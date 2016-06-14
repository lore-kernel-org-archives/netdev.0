From: "Philip Prindeville" <philipp@redfish-solutions.com>
Subject: [PATCH v2 net-next] net: ipv4: Add ability to have GRE ignore DF bit in IPv4 payloads
Date: Tue, 14 Jun 2016 15:53:02 -0600
Message-ID: <20160614215302.21641-1-philipp@redfish-solutions.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Philip Prindeville <philipp@redfish-solutions.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:52218 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751805AbcFNVxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:53:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp@redfish-solutions.com>

    In the presence of firewalls which improperly block ICMP Unreachable
    (including Fragmentation Required) messages, Path MTU Discovery is
    prevented from working.
    
    A workaround is to handle IPv4 payloads opaquely, ignoring the DF bit--as
    is done for other payloads like AppleTalk--and doing transparent
    fragmentation and reassembly.
    
    Redux includes the enforcement of mutual exclusion between this feature
    and Path MTU Discovery as suggested by Alexander Duyck.
    
    Cc: Alexander Duyck <alexander.duyck@gmail.com>
    Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
    Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---
 include/net/ip_tunnels.h       |  1 +
 include/uapi/linux/if_tunnel.h |  1 +
 net/ipv4/ip_gre.c              | 42 +++++++++++++++++++++++++++++++++---------
 net/ipv4/ip_tunnel.c           |  2 +-
 4 files changed, 36 insertions(+), 10 deletions(-)

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
index 4d2025f..0f8ca3f 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -841,17 +841,19 @@ out:
 	return ipgre_tunnel_validate(tb, data);
 }
 
-static void ipgre_netlink_parms(struct net_device *dev,
+static int ipgre_netlink_parms(struct net_device *dev,
 				struct nlattr *data[],
 				struct nlattr *tb[],
 				struct ip_tunnel_parm *parms)
 {
+	struct ip_tunnel *t = netdev_priv(dev);
+
 	memset(parms, 0, sizeof(*parms));
 
 	parms->iph.protocol = IPPROTO_GRE;
 
 	if (!data)
-		return;
+		return 0;
 
 	if (data[IFLA_GRE_LINK])
 		parms->link = nla_get_u32(data[IFLA_GRE_LINK]);
@@ -880,16 +882,26 @@ static void ipgre_netlink_parms(struct net_device *dev,
 	if (data[IFLA_GRE_TOS])
 		parms->iph.tos = nla_get_u8(data[IFLA_GRE_TOS]);
 
-	if (!data[IFLA_GRE_PMTUDISC] || nla_get_u8(data[IFLA_GRE_PMTUDISC]))
+	if (!data[IFLA_GRE_PMTUDISC] || nla_get_u8(data[IFLA_GRE_PMTUDISC])) {
+		if (t->ignore_df)
+			return -EINVAL;
 		parms->iph.frag_off = htons(IP_DF);
+	}
 
 	if (data[IFLA_GRE_COLLECT_METADATA]) {
-		struct ip_tunnel *t = netdev_priv(dev);
-
 		t->collect_md = true;
 		if (dev->type == ARPHRD_IPGRE)
 			dev->type = ARPHRD_NONE;
 	}
+
+	if (data[IFLA_GRE_IGNORE_DF]) {
+		if (nla_get_u8(data[IFLA_GRE_IGNORE_DF])
+		  && (parms->iph.frag_off & htons(IP_DF)))
+			return -EINVAL;
+		t->ignore_df = !!nla_get_u8(data[IFLA_GRE_IGNORE_DF]);
+	}
+
+	return 0;
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -960,16 +972,19 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
+	int err;
 
 	if (ipgre_netlink_encap_parms(data, &ipencap)) {
 		struct ip_tunnel *t = netdev_priv(dev);
-		int err = ip_tunnel_encap_setup(t, &ipencap);
+		err = ip_tunnel_encap_setup(t, &ipencap);
 
 		if (err < 0)
 			return err;
 	}
 
-	ipgre_netlink_parms(dev, data, tb, &p);
+	err = ipgre_netlink_parms(dev, data, tb, &p);
+	if (err < 0)
+		return err;
 	return ip_tunnel_newlink(dev, tb, &p);
 }
 
@@ -978,16 +993,19 @@ static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 {
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
+	int err;
 
 	if (ipgre_netlink_encap_parms(data, &ipencap)) {
 		struct ip_tunnel *t = netdev_priv(dev);
-		int err = ip_tunnel_encap_setup(t, &ipencap);
+		err = ip_tunnel_encap_setup(t, &ipencap);
 
 		if (err < 0)
 			return err;
 	}
 
-	ipgre_netlink_parms(dev, data, tb, &p);
+	err = ipgre_netlink_parms(dev, data, tb, &p);
+	if (err < 0)
+		return err;
 	return ip_tunnel_changelink(dev, tb, &p);
 }
 
@@ -1024,6 +1042,8 @@ static size_t ipgre_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_GRE_COLLECT_METADATA */
 		nla_total_size(0) +
+		/* IFLA_GRE_IGNORE_DF */
+		nla_total_size(1) +
 		0;
 }
 
@@ -1057,6 +1077,9 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			t->encap.flags))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_GRE_IGNORE_DF, t->ignore_df))
+		goto nla_put_failure;
+
 	if (t->collect_md) {
 		if (nla_put_flag(skb, IFLA_GRE_COLLECT_METADATA))
 			goto nla_put_failure;
@@ -1084,6 +1107,7 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
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
