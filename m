From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 04/15] drivers/net/bnx2.c: Use (pr|netdev|netif)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:51 -0800
Message-ID: <9b889787bedb71e606928eb956861eb6292583f7.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: Michael Chan <mchan@broadcom.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1057 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755518Ab0BRBCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:02:09 -0500
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Use netif_<level>
Remove periods from formats
Coalesce long formats
Coalesce some printks

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bnx2.c |  145 ++++++++++++++++++++++------------------------------
 1 files changed, 61 insertions(+), 84 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 5f0dda1..a6cc9d0 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -9,6 +9,7 @@
  * Written by: Michael Chan  (mchan@broadcom.com)
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -57,7 +58,6 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define PFX DRV_MODULE_NAME	": "
 #define DRV_MODULE_VERSION	"2.0.8"
 #define DRV_MODULE_RELDATE	"Feb 15, 2010"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-5.0.0.j6.fw"
@@ -979,33 +979,27 @@ bnx2_report_link(struct bnx2 *bp)
 {
 	if (bp->link_up) {
 		netif_carrier_on(bp->dev);
-		printk(KERN_INFO PFX "%s NIC %s Link is Up, ", bp->dev->name,
-		       bnx2_xceiver_str(bp));
-
-		printk("%d Mbps ", bp->line_speed);
-
-		if (bp->duplex == DUPLEX_FULL)
-			printk("full duplex");
-		else
-			printk("half duplex");
+		netdev_info(bp->dev, "NIC %s Link is Up, %d Mbps %s duplex",
+			    bnx2_xceiver_str(bp),
+			    bp->line_speed,
+			    bp->duplex == DUPLEX_FULL ? "full" : "half");
 
 		if (bp->flow_ctrl) {
 			if (bp->flow_ctrl & FLOW_CTRL_RX) {
-				printk(", receive ");
+				pr_cont(", receive ");
 				if (bp->flow_ctrl & FLOW_CTRL_TX)
-					printk("& transmit ");
+					pr_cont("& transmit ");
 			}
 			else {
-				printk(", transmit ");
+				pr_cont(", transmit ");
 			}
-			printk("flow control ON");
+			pr_cont("flow control ON");
 		}
-		printk("\n");
-	}
-	else {
+		pr_cont("\n");
+	} else {
 		netif_carrier_off(bp->dev);
-		printk(KERN_ERR PFX "%s NIC %s Link is Down\n", bp->dev->name,
-		       bnx2_xceiver_str(bp));
+		netdev_err(bp->dev, "NIC %s Link is Down\n",
+			   bnx2_xceiver_str(bp));
 	}
 
 	bnx2_report_fw_link(bp);
@@ -2482,8 +2476,7 @@ bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int ack, int silent)
 	/* If we timed out, inform the firmware that this is the case. */
 	if ((val & BNX2_FW_MSG_ACK) != (msg_data & BNX2_DRV_MSG_SEQ)) {
 		if (!silent)
-			printk(KERN_ERR PFX "fw sync timeout, reset code = "
-					    "%x\n", msg_data);
+			pr_err("fw sync timeout, reset code = %x\n", msg_data);
 
 		msg_data &= ~BNX2_DRV_MSG_CODE;
 		msg_data |= BNX2_DRV_MSG_CODE_FW_TIMEOUT;
@@ -2599,8 +2592,7 @@ bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 
 	good_mbuf = kmalloc(512 * sizeof(u16), GFP_KERNEL);
 	if (good_mbuf == NULL) {
-		printk(KERN_ERR PFX "Failed to allocate memory in "
-				    "bnx2_alloc_bad_rbuf\n");
+		pr_err("Failed to allocate memory in %s\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -3656,15 +3648,13 @@ bnx2_request_firmware(struct bnx2 *bp)
 
 	rc = request_firmware(&bp->mips_firmware, mips_fw_file, &bp->pdev->dev);
 	if (rc) {
-		printk(KERN_ERR PFX "Can't load firmware file \"%s\"\n",
-		       mips_fw_file);
+		pr_err("Can't load firmware file \"%s\"\n", mips_fw_file);
 		return rc;
 	}
 
 	rc = request_firmware(&bp->rv2p_firmware, rv2p_fw_file, &bp->pdev->dev);
 	if (rc) {
-		printk(KERN_ERR PFX "Can't load firmware file \"%s\"\n",
-		       rv2p_fw_file);
+		pr_err("Can't load firmware file \"%s\"\n", rv2p_fw_file);
 		return rc;
 	}
 	mips_fw = (const struct bnx2_mips_fw_file *) bp->mips_firmware->data;
@@ -3675,15 +3665,13 @@ bnx2_request_firmware(struct bnx2 *bp)
 	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->rxp) ||
 	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->tpat) ||
 	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->txp)) {
-		printk(KERN_ERR PFX "Firmware file \"%s\" is invalid\n",
-		       mips_fw_file);
+		pr_err("Firmware file \"%s\" is invalid\n", mips_fw_file);
 		return -EINVAL;
 	}
 	if (bp->rv2p_firmware->size < sizeof(*rv2p_fw) ||
 	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc1.rv2p, 8, true) ||
 	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc2.rv2p, 8, true)) {
-		printk(KERN_ERR PFX "Firmware file \"%s\" is invalid\n",
-		       rv2p_fw_file);
+		pr_err("Firmware file \"%s\" is invalid\n", rv2p_fw_file);
 		return -EINVAL;
 	}
 
