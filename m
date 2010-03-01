From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/e100.c: Use pr_<level> and
 netif_<level>
Date: Mon, 01 Mar 2010 13:16:21 -0800
Message-ID: <1267478181.12641.142.camel@Joe-Laptop.home>
References: <cover.1266893507.git.joe@perches.com>
	 <9929d2391002231833j65008a1ev1d2297672a39a483@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9929d2391002231833j65008a1ev1d2297672a39a483@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert DPRINTK, commonly used for debugging, to netif_<level>
Remove #define PFX
Use #define pr_fmt
Consistently use no periods for non-sentence logging messages

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e100.c |  183 ++++++++++++++++++++++++++++------------------------
 1 files changed, 98 insertions(+), 85 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index a26ccab..c33d12a 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -147,6 +147,8 @@
  *      - add clean lowlevel I/O emulation for cards with MII-lacking PHYs
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
@@ -174,7 +176,6 @@
 #define DRV_VERSION		"3.5.24-k2"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel Corporation"
-#define PFX			DRV_NAME ": "
 
 #define E100_WATCHDOG_PERIOD	(2 * HZ)
 #define E100_NAPI_WEIGHT	16
@@ -200,10 +201,6 @@ module_param(use_io, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 MODULE_PARM_DESC(eeprom_bad_csum_allow, "Allow bad eeprom checksums");
 MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	(void)((NETIF_MSG_##nlevel & nic->msg_enable) && \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, nic->netdev->name, \
-		__func__ , ## args))
 
 #define INTEL_8255X_ETHERNET_DEVICE(device_id, ich) {\
 	PCI_VENDOR_ID_INTEL, device_id, PCI_ANY_ID, PCI_ANY_ID, \
@@ -689,12 +686,13 @@ static int e100_self_test(struct nic *nic)
 
 	/* Check results of self-test */
 	if (nic->mem->selftest.result != 0) {
-		DPRINTK(HW, ERR, "Self-test failed: result=0x%08X\n",
-			nic->mem->selftest.result);
+		netif_err(nic, hw, nic->netdev,
+			  "Self-test failed: result=0x%08X\n",
+			  nic->mem->selftest.result);
 		return -ETIMEDOUT;
 	}
 	if (nic->mem->selftest.signature == 0) {
-		DPRINTK(HW, ERR, "Self-test failed: timed out\n");
+		netif_err(nic, hw, nic->netdev, "Self-test failed: timed out\n");
 		return -ETIMEDOUT;
 	}
 
@@ -797,7 +795,7 @@ static int e100_eeprom_load(struct nic *nic)
 	/* The checksum, stored in the last word, is calculated such that
 	 * the sum of words should be 0xBABA */
 	if (cpu_to_le16(0xBABA - checksum) != nic->eeprom[nic->eeprom_wc - 1]) {
-		DPRINTK(PROBE, ERR, "EEPROM corrupted\n");
+		netif_err(nic, probe, nic->netdev, "EEPROM corrupted\n");
 		if (!eeprom_bad_csum_allow)
 			return -EAGAIN;
 	}
@@ -953,8 +951,7 @@ static u16 mdio_ctrl_hw(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data)
 		udelay(20);
 	}
 	if (unlikely(!i)) {
-		printk("e100.mdio_ctrl(%s) won't go Ready\n",
-			nic->netdev->name );
+		netdev_err(nic->netdev, "e100.mdio_ctrl won't go Ready\n");
 		spin_unlock_irqrestore(&nic->mdio_lock, flags);
 		return 0;		/* No way to indicate timeout error */
 	}
@@ -966,9 +963,10 @@ static u16 mdio_ctrl_hw(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data)
 			break;
 	}
 	spin_unlock_irqrestore(&nic->mdio_lock, flags);
-	DPRINTK(HW, DEBUG,
-		"%s:addr=%d, reg=%d, data_in=0x%04X, data_out=0x%04X\n",
-		dir == mdi_read ? "READ" : "WRITE", addr, reg, data, data_out);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+		     "%s:addr=%d, reg=%d, data_in=0x%04X, data_out=0x%04X\n",
+		     dir == mdi_read ? "READ" : "WRITE",
+		     addr, reg, data, data_out);
 	return (u16)data_out;
 }
 
