From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH] net: smc91x: convert pxa dma to dmaengine
Date: Thu, 10 Sep 2015 21:26:04 +0200
Message-ID: <1441913164-3785-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Robert Jarzmik <robert.jarzmik@free.fr>
To: Nicolas Pitre <nico@fluxnic.net>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the dma transfers to be dmaengine based, now pxa has a dmaengine
slave driver. This makes this driver a bit more PXA agnostic.

The driver was tested on pxa27x (mainstone) and pxa310 (zylonite),
ie. only pxa platforms.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>
---
This has potential to break other platform such as Neponset, Idp,
halibut and qsd8x50, so I added Russell and Arnd as they were discussing
smc91x support last February.
---
 drivers/net/ethernet/smsc/smc91x.c | 29 +++++++----
 drivers/net/ethernet/smsc/smc91x.h | 99 +++++++++++++++++++++++++-------------
 2 files changed, 84 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 630f0b7800e4..0e2fc1a844ab 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2018,10 +2018,18 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	lp->cfg.flags |= SMC91X_USE_DMA;
 #  endif
 	if (lp->cfg.flags & SMC91X_USE_DMA) {
-		int dma = pxa_request_dma(dev->name, DMA_PRIO_LOW,
-					  smc_pxa_dma_irq, NULL);
-		if (dma >= 0)
-			dev->dma = dma;
+		dma_cap_mask_t mask;
+		struct pxad_param param;
+
+		dma_cap_zero(mask);
+		dma_cap_set(DMA_SLAVE, mask);
+		param.prio = PXAD_PRIO_LOWEST;
+		param.drcmr = -1UL;
+
+		lp->dma_chan =
+			dma_request_slave_channel_compat(mask, pxad_filter_fn,
+							 &param, &dev->dev,
+							 "data");
 	}
 #endif
 
@@ -2032,8 +2040,8 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 			    version_string, revision_register & 0x0f,
 			    lp->base, dev->irq);
 
-		if (dev->dma != (unsigned char)-1)
-			pr_cont(" DMA %d", dev->dma);
+		if (lp->dma_chan)
+			pr_cont(" DMA %p", lp->dma_chan);
 
 		pr_cont("%s%s\n",
 			lp->cfg.flags & SMC91X_NOWAIT ? " [nowait]" : "",
@@ -2058,8 +2066,8 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 
 err_out:
 #ifdef CONFIG_ARCH_PXA
-	if (retval && dev->dma != (unsigned char)-1)
-		pxa_free_dma(dev->dma);
+	if (retval && lp->dma_chan)
+		dma_release_channel(lp->dma_chan);
 #endif
 	return retval;
 }
@@ -2370,6 +2378,7 @@ static int smc_drv_probe(struct platform_device *pdev)
 		struct smc_local *lp = netdev_priv(ndev);
 		lp->device = &pdev->dev;
 		lp->physaddr = res->start;
+
 	}
 #endif
 
@@ -2406,8 +2415,8 @@ static int smc_drv_remove(struct platform_device *pdev)
 	free_irq(ndev->irq, ndev);
 
 #ifdef CONFIG_ARCH_PXA
-	if (ndev->dma != (unsigned char)-1)
-		pxa_free_dma(ndev->dma);
+	if (lp->dma_chan)
+		dma_release_channel(lp->dma_chan);
 #endif
 	iounmap(lp->base);
 
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 3a18501d1068..a3c129e1e40a 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -33,6 +33,7 @@
 #ifndef _SMC91X_H_
 #define _SMC91X_H_
 
+#include <linux/dmaengine.h>
 #include <linux/smc91x.h>
 
 /*
@@ -244,6 +245,7 @@ struct smc_local {
 	u_long physaddr;
 	struct device *device;
 #endif
+	struct dma_chan *dma_chan;
 	void __iomem *base;
 	void __iomem *datacs;
 
@@ -265,21 +267,47 @@ struct smc_local {
  * as RX which can overrun memory and lose packets.
  */
 #include <linux/dma-mapping.h>
-#include <mach/dma.h>
+#include <linux/dma/pxa-dma.h>
 
 #ifdef SMC_insl
 #undef SMC_insl
 #define SMC_insl(a, r, p, l) \
 	smc_pxa_dma_insl(a, lp, r, dev->dma, p, l)
 static inline void
