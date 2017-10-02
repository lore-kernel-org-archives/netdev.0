From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] bridge: add new BR_NEIGH_SUPPRESS port flag to suppress arp and nd flood
Date: Sun,  1 Oct 2017 21:36:56 -0700
Message-ID: <1506919018-27875-2-git-send-email-roopa@cumulusnetworks.com>
References: <1506919018-27875-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:50976 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751101AbdJBEhE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 00:37:04 -0400
Received: by mail-pf0-f173.google.com with SMTP id m63so2353907pfk.7
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 21:37:04 -0700 (PDT)
In-Reply-To: <1506919018-27875-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds a new bridge port flag BR_NEIGH_SUPPRESS to
suppress arp and nd flood on bridge ports. It implements
rfc7432, section 10.
https://tools.ietf.org/html/rfc7432#section-10
for ethernet VPN deployments. It is similar to the existing
BR_ARP_PROXY flag but has a few semantic differences to conform
to EVPN standard. In case of EVPN, it is mainly used to
avoid flooding to tunnel ports like vxlan. Unlike the existing
flags it suppresses flood of all neigh discovery packets
(arp, nd) to tunnel ports.

This patch adds netlink and sysfs support to set this bridge port
flag.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/if_bridge.h    |  1 +
 include/uapi/linux/if_link.h |  1 +
 net/bridge/Makefile          |  2 +-
 net/bridge/br_arp_nd_proxy.c | 27 +++++++++++++++++++++++++++
 net/bridge/br_forward.c      |  3 ++-
 net/bridge/br_if.c           |  5 +++++
 net/bridge/br_netlink.c      | 16 +++++++++++++++-
 net/bridge/br_private.h      |  2 ++
 net/bridge/br_sysfs_if.c     |  2 ++
 9 files changed, 56 insertions(+), 3 deletions(-)
 create mode 100644 net/bridge/br_arp_nd_proxy.c

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 3cd18ac..316ee11 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -49,6 +49,7 @@ struct br_ip_list {
 #define BR_MULTICAST_TO_UNICAST	BIT(12)
 #define BR_VLAN_TUNNEL		BIT(13)
 #define BR_BCAST_FLOOD		BIT(14)
+#define BR_NEIGH_SUPPRESS	BIT(15)
 
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8d062c5..0882e86 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -325,6 +325,7 @@ enum {
 	IFLA_BRPORT_MCAST_TO_UCAST,
 	IFLA_BRPORT_VLAN_TUNNEL,
 	IFLA_BRPORT_BCAST_FLOOD,
+	IFLA_BRPORT_NEIGH_SUPPRESS,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 40b1ede..4aee55f 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_BRIDGE) += bridge.o
 bridge-y	:= br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
 			br_ioctl.o br_stp.o br_stp_bpdu.o \
 			br_stp_if.o br_stp_timer.o br_netlink.o \
-			br_netlink_tunnel.o
+			br_netlink_tunnel.o br_arp_nd_proxy.o
 
 bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
 
diff --git a/net/bridge/br_arp_nd_proxy.c b/net/bridge/br_arp_nd_proxy.c
new file mode 100644
index 0000000..e191bb5
--- /dev/null
+++ b/net/bridge/br_arp_nd_proxy.c
@@ -0,0 +1,27 @@
+/*
+ *	Handle bridge arp/nd proxy/suppress
+ *
+ *	Authors:
+ *	Roopa Prabhu		<roopa@cumulusnetworks.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include "br_private.h"
+
+void br_recalculate_neigh_suppress_enabled(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+
+	br->neigh_suppress_enabled = false;
+	list_for_each_entry(p, &br->port_list, list) {
+		if (p->flags & BR_NEIGH_SUPPRESS) {
+			br->neigh_suppress_enabled = true;
+			break;
+		}
+	}
+}
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 48fb174..7a50dc5 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -204,7 +204,8 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		/* Do not flood to ports that enable proxy ARP */
 		if (p->flags & BR_PROXYARP)
 			continue;
-		if ((p->flags & BR_PROXYARP_WIFI) &&
+		if ((p->flags & BR_PROXYARP_WIFI ||
+		     p->flags & BR_NEIGH_SUPPRESS) &&
 		    BR_INPUT_SKB_CB(skb)->proxyarp_replied)
 			continue;
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f3aef22..8f615d4 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -310,6 +310,8 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 		del_nbp(p);
 	}
 
+	br_recalculate_neigh_suppress_enabled(br);
+
 	br_fdb_delete_by_port(br, NULL, 0, 1);
 
 	cancel_delayed_work_sync(&br->gc_work);
@@ -653,4 +655,7 @@ void br_port_flags_change(struct net_bridge_port *p, unsigned long mask)
 
 	if (mask & BR_AUTO_MASK)
 		nbp_update_port_count(br);
+
+	if (mask & BR_NEIGH_SUPPRESS)
+		br_recalculate_neigh_suppress_enabled(br);
 }
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 3bc8907..abe1d8d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -138,6 +138,7 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP_WIFI */
 		+ nla_total_size(1)	/* IFLA_BRPORT_VLAN_TUNNEL */
