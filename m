From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.7-rc2 + bk-netdev 4/4] r8169: tx lock removal
Date: Thu, 3 Jun 2004 01:36:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040603013636.C22272@electric-eye.fr.zoreil.com>
References: <200406010922.i519MIr27814@mail.osdl.org> <40BE2FAB.1040008@pobox.com> <20040603013128.D18059@electric-eye.fr.zoreil.com> <20040603013319.A22272@electric-eye.fr.zoreil.com> <20040603013511.B22272@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, luto@myrealbox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040603013511.B22272@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Thu, Jun 03, 2004 at 01:35:11AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

spinlock removal crusade.

The patch rephrases the spinlock_irq() in rtl8169_start_xmit() and its
companion in the Tx irq handling patch in terms of ordered operations.


diff -puN drivers/net/r8169.c~r8169-tx-lock-removal drivers/net/r8169.c
--- linux-2.6.7-rc2/drivers/net/r8169.c~r8169-tx-lock-removal	2004-06-03 00:15:37.000000000 +0200
+++ linux-2.6.7-rc2-fr/drivers/net/r8169.c	2004-06-03 00:15:37.000000000 +0200
@@ -1538,8 +1538,6 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 		len = ETH_ZLEN;
 	}
 	
-	spin_lock_irq(&tp->lock);
-
 	if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
 		dma_addr_t mapping;
 		u32 status;
@@ -1560,16 +1558,20 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 		dev->trans_start = jiffies;
 
 		tp->cur_tx++;
+		smp_wmb();
 	} else
 		goto err_drop;
 
-
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx) {
+		u32 dirty = tp->dirty_tx;
+	
 		netif_stop_queue(dev);
+		smp_rmb();
+		if (dirty != tp->dirty_tx)
+			netif_wake_queue(dev);
 	}
-out:
-	spin_unlock_irq(&tp->lock);
 
+out:
 	return 0;
 
 err_drop:
@@ -1590,6 +1592,7 @@ rtl8169_tx_interrupt(struct net_device *
 	assert(ioaddr != NULL);
 
 	dirty_tx = tp->dirty_tx;
+	smp_rmb();
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
@@ -1616,6 +1619,7 @@ rtl8169_tx_interrupt(struct net_device *
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
+		smp_wmb();
 		if (netif_queue_stopped(dev))
 			netif_wake_queue(dev);
 	}
@@ -1777,11 +1781,8 @@ rtl8169_interrupt(int irq, void *dev_ins
 			rtl8169_rx_interrupt(dev, tp, ioaddr);
 		}
 		// Tx interrupt
-		if (status & (TxOK | TxErr)) {
-			spin_lock(&tp->lock);
+		if (status & (TxOK | TxErr))
 			rtl8169_tx_interrupt(dev, tp, ioaddr);
-			spin_unlock(&tp->lock);
-		}
 #endif
 
 		boguscnt--;

_
