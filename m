From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/2] net: dsa: introduce STPID switch tagging handling code
Date: Wed, 21 Jul 2010 09:37:21 -0400
Message-ID: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Karl Beldan <karl.beldan@gmail.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:41823 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753419Ab0GUNhE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 09:37:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graf Yang <graf.yang@analog.com>

Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 include/linux/if_ether.h  |    1 +
 include/linux/netdevice.h |   10 +++
 include/net/dsa.h         |    2 +-
 net/dsa/Kconfig           |    3 +
 net/dsa/Makefile          |    1 +
 net/dsa/dsa.c             |    6 ++
 net/dsa/dsa_priv.h        |    2 +
 net/dsa/slave.c           |   18 ++++++
 net/dsa/tag_stpid.c       |  147 +++++++++++++++++++++++++++++++++++++++++++++
 net/ethernet/eth.c        |    2 +
 10 files changed, 191 insertions(+), 1 deletions(-)
 create mode 100644 net/dsa/tag_stpid.c

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index c831467..cb9e2be 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -107,6 +107,7 @@
 #define ETH_P_ARCNET	0x001A		/* 1A for ArcNet :-)            */
 #define ETH_P_DSA	0x001B		/* Distributed Switch Arch.	*/
 #define ETH_P_TRAILER	0x001C		/* Trailer switch tagging	*/
+#define ETH_P_STPID	0x001D		/* STPID switch tagging		*/
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b626289..a13dca4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1140,6 +1140,16 @@ static inline bool netdev_uses_trailer_tags(struct net_device *dev)
 	return 0;
 }
 
+static inline bool netdev_uses_stpid_tags(struct net_device *dev)
+{
+#ifdef CONFIG_NET_DSA_TAG_STPID
+	if (dev->dsa_ptr != NULL)
+		return dsa_uses_stpid_tags(dev->dsa_ptr);
+#endif
+
+	return 0;
+}
+
 /**
  *	netdev_priv - access network device private data
  *	@dev: network device
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 839f768..21a5e2e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -56,6 +56,6 @@ struct dsa_platform_data {
 
 extern bool dsa_uses_dsa_tags(void *dsa_ptr);
 extern bool dsa_uses_trailer_tags(void *dsa_ptr);
-
+extern bool dsa_uses_stpid_tags(void *dsa_ptr);
 
 #endif
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 1120178..ee8d705 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -23,6 +23,9 @@ config NET_DSA_TAG_TRAILER
 	bool
 	default n
 
+config NET_DSA_TAG_STPID
+	bool
+	default n
 
 # switch drivers
 config NET_DSA_MV88E6XXX
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 2374faf..4881577 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -2,6 +2,7 @@
 obj-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 obj-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
 obj-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
+obj-$(CONFIG_NET_DSA_TAG_STPID) += tag_stpid.o
 
 # switch drivers
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 6112a12..8cb4dfa 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -220,6 +220,12 @@ bool dsa_uses_trailer_tags(void *dsa_ptr)
 	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
 }
 
+bool dsa_uses_stpid_tags(void *dsa_ptr)
+{
+	struct dsa_switch_tree *dst = dsa_ptr;
+
+	return !!(dst->tag_protocol == htons(ETH_P_STPID));
+}
 
 /* link polling *************************************************************/
 static void dsa_link_poll_work(struct work_struct *ugly)
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 4b0ea05..be76ded 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -177,5 +177,7 @@ netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev);
 /* tag_trailer.c */
 netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev);
 
+/* tag_stpid.c */
+int stpid_xmit(struct sk_buff *skb, struct net_device *dev);
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 64ca2a6..a1b30a7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -333,6 +333,19 @@ static const struct net_device_ops trailer_netdev_ops = {
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
 #endif
+#ifdef CONFIG_NET_DSA_TAG_STPID
+static const struct net_device_ops stpid_netdev_ops = {
+	.ndo_init		= dsa_slave_init,
+	.ndo_open		= dsa_slave_open,
+	.ndo_stop		= dsa_slave_close,
+	.ndo_start_xmit		= stpid_xmit,
+	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
+	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
+	.ndo_set_multicast_list = dsa_slave_set_rx_mode,
+	.ndo_set_mac_address	= dsa_slave_set_mac_address,
+	.ndo_do_ioctl		= dsa_slave_ioctl,
+};
+#endif
 
 /* slave device setup *******************************************************/
 struct net_device *
@@ -370,6 +383,11 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		slave_dev->netdev_ops = &trailer_netdev_ops;
 		break;
 #endif
+#ifdef CONFIG_NET_DSA_TAG_STPID
+	case htons(ETH_P_STPID):
+		slave_dev->netdev_ops = &stpid_netdev_ops;
+		break;
+#endif
 	default:
 		BUG();
 	}
