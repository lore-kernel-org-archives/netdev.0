From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/4 v2] net: Use sk_tx_queue_mapping for connected sockets
Date: Fri, 16 Oct 2009 12:51:32 +0530
Message-ID: <20091016072132.24384.38301.sendpatchset@localhost.localdomain>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:41307 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391AbZJPHWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 03:22:24 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9G7LaqP021189
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 12:51:36 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9G7La1G2351270
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 12:51:36 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9G7LaXf013003
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 12:51:36 +0530
In-Reply-To: <20091016072107.24384.17358.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

For connected sockets, the first run of dev_pick_tx saves the
calculated txq in sk_tx_queue_mapping. This is not saved if
either skb rx was recorded, or if the device has a queue select
handler. Next iterations of dev_pick_tx uses the cached value of
sk_tx_queue_mapping.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/core/dev.c |   24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2009-10-16 11:58:37.000000000 +0530
+++ new/net/core/dev.c	2009-10-16 11:59:11.000000000 +0530
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
+		queue_index = sk_get_tx_queue(sk);
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
