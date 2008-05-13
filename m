From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net-next updates for .27
Date: Tue, 13 May 2008 01:57:01 -0400
Message-ID: <20080513055701.GA17000@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758689AbYEMF5c@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-next

to receive the following updates:

 drivers/net/3c523.c            |   37 +++++++--------
 drivers/net/3c527.c            |   45 +++++++++----------
 drivers/net/8139cp.c           |   43 +++++++++---------
 drivers/net/8139too.c          |   53 +++++++++++-----------
 drivers/net/8390.h             |    1 -
 drivers/net/acenic.c           |   21 +++-----
 drivers/net/acenic.h           |    1 -
 drivers/net/cpmac.c            |    2 +-
 drivers/net/dm9000.c           |    6 +-
 drivers/net/gianfar.c          |    2 +-
 drivers/net/hamradio/6pack.c   |   24 +++-------
 drivers/net/lib8390.c          |   96 +++++++++++++++++++--------------------
 drivers/net/natsemi.c          |    4 +-
 drivers/net/niu.h              |    2 +-
 drivers/net/pcmcia/3c574_cs.c  |   47 +++++++++-----------
 drivers/net/pcmcia/3c589_cs.c  |   49 +++++++++-----------
 drivers/net/pcmcia/axnet_cs.c  |   70 ++++++++++++++---------------
 drivers/net/pcnet32.c          |    6 +-
 drivers/net/qla3xxx.c          |    4 +-
 drivers/net/s2io.c             |    4 +-
 drivers/net/s2io.h             |    2 +-
 drivers/net/sb1250-mac.c       |    2 +-
 drivers/net/sis190.c           |    2 +-
 drivers/net/sis900.c           |    2 +-
 drivers/net/sky2.c             |    2 +-
 drivers/net/spider_net.c       |    4 +-
 drivers/net/tokenring/3c359.c  |   20 +++------
 drivers/net/tokenring/3c359.h  |    2 -
 drivers/net/tsi108_eth.c       |    4 +-
 drivers/net/ucc_geth_ethtool.c |    4 +-
 30 files changed, 257 insertions(+), 304 deletions(-)

Jeff Garzik (2):
      drivers/net/lib8390: fix warning, trim trailing whitespace
      [netdrvr] Trim trailing whitespace for several drivers

Paulius Zaleckas (12):
      axnet_cs: use netstats in net_device structure
      lib8390: use netstats in net_device structure
      8390.h: remove net_device_stats
      8139cp: use netstats in net_device structure
      8139too: use netstats in net_device structure
      3c574_cs: use netstats in net_device structure
      3c589_cs: use netstats in net_device structure
      6pack: use netstats in net_device structure
      acenic: use netstats in net_device structure
      3c523: use netstats in net_device structure
      3c527: use netstats in net_device structure
      3c359: use netstats in net_device structure

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 239fc42..dc6e474 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -202,7 +202,6 @@ static void elmc_xmt_int(struct net_device *dev);
 static void elmc_rnr_int(struct net_device *dev);
 
 struct priv {
-	struct net_device_stats stats;
 	unsigned long base;
 	char *memtop;
 	unsigned long mapped_start;		/* Start of ioremap */
@@ -989,18 +988,18 @@ static void elmc_rcv_int(struct net_device *dev)
 					skb->protocol = eth_type_trans(skb, dev);
 					netif_rx(skb);
 					dev->last_rx = jiffies;
-					p->stats.rx_packets++;
-					p->stats.rx_bytes += totlen;
+					dev->stats.rx_packets++;
+					dev->stats.rx_bytes += totlen;
 				} else {
-					p->stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 				}
 			} else {
 				printk(KERN_WARNING "%s: received oversized frame.\n", dev->name);
-				p->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 		} else {	/* frame !(ok), only with 'save-bad-frames' */
 			printk(KERN_WARNING "%s: oops! rfd-error-status: %04x\n", dev->name, status);
-			p->stats.rx_errors++;
+			dev->stats.rx_errors++;
 		}
 		p->rfd_top->status = 0;
 		p->rfd_top->last = RFD_SUSP;
@@ -1018,7 +1017,7 @@ static void elmc_rnr_int(struct net_device *dev)
 {
 	struct priv *p = (struct priv *) dev->priv;
 
-	p->stats.rx_errors++;
+	dev->stats.rx_errors++;
 
 	WAIT_4_SCB_CMD();	/* wait for the last cmd */
 	p->scb->cmd = RUC_ABORT;	/* usually the RU is in the 'no resource'-state .. abort it now. */
@@ -1046,24 +1045,24 @@ static void elmc_xmt_int(struct net_device *dev)
 		printk(KERN_WARNING "%s: strange .. xmit-int without a 'COMPLETE'\n", dev->name);
 	}
 	if (status & STAT_OK) {
-		p->stats.tx_packets++;
-		p->stats.collisions += (status & TCMD_MAXCOLLMASK);
+		dev->stats.tx_packets++;
+		dev->stats.collisions += (status & TCMD_MAXCOLLMASK);
 	} else {
-		p->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		if (status & TCMD_LATECOLL) {
 			printk(KERN_WARNING "%s: late collision detected.\n", dev->name);
-			p->stats.collisions++;
+			dev->stats.collisions++;
 		} else if (status & TCMD_NOCARRIER) {
-			p->stats.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 			printk(KERN_WARNING "%s: no carrier detected.\n", dev->name);
 		} else if (status & TCMD_LOSTCTS) {
 			printk(KERN_WARNING "%s: loss of CTS detected.\n", dev->name);
 		} else if (status & TCMD_UNDERRUN) {
-			p->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			printk(KERN_WARNING "%s: DMA underrun detected.\n", dev->name);
 		} else if (status & TCMD_MAXCOLL) {
 			printk(KERN_WARNING "%s: Max. collisions exceeded.\n", dev->name);
-			p->stats.collisions += 16;
+			dev->stats.collisions += 16;
 		}
 	}
 
@@ -1215,12 +1214,12 @@ static struct net_device_stats *elmc_get_stats(struct net_device *dev)
 	ovrn = p->scb->ovrn_errs;
 	p->scb->ovrn_errs -= ovrn;
 
-	p->stats.rx_crc_errors += crc;
-	p->stats.rx_fifo_errors += ovrn;
-	p->stats.rx_frame_errors += aln;
-	p->stats.rx_dropped += rsc;
+	dev->stats.rx_crc_errors += crc;
+	dev->stats.rx_fifo_errors += ovrn;
+	dev->stats.rx_frame_errors += aln;
+	dev->stats.rx_dropped += rsc;
 
-	return &p->stats;
+	return &dev->stats;
 }
 
 /********************************************************
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index fae295b..6aca0c6 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -158,7 +158,6 @@ struct mc32_local
 	int slot;
 
 	u32 base;
-	struct net_device_stats net_stats;
 	volatile struct mc32_mailbox *rx_box;
 	volatile struct mc32_mailbox *tx_box;
 	volatile struct mc32_mailbox *exec_box;
@@ -1093,24 +1092,24 @@ static void mc32_update_stats(struct net_device *dev)
 
 	u32 rx_errors=0;
 
-	rx_errors+=lp->net_stats.rx_crc_errors   +=st->rx_crc_errors;
+	rx_errors+=dev->stats.rx_crc_errors   +=st->rx_crc_errors;
 	                                           st->rx_crc_errors=0;
-	rx_errors+=lp->net_stats.rx_fifo_errors  +=st->rx_overrun_errors;
+	rx_errors+=dev->stats.rx_fifo_errors  +=st->rx_overrun_errors;
 	                                           st->rx_overrun_errors=0;
-	rx_errors+=lp->net_stats.rx_frame_errors +=st->rx_alignment_errors;
+	rx_errors+=dev->stats.rx_frame_errors +=st->rx_alignment_errors;
  	                                           st->rx_alignment_errors=0;
-	rx_errors+=lp->net_stats.rx_length_errors+=st->rx_tooshort_errors;
+	rx_errors+=dev->stats.rx_length_errors+=st->rx_tooshort_errors;
 	                                           st->rx_tooshort_errors=0;
-	rx_errors+=lp->net_stats.rx_missed_errors+=st->rx_outofresource_errors;
+	rx_errors+=dev->stats.rx_missed_errors+=st->rx_outofresource_errors;
 	                                           st->rx_outofresource_errors=0;
-        lp->net_stats.rx_errors=rx_errors;
+        dev->stats.rx_errors=rx_errors;
 
 	/* Number of packets which saw one collision */
-	lp->net_stats.collisions+=st->dataC[10];
+	dev->stats.collisions+=st->dataC[10];
 	st->dataC[10]=0;
 
 	/* Number of packets which saw 2--15 collisions */
-	lp->net_stats.collisions+=st->dataC[11];
+	dev->stats.collisions+=st->dataC[11];
 	st->dataC[11]=0;
 }
 
@@ -1178,7 +1177,7 @@ static void mc32_rx_ring(struct net_device *dev)
 				skb=dev_alloc_skb(length+2);
 
 				if(skb==NULL) {
-					lp->net_stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 					goto dropped;
 				}
 
