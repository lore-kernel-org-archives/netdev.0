From: Zhang Haitao <zhanght@netpower.com.cn>
Subject: Hi, this is my patch for broadcom sb1250-mac.c
Date: Thu, 29 May 2003 12:34:02 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED58DBA.6000506@netpower.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, i've got sb1250-mac.c from broadcom directly,
but find the original driver are not working stable when
delivering 64bytes framesize packets under gigabits circumstance.
This patch have been ported a part of NAPI (added an sbmac_poll
function,dev->quota = 80 )
and modified some parameters to enhance the packets processing performance
eg. tx&rx dma discriptor numbers and dual TX channel configuration.
at the same, in order to let may driver working in Gigafiber circumstance,
i also added some codes for fiber mode controll.

After using my pacth, my board can process 140Mbps 64bytes packets under
linux.

but there are still some problem exsit in my driver :
seems that bug will be trigger when running into fiber mode
and i also use klogd to collect some oops message, hope someone can told me
what's happend to make my kernel crashed.... :-(

i'm very glad to let all of you to review this patch
or give me some advice from the oops message!

Thanks in advance !

yours
Zhang Haitao

here i post my most part of this patch  and oops message get from klogd


[minipanda@zhanght netpower]# cat
/home/zhanght/patchcvs/sb1250.patchbroadcom
--- ./sb1250-broadcom.c Thu May 29 12:24:17 2003
+++ ./sb1250-mac.debug.c        Wed May 28 14:37:00 2003
@@ -44,8 +44,8 @@
 static int full_duplex[MAX_UNITS] = {-1, -1, -1};
 #endif

-static int int_pktcnt = 0;
-static int int_timeout = 0;
+static int int_pktcnt = 32;
+static int int_timeout = 1024;

 /* Operational parameters that usually are not changed. */

@@ -91,7 +91,8 @@
 static char version1[] __devinitdata =
 "sb1250-mac.c:1.00 1/11/2001 Written by Mitch Lichtenberg
(mpl@broadcom.com)\n";
 #endif
-
+#define CONFIG_SB1250_NAPI
+#define NAPI_LOP_MAX 10


 MODULE_AUTHOR("Mitch Lichtenberg (mpl@broadcom.com)");
@@ -154,8 +155,8 @@

 #define PKSEG1(x) ((sbmac_port_t) KSEG1ADDR(x))

-#define SBMAC_MAX_TXDESCR      32
-#define SBMAC_MAX_RXDESCR      32
+#define SBMAC_MAX_TXDESCR      128
+#define SBMAC_MAX_RXDESCR      128

 #define ETHER_ALIGN    2
 #define ETHER_ADDR_LEN 6
@@ -190,8 +191,8 @@
        int              sbdma_txdir;       /* direction (1=transmit) */
        int              sbdma_maxdescr;        /* total # of
descriptors in ring */
 #ifdef CONFIG_SBMAC_COALESCE
-        int              sbdma_int_pktcnt;  /* # descriptors rx/tx
before interrupt*/
-        int              sbdma_int_timeout; /* # usec rx/tx interrupt */
+        int              sbdma_int_pktcnt;  /* # descriptors rx before
interrupt*/
+        int              sbdma_int_timeout; /* # usec rx interrupt */
 #endif

        sbmac_port_t     sbdma_config0; /* DMA config register 0 */
@@ -255,18 +256,20 @@
        sbmac_port_t     sbm_isr;               /* Interrupt status
register */
        sbmac_port_t     sbm_imr;               /* Interrupt mask
register */
        sbmac_port_t     sbm_mdio;              /* MDIO register */
-
+
        sbmac_speed_t    sbm_speed;             /* current speed */
        sbmac_duplex_t   sbm_duplex;    /* current duplex */
        sbmac_fc_t       sbm_fc;                /* current flow control
setting */

        u_char           sbm_hwaddr[ETHER_ADDR_LEN];

-       sbmacdma_t       sbm_txdma;             /* for now, only use
channel 0 */
+       sbmacdma_t       sbm_txdma;             /* for now, use channel 0 */
        sbmacdma_t       sbm_rxdma;
        int              rx_hw_checksum;
        int              sbe_idx;
-
+
+       int              sbm_fibermode;
+       int              sbm_phy_oldsignaldetect;
 };


@@ -288,7 +291,6 @@
 static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *m);
 static void sbdma_emptyring(sbmacdma_t *d);
 static void sbdma_fillring(sbmacdma_t *d);
-static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d);
 static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d);
 static int sbmac_initctx(struct sbmac_softc *s);
 static void sbmac_channel_start(struct sbmac_softc *s);
@@ -299,6 +301,13 @@
 static uint64_t sbmac_addr2reg(unsigned char *ptr);
 static void sbmac_intr(int irq,void *dev_instance,struct pt_regs *rgs);
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev);
+#ifdef CONFIG_SB1250_NAPI
+static int sbmac_poll(struct net_device *dev_instance, int *budget);
+static inline void sbmac_irq_disable(struct sbmac_softc *s);
+static inline void sbmac_irq_enable(struct sbmac_softc *s);
+#else
+static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d);
+#endif
 static void sbmac_setmulti(struct sbmac_softc *sc);
 static int sbmac_init(struct net_device *dev);
 static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed);
@@ -448,6 +457,15 @@
 #define PHYSUP_LINKUP   0x04
 #define PHYSUP_FDX       0x02

+/* Added for Fiber mode detection
+just read Signal Detect alternation */
+
+#define MII_AUXCTL      0x18   /* Auxiliary Control Register */
+
+#define MII_SGMIISR     0x0C    /* SGMII/100-X Status Register */
+
+#define SGMIISR_FIBERSDS       0x2000
+
 #define        MII_BMCR        0x00    /* Basic mode control register
(rw) */
 #define        MII_BMSR        0x01    /* Basic mode status register
(ro) */
 #define MII_K1STSR     0x0A    /* 1K Status Register (ro) */
@@ -459,6 +477,17 @@
 #define ENABLE                 1
 #define DISABLE                0

+#ifdef CONFIG_SB1250_NAPI
+static inline void sbmac_irq_disable(struct sbmac_softc *s){
+         SBMAC_WRITECSR(s->sbm_imr,
+                      ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_TX_CH0));
+}
+static inline void sbmac_irq_enable(struct sbmac_softc *s){
+       SBMAC_WRITECSR(s->sbm_imr,
+                      ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_TX_CH0) |
+                      ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_RX_CH0));
+}
+#endif
 /**********************************************************************
  *  SBMAC_MII_SYNC(s)
  *
@@ -759,22 +788,22 @@

 #ifdef CONFIG_SBMAC_COALESCE
         /*
-         * Setup Rx/Tx DMA coalescing defaults
+         * Setup RxTx DMA coalescing defaults
          */

