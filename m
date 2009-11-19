From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] gianfar: multi queue stuff not complete
Date: Thu, 19 Nov 2009 09:28:15 +0100
Message-ID: <4B05019F.4090208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59560 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbZKSI2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 03:28:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed gianfar got multiqueue support recently, but it still
updates dev->stats.{tx_bytes|tx_packets|tx_dropped} without proper locking
(several cpus could update stats at same time while xmitting on different tx queues)

It should use txq->{tx_bytes|tx_packets|tx_dropped} to avoid wrong tx stats


I cooked following preliminar patch but its only for discussion, because I
dont know yet how to transform dev->stats.tx_dropped++; in gfar_error(),
and also because I cannot compile this driver on my dev machine.

(if a driver uses txq->tx... counters, it must not use any dev->stats.{tx_bytes|tx_packets|tx_dropped}
that are overwritten by dev_txq_stats_fold(). Or we could change dev_txq_stats_fold() logic
to get a mask of what fields a drivers updates in txq-> or dev->stats


diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 16def13..8fe38aa 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1937,7 +1937,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Update transmit stats */
-	dev->stats.tx_bytes += skb->len;
+	txq->tx_bytes += skb->len;
+	txq->tx_packets++;
 
 	txbdp = txbdp_start = tx_queue->cur_tx;
 
@@ -2295,8 +2296,6 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	tx_queue->skb_dirtytx = skb_dirtytx;
 	tx_queue->dirty_tx = bdp;
 
-	dev->stats.tx_packets += howmany;
-
 	return howmany;
 }
 
