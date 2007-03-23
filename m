From: "Mark E Mason" <mason@broadcom.com>
Subject: [PATCH] NAPI support for Sibyte MAC
Date: Fri, 23 Mar 2007 11:08:16 -0700
Message-ID: <7E000E7F06B05C49BDBB769ADAF44D070206E7BF@NT-SJCA-0750.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: linux-mips@linux-mips.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2904 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433AbXCWSI0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 14:08:26 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ This is a re-post, but the patch still applies and works fine against
the linux-mips.org tip. We'd really like to get this in. -Mark ]

  This patch completes the NAPI functionality for SB1250 MAC, including
making
  NAPI a kernel option that can be turned on or off and adds the
"sbmac_poll"
  routine.

    Signed off by: Mark Mason (mason@broadcom.com)
    Signed off by: Dan Krejsa (dan.krejsa@windriver.com)
    Signed off by: Steve Yang (steve.yang@windriver.com)

Index: linux-2.6.14-cgl/drivers/net/Kconfig
===================================================================
--- linux-2.6.14-cgl.orig/drivers/net/Kconfig	2006-09-20
14:58:54.000000000 -0700
+++ linux-2.6.14-cgl/drivers/net/Kconfig	2006-09-20
17:04:31.000000000 -0700
@@ -2031,6 +2031,23 @@
 	tristate "SB1250 Ethernet support"
 	depends on SIBYTE_SB1xxx_SOC
 
+config SBMAC_NAPI
+	bool "SBMAC: Use Rx Polling (NAPI) (EXPERIMENTAL)"
+	depends on NET_SB1250_MAC && EXPERIMENTAL
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt
load
+	  when the driver is receiving lots of packets from the card. It
is
+	  still somewhat experimental and thus not yet enabled by
default.
+
+	  If your estimated Rx load is 10kpps or more, or if the card
will be
+	  deployed on potentially unfriendly networks (e.g. in a
firewall),
+	  then say Y here.
+
+	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
+	  information.
+
+	  If in doubt, say y.
+
 config R8169_VLAN
 	bool "VLAN support"
 	depends on R8169 && VLAN_8021Q
@@ -2826,3 +2843,5 @@
 	def_bool NETPOLL
 
 endmenu
+
+
Index: linux-2.6.14-cgl/drivers/net/sb1250-mac.c
===================================================================
--- linux-2.6.14-cgl.orig/drivers/net/sb1250-mac.c	2006-09-20
14:59:00.000000000 -0700
+++ linux-2.6.14-cgl/drivers/net/sb1250-mac.c	2006-09-20
20:16:27.000000000 -0700
@@ -95,19 +95,28 @@
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
@@ -155,8 +164,8 @@
 
 #define NUMCACHEBLKS(x) (((x)+SMP_CACHE_BYTES-1)/SMP_CACHE_BYTES)
 
-#define SBMAC_MAX_TXDESCR	32
-#define SBMAC_MAX_RXDESCR	32
+#define SBMAC_MAX_TXDESCR	256
+#define SBMAC_MAX_RXDESCR	256
 
 #define ETHER_ALIGN	2
 #define ETHER_ADDR_LEN	6
@@ -185,10 +194,10 @@
 	 * associated with it.
 	 */
 
-	struct sbmac_softc *sbdma_eth;	        /* back pointer to
associated MAC */
-	int              sbdma_channel;	/* channel number */
+	struct sbmac_softc *sbdma_eth;	    /* back pointer to
associated MAC */
+	int              sbdma_channel;	    /* channel number */
 	int		 sbdma_txdir;       /* direction (1=transmit) */
-	int		 sbdma_maxdescr;	/* total # of
descriptors in ring */
+	int		 sbdma_maxdescr;    /* total # of descriptors in
ring */
 #ifdef CONFIG_SBMAC_COALESCE
 	int		 sbdma_int_pktcnt;  /* # descriptors rx/tx
before interrupt*/
 	int		 sbdma_int_timeout; /* # usec rx/tx interrupt */
