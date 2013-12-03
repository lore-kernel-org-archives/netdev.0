From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net] xen-netback: clear vif->task on disconnect
Date: Tue, 3 Dec 2013 09:53:47 +0000
Message-ID: <1386064427-31008-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:52424 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060Ab3LCJx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 04:53:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xenvif_start_xmit() relies on checking vif->task for NULL to determine
whether the vif is ready to accept packets. The task thread is stopped in
xenvif_disconnect() but task is not set to NULL. Thus, on a re-connect the
check will give a false positive.
Also since commit ea732dff5cfa10789007bf4a5b935388a0bb2a8f it should not
be possible for xenvif_connect() to be called if the vif is already connected
so change the check of vif->tx_irq to a BUG_ON() and also add a
BUG_ON(vif->task).

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/interface.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 2329ccc..d42efbf 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -370,9 +370,8 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 {
 	int err = -ENOMEM;
 
-	/* Already connected through? */
-	if (vif->tx_irq)
-		return 0;
+	BUG_ON(vif->tx_irq);
+	BUG_ON(vif->task);
 
 	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
@@ -461,8 +460,10 @@ void xenvif_disconnect(struct xenvif *vif)
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
 
-	if (vif->task)
+	if (vif->task) {
 		kthread_stop(vif->task);
+		vif->task = NULL;
+	}
 
 	if (vif->tx_irq) {
 		if (vif->tx_irq == vif->rx_irq)
-- 
1.7.10.4
