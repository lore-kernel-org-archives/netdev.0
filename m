From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v4 1/3] xen-netback: move NAPI add/remove calls
Date: Tue, 12 Aug 2014 11:48:06 +0100
Message-ID: <1407840488-20026-2-git-send-email-wei.liu2@citrix.com>
References: <1407840488-20026-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <zoltan.kiss@citrix.com>,
	<david.vrabel@citrix.com>, Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:65100 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbaHLKsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 06:48:11 -0400
In-Reply-To: <1407840488-20026-1-git-send-email-wei.liu2@citrix.com>
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
 drivers/net/xen-netback/interface.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index bfd10cb..5f3d6c0 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -524,9 +524,6 @@ int xenvif_init_queue(struct xenvif_queue *queue)
 
 	init_timer(&queue->rx_stalled);
 
-	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
-			XENVIF_NAPI_WEIGHT);
-
 	return 0;
 }
 
@@ -614,6 +611,9 @@ int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 	wake_up_process(queue->task);
 	wake_up_process(queue->dealloc_task);
 
+	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
+			XENVIF_NAPI_WEIGHT);
+
 	return 0;
 
 err_rx_unbind:
@@ -672,6 +672,8 @@ void xenvif_disconnect(struct xenvif *vif)
 	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
 		queue = &vif->queues[queue_index];
 
+		netif_napi_del(&queue->napi);
+
 		if (queue->task) {
 			del_timer_sync(&queue->rx_stalled);
 			kthread_stop(queue->task);
@@ -704,7 +706,6 @@ void xenvif_disconnect(struct xenvif *vif)
 void xenvif_deinit_queue(struct xenvif_queue *queue)
 {
 	free_xenballooned_pages(MAX_PENDING_REQS, queue->mmap_pages);
-	netif_napi_del(&queue->napi);
 }
 
 void xenvif_free(struct xenvif *vif)
-- 
1.7.10.4
