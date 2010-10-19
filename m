From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/3 v2] net: cleanups in RX queue allocation
Date: Mon, 18 Oct 2010 21:00:16 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010182056010.6676@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:23804 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424Ab0JSEA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 00:00:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up in RX queue allocation.  In netif_set_real_num_rx_queues
return error on attempt to set zero queues, or requested number is
greater than number of allocated queues.  In netif_alloc_rx_queues,
do BUG_ON if queue_count is zero.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |   36 +++++++++++++++++-------------------
 1 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f44d29a..d33adec 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1583,12 +1583,12 @@ int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
 {
 	int rc;
 
+	if (rxq < 1 || rxq > dev->num_rx_queues)
+		return -EINVAL;
+
 	if (dev->reg_state == NETREG_REGISTERED) {
 		ASSERT_RTNL();
 
-		if (rxq > dev->num_rx_queues)
-			return -EINVAL;
-
 		rc = net_rx_queue_update_kobjects(dev, dev->real_num_rx_queues,
 						  rxq);
 		if (rc)
@@ -5013,25 +5013,23 @@ static int netif_alloc_rx_queues(struct net_device *dev)
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

