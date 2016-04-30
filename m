From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH next-next 7/7] gre6: Cleanup GREv6 transmit path, call common GRE functions
Date: Fri, 29 Apr 2016 17:12:21 -0700
Message-ID: <1461975141-954269-8-git-send-email-tom@herbertland.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:27910 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752791AbcD3AOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:14:50 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3U0CAY1027390
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22mf0j8nsk-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:49 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 8cbf76520e6811e6b5d224be0595f910-d43f7c50 for <netdev@vger.kernel.org>;	Fri,
 29 Apr 2016 17:14:48 -0700
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in GREv6 transmit path:
  - Call gre_checksum, remove gre6_checksum
  - Rename ip6gre_xmit2 to __gre6_xmit
  - Call gre_build_header utility function
  - Call ip6_tnl_xmit common function
  - Call ip6_tnl_change_mtu, eliminate ip6gre_tunnel_change_mtu

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_gre.c | 252 +++++++++++------------------------------------------
 1 file changed, 50 insertions(+), 202 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 9b33745..1012774 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -488,199 +488,40 @@ struct ipv6_tel_txoption {
 	__u8 dst_opt[8];
 };
 
-static void init_tel_txopt(struct ipv6_tel_txoption *opt, __u8 encap_limit)
+static int gre_handle_offloads(struct sk_buff *skb, bool csum)
 {
-	memset(opt, 0, sizeof(struct ipv6_tel_txoption));
-
-	opt->dst_opt[2] = IPV6_TLV_TNL_ENCAP_LIMIT;
-	opt->dst_opt[3] = 1;
-	opt->dst_opt[4] = encap_limit;
-	opt->dst_opt[5] = IPV6_TLV_PADN;
-	opt->dst_opt[6] = 1;
-
-	opt->ops.dst0opt = (struct ipv6_opt_hdr *) opt->dst_opt;
-	opt->ops.opt_nflen = 8;
+	return iptunnel_handle_offloads(skb,
+					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
 }
 
-static __sum16 gre6_checksum(struct sk_buff *skb)
-{
-	__wsum csum;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		csum = lco_csum(skb);
-	else
-		csum = skb_checksum(skb, sizeof(struct ipv6hdr),
-				    skb->len - sizeof(struct ipv6hdr), 0);
-	return csum_fold(csum);
-}
-
-static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
-			 struct net_device *dev,
-			 __u8 dsfield,
-			 struct flowi6 *fl6,
-			 int encap_limit,
-			 __u32 *pmtu)
+static netdev_tx_t __gre6_xmit(struct sk_buff *skb,
+			       struct net_device *dev, __u8 dsfield,
+			       struct flowi6 *fl6, int encap_limit,
+			       __u32 *pmtu, __be16 proto)
 {
 	struct ip6_tnl *tunnel = netdev_priv(dev);
-	struct net *net = tunnel->net;
-	struct net_device *tdev;    /* Device to other host */
-	struct ipv6hdr  *ipv6h;     /* Our new IP header */
-	unsigned int min_headroom = 0; /* The extra header space needed */
-	int    gre_hlen;
-	struct ipv6_tel_txoption opt;
-	int    mtu;
-	struct dst_entry *dst = NULL, *ndst = NULL;
-	struct net_device_stats *stats = &tunnel->dev->stats;
-	int err = -1;
-	u8 proto;
-	__be16 protocol;
+	__be16 protocol = (dev->type == ARPHRD_ETHER) ?
+			  htons(ETH_P_TEB) : proto;
 
 	if (dev->type == ARPHRD_ETHER)
 		IPCB(skb)->flags = 0;
 
-	if (dev->header_ops && dev->type == ARPHRD_IP6GRE) {
-		gre_hlen = 0;
-		ipv6h = (struct ipv6hdr *)skb->data;
-		fl6->daddr = ipv6h->daddr;
-	} else {
-		gre_hlen = tunnel->hlen;
+	if (dev->header_ops && dev->type == ARPHRD_IP6GRE)
+		fl6->daddr = ((struct ipv6hdr *)skb->data)->daddr;
+	else
 		fl6->daddr = tunnel->parms.raddr;
-	}
-
-	if (!fl6->flowi6_mark)
-		dst = dst_cache_get(&tunnel->dst_cache);
-
-	if (!dst) {
-		dst = ip6_route_output(net, NULL, fl6);
-
-		if (dst->error)
-			goto tx_err_link_failure;
-		dst = xfrm_lookup(net, dst, flowi6_to_flowi(fl6), NULL, 0);
-		if (IS_ERR(dst)) {
-			err = PTR_ERR(dst);
-			dst = NULL;
-			goto tx_err_link_failure;
-		}
-		ndst = dst;
-	}
-
-	tdev = dst->dev;
-
-	if (tdev == dev) {
-		stats->collisions++;
-		net_warn_ratelimited("%s: Local routing loop detected!\n",
-				     tunnel->parms.name);
-		goto tx_err_dst_release;
-	}
 
-	mtu = dst_mtu(dst) - sizeof(*ipv6h);
-	if (encap_limit >= 0) {
-		min_headroom += 8;
-		mtu -= 8;
-	}
-	if (mtu < IPV6_MIN_MTU)
-		mtu = IPV6_MIN_MTU;
-	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-	if (skb->len > mtu && !skb_is_gso(skb)) {
-		*pmtu = mtu;
-		err = -EMSGSIZE;
-		goto tx_err_dst_release;
-	}
+	if (tunnel->parms.o_flags & TUNNEL_SEQ)
+		tunnel->o_seqno++;
 
-	if (tunnel->err_count > 0) {
-		if (time_before(jiffies,
-				tunnel->err_time + IP6TUNNEL_ERR_TIMEO)) {
-			tunnel->err_count--;
+	/* Push GRE header. */
+	gre_build_header(skb, tunnel->tun_hlen, tunnel->parms.o_flags,
+			 protocol, tunnel->parms.o_key, htonl(tunnel->o_seqno));
 
-			dst_link_failure(skb);
-		} else
-			tunnel->err_count = 0;
-	}
+	skb_set_inner_protocol(skb, proto);
 
-	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(dev)));
-
-	min_headroom += LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_len;
-
-	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
-		int head_delta = SKB_DATA_ALIGN(min_headroom -
-						skb_headroom(skb) +
-						16);
-
-		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
-				       0, GFP_ATOMIC);
-		if (min_headroom > dev->needed_headroom)
-			dev->needed_headroom = min_headroom;
-		if (unlikely(err))
-			goto tx_err_dst_release;
-	}
-
-	if (!fl6->flowi6_mark && ndst)
-		dst_cache_set_ip6(&tunnel->dst_cache, ndst, &fl6->saddr);
-	skb_dst_set(skb, dst);
-
-	proto = NEXTHDR_GRE;
-	if (encap_limit >= 0) {
-		init_tel_txopt(&opt, encap_limit);
-		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
-	}
-
-	err = iptunnel_handle_offloads(skb,
-				       (tunnel->parms.o_flags & GRE_CSUM) ?
-				       SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
-	if (err)
-		goto tx_err_dst_release;
-
-	skb_push(skb, gre_hlen);
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, sizeof(*ipv6h));
-
-	/*
-	 *	Push down and install the IP header.
-	 */
-	ipv6h = ipv6_hdr(skb);
-	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
-	ipv6h->hop_limit = tunnel->parms.hop_limit;
-	ipv6h->nexthdr = proto;
-	ipv6h->saddr = fl6->saddr;
-	ipv6h->daddr = fl6->daddr;
-
-	((__be16 *)(ipv6h + 1))[0] = tunnel->parms.o_flags;
-	protocol = (dev->type == ARPHRD_ETHER) ?
-		    htons(ETH_P_TEB) : skb->protocol;
-	((__be16 *)(ipv6h + 1))[1] = protocol;
-
-	if (tunnel->parms.o_flags&(GRE_KEY|GRE_CSUM|GRE_SEQ)) {
-		__be32 *ptr = (__be32 *)(((u8 *)ipv6h) + tunnel->hlen - 4);
-
-		if (tunnel->parms.o_flags&GRE_SEQ) {
-			++tunnel->o_seqno;
-			*ptr = htonl(tunnel->o_seqno);
-			ptr--;
-		}
-		if (tunnel->parms.o_flags&GRE_KEY) {
-			*ptr = tunnel->parms.o_key;
-			ptr--;
-		}
-		if ((tunnel->parms.o_flags & GRE_CSUM) &&
-		    !(skb_shinfo(skb)->gso_type &
-		      (SKB_GSO_GRE | SKB_GSO_GRE_CSUM))) {
-			*ptr = 0;
-			*(__sum16 *)ptr = gre6_checksum(skb);
-		}
-	}
-
-	skb_set_inner_protocol(skb, protocol);
-
-	ip6tunnel_xmit(NULL, skb, dev);
-	return 0;
-tx_err_link_failure:
-	stats->tx_carrier_errors++;
-	dst_link_failure(skb);
-tx_err_dst_release:
-	dst_release(dst);
-	return err;
+	return ip6_tnl_xmit(skb, dev, dsfield, fl6, encap_limit, pmtu,
+			    NEXTHDR_GRE);
 }
 
 static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
