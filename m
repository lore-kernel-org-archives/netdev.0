From: John Linn <john.linn@xilinx.com>
Subject: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Mon, 5 Apr 2010 15:11:33 -0600
Message-ID: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: john.williams@petalogix.com, michal.simek@petalogix.com,
	John Linn <john.linn@xilinx.com>,
	John Tyner <jtyner@cs.ucr.edu>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe005.messaging.microsoft.com ([207.46.51.79]:28240 "EHLO
	SG2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756412Ab0DEVMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 17:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for using the LL TEMAC Ethernet driver on
non-Virtex 5 platforms by adding support for accessing the Soft DMA
registers as if they were memory mapped instead of solely through the
DCR's (available on the Virtex 5).

The patch also updates the driver so that it runs on the MicroBlaze.
The changes were tested on the PowerPC 440, PowerPC 405, and the
MicroBlaze platforms.

Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
Signed-off-by: John Linn <john.linn@xilinx.com>

---

V2 - Incorporated comments from Grant and added more logic to allow the driver
to work on MicroBlaze.

V3 - Only updated it to apply to head, minor change to include slab.h. Also
verified that it now builds for MicroBlaze. Retested on PowerPC and MicroBlaze.
---
 drivers/net/Kconfig         |    1 -
 drivers/net/ll_temac.h      |   17 +++++-
 drivers/net/ll_temac_main.c |  124 ++++++++++++++++++++++++++++++++++---------
 3 files changed, 113 insertions(+), 29 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0ba5b8e..17044dc 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2435,7 +2435,6 @@ config MV643XX_ETH
 config XILINX_LL_TEMAC
 	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
 	select PHYLIB
-	depends on PPC_DCR_NATIVE
 	help
 	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
 	  core used in Xilinx Spartan and Virtex FPGAs
diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
index 1af66a1..915aa34 100644
--- a/drivers/net/ll_temac.h
+++ b/drivers/net/ll_temac.h
@@ -5,8 +5,11 @@
 #include <linux/netdevice.h>
 #include <linux/of.h>
 #include <linux/spinlock.h>
+
+#ifdef CONFIG_PPC_DCR
 #include <asm/dcr.h>
 #include <asm/dcr-regs.h>
+#endif
 
 /* packet size info */
 #define XTE_HDR_SIZE			14      /* size of Ethernet header */
@@ -290,8 +293,12 @@ This option defaults to enabled (set) */
 
 #define TX_CONTROL_CALC_CSUM_MASK   1
 
+/* Align the IP data in the packet on word boundaries as MicroBlaze
+ * needs it.
+ */
+
 #define XTE_ALIGN       32
-#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN)
+#define BUFFER_ALIGN(adr) ((34 - ((u32) adr)) % XTE_ALIGN)
 
 #define MULTICAST_CAM_TABLE_NUM 4
 
@@ -335,9 +342,15 @@ struct temac_local {
 	struct mii_bus *mii_bus;	/* MII bus reference */
 	int mdio_irqs[PHY_MAX_ADDR];	/* IRQs table for MDIO bus */
 
-	/* IO registers and IRQs */
+	/* IO registers, dma functions and IRQs */
 	void __iomem *regs;
+	void __iomem *sdma_regs;
+#ifdef CONFIG_PPC_DCR
 	dcr_host_t sdma_dcrs;
+#endif
+	u32 (*dma_in)(struct temac_local *, int);
+	void (*dma_out)(struct temac_local *, int, u32);
+
 	int tx_irq;
 	int rx_irq;
 	int emac_num;
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index ba617e3..801b076 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -20,9 +20,6 @@
  *   or rx, so this should be okay.
  *
  * TODO:
- * - Fix driver to work on more than just Virtex5.  Right now the driver
- *   assumes that the locallink DMA registers are accessed via DCR
- *   instructions.
  * - Factor out locallink DMA code into separate driver
  * - Fix multicast assignment.
  * - Fix support for hardware checksumming.
@@ -116,17 +113,86 @@ void temac_indirect_out32(struct temac_local *lp, int reg, u32 value)
 	temac_iow(lp, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MASK | reg);
 }
 
+/**
+ * temac_dma_in32 - Memory mapped DMA read, this function expects a
+ * register input that is based on DCR word addresses which
+ * are then converted to memory mapped byte addresses
+ */
 static u32 temac_dma_in32(struct temac_local *lp, int reg)
 {
-	return dcr_read(lp->sdma_dcrs, reg);
+	return in_be32((u32 *)(lp->sdma_regs + (reg << 2)));
 }
 
+/**
+ * temac_dma_out32 - Memory mapped DMA read, this function expects a
+ * register input that is based on DCR word addresses which
+ * are then converted to memory mapped byte addresses
+ */
 static void temac_dma_out32(struct temac_local *lp, int reg, u32 value)
 {
+	out_be32((u32 *)(lp->sdma_regs + (reg << 2)), value);
+}
+
+/* DMA register access functions can be DCR based or memory mapped.
+ * The PowerPC 440 is DCR based, the PowerPC 405 and MicroBlaze are both
+ * memory mapped.
+ */
+#ifdef CONFIG_PPC_DCR
+
+/**
+ * temac_dma_dcr_in32 - DCR based DMA read
+ */
+static u32 temac_dma_dcr_in(struct temac_local *lp, int reg)
+{
+	return dcr_read(lp->sdma_dcrs, reg);
+}
+
+/**
+ * temac_dma_dcr_out32 - DCR based DMA write
+ */
+static void temac_dma_dcr_out(struct temac_local *lp, int reg, u32 value)
+{
 	dcr_write(lp->sdma_dcrs, reg, value);
 }
 
 /**
+ * temac_dcr_setup - If the DMA is DCR based, then setup the address and
+ * I/O  functions
+ */
+static int temac_dcr_setup(struct temac_local *lp, struct of_device *op,
+				struct device_node *np)
+{
+	unsigned int dcrs;
+
+	/* setup the dcr address mapping if it's in the device tree */
+
+	dcrs = dcr_resource_start(np, 0);
+	if (dcrs != 0) {
+		lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
+		lp->dma_in = temac_dma_dcr_in;
+		lp->dma_out = temac_dma_dcr_out;
+		dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
+		return 0;
+	}
+	/* no DCR in the device tree, indicate a failure */
+	return -1;
+}
+
+#else
+
+/*
+ * temac_dcr_setup - This is a stub for when DCR is not supported,
+ * such as with MicroBlaze
+ */
+static int temac_dcr_setup(struct temac_local *lp, struct of_device *op,
+				struct device_node *np)
+{
+	return -1;
+}
+
+#endif
+
+/**
  * temac_dma_bd_init - Setup buffer descriptor rings
  */
 static int temac_dma_bd_init(struct net_device *ndev)
@@ -173,23 +239,23 @@ static int temac_dma_bd_init(struct net_device *ndev)
 		lp->rx_bd_v[i].app0 = STS_CTRL_APP0_IRQONEND;
 	}
 
