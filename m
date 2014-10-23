From: Kyeyoon Park <kyeyoonp@qca.qualcomm.com>
Subject: [PATCH] bridge: Add support for IEEE 802.11 Proxy ARP
Date: Thu, 23 Oct 2014 14:49:17 -0700
Message-ID: <1414100957-8288-1-git-send-email-kyeyoonp@qca.qualcomm.com>
Cc: kyeyoonp@qca.qualcomm.com, jouni@qca.qualcomm.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:47410 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbaJWVt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 17:49:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeyoon Park <kyeyoonp@codeaurora.org>

This feature is defined in IEEE Std 802.11-2012, 10.23.13. It allows
the AP devices to keep track of the hardware-address-to-IP-address
mapping of the mobile devices within the WLAN network.

The AP will learn this mapping via observing DHCP, ARP, and NS/NA
frames. When a request for such information is made (i.e. ARP request,
Neighbor Solicitation), the AP will respond on behalf of the
associated mobile device. In the process of doing so, the AP will drop
the multicast request frame that was intended to go out to the wireless
medium.

It was recommended at the LKS workshop to do this implementation in
the bridge layer. vxlan.c is already doing something very similar.
The DHCP snooping code will be added to the userspace application
(hostapd) per the recommendation.

This RFC commit is only for IPv4. A similar approach in the bridge
layer will be taken for IPv6 as well.

Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_forward.c      |  5 ++++
 net/bridge/br_input.c        | 60 ++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_netlink.c      |  4 ++-
 net/bridge/br_private.h      |  1 +
 net/bridge/br_sysfs_if.c     |  2 ++
 6 files changed, 72 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ff95760..62a17e0 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -231,6 +231,7 @@ enum {
 	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
 	IFLA_BRPORT_LEARNING,	/* mac learning */
 	IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
+	IFLA_BRPORT_PROXYARP,	/* proxy ARP */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 056b67b..61d9edf 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -181,6 +181,11 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		/* Do not flood unicast traffic to ports that turn it off */
 		if (unicast && !(p->flags & BR_FLOOD))
 			continue;
+
+		/* Do not flood to ports that enable proxy ARP */
+		if (p->flags & BR_PROXYARP)
+			continue;
+
 		prev = maybe_deliver(prev, p, skb, __packet_hook);
 		if (IS_ERR(prev))
 			goto out;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 366c436..a548fbf 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -16,6 +16,8 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/netfilter_bridge.h>
+#include <linux/neighbour.h>
+#include <net/arp.h>
 #include <linux/export.h>
 #include <linux/rculist.h>
 #include "br_private.h"
@@ -57,6 +59,60 @@ static int br_pass_frame_up(struct sk_buff *skb)
 		       netif_receive_skb);
 }
 
+static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
+			    u16 vid)
+{
+	struct net_device *dev = br->dev;
+	struct neighbour *n;
+	struct arphdr *parp;
+	u8 *arpptr, *sha;
+	__be32 sip, tip;
+
+	if (dev->flags & IFF_NOARP)
+		return;
+
+	if (!pskb_may_pull(skb, arp_hdr_len(dev))) {
+		dev->stats.tx_dropped++;
+		return;
+	}
+	parp = arp_hdr(skb);
+
+	if (parp->ar_pro != htons(ETH_P_IP) ||
+	    parp->ar_op != htons(ARPOP_REQUEST) ||
+	    parp->ar_hln != dev->addr_len ||
+	    parp->ar_pln != 4)
+		return;
+
+	arpptr = (u8 *)parp + sizeof(struct arphdr);
+	sha = arpptr;
+	arpptr += dev->addr_len;	/* sha */
+	memcpy(&sip, arpptr, sizeof(sip));
+	arpptr += sizeof(sip);
+	arpptr += dev->addr_len;	/* tha */
+	memcpy(&tip, arpptr, sizeof(tip));
+
+	if (ipv4_is_loopback(tip) ||
+	    ipv4_is_multicast(tip))
+		return;
+
+	n = neigh_lookup(&arp_tbl, &tip, dev);
+	if (n) {
+		struct net_bridge_fdb_entry *f;
+
+		if (!(n->nud_state & NUD_VALID)) {
+			neigh_release(n);
+			return;
+		}
+
+		f = __br_fdb_get(br, n->ha, vid);
+		if (f)
+			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, skb->dev, tip,
+				 sha, n->ha, sha);
+
+		neigh_release(n);
+	}
+}
+
 /* note: already called with rcu_read_lock */
 int br_handle_frame_finish(struct sk_buff *skb)
 {
@@ -98,6 +154,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	dst = NULL;
 
 	if (is_broadcast_ether_addr(dest)) {
+		if (p->flags & BR_PROXYARP &&
+		    skb->protocol == htons(ETH_P_ARP))
+			br_do_proxy_arp(skb, br, vid);
+
 		skb2 = skb;
 		unicast = false;
 	} else if (is_multicast_ether_addr(dest)) {
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index cb5fcf6..caa6857 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -60,7 +60,8 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)))
+	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -335,6 +336,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
 	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
 	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
+	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b6c04cb..666c6bc 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -172,6 +172,7 @@ struct net_bridge_port
 #define BR_FLOOD		0x00000040
 #define BR_AUTO_MASK (BR_FLOOD | BR_LEARNING)
 #define BR_PROMISC		0x00000080
+#define BR_PROXYARP		0x00000100
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	struct bridge_mcast_own_query	ip4_own_query;
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index e561cd5..2de5d91 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -170,6 +170,7 @@ BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
 BRPORT_ATTR_FLAG(learning, BR_LEARNING);
 BRPORT_ATTR_FLAG(unicast_flood, BR_FLOOD);
+BRPORT_ATTR_FLAG(proxyarp, BR_PROXYARP);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -213,6 +214,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,
 #endif
+	&brport_attr_proxyarp,
 	NULL
 };
 
-- 
1.9.1