@@ -4317,7 +4305,7 @@ bnx2_init_nvram(struct bnx2 *bp)
 
 	if (j == entry_count) {
 		bp->flash_info = NULL;
-		printk(KERN_ALERT PFX "Unknown flash/EEPROM type.\n");
+		pr_alert("Unknown flash/EEPROM type\n");
 		return -ENODEV;
 	}
 
@@ -4737,7 +4725,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 
 		if (val & (BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
 			   BNX2_PCICFG_MISC_CONFIG_CORE_RST_BSY)) {
-			printk(KERN_ERR PFX "Chip reset did not complete\n");
+			pr_err("Chip reset did not complete\n");
 			return -EBUSY;
 		}
 	}
@@ -4745,7 +4733,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	/* Make sure byte swapping is properly configured. */
 	val = REG_RD(bp, BNX2_PCI_SWAP_DIAG0);
 	if (val != 0x01020304) {
-		printk(KERN_ERR PFX "Chip not in correct endian mode\n");
+		pr_err("Chip not in correct endian mode\n");
 		return -ENODEV;
 	}
 
@@ -5166,9 +5154,8 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 	ring_prod = prod = rxr->rx_pg_prod;
 	for (i = 0; i < bp->rx_pg_ring_size; i++) {
 		if (bnx2_alloc_rx_page(bp, rxr, ring_prod) < 0) {
-			printk(KERN_WARNING PFX "%s: init'ed rx page ring %d "
-						"with %d/%d pages only\n",
-			       bp->dev->name, ring_num, i, bp->rx_pg_ring_size);
+			netdev_warn(bp->dev, "init'ed rx page ring %d with %d/%d pages only\n",
+				    ring_num, i, bp->rx_pg_ring_size);
 			break;
 		}
 		prod = NEXT_RX_BD(prod);
@@ -5179,9 +5166,8 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 	ring_prod = prod = rxr->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
 		if (bnx2_alloc_rx_skb(bp, rxr, ring_prod) < 0) {
-			printk(KERN_WARNING PFX "%s: init'ed rx ring %d with "
-						"%d/%d skbs only\n",
-			       bp->dev->name, ring_num, i, bp->rx_ring_size);
+			netdev_warn(bp->dev, "init'ed rx ring %d with %d/%d skbs only\n",
+				    ring_num, i, bp->rx_ring_size);
 			break;
 		}
 		prod = NEXT_RX_BD(prod);
@@ -6239,11 +6225,7 @@ bnx2_open(struct net_device *dev)
 		 * If MSI test fails, go back to INTx mode
 		 */
 		if (bnx2_test_intr(bp) != 0) {
-			printk(KERN_WARNING PFX "%s: No interrupt was generated"
-			       " using MSI, switching to INTx mode. Please"
-			       " report this failure to the PCI maintainer"
-			       " and include system chipset information.\n",
-			       bp->dev->name);
+			netdev_warn(bp->dev, "No interrupt was generated using MSI, switching to INTx mode. Please report this failure to the PCI maintainer and include system chipset information.\n");
 
 			bnx2_disable_int(bp);
 			bnx2_free_irq(bp);
@@ -6263,9 +6245,9 @@ bnx2_open(struct net_device *dev)
 		}
 	}
 	if (bp->flags & BNX2_FLAG_USING_MSI)