@@ -1189,8 +1188,8 @@ static void mc32_rx_ring(struct net_device *dev)
 
 			skb->protocol=eth_type_trans(skb,dev);
 			dev->last_rx = jiffies;
- 			lp->net_stats.rx_packets++;
- 			lp->net_stats.rx_bytes += length;
+ 			dev->stats.rx_packets++;
+ 			dev->stats.rx_bytes += length;
 			netif_rx(skb);
 		}
 
@@ -1253,34 +1252,34 @@ static void mc32_tx_ring(struct net_device *dev)
 			/* Not COMPLETED */
 			break;
 		}
-		lp->net_stats.tx_packets++;
+		dev->stats.tx_packets++;
 		if(!(np->status & (1<<6))) /* Not COMPLETED_OK */
 		{
-			lp->net_stats.tx_errors++;
+			dev->stats.tx_errors++;
 
 			switch(np->status&0x0F)
 			{
 				case 1:
-					lp->net_stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 					break; /* Max collisions */
 				case 2:
-					lp->net_stats.tx_fifo_errors++;
+					dev->stats.tx_fifo_errors++;
 					break;
 				case 3:
-					lp->net_stats.tx_carrier_errors++;
+					dev->stats.tx_carrier_errors++;
 					break;
 				case 4:
-					lp->net_stats.tx_window_errors++;
+					dev->stats.tx_window_errors++;
 					break;  /* CTS Lost */
 				case 5:
-					lp->net_stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 					break; /* Transmit timeout */
 			}
 		}
 		/* Packets are sent in order - this is
 		    basically a FIFO queue of buffers matching
 		    the card ring */
-		lp->net_stats.tx_bytes+=lp->tx_ring[t].skb->len;
+		dev->stats.tx_bytes+=lp->tx_ring[t].skb->len;
 		dev_kfree_skb_irq(lp->tx_ring[t].skb);
 		lp->tx_ring[t].skb=NULL;
 		atomic_inc(&lp->tx_count);
@@ -1367,7 +1366,7 @@ static irqreturn_t mc32_interrupt(int irq, void *dev_id)
 			case 6:
 				/* Out of RX buffers stat */
 				/* Must restart rx */
-				lp->net_stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				mc32_rx_ring(dev);
 				mc32_start_transceiver(dev);
 				break;
@@ -1489,10 +1488,8 @@ static int mc32_close(struct net_device *dev)
 
 static struct net_device_stats *mc32_get_stats(struct net_device *dev)
 {
-	struct mc32_local *lp = netdev_priv(dev);
-
 	mc32_update_stats(dev);
-	return &lp->net_stats;
+	return &dev->stats;
 }
 
 
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a453eda..934db35 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -340,7 +340,6 @@ struct cp_private {
 	u32			rx_config;
 	u16			cpcmd;
 
-	struct net_device_stats net_stats;
 	struct cp_extra_stats	cp_stats;
 
 	unsigned		rx_head		____cacheline_aligned;
@@ -457,8 +456,8 @@ static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
 {
 	skb->protocol = eth_type_trans (skb, cp->dev);
 
-	cp->net_stats.rx_packets++;
-	cp->net_stats.rx_bytes += skb->len;
+	cp->dev->stats.rx_packets++;
+	cp->dev->stats.rx_bytes += skb->len;
 	cp->dev->last_rx = jiffies;
 
 #if CP_VLAN_TAG_USED
@@ -477,17 +476,17 @@ static void cp_rx_err_acct (struct cp_private *cp, unsigned rx_tail,
 		printk (KERN_DEBUG
 			"%s: rx err, slot %d status 0x%x len %d\n",
 			cp->dev->name, rx_tail, status, len);
-	cp->net_stats.rx_errors++;
+	cp->dev->stats.rx_errors++;
 	if (status & RxErrFrame)
-		cp->net_stats.rx_frame_errors++;
+		cp->dev->stats.rx_frame_errors++;
 	if (status & RxErrCRC)
-		cp->net_stats.rx_crc_errors++;
+		cp->dev->stats.rx_crc_errors++;
 	if ((status & RxErrRunt) || (status & RxErrLong))
-		cp->net_stats.rx_length_errors++;
+		cp->dev->stats.rx_length_errors++;
 	if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag))
-		cp->net_stats.rx_length_errors++;
+		cp->dev->stats.rx_length_errors++;
 	if (status & RxErrFIFO)
-		cp->net_stats.rx_fifo_errors++;
+		cp->dev->stats.rx_fifo_errors++;
 }
 
 static inline unsigned int cp_rx_csum_ok (u32 status)
@@ -539,7 +538,7 @@ rx_status_loop:
 			 * that RX fragments are never encountered
 			 */
 			cp_rx_err_acct(cp, rx_tail, status, len);
-			cp->net_stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			cp->cp_stats.rx_frags++;
 			goto rx_next;
 		}
@@ -556,7 +555,7 @@ rx_status_loop:
 		buflen = cp->rx_buf_sz + RX_OFFSET;
 		new_skb = dev_alloc_skb (buflen);
 		if (!new_skb) {
-			cp->net_stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			goto rx_next;
 		}
 
@@ -710,20 +709,20 @@ static void cp_tx (struct cp_private *cp)
 				if (netif_msg_tx_err(cp))
 					printk(KERN_DEBUG "%s: tx err, status 0x%x\n",
 					       cp->dev->name, status);
-				cp->net_stats.tx_errors++;
+				cp->dev->stats.tx_errors++;
 				if (status & TxOWC)
-					cp->net_stats.tx_window_errors++;
+					cp->dev->stats.tx_window_errors++;
 				if (status & TxMaxCol)
-					cp->net_stats.tx_aborted_errors++;
+					cp->dev->stats.tx_aborted_errors++;
 				if (status & TxLinkFail)
-					cp->net_stats.tx_carrier_errors++;
+					cp->dev->stats.tx_carrier_errors++;
 				if (status & TxFIFOUnder)
-					cp->net_stats.tx_fifo_errors++;
+					cp->dev->stats.tx_fifo_errors++;
 			} else {
-				cp->net_stats.collisions +=
+				cp->dev->stats.collisions +=
 					((status >> TxColCntShift) & TxColCntMask);
-				cp->net_stats.tx_packets++;
-				cp->net_stats.tx_bytes += skb->len;
+				cp->dev->stats.tx_packets++;
+				cp->dev->stats.tx_bytes += skb->len;
 				if (netif_msg_tx_done(cp))
 					printk(KERN_DEBUG "%s: tx done, slot %d\n", cp->dev->name, tx_tail);
 			}
@@ -956,7 +955,7 @@ static void cp_set_rx_mode (struct net_device *dev)
 static void __cp_get_stats(struct cp_private *cp)
 {
 	/* only lower 24 bits valid; write any value to clear */
-	cp->net_stats.rx_missed_errors += (cpr32 (RxMissed) & 0xffffff);
+	cp->dev->stats.rx_missed_errors += (cpr32 (RxMissed) & 0xffffff);
 	cpw32 (RxMissed, 0);
 }
 
@@ -971,7 +970,7 @@ static struct net_device_stats *cp_get_stats(struct net_device *dev)
  		__cp_get_stats(cp);
 	spin_unlock_irqrestore(&cp->lock, flags);
 
-	return &cp->net_stats;
+	return &dev->stats;
 }
 
 static void cp_stop_hw (struct cp_private *cp)
@@ -1142,7 +1141,7 @@ static void cp_clean_rings (struct cp_private *cp)
 					 PCI_DMA_TODEVICE);
 			if (le32_to_cpu(desc->opts1) & LastFrag)
 				dev_kfree_skb(skb);
-			cp->net_stats.tx_dropped++;
+			cp->dev->stats.tx_dropped++;
 		}
 	}
 
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 53bd903..b23a00c 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -574,7 +574,6 @@ struct rtl8139_private {
 	u32			msg_enable;
 	struct napi_struct	napi;
 	struct net_device	*dev;
-	struct net_device_stats	stats;
 
 	unsigned char		*rx_ring;
 	unsigned int		cur_rx;	/* RX buf index of next pkt */
@@ -1711,7 +1710,7 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb);
 	} else {
 		dev_kfree_skb(skb);
-		tp->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		return 0;
 	}
 
@@ -1762,27 +1761,27 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 			if (netif_msg_tx_err(tp))
 				printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
 					dev->name, txstatus);
-			tp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
-				tp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 				RTL_W32 (TxConfig, TxClearAbt);
 				RTL_W16 (IntrStatus, TxErr);
 				wmb();
 			}
 			if (txstatus & TxCarrierLost)
-				tp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 			if (txstatus & TxOutOfWindow)
-				tp->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 		} else {
 			if (txstatus & TxUnderrun) {
 				/* Add 64 to the Tx FIFO threshold. */
 				if (tp->tx_flag < 0x00300000)
 					tp->tx_flag += 0x00020000;
-				tp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 			}
-			tp->stats.collisions += (txstatus >> 24) & 15;
-			tp->stats.tx_bytes += txstatus & 0x7ff;
-			tp->stats.tx_packets++;
+			dev->stats.collisions += (txstatus >> 24) & 15;
+			dev->stats.tx_bytes += txstatus & 0x7ff;
+			dev->stats.tx_packets++;
 		}
 
 		dirty_tx++;
