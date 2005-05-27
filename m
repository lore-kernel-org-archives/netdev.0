From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] [LIB] Knuth-Morris-Pratt string-matching algorithm
Date: Sat, 28 May 2005 00:48:18 +0200
Message-ID: <20050527224818.GI15391@postel.suug.ch>
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
commit 5b70ca8eab4c7d7ef884582d9713cdbffa0f4cd4
tree 4d90ca82120da7b308b9a6bf11a1069473ca5d30
parent bf7ae763f13d767bd039703b3ab4f5954561df39
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 23:44:02 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 23:44:02 +0200

 lib/Kconfig  |   13 +++++
 lib/Makefile |    2 
 lib/ts_kmp.c |  145 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 160 insertions(+)

Index: lib/Kconfig
===================================================================
--- ab065819ea6e966aa3db4f1c5935c421dd689d2e/lib/Kconfig  (mode:100644)
+++ 4d90ca82120da7b308b9a6bf11a1069473ca5d30/lib/Kconfig  (mode:100644)
@@ -57,5 +57,18 @@
 config REED_SOLOMON_DEC16
 	boolean
 
+menu "Textsearch facility"
+
+config TEXTSEARCH_KMP
+	tristate "Knuth-Morris-Pratt"
+	help
+	  Say Y here if you want to be able to search text using the
+	  Knuth-Morris-Pratt textsearch algorithm.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called ts_kmp.
+
+endmenu
+
 endmenu
 
Index: lib/Makefile
===================================================================
--- ab065819ea6e966aa3db4f1c5935c421dd689d2e/lib/Makefile  (mode:100644)
+++ 4d90ca82120da7b308b9a6bf11a1069473ca5d30/lib/Makefile  (mode:100644)
@@ -33,6 +33,8 @@
 obj-$(CONFIG_ZLIB_DEFLATE) += zlib_deflate/
 obj-$(CONFIG_REED_SOLOMON) += reed_solomon/
 
+obj-$(CONFIG_TEXTSEARCH_KMP) += ts_kmp.o
+
 hostprogs-y	:= gen_crc32table
 clean-files	:= crc32table.h
 
Index: lib/ts_kmp.c
===================================================================
--- /dev/null  (tree:ab065819ea6e966aa3db4f1c5935c421dd689d2e)
+++ 4d90ca82120da7b308b9a6bf11a1069473ca5d30/lib/ts_kmp.c  (mode:100644)
@@ -0,0 +1,145 @@
+/*
+ * lib/ts_kmp.c		Knuth-Morris-Pratt text search implementation
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ * 
+ * Implements a linear-time string-matching algorithm due to Knuth,
+ * Morris, and Pratt [0]. Their algorithm avoids the explicit
+ * computation of the transition function DELTA altogether. Its
+ * matching time is O(n), for n being length(text), using just an
+ * auxiliary function PI[1..m], for m being length(pattern),
+ * precomputed from the pattern in time O(m). The array PI allows
+ * the transition function DELTA to be computed efficiently
+ * "on the fly" as needed. Roughly speaking, for any state
+ * "q" = 0,1,...,m and any character "a" in SIGMA, the value
+ * PI["q"] contains the information that is independent of "a" and
+ * is needed to compute DELTA("q", "a") [1]. Since the array PI
+ * has only m entries, whereas DELTA has O(m|SIGMA|) entries, we
+ * save a factor of |SIGMA| in the preprocessing time by computing
+ * PI rather than DELTA.
+ *
+ * [0] Cormen, Leiserson, Rivest, Stein
+ *     Introdcution to Algorithms, 2nd Edition, MIT Press
+ * [1] See finite automation theory
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/textsearch.h>
+
+struct ts_kmp
+{
+	int		pattern_len;
+	unsigned char *	pattern;
+	unsigned int 	prefix_tbl[0];
+};
+
+static int kmp_find(struct ts_config *conf, struct ts_state *state)
+{
+	struct ts_kmp *kmp = ts_config_priv(conf);
+	int i, q = 0, consumed = state->offset;
+	unsigned char *text;
+	size_t text_len;
+
+	for (;;) {
+		text_len = conf->get_text(consumed, &text, conf, state);
+
+		if (text_len == 0)
+			break;
+
+		for (i = 0; i < text_len; i++) {
+			while (q > 0 && kmp->pattern[q] != text[i])
+				q = kmp->prefix_tbl[q - 1];
+			if (kmp->pattern[q] == text[i])
+				q++;
+			if (q == kmp->pattern_len) {
+				state->offset = consumed + i + 1;
+				return state->offset - kmp->pattern_len;
+			}
+		}
+
+		consumed += text_len;
+	}
+
+	return -1;
+
+}
+
+static inline void compute_prefix_tbl(const unsigned char *pattern, size_t len,
+				      unsigned int *prefix_tbl)
+{
+	unsigned int k, q;
+
+	for (k = 0, q = 1; q < len; q++) {
+		while (k > 0 && pattern[k] != pattern[q])
+			k = prefix_tbl[k-1];
+		if (pattern[k] == pattern[q])
+			k++;
+		prefix_tbl[q] = k;
+	}
+}
+
+static struct ts_config *kmp_init(const unsigned char *pattern, size_t len,
+				  int gfp_mask)
+{
+	struct ts_config *conf;
+	struct ts_kmp *kmp;
+	size_t prefix_tbl_len = len * sizeof(unsigned int);
+	size_t priv_size = sizeof(*kmp) + len + prefix_tbl_len;
+
+	conf = alloc_ts_config(priv_size, gfp_mask);
+	if (IS_ERR(conf))
+		return conf;
+
+	kmp = ts_config_priv(conf);
+	kmp->pattern_len = len;
+	compute_prefix_tbl(pattern, len, kmp->prefix_tbl);
+	kmp->pattern = (unsigned char *) kmp->prefix_tbl + prefix_tbl_len;
+	memcpy(kmp->pattern, pattern, len);
+
+	return conf;
+}
+
+static unsigned char *kmp_get_pattern(struct ts_config *conf)
+{
+	struct ts_kmp *kmp = ts_config_priv(conf);
+	return kmp->pattern;
+}
+
+static unsigned int kmp_get_pattern_len(struct ts_config *conf)
+{
+	struct ts_kmp *kmp = ts_config_priv(conf);
+	return kmp->pattern_len;
+}
+
+static struct ts_ops kmp_ops = {
+	.name		  = "kmp",
+	.find		  = kmp_find,
+	.init		  = kmp_init,
+	.get_pattern	  = kmp_get_pattern,
+	.get_pattern_len  = kmp_get_pattern_len,
+	.owner		  = THIS_MODULE,
+	.list		  = LIST_HEAD_INIT(kmp_ops.list)
+};
+
+static int __init init_kmp(void)
+{
+	return textsearch_register(&kmp_ops);
+}
+
+static void __exit exit_kmp(void)
+{
+	textsearch_unregister(&kmp_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_kmp);
+module_exit(exit_kmp);