+		+ nla_total_size(1)	/* IFLA_BRPORT_NEIGH_SUPPRESS */
 		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_ROOT_ID */
 		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_BRIDGE_ID */
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_DESIGNATED_PORT */
@@ -208,7 +209,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 		       p->topology_change_ack) ||
 	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending) ||
 	    nla_put_u8(skb, IFLA_BRPORT_VLAN_TUNNEL, !!(p->flags &
-							BR_VLAN_TUNNEL)))
+							BR_VLAN_TUNNEL)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_NEIGH_SUPPRESS, !!(p->flags &
+							BR_NEIGH_SUPPRESS)))
 		return -EMSGSIZE;
 
 	timerval = br_timer_value(&p->message_age_timer);
@@ -618,6 +621,9 @@ static int br_afspec(struct net_bridge *br,
 		}
 	}
 
+	if (p)
+		br_recalculate_neigh_suppress_enabled(p->br);
+
 	return err;
 }
 
@@ -689,6 +695,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
 	unsigned long old_flags = p->flags;
 	bool br_vlan_tunnel_old = false;
+	int neigh_suppress_old = 0;
 	int err;
 
 	err = br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
@@ -773,6 +780,13 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 			return err;
 	}
 #endif
+
+	neigh_suppress_old = (p->flags & BR_NEIGH_SUPPRESS);
+	br_set_port_flag(p, tb, IFLA_BRPORT_NEIGH_SUPPRESS,
+			 BR_NEIGH_SUPPRESS);
+	if (neigh_suppress_old != (p->flags & BR_NEIGH_SUPPRESS))
+		br_recalculate_neigh_suppress_enabled(p->br);
+
 	br_port_flags_change(p, old_flags ^ p->flags);
 	return 0;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e870cfc..7dacd83 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -396,6 +396,7 @@ struct net_bridge {
 #ifdef CONFIG_NET_SWITCHDEV
 	int offload_fwd_mark;
 #endif
+	bool				neigh_suppress_enabled;
 };
 
 struct br_input_skb_cb {
@@ -1130,4 +1131,5 @@ static inline void br_switchdev_frame_unmark(struct sk_buff *skb)
 }
 #endif /* CONFIG_NET_SWITCHDEV */
 
+void br_recalculate_neigh_suppress_enabled(struct net_bridge *br);
 #endif
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 5d5d413a..2467213 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -174,6 +174,7 @@ BRPORT_ATTR_FLAG(proxyarp, BR_PROXYARP);
 BRPORT_ATTR_FLAG(proxyarp_wifi, BR_PROXYARP_WIFI);
 BRPORT_ATTR_FLAG(multicast_flood, BR_MCAST_FLOOD);
 BRPORT_ATTR_FLAG(broadcast_flood, BR_BCAST_FLOOD);
+BRPORT_ATTR_FLAG(neigh_suppress, BR_NEIGH_SUPPRESS);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -223,6 +224,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_proxyarp_wifi,
 	&brport_attr_multicast_flood,
 	&brport_attr_broadcast_flood,
+	&brport_attr_neigh_suppress,
 	NULL
 };
 
-- 
2.1.4
