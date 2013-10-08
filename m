From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH] xen-netback: Don't destroy the netdev until the vif is
 shut
Date: Tue, 8 Oct 2013 14:39:57 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD012F451@AMSPEX01CL01.citrite.net>
References: <20131004.002248.789391156050342547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29962 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509Ab3JHOmL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 10:42:11 -0400
In-Reply-To: <20131004.002248.789391156050342547.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 04 October 2013 05:23
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; Wei Liu
> Subject: Re: [PATCH] xen-netback: Don't destroy the netdev until the vif is
> shut
> 
> 
> Can one of you do -stable backports of this change for v3.11 and any
> other active -stable branch where this fix is relevant?
> 
> I gave it a shot, and it got outside my realm of expertise.
> 
> Thanks!

Ok. Here's a backport to 3.11.

  Paul

--8<--
>From 158011889a79ad7cebdd30d551adcfeae80b8989 Mon Sep 17 00:00:00 2001
From: Paul Durrant <paul.durrant@citrix.com>
Date: Tue, 8 Oct 2013 14:56:44 +0100
Subject: [PATCH] xen-netback: Don't destroy the netdev until the vif is shut
 down

[ upstream commit id: 279f438e36c0a70b23b86d2090aeec50155034a9 ]

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
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/common.h    |    1 +
 drivers/net/xen-netback/interface.c |   23 +++++++++--------------
 drivers/net/xen-netback/xenbus.c    |   17 ++++++++++++-----
 3 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 8a4d77e..4d9a5e7 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -120,6 +120,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
 		   unsigned int rx_evtchn);
 void xenvif_disconnect(struct xenvif *vif);
+void xenvif_free(struct xenvif *vif);
 
 void xenvif_get(struct xenvif *vif);
 void xenvif_put(struct xenvif *vif);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 087d2db..73336c1 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -326,6 +326,9 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	}
 
 	netdev_dbg(dev, "Successfully created xenvif\n");
+
+	__module_get(THIS_MODULE);
+
 	return vif;
 }
 
@@ -413,12 +416,6 @@ void xenvif_carrier_off(struct xenvif *vif)
 
 void xenvif_disconnect(struct xenvif *vif)
 {
-	/* Disconnect funtion might get called by generic framework
-	 * even before vif connects, so we need to check if we really
-	 * need to do a module_put.
-	 */
-	int need_module_put = 0;
-
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
 
@@ -432,18 +429,16 @@ void xenvif_disconnect(struct xenvif *vif)
 			unbind_from_irqhandler(vif->tx_irq, vif);
 			unbind_from_irqhandler(vif->rx_irq, vif);
 		}
-		/* vif->irq is valid, we had a module_get in
-		 * xenvif_connect.
-		 */
-		need_module_put = 1;
 	}
 
-	unregister_netdev(vif->dev);
-
 	xen_netbk_unmap_frontend_rings(vif);
+}
+
+void xenvif_free(struct xenvif *vif)
+{
+	unregister_netdev(vif->dev);
 
 	free_netdev(vif->dev);
 
-	if (need_module_put)
-		module_put(THIS_MODULE);
+	module_put(THIS_MODULE);
 }
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 1fe48fe3..a53782e 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -42,7 +42,7 @@ static int netback_remove(struct xenbus_device *dev)
 	if (be->vif) {
 		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
 		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
-		xenvif_disconnect(be->vif);
+		xenvif_free(be->vif);
 		be->vif = NULL;
 	}
 	kfree(be);
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
