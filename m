From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 06/15] drivers/net/cassini.c: Use (pr|netdev|netif)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:53 -0800
Message-ID: <4e4c97e3bafbc990508508bd9a0e8bef0ffb57d4.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Use netif_<level>
Remove periods from formats
Coalesce long formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cassini.c |  361 +++++++++++++++++++++----------------------------
 1 files changed, 151 insertions(+), 210 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index ad47e51..adecd88 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -66,6 +66,7 @@
  * by default, the selective clear mask is set up to process rx packets.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -143,7 +144,6 @@
 #undef  RX_COUNT_BUFFERS    /* define to calculate RX buffer stats */
 
 #define DRV_MODULE_NAME		"cassini"
-#define PFX DRV_MODULE_NAME	": "
 #define DRV_MODULE_VERSION	"1.6"
 #define DRV_MODULE_RELDATE	"21 May 2008"
 
@@ -649,9 +649,8 @@ static cas_page_t *cas_page_dequeue(struct cas *cp)
 		cas_spare_recover(cp, GFP_ATOMIC);
 		spin_lock(&cp->rx_spare_lock);
 		if (list_empty(&cp->rx_spare_list)) {
-			if (netif_msg_rx_err(cp))
-				printk(KERN_ERR "%s: no spare buffers "
-				       "available.\n", cp->dev->name);
+			netif_err(cp, rx_err, cp->dev,
+				  "no spare buffers available\n");
 			spin_unlock(&cp->rx_spare_lock);
 			return NULL;
 		}
@@ -728,12 +727,10 @@ static void cas_begin_auto_negotiation(struct cas *cp, struct ethtool_cmd *ep)
 #endif
 start_aneg:
 	if (cp->lstate == link_up) {
-		printk(KERN_INFO "%s: PCS link down.\n",
-		       cp->dev->name);
+		netdev_info(cp->dev, "PCS link down\n");
 	} else {
 		if (changed) {
-			printk(KERN_INFO "%s: link configuration changed\n",
-			       cp->dev->name);
+			netdev_info(cp->dev, "link configuration changed\n");
 		}
 	}
 	cp->lstate = link_down;
