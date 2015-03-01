From: Arun Chandran <achandran@mvista.com>
Subject: [PATCH 1/2] net: macb: Add on the fly CPU endianness detection
Date: Sun,  1 Mar 2015 11:38:02 +0530
Message-ID: <1425190083-16007-1-git-send-email-achandran@mvista.com>
References: <20150227.172430.705343480463996651.davem@davemloft.net>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	Arun Chandran <achandran@mvista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:32891 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbbCAGI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 01:08:56 -0500
Received: by pdjz10 with SMTP id z10so31271043pdj.0
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 22:08:55 -0800 (PST)
In-Reply-To: <20150227.172430.705343480463996651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Program management descriptor's access mode according to the
dynamically detected CPU endianness.

Signed-off-by: Arun Chandran <achandran@mvista.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Tested-by: Michal Simek <michal.simek@xilinx.com>
---
* Adding CPU endianness detection according to Michal Simek
* Added Acked-by: Nicolas Ferre
* Added Tested-by: Michal Simek
---
---
 drivers/net/ethernet/cadence/macb.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 05fb36d..1fe8b94 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1578,6 +1578,7 @@ static u32 macb_dbw(struct macb *bp)
 static void macb_configure_dma(struct macb *bp)
 {
 	u32 dmacfg;
+	u32 tmp, ncr;
 
 	if (macb_is_gem(bp)) {
 		dmacfg = gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
@@ -1586,10 +1587,23 @@ static void macb_configure_dma(struct macb *bp)
 			dmacfg = GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
 		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
 		dmacfg &= ~GEM_BIT(ENDIA_PKT);
-		/* Tell the chip to byteswap descriptors on big-endian hosts */
-#ifdef __BIG_ENDIAN
-		dmacfg |= GEM_BIT(ENDIA_DESC);
-#endif
+
+		/* Find the CPU endianness by using the loopback bit of net_ctrl
+		 * register. save it first. When the CPU is in big endian we
+		 * need to program swaped mode for management descriptor access.
+		 */
+		ncr = macb_readl(bp, NCR);
+		__raw_writel(MACB_BIT(LLB), bp->regs + MACB_NCR);
+		tmp =  __raw_readl(bp->regs + MACB_NCR);
+
+		if (tmp == MACB_BIT(LLB))
+			dmacfg &= ~GEM_BIT(ENDIA_DESC);
+		else
+			dmacfg |= GEM_BIT(ENDIA_DESC); /* CPU in big endian */
+
+		/* Restore net_ctrl */
+		macb_writel(bp, NCR, ncr);
+
 		if (bp->dev->features & NETIF_F_HW_CSUM)
 			dmacfg |= GEM_BIT(TXCOEN);
 		else
-- 
1.9.1
