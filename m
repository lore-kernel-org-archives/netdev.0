From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 8/8] xen-netback: add support for toeplitz hashing
Date: Wed, 21 Oct 2015 11:36:25 +0100
Message-ID: <1445423785-4654-9-git-send-email-paul.durrant@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:9593 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961AbbJUKhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 06:37:07 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds all the necessary infrastructure to allow a frontend to
specify toeplitz hashing of network packets on its receive side. (See
netif.h for details of the xenbus protocol).

The toeplitz hash algorithm itself was based on pseudo-code provided by
Microsoft at:

https://msdn.microsoft.com/en-us/library/windows/hardware/ff570725.aspx

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |  32 ++++++
 drivers/net/xen-netback/interface.c | 111 +++++++++++++++++++-
 drivers/net/xen-netback/xenbus.c    | 195 ++++++++++++++++++++++++++++++++++++
 3 files changed, 335 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 23f2275..4ebfad9 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -214,6 +214,31 @@ struct xenvif_mcast_addr {
 
 #define XEN_NETBK_MAX_HASH_MAPPING_SIZE 128
 
+enum xenvif_hash_alg {
+	XEN_NETBK_HASH_UNSPECIFIED,
+	XEN_NETBK_HASH_TOEPLITZ,
+};
+
+#define XEN_NETBK_MAX_TOEPLITZ_KEY_LENGTH 40
+
+struct xenvif_toeplitz_params {
+	union {
+		struct {
+			u8 ipv4_enabled:1;
+			u8 ipv4_tcp_enabled:1;
+			u8 ipv6_enabled:1;
+			u8 ipv6_tcp_enabled:1;
+		};
+		u8 types;
+	};
+
+	u8 key[XEN_NETBK_MAX_TOEPLITZ_KEY_LENGTH];
+};
+
+union xenvif_hash_params {
+	struct xenvif_toeplitz_params toeplitz;
+};
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
@@ -250,8 +275,15 @@ struct xenvif {
 		unsigned int table[XEN_NETBK_MAX_HASH_MAPPING_SIZE];
 		unsigned int length;
 	} hash_mapping;
+
+	/* Hash */
+	enum xenvif_hash_alg hash_alg;
+	union xenvif_hash_params hash_params;
+
 	struct xenbus_watch credit_watch;
 	struct xenbus_watch hash_mapping_watch;
+	struct xenbus_watch hash_watch;
+	struct xenbus_watch hash_params_watch;
 
 	spinlock_t lock;
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 0c7da7b..38eee4f 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -142,17 +142,122 @@ void xenvif_wake_queue(struct xenvif_queue *queue)
 	netif_tx_wake_queue(netdev_get_tx_queue(dev, id));
 }
 
