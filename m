From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 2/9] netns: ipmr: dynamically allocates vif_table
Date: Thu, 22 Jan 2009 15:56:16 +0100
Message-ID: <20090122145615.338217201@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58631 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbZAVO5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:57:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv6 multicast routing netns-aware.

Dynamically allocates interface table vif_table and moves it to 
struct netns_ipv4, and updates MIF_EXISTS() macro. 

At the moment, vif_table is only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

---
 include/net/netns/ipv4.h |    2 
 net/ipv4/ipmr.c          |  109 +++++++++++++++++++++++++++++------------------
 2 files changed, 70 insertions(+), 41 deletions(-)

Index: net-next-2.6/include/net/netns/ipv4.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv4.h
+++ net-next-2.6/include/net/netns/ipv4.h
@@ -57,6 +57,8 @@ struct netns_ipv4 {
 
 #ifdef CONFIG_IP_MROUTE
 	struct sock		*mroute_sk;
+	struct vif_device	*vif_table;
+	int			maxvif;
 #endif
 };
 #endif
Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -77,10 +77,7 @@ static DEFINE_RWLOCK(mrt_lock);
  *	Multicast router control variables
  */
 
-static struct vif_device vif_table[MAXVIFS];		/* Devices 		*/
-static int maxvif;
-
-#define VIF_EXISTS(idx) (vif_table[idx].dev != NULL)
+#define VIF_EXISTS(_net, _idx) ((_net)->ipv4.vif_table[_idx].dev != NULL)
 
 static int mroute_do_assert;				/* Set in PIM assert	*/
 static int mroute_do_pim;
