From: John Crispin <john@phrozen.org>
Subject: [PATCH 2/3] net-next: dsa: add Qualcomm tag RX/TX handler
Date: Mon, 12 Sep 2016 10:35:36 +0200
Message-ID: <1473669337-21221-3-git-send-email-john@phrozen.org>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473669337-21221-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the 2-bytes Qualcomm tag that gigabit switches such as
the QCA8337/N might insert when receiving packets, or that we need
to insert while targeting specific switch ports. The tag is inserted
directly behind the ethernet header.

Signed-off-by: John Crispin <john@phrozen.org>
---
 include/net/dsa.h  |    1 +
 net/dsa/Kconfig    |    3 +
 net/dsa/Makefile   |    1 +
 net/dsa/dsa.c      |    3 +
 net/dsa/dsa_priv.h |    2 +
 net/dsa/tag_qca.c  |  158 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 168 insertions(+)
 create mode 100644 net/dsa/tag_qca.c

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 9d97c52..7556646 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -26,6 +26,7 @@ enum dsa_tag_protocol {
 	DSA_TAG_PROTO_TRAILER,
 	DSA_TAG_PROTO_EDSA,
 	DSA_TAG_PROTO_BRCM,
+	DSA_TAG_PROTO_QCA,
 	DSA_TAG_LAST,		/* MUST BE LAST */
 };
 
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index ff7736f..96e47c5 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -38,4 +38,7 @@ config NET_DSA_TAG_EDSA
 config NET_DSA_TAG_TRAILER
 	bool
 
+config NET_DSA_TAG_QCA
+	bool
+
 endif
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 8af4ded..a3380ed 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -7,3 +7,4 @@ dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
 dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
+dsa_core-$(CONFIG_NET_DSA_TAG_QCA) += tag_qca.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d8d267e..66e31ac 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -54,6 +54,9 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
 #ifdef CONFIG_NET_DSA_TAG_BRCM
 	[DSA_TAG_PROTO_BRCM] = &brcm_netdev_ops,
 #endif
+#ifdef CONFIG_NET_DSA_TAG_QCA
+	[DSA_TAG_PROTO_QCA] = &qca_netdev_ops,
+#endif
 	[DSA_TAG_PROTO_NONE] = &none_ops,
 };
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 00077a9..6cfd738 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -81,5 +81,7 @@ extern const struct dsa_device_ops trailer_netdev_ops;
 /* tag_brcm.c */
 extern const struct dsa_device_ops brcm_netdev_ops;
 
+/* tag_qca.c */
+extern const struct dsa_device_ops qca_netdev_ops;
 
 #endif
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
new file mode 100644
index 0000000..8d75663
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
+static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
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
+	//skb->dev = p->parent->dst->master_netdev;
+	//dev_queue_xmit(skb);
+
+	return skb;
+
+out_free:
+	kfree_skb(skb);
+	return NULL;
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
+	if (unlikely(phy < 0) || !ds->ports[phy].netdev)
+		goto out_drop;
+
+	/* Update skb & forward the frame accordingly */
+	skb_push(skb, ETH_HLEN);
+	skb->pkt_type = PACKET_HOST;
+	skb->dev = ds->ports[phy].netdev;
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
1.7.10.4
