From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 02/29] fib_trie: Replace plen with slen in leaf_info
Date: Tue, 24 Feb 2015 12:48:09 -0800
Message-ID: <20150224204809.26106.53795.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbbBXUsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:48:11 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmARg009907
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:10 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKm90V030161
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:10 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replaces the prefix length variable in the leaf_info structure with a
suffix length value, or host identifier length in bits.  By doing this it
makes it easier to sort out since the tnodes and leaf are carrying this
value as well since it is compatible with the ->pos field in tnodes.

I also cleaned up one spot that had some list manipulation that could be
simplified.  I basically updated it so that we just use hlist_add_head_rcu
instead of calling hlist_add_before_rcu on the first node in the list.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   63 ++++++++++++++++++++++++---------------------------
 1 file changed, 30 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e0d44b7..e04f102 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -114,8 +114,7 @@ struct tnode {
 
 struct leaf_info {
 	struct hlist_node hlist;
-	int plen;
-	u32 mask_plen; /* ntohl(inet_make_mask(plen)) */
+	unsigned char slen;
 	struct hlist_head falh;
 	struct rcu_head rcu;
 };
@@ -337,8 +336,7 @@ static struct leaf_info *leaf_info_new(int plen)
 {
 	struct leaf_info *li = kmalloc(sizeof(struct leaf_info),  GFP_KERNEL);
 	if (li) {
-		li->plen = plen;
-		li->mask_plen = ntohl(inet_make_mask(plen));
+		li->slen = KEYLENGTH - plen;
 		INIT_HLIST_HEAD(&li->falh);
 	}
 	return li;
@@ -873,9 +871,10 @@ static struct leaf_info *find_leaf_info(struct tnode *l, int plen)
 {
 	struct hlist_head *head = &l->list;
 	struct leaf_info *li;
+	int slen = KEYLENGTH - plen;
 
 	hlist_for_each_entry_rcu(li, head, hlist)
-		if (li->plen == plen)
+		if (li->slen == slen)
 			return li;
 
 	return NULL;
@@ -929,33 +928,29 @@ static void remove_leaf_info(struct tnode *l, struct leaf_info *old)
 		return;
 
 	/* update the trie with the latest suffix length */
-	l->slen = KEYLENGTH - li->plen;
+	l->slen = li->slen;
 	leaf_pull_suffix(l);
 }
 
 static void insert_leaf_info(struct tnode *l, struct leaf_info *new)
 {
 	struct hlist_head *head = &l->list;
-	struct leaf_info *li = NULL, *last = NULL;
-
-	if (hlist_empty(head)) {
-		hlist_add_head_rcu(&new->hlist, head);
-	} else {
-		hlist_for_each_entry(li, head, hlist) {
-			if (new->plen > li->plen)
-				break;
+	struct leaf_info *li, *last = NULL;
 
-			last = li;
-		}
-		if (last)
-			hlist_add_behind_rcu(&new->hlist, &last->hlist);
-		else
-			hlist_add_before_rcu(&new->hlist, &li->hlist);
+	hlist_for_each_entry(li, head, hlist) {
+		if (new->slen < li->slen)
+			break;
+		last = li;
 	}
 
+	if (last)
+		hlist_add_behind_rcu(&new->hlist, &last->hlist);
+	else
+		hlist_add_head_rcu(&new->hlist, head);
+
 	/* if we added to the tail node then we need to update slen */
-	if (l->slen < (KEYLENGTH - new->plen)) {
-		l->slen = KEYLENGTH - new->plen;
+	if (l->slen < new->slen) {
+		l->slen = new->slen;
 		leaf_push_suffix(l);
 	}
 }
@@ -1139,7 +1134,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	int err;
 	struct tnode *l;
 
-	if (plen > 32)
+	if (plen > KEYLENGTH)
 		return -EINVAL;
 
 	key = ntohl(cfg->fc_dst);
@@ -1425,7 +1420,8 @@ found:
 	hlist_for_each_entry_rcu(li, &n->list, hlist) {
 		struct fib_alias *fa;
 
-		if ((key ^ n->key) & li->mask_plen)
+		if (((key ^ n->key) >> li->slen) &&
+		    (li->slen != KEYLENGTH))
 			continue;
 
 		hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
@@ -1459,7 +1455,7 @@ found:
 				if (!(fib_flags & FIB_LOOKUP_NOREF))
 					atomic_inc(&fi->fib_clntref);
 
-				res->prefixlen = li->plen;
+				res->prefixlen = KEYLENGTH - li->slen;
 				res->nh_sel = nhsel;
 				res->type = fa->fa_type;
 				res->scope = fi->fib_scope;
@@ -1614,7 +1610,7 @@ static int trie_flush_leaf(struct tnode *l)
 	int found = 0;
 	struct hlist_node *tmp;
 	struct leaf_info *li;
-	unsigned char plen = KEYLENGTH;
+	unsigned char slen = 0;
 
 	hlist_for_each_entry_safe(li, tmp, &l->list, hlist) {
 		found += trie_flush_list(&li->falh);
@@ -1625,10 +1621,10 @@ static int trie_flush_leaf(struct tnode *l)
 			continue;
 		}
 
-		plen = li->plen;
+		slen = li->slen;
 	}
 
-	l->slen = KEYLENGTH - plen;
+	l->slen = slen;
 
 	return found;
 }
@@ -1739,7 +1735,7 @@ void fib_free_table(struct fib_table *tb)
 	kfree(tb);
 }
 
-static int fn_trie_dump_fa(t_key key, int plen, struct hlist_head *fah,
+static int fn_trie_dump_fa(t_key key, int slen, struct hlist_head *fah,
 			   struct fib_table *tb,
 			   struct sk_buff *skb, struct netlink_callback *cb)
 {
@@ -1764,7 +1760,7 @@ static int fn_trie_dump_fa(t_key key, int plen, struct hlist_head *fah,
 				  tb->tb_id,
 				  fa->fa_type,
 				  xkey,
-				  plen,
+				  KEYLENGTH - slen,
 				  fa->fa_tos,
 				  fa->fa_info, NLM_F_MULTI) < 0) {
 			cb->args[5] = i;
@@ -1798,7 +1794,7 @@ static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
 		if (hlist_empty(&li->falh))
 			continue;
 
-		if (fn_trie_dump_fa(l->key, li->plen, &li->falh, tb, skb, cb) < 0) {
+		if (fn_trie_dump_fa(l->key, li->slen, &li->falh, tb, skb, cb) < 0) {
 			cb->args[4] = i;
 			return -1;
 		}
@@ -2284,7 +2280,8 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 				char buf1[32], buf2[32];
 
 				seq_indent(seq, iter->depth+1);
-				seq_printf(seq, "  /%d %s %s", li->plen,
+				seq_printf(seq, "  /%zu %s %s",
+					   KEYLENGTH - li->slen,
 					   rtn_scope(buf1, sizeof(buf1),
 						     fa->fa_info->fib_scope),
 					   rtn_type(buf2, sizeof(buf2),
@@ -2434,7 +2431,7 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 		struct fib_alias *fa;
 		__be32 mask, prefix;
 
-		mask = inet_make_mask(li->plen);
+		mask = inet_make_mask(KEYLENGTH - li->slen);
 		prefix = htonl(l->key);
 
 		hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
