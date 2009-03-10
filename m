From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.30 2/2] gianfar: Convert to use netdev_ops
Date: Tue, 10 Mar 2009 17:58:28 -0500
Message-ID: <1236725908-8943-2-git-send-email-afleming@freescale.com>
References: <1236725908-8943-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:49523 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbZCJW6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 18:58:36 -0400
In-Reply-To: <1236725908-8943-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   31 +++++++++++++++++--------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index bd42502..bed30ef 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -140,11 +140,26 @@ static void gfar_halt_nodisable(struct net_device *dev);
 void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
+static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
 MODULE_LICENSE("GPL");
 
+static const struct net_device_ops gfar_netdev_ops = {
+	.ndo_open = gfar_enet_open,
+	.ndo_start_xmit = gfar_start_xmit,
+	.ndo_stop = gfar_close,
+	.ndo_change_mtu = gfar_change_mtu,
+	.ndo_set_multicast_list = gfar_set_multi,
+	.ndo_tx_timeout = gfar_timeout,
+	.ndo_do_ioctl = gfar_ioctl,
+	.ndo_vlan_rx_register = gfar_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = gfar_netpoll,
+#endif
+};
+
 /* Returns 1 if incoming frames use an FCB */
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
@@ -390,21 +405,12 @@ static int gfar_probe(struct of_device *ofdev,
 	SET_NETDEV_DEV(dev, &ofdev->dev);
 
 	/* Fill in the dev structure */
-	dev->open = gfar_enet_open;
-	dev->hard_start_xmit = gfar_start_xmit;
-	dev->tx_timeout = gfar_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	netif_napi_add(dev, &priv->napi, gfar_poll, GFAR_DEV_WEIGHT);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = gfar_netpoll;
-#endif
-	dev->stop = gfar_close;
-	dev->change_mtu = gfar_change_mtu;
 	dev->mtu = 1500;
-	dev->set_multicast_list = gfar_set_multi;
 
+	dev->netdev_ops = &gfar_netdev_ops;
 	dev->ethtool_ops = &gfar_ethtool_ops;
-	dev->do_ioctl = gfar_ioctl;
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		priv->rx_csum_enable = 1;
@@ -414,11 +420,8 @@ static int gfar_probe(struct of_device *ofdev,
 
 	priv->vlgrp = NULL;
 
-	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN) {
-		dev->vlan_rx_register = gfar_vlan_rx_register;
-
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN)
 		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	}
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
 		priv->extended_hash = 1;
-- 
1.6.0.6

