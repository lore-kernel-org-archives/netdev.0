From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] net: macb: fix endian code for avr32
Date: Wed, 18 Mar 2015 10:57:27 +0000
Message-ID: <1426676247-14023-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	Linux Networking List <netdev@vger.kernel.org>,
	Arun Chandran <achandran@mvista.com>,
	Haavard Skinnemoen <hskinnemoen@gmail.com>,
	Hans-Christian Egtvedt <egtvedt@samfundet.no>,
	Linux Kernel List <linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:50061 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118AbbCRK5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:57:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[note this has yet to be compile tested on avr32]

The changes to run the macb driver in 29af05aeb98e ("net: macb:
Add big endian CPU support") to support big endian operation on
ARM may not work on AVR32 which already is naturally big endian
architecture (and the driver already works here).

In this case  the readl/writel relaxed will do the opposite of __raw
accesors which arleady work. Add an indirection of cdneth_ prefixed
accesors which are changed as necessary. Also do not issue the DMA
descritpor endian fetch configuration for AVR32.

>From discussions with Arnd Bergman, the following fix changes the use
of readl_relaxed and writel_relaxed with a version that can be put
back to __raw_readl/__raw_writel for the CONFIG_AVR32 case (and also
remove the change to the DMA descriptor endian).

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
Reported-by: Arnd Bergmann <arnd@arndb.de>
--
CC: Linux Networking List <netdev@vger.kernel.org>
CC: Arun Chandran <achandran@mvista.com>
CC: Haavard Skinnemoen <hskinnemoen@gmail.com>
CC: Hans-Christian Egtvedt <egtvedt@samfundet.no>
CC: Linux Kernel List <linux-kernel@vger.kernel.org>
CC: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 14 +++++++-------
 drivers/net/ethernet/cadence/macb.h | 20 ++++++++++++++------
 2 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index b71e316..1c3f6e7 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
 	WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
 
 	for(; p < end; p++, reg++)
-		*p += readl_relaxed(reg);
+		*p += cdneth_readl(reg);
 }
 
 static int macb_halt_tx(struct macb *bp)
@@ -1587,7 +1587,7 @@ static void macb_configure_dma(struct macb *bp)
 		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
 		dmacfg &= ~GEM_BIT(ENDIA_PKT);
 		/* Tell the chip to byteswap descriptors on big-endian hosts */
-#ifdef __BIG_ENDIAN
+#if defined(__BIG_ENDIAN) && !defined(CONFIG_AVR32)
 		dmacfg |= GEM_BIT(ENDIA_DESC);
 #endif
 		if (bp->dev->features & NETIF_F_HW_CSUM)
@@ -1836,14 +1836,14 @@ static void gem_update_stats(struct macb *bp)
 
 	for (i = 0; i < GEM_STATS_LEN; ++i, ++p) {
 		u32 offset = gem_statistics[i].offset;
-		u64 val = readl_relaxed(bp->regs + offset);
+		u64 val = cdneth_readl(bp->regs + offset);
 
 		bp->ethtool_stats[i] += val;
 		*p += val;
 
 		if (offset == GEM_OCTTXL || offset == GEM_OCTRXL) {
 			/* Add GEM_OCTTXH, GEM_OCTRXH */
-			val = readl_relaxed(bp->regs + offset + 4);
+			val = cdneth_readl(bp->regs + offset + 4);
 			bp->ethtool_stats[i] += ((u64)val) << 32;
 			*(++p) += val;
 		}
@@ -2191,17 +2191,17 @@ static void macb_probe_queues(void __iomem *mem,
 	unsigned int hw_q;
 	u32 mid;
 
-	*queue_mask = 0x1;
+	*queue_mask = 0x1;\
 	*num_queues = 1;
 
 	/* is it macb or gem ? */
-	mid = readl_relaxed(mem + MACB_MID);
+	mid = cdneth_readl(mem + MACB_MID);
 
 	if (MACB_BFEXT(IDNUM, mid) != 0x2)
 		return;
 
 	/* bit 0 is never set but queue 0 always exists */
-	*queue_mask = readl_relaxed(mem + GEM_DCFG6) & 0xff;
+	*queue_mask = cdneth_readl(mem + GEM_DCFG6) & 0xff;
 
 	*queue_mask |= 0x1;
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 6cfff0b..c003e98 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -422,19 +422,27 @@
 		    << GEM_##name##_OFFSET))		\
 	 | GEM_BF(name, value))
 
+#ifdef CONFIG_AVR32
+#define cdneth_readl	__raw_readl
+#define cdneth_writel	__raw_writel
+#else
+#define cdneth_readl	readl_relaxed
+#define cdneth_writel	writel_relaxed
+#endif
+
 /* Register access macros */
 #define macb_readl(port,reg)				\
-	readl_relaxed((port)->regs + MACB_##reg)
+	cdneth_readl((port)->regs + MACB_##reg)
 #define macb_writel(port,reg,value)			\
-	writel_relaxed((value), (port)->regs + MACB_##reg)
+	cdneth_writel((value), (port)->regs + MACB_##reg)
 #define gem_readl(port, reg)				\
-	readl_relaxed((port)->regs + GEM_##reg)
+	cdneth_readl((port)->regs + GEM_##reg)
 #define gem_writel(port, reg, value)			\
-	writel_relaxed((value), (port)->regs + GEM_##reg)
+	cdneth_writel((value), (port)->regs + GEM_##reg)
 #define queue_readl(queue, reg)				\
-	readl_relaxed((queue)->bp->regs + (queue)->reg)
+	cdneth_readl((queue)->bp->regs + (queue)->reg)
 #define queue_writel(queue, reg, value)			\
-	writel_relaxed((value), (queue)->bp->regs + (queue)->reg)
+	cdneth_writel((value), (queue)->bp->regs + (queue)->reg)
 
 /* Conditional GEM/MACB macros.  These perform the operation to the correct
  * register dependent on whether the device is a GEM or a MACB.  For registers
-- 
2.1.4
