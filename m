From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Create buffer alloc and free helpers
Date: Sun, 09 Aug 2009 20:40:16 +0900
Message-ID: <4A7EB5A0.3040401@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f196.google.com ([209.85.222.196]:44338 "EHLO
	mail-pz0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbZHILnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2009 07:43:22 -0400
Received: by pzk34 with SMTP id 34so2408973pzk.4
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2009 04:43:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor similar two sections of code that free buffers into one.
As a side effect, only call tx_init() in sky2_up() if all buffer 
 allocations succeed.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |  111 +++++++++++++++++++++++++++------------------------
 1 files changed, 59 insertions(+), 52 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 824a319..fab51bb 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1396,6 +1396,62 @@ nomem:
 	return -ENOMEM;
 }
 
+static int sky2_alloc_buffers(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+
+	/* must be power of 2 */
+	sky2->tx_le = pci_alloc_consistent(hw->pdev,
+					   TX_RING_SIZE *
+					   sizeof(struct sky2_tx_le),
+					   &sky2->tx_le_map);
+	if (!sky2->tx_le)
+		goto err;
+
+	sky2->tx_ring = kcalloc(TX_RING_SIZE, sizeof(struct tx_ring_info),
+				GFP_KERNEL);
+	if (!sky2->tx_ring)
+		goto err;
+
+	sky2->rx_le = pci_alloc_consistent(hw->pdev, RX_LE_BYTES,
+					   &sky2->rx_le_map);
+	if (!sky2->rx_le)
+		goto err;
+	memset(sky2->rx_le, 0, RX_LE_BYTES);
+
+	sky2->rx_ring = kcalloc(sky2->rx_pending, sizeof(struct rx_ring_info),
+				GFP_KERNEL);
+	if (!sky2->rx_ring)
+		goto err;
+
+	return 0;
+
+err:
+	return -1;
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
+				    TX_RING_SIZE * sizeof(struct sky2_tx_le),
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
@@ -1422,32 +1478,11 @@ static int sky2_up(struct net_device *dev)
 
 	netif_carrier_off(dev);
 
-	/* must be power of 2 */
-	sky2->tx_le = pci_alloc_consistent(hw->pdev,
-					   TX_RING_SIZE *
-					   sizeof(struct sky2_tx_le),
-					   &sky2->tx_le_map);
-	if (!sky2->tx_le)
-		goto err_out;
-
-	sky2->tx_ring = kcalloc(TX_RING_SIZE, sizeof(struct tx_ring_info),
-				GFP_KERNEL);
-	if (!sky2->tx_ring)
+	if (0 > sky2_alloc_buffers(sky2))
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
 	napi_disable(&hw->napi);
 	sky2_mac_init(hw, port);
 	napi_enable(&hw->napi);
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
-				    TX_RING_SIZE * sizeof(struct sky2_tx_le),
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
 
@@ -1900,20 +1920,7 @@ static int sky2_down(struct net_device *dev)
 	sky2_tx_clean(dev);
 	sky2_rx_clean(sky2);
 
-	pci_free_consistent(hw->pdev, RX_LE_BYTES,
-			    sky2->rx_le, sky2->rx_le_map);
-	kfree(sky2->rx_ring);
-
-	pci_free_consistent(hw->pdev,
-			    TX_RING_SIZE * sizeof(struct sky2_tx_le),
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