-               if ( int_pktcnt ) {
-                       d->sbdma_int_pktcnt = int_pktcnt;
-                       }
-               else {
-                       d->sbdma_int_pktcnt = 1;
-                       }
+       if ( int_pktcnt ) {
+                       d->sbdma_int_pktcnt = int_pktcnt;
+               }
+       else {
+                       d->sbdma_int_pktcnt = 1;
+               }

-               if ( int_timeout ) {
-                       d->sbdma_int_timeout = int_timeout;
-                       }
-               else {
-                       d->sbdma_int_timeout = 0;
-                   }
+       if ( int_timeout ) {
+               d->sbdma_int_timeout = int_timeout;
+               }
+       else {
+               d->sbdma_int_timeout = 0;
+           }
 #endif

 }
@@ -944,7 +973,7 @@
                sb_new = sb;
                /*
                 * nothing special to reinit buffer, it's already aligned
-                * and sb->data already points to a good place.
+                * and sb->tail already points to a good place.
                 */
        }

@@ -956,11 +985,11 @@
         /*
          * Do not interrupt per DMA transfer.
          */
-        dsc->dscr_a = KVTOPHYS(sb_new->data) |
+        dsc->dscr_a = KVTOPHYS(sb_new->tail) |
                 V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) |
                 0;
 #else
-       dsc->dscr_a = KVTOPHYS(sb_new->data) |
+       dsc->dscr_a = KVTOPHYS(sb_new->tail) |
                V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) |
                M_DMA_DSCRA_INTERRUPT;
 #endif
@@ -1045,16 +1074,17 @@

        phys = KVTOPHYS(sb->data);
        ncb = NUMCACHEBLKS(length+(phys & (CACHELINESIZE-1)));
-
+#ifdef CONFIG_SBMAC_COALESCE
+       /* do not interript per DMA transfer*/
        dsc->dscr_a = phys |
                V_DMA_DSCRA_A_SIZE(ncb) |
-#ifdef CONFIG_SBMAC_COALESCE
-                0 |
+               M_DMA_ETHTX_SOP;
 #else
+       dsc->dscr_a = phys |
+               V_DMA_DSCRA_A_SIZE(ncb) |
                M_DMA_DSCRA_INTERRUPT |
-#endif
                M_DMA_ETHTX_SOP;
-
+#endif
        /* transmitting: set outbound options and length */

        dsc->dscr_b = V_DMA_DSCRB_OPTIONS(K_DMA_ETHTX_APPENDCRC_APPENDPAD) |
@@ -1133,7 +1163,7 @@
        }
 }

-
+#ifndef CONFIG_SB1250_NAPI
 /**********************************************************************
  *  SBDMA_RX_PROCESS(sc,d)
  *
@@ -1181,6 +1211,14 @@
                 */

                if (curidx == hwidx) break;
+               /*{
+                       int i;
+                       for (i=0;;i++) {
+                       if ((dsc->dscr_a & M_DMA_ETHRX_SOP) != 0)
+                               break;
+                       if (i >= NAPI_LOP_MAX) goto ret;
+                       }
+               }*/

                /*
                 * Otherwise, get the packet's sk_buff ptr back
@@ -1236,8 +1274,7 @@
                                 sb->ip_summed = CHECKSUM_UNNECESSARY;
                               }
                            } /*rx_hw_checksum */
-
-                           netif_rx(sb);
+                            netif_rx(sb);
                            }
                }
                else {
@@ -1258,7 +1295,7 @@

        }
 }
-
+#endif


 /**********************************************************************
@@ -1352,6 +1389,7 @@
                 */

                dev_kfree_skb_irq(sb);
+               //__kfree_skb(sb); //try free fast

                /*
                 * .. and advance to the next buffer.
@@ -1392,7 +1430,8 @@

 static int sbmac_initctx(struct sbmac_softc *s)
 {
-
+
+       int auxctl;
        /*
         * figure out the addresses of some ports
         */
@@ -1413,6 +1452,8 @@
        s->sbm_phy_oldanlpar = 0;
        s->sbm_phy_oldk1stsr = 0;
        s->sbm_phy_oldlinkstat = 0;
+
+       s->sbm_phy_oldsignaldetect =0;

        /*
         * Initialize the DMA channels.  Right now, only one per MAC is used
@@ -1421,7 +1462,6 @@

        sbdma_initctx(&(s->sbm_txdma),s,0,DMA_TX,SBMAC_MAX_TXDESCR);
        sbdma_initctx(&(s->sbm_rxdma),s,0,DMA_RX,SBMAC_MAX_RXDESCR);
-
        /*
         * initial state is OFF
         */
@@ -1435,7 +1475,18 @@
        s->sbm_speed = sbmac_speed_10;
        s->sbm_duplex = sbmac_duplex_half;
        s->sbm_fc = sbmac_fc_disabled;
+
+       /*
+        * Fiber/Copper Mode AutoDetection
+        */

+       sbmac_mii_write(s,1,MII_AUXCTL,0x2007);
+       auxctl = sbmac_mii_read(s,1,MII_AUXCTL);
+       if(auxctl)
+               {
+                       s->sbm_fibermode=1;
+               }
+       else s->sbm_fibermode=0;
        return 0;
 }

@@ -1533,7 +1584,7 @@
        framecfg = V_MAC_MIN_FRAMESZ_DEFAULT |
                V_MAC_MAX_FRAMESZ_DEFAULT |
                V_MAC_BACKOFF_SEL(1);
-
+

        /*
         * Clear out the hash address map
@@ -1604,14 +1655,14 @@
        SBMAC_WRITECSR(s->sbm_framecfg,framecfg);
        SBMAC_WRITECSR(s->sbm_fifocfg,fifo);
        SBMAC_WRITECSR(s->sbm_maccfg,cfg);
-
+
        /*
         * Initialize DMA channels (rings should be ok now)
         */

        sbdma_channel_start(&(s->sbm_rxdma), DMA_RX);
        sbdma_channel_start(&(s->sbm_txdma), DMA_TX);
-
+
        /*
         * Configure the speed, duplex, and flow control
         */
@@ -1632,6 +1683,8 @@
        SBMAC_WRITECSR(s->sbm_macenable,
                       M_MAC_RXDMA_EN0 |
                       M_MAC_TXDMA_EN0 |
+                      M_MAC_RXDMA_EN1 |
+                      M_MAC_TXDMA_EN1 |
                       M_MAC_RX_ENABLE |
                       M_MAC_TX_ENABLE);

@@ -1645,6 +1698,7 @@
        SBMAC_WRITECSR(s->sbm_imr,
                       ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_TX_CH0) |
                       ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_RX_CH0));
+
 #else
        /*
         * Accept any kind of interrupt on TX and RX DMA channel 0
@@ -1724,12 +1778,12 @@

        sbdma_channel_stop(&(s->sbm_rxdma));
        sbdma_channel_stop(&(s->sbm_txdma));
-
+
        /* Empty the receive and transmit rings */

        sbdma_emptyring(&(s->sbm_rxdma));
        sbdma_emptyring(&(s->sbm_txdma));
