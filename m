From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH next-next 2/7] gre: Move utility functions to common headers
Date: Fri, 29 Apr 2016 17:12:16 -0700
Message-ID: <1461975141-954269-3-git-send-email-tom@herbertland.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34195 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752404AbcD3AOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:14:42 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3U0AX3j010500
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22mf39rsvj-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:41 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 87f6b2ac0e6811e6b5d224be0595f910-d43f7c50 for <netdev@vger.kernel.org>;	Fri,
 29 Apr 2016 17:14:40 -0700
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several of the GRE functions defined in net/ipv4/ip_gre.c are usable
for IPv6 GRE implementation (that is they are protocol agnostic).

These include:
  - GRE flag handling functions are move to gre.h
  - GRE build_header is moved to gre.h and renamed gre_build_header
  - parse_gre_header is moved to gre_demux.c and renamed gre_parse_header
  - iptunnel_pull_header is taken out of gre_parse_header. This is now
    done by caller. The header length is returned from gre_parse_header
    in an int* argument.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/gre.h    |  60 +++++++++++++++++++++
 net/ipv4/gre_demux.c |  64 ++++++++++++++++++++++
 net/ipv4/ip_gre.c    | 149 +++++++--------------------------------------------
 3 files changed, 144 insertions(+), 129 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 97eafdc..3959158 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -25,4 +25,64 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
 struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 				       u8 name_assign_type);
+int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
+		     bool *csum_err, int *hdr_len);
+
+static inline int gre_calc_hlen(__be16 o_flags)
+{
+	int addend = 4;
+
+	if (o_flags & TUNNEL_CSUM)
+		addend += 4;
+	if (o_flags & TUNNEL_KEY)
+		addend += 4;
+	if (o_flags & TUNNEL_SEQ)
+		addend += 4;
+	return addend;
+}
+
+static inline __be16 gre_flags_to_tnl_flags(__be16 flags)
+{
+	__be16 tflags = 0;
+
+	if (flags & GRE_CSUM)
+		tflags |= TUNNEL_CSUM;
+	if (flags & GRE_ROUTING)
+		tflags |= TUNNEL_ROUTING;
+	if (flags & GRE_KEY)
+		tflags |= TUNNEL_KEY;
+	if (flags & GRE_SEQ)
+		tflags |= TUNNEL_SEQ;
+	if (flags & GRE_STRICT)
+		tflags |= TUNNEL_STRICT;
+	if (flags & GRE_REC)
+		tflags |= TUNNEL_REC;
+	if (flags & GRE_VERSION)
+		tflags |= TUNNEL_VERSION;
+
+	return tflags;
+}
+
+static inline __be16 gre_tnl_flags_to_gre_flags(__be16 tflags)
+{
+	__be16 flags = 0;
+
+	if (tflags & TUNNEL_CSUM)
+		flags |= GRE_CSUM;
+	if (tflags & TUNNEL_ROUTING)
+		flags |= GRE_ROUTING;
+	if (tflags & TUNNEL_KEY)
+		flags |= GRE_KEY;
+	if (tflags & TUNNEL_SEQ)
+		flags |= GRE_SEQ;
+	if (tflags & TUNNEL_STRICT)
+		flags |= GRE_STRICT;
+	if (tflags & TUNNEL_REC)
+		flags |= GRE_REC;
+	if (tflags & TUNNEL_VERSION)
+		flags |= GRE_VERSION;
+
+	return flags;
+}
+
 #endif
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index d9c552a..37167480 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -60,6 +60,70 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 }
 EXPORT_SYMBOL_GPL(gre_del_protocol);
 
