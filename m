From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 06/14] gianfar: Fix VLAN HW feature related frame/buffer size calculation.
Date: Tue, 16 Dec 2008 17:20:59 -0600
Message-ID: <1229469667-25002-7-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
 <1229469667-25002-5-git-send-email-afleming@freescale.com>
 <1229469667-25002-6-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Haruki Dai <Dai.Haruki@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39687 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691AbYLPXVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:21 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL9Ol013525
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:09 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL8Tb006128
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:08 -0600 (CST)
In-Reply-To: <1229469667-25002-6-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haruki Dai <Dai.Haruki@freescale.com>

Optimize the VLAN checking logic as well.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   36 +++++++++++++++++++++---------------
 drivers/net/gianfar.h |    9 +++++----
 2 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index aac9915..c40ba18 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -149,7 +149,7 @@ MODULE_LICENSE("GPL");
 /* Returns 1 if incoming frames use an FCB */
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
-	return (priv->vlan_enable || priv->rx_csum_enable);
+	return priv->vlgrp || priv->rx_csum_enable;
 }
 
 static int gfar_of_init(struct net_device *dev)
@@ -376,8 +376,6 @@ static int gfar_probe(struct of_device *ofdev,
 		dev->vlan_rx_register = gfar_vlan_rx_register;
 
 		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-
-		priv->vlan_enable = 1;
 	}
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
@@ -1078,9 +1076,6 @@ int startup_gfar(struct net_device *dev)
 		rctrl |= RCTRL_EMEN;
 	}
 
-	if (priv->vlan_enable)
-		rctrl |= RCTRL_VLAN;
-
 	if (priv->padding) {
 		rctrl &= ~RCTRL_PAL_MASK;
 		rctrl |= RCTRL_PADDING(priv->padding);
@@ -1241,8 +1236,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		gfar_tx_checksum(skb, fcb);
 	}
 
-	if (priv->vlan_enable &&
-			unlikely(priv->vlgrp && vlan_tx_tag_present(skb))) {
+	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
 		if (unlikely(NULL == fcb)) {
 			fcb = gfar_add_fcb(skb, txbdp);
 			status |= TXBD_TOE;
@@ -1344,11 +1338,15 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	unsigned long flags;
+	struct vlan_group *old_grp;
 	u32 tempval;
 
 	spin_lock_irqsave(&priv->rxlock, flags);
 
-	priv->vlgrp = grp;
+	old_grp = priv->vlgrp;
+
+	if (old_grp == grp)
+		return;
 
 	if (grp) {
 		/* Enable VLAN tag insertion */
@@ -1360,6 +1358,7 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 		/* Enable VLAN tag extraction */
 		tempval = gfar_read(&priv->regs->rctrl);
 		tempval |= RCTRL_VLEX;
+		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
 		gfar_write(&priv->regs->rctrl, tempval);
 	} else {
 		/* Disable VLAN tag insertion */
@@ -1370,9 +1369,16 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 		/* Disable VLAN tag extraction */
 		tempval = gfar_read(&priv->regs->rctrl);
 		tempval &= ~RCTRL_VLEX;
+		/* If parse is no longer required, then disable parser */
+		if (tempval & RCTRL_REQ_PARSER)
+			tempval |= RCTRL_PRSDEP_INIT;
+		else
+			tempval &= ~RCTRL_PRSDEP_INIT;
 		gfar_write(&priv->regs->rctrl, tempval);
 	}
 
+	gfar_change_mtu(dev, dev->mtu);
+
 	spin_unlock_irqrestore(&priv->rxlock, flags);
 }
 
@@ -1383,14 +1389,9 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	int oldsize = priv->rx_buffer_size;
 	int frame_size = new_mtu + ETH_HLEN;
 
-	if (priv->vlan_enable)
+	if (priv->vlgrp)
 		frame_size += VLAN_HLEN;
 
-	if (gfar_uses_fcb(priv))
-		frame_size += GMAC_FCB_LEN;
-
-	frame_size += priv->padding;
-
 	if ((frame_size < 64) || (frame_size > JUMBO_FRAME_SIZE)) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR "%s: Invalid MTU setting\n",
@@ -1398,6 +1399,11 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 	}
 
+	if (gfar_uses_fcb(priv))
+		frame_size += GMAC_FCB_LEN;
+
+	frame_size += priv->padding;
+
 	tempsize =
 	    (frame_size & ~(INCREMENTAL_BUFFER_SIZE - 1)) +
 	    INCREMENTAL_BUFFER_SIZE;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 449f508..1bdb50c 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -206,8 +206,10 @@ extern const char gfar_driver_version[];
 #define RCTRL_PRSDEP_INIT	0x000000c0
 #define RCTRL_PROM		0x00000008
 #define RCTRL_EMEN		0x00000002
-#define RCTRL_CHECKSUMMING	(RCTRL_IPCSEN \
-		| RCTRL_TUCSEN | RCTRL_PRSDEP_INIT)
+#define RCTRL_REQ_PARSER	(RCTRL_VLEX | RCTRL_IPCSEN | \
+				 RCTRL_TUCSEN)
+#define RCTRL_CHECKSUMMING	(RCTRL_IPCSEN | RCTRL_TUCSEN | \
+				RCTRL_PRSDEP_INIT)
 #define RCTRL_EXTHASH		(RCTRL_GHTX)
 #define RCTRL_VLAN		(RCTRL_PRSDEP_INIT)
 #define RCTRL_PADDING(x)	((x << 16) & RCTRL_PAL_MASK)
@@ -754,8 +756,7 @@ struct gfar_private {
 	phy_interface_t interface;
 	char	phy_bus_id[BUS_ID_SIZE];
 	u32 device_flags;
-	unsigned char vlan_enable:1,
-		rx_csum_enable:1,
+	unsigned char rx_csum_enable:1,
 		extended_hash:1,
 		bd_stash_en:1,
 		wol_en:1; /* Wake-on-LAN enabled */
-- 
1.5.4.GIT

