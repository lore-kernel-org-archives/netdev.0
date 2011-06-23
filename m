From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/8] a2065: Use pr_fmt, pr_<level> and netdev_<level>
Date: Wed, 22 Jun 2011 23:38:54 -0700
Message-ID: <66a474027c1bd82e77b48431ff6ae8de199a0549.1308810463.git.joe@perches.com>
References: <cover.1308810463.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1308810463.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use current logging styles.

Other miscellaneous cleanups:

Space removal and additions for checkpatch warnings.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/a2065.c |  336 +++++++++++++++++++++++++--------------------------
 1 files changed, 162 insertions(+), 174 deletions(-)

diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 25ea98a..7d9a1a6 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -37,6 +37,11 @@
  *	  both 10BASE-2 (thin coax) and AUI (DB-15) connectors
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+/*#define DEBUG*/
+/*#define TEST_HITS*/
+
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -58,29 +63,22 @@
 
 #include "a2065.h"
 
-
-	/*
-	 *		Transmit/Receive Ring Definitions
-	 */
+/* Transmit/Receive Ring Definitions */
 
 #define LANCE_LOG_TX_BUFFERS	(2)
 #define LANCE_LOG_RX_BUFFERS	(4)
 
-#define TX_RING_SIZE		(1<<LANCE_LOG_TX_BUFFERS)
-#define RX_RING_SIZE		(1<<LANCE_LOG_RX_BUFFERS)
+#define TX_RING_SIZE		(1 << LANCE_LOG_TX_BUFFERS)
+#define RX_RING_SIZE		(1 << LANCE_LOG_RX_BUFFERS)
 
-#define TX_RING_MOD_MASK	(TX_RING_SIZE-1)
-#define RX_RING_MOD_MASK	(RX_RING_SIZE-1)
+#define TX_RING_MOD_MASK	(TX_RING_SIZE - 1)
+#define RX_RING_MOD_MASK	(RX_RING_SIZE - 1)
 
 #define PKT_BUF_SIZE		(1544)
 #define RX_BUFF_SIZE            PKT_BUF_SIZE
 #define TX_BUFF_SIZE            PKT_BUF_SIZE
 
