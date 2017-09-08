From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/9] netfilter: nat: use keyed locks
Date: Fri,  8 Sep 2017 19:45:45 +0200
Message-ID: <1504892748-1605-7-git-send-email-pablo@netfilter.org>
References: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54482 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756725AbdIHRqD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 13:46:03 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 8FBD48D050E
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:32 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7E0EDDA2DA
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:32 +0200 (CEST)
In-Reply-To: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

no need to serialize on a single lock, we can partition the table and
add/delete in parallel to different slots.
This restores one of the advantages that got lost with the rhlist
revert.

Cc: Ivan Babrou <ibobrik@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 36 ++++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index f090419f5f97..f393a7086025 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -30,7 +30,7 @@
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <linux/netfilter/nf_nat.h>
 
-static DEFINE_SPINLOCK(nf_nat_lock);
+static spinlock_t nf_nat_locks[CONNTRACK_LOCKS];
 
 static DEFINE_MUTEX(nf_nat_proto_mutex);
 static const struct nf_nat_l3proto __rcu *nf_nat_l3protos[NFPROTO_NUMPROTO]
@@ -425,13 +425,15 @@ nf_nat_setup_info(struct nf_conn *ct,
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
 		unsigned int srchash;
+		spinlock_t *lock;
 
 		srchash = hash_by_src(net,
 				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-		spin_lock_bh(&nf_nat_lock);
+		lock = &nf_nat_locks[srchash % ARRAY_SIZE(nf_nat_locks)];
+		spin_lock_bh(lock);
 		hlist_add_head_rcu(&ct->nat_bysource,
 				   &nf_nat_bysource[srchash]);
-		spin_unlock_bh(&nf_nat_lock);
+		spin_unlock_bh(lock);
 	}
 
 	/* It's done. */
@@ -525,6 +527,16 @@ static int nf_nat_proto_remove(struct nf_conn *i, void *data)
 	return i->status & IPS_NAT_MASK ? 1 : 0;
 }
 
+static void __nf_nat_cleanup_conntrack(struct nf_conn *ct)
+{
+	unsigned int h;
+
+	h = hash_by_src(nf_ct_net(ct), &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+	spin_lock_bh(&nf_nat_locks[h % ARRAY_SIZE(nf_nat_locks)]);
+	hlist_del_rcu(&ct->nat_bysource);
+	spin_unlock_bh(&nf_nat_locks[h % ARRAY_SIZE(nf_nat_locks)]);
+}
+
 static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 {
 	if (nf_nat_proto_remove(ct, data))
@@ -540,9 +552,7 @@ static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 	 * will delete entry from already-freed table.
 	 */
 	clear_bit(IPS_SRC_NAT_DONE_BIT, &ct->status);
-	spin_lock_bh(&nf_nat_lock);
-	hlist_del_rcu(&ct->nat_bysource);
-	spin_unlock_bh(&nf_nat_lock);
+	__nf_nat_cleanup_conntrack(ct);
 
 	/* don't delete conntrack.  Although that would make things a lot
 	 * simpler, we'd end up flushing all conntracks on nat rmmod.
@@ -670,11 +680,8 @@ EXPORT_SYMBOL_GPL(nf_nat_l3proto_unregister);
 /* No one using conntrack by the time this called. */
 static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 {
-	if (ct->status & IPS_SRC_NAT_DONE) {
-		spin_lock_bh(&nf_nat_lock);
-		hlist_del_rcu(&ct->nat_bysource);
-		spin_unlock_bh(&nf_nat_lock);
-	}
+	if (ct->status & IPS_SRC_NAT_DONE)
+		__nf_nat_cleanup_conntrack(ct);
 }
 
 static struct nf_ct_ext_type nat_extend __read_mostly = {
@@ -796,10 +803,12 @@ static struct nf_ct_helper_expectfn follow_master_nat = {
 
 static int __init nf_nat_init(void)
 {
-	int ret;
+	int ret, i;
 
 	/* Leave them the same for the moment. */
 	nf_nat_htable_size = nf_conntrack_htable_size;
+	if (nf_nat_htable_size < ARRAY_SIZE(nf_nat_locks))
+		nf_nat_htable_size = ARRAY_SIZE(nf_nat_locks);
 
 	nf_nat_bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size, 0);
 	if (!nf_nat_bysource)
@@ -812,6 +821,9 @@ static int __init nf_nat_init(void)
 		return ret;
 	}
 
+	for (i = 0; i < ARRAY_SIZE(nf_nat_locks); i++)
+		spin_lock_init(&nf_nat_locks[i]);
+
 	nf_ct_helper_expectfn_register(&follow_master_nat);
 
 	BUG_ON(nfnetlink_parse_nat_setup_hook != NULL);
-- 
2.1.4