@@ -286,10 +283,10 @@ static int vif_delete(int vifi, int noti
 	struct net_device *dev;
 	struct in_device *in_dev;
 
-	if (vifi < 0 || vifi >= maxvif)
+	if (vifi < 0 || vifi >= init_net.ipv4.maxvif)
 		return -EADDRNOTAVAIL;
 
-	v = &vif_table[vifi];
+	v = &init_net.ipv4.vif_table[vifi];
 
 	write_lock_bh(&mrt_lock);
 	dev = v->dev;
@@ -305,13 +302,13 @@ static int vif_delete(int vifi, int noti
 		reg_vif_num = -1;
 #endif
 
-	if (vifi+1 == maxvif) {
+	if (vifi+1 == init_net.ipv4.maxvif) {
 		int tmp;
 		for (tmp=vifi-1; tmp>=0; tmp--) {
-			if (VIF_EXISTS(tmp))
+			if (VIF_EXISTS(&init_net, tmp))
 				break;
 		}
-		maxvif = tmp+1;
+		init_net.ipv4.maxvif = tmp+1;
 	}
 
 	write_unlock_bh(&mrt_lock);
@@ -411,8 +408,9 @@ static void ipmr_update_thresholds(struc
 	cache->mfc_un.res.maxvif = 0;
 	memset(cache->mfc_un.res.ttls, 255, MAXVIFS);
 
-	for (vifi=0; vifi<maxvif; vifi++) {
-		if (VIF_EXISTS(vifi) && ttls[vifi] && ttls[vifi] < 255) {
+	for (vifi = 0; vifi < init_net.ipv4.maxvif; vifi++) {
+		if (VIF_EXISTS(&init_net, vifi) &&
+		    ttls[vifi] && ttls[vifi] < 255) {
 			cache->mfc_un.res.ttls[vifi] = ttls[vifi];
 			if (cache->mfc_un.res.minvif > vifi)
 				cache->mfc_un.res.minvif = vifi;
@@ -425,13 +423,13 @@ static void ipmr_update_thresholds(struc
 static int vif_add(struct vifctl *vifc, int mrtsock)
 {
 	int vifi = vifc->vifc_vifi;
-	struct vif_device *v = &vif_table[vifi];
+	struct vif_device *v = &init_net.ipv4.vif_table[vifi];
 	struct net_device *dev;
 	struct in_device *in_dev;
 	int err;
 
 	/* Is vif busy ? */
-	if (VIF_EXISTS(vifi))
+	if (VIF_EXISTS(&init_net, vifi))
 		return -EADDRINUSE;
 
 	switch (vifc->vifc_flags) {
@@ -509,8 +507,8 @@ static int vif_add(struct vifctl *vifc, 
 	if (v->flags&VIFF_REGISTER)
 		reg_vif_num = vifi;
 #endif
-	if (vifi+1 > maxvif)
-		maxvif = vifi+1;
+	if (vifi+1 > init_net.ipv4.maxvif)
+		init_net.ipv4.maxvif = vifi+1;
 	write_unlock_bh(&mrt_lock);
 	return 0;
 }
@@ -849,8 +847,8 @@ static void mroute_clean_tables(struct s
 	/*
 	 *	Shut down all active vif entries
 	 */
-	for (i=0; i<maxvif; i++) {
-		if (!(vif_table[i].flags&VIFF_STATIC))
+	for (i = 0; i < init_net.ipv4.maxvif; i++) {
+		if (!(init_net.ipv4.vif_table[i].flags&VIFF_STATIC))
 			vif_delete(i, 0);
 	}
 
@@ -1088,11 +1086,11 @@ int ipmr_ioctl(struct sock *sk, int cmd,
 	case SIOCGETVIFCNT:
 		if (copy_from_user(&vr, arg, sizeof(vr)))
 			return -EFAULT;
-		if (vr.vifi >= maxvif)
+		if (vr.vifi >= init_net.ipv4.maxvif)
 			return -EINVAL;
 		read_lock(&mrt_lock);
-		vif=&vif_table[vr.vifi];
-		if (VIF_EXISTS(vr.vifi))	{
+		vif = &init_net.ipv4.vif_table[vr.vifi];
+		if (VIF_EXISTS(&init_net, vr.vifi)) {
 			vr.icount = vif->pkt_in;
 			vr.ocount = vif->pkt_out;
 			vr.ibytes = vif->bytes_in;
@@ -1140,8 +1138,8 @@ static int ipmr_device_event(struct noti
 
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
-	v=&vif_table[0];
-	for (ct=0; ct<maxvif; ct++,v++) {
+	v = &init_net.ipv4.vif_table[0];
+	for (ct = 0; ct < init_net.ipv4.maxvif; ct++, v++) {
 		if (v->dev == dev)
 			vif_delete(ct, 1);
 	}
@@ -1204,7 +1202,7 @@ static inline int ipmr_forward_finish(st
 static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct vif_device *vif = &vif_table[vifi];
+	struct vif_device *vif = &init_net.ipv4.vif_table[vifi];
 	struct net_device *dev;
 	struct rtable *rt;
 	int    encap = 0;
@@ -1305,8 +1303,8 @@ out_free:
 static int ipmr_find_vif(struct net_device *dev)
 {
 	int ct;
-	for (ct=maxvif-1; ct>=0; ct--) {
-		if (vif_table[ct].dev == dev)
+	for (ct = init_net.ipv4.maxvif-1; ct >= 0; ct--) {
+		if (init_net.ipv4.vif_table[ct].dev == dev)
 			break;
 	}
 	return ct;
@@ -1326,7 +1324,7 @@ static int ip_mr_forward(struct sk_buff 
 	/*
 	 * Wrong interface: drop packet and (maybe) send PIM assert.
 	 */
-	if (vif_table[vif].dev != skb->dev) {
+	if (init_net.ipv4.vif_table[vif].dev != skb->dev) {
 		int true_vifi;
 
 		if (skb->rtable->fl.iif == 0) {
@@ -1362,8 +1360,8 @@ static int ip_mr_forward(struct sk_buff 
 		goto dont_forward;
 	}
 
-	vif_table[vif].pkt_in++;
-	vif_table[vif].bytes_in += skb->len;
+	init_net.ipv4.vif_table[vif].pkt_in++;
+	init_net.ipv4.vif_table[vif].bytes_in += skb->len;
 
 	/*
 	 *	Forward the frame
@@ -1500,7 +1498,7 @@ static int __pim_rcv(struct sk_buff *skb
 
 	read_lock(&mrt_lock);
 	if (reg_vif_num >= 0)
-		reg_dev = vif_table[reg_vif_num].dev;
+		reg_dev = init_net.ipv4.vif_table[reg_vif_num].dev;
 	if (reg_dev)
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
@@ -1581,7 +1579,7 @@ ipmr_fill_mroute(struct sk_buff *skb, st
 {
 	int ct;
 	struct rtnexthop *nhp;
-	struct net_device *dev = vif_table[c->mfc_parent].dev;
+	struct net_device *dev = init_net.ipv4.vif_table[c->mfc_parent].dev;
 	u8 *b = skb_tail_pointer(skb);
 	struct rtattr *mp_head;
 
@@ -1597,7 +1595,7 @@ ipmr_fill_mroute(struct sk_buff *skb, st
 			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
 			nhp->rtnh_flags = 0;
 			nhp->rtnh_hops = c->mfc_un.res.ttls[ct];
-			nhp->rtnh_ifindex = vif_table[ct].dev->ifindex;
+			nhp->rtnh_ifindex = init_net.ipv4.vif_table[ct].dev->ifindex;
 			nhp->rtnh_len = sizeof(*nhp);
 		}
 	}
@@ -1672,11 +1670,11 @@ struct ipmr_vif_iter {
 static struct vif_device *ipmr_vif_seq_idx(struct ipmr_vif_iter *iter,
 					   loff_t pos)
 {
-	for (iter->ct = 0; iter->ct < maxvif; ++iter->ct) {
-		if (!VIF_EXISTS(iter->ct))
+	for (iter->ct = 0; iter->ct < init_net.ipv4.maxvif; ++iter->ct) {
+		if (!VIF_EXISTS(&init_net, iter->ct))
 			continue;
 		if (pos-- == 0)
-			return &vif_table[iter->ct];
+			return &init_net.ipv4.vif_table[iter->ct];
 	}
 	return NULL;
 }
@@ -1697,10 +1695,10 @@ static void *ipmr_vif_seq_next(struct se
 	if (v == SEQ_START_TOKEN)
 		return ipmr_vif_seq_idx(iter, 0);
 
-	while (++iter->ct < maxvif) {
-		if (!VIF_EXISTS(iter->ct))
+	while (++iter->ct < init_net.ipv4.maxvif) {
+		if (!VIF_EXISTS(&init_net, iter->ct))
 			continue;
-		return &vif_table[iter->ct];
+		return &init_net.ipv4.vif_table[iter->ct];
 	}
 	return NULL;
 }
@@ -1722,7 +1720,7 @@ static int ipmr_vif_seq_show(struct seq_
 
 		seq_printf(seq,
 			   "%2Zd %-10s %8ld %7ld  %8ld %7ld %05X %08X %08X\n",
-			   vif - vif_table,
+			   vif - init_net.ipv4.vif_table,
 			   name, vif->bytes_in, vif->pkt_in,
 			   vif->bytes_out, vif->pkt_out,
 			   vif->flags, vif->local, vif->remote);
@@ -1864,9 +1862,9 @@ static int ipmr_mfc_seq_show(struct seq_
 				   mfc->mfc_un.res.wrong_if);
 			for (n = mfc->mfc_un.res.minvif;
 			     n < mfc->mfc_un.res.maxvif; n++ ) {
-				if (VIF_EXISTS(n)
-				   && mfc->mfc_un.res.ttls[n] < 255)
-				seq_printf(seq,
+				if (VIF_EXISTS(&init_net, n) &&
+				    mfc->mfc_un.res.ttls[n] < 255)
+					seq_printf(seq,
 					   " %2d:%-3d",
 					   n, mfc->mfc_un.res.ttls[n]);
 			}
@@ -1913,6 +1911,29 @@ static struct net_protocol pim_protocol 
 /*
  *	Setup for IP multicast routing
  */
+static int __net_init ipmr_net_init(struct net *net)
+{
+	int err = 0;
+
+	net->ipv4.vif_table = kcalloc(MAXVIFS, sizeof(struct vif_device),
+				      GFP_KERNEL);
+	if (!net->ipv4.vif_table) {
+		err = -ENOMEM;
+		goto fail;
+	}
+fail:
+	return err;
+}
+
+static void __net_exit ipmr_net_exit(struct net *net)
+{
+	kfree(net->ipv4.vif_table);
+}
+
+static struct pernet_operations ipmr_net_ops = {
+	.init = ipmr_net_init,
+	.exit = ipmr_net_exit,
+};
 
 int __init ip_mr_init(void)
 {
@@ -1925,6 +1946,10 @@ int __init ip_mr_init(void)
 	if (!mrt_cachep)
 		return -ENOMEM;
 
+	err = register_pernet_subsys(&ipmr_net_ops);
+	if (err)
+		goto reg_pernet_fail;
+
 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
 	err = register_netdevice_notifier(&ip_mr_notifier);
 	if (err)
@@ -1945,6 +1970,8 @@ proc_vif_fail:
 #endif
 reg_notif_fail:
 	del_timer(&ipmr_expire_timer);
+	unregister_pernet_subsys(&ipmr_net_ops);
+reg_pernet_fail:
 	kmem_cache_destroy(mrt_cachep);
 	return err;
 }

