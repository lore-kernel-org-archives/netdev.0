From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 4/8] textsearch: fix Knuth-Morris-Pratt for case insensitive searching
Date: Sat, 21 Jun 2008 00:54:11 -0700
Message-ID: <1214034851-1338-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <>
References: <>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix Knuth-Morris-Pratt algorithm to have capability of case insensitive
searching

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 lib/ts_kmp.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/lib/ts_kmp.c b/lib/ts_kmp.c
index 3ced628..fb55d6c 100644
--- a/lib/ts_kmp.c
+++ b/lib/ts_kmp.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/ctype.h>
 #include <linux/textsearch.h>
 
 struct ts_kmp
@@ -47,6 +48,7 @@ static unsigned int kmp_find(struct ts_config *conf, struct ts_state *state)
 	struct ts_kmp *kmp = ts_config_priv(conf);
 	unsigned int i, q = 0, text_len, consumed = state->offset;
 	const u8 *text;
+	const int icase = conf->icase;
 
 	for (;;) {
 		text_len = conf->get_next_block(consumed, &text, conf, state);
@@ -55,9 +57,11 @@ static unsigned int kmp_find(struct ts_config *conf, struct ts_state *state)
 			break;
 
 		for (i = 0; i < text_len; i++) {
-			while (q > 0 && kmp->pattern[q] != text[i])
+			while (q > 0 && kmp->pattern[q]
+			    != (icase ? toupper(text[i]) : text[i]))
 				q = kmp->prefix_tbl[q - 1];
-			if (kmp->pattern[q] == text[i])
+			if (kmp->pattern[q]
+			    == (icase ? toupper(text[i]) : text[i]))
 				q++;
 			if (unlikely(q == kmp->pattern_len)) {
 				state->offset = consumed + i + 1;
@@ -72,24 +76,27 @@ static unsigned int kmp_find(struct ts_config *conf, struct ts_state *state)
 }
 
 static inline void compute_prefix_tbl(const u8 *pattern, unsigned int len,
-				      unsigned int *prefix_tbl)
+				      unsigned int *prefix_tbl, u8 icase)
 {
 	unsigned int k, q;
 
 	for (k = 0, q = 1; q < len; q++) {
-		while (k > 0 && pattern[k] != pattern[q])
+		while (k > 0 && (icase ? toupper(pattern[k]) : pattern[k])
+		    != (icase ? toupper(pattern[q]) : pattern[q]))
 			k = prefix_tbl[k-1];
-		if (pattern[k] == pattern[q])
+		if ((icase ? toupper(pattern[k]) : pattern[k])
+		    == (icase ? toupper(pattern[q]) : pattern[q]))
 			k++;
 		prefix_tbl[q] = k;
 	}
 }
 
 static struct ts_config *kmp_init(const void *pattern, unsigned int len,
-				  gfp_t gfp_mask)
+				  u8 icase, gfp_t gfp_mask)
 {
 	struct ts_config *conf;
 	struct ts_kmp *kmp;
+	int i;
 	unsigned int prefix_tbl_len = len * sizeof(unsigned int);
 	size_t priv_size = sizeof(*kmp) + len + prefix_tbl_len;
 
@@ -97,11 +104,16 @@ static struct ts_config *kmp_init(const void *pattern, unsigned int len,
 	if (IS_ERR(conf))
 		return conf;
 
+	conf->icase = icase;
 	kmp = ts_config_priv(conf);
 	kmp->pattern_len = len;
-	compute_prefix_tbl(pattern, len, kmp->prefix_tbl);
+	compute_prefix_tbl(pattern, len, kmp->prefix_tbl, icase);
 	kmp->pattern = (u8 *) kmp->prefix_tbl + prefix_tbl_len;
-	memcpy(kmp->pattern, pattern, len);
+	if (icase)
+		for (i = 0; i < len; i++)
+			kmp->pattern[i] = toupper(((u8 *)pattern)[i]);
+	else
+		memcpy(kmp->pattern, pattern, len);
 
 	return conf;
 }
-- 
1.5.4.3