@@ -1818,7 +1817,7 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 	if (netif_msg_rx_err (tp))
 		printk(KERN_DEBUG "%s: Ethernet frame had errors, status %8.8x.\n",
 			dev->name, rx_status);
-	tp->stats.rx_errors++;
+	dev->stats.rx_errors++;
 	if (!(rx_status & RxStatusOK)) {
 		if (rx_status & RxTooLong) {
 			DPRINTK ("%s: Oversized Ethernet frame, status %4.4x!\n",
@@ -1826,11 +1825,11 @@ static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
 			/* A.C.: The chip hangs here. */
 		}
 		if (rx_status & (RxBadSymbol | RxBadAlign))
-			tp->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (rx_status & (RxRunt | RxTooLong))
-			tp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		if (rx_status & RxCRCErr)
-			tp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 	} else {
 		tp->xstats.rx_lost_in_ring++;
 	}
@@ -1913,9 +1912,9 @@ static void rtl8139_isr_ack(struct rtl8139_private *tp)
 	/* Clear out errors and receive interrupts */
 	if (likely(status != 0)) {
 		if (unlikely(status & (RxFIFOOver | RxOverflow))) {
-			tp->stats.rx_errors++;
+			tp->dev->stats.rx_errors++;
 			if (status & RxFIFOOver)
-				tp->stats.rx_fifo_errors++;
+				tp->dev->stats.rx_fifo_errors++;
 		}
 		RTL_W16_F (IntrStatus, RxAckBits);
 	}
@@ -2016,8 +2015,8 @@ no_early_rx:
 			skb->protocol = eth_type_trans (skb, dev);
 
 			dev->last_rx = jiffies;
-			tp->stats.rx_bytes += pkt_size;
-			tp->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_size;
+			dev->stats.rx_packets++;
 
 			netif_receive_skb (skb);
 		} else {
@@ -2025,7 +2024,7 @@ no_early_rx:
 				printk (KERN_WARNING
 					"%s: Memory squeeze, dropping packet.\n",
 					dev->name);
-			tp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 		}
 		received++;
 
@@ -2072,7 +2071,7 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 	assert (ioaddr != NULL);
 
 	/* Update the error count. */
-	tp->stats.rx_missed_errors += RTL_R32 (RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
 	RTL_W32 (RxMissed, 0);
 
 	if ((status & RxUnderrun) && link_changed &&
@@ -2082,12 +2081,12 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 	}
 
 	if (status & (RxUnderrun | RxErr))
-		tp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 	if (status & PCSTimeout)
-		tp->stats.rx_length_errors++;
+		dev->stats.rx_length_errors++;
 	if (status & RxUnderrun)
-		tp->stats.rx_fifo_errors++;
+		dev->stats.rx_fifo_errors++;
 	if (status & PCIErr) {
 		u16 pci_cmd_status;
 		pci_read_config_word (tp->pci_dev, PCI_STATUS, &pci_cmd_status);
@@ -2227,7 +2226,7 @@ static int rtl8139_close (struct net_device *dev)
 	RTL_W16 (IntrMask, 0);
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += RTL_R32 (RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
 	RTL_W32 (RxMissed, 0);
 
 	spin_unlock_irqrestore (&tp->lock, flags);
@@ -2472,12 +2471,12 @@ static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave (&tp->lock, flags);
-		tp->stats.rx_missed_errors += RTL_R32 (RxMissed);
+		dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
 		RTL_W32 (RxMissed, 0);
 		spin_unlock_irqrestore (&tp->lock, flags);
 	}
 
-	return &tp->stats;
+	return &dev->stats;
 }
 
 /* Set or clear the multicast filter for this adaptor.
@@ -2561,7 +2560,7 @@ static int rtl8139_suspend (struct pci_dev *pdev, pm_message_t state)
 	RTL_W8 (ChipCmd, 0);
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += RTL_R32 (RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32 (RxMissed);
 	RTL_W32 (RxMissed, 0);
 
 	spin_unlock_irqrestore (&tp->lock, flags);
diff --git a/drivers/net/8390.h b/drivers/net/8390.h
index 04ddec0..cf020d4 100644
--- a/drivers/net/8390.h
+++ b/drivers/net/8390.h
@@ -69,7 +69,6 @@ struct ei_device {
 	unsigned char reg0;		/* Register '0' in a WD8013 */
 	unsigned char reg5;		/* Register '5' in a WD8013 */
 	unsigned char saved_irq;	/* Original dev->irq value. */
-	struct net_device_stats stat;	/* The new statistics table. */
 	u32 *reg_offset;		/* Register mapping table */
 	spinlock_t page_lock;		/* Page register locks */
 	unsigned long priv;		/* Private field to store bus IDs etc. */
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 6c19265..e4483de 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -1457,11 +1457,6 @@ static int __devinit ace_init(struct net_device *dev)
 	ace_set_txprd(regs, ap, 0);
 	writel(0, &regs->RxRetCsm);
 
-	/*
-	 * Zero the stats before starting the interface
-	 */
-	memset(&ap->stats, 0, sizeof(ap->stats));
-
        /*
 	* Enable DMA engine now.
 	* If we do this sooner, Mckinley box pukes.
@@ -2041,8 +2036,8 @@ static void ace_rx_int(struct net_device *dev, u32 rxretprd, u32 rxretcsm)
 			netif_rx(skb);
 
 		dev->last_rx = jiffies;
-		ap->stats.rx_packets++;
-		ap->stats.rx_bytes += retdesc->size;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += retdesc->size;
 
 		idx = (idx + 1) % RX_RETURN_RING_ENTRIES;
 	}
@@ -2090,8 +2085,8 @@ static inline void ace_tx_int(struct net_device *dev,
 		}
 
 		if (skb) {
-			ap->stats.tx_packets++;
-			ap->stats.tx_bytes += skb->len;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += skb->len;
 			dev_kfree_skb_irq(skb);
 			info->skb = NULL;
 		}
@@ -2863,11 +2858,11 @@ static struct net_device_stats *ace_get_stats(struct net_device *dev)
 	struct ace_mac_stats __iomem *mac_stats =
 		(struct ace_mac_stats __iomem *)ap->regs->Stats;
 
-	ap->stats.rx_missed_errors = readl(&mac_stats->drop_space);
-	ap->stats.multicast = readl(&mac_stats->kept_mc);
-	ap->stats.collisions = readl(&mac_stats->coll);
+	dev->stats.rx_missed_errors = readl(&mac_stats->drop_space);
+	dev->stats.multicast = readl(&mac_stats->kept_mc);
+	dev->stats.collisions = readl(&mac_stats->coll);
 
-	return &ap->stats;
+	return &dev->stats;
 }
 
 
diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index 60ed183..4487f32 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -693,7 +693,6 @@ struct ace_private
 				__attribute__ ((aligned (SMP_CACHE_BYTES)));
 	u32			last_tx, last_std_rx, last_mini_rx;
 #endif
-	struct net_device_stats stats;
 	int			pci_using_dac;
 };
 
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 2b5740b..ae07100 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -708,7 +708,7 @@ static void cpmac_tx_timeout(struct net_device *dev)
 	spin_unlock(&priv->lock);
 	if (netif_msg_tx_err(priv) && net_ratelimit())
 		printk(KERN_WARNING "%s: transmit timeout\n", dev->name);
-	/* 
+	/*
 	 * FIXME: waking up random queue is not the best thing to
 	 * do... on the other hand why we got here at all?
 	 */
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index e6fe261..12b4626 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -696,7 +696,7 @@ dm9000_probe(struct platform_device *pdev)
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
 		/* try reading from mac */
-		
+
 		mac_src = "chip";
 		for (i = 0; i < 6; i++)
 			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
@@ -746,7 +746,7 @@ dm9000_open(struct net_device *dev)
 		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
 		irqflags = DEFAULT_TRIGGER;
 	}
-	
+
 	irqflags |= IRQF_SHARED;
 
 	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev))
@@ -1089,7 +1089,7 @@ static int dm9000_wait_eeprom(board_info_t *db)
 	/* The DM9000 data sheets say we should be able to
 	 * poll the ERRE bit in EPCR to wait for the EEPROM
 	 * operation. From testing several chips, this bit
-	 * does not seem to work. 
+	 * does not seem to work.
 	 *
 	 * We attempt to use the bit, but fall back to the
 	 * timeout (which is why we do not return an error
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 587afe7..642dc63 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -925,7 +925,7 @@ rx_irq_fail:
 tx_irq_fail:
 	free_irq(priv->interruptError, dev);
 err_irq_fail:
-err_rxalloc_fail:	
+err_rxalloc_fail:
 rx_skb_fail:
 	free_skb_resources(priv);
 tx_skb_fail:
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 9d57212..06ad9f3 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -99,9 +99,6 @@ struct sixpack {
 	unsigned int		rx_count;
 	unsigned int		rx_count_cooked;
 
-	/* 6pack interface statistics. */
-	struct net_device_stats stats;
-
 	int			mtu;		/* Our mtu (to spot changes!) */
 	int			buffsize;       /* Max buffers sizes */
 
