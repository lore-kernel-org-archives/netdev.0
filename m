From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] make tg3 NAPI support configurable
Date: Fri, 19 Dec 2003 23:48:39 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FE2F3A7.2A109F28@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

G'day,

I've been having some issues with irq rates and cpu usage in the
tg3 driver.  In short, on Altix machines they're far too high.
It turned out that reverting the driver to its pre-NAPI interrupt
coalescing scheme made the situation a lot better.

How much better?  Running 8192 byte UDP packets across gige
with NAPI takes 99.5% of a CPU to service 29,100 irqs per second.
With the pre-NAPI code the figures are 36.0% CPU and 4880 irq/sec.
Similar improvements are seen for non-fragmented UDP and for TCP.

So, this patch against 2.6.0-test11 makes NAPI support in the tg3
driver selectable with a config option.  The default value is to
enable NAPI, on the assumption that NAPI must be working for most
people.  The non-NAPI case is the code from before NAPI was added,
with tweaks for locking and ethtool_ops.

The patch also applies against 2.6.0 with a few offsets.



===========================================================================
linux/drivers/net/Kconfig
===========================================================================

--- /usr/tmp/TmpDir.7858-0/linux/drivers/net/Kconfig_1.22	Thu Dec 18 11:45:52 2003
+++ linux/drivers/net/Kconfig	Thu Dec 18 11:45:11 2003
@@ -2017,6 +2017,14 @@
 	  To compile this driver as a module, choose M here: the module
 	  will be called tg3.  This is recommended.
 
+config TIGON3_NAPI
+	bool "Use Rx Polling (NAPI)"
+	default y
+	depends on TIGON3
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card.
+	
 endmenu
 
 #

===========================================================================
linux/drivers/net/tg3.c
===========================================================================

--- /usr/tmp/TmpDir.26498-0/linux/drivers/net/tg3.c_1.20	Tue Nov 11 12:38:57 2003
+++ linux/drivers/net/tg3.c	Tue Nov 11 12:03:11 2003
@@ -2306,7 +2306,13 @@
 				    desc->err_vlan & RXD_VLAN_MASK);
 		} else
 #endif
+		{
+#ifdef CONFIG_TIGON3_NAPI
 			netif_receive_skb(skb);
+#else /* !CONFIG_TIGON3_NAPI */
+			netif_rx(skb);
+#endif /* !CONFIG_TIGON3_NAPI */
+		}
 
 		tp->dev->last_rx = jiffies;
 		received++;
@@ -2345,6 +2351,146 @@
 	return received;
 }
 
