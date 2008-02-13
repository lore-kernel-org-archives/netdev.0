From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] fib_trie: improve output format for /proc/net/fib_trie
Date: Wed, 13 Feb 2008 11:58:07 -0800
Message-ID: <20080213195929.855750228@vyatta.com>
References: <20080213195805.493794050@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:60848 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757613AbYBMUC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 15:02:26 -0500
Content-Disposition: inline; filename=fib-trie-format.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make output format prettier (more tree like).

   <local>:
   --- 0.0.0.0/0
     |--- 10.111.111.0/24
     |  +-- 10.111.111.0/32 link broadcast
     |  |--- 10.111.111.254/31
     |  |  +-- 10.111.111.254/32 host local
     |  |  +-- 10.111.111.255/32 link broadcast
     |--- 127.0.0.0/8
     |  |--- 127.0.0.0/31
     |  |  +-- 127.0.0.0/32 link broadcast
     |  |  +-- 127.0.0.0/8 host local
     |  |  +-- 127.0.0.1/32 host local
     |  +-- 127.255.255.255/32 link broadcast
     |--- 192.168.1.0/24
     |  |--- 192.168.1.0/28
     |  |  +-- 192.168.1.0/32 link broadcast
     |  |  +-- 192.168.1.9/32 host local
     |  +-- 192.168.1.255/32 link broadcast
   <main>:
   --- 0.0.0.0/0
     |--- 0.0.0.0/4
     |  +-- 0.0.0.0/0 universe unicast
     |  +-- 10.111.111.0/24 link unicast
     +-- 169.254.0.0/16 link unicast
     +-- 192.168.1.0/24 link unicast
   
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/ipv4/fib_trie.c |  106 ++++++++++++++++++++++++++------------------------
 1 files changed, 55 insertions(+), 51 deletions(-)

--- a/net/ipv4/fib_trie.c	2008-02-13 11:33:43.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-02-13 11:41:23.000000000 -0800
@@ -2334,46 +2334,57 @@ static void fib_trie_seq_stop(struct seq
 	rcu_read_unlock();
 }
 
+/* print left side of tree */
 static void seq_indent(struct seq_file *seq, int n)
 {
-	while (n-- > 0) seq_puts(seq, "   ");
+	while (n-- > 0)
+		seq_puts(seq, "  |");
 }
 
