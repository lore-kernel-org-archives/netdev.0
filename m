From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v3 1/3] xen-netback: move NAPI add/remove calls
Date: Mon, 11 Aug 2014 11:11:22 +0100
Message-ID: <1407751884-9005-2-git-send-email-wei.liu2@citrix.com>
References: <1407751884-9005-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:38379 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbaHKKL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 06:11:26 -0400
In-Reply-To: <1407751884-9005-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally netif_napi_add was in xenvif_init_queue and netif_napi_del
was in xenvif_deinit_queue, while kthreads were handled in
xenvif_connect and xenvif_disconnect. Move netif_napi_add and
netif_napi_del to xenvif_connect and xenvif_disconnect so that they
reside together with kthread operations.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/interface.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 48a55cd..fdb4fca 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -528,9 +528,6 @@ int xenvif_init_queue(struct xenvif_queue *queue)
 
 	init_timer(&queue->rx_stalled);
 
-	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
-			XENVIF_NAPI_WEIGHT);
-
 	return 0;
 }
 
@@ -618,6 +615,9 @@ int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 	wake_up_process(queue->task);
 	wake_up_process(queue->dealloc_task);
 
+	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
+			XENVIF_NAPI_WEIGHT);
+
 	return 0;
 
 err_rx_unbind:
@@ -675,6 +675,11 @@ void xenvif_disconnect(struct xenvif *vif)
 
 	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
 		queue = &vif->queues[queue_index];
+		netif_napi_del(&queue->napi);
+	}
+
+	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
+		queue = &vif->queues[queue_index];
 
 		if (queue->task) {
 			del_timer_sync(&queue->rx_stalled);
@@ -708,7 +713,6 @@ void xenvif_disconnect(struct xenvif *vif)
 void xenvif_deinit_queue(struct xenvif_queue *queue)
 {
 	free_xenballooned_pages(MAX_PENDING_REQS, queue->mmap_pages);
-	netif_napi_del(&queue->napi);
 }
 
 void xenvif_free(struct xenvif *vif)
-- 
1.7.10.4
