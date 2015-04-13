From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v6 7/9] bgmac: simplify dma init/cleanup
Date: Tue, 14 Apr 2015 01:42:15 +0200
Message-ID: <1428968537-6181-7-git-send-email-nbd@openwrt.org>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:53114
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752052AbbDMXmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 19:42:21 -0400
In-Reply-To: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of allocating buffers at device init time and initializing
descriptors at device open, do both at the same time (during open).
Free all buffers when closing the device.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 70 +++++++++++++++++------------------
 1 file changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index eafdbca..aad80a7 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -557,18 +557,26 @@ static void bgmac_dma_ring_desc_free(struct bgmac *bgmac,
 			  ring->dma_base);
 }
 
-static void bgmac_dma_free(struct bgmac *bgmac)
+static void bgmac_dma_cleanup(struct bgmac *bgmac)
 {
 	int i;
 
-	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++) {
+	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++)
 		bgmac_dma_tx_ring_free(bgmac, &bgmac->tx_ring[i]);
-		bgmac_dma_ring_desc_free(bgmac, &bgmac->tx_ring[i]);
-	}
-	for (i = 0; i < BGMAC_MAX_RX_RINGS; i++) {
+
+	for (i = 0; i < BGMAC_MAX_RX_RINGS; i++)
 		bgmac_dma_rx_ring_free(bgmac, &bgmac->rx_ring[i]);
+}
+
+static void bgmac_dma_free(struct bgmac *bgmac)
+{
+	int i;
+
+	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++)
+		bgmac_dma_ring_desc_free(bgmac, &bgmac->tx_ring[i]);
+
+	for (i = 0; i < BGMAC_MAX_RX_RINGS; i++)
 		bgmac_dma_ring_desc_free(bgmac, &bgmac->rx_ring[i]);
-	}
 }
 
 static int bgmac_dma_alloc(struct bgmac *bgmac)
@@ -616,8 +624,6 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 	}
 
 	for (i = 0; i < BGMAC_MAX_RX_RINGS; i++) {
-		int j;
-
 		ring = &bgmac->rx_ring[i];
 		ring->num_slots = BGMAC_RX_RING_SLOTS;
 		ring->mmio_base = ring_base[i];
@@ -640,15 +646,6 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 			ring->index_base = lower_32_bits(ring->dma_base);
 		else
 			ring->index_base = 0;
-
-		/* Alloc RX slots */
-		for (j = 0; j < ring->num_slots; j++) {
-			err = bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[j]);
-			if (err) {
-				bgmac_err(bgmac, "Can't allocate skb for slot in RX ring\n");
-				goto err_dma_free;
-			}
-		}
 	}
 
 	return 0;
@@ -658,10 +655,10 @@ err_dma_free:
 	return -ENOMEM;
 }
 
-static void bgmac_dma_init(struct bgmac *bgmac)
+static int bgmac_dma_init(struct bgmac *bgmac)
 {
 	struct bgmac_dma_ring *ring;
-	int i;
+	int i, err;
 
 	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++) {
 		ring = &bgmac->tx_ring[i];
@@ -693,8 +690,13 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 		if (ring->unaligned)
 			bgmac_dma_rx_enable(bgmac, ring);
 
-		for (j = 0; j < ring->num_slots; j++)
+		for (j = 0; j < ring->num_slots; j++) {
+			err = bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[j]);
+			if (err)
+				return err;
+
 			bgmac_dma_rx_setup_desc(bgmac, ring, j);
+		}
 
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
 			    ring->index_base +
@@ -703,6 +705,8 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 		ring->start = 0;
 		ring->end = 0;
 	}
+
+	return 0;
 }
 
 /**************************************************
@@ -1178,11 +1182,8 @@ static void bgmac_enable(struct bgmac *bgmac)
 }
 
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipinit */
-static void bgmac_chip_init(struct bgmac *bgmac, bool full_init)
+static void bgmac_chip_init(struct bgmac *bgmac)
 {
-	struct bgmac_dma_ring *ring;
-	int i;
-
 	/* 1 interrupt per received frame */
 	bgmac_write(bgmac, BGMAC_INT_RECV_LAZY, 1 << BGMAC_IRL_FC_SHIFT);
 
@@ -1200,16 +1201,7 @@ static void bgmac_chip_init(struct bgmac *bgmac, bool full_init)
 
 	bgmac_write(bgmac, BGMAC_RXMAX_LENGTH, 32 + ETHER_MAX_LEN);
 
-	if (full_init) {
-		bgmac_dma_init(bgmac);
-		if (1) /* FIXME: is there any case we don't want IRQs? */
-			bgmac_chip_intrs_on(bgmac);
-	} else {
-		for (i = 0; i < BGMAC_MAX_RX_RINGS; i++) {
-			ring = &bgmac->rx_ring[i];
-			bgmac_dma_rx_enable(bgmac, ring);
-		}
-	}
+	bgmac_chip_intrs_on(bgmac);
 
 	bgmac_enable(bgmac);
 }
@@ -1269,8 +1261,13 @@ static int bgmac_open(struct net_device *net_dev)
 	int err = 0;
 
 	bgmac_chip_reset(bgmac);
+
+	err = bgmac_dma_init(bgmac);
+	if (err)
+		goto err_out;
+
 	/* Specs say about reclaiming rings here, but we do that in DMA init */
-	bgmac_chip_init(bgmac, true);
+	bgmac_chip_init(bgmac);
 
 	err = request_irq(bgmac->core->irq, bgmac_interrupt, IRQF_SHARED,
 			  KBUILD_MODNAME, net_dev);
@@ -1283,8 +1280,10 @@ static int bgmac_open(struct net_device *net_dev)
 	phy_start(bgmac->phy_dev);
 
 	netif_carrier_on(net_dev);
+	return 0;
 
 err_out:
+	bgmac_dma_cleanup(bgmac);
 	return err;
 }
 
@@ -1301,6 +1300,7 @@ static int bgmac_stop(struct net_device *net_dev)
 	free_irq(bgmac->core->irq, net_dev);
 
 	bgmac_chip_reset(bgmac);
+	bgmac_dma_cleanup(bgmac);
 
 	return 0;
 }
-- 
2.2.2
