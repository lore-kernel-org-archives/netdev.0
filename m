From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/29] netfilter: conntrack: don't call iter for non-confirmed conntracks
Date: Fri, 30 Jun 2017 00:53:04 +0200
Message-ID: <1498776807-11124-7-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57602 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752356AbdF2Wxx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:53 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B2B4ABDF49
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A22CDD1CA7
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 36774D1CA3
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:28 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

nf_ct_iterate_cleanup_net currently calls iter() callback also for
conntracks on the unconfirmed list, but this is unsafe.

Acesses to nf_conn are fine, but some users access the extension area
in the iter() callback, but that does only work reliably for confirmed
conntracks (ct->ext can be reallocated at any time for unconfirmed
conntrack).

The seond issue is that there is a short window where a conntrack entry
is neither on the list nor in the table: To confirm an entry, it is first
removed from the unconfirmed list, then insert into the table.

Fix this by iterating the unconfirmed list first and marking all entries
as dying, then wait for rcu grace period.

This makes sure all entries that were about to be confirmed either are
in the main table, or will be dropped soon.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 2730f9df33b7..08733685d732 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1592,7 +1592,6 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	struct hlist_nulls_node *n;
-	int cpu;
 	spinlock_t *lockp;
 
 	for (; *bucket < nf_conntrack_htable_size; (*bucket)++) {
@@ -1614,24 +1613,40 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 		cond_resched();
 	}
 
+	return NULL;
+found:
+	atomic_inc(&ct->ct_general.use);
+	spin_unlock(lockp);
+	local_bh_enable();
+	return ct;
+}
+
+static void
+__nf_ct_unconfirmed_destroy(struct net *net)
+{
+	int cpu;
+
 	for_each_possible_cpu(cpu) {
-		struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
+		struct nf_conntrack_tuple_hash *h;
+		struct hlist_nulls_node *n;
+		struct ct_pcpu *pcpu;
+
+		pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
 
 		spin_lock_bh(&pcpu->lock);
 		hlist_nulls_for_each_entry(h, n, &pcpu->unconfirmed, hnnode) {
+			struct nf_conn *ct;
+
 			ct = nf_ct_tuplehash_to_ctrack(h);
-			if (iter(ct, data))
-				set_bit(IPS_DYING_BIT, &ct->status);
+
+			/* we cannot call iter() on unconfirmed list, the
+			 * owning cpu can reallocate ct->ext at any time.
+			 */
+			set_bit(IPS_DYING_BIT, &ct->status);
 		}
 		spin_unlock_bh(&pcpu->lock);
 		cond_resched();
 	}
-	return NULL;
-found:
-	atomic_inc(&ct->ct_general.use);
-	spin_unlock(lockp);
-	local_bh_enable();
-	return ct;
 }
 
 void nf_ct_iterate_cleanup_net(struct net *net,
@@ -1646,6 +1661,10 @@ void nf_ct_iterate_cleanup_net(struct net *net,
 	if (atomic_read(&net->ct.count) == 0)
 		return;
 
+	__nf_ct_unconfirmed_destroy(net);
+
+	synchronize_net();
+
 	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
 		/* Time to push up daises... */
 
-- 
2.1.4
