From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [11/22] Cyclades PC300 driver: improve printk()s for debugging and portability
Date: Sun, 29 Jan 2012 18:52:18 -0800
Message-ID: <20120130025218.GL10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the field widths in the debug printk()s for 64-bit kernels, adds
KERN_DEBUG, etc. where appropriate and adds some new debug printk()s with
controlling #ifdefs that I found useful while working on this.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index 134227a..f00db39 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -364,6 +364,13 @@ typedef struct pc300dev {
 
 	void *private;
 	struct sk_buff *tx_skb;
+
+	enum {
+	  CPC_DMA_FULL,
+	  CPC_DMA_ERROR,
+	  TRANSMISSION_ACTIVE,
+	  CHANNEL_CLOSED
+	} reason_stopped;
 #ifdef CONFIG_PC300_MLPPP
 	void *cpc_tty;	/* information to PC300 TTY driver */
 #endif
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 1a57eff..36cf3b0 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -258,6 +258,7 @@ static char rcsid[] =
 #undef	PC300_DEBUG_TX
 #undef	PC300_DEBUG_RX
 #undef	PC300_DEBUG_OTHER
+#undef  PC300_DEBUG_QUEUE
 
 static DEFINE_PCI_DEVICE_TABLE(cpc_pci_dev_id) = {
 	/* PC300/RSV or PC300/X21, 2 chan */
@@ -458,9 +459,9 @@ static void tx_dma_buf_check(pc300_t * card, int ch)
 	u16 first_bd = card->chan[ch].tx_first_bd;
 	u16 next_bd = card->chan[ch].tx_next_bd;
 
-	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
-	       first_bd, TX_BD_ADDR(ch, first_bd),
-	       next_bd, TX_BD_ADDR(ch, next_bd));
+	printk(KERN_DEBUG "#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
+	       first_bd, (u32)TX_BD_ADDR(ch, first_bd),
+	       next_bd, (u32)TX_BD_ADDR(ch, next_bd));
 	for (i = first_bd,
 	     ptdescr = (pcsca_bd_t *) (card->hw.rambase + TX_BD_ADDR(ch, first_bd));
 	     i != ((next_bd + 1) & (N_DMA_TX_BUF - 1));
@@ -484,19 +485,35 @@ static void tx1_dma_buf_check(pc300_t * card, int ch)
 	u16 next_bd = card->chan[ch].tx_next_bd;
 	uintptr_t scabase = card->hw.scabase;
 
-	printk ("\nnfree_tx_bd = %d \n", card->chan[ch].nfree_tx_bd);
+	printk(KERN_DEBUG "\nnfree_tx_bd = %d\n", card->chan[ch].nfree_tx_bd);
 	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
 	       first_bd, (u32)TX_BD_ADDR(ch, first_bd),
 	       next_bd, (u32)TX_BD_ADDR(ch, next_bd));
 	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
 	       (u32)(cpc_readl(scabase + DTX_REG(CDAL, ch))),
 	       (u32)(cpc_readl(scabase + DTX_REG(EDAL, ch))));
+	printk(KERN_DEBUG "TX_CDA(BH/B/H/L) = %02x %02x %02x %02x\n",
+	       (u8) cpc_readb(scabase + DTX_REG(CDABH, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(CDAB, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(CDAH, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(CDAL, ch)));
+	printk(KERN_DEBUG "TX_EDA(BH/B/H/L) = %02x %02x %02x %02x\n",
+	       (u8) cpc_readb(scabase + DTX_REG(EDABH, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(EDAB, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(EDAH, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(EDAL, ch)));
 	for (i = 0; i < N_DMA_TX_BUF; i++) {
 		ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i));
 		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
 		       ch, i, (u32) cpc_readl(&ptdescr->next),
 		       (u32) cpc_readl(&ptdescr->ptbuf),
 		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
+		printk("\n CH%d TX%d: next=0x%02x%02x%02x%02x (endianess-correct)",
+		       ch, i,
+		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x3),
+		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x2),
+		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x1),
+		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x0));
 	}
 	printk("\n");
 }
