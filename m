From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 5/7] 2.6.5-bk-netdev - r8169 queue
Date: Mon, 5 Apr 2004 23:59:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405235929.E23436@electric-eye.fr.zoreil.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com> <20040405235648.A23436@electric-eye.fr.zoreil.com> <20040405235726.B23436@electric-eye.fr.zoreil.com> <20040405235802.C23436@electric-eye.fr.zoreil.com> <20040405235844.D23436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040405235844.D23436@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Apr 05, 2004 at 11:58:44PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


If a few packets have been scheduled for Tx, it is possible to keep looping
in the Tx irq handler as soon as the irq for the first packet has been
received until the descriptor of the last packet has been sent (with 
interrupts disabled btw).


 drivers/net/r8169.c |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff -puN drivers/net/r8169.c~r8169-kill-potential-busy-loop drivers/net/r8169.c
--- linux-2.6.5/drivers/net/r8169.c~r8169-kill-potential-busy-loop	2004-04-05 23:06:15.000000000 +0200
+++ linux-2.6.5-fr/drivers/net/r8169.c	2004-04-05 23:06:15.000000000 +0200
@@ -1366,22 +1366,24 @@ rtl8169_tx_interrupt(struct net_device *
 
 	while (tx_left > 0) {
 		int entry = dirty_tx % NUM_TX_DESC;
+		struct sk_buff *skb = tp->Tx_skbuff[entry];
+		u32 status;
 
 		rmb();
-		if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
-			struct sk_buff *skb = tp->Tx_skbuff[entry];
+		status = le32_to_cpu(tp->TxDescArray[entry].status);
+		if (status & OWNbit)
+			break;
 
-			/* FIXME: is it really accurate for TxErr ? */
-			tp->stats.tx_bytes += skb->len >= ETH_ZLEN ?
-					      skb->len : ETH_ZLEN;
-			tp->stats.tx_packets++;
-			rtl8169_unmap_tx_skb(tp->pci_dev, tp->Tx_skbuff + entry,
-					     tp->TxDescArray + entry);
-			dev_kfree_skb_irq(skb);
-			tp->Tx_skbuff[entry] = NULL;
-			dirty_tx++;
-			tx_left--;
-		}
+		/* FIXME: is it really accurate for TxErr ? */
+		tp->stats.tx_bytes += skb->len >= ETH_ZLEN ?
+				      skb->len : ETH_ZLEN;
+		tp->stats.tx_packets++;
+		rtl8169_unmap_tx_skb(tp->pci_dev, tp->Tx_skbuff + entry,
+				     tp->TxDescArray + entry);
+		dev_kfree_skb_irq(skb);
+		tp->Tx_skbuff[entry] = NULL;
+		dirty_tx++;
+		tx_left--;
 	}
 
 	if (tp->dirty_tx != dirty_tx) {

_
