From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/25] netfilter: conntrack: simplify early_drop
Date: Sat, 23 Jul 2016 13:08:19 +0200
Message-ID: <1469272119-29942-6-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35891 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751340AbcGWLJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:16 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 699DBE7DAA
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:15 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5A4C4FAB56
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:15 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0E9AEFAB56
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:13 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We don't need to acquire the bucket lock during early drop, we can
use lockless traveral just like ____nf_conntrack_find.

The timer deletion serves as synchronization point, if another cpu
attempts to evict same entry, only one will succeed with timer deletion.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |  1 +
 net/netfilter/nf_conntrack_core.c    | 95 ++++++++++++++++++------------------
 2 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 5d3397f..2a5133e 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -301,6 +301,7 @@ void nf_ct_tmpl_free(struct nf_conn *tmpl);
 
 #define NF_CT_STAT_INC(net, count)	  __this_cpu_inc((net)->ct.stat->count)
 #define NF_CT_STAT_INC_ATOMIC(net, count) this_cpu_inc((net)->ct.stat->count)
+#define NF_CT_STAT_ADD_ATOMIC(net, count, v) this_cpu_add((net)->ct.stat->count, (v))
 
 #define MODULE_ALIAS_NFCT_HELPER(helper) \
         MODULE_ALIAS("nfct-helper-" helper)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1289e7e..e0e9c9a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -834,67 +834,66 @@ EXPORT_SYMBOL_GPL(nf_conntrack_tuple_taken);
 
 /* There's a small race here where we may free a just-assured
    connection.  Too bad: we're in trouble anyway. */
-static noinline int early_drop(struct net *net, unsigned int _hash)
+static unsigned int early_drop_list(struct net *net,
+				    struct hlist_nulls_head *head)
 {
-	/* Use oldest entry, which is roughly LRU */
 	struct nf_conntrack_tuple_hash *h;
-	struct nf_conn *tmp;
 	struct hlist_nulls_node *n;
-	unsigned int i, hash, sequence;
-	struct nf_conn *ct = NULL;
-	spinlock_t *lockp;
-	bool ret = false;
+	unsigned int drops = 0;
+	struct nf_conn *tmp;
 
-	i = 0;
+	hlist_nulls_for_each_entry_rcu(h, n, head, hnnode) {
+		tmp = nf_ct_tuplehash_to_ctrack(h);
 
-	local_bh_disable();
-restart:
-	sequence = read_seqcount_begin(&nf_conntrack_generation);
-	for (; i < NF_CT_EVICTION_RANGE; i++) {
-		hash = scale_hash(_hash++);
-		lockp = &nf_conntrack_locks[hash % CONNTRACK_LOCKS];
-		nf_conntrack_lock(lockp);
-		if (read_seqcount_retry(&nf_conntrack_generation, sequence)) {
-			spin_unlock(lockp);
-			goto restart;
-		}
-		hlist_nulls_for_each_entry_rcu(h, n, &nf_conntrack_hash[hash],
-					       hnnode) {
-			tmp = nf_ct_tuplehash_to_ctrack(h);
-
-			if (test_bit(IPS_ASSURED_BIT, &tmp->status) ||
-			    !net_eq(nf_ct_net(tmp), net) ||
-			    nf_ct_is_dying(tmp))
-				continue;
-
-			if (atomic_inc_not_zero(&tmp->ct_general.use)) {
-				ct = tmp;
-				break;
-			}
-		}
+		if (test_bit(IPS_ASSURED_BIT, &tmp->status) ||
+		    !net_eq(nf_ct_net(tmp), net) ||
+		    nf_ct_is_dying(tmp))
+			continue;
 
-		spin_unlock(lockp);
-		if (ct)
-			break;
+		if (!atomic_inc_not_zero(&tmp->ct_general.use))
+			continue;
+
+		/* kill only if still in same netns -- might have moved due to
+		 * SLAB_DESTROY_BY_RCU rules.
+		 *
+		 * We steal the timer reference.  If that fails timer has
+		 * already fired or someone else deleted it. Just drop ref
+		 * and move to next entry.
+		 */
+		if (net_eq(nf_ct_net(tmp), net) &&
+		    nf_ct_is_confirmed(tmp) &&
+		    del_timer(&tmp->timeout) &&
+		    nf_ct_delete(tmp, 0, 0))
+			drops++;
+
+		nf_ct_put(tmp);
 	}
 
-	local_bh_enable();
+	return drops;
+}
 
-	if (!ct)
-		return false;
+static noinline int early_drop(struct net *net, unsigned int _hash)
+{
+	unsigned int i;
 
-	/* kill only if in same netns -- might have moved due to
-	 * SLAB_DESTROY_BY_RCU rules
-	 */
-	if (net_eq(nf_ct_net(ct), net) && del_timer(&ct->timeout)) {
-		if (nf_ct_delete(ct, 0, 0)) {
-			NF_CT_STAT_INC_ATOMIC(net, early_drop);
-			ret = true;
+	for (i = 0; i < NF_CT_EVICTION_RANGE; i++) {
+		struct hlist_nulls_head *ct_hash;
+		unsigned hash, sequence, drops;
+
+		do {
+			sequence = read_seqcount_begin(&nf_conntrack_generation);
+			hash = scale_hash(_hash++);
+			ct_hash = nf_conntrack_hash;
+		} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
+
+		drops = early_drop_list(net, &ct_hash[hash]);
+		if (drops) {
+			NF_CT_STAT_ADD_ATOMIC(net, early_drop, drops);
+			return true;
 		}
 	}
 
-	nf_ct_put(ct);
-	return ret;
+	return false;
 }
 
 static struct nf_conn *
-- 
2.1.4
