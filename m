From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 4/4] bridge: add root port blocking
Date: Tue, 13 Nov 2012 09:53:08 -0800
Message-ID: <20121113175346.739328044@vyatta.com>
References: <20121113175304.628996029@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:36669 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754519Ab2KMR56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 12:57:58 -0500
Content-Disposition: inline; filename=bridge-root-block.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is Linux bridge implementation of root port guard.
If BPDU is received from a leaf (edge) port, it should not
be elected as root port.

Why would you want to do this?
If using STP on a bridge and the downstream bridges are not fully
trusted; this prevents a hostile guest for rerouting traffic.

Why not just use netfilter?
Netfilter does not track of follow spanning tree decisions.
It would be difficult and error prone to try and mirror STP
resolution in netfilter module.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_netlink.c      |    6 +++++-
 net/bridge/br_private.h      |    1 +
 net/bridge/br_stp.c          |   22 +++++++++++++++++++++-
 net/bridge/br_sysfs_if.c     |    2 ++
 5 files changed, 30 insertions(+), 2 deletions(-)

--- a/net/bridge/br_private.h	2012-11-12 13:52:51.858985336 -0800
+++ b/net/bridge/br_private.h	2012-11-12 13:54:52.309778448 -0800
@@ -136,6 +136,7 @@ struct net_bridge_port
 	unsigned long 			flags;
 #define BR_HAIRPIN_MODE		0x00000001
 #define BR_BPDU_GUARD           0x00000002
+#define BR_ROOT_BLOCK		0x00000004
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
--- a/net/bridge/br_stp.c	2012-11-12 07:58:31.067183169 -0800
+++ b/net/bridge/br_stp.c	2012-11-12 13:53:27.254630683 -0800
@@ -100,6 +100,21 @@ static int br_should_become_root_port(co
 	return 0;
 }
 
+static void br_root_port_block(const struct net_bridge *br,
+			       struct net_bridge_port *p)
+{
+
+	br_notice(br, "port %u(%s) tried to become root port (blocked)",
+		  (unsigned int) p->port_no, p->dev->name);
+
+	p->state = BR_STATE_LISTENING;
+	br_log_state(p);
+	br_ifinfo_notify(RTM_NEWLINK, p);
+
+	if (br->forward_delay > 0)
+		mod_timer(&p->forward_delay_timer, jiffies + br->forward_delay);
+}
+
 /* called under bridge lock */
 static void br_root_selection(struct net_bridge *br)
 {
@@ -107,7 +122,12 @@ static void br_root_selection(struct net
 	u16 root_port = 0;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (br_should_become_root_port(p, root_port))
+		if (!br_should_become_root_port(p, root_port))
+			continue;
+
+		if (p->flags & BR_ROOT_BLOCK)
+			br_root_port_block(br, p);
+		else
 			root_port = p->port_no;
 	}
 
--- a/net/bridge/br_sysfs_if.c	2012-11-12 13:52:51.858985336 -0800
+++ b/net/bridge/br_sysfs_if.c	2012-11-12 13:54:52.309778448 -0800
@@ -157,6 +157,7 @@ static BRPORT_ATTR(flush, S_IWUSR, NULL,
 
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
+BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -191,6 +192,7 @@ static const struct brport_attribute *br
 	&brport_attr_flush,
 	&brport_attr_hairpin_mode,
 	&brport_attr_bpdu_guard,
+	&brport_attr_root_block,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 #endif
--- a/include/uapi/linux/if_link.h	2012-11-12 13:52:51.858985336 -0800
+++ b/include/uapi/linux/if_link.h	2012-11-12 13:54:52.309778448 -0800
@@ -217,6 +217,7 @@ enum {
 	IFLA_BRPORT_COST,	/* "             cost      */
 	IFLA_BRPORT_MODE,	/* mode (hairpin)          */
 	IFLA_BRPORT_GUARD,	/* bpdu guard              */
+	IFLA_BRPORT_PROTECT,	/* root port protection    */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
--- a/net/bridge/br_netlink.c	2012-11-12 13:53:19.694706427 -0800
+++ b/net/bridge/br_netlink.c	2012-11-12 13:54:52.309778448 -0800
@@ -27,6 +27,7 @@ static inline size_t br_port_info_size(v
 		+ nla_total_size(4)	/* IFLA_BRPORT_COST */
 		+ nla_total_size(1)	/* IFLA_BRPORT_MODE */
 		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
+		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
 		+ 0;
 }
 
@@ -51,7 +52,8 @@ static int br_port_fill_attrs(struct sk_
 	    nla_put_u16(skb, IFLA_BRPORT_PRIORITY, p->priority) ||
 	    nla_put_u32(skb, IFLA_BRPORT_COST, p->path_cost) ||
 	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode) ||
-	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)))
+	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -165,6 +167,7 @@ static const struct nla_policy ifla_brpo
 	[IFLA_BRPORT_PRIORITY]	= { .type = NLA_U16 },
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
