From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver
 code
Date: Thu, 14 Aug 2008 16:44:32 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808141643200.3164@sbz-30.cs.Helsinki.FI>
References: <20080813095324.GA15055@ben.ifi.uio.no>
 <20080813.033749.165504341.davem@davemloft.net>
 <84144f020808140628m31d6d099t1fecdb1701c0bbdc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, vegardno@ifi.uio.no,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, adobriyan@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53628 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbYHNNoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 09:44:34 -0400
In-Reply-To: <84144f020808140628m31d6d099t1fecdb1701c0bbdc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Aug 2008, Pekka Enberg wrote:
> > See my other reply, this is absolutely the wrong way to go about
> > this.
> >
> > You only have two sane options:
> >
> > 1) Defer the link status printk message into a deferred context,
> >   such as a workqueue, so that you can do it outside of the
> >   lock.
> 
> It's not just the link status. We have assert() and debugging printks
> there under tp->lock as well which can also trigger the deadlock
> condition.
> 
> On Wed, Aug 13, 2008 at 1:37 PM, David Miller <davem@davemloft.net> wrote:
> > 2) Do your locking differently so that the link status handling
> >   locking does not bisect the locking used for packet transmit
> >   in ->hard_start_xmit().
> >
> > #2 is the reason why most other drivers don't have this silly
> > bug, they don't hold TX path locks when handling link status
> > and printing out such messages.
> 
> Yeah, that works for the link status case, but not for things like the
> printks in rtl8139_tx_interrupt()... Hmm.

...so I guess something like the following (totally untested) patch could 
work.

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

To avoid the deadlock, use a separate ->tx_lock for the TX paths and make sure
we never call printk() while holding that lock.

Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Jeff Garzik <jgarzik@pobox.com>
Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/8139too.c |   34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

Index: linux-2.6/drivers/net/8139too.c
===================================================================
--- linux-2.6.orig/drivers/net/8139too.c	2008-08-14 16:29:32.000000000 +0300
+++ linux-2.6/drivers/net/8139too.c	2008-08-14 16:41:10.000000000 +0300
@@ -598,6 +598,7 @@
 
 	spinlock_t		lock;
 	spinlock_t		rx_lock;
+	spinlock_t		tx_lock;
 
 	chip_t			chipset;
 	u32			rx_config;
@@ -1009,6 +1010,7 @@
 		(debug < 0 ? RTL8139_DEF_MSG_ENABLE : ((1 << debug) - 1));
 	spin_lock_init (&tp->lock);
 	spin_lock_init (&tp->rx_lock);
+	spin_lock_init (&tp->tx_lock);
 	INIT_DELAYED_WORK(&tp->thread, rtl8139_thread);
 	tp->mii.dev = dev;
 	tp->mii.mdio_read = mdio_read;
@@ -1675,9 +1677,9 @@
 	RTL_W16 (IntrMask, 0x0000);
 
 	/* Stop a shared interrupt from scavenging while we are. */
-	spin_lock_irq(&tp->lock);
+	spin_lock_irq(&tp->tx_lock);
 	rtl8139_tx_clear (tp);
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irq(&tp->tx_lock);
 
 	/* ...and finally, reset everything */
 	if (netif_running(dev)) {
@@ -1721,7 +1723,7 @@
 		return 0;
 	}
 
-	spin_lock_irqsave(&tp->lock, flags);
+	spin_lock_irqsave(&tp->tx_lock, flags);
 	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
 
@@ -1732,7 +1734,7 @@
 
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx)
 		netif_stop_queue (dev);
-	spin_unlock_irqrestore(&tp->lock, flags);
+	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	if (netif_msg_tx_queued(tp))
 		printk (KERN_DEBUG "%s: Queued Tx packet size %u to slot %d.\n",
@@ -1746,11 +1748,15 @@
 				  struct rtl8139_private *tp,
 				  void __iomem *ioaddr)
 {
-	unsigned long dirty_tx, tx_left;
+	unsigned long dirty_tx, old_dirty_tx, tx_left;
+	int error;
 
 	assert (dev != NULL);
 	assert (ioaddr != NULL);
 
+	spin_lock(&tp->tx_lock);
+retry:
+	error = 0;
 	dirty_tx = tp->dirty_tx;
 	tx_left = tp->cur_tx - dirty_tx;
 	while (tx_left > 0) {
@@ -1766,8 +1772,7 @@
 		if (txstatus & (TxOutOfWindow | TxAborted)) {
 			/* There was an major error, log it. */
 			if (netif_msg_tx_err(tp))
-				printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
-					dev->name, txstatus);
+				error = 1;
 			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
 				dev->stats.tx_aborted_errors++;
@@ -1793,12 +1798,19 @@
 
 		dirty_tx++;
 		tx_left--;
+		if (error) {
+			spin_unlock(&tp->tx_lock);
+			printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
+				dev->name, txstatus);
+			spin_lock(&tp->tx_lock);
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
@@ -1809,6 +1821,10 @@
 		mb();
 		netif_wake_queue (dev);
 	}
+	spin_unlock(&tp->tx_lock);
+	if (error)
+		printk (KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
+		        dev->name, old_dirty_tx, tp->cur_tx);
 }
 
 
