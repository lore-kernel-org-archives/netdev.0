From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/4] 2.6.5-rc2 - epic100 napi
Date: Tue, 23 Mar 2004 00:53:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040323005354.E1715@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <20040323005021.A1715@electric-eye.fr.zoreil.com> <20040323005114.B1715@electric-eye.fr.zoreil.com> <20040323005218.C1715@electric-eye.fr.zoreil.com> <20040323005312.D1715@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040323005312.D1715@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Tue, Mar 23, 2004 at 12:53:12AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


TX NAPI.


 drivers/net/epic100.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff -puN drivers/net/epic100.c~epic100-napi-20 drivers/net/epic100.c
--- linux-2.6.5-rc2/drivers/net/epic100.c~epic100-napi-20	2004-03-23 00:18:40.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/epic100.c	2004-03-23 00:18:40.000000000 +0100
@@ -96,8 +96,8 @@ static int rx_copybreak;
    Making the Tx ring too large decreases the effectiveness of channel
    bonding and packet priority.
    There are no ill effects from too-large receive rings. */
-#define TX_RING_SIZE	16
-#define TX_QUEUE_LEN	10		/* Limit ring entries actually used.  */
+#define TX_RING_SIZE	256
+#define TX_QUEUE_LEN	240		/* Limit ring entries actually used.  */
 #define RX_RING_SIZE	256
 #define TX_TOTAL_SIZE	TX_RING_SIZE*sizeof(struct epic_tx_desc)
 #define RX_TOTAL_SIZE	RX_RING_SIZE*sizeof(struct epic_rx_desc)
@@ -294,7 +294,8 @@ enum CommandBits {
 
 #define EpicRemoved	0xffffffff	/* Chip failed or removed (CardBus) */
 
-#define EpicNapiEvent	(RxDone | RxStarted | RxEarlyWarn | RxOverflow | RxFull)
+#define EpicNapiEvent	(TxEmpty | TxDone | \
+			 RxDone | RxStarted | RxEarlyWarn | RxOverflow | RxFull)
 #define EpicNormalEvent	(0x0000ffff & ~EpicNapiEvent)
 
 static u16 media2miictl[16] = {
@@ -503,7 +504,7 @@ static int __devinit epic_init_one (stru
 	ep->chip_flags = pci_id_tbl[chip_idx].drv_flags;
 	ep->irq_mask = 
 		(ep->chip_flags & TYPE2_INTR ?  PCIBusErr175 : PCIBusErr170)
-		 | CntFull | TxUnderrun | TxDone | TxEmpty | EpicNapiEvent;
+		 | CntFull | TxUnderrun | EpicNapiEvent;
 
 	/* Find the connected MII xcvrs.
 	   Doing this in open() would allow detecting external xcvrs later, but
@@ -804,7 +805,7 @@ static int epic_open(struct net_device *
 
 	/* Enable interrupts by setting the interrupt mask. */
 	outl((ep->chip_flags & TYPE2_INTR ? PCIBusErr175 : PCIBusErr170)
-		 | CntFull | TxUnderrun | TxDone | TxEmpty
+		 | CntFull | TxUnderrun 
 		 | RxError | RxHeader | EpicNapiEvent, ioaddr + INTMASK);
 
 	if (debug > 1)
@@ -892,7 +893,7 @@ static void epic_restart(struct net_devi
 
 	/* Enable interrupts by setting the interrupt mask. */
 	outl((ep->chip_flags & TYPE2_INTR ? PCIBusErr175 : PCIBusErr170)
-		 | CntFull | TxUnderrun | TxDone | TxEmpty
+		 | CntFull | TxUnderrun
 		 | RxError | RxHeader | EpicNapiEvent, ioaddr + INTMASK);
 
 	printk(KERN_DEBUG "%s: epic_restart() done, cmd status %4.4x, ctl %4.4x"
@@ -1111,7 +1112,6 @@ static void epic_tx(struct net_device *d
 	 * Note: if this lock becomes a problem we can narrow the locked
 	 * region at the cost of occasionally grabbing the lock more times.
 	 */
-	spin_lock(&ep->lock);
 	cur_tx = ep->cur_tx;
 	for (dirty_tx = ep->dirty_tx; cur_tx - dirty_tx > 0; dirty_tx++) {
 		struct sk_buff *skb;
@@ -1150,7 +1150,6 @@ static void epic_tx(struct net_device *d
 		ep->tx_full = 0;
 		netif_wake_queue(dev);
 	}
-	spin_unlock(&ep->lock);
 }
 
 
@@ -1187,9 +1186,6 @@ static irqreturn_t epic_interrupt(int ir
 			spin_unlock(&ep->napi_lock);
 		}
 
-		if (status & (TxEmpty | TxDone))
-			epic_tx(dev, ep);
-
 		/* Check uncommon events all at once. */
 		if (status &
 		    (CntFull | TxUnderrun | PCIBusErr170 | PCIBusErr175)) {
@@ -1362,6 +1358,8 @@ static int epic_poll(struct net_device *
 rx_action:
 	outl(EpicNapiEvent, ioaddr + INTSTAT);
 
+	epic_tx(dev, ep);
+
 	work_done = epic_rx(dev, *budget);
 
 	epic_rx_err(dev, ep);

_
