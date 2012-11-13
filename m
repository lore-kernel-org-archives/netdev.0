From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 3/4] bridge: implement BPDU blocking
Date: Tue, 13 Nov 2012 09:53:07 -0800
Message-ID: <20121113175346.664794574@vyatta.com>
References: <20121113175304.628996029@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:36666 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754821Ab2KMR57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 12:57:59 -0500
Content-Disposition: inline; filename=bridge-bpdu-guard.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is Linux bridge implementation of STP protection
(Cisco BPDU guard/Juniper BPDU block). BPDU block disables
the bridge port if a STP BPDU packet is received.

Why would you want to do this?
If running Spanning Tree on bridge, hostile devices on the network
may send BPDU and cause network failure. Enabling bpdu block
will detect and stop this.

How to recover the port?
The port will be restarted if link is brought down, or
removed and reattached.  For example:
 # ip li set dev eth0 down; ip li set dev eth0 up

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - refresh for earlier changes related to generic bridge setlink

 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_netlink.c      |    7 ++++++-
 net/bridge/br_private.h      |    1 +
 net/bridge/br_stp_bpdu.c     |    7 +++++++
 net/bridge/br_sysfs_if.c     |    2 ++
 5 files changed, 17 insertions(+), 1 deletion(-)

--- a/net/bridge/br_private.h	2012-11-12 07:58:45.000000000 -0800
+++ b/net/bridge/br_private.h	2012-11-12 13:52:51.858985336 -0800
@@ -135,6 +135,7 @@ struct net_bridge_port
 
 	unsigned long 			flags;
 #define BR_HAIRPIN_MODE		0x00000001
+#define BR_BPDU_GUARD           0x00000002
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
--- a/net/bridge/br_stp_bpdu.c	2012-11-12 07:58:35.000000000 -0800
+++ b/net/bridge/br_stp_bpdu.c	2012-11-12 13:52:51.858985336 -0800
@@ -170,6 +170,13 @@ void br_stp_rcv(const struct stp_proto *
 	if (!ether_addr_equal(dest, br->group_addr))
 		goto out;
 
+	if (p->flags & BR_BPDU_GUARD) {
+		br_notice(br, "BPDU received on blocked port %u(%s)\n",
+			  (unsigned int) p->port_no, p->dev->name);
+		br_stp_disable_port(p);
+		goto out;
+	}
+
 	buf = skb_pull(skb, 3);
 
 	if (buf[0] == BPDU_TYPE_CONFIG) {
--- a/net/bridge/br_sysfs_if.c	2012-11-12 13:52:42.000000000 -0800
+++ b/net/bridge/br_sysfs_if.c	2012-11-12 13:52:51.858985336 -0800
@@ -156,6 +156,7 @@ static int store_flush(struct net_bridge
 static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
 
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
+BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -189,6 +190,7 @@ static const struct brport_attribute *br
 	&brport_attr_hold_timer,
 	&brport_attr_flush,
 	&brport_attr_hairpin_mode,
+	&brport_attr_bpdu_guard,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 #endif
--- a/include/uapi/linux/if_link.h	2012-11-12 13:33:53.000000000 -0800
+++ b/include/uapi/linux/if_link.h	2012-11-12 13:52:51.858985336 -0800
@@ -216,6 +216,7 @@ enum {
 	IFLA_BRPORT_PRIORITY,	/* "             priority  */
 	IFLA_BRPORT_COST,	/* "             cost      */
 	IFLA_BRPORT_MODE,	/* mode (hairpin)          */
+	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
--- a/net/bridge/br_netlink.c	2012-11-12 13:51:37.000000000 -0800
+++ b/net/bridge/br_netlink.c	2012-11-12 13:53:19.694706427 -0800
@@ -26,6 +26,7 @@ static inline size_t br_port_info_size(v
 		+ nla_total_size(2)	/* IFLA_BRPORT_PRIORITY */
 		+ nla_total_size(4)	/* IFLA_BRPORT_COST */
 		+ nla_total_size(1)	/* IFLA_BRPORT_MODE */
+		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
 		+ 0;
 }
 
@@ -49,7 +50,8 @@ static int br_port_fill_attrs(struct sk_
 	if (nla_put_u8(skb, IFLA_BRPORT_STATE, p->state) ||
 	    nla_put_u16(skb, IFLA_BRPORT_PRIORITY, p->priority) ||
 	    nla_put_u32(skb, IFLA_BRPORT_COST, p->path_cost) ||
-	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode))
+	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode) ||
+	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -162,6 +164,7 @@ static const struct nla_policy ifla_brpo
 	[IFLA_BRPORT_COST]	= { .type = NLA_U32 },
 	[IFLA_BRPORT_PRIORITY]	= { .type = NLA_U16 },
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -203,6 +206,7 @@ static int br_setport(struct net_bridge_
 	int err;
 
 	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
+	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
