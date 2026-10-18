-- =============================================================================
-- init.lua — Neovim Configuration
-- =============================================================================

-- Leader key (set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- =============================================================================
-- OPTIONS
-- =============================================================================
local opt = vim.opt

-- UI
opt.number         = true          -- Show line numbers
opt.relativenumber = true          -- Relative line numbers
opt.cursorline     = true          -- Highlight current line
opt.signcolumn     = "yes"         -- Always show sign column
opt.scrolloff      = 8             -- Keep 8 lines visible above/below cursor
opt.sidescrolloff  = 8
opt.wrap           = false         -- No line wrap
opt.showmode       = false         -- Mode shown in statusline instead
opt.termguicolors  = true          -- True color support
opt.pumheight      = 10            -- Max popup menu height
opt.splitright     = true          -- Vertical splits go right
opt.splitbelow     = true          -- Horizontal splits go below

-- Editing
opt.tabstop        = 4             -- Tab width
opt.shiftwidth     = 4             -- Indent width
opt.expandtab      = true          -- Use spaces instead of tabs
opt.smartindent    = true          -- Smart auto-indenting
opt.autoindent     = true
opt.breakindent    = true          -- Wrapped lines keep indent

-- Search
opt.ignorecase     = true          -- Case-insensitive search...
opt.smartcase      = true          -- ...unless uppercase is used
opt.hlsearch       = true          -- Highlight search results
opt.incsearch      = true          -- Incremental search

-- Files
opt.undofile       = true          -- Persistent undo
opt.swapfile       = false         -- No swap files
opt.backup         = false         -- No backup files
opt.updatetime     = 250           -- Faster CursorHold events
opt.timeoutlen     = 300           -- Faster key sequence timeout

-- Clipboard — macOS uses pbcopy/pbpaste via "unnamed" or "unnamedplus"
opt.clipboard      = "unnamedplus"

-- Completion
opt.completeopt    = { "menuone", "noselect" }

-- Folding (using treesitter if available, else indent)
opt.foldmethod     = "indent"
opt.foldlevel      = 99            -- Open all folds by default

-- =============================================================================
-- KEYMAPS
-- =============================================================================
local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true, noremap = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Change to normal mode from terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>")

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Better window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Resize windows
map("n", "<C-Up>",    "<cmd>resize +2<CR>")
map("n", "<C-Down>",  "<cmd>resize -2<CR>")
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centred when jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n",     "nzzzv")
map("n", "N",     "Nzzzv")

-- Don't lose register when pasting over selection
map("x", "<leader>p", '"_dP', { desc = "Paste without losing register" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>",     { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Save and quit shortcuts
map("n", "<leader>w", "<cmd>write<CR>",  { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>",   { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qall!<CR>",  { desc = "Quit all" })

-- Indent and stay in visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Open netrw file explorer
map("n", "<leader>e", "<cmd>Explore<CR>", { desc = "File explorer" })

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev,  { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- =============================================================================
-- AUTOCOMMANDS
-- =============================================================================
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
autocmd("TextYankPost", {
  group   = augroup("highlight_yank", { clear = true }),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group   = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Return to last cursor position when opening a file
autocmd("BufReadPost", {
  group = augroup("last_cursor_pos", { clear = true }),
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Set 2-space indent for web/config filetypes
autocmd("FileType", {
  group   = augroup("two_space_indent", { clear = true }),
  pattern = { "lua", "javascript", "typescript", "html", "css", "json", "yaml", "toml" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Enable native treesitter highlighting (Neovim 0.12 built-in, no plugin needed)
autocmd("FileType", {
  group = augroup("ts_highlight", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Automatically close quickfix if it's the last window
autocmd("WinEnter", {
  group   = augroup("auto_close_qf", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "qf" and #vim.api.nvim_list_wins() == 1 then
      vim.cmd("quit")
    end
  end,
})

-- =============================================================================
-- LSP HOVER: strip HTML that pyright injects into hover docs.
-- Wrap open_floating_preview so we catch the content as lines right before
-- display — more reliable than intercepting the handler, and lets us split
-- <br> tags into real newlines (they appear mid-line as separators).
-- =============================================================================
do
  local orig = vim.lsp.util.open_floating_preview
  local function clean(s)
    s = s:gsub("</?[Pp]%s*/?>", "")   -- <p>, </p>
    s = s:gsub("<[^>\n]+>",     "")   -- any remaining tag
    s = s:gsub("&lt;",  "<")
    s = s:gsub("&gt;",  ">")
    s = s:gsub("&amp;", "&")
    s = s:gsub("&quot;", '"')
    return s
  end
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
    local out = {}
    for _, line in ipairs(contents) do
      -- Split on <br> variants first, then clean each part
      local parts = vim.split(line:gsub("<[Bb][Rr]%s*/?>", "\0"), "\0", { plain = true })
      for _, part in ipairs(parts) do
        out[#out + 1] = clean(part)
      end
    end
    return orig(out, syntax, opts, ...)
  end
end

-- =============================================================================
-- PLUGIN MANAGER (lazy.nvim — auto-installs if missing)
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- FIX: vim.loop is deprecated in Neovim 0.10+; use vim.uv instead, with
--      a fallback so the config still works on older builds.
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- --------------------------------------------------------------------------
  -- Colorscheme
  -- --------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    opts     = { style = "night", transparent = false },
    config   = function()
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  -- Treesitter: nvim-treesitter removed — Neovim 0.12 ships native treesitter
  -- highlighting + bundled parsers. No plugin needed.

  -- --------------------------------------------------------------------------
  -- Telescope — fuzzy finder
  -- --------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    branch       = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      -- File browser extension
      {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    cmd  = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>",  desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",   desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",     desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",   desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>",    desc = "Recent files" },
      { "<leader>fc", "<cmd>Telescope commands<CR>",    desc = "Commands" },
      -- File browser: open at current file's directory
      {
        "<leader>fe",
        "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
        desc = "File browser (current dir)",
      },
      -- File browser: open at cwd
      { "<leader>fE", "<cmd>Telescope file_browser<CR>", desc = "File browser (cwd)" },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "file_browser")
    end,
    opts = {
      defaults = {
        prompt_prefix    = "> ",
        selection_caret  = "> ",
        path_display     = { "smart" },
        sorting_strategy = "ascending",
        layout_config    = { prompt_position = "top" },
      },
      extensions = {
        file_browser = {
          hijack_netrw  = true,   -- replaces netrw when opening a directory
          hidden        = true,   -- show dotfiles by default
          grouped       = true,   -- folders listed before files
          previewer     = false,  -- cleaner look without a preview pane
          initial_mode  = "normal",
          layout_config = { height = 0.5 },
        },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- LSP — Language Server Protocol (Neovim 0.11+ native API)
  -- --------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Mason: installs the server binaries
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed    = { "lua_ls", "pyright", "ts_ls", "bashls" },
        automatic_installation = true,
      })

      -- Merge nvim-cmp capabilities if available
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- Keymaps attached whenever any LSP connects to a buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
        callback = function(event)
          local bmap = function(mode, lhs, rhs, desc)
            map(mode, lhs, rhs, { buffer = event.buf, desc = desc })
          end
          bmap("n", "gd",          vim.lsp.buf.definition,     "Go to definition")
          bmap("n", "gD",          vim.lsp.buf.declaration,    "Go to declaration")
          bmap("n", "gr",          vim.lsp.buf.references,     "References")
          bmap("n", "gi",          vim.lsp.buf.implementation, "Implementation")
          bmap("n", "K",           vim.lsp.buf.hover,          "Hover docs")
          bmap("n", "<leader>rn",  vim.lsp.buf.rename,         "Rename")
          bmap("n", "<leader>ca",  vim.lsp.buf.code_action,    "Code action")
          bmap("n", "<leader>f",   function()
            vim.lsp.buf.format({ async = true })
          end, "Format buffer")
        end,
      })

      -- Per-server config via the new vim.lsp.config() API
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
          },
        },
      })

      vim.lsp.config("pyright",  { capabilities = capabilities })
      vim.lsp.config("ts_ls",    { capabilities = capabilities })
      vim.lsp.config("bashls",   { capabilities = capabilities })

      -- Enable all configured servers
      vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "bashls" })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Autocompletion
  -- --------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Git integration
  -- --------------------------------------------------------------------------
  {
    "tpope/vim-fugitive",
    cmd  = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Glog", "Gclog", "Gblame" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>",          desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<CR>",   desc = "Git commit" },
      { "<leader>gp", "<cmd>Git push<CR>",     desc = "Git push" },
      { "<leader>gl", "<cmd>Gclog<CR>",        desc = "Git log" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>",   desc = "Git diff split" },
      { "<leader>gb", "<cmd>Git blame<CR>",    desc = "Git blame" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local bmap = function(mode, l, r, desc)
          map(mode, l, r, { buffer = bufnr, desc = desc })
        end
        bmap("n", "]c", gs.next_hunk,        "Next hunk")
        bmap("n", "[c", gs.prev_hunk,        "Prev hunk")
        bmap("n", "<leader>hs", gs.stage_hunk,   "Stage hunk")
        bmap("n", "<leader>hr", gs.reset_hunk,   "Reset hunk")
        bmap("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        bmap("n", "<leader>hb", gs.blame_line,   "Blame line")
      end,
    },
  },

  -- --------------------------------------------------------------------------
  -- Status line
  -- --------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event        = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme                = "tokyonight",
        component_separators = "|",
        section_separators   = { left = "", right = "" },
        globalstatus         = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Auto pairs
  -- --------------------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = { check_ts = true },
  },

  -- --------------------------------------------------------------------------
  -- Comments
  -- --------------------------------------------------------------------------
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts  = {},
  },

  -- --------------------------------------------------------------------------
  -- Which-key — keybind hints
  -- --------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {},
  },

  -- --------------------------------------------------------------------------
  -- Indentation guides
  -- --------------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main  = "ibl",
    opts  = {
      indent = { char = "│" },
      scope  = { enabled = true },
      exclude = {
        filetypes = { "TelescopePrompt", "TelescopeResults", "TelescopePreview" },
      },
    },
  },

}, {
  -- lazy.nvim options
  install = { colorscheme = { "tokyonight", "habamax" } },
  ui      = { border = "rounded" },
  checker = { enabled = true, notify = false },
})