@@ -516,7 +533,7 @@ static void rx_dma_buf_check(pc300_t * card, int ch)
 					      DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 	     i < N_DMA_RX_BUF; i++, ptdescr++) {
 		if (cpc_readb(&ptdescr->status) & DST_OSB)
-			printk("\n CH%d RX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+			printk(KERN_DEBUG "\n CH%d RX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
 				ch, i, (u32) cpc_readl(&ptdescr->next),
 				(u32) cpc_readl(&ptdescr->ptbuf),
 				cpc_readb(&ptdescr->status),
@@ -1868,6 +1885,10 @@ static void cpc_tx_timeout(struct net_device *dev)
 	unsigned long flags;
 	u8 ilar;
 
+#ifdef PC300_DEBUG_OTHER
+	printk(KERN_DEBUG "cpc_tx_timeout()\n");
+	cpc_sca_status(card, ch);
+#endif
 	stats->tx_errors++;
 	stats->tx_aborted_errors++;
 	CPC_LOCK(card, flags);
@@ -1883,6 +1904,10 @@ static void cpc_tx_timeout(struct net_device *dev)
 	}
 	dev->trans_start = jiffies;
 	CPC_UNLOCK(card, flags);
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG "%s: waking queue, finished cpc_tx_timeout()\n",
+	       dev->name);
+#endif
 	netif_wake_queue(dev);
 }
 
@@ -1898,20 +1923,36 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i;
 #endif
 
+#ifdef PC300_DEBUG_TX
+	printk(KERN_DEBUG "%s: cpc_queue_xmit called wih %d bytes\n",
+	       dev->name, skb->len);
+#endif
 	if (chan->conf.monitor) {
 		/* In monitor mode no Tx is done: ignore packet */
 		dev_kfree_skb(skb);
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG "%s: dropping TX packet because in monitor mode\n",
+		       dev->name);
+#endif
 		return 0;
 	} else if (!netif_carrier_ok(dev)) {
 		/* DCD must be OFF: drop packet */
 		dev_kfree_skb(skb);
 		stats->tx_errors++;
 		stats->tx_carrier_errors++;
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG "%s: TX carrier error; dropping silently\n",
+		       dev->name);
+#endif
 		return 0;
 	} else if (cpc_readb(card->hw.scabase + M_REG(ST3, ch)) & ST3_DCD) {
 		printk("%s: DCD is OFF. Going administrative down.\n", dev->name);
 		stats->tx_errors++;
 		stats->tx_carrier_errors++;
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG "%s: TX carrier error; dropping silently\n",
+		       dev->name);
+#endif
 		dev_kfree_skb(skb);
 		netif_carrier_off(dev);
 		CPC_LOCK(card, flags);
@@ -1922,13 +1963,23 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 				   			~(CPLD_REG2_FALC_LED1 << (2 * ch)));
 		}
 		CPC_UNLOCK(card, flags);
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG "%s: waking queue after TX carrier error\n",
+		       dev->name);
+#endif
 		netif_wake_queue(dev);
 		return 0;
 	}
 
 	/* Write buffer to DMA buffers */
 	if (dma_buf_write(card, ch, (u8 *) skb->data, skb->len) != 0) {
-		printk("%s: write error. Dropping TX packet.\n", dev->name);
+		printk(KERN_ERR "%s: write error. Dropping TX packet.\n",
+		       dev->name);
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG "%s: stopping queue due to DMA error\n",
+		       dev->name);
+#endif
+		d->reason_stopped = CPC_DMA_ERROR;
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
 		stats->tx_errors++;
@@ -1951,6 +2002,10 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	CPC_LOCK(card, flags);
 	/* verify if it has more than one free descriptor */
 	if (card->chan[ch].nfree_tx_bd <= 1) {
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG "%s: stopping queue for transmission\n",
+			dev->name);
+#endif
 		/* don't have so stop the queue */
 		netif_stop_queue(dev);
 	}
@@ -1966,6 +2021,11 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	CPC_UNLOCK(card, flags);
 	dev_kfree_skb(skb);
 
+#ifdef PC300_DEBUG_TX
+	printk(KERN_DEBUG "%s: cpc_queue_xmit returning normally\n",
+	       dev->name);
+#endif
+
 	return 0;
 }
 
@@ -1988,7 +2048,8 @@ static void cpc_net_rx(struct net_device *dev)
 
 		if (!netif_carrier_ok(dev)) {
 			/* DCD must be OFF: drop packet */
-		    printk("%s : DCD is OFF - drop %d rx bytes\n", dev->name, rxb); 
+			printk(KERN_INFO "%s : DCD is OFF - drop %d rx bytes\n",
+				dev->name, rxb);
 			skb = NULL;
 		} else {
 			if (rxb > (dev->mtu + 40)) { /* add headers */
@@ -2087,6 +2148,9 @@ static void sca_tx_intr(pc300dev_t *dev)
 	} else {
 #endif
 	/* Tell the upper layer we are ready to transmit more packets */
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG "Waking queue on TX interrupt\n");
+#endif
 		netif_wake_queue(dev->netdev);
 #ifdef CONFIG_PC300_MLPPP
 	}