-
+
 }

 /**********************************************************************
@@ -1967,7 +2021,7 @@
                        V_MAC_IFG_TX_1000 |
                        V_MAC_IFG_THRSH_1000 |
                        V_MAC_SLOT_SIZE_1000;
-               cfg |= V_MAC_SPEED_SEL_1000MBPS | M_MAC_BURST_EN;
+cfg |= V_MAC_SPEED_SEL_1000MBPS | M_MAC_BURST_EN;
                break;

        case sbmac_speed_auto:          /* XXX not implemented */
@@ -2102,6 +2156,7 @@
 {
        struct net_device *dev = (struct net_device *) dev_instance;
        struct sbmac_softc *sc = (struct sbmac_softc *) (dev->priv);
+
        uint64_t isr;

        for (;;) {
@@ -2122,9 +2177,9 @@
                if (isr & (M_MAC_INT_CHANNEL << S_MAC_TX_CH0)) {
                        sbdma_tx_process(sc,&(sc->sbm_txdma));
                }
-
+
                /*
-                * Receives on channel 0
+                * Receives on channel 0,1
                 */

                /*
@@ -2140,58 +2195,191 @@
                 * won't get another interrupt until a packet shows
                 * up to start the timer again.  Testing
                 * EOP_SEEN here takes care of this case.
-                * (EOP_SEEN is part of M_MAC_INT_CHANNEL << S_MAC_RX_CH0)
-                */
-
-
-               if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
-                       sbdma_rx_process(sc,&(sc->sbm_rxdma));
+        * (EOP_SEEN is part of M_MAC_INT_CHANNEL << S_MAC_RX_CH0)
+        */
+
+
+       if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
+#ifdef CONFIG_SB1250_NAPI
+               if (netif_rx_schedule_prep(dev)) {
+                       sbmac_irq_disable(sc);
+                       __netif_rx_schedule(dev);
                }
+#else
+               sbdma_rx_process(sc,&(sc->sbm_rxdma));
+#endif
        }
-
+}
 }


 /**********************************************************************
- *  SBMAC_START_TX(skb,dev)
- *
- *  Start output on the specified interface.  Basically, we
- *  queue as many buffers as we can until the ring fills up, or
- *  we run off the end of the queue, whichever comes first.
- *
- *  Input parameters:
- *
- *
- *  Return value:
- *        nothing
- ********************************************************************* */
+*  SBMAC_START_TX(skb,dev)
+*
+*  Start output on the specified interface.  Basically, we
+*  queue as many buffers as we can until the ring fills up, or
+*  we run off the end of the queue, whichever comes first.
+*
+*  Input parameters:
+*
+*
+*  Return value:
+*         nothing
+********************************************************************* */
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-       struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
-
-       /* lock eth irq */
-       spin_lock_irq (&sc->sbm_lock);
-
-       /*
-        * Put the buffer on the transmit ring.  If we
-        * don't have room, stop the queue.
-        */
-
-       if (sbdma_add_txbuffer(&(sc->sbm_txdma),skb)) {
-               /* XXX save skb that we could not send */
-               netif_stop_queue(dev);
-               spin_unlock_irq(&sc->sbm_lock);
+struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+spin_lock_irq (&sc->sbm_lock);
+/*
+ * Put the buffer on the transmit ring.  If we
+ * don't have room, stop the queue.
+ */
+
+if (sbdma_add_txbuffer(&(sc->sbm_txdma),skb)) {
+               /* XXX save skb that we could not send, then test 1
channel */
+                       netif_stop_queue(dev);
+                       spin_unlock_irq(&sc->sbm_lock);

-               return 1;
+                       return 1;
        }

        dev->trans_start = jiffies;
-
        spin_unlock_irq (&sc->sbm_lock);

        return 0;
 }
