From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 3/3] sky2: Remove failure cases for sky2_rx_start
Date: Thu, 28 Jan 2010 00:05:54 +0900
Message-ID: <4B605652.6020400@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f190.google.com ([209.85.222.190]:41625 "EHLO
	mail-pz0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab0A0PKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 10:10:34 -0500
Received: by pzk28 with SMTP id 28so2000759pzk.4
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 07:10:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sky2_rx_start() can no longer fail, so remove redundant code pathes.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   24 ++++++------------------
 1 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a967912..6ea660f 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1366,7 +1366,7 @@ static inline void sky2_rx_update(struct sky2_port *sky2, unsigned rxq)
  * One element is used for checksum enable/disable, and one
  * extra to avoid wrap.
  */
-static int sky2_rx_start(struct sky2_port *sky2)
+static void sky2_rx_start(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
 	struct rx_ring_info *re;
@@ -1392,7 +1392,6 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	if (!(hw->flags & SKY2_HW_NEW_LE))
 		rx_set_checksum(sky2);
 
-
 	/* submit Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
 		re = sky2->rx_ring + i;
@@ -1437,10 +1436,6 @@ static int sky2_rx_start(struct sky2_port *sky2)
 		sky2_write32(hw, Q_ADDR(txqaddr[sky2->port], Q_TEST),
 			     TBMU_TEST_HOME_ADD_FIX_EN | TBMU_TEST_ROUTING_ADD_FIX_EN);
 	}
-
-
-
-	return 0;
 }
 
 static int sky2_alloc_buffers(struct sky2_port *sky2)
@@ -1590,9 +1585,7 @@ static int sky2_up(struct net_device *dev)
 	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
 #endif
 
-	err = sky2_rx_start(sky2);
-	if (err)
-		goto err_out;
+	sky2_rx_start(sky2);
 
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -2200,7 +2193,6 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	int err;
 	u16 ctl, mode;
 	u32 imask;
 
@@ -2246,21 +2238,17 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 
 	sky2_write8(hw, RB_ADDR(rxqaddr[port], RB_CTRL), RB_ENA_OP_MD);
 
-	err = sky2_rx_start(sky2);
+	sky2_rx_start(sky2);
 	sky2_write32(hw, B0_IMSK, imask);
 
 	sky2_read32(hw, B0_Y2_SP_LISR);
 	napi_enable(&hw->napi);
 
-	if (err)
-		dev_close(dev);
-	else {
-		gma_write16(hw, port, GM_GP_CTRL, ctl);
+	gma_write16(hw, port, GM_GP_CTRL, ctl);
 
-		netif_wake_queue(dev);
-	}
+	netif_wake_queue(dev);
 
-	return err;
+	return 0;
 }
 
 /* For small just reuse existing skb for next receive */
-- 
1.5.6.5

