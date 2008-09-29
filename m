From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/6] [NET] dsa: add support for Trailer tagging format
Date: Mon, 29 Sep 2008 04:39:36 +0200
Message-ID: <20080929023936.GK21560@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:49036 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbYI2Cjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 22:39:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the Trailer switch tagging format.  This is
another tagging that doesn't explicitly mark tagged packets with a
distinct ethertype, so that we need to add a similar hack in the
receive path as for the Original DSA tagging format.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Tested-by: Byron Bradley <byron.bbradley@gmail.com>
Semi-tested-by: Tim Ellis <tim.ellis@mac.com>
---
 include/linux/if_ether.h  |    1 +
 include/linux/netdevice.h |   10 ++++
 include/net/dsa.h         |    1 +
 net/dsa/Kconfig           |    4 ++
 net/dsa/Makefile          |    1 +
 net/dsa/dsa.c             |    7 +++
 net/dsa/dsa_priv.h        |    4 ++
 net/dsa/slave.c           |    5 ++
 net/dsa/tag_trailer.c     |  129 +++++++++++++++++++++++++++++++++++++++++++++
 net/ethernet/eth.c        |    2 +
 10 files changed, 164 insertions(+), 0 deletions(-)
 create mode 100644 net/dsa/tag_trailer.c

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 864982b..23707d4 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -101,6 +101,7 @@
 #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
 #define ETH_P_ARCNET	0x001A		/* 1A for ArcNet :-)            */
 #define ETH_P_DSA	0x001B		/* Distributed Switch Arch.	*/