+#ifdef CONFIG_SB1250_NAPI
+//#define NAPI_POL_MAX 100
+static int sbmac_poll(struct net_device *dev_instance, int *budget) {
+       struct net_device *dev = (struct net_device *) dev_instance;
+    struct sbmac_softc *sc = (struct sbmac_softc *) (dev_instance->priv);
+    sbmacdma_t *d = &(sc->sbm_rxdma);
+    int rx_work_limit = *budget;
+       unsigned long flags;
+       long int receive=0;
+       int curidx;
+       int hwidx;
+
+       sbdmadscr_t *dsc;
+       struct sk_buff *sb;
+       int len;
+
+    if(rx_work_limit > dev->quota)
+          rx_work_limit = dev->quota;
+
+    for (;;) {
+               /*
+                * figure out where we are (as an index) and where
+                * the hardware is (also as an index)
+                *
+                * This could be done faster if (for example) the
+                * descriptor table was page-aligned and contiguous in
+                * both virtual and physical memory -- you could then
+                * just compare the low-order bits of the virtual address
+                * (sbdma_remptr) and the physical address
(sbdma_curdscr CSR)
+                */
+               if(--rx_work_limit < 0) goto not_done;
+               curidx = d->sbdma_remptr - d->sbdma_dscrtable;
+               hwidx = (int) (((SBMAC_READCSR(d->sbdma_curdscr) &
M_DMA_CURDSCR_ADDR) -
+                               d->sbdma_dscrtable_phys) /
sizeof(sbdmadscr_t));
+
+               /*
+                * If they're the same, that means we've processed all
+                * of the descriptors up to (but not including) the one that
+                * the hardware is working on right now.
+                */
+
+               if (curidx == hwidx) break;
+
+               /*
+                * Otherwise, get the packet's sk_buff ptr back
+                */
+
+               dsc = &(d->sbdma_dscrtable[curidx]);
+               sb = d->sbdma_ctxtable[curidx];
+               d->sbdma_ctxtable[curidx] = NULL;
+
+               len = (int)G_DMA_DSCRB_PKT_SIZE(dsc->dscr_b) - 4;
+
+               /*
+                * Check packet status.  If good, process it.
+                * If not, silently drop it and put it back on the
+                * receive ring.
+                */
+
+               if (!(dsc->dscr_a & M_DMA_ETHRX_BAD)) {
+
+                               /*
+                        * Add a new buffer to replace the old one.  If
we fail
+                        * to allocate a buffer, we're going to drop this
+                        * packet and put it right back on the receive
ring.[root@zhanght root]# cat /home/zhanght/patchcvs/sb1250.patchbroadcom
--- ./sb1250-broadcom.c Thu May 29 12:24:17 2003
+++ ./sb1250-mac.debug.c        Wed May 28 14:37:00 2003
@@ -44,8 +44,8 @@
 static int full_duplex[MAX_UNITS] = {-1, -1, -1};
 #endif

-static int int_pktcnt = 0;
-static int int_timeout = 0;
+static int int_pktcnt = 32;
+static int int_timeout = 1024;

 /* Operational parameters that usually are not changed. */

@@ -91,7 +91,8 @@
 static char version1[] __devinitdata =
 "sb1250-mac.c:1.00 1/11/2001 Written by Mitch Lichtenberg
(mpl@broadcom.com)\n";
 #endif
-
+#define CONFIG_SB1250_NAPI
+#define NAPI_LOP_MAX 10


 MODULE_AUTHOR("Mitch Lichtenberg (mpl@broadcom.com)");
@@ -154,8 +155,8 @@

 #define PKSEG1(x) ((sbmac_port_t) KSEG1ADDR(x))

-#define SBMAC_MAX_TXDESCR      32
-#define SBMAC_MAX_RXDESCR      32
+#define SBMAC_MAX_TXDESCR      128
+#define SBMAC_MAX_RXDESCR      128

 #define ETHER_ALIGN    2
 #define ETHER_ADDR_LEN 6
@@ -190,8 +191,8 @@
        int              sbdma_txdir;       /* direction (1=transmit) */
        int              sbdma_maxdescr;        /* total # of
descriptors in ring */
 #ifdef CONFIG_SBMAC_COALESCE
-        int              sbdma_int_pktcnt;  /* # descriptors rx/tx
before interrupt*/
-        int              sbdma_int_timeout; /* # usec rx/tx interrupt */
+        int              sbdma_int_pktcnt;  /* # descriptors rx before
interrupt*/
+        int              sbdma_int_timeout; /* # usec rx interrupt */
 #endif

        sbmac_port_t     sbdma_config0; /* DMA config register 0 */
@@ -255,18 +256,20 @@
        sbmac_port_t     sbm_isr;               /* Interrupt status
register */
        sbmac_port_t     sbm_imr;               /* Interrupt mask
register */
        sbmac_port_t     sbm_mdio;              /* MDIO register */
-
+
        sbmac_speed_t    sbm_speed;             /* current speed */
        sbmac_duplex_t   sbm_duplex;    /* current duplex */
        sbmac_fc_t       sbm_fc;                /* current flow control
setting */

        u_char           sbm_hwaddr[ETHER_ADDR_LEN];

-       sbmacdma_t       sbm_txdma;             /* for now, only use
channel 0 */
+       sbmacdma_t       sbm_txdma;             /* for now, use channel 0 */
        sbmacdma_t       sbm_rxdma;
        int              rx_hw_checksum;
        int              sbe_idx;
-
+
+       int              sbm_fibermode;
+       int              sbm_phy_oldsignaldetect;
 };


@@ -288,7 +291,6 @@
 static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *m);
 static void sbdma_emptyring(sbmacdma_t *d);
 static void sbdma_fillring(sbmacdma_t *d);
-static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d);
 static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d);
 static int sbmac_initctx(struct sbmac_softc *s);
 static void sbmac_channel_start(struct sbmac_softc *s);
@@ -299,6 +301,13 @@
 static uint64_t sbmac_addr2reg(unsigned char *ptr);
 static void sbmac_intr(int irq,void *dev_instance,struct pt_regs *rgs);
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev);
+#ifdef CONFIG_SB1250_NAPI
+static int sbmac_poll(struct net_device *dev_instance, int *budget);
+static inline void sbmac_irq_disable(struct sbmac_softc *s);
+static inline void sbmac_irq_enable(struct sbmac_softc *s);
+#else
+static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d);
+#endif
 static void sbmac_setmulti(struct sbmac_softc *sc);
 static int sbmac_init(struct net_device *dev);
 static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed);
@@ -448,6 +457,15 @@
 #define PHYSUP_LINKUP   0x04
 #define PHYSUP_FDX       0x02

+/* Added for Fiber mode detection
+just read Signal Detect alternation */
+
+#define MII_AUXCTL      0x18   /* Auxiliary Control Register */
+
+#define MII_SGMIISR     0x0C    /* SGMII/100-X Status Register */
+
+#define SGMIISR_FIBERSDS       0x2000
+
 #define        MII_BMCR        0x00    /* Basic mode control register
(rw) */
 #define        MII_BMSR        0x01    /* Basic mode status register
(ro) */
 #define MII_K1STSR     0x0A    /* 1K Status Register (ro) */
@@ -459,6 +477,17 @@
 #define ENABLE                 1
 #define DISABLE                0

+#ifdef CONFIG_SB1250_NAPI
+static inline void sbmac_irq_disable(struct sbmac_softc *s){
+         SBMAC_WRITECSR(s->sbm_imr,
+                      ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_TX_CH0));
+}
+static inline void sbmac_irq_enable(struct sbmac_softc *s){
+       SBMAC_WRITECSR(s->sbm_imr,
+                      ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_TX_CH0) |
+                      ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_RX_CH0));
+}
+#endif
 /**********************************************************************
  *  SBMAC_MII_SYNC(s)
  *
@@ -759,22 +788,22 @@

 #ifdef CONFIG_SBMAC_COALESCE
         /*
-         * Setup Rx/Tx DMA coalescing defaults
+         * Setup RxTx DMA coalescing defaults
          */

-               if ( int_pktcnt ) {
-                       d->sbdma_int_pktcnt = int_pktcnt;
-                       }
-               else {
-                       d->sbdma_int_pktcnt = 1;
-                       }
+       if ( int_pktcnt ) {
+                       d->sbdma_int_pktcnt = int_pktcnt;
+               }
+       else {
+                       d->sbdma_int_pktcnt = 1;
+               }

-               if ( int_timeout ) {
-                       d->sbdma_int_timeout = int_timeout;
-                       }
-               else {
-                       d->sbdma_int_timeout = 0;
-                   }
+       if ( int_timeout ) {
+               d->sbdma_int_timeout = int_timeout;
+               }
+       else {
+               d->sbdma_int_timeout = 0;
+           }
 #endif

 }
@@ -944,7 +973,7 @@
                sb_new = sb;
                /*
                 * nothing special to reinit buffer, it's already aligned
-                * and sb->data already points to a good place.
+                * and sb->tail already points to a good place.
                 */
        }

@@ -956,11 +985,11 @@
         /*
          * Do not interrupt per DMA transfer.
          */
-        dsc->dscr_a = KVTOPHYS(sb_new->data) |
+        dsc->dscr_a = KVTOPHYS(sb_new->tail) |
                 V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) |
                 0;
 #else
-       dsc->dscr_a = KVTOPHYS(sb_new->data) |
+       dsc->dscr_a = KVTOPHYS(sb_new->tail) |
                V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) |
                M_DMA_DSCRA_INTERRUPT;
 #endif
