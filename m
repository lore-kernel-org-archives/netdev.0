From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [FIB]: Avoid using static variables without proper locking
Date: Mon, 14 Jan 2008 20:27:11 +0100
Message-ID: <478BB78F.8060609@cosmosbay.com>
References: <20080112064513.803976049@linux-foundation.org>	<20080112064646.659443238@linux-foundation.org>	<4788A17D.5070903@cosmosbay.com>	<20080112130824.54cc1fc3@deepthought>	<18315.16984.456053.250600@robur.slu.se>	<478B9D0B.5040301@cosmosbay.com> <18315.41725.417992.715140@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020303030908000203050701"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.139]:21465 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485AbYANT1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 14:27:16 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2a06.orange.fr (SMTP Server) with ESMTP id 382AF700008A
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 20:27:15 +0100 (CET)
In-Reply-To: <18315.41725.417992.715140@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020303030908000203050701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

fib_trie_seq_show() uses two helper functions, rtn_scope() and 
rtn_type() that can
write to static storage without locking.

Just pass to them a temporary buffer to avoid potential  corruption
(probably not triggerable but still...)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------020303030908000203050701
Content-Type: text/plain;
 name="fib_trie.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_trie.patch"

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 8d8c291..15a555a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2276,10 +2276,8 @@ static void seq_indent(struct seq_file *seq, int n)
 	while (n-- > 0) seq_puts(seq, "   ");
 }
 
-static inline const char *rtn_scope(enum rt_scope_t s)
+static inline const char *rtn_scope(char *buf, size_t len, enum rt_scope_t s)
 {
-	static char buf[32];
-
 	switch (s) {
 	case RT_SCOPE_UNIVERSE: return "universe";
 	case RT_SCOPE_SITE:	return "site";
@@ -2287,7 +2285,7 @@ static inline const char *rtn_scope(enum rt_scope_t s)
 	case RT_SCOPE_HOST:	return "host";
 	case RT_SCOPE_NOWHERE:	return "nowhere";
 	default:
-		snprintf(buf, sizeof(buf), "scope=%d", s);
+		snprintf(buf, len, "scope=%d", s);
 		return buf;
 	}
 }
@@ -2307,13 +2305,11 @@ static const char *rtn_type_names[__RTN_MAX] = {
 	[RTN_XRESOLVE] = "XRESOLVE",
 };
 
-static inline const char *rtn_type(unsigned t)
+static inline const char *rtn_type(char *buf, size_t len, unsigned t)
 {
-	static char buf[32];
-
 	if (t < __RTN_MAX && rtn_type_names[t])
 		return rtn_type_names[t];
-	snprintf(buf, sizeof(buf), "type %d", t);
+	snprintf(buf, len, "type %d", t);
 	return buf;
 }
 
@@ -2351,13 +2347,19 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "  |-- %d.%d.%d.%d\n", NIPQUAD(val));
 		for (i = 32; i >= 0; i--) {
 			struct leaf_info *li = find_leaf_info(l, i);
+
 			if (li) {
 				struct fib_alias *fa;
+
 				list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+					char buf1[32], buf2[32];
+
 					seq_indent(seq, iter->depth+1);
 					seq_printf(seq, "  /%d %s %s", i,
-						   rtn_scope(fa->fa_scope),
-						   rtn_type(fa->fa_type));
+						   rtn_scope(buf1, sizeof(buf1),
+							     fa->fa_scope),
+						   rtn_type(buf2, sizeof(buf2),
+							     fa->fa_type));
 					if (fa->fa_tos)
 						seq_printf(seq, "tos =%d\n",
 							   fa->fa_tos);

--------------020303030908000203050701--


