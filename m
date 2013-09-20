From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2 1/2] xen-netback: add a vif-is-connected flag
Date: Fri, 20 Sep 2013 14:57:39 +0100
Message-ID: <1379685460-25032-2-git-send-email-paul.durrant@citrix.com>
References: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:11246 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab3ITN5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 09:57:45 -0400
In-Reply-To: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having applied my patch to separate vif disconnect and free, I ran into a
BUG when testing resume from S3 with a Windows frontend because the vif task
pointer was not cleared by xenvif_disconnect() and so a double call to this
function tries to stop the thread twice.
Rather than applying a point fix for that issue it seems better to introduce
a boolean to indicate whether the vif is connected or not such that repeated
calls to either xenvif_connect() or xenvif_disconnect() behave appropriately.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/common.h    |    1 +
 drivers/net/xen-netback/interface.c |   24 +++++++++++++-----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 5715318..860d92c 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -169,6 +169,7 @@ struct xenvif {
 
 	/* Miscellaneous private stuff. */
 	struct net_device *dev;
+	bool connected;
 };
 
 static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 01bb854..94b47f5 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -366,7 +366,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	int err = -ENOMEM;
 
 	/* Already connected through? */
-	if (vif->tx_irq)
+	if (vif->connected)
 		return 0;
 
 	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
@@ -425,6 +425,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	wake_up_process(vif->task);
 
+	vif->connected = 1;
 	return 0;
 
 err_rx_unbind:
@@ -453,23 +454,24 @@ void xenvif_carrier_off(struct xenvif *vif)
 
 void xenvif_disconnect(struct xenvif *vif)
 {
+	if (!vif->connected)
+		return;
+
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
 
-	if (vif->tx_irq) {
-		if (vif->tx_irq == vif->rx_irq)
-			unbind_from_irqhandler(vif->tx_irq, vif);
-		else {
-			unbind_from_irqhandler(vif->tx_irq, vif);
-			unbind_from_irqhandler(vif->rx_irq, vif);
-		}
-		vif->tx_irq = 0;
+	if (vif->tx_irq == vif->rx_irq)
+		unbind_from_irqhandler(vif->tx_irq, vif);
+	else {
+		unbind_from_irqhandler(vif->tx_irq, vif);
+		unbind_from_irqhandler(vif->rx_irq, vif);
 	}
 
-	if (vif->task)
-		kthread_stop(vif->task);
+	kthread_stop(vif->task);
 
 	xenvif_unmap_frontend_rings(vif);
+
+	vif->connected = 0;
 }
 
 void xenvif_free(struct xenvif *vif)
-- 
1.7.10.4