@@ -1045,16 +1074,17 @@

        phys = KVTOPHYS(sb->data);
        ncb = NUMCACHEBLKS(length+(phys & (CACHELINESIZE-1)));
-
+#ifdef CONFIG_SBMAC_COALESCE
+       /* do not interript per DMA transfer*/
        dsc->dscr_a = phys |
                V_DMA_DSCRA_A_SIZE(ncb) |
-#ifdef CONFIG_SBMAC_COALESCE
-                0 |
+               M_DMA_ETHTX_SOP;
 #else
+       dsc->dscr_a = phys |
+               V_DMA_DSCRA_A_SIZE(ncb) |
                M_DMA_DSCRA_INTERRUPT |
-#endif
                M_DMA_ETHTX_SOP;
-
+#endif
        /* transmitting: set outbound options and length */

        dsc->dscr_b = V_DMA_DSCRB_OPTIONS(K_DMA_ETHTX_APPENDCRC_APPENDPAD) |
@@ -1133,7 +1163,7 @@
        }
 }

-
+#ifndef CONFIG_SB1250_NAPI
 /**********************************************************************
  *  SBDMA_RX_PROCESS(sc,d)
  *
@@ -1181,6 +1211,14 @@
                 */

                if (curidx == hwidx) break;
+               /*{
+                       int i;
+                       for (i=0;;i++) {
+                       if ((dsc->dscr_a & M_DMA_ETHRX_SOP) != 0)
+                               break;
+                       if (i >= NAPI_LOP_MAX) goto ret;
+                       }
+               }*/

                /*
                 * Otherwise, get the packet's sk_buff ptr back
@@ -1236,8 +1274,7 @@
                                 sb->ip_summed = CHECKSUM_UNNECESSARY;
                               }
                            } /*rx_hw_checksum */
-
-                           netif_rx(sb);
+                            netif_rx(sb);
                            }
                }
                else {
@@ -1258,7 +1295,7 @@

        }
 }
-
+#endif


 /**********************************************************************
@@ -1352,6 +1389,7 @@
                 */

                dev_kfree_skb_irq(sb);
+               //__kfree_skb(sb); //try free fast

                /*
                 * .. and advance to the next buffer.
@@ -1392,7 +1430,8 @@

 static int sbmac_initctx(struct sbmac_softc *s)
 {
-
+
+       int auxctl;
        /*
         * figure out the addresses of some ports
         */
@@ -1413,6 +1452,8 @@
        s->sbm_phy_oldanlpar = 0;
        s->sbm_phy_oldk1stsr = 0;
        s->sbm_phy_oldlinkstat = 0;
+
+       s->sbm_phy_oldsignaldetect =0;

        /*
         * Initialize the DMA channels.  Right now, only one per MAC is used
@@ -1421,7 +1462,6 @@

        sbdma_initctx(&(s->sbm_txdma),s,0,DMA_TX,SBMAC_MAX_TXDESCR);
        sbdma_initctx(&(s->sbm_rxdma),s,0,DMA_RX,SBMAC_MAX_RXDESCR);
-
        /*
         * initial state is OFF
         */
@@ -1435,7 +1475,18 @@
        s->sbm_speed = sbmac_speed_10;
        s->sbm_duplex = sbmac_duplex_half;
        s->sbm_fc = sbmac_fc_disabled;
+
+       /*
+        * Fiber/Copper Mode AutoDetection
+        */

+       sbmac_mii_write(s,1,MII_AUXCTL,0x2007);
+       auxctl = sbmac_mii_read(s,1,MII_AUXCTL);
+       if(auxctl)
+               {
+                       s->sbm_fibermode=1;
+               }
+       else s->sbm_fibermode=0;
        return 0;
 }

@@ -1533,7 +1584,7 @@
        framecfg = V_MAC_MIN_FRAMESZ_DEFAULT |
                V_MAC_MAX_FRAMESZ_DEFAULT |
                V_MAC_BACKOFF_SEL(1);
-
+

        /*
         * Clear out the hash address map
@@ -1604,14 +1655,14 @@
        SBMAC_WRITECSR(s->sbm_framecfg,framecfg);
        SBMAC_WRITECSR(s->sbm_fifocfg,fifo);
        SBMAC_WRITECSR(s->sbm_maccfg,cfg);
-
+
        /*
         * Initialize DMA channels (rings should be ok now)
         */

        sbdma_channel_start(&(s->sbm_rxdma), DMA_RX);
        sbdma_channel_start(&(s->sbm_txdma), DMA_TX);
-
+
        /*
         * Configure the speed, duplex, and flow control
         */
@@ -1632,6 +1683,8 @@
        SBMAC_WRITECSR(s->sbm_macenable,
                       M_MAC_RXDMA_EN0 |
                       M_MAC_TXDMA_EN0 |
+                      M_MAC_RXDMA_EN1 |
+                      M_MAC_TXDMA_EN1 |
                       M_MAC_RX_ENABLE |
                       M_MAC_TX_ENABLE);

@@ -1645,6 +1698,7 @@
        SBMAC_WRITECSR(s->sbm_imr,
                       ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_TX_CH0) |
                       ((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) <<
S_MAC_RX_CH0));
+
 #else
        /*
         * Accept any kind of interrupt on TX and RX DMA channel 0
@@ -1724,12 +1778,12 @@

        sbdma_channel_stop(&(s->sbm_rxdma));
        sbdma_channel_stop(&(s->sbm_txdma));
-
+
        /* Empty the receive and transmit rings */

        sbdma_emptyring(&(s->sbm_rxdma));
        sbdma_emptyring(&(s->sbm_txdma));
-
+
 }

 /**********************************************************************
@@ -1967,7 +2021,7 @@
                        V_MAC_IFG_TX_1000 |
                        V_MAC_IFG_THRSH_1000 |
                        V_MAC_SLOT_SIZE_1000;
-               cfg |= V_MAC_SPEED_SEL_1000MBPS | M_MAC_BURST_EN;
+cfg |= V_MAC_SPEED_SEL_1000MBPS | M_MAC_BURST_EN;
                break;

        case sbmac_speed_auto:          /* XXX not implemented */
