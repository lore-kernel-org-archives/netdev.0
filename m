From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net] xen-netback: fix abuse of napi budget
Date: Tue, 10 Dec 2013 10:16:40 +0000
Message-ID: <1386670600-5882-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53022 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035Ab3LJKQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 05:16:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netback seemed to be somewhat confused about the napi budget parameter and
basically ignored it. This patch fixes that, properly limiting the work done
in each poll.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 43341b8..83b4e5b 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1351,14 +1351,15 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	return false;
 }
 
-static unsigned xenvif_tx_build_gops(struct xenvif *vif)
+static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 {
 	struct gnttab_copy *gop = vif->tx_copy_ops, *request_gop;
 	struct sk_buff *skb;
 	int ret;
 
 	while ((nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
-		< MAX_PENDING_REQS)) {
+		< MAX_PENDING_REQS) &&
+	       (skb_queue_len(&vif->tx_queue) < budget)) {
 		struct xen_netif_tx_request txreq;
 		struct xen_netif_tx_request txfrags[XEN_NETBK_LEGACY_SLOTS_MAX];
 		struct page *page;
@@ -1520,14 +1521,13 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif)
 }
 
 
-static int xenvif_tx_submit(struct xenvif *vif, int budget)
+static int xenvif_tx_submit(struct xenvif *vif)
 {
 	struct gnttab_copy *gop = vif->tx_copy_ops;
 	struct sk_buff *skb;
 	int work_done = 0;
 
-	while (work_done < budget &&
-	       (skb = __skb_dequeue(&vif->tx_queue)) != NULL) {
+	while ((skb = __skb_dequeue(&vif->tx_queue)) != NULL) {
 		struct xen_netif_tx_request *txp;
 		u16 pending_idx;
 		unsigned data_len;
@@ -1602,14 +1602,14 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
 	if (unlikely(!tx_work_todo(vif)))
 		return 0;
 
-	nr_gops = xenvif_tx_build_gops(vif);
+	nr_gops = xenvif_tx_build_gops(vif, budget);
 
 	if (nr_gops == 0)
 		return 0;
 
 	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
 
-	work_done = xenvif_tx_submit(vif, nr_gops);
+	work_done = xenvif_tx_submit(vif);
 
 	return work_done;
 }
-- 
1.7.10.4
