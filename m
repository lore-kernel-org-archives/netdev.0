From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 10/11] net: dsa: add Broadcom tag RX/TX handler
Date: Tue, 13 May 2014 22:00:36 -0700
Message-ID: <1400043637-9799-11-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:43176 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136AbaENFBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:36 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so1185679pad.9
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:35 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the 4-bytes Broadcom tag that built-in switches such as
the Starfighter 2 might insert when receiving packets, or that we need
to insert while targetting specific switch ports.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/Kconfig    |   3 +
 net/dsa/Makefile   |   1 +
 net/dsa/dsa.c      |   6 ++
 net/dsa/dsa_priv.h |   4 ++
 net/dsa/slave.c    |  17 ++++++
 net/dsa/tag_brcm.c | 170 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 201 insertions(+)
 create mode 100644 net/dsa/tag_brcm.c

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
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index ac05d55dfdd3..d38570f7c6d8 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -645,6 +645,9 @@ static int __init dsa_init_module(void)
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
 	dev_add_pack(&trailer_packet_type);
 #endif
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+	dev_add_pack(&brcm_tag_packet_type);
+#endif
 	return 0;
 }
 module_init(dsa_init_module);
@@ -660,6 +663,9 @@ static void __exit dsa_cleanup_module(void)
 #ifdef CONFIG_NET_DSA_TAG_DSA
 	dev_remove_pack(&dsa_packet_type);
 #endif
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+	dev_remove_pack(&brcm_tag_packet_type);
+#endif
 	platform_driver_unregister(&dsa_driver);
 }
 module_exit(dsa_cleanup_module);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index a7f6f0c5fa31..8fb71da70dd6 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -60,5 +60,9 @@ extern struct packet_type edsa_packet_type;
 netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev);
 extern struct packet_type trailer_packet_type;
 
+/* tag_brcm.c */
+netdev_tx_t brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev);
+extern struct packet_type brcm_tag_packet_type;
+
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 791b0899e7ee..e08d6664e882 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -295,6 +295,18 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_sset_count		= dsa_slave_get_sset_count,
 };
 
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+static const struct net_device_ops brcm_netdev_ops = {
+	.ndo_init		= dsa_slave_init,
+	.ndo_open	 	= dsa_slave_open,
+	.ndo_stop		= dsa_slave_close,
+	.ndo_start_xmit		= brcm_tag_xmit,
+	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
+	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
+	.ndo_set_mac_address	= dsa_slave_set_mac_address,
+	.ndo_do_ioctl		= dsa_slave_ioctl,
+};
+#endif
 #ifdef CONFIG_NET_DSA_TAG_DSA
 static const struct net_device_ops dsa_netdev_ops = {
 	.ndo_init		= dsa_slave_init,
@@ -462,6 +474,11 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		slave_dev->netdev_ops = &trailer_netdev_ops;
 		break;
 #endif
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+	case htons(ETH_P_BRCMTAG):
+		slave_dev->netdev_ops = &brcm_netdev_ops;
+		break;
+#endif
 	default:
 		slave_dev->netdev_ops = &dummy_netdev_ops;
 		break;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
new file mode 100644
index 000000000000..f2a7c9244626
--- /dev/null
+++ b/net/dsa/tag_brcm.c
@@ -0,0 +1,170 @@
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
+netdev_tx_t brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
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
+	 * deprecated */
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
+	struct dsa_switch *ds = dst->ds[0];
+	int source_port;
+	u8 *brcm_tag;
+
+	if (unlikely(dst == NULL))
+		goto out_drop;
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
+struct packet_type brcm_tag_packet_type __read_mostly = {
+	.type	= cpu_to_be16(ETH_P_BRCMTAG),
+	.func	= brcm_tag_rcv,
+};
-- 
1.9.1
