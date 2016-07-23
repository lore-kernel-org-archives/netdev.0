From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/25] netfilter: move nat hlist_head to nf_conn
Date: Sat, 23 Jul 2016 13:08:20 +0200
Message-ID: <1469272119-29942-7-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35896 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360AbcGWLJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:18 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 860BCE7DAE
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 765AA6DB36
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4CF686DB36
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:14 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The nat extension structure is 32bytes in size on x86_64:

struct nf_conn_nat {
        struct hlist_node          bysource;             /*     0    16 */
        struct nf_conn *           ct;                   /*    16     8 */
        union nf_conntrack_nat_help help;                /*    24     4 */
        int                        masq_index;           /*    28     4 */
        /* size: 32, cachelines: 1, members: 4 */
        /* last cacheline: 32 bytes */
};

The hlist is needed to quickly check for possible tuple collisions
when installing a new nat binding. Storing this in the extension
area has two drawbacks:

1. We need ct backpointer to get the conntrack struct from the extension.
2. When reallocation of extension area occurs we need to fixup the bysource
   hash head via hlist_replace_rcu.

We can avoid both by placing the hlist_head in nf_conn and place nf_conn in
the bysource hash rather than the extenstion.

We can also remove the ->move support; no other extension needs it.

Moving the entire nat extension into nf_conn would be possible as well but
then we have to add yet another callback for deletion from the bysource
hash table rather than just using nat extension ->destroy hook for this.

nf_conn size doesn't increase due to aligment, followup patch replaces
hlist_node with single pointer.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h        |  3 +++
 include/net/netfilter/nf_conntrack_extend.h |  3 ---
 include/net/netfilter/nf_nat.h              |  2 --
 net/netfilter/nf_conntrack_extend.c         | 15 ++-----------
 net/netfilter/nf_nat_core.c                 | 33 ++++++-----------------------
 5 files changed, 12 insertions(+), 44 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 2a5133e..e5135d8 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -117,6 +117,9 @@ struct nf_conn {
 	/* Extensions */
 	struct nf_ct_ext *ext;
 
+#if IS_ENABLED(CONFIG_NF_NAT)
+	struct hlist_node	nat_bysource;
+#endif
 	/* Storage reserved for other modules, must be the last member */
 	union nf_conntrack_proto proto;
 };
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index b925395..1c3035d 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -99,9 +99,6 @@ void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
 struct nf_ct_ext_type {
 	/* Destroys relationships (can be NULL). */
 	void (*destroy)(struct nf_conn *ct);
-	/* Called when realloacted (can be NULL).
-	   Contents has already been moved. */
-	void (*move)(void *new, void *old);
 
 	enum nf_ct_ext_id id;
 
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index 344b1ab..02515f7 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -29,8 +29,6 @@ struct nf_conn;
 
 /* The structure embedded in the conntrack structure. */
 struct nf_conn_nat {
-	struct hlist_node bysource;
-	struct nf_conn *ct;
 	union nf_conntrack_nat_help help;
 #if IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV4) || \
     IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV6)
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 1a95459..02bcf00 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -73,7 +73,7 @@ void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
 			     size_t var_alloc_len, gfp_t gfp)
 {
 	struct nf_ct_ext *old, *new;
-	int i, newlen, newoff;
+	int newlen, newoff;
 	struct nf_ct_ext_type *t;
 
 	/* Conntrack must not be confirmed to avoid races on reallocation. */
@@ -99,19 +99,8 @@ void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
 		return NULL;
 
 	if (new != old) {
-		for (i = 0; i < NF_CT_EXT_NUM; i++) {
-			if (!__nf_ct_ext_exist(old, i))
-				continue;
-
-			rcu_read_lock();
-			t = rcu_dereference(nf_ct_ext_types[i]);
-			if (t && t->move)
-				t->move((void *)new + new->offset[i],
-					(void *)old + old->offset[i]);
-			rcu_read_unlock();
-		}
 		kfree_rcu(old, rcu);
-		ct->ext = new;
+		rcu_assign_pointer(ct->ext, new);
 	}
 
 	new->offset[id] = newoff;
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 6877a39..6925347 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -198,11 +198,9 @@ find_appropriate_src(struct net *net,
 		     const struct nf_nat_range *range)
 {
 	unsigned int h = hash_by_src(net, tuple);
-	const struct nf_conn_nat *nat;
 	const struct nf_conn *ct;
 
-	hlist_for_each_entry_rcu(nat, &nf_nat_bysource[h], bysource) {
-		ct = nat->ct;
+	hlist_for_each_entry_rcu(ct, &nf_nat_bysource[h], nat_bysource) {
 		if (same_src(ct, tuple) &&
 		    net_eq(net, nf_ct_net(ct)) &&
 		    nf_ct_zone_equal(ct, zone, IP_CT_DIR_ORIGINAL)) {
@@ -435,8 +433,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 		spin_lock_bh(&nf_nat_lock);
 		/* nf_conntrack_alter_reply might re-allocate extension aera */
 		nat = nfct_nat(ct);
-		nat->ct = ct;
-		hlist_add_head_rcu(&nat->bysource,
+		hlist_add_head_rcu(&ct->nat_bysource,
 				   &nf_nat_bysource[srchash]);
 		spin_unlock_bh(&nf_nat_lock);
 	}
@@ -543,7 +540,7 @@ static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 	if (nf_nat_proto_remove(ct, data))
 		return 1;
 
-	if (!nat || !nat->ct)
+	if (!nat)
 		return 0;
 
 	/* This netns is being destroyed, and conntrack has nat null binding.
@@ -556,9 +553,8 @@ static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 		return 1;
 
 	spin_lock_bh(&nf_nat_lock);
-	hlist_del_rcu(&nat->bysource);
+	hlist_del_rcu(&ct->nat_bysource);
 	ct->status &= ~IPS_NAT_DONE_MASK;
-	nat->ct = NULL;
 	spin_unlock_bh(&nf_nat_lock);
 
 	add_timer(&ct->timeout);
@@ -688,27 +684,13 @@ static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 {
 	struct nf_conn_nat *nat = nf_ct_ext_find(ct, NF_CT_EXT_NAT);
 
-	if (nat == NULL || nat->ct == NULL)
+	if (!nat)
 		return;
 
-	NF_CT_ASSERT(nat->ct->status & IPS_SRC_NAT_DONE);
-
-	spin_lock_bh(&nf_nat_lock);
-	hlist_del_rcu(&nat->bysource);
-	spin_unlock_bh(&nf_nat_lock);
-}
-
-static void nf_nat_move_storage(void *new, void *old)
-{
-	struct nf_conn_nat *new_nat = new;
-	struct nf_conn_nat *old_nat = old;
-	struct nf_conn *ct = old_nat->ct;
-
-	if (!ct || !(ct->status & IPS_SRC_NAT_DONE))
-		return;
+	NF_CT_ASSERT(ct->status & IPS_SRC_NAT_DONE);
 
 	spin_lock_bh(&nf_nat_lock);
-	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
+	hlist_del_rcu(&ct->nat_bysource);
 	spin_unlock_bh(&nf_nat_lock);
 }
 
@@ -716,7 +698,6 @@ static struct nf_ct_ext_type nat_extend __read_mostly = {
 	.len		= sizeof(struct nf_conn_nat),
 	.align		= __alignof__(struct nf_conn_nat),
 	.destroy	= nf_nat_cleanup_conntrack,
-	.move		= nf_nat_move_storage,
 	.id		= NF_CT_EXT_NAT,
 	.flags		= NF_CT_EXT_F_PREALLOC,
 };
-- 
2.1.4
