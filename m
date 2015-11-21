From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 3/9] net: ipmr: remove some pimsm ifdefs and simplify
Date: Sat, 21 Nov 2015 14:01:36 +0100
Message-ID: <1448110902-28793-4-git-send-email-razor@blackwall.org>
References: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34236 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbbKUNBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 08:01:50 -0500
Received: by wmvv187 with SMTP id v187so105478488wmv.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 05:01:49 -0800 (PST)
In-Reply-To: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add the helper pimsm_enabled() which replaces the old CONFIG_IP_PIMSM
define and is used to check if any version of PIM-SM has been enabled.
Use a single if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
for the pim-sm shared code. This is okay w.r.t IGMPMSG_WHOLEPKT because
only a VIFF_REGISTER device can send such packet, and it can't be
created if pimsm_enabled() is false.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 180 ++++++++++++++++++++++++++------------------------------
 1 file changed, 84 insertions(+), 96 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index dd2462f70d34..e153ab7b17a1 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -67,10 +67,6 @@
 #include <net/fib_rules.h>
 #include <linux/netconf.h>
 
-#if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
-#define CONFIG_IP_PIMSM	1
-#endif
-
 struct mr_table {
 	struct list_head	list;
 	possible_net_t		net;
@@ -95,6 +91,11 @@ struct ipmr_result {
 	struct mr_table		*mrt;
 };
 
+static inline bool pimsm_enabled(void)
+{
+	return IS_BUILTIN(CONFIG_IP_PIMSM_V1) || IS_BUILTIN(CONFIG_IP_PIMSM_V2);
+}
+
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
  * Note that the changes are semaphored via rtnl_lock.
  */
@@ -454,8 +455,7 @@ failure:
 	return NULL;
 }
 
-#ifdef CONFIG_IP_PIMSM
-
+#if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
 static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
@@ -552,6 +552,51 @@ failure:
 	unregister_netdevice(dev);
 	return NULL;
 }
+
+/* called with rcu_read_lock() */
+static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
+		     unsigned int pimlen)
+{
+	struct net_device *reg_dev = NULL;
+	struct iphdr *encap;
+
+	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
+	/*
+	 * Check that:
+	 * a. packet is really sent to a multicast group
+	 * b. packet is not a NULL-REGISTER
+	 * c. packet is not truncated
+	 */
+	if (!ipv4_is_multicast(encap->daddr) ||
+	    encap->tot_len == 0 ||
+	    ntohs(encap->tot_len) + pimlen > skb->len)
+		return 1;
+
+	read_lock(&mrt_lock);
+	if (mrt->mroute_reg_vif_num >= 0)
+		reg_dev = mrt->vif_table[mrt->mroute_reg_vif_num].dev;
+	read_unlock(&mrt_lock);
+
+	if (!reg_dev)
+		return 1;
+
+	skb->mac_header = skb->network_header;
+	skb_pull(skb, (u8 *)encap - skb->data);
+	skb_reset_network_header(skb);
+	skb->protocol = htons(ETH_P_IP);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	skb_tunnel_rx(skb, reg_dev, dev_net(reg_dev));
+
+	netif_rx(skb);
+
+	return NET_RX_SUCCESS;
+}
+#else
+static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
+{
+	return NULL;
+}
 #endif
 
 /**
@@ -734,10 +779,10 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 		return -EADDRINUSE;
 
 	switch (vifc->vifc_flags) {
-#ifdef CONFIG_IP_PIMSM
 	case VIFF_REGISTER:
-		/*
-		 * Special Purpose VIF in PIM
+		if (!pimsm_enabled())
+			return -EINVAL;
+		/* Special Purpose VIF in PIM
 		 * All the packets will be sent to the daemon
 		 */
 		if (mrt->mroute_reg_vif_num >= 0)
@@ -752,7 +797,6 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 			return err;
 		}
 		break;
-#endif
 	case VIFF_TUNNEL:
 		dev = ipmr_new_tunnel(net, vifc);
 		if (!dev)
@@ -942,34 +986,29 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 	}
 }
 
-/*
- *	Bounce a cache query up to mrouted. We could use netlink for this but mrouted
- *	expects the following bizarre scheme.
+/* Bounce a cache query up to mrouted. We could use netlink for this but mrouted
+ * expects the following bizarre scheme.
  *
- *	Called under mrt_lock.
+ * Called under mrt_lock.
  */
