From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 3/6] at91_ether: convert to net_device_ops
Date: Fri, 10 Apr 2009 07:27:00 +0400
Message-ID: <20090410032700.GA29233@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:44795 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763225AbZDJD1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 23:27:07 -0400
Received: by fg-out-1718.google.com with SMTP id 16so781785fgg.17
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 20:27:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/arm/at91_ether.c |   32 +++++++++++++++++++-------------
 1 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 442938d..7f4bc8a 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -577,7 +577,7 @@ static void at91ether_sethashtable(struct net_device *dev)
 /*
  * Enable/Disable promiscuous and multicast modes.
  */
-static void at91ether_set_rx_mode(struct net_device *dev)
+static void at91ether_set_multicast_list(struct net_device *dev)
 {
 	unsigned long cfg;
 
@@ -808,7 +808,7 @@ static int at91ether_close(struct net_device *dev)
 /*
  * Transmit packet.
  */
-static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
+static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct at91_private *lp = netdev_priv(dev);
 
@@ -828,7 +828,7 @@ static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
 
 		dev->trans_start = jiffies;
 	} else {
-		printk(KERN_ERR "at91_ether.c: at91ether_tx() called, but device is busy!\n");
+		printk(KERN_ERR "at91_ether.c: at91ether_start_xmit() called, but device is busy!\n");
 		return 1;	/* if we return anything but zero, dev.c:1055 calls kfree_skb(skb)
 				on this skb, he also reports -ENETDOWN and printk's, so either
 				we free and return(0) or don't free and return 1 */
@@ -965,6 +965,21 @@ static void at91ether_poll_controller(struct net_device *dev)
 }
 #endif
 
+static const struct net_device_ops at91ether_netdev_ops = {
+	.ndo_open		= at91ether_open,
+	.ndo_stop		= at91ether_close,
+	.ndo_start_xmit		= at91ether_start_xmit,
+	.ndo_get_stats		= at91ether_stats,
+	.ndo_set_multicast_list	= at91ether_set_multicast_list,
+	.ndo_set_mac_address	= set_mac_address,
+	.ndo_do_ioctl		= at91ether_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= at91ether_poll_controller,
+#endif
+};
+
 /*
  * Initialize the ethernet interface
  */
@@ -1005,17 +1020,8 @@ static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_add
 	spin_lock_init(&lp->lock);
 
 	ether_setup(dev);
-	dev->open = at91ether_open;
-	dev->stop = at91ether_close;
-	dev->hard_start_xmit = at91ether_tx;
-	dev->get_stats = at91ether_stats;
-	dev->set_multicast_list = at91ether_set_rx_mode;
-	dev->set_mac_address = set_mac_address;
+	dev->netdev_ops = &at91ether_netdev_ops;
 	dev->ethtool_ops = &at91ether_ethtool_ops;
-	dev->do_ioctl = at91ether_ioctl;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = at91ether_poll_controller;
-#endif
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
