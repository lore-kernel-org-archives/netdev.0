From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/4] 2.6.5-rc2 - epic100 napi
Date: Tue, 23 Mar 2004 00:53:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040323005312.D1715@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <20040323005021.A1715@electric-eye.fr.zoreil.com> <20040323005114.B1715@electric-eye.fr.zoreil.com> <20040323005218.C1715@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040323005218.C1715@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Tue, Mar 23, 2004 at 12:52:18AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


RX NAPI.


 drivers/net/epic100.c |  137 ++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 116 insertions(+), 21 deletions(-)

diff -puN drivers/net/epic100.c~epic100-napi-10 drivers/net/epic100.c
--- linux-2.6.5-rc2/drivers/net/epic100.c~epic100-napi-10	2004-03-22 22:53:19.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/epic100.c	2004-03-23 00:18:33.000000000 +0100
@@ -98,7 +98,7 @@ static int rx_copybreak;
    There are no ill effects from too-large receive rings. */
 #define TX_RING_SIZE	16
 #define TX_QUEUE_LEN	10		/* Limit ring entries actually used.  */
-#define RX_RING_SIZE	32
+#define RX_RING_SIZE	256
 #define TX_TOTAL_SIZE	TX_RING_SIZE*sizeof(struct epic_tx_desc)
 #define RX_TOTAL_SIZE	RX_RING_SIZE*sizeof(struct epic_rx_desc)
 
@@ -292,6 +292,11 @@ enum CommandBits {
 	StopTxDMA=0x20, StopRxDMA=0x40, RestartTx=0x80,
 };
 
+#define EpicRemoved	0xffffffff	/* Chip failed or removed (CardBus) */
+
+#define EpicNapiEvent	(RxDone | RxStarted | RxEarlyWarn | RxOverflow | RxFull)
+#define EpicNormalEvent	(0x0000ffff & ~EpicNapiEvent)
+
 static u16 media2miictl[16] = {
 	0, 0x0C00, 0x0C00, 0x2000,  0x0100, 0x2100, 0, 0,
 	0, 0, 0, 0,  0, 0, 0, 0 };
