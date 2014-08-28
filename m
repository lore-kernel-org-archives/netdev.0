From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 01/13] net: dsa: reduce number of protocol hooks
Date: Wed, 27 Aug 2014 17:04:46 -0700
Message-ID: <1409184298-1793-2-git-send-email-f.fainelli@gmail.com>
References: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:52152 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965589AbaH1AFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 20:05:33 -0400
Received: by mail-pa0-f52.google.com with SMTP id eu11so98686pac.39
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 17:05:32 -0700 (PDT)
In-Reply-To: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA is currently registering one packet_type function per EtherType it
needs to intercept in the receive path of a DSA-enabled Ethernet device.
Right now we have three of them: trailer, DSA and eDSA, and there might
be more in the future, this will not scale to the addition of new
protocols.

This patch proceeds with adding a new layer of abstraction and two new
functions:

dsa_switch_rcv() which will dispatch into the tag-protocol specific
receive function implemented by net/dsa/tag_*.c

dsa_slave_xmit() which will dispatch into the tag-protocol specific
transmit function implemented by net/dsa/tag_*.c

When we do create the per-port slave network devices, we iterate over
the switch protocol to assign the DSA-specific receive and transmit
operations.

A new fake ethertype value is used: ETH_P_XDSA to illustrate the fact
that this is no longer going to look like ETH_P_DSA or ETH_P_TRAILER
like it used to be.

This allows us to greatly simplify the check in eth_type_trans() and
always override the skb->protocol with ETH_P_XDSA for Ethernet switches
tagged protocol, while also reducing the number repetitive slave
netdevice_ops assignments.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v5:
- add ETH_P_XDSA to help capture applications figure out this is
  a demultiplexed DSA now

Changes in v4:
- introduce a level of indirection and dsa_device_ops to limit the
  number of packet_type functions to just one and do the dispatching
  in the core dsa code.

New patch in v3

 include/linux/netdevice.h     | 28 ++++++++++++---------------
 include/net/dsa.h             | 20 +++----------------
 include/uapi/linux/if_ether.h |  1 +
 net/dsa/dsa.c                 | 39 ++++++++++++++++++++-----------------
 net/dsa/dsa_priv.h            |  9 +++------
 net/dsa/slave.c               | 45 ++++++++++++++-----------------------------
 net/dsa/tag_dsa.c             |  8 ++++----
 net/dsa/tag_edsa.c            |  8 ++++----
 net/dsa/tag_trailer.c         |  8 ++++----
 net/ethernet/eth.c            |  7 ++-----
 10 files changed, 68 insertions(+), 105 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 039b23786c22..1875dc71422a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1781,24 +1781,13 @@ void dev_net_set(struct net_device *dev, struct net *net)
 #endif
 }
 