-		printk(KERN_INFO PFX "%s: using MSI\n", dev->name);
+		netdev_info(dev, "using MSI\n");
 	else if (bp->flags & BNX2_FLAG_USING_MSIX)
-		printk(KERN_INFO PFX "%s: using MSIX\n", dev->name);
+		netdev_info(dev, "using MSIX\n");
 
 	netif_tx_start_all_queues(dev);
 
@@ -6304,20 +6286,18 @@ bnx2_dump_state(struct bnx2 *bp)
 {
 	struct net_device *dev = bp->dev;
 
-	printk(KERN_ERR PFX "%s DEBUG: intr_sem[%x]\n", dev->name,
-		atomic_read(&bp->intr_sem));
-	printk(KERN_ERR PFX "%s DEBUG: EMAC_TX_STATUS[%08x] "
-			    "RPM_MGMT_PKT_CTRL[%08x]\n", dev->name,
-		REG_RD(bp, BNX2_EMAC_TX_STATUS),
-		REG_RD(bp, BNX2_RPM_MGMT_PKT_CTRL));
-	printk(KERN_ERR PFX "%s DEBUG: MCP_STATE_P0[%08x] MCP_STATE_P1[%08x]\n",
-		dev->name, bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P0),
-		bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P1));
-	printk(KERN_ERR PFX "%s DEBUG: HC_STATS_INTERRUPT_STATUS[%08x]\n",
-		dev->name, REG_RD(bp, BNX2_HC_STATS_INTERRUPT_STATUS));
+	netdev_err(dev, "DEBUG: intr_sem[%x]\n", atomic_read(&bp->intr_sem));
+	netdev_err(dev, "DEBUG: EMAC_TX_STATUS[%08x] RPM_MGMT_PKT_CTRL[%08x]\n",
+		   REG_RD(bp, BNX2_EMAC_TX_STATUS),
+		   REG_RD(bp, BNX2_RPM_MGMT_PKT_CTRL));
+	netdev_err(dev, "DEBUG: MCP_STATE_P0[%08x] MCP_STATE_P1[%08x]\n",
+		   bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P0),
+		   bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P1));
+	netdev_err(dev, "DEBUG: HC_STATS_INTERRUPT_STATUS[%08x]\n",
+		   REG_RD(bp, BNX2_HC_STATS_INTERRUPT_STATUS));
 	if (bp->flags & BNX2_FLAG_USING_MSIX)
-		printk(KERN_ERR PFX "%s DEBUG: PBA[%08x]\n", dev->name,
-			REG_RD(bp, BNX2_PCI_GRC_WINDOW3_BASE));
+		netdev_err(dev, "DEBUG: PBA[%08x]\n",
+			   REG_RD(bp, BNX2_PCI_GRC_WINDOW3_BASE));
 }
 
 static void
@@ -6381,8 +6361,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(bnx2_tx_avail(bp, txr) <
 	    (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_tx_stop_queue(txq);
-		printk(KERN_ERR PFX "%s: BUG! Tx ring full when queue awake!\n",
-			dev->name);
+		netdev_err(dev, "BUG! Tx ring full when queue awake!\n");
 
 		return NETDEV_TX_BUSY;
 	}
@@ -7869,20 +7848,20 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
 	rc = pci_enable_device(pdev);
 	if (rc) {
-		dev_err(&pdev->dev, "Cannot enable PCI device, aborting.\n");
+		dev_err(&pdev->dev, "Cannot enable PCI device, aborting\n");
 		goto err_out;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev,
-			"Cannot find PCI device base address, aborting.\n");
+			"Cannot find PCI device base address, aborting\n");
 		rc = -ENODEV;
 		goto err_out_disable;
 	}
 
 	rc = pci_request_regions(pdev, DRV_MODULE_NAME);
 	if (rc) {
-		dev_err(&pdev->dev, "Cannot obtain PCI resources, aborting.\n");
+		dev_err(&pdev->dev, "Cannot obtain PCI resources, aborting\n");
 		goto err_out_disable;
 	}
 
