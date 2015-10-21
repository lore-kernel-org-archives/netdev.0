From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 7/8] xen-netback: add support for a multi-queue hash mapping table
Date: Wed, 21 Oct 2015 11:36:24 +0100
Message-ID: <1445423785-4654-8-git-send-email-paul.durrant@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:51211 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752832AbbJUKhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 06:37:06 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advertise the capability to handle a hash mapping specified by the
frontend (see netif.h for details).

Add an ndo_select() entry point so that, of the frontend does specify a
hash mapping, the skb hash is extracted and mapped to a queue. If no
mapping is specified then the fallback queue selection function is
called so there is no change in behaviour.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   7 ++
 drivers/net/xen-netback/interface.c |  14 ++++
 drivers/net/xen-netback/xenbus.c    | 154 ++++++++++++++++++++++++++++++------
 3 files changed, 152 insertions(+), 23 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 1bce5a5..23f2275 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -212,6 +212,8 @@ struct xenvif_mcast_addr {
 
 #define XEN_NETBK_MCAST_MAX 64
 
+#define XEN_NETBK_MAX_HASH_MAPPING_SIZE 128
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
@@ -244,7 +246,12 @@ struct xenvif {
 	unsigned int num_queues; /* active queues, resource allocated */
 	unsigned int stalled_queues;
 
+	struct {
+		unsigned int table[XEN_NETBK_MAX_HASH_MAPPING_SIZE];
+		unsigned int length;
+	} hash_mapping;
 	struct xenbus_watch credit_watch;
+	struct xenbus_watch hash_mapping_watch;
 
 	spinlock_t lock;
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index e7bd63e..0c7da7b 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -142,6 +142,19 @@ void xenvif_wake_queue(struct xenvif_queue *queue)
 	netif_tx_wake_queue(netdev_get_tx_queue(dev, id));
 }
 
+static u16 xenvif_select_queue(struct net_device *dev, struct sk_buff *skb,
+			       void *accel_priv,
+			       select_queue_fallback_t fallback)
+{
+	struct xenvif *vif = netdev_priv(dev);
+
+	if (vif->hash_mapping.length == 0)
+		return fallback(dev, skb) % dev->real_num_tx_queues;
+
+	return vif->hash_mapping.table[skb_get_hash_raw(skb) %
+				       vif->hash_mapping.length];
+}
+
 static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
@@ -386,6 +399,7 @@ static const struct ethtool_ops xenvif_ethtool_ops = {
 };
 
 static const struct net_device_ops xenvif_netdev_ops = {
+	.ndo_select_queue = xenvif_select_queue,
 	.ndo_start_xmit	= xenvif_start_xmit,
 	.ndo_get_stats	= xenvif_get_stats,
 	.ndo_open	= xenvif_open,
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index a31bcee..f5ed945 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -367,6 +367,13 @@ static int netback_probe(struct xenbus_device *dev,
 	if (err)
 		pr_debug("Error writing multi-queue-max-queues\n");
 
+	/* Multi-queue mapping support: This is an optional feature. */
+	err = xenbus_printf(XBT_NIL, dev->nodename,
+			    "multi-queue-max-hash-mapping-length", "%u",
+			    XEN_NETBK_MAX_HASH_MAPPING_SIZE);
+	if (err)
+		pr_debug("Error writing multi-queue-max-hash-mapping-length\n");
+
 	script = xenbus_read(XBT_NIL, dev->nodename, "script", NULL);
 	if (IS_ERR(script)) {
 		err = PTR_ERR(script);
@@ -691,38 +698,139 @@ static void xen_net_rate_changed(struct xenbus_watch *watch,
 	}
 }
 
-static int xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
+static void xen_net_read_multi_queue_hash_mapping(struct xenvif *vif)
+{
+	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
+	char *str, *token;
+	unsigned int *table;
+	unsigned int n, i;
+
+	str = xenbus_read(XBT_NIL, dev->otherend,
+			  "multi-queue-hash-mapping", NULL);
+	if (IS_ERR(str))
+		goto fail1;
+
+	table = kcalloc(ARRAY_SIZE(vif->hash_mapping.table),
+			sizeof(unsigned int),
+			GFP_KERNEL);
+	if (!table) {
+		pr_err("%s: failed to allocate mapping table\n",
+		       dev->nodename);
+		goto fail2;
+	}
+
+	n = 0;
+	while ((token = strsep(&str, ",")) != NULL) {
+		int rc;
+
+		if (n >= ARRAY_SIZE(vif->hash_mapping.table)) {
+			pr_err("%s: mapping table too big\n",
+			       dev->nodename);
+			goto fail3;
+		}
+
+		rc = kstrtouint(token, 0, &table[n]);
+		if (rc < 0) {
+			pr_err("%s: invalid mapping table value (%s at index %u)\n",
+			       dev->nodename, token, n);
+			goto fail3;
+		}
+
+		n++;
+	}
+
+	if (n == 0) {
+		pr_err("%s: invalid mapping table\n", dev->nodename);
+		goto fail3;
+	}
+
+	vif->hash_mapping.length = n;
+
+	for (i = 0; i < n; i++)
+		vif->hash_mapping.table[i] =
+			(table[i] < vif->num_queues) ? table[i] : 0;
+
+	kfree(table);
+	kfree(str);
+	return;
+
+fail3:
+	kfree(table);
+fail2:
+	kfree(str);
+fail1:
+	vif->hash_mapping.length = 0;
+}
+
+static void xen_hash_mapping_changed(struct xenbus_watch *watch,
+				     const char **vec, unsigned int len)
+{
+	struct xenvif *vif = container_of(watch, struct xenvif,
+					  hash_mapping_watch);
+
+	xen_net_read_multi_queue_hash_mapping(vif);
+}
+
+static int xenvif_register_watch(const char *prefix, const char *name,
+				 void (*callback)(struct xenbus_watch *,
+						  const char **vec,
+						  unsigned int len),
+				 struct xenbus_watch *watch)
 {
-	int err = 0;
+	unsigned int len;
 	char *node;
-	unsigned maxlen = strlen(dev->nodename) + sizeof("/rate");
+	int err;
 
-	if (vif->credit_watch.node)
+	if (watch->node)
 		return -EADDRINUSE;
 
-	node = kmalloc(maxlen, GFP_KERNEL);
+	len = strlen(prefix) + 1 + strlen(name) + 1;
+
+	node = kmalloc(len, GFP_KERNEL);
 	if (!node)
 		return -ENOMEM;
-	snprintf(node, maxlen, "%s/rate", dev->nodename);
-	vif->credit_watch.node = node;
-	vif->credit_watch.callback = xen_net_rate_changed;
-	err = register_xenbus_watch(&vif->credit_watch);
+
+	snprintf(node, len, "%s/%s", prefix, name);
+	watch->node = node;
+	watch->callback = callback;
+	err = register_xenbus_watch(watch);
 	if (err) {
-		pr_err("Failed to set watcher %s\n", vif->credit_watch.node);
+		pr_err("Failed to set watch %s\n", node);
 		kfree(node);
-		vif->credit_watch.node = NULL;
-		vif->credit_watch.callback = NULL;
+		watch->node = NULL;
+		watch->callback = NULL;
 	}
 	return err;
 }
 
+static void xenvif_unregister_watch(struct xenbus_watch *watch)
+{
+	if (!watch->node)
+		return;
+
+	unregister_xenbus_watch(watch);
+	kfree(watch->node);
+
+	watch->node = NULL;
+	watch->callback = NULL;
+}
+
+static void xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
+{
+	xenvif_register_watch(dev->nodename, "rate",
+			      xen_net_rate_changed,
+			      &vif->credit_watch);
+
+	xenvif_register_watch(dev->otherend,
+			      "multi-queue-hash-mapping",
+			      xen_hash_mapping_changed,
+			      &vif->hash_mapping_watch);
+}
+
 static void xen_unregister_watchers(struct xenvif *vif)
 {
-	if (vif->credit_watch.node) {
-		unregister_xenbus_watch(&vif->credit_watch);
-		kfree(vif->credit_watch.node);
-		vif->credit_watch.node = NULL;
-	}
+	xenvif_unregister_watch(&vif->hash_mapping_watch);
+	xenvif_unregister_watch(&vif->credit_watch);
 }
 
 static void unregister_hotplug_status_watch(struct backend_info *be)
@@ -782,6 +890,12 @@ static void connect(struct backend_info *be)
 		return;
 	}
 
+	/* Use the number of queues requested by the frontend */
+	be->vif->queues = vzalloc(requested_num_queues *
+				  sizeof(struct xenvif_queue));
+	be->vif->num_queues = requested_num_queues;
+	be->vif->stalled_queues = requested_num_queues;
+
 	err = xen_net_read_mac(dev, be->vif->fe_dev_addr);
 	if (err) {
 		xenbus_dev_fatal(dev, err, "parsing %s/mac", dev->nodename);
@@ -793,12 +907,6 @@ static void connect(struct backend_info *be)
 	xen_register_watchers(dev, be->vif);
 	read_xenbus_vif_flags(be);
 
-	/* Use the number of queues requested by the frontend */
-	be->vif->queues = vzalloc(requested_num_queues *
-				  sizeof(struct xenvif_queue));
-	be->vif->num_queues = requested_num_queues;
-	be->vif->stalled_queues = requested_num_queues;
-
 	for (queue_index = 0; queue_index < requested_num_queues; ++queue_index) {
 		queue = &be->vif->queues[queue_index];
 		queue->vif = be->vif;
-- 
2.1.4
