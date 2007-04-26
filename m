From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] It appears that some systems still like e100 better if it uses
Date: Thu, 26 Apr 2007 09:22:45 -0700
Message-ID: <20070426162245.17960.74045.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: jeff@garzik.org, jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22984 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031335AbXDZQWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 12:22:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

I/O access mode.  Setting the new parameter use_io=1 will cause
all driver instances to use io mapping to access the register
space on the e100 device.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |   72 ++++++++++++++++++++++++++++------------------------
 1 files changed, 39 insertions(+), 33 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 7d9984a..7ca207c 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -159,7 +159,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.5.17-k2"DRV_EXT
+#define DRV_VERSION		"3.5.17-k4"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -174,10 +174,13 @@ MODULE_VERSION(DRV_VERSION);
 
 static int debug = 3;
 static int eeprom_bad_csum_allow = 0;
+static int use_io = 0;
 module_param(debug, int, 0);
 module_param(eeprom_bad_csum_allow, int, 0);
+module_param(use_io, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 MODULE_PARM_DESC(eeprom_bad_csum_allow, "Allow bad eeprom checksums");
+MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & nic->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, nic->netdev->name, \
@@ -584,7 +587,7 @@ static inline void e100_write_flush(struct nic *nic)
 {
 	/* Flush previous PCI writes through intermediate bridges
 	 * by doing a benign read */
-	(void)readb(&nic->csr->scb.status);
+	(void)ioread8(&nic->csr->scb.status);
 }
 
 static void e100_enable_irq(struct nic *nic)
@@ -592,7 +595,7 @@ static void e100_enable_irq(struct nic *nic)
 	unsigned long flags;
 
 	spin_lock_irqsave(&nic->cmd_lock, flags);
-	writeb(irq_mask_none, &nic->csr->scb.cmd_hi);
+	iowrite8(irq_mask_none, &nic->csr->scb.cmd_hi);
 	e100_write_flush(nic);
 	spin_unlock_irqrestore(&nic->cmd_lock, flags);
 }
@@ -602,7 +605,7 @@ static void e100_disable_irq(struct nic *nic)
 	unsigned long flags;
 
 	spin_lock_irqsave(&nic->cmd_lock, flags);
-	writeb(irq_mask_all, &nic->csr->scb.cmd_hi);
+	iowrite8(irq_mask_all, &nic->csr->scb.cmd_hi);
 	e100_write_flush(nic);
 	spin_unlock_irqrestore(&nic->cmd_lock, flags);
 }
