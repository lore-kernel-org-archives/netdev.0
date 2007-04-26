From: akpm@linux-foundation.org
Subject: [patch 08/11] add NAPI support to sb1250-mac.c
Date: Thu, 26 Apr 2007 00:23:22 -0700
Message-ID: <200704260723.l3Q7NNAV023841@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	mmason@upwardaccess.com, mason@broadcom.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:56503 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933330AbXDZHYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:24:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Mason <mmason@upwardaccess.com>

Patch to add NAPI support to sb1250-mac.c (rev 2).  This patch differs from
the last in that the NAPI support isn't marked as experimental, nor is it
configurable (ie.  once applied - NAPI is enabled all the time).  This was
based on feedback from Ralf and others.

Signed-off-by: Mark Mason <mason@broadcom.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sb1250-mac.c |  273 ++++++++++++++++++++++++-------------
 1 file changed, 180 insertions(+), 93 deletions(-)

diff -puN drivers/net/sb1250-mac.c~add-napi-support-to-sb1250-macc-take-2 drivers/net/sb1250-mac.c
--- a/drivers/net/sb1250-mac.c~add-napi-support-to-sb1250-macc-take-2
+++ a/drivers/net/sb1250-mac.c
@@ -95,19 +95,28 @@ MODULE_PARM_DESC(full_duplex, "1-" __MOD
 #endif
 
 #ifdef CONFIG_SBMAC_COALESCE
-static int int_pktcnt = 0;
-module_param(int_pktcnt, int, S_IRUGO);
-MODULE_PARM_DESC(int_pktcnt, "Packet count");
-
-static int int_timeout = 0;
-module_param(int_timeout, int, S_IRUGO);
-MODULE_PARM_DESC(int_timeout, "Timeout value");
+static int int_pktcnt_tx = 255;
+module_param(int_pktcnt_tx, int, S_IRUGO);
+MODULE_PARM_DESC(int_pktcnt_tx, "TX packet count");
+
+static int int_timeout_tx = 255;
+module_param(int_timeout_tx, int, S_IRUGO);
+MODULE_PARM_DESC(int_timeout_tx, "TX timeout value");
+
+static int int_pktcnt_rx = 64;
+module_param(int_pktcnt_rx, int, S_IRUGO);
+MODULE_PARM_DESC(int_pktcnt_rx, "RX packet count");
+
+static int int_timeout_rx = 64;
+module_param(int_timeout_rx, int, S_IRUGO);
+MODULE_PARM_DESC(int_timeout_rx, "RX timeout value");
 #endif
 
 #include <asm/sibyte/sb1250.h>
 #if defined(CONFIG_SIBYTE_BCM1x55) || defined(CONFIG_SIBYTE_BCM1x80)
 #include <asm/sibyte/bcm1480_regs.h>
 #include <asm/sibyte/bcm1480_int.h>
+#define R_MAC_DMA_OODPKTLOST_RX	R_MAC_DMA_OODPKTLOST
 #elif defined(CONFIG_SIBYTE_SB1250) || defined(CONFIG_SIBYTE_BCM112X)
 #include <asm/sibyte/sb1250_regs.h>
 #include <asm/sibyte/sb1250_int.h>
@@ -155,8 +164,8 @@ typedef enum { sbmac_state_uninit, sbmac
 
 #define NUMCACHEBLKS(x) (((x)+SMP_CACHE_BYTES-1)/SMP_CACHE_BYTES)
 
-#define SBMAC_MAX_TXDESCR	32
-#define SBMAC_MAX_RXDESCR	32
+#define SBMAC_MAX_TXDESCR	256
+#define SBMAC_MAX_RXDESCR	256
 
 #define ETHER_ALIGN	2
 #define ETHER_ADDR_LEN	6
@@ -185,10 +194,10 @@ typedef struct sbmacdma_s {
 	 * associated with it.
 	 */
 
-	struct sbmac_softc *sbdma_eth;	        /* back pointer to associated MAC */
-	int              sbdma_channel;	/* channel number */
+	struct sbmac_softc *sbdma_eth;	    /* back pointer to associated MAC */
+	int              sbdma_channel;	    /* channel number */
 	int		 sbdma_txdir;       /* direction (1=transmit) */
-	int		 sbdma_maxdescr;	/* total # of descriptors in ring */
+	int		 sbdma_maxdescr;    /* total # of descriptors in ring */
 #ifdef CONFIG_SBMAC_COALESCE
 	int		 sbdma_int_pktcnt;  /* # descriptors rx/tx before interrupt*/
 	int		 sbdma_int_timeout; /* # usec rx/tx interrupt */
@@ -197,13 +206,16 @@ typedef struct sbmacdma_s {
 	volatile void __iomem *sbdma_config0;	/* DMA config register 0 */
 	volatile void __iomem *sbdma_config1;	/* DMA config register 1 */
 	volatile void __iomem *sbdma_dscrbase;	/* Descriptor base address */
-	volatile void __iomem *sbdma_dscrcnt;     /* Descriptor count register */
+	volatile void __iomem *sbdma_dscrcnt;   /* Descriptor count register */
 	volatile void __iomem *sbdma_curdscr;	/* current descriptor address */
+	volatile void __iomem *sbdma_oodpktlost;/* pkt drop (rx only) */
+
 
 	/*
 	 * This stuff is for maintenance of the ring
 	 */
 
+	sbdmadscr_t     *sbdma_dscrtable_unaligned;
 	sbdmadscr_t     *sbdma_dscrtable;	/* base of descriptor table */
 	sbdmadscr_t     *sbdma_dscrtable_end; /* end of descriptor table */
 
@@ -286,8 +298,8 @@ static int sbdma_add_rcvbuffer(sbmacdma_
 static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *m);
 static void sbdma_emptyring(sbmacdma_t *d);
 static void sbdma_fillring(sbmacdma_t *d);
-static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d);
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d);
+static int sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d, int work_to_do, int poll);
+static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int poll);
 static int sbmac_initctx(struct sbmac_softc *s);
 static void sbmac_channel_start(struct sbmac_softc *s);
 static void sbmac_channel_stop(struct sbmac_softc *s);
