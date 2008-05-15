From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/5] sky2: restore vlan acceleration on reset
Date: Wed, 14 May 2008 17:04:13 -0700
Message-ID: <20080515000432.887028646@vyatta.com>
References: <20080515000412.984337700@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:49972 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760303AbYEOAI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 20:08:27 -0400
Content-Disposition: inline; filename=sky2-vlan-restore.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If device has to be reset by sky2_restart, then need to restore
the VLAN acceleration settings.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Please apply to 2.6.26


--- a/drivers/net/sky2.c	2008-05-14 16:28:22.000000000 -0700
+++ b/drivers/net/sky2.c	2008-05-14 16:29:39.000000000 -0700
@@ -1159,17 +1159,9 @@ static int sky2_ioctl(struct net_device 
 }
 
 #ifdef SKY2_VLAN_TAG_USED
-static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
+static void sky2_set_vlan_mode(struct sky2_hw *hw, u16 port, bool onoff)
 {
-	struct sky2_port *sky2 = netdev_priv(dev);
-	struct sky2_hw *hw = sky2->hw;
-	u16 port = sky2->port;
-
-	netif_tx_lock_bh(dev);
-	napi_disable(&hw->napi);
-
-	sky2->vlgrp = grp;
-	if (grp) {
+	if (onoff) {
 		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
 			     RX_VLAN_STRIP_ON);
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
@@ -1180,6 +1172,19 @@ static void sky2_vlan_rx_register(struct
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
 			     TX_VLAN_TAG_OFF);
 	}
+}
+
+static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
+	u16 port = sky2->port;
+
+	netif_tx_lock_bh(dev);
+	napi_disable(&hw->napi);
+
+	sky2->vlgrp = grp;
+	sky2_set_vlan_mode(hw, port, grp != NULL);
 
 	sky2_read32(hw, B0_Y2_SP_LISR);
 	napi_enable(&hw->napi);
@@ -1418,6 +1423,10 @@ static int sky2_up(struct net_device *de
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   TX_RING_SIZE - 1);
 
+#ifdef SKY2_VLAN_TAG_USED
+	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
+#endif
+
 	err = sky2_rx_start(sky2);
 	if (err)
 		goto err_out;

-- 

