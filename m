From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: bcmgenet: Implement RX coalescing control knobs
Date: Wed, 16 Sep 2015 16:47:40 -0700
Message-ID: <1442447260-14129-3-git-send-email-f.fainelli@gmail.com>
References: <1442447260-14129-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34307 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbbIPXvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 19:51:25 -0400
Received: by padhy16 with SMTP id hy16so2211979pad.1
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 16:51:25 -0700 (PDT)
In-Reply-To: <1442447260-14129-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the ethtool rx-frames coalescing parameter which allows
defining the number of RX interrupts per frames received. The RDMA
engine supports a configurable timeout with a resolution of
approximately 8.192 us.

We can no longer enable the BDONE/PDONE interrupts as those would
fire for each packet/buffer received, which would defeat the MBDONE
interrupt purpose. The MBDONE interrupt is guaranteed to correspond to a
PDONE/BDONE interrupt when the threshold is set to 1.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 105 ++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |   3 +-
 2 files changed, 105 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 5e247c7b379e..1e72722abbf1 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -205,6 +205,23 @@ enum dma_reg {
 	DMA_INDEX2RING_5,
 	DMA_INDEX2RING_6,
 	DMA_INDEX2RING_7,
+	DMA_RING0_TIMEOUT,
+	DMA_RING1_TIMEOUT,
+	DMA_RING2_TIMEOUT,
+	DMA_RING3_TIMEOUT,
+	DMA_RING4_TIMEOUT,
+	DMA_RING5_TIMEOUT,
+	DMA_RING6_TIMEOUT,
+	DMA_RING7_TIMEOUT,
+	DMA_RING8_TIMEOUT,
+	DMA_RING9_TIMEOUT,
+	DMA_RING10_TIMEOUT,
+	DMA_RING11_TIMEOUT,
+	DMA_RING12_TIMEOUT,
+	DMA_RING13_TIMEOUT,
+	DMA_RING14_TIMEOUT,
+	DMA_RING15_TIMEOUT,
+	DMA_RING16_TIMEOUT,
 };
 
 static const u8 bcmgenet_dma_regs_v3plus[] = {
@@ -216,6 +233,23 @@ static const u8 bcmgenet_dma_regs_v3plus[] = {
 	[DMA_PRIORITY_0]	= 0x30,
 	[DMA_PRIORITY_1]	= 0x34,
 	[DMA_PRIORITY_2]	= 0x38,
+	[DMA_RING0_TIMEOUT]	= 0x2C,
+	[DMA_RING1_TIMEOUT]	= 0x30,
+	[DMA_RING2_TIMEOUT]	= 0x34,
+	[DMA_RING3_TIMEOUT]	= 0x38,
+	[DMA_RING4_TIMEOUT]	= 0x3c,
+	[DMA_RING5_TIMEOUT]	= 0x40,
+	[DMA_RING6_TIMEOUT]	= 0x44,
+	[DMA_RING7_TIMEOUT]	= 0x48,
+	[DMA_RING8_TIMEOUT]	= 0x4c,
+	[DMA_RING9_TIMEOUT]	= 0x50,
+	[DMA_RING10_TIMEOUT]	= 0x54,
+	[DMA_RING11_TIMEOUT]	= 0x58,
+	[DMA_RING12_TIMEOUT]	= 0x5c,
+	[DMA_RING13_TIMEOUT]	= 0x60,
+	[DMA_RING14_TIMEOUT]	= 0x64,
+	[DMA_RING15_TIMEOUT]	= 0x68,
+	[DMA_RING16_TIMEOUT]	= 0x6C,
 	[DMA_INDEX2RING_0]	= 0x70,
 	[DMA_INDEX2RING_1]	= 0x74,
 	[DMA_INDEX2RING_2]	= 0x78,
@@ -235,6 +269,23 @@ static const u8 bcmgenet_dma_regs_v2[] = {
 	[DMA_PRIORITY_0]	= 0x34,
 	[DMA_PRIORITY_1]	= 0x38,
 	[DMA_PRIORITY_2]	= 0x3C,
+	[DMA_RING0_TIMEOUT]	= 0x2C,
+	[DMA_RING1_TIMEOUT]	= 0x30,
+	[DMA_RING2_TIMEOUT]	= 0x34,
+	[DMA_RING3_TIMEOUT]	= 0x38,
+	[DMA_RING4_TIMEOUT]	= 0x3c,
+	[DMA_RING5_TIMEOUT]	= 0x40,
+	[DMA_RING6_TIMEOUT]	= 0x44,
+	[DMA_RING7_TIMEOUT]	= 0x48,
+	[DMA_RING8_TIMEOUT]	= 0x4c,
+	[DMA_RING9_TIMEOUT]	= 0x50,
+	[DMA_RING10_TIMEOUT]	= 0x54,
+	[DMA_RING11_TIMEOUT]	= 0x58,
+	[DMA_RING12_TIMEOUT]	= 0x5c,
+	[DMA_RING13_TIMEOUT]	= 0x60,
+	[DMA_RING14_TIMEOUT]	= 0x64,
+	[DMA_RING15_TIMEOUT]	= 0x68,
+	[DMA_RING16_TIMEOUT]	= 0x6C,
 };
 
 static const u8 bcmgenet_dma_regs_v1[] = {
@@ -245,6 +296,23 @@ static const u8 bcmgenet_dma_regs_v1[] = {
 	[DMA_PRIORITY_0]	= 0x34,
 	[DMA_PRIORITY_1]	= 0x38,
 	[DMA_PRIORITY_2]	= 0x3C,
+	[DMA_RING0_TIMEOUT]	= 0x2C,
+	[DMA_RING1_TIMEOUT]	= 0x30,
+	[DMA_RING2_TIMEOUT]	= 0x34,
+	[DMA_RING3_TIMEOUT]	= 0x38,
+	[DMA_RING4_TIMEOUT]	= 0x3c,
+	[DMA_RING5_TIMEOUT]	= 0x40,
+	[DMA_RING6_TIMEOUT]	= 0x44,
+	[DMA_RING7_TIMEOUT]	= 0x48,
+	[DMA_RING8_TIMEOUT]	= 0x4c,
+	[DMA_RING9_TIMEOUT]	= 0x50,
+	[DMA_RING10_TIMEOUT]	= 0x54,
+	[DMA_RING11_TIMEOUT]	= 0x58,
+	[DMA_RING12_TIMEOUT]	= 0x5c,
+	[DMA_RING13_TIMEOUT]	= 0x60,
+	[DMA_RING14_TIMEOUT]	= 0x64,
+	[DMA_RING15_TIMEOUT]	= 0x68,
+	[DMA_RING16_TIMEOUT]	= 0x6C,
 };
 
 /* Set at runtime once bcmgenet version is known */
@@ -506,6 +574,11 @@ static int bcmgenet_get_coalesce(struct net_device *dev,
 	ec->tx_max_coalesced_frames =
 		bcmgenet_tdma_ring_readl(priv, DESC_INDEX,
 					 DMA_MBUF_DONE_THRESH);
+	ec->rx_max_coalesced_frames =
+		bcmgenet_rdma_ring_readl(priv, DESC_INDEX,
+					 DMA_MBUF_DONE_THRESH);
+	ec->rx_coalesce_usecs =
+		bcmgenet_rdma_readl(priv, DMA_RING16_TIMEOUT) * 8192 / 1000;
 
 	return 0;
 }
@@ -515,9 +588,19 @@ static int bcmgenet_set_coalesce(struct net_device *dev,
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	unsigned int i;
+	u32 reg;
 
+	/* Base system clock is 125Mhz, DMA timeout is this reference clock
+	 * divided by 1024, which yields roughly 8.192us, our maximum value
+	 * has to fit in the DMA_TIMEOUT_MASK (16 bits)
+	 */
 	if (ec->tx_max_coalesced_frames > DMA_INTR_THRESHOLD_MASK ||
-	    ec->tx_max_coalesced_frames == 0)
+	    ec->tx_max_coalesced_frames == 0 ||
+	    ec->rx_max_coalesced_frames > DMA_INTR_THRESHOLD_MASK ||
+	    ec->rx_coalesce_usecs > (DMA_TIMEOUT_MASK * 8) + 1)
+		return -EINVAL;
+
+	if (ec->rx_coalesce_usecs == 0 && ec->rx_max_coalesced_frames == 0)
 		return -EINVAL;
 
 	/* GENET TDMA hardware does not support a configurable timeout, but will
@@ -540,6 +623,26 @@ static int bcmgenet_set_coalesce(struct net_device *dev,
 				  ec->tx_max_coalesced_frames,
 				  DMA_MBUF_DONE_THRESH);
 
+	for (i = 0; i < priv->hw_params->rx_queues; i++) {
+		bcmgenet_rdma_ring_writel(priv, i,
+					  ec->rx_max_coalesced_frames,
+					  DMA_MBUF_DONE_THRESH);
+
+		reg = bcmgenet_rdma_readl(priv, DMA_RING0_TIMEOUT + i);
+		reg &= ~DMA_TIMEOUT_MASK;
+		reg |= DIV_ROUND_UP(ec->rx_coalesce_usecs * 1000, 8192);
+		bcmgenet_rdma_writel(priv, reg, DMA_RING0_TIMEOUT + i);
+	}
+
+	bcmgenet_rdma_ring_writel(priv, DESC_INDEX,
+				  ec->rx_max_coalesced_frames,
+				  DMA_MBUF_DONE_THRESH);
+
+	reg = bcmgenet_rdma_readl(priv, DMA_RING16_TIMEOUT);
+	reg &= ~DMA_TIMEOUT_MASK;
+	reg |= DIV_ROUND_UP(ec->rx_coalesce_usecs * 1000, 8192);
+	bcmgenet_rdma_writel(priv, reg, DMA_RING16_TIMEOUT);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index ef7829524d46..29dc2f1bbb19 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -304,8 +304,7 @@ struct bcmgenet_mib_counters {
 #define UMAC_IRQ_RXDMA_MBDONE		(1 << 13)
 #define UMAC_IRQ_RXDMA_PDONE		(1 << 14)
 #define UMAC_IRQ_RXDMA_BDONE		(1 << 15)
-#define UMAC_IRQ_RXDMA_DONE		(UMAC_IRQ_RXDMA_PDONE | \
-					 UMAC_IRQ_RXDMA_BDONE)
+#define UMAC_IRQ_RXDMA_DONE		UMAC_IRQ_RXDMA_MBDONE
 #define UMAC_IRQ_TXDMA_MBDONE		(1 << 16)
 #define UMAC_IRQ_TXDMA_PDONE		(1 << 17)
 #define UMAC_IRQ_TXDMA_BDONE		(1 << 18)
-- 
2.1.0
