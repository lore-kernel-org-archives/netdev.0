From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch] 2.6.6-rc3 - r8169 rediff
Date: Sat, 15 May 2004 01:52:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040515015241.A12010@electric-eye.fr.zoreil.com>
References: <20040504012400.C4612@electric-eye.fr.zoreil.com> <OF6F220169.C19B30A8-ON87256E8C.004FD242-86256E8C.004FAA37@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon D Mason <jonmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF6F220169.C19B30A8-ON87256E8C.004FD242-86256E8C.004FAA37@us.ibm.com>; from jonmason@us.ibm.com on Thu, May 06, 2004 at 09:36:55AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason <jonmason@us.ibm.com> :
[...]
> All the patches applied cleanly against the 2.6.6-rc3 driver.  My system 
> (amd64) has run for 12 hours without any problems.

Do you have an SMP system where you could try the patch below on top of the
usual stuff ?


 drivers/net/r8169.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff -puN drivers/net/r8169.c~r8169-tx-lock-removal drivers/net/r8169.c
--- linux-2.6.6-rc3/drivers/net/r8169.c~r8169-tx-lock-removal	2004-05-15 01:38:35.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/r8169.c	2004-05-15 01:38:35.000000000 +0200
@@ -1457,8 +1457,6 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 		len = ETH_ZLEN;
 	}
 	
-	spin_lock_irq(&tp->lock);
-
 	if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
 		dma_addr_t mapping;
 
@@ -1479,13 +1477,16 @@ rtl8169_start_xmit(struct sk_buff *skb, 
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
@@ -1532,6 +1533,7 @@ rtl8169_tx_interrupt(struct net_device *
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
+		smp_wmb();
 		if (netif_queue_stopped(dev))
 			netif_wake_queue(dev);
 	}
@@ -1693,11 +1695,8 @@ rtl8169_interrupt(int irq, void *dev_ins
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
