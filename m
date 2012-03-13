From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] net: Add memory barriers to prevent possible race in byte queue limits
Date: Mon, 12 Mar 2012 21:03:43 -0700
Message-ID: <1331611432-30109-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab2CMED7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:03:59 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds a memory barrier to the byte queue limit code to address a
possible race as has been seen in the past with the
netif_stop_queue/netif_wake_queue logic.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/netdevice.h |   49 ++++++++++++++++++++++++++++++--------------
 1 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4bf314f..4535a4e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1899,12 +1899,22 @@ static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 {
 #ifdef CONFIG_BQL
 	dql_queued(&dev_queue->dql, bytes);
-	if (unlikely(dql_avail(&dev_queue->dql) < 0)) {
-		set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
-		if (unlikely(dql_avail(&dev_queue->dql) >= 0))
-			clear_bit(__QUEUE_STATE_STACK_XOFF,
-			    &dev_queue->state);
-	}
+
+	if (likely(dql_avail(&dev_queue->dql) >= 0))
+		return;
+
+	set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
+
+	/*
+	 * The XOFF flag must be set before checking the dql_avail below,
+	 * because in netdev_tx_completed_queue we update the dql_completed
+	 * before checking the XOFF flag.
+	 */
+	smp_mb();
+
+	/* check again in case another CPU has just made room avail */
+	if (unlikely(dql_avail(&dev_queue->dql) >= 0))
+		clear_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
 #endif
 }
 
@@ -1917,16 +1927,23 @@ static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
 					     unsigned pkts, unsigned bytes)
 {
 #ifdef CONFIG_BQL
-	if (likely(bytes)) {
-		dql_completed(&dev_queue->dql, bytes);
-		if (unlikely(test_bit(__QUEUE_STATE_STACK_XOFF,
-		    &dev_queue->state) &&
-		    dql_avail(&dev_queue->dql) >= 0)) {
-			if (test_and_clear_bit(__QUEUE_STATE_STACK_XOFF,
-			     &dev_queue->state))
-				netif_schedule_queue(dev_queue);
-		}
-	}
+	if (unlikely(!bytes))
+		return;
+
+	dql_completed(&dev_queue->dql, bytes);
+
+	/*
+	 * Without the memory barrier there is a small possiblity that
+	 * netdev_tx_sent_queue will miss the update and cause the queue to
+	 * be stopped forever
+	 */
+	smp_mb();
+
+	if (dql_avail(&dev_queue->dql) < 0)
+		return;
+
+	if (test_and_clear_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state))
+		netif_schedule_queue(dev_queue);
 #endif
 }
 
-- 
1.7.7.6
