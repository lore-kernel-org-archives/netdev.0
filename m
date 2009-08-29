From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH next] sky2: Create buffer alloc and free helpers
Date: Sat, 29 Aug 2009 22:13:24 +0900
Message-ID: <4A992974.1060308@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f204.google.com ([209.85.223.204]:54634 "EHLO
	mail-iw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbZH2NRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 09:17:15 -0400
Received: by iwn42 with SMTP id 42so1233222iwn.33
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 06:17:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor similar two sections of code that free buffers into one.
Only call tx_init if all buffer allocations succeed.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |  113 +++++++++++++++++++++++++++------------------------
 1 files changed, 60 insertions(+), 53 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index aec8ad3..f0c9f39 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1399,6 +1399,61 @@ nomem:
 	return -ENOMEM;
 }
 
+static int sky2_alloc_buffers(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+
+	/* must be power of 2 */
+	sky2->tx_le = pci_alloc_consistent(hw->pdev,
+					   sky2->tx_ring_size *
+					   sizeof(struct sky2_tx_le),
+					   &sky2->tx_le_map);
+	if (!sky2->tx_le)
+		goto nomem;
+
+	sky2->tx_ring = kcalloc(sky2->tx_ring_size, sizeof(struct tx_ring_info),
+				GFP_KERNEL);
+	if (!sky2->tx_ring)
+		goto nomem;
+
+	sky2->rx_le = pci_alloc_consistent(hw->pdev, RX_LE_BYTES,
+					   &sky2->rx_le_map);
+	if (!sky2->rx_le)
+		goto nomem;
+	memset(sky2->rx_le, 0, RX_LE_BYTES);
+
+	sky2->rx_ring = kcalloc(sky2->rx_pending, sizeof(struct rx_ring_info),
+				GFP_KERNEL);
+	if (!sky2->rx_ring)
+		goto nomem;
+
+	return 0;
+nomem:
+	return -ENOMEM;
+}
+
+static void sky2_free_buffers(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+
+	if (sky2->rx_le) {
+		pci_free_consistent(hw->pdev, RX_LE_BYTES,
+				    sky2->rx_le, sky2->rx_le_map);
+		sky2->rx_le = NULL;
+	}
+	if (sky2->tx_le) {
+		pci_free_consistent(hw->pdev,
+				    sky2->tx_ring_size * sizeof(struct sky2_tx_le),
+				    sky2->tx_le, sky2->tx_le_map);
+		sky2->tx_le = NULL;
+	}
+	kfree(sky2->tx_ring);
+	kfree(sky2->rx_ring);
+
+	sky2->tx_ring = NULL;
+	sky2->rx_ring = NULL;
+}
+
 /* Bring up network interface. */
 static int sky2_up(struct net_device *dev)
 {
@@ -1406,7 +1461,7 @@ static int sky2_up(struct net_device *dev)
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
 	u32 imask, ramsize;
-	int cap, err = -ENOMEM;
+	int cap, err;
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
 	/*
@@ -1425,32 +1480,12 @@ static int sky2_up(struct net_device *dev)
 
 	netif_carrier_off(dev);
 
-	/* must be power of 2 */
-	sky2->tx_le = pci_alloc_consistent(hw->pdev,
-					   sky2->tx_ring_size *
-					   sizeof(struct sky2_tx_le),
-					   &sky2->tx_le_map);
-	if (!sky2->tx_le)
-		goto err_out;
-
-	sky2->tx_ring = kcalloc(sky2->tx_ring_size, sizeof(struct tx_ring_info),
-				GFP_KERNEL);
-	if (!sky2->tx_ring)
+	err = sky2_alloc_buffers(sky2);
+	if (err)
 		goto err_out;
 
 	tx_init(sky2);
 
-	sky2->rx_le = pci_alloc_consistent(hw->pdev, RX_LE_BYTES,
-					   &sky2->rx_le_map);
-	if (!sky2->rx_le)
-		goto err_out;
-	memset(sky2->rx_le, 0, RX_LE_BYTES);
-
-	sky2->rx_ring = kcalloc(sky2->rx_pending, sizeof(struct rx_ring_info),
-				GFP_KERNEL);
-	if (!sky2->rx_ring)
-		goto err_out;
-
 	sky2_mac_init(hw, port);
 
 	/* Register is number of 4K blocks on internal RAM buffer. */
@@ -1507,22 +1542,7 @@ static int sky2_up(struct net_device *dev)
 	return 0;
 
 err_out:
-	if (sky2->rx_le) {
-		pci_free_consistent(hw->pdev, RX_LE_BYTES,
-				    sky2->rx_le, sky2->rx_le_map);
-		sky2->rx_le = NULL;
-	}
-	if (sky2->tx_le) {
-		pci_free_consistent(hw->pdev,
-				    sky2->tx_ring_size * sizeof(struct sky2_tx_le),
-				    sky2->tx_le, sky2->tx_le_map);
-		sky2->tx_le = NULL;
-	}
-	kfree(sky2->tx_ring);
-	kfree(sky2->rx_ring);
-
-	sky2->tx_ring = NULL;
-	sky2->rx_ring = NULL;
+	sky2_free_buffers(sky2);
 	return err;
 }
 
@@ -1873,20 +1893,7 @@ static int sky2_down(struct net_device *dev)
 
 	sky2_rx_clean(sky2);
 
-	pci_free_consistent(hw->pdev, RX_LE_BYTES,
-			    sky2->rx_le, sky2->rx_le_map);
-	kfree(sky2->rx_ring);
-
-	pci_free_consistent(hw->pdev,
-			    sky2->tx_ring_size * sizeof(struct sky2_tx_le),
-			    sky2->tx_le, sky2->tx_le_map);
-	kfree(sky2->tx_ring);
-
-	sky2->tx_le = NULL;
-	sky2->rx_le = NULL;
-
-	sky2->rx_ring = NULL;
-	sky2->tx_ring = NULL;
+	sky2_free_buffers(sky2);
 
 	return 0;
 }
-- 
1.5.6.5

