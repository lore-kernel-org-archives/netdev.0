From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v4 net] bridge: use is_skb_forwardable in forward path
Date: Thu, 27 Mar 2014 21:49:10 -0400
Message-ID: <1395971350-10559-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757249AbaC1BtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 21:49:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use existing function instead of trying to use our own.  This allows
us to better handle Q-in-Q packets.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
v2: Fix missing hunk in patch 2/2 to make it build.

v3: Fix indent for is_skb_forwardable

v4: Made is_skb_forwardable inline in netdevice.h and squashed
    the 2 patches into one since having 2 doesn't make much sense
    any more.

 include/linux/netdevice.h | 24 ++++++++++++++++++++++++
 net/bridge/br_forward.c   |  9 ++-------
 net/core/dev.c            | 21 ---------------------
 3 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e8eeebd..5d07fee 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3146,6 +3146,30 @@ static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
 	skb->mac_len = mac_len;
 }
 
+
+#include <linux/if_vlan.h>
+
+static inline bool is_skb_forwardable(struct net_device *dev,
+				      struct sk_buff *skb)
+{
+	unsigned int len;
+
+	if (!(dev->flags & IFF_UP))
+		return false;
+
+	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
+	if (skb->len <= len)
+		return true;
+
+	/* if TSO is enabled, we don't care about the length as the packet
+	 * could be forwarded without being segmented before
+	 */
+	if (skb_is_gso(skb))
+		return true;
+
+	return false;
+}
+
 static inline bool netif_is_macvlan(struct net_device *dev)
 {
 	return dev->priv_flags & IFF_MACVLAN;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d3409e6..056b67b 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -35,16 +35,11 @@ static inline int should_deliver(const struct net_bridge_port *p,
 		p->state == BR_STATE_FORWARDING;
 }
 
-static inline unsigned int packet_length(const struct sk_buff *skb)
-{
-	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
-}
-
 int br_dev_queue_push_xmit(struct sk_buff *skb)
 {
 	/* ip_fragment doesn't copy the MAC header */
 	if (nf_bridge_maybe_copy_header(skb) ||
-	    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
+	    !is_skb_forwardable(skb->dev, skb)) {
 		kfree_skb(skb);
 	} else {
 		skb_push(skb, ETH_HLEN);
@@ -71,7 +66,7 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 
 	if (unlikely(netpoll_tx_running(to->br->dev))) {
-		if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
+		if (!is_skb_forwardable(skb->dev, skb))
 			kfree_skb(skb);
 		else {
 			skb_push(skb, ETH_HLEN);
diff --git a/net/core/dev.c b/net/core/dev.c
index b1b0c8d..3e4a965 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1645,27 +1645,6 @@ static inline void net_timestamp_set(struct sk_buff *skb)
 			__net_timestamp(SKB);		\
 	}						\
 
-static inline bool is_skb_forwardable(struct net_device *dev,
-				      struct sk_buff *skb)
-{
-	unsigned int len;
-
-	if (!(dev->flags & IFF_UP))
-		return false;
-
-	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
-	if (skb->len <= len)
-		return true;
-
-	/* if TSO is enabled, we don't care about the length as the packet
-	 * could be forwarded without being segmented before
-	 */
-	if (skb_is_gso(skb))
-		return true;
-
-	return false;
-}
-
 /**
  * dev_forward_skb - loopback an skb to another netif
  *
-- 
1.8.5.3