@@ -699,7 +540,6 @@ static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_GRE;
 
 	dsfield = ipv4_get_dsfield(iph);
 
@@ -709,7 +549,12 @@ static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
-	err = ip6gre_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
+	err = gre_handle_offloads(skb, !!(t->parms.o_flags & TUNNEL_CSUM));
+	if (err)
+		return -1;
+
+	err = __gre6_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
+			  skb->protocol);
 	if (err != 0) {
 		/* XXX: send ICMP error even if DF is not set. */
 		if (err == -EMSGSIZE)
@@ -749,7 +594,6 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_GRE;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
@@ -759,7 +603,11 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
-	err = ip6gre_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
+	if (gre_handle_offloads(skb, !!(t->parms.o_flags & TUNNEL_CSUM)))
+		return -1;
+
+	err = __gre6_xmit(skb, dev, dsfield, &fl6, encap_limit,
+			  &mtu, skb->protocol);
 	if (err != 0) {
 		if (err == -EMSGSIZE)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
@@ -803,7 +651,11 @@ static int ip6gre_xmit_other(struct sk_buff *skb, struct net_device *dev)
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 	fl6.flowi6_proto = skb->protocol;
 
-	err = ip6gre_xmit2(skb, dev, 0, &fl6, encap_limit, &mtu);
+	err = gre_handle_offloads(skb, !!(t->parms.o_flags & TUNNEL_CSUM));
+	if (err)
+		return err;
+
+	err = __gre6_xmit(skb, dev, 0, &fl6, encap_limit, &mtu, skb->protocol);
 
 	return err;
 }
@@ -1080,15 +932,6 @@ done:
 	return err;
 }
 
