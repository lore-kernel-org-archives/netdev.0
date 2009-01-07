From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/42] bluetooth: driver API update
Date: Tue, 06 Jan 2009 16:33:19 -0800
Message-ID: <20090107003345.753201945@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: David Miller <davem@davemloft.net>, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58977 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754744AbZAGAxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:02 -0500
Content-Disposition: inline; filename=bluetooth.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops and use internal net_device_stats in bnep
device. 

Note: no need for bnep_net_ioctl since if ioctl is not set, then
dev_ifsioc handles it by returning -EOPNOTSUPP

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/bluetooth/bnep/bnep.h   |    1 -
 net/bluetooth/bnep/core.c   |   12 ++++++------
 net/bluetooth/bnep/netdev.c |   33 +++++++++++++--------------------
 3 files changed, 19 insertions(+), 27 deletions(-)

--- a/net/bluetooth/bnep/bnep.h	2009-01-06 15:36:57.660614286 -0800
+++ b/net/bluetooth/bnep/bnep.h	2009-01-06 15:49:48.920360342 -0800
@@ -165,7 +165,6 @@ struct bnep_session {
 
 	struct socket    *sock;
 	struct net_device *dev;
-	struct net_device_stats stats;
 };
 
 void bnep_net_setup(struct net_device *dev);
--- a/net/bluetooth/bnep/netdev.c	2009-01-06 15:36:57.652614285 -0800
+++ b/net/bluetooth/bnep/netdev.c	2009-01-06 16:13:10.628360045 -0800
@@ -55,12 +55,6 @@ static int bnep_net_close(struct net_dev
 	return 0;
 }
 
-static struct net_device_stats *bnep_net_get_stats(struct net_device *dev)
-{
-	struct bnep_session *s = netdev_priv(dev);
-	return &s->stats;
-}
-
 static void bnep_net_set_mc_list(struct net_device *dev)
 {
 #ifdef CONFIG_BT_BNEP_MC_FILTER
@@ -128,11 +122,6 @@ static void bnep_net_timeout(struct net_
 	netif_wake_queue(dev);
 }
 
-static int bnep_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-{
-	return -EINVAL;
-}
-
 #ifdef CONFIG_BT_BNEP_MC_FILTER
 static inline int bnep_net_mc_filter(struct sk_buff *skb, struct bnep_session *s)
 {
@@ -217,6 +206,18 @@ static int bnep_net_xmit(struct sk_buff 
 	return 0;
 }
 
+static const struct net_device_ops bnep_netdev_ops = {
+	.ndo_open            = bnep_net_open,
+	.ndo_stop            = bnep_net_close,
+	.ndo_start_xmit	     = bnep_net_xmit,
+	.ndo_validate_addr   = eth_validate_addr,
+	.ndo_set_multicast_list = bnep_net_set_mc_list,
+	.ndo_set_mac_address = bnep_net_set_mac_addr,
+	.ndo_tx_timeout      = bnep_net_timeout,
+	.ndo_change_mtu	     = eth_change_mtu,
+
+};
+
 void bnep_net_setup(struct net_device *dev)
 {
 
@@ -224,15 +225,7 @@ void bnep_net_setup(struct net_device *d
 	dev->addr_len = ETH_ALEN;
 
 	ether_setup(dev);
-
-	dev->open            = bnep_net_open;
-	dev->stop            = bnep_net_close;
-	dev->hard_start_xmit = bnep_net_xmit;
-	dev->get_stats       = bnep_net_get_stats;
-	dev->do_ioctl        = bnep_net_ioctl;
-	dev->set_mac_address = bnep_net_set_mac_addr;
-	dev->set_multicast_list = bnep_net_set_mc_list;
+	dev->netdev_ops = &bnep_netdev_ops;
 
 	dev->watchdog_timeo  = HZ * 2;
-	dev->tx_timeout      = bnep_net_timeout;
 }
--- a/net/bluetooth/bnep/core.c	2009-01-06 15:36:57.668614314 -0800
+++ b/net/bluetooth/bnep/core.c	2009-01-06 15:49:48.920360342 -0800
@@ -306,7 +306,7 @@ static inline int bnep_rx_frame(struct b
 	struct sk_buff *nskb;
 	u8 type;
 
-	s->stats.rx_bytes += skb->len;
+	dev->stats.rx_bytes += skb->len;
 
 	type = *(u8 *) skb->data; skb_pull(skb, 1);
 
@@ -343,7 +343,7 @@ static inline int bnep_rx_frame(struct b
 	 * may not be modified and because of the alignment requirements. */
 	nskb = alloc_skb(2 + ETH_HLEN + skb->len, GFP_KERNEL);
 	if (!nskb) {
-		s->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		kfree_skb(skb);
 		return -ENOMEM;
 	}
@@ -378,14 +378,14 @@ static inline int bnep_rx_frame(struct b
 	skb_copy_from_linear_data(skb, __skb_put(nskb, skb->len), skb->len);
 	kfree_skb(skb);
 
-	s->stats.rx_packets++;
+	dev->stats.rx_packets++;
 	nskb->ip_summed = CHECKSUM_NONE;
 	nskb->protocol  = eth_type_trans(nskb, dev);
 	netif_rx_ni(nskb);
 	return 0;
 
 badframe:
-	s->stats.rx_errors++;
+	dev->stats.rx_errors++;
 	kfree_skb(skb);
 	return 0;
 }
@@ -448,8 +448,8 @@ send:
 	kfree_skb(skb);
 
 	if (len > 0) {
-		s->stats.tx_bytes += len;
-		s->stats.tx_packets++;
+		s->dev->stats.tx_bytes += len;
+		s->dev->stats.tx_packets++;
 		return 0;
 	}
 

-- 

