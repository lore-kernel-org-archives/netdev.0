From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/5] [LIB] Naive regular expression string-matching algorithm
Date: Sat, 28 May 2005 00:48:37 +0200
Message-ID: <20050527224837.GJ15391@postel.suug.ch>
References: <20050527224725.GG15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050527224725.GG15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 81553cdea2a7ff762cb44aeced743d3a77efd2d7
tree 266c4ad512e5ae71bd7cd88c94bfb18fb2f761d6
parent 5b70ca8eab4c7d7ef884582d9713cdbffa0f4cd4
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 23:44:24 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 23:44:24 +0200

 include/linux/textsearch_regexp.h |   47 ++++++
 lib/Kconfig                       |    9 +
 lib/Makefile                      |    1 
 lib/ts_regexp.c                   |  272 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 329 insertions(+)

Index: include/linux/textsearch_regexp.h
===================================================================
--- /dev/null  (tree:4d90ca82120da7b308b9a6bf11a1069473ca5d30)
+++ 266c4ad512e5ae71bd7cd88c94bfb18fb2f761d6/include/linux/textsearch_regexp.h  (mode:100644)
@@ -0,0 +1,47 @@
+#ifndef __LINUX_TEXTSEARCH_REGEXP_H
+#define __LINUX_TEXTSEARCH_REGEXP_H
+
+#include <linux/types.h>
+
+enum {
+	TS_RE_SPECIFIC,		/* specific character */
+	TS_RE_WILDCARD,		/* any character */
+	TS_RE_DIGIT,		/* isdigit() */
+	TS_RE_XDIGIT,		/* isxdigit() */
+	TS_RE_PRINT,		/* isprint() */
+	TS_RE_ALPHA,		/* isalpha() */
+	TS_RE_ALNUM,		/* isalnum() */
+	TS_RE_ASCII,		/* isascii() */
+	TS_RE_CNTRL,		/* iscntrl() */
+	TS_RE_GRAPH,		/* isgraph() */
+	TS_RE_LOWER,		/* islower() */
+	TS_RE_UPPER,		/* isupper() */
+	TS_RE_PUNCT,		/* ispunct() */
+	TS_RE_SPACE,		/* isspace() */
+	__TS_RE_TYPE_MAX,
+};
+#define TS_RE_TYPE_MAX (__TS_RE_TYPE_MAX - 1)
+
+enum {
+	TS_RE_SINGLE,		/* 1 occurrence */
+	TS_RE_PERHAPS,		/* 1 or 0 occurrence */
+	TS_RE_ANY,		/* 0..n occurrences */
+	TS_RE_MULTI,		/* 1..n occurrences */
+	__TS_RE_RECUR_MAX,
+};
+#define TS_RE_RECUR_MAX (__TS_RE_RECUR_MAX - 1)
+
+/**
+ * struct ts_regexp_token - regular expression token
+ * @type: type of token
+ * @recur: number of recurrences
+ * @value: character value for TS_RE_SPECIFIC
+ */
+struct ts_regexp_token
+{
+	__u16		type;
+	__u8		recur;
+	__u8		value;
+};
+
+#endif
Index: lib/Kconfig
===================================================================
--- 4d90ca82120da7b308b9a6bf11a1069473ca5d30/lib/Kconfig  (mode:100644)
+++ 266c4ad512e5ae71bd7cd88c94bfb18fb2f761d6/lib/Kconfig  (mode:100644)
@@ -68,6 +68,15 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called ts_kmp.
 
+config TEXTSEARCH_REGEXP
+	tristate "Regular Expression"
+	help
+	  Say Y here if you want to be able to search text using a
+	  naive and limited regular expression textsearch algorithm.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called ts_regexp.
+
 endmenu
 
 endmenu
Index: lib/Makefile
===================================================================
--- 4d90ca82120da7b308b9a6bf11a1069473ca5d30/lib/Makefile  (mode:100644)
+++ 266c4ad512e5ae71bd7cd88c94bfb18fb2f761d6/lib/Makefile  (mode:100644)
@@ -34,6 +34,7 @@
 obj-$(CONFIG_REED_SOLOMON) += reed_solomon/
 
 obj-$(CONFIG_TEXTSEARCH_KMP) += ts_kmp.o
+obj-$(CONFIG_TEXTSEARCH_REGEXP) += ts_regexp.o
 
 hostprogs-y	:= gen_crc32table
 clean-files	:= crc32table.h