@@ -611,11 +614,11 @@ static void e100_hw_reset(struct nic *nic)
 {
 	/* Put CU and RU into idle with a selective reset to get
 	 * device off of PCI bus */
-	writel(selective_reset, &nic->csr->port);
+	iowrite32(selective_reset, &nic->csr->port);
 	e100_write_flush(nic); udelay(20);
 
 	/* Now fully reset device */
-	writel(software_reset, &nic->csr->port);
+	iowrite32(software_reset, &nic->csr->port);
 	e100_write_flush(nic); udelay(20);
 
 	/* Mask off our interrupt line - it's unmasked after reset */
@@ -632,7 +635,7 @@ static int e100_self_test(struct nic *nic)
 	nic->mem->selftest.signature = 0;
 	nic->mem->selftest.result = 0xFFFFFFFF;
 
-	writel(selftest | dma_addr, &nic->csr->port);
+	iowrite32(selftest | dma_addr, &nic->csr->port);
 	e100_write_flush(nic);
 	/* Wait 10 msec for self-test to complete */
 	msleep(10);
@@ -670,23 +673,23 @@ static void e100_eeprom_write(struct nic *nic, u16 addr_len, u16 addr, u16 data)
 	for(j = 0; j < 3; j++) {
 
 		/* Chip select */
-		writeb(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
+		iowrite8(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
 
 		for(i = 31; i >= 0; i--) {
 			ctrl = (cmd_addr_data[j] & (1 << i)) ?
 				eecs | eedi : eecs;
-			writeb(ctrl, &nic->csr->eeprom_ctrl_lo);
+			iowrite8(ctrl, &nic->csr->eeprom_ctrl_lo);
 			e100_write_flush(nic); udelay(4);
 
-			writeb(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
+			iowrite8(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
 			e100_write_flush(nic); udelay(4);
 		}
 		/* Wait 10 msec for cmd to complete */
 		msleep(10);
 
 		/* Chip deselect */
-		writeb(0, &nic->csr->eeprom_ctrl_lo);
+		iowrite8(0, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
 	}
 };
@@ -702,21 +705,21 @@ static u16 e100_eeprom_read(struct nic *nic, u16 *addr_len, u16 addr)
 	cmd_addr_data = ((op_read << *addr_len) | addr) << 16;
 
 	/* Chip select */
-	writeb(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
+	iowrite8(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
 	e100_write_flush(nic); udelay(4);
 
 	/* Bit-bang to read word from eeprom */
 	for(i = 31; i >= 0; i--) {
 		ctrl = (cmd_addr_data & (1 << i)) ? eecs | eedi : eecs;
-		writeb(ctrl, &nic->csr->eeprom_ctrl_lo);
+		iowrite8(ctrl, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
 
-		writeb(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
+		iowrite8(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
 
 		/* Eeprom drives a dummy zero to EEDO after receiving
 		 * complete address.  Use this to adjust addr_len. */
-		ctrl = readb(&nic->csr->eeprom_ctrl_lo);
+		ctrl = ioread8(&nic->csr->eeprom_ctrl_lo);
 		if(!(ctrl & eedo) && i > 16) {
 			*addr_len -= (i - 16);
 			i = 17;
@@ -726,7 +729,7 @@ static u16 e100_eeprom_read(struct nic *nic, u16 *addr_len, u16 addr)
 	}
 
 	/* Chip deselect */
-	writeb(0, &nic->csr->eeprom_ctrl_lo);
+	iowrite8(0, &nic->csr->eeprom_ctrl_lo);
 	e100_write_flush(nic); udelay(4);
 
 	return le16_to_cpu(data);
@@ -797,7 +800,7 @@ static int e100_exec_cmd(struct nic *nic, u8 cmd, dma_addr_t dma_addr)
 
 	/* Previous command is accepted when SCB clears */
 	for(i = 0; i < E100_WAIT_SCB_TIMEOUT; i++) {
-		if(likely(!readb(&nic->csr->scb.cmd_lo)))
+		if(likely(!ioread8(&nic->csr->scb.cmd_lo)))
 			break;
 		cpu_relax();
 		if(unlikely(i > E100_WAIT_SCB_FAST))
@@ -809,8 +812,8 @@ static int e100_exec_cmd(struct nic *nic, u8 cmd, dma_addr_t dma_addr)
 	}
 
 	if(unlikely(cmd != cuc_resume))
-		writel(dma_addr, &nic->csr->scb.gen_ptr);
-	writeb(cmd, &nic->csr->scb.cmd_lo);
+		iowrite32(dma_addr, &nic->csr->scb.gen_ptr);
+	iowrite8(cmd, &nic->csr->scb.cmd_lo);
 
 err_unlock:
 	spin_unlock_irqrestore(&nic->cmd_lock, flags);
@@ -888,7 +891,7 @@ static u16 mdio_ctrl(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data)
 	 */
 	spin_lock_irqsave(&nic->mdio_lock, flags);
 	for (i = 100; i; --i) {
-		if (readl(&nic->csr->mdi_ctrl) & mdi_ready)
+		if (ioread32(&nic->csr->mdi_ctrl) & mdi_ready)
 			break;
 		udelay(20);
 	}
@@ -898,11 +901,11 @@ static u16 mdio_ctrl(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data)
 		spin_unlock_irqrestore(&nic->mdio_lock, flags);
 		return 0;		/* No way to indicate timeout error */
 	}
-	writel((reg << 16) | (addr << 21) | dir | data, &nic->csr->mdi_ctrl);
+	iowrite32((reg << 16) | (addr << 21) | dir | data, &nic->csr->mdi_ctrl);
 
 	for (i = 0; i < 100; i++) {
 		udelay(20);
-		if ((data_out = readl(&nic->csr->mdi_ctrl)) & mdi_ready)
+		if ((data_out = ioread32(&nic->csr->mdi_ctrl)) & mdi_ready)
 			break;
 	}
 	spin_unlock_irqrestore(&nic->mdio_lock, flags);
@@ -1311,7 +1314,7 @@ static inline int e100_exec_cb_wait(struct nic *nic, struct sk_buff *skb,
 	}
 
 	/* ack any interupts, something could have been set */
-	writeb(~0, &nic->csr->scb.stat_ack);
+	iowrite8(~0, &nic->csr->scb.stat_ack);
 
 	/* if the command failed, or is not OK, notify and return */
 	if (!counter || !(cb->status & cpu_to_le16(cb_ok))) {
@@ -1573,7 +1576,7 @@ static void e100_watchdog(unsigned long data)
 	 * accidentally, due to hardware that shares a register between the
 	 * interrupt mask bit and the SW Interrupt generation bit */
 	spin_lock_irq(&nic->cmd_lock);
-	writeb(readb(&nic->csr->scb.cmd_hi) | irq_sw_gen,&nic->csr->scb.cmd_hi);
+	iowrite8(ioread8(&nic->csr->scb.cmd_hi) | irq_sw_gen,&nic->csr->scb.cmd_hi);
 	e100_write_flush(nic);
 	spin_unlock_irq(&nic->cmd_lock);
 
@@ -1902,7 +1905,7 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 {
 	struct net_device *netdev = dev_id;
 	struct nic *nic = netdev_priv(netdev);
-	u8 stat_ack = readb(&nic->csr->scb.stat_ack);
+	u8 stat_ack = ioread8(&nic->csr->scb.stat_ack);
 
 	DPRINTK(INTR, DEBUG, "stat_ack = 0x%02X\n", stat_ack);
 
@@ -1911,7 +1914,7 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	/* Ack interrupt(s) */
-	writeb(stat_ack, &nic->csr->scb.stat_ack);
+	iowrite8(stat_ack, &nic->csr->scb.stat_ack);
 
 	if(likely(netif_rx_schedule_prep(netdev))) {
 		e100_disable_irq(nic);
@@ -2053,7 +2056,7 @@ static void e100_tx_timeout_task(struct work_struct *work)
 	struct net_device *netdev = nic->netdev;
 
 	DPRINTK(TX_ERR, DEBUG, "scb.status=0x%02X\n",
-		readb(&nic->csr->scb.status));
+		ioread8(&nic->csr->scb.status));
 	e100_down(netdev_priv(netdev));
 	e100_up(netdev_priv(netdev));
 }
@@ -2176,9 +2179,9 @@ static void e100_get_regs(struct net_device *netdev,
 	int i;
 
 	regs->version = (1 << 24) | nic->rev_id;
-	buff[0] = readb(&nic->csr->scb.cmd_hi) << 24 |
-		readb(&nic->csr->scb.cmd_lo) << 16 |
-		readw(&nic->csr->scb.status);
+	buff[0] = ioread8(&nic->csr->scb.cmd_hi) << 24 |
+		ioread8(&nic->csr->scb.cmd_lo) << 16 |
+		ioread16(&nic->csr->scb.status);
 	for(i = E100_PHY_REGS; i >= 0; i--)
 		buff[1 + E100_PHY_REGS - i] =
 			mdio_read(netdev, nic->mii.phy_id, i);
@@ -2550,7 +2553,10 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-	nic->csr = ioremap(pci_resource_start(pdev, 0), sizeof(struct csr));
+	if (use_io)
+		DPRINTK(PROBE, INFO, "using i/o access mode\n");
+
+	nic->csr = pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
 	if(!nic->csr) {
 		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
 		err = -ENOMEM;
@@ -2627,7 +2633,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 
 	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, "
 		"MAC addr %02X:%02X:%02X:%02X:%02X:%02X\n",
-		(unsigned long long)pci_resource_start(pdev, 0), pdev->irq,
+		(unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0), pdev->irq,
 		netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
 		netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
 
@@ -2636,7 +2642,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 err_out_free:
 	e100_free(nic);
 err_out_iounmap:
-	iounmap(nic->csr);
+	pci_iounmap(pdev, nic->csr);
 err_out_free_res:
 	pci_release_regions(pdev);
 err_out_disable_pdev:
