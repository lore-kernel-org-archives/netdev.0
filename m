From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: uninline skb_bond_should_drop()
Date: Sun, 11 Apr 2010 18:56:11 +0200
Message-ID: <1271004971.2078.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:63600 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab0DKQ5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 12:57:09 -0400
Received: by bwz19 with SMTP id 19so2634bwz.21
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 09:57:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_bond_should_drop() is too big to be inlined.

This patch reduces kernel text size, and its compilation time as well
(shrinking include/linux/netdevice.h)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |   48 ++---------------------------------
 net/core/dev.c            |   49 ++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+), 44 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d1a21b5..470f7c9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2089,54 +2089,14 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
-static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
-					      struct net_device *master)
-{
-	if (skb->pkt_type == PACKET_HOST) {
-		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
-
-		memcpy(dest, master->dev_addr, ETH_ALEN);
-	}
-}
+extern int __skb_bond_should_drop(struct sk_buff *skb,
+				  struct net_device *master);
 
-/* On bonding slaves other than the currently active slave, suppress
- * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
- * ARP on active-backup slaves with arp_validate enabled.
- */
 static inline int skb_bond_should_drop(struct sk_buff *skb,
 				       struct net_device *master)
 {
-	if (master) {
-		struct net_device *dev = skb->dev;
-
-		if (master->priv_flags & IFF_MASTER_ARPMON)
-			dev->last_rx = jiffies;
-
-		if ((master->priv_flags & IFF_MASTER_ALB) && master->br_port) {
-			/* Do address unmangle. The local destination address
-			 * will be always the one master has. Provides the right
-			 * functionality in a bridge.
-			 */
-			skb_bond_set_mac_by_master(skb, master);
-		}
-
-		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
-			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
-			    skb->protocol == __cpu_to_be16(ETH_P_ARP))
-				return 0;
-
-			if (master->priv_flags & IFF_MASTER_ALB) {
-				if (skb->pkt_type != PACKET_BROADCAST &&
-				    skb->pkt_type != PACKET_MULTICAST)
-					return 0;
-			}
-			if (master->priv_flags & IFF_MASTER_8023AD &&
-			    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
-				return 0;
-
-			return 1;
-		}
-	}
+	if (master)
+		return __skb_bond_should_drop(skb, master);
 	return 0;
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b98ddc6..c5ca39d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2645,6 +2645,55 @@ void netif_nit_deliver(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
+static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
+					      struct net_device *master)
+{
+	if (skb->pkt_type == PACKET_HOST) {
+		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
+
+		memcpy(dest, master->dev_addr, ETH_ALEN);
+	}
+}
+
+/* On bonding slaves other than the currently active slave, suppress
+ * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
+ * ARP on active-backup slaves with arp_validate enabled.
+ */
+int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
+{
+	struct net_device *dev = skb->dev;
+
+	if (master->priv_flags & IFF_MASTER_ARPMON)
+		dev->last_rx = jiffies;
+
+	if ((master->priv_flags & IFF_MASTER_ALB) && master->br_port) {
+		/* Do address unmangle. The local destination address
+		 * will be always the one master has. Provides the right
+		 * functionality in a bridge.
+		 */
+		skb_bond_set_mac_by_master(skb, master);
+	}
+
+	if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
+		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
+		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
+			return 0;
+
+		if (master->priv_flags & IFF_MASTER_ALB) {
+			if (skb->pkt_type != PACKET_BROADCAST &&
+			    skb->pkt_type != PACKET_MULTICAST)
+				return 0;
+		}
+		if (master->priv_flags & IFF_MASTER_8023AD &&
+		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
+			return 0;
+
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(__skb_bond_should_drop);
+
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;