Index: lib/ts_regexp.c
===================================================================
--- /dev/null  (tree:4d90ca82120da7b308b9a6bf11a1069473ca5d30)
+++ 266c4ad512e5ae71bd7cd88c94bfb18fb2f761d6/lib/ts_regexp.c  (mode:100644)
@@ -0,0 +1,272 @@
+/*
+ * lib/ts_regexp.c	Naive and very limited regular expression
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/ctype.h>
+#include <linux/textsearch.h>
+#include <linux/textsearch_regexp.h>
+
+struct ts_regexp
+{
+	int			ntokens;
+	struct ts_regexp_token	tokens[0];
+};
+
+/* other values derived from ctype.h */
+#define _A		0x100 /* ascii */
+#define _W		0x200 /* wildcard */
+
+/* Map to _ctype flags and some magic numbers */
+static u16 token_map[TS_RE_TYPE_MAX+1] = {
+	[TS_RE_SPECIFIC]  = 0,
+	[TS_RE_WILDCARD]  = _W,
+	[TS_RE_CNTRL]	  = _C,
+	[TS_RE_LOWER]	  = _L,
+	[TS_RE_UPPER]	  = _U,
+	[TS_RE_PUNCT]	  = _P,
+	[TS_RE_SPACE]	  = _S,
+	[TS_RE_DIGIT]	  = _D,
+	[TS_RE_XDIGIT]	  = _D | _X,
+	[TS_RE_ALPHA]	  = _U | _L,
+	[TS_RE_ALNUM]	  = _U | _L | _D,
+	[TS_RE_PRINT]	  = _P | _U | _L | _D | _SP,
+	[TS_RE_GRAPH]	  = _P | _U | _L | _D,
+	[TS_RE_ASCII]	  = _A,
+};
+
+static u16 token_lookup_tbl[256] = {
+_W|_A|_C,      _W|_A|_C,     _W|_A|_C,     _W|_A|_C,		/*   0-  3 */
+_W|_A|_C,      _W|_A|_C,     _W|_A|_C,     _W|_A|_C,		/*   4-  7 */
+_W|_A|_C,      _W|_A|_C|_S,  _W|_A|_C|_S,  _W|_A|_C|_S,		/*   8- 11 */
+_W|_A|_C|_S,   _W|_A|_C|_S,  _W|_A|_C,     _W|_A|_C,		/*  12- 15 */
+_W|_A|_C,      _W|_A|_C,     _W|_A|_C,     _W|_A|_C,		/*  16- 19 */
+_W|_A|_C,      _W|_A|_C,     _W|_A|_C,     _W|_A|_C,		/*  20- 23 */
+_W|_A|_C,      _W|_A|_C,     _W|_A|_C,     _W|_A|_C,		/*  24- 27 */
+_W|_A|_C,      _W|_A|_C,     _W|_A|_C,     _W|_A|_C,		/*  28- 31 */
+_W|_A|_S|_SP,  _W|_A|_P,     _W|_A|_P,     _W|_A|_P,		/*  32- 35 */
+_W|_A|_P,      _W|_A|_P,     _W|_A|_P,     _W|_A|_P,		/*  36- 39 */
+_W|_A|_P,      _W|_A|_P,     _W|_A|_P,     _W|_A|_P,		/*  40- 43 */
+_W|_A|_P,      _W|_A|_P,     _W|_A|_P,     _W|_A|_P,		/*  44- 47 */
+_W|_A|_D,      _W|_A|_D,     _W|_A|_D,     _W|_A|_D,		/*  48- 51 */
+_W|_A|_D,      _W|_A|_D,     _W|_A|_D,     _W|_A|_D,		/*  52- 55 */
+_W|_A|_D,      _W|_A|_D,     _W|_A|_P,     _W|_A|_P,		/*  56- 59 */
+_W|_A|_P,      _W|_A|_P,     _W|_A|_P,     _W|_A|_P,		/*  60- 63 */
+_W|_A|_P,      _W|_A|_U|_X,  _W|_A|_U|_X,  _W|_A|_U|_X,		/*  64- 67 */
+_W|_A|_U|_X,   _W|_A|_U|_X,  _W|_A|_U|_X,  _W|_A|_U,		/*  68- 71 */
+_W|_A|_U,      _W|_A|_U,     _W|_A|_U,     _W|_A|_U,		/*  72- 75 */
+_W|_A|_U,      _W|_A|_U,     _W|_A|_U,     _W|_A|_U,		/*  76- 79 */
+_W|_A|_U,      _W|_A|_U,     _W|_A|_U,     _W|_A|_U,		/*  80- 83 */
+_W|_A|_U,      _W|_A|_U,     _W|_A|_U,     _W|_A|_U,		/*  84- 87 */
+_W|_A|_U,      _W|_A|_U,     _W|_A|_U,     _W|_A|_P,		/*  88- 91 */
+_W|_A|_P,      _W|_A|_P,     _W|_A|_P,     _W|_A|_P,		/*  92- 95 */
+_W|_A|_P,      _W|_A|_L|_X,  _W|_A|_L|_X,  _W|_A|_L|_X,		/*  96- 99 */
+_W|_A|_L|_X,   _W|_A|_L|_X,  _W|_A|_L|_X,  _W|_A|_L,		/* 100-103 */
+_W|_A|_L,      _W|_A|_L,     _W|_A|_L,     _W|_A|_L,		/* 104-107 */
+_W|_A|_L,      _W|_A|_L,     _W|_A|_L,     _W|_A|_L,		/* 108-111 */
+_W|_A|_L,      _W|_A|_L,     _W|_A|_L,     _W|_A|_L,		/* 112-115 */
+_W|_A|_L,      _W|_A|_L,     _W|_A|_L,     _W|_A|_L,		/* 116-119 */
+_W|_A|_L,      _W|_A|_L,     _W|_A|_L,     _W|_A|_P,		/* 120-123 */
+_W|_A|_P,      _W|_A|_P,     _W|_A|_P,     _W|_A|_C,		/* 124-127 */
+_W,            _W,           _W,           _W,			/* 128-131 */
+_W,            _W,           _W,           _W,			/* 132-135 */
+_W,            _W,           _W,           _W,			/* 136-139 */
+_W,            _W,           _W,           _W,			/* 140-143 */
+_W,            _W,           _W,           _W,			/* 144-147 */
+_W,            _W,           _W,           _W,			/* 148-151 */
+_W,            _W,           _W,           _W,			/* 152-155 */
+_W,            _W,           _W,           _W,			/* 156-159 */
+_W|_S|_SP,     _W|_P,        _W|_P,        _W|_P,		/* 160-163 */
+_W|_P,         _W|_P,        _W|_P,        _W|_P,		/* 164-167 */
+_W|_P,         _W|_P,        _W|_P,        _W|_P,		/* 168-171 */
+_W|_P,         _W|_P,        _W|_P,        _W|_P,		/* 172-175 */
+_W|_P,         _W|_P,        _W|_P,        _W|_P,		/* 176-179 */
+_W|_P,         _W|_P,        _W|_P,        _W|_P,		/* 180-183 */
+_W|_P,         _W|_P,        _W|_P,        _W|_P,		/* 184-187 */
+_W|_P,         _W|_P,        _W|_P,        _W|_P,		/* 188-191 */
+_W|_U,         _W|_U,        _W|_U,        _W|_U,		/* 192-195 */
+_W|_U,         _W|_U,        _W|_U,        _W|_U,		/* 196-199 */
+_W|_U,         _W|_U,        _W|_U,        _W|_U,		/* 200-203 */
+_W|_U,         _W|_U,        _W|_U,        _W|_U,		/* 204-207 */
+_W|_U,         _W|_U,        _W|_U,        _W|_U,		/* 208-211 */
+_W|_U,         _W|_U,        _W|_U,        _W|_P,		/* 212-215 */
+_W|_U,         _W|_U,        _W|_U,        _W|_U,		/* 216-219 */
+_W|_U,         _W|_U,        _W|_U,        _W|_L,		/* 220-223 */
+_W|_L,         _W|_L,        _W|_L,        _W|_L,		/* 224-227 */
+_W|_L,         _W|_L,        _W|_L,        _W|_L,		/* 228-231 */
+_W|_L,         _W|_L,        _W|_L,        _W|_L,		/* 232-235 */
+_W|_L,         _W|_L,        _W|_L,        _W|_L,		/* 236-239 */
+_W|_L,         _W|_L,        _W|_L,        _W|_L,		/* 240-243 */
+_W|_L,         _W|_L,        _W|_L,        _W|_P,		/* 244-247 */
+_W|_L,         _W|_L,        _W|_L,        _W|_L,		/* 248-251 */
+_W|_L,         _W|_L,        _W|_L,        _W|_L};		/* 252-255 */
+
+static inline int match_token(struct ts_regexp_token *t, u8 d)
+{
+	if (t->type)
+		return (token_lookup_tbl[d] & t->type) != 0;
+	else
+		return t->value == d;
+}
+
+static int regexp_find(struct ts_config *conf, struct ts_state *state)
+{
+	struct ts_regexp *regexp = ts_config_priv(conf);
+	int i, q, consumed = state->offset;
+	int match_start = state->offset;
+	struct ts_regexp_token *t = NULL, *next;
+	size_t text_len = 0;
+	unsigned char *text;
+
+#define GET_TEXT() \
+	({ i = 0; conf->get_text(consumed, &text, conf, state); })
+
+#define end_of_text()  (i >= text_len && !GET_TEXT())
+#define more_text() (i < text_len || GET_TEXT())
+
+#define NEXT_CHAR() do { i++; consumed++; } while (0)
+	
+	for (i = 0, q = 0; q < regexp->ntokens; q++) {
+		t = &regexp->tokens[q];
+
+		if (likely(q < (regexp->ntokens - 1)))
+			next = &regexp->tokens[q+1];
+		else
+			next = NULL;
+
+		switch (t->recur) {
+			case TS_RE_SINGLE:
+				if (unlikely(end_of_text()))
+					goto no_match;
+
+				if (!match_token(t, text[i]))
+					goto no_match;
+				break;
+
+			case TS_RE_PERHAPS:
+				if (likely(more_text()))
+					if (match_token(t, text[i]))
+						break;
+				continue;
+
+			case TS_RE_MULTI:
+				if (unlikely(end_of_text()))
+					goto no_match;
+
+				if (!match_token(t, text[i]))
+					goto no_match;
+
+				NEXT_CHAR();
+				/* fall through */
+
+			case TS_RE_ANY:
+				if (next == NULL)
+					goto found_match;
+
+				if (likely(more_text())) {
+					while (!match_token(next, text[i])) {
+						if (!match_token(t, text[i]))
+							goto no_match;
+						NEXT_CHAR();
+						if (unlikely(end_of_text()))
+							goto no_match;
+					}
+				}
+				continue;
+		}
+
+		NEXT_CHAR();
+	}
+
+	if (q >= (regexp->ntokens - 1))
+		goto found_match;
+
+no_match:
+	return -1;
+
+found_match:
+	state->offset = consumed + i + 1;
+	return match_start;
+}
+
+static struct ts_config *regexp_init(const unsigned char *pattern, size_t len,
+				     int gfp_mask)
+{
+	int i, err = -EINVAL;
+	struct ts_config *conf;
+	struct ts_regexp *regexp;
+	struct ts_regexp_token *tokens = (struct ts_regexp_token *) pattern;
+
+	if (len  % sizeof(struct ts_regexp_token))
+		goto errout;
+
+	for (i = 0; i < len / sizeof(struct ts_regexp_token); i++) {
+		struct ts_regexp_token *t = &tokens[i];
+
+		if (t->type > TS_RE_TYPE_MAX ||
+		    t->type > TS_RE_RECUR_MAX)
+			goto errout;
+
+		t->type = token_map[t->type];
+	}
+
+	conf = alloc_ts_config(len, gfp_mask);
+	if (IS_ERR(conf))
+		return conf;
+
+	regexp = ts_config_priv(conf);
+	regexp->ntokens = len / sizeof(struct ts_regexp_token);
+	memcpy(regexp->tokens, pattern, len);
+
+	return conf;
+
+errout:
+	return ERR_PTR(err);
+}
+
+static unsigned char *regexp_get_pattern(struct ts_config *conf)
+{
+	struct ts_regexp *regexp = ts_config_priv(conf);
+	return (unsigned char *) regexp->tokens;
+}
+
+static unsigned int regexp_get_pattern_len(struct ts_config *conf)
+{
+	struct ts_regexp *regexp = ts_config_priv(conf);
+	return regexp->ntokens * sizeof(struct ts_regexp_token);
+}
+
+static struct ts_ops regexp_ops = {
+	.name		  = "regexp",
+	.find		  = regexp_find,
+	.init		  = regexp_init,
+	.get_pattern	  = regexp_get_pattern,
+	.get_pattern_len  = regexp_get_pattern_len,
+	.owner		  = THIS_MODULE,
+	.list		  = LIST_HEAD_INIT(regexp_ops.list)
+};
+
+static int __init init_regexp(void)
+{
+	return textsearch_register(&regexp_ops);
+}
+
+static void __exit exit_regexp(void)
+{
+	textsearch_unregister(&regexp_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_regexp);
+module_exit(exit_regexp);