-static inline const char *rtn_scope(char *buf, size_t len, enum rt_scope_t s)
+static const char *rtn_type_names[__RTN_MAX] = {
+	[RTN_UNSPEC]	= "unspec",
+	[RTN_UNICAST]	= "unicast",
+	[RTN_LOCAL]	= "local",
+	[RTN_BROADCAST] = "broadcast",
+	[RTN_ANYCAST]	= "anycast",
+	[RTN_MULTICAST] = "multicast",
+	[RTN_BLACKHOLE] = "blackhole",
+	[RTN_UNREACHABLE] = "unreachable",
+	[RTN_PROHIBIT] 	= "prohibit",
+	[RTN_THROW]	= "throw",
+	[RTN_NAT]	= "nat",
+	[RTN_XRESOLVE]	= "xresolve",
+};
+
+static void fib_trie_show_alias(struct seq_file *seq, const struct fib_alias *fa)
 {
-	switch (s) {
-	case RT_SCOPE_UNIVERSE: return "universe";
-	case RT_SCOPE_SITE:	return "site";
-	case RT_SCOPE_LINK:	return "link";
-	case RT_SCOPE_HOST:	return "host";
-	case RT_SCOPE_NOWHERE:	return "nowhere";
+	switch (fa->fa_scope) {
+	case RT_SCOPE_UNIVERSE:
+		seq_puts(seq, "universe");
+		break;
+	case RT_SCOPE_SITE:
+		seq_puts(seq,  "site");
+		break;
+	case RT_SCOPE_LINK:
+		seq_puts(seq,  "link");
+		break;
+	case RT_SCOPE_HOST:
+		seq_puts(seq,  "host");
+		break;
+	case RT_SCOPE_NOWHERE:
+		seq_puts(seq,  "nowhere");
+		break;
 	default:
-		snprintf(buf, len, "scope=%d", s);
-		return buf;
+		seq_printf(seq, "scope:%d", fa->fa_scope);
 	}
-}
 
-static const char *rtn_type_names[__RTN_MAX] = {
-	[RTN_UNSPEC] = "UNSPEC",
-	[RTN_UNICAST] = "UNICAST",
-	[RTN_LOCAL] = "LOCAL",
-	[RTN_BROADCAST] = "BROADCAST",
-	[RTN_ANYCAST] = "ANYCAST",
-	[RTN_MULTICAST] = "MULTICAST",
-	[RTN_BLACKHOLE] = "BLACKHOLE",
-	[RTN_UNREACHABLE] = "UNREACHABLE",
-	[RTN_PROHIBIT] = "PROHIBIT",
-	[RTN_THROW] = "THROW",
-	[RTN_NAT] = "NAT",
-	[RTN_XRESOLVE] = "XRESOLVE",
-};
+	if (fa->fa_type < __RTN_MAX && rtn_type_names[fa->fa_type])
+		seq_printf(seq, " %s", rtn_type_names[fa->fa_type]);
+	else
+		seq_printf(seq, " type:%u", fa->fa_type);
 
-static inline const char *rtn_type(char *buf, size_t len, unsigned t)
-{
-	if (t < __RTN_MAX && rtn_type_names[t])
-		return rtn_type_names[t];
-	snprintf(buf, len, "type %u", t);
-	return buf;
+	if (fa->fa_tos)
+		seq_printf(seq, " tos:%#x", fa->fa_tos);
 }
 
 /* Pretty print the trie */
@@ -2396,10 +2407,8 @@ static int fib_trie_seq_show(struct seq_
 		struct tnode *tn = (struct tnode *) n;
 		__be32 prf = htonl(mask_pfx(tn->key, tn->pos));
 
-		seq_indent(seq, iter->depth-1);
-		seq_printf(seq, "  +-- %d.%d.%d.%d/%d %d %d %d\n",
-			   NIPQUAD(prf), tn->pos, tn->bits, tn->full_children,
-			   tn->empty_children);
+		seq_indent(seq, iter->depth - 1);
+		seq_printf(seq, "--- %d.%d.%d.%d/%d\n", NIPQUAD(prf), tn->pos);
 
 	} else {
 		struct leaf *l = (struct leaf *) n;
@@ -2407,24 +2416,19 @@ static int fib_trie_seq_show(struct seq_
 		struct hlist_node *node;
 		__be32 val = htonl(l->key);
 
-		seq_indent(seq, iter->depth);
-		seq_printf(seq, "  |-- %d.%d.%d.%d\n", NIPQUAD(val));
-
 		hlist_for_each_entry_rcu(li, node, &l->list, hlist) {
 			struct fib_alias *fa;
 
-			list_for_each_entry_rcu(fa, &li->falh, fa_list) {
-				char buf1[32], buf2[32];
+			seq_indent(seq, iter->depth - 1);
+			seq_printf(seq, "  +-- %d.%d.%d.%d/%d ",
+				   NIPQUAD(val), li->plen);
 
-				seq_indent(seq, iter->depth+1);
-				seq_printf(seq, "  /%d %s %s", li->plen,
-					   rtn_scope(buf1, sizeof(buf1),
-						     fa->fa_scope),
-					   rtn_type(buf2, sizeof(buf2),
-						    fa->fa_type));
-				if (fa->fa_tos)
-					seq_printf(seq, " tos=%d", fa->fa_tos);
-				seq_putc(seq, '\n');
+			list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+				fib_trie_show_alias(seq, fa);
+				if (list_is_last(&fa->fa_list, &li->falh))
+					seq_putc(seq, '\n');
+				else
+					seq_puts(seq, ", ");
 			}
 		}
 	}

-- 
Stephen Hemminger <shemminger@vyatta.com>