+smc_pxa_dma_inpump(struct smc_local *lp, u_char *buf, int len)
+{
+	dma_addr_t dmabuf;
+	struct dma_async_tx_descriptor *tx;
+	dma_cookie_t cookie;
+	enum dma_status status;
+	struct dma_tx_state state;
+
+	dmabuf = dma_map_single(lp->device, buf, len, DMA_FROM_DEVICE);
+	tx = dmaengine_prep_slave_single(lp->dma_chan, dmabuf, len,
+					 DMA_DEV_TO_MEM, 0);
+	if (tx) {
+		cookie = dmaengine_submit(tx);
+		dma_async_issue_pending(lp->dma_chan);
+		do {
+			status = dmaengine_tx_status(lp->dma_chan, cookie,
+						     &state);
+			cpu_relax();
+		} while (status != DMA_COMPLETE && status != DMA_ERROR &&
+			 state.residue);
+		dmaengine_terminate_all(lp->dma_chan);
+	}
+	dma_unmap_single(lp->device, dmabuf, len, DMA_FROM_DEVICE);
+}
+
+static inline void
 smc_pxa_dma_insl(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
 		 u_char *buf, int len)
 {
-	u_long physaddr = lp->physaddr;
-	dma_addr_t dmabuf;
+	struct dma_slave_config	config;
+	int ret;
 
 	/* fallback if no DMA available */
-	if (dma == (unsigned char)-1) {
+	if (!lp->dma_chan) {
 		readsl(ioaddr + reg, buf, len);
 		return;
 	}
@@ -291,18 +319,22 @@ smc_pxa_dma_insl(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
 		len--;
 	}
 
+	memset(&config, 0, sizeof(config));
+	config.src_addr_width = DMA_SLAVE_BUSWIDTH_4_BYTES;
+	config.dst_addr_width = DMA_SLAVE_BUSWIDTH_4_BYTES;
+	config.src_addr = lp->physaddr + reg;
+	config.dst_addr = lp->physaddr + reg;
+	config.src_maxburst = 32;
+	config.dst_maxburst = 32;
+	ret = dmaengine_slave_config(lp->dma_chan, &config);
+	if (ret) {
+		dev_err(lp->device, "dma channel configuration failed: %d\n",
+			ret);
+		return;
+	}
+
 	len *= 4;
-	dmabuf = dma_map_single(lp->device, buf, len, DMA_FROM_DEVICE);
-	DCSR(dma) = DCSR_NODESC;
-	DTADR(dma) = dmabuf;
-	DSADR(dma) = physaddr + reg;
-	DCMD(dma) = (DCMD_INCTRGADDR | DCMD_BURST32 |
-		     DCMD_WIDTH4 | (DCMD_LENGTH & len));
-	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
-	while (!(DCSR(dma) & DCSR_STOPSTATE))
-		cpu_relax();
-	DCSR(dma) = 0;
-	dma_unmap_single(lp->device, dmabuf, len, DMA_FROM_DEVICE);
+	smc_pxa_dma_inpump(lp, buf, len);
 }
 #endif
 
@@ -314,11 +346,11 @@ static inline void
 smc_pxa_dma_insw(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
 		 u_char *buf, int len)
 {
-	u_long physaddr = lp->physaddr;
-	dma_addr_t dmabuf;
+	struct dma_slave_config	config;
+	int ret;
 
 	/* fallback if no DMA available */
-	if (dma == (unsigned char)-1) {
+	if (!lp->dma_chan) {
 		readsw(ioaddr + reg, buf, len);
 		return;
 	}
@@ -330,26 +362,25 @@ smc_pxa_dma_insw(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
 		len--;
 	}
 
+	memset(&config, 0, sizeof(config));
+	config.src_addr_width = DMA_SLAVE_BUSWIDTH_2_BYTES;
+	config.dst_addr_width = DMA_SLAVE_BUSWIDTH_2_BYTES;
+	config.src_addr = lp->physaddr + reg;
+	config.dst_addr = lp->physaddr + reg;
+	config.src_maxburst = 32;
+	config.dst_maxburst = 32;
+	ret = dmaengine_slave_config(lp->dma_chan, &config);
+	if (ret) {
+		dev_err(lp->device, "dma channel configuration failed: %d\n",
+			ret);
+		return;
+	}
+
 	len *= 2;
-	dmabuf = dma_map_single(lp->device, buf, len, DMA_FROM_DEVICE);
-	DCSR(dma) = DCSR_NODESC;
-	DTADR(dma) = dmabuf;
-	DSADR(dma) = physaddr + reg;
-	DCMD(dma) = (DCMD_INCTRGADDR | DCMD_BURST32 |
-		     DCMD_WIDTH2 | (DCMD_LENGTH & len));
-	DCSR(dma) = DCSR_NODESC | DCSR_RUN;
-	while (!(DCSR(dma) & DCSR_STOPSTATE))
-		cpu_relax();
-	DCSR(dma) = 0;
-	dma_unmap_single(lp->device, dmabuf, len, DMA_FROM_DEVICE);
+	smc_pxa_dma_inpump(lp, buf, len);
 }
 #endif
 
-static void
-smc_pxa_dma_irq(int dma, void *dummy)
-{
-	DCSR(dma) = 0;
-}
 #endif  /* CONFIG_ARCH_PXA */
 
 
-- 
2.1.4
