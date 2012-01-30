From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 08/16] netback: remove unwanted notification generation during NAPI processing.
Date: Mon, 30 Jan 2012 14:45:26 +0000
Message-ID: <1327934734-8908-9-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:57846 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365Ab2A3Opo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 09:45:44 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In original implementation, tx_build_gops tends to update req_event
pointer every time it sees tx error or finish one batch. Remove those
code to only update req_event pointer when we really want to shut down
NAPI.

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c |    5 +++--
 drivers/net/xen-netback/netback.c   |    4 +---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index ebed26a..fe37143 100644
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
index 2a2835e..065cd65 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -662,7 +662,6 @@ static void xenvif_tx_err(struct xenvif *vif,
 		txp = RING_GET_REQUEST(&vif->tx, cons++);
 	} while (1);
 	vif->tx.req_cons = cons;
-	xenvif_check_rx_xenvif(vif);
 }
 
 static int xenvif_count_requests(struct xenvif *vif,
@@ -1047,7 +1046,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif,
 		int pool_idx;
 		struct pending_tx_info *pending_tx_info;
 
-		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, work_to_do);
+		work_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
 		if (!work_to_do) {
 			break;
 		}
@@ -1187,7 +1186,6 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif,
 		gop = request_gop;
 
 		vif->tx.req_cons = idx;
-		xenvif_check_rx_xenvif(vif);
 
 		if ((gop - tco) >= MAX_PENDING_REQS)
 			break;
-- 
1.7.2.5
