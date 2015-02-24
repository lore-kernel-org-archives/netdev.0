From: Arun Chandran <achandran@mvista.com>
Subject: [PATCH] net: macb: Add big endian CPU support
Date: Tue, 24 Feb 2015 13:09:32 +0530
Message-ID: <1424763572-23317-1-git-send-email-achandran@mvista.com>
References: <54EB34E7.7060400@monstr.eu>
Cc: Arun Chandran <achandran@mvista.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54EB34E7.7060400@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch converts all __raw_readl and __raw_writel function calls
to their corresponding readl_relaxed and writel_relaxed variants.

It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
when the cpu is configured in big endian mode.

Signed-off-by: Arun Chandran <achandran@mvista.com>
---
	This patch is tested on xilinx ZC702 evaluation board with
	CONFIG_CPU_BIG_ENDIAN=y and booting NFS rootfs
	Added on the fly IP endianness detection according to
	comments from Michal Simek.
---
---
 drivers/net/ethernet/cadence/macb.c | 33 +++++++++++++++++++++++++++------
 drivers/net/ethernet/cadence/macb.h | 15 ++++++++-------
 2 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ad76b8e..1642911 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
 	WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
 
 	for(; p < end; p++, reg++)
-		*p += __raw_readl(reg);
+		*p += readl_relaxed(reg);
 }
 
 static int macb_halt_tx(struct macb *bp)
@@ -1578,6 +1578,7 @@ static u32 macb_dbw(struct macb *bp)
 static void macb_configure_dma(struct macb *bp)
 {
 	u32 dmacfg;
+	u32 tmp, ncr;
 
 	if (macb_is_gem(bp)) {
 		dmacfg = gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
@@ -1585,7 +1586,25 @@ static void macb_configure_dma(struct macb *bp)
 		if (bp->dma_burst_length)
 			dmacfg = GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
 		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
-		dmacfg &= ~GEM_BIT(ENDIA);
+		dmacfg &= ~GEM_BIT(ENDIA_PKT);
+
+		/* Here we use the loopback bit of net_ctrl register to detect
+		 * endianness on IP. save it first. Program swaped mode for
+		 * management descriptor accesses if writing to loop back bit
+		 * and reading it back brings no change in bit value.
+		 */
+		ncr = macb_readl(bp, NCR);
+		__raw_writel(MACB_BIT(LLB), bp->regs + MACB_NCR);
+		tmp =  __raw_readl(bp->regs + MACB_NCR);
+
+		if (tmp == MACB_BIT(LLB))
+			dmacfg &= ~GEM_BIT(ENDIA_DESC);
+		else
+			dmacfg |= GEM_BIT(ENDIA_DESC);
+
+		/* Restore net_ctrl */
+		macb_writel(bp, NCR, ncr);
+
 		if (bp->dev->features & NETIF_F_HW_CSUM)
 			dmacfg |= GEM_BIT(TXCOEN);
 		else
@@ -1832,14 +1851,14 @@ static void gem_update_stats(struct macb *bp)
 
 	for (i = 0; i < GEM_STATS_LEN; ++i, ++p) {
 		u32 offset = gem_statistics[i].offset;
-		u64 val = __raw_readl(bp->regs + offset);
+		u64 val = readl_relaxed(bp->regs + offset);
 
 		bp->ethtool_stats[i] += val;
 		*p += val;
 
 		if (offset == GEM_OCTTXL || offset == GEM_OCTRXL) {
 			/* Add GEM_OCTTXH, GEM_OCTRXH */
-			val = __raw_readl(bp->regs + offset + 4);
+			val = readl_relaxed(bp->regs + offset + 4);
 			bp->ethtool_stats[i] += ((u64)val) << 32;
 			*(++p) += val;
 		}
@@ -2191,12 +2210,14 @@ static void macb_probe_queues(void __iomem *mem,
 	*num_queues = 1;
 
 	/* is it macb or gem ? */
-	mid = __raw_readl(mem + MACB_MID);
+	mid = readl_relaxed(mem + MACB_MID);
+
 	if (MACB_BFEXT(IDNUM, mid) != 0x2)
 		return;
 
 	/* bit 0 is never set but queue 0 always exists */
-	*queue_mask = __raw_readl(mem + GEM_DCFG6) & 0xff;
+	*queue_mask = readl_relaxed(mem + GEM_DCFG6) & 0xff;
+
 	*queue_mask |= 0x1;
 
 	for (hw_q = 1; hw_q < MACB_MAX_QUEUES; ++hw_q)
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 31dc080..57f0a1a 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -229,7 +229,8 @@
 /* Bitfields in DMACFG. */
 #define GEM_FBLDO_OFFSET	0 /* fixed burst length for DMA */
 #define GEM_FBLDO_SIZE		5
-#define GEM_ENDIA_OFFSET	7 /* endian swap mode for packet data access */
+#define GEM_ENDIA_DESC_OFFSET	6 /* endian swap mode for management descriptor access */
+#define GEM_ENDIA_PKT_OFFSET	7 /* endian swap mode for packet data access */
 #define GEM_ENDIA_SIZE		1
 #define GEM_RXBMS_OFFSET	8 /* RX packet buffer memory size select */
 #define GEM_RXBMS_SIZE		2
@@ -423,17 +424,17 @@
 
 /* Register access macros */
 #define macb_readl(port,reg)				\
-	__raw_readl((port)->regs + MACB_##reg)
+	readl_relaxed((port)->regs + MACB_##reg)
 #define macb_writel(port,reg,value)			\
-	__raw_writel((value), (port)->regs + MACB_##reg)
+	writel_relaxed((value), (port)->regs + MACB_##reg)
 #define gem_readl(port, reg)				\
-	__raw_readl((port)->regs + GEM_##reg)
+	readl_relaxed((port)->regs + GEM_##reg)
 #define gem_writel(port, reg, value)			\
-	__raw_writel((value), (port)->regs + GEM_##reg)
+	writel_relaxed((value), (port)->regs + GEM_##reg)
 #define queue_readl(queue, reg)				\
-	__raw_readl((queue)->bp->regs + (queue)->reg)
+	readl_relaxed((queue)->bp->regs + (queue)->reg)
 #define queue_writel(queue, reg, value)			\
-	__raw_writel((value), (queue)->bp->regs + (queue)->reg)
+	writel_relaxed((value), (queue)->bp->regs + (queue)->reg)
 
 /* Conditional GEM/MACB macros.  These perform the operation to the correct
  * register dependent on whether the device is a GEM or a MACB.  For registers
-- 
1.9.1
