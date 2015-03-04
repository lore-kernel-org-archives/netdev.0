From: Jouni Malinen <jouni@codeaurora.org>
Subject: [PATCH] bridge: Extend Proxy ARP design to allow optional rules for Wi-Fi
Date: Wed,  4 Mar 2015 12:54:21 +0200
Message-ID: <1425466461-1371-1-git-send-email-jouni@codeaurora.org>
Cc: netdev@vger.kernel.org, Jouni Malinen <jouni@codeaurora.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60300 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061AbbCDKyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 05:54:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extends the design in commit 958501163ddd ("bridge: Add support for
IEEE 802.11 Proxy ARP") with optional set of rules that are needed to
meet the IEEE 802.11 and Hotspot 2.0 requirements for ProxyARP. The
previously added BR_PROXYARP behavior is left as-is and a new
BR_PROXYARP_WIFI alternative is added so that this behavior can be
configured from user space when required.

In addition, this enables proxyarp functionality for unicast ARP
requests for both BR_PROXYARP and BR_PROXYARP_WIFI since it is possible
to use unicast as well as broadcast for these frames.

The key differences in functionality:

BR_PROXYARP:
- uses the flag on the bridge port on which the request frame was
  received to determine whether to reply
- block bridge port flooding completely on ports that enable proxy ARP

BR_PROXYARP_WIFI:
- uses the flag on the bridge port to which the target device of the
  request belongs
- block bridge port flooding selectively based on whether the proxyarp
  functionality replied

Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
---
Note:

This version supersedes the earlier set of the patches listed below
based on the review comment requesting the new behavior to be made
separately configurable instead of modifying the existing BR_PROXYARP
functionality.

bridge: Base the BR_PROXYARP decision on the target port flag
bridge: Selectively prevent bridge port flooding for proxy ARP
bridge: Allow proxy ARP for unicast ARP requests

 include/linux/if_bridge.h    |  1 +
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_forward.c      |  3 +++
 net/bridge/br_input.c        | 17 ++++++++++-------
 net/bridge/br_netlink.c      |  5 ++++-
 net/bridge/br_private.h      |  1 +
 net/bridge/br_sysfs_if.c     |  2 ++
 7 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index a57bca2..dad8b00 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -44,6 +44,7 @@ struct br_ip_list {
 #define BR_PROMISC		BIT(7)
 #define BR_PROXYARP		BIT(8)
 #define BR_LEARNING_SYNC	BIT(9)
+#define BR_PROXYARP_WIFI	BIT(10)
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index dfd0bb2..756436e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -247,6 +247,7 @@ enum {
 	IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
 	IFLA_BRPORT_PROXYARP,	/* proxy ARP */
 	IFLA_BRPORT_LEARNING_SYNC, /* mac learning sync from device */
+	IFLA_BRPORT_PROXYARP_WIFI, /* proxy ARP for Wi-Fi */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index f96933a..1238fab 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -188,6 +188,9 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		/* Do not flood to ports that enable proxy ARP */
 		if (p->flags & BR_PROXYARP)
 			continue;
+		if ((p->flags & BR_PROXYARP_WIFI) &&
+		    BR_INPUT_SKB_CB(skb)->proxyarp_replied)
+			continue;
 
 		prev = maybe_deliver(prev, p, skb, __packet_hook);
 		if (IS_ERR(prev))
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index e2aa7be..052c5eb 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -60,7 +60,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 }
 
 static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
-			    u16 vid)
+			    u16 vid, struct net_bridge_port *p)
 {
 	struct net_device *dev = br->dev;
 	struct neighbour *n;
@@ -68,6 +68,8 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 	u8 *arpptr, *sha;
 	__be32 sip, tip;
 
+	BR_INPUT_SKB_CB(skb)->proxyarp_replied = false;
+
 	if (dev->flags & IFF_NOARP)
 		return;
 
@@ -105,9 +107,12 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 		}
 
 		f = __br_fdb_get(br, n->ha, vid);
-		if (f)
+		if (f && ((p->flags & BR_PROXYARP) ||
+			  (f->dst && (f->dst->flags & BR_PROXYARP_WIFI)))) {
 			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, skb->dev, tip,
 				 sha, n->ha, sha);
+			BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+		}
 
 		neigh_release(n);
 	}
@@ -153,12 +158,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	dst = NULL;
 
-	if (is_broadcast_ether_addr(dest)) {
-		if (IS_ENABLED(CONFIG_INET) &&
-		    p->flags & BR_PROXYARP &&
-		    skb->protocol == htons(ETH_P_ARP))
-			br_do_proxy_arp(skb, br, vid);
+	if (IS_ENABLED(CONFIG_INET) && skb->protocol == htons(ETH_P_ARP))
+		br_do_proxy_arp(skb, br, vid, p);
 
+	if (is_broadcast_ether_addr(dest)) {
 		skb2 = skb;
 		unicast = false;
 	} else if (is_multicast_ether_addr(dest)) {
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index c720839..8bc6b67 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -143,7 +143,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)))
+	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP_WIFI,
+		       !!(p->flags & BR_PROXYARP_WIFI)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -553,6 +555,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
 	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
+	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index de09199..c32e279 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -305,6 +305,7 @@ struct br_input_skb_cb {
 #endif
 
 	u16 frag_max_size;
+	bool proxyarp_replied;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	bool vlan_filtered;
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 2de5d91..4905845 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -171,6 +171,7 @@ BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
 BRPORT_ATTR_FLAG(learning, BR_LEARNING);
 BRPORT_ATTR_FLAG(unicast_flood, BR_FLOOD);
 BRPORT_ATTR_FLAG(proxyarp, BR_PROXYARP);
+BRPORT_ATTR_FLAG(proxyarp_wifi, BR_PROXYARP_WIFI);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -215,6 +216,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_multicast_fast_leave,
 #endif
 	&brport_attr_proxyarp,
+	&brport_attr_proxyarp_wifi,
 	NULL
 };
 
-- 
1.9.1
