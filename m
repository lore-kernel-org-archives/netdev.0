From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 2/3] sky2: Allocate initial skbs in sky2_alloc_buffers
Date: Thu, 28 Jan 2010 00:05:44 +0900
Message-ID: <4B605648.7020705@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:48312 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab0A0PKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 10:10:22 -0500
Received: by mail-px0-f182.google.com with SMTP id 12so4448801pxi.33
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 07:10:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocating everything in one place means there's a single point
of failure in sky2_up, and sky2_rx_start can no longer fail.

This also fixes a memory leak in the case that sky2_rx_start
fails in the middle of allocating skbs, since any allocated
skbs will not be free'd in sky2_up's failure path.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   42 +++++++++++++++++++++++-------------------
 1 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 2061eb8..a967912 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1358,7 +1358,7 @@ static inline void sky2_rx_update(struct sky2_port *sky2, unsigned rxq)
 }
 
 /*
- * Allocate and setup receiver buffer pool.
+ * Setup receiver buffer pool.
  * Normal case this ends up creating one list element for skb
  * in the receive ring. Worst case if using large MTU and each
  * allocation falls on a different 64 bit region, that results
@@ -1392,22 +1392,10 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	if (!(hw->flags & SKY2_HW_NEW_LE))
 		rx_set_checksum(sky2);
 
-	sky2->rx_data_size = sky2_get_rx_data_size(sky2);
 
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
 
@@ -1453,14 +1441,12 @@ static int sky2_rx_start(struct sky2_port *sky2)
 
 
 	return 0;
-nomem:
-	sky2_rx_clean(sky2);
-	return -ENOMEM;
 }
 
 static int sky2_alloc_buffers(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
+	unsigned i;
 
 	/* must be power of 2 */
 	sky2->tx_le = pci_alloc_consistent(hw->pdev,
@@ -1486,6 +1472,24 @@ static int sky2_alloc_buffers(struct sky2_port *sky2)
 	if (!sky2->rx_ring)
 		goto nomem;
 
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
+
+
 	return 0;
 nomem:
 	return -ENOMEM;
@@ -1495,6 +1499,8 @@ static void sky2_free_buffers(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
 
+	sky2_rx_clean(sky2);
+
 	if (sky2->rx_le) {
 		pci_free_consistent(hw->pdev, RX_LE_BYTES,
 				    sky2->rx_le, sky2->rx_le_map);
@@ -1953,8 +1959,6 @@ static int sky2_down(struct net_device *dev)
 	/* Free any pending frames stuck in HW queue */
 	sky2_tx_complete(sky2, sky2->tx_prod);
 
-	sky2_rx_clean(sky2);
-
 	sky2_free_buffers(sky2);
 
 	return 0;
-- 
1.5.6.5


