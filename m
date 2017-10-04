From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v3 1/3] bridge: add new BR_NEIGH_SUPPRESS port flag to suppress arp and nd flood
Date: Tue,  3 Oct 2017 21:43:53 -0700
Message-ID: <1507092235-39876-2-git-send-email-roopa@cumulusnetworks.com>
References: <1507092235-39876-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:51319 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdJDEoN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:44:13 -0400
Received: by mail-pg0-f44.google.com with SMTP id u144so3209933pgb.8
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 21:44:13 -0700 (PDT)
In-Reply-To: <1507092235-39876-1-git-send-email-roopa@cumulusnetworks.com>
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
 net/bridge/br_arp_nd_proxy.c | 32 ++++++++++++++++++++++++++++++++
 net/bridge/br_forward.c      |  3 ++-
 net/bridge/br_if.c           |  5 +++++
 net/bridge/br_netlink.c      | 12 +++++++++++-
 net/bridge/br_private.h      |  2 ++
 net/bridge/br_sysfs_if.c     |  2 ++
 9 files changed, 57 insertions(+), 3 deletions(-)
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
index ea87bd7..0d51f4f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -326,6 +326,7 @@ enum {
 	IFLA_BRPORT_VLAN_TUNNEL,
 	IFLA_BRPORT_BCAST_FLOOD,
 	IFLA_BRPORT_GROUP_FWD_MASK,
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
index 0000000..f889ad5
--- /dev/null
+++ b/net/bridge/br_arp_nd_proxy.c
@@ -0,0 +1,32 @@
+/*
+ *  Handle bridge arp/nd proxy/suppress
+ *
+ *  Copyright (C) 2017 Cumulus Networks
+ *  Copyright (c) 2017 Roopa Prabhu <roopa@cumulusnetworks.com>
+ *
+ *  Authors:
+ *	Roopa Prabhu <roopa@cumulusnetworks.com>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version
+ *  2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include "br_private.h"
+
+void br_recalculate_neigh_suppress_enabled(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+	bool neigh_suppress = false;
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (p->flags & BR_NEIGH_SUPPRESS) {
+			neigh_suppress = true;
+			break;
+		}
+	}
+
+	br->neigh_suppress_enabled = neigh_suppress;
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
index dea88a2..d8c2706 100644
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
@@ -210,7 +211,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending) ||
 	    nla_put_u8(skb, IFLA_BRPORT_VLAN_TUNNEL, !!(p->flags &
 							BR_VLAN_TUNNEL)) ||
-	    nla_put_u16(skb, IFLA_BRPORT_GROUP_FWD_MASK, p->group_fwd_mask))
+	    nla_put_u16(skb, IFLA_BRPORT_GROUP_FWD_MASK, p->group_fwd_mask) ||
+	    nla_put_u8(skb, IFLA_BRPORT_NEIGH_SUPPRESS, !!(p->flags &
+							BR_NEIGH_SUPPRESS)))
 		return -EMSGSIZE;
 
 	timerval = br_timer_value(&p->message_age_timer);
@@ -692,6 +695,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
 	unsigned long old_flags = p->flags;
 	bool br_vlan_tunnel_old = false;
+	int neigh_suppress_old = 0;
 	int err;
 
 	err = br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
@@ -785,6 +789,12 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 		p->group_fwd_mask = fwd_mask;
 	}
 
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
index 020c709..f47332e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -404,6 +404,7 @@ struct net_bridge {
 #ifdef CONFIG_NET_SWITCHDEV
 	int offload_fwd_mark;
 #endif
+	bool				neigh_suppress_enabled;
 };
 
 struct br_input_skb_cb {
@@ -1138,4 +1139,5 @@ static inline void br_switchdev_frame_unmark(struct sk_buff *skb)
 }
 #endif /* CONFIG_NET_SWITCHDEV */
 
+void br_recalculate_neigh_suppress_enabled(struct net_bridge *br);
 #endif
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 9110d5e..0a1fa9c 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -191,6 +191,7 @@ BRPORT_ATTR_FLAG(proxyarp, BR_PROXYARP);
 BRPORT_ATTR_FLAG(proxyarp_wifi, BR_PROXYARP_WIFI);
 BRPORT_ATTR_FLAG(multicast_flood, BR_MCAST_FLOOD);
 BRPORT_ATTR_FLAG(broadcast_flood, BR_BCAST_FLOOD);
+BRPORT_ATTR_FLAG(neigh_suppress, BR_NEIGH_SUPPRESS);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -241,6 +242,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_multicast_flood,
 	&brport_attr_broadcast_flood,
 	&brport_attr_group_fwd_mask,
+	&brport_attr_neigh_suppress,
 	NULL
 };
 
-- 
2.1.4
