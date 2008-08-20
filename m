From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver
 code
Date: Wed, 20 Aug 2008 20:54:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808202051550.3501@melkki.cs.Helsinki.FI>
References: <20080813.033749.165504341.davem@davemloft.net>
 <84144f020808140628m31d6d099t1fecdb1701c0bbdc@mail.gmail.com>
 <Pine.LNX.4.64.0808141643200.3164@sbz-30.cs.Helsinki.FI>
 <20080814.151502.251134900.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, vegardno@ifi.uio.no,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, adobriyan@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54272 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbYHTRyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 13:54:05 -0400
In-Reply-To: <20080814.151502.251134900.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Aug 2008, David Miller wrote:
> From: Pekka J Enberg <penberg@cs.helsinki.fi>
> Date: Thu, 14 Aug 2008 16:44:32 +0300 (EEST)
> 
> > @@ -598,6 +598,7 @@
> >  
> >  	spinlock_t		lock;
> >  	spinlock_t		rx_lock;
> > +	spinlock_t		tx_lock;
> >  
> >  	chip_t			chipset;
> >  	u32			rx_config;
> 
> Why create a special purpose lock when the generic networking
> already is taking a lock for you to proect the TX path?

Heh, no reason, just my ignorance of the networking layer... Does this 
look more like it?

		Pekka

Subject: [PATCH] 8139too: avoid deadlock with netconsole
From: Pekka Enberg <penberg@cs.helsinki.fi>

As explained by Vegard Nossum, the 8139too driver can deadlock with netconsole:

  I encountered a hard-to-debug deadlock when I pulled out the plug of my
  RealTek 8139 which was also running netconsole: The driver wants to print a
  "link down" message. However, this triggers netconsole, which wants to print
  the message using the same device. Here is a backtrace:

     [<c05916b6>] _spin_lock_irqsave+0x76/0x90
     [<c035b255>] rtl8139_start_xmit+0x65/0x130 <-- spin_lock(&tp->lock)
     [<c04c5e28>] netpoll_send_skb+0x158/0x1a0
     [<c04c62fb>] netpoll_send_udp+0x1db/0x1f0
     [<c037c70c>] write_msg+0x8c/0xc0
     [<c0135883>] __call_console_drivers+0x53/0x60
     [<c01358db>] _call_console_drivers+0x4b/0x90
     [<c0135a25>] release_console_sem+0xc5/0x1f0
     [<c0135f0b>] vprintk+0x1ab/0x3e0
     [<c013615b>] printk+0x1b/0x20
     [<c0349736>] mii_check_media+0x196/0x1e0
     [<c03597f4>] rtl_check_media+0x24/0x30
     [<c035a0ea>] rtl8139_interrupt+0x42a/0x4a0 <-- spin_lock(&tp->lock)
     [<c01716d8>] handle_IRQ_event+0x28/0x70
     [<c0172d9b>] handle_fasteoi_irq+0x6b/0xe0
     [<c0107128>] do_IRQ+0x48/0xa0

To avoid the deadlock, use netif_tx_lock() for the TX paths and make sure we
never call printk() while holding that lock as suggested by David Miller.

Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Jeff Garzik <jgarzik@pobox.com>
Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/8139too.c |   35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

Index: linux-2.6/drivers/net/8139too.c
===================================================================
--- linux-2.6.orig/drivers/net/8139too.c
+++ linux-2.6/drivers/net/8139too.c
@@ -1675,9 +1675,11 @@ static void rtl8139_tx_timeout_task (str
 	RTL_W16 (IntrMask, 0x0000);
 
 	/* Stop a shared interrupt from scavenging while we are. */
-	spin_lock_irq(&tp->lock);
+	local_irq_disable();
+	netif_tx_lock(dev);
 	rtl8139_tx_clear (tp);
-	spin_unlock_irq(&tp->lock);
+	netif_tx_unlock(dev);
+	local_irq_enable();
 
 	/* ...and finally, reset everything */
 	if (netif_running(dev)) {
@@ -1721,7 +1723,8 @@ static int rtl8139_start_xmit (struct sk
 		return 0;
 	}
 
-	spin_lock_irqsave(&tp->lock, flags);
+	local_irq_save(flags);
+	netif_tx_lock(dev);
 	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
 
@@ -1732,7 +1735,8 @@ static int rtl8139_start_xmit (struct sk
 
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx)
 		netif_stop_queue (dev);
-	spin_unlock_irqrestore(&tp->lock, flags);
+	netif_tx_unlock(dev);
+	local_irq_restore(flags);
 
 	if (netif_msg_tx_queued(tp))
 		printk (KERN_DEBUG "%s: Queued Tx packet size %u to slot %d.\n",
@@ -1747,10 +1751,15 @@ static void rtl8139_tx_interrupt (struct
 				  void __iomem *ioaddr)
 {
 	unsigned long dirty_tx, tx_left;
+	unsigned long old_dirty_tx = 0;
+	int error;
 
 	assert (dev != NULL);
 	assert (ioaddr != NULL);
 
+	netif_tx_lock(dev);
+retry:
+	error = 0;
 	dirty_tx = tp->dirty_tx;
 	tx_left = tp->cur_tx - dirty_tx;
 	while (tx_left > 0) {
@@ -1766,8 +1775,7 @@ static void rtl8139_tx_interrupt (struct
 		if (txstatus & (TxOutOfWindow | TxAborted)) {
 			/* There was an major error, log it. */
 			if (netif_msg_tx_err(tp))
-				printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
-					dev->name, txstatus);
+				error = 1;
 			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
 				dev->stats.tx_aborted_errors++;
@@ -1793,12 +1801,19 @@ static void rtl8139_tx_interrupt (struct
 
 		dirty_tx++;
 		tx_left--;
+		if (error) {
+			netif_tx_unlock(dev);
+			printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
+				dev->name, txstatus);
+			netif_tx_lock(dev);
+			goto retry;
+		}
 	}
 
 #ifndef RTL8139_NDEBUG
 	if (tp->cur_tx - dirty_tx > NUM_TX_DESC) {
-		printk (KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
-		        dev->name, dirty_tx, tp->cur_tx);
+		error = 1;
+		old_dirty_tx = dirty_tx;
 		dirty_tx += NUM_TX_DESC;
 	}
 #endif /* RTL8139_NDEBUG */
@@ -1809,6 +1824,10 @@ static void rtl8139_tx_interrupt (struct
 		mb();
 		netif_wake_queue (dev);
 	}
+	netif_tx_unlock(dev);
+	if (error)
+		printk (KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
+		        dev->name, old_dirty_tx, tp->cur_tx);
 }
 
 