@@ -2102,6 +2156,7 @@
 {
        struct net_device *dev = (struct net_device *) dev_instance;
        struct sbmac_softc *sc = (struct sbmac_softc *) (dev->priv);
+
        uint64_t isr;

        for (;;) {
@@ -2122,9 +2177,9 @@
                if (isr & (M_MAC_INT_CHANNEL << S_MAC_TX_CH0)) {
                        sbdma_tx_process(sc,&(sc->sbm_txdma));
                }
-
+
                /*
-                * Receives on channel 0
+                * Receives on channel 0,1
                 */

                /*
@@ -2140,58 +2195,191 @@
                 * won't get another interrupt until a packet shows
                 * up to start the timer again.  Testing
                 * EOP_SEEN here takes care of this case.
-                * (EOP_SEEN is part of M_MAC_INT_CHANNEL << S_MAC_RX_CH0)
-                */
-
-
-               if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
-                       sbdma_rx_process(sc,&(sc->sbm_rxdma));
+        * (EOP_SEEN is part of M_MAC_INT_CHANNEL << S_MAC_RX_CH0)
+        */
+
+
+       if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
+#ifdef CONFIG_SB1250_NAPI
+               if (netif_rx_schedule_prep(dev)) {
+                       sbmac_irq_disable(sc);
+                       __netif_rx_schedule(dev);
                }
+#else
+               sbdma_rx_process(sc,&(sc->sbm_rxdma));
+#endif
        }
-
+}
 }


 /**********************************************************************
- *  SBMAC_START_TX(skb,dev)
- *
- *  Start output on the specified interface.  Basically, we
- *  queue as many buffers as we can until the ring fills up, or
- *  we run off the end of the queue, whichever comes first.
- *
- *  Input parameters:
- *
- *
- *  Return value:
- *        nothing
- ********************************************************************* */
+*  SBMAC_START_TX(skb,dev)
+*
+*  Start output on the specified interface.  Basically, we
+*  queue as many buffers as we can until the ring fills up, or
+*  we run off the end of the queue, whichever comes first.
+*
+*  Input parameters:
+*
+*
+*  Return value:
+*         nothing
+********************************************************************* */
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-       struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
-
-       /* lock eth irq */
-       spin_lock_irq (&sc->sbm_lock);
-
-       /*
-        * Put the buffer on the transmit ring.  If we
-        * don't have room, stop the queue.
-        */
-
-       if (sbdma_add_txbuffer(&(sc->sbm_txdma),skb)) {
-               /* XXX save skb that we could not send */
-               netif_stop_queue(dev);
-               spin_unlock_irq(&sc->sbm_lock);
+struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+spin_lock_irq (&sc->sbm_lock);
+/*
+ * Put the buffer on the transmit ring.  If we
+ * don't have room, stop the queue.
+ */
+
+if (sbdma_add_txbuffer(&(sc->sbm_txdma),skb)) {
+               /* XXX save skb that we could not send, then test 1
channel */
+                       netif_stop_queue(dev);
+                       spin_unlock_irq(&sc->sbm_lock);

-               return 1;
+                       return 1;
        }

        dev->trans_start = jiffies;
-
        spin_unlock_irq (&sc->sbm_lock);

        return 0;
 }
+#ifdef CONFIG_SB1250_NAPI
+//#define NAPI_POL_MAX 100
+static int sbmac_poll(struct net_device *dev_instance, int *budget) {
+       struct net_device *dev = (struct net_device *) dev_instance;
+    struct sbmac_softc *sc = (struct sbmac_softc *) (dev_instance->priv);
+    sbmacdma_t *d = &(sc->sbm_rxdma);
+    int rx_work_limit = *budget;
+       unsigned long flags;
+       long int receive=0;
+       int curidx;
+       int hwidx;
+
+       sbdmadscr_t *dsc;
+       struct sk_buff *sb;
+       int len;
+
+    if(rx_work_limit > dev->quota)
+          rx_work_limit = dev->quota;
+
+    for (;;) {
+               /*
+                * figure out where we are (as an index) and where
+                * the hardware is (also as an index)
+                *
+                * This could be done faster if (for example) the
+                * descriptor table was page-aligned and contiguous in
+                * both virtual and physical memory -- you could then
+                * just compare the low-order bits of the virtual address
+                * (sbdma_remptr) and the physical address
(sbdma_curdscr CSR)
+                */
+               if(--rx_work_limit < 0) goto not_done;
+               curidx = d->sbdma_remptr - d->sbdma_dscrtable;
+               hwidx = (int) (((SBMAC_READCSR(d->sbdma_curdscr) &
M_DMA_CURDSCR_ADDR) -
+                               d->sbdma_dscrtable_phys) /
sizeof(sbdmadscr_t));
+
+               /*
+                * If they're the same, that means we've processed all
+                * of the descriptors up to (but not including) the one that
+                * the hardware is working on right now.
+                */
+
+               if (curidx == hwidx) break;
+
+               /*
+                * Otherwise, get the packet's sk_buff ptr back
+                */
+
+               dsc = &(d->sbdma_dscrtable[curidx]);
+               sb = d->sbdma_ctxtable[curidx];
+               d->sbdma_ctxtable[curidx] = NULL;
+
+               len = (int)G_DMA_DSCRB_PKT_SIZE(dsc->dscr_b) - 4;
+
+               /*
+                * Check packet status.  If good, process it.
+                * If not, silently drop it and put it back on the
+                * receive ring.
+                */
+
+               if (!(dsc->dscr_a & M_DMA_ETHRX_BAD)) {
+
+                               /*
+                        * Add a new buffer to replace the old one.  If
we fail
+                        * to allocate a buffer, we're going to drop this
+                        * packet and put it right back on the receive ring.
+                        */
+
+                       if (sbdma_add_rcvbuffer(d,NULL) == -ENOBUFS) {
+                           sc->sbm_stats.rx_dropped++;
+                           sbdma_add_rcvbuffer(d,sb);  /* re-add old
buffer */
+                           }
+                       else {
+                           /*
+                            * Set length into the packet
+                            */
+                           skb_put(sb,len);

+                           /*
+                            * Buffer has been replaced on the receive ring.
+                            * Pass the buffer to the kernel
+                            */
+                           sc->sbm_stats.rx_bytes += len;
+                           sc->sbm_stats.rx_packets++;receive++;
+                           sb->protocol =
eth_type_trans(sb,d->sbdma_eth->sbm_dev);
+                            if (sc->rx_hw_checksum == ENABLE) {
+                           /* if the ip checksum is good indicate in skb.
+                               else set CHECKSUM_NONE as device failed to
+                                       checksum the packet */
+
+                              if (((dsc->dscr_b) |M_DMA_ETHRX_BADTCPCS) ||
+                                 ((dsc->dscr_a)| M_DMA_ETHRX_BADIP4CS)){
+                                 sb->ip_summed = CHECKSUM_NONE;
+                              } else {
+                                printk(KERN_DEBUG "hw checksum fail .\n");
+                                sb->ip_summed = CHECKSUM_UNNECESSARY;
+                              }
+                           } /*rx_hw_checksum */
+                            netif_receive_skb(sb);
+                           }
+               }
+               else {
+                       /*
+                        * Packet was mangled somehow.  Just drop it and
+                        * put it back on the receive ring.
+                        */
+                       sc->sbm_stats.rx_errors++;
+                       sbdma_add_rcvbuffer(d,sb);
+               }
+
+
+               /*
+                * .. and advance to the next buffer.
+                */
+
+               d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
+
+       }
+       if (!receive) receive = 1;
+       dev->quota -= receive;
+       *budget -= receive;
+
+       spin_lock_irqsave(&sc->sbm_lock,flags);
+       netif_rx_complete(dev);
+        sbmac_irq_enable(sc);
+       spin_unlock_irqrestore(&sc->sbm_lock,flags);
+       return 0;
+not_done:
+       dev->quota -= receive;
+       *budget -= receive;
+       return 1;
+}
+#endif
 /**********************************************************************
  *  SBMAC_SETMULTI(sc)
  *
@@ -2448,6 +2636,10 @@
        dev->do_ioctl           = sbmac_mii_ioctl;
        dev->tx_timeout         = sbmac_tx_timeout;
        dev->watchdog_timeo     = TX_TIMEOUT;
+#ifdef CONFIG_SB1250_NAPI
+        dev->poll       = sbmac_poll;
+        dev->weight     =dev->quota = 80;
+#endif

        dev->change_mtu         = sb1250_change_mtu;

@@ -2525,6 +2717,10 @@
     char buffer[100];
     char *p = buffer;

+       int signaldetect;
+
+       if(s->sbm_fibermode == 0)
+               {
     /* Read the mode status and mode control registers. */
     bmsr = sbmac_mii_read(s,s->sbm_phys[0],MII_BMSR);
     bmcr = sbmac_mii_read(s,s->sbm_phys[0],MII_BMCR);
