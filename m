From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] check the return value of ndo_select_queue()
Date: Sat, 14 Nov 2009 08:50:02 +0800
Message-ID: <412e6f7f0911131650j6d13f95bt20aa607f9f44c3af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:44090 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932576AbZKNAt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 19:49:56 -0500
Received: by pwi3 with SMTP id 3so2298987pwi.21
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 16:50:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

check the return value of ndo_select_queue()

Check the return value of ndo_select_queue(). If the value isn't smaller
than the real_num_tx_queues, print a warning message, and reset it to zero.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/dev.c |   33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index bf629ac..74a3824 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1849,22 +1849,37 @@ static struct netdev_queue *dev_pick_tx(struct
net_device *dev,
 {
 	u16 queue_index;
 	struct sock *sk = skb->sk;
+	unsigned int real_num_tx_queues = dev->real_num_tx_queues;

 	if (sk_tx_queue_recorded(sk)) {
 		queue_index = sk_tx_queue_get(sk);
+		if (unlikely(queue_index >= real_num_tx_queues)) {
+			do {
+				queue_index -= real_num_tx_queues;
+			} while (queue_index >= real_num_tx_queues);
+			sk_tx_queue_set(sk, queue_index);
+		}
 	} else {
-		const struct net_device_ops *ops = dev->netdev_ops;
+		u16 (*select_queue)(struct net_device *, struct sk_buff *);

-		if (ops->ndo_select_queue) {
-			queue_index = ops->ndo_select_queue(dev, skb);
-		} else {
+		if (real_num_tx_queues == 1) {
 			queue_index = 0;
-			if (dev->real_num_tx_queues > 1)
-				queue_index = skb_tx_hash(dev, skb);
-
-			if (sk && sk->sk_dst_cache)
-				sk_tx_queue_set(sk, queue_index);
+		} else if((select_queue = dev->netdev_ops->ndo_select_queue)) {
+			queue_index = select_queue(dev, skb);
+			if (unlikely(queue_index >= real_num_tx_queues)) {
+				if (net_ratelimit())
+					WARN(1, "%s selects TX queue %d, but "
+					     "real number of TX queues is %d\n",
+					     dev->name, queue_index,
+					     real_num_tx_queues);
+				queue_index = 0;
+			}
+		} else {
+			queue_index = skb_tx_hash(dev, skb);
 		}
+
+		if (sk && sk->sk_dst_cache)
+			sk_tx_queue_set(sk, queue_index);
 	}

 	skb_set_queue_mapping(skb, queue_index);
