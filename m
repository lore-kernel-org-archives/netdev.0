From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 02/15] drivers/net/8139too.c: Use (pr|netdev|netif)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:49 -0800
Message-ID: <53d659f9d133b14a6fcdcd7958a83f0e8bb15cf9.1266454576.git.joe@perches.com>
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
Convert formats like %8.8 to %08
Remove periods from formats
Coalesce long formats
Use print_hex_dump

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/8139too.c |  187 +++++++++++++++++++++----------------------------
 1 files changed, 81 insertions(+), 106 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index c7d6f09..b4efc91 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -89,6 +89,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"8139too"
 #define DRV_VERSION	"0.9.28"
 
@@ -111,7 +113,6 @@
 #include <asm/irq.h>
 
 #define RTL8139_DRIVER_NAME   DRV_NAME " Fast Ethernet driver " DRV_VERSION
-#define PFX DRV_NAME ": "
 
 /* Default Message level */
 #define RTL8139_DEF_MSG_ENABLE   (NETIF_MSG_DRV   | \
@@ -130,9 +131,9 @@
 #  define assert(expr) do {} while (0)
 #else
 #  define assert(expr) \
-        if(unlikely(!(expr))) {				        \
-        pr_err("Assertion failed! %s,%s,%s,line=%d\n",	\
-	#expr, __FILE__, __func__, __LINE__);			\
+        if (unlikely(!(expr))) {				\
+		pr_err("Assertion failed! %s,%s,%s,line=%d\n",	\
+		       #expr, __FILE__, __func__, __LINE__);	\
         }
 #endif
 
@@ -957,7 +958,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 &&
 	    pdev->subsystem_vendor == PCI_VENDOR_ID_ATHEROS &&
 	    pdev->subsystem_device == PCI_DEVICE_ID_REALTEK_8139) {
-		pr_info("8139too: OQO Model 2 detected. Forcing PIO\n");
+		pr_info("OQO Model 2 detected. Forcing PIO\n");
 		use_io = 1;
 	}
 
@@ -1010,21 +1011,19 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	tp->mii.reg_num_mask = 0x1f;
 
 	/* dev is fully set up and ready to use now */
-	pr_debug("about to register device named %s (%p)...\n", dev->name, dev);
+	pr_debug("about to register device named %s (%p)...\n",
+		 dev->name, dev);
 	i = register_netdev (dev);
 	if (i) goto err_out;
 
 	pci_set_drvdata (pdev, dev);
 
-	pr_info("%s: %s at 0x%lx, %pM, IRQ %d\n",
-		dev->name,
-		board_info[ent->driver_data].name,
-		dev->base_addr,
-		dev->dev_addr,
-		dev->irq);
+	netdev_info(dev, "%s at 0x%lx, %pM, IRQ %d\n",
+		    board_info[ent->driver_data].name,
+		    dev->base_addr, dev->dev_addr, dev->irq);
 
-	pr_debug("%s:  Identified 8139 chip type '%s'\n",
-		dev->name, rtl_chip_info[tp->chipset].name);
+	netdev_dbg(dev, "Identified 8139 chip type '%s'\n",
+		   rtl_chip_info[tp->chipset].name);
 
 	/* Find the connected MII xcvrs.
 	   Doing this in open() would allow detecting external xcvrs later, but
@@ -1037,13 +1036,12 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 			if (mii_status != 0xffff  &&  mii_status != 0x0000) {
 				u16 advertising = mdio_read(dev, phy, 4);
 				tp->phys[phy_idx++] = phy;
-				pr_info("%s: MII transceiver %d status 0x%4.4x advertising %4.4x.\n",
-					   dev->name, phy, mii_status, advertising);
+				netdev_info(dev, "MII transceiver %d status 0x%04x advertising %04x\n",
+					    phy, mii_status, advertising);
 			}
 		}
 		if (phy_idx == 0) {
-			pr_info("%s: No MII transceivers found! Assuming SYM transceiver.\n",
-				   dev->name);
+			netdev_info(dev, "No MII transceivers found! Assuming SYM transceiver\n");
 			tp->phys[0] = 32;
 		}
 	} else
@@ -1062,15 +1060,15 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	if (board_idx < MAX_UNITS  &&  full_duplex[board_idx] > 0)
 		tp->mii.full_duplex = full_duplex[board_idx];
 	if (tp->mii.full_duplex) {
-		pr_info("%s: Media type forced to Full Duplex.\n", dev->name);
+		netdev_info(dev, "Media type forced to Full Duplex\n");
 		/* Changing the MII-advertised media because might prevent
 		   re-connection. */
 		tp->mii.force_media = 1;
 	}
 	if (tp->default_port) {
-		pr_info("  Forcing %dMbps %s-duplex operation.\n",
-			   (option & 0x20 ? 100 : 10),
-			   (option & 0x10 ? "full" : "half"));
+		netdev_info(dev, "  Forcing %dMbps %s-duplex operation\n",
+			    (option & 0x20 ? 100 : 10),
+			    (option & 0x10 ? "full" : "half"));
 		mdio_write(dev, tp->phys[0], 0,
 				   ((option & 0x20) ? 0x2000 : 0) | 	/* 100Mbps? */
 				   ((option & 0x10) ? 0x0100 : 0)); /* Full duplex? */
@@ -1330,12 +1328,12 @@ static int rtl8139_open (struct net_device *dev)
 	rtl8139_hw_start (dev);
 	netif_start_queue (dev);
 
-	if (netif_msg_ifup(tp))
-		pr_debug("%s: rtl8139_open() ioaddr %#llx IRQ %d"
-			" GP Pins %2.2x %s-duplex.\n", dev->name,
-			(unsigned long long)pci_resource_start (tp->pci_dev, 1),
-			dev->irq, RTL_R8 (MediaStatus),
-			tp->mii.full_duplex ? "full" : "half");
+	netif_dbg(tp, ifup, dev,
+		  "%s() ioaddr %#llx IRQ %d GP Pins %02x %s-duplex\n",
+		  __func__,
+		  (unsigned long long)pci_resource_start (tp->pci_dev, 1),
+		  dev->irq, RTL_R8 (MediaStatus),
+		  tp->mii.full_duplex ? "full" : "half");
 
 	rtl8139_start_thread(tp);
 
@@ -1393,7 +1391,7 @@ static void rtl8139_hw_start (struct net_device *dev)
 		RTL_W8 (Config3, RTL_R8 (Config3) & ~Cfg3_Magic);
 	}
 
-	pr_debug("init buffer addresses\n");
+	netdev_dbg(dev, "init buffer addresses\n");
 
 	/* Lock Config[01234] and BMCR register writes */
 	RTL_W8 (Cfg9346, Cfg9346_Lock);
@@ -1555,14 +1553,11 @@ static inline void rtl8139_thread_iter (struct net_device *dev,
 			tp->mii.full_duplex = duplex;
 
 			if (mii_lpa) {
-				pr_info("%s: Setting %s-duplex based on MII #%d link"
-					" partner ability of %4.4x.\n",
-					dev->name,
-					tp->mii.full_duplex ? "full" : "half",
-					tp->phys[0], mii_lpa);
+				netdev_info(dev, "Setting %s-duplex based on MII #%d link partner ability of %04x\n",
+					    tp->mii.full_duplex ? "full" : "half",
+					    tp->phys[0], mii_lpa);
 			} else {
-				pr_info("%s: media is unconnected, link down, or incompatible connection\n",
-				       dev->name);
+				netdev_info(dev, "media is unconnected, link down, or incompatible connection\n");
 			}
 #if 0
 			RTL_W8 (Cfg9346, Cfg9346_Unlock);
@@ -1576,13 +1571,12 @@ static inline void rtl8139_thread_iter (struct net_device *dev,
 
 	rtl8139_tune_twister (dev, tp);
 
-	pr_debug("%s: Media selection tick, Link partner %4.4x.\n",
-		 dev->name, RTL_R16 (NWayLPAR));
-	pr_debug("%s:  Other registers are IntMask %4.4x IntStatus %4.4x\n",
-		 dev->name, RTL_R16 (IntrMask), RTL_R16 (IntrStatus));
-	pr_debug("%s:  Chip config %2.2x %2.2x.\n",
-		 dev->name, RTL_R8 (Config0),
-		 RTL_R8 (Config1));
+	netdev_dbg(dev, "Media selection tick, Link partner %04x\n",
+		   RTL_R16(NWayLPAR));
+	netdev_dbg(dev, "Other registers are IntMask %04x IntStatus %04x\n",
+		   RTL_R16(IntrMask), RTL_R16(IntrStatus));
+	netdev_dbg(dev, "Chip config %02x %02x\n",
+		   RTL_R8(Config0), RTL_R8(Config1));
 }
 
 static void rtl8139_thread (struct work_struct *work)
@@ -1640,17 +1634,17 @@ static void rtl8139_tx_timeout_task (struct work_struct *work)
 	int i;
 	u8 tmp8;
 
-	pr_debug("%s: Transmit timeout, status %2.2x %4.4x %4.4x media %2.2x.\n",
-		dev->name, RTL_R8 (ChipCmd),
-		RTL_R16(IntrStatus), RTL_R16(IntrMask), RTL_R8(MediaStatus));
+	netdev_dbg(dev, "Transmit timeout, status %02x %04x %04x media %02x\n",
+		   RTL_R8(ChipCmd), RTL_R16(IntrStatus),
+		   RTL_R16(IntrMask), RTL_R8(MediaStatus));
 	/* Emit info to figure out what went wrong. */
-	pr_debug("%s: Tx queue start entry %ld  dirty entry %ld.\n",
-		dev->name, tp->cur_tx, tp->dirty_tx);
+	netdev_dbg(dev, "Tx queue start entry %ld  dirty entry %ld\n",
+		   tp->cur_tx, tp->dirty_tx);
 	for (i = 0; i < NUM_TX_DESC; i++)
-		pr_debug("%s:  Tx descriptor %d is %8.8lx.%s\n",
-			dev->name, i, RTL_R32 (TxStatus0 + (i * 4)),
-			i == tp->dirty_tx % NUM_TX_DESC ?
-				" (queue head)" : "");
+		netdev_dbg(dev, "Tx descriptor %d is %08lx%s\n",
+			   i, RTL_R32(TxStatus0 + (i * 4)),
+			   i == tp->dirty_tx % NUM_TX_DESC ?
+			   " (queue head)" : "");
 
 	tp->xstats.tx_timeouts++;
 
@@ -1729,9 +1723,8 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 		netif_stop_queue (dev);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
-	if (netif_msg_tx_queued(tp))
-		pr_debug("%s: Queued Tx packet size %u to slot %d.\n",
-			dev->name, len, entry);
+	netif_dbg(tp, tx_queued, dev, "Queued Tx packet size %u to slot %d\n",
+		  len, entry);
 
 	return NETDEV_TX_OK;
 }
@@ -1760,9 +1753,8 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 		/* Note: TxCarrierLost is always asserted at 100mbps. */
 		if (txstatus & (TxOutOfWindow | TxAborted)) {
 			/* There was an major error, log it. */
-			if (netif_msg_tx_err(tp))
-				pr_debug("%s: Transmit error, Tx status %8.8x.\n",
-					dev->name, txstatus);
+			netif_dbg(tp, tx_err, dev, "Transmit error, Tx status %08x\n",
+				  txstatus);
 			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
 				dev->stats.tx_aborted_errors++;
@@ -1792,8 +1784,8 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 
 #ifndef RTL8139_NDEBUG
 	if (tp->cur_tx - dirty_tx > NUM_TX_DESC) {
-		pr_err("%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
-		        dev->name, dirty_tx, tp->cur_tx);
+		netdev_err(dev, "Out-of-sync dirty pointer, %ld vs. %ld\n",
+			   dirty_tx, tp->cur_tx);
 		dirty_tx += NUM_TX_DESC;
 	}
 #endif /* RTL8139_NDEBUG */
@@ -1816,14 +1808,13 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 	int tmp_work;
 #endif
 
-	if (netif_msg_rx_err (tp))
-		pr_debug("%s: Ethernet frame had errors, status %8.8x.\n",
-			dev->name, rx_status);
+	netif_dbg(tp, rx_err, dev, "Ethernet frame had errors, status %08x\n",
+		  rx_status);
 	dev->stats.rx_errors++;
 	if (!(rx_status & RxStatusOK)) {
 		if (rx_status & RxTooLong) {
-			pr_debug("%s: Oversized Ethernet frame, status %4.4x!\n",
-			 	dev->name, rx_status);
+			netdev_dbg(dev, "Oversized Ethernet frame, status %04x!\n",
+				   rx_status);
 			/* A.C.: The chip hangs here. */
 		}
 		if (rx_status & (RxBadSymbol | RxBadAlign))
@@ -1855,7 +1846,7 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 			break;
 	}
 	if (tmp_work <= 0)
-		pr_warning(PFX "rx stop wait too long\n");
+		netdev_warn(dev, "rx stop wait too long\n");
 	/* restart receive */
 	tmp_work = 200;
 	while (--tmp_work > 0) {
@@ -1866,7 +1857,7 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 			break;
 	}
 	if (tmp_work <= 0)
-		pr_warning(PFX "tx/rx enable wait too long\n");
+		netdev_warn(dev, "tx/rx enable wait too long\n");
 
 	/* and reinitialize all rx related registers */
 	RTL_W8_F (Cfg9346, Cfg9346_Unlock);
@@ -1877,7 +1868,7 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 	RTL_W32 (RxConfig, tp->rx_config);
 	tp->cur_rx = 0;
 
-	pr_debug("init buffer addresses\n");
+	netdev_dbg(dev, "init buffer addresses\n");
 
 	/* Lock Config[01234] and BMCR register writes */
 	RTL_W8 (Cfg9346, Cfg9346_Lock);
@@ -1931,10 +1922,9 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 	unsigned int cur_rx = tp->cur_rx;
 	unsigned int rx_size = 0;
 
-	pr_debug("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
-		 " free to %4.4x, Cmd %2.2x.\n", dev->name, (u16)cur_rx,
-		 RTL_R16 (RxBufAddr),
-		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
+	netdev_dbg(dev, "In %s(), current %04x BufAddr %04x, free to %04x, Cmd %02x\n",
+		   __func__, (u16)cur_rx,
+		   RTL_R16(RxBufAddr), RTL_R16(RxBufPtr), RTL_R8(ChipCmd));
 
 	while (netif_running(dev) && received < budget &&
 	       (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
@@ -1950,19 +1940,12 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		rx_size = rx_status >> 16;
 		pkt_size = rx_size - 4;
 
-		if (netif_msg_rx_status(tp))
-			pr_debug("%s:  rtl8139_rx() status %4.4x, size %4.4x,"
-				" cur %4.4x.\n", dev->name, rx_status,
-			 rx_size, cur_rx);
+		netif_dbg(tp, rx_status, dev, "%s() status %04x, size %04x, cur %04x\n",
+			  __func__, rx_status, rx_size, cur_rx);
 #if RTL8139_DEBUG > 2
-		{
-			int i;
-			pr_debug("%s: Frame contents ", dev->name);
-			for (i = 0; i < 70; i++)
-				pr_cont(" %2.2x",
-					rx_ring[ring_offset + i]);
-			pr_cont(".\n");
-		}
+		print_dump_hex(KERN_DEBUG, "Frame contents: ",
+			       DUMP_PREFIX_OFFSET, 16, 1,
+			       &rx_ring[ring_offset], 70, true);
 #endif
 
 		/* Packet copy from FIFO still in progress.
@@ -1973,14 +1956,11 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 			if (!tp->fifo_copy_timeout)
 				tp->fifo_copy_timeout = jiffies + 2;
 			else if (time_after(jiffies, tp->fifo_copy_timeout)) {
-				pr_debug("%s: hung FIFO. Reset.", dev->name);
+				netdev_dbg(dev, "hung FIFO. Reset\n");
 				rx_size = 0;
 				goto no_early_rx;
 			}
-			if (netif_msg_intr(tp)) {
-				pr_debug("%s: fifo copy in progress.",
-				       dev->name);
-			}
+			netif_dbg(tp, intr, dev, "fifo copy in progress\n");
 			tp->xstats.early_rx++;
 			break;
 		}
@@ -2021,8 +2001,7 @@ no_early_rx:
 			netif_receive_skb (skb);
 		} else {
 			if (net_ratelimit())
-				pr_warning("%s: Memory squeeze, dropping packet.\n",
-					dev->name);
+				netdev_warn(dev, "Memory squeeze, dropping packet\n");
 			dev->stats.rx_dropped++;
 		}
 		received++;
@@ -2036,10 +2015,9 @@ no_early_rx:
 	if (unlikely(!received || rx_size == 0xfff0))
 		rtl8139_isr_ack(tp);
 
-	pr_debug("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
-		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
-		 RTL_R16 (RxBufAddr),
-		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
+	netdev_dbg(dev, "Done %s(), current %04x BufAddr %04x, free to %04x, Cmd %02x\n",
+		   __func__, cur_rx,
+		   RTL_R16(RxBufAddr), RTL_R16(RxBufPtr), RTL_R8(ChipCmd));
 
 	tp->cur_rx = cur_rx;
 
@@ -2060,8 +2038,7 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 				     void __iomem *ioaddr,
 				     int status, int link_changed)
 {
-	pr_debug("%s: Abnormal interrupt, status %8.8x.\n",
-		 dev->name, status);
+	netdev_dbg(dev, "Abnormal interrupt, status %08x\n", status);
 
 	assert (dev != NULL);
 	assert (tp != NULL);
@@ -2089,8 +2066,7 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 		pci_read_config_word (tp->pci_dev, PCI_STATUS, &pci_cmd_status);
 		pci_write_config_word (tp->pci_dev, PCI_STATUS, pci_cmd_status);
 
-		pr_err("%s: PCI Bus error %4.4x.\n",
-			dev->name, pci_cmd_status);
+		netdev_err(dev, "PCI Bus error %04x\n", pci_cmd_status);
 	}
 }
 
@@ -2183,8 +2159,8 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
  out:
 	spin_unlock (&tp->lock);
 
-	pr_debug("%s: exiting interrupt, intr_status=%#4.4x.\n",
-		 dev->name, RTL_R16 (IntrStatus));
+	netdev_dbg(dev, "exiting interrupt, intr_status=%#4.4x\n",
+		   RTL_R16(IntrStatus));
 	return IRQ_RETVAL(handled);
 }
 
@@ -2233,9 +2209,8 @@ static int rtl8139_close (struct net_device *dev)
 	netif_stop_queue(dev);
 	napi_disable(&tp->napi);
 
-	if (netif_msg_ifdown(tp))
-		pr_debug("%s: Shutting down ethercard, status was 0x%4.4x.\n",
-			dev->name, RTL_R16 (IntrStatus));
+	netif_dbg(tp, ifdown, dev, "Shutting down ethercard, status was 0x%04x\n",
+		  RTL_R16(IntrStatus));
 
 	spin_lock_irqsave (&tp->lock, flags);
 
@@ -2512,8 +2487,8 @@ static void __set_rx_mode (struct net_device *dev)
 	int rx_mode;
 	u32 tmp;
 
-	pr_debug("%s:   rtl8139_set_rx_mode(%4.4x) done -- Rx config %8.8lx.\n",
-			dev->name, dev->flags, RTL_R32 (RxConfig));
+	netdev_dbg(dev, "rtl8139_set_rx_mode(%04x) done -- Rx config %08lx\n",
+		   dev->flags, RTL_R32(RxConfig));
 
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
-- 
1.7.0.14.g7e948
