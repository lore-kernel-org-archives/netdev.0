From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 10/13] net: dsa: add Broadcom tag RX/TX handler
Date: Wed, 27 Aug 2014 17:04:55 -0700
Message-ID: <1409184298-1793-11-git-send-email-f.fainelli@gmail.com>
References: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:46810 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965645AbaH1AGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 20:06:13 -0400
Received: by mail-pa0-f49.google.com with SMTP id kq14so113309pab.8
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 17:06:13 -0700 (PDT)
In-Reply-To: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the 4-bytes Broadcom tag that built-in switches such as
the Starfighter 2 might insert when receiving packets, or that we need
to insert while targetting specific switch ports. We use a fake local
EtherType value for this 4-bytes switch tag: ETH_P_BRCMTAG to make sure
we can assign DSA-specific network operations within the DSA drivers.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v5:
- make ETH_P_BRCMTAG local to the DSA code, it does not need to be exported
  to user-space

Changes in v4:
- reworked changes to match the new dsa_device_ops introduced in patch 1

Changes in v3:
- add ETH_P_BRCMTAG as part of this changeset and not in a previous patch
- fixed an early de-reference in the receive hook

 include/net/dsa.h  |   5 ++
 net/dsa/Kconfig    |   3 +
 net/dsa/Makefile   |   1 +
 net/dsa/dsa_priv.h |   3 +
 net/dsa/slave.c    |   5 ++
 net/dsa/tag_brcm.c | 173 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 190 insertions(+)
 create mode 100644 net/dsa/tag_brcm.c

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2c9563f0b2f4..97712927a9d2 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -19,6 +19,11 @@
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 
+/* Not an official ethertype value, used only internally for DSA
+ * demultiplexing
+ */
+#define ETH_P_BRCMTAG		(ETH_P_XDSA + 1)
+
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
 
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index f5eede1d6cb8..a585fd6352eb 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -12,6 +12,9 @@ config NET_DSA
 if NET_DSA
 
 # tagging formats
+config NET_DSA_TAG_BRCM
+	bool
+
 config NET_DSA_TAG_DSA
 	bool
 
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 7b9fcbbeda5d..da06ed1df620 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -3,6 +3,7 @@ obj-$(CONFIG_NET_DSA) += dsa_core.o
 dsa_core-y += dsa.o slave.o
 
 # tagging formats
+dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
 dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d20364ac1574..98afed4d92ba 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -57,5 +57,8 @@ extern const struct dsa_device_ops edsa_netdev_ops;
 /* tag_trailer.c */
 extern const struct dsa_device_ops trailer_netdev_ops;
 
+/* tag_brcm.c */
+extern const struct dsa_device_ops brcm_netdev_ops;
+
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 18ff53836fe3..7333a4aebb7d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -451,6 +451,11 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		ds->dst->ops = &trailer_netdev_ops;
 		break;
 #endif
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+	case htons(ETH_P_BRCMTAG):
+		ds->dst->ops = &brcm_netdev_ops;
+		break;
+#endif
 	default:
 		ds->dst->ops = &notag_netdev_ops;
 		break;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
