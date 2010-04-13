From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 5/9] ipv4: ipmr: move unres_queue and timer to per-namespace data
Date: Tue, 13 Apr 2010 17:03:19 +0200
Message-ID: <1271171003-11901-6-git-send-email-kaber@trash.net>
References: <1271171003-11901-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51255 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab0DMPD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:03:28 -0400
In-Reply-To: <1271171003-11901-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The unres_queue is currently shared between all namespaces. Following patches
will additionally allow to create multiple multicast routing tables in each
namespace. Having a single shared queue for all these users seems to excessive,
move the queue and the cleanup timer to the per-namespace data to unshare it.

As a side-effect, this fixes a bug in the seq file iteration functions: the
first entry returned is always from the current namespace, entries returned
after that may belong to any namespace.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netns/ipv4.h |    2 +
 net/ipv4/ipmr.c          |   70 +++++++++++++++++++---------------------------
 2 files changed, 31 insertions(+), 41 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2764994..b15e518 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -60,6 +60,8 @@ struct netns_ipv4 {
 
 #ifdef CONFIG_IP_MROUTE
 	struct sock		*mroute_sk;
+	struct timer_list	ipmr_expire_timer;
+	struct mfc_cache	*mfc_unres_queue;
 	struct mfc_cache	**mfc_cache_array;
 	struct vif_device	*vif_table;
 	int			maxvif;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9d4f6d1..d6aa65e 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -80,8 +80,6 @@ static DEFINE_RWLOCK(mrt_lock);
 
 #define VIF_EXISTS(_net, _idx) ((_net)->ipv4.vif_table[_idx].dev != NULL)
 
-static struct mfc_cache *mfc_unres_queue;		/* Queue of unresolved entries */
-
 /* Special spinlock for queue of unresolved entries */
 static DEFINE_SPINLOCK(mfc_unres_lock);
 
@@ -100,8 +98,6 @@ static int ipmr_cache_report(struct net *net,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm);
 
-static struct timer_list ipmr_expire_timer;
-
 /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */
 
 static void ipmr_del_tunnel(struct net_device *dev, struct vifctl *v)
@@ -364,25 +360,26 @@ static void ipmr_destroy_unres(struct mfc_cache *c)
 }
 
 
-/* Single timer process for all the unresolved queue. */
+/* Timer process for the unresolved queue. */
 