-static int ip6gre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < 68 ||
-	    new_mtu > 0xFFF8 - dev->hard_header_len)
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type,
 			const void *daddr, const void *saddr, unsigned int len)
@@ -1132,7 +975,7 @@ static const struct net_device_ops ip6gre_netdev_ops = {
 	.ndo_uninit		= ip6gre_tunnel_uninit,
 	.ndo_start_xmit		= ip6gre_tunnel_xmit,
 	.ndo_do_ioctl		= ip6gre_tunnel_ioctl,
-	.ndo_change_mtu		= ip6gre_tunnel_change_mtu,
+	.ndo_change_mtu		= ip6_tnl_change_mtu,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
 	.ndo_get_iflink		= ip6_tnl_get_iflink,
 };
@@ -1148,17 +991,11 @@ static void ip6gre_dev_free(struct net_device *dev)
 
 static void ip6gre_tunnel_setup(struct net_device *dev)
 {
-	struct ip6_tnl *t;
-
 	dev->netdev_ops = &ip6gre_netdev_ops;
 	dev->destructor = ip6gre_dev_free;
 
 	dev->type = ARPHRD_IP6GRE;
-	dev->hard_header_len = LL_MAX_HEADER + sizeof(struct ipv6hdr) + 4;
-	dev->mtu = ETH_DATA_LEN - sizeof(struct ipv6hdr) - 4;
-	t = netdev_priv(dev);
-	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-		dev->mtu -= 8;
+
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	netif_keep_dst(dev);
@@ -1168,6 +1005,7 @@ static int ip6gre_tunnel_init_common(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
 	int ret;
+	int t_hlen;
 
 	tunnel = netdev_priv(dev);
 
@@ -1186,6 +1024,16 @@ static int ip6gre_tunnel_init_common(struct net_device *dev)
 		return ret;
 	}
 
+	tunnel->tun_hlen = gre_calc_hlen(tunnel->parms.o_flags);
+
+	t_hlen = tunnel->hlen + sizeof(struct ipv6hdr);
+
+	dev->needed_headroom	= LL_MAX_HEADER + t_hlen + 4;
+	dev->mtu		= ETH_DATA_LEN - t_hlen - 4;
+
+	if (!(tunnel->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
+		dev->mtu -= 8;
+
 	return 0;
 }
 
@@ -1420,7 +1268,7 @@ static const struct net_device_ops ip6gre_tap_netdev_ops = {
 	.ndo_start_xmit = ip6gre_tunnel_xmit,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
-	.ndo_change_mtu = ip6gre_tunnel_change_mtu,
+	.ndo_change_mtu = ip6_tnl_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
 	.ndo_get_iflink = ip6_tnl_get_iflink,
 };
-- 
2.8.0.rc2
