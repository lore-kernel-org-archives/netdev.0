From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] xen-netback: do not report success if xenvif_alloc() fails
Date: Sat, 22 Nov 2014 01:56:28 +0300
Message-ID: <1416610588-19816-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If xenvif_alloc() failes, netback_probe() reports success as well as
"online" uevent is emitted. It does not make any sense, but it just
misleads users.

The patch implements propagation of error code if xenvif creation fails.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/xen-netback/xenbus.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 4e56a27f9689..fab0d4b42f58 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -39,7 +39,7 @@ struct backend_info {
 static int connect_rings(struct backend_info *be, struct xenvif_queue *queue);
 static void connect(struct backend_info *be);
 static int read_xenbus_vif_flags(struct backend_info *be);
-static void backend_create_xenvif(struct backend_info *be);
+static int backend_create_xenvif(struct backend_info *be);
 static void unregister_hotplug_status_watch(struct backend_info *be);
 static void set_backend_state(struct backend_info *be,
 			      enum xenbus_state state);
@@ -352,7 +352,9 @@ static int netback_probe(struct xenbus_device *dev,
 	be->state = XenbusStateInitWait;
 
 	/* This kicks hotplug scripts, so do it immediately. */
-	backend_create_xenvif(be);
+	err = backend_create_xenvif(be);
+	if (err)
+		goto fail;
 
 	return 0;
 
@@ -397,19 +399,19 @@ static int netback_uevent(struct xenbus_device *xdev,
 }
 
 
-static void backend_create_xenvif(struct backend_info *be)
+static int backend_create_xenvif(struct backend_info *be)
 {
 	int err;
 	long handle;
 	struct xenbus_device *dev = be->dev;
 
 	if (be->vif != NULL)
-		return;
+		return 0;
 
 	err = xenbus_scanf(XBT_NIL, dev->nodename, "handle", "%li", &handle);
 	if (err != 1) {
 		xenbus_dev_fatal(dev, err, "reading handle");
-		return;
+		return (err < 0) ? err : -EINVAL;
 	}
 
 	be->vif = xenvif_alloc(&dev->dev, dev->otherend_id, handle);
@@ -417,10 +419,11 @@ static void backend_create_xenvif(struct backend_info *be)
 		err = PTR_ERR(be->vif);
 		be->vif = NULL;
 		xenbus_dev_fatal(dev, err, "creating interface");
-		return;
+		return err;
 	}
 
 	kobject_uevent(&dev->dev.kobj, KOBJ_ONLINE);
+	return 0;
 }
 
 static void backend_disconnect(struct backend_info *be)
-- 
1.9.1