@@ -237,7 +234,7 @@ static void sp_encaps(struct sixpack *sp, unsigned char *icp, int len)
 	return;
 
 out_drop:
-	sp->stats.tx_dropped++;
+	sp->dev->stats.tx_dropped++;
 	netif_start_queue(sp->dev);
 	if (net_ratelimit())
 		printk(KERN_DEBUG "%s: %s - dropped.\n", sp->dev->name, msg);
@@ -252,7 +249,7 @@ static int sp_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_lock_bh(&sp->lock);
 	/* We were not busy, so we are now... :-) */
 	netif_stop_queue(dev);
-	sp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 	sp_encaps(sp, skb->data, skb->len);
 	spin_unlock_bh(&sp->lock);
 
@@ -298,12 +295,6 @@ static int sp_header(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 }
 
-static struct net_device_stats *sp_get_stats(struct net_device *dev)
-{
-	struct sixpack *sp = netdev_priv(dev);
-	return &sp->stats;
-}
-
 static int sp_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr_ax25 *sa = addr;
@@ -338,7 +329,6 @@ static void sp_setup(struct net_device *dev)
 	dev->destructor		= free_netdev;
 	dev->stop		= sp_close;
 
-	dev->get_stats	        = sp_get_stats;
 	dev->set_mac_address    = sp_set_mac_address;
 	dev->hard_header_len	= AX25_MAX_HEADER_LEN;
 	dev->header_ops 	= &sp_header_ops;
@@ -370,7 +360,7 @@ static void sp_bump(struct sixpack *sp, char cmd)
 
 	count = sp->rcount + 1;
 
-	sp->stats.rx_bytes += count;
+	sp->dev->stats.rx_bytes += count;
 
 	if ((skb = dev_alloc_skb(count)) == NULL)
 		goto out_mem;
@@ -382,12 +372,12 @@ static void sp_bump(struct sixpack *sp, char cmd)
 	skb->protocol = ax25_type_trans(skb, sp->dev);
 	netif_rx(skb);
 	sp->dev->last_rx = jiffies;
-	sp->stats.rx_packets++;
+	sp->dev->stats.rx_packets++;
 
 	return;
 
 out_mem:
-	sp->stats.rx_dropped++;
+	sp->dev->stats.rx_dropped++;
 }
 
 
@@ -436,7 +426,7 @@ static void sixpack_write_wakeup(struct tty_struct *tty)
 	if (sp->xleft <= 0)  {
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
-		sp->stats.tx_packets++;
+		sp->dev->stats.tx_packets++;
 		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 		sp->tx_enable = 0;
 		netif_wake_queue(sp->dev);
@@ -484,7 +474,7 @@ static void sixpack_receive_buf(struct tty_struct *tty,
 		count--;
 		if (fp && *fp++) {
 			if (!test_and_set_bit(SIXPF_ERROR, &sp->flags))
-				sp->stats.rx_errors++;
+				sp->dev->stats.rx_errors++;
 			continue;
 		}
 	}
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 0c5447d..ed49527 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -150,19 +150,19 @@ static void __NS8390_init(struct net_device *dev, int startp);
  *	card means that approach caused horrible problems like losing serial data
  *	at 38400 baud on some chips. Remember many 8390 nics on PCI were ISA
  *	chips with FPGA front ends.
- *	
+ *
  *	Ok the logic behind the 8390 is very simple:
- *	
+ *
  *	Things to know
  *		- IRQ delivery is asynchronous to the PCI bus
  *		- Blocking the local CPU IRQ via spin locks was too slow
  *		- The chip has register windows needing locking work
- *	
+ *
  *	So the path was once (I say once as people appear to have changed it
  *	in the mean time and it now looks rather bogus if the changes to use
  *	disable_irq_nosync_irqsave are disabling the local IRQ)
- *	
- *	
+ *
+ *
  *		Take the page lock
  *		Mask the IRQ on chip
  *		Disable the IRQ (but not mask locally- someone seems to have
@@ -170,22 +170,22 @@ static void __NS8390_init(struct net_device *dev, int startp);
  *			[This must be _nosync as the page lock may otherwise
  *				deadlock us]
  *		Drop the page lock and turn IRQs back on
- *		
+ *
  *		At this point an existing IRQ may still be running but we can't
  *		get a new one
- *	
+ *
  *		Take the lock (so we know the IRQ has terminated) but don't mask
  *	the IRQs on the processor
  *		Set irqlock [for debug]
- *	
+ *
  *		Transmit (slow as ****)
- *	
+ *
  *		re-enable the IRQ
- *	
- *	
+ *
+ *
  *	We have to use disable_irq because otherwise you will get delayed
  *	interrupts on the APIC bus deadlocking the transmit path.
- *	
+ *
  *	Quite hairy but the chip simply wasn't designed for SMP and you can't
  *	even ACK an interrupt without risking corrupting other parallel
  *	activities on the chip." [lkml, 25 Jul 2007]
@@ -265,7 +265,7 @@ static void ei_tx_timeout(struct net_device *dev)
 	int txsr, isr, tickssofar = jiffies - dev->trans_start;
 	unsigned long flags;
 
-	ei_local->stat.tx_errors++;
+	dev->stats.tx_errors++;
 
 	spin_lock_irqsave(&ei_local->page_lock, flags);
 	txsr = ei_inb(e8390_base+EN0_TSR);
@@ -276,7 +276,7 @@ static void ei_tx_timeout(struct net_device *dev)
 		dev->name, (txsr & ENTSR_ABT) ? "excess collisions." :
 		(isr) ? "lost interrupt?" : "cable problem?", txsr, isr, tickssofar);
 
-	if (!isr && !ei_local->stat.tx_packets)
+	if (!isr && !dev->stats.tx_packets)
 	{
 		/* The 8390 probably hasn't gotten on the cable yet. */
 		ei_local->interface_num ^= 1;   /* Try a different xcvr.  */
@@ -374,7 +374,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock(&ei_local->page_lock);
 		enable_irq_lockdep_irqrestore(dev->irq, &flags);
-		ei_local->stat.tx_errors++;
+		dev->stats.tx_errors++;
 		return 1;
 	}
 
@@ -417,7 +417,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	enable_irq_lockdep_irqrestore(dev->irq, &flags);
 
 	dev_kfree_skb (skb);
-	ei_local->stat.tx_bytes += send_length;
+	dev->stats.tx_bytes += send_length;
 
 	return 0;
 }
@@ -493,9 +493,9 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 
 		if (interrupts & ENISR_COUNTERS)
 		{
-			ei_local->stat.rx_frame_errors += ei_inb_p(e8390_base + EN0_COUNTER0);
-			ei_local->stat.rx_crc_errors   += ei_inb_p(e8390_base + EN0_COUNTER1);
-			ei_local->stat.rx_missed_errors+= ei_inb_p(e8390_base + EN0_COUNTER2);
+			dev->stats.rx_frame_errors += ei_inb_p(e8390_base + EN0_COUNTER0);
+			dev->stats.rx_crc_errors   += ei_inb_p(e8390_base + EN0_COUNTER1);
+			dev->stats.rx_missed_errors+= ei_inb_p(e8390_base + EN0_COUNTER2);
 			ei_outb_p(ENISR_COUNTERS, e8390_base + EN0_ISR); /* Ack intr. */
 		}
 
@@ -553,7 +553,6 @@ static void __ei_poll(struct net_device *dev)
 static void ei_tx_err(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 	unsigned char txsr = ei_inb_p(e8390_base+EN0_TSR);
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
@@ -578,10 +577,10 @@ static void ei_tx_err(struct net_device *dev)
 		ei_tx_intr(dev);
 	else
 	{
-		ei_local->stat.tx_errors++;
-		if (txsr & ENTSR_CRS) ei_local->stat.tx_carrier_errors++;
-		if (txsr & ENTSR_CDH) ei_local->stat.tx_heartbeat_errors++;
-		if (txsr & ENTSR_OWC) ei_local->stat.tx_window_errors++;
+		dev->stats.tx_errors++;
+		if (txsr & ENTSR_CRS) dev->stats.tx_carrier_errors++;
+		if (txsr & ENTSR_CDH) dev->stats.tx_heartbeat_errors++;
+		if (txsr & ENTSR_OWC) dev->stats.tx_window_errors++;
 	}
 }
 
@@ -645,25 +644,25 @@ static void ei_tx_intr(struct net_device *dev)
 
 	/* Minimize Tx latency: update the statistics after we restart TXing. */
 	if (status & ENTSR_COL)
-		ei_local->stat.collisions++;
+		dev->stats.collisions++;
 	if (status & ENTSR_PTX)
