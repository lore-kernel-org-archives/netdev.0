From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 11/16] net: dsa: Refactor selection of tag ops into a function
Date: Fri, 27 May 2016 03:20:45 +0200
Message-ID: <1464312050-23023-12-git-send-email-andrew@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52569 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845AbcE0B1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 21:27:46 -0400
In-Reply-To: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the two switch statements with an array lookup, and store the
result in the dsa tree structure. The drivers no longer need to know
the selected tag protocol, so remove it from the dsa switch structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/net/dsa.h  |  8 +++++-
 net/dsa/dsa.c      | 71 ++++++++++++++++++++++++++++++++++--------------------
 net/dsa/dsa_priv.h |  1 +
 net/dsa/slave.c    | 35 +--------------------------
 4 files changed, 54 insertions(+), 61 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index ea0e7d30342b..adb75422bc6c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -26,6 +26,7 @@ enum dsa_tag_protocol {
 	DSA_TAG_PROTO_TRAILER,
 	DSA_TAG_PROTO_EDSA,
 	DSA_TAG_PROTO_BRCM,
+	_DSA_TAG_LAST,
 };
 
 #define DSA_MAX_SWITCHES	4
@@ -100,7 +101,6 @@ struct dsa_switch_tree {
 				       struct net_device *dev,
 				       struct packet_type *pt,
 				       struct net_device *orig_dev);
-	enum dsa_tag_protocol	tag_protocol;
 
 	/*
 	 * Original copy of the master netdev ethtool_ops
@@ -117,6 +117,12 @@ struct dsa_switch_tree {
 	 * Data for the individual switch chips.
 	 */
 	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
+
+	/*
+	 * Tagging protocol operations for adding and removing an
+	 * encapsulation tag.
+	 */
+	const struct dsa_device_ops *tag_ops;
 };
 
 struct dsa_port {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 20eede3facf5..49cdf143c822 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -29,6 +29,33 @@
 
 char dsa_driver_version[] = "0.1";
 
+static struct sk_buff *dsa_slave_notag_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
+{
+	/* Just return the original SKB */
+	return skb;
+}
+
+static const struct dsa_device_ops none_ops = {
+	.xmit	= dsa_slave_notag_xmit,
+	.rcv	= NULL,
+};
+
+const struct dsa_device_ops *dsa_device_ops[_DSA_TAG_LAST] = {
+#ifdef CONFIG_NET_DSA_TAG_DSA
+	[DSA_TAG_PROTO_DSA] = &dsa_netdev_ops,
+#endif
+#ifdef CONFIG_NET_DSA_TAG_EDSA
+	[DSA_TAG_PROTO_EDSA] = &edsa_netdev_ops,
+#endif
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+	[DSA_TAG_PROTO_TRAILER] = &trailer_netdev_ops,
+#endif
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+	[DSA_TAG_PROTO_BRCM] = &brcm_netdev_ops,
+#endif
+	[DSA_TAG_PROTO_NONE] = &none_ops,
+};
 
 /* switch driver registration ***********************************************/
 static DEFINE_MUTEX(dsa_switch_drivers_mutex);
@@ -225,6 +252,20 @@ static int dsa_cpu_dsa_setups(struct dsa_switch *ds, struct device *dev)
 	return 0;
 }
 
+const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
+{
+	const struct dsa_device_ops *ops;
+
+	if (tag_protocol >= _DSA_TAG_LAST)
+		return ERR_PTR(-EINVAL);
+	ops = dsa_device_ops[tag_protocol];
+
+	if (!ops)
+		return ERR_PTR(-ENOPROTOOPT);
+
+	return ops;
+}
+
 static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
 	struct dsa_switch_driver *drv = ds->drv;
@@ -277,35 +318,13 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * switch.
 	 */
 	if (dst->cpu_switch == index) {
-		switch (drv->tag_protocol) {
-#ifdef CONFIG_NET_DSA_TAG_DSA
-		case DSA_TAG_PROTO_DSA:
-			dst->rcv = dsa_netdev_ops.rcv;
-			break;
-#endif
-#ifdef CONFIG_NET_DSA_TAG_EDSA
-		case DSA_TAG_PROTO_EDSA:
-			dst->rcv = edsa_netdev_ops.rcv;
-			break;
-#endif
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
-		case DSA_TAG_PROTO_TRAILER:
-			dst->rcv = trailer_netdev_ops.rcv;
-			break;
-#endif
-#ifdef CONFIG_NET_DSA_TAG_BRCM
-		case DSA_TAG_PROTO_BRCM:
-			dst->rcv = brcm_netdev_ops.rcv;
-			break;
-#endif
-		case DSA_TAG_PROTO_NONE:
-			break;
-		default:
-			ret = -ENOPROTOOPT;
+		dst->tag_ops = dsa_resolve_tag_protocol(drv->tag_protocol);
+		if (IS_ERR(dst->tag_ops)) {
+			ret = PTR_ERR(dst->tag_ops);
 			goto out;
 		}
 
-		dst->tag_protocol = drv->tag_protocol;
+		dst->rcv = dst->tag_ops->rcv;
 	}
 
 	memcpy(ds->rtable, cd->rtable, sizeof(ds->rtable));
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index dbea5d9e7f75..72f7b8989cfb 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -53,6 +53,7 @@ extern char dsa_driver_version[];
 int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		      struct device_node *port_dn, int port);
 void dsa_cpu_dsa_destroy(struct device_node *port_dn);
+const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 52f1183c42a0..35e5f0f6688b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -521,14 +521,6 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static struct sk_buff *dsa_slave_notag_xmit(struct sk_buff *skb,
-					    struct net_device *dev)
-{
-	/* Just return the original SKB */
-	return skb;
-}
-
-
 /* ethtool operations *******************************************************/
 static int
 dsa_slave_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -1151,32 +1143,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p = netdev_priv(slave_dev);
 	p->parent = ds;
 	p->port = port;
-
-	switch (ds->dst->tag_protocol) {
-#ifdef CONFIG_NET_DSA_TAG_DSA
-	case DSA_TAG_PROTO_DSA:
-		p->xmit = dsa_netdev_ops.xmit;
-		break;
-#endif
-#ifdef CONFIG_NET_DSA_TAG_EDSA
-	case DSA_TAG_PROTO_EDSA:
-		p->xmit = edsa_netdev_ops.xmit;
-		break;
-#endif
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
-	case DSA_TAG_PROTO_TRAILER:
-		p->xmit = trailer_netdev_ops.xmit;
-		break;
-#endif
-#ifdef CONFIG_NET_DSA_TAG_BRCM
-	case DSA_TAG_PROTO_BRCM:
-		p->xmit = brcm_netdev_ops.xmit;
-		break;
-#endif
-	default:
-		p->xmit	= dsa_slave_notag_xmit;
-		break;
-	}
+	p->xmit = dst->tag_ops->xmit;
 
 	p->old_pause = -1;
 	p->old_link = -1;
-- 
2.8.1
