From: "Philip Prindeville" <philipp@redfish-solutions.com>
Subject: [PATCH net-next] net: ipv4: Add ability to have GRE ignore DF bit in IPv4 payloads
Date: Tue,  7 Jun 2016 13:48:46 -0600
Message-ID: <20160607194846.11494-1-philipp@redfish-solutions.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Philip Prindeville <philipp@redfish-solutions.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:54548 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752852AbcFGUAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 16:00:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp@redfish-solutions.com>

In the presence of firewalls which improperly block ICMP Unreachable
(including Fragmentation Required) messages, Path MTU Discovery is
prevented from working.

A workaround is to handle IPv4 payloads opaquely, ignoring the DF bit--as
is done for other payloads like AppleTalk--and doing transparent
fragmentation and reassembly.

Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---
 include/net/ip_tunnels.h       |    1 +
 include/uapi/linux/if_tunnel.h |    1 +
 net/ipv4/ip_gre.c              |   13 +++++++++++--
 net/ipv4/ip_tunnel.c           |    2 +-
 4 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index dbf4444..9222678 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -132,6 +132,7 @@ struct ip_tunnel {
 	int			ip_tnl_net_id;
 	struct gro_cells	gro_cells;
 	bool			collect_md;
+	bool			ignore_df;
 };
 
 #define TUNNEL_CSUM		__cpu_to_be16(0x01)
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index af4de90..1046f55 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -113,6 +113,7 @@ enum {
 	IFLA_GRE_ENCAP_SPORT,
 	IFLA_GRE_ENCAP_DPORT,
 	IFLA_GRE_COLLECT_METADATA,
+	IFLA_GRE_IGNORE_DF,
 	__IFLA_GRE_MAX,
 };
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 4d2025f..cbeecfb 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -846,6 +846,8 @@ static void ipgre_netlink_parms(struct net_device *dev,
 				struct nlattr *tb[],
 				struct ip_tunnel_parm *parms)
 {
+	struct ip_tunnel *t = netdev_priv(dev);
+
 	memset(parms, 0, sizeof(*parms));
 
 	parms->iph.protocol = IPPROTO_GRE;
@@ -884,12 +886,13 @@ static void ipgre_netlink_parms(struct net_device *dev,
 		parms->iph.frag_off = htons(IP_DF);
 
 	if (data[IFLA_GRE_COLLECT_METADATA]) {
-		struct ip_tunnel *t = netdev_priv(dev);
-
 		t->collect_md = true;
 		if (dev->type == ARPHRD_IPGRE)
 			dev->type = ARPHRD_NONE;
 	}
+
+	if (data[IFLA_GRE_IGNORE_DF])
+		t->ignore_df = !!nla_get_u8(data[IFLA_GRE_IGNORE_DF]);
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -1024,6 +1027,8 @@ static size_t ipgre_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_GRE_COLLECT_METADATA */
 		nla_total_size(0) +
+		/* IFLA_GRE_IGNORE_DF */
+		nla_total_size(1) +
 		0;
 }
 
@@ -1057,6 +1062,9 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			t->encap.flags))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_GRE_IGNORE_DF, t->ignore_df))
+		goto nla_put_failure;
+
 	if (t->collect_md) {
 		if (nla_put_flag(skb, IFLA_GRE_COLLECT_METADATA))
 			goto nla_put_failure;
@@ -1084,6 +1092,7 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_ENCAP_SPORT]	= { .type = NLA_U16 },
 	[IFLA_GRE_ENCAP_DPORT]	= { .type = NLA_U16 },
 	[IFLA_GRE_COLLECT_METADATA]	= { .type = NLA_FLAG },
+	[IFLA_GRE_IGNORE_DF]	= { .type = NLA_U8 },
 };
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index d8f5e0a..95649eb 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -682,7 +682,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	df = tnl_params->frag_off;
-	if (skb->protocol == htons(ETH_P_IP))
+	if (skb->protocol == htons(ETH_P_IP) && !tunnel->ignore_df)
 		df |= (inner_iph->frag_off&htons(IP_DF));
 
 	max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
