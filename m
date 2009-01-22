From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 7/9] netns: ipmr: declare reg_vif_num per-namespace
Date: Thu, 22 Jan 2009 15:56:21 +0100
Message-ID: <20090122145616.329204373@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:59363 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548AbZAVO6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:58:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv4 multicast routing netns-aware.

Declare variable 'reg_vif_num' per-namespace, moves into struct netns_ipv4.

At the moment, this variable is only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv4.h |    3 +++
 net/ipv4/ipmr.c          |   22 ++++++++++++----------
 2 files changed, 15 insertions(+), 10 deletions(-)

Index: net-next-2.6/include/net/netns/ipv4.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv4.h
+++ net-next-2.6/include/net/netns/ipv4.h
@@ -63,6 +63,9 @@ struct netns_ipv4 {
 	atomic_t		cache_resolve_queue_len;
 	int			mroute_do_assert;
 	int			mroute_do_pim;
+#if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
+	int			mroute_reg_vif_num;
+#endif
 #endif
 };
 #endif
Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -197,14 +197,12 @@ failure:
 
 #ifdef CONFIG_IP_PIMSM
 
-static int reg_vif_num = -1;
-
 static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
-	ipmr_cache_report(skb, reg_vif_num, IGMPMSG_WHOLEPKT);
+	ipmr_cache_report(skb, init_net.ipv4.mroute_reg_vif_num, IGMPMSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
 	return 0;
@@ -292,8 +290,8 @@ static int vif_delete(int vifi, int noti
 	}
 
 #ifdef CONFIG_IP_PIMSM
-	if (vifi == reg_vif_num)
-		reg_vif_num = -1;
+	if (vifi == init_net.ipv4.mroute_reg_vif_num)
+		init_net.ipv4.mroute_reg_vif_num = -1;
 #endif
 
 	if (vifi+1 == init_net.ipv4.maxvif) {
@@ -439,7 +437,7 @@ static int vif_add(struct vifctl *vifc, 
 		 * Special Purpose VIF in PIM
 		 * All the packets will be sent to the daemon
 		 */
-		if (reg_vif_num >= 0)
+		if (init_net.ipv4.mroute_reg_vif_num >= 0)
 			return -EADDRINUSE;
 		dev = ipmr_reg_vif();
 		if (!dev)
@@ -505,7 +503,7 @@ static int vif_add(struct vifctl *vifc, 
 	v->dev = dev;
 #ifdef CONFIG_IP_PIMSM
 	if (v->flags&VIFF_REGISTER)
-		reg_vif_num = vifi;
+		init_net.ipv4.mroute_reg_vif_num = vifi;
 #endif
 	if (vifi+1 > init_net.ipv4.maxvif)
 		init_net.ipv4.maxvif = vifi+1;
@@ -623,7 +621,7 @@ static int ipmr_cache_report(struct sk_b
 		memcpy(msg, skb_network_header(pkt), sizeof(struct iphdr));
 		msg->im_msgtype = IGMPMSG_WHOLEPKT;
 		msg->im_mbz = 0;
-		msg->im_vif = reg_vif_num;
+		msg->im_vif = init_net.ipv4.mroute_reg_vif_num;
 		ip_hdr(skb)->ihl = sizeof(struct iphdr) >> 2;
 		ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(pkt)->tot_len) +
 					     sizeof(struct iphdr));
@@ -1506,8 +1504,8 @@ static int __pim_rcv(struct sk_buff *skb
 		return 1;
 
 	read_lock(&mrt_lock);
-	if (reg_vif_num >= 0)
-		reg_dev = init_net.ipv4.vif_table[reg_vif_num].dev;
+	if (init_net.ipv4.mroute_reg_vif_num >= 0)
+		reg_dev = init_net.ipv4.vif_table[init_net.ipv4.mroute_reg_vif_num].dev;
 	if (reg_dev)
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
@@ -1940,6 +1938,10 @@ static int __net_init ipmr_net_init(stru
 		err = -ENOMEM;
 		goto fail_mfc_cache;
 	}
+
+#ifdef CONFIG_IP_PIMSM
+	net->ipv4.mroute_reg_vif_num = -1;
+#endif
 	return 0;
 
 fail_mfc_cache:

