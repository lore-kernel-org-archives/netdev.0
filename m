From: Imre Palik <imrep.amz@gmail.com>
Subject: [RFC PATCH] xen-netback: making the bandwidth limiter runtime settable
Date: Fri, 13 Mar 2015 13:51:05 +0100
Message-ID: <1426251065-24279-1-git-send-email-imrep.amz@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Palik, Imre" <imrep@amazon.de>,
	Anthony Liguori <aliguori@amazon.com>
To: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:44645 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbbCMMva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 08:51:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Palik, Imre" <imrep@amazon.de>

With the current netback, the bandwidth limiter's parameters are only
settable during vif setup time.  This patch register a watch on them, and
thus makes them runtime changeable.

When the watch fires, the timer is reset.  The timer's mutex is used for
fencing the change.

Cc: Anthony Liguori <aliguori@amazon.com>
Signed-off-by: Imre Palik <imrep@amazon.de>
---
 drivers/net/xen-netback/common.h    |    4 ++
 drivers/net/xen-netback/interface.c |    1 +
 drivers/net/xen-netback/netback.c   |    4 +-
 drivers/net/xen-netback/xenbus.c    |   73 +++++++++++++++++++++++++++++++----
 4 files changed, 73 insertions(+), 9 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 589fa25..8a495b3 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -238,6 +238,8 @@ struct xenvif {
 	unsigned int num_queues; /* active queues, resource allocated */
 	unsigned int stalled_queues;
 
+	struct xenbus_watch credit_watch;
+
 	spinlock_t lock;
 
 #ifdef CONFIG_DEBUG_FS
@@ -260,6 +262,8 @@ static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
 	return to_xenbus_device(vif->dev->dev.parent);
 }
 
+void xenvif_tx_credit_callback(unsigned long data);
+
 struct xenvif *xenvif_alloc(struct device *parent,
 			    domid_t domid,
 			    unsigned int handle);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 3aa8648..34d8038 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -463,6 +463,7 @@ int xenvif_init_queue(struct xenvif_queue *queue)
 	queue->credit_bytes = queue->remaining_credit = ~0UL;
 	queue->credit_usec  = 0UL;
 	init_timer(&queue->credit_timeout);
+	queue->credit_timeout.function = xenvif_tx_credit_callback;
 	queue->credit_window_start = get_jiffies_64();
 
 	queue->rx_queue_max = XENVIF_RX_QUEUE_BYTES;
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index cab9f52..bcc1880 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -641,7 +641,7 @@ static void tx_add_credit(struct xenvif_queue *queue)
 	queue->remaining_credit = min(max_credit, max_burst);
 }
 
-static void tx_credit_callback(unsigned long data)
+void xenvif_tx_credit_callback(unsigned long data)
 {
 	struct xenvif_queue *queue = (struct xenvif_queue *)data;
 	tx_add_credit(queue);
@@ -1170,7 +1170,7 @@ static bool tx_credit_exceeded(struct xenvif_queue *queue, unsigned size)
 		queue->credit_timeout.data     =
 			(unsigned long)queue;
 		queue->credit_timeout.function =
-			tx_credit_callback;
+			xenvif_tx_credit_callback;
 		mod_timer(&queue->credit_timeout,
 			  next_credit);
 		queue->credit_window_start = next_credit;
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 794204e..c6528de 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -41,6 +41,7 @@ static void connect(struct backend_info *be);
 static int read_xenbus_vif_flags(struct backend_info *be);
 static int backend_create_xenvif(struct backend_info *be);
 static void unregister_hotplug_status_watch(struct backend_info *be);
+static void xen_unregister_watchers(struct xenvif *vif);
 static void set_backend_state(struct backend_info *be,
 			      enum xenbus_state state);
 
@@ -232,6 +233,7 @@ static int netback_remove(struct xenbus_device *dev)
 	unregister_hotplug_status_watch(be);
 	if (be->vif) {
 		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
+		xen_unregister_watchers(be->vif);
 		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
 		xenvif_free(be->vif);
 		be->vif = NULL;
@@ -430,6 +432,7 @@ static int backend_create_xenvif(struct backend_info *be)
 static void backend_disconnect(struct backend_info *be)
 {
 	if (be->vif) {
+		xen_unregister_watchers(be->vif);
 #ifdef CONFIG_DEBUG_FS
 		xenvif_debugfs_delif(be->vif);
 #endif /* CONFIG_DEBUG_FS */
@@ -594,13 +597,9 @@ static void xen_net_read_rate(struct xenbus_device *dev,
 	unsigned long b, u;
 	char *ratestr;
 
-	/* Default to unlimited bandwidth. */
-	*bytes = ~0UL;
-	*usec = 0;
-
 	ratestr = xenbus_read(XBT_NIL, dev->nodename, "rate", NULL);
 	if (IS_ERR(ratestr))
-		return;
+		goto reset;
 
 	s = ratestr;
 	b = simple_strtoul(s, &e, 10);
@@ -612,15 +611,21 @@ static void xen_net_read_rate(struct xenbus_device *dev,
 	if ((s == e) || (*e != '\0'))
 		goto fail;
 
+	kfree(ratestr);
+
 	*bytes = b;
 	*usec = u;
 
-	kfree(ratestr);
 	return;
 
- fail:
+fail:
 	pr_warn("Failed to parse network rate limit. Traffic unlimited.\n");
 	kfree(ratestr);
+
+reset:
+	/* Default to unlimited bandwidth. */
+	*bytes = ~0UL;
+	*usec = 0;
 }
 
 static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
@@ -645,6 +650,59 @@ static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
 	return 0;
 }
 
+static void xen_net_rate_changed(struct xenbus_watch *watch,
+				const char **vec, unsigned int len)
+{
+	struct xenvif *vif = container_of(watch, struct xenvif, credit_watch);
+	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
+	unsigned long   credit_bytes;
+	unsigned long   credit_usec;
+	unsigned int queue_index;
+
+	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
+	for (queue_index = 0; queue_index < vif->num_queues; queue_index++) {
+		struct xenvif_queue *queue = &vif->queues[queue_index];
+
+		queue->credit_bytes = credit_bytes;
+		queue->credit_usec = credit_usec;
+		if (!mod_timer_pending(&queue->credit_timeout, jiffies) &&
+			queue->remaining_credit > queue->credit_bytes) {
+			queue->remaining_credit = queue->credit_bytes;
+		}
+	}
+}
+
+static int xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
+{
+	int err = 0;
+	char *node;
+	unsigned maxlen = strlen(dev->nodename) + sizeof("/rate");
+
+	node = kmalloc(maxlen, GFP_KERNEL);
+	if (!node)
+		return -ENOMEM;
+	sprintf(node, "%s/rate", dev->nodename);
+	vif->credit_watch.node = node;
+	vif->credit_watch.callback = xen_net_rate_changed;
+	err = register_xenbus_watch(&vif->credit_watch);
+	if (err) {
+		pr_err("Failed to set watcher %s\n", vif->credit_watch.node);
+		kfree(node);
+		vif->credit_watch.node = 0;
+		vif->credit_watch.callback = 0;
+	}
+	return err;
+}
+
+static void xen_unregister_watchers(struct xenvif *vif)
+{
+	if (vif->credit_watch.node) {
+		unregister_xenbus_watch(&vif->credit_watch);
+		kfree(vif->credit_watch.node);
+		vif->credit_watch.node = NULL;
+	}
+}
+
 static void unregister_hotplug_status_watch(struct backend_info *be)
 {
 	if (be->have_hotplug_status_watch) {
@@ -709,6 +767,7 @@ static void connect(struct backend_info *be)
 	}
 
 	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
+	xen_register_watchers(dev, be->vif);
 	read_xenbus_vif_flags(be);
 
 	/* Use the number of queues requested by the frontend */
-- 
1.7.9.5
