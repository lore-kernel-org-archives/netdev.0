From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 3/8] netback: get/put module along with vif connect/disconnect
Date: Fri, 15 Feb 2013 16:00:04 +0000
Message-ID: <1360944010-15336-4-git-send-email-wei.liu2@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29656 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756331Ab3BOQAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 11:00:53 -0500
In-Reply-To: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is vif running and user unloads netback, guest's network interface
just mysteriously stops working. So we need to prevent unloading netback
module if there is vif running.

The disconnect function of vif may get called by the generic framework even
before vif connects, so thers is an extra check on whether we actually need to
put module when disconnecting a vif.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 221f426..db638e1 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -314,6 +314,8 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	if (vif->irq)
 		return 0;
 
+	__module_get(THIS_MODULE);
+
 	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
@@ -341,6 +343,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 err_unmap:
 	xen_netbk_unmap_frontend_rings(vif);
 err:
+	module_put(THIS_MODULE);
 	return err;
 }
 
@@ -358,18 +361,31 @@ void xenvif_carrier_off(struct xenvif *vif)
 
 void xenvif_disconnect(struct xenvif *vif)
 {
+	/*
+	 * This function may get called even before vif connets, set
+	 * need_module_put if vif->irq != 0, which means vif has
+	 * already connected, we should call module_put to balance the
+	 * previous __module_get.
+	 */
+	int need_module_put = 0;
+
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
 
 	atomic_dec(&vif->refcnt);
 	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
 
-	if (vif->irq)
+	if (vif->irq) {
 		unbind_from_irqhandler(vif->irq, vif);
+		need_module_put = 1;
+	}
 
 	unregister_netdev(vif->dev);
 
 	xen_netbk_unmap_frontend_rings(vif);
 
 	free_netdev(vif->dev);
+
+	if (need_module_put)
+		module_put(THIS_MODULE);
 }
-- 
1.7.10.4
