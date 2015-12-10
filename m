From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 3/3] geneve: Remote Checksum Offload support
Date: Thu, 10 Dec 2015 12:37:46 -0800
Message-ID: <1449779866-3704097-4-git-send-email-tom@herbertland.com>
References: <1449779866-3704097-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47230 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752482AbbLJUh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 15:37:56 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBAKahGj024588
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 12:37:55 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1yqg1ar5cf-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 12:37:55 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 e34e06d29f7d11e5b94224be0593f280-1d16b6d0 for <netdev@vger.kernel.org>;	Thu,
 10 Dec 2015 12:37:54 -0800
In-Reply-To: <1449779866-3704097-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for remote checksum offload in both the normal and GRO
paths. netlinks command are used to enable sending of the Remote
Checksum Data, and allow processing of it on receive.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/geneve.c         | 162 ++++++++++++++++++++++++++++++++++++++++---
 include/net/geneve.h         |  22 ++++--
 include/uapi/linux/if_link.h |   3 +
 3 files changed, 174 insertions(+), 13 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 0750d7a..9d4f487 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -78,6 +78,9 @@ struct geneve_dev {
 #define GENEVE_F_UDP_CSUM		BIT(0)
 #define GENEVE_F_UDP_ZERO_CSUM6_TX	BIT(1)
 #define GENEVE_F_UDP_ZERO_CSUM6_RX	BIT(2)
+#define GENEVE_F_REMCSUM_TX		BIT(3)
+#define GENEVE_F_REMCSUM_RX		BIT(4)
+#define GENEVE_F_REMCSUM_NOPARTIAL	BIT(5)
 
 struct geneve_sock {
 	bool			collect_md;
@@ -308,6 +311,33 @@ static void geneve_uninit(struct net_device *dev)
 	free_percpu(dev->tstats);
 }
 
+static struct genevehdr *geneve_remcsum(struct sk_buff *skb,
+					struct genevehdr *gh,
+					size_t hdrlen, bool nopartial)
+{
+	size_t start, offset, plen;
+
+	if (skb->remcsum_offload)
+		return gh;
+
+	start = gh->rco_start << GENEVE_RCO_SHIFT;
+	offset = start + (gh->udp_rco ?
+			  offsetof(struct udphdr, check) :
+			  offsetof(struct tcphdr, check));
+
+	plen = hdrlen + offset + sizeof(u16);
+
+	if (!pskb_may_pull(skb, plen))
+		return NULL;
+
+	gh = (struct genevehdr *)(udp_hdr(skb) + 1);
+
+	skb_remcsum_process(skb, (void *)gh + hdrlen, start, offset,
+			    nopartial);
+
+	return gh;
+}
+
 /* Callback from net/ipv4/udp.c to receive packets */
 static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
@@ -336,6 +366,15 @@ static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!gs)
 		goto drop;
 
+	if (geneveh->rco && (gs->flags & GENEVE_F_REMCSUM_RX)) {
+		geneveh = geneve_remcsum(skb, geneveh,
+					 sizeof(*geneveh) + opts_len,
+					 !!(gs->flags &
+					    GENEVE_F_REMCSUM_NOPARTIAL));
+		if (unlikely(!geneveh))
+			goto drop;
+	}
+
 	geneve_rx(gs, skb);
 	return 0;
 
@@ -397,6 +436,32 @@ static int geneve_hlen(struct genevehdr *gh)
 	return sizeof(*gh) + gh->opt_len * 4;
 }
 
+static struct genevehdr *geneve_gro_remcsum(struct sk_buff *skb,
+					    unsigned int off,
+					    struct genevehdr *gh, size_t hdrlen,
+					    struct gro_remcsum *grc,
+					    bool nopartial)
+{
+	size_t start, offset;
+
+	if (skb->remcsum_offload)
+		return gh;
+
+	if (!NAPI_GRO_CB(skb)->csum_valid)
+		return NULL;
+
+	start = gh->rco_start << GENEVE_RCO_SHIFT;
+	offset = start + (gh->udp_rco ?
+			  offsetof(struct udphdr, check) :
+			  offsetof(struct tcphdr, check));
+
+	gh = skb_gro_remcsum_process(skb, (void *)gh, off, hdrlen,
+				     start, offset, grc, nopartial);
+
+	skb->remcsum_offload = 1;
+
+	return gh;
+}
 static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 					   struct sk_buff *skb,
 					   struct udp_offload *uoff)
@@ -407,6 +472,11 @@ static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 	const struct packet_offload *ptype;
 	__be16 type;
 	int flush = 1;
+	struct gro_remcsum grc;
+	struct geneve_sock *gs = container_of(uoff, struct geneve_sock,
+					      udp_offloads);
+
+	skb_gro_remcsum_init(&grc);
 
 	off_gnv = skb_gro_offset(skb);
 	hlen = off_gnv + sizeof(*gh);
@@ -421,6 +491,16 @@ static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 		goto out;
 	gh_len = geneve_hlen(gh);
 
