From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 9/9] netfilter: conntrack: consider ct netns in early_drop logic
Date: Thu, 28 Apr 2016 19:13:48 +0200
Message-ID: <1461863628-23350-10-git-send-email-fw@strlen.de>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461863628-23350-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When iterating, skip conntrack entries living in a different netns.

We could ignore netns and kill some other non-assured one, but it
has two problems:

- a netns can kill non-assured conntracks in other namespace
- we would start to 'over-subscribe' the affected/overlimit netns.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/nf_conntrack_core.c | 43 +++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index d58b597..418e4bc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -763,18 +763,20 @@ static noinline int early_drop(struct net *net, unsigned int _hash)
 {
 	/* Use oldest entry, which is roughly LRU */
 	struct nf_conntrack_tuple_hash *h;
-	struct nf_conn *ct = NULL, *tmp;
+	struct nf_conn *tmp;
 	struct hlist_nulls_node *n;
-	unsigned int i = 0, cnt = 0;
-	int dropped = 0;
-	unsigned int hash, sequence;
+	unsigned int i, hash, sequence;
+	struct nf_conn *ct = NULL;
 	spinlock_t *lockp;
+	bool ret = false;
+
+	i = 0;
 
 	local_bh_disable();
 restart:
 	sequence = read_seqcount_begin(&nf_conntrack_generation);
-	hash = scale_hash(_hash);
-	for (; i < nf_conntrack_htable_size; i++) {
+	for (; i < NF_CT_EVICTION_RANGE; i++) {
+		hash = scale_hash(_hash++);
 		lockp = &nf_conntrack_locks[hash % CONNTRACK_LOCKS];
 		nf_conntrack_lock(lockp);
 		if (read_seqcount_retry(&nf_conntrack_generation, sequence)) {
@@ -784,35 +786,40 @@ restart:
 		hlist_nulls_for_each_entry_rcu(h, n, &nf_conntrack_hash[hash],
 					       hnnode) {
 			tmp = nf_ct_tuplehash_to_ctrack(h);
-			if (!test_bit(IPS_ASSURED_BIT, &tmp->status) &&
-			    !nf_ct_is_dying(tmp) &&
-			    atomic_inc_not_zero(&tmp->ct_general.use)) {
+
+			if (test_bit(IPS_ASSURED_BIT, &tmp->status) ||
+			    !net_eq(nf_ct_net(tmp), net) ||
+			    nf_ct_is_dying(tmp))
+				continue;
+
+			if (atomic_inc_not_zero(&tmp->ct_general.use)) {
 				ct = tmp;
 				break;
 			}
-			cnt++;
 		}
 
-		hash = (hash + 1) % nf_conntrack_htable_size;
 		spin_unlock(lockp);
-
-		if (ct || cnt >= NF_CT_EVICTION_RANGE)
+		if (ct)
 			break;
-
 	}
+
 	local_bh_enable();
 
 	if (!ct)
-		return dropped;
+		return false;
 
-	if (del_timer(&ct->timeout)) {
+	/* kill only if in same netns -- might have moved due to
+	 * SLAB_DESTROY_BY_RCU rules
+	 */
+	if (net_eq(nf_ct_net(ct), net) && del_timer(&ct->timeout)) {
 		if (nf_ct_delete(ct, 0, 0)) {
-			dropped = 1;
 			NF_CT_STAT_INC_ATOMIC(net, early_drop);
+			ret = true;
 		}
 	}
+
 	nf_ct_put(ct);
-	return dropped;
+	return ret;
 }
 
 static struct nf_conn *
-- 
2.7.3