-		ei_local->stat.tx_packets++;
+		dev->stats.tx_packets++;
 	else
 	{
-		ei_local->stat.tx_errors++;
+		dev->stats.tx_errors++;
 		if (status & ENTSR_ABT)
 		{
-			ei_local->stat.tx_aborted_errors++;
-			ei_local->stat.collisions += 16;
+			dev->stats.tx_aborted_errors++;
+			dev->stats.collisions += 16;
 		}
 		if (status & ENTSR_CRS)
-			ei_local->stat.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 		if (status & ENTSR_FU)
-			ei_local->stat.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 		if (status & ENTSR_CDH)
-			ei_local->stat.tx_heartbeat_errors++;
+			dev->stats.tx_heartbeat_errors++;
 		if (status & ENTSR_OWC)
-			ei_local->stat.tx_window_errors++;
+			dev->stats.tx_window_errors++;
 	}
 	netif_wake_queue(dev);
 }
@@ -730,7 +729,7 @@ static void ei_receive(struct net_device *dev)
 			&& rx_frame.next != next_frame + 1 - num_rx_pages) {
 			ei_local->current_page = rxing_page;
 			ei_outb(ei_local->current_page-1, e8390_base+EN0_BOUNDARY);
-			ei_local->stat.rx_errors++;
+			dev->stats.rx_errors++;
 			continue;
 		}
 
@@ -740,8 +739,8 @@ static void ei_receive(struct net_device *dev)
 				printk(KERN_DEBUG "%s: bogus packet size: %d, status=%#2x nxpg=%#2x.\n",
 					   dev->name, rx_frame.count, rx_frame.status,
 					   rx_frame.next);
-			ei_local->stat.rx_errors++;
-			ei_local->stat.rx_length_errors++;
+			dev->stats.rx_errors++;
+			dev->stats.rx_length_errors++;
 		}
 		 else if ((pkt_stat & 0x0F) == ENRSR_RXOK)
 		{
@@ -753,7 +752,7 @@ static void ei_receive(struct net_device *dev)
 				if (ei_debug > 1)
 					printk(KERN_DEBUG "%s: Couldn't allocate a sk_buff of size %d.\n",
 						   dev->name, pkt_len);
-				ei_local->stat.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 			else
@@ -764,10 +763,10 @@ static void ei_receive(struct net_device *dev)
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				ei_local->stat.rx_packets++;
-				ei_local->stat.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 				if (pkt_stat & ENRSR_PHY)
-					ei_local->stat.multicast++;
+					dev->stats.multicast++;
 			}
 		}
 		else
@@ -776,10 +775,10 @@ static void ei_receive(struct net_device *dev)
 				printk(KERN_DEBUG "%s: bogus packet: status=%#2x nxpg=%#2x size=%d\n",
 					   dev->name, rx_frame.status, rx_frame.next,
 					   rx_frame.count);
-			ei_local->stat.rx_errors++;
+			dev->stats.rx_errors++;
 			/* NB: The NIC counts CRC, frame and missed errors. */
 			if (pkt_stat & ENRSR_FO)
-				ei_local->stat.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 		}
 		next_frame = rx_frame.next;
 
@@ -816,7 +815,6 @@ static void ei_rx_overrun(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 
 	/*
 	 * Record whether a Tx was in progress and then issue the
@@ -827,7 +825,7 @@ static void ei_rx_overrun(struct net_device *dev)
 
 	if (ei_debug > 1)
 		printk(KERN_DEBUG "%s: Receiver overrun.\n", dev->name);
-	ei_local->stat.rx_over_errors++;
+	dev->stats.rx_over_errors++;
 
 	/*
 	 * Wait a full Tx time (1.2ms) + some guard time, NS says 1.6ms total.
@@ -889,16 +887,16 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 
 	/* If the card is stopped, just return the present stats. */
 	if (!netif_running(dev))
-		return &ei_local->stat;
+		return &dev->stats;
 
 	spin_lock_irqsave(&ei_local->page_lock,flags);
 	/* Read the counter registers, assuming we are in page 0. */
-	ei_local->stat.rx_frame_errors += ei_inb_p(ioaddr + EN0_COUNTER0);
-	ei_local->stat.rx_crc_errors   += ei_inb_p(ioaddr + EN0_COUNTER1);
-	ei_local->stat.rx_missed_errors+= ei_inb_p(ioaddr + EN0_COUNTER2);
+	dev->stats.rx_frame_errors += ei_inb_p(ioaddr + EN0_COUNTER0);
+	dev->stats.rx_crc_errors   += ei_inb_p(ioaddr + EN0_COUNTER1);
+	dev->stats.rx_missed_errors+= ei_inb_p(ioaddr + EN0_COUNTER2);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
-	return &ei_local->stat;
+	return &dev->stats;
 }
 
 /*
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 46119bb..b238ed0 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -664,7 +664,7 @@ static ssize_t natsemi_show_##_name(struct device *dev, \
 NATSEMI_ATTR(dspcfg_workaround);
 
 static ssize_t natsemi_show_dspcfg_workaround(struct device *dev,
-				  	      struct device_attribute *attr, 
+				  	      struct device_attribute *attr,
 					      char *buf)
 {
 	struct netdev_private *np = netdev_priv(to_net_dev(dev));
@@ -687,7 +687,7 @@ static ssize_t natsemi_set_dspcfg_workaround(struct device *dev,
                  || !strncmp("0", buf, count - 1))
 		new_setting = 0;
 	else
-                 return count; 
+                 return count;
 
 	spin_lock_irqsave(&np->lock, flags);
 
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 97ffbe1..101a3f1 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -281,7 +281,7 @@
 #define XMAC_ADDR1			0x000a8UL
 #define  XMAC_ADDR1_ADDR1		0x000000000000ffffULL
 
-#define XMAC_ADDR2			0x000b0UL 
+#define XMAC_ADDR2			0x000b0UL
 #define  XMAC_ADDR2_ADDR2		0x000000000000ffffULL
 
 #define XMAC_ADDR_CMPEN			0x00208UL
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 3b78a38..7112fd5 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -208,7 +208,6 @@ enum Window4 {		/* Window 4: Xcvr/media bits. */
 struct el3_private {
 	struct pcmcia_device	*p_dev;
 	dev_node_t node;
-	struct net_device_stats stats;
 	u16 advertising, partner;		/* NWay media advertisement */
 	unsigned char phys;			/* MII device address */
 	unsigned int autoselect:1, default_media:3;	/* Read from the EEPROM/Wn3_Config. */
@@ -741,12 +740,11 @@ static int el3_open(struct net_device *dev)
 
 static void el3_tx_timeout(struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
 	
 	printk(KERN_NOTICE "%s: Transmit timed out!\n", dev->name);
 	dump_status(dev);
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	dev->trans_start = jiffies;
 	/* Issue TX_RESET and TX_START commands. */
 	tc574_wait_for_completion(dev, TxReset);
@@ -756,7 +754,6 @@ static void el3_tx_timeout(struct net_device *dev)
 
 static void pop_tx_status(struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
 	int i;
     
@@ -772,7 +769,7 @@ static void pop_tx_status(struct net_device *dev)
 			DEBUG(1, "%s: transmit error: status 0x%02x\n",
 				  dev->name, tx_status);
 			outw(TxEnable, ioaddr + EL3_CMD);
-			lp->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 		}
 		outb(0x00, ioaddr + TxStatus); /* Pop the status stack. */
 	}
@@ -987,7 +984,7 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
 		update_stats(dev);
 		spin_unlock_irqrestore(&lp->window_lock, flags);
 	}
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /*  Update statistics.
@@ -996,7 +993,6 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
  */
 static void update_stats(struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
 	u8 rx, tx, up;
 
@@ -1008,15 +1004,15 @@ static void update_stats(struct net_device *dev)
 	/* Unlike the 3c509 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
-	lp->stats.tx_carrier_errors 		+= inb(ioaddr + 0);
-	lp->stats.tx_heartbeat_errors		+= inb(ioaddr + 1);
+	dev->stats.tx_carrier_errors 		+= inb(ioaddr + 0);
+	dev->stats.tx_heartbeat_errors		+= inb(ioaddr + 1);
 	/* Multiple collisions. */	   	inb(ioaddr + 2);
-	lp->stats.collisions			+= inb(ioaddr + 3);
-	lp->stats.tx_window_errors		+= inb(ioaddr + 4);
-	lp->stats.rx_fifo_errors		+= inb(ioaddr + 5);
-	lp->stats.tx_packets			+= inb(ioaddr + 6);
+	dev->stats.collisions			+= inb(ioaddr + 3);
+	dev->stats.tx_window_errors		+= inb(ioaddr + 4);
+	dev->stats.rx_fifo_errors		+= inb(ioaddr + 5);
+	dev->stats.tx_packets			+= inb(ioaddr + 6);
 	up		 			 = inb(ioaddr + 9);
-	lp->stats.tx_packets			+= (up&0x30) << 4;
+	dev->stats.tx_packets			+= (up&0x30) << 4;
 	/* Rx packets   */			   inb(ioaddr + 7);
 	/* Tx deferrals */			   inb(ioaddr + 8);
 	rx		 			 = inw(ioaddr + 10);
@@ -1026,14 +1022,13 @@ static void update_stats(struct net_device *dev)
 	/* BadSSD */				   inb(ioaddr + 12);
 	up					 = inb(ioaddr + 13);
 
-	lp->stats.tx_bytes 			+= tx + ((up & 0xf0) << 12);
+	dev->stats.tx_bytes 			+= tx + ((up & 0xf0) << 12);
 
 	EL3WINDOW(1);
 }
 
 static int el3_rx(struct net_device *dev, int worklimit)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
 	short rx_status;
 	
