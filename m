From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: bcmgenet: Implement TX coalescing control knobs
Date: Wed, 16 Sep 2015 16:47:39 -0700
Message-ID: <1442447260-14129-2-git-send-email-f.fainelli@gmail.com>
References: <1442447260-14129-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34295 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbbIPXvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 19:51:24 -0400
Received: by padhy16 with SMTP id hy16so2211630pad.1
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 16:51:24 -0700 (PDT)
In-Reply-To: <1442447260-14129-1-git-send-email-f.fainelli@gmail.com>
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
PDONE/BDONE interrupt when the threshold is set to 1, but offers
interrupt coalescing when the value is > 1.

Since the HW is configured to generate an interrupt when the ring
becomes emtpy, we have to deny any timeout/timer settings coming from
user-space to indicate we can only generate an interrupt very <N>
packets.

While we are at it, fix the DMA_INTR_THRESHOLD_MASK value which was off
by one bit (0xff vs. 0x1ff).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 47 ++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  6 ++--
 2 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index fadbd0088d3e..5e247c7b379e 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -498,6 +498,51 @@ static void bcmgenet_set_msglevel(struct net_device *dev, u32 level)
 	priv->msg_enable = level;
 }
 
+static int bcmgenet_get_coalesce(struct net_device *dev,
+				 struct ethtool_coalesce *ec)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	ec->tx_max_coalesced_frames =
+		bcmgenet_tdma_ring_readl(priv, DESC_INDEX,
+					 DMA_MBUF_DONE_THRESH);
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
+	if (ec->tx_max_coalesced_frames > DMA_INTR_THRESHOLD_MASK ||
+	    ec->tx_max_coalesced_frames == 0)
+		return -EINVAL;
+
+	/* GENET TDMA hardware does not support a configurable timeout, but will
+	 * always generate an interrupt either after MBDONE packets have been
+	 * transmitted, or when the ring is emtpy.
+	 */
+	if (ec->tx_coalesce_usecs || ec->tx_coalesce_usecs_high ||
+	    ec->tx_coalesce_usecs_irq || ec->tx_coalesce_usecs_high ||
+	    ec->tx_coalesce_usecs_low)
+		return -EOPNOTSUPP;
+
+	/* Program all TX queues with the same values, as there is no
+	 * ethtool knob to do coalescing on a per-queue basis
+	 */
+	for (i = 0; i < priv->hw_params->tx_queues; i++)
+		bcmgenet_tdma_ring_writel(priv, i,
+					  ec->tx_max_coalesced_frames,
+					  DMA_MBUF_DONE_THRESH);
+	bcmgenet_tdma_ring_writel(priv, DESC_INDEX,
+				  ec->tx_max_coalesced_frames,
+				  DMA_MBUF_DONE_THRESH);
+
+	return 0;
+}
+
 /* standard ethtool support functions. */
 enum bcmgenet_stat_type {
 	BCMGENET_STAT_NETDEV = -1,
@@ -844,6 +889,8 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_eee		= bcmgenet_get_eee,
 	.set_eee		= bcmgenet_set_eee,
 	.nway_reset		= bcmgenet_nway_reset,
+	.get_coalesce		= bcmgenet_get_coalesce,
+	.set_coalesce		= bcmgenet_set_coalesce,
 };
 
 /* Power down the unimac, based on mode. */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 7299d1075422..ef7829524d46 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -309,8 +309,8 @@ struct bcmgenet_mib_counters {
 #define UMAC_IRQ_TXDMA_MBDONE		(1 << 16)
 #define UMAC_IRQ_TXDMA_PDONE		(1 << 17)
 #define UMAC_IRQ_TXDMA_BDONE		(1 << 18)
-#define UMAC_IRQ_TXDMA_DONE		(UMAC_IRQ_TXDMA_PDONE | \
-					 UMAC_IRQ_TXDMA_BDONE)
+#define UMAC_IRQ_TXDMA_DONE		UMAC_IRQ_TXDMA_MBDONE
+
 /* Only valid for GENETv3+ */
 #define UMAC_IRQ_MDIO_DONE		(1 << 23)
 #define UMAC_IRQ_MDIO_ERROR		(1 << 24)
@@ -386,7 +386,7 @@ struct bcmgenet_mib_counters {
 #define DMA_RING_BUFFER_SIZE_MASK	0xFFFF
 
 /* DMA interrupt threshold register */
-#define DMA_INTR_THRESHOLD_MASK		0x00FF
+#define DMA_INTR_THRESHOLD_MASK		0x01FF
 
 /* DMA XON/XOFF register */
 #define DMA_XON_THREHOLD_MASK		0xFFFF
-- 
2.1.0