@@ -1028,17 +1026,19 @@ static u16 mdio_ctrl_phy_mii_emulated(struct nic *nic,
 			return	ADVERTISE_10HALF |
 				ADVERTISE_10FULL;
 		default:
-			DPRINTK(HW, DEBUG,
-		"%s:addr=%d, reg=%d, data=0x%04X: unimplemented emulation!\n",
-		dir == mdi_read ? "READ" : "WRITE", addr, reg, data);
+			netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+				     "%s:addr=%d, reg=%d, data=0x%04X: unimplemented emulation!\n",
+				     dir == mdi_read ? "READ" : "WRITE",
+				     addr, reg, data);
 			return 0xFFFF;
 		}
 	} else {
 		switch (reg) {
 		default:
-			DPRINTK(HW, DEBUG,
-		"%s:addr=%d, reg=%d, data=0x%04X: unimplemented emulation!\n",
-		dir == mdi_read ? "READ" : "WRITE", addr, reg, data);
+			netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+				     "%s:addr=%d, reg=%d, data=0x%04X: unimplemented emulation!\n",
+				     dir == mdi_read ? "READ" : "WRITE",
+				     addr, reg, data);
 			return 0xFFFF;
 		}
 	}
@@ -1155,12 +1155,15 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		}
 	}
 
-	DPRINTK(HW, DEBUG, "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
-	DPRINTK(HW, DEBUG, "[08-15]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15]);
-	DPRINTK(HW, DEBUG, "[16-23]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+		     "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
+		     c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+		     "[08-15]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
+		     c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15]);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+		     "[16-23]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
+		     c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
 }
 
 /*************************************************************************
@@ -1253,16 +1256,18 @@ static const struct firmware *e100_request_firmware(struct nic *nic)
 		err = request_firmware(&fw, fw_name, &nic->pdev->dev);
 
 	if (err) {
-		DPRINTK(PROBE, ERR, "Failed to load firmware \"%s\": %d\n",
-			fw_name, err);
+		netif_err(nic, probe, nic->netdev,
+			  "Failed to load firmware \"%s\": %d\n",
+			  fw_name, err);
 		return ERR_PTR(err);
 	}
 
 	/* Firmware should be precisely UCODE_SIZE (words) plus three bytes
 	   indicating the offsets for BUNDLESMALL, BUNDLEMAX, INTDELAY */
 	if (fw->size != UCODE_SIZE * 4 + 3) {
-		DPRINTK(PROBE, ERR, "Firmware \"%s\" has wrong size %zu\n",
-			fw_name, fw->size);
+		netif_err(nic, probe, nic->netdev,
+			  "Firmware \"%s\" has wrong size %zu\n",
+			  fw_name, fw->size);
 		release_firmware(fw);
 		return ERR_PTR(-EINVAL);
 	}
@@ -1274,9 +1279,9 @@ static const struct firmware *e100_request_firmware(struct nic *nic)
 
 	if (timer >= UCODE_SIZE || bundle >= UCODE_SIZE ||
 	    min_size >= UCODE_SIZE) {
-		DPRINTK(PROBE, ERR,
-			"\"%s\" has bogus offset values (0x%x,0x%x,0x%x)\n",
-			fw_name, timer, bundle, min_size);
+		netif_err(nic, probe, nic->netdev,
+			  "\"%s\" has bogus offset values (0x%x,0x%x,0x%x)\n",
+			  fw_name, timer, bundle, min_size);
 		release_firmware(fw);
 		return ERR_PTR(-EINVAL);
 	}
@@ -1328,7 +1333,8 @@ static inline int e100_load_ucode_wait(struct nic *nic)
 		return PTR_ERR(fw);
 
 	if ((err = e100_exec_cb(nic, (void *)fw, e100_setup_ucode)))
-		DPRINTK(PROBE,ERR, "ucode cmd failed with error %d\n", err);
+		netif_err(nic, probe, nic->netdev,
+			  "ucode cmd failed with error %d\n", err);
 
 	/* must restart cuc */
 	nic->cuc_cmd = cuc_start;
@@ -1348,7 +1354,7 @@ static inline int e100_load_ucode_wait(struct nic *nic)
 
 	/* if the command failed, or is not OK, notify and return */
 	if (!counter || !(cb->status & cpu_to_le16(cb_ok))) {
-		DPRINTK(PROBE,ERR, "ucode load failed\n");
+		netif_err(nic, probe, nic->netdev, "ucode load failed\n");
 		err = -EPERM;
 	}
 
@@ -1386,8 +1392,8 @@ static int e100_phy_check_without_mii(struct nic *nic)
 		 * media is sensed automatically based on how the link partner
 		 * is configured.  This is, in essence, manual configuration.
 		 */
