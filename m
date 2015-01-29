From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 4/6] ip_tunnel: Introduce tunnel_info struct.
Date: Thu, 29 Jan 2015 15:29:40 -0800
Message-ID: <1422574180-1947-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:38194 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758891AbbA2X3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:29:43 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so44472534pab.12
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 15:29:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tunnel information is stored in ip_tunnel_parm, but this is part
of tunnel ioctl interface, so it is not extensible.
STT need to extend tunnel layer, so this patch introduces tunnel_info
struct to store kernel tunnel information. with this new struct
we can get rid of iphdr which is used to store iphdr parameters. Plus
redundant tunnel name is also removed. This simplifies code in ip_tunnel.
This patch does not change actual tunnel parameters.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnels.h |  34 ++++--
 net/ipv4/ip_gre.c        | 179 ++++++++++++++++++-------------
 net/ipv4/ip_tunnel.c     | 268 ++++++++++++++++++++++++++---------------------
 net/ipv4/ip_vti.c        |  71 ++++++-------
 net/ipv4/ipip.c          |  84 ++++++++-------
 net/ipv6/sit.c           | 152 +++++++++++++--------------
 6 files changed, 440 insertions(+), 348 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 2c47061..b46b05d 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -51,6 +51,20 @@ struct ip_tunnel_dst {
 	__be32				 saddr;
 };
 
+struct tunnel_info {
+	__be32		i_key;
+	__be32		o_key;
+	__be32		saddr;
+	__be32		daddr;
+	int		link;
+	__be16		i_flags;
+	__be16		o_flags;
+	__be16		df;
+	__u8		tos;
+	__u8		ttl;
+	__u8		protocol;
+};
+
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct hlist_node hash_node;
@@ -69,7 +83,7 @@ struct ip_tunnel {
 
 	struct ip_tunnel_dst __percpu *dst_cache;
 
-	struct ip_tunnel_parm parms;
+	struct tunnel_info info;
 
 	int		encap_hlen;	/* Encap header length (FOU,GUE) */
 	struct ip_tunnel_encap encap;
@@ -143,13 +157,14 @@ void ip_tunnel_uninit(struct net_device *dev);
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
 struct net *ip_tunnel_get_link_net(const struct net_device *dev);
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
-		       struct rtnl_link_ops *ops, char *devname);
+		       struct rtnl_link_ops *ops, char devname[]);
 
 void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
-
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
-		    const struct iphdr *tnl_params, const u8 protocol);
-int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
+		    __be32 saddr, __be32 dst, u8 tos, u8 ttl, __be16 df,
+		    u8 protocol);
+int ip_tunnel_ioctl(struct net_device *dev, char *dev_name,
+		    struct tunnel_info *info, int cmd);
 int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
 		    u8 *protocol, struct flowi4 *fl4);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
@@ -164,14 +179,19 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		  const struct tnl_ptk_info *tpi, bool log_ecn_error);
 int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
-			 struct ip_tunnel_parm *p);
+			 struct tunnel_info *info);
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
-		      struct ip_tunnel_parm *p);
+		      struct tunnel_info *info);
 void ip_tunnel_setup(struct net_device *dev, int net_id);
 void ip_tunnel_dst_reset_all(struct ip_tunnel *t);
 int ip_tunnel_encap_setup(struct ip_tunnel *t,
 			  struct ip_tunnel_encap *ipencap);
 
+void tunnel_info_to_parm(char dev_name[], struct tunnel_info *info,
+			    struct ip_tunnel_parm *p);
+void ip_tunnel_parm_to_info(struct ip_tunnel_parm *p,
+			    struct tunnel_info *info);
+
 /* Extract dsfield from inner protocol */
 static inline u8 ip_tunnel_get_dsfield(const struct iphdr *iph,
 				       const struct sk_buff *skb)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6e7727f2..fa9ee75 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -185,11 +185,11 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
 	if (t == NULL)
 		return PACKET_REJECT;
 
-	if (t->parms.iph.daddr == 0 ||
-	    ipv4_is_multicast(t->parms.iph.daddr))
+	if (t->info.daddr == 0 ||
+	    ipv4_is_multicast(t->info.daddr))
 		return PACKET_RCVD;
 
-	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
+	if (t->info.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		return PACKET_RCVD;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
@@ -224,17 +224,17 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 	return PACKET_REJECT;
 }
 
-static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
-		       const struct iphdr *tnl_params,
-		       __be16 proto)
+static void __gre_xmit(struct sk_buff *skb, struct net_device *dev, __be32 src,
+		       __be32 dst, __u8 tos, __u8 ttl, __be16 df,
+		       __be16 inner_proto)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct tnl_ptk_info tpi;
 
-	tpi.flags = tunnel->parms.o_flags;
-	tpi.proto = proto;
-	tpi.key = tunnel->parms.o_key;
-	if (tunnel->parms.o_flags & TUNNEL_SEQ)
+	tpi.flags = tunnel->info.o_flags;
+	tpi.proto = inner_proto;
+	tpi.key = tunnel->info.o_key;
+	if (tunnel->info.o_flags & TUNNEL_SEQ)
 		tunnel->o_seqno++;
 	tpi.seq = htonl(tunnel->o_seqno);
 
@@ -243,22 +243,32 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	skb_set_inner_protocol(skb, tpi.proto);
 
-	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
+	ip_tunnel_xmit(skb, dev, src, dst, tos, ttl, df, IPPROTO_GRE);
 }
 
 static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 			      struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr *tnl_params;
