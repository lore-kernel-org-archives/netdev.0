From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V2 8/8] netback: remove unwanted notification generation during NAPI processing.
Date: Tue, 17 Jan 2012 13:47:04 +0000
Message-ID: <1326808024-3744-9-git-send-email-wei.liu2@citrix.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: konrad.wilk@oracle.com, david.vrabel@citrix.com,
	paul.durrant@citrix.com, Wei Liu <wei.liu2@citrix.com>
To: ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35366 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754211Ab2AQNsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 08:48:17 -0500
In-Reply-To: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In original implementation, tx_build_gops tends to update req_event
pointer every time it sees tx error or finish one batch. Remove those
code to only update req_event pointer when we really want to shut down
NAPI.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c |    5 +++--
 drivers/net/xen-netback/netback.c   |    4 +---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 05caccc..7cf0947 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -58,8 +58,8 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 	if (xenvif_rx_schedulable(vif))
 		netif_wake_queue(vif->dev);
 
-	if (likely(napi_schedule_prep(&vif->napi)))
-		__napi_schedule(&vif->napi);
+	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
+		napi_schedule(&vif->napi);
 
 	return IRQ_HANDLED;
 }
@@ -74,6 +74,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		int more_to_do = 0;
 		unsigned long flag;
+
 		local_irq_save(flag);
 
 		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index fa864f4..34f34f5 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -663,7 +663,6 @@ static void xenvif_tx_err(struct xenvif *vif,
 		txp = RING_GET_REQUEST(&vif->tx, cons++);
 	} while (1);
 	vif->tx.req_cons = cons;
-	xenvif_check_rx_xenvif(vif);
 }
 
 static int xenvif_count_requests(struct xenvif *vif,
@@ -1048,7 +1047,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif,
 		int pool_idx;
 		struct pending_tx_info *pending_tx_info;
 
-		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, work_to_do);
+		work_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
 		if (!work_to_do) {
 			break;
 		}
@@ -1188,7 +1187,6 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif,
 		gop = request_gop;
 
 		vif->tx.req_cons = idx;
-		xenvif_check_rx_xenvif(vif);
 
 		if ((gop - tco) >= MAX_PENDING_REQS)
 			break;
-- 
1.7.2.5
