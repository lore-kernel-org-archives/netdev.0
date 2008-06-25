From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 3/8 v2] textsearch: fix Boyer-Moore algorithm for case insensitive searching
Date: Wed, 25 Jun 2008 03:24:58 -0700
Message-ID: <1214389498-21345-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:63005 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497AbYFYKY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 06:24:59 -0400
Received: by rv-out-0506.google.com with SMTP id k40so8130417rvb.1
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 03:24:59 -0700 (PDT)
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix Boyer-Moore algorithm to have capability of case insensitive
searching

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 lib/ts_bm.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/lib/ts_bm.c b/lib/ts_bm.c
index 4a7fce7..9e66ee4 100644
--- a/lib/ts_bm.c
+++ b/lib/ts_bm.c
@@ -39,6 +39,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/ctype.h>
 #include <linux/textsearch.h>
 
 /* Alphabet size, use ASCII */
@@ -64,6 +65,7 @@ static unsigned int bm_find(struct ts_config *conf, struct ts_state *state)
 	unsigned int i, text_len, consumed = state->offset;
 	const u8 *text;
 	int shift = bm->patlen - 1, bs;
+	const u8 icase = conf->flags & TS_IGNORECASE;
 
 	for (;;) {
 		text_len = conf->get_next_block(consumed, &text, conf, state);
@@ -75,7 +77,9 @@ static unsigned int bm_find(struct ts_config *conf, struct ts_state *state)
 			DEBUGP("Searching in position %d (%c)\n", 
 				shift, text[shift]);
 			for (i = 0; i < bm->patlen; i++) 
-			     if (text[shift-i] != bm->pattern[bm->patlen-1-i])
+				if ((icase ? toupper(text[shift-i])
+				    : text[shift-i])
+					!= bm->pattern[bm->patlen-1-i])
 				     goto next;
 
 			/* London calling... */
@@ -111,14 +115,18 @@ static int subpattern(u8 *pattern, int i, int j, int g)
 	return ret;
 }
 
-static void compute_prefix_tbl(struct ts_bm *bm)
+static void compute_prefix_tbl(struct ts_bm *bm, int flags)
 {
 	int i, j, g;
 
 	for (i = 0; i < ASIZE; i++)
 		bm->bad_shift[i] = bm->patlen;
-	for (i = 0; i < bm->patlen - 1; i++)
+	for (i = 0; i < bm->patlen - 1; i++) {
 		bm->bad_shift[bm->pattern[i]] = bm->patlen - 1 - i;
+		if (flags & TS_IGNORECASE)
+			bm->bad_shift[tolower(bm->pattern[i])]
+			    = bm->patlen - 1 - i;
+	}
 
 	/* Compute the good shift array, used to match reocurrences 
 	 * of a subpattern */
@@ -135,10 +143,11 @@ static void compute_prefix_tbl(struct ts_bm *bm)
 }
 
 static struct ts_config *bm_init(const void *pattern, unsigned int len,
-				 gfp_t gfp_mask)
+				 gfp_t gfp_mask, int flags)
 {
 	struct ts_config *conf;
 	struct ts_bm *bm;
+	int i;
 	unsigned int prefix_tbl_len = len * sizeof(unsigned int);
 	size_t priv_size = sizeof(*bm) + len + prefix_tbl_len;
 
@@ -146,11 +155,16 @@ static struct ts_config *bm_init(const void *pattern, unsigned int len,
 	if (IS_ERR(conf))
 		return conf;
 
+	conf->flags = flags;
 	bm = ts_config_priv(conf);
 	bm->patlen = len;
 	bm->pattern = (u8 *) bm->good_shift + prefix_tbl_len;
-	memcpy(bm->pattern, pattern, len);
-	compute_prefix_tbl(bm);
+	if (flags & TS_IGNORECASE)
+		for (i = 0; i < len; i++)
+			bm->pattern[i] = toupper(((u8 *)pattern)[i]);
+	else
+		memcpy(bm->pattern, pattern, len);
+	compute_prefix_tbl(bm, flags);
 
 	return conf;
 }
-- 
1.5.4.3