-static inline bool netdev_uses_dsa_tags(struct net_device *dev)
+static inline bool netdev_uses_dsa(struct net_device *dev)
 {
-#ifdef CONFIG_NET_DSA_TAG_DSA
-	if (dev->dsa_ptr != NULL)
-		return dsa_uses_dsa_tags(dev->dsa_ptr);
-#endif
-
-	return 0;
-}
-
-static inline bool netdev_uses_trailer_tags(struct net_device *dev)
-{
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
-	if (dev->dsa_ptr != NULL)
-		return dsa_uses_trailer_tags(dev->dsa_ptr);
+#ifdef CONFIG_NET_DSA
+	return dev->dsa_ptr != NULL;
+#else
+	return false;
 #endif
-
-	return 0;
 }
 
 /**
@@ -1933,6 +1922,13 @@ struct udp_offload {
 	struct offload_callbacks callbacks;
 };
 
+struct dsa_device_ops {
+	netdev_tx_t (*xmit)(struct sk_buff *skb, struct net_device *dev);
+	int (*rcv)(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pt, struct net_device *orig_dev);
+};
+
+
 /* often modified stats are per cpu, other are shared (netdev->stats) */
 struct pcpu_sw_netstats {
 	u64     rx_packets;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6efce384451e..6e26f1e4d8ce 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -59,6 +59,8 @@ struct dsa_platform_data {
 	struct dsa_chip_data	*chip;
 };
 
+struct dsa_device_ops;
+
 struct dsa_switch_tree {
 	/*
 	 * Configuration data for the platform device that owns
@@ -71,6 +73,7 @@ struct dsa_switch_tree {
 	 * protocol to use.
 	 */
 	struct net_device	*master_netdev;
+	const struct dsa_device_ops	*ops;
 	__be16			tag_protocol;
 
 	/*
@@ -186,21 +189,4 @@ static inline void *ds_to_priv(struct dsa_switch *ds)
 	return (void *)(ds + 1);
 }
 
-/*
- * The original DSA tag format and some other tag formats have no
- * ethertype, which means that we need to add a little hack to the
- * networking receive path to make sure that received frames get
- * the right ->protocol assigned to them when one of those tag
- * formats is in use.
- */
-static inline bool dsa_uses_dsa_tags(struct dsa_switch_tree *dst)
-{
-	return !!(dst->tag_protocol == htons(ETH_P_DSA));
-}
-
-static inline bool dsa_uses_trailer_tags(struct dsa_switch_tree *dst)
-{
-	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
-}
-
 #endif
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 0f8210b8e0bc..aa63ed023c2b 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -128,6 +128,7 @@
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
+#define ETH_P_XDSA	0x00F8		/* Multiplexed DSA protocol	*/
 
 /*
  *	This is an Ethernet frame header.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0a49632fac47..92e71d2a2ccd 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -608,6 +608,24 @@ static void dsa_shutdown(struct platform_device *pdev)
 {
 }
 
+static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
+			  struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+
+	if (unlikely(dst == NULL)) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	return dst->ops->rcv(skb, dev, pt, orig_dev);
+}
+
+struct packet_type dsa_pack_type __read_mostly = {
+	.type	= cpu_to_be16(ETH_P_XDSA),
+	.func	= dsa_switch_rcv,
+};
+
 static const struct of_device_id dsa_of_match_table[] = {
 	{ .compatible = "marvell,dsa", },
 	{}
@@ -633,30 +651,15 @@ static int __init dsa_init_module(void)
 	if (rc)
 		return rc;
 
-#ifdef CONFIG_NET_DSA_TAG_DSA
-	dev_add_pack(&dsa_packet_type);
-#endif
-#ifdef CONFIG_NET_DSA_TAG_EDSA
-	dev_add_pack(&edsa_packet_type);
-#endif
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
-	dev_add_pack(&trailer_packet_type);
-#endif
+	dev_add_pack(&dsa_pack_type);
+
 	return 0;
 }
 module_init(dsa_init_module);
 
 static void __exit dsa_cleanup_module(void)
 {
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
-	dev_remove_pack(&trailer_packet_type);
-#endif
-#ifdef CONFIG_NET_DSA_TAG_EDSA
-	dev_remove_pack(&edsa_packet_type);
-#endif
-#ifdef CONFIG_NET_DSA_TAG_DSA
-	dev_remove_pack(&dsa_packet_type);
-#endif
+	dev_remove_pack(&dsa_pack_type);
 	platform_driver_unregister(&dsa_driver);
 }
 module_exit(dsa_cleanup_module);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d4cf5cc747e3..218d75d16f6f 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -45,16 +45,13 @@ struct net_device *dsa_slave_create(struct dsa_switch *ds,
 				    int port, char *name);
 
 /* tag_dsa.c */
-netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev);
-extern struct packet_type dsa_packet_type;
+extern const struct dsa_device_ops dsa_netdev_ops;
 
 /* tag_edsa.c */
-netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev);
-extern struct packet_type edsa_packet_type;
+extern const struct dsa_device_ops edsa_netdev_ops;
 
 /* tag_trailer.c */
-netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev);
-extern struct packet_type trailer_packet_type;
+extern const struct dsa_device_ops trailer_netdev_ops;
 
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 45a1e34c89e0..ad1a913533aa 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -171,6 +171,14 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch_tree *dst = p->parent->dst;
+
+	return dst->ops->xmit(skb, dev);
+}
+
 
 /* ethtool operations *******************************************************/
 static int
@@ -293,42 +301,16 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_sset_count		= dsa_slave_get_sset_count,
 };
 