+static u32 toeplitz_hash(const u8 *k, unsigned int klen,
+			 const u8 *d, unsigned int dlen)
+{
+	unsigned int di, ki;
+	u64 prefix = 0;
+	u64 hash = 0;
+
+	for (ki = 0; ki < 8; ki++) {
+		prefix |= ki < klen ? k[ki] : 0;
+		prefix <<= 8;
+	}
+
+	for (di = 0; di < dlen; di++) {
+		u8 byte = d[di];
+		unsigned int bit;
+
+		prefix |= ki < klen ? k[ki] : 0;
+		ki++;
+
+		for (bit = 0; bit < 8; bit++) {
+			if (byte & 0x80)
+				hash ^= prefix;
+			byte <<= 1;
+			prefix <<= 1;
+		}
+	}
+
+	return hash >> 32;
+}
+
+static void xenvif_set_toeplitz_hash(struct xenvif *vif, struct sk_buff *skb)
+{
+	struct flow_keys flow;
+	u32 hash = 0;
+	enum pkt_hash_types type = PKT_HASH_TYPE_NONE;
+	const u8 *key = vif->hash_params.toeplitz.key;
+	const unsigned int len = ARRAY_SIZE(vif->hash_params.toeplitz.key);
+
+	memset(&flow, 0, sizeof(flow));
+	if (!skb_flow_dissect_flow_keys(skb, &flow, 0))
+		goto done;
+
+	if (flow.basic.n_proto == htons(ETH_P_IP)) {
+		if (vif->hash_params.toeplitz.ipv4_tcp_enabled &&
+		    flow.basic.ip_proto == IPPROTO_TCP) {
+			u8 data[12];
+
+			memcpy(&data[0], &flow.addrs.v4addrs.src, 4);
+			memcpy(&data[4], &flow.addrs.v4addrs.dst, 4);
+			memcpy(&data[8], &flow.ports.src, 2);
+			memcpy(&data[10], &flow.ports.dst, 2);
+
+			hash = toeplitz_hash(key, len,
+					     data, sizeof(data));
+			type = PKT_HASH_TYPE_L4;
+		} else if (vif->hash_params.toeplitz.ipv4_enabled) {
+			u8 data[8];
+
+			memcpy(&data[0], &flow.addrs.v4addrs.src, 4);
+			memcpy(&data[4], &flow.addrs.v4addrs.dst, 4);
+
+			hash = toeplitz_hash(key, len,
+					     data, sizeof(data));
+			type = PKT_HASH_TYPE_L3;
+		}
+	} else if (flow.basic.n_proto == htons(ETH_P_IPV6)) {
+		if (vif->hash_params.toeplitz.ipv6_tcp_enabled &&
+		    flow.basic.ip_proto == IPPROTO_TCP) {
+			u8 data[36];
+
+			memcpy(&data[0], &flow.addrs.v6addrs.src, 16);
+			memcpy(&data[16], &flow.addrs.v6addrs.dst, 16);
+			memcpy(&data[32], &flow.ports.src, 2);
+			memcpy(&data[34], &flow.ports.dst, 2);
+
+			hash = toeplitz_hash(key, len,
+					     data, sizeof(data));
+			type = PKT_HASH_TYPE_L4;
+		} else if (vif->hash_params.toeplitz.ipv6_enabled) {
+			u8 data[32];
+
+			memcpy(&data[0], &flow.addrs.v6addrs.src, 16);
+			memcpy(&data[16], &flow.addrs.v6addrs.dst, 16);
+
+			hash = toeplitz_hash(key, len,
+					     data, sizeof(data));
+			type = PKT_HASH_TYPE_L3;
+		}
+	}
+
+done:
+	skb_set_hash(skb, hash, type);
+}
+
 static u16 xenvif_select_queue(struct net_device *dev, struct sk_buff *skb,
 			       void *accel_priv,
 			       select_queue_fallback_t fallback)
 {
 	struct xenvif *vif = netdev_priv(dev);
+	u32 hash;
+
+	/* If a hash algorithm has been specified re-calculate accordingly */
+	switch (vif->hash_alg) {
+	case XEN_NETBK_HASH_TOEPLITZ:
+		xenvif_set_toeplitz_hash(vif, skb);
+		hash = skb_get_hash_raw(skb);
+		break;
+	default:
+		hash = fallback(dev, skb);
+		break;
+	}
 
 	if (vif->hash_mapping.length == 0)
-		return fallback(dev, skb) % dev->real_num_tx_queues;
+		return hash % dev->real_num_tx_queues;
 
-	return vif->hash_mapping.table[skb_get_hash_raw(skb) %
-				       vif->hash_mapping.length];
+	return vif->hash_mapping.table[hash % vif->hash_mapping.length];
 }
 
 static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index f5ed945..9d12bd8 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -246,6 +246,34 @@ static int netback_remove(struct xenbus_device *dev)
 	return 0;
 }
 
+static int netback_set_toeplitz_caps(struct xenbus_device *dev)
+{
+	unsigned int len = strlen(dev->nodename) +
+		sizeof("/multi-queue-hash-caps-toeplitz");
+	char *node;
+	int err;
+
+	node = kmalloc(len, GFP_KERNEL);
+	if (!node)
+		return -ENOMEM;
+
+	snprintf(node, len, "%s/multi-queue-hash-caps-toeplitz",
+		 dev->nodename);
+
+	err = xenbus_printf(XBT_NIL, node,
+			    "types", "ipv4 ipv4+tcp ipv6 ipv6+tcp");
+	if (err)
+		pr_debug("Error writing types\n");
+
+	err = xenbus_printf(XBT_NIL, node,
+			    "max-key-length", "%u",
+			    XEN_NETBK_MAX_TOEPLITZ_KEY_LENGTH);
+	if (err)
+		pr_debug("Error writing max-key-length\n");
+
+	kfree(node);
+	return 0;
+}
 
 /**
  * Entry point to this code when a new device is created.  Allocate the basic
@@ -374,6 +402,17 @@ static int netback_probe(struct xenbus_device *dev,
 	if (err)
 		pr_debug("Error writing multi-queue-max-hash-mapping-length\n");
 
+	/* Selectable multi-queue hash algorithms: This is an optional
+	 * feature.
+	 */
+	err = netback_set_toeplitz_caps(dev);
+	if (!err) {
+		err = xenbus_printf(XBT_NIL, dev->nodename,
+				    "multi-queue-hash-list", "toeplitz");
+		if (err)
+			pr_debug("Error writing multi-queue-hash-list\n");
+	}
+
 	script = xenbus_read(XBT_NIL, dev->nodename, "script", NULL);
 	if (IS_ERR(script)) {
 		err = PTR_ERR(script);
@@ -815,6 +854,153 @@ static void xenvif_unregister_watch(struct xenbus_watch *watch)
 	watch->callback = NULL;
 }
 
