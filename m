From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 2/2] sky2: Allocate initial skbs in sky2_alloc_buffers
Date: Sat, 06 Feb 2010 10:22:59 +0900
Message-ID: <4B6CC473.4090008@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:45344 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933297Ab0BFB16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 20:27:58 -0500
Received: by pxi12 with SMTP id 12so4912978pxi.33
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2010 17:27:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocating everything in one place means there's a single point
of failure in sky2_up, and sky2_rx_start can no longer fail.

With this patch, sky2_restart can later be rewritten to shutdown
the hardware and restart it without freeing and reallocing memory.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   68 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 38 insertions(+), 30 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 40c661b..ee091d1 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1379,8 +1379,34 @@ static inline void sky2_rx_update(struct sky2_port *sky2, unsigned rxq)
 	sky2_put_idx(sky2->hw, rxq, sky2->rx_put);
 }
 
+static int sky2_alloc_rx_skbs(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+	unsigned i;
+
+	sky2->rx_data_size = sky2_get_rx_data_size(sky2);
+
+	/* Fill Rx ring */
+	for (i = 0; i < sky2->rx_pending; i++) {
+		struct rx_ring_info *re = sky2->rx_ring + i;
+
+		re->skb = sky2_rx_alloc(sky2);
+		if (!re->skb)
+			goto nomem;
+
+		if (sky2_rx_map_skb(hw->pdev, re, sky2->rx_data_size)) {
+			dev_kfree_skb(re->skb);
+			re->skb = NULL;
+			goto nomem;
+		}
+	}
+	return 0;
+nomem:
+	return -ENOMEM;
+}
+
 /*
- * Allocate and setup receiver buffer pool.
+ * Setup receiver buffer pool.
  * Normal case this ends up creating one list element for skb
  * in the receive ring. Worst case if using large MTU and each
  * allocation falls on a different 64 bit region, that results
@@ -1388,7 +1414,7 @@ static inline void sky2_rx_update(struct sky2_port *sky2, unsigned rxq)
  * One element is used for checksum enable/disable, and one
  * extra to avoid wrap.
  */
-static int sky2_rx_start(struct sky2_port *sky2)
+static void sky2_rx_start(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
 	struct rx_ring_info *re;
@@ -1414,22 +1440,9 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	if (!(hw->flags & SKY2_HW_NEW_LE))
 		rx_set_checksum(sky2);
 
-	sky2->rx_data_size = sky2_get_rx_data_size(sky2);
-
-	/* Fill Rx ring */
+	/* submit Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
 		re = sky2->rx_ring + i;
-
-		re->skb = sky2_rx_alloc(sky2);
-		if (!re->skb)
-			goto nomem;
-
-		if (sky2_rx_map_skb(hw->pdev, re, sky2->rx_data_size)) {
-			dev_kfree_skb(re->skb);
-			re->skb = NULL;
-			goto nomem;
-		}
-
 		sky2_rx_submit(sky2, re);
 	}
 
@@ -1471,13 +1484,6 @@ static int sky2_rx_start(struct sky2_port *sky2)
 		sky2_write32(hw, Q_ADDR(txqaddr[sky2->port], Q_TEST),
 			     TBMU_TEST_HOME_ADD_FIX_EN | TBMU_TEST_ROUTING_ADD_FIX_EN);
 	}
-
-
-
-	return 0;
-nomem:
-	sky2_rx_clean(sky2);
-	return -ENOMEM;
 }
 
 static int sky2_alloc_buffers(struct sky2_port *sky2)
@@ -1508,7 +1514,7 @@ static int sky2_alloc_buffers(struct sky2_port *sky2)
 	if (!sky2->rx_ring)
 		goto nomem;
 
-	return 0;
+	return sky2_alloc_rx_skbs(sky2);
 nomem:
 	return -ENOMEM;
 }
@@ -1517,6 +1523,8 @@ static void sky2_free_buffers(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
 
+	sky2_rx_clean(sky2);
+
 	if (sky2->rx_le) {
 		pci_free_consistent(hw->pdev, RX_LE_BYTES,
 				    sky2->rx_le, sky2->rx_le_map);
@@ -1606,9 +1614,7 @@ static int sky2_up(struct net_device *dev)
 	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
 #endif
 
-	err = sky2_rx_start(sky2);
-	if (err)
-		goto err_out;
+	sky2_rx_start(sky2);
 
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -1976,8 +1982,6 @@ static int sky2_down(struct net_device *dev)
 	/* Free any pending frames stuck in HW queue */
 	sky2_tx_complete(sky2, sky2->tx_prod);
 
-	sky2_rx_clean(sky2);
-
 	sky2_free_buffers(sky2);
 
 	return 0;
@@ -2267,7 +2271,11 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 
 	sky2_write8(hw, RB_ADDR(rxqaddr[port], RB_CTRL), RB_ENA_OP_MD);
 
-	err = sky2_rx_start(sky2);
+	err = sky2_alloc_rx_skbs(sky2);
+	if (!err)
+		sky2_rx_start(sky2);
+	else
+		sky2_rx_clean(sky2);
 	sky2_write32(hw, B0_IMSK, imask);
 
 	sky2_read32(hw, B0_Y2_SP_LISR);
-- 
1.5.6.5