-static void ipmr_expire_process(unsigned long dummy)
+static void ipmr_expire_process(unsigned long arg)
 {
+	struct net *net = (struct net *)arg;
 	unsigned long now;
 	unsigned long expires;
 	struct mfc_cache *c, **cp;
 
 	if (!spin_trylock(&mfc_unres_lock)) {
-		mod_timer(&ipmr_expire_timer, jiffies+HZ/10);
+		mod_timer(&net->ipv4.ipmr_expire_timer, jiffies+HZ/10);
 		return;
 	}
 
-	if (mfc_unres_queue == NULL)
+	if (net->ipv4.mfc_unres_queue == NULL)
 		goto out;
 
 	now = jiffies;
 	expires = 10*HZ;
-	cp = &mfc_unres_queue;
+	cp = &net->ipv4.mfc_unres_queue;
 
 	while ((c=*cp) != NULL) {
 		if (time_after(c->mfc_un.unres.expires, now)) {
@@ -398,8 +395,8 @@ static void ipmr_expire_process(unsigned long dummy)
 		ipmr_destroy_unres(c);
 	}
 
-	if (mfc_unres_queue != NULL)
-		mod_timer(&ipmr_expire_timer, jiffies + expires);
+	if (net->ipv4.mfc_unres_queue != NULL)
+		mod_timer(&net->ipv4.ipmr_expire_timer, jiffies + expires);
 
 out:
 	spin_unlock(&mfc_unres_lock);
@@ -708,9 +705,8 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 
 	spin_lock_bh(&mfc_unres_lock);
-	for (c=mfc_unres_queue; c; c=c->next) {
-		if (net_eq(mfc_net(c), net) &&
-		    c->mfc_mcastgrp == iph->daddr &&
+	for (c=net->ipv4.mfc_unres_queue; c; c=c->next) {
+		if (c->mfc_mcastgrp == iph->daddr &&
 		    c->mfc_origin == iph->saddr)
 			break;
 	}
@@ -751,10 +747,10 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 		}
 
 		atomic_inc(&net->ipv4.cache_resolve_queue_len);
-		c->next = mfc_unres_queue;
-		mfc_unres_queue = c;
+		c->next = net->ipv4.mfc_unres_queue;
+		net->ipv4.mfc_unres_queue = c;
 
-		mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
+		mod_timer(&net->ipv4.ipmr_expire_timer, c->mfc_un.unres.expires);
 	}
 
 	/*
@@ -849,18 +845,17 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	 *	need to send on the frames and tidy up.
 	 */
 	spin_lock_bh(&mfc_unres_lock);
-	for (cp = &mfc_unres_queue; (uc=*cp) != NULL;
+	for (cp = &net->ipv4.mfc_unres_queue; (uc=*cp) != NULL;
 	     cp = &uc->next) {
-		if (net_eq(mfc_net(uc), net) &&
-		    uc->mfc_origin == c->mfc_origin &&
+		if (uc->mfc_origin == c->mfc_origin &&
 		    uc->mfc_mcastgrp == c->mfc_mcastgrp) {
 			*cp = uc->next;
 			atomic_dec(&net->ipv4.cache_resolve_queue_len);
 			break;
 		}
 	}
-	if (mfc_unres_queue == NULL)
-		del_timer(&ipmr_expire_timer);
+	if (net->ipv4.mfc_unres_queue == NULL)
+		del_timer(&net->ipv4.ipmr_expire_timer);
 	spin_unlock_bh(&mfc_unres_lock);
 
 	if (uc) {
@@ -912,14 +907,9 @@ static void mroute_clean_tables(struct net *net)
 		struct mfc_cache *c, **cp;
 
 		spin_lock_bh(&mfc_unres_lock);
-		cp = &mfc_unres_queue;
+		cp = &net->ipv4.mfc_unres_queue;
 		while ((c = *cp) != NULL) {
-			if (!net_eq(mfc_net(c), net)) {
-				cp = &c->next;
-				continue;
-			}
 			*cp = c->next;
-
 			ipmr_destroy_unres(c);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
@@ -1819,11 +1809,10 @@ static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
 				return mfc;
 	read_unlock(&mrt_lock);
 
-	it->cache = &mfc_unres_queue;
+	it->cache = &net->ipv4.mfc_unres_queue;
 	spin_lock_bh(&mfc_unres_lock);
-	for (mfc = mfc_unres_queue; mfc; mfc = mfc->next)
-		if (net_eq(mfc_net(mfc), net) &&
-		    pos-- == 0)
+	for (mfc = net->ipv4.mfc_unres_queue; mfc; mfc = mfc->next)
+		if (pos-- == 0)
 			return mfc;
 	spin_unlock_bh(&mfc_unres_lock);
 
@@ -1857,7 +1846,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (mfc->next)
 		return mfc->next;
 
-	if (it->cache == &mfc_unres_queue)
+	if (it->cache == &net->ipv4.mfc_unres_queue)
 		goto end_of_list;
 
 	BUG_ON(it->cache != net->ipv4.mfc_cache_array);
@@ -1870,13 +1859,11 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	/* exhausted cache_array, show unresolved */
 	read_unlock(&mrt_lock);
-	it->cache = &mfc_unres_queue;
+	it->cache = &net->ipv4.mfc_unres_queue;
 	it->ct = 0;
 
 	spin_lock_bh(&mfc_unres_lock);
-	mfc = mfc_unres_queue;
-	while (mfc && !net_eq(mfc_net(mfc), net))
-		mfc = mfc->next;
+	mfc = net->ipv4.mfc_unres_queue;
 	if (mfc)
 		return mfc;
 
@@ -1892,7 +1879,7 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
 
-	if (it->cache == &mfc_unres_queue)
+	if (it->cache == &net->ipv4.mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
 	else if (it->cache == net->ipv4.mfc_cache_array)
 		read_unlock(&mrt_lock);
@@ -1915,7 +1902,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 			   (unsigned long) mfc->mfc_origin,
 			   mfc->mfc_parent);
 
-		if (it->cache != &mfc_unres_queue) {
+		if (it->cache != &net->ipv4.mfc_unres_queue) {
 			seq_printf(seq, " %8lu %8lu %8lu",
 				   mfc->mfc_un.res.pkt,
 				   mfc->mfc_un.res.bytes,
@@ -1992,6 +1979,9 @@ static int __net_init ipmr_net_init(struct net *net)
 		goto fail_mfc_cache;
 	}
 
+	setup_timer(&net->ipv4.ipmr_expire_timer, ipmr_expire_process,
+		    (unsigned long)net);
+
 #ifdef CONFIG_IP_PIMSM
 	net->ipv4.mroute_reg_vif_num = -1;
 #endif
@@ -2047,7 +2037,6 @@ int __init ip_mr_init(void)
 	if (err)
 		goto reg_pernet_fail;
 
-	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
 	err = register_netdevice_notifier(&ip_mr_notifier);
 	if (err)
 		goto reg_notif_fail;
@@ -2065,7 +2054,6 @@ add_proto_fail:
 	unregister_netdevice_notifier(&ip_mr_notifier);
 #endif
 reg_notif_fail:
-	del_timer(&ipmr_expire_timer);
 	unregister_pernet_subsys(&ipmr_net_ops);
 reg_pernet_fail:
 	kmem_cache_destroy(mrt_cachep);
-- 
1.7.0.4

