From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/10] sky2: Allocate initial skbs in sky2_alloc_buffers
Date: Fri, 12 Feb 2010 08:58:03 -0800
Message-ID: <20100212165937.933877645@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49504 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757372Ab0BLRIW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:08:22 -0500
Content-Disposition: inline; filename=sky2-mike2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Allocate everything in one place so there's a single point
of failure in sky2_up, and sky2_rx_start can no longer fail.

Don't leave the hardware in a partially initialized state in the
case rx ring allocation fails.

As with the old code, the rx ring still needs to be fully
allocated for sky2_up to succeed.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |   68 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 38 insertions(+), 30 deletions(-)

--- a/drivers/net/sky2.c	2010-02-11 15:33:38.651857666 -0800
+++ b/drivers/net/sky2.c	2010-02-11 15:33:40.351545123 -0800
@@ -1363,8 +1363,32 @@ static inline void sky2_rx_update(struct
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
+			return -ENOMEM;
+
+		if (sky2_rx_map_skb(hw->pdev, re, sky2->rx_data_size)) {
+			dev_kfree_skb(re->skb);
+			re->skb = NULL;
+			return -ENOMEM;
+		}
+	}
+	return 0;
+}
+
 /*
- * Allocate and setup receiver buffer pool.
+ * Setup receiver buffer pool.
  * Normal case this ends up creating one list element for skb
  * in the receive ring. Worst case if using large MTU and each
  * allocation falls on a different 64 bit region, that results
@@ -1372,7 +1396,7 @@ static inline void sky2_rx_update(struct
  * One element is used for checksum enable/disable, and one
  * extra to avoid wrap.
  */
-static int sky2_rx_start(struct sky2_port *sky2)
+static void sky2_rx_start(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
 	struct rx_ring_info *re;
@@ -1398,22 +1422,9 @@ static int sky2_rx_start(struct sky2_por
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
 
@@ -1455,13 +1466,6 @@ static int sky2_rx_start(struct sky2_por
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
@@ -1492,7 +1496,7 @@ static int sky2_alloc_buffers(struct sky
 	if (!sky2->rx_ring)
 		goto nomem;
 
-	return 0;
+	return sky2_alloc_rx_skbs(sky2);
 nomem:
 	return -ENOMEM;
 }
@@ -1501,6 +1505,8 @@ static void sky2_free_buffers(struct sky
 {
 	struct sky2_hw *hw = sky2->hw;
 
+	sky2_rx_clean(sky2);
+
 	if (sky2->rx_le) {
 		pci_free_consistent(hw->pdev, RX_LE_BYTES,
 				    sky2->rx_le, sky2->rx_le_map);
@@ -1590,9 +1596,7 @@ static int sky2_up(struct net_device *de
 	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
 #endif
 
-	err = sky2_rx_start(sky2);
-	if (err)
-		goto err_out;
+	sky2_rx_start(sky2);
 
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -1960,8 +1964,6 @@ static int sky2_down(struct net_device *
 	/* Free any pending frames stuck in HW queue */
 	sky2_tx_complete(sky2, sky2->tx_prod);
 
-	sky2_rx_clean(sky2);
-
 	sky2_free_buffers(sky2);
 
 	return 0;
@@ -2257,7 +2259,11 @@ static int sky2_change_mtu(struct net_de
 
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