@@ -1043,14 +1038,14 @@ static int el3_rx(struct net_device *dev, int worklimit)
 		   (--worklimit >= 0)) {
 		if (rx_status & 0x4000) { /* Error, update stats. */
 			short error = rx_status & 0x3800;
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			switch (error) {
-			case 0x0000:	lp->stats.rx_over_errors++; break;
-			case 0x0800:	lp->stats.rx_length_errors++; break;
-			case 0x1000:	lp->stats.rx_frame_errors++; break;
-			case 0x1800:	lp->stats.rx_length_errors++; break;
-			case 0x2000:	lp->stats.rx_frame_errors++; break;
-			case 0x2800:	lp->stats.rx_crc_errors++; break;
+			case 0x0000:	dev->stats.rx_over_errors++; break;
+			case 0x0800:	dev->stats.rx_length_errors++; break;
+			case 0x1000:	dev->stats.rx_frame_errors++; break;
+			case 0x1800:	dev->stats.rx_length_errors++; break;
+			case 0x2000:	dev->stats.rx_frame_errors++; break;
+			case 0x2800:	dev->stats.rx_crc_errors++; break;
 			}
 		} else {
 			short pkt_len = rx_status & 0x7ff;
@@ -1067,12 +1062,12 @@ static int el3_rx(struct net_device *dev, int worklimit)
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 			} else {
 				DEBUG(1, "%s: couldn't allocate a sk_buff of"
 					  " size %d.\n", dev->name, pkt_len);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 		}
 		tc574_wait_for_completion(dev, RxDiscard);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 1b1abb1..549a645 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -107,7 +107,6 @@ enum RxFilter {
 struct el3_private {
 	struct pcmcia_device	*p_dev;
     dev_node_t 		node;
-    struct net_device_stats stats;
     /* For transceiver monitoring */
     struct timer_list	media;
     u16			media_status;
@@ -566,12 +565,11 @@ static int el3_open(struct net_device *dev)
 
 static void el3_tx_timeout(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     
     printk(KERN_WARNING "%s: Transmit timed out!\n", dev->name);
     dump_status(dev);
-    lp->stats.tx_errors++;
+    dev->stats.tx_errors++;
     dev->trans_start = jiffies;
     /* Issue TX_RESET and TX_START commands. */
     tc589_wait_for_completion(dev, TxReset);
@@ -581,7 +579,6 @@ static void el3_tx_timeout(struct net_device *dev)
 
 static void pop_tx_status(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     int i;
     
@@ -596,7 +593,7 @@ static void pop_tx_status(struct net_device *dev)
 	    DEBUG(1, "%s: transmit error: status 0x%02x\n",
 		  dev->name, tx_status);
 	    outw(TxEnable, ioaddr + EL3_CMD);
-	    lp->stats.tx_aborted_errors++;
+	    dev->stats.tx_aborted_errors++;
 	}
 	outb(0x00, ioaddr + TX_STATUS); /* Pop the status stack. */
     }
@@ -614,7 +611,7 @@ static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
     spin_lock_irqsave(&priv->lock, flags);    
 
-    priv->stats.tx_bytes += skb->len;
+    dev->stats.tx_bytes += skb->len;
 
     /* Put out the doubleword header... */
     outw(skb->len, ioaddr + TX_FIFO);
@@ -764,7 +761,7 @@ static void media_check(unsigned long arg)
 	outw(StatsDisable, ioaddr + EL3_CMD);
 	errs = inb(ioaddr + 0);
 	outw(StatsEnable, ioaddr + EL3_CMD);
-	lp->stats.tx_carrier_errors += errs;
+	dev->stats.tx_carrier_errors += errs;
 	if (errs || (lp->media_status & 0x0010)) media |= 0x0010;
     }
 
@@ -814,7 +811,7 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
 	update_stats(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
     }
-    return &lp->stats;
+    return &dev->stats;
 }
 
 /*
@@ -827,7 +824,6 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
 */
 static void update_stats(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
 
     DEBUG(2, "%s: updating the statistics.\n", dev->name);
@@ -835,13 +831,13 @@ static void update_stats(struct net_device *dev)
     outw(StatsDisable, ioaddr + EL3_CMD);
     /* Switch to the stats window, and read everything. */
     EL3WINDOW(6);
-    lp->stats.tx_carrier_errors 	+= inb(ioaddr + 0);
-    lp->stats.tx_heartbeat_errors	+= inb(ioaddr + 1);
+    dev->stats.tx_carrier_errors 	+= inb(ioaddr + 0);
+    dev->stats.tx_heartbeat_errors	+= inb(ioaddr + 1);
     /* Multiple collisions. */	   	inb(ioaddr + 2);
-    lp->stats.collisions		+= inb(ioaddr + 3);
-    lp->stats.tx_window_errors		+= inb(ioaddr + 4);
-    lp->stats.rx_fifo_errors		+= inb(ioaddr + 5);
-    lp->stats.tx_packets		+= inb(ioaddr + 6);
+    dev->stats.collisions		+= inb(ioaddr + 3);
+    dev->stats.tx_window_errors		+= inb(ioaddr + 4);
+    dev->stats.rx_fifo_errors		+= inb(ioaddr + 5);
+    dev->stats.tx_packets		+= inb(ioaddr + 6);
     /* Rx packets   */			inb(ioaddr + 7);
     /* Tx deferrals */			inb(ioaddr + 8);
     /* Rx octets */			inw(ioaddr + 10);
@@ -854,7 +850,6 @@ static void update_stats(struct net_device *dev)
 
 static int el3_rx(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     int worklimit = 32;
     short rx_status;
@@ -865,14 +860,14 @@ static int el3_rx(struct net_device *dev)
 	   (--worklimit >= 0)) {
 	if (rx_status & 0x4000) { /* Error, update stats. */
 	    short error = rx_status & 0x3800;
-	    lp->stats.rx_errors++;
+	    dev->stats.rx_errors++;
 	    switch (error) {
-	    case 0x0000:	lp->stats.rx_over_errors++; break;
-	    case 0x0800:	lp->stats.rx_length_errors++; break;
-	    case 0x1000:	lp->stats.rx_frame_errors++; break;
-	    case 0x1800:	lp->stats.rx_length_errors++; break;
-	    case 0x2000:	lp->stats.rx_frame_errors++; break;
-	    case 0x2800:	lp->stats.rx_crc_errors++; break;
+	    case 0x0000:	dev->stats.rx_over_errors++; break;
+	    case 0x0800:	dev->stats.rx_length_errors++; break;
+	    case 0x1000:	dev->stats.rx_frame_errors++; break;
+	    case 0x1800:	dev->stats.rx_length_errors++; break;
+	    case 0x2000:	dev->stats.rx_frame_errors++; break;
+	    case 0x2800:	dev->stats.rx_crc_errors++; break;
 	    }
 	} else {
 	    short pkt_len = rx_status & 0x7ff;
@@ -889,12 +884,12 @@ static int el3_rx(struct net_device *dev)
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 		dev->last_rx = jiffies;
-		lp->stats.rx_packets++;
-		lp->stats.rx_bytes += pkt_len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pkt_len;
 	    } else {
 		DEBUG(1, "%s: couldn't allocate a sk_buff of"
 		      " size %d.\n", dev->name, pkt_len);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 	    }
 	}
 	/* Pop the top of the Rx FIFO */
@@ -929,7 +924,7 @@ static int el3_close(struct net_device *dev)
     DEBUG(1, "%s: shutting down ethercard.\n", dev->name);
 
     if (pcmcia_dev_present(link)) {
-	/* Turn off statistics ASAP.  We update lp->stats below. */
+	/* Turn off statistics ASAP.  We update dev->stats below. */
 	outw(StatsDisable, ioaddr + EL3_CMD);
 	
 	/* Disable the receiver and transmitter. */
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index ce95c5d..d7018ff 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1021,7 +1021,7 @@ static void ei_tx_timeout(struct net_device *dev)
 	int txsr, isr, tickssofar = jiffies - dev->trans_start;
 	unsigned long flags;
 
-	ei_local->stat.tx_errors++;
+	dev->stats.tx_errors++;
 
 	spin_lock_irqsave(&ei_local->page_lock, flags);
 	txsr = inb(e8390_base+EN0_TSR);
@@ -1032,7 +1032,7 @@ static void ei_tx_timeout(struct net_device *dev)
 		dev->name, (txsr & ENTSR_ABT) ? "excess collisions." :
 		(isr) ? "lost interrupt?" : "cable problem?", txsr, isr, tickssofar);
 
-	if (!isr && !ei_local->stat.tx_packets) 
+	if (!isr && !dev->stats.tx_packets) 
 	{
 		/* The 8390 probably hasn't gotten on the cable yet. */
 		ei_local->interface_num ^= 1;   /* Try a different xcvr.  */
@@ -1122,7 +1122,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 		outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock_irqrestore(&ei_local->page_lock, flags);
-		ei_local->stat.tx_errors++;
+		dev->stats.tx_errors++;
 		return 1;
 	}
 
@@ -1170,7 +1170,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	dev_kfree_skb (skb);
-	ei_local->stat.tx_bytes += send_length;
+	dev->stats.tx_bytes += send_length;
     
 	return 0;
 }
@@ -1262,9 +1262,9 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 
 		if (interrupts & ENISR_COUNTERS) 
 		{
-			ei_local->stat.rx_frame_errors += inb_p(e8390_base + EN0_COUNTER0);
-			ei_local->stat.rx_crc_errors   += inb_p(e8390_base + EN0_COUNTER1);
-			ei_local->stat.rx_missed_errors+= inb_p(e8390_base + EN0_COUNTER2);
+			dev->stats.rx_frame_errors += inb_p(e8390_base + EN0_COUNTER0);
+			dev->stats.rx_crc_errors   += inb_p(e8390_base + EN0_COUNTER1);
+			dev->stats.rx_missed_errors+= inb_p(e8390_base + EN0_COUNTER2);
 		}
 	}
     