-
 static int ipmr_cache_report(struct mr_table *mrt,
 			     struct sk_buff *pkt, vifi_t vifi, int assert)
 {
-	struct sk_buff *skb;
 	const int ihl = ip_hdrlen(pkt);
+	struct sock *mroute_sk;
 	struct igmphdr *igmp;
 	struct igmpmsg *msg;
-	struct sock *mroute_sk;
+	struct sk_buff *skb;
 	int ret;
 
-#ifdef CONFIG_IP_PIMSM
 	if (assert == IGMPMSG_WHOLEPKT)
 		skb = skb_realloc_headroom(pkt, sizeof(struct iphdr));
 	else
-#endif
 		skb = alloc_skb(128, GFP_ATOMIC);
 
 	if (!skb)
 		return -ENOBUFS;
 
-#ifdef CONFIG_IP_PIMSM
 	if (assert == IGMPMSG_WHOLEPKT) {
 		/* Ugly, but we have no choice with this interface.
 		 * Duplicate old header, fix ihl, length etc.
@@ -987,28 +1026,23 @@ static int ipmr_cache_report(struct mr_table *mrt,
 		ip_hdr(skb)->ihl = sizeof(struct iphdr) >> 2;
 		ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(pkt)->tot_len) +
 					     sizeof(struct iphdr));
-	} else
-#endif
-	{
-
-	/* Copy the IP header */
-
-	skb_set_network_header(skb, skb->len);
-	skb_put(skb, ihl);
-	skb_copy_to_linear_data(skb, pkt->data, ihl);
-	ip_hdr(skb)->protocol = 0;	/* Flag to the kernel this is a route add */
-	msg = (struct igmpmsg *)skb_network_header(skb);
-	msg->im_vif = vifi;
-	skb_dst_set(skb, dst_clone(skb_dst(pkt)));
-
-	/* Add our header */
-
-	igmp = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
-	igmp->type	=
-	msg->im_msgtype = assert;
-	igmp->code	= 0;
-	ip_hdr(skb)->tot_len = htons(skb->len);		/* Fix the length */
-	skb->transport_header = skb->network_header;
+	} else {
+		/* Copy the IP header */
+		skb_set_network_header(skb, skb->len);
+		skb_put(skb, ihl);
+		skb_copy_to_linear_data(skb, pkt->data, ihl);
+		/* Flag to the kernel this is a route add */
+		ip_hdr(skb)->protocol = 0;
+		msg = (struct igmpmsg *)skb_network_header(skb);
+		msg->im_vif = vifi;
+		skb_dst_set(skb, dst_clone(skb_dst(pkt)));
+		/* Add our header */
+		igmp = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
+		igmp->type = assert;
+		msg->im_msgtype = assert;
+		igmp->code = 0;
+		ip_hdr(skb)->tot_len = htons(skb->len);	/* Fix the length */
+		skb->transport_header = skb->network_header;
 	}
 
 	rcu_read_lock();
@@ -1020,7 +1054,6 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	}
 
 	/* Deliver to mrouted */
-
 	ret = sock_queue_rcv_skb(mroute_sk, skb);
 	rcu_read_unlock();
 	if (ret < 0) {
@@ -1377,11 +1410,12 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		mrt->mroute_do_assert = v;
 		return 0;
 	}
-#ifdef CONFIG_IP_PIMSM
 	case MRT_PIM:
 	{
 		int v;
 
+		if (!pimsm_enabled())
+			return -ENOPROTOOPT;
 		if (optlen != sizeof(v))
 			return -EINVAL;
 		if (get_user(v, (int __user *)optval))
@@ -1397,7 +1431,6 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		rtnl_unlock();
 		return ret;
 	}
-#endif
 #ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
 	case MRT_TABLE:
 	{
@@ -1452,9 +1485,7 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 		return -ENOENT;
 
 	if (optname != MRT_VERSION &&
-#ifdef CONFIG_IP_PIMSM
 	   optname != MRT_PIM &&
-#endif
 	   optname != MRT_ASSERT)
 		return -ENOPROTOOPT;
 
@@ -1467,14 +1498,15 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 
 	if (put_user(olr, optlen))
 		return -EFAULT;
-	if (optname == MRT_VERSION)
+	if (optname == MRT_VERSION) {
 		val = 0x0305;
-#ifdef CONFIG_IP_PIMSM
-	else if (optname == MRT_PIM)
+	} else if (optname == MRT_PIM) {
+		if (!pimsm_enabled())
+			return -ENOPROTOOPT;
 		val = mrt->mroute_do_pim;
-#endif
-	else
+	} else {
 		val = mrt->mroute_do_assert;
+	}
 	if (copy_to_user(optval, &val, olr))
 		return -EFAULT;
 	return 0;
@@ -1707,7 +1739,6 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	if (!vif->dev)
 		goto out_free;
 
-#ifdef CONFIG_IP_PIMSM
 	if (vif->flags & VIFF_REGISTER) {
 		vif->pkt_out++;
 		vif->bytes_out += skb->len;
@@ -1716,7 +1747,6 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		ipmr_cache_report(mrt, skb, vifi, IGMPMSG_WHOLEPKT);
 		goto out_free;
 	}
-#endif
 
 	if (vif->flags & VIFF_TUNNEL) {
 		rt = ip_route_output_ports(net, &fl4, NULL,
@@ -2047,48 +2077,6 @@ dont_forward:
 	return 0;
 }
 
-#ifdef CONFIG_IP_PIMSM
-/* called with rcu_read_lock() */
-static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
-		     unsigned int pimlen)
-{
-	struct net_device *reg_dev = NULL;
-	struct iphdr *encap;
-
-	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
-	/*
-	 * Check that:
-	 * a. packet is really sent to a multicast group
-	 * b. packet is not a NULL-REGISTER
-	 * c. packet is not truncated
-	 */
-	if (!ipv4_is_multicast(encap->daddr) ||
-	    encap->tot_len == 0 ||
-	    ntohs(encap->tot_len) + pimlen > skb->len)
-		return 1;
-
-	read_lock(&mrt_lock);
-	if (mrt->mroute_reg_vif_num >= 0)
-		reg_dev = mrt->vif_table[mrt->mroute_reg_vif_num].dev;
-	read_unlock(&mrt_lock);
-
-	if (!reg_dev)
-		return 1;
-
-	skb->mac_header = skb->network_header;
-	skb_pull(skb, (u8 *)encap - skb->data);
-	skb_reset_network_header(skb);
-	skb->protocol = htons(ETH_P_IP);
-	skb->ip_summed = CHECKSUM_NONE;
-
-	skb_tunnel_rx(skb, reg_dev, dev_net(reg_dev));
-
-	netif_rx(skb);
-
-	return NET_RX_SUCCESS;
-}
-#endif
-
 #ifdef CONFIG_IP_PIMSM_V1
 /*
  * Handle IGMP messages of PIMv1
-- 
2.4.3
