From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #3 8/8] via-rhine: close SMP transmit races.
Date: Fri,  1 May 2015 22:14:45 +0200
Message-ID: <f8493e71d92ba6dec3f7816d8473bdc8f80874ac.1430509434.git.romieu@fr.zoreil.com>
References: <cover.1430509434.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>, Nix <nix@esperi.org.uk>,
	Roger.Luethi.rl@hellgate.ch,
	Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51001 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbbEAUPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 16:15:12 -0400
In-Reply-To: <cover.1430509434.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1430509434.git.romieu@fr.zoreil.com>
References: <cover.1430509434.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

7ab87ff4c770eed71e3777936299292739fcd0fe ("via-rhine: move work from
irq handler to softirq and beyond") forgot to explicitely control the
lifespan of the tx_dirty and tx_cur pointers.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 51 +++++++++++++++++++++++++++++++-----
 1 file changed, 45 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 86ca8b2..725106f 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1779,6 +1779,11 @@ static void rhine_tx_timeout(struct net_device *dev)
 	schedule_work(&rp->reset_task);
 }
 
+static inline bool rhine_tx_queue_full(struct rhine_private *rp)
+{
+	return (rp->cur_tx - rp->dirty_tx) >= TX_QUEUE_LEN;
+}
+
 static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 				  struct net_device *dev)
 {
@@ -1854,6 +1859,12 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	wmb();
 
 	rp->cur_tx++;
+	/*
+	 * Nobody wants cur_tx write to rot for ages after the NIC will have
+	 * seen the transmit request, especially as the transmit completion
+	 * handler could miss it.
+	 */
+	smp_wmb();
 
 	/* Non-x86 Todo: explicitly flush cache lines here. */
 
@@ -1866,8 +1877,14 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	       ioaddr + ChipCmd1);
 	IOSYNC;
 
-	if (rp->cur_tx == rp->dirty_tx + TX_QUEUE_LEN)
+	/* dirty_tx may be pessimistically out-of-sync. See rhine_tx. */
+	if (rhine_tx_queue_full(rp)) {
 		netif_stop_queue(dev);
+		smp_rmb();
+		/* Rejuvenate. */
+		if (!rhine_tx_queue_full(rp))
+			netif_wake_queue(dev);
+	}
 
 	netif_dbg(rp, tx_queued, dev, "Transmit frame #%d queued in slot %d\n",
 		  rp->cur_tx - 1, entry);
@@ -1915,13 +1932,24 @@ static void rhine_tx(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	struct device *hwdev = dev->dev.parent;
-	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
 	unsigned int pkts_compl = 0, bytes_compl = 0;
+	unsigned int dirty_tx = rp->dirty_tx;
+	unsigned int cur_tx;
 	struct sk_buff *skb;
 
+	/*
+	 * The race with rhine_start_tx does not matter here as long as the
+	 * driver enforces a value of cur_tx that was relevant when the
+	 * packet was scheduled to the network chipset.
+	 * Executive summary: smp_rmb() balances smp_wmb() in rhine_start_tx.
+	 */
+	smp_rmb();
+	cur_tx = rp->cur_tx;
 	/* find and cleanup dirty tx descriptors */
-	while (rp->dirty_tx != rp->cur_tx) {
-		txstatus = le32_to_cpu(rp->tx_ring[entry].tx_status);
+	while (dirty_tx != cur_tx) {
+		unsigned int entry = dirty_tx % TX_RING_SIZE;
+		u32 txstatus = le32_to_cpu(rp->tx_ring[entry].tx_status);
+
 		netif_dbg(rp, tx_done, dev, "Tx scavenge %d status %08x\n",
 			  entry, txstatus);
 		if (txstatus & DescOwn)
@@ -1970,12 +1998,23 @@ static void rhine_tx(struct net_device *dev)
 		pkts_compl++;
 		dev_consume_skb_any(skb);
 		rp->tx_skbuff[entry] = NULL;
-		entry = (++rp->dirty_tx) % TX_RING_SIZE;
+		dirty_tx++;
 	}
 
+	rp->dirty_tx = dirty_tx;
+	/* Pity we can't rely on the nearby BQL completion implicit barrier. */
+	smp_wmb();
+
 	netdev_completed_queue(dev, pkts_compl, bytes_compl);
-	if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
+
+	/* cur_tx may be optimistically out-of-sync. See rhine_start_tx. */
+	if (!rhine_tx_queue_full(rp) && netif_queue_stopped(dev)) {
 		netif_wake_queue(dev);
+		smp_rmb();
+		/* Rejuvenate. */
+		if (rhine_tx_queue_full(rp))
+			netif_stop_queue(dev);
+	}
 }
 
 /**
-- 
Ueimor