@@ -1309,7 +1309,6 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 static void ei_tx_err(struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 	unsigned char txsr = inb_p(e8390_base+EN0_TSR);
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
@@ -1332,10 +1331,10 @@ static void ei_tx_err(struct net_device *dev)
 		ei_tx_intr(dev);
 	else 
 	{
-		ei_local->stat.tx_errors++;
-		if (txsr & ENTSR_CRS) ei_local->stat.tx_carrier_errors++;
-		if (txsr & ENTSR_CDH) ei_local->stat.tx_heartbeat_errors++;
-		if (txsr & ENTSR_OWC) ei_local->stat.tx_window_errors++;
+		dev->stats.tx_errors++;
+		if (txsr & ENTSR_CRS) dev->stats.tx_carrier_errors++;
+		if (txsr & ENTSR_CDH) dev->stats.tx_heartbeat_errors++;
+		if (txsr & ENTSR_OWC) dev->stats.tx_window_errors++;
 	}
 }
 
@@ -1397,25 +1396,25 @@ static void ei_tx_intr(struct net_device *dev)
 
 	/* Minimize Tx latency: update the statistics after we restart TXing. */
 	if (status & ENTSR_COL)
-		ei_local->stat.collisions++;
+		dev->stats.collisions++;
 	if (status & ENTSR_PTX)
-		ei_local->stat.tx_packets++;
+		dev->stats.tx_packets++;
 	else 
 	{
-		ei_local->stat.tx_errors++;
+		dev->stats.tx_errors++;
 		if (status & ENTSR_ABT) 
 		{
-			ei_local->stat.tx_aborted_errors++;
-			ei_local->stat.collisions += 16;
+			dev->stats.tx_aborted_errors++;
+			dev->stats.collisions += 16;
 		}
 		if (status & ENTSR_CRS) 
-			ei_local->stat.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 		if (status & ENTSR_FU) 
-			ei_local->stat.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 		if (status & ENTSR_CDH)
-			ei_local->stat.tx_heartbeat_errors++;
+			dev->stats.tx_heartbeat_errors++;
 		if (status & ENTSR_OWC)
-			ei_local->stat.tx_window_errors++;
+			dev->stats.tx_window_errors++;
 	}
 	netif_wake_queue(dev);
 }
@@ -1476,8 +1475,8 @@ static void ei_receive(struct net_device *dev)
 				printk(KERN_DEBUG "%s: bogus packet size: %d, status=%#2x nxpg=%#2x.\n",
 					   dev->name, rx_frame.count, rx_frame.status,
 					   rx_frame.next);
-			ei_local->stat.rx_errors++;
-			ei_local->stat.rx_length_errors++;
+			dev->stats.rx_errors++;
+			dev->stats.rx_length_errors++;
 		}
 		 else if ((pkt_stat & 0x0F) == ENRSR_RXOK) 
 		{
@@ -1489,7 +1488,7 @@ static void ei_receive(struct net_device *dev)
 				if (ei_debug > 1)
 					printk(KERN_DEBUG "%s: Couldn't allocate a sk_buff of size %d.\n",
 						   dev->name, pkt_len);
-				ei_local->stat.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 			else
@@ -1500,10 +1499,10 @@ static void ei_receive(struct net_device *dev)
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				ei_local->stat.rx_packets++;
-				ei_local->stat.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 				if (pkt_stat & ENRSR_PHY)
-					ei_local->stat.multicast++;
+					dev->stats.multicast++;
 			}
 		} 
 		else 
@@ -1512,10 +1511,10 @@ static void ei_receive(struct net_device *dev)
 				printk(KERN_DEBUG "%s: bogus packet: status=%#2x nxpg=%#2x size=%d\n",
 					   dev->name, rx_frame.status, rx_frame.next,
 					   rx_frame.count);
-			ei_local->stat.rx_errors++;
+			dev->stats.rx_errors++;
 			/* NB: The NIC counts CRC, frame and missed errors. */
 			if (pkt_stat & ENRSR_FO)
-				ei_local->stat.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 		}
 		next_frame = rx_frame.next;
 		
@@ -1550,7 +1549,6 @@ static void ei_rx_overrun(struct net_device *dev)
 	axnet_dev_t *info = PRIV(dev);
 	long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
     
 	/*
 	 * Record whether a Tx was in progress and then issue the
@@ -1561,7 +1559,7 @@ static void ei_rx_overrun(struct net_device *dev)
     
 	if (ei_debug > 1)
 		printk(KERN_DEBUG "%s: Receiver overrun.\n", dev->name);
-	ei_local->stat.rx_over_errors++;
+	dev->stats.rx_over_errors++;
     
 	/* 
 	 * Wait a full Tx time (1.2ms) + some guard time, NS says 1.6ms total.
@@ -1622,16 +1620,16 @@ static struct net_device_stats *get_stats(struct net_device *dev)
     
 	/* If the card is stopped, just return the present stats. */
 	if (!netif_running(dev))
-		return &ei_local->stat;
+		return &dev->stats;
 
 	spin_lock_irqsave(&ei_local->page_lock,flags);
 	/* Read the counter registers, assuming we are in page 0. */
-	ei_local->stat.rx_frame_errors += inb_p(ioaddr + EN0_COUNTER0);
-	ei_local->stat.rx_crc_errors   += inb_p(ioaddr + EN0_COUNTER1);
-	ei_local->stat.rx_missed_errors+= inb_p(ioaddr + EN0_COUNTER2);
+	dev->stats.rx_frame_errors += inb_p(ioaddr + EN0_COUNTER0);
+	dev->stats.rx_crc_errors   += inb_p(ioaddr + EN0_COUNTER1);
+	dev->stats.rx_missed_errors+= inb_p(ioaddr + EN0_COUNTER2);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
     
-	return &ei_local->stat;
+	return &dev->stats;
 }
 
 /*
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 4eb322e..d0d5585 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2006,7 +2006,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
       err_free_ring:
 	pcnet32_free_ring(dev);
       err_free_consistent:
-	pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block), 
+	pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block),
 			    lp->init_block, lp->init_dma_addr);
       err_free_netdev:
 	free_netdev(dev);
@@ -3006,7 +3006,7 @@ static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
 		unregister_netdev(dev);
 		pcnet32_free_ring(dev);
 		release_region(dev->base_addr, PCNET32_TOTAL_SIZE);
-		pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block), 
+		pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block),
 				    lp->init_block, lp->init_dma_addr);
 		free_netdev(dev);
 		pci_disable_device(pdev);
@@ -3089,7 +3089,7 @@ static void __exit pcnet32_cleanup_module(void)
 		unregister_netdev(pcnet32_dev);
 		pcnet32_free_ring(pcnet32_dev);
 		release_region(pcnet32_dev->base_addr, PCNET32_TOTAL_SIZE);
-		pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block), 
+		pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block),
 				    lp->init_block, lp->init_dma_addr);
 		free_netdev(pcnet32_dev);
 		pcnet32_dev = next_dev;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index b7f7b22..5f60878 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1437,9 +1437,9 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 	reg &= ~PHY_GIG_ALL_PARAMS;
 
 	if(portConfiguration & PORT_CONFIG_1000MB_SPEED) {
-		if(portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED) 
+		if(portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED)
 			reg |= PHY_GIG_ADV_1000F;
-		else 
+		else
 			reg |= PHY_GIG_ADV_1000H;
 	}
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 523478e..75bde64 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2547,7 +2547,7 @@ static int fill_rx_buffers(struct ring_info *ring)
 		if (block_no)
 			rxd_index += (block_no * ring->rxd_count);
 
-		if ((block_no == block_no1) && 
+		if ((block_no == block_no1) &&
 			(off == ring->rx_curr_get_info.offset) &&
 			(rxdp->Host_Control)) {
 			DBG_PRINT(INTR_DBG, "%s: Get and Put",
@@ -2593,7 +2593,7 @@ static int fill_rx_buffers(struct ring_info *ring)
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
 			}
 			stats->mem_alloc_fail_cnt++;
-				
+
 			return -ENOMEM ;
 		}
 		stats->mem_allocated += skb->truesize;
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 0709eba..58229dc 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -747,7 +747,7 @@ struct ring_info {
 
 	/* interface MTU value */
         unsigned mtu;
