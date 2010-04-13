From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 8/9] ipv4: ipmr: move mroute data into seperate structure
Date: Tue, 13 Apr 2010 17:03:22 +0200
Message-ID: <1271171003-11901-9-git-send-email-kaber@trash.net>
References: <1271171003-11901-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51258 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab0DMPD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:03:28 -0400
In-Reply-To: <1271171003-11901-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netns/ipv4.h |   13 +--
 net/ipv4/ipmr.c          |  369 +++++++++++++++++++++++++---------------------
 2 files changed, 200 insertions(+), 182 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 5d06429..72e762a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -59,18 +59,7 @@ struct netns_ipv4 {
 	atomic_t rt_genid;
 
 #ifdef CONFIG_IP_MROUTE
-	struct sock		*mroute_sk;
-	struct timer_list	ipmr_expire_timer;
-	struct list_head	mfc_unres_queue;
-	struct list_head	*mfc_cache_array;
-	struct vif_device	*vif_table;
-	int			maxvif;
-	atomic_t		cache_resolve_queue_len;
-	int			mroute_do_assert;
-	int			mroute_do_pim;
-#if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
-	int			mroute_reg_vif_num;
-#endif
+	struct mr_table		*mrt;
 #endif
 };
 #endif
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 21b5edc..498f4e9 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -68,6 +68,21 @@
 #define CONFIG_IP_PIMSM	1
 #endif
 
+struct mr_table {
+	struct sock		*mroute_sk;
+	struct timer_list	ipmr_expire_timer;
+	struct list_head	mfc_unres_queue;
+	struct list_head	mfc_cache_array[MFC_LINES];
+	struct vif_device	vif_table[MAXVIFS];
+	int			maxvif;
+	atomic_t		cache_resolve_queue_len;
+	int			mroute_do_assert;
+	int			mroute_do_pim;
+#if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
+	int			mroute_reg_vif_num;
+#endif
+};
+
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
    Note that the changes are semaphored via rtnl_lock.
  */
@@ -78,7 +93,7 @@ static DEFINE_RWLOCK(mrt_lock);
  *	Multicast router control variables
  */
 
-#define VIF_EXISTS(_net, _idx) ((_net)->ipv4.vif_table[_idx].dev != NULL)
+#define VIF_EXISTS(_mrt, _idx) ((_mrt)->vif_table[_idx].dev != NULL)
 
 /* Special spinlock for queue of unresolved entries */
 static DEFINE_SPINLOCK(mfc_unres_lock);
@@ -93,11 +108,12 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 
 static struct kmem_cache *mrt_cachep __read_mostly;
 
