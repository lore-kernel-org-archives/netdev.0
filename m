From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v4 2/9] bgmac: leave interrupts disabled as long as there is work to do
Date: Mon, 13 Apr 2015 15:52:35 +0200
Message-ID: <1428933162-26763-2-git-send-email-nbd@openwrt.org>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:51314
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753591AbbDMNwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 09:52:47 -0400
In-Reply-To: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always poll rx and tx during NAPI poll instead of relying on the status
of the first interrupt. This prevents bgmac_poll from leaving unfinished
work around until the next IRQ.
In my tests this makes bridging/routing throughput under heavy load more
stable and ensures that no new IRQs arrive as long as bgmac_poll uses up
the entire budget.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 31 ++++++++++---------------------
 drivers/net/ethernet/broadcom/bgmac.h |  1 -
 2 files changed, 10 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 73374b4..66876c5 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1105,8 +1105,6 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	bgmac_phy_init(bgmac);
 
 	netdev_reset_queue(bgmac->net_dev);
-
-	bgmac->int_status = 0;
 }
 
 static void bgmac_chip_intrs_on(struct bgmac *bgmac)
@@ -1221,14 +1219,13 @@ static irqreturn_t bgmac_interrupt(int irq, void *dev_id)
 	if (!int_status)
 		return IRQ_NONE;
 
-	/* Ack */
-	bgmac_write(bgmac, BGMAC_INT_STATUS, int_status);
+	int_status &= ~(BGMAC_IS_TX0 | BGMAC_IS_RX);
+	if (int_status)
+		bgmac_err(bgmac, "Unknown IRQs: 0x%08X\n", int_status);
 
 	/* Disable new interrupts until handling existing ones */
 	bgmac_chip_intrs_off(bgmac);
 
-	bgmac->int_status = int_status;
-
 	napi_schedule(&bgmac->napi);
 
 	return IRQ_HANDLED;
@@ -1237,25 +1234,17 @@ static irqreturn_t bgmac_interrupt(int irq, void *dev_id)
 static int bgmac_poll(struct napi_struct *napi, int weight)
 {
 	struct bgmac *bgmac = container_of(napi, struct bgmac, napi);
-	struct bgmac_dma_ring *ring;
 	int handled = 0;
 
-	if (bgmac->int_status & BGMAC_IS_TX0) {
-		ring = &bgmac->tx_ring[0];
-		bgmac_dma_tx_free(bgmac, ring);
-		bgmac->int_status &= ~BGMAC_IS_TX0;
-	}
+	/* Ack */
+	bgmac_write(bgmac, BGMAC_INT_STATUS, ~0);
 
-	if (bgmac->int_status & BGMAC_IS_RX) {
-		ring = &bgmac->rx_ring[0];
-		handled += bgmac_dma_rx_read(bgmac, ring, weight);
-		bgmac->int_status &= ~BGMAC_IS_RX;
-	}
+	bgmac_dma_tx_free(bgmac, &bgmac->tx_ring[0]);
+	handled += bgmac_dma_rx_read(bgmac, &bgmac->rx_ring[0], weight);
 
-	if (bgmac->int_status) {
-		bgmac_err(bgmac, "Unknown IRQs: 0x%08X\n", bgmac->int_status);
-		bgmac->int_status = 0;
-	}
+	/* poll again if more events arrived in the mean time */
+	if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BGMAC_IS_RX))
+		return handled;
 
 	if (handled < weight) {
 		napi_complete(napi);
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 5a198d5..abd50d1 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -452,7 +452,6 @@ struct bgmac {
 
 	/* Int */
 	u32 int_mask;
-	u32 int_status;
 
 	/* Current MAC state */
 	int mac_speed;
-- 
2.2.2