+#ifndef CONFIG_TIGON3_NAPI
+
+#define PKT_RATE_LOW		22000
+#define PKT_RATE_HIGH		61000
+
+static void tg3_rate_sample(struct tg3 *tp, unsigned long ticks)
+{
+	u32 delta, rx_now, tx_now;
+	int new_vals, do_tx, do_rx;
+
+	rx_now = tp->hw_stats->rx_ucast_packets.low;
+	tx_now = tp->hw_stats->COS_out_packets[0].low;
+
+	delta  = (rx_now - tp->last_rx_count);
+	delta += (tx_now - tp->last_tx_count);
+	delta /= (ticks / tp->coalesce_config.rate_sample_jiffies);
+
+	tp->last_rx_count = rx_now;
+	tp->last_tx_count = tx_now;
+
+	new_vals = 0;
+	do_tx = (tp->tg3_flags2 & TG3_FLG2_ADAPTIVE_TX) != 0;
+	do_rx = (tp->tg3_flags2 & TG3_FLG2_ADAPTIVE_RX) != 0;
+	if (delta < tp->coalesce_config.pkt_rate_low) {
+		if (do_rx &&
+		    tp->coalesce_config.rx_max_coalesced_frames !=
+		    tp->coalesce_config.rx_max_coalesced_frames_low) {
+			tp->coalesce_config.rx_max_coalesced_frames =
+				LOW_RXMAX_FRAMES;
+			tp->coalesce_config.rx_coalesce_ticks =
+				LOW_RXCOL_TICKS;
+			new_vals = 1;
+		}
+		if (do_tx &&
+		    tp->coalesce_config.tx_max_coalesced_frames !=
+		    tp->coalesce_config.tx_max_coalesced_frames_low) {
+			tp->coalesce_config.tx_max_coalesced_frames =
+				tp->coalesce_config.tx_max_coalesced_frames_low;
+			tp->coalesce_config.tx_coalesce_ticks =
+				tp->coalesce_config.tx_coalesce_ticks_low;
+			new_vals = 1;
+		}
+	} else if (delta < tp->coalesce_config.pkt_rate_high) {
+		if (do_rx &&
+		    tp->coalesce_config.rx_max_coalesced_frames !=
+		    tp->coalesce_config.rx_max_coalesced_frames_def) {
+			tp->coalesce_config.rx_max_coalesced_frames =
+				tp->coalesce_config.rx_max_coalesced_frames_def;
+			tp->coalesce_config.rx_coalesce_ticks =
+				tp->coalesce_config.rx_coalesce_ticks_def;
+			new_vals = 1;
+		}
+		if (do_tx &&
+		    tp->coalesce_config.tx_max_coalesced_frames !=
+		    tp->coalesce_config.tx_max_coalesced_frames_def) {
+			tp->coalesce_config.tx_max_coalesced_frames =
+				tp->coalesce_config.tx_max_coalesced_frames_def;
+			tp->coalesce_config.tx_coalesce_ticks =
+				tp->coalesce_config.tx_coalesce_ticks_def;
+			new_vals = 1;
+		}
+	} else {
+		if (do_rx &&
+		    tp->coalesce_config.rx_max_coalesced_frames !=
+		    tp->coalesce_config.rx_max_coalesced_frames_high) {
+			tp->coalesce_config.rx_max_coalesced_frames =
+				tp->coalesce_config.rx_max_coalesced_frames_high;
+			tp->coalesce_config.rx_coalesce_ticks =
+				tp->coalesce_config.rx_coalesce_ticks_high;
+			new_vals = 1;
+		}
+		if (do_tx &&
+		    tp->coalesce_config.tx_max_coalesced_frames !=
+		    tp->coalesce_config.tx_max_coalesced_frames_high) {
+			tp->coalesce_config.tx_max_coalesced_frames =
+				tp->coalesce_config.tx_max_coalesced_frames_high;
+			tp->coalesce_config.tx_coalesce_ticks =
+				tp->coalesce_config.tx_coalesce_ticks_high;
+			new_vals = 1;
+		}
+	}
+
+	if (new_vals) {
+		if (do_rx) {
+			tw32(HOSTCC_RXCOL_TICKS,
+			     tp->coalesce_config.rx_coalesce_ticks);
+			tw32(HOSTCC_RXMAX_FRAMES,
+			     tp->coalesce_config.rx_max_coalesced_frames);
+		}
+		if (do_tx) {
+			tw32(HOSTCC_TXCOL_TICKS,
+			     tp->coalesce_config.tx_coalesce_ticks);
+			tw32(HOSTCC_TXMAX_FRAMES,
+			     tp->coalesce_config.tx_max_coalesced_frames);
+		}
+	}
+
+	tp->last_rate_sample = jiffies;
+}
+
+static void tg3_interrupt_main_work(struct tg3 *tp)
+{
+	struct tg3_hw_status *sblk = tp->hw_status;
+	int did_pkts;
+
+	if (!(tp->tg3_flags &
+	      (TG3_FLAG_USE_LINKCHG_REG |
+	       TG3_FLAG_POLL_SERDES))) {
+		if (sblk->status & SD_STATUS_LINK_CHG) {
+			sblk->status = SD_STATUS_UPDATED |
+				(sblk->status & ~SD_STATUS_LINK_CHG);
+			tg3_setup_phy(tp);
+		}
+	}
+	
+	/* gnbTODO: check locking here */
+
+    	did_pkts = 0;
+	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr) {
+		tg3_rx(tp, 1024);
+		did_pkts = 1;
+	}
+
+	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
+		spin_lock(&tp->tx_lock);
+		tg3_tx(tp);
+		spin_unlock(&tp->tx_lock);
+	}
+
+	if (did_pkts &&
+	    (tp->tg3_flags2 & (TG3_FLG2_ADAPTIVE_RX | TG3_FLG2_ADAPTIVE_TX))) {
+		unsigned long ticks = jiffies - tp->last_rate_sample;
+
+		if (ticks >= tp->coalesce_config.rate_sample_jiffies)
+			tg3_rate_sample(tp, ticks);
+	}
+}
+
+#else /* CONFIG_TIGON3_NAPI */
+
 static int tg3_poll(struct net_device *netdev, int *budget)
 {
 	struct tg3 *tp = netdev->priv;
@@ -2406,6 +2552,8 @@
 	return (done ? 0 : 1);
 }
 
