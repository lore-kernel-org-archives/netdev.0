From: Li Yang <leoli@freescale.com>
Subject: [PATCH] net/gianfar: add missing set_mac_address hook
Date: Wed, 24 Jun 2009 21:04:34 +0800
Message-ID: <1245848674-6192-1-git-send-email-leoli@freescale.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Li Yang <leoli@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43076 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757904AbZFXMfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 08:35:23 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n5OCZCqW003104
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 05:35:25 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id n5OCZBCi026531
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 07:35:11 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the missing ndo_set_mac_address function to enable changing MAC
address.  Also remove the unnecessary gfar_set_mac_address function.

Signed-off-by: Li Yang <leoli@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4ae1d25..f526c99 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -111,7 +111,6 @@ static int gfar_close(struct net_device *dev);
 struct sk_buff *gfar_new_skb(struct net_device *dev);
 static void gfar_new_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
 		struct sk_buff *skb);
-static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
 static irqreturn_t gfar_transmit(int irq, void *dev_id);
@@ -142,6 +141,7 @@ void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static int gfar_set_mac_addr(struct net_device *dev, void *p)
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
@@ -156,6 +156,7 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
 	.ndo_vlan_rx_register = gfar_vlan_rx_register,
+	.ndo_set_mac_address = gfar_set_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = gfar_netpoll,
 #endif
@@ -1182,7 +1183,7 @@ static int gfar_enet_open(struct net_device *dev)
 	/* Initialize a bunch of registers */
 	init_registers(dev);
 
-	gfar_set_mac_address(dev);
+	gfar_set_mac_for_addr(dev, 0, dev->dev_addr);
 
 	err = init_phy(dev);
 
@@ -1426,15 +1427,19 @@ static int gfar_close(struct net_device *dev)
 	return 0;
 }
 
-/* Changes the mac address if the controller is not running. */
-static int gfar_set_mac_address(struct net_device *dev)
+/* Changes the station mac address on the go */
+static int gfar_set_mac_addr(struct net_device *dev, void *p)
 {
-	gfar_set_mac_for_addr(dev, 0, dev->dev_addr);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 
+	gfar_set_mac_for_addr(dev, 0, dev->dev_addr);
 	return 0;
 }
 
-
 /* Enables and disables VLAN insertion/extraction */
 static void gfar_vlan_rx_register(struct net_device *dev,
 		struct vlan_group *grp)
-- 
1.6.3.1.6.g4bf1f

