From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/29] netfilter: nf_ct_helper: use nf_ct_iterate_destroy to unlink helper objs
Date: Fri, 30 Jun 2017 00:53:17 +0200
Message-ID: <1498776807-11124-20-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57590 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752392AbdF2Wx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:57 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 78B3BBDF5B
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6695EDA241
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 45D5FD1CA9
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:38 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

When we unlink the helper objects, we will iterate the nf_conntrack_hash,
iterate the unconfirmed list, handle the hash resize situation, etc.

Actually this logic is same as the nf_ct_iterate_destroy, so we can use
it to remove these copy & paste code.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c | 50 +++----------------------------------
 1 file changed, 4 insertions(+), 46 deletions(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 7f6100ca63be..9129bb3b5153 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -285,16 +285,16 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 EXPORT_SYMBOL_GPL(__nf_ct_try_assign_helper);
 
 /* appropriate ct lock protecting must be taken by caller */
-static inline int unhelp(struct nf_conntrack_tuple_hash *i,
-			 const struct nf_conntrack_helper *me)
+static int unhelp(struct nf_conn *ct, void *me)
 {
-	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(i);
 	struct nf_conn_help *help = nfct_help(ct);
 
 	if (help && rcu_dereference_raw(help->helper) == me) {
 		nf_conntrack_event(IPCT_HELPER, ct);
 		RCU_INIT_POINTER(help->helper, NULL);
 	}
+
+	/* We are not intended to delete this conntrack. */
 	return 0;
 }
 
@@ -437,33 +437,10 @@ int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_register);
 
-static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
-					     struct net *net)
-{
-	struct nf_conntrack_tuple_hash *h;
-	const struct hlist_nulls_node *nn;
-	int cpu;
-
-	/* Get rid of expecteds, set helpers to NULL. */
-	for_each_possible_cpu(cpu) {
-		struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
-
-		spin_lock_bh(&pcpu->lock);
-		hlist_nulls_for_each_entry(h, nn, &pcpu->unconfirmed, hnnode)
-			unhelp(h, me);
-		spin_unlock_bh(&pcpu->lock);
-	}
-}
-
 void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 {
-	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_expect *exp;
 	const struct hlist_node *next;
-	const struct hlist_nulls_node *nn;
-	unsigned int last_hsize;
-	spinlock_t *lock;
-	struct net *net;
 	unsigned int i;
 
 	mutex_lock(&nf_ct_helper_mutex);
@@ -491,26 +468,7 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	}
 	spin_unlock_bh(&nf_conntrack_expect_lock);
 
-	rtnl_lock();
-	for_each_net(net)
-		__nf_conntrack_helper_unregister(me, net);
-	rtnl_unlock();
-
-	local_bh_disable();
-restart:
-	last_hsize = nf_conntrack_htable_size;
-	for (i = 0; i < last_hsize; i++) {
-		lock = &nf_conntrack_locks[i % CONNTRACK_LOCKS];
-		nf_conntrack_lock(lock);
-		if (last_hsize != nf_conntrack_htable_size) {
-			spin_unlock(lock);
-			goto restart;
-		}
-		hlist_nulls_for_each_entry(h, nn, &nf_conntrack_hash[i], hnnode)
-			unhelp(h, me);
-		spin_unlock(lock);
-	}
-	local_bh_enable();
+	nf_ct_iterate_destroy(unhelp, me);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
 
-- 
2.1.4
