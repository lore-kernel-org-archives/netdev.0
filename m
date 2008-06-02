From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 02/05] smc911x: Fix 16-bit I/O operations
Date: Mon, 02 Jun 2008 20:37:23 +0900
Message-ID: <20080602113723.28716.78846.sendpatchset@rx1.opensource.se>
References: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	akpm@linux-foundation.org, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:47685 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbYFBLhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 07:37:10 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1003094rvb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 04:37:10 -0700 (PDT)
In-Reply-To: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following issues related to 16-bit support:
 - Remove unused 16-bit PXA DMA implementation.
 - Remove unused SMC_inw() and SMC_outw() functions.
 - Fix 16-bit SMC_outl to use writew() instead of writel().

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc911x.h |   66 ++-----------------------------------------------
 1 file changed, 3 insertions(+), 63 deletions(-)

--- 0002/drivers/net/smc911x.h
+++ work/drivers/net/smc911x.h	2008-06-02 12:39:11.000000000 +0900
@@ -50,19 +50,16 @@
  */
 
 #if	SMC_USE_16BIT
-#define SMC_inw(a, r)			 readw((a) + (r))
-#define SMC_inl(a, r)			 ((SMC_inw(a, r) & 0xFFFF)+(SMC_inw(a+2, r)<<16))
-#define SMC_outw(v, a, r)		 writew(v, (a) + (r))
+#define SMC_inl(a, r)		 (readw((a) + (r)) & 0xFFFF) + (readw((a) + (r) + 2) << 16))
 #define SMC_outl(v, a, r) 			 \
 	do{					 \
-		 writel(v & 0xFFFF, (a) + (r));	 \
-		 writel(v >> 16, (a) + (r) + 2); \
+		 writew(v & 0xFFFF, (a) + (r));	 \
+		 writew(v >> 16, (a) + (r) + 2); \
 	 } while (0)
 #define SMC_insl(a, r, p, l)	 readsw((short*)((a) + (r)), p, l*2)
 #define SMC_outsl(a, r, p, l)	 writesw((short*)((a) + (r)), p, l*2)
 
 #elif	SMC_USE_32BIT
-#define SMC_inw(a, r)		 readw((a) + (r))
 #define SMC_inl(a, r)		 readl((a) + (r))
 #define SMC_outl(v, a, r)	 writel(v, (a) + (r))
 #define SMC_insl(a, r, p, l)	 readsl((int*)((a) + (r)), p, l)
@@ -132,34 +129,6 @@ smc_pxa_dma_insl(struct device *dev, u_l
 }
 #endif
 
-#ifdef SMC_insw
-#undef SMC_insw
-#define SMC_insw(a, r, p, l) \
-	smc_pxa_dma_insw(lp->dev, a, lp->physaddr, r, lp->rxdma, p, l)
-
-static inline void
-smc_pxa_dma_insw(struct device *dev, u_long ioaddr, u_long physaddr,
-		int reg, int dma, u_char *buf, int len)
-{
-	/* 64 bit alignment is required for memory to memory DMA */
-	while ((long)buf & 6) {
-		*((u16 *)buf) = SMC_inw(ioaddr, reg);
-		buf += 2;
-		len--;
-	}
-
-	len *= 2;
-	rx_dmabuf = dma_map_single(dev, buf, len, DMA_FROM_DEVICE);
-	rx_dmalen = len;
-	DCSR(dma) = DCSR_NODESC;
-	DTADR(dma) = rx_dmabuf;
-	DSADR(dma) = physaddr + reg;
-	DCMD(dma) = (DCMD_INCTRGADDR | DCMD_BURST32 |
-		DCMD_WIDTH2 | DCMD_ENDIRQEN | (DCMD_LENGTH & rx_dmalen));
-	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
-}
-#endif
-
 #ifdef SMC_outsl
 #undef SMC_outsl
 #define SMC_outsl(a, r, p, l) \
@@ -187,35 +156,6 @@ smc_pxa_dma_outsl(struct device *dev, u_
 	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
 }
 #endif
-
-#ifdef SMC_outsw
-#undef SMC_outsw
-#define SMC_outsw(a, r, p, l) \
-	smc_pxa_dma_outsw(lp->dev, a, lp->physaddr, r, lp->txdma, p, l)
-
-static inline void
-smc_pxa_dma_outsw(struct device *dev, u_long ioaddr, u_long physaddr,
-		  int reg, int dma, u_char *buf, int len)
-{
-	/* 64 bit alignment is required for memory to memory DMA */
-	while ((long)buf & 6) {
-		SMC_outw(*((u16 *)buf), ioaddr, reg);
-		buf += 2;
-		len--;
-	}
-
-	len *= 2;
-	tx_dmabuf = dma_map_single(dev, buf, len, DMA_TO_DEVICE);
-	tx_dmalen = len;
-	DCSR(dma) = DCSR_NODESC;
-	DSADR(dma) = tx_dmabuf;
-	DTADR(dma) = physaddr + reg;
-	DCMD(dma) = (DCMD_INCSRCADDR | DCMD_BURST32 |
-		DCMD_WIDTH2 | DCMD_ENDIRQEN | (DCMD_LENGTH & tx_dmalen));
-	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
-}
-#endif
-
 #endif	 /* SMC_USE_PXA_DMA */
 
 