@@ -197,13 +206,16 @@
 	volatile void __iomem *sbdma_config0;	/* DMA config register 0
*/
 	volatile void __iomem *sbdma_config1;	/* DMA config register 1
*/
 	volatile void __iomem *sbdma_dscrbase;	/* Descriptor base
address */
-	volatile void __iomem *sbdma_dscrcnt;     /* Descriptor count
register */
+	volatile void __iomem *sbdma_dscrcnt;   /* Descriptor count
register */
 	volatile void __iomem *sbdma_curdscr;	/* current descriptor
address */
+	volatile void __iomem *sbdma_oodpktlost;/* pkt drop (rx only) */
+
 
 	/*
 	 * This stuff is for maintenance of the ring
 	 */
 
+	sbdmadscr_t     *sbdma_dscrtable_unaligned;
 	sbdmadscr_t     *sbdma_dscrtable;	/* base of descriptor
table */
 	sbdmadscr_t     *sbdma_dscrtable_end; /* end of descriptor table
*/
 
@@ -286,8 +298,8 @@
 static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *m);
 static void sbdma_emptyring(sbmacdma_t *d);
 static void sbdma_fillring(sbmacdma_t *d);
-static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d);
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d);
+static int sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d, int
work_to_do, int poll);
+static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int
poll);
 static int sbmac_initctx(struct sbmac_softc *s);
 static void sbmac_channel_start(struct sbmac_softc *s);
 static void sbmac_channel_stop(struct sbmac_softc *s);
@@ -308,6 +320,10 @@
 static void sbmac_set_rx_mode(struct net_device *dev);
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq,
int cmd);
 static int sbmac_close(struct net_device *dev);
+#ifdef CONFIG_SBMAC_NAPI
+static int sbmac_poll(struct net_device *poll_dev, int *budget);
+#endif
+
 static int sbmac_mii_poll(struct sbmac_softc *s,int noisy);
 static int sbmac_mii_probe(struct net_device *dev);
 
@@ -679,6 +695,10 @@
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
@@ -728,6 +748,11 @@
 		s->sbm_base +
R_MAC_DMA_REGISTER(txrx,chan,R_MAC_DMA_DSCR_CNT);
 	d->sbdma_curdscr =
 		s->sbm_base +
R_MAC_DMA_REGISTER(txrx,chan,R_MAC_DMA_CUR_DSCRADDR);
+	if (d->sbdma_txdir)
+		d->sbdma_oodpktlost = NULL;
+	else
+		d->sbdma_oodpktlost =
+			s->sbm_base +
R_MAC_DMA_REGISTER(txrx,chan,R_MAC_DMA_OODPKTLOST_RX);
 
 	/*
 	 * Allocate memory for the ring
@@ -735,6 +760,7 @@
 
 	d->sbdma_maxdescr = maxdescr;
 
+	d->sbdma_dscrtable_unaligned =
 	d->sbdma_dscrtable = (sbdmadscr_t *)
 		kmalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t),
GFP_KERNEL);
 
@@ -765,12 +791,14 @@
 	 * Setup Rx/Tx DMA coalescing defaults
 	 */
 
+	int_pktcnt = (txrx == DMA_TX) ? int_pktcnt_tx : int_pktcnt_rx;
 	if ( int_pktcnt ) {
 		d->sbdma_int_pktcnt = int_pktcnt;
 	} else {
 		d->sbdma_int_pktcnt = 1;
 	}
 