+	__be16 df;
+	__be32 src, dst;
+	__u8 tos, ttl;
 
 	if (dev->header_ops) {
+		const struct iphdr *iph;
+
 		/* Need space for new headers */
 		if (skb_cow_head(skb, dev->needed_headroom -
 				      (tunnel->hlen + sizeof(struct iphdr))))
 			goto free_skb;
 
-		tnl_params = (const struct iphdr *)skb->data;
+		iph = (const struct iphdr *)skb->data;
+
+		src = iph->saddr;
+		dst = iph->daddr;
+		tos = iph->tos;
+		ttl = iph->ttl;
+		df = iph->frag_off;
 
 		/* Pull skb since ip_tunnel_xmit() needs skb->data pointing
 		 * to gre header.
@@ -266,17 +276,23 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 		skb_pull(skb, tunnel->hlen + sizeof(struct iphdr));
 		skb_reset_mac_header(skb);
 	} else {
+		struct tunnel_info *info = &tunnel->info;
+
 		if (skb_cow_head(skb, dev->needed_headroom))
 			goto free_skb;
 
-		tnl_params = &tunnel->parms.iph;
+		src = info->saddr;
+		dst = info->daddr;
+		tos = info->tos;
+		ttl = info->ttl;
+		df = info->df;
 	}
 
-	skb = gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM));
+	skb = gre_handle_offloads(skb, !!(tunnel->info.o_flags&TUNNEL_CSUM));
 	if (IS_ERR(skb))
 		goto out;
 
-	__gre_xmit(skb, dev, tnl_params, skb->protocol);
+	__gre_xmit(skb, dev, src, dst, tos, ttl, df, skb->protocol);
 
 	return NETDEV_TX_OK;
 
@@ -291,15 +307,17 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct tunnel_info *info = &tunnel->info;
 
-	skb = gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM));
+	skb = gre_handle_offloads(skb, !!(info->o_flags&TUNNEL_CSUM));
 	if (IS_ERR(skb))
 		goto out;
 
 	if (skb_cow_head(skb, dev->needed_headroom))
 		goto free_skb;
 
-	__gre_xmit(skb, dev, &tunnel->parms.iph, htons(ETH_P_TEB));
+	__gre_xmit(skb, dev, info->saddr, info->daddr, info->tos, info->ttl,
+		   info->df, htons(ETH_P_TEB));
 
 	return NETDEV_TX_OK;
 
@@ -313,8 +331,9 @@ out:
 static int ipgre_tunnel_ioctl(struct net_device *dev,
 			      struct ifreq *ifr, int cmd)
 {
-	int err;
+	struct tunnel_info info;
 	struct ip_tunnel_parm p;
+	int err;
 
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
@@ -327,9 +346,11 @@ static int ipgre_tunnel_ioctl(struct net_device *dev,
 	p.i_flags = gre_flags_to_tnl_flags(p.i_flags);
 	p.o_flags = gre_flags_to_tnl_flags(p.o_flags);
 
-	err = ip_tunnel_ioctl(dev, &p, cmd);
+	ip_tunnel_parm_to_info(&p, &info);
+	err = ip_tunnel_ioctl(dev, p.name, &info, cmd);
 	if (err)
 		return err;
+	tunnel_info_to_parm(p.name, &info, &p);
 
 	p.i_flags = tnl_flags_to_gre_flags(p.i_flags);
 	p.o_flags = tnl_flags_to_gre_flags(p.o_flags);
@@ -371,21 +392,36 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 			const void *daddr, const void *saddr, unsigned int len)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
+	struct tunnel_info *info = &t->info;
 	struct iphdr *iph;
 	struct gre_base_hdr *greh;
 
 	iph = (struct iphdr *)skb_push(skb, t->hlen + sizeof(*iph));
 	greh = (struct gre_base_hdr *)(iph+1);
-	greh->flags = tnl_flags_to_gre_flags(t->parms.o_flags);
+	greh->flags = tnl_flags_to_gre_flags(t->info.o_flags);
 	greh->protocol = htons(type);
 
-	memcpy(iph, &t->parms.iph, sizeof(struct iphdr));
+	iph->ihl = 5;
+	iph->version = 4;
+	iph->tos = info->tos;
+	iph->tot_len = 0;
+	iph->id = 0;
+	iph->frag_off = info->df;
+	iph->ttl = info->ttl;
+	iph->protocol = IPPROTO_GRE;
+	iph->check = 0;
 
 	/* Set the source hardware address. */
 	if (saddr)
 		memcpy(&iph->saddr, saddr, 4);
+	else
+		memcpy(&iph->saddr, &info->saddr, 4);
+
 	if (daddr)
 		memcpy(&iph->daddr, daddr, 4);
+	else
+		memcpy(&iph->daddr, &info->daddr, 4);
+
 	if (iph->daddr)
 		return t->hlen + sizeof(*iph);
 
@@ -409,16 +445,16 @@ static int ipgre_open(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 
-	if (ipv4_is_multicast(t->parms.iph.daddr)) {
+	if (ipv4_is_multicast(t->info.daddr)) {
 		struct flowi4 fl4;
 		struct rtable *rt;
 
 		rt = ip_route_output_gre(t->net, &fl4,
-					 t->parms.iph.daddr,
-					 t->parms.iph.saddr,
-					 t->parms.o_key,
-					 RT_TOS(t->parms.iph.tos),
-					 t->parms.link);
+					 t->info.daddr,
+					 t->info.saddr,
+					 t->info.o_key,
+					 RT_TOS(t->info.tos),
+					 t->info.link);
 		if (IS_ERR(rt))
 			return -EADDRNOTAVAIL;
 		dev = rt->dst.dev;
@@ -426,7 +462,7 @@ static int ipgre_open(struct net_device *dev)
 		if (__in_dev_get_rtnl(dev) == NULL)
 			return -EADDRNOTAVAIL;
 		t->mlink = dev->ifindex;
-		ip_mc_inc_group(__in_dev_get_rtnl(dev), t->parms.iph.daddr);
+		ip_mc_inc_group(__in_dev_get_rtnl(dev), t->info.daddr);
 	}
 	return 0;
 }
@@ -435,11 +471,11 @@ static int ipgre_close(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 
-	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
+	if (ipv4_is_multicast(t->info.daddr) && t->mlink) {
 		struct in_device *in_dev;
 		in_dev = inetdev_by_index(t->net, t->mlink);
 		if (in_dev)
-			ip_mc_dec_group(in_dev, t->parms.iph.daddr);
+			ip_mc_dec_group(in_dev, t->info.daddr);
 	}
 	return 0;
 }
@@ -476,8 +512,7 @@ static void __gre_tunnel_init(struct net_device *dev)
 	int t_hlen;
 
 	tunnel = netdev_priv(dev);
-	tunnel->tun_hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
-	tunnel->parms.iph.protocol = IPPROTO_GRE;
+	tunnel->tun_hlen = ip_gre_calc_hlen(tunnel->info.o_flags);
 
 	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
 
@@ -489,7 +524,7 @@ static void __gre_tunnel_init(struct net_device *dev)
 	dev->features		|= GRE_FEATURES;
 	dev->hw_features	|= GRE_FEATURES;
 
-	if (!(tunnel->parms.o_flags & TUNNEL_SEQ)) {
+	if (!(tunnel->info.o_flags & TUNNEL_SEQ)) {
 		/* TCP offload with GRE SEQ is not supported. */
 		dev->features    |= NETIF_F_GSO_SOFTWARE;
 		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
@@ -503,21 +538,21 @@ static void __gre_tunnel_init(struct net_device *dev)
 static int ipgre_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct iphdr *iph = &tunnel->parms.iph;
+	struct tunnel_info *info = &tunnel->info;
 
 	__gre_tunnel_init(dev);
 
-	memcpy(dev->dev_addr, &iph->saddr, 4);
-	memcpy(dev->broadcast, &iph->daddr, 4);
+	memcpy(dev->dev_addr, &info->saddr, 4);
+	memcpy(dev->broadcast, &info->daddr, 4);
 
 	dev->flags		= IFF_NOARP;
 	netif_keep_dst(dev);
 	dev->addr_len		= 4;
 
-	if (iph->daddr) {
+	if (info->daddr) {
 #ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (ipv4_is_multicast(iph->daddr)) {
-			if (!iph->saddr)
+		if (ipv4_is_multicast(info->daddr)) {
+			if (!info->saddr)
 				return -EINVAL;
 			dev->flags = IFF_BROADCAST;
 			dev->header_ops = &ipgre_header_ops;
@@ -595,45 +630,45 @@ out:
 	return ipgre_tunnel_validate(tb, data);
 }
 
-static void ipgre_netlink_parms(struct nlattr *data[], struct nlattr *tb[],
-			       struct ip_tunnel_parm *parms)
+static void ipgre_netlink_info(struct nlattr *data[], struct nlattr *tb[],
+			       struct tunnel_info *info)
 {
-	memset(parms, 0, sizeof(*parms));
+	memset(info, 0, sizeof(*info));
 
-	parms->iph.protocol = IPPROTO_GRE;
+	info->protocol = IPPROTO_GRE;
 
 	if (!data)
 		return;
 
 	if (data[IFLA_GRE_LINK])
-		parms->link = nla_get_u32(data[IFLA_GRE_LINK]);
+		info->link = nla_get_u32(data[IFLA_GRE_LINK]);
 
 	if (data[IFLA_GRE_IFLAGS])
-		parms->i_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_IFLAGS]));
+		info->i_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_IFLAGS]));
 
 	if (data[IFLA_GRE_OFLAGS])
-		parms->o_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_OFLAGS]));
+		info->o_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_OFLAGS]));
 
 	if (data[IFLA_GRE_IKEY])
-		parms->i_key = nla_get_be32(data[IFLA_GRE_IKEY]);
+		info->i_key = nla_get_be32(data[IFLA_GRE_IKEY]);
 
 	if (data[IFLA_GRE_OKEY])
-		parms->o_key = nla_get_be32(data[IFLA_GRE_OKEY]);
+		info->o_key = nla_get_be32(data[IFLA_GRE_OKEY]);
 
 	if (data[IFLA_GRE_LOCAL])
-		parms->iph.saddr = nla_get_be32(data[IFLA_GRE_LOCAL]);
+		info->saddr = nla_get_be32(data[IFLA_GRE_LOCAL]);
 
 	if (data[IFLA_GRE_REMOTE])
-		parms->iph.daddr = nla_get_be32(data[IFLA_GRE_REMOTE]);
+		info->daddr = nla_get_be32(data[IFLA_GRE_REMOTE]);
 
 	if (data[IFLA_GRE_TTL])
-		parms->iph.ttl = nla_get_u8(data[IFLA_GRE_TTL]);
+		info->ttl = nla_get_u8(data[IFLA_GRE_TTL]);
 
 	if (data[IFLA_GRE_TOS])
-		parms->iph.tos = nla_get_u8(data[IFLA_GRE_TOS]);
+		info->tos = nla_get_u8(data[IFLA_GRE_TOS]);
 
 	if (!data[IFLA_GRE_PMTUDISC] || nla_get_u8(data[IFLA_GRE_PMTUDISC]))
-		parms->iph.frag_off = htons(IP_DF);
+		info->df = htons(IP_DF);
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -699,8 +734,8 @@ static void ipgre_tap_setup(struct net_device *dev)
 static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
-	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
+	struct tunnel_info info;
 
 	if (ipgre_netlink_encap_parms(data, &ipencap)) {
 		struct ip_tunnel *t = netdev_priv(dev);
@@ -710,15 +745,15 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 			return err;
 	}
 
-	ipgre_netlink_parms(data, tb, &p);
-	return ip_tunnel_newlink(dev, tb, &p);
+	ipgre_netlink_info(data, tb, &info);
+	return ip_tunnel_newlink(dev, tb, &info);
 }
 
 static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 			    struct nlattr *data[])
 {
-	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
+	struct tunnel_info info;
 
 	if (ipgre_netlink_encap_parms(data, &ipencap)) {
 		struct ip_tunnel *t = netdev_priv(dev);
@@ -728,8 +763,8 @@ static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 			return err;
 	}
 
-	ipgre_netlink_parms(data, tb, &p);
-	return ip_tunnel_changelink(dev, tb, &p);
+	ipgre_netlink_info(data, tb, &info);
+	return ip_tunnel_changelink(dev, tb, &info);
 }
 
 static size_t ipgre_get_size(const struct net_device *dev)