+#endif /* CONFIG_TIGON3_NAPI */
+
 static inline unsigned int tg3_has_work(struct net_device *dev, struct tg3 *tp)
 {
 	struct tg3_hw_status *sblk = tp->hw_status;
@@ -2432,10 +2580,12 @@
 	struct tg3 *tp = dev->priv;
 	struct tg3_hw_status *sblk = tp->hw_status;
 	unsigned long flags;
-	unsigned int handled = 1;
+	unsigned int handled;
 
 	spin_lock_irqsave(&tp->lock, flags);
 
+#ifdef CONFIG_TIGON3_NAPI
+	handled = 1;
 	if (sblk->status & SD_STATUS_UPDATED) {
 		/*
 		 * writing any value to intr-mbox-0 clears PCI INTA# and
@@ -2466,6 +2616,21 @@
 	} else {	/* shared interrupt */
 		handled = 0;
 	}
+#else
+	handled = 0;
+	while (sblk->status & SD_STATUS_UPDATED) {
+		handled = 1;
+		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+			     0x00000001);
+		sblk->status &= ~SD_STATUS_UPDATED;
+
+		tg3_interrupt_main_work(tp);
+
+		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+			     0x00000000);
+		tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
+	}
+#endif
 
 	spin_unlock_irqrestore(&tp->lock, flags);
 
@@ -4894,6 +5059,7 @@
 		udelay(10);
 	}
 
+#ifdef CONFIG_TIGON3_NAPI
 	tw32(HOSTCC_RXCOL_TICKS, 0);
 	tw32(HOSTCC_TXCOL_TICKS, LOW_TXCOL_TICKS);
 	tw32(HOSTCC_RXMAX_FRAMES, 1);
@@ -4904,6 +5070,28 @@
 		tw32(HOSTCC_TXCOAL_TICK_INT, 0);
 	tw32(HOSTCC_RXCOAL_MAXF_INT, 1);
 	tw32(HOSTCC_TXCOAL_MAXF_INT, 0);
+#else /* !CONFIG_TIGON3_NAPI */
+	tw32(HOSTCC_RXCOL_TICKS,
+	     tp->coalesce_config.rx_coalesce_ticks);
+	tw32(HOSTCC_RXMAX_FRAMES,
+	     tp->coalesce_config.rx_max_coalesced_frames);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705)
+		tw32(HOSTCC_RXCOAL_TICK_INT,
+		     tp->coalesce_config.rx_coalesce_ticks_during_int);
+	tw32(HOSTCC_RXCOAL_MAXF_INT,
+	     tp->coalesce_config.rx_max_coalesced_frames_during_int);
+	tw32(HOSTCC_TXCOL_TICKS,
+	     tp->coalesce_config.tx_coalesce_ticks);
+	tw32(HOSTCC_TXMAX_FRAMES,
+	     tp->coalesce_config.tx_max_coalesced_frames);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705)
+		tw32(HOSTCC_TXCOAL_TICK_INT,
+		     tp->coalesce_config.tx_coalesce_ticks_during_int);
+	tw32(HOSTCC_TXCOAL_MAXF_INT,
+	     tp->coalesce_config.tx_max_coalesced_frames_during_int);
+	tw32(HOSTCC_STAT_COAL_TICKS,
+	     tp->coalesce_config.stats_coalesce_ticks);
+#endif /* !CONFIG_TIGON3_NAPI */
 
 	/* set status block DMA address */
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
@@ -5922,8 +6110,13 @@
 	cmd->phy_address = PHY_ADDR;
 	cmd->transceiver = 0;
 	cmd->autoneg = tp->link_config.autoneg;
+#ifdef CONFIG_TIGON3_NAPI
 	cmd->maxtxpkt = 0;
 	cmd->maxrxpkt = 0;
+#else
+	cmd->maxtxpkt = tp->coalesce_config.tx_max_coalesced_frames_def;
+	cmd->maxrxpkt = tp->coalesce_config.rx_max_coalesced_frames_def;
+#endif
 	return 0;
 }
   
@@ -5944,6 +6137,25 @@
 		tp->link_config.duplex = cmd->duplex;
   	}
   
