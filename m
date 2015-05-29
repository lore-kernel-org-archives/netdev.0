From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH 4/7] net: dsa: add QCA tag support
Date: Thu, 28 May 2015 18:42:19 -0700
Message-ID: <1432863742-18427-5-git-send-email-mathieu@codeaurora.org>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, mathieu@codeaurora.org, andrew@lunn.ch,
	f.fainelli@gmail.com, linux@roeck-us.net, gang.chen.5i5j@gmail.com,
	jiri@resnulli.us, leitec@staticky.com, fabf@skynet.be,
	alexander.h.duyck@intel.com, pavel.nakonechny@skitlab.ru,
	joe@perches.com, sfeldma@gmail.com, nbd@openwrt.org,
	juhosg@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QCA tags are used on QCA ar8xxx switch family. This change adds support
for encap/decap using 2 bytes header mode.

Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 include/net/dsa.h  |   1 +
 net/dsa/Kconfig    |   3 +
 net/dsa/Makefile   |   1 +
 net/dsa/dsa.c      |   5 ++
 net/dsa/dsa_priv.h |   2 +
 net/dsa/slave.c    |   5 ++
 net/dsa/tag_qca.c  | 158 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 175 insertions(+)
 create mode 100644 net/dsa/tag_qca.c

diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63b..64ddf6f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -26,6 +26,7 @@ enum dsa_tag_protocol {
 	DSA_TAG_PROTO_TRAILER,
 	DSA_TAG_PROTO_EDSA,
 	DSA_TAG_PROTO_BRCM,
+	DSA_TAG_PROTO_QCA,
 };
 
 #define DSA_MAX_SWITCHES	4
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index ff7736f..4f3cce1 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -26,6 +26,9 @@ config NET_DSA_HWMON
 	  via the hwmon sysfs interface and exposes the onboard sensors.
 
 # tagging formats
+config NET_DSA_TAG_QCA
+	bool
+
 config NET_DSA_TAG_BRCM
 	bool
 
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index da06ed1..9feb86c 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -3,6 +3,7 @@ obj-$(CONFIG_NET_DSA) += dsa_core.o
 dsa_core-y += dsa.o slave.o
 
 # tagging formats
+dsa_core-$(CONFIG_NET_DSA_TAG_QCA) += tag_qca.o
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
 dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index fffb9aa..6010a7d 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -249,6 +249,11 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			dst->rcv = brcm_netdev_ops.rcv;
 			break;
 #endif
+#ifdef CONFIG_NET_DSA_TAG_QCA
+		case DSA_TAG_PROTO_QCA:
+			dst->rcv = qca_netdev_ops.rcv;
+			break;
+#endif
 		case DSA_TAG_PROTO_NONE:
 			break;
 		default:
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d5f1f9b..350c94b 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -74,5 +74,7 @@ extern const struct dsa_device_ops trailer_netdev_ops;
 /* tag_brcm.c */
 extern const struct dsa_device_ops brcm_netdev_ops;
 
+/* tag_qca.c */
+extern const struct dsa_device_ops qca_netdev_ops;
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 04ffad3..cd8f552 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -925,6 +925,11 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		p->xmit = brcm_netdev_ops.xmit;
 		break;
 #endif