+	skb_gro_postpull_rcsum(skb, gh, gh_len);
+
+	if (gh->rco && (gs->flags & GENEVE_F_REMCSUM_RX)) {
+		gh = geneve_gro_remcsum(skb, off_gnv, gh, gh_len, &grc,
+					!!(gs->flags &
+					  GENEVE_F_REMCSUM_NOPARTIAL));
+		if (unlikely(!gh))
+			goto out;
+	}
+
 	hlen = off_gnv + gh_len;
 	if (skb_gro_header_hard(skb, hlen)) {
 		gh = skb_gro_header_slow(skb, hlen, off_gnv);
@@ -452,7 +532,6 @@ static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 	}
 
 	skb_gro_pull(skb, gh_len);
-	skb_gro_postpull_rcsum(skb, gh, gh_len);
 	pp = ptype->callbacks.gro_receive(head, skb);
 
 out_unlock:
@@ -636,7 +715,8 @@ static int geneve_stop(struct net_device *dev)
 
 static void geneve_build_header(struct genevehdr *geneveh,
 				__be16 tun_flags, u8 vni[3],
-				u8 options_len, u8 *options)
+				u8 options_len, u8 *options,
+				int type, struct sk_buff *skb)
 {
 	geneveh->ver = GENEVE_VER;
 	geneveh->opt_len = options_len / 4;
@@ -645,7 +725,25 @@ static void geneve_build_header(struct genevehdr *geneveh,
 	geneveh->rsvd1 = 0;
 	memcpy(geneveh->vni, vni, 3);
 	geneveh->proto_type = htons(ETH_P_TEB);
-	geneveh->rsvd2 = 0;
+
+	if (type & SKB_GSO_TUNNEL_REMCSUM) {
+		size_t hdrlen = sizeof(*geneveh) + options_len;
+
+		geneveh->rco = 1;
+		geneveh->rco_start = (skb_checksum_start_offset(skb) -
+				      hdrlen) >> GENEVE_RCO_SHIFT;
+
+		if (skb->csum_offset == offsetof(struct udphdr, check))
+			geneveh->udp_rco = 1;
+
+		if (!skb_is_gso(skb)) {
+			skb->ip_summed = CHECKSUM_NONE;
+			skb->encapsulation = 0;
+		}
+	} else {
+		geneveh->udp_rco = 0;
+		geneveh->rco_start = 0;
+	}
 
 	memcpy(geneveh->options, options, options_len);
 }
@@ -658,6 +756,20 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 	int min_headroom;
 	int err;
 	bool udp_sum = !!(flags & GENEVE_F_UDP_CSUM);
+	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+
+	if ((flags & GENEVE_F_REMCSUM_TX) &&
+	    skb->ip_summed == CHECKSUM_PARTIAL) {
+		int csum_start = skb_checksum_start_offset(skb);
+
+		if (csum_start <= GENEVE_MAX_REMCSUM_START &&
+		    !(csum_start & GENEVE_RCO_SHIFT_MASK) &&
+		    (skb->csum_offset == offsetof(struct udphdr, check) ||
+		     skb->csum_offset == offsetof(struct tcphdr, check))) {
+			udp_sum = false;
+			type |= SKB_GSO_TUNNEL_REMCSUM;
+		}
+	}
 
 	skb_scrub_packet(skb, xnet);
 
@@ -669,14 +781,14 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 		goto free_rt;
 	}
 
-	skb = udp_tunnel_handle_offloads(skb, udp_sum);
+	skb = iptunnel_handle_offloads(skb, udp_sum, type);
 	if (IS_ERR(skb)) {
 		err = PTR_ERR(skb);
 		goto free_rt;
 	}
 
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
-	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
+	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt, type, skb);
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 	return 0;
@@ -695,6 +807,20 @@ static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 	int min_headroom;
 	int err;
 	bool udp_sum = !(flags & GENEVE_F_UDP_ZERO_CSUM6_TX);
+	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+
+	 if ((flags & GENEVE_F_REMCSUM_TX) &&
+	     skb->ip_summed == CHECKSUM_PARTIAL) {
+		int csum_start = skb_checksum_start_offset(skb);
+
+		if (csum_start <= GENEVE_MAX_REMCSUM_START &&
+		    !(csum_start & GENEVE_RCO_SHIFT_MASK) &&
+		    (skb->csum_offset == offsetof(struct udphdr, check) ||
+		     skb->csum_offset == offsetof(struct tcphdr, check))) {
+			udp_sum = false;
+			type |= SKB_GSO_TUNNEL_REMCSUM;
+		}
+	}
 
 	skb_scrub_packet(skb, xnet);
 
@@ -706,14 +832,14 @@ static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 		goto free_dst;
 	}
 