+#ifndef CONFIG_TIGON3_NAPI
+	if (cmd->maxtxpkt || cmd->maxrxpkt) {
+		tp->coalesce_config.tx_max_coalesced_frames_def =
+			tp->coalesce_config.tx_max_coalesced_frames =
+			cmd->maxtxpkt;
+		tp->coalesce_config.rx_max_coalesced_frames_def =
+			tp->coalesce_config.rx_max_coalesced_frames =
+			cmd->maxrxpkt;
+
+		/* Coalescing config bits can be updated without
+		 * a full chip reset.
+		 */
+		tw32(HOSTCC_TXMAX_FRAMES,
+		     tp->coalesce_config.tx_max_coalesced_frames);
+		tw32(HOSTCC_RXMAX_FRAMES,
+		     tp->coalesce_config.rx_max_coalesced_frames);
+	}
+#endif /* !CONFIG_TIGON3_NAPI */
+
 	tg3_setup_phy(tp);
 	spin_unlock(&tp->tx_lock);
 	spin_unlock_irq(&tp->lock);
@@ -6036,7 +6248,186 @@
   
 	return r;
 }
-  
+
+#ifndef CONFIG_TIGON3_NAPI
+static int tg3_get_coalesce(struct net_device *dev,
+			    struct ethtool_coalesce *ecoal)
+{
+	struct tg3 *tp = dev->priv;
+
+	ecoal->rx_coalesce_usecs =
+		tp->coalesce_config.rx_coalesce_ticks_def;
+	ecoal->rx_max_coalesced_frames =
+		tp->coalesce_config.rx_max_coalesced_frames_def;
+	ecoal->rx_coalesce_usecs_irq =
+		tp->coalesce_config.rx_coalesce_ticks_during_int_def;
+	ecoal->rx_max_coalesced_frames_irq =
+		tp->coalesce_config.rx_max_coalesced_frames_during_int_def;
+
+	ecoal->tx_coalesce_usecs =
+		tp->coalesce_config.tx_coalesce_ticks_def;
+	ecoal->tx_max_coalesced_frames =
+		tp->coalesce_config.tx_max_coalesced_frames_def;
+	ecoal->tx_coalesce_usecs_irq =
+		tp->coalesce_config.tx_coalesce_ticks_during_int_def;
+	ecoal->tx_max_coalesced_frames_irq =
+		tp->coalesce_config.tx_max_coalesced_frames_during_int_def;
+
+	ecoal->stats_block_coalesce_usecs =
+		tp->coalesce_config.stats_coalesce_ticks_def;
+
+	ecoal->use_adaptive_rx_coalesce =
+		(tp->tg3_flags2 & TG3_FLG2_ADAPTIVE_RX) != 0;
+	ecoal->use_adaptive_tx_coalesce =
+		(tp->tg3_flags2 & TG3_FLG2_ADAPTIVE_TX) != 0;
+
+	ecoal->pkt_rate_low =
+		tp->coalesce_config.pkt_rate_low;
+	ecoal->rx_coalesce_usecs_low =
+		tp->coalesce_config.rx_coalesce_ticks_low;
+	ecoal->rx_max_coalesced_frames_low =
+		tp->coalesce_config.rx_max_coalesced_frames_low;
+	ecoal->tx_coalesce_usecs_low =
+		tp->coalesce_config.tx_coalesce_ticks_low;
+	ecoal->tx_max_coalesced_frames_low =
+		tp->coalesce_config.tx_max_coalesced_frames_low;
+
+	ecoal->pkt_rate_high =
+		tp->coalesce_config.pkt_rate_high;
+	ecoal->rx_coalesce_usecs_high =
+		tp->coalesce_config.rx_coalesce_ticks_high;
+	ecoal->rx_max_coalesced_frames_high =
+		tp->coalesce_config.rx_max_coalesced_frames_high;
+	ecoal->tx_coalesce_usecs_high =
+		tp->coalesce_config.tx_coalesce_ticks_high;
+	ecoal->tx_max_coalesced_frames_high =
+		tp->coalesce_config.tx_max_coalesced_frames_high;
+
+	ecoal->rate_sample_interval =
+		tp->coalesce_config.rate_sample_jiffies / HZ;
+
+	return 0;
+}
+
+static int tg3_set_coalesce(struct net_device *dev,
+			    struct ethtool_coalesce *ecoal)
+{
+	struct tg3 *tp = dev->priv;
+
+	/* Make sure we are not getting garbage. */
+	if ((ecoal->rx_coalesce_usecs == 0 &&
+	     ecoal->rx_max_coalesced_frames == 0) ||
+	    (ecoal->tx_coalesce_usecs == 0 &&
+	     ecoal->tx_max_coalesced_frames == 0) ||
+	    ecoal->stats_block_coalesce_usecs == 0)
+		return -EINVAL;
+	if (ecoal->use_adaptive_rx_coalesce ||
+	    ecoal->use_adaptive_tx_coalesce) {
+		if (ecoal->pkt_rate_low > ecoal->pkt_rate_high)
+			return -EINVAL;
+		if (ecoal->rate_sample_interval == 0)
+			return -EINVAL;
+		if (ecoal->use_adaptive_rx_coalesce &&
+		    ((ecoal->rx_coalesce_usecs_low == 0 &&
+		      ecoal->rx_max_coalesced_frames_low == 0) ||
+		     (ecoal->rx_coalesce_usecs_high == 0 &&
+		      ecoal->rx_max_coalesced_frames_high == 0)))
+			return -EINVAL;
+		if (ecoal->use_adaptive_tx_coalesce &&
+		    ((ecoal->tx_coalesce_usecs_low == 0 &&
+		      ecoal->tx_max_coalesced_frames_low == 0) ||
+		     (ecoal->tx_coalesce_usecs_high == 0 &&
+		      ecoal->tx_max_coalesced_frames_high == 0)))
+			return -EINVAL;
+	}
+
+	/* Looks good, let it rip. */
+	spin_lock_irq(&tp->lock);
+	tp->coalesce_config.rx_coalesce_ticks =
+		tp->coalesce_config.rx_coalesce_ticks_def =
+		ecoal->rx_coalesce_usecs;
+	tp->coalesce_config.rx_max_coalesced_frames =
+		tp->coalesce_config.rx_max_coalesced_frames_def =
+		ecoal->rx_max_coalesced_frames;
+	tp->coalesce_config.rx_coalesce_ticks_during_int =
+		tp->coalesce_config.rx_coalesce_ticks_during_int_def =
+		ecoal->rx_coalesce_usecs_irq;
+	tp->coalesce_config.rx_max_coalesced_frames_during_int =
+		tp->coalesce_config.rx_max_coalesced_frames_during_int_def =
+		ecoal->rx_max_coalesced_frames_irq;
+	tp->coalesce_config.tx_coalesce_ticks =
+		tp->coalesce_config.tx_coalesce_ticks_def =
+		ecoal->tx_coalesce_usecs;
+	tp->coalesce_config.tx_max_coalesced_frames =
+		tp->coalesce_config.tx_max_coalesced_frames_def =
+		ecoal->tx_max_coalesced_frames;
+	tp->coalesce_config.tx_coalesce_ticks_during_int =
+		tp->coalesce_config.tx_coalesce_ticks_during_int_def =
+		ecoal->tx_coalesce_usecs_irq;
+	tp->coalesce_config.tx_max_coalesced_frames_during_int =
+		tp->coalesce_config.tx_max_coalesced_frames_during_int_def =
+		ecoal->tx_max_coalesced_frames_irq;
+	tp->coalesce_config.stats_coalesce_ticks =
+		tp->coalesce_config.stats_coalesce_ticks_def =
+		ecoal->stats_block_coalesce_usecs;
+
+	if (ecoal->use_adaptive_rx_coalesce)
+		tp->tg3_flags2 |= TG3_FLG2_ADAPTIVE_RX;
+	else
+		tp->tg3_flags2 &= ~TG3_FLG2_ADAPTIVE_RX;
+	if (ecoal->use_adaptive_tx_coalesce)
+		tp->tg3_flags2 |= TG3_FLG2_ADAPTIVE_TX;
+	else
+		tp->tg3_flags2 &= ~TG3_FLG2_ADAPTIVE_TX;
+
+	tp->coalesce_config.pkt_rate_low = ecoal->pkt_rate_low;
+	tp->coalesce_config.pkt_rate_high = ecoal->pkt_rate_high;
+	tp->coalesce_config.rate_sample_jiffies =
+		ecoal->rate_sample_interval * HZ;
+
+	tp->coalesce_config.rx_coalesce_ticks_low =
+		ecoal->rx_coalesce_usecs_low;
+	tp->coalesce_config.rx_max_coalesced_frames_low =
+		ecoal->rx_max_coalesced_frames_low;
+	tp->coalesce_config.tx_coalesce_ticks_low =
+		ecoal->tx_coalesce_usecs_low;
+	tp->coalesce_config.tx_max_coalesced_frames_low =
+		ecoal->tx_max_coalesced_frames_low;
+
+	tp->coalesce_config.rx_coalesce_ticks_high =
+		ecoal->rx_coalesce_usecs_high;
+	tp->coalesce_config.rx_max_coalesced_frames_high =
+		ecoal->rx_max_coalesced_frames_high;
+	tp->coalesce_config.tx_coalesce_ticks_high =
+		ecoal->tx_coalesce_usecs_high;
+	tp->coalesce_config.tx_max_coalesced_frames_high =
+		ecoal->tx_max_coalesced_frames_high;
+
+	tw32(HOSTCC_RXCOL_TICKS,
+	     tp->coalesce_config.rx_coalesce_ticks_def);
+	tw32(HOSTCC_RXMAX_FRAMES,
+	     tp->coalesce_config.rx_max_coalesced_frames_def);
+	tw32(HOSTCC_RXCOAL_TICK_INT,
+	     tp->coalesce_config.rx_coalesce_ticks_during_int_def);
+	tw32(HOSTCC_RXCOAL_MAXF_INT,
+	     tp->coalesce_config.rx_max_coalesced_frames_during_int_def);
+	tw32(HOSTCC_TXCOL_TICKS,
+	     tp->coalesce_config.tx_coalesce_ticks_def);
+	tw32(HOSTCC_TXMAX_FRAMES,
+	     tp->coalesce_config.tx_max_coalesced_frames_def);
+	tw32(HOSTCC_TXCOAL_TICK_INT,
+	     tp->coalesce_config.tx_coalesce_ticks_during_int_def);
+	tw32(HOSTCC_TXCOAL_MAXF_INT,
+	     tp->coalesce_config.tx_max_coalesced_frames_during_int_def);
+	tw32(HOSTCC_STAT_COAL_TICKS,
+	     tp->coalesce_config.stats_coalesce_ticks_def);
+
+	spin_unlock_irq(&tp->lock);
+
+	return 0;
+}
+#endif /* !CONFIG_TIGON3_NAPI */
+
 static void tg3_get_ringparam(struct net_device *dev, struct ethtool_ringparam
*ering)
 {
 	struct tg3 *tp = dev->priv;
@@ -6245,6 +6636,10 @@
 	.set_msglevel		= tg3_set_msglevel,
 	.nway_reset		= tg3_nway_reset,
 	.get_link		= ethtool_op_get_link,
+#ifndef CONFIG_TIGON3_NAPI
+	.get_coalesce		= tg3_get_coalesce,
+	.set_coalesce		= tg3_set_coalesce,
+#endif
 	.get_ringparam		= tg3_get_ringparam,
 	.set_ringparam		= tg3_set_ringparam,
 	.get_pauseparam		= tg3_get_pauseparam,
@@ -6889,6 +7284,7 @@
 	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A1)))
 		tp->tg3_flags2 |= TG3_FLG2_NO_ETH_WIRE_SPEED;
 