+#ifdef CONFIG_NET_DSA_TAG_QCA
+	case DSA_TAG_PROTO_QCA:
+		p->xmit = qca_netdev_ops.xmit;
+		break;
+#endif
 	default:
 		p->xmit	= dsa_slave_notag_xmit;
 		break;
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
new file mode 100644
index 0000000..8f02196
--- /dev/null
+++ b/net/dsa/tag_qca.c
@@ -0,0 +1,158 @@
+/*
+ * Copyright (c) 2015, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/etherdevice.h>
+#include "dsa_priv.h"
+
+#define QCA_HDR_LEN	2
+#define QCA_HDR_VERSION	0x2
+
+#define QCA_HDR_RECV_VERSION_MASK	GENMASK(15, 14)
+#define QCA_HDR_RECV_VERSION_S		14
+#define QCA_HDR_RECV_PRIORITY_MASK	GENMASK(13, 11)
+#define QCA_HDR_RECV_PRIORITY_S		11
+#define QCA_HDR_RECV_TYPE_MASK		GENMASK(10, 6)
+#define QCA_HDR_RECV_TYPE_S		6
+#define QCA_HDR_RECV_FRAME_IS_TAGGED	BIT(3)
+#define QCA_HDR_RECV_SOURCE_PORT_MASK	GENMASK(2, 0)
+
+#define QCA_HDR_XMIT_VERSION_MASK	GENMASK(15, 14)
+#define QCA_HDR_XMIT_VERSION_S		14
+#define QCA_HDR_XMIT_PRIORITY_MASK	GENMASK(13, 11)
+#define QCA_HDR_XMIT_PRIORITY_S		11
+#define QCA_HDR_XMIT_CONTROL_MASK	GENMASK(10, 8)
+#define QCA_HDR_XMIT_CONTROL_S		8
+#define QCA_HDR_XMIT_FROM_CPU		BIT(7)
+#define QCA_HDR_XMIT_DP_BIT_MASK	GENMASK(6, 0)
+
+static inline int reg_to_port(int reg)
+{
+	if (reg < 5)
+		return reg + 1;
+
+	return -1;
+}
+
+static inline int port_to_reg(int port)
+{
+	if (port >= 1 && port <= 6)
+		return port - 1;
+
+	return -1;
+}
+
+static netdev_tx_t qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	u16 *phdr, hdr;
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	if (skb_cow_head(skb, 0) < 0)
+		goto out_free;
+
+	skb_push(skb, QCA_HDR_LEN);
+
+	memmove(skb->data, skb->data + QCA_HDR_LEN, 2 * ETH_ALEN);
+	phdr = (u16 *)(skb->data + 2 * ETH_ALEN);
+
+	/* Set the version field, and set destination port information */
+	hdr = QCA_HDR_VERSION << QCA_HDR_XMIT_VERSION_S |
+		QCA_HDR_XMIT_FROM_CPU |
+		1 << reg_to_port(p->port);
+
+	*phdr = htons(hdr);
+
+	skb->dev = p->parent->dst->master_netdev;
+	dev_queue_xmit(skb);
+
+	return NETDEV_TX_OK;
+
+out_free:
+	kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static int qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
+		       struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds;
+	u8 ver;
+	int port, phy;
+	__be16 *phdr, hdr;
+
+	if (unlikely(!dst))
+		goto out_drop;
+
+	skb = skb_unshare(skb, GFP_ATOMIC);
+	if (!skb)
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, QCA_HDR_LEN)))
+		goto out_drop;
+
+	/* Ethernet is added by the switch between src addr and Ethertype
+	 * At this point, skb->data points to ethertype so header should be
+	 * right before
+	 */
+	phdr = (__be16 *)(skb->data - 2);
+	hdr = ntohs(*phdr);
+
+	/* Make sure the version is correct */
+	ver = (hdr & QCA_HDR_RECV_VERSION_MASK) >> QCA_HDR_RECV_VERSION_S;
+	if (unlikely(ver != QCA_HDR_VERSION))
+		goto out_drop;
+
+	/* Remove QCA tag and recalculate checksum */
+	skb_pull_rcsum(skb, QCA_HDR_LEN);
+	memmove(skb->data - ETH_HLEN, skb->data - ETH_HLEN - QCA_HDR_LEN,
+		ETH_HLEN - QCA_HDR_LEN);
+
+	/* This protocol doesn't support cascading multiple switches so it's
+	 * safe to assume the switch is first in the tree
+	 */
+	ds = dst->ds[0];
+	if (!ds)
+		goto out_drop;
+
+	/* Get source port information */
+	port = (hdr & QCA_HDR_RECV_SOURCE_PORT_MASK);
+	phy = port_to_reg(port);
+	if (unlikely(phy < 0) || !ds->ports[phy])
+		goto out_drop;
+
+	/* Update skb & forward the frame accordingly */
+	skb_push(skb, ETH_HLEN);
+	skb->pkt_type = PACKET_HOST;
+	skb->dev = ds->ports[phy];
+	skb->protocol = eth_type_trans(skb, skb->dev);
+
+	skb->dev->stats.rx_packets++;
+	skb->dev->stats.rx_bytes += skb->len;
+
+	netif_receive_skb(skb);
+
+	return 0;
+
+out_drop:
+	kfree_skb(skb);
+out:
+	return 0;
+}
+
+const struct dsa_device_ops qca_netdev_ops = {
+	.xmit	= qca_tag_xmit,
+	.rcv	= qca_tag_rcv,
+};
-- 
2.1.4
