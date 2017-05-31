From: <Woojung.Huh@microchip.com>
Subject: [PATCH v5 net-next 1/5] dsa: add support for Microchip KSZ tail
 tagging
Date: Wed, 31 May 2017 20:19:06 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA5561@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <UNGLinuxDriver@microchip.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:42544 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdEaUTI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 16:19:08 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <Woojung.Huh@microchip.com>

Adding support for the Microchip KSZ switch family tail tagging.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
---
 include/net/dsa.h  |   1 +
 net/dsa/Kconfig    |   3 ++
 net/dsa/Makefile   |   1 +
 net/dsa/dsa.c      |   3 ++
 net/dsa/dsa_priv.h |   3 ++
 net/dsa/tag_ksz.c  | 101 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 112 insertions(+)
 create mode 100644 net/dsa/tag_ksz.c

diff --git a/include/net/dsa.h b/include/net/dsa.h
index d9bd693..7de1234 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -31,6 +31,7 @@ enum dsa_tag_protocol {
 	DSA_TAG_PROTO_BRCM,
 	DSA_TAG_PROTO_DSA,
 	DSA_TAG_PROTO_EDSA,
+	DSA_TAG_PROTO_KSZ,
 	DSA_TAG_PROTO_LAN9303,
 	DSA_TAG_PROTO_MTK,
 	DSA_TAG_PROTO_QCA,
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 297389b..cc5f8f9 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -25,6 +25,9 @@ config NET_DSA_TAG_DSA
 config NET_DSA_TAG_EDSA
 	bool
 
+config NET_DSA_TAG_KSZ
+	bool
+
 config NET_DSA_TAG_LAN9303
 	bool
 
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 90e5aa6..fcce25d 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -6,6 +6,7 @@ dsa_core-y += dsa.o dsa2.o legacy.o port.o slave.o switch.o
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
 dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
+dsa_core-$(CONFIG_NET_DSA_TAG_KSZ) += tag_ksz.o
 dsa_core-$(CONFIG_NET_DSA_TAG_LAN9303) += tag_lan9303.o
 dsa_core-$(CONFIG_NET_DSA_TAG_MTK) += tag_mtk.o
 dsa_core-$(CONFIG_NET_DSA_TAG_QCA) += tag_qca.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 3288a80..402459e 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -49,6 +49,9 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LAST] = {
 #ifdef CONFIG_NET_DSA_TAG_EDSA
 	[DSA_TAG_PROTO_EDSA] = &edsa_netdev_ops,
 #endif
+#ifdef CONFIG_NET_DSA_TAG_KSZ
+	[DSA_TAG_PROTO_KSZ] = &ksz_netdev_ops,
+#endif
 #ifdef CONFIG_NET_DSA_TAG_LAN9303
 	[DSA_TAG_PROTO_LAN9303] = &lan9303_netdev_ops,
 #endif
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c1d4180..7459d57 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -167,6 +167,9 @@ extern const struct dsa_device_ops dsa_netdev_ops;
 /* tag_edsa.c */
 extern const struct dsa_device_ops edsa_netdev_ops;
 
+/* tag_ksz.c */
+extern const struct dsa_device_ops ksz_netdev_ops;
+
 /* tag_lan9303.c */
 extern const struct dsa_device_ops lan9303_netdev_ops;
 
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
new file mode 100644
index 0000000..0b08a40
--- /dev/null
+++ b/net/dsa/tag_ksz.c
@@ -0,0 +1,101 @@
+/*
+ * net/dsa/tag_ksz.c - Microchip KSZ Switch tag format handling
+ * Copyright (c) 2017 Microchip Technology
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <net/dsa.h>
+#include "dsa_priv.h"
+
+/* For Ingress (Host -> KSZ), 2 bytes are added before FCS.
+ * ---------------------------------------------------------------------------
+ * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|tag1(1byte)|FCS(4bytes)
+ * ---------------------------------------------------------------------------
+ * tag0 : Prioritization (not used now)
+ * tag1 : each bit represents port (eg, 0x01=port1, 0x02=port2, 0x10=port5)
+ *
+ * For Egress (KSZ -> Host), 1 byte is added before FCS.
+ * ---------------------------------------------------------------------------
+ * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|FCS(4bytes)
+ * ---------------------------------------------------------------------------
+ * tag0 : zero-based value represents port
+ *	  (eg, 0x00=port1, 0x02=port3, 0x06=port7)
+ */
+
+#define	KSZ_INGRESS_TAG_LEN	2
+#define	KSZ_EGRESS_TAG_LEN	1
+
+static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct sk_buff *nskb;
+	int padlen;
+	u8 *tag;
+
+	padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
+
+	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
+		nskb = skb;
+	} else {
+		nskb = alloc_skb(NET_IP_ALIGN + skb->len +
+				 padlen + KSZ_INGRESS_TAG_LEN, GFP_ATOMIC);
+		if (!nskb) {
+			kfree_skb(skb);
+			return NULL;
+		}
+		skb_reserve(nskb, NET_IP_ALIGN);
+
+		skb_reset_mac_header(nskb);
+		skb_set_network_header(nskb,
+				       skb_network_header(skb) - skb->head);
+		skb_set_transport_header(nskb,
+					 skb_transport_header(skb) - skb->head);
+		skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
+		kfree_skb(skb);
+	}
+
+	/* skb is freed when it fails */
+	if (skb_put_padto(nskb, nskb->len + padlen))
+		return NULL;
+
+	tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
+	tag[0] = 0;
+	tag[1] = 1 << p->dp->index; /* destination port */
+
+	return nskb;
+}
+
+struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
+			struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds;
+	u8 *tag;
+	int source_port;
+
+	ds = dst->cpu_dp->ds;
+
+	tag = skb_tail_pointer(skb) - KSZ_EGRESS_TAG_LEN;
+
+	source_port = tag[0] & 7;
+	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
+		return NULL;
+
+	pskb_trim_rcsum(skb, skb->len - KSZ_EGRESS_TAG_LEN);
+
+	skb->dev = ds->ports[source_port].netdev;
+
+	return skb;
+}
+
+const struct dsa_device_ops ksz_netdev_ops = {
+	.xmit	= ksz_xmit,
+	.rcv	= ksz_rcv,
+};
-- 
2.7.4