@@ -2539,7 +2735,6 @@
     else {
        k1stsr = 0;
        }
-
     chg = 0;

     if ((bmsr & BMSR_LINKSTAT) == 0) {
@@ -2618,8 +2813,43 @@
 #endif
     if (noisy) {
            printk(KERN_INFO "%s: %s\n",s->sbm_dev->name,buffer);
-           }
+    }

+   }
+   else
+       { //fiber mode
+
+       chg=0;
+       printk("sbm_phy_oldsignaldetect:%d\n",s->sbm_phy_oldsignaldetect);
+
+       signaldetect = (SGMIISR_FIBERSDS &
sbmac_mii_read(s,s->sbm_phys[0],MII_SGMIISR));
+
+    printk("current signaldetect:%d\n",signaldetect);
+
+       if (signaldetect == 0)
+               {
+               printk("link state is DOWN!\n");
+               s->sbm_phy_oldsignaldetect = 0;
+               return 0;
+               }
+       else
+               {
+               if(s->sbm_phy_oldsignaldetect != signaldetect)
+               {
+               s->sbm_phy_oldsignaldetect = signaldetect;
+               chg = 1;
+               printk("link state has been changed\n");
+               }
+               }
+       if (chg==0) return 0;
+               printk("Link is up\n");
+               s->sbm_speed = sbmac_speed_1000;
+               s->sbm_duplex = sbmac_duplex_full;
+               s->sbm_fc = sbmac_fc_frame;
+               s->sbm_state = sbmac_state_on;
+       noisy =0;
+       printk("fiber mode.\t");
+       }
     return 1;
 }

@@ -2632,9 +2862,12 @@
        struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
        int next_tick = HZ;
        int mii_status;
+       int signaldetect;

        spin_lock_irq (&sc->sbm_lock);
-
+
+    if(sc->sbm_fibermode == 0)
+    {
        /* make IFF_RUNNING follow the MII status bit "Link established" */
        mii_status = sbmac_mii_read(sc, sc->sbm_phys[0], MII_BMSR);

@@ -2647,6 +2880,23 @@
                        netif_carrier_off(dev);
                }
        }
+    }
+    else
+    {
+       signaldetect = (SGMIISR_FIBERSDS &
sbmac_mii_read(sc,sc->sbm_phys[0],MII_SGMIISR));
+              if(sc->sbm_phy_oldsignaldetect != signaldetect)
+              {
+                sc->sbm_phy_oldsignaldetect = signaldetect;
+               if (signaldetect) {
+                 printk("netif_carrier_on. \n");
+                netif_carrier_on(dev);
+               }
+               else {
+                netif_carrier_off(dev);
+               }
+                printk("link state has been changed\n");
+              }
+    }

        /*
         * Poll the PHY to see what speed we should be running at

+                        */
+
+                       if (sbdma_add_rcvbuffer(d,NULL) == -ENOBUFS) {
+                           sc->sbm_stats.rx_dropped++;
+                           sbdma_add_rcvbuffer(d,sb);  /* re-add old
buffer */
+                           }
+                       else {
+                           /*
+                            * Set length into the packet
+                            */
+                           skb_put(sb,len);

+                           /*
+                            * Buffer has been replaced on the receive ring.
+                            * Pass the buffer to the kernel
+                            */
+                           sc->sbm_stats.rx_bytes += len;
+                           sc->sbm_stats.rx_packets++;receive++;
+                           sb->protocol =
eth_type_trans(sb,d->sbdma_eth->sbm_dev);
+                            if (sc->rx_hw_checksum == ENABLE) {
+                           /* if the ip checksum is good indicate in skb.
+                               else set CHECKSUM_NONE as device failed to
+                                       checksum the packet */
+
+                              if (((dsc->dscr_b) |M_DMA_ETHRX_BADTCPCS) ||
+                                 ((dsc->dscr_a)| M_DMA_ETHRX_BADIP4CS)){
+                                 sb->ip_summed = CHECKSUM_NONE;
+                              } else {
+                                printk(KERN_DEBUG "hw checksum fail .\n");
+                                sb->ip_summed = CHECKSUM_UNNECESSARY;
+                              }
+                           } /*rx_hw_checksum */
+                            netif_receive_skb(sb);
+                           }
+               }
+               else {
+                       /*
+                        * Packet was mangled somehow.  Just drop it and
+                        * put it back on the receive ring.
+                        */
+                       sc->sbm_stats.rx_errors++;
+                       sbdma_add_rcvbuffer(d,sb);
+               }
+
+
+               /*
+                * .. and advance to the next buffer.
+                */
+
+               d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
+
+       }
+       if (!receive) receive = 1;
+       dev->quota -= receive;
+       *budget -= receive;
+
+       spin_lock_irqsave(&sc->sbm_lock,flags);
+       netif_rx_complete(dev);
+        sbmac_irq_enable(sc);
+       spin_unlock_irqrestore(&sc->sbm_lock,flags);
+       return 0;
+not_done:
+       dev->quota -= receive;
+       *budget -= receive;
+       return 1;
+}
+#endif
 /**********************************************************************
  *  SBMAC_SETMULTI(sc)
  *
@@ -2448,6 +2636,10 @@
        dev->do_ioctl           = sbmac_mii_ioctl;
        dev->tx_timeout         = sbmac_tx_timeout;
        dev->watchdog_timeo     = TX_TIMEOUT;
+#ifdef CONFIG_SB1250_NAPI
+        dev->poll       = sbmac_poll;
+        dev->weight     =dev->quota = 80;
+#endif

        dev->change_mtu         = sb1250_change_mtu;

@@ -2525,6 +2717,10 @@
     char buffer[100];
     char *p = buffer;

+       int signaldetect;
+
+       if(s->sbm_fibermode == 0)
+               {
     /* Read the mode status and mode control registers. */
     bmsr = sbmac_mii_read(s,s->sbm_phys[0],MII_BMSR);
     bmcr = sbmac_mii_read(s,s->sbm_phys[0],MII_BMCR);