-		DPRINTK(PROBE, INFO,
-			 "found MII-less i82503 or 80c24 or other PHY\n");
+		netif_info(nic, probe, nic->netdev,
+			   "found MII-less i82503 or 80c24 or other PHY\n");
 
 		nic->mdio_ctrl = mdio_ctrl_phy_mii_emulated;
 		nic->mii.phy_id = 0; /* is this ok for an MII-less PHY? */
@@ -1434,18 +1440,20 @@ static int e100_phy_init(struct nic *nic)
 			return 0; /* simply return and hope for the best */
 		else {
 			/* for unknown cases log a fatal error */
-			DPRINTK(HW, ERR,
-				"Failed to locate any known PHY, aborting.\n");
+			netif_err(nic, hw, nic->netdev,
+				  "Failed to locate any known PHY, aborting\n");
 			return -EAGAIN;
 		}
 	} else
-		DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
+		netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+			     "phy_addr = %d\n", nic->mii.phy_id);
 
 	/* Get phy ID */
 	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
 	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);
 	nic->phy = (u32)id_hi << 16 | (u32)id_lo;
-	DPRINTK(HW, DEBUG, "phy ID = 0x%08X\n", nic->phy);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+		     "phy ID = 0x%08X\n", nic->phy);
 
 	/* Select the phy and isolate the rest */
 	for (addr = 0; addr < 32; addr++) {
@@ -1507,7 +1515,7 @@ static int e100_hw_init(struct nic *nic)
 
 	e100_hw_reset(nic);
 
-	DPRINTK(HW, ERR, "e100_hw_init\n");
+	netif_err(nic, hw, nic->netdev, "e100_hw_init\n");
 	if (!in_interrupt() && (err = e100_self_test(nic)))
 		return err;
 
@@ -1555,8 +1563,9 @@ static void e100_set_multicast_list(struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
 
-	DPRINTK(HW, DEBUG, "mc_count=%d, flags=0x%04X\n",
-		netdev_mc_count(netdev), netdev->flags);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
+		     "mc_count=%d, flags=0x%04X\n",
+		     netdev_mc_count(netdev), netdev->flags);
 
 	if (netdev->flags & IFF_PROMISC)
 		nic->flags |= promiscuous;
@@ -1629,7 +1638,8 @@ static void e100_update_stats(struct nic *nic)
 
 
 	if (e100_exec_cmd(nic, cuc_dump_reset, 0))
-		DPRINTK(TX_ERR, DEBUG, "exec cuc_dump_reset failed\n");
+		netif_printk(nic, tx_err, KERN_DEBUG, nic->netdev,
+			     "exec cuc_dump_reset failed\n");
 }
 
 static void e100_adjust_adaptive_ifs(struct nic *nic, int speed, int duplex)
@@ -1659,20 +1669,19 @@ static void e100_watchdog(unsigned long data)
 	struct nic *nic = (struct nic *)data;
 	struct ethtool_cmd cmd;
 
