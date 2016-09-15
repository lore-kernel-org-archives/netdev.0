From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/4] ip_tunnel: add collect_md mode to IPIP tunnel
Date: Thu, 15 Sep 2016 13:00:29 -0700
Message-ID: <1473969632-2408261-2-git-send-email-ast@fb.com>
References: <1473969632-2408261-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43287 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755953AbcIOUAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:00:37 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8FJwWlx014311
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:00:35 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 25fwh12nt2-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:00:35 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 0fad9ae87b7f11e693270002c95209d8-cb2f4a50 for <netdev@vger.kernel.org>;        Thu,
 15 Sep 2016 13:00:33 -0700
In-Reply-To: <1473969632-2408261-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to gre, vxlan, geneve tunnels allow IPIP tunnels to
operate in 'collect metadata' mode.
bpf_skb_[gs]et_tunnel_key() helpers can make use of it right away.
ovs can use it as well in the future (once appropriate ovs-vport
abstractions and user apis are added).
Note that just like in other tunnels we cannot cache the dst,
since tunnel_info metadata can be different for every packet.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/ip_tunnels.h       |  2 ++
 include/uapi/linux/if_tunnel.h |  1 +
 net/ipv4/ip_tunnel.c           | 76 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ipip.c                | 35 +++++++++++++++----
 4 files changed, 108 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index e598c639aa6f..59557c07904b 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -255,6 +255,8 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
+void ip_md_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
+		       const u8 proto);
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
 int __ip_tunnel_change_mtu(struct net_device *dev, int new_mtu, bool strict);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 9865c8caedde..18d5dc13985d 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -73,6 +73,7 @@ enum {
 	IFLA_IPTUN_ENCAP_FLAGS,
 	IFLA_IPTUN_ENCAP_SPORT,
 	IFLA_IPTUN_ENCAP_DPORT,
+	IFLA_IPTUN_COLLECT_METADATA,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 95649ebd2874..5719d6ba0824 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -55,6 +55,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/udp.h>
+#include <net/dst_metadata.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -546,6 +547,81 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 	return 0;
 }
 
