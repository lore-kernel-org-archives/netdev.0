From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/3] net: cleanups in RX queue allocation
Date: Mon, 18 Oct 2010 11:02:07 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010181056590.16238@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:42786 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757608Ab0JRSCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 14:02:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up in RX queue allocation.  In netif_set_real_num_rx_queues
return error on attempt to set zero queues, and set
dev->num_rx_queues if device not registered (similar to TX
allocation).  In netif_alloc_rx_queues, do BUG_ON if queue
count is zero.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |   36 +++++++++++++++++++-----------------
 1 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 76db105..77b860d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1583,6 +1583,9 @@ int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
 {
 	int rc;
 
+	if (rxq < 1)
+		return -EINVAL;
+
 	if (dev->reg_state == NETREG_REGISTERED) {
 		ASSERT_RTNL();
 
@@ -1593,7 +1596,8 @@ int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
 						  rxq);
 		if (rc)
 			return rc;
-	}
+	} else
+		dev->num_rx_queues = rxq;
 
 	dev->real_num_rx_queues = rxq;
 	return 0;
@@ -5013,25 +5017,23 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 {
 #ifdef CONFIG_RPS
 	unsigned int i, count = dev->num_rx_queues;
+	struct netdev_rx_queue *rx;
 
-	if (count) {
-		struct netdev_rx_queue *rx;
-
-		rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
-		if (!rx) {
-			pr_err("netdev: Unable to allocate %u rx queues.\n",
-			       count);
-			return -ENOMEM;
-		}
-		dev->_rx = rx;
+	BUG_ON(count < 1);
 
-		/*
-		 * Set a pointer to first element in the array which holds the
-		 * reference count.
-		 */
-		for (i = 0; i < count; i++)
-			rx[i].first = rx;
+	rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
+	if (!rx) {
+		pr_err("netdev: Unable to allocate %u rx queues.\n", count);
+		return -ENOMEM;
 	}
+	dev->_rx = rx;
+
+	/*
+	 * Set a pointer to first element in the array which holds the
+	 * reference count.
+	 */
+	for (i = 0; i < count; i++)
+		rx[i].first = rx;
 #endif
 	return 0;
 }
-- 
1.7.1

