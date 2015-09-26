From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v3 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Sat, 26 Sep 2015 20:49:19 +0200
Message-ID: <1443293360-16377-2-git-send-email-robert.jarzmik@free.fr>
References: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Robert Jarzmik <robert.jarzmik@free.fr>
To: Samuel Ortiz <samuel@sortiz.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the pxa IRDA driver to readl and writel primitives, and remove
another set of direct registers access. This leaves only the DMA
registers access, which will be dealt with dmaengine conversion.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
Tested-by: Petr Cvek <petr.cvek@tul.cz>
---
Since v1: modified __REG macro to cope with STIER, ST* registers
---
 drivers/net/irda/pxaficp_ir.c | 210 +++++++++++++++++++++++++-----------------
 1 file changed, 126 insertions(+), 84 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 6a81d3d1b312..05a668216a0f 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -29,15 +29,16 @@
 
 #include <mach/dma.h>
 #include <linux/platform_data/irda-pxaficp.h>
+#undef __REG
+#define __REG(x) ((x) & 0xffff)
 #include <mach/regs-uart.h>
 
-#define FICP		__REG(0x40800000)  /* Start of FICP area */
-#define ICCR0		__REG(0x40800000)  /* ICP Control Register 0 */
-#define ICCR1		__REG(0x40800004)  /* ICP Control Register 1 */
-#define ICCR2		__REG(0x40800008)  /* ICP Control Register 2 */
-#define ICDR		__REG(0x4080000c)  /* ICP Data Register */
-#define ICSR0		__REG(0x40800014)  /* ICP Status Register 0 */
-#define ICSR1		__REG(0x40800018)  /* ICP Status Register 1 */
+#define ICCR0		0x0000		/* ICP Control Register 0 */
+#define ICCR1		0x0004		/* ICP Control Register 1 */
+#define ICCR2		0x0008		/* ICP Control Register 2 */
+#define ICDR		0x000c		/* ICP Data Register */
+#define ICSR0		0x0014		/* ICP Status Register 0 */
+#define ICSR1		0x0018		/* ICP Status Register 1 */
 
 #define ICCR0_AME	(1 << 7)	/* Address match enable */
 #define ICCR0_TIE	(1 << 6)	/* Transmit FIFO interrupt enable */
@@ -55,9 +56,7 @@
 #define ICCR2_TRIG_16   (1 << 0)	/*	>= 16 bytes */
 #define ICCR2_TRIG_32   (2 << 0)	/*	>= 32 bytes */
 
-#ifdef CONFIG_PXA27x
 #define ICSR0_EOC	(1 << 6)	/* DMA End of Descriptor Chain */
-#endif
 #define ICSR0_FRE	(1 << 5)	/* Framing error */
 #define ICSR0_RFS	(1 << 4)	/* Receive FIFO service request */
 #define ICSR0_TFS	(1 << 3)	/* Transnit FIFO service request */
@@ -98,11 +97,50 @@
                 IrSR_RCVEIR_UART_MODE | \
                 IrSR_XMITIR_IR_MODE)
 
+/* macros for registers read/write */
+#define ficp_writel(irda, val, off)					\
+	do {								\
+		dev_vdbg(irda->dev,					\
+			 "%s():%d ficp_writel(0x%x, %s)\n",		\
+			 __func__, __LINE__, (val), #off);		\
+		writel_relaxed((val), (irda)->irda_base + (off));	\
+	} while (0)
+
+#define ficp_readl(irda, off)						\
+	({								\
+		unsigned int _v;					\
+		_v = readl_relaxed((irda)->irda_base + (off));		\
+		dev_vdbg(irda->dev,					\
+			 "%s():%d ficp_readl(%s): 0x%x\n",		\
+			 __func__, __LINE__, #off, _v);			\
+		_v;							\
+	})
+
+#define stuart_writel(irda, val, off)					\
+	do {								\
+		dev_vdbg(irda->dev,					\
+			 "%s():%d stuart_writel(0x%x, %s)\n",		\
+			 __func__, __LINE__, (val), #off);		\
+		writel_relaxed((val), (irda)->stuart_base + (off));	\
+	} while (0)
+
+#define stuart_readl(irda, off)						\
+	({								\
+		unsigned int _v;					\
+		_v = readl_relaxed((irda)->stuart_base + (off));	\
+		dev_vdbg(irda->dev,					\
+			 "%s():%d stuart_readl(%s): 0x%x\n",		\
+			 __func__, __LINE__, #off, _v);			\
+		_v;							\
+	})
+
 struct pxa_irda {
 	int			speed;
 	int			newspeed;
 	unsigned long long	last_clk;
 
+	void __iomem		*stuart_base;
+	void __iomem		*irda_base;
 	unsigned char		*dma_rx_buff;
 	unsigned char		*dma_tx_buff;
 	dma_addr_t		dma_rx_buff_phy;
@@ -153,7 +191,7 @@ static inline void pxa_irda_enable_sirclk(struct pxa_irda *si)
 inline static void pxa_irda_fir_dma_rx_start(struct pxa_irda *si)
 {
 	DCSR(si->rxdma)  = DCSR_NODESC;
-	DSADR(si->rxdma) = __PREG(ICDR);
+	DSADR(si->rxdma) = (unsigned long)si->irda_base + ICDR;
 	DTADR(si->rxdma) = si->dma_rx_buff_phy;
 	DCMD(si->rxdma) = DCMD_INCTRGADDR | DCMD_FLOWSRC |  DCMD_WIDTH1 | DCMD_BURST32 | IRDA_FRAME_SIZE_LIMIT;
 	DCSR(si->rxdma) |= DCSR_RUN;
@@ -163,7 +201,7 @@ inline static void pxa_irda_fir_dma_tx_start(struct pxa_irda *si)
 {
 	DCSR(si->txdma)  = DCSR_NODESC;
 	DSADR(si->txdma) = si->dma_tx_buff_phy;
-	DTADR(si->txdma) = __PREG(ICDR);
+	DTADR(si->txdma) = (unsigned long)si->irda_base + ICDR;
 	DCMD(si->txdma) = DCMD_INCSRCADDR | DCMD_FLOWTRG |  DCMD_ENDIRQEN | DCMD_WIDTH1 | DCMD_BURST32 | si->dma_tx_buff_len;
 	DCSR(si->txdma) |= DCSR_RUN;
 }
@@ -206,7 +244,7 @@ static int pxa_irda_set_speed(struct pxa_irda *si, int speed)
 			/* stop RX DMA */
 			DCSR(si->rxdma) &= ~DCSR_RUN;
 			/* disable FICP */
-			ICCR0 = 0;
+			ficp_writel(si, 0, ICCR0);
 			pxa_irda_disable_clk(si);
 
 			/* set board transceiver to SIR mode */
@@ -217,17 +255,19 @@ static int pxa_irda_set_speed(struct pxa_irda *si, int speed)
 		}
 
 		/* disable STUART first */
-		STIER = 0;
+		stuart_writel(si, 0, STIER);
 
 		/* access DLL & DLH */
-		STLCR |= LCR_DLAB;
-		STDLL = divisor & 0xff;
-		STDLH = divisor >> 8;
-		STLCR &= ~LCR_DLAB;
+		stuart_writel(si, stuart_readl(si, STLCR) | LCR_DLAB, STLCR);
+		stuart_writel(si, divisor & 0xff, STDLL);
+		stuart_writel(si, divisor >> 8, STDLH);
+		stuart_writel(si, stuart_readl(si, STLCR) & ~LCR_DLAB, STLCR);
 
 		si->speed = speed;
-		STISR = IrSR_IR_RECEIVE_ON | IrSR_XMODE_PULSE_1_6;
-		STIER = IER_UUE | IER_RLSE | IER_RAVIE | IER_RTIOE;
+		stuart_writel(si, IrSR_IR_RECEIVE_ON | IrSR_XMODE_PULSE_1_6,
+			      STISR);
+		stuart_writel(si, IER_UUE | IER_RLSE | IER_RAVIE | IER_RTIOE,
+			      STIER);
 
 		local_irq_restore(flags);
 		break;
@@ -236,12 +276,12 @@ static int pxa_irda_set_speed(struct pxa_irda *si, int speed)
 		local_irq_save(flags);
 
 		/* disable STUART */
-		STIER = 0;
-		STISR = 0;
+		stuart_writel(si, 0, STIER);
+		stuart_writel(si, 0, STISR);
 		pxa_irda_disable_clk(si);
 
 		/* disable FICP first */
-		ICCR0 = 0;
+		ficp_writel(si, 0, ICCR0);
 
 		/* set board transceiver to FIR mode */
 		pxa_irda_set_mode(si, IR_FIRMODE);
@@ -251,7 +291,7 @@ static int pxa_irda_set_speed(struct pxa_irda *si, int speed)
 
 		si->speed = speed;
 		pxa_irda_fir_dma_rx_start(si);
-		ICCR0 = ICCR0_ITR | ICCR0_RXE;
+		ficp_writel(si, ICCR0_ITR | ICCR0_RXE, ICCR0);
 
 		local_irq_restore(flags);
 		break;
@@ -270,13 +310,13 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 	struct pxa_irda *si = netdev_priv(dev);
 	int iir, lsr, data;
 
-	iir = STIIR;
+	iir = stuart_readl(si, STIIR);
 
 	switch  (iir & 0x0F) {
 	case 0x06: /* Receiver Line Status */
-	  	lsr = STLSR;
+		lsr = stuart_readl(si, STLSR);
 		while (lsr & LSR_FIFOE) {
-			data = STRBR;
+			data = stuart_readl(si, STRBR);
 			if (lsr & (LSR_OE | LSR_PE | LSR_FE | LSR_BI)) {
 				printk(KERN_DEBUG "pxa_ir: sir receiving error\n");
 				dev->stats.rx_errors++;
@@ -289,7 +329,7 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 				async_unwrap_char(dev, &dev->stats,
 						  &si->rx_buff, data);
 			}
-			lsr = STLSR;
+			lsr = stuart_readl(si, STLSR);
 		}
 		si->last_clk = sched_clock();
 		break;
@@ -300,14 +340,16 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 	case 0x0C: /* Character Timeout Indication */
 	  	do  {
 		    dev->stats.rx_bytes++;
-	            async_unwrap_char(dev, &dev->stats, &si->rx_buff, STRBR);
-	  	} while (STLSR & LSR_DR);
+		    async_unwrap_char(dev, &dev->stats, &si->rx_buff,
+				      stuart_readl(si, STRBR));
+		} while (stuart_readl(si, STLSR) & LSR_DR);
 		si->last_clk = sched_clock();
 	  	break;
 
 	case 0x02: /* Transmit FIFO Data Request */
-	    	while ((si->tx_buff.len) && (STLSR & LSR_TDRQ)) {
-	    		STTHR = *si->tx_buff.data++;
+		while ((si->tx_buff.len) &&
+		       (stuart_readl(si, STLSR) & LSR_TDRQ)) {
+			stuart_writel(si, *si->tx_buff.data++, STTHR);
 			si->tx_buff.len -= 1;
 	    	}
 
@@ -316,7 +358,7 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 			dev->stats.tx_bytes += si->tx_buff.data - si->tx_buff.head;
 
                         /* We need to ensure that the transmitter has finished. */
-			while ((STLSR & LSR_TEMT) == 0)
+			while ((stuart_readl(si, STLSR) & LSR_TEMT) == 0)
 				cpu_relax();
 			si->last_clk = sched_clock();
 
@@ -330,9 +372,11 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 				si->newspeed = 0;
 			} else {
 				/* enable IR Receiver, disable IR Transmitter */
-				STISR = IrSR_IR_RECEIVE_ON | IrSR_XMODE_PULSE_1_6;
+				stuart_writel(si, IrSR_IR_RECEIVE_ON |
+					      IrSR_XMODE_PULSE_1_6, STISR);
 				/* enable STUART and receive interrupts */
-				STIER = IER_UUE | IER_RLSE | IER_RAVIE | IER_RTIOE;
+				stuart_writel(si, IER_UUE | IER_RLSE |
+					      IER_RAVIE | IER_RTIOE, STIER);
 			}
 			/* I'm hungry! */
 			netif_wake_queue(dev);
@@ -370,7 +414,7 @@ static void pxa_irda_fir_dma_tx_irq(int channel, void *data)
 		dev->stats.tx_errors++;
 	}
 
-	while (ICSR1 & ICSR1_TBY)
+	while (ficp_readl(si, ICSR1) & ICSR1_TBY)
 		cpu_relax();
 	si->last_clk = sched_clock();
 
@@ -386,11 +430,11 @@ static void pxa_irda_fir_dma_tx_irq(int channel, void *data)
 	} else {
 		int i = 64;
 
-		ICCR0 = 0;
+		ficp_writel(si, 0, ICCR0);
 		pxa_irda_fir_dma_rx_start(si);
-		while ((ICSR1 & ICSR1_RNE) && i--)
-			(void)ICDR;
-		ICCR0 = ICCR0_ITR | ICCR0_RXE;
+		while ((ficp_readl(si, ICSR1) & ICSR1_RNE) && i--)
+			ficp_readl(si, ICDR);
+		ficp_writel(si, ICCR0_ITR | ICCR0_RXE, ICCR0);
 
 		if (i < 0)
 			printk(KERN_ERR "pxa_ir: cannot clear Rx FIFO!\n");
@@ -408,9 +452,9 @@ static void pxa_irda_fir_irq_eif(struct pxa_irda *si, struct net_device *dev, in
 
 	do {
 		/* Read Status, and then Data. 	 */
-		stat = ICSR1;
+		stat = ficp_readl(si, ICSR1);
 		rmb();
-		data = ICDR;
+		data = ficp_readl(si, ICDR);
 
 		if (stat & (ICSR1_CRE | ICSR1_ROR)) {
 			dev->stats.rx_errors++;
@@ -428,7 +472,7 @@ static void pxa_irda_fir_irq_eif(struct pxa_irda *si, struct net_device *dev, in
 		/* If we hit the end of frame, there's no point in continuing. */
 		if (stat & ICSR1_EOF)
 			break;
-	} while (ICSR0 & ICSR0_EIF);
+	} while (ficp_readl(si, ICSR0) & ICSR0_EIF);
 
 	if (stat & ICSR1_EOF) {
 		/* end of frame. */
@@ -472,8 +516,8 @@ static irqreturn_t pxa_irda_fir_irq(int irq, void *dev_id)
 
 	/* stop RX DMA */
 	DCSR(si->rxdma) &= ~DCSR_RUN;
-	icsr0 = ICSR0;
 	si->last_clk = sched_clock();
+	icsr0 = ficp_readl(si, ICSR0);
 
 	if (icsr0 & (ICSR0_FRE | ICSR0_RAB)) {
 		if (icsr0 & ICSR0_FRE) {
@@ -483,7 +527,7 @@ static irqreturn_t pxa_irda_fir_irq(int irq, void *dev_id)
 			printk(KERN_DEBUG "pxa_ir: fir receive abort\n");
 			dev->stats.rx_errors++;
 		}
-		ICSR0 = icsr0 & (ICSR0_FRE | ICSR0_RAB);
+		ficp_writel(si, icsr0 & (ICSR0_FRE | ICSR0_RAB), ICSR0);
 	}
 
 	if (icsr0 & ICSR0_EIF) {
@@ -491,11 +535,11 @@ static irqreturn_t pxa_irda_fir_irq(int irq, void *dev_id)
 		pxa_irda_fir_irq_eif(si, dev, icsr0);
 	}
 
-	ICCR0 = 0;
+	ficp_writel(si, 0, ICCR0);
 	pxa_irda_fir_dma_rx_start(si);
-	while ((ICSR1 & ICSR1_RNE) && i--)
-		(void)ICDR;
-	ICCR0 = ICCR0_ITR | ICCR0_RXE;
+	while ((ficp_readl(si, ICSR1) & ICSR1_RNE) && i--)
+		ficp_readl(si, ICDR);
+	ficp_writel(si, ICCR0_ITR | ICCR0_RXE, ICCR0);
 
 	if (i < 0)
 		printk(KERN_ERR "pxa_ir: cannot clear Rx FIFO!\n");
@@ -536,11 +580,12 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 		si->tx_buff.len  = async_wrap_skb(skb, si->tx_buff.data, si->tx_buff.truesize);
 
 		/* Disable STUART interrupts and switch to transmit mode. */
-		STIER = 0;
-		STISR = IrSR_IR_TRANSMIT_ON | IrSR_XMODE_PULSE_1_6;
+		stuart_writel(si, 0, STIER);
+		stuart_writel(si, IrSR_IR_TRANSMIT_ON | IrSR_XMODE_PULSE_1_6,
+			      STISR);
 
 		/* enable STUART and transmit interrupts */
-		STIER = IER_UUE | IER_TIE;
+		stuart_writel(si, IER_UUE | IER_TIE, STIER);
 	} else {
 		unsigned long mtt = irda_get_mtt(skb);
 
@@ -553,10 +598,10 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* stop RX DMA,  disable FICP */
 		DCSR(si->rxdma) &= ~DCSR_RUN;
-		ICCR0 = 0;
+		ficp_writel(si, 0, ICCR0);
 
 		pxa_irda_fir_dma_tx_start(si);
-		ICCR0 = ICCR0_ITR | ICCR0_TXE;
+		ficp_writel(si, ICCR0_ITR | ICCR0_TXE, ICCR0);
 	}
 
 	dev_kfree_skb(skb);
@@ -612,18 +657,18 @@ static int pxa_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 static void pxa_irda_startup(struct pxa_irda *si)
 {
 	/* Disable STUART interrupts */
-	STIER = 0;
+	stuart_writel(si, 0, STIER);
 	/* enable STUART interrupt to the processor */
-	STMCR = MCR_OUT2;
+	stuart_writel(si, MCR_OUT2, STMCR);
 	/* configure SIR frame format: StartBit - Data 7 ... Data 0 - Stop Bit */
-	STLCR = LCR_WLS0 | LCR_WLS1;
+	stuart_writel(si, LCR_WLS0 | LCR_WLS1, STLCR);
 	/* enable FIFO, we use FIFO to improve performance */
-	STFCR = FCR_TRFIFOE | FCR_ITL_32;
+	stuart_writel(si, FCR_TRFIFOE | FCR_ITL_32, STFCR);
 
 	/* disable FICP */
-	ICCR0 = 0;
+	ficp_writel(si, 0, ICCR0);
 	/* configure FICP ICCR2 */
-	ICCR2 = ICCR2_TXP | ICCR2_TRIG_32;
+	ficp_writel(si, ICCR2_TXP | ICCR2_TRIG_32, ICCR2);
 
 	/* configure DMAC */
 	DRCMR(17) = si->rxdma | DRCMR_MAPVLD;
@@ -643,15 +688,15 @@ static void pxa_irda_shutdown(struct pxa_irda *si)
 	local_irq_save(flags);
 
 	/* disable STUART and interrupt */
-	STIER = 0;
+	stuart_writel(si, 0, STIER);
 	/* disable STUART SIR mode */
-	STISR = 0;
+	stuart_writel(si, 0, STISR);
 
 	/* disable DMA */
 	DCSR(si->txdma) &= ~DCSR_RUN;
 	DCSR(si->rxdma) &= ~DCSR_RUN;
 	/* disable FICP */
-	ICCR0 = 0;
+	ficp_writel(si, 0, ICCR0);
 
 	/* disable the STUART or FICP clocks */
 	pxa_irda_disable_clk(si);
@@ -829,25 +874,33 @@ static const struct net_device_ops pxa_irda_netdev_ops = {
 static int pxa_irda_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
+	struct resource *res;
 	struct pxa_irda *si;
+	void __iomem *ficp, *stuart;
 	unsigned int baudrate_mask;
 	int err;
 
 	if (!pdev->dev.platform_data)
 		return -ENODEV;
 
-	err = request_mem_region(__PREG(STUART), 0x24, "IrDA") ? 0 : -EBUSY;
-	if (err)
-		goto err_mem_1;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	ficp = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(ficp)) {
+		dev_err(&pdev->dev, "resource ficp not defined\n");
+		return PTR_ERR(ficp);
+	}
 
-	err = request_mem_region(__PREG(FICP), 0x1c, "IrDA") ? 0 : -EBUSY;
-	if (err)
-		goto err_mem_2;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	stuart = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(stuart)) {
+		dev_err(&pdev->dev, "resource stuart not defined\n");
+		return PTR_ERR(stuart);
+	}
 
 	dev = alloc_irdadev(sizeof(struct pxa_irda));
 	if (!dev) {
 		err = -ENOMEM;
-		goto err_mem_3;
+		goto err_mem_1;
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -855,11 +908,13 @@ static int pxa_irda_probe(struct platform_device *pdev)
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
 
+	si->irda_base = ficp;
+	si->stuart_base = stuart;
 	si->uart_irq = platform_get_irq(pdev, 0);
 	si->icp_irq = platform_get_irq(pdev, 1);
 
-	si->sir_clk = clk_get(&pdev->dev, "UARTCLK");
-	si->fir_clk = clk_get(&pdev->dev, "FICPCLK");
+	si->sir_clk = devm_clk_get(&pdev->dev, "UARTCLK");
+	si->fir_clk = devm_clk_get(&pdev->dev, "FICPCLK");
 	if (IS_ERR(si->sir_clk) || IS_ERR(si->fir_clk)) {
 		err = PTR_ERR(IS_ERR(si->sir_clk) ? si->sir_clk : si->fir_clk);
 		goto err_mem_4;
@@ -924,15 +979,7 @@ err_startup:
 err_mem_5:
 		kfree(si->rx_buff.head);
 err_mem_4:
-		if (si->sir_clk && !IS_ERR(si->sir_clk))
-			clk_put(si->sir_clk);
-		if (si->fir_clk && !IS_ERR(si->fir_clk))
-			clk_put(si->fir_clk);
 		free_netdev(dev);
-err_mem_3:
-		release_mem_region(__PREG(FICP), 0x1c);
-err_mem_2:
-		release_mem_region(__PREG(STUART), 0x24);
 	}
 err_mem_1:
 	return err;
@@ -951,14 +998,9 @@ static int pxa_irda_remove(struct platform_device *_dev)
 			si->pdata->shutdown(si->dev);
 		kfree(si->tx_buff.head);
 		kfree(si->rx_buff.head);
-		clk_put(si->fir_clk);
-		clk_put(si->sir_clk);
 		free_netdev(dev);
 	}
 
-	release_mem_region(__PREG(STUART), 0x24);
-	release_mem_region(__PREG(FICP), 0x1c);
-
 	return 0;
 }
 
-- 
2.1.4
