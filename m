From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 4/9] fib_trie: use hash list
Date: Tue, 22 Jan 2008 15:37:37 -0800
Message-ID: <20080122233926.916980551@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33109 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757415AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Content-Disposition: inline; filename=fib-use-the-list.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code to dump can use the existing hash chain rather
than doing repeated lookup.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-21 17:45:03.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-21 17:45:08.000000000 -0800
@@ -2396,31 +2396,30 @@ static int fib_trie_seq_show(struct seq_
 
 	} else {
 		struct leaf *l = (struct leaf *) n;
-		int i;
+		struct leaf_info *li;
+		struct hlist_node *node;
+
 		__be32 val = htonl(l->key);
 
 		seq_indent(seq, iter->depth);
 		seq_printf(seq, "  |-- %d.%d.%d.%d\n", NIPQUAD(val));
-		for (i = 32; i >= 0; i--) {
-			struct leaf_info *li = find_leaf_info(l, i);
 
-			if (li) {
-				struct fib_alias *fa;
+		hlist_for_each_entry_rcu(li, node, &l->list, hlist) {
+			struct fib_alias *fa;
 
-				list_for_each_entry_rcu(fa, &li->falh, fa_list) {
-					char buf1[32], buf2[32];
+			list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+				char buf1[32], buf2[32];
 
-					seq_indent(seq, iter->depth+1);
-					seq_printf(seq, "  /%d %s %s", i,
-						   rtn_scope(buf1, sizeof(buf1),
-							     fa->fa_scope),
-						   rtn_type(buf2, sizeof(buf2),
-							     fa->fa_type));
-					if (fa->fa_tos)
-						seq_printf(seq, "tos =%d\n",
-							   fa->fa_tos);
-					seq_putc(seq, '\n');
-				}
+				seq_indent(seq, iter->depth+1);
+				seq_printf(seq, "  /%d %s %s", li->plen,
+					   rtn_scope(buf1, sizeof(buf1),
+						     fa->fa_scope),
+					   rtn_type(buf2, sizeof(buf2),
+						    fa->fa_type));
+				if (fa->fa_tos)
+					seq_printf(seq, "tos =%d\n",
+						   fa->fa_tos);
+				seq_putc(seq, '\n');
 			}
 		}
 	}
@@ -2474,8 +2473,8 @@ static int fib_route_seq_show(struct seq
 {
 	const struct fib_trie_iter *iter = seq->private;
 	struct leaf *l = v;
-	int i;
-	char bf[128];
+	struct leaf_info *li;
+	struct hlist_node *node;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "%-127s\n", "Iface\tDestination\tGateway "
@@ -2490,8 +2489,7 @@ static int fib_route_seq_show(struct seq
 	if (IS_TNODE(l))
 		return 0;
 
-	for (i = 32; i >= 0; i--) {
-		struct leaf_info *li = find_leaf_info(l, i);
+	hlist_for_each_entry_rcu(li, node, &l->list, hlist) {
 		struct fib_alias *fa;
 		__be32 mask, prefix;
 
@@ -2504,6 +2502,7 @@ static int fib_route_seq_show(struct seq
 		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			const struct fib_info *fi = fa->fa_info;
 			unsigned flags = fib_flag_trans(fa->fa_type, mask, fi);
+			char bf[128];
 
 			if (fa->fa_type == RTN_BROADCAST
 			    || fa->fa_type == RTN_MULTICAST)

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

