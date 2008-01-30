From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Optimize cxgb3 xmit path (a bit)
Date: Wed, 30 Jan 2008 12:30:16 +0530
Message-ID: <20080130070016.29078.94125.sendpatchset@N20wks267652wss.in.ibm.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Krishna Kumar <krkumar2@in.ibm.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:51215 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634AbYA3HBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 02:01:50 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0U71jvo009781
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 02:01:45 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U71jwW244086
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 02:01:45 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U71jlg028492
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 02:01:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes:
	1. Add common code for stopping queue.
	2. No need to call netif_stop_queue followed by netif_wake_queue (and
	   infact a netif_start_queue could have been used instead), instead
	   call stop_queue if required, and remove code under USE_GTS macro.
	3. There is no need to check for netif_queue_stopped, as the network
	   core guarantees that for us (I am sure every driver could remove
	   that check, eg e1000 - I have tested that path a few billion times
	   with about a few hundred thousand qstops but the condition never
	   hit even once).

Thanks,

- KK

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 sge.c |   35 +++++++++++++++--------------------
 1 files changed, 15 insertions(+), 20 deletions(-)

diff -ruNp a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
--- a/drivers/net/cxgb3/sge.c	2008-01-30 11:42:39.000000000 +0530
+++ b/drivers/net/cxgb3/sge.c	2008-01-30 12:15:28.000000000 +0530
@@ -1059,6 +1059,14 @@ static void write_tx_pkt_wr(struct adapt
 			 htonl(V_WR_TID(q->token)));
 }
 
+static inline void t3_stop_queue(struct net_device *dev, struct sge_qset *qs,
+				 struct sge_txq *q)
+{
+	netif_stop_queue(dev);
+	set_bit(TXQ_ETH, &qs->txq_stopped);
+	q->stops++;
+}
+
 /**
  *	eth_xmit - add a packet to the Ethernet Tx queue
  *	@skb: the packet
@@ -1090,31 +1098,18 @@ int t3_eth_xmit(struct sk_buff *skb, str
 	ndesc = calc_tx_descs(skb);
 
 	if (unlikely(credits < ndesc)) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
-			set_bit(TXQ_ETH, &qs->txq_stopped);
-			q->stops++;
-			dev_err(&adap->pdev->dev,
-				"%s: Tx ring %u full while queue awake!\n",
-				dev->name, q->cntxt_id & 7);
-		}
+		t3_stop_queue(dev, qs, q);
+		dev_err(&adap->pdev->dev,
+			"%s: Tx ring %u full while queue awake!\n",
+			dev->name, q->cntxt_id & 7);
 		spin_unlock(&q->lock);
 		return NETDEV_TX_BUSY;
 	}
 
 	q->in_use += ndesc;
-	if (unlikely(credits - ndesc < q->stop_thres)) {
-		q->stops++;
-		netif_stop_queue(dev);
-		set_bit(TXQ_ETH, &qs->txq_stopped);
-#if !USE_GTS
-		if (should_restart_tx(q) &&
-		    test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
-			q->restarts++;
-			netif_wake_queue(dev);
-		}
-#endif
-	}
+	if (unlikely(credits - ndesc < q->stop_thres))
+		if (USE_GTS || !should_restart_tx(q))
+			t3_stop_queue(dev, qs, q);
 
 	gen = q->gen;
 	q->unacked += ndesc;
