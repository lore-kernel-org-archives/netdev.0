From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] check the return value of ndo_select_queue()
Date: Mon, 09 Nov 2009 15:17:17 +0800
Message-ID: <4AF7C1FD.8000302@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaosuo <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:34126 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbZKIHRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 02:17:16 -0500
Received: by pwi3 with SMTP id 3so463705pwi.21
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2009 23:17:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

check the return value of ndo_select_queue()

Check the return value of ndo_select_queue(). If the value isn't smaller
than the real_num_tx_queues, print a warning message, and reset it to zero.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/core/dev.c | 11 +++++++++--
1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..edf5ea6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1794,10 +1794,17 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 	const struct net_device_ops *ops = dev->netdev_ops;
 	u16 queue_index = 0;
 
-	if (ops->ndo_select_queue)
+	if (ops->ndo_select_queue) {
 		queue_index = ops->ndo_select_queue(dev, skb);
-	else if (dev->real_num_tx_queues > 1)
+		if (queue_index >= dev->real_num_tx_queues) {
+			printk(KERN_WARNING "%s selects TX queue %d, "
+			       "but real number of TX queues is %d\n",
+			       dev->name, queue_index, dev->real_num_tx_queues);
+			queue_index = 0;
+		}
+	} else if (dev->real_num_tx_queues > 1) {
 		queue_index = skb_tx_hash(dev, skb);
+	}
 
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);