+	int_timeout = (txrx == DMA_TX) ? int_timeout_tx :
int_timeout_rx;
 	if ( int_timeout ) {
 		d->sbdma_int_timeout = int_timeout;
 	} else {
@@ -1130,30 +1158,41 @@
 
 
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
  *********************************************************************
*/
 
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
@@ -1165,7 +1204,12 @@
 		 * (sbdma_remptr) and the physical address
(sbdma_curdscr CSR)
 		 */
 
-		curidx = d->sbdma_remptr - d->sbdma_dscrtable;
+		dsc = d->sbdma_remptr;
+		curidx = dsc - d->sbdma_dscrtable;
+
+		prefetch(dsc);
+		prefetch(&d->sbdma_ctxtable[curidx]);
+
 		hwidx = (int) (((__raw_readq(d->sbdma_curdscr) &
M_DMA_CURDSCR_ADDR) -
 				d->sbdma_dscrtable_phys) /
sizeof(sbdmadscr_t));
 
@@ -1176,13 +1220,12 @@
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
 
@@ -1194,17 +1237,22 @@
 		 * receive ring.
 		 */
 
-		if (!(dsc->dscr_a & M_DMA_ETHRX_BAD)) {
-
+		if (likely (!(dsc->dscr_a & M_DMA_ETHRX_BAD))) {
+ 
 			/*
 			 * Add a new buffer to replace the old one.  If
we fail
 			 * to allocate a buffer, we're going to drop
this
 			 * packet and put it right back on the receive
ring.
 			 */
 
-			if (sbdma_add_rcvbuffer(d,NULL) == -ENOBUFS) {
-				sc->sbm_stats.rx_dropped++;
+			if (unlikely (sbdma_add_rcvbuffer(d,NULL) == 
+				      -ENOBUFS)) {
+ 				sc->sbm_stats.rx_dropped++;
 				sbdma_add_rcvbuffer(d,sb); /* re-add old
buffer */
+				/* No point in continuing at the moment
*/
+				printk(KERN_ERR "dropped packet (1)\n");
+				d->sbdma_remptr =
SBDMA_NEXTBUF(d,sbdma_remptr);
+				goto done;
 			} else {
 				/*
 				 * Set length into the packet
@@ -1216,8 +1264,6 @@
 				 * receive ring.  Pass the buffer to
 				 * the kernel
 				 */
-				sc->sbm_stats.rx_bytes += len;
-				sc->sbm_stats.rx_packets++;
 				sb->protocol =
eth_type_trans(sb,d->sbdma_eth->sbm_dev);
 				/* Check hw IPv4/TCP checksum if
supported */
 				if (sc->rx_hw_checksum == ENABLE) {
@@ -1229,8 +1275,24 @@
 						sb->ip_summed =
CHECKSUM_NONE;
 					}
 				}
-
-				netif_rx(sb);
+				prefetch(sb->data);
+				prefetch((const void *)(((char
*)sb->data)+32));
+#ifdef CONFIG_SBMAC_NAPI
+				if (poll)
+					dropped = netif_receive_skb(sb);
+				else 
+#endif				
+					dropped = netif_rx(sb);
+
+				if (dropped == NET_RX_DROP) {
+					sc->sbm_stats.rx_dropped++;
+					d->sbdma_remptr =
SBDMA_NEXTBUF(d,sbdma_remptr);
+					goto done;
+				}
+				else {
+					sc->sbm_stats.rx_bytes += len;
+					sc->sbm_stats.rx_packets++;
+				}
 			}
 		} else {
 			/*
@@ -1247,12 +1309,16 @@
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
@@ -1264,22 +1330,30 @@
  *
  *  Input parameters:
  *      sc - softc structure
- *  	   d - DMA channel context
+ *  	 d - DMA channel context
+ *    poll - 1: using polling (for NAPI)
  *
  *  Return value:
  *  	   nothing
  *********************************************************************
*/
 
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d)
+static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int
poll)
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
+	hwidx = (int) (((__raw_readq(d->sbdma_curdscr) &
M_DMA_CURDSCR_ADDR) -
+			d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
+ 
 	for (;;) {
 		/*
 		 * figure out where we are (as an index) and where
@@ -1293,8 +1367,6 @@
 		 */
 
 		curidx = d->sbdma_remptr - d->sbdma_dscrtable;
-		hwidx = (int) (((__raw_readq(d->sbdma_curdscr) &
M_DMA_CURDSCR_ADDR) -
-				d->sbdma_dscrtable_phys) /
sizeof(sbdmadscr_t));
 
 		/*
 		 * If they're the same, that means we've processed all
@@ -1332,6 +1404,8 @@
 
 		d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
 
+		packets_handled++;
+
 	}
 
 	/*
@@ -1340,8 +1414,10 @@
 	 * watermark on the transmit queue.
 	 */
 
-	netif_wake_queue(d->sbdma_eth->sbm_dev);
+	if (packets_handled)
+		netif_wake_queue(d->sbdma_eth->sbm_dev);
 
+end_unlock:
 	spin_unlock_irqrestore(&(sc->sbm_lock), flags);
 
 }
@@ -1415,9 +1491,9 @@
 
 static void sbdma_uninitctx(struct sbmacdma_s *d)
 {
-	if (d->sbdma_dscrtable) {
-		kfree(d->sbdma_dscrtable);
-		d->sbdma_dscrtable = NULL;
+	if (d->sbdma_dscrtable_unaligned) {
+		kfree(d->sbdma_dscrtable_unaligned);
+		d->sbdma_dscrtable_unaligned = d->sbdma_dscrtable =
NULL;
 	}
 
 	if (d->sbdma_ctxtable) {
@@ -1615,15 +1691,9 @@
 #endif
 
 #ifdef CONFIG_SBMAC_COALESCE
-	/*
-	 * Accept any TX interrupt and EOP count/timer RX interrupts on
ch 0
-	 */
 	__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_TX_CH0) |
 		       ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_RX_CH0), s->sbm_imr);
 #else
-	/*
-	 * Accept any kind of interrupt on TX and RX DMA channel 0
-	 */
 	__raw_writeq((M_MAC_INT_CHANNEL << S_MAC_TX_CH0) |
 		       (M_MAC_INT_CHANNEL << S_MAC_RX_CH0), s->sbm_imr);
 #endif
@@ -2056,8 +2126,7 @@
 	uint64_t isr;
 	int handled = 0;
 
-	for (;;) {
-
+#ifdef CONFIG_SBMAC_NAPI
 		/*
 		 * Read the ISR (this clears the bits in the real
 		 * register, except for counter addr)
@@ -2066,8 +2135,7 @@
 		isr = __raw_readq(sc->sbm_isr) & ~M_MAC_COUNTER_ADDR;
 
 		if (isr == 0)
-			break;
-
+		        return IRQ_RETVAL(0);
 		handled = 1;
 
 		/*
@@ -2075,12 +2143,52 @@
 		 */
 
 		if (isr & (M_MAC_INT_CHANNEL << S_MAC_TX_CH0)) {
-			sbdma_tx_process(sc,&(sc->sbm_txdma));
+			sbdma_tx_process(sc,&(sc->sbm_txdma), 0);
+#ifdef CONFIG_NETPOLL_TRAP
+		       if (netpoll_trap()) {
+			       if (test_and_clear_bit(__LINK_STATE_XOFF,
&dev->state)) 
+				       __netif_schedule(dev);
+		       }
+#endif
 		}
 
+	if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
+		if (netif_rx_schedule_prep(dev)) {
+			__raw_writeq(0, sc->sbm_imr);
+			__netif_rx_schedule(dev);
+			/* Depend on the exit from poll to reenable intr
*/
+		}
+		else {
+			/* may leave some packets behind */
+			sbdma_rx_process(sc,&(sc->sbm_rxdma),
+					 SBMAC_MAX_RXDESCR * 2, 0);
+		}
+	}
+#else
+	/* Non NAPI */
+	for (;;) {
+ 
 		/*
-		 * Receives on channel 0
+		 * Read the ISR (this clears the bits in the real
+		 * register, except for counter addr)
 		 */
+		isr = __raw_readq(sc->sbm_isr) & ~M_MAC_COUNTER_ADDR;
+
+		if (isr == 0)
+			break;
+
+		handled = 1;
+
+		if (isr & (M_MAC_INT_CHANNEL << S_MAC_TX_CH0)) {
+			sbdma_tx_process(sc,&(sc->sbm_txdma),
+					 SBMAC_MAX_RXDESCR * 2);
+#ifdef CONFIG_NETPOLL_TRAP
+		       if (netpoll_trap()) {
+			       if (test_and_clear_bit(__LINK_STATE_XOFF,
&dev->state)) 
+				       __netif_schedule(dev);
+		       }
+#endif
+		}
 
 		/*
 		 * It's important to test all the bits (or at least the
@@ -2097,16 +2205,15 @@
 		 * EOP_SEEN here takes care of this case.
 		 * (EOP_SEEN is part of M_MAC_INT_CHANNEL <<
S_MAC_RX_CH0)
 		 */
-
-
 		if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
-			sbdma_rx_process(sc,&(sc->sbm_rxdma));
+			sbdma_rx_process(sc,&(sc->sbm_rxdma),
+					 SBMAC_MAX_RXDESCR * 2, 0);
 		}
 	}
+#endif
 	return IRQ_RETVAL(handled);
 }
 
-
 /**********************************************************************
  *  SBMAC_START_TX(skb,dev)
  *
@@ -2236,8 +2343,6 @@
 	}
 }
 
-
-
 #if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) ||
defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
 /**********************************************************************
  *  SBMAC_PARSE_XDIGIT(str)
@@ -2400,9 +2505,12 @@
 	dev->do_ioctl           = sbmac_mii_ioctl;
 	dev->tx_timeout         = sbmac_tx_timeout;
 	dev->watchdog_timeo     = TX_TIMEOUT;
-
 	dev->change_mtu         = sb1250_change_mtu;
-
+#ifdef CONFIG_SBMAC_NAPI
+	dev->poll               = sbmac_poll;
+	dev->weight             = 16;
+#endif
+ 
 	/* This is needed for PASS2 for Rx H/W checksum feature */
 	sbmac_set_iphdr_offset(sc);
 
@@ -2808,7 +2916,41 @@
 	return 0;
 }
 
