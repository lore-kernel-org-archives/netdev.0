From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/4] ip6_tunnel: add collect_md mode to IPv6 tunnels
Date: Thu, 15 Sep 2016 13:00:30 -0700
Message-ID: <1473969632-2408261-3-git-send-email-ast@fb.com>
References: <1473969632-2408261-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57818 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754485AbcIOUAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:00:36 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FJwfEf011040
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:00:35 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25g0w08pan-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:00:35 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 0f99ecc87b7f11e6950824be0593f280-f6df8a50 for <netdev@vger.kernel.org>;        Thu,
 15 Sep 2016 13:00:33 -0700
In-Reply-To: <1473969632-2408261-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to gre, vxlan, geneve tunnels allow IPIP6 and IP6IP6 tunnels
to operate in 'collect metadata' mode.
Unlike ipv4 code here it's possible to reuse ip6_tnl_xmit() function
for both collect_md and traditional tunnels.
bpf_skb_[gs]et_tunnel_key() helpers and ovs (in the future) are the users.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/ip6_tunnel.h |   1 +
 net/ipv6/ip6_tunnel.c    | 178 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 134 insertions(+), 45 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 43a5a0e4524c..20ed9699fcd4 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -23,6 +23,7 @@ struct __ip6_tnl_parm {
 	__u8 proto;		/* tunnel protocol */
 	__u8 encap_limit;	/* encapsulation limit for tunnel */
 	__u8 hop_limit;		/* hop limit for tunnel */
+	bool collect_md;
 	__be32 flowinfo;	/* traffic class and flowlabel for tunnel */
 	__u32 flags;		/* tunnel flags */
 	struct in6_addr laddr;	/* local tunnel end-point address */
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 5c5779720ef1..6a66adba0c22 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -57,6 +57,7 @@
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/dst_metadata.h>
 
 MODULE_AUTHOR("Ville Nuorvala");
 MODULE_DESCRIPTION("IPv6 tunneling device");
@@ -90,6 +91,7 @@ struct ip6_tnl_net {
 	struct ip6_tnl __rcu *tnls_r_l[IP6_TUNNEL_HASH_SIZE];
 	struct ip6_tnl __rcu *tnls_wc[1];
 	struct ip6_tnl __rcu **tnls[2];
+	struct ip6_tnl __rcu *collect_md_tun;
 };
 
 static struct net_device_stats *ip6_get_stats(struct net_device *dev)
@@ -166,6 +168,10 @@ ip6_tnl_lookup(struct net *net, const struct in6_addr *remote, const struct in6_
 			return t;
 	}
 
+	t = rcu_dereference(ip6n->collect_md_tun);
+	if (t)
+		return t;
+
 	t = rcu_dereference(ip6n->tnls_wc[0]);
 	if (t && (t->dev->flags & IFF_UP))
 		return t;
@@ -209,6 +215,8 @@ ip6_tnl_link(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 {
 	struct ip6_tnl __rcu **tp = ip6_tnl_bucket(ip6n, &t->parms);
 
+	if (t->parms.collect_md)
+		rcu_assign_pointer(ip6n->collect_md_tun, t);
 	rcu_assign_pointer(t->next , rtnl_dereference(*tp));
 	rcu_assign_pointer(*tp, t);
 }
@@ -224,6 +232,9 @@ ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 	struct ip6_tnl __rcu **tp;
 	struct ip6_tnl *iter;
 
+	if (t->parms.collect_md)
+		rcu_assign_pointer(ip6n->collect_md_tun, NULL);
+
 	for (tp = ip6_tnl_bucket(ip6n, &t->parms);
 	     (iter = rtnl_dereference(*tp)) != NULL;
 	     tp = &iter->next) {
@@ -829,6 +840,9 @@ static int __ip6_tnl_rcv(struct ip6_tnl *tunnel, struct sk_buff *skb,
 
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(tunnel->dev)));
 
+	if (tun_dst)
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
+
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
@@ -865,6 +879,7 @@ static int ipxip6_rcv(struct sk_buff *skb, u8 ipproto,
 {
 	struct ip6_tnl *t;
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	struct metadata_dst *tun_dst = NULL;
 	int ret = -1;
 
 	rcu_read_lock();
@@ -881,7 +896,12 @@ static int ipxip6_rcv(struct sk_buff *skb, u8 ipproto,
 			goto drop;
 		if (iptunnel_pull_header(skb, 0, tpi->proto, false))
 			goto drop;
-		ret = __ip6_tnl_rcv(t, skb, tpi, NULL, dscp_ecn_decapsulate,
+		if (t->parms.collect_md) {
+			tun_dst = ipv6_tun_rx_dst(skb, 0, 0, 0);
+			if (!tun_dst)
+				return 0;
+		}
+		ret = __ip6_tnl_rcv(t, skb, tpi, tun_dst, dscp_ecn_decapsulate,
 				    log_ecn_error);
 	}
 
@@ -1012,8 +1032,16 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	int mtu;
 	unsigned int psh_hlen = sizeof(struct ipv6hdr) + t->encap_hlen;
 	unsigned int max_headroom = psh_hlen;
+	u8 hop_limit;
 	int err = -1;
 
+	if (t->parms.collect_md) {
+		hop_limit = skb_tunnel_info(skb)->key.ttl;
+		goto route_lookup;
+	} else {
+		hop_limit = t->parms.hop_limit;
+	}
+
 	/* NBMA tunnel */
 	if (ipv6_addr_any(&t->parms.raddr)) {
 		struct in6_addr *addr6;
@@ -1043,6 +1071,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		goto tx_err_link_failure;
 
 	if (!dst) {
+route_lookup:
 		dst = ip6_route_output(net, NULL, fl6);
 
 		if (dst->error)
@@ -1053,6 +1082,10 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 			dst = NULL;
 			goto tx_err_link_failure;
 		}
+		if (t->parms.collect_md &&
+		    ipv6_dev_get_saddr(net, ip6_dst_idev(dst)->dev,
+				       &fl6->daddr, 0, &fl6->saddr))
+			goto tx_err_link_failure;
 		ndst = dst;
 	}
 
@@ -1071,7 +1104,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	}
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
-	if (skb_dst(skb))
+	if (skb_dst(skb) && !t->parms.collect_md)
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 	if (skb->len > mtu && !skb_is_gso(skb)) {
 		*pmtu = mtu;
@@ -1111,8 +1144,13 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		skb = new_skb;
 	}
 
-	if (!fl6->flowi6_mark && ndst)
-		dst_cache_set_ip6(&t->dst_cache, ndst, &fl6->saddr);
+	if (t->parms.collect_md) {
+		if (t->encap.type != TUNNEL_ENCAP_NONE)
+			goto tx_err_dst_release;
+	} else {
+		if (!fl6->flowi6_mark && ndst)
+			dst_cache_set_ip6(&t->dst_cache, ndst, &fl6->saddr);
+	}
 	skb_dst_set(skb, dst);
 
 	if (encap_limit >= 0) {
@@ -1137,7 +1175,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
 		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
-	ipv6h->hop_limit = t->parms.hop_limit;
+	ipv6h->hop_limit = hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
 	ipv6h->daddr = fl6->daddr;
@@ -1170,19 +1208,34 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (tproto != IPPROTO_IPIP && tproto != 0)
 		return -1;
 
-	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-		encap_limit = t->parms.encap_limit;
+	dsfield = ipv4_get_dsfield(iph);
 
-	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_IPIP;
+	if (t->parms.collect_md) {
+		struct ip_tunnel_info *tun_info;
+		const struct ip_tunnel_key *key;
 
-	dsfield = ipv4_get_dsfield(iph);
+		tun_info = skb_tunnel_info(skb);
+		if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
+			     ip_tunnel_info_af(tun_info) != AF_INET6))
+			return -1;
+		key = &tun_info->key;
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_proto = IPPROTO_IPIP;
+		fl6.daddr = key->u.ipv6.dst;
+		fl6.flowlabel = key->label;
+	} else {
+		if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
+			encap_limit = t->parms.encap_limit;
 
-	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-		fl6.flowlabel |= htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
-					  & IPV6_TCLASS_MASK;
-	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
-		fl6.flowi6_mark = skb->mark;
+		memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
+		fl6.flowi6_proto = IPPROTO_IPIP;
+
+		if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
+			fl6.flowlabel |= htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
+					 & IPV6_TCLASS_MASK;
+		if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
+			fl6.flowi6_mark = skb->mark;
+	}
 
 	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
 		return -1;
@@ -1220,29 +1273,47 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	    ip6_tnl_addr_conflict(t, ipv6h))
 		return -1;
 
-	offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
-	if (offset > 0) {
-		struct ipv6_tlv_tnl_enc_lim *tel;
-		tel = (struct ipv6_tlv_tnl_enc_lim *)&skb_network_header(skb)[offset];
-		if (tel->encap_limit == 0) {
-			icmpv6_send(skb, ICMPV6_PARAMPROB,
-				    ICMPV6_HDR_FIELD, offset + 2);
+	dsfield = ipv6_get_dsfield(ipv6h);
+
+	if (t->parms.collect_md) {
+		struct ip_tunnel_info *tun_info;
+		const struct ip_tunnel_key *key;
+
+		tun_info = skb_tunnel_info(skb);
+		if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
+			     ip_tunnel_info_af(tun_info) != AF_INET6))
 			return -1;
+		key = &tun_info->key;
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_proto = IPPROTO_IPV6;
+		fl6.daddr = key->u.ipv6.dst;
+		fl6.flowlabel = key->label;
+	} else {
+		offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
+		if (offset > 0) {
+			struct ipv6_tlv_tnl_enc_lim *tel;
+
+			tel = (void *)&skb_network_header(skb)[offset];
+			if (tel->encap_limit == 0) {
+				icmpv6_send(skb, ICMPV6_PARAMPROB,
+					    ICMPV6_HDR_FIELD, offset + 2);
+				return -1;
+			}
+			encap_limit = tel->encap_limit - 1;
+		} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT)) {
+			encap_limit = t->parms.encap_limit;
 		}
-		encap_limit = tel->encap_limit - 1;
-	} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-		encap_limit = t->parms.encap_limit;
 
