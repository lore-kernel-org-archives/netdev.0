From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: bridge: add per-port group_fwd_mask with less restrictions
Date: Wed, 27 Sep 2017 16:12:44 +0300
Message-ID: <1506517964-17479-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
        stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:46477 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751959AbdI0NOK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 09:14:10 -0400
Received: by mail-wm0-f50.google.com with SMTP id m72so18207247wmc.1
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 06:14:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to be able to transparently forward most link-local frames via
tunnels (e.g. vxlan, qinq). Currently the bridge's group_fwd_mask has a
mask which restricts the forwarding of STP and LACP, but we need to be able
to forward these over tunnels and control that forwarding on a per-port
basis thus add a new per-port group_fwd_mask option which only disallows
mac pause frames to be forwarded (they're always dropped anyway).
The patch does not change the current default situation - all of the others
are still restricted unless configured for forwarding.
We have successfully tested this patch with LACP and STP forwarding over
VxLAN and qinq tunnels.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
note: I left the permissions like this to be consistent with all the other
port options.

 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_input.c        |  1 +
 net/bridge/br_netlink.c      | 14 +++++++++++++-
 net/bridge/br_private.h      | 10 +++++++++-
 net/bridge/br_sysfs_if.c     | 18 ++++++++++++++++++
 5 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8d062c58d5cb..ea87bd708ee9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -325,6 +325,7 @@ enum {
 	IFLA_BRPORT_MCAST_TO_UCAST,
 	IFLA_BRPORT_VLAN_TUNNEL,
 	IFLA_BRPORT_BCAST_FLOOD,
+	IFLA_BRPORT_GROUP_FWD_MASK,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7637f58c1226..7cb613776b31 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -289,6 +289,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		 *
 		 * Others reserved for future standardization
 		 */
+		fwd_mask |= p->group_fwd_mask;
 		switch (dest[5]) {
 		case 0x00:	/* Bridge Group Address */
 			/* If STP is turned off,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 3bc890716c89..dea88a255d26 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -152,6 +152,7 @@ static inline size_t br_port_info_size(void)
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 		+ nla_total_size(sizeof(u8))	/* IFLA_BRPORT_MULTICAST_ROUTER */
 #endif
+		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_GROUP_FWD_MASK */
 		+ 0;
 }
 
@@ -208,7 +209,8 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 		       p->topology_change_ack) ||
 	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending) ||
 	    nla_put_u8(skb, IFLA_BRPORT_VLAN_TUNNEL, !!(p->flags &
-							BR_VLAN_TUNNEL)))
+							BR_VLAN_TUNNEL)) ||
+	    nla_put_u16(skb, IFLA_BRPORT_GROUP_FWD_MASK, p->group_fwd_mask))
 		return -EMSGSIZE;
 
 	timerval = br_timer_value(&p->message_age_timer);
@@ -637,6 +639,7 @@ static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_MCAST_TO_UCAST] = { .type = NLA_U8 },
 	[IFLA_BRPORT_MCAST_FLOOD] = { .type = NLA_U8 },
 	[IFLA_BRPORT_BCAST_FLOOD] = { .type = NLA_U8 },
+	[IFLA_BRPORT_GROUP_FWD_MASK] = { .type = NLA_U16 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -773,6 +776,15 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 			return err;
 	}
 #endif
+
+	if (tb[IFLA_BRPORT_GROUP_FWD_MASK]) {
+		u16 fwd_mask = nla_get_u16(tb[IFLA_BRPORT_GROUP_FWD_MASK]);
+
+		if (fwd_mask & BR_GROUPFWD_MACPAUSE)
+			return -EINVAL;
+		p->group_fwd_mask = fwd_mask;
+	}
+
 	br_port_flags_change(p, old_flags ^ p->flags);
 	return 0;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e870cfc85b14..020c709a017f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -36,7 +36,14 @@
 /* Control of forwarding link local multicast */
 #define BR_GROUPFWD_DEFAULT	0
 /* Don't allow forwarding of control protocols like STP, MAC PAUSE and LACP */
-#define BR_GROUPFWD_RESTRICTED	0x0007u
+enum {
+	BR_GROUPFWD_STP		= BIT(0),
+	BR_GROUPFWD_MACPAUSE	= BIT(1),
+	BR_GROUPFWD_LACP	= BIT(2),
+};
+
+#define BR_GROUPFWD_RESTRICTED (BR_GROUPFWD_STP | BR_GROUPFWD_MACPAUSE | \
+				BR_GROUPFWD_LACP)
 /* The Nearest Customer Bridge Group Address, 01-80-C2-00-00-[00,0B,0C,0D,0F] */
 #define BR_GROUPFWD_8021AD	0xB801u
 
@@ -268,6 +275,7 @@ struct net_bridge_port {
 #ifdef CONFIG_NET_SWITCHDEV
 	int				offload_fwd_mark;
 #endif
+	u16				group_fwd_mask;
 };
 
 #define br_auto_port(p) ((p)->flags & BR_AUTO_MASK)
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 5d5d413a6cf8..9110d5e56085 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -165,6 +165,23 @@ static int store_flush(struct net_bridge_port *p, unsigned long v)
 }
 static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
 
+static ssize_t show_group_fwd_mask(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%#x\n", p->group_fwd_mask);
+}
+
+static int store_group_fwd_mask(struct net_bridge_port *p,
+				unsigned long v)
+{
+	if (v & BR_GROUPFWD_MACPAUSE)
+		return -EINVAL;
+	p->group_fwd_mask = v;
+
+	return 0;
+}
+static BRPORT_ATTR(group_fwd_mask, S_IRUGO | S_IWUSR, show_group_fwd_mask,
+		   store_group_fwd_mask);
+
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
@@ -223,6 +240,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_proxyarp_wifi,
 	&brport_attr_multicast_flood,
 	&brport_attr_broadcast_flood,
+	&brport_attr_group_fwd_mask,
 	NULL
 };
 
-- 
2.1.4
