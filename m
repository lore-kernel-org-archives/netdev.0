From: Juergen Borleis <jbe@pengutronix.de>
Subject: [PATCH v3 1/4] net: dsa: add support for the SMSC-LAN9303 tagging format
Date: Tue, 11 Apr 2017 09:22:56 +0200
Message-ID: <20170411072259.15356-2-jbe@pengutronix.de>
References: <20170411072259.15356-1-jbe@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
        kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170411072259.15356-1-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To define the outgoing port and to discover the incoming port a regular
VLAN tag is used by the LAN9303. But its VID meaning is 'special'.

This tag handler/filter depends on some hardware features which must be
enabled in the device to provide and make use of this special VLAN tag
to control the destination and the source of an ethernet packet.

Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
---
 include/net/dsa.h     |   1 +
 net/dsa/Kconfig       |   3 +
 net/dsa/Makefile      |   1 +
 net/dsa/dsa.c         |   3 +
 net/dsa/dsa_priv.h    |   3 +
 net/dsa/tag_lan9303.c | 158 ++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 169 insertions(+)
 create mode 100644 net/dsa/tag_lan9303.c

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4e13e695f0251..4fb1f2b086b05 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -31,6 +31,7 @@ enum dsa_tag_protocol {
 	DSA_TAG_PROTO_EDSA,
 	DSA_TAG_PROTO_BRCM,
 	DSA_TAG_PROTO_QCA,
+	DSA_TAG_PROTO_LAN9303,
 	DSA_TAG_LAST,		/* MUST BE LAST */
 };
 
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 9649238eef404..22c8bd69ff71c 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -31,4 +31,7 @@ config NET_DSA_TAG_TRAILER
 config NET_DSA_TAG_QCA
 	bool
 
+config NET_DSA_TAG_LAN9303
+	bool
+
 endif
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 31d343796251d..aafc74f2cb193 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -8,3 +8,4 @@ dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
 dsa_core-$(CONFIG_NET_DSA_TAG_QCA) += tag_qca.o
+dsa_core-$(CONFIG_NET_DSA_TAG_LAN9303) += tag_lan9303.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b6d4f6a23f06c..f93f78de23af3 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -53,6 +53,9 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
 #ifdef CONFIG_NET_DSA_TAG_QCA
 	[DSA_TAG_PROTO_QCA] = &qca_netdev_ops,
 #endif
+#ifdef CONFIG_NET_DSA_TAG_LAN9303
+	[DSA_TAG_PROTO_LAN9303] = &lan9303_netdev_ops,
+#endif
 	[DSA_TAG_PROTO_NONE] = &none_ops,
 };
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 0706a511244e9..a54cfc8aefa83 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -85,4 +85,7 @@ extern const struct dsa_device_ops brcm_netdev_ops;
 /* tag_qca.c */
 extern const struct dsa_device_ops qca_netdev_ops;
 
