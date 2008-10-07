From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCHv3 2/5] [NET] dsa: add support for original DSA tagging format
Date: Wed, 8 Oct 2008 01:45:02 +0200
Message-ID: <20081007234502.GC23200@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:60973 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755038AbYJGXpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 19:45:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the DSA switches currently in the field do not support the
Ethertype DSA tagging format that one of the previous patches added
support for, but only the original DSA tagging format.

The original DSA tagging format carries the same information as the
Ethertype DSA tagging format, but with the difference that it does not
have an ethertype field.  In other words, when receiving a packet that
is tagged with an original DSA tag, there is no way of telling in
eth_type_trans() that this packet is in fact a DSA-tagged packet.

This patch adds a hook into eth_type_trans() which is only compiled in
if support for a switch chip that doesn't support Ethertype DSA is
selected, and which checks whether there is a DSA switch driver
instance attached to this network device which uses the old tag format.
If so, it sets the protocol field to ETH_P_DSA without looking at the
packet, so that the packet ends up in the right place.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Tested-by: Nicolas Pitre <nico@marvell.com>
Tested-by: Peter van Valderen <linux@ddcrew.com>
Tested-by: Dirk Teurlings <dirk@upexia.nl>
---
 include/linux/if_ether.h  |    1 +
 include/linux/netdevice.h |   11 +++
 include/net/dsa.h         |    2 +
 net/dsa/Kconfig           |    4 +
 net/dsa/Makefile          |    1 +
 net/dsa/dsa.c             |   16 ++++
 net/dsa/dsa_priv.h        |    3 +
 net/dsa/mv88e6123_61_65.c |   18 +++--
 net/dsa/slave.c           |    5 +
 net/dsa/tag_dsa.c         |  194 +++++++++++++++++++++++++++++++++++++++++++++
 net/ethernet/eth.c        |   10 +++
 11 files changed, 258 insertions(+), 7 deletions(-)
 create mode 100644 net/dsa/tag_dsa.c

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 2140aac..32b9dcd 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -101,6 +101,7 @@
 #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
 #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
 #define ETH_P_ARCNET	0x001A		/* 1A for ArcNet :-)            */
