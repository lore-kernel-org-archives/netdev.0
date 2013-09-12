From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH] Don't destroy the netdev until the vif is shut down
Date: Thu, 12 Sep 2013 12:08:19 +0100
Message-ID: <1378984100-12295-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53261 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162Ab3ILLIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 07:08:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch, if a frontend cycles through states Closing
and Closed (which Windows frontends need to do) then the netdev
will be destroyed and requires re-invocation of hotplug scripts
to restore state before the frontend can move to Connected. Thus
when udev is not in use the backend gets stuck in InitWait.

With this patch, the netdev is left alone whilst the backend is
still online and is only de-registered and freed just prior to
destroying the vif (which is also nicely symmetrical with the
netdev allocation and registration being done during probe) so
no re-invocation of hotplug scripts is required.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/common.h    |    1 +
 drivers/net/xen-netback/interface.c |   13 ++++++++-----
 drivers/net/xen-netback/xenbus.c    |   15 +++++++++++----
 3 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index a197743..5715318 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -184,6 +184,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
 		   unsigned int rx_evtchn);
 void xenvif_disconnect(struct xenvif *vif);
+void xenvif_free(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
 void xenvif_xenbus_fini(void);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 625c6f4..65e78f9 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -477,14 +477,17 @@ void xenvif_disconnect(struct xenvif *vif)
 	if (vif->task)
 		kthread_stop(vif->task);
 
+	xenvif_unmap_frontend_rings(vif);
+
+	if (need_module_put)
+		module_put(THIS_MODULE);
+}
+
+void xenvif_free(struct xenvif *vif)
+{
 	netif_napi_del(&vif->napi);
 
 	unregister_netdev(vif->dev);
 
-	xenvif_unmap_frontend_rings(vif);
-
 	free_netdev(vif->dev);
-
-	if (need_module_put)
-		module_put(THIS_MODULE);
 }
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 1fe48fe3..1a5683f 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -213,9 +213,18 @@ static void disconnect_backend(struct xenbus_device *dev)
 {
 	struct backend_info *be = dev_get_drvdata(&dev->dev);
 
+	if (be->vif)
+		xenvif_disconnect(be->vif);
+}
+
+static void destroy_backend(struct xenbus_device *dev)
+{
+	struct backend_info *be = dev_get_drvdata(&dev->dev);
+
 	if (be->vif) {
+		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
 		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
-		xenvif_disconnect(be->vif);
+		xenvif_free(be->vif);
 		be->vif = NULL;
 	}
 }
@@ -246,14 +255,11 @@ static void frontend_changed(struct xenbus_device *dev,
 	case XenbusStateConnected:
 		if (dev->state == XenbusStateConnected)
 			break;
-		backend_create_xenvif(be);
 		if (be->vif)
 			connect(be);
 		break;
 
 	case XenbusStateClosing:
-		if (be->vif)
-			kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
 		disconnect_backend(dev);
 		xenbus_switch_state(dev, XenbusStateClosing);
 		break;
@@ -262,6 +268,7 @@ static void frontend_changed(struct xenbus_device *dev,
 		xenbus_switch_state(dev, XenbusStateClosed);
 		if (xenbus_dev_is_online(dev))
 			break;
+		destroy_backend(dev);
 		/* fall through if not online */
 	case XenbusStateUnknown:
 		device_unregister(&dev->dev);
-- 
1.7.10.4
