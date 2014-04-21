From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: bcmgenet: prepare for MBDONE interrupts support
Date: Mon, 21 Apr 2014 08:45:21 -0700
Message-ID: <1398095124-5411-2-git-send-email-f.fainelli@gmail.com>
References: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:63089 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbaDUPqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 11:46:08 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so3772990pdj.40
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 08:46:08 -0700 (PDT)
In-Reply-To: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multiple buffer done interrupts, as their name suggests will generate an
interrupt after N packets/buffers are done, prepare the interrupt
handlers and TX and RX path for handling these interrupts in preparation
for ethtool coalescing support.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 0966bd04375f..b093a48c427f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -78,6 +78,15 @@
 #define GENET_RDMA_REG_OFF	(priv->hw_params->rdma_offset + \
 				TOTAL_DESC * DMA_DESC_SIZE)
 
+/* Tx/Rx DMA done masks: packet, buffer and multiple buffer done */
+#define UMAC_TXDMA_DONE_MASK	(UMAC_IRQ_TXDMA_BDONE | \
+				 UMAC_IRQ_TXDMA_PDONE | \
+				 UMAC_IRQ_TXDMA_MBDONE)
+
+#define UMAC_RXDMA_DONE_MASK	(UMAC_IRQ_RXDMA_BDONE | \
+				 UMAC_IRQ_RXDMA_PDONE | \
+				 UMAC_IRQ_RXDMA_MBDONE)
+
 static inline void dmadesc_set_length_status(struct bcmgenet_priv *priv,
 						void __iomem *d, u32 value)
 {
@@ -840,16 +849,14 @@ static void bcmgenet_free_cb(struct enet_cb *cb)
 static inline void bcmgenet_tx_ring16_int_disable(struct bcmgenet_priv *priv,
 						  struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(priv,
-			UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
+	bcmgenet_intrl2_0_writel(priv, UMAC_TXDMA_DONE_MASK,
 			INTRL2_CPU_MASK_SET);
 }
 
 static inline void bcmgenet_tx_ring16_int_enable(struct bcmgenet_priv *priv,
 						 struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(priv,
-			UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
+	bcmgenet_intrl2_0_writel(priv, UMAC_TXDMA_DONE_MASK
 			INTRL2_CPU_MASK_CLEAR);
 }
 
@@ -1509,7 +1516,7 @@ static int init_umac(struct bcmgenet_priv *priv)
 	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_CLEAR);
 	bcmgenet_intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
 
-	cpu_mask_clear = UMAC_IRQ_RXDMA_BDONE;
+	cpu_mask_clear = UMAC_RXDMA_DONE_MASK;
 
 	dev_dbg(kdev, "%s:Enabling RXDMA_BDONE interrupt\n", __func__);
 
@@ -1795,7 +1802,7 @@ static int bcmgenet_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		napi_complete(napi);
 		bcmgenet_intrl2_0_writel(priv,
-			UMAC_IRQ_RXDMA_BDONE, INTRL2_CPU_MASK_CLEAR);
+			UMAC_RXDMA_DONE_MASK, INTRL2_CPU_MASK_CLEAR);
 	}
 
 	return work_done;
@@ -1862,19 +1869,18 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 	netif_dbg(priv, intr, priv->dev,
 		"IRQ=0x%x\n", priv->irq0_stat);
 
-	if (priv->irq0_stat & (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE)) {
+	if (priv->irq0_stat & UMAC_RXDMA_DONE_MASK) {
 		/* We use NAPI(software interrupt throttling, if
 		 * Rx Descriptor throttling is not used.
 		 * Disable interrupt, will be enabled in the poll method.
 		 */
 		if (likely(napi_schedule_prep(&priv->napi))) {
 			bcmgenet_intrl2_0_writel(priv,
-				UMAC_IRQ_RXDMA_BDONE, INTRL2_CPU_MASK_SET);
+				UMAC_RXDMA_DONE_MASK, INTRL2_CPU_MASK_SET);
 			__napi_schedule(&priv->napi);
 		}
 	}
-	if (priv->irq0_stat &
-			(UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)) {
+	if (priv->irq0_stat & UMAC_TXDMA_DONE_MASK) {
 		/* Tx reclaim */
 		bcmgenet_tx_reclaim(priv->dev, &priv->tx_rings[DESC_INDEX]);
 	}
-- 
1.9.1