@@ -2102,6 +2166,10 @@ static void sca_intr(pc300_t * card)
 	unsigned char dsr_rx;
 
 	while ((status = cpc_readl(scabase + ISR0)) != 0) {
+#ifdef PC300_DEBUG_INTR
+		printk(KERN_DEBUG "sca_intr(): status = %08x\n",
+		       status);
+#endif
 		for (ch = 0; ch < card->hw.nchan; ch++) {
 			pc300ch_t *chan = &card->chan[ch];
 			pc300dev_t *d = &chan->d;
@@ -2117,8 +2185,8 @@ static void sca_intr(pc300_t * card)
 				cpc_writeb(scabase + DSR_RX(ch), drx_stat | DSR_DWE);
 
 #ifdef PC300_DEBUG_INTR
-				printk ("sca_intr: RX intr chan[%d] (st=0x%08lx, dsr=0x%02x)\n",
-					 ch, status, drx_stat);
+				printk(KERN_DEBUG "sca_intr: RX intr chan[%d] (st=0x%08x, dsr=0x%02x)\n",
+				       ch, status, drx_stat);
 #endif
 				if (status & IR0_DRX(IR0_DMIA, ch)) {
 					if (drx_stat & DSR_BOF) {
@@ -2176,8 +2244,10 @@ static void sca_intr(pc300_t * card)
 				}
 				if (!(dsr_rx = cpc_readb(scabase + DSR_RX(ch)) & DSR_DE)) {
 #ifdef PC300_DEBUG_INTR
-		printk("%s: RX intr chan[%d] (st=0x%08lx, dsr=0x%02x, dsr2=0x%02x)\n",
-			dev->name, ch, status, drx_stat, dsr_rx);
+					printk(KERN_DEBUG
+					       "%s: RX intr chan[%d] (st=0x%08x, dsr=0x%02x, dsr2=0x%02x)\n",
+					       dev->name, ch, status,
+					       drx_stat, dsr_rx);
 #endif
 					cpc_writeb(scabase + DSR_RX(ch), (dsr_rx | DSR_DE) & 0xfe);
 				}
@@ -2191,8 +2261,8 @@ static void sca_intr(pc300_t * card)
 				cpc_writeb(scabase + DSR_TX(ch), dtx_stat | DSR_DWE);
 
 #ifdef PC300_DEBUG_INTR
-				printk ("sca_intr: TX intr chan[%d] (st=0x%08lx, dsr=0x%02x)\n",
-					 ch, status, dtx_stat);
+				printk(KERN_DEBUG "sca_intr: TX intr chan[%d] (st=0x%08x, dsr=0x%02x)\n",
+				       ch, status, dtx_stat);
 #endif
 				if (status & IR0_DTX(IR0_EFT, ch)) {
 					if (dtx_stat & DSR_UDRF) {
@@ -2207,6 +2277,15 @@ static void sca_intr(pc300_t * card)
 						}
 						dev->stats.tx_errors++;
 						dev->stats.tx_fifo_errors++;
+#ifdef PC300_DEBUG_OTHER
+						printk(KERN_DEBUG
+						       "sca_intr(): TX underflow!  Dump follows:\n");
+						printk(KERN_DEBUG
+						       "DSR_TX was 0x%02x\n",
+						       dtx_stat);
+						cpc_sca_status(card, ch);
+#endif
+
 					}
 					sca_tx_intr(d);
 				}
@@ -2235,8 +2314,8 @@ static void sca_intr(pc300_t * card)
 				cpc_writeb(scabase + M_REG(ST1, ch), st1);
 
 #ifdef PC300_DEBUG_INTR
-				printk("sca_intr: MSCI intr chan[%d] (st=0x%08lx, st1=0x%02x)\n",
-					 ch, status, st1);
+				printk(KERN_DEBUG "sca_intr: MSCI intr chan[%d] (st=0x%08x, st1=0x%02x)\n",
+				       ch, status, st1);
 #endif
 				if (st1 & ST1_CDCD) {	/* DCD changed */
 					if (cpc_readb(scabase + M_REG(ST3, ch)) & ST3_DCD) {
@@ -2498,8 +2577,15 @@ static void cpc_sca_status(pc300_t * card, int ch)
 	u8 ilar;
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	unsigned long flags;
+	char *reason;
 
+	printk(KERN_DEBUG "tx_dma_buf_check():\n");
 	tx_dma_buf_check(card, ch);
+#ifdef PC300_DEBUG_OTHER
+	printk(KERN_DEBUG "tx1_dma_buf_check():\n");
+	tx1_dma_buf_check(card, ch);
+#endif
+	printk(KERN_DEBUG "rx_dma_buf_check():\n");
 	rx_dma_buf_check(card, ch);
 	ilar = cpc_readb(scabase + ILAR);
 	printk ("ILAR=0x%02x, WCRL=0x%02x, PCR=0x%02x, BTCR=0x%02x, BOLR=0x%02x\n",
@@ -2575,7 +2661,25 @@ static void cpc_sca_status(pc300_t * card, int ch)
 	       cpc_readb(scabase + M_REG(IE2, ch)),
 	       cpc_readb(scabase + M_REG(IE4, ch)),
 	       cpc_readb(scabase + M_REG(FIE, ch)));
-	printk("IER0=0x%08x\n", (u32) cpc_readl(scabase + IER0));
+	printk(KERN_DEBUG "IER0=0x%08x\n", (u32) cpc_readl(scabase + IER0));
+	switch (card->chan[ch].d.reason_stopped) {
+	case CPC_DMA_FULL:
+	  reason = "CPC_DMA_FULL";
+	  break;
+	case CPC_DMA_ERROR:
+	  reason = "CPC_DMA_ERROR";
+	  break;
+	case TRANSMISSION_ACTIVE:
+	  reason = "TRANSMISSION_ACTIVE";
+	  break;
+	case CHANNEL_CLOSED:
+	  reason = "CHANNEL_CLOSED";
+	  break;
+	default:
+	  reason = "unknown";
+	  break;
+	}
+	printk(KERN_DEBUG "reason_stopped = %s\n", reason);
 
 	if (ilar != 0) {
 		CPC_LOCK(card, flags);
@@ -2615,6 +2719,9 @@ static void cpc_falc_status(pc300_t * card, int ch)
 
 static int cpc_change_mtu(struct net_device *dev, int new_mtu)
 {
+#ifdef PC300_DEBUG_OTHER
+	printk(KERN_DEBUG "%s: change MTU to %d\n", dev->name, new_mtu);
+#endif
 	if ((new_mtu < 128) || (new_mtu > PC300_DEF_MTU))
 		return -EINVAL;
 	dev->mtu = new_mtu;
@@ -2690,6 +2797,11 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 		case SIOCGPC300CONF:
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCGPC300CONF called, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
+#endif
 #ifdef CONFIG_PC300_MLPPP
 			if (conf->proto != PC300_PROTO_MLPPP) {
 				conf->proto = 0;
@@ -2702,8 +2814,18 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (!arg || 
 				copy_to_user(arg, &conf_aux, sizeof(pc300conf_t))) 
 				return -EINVAL;
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCGPC300CONF returning, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
+#endif
 			return 0;
 		case SIOCSPC300CONF:
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCSPC300CONF called, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
+#endif
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			if (!arg || 
@@ -2733,6 +2855,11 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 #else
 			memcpy(conf, &conf_aux.conf, sizeof(pc300chconf_t));
 #endif
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCSPC300CONF returning, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
+#endif
 			return 0;
 		case SIOCGPC300STATUS:
 			cpc_sca_status(card, ch);
@@ -3302,7 +3429,7 @@ int cpc_open(struct net_device *dev)
 	pc300_t *card = (pc300_t *) chan->card;
 
 #ifdef	PC300_DEBUG_OTHER
-	printk("pc300: cpc_open");
+	printk("pc300: cpc_open\n");
 #endif
 
 	result = hdlc_open(dev);
@@ -3311,6 +3438,9 @@ int cpc_open(struct net_device *dev)
 
 	sprintf(ifr.ifr_name, "%s", dev->name);
 	cpc_opench(d);
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG "%s: starting queue for open\n", dev->name);
+#endif
 	netif_start_queue(dev);
 	return 0;
 }
@@ -3323,9 +3453,13 @@ static int cpc_close(struct net_device *dev)
 	unsigned long flags;
 
 #ifdef	PC300_DEBUG_OTHER
-	printk("pc300: cpc_close");
+	printk(KERN_DEBUG "pc300: cpc_close\n");
+#endif
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG "%s: stopping queue\n", dev->name);
 #endif
 
+	d->reason_stopped = CHANNEL_CLOSED;
 	netif_stop_queue(dev);
 
 	CPC_LOCK(card, flags);
@@ -3517,6 +3651,7 @@ static void cpc_init_card(pc300_t * card)
 		d->hdlc = hdlc;
 
 		d->netdev = dev;
+		d->reason_stopped = CHANNEL_CLOSED;
 
 		if (register_hdlc_device(dev) == 0) {
 			printk("%s: Cyclades-PC300/", dev->name);
@@ -3538,13 +3673,27 @@ static void cpc_init_card(pc300_t * card)
 					printk("RSV ");
 					break;
 			}
-			printk (" #%d, %ldKB of RAM at 0x%08lx, IRQ%d, channel %d.\n",
-				 board_nbr, card->hw.ramsize / 1024,
-				 card->hw.ramphys, card->hw.irq, i + 1);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+			printk(KERN_INFO " #%d, %dKB of RAM at 0x%016lx, IRQ %d, channel %d.\n",
+			       board_nbr, card->hw.ramsize / 1024,
+			       (unsigned long)(card->hw.ramphys),
+			       card->hw.irq, i + 1);
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+			printk(KERN_INFO " #%d, %dKB of RAM at 0x%08x, IRQ %d, channel %d.\n",
+			       board_nbr, card->hw.ramsize / 1024,
+			       (unsigned int)(card->hw.ramphys),
+			       card->hw.irq, i + 1);
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+
 			devcount++;
 		} else {
-			printk ("Dev%d on card(0x%08lx): unable to allocate i/f name.\n",
-				 i + 1, card->hw.ramphys);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+			printk(KERN_ERR "Dev %d on card(0x%016lx): unable to allocate i/f name.\n",
+			       i + 1, (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+			printk(KERN_ERR "Dev %d on card(0x%08x): unable to allocate i/f name.\n",
+			       i + 1, (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 			*(dev->name) = 0;
 			kfree(d->hdlc);
 			continue;
@@ -3576,9 +3725,13 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	card = kzalloc(sizeof(pc300_t), GFP_KERNEL);
 	if (card == NULL) {
-		printk("PC300 found at RAM 0x%08lx, "
-		       "but could not allocate card structure.\n",
-		       pci_resource_start(pdev, 3));
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR "PC300 found at RAM 0x%016lx, but could not allocate card structure.\n",
+		       (unsigned long)(pci_resource_start(pdev, 3)));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR "PC300 found at RAM 0x%08x, but could not allocate card structure.\n",
+		       (unsigned int)(pci_resource_start(pdev, 3)));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 		return -ENOMEM;
 	}
 
@@ -3615,19 +3768,37 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 #ifdef PC300_DEBUG_PCI
 	printk("cpc (bus=0x0%x,pci_id=0x%x,", pdev->bus->number, pdev->devfn);
-	printk("rev_id=%d) IRQ%d\n", cpc_rev_id, card->hw.irq);
-	printk("cpc:found  ramaddr=0x%08lx plxaddr=0x%08lx "
-	       "ctladdr=0x%08lx falcaddr=0x%08lx\n",
-	       card->hw.ramphys, card->hw.plxphys, card->hw.scaphys,
-	       card->hw.falcphys);
+	printk("rev_id=%d) IRQ%d\n", pdev->revision, card->hw.irq);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+	printk(KERN_INFO
+	       "cpc:found  ramaddr=0x%016lx plxaddr=0x%016lx "
+	       "ctladdr=0x%016lx falcaddr=0x%016lx\n",
+	       (unsigned long)(card->hw.ramphys),
+	       (unsigned long)(card->hw.plxphys),
+	       (unsigned long)(card->hw.scaphys),
+	       (unsigned long)(card->hw.falcphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+	printk(KERN_INFO
+	       "cpc:found  ramaddr=0x%08x plxaddr=0x%08x "
+	       "ctladdr=0x%08x falcaddr=0x%08x\n",
+	       (unsigned int)(card->hw.ramphys),
+	       (unsigned int)(card->hw.plxphys),
+	       (unsigned int)(card->hw.scaphys),
+	       (unsigned int)(card->hw.falcphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 #endif
 	/* Although we don't use this I/O region, we should
 	 * request it from the kernel anyway, to avoid problems
 	 * with other drivers accessing it. */
 	if (!request_region(card->hw.iophys, card->hw.iosize, "PLX Registers")) {
 		/* In case we can't allocate it, warn user */
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
 		printk("WARNING: couldn't allocate I/O region for PC300 board "
-		       "at 0x%08lx!\n", card->hw.ramphys);
+		       "at 0x%016lx!\n", (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk("WARNING: couldn't allocate I/O region for PC300 board "
+		       "at 0x%08x!\n", (unsigned int)(card->hw.ramphys));
+#endif
 	}
 
 	if (card->hw.plxphys) {
@@ -3640,25 +3811,47 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (!request_mem_region(card->hw.plxphys, card->hw.plxsize,
 				"PLX Registers")) {
-		printk("PC300 found at RAM 0x%08lx, "
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%016lx, "
+		       "but could not allocate PLX mem region.\n",
+		       (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%08x, "
 		       "but could not allocate PLX mem region.\n",
 		       (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 		err = -ENODEV;
 		goto err_release_io;
 	}
 	if (!request_mem_region(card->hw.ramphys, card->hw.alloc_ramsize,
 				"On-board RAM")) {
-		printk("PC300 found at RAM 0x%08lx, "
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk("PC300 found at RAM 0x%016lx, "
+		       "but could not allocate SCA mem region.\n",
+		       (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk("PC300 found at RAM 0x%08x, "
 		       "but could not allocate RAM mem region.\n",
 		       (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 		err = -ENODEV;
 		goto err_release_plx;
 	}
 	if (!request_mem_region(card->hw.scaphys, card->hw.scasize,
 				"SCA-II Registers")) {
-		printk("PC300 found at RAM 0x%08lx, "
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%016lx, "
+		       "but could not allocate SCA mem region.\n",
+		       (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%08x, "
 		       "but could not allocate SCA mem region.\n",
 		       (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 		err = -ENODEV;
 		goto err_release_ram;
 	}
@@ -3692,10 +3885,23 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 #ifdef PC300_DEBUG_PCI
-	printk("cpc: relocate ramaddr=0x%08lx plxaddr=0x%08lx "
-	       "ctladdr=0x%08lx falcaddr=0x%08lx\n",
-	       card->hw.rambase, card->hw.plxbase, card->hw.scabase,
-	       card->hw.falcbase);
+#ifdef CONFIG_64BIT
+	printk(KERN_DEBUG
+	       "cpc: relocate ramaddr=0x%016lx plxaddr=0x%016lx "
+	       "ctladdr=0x%016lx falcaddr=0x%016lx\n",
+	       (unsigned long)(card->hw.rambase),
+	       (unsigned long)(card->hw.plxbase),
+	       (unsigned long)(card->hw.scabase),
+	       (unsigned long)(card->hw.falcbase));
+#else /* !CONFIG_64BIT */
+	printk(KERN_DEBUG
+	       "cpc: relocate ramaddr=0x%08x plxaddr=0x%08x "
+	       "ctladdr=0x%08x falcaddr=0x%08x\n",
+	       (unsigned int)(card->hw.rambase),
+	       (unsigned int)(card->hw.plxbase),
+	       (unsigned int)(card->hw.scabase),
+	       (unsigned int)(card->hw.falcbase));
+#endif /* CONFIG_64BIT */
 #endif
 
 	/* Set PCI drv pointer to the card structure */
@@ -3742,6 +3948,15 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Allocate IRQ */
 	if (request_irq(card->hw.irq, cpc_intr, IRQF_SHARED,
 				"Cyclades-PC300", card)) {
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR "PC300 found at RAM 0x%016lx, but could not allocate "
+			"IRQ%d.\n", (unsigned long)(card->hw.ramphys),
+			card->hw.irq);
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR "PC300 found at RAM 0x%08x, but could not allocate "
+			"IRQ%d.\n", (unsigned int)(card->hw.ramphys),
+			card->hw.irq);
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 		printk ("PC300 found at RAM 0x%08lx, but could not allocate IRQ%d.\n",
 			 card->hw.ramphys, card->hw.irq);
 		goto err_io_unmap;