+static void xen_net_read_toeplitz_types(struct xenvif *vif,
+					const char *node)
+{
+	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
+	char *str, *token;
+
+	vif->hash_params.toeplitz.types = 0;
+
+	str = xenbus_read(XBT_NIL, node, "types", NULL);
+	if (IS_ERR(str))
+		return;
+
+	while ((token = strsep(&str, " ")) != NULL) {
+		if (strcmp(token, "ipv4") == 0) {
+			vif->hash_params.toeplitz.ipv4_enabled = 1;
+		} else if (strcmp(token, "ipv4+tcp") == 0) {
+			vif->hash_params.toeplitz.ipv4_tcp_enabled = 1;
+		} else if (strcmp(token, "ipv6") == 0) {
+			vif->hash_params.toeplitz.ipv6_enabled = 1;
+		} else if (strcmp(token, "ipv6+tcp") == 0) {
+			vif->hash_params.toeplitz.ipv6_tcp_enabled = 1;
+		} else {
+			pr_err("%s: unknown hash type (%s)\n",
+			       dev->nodename, token);
+			goto fail1;
+		}
+	}
+
+	kfree(str);
+	return;
+
+fail1:
+	vif->hash_params.toeplitz.types = 0;
+}
+
+static void xen_net_read_toeplitz_key(struct xenvif *vif,
+				      const char *node)
+{
+	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
+	char *str, *token;
+	u8 key[40];
+	unsigned int n, i;
+
+	str = xenbus_read(XBT_NIL, node, "key", NULL);
+	if (IS_ERR(str))
+		goto fail1;
+
+	memset(key, 0, sizeof(key));
+
+	n = 0;
+	while ((token = strsep(&str, ",")) != NULL) {
+		int rc;
+
+		if (n >= ARRAY_SIZE(vif->hash_params.toeplitz.key)) {
+			pr_err("%s: key too big\n",
+			       dev->nodename);
+			goto fail2;
+		}
+
+		rc = kstrtou8(token, 0, &key[n]);
+		if (rc < 0) {
+			pr_err("%s: invalid key value (%s at index %u)\n",
+			       dev->nodename, token, n);
+			goto fail2;
+		}
+
+		n++;
+	}
+
+	for (i = 0; i < ARRAY_SIZE(vif->hash_params.toeplitz.key); i++)
+		vif->hash_params.toeplitz.key[i] = key[i];
+
+	kfree(str);
+	return;
+
+fail2:
+	kfree(str);
+fail1:
+	vif->hash_params.toeplitz.types = 0;
+}
+
+static void xen_net_read_toeplitz_params(struct xenvif *vif)
+{
+	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
+	unsigned int len = strlen(dev->otherend) +
+		sizeof("/multi-queue-hash-params-toeplitz");
+	char *node;
+
+	node = kmalloc(len, GFP_KERNEL);
+	if (!node)
+		return;
+	snprintf(node, len, "%s/multi-queue-hash-params-toeplitz",
+		 dev->otherend);
+
+	xen_net_read_toeplitz_types(vif, node);
+	xen_net_read_toeplitz_key(vif, node);
+
+	kfree(node);
+}
+
+static void xen_hash_params_changed(struct xenbus_watch *watch,
+				    const char **vec, unsigned int len)
+{
+	struct xenvif *vif = container_of(watch, struct xenvif,
+					  hash_params_watch);
+
+	switch (vif->hash_alg) {
+	case XEN_NETBK_HASH_TOEPLITZ:
+		xen_net_read_toeplitz_params(vif);
+		break;
+	default:
+		break;
+	}
+}
+
+static void xen_net_read_hash(struct xenvif *vif)
+{
+	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
+	char *str;
+
+	vif->hash_alg = XEN_NETBK_HASH_UNSPECIFIED;
+	xenvif_unregister_watch(&vif->hash_params_watch);
+
+	str = xenbus_read(XBT_NIL, dev->otherend, "multi-queue-hash", NULL);
+	if (IS_ERR(str))
+		return;
+
+	if (strcmp(str, "toeplitz") == 0) {
+		vif->hash_alg = XEN_NETBK_HASH_TOEPLITZ;
+
+		xenvif_register_watch(dev->otherend,
+				      "multi-queue-hash-params-toeplitz",
+				      xen_hash_params_changed,
+				      &vif->hash_params_watch);
+	}
+
+	kfree(str);
+}
+
+static void xen_hash_changed(struct xenbus_watch *watch,
+			     const char **vec, unsigned int len)
+{
+	struct xenvif *vif = container_of(watch, struct xenvif, hash_watch);
+
+	xen_net_read_hash(vif);
+}
+
 static void xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
 {
 	xenvif_register_watch(dev->nodename, "rate",
@@ -825,10 +1011,17 @@ static void xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
 			      "multi-queue-hash-mapping",
 			      xen_hash_mapping_changed,
 			      &vif->hash_mapping_watch);
+
+	xenvif_register_watch(dev->otherend,
+			      "multi-queue-hash",
+			      xen_hash_changed,
+			      &vif->hash_watch);
 }
 
 static void xen_unregister_watchers(struct xenvif *vif)
 {
+	xenvif_unregister_watch(&vif->hash_params_watch);
+	xenvif_unregister_watch(&vif->hash_watch);
 	xenvif_unregister_watch(&vif->hash_mapping_watch);
 	xenvif_unregister_watch(&vif->credit_watch);
 }
@@ -874,6 +1067,8 @@ static void connect(struct backend_info *be)
 	unsigned int requested_num_queues;
 	struct xenvif_queue *queue;
 
+	be->vif->hash_alg = XEN_NETBK_HASH_UNSPECIFIED;
+
 	/* Check whether the frontend requested multiple queues
 	 * and read the number requested.
 	 */
-- 
2.1.4
