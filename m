From: kaber@trash.net
Subject: [PATCH 1/6] ipv6: ip6mr: move unres_queue and timer to per-namespace data
Date: Tue, 11 May 2010 16:02:26 +0200
Message-ID: <1273586551-3521-2-git-send-email-kaber@trash.net>
References: <1273586551-3521-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40383 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757926Ab0EKOCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 10:02:39 -0400
In-Reply-To: <1273586551-3521-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The unres_queue is currently shared between all namespaces. Following patches
will additionally allow to create multiple multicast routing tables in each
namespace. Having a single shared queue for all these users seems to excessive,
move the queue and the cleanup timer to the per-namespace data to unshare it.

As a side-effect, this fixes a bug in the seq file iteration functions: the
first entry returned is always from the current namespace, entries returned
after that may belong to any namespace.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netns/ipv6.h |    2 +
 net/ipv6/ip6mr.c         |   74 ++++++++++++++++++++-------------------------
 2 files changed, 35 insertions(+), 41 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 1f11ebc..43d842a 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -60,6 +60,8 @@ struct netns_ipv6 {
 	struct sock             *igmp_sk;
 #ifdef CONFIG_IPV6_MROUTE
 	struct sock		*mroute6_sk;
+	struct timer_list	ipmr_expire_timer;
+	struct mfc6_cache	*mfc6_unres_queue;
 	struct mfc6_cache	**mfc6_cache_array;
 	struct mif_device	*vif6_table;
 	int			maxvif;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index e0b530c..7236030 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -63,8 +63,6 @@ static DEFINE_RWLOCK(mrt_lock);
 
 #define MIF_EXISTS(_net, _idx) ((_net)->ipv6.vif6_table[_idx].dev != NULL)
 
-static struct mfc6_cache *mfc_unres_queue;		/* Queue of unresolved entries */
-
 /* Special spinlock for queue of unresolved entries */
 static DEFINE_SPINLOCK(mfc_unres_lock);
 
@@ -84,8 +82,6 @@ static int ip6mr_cache_report(struct net *net, struct sk_buff *pkt,
 static int ip6mr_fill_mroute(struct sk_buff *skb, struct mfc6_cache *c, struct rtmsg *rtm);
 static void mroute_clean_tables(struct net *net);
 
-static struct timer_list ipmr_expire_timer;
-
 
 #ifdef CONFIG_PROC_FS
 
@@ -110,11 +106,10 @@ static struct mfc6_cache *ipmr_mfc_seq_idx(struct net *net,
 				return mfc;
 	read_unlock(&mrt_lock);
 
-	it->cache = &mfc_unres_queue;
+	it->cache = &net->ipv6.mfc6_unres_queue;
 	spin_lock_bh(&mfc_unres_lock);
-	for (mfc = mfc_unres_queue; mfc; mfc = mfc->next)
-		if (net_eq(mfc6_net(mfc), net) &&
-		    pos-- == 0)
+	for (mfc = net->ipv6.mfc6_unres_queue; mfc; mfc = mfc->next)
+		if (pos-- == 0)
 			return mfc;
 	spin_unlock_bh(&mfc_unres_lock);
 
@@ -244,7 +239,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (mfc->next)
 		return mfc->next;
 
-	if (it->cache == &mfc_unres_queue)
+	if (it->cache == &net->ipv6.mfc6_unres_queue)
 		goto end_of_list;
 
 	BUG_ON(it->cache != net->ipv6.mfc6_cache_array);
@@ -257,11 +252,11 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	/* exhausted cache_array, show unresolved */
 	read_unlock(&mrt_lock);
-	it->cache = &mfc_unres_queue;
+	it->cache = &net->ipv6.mfc6_unres_queue;
 	it->ct = 0;
 
 	spin_lock_bh(&mfc_unres_lock);
-	mfc = mfc_unres_queue;
+	mfc = net->ipv6.mfc6_unres_queue;
 	if (mfc)
 		return mfc;
 
@@ -277,7 +272,7 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
 
-	if (it->cache == &mfc_unres_queue)
+	if (it->cache == &net->ipv6.mfc6_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
 	else if (it->cache == net->ipv6.mfc6_cache_array)
 		read_unlock(&mrt_lock);
@@ -301,7 +296,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 			   &mfc->mf6c_mcastgrp, &mfc->mf6c_origin,
 			   mfc->mf6c_parent);
 
-		if (it->cache != &mfc_unres_queue) {
+		if (it->cache != &net->ipv6.mfc6_unres_queue) {
 			seq_printf(seq, " %8lu %8lu %8lu",
 				   mfc->mfc_un.res.pkt,
 				   mfc->mfc_un.res.bytes,
@@ -559,15 +554,15 @@ static void ip6mr_destroy_unres(struct mfc6_cache *c)
 }
 
 
-/* Single timer process for all the unresolved queue. */
+/* Timer process for all the unresolved queue. */
 
-static void ipmr_do_expire_process(unsigned long dummy)
+static void ipmr_do_expire_process(struct net *net)
 {
 	unsigned long now = jiffies;
 	unsigned long expires = 10 * HZ;
 	struct mfc6_cache *c, **cp;
 
-	cp = &mfc_unres_queue;
+	cp = &net->ipv6.mfc6_unres_queue;
 
 	while ((c = *cp) != NULL) {
 		if (time_after(c->mfc_un.unres.expires, now)) {
@@ -583,19 +578,21 @@ static void ipmr_do_expire_process(unsigned long dummy)
 		ip6mr_destroy_unres(c);
 	}
 
-	if (mfc_unres_queue != NULL)
-		mod_timer(&ipmr_expire_timer, jiffies + expires);
+	if (net->ipv6.mfc6_unres_queue != NULL)
+		mod_timer(&net->ipv6.ipmr_expire_timer, jiffies + expires);
 }
 
-static void ipmr_expire_process(unsigned long dummy)
+static void ipmr_expire_process(unsigned long arg)
 {
+	struct net *net = (struct net *)arg;
+
 	if (!spin_trylock(&mfc_unres_lock)) {
-		mod_timer(&ipmr_expire_timer, jiffies + 1);
+		mod_timer(&net->ipv6.ipmr_expire_timer, jiffies + 1);
 		return;
 	}
 
-	if (mfc_unres_queue != NULL)
-		ipmr_do_expire_process(dummy);
+	if (net->ipv6.mfc6_unres_queue != NULL)
+		ipmr_do_expire_process(net);
 
 	spin_unlock(&mfc_unres_lock);
 }
@@ -880,9 +877,8 @@ ip6mr_cache_unresolved(struct net *net, mifi_t mifi, struct sk_buff *skb)
 	struct mfc6_cache *c;
 
 	spin_lock_bh(&mfc_unres_lock);
-	for (c = mfc_unres_queue; c; c = c->next) {
-		if (net_eq(mfc6_net(c), net) &&
-		    ipv6_addr_equal(&c->mf6c_mcastgrp, &ipv6_hdr(skb)->daddr) &&
+	for (c = net->ipv6.mfc6_unres_queue; c; c = c->next) {
+		if (ipv6_addr_equal(&c->mf6c_mcastgrp, &ipv6_hdr(skb)->daddr) &&
 		    ipv6_addr_equal(&c->mf6c_origin, &ipv6_hdr(skb)->saddr))
 			break;
 	}
@@ -923,10 +919,10 @@ ip6mr_cache_unresolved(struct net *net, mifi_t mifi, struct sk_buff *skb)
 		}
 
 		atomic_inc(&net->ipv6.cache_resolve_queue_len);
-		c->next = mfc_unres_queue;
-		mfc_unres_queue = c;
+		c->next = net->ipv6.mfc6_unres_queue;
+		net->ipv6.mfc6_unres_queue = c;
 
-		ipmr_do_expire_process(1);
+		ipmr_do_expire_process(net);
 	}
 
 	/*
@@ -1019,6 +1015,9 @@ static int __net_init ip6mr_net_init(struct net *net)
 		goto fail_mfc6_cache;
 	}
 
+	setup_timer(&net->ipv6.ipmr_expire_timer, ipmr_expire_process,
+		    (unsigned long)net);
+
 #ifdef CONFIG_IPV6_PIMSM_V2
 	net->ipv6.mroute_reg_vif_num = -1;
 #endif
@@ -1050,6 +1049,7 @@ static void __net_exit ip6mr_net_exit(struct net *net)
 	proc_net_remove(net, "ip6_mr_cache");
 	proc_net_remove(net, "ip6_mr_vif");
 #endif
+	del_timer(&net->ipv6.ipmr_expire_timer);
 	mroute_clean_tables(net);
 	kfree(net->ipv6.mfc6_cache_array);
 	kfree(net->ipv6.vif6_table);
@@ -1075,7 +1075,6 @@ int __init ip6_mr_init(void)
 	if (err)
 		goto reg_pernet_fail;
 
-	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
 	err = register_netdevice_notifier(&ip6_mr_notifier);
 	if (err)
 		goto reg_notif_fail;
@@ -1092,7 +1091,6 @@ add_proto_fail:
 	unregister_netdevice_notifier(&ip6_mr_notifier);
 #endif
 reg_notif_fail:
-	del_timer(&ipmr_expire_timer);
 	unregister_pernet_subsys(&ip6mr_net_ops);
 reg_pernet_fail:
 	kmem_cache_destroy(mrt_cachep);
@@ -1102,7 +1100,6 @@ reg_pernet_fail:
 void ip6_mr_cleanup(void)
 {
 	unregister_netdevice_notifier(&ip6_mr_notifier);
-	del_timer(&ipmr_expire_timer);
 	unregister_pernet_subsys(&ip6mr_net_ops);
 	kmem_cache_destroy(mrt_cachep);
 }
@@ -1167,18 +1164,17 @@ static int ip6mr_mfc_add(struct net *net, struct mf6cctl *mfc, int mrtsock)
 	 *	need to send on the frames and tidy up.
 	 */
 	spin_lock_bh(&mfc_unres_lock);
-	for (cp = &mfc_unres_queue; (uc = *cp) != NULL;
+	for (cp = &net->ipv6.mfc6_unres_queue; (uc = *cp) != NULL;
 	     cp = &uc->next) {
-		if (net_eq(mfc6_net(uc), net) &&
-		    ipv6_addr_equal(&uc->mf6c_origin, &c->mf6c_origin) &&
+		if (ipv6_addr_equal(&uc->mf6c_origin, &c->mf6c_origin) &&
 		    ipv6_addr_equal(&uc->mf6c_mcastgrp, &c->mf6c_mcastgrp)) {
 			*cp = uc->next;
 			atomic_dec(&net->ipv6.cache_resolve_queue_len);
 			break;
 		}
 	}
-	if (mfc_unres_queue == NULL)
-		del_timer(&ipmr_expire_timer);
+	if (net->ipv6.mfc6_unres_queue == NULL)
+		del_timer(&net->ipv6.ipmr_expire_timer);
 	spin_unlock_bh(&mfc_unres_lock);
 
 	if (uc) {
@@ -1230,12 +1226,8 @@ static void mroute_clean_tables(struct net *net)
 		struct mfc6_cache *c, **cp;
 
 		spin_lock_bh(&mfc_unres_lock);
-		cp = &mfc_unres_queue;
+		cp = &net->ipv6.mfc6_unres_queue;
 		while ((c = *cp) != NULL) {
-			if (!net_eq(mfc6_net(c), net)) {
-				cp = &c->next;
-				continue;
-			}
 			*cp = c->next;
 			ip6mr_destroy_unres(c);
 		}
-- 
1.7.0.4

