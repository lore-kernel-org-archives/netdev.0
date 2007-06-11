From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] [RFC] NET: Convert several drivers to ndev_printk
Date: Mon, 11 Jun 2007 14:37:27 -0700
Message-ID: <20070611213727.23014.76760.stgit@localhost.localdomain>
References: <20070611213721.23014.4812.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: arjan@linux.intel.com, joe@perches.com,
	shemminger@linux-foundation.org
To: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17484 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766AbXFKVhb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 17:37:31 -0400
In-Reply-To: <20070611213721.23014.4812.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the generic ndev_printk macros, we can now convert network
drivers to use this generic printk family for netdevices.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c                |  135 ++++++++++++++++---------------------
 drivers/net/e1000/e1000.h         |   15 ----
 drivers/net/e1000/e1000_ethtool.c |   39 +++--------
 drivers/net/e1000/e1000_main.c    |  110 +++++++++++++++---------------
 drivers/net/e1000/e1000_param.c   |   67 +++++++++---------
 drivers/net/ixgb/ixgb.h           |   14 ----
 drivers/net/ixgb/ixgb_ethtool.c   |   15 ----
 drivers/net/ixgb/ixgb_main.c      |   50 ++++++--------
 8 files changed, 184 insertions(+), 261 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 6169663..8c09c9e 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -172,19 +172,12 @@ MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-static int debug = 3;
 static int eeprom_bad_csum_allow = 0;
 static int use_io = 0;
-module_param(debug, int, 0);
 module_param(eeprom_bad_csum_allow, int, 0);
 module_param(use_io, int, 0);
-MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 MODULE_PARM_DESC(eeprom_bad_csum_allow, "Allow bad eeprom checksums");
 MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	(void)((NETIF_MSG_##nlevel & nic->msg_enable) && \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, nic->netdev->name, \
-		__FUNCTION__ , ## args))
 
 #define INTEL_8255X_ETHERNET_DEVICE(device_id, ich) {\
 	PCI_VENDOR_ID_INTEL, device_id, PCI_ANY_ID, PCI_ANY_ID, \
@@ -645,12 +638,12 @@ static int e100_self_test(struct nic *nic)
 
 	/* Check results of self-test */
 	if(nic->mem->selftest.result != 0) {
-		DPRINTK(HW, ERR, "Self-test failed: result=0x%08X\n",
+		ndev_err(nic->netdev, HW, "Self-test failed: result=0x%08X\n",
 			nic->mem->selftest.result);
 		return -ETIMEDOUT;
 	}
 	if(nic->mem->selftest.signature == 0) {
-		DPRINTK(HW, ERR, "Self-test failed: timed out\n");
+		ndev_err(nic->netdev, HW, "Self-test failed: timed out\n");
 		return -ETIMEDOUT;
 	}
 
@@ -754,7 +747,7 @@ static int e100_eeprom_load(struct nic *nic)
 	 * the sum of words should be 0xBABA */
 	checksum = le16_to_cpu(0xBABA - checksum);
 	if(checksum != nic->eeprom[nic->eeprom_wc - 1]) {
-		DPRINTK(PROBE, ERR, "EEPROM corrupted\n");
+		ndev_err(nic->netdev, PROBE, "EEPROM corrupted\n");
 		if (!eeprom_bad_csum_allow)
 			return -EAGAIN;
 	}
@@ -896,8 +889,7 @@ static u16 mdio_ctrl(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data)
 		udelay(20);
 	}
 	if (unlikely(!i)) {
-		printk("e100.mdio_ctrl(%s) won't go Ready\n",
-			nic->netdev->name );
+		dev_err(&nic->pdev->dev, "mdio_ctrl won't go Ready\n");
 		spin_unlock_irqrestore(&nic->mdio_lock, flags);
 		return 0;		/* No way to indicate timeout error */
 	}
@@ -909,7 +901,7 @@ static u16 mdio_ctrl(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data)
 			break;
 	}
 	spin_unlock_irqrestore(&nic->mdio_lock, flags);
-	DPRINTK(HW, DEBUG,
+	ndev_dbg(nic->netdev, HW,
 		"%s:addr=%d, reg=%d, data_in=0x%04X, data_out=0x%04X\n",
 		dir == mdi_read ? "READ" : "WRITE", addr, reg, data, data_out);
 	return (u16)data_out;
@@ -962,8 +954,8 @@ static void e100_get_defaults(struct nic *nic)
 static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
 	struct config *config = &cb->u.config;
-	u8 *c = (u8 *)config;
-
+	u8 *c;
+	
 	cb->command = cpu_to_le16(cb_config);
 
 	memset(config, 0, sizeof(struct config));
@@ -1023,12 +1015,16 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 			config->standard_stat_counter = 0x0;
 	}
 
-	DPRINTK(HW, DEBUG, "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
-	DPRINTK(HW, DEBUG, "[08-15]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15]);
-	DPRINTK(HW, DEBUG, "[16-23]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
+	c = (u8 *)config;
+	ndev_dbg(nic->netdev, HW,
+	         "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
+	         c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
+	ndev_dbg(nic->netdev, HW,
+	         "[08-15]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
+	         c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15]);
+	ndev_dbg(nic->netdev, HW,
+	         "[16-23]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
+	         c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
 }
 
 /********************************************************/
@@ -1298,7 +1294,7 @@ static inline int e100_exec_cb_wait(struct nic *nic, struct sk_buff *skb,
 	struct cb *cb = nic->cb_to_clean;
 
 	if ((err = e100_exec_cb(nic, NULL, e100_setup_ucode)))
-		DPRINTK(PROBE,ERR, "ucode cmd failed with error %d\n", err);
+		ndev_err(nic->netdev, PROBE, "ucode cmd failed with error %d\n", err);
 
 	/* must restart cuc */
 	nic->cuc_cmd = cuc_start;
@@ -1318,7 +1314,7 @@ static inline int e100_exec_cb_wait(struct nic *nic, struct sk_buff *skb,
 
 	/* if the command failed, or is not OK, notify and return */
 	if (!counter || !(cb->status & cpu_to_le16(cb_ok))) {
-		DPRINTK(PROBE,ERR, "ucode load failed\n");
+		ndev_err(nic->netdev, PROBE, "ucode load failed\n");
 		err = -EPERM;
 	}
 
@@ -1359,7 +1355,7 @@ static int e100_phy_init(struct nic *nic)
 		if(!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
 			break;
 	}
-	DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
+	ndev_dbg(nic->netdev, HW, "phy_addr = %d\n", nic->mii.phy_id);
 	if(addr == 32)
 		return -EAGAIN;
 
@@ -1378,7 +1374,7 @@ static int e100_phy_init(struct nic *nic)
 	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
 	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);
 	nic->phy = (u32)id_hi << 16 | (u32)id_lo;
-	DPRINTK(HW, DEBUG, "phy ID = 0x%08X\n", nic->phy);
+	ndev_dbg(nic->netdev, HW, "phy ID = 0x%08X\n", nic->phy);
 
 	/* Handle National tx phys */
 #define NCS_PHY_MODEL_MASK	0xFFF0FFFF
@@ -1407,7 +1403,7 @@ static int e100_hw_init(struct nic *nic)
 
 	e100_hw_reset(nic);
 
-	DPRINTK(HW, ERR, "e100_hw_init\n");
+	ndev_err(nic->netdev, HW, "e100_hw_init\n");
 	if(!in_interrupt() && (err = e100_self_test(nic)))
 		return err;
 
@@ -1451,7 +1447,7 @@ static void e100_set_multicast_list(struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
 
-	DPRINTK(HW, DEBUG, "mc_count=%d, flags=0x%04X\n",
+	ndev_dbg(nic->netdev, HW, "mc_count=%d, flags=0x%04X\n",
 		netdev->mc_count, netdev->flags);
 
 	if(netdev->flags & IFF_PROMISC)
@@ -1524,7 +1520,7 @@ static void e100_update_stats(struct nic *nic)
 
 
 	if(e100_exec_cmd(nic, cuc_dump_reset, 0))
-		DPRINTK(TX_ERR, DEBUG, "exec cuc_dump_reset failed\n");
+		ndev_dbg(nic->netdev, TX_ERR, "exec cuc_dump_reset failed\n");
 }
 
 static void e100_adjust_adaptive_ifs(struct nic *nic, int speed, int duplex)
@@ -1554,18 +1550,18 @@ static void e100_watchdog(unsigned long data)
 	struct nic *nic = (struct nic *)data;
 	struct ethtool_cmd cmd;
 
-	DPRINTK(TIMER, DEBUG, "right now = %ld\n", jiffies);
+	ndev_dbg(nic->netdev, TIMER, "right now = %ld\n", jiffies);
 
 	/* mii library handles link maintenance tasks */
 
 	mii_ethtool_gset(&nic->mii, &cmd);
 
 	if(mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
-		DPRINTK(LINK, INFO, "link up, %sMbps, %s-duplex\n",
+		ndev_info(nic->netdev, LINK, "link up, %sMbps, %s-duplex\n",
 			cmd.speed == SPEED_100 ? "100" : "10",
 			cmd.duplex == DUPLEX_FULL ? "full" : "half");
 	} else if(!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
-		DPRINTK(LINK, INFO, "link down\n");
+		ndev_info(nic->netdev, LINK, "link down\n");
 	}
 
 	mii_check_link(&nic->mii);
@@ -1623,7 +1619,7 @@ static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		   Issue a NOP command followed by a 1us delay before
 		   issuing the Tx command. */
 		if(e100_exec_cmd(nic, cuc_nop, 0))
-			DPRINTK(TX_ERR, DEBUG, "exec cuc_nop failed\n");
+			ndev_dbg(nic->netdev, TX_ERR, "exec cuc_nop failed\n");
 		udelay(1);
 	}
 
@@ -1632,12 +1628,12 @@ static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	switch(err) {
 	case -ENOSPC:
 		/* We queued the skb, but now we're out of space. */
-		DPRINTK(TX_ERR, DEBUG, "No space for CB\n");
+		ndev_dbg(nic->netdev, TX_ERR, "No space for CB\n");
 		netif_stop_queue(netdev);
 		break;
 	case -ENOMEM:
 		/* This is a hard error - log it. */
-		DPRINTK(TX_ERR, DEBUG, "Out of Tx resources, returning skb\n");
+		ndev_dbg(nic->netdev, TX_ERR, "Out of Tx resources, returning skb\n");
 		netif_stop_queue(netdev);
 		return 1;
 	}
@@ -1657,7 +1653,7 @@ static int e100_tx_clean(struct nic *nic)
 	for(cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
-		DPRINTK(TX_DONE, DEBUG, "cb[%d]->status = 0x%04X\n",
+		ndev_dbg(nic->netdev, TX_DONE, "cb[%d]->status = 0x%04X\n",
 		        (int)(((void*)cb - (void*)nic->cbs)/sizeof(struct cb)),
 		        cb->status);
 
@@ -1798,7 +1794,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 		sizeof(struct rfd), PCI_DMA_FROMDEVICE);
 	rfd_status = le16_to_cpu(rfd->status);
 
-	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);
+	ndev_dbg(nic->netdev, RX_STATUS, "status=0x%04X\n", rfd_status);
 
 	/* If data isn't ready, nothing to indicate */
 	if(unlikely(!(rfd_status & cb_complete)))
@@ -1907,7 +1903,7 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 	struct nic *nic = netdev_priv(netdev);
 	u8 stat_ack = ioread8(&nic->csr->scb.stat_ack);
 
-	DPRINTK(INTR, DEBUG, "stat_ack = 0x%02X\n", stat_ack);
+	ndev_dbg(nic->netdev, INTR, "stat_ack = 0x%02X\n", stat_ack);
 
 	if(stat_ack == stat_ack_not_ours ||	/* Not our interrupt */
 	   stat_ack == stat_ack_not_present)	/* Hardware is ejected */
@@ -2055,7 +2051,7 @@ static void e100_tx_timeout_task(struct work_struct *work)
 	struct nic *nic = container_of(work, struct nic, tx_timeout_task);
 	struct net_device *netdev = nic->netdev;
 
-	DPRINTK(TX_ERR, DEBUG, "scb.status=0x%02X\n",
+	ndev_dbg(nic->netdev, TX_ERR, "scb.status=0x%02X\n",
 		ioread8(&nic->csr->scb.status));
 	e100_down(netdev_priv(netdev));
 	e100_up(netdev_priv(netdev));
@@ -2216,18 +2212,6 @@ static int e100_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	return 0;
 }
 
-static u32 e100_get_msglevel(struct net_device *netdev)
-{
-	struct nic *nic = netdev_priv(netdev);
-	return nic->msg_enable;
-}
-
-static void e100_set_msglevel(struct net_device *netdev, u32 value)
-{
-	struct nic *nic = netdev_priv(netdev);
-	nic->msg_enable = value;
-}
-
 static int e100_nway_reset(struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
@@ -2305,7 +2289,7 @@ static int e100_set_ringparam(struct net_device *netdev,
 	rfds->count = min(rfds->count, rfds->max);
 	cbs->count = max(ring->tx_pending, cbs->min);
 	cbs->count = min(cbs->count, cbs->max);
-	DPRINTK(DRV, INFO, "Ring Param settings: rx: %d, tx %d\n",
+	ndev_info(nic->netdev, DRV, "Ring Param settings: rx: %d, tx %d\n",
 	        rfds->count, cbs->count);
 	if(netif_running(netdev))
 		e100_up(nic);
@@ -2433,8 +2417,6 @@ static const struct ethtool_ops e100_ethtool_ops = {
 	.get_regs		= e100_get_regs,
 	.get_wol		= e100_get_wol,
 	.set_wol		= e100_set_wol,
-	.get_msglevel		= e100_get_msglevel,
-	.set_msglevel		= e100_set_msglevel,
 	.nway_reset		= e100_nway_reset,
 	.get_link		= e100_get_link,
 	.get_eeprom_len		= e100_get_eeprom_len,
@@ -2481,7 +2463,7 @@ static int e100_open(struct net_device *netdev)
 
 	netif_carrier_off(netdev);
 	if((err = e100_up(nic)))
-		DPRINTK(IFUP, ERR, "Cannot open interface, aborting.\n");
+		ndev_err(nic->netdev, IFUP, "Cannot open interface, aborting.\n");
 	return err;
 }
 
@@ -2499,8 +2481,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	int err;
 
 	if(!(netdev = alloc_etherdev(sizeof(struct nic)))) {
-		if(((1 << debug) - 1) & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX "Etherdev alloc failed, abort.\n");
+		dev_err(&pdev->dev, "Etherdev alloc failed, abort.\n");
 		return -ENOMEM;
 	}
 
@@ -2525,28 +2506,30 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	nic = netdev_priv(netdev);
 	nic->netdev = netdev;
 	nic->pdev = pdev;
-	nic->msg_enable = (1 << debug) - 1;
 	pci_set_drvdata(pdev, netdev);
 
 	if((err = pci_enable_device(pdev))) {
-		DPRINTK(PROBE, ERR, "Cannot enable PCI device, aborting.\n");
+		dev_err(&pdev->dev,
+		        "Cannot enable PCI device, aborting.\n");
 		goto err_out_free_dev;
 	}
 
 	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		DPRINTK(PROBE, ERR, "Cannot find proper PCI device "
+		dev_err(&pdev->dev, "Cannot find proper PCI device "
 			"base address, aborting.\n");
 		err = -ENODEV;
 		goto err_out_disable_pdev;
 	}
 
 	if((err = pci_request_regions(pdev, DRV_NAME))) {
-		DPRINTK(PROBE, ERR, "Cannot obtain PCI resources, aborting.\n");
+		dev_err(&pdev->dev,
+		        "Cannot obtain PCI resources, aborting.\n");
 		goto err_out_disable_pdev;
 	}
 
 	if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
-		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
+		dev_err(&pdev->dev,
+		        "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;
 	}
 
@@ -2554,11 +2537,12 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	if (use_io)
-		DPRINTK(PROBE, INFO, "using i/o access mode\n");
+		dev_info(&pdev->dev, "using i/o access mode\n");
 
 	nic->csr = pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
 	if(!nic->csr) {
-		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
+		dev_err(&pdev->dev,
+		        "Cannot map device registers, aborting.\n");
 		err = -ENOMEM;
 		goto err_out_free_res;
 	}
@@ -2592,7 +2576,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	INIT_WORK(&nic->tx_timeout_task, e100_tx_timeout_task);
 
 	if((err = e100_alloc(nic))) {
-		DPRINTK(PROBE, ERR, "Cannot alloc driver memory, aborting.\n");
+		ndev_err(nic->netdev, PROBE, "Cannot alloc driver memory, aborting.\n");
 		goto err_out_iounmap;
 	}
 
@@ -2605,13 +2589,13 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	memcpy(netdev->perm_addr, nic->eeprom, ETH_ALEN);
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		if (!eeprom_bad_csum_allow) {
-			DPRINTK(PROBE, ERR, "Invalid MAC address from "
+			dev_err(&pdev->dev, "Invalid MAC address from "
 			        "EEPROM, aborting.\n");
 			err = -EAGAIN;
 			goto err_out_free;
 		} else {
-			DPRINTK(PROBE, ERR, "Invalid MAC address from EEPROM, "
-			        "you MUST configure one.\n");
+			dev_err(&pdev->dev, "Invalid MAC address from "
+			        "EEPROM, you MUST configure one.\n");
 		}
 	}
 
@@ -2623,15 +2607,17 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	/* ack any pending wake events, disable PME */
 	err = pci_enable_wake(pdev, 0, 0);
 	if (err)
-		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
+		dev_err(&pdev->dev,
+		        "Error clearing wake event\n");
 
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
-		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
+		dev_err(&pdev->dev,
+		        "Cannot register net device, aborting.\n");
 		goto err_out_free;
 	}
 
-	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, "
+	ndev_info(nic->netdev, PROBE, "addr 0x%llx, irq %d, "
 		"MAC addr %02X:%02X:%02X:%02X:%02X:%02X\n",
 		(unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0), pdev->irq,
 		netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
@@ -2772,7 +2758,8 @@ static pci_ers_result_t e100_io_slot_reset(struct pci_dev *pdev)
 	struct nic *nic = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
-		printk(KERN_ERR "e100: Cannot re-enable PCI device after reset.\n");
+		dev_err(&pdev->dev,
+		        "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
@@ -2830,10 +2817,8 @@ static struct pci_driver e100_driver = {
 
 static int __init e100_init_module(void)
 {
-	if(((1 << debug) - 1) & NETIF_MSG_DRV) {
-		printk(KERN_INFO PFX "%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
-		printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
-	}
+	printk(KERN_INFO PFX "%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
+	printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
 	return pci_register_driver(&e100_driver);
 }
 
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 16a6edf..a232f0e 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -81,20 +81,6 @@ struct e1000_adapter;
 
 #include "e1000_hw.h"
 
-#ifdef DBG
-#define E1000_DBG(args...) printk(KERN_DEBUG "e1000: " args)
-#else
-#define E1000_DBG(args...)
-#endif
-
-#define E1000_ERR(args...) printk(KERN_ERR "e1000: " args)
-
-#define PFX "e1000: "
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args))
-
 #define E1000_MAX_INTR 10
 
 /* TX/RX descriptor defines */
@@ -333,7 +319,6 @@ struct e1000_adapter {
 	struct e1000_tx_ring test_tx_ring;
 	struct e1000_rx_ring test_rx_ring;
 
-	int msg_enable;
 	boolean_t have_msi;
 
 	/* to not mess up cache alignment, always add to the bottom */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index bb08375..e5ba5ac 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -198,7 +198,7 @@ e1000_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	/* When SoL/IDER sessions are active, autoneg/speed/duplex
 	 * cannot be changed */
 	if (e1000_check_phy_reset_block(hw)) {
-		DPRINTK(DRV, ERR, "Cannot change link characteristics "
+		ndev_err(adapter->netdev, DRV, "Cannot change link characteristics "
 		        "when SoL/IDER is active.\n");
 		return -EINVAL;
 	}
@@ -356,25 +356,12 @@ e1000_set_tso(struct net_device *netdev, uint32_t data)
 	else
 		netdev->features &= ~NETIF_F_TSO6;
 
-	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
+	ndev_info(adapter->netdev, PROBE,
+	          "TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->tso_force = TRUE;
 	return 0;
 }
 
-static uint32_t
-e1000_get_msglevel(struct net_device *netdev)
-{
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-	return adapter->msg_enable;
-}
-
-static void
-e1000_set_msglevel(struct net_device *netdev, uint32_t data)
-{
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-	adapter->msg_enable = data;
-}
-
 static int
 e1000_get_regs_len(struct net_device *netdev)
 {
@@ -743,7 +730,7 @@ err_setup:
 		E1000_WRITE_REG(&adapter->hw, R, (test[pat] & W));             \
 		value = E1000_READ_REG(&adapter->hw, R);                       \
 		if (value != (test[pat] & W & M)) {                             \
-			DPRINTK(DRV, ERR, "pattern test reg %04X failed: got " \
+			ndev_err(adapter->netdev, DRV, "pattern test reg %04X failed: got " \
 			        "0x%08X expected 0x%08X\n",                    \
 			        E1000_##R, value, (test[pat] & W & M));        \
 			*data = (adapter->hw.mac_type < e1000_82543) ?         \
@@ -759,7 +746,7 @@ err_setup:
 	E1000_WRITE_REG(&adapter->hw, R, W & M);                               \
 	value = E1000_READ_REG(&adapter->hw, R);                               \
 	if ((W & M) != (value & M)) {                                          \
-		DPRINTK(DRV, ERR, "set/check reg %04X test failed: got 0x%08X "\
+		ndev_err(adapter->netdev, DRV, "set/check reg %04X test failed: got 0x%08X "\
 		        "expected 0x%08X\n", E1000_##R, (value & M), (W & M)); \
 		*data = (adapter->hw.mac_type < e1000_82543) ?                 \
 			E1000_82542_##R : E1000_##R;                           \
@@ -797,7 +784,7 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 	E1000_WRITE_REG(&adapter->hw, STATUS, toggle);
 	after = E1000_READ_REG(&adapter->hw, STATUS) & toggle;
 	if (value != after) {
-		DPRINTK(DRV, ERR, "failed STATUS register test got: "
+		ndev_err(adapter->netdev, DRV, "failed STATUS register test got: "
 		        "0x%08X expected: 0x%08X\n", after, value);
 		*data = 1;
 		return 1;
@@ -917,7 +904,7 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 		*data = 1;
 		return -1;
 	}
-	DPRINTK(HW, INFO, "testing %s interrupt\n",
+	ndev_info(adapter->netdev, HW, "testing %s interrupt\n",
 	        (shared_int ? "shared" : "unshared"));
 
 	/* Disable all the interrupts */
@@ -1562,7 +1549,7 @@ e1000_loopback_test(struct e1000_adapter *adapter, uint64_t *data)
 	/* PHY loopback cannot be performed if SoL/IDER
 	 * sessions are active */
 	if (e1000_check_phy_reset_block(&adapter->hw)) {
-		DPRINTK(DRV, ERR, "Cannot do PHY loopback test "
+		ndev_err(adapter->netdev, DRV, "Cannot do PHY loopback test "
 		        "when SoL/IDER is active.\n");
 		*data = 0;
 		goto out;
@@ -1635,7 +1622,7 @@ e1000_diag_test(struct net_device *netdev,
 		uint8_t forced_speed_duplex = adapter->hw.forced_speed_duplex;
 		uint8_t autoneg = adapter->hw.autoneg;
 
-		DPRINTK(HW, INFO, "offline testing starting\n");
+		ndev_info(adapter->netdev, HW, "offline testing starting\n");
 
 		/* Link test performed before hardware reset so autoneg doesn't
 		 * interfere with test result */
@@ -1675,7 +1662,7 @@ e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			dev_open(netdev);
 	} else {
-		DPRINTK(HW, INFO, "online testing starting\n");
+		ndev_info(adapter->netdev, HW, "online testing starting\n");
 		/* Online tests */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1770,7 +1757,7 @@ e1000_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 		wol->supported &= ~WAKE_UCAST;
 
 		if (adapter->wol & E1000_WUFC_EX)
-			DPRINTK(DRV, ERR, "Interface does not support "
+			ndev_err(adapter->netdev, DRV, "Interface does not support "
 		        "directed (unicast) frame wake-up packets\n");
 		break;
 	default:
@@ -1804,7 +1791,7 @@ e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	switch (hw->device_id) {
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		if (wol->wolopts & WAKE_UCAST) {
-			DPRINTK(DRV, ERR, "Interface does not support "
+			ndev_err(adapter->netdev, DRV, "Interface does not support "
 		        "directed (unicast) frame wake-up packets\n");
 			return -EOPNOTSUPP;
 		}
@@ -1948,8 +1935,6 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_regs               = e1000_get_regs,
 	.get_wol                = e1000_get_wol,
 	.set_wol                = e1000_set_wol,
-	.get_msglevel           = e1000_get_msglevel,
-	.set_msglevel           = e1000_set_msglevel,
 	.nway_reset             = e1000_nway_reset,
 	.get_link               = ethtool_op_get_link,
 	.get_eeprom_len         = e1000_get_eeprom_len,
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cf8af92..fcd3443 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -247,10 +247,6 @@ MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
-module_param(debug, int, 0);
-MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
-
 /**
  * e1000_init_module - Driver Registration Routine
  *
@@ -315,7 +311,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	if (err) {
 		if (adapter->have_msi)
 			pci_disable_msi(adapter->pdev);
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		        "Unable to allocate interrupt Error: %d\n", err);
 	}
 
@@ -803,7 +799,7 @@ e1000_reset(struct e1000_adapter *adapter)
 		E1000_WRITE_REG(&adapter->hw, WUC, 0);
 
 	if (e1000_init_hw(&adapter->hw))
-		DPRINTK(PROBE, ERR, "Hardware Error\n");
+		ndev_err(adapter->netdev, PROBE, "Hardware Error\n");
 	e1000_update_mng_vlan(adapter);
 
 	/* if (adapter->hwflags & HWFLAGS_PHY_PWR_BIT) { */
@@ -877,7 +873,8 @@ e1000_probe(struct pci_dev *pdev,
 	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) &&
 		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
-			E1000_ERR("No usable DMA configuration, aborting\n");
+			dev_err(&pdev->dev, "No usable DMA "
+			        "configuration, aborting\n");
 			goto err_dma;
 		}
 		pci_using_dac = 0;
@@ -901,7 +898,6 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
-	adapter->msg_enable = (1 << debug) - 1;
 
 	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
@@ -967,7 +963,8 @@ e1000_probe(struct pci_dev *pdev,
 	}
 
 	if (e1000_check_phy_reset_block(&adapter->hw))
-		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
+		dev_info(&pdev->dev, "PHY reset is blocked due to "
+		         "SOL/IDER session.\n");
 
 	if (adapter->hw.mac_type >= e1000_82543) {
 		netdev->features = NETIF_F_SG |
@@ -995,7 +992,7 @@ e1000_probe(struct pci_dev *pdev,
 	/* initialize eeprom parameters */
 
 	if (e1000_init_eeprom_params(&adapter->hw)) {
-		E1000_ERR("EEPROM initialization failed\n");
+		dev_err(&pdev->dev, "EEPROM initialization failed\n");
 		goto err_eeprom;
 	}
 
@@ -1007,19 +1004,20 @@ e1000_probe(struct pci_dev *pdev,
 	/* make sure the EEPROM is good */
 
 	if (e1000_validate_eeprom_checksum(&adapter->hw) < 0) {
-		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
+		dev_err(&pdev->dev,
+		        "The EEPROM Checksum Is Not Valid\n");
 		goto err_eeprom;
 	}
 
 	/* copy the MAC address out of the EEPROM */
 
 	if (e1000_read_mac_addr(&adapter->hw))
-		DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
+		dev_err(&pdev->dev, "EEPROM Read Error\n");
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
+		dev_err(&pdev->dev, "Invalid MAC Address\n");
 		goto err_eeprom;
 	}
 
@@ -1114,7 +1112,7 @@ e1000_probe(struct pci_dev *pdev,
 	/* print bus type/speed/width info */
 	{
 	struct e1000_hw *hw = &adapter->hw;
-	DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
+	dev_info(&pdev->dev, "(PCI%s:%s:%s) ",
 		((hw->bus_type == e1000_bus_type_pcix) ? "-X" :
 		 (hw->bus_type == e1000_bus_type_pci_express ? " Express":"")),
 		((hw->bus_speed == e1000_bus_speed_2500) ? "2.5Gb/s" :
@@ -1153,7 +1151,7 @@ e1000_probe(struct pci_dev *pdev,
 	if ((err = register_netdev(netdev)))
 		goto err_register;
 
-	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
+	ndev_info(netdev, PROBE, "Intel(R) PRO/1000 Network Connection\n");
 
 	cards_found++;
 	return 0;
@@ -1280,7 +1278,7 @@ e1000_sw_init(struct e1000_adapter *adapter)
 	/* identify the MAC */
 
 	if (e1000_set_mac_type(hw)) {
-		DPRINTK(PROBE, ERR, "Unknown MAC Type\n");
+		ndev_err(adapter->netdev, PROBE, "Unknown MAC Type\n");
 		return -EIO;
 	}
 
@@ -1313,7 +1311,7 @@ e1000_sw_init(struct e1000_adapter *adapter)
 	adapter->num_rx_queues = 1;
 
 	if (e1000_alloc_queues(adapter)) {
-		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
+		ndev_err(adapter->netdev, PROBE, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
 
@@ -1544,7 +1542,7 @@ e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	size = sizeof(struct e1000_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if (!txdr->buffer_info) {
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		"Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
@@ -1559,7 +1557,7 @@ e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	if (!txdr->desc) {
 setup_tx_desc_die:
 		vfree(txdr->buffer_info);
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		"Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
@@ -1568,7 +1566,7 @@ setup_tx_desc_die:
 	if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
 		void *olddesc = txdr->desc;
 		dma_addr_t olddma = txdr->dma;
-		DPRINTK(TX_ERR, ERR, "txdr align check failed: %u bytes "
+		ndev_err(adapter->netdev, TX_ERR, "txdr align check failed: %u bytes "
 				     "at %p\n", txdr->size, txdr->desc);
 		/* Try again, without freeing the previous */
 		txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
@@ -1583,7 +1581,7 @@ setup_tx_desc_die:
 			pci_free_consistent(pdev, txdr->size, txdr->desc,
 					    txdr->dma);
 			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
-			DPRINTK(PROBE, ERR,
+			ndev_err(adapter->netdev, PROBE,
 				"Unable to allocate aligned memory "
 				"for the transmit descriptor ring\n");
 			vfree(txdr->buffer_info);
@@ -1618,7 +1616,7 @@ e1000_setup_all_tx_resources(struct e1000_adapter *adapter)
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		err = e1000_setup_tx_resources(adapter, &adapter->tx_ring[i]);
 		if (err) {
-			DPRINTK(PROBE, ERR,
+			ndev_err(adapter->netdev, PROBE,
 				"Allocation for Tx Queue %u failed\n", i);
 			for (i-- ; i >= 0; i--)
 				e1000_free_tx_resources(adapter,
@@ -1761,7 +1759,7 @@ e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	size = sizeof(struct e1000_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if (!rxdr->buffer_info) {
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
@@ -1771,7 +1769,7 @@ e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	                        GFP_KERNEL);
 	if (!rxdr->ps_page) {
 		vfree(rxdr->buffer_info);
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
@@ -1782,7 +1780,7 @@ e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	if (!rxdr->ps_page_dma) {
 		vfree(rxdr->buffer_info);
 		kfree(rxdr->ps_page);
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
@@ -1800,7 +1798,7 @@ e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
 	if (!rxdr->desc) {
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		"Unable to allocate memory for the receive descriptor ring\n");
 setup_rx_desc_die:
 		vfree(rxdr->buffer_info);
@@ -1813,14 +1811,14 @@ setup_rx_desc_die:
 	if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
 		void *olddesc = rxdr->desc;
 		dma_addr_t olddma = rxdr->dma;
-		DPRINTK(RX_ERR, ERR, "rxdr align check failed: %u bytes "
+		ndev_err(adapter->netdev, RX_ERR, "rxdr align check failed: %u bytes "
 				     "at %p\n", rxdr->size, rxdr->desc);
 		/* Try again, without freeing the previous */
 		rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 		/* Failed allocation, critical failure */
 		if (!rxdr->desc) {
 			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
-			DPRINTK(PROBE, ERR,
+			ndev_err(adapter->netdev, PROBE,
 				"Unable to allocate memory "
 				"for the receive descriptor ring\n");
 			goto setup_rx_desc_die;
@@ -1831,7 +1829,7 @@ setup_rx_desc_die:
 			pci_free_consistent(pdev, rxdr->size, rxdr->desc,
 					    rxdr->dma);
 			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
-			DPRINTK(PROBE, ERR,
+			ndev_err(adapter->netdev, PROBE,
 				"Unable to allocate aligned memory "
 				"for the receive descriptor ring\n");
 			goto setup_rx_desc_die;
@@ -1864,7 +1862,7 @@ e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		err = e1000_setup_rx_resources(adapter, &adapter->rx_ring[i]);
 		if (err) {
-			DPRINTK(PROBE, ERR,
+			ndev_err(adapter->netdev, PROBE,
 				"Allocation for Rx Queue %u failed\n", i);
 			for (i-- ; i >= 0; i--)
 				e1000_free_rx_resources(adapter,
@@ -2568,7 +2566,7 @@ e1000_watchdog(unsigned long data)
 	    (adapter->hw.phy_type == e1000_phy_igp_3) &&
 	    (E1000_READ_REG(&adapter->hw, CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
 		/* See e1000_kumeran_lock_loss_workaround() */
-		DPRINTK(LINK, INFO,
+		ndev_info(adapter->netdev, LINK,
 			"Gigabit has been disabled, downgrading speed\n");
 	}
 
@@ -2593,7 +2591,7 @@ e1000_watchdog(unsigned long data)
 			                           &adapter->link_duplex);
 
 			ctrl = E1000_READ_REG(&adapter->hw, CTRL);
-			DPRINTK(LINK, INFO, "NIC Link is Up %d Mbps %s, "
+			ndev_info(adapter->netdev, LINK, "NIC Link is Up %d Mbps %s, "
 			        "Flow Control: %s\n",
 			        adapter->link_speed,
 			        adapter->link_duplex == FULL_DUPLEX ?
@@ -2636,7 +2634,7 @@ e1000_watchdog(unsigned long data)
 				switch (adapter->link_speed) {
 				case SPEED_10:
 				case SPEED_100:
-					DPRINTK(PROBE,INFO,
+					ndev_info(adapter->netdev, PROBE,
 				        "10/100 speed: disabling TSO\n");
 					netdev->features &= ~NETIF_F_TSO;
 					netdev->features &= ~NETIF_F_TSO6;
@@ -2673,7 +2671,7 @@ e1000_watchdog(unsigned long data)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			DPRINTK(LINK, INFO, "NIC Link is Down\n");
+			ndev_info(adapter->netdev, LINK, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
@@ -3321,7 +3319,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			case e1000_ich8lan:
 				pull_size = min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
-					DPRINTK(DRV, ERR,
+					ndev_err(adapter->netdev, DRV,
 						"__pskb_pull_tail failed.\n");
 					dev_kfree_skb_any(skb);
 					return NETDEV_TX_OK;
@@ -3485,7 +3483,7 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		DPRINTK(PROBE, ERR, "Invalid MTU setting\n");
+		ndev_err(adapter->netdev, PROBE, "Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -3494,7 +3492,7 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	case e1000_undefined ... e1000_82542_rev2_1:
 	case e1000_ich8lan:
 		if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
-			DPRINTK(PROBE, ERR, "Jumbo Frames not supported.\n");
+			ndev_err(adapter->netdev, PROBE, "Jumbo Frames not supported.\n");
 			return -EINVAL;
 		}
 		break;
@@ -3507,7 +3505,7 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		if ((adapter->hw.device_id != E1000_DEV_ID_82573L) ||
 		    (eeprom_data & EEPROM_WORD1A_ASPM_MASK)) {
 			if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
-				DPRINTK(PROBE, ERR,
+				ndev_err(adapter->netdev, PROBE,
 			            	"Jumbo Frames not supported.\n");
 				return -EINVAL;
 			}
@@ -3521,7 +3519,7 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	case e1000_80003es2lan:
 #define MAX_STD_JUMBO_FRAME_SIZE 9234
 		if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-			DPRINTK(PROBE, ERR, "MTU > 9216 not supported.\n");
+			ndev_err(adapter->netdev, PROBE, "MTU > 9216 not supported.\n");
 			return -EINVAL;
 		}
 		break;
@@ -4043,7 +4041,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		         E1000_STATUS_TXOFF)) {
 
 			/* detected Tx unit hang */
-			DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
+			ndev_err(adapter->netdev, DRV, "Detected Tx Unit Hang\n"
 					"  Tx Queue             <%lu>\n"
 					"  TDH                  <%x>\n"
 					"  TDT                  <%x>\n"
@@ -4186,8 +4184,8 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		if (unlikely(!(status & E1000_RXD_STAT_EOP))) {
 			/* All receives must fit into a single buffer */
-			E1000_DBG("%s: Receive packet consumed multiple"
-				  " buffers\n", netdev->name);
+			ndev_dbg(adapter->netdev, RX_ERR,
+			         "Receive packet consumed multiple buffers\n");
 			/* recycle */
 			buffer_info->skb = skb;
 			goto next_desc;
@@ -4353,8 +4351,9 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 				 PCI_DMA_FROMDEVICE);
 
 		if (unlikely(!(staterr & E1000_RXD_STAT_EOP))) {
-			E1000_DBG("%s: Packet Split buffers didn't pick up"
-				  " the full packet\n", netdev->name);
+			ndev_dbg(adapter->netdev, RX_ERR,
+			         "Packet Split buffers didn't pick up"
+			         " the full packetun");
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -4367,8 +4366,9 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		length = le16_to_cpu(rx_desc->wb.middle.length0);
 
 		if (unlikely(!length)) {
-			E1000_DBG("%s: Last part of the packet spanning"
-				  " multiple descriptors\n", netdev->name);
+			ndev_dbg(adapter->netdev, RX_ERR,
+			         "Last part of the packet spanning"
+			         " multiple descriptors\n");
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -4519,7 +4519,7 @@ e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 			struct sk_buff *oldskb = skb;
-			DPRINTK(RX_ERR, ERR, "skb align check failed: %u bytes "
+			ndev_err(adapter->netdev, RX_ERR, "skb align check failed: %u bytes "
 					     "at %p\n", bufsz, skb->data);
 			/* Try again, without freeing the previous */
 			skb = netdev_alloc_skb(netdev, bufsz);
@@ -4557,7 +4557,7 @@ map_skb:
 		if (!e1000_check_64k_bound(adapter,
 					(void *)(unsigned long)buffer_info->dma,
 					adapter->rx_buffer_len)) {
-			DPRINTK(RX_ERR, ERR,
+			ndev_err(adapter->netdev, RX_ERR,
 				"dma align check failed: %u bytes at %p\n",
 				adapter->rx_buffer_len,
 				(void *)(unsigned long)buffer_info->dma);
@@ -4880,7 +4880,7 @@ e1000_pci_set_mwi(struct e1000_hw *hw)
 	int ret_val = pci_set_mwi(adapter->pdev);
 
 	if (ret_val)
-		DPRINTK(PROBE, ERR, "Error in setting MWI\n");
+		ndev_err(adapter->netdev, PROBE, "Error in setting MWI\n");
 }
 
 void
@@ -5039,7 +5039,7 @@ e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx)
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((adapter->hw.media_type == e1000_media_type_fiber) &&
 		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		DPRINTK(PROBE, ERR, "Unsupported Speed/Duplex configuration\n");
+		ndev_err(adapter->netdev, PROBE, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 
@@ -5062,7 +5062,7 @@ e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		DPRINTK(PROBE, ERR, "Unsupported Speed/Duplex configuration\n");
+		ndev_err(adapter->netdev, PROBE, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -5176,7 +5176,7 @@ e1000_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	if ((err = pci_enable_device(pdev))) {
-		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
+		dev_err(&pdev->dev, "Cannot enable PCI device from suspend\n");
 		return err;
 	}
 	pci_set_master(pdev);
@@ -5272,7 +5272,8 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev->priv;
 
 	if (pci_enable_device(pdev)) {
-		printk(KERN_ERR "e1000: Cannot re-enable PCI device after reset.\n");
+		dev_err(&pdev->dev,
+		        "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
@@ -5303,7 +5304,8 @@ static void e1000_io_resume(struct pci_dev *pdev)
 
 	if (netif_running(netdev)) {
 		if (e1000_up(adapter)) {
-			printk("e1000: can't bring device back up after reset\n");
+			dev_err(&pdev->dev,
+			        "can't bring device back up after reset\n");
 			return;
 		}
 	}
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index f485874..d3f25bc 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -226,16 +226,16 @@ e1000_validate_option(int *value, struct e1000_option *opt,
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			DPRINTK(PROBE, INFO, "%s Enabled\n", opt->name);
+			ndev_info(adapter->netdev, PROBE, "%s Enabled\n", opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			DPRINTK(PROBE, INFO, "%s Disabled\n", opt->name);
+			ndev_info(adapter->netdev, PROBE, "%s Disabled\n", opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			DPRINTK(PROBE, INFO,
+			ndev_info(adapter->netdev, PROBE,
 					"%s set to %i\n", opt->name, *value);
 			return 0;
 		}
@@ -248,7 +248,7 @@ e1000_validate_option(int *value, struct e1000_option *opt,
 			ent = &opt->arg.l.p[i];
 			if (*value == ent->i) {
 				if (ent->str[0] != '\0')
-					DPRINTK(PROBE, INFO, "%s\n", ent->str);
+					ndev_info(adapter->netdev, PROBE, "%s\n", ent->str);
 				return 0;
 			}
 		}
@@ -258,7 +258,7 @@ e1000_validate_option(int *value, struct e1000_option *opt,
 		BUG();
 	}
 
-	DPRINTK(PROBE, INFO, "Invalid %s value specified (%i) %s\n",
+	ndev_info(adapter->netdev, PROBE, "Invalid %s value specified (%i) %s\n",
 	       opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
@@ -282,9 +282,10 @@ e1000_check_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 	if (bd >= E1000_MAX_NIC) {
-		DPRINTK(PROBE, NOTICE,
-		       "Warning: no configuration for board #%i\n", bd);
-		DPRINTK(PROBE, NOTICE, "Using defaults for all values\n");
+		ndev_info(adapter->netdev, PROBE,
+		          "Warning: no configuration for board #%i\n", bd);
+		ndev_info(adapter->netdev, PROBE,
+		          "Using defaults for all values\n");
 	}
 
 	{ /* Transmit Descriptor Count */
@@ -467,17 +468,17 @@ e1000_check_options(struct e1000_adapter *adapter)
 			adapter->itr = InterruptThrottleRate[bd];
 			switch (adapter->itr) {
 			case 0:
-				DPRINTK(PROBE, INFO, "%s turned off\n",
+				ndev_info(adapter->netdev, PROBE, "%s turned off\n",
 				        opt.name);
 				break;
 			case 1:
-				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
+				ndev_info(adapter->netdev, PROBE, "%s set to dynamic mode\n",
 					opt.name);
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;
 				break;
 			case 3:
-				DPRINTK(PROBE, INFO,
+				ndev_info(adapter->netdev, PROBE,
 				        "%s set to dynamic conservative mode\n",
 					opt.name);
 				adapter->itr_setting = adapter->itr;
@@ -555,17 +556,17 @@ e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 	if (num_Speed > bd) {
-		DPRINTK(PROBE, INFO, "Speed not valid for fiber adapters, "
+		ndev_info(adapter->netdev, PROBE, "Speed not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
 
 	if (num_Duplex > bd) {
-		DPRINTK(PROBE, INFO, "Duplex not valid for fiber adapters, "
+		ndev_info(adapter->netdev, PROBE, "Duplex not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
 
 	if ((num_AutoNeg > bd) && (AutoNeg[bd] != 0x20)) {
-		DPRINTK(PROBE, INFO, "AutoNeg other than 1000/Full is "
+		ndev_info(adapter->netdev, PROBE, "AutoNeg other than 1000/Full is "
 				 "not valid for fiber adapters, "
 				 "parameter ignored\n");
 	}
@@ -621,7 +622,7 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 		};
 
 		if (e1000_check_phy_reset_block(&adapter->hw)) {
-			DPRINTK(PROBE, INFO,
+			ndev_info(adapter->netdev, PROBE,
 				"Link active due to SoL/IDER Session. "
 			        "Speed/Duplex/AutoNeg parameter ignored.\n");
 			return;
@@ -635,7 +636,7 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 	}
 
 	if ((num_AutoNeg > bd) && (speed != 0 || dplx != 0)) {
-		DPRINTK(PROBE, INFO,
+		ndev_info(adapter->netdev, PROBE,
 		       "AutoNeg specified along with Speed or Duplex, "
 		       "parameter ignored\n");
 		adapter->hw.autoneg_advertised = AUTONEG_ADV_DEFAULT;
@@ -696,20 +697,20 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 	case 0:
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		if ((num_Speed > bd) && (speed != 0 || dplx != 0))
-			DPRINTK(PROBE, INFO,
+			ndev_info(adapter->netdev, PROBE,
 			       "Speed and duplex autonegotiation enabled\n");
 		break;
 	case HALF_DUPLEX:
-		DPRINTK(PROBE, INFO, "Half Duplex specified without Speed\n");
-		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+		ndev_info(adapter->netdev, PROBE, "Half Duplex specified without Speed\n");
+		ndev_info(adapter->netdev, PROBE, "Using Autonegotiation at "
 			"Half Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 		                                 ADVERTISE_100_HALF;
 		break;
 	case FULL_DUPLEX:
-		DPRINTK(PROBE, INFO, "Full Duplex specified without Speed\n");
-		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+		ndev_info(adapter->netdev, PROBE, "Full Duplex specified without Speed\n");
+		ndev_info(adapter->netdev, PROBE, "Using Autonegotiation at "
 			"Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_FULL |
@@ -717,57 +718,57 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 		                                 ADVERTISE_1000_FULL;
 		break;
 	case SPEED_10:
-		DPRINTK(PROBE, INFO, "10 Mbps Speed specified "
+		ndev_info(adapter->netdev, PROBE, "10 Mbps Speed specified "
 			"without Duplex\n");
-		DPRINTK(PROBE, INFO, "Using Autonegotiation at 10 Mbps only\n");
+		ndev_info(adapter->netdev, PROBE, "Using Autonegotiation at 10 Mbps only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 		                                 ADVERTISE_10_FULL;
 		break;
 	case SPEED_10 + HALF_DUPLEX:
-		DPRINTK(PROBE, INFO, "Forcing to 10 Mbps Half Duplex\n");
+		ndev_info(adapter->netdev, PROBE, "Forcing to 10 Mbps Half Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_10_half;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_10 + FULL_DUPLEX:
-		DPRINTK(PROBE, INFO, "Forcing to 10 Mbps Full Duplex\n");
+		ndev_info(adapter->netdev, PROBE, "Forcing to 10 Mbps Full Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_10_full;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100:
-		DPRINTK(PROBE, INFO, "100 Mbps Speed specified "
+		ndev_info(adapter->netdev, PROBE, "100 Mbps Speed specified "
 			"without Duplex\n");
-		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+		ndev_info(adapter->netdev, PROBE, "Using Autonegotiation at "
 			"100 Mbps only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_100_HALF |
 		                                 ADVERTISE_100_FULL;
 		break;
 	case SPEED_100 + HALF_DUPLEX:
-		DPRINTK(PROBE, INFO, "Forcing to 100 Mbps Half Duplex\n");
+		ndev_info(adapter->netdev, PROBE, "Forcing to 100 Mbps Half Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_100_half;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100 + FULL_DUPLEX:
-		DPRINTK(PROBE, INFO, "Forcing to 100 Mbps Full Duplex\n");
+		ndev_info(adapter->netdev, PROBE, "Forcing to 100 Mbps Full Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_100_full;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_1000:
-		DPRINTK(PROBE, INFO, "1000 Mbps Speed specified without "
+		ndev_info(adapter->netdev, PROBE, "1000 Mbps Speed specified without "
 			"Duplex\n");
 		goto full_duplex_only;
 	case SPEED_1000 + HALF_DUPLEX:
-		DPRINTK(PROBE, INFO,
+		ndev_info(adapter->netdev, PROBE,
 			"Half Duplex is not supported at 1000 Mbps\n");
 		/* fall through */
 	case SPEED_1000 + FULL_DUPLEX:
 full_duplex_only:
-		DPRINTK(PROBE, INFO,
+		ndev_info(adapter->netdev, PROBE,
 		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
@@ -778,7 +779,7 @@ full_duplex_only:
 
 	/* Speed, AutoNeg and MDI/MDI-X must all play nice */
 	if (e1000_validate_mdi_setting(&(adapter->hw)) < 0) {
-		DPRINTK(PROBE, INFO,
+		ndev_info(adapter->netdev, PROBE,
 			"Speed, AutoNeg and MDI-X specifications are "
 			"incompatible. Setting MDI-X to a compatible value.\n");
 	}
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 3569d5b..d65cbea 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -75,19 +75,6 @@ struct ixgb_adapter;
 #include "ixgb_ee.h"
 #include "ixgb_ids.h"
 
-#ifdef _DEBUG_DRIVER_
-#define IXGB_DBG(args...) printk(KERN_DEBUG "ixgb: " args)
-#else
-#define IXGB_DBG(args...)
-#endif
-
-#define PFX "ixgb: "
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args))
-
-
 /* TX/RX descriptor defines */
 #define DEFAULT_TXD	 256
 #define MAX_TXD   	4096
@@ -190,7 +177,6 @@ struct ixgb_adapter {
 
 	/* structs defined in ixgb_hw.h */
 	struct ixgb_hw hw;
-	u16 msg_enable;
 	struct ixgb_hw_stats stats;
 	uint32_t alloc_rx_buff_failed;
 	boolean_t have_msi;
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index afde848..b68b30e 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -248,19 +248,6 @@ ixgb_set_tso(struct net_device *netdev, uint32_t data)
 	return 0;
 } 
 
-static uint32_t
-ixgb_get_msglevel(struct net_device *netdev)
-{
-	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	return adapter->msg_enable;
-}
-
-static void
-ixgb_set_msglevel(struct net_device *netdev, uint32_t data)
-{
-	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	adapter->msg_enable = data;
-}
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_
 
 static int 
@@ -716,8 +703,6 @@ static const struct ethtool_ops ixgb_ethtool_ops = {
 	.set_tx_csum = ixgb_set_tx_csum,
 	.get_sg	= ethtool_op_get_sg,
 	.set_sg	= ethtool_op_set_sg,
-	.get_msglevel = ixgb_get_msglevel,
-	.set_msglevel = ixgb_set_msglevel,
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ixgb_set_tso,
 	.get_strings = ixgb_get_strings,
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 991c883..23e74d0 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -145,11 +145,6 @@ MODULE_DESCRIPTION("Intel(R) PRO/10GbE Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-#define DEFAULT_DEBUG_LEVEL_SHIFT 3
-static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
-module_param(debug, int, 0);
-MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
-
 /* some defines for controlling descriptor fetches in h/w */
 #define RXDCTL_WTHRESH_DEFAULT 15  /* chip writes back at this many or RXT0 */
 #define RXDCTL_PTHRESH_DEFAULT 0   /* chip considers prefech below
@@ -261,7 +256,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 	if (err) {
 		if (adapter->have_msi)
 			pci_disable_msi(adapter->pdev);
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		 "Unable to allocate interrupt Error: %d\n", err);
 		return err;
 	}
@@ -327,7 +322,7 @@ ixgb_reset(struct ixgb_adapter *adapter)
 
 	ixgb_adapter_stop(&adapter->hw);
 	if(!ixgb_init_hw(&adapter->hw))
-		DPRINTK(PROBE, ERR, "ixgb_init_hw failed.\n");
+		ndev_err(adapter->netdev, PROBE, "ixgb_init_hw failed.\n");
 }
 
 /**
@@ -364,8 +359,8 @@ ixgb_probe(struct pci_dev *pdev,
 	} else {
 		if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
 		   (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
-			printk(KERN_ERR
-			 "ixgb: No usable DMA configuration, aborting\n");
+			dev_err(&pdev->dev,
+			        "No usable DMA configuration, aborting\n");
 			goto err_dma_mask;
 		}
 		pci_using_dac = 0;
@@ -390,7 +385,6 @@ ixgb_probe(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
-	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
 	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
@@ -461,7 +455,7 @@ ixgb_probe(struct pci_dev *pdev,
 	/* make sure the EEPROM is good */
 
 	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
-		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
+		dev_err(&pdev->dev, "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -470,7 +464,7 @@ ixgb_probe(struct pci_dev *pdev,
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
 	if(!is_valid_ether_addr(netdev->perm_addr)) {
-		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
+		dev_err(&pdev->dev, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -492,7 +486,7 @@ ixgb_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	DPRINTK(PROBE, INFO, "Intel(R) PRO/10GbE Network Connection\n");
+	ndev_info(adapter->netdev, PROBE, "Intel(R) PRO/10GbE Network Connection\n");
 	ixgb_check_options(adapter);
 	/* reset the hardware with the new settings */
 
@@ -572,7 +566,7 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 			hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */
-		DPRINTK(PROBE, ERR, "unsupported device id\n");
+		ndev_err(adapter->netdev, PROBE, "unsupported device id\n");
 	}
 
 	/* enable flow control to be programmed */
@@ -670,7 +664,7 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	size = sizeof(struct ixgb_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if(!txdr->buffer_info) {
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		 "Unable to allocate transmit descriptor ring memory\n");
 		return -ENOMEM;
 	}
@@ -684,7 +678,7 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
 		vfree(txdr->buffer_info);
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		 "Unable to allocate transmit descriptor memory\n");
 		return -ENOMEM;
 	}
@@ -759,7 +753,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if(!rxdr->buffer_info) {
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		 "Unable to allocate receive descriptor ring\n");
 		return -ENOMEM;
 	}
@@ -774,7 +768,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 
 	if(!rxdr->desc) {
 		vfree(rxdr->buffer_info);
-		DPRINTK(PROBE, ERR,
+		ndev_err(adapter->netdev, PROBE,
 		 "Unable to allocate receive descriptors\n");
 		return -ENOMEM;
 	}
@@ -1121,7 +1115,7 @@ ixgb_watchdog(unsigned long data)
 
 	if(adapter->hw.link_up) {
 		if(!netif_carrier_ok(netdev)) {
-			DPRINTK(LINK, INFO,
+			ndev_info(adapter->netdev, LINK,
 			        "NIC Link is Up 10000 Mbps Full Duplex\n");
 			adapter->link_speed = 10000;
 			adapter->link_duplex = FULL_DUPLEX;
@@ -1132,7 +1126,7 @@ ixgb_watchdog(unsigned long data)
 		if(netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			DPRINTK(LINK, INFO, "NIC Link is Down\n");
+			ndev_info(adapter->netdev, LINK, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 
@@ -1574,7 +1568,7 @@ ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
 	   || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
-		DPRINTK(PROBE, ERR, "Invalid MTU setting %d\n", new_mtu);
+		ndev_err(adapter->netdev, PROBE, "Invalid MTU setting %d\n", new_mtu);
 		return -EINVAL;
 	}
 
@@ -1861,7 +1855,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
 		        IXGB_STATUS_TXOFF)) {
 			/* detected Tx unit hang */
-			DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
+			ndev_err(adapter->netdev, DRV, "Detected Tx Unit Hang\n"
 					"  TDH                  <%x>\n"
 					"  TDT                  <%x>\n"
 					"  next_to_use          <%x>\n"
@@ -1985,9 +1979,9 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		if(unlikely(!(status & IXGB_RX_DESC_STATUS_EOP))) {
 
 			/* All receives must fit into a single buffer */
-
-			IXGB_DBG("Receive packet consumed multiple buffers "
-					 "length<%x>\n", length);
+			ndev_err(adapter->netdev, RX_ERR,
+			         "Receive packet consumed multiple buffers "
+			         "length<%x>\n", length);
 
 			dev_kfree_skb_irq(skb);
 			goto rxdesc_done;
@@ -2295,7 +2289,7 @@ static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
 	if(pci_enable_device(pdev)) {
-		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after reset.\n");
+		ndev_err(adapter->netdev, PROBE, "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
@@ -2311,14 +2305,14 @@ static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
 
 	/* Make sure the EEPROM is good */
 	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
-		DPRINTK(PROBE, ERR, "After reset, the EEPROM checksum is not valid.\n");
+		ndev_err(adapter->netdev, PROBE, "After reset, the EEPROM checksum is not valid.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
 	if(!is_valid_ether_addr(netdev->perm_addr)) {
-		DPRINTK(PROBE, ERR, "After reset, invalid MAC address.\n");
+		ndev_err(adapter->netdev, PROBE, "After reset, invalid MAC address.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
