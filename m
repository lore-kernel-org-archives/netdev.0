From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.6.3 pcnet32.c transmit hang fix
Date: Wed, 18 Feb 2004 16:14:30 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402190014.i1J0EUo03980@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The transmit routine will stop interrupting and hang, causing the
tx_timeout routine to attempt to restart the device when the 32-bit
cur_tx counter wraps below dirty_tx.  If the device had called
netif_stop_queue it will never call netif_wake_queue in the interrupt
routine (at least on an IA32 system) due to 32-bit wrap around arithmetic.

On my IA32 system 'dirty_tx > lp->cur_tx - TX_RING_SIZE + 2' would
always evaluate to false when dirty and cur_tx were less than 15,
preventing netif_wake_queue to be called.

By starting dirty_tx and cur_tx at 0xfffffff0 (to reduce test time) I
found that once cur_tx wrapped to zero, that transmitted buffers would
never be unmapped or freed because 'while (dirty_tx < lp->cur_tx) {'
was not true.  cur_tx would keep incrementing (in start_xmit) but dirty_tx
would not (in pcnet32_interrupt), thus leaking skb's and pci map entries.
On PPC machines, the system would quickly run out of pci maps.

Fix tested on PPC and IA32.


--- linux-2.6.3/drivers/net/slab.pcnet32.c	Wed Feb 18 15:26:43 2004
+++ linux-2.6.3/drivers/net/pcnet32.c	Wed Feb 18 15:36:59 2004
@@ -1082,7 +1082,7 @@
 	pcnet32_restart(dev, 0x0042);
 
 	dev->trans_start = jiffies;
-	netif_start_queue(dev);
+	netif_wake_queue(dev);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
@@ -1108,9 +1108,10 @@
      * interrupt when that option is available to us.
      */
     status = 0x8300;
+    entry = (lp->cur_tx - lp->dirty_tx) & TX_RING_MOD_MASK;
     if ((lp->ltint) &&
-	((lp->cur_tx - lp->dirty_tx == TX_RING_SIZE/2) ||
-	 (lp->cur_tx - lp->dirty_tx >= TX_RING_SIZE-2)))
+	((entry == TX_RING_SIZE/2) ||
+	 (entry >= TX_RING_SIZE-2)))
     {
 	/* Enable Successful-TxDone interrupt if we have
 	 * 1/2 of, or nearly all of, our ring buffer Tx'd
@@ -1125,7 +1126,7 @@
     /* Mask to ring buffer boundary. */
     entry = lp->cur_tx & TX_RING_MOD_MASK;
   
-    /* Caution: the write order is important here, set the base address
+    /* Caution: the write order is important here, set the status
        with the "ownership" bits last. */
 
     lp->tx_ring[entry].length = le16_to_cpu(-skb->len);
@@ -1147,7 +1148,7 @@
     dev->trans_start = jiffies;
 
     if (lp->tx_ring[(entry+1) & TX_RING_MOD_MASK].base == 0)
-	netif_start_queue(dev);
+	netif_wake_queue(dev);
     else {
 	lp->tx_full = 1;
 	netif_stop_queue(dev);
@@ -1194,8 +1195,9 @@
 
 	if (csr0 & 0x0200) {		/* Tx-done interrupt */
 	    unsigned int dirty_tx = lp->dirty_tx;
+	    int delta;
 
-	    while (dirty_tx < lp->cur_tx) {
+	    while (dirty_tx != lp->cur_tx) {
 		int entry = dirty_tx & TX_RING_MOD_MASK;
 		int status = (short)le16_to_cpu(lp->tx_ring[entry].status);
 			
@@ -1249,15 +1251,17 @@
 		dirty_tx++;
 	    }
 
-	    if (lp->cur_tx - dirty_tx >= TX_RING_SIZE) {
+	    delta = (lp->cur_tx - dirty_tx) & (TX_RING_MOD_MASK + TX_RING_SIZE);
+	    if (delta >= TX_RING_SIZE) {
 		printk(KERN_ERR "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
 			dev->name, dirty_tx, lp->cur_tx, lp->tx_full);
 		dirty_tx += TX_RING_SIZE;
+		delta -= TX_RING_SIZE;
 	    }
 
 	    if (lp->tx_full &&
 		netif_queue_stopped(dev) &&
-		dirty_tx > lp->cur_tx - TX_RING_SIZE + 2) {
+		delta < TX_RING_SIZE - 2) {
 		/* The ring is no longer full, clear tbusy. */
 		lp->tx_full = 0;
 		netif_wake_queue (dev);

-- 
Don Fry
brazilnut@us.ibm.com
