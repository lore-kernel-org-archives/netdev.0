From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 03/29] fib_trie: Add slen to fib alias
Date: Tue, 24 Feb 2015 12:48:15 -0800
Message-ID: <20150224204815.26106.63494.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbbBXUsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:48:17 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmHhP008571
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:17 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmFTD014847
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:16 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of an empty spot in the alias to store the suffix length so that
we don't need to pull that information from the leaf_info structure.

This patch also makes a slight change to the user statistics.  Instead of
incrementing semantic_match_miss once per leaf_info miss we now just
increment it once per leaf if a match was not found.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_lookup.h |    1 +
 net/ipv4/fib_trie.c   |   36 +++++++++++++++++-------------------
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 3cd444f..ae2e6ee 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -11,6 +11,7 @@ struct fib_alias {
 	u8			fa_tos;
 	u8			fa_type;
 	u8			fa_state;
+	u8			fa_slen;
 	struct rcu_head		rcu;
 };
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e04f102..1c35261 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1221,6 +1221,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			new_fa->fa_type = cfg->fc_type;
 			state = fa->fa_state;
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
+			new_fa->fa_slen = fa->fa_slen;
 
 			hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
 			alias_free_mem_rcu(fa);
@@ -1256,10 +1257,9 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_tos = tos;
 	new_fa->fa_type = cfg->fc_type;
 	new_fa->fa_state = 0;
-	/*
-	 * Insert new entry to the list.
-	 */
+	new_fa->fa_slen = KEYLENGTH - plen;
 
+	/* Insert new entry to the list. */
 	if (!fa_head) {
 		fa_head = fib_insert_node(t, key, plen);
 		if (unlikely(!fa_head)) {
@@ -1420,14 +1420,13 @@ found:
 	hlist_for_each_entry_rcu(li, &n->list, hlist) {
 		struct fib_alias *fa;
 
-		if (((key ^ n->key) >> li->slen) &&
-		    (li->slen != KEYLENGTH))
-			continue;
-
 		hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			struct fib_info *fi = fa->fa_info;
 			int nhsel, err;
 
+			if (((key ^ n->key) >> fa->fa_slen) &&
+			    (fa->fa_slen != KEYLENGTH))
+				continue;
 			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
 				continue;
 			if (fi->fib_dead)
@@ -1455,7 +1454,7 @@ found:
 				if (!(fib_flags & FIB_LOOKUP_NOREF))
 					atomic_inc(&fi->fib_clntref);
 
-				res->prefixlen = KEYLENGTH - li->slen;
+				res->prefixlen = KEYLENGTH - fa->fa_slen;
 				res->nh_sel = nhsel;
 				res->type = fa->fa_type;
 				res->scope = fi->fib_scope;
@@ -1468,11 +1467,10 @@ found:
 				return err;
 			}
 		}
-
+	}
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-		this_cpu_inc(stats->semantic_match_miss);
+	this_cpu_inc(stats->semantic_match_miss);
 #endif
-	}
 	goto backtrace;
 }
 EXPORT_SYMBOL_GPL(fib_table_lookup);
@@ -1735,7 +1733,7 @@ void fib_free_table(struct fib_table *tb)
 	kfree(tb);
 }
 
-static int fn_trie_dump_fa(t_key key, int slen, struct hlist_head *fah,
+static int fn_trie_dump_fa(t_key key, struct hlist_head *fah,
 			   struct fib_table *tb,
 			   struct sk_buff *skb, struct netlink_callback *cb)
 {
@@ -1760,7 +1758,7 @@ static int fn_trie_dump_fa(t_key key, int slen, struct hlist_head *fah,
 				  tb->tb_id,
 				  fa->fa_type,
 				  xkey,
-				  KEYLENGTH - slen,
+				  KEYLENGTH - fa->fa_slen,
 				  fa->fa_tos,
 				  fa->fa_info, NLM_F_MULTI) < 0) {
 			cb->args[5] = i;
@@ -1794,7 +1792,7 @@ static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
 		if (hlist_empty(&li->falh))
 			continue;
 
-		if (fn_trie_dump_fa(l->key, li->slen, &li->falh, tb, skb, cb) < 0) {
+		if (fn_trie_dump_fa(l->key, &li->falh, tb, skb, cb) < 0) {
 			cb->args[4] = i;
 			return -1;
 		}
@@ -2281,7 +2279,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 
 				seq_indent(seq, iter->depth+1);
 				seq_printf(seq, "  /%zu %s %s",
-					   KEYLENGTH - li->slen,
+					   KEYLENGTH - fa->fa_slen,
 					   rtn_scope(buf1, sizeof(buf1),
 						     fa->fa_info->fib_scope),
 					   rtn_type(buf2, sizeof(buf2),
@@ -2419,6 +2417,7 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 {
 	struct tnode *l = v;
 	struct leaf_info *li;
+	__be32 prefix;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "%-127s\n", "Iface\tDestination\tGateway "
@@ -2427,15 +2426,14 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 		return 0;
 	}
 
+	prefix = htonl(l->key);
+
 	hlist_for_each_entry_rcu(li, &l->list, hlist) {
 		struct fib_alias *fa;
-		__be32 mask, prefix;
-
-		mask = inet_make_mask(KEYLENGTH - li->slen);
-		prefix = htonl(l->key);
 
 		hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			const struct fib_info *fi = fa->fa_info;
+			__be32 mask = inet_make_mask(KEYLENGTH - fa->fa_slen);
 			unsigned int flags = fib_flag_trans(fa->fa_type, mask, fi);
 
 			if (fa->fa_type == RTN_BROADCAST