new file mode 100644
index 000000000000..e0b759ec209e
--- /dev/null
+++ b/net/dsa/tag_brcm.c
@@ -0,0 +1,173 @@
+/*
+ * Broadcom tag support
+ *
+ * Copyright (C) 2014 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/slab.h>
+#include "dsa_priv.h"
+
+/* This tag length is 4 bytes, older ones were 6 bytes, we do not
+ * handle them
+ */
+#define BRCM_TAG_LEN	4
+
+/* Tag is constructed and desconstructed using byte by byte access
+ * because the tag is placed after the MAC Source Address, which does
+ * not make it 4-bytes aligned, so this might cause unaligned accesses
+ * on most systems where this is used.
+ */
+
+/* Ingress and egress opcodes */
+#define BRCM_OPCODE_SHIFT	5
+#define BRCM_OPCODE_MASK	0x7
+
+/* Ingress fields */
+/* 1st byte in the tag */
+#define BRCM_IG_TC_SHIFT	2
+#define BRCM_IG_TC_MASK		0x7
+/* 2nd byte in the tag */
+#define BRCM_IG_TE_MASK		0x3
+#define BRCM_IG_TS_SHIFT	7
+/* 3rd byte in the tag */
+#define BRCM_IG_DSTMAP2_MASK	1
+#define BRCM_IG_DSTMAP1_MASK	0xff
+
+/* Egress fields */
+
+/* 2nd byte in the tag */
+#define BRCM_EG_CID_MASK	0xff
+
+/* 3rd byte in the tag */
+#define BRCM_EG_RC_MASK		0xff
+#define  BRCM_EG_RC_RSVD	(3 << 6)
+#define  BRCM_EG_RC_EXCEPTION	(1 << 5)
+#define  BRCM_EG_RC_PROT_SNOOP	(1 << 4)
+#define  BRCM_EG_RC_PROT_TERM	(1 << 3)
+#define  BRCM_EG_RC_SWITCH	(1 << 2)
+#define  BRCM_EG_RC_MAC_LEARN	(1 << 1)
+#define  BRCM_EG_RC_MIRROR	(1 << 0)
+#define BRCM_EG_TC_SHIFT	5
+#define BRCM_EG_TC_MASK		0x7
+#define BRCM_EG_PID_MASK	0x1f
+
+static netdev_tx_t brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	u8 *brcm_tag;
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	if (skb_cow_head(skb, BRCM_TAG_LEN) < 0)
+		goto out_free;
+
+	skb_push(skb, BRCM_TAG_LEN);
+
+	memmove(skb->data, skb->data + BRCM_TAG_LEN, 2 * ETH_ALEN);
+
+	/* Build the tag after the MAC Source Address */
+	brcm_tag = skb->data + 2 * ETH_ALEN;
+
+	/* Set the ingress opcode, traffic class, tag enforcment is
+	 * deprecated
+	 */
+	brcm_tag[0] = (1 << BRCM_OPCODE_SHIFT) |
+			((skb->priority << BRCM_IG_TC_SHIFT) & BRCM_IG_TC_MASK);
+	brcm_tag[1] = 0;
+	brcm_tag[2] = 0;
+	if (p->port == 8)
+		brcm_tag[2] = BRCM_IG_DSTMAP2_MASK;
+	brcm_tag[3] = (1 << p->port) & BRCM_IG_DSTMAP1_MASK;
+
+	/* Queue the SKB for transmission on the parent interface, but
+	 * do not modify its EtherType
+	 */
+	skb->protocol = htons(ETH_P_BRCMTAG);
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
+static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
+			struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds;
+	int source_port;
+	u8 *brcm_tag;
+
+	if (unlikely(dst == NULL))
+		goto out_drop;
+
+	ds = dst->ds[0];
+
+	skb = skb_unshare(skb, GFP_ATOMIC);
+	if (skb == NULL)
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, BRCM_TAG_LEN)))
+		goto out_drop;
+
+	/* skb->data points to the EtherType, the tag is right before it */
+	brcm_tag = skb->data - 2;
+
+	/* The opcode should never be different than 0b000 */
+	if (unlikely((brcm_tag[0] >> BRCM_OPCODE_SHIFT) & BRCM_OPCODE_MASK))
+		goto out_drop;
+
+	/* We should never see a reserved reason code without knowing how to
+	 * handle it
+	 */
+	WARN_ON(brcm_tag[2] & BRCM_EG_RC_RSVD);
+
+	/* Locate which port this is coming from */
+	source_port = brcm_tag[3] & BRCM_EG_PID_MASK;
+
+	/* Validate port against switch setup, either the port is totally */
+	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+		goto out_drop;
+
+	/* Remove Broadcom tag and update checksum */
+	skb_pull_rcsum(skb, BRCM_TAG_LEN);
+
+	/* Move the Ethernet DA and SA */
+	memmove(skb->data - ETH_HLEN,
+		skb->data - ETH_HLEN - BRCM_TAG_LEN,
+		2 * ETH_ALEN);
+
+	skb_push(skb, ETH_HLEN);
+	skb->pkt_type = PACKET_HOST;
+	skb->dev = ds->ports[source_port];
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
+const struct dsa_device_ops brcm_netdev_ops = {
+	.xmit	= brcm_tag_xmit,
+	.rcv	= brcm_tag_rcv,
+};
-- 
1.9.1
