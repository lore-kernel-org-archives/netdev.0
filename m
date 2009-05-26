From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 3/3] 8139*: convert printk() to pr_<foo>()
Date: Wed, 27 May 2009 02:35:27 +0400
Message-ID: <1243377327-8313-3-git-send-email-a.beregalov@gmail.com>
References: <1243377327-8313-1-git-send-email-a.beregalov@gmail.com>
 <1243377327-8313-2-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:13133 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756158AbZEZWft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 18:35:49 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1054420fga.17
        for <netdev@vger.kernel.org>; Tue, 26 May 2009 15:35:49 -0700 (PDT)
In-Reply-To: <1243377327-8313-2-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also convert DPRINTK to pr_debug and dev_printk to dev_<foo>.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/8139cp.c  |   32 ++++++-------
 drivers/net/8139too.c |  118 +++++++++++++++++++++----------------------------
 2 files changed, 66 insertions(+), 84 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 02330f3..c9fc0ff 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -471,8 +471,7 @@ static void cp_rx_err_acct (struct cp_private *cp, unsigned rx_tail,
 			    u32 status, u32 len)
 {
 	if (netif_msg_rx_err (cp))
-		printk (KERN_DEBUG
-			"%s: rx err, slot %d status 0x%x len %d\n",
+		pr_debug("%s: rx err, slot %d status 0x%x len %d\n",
 			cp->dev->name, rx_tail, status, len);
 	cp->dev->stats.rx_errors++;
 	if (status & RxErrFrame)
@@ -547,7 +546,7 @@ rx_status_loop:
 		}
 
 		if (netif_msg_rx_status(cp))
-			printk(KERN_DEBUG "%s: rx slot %d status 0x%x len %d\n",
+			pr_debug("%s: rx slot %d status 0x%x len %d\n",
 			       dev->name, rx_tail, status, len);
 
 		buflen = cp->rx_buf_sz + NET_IP_ALIGN;
@@ -626,7 +625,7 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 		return IRQ_NONE;
 
 	if (netif_msg_intr(cp))
-		printk(KERN_DEBUG "%s: intr, status %04x cmd %02x cpcmd %04x\n",
+		pr_debug("%s: intr, status %04x cmd %02x cpcmd %04x\n",
 		        dev->name, status, cpr8(Cmd), cpr16(CpCmd));
 
 	cpw16(IntrStatus, status & ~cp_rx_intr_mask);
@@ -658,7 +657,7 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 
 		pci_read_config_word(cp->pdev, PCI_STATUS, &pci_status);
 		pci_write_config_word(cp->pdev, PCI_STATUS, pci_status);
-		printk(KERN_ERR "%s: PCI bus error, status=%04x, PCI status=%04x\n",
+		pr_err("%s: PCI bus error, status=%04x, PCI status=%04x\n",
 		       dev->name, status, pci_status);
 
 		/* TODO: reset hardware */
@@ -705,7 +704,7 @@ static void cp_tx (struct cp_private *cp)
 		if (status & LastFrag) {
 			if (status & (TxError | TxFIFOUnder)) {
 				if (netif_msg_tx_err(cp))
-					printk(KERN_DEBUG "%s: tx err, status 0x%x\n",
+					pr_debug("%s: tx err, status 0x%x\n",
 					       cp->dev->name, status);
 				cp->dev->stats.tx_errors++;
 				if (status & TxOWC)
@@ -722,7 +721,7 @@ static void cp_tx (struct cp_private *cp)
 				cp->dev->stats.tx_packets++;
 				cp->dev->stats.tx_bytes += skb->len;
 				if (netif_msg_tx_done(cp))
-					printk(KERN_DEBUG "%s: tx done, slot %d\n", cp->dev->name, tx_tail);
+					pr_debug("%s: tx done, slot %d\n", cp->dev->name, tx_tail);
 			}
 			dev_kfree_skb_irq(skb);
 		}
@@ -755,7 +754,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	if (TX_BUFFS_AVAIL(cp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&cp->lock, intr_flags);
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
+		pr_err(PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return 1;
 	}
@@ -882,7 +881,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	}
 	cp->tx_head = entry;
 	if (netif_msg_tx_queued(cp))
-		printk(KERN_DEBUG "%s: tx queued, slot %d, skblen %d\n",
+		pr_debug("%s: tx queued, slot %d, skblen %d\n",
 		       dev->name, entry, skb->len);
 	if (TX_BUFFS_AVAIL(cp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
@@ -996,7 +995,7 @@ static void cp_reset_hw (struct cp_private *cp)
 		schedule_timeout_uninterruptible(10);
 	}
 
-	printk(KERN_ERR "%s: hardware reset timeout\n", cp->dev->name);
+	pr_err("%s: hardware reset timeout\n", cp->dev->name);
 }
 
 static inline void cp_start_hw (struct cp_private *cp)
@@ -1166,7 +1165,7 @@ static int cp_open (struct net_device *dev)
 	int rc;
 
 	if (netif_msg_ifup(cp))
-		printk(KERN_DEBUG "%s: enabling interface\n", dev->name);
+		pr_debug("%s: enabling interface\n", dev->name);
 
 	rc = cp_alloc_rings(cp);
 	if (rc)
@@ -1201,7 +1200,7 @@ static int cp_close (struct net_device *dev)
 	napi_disable(&cp->napi);
 
 	if (netif_msg_ifdown(cp))
-		printk(KERN_DEBUG "%s: disabling interface\n", dev->name);
+		pr_debug("%s: disabling interface\n", dev->name);
 
 	spin_lock_irqsave(&cp->lock, flags);
 
@@ -1224,7 +1223,7 @@ static void cp_tx_timeout(struct net_device *dev)
 	unsigned long flags;
 	int rc;
 
-	printk(KERN_WARNING "%s: Transmit timeout, status %2x %4x %4x %4x\n",
+	pr_warning("%s: Transmit timeout, status %2x %4x %4x %4x\n",
 	       dev->name, cpr8(Cmd), cpr16(CpCmd),
 	       cpr16(IntrStatus), cpr16(IntrMask));
 
@@ -1873,7 +1872,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifndef MODULE
 	static int version_printed;
 	if (version_printed++ == 0)
-		printk("%s", version);
+		pr_info("%s", version);
 #endif
 
 	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
@@ -1995,8 +1994,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto err_out_iomap;
 
-	printk (KERN_INFO "%s: RTL-8139C+ at 0x%lx, "
-		"%pM, IRQ %d\n",
+	pr_info("%s: RTL-8139C+ at 0x%lx, %pM, IRQ %d\n",
 		dev->name,
 		dev->base_addr,
 		dev->dev_addr,
@@ -2113,7 +2111,7 @@ static struct pci_driver cp_driver = {
 static int __init cp_init (void)
 {
 #ifdef MODULE
-	printk("%s", version);
+	pr_info("%s", version);
 #endif
 	return pci_register_driver(&cp_driver);
 }
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index d901775..8ae72ec 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -126,19 +126,12 @@
 #undef RTL8139_NDEBUG
 
 
-#if RTL8139_DEBUG
-/* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
-#else
-#  define DPRINTK(fmt, args...)
-#endif
-
 #ifdef RTL8139_NDEBUG
 #  define assert(expr) do {} while (0)
 #else
 #  define assert(expr) \
         if(unlikely(!(expr))) {				        \
-        printk(KERN_ERR "Assertion failed! %s,%s,%s,line=%d\n",	\
+        pr_err("Assertion failed! %s,%s,%s,line=%d\n",	\
 	#expr, __FILE__, __func__, __LINE__);			\
         }
 #endif
@@ -784,8 +777,8 @@ static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
 
 	/* set this immediately, we need to know before
 	 * we talk to the chip directly */
-	DPRINTK("PIO region size == 0x%02X\n", pio_len);
-	DPRINTK("MMIO region size == 0x%02lX\n", mmio_len);
+	pr_debug("PIO region size == 0x%02lX\n", pio_len);
+	pr_debug("MMIO region size == 0x%02lX\n", mmio_len);
 
 retry:
 	if (use_io) {
@@ -865,19 +858,17 @@ retry:
 		}
 
 	/* if unknown chip, assume array element #0, original RTL-8139 in this case */
-	dev_printk (KERN_DEBUG, &pdev->dev,
-		    "unknown chip version, assuming RTL-8139\n");
-	dev_printk (KERN_DEBUG, &pdev->dev,
-		    "TxConfig = 0x%lx\n", RTL_R32 (TxConfig));
+	dev_dbg(&pdev->dev, "unknown chip version, assuming RTL-8139\n");
+	dev_dbg(&pdev->dev, "TxConfig = 0x%lx\n", RTL_R32 (TxConfig));
 	tp->chipset = 0;
 
 match:
-	DPRINTK ("chipset id (%d) == index %d, '%s'\n",
+	pr_debug("chipset id (%d) == index %d, '%s'\n",
 		 version, i, rtl_chip_info[i].name);
 
 	if (tp->chipset >= CH_8139B) {
 		u8 new_tmp8 = tmp8 = RTL_R8 (Config1);
-		DPRINTK("PCI PM wakeup\n");
+		pr_debug("PCI PM wakeup\n");
 		if ((rtl_chip_info[tp->chipset].flags & HasLWake) &&
 		    (tmp8 & LWAKE))
 			new_tmp8 &= ~LWAKE;
@@ -896,7 +887,7 @@ match:
 			}
 		}
 	} else {
-		DPRINTK("Old chip wakeup\n");
+		pr_debug("Old chip wakeup\n");
 		tmp8 = RTL_R8 (Config1);
 		tmp8 &= ~(SLEEP | PWRDN);
 		RTL_W8 (Config1, tmp8);
@@ -949,7 +940,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	{
 		static int printed_version;
 		if (!printed_version++)
-			printk (KERN_INFO RTL8139_DRIVER_NAME "\n");
+			pr_info(RTL8139_DRIVER_NAME "\n");
 	}
 #endif
 
@@ -965,7 +956,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 &&
 	    pdev->subsystem_vendor == PCI_VENDOR_ID_ATHEROS &&
 	    pdev->subsystem_device == PCI_DEVICE_ID_REALTEK_8139) {
-		printk(KERN_INFO "8139too: OQO Model 2 detected. Forcing PIO\n");
+		pr_info("8139too: OQO Model 2 detected. Forcing PIO\n");
 		use_io = 1;
 	}
 
@@ -1018,21 +1009,20 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	tp->mii.reg_num_mask = 0x1f;
 
 	/* dev is fully set up and ready to use now */
-	DPRINTK("about to register device named %s (%p)...\n", dev->name, dev);
+	pr_debug("about to register device named %s (%p)...\n", dev->name, dev);
 	i = register_netdev (dev);
 	if (i) goto err_out;
 
 	pci_set_drvdata (pdev, dev);
 
-	printk (KERN_INFO "%s: %s at 0x%lx, "
-		"%pM, IRQ %d\n",
+	pr_info("%s: %s at 0x%lx, %pM, IRQ %d\n",
 		dev->name,
 		board_info[ent->driver_data].name,
 		dev->base_addr,
 		dev->dev_addr,
 		dev->irq);
 
-	printk (KERN_DEBUG "%s:  Identified 8139 chip type '%s'\n",
+	pr_debug("%s:  Identified 8139 chip type '%s'\n",
 		dev->name, rtl_chip_info[tp->chipset].name);
 
 	/* Find the connected MII xcvrs.
@@ -1046,14 +1036,12 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 			if (mii_status != 0xffff  &&  mii_status != 0x0000) {
 				u16 advertising = mdio_read(dev, phy, 4);
 				tp->phys[phy_idx++] = phy;
-				printk(KERN_INFO "%s: MII transceiver %d status 0x%4.4x "
-					   "advertising %4.4x.\n",
+				pr_info("%s: MII transceiver %d status 0x%4.4x advertising %4.4x.\n",
 					   dev->name, phy, mii_status, advertising);
 			}
 		}
 		if (phy_idx == 0) {
-			printk(KERN_INFO "%s: No MII transceivers found!  Assuming SYM "
-				   "transceiver.\n",
+			pr_info("%s: No MII transceivers found! Assuming SYM transceiver.\n",
 				   dev->name);
 			tp->phys[0] = 32;
 		}
@@ -1073,13 +1061,13 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	if (board_idx < MAX_UNITS  &&  full_duplex[board_idx] > 0)
 		tp->mii.full_duplex = full_duplex[board_idx];
 	if (tp->mii.full_duplex) {
-		printk(KERN_INFO "%s: Media type forced to Full Duplex.\n", dev->name);
+		pr_info("%s: Media type forced to Full Duplex.\n", dev->name);
 		/* Changing the MII-advertised media because might prevent
 		   re-connection. */
 		tp->mii.force_media = 1;
 	}
 	if (tp->default_port) {
-		printk(KERN_INFO "  Forcing %dMbps %s-duplex operation.\n",
+		pr_info("  Forcing %dMbps %s-duplex operation.\n",
 			   (option & 0x20 ? 100 : 10),
 			   (option & 0x10 ? "full" : "half"));
 		mdio_write(dev, tp->phys[0], 0,
@@ -1342,7 +1330,7 @@ static int rtl8139_open (struct net_device *dev)
 	netif_start_queue (dev);
 
 	if (netif_msg_ifup(tp))
-		printk(KERN_DEBUG "%s: rtl8139_open() ioaddr %#llx IRQ %d"
+		pr_debug("%s: rtl8139_open() ioaddr %#llx IRQ %d"
 			" GP Pins %2.2x %s-duplex.\n", dev->name,
 			(unsigned long long)pci_resource_start (tp->pci_dev, 1),
 			dev->irq, RTL_R8 (MediaStatus),
@@ -1404,7 +1392,7 @@ static void rtl8139_hw_start (struct net_device *dev)
 		RTL_W8 (Config3, RTL_R8 (Config3) & ~Cfg3_Magic);
 	}
 
-	DPRINTK("init buffer addresses\n");
+	pr_debug("init buffer addresses\n");
 
 	/* Lock Config[01234] and BMCR register writes */
 	RTL_W8 (Cfg9346, Cfg9346_Lock);
@@ -1566,14 +1554,13 @@ static inline void rtl8139_thread_iter (struct net_device *dev,
 			tp->mii.full_duplex = duplex;
 
 			if (mii_lpa) {
-				printk (KERN_INFO
-					"%s: Setting %s-duplex based on MII #%d link"
+				pr_info("%s: Setting %s-duplex based on MII #%d link"
 					" partner ability of %4.4x.\n",
 					dev->name,
 					tp->mii.full_duplex ? "full" : "half",
 					tp->phys[0], mii_lpa);
 			} else {
-				printk(KERN_INFO"%s: media is unconnected, link down, or incompatible connection\n",
+				pr_info("%s: media is unconnected, link down, or incompatible connection\n",
 				       dev->name);
 			}
 #if 0
@@ -1588,11 +1575,11 @@ static inline void rtl8139_thread_iter (struct net_device *dev,
 
 	rtl8139_tune_twister (dev, tp);
 
-	DPRINTK ("%s: Media selection tick, Link partner %4.4x.\n",
+	pr_debug("%s: Media selection tick, Link partner %4.4x.\n",
 		 dev->name, RTL_R16 (NWayLPAR));
-	DPRINTK ("%s:  Other registers are IntMask %4.4x IntStatus %4.4x\n",
+	pr_debug("%s:  Other registers are IntMask %4.4x IntStatus %4.4x\n",
 		 dev->name, RTL_R16 (IntrMask), RTL_R16 (IntrStatus));
-	DPRINTK ("%s:  Chip config %2.2x %2.2x.\n",
+	pr_debug("%s:  Chip config %2.2x %2.2x.\n",
 		 dev->name, RTL_R8 (Config0),
 		 RTL_R8 (Config1));
 }
@@ -1652,14 +1639,14 @@ static void rtl8139_tx_timeout_task (struct work_struct *work)
 	int i;
 	u8 tmp8;
 
-	printk (KERN_DEBUG "%s: Transmit timeout, status %2.2x %4.4x %4.4x "
-		"media %2.2x.\n", dev->name, RTL_R8 (ChipCmd),
+	pr_debug("%s: Transmit timeout, status %2.2x %4.4x %4.4x media %2.2x.\n",
+		dev->name, RTL_R8 (ChipCmd),
 		RTL_R16(IntrStatus), RTL_R16(IntrMask), RTL_R8(MediaStatus));
 	/* Emit info to figure out what went wrong. */
-	printk (KERN_DEBUG "%s: Tx queue start entry %ld  dirty entry %ld.\n",
+	pr_debug("%s: Tx queue start entry %ld  dirty entry %ld.\n",
 		dev->name, tp->cur_tx, tp->dirty_tx);
 	for (i = 0; i < NUM_TX_DESC; i++)
-		printk (KERN_DEBUG "%s:  Tx descriptor %d is %8.8lx.%s\n",
+		pr_debug("%s:  Tx descriptor %d is %8.8lx.%s\n",
 			dev->name, i, RTL_R32 (TxStatus0 + (i * 4)),
 			i == tp->dirty_tx % NUM_TX_DESC ?
 				" (queue head)" : "");
@@ -1741,7 +1728,7 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	if (netif_msg_tx_queued(tp))
-		printk (KERN_DEBUG "%s: Queued Tx packet size %u to slot %d.\n",
+		pr_debug("%s: Queued Tx packet size %u to slot %d.\n",
 			dev->name, len, entry);
 
 	return 0;
@@ -1772,7 +1759,7 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 		if (txstatus & (TxOutOfWindow | TxAborted)) {
 			/* There was an major error, log it. */
 			if (netif_msg_tx_err(tp))
-				printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
+				pr_debug("%s: Transmit error, Tx status %8.8x.\n",
 					dev->name, txstatus);
 			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
@@ -1803,7 +1790,7 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 
 #ifndef RTL8139_NDEBUG
 	if (tp->cur_tx - dirty_tx > NUM_TX_DESC) {
-		printk (KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
+		pr_err("%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
 		        dev->name, dirty_tx, tp->cur_tx);
 		dirty_tx += NUM_TX_DESC;
 	}
@@ -1828,12 +1815,12 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 #endif
 
 	if (netif_msg_rx_err (tp))
-		printk(KERN_DEBUG "%s: Ethernet frame had errors, status %8.8x.\n",
+		pr_debug("%s: Ethernet frame had errors, status %8.8x.\n",
 			dev->name, rx_status);
 	dev->stats.rx_errors++;
 	if (!(rx_status & RxStatusOK)) {
 		if (rx_status & RxTooLong) {
-			DPRINTK ("%s: Oversized Ethernet frame, status %4.4x!\n",
+			pr_debug("%s: Oversized Ethernet frame, status %4.4x!\n",
 			 	dev->name, rx_status);
 			/* A.C.: The chip hangs here. */
 		}
@@ -1866,7 +1853,7 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 			break;
 	}
 	if (tmp_work <= 0)
-		printk (KERN_WARNING PFX "rx stop wait too long\n");
+		pr_warning(PFX "rx stop wait too long\n");
 	/* restart receive */
 	tmp_work = 200;
 	while (--tmp_work > 0) {
@@ -1877,7 +1864,7 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 			break;
 	}
 	if (tmp_work <= 0)
-		printk (KERN_WARNING PFX "tx/rx enable wait too long\n");
+		pr_warning(PFX "tx/rx enable wait too long\n");
 
 	/* and reinitialize all rx related registers */
 	RTL_W8_F (Cfg9346, Cfg9346_Unlock);
@@ -1888,7 +1875,7 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 	RTL_W32 (RxConfig, tp->rx_config);
 	tp->cur_rx = 0;
 
-	DPRINTK("init buffer addresses\n");
+	pr_debug("init buffer addresses\n");
 
 	/* Lock Config[01234] and BMCR register writes */
 	RTL_W8 (Cfg9346, Cfg9346_Lock);
@@ -1942,7 +1929,7 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 	unsigned int cur_rx = tp->cur_rx;
 	unsigned int rx_size = 0;
 
-	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
+	pr_debug("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, (u16)cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
@@ -1962,17 +1949,17 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		pkt_size = rx_size - 4;
 
 		if (netif_msg_rx_status(tp))
-			printk(KERN_DEBUG "%s:  rtl8139_rx() status %4.4x, size %4.4x,"
+			pr_debug("%s:  rtl8139_rx() status %4.4x, size %4.4x,"
 				" cur %4.4x.\n", dev->name, rx_status,
 			 rx_size, cur_rx);
 #if RTL8139_DEBUG > 2
 		{
 			int i;
-			DPRINTK ("%s: Frame contents ", dev->name);
+			pr_debug("%s: Frame contents ", dev->name);
 			for (i = 0; i < 70; i++)
-				printk (" %2.2x",
+				pr_cont(" %2.2x",
 					rx_ring[ring_offset + i]);
-			printk (".\n");
+			pr_cont(".\n");
 		}
 #endif
 
@@ -1984,12 +1971,12 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 			if (!tp->fifo_copy_timeout)
 				tp->fifo_copy_timeout = jiffies + 2;
 			else if (time_after(jiffies, tp->fifo_copy_timeout)) {
-				DPRINTK ("%s: hung FIFO. Reset.", dev->name);
+				pr_debug("%s: hung FIFO. Reset.", dev->name);
 				rx_size = 0;
 				goto no_early_rx;
 			}
 			if (netif_msg_intr(tp)) {
-				printk(KERN_DEBUG "%s: fifo copy in progress.",
+				pr_debug("%s: fifo copy in progress.",
 				       dev->name);
 			}
 			tp->xstats.early_rx++;
@@ -2033,8 +2020,7 @@ no_early_rx:
 			netif_receive_skb (skb);
 		} else {
 			if (net_ratelimit())
-				printk (KERN_WARNING
-					"%s: Memory squeeze, dropping packet.\n",
+				pr_warning("%s: Memory squeeze, dropping packet.\n",
 					dev->name);
 			dev->stats.rx_dropped++;
 		}
@@ -2049,12 +2035,10 @@ no_early_rx:
 	if (unlikely(!received || rx_size == 0xfff0))
 		rtl8139_isr_ack(tp);
 
-#if RTL8139_DEBUG > 1
-	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
+	pr_debug("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
-#endif
 
 	tp->cur_rx = cur_rx;
 
@@ -2075,7 +2059,7 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 				     void __iomem *ioaddr,
 				     int status, int link_changed)
 {
-	DPRINTK ("%s: Abnormal interrupt, status %8.8x.\n",
+	pr_debug("%s: Abnormal interrupt, status %8.8x.\n",
 		 dev->name, status);
 
 	assert (dev != NULL);
@@ -2104,7 +2088,7 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 		pci_read_config_word (tp->pci_dev, PCI_STATUS, &pci_cmd_status);
 		pci_write_config_word (tp->pci_dev, PCI_STATUS, pci_cmd_status);
 
-		printk (KERN_ERR "%s: PCI Bus error %4.4x.\n",
+		pr_err("%s: PCI Bus error %4.4x.\n",
 			dev->name, pci_cmd_status);
 	}
 }
@@ -2198,7 +2182,7 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
  out:
 	spin_unlock (&tp->lock);
 
-	DPRINTK ("%s: exiting interrupt, intr_status=%#4.4x.\n",
+	pr_debug("%s: exiting interrupt, intr_status=%#4.4x.\n",
 		 dev->name, RTL_R16 (IntrStatus));
 	return IRQ_RETVAL(handled);
 }
@@ -2249,7 +2233,7 @@ static int rtl8139_close (struct net_device *dev)
 	napi_disable(&tp->napi);
 
 	if (netif_msg_ifdown(tp))
-		printk(KERN_DEBUG "%s: Shutting down ethercard, status was 0x%4.4x.\n",
+		pr_debug("%s: Shutting down ethercard, status was 0x%4.4x.\n",
 			dev->name, RTL_R16 (IntrStatus));
 
 	spin_lock_irqsave (&tp->lock, flags);
@@ -2527,7 +2511,7 @@ static void __set_rx_mode (struct net_device *dev)
 	int i, rx_mode;
 	u32 tmp;
 
-	DPRINTK ("%s:   rtl8139_set_rx_mode(%4.4x) done -- Rx config %8.8lx.\n",
+	pr_debug("%s:   rtl8139_set_rx_mode(%4.4x) done -- Rx config %8.8lx.\n",
 			dev->name, dev->flags, RTL_R32 (RxConfig));
 
 	/* Note: do not reorder, GCC is clever about common statements. */
@@ -2643,7 +2627,7 @@ static int __init rtl8139_init_module (void)
 	 * even if no 8139 board is found.
 	 */
 #ifdef MODULE
-	printk (KERN_INFO RTL8139_DRIVER_NAME "\n");
+	pr_info(RTL8139_DRIVER_NAME "\n");
 #endif
 
 	return pci_register_driver(&rtl8139_pci_driver);
-- 
1.6.3.1