-	skb = udp_tunnel_handle_offloads(skb, udp_sum);
+	skb = iptunnel_handle_offloads(skb, udp_sum, type);
 	if (IS_ERR(skb)) {
 		err = PTR_ERR(skb);
 		goto free_dst;
 	}
 
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
-	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
+	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt, type, skb);
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 	return 0;
@@ -1121,6 +1247,9 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_UDP_CSUM]		= { .type = NLA_U8 },
 	[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
 	[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
+	[IFLA_GENEVE_REMCSUM_TX]	= { .type = NLA_U8 },
+	[IFLA_GENEVE_REMCSUM_RX]	= { .type = NLA_U8 },
+	[IFLA_GENEVE_REMCSUM_NOPARTIAL]	= { .type = NLA_FLAG },
 };
 
 static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1289,6 +1418,17 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	    nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
 		flags |= GENEVE_F_UDP_ZERO_CSUM6_RX;
 
+	if (data[IFLA_GENEVE_REMCSUM_TX] &&
+	    nla_get_u8(data[IFLA_GENEVE_REMCSUM_TX]))
+		flags |= GENEVE_F_REMCSUM_TX;
+
+	if (data[IFLA_GENEVE_REMCSUM_RX] &&
+	    nla_get_u8(data[IFLA_GENEVE_REMCSUM_RX]))
+		flags |= GENEVE_F_REMCSUM_RX;
+
+	if (data[IFLA_GENEVE_REMCSUM_NOPARTIAL])
+		flags |= GENEVE_F_REMCSUM_NOPARTIAL;
+
 	return geneve_configure(net, dev, &remote, vni, ttl, tos, dst_port,
 				metadata, flags);
 }
@@ -1312,6 +1452,8 @@ static size_t geneve_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_UDP_CSUM */
 		nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_UDP_ZERO_CSUM6_TX */
 		nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_UDP_ZERO_CSUM6_RX */
+		nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_REMCSUM_TX */
+		nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_REMCSUM_RX */
 		0;
 }
 
@@ -1353,7 +1495,11 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
 		       !!(geneve->flags & GENEVE_F_UDP_ZERO_CSUM6_TX)) ||
 	    nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
-		       !!(geneve->flags & GENEVE_F_UDP_ZERO_CSUM6_RX)))
+		       !!(geneve->flags & GENEVE_F_UDP_ZERO_CSUM6_RX)) ||
+	    nla_put_u8(skb, IFLA_GENEVE_REMCSUM_TX,
+		       !!(geneve->flags & GENEVE_F_REMCSUM_TX)) ||
+	    nla_put_u8(skb, IFLA_GENEVE_REMCSUM_RX,
+		       !!(geneve->flags & GENEVE_F_REMCSUM_RX)))
 		goto nla_put_failure;
 
 	return 0;
diff --git a/include/net/geneve.h b/include/net/geneve.h
index 3106ed6..b59ad0a 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -8,9 +8,9 @@
 
 /* Geneve Header:
  *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- *  |Ver|  Opt Len  |O|C|    Rsvd.  |          Protocol Type        |
+ *  |Ver|  Opt Len  |O|C|X|  Rsvd.  |          Protocol Type        |
  *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- *  |        Virtual Network Identifier (VNI)       |    Reserved   |
+ *  |        Virtual Network Identifier (VNI)       |U| Csum start  |
  *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  *  |                    Variable Length Options                    |
  *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@@ -46,7 +46,8 @@ struct genevehdr {
 #ifdef __LITTLE_ENDIAN_BITFIELD
 	u8 opt_len:6;
 	u8 ver:2;
-	u8 rsvd1:6;
+	u8 rsvd1:5;
+	u8 rco:1;
 	u8 critical:1;
 	u8 oam:1;
 #else
@@ -54,14 +55,25 @@ struct genevehdr {
 	u8 opt_len:6;
 	u8 oam:1;
 	u8 critical:1;
-	u8 rsvd1:6;
+	u8 rco:1;
+	u8 rsvd1:5;
 #endif
 	__be16 proto_type;
 	u8 vni[3];
-	u8 rsvd2;
+#ifdef __LITTLE_ENDIAN_BITFIELD
+	u8 rco_start : 7;
+	u8 udp_rco : 1;
+#else
+	u8 udp_rco : 1;
+	u8 rco_start : 7;
+#endif
 	struct geneve_opt options[];
 };
 
+#define GENEVE_RCO_SHIFT 1	/* Left shift of start */
+#define GENEVE_RCO_SHIFT_MASK ((1 << GENEVE_RCO_SHIFT) - 1)
+#define GENEVE_MAX_REMCSUM_START (0x7f << GENEVE_RCO_SHIFT)
+
 #ifdef CONFIG_INET
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 					u8 name_assign_type, u16 dst_port);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 2be1dd5..998eff0 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -465,6 +465,9 @@ enum {
 	IFLA_GENEVE_UDP_CSUM,
 	IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
 	IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
+	IFLA_GENEVE_REMCSUM_RX,
+	IFLA_GENEVE_REMCSUM_TX,
+	IFLA_GENEVE_REMCSUM_NOPARTIAL,
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
-- 
2.4.6
