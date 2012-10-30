From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 5/8] bridge: add bpdu filter
Date: Mon, 29 Oct 2012 17:57:36 -0700
Message-ID: <20121030005835.640128316@vyatta.com>
References: <20121030005731.843020405@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:35109 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759046Ab2J3BGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 21:06:14 -0400
Content-Disposition: inline; filename=bridge-filter.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPDU filter allows spanning tree to be disabled for a bridge
but not send or receive BPDU packets on a specific port. A common
usage of this to turn on spanning tree (so that bridge can talk
to other bridges), but turn off STP packets to leaf virtual devices.

This could be done with ebtables, but that adds another set of layers
which hurts performance and is much more difficult to manage.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_private.h	2012-10-29 17:40:20.373973489 -0700
+++ b/net/bridge/br_private.h	2012-10-29 17:40:48.945686542 -0700
@@ -137,6 +137,7 @@ struct net_bridge_port
 #define BR_HAIRPIN_MODE		0x00000001
 #define BR_BPDU_GUARD           0x00000002
 #define BR_ROOT_BLOCK		0x00000004
+#define BR_BPDU_FILTER		0x00000008
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
--- a/net/bridge/br_stp_bpdu.c	2012-10-29 17:39:53.910239263 -0700
+++ b/net/bridge/br_stp_bpdu.c	2012-10-29 17:40:48.945686542 -0700
@@ -78,6 +78,9 @@ void br_send_config_bpdu(struct net_brid
 	if (p->br->stp_enabled != BR_KERNEL_STP)
 		return;
 
+	if (p->flags & BR_BPDU_FILTER)
+		return;
+
 	buf[0] = 0;
 	buf[1] = 0;
 	buf[2] = 0;
@@ -123,6 +126,9 @@ void br_send_tcn_bpdu(struct net_bridge_
 	if (p->br->stp_enabled != BR_KERNEL_STP)
 		return;
 
+	if (p->flags & BR_BPDU_FILTER)
+		return;
+
 	buf[0] = 0;
 	buf[1] = 0;
 	buf[2] = 0;
@@ -170,6 +176,9 @@ void br_stp_rcv(const struct stp_proto *
 	if (!ether_addr_equal(dest, br->group_addr))
 		goto out;
 
+	if (p->flags & BR_BPDU_FILTER)
+		goto out;
+
 	if (p->flags & BR_BPDU_GUARD) {
 		br_notice(br, "BPDU received on blocked port %u(%s)\n",
 			  (unsigned int) p->port_no, p->dev->name);
--- a/net/bridge/br_sysfs_if.c	2012-10-29 17:40:37.869797779 -0700
+++ b/net/bridge/br_sysfs_if.c	2012-10-29 17:40:48.945686542 -0700
@@ -158,6 +158,7 @@ static BRPORT_ATTR(flush, S_IWUSR, NULL,
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
+BRPORT_ATTR_FLAG(bpdu_filter, BR_BPDU_FILTER);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -193,6 +194,7 @@ static const struct brport_attribute *br
 	&brport_attr_hairpin_mode,
 	&brport_attr_bpdu_guard,
 	&brport_attr_root_block,
+	&brport_attr_bpdu_filter,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 #endif
--- a/include/uapi/linux/if_link.h	2012-10-29 17:40:20.373973489 -0700
+++ b/include/uapi/linux/if_link.h	2012-10-29 17:40:48.945686542 -0700
@@ -218,6 +218,7 @@ enum {
 	IFLA_BRPORT_MODE,	/* mode (hairpin)          */
 	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	IFLA_BRPORT_PROTECT,	/* root port protection    */
+	IFLA_BRPORT_BLOCK,	/* bpdu filter             */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
--- a/net/bridge/br_netlink.c	2012-10-29 17:40:20.373973489 -0700
+++ b/net/bridge/br_netlink.c	2012-10-29 17:40:48.945686542 -0700
@@ -28,6 +28,7 @@ static inline size_t br_port_info_size(v
 		+ nla_total_size(1)	/* IFLA_BRPORT_MODE */
 		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
+		+ nla_total_size(1)	/* IFLA_BRPORT_BLOCK */
 		+ 0;
 }
 