+#define ETH_P_TRAILER	0x001C		/* Trailer switch tagging	*/
 
 /*
  *	This is an Ethernet frame header.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5226308..169ce79 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -812,6 +812,16 @@ static inline int netdev_uses_dsa_tags(struct net_device *dev)
 	return 0;
 }
 
+static inline int netdev_uses_trailer_tags(struct net_device *dev)
+{
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+	if (dev->dsa_ptr != NULL)
+		return dsa_uses_trailer_tags(dev->dsa_ptr);
+#endif
+
+	return 0;
+}
+
 /**
  *	netdev_priv - access network device private data
  *	@dev: network device
diff --git a/include/net/dsa.h b/include/net/dsa.h
index a331f64..d78b95a 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -21,6 +21,7 @@ struct dsa_platform_data {
 };
 
 int dsa_uses_dsa_tags(void *dsa_ptr);
+int dsa_uses_trailer_tags(void *dsa_ptr);
 
 
 #endif
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 79bcd76..505aa14 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -18,6 +18,10 @@ config NET_DSA_TAG_EDSA
 	bool
 	default n
 
+config NET_DSA_TAG_TRAILER
+	bool
+	default n
+
 
 # switch drivers
 config NET_DSA_MV88E6XXX
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 7fb6f85..63d3c44 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,6 +1,7 @@
 # tagging formats
 obj-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 obj-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
+obj-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
 
 # switch drivers
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d16a66e..abf69cf 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -218,6 +218,13 @@ int dsa_uses_dsa_tags(void *dsa_ptr)
 	return !!(ds->tag_type == TAG_TYPE_DSA);
 }
 
+int dsa_uses_trailer_tags(void *dsa_ptr)
+{
+	struct dsa_switch *ds = dsa_ptr;
+
+	return !!(ds->tag_type == TAG_TYPE_TRAILER);
+}
+
 
 /* link polling *************************************************************/
 static void dsa_link_poll_work(struct work_struct *ugly)
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 385a380..17897fe 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -20,6 +20,7 @@
 enum dsa_tag_type {
 	TAG_TYPE_DSA,
 	TAG_TYPE_EDSA,
+	TAG_TYPE_TRAILER,
 };
 
 struct dsa_switch {
@@ -108,5 +109,8 @@ int dsa_xmit(struct sk_buff *skb, struct net_device *dev);
 /* tag_edsa.c */
 int edsa_xmit(struct sk_buff *skb, struct net_device *dev);
 
+/* tag_trailer.c */
+int trailer_xmit(struct sk_buff *skb, struct net_device *dev);
+
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ac8ed09..db3185a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -248,6 +248,11 @@ struct net_device *dsa_slave_create(struct dsa_switch *ds, int port)
 		slave_dev->hard_start_xmit = edsa_xmit;
 		break;
 #endif
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+	case TAG_TYPE_TRAILER:
+		slave_dev->hard_start_xmit = trailer_xmit;
+		break;
+#endif
 	default:
 		BUG();
 	}
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
new file mode 100644
index 0000000..abb993c
--- /dev/null
+++ b/net/dsa/tag_trailer.c
@@ -0,0 +1,129 @@
+/*
+ * net/dsa/tag_trailer.c - Trailer tag format handling
+ * Copyright (c) 2008 Marvell Semiconductor
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
+#include "dsa_priv.h"
+
+int trailer_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct sk_buff *nskb;
+	int padlen;
+	char *trailer;
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	/*
+	 * We have to make sure that the trailer ends up as the very
+	 * last 4 bytes of the packet.  This means that we have to pad
+	 * the packet to the minimum ethernet frame size, if necessary,
+	 * before adding the trailer.
+	 */
+	padlen = 0;
+	if (skb->len < 60)
+		padlen = 60 - skb->len;
+
+	nskb = alloc_skb(NET_IP_ALIGN + skb->len + padlen + 4, GFP_ATOMIC);
+	if (nskb == NULL) {
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+	skb_reserve(nskb, NET_IP_ALIGN);
+
+	skb_reset_mac_header(nskb);
+	skb_set_network_header(nskb, skb_network_header(skb) - skb->head);
+	skb_set_transport_header(nskb, skb_transport_header(skb) - skb->head);
+	skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
+	kfree_skb(skb);
+
+	if (padlen) {
+		char *pad = skb_put(nskb, padlen);
+		memset(pad, 0, padlen);
+	}
+
+	trailer = skb_put(nskb, 4);
+	trailer[0] = 0x80;
+	trailer[1] = 1 << p->port;
+	trailer[2] = 0x10;
+	trailer[3] = 0x00;
+
+	nskb->protocol = htons(ETH_P_TRAILER);
+	nskb->dev = p->parent->master_dev;
+	dev_queue_xmit(nskb);
+
+	return NETDEV_TX_OK;
+}
+
+static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
+		       struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dsa_switch *ds = dev->dsa_ptr;
+	u8 *trailer;
+	int source_port;
+
+	if (unlikely(ds == NULL))
+		goto out_drop;
+
+	skb = skb_unshare(skb, GFP_ATOMIC);
+	if (skb == NULL)
+		goto out;
+
+	if (skb_linearize(skb))
+		goto out_drop;
+
+	trailer = skb_tail_pointer(skb) - 4;
+	if (trailer[0] != 0x80 || (trailer[1] & 0xf8) != 0x00 ||
+	    (trailer[3] & 0xef) != 0x00 || trailer[3] != 0x00)
+		goto out_drop;
+
+	source_port = trailer[1] & 7;
+	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+		goto out_drop;
+
+	pskb_trim_rcsum(skb, skb->len - 4);
+
+	skb->dev = ds->ports[source_port];
+	skb_push(skb, ETH_HLEN);
+	skb->protocol = eth_type_trans(skb, skb->dev);
+
+	skb->dev->last_rx = jiffies;
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
+static struct packet_type trailer_packet_type = {
+	.type	= __constant_htons(ETH_P_TRAILER),
+	.func	= trailer_rcv,
+};
+
+static int __init trailer_init_module(void)
+{
+	dev_add_pack(&trailer_packet_type);
+	return 0;
+}
+module_init(trailer_init_module);
+
+static void __exit trailer_cleanup_module(void)
+{
+	dev_remove_pack(&trailer_packet_type);
+}
+module_exit(trailer_cleanup_module);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index e0aca95..9a9dd28 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -193,6 +193,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (netdev_uses_dsa_tags(dev))
 		return htons(ETH_P_DSA);
+	if (netdev_uses_trailer_tags(dev))
+		return htons(ETH_P_TRAILER);
 
 	if (ntohs(eth->h_proto) >= 1536)
 		return eth->h_proto;
-- 
1.5.6.4
