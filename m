From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/4 v3] net: Use sk_tx_queue_mapping for connected sockets
Date: Sun, 18 Oct 2009 18:37:52 +0530
Message-ID: <20091018130752.3960.83781.sendpatchset@localhost.localdomain>
References: <20091018130727.3960.32107.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:51184 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562AbZJRNHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 09:07:51 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9ID7t5g015219
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:37:55 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9ID7sti2555948
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:37:54 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9ID7sM6003237
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 00:07:54 +1100
In-Reply-To: <20091018130727.3960.32107.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

For connected sockets, the first run of dev_pick_tx saves the
calculated txq in sk_tx_queue_mapping. This is not saved if
either the device has a queue select or the socket is not
connected. Next iterations of dev_pick_tx uses the cached value
of sk_tx_queue_mapping.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/core/dev.c |   24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2009-10-16 18:53:40.000000000 +0530
+++ new/net/core/dev.c	2009-10-16 21:30:38.000000000 +0530
@@ -1791,13 +1791,25 @@ EXPORT_SYMBOL(skb_tx_hash);
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
-	u16 queue_index = 0;
+	u16 queue_index;
+	struct sock *sk = skb->sk;
+
+	if (sk_tx_queue_recorded(sk)) {
+		queue_index = sk_tx_queue_get(sk);
+	} else {
+		const struct net_device_ops *ops = dev->netdev_ops;
 
-	if (ops->ndo_select_queue)
-		queue_index = ops->ndo_select_queue(dev, skb);
-	else if (dev->real_num_tx_queues > 1)
-		queue_index = skb_tx_hash(dev, skb);
+		if (ops->ndo_select_queue) {
+			queue_index = ops->ndo_select_queue(dev, skb);
+		} else {
+			queue_index = 0;
+			if (dev->real_num_tx_queues > 1)
+				queue_index = skb_tx_hash(dev, skb);
+
+			if (sk && sk->sk_dst_cache)
+				sk_record_tx_queue(sk, queue_index);
+		}
+	}
 
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