@@ -826,12 +823,12 @@ static int cas_saturn_firmware_init(struct cas *cp)
 
 	err = request_firmware(&fw, fw_name, &cp->pdev->dev);
 	if (err) {
-		printk(KERN_ERR "cassini: Failed to load firmware \"%s\"\n",
+		pr_err("Failed to load firmware \"%s\"\n",
 		       fw_name);
 		return err;
 	}
 	if (fw->size < 2) {
-		printk(KERN_ERR "cassini: bogus length %zu in \"%s\"\n",
+		pr_err("bogus length %zu in \"%s\"\n",
 		       fw->size, fw_name);
 		err = -EINVAL;
 		goto out;
@@ -841,7 +838,7 @@ static int cas_saturn_firmware_init(struct cas *cp)
 	cp->fw_data = vmalloc(cp->fw_size);
 	if (!cp->fw_data) {
 		err = -ENOMEM;
-		printk(KERN_ERR "cassini: \"%s\" Failed %d\n", fw_name, err);
+		pr_err("\"%s\" Failed %d\n", fw_name, err);
 		goto out;
 	}
 	memcpy(cp->fw_data, &fw->data[2], cp->fw_size);
@@ -986,9 +983,8 @@ static void cas_phy_init(struct cas *cp)
 				break;
 		}
 		if (limit <= 0)
-			printk(KERN_WARNING "%s: PCS reset bit would not "
-			       "clear [%08x].\n", cp->dev->name,
-			       readl(cp->regs + REG_PCS_STATE_MACHINE));
+			netdev_warn(cp->dev, "PCS reset bit would not clear [%08x]\n",
+				    readl(cp->regs + REG_PCS_STATE_MACHINE));
 
 		/* Make sure PCS is disabled while changing advertisement
 		 * configuration.
@@ -1030,11 +1026,8 @@ static int cas_pcs_link_check(struct cas *cp)
 	 */
 	if ((stat & (PCS_MII_STATUS_AUTONEG_COMP |
 		     PCS_MII_STATUS_REMOTE_FAULT)) ==
-	    (PCS_MII_STATUS_AUTONEG_COMP | PCS_MII_STATUS_REMOTE_FAULT)) {
-		if (netif_msg_link(cp))
-			printk(KERN_INFO "%s: PCS RemoteFault\n",
-			       cp->dev->name);
-	}
+	    (PCS_MII_STATUS_AUTONEG_COMP | PCS_MII_STATUS_REMOTE_FAULT))
+		netif_info(cp, link, cp->dev, "PCS RemoteFault\n");
 
 	/* work around link detection issue by querying the PCS state
 	 * machine directly.
@@ -1081,10 +1074,8 @@ static int cas_pcs_link_check(struct cas *cp)
 			cp->link_transition = LINK_TRANSITION_ON_FAILURE;
 		}
 		netif_carrier_off(cp->dev);
-		if (cp->opened && netif_msg_link(cp)) {
-			printk(KERN_INFO "%s: PCS link down.\n",
-			       cp->dev->name);
-		}
+		if (cp->opened)
+			netif_info(cp, link, cp->dev, "PCS link down\n");
 
 		/* Cassini only: if you force a mode, there can be
 		 * sync problems on link down. to fix that, the following
@@ -1139,9 +1130,8 @@ static int cas_txmac_interrupt(struct net_device *dev,
 	if (!txmac_stat)
 		return 0;
 
-	if (netif_msg_intr(cp))
-		printk(KERN_DEBUG "%s: txmac interrupt, txmac_stat: 0x%x\n",
-			cp->dev->name, txmac_stat);
+	netif_printk(cp, intr, KERN_DEBUG, cp->dev,
+		     "txmac interrupt, txmac_stat: 0x%x\n", txmac_stat);
 
 	/* Defer timer expiration is quite normal,
 	 * don't even log the event.
@@ -1152,14 +1142,12 @@ static int cas_txmac_interrupt(struct net_device *dev,
 
 	spin_lock(&cp->stat_lock[0]);
 	if (txmac_stat & MAC_TX_UNDERRUN) {
-		printk(KERN_ERR "%s: TX MAC xmit underrun.\n",
-		       dev->name);
+		netdev_err(dev, "TX MAC xmit underrun\n");
 		cp->net_stats[0].tx_fifo_errors++;
 	}
 
 	if (txmac_stat & MAC_TX_MAX_PACKET_ERR) {
-		printk(KERN_ERR "%s: TX MAC max packet size error.\n",
-		       dev->name);
+		netdev_err(dev, "TX MAC max packet size error\n");
 		cp->net_stats[0].tx_errors++;
 	}
 
@@ -1487,8 +1475,7 @@ static int cas_rxmac_reset(struct cas *cp)
 		udelay(10);
 	}
 	if (limit == STOP_TRIES) {
-		printk(KERN_ERR "%s: RX MAC will not disable, resetting whole "
-		       "chip.\n", dev->name);
+		netdev_err(dev, "RX MAC will not disable, resetting whole chip\n");
 		return 1;
 	}
 
@@ -1500,8 +1487,7 @@ static int cas_rxmac_reset(struct cas *cp)
 		udelay(10);
 	}
 	if (limit == STOP_TRIES) {
-		printk(KERN_ERR "%s: RX DMA will not disable, resetting whole "
-		       "chip.\n", dev->name);
+		netdev_err(dev, "RX DMA will not disable, resetting whole chip\n");
 		return 1;
 	}
 
@@ -1515,8 +1501,7 @@ static int cas_rxmac_reset(struct cas *cp)
 		udelay(10);
 	}
 	if (limit == STOP_TRIES) {
-		printk(KERN_ERR "%s: RX reset command will not execute, "
-		       "resetting whole chip.\n", dev->name);
+		netdev_err(dev, "RX reset command will not execute, resetting whole chip\n");
 		return 1;
 	}
 
@@ -1545,9 +1530,7 @@ static int cas_rxmac_interrupt(struct net_device *dev, struct cas *cp,
 	if (!stat)
 		return 0;
 
-	if (netif_msg_intr(cp))
-		printk(KERN_DEBUG "%s: rxmac interrupt, stat: 0x%x\n",
-			cp->dev->name, stat);
+	netif_dbg(cp, intr, cp->dev, "rxmac interrupt, stat: 0x%x\n", stat);
 
 	/* these are all rollovers */
 	spin_lock(&cp->stat_lock[0]);
@@ -1580,9 +1563,8 @@ static int cas_mac_interrupt(struct net_device *dev, struct cas *cp,
 	if (!stat)
 		return 0;
 
-	if (netif_msg_intr(cp))
-		printk(KERN_DEBUG "%s: mac interrupt, stat: 0x%x\n",
-			cp->dev->name, stat);
+	netif_printk(cp, intr, KERN_DEBUG, cp->dev,
+		     "mac interrupt, stat: 0x%x\n", stat);
 
 	/* This interrupt is just for pause frame and pause
 	 * tracking.  It is useful for diagnostics and debug
@@ -1605,9 +1587,7 @@ static inline int cas_mdio_link_not_up(struct cas *cp)
 
 	switch (cp->lstate) {
 	case link_force_ret:
-		if (netif_msg_link(cp))
-			printk(KERN_INFO "%s: Autoneg failed again, keeping"
-				" forced mode\n", cp->dev->name);
+		netif_info(cp, link, cp->dev, "Autoneg failed again, keeping forced mode\n");
 		cas_phy_write(cp, MII_BMCR, cp->link_fcntl);
 		cp->timer_ticks = 5;
 		cp->lstate = link_force_ok;
@@ -1675,9 +1655,9 @@ static int cas_mii_link_check(struct cas *cp, const u16 bmsr)
 			cas_mif_poll(cp, 0);
 			cp->link_fcntl = cas_phy_read(cp, MII_BMCR);
 			cp->timer_ticks = 5;
-			if (cp->opened && netif_msg_link(cp))
-				printk(KERN_INFO "%s: Got link after fallback, retrying"
-				       " autoneg once...\n", cp->dev->name);
+			if (cp->opened)
+				netif_info(cp, link, cp->dev,
+					   "Got link after fallback, retrying autoneg once...\n");
 			cas_phy_write(cp, MII_BMCR,
 				      cp->link_fcntl | BMCR_ANENABLE |
 				      BMCR_ANRESTART);
@@ -1704,9 +1684,8 @@ static int cas_mii_link_check(struct cas *cp, const u16 bmsr)
 		cp->link_transition = LINK_TRANSITION_LINK_DOWN;
 
 		netif_carrier_off(cp->dev);
-		if (cp->opened && netif_msg_link(cp))
-			printk(KERN_INFO "%s: Link down\n",
-			       cp->dev->name);
+		if (cp->opened)
+			netif_info(cp, link, cp->dev, "Link down\n");
 		restart = 1;
 
 	} else if (++cp->timer_ticks > 10)
@@ -1737,23 +1716,23 @@ static int cas_pci_interrupt(struct net_device *dev, struct cas *cp,
 	if (!stat)
 		return 0;
 
-	printk(KERN_ERR "%s: PCI error [%04x:%04x] ", dev->name, stat,
-	       readl(cp->regs + REG_BIM_DIAG));
+	netdev_err(dev, "PCI error [%04x:%04x]",
+		   stat, readl(cp->regs + REG_BIM_DIAG));
 
 	/* cassini+ has this reserved */
 	if ((stat & PCI_ERR_BADACK) &&
 	    ((cp->cas_flags & CAS_FLAG_REG_PLUS) == 0))
-		printk("<No ACK64# during ABS64 cycle> ");
+		pr_cont(" <No ACK64# during ABS64 cycle>");
 
 	if (stat & PCI_ERR_DTRTO)
-		printk("<Delayed transaction timeout> ");
+		pr_cont(" <Delayed transaction timeout>");
 	if (stat & PCI_ERR_OTHER)
-		printk("<other> ");
+		pr_cont(" <other>");
 	if (stat & PCI_ERR_BIM_DMA_WRITE)
-		printk("<BIM DMA 0 write req> ");
+		pr_cont(" <BIM DMA 0 write req>");
 	if (stat & PCI_ERR_BIM_DMA_READ)
-		printk("<BIM DMA 0 read req> ");
-	printk("\n");
+		pr_cont(" <BIM DMA 0 read req>");
+	pr_cont("\n");
 
 	if (stat & PCI_ERR_OTHER) {
 		u16 cfg;
@@ -1762,25 +1741,19 @@ static int cas_pci_interrupt(struct net_device *dev, struct cas *cp,
 		 * true cause.
 		 */
 		pci_read_config_word(cp->pdev, PCI_STATUS, &cfg);
-		printk(KERN_ERR "%s: Read PCI cfg space status [%04x]\n",
-		       dev->name, cfg);
+		netdev_err(dev, "Read PCI cfg space status [%04x]\n", cfg);
 		if (cfg & PCI_STATUS_PARITY)
-			printk(KERN_ERR "%s: PCI parity error detected.\n",
-			       dev->name);
+			netdev_err(dev, "PCI parity error detected\n");
 		if (cfg & PCI_STATUS_SIG_TARGET_ABORT)
-			printk(KERN_ERR "%s: PCI target abort.\n",
-			       dev->name);
+			netdev_err(dev, "PCI target abort\n");
 		if (cfg & PCI_STATUS_REC_TARGET_ABORT)
-			printk(KERN_ERR "%s: PCI master acks target abort.\n",
-			       dev->name);
+			netdev_err(dev, "PCI master acks target abort\n");
 		if (cfg & PCI_STATUS_REC_MASTER_ABORT)
-			printk(KERN_ERR "%s: PCI master abort.\n", dev->name);
+			netdev_err(dev, "PCI master abort\n");
 		if (cfg & PCI_STATUS_SIG_SYSTEM_ERROR)
-			printk(KERN_ERR "%s: PCI system error SERR#.\n",
-			       dev->name);
+			netdev_err(dev, "PCI system error SERR#\n");
 		if (cfg & PCI_STATUS_DETECTED_PARITY)
-			printk(KERN_ERR "%s: PCI parity error.\n",
-			       dev->name);
+			netdev_err(dev, "PCI parity error\n");
 
 		/* Write the error bits back to clear them. */
 		cfg &= (PCI_STATUS_PARITY |
@@ -1806,9 +1779,8 @@ static int cas_abnormal_irq(struct net_device *dev, struct cas *cp,
 {
 	if (status & INTR_RX_TAG_ERROR) {
 		/* corrupt RX tag framing */
-		if (netif_msg_rx_err(cp))
-			printk(KERN_DEBUG "%s: corrupt rx tag framing\n",
-				cp->dev->name);
+		netif_printk(cp, rx_err, KERN_DEBUG, cp->dev,
+			     "corrupt rx tag framing\n");
 		spin_lock(&cp->stat_lock[0]);
 		cp->net_stats[0].rx_errors++;
 		spin_unlock(&cp->stat_lock[0]);
@@ -1817,9 +1789,8 @@ static int cas_abnormal_irq(struct net_device *dev, struct cas *cp,
 
 	if (status & INTR_RX_LEN_MISMATCH) {
 		/* length mismatch. */
-		if (netif_msg_rx_err(cp))
-			printk(KERN_DEBUG "%s: length mismatch for rx frame\n",
-				cp->dev->name);
+		netif_printk(cp, rx_err, KERN_DEBUG, cp->dev,
+			     "length mismatch for rx frame\n");
 		spin_lock(&cp->stat_lock[0]);
 		cp->net_stats[0].rx_errors++;
 		spin_unlock(&cp->stat_lock[0]);
@@ -1861,12 +1832,11 @@ do_reset:
 #if 1
 	atomic_inc(&cp->reset_task_pending);
 	atomic_inc(&cp->reset_task_pending_all);
-	printk(KERN_ERR "%s:reset called in cas_abnormal_irq [0x%x]\n",
-	       dev->name, status);
+	netdev_err(dev, "reset called in cas_abnormal_irq [0x%x]\n", status);
 	schedule_work(&cp->reset_task);
 #else
 	atomic_set(&cp->reset_task_pending, CAS_RESET_ALL);
-	printk(KERN_ERR "reset called in cas_abnormal_irq\n");
+	netdev_err(dev, "reset called in cas_abnormal_irq\n");
 	schedule_work(&cp->reset_task);
 #endif
 	return 1;
@@ -1920,9 +1890,8 @@ static inline void cas_tx_ringN(struct cas *cp, int ring, int limit)
 		if (count < 0)
 			break;
 
-		if (netif_msg_tx_done(cp))
-			printk(KERN_DEBUG "%s: tx[%d] done, slot %d\n",
-			       cp->dev->name, ring, entry);
+		netif_printk(cp, tx_done, KERN_DEBUG, cp->dev,
+			     "tx[%d] done, slot %d\n", ring, entry);
 
 		skbs[entry] = NULL;
 		cp->tx_tiny_use[ring][entry].nbufs = 0;
@@ -1969,9 +1938,9 @@ static void cas_tx(struct net_device *dev, struct cas *cp,
 #ifdef USE_TX_COMPWB
 	u64 compwb = le64_to_cpu(cp->init_block->tx_compwb);
 #endif
-	if (netif_msg_intr(cp))
-		printk(KERN_DEBUG "%s: tx interrupt, status: 0x%x, %llx\n",
-			cp->dev->name, status, (unsigned long long)compwb);
+	netif_printk(cp, intr, KERN_DEBUG, cp->dev,
+		     "tx interrupt, status: 0x%x, %llx\n",
+		     status, (unsigned long long)compwb);
 	/* process all the rings */
 	for (ring = 0; ring < N_TX_RINGS; ring++) {
 #ifdef USE_TX_COMPWB
@@ -2050,10 +2019,8 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 
 		hlen = min(cp->page_size - off, dlen);
 		if (hlen < 0) {
-			if (netif_msg_rx_err(cp)) {
-				printk(KERN_DEBUG "%s: rx page overflow: "
-				       "%d\n", cp->dev->name, hlen);
-			}
+			netif_printk(cp, rx_err, KERN_DEBUG, cp->dev,
+				     "rx page overflow: %d\n", hlen);
 			dev_kfree_skb_irq(skb);
 			return -1;
 		}
@@ -2130,10 +2097,8 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 		off = CAS_VAL(RX_COMP1_DATA_OFF, words[0]) + swivel;
 		hlen = min(cp->page_size - off, dlen);
 		if (hlen < 0) {
-			if (netif_msg_rx_err(cp)) {
-				printk(KERN_DEBUG "%s: rx page overflow: "
-				       "%d\n", cp->dev->name, hlen);
-			}
+			netif_printk(cp, rx_err, KERN_DEBUG, cp->dev,
+				     "rx page overflow: %d\n", hlen);
 			dev_kfree_skb_irq(skb);
 			return -1;
 		}
@@ -2265,9 +2230,8 @@ static int cas_post_rxds_ringN(struct cas *cp, int ring, int num)
 
 	entry = cp->rx_old[ring];
 
-	if (netif_msg_intr(cp))
-		printk(KERN_DEBUG "%s: rxd[%d] interrupt, done: %d\n",
-		       cp->dev->name, ring, entry);
+	netif_printk(cp, intr, KERN_DEBUG, cp->dev,
+		     "rxd[%d] interrupt, done: %d\n", ring, entry);
 
 	cluster = -1;
 	count = entry & 0x3;
@@ -2337,11 +2301,10 @@ static int cas_rx_ringN(struct cas *cp, int ring, int budget)
 	int entry, drops;
 	int npackets = 0;
 
-	if (netif_msg_intr(cp))
-		printk(KERN_DEBUG "%s: rx[%d] interrupt, done: %d/%d\n",
-		       cp->dev->name, ring,
-		       readl(cp->regs + REG_RX_COMP_HEAD),
-		       cp->rx_new[ring]);
+	netif_printk(cp, intr, KERN_DEBUG, cp->dev,
+		     "rx[%d] interrupt, done: %d/%d\n",
+		     ring,
+		     readl(cp->regs + REG_RX_COMP_HEAD), cp->rx_new[ring]);
 
 	entry = cp->rx_new[ring];
 	drops = 0;
@@ -2442,8 +2405,7 @@ static int cas_rx_ringN(struct cas *cp, int ring, int budget)
 	cp->rx_new[ring] = entry;
 
 	if (drops)
-		printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
-		       cp->dev->name);
+		netdev_info(cp->dev, "Memory squeeze, deferring packet\n");
 	return npackets;
 }
 
@@ -2457,10 +2419,9 @@ static void cas_post_rxcs_ringN(struct net_device *dev,
 
 	last = cp->rx_cur[ring];
 	entry = cp->rx_new[ring];
-	if (netif_msg_intr(cp))
-		printk(KERN_DEBUG "%s: rxc[%d] interrupt, done: %d/%d\n",
-		       dev->name, ring, readl(cp->regs + REG_RX_COMP_HEAD),
-		       entry);
+	netif_printk(cp, intr, KERN_DEBUG, dev,
+		     "rxc[%d] interrupt, done: %d/%d\n",
+		     ring, readl(cp->regs + REG_RX_COMP_HEAD), entry);
 
 	/* zero and re-mark descriptors */
 	while (last != entry) {
@@ -2729,42 +2690,38 @@ static void cas_tx_timeout(struct net_device *dev)
 {
 	struct cas *cp = netdev_priv(dev);
 
-	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
+	netdev_err(dev, "transmit timed out, resetting\n");
 	if (!cp->hw_running) {
-		printk("%s: hrm.. hw not running!\n", dev->name);
+		netdev_err(dev, "hrm.. hw not running!\n");
 		return;
 	}
 
-	printk(KERN_ERR "%s: MIF_STATE[%08x]\n",
-	       dev->name, readl(cp->regs + REG_MIF_STATE_MACHINE));
-
-	printk(KERN_ERR "%s: MAC_STATE[%08x]\n",
-	       dev->name, readl(cp->regs + REG_MAC_STATE_MACHINE));
-
-	printk(KERN_ERR "%s: TX_STATE[%08x:%08x:%08x] "
-	       "FIFO[%08x:%08x:%08x] SM1[%08x] SM2[%08x]\n",
-	       dev->name,
-	       readl(cp->regs + REG_TX_CFG),
-	       readl(cp->regs + REG_MAC_TX_STATUS),
-	       readl(cp->regs + REG_MAC_TX_CFG),
-	       readl(cp->regs + REG_TX_FIFO_PKT_CNT),
-	       readl(cp->regs + REG_TX_FIFO_WRITE_PTR),
-	       readl(cp->regs + REG_TX_FIFO_READ_PTR),
-	       readl(cp->regs + REG_TX_SM_1),
-	       readl(cp->regs + REG_TX_SM_2));
-
-	printk(KERN_ERR "%s: RX_STATE[%08x:%08x:%08x]\n",
-	       dev->name,
-	       readl(cp->regs + REG_RX_CFG),
-	       readl(cp->regs + REG_MAC_RX_STATUS),
-	       readl(cp->regs + REG_MAC_RX_CFG));
-
-	printk(KERN_ERR "%s: HP_STATE[%08x:%08x:%08x:%08x]\n",
-	       dev->name,
-	       readl(cp->regs + REG_HP_STATE_MACHINE),
-	       readl(cp->regs + REG_HP_STATUS0),
-	       readl(cp->regs + REG_HP_STATUS1),
-	       readl(cp->regs + REG_HP_STATUS2));
+	netdev_err(dev, "MIF_STATE[%08x]\n",
+		   readl(cp->regs + REG_MIF_STATE_MACHINE));
+
+	netdev_err(dev, "MAC_STATE[%08x]\n",
+		   readl(cp->regs + REG_MAC_STATE_MACHINE));
+
+	netdev_err(dev, "TX_STATE[%08x:%08x:%08x] FIFO[%08x:%08x:%08x] SM1[%08x] SM2[%08x]\n",
+		   readl(cp->regs + REG_TX_CFG),
+		   readl(cp->regs + REG_MAC_TX_STATUS),
+		   readl(cp->regs + REG_MAC_TX_CFG),
+		   readl(cp->regs + REG_TX_FIFO_PKT_CNT),
+		   readl(cp->regs + REG_TX_FIFO_WRITE_PTR),
+		   readl(cp->regs + REG_TX_FIFO_READ_PTR),
+		   readl(cp->regs + REG_TX_SM_1),
+		   readl(cp->regs + REG_TX_SM_2));
+
+	netdev_err(dev, "RX_STATE[%08x:%08x:%08x]\n",
+		   readl(cp->regs + REG_RX_CFG),
+		   readl(cp->regs + REG_MAC_RX_STATUS),
+		   readl(cp->regs + REG_MAC_RX_CFG));
+
+	netdev_err(dev, "HP_STATE[%08x:%08x:%08x:%08x]\n",
+		   readl(cp->regs + REG_HP_STATE_MACHINE),
+		   readl(cp->regs + REG_HP_STATUS0),
+		   readl(cp->regs + REG_HP_STATUS1),
+		   readl(cp->regs + REG_HP_STATUS2));
 
 #if 1
 	atomic_inc(&cp->reset_task_pending);
@@ -2830,8 +2787,7 @@ static inline int cas_xmit_tx_ringN(struct cas *cp, int ring,
 	    CAS_TABORT(cp)*(skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&cp->tx_lock[ring], flags);
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-		       "queue awake!\n", dev->name);
+		netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
 		return 1;
 	}
 
@@ -2908,11 +2864,9 @@ static inline int cas_xmit_tx_ringN(struct cas *cp, int ring,
 	if (TX_BUFFS_AVAIL(cp, ring) <= CAS_TABORT(cp)*(MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
-	if (netif_msg_tx_queued(cp))
-		printk(KERN_DEBUG "%s: tx[%d] queued, slot %d, skblen %d, "
-		       "avail %d\n",
-		       dev->name, ring, entry, skb->len,
-		       TX_BUFFS_AVAIL(cp, ring));
+	netif_printk(cp, tx_queued, KERN_DEBUG, dev,
+		     "tx[%d] queued, slot %d, skblen %d, avail %d\n",
+		     ring, entry, skb->len, TX_BUFFS_AVAIL(cp, ring));
 	writel(entry, cp->regs + REG_TX_KICKN(ring));
 	spin_unlock_irqrestore(&cp->tx_lock[ring], flags);
 	return 0;
@@ -3100,10 +3054,10 @@ static void cas_mac_reset(struct cas *cp)
 
 	if (readl(cp->regs + REG_MAC_TX_RESET) |
 	    readl(cp->regs + REG_MAC_RX_RESET))
-		printk(KERN_ERR "%s: mac tx[%d]/rx[%d] reset failed [%08x]\n",
-		       cp->dev->name, readl(cp->regs + REG_MAC_TX_RESET),
-		       readl(cp->regs + REG_MAC_RX_RESET),
-		       readl(cp->regs + REG_MAC_STATE_MACHINE));
+		netdev_err(cp->dev, "mac tx[%d]/rx[%d] reset failed [%08x]\n",
+			   readl(cp->regs + REG_MAC_TX_RESET),
+			   readl(cp->regs + REG_MAC_RX_RESET),
+			   readl(cp->regs + REG_MAC_STATE_MACHINE));
 }
 
 
@@ -3423,7 +3377,7 @@ use_random_mac_addr:
 		goto done;
 
 	/* Sun MAC prefix then 3 random bytes. */
-	printk(PFX "MAC address not found in ROM VPD\n");
+	pr_info("MAC address not found in ROM VPD\n");
 	dev_addr[0] = 0x08;
 	dev_addr[1] = 0x00;
 	dev_addr[2] = 0x20;
@@ -3484,7 +3438,7 @@ static int cas_check_invariants(struct cas *cp)
 			__free_pages(page, CAS_JUMBO_PAGE_SHIFT - PAGE_SHIFT);
 			cp->page_order = CAS_JUMBO_PAGE_SHIFT - PAGE_SHIFT;
 		} else {
-			printk(PFX "MTU limited to %d bytes\n", CAS_MAX_MTU);
+			printk("MTU limited to %d bytes\n", CAS_MAX_MTU);
 		}
 	}
 #endif
@@ -3529,7 +3483,7 @@ static int cas_check_invariants(struct cas *cp)
 			}
 		}
 	}
-	printk(KERN_ERR PFX "MII phy did not respond [%08x]\n",
+	pr_err("MII phy did not respond [%08x]\n",
 	       readl(cp->regs + REG_MIF_STATE_MACHINE));
 	return -1;
 
@@ -3574,21 +3528,19 @@ static inline void cas_start_dma(struct cas *cp)
 		val = readl(cp->regs + REG_MAC_RX_CFG);
 		if ((val & MAC_RX_CFG_EN)) {
 			if (txfailed) {
-			  printk(KERN_ERR
-				 "%s: enabling mac failed [tx:%08x:%08x].\n",
-				 cp->dev->name,
-				 readl(cp->regs + REG_MIF_STATE_MACHINE),
-				 readl(cp->regs + REG_MAC_STATE_MACHINE));
+				netdev_err(cp->dev,
+					   "enabling mac failed [tx:%08x:%08x]\n",
+					   readl(cp->regs + REG_MIF_STATE_MACHINE),
+					   readl(cp->regs + REG_MAC_STATE_MACHINE));
 			}
 			goto enable_rx_done;
 		}
 		udelay(10);
 	}
-	printk(KERN_ERR "%s: enabling mac failed [%s:%08x:%08x].\n",
-	       cp->dev->name,
-	       (txfailed? "tx,rx":"rx"),
-	       readl(cp->regs + REG_MIF_STATE_MACHINE),
-	       readl(cp->regs + REG_MAC_STATE_MACHINE));
+	netdev_err(cp->dev, "enabling mac failed [%s:%08x:%08x]\n",
+		   (txfailed ? "tx,rx" : "rx"),
+		   readl(cp->regs + REG_MIF_STATE_MACHINE),
+		   readl(cp->regs + REG_MAC_STATE_MACHINE));
 
 enable_rx_done:
 	cas_unmask_intr(cp); /* enable interrupts */
@@ -3690,9 +3642,8 @@ static void cas_set_link_modes(struct cas *cp)
 		}
 	}
 
-	if (netif_msg_link(cp))
-		printk(KERN_INFO "%s: Link up at %d Mbps, %s-duplex.\n",
-		       cp->dev->name, speed, (full_duplex ? "full" : "half"));
+	netif_info(cp, link, cp->dev, "Link up at %d Mbps, %s-duplex\n",
+		   speed, full_duplex ? "full" : "half");
 
 	val = MAC_XIF_TX_MII_OUTPUT_EN | MAC_XIF_LINK_LED;
 	if (CAS_PHY_MII(cp->phy_type)) {
@@ -3762,18 +3713,14 @@ static void cas_set_link_modes(struct cas *cp)
 
 	if (netif_msg_link(cp)) {
 		if (pause & 0x01) {
-			printk(KERN_INFO "%s: Pause is enabled "
-			       "(rxfifo: %d off: %d on: %d)\n",
-			       cp->dev->name,
-			       cp->rx_fifo_size,
-			       cp->rx_pause_off,
-			       cp->rx_pause_on);
+			netdev_info(cp->dev, "Pause is enabled (rxfifo: %d off: %d on: %d)\n",
+				    cp->rx_fifo_size,
+				    cp->rx_pause_off,
+				    cp->rx_pause_on);
 		} else if (pause & 0x10) {
-			printk(KERN_INFO "%s: TX pause enabled\n",
-			       cp->dev->name);
+			netdev_info(cp->dev, "TX pause enabled\n");
 		} else {
-			printk(KERN_INFO "%s: Pause is disabled\n",
-			       cp->dev->name);
+			netdev_info(cp->dev, "Pause is disabled\n");
 		}
 	}
 
@@ -3849,7 +3796,7 @@ static void cas_global_reset(struct cas *cp, int blkflag)
 			goto done;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s: sw reset failed.\n", cp->dev->name);
+	netdev_err(cp->dev, "sw reset failed\n");
 
 done:
 	/* enable various BIM interrupts */
@@ -3955,7 +3902,7 @@ static int cas_change_mtu(struct net_device *dev, int new_mtu)
 #else
 	atomic_set(&cp->reset_task_pending, (cp->phy_type & CAS_PHY_SERDES) ?
 		   CAS_RESET_ALL : CAS_RESET_MTU);
-	printk(KERN_ERR "reset called in cas_change_mtu\n");
+	pr_err("reset called in cas_change_mtu\n");
 	schedule_work(&cp->reset_task);
 #endif
 
@@ -4237,10 +4184,8 @@ static void cas_link_timer(unsigned long data)
 
 		if (((tlm == 0x5) || (tlm == 0x3)) &&
 		    (CAS_VAL(MAC_SM_ENCAP_SM, val) == 0)) {
-			if (netif_msg_tx_err(cp))
-				printk(KERN_DEBUG "%s: tx err: "
-				       "MAC_STATE[%08x]\n",
-				       cp->dev->name, val);
+			netif_printk(cp, tx_err, KERN_DEBUG, cp->dev,
+				     "tx err: MAC_STATE[%08x]\n", val);
 			reset = 1;
 			goto done;
 		}
@@ -4249,10 +4194,9 @@ static void cas_link_timer(unsigned long data)
 		wptr = readl(cp->regs + REG_TX_FIFO_WRITE_PTR);
 		rptr = readl(cp->regs + REG_TX_FIFO_READ_PTR);
 		if ((val == 0) && (wptr != rptr)) {
-			if (netif_msg_tx_err(cp))
-				printk(KERN_DEBUG "%s: tx err: "
-				       "TX_FIFO[%08x:%08x:%08x]\n",
-				       cp->dev->name, val, wptr, rptr);
+			netif_printk(cp, tx_err, KERN_DEBUG, cp->dev,
+				     "tx err: TX_FIFO[%08x:%08x:%08x]\n",
+				     val, wptr, rptr);
 			reset = 1;
 		}
 
@@ -4268,7 +4212,7 @@ done:
 		schedule_work(&cp->reset_task);
 #else
 		atomic_set(&cp->reset_task_pending, CAS_RESET_ALL);
-		printk(KERN_ERR "reset called in cas_link_timer\n");
+		pr_err("reset called in cas_link_timer\n");
 		schedule_work(&cp->reset_task);
 #endif
 	}
@@ -4361,8 +4305,7 @@ static int cas_open(struct net_device *dev)
 	 */
 	if (request_irq(cp->pdev->irq, cas_interrupt,
 			IRQF_SHARED, dev->name, (void *) dev)) {
-		printk(KERN_ERR "%s: failed to request irq !\n",
-		       cp->dev->name);
+		netdev_err(cp->dev, "failed to request irq !\n");
 		err = -EAGAIN;
 		goto err_spare;
 	}
@@ -5002,24 +4945,24 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 	u8 orig_cacheline_size = 0, cas_cacheline_size = 0;
 
 	if (cas_version_printed++ == 0)
-		printk(KERN_INFO "%s", version);
+		pr_info("%s", version);
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		dev_err(&pdev->dev, "Cannot enable PCI device, aborting.\n");
+		dev_err(&pdev->dev, "Cannot enable PCI device, aborting\n");
 		return err;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev, "Cannot find proper PCI device "
-		       "base address, aborting.\n");
+		       "base address, aborting\n");
 		err = -ENODEV;
 		goto err_out_disable_pdev;
 	}
 
 	dev = alloc_etherdev(sizeof(*cp));
 	if (!dev) {
-		dev_err(&pdev->dev, "Etherdev alloc failed, aborting.\n");
+		dev_err(&pdev->dev, "Etherdev alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto err_out_disable_pdev;
 	}
@@ -5027,7 +4970,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 
 	err = pci_request_regions(pdev, dev->name);
 	if (err) {
-		dev_err(&pdev->dev, "Cannot obtain PCI resources, aborting.\n");
+		dev_err(&pdev->dev, "Cannot obtain PCI resources, aborting\n");
 		goto err_out_free_netdev;
 	}
 	pci_set_master(pdev);
@@ -5041,8 +4984,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 	pci_cmd |= PCI_COMMAND_PARITY;
 	pci_write_config_word(pdev, PCI_COMMAND, pci_cmd);
 	if (pci_try_set_mwi(pdev))
-		printk(KERN_WARNING PFX "Could not enable MWI for %s\n",
-		       pci_name(pdev));
+		pr_warning("Could not enable MWI for %s\n", pci_name(pdev));
 
 	cas_program_bridge(pdev);
 
@@ -5085,7 +5027,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "No usable DMA configuration, "
-			       "aborting.\n");
+			       "aborting\n");
 			goto err_out_free_res;
 		}
 		pci_using_dac = 0;
@@ -5144,7 +5086,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 	/* give us access to cassini registers */
 	cp->regs = pci_iomap(pdev, 0, casreg_len);
 	if (!cp->regs) {
-		dev_err(&pdev->dev, "Cannot map device registers, aborting.\n");
+		dev_err(&pdev->dev, "Cannot map device registers, aborting\n");
 		goto err_out_free_res;
 	}
 	cp->casreg_len = casreg_len;
@@ -5163,7 +5105,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 		pci_alloc_consistent(pdev, sizeof(struct cas_init_block),
 				     &cp->block_dvma);
 	if (!cp->init_block) {
-		dev_err(&pdev->dev, "Cannot allocate init block, aborting.\n");
+		dev_err(&pdev->dev, "Cannot allocate init block, aborting\n");
 		goto err_out_iounmap;
 	}
 
@@ -5197,18 +5139,17 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 		dev->features |= NETIF_F_HIGHDMA;
 
 	if (register_netdev(dev)) {
-		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
+		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
 		goto err_out_free_consistent;
 	}
 
 	i = readl(cp->regs + REG_BIM_CFG);
-	printk(KERN_INFO "%s: Sun Cassini%s (%sbit/%sMHz PCI/%s) "
-	       "Ethernet[%d] %pM\n",  dev->name,
-	       (cp->cas_flags & CAS_FLAG_REG_PLUS) ? "+" : "",
-	       (i & BIM_CFG_32BIT) ? "32" : "64",
-	       (i & BIM_CFG_66MHZ) ? "66" : "33",
-	       (cp->phy_type == CAS_PHY_SERDES) ? "Fi" : "Cu", pdev->irq,
-	       dev->dev_addr);
+	netdev_info(dev, "Sun Cassini%s (%sbit/%sMHz PCI/%s) Ethernet[%d] %pM\n",
+		    (cp->cas_flags & CAS_FLAG_REG_PLUS) ? "+" : "",
+		    (i & BIM_CFG_32BIT) ? "32" : "64",
+		    (i & BIM_CFG_66MHZ) ? "66" : "33",
+		    (cp->phy_type == CAS_PHY_SERDES) ? "Fi" : "Cu", pdev->irq,
+		    dev->dev_addr);
 
 	pci_set_drvdata(pdev, dev);
 	cp->hw_running = 1;
@@ -5322,7 +5263,7 @@ static int cas_resume(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct cas *cp = netdev_priv(dev);
 
-	printk(KERN_INFO "%s: resuming\n", dev->name);
+	netdev_info(dev, "resuming\n");
 
 	mutex_lock(&cp->pm_mutex);
 	cas_hard_reset(cp);
-- 
1.7.0.14.g7e948
