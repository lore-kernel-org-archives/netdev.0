From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net] xen-netback: move netif_napi_add before binding interrupt
Date: Mon, 25 Aug 2014 16:44:00 +0100
Message-ID: <1408981440-19255-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <talex5@gmail.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:50724 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933032AbaHYPoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 11:44:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interrupt is enabled when bind_interdomain_evtchn_to_irqhandler returns.
If there's interrupt pending interrupt handler is invoked.

NAPI needs to be initialised before binding interrupt otherwise the
interrupt handler will try to scheduling a NAPI instance that is not
initialised yet, resulting in kernel OOPS.

This fixes a regression introduced in ea2c5e13 ("xen-netback: move NAPI
add/remove calls").

Ideally function calls to create kthreads should also be moved before
binding but I intent to fix this regression with minimal changes and
refactor the code with another patch.

Reported-by: Thomas Leonard <talex5@gmail.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/interface.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index e29e15d..f379689 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -576,6 +576,9 @@ int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 	init_waitqueue_head(&queue->dealloc_wq);
 	atomic_set(&queue->inflight_packets, 0);
 
+	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
+			XENVIF_NAPI_WEIGHT);
+
 	if (tx_evtchn == rx_evtchn) {
 		/* feature-split-event-channels == 0 */
 		err = bind_interdomain_evtchn_to_irqhandler(
@@ -629,9 +632,6 @@ int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 	wake_up_process(queue->task);
 	wake_up_process(queue->dealloc_task);
 
-	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
-			XENVIF_NAPI_WEIGHT);
-
 	return 0;
 
 err_rx_unbind:
-- 
1.7.10.4