diff --git a/net/dsa/tag_stpid.c b/net/dsa/tag_stpid.c
new file mode 100644
index 0000000..b5d9829
--- /dev/null
+++ b/net/dsa/tag_stpid.c
@@ -0,0 +1,147 @@
+/*
+ * net/dsa/tag_stpid.c - special tag identifier,
+ * 0x810 + 4 bit "port mask" + 3 bit 8021p + 1 bit CFI + 12 bit VLAN ID
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
+#define ETH_P_8021QH      (ETH_P_8021Q >> 8)
+#define ETH_P_8021QL      (ETH_P_8021Q & 0xFF)
+#define STPID_HLEN        4
+
+#define ZERO_VID          0
+#define RESERVED_VID      0xFFF
+#define STPID_VID         ZERO_VID
+
+int stpid_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	u8 *dsa_header;
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	/*
+	 * For 802.1Q frames, convert to STPID tagged frames,
+	 * do nothing for common frames.
+	 */
+	if (skb->protocol == htons(ETH_P_8021Q)) {
+		if (skb_cow_head(skb, 0) < 0)
+			goto out_free;
+
+		dsa_header = skb->data + 2 * ETH_ALEN;
+		dsa_header[1] = p->port & 0x03;
+	}
+
+	skb->protocol = htons(ETH_P_STPID);
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
+static int stpid_rcv(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds = dst->ds[0];
+	u8 *dsa_header;
+	int source_port;
+	int vid;
+
+	if (unlikely(ds == NULL))
+		goto out_drop;
+
+	skb = skb_unshare(skb, GFP_ATOMIC);
+	if (skb == NULL)
+		goto out;
+
+	/* The ether_head has been pulled by master driver */
+	dsa_header = skb->data - 2;
+
+	vid = ((dsa_header[2] & 0x0f)<<8 | dsa_header[3]);
+
+	source_port = dsa_header[1] & 0x03;
+	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+		goto out_drop;
+
+	if (((dsa_header[0] & ETH_P_8021QH) == ETH_P_8021QH) &&
+			(vid != STPID_VID)) {
+		u8 new_header[STPID_HLEN];
+
+		/* Convert STPID tag to 802.1q tag */
+		new_header[0] = ETH_P_8021QH;
+		new_header[1] = ETH_P_8021QL;
+
+		if (skb->ip_summed == CHECKSUM_COMPLETE) {
+			__wsum c = skb->csum;
+			c = csum_add(c, csum_partial(new_header, 2, 0));
+			c = csum_sub(c, csum_partial(dsa_header, 2, 0));
+			skb->csum = c;
+		}
+		memcpy(dsa_header, new_header, STPID_HLEN / 2);
+
+	} else if ((dsa_header[0] & ETH_P_8021QH) &&
+			(vid == STPID_VID)) {
+
+		if (unlikely(!pskb_may_pull(skb, STPID_HLEN)))
+			goto out_drop;
+
+		/* Remove STPID tag and update checksum. */
+		if (skb->ip_summed == CHECKSUM_COMPLETE) {
+			__wsum c = skb->csum;
+			c = csum_sub(c, csum_partial(dsa_header, STPID_HLEN, 0));
+			skb->csum = c;
+		}
+		memmove(skb->data - ETH_HLEN + STPID_HLEN,
+				skb->data - ETH_HLEN, 2 * ETH_ALEN);
+		skb_pull(skb, STPID_HLEN);
+	}
+
+	skb->dev = ds->ports[source_port];
+	skb_push(skb, ETH_HLEN);
+	skb->pkt_type = PACKET_HOST;
+	skb->protocol = eth_type_trans(skb, skb->dev);
+	skb->dev->last_rx = jiffies;
+	skb->dev->stats.rx_packets++;
+	skb->dev->stats.rx_bytes += skb->len;
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
+static struct packet_type stpid_packet_type = {
+	.type	= __constant_htons(ETH_P_STPID),
+	.func	= stpid_rcv,
+};
+
+static int __init stpid_init_module(void)
+{
+	dev_add_pack(&stpid_packet_type);
+	return 0;
+}
+module_init(stpid_init_module);
+
+static void __exit stpid_cleanup_module(void)
+{
+	dev_remove_pack(&stpid_packet_type);
+}
+module_exit(stpid_cleanup_module);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 215c839..964f9d2 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -194,6 +194,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 		return htons(ETH_P_DSA);
 	if (netdev_uses_trailer_tags(dev))
 		return htons(ETH_P_TRAILER);
+	if (netdev_uses_stpid_tags(dev))
+		return htons(ETH_P_STPID);
 
 	if (ntohs(eth->h_proto) >= 1536)
 		return eth->h_proto;
-- 
1.7.1.1