@@ -769,19 +804,19 @@ static size_t ipgre_get_size(const struct net_device *dev)
 static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
-	struct ip_tunnel_parm *p = &t->parms;
-
-	if (nla_put_u32(skb, IFLA_GRE_LINK, p->link) ||
-	    nla_put_be16(skb, IFLA_GRE_IFLAGS, tnl_flags_to_gre_flags(p->i_flags)) ||
-	    nla_put_be16(skb, IFLA_GRE_OFLAGS, tnl_flags_to_gre_flags(p->o_flags)) ||
-	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
-	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
-	    nla_put_be32(skb, IFLA_GRE_LOCAL, p->iph.saddr) ||
-	    nla_put_be32(skb, IFLA_GRE_REMOTE, p->iph.daddr) ||
-	    nla_put_u8(skb, IFLA_GRE_TTL, p->iph.ttl) ||
-	    nla_put_u8(skb, IFLA_GRE_TOS, p->iph.tos) ||
+	struct tunnel_info *info = &t->info;
+
+	if (nla_put_u32(skb, IFLA_GRE_LINK, info->link) ||
+	    nla_put_be16(skb, IFLA_GRE_IFLAGS, tnl_flags_to_gre_flags(info->i_flags)) ||
+	    nla_put_be16(skb, IFLA_GRE_OFLAGS, tnl_flags_to_gre_flags(info->o_flags)) ||
+	    nla_put_be32(skb, IFLA_GRE_IKEY, info->i_key) ||
+	    nla_put_be32(skb, IFLA_GRE_OKEY, info->o_key) ||
+	    nla_put_be32(skb, IFLA_GRE_LOCAL, info->saddr) ||
+	    nla_put_be32(skb, IFLA_GRE_REMOTE, info->daddr) ||
+	    nla_put_u8(skb, IFLA_GRE_TTL, info->ttl) ||
+	    nla_put_u8(skb, IFLA_GRE_TOS, info->tos) ||
 	    nla_put_u8(skb, IFLA_GRE_PMTUDISC,
-		       !!(p->iph.frag_off & htons(IP_DF))))
+		       !!(info->df & htons(IP_DF))))
 		goto nla_put_failure;
 
 	if (nla_put_u16(skb, IFLA_GRE_ENCAP_TYPE,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 2cd0828..fc078ae 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -63,6 +63,49 @@
 #include <net/ip6_route.h>
 #endif
 
+void tunnel_info_to_parm(char dev_name[], struct tunnel_info *info,
+			 struct ip_tunnel_parm *p)
+{
+	memset(p, 0, sizeof(*p));
+
+	strcpy(p->name, dev_name);
+	p->link = info->link;
+	p->i_flags = info->i_flags;
+	p->o_flags = info->o_flags;
+	p->i_key = info->i_key;
+	p->o_key = info->o_key;
+
+	p->iph.version = 4;
+	p->iph.ihl = 5;
+	p->iph.tos = info->tos;
+	p->iph.frag_off = info->df;
+	p->iph.ttl = info->ttl;
+	p->iph.protocol = info->protocol;
+	p->iph.saddr = info->saddr;
+	p->iph.daddr = info->daddr;
+}
+EXPORT_SYMBOL_GPL(tunnel_info_to_parm);
+
+void ip_tunnel_parm_to_info(struct ip_tunnel_parm *p,
+			    struct tunnel_info *info)
+{
+	memset(info, 0, sizeof(*info));
+
+	info->link = p->link;
+	info->i_flags = p->i_flags;
+	info->o_flags = p->o_flags;
+	info->i_key = p->i_key;
+	info->o_key = p->o_key;
+
+	info->tos = p->iph.tos;
+	info->df = p->iph.frag_off;
+	info->ttl = p->iph.ttl;
+	info->protocol = p->iph.protocol;
+	info->saddr = p->iph.saddr;
+	info->daddr = p->iph.daddr;
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_parm_to_info);
+
 static unsigned int ip_tunnel_hash(__be32 key, __be32 remote)
 {
 	return hash_32((__force u32)key ^ (__force u32)remote,
@@ -124,12 +167,12 @@ static struct rtable *tunnel_rtable_get(struct ip_tunnel *t,
 	return (struct rtable *)dst;
 }
 
-static bool ip_tunnel_key_match(const struct ip_tunnel_parm *p,
+static bool ip_tunnel_key_match(const struct tunnel_info *t,
 				__be16 flags, __be32 key)
 {
-	if (p->i_flags & TUNNEL_KEY) {
+	if (t->i_flags & TUNNEL_KEY) {
 		if (flags & TUNNEL_KEY)
-			return key == p->i_key;
+			return key == t->i_key;
 		else
 			/* key expected, none present */
 			return false;
@@ -161,30 +204,30 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 	head = &itn->tunnels[hash];
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
-		if (local != t->parms.iph.saddr ||
-		    remote != t->parms.iph.daddr ||
+		if (local != t->info.saddr ||
+		    remote != t->info.daddr ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
 
-		if (!ip_tunnel_key_match(&t->parms, flags, key))
+		if (!ip_tunnel_key_match(&t->info, flags, key))
 			continue;
 
-		if (t->parms.link == link)
+		if (t->info.link == link)
 			return t;
 		else
 			cand = t;
 	}
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
-		if (remote != t->parms.iph.daddr ||
-		    t->parms.iph.saddr != 0 ||
+		if (remote != t->info.daddr ||
+		    t->info.saddr != 0 ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
 
-		if (!ip_tunnel_key_match(&t->parms, flags, key))
+		if (!ip_tunnel_key_match(&t->info, flags, key))
 			continue;
 
-		if (t->parms.link == link)
+		if (t->info.link == link)
 			return t;
 		else if (!cand)
 			cand = t;
@@ -194,17 +237,17 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 	head = &itn->tunnels[hash];
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
-		if ((local != t->parms.iph.saddr || t->parms.iph.daddr != 0) &&
-		    (local != t->parms.iph.daddr || !ipv4_is_multicast(local)))
+		if ((local != t->info.saddr || t->info.daddr != 0) &&
+		    (local != t->info.daddr || !ipv4_is_multicast(local)))
 			continue;
 
 		if (!(t->dev->flags & IFF_UP))
 			continue;
 
-		if (!ip_tunnel_key_match(&t->parms, flags, key))
+		if (!ip_tunnel_key_match(&t->info, flags, key))
 			continue;
 
-		if (t->parms.link == link)
+		if (t->info.link == link)
 			return t;
 		else if (!cand)
 			cand = t;
@@ -214,13 +257,13 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 		goto skip_key_lookup;
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
-		if (t->parms.i_key != key ||
-		    t->parms.iph.saddr != 0 ||
-		    t->parms.iph.daddr != 0 ||
+		if (t->info.i_key != key ||
+		    t->info.saddr != 0 ||
+		    t->info.daddr != 0 ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
 
-		if (t->parms.link == link)
+		if (t->info.link == link)
 			return t;
 		else if (!cand)
 			cand = t;
@@ -239,18 +282,18 @@ skip_key_lookup:
 EXPORT_SYMBOL_GPL(ip_tunnel_lookup);
 
 static struct hlist_head *ip_bucket(struct ip_tunnel_net *itn,
-				    struct ip_tunnel_parm *parms)
+				    struct tunnel_info *info)
 {
 	unsigned int h;
 	__be32 remote;
-	__be32 i_key = parms->i_key;
+	__be32 i_key = info->i_key;
 
-	if (parms->iph.daddr && !ipv4_is_multicast(parms->iph.daddr))
-		remote = parms->iph.daddr;
+	if (info->daddr && !ipv4_is_multicast(info->daddr))
+		remote = info->daddr;
 	else
 		remote = 0;
 
-	if (!(parms->i_flags & TUNNEL_KEY) && (parms->i_flags & VTI_ISVTI))
+	if (!(info->i_flags & TUNNEL_KEY) && (info->i_flags & VTI_ISVTI))
 		i_key = 0;
 
 	h = ip_tunnel_hash(i_key, remote);
@@ -259,7 +302,7 @@ static struct hlist_head *ip_bucket(struct ip_tunnel_net *itn,
 
 static void ip_tunnel_add(struct ip_tunnel_net *itn, struct ip_tunnel *t)
 {
-	struct hlist_head *head = ip_bucket(itn, &t->parms);
+	struct hlist_head *head = ip_bucket(itn, &t->info);
 
 	hlist_add_head_rcu(&t->hash_node, head);
 }
@@ -270,23 +313,23 @@ static void ip_tunnel_del(struct ip_tunnel *t)
 }
 
 static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
-					struct ip_tunnel_parm *parms,
+					struct tunnel_info *info,
 					int type)
 {
-	__be32 remote = parms->iph.daddr;
-	__be32 local = parms->iph.saddr;
-	__be32 key = parms->i_key;
-	__be16 flags = parms->i_flags;
-	int link = parms->link;
+	__be32 remote = info->daddr;
+	__be32 local = info->saddr;
+	__be32 key = info->i_key;
+	__be16 flags = info->i_flags;
+	int link = info->link;
 	struct ip_tunnel *t = NULL;
-	struct hlist_head *head = ip_bucket(itn, parms);
+	struct hlist_head *head = ip_bucket(itn, info);
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
-		if (local == t->parms.iph.saddr &&
-		    remote == t->parms.iph.daddr &&
-		    link == t->parms.link &&
+		if (local == t->info.saddr &&
+		    remote == t->info.daddr &&
+		    link == t->info.link &&
 		    type == t->dev->type &&
-		    ip_tunnel_key_match(&t->parms, flags, key))
+		    ip_tunnel_key_match(&t->info, flags, key))
 			break;
 	}
 	return t;
@@ -294,15 +337,16 @@ static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
 
 static struct net_device *__ip_tunnel_create(struct net *net,
 					     const struct rtnl_link_ops *ops,
-					     struct ip_tunnel_parm *parms)
+					     char *dev_name,
+					     struct tunnel_info *info)
 {
 	int err;
 	struct ip_tunnel *tunnel;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
 
-	if (parms->name[0])
-		strlcpy(name, parms->name, IFNAMSIZ);
+	if (dev_name && dev_name[0])
+		strlcpy(name, dev_name, IFNAMSIZ);
 	else {
 		if (strlen(ops->kind) > (IFNAMSIZ - 3)) {
 			err = -E2BIG;
@@ -323,7 +367,7 @@ static struct net_device *__ip_tunnel_create(struct net *net,
 	dev->rtnl_link_ops = ops;
 
 	tunnel = netdev_priv(dev);
-	tunnel->parms = *parms;
+	tunnel->info = *info;
 	tunnel->net = net;
 
 	err = register_netdevice(dev);
@@ -356,21 +400,19 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr *iph;
+	struct tunnel_info *info = &tunnel->info;
 	int hlen = LL_MAX_HEADER;
 	int mtu = ETH_DATA_LEN;
 	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
 
-	iph = &tunnel->parms.iph;
-
 	/* Guess output device to choose reasonable mtu and needed_headroom */
-	if (iph->daddr) {
+	if (info->daddr) {
 		struct flowi4 fl4;
 		struct rtable *rt;
 
-		init_tunnel_flow(&fl4, iph->protocol, iph->daddr,
-				 iph->saddr, tunnel->parms.o_key,
-				 RT_TOS(iph->tos), tunnel->parms.link);
+		init_tunnel_flow(&fl4, info->protocol, info->daddr,
+				 info->saddr, info->o_key,
+				 RT_TOS(info->tos), info->link);
 		rt = ip_route_output_key(tunnel->net, &fl4);
 
 		if (!IS_ERR(rt)) {
@@ -382,14 +424,14 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 			dev->flags |= IFF_POINTOPOINT;
 	}
 
-	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(tunnel->net, tunnel->parms.link);
+	if (!tdev && info->link)
+		tdev = __dev_get_by_index(tunnel->net, info->link);
 
 	if (tdev) {
 		hlen = tdev->hard_header_len + tdev->needed_headroom;
 		mtu = tdev->mtu;
 	}
-	dev->iflink = tunnel->parms.link;
+	dev->iflink = info->link;
 
 	dev->needed_headroom = t_hlen + hlen;
 	mtu -= (dev->hard_header_len + t_hlen);
@@ -402,13 +444,15 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 
 static struct ip_tunnel *ip_tunnel_create(struct net *net,
 					  struct ip_tunnel_net *itn,
-					  struct ip_tunnel_parm *parms)
+					  char *dev_name,
+					  struct tunnel_info *info)
 {
 	struct ip_tunnel *nt;
 	struct net_device *dev;
 
 	BUG_ON(!itn->fb_tunnel_dev);
-	dev = __ip_tunnel_create(net, itn->fb_tunnel_dev->rtnl_link_ops, parms);
+	dev = __ip_tunnel_create(net, itn->fb_tunnel_dev->rtnl_link_ops,
+				 dev_name, info);
 	if (IS_ERR(dev))
 		return ERR_CAST(dev);
 
@@ -422,6 +466,7 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		  const struct tnl_ptk_info *tpi, bool log_ecn_error)
 {
+	struct tunnel_info *info = &tunnel->info;
 	struct pcpu_sw_netstats *tstats;
 	const struct iphdr *iph = ip_hdr(skb);
 	int err;
@@ -433,14 +478,14 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	}
 #endif
 
-	if ((!(tpi->flags&TUNNEL_CSUM) &&  (tunnel->parms.i_flags&TUNNEL_CSUM)) ||
-	     ((tpi->flags&TUNNEL_CSUM) && !(tunnel->parms.i_flags&TUNNEL_CSUM))) {
+	if ((!(tpi->flags&TUNNEL_CSUM) &&  (info->i_flags&TUNNEL_CSUM)) ||
+	    ((tpi->flags&TUNNEL_CSUM) && !(info->i_flags&TUNNEL_CSUM))) {
 		tunnel->dev->stats.rx_crc_errors++;
 		tunnel->dev->stats.rx_errors++;
 		goto drop;
 	}
 
-	if (tunnel->parms.i_flags&TUNNEL_SEQ) {
+	if (info->i_flags&TUNNEL_SEQ) {
 		if (!(tpi->flags&TUNNEL_SEQ) ||
 		    (tunnel->i_seqno && (s32)(ntohl(tpi->seq) - tunnel->i_seqno) < 0)) {
 			tunnel->dev->stats.rx_fifo_errors++;
@@ -616,8 +661,8 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 
 		if (rt6 && mtu < dst_mtu(skb_dst(skb)) &&
 			   mtu >= IPV6_MIN_MTU) {
-			if ((tunnel->parms.iph.daddr &&
-			    !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
+			if ((tunnel->info.daddr &&
+			    !ipv4_is_multicast(tunnel->info.daddr)) ||
 			    rt6->rt6i_dst.plen == 128) {
 				rt6->rt6i_flags |= RTF_MODIFIED;
 				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
@@ -635,23 +680,21 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 }
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
-		    const struct iphdr *tnl_params, u8 protocol)
+		    __be32 saddr, __be32 dst, u8 tos, u8 ttl, __be16 df,
+		    u8 protocol)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct tunnel_info *info = &tunnel->info;
 	const struct iphdr *inner_iph;
 	struct flowi4 fl4;
-	u8     tos, ttl;
-	__be16 df;
 	struct rtable *rt;		/* Route to the other host */
 	unsigned int max_headroom;	/* The extra header space needed */
-	__be32 dst;
 	int err;
 	bool connected;
 
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
-	connected = (tunnel->parms.iph.daddr != 0);
+	connected = (tunnel->info.daddr != 0);
 
-	dst = tnl_params->daddr;
 	if (dst == 0) {
 		/* NBMA tunnel */
 
@@ -701,7 +744,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		connected = false;
 	}
 
-	tos = tnl_params->tos;
 	if (tos & 0x1) {
 		tos &= ~0x1;
 		if (skb->protocol == htons(ETH_P_IP)) {
@@ -713,8 +755,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
-			 tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link);
+	init_tunnel_flow(&fl4, protocol, dst, saddr,
+			 info->o_key, RT_TOS(tos), info->link);
 
 	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0)
 		goto tx_error;
@@ -738,7 +780,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	if (tnl_update_pmtu(dev, skb, rt, tnl_params->frag_off)) {
+	if (tnl_update_pmtu(dev, skb, rt, df)) {
 		ip_rt_put(rt);
 		goto tx_error;
 	}
@@ -755,7 +797,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	tos = ip_tunnel_ecn_encap(tos, inner_iph, skb);
-	ttl = tnl_params->ttl;
 	if (ttl == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
 			ttl = inner_iph->ttl;
@@ -767,7 +808,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 			ttl = ip4_dst_hoplimit(&rt->dst);
 	}
 
-	df = tnl_params->frag_off;
 	if (skb->protocol == htons(ETH_P_IP))
 		df |= (inner_iph->frag_off&htons(IP_DF));
 
@@ -802,28 +842,28 @@ EXPORT_SYMBOL_GPL(ip_tunnel_xmit);
 static void ip_tunnel_update(struct ip_tunnel_net *itn,
 			     struct ip_tunnel *t,
 			     struct net_device *dev,
-			     struct ip_tunnel_parm *p,
+			     struct tunnel_info *info,
 			     bool set_mtu)
 {
 	ip_tunnel_del(t);
-	t->parms.iph.saddr = p->iph.saddr;
-	t->parms.iph.daddr = p->iph.daddr;
-	t->parms.i_key = p->i_key;
-	t->parms.o_key = p->o_key;
+	t->info.saddr = info->saddr;
+	t->info.daddr = info->daddr;
+	t->info.i_key = info->i_key;
+	t->info.o_key = info->o_key;
 	if (dev->type != ARPHRD_ETHER) {
-		memcpy(dev->dev_addr, &p->iph.saddr, 4);
-		memcpy(dev->broadcast, &p->iph.daddr, 4);
+		memcpy(dev->dev_addr, &info->saddr, 4);
+		memcpy(dev->broadcast, &info->daddr, 4);
 	}
 	ip_tunnel_add(itn, t);
 
-	t->parms.iph.ttl = p->iph.ttl;
-	t->parms.iph.tos = p->iph.tos;
-	t->parms.iph.frag_off = p->iph.frag_off;
+	t->info.ttl = info->ttl;
+	t->info.tos = info->tos;
+	t->info.df = info->df;
 
-	if (t->parms.link != p->link) {
+	if (t->info.link != info->link) {
 		int mtu;
 
-		t->parms.link = p->link;
+		t->info.link = info->link;
 		mtu = ip_tunnel_bind_dev(dev);
 		if (set_mtu)
 			dev->mtu = mtu;
@@ -832,7 +872,8 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 	netdev_state_change(dev);
 }
 
-int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
+int ip_tunnel_ioctl(struct net_device *dev, char dev_name[],
+		    struct tunnel_info *info, int cmd)
 {
 	int err = 0;
 	struct ip_tunnel *t = netdev_priv(dev);
@@ -843,11 +884,12 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		if (dev == itn->fb_tunnel_dev) {
-			t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
+			t = ip_tunnel_find(itn, info, itn->fb_tunnel_dev->type);
 			if (t == NULL)
 				t = netdev_priv(dev);
 		}
-		memcpy(p, &t->parms, sizeof(*p));
+		strlcpy(dev_name, t->dev->name, IFNAMSIZ);
+		memcpy(info, &t->info, sizeof(*info));
 		break;
 
 	case SIOCADDTUNNEL:
@@ -855,20 +897,20 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 		err = -EPERM;
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			goto done;
-		if (p->iph.ttl)
-			p->iph.frag_off |= htons(IP_DF);
-		if (!(p->i_flags & VTI_ISVTI)) {
-			if (!(p->i_flags & TUNNEL_KEY))
-				p->i_key = 0;
-			if (!(p->o_flags & TUNNEL_KEY))
-				p->o_key = 0;
+		if (info->ttl)
+			info->df |= htons(IP_DF);
+		if (!(info->i_flags & VTI_ISVTI)) {
+			if (!(info->i_flags & TUNNEL_KEY))
+				info->i_key = 0;
+			if (!(info->o_flags & TUNNEL_KEY))
+				info->o_key = 0;
 		}
 
-		t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
+		t = ip_tunnel_find(itn, info, itn->fb_tunnel_dev->type);
 
 		if (cmd == SIOCADDTUNNEL) {
 			if (!t) {
-				t = ip_tunnel_create(net, itn, p);
+				t = ip_tunnel_create(net, itn, dev_name, info);
 				err = PTR_ERR_OR_ZERO(t);
 				break;
 			}
@@ -885,9 +927,9 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 			} else {
 				unsigned int nflags = 0;
 
-				if (ipv4_is_multicast(p->iph.daddr))
+				if (ipv4_is_multicast(info->daddr))
 					nflags = IFF_BROADCAST;
-				else if (p->iph.daddr)
+				else if (info->daddr)
 					nflags = IFF_POINTOPOINT;
 
 				if ((dev->flags^nflags)&(IFF_POINTOPOINT|IFF_BROADCAST)) {
@@ -901,7 +943,7 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 
 		if (t) {
 			err = 0;
-			ip_tunnel_update(itn, t, dev, p, true);
+			ip_tunnel_update(itn, t, dev, info, true);
 		} else {
 			err = -ENOENT;
 		}
@@ -914,7 +956,7 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 
 		if (dev == itn->fb_tunnel_dev) {
 			err = -ENOENT;
-			t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
+			t = ip_tunnel_find(itn, info, itn->fb_tunnel_dev->type);
 			if (t == NULL)
 				goto done;
 			err = -EPERM;
@@ -981,10 +1023,10 @@ struct net *ip_tunnel_get_link_net(const struct net_device *dev)
 EXPORT_SYMBOL(ip_tunnel_get_link_net);
 
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
-				  struct rtnl_link_ops *ops, char *devname)
+		       struct rtnl_link_ops *ops, char *dev_name)
 {
 	struct ip_tunnel_net *itn = net_generic(net, ip_tnl_net_id);
-	struct ip_tunnel_parm parms;
+	struct tunnel_info info;
 	unsigned int i;
 
 	for (i = 0; i < IP_TNL_HASH_SIZE; i++)
@@ -995,12 +1037,9 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 		return 0;
 	}
 
-	memset(&parms, 0, sizeof(parms));
-	if (devname)
-		strlcpy(parms.name, devname, IFNAMSIZ);
-
+	memset(&info, 0, sizeof(info));
 	rtnl_lock();
-	itn->fb_tunnel_dev = __ip_tunnel_create(net, ops, &parms);
+	itn->fb_tunnel_dev = __ip_tunnel_create(net, ops, dev_name, &info);
 	/* FB netdevice is special: we have one, and only one per netns.
 	 * Allowing to move it to another netns is clearly unsafe.
 	 */
@@ -1052,7 +1091,7 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops)
 EXPORT_SYMBOL_GPL(ip_tunnel_delete_net);
 
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
-		      struct ip_tunnel_parm *p)
+		      struct tunnel_info *info)
 {
 	struct ip_tunnel *nt;
 	struct net *net = dev_net(dev);
@@ -1063,11 +1102,11 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 	nt = netdev_priv(dev);
 	itn = net_generic(net, nt->ip_tnl_net_id);
 
-	if (ip_tunnel_find(itn, p, dev->type))
+	if (ip_tunnel_find(itn, info, dev->type))
 		return -EEXIST;
 
 	nt->net = net;
-	nt->parms = *p;
+	nt->info = *info;
 	err = register_netdevice(dev);
 	if (err)
 		goto out;
@@ -1087,7 +1126,7 @@ out:
 EXPORT_SYMBOL_GPL(ip_tunnel_newlink);
 
 int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
-			 struct ip_tunnel_parm *p)
+			 struct tunnel_info *info)
 {
 	struct ip_tunnel *t;
 	struct ip_tunnel *tunnel = netdev_priv(dev);
@@ -1097,7 +1136,7 @@ int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 	if (dev == itn->fb_tunnel_dev)
 		return -EINVAL;
 
-	t = ip_tunnel_find(itn, p, dev->type);
+	t = ip_tunnel_find(itn, info, dev->type);
 
 	if (t) {
 		if (t->dev != dev)
@@ -1108,9 +1147,9 @@ int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 		if (dev->type != ARPHRD_ETHER) {
 			unsigned int nflags = 0;
 
-			if (ipv4_is_multicast(p->iph.daddr))
+			if (ipv4_is_multicast(info->daddr))
 				nflags = IFF_BROADCAST;
-			else if (p->iph.daddr)
+			else if (info->daddr)
 				nflags = IFF_POINTOPOINT;
 
 			if ((dev->flags ^ nflags) &
@@ -1119,7 +1158,7 @@ int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 		}
 	}
 
-	ip_tunnel_update(itn, t, dev, p, !tb[IFLA_MTU]);
+	ip_tunnel_update(itn, t, dev, info, !tb[IFLA_MTU]);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_changelink);
@@ -1127,7 +1166,6 @@ EXPORT_SYMBOL_GPL(ip_tunnel_changelink);
 int ip_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct iphdr *iph = &tunnel->parms.iph;
 	int err;
 
 	dev->destructor	= ip_tunnel_dev_free;
@@ -1150,10 +1188,6 @@ int ip_tunnel_init(struct net_device *dev)
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
-	strcpy(tunnel->parms.name, dev->name);
-	iph->version		= 4;
-	iph->ihl		= 5;
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 94efe14..f25222d 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -65,7 +65,7 @@ static int vti_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 			goto drop;
 
 		XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = tunnel;
-		skb->mark = be32_to_cpu(tunnel->parms.i_key);
+		skb->mark = be32_to_cpu(tunnel->info.i_key);
 
 		return xfrm_input(skb, nexthdr, spi, encap_type);
 	}
@@ -148,7 +148,7 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 			    struct flowi *fl)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct ip_tunnel_parm *parms = &tunnel->parms;
+	struct tunnel_info *info = &tunnel->info;
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *tdev;	/* Device to other host */
 	int err;
@@ -165,7 +165,7 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error_icmp;
 	}
 
-	if (!vti_state_check(dst->xfrm, parms->iph.daddr, parms->iph.saddr)) {
+	if (!vti_state_check(dst->xfrm, info->daddr, info->saddr)) {
 		dev->stats.tx_carrier_errors++;
 		dst_release(dst);
 		goto tx_error_icmp;
@@ -216,7 +216,7 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	memset(&fl, 0, sizeof(fl));
 
-	skb->mark = be32_to_cpu(tunnel->parms.o_key);
+	skb->mark = be32_to_cpu(tunnel->info.o_key);
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -255,7 +255,7 @@ static int vti4_err(struct sk_buff *skb, u32 info)
 	if (!tunnel)
 		return -1;
 
-	mark = be32_to_cpu(tunnel->parms.o_key);
+	mark = be32_to_cpu(tunnel->info.o_key);
 
 	switch (protocol) {
 	case IPPROTO_ESP:
@@ -301,8 +301,9 @@ static int vti4_err(struct sk_buff *skb, u32 info)
 static int
 vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	int err = 0;
+	struct tunnel_info info;
 	struct ip_tunnel_parm p;
+	int err = 0;
 
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
@@ -320,10 +321,12 @@ vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	p.i_flags = VTI_ISVTI;
 
-	err = ip_tunnel_ioctl(dev, &p, cmd);
+	ip_tunnel_parm_to_info(&p, &info);
+	err = ip_tunnel_ioctl(dev, p.name, &info, cmd);
 	if (err)
 		return err;
 
+	tunnel_info_to_parm(p.name, &info, &p);
 	if (cmd != SIOCDELTUNNEL) {
 		p.i_flags |= GRE_KEY;
 		p.o_flags |= GRE_KEY;
@@ -353,10 +356,10 @@ static void vti_tunnel_setup(struct net_device *dev)
 static int vti_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct iphdr *iph = &tunnel->parms.iph;
+	struct tunnel_info *info = &tunnel->info;
 
-	memcpy(dev->dev_addr, &iph->saddr, 4);
-	memcpy(dev->broadcast, &iph->daddr, 4);
+	memcpy(dev->dev_addr, &info->saddr, 4);
+	memcpy(dev->broadcast, &info->daddr, 4);
 
 	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
 	dev->mtu		= ETH_DATA_LEN;
@@ -372,11 +375,9 @@ static int vti_tunnel_init(struct net_device *dev)
 static void __net_init vti_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct iphdr *iph = &tunnel->parms.iph;
+	struct tunnel_info *info = &tunnel->info;
 
-	iph->version		= 4;
-	iph->protocol		= IPPROTO_IPIP;
-	iph->ihl		= 5;
+	info->protocol		= IPPROTO_IPIP;
 }
 
 static struct xfrm4_protocol vti_esp4_protocol __read_mostly = {
@@ -435,50 +436,50 @@ static int vti_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static void vti_netlink_parms(struct nlattr *data[],
-			      struct ip_tunnel_parm *parms)
+			      struct tunnel_info *info)
 {
-	memset(parms, 0, sizeof(*parms));
+	memset(info, 0, sizeof(*info));
 
-	parms->iph.protocol = IPPROTO_IPIP;
+	info->protocol = IPPROTO_IPIP;
 
 	if (!data)
 		return;
 
-	parms->i_flags = VTI_ISVTI;
+	info->i_flags = VTI_ISVTI;
 
 	if (data[IFLA_VTI_LINK])
-		parms->link = nla_get_u32(data[IFLA_VTI_LINK]);
+		info->link = nla_get_u32(data[IFLA_VTI_LINK]);
 
 	if (data[IFLA_VTI_IKEY])
-		parms->i_key = nla_get_be32(data[IFLA_VTI_IKEY]);
+		info->i_key = nla_get_be32(data[IFLA_VTI_IKEY]);
 
 	if (data[IFLA_VTI_OKEY])
-		parms->o_key = nla_get_be32(data[IFLA_VTI_OKEY]);
+		info->o_key = nla_get_be32(data[IFLA_VTI_OKEY]);
 
 	if (data[IFLA_VTI_LOCAL])
-		parms->iph.saddr = nla_get_be32(data[IFLA_VTI_LOCAL]);
+		info->saddr = nla_get_be32(data[IFLA_VTI_LOCAL]);
 
 	if (data[IFLA_VTI_REMOTE])
-		parms->iph.daddr = nla_get_be32(data[IFLA_VTI_REMOTE]);
+		info->daddr = nla_get_be32(data[IFLA_VTI_REMOTE]);
 
 }
 
 static int vti_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
-	struct ip_tunnel_parm parms;
+	struct tunnel_info info;
 
-	vti_netlink_parms(data, &parms);
-	return ip_tunnel_newlink(dev, tb, &parms);
+	vti_netlink_parms(data, &info);
+	return ip_tunnel_newlink(dev, tb, &info);
 }
 
 static int vti_changelink(struct net_device *dev, struct nlattr *tb[],
 			  struct nlattr *data[])
 {
-	struct ip_tunnel_parm p;
+	struct tunnel_info info;
 
-	vti_netlink_parms(data, &p);
-	return ip_tunnel_changelink(dev, tb, &p);
+	vti_netlink_parms(data, &info);
+	return ip_tunnel_changelink(dev, tb, &info);
 }
 
 static size_t vti_get_size(const struct net_device *dev)
@@ -500,13 +501,13 @@ static size_t vti_get_size(const struct net_device *dev)
 static int vti_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
-	struct ip_tunnel_parm *p = &t->parms;
+	struct tunnel_info *info = &t->info;
 
-	nla_put_u32(skb, IFLA_VTI_LINK, p->link);
-	nla_put_be32(skb, IFLA_VTI_IKEY, p->i_key);
-	nla_put_be32(skb, IFLA_VTI_OKEY, p->o_key);
-	nla_put_be32(skb, IFLA_VTI_LOCAL, p->iph.saddr);
-	nla_put_be32(skb, IFLA_VTI_REMOTE, p->iph.daddr);
+	nla_put_u32(skb, IFLA_VTI_LINK, info->link);
+	nla_put_be32(skb, IFLA_VTI_IKEY, info->i_key);
+	nla_put_be32(skb, IFLA_VTI_OKEY, info->o_key);
+	nla_put_be32(skb, IFLA_VTI_LOCAL, info->saddr);
+	nla_put_be32(skb, IFLA_VTI_REMOTE, info->daddr);
 
 	return 0;
 }
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index b58d668..b14b33d 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -149,23 +149,23 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
 		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->parms.link, 0, IPPROTO_IPIP, 0);
+				 t->info.link, 0, IPPROTO_IPIP, 0);
 		err = 0;
 		goto out;
 	}
 
 	if (type == ICMP_REDIRECT) {
-		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
+		ipv4_redirect(skb, dev_net(skb->dev), t->info.link, 0,
 			      IPPROTO_IPIP, 0);
 		err = 0;
 		goto out;
 	}
 
-	if (t->parms.iph.daddr == 0)
+	if (t->info.daddr == 0)
 		goto out;
 
 	err = 0;
-	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
+	if (t->info.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
@@ -215,7 +215,7 @@ drop:
 static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr  *tiph = &tunnel->parms.iph;
+	struct tunnel_info *info = &tunnel->info;
 
 	if (unlikely(skb->protocol != htons(ETH_P_IP)))
 		goto tx_error;
@@ -226,7 +226,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
 
-	ip_tunnel_xmit(skb, dev, tiph, tiph->protocol);
+	ip_tunnel_xmit(skb, dev, info->saddr, info->daddr, info->tos,
+		       info->ttl, info->df, IPPROTO_IPIP);
 	return NETDEV_TX_OK;
 
 tx_error:
@@ -239,8 +240,9 @@ out:
 static int
 ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	int err = 0;
+	struct tunnel_info info;
 	struct ip_tunnel_parm p;
+	int err = 0;
 
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
@@ -251,14 +253,19 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EINVAL;
 	}
 
-	p.i_key = p.o_key = p.i_flags = p.o_flags = 0;
+	p.i_key = 0;
+	p.o_key = 0;
+	p.i_flags = 0;
+	p.o_flags = 0;
 	if (p.iph.ttl)
 		p.iph.frag_off |= htons(IP_DF);
 
-	err = ip_tunnel_ioctl(dev, &p, cmd);
+	ip_tunnel_parm_to_info(&p, &info);
+	err = ip_tunnel_ioctl(dev, p.name, &info, cmd);
 	if (err)
 		return err;
 
+	tunnel_info_to_parm(p.name, &info, &p);
 	if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
 		return -EFAULT;
 
@@ -300,47 +307,44 @@ static int ipip_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
-	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
+	memcpy(dev->dev_addr, &tunnel->info.saddr, 4);
+	memcpy(dev->broadcast, &tunnel->info.daddr, 4);
 
 	tunnel->tun_hlen = 0;
 	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
-	tunnel->parms.iph.protocol = IPPROTO_IPIP;
 	return ip_tunnel_init(dev);
 }
 
 static void ipip_netlink_parms(struct nlattr *data[],
-			       struct ip_tunnel_parm *parms)
+			       struct tunnel_info *info)
 {
-	memset(parms, 0, sizeof(*parms));
+	memset(info, 0, sizeof(*info));
 
-	parms->iph.version = 4;
-	parms->iph.protocol = IPPROTO_IPIP;
-	parms->iph.ihl = 5;
+	info->protocol = IPPROTO_IPIP;
 
 	if (!data)
 		return;
 
 	if (data[IFLA_IPTUN_LINK])
-		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
+		info->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
 
 	if (data[IFLA_IPTUN_LOCAL])
-		parms->iph.saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
+		info->saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
 
 	if (data[IFLA_IPTUN_REMOTE])
-		parms->iph.daddr = nla_get_be32(data[IFLA_IPTUN_REMOTE]);
+		info->daddr = nla_get_be32(data[IFLA_IPTUN_REMOTE]);
 
 	if (data[IFLA_IPTUN_TTL]) {
-		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
-		if (parms->iph.ttl)
-			parms->iph.frag_off = htons(IP_DF);
+		info->ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
+		if (info->ttl)
+			info->df = htons(IP_DF);
 	}
 
 	if (data[IFLA_IPTUN_TOS])
-		parms->iph.tos = nla_get_u8(data[IFLA_IPTUN_TOS]);
+		info->tos = nla_get_u8(data[IFLA_IPTUN_TOS]);
 
 	if (!data[IFLA_IPTUN_PMTUDISC] || nla_get_u8(data[IFLA_IPTUN_PMTUDISC]))
-		parms->iph.frag_off = htons(IP_DF);
+		info->df = htons(IP_DF);
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -380,7 +384,7 @@ static bool ipip_netlink_encap_parms(struct nlattr *data[],
 static int ipip_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
-	struct ip_tunnel_parm p;
+	struct tunnel_info info;
 	struct ip_tunnel_encap ipencap;
 
 	if (ipip_netlink_encap_parms(data, &ipencap)) {
@@ -391,14 +395,14 @@ static int ipip_newlink(struct net *src_net, struct net_device *dev,
 			return err;
 	}
 
-	ipip_netlink_parms(data, &p);
-	return ip_tunnel_newlink(dev, tb, &p);
+	ipip_netlink_parms(data, &info);
+	return ip_tunnel_newlink(dev, tb, &info);
 }
 
 static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 			   struct nlattr *data[])
 {
-	struct ip_tunnel_parm p;
+	struct tunnel_info info;
 	struct ip_tunnel_encap ipencap;
 
 	if (ipip_netlink_encap_parms(data, &ipencap)) {
@@ -409,13 +413,13 @@ static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 			return err;
 	}
 
-	ipip_netlink_parms(data, &p);
+	ipip_netlink_parms(data, &info);
 
-	if (((dev->flags & IFF_POINTOPOINT) && !p.iph.daddr) ||
-	    (!(dev->flags & IFF_POINTOPOINT) && p.iph.daddr))
+	if (((dev->flags & IFF_POINTOPOINT) && !info.daddr) ||
+	    (!(dev->flags & IFF_POINTOPOINT) && info.daddr))
 		return -EINVAL;
 
-	return ip_tunnel_changelink(dev, tb, &p);
+	return ip_tunnel_changelink(dev, tb, &info);
 }
 
 static size_t ipip_get_size(const struct net_device *dev)
@@ -447,15 +451,15 @@ static size_t ipip_get_size(const struct net_device *dev)
 static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct ip_tunnel_parm *parm = &tunnel->parms;
+	struct tunnel_info *info = &tunnel->info;
 
-	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
-	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
-	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
-	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
-	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
+	if (nla_put_u32(skb, IFLA_IPTUN_LINK, info->link) ||
+	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, info->saddr) ||
+	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, info->daddr) ||
+	    nla_put_u8(skb, IFLA_IPTUN_TTL, info->ttl) ||
+	    nla_put_u8(skb, IFLA_IPTUN_TOS, info->tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
-		       !!(parm->iph.frag_off & htons(IP_DF))))
+		       !!(info->df & htons(IP_DF))))
 		goto nla_put_failure;
 
 	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE,
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3cc197c..02eb387 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -99,21 +99,21 @@ static struct ip_tunnel *ipip6_tunnel_lookup(struct net *net,
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_r_l[h0 ^ h1]) {
-		if (local == t->parms.iph.saddr &&
-		    remote == t->parms.iph.daddr &&
-		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
+		if (local == t->info.saddr &&
+		    remote == t->info.daddr &&
+		    (!dev || !t->info.link || dev->ifindex == t->info.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_r[h0]) {
-		if (remote == t->parms.iph.daddr &&
-		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
+		if (remote == t->info.daddr &&
+		    (!dev || !t->info.link || dev->ifindex == t->info.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_l[h1]) {
-		if (local == t->parms.iph.saddr &&
-		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
+		if (local == t->info.saddr &&
+		    (!dev || !t->info.link || dev->ifindex == t->info.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
@@ -124,10 +124,9 @@ static struct ip_tunnel *ipip6_tunnel_lookup(struct net *net,
 }
 
 static struct ip_tunnel __rcu **__ipip6_bucket(struct sit_net *sitn,
-		struct ip_tunnel_parm *parms)
+					       __be32 remote,
+					       __be32 local)
 {
-	__be32 remote = parms->iph.daddr;
-	__be32 local = parms->iph.saddr;
 	unsigned int h = 0;
 	int prio = 0;
 
@@ -145,7 +144,7 @@ static struct ip_tunnel __rcu **__ipip6_bucket(struct sit_net *sitn,
 static inline struct ip_tunnel __rcu **ipip6_bucket(struct sit_net *sitn,
 		struct ip_tunnel *t)
 {
-	return __ipip6_bucket(sitn, &t->parms);
+	return __ipip6_bucket(sitn, t->info.daddr, t->info.saddr);
 }
 
 static void ipip6_tunnel_unlink(struct sit_net *sitn, struct ip_tunnel *t)
@@ -188,17 +187,20 @@ static void ipip6_tunnel_clone_6rd(struct net_device *dev, struct sit_net *sitn)
 #endif
 }
 
-static int ipip6_tunnel_create(struct net_device *dev)
+static int ipip6_tunnel_create(struct net_device *dev,
+			       struct ip_tunnel_parm *parms)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 	int err;
 
-	memcpy(dev->dev_addr, &t->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &t->parms.iph.daddr, 4);
+	ip_tunnel_parm_to_info(parms, &t->info);
+
+	memcpy(dev->dev_addr, &t->info.saddr, 4);
+	memcpy(dev->broadcast, &t->info.daddr, 4);
 
-	if ((__force u16)t->parms.i_flags & SIT_ISATAP)
+	if ((__force u16)t->info.i_flags & SIT_ISATAP)
 		dev->priv_flags |= IFF_ISATAP;
 
 	err = register_netdevice(dev);
@@ -229,12 +231,12 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	char name[IFNAMSIZ];
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
-	for (tp = __ipip6_bucket(sitn, parms);
+	for (tp = __ipip6_bucket(sitn, remote, local);
 	    (t = rtnl_dereference(*tp)) != NULL;
 	     tp = &t->next) {
-		if (local == t->parms.iph.saddr &&
-		    remote == t->parms.iph.daddr &&
-		    parms->link == t->parms.link) {
+		if (local == t->info.saddr &&
+		    remote == t->info.daddr &&
+		    parms->link == t->info.link) {
 			if (create)
 				return NULL;
 			else
@@ -258,8 +260,7 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 
 	nt = netdev_priv(dev);
 
-	nt->parms = *parms;
-	if (ipip6_tunnel_create(dev) < 0)
+	if (ipip6_tunnel_create(dev, parms) < 0)
 		goto failed_free;
 
 	return nt;
@@ -560,25 +561,25 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
 		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->parms.link, 0, IPPROTO_IPV6, 0);
+				 t->info.link, 0, IPPROTO_IPV6, 0);
 		err = 0;
 		goto out;
 	}
 	if (type == ICMP_REDIRECT) {
-		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
+		ipv4_redirect(skb, dev_net(skb->dev), t->info.link, 0,
 			      IPPROTO_IPV6, 0);
 		err = 0;
 		goto out;
 	}
 
-	if (t->parms.iph.daddr == 0)
+	if (t->info.daddr == 0)
 		goto out;
 
 	err = 0;
 	if (!ipip6_err_gen_icmpv6_unreach(skb))
 		goto out;
 
-	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
+	if (t->info.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
@@ -674,8 +675,8 @@ static int ipip6_rcv(struct sk_buff *skb)
 	if (tunnel != NULL) {
 		struct pcpu_sw_netstats *tstats;
 
-		if (tunnel->parms.iph.protocol != IPPROTO_IPV6 &&
-		    tunnel->parms.iph.protocol != 0)
+		if (tunnel->info.protocol != IPPROTO_IPV6 &&
+		    tunnel->info.protocol != 0)
 			goto out;
 
 		skb->mac_header = skb->network_header;
@@ -734,8 +735,8 @@ static int ipip_rcv(struct sk_buff *skb)
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
-		if (tunnel->parms.iph.protocol != IPPROTO_IPIP &&
-		    tunnel->parms.iph.protocol != 0)
+		if (tunnel->info.protocol != IPPROTO_IPIP &&
+		    tunnel->info.protocol != 0)
 			goto drop;
 
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
@@ -807,14 +808,14 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 				     struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr  *tiph = &tunnel->parms.iph;
+	const struct tunnel_info *info = &tunnel->info;
 	const struct ipv6hdr *iph6 = ipv6_hdr(skb);
-	u8     tos = tunnel->parms.iph.tos;
-	__be16 df = tiph->frag_off;
+	u8     tos = tunnel->info.tos;
+	__be16 df = info->df;
 	struct rtable *rt;		/* Route to the other host */
 	struct net_device *tdev;	/* Device to other host */
 	unsigned int max_headroom;	/* The extra header space needed */
-	__be32 dst = tiph->daddr;
+	__be32 dst = info->daddr;
 	struct flowi4 fl4;
 	int    mtu;
 	const struct in6_addr *addr6;
@@ -891,10 +892,10 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	rt = ip_route_output_ports(tunnel->net, &fl4, NULL,
-				   dst, tiph->saddr,
+				   dst, info->saddr,
 				   0, 0,
 				   IPPROTO_IPV6, RT_TOS(tos),
-				   tunnel->parms.link);
+				   tunnel->info.link);
 	if (IS_ERR(rt)) {
 		dev->stats.tx_carrier_errors++;
 		goto tx_error_icmp;
@@ -932,7 +933,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			df = 0;
 		}
 
-		if (tunnel->parms.iph.daddr && skb_dst(skb))
+		if (tunnel->info.daddr && skb_dst(skb))
 			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 		if (skb->len > mtu && !skb_is_gso(skb)) {
@@ -971,7 +972,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		skb = new_skb;
 		iph6 = ipv6_hdr(skb);
 	}
-	ttl = tiph->ttl;
+	ttl = info->ttl;
 	if (ttl == 0)
 		ttl = iph6->hop_limit;
 	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
@@ -1001,15 +1002,15 @@ out:
 static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr  *tiph = &tunnel->parms.iph;
+	const struct tunnel_info *info = &tunnel->info;
 
 	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
 	if (IS_ERR(skb))
 		goto out;
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
-
-	ip_tunnel_xmit(skb, dev, tiph, IPPROTO_IPIP);
+	ip_tunnel_xmit(skb, dev, info->saddr, info->daddr, info->tos, info->ttl,
+		       info->df, IPPROTO_IPIP);
 	return NETDEV_TX_OK;
 out:
 	dev->stats.tx_errors++;
@@ -1043,20 +1044,20 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
-	const struct iphdr *iph;
+	struct tunnel_info *info;
 	struct flowi4 fl4;
 
 	tunnel = netdev_priv(dev);
-	iph = &tunnel->parms.iph;
+	info = &tunnel->info;
 
-	if (iph->daddr) {
+	if (info->daddr) {
 		struct rtable *rt = ip_route_output_ports(tunnel->net, &fl4,
 							  NULL,
-							  iph->daddr, iph->saddr,
+							  info->daddr, info->saddr,
 							  0, 0,
 							  IPPROTO_IPV6,
-							  RT_TOS(iph->tos),
-							  tunnel->parms.link);
+							  RT_TOS(info->tos),
+							  tunnel->info.link);
 
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
@@ -1065,8 +1066,8 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 		dev->flags |= IFF_POINTOPOINT;
 	}
 
-	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(tunnel->net, tunnel->parms.link);
+	if (!tdev && tunnel->info.link)
+		tdev = __dev_get_by_index(tunnel->net, tunnel->info.link);
 
 	if (tdev) {
 		int t_hlen = tunnel->hlen + sizeof(struct iphdr);
@@ -1076,7 +1077,7 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 		if (dev->mtu < IPV6_MIN_MTU)
 			dev->mtu = IPV6_MIN_MTU;
 	}
-	dev->iflink = tunnel->parms.link;
+	dev->iflink = tunnel->info.link;
 }
 
 static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
@@ -1086,15 +1087,15 @@ static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
 
 	ipip6_tunnel_unlink(sitn, t);
 	synchronize_net();
-	t->parms.iph.saddr = p->iph.saddr;
-	t->parms.iph.daddr = p->iph.daddr;
+	t->info.saddr = p->iph.saddr;
+	t->info.daddr = p->iph.daddr;
 	memcpy(t->dev->dev_addr, &p->iph.saddr, 4);
 	memcpy(t->dev->broadcast, &p->iph.daddr, 4);
 	ipip6_tunnel_link(sitn, t);
-	t->parms.iph.ttl = p->iph.ttl;
-	t->parms.iph.tos = p->iph.tos;
-	if (t->parms.link != p->link) {
-		t->parms.link = p->link;
+	t->info.ttl = p->iph.ttl;
+	t->info.tos = p->iph.tos;
+	if (t->info.link != p->link) {
+		t->info.link = p->link;
 		ipip6_tunnel_bind_dev(t->dev);
 	}
 	ip_tunnel_dst_reset_all(t);
@@ -1164,7 +1165,7 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		err = -EFAULT;
 		if (cmd == SIOCGETTUNNEL) {
-			memcpy(&p, &t->parms, sizeof(p));
+			tunnel_info_to_parm(t->dev->name, &t->info, &p);
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p,
 					 sizeof(p)))
 				goto done;
@@ -1225,7 +1226,8 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		if (t) {
 			err = 0;
-			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
+			tunnel_info_to_parm(t->dev->name, &t->info, &p);
+			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
 				err = -EFAULT;
 		} else
 			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
@@ -1379,7 +1381,6 @@ static int ipip6_tunnel_init(struct net_device *dev)
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
-	strcpy(tunnel->parms.name, dev->name);
 
 	ipip6_tunnel_bind_dev(dev);
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
@@ -1398,17 +1399,15 @@ static int ipip6_tunnel_init(struct net_device *dev)
 static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct iphdr *iph = &tunnel->parms.iph;
+	struct tunnel_info *info = &tunnel->info;
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
 
-	iph->version		= 4;
-	iph->protocol		= IPPROTO_IPV6;
-	iph->ihl		= 5;
-	iph->ttl		= 64;
+	info->protocol		= IPPROTO_IPV6;
+	info->ttl		= 64;
 
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
@@ -1561,6 +1560,7 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 	struct net *net = dev_net(dev);
 	struct ip_tunnel *nt;
 	struct ip_tunnel_encap ipencap;
+	struct ip_tunnel_parm parms;
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd ip6rd;
 #endif
@@ -1574,12 +1574,12 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 			return err;
 	}
 
-	ipip6_netlink_parms(data, &nt->parms);
+	ipip6_netlink_parms(data, &parms);
 
-	if (ipip6_tunnel_locate(net, &nt->parms, 0))
+	if (ipip6_tunnel_locate(net, &parms, 0))
 		return -EEXIST;
 
-	err = ipip6_tunnel_create(dev);
+	err = ipip6_tunnel_create(dev, &parms);
 	if (err < 0)
 		return err;
 
@@ -1680,17 +1680,17 @@ static size_t ipip6_get_size(const struct net_device *dev)
 static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct ip_tunnel_parm *parm = &tunnel->parms;
+	struct tunnel_info *info = &tunnel->info;
 
-	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
-	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
-	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
-	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
-	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
+	if (nla_put_u32(skb, IFLA_IPTUN_LINK, info->link) ||
+	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, info->saddr) ||
+	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, info->daddr) ||
+	    nla_put_u8(skb, IFLA_IPTUN_TTL, info->ttl) ||
+	    nla_put_u8(skb, IFLA_IPTUN_TOS, info->tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
-		       !!(parm->iph.frag_off & htons(IP_DF))) ||
-	    nla_put_u8(skb, IFLA_IPTUN_PROTO, parm->iph.protocol) ||
-	    nla_put_be16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
+		       !!(info->df & htons(IP_DF))) ||
+	    nla_put_u8(skb, IFLA_IPTUN_PROTO, info->protocol) ||
+	    nla_put_be16(skb, IFLA_IPTUN_FLAGS, info->i_flags))
 		goto nla_put_failure;
 
 #ifdef CONFIG_IPV6_SIT_6RD
@@ -1843,8 +1843,6 @@ static int __net_init sit_init_net(struct net *net)
 		goto err_reg_dev;
 
 	t = netdev_priv(sitn->fb_tunnel_dev);
-
-	strcpy(t->parms.name, sitn->fb_tunnel_dev->name);
 	return 0;
 
 err_reg_dev:
-- 
1.9.1
