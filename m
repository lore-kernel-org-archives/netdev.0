From: Patrick McHardy <kaber@trash.net>
Subject: net: fix packet socket delivery in rx irq handler
Date: Tue, 04 Nov 2008 13:52:41 +0100
Message-ID: <49104599.1030200@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000806080205050708050401"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40497 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbYKDMws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 07:52:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000806080205050708050401
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the atl1 VLAN warning regression reported
by Ramon Casellas.


--------------000806080205050708050401
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit f60d3f0c1a7bf5072a809fdf7bfd39efded725f1
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Nov 4 13:30:54 2008 +0100

    net: fix packet socket delivery in rx irq handler
    
    The changes to deliver hardware accelerated VLAN packets to packet
    sockets (commit bc1d0411) caused a warning for non-NAPI drivers.
    The __vlan_hwaccel_rx() function is called directly from the drivers
    RX function, for non-NAPI drivers that means its still in RX IRQ
    context:
    
    [   27.779463] ------------[ cut here ]------------
    [   27.779509] WARNING: at kernel/softirq.c:136 local_bh_enable+0x37/0x81()
    ...
    [   27.782520]  [<c0264755>] netif_nit_deliver+0x5b/0x75
    [   27.782590]  [<c02bba83>] __vlan_hwaccel_rx+0x79/0x162
    [   27.782664]  [<f8851c1d>] atl1_intr+0x9a9/0xa7c [atl1]
    [   27.782738]  [<c0155b17>] handle_IRQ_event+0x23/0x51
    [   27.782808]  [<c015692e>] handle_edge_irq+0xc2/0x102
    [   27.782878]  [<c0105fd5>] do_IRQ+0x4d/0x64
    
    Split hardware accelerated VLAN reception into two parts to fix this:
    
    - __vlan_hwaccel_rx just stores the VLAN TCI and performs the VLAN
      device lookup, then calls netif_receive_skb()/netif_rx()
    
    - vlan_hwaccel_do_receive(), which is invoked by netif_receive_skb()
      in softirq context, performs the real reception and delivery to
      packet sockets.
    
    Reported-and-tested-by: Ramon Casellas <ramon.casellas@cttc.es>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 9e7b49b..a5cb0c3 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -114,6 +114,8 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
+extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
+
 #else
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
@@ -133,6 +135,11 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	BUG();
 	return NET_XMIT_SUCCESS;
 }
+
+static inline int vlan_hwaccel_do_receive(struct sk_buff *skb)
+{
+	return 0;
+}
 #endif
 
 /**
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 916061f..68ced4b 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -3,11 +3,20 @@
 #include <linux/if_vlan.h>
 #include "vlan.h"
 
+struct vlan_hwaccel_cb {
+	struct net_device	*dev;
+};
+
+static inline struct vlan_hwaccel_cb *vlan_hwaccel_cb(struct sk_buff *skb)
+{
+	return (struct vlan_hwaccel_cb *)skb->cb;
+}
+
 /* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		      u16 vlan_tci, int polling)
 {
-	struct net_device_stats *stats;
+	struct vlan_hwaccel_cb *cb = vlan_hwaccel_cb(skb);
 
 	if (skb_bond_should_drop(skb)) {
 		dev_kfree_skb_any(skb);
@@ -15,23 +24,35 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	}
 
 	skb->vlan_tci = vlan_tci;
+	cb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+
+	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+}
+EXPORT_SYMBOL(__vlan_hwaccel_rx);
+
+int vlan_hwaccel_do_receive(struct sk_buff *skb)
+{
+	struct vlan_hwaccel_cb *cb = vlan_hwaccel_cb(skb);
+	struct net_device *dev = cb->dev;
+	struct net_device_stats *stats;
+
 	netif_nit_deliver(skb);
 
-	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
-	if (skb->dev == NULL) {
-		dev_kfree_skb_any(skb);
-		/* Not NET_RX_DROP, this is not being dropped
-		 * due to congestion. */
-		return NET_RX_SUCCESS;
+	if (dev == NULL) {
+		kfree_skb(skb);
+		return -1;
 	}
-	skb->dev->last_rx = jiffies;
+
+	skb->dev = dev;
+	skb->priority = vlan_get_ingress_priority(dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
-	stats = &skb->dev->stats;
+	dev->last_rx = jiffies;
+
+	stats = &dev->stats;
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 
-	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tci);
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST:
 		break;
@@ -43,13 +64,12 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		 * This allows the VLAN to have a different MAC than the
 		 * underlying device, and still route correctly. */
 		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-					skb->dev->dev_addr))
+					dev->dev_addr))
 			skb->pkt_type = PACKET_HOST;
 		break;
 	};
-	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+	return 0;
 }
-EXPORT_SYMBOL(__vlan_hwaccel_rx);
 
 struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index d9038e3..9174c77 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2218,6 +2218,9 @@ int netif_receive_skb(struct sk_buff *skb)
 	int ret = NET_RX_DROP;
 	__be16 type;
 
+	if (skb->vlan_tci && vlan_hwaccel_do_receive(skb))
+		return NET_RX_SUCCESS;
+
 	/* if we've gotten here through NAPI, check netpoll */
 	if (netpoll_receive_skb(skb))
 		return NET_RX_DROP;

--------------000806080205050708050401--