+/* tag_lan9303.c */
+extern const struct dsa_device_ops lan9303_netdev_ops;
+
 #endif
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
new file mode 100644
index 0000000000000..aa979bbb9f399
--- /dev/null
+++ b/net/dsa/tag_lan9303.c
@@ -0,0 +1,158 @@
+/*
+ * Copyright (C) 2017 Pengutronix, Juergen Borleis <jbe@pengutronix.de>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+#include <linux/etherdevice.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include "dsa_priv.h"
+
+/* To define the outgoing port and to discover the incoming port a regular
+ * VLAN tag is used by the LAN9303. But its VID meaning is 'special':
+ *
+ *       Dest MAC       Src MAC        TAG    Type
+ * ...| 1 2 3 4 5 6 | 1 2 3 4 5 6 | 1 2 3 4 | 1 2 |...
+ *                                |<------->|
+ * TAG:
+ *    |<------------->|
+ *    |  1  2 | 3  4  |
+ *      TPID    VID
+ *     0x8100
+ *
+ * VID bit 3 indicates a request for an ALR lookup.
+ *
+ * If VID bit 3 is zero, then bits 0 and 1 specify the destination port
+ * (0, 1, 2) or broadcast (3) or the source port (1, 2).
+ *
+ * VID bit 4 is used to specify if the STP port state should be overridden.
+ * Required when no forwarding between the external ports should happen.
+ */
+
+#define LAN9303_TAG_LEN 4
+#define LAN9303_MAX_PORTS 3
+
+static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	u16 *lan9303_tag;
+
+	/* insert a special VLAN tag between the MAC addresses
+	 * and the current ethertype field.
+	 */
+	if (skb_cow_head(skb, LAN9303_TAG_LEN) < 0) {
+		dev_dbg(&dev->dev,
+			"Cannot make room for the special tag. Dropping packet\n");
+		goto out_free;
+	}
+
+	/* provide 'LAN9303_TAG_LEN' bytes additional space */
+	skb_push(skb, LAN9303_TAG_LEN);
+
+	/* make room between MACs and Ether-Type */
+	memmove(skb->data, skb->data + LAN9303_TAG_LEN, 2 * ETH_ALEN);
+
+	lan9303_tag = (u16 *)(skb->data + 2 * ETH_ALEN);
+	lan9303_tag[0] = htons(ETH_P_8021Q);
+	lan9303_tag[1] = htons(p->dp->index | BIT(4));
+
+	return skb;
+out_free:
+	kfree_skb(skb);
+	return NULL;
+}
+
+static int lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
+		       struct packet_type *pt, struct net_device *orig_dev)
+{
+	u16 *lan9303_tag;
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds;
+	unsigned int source_port;
+
+	if (unlikely(!dst)) {
+		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing switch tree device\n");
+		goto out_drop;
+	}
+
+	ds = dst->ds[0];
+
+	if (unlikely(!ds)) {
+		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing DSA switch device\n");
+		goto out_drop;
+	}
+
+	skb = skb_unshare(skb, GFP_ATOMIC);
+	if (!skb) {
+		dev_warn_ratelimited(&dev->dev, "Cannot post-process skb: unshareable\n");
+		goto out;
+	}
+
+	if (unlikely(!pskb_may_pull(skb, 2 + 2))) {
+		dev_warn_ratelimited(&dev->dev,
+				     "Dropping packet, cannot pull\n");
+		goto out_drop;
+	}
+
+	/* '->data' points into the middle of our special VLAN tag information:
+	 *
+	 * ~ MAC src   | 0x81 | 0x00 | 0xyy | 0xzz | ether type
+	 *                           ^
+	 *                        ->data
+	 */
+	lan9303_tag = (u16 *)(skb->data - 2);
+
+	if (lan9303_tag[0] != htons(ETH_P_8021Q)) {
+		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid VLAN marker\n");
+		goto out_drop;
+	}
+
+	source_port = ntohs(lan9303_tag[1]) & 0x3;
+
+	if (source_port >= LAN9303_MAX_PORTS) {
+		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid source port\n");
+		goto out_drop;
+	}
+
+	if (!ds->ports[source_port].netdev) {
+		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid netdev or device\n");
+		goto out_drop;
+	}
+
+	/* remove the special VLAN tag between the MAC addresses
+	 * and the current ethertype field.
+	 */
+	skb_pull_rcsum(skb, 2 + 2);
+	memmove(skb->data - ETH_HLEN, skb->data - (ETH_HLEN + LAN9303_TAG_LEN),
+		2 * ETH_ALEN);
+
+	/* Update skb & forward the packet to the dedicated interface */
+	skb_push(skb, ETH_HLEN);
+	skb->dev = ds->ports[source_port].netdev;
+	skb->pkt_type = PACKET_HOST;
+	skb->protocol = eth_type_trans(skb, skb->dev);
+
+	skb->dev->stats.rx_packets++;
+	skb->dev->stats.rx_bytes += skb->len;
+
+	netif_receive_skb(skb);
+
+	return 0;
+out_drop:
+	kfree_skb(skb);
+out:
+	return 0;
+}
+
+const struct dsa_device_ops lan9303_netdev_ops = {
+	.xmit = lan9303_xmit,
+	.rcv = lan9303_rcv,
+};
-- 
2.11.0