-	DPRINTK(TIMER, DEBUG, "right now = %ld\n", jiffies);
+	netif_printk(nic, timer, KERN_DEBUG, nic->netdev,
+		     "right now = %ld\n", jiffies);
 
 	/* mii library handles link maintenance tasks */
 
 	mii_ethtool_gset(&nic->mii, &cmd);
 
 	if (mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
-		printk(KERN_INFO "e100: %s NIC Link is Up %s Mbps %s Duplex\n",
-		       nic->netdev->name,
-		       cmd.speed == SPEED_100 ? "100" : "10",
-		       cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
+		netdev_info(nic->netdev, "NIC Link is Up %u Mbps %s Duplex\n",
+			    cmd.speed == SPEED_100 ? 100 : 10,
+			    cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
 	} else if (!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
-		printk(KERN_INFO "e100: %s NIC Link is Down\n",
-		       nic->netdev->name);
+		netdev_info(nic->netdev, "NIC Link is Down\n");
 	}
 
 	mii_check_link(&nic->mii);
@@ -1732,7 +1741,8 @@ static netdev_tx_t e100_xmit_frame(struct sk_buff *skb,
 		   Issue a NOP command followed by a 1us delay before
 		   issuing the Tx command. */
 		if (e100_exec_cmd(nic, cuc_nop, 0))
-			DPRINTK(TX_ERR, DEBUG, "exec cuc_nop failed\n");
+			netif_printk(nic, tx_err, KERN_DEBUG, nic->netdev,
+				     "exec cuc_nop failed\n");
 		udelay(1);
 	}
 
@@ -1741,12 +1751,14 @@ static netdev_tx_t e100_xmit_frame(struct sk_buff *skb,
 	switch (err) {
 	case -ENOSPC:
 		/* We queued the skb, but now we're out of space. */
-		DPRINTK(TX_ERR, DEBUG, "No space for CB\n");
+		netif_printk(nic, tx_err, KERN_DEBUG, nic->netdev,
+			     "No space for CB\n");
 		netif_stop_queue(netdev);
 		break;
 	case -ENOMEM:
 		/* This is a hard error - log it. */
-		DPRINTK(TX_ERR, DEBUG, "Out of Tx resources, returning skb\n");
+		netif_printk(nic, tx_err, KERN_DEBUG, nic->netdev,
+			     "Out of Tx resources, returning skb\n");
 		netif_stop_queue(netdev);
 		return NETDEV_TX_BUSY;
 	}
@@ -1767,9 +1779,10 @@ static int e100_tx_clean(struct nic *nic)
 	for (cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
-		DPRINTK(TX_DONE, DEBUG, "cb[%d]->status = 0x%04X\n",
-		        (int)(((void*)cb - (void*)nic->cbs)/sizeof(struct cb)),
-		        cb->status);
+		netif_printk(nic, tx_done, KERN_DEBUG, nic->netdev,
+			     "cb[%d]->status = 0x%04X\n",
+			     (int)(((void*)cb - (void*)nic->cbs)/sizeof(struct cb)),
+			     cb->status);
 
 		if (likely(cb->skb != NULL)) {
 			dev->stats.tx_packets++;
@@ -1912,7 +1925,8 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 		sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
 	rfd_status = le16_to_cpu(rfd->status);
 
-	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);
+	netif_printk(nic, rx_status, KERN_DEBUG, nic->netdev,
+		     "status=0x%04X\n", rfd_status);
 
 	/* If data isn't ready, nothing to indicate */
 	if (unlikely(!(rfd_status & cb_complete))) {
@@ -2123,7 +2137,8 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 	struct nic *nic = netdev_priv(netdev);
 	u8 stat_ack = ioread8(&nic->csr->scb.stat_ack);
 
-	DPRINTK(INTR, DEBUG, "stat_ack = 0x%02X\n", stat_ack);
+	netif_printk(nic, intr, KERN_DEBUG, nic->netdev,
+		     "stat_ack = 0x%02X\n", stat_ack);
 
 	if (stat_ack == stat_ack_not_ours ||	/* Not our interrupt */
 	   stat_ack == stat_ack_not_present)	/* Hardware is ejected */
@@ -2263,8 +2278,8 @@ static void e100_tx_timeout_task(struct work_struct *work)
 	struct nic *nic = container_of(work, struct nic, tx_timeout_task);
 	struct net_device *netdev = nic->netdev;
 
-	DPRINTK(TX_ERR, DEBUG, "scb.status=0x%02X\n",
-		ioread8(&nic->csr->scb.status));
+	netif_printk(nic, tx_err, KERN_DEBUG, nic->netdev,
+		     "scb.status=0x%02X\n", ioread8(&nic->csr->scb.status));
 	e100_down(netdev_priv(netdev));
 	e100_up(netdev_priv(netdev));
 }
@@ -2526,8 +2541,8 @@ static int e100_set_ringparam(struct net_device *netdev,
 	rfds->count = min(rfds->count, rfds->max);
 	cbs->count = max(ring->tx_pending, cbs->min);
 	cbs->count = min(cbs->count, cbs->max);
-	DPRINTK(DRV, INFO, "Ring Param settings: rx: %d, tx %d\n",
-	        rfds->count, cbs->count);
+	netif_info(nic, drv, nic->netdev, "Ring Param settings: rx: %d, tx %d\n",
+		   rfds->count, cbs->count);
 	if (netif_running(netdev))
 		e100_up(nic);
 
@@ -2704,7 +2719,7 @@ static int e100_open(struct net_device *netdev)
 
 	netif_carrier_off(netdev);
 	if ((err = e100_up(nic)))
-		DPRINTK(IFUP, ERR, "Cannot open interface, aborting.\n");
+		netif_err(nic, ifup, nic->netdev, "Cannot open interface, aborting\n");
 	return err;
 }
 
@@ -2738,7 +2753,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 
 	if (!(netdev = alloc_etherdev(sizeof(struct nic)))) {
 		if (((1 << debug) - 1) & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX "Etherdev alloc failed, abort.\n");
+			pr_err("Etherdev alloc failed, aborting\n");
 		return -ENOMEM;
 	}
 
@@ -2756,35 +2771,34 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, netdev);
 
 	if ((err = pci_enable_device(pdev))) {
-		DPRINTK(PROBE, ERR, "Cannot enable PCI device, aborting.\n");
+		netif_err(nic, probe, nic->netdev, "Cannot enable PCI device, aborting\n");
 		goto err_out_free_dev;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		DPRINTK(PROBE, ERR, "Cannot find proper PCI device "
-			"base address, aborting.\n");
+		netif_err(nic, probe, nic->netdev, "Cannot find proper PCI device base address, aborting\n");
 		err = -ENODEV;
 		goto err_out_disable_pdev;
 	}
 
 	if ((err = pci_request_regions(pdev, DRV_NAME))) {
-		DPRINTK(PROBE, ERR, "Cannot obtain PCI resources, aborting.\n");
+		netif_err(nic, probe, nic->netdev, "Cannot obtain PCI resources, aborting\n");
 		goto err_out_disable_pdev;
 	}
 
 	if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))) {
-		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
+		netif_err(nic, probe, nic->netdev, "No usable DMA configuration, aborting\n");
 		goto err_out_free_res;
 	}
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	if (use_io)
-		DPRINTK(PROBE, INFO, "using i/o access mode\n");
+		netif_info(nic, probe, nic->netdev, "using i/o access mode\n");
 
 	nic->csr = pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
 	if (!nic->csr) {
-		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
+		netif_err(nic, probe, nic->netdev, "Cannot map device registers, aborting\n");
 		err = -ENOMEM;
 		goto err_out_free_res;
 	}