-    
+
 	/* Buffer Address store. */
 	struct buffAdd **ba;
 
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 888b7de..2951990 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -1063,7 +1063,7 @@ static void sbmac_netpoll(struct net_device *netdev)
 	((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_RX_CH0),
 	sc->sbm_imr);
 #else
-	__raw_writeq((M_MAC_INT_CHANNEL << S_MAC_TX_CH0) | 
+	__raw_writeq((M_MAC_INT_CHANNEL << S_MAC_TX_CH0) |
 	(M_MAC_INT_CHANNEL << S_MAC_RX_CH0), sc->sbm_imr);
 #endif
 }
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index abc63b0..3fe0176 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1656,7 +1656,7 @@ static inline void sis190_init_rxfilter(struct net_device *dev)
 	SIS_PCI_COMMIT();
 }
 
-static int __devinit sis190_get_mac_addr(struct pci_dev *pdev, 
+static int __devinit sis190_get_mac_addr(struct pci_dev *pdev,
 					 struct net_device *dev)
 {
 	int rc;
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index ec95e49..fa3a460 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1766,7 +1766,7 @@ static int sis900_rx(struct net_device *net_dev)
 				skb = sis_priv->rx_skbuff[entry];
 				net_dev->stats.rx_dropped++;
 				goto refill_rx_ring;
-			}	
+			}
 
 			/* This situation should never happen, but due to
 			   some unknow bugs, it is possible that
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index f226bca..4b0f033 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3369,7 +3369,7 @@ static void sky2_led(struct sky2_port *sky2, enum led_mode mode)
 
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	} else
-		gm_phy_write(hw, port, PHY_MARV_LED_OVER, 
+		gm_phy_write(hw, port, PHY_MARV_LED_OVER,
 				     PHY_M_LED_MO_DUP(mode) |
 				     PHY_M_LED_MO_10(mode) |
 				     PHY_M_LED_MO_100(mode) |
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 4776716..00aa0b1 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1704,7 +1704,7 @@ spider_net_poll_controller(struct net_device *netdev)
  *
  * spider_net_enable_interrupt enables several interrupts
  */
-static void 
+static void
 spider_net_enable_interrupts(struct spider_net_card *card)
 {
 	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK,
@@ -1721,7 +1721,7 @@ spider_net_enable_interrupts(struct spider_net_card *card)
  *
  * spider_net_disable_interrupts disables all the interrupts
  */
-static void 
+static void
 spider_net_disable_interrupts(struct spider_net_card *card)
 {
 	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, 0);
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 45208a0..7766cde 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -132,7 +132,6 @@ static void xl_dn_comp(struct net_device *dev);
 static int xl_close(struct net_device *dev);
 static void xl_set_rx_mode(struct net_device *dev);
 static irqreturn_t xl_interrupt(int irq, void *dev_id);
-static struct net_device_stats * xl_get_stats(struct net_device *dev);
 static int xl_set_mac_address(struct net_device *dev, void *addr) ; 
 static void xl_arb_cmd(struct net_device *dev);
 static void xl_asb_cmd(struct net_device *dev) ; 
@@ -343,7 +342,6 @@ static int __devinit xl_probe(struct pci_dev *pdev,
 	dev->stop=&xl_close;
 	dev->do_ioctl=NULL;
 	dev->set_multicast_list=&xl_set_rx_mode;
-	dev->get_stats=&xl_get_stats ;
 	dev->set_mac_address=&xl_set_mac_address ; 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -921,7 +919,7 @@ static void xl_rx(struct net_device *dev)
 					adv_rx_ring(dev) ; 
 				
 				adv_rx_ring(dev) ; /* One more time just for luck :) */ 
-				xl_priv->xl_stats.rx_dropped++ ; 
+				dev->stats.rx_dropped++ ; 
 
 				writel(ACK_INTERRUPT | UPCOMPACK | LATCH_ACK , xl_mmio + MMIO_COMMAND) ; 
 				return ; 				
@@ -957,7 +955,7 @@ static void xl_rx(struct net_device *dev)
 			if (skb==NULL) { /* Still need to fix the rx ring */
 				printk(KERN_WARNING "%s: dev_alloc_skb failed in rx, single buffer \n",dev->name) ; 
 				adv_rx_ring(dev) ; 
-				xl_priv->xl_stats.rx_dropped++ ; 
+				dev->stats.rx_dropped++ ; 
 				writel(ACK_INTERRUPT | UPCOMPACK | LATCH_ACK , xl_mmio + MMIO_COMMAND) ; 
 				return ; 
 			}
@@ -971,8 +969,8 @@ static void xl_rx(struct net_device *dev)
 			xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr = cpu_to_le32(pci_map_single(xl_priv->pdev,skb->data,xl_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE));
 			xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfraglen = cpu_to_le32(xl_priv->pkt_buf_sz) | RXUPLASTFRAG;
 			adv_rx_ring(dev) ; 
-			xl_priv->xl_stats.rx_packets++ ; 
-			xl_priv->xl_stats.rx_bytes += frame_length ; 	
+			dev->stats.rx_packets++ ; 
+			dev->stats.rx_bytes += frame_length ; 	
 
 			netif_rx(skb2) ; 		
 		 } /* if multiple buffers */
@@ -1182,8 +1180,8 @@ static int xl_xmit(struct sk_buff *skb, struct net_device *dev)
 		txd->buffer = cpu_to_le32(pci_map_single(xl_priv->pdev, skb->data, skb->len, PCI_DMA_TODEVICE));
 		txd->buffer_length = cpu_to_le32(skb->len) | TXDNFRAGLAST;
 		xl_priv->tx_ring_skb[tx_head] = skb ; 
-		xl_priv->xl_stats.tx_packets++ ; 
-		xl_priv->xl_stats.tx_bytes += skb->len ;
+		dev->stats.tx_packets++ ; 
+		dev->stats.tx_bytes += skb->len ;
 
 		/* 
 		 * Set the nextptr of the previous descriptor equal to this descriptor, add XL_TX_RING_SIZE -1 
@@ -1463,12 +1461,6 @@ static void xl_srb_bh(struct net_device *dev)
 	return ; 	
 } 
 
-static struct net_device_stats * xl_get_stats(struct net_device *dev)
-{
-	struct xl_private *xl_priv = netdev_priv(dev);
-	return (struct net_device_stats *) &xl_priv->xl_stats; 
-}
-
 static int xl_set_mac_address (struct net_device *dev, void *addr) 
 {
 	struct sockaddr *saddr = addr ; 
diff --git a/drivers/net/tokenring/3c359.h b/drivers/net/tokenring/3c359.h
index b880cba..0f8b4ec 100644
--- a/drivers/net/tokenring/3c359.h
+++ b/drivers/net/tokenring/3c359.h
@@ -273,8 +273,6 @@ struct xl_private {
 	struct wait_queue *srb_wait;
 	volatile int asb_queued;   
 
-	struct net_device_stats xl_stats ;
-
 	u16 mac_buffer ; 	
 	u16 xl_lan_status ;
 	u8 xl_ring_speed ;
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 6017d52..c028fac 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1526,7 +1526,7 @@ static int tsi108_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct tsi108_prv_data *data = netdev_priv(dev);
 	unsigned long flags;
 	int rc;
-	
+
 	spin_lock_irqsave(&data->txlock, flags);
 	rc = mii_ethtool_gset(&data->mii_if, cmd);
 	spin_unlock_irqrestore(&data->txlock, flags);
@@ -1543,7 +1543,7 @@ static int tsi108_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	spin_lock_irqsave(&data->txlock, flags);
 	rc = mii_ethtool_sset(&data->mii_if, cmd);
 	spin_unlock_irqrestore(&data->txlock, flags);
-	
+
 	return rc;
 }
 
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 9a9622c..3320003 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -5,7 +5,7 @@
  *
  * Author: Li Yang <leoli@freescale.com>
  *
- * Limitation: 
+ * Limitation:
  * Can only get/set setttings of the first queue.
  * Need to re-open the interface manually after changing some paramters.
  *
@@ -165,7 +165,7 @@ uec_set_pauseparam(struct net_device *netdev,
 
 	ugeth->ug_info->receiveFlowControl = pause->rx_pause;
 	ugeth->ug_info->transmitFlowControl = pause->tx_pause;
-	
+
 	if (ugeth->phydev->autoneg) {
 		if (netif_running(netdev)) {
 			/* FIXME: automatically restart */