-#ifdef CONFIG_NET_DSA_TAG_DSA
-static const struct net_device_ops dsa_netdev_ops = {
+static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_init		= dsa_slave_init,
 	.ndo_open	 	= dsa_slave_open,
 	.ndo_stop		= dsa_slave_close,
-	.ndo_start_xmit		= dsa_xmit,
+	.ndo_start_xmit		= dsa_slave_xmit,
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
-#endif
-#ifdef CONFIG_NET_DSA_TAG_EDSA
-static const struct net_device_ops edsa_netdev_ops = {
-	.ndo_init		= dsa_slave_init,
-	.ndo_open	 	= dsa_slave_open,
-	.ndo_stop		= dsa_slave_close,
-	.ndo_start_xmit		= edsa_xmit,
-	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
-	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
-	.ndo_set_mac_address	= dsa_slave_set_mac_address,
-	.ndo_do_ioctl		= dsa_slave_ioctl,
-};
-#endif
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
-static const struct net_device_ops trailer_netdev_ops = {
-	.ndo_init		= dsa_slave_init,
-	.ndo_open	 	= dsa_slave_open,
-	.ndo_stop		= dsa_slave_close,
-	.ndo_start_xmit		= trailer_xmit,
-	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
-	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
-	.ndo_set_mac_address	= dsa_slave_set_mac_address,
-	.ndo_do_ioctl		= dsa_slave_ioctl,
-};
-#endif
 
 /* slave device setup *******************************************************/
 struct net_device *
@@ -349,21 +331,22 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->tx_queue_len = 0;
+	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
 
 	switch (ds->dst->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
 	case htons(ETH_P_DSA):
-		slave_dev->netdev_ops = &dsa_netdev_ops;
+		ds->dst->ops = &dsa_netdev_ops;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_EDSA
 	case htons(ETH_P_EDSA):
-		slave_dev->netdev_ops = &edsa_netdev_ops;
+		ds->dst->ops = &edsa_netdev_ops;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
 	case htons(ETH_P_TRAILER):
-		slave_dev->netdev_ops = &trailer_netdev_ops;
+		ds->dst->ops = &trailer_netdev_ops;
 		break;
 #endif
 	default:
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index cacce1e22f9c..d7dbc5bda5c0 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -16,7 +16,7 @@
 
 #define DSA_HLEN	4
 
-netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	u8 *dsa_header;
@@ -186,7 +186,7 @@ out:
 	return 0;
 }
 
-struct packet_type dsa_packet_type __read_mostly = {
-	.type	= cpu_to_be16(ETH_P_DSA),
-	.func	= dsa_rcv,
+const struct dsa_device_ops dsa_netdev_ops = {
+	.xmit	= dsa_xmit,
+	.rcv	= dsa_rcv,
 };
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index e70c43c25e64..6b30abe89183 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -17,7 +17,7 @@
 #define DSA_HLEN	4
 #define EDSA_HLEN	8
 
-netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	u8 *edsa_header;
@@ -205,7 +205,7 @@ out:
 	return 0;
 }
 
-struct packet_type edsa_packet_type __read_mostly = {
-	.type	= cpu_to_be16(ETH_P_EDSA),
-	.func	= edsa_rcv,
+const struct dsa_device_ops edsa_netdev_ops = {
+	.xmit	= edsa_xmit,
+	.rcv	= edsa_rcv,
 };
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 94bc260d015d..5fe9444842c5 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -14,7 +14,7 @@
 #include <linux/slab.h>
 #include "dsa_priv.h"
 
-netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct sk_buff *nskb;
@@ -114,7 +114,7 @@ out:
 	return 0;
 }
 
-struct packet_type trailer_packet_type __read_mostly = {
-	.type	= cpu_to_be16(ETH_P_TRAILER),
-	.func	= trailer_rcv,
+const struct dsa_device_ops trailer_netdev_ops = {
+	.xmit	= trailer_xmit,
+	.rcv	= trailer_rcv,
 };
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index f405e0592407..5cebca134585 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -181,11 +181,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 * variants has been configured on the receiving interface,
 	 * and if so, set skb->protocol without looking at the packet.
 	 */
-	if (unlikely(netdev_uses_dsa_tags(dev)))
-		return htons(ETH_P_DSA);
-
-	if (unlikely(netdev_uses_trailer_tags(dev)))
-		return htons(ETH_P_TRAILER);
+	if (unlikely(netdev_uses_dsa(dev)))
+		return htons(ETH_P_XDSA);
 
 	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
 		return eth->h_proto;
-- 
1.9.1
