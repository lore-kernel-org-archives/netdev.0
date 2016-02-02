From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2] xen-netback: implement dynamic multicast control
Date: Tue, 2 Feb 2016 11:31:08 +0000
Message-ID: <1454412668-6472-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:35879 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754625AbcBBLir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 06:38:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My recent patch to the Xen Project documents a protocol for 'dynamic
multicast control' in netif.h. This extends the previous multicast control
protocol to not require a shared ring reconnection to turn the feature off.
Instead the backend watches the "request-multicast-control" key in xenstore
and turns the feature off if the key value is written to zero.

This patch adds support for dynamic multicast control in xen-netback.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---

v2:
 - Log error on failure to allocate memory for multicast watch
---
 drivers/net/xen-netback/common.h |  1 +
 drivers/net/xen-netback/xenbus.c | 87 ++++++++++++++++++++++++++++++++++++----
 2 files changed, 80 insertions(+), 8 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 0333ab0..1128252 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -251,6 +251,7 @@ struct xenvif {
 	unsigned int stalled_queues;
 
 	struct xenbus_watch credit_watch;
+	struct xenbus_watch mcast_ctrl_watch;
 
 	spinlock_t lock;
 
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 56ebd82..f8345ca 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -327,7 +327,7 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
-		/* We support multicast-control. */
+		/* We support dynamic multicast-control. */
 		err = xenbus_printf(xbt, dev->nodename,
 				    "feature-multicast-control", "%d", 1);
 		if (err) {
@@ -335,6 +335,14 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		err = xenbus_printf(xbt, dev->nodename,
+				    "feature-dynamic-multicast-control",
+				    "%d", 1);
+		if (err) {
+			message = "writing feature-dynamic-multicast-control";
+			goto abort_transaction;
+		}
+
 		err = xenbus_transaction_end(xbt, 0);
 	} while (err == -EAGAIN);
 
@@ -683,7 +691,8 @@ static void xen_net_rate_changed(struct xenbus_watch *watch,
 	}
 }
 
-static int xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
+static int xen_register_credit_watch(struct xenbus_device *dev,
+				     struct xenvif *vif)
 {
 	int err = 0;
 	char *node;
@@ -708,7 +717,7 @@ static int xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
 	return err;
 }
 
-static void xen_unregister_watchers(struct xenvif *vif)
+static void xen_unregister_credit_watch(struct xenvif *vif)
 {
 	if (vif->credit_watch.node) {
 		unregister_xenbus_watch(&vif->credit_watch);
@@ -717,6 +726,73 @@ static void xen_unregister_watchers(struct xenvif *vif)
 	}
 }
 
+static void xen_mcast_ctrl_changed(struct xenbus_watch *watch,
+				   const char **vec, unsigned int len)
+{
+	struct xenvif *vif = container_of(watch, struct xenvif,
+					  mcast_ctrl_watch);
+	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
+	int val;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend,
+			 "request-multicast-control", "%d", &val) < 0)
+		val = 0;
+	vif->multicast_control = !!val;
+}
+
+static int xen_register_mcast_ctrl_watch(struct xenbus_device *dev,
+					 struct xenvif *vif)
+{
+	int err = 0;
+	char *node;
+	unsigned maxlen = strlen(dev->otherend) +
+		sizeof("/request-multicast-control");
+
+	if (vif->mcast_ctrl_watch.node)
+		return -EADDRINUSE;
+
+	node = kmalloc(maxlen, GFP_KERNEL);
+	if (!node) {
+		pr_err("Failed to allocate memory for watch\n");
+		return -ENOMEM;
+	}
+	snprintf(node, maxlen, "%s/request-multicast-control",
+		 dev->otherend);
+	vif->mcast_ctrl_watch.node = node;
+	vif->mcast_ctrl_watch.callback = xen_mcast_ctrl_changed;
+	err = register_xenbus_watch(&vif->mcast_ctrl_watch);
+	if (err) {
+		pr_err("Failed to set watcher %s\n",
+		       vif->mcast_ctrl_watch.node);
+		kfree(node);
+		vif->mcast_ctrl_watch.node = NULL;
+		vif->mcast_ctrl_watch.callback = NULL;
+	}
+	return err;
+}
+
+static void xen_unregister_mcast_ctrl_watch(struct xenvif *vif)
+{
+	if (vif->mcast_ctrl_watch.node) {
+		unregister_xenbus_watch(&vif->mcast_ctrl_watch);
+		kfree(vif->mcast_ctrl_watch.node);
+		vif->mcast_ctrl_watch.node = NULL;
+	}
+}
+
+static void xen_register_watchers(struct xenbus_device *dev,
+				  struct xenvif *vif)
+{
+	xen_register_credit_watch(dev, vif);
+	xen_register_mcast_ctrl_watch(dev, vif);
+}
+
+static void xen_unregister_watchers(struct xenvif *vif)
+{
+	xen_unregister_mcast_ctrl_watch(vif);
+	xen_unregister_credit_watch(vif);
+}
+
 static void unregister_hotplug_status_watch(struct backend_info *be)
 {
 	if (be->have_hotplug_status_watch) {
@@ -1030,11 +1106,6 @@ static int read_xenbus_vif_flags(struct backend_info *be)
 		val = 0;
 	vif->ipv6_csum = !!val;
 
-	if (xenbus_scanf(XBT_NIL, dev->otherend, "request-multicast-control",
-			 "%d", &val) < 0)
-		val = 0;
-	vif->multicast_control = !!val;
-
 	return 0;
 }
 
-- 
2.1.4