@@ -330,9 +335,11 @@ struct epic_private {
 
 	/* Ring pointers. */
 	spinlock_t lock;				/* Group with Tx control cache line. */
+	spinlock_t napi_lock;
 	unsigned int cur_tx, dirty_tx;
 
 	unsigned int cur_rx, dirty_rx;
+	u32 irq_mask;
 	unsigned int rx_buf_sz;				/* Based on MTU+slack. */
 
 	struct pci_dev *pci_dev;			/* PCI bus location. */
@@ -359,7 +366,8 @@ static void epic_timer(unsigned long dat
 static void epic_tx_timeout(struct net_device *dev);
 static void epic_init_ring(struct net_device *dev);
 static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static int epic_rx(struct net_device *dev);
+static int epic_rx(struct net_device *dev, int budget);
+static int epic_poll(struct net_device *dev, int *budget);
 static irqreturn_t epic_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static struct ethtool_ops netdev_ethtool_ops;
@@ -493,6 +501,9 @@ static int __devinit epic_init_one (stru
 	ep->pci_dev = pdev;
 	ep->chip_id = chip_idx;
 	ep->chip_flags = pci_id_tbl[chip_idx].drv_flags;
+	ep->irq_mask = 
+		(ep->chip_flags & TYPE2_INTR ?  PCIBusErr175 : PCIBusErr170)
+		 | CntFull | TxUnderrun | TxDone | TxEmpty | EpicNapiEvent;
 
 	/* Find the connected MII xcvrs.
 	   Doing this in open() would allow detecting external xcvrs later, but
@@ -547,6 +558,8 @@ static int __devinit epic_init_one (stru
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->tx_timeout = &epic_tx_timeout;
+	dev->poll = epic_poll;
+	dev->weight = 64;
 
 	ret = register_netdev(dev);
 	if (ret < 0)
@@ -608,6 +621,29 @@ static void epic_disable_int(struct net_
 	outl(0x00000000, ioaddr + INTMASK);
 }
 
+static inline void __epic_pci_commit(long ioaddr)
+{
+#ifndef USE_IO_OPS
+	inl(ioaddr + INTMASK);
+#endif
+}
+
+static void epic_napi_irq_off(struct net_device *dev, struct epic_private *ep)
+{
+	long ioaddr = dev->base_addr;
+
+	outl(ep->irq_mask & ~EpicNapiEvent, ioaddr + INTMASK);
+	__epic_pci_commit(ioaddr);
+}
+
+static void epic_napi_irq_on(struct net_device *dev, struct epic_private *ep)
+{
+	long ioaddr = dev->base_addr;
+
+	/* No need to commit possible posted write */
+	outl(ep->irq_mask | EpicNapiEvent, ioaddr + INTMASK);
+}
+
 static int __devinit read_eeprom(long ioaddr, int location)
 {
 	int i;
@@ -769,8 +805,7 @@ static int epic_open(struct net_device *
 	/* Enable interrupts by setting the interrupt mask. */
 	outl((ep->chip_flags & TYPE2_INTR ? PCIBusErr175 : PCIBusErr170)
 		 | CntFull | TxUnderrun | TxDone | TxEmpty
-		 | RxError | RxOverflow | RxFull | RxHeader | RxDone,
-		 ioaddr + INTMASK);
+		 | RxError | RxHeader | EpicNapiEvent, ioaddr + INTMASK);
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: epic_open() ioaddr %lx IRQ %d status %4.4x "
@@ -811,7 +846,7 @@ static void epic_pause(struct net_device
 	}
 
 	/* Remove the packets on the Rx queue. */
-	epic_rx(dev);
+	epic_rx(dev, RX_RING_SIZE);
 }
 
 static void epic_restart(struct net_device *dev)
@@ -858,8 +893,8 @@ static void epic_restart(struct net_devi
 	/* Enable interrupts by setting the interrupt mask. */
 	outl((ep->chip_flags & TYPE2_INTR ? PCIBusErr175 : PCIBusErr170)
 		 | CntFull | TxUnderrun | TxDone | TxEmpty
-		 | RxError | RxOverflow | RxFull | RxHeader | RxDone,
-		 ioaddr + INTMASK);
+		 | RxError | RxHeader | EpicNapiEvent, ioaddr + INTMASK);
+
 	printk(KERN_DEBUG "%s: epic_restart() done, cmd status %4.4x, ctl %4.4x"
 		   " interrupt %4.4x.\n",
 		   dev->name, (int)inl(ioaddr + COMMAND), (int)inl(ioaddr + GENCTL),
@@ -945,7 +980,8 @@ static void epic_init_ring(struct net_de
 	int i;
 
 	ep->tx_full = 0;
-	ep->lock = (spinlock_t) SPIN_LOCK_UNLOCKED;
+	spin_lock_init(&ep->lock);
+	spin_lock_init(&ep->napi_lock);
 	ep->dirty_tx = ep->cur_tx = 0;
 	ep->cur_rx = ep->dirty_rx = 0;
 	ep->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
@@ -1131,7 +1167,7 @@ static irqreturn_t epic_interrupt(int ir
 	do {
 		status = inl(ioaddr + INTSTAT);
 		/* Acknowledge all of the current interrupt sources ASAP. */
-		outl(status & 0x00007fff, ioaddr + INTSTAT);
+		outl(status & EpicNormalEvent, ioaddr + INTSTAT);
 
 		if (debug > 4)
 			printk(KERN_DEBUG "%s: Interrupt, status=%#8.8x new "
@@ -1142,16 +1178,22 @@ static irqreturn_t epic_interrupt(int ir
 			break;
 		handled = 1;
 
-		if (status & (RxDone | RxStarted | RxEarlyWarn | RxOverflow))
-			epic_rx(dev);
+		if (status & EpicNapiEvent) {
+			spin_lock(&ep->napi_lock);
+			if (netif_rx_schedule_prep(dev)) {
+				epic_napi_irq_off(dev, ep);
+				__netif_rx_schedule(dev);
+			}
+			spin_unlock(&ep->napi_lock);
+		}
 
 		if (status & (TxEmpty | TxDone))
 			epic_tx(dev, ep);
 
 		/* Check uncommon events all at once. */
-		if (status & (CntFull | TxUnderrun | RxOverflow | RxFull |
-					  PCIBusErr170 | PCIBusErr175)) {
-			if (status == 0xffffffff) /* Chip failed or removed (CardBus). */
+		if (status &
+		    (CntFull | TxUnderrun | PCIBusErr170 | PCIBusErr175)) {
+			if (status == EpicRemoved)
 				break;
 			/* Always update the error counts to avoid overhead later. */
 			ep->stats.rx_missed_errors += inb(ioaddr + MPCNT);
@@ -1164,11 +1206,6 @@ static irqreturn_t epic_interrupt(int ir
 				/* Restart the transmit process. */
 				outl(RestartTx, ioaddr + COMMAND);
 			}
-			if (status & RxOverflow) {	/* Missed a Rx frame. */
-				ep->stats.rx_errors++;
-			}
-			if (status & (RxOverflow | RxFull))
-				outw(RxQueued, ioaddr + COMMAND);
 			if (status & PCIBusErr170) {
 				printk(KERN_ERR "%s: PCI Bus Error!  EPIC status %4.4x.\n",
 					   dev->name, status);
@@ -1178,6 +1215,8 @@ static irqreturn_t epic_interrupt(int ir
 			/* Clear all error sources. */
 			outl(status & 0x7f18, ioaddr + INTSTAT);
 		}
+		if (status & EpicNormalEvent)
+			break;
 		if (--boguscnt < 0) {
 			printk(KERN_ERR "%s: Too much work at interrupt, "
 				   "IntrStatus=0x%8.8x.\n",
@@ -1195,7 +1234,7 @@ static irqreturn_t epic_interrupt(int ir
 	return IRQ_RETVAL(handled);
 }
 
-static int epic_rx(struct net_device *dev)
+static int epic_rx(struct net_device *dev, int budget)
 {
 	struct epic_private *ep = dev->priv;
 	int entry = ep->cur_rx % RX_RING_SIZE;
@@ -1205,6 +1244,10 @@ static int epic_rx(struct net_device *de
 	if (debug > 4)
 		printk(KERN_DEBUG " In epic_rx(), entry %d %8.8x.\n", entry,
 			   ep->rx_ring[entry].rxstatus);
+
+	if (rx_work_limit > budget)
+		rx_work_limit = budget;
+
 	/* If we own the next entry, it's a new packet. Send it up. */
 	while ((ep->rx_ring[entry].rxstatus & cpu_to_le32(DescOwn)) == 0) {
 		int status = le32_to_cpu(ep->rx_ring[entry].rxstatus);
@@ -1265,7 +1308,7 @@ static int epic_rx(struct net_device *de
 				ep->rx_skbuff[entry] = NULL;
 			}
 			skb->protocol = eth_type_trans(skb, dev);
-			netif_rx(skb);
+			netif_receive_skb(skb);
 			dev->last_rx = jiffies;
 			ep->stats.rx_packets++;
 			ep->stats.rx_bytes += pkt_len;
@@ -1293,6 +1336,58 @@ static int epic_rx(struct net_device *de
 	return work_done;
 }
 
+static void epic_rx_err(struct net_device *dev, struct epic_private *ep)
+{
+	long ioaddr = dev->base_addr;
+	int status;
+
+	status = inl(ioaddr + INTSTAT);
+
+	if (status == EpicRemoved)
+		return;
+	if (status & RxOverflow) 	/* Missed a Rx frame. */
+		ep->stats.rx_errors++;
+	if (status & (RxOverflow | RxFull))
+		outw(RxQueued, ioaddr + COMMAND);
+}
+
+static int epic_poll(struct net_device *dev, int *budget)
+{
+	struct epic_private *ep = dev->priv;
+	int work_done, orig_budget;
+	long ioaddr = dev->base_addr;
+
+	orig_budget = (*budget > dev->quota) ? dev->quota : *budget;
+
+rx_action:
+	outl(EpicNapiEvent, ioaddr + INTSTAT);
+
+	work_done = epic_rx(dev, *budget);
+
+	epic_rx_err(dev, ep);
+
+	*budget -= work_done;
+	dev->quota -= work_done;
+
+	if (netif_running(dev) && (work_done < orig_budget)) {
+		unsigned long flags;
+		int status;
+
+		spin_lock_irqsave(&ep->napi_lock, flags);
+		epic_napi_irq_on(dev, ep);
+		__netif_rx_complete(dev);
+		spin_unlock_irqrestore(&ep->napi_lock, flags);
+
+		status = inl(ioaddr + INTSTAT);
+		if (status & EpicNapiEvent) {
+			epic_napi_irq_off(dev, ep);
+			goto rx_action;
+		}
+	}
+
+	return (work_done >= orig_budget);
+}
+
 static int epic_close(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;

_
