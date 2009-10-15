From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH 2/5] net: Use sk_tx_queue_mapping for connected sockets
Date: Thu, 15 Oct 2009 11:27:02 +0530
Message-ID: <20091015055702.30145.41799.sendpatchset@localhost.localdomain>
References: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:44577 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbZJOF6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:58:05 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp07.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9F5vHPi026288
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:57:17 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9F5sdkn1548408
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:54:39 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9F5vGjO003232
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:57:17 +1100
In-Reply-To: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
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
--- org/net/core/dev.c	2009-10-14 17:59:40.000000000 +0530
+++ new/net/core/dev.c	2009-10-14 18:00:04.000000000 +0530
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