-	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_IPV6;
+		memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
+		fl6.flowi6_proto = IPPROTO_IPV6;
 
-	dsfield = ipv6_get_dsfield(ipv6h);
-	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-		fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
-	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
-		fl6.flowlabel |= ip6_flowlabel(ipv6h);
-	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
-		fl6.flowi6_mark = skb->mark;
+		if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
+			fl6.flowlabel |= (*(__be32 *)ipv6h & IPV6_TCLASS_MASK);
+		if (t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
+			fl6.flowlabel |= ip6_flowlabel(ipv6h);
+		if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
+			fl6.flowi6_mark = skb->mark;
+	}
 
 	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
 		return -1;
@@ -1741,6 +1812,10 @@ static int ip6_tnl_dev_init(struct net_device *dev)
 	if (err)
 		return err;
 	ip6_tnl_link_config(t);
+	if (t->parms.collect_md) {
+		dev->features |= NETIF_F_NETNS_LOCAL;
+		netif_keep_dst(dev);
+	}
 	return 0;
 }
 
@@ -1811,6 +1886,9 @@ static void ip6_tnl_netlink_parms(struct nlattr *data[],
 
 	if (data[IFLA_IPTUN_PROTO])
 		parms->proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
+
+	if (data[IFLA_IPTUN_COLLECT_METADATA])
+		parms->collect_md = true;
 }
 
 static bool ip6_tnl_netlink_encap_parms(struct nlattr *data[],
@@ -1850,6 +1928,7 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net *net = dev_net(dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 	struct ip6_tnl *nt, *t;
 	struct ip_tunnel_encap ipencap;
 
@@ -1864,9 +1943,14 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 
 	ip6_tnl_netlink_parms(data, &nt->parms);
 
-	t = ip6_tnl_locate(net, &nt->parms, 0);
-	if (!IS_ERR(t))
-		return -EEXIST;
+	if (nt->parms.collect_md) {
+		if (rtnl_dereference(ip6n->collect_md_tun))
+			return -EEXIST;
+	} else {
+		t = ip6_tnl_locate(net, &nt->parms, 0);
+		if (!IS_ERR(t))
+			return -EEXIST;
+	}
 
 	return ip6_tnl_create2(dev);
 }
@@ -1890,6 +1974,8 @@ static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
 			return err;
 	}
 	ip6_tnl_netlink_parms(data, &p);
