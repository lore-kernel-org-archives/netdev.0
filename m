From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/38] netfilter: trivial code cleanup and doc changes
Date: Mon, 17 Mar 2014 13:42:40 +0100
Message-ID: <1395060178-11833-21-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59432 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933136AbaCQMnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:37 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Changes while reading through the netfilter code.

Added hint about how conntrack nf_conn refcnt is accessed.
And renamed repl_hash to reply_hash for readability

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Reviewed-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |    8 +++++++-
 net/netfilter/nf_conntrack_core.c    |   20 ++++++++++----------
 net/netfilter/nf_conntrack_expect.c  |    2 +-
 3 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index b2ac624..e10d1fa 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -73,7 +73,13 @@ struct nf_conn_help {
 
 struct nf_conn {
 	/* Usage count in here is 1 for hash table/destruct timer, 1 per skb,
-           plus 1 for any connection(s) we are `master' for */
+	 * plus 1 for any connection(s) we are `master' for
+	 *
+	 * Hint, SKB address this struct and refcnt via skb->nfct and
+	 * helpers nf_conntrack_get() and nf_conntrack_put().
+	 * Helper nf_ct_put() equals nf_conntrack_put() by dec refcnt,
+	 * beware nf_ct_get() is different and don't inc refcnt.
+	 */
 	struct nf_conntrack ct_general;
 
 	spinlock_t lock;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 356bef5..965693e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -408,21 +408,21 @@ EXPORT_SYMBOL_GPL(nf_conntrack_find_get);
 
 static void __nf_conntrack_hash_insert(struct nf_conn *ct,
 				       unsigned int hash,
-				       unsigned int repl_hash)
+				       unsigned int reply_hash)
 {
 	struct net *net = nf_ct_net(ct);
 
 	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 			   &net->ct.hash[hash]);
 	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode,
-			   &net->ct.hash[repl_hash]);
+			   &net->ct.hash[reply_hash]);
 }
 
 int
 nf_conntrack_hash_check_insert(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
-	unsigned int hash, repl_hash;
+	unsigned int hash, reply_hash;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
 	u16 zone;
@@ -430,7 +430,7 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	zone = nf_ct_zone(ct);
 	hash = hash_conntrack(net, zone,
 			      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	repl_hash = hash_conntrack(net, zone,
+	reply_hash = hash_conntrack(net, zone,
 				   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
 	spin_lock_bh(&nf_conntrack_lock);
@@ -441,7 +441,7 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 				      &h->tuple) &&
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
-	hlist_nulls_for_each_entry(h, n, &net->ct.hash[repl_hash], hnnode)
+	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				      &h->tuple) &&
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
@@ -451,7 +451,7 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	smp_wmb();
 	/* The caller holds a reference to this object */
 	atomic_set(&ct->ct_general.use, 2);
-	__nf_conntrack_hash_insert(ct, hash, repl_hash);
+	__nf_conntrack_hash_insert(ct, hash, reply_hash);
 	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
 
@@ -483,7 +483,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_tmpl_insert);
 int
 __nf_conntrack_confirm(struct sk_buff *skb)
 {
-	unsigned int hash, repl_hash;
+	unsigned int hash, reply_hash;
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
@@ -507,7 +507,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* reuse the hash saved before */
 	hash = *(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev;
 	hash = hash_bucket(hash, net);
-	repl_hash = hash_conntrack(net, zone,
+	reply_hash = hash_conntrack(net, zone,
 				   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
 	/* We're not in hash table, and we refuse to set up related
@@ -540,7 +540,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 				      &h->tuple) &&
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
-	hlist_nulls_for_each_entry(h, n, &net->ct.hash[repl_hash], hnnode)
+	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				      &h->tuple) &&
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
@@ -570,7 +570,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	 * guarantee that no other CPU can find the conntrack before the above
 	 * stores are visible.
 	 */
-	__nf_conntrack_hash_insert(ct, hash, repl_hash);
+	__nf_conntrack_hash_insert(ct, hash, reply_hash);
 	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
 
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4fd1ca9..da2f84f 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -417,7 +417,7 @@ out:
 	return ret;
 }
 
-int nf_ct_expect_related_report(struct nf_conntrack_expect *expect, 
+int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 				u32 portid, int report)
 {
 	int ret;
-- 
1.7.10.4