+void ip_md_tunnel_xmit(struct sk_buff *skb, struct net_device *dev, u8 proto)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	u32 headroom = sizeof(struct iphdr);
+	struct ip_tunnel_info *tun_info;
+	const struct ip_tunnel_key *key;
+	const struct iphdr *inner_iph;
+	struct rtable *rt;
+	struct flowi4 fl4;
+	__be16 df = 0;
+	u8 tos, ttl;
+
+	tun_info = skb_tunnel_info(skb);
+	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
+		     ip_tunnel_info_af(tun_info) != AF_INET))
+		goto tx_error;
+	key = &tun_info->key;
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
+	tos = key->tos;
+	if (tos == 1) {
+		if (skb->protocol == htons(ETH_P_IP))
+			tos = inner_iph->tos;
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			tos = ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
+	}
+	init_tunnel_flow(&fl4, proto, key->u.ipv4.dst, key->u.ipv4.src, 0,
+			 RT_TOS(tos), tunnel->parms.link);
+	if (tunnel->encap.type != TUNNEL_ENCAP_NONE)
+		goto tx_error;
+	rt = ip_route_output_key(tunnel->net, &fl4);
+	if (IS_ERR(rt)) {
+		dev->stats.tx_carrier_errors++;
+		goto tx_error;
+	}
+	if (rt->dst.dev == dev) {
+		ip_rt_put(rt);
+		dev->stats.collisions++;
+		goto tx_error;
+	}
+	tos = ip_tunnel_ecn_encap(tos, inner_iph, skb);
+	ttl = key->ttl;
+	if (ttl == 0) {
+		if (skb->protocol == htons(ETH_P_IP))
+			ttl = inner_iph->ttl;
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			ttl = ((const struct ipv6hdr *)inner_iph)->hop_limit;
+		else
+			ttl = ip4_dst_hoplimit(&rt->dst);
+	}
+	if (key->tun_flags & TUNNEL_DONT_FRAGMENT)
+		df = htons(IP_DF);
+	else if (skb->protocol == htons(ETH_P_IP))
+		df = inner_iph->frag_off & htons(IP_DF);
+	headroom += LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len;
+	if (headroom > dev->needed_headroom)
+		dev->needed_headroom = headroom;
+
+	if (skb_cow_head(skb, dev->needed_headroom)) {
+		ip_rt_put(rt);
+		goto tx_dropped;
+	}
+	iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, proto, key->tos,
+		      key->ttl, df, !net_eq(tunnel->net, dev_net(dev)));
+	return;
+tx_error:
+	dev->stats.tx_errors++;
+	goto kfree;
+tx_dropped:
+	dev->stats.tx_dropped++;
+kfree:
+	kfree_skb(skb);
+}
+EXPORT_SYMBOL_GPL(ip_md_tunnel_xmit);
+
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, u8 protocol)
 {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 4ae3f8e6c6cc..c9392589c415 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -115,6 +115,7 @@
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/dst_metadata.h>
 
 static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
@@ -193,6 +194,7 @@ static int ipip_tunnel_rcv(struct sk_buff *skb, u8 ipproto)
 {
 	struct net *net = dev_net(skb->dev);
 	struct ip_tunnel_net *itn = net_generic(net, ipip_net_id);
+	struct metadata_dst *tun_dst = NULL;
 	struct ip_tunnel *tunnel;
 	const struct iphdr *iph;
 
@@ -216,7 +218,12 @@ static int ipip_tunnel_rcv(struct sk_buff *skb, u8 ipproto)
 			tpi = &ipip_tpi;
 		if (iptunnel_pull_header(skb, 0, tpi->proto, false))
 			goto drop;
-		return ip_tunnel_rcv(tunnel, skb, tpi, NULL, log_ecn_error);
+		if (tunnel->collect_md) {
+			tun_dst = ip_tun_rx_dst(skb, 0, 0, 0);
+			if (!tun_dst)
+				return 0;
+		}
+		return ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
 	}
 
 	return -1;
@@ -270,7 +277,10 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb,
 
 	skb_set_inner_ipproto(skb, ipproto);
 
-	ip_tunnel_xmit(skb, dev, tiph, ipproto);
+	if (tunnel->collect_md)
+		ip_md_tunnel_xmit(skb, dev, ipproto);
+	else
+		ip_tunnel_xmit(skb, dev, tiph, ipproto);
 	return NETDEV_TX_OK;
 
 tx_error:
@@ -380,13 +390,14 @@ static int ipip_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static void ipip_netlink_parms(struct nlattr *data[],
-			       struct ip_tunnel_parm *parms)
+			       struct ip_tunnel_parm *parms, bool *collect_md)
 {
 	memset(parms, 0, sizeof(*parms));
 
 	parms->iph.version = 4;
 	parms->iph.protocol = IPPROTO_IPIP;
 	parms->iph.ihl = 5;
+	*collect_md = false;
 
 	if (!data)
 		return;
@@ -414,6 +425,9 @@ static void ipip_netlink_parms(struct nlattr *data[],
 
 	if (!data[IFLA_IPTUN_PMTUDISC] || nla_get_u8(data[IFLA_IPTUN_PMTUDISC]))
 		parms->iph.frag_off = htons(IP_DF);
+
+	if (data[IFLA_IPTUN_COLLECT_METADATA])
+		*collect_md = true;
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -453,18 +467,18 @@ static bool ipip_netlink_encap_parms(struct nlattr *data[],
 static int ipip_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
+	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
 
 	if (ipip_netlink_encap_parms(data, &ipencap)) {
-		struct ip_tunnel *t = netdev_priv(dev);
 		int err = ip_tunnel_encap_setup(t, &ipencap);
 
 		if (err < 0)
 			return err;
 	}
 
-	ipip_netlink_parms(data, &p);
+	ipip_netlink_parms(data, &p, &t->collect_md);
 	return ip_tunnel_newlink(dev, tb, &p);
 }
 
@@ -473,6 +487,7 @@ static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 {
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
+	bool collect_md;
 
 	if (ipip_netlink_encap_parms(data, &ipencap)) {
 		struct ip_tunnel *t = netdev_priv(dev);
@@ -482,7 +497,9 @@ static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 			return err;
 	}
 
-	ipip_netlink_parms(data, &p);
+	ipip_netlink_parms(data, &p, &collect_md);
+	if (collect_md)
+		return -EINVAL;
 
 	if (((dev->flags & IFF_POINTOPOINT) && !p.iph.daddr) ||
 	    (!(dev->flags & IFF_POINTOPOINT) && p.iph.daddr))
@@ -516,6 +533,8 @@ static size_t ipip_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_IPTUN_ENCAP_DPORT */
 		nla_total_size(2) +
+		/* IFLA_IPTUN_COLLECT_METADATA */
+		nla_total_size(0) +
 		0;
 }
 
@@ -544,6 +563,9 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			tunnel->encap.flags))
 		goto nla_put_failure;
 
+	if (tunnel->collect_md)
+		if (nla_put_flag(skb, IFLA_IPTUN_COLLECT_METADATA))
+			goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -562,6 +584,7 @@ static const struct nla_policy ipip_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_ENCAP_FLAGS]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_SPORT]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_DPORT]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_COLLECT_METADATA]	= { .type = NLA_FLAG },
 };
 
 static struct rtnl_link_ops ipip_link_ops __read_mostly = {
-- 
2.8.0
