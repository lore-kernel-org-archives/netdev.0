From: "Krishnakumar. R" <krishnakumar@naturesoft.net>
Subject: [PATCH] 8139too.c Network interface messages
Date: Thu, 9 Oct 2003 12:41:26 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310091241.26027.krishnakumar@naturesoft.net>
Reply-To: krishnakumar@naturesoft.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch enables the network interface message
settings in the Realtek 8139 driver - 8139too.c.
The patch is against 2.6.0-test6 kernel.

It introduces the new variable in the private
structure of the 8139too (msg_enable) and 
various debug printks can be activated
and deactivated (using the ethtool)
after the patch is applied.

The following kernel apis for the Network interface logging
has been introduced into the 8139too.c by this patch.

1. netif_msg_link
2. netif_msg_ifdown
3. netif_msg_ifup
4. netif_msg_rx_err
5. netif_msg_tx_err
6. netif_msg_tx_queued
7. netif_msg_intr
8. netif_msg_rx_status

>From this I have tested the 1,2,3,6,7 and 8 with
the ethtool.

Regards
KK


diffstat output:
--------------------
 8139too.c |   50 ++++++++++++++++++++++++++++++++------------------
 1 files changed, 32 insertions(+), 18 deletions(-)

The patch
---------------

--- linux-2.6.0-test6/drivers/net/8139too.orig.c	2003-09-28 06:20:05.000000000 +0530
+++ linux-2.6.0-test6/drivers/net/8139too.c	2003-10-09 12:12:40.787777240 +0530
@@ -117,6 +117,11 @@
 #define RTL8139_DRIVER_NAME   DRV_NAME " Fast Ethernet driver " DRV_VERSION
 #define PFX DRV_NAME ": "
 
+/* Default Message level */
+#define RTL8139_DEF_MSG_ENABLE   (NETIF_MSG_DRV   | \
+                                 NETIF_MSG_PROBE  | \
+                                 NETIF_MSG_LINK)
+
 
 /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
 #ifdef CONFIG_8139TOO_PIO
@@ -557,6 +562,7 @@
 	int drv_flags;
 	struct pci_dev *pci_dev;
 	u32 pci_state[16];
+	u32 msg_enable;
 	struct net_device_stats stats;
 	unsigned char *rx_ring;
 	unsigned int cur_rx;	/* Index into the Rx buffer of next Rx pkt. */
@@ -983,6 +989,7 @@
 	/* note: tp->chipset set in rtl8139_init_board */
 	tp->drv_flags = board_info[ent->driver_data].hw_flags;
 	tp->mmio_addr = ioaddr;
+	tp->msg_enable = (debug < 0 ? RTL8139_DEF_MSG_ENABLE : debug);
 	spin_lock_init (&tp->lock);
 	init_waitqueue_head (&tp->thr_wait);
 	init_completion (&tp->thr_exited);