-
-	/*
-	 *		Layout of the Lance's RAM Buffer
-	 */
-
+/* Layout of the Lance's RAM Buffer */
 
 struct lance_init_block {
 	unsigned short mode;		/* Pre-set mode (reg. 15) */
@@ -97,14 +95,11 @@ struct lance_init_block {
 	struct lance_rx_desc brx_ring[RX_RING_SIZE];
 	struct lance_tx_desc btx_ring[TX_RING_SIZE];
 
-	char   rx_buf [RX_RING_SIZE][RX_BUFF_SIZE];
-	char   tx_buf [TX_RING_SIZE][TX_BUFF_SIZE];
+	char rx_buf[RX_RING_SIZE][RX_BUFF_SIZE];
+	char tx_buf[TX_RING_SIZE][TX_BUFF_SIZE];
 };
 
-
-	/*
-	 *		Private Device Data
-	 */
+/* Private Device Data */
 
 struct lance_private {
 	char *name;
@@ -129,21 +124,14 @@ struct lance_private {
 	struct timer_list         multicast_timer;
 };
 
-#define TX_BUFFS_AVAIL ((lp->tx_old<=lp->tx_new)?\
-			lp->tx_old+lp->tx_ring_mod_mask-lp->tx_new:\
-			lp->tx_old - lp->tx_new-1)
-
-
 #define LANCE_ADDR(x) ((int)(x) & ~0xff000000)
 
 /* Load the CSR registers */
-static void load_csrs (struct lance_private *lp)
+static void load_csrs(struct lance_private *lp)
 {
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_init_block *aib = lp->lance_init_block;
-	int leptr;
-
-	leptr = LANCE_ADDR (aib);
+	int leptr = LANCE_ADDR(aib);
 
 	ll->rap = LE_CSR1;
 	ll->rdp = (leptr & 0xFFFF);
@@ -156,19 +144,16 @@ static void load_csrs (struct lance_private *lp)
 	ll->rap = LE_CSR0;
 }
 
-#define ZERO 0
-
 /* Setup the Lance Rx and Tx rings */
-static void lance_init_ring (struct net_device *dev)
+static void lance_init_ring(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
-	volatile struct lance_init_block *aib; /* for LANCE_ADDR computations */
+	volatile struct lance_init_block *aib = lp->lance_init_block;
+					/* for LANCE_ADDR computations */
 	int leptr;
 	int i;
 
-	aib = lp->lance_init_block;
-
 	/* Lock out other processes while setting up hardware */
 	netif_stop_queue(dev);
 	lp->rx_new = lp->tx_new = 0;
@@ -179,41 +164,38 @@ static void lance_init_ring (struct net_device *dev)
 	/* Copy the ethernet address to the lance init block
 	 * Note that on the sparc you need to swap the ethernet address.
 	 */
-	ib->phys_addr [0] = dev->dev_addr [1];
-	ib->phys_addr [1] = dev->dev_addr [0];
-	ib->phys_addr [2] = dev->dev_addr [3];
-	ib->phys_addr [3] = dev->dev_addr [2];
-	ib->phys_addr [4] = dev->dev_addr [5];
-	ib->phys_addr [5] = dev->dev_addr [4];
-
-	if (ZERO)
-		printk(KERN_DEBUG "TX rings:\n");
+	ib->phys_addr[0] = dev->dev_addr[1];
+	ib->phys_addr[1] = dev->dev_addr[0];
+	ib->phys_addr[2] = dev->dev_addr[3];
+	ib->phys_addr[3] = dev->dev_addr[2];
+	ib->phys_addr[4] = dev->dev_addr[5];
+	ib->phys_addr[5] = dev->dev_addr[4];
 
 	/* Setup the Tx ring entries */
-	for (i = 0; i <= (1<<lp->lance_log_tx_bufs); i++) {
+	netdev_dbg(dev, "TX rings:\n");
+	for (i = 0; i <= 1 << lp->lance_log_tx_bufs; i++) {
 		leptr = LANCE_ADDR(&aib->tx_buf[i][0]);
-		ib->btx_ring [i].tmd0      = leptr;
-		ib->btx_ring [i].tmd1_hadr = leptr >> 16;
-		ib->btx_ring [i].tmd1_bits = 0;
-		ib->btx_ring [i].length    = 0xf000; /* The ones required by tmd2 */
-		ib->btx_ring [i].misc      = 0;
-		if (i < 3 && ZERO)
-			printk(KERN_DEBUG "%d: 0x%8.8x\n", i, leptr);
+		ib->btx_ring[i].tmd0      = leptr;
+		ib->btx_ring[i].tmd1_hadr = leptr >> 16;
+		ib->btx_ring[i].tmd1_bits = 0;
+		ib->btx_ring[i].length    = 0xf000; /* The ones required by tmd2 */
+		ib->btx_ring[i].misc      = 0;
+		if (i < 3)
+			netdev_dbg(dev, "%d: 0x%08x\n", i, leptr);
 	}
 
 	/* Setup the Rx ring entries */
-	if (ZERO)
-		printk(KERN_DEBUG "RX rings:\n");
-	for (i = 0; i < (1<<lp->lance_log_rx_bufs); i++) {
+	netdev_dbg(dev, "RX rings:\n");
+	for (i = 0; i < 1 << lp->lance_log_rx_bufs; i++) {
 		leptr = LANCE_ADDR(&aib->rx_buf[i][0]);
 
-		ib->brx_ring [i].rmd0      = leptr;
-		ib->brx_ring [i].rmd1_hadr = leptr >> 16;
-		ib->brx_ring [i].rmd1_bits = LE_R1_OWN;
-		ib->brx_ring [i].length    = -RX_BUFF_SIZE | 0xf000;
-		ib->brx_ring [i].mblength  = 0;
-		if (i < 3 && ZERO)
-			printk(KERN_DEBUG "%d: 0x%8.8x\n", i, leptr);
+		ib->brx_ring[i].rmd0      = leptr;
+		ib->brx_ring[i].rmd1_hadr = leptr >> 16;
+		ib->brx_ring[i].rmd1_bits = LE_R1_OWN;
+		ib->brx_ring[i].length    = -RX_BUFF_SIZE | 0xf000;
+		ib->brx_ring[i].mblength  = 0;
+		if (i < 3)
+			netdev_dbg(dev, "%d: 0x%08x\n", i, leptr);
 	}
 
 	/* Setup the initialization block */
@@ -222,22 +204,20 @@ static void lance_init_ring (struct net_device *dev)
 	leptr = LANCE_ADDR(&aib->brx_ring);
 	ib->rx_len = (lp->lance_log_rx_bufs << 13) | (leptr >> 16);
 	ib->rx_ptr = leptr;
-	if (ZERO)
-		printk(KERN_DEBUG "RX ptr: %8.8x\n", leptr);
+	netdev_dbg(dev, "RX ptr: %08x\n", leptr);
 
 	/* Setup tx descriptor pointer */
 	leptr = LANCE_ADDR(&aib->btx_ring);
 	ib->tx_len = (lp->lance_log_tx_bufs << 13) | (leptr >> 16);
 	ib->tx_ptr = leptr;
-	if (ZERO)
-		printk(KERN_DEBUG "TX ptr: %8.8x\n", leptr);
+	netdev_dbg(dev, "TX ptr: %08x\n", leptr);
 
 	/* Clear the multicast filter */
-	ib->filter [0] = 0;
-	ib->filter [1] = 0;
+	ib->filter[0] = 0;
+	ib->filter[1] = 0;
 }
 
-static int init_restart_lance (struct lance_private *lp)
+static int init_restart_lance(struct lance_private *lp)
 {
 	volatile struct lance_regs *ll = lp->ll;
 	int i;
@@ -249,8 +229,7 @@ static int init_restart_lance (struct lance_private *lp)
 	for (i = 0; (i < 100) && !(ll->rdp & (LE_C0_ERR | LE_C0_IDON)); i++)
 		barrier();
 	if ((i == 100) || (ll->rdp & LE_C0_ERR)) {
-		printk(KERN_ERR "LANCE unopened after %d ticks, csr0=%4.4x.\n",
-		       i, ll->rdp);
+		pr_err("unopened after %d ticks, csr0=%04x\n", i, ll->rdp);
 		return -EIO;
 	}
 
@@ -261,7 +240,7 @@ static int init_restart_lance (struct lance_private *lp)
 	return 0;
 }
 
-static int lance_rx (struct net_device *dev)
+static int lance_rx(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
@@ -271,22 +250,24 @@ static int lance_rx (struct net_device *dev)
 
 #ifdef TEST_HITS
 	int i;
-	printk(KERN_DEBUG "[");
+	char buf[RX_RING_SIZE + 1];
+
 	for (i = 0; i < RX_RING_SIZE; i++) {
+		char r1_own = ib->brx_ring[i].rmd1_bits & LE_R1_OWN;
 		if (i == lp->rx_new)
-			printk ("%s",
-				ib->brx_ring [i].rmd1_bits & LE_R1_OWN ? "_" : "X");
+			buf[i] = r1_own ? '_' : 'X';
 		else
-			printk ("%s",
-				ib->brx_ring [i].rmd1_bits & LE_R1_OWN ? "." : "1");
+			buf[i] = r1_own ? '.' : '1';
 	}
-	printk ("]\n");
+	buf[RX_RING_SIZE] = 0;
+
+	pr_debug("RxRing TestHits: [%s]\n", buf);
 #endif
 
-	ll->rdp = LE_C0_RINT|LE_C0_INEA;
-	for (rd = &ib->brx_ring [lp->rx_new];
+	ll->rdp = LE_C0_RINT | LE_C0_INEA;
+	for (rd = &ib->brx_ring[lp->rx_new];
 	     !((bits = rd->rmd1_bits) & LE_R1_OWN);
-	     rd = &ib->brx_ring [lp->rx_new]) {
+	     rd = &ib->brx_ring[lp->rx_new]) {
 
 		/* We got an incomplete frame? */
 		if ((bits & LE_R1_POK) != LE_R1_POK) {
@@ -297,18 +278,22 @@ static int lance_rx (struct net_device *dev)
 			/* Count only the end frame as a rx error,
 			 * not the beginning
 			 */
-			if (bits & LE_R1_BUF) dev->stats.rx_fifo_errors++;
-			if (bits & LE_R1_CRC) dev->stats.rx_crc_errors++;
-			if (bits & LE_R1_OFL) dev->stats.rx_over_errors++;
-			if (bits & LE_R1_FRA) dev->stats.rx_frame_errors++;
-			if (bits & LE_R1_EOP) dev->stats.rx_errors++;
+			if (bits & LE_R1_BUF)
+				dev->stats.rx_fifo_errors++;
+			if (bits & LE_R1_CRC)
+				dev->stats.rx_crc_errors++;
+			if (bits & LE_R1_OFL)
+				dev->stats.rx_over_errors++;
+			if (bits & LE_R1_FRA)
+				dev->stats.rx_frame_errors++;
+			if (bits & LE_R1_EOP)
+				dev->stats.rx_errors++;
 		} else {
 			int len = (rd->mblength & 0xfff) - 4;
-			struct sk_buff *skb = dev_alloc_skb (len+2);
+			struct sk_buff *skb = dev_alloc_skb(len + 2);
 
 			if (!skb) {
-				printk(KERN_WARNING "%s: Memory squeeze, "
-				       "deferring packet.\n", dev->name);
+				netdev_warn(dev, "Memory squeeze, deferring packet\n");
 				dev->stats.rx_dropped++;
 				rd->mblength = 0;
 				rd->rmd1_bits = LE_R1_OWN;
@@ -316,13 +301,13 @@ static int lance_rx (struct net_device *dev)
 				return 0;
 			}
 
-			skb_reserve (skb, 2);		/* 16 byte align */
-			skb_put (skb, len);		/* make room */
+			skb_reserve(skb, 2);		/* 16 byte align */
+			skb_put(skb, len);		/* make room */
 			skb_copy_to_linear_data(skb,
-					 (unsigned char *)&(ib->rx_buf [lp->rx_new][0]),
-					 len);
-			skb->protocol = eth_type_trans (skb, dev);
-			netif_rx (skb);
+				 (unsigned char *)&ib->rx_buf[lp->rx_new][0],
+				 len);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += len;
 		}
@@ -335,7 +320,7 @@ static int lance_rx (struct net_device *dev)
 	return 0;
 }
 
-static int lance_tx (struct net_device *dev)
+static int lance_tx(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
@@ -350,7 +335,7 @@ static int lance_tx (struct net_device *dev)
 
 	j = lp->tx_old;
 	for (i = j; i != lp->tx_new; i = j) {
-		td = &ib->btx_ring [i];
+		td = &ib->btx_ring[i];
 
 		/* If we hit a packet not owned by us, stop */
 		if (td->tmd1_bits & LE_T1_OWN)
@@ -360,45 +345,44 @@ static int lance_tx (struct net_device *dev)
 			status = td->misc;
 
 			dev->stats.tx_errors++;
-			if (status & LE_T3_RTY)  dev->stats.tx_aborted_errors++;
-			if (status & LE_T3_LCOL) dev->stats.tx_window_errors++;
+			if (status & LE_T3_RTY)
+				dev->stats.tx_aborted_errors++;
+			if (status & LE_T3_LCOL)
+				dev->stats.tx_window_errors++;
 
 			if (status & LE_T3_CLOS) {
 				dev->stats.tx_carrier_errors++;
 				if (lp->auto_select) {
 					lp->tpe = 1 - lp->tpe;
-					printk(KERN_ERR "%s: Carrier Lost, "
-					       "trying %s\n", dev->name,
-					       lp->tpe?"TPE":"AUI");
+					netdev_err(dev, "Carrier Lost, trying %s\n",
+						   lp->tpe ? "TPE" : "AUI");
 					/* Stop the lance */
 					ll->rap = LE_CSR0;
 					ll->rdp = LE_C0_STOP;
-					lance_init_ring (dev);
-					load_csrs (lp);
-					init_restart_lance (lp);
+					lance_init_ring(dev);
+					load_csrs(lp);
+					init_restart_lance(lp);
 					return 0;
 				}
 			}
 
-			/* buffer errors and underflows turn off the transmitter */
-			/* Restart the adapter */
-			if (status & (LE_T3_BUF|LE_T3_UFL)) {
+			/* buffer errors and underflows turn off
+			 * the transmitter, so restart the adapter
+			 */
+			if (status & (LE_T3_BUF | LE_T3_UFL)) {
 				dev->stats.tx_fifo_errors++;
 
-				printk(KERN_ERR "%s: Tx: ERR_BUF|ERR_UFL, "
-				       "restarting\n", dev->name);
+				netdev_err(dev, "Tx: ERR_BUF|ERR_UFL, restarting\n");
 				/* Stop the lance */
 				ll->rap = LE_CSR0;
 				ll->rdp = LE_C0_STOP;
-				lance_init_ring (dev);
-				load_csrs (lp);
-				init_restart_lance (lp);
+				lance_init_ring(dev);
+				load_csrs(lp);
+				init_restart_lance(lp);
 				return 0;
 			}
 		} else if ((td->tmd1_bits & LE_T1_POK) == LE_T1_POK) {
-			/*
-			 * So we don't count the packet more than once.
-			 */
+			/* So we don't count the packet more than once. */
 			td->tmd1_bits &= ~(LE_T1_POK);
 
 			/* One collision before packet was sent. */
@@ -419,7 +403,14 @@ static int lance_tx (struct net_device *dev)
 	return 0;
 }
 
-static irqreturn_t lance_interrupt (int irq, void *dev_id)
+static int lance_tx_buffs_avail(struct lance_private *lp)
+{
+	if (lp->tx_old <= lp->tx_new)
+		return lp->tx_old + lp->tx_ring_mod_mask - lp->tx_new;
+	return lp->tx_old - lp->tx_new - 1;
+}
+
+static irqreturn_t lance_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct lance_private *lp = netdev_priv(dev);
@@ -433,19 +424,19 @@ static irqreturn_t lance_interrupt (int irq, void *dev_id)
 		return IRQ_NONE;	/* been generated by the Lance. */
 
 	/* Acknowledge all the interrupt sources ASAP */
-	ll->rdp = csr0 & ~(LE_C0_INEA|LE_C0_TDMD|LE_C0_STOP|LE_C0_STRT|
+	ll->rdp = csr0 & ~(LE_C0_INEA | LE_C0_TDMD | LE_C0_STOP | LE_C0_STRT |
 			   LE_C0_INIT);
 
-	if ((csr0 & LE_C0_ERR)) {
+	if (csr0 & LE_C0_ERR) {
 		/* Clear the error condition */
-		ll->rdp = LE_C0_BABL|LE_C0_ERR|LE_C0_MISS|LE_C0_INEA;
+		ll->rdp = LE_C0_BABL | LE_C0_ERR | LE_C0_MISS | LE_C0_INEA;
 	}
 
 	if (csr0 & LE_C0_RINT)
-		lance_rx (dev);
+		lance_rx(dev);
 
 	if (csr0 & LE_C0_TINT)
-		lance_tx (dev);
+		lance_tx(dev);
 
 	/* Log misc errors. */
 	if (csr0 & LE_C0_BABL)
@@ -453,22 +444,22 @@ static irqreturn_t lance_interrupt (int irq, void *dev_id)
 	if (csr0 & LE_C0_MISS)
 		dev->stats.rx_errors++;       /* Missed a Rx frame. */
 	if (csr0 & LE_C0_MERR) {
-		printk(KERN_ERR "%s: Bus master arbitration failure, status "
-		       "%4.4x.\n", dev->name, csr0);
+		netdev_err(dev, "Bus master arbitration failure, status %04x\n",
+			   csr0);
 		/* Restart the chip. */
 		ll->rdp = LE_C0_STRT;
 	}
 
-	if (netif_queue_stopped(dev) && TX_BUFFS_AVAIL > 0)
+	if (netif_queue_stopped(dev) && lance_tx_buffs_avail(lp) > 0)
 		netif_wake_queue(dev);
 
 	ll->rap = LE_CSR0;
-	ll->rdp = LE_C0_BABL|LE_C0_CERR|LE_C0_MISS|LE_C0_MERR|
-					LE_C0_IDON|LE_C0_INEA;
+	ll->rdp = (LE_C0_BABL | LE_C0_CERR | LE_C0_MISS | LE_C0_MERR |
+		   LE_C0_IDON | LE_C0_INEA);
 	return IRQ_HANDLED;
 }
 
-static int lance_open (struct net_device *dev)
+static int lance_open(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
@@ -481,17 +472,18 @@ static int lance_open (struct net_device *dev)
 	/* Install the Interrupt handler */
 	ret = request_irq(IRQ_AMIGA_PORTS, lance_interrupt, IRQF_SHARED,
 			  dev->name, dev);
-	if (ret) return ret;
+	if (ret)
+		return ret;
 
-	load_csrs (lp);
-	lance_init_ring (dev);
+	load_csrs(lp);
+	lance_init_ring(dev);
 
 	netif_start_queue(dev);
 
-	return init_restart_lance (lp);
+	return init_restart_lance(lp);
 }
 
-static int lance_close (struct net_device *dev)
+static int lance_close(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
@@ -507,7 +499,7 @@ static int lance_close (struct net_device *dev)
 	return 0;
 }
 
-static inline int lance_reset (struct net_device *dev)
+static inline int lance_reset(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
@@ -517,16 +509,15 @@ static inline int lance_reset (struct net_device *dev)
 	ll->rap = LE_CSR0;
 	ll->rdp = LE_C0_STOP;
 
-	load_csrs (lp);
+	load_csrs(lp);
 
-	lance_init_ring (dev);
+	lance_init_ring(dev);
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_start_queue(dev);
 
-	status = init_restart_lance (lp);
-#ifdef DEBUG_DRIVER
-	printk(KERN_DEBUG "Lance restart=%d\n", status);
-#endif
+	status = init_restart_lance(lp);
+	netdev_dbg(dev, "Lance restart=%d\n", status);
+
 	return status;
 }
 
@@ -535,14 +526,13 @@ static void lance_tx_timeout(struct net_device *dev)
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 
-	printk(KERN_ERR "%s: transmit timed out, status %04x, reset\n",
-	       dev->name, ll->rdp);
+	netdev_err(dev, "transmit timed out, status %04x, reset\n", ll->rdp);
 	lance_reset(dev);
 	netif_wake_queue(dev);
 }
 
-static netdev_tx_t lance_start_xmit (struct sk_buff *skb,
-				     struct net_device *dev)
+static netdev_tx_t lance_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
@@ -557,33 +547,33 @@ static netdev_tx_t lance_start_xmit (struct sk_buff *skb,
 
 	local_irq_save(flags);
 
-	if (!TX_BUFFS_AVAIL){
+	if (!lance_tx_buffs_avail(lp)) {
 		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
 	}
 
-#ifdef DEBUG_DRIVER
+#ifdef DEBUG
 	/* dump the packet */
 	print_hex_dump(KERN_DEBUG, "skb->data: ", DUMP_PREFIX_NONE,
 		       16, 1, skb->data, 64, true);
 #endif
 	entry = lp->tx_new & lp->tx_ring_mod_mask;
-	ib->btx_ring [entry].length = (-skblen) | 0xf000;
-	ib->btx_ring [entry].misc = 0;
+	ib->btx_ring[entry].length = (-skblen) | 0xf000;
+	ib->btx_ring[entry].misc = 0;
 
-	skb_copy_from_linear_data(skb, (void *)&ib->tx_buf [entry][0], skblen);
+	skb_copy_from_linear_data(skb, (void *)&ib->tx_buf[entry][0], skblen);
 
 	/* Now, give the packet to the lance */
-	ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
+	ib->btx_ring[entry].tmd1_bits = (LE_T1_POK | LE_T1_OWN);
 	lp->tx_new = (lp->tx_new+1) & lp->tx_ring_mod_mask;
 	dev->stats.tx_bytes += skblen;
 
-	if (TX_BUFFS_AVAIL <= 0)
+	if (lance_tx_buffs_avail(lp) <= 0)
 		netif_stop_queue(dev);
 
 	/* Kick the lance: transmit now */
 	ll->rdp = LE_C0_INEA | LE_C0_TDMD;
-	dev_kfree_skb (skb);
+	dev_kfree_skb(skb);
 
 	local_irq_restore(flags);
 
@@ -591,7 +581,7 @@ static netdev_tx_t lance_start_xmit (struct sk_buff *skb,
 }
 
 /* taken from the depca driver */
-static void lance_load_multicast (struct net_device *dev)
+static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
@@ -601,14 +591,14 @@ static void lance_load_multicast (struct net_device *dev)
 	u32 crc;
 
 	/* set all multicast bits */
-	if (dev->flags & IFF_ALLMULTI){
-		ib->filter [0] = 0xffffffff;
-		ib->filter [1] = 0xffffffff;
+	if (dev->flags & IFF_ALLMULTI) {
+		ib->filter[0] = 0xffffffff;
+		ib->filter[1] = 0xffffffff;
 		return;
 	}
 	/* clear the multicast filter */
-	ib->filter [0] = 0;
-	ib->filter [1] = 0;
+	ib->filter[0] = 0;
+	ib->filter[1] = 0;
 
 	/* Add addresses */
 	netdev_for_each_mc_addr(ha, dev) {
@@ -620,11 +610,11 @@ static void lance_load_multicast (struct net_device *dev)
 
 		crc = ether_crc_le(6, addrs);
 		crc = crc >> 26;
-		mcast_table [crc >> 4] |= 1 << (crc & 0xf);
+		mcast_table[crc >> 4] |= 1 << (crc & 0xf);
 	}
 }
 
-static void lance_set_multicast (struct net_device *dev)
+static void lance_set_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
@@ -643,16 +633,16 @@ static void lance_set_multicast (struct net_device *dev)
 
 	ll->rap = LE_CSR0;
 	ll->rdp = LE_C0_STOP;
-	lance_init_ring (dev);
+	lance_init_ring(dev);
 
 	if (dev->flags & IFF_PROMISC) {
 		ib->mode |= LE_MO_PROM;
 	} else {
 		ib->mode &= ~LE_MO_PROM;
-		lance_load_multicast (dev);
+		lance_load_multicast(dev);
 	}
-	load_csrs (lp);
-	init_restart_lance (lp);
+	load_csrs(lp);
+	init_restart_lance(lp);
 	netif_wake_queue(dev);
 }
 
@@ -692,14 +682,12 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 {
 	struct net_device *dev;
 	struct lance_private *priv;
-	unsigned long board, base_addr, mem_start;
+	unsigned long board = z->resource.start;
+	unsigned long base_addr = board + A2065_LANCE;
+	unsigned long mem_start = board + A2065_RAM;
 	struct resource *r1, *r2;
 	int err;
 
-	board = z->resource.start;
-	base_addr = board+A2065_LANCE;
-	mem_start = board+A2065_RAM;
-
 	r1 = request_mem_region(base_addr, sizeof(struct lance_regs),
 				"Am7990");
 	if (!r1)
@@ -730,12 +718,12 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 		dev->dev_addr[1] = 0x00;
 		dev->dev_addr[2] = 0x9f;
 	}
-	dev->dev_addr[3] = (z->rom.er_SerialNumber>>16) & 0xff;
-	dev->dev_addr[4] = (z->rom.er_SerialNumber>>8) & 0xff;
+	dev->dev_addr[3] = (z->rom.er_SerialNumber >> 16) & 0xff;
+	dev->dev_addr[4] = (z->rom.er_SerialNumber >> 8) & 0xff;
 	dev->dev_addr[5] = z->rom.er_SerialNumber & 0xff;
 	dev->base_addr = ZTWO_VADDR(base_addr);
 	dev->mem_start = ZTWO_VADDR(mem_start);
-	dev->mem_end = dev->mem_start+A2065_RAM_SIZE;
+	dev->mem_end = dev->mem_start + A2065_RAM_SIZE;
 
 	priv->ll = (volatile struct lance_regs *)dev->base_addr;
 	priv->init_block = (struct lance_init_block *)dev->mem_start;
@@ -755,7 +743,7 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 	init_timer(&priv->multicast_timer);
 	priv->multicast_timer.data = (unsigned long) dev;
 	priv->multicast_timer.function =
-		(void (*)(unsigned long)) &lance_set_multicast;
+		(void (*)(unsigned long))lance_set_multicast;
 
 	err = register_netdev(dev);
 	if (err) {
@@ -766,8 +754,8 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 	}
 	zorro_set_drvdata(z, dev);
 
-	printk(KERN_INFO "%s: A2065 at 0x%08lx, Ethernet Address "
-	       "%pM\n", dev->name, board, dev->dev_addr);
+	netdev_info(dev, "A2065 at 0x%08lx, Ethernet Address %pM\n",
+		    board, dev->dev_addr);
 
 	return 0;
 }
-- 
1.7.6.rc3
