From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 tx problem (1s pause with ping)
Date: Wed, 20 Jun 2007 23:15:30 +0200
Message-ID: <20070620211530.GA10042@electric-eye.fr.zoreil.com>
References: <20070613004154.GA4187@kvack.org> <20070613211859.GA22521@electric-eye.fr.zoreil.com> <46715FBA.3070302@iinet.net.au> <20070614220050.GB23266@electric-eye.fr.zoreil.com> <20070619230641.GD14681@electric-eye.fr.zoreil.com> <4678EC07.8050700@iinet.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Benjamin LaHaise <bcrl@kvack.org>
To: David Gundersen <gundy@iinet.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52437 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbXFTVRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 17:17:25 -0400
Content-Disposition: inline
In-Reply-To: <4678EC07.8050700@iinet.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Gundersen <gundy@iinet.net.au> :
[...]
> - Why are you checking dirty_tx against cur_rx (shouldn't it be cur_tx?)?

Usual "try something, send something else" bug.

> - Is there a possibility that the driver could be triggering the card to 
> send invalid packets with that code?
[snip]

I do not know but I doubt that it matters.

That being said, the patch below should make things better (though still
not perfect):


diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 8f3e0da..35054e8 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2514,7 +2514,7 @@ static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned int frags, entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned int frags, cur_tx, entry = tp->cur_tx % NUM_TX_DESC;
 	struct TxDesc *txd = tp->TxDescArray + entry;
 	void __iomem *ioaddr = tp->mmio_addr;
 	dma_addr_t mapping;
@@ -2567,13 +2567,17 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
+	cur_tx = tp->cur_tx;
+
 	tp->cur_tx += frags + 1;
 
-	smp_wmb();
+	mmiowb();
 
-	RTL_W8(TxPoll, NPQ);	/* set polling bit */
+	smp_mb();
 
-	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+	if (cur_tx == tp->dirty_tx)
+		RTL_W8(TxPoll, NPQ);
+	else if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
 		smp_rmb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
@@ -2677,10 +2681,18 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-		smp_wmb();
-		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
-			netif_wake_queue(dev);
+		smp_mb();
+		if (unlikely(netif_queue_stopped(dev))) {
+			netif_tx_lock(dev);
+		    	if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
+				netif_wake_queue(dev);
+			if (dirty_tx != tp->cur_tx)
+				RTL_W8(TxPoll, NPQ);
+			netif_tx_unlock(dev);
+		} else if (dirty_tx != tp->cur_tx) {
+			netif_tx_lock(dev);
+			RTL_W8(TxPoll, NPQ);
+			netif_tx_unlock(dev);
 		}
 	}
 }