@@ -2539,7 +2735,6 @@
     else {
        k1stsr = 0;
        }
-
     chg = 0;

     if ((bmsr & BMSR_LINKSTAT) == 0) {
@@ -2618,8 +2813,43 @@
 #endif
     if (noisy) {
            printk(KERN_INFO "%s: %s\n",s->sbm_dev->name,buffer);
-           }
+    }

+   }
+   else
+       { //fiber mode
+
+       chg=0;
+       printk("sbm_phy_oldsignaldetect:%d\n",s->sbm_phy_oldsignaldetect);
+
+       signaldetect = (SGMIISR_FIBERSDS &
sbmac_mii_read(s,s->sbm_phys[0],MII_SGMIISR));
+
+    printk("current signaldetect:%d\n",signaldetect);
+
+       if (signaldetect == 0)
+               {
+               printk("link state is DOWN!\n");
+               s->sbm_phy_oldsignaldetect = 0;
+               return 0;
+               }
+       else
+               {
+               if(s->sbm_phy_oldsignaldetect != signaldetect)
+               {
+               s->sbm_phy_oldsignaldetect = signaldetect;
+               chg = 1;
+               printk("link state has been changed\n");
+               }
+               }
+       if (chg==0) return 0;
+               printk("Link is up\n");
+               s->sbm_speed = sbmac_speed_1000;
+               s->sbm_duplex = sbmac_duplex_full;
+               s->sbm_fc = sbmac_fc_frame;
+               s->sbm_state = sbmac_state_on;
+       noisy =0;
+       printk("fiber mode.\t");
+       }
     return 1;
 }

@@ -2632,9 +2862,12 @@
        struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
        int next_tick = HZ;
        int mii_status;
+       int signaldetect;

        spin_lock_irq (&sc->sbm_lock);
-
+
+    if(sc->sbm_fibermode == 0)
+    {
        /* make IFF_RUNNING follow the MII status bit "Link established" */
        mii_status = sbmac_mii_read(sc, sc->sbm_phys[0], MII_BMSR);

@@ -2647,6 +2880,23 @@
                        netif_carrier_off(dev);
                }
        }
+    }
+    else
+    {
+       signaldetect = (SGMIISR_FIBERSDS &
sbmac_mii_read(sc,sc->sbm_phys[0],MII_SGMIISR));
+              if(sc->sbm_phy_oldsignaldetect != signaldetect)
+              {
+                sc->sbm_phy_oldsignaldetect = signaldetect;
+               if (signaldetect) {
+                 printk("netif_carrier_on. \n");
+                netif_carrier_on(dev);
+               }
+               else {
+                netif_carrier_off(dev);
+               }
+                printk("link state has been changed\n");
+              }
+    }

        /*
         * Poll the PHY to see what speed we should be running at


----------------------------------------------------
and blow is the oops messages
----------------------------------------------------
May 28 14:16:04 netpower kernel: napi mac_irq disable.
May 28 14:16:04 netpower kernel: skput:over: 801dce38:2498 put:2498
dev:eth2kern
el BUG at skbuff.c:92!
May 28 14:16:04 netpower kernel: Unable to handle kernel paging request
at virtu
al address 00000000, epc == 801f1a5c, ra == 801dce4c
May 28 14:16:04 netpower kernel: Oops in fault.c::do_page_fault, line 219:
May 28 14:16:04 netpower kernel: $0 : 00000000 10001f00 0000001b
00000000 000000
01 80cbe000 00000001 00000000
May 28 14:16:04 netpower kernel: $8 : 007d351a 00000000 00008001
00000000 802f63
79 fffffffa 0000000a 802afc79
May 28 14:16:04 netpower kernel: $16: 8fe1b980 000009c2 8fe16a74
8fe16960 8fe140
00 0000004f 00000000 8fe16800
May 28 14:16:04 netpower kernel: $24: ffffffff
00000002                   802ae0
00 802afdb8 8fe16800 801dce4c
May 28 14:16:04 netpower kernel: Hi : 00000003
May 28 14:16:04 netpower kernel: Lo : 33333334
May 28 14:16:04 netpower kernel: epc  : 801f1a5c    Not tainted
May 28 14:16:04 netpower kernel: Status: 10001f03
May 28 14:16:04 netpower kernel: Cause : 1080000c
May 28 14:16:04 netpower kernel: Process swapper (pid: 0,
stackpage=802ae000)
May 28 14:16:04 netpower kernel: Stack:    802993c0 802993d8 0000005c
00000001 8
fe16800 8fe16960 801dce4c
May 28 14:16:04 netpower kernel:  80115490 00000000 2ac58da0 80296972
8fe16968 8
fe168c0 8fe16800 00000001
May 28 14:16:04 netpower kernel:  802c11dc 802c11dc 802c11c0 00000000
00016424 8
ffae460 801f7874 00000000
May 28 14:16:04 netpower kernel:  802afe20 8029695c 00000001 0000012c
ffffffff 00000000 802c0c90 fffffffb
May 28 14:16:04 netpower kernel:  00000000 10001f00 802afea8 8ffd1208
8fed1cb0 8011ae44 801037d4 8010bb34
May 28 14:16:04 netpower kernel:  00000037 ...
May 28 14:16:04 netpower kernel: Call Trace:
[dm_head_vals.0+1568/4944] [dm_head_vals.0+1592/4944]
[sbmac_poll+524/1240] [printk+608/688] [twist_table.0+3010/3712]
May 28 14:16:04 netpower kernel:  [net_rx_action+356/704]
[twist_table.0+2988/3712] [do_softirq+228/440]
[handle_IRQ_event+144/304] [local_timer_interrupt+152/164] [do_IRQ+316/372]
May 28 14:16:04 netpower kernel:  [sb1250_timer_interrupt+248/252]
[sb1250_time_init+8/588] [cpu_idle+60/112] [cpu_idle+92/112]
[init+0/468] [std_ide_release_region+204/2360]
May 28 14:16:04 netpower kernel:  [std_ide_release_region+268/2360]
May 28 14:16:04 netpower kernel:
May 28 14:16:04 netpower kernel: Code: 0c04548c  2406005c  8fbf0018
<ac000000> 03e00008  27bd0020  3c02802a  244293e4  0807c68e
May 28 14:16:04 netpower kernel: Kernel panic: Aiee, killing interrupt
handler!