+	if (p.collect_md)
+		return -EINVAL;
 
 	t = ip6_tnl_locate(net, &p, 0);
 	if (!IS_ERR(t)) {
@@ -1937,6 +2023,8 @@ static size_t ip6_tnl_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_IPTUN_ENCAP_DPORT */
 		nla_total_size(2) +
+		/* IFLA_IPTUN_COLLECT_METADATA */
+		nla_total_size(0) +
 		0;
 }
 
@@ -1955,16 +2043,15 @@ static int ip6_tnl_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->proto))
 		goto nla_put_failure;
 
-	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE,
-			tunnel->encap.type) ||
-	nla_put_be16(skb, IFLA_IPTUN_ENCAP_SPORT,
-		     tunnel->encap.sport) ||
-	nla_put_be16(skb, IFLA_IPTUN_ENCAP_DPORT,
-		     tunnel->encap.dport) ||
-	nla_put_u16(skb, IFLA_IPTUN_ENCAP_FLAGS,
-		    tunnel->encap.flags))
+	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE, tunnel->encap.type) ||
+	    nla_put_be16(skb, IFLA_IPTUN_ENCAP_SPORT, tunnel->encap.sport) ||
+	    nla_put_be16(skb, IFLA_IPTUN_ENCAP_DPORT, tunnel->encap.dport) ||
+	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_FLAGS, tunnel->encap.flags))
 		goto nla_put_failure;
 
+	if (parm->collect_md)
+		if (nla_put_flag(skb, IFLA_IPTUN_COLLECT_METADATA))
+			goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -1992,6 +2079,7 @@ static const struct nla_policy ip6_tnl_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_ENCAP_FLAGS]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_SPORT]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_ENCAP_DPORT]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_COLLECT_METADATA]	= { .type = NLA_FLAG },
 };
 
 static struct rtnl_link_ops ip6_link_ops __read_mostly = {
-- 
2.8.0