+#ifdef CONFIG_TIGON3_NAPI
 	/* Only 5701 and later support tagged irq status mode.
 	 * Also, 5788 chips cannot use tagged irq status.
 	 *
@@ -6897,6 +7293,10 @@
 	 * fully clear in that mode.
 	 */
 	tp->coalesce_mode = 0;
+#else
+	tp->coalesce_mode = (HOSTCC_MODE_CLRTICK_RXBD |
+			     HOSTCC_MODE_CLRTICK_TXBD);
+#endif
 
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_AX &&
 	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_BX)
@@ -7424,6 +7824,63 @@
 	tp->link_config.orig_autoneg = AUTONEG_INVALID;
 }
 
+#ifndef CONFIG_TIGON3_NAPI
+static void __devinit tg3_init_coalesce_config(struct tg3 *tp)
+{
+	tp->coalesce_config.rx_coalesce_ticks_def = DEFAULT_RXCOL_TICKS;
+	tp->coalesce_config.rx_max_coalesced_frames_def = DEFAULT_RXMAX_FRAMES;
+	tp->coalesce_config.rx_coalesce_ticks_during_int_def =
+		DEFAULT_RXCOAL_TICK_INT;
+	tp->coalesce_config.rx_max_coalesced_frames_during_int_def =
+		DEFAULT_RXCOAL_MAXF_INT;
+	tp->coalesce_config.tx_coalesce_ticks_def = DEFAULT_TXCOL_TICKS;
+	tp->coalesce_config.tx_max_coalesced_frames_def = DEFAULT_TXMAX_FRAMES;
+	tp->coalesce_config.tx_coalesce_ticks_during_int_def =
+		DEFAULT_TXCOAL_TICK_INT;
+	tp->coalesce_config.tx_max_coalesced_frames_during_int_def =
+		DEFAULT_TXCOAL_MAXF_INT;
+	tp->coalesce_config.stats_coalesce_ticks_def =
+		DEFAULT_STAT_COAL_TICKS;
+
+	tp->coalesce_config.rx_coalesce_ticks_low =
+		LOW_RXCOL_TICKS;
+	tp->coalesce_config.rx_max_coalesced_frames_low =
+		LOW_RXMAX_FRAMES;
+	tp->coalesce_config.tx_coalesce_ticks_low =
+		LOW_TXCOL_TICKS;
+	tp->coalesce_config.tx_max_coalesced_frames_low =
+		LOW_TXMAX_FRAMES;
+
+	tp->coalesce_config.rx_coalesce_ticks_high =
+		HIGH_RXCOL_TICKS;
+	tp->coalesce_config.rx_max_coalesced_frames_high =
+		HIGH_RXMAX_FRAMES;
+	tp->coalesce_config.tx_coalesce_ticks_high =
+		HIGH_TXCOL_TICKS;
+	tp->coalesce_config.tx_max_coalesced_frames_high =
+		HIGH_TXMAX_FRAMES;
+
+	/* Active == default */
+	tp->coalesce_config.rx_coalesce_ticks =
+		tp->coalesce_config.rx_coalesce_ticks_def;
+	tp->coalesce_config.rx_max_coalesced_frames =
+		tp->coalesce_config.rx_max_coalesced_frames_def;
+	tp->coalesce_config.tx_coalesce_ticks =
+		tp->coalesce_config.tx_coalesce_ticks_def;
+	tp->coalesce_config.tx_max_coalesced_frames =
+		tp->coalesce_config.tx_max_coalesced_frames_def;
+	tp->coalesce_config.stats_coalesce_ticks =
+		tp->coalesce_config.stats_coalesce_ticks_def;
+
+	tp->coalesce_config.rate_sample_jiffies = (1 * HZ);
+	tp->coalesce_config.pkt_rate_low = 22000;
+	tp->coalesce_config.pkt_rate_high = 61000;
+
+	tp->tg3_flags2 |= TG3_FLG2_ADAPTIVE_RX;
+	tp->tg3_flags2 &= ~(TG3_FLG2_ADAPTIVE_TX);
+}
+#endif /* !CONFIG_TIGON3_NAPI */
+
 static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 {
 	tp->bufmgr_config.mbuf_read_dma_low_water =
@@ -7613,6 +8070,10 @@
 
 	tg3_init_link_config(tp);
 
+#ifndef CONFIG_TIGON3_NAPI
+	tg3_init_coalesce_config(tp);
+#endif /* !CONFIG_TIGON3_NAPI */
+
 	tg3_init_bufmgr_config(tp);
 
 	tp->rx_pending = TG3_DEF_RX_RING_PENDING;
@@ -7626,9 +8087,11 @@
 	dev->set_mac_address = tg3_set_mac_addr;
 	dev->do_ioctl = tg3_ioctl;
 	dev->tx_timeout = tg3_tx_timeout;
-	dev->poll = tg3_poll;
 	dev->ethtool_ops = &tg3_ethtool_ops;
+#ifdef CONFIG_TIGON3_NAPI
+	dev->poll = tg3_poll;
 	dev->weight = 64;
+#endif /* CONFIG_TIGON3_NAPI */
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
@@ -7718,7 +8181,7 @@
 	 */
 	pci_save_state(tp->pdev, tp->pci_cfg_state);
 
-	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] (PCI%s:%s:%s) %sBaseT
Ethernet ",
+	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] (PCI%s:%s:%s) %sBaseT
Ethernet (%s) ",
 	       dev->name,
 	       tp->board_part_number,
 	       tp->pci_chip_rev_id,