+#ifdef CONFIG_SBMAC_NAPI
+static int sbmac_poll(struct net_device *dev, int *budget)
+{
+	int work_to_do;
+	int work_done;
+	struct sbmac_softc *sc = netdev_priv(dev);
+
+	work_to_do = min(*budget, dev->quota);
+	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), work_to_do,
1);
+
+	if (work_done > work_to_do)
+		printk(KERN_ERR "%s exceeded work_to_do budget=%d
quota=%d work-done=%d\n",
+		       sc->sbm_dev->name, *budget, dev->quota,
work_done);
+
+	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
 
+	*budget -= work_done;
+	dev->quota -= work_done;
+
+	if (work_done < work_to_do) {
+		netif_rx_complete(dev);
+
+#ifdef CONFIG_SBMAC_COALESCE
+		__raw_writeq(((M_MAC_INT_EOP_COUNT |
M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
+			     ((M_MAC_INT_EOP_COUNT |
M_MAC_INT_EOP_TIMER) << S_MAC_RX_CH0), 
+			     sc->sbm_imr);
+#else
+		__raw_writeq((M_MAC_INT_CHANNEL << S_MAC_TX_CH0) |
+			     (M_MAC_INT_CHANNEL << S_MAC_RX_CH0),
sc->sbm_imr);
+#endif
+	}
+
+	return (work_done >= work_to_do);
+}
+#endif
 
 #if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) ||
defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
 static void
Index: linux-2.6.14-cgl/arch/mips/sibyte/bcm1480/irq.c
===================================================================
--- linux-2.6.14-cgl.orig/arch/mips/sibyte/bcm1480/irq.c
2006-09-20 14:58:41.000000000 -0700
+++ linux-2.6.14-cgl/arch/mips/sibyte/bcm1480/irq.c	2006-09-20
15:58:33.000000000 -0700
@@ -144,11 +144,11 @@
 	unsigned long flags;
 	unsigned int irq_dirty;
 
-	i = first_cpu(mask);
-	if (next_cpu(i, mask) <= NR_CPUS) {
+	if (cpus_weight(mask) != 1) {
 		printk("attempted to set irq affinity for irq %d to
multiple CPUs\n", irq);
 		return;
 	}
+	i = first_cpu(mask);
 
 	/* Convert logical CPU to physical CPU */
 	cpu = cpu_logical_map(i);

