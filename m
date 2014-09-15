From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 1/2] dsa: Split ops up,
 and avoid assigning tag_protocol and receive separately
Date: Mon, 15 Sep 2014 13:00:19 -0400
Message-ID: <20140915165921.1261.9679.stgit@ahduyck-bv4.jf.intel.com>
References: <20140915165543.1261.2520.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, kernel@wantstofly.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26094 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190AbaIORJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 13:09:51 -0400
In-Reply-To: <20140915165543.1261.2520.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change addresses several issues.

First, it was possible to set tag_protocol without setting the ops pointer.
To correct that I have reordered things so that rcv is now populated before
we set tag_protocol.

Second, it didn't make much sense to keep setting the device ops each time a
new slave was registered.  So by moving the receive portion out into root
switch initialization that issue should be addressed.

Third, I wanted to avoid sending tags if the rcv pointer was not registered
so I changed the tag check to verify if the rcv function pointer is set on
the root tree.  If it is then we start sending DSA tagged frames.

Finally I split the device ops pointer in the structures into two spots.  I
placed the rcv function pointer in the root switch since this makes it
easiest to access from there, and I placed the xmit function pointer in the
slave for the same reason.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/netdevice.h |    7 -------
 include/net/dsa.h         |   10 ++++++----
 net/dsa/dsa.c             |   32 ++++++++++++++++++++++++++++----
 net/dsa/dsa_priv.h        |   11 ++++++++++-
 net/dsa/slave.c           |   37 +++++++++++++++----------------------
 net/dsa/tag_brcm.c        |    1 -
 net/dsa/tag_dsa.c         |    1 -
 net/dsa/tag_edsa.c        |    1 -
 net/dsa/tag_trailer.c     |    1 -
 9 files changed, 59 insertions(+), 42 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f9e81d1..28d4378 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1928,13 +1928,6 @@ struct udp_offload {
 	struct offload_callbacks callbacks;
 };
 