@@ -2818,7 +2832,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	INIT_WORK(&nic->tx_timeout_task, e100_tx_timeout_task);
 
 	if ((err = e100_alloc(nic))) {
-		DPRINTK(PROBE, ERR, "Cannot alloc driver memory, aborting.\n");
+		netif_err(nic, probe, nic->netdev, "Cannot alloc driver memory, aborting\n");
 		goto err_out_iounmap;
 	}
 
@@ -2831,13 +2845,11 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	memcpy(netdev->perm_addr, nic->eeprom, ETH_ALEN);
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		if (!eeprom_bad_csum_allow) {
-			DPRINTK(PROBE, ERR, "Invalid MAC address from "
-			        "EEPROM, aborting.\n");
+			netif_err(nic, probe, nic->netdev, "Invalid MAC address from EEPROM, aborting\n");
 			err = -EAGAIN;
 			goto err_out_free;
 		} else {
-			DPRINTK(PROBE, ERR, "Invalid MAC address from EEPROM, "
-			        "you MUST configure one.\n");
+			netif_err(nic, probe, nic->netdev, "Invalid MAC address from EEPROM, you MUST configure one.\n");
 		}
 	}
 
@@ -2853,7 +2865,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 
 	strcpy(netdev->name, "eth%d");
 	if ((err = register_netdev(netdev))) {
-		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
+		netif_err(nic, probe, nic->netdev, "Cannot register net device, aborting\n");
 		goto err_out_free;
 	}
 	nic->cbs_pool = pci_pool_create(netdev->name,
@@ -2861,9 +2873,10 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 			   nic->params.cbs.count * sizeof(struct cb),
 			   sizeof(u32),
 			   0);
-	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, MAC addr %pM\n",
-		(unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0),
-		pdev->irq, netdev->dev_addr);
+	netif_info(nic, probe, nic->netdev,
+		   "addr 0x%llx, irq %d, MAC addr %pM\n",
+		   (unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0),
+		   pdev->irq, netdev->dev_addr);
 
 	return 0;
 
@@ -3021,7 +3034,7 @@ static pci_ers_result_t e100_io_slot_reset(struct pci_dev *pdev)
 	struct nic *nic = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
-		printk(KERN_ERR "e100: Cannot re-enable PCI device after reset.\n");
+		pr_err("Cannot re-enable PCI device after reset\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
@@ -3080,8 +3093,8 @@ static struct pci_driver e100_driver = {
 static int __init e100_init_module(void)
 {
 	if (((1 << debug) - 1) & NETIF_MSG_DRV) {
-		printk(KERN_INFO PFX "%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
-		printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
+		pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
+		pr_info("%s\n", DRV_COPYRIGHT);
 	}
 	return pci_register_driver(&e100_driver);
 }
