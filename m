From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 3/8] bridge: implement BPDU blocking
Date: Mon, 29 Oct 2012 17:57:34 -0700
Message-ID: <20121030005835.462418417@vyatta.com>
References: <20121030005731.843020405@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:35098 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761788Ab2J3BGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 21:06:14 -0400
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
 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_netlink.c      |    7 ++++++-
 net/bridge/br_private.h      |    1 +
 net/bridge/br_stp_bpdu.c     |    7 +++++++
 net/bridge/br_sysfs_if.c     |    2 ++
 5 files changed, 17 insertions(+), 1 deletion(-)

--- a/net/bridge/br_private.h	2012-10-29 17:07:08.005982838 -0700
+++ b/net/bridge/br_private.h	2012-10-29 17:37:20.959775346 -0700
@@ -135,6 +135,7 @@ struct net_bridge_port
 
 	unsigned long 			flags;
 #define BR_HAIRPIN_MODE		0x00000001
+#define BR_BPDU_GUARD           0x00000002
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
--- a/net/bridge/br_stp_bpdu.c	2012-10-29 17:07:08.005982838 -0700
+++ b/net/bridge/br_stp_bpdu.c	2012-10-29 17:31:14.327457434 -0700
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
--- a/net/bridge/br_sysfs_if.c	2012-10-29 17:19:30.562525344 -0700
+++ b/net/bridge/br_sysfs_if.c	2012-10-29 17:37:38.207602125 -0700
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
+	&brport_attr_bpdu_block,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 #endif
--- a/include/uapi/linux/if_link.h	2012-10-29 17:07:14.713915471 -0700
+++ b/include/uapi/linux/if_link.h	2012-10-29 17:37:20.959775346 -0700
@@ -216,6 +216,7 @@ enum {
 	IFLA_BRPORT_PRIORITY,	/* "             priority  */
 	IFLA_BRPORT_COST,	/* "             cost      */
 	IFLA_BRPORT_MODE,	/* mode (hairpin)          */
+	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
--- a/net/bridge/br_netlink.c	2012-10-29 17:09:23.520621865 -0700
+++ b/net/bridge/br_netlink.c	2012-10-29 17:37:20.959775346 -0700
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
@@ -176,6 +178,7 @@ static const struct nla_policy ifla_brpo
 	[IFLA_BRPORT_COST]	= { .type = NLA_U16 },
 	[IFLA_BRPORT_PRIORITY]	= { .type = NLA_U32 },
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 };
 
 /* Change state of port (ie from forwarding to blocking etc)
@@ -218,6 +221,7 @@ static int br_rtm_protinfo(struct net_br
 	int err;
 
 	br_rtm_setflag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
+	br_rtm_setflag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