@@ -7892,7 +7871,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (bp->pm_cap == 0) {
 		dev_err(&pdev->dev,
-			"Cannot find power management capability, aborting.\n");
+			"Cannot find power management capability, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
 	}
@@ -7915,7 +7894,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->regview = ioremap_nocache(dev->base_addr, mem_len);
 
 	if (!bp->regview) {
-		dev_err(&pdev->dev, "Cannot map register space, aborting.\n");
+		dev_err(&pdev->dev, "Cannot map register space, aborting\n");
 		rc = -ENOMEM;
 		goto err_out_release;
 	}
@@ -7935,7 +7914,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		if (pci_find_capability(pdev, PCI_CAP_ID_EXP) == 0) {
 			dev_err(&pdev->dev,
-				"Cannot find PCIE capability, aborting.\n");
+				"Cannot find PCIE capability, aborting\n");
 			rc = -EIO;
 			goto err_out_unmap;
 		}
@@ -7946,7 +7925,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		bp->pcix_cap = pci_find_capability(pdev, PCI_CAP_ID_PCIX);
 		if (bp->pcix_cap == 0) {
 			dev_err(&pdev->dev,
-				"Cannot find PCIX capability, aborting.\n");
+				"Cannot find PCIX capability, aborting\n");
 			rc = -EIO;
 			goto err_out_unmap;
 		}
@@ -7975,11 +7954,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		rc = pci_set_consistent_dma_mask(pdev, persist_dma_mask);
 		if (rc) {
 			dev_err(&pdev->dev,
-				"pci_set_consistent_dma_mask failed, aborting.\n");
+				"pci_set_consistent_dma_mask failed, aborting\n");
 			goto err_out_unmap;
 		}
 	} else if ((rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) != 0) {
-		dev_err(&pdev->dev, "System does not support DMA, aborting.\n");
+		dev_err(&pdev->dev, "System does not support DMA, aborting\n");
 		goto err_out_unmap;
 	}
 
@@ -7996,7 +7975,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		!(bp->flags & BNX2_FLAG_PCIX)) {
 
 		dev_err(&pdev->dev,
-			"5706 A1 can only be used in a PCIX bus, aborting.\n");
+			"5706 A1 can only be used in a PCIX bus, aborting\n");
 		goto err_out_unmap;
 	}
 
@@ -8019,7 +7998,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	if ((reg & BNX2_DEV_INFO_SIGNATURE_MAGIC_MASK) !=
 	    BNX2_DEV_INFO_SIGNATURE_MAGIC) {
-		dev_err(&pdev->dev, "Firmware not running, aborting.\n");
+		dev_err(&pdev->dev, "Firmware not running, aborting\n");
 		rc = -ENODEV;
 		goto err_out_unmap;
 	}
@@ -8292,7 +8271,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	char str[40];
 
 	if (version_printed++ == 0)
-		printk(KERN_INFO "%s", version);
+		pr_info("%s", version);
 
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mq(sizeof(*bp), TX_MAX_RINGS);
@@ -8342,15 +8321,13 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto error;
 	}
 
-	printk(KERN_INFO "%s: %s (%c%d) %s found at mem %lx, "
-		"IRQ %d, node addr %pM\n",
-		dev->name,
-		board_info[ent->driver_data].name,
-		((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
-		((CHIP_ID(bp) & 0x0ff0) >> 4),
-		bnx2_bus_string(bp, str),
-		dev->base_addr,
-		bp->pdev->irq, dev->dev_addr);
+	netdev_info(dev, "%s (%c%d) %s found at mem %lx, IRQ %d, node addr %pM\n",
+		    board_info[ent->driver_data].name,
+		    ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
+		    ((CHIP_ID(bp) & 0x0ff0) >> 4),
+		    bnx2_bus_string(bp, str),
+		    dev->base_addr,
+		    bp->pdev->irq, dev->dev_addr);
 
 	return 0;
 
@@ -8485,7 +8462,7 @@ static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
 	rtnl_lock();
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
-			"Cannot re-enable PCI device after reset.\n");
+			"Cannot re-enable PCI device after reset\n");
 		rtnl_unlock();
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
-- 
1.7.0.14.g7e948