-	temac_dma_out32(lp, TX_CHNL_CTRL, 0x10220400 |
+	lp->dma_out(lp, TX_CHNL_CTRL, 0x10220400 |
 					  CHNL_CTRL_IRQ_EN |
 					  CHNL_CTRL_IRQ_DLY_EN |
 					  CHNL_CTRL_IRQ_COAL_EN);
 	/* 0x10220483 */
 	/* 0x00100483 */
-	temac_dma_out32(lp, RX_CHNL_CTRL, 0xff010000 |
+	lp->dma_out(lp, RX_CHNL_CTRL, 0xff010000 |
 					  CHNL_CTRL_IRQ_EN |
 					  CHNL_CTRL_IRQ_DLY_EN |
 					  CHNL_CTRL_IRQ_COAL_EN |
 					  CHNL_CTRL_IRQ_IOE);
 	/* 0xff010283 */
 
-	temac_dma_out32(lp, RX_CURDESC_PTR,  lp->rx_bd_p);
-	temac_dma_out32(lp, RX_TAILDESC_PTR,
+	lp->dma_out(lp, RX_CURDESC_PTR,  lp->rx_bd_p);
+	lp->dma_out(lp, RX_TAILDESC_PTR,
 		       lp->rx_bd_p + (sizeof(*lp->rx_bd_v) * (RX_BD_NUM - 1)));
-	temac_dma_out32(lp, TX_CURDESC_PTR, lp->tx_bd_p);
+	lp->dma_out(lp, TX_CURDESC_PTR, lp->tx_bd_p);
 
 	return 0;
 }
@@ -427,9 +493,9 @@ static void temac_device_reset(struct net_device *ndev)
 	temac_indirect_out32(lp, XTE_RXC1_OFFSET, val & ~XTE_RXC1_RXEN_MASK);
 
 	/* Reset Local Link (DMA) */
-	temac_dma_out32(lp, DMA_CONTROL_REG, DMA_CONTROL_RST);
+	lp->dma_out(lp, DMA_CONTROL_REG, DMA_CONTROL_RST);
 	timeout = 1000;
-	while (temac_dma_in32(lp, DMA_CONTROL_REG) & DMA_CONTROL_RST) {
+	while (lp->dma_in(lp, DMA_CONTROL_REG) & DMA_CONTROL_RST) {
 		udelay(1);
 		if (--timeout == 0) {
 			dev_err(&ndev->dev,
@@ -437,7 +503,7 @@ static void temac_device_reset(struct net_device *ndev)
 			break;
 		}
 	}
-	temac_dma_out32(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
+	lp->dma_out(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
 
 	temac_dma_bd_init(ndev);
 
@@ -598,7 +664,7 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		lp->tx_bd_tail = 0;
 
 	/* Kick off the transfer */
-	temac_dma_out32(lp, TX_TAILDESC_PTR, tail_p); /* DMA start */
+	lp->dma_out(lp, TX_TAILDESC_PTR, tail_p); /* DMA start */
 
 	return NETDEV_TX_OK;
 }
@@ -664,7 +730,7 @@ static void ll_temac_recv(struct net_device *ndev)
 		cur_p = &lp->rx_bd_v[lp->rx_bd_ci];
 		bdstat = cur_p->app0;
 	}
-	temac_dma_out32(lp, RX_TAILDESC_PTR, tail_p);
+	lp->dma_out(lp, RX_TAILDESC_PTR, tail_p);
 
 	spin_unlock_irqrestore(&lp->rx_lock, flags);
 }
@@ -675,8 +741,8 @@ static irqreturn_t ll_temac_tx_irq(int irq, void *_ndev)
 	struct temac_local *lp = netdev_priv(ndev);
 	unsigned int status;
 
-	status = temac_dma_in32(lp, TX_IRQ_REG);
-	temac_dma_out32(lp, TX_IRQ_REG, status);
+	status = lp->dma_in(lp, TX_IRQ_REG);
+	lp->dma_out(lp, TX_IRQ_REG, status);
 
 	if (status & (IRQ_COAL | IRQ_DLY))
 		temac_start_xmit_done(lp->ndev);
@@ -693,8 +759,8 @@ static irqreturn_t ll_temac_rx_irq(int irq, void *_ndev)
 	unsigned int status;
 
 	/* Read and clear the status registers */
-	status = temac_dma_in32(lp, RX_IRQ_REG);
-	temac_dma_out32(lp, RX_IRQ_REG, status);
+	status = lp->dma_in(lp, RX_IRQ_REG);
+	lp->dma_out(lp, RX_IRQ_REG, status);
 
 	if (status & (IRQ_COAL | IRQ_DLY))
 		ll_temac_recv(lp->ndev);
@@ -795,7 +861,7 @@ static ssize_t temac_show_llink_regs(struct device *dev,
 	int i, len = 0;
 
 	for (i = 0; i < 0x11; i++)
-		len += sprintf(buf + len, "%.8x%s", temac_dma_in32(lp, i),
+		len += sprintf(buf + len, "%.8x%s", lp->dma_in(lp, i),
 			       (i % 8) == 7 ? "\n" : " ");
 	len += sprintf(buf + len, "\n");
 
@@ -821,7 +887,6 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	struct net_device *ndev;
 	const void *addr;
 	int size, rc = 0;
-	unsigned int dcrs;
 
 	/* Init network device structure */
 	ndev = alloc_etherdev(sizeof(*lp));
@@ -871,13 +936,20 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 		goto nodev;
 	}
 
-	dcrs = dcr_resource_start(np, 0);
-	if (dcrs == 0) {
-		dev_err(&op->dev, "could not get DMA register address\n");
-		goto nodev;
+	/* Setup the DMA register accesses, could be DCR or memory mapped */
+	if (temac_dcr_setup(lp, op, np)) {
+
+		/* no DCR in the device tree, try non-DCR */
+		lp->sdma_regs = of_iomap(np, 0);
+		if (lp->sdma_regs) {
+			lp->dma_in = temac_dma_in32;
+			lp->dma_out = temac_dma_out32;
+			dev_dbg(&op->dev, "MEM base: %p\n", lp->sdma_regs);
+		} else {
+			dev_err(&op->dev, "unable to map DMA registers\n");
+			goto nodev;
+		}
 	}
-	lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
-	dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
 
 	lp->rx_irq = irq_of_parse_and_map(np, 0);
 	lp->tx_irq = irq_of_parse_and_map(np, 1);
-- 
1.6.2.1



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