-static int ip_mr_forward(struct net *net, struct sk_buff *skb,
-			 struct mfc_cache *cache, int local);
-static int ipmr_cache_report(struct net *net,
+static int ip_mr_forward(struct net *net, struct mr_table *mrt,
+			 struct sk_buff *skb, struct mfc_cache *cache,
+			 int local);
+static int ipmr_cache_report(struct mr_table *mrt,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
-static int ipmr_fill_mroute(struct net *net, struct sk_buff *skb,
+static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			    struct mfc_cache *c, struct rtmsg *rtm);
 
 /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */
@@ -199,12 +215,12 @@ failure:
 static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
-	ipmr_cache_report(net, skb, net->ipv4.mroute_reg_vif_num,
-			  IGMPMSG_WHOLEPKT);
+	ipmr_cache_report(mrt, skb, mrt->mroute_reg_vif_num, IGMPMSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
 	return NETDEV_TX_OK;
@@ -274,17 +290,17 @@ failure:
  *	@notify: Set to 1, if the caller is a notifier_call
  */
 
-static int vif_delete(struct net *net, int vifi, int notify,
+static int vif_delete(struct mr_table *mrt, int vifi, int notify,
 		      struct list_head *head)
 {
 	struct vif_device *v;
 	struct net_device *dev;
 	struct in_device *in_dev;
 
-	if (vifi < 0 || vifi >= net->ipv4.maxvif)
+	if (vifi < 0 || vifi >= mrt->maxvif)
 		return -EADDRNOTAVAIL;
 
-	v = &net->ipv4.vif_table[vifi];
+	v = &mrt->vif_table[vifi];
 
 	write_lock_bh(&mrt_lock);
 	dev = v->dev;
@@ -296,17 +312,17 @@ static int vif_delete(struct net *net, int vifi, int notify,
 	}
 
 #ifdef CONFIG_IP_PIMSM
-	if (vifi == net->ipv4.mroute_reg_vif_num)
-		net->ipv4.mroute_reg_vif_num = -1;
+	if (vifi == mrt->mroute_reg_vif_num)
+		mrt->mroute_reg_vif_num = -1;
 #endif
 
-	if (vifi+1 == net->ipv4.maxvif) {
+	if (vifi+1 == mrt->maxvif) {
 		int tmp;
 		for (tmp=vifi-1; tmp>=0; tmp--) {
-			if (VIF_EXISTS(net, tmp))
+			if (VIF_EXISTS(mrt, tmp))
 				break;
 		}
-		net->ipv4.maxvif = tmp+1;
+		mrt->maxvif = tmp+1;
 	}
 
 	write_unlock_bh(&mrt_lock);
@@ -334,12 +350,13 @@ static inline void ipmr_cache_free(struct mfc_cache *c)
    and reporting error to netlink readers.
  */
 
-static void ipmr_destroy_unres(struct net *net, struct mfc_cache *c)
+static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 {
+	struct net *net = NULL; //mrt->net;
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
 
-	atomic_dec(&net->ipv4.cache_resolve_queue_len);
+	atomic_dec(&mrt->cache_resolve_queue_len);
 
 	while ((skb = skb_dequeue(&c->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
@@ -364,23 +381,23 @@ static void ipmr_destroy_unres(struct net *net, struct mfc_cache *c)
 
 static void ipmr_expire_process(unsigned long arg)
 {
-	struct net *net = (struct net *)arg;
+	struct mr_table *mrt = (struct mr_table *)arg;
 	unsigned long now;
 	unsigned long expires;
 	struct mfc_cache *c, *next;
 
 	if (!spin_trylock(&mfc_unres_lock)) {
-		mod_timer(&net->ipv4.ipmr_expire_timer, jiffies+HZ/10);
+		mod_timer(&mrt->ipmr_expire_timer, jiffies+HZ/10);
 		return;
 	}
 
-	if (list_empty(&net->ipv4.mfc_unres_queue))
+	if (list_empty(&mrt->mfc_unres_queue))
 		goto out;
 
 	now = jiffies;
 	expires = 10*HZ;
 
-	list_for_each_entry_safe(c, next, &net->ipv4.mfc_unres_queue, list) {
+	list_for_each_entry_safe(c, next, &mrt->mfc_unres_queue, list) {
 		if (time_after(c->mfc_un.unres.expires, now)) {
 			unsigned long interval = c->mfc_un.unres.expires - now;
 			if (interval < expires)
@@ -389,11 +406,11 @@ static void ipmr_expire_process(unsigned long arg)
 		}
 
 		list_del(&c->list);
-		ipmr_destroy_unres(net, c);
+		ipmr_destroy_unres(mrt, c);
 	}
 
-	if (!list_empty(&net->ipv4.mfc_unres_queue))
-		mod_timer(&net->ipv4.ipmr_expire_timer, jiffies + expires);
+	if (!list_empty(&mrt->mfc_unres_queue))
+		mod_timer(&mrt->ipmr_expire_timer, jiffies + expires);
 
 out:
 	spin_unlock(&mfc_unres_lock);
@@ -401,7 +418,7 @@ out:
 
 /* Fill oifs list. It is called under write locked mrt_lock. */
 
-static void ipmr_update_thresholds(struct net *net, struct mfc_cache *cache,
+static void ipmr_update_thresholds(struct mr_table *mrt, struct mfc_cache *cache,
 				   unsigned char *ttls)
 {
 	int vifi;
@@ -410,8 +427,8 @@ static void ipmr_update_thresholds(struct net *net, struct mfc_cache *cache,
 	cache->mfc_un.res.maxvif = 0;
 	memset(cache->mfc_un.res.ttls, 255, MAXVIFS);
 
-	for (vifi = 0; vifi < net->ipv4.maxvif; vifi++) {
-		if (VIF_EXISTS(net, vifi) &&
+	for (vifi = 0; vifi < mrt->maxvif; vifi++) {
+		if (VIF_EXISTS(mrt, vifi) &&
 		    ttls[vifi] && ttls[vifi] < 255) {
 			cache->mfc_un.res.ttls[vifi] = ttls[vifi];
 			if (cache->mfc_un.res.minvif > vifi)
@@ -422,16 +439,17 @@ static void ipmr_update_thresholds(struct net *net, struct mfc_cache *cache,
 	}
 }
 
-static int vif_add(struct net *net, struct vifctl *vifc, int mrtsock)
+static int vif_add(struct net *net, struct mr_table *mrt,
+		   struct vifctl *vifc, int mrtsock)
 {
 	int vifi = vifc->vifc_vifi;
-	struct vif_device *v = &net->ipv4.vif_table[vifi];
+	struct vif_device *v = &mrt->vif_table[vifi];
 	struct net_device *dev;
 	struct in_device *in_dev;
 	int err;
 
 	/* Is vif busy ? */
-	if (VIF_EXISTS(net, vifi))
+	if (VIF_EXISTS(mrt, vifi))
 		return -EADDRINUSE;
 
 	switch (vifc->vifc_flags) {
@@ -441,7 +459,7 @@ static int vif_add(struct net *net, struct vifctl *vifc, int mrtsock)
 		 * Special Purpose VIF in PIM
 		 * All the packets will be sent to the daemon
 		 */
-		if (net->ipv4.mroute_reg_vif_num >= 0)
+		if (mrt->mroute_reg_vif_num >= 0)
 			return -EADDRINUSE;
 		dev = ipmr_reg_vif(net);
 		if (!dev)
@@ -519,22 +537,22 @@ static int vif_add(struct net *net, struct vifctl *vifc, int mrtsock)
 	v->dev = dev;
 #ifdef CONFIG_IP_PIMSM
 	if (v->flags&VIFF_REGISTER)
-		net->ipv4.mroute_reg_vif_num = vifi;
+		mrt->mroute_reg_vif_num = vifi;
 #endif
-	if (vifi+1 > net->ipv4.maxvif)
-		net->ipv4.maxvif = vifi+1;
+	if (vifi+1 > mrt->maxvif)
+		mrt->maxvif = vifi+1;
 	write_unlock_bh(&mrt_lock);
 	return 0;
 }
 
-static struct mfc_cache *ipmr_cache_find(struct net *net,
+static struct mfc_cache *ipmr_cache_find(struct mr_table *mrt,
 					 __be32 origin,
 					 __be32 mcastgrp)
 {
 	int line = MFC_HASH(mcastgrp, origin);
 	struct mfc_cache *c;
 
-	list_for_each_entry(c, &net->ipv4.mfc_cache_array[line], list) {
+	list_for_each_entry(c, &mrt->mfc_cache_array[line], list) {
 		if (c->mfc_origin == origin && c->mfc_mcastgrp == mcastgrp)
 			return c;
 	}
@@ -567,8 +585,8 @@ static struct mfc_cache *ipmr_cache_alloc_unres(void)
  *	A cache entry has gone into a resolved state from queued
  */
 
-static void ipmr_cache_resolve(struct net *net, struct mfc_cache *uc,
-			       struct mfc_cache *c)
+static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
+			       struct mfc_cache *uc, struct mfc_cache *c)
 {
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
@@ -581,7 +599,7 @@ static void ipmr_cache_resolve(struct net *net, struct mfc_cache *uc,
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
-			if (ipmr_fill_mroute(net, skb, c, NLMSG_DATA(nlh)) > 0) {
+			if (ipmr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
 				nlh->nlmsg_len = (skb_tail_pointer(skb) -
 						  (u8 *)nlh);
 			} else {
@@ -595,7 +613,7 @@ static void ipmr_cache_resolve(struct net *net, struct mfc_cache *uc,
 
 			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
 		} else
-			ip_mr_forward(net, skb, c, 0);
+			ip_mr_forward(net, mrt, skb, c, 0);
 	}
 }
 
@@ -606,7 +624,7 @@ static void ipmr_cache_resolve(struct net *net, struct mfc_cache *uc,
  *	Called under mrt_lock.
  */
 
-static int ipmr_cache_report(struct net *net,
+static int ipmr_cache_report(struct mr_table *mrt,
 			     struct sk_buff *pkt, vifi_t vifi, int assert)
 {
 	struct sk_buff *skb;
@@ -639,7 +657,7 @@ static int ipmr_cache_report(struct net *net,
 		memcpy(msg, skb_network_header(pkt), sizeof(struct iphdr));
 		msg->im_msgtype = IGMPMSG_WHOLEPKT;
 		msg->im_mbz = 0;
-		msg->im_vif = net->ipv4.mroute_reg_vif_num;
+		msg->im_vif = mrt->mroute_reg_vif_num;
 		ip_hdr(skb)->ihl = sizeof(struct iphdr) >> 2;
 		ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(pkt)->tot_len) +
 					     sizeof(struct iphdr));
@@ -671,7 +689,7 @@ static int ipmr_cache_report(struct net *net,
 	skb->transport_header = skb->network_header;
 	}
 
-	if (net->ipv4.mroute_sk == NULL) {
+	if (mrt->mroute_sk == NULL) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -679,7 +697,7 @@ static int ipmr_cache_report(struct net *net,
 	/*
 	 *	Deliver to mrouted
 	 */
-	ret = sock_queue_rcv_skb(net->ipv4.mroute_sk, skb);
+	ret = sock_queue_rcv_skb(mrt->mroute_sk, skb);
 	if (ret < 0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "mroute: pending queue full, dropping entries.\n");
@@ -694,7 +712,7 @@ static int ipmr_cache_report(struct net *net,
  */
 
 static int
-ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
+ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 {
 	bool found = false;
 	int err;
@@ -702,7 +720,7 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 
 	spin_lock_bh(&mfc_unres_lock);
-	list_for_each_entry(c, &net->ipv4.mfc_unres_queue, list) {
+	list_for_each_entry(c, &mrt->mfc_unres_queue, list) {
 		if (c->mfc_mcastgrp == iph->daddr &&
 		    c->mfc_origin == iph->saddr) {
 			found = true;
@@ -715,7 +733,7 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 		 *	Create a new entry if allowable
 		 */
 
-		if (atomic_read(&net->ipv4.cache_resolve_queue_len) >= 10 ||
+		if (atomic_read(&mrt->cache_resolve_queue_len) >= 10 ||
 		    (c = ipmr_cache_alloc_unres()) == NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
 
@@ -733,7 +751,7 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 		/*
 		 *	Reflect first query at mrouted.
 		 */
-		err = ipmr_cache_report(net, skb, vifi, IGMPMSG_NOCACHE);
+		err = ipmr_cache_report(mrt, skb, vifi, IGMPMSG_NOCACHE);
 		if (err < 0) {
 			/* If the report failed throw the cache entry
 			   out - Brad Parker
@@ -745,10 +763,10 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 			return err;
 		}
 
-		atomic_inc(&net->ipv4.cache_resolve_queue_len);
-		list_add(&c->list, &net->ipv4.mfc_unres_queue);
+		atomic_inc(&mrt->cache_resolve_queue_len);
+		list_add(&c->list, &mrt->mfc_unres_queue);
 
-		mod_timer(&net->ipv4.ipmr_expire_timer, c->mfc_un.unres.expires);
+		mod_timer(&mrt->ipmr_expire_timer, c->mfc_un.unres.expires);
 	}
 
 	/*
@@ -770,14 +788,14 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
  *	MFC cache manipulation by user space mroute daemon
  */
 
-static int ipmr_mfc_delete(struct net *net, struct mfcctl *mfc)
+static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc)
 {
 	int line;
 	struct mfc_cache *c, *next;
 
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	list_for_each_entry_safe(c, next, &net->ipv4.mfc_cache_array[line], list) {
+	list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[line], list) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
 			write_lock_bh(&mrt_lock);
@@ -791,7 +809,8 @@ static int ipmr_mfc_delete(struct net *net, struct mfcctl *mfc)
 	return -ENOENT;
 }
 
-static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
+static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
+			struct mfcctl *mfc, int mrtsock)
 {
 	bool found = false;
 	int line;
@@ -802,7 +821,7 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	list_for_each_entry(c, &net->ipv4.mfc_cache_array[line], list) {
+	list_for_each_entry(c, &mrt->mfc_cache_array[line], list) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
 			found = true;
@@ -813,7 +832,7 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	if (found) {
 		write_lock_bh(&mrt_lock);
 		c->mfc_parent = mfc->mfcc_parent;
-		ipmr_update_thresholds(net, c, mfc->mfcc_ttls);
+		ipmr_update_thresholds(mrt, c, mfc->mfcc_ttls);
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
@@ -830,12 +849,12 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	c->mfc_origin = mfc->mfcc_origin.s_addr;
 	c->mfc_mcastgrp = mfc->mfcc_mcastgrp.s_addr;
 	c->mfc_parent = mfc->mfcc_parent;
-	ipmr_update_thresholds(net, c, mfc->mfcc_ttls);
+	ipmr_update_thresholds(mrt, c, mfc->mfcc_ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
 	write_lock_bh(&mrt_lock);
-	list_add(&c->list, &net->ipv4.mfc_cache_array[line]);
+	list_add(&c->list, &mrt->mfc_cache_array[line]);
 	write_unlock_bh(&mrt_lock);
 
 	/*
@@ -843,20 +862,20 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	 *	need to send on the frames and tidy up.
 	 */
 	spin_lock_bh(&mfc_unres_lock);
-	list_for_each_entry(uc, &net->ipv4.mfc_unres_queue, list) {
+	list_for_each_entry(uc, &mrt->mfc_unres_queue, list) {
 		if (uc->mfc_origin == c->mfc_origin &&
 		    uc->mfc_mcastgrp == c->mfc_mcastgrp) {
 			list_del(&uc->list);
-			atomic_dec(&net->ipv4.cache_resolve_queue_len);
+			atomic_dec(&mrt->cache_resolve_queue_len);
 			break;
 		}
 	}
-	if (list_empty(&net->ipv4.mfc_unres_queue))
-		del_timer(&net->ipv4.ipmr_expire_timer);
+	if (list_empty(&mrt->mfc_unres_queue))
+		del_timer(&mrt->ipmr_expire_timer);
 	spin_unlock_bh(&mfc_unres_lock);
 
 	if (uc) {
-		ipmr_cache_resolve(net, uc, c);
+		ipmr_cache_resolve(net, mrt, uc, c);
 		ipmr_cache_free(uc);
 	}
 	return 0;
@@ -866,7 +885,7 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
  *	Close the multicast socket, and clear the vif tables etc
  */
 
-static void mroute_clean_tables(struct net *net)
+static void mroute_clean_tables(struct mr_table *mrt)
 {
 	int i;
 	LIST_HEAD(list);
@@ -875,9 +894,9 @@ static void mroute_clean_tables(struct net *net)
 	/*
 	 *	Shut down all active vif entries
 	 */
-	for (i = 0; i < net->ipv4.maxvif; i++) {
-		if (!(net->ipv4.vif_table[i].flags&VIFF_STATIC))
-			vif_delete(net, i, 0, &list);
+	for (i = 0; i < mrt->maxvif; i++) {
+		if (!(mrt->vif_table[i].flags&VIFF_STATIC))
+			vif_delete(mrt, i, 0, &list);
 	}
 	unregister_netdevice_many(&list);
 
@@ -885,7 +904,7 @@ static void mroute_clean_tables(struct net *net)
 	 *	Wipe the cache
 	 */
 	for (i = 0; i < MFC_LINES; i++) {
-		list_for_each_entry_safe(c, next, &net->ipv4.mfc_cache_array[i], list) {
+		list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[i], list) {
 			if (c->mfc_flags&MFC_STATIC)
 				continue;
 			write_lock_bh(&mrt_lock);
@@ -896,11 +915,11 @@ static void mroute_clean_tables(struct net *net)
 		}
 	}
 
-	if (atomic_read(&net->ipv4.cache_resolve_queue_len) != 0) {
+	if (atomic_read(&mrt->cache_resolve_queue_len) != 0) {
 		spin_lock_bh(&mfc_unres_lock);
-		list_for_each_entry_safe(c, next, &net->ipv4.mfc_unres_queue, list) {
+		list_for_each_entry_safe(c, next, &mrt->mfc_unres_queue, list) {
 			list_del(&c->list);
-			ipmr_destroy_unres(net, c);
+			ipmr_destroy_unres(mrt, c);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
 	}
@@ -909,16 +928,17 @@ static void mroute_clean_tables(struct net *net)
 static void mrtsock_destruct(struct sock *sk)
 {
 	struct net *net = sock_net(sk);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	rtnl_lock();
-	if (sk == net->ipv4.mroute_sk) {
+	if (sk == mrt->mroute_sk) {
 		IPV4_DEVCONF_ALL(net, MC_FORWARDING)--;
 
 		write_lock_bh(&mrt_lock);
-		net->ipv4.mroute_sk = NULL;
+		mrt->mroute_sk = NULL;
 		write_unlock_bh(&mrt_lock);
 
-		mroute_clean_tables(net);
+		mroute_clean_tables(mrt);
 	}
 	rtnl_unlock();
 }
@@ -936,9 +956,10 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	struct vifctl vif;
 	struct mfcctl mfc;
 	struct net *net = sock_net(sk);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	if (optname != MRT_INIT) {
-		if (sk != net->ipv4.mroute_sk && !capable(CAP_NET_ADMIN))
+		if (sk != mrt->mroute_sk && !capable(CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
@@ -951,7 +972,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -ENOPROTOOPT;
 
 		rtnl_lock();
-		if (net->ipv4.mroute_sk) {
+		if (mrt->mroute_sk) {
 			rtnl_unlock();
 			return -EADDRINUSE;
 		}
@@ -959,7 +980,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		ret = ip_ra_control(sk, 1, mrtsock_destruct);
 		if (ret == 0) {
 			write_lock_bh(&mrt_lock);
-			net->ipv4.mroute_sk = sk;
+			mrt->mroute_sk = sk;
 			write_unlock_bh(&mrt_lock);
 
 			IPV4_DEVCONF_ALL(net, MC_FORWARDING)++;
@@ -967,7 +988,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		rtnl_unlock();
 		return ret;
 	case MRT_DONE:
-		if (sk != net->ipv4.mroute_sk)
+		if (sk != mrt->mroute_sk)
 			return -EACCES;
 		return ip_ra_control(sk, 0, NULL);
 	case MRT_ADD_VIF:
@@ -980,9 +1001,9 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -ENFILE;
 		rtnl_lock();
 		if (optname == MRT_ADD_VIF) {
-			ret = vif_add(net, &vif, sk == net->ipv4.mroute_sk);
+			ret = vif_add(net, mrt, &vif, sk == mrt->mroute_sk);
 		} else {
-			ret = vif_delete(net, vif.vifc_vifi, 0, NULL);
+			ret = vif_delete(mrt, vif.vifc_vifi, 0, NULL);
 		}
 		rtnl_unlock();
 		return ret;
@@ -999,9 +1020,9 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -EFAULT;
 		rtnl_lock();
 		if (optname == MRT_DEL_MFC)
-			ret = ipmr_mfc_delete(net, &mfc);
+			ret = ipmr_mfc_delete(mrt, &mfc);
 		else
-			ret = ipmr_mfc_add(net, &mfc, sk == net->ipv4.mroute_sk);
+			ret = ipmr_mfc_add(net, mrt, &mfc, sk == mrt->mroute_sk);
 		rtnl_unlock();
 		return ret;
 		/*
@@ -1012,7 +1033,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		int v;
 		if (get_user(v,(int __user *)optval))
 			return -EFAULT;
-		net->ipv4.mroute_do_assert = (v) ? 1 : 0;
+		mrt->mroute_do_assert = (v) ? 1 : 0;
 		return 0;
 	}
 #ifdef CONFIG_IP_PIMSM
@@ -1026,9 +1047,9 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 
 		rtnl_lock();
 		ret = 0;
-		if (v != net->ipv4.mroute_do_pim) {
-			net->ipv4.mroute_do_pim = v;
-			net->ipv4.mroute_do_assert = v;
+		if (v != mrt->mroute_do_pim) {
+			mrt->mroute_do_pim = v;
+			mrt->mroute_do_assert = v;
 		}
 		rtnl_unlock();
 		return ret;
@@ -1052,6 +1073,7 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 	int olr;
 	int val;
 	struct net *net = sock_net(sk);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	if (optname != MRT_VERSION &&
 #ifdef CONFIG_IP_PIMSM
@@ -1073,10 +1095,10 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 		val = 0x0305;
 #ifdef CONFIG_IP_PIMSM
 	else if (optname == MRT_PIM)
-		val = net->ipv4.mroute_do_pim;
+		val = mrt->mroute_do_pim;
 #endif
 	else
-		val = net->ipv4.mroute_do_assert;
+		val = mrt->mroute_do_assert;
 	if (copy_to_user(optval, &val, olr))
 		return -EFAULT;
 	return 0;
@@ -1093,16 +1115,17 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 	struct vif_device *vif;
 	struct mfc_cache *c;
 	struct net *net = sock_net(sk);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	switch (cmd) {
 	case SIOCGETVIFCNT:
 		if (copy_from_user(&vr, arg, sizeof(vr)))
 			return -EFAULT;
-		if (vr.vifi >= net->ipv4.maxvif)
+		if (vr.vifi >= mrt->maxvif)
 			return -EINVAL;
 		read_lock(&mrt_lock);
-		vif = &net->ipv4.vif_table[vr.vifi];
-		if (VIF_EXISTS(net, vr.vifi)) {
+		vif = &mrt->vif_table[vr.vifi];
+		if (VIF_EXISTS(mrt, vr.vifi)) {
 			vr.icount = vif->pkt_in;
 			vr.ocount = vif->pkt_out;
 			vr.ibytes = vif->bytes_in;
@@ -1120,7 +1143,7 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 			return -EFAULT;
 
 		read_lock(&mrt_lock);
-		c = ipmr_cache_find(net, sr.src.s_addr, sr.grp.s_addr);
+		c = ipmr_cache_find(mrt, sr.src.s_addr, sr.grp.s_addr);
 		if (c) {
 			sr.pktcnt = c->mfc_un.res.pkt;
 			sr.bytecnt = c->mfc_un.res.bytes;
@@ -1143,16 +1166,17 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 {
 	struct net_device *dev = ptr;
 	struct net *net = dev_net(dev);
+	struct mr_table *mrt = net->ipv4.mrt;
 	struct vif_device *v;
 	int ct;
 	LIST_HEAD(list);
 
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
-	v = &net->ipv4.vif_table[0];
-	for (ct = 0; ct < net->ipv4.maxvif; ct++, v++) {
+	v = &mrt->vif_table[0];
+	for (ct = 0; ct < mrt->maxvif; ct++, v++) {
 		if (v->dev == dev)
-			vif_delete(net, ct, 1, &list);
+			vif_delete(mrt, ct, 1, &list);
 	}
 	unregister_netdevice_many(&list);
 	return NOTIFY_DONE;
@@ -1211,11 +1235,11 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
  *	Processing handlers for ipmr_forward
  */
 
-static void ipmr_queue_xmit(struct net *net, struct sk_buff *skb,
-			    struct mfc_cache *c, int vifi)
+static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
+			    struct sk_buff *skb, struct mfc_cache *c, int vifi)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct vif_device *vif = &net->ipv4.vif_table[vifi];
+	struct vif_device *vif = &mrt->vif_table[vifi];
 	struct net_device *dev;
 	struct rtable *rt;
 	int    encap = 0;
@@ -1229,7 +1253,7 @@ static void ipmr_queue_xmit(struct net *net, struct sk_buff *skb,
 		vif->bytes_out += skb->len;
 		vif->dev->stats.tx_bytes += skb->len;
 		vif->dev->stats.tx_packets++;
-		ipmr_cache_report(net, skb, vifi, IGMPMSG_WHOLEPKT);
+		ipmr_cache_report(mrt, skb, vifi, IGMPMSG_WHOLEPKT);
 		goto out_free;
 	}
 #endif
@@ -1312,12 +1336,12 @@ out_free:
 	return;
 }
 
-static int ipmr_find_vif(struct net_device *dev)
+static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
 {
-	struct net *net = dev_net(dev);
 	int ct;
-	for (ct = net->ipv4.maxvif-1; ct >= 0; ct--) {
-		if (net->ipv4.vif_table[ct].dev == dev)
+
+	for (ct = mrt->maxvif-1; ct >= 0; ct--) {
+		if (mrt->vif_table[ct].dev == dev)
 			break;
 	}
 	return ct;
@@ -1325,8 +1349,9 @@ static int ipmr_find_vif(struct net_device *dev)
 
 /* "local" means that we should preserve one skb (for local delivery) */
 
-static int ip_mr_forward(struct net *net, struct sk_buff *skb,
-			 struct mfc_cache *cache, int local)
+static int ip_mr_forward(struct net *net, struct mr_table *mrt,
+			 struct sk_buff *skb, struct mfc_cache *cache,
+			 int local)
 {
 	int psend = -1;
 	int vif, ct;
@@ -1338,7 +1363,7 @@ static int ip_mr_forward(struct net *net, struct sk_buff *skb,
 	/*
 	 * Wrong interface: drop packet and (maybe) send PIM assert.
 	 */
-	if (net->ipv4.vif_table[vif].dev != skb->dev) {
+	if (mrt->vif_table[vif].dev != skb->dev) {
 		int true_vifi;
 
 		if (skb_rtable(skb)->fl.iif == 0) {
@@ -1357,26 +1382,26 @@ static int ip_mr_forward(struct net *net, struct sk_buff *skb,
 		}
 
 		cache->mfc_un.res.wrong_if++;
-		true_vifi = ipmr_find_vif(skb->dev);
+		true_vifi = ipmr_find_vif(mrt, skb->dev);
 
-		if (true_vifi >= 0 && net->ipv4.mroute_do_assert &&
+		if (true_vifi >= 0 && mrt->mroute_do_assert &&
 		    /* pimsm uses asserts, when switching from RPT to SPT,
 		       so that we cannot check that packet arrived on an oif.
 		       It is bad, but otherwise we would need to move pretty
 		       large chunk of pimd to kernel. Ough... --ANK
 		     */
-		    (net->ipv4.mroute_do_pim ||
+		    (mrt->mroute_do_pim ||
 		     cache->mfc_un.res.ttls[true_vifi] < 255) &&
 		    time_after(jiffies,
 			       cache->mfc_un.res.last_assert + MFC_ASSERT_THRESH)) {
 			cache->mfc_un.res.last_assert = jiffies;
-			ipmr_cache_report(net, skb, true_vifi, IGMPMSG_WRONGVIF);
+			ipmr_cache_report(mrt, skb, true_vifi, IGMPMSG_WRONGVIF);
 		}
 		goto dont_forward;
 	}
 
-	net->ipv4.vif_table[vif].pkt_in++;
-	net->ipv4.vif_table[vif].bytes_in += skb->len;
+	mrt->vif_table[vif].pkt_in++;
+	mrt->vif_table[vif].bytes_in += skb->len;
 
 	/*
 	 *	Forward the frame
@@ -1386,7 +1411,8 @@ static int ip_mr_forward(struct net *net, struct sk_buff *skb,
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2)
-					ipmr_queue_xmit(net, skb2, cache, psend);
+					ipmr_queue_xmit(net, mrt, skb2, cache,
+							psend);
 			}
 			psend = ct;
 		}
@@ -1395,9 +1421,9 @@ static int ip_mr_forward(struct net *net, struct sk_buff *skb,
 		if (local) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2)
-				ipmr_queue_xmit(net, skb2, cache, psend);
+				ipmr_queue_xmit(net, mrt, skb2, cache, psend);
 		} else {
-			ipmr_queue_xmit(net, skb, cache, psend);
+			ipmr_queue_xmit(net, mrt, skb, cache, psend);
 			return 0;
 		}
 	}
@@ -1417,6 +1443,7 @@ int ip_mr_input(struct sk_buff *skb)
 {
 	struct mfc_cache *cache;
 	struct net *net = dev_net(skb->dev);
+	struct mr_table *mrt = net->ipv4.mrt;
 	int local = skb_rtable(skb)->rt_flags & RTCF_LOCAL;
 
 	/* Packet is looped back after forward, it should not be
@@ -1437,9 +1464,9 @@ int ip_mr_input(struct sk_buff *skb)
 			       that we can forward NO IGMP messages.
 			     */
 			    read_lock(&mrt_lock);
-			    if (net->ipv4.mroute_sk) {
+			    if (mrt->mroute_sk) {
 				    nf_reset(skb);
-				    raw_rcv(net->ipv4.mroute_sk, skb);
+				    raw_rcv(mrt->mroute_sk, skb);
 				    read_unlock(&mrt_lock);
 				    return 0;
 			    }
@@ -1448,7 +1475,7 @@ int ip_mr_input(struct sk_buff *skb)
 	}
 
 	read_lock(&mrt_lock);
-	cache = ipmr_cache_find(net, ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
+	cache = ipmr_cache_find(mrt, ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
 
 	/*
 	 *	No usable cache entry
@@ -1466,9 +1493,9 @@ int ip_mr_input(struct sk_buff *skb)
 			skb = skb2;
 		}
 
-		vif = ipmr_find_vif(skb->dev);
+		vif = ipmr_find_vif(mrt, skb->dev);
 		if (vif >= 0) {
-			int err = ipmr_cache_unresolved(net, vif, skb);
+			int err = ipmr_cache_unresolved(mrt, vif, skb);
 			read_unlock(&mrt_lock);
 
 			return err;
@@ -1478,7 +1505,7 @@ int ip_mr_input(struct sk_buff *skb)
 		return -ENODEV;
 	}
 
-	ip_mr_forward(net, skb, cache, local);
+	ip_mr_forward(net, mrt, skb, cache, local);
 
 	read_unlock(&mrt_lock);
 
@@ -1500,6 +1527,7 @@ static int __pim_rcv(struct sk_buff *skb, unsigned int pimlen)
 	struct net_device *reg_dev = NULL;
 	struct iphdr *encap;
 	struct net *net = dev_net(skb->dev);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
 	/*
@@ -1514,8 +1542,8 @@ static int __pim_rcv(struct sk_buff *skb, unsigned int pimlen)
 		return 1;
 
 	read_lock(&mrt_lock);
-	if (net->ipv4.mroute_reg_vif_num >= 0)
-		reg_dev = net->ipv4.vif_table[net->ipv4.mroute_reg_vif_num].dev;
+	if (mrt->mroute_reg_vif_num >= 0)
+		reg_dev = mrt->vif_table[mrt->mroute_reg_vif_num].dev;
 	if (reg_dev)
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
@@ -1550,13 +1578,14 @@ int pim_rcv_v1(struct sk_buff * skb)
 {
 	struct igmphdr *pim;
 	struct net *net = dev_net(skb->dev);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(struct iphdr)))
 		goto drop;
 
 	pim = igmp_hdr(skb);
 
-	if (!net->ipv4.mroute_do_pim ||
+	if (!mrt->mroute_do_pim ||
 	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;
 
@@ -1592,7 +1621,7 @@ drop:
 #endif
 
 static int
-ipmr_fill_mroute(struct net *net, struct sk_buff *skb, struct mfc_cache *c,
+ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb, struct mfc_cache *c,
 		 struct rtmsg *rtm)
 {
 	int ct;
@@ -1604,19 +1633,19 @@ ipmr_fill_mroute(struct net *net, struct sk_buff *skb, struct mfc_cache *c,
 	if (c->mfc_parent > MAXVIFS)
 		return -ENOENT;
 
-	if (VIF_EXISTS(net, c->mfc_parent))
-		RTA_PUT(skb, RTA_IIF, 4, &net->ipv4.vif_table[c->mfc_parent].dev->ifindex);
+	if (VIF_EXISTS(mrt, c->mfc_parent))
+		RTA_PUT(skb, RTA_IIF, 4, &mrt->vif_table[c->mfc_parent].dev->ifindex);
 
 	mp_head = (struct rtattr *)skb_put(skb, RTA_LENGTH(0));
 
 	for (ct = c->mfc_un.res.minvif; ct < c->mfc_un.res.maxvif; ct++) {
-		if (VIF_EXISTS(net, ct) && c->mfc_un.res.ttls[ct] < 255) {
+		if (VIF_EXISTS(mrt, ct) && c->mfc_un.res.ttls[ct] < 255) {
 			if (skb_tailroom(skb) < RTA_ALIGN(RTA_ALIGN(sizeof(*nhp)) + 4))
 				goto rtattr_failure;
 			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
 			nhp->rtnh_flags = 0;
 			nhp->rtnh_hops = c->mfc_un.res.ttls[ct];
-			nhp->rtnh_ifindex = net->ipv4.vif_table[ct].dev->ifindex;
+			nhp->rtnh_ifindex = mrt->vif_table[ct].dev->ifindex;
 			nhp->rtnh_len = sizeof(*nhp);
 		}
 	}
@@ -1634,11 +1663,12 @@ int ipmr_get_route(struct net *net,
 		   struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 {
 	int err;
+	struct mr_table *mrt = net->ipv4.mrt;
 	struct mfc_cache *cache;
 	struct rtable *rt = skb_rtable(skb);
 
 	read_lock(&mrt_lock);
-	cache = ipmr_cache_find(net, rt->rt_src, rt->rt_dst);
+	cache = ipmr_cache_find(mrt, rt->rt_src, rt->rt_dst);
 
 	if (cache == NULL) {
 		struct sk_buff *skb2;
@@ -1652,7 +1682,7 @@ int ipmr_get_route(struct net *net,
 		}
 
 		dev = skb->dev;
-		if (dev == NULL || (vif = ipmr_find_vif(dev)) < 0) {
+		if (dev == NULL || (vif = ipmr_find_vif(mrt, dev)) < 0) {
 			read_unlock(&mrt_lock);
 			return -ENODEV;
 		}
@@ -1669,14 +1699,14 @@ int ipmr_get_route(struct net *net,
 		iph->saddr = rt->rt_src;
 		iph->daddr = rt->rt_dst;
 		iph->version = 0;
-		err = ipmr_cache_unresolved(net, vif, skb2);
+		err = ipmr_cache_unresolved(mrt, vif, skb2);
 		read_unlock(&mrt_lock);
 		return err;
 	}
 
 	if (!nowait && (rtm->rtm_flags&RTM_F_NOTIFY))
 		cache->mfc_flags |= MFC_NOTIFY;
-	err = ipmr_fill_mroute(net, skb, cache, rtm);
+	err = ipmr_fill_mroute(mrt, skb, cache, rtm);
 	read_unlock(&mrt_lock);
 	return err;
 }
@@ -1694,11 +1724,13 @@ static struct vif_device *ipmr_vif_seq_idx(struct net *net,
 					   struct ipmr_vif_iter *iter,
 					   loff_t pos)
 {
-	for (iter->ct = 0; iter->ct < net->ipv4.maxvif; ++iter->ct) {
-		if (!VIF_EXISTS(net, iter->ct))
+	struct mr_table *mrt = net->ipv4.mrt;
+
+	for (iter->ct = 0; iter->ct < mrt->maxvif; ++iter->ct) {
+		if (!VIF_EXISTS(mrt, iter->ct))
 			continue;
 		if (pos-- == 0)
-			return &net->ipv4.vif_table[iter->ct];
+			return &mrt->vif_table[iter->ct];
 	}
 	return NULL;
 }
@@ -1717,15 +1749,16 @@ static void *ipmr_vif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ipmr_vif_iter *iter = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
 		return ipmr_vif_seq_idx(net, iter, 0);
 
-	while (++iter->ct < net->ipv4.maxvif) {
-		if (!VIF_EXISTS(net, iter->ct))
+	while (++iter->ct < mrt->maxvif) {
+		if (!VIF_EXISTS(mrt, iter->ct))
 			continue;
-		return &net->ipv4.vif_table[iter->ct];
+		return &mrt->vif_table[iter->ct];
 	}
 	return NULL;
 }
@@ -1739,6 +1772,7 @@ static void ipmr_vif_seq_stop(struct seq_file *seq, void *v)
 static int ipmr_vif_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq_file_net(seq);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -1749,7 +1783,7 @@ static int ipmr_vif_seq_show(struct seq_file *seq, void *v)
 
 		seq_printf(seq,
 			   "%2Zd %-10s %8ld %7ld  %8ld %7ld %05X %08X %08X\n",
-			   vif - net->ipv4.vif_table,
+			   vif - mrt->vif_table,
 			   name, vif->bytes_in, vif->pkt_in,
 			   vif->bytes_out, vif->pkt_out,
 			   vif->flags, vif->local, vif->remote);
@@ -1788,11 +1822,12 @@ struct ipmr_mfc_iter {
 static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
 					  struct ipmr_mfc_iter *it, loff_t pos)
 {
+	struct mr_table *mrt = net->ipv4.mrt;
 	struct mfc_cache *mfc;
 
 	read_lock(&mrt_lock);
 	for (it->ct = 0; it->ct < MFC_LINES; it->ct++) {
-		it->cache = &net->ipv4.mfc_cache_array[it->ct];
+		it->cache = &mrt->mfc_cache_array[it->ct];
 		list_for_each_entry(mfc, it->cache, list)
 			if (pos-- == 0)
 				return mfc;
@@ -1800,7 +1835,7 @@ static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
 	read_unlock(&mrt_lock);
 
 	spin_lock_bh(&mfc_unres_lock);
-	it->cache = &net->ipv4.mfc_unres_queue;
+	it->cache = &mrt->mfc_unres_queue;
 	list_for_each_entry(mfc, it->cache, list)
 		if (pos-- == 0)
 			return mfc;
@@ -1827,6 +1862,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct mfc_cache *mfc = v;
 	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	++*pos;
 
@@ -1836,13 +1872,13 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (mfc->list.next != it->cache)
 		return list_entry(mfc->list.next, struct mfc_cache, list);
 
-	if (it->cache == &net->ipv4.mfc_unres_queue)
+	if (it->cache == &mrt->mfc_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != &net->ipv4.mfc_cache_array[it->ct]);
+	BUG_ON(it->cache != &mrt->mfc_cache_array[it->ct]);
 
 	while (++it->ct < MFC_LINES) {
-		it->cache = &net->ipv4.mfc_cache_array[it->ct];
+		it->cache = &mrt->mfc_cache_array[it->ct];
 		if (list_empty(it->cache))
 			continue;
 		return list_first_entry(it->cache, struct mfc_cache, list);
@@ -1850,7 +1886,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	/* exhausted cache_array, show unresolved */
 	read_unlock(&mrt_lock);
-	it->cache = &net->ipv4.mfc_unres_queue;
+	it->cache = &mrt->mfc_unres_queue;
 	it->ct = 0;
 
 	spin_lock_bh(&mfc_unres_lock);
@@ -1868,10 +1904,11 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 {
 	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct mr_table *mrt = net->ipv4.mrt;
 
-	if (it->cache == &net->ipv4.mfc_unres_queue)
+	if (it->cache == &mrt->mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == &net->ipv4.mfc_cache_array[it->ct])
+	else if (it->cache == &mrt->mfc_cache_array[it->ct])
 		read_unlock(&mrt_lock);
 }
 
@@ -1879,6 +1916,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 {
 	int n;
 	struct net *net = seq_file_net(seq);
+	struct mr_table *mrt = net->ipv4.mrt;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
@@ -1892,14 +1930,14 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 			   (unsigned long) mfc->mfc_origin,
 			   mfc->mfc_parent);
 
-		if (it->cache != &net->ipv4.mfc_unres_queue) {
+		if (it->cache != &mrt->mfc_unres_queue) {
 			seq_printf(seq, " %8lu %8lu %8lu",
 				   mfc->mfc_un.res.pkt,
 				   mfc->mfc_un.res.bytes,
 				   mfc->mfc_un.res.wrong_if);
 			for (n = mfc->mfc_un.res.minvif;
 			     n < mfc->mfc_un.res.maxvif; n++ ) {
-				if (VIF_EXISTS(net, n) &&
+				if (VIF_EXISTS(mrt, n) &&
 				    mfc->mfc_un.res.ttls[n] < 255)
 					seq_printf(seq,
 					   " %2d:%-3d",
@@ -1951,35 +1989,27 @@ static const struct net_protocol pim_protocol = {
  */
 static int __net_init ipmr_net_init(struct net *net)
 {
+	struct mr_table *mrt;
 	unsigned int i;
 	int err = 0;
 
-	net->ipv4.vif_table = kcalloc(MAXVIFS, sizeof(struct vif_device),
-				      GFP_KERNEL);
-	if (!net->ipv4.vif_table) {
+	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
+	if (mrt == NULL) {
 		err = -ENOMEM;
 		goto fail;
 	}
 
 	/* Forwarding cache */
-	net->ipv4.mfc_cache_array = kcalloc(MFC_LINES,
-					    sizeof(struct list_head),
-					    GFP_KERNEL);
-	if (!net->ipv4.mfc_cache_array) {
-		err = -ENOMEM;
-		goto fail_mfc_cache;
-	}
-
 	for (i = 0; i < MFC_LINES; i++)
-		INIT_LIST_HEAD(&net->ipv4.mfc_cache_array[i]);
+		INIT_LIST_HEAD(&mrt->mfc_cache_array[i]);
 
-	INIT_LIST_HEAD(&net->ipv4.mfc_unres_queue);
+	INIT_LIST_HEAD(&mrt->mfc_unres_queue);
 
-	setup_timer(&net->ipv4.ipmr_expire_timer, ipmr_expire_process,
+	setup_timer(&mrt->ipmr_expire_timer, ipmr_expire_process,
 		    (unsigned long)net);
 
 #ifdef CONFIG_IP_PIMSM
-	net->ipv4.mroute_reg_vif_num = -1;
+	mrt->mroute_reg_vif_num = -1;
 #endif
 
 #ifdef CONFIG_PROC_FS
@@ -1989,16 +2019,16 @@ static int __net_init ipmr_net_init(struct net *net)
 	if (!proc_net_fops_create(net, "ip_mr_cache", 0, &ipmr_mfc_fops))
 		goto proc_cache_fail;
 #endif
+
+	net->ipv4.mrt = mrt;
 	return 0;
 
 #ifdef CONFIG_PROC_FS
 proc_cache_fail:
 	proc_net_remove(net, "ip_mr_vif");
 proc_vif_fail:
-	kfree(net->ipv4.mfc_cache_array);
+	kfree(mrt);
 #endif
-fail_mfc_cache:
-	kfree(net->ipv4.vif_table);
 fail:
 	return err;
 }
@@ -2009,8 +2039,7 @@ static void __net_exit ipmr_net_exit(struct net *net)
 	proc_net_remove(net, "ip_mr_cache");
 	proc_net_remove(net, "ip_mr_vif");
 #endif
-	kfree(net->ipv4.mfc_cache_array);
-	kfree(net->ipv4.vif_table);
+	kfree(net->ipv4.mrt);
 }
 
 static struct pernet_operations ipmr_net_ops = {
-- 
1.7.0.4

