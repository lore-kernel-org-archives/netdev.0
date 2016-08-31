From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v3 2/2] net: bridge: add per-port multicast flood flag
Date: Wed, 31 Aug 2016 15:36:52 +0200
Message-ID: <1472650612-2123-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1472650612-2123-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37676 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933787AbcHaNhI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 09:37:08 -0400
Received: by mail-wm0-f42.google.com with SMTP id i5so90411192wmg.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 06:37:07 -0700 (PDT)
In-Reply-To: <1472650612-2123-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a per-port flag to control the unknown multicast flood, similar to the
unknown unicast flood flag and break a few long lines in the netlink flag
exports.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v3: don't change br_auto_mask
v2: no change

 include/linux/if_bridge.h    |  1 +
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_forward.c      |  3 +++
 net/bridge/br_if.c           |  2 +-
 net/bridge/br_netlink.c      | 12 +++++++++---
 net/bridge/br_sysfs_if.c     |  1 +
 6 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index dcb89e3515db..c6587c01d951 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -45,6 +45,7 @@ struct br_ip_list {
 #define BR_PROXYARP		BIT(8)
 #define BR_LEARNING_SYNC	BIT(9)
 #define BR_PROXYARP_WIFI	BIT(10)
+#define BR_MCAST_FLOOD		BIT(11)
 
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a1b5202c5f6b..9bf3aecfe05b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -318,6 +318,7 @@ enum {
 	IFLA_BRPORT_FLUSH,
 	IFLA_BRPORT_MULTICAST_ROUTER,
 	IFLA_BRPORT_PAD,
+	IFLA_BRPORT_MCAST_FLOOD,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 5de854ed3340..7cb41aee4c82 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -186,6 +186,9 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		/* Do not flood unicast traffic to ports that turn it off */
 		if (pkt_type == BR_PKT_UNICAST && !(p->flags & BR_FLOOD))
 			continue;
+		if (pkt_type == BR_PKT_MULTICAST &&
+		    !(p->flags & BR_MCAST_FLOOD))
+			continue;
 
 		/* Do not flood to ports that enable proxy ARP */
 		if (p->flags & BR_PROXYARP)
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1da3221845f1..ed0dd3340084 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -362,7 +362,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->path_cost = port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
-	p->flags = BR_LEARNING | BR_FLOOD;
+	p->flags = BR_LEARNING | BR_FLOOD | BR_MCAST_FLOOD;
 	br_init_port(p);
 	br_set_state(p, BR_STATE_DISABLED);
 	br_stp_port_timer_init(p);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 190a5bc00f4a..e99037c6f7b7 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -169,10 +169,15 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u32(skb, IFLA_BRPORT_COST, p->path_cost) ||
 	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode) ||
 	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_PROTECT,
+		       !!(p->flags & BR_ROOT_BLOCK)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE,
+		       !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD,
+		       !!(p->flags & BR_FLOOD)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_MCAST_FLOOD,
+		       !!(p->flags & BR_MCAST_FLOOD)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP_WIFI,
 		       !!(p->flags & BR_PROXYARP_WIFI)) ||
@@ -630,6 +635,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
 	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
 	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
+	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_FLOOD, BR_MCAST_FLOOD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 1e04d4d44273..e657258e1f2c 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -171,6 +171,7 @@ BRPORT_ATTR_FLAG(learning, BR_LEARNING);
 BRPORT_ATTR_FLAG(unicast_flood, BR_FLOOD);
 BRPORT_ATTR_FLAG(proxyarp, BR_PROXYARP);
 BRPORT_ATTR_FLAG(proxyarp_wifi, BR_PROXYARP_WIFI);
+BRPORT_ATTR_FLAG(multicast_flood, BR_MCAST_FLOOD);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
-- 
2.1.4
