From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: bcmgenet: add support for ethtool tx-frames
Date: Mon, 21 Apr 2014 08:45:22 -0700
Message-ID: <1398095124-5411-3-git-send-email-f.fainelli@gmail.com>
References: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:54037 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbaDUPqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 11:46:09 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so3791390pdb.14
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 08:46:09 -0700 (PDT)
In-Reply-To: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configuring the ethtool tx-frames property, which translates into N
packets before a TX interrupt is the simplest configuration scheme
because it requires no locking neither at the softare nor hardware
level, and is completely indepedent from the link speed. Since ethtool
does not allow per-tx queue coalescing parameters, we apply the same
setting to any transmit queue.

We can no longer enable the BDONE/PDONE interrupts as those would fire
for each packet/buffer received, which would defeat the MBDONE interrupt
purpose. The MBDONE interrupt is guaranteed to correspond to a
PDONE/BDONE interrupt when the threshold is set to 1.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 43 +++++++++++++++++++++++---
 1 file changed, 38 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index b093a48c427f..f1b3969de10b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -78,11 +78,10 @@
 #define GENET_RDMA_REG_OFF	(priv->hw_params->rdma_offset + \
 				TOTAL_DESC * DMA_DESC_SIZE)
 
-/* Tx/Rx DMA done masks: packet, buffer and multiple buffer done */
-#define UMAC_TXDMA_DONE_MASK	(UMAC_IRQ_TXDMA_BDONE | \
-				 UMAC_IRQ_TXDMA_PDONE | \
-				 UMAC_IRQ_TXDMA_MBDONE)
+/* TX DMA done mask: multiple buffer done */
+#define UMAC_TXDMA_DONE_MASK	(UMAC_IRQ_TXDMA_MBDONE)
 
+/* Rx DMA done masks: packet, buffer and multiple buffer done */
 #define UMAC_RXDMA_DONE_MASK	(UMAC_IRQ_RXDMA_BDONE | \
 				 UMAC_IRQ_RXDMA_PDONE | \
 				 UMAC_IRQ_RXDMA_MBDONE)
@@ -495,6 +494,38 @@ static void bcmgenet_set_msglevel(struct net_device *dev, u32 level)
 	priv->msg_enable = level;
 }
 
+static int bcmgenet_get_coalesce(struct net_device *dev,
+				 struct ethtool_coalesce *ec)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	ec->tx_max_coalesced_frames = bcmgenet_tdma_ring_readl(priv,
+			DESC_INDEX, DMA_MBUF_DONE_THRESH);
+
+	return 0;
+}
+
+static int bcmgenet_set_coalesce(struct net_device *dev,
+				 struct ethtool_coalesce *ec)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	unsigned int i;
+
+	if (ec->tx_max_coalesced_frames > 255)
+		return -EINVAL;
+
+	/* Program all TX queues with the same values, as there is no
+	 * ethtool knob to do coalescing on a per-queue basis
+	 */
+	for (i = 0; i < priv->hw_params->tx_queues; i++)
+		bcmgenet_tdma_ring_writel(priv, i,
+			ec->tx_max_coalesced_frames, DMA_MBUF_DONE_THRESH);
+	bcmgenet_tdma_ring_writel(priv, DESC_INDEX,
+			ec->tx_max_coalesced_frames, DMA_MBUF_DONE_THRESH);
+
+	return 0;
+}
+
 /* standard ethtool support functions. */
 enum bcmgenet_stat_type {
 	BCMGENET_STAT_NETDEV = -1,
@@ -739,6 +770,8 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= bcmgenet_get_msglevel,
 	.set_msglevel		= bcmgenet_set_msglevel,
+	.get_coalesce		= bcmgenet_get_coalesce,
+	.set_coalesce		= bcmgenet_set_coalesce,
 };
 
 /* Power down the unimac, based on mode. */
@@ -856,7 +889,7 @@ static inline void bcmgenet_tx_ring16_int_disable(struct bcmgenet_priv *priv,
 static inline void bcmgenet_tx_ring16_int_enable(struct bcmgenet_priv *priv,
 						 struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(priv, UMAC_TXDMA_DONE_MASK
+	bcmgenet_intrl2_0_writel(priv, UMAC_TXDMA_DONE_MASK,
 			INTRL2_CPU_MASK_CLEAR);
 }
 
-- 
1.9.1
