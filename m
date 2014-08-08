From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v2 3/3] xen-netback: remove loop waiting function
Date: Fri, 8 Aug 2014 17:37:13 +0100
Message-ID: <1407515833-2550-4-git-send-email-wei.liu2@citrix.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17931 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756163AbaHHQhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 12:37:14 -0400
In-Reply-To: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original implementation relies on a loop to check if all inflight
packets are freed. Now we have proper reference counting, there's no
need to use loop anymore.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/interface.c |   29 -----------------------------
 1 file changed, 29 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 6488801..3bb1104 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -659,25 +659,6 @@ void xenvif_carrier_off(struct xenvif *vif)
 	rtnl_unlock();
 }
 
-static void xenvif_wait_unmap_timeout(struct xenvif_queue *queue,
-				      unsigned int worst_case_skb_lifetime)
-{
-	int i, unmap_timeout = 0;
-
-	for (i = 0; i < MAX_PENDING_REQS; ++i) {
-		if (queue->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
-			unmap_timeout++;
-			schedule_timeout(msecs_to_jiffies(1000));
-			if (unmap_timeout > worst_case_skb_lifetime &&
-			    net_ratelimit())
-				netdev_err(queue->vif->dev,
-					   "Page still granted! Index: %x\n",
-					   i);
-			i = -1;
-		}
-	}
-}
-
 void xenvif_disconnect(struct xenvif *vif)
 {
 	struct xenvif_queue *queue = NULL;
@@ -736,21 +717,11 @@ void xenvif_free(struct xenvif *vif)
 	struct xenvif_queue *queue = NULL;
 	unsigned int num_queues = vif->num_queues;
 	unsigned int queue_index;
-	/* Here we want to avoid timeout messages if an skb can be legitimately
-	 * stuck somewhere else. Realistically this could be an another vif's
-	 * internal or QDisc queue. That another vif also has this
-	 * rx_drain_timeout_msecs timeout, so give it time to drain out.
-	 * Although if that other guest wakes up just before its timeout happens
-	 * and takes only one skb from QDisc, it can hold onto other skbs for a
-	 * longer period.
-	 */
-	unsigned int worst_case_skb_lifetime = (rx_drain_timeout_msecs/1000);
 
 	unregister_netdev(vif->dev);
 
 	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
 		queue = &vif->queues[queue_index];
-		xenvif_wait_unmap_timeout(queue, worst_case_skb_lifetime);
 		xenvif_deinit_queue(queue);
 	}
 
-- 
1.7.10.4