-struct dsa_device_ops {
-	netdev_tx_t (*xmit)(struct sk_buff *skb, struct net_device *dev);
-	int (*rcv)(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev);
-};
-
-
 /* often modified stats are per cpu, other are shared (netdev->stats) */
 struct pcpu_sw_netstats {
 	u64     rx_packets;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8a8a5d9..a55c4e6 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -77,7 +77,7 @@ struct dsa_platform_data {
 	struct dsa_chip_data	*chip;
 };
 
-struct dsa_device_ops;
+struct packet_type;
 
 struct dsa_switch_tree {
 	/*
@@ -91,7 +91,10 @@ struct dsa_switch_tree {
 	 * protocol to use.
 	 */
 	struct net_device	*master_netdev;
-	const struct dsa_device_ops	*ops;
+	int			(*rcv)(struct sk_buff *skb,
+				       struct net_device *dev,
+				       struct packet_type *pt,
+				       struct net_device *orig_dev);
 	enum dsa_tag_protocol	tag_protocol;
 
 	/*
@@ -218,7 +221,6 @@ static inline void *ds_to_priv(struct dsa_switch *ds)
 
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
-	return dst->tag_protocol != DSA_TAG_PROTO_NONE;
+	return dst->rcv != NULL;
 }
-
 #endif
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 61f145c..1df0a7c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -10,7 +10,6 @@
  */
 
 #include <linux/list.h>
-#include <linux/netdevice.h>
 #include <linux/platform_device.h>
 #include <linux/slab.h>
 #include <linux/module.h>
@@ -154,9 +153,34 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	 * tagging protocol to the preferred tagging format of this
 	 * switch.
 	 */
-	if (ds->dst->cpu_switch == index)
-		ds->dst->tag_protocol = drv->tag_protocol;
+	if (dst->cpu_switch == index) {
+		switch (drv->tag_protocol) {
+#ifdef CONFIG_NET_DSA_TAG_DSA
+		case DSA_TAG_PROTO_DSA:
+			dst->rcv = dsa_netdev_ops.rcv;
+			break;
+#endif
+#ifdef CONFIG_NET_DSA_TAG_EDSA
+		case DSA_TAG_PROTO_EDSA:
+			dst->rcv = edsa_netdev_ops.rcv;
+			break;
+#endif
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+		case DSA_TAG_PROTO_TRAILER:
+			dst->rcv = trailer_netdev_ops.rcv;
+			break;
+#endif
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+		case DSA_TAG_PROTO_BRCM:
+			dst->rcv = brcm_netdev_ops.rcv;
+			break;
+#endif
+		default:
+			break;
+		}
 
+		dst->tag_protocol = drv->tag_protocol;
+	}
 
 	/*
 	 * Do basic register setup.
@@ -626,7 +650,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
-	return dst->ops->rcv(skb, dev, pt, orig_dev);
+	return dst->rcv(skb, dev, pt, orig_dev);
 }
 
 static struct packet_type dsa_pack_type __read_mostly = {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 98afed4..f90899e 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -12,7 +12,13 @@
 #define __DSA_PRIV_H
 
 #include <linux/phy.h>
-#include <net/dsa.h>
+#include <linux/netdevice.h>
+
+struct dsa_device_ops {
+	netdev_tx_t (*xmit)(struct sk_buff *skb, struct net_device *dev);
+	int (*rcv)(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pt, struct net_device *orig_dev);
+};
 
 struct dsa_slave_priv {
 	/*
@@ -20,6 +26,8 @@ struct dsa_slave_priv {
 	 * switch port.
 	 */
 	struct net_device	*dev;
+	netdev_tx_t		(*xmit)(struct sk_buff *skb,
+					struct net_device *dev);
 
 	/*
 	 * Which switch this port is a part of, and the port index
@@ -43,6 +51,7 @@ struct dsa_slave_priv {
 extern char dsa_driver_version[];
 
 /* slave.c */
+extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
 struct net_device *dsa_slave_create(struct dsa_switch *ds,
 				    struct device *parent,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 809eeb1..e38a331 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -9,7 +9,6 @@
  */
 
 #include <linux/list.h>
-#include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/phy.h>
 #include <linux/of_net.h>
@@ -176,9 +175,8 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch_tree *dst = p->parent->dst;
 
-	return dst->ops->xmit(skb, dev);
+	return p->xmit(skb, dev);
 }
 
 static netdev_tx_t dsa_slave_notag_xmit(struct sk_buff *skb,
@@ -325,11 +323,6 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
 
-static const struct dsa_device_ops notag_netdev_ops = {
-	.xmit	= dsa_slave_notag_xmit,
-	.rcv	= NULL,
-};
-
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -435,41 +428,41 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->tx_queue_len = 0;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
 
+	SET_NETDEV_DEV(slave_dev, parent);
+	slave_dev->dev.of_node = ds->pd->port_dn[port];
+	slave_dev->vlan_features = master->vlan_features;
+
+	p = netdev_priv(slave_dev);
+	p->dev = slave_dev;
+	p->parent = ds;
+	p->port = port;
+
 	switch (ds->dst->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
 	case DSA_TAG_PROTO_DSA:
-		ds->dst->ops = &dsa_netdev_ops;
+		p->xmit = dsa_netdev_ops.xmit;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_EDSA
 	case DSA_TAG_PROTO_EDSA:
-		ds->dst->ops = &edsa_netdev_ops;
+		p->xmit = edsa_netdev_ops.xmit;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
 	case DSA_TAG_PROTO_TRAILER:
-		ds->dst->ops = &trailer_netdev_ops;
+		p->xmit = trailer_netdev_ops.xmit;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_BRCM
 	case DSA_TAG_PROTO_BRCM:
-		ds->dst->ops = &brcm_netdev_ops;
+		p->xmit = brcm_netdev_ops.xmit;
 		break;
 #endif
 	default:
-		ds->dst->ops = &notag_netdev_ops;
+		p->xmit	= dsa_slave_notag_xmit;
 		break;
 	}
 
-	SET_NETDEV_DEV(slave_dev, parent);
-	slave_dev->dev.of_node = ds->pd->port_dn[port];
-	slave_dev->vlan_features = master->vlan_features;
-
-	p = netdev_priv(slave_dev);
-	p->dev = slave_dev;
-	p->parent = ds;
-	p->port = port;
-
 	p->old_pause = -1;
 	p->old_link = -1;
 	p->old_duplex = -1;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 8fbc21c..83d3572 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -11,7 +11,6 @@
 
 #include <linux/etherdevice.h>
 #include <linux/list.h>
-#include <linux/netdevice.h>
 #include <linux/slab.h>
 #include "dsa_priv.h"
 
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index d7dbc5b..ce90c8b 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -10,7 +10,6 @@
 
 #include <linux/etherdevice.h>
 #include <linux/list.h>
-#include <linux/netdevice.h>
 #include <linux/slab.h>
 #include "dsa_priv.h"
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 6b30abe..94fcce7 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -10,7 +10,6 @@
 
 #include <linux/etherdevice.h>
 #include <linux/list.h>
-#include <linux/netdevice.h>
 #include <linux/slab.h>
 #include "dsa_priv.h"
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 5fe9444..115fdca 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -10,7 +10,6 @@
 
 #include <linux/etherdevice.h>
 #include <linux/list.h>
-#include <linux/netdevice.h>
 #include <linux/slab.h>
 #include "dsa_priv.h"
 
