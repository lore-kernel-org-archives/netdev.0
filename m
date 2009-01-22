From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 9/9] netns: ipmr: enable namespace support in ipv4 multicast
 routing code
Date: Thu, 22 Jan 2009 15:56:23 +0100
Message-ID: <20090122145616.726473370@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:59587 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbZAVO6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:58:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This last patch makes the appropriate changes to use and propagate the
network namespace where needed in IPv4 multicast routing code.

This consists mainly in replacing all the remaining init_net occurences
with current netns pointer retrieved from sockets, net devices or 
mfc_caches depending on the routines' contexts.

Some routines receive a new 'struct net' parameter to propagate the current
netns:
* vif_add/vif_delete
* ipmr_new_tunnel
* mroute_clean_tables
* ipmr_cache_find
* ipmr_cache_report
* ipmr_cache_unresolved
* ipmr_mfc_add/ipmr_mfc_delete
* ipmr_get_route
* rt_fill_info (in route.c)

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/linux/mroute.h |    3 
 net/ipv4/ipmr.c        |  243 +++++++++++++++++++++++++++----------------------
 net/ipv4/route.c       |   11 +-
 3 files changed, 143 insertions(+), 114 deletions(-)

Index: net-next-2.6/include/linux/mroute.h
===================================================================
--- net-next-2.6.orig/include/linux/mroute.h
+++ net-next-2.6/include/linux/mroute.h
@@ -256,7 +256,8 @@ void mfc_net_set(struct mfc_cache *mfc, 
 
 #ifdef __KERNEL__
 struct rtmsg;
-extern int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait);
+extern int ipmr_get_route(struct net *net, struct sk_buff *skb,
+			  struct rtmsg *rtm, int nowait);
 #endif
 
 #endif
Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -95,7 +95,8 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 static struct kmem_cache *mrt_cachep __read_mostly;
 
 static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local);
-static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert);
+static int ipmr_cache_report(struct net *net,
+			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm);
 
 #ifdef CONFIG_IP_PIMSM_V2