+#define ETH_P_DSA	0x001B		/* Distributed Switch Arch.	*/
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 
 /*
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 794eeb4..97f0c64 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -42,6 +42,7 @@
 #include <linux/workqueue.h>
 
 #include <net/net_namespace.h>
+#include <net/dsa.h>
 
 struct vlan_group;
 struct ethtool_ops;
@@ -801,6 +802,16 @@ void dev_net_set(struct net_device *dev, struct net *net)
 #endif
 }
 
+static inline bool netdev_uses_dsa_tags(struct net_device *dev)
+{
+#ifdef CONFIG_NET_DSA_TAG_DSA
+	if (dev->dsa_ptr != NULL)
+		return dsa_uses_dsa_tags(dev->dsa_ptr);
+#endif
+
+	return 0;
+}
+
 /**
  *	netdev_priv - access network device private data
  *	@dev: network device
diff --git a/include/net/dsa.h b/include/net/dsa.h
index dc4784f..72e509b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -30,5 +30,7 @@ struct dsa_platform_data {
 	char		*port_names[DSA_MAX_PORTS];
 };
 
+extern bool dsa_uses_dsa_tags(void *dsa_ptr);
+
 
 #endif
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 7cf55e5..6b68016 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -10,6 +10,10 @@ menuconfig NET_DSA
 if NET_DSA
 
 # tagging formats
+config NET_DSA_TAG_DSA
+	bool
+	default n
+
 config NET_DSA_TAG_EDSA
 	bool
 	default n
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index b59a6f6..8b92123 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,4 +1,5 @@
 # tagging formats
+obj-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 obj-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
 
 # switch drivers
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 6cc5be2..f8c5492 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -202,6 +202,22 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 }
 
 
+/* hooks for ethertype-less tagging formats *********************************/
+/*
+ * The original DSA tag format and some other tag formats have no
+ * ethertype, which means that we need to add a little hack to the
+ * networking receive path to make sure that received frames get
+ * the right ->protocol assigned to them when one of those tag
+ * formats is in use.
+ */
+bool dsa_uses_dsa_tags(void *dsa_ptr)
+{
+	struct dsa_switch *ds = dsa_ptr;
+
+	return !!(ds->tag_protocol == htons(ETH_P_DSA));
+}
+
+
 /* link polling *************************************************************/
 static void dsa_link_poll_work(struct work_struct *ugly)
 {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index ae3737e..148ade8 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -102,6 +102,9 @@ struct net_device *dsa_slave_create(struct dsa_switch *ds,
 				    struct device *parent,
 				    int port, char *name);
 
+/* tag_dsa.c */
+int dsa_xmit(struct sk_buff *skb, struct net_device *dev);
+
 /* tag_edsa.c */
 int edsa_xmit(struct sk_buff *skb, struct net_device *dev);
 
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index 147818c..555b164 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -192,15 +192,19 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 
 	/*
 	 * Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
-	 * configure the EDSA tagging mode if this is the CPU port,
-	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
-	 * tunneling, determine priority by looking at 802.1p and IP
-	 * priority fields (IP prio has precedence), and set STP state
-	 * to Forwarding.  Finally, if this is the CPU port, additionally
-	 * enable forwarding of unknown unicast and multicast addresses.
+	 * configure the requested (DSA/EDSA) tagging mode if this is
+	 * the CPU port, disable Header mode, enable IGMP/MLD snooping,
+	 * disable VLAN tunneling, determine priority by looking at
+	 * 802.1p and IP priority fields (IP prio has precedence), and
+	 * set STP state to Forwarding.  Finally, if this is the CPU
+	 * port, additionally enable forwarding of unknown unicast and
+	 * multicast addresses.
 	 */
 	REG_WRITE(addr, 0x04,
-			(p == ds->cpu_port) ? 0x373f : 0x0433);
+			(p == ds->cpu_port) ?
+			 (ds->tag_protocol == htons(ETH_P_DSA)) ?
+			  0x053f : 0x373f :
+			 0x0433);
 
 	/*
 	 * Port Control 1: disable trunking.  Also, if this is the
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3cb331e..8f8868d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -239,6 +239,11 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	memcpy(slave_dev->dev_addr, master->dev_addr, ETH_ALEN);
 	slave_dev->tx_queue_len = 0;
 	switch (ds->tag_protocol) {
+#ifdef CONFIG_NET_DSA_TAG_DSA
+	case htons(ETH_P_DSA):
+		slave_dev->hard_start_xmit = dsa_xmit;
+		break;
+#endif
 #ifdef CONFIG_NET_DSA_TAG_EDSA
 	case htons(ETH_P_EDSA):
 		slave_dev->hard_start_xmit = edsa_xmit;
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
new file mode 100644
index 0000000..bdc0510
--- /dev/null
+++ b/net/dsa/tag_dsa.c
@@ -0,0 +1,194 @@
+/*
+ * net/dsa/tag_dsa.c - (Non-ethertype) DSA tagging
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
+#define DSA_HLEN	4
+
+int dsa_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	u8 *dsa_header;
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	/*
+	 * Convert the outermost 802.1q tag to a DSA tag for tagged
+	 * packets, or insert a DSA tag between the addresses and
+	 * the ethertype field for untagged packets.
+	 */
+	if (skb->protocol == htons(ETH_P_8021Q)) {
+		if (skb_cow_head(skb, 0) < 0)
+			goto out_free;
+
+		/*
+		 * Construct tagged FROM_CPU DSA tag from 802.1q tag.
+		 */
+		dsa_header = skb->data + 2 * ETH_ALEN;
+		dsa_header[0] = 0x60;
+		dsa_header[1] = p->port << 3;
+
+		/*
+		 * Move CFI field from byte 2 to byte 1.
+		 */
+		if (dsa_header[2] & 0x10) {
+			dsa_header[1] |= 0x01;
+			dsa_header[2] &= ~0x10;
+		}
+	} else {
+		if (skb_cow_head(skb, DSA_HLEN) < 0)
+			goto out_free;
+		skb_push(skb, DSA_HLEN);
+
+		memmove(skb->data, skb->data + DSA_HLEN, 2 * ETH_ALEN);
+
+		/*
+		 * Construct untagged FROM_CPU DSA tag.
+		 */
+		dsa_header = skb->data + 2 * ETH_ALEN;
+		dsa_header[0] = 0x40;
+		dsa_header[1] = p->port << 3;
+		dsa_header[2] = 0x00;
+		dsa_header[3] = 0x00;
+	}
+
+	skb->protocol = htons(ETH_P_DSA);
+
+	skb->dev = p->parent->master_netdev;
+	dev_queue_xmit(skb);
+
+	return NETDEV_TX_OK;
+
+out_free:
+	kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dsa_switch *ds = dev->dsa_ptr;
+	u8 *dsa_header;
+	int source_port;
+
+	if (unlikely(ds == NULL))
+		goto out_drop;
+
+	skb = skb_unshare(skb, GFP_ATOMIC);
+	if (skb == NULL)
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, DSA_HLEN)))
+		goto out_drop;
+
+	/*
+	 * The ethertype field is part of the DSA header.
+	 */
+	dsa_header = skb->data - 2;
+
+	/*
+	 * Check that frame type is either TO_CPU or FORWARD, and
+	 * that the source device is zero.
+	 */
+	if ((dsa_header[0] & 0xdf) != 0x00 && (dsa_header[0] & 0xdf) != 0xc0)
+		goto out_drop;
+
+	/*
+	 * Check that the source port is a registered DSA port.
+	 */
+	source_port = (dsa_header[1] >> 3) & 0x1f;
+	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+		goto out_drop;
+
+	/*
+	 * Convert the DSA header to an 802.1q header if the 'tagged'
+	 * bit in the DSA header is set.  If the 'tagged' bit is clear,
+	 * delete the DSA header entirely.
+	 */
+	if (dsa_header[0] & 0x20) {
+		u8 new_header[4];
+
+		/*
+		 * Insert 802.1q ethertype and copy the VLAN-related
+		 * fields, but clear the bit that will hold CFI (since
+		 * DSA uses that bit location for another purpose).
+		 */
+		new_header[0] = (ETH_P_8021Q >> 8) & 0xff;
+		new_header[1] = ETH_P_8021Q & 0xff;
+		new_header[2] = dsa_header[2] & ~0x10;
+		new_header[3] = dsa_header[3];
+
+		/*
+		 * Move CFI bit from its place in the DSA header to
+		 * its 802.1q-designated place.
+		 */
+		if (dsa_header[1] & 0x01)
+			new_header[2] |= 0x10;
+
+		/*
+		 * Update packet checksum if skb is CHECKSUM_COMPLETE.
+		 */
+		if (skb->ip_summed == CHECKSUM_COMPLETE) {
+			__wsum c = skb->csum;
+			c = csum_add(c, csum_partial(new_header + 2, 2, 0));
+			c = csum_sub(c, csum_partial(dsa_header + 2, 2, 0));
+			skb->csum = c;
+		}
+
+		memcpy(dsa_header, new_header, DSA_HLEN);
+	} else {
+		/*
+		 * Remove DSA tag and update checksum.
+		 */
+		skb_pull_rcsum(skb, DSA_HLEN);
+		memmove(skb->data - ETH_HLEN,
+			skb->data - ETH_HLEN - DSA_HLEN,
+			2 * ETH_ALEN);
+	}
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
+static struct packet_type dsa_packet_type = {
+	.type	= __constant_htons(ETH_P_DSA),
+	.func	= dsa_rcv,
+};
+
+static int __init dsa_init_module(void)
+{
+	dev_add_pack(&dsa_packet_type);
+	return 0;
+}
+module_init(dsa_init_module);
+
+static void __exit dsa_cleanup_module(void)
+{
+	dev_remove_pack(&dsa_packet_type);
+}
+module_exit(dsa_cleanup_module);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 647a9ed..dae47e7 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -57,6 +57,7 @@
 #include <net/sock.h>
 #include <net/ipv6.h>
 #include <net/ip.h>
+#include <net/dsa.h>
 #include <asm/uaccess.h>
 #include <asm/system.h>
 
@@ -184,6 +185,15 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
 
+	/*
+	 * Some variants of DSA tagging don't have an ethertype field
+	 * at all, so we check here whether one of those tagging
+	 * variants has been configured on the receiving interface,
+	 * and if so, set skb->protocol without looking at the packet.
+	 */
+	if (netdev_uses_dsa_tags(dev))
+		return htons(ETH_P_DSA);
+
 	if (ntohs(eth->h_proto) >= 1536)
 		return eth->h_proto;
 
-- 
1.5.6.4