@@ -308,6 +320,8 @@ static struct net_device_stats *sbmac_ge
 static void sbmac_set_rx_mode(struct net_device *dev);
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int sbmac_close(struct net_device *dev);
+static int sbmac_poll(struct net_device *poll_dev, int *budget);
+
 static int sbmac_mii_poll(struct sbmac_softc *s,int noisy);
 static int sbmac_mii_probe(struct net_device *dev);
 
@@ -679,6 +693,10 @@ static void sbdma_initctx(sbmacdma_t *d,
 			  int txrx,
 			  int maxdescr)
 {
+#ifdef CONFIG_SBMAC_COALESCE
+	int int_pktcnt, int_timeout;
+#endif
+
 	/*
 	 * Save away interesting stuff in the structure
 	 */
@@ -728,6 +746,11 @@ static void sbdma_initctx(sbmacdma_t *d,
 		s->sbm_base + R_MAC_DMA_REGISTER(txrx,chan,R_MAC_DMA_DSCR_CNT);
 	d->sbdma_curdscr =
 		s->sbm_base + R_MAC_DMA_REGISTER(txrx,chan,R_MAC_DMA_CUR_DSCRADDR);
+	if (d->sbdma_txdir)
+		d->sbdma_oodpktlost = NULL;
+	else
+		d->sbdma_oodpktlost =
+			s->sbm_base + R_MAC_DMA_REGISTER(txrx,chan,R_MAC_DMA_OODPKTLOST_RX);
 
 	/*
 	 * Allocate memory for the ring
@@ -735,6 +758,7 @@ static void sbdma_initctx(sbmacdma_t *d,
 
 	d->sbdma_maxdescr = maxdescr;
 
+	d->sbdma_dscrtable_unaligned =
 	d->sbdma_dscrtable = (sbdmadscr_t *)
 		kmalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
 
@@ -765,12 +789,14 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 * Setup Rx/Tx DMA coalescing defaults
 	 */
 
+	int_pktcnt = (txrx == DMA_TX) ? int_pktcnt_tx : int_pktcnt_rx;
 	if ( int_pktcnt ) {
 		d->sbdma_int_pktcnt = int_pktcnt;
 	} else {
 		d->sbdma_int_pktcnt = 1;
 	}
 
+	int_timeout = (txrx == DMA_TX) ? int_timeout_tx : int_timeout_rx;
 	if ( int_timeout ) {
 		d->sbdma_int_timeout = int_timeout;
 	} else {
@@ -1150,30 +1176,41 @@ static void sbmac_netpoll(struct net_dev
 #endif
 
 /**********************************************************************
- *  SBDMA_RX_PROCESS(sc,d)
+ *  SBDMA_RX_PROCESS(sc,d,work_to_do,poll)
  *
  *  Process "completed" receive buffers on the specified DMA channel.
- *  Note that this isn't really ideal for priority channels, since
- *  it processes all of the packets on a given channel before
- *  returning.
  *
  *  Input parameters:
- *	   sc - softc structure
- *  	   d - DMA channel context
+ *            sc - softc structure
+ *  	       d - DMA channel context
+ *    work_to_do - no. of packets to process before enabling interrupt
+ *                 again (for NAPI)
+ *          poll - 1: using polling (for NAPI)
  *
  *  Return value:
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d)
+static int sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d,
+                             int work_to_do, int poll)
 {
 	int curidx;
 	int hwidx;
 	sbdmadscr_t *dsc;
 	struct sk_buff *sb;
 	int len;
+	int work_done = 0;
+	int dropped = 0;
 
-	for (;;) {
+	prefetch(d);
+
+again:
+	/* Check if the HW dropped any frames */
+	sc->sbm_stats.rx_fifo_errors
+	    += __raw_readq(sc->sbm_rxdma.sbdma_oodpktlost) & 0xffff;
+	__raw_writeq(0, sc->sbm_rxdma.sbdma_oodpktlost);
+
+	while (work_to_do-- > 0) {
 		/*
 		 * figure out where we are (as an index) and where
 		 * the hardware is (also as an index)
@@ -1185,7 +1222,12 @@ static void sbdma_rx_process(struct sbma
 		 * (sbdma_remptr) and the physical address (sbdma_curdscr CSR)
 		 */
 
-		curidx = d->sbdma_remptr - d->sbdma_dscrtable;
+		dsc = d->sbdma_remptr;
+		curidx = dsc - d->sbdma_dscrtable;
+
+		prefetch(dsc);
+		prefetch(&d->sbdma_ctxtable[curidx]);
+
 		hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
 				d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
 
@@ -1196,13 +1238,12 @@ static void sbdma_rx_process(struct sbma
 		 */
 
 		if (curidx == hwidx)
-			break;
+			goto done;
 
 		/*
 		 * Otherwise, get the packet's sk_buff ptr back
 		 */
 
-		dsc = &(d->sbdma_dscrtable[curidx]);
 		sb = d->sbdma_ctxtable[curidx];
 		d->sbdma_ctxtable[curidx] = NULL;
 
@@ -1214,7 +1255,7 @@ static void sbdma_rx_process(struct sbma
 		 * receive ring.
 		 */
 
-		if (!(dsc->dscr_a & M_DMA_ETHRX_BAD)) {
+		if (likely (!(dsc->dscr_a & M_DMA_ETHRX_BAD))) {
 
 			/*
 			 * Add a new buffer to replace the old one.  If we fail
@@ -1222,9 +1263,14 @@ static void sbdma_rx_process(struct sbma
 			 * packet and put it right back on the receive ring.
 			 */
 
-			if (sbdma_add_rcvbuffer(d,NULL) == -ENOBUFS) {
-				sc->sbm_stats.rx_dropped++;
+			if (unlikely (sbdma_add_rcvbuffer(d,NULL) ==
+				      -ENOBUFS)) {
+ 				sc->sbm_stats.rx_dropped++;
 				sbdma_add_rcvbuffer(d,sb); /* re-add old buffer */
+				/* No point in continuing at the moment */
+				printk(KERN_ERR "dropped packet (1)\n");
+				d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
+				goto done;
 			} else {
 				/*
 				 * Set length into the packet
@@ -1236,8 +1282,6 @@ static void sbdma_rx_process(struct sbma
 				 * receive ring.  Pass the buffer to
 				 * the kernel
 				 */
-				sc->sbm_stats.rx_bytes += len;
-				sc->sbm_stats.rx_packets++;
 				sb->protocol = eth_type_trans(sb,d->sbdma_eth->sbm_dev);
 				/* Check hw IPv4/TCP checksum if supported */
 				if (sc->rx_hw_checksum == ENABLE) {
@@ -1249,8 +1293,22 @@ static void sbdma_rx_process(struct sbma
 						sb->ip_summed = CHECKSUM_NONE;
 					}
 				}
-
-				netif_rx(sb);
+				prefetch(sb->data);
+				prefetch((const void *)(((char *)sb->data)+32));
+				if (poll)
+					dropped = netif_receive_skb(sb);
+				else
+					dropped = netif_rx(sb);
+
+				if (dropped == NET_RX_DROP) {
+					sc->sbm_stats.rx_dropped++;
+					d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
+					goto done;
+				}
+				else {
+					sc->sbm_stats.rx_bytes += len;
+					sc->sbm_stats.rx_packets++;
+				}
 			}
 		} else {
 			/*
@@ -1267,12 +1325,16 @@ static void sbdma_rx_process(struct sbma
 		 */
 
 		d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
-
+		work_done++;
+	}
+	if (!poll) {
+		work_to_do = 32;
+		goto again; /* collect fifo drop statistics again */
 	}
+done:
+	return work_done;
 }
 
-
-
 /**********************************************************************
  *  SBDMA_TX_PROCESS(sc,d)
  *
@@ -1284,22 +1346,30 @@ static void sbdma_rx_process(struct sbma
  *
  *  Input parameters:
  *      sc - softc structure
- *  	   d - DMA channel context
+ *  	 d - DMA channel context
+ *    poll - 1: using polling (for NAPI)
  *
  *  Return value:
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d)
+static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int poll)
 {
 	int curidx;
 	int hwidx;
 	sbdmadscr_t *dsc;
 	struct sk_buff *sb;
 	unsigned long flags;
+	int packets_handled = 0;
 
 	spin_lock_irqsave(&(sc->sbm_lock), flags);
 
+	if (d->sbdma_remptr == d->sbdma_addptr)
+	  goto end_unlock;
+
+	hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
+			d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
+
 	for (;;) {
 		/*
 		 * figure out where we are (as an index) and where
@@ -1313,8 +1383,6 @@ static void sbdma_tx_process(struct sbma
 		 */
 
 		curidx = d->sbdma_remptr - d->sbdma_dscrtable;
-		hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
-				d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
 
 		/*
 		 * If they're the same, that means we've processed all
@@ -1352,6 +1420,8 @@ static void sbdma_tx_process(struct sbma
 
 		d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
 
+		packets_handled++;
+
 	}
 
 	/*
@@ -1360,8 +1430,10 @@ static void sbdma_tx_process(struct sbma
 	 * watermark on the transmit queue.
 	 */
 
-	netif_wake_queue(d->sbdma_eth->sbm_dev);
+	if (packets_handled)
+		netif_wake_queue(d->sbdma_eth->sbm_dev);
 
+end_unlock:
 	spin_unlock_irqrestore(&(sc->sbm_lock), flags);
 
 }
@@ -1435,9 +1507,9 @@ static int sbmac_initctx(struct sbmac_so
 
 static void sbdma_uninitctx(struct sbmacdma_s *d)
 {
-	if (d->sbdma_dscrtable) {
-		kfree(d->sbdma_dscrtable);
-		d->sbdma_dscrtable = NULL;
+	if (d->sbdma_dscrtable_unaligned) {
+		kfree(d->sbdma_dscrtable_unaligned);
+		d->sbdma_dscrtable_unaligned = d->sbdma_dscrtable = NULL;
 	}
 
 	if (d->sbdma_ctxtable) {
@@ -1635,15 +1707,9 @@ static void sbmac_channel_start(struct s
 #endif
 
 #ifdef CONFIG_SBMAC_COALESCE
-	/*
-	 * Accept any TX interrupt and EOP count/timer RX interrupts on ch 0
-	 */
 	__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
 		       ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_RX_CH0), s->sbm_imr);
 #else
-	/*
-	 * Accept any kind of interrupt on TX and RX DMA channel 0
-	 */
 	__raw_writeq((M_MAC_INT_CHANNEL << S_MAC_TX_CH0) |
 		       (M_MAC_INT_CHANNEL << S_MAC_RX_CH0), s->sbm_imr);
 #endif
@@ -2076,57 +2142,46 @@ static irqreturn_t sbmac_intr(int irq,vo
 	uint64_t isr;
 	int handled = 0;
 
-	for (;;) {
-
-		/*
-		 * Read the ISR (this clears the bits in the real
-		 * register, except for counter addr)
-		 */
+	/*
+	 * Read the ISR (this clears the bits in the real
+	 * register, except for counter addr)
+	 */
 
-		isr = __raw_readq(sc->sbm_isr) & ~M_MAC_COUNTER_ADDR;
+	isr = __raw_readq(sc->sbm_isr) & ~M_MAC_COUNTER_ADDR;
 
-		if (isr == 0)
-			break;
+	if (isr == 0)
+		return IRQ_RETVAL(0);
+	handled = 1;
 
-		handled = 1;
-
-		/*
-		 * Transmits on channel 0
-		 */
+	/*
+	 * Transmits on channel 0
+	 */
 
-		if (isr & (M_MAC_INT_CHANNEL << S_MAC_TX_CH0)) {
-			sbdma_tx_process(sc,&(sc->sbm_txdma));
+	if (isr & (M_MAC_INT_CHANNEL << S_MAC_TX_CH0)) {
+		sbdma_tx_process(sc,&(sc->sbm_txdma), 0);
+#ifdef CONFIG_NETPOLL_TRAP
+		if (netpoll_trap()) {
+			if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state))
+				__netif_schedule(dev);
 		}
+#endif
+	}
 
-		/*
-		 * Receives on channel 0
-		 */
-
-		/*
-		 * It's important to test all the bits (or at least the
-		 * EOP_SEEN bit) when deciding to do the RX process
-		 * particularly when coalescing, to make sure we
-		 * take care of the following:
-		 *
-		 * If you have some packets waiting (have been received
-		 * but no interrupt) and get a TX interrupt before
-		 * the RX timer or counter expires, reading the ISR
-		 * above will clear the timer and counter, and you
-		 * won't get another interrupt until a packet shows
-		 * up to start the timer again.  Testing
-		 * EOP_SEEN here takes care of this case.
-		 * (EOP_SEEN is part of M_MAC_INT_CHANNEL << S_MAC_RX_CH0)
-		 */
-
-
-		if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
-			sbdma_rx_process(sc,&(sc->sbm_rxdma));
+	if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
+		if (netif_rx_schedule_prep(dev)) {
+			__raw_writeq(0, sc->sbm_imr);
+			__netif_rx_schedule(dev);
+			/* Depend on the exit from poll to reenable intr */
+		}
+		else {
+			/* may leave some packets behind */
+			sbdma_rx_process(sc,&(sc->sbm_rxdma),
+					 SBMAC_MAX_RXDESCR * 2, 0);
 		}
 	}
 	return IRQ_RETVAL(handled);
 }
 
-
 /**********************************************************************
  *  SBMAC_START_TX(skb,dev)
  *
@@ -2256,8 +2311,6 @@ static void sbmac_setmulti(struct sbmac_
 	}
 }
 
-
-
 #if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) || defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
 /**********************************************************************
  *  SBMAC_PARSE_XDIGIT(str)
@@ -2420,6 +2473,8 @@ static int sbmac_init(struct net_device 
 	dev->do_ioctl           = sbmac_mii_ioctl;
 	dev->tx_timeout         = sbmac_tx_timeout;
 	dev->watchdog_timeo     = TX_TIMEOUT;
+	dev->poll               = sbmac_poll;
+	dev->weight             = 16;
 
 	dev->change_mtu         = sb1250_change_mtu;
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2822,7 +2877,39 @@ static int sbmac_close(struct net_device
 	return 0;
 }
 
+static int sbmac_poll(struct net_device *dev, int *budget)
+{
+	int work_to_do;
+	int work_done;
+	struct sbmac_softc *sc = netdev_priv(dev);
+
+	work_to_do = min(*budget, dev->quota);
+	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), work_to_do, 1);
+
+	if (work_done > work_to_do)
+		printk(KERN_ERR "%s exceeded work_to_do budget=%d quota=%d work-done=%d\n",
+		       sc->sbm_dev->name, *budget, dev->quota, work_done);
 
+	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
+
+	*budget -= work_done;
+	dev->quota -= work_done;
+
+	if (work_done < work_to_do) {
+		netif_rx_complete(dev);
+
+#ifdef CONFIG_SBMAC_COALESCE
+		__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
+			     ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_RX_CH0),
+			     sc->sbm_imr);
+#else
+		__raw_writeq((M_MAC_INT_CHANNEL << S_MAC_TX_CH0) |
+			     (M_MAC_INT_CHANNEL << S_MAC_RX_CH0), sc->sbm_imr);
+#endif
+	}
+
+	return (work_done >= work_to_do);
+}
 
 #if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) || defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
 static void
@@ -2909,7 +2996,7 @@ sbmac_init_module(void)
 
 		/*
 		 * The R_MAC_ETHERNET_ADDR register will be set to some nonzero
-		 * value for us by the firmware if we're going to use this MAC.
+		 * value for us by the firmware if we are going to use this MAC.
 		 * If we find a zero, skip this MAC.
 		 */
 
_