@@ -108,9 +109,11 @@ static struct timer_list ipmr_expire_tim
 
 static void ipmr_del_tunnel(struct net_device *dev, struct vifctl *v)
 {
+	struct net *net = dev_net(dev);
+
 	dev_close(dev);
 
-	dev = __dev_get_by_name(&init_net, "tunl0");
+	dev = __dev_get_by_name(net, "tunl0");
 	if (dev) {
 		const struct net_device_ops *ops = dev->netdev_ops;
 		struct ifreq ifr;
@@ -136,11 +139,11 @@ static void ipmr_del_tunnel(struct net_d
 }
 
 static
-struct net_device *ipmr_new_tunnel(struct vifctl *v)
+struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 {
 	struct net_device  *dev;
 
-	dev = __dev_get_by_name(&init_net, "tunl0");
+	dev = __dev_get_by_name(net, "tunl0");
 
 	if (dev) {
 		const struct net_device_ops *ops = dev->netdev_ops;
@@ -169,7 +172,8 @@ struct net_device *ipmr_new_tunnel(struc
 
 		dev = NULL;
 
-		if (err == 0 && (dev = __dev_get_by_name(&init_net, p.name)) != NULL) {
+		if (err == 0 &&
+		    (dev = __dev_get_by_name(net, p.name)) != NULL) {
 			dev->flags |= IFF_MULTICAST;
 
 			in_dev = __in_dev_get_rtnl(dev);
@@ -199,10 +203,13 @@ failure:
 
 static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	struct net *net = dev_net(dev);
+
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
-	ipmr_cache_report(skb, init_net.ipv4.mroute_reg_vif_num, IGMPMSG_WHOLEPKT);
+	ipmr_cache_report(net, skb, net->ipv4.mroute_reg_vif_num,
+			  IGMPMSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
 	return 0;
@@ -269,16 +276,16 @@ failure:
  *	@notify: Set to 1, if the caller is a notifier_call
  */
 
-static int vif_delete(int vifi, int notify)
+static int vif_delete(struct net *net, int vifi, int notify)
 {
 	struct vif_device *v;
 	struct net_device *dev;
 	struct in_device *in_dev;
 
-	if (vifi < 0 || vifi >= init_net.ipv4.maxvif)
+	if (vifi < 0 || vifi >= net->ipv4.maxvif)
 		return -EADDRNOTAVAIL;
 
-	v = &init_net.ipv4.vif_table[vifi];
+	v = &net->ipv4.vif_table[vifi];
 
 	write_lock_bh(&mrt_lock);
 	dev = v->dev;
@@ -290,17 +297,17 @@ static int vif_delete(int vifi, int noti
 	}
 
 #ifdef CONFIG_IP_PIMSM
-	if (vifi == init_net.ipv4.mroute_reg_vif_num)
-		init_net.ipv4.mroute_reg_vif_num = -1;
+	if (vifi == net->ipv4.mroute_reg_vif_num)
+		net->ipv4.mroute_reg_vif_num = -1;
 #endif
 
-	if (vifi+1 == init_net.ipv4.maxvif) {
+	if (vifi+1 == net->ipv4.maxvif) {
 		int tmp;
 		for (tmp=vifi-1; tmp>=0; tmp--) {
-			if (VIF_EXISTS(&init_net, tmp))
+			if (VIF_EXISTS(net, tmp))
 				break;
 		}
-		init_net.ipv4.maxvif = tmp+1;
+		net->ipv4.maxvif = tmp+1;
 	}
 
 	write_unlock_bh(&mrt_lock);
@@ -333,8 +340,9 @@ static void ipmr_destroy_unres(struct mf
 {
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
+	struct net *net = mfc_net(c);
 
-	atomic_dec(&init_net.ipv4.cache_resolve_queue_len);
+	atomic_dec(&net->ipv4.cache_resolve_queue_len);
 
 	while ((skb = skb_dequeue(&c->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
@@ -346,7 +354,7 @@ static void ipmr_destroy_unres(struct mf
 			e->error = -ETIMEDOUT;
 			memset(&e->msg, 0, sizeof(e->msg));
 
-			rtnl_unicast(skb, &init_net, NETLINK_CB(skb).pid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
 		} else
 			kfree_skb(skb);
 	}
@@ -401,13 +409,14 @@ out:
 static void ipmr_update_thresholds(struct mfc_cache *cache, unsigned char *ttls)
 {
 	int vifi;
+	struct net *net = mfc_net(cache);
 
 	cache->mfc_un.res.minvif = MAXVIFS;
 	cache->mfc_un.res.maxvif = 0;
 	memset(cache->mfc_un.res.ttls, 255, MAXVIFS);
 
-	for (vifi = 0; vifi < init_net.ipv4.maxvif; vifi++) {
-		if (VIF_EXISTS(&init_net, vifi) &&
+	for (vifi = 0; vifi < net->ipv4.maxvif; vifi++) {
+		if (VIF_EXISTS(net, vifi) &&
 		    ttls[vifi] && ttls[vifi] < 255) {
 			cache->mfc_un.res.ttls[vifi] = ttls[vifi];
 			if (cache->mfc_un.res.minvif > vifi)
@@ -418,16 +427,16 @@ static void ipmr_update_thresholds(struc
 	}
 }
 
-static int vif_add(struct vifctl *vifc, int mrtsock)
+static int vif_add(struct net *net, struct vifctl *vifc, int mrtsock)
 {
 	int vifi = vifc->vifc_vifi;
-	struct vif_device *v = &init_net.ipv4.vif_table[vifi];
+	struct vif_device *v = &net->ipv4.vif_table[vifi];
 	struct net_device *dev;
 	struct in_device *in_dev;
 	int err;
 
 	/* Is vif busy ? */
-	if (VIF_EXISTS(&init_net, vifi))
+	if (VIF_EXISTS(net, vifi))
 		return -EADDRINUSE;
 
 	switch (vifc->vifc_flags) {
@@ -437,7 +446,7 @@ static int vif_add(struct vifctl *vifc, 
 		 * Special Purpose VIF in PIM
 		 * All the packets will be sent to the daemon
 		 */
-		if (init_net.ipv4.mroute_reg_vif_num >= 0)
+		if (net->ipv4.mroute_reg_vif_num >= 0)
 			return -EADDRINUSE;
 		dev = ipmr_reg_vif();
 		if (!dev)
@@ -451,7 +460,7 @@ static int vif_add(struct vifctl *vifc, 
 		break;
 #endif
 	case VIFF_TUNNEL:
-		dev = ipmr_new_tunnel(vifc);
+		dev = ipmr_new_tunnel(net, vifc);
 		if (!dev)
 			return -ENOBUFS;
 		err = dev_set_allmulti(dev, 1);
@@ -462,7 +471,7 @@ static int vif_add(struct vifctl *vifc, 
 		}
 		break;
 	case 0:
-		dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
+		dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);
 		if (!dev)
 			return -EADDRNOTAVAIL;
 		err = dev_set_allmulti(dev, 1);
@@ -503,20 +512,22 @@ static int vif_add(struct vifctl *vifc, 
 	v->dev = dev;
 #ifdef CONFIG_IP_PIMSM
 	if (v->flags&VIFF_REGISTER)
-		init_net.ipv4.mroute_reg_vif_num = vifi;
+		net->ipv4.mroute_reg_vif_num = vifi;
 #endif
-	if (vifi+1 > init_net.ipv4.maxvif)
-		init_net.ipv4.maxvif = vifi+1;
+	if (vifi+1 > net->ipv4.maxvif)
+		net->ipv4.maxvif = vifi+1;
 	write_unlock_bh(&mrt_lock);
 	return 0;
 }
 
-static struct mfc_cache *ipmr_cache_find(__be32 origin, __be32 mcastgrp)
+static struct mfc_cache *ipmr_cache_find(struct net *net,
+					 __be32 origin,
+					 __be32 mcastgrp)
 {
 	int line = MFC_HASH(mcastgrp, origin);
 	struct mfc_cache *c;
 
-	for (c = init_net.ipv4.mfc_cache_array[line]; c; c = c->next) {
+	for (c = net->ipv4.mfc_cache_array[line]; c; c = c->next) {
 		if (c->mfc_origin==origin && c->mfc_mcastgrp==mcastgrp)
 			break;
 	}
@@ -576,7 +587,7 @@ static void ipmr_cache_resolve(struct mf
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
 
-			rtnl_unicast(skb, &init_net, NETLINK_CB(skb).pid);
+			rtnl_unicast(skb, mfc_net(c), NETLINK_CB(skb).pid);
 		} else
 			ip_mr_forward(skb, c, 0);
 	}
@@ -589,7 +600,8 @@ static void ipmr_cache_resolve(struct mf
  *	Called under mrt_lock.
  */
 
-static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
+static int ipmr_cache_report(struct net *net,
+			     struct sk_buff *pkt, vifi_t vifi, int assert)
 {
 	struct sk_buff *skb;
 	const int ihl = ip_hdrlen(pkt);
@@ -621,7 +633,7 @@ static int ipmr_cache_report(struct sk_b
 		memcpy(msg, skb_network_header(pkt), sizeof(struct iphdr));
 		msg->im_msgtype = IGMPMSG_WHOLEPKT;
 		msg->im_mbz = 0;
-		msg->im_vif = init_net.ipv4.mroute_reg_vif_num;
+		msg->im_vif = net->ipv4.mroute_reg_vif_num;
 		ip_hdr(skb)->ihl = sizeof(struct iphdr) >> 2;
 		ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(pkt)->tot_len) +
 					     sizeof(struct iphdr));
@@ -653,7 +665,7 @@ static int ipmr_cache_report(struct sk_b
 	skb->transport_header = skb->network_header;
 	}
 
-	if (init_net.ipv4.mroute_sk == NULL) {
+	if (net->ipv4.mroute_sk == NULL) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -661,7 +673,7 @@ static int ipmr_cache_report(struct sk_b
 	/*
 	 *	Deliver to mrouted
 	 */
-	ret = sock_queue_rcv_skb(init_net.ipv4.mroute_sk, skb);
+	ret = sock_queue_rcv_skb(net->ipv4.mroute_sk, skb);
 	if (ret < 0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "mroute: pending queue full, dropping entries.\n");
@@ -676,7 +688,7 @@ static int ipmr_cache_report(struct sk_b
  */
 
 static int
-ipmr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
+ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 {
 	int err;
 	struct mfc_cache *c;
@@ -684,7 +696,7 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 
 	spin_lock_bh(&mfc_unres_lock);
 	for (c=mfc_unres_queue; c; c=c->next) {
-		if (net_eq(mfc_net(c), &init_net) &&
+		if (net_eq(mfc_net(c), net) &&
 		    c->mfc_mcastgrp == iph->daddr &&
 		    c->mfc_origin == iph->saddr)
 			break;
@@ -695,8 +707,8 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 		 *	Create a new entry if allowable
 		 */
 
-		if (atomic_read(&init_net.ipv4.cache_resolve_queue_len) >= 10 ||
-		    (c = ipmr_cache_alloc_unres(&init_net)) == NULL) {
+		if (atomic_read(&net->ipv4.cache_resolve_queue_len) >= 10 ||
+		    (c = ipmr_cache_alloc_unres(net)) == NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
 
 			kfree_skb(skb);
@@ -713,7 +725,8 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 		/*
 		 *	Reflect first query at mrouted.
 		 */
-		if ((err = ipmr_cache_report(skb, vifi, IGMPMSG_NOCACHE))<0) {
+		err = ipmr_cache_report(net, skb, vifi, IGMPMSG_NOCACHE);
+		if (err < 0) {
 			/* If the report failed throw the cache entry
 			   out - Brad Parker
 			 */
@@ -724,7 +737,7 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 			return err;
 		}
 
-		atomic_inc(&init_net.ipv4.cache_resolve_queue_len);
+		atomic_inc(&net->ipv4.cache_resolve_queue_len);
 		c->next = mfc_unres_queue;
 		mfc_unres_queue = c;
 
@@ -750,14 +763,14 @@ ipmr_cache_unresolved(vifi_t vifi, struc
  *	MFC cache manipulation by user space mroute daemon
  */
 
-static int ipmr_mfc_delete(struct mfcctl *mfc)
+static int ipmr_mfc_delete(struct net *net, struct mfcctl *mfc)
 {
 	int line;
 	struct mfc_cache *c, **cp;
 
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	for (cp = &init_net.ipv4.mfc_cache_array[line];
+	for (cp = &net->ipv4.mfc_cache_array[line];
 	     (c = *cp) != NULL; cp = &c->next) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
@@ -772,14 +785,14 @@ static int ipmr_mfc_delete(struct mfcctl
 	return -ENOENT;
 }
 
-static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
+static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 {
 	int line;
 	struct mfc_cache *uc, *c, **cp;
 
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	for (cp = &init_net.ipv4.mfc_cache_array[line];
+	for (cp = &net->ipv4.mfc_cache_array[line];
 	     (c = *cp) != NULL; cp = &c->next) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr)
@@ -799,7 +812,7 @@ static int ipmr_mfc_add(struct mfcctl *m
 	if (!ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
-	c = ipmr_cache_alloc(&init_net);
+	c = ipmr_cache_alloc(net);
 	if (c == NULL)
 		return -ENOMEM;
 
@@ -811,8 +824,8 @@ static int ipmr_mfc_add(struct mfcctl *m
 		c->mfc_flags |= MFC_STATIC;
 
 	write_lock_bh(&mrt_lock);
-	c->next = init_net.ipv4.mfc_cache_array[line];
-	init_net.ipv4.mfc_cache_array[line] = c;
+	c->next = net->ipv4.mfc_cache_array[line];
+	net->ipv4.mfc_cache_array[line] = c;
 	write_unlock_bh(&mrt_lock);
 
 	/*
@@ -822,11 +835,11 @@ static int ipmr_mfc_add(struct mfcctl *m
 	spin_lock_bh(&mfc_unres_lock);
 	for (cp = &mfc_unres_queue; (uc=*cp) != NULL;
 	     cp = &uc->next) {
-		if (net_eq(mfc_net(uc), &init_net) &&
+		if (net_eq(mfc_net(uc), net) &&
 		    uc->mfc_origin == c->mfc_origin &&
 		    uc->mfc_mcastgrp == c->mfc_mcastgrp) {
 			*cp = uc->next;
-			atomic_dec(&init_net.ipv4.cache_resolve_queue_len);
+			atomic_dec(&net->ipv4.cache_resolve_queue_len);
 			break;
 		}
 	}
@@ -845,16 +858,16 @@ static int ipmr_mfc_add(struct mfcctl *m
  *	Close the multicast socket, and clear the vif tables etc
  */
 
-static void mroute_clean_tables(struct sock *sk)
+static void mroute_clean_tables(struct net *net)
 {
 	int i;
 
 	/*
 	 *	Shut down all active vif entries
 	 */
-	for (i = 0; i < init_net.ipv4.maxvif; i++) {
-		if (!(init_net.ipv4.vif_table[i].flags&VIFF_STATIC))
-			vif_delete(i, 0);
+	for (i = 0; i < net->ipv4.maxvif; i++) {
+		if (!(net->ipv4.vif_table[i].flags&VIFF_STATIC))
+			vif_delete(net, i, 0);
 	}
 
 	/*
@@ -863,7 +876,7 @@ static void mroute_clean_tables(struct s
 	for (i=0; i<MFC_LINES; i++) {
 		struct mfc_cache *c, **cp;
 
-		cp = &init_net.ipv4.mfc_cache_array[i];
+		cp = &net->ipv4.mfc_cache_array[i];
 		while ((c = *cp) != NULL) {
 			if (c->mfc_flags&MFC_STATIC) {
 				cp = &c->next;
@@ -877,13 +890,13 @@ static void mroute_clean_tables(struct s
 		}
 	}
 
-	if (atomic_read(&init_net.ipv4.cache_resolve_queue_len) != 0) {
+	if (atomic_read(&net->ipv4.cache_resolve_queue_len) != 0) {
 		struct mfc_cache *c, **cp;
 
 		spin_lock_bh(&mfc_unres_lock);
 		cp = &mfc_unres_queue;
 		while ((c = *cp) != NULL) {
-			if (!net_eq(mfc_net(c), &init_net)) {
+			if (!net_eq(mfc_net(c), net)) {
 				cp = &c->next;
 				continue;
 			}
@@ -897,15 +910,17 @@ static void mroute_clean_tables(struct s
 
 static void mrtsock_destruct(struct sock *sk)
 {
+	struct net *net = sock_net(sk);
+
 	rtnl_lock();
-	if (sk == init_net.ipv4.mroute_sk) {
-		IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)--;
+	if (sk == net->ipv4.mroute_sk) {
+		IPV4_DEVCONF_ALL(net, MC_FORWARDING)--;
 
 		write_lock_bh(&mrt_lock);
-		init_net.ipv4.mroute_sk = NULL;
+		net->ipv4.mroute_sk = NULL;
 		write_unlock_bh(&mrt_lock);
 
-		mroute_clean_tables(sk);
+		mroute_clean_tables(net);
 	}
 	rtnl_unlock();
 }
@@ -922,9 +937,10 @@ int ip_mroute_setsockopt(struct sock *sk
 	int ret;
 	struct vifctl vif;
 	struct mfcctl mfc;
+	struct net *net = sock_net(sk);
 
 	if (optname != MRT_INIT) {
-		if (sk != init_net.ipv4.mroute_sk && !capable(CAP_NET_ADMIN))
+		if (sk != net->ipv4.mroute_sk && !capable(CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
@@ -937,7 +953,7 @@ int ip_mroute_setsockopt(struct sock *sk
 			return -ENOPROTOOPT;
 
 		rtnl_lock();
-		if (init_net.ipv4.mroute_sk) {
+		if (net->ipv4.mroute_sk) {
 			rtnl_unlock();
 			return -EADDRINUSE;
 		}
@@ -945,15 +961,15 @@ int ip_mroute_setsockopt(struct sock *sk
 		ret = ip_ra_control(sk, 1, mrtsock_destruct);
 		if (ret == 0) {
 			write_lock_bh(&mrt_lock);
-			init_net.ipv4.mroute_sk = sk;
+			net->ipv4.mroute_sk = sk;
 			write_unlock_bh(&mrt_lock);
 
-			IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)++;
+			IPV4_DEVCONF_ALL(net, MC_FORWARDING)++;
 		}
 		rtnl_unlock();
 		return ret;
 	case MRT_DONE:
-		if (sk != init_net.ipv4.mroute_sk)
+		if (sk != net->ipv4.mroute_sk)
 			return -EACCES;
 		return ip_ra_control(sk, 0, NULL);
 	case MRT_ADD_VIF:
@@ -966,9 +982,9 @@ int ip_mroute_setsockopt(struct sock *sk
 			return -ENFILE;
 		rtnl_lock();
 		if (optname == MRT_ADD_VIF) {
-			ret = vif_add(&vif, sk == init_net.ipv4.mroute_sk);
+			ret = vif_add(net, &vif, sk == net->ipv4.mroute_sk);
 		} else {
-			ret = vif_delete(vif.vifc_vifi, 0);
+			ret = vif_delete(net, vif.vifc_vifi, 0);
 		}
 		rtnl_unlock();
 		return ret;
@@ -985,9 +1001,9 @@ int ip_mroute_setsockopt(struct sock *sk
 			return -EFAULT;
 		rtnl_lock();
 		if (optname == MRT_DEL_MFC)
-			ret = ipmr_mfc_delete(&mfc);
+			ret = ipmr_mfc_delete(net, &mfc);
 		else
-			ret = ipmr_mfc_add(&mfc, sk == init_net.ipv4.mroute_sk);
+			ret = ipmr_mfc_add(net, &mfc, sk == net->ipv4.mroute_sk);
 		rtnl_unlock();
 		return ret;
 		/*
@@ -998,7 +1014,7 @@ int ip_mroute_setsockopt(struct sock *sk
 		int v;
 		if (get_user(v,(int __user *)optval))
 			return -EFAULT;
-		init_net.ipv4.mroute_do_assert = (v) ? 1 : 0;
+		net->ipv4.mroute_do_assert = (v) ? 1 : 0;
 		return 0;
 	}
 #ifdef CONFIG_IP_PIMSM
@@ -1012,11 +1028,11 @@ int ip_mroute_setsockopt(struct sock *sk
 
 		rtnl_lock();
 		ret = 0;
-		if (v != init_net.ipv4.mroute_do_pim) {
-			init_net.ipv4.mroute_do_pim = v;
-			init_net.ipv4.mroute_do_assert = v;
+		if (v != net->ipv4.mroute_do_pim) {
+			net->ipv4.mroute_do_pim = v;
+			net->ipv4.mroute_do_assert = v;
 #ifdef CONFIG_IP_PIMSM_V2
-			if (init_net.ipv4.mroute_do_pim)
+			if (net->ipv4.mroute_do_pim)
 				ret = inet_add_protocol(&pim_protocol,
 							IPPROTO_PIM);
 			else
@@ -1047,6 +1063,7 @@ int ip_mroute_getsockopt(struct sock *sk
 {
 	int olr;
 	int val;
+	struct net *net = sock_net(sk);
 
 	if (optname != MRT_VERSION &&
 #ifdef CONFIG_IP_PIMSM
@@ -1068,10 +1085,10 @@ int ip_mroute_getsockopt(struct sock *sk
 		val = 0x0305;
 #ifdef CONFIG_IP_PIMSM
 	else if (optname == MRT_PIM)
-		val = init_net.ipv4.mroute_do_pim;
+		val = net->ipv4.mroute_do_pim;
 #endif
 	else
-		val = init_net.ipv4.mroute_do_assert;
+		val = net->ipv4.mroute_do_assert;
 	if (copy_to_user(optval, &val, olr))
 		return -EFAULT;
 	return 0;
@@ -1087,16 +1104,17 @@ int ipmr_ioctl(struct sock *sk, int cmd,
 	struct sioc_vif_req vr;
 	struct vif_device *vif;
 	struct mfc_cache *c;
+	struct net *net = sock_net(sk);
 
 	switch (cmd) {
 	case SIOCGETVIFCNT:
 		if (copy_from_user(&vr, arg, sizeof(vr)))
 			return -EFAULT;
-		if (vr.vifi >= init_net.ipv4.maxvif)
+		if (vr.vifi >= net->ipv4.maxvif)
 			return -EINVAL;
 		read_lock(&mrt_lock);
-		vif = &init_net.ipv4.vif_table[vr.vifi];
-		if (VIF_EXISTS(&init_net, vr.vifi)) {
+		vif = &net->ipv4.vif_table[vr.vifi];
+		if (VIF_EXISTS(net, vr.vifi)) {
 			vr.icount = vif->pkt_in;
 			vr.ocount = vif->pkt_out;
 			vr.ibytes = vif->bytes_in;
@@ -1114,7 +1132,7 @@ int ipmr_ioctl(struct sock *sk, int cmd,
 			return -EFAULT;
 
 		read_lock(&mrt_lock);
-		c = ipmr_cache_find(sr.src.s_addr, sr.grp.s_addr);
+		c = ipmr_cache_find(net, sr.src.s_addr, sr.grp.s_addr);
 		if (c) {
 			sr.pktcnt = c->mfc_un.res.pkt;
 			sr.bytecnt = c->mfc_un.res.bytes;
@@ -1136,18 +1154,19 @@ int ipmr_ioctl(struct sock *sk, int cmd,
 static int ipmr_device_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
+	struct net *net = dev_net(dev);
 	struct vif_device *v;
 	int ct;
 
-	if (!net_eq(dev_net(dev), &init_net))
+	if (!net_eq(dev_net(dev), net))
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
-	v = &init_net.ipv4.vif_table[0];
-	for (ct = 0; ct < init_net.ipv4.maxvif; ct++, v++) {
+	v = &net->ipv4.vif_table[0];
+	for (ct = 0; ct < net->ipv4.maxvif; ct++, v++) {
 		if (v->dev == dev)
-			vif_delete(ct, 1);
+			vif_delete(net, ct, 1);
 	}
 	return NOTIFY_DONE;
 }
@@ -1207,8 +1226,9 @@ static inline int ipmr_forward_finish(st
 
 static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 {
+	struct net *net = mfc_net(c);
 	const struct iphdr *iph = ip_hdr(skb);
-	struct vif_device *vif = &init_net.ipv4.vif_table[vifi];
+	struct vif_device *vif = &net->ipv4.vif_table[vifi];
 	struct net_device *dev;
 	struct rtable *rt;
 	int    encap = 0;
@@ -1222,7 +1242,7 @@ static void ipmr_queue_xmit(struct sk_bu
 		vif->bytes_out += skb->len;
 		vif->dev->stats.tx_bytes += skb->len;
 		vif->dev->stats.tx_packets++;
-		ipmr_cache_report(skb, vifi, IGMPMSG_WHOLEPKT);
+		ipmr_cache_report(net, skb, vifi, IGMPMSG_WHOLEPKT);
 		kfree_skb(skb);
 		return;
 	}
@@ -1235,7 +1255,7 @@ static void ipmr_queue_xmit(struct sk_bu
 						.saddr = vif->local,
 						.tos = RT_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
-		if (ip_route_output_key(&init_net, &rt, &fl))
+		if (ip_route_output_key(net, &rt, &fl))
 			goto out_free;
 		encap = sizeof(struct iphdr);
 	} else {
@@ -1244,7 +1264,7 @@ static void ipmr_queue_xmit(struct sk_bu
 					      { .daddr = iph->daddr,
 						.tos = RT_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
-		if (ip_route_output_key(&init_net, &rt, &fl))
+		if (ip_route_output_key(net, &rt, &fl))
 			goto out_free;
 	}
 
@@ -1308,9 +1328,10 @@ out_free:
 
 static int ipmr_find_vif(struct net_device *dev)
 {
+	struct net *net = dev_net(dev);
 	int ct;
-	for (ct = init_net.ipv4.maxvif-1; ct >= 0; ct--) {
-		if (init_net.ipv4.vif_table[ct].dev == dev)
+	for (ct = net->ipv4.maxvif-1; ct >= 0; ct--) {
+		if (net->ipv4.vif_table[ct].dev == dev)
 			break;
 	}
 	return ct;
@@ -1322,6 +1343,7 @@ static int ip_mr_forward(struct sk_buff 
 {
 	int psend = -1;
 	int vif, ct;
+	struct net *net = mfc_net(cache);
 
 	vif = cache->mfc_parent;
 	cache->mfc_un.res.pkt++;
@@ -1330,7 +1352,7 @@ static int ip_mr_forward(struct sk_buff 
 	/*
 	 * Wrong interface: drop packet and (maybe) send PIM assert.
 	 */
-	if (init_net.ipv4.vif_table[vif].dev != skb->dev) {
+	if (net->ipv4.vif_table[vif].dev != skb->dev) {
 		int true_vifi;
 
 		if (skb->rtable->fl.iif == 0) {
@@ -1351,24 +1373,24 @@ static int ip_mr_forward(struct sk_buff 
 		cache->mfc_un.res.wrong_if++;
 		true_vifi = ipmr_find_vif(skb->dev);
 
-		if (true_vifi >= 0 && init_net.ipv4.mroute_do_assert &&
+		if (true_vifi >= 0 && net->ipv4.mroute_do_assert &&
 		    /* pimsm uses asserts, when switching from RPT to SPT,
 		       so that we cannot check that packet arrived on an oif.
 		       It is bad, but otherwise we would need to move pretty
 		       large chunk of pimd to kernel. Ough... --ANK
 		     */
-		    (init_net.ipv4.mroute_do_pim ||
+		    (net->ipv4.mroute_do_pim ||
 		     cache->mfc_un.res.ttls[true_vifi] < 255) &&
 		    time_after(jiffies,
 			       cache->mfc_un.res.last_assert + MFC_ASSERT_THRESH)) {
 			cache->mfc_un.res.last_assert = jiffies;
-			ipmr_cache_report(skb, true_vifi, IGMPMSG_WRONGVIF);
+			ipmr_cache_report(net, skb, true_vifi, IGMPMSG_WRONGVIF);
 		}
 		goto dont_forward;
 	}
 
-	init_net.ipv4.vif_table[vif].pkt_in++;
-	init_net.ipv4.vif_table[vif].bytes_in += skb->len;
+	net->ipv4.vif_table[vif].pkt_in++;
+	net->ipv4.vif_table[vif].bytes_in += skb->len;
 
 	/*
 	 *	Forward the frame
@@ -1408,6 +1430,7 @@ dont_forward:
 int ip_mr_input(struct sk_buff *skb)
 {
 	struct mfc_cache *cache;
+	struct net *net = dev_net(skb->dev);
 	int local = skb->rtable->rt_flags&RTCF_LOCAL;
 
 	/* Packet is looped back after forward, it should not be
@@ -1428,9 +1451,9 @@ int ip_mr_input(struct sk_buff *skb)
 			       that we can forward NO IGMP messages.
 			     */
 			    read_lock(&mrt_lock);
-			    if (init_net.ipv4.mroute_sk) {
+			    if (net->ipv4.mroute_sk) {
 				    nf_reset(skb);
-				    raw_rcv(init_net.ipv4.mroute_sk, skb);
+				    raw_rcv(net->ipv4.mroute_sk, skb);
 				    read_unlock(&mrt_lock);
 				    return 0;
 			    }
@@ -1439,7 +1462,7 @@ int ip_mr_input(struct sk_buff *skb)
 	}
 
 	read_lock(&mrt_lock);
-	cache = ipmr_cache_find(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
+	cache = ipmr_cache_find(net, ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
 
 	/*
 	 *	No usable cache entry
@@ -1459,7 +1482,7 @@ int ip_mr_input(struct sk_buff *skb)
 
 		vif = ipmr_find_vif(skb->dev);
 		if (vif >= 0) {
-			int err = ipmr_cache_unresolved(vif, skb);
+			int err = ipmr_cache_unresolved(net, vif, skb);
 			read_unlock(&mrt_lock);
 
 			return err;
@@ -1490,6 +1513,7 @@ static int __pim_rcv(struct sk_buff *skb
 {
 	struct net_device *reg_dev = NULL;
 	struct iphdr *encap;
+	struct net *net = dev_net(skb->dev);
 
 	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
 	/*
@@ -1504,8 +1528,8 @@ static int __pim_rcv(struct sk_buff *skb
 		return 1;
 
 	read_lock(&mrt_lock);
-	if (init_net.ipv4.mroute_reg_vif_num >= 0)
-		reg_dev = init_net.ipv4.vif_table[init_net.ipv4.mroute_reg_vif_num].dev;
+	if (net->ipv4.mroute_reg_vif_num >= 0)
+		reg_dev = net->ipv4.vif_table[net->ipv4.mroute_reg_vif_num].dev;
 	if (reg_dev)
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
@@ -1540,13 +1564,14 @@ static int __pim_rcv(struct sk_buff *skb
 int pim_rcv_v1(struct sk_buff * skb)
 {
 	struct igmphdr *pim;
+	struct net *net = dev_net(skb->dev);
 
 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(struct iphdr)))
 		goto drop;
 
 	pim = igmp_hdr(skb);
 
-	if (!init_net.ipv4.mroute_do_pim ||
+	if (!net->ipv4.mroute_do_pim ||
 	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;
 
@@ -1586,7 +1611,8 @@ ipmr_fill_mroute(struct sk_buff *skb, st
 {
 	int ct;
 	struct rtnexthop *nhp;
-	struct net_device *dev = init_net.ipv4.vif_table[c->mfc_parent].dev;
+	struct net *net = mfc_net(c);
+	struct net_device *dev = net->ipv4.vif_table[c->mfc_parent].dev;
 	u8 *b = skb_tail_pointer(skb);
 	struct rtattr *mp_head;
 
@@ -1602,7 +1628,7 @@ ipmr_fill_mroute(struct sk_buff *skb, st
 			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
 			nhp->rtnh_flags = 0;
 			nhp->rtnh_hops = c->mfc_un.res.ttls[ct];
-			nhp->rtnh_ifindex = init_net.ipv4.vif_table[ct].dev->ifindex;
+			nhp->rtnh_ifindex = net->ipv4.vif_table[ct].dev->ifindex;
 			nhp->rtnh_len = sizeof(*nhp);
 		}
 	}
@@ -1616,14 +1642,15 @@ rtattr_failure:
 	return -EMSGSIZE;
 }
 
-int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait)
+int ipmr_get_route(struct net *net,
+		   struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 {
 	int err;
 	struct mfc_cache *cache;
 	struct rtable *rt = skb->rtable;
 
 	read_lock(&mrt_lock);
-	cache = ipmr_cache_find(rt->rt_src, rt->rt_dst);
+	cache = ipmr_cache_find(net, rt->rt_src, rt->rt_dst);
 
 	if (cache == NULL) {
 		struct sk_buff *skb2;
@@ -1654,7 +1681,7 @@ int ipmr_get_route(struct sk_buff *skb, 
 		iph->saddr = rt->rt_src;
 		iph->daddr = rt->rt_dst;
 		iph->version = 0;
-		err = ipmr_cache_unresolved(vif, skb2);
+		err = ipmr_cache_unresolved(net, vif, skb2);
 		read_unlock(&mrt_lock);
 		return err;
 	}
Index: net-next-2.6/net/ipv4/route.c
===================================================================
--- net-next-2.6.orig/net/ipv4/route.c
+++ net-next-2.6/net/ipv4/route.c
@@ -2779,7 +2779,8 @@ int ip_route_output_key(struct net *net,
 	return ip_route_output_flow(net, rp, flp, NULL, 0);
 }
 
-static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
+static int rt_fill_info(struct net *net,
+			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
 	struct rtable *rt = skb->rtable;
@@ -2844,8 +2845,8 @@ static int rt_fill_info(struct sk_buff *
 		__be32 dst = rt->rt_dst;
 
 		if (ipv4_is_multicast(dst) && !ipv4_is_local_multicast(dst) &&
-		    IPV4_DEVCONF_ALL(&init_net, MC_FORWARDING)) {
-			int err = ipmr_get_route(skb, r, nowait);
+		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
+			int err = ipmr_get_route(net, skb, r, nowait);
 			if (err <= 0) {
 				if (!nowait) {
 					if (err == 0)
@@ -2950,7 +2951,7 @@ static int inet_rtm_getroute(struct sk_b
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+	err = rt_fill_info(net, skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
 		goto errout_free;
@@ -2988,7 +2989,7 @@ int ip_rt_dump(struct sk_buff *skb,  str
 			if (rt_is_expired(rt))
 				continue;
 			skb->dst = dst_clone(&rt->u.dst);
-			if (rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
+			if (rt_fill_info(net, skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					 1, NLM_F_MULTI) <= 0) {
 				dst_release(xchg(&skb->dst, NULL));

