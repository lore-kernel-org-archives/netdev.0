From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH v2 net-next] bridge: add per-port broadcast flood flag
Date: Wed, 26 Apr 2017 14:48:09 +0100
Message-ID: <1493214489-9921-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:51257 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S3000613AbdDZNsb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:48:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for l2 multicast flood control was added in commit b6cb5ac8331b
("net: bridge: add per-port multicast flood flag"). It allows broadcast
as it was introduced specifically for unknown multicast flood control.
But as broadcast is a special case of multicast, this may also need to
be disabled. For this purpose, introduce a flag to disable the flooding
of received l2 broadcasts. This approach is backwards compatible and
provides flexibility in filtering for the desired packet types.

Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 include/linux/if_bridge.h    |  1 +
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_forward.c      | 24 +++++++++++++++++-------
 net/bridge/br_if.c           |  2 +-
 net/bridge/br_netlink.c      |  3 +++
 net/bridge/br_sysfs_if.c     |  2 ++
 6 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index c5847dc..0c16866 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -48,6 +48,7 @@ struct br_ip_list {
 #define BR_MCAST_FLOOD		BIT(11)
 #define BR_MULTICAST_TO_UNICAST	BIT(12)
 #define BR_VLAN_TUNNEL		BIT(13)
+#define BR_BCAST_FLOOD		BIT(14)
 
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 633aa02..8e56ac7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -323,6 +323,7 @@ enum {
 	IFLA_BRPORT_MCAST_FLOOD,
 	IFLA_BRPORT_MCAST_TO_UCAST,
 	IFLA_BRPORT_VLAN_TUNNEL,
+	IFLA_BRPORT_BCAST_FLOOD,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 902af6b..48fb174 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -183,13 +183,23 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	struct net_bridge_port *p;
 
 	list_for_each_entry_rcu(p, &br->port_list, list) {
-		/* Do not flood unicast traffic to ports that turn it off */
-		if (pkt_type == BR_PKT_UNICAST && !(p->flags & BR_FLOOD))
-			continue;
-		/* Do not flood if mc off, except for traffic we originate */
-		if (pkt_type == BR_PKT_MULTICAST &&
-		    !(p->flags & BR_MCAST_FLOOD) && skb->dev != br->dev)
-			continue;
+		/* Do not flood unicast traffic to ports that turn it off, nor
+		 * other traffic if flood off, except for traffic we originate
+		 */
+		switch (pkt_type) {
+		case BR_PKT_UNICAST:
+			if (!(p->flags & BR_FLOOD))
+				continue;
+			break;
+		case BR_PKT_MULTICAST:
+			if (!(p->flags & BR_MCAST_FLOOD) && skb->dev != br->dev)
+				continue;
+			break;
+		case BR_PKT_BROADCAST:
+			if (!(p->flags & BR_BCAST_FLOOD) && skb->dev != br->dev)
+				continue;
+			break;
+		}
 
 		/* Do not flood to ports that enable proxy ARP */
 		if (p->flags & BR_PROXYARP)
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 6d273ca..b436ea0 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -362,7 +362,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->path_cost = port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
-	p->flags = BR_LEARNING | BR_FLOOD | BR_MCAST_FLOOD;
+	p->flags = BR_LEARNING | BR_FLOOD | BR_MCAST_FLOOD | BR_BCAST_FLOOD;
 	br_init_port(p);
 	br_set_state(p, BR_STATE_DISABLED);
 	br_stp_port_timer_init(p);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 6509864..a572db71 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -189,6 +189,8 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 		       !!(p->flags & BR_FLOOD)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_MCAST_FLOOD,
 		       !!(p->flags & BR_MCAST_FLOOD)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_BCAST_FLOOD,
+		       !!(p->flags & BR_BCAST_FLOOD)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP, !!(p->flags & BR_PROXYARP)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROXYARP_WIFI,
 		       !!(p->flags & BR_PROXYARP_WIFI)) ||
@@ -683,6 +685,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_FLOOD, BR_MCAST_FLOOD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_TO_UCAST, BR_MULTICAST_TO_UNICAST);
+	br_set_port_flag(p, tb, IFLA_BRPORT_BCAST_FLOOD, BR_BCAST_FLOOD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 79aee75..5d5d413a 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -173,6 +173,7 @@ BRPORT_ATTR_FLAG(unicast_flood, BR_FLOOD);
 BRPORT_ATTR_FLAG(proxyarp, BR_PROXYARP);
 BRPORT_ATTR_FLAG(proxyarp_wifi, BR_PROXYARP_WIFI);
 BRPORT_ATTR_FLAG(multicast_flood, BR_MCAST_FLOOD);
+BRPORT_ATTR_FLAG(broadcast_flood, BR_BCAST_FLOOD);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -221,6 +222,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_proxyarp,
 	&brport_attr_proxyarp_wifi,
 	&brport_attr_multicast_flood,
+	&brport_attr_broadcast_flood,
 	NULL
 };
 
-- 
2.1.4