+int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
+		     bool *csum_err, int *ret_hdr_len)
+{
+	const struct gre_base_hdr *greh;
+	__be32 *options;
+	int hdr_len;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
+		return -EINVAL;
+
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
+	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
+		return -EINVAL;
+
+	tpi->flags = gre_flags_to_tnl_flags(greh->flags);
+	hdr_len = gre_calc_hlen(tpi->flags);
+
+	if (!pskb_may_pull(skb, hdr_len))
+		return -EINVAL;
+
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
+	tpi->proto = greh->protocol;
+
+	options = (__be32 *)(greh + 1);
+	if (greh->flags & GRE_CSUM) {
+		if (skb_checksum_simple_validate(skb)) {
+			*csum_err = true;
+			return -EINVAL;
+		}
+
+		skb_checksum_try_convert(skb, IPPROTO_GRE, 0,
+					 null_compute_pseudo);
+		options++;
+	}
+
+	if (greh->flags & GRE_KEY) {
+		tpi->key = *options;
+		options++;
+	} else {
+		tpi->key = 0;
+	}
+	if (unlikely(greh->flags & GRE_SEQ)) {
+		tpi->seq = *options;
+		options++;
+	} else {
+		tpi->seq = 0;
+	}
+	/* WCCP version 1 and 2 protocol decoding.
+	 * - Change protocol to IP
+	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
+	 */
+	if (greh->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
+		tpi->proto = htons(ETH_P_IP);
+		if ((*(u8 *)options & 0xF0) != 0x40) {
+			hdr_len += 4;
+			if (!pskb_may_pull(skb, hdr_len))
+				return -EINVAL;
+		}
+	}
+	*ret_hdr_len = hdr_len;
+	return 0;
+}
+EXPORT_SYMBOL(gre_parse_header);
+
 static int gre_rcv(struct sk_buff *skb)
 {
 	const struct gre_protocol *proto;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index eedd829..f6db3d6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -122,125 +122,6 @@ static int ipgre_tunnel_init(struct net_device *dev);
 static int ipgre_net_id __read_mostly;
 static int gre_tap_net_id __read_mostly;
 
-static int ip_gre_calc_hlen(__be16 o_flags)
-{
-	int addend = 4;
-
-	if (o_flags & TUNNEL_CSUM)
-		addend += 4;
-	if (o_flags & TUNNEL_KEY)
-		addend += 4;
-	if (o_flags & TUNNEL_SEQ)
-		addend += 4;
-	return addend;
-}
-
-static __be16 gre_flags_to_tnl_flags(__be16 flags)
-{
-	__be16 tflags = 0;
-
-	if (flags & GRE_CSUM)
-		tflags |= TUNNEL_CSUM;
-	if (flags & GRE_ROUTING)
-		tflags |= TUNNEL_ROUTING;
-	if (flags & GRE_KEY)
-		tflags |= TUNNEL_KEY;
-	if (flags & GRE_SEQ)
-		tflags |= TUNNEL_SEQ;
-	if (flags & GRE_STRICT)
-		tflags |= TUNNEL_STRICT;
-	if (flags & GRE_REC)
-		tflags |= TUNNEL_REC;
-	if (flags & GRE_VERSION)
-		tflags |= TUNNEL_VERSION;
-
-	return tflags;
-}
-
-static __be16 tnl_flags_to_gre_flags(__be16 tflags)
-{
-	__be16 flags = 0;
-
-	if (tflags & TUNNEL_CSUM)
-		flags |= GRE_CSUM;
-	if (tflags & TUNNEL_ROUTING)
-		flags |= GRE_ROUTING;
-	if (tflags & TUNNEL_KEY)
-		flags |= GRE_KEY;
-	if (tflags & TUNNEL_SEQ)
-		flags |= GRE_SEQ;
-	if (tflags & TUNNEL_STRICT)
-		flags |= GRE_STRICT;
-	if (tflags & TUNNEL_REC)
-		flags |= GRE_REC;
-	if (tflags & TUNNEL_VERSION)
-		flags |= GRE_VERSION;
-
-	return flags;
-}
-
-static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
-			    bool *csum_err)
-{
-	const struct gre_base_hdr *greh;
-	__be32 *options;
-	int hdr_len;
-
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
-		return -EINVAL;
-
-	greh = (struct gre_base_hdr *)skb_transport_header(skb);
-	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
-		return -EINVAL;
-
-	tpi->flags = gre_flags_to_tnl_flags(greh->flags);
-	hdr_len = ip_gre_calc_hlen(tpi->flags);
-
-	if (!pskb_may_pull(skb, hdr_len))
-		return -EINVAL;
-
-	greh = (struct gre_base_hdr *)skb_transport_header(skb);
-	tpi->proto = greh->protocol;
-
-	options = (__be32 *)(greh + 1);
-	if (greh->flags & GRE_CSUM) {
-		if (skb_checksum_simple_validate(skb)) {
-			*csum_err = true;
-			return -EINVAL;
-		}
-
-		skb_checksum_try_convert(skb, IPPROTO_GRE, 0,
-					 null_compute_pseudo);
-		options++;
-	}
-
-	if (greh->flags & GRE_KEY) {
-		tpi->key = *options;
-		options++;
-	} else {
-		tpi->key = 0;
-	}
-	if (unlikely(greh->flags & GRE_SEQ)) {
-		tpi->seq = *options;
-		options++;
-	} else {
-		tpi->seq = 0;
-	}
-	/* WCCP version 1 and 2 protocol decoding.
-	 * - Change protocol to IP
-	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
-	 */
-	if (greh->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
-		tpi->proto = htons(ETH_P_IP);
-		if ((*(u8 *)options & 0xF0) != 0x40) {
-			hdr_len += 4;
-			if (!pskb_may_pull(skb, hdr_len))
-				return -EINVAL;
-		}
-	}
-	return iptunnel_pull_header(skb, hdr_len, tpi->proto, false);
-}
-
 static void ipgre_err(struct sk_buff *skb, u32 info,
 		      const struct tnl_ptk_info *tpi)
 {
@@ -340,12 +221,16 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	const int code = icmp_hdr(skb)->code;
 	struct tnl_ptk_info tpi;
 	bool csum_err = false;
+	int hdr_len;
 
-	if (parse_gre_header(skb, &tpi, &csum_err)) {
+	if (gre_parse_header(skb, &tpi, &csum_err, &hdr_len)) {
 		if (!csum_err)		/* ignore csum errors. */
 			return;
 	}
 
+	if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
+		return;
+
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
 		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
 				 skb->dev->ifindex, 0, IPPROTO_GRE, 0);
@@ -419,6 +304,7 @@ static int gre_rcv(struct sk_buff *skb)
 {
 	struct tnl_ptk_info tpi;
 	bool csum_err = false;
+	int hdr_len;
 
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 	if (ipv4_is_multicast(ip_hdr(skb)->daddr)) {
@@ -428,7 +314,10 @@ static int gre_rcv(struct sk_buff *skb)
 	}
 #endif
 
-	if (parse_gre_header(skb, &tpi, &csum_err) < 0)
+	if (gre_parse_header(skb, &tpi, &csum_err, &hdr_len) < 0)
+		goto drop;
+
+	if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
 		goto drop;
 
 	if (ipgre_rcv(skb, &tpi) == PACKET_RCVD)
@@ -460,7 +349,7 @@ static void build_header(struct sk_buff *skb, int hdr_len, __be16 flags,
 
 	skb_reset_transport_header(skb);
 	greh = (struct gre_base_hdr *)skb->data;
-	greh->flags = tnl_flags_to_gre_flags(flags);
+	greh->flags = gre_tnl_flags_to_gre_flags(flags);
 	greh->protocol = proto;
 
 	if (flags & (TUNNEL_KEY | TUNNEL_CSUM | TUNNEL_SEQ)) {
@@ -552,7 +441,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 					  fl.saddr);
 	}
 
-	tunnel_hlen = ip_gre_calc_hlen(key->tun_flags);
+	tunnel_hlen = gre_calc_hlen(key->tun_flags);
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ tunnel_hlen + sizeof(struct iphdr);
@@ -694,8 +583,8 @@ static int ipgre_tunnel_ioctl(struct net_device *dev,
 	if (err)
 		return err;
 
-	p.i_flags = tnl_flags_to_gre_flags(p.i_flags);
-	p.o_flags = tnl_flags_to_gre_flags(p.o_flags);
+	p.i_flags = gre_tnl_flags_to_gre_flags(p.i_flags);
+	p.o_flags = gre_tnl_flags_to_gre_flags(p.o_flags);
 
 	if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
 		return -EFAULT;
@@ -739,7 +628,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 
 	iph = (struct iphdr *)skb_push(skb, t->hlen + sizeof(*iph));
 	greh = (struct gre_base_hdr *)(iph+1);
-	greh->flags = tnl_flags_to_gre_flags(t->parms.o_flags);
+	greh->flags = gre_tnl_flags_to_gre_flags(t->parms.o_flags);
 	greh->protocol = htons(type);
 
 	memcpy(iph, &t->parms.iph, sizeof(struct iphdr));
@@ -840,7 +729,7 @@ static void __gre_tunnel_init(struct net_device *dev)
 	int t_hlen;
 
 	tunnel = netdev_priv(dev);
-	tunnel->tun_hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
+	tunnel->tun_hlen = gre_calc_hlen(tunnel->parms.o_flags);
 	tunnel->parms.iph.protocol = IPPROTO_GRE;
 
 	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
@@ -1155,8 +1044,10 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct ip_tunnel_parm *p = &t->parms;
 
 	if (nla_put_u32(skb, IFLA_GRE_LINK, p->link) ||
-	    nla_put_be16(skb, IFLA_GRE_IFLAGS, tnl_flags_to_gre_flags(p->i_flags)) ||
-	    nla_put_be16(skb, IFLA_GRE_OFLAGS, tnl_flags_to_gre_flags(p->o_flags)) ||
+	    nla_put_be16(skb, IFLA_GRE_IFLAGS,
+			 gre_tnl_flags_to_gre_flags(p->i_flags)) ||
+	    nla_put_be16(skb, IFLA_GRE_OFLAGS,
+			 gre_tnl_flags_to_gre_flags(p->o_flags)) ||
 	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
 	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
 	    nla_put_in_addr(skb, IFLA_GRE_LOCAL, p->iph.saddr) ||
-- 
2.8.0.rc2
