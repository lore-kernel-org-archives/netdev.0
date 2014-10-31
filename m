From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH net-next] bridge: make proxy arp configurable
Date: Thu, 30 Oct 2014 20:09:42 -0700
Message-ID: <20141030200942.5a531e34@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Kyeyoon Park <kyeyoonp@codeaurora.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:20710 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750808AbaJaEWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 00:22:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This solves kernel build without INET enabled, and allows user
to control building this feature.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/bridge/Kconfig       |   16 ++++++++++++++++
 net/bridge/br_input.c    |    4 ++++
 net/bridge/br_sysfs_if.c |    4 ++++
 3 files changed, 24 insertions(+)

--- a/net/bridge/Kconfig	2014-10-30 18:51:19.242364880 -0700
+++ b/net/bridge/Kconfig	2014-10-30 18:51:21.326379955 -0700
@@ -60,3 +60,19 @@ config BRIDGE_VLAN_FILTERING
 	  Say N to exclude this support and reduce the binary size.
 
 	  If unsure, say Y.
+
+config BRIDGE_ARP_PROXY
+	bool "ARP proxying"
+	depends on BRIDGE
+	depends on INET
+	default y
+	---help---
+	  If you say Y here, then the Ethernet bridge to keep track of
+	  the hardware address to IP address mapping.
+
+	  It is most useful when used as a wireless AP.
+
+	  Say N to exclude this support and reduce the binary size.
+
+	  If unsure, say Y.
+
--- a/net/bridge/br_input.c	2014-10-30 18:51:19.242364880 -0700
+++ b/net/bridge/br_input.c	2014-10-30 19:00:11.050205767 -0700
@@ -59,6 +59,7 @@ static int br_pass_frame_up(struct sk_bu
 		       netif_receive_skb);
 }
 
+#ifdef CONFIG_BRIDGE_PROXY_ARP
 static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 			    u16 vid)
 {
@@ -112,6 +113,7 @@ static void br_do_proxy_arp(struct sk_bu
 		neigh_release(n);
 	}
 }
+#endif
 
 /* note: already called with rcu_read_lock */
 int br_handle_frame_finish(struct sk_buff *skb)
@@ -154,9 +156,11 @@ int br_handle_frame_finish(struct sk_buf
 	dst = NULL;
 
 	if (is_broadcast_ether_addr(dest)) {
+#ifdef CONFIG_BRIDGE_PROXY_ARP
 		if (p->flags & BR_PROXYARP &&
 		    skb->protocol == htons(ETH_P_ARP))
 			br_do_proxy_arp(skb, br, vid);
+#endif
 
 		skb2 = skb;
 		unicast = false;
--- a/net/bridge/br_sysfs_if.c	2014-10-27 20:24:06.376733888 -0700
+++ b/net/bridge/br_sysfs_if.c	2014-10-30 18:58:58.209680384 -0700
@@ -170,7 +170,9 @@ BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUA
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
 BRPORT_ATTR_FLAG(learning, BR_LEARNING);
 BRPORT_ATTR_FLAG(unicast_flood, BR_FLOOD);
+#ifdef CONFIG_BRIDGE_PROXY_ARP
 BRPORT_ATTR_FLAG(proxyarp, BR_PROXYARP);
+#endif
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -214,7 +216,9 @@ static const struct brport_attribute *br
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,
 #endif
+#ifdef CONFIG_BRIDGE_PROXY_ARP
 	&brport_attr_proxyarp,
+#endif
 	NULL
 };
 