@@ -7728,7 +8191,13 @@
 		((tp->tg3_flags & TG3_FLAG_PCIX_MODE) ? "133MHz" : "66MHz") :
 		((tp->tg3_flags & TG3_FLAG_PCIX_MODE) ? "100MHz" : "33MHz")),
 	       ((tp->tg3_flags & TG3_FLAG_PCI_32BIT) ? "32-bit" : "64-bit"),
-	       (tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100" : "10/100/1000");
+	       (tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100" : "10/100/1000",
+#ifdef CONFIG_TIGON3_NAPI
+	        "NAPI"
+#else
+		"no NAPI"
+#endif
+	       );
 
 	for (i = 0; i < 6; i++)
 		printk("%2.2x%c", dev->dev_addr[i],

===========================================================================
linux/drivers/net/tg3.h
===========================================================================

--- /usr/tmp/TmpDir.26498-0/linux/drivers/net/tg3.h_1.9	Tue Nov 11 12:38:57 2003
+++ linux/drivers/net/tg3.h	Tue Nov 11 12:38:24 2003
@@ -1801,6 +1801,47 @@
 	u8				orig_autoneg;
 };
 
+#ifndef CONFIG_TIGON3_NAPI
+struct tg3_coalesce_config {
+	/* Current settings. */
+	u32		rx_coalesce_ticks;
+	u32		rx_max_coalesced_frames;
+	u32		rx_coalesce_ticks_during_int;
+	u32		rx_max_coalesced_frames_during_int;
+	u32		tx_coalesce_ticks;
+	u32		tx_max_coalesced_frames;
+	u32		tx_coalesce_ticks_during_int;
+	u32		tx_max_coalesced_frames_during_int;
+	u32		stats_coalesce_ticks;
+
+	/* Default settings. */
+	u32		rx_coalesce_ticks_def;
+	u32		rx_max_coalesced_frames_def;
+	u32		rx_coalesce_ticks_during_int_def;
+	u32		rx_max_coalesced_frames_during_int_def;
+	u32		tx_coalesce_ticks_def;
+	u32		tx_max_coalesced_frames_def;
+	u32		tx_coalesce_ticks_during_int_def;
+	u32		tx_max_coalesced_frames_during_int_def;
+	u32		stats_coalesce_ticks_def;
+
+	/* Adaptive RX/TX coalescing parameters. */
+	u32		rate_sample_jiffies;
+	u32		pkt_rate_low;
+	u32		pkt_rate_high;
+
+	u32		rx_coalesce_ticks_low;
+	u32		rx_max_coalesced_frames_low;
+	u32		tx_coalesce_ticks_low;
+	u32		tx_max_coalesced_frames_low;
+
+	u32		rx_coalesce_ticks_high;
+	u32		rx_max_coalesced_frames_high;
+	u32		tx_coalesce_ticks_high;
+	u32		tx_max_coalesced_frames_high;
+};
+#endif /* !CONFIG_TIGON3_NAPI */
+
 struct tg3_bufmgr_config {
 	u32		mbuf_read_dma_low_water;
 	u32		mbuf_mac_rx_low_water;
@@ -1879,6 +1920,13 @@
 	struct net_device_stats		net_stats_prev;
 	unsigned long			phy_crc_errors;
 
+#ifndef CONFIG_TIGON3_NAPI
+	/* Adaptive coalescing engine. */
+	unsigned long			last_rate_sample;
+	u32				last_rx_count;
+	u32				last_tx_count;
+#endif /* !CONFIG_TIGON3_NAPI */
+
 	u32				rx_offset;
 	u32				tg3_flags;
 #define TG3_FLAG_HOST_TXDS		0x00000001
@@ -1920,6 +1968,8 @@
 #define TG3_FLG2_IS_5788		0x00000008
 #define TG3_FLG2_MAX_RXPEND_64		0x00000010
 #define TG3_FLG2_TSO_CAPABLE		0x00000020
+#define TG3_FLG2_ADAPTIVE_RX		0x00000040
+#define TG3_FLG2_ADAPTIVE_TX		0x00000080
 
 	u32				split_mode_max_reqs;
 #define SPLIT_MODE_5704_MAX_REQ		3
@@ -1932,6 +1982,9 @@
 	u16				asf_multiplier;
 
 	struct tg3_link_config		link_config;
+#ifndef CONFIG_TIGON3_NAPI
+	struct tg3_coalesce_config	coalesce_config;
+#endif /* !CONFIG_TIGON3_NAPI */
 	struct tg3_bufmgr_config	bufmgr_config;
 
 	/* cache h/w values, often passed straight to h/w */



Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