@@ -1285,9 +1292,7 @@
 {
 	struct rtl8139_private *tp = dev->priv;
 	int retval;
-#ifdef RTL8139_DEBUG
 	void *ioaddr = tp->mmio_addr;
-#endif
 
 	retval = request_irq (dev->irq, rtl8139_interrupt, SA_SHIRQ, dev->name, dev);
 	if (retval)
@@ -1317,7 +1322,8 @@
 	rtl8139_init_ring (dev);
 	rtl8139_hw_start (dev);
 
-	DPRINTK ("%s: rtl8139_open() ioaddr %#lx IRQ %d"
+	if (netif_msg_ifup(tp))
+		printk(KERN_DEBUG "%s: rtl8139_open() ioaddr %#lx IRQ %d"
 			" GP Pins %2.2x %s-duplex.\n",
 			dev->name, pci_resource_start (tp->pci_dev, 1),
 			dev->irq, RTL_R8 (MediaStatus),
@@ -1334,7 +1340,7 @@
 	struct rtl8139_private *tp = dev->priv;
 
 	if (tp->phys[0] >= 0) {
-		mii_check_media(&tp->mii, 1, init_media);
+		mii_check_media(&tp->mii, netif_msg_link(tp), init_media);
 	}
 }
 
@@ -1717,8 +1723,9 @@
 		netif_stop_queue (dev);
 	spin_unlock_irq(&tp->lock);
 
-	DPRINTK ("%s: Queued Tx packet size %u to slot %d.\n",
-		 dev->name, len, entry);
+	if (netif_msg_tx_queued(tp))
+		printk (KERN_DEBUG "%s: Queued Tx packet size %u to slot %d.\n",
+			dev->name, len, entry);
 
 	return 0;
 }
@@ -1748,8 +1755,9 @@
 		/* Note: TxCarrierLost is always asserted at 100mbps. */
 		if (txstatus & (TxOutOfWindow | TxAborted)) {
 			/* There was an major error, log it. */
-			DPRINTK ("%s: Transmit error, Tx status %8.8x.\n",
-				 dev->name, txstatus);
+			if (netif_msg_tx_err(tp))
+				printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
+					dev->name, txstatus);
 			tp->stats.tx_errors++;
 			if (txstatus & TxAborted) {
 				tp->stats.tx_aborted_errors++;
@@ -1804,8 +1812,9 @@
 	int tmp_work;
 #endif
 
-	DPRINTK ("%s: Ethernet frame had errors, status %8.8x.\n",
-	         dev->name, rx_status);
+	if (netif_msg_rx_err (tp)) 
+		printk(KERN_DEBUG "%s: Ethernet frame had errors, status %8.8x.\n",
+			dev->name, rx_status);
 	tp->stats.rx_errors++;
 	if (!(rx_status & RxStatusOK)) {
 		if (rx_status & RxTooLong) {
@@ -1909,8 +1918,9 @@
 		rx_size = rx_status >> 16;
 		pkt_size = rx_size - 4;
 
-		DPRINTK ("%s:  rtl8139_rx() status %4.4x, size %4.4x,"
-			 " cur %4.4x.\n", dev->name, rx_status,
+		if (netif_msg_rx_status(tp))
+			printk(KERN_DEBUG "%s:  rtl8139_rx() status %4.4x, size %4.4x,"
+				" cur %4.4x.\n", dev->name, rx_status,
 			 rx_size, cur_rx);
 #if RTL8139_DEBUG > 2
 		{
@@ -2071,8 +2081,9 @@
 		ackstat = status & ~(RxAckBits | TxErr);
 		RTL_W16 (IntrStatus, ackstat);
 
-		DPRINTK ("%s: interrupt  status=%#4.4x ackstat=%#4.4x new intstat=%#4.4x.\n",
-			 dev->name, status, ackstat, RTL_R16 (IntrStatus));
+		if (netif_msg_intr(tp))
+			printk (KERN_DEBUG "%s: interrupt  status=%#4.4x ackstat=%#4.4x new intstat=%#4.4x.\n",
+				dev->name, status, ackstat, RTL_R16 (IntrStatus));
 
 		if (netif_running (dev) && (status & RxAckBits))
 			rtl8139_rx_interrupt (dev, tp, ioaddr);
@@ -2127,8 +2138,9 @@
 		}
 		wait_for_completion (&tp->thr_exited);
 	}
-
-	DPRINTK ("%s: Shutting down ethercard, status was 0x%4.4x.\n",
+	
+	if (netif_msg_ifdown(tp))
+		printk(KERN_DEBUG "%s: Shutting down ethercard, status was 0x%4.4x.\n",
 			dev->name, RTL_R16 (IntrStatus));
 
 	spin_lock_irqsave (&tp->lock, flags);
@@ -2286,12 +2298,14 @@
 
 static u32 rtl8139_get_msglevel(struct net_device *dev)
 {
-	return debug;
+	struct rtl8139_private *np = dev->priv;
+	return np->msg_enable;
 }
 
 static void rtl8139_set_msglevel(struct net_device *dev, u32 datum)
 {
-	debug = datum;
+	struct rtl8139_private *np = dev->priv;
+	np->msg_enable = datum;
 }
 
 /* TODO: we are too slack to do reg dumping for pio, for now */
