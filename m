From: Patrick McHardy <kaber@trash.net>
Subject: vlan 04/07: uninline __vlan_hwaccel_rx
Date: Mon,  7 Jul 2008 14:36:04 +0200 (MEST)
Message-ID: <20080707123603.23947.96722.sendpatchset@localhost.localdomain>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59273 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbYGGMgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:36:05 -0400
In-Reply-To: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: uninline __vlan_hwaccel_rx

The function is huge and included at least once in every VLAN acceleration
capable driver. Uninline it; to avoid having drivers depend on the VLAN
module, the function is always built in statically when VLAN is enabled.

With all VLAN acceleration capable drivers that build on x86_64 enabled,
this results in:

   text    data     bss     dec     hex filename
6515227  854044  343968 7713239  75b1d7 vmlinux.inlined
6505637  854044  343968 7703649  758c61 vmlinux.uninlined
----------------------------------------------------------
  -9590

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f8a70bfd12e6421b2c98e19a475633fddb5d5a2a
tree 0fdcf8c5470ec7cc9743f6850e38a99999dc8431
parent 0dba2d1f208d01290f0ea2d19a201f06da80dded
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:44 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:44 +0200

 include/linux/if_vlan.h |   64 ++++++-----------------------------------------
 net/8021q/Makefile      |    9 ++++---
 net/8021q/vlan.h        |    8 ++++++
 net/8021q/vlan_core.c   |   48 +++++++++++++++++++++++++++++++++++
 net/Makefile            |    4 ++-
 5 files changed, 72 insertions(+), 61 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 8f5bf9b..594cd35 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -150,15 +150,6 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
 	return netdev_priv(dev);
 }
 
-/* inline functions */
-static inline __u32 vlan_get_ingress_priority(struct net_device *dev,
-					      unsigned short vlan_tag)
-{
-	struct vlan_dev_info *vip = vlan_dev_info(dev);
-
-	return vip->ingress_priority_map[(vlan_tag >> 13) & 0x7];
-}
-
 /* VLAN tx hw acceleration helpers. */
 struct vlan_skb_tx_cookie {
 	u32	magic;
@@ -171,56 +162,17 @@ struct vlan_skb_tx_cookie {
 	(VLAN_TX_SKB_CB(__skb)->magic == VLAN_TX_COOKIE_MAGIC)
 #define vlan_tx_tag_get(__skb)	(VLAN_TX_SKB_CB(__skb)->vlan_tag)
 
-/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
-static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
-				    struct vlan_group *grp,
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
+			     unsigned short vlan_tag, int polling);
+#else
+static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 				    unsigned short vlan_tag, int polling)
 {
-	struct net_device_stats *stats;
-
-	if (skb_bond_should_drop(skb)) {
-		dev_kfree_skb_any(skb);
-		return NET_RX_DROP;
-	}
-
-	skb->dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
-	if (skb->dev == NULL) {
-		dev_kfree_skb_any(skb);
-
-		/* Not NET_RX_DROP, this is not being dropped
-		 * due to congestion.
-		 */
-		return 0;
-	}
-
-	skb->dev->last_rx = jiffies;
-
-	stats = &skb->dev->stats;
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-
-	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
-	switch (skb->pkt_type) {
-	case PACKET_BROADCAST:
-		break;
-
-	case PACKET_MULTICAST:
-		stats->multicast++;
-		break;
-
-	case PACKET_OTHERHOST:
-		/* Our lower layer thinks this is not local, let's make sure.
-		 * This allows the VLAN to have a different MAC than the underlying
-		 * device, and still route correctly.
-		 */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-				       	skb->dev->dev_addr))
-			skb->pkt_type = PACKET_HOST;
-		break;
-	};
-
-	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+	BUG();
+	return NET_XMIT_SUCCESS;
 }
+#endif
 
 static inline int vlan_hwaccel_rx(struct sk_buff *skb,
 				  struct vlan_group *grp,
diff --git a/net/8021q/Makefile b/net/8021q/Makefile
index 3006e9e..9f4f174 100644
--- a/net/8021q/Makefile
+++ b/net/8021q/Makefile
@@ -1,9 +1,10 @@
 #
 # Makefile for the Linux VLAN layer.
 #
+obj-$(subst m,y,$(CONFIG_VLAN_8021Q))	+= vlan_core.o
+obj-$(CONFIG_VLAN_8021Q)		+= 8021q.o
 
-obj-$(CONFIG_VLAN_8021Q) += 8021q.o
+8021q-y					:= vlan.o vlan_dev.o vlan_netlink.o
+8021q-$(CONFIG_VLAN_8021Q_GVRP)		+= vlan_gvrp.o
+8021q-$(CONFIG_PROC_FS)			+= vlanproc.o
 
-8021q-y				:= vlan.o vlan_dev.o vlan_netlink.o
-8021q-$(CONFIG_VLAN_8021Q_GVRP)	+= vlan_gvrp.o
-8021q-$(CONFIG_PROC_FS)		+= vlanproc.o
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 097b2e0..7cc1a97 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -37,6 +37,14 @@ void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
 void unregister_vlan_dev(struct net_device *dev);
 
+static inline u32 vlan_get_ingress_priority(struct net_device *dev,
+					    unsigned short vlan_tag)
+{
+	struct vlan_dev_info *vip = vlan_dev_info(dev);
+
+	return vip->ingress_priority_map[(vlan_tag >> 13) & 0x7];
+}
+
 #ifdef CONFIG_VLAN_8021Q_GVRP
 extern int vlan_gvrp_request_join(const struct net_device *dev);
 extern void vlan_gvrp_request_leave(const struct net_device *dev);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
new file mode 100644
index 0000000..a6c249c
--- /dev/null
+++ b/net/8021q/vlan_core.c
@@ -0,0 +1,48 @@
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+#include "vlan.h"
+
+/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
+int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
+		      unsigned short vlan_tag, int polling)
+{
+	struct net_device_stats *stats;
+
+	if (skb_bond_should_drop(skb)) {
+		dev_kfree_skb_any(skb);
+		return NET_RX_DROP;
+	}
+
+	skb->dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
+	if (skb->dev == NULL) {
+		dev_kfree_skb_any(skb);
+		/* Not NET_RX_DROP, this is not being dropped
+		 * due to congestion. */
+		return NET_RX_SUCCESS;
+	}
+	skb->dev->last_rx = jiffies;
+
+	stats = &skb->dev->stats;
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+
+	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
+	switch (skb->pkt_type) {
+	case PACKET_BROADCAST:
+		break;
+	case PACKET_MULTICAST:
+		stats->multicast++;
+		break;
+	case PACKET_OTHERHOST:
+		/* Our lower layer thinks this is not local, let's make sure.
+		 * This allows the VLAN to have a different MAC than the
+		 * underlying device, and still route correctly. */
+		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+				       	skb->dev->dev_addr))
+			skb->pkt_type = PACKET_HOST;
+		break;
+	};
+	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+}
+EXPORT_SYMBOL(__vlan_hwaccel_rx);
diff --git a/net/Makefile b/net/Makefile
index b7a1364..4f43e7f 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -42,7 +42,9 @@ obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_DECNET)		+= decnet/
 obj-$(CONFIG_ECONET)		+= econet/
-obj-$(CONFIG_VLAN_8021Q)	+= 8021q/
+ifneq ($(CONFIG_VLAN_8021Q),)
+obj-y				+= 8021q/
+endif
 obj-$(CONFIG_IP_DCCP)		+= dccp/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
 obj-y				+= wireless/
