From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] check the return value of ndo_select_queue()
Date: Tue, 10 Nov 2009 09:42:01 +0800
Message-ID: <4AF8C4E9.3030907@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaosuo <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:35581 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbZKJBmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 20:42:03 -0500
Received: by ywh40 with SMTP id 40so3092467ywh.33
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 17:42:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

check the return value of ndo_select_queue()

Check the return value of ndo_select_queue(). If the value isn't smaller
than the real_num_tx_queues, print a warning message, and reset it to zero.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/core/dev.c | 24 ++++++++++++++++++------
1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..be081a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1791,13 +1791,25 @@ EXPORT_SYMBOL(skb_tx_hash);
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
-	u16 queue_index = 0;
-
-	if (ops->ndo_select_queue)
-		queue_index = ops->ndo_select_queue(dev, skb);
-	else if (dev->real_num_tx_queues > 1)
+	u16 queue_index;
+	u16 (*ndo_select_queue)(struct net_device*, struct sk_buff*);
+	unsigned int real_num_tx_queues = dev->real_num_tx_queues;
+
+	if (real_num_tx_queues == 1) {
+		queue_index = 0;
+	} else if ((ndo_select_queue = dev->netdev_ops->ndo_select_queue)) {
+		queue_index = ndo_select_queue(dev, skb);
+		if (unlikely(queue_index >= real_num_tx_queues)) {
+			if (net_ratelimit())
+				WARN(1, "%s selects TX queue %d, "
+				     "but real number of TX queues is %d\n",
+				     dev->name, queue_index,
+				     real_num_tx_queues);
+			queue_index = 0;
+		}
+	} else {
 		queue_index = skb_tx_hash(dev, skb);
+	}
 
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);


