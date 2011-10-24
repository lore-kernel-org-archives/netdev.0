From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] cls_flow: Add tunnel support to the flow classifier
Date: Mon, 24 Oct 2011 05:59:41 +0200
Message-ID: <1319428781.2517.26.camel@edumazet-laptop>
References: <1318806373.7169.35.camel@ganymede>
	 <1318833623.2500.45.camel@edumazet-laptop>
	 <1319419287.20602.21.camel@ganymede>
	 <1319426081.2517.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Dan Siemon <dan@coverfire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63380 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941Ab1JXD7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 23:59:46 -0400
Received: by wyg36 with SMTP id 36so5720231wyg.19
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2011 20:59:44 -0700 (PDT)
In-Reply-To: <1319426081.2517.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 24 octobre 2011 =C3=A0 05:14 +0200, Eric Dumazet a =C3=A9crit =
:

> If you prefer, I can do the preliminary work=20
>=20

Since it is a bit tricky, I finished it.

It'll be easier for you to use existing functions without copy/paste,
since I added an "nhoff" argument that you can play with (skipping
tunnel header)

Please test it !

Thanks

[PATCH net-next] net_sched: cls_flow: use skb_header_pointer()

Dan Siemon would like to add tunnelling support to cls_flow

This preliminary patch introduces use of skb_header_pointer() to help
this task, while avoiding skb head reallocation because of deep packet
inspection.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/cls_flow.c |  188 ++++++++++++++++++++---------------------
 1 file changed, 96 insertions(+), 92 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 6994214..9e087d8 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -65,132 +65,134 @@ static inline u32 addr_fold(void *addr)
 	return (a & 0xFFFFFFFF) ^ (BITS_PER_LONG > 32 ? a >> 32 : 0);
 }
=20
-static u32 flow_get_src(struct sk_buff *skb)
+static u32 flow_get_src(const struct sk_buff *skb, int nhoff)
 {
+	__be32 *data =3D NULL, hdata;
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		if (pskb_network_may_pull(skb, sizeof(struct iphdr)))
-			return ntohl(ip_hdr(skb)->saddr);
+		data =3D skb_header_pointer(skb,
+					  nhoff + offsetof(struct iphdr,
+							   saddr),
+					  4, &hdata);
 		break;
 	case htons(ETH_P_IPV6):
-		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr)))
-			return ntohl(ipv6_hdr(skb)->saddr.s6_addr32[3]);
+		data =3D skb_header_pointer(skb,
+					 nhoff + offsetof(struct ipv6hdr,
+							  saddr.s6_addr32[3]),
+					 4, &hdata);
 		break;
 	}
=20
+	if (data)
+		return ntohl(*data);
 	return addr_fold(skb->sk);
 }
=20
-static u32 flow_get_dst(struct sk_buff *skb)
+static u32 flow_get_dst(const struct sk_buff *skb, int nhoff)
 {
+	__be32 *data =3D NULL, hdata;
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		if (pskb_network_may_pull(skb, sizeof(struct iphdr)))
-			return ntohl(ip_hdr(skb)->daddr);
+		data =3D skb_header_pointer(skb,
+					  nhoff + offsetof(struct iphdr,
+							   daddr),
+					  4, &hdata);
 		break;
 	case htons(ETH_P_IPV6):
-		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr)))
-			return ntohl(ipv6_hdr(skb)->daddr.s6_addr32[3]);
+		data =3D skb_header_pointer(skb,
+					 nhoff + offsetof(struct ipv6hdr,
+							  daddr.s6_addr32[3]),
+					 4, &hdata);
 		break;
 	}
=20
+	if (data)
+		return ntohl(*data);
 	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 }
=20
-static u32 flow_get_proto(struct sk_buff *skb)
+static u32 flow_get_proto(const struct sk_buff *skb, int nhoff)
 {
+	__u8 *data =3D NULL, hdata;
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return pskb_network_may_pull(skb, sizeof(struct iphdr)) ?
-		       ip_hdr(skb)->protocol : 0;
+		data =3D skb_header_pointer(skb,
+					  nhoff + offsetof(struct iphdr,
+							   protocol),
+					  1, &hdata);
+		break;
 	case htons(ETH_P_IPV6):
-		return pskb_network_may_pull(skb, sizeof(struct ipv6hdr)) ?
-		       ipv6_hdr(skb)->nexthdr : 0;
-	default:
-		return 0;
+		data =3D skb_header_pointer(skb,
+					 nhoff + offsetof(struct ipv6hdr,
+							  nexthdr),
+					 1, &hdata);
+		break;
 	}
+	if (data)
+		return *data;
+	return 0;
 }
=20
-static u32 flow_get_proto_src(struct sk_buff *skb)
+/* helper function to get either src or dst port */
+static __be16 *flow_get_proto_common(const struct sk_buff *skb, int nh=
off,
+				     __be16 *_port, int dst)
 {
+	__be16 *port =3D NULL;
+	int poff;
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP): {
-		struct iphdr *iph;
-		int poff;
+		struct iphdr *iph, _iph;
=20
-		if (!pskb_network_may_pull(skb, sizeof(*iph)))
+		iph =3D skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
+		if (!iph)
 			break;
-		iph =3D ip_hdr(skb);
 		if (ip_is_fragment(iph))
 			break;
 		poff =3D proto_ports_offset(iph->protocol);
-		if (poff >=3D 0 &&
-		    pskb_network_may_pull(skb, iph->ihl * 4 + 2 + poff)) {
-			iph =3D ip_hdr(skb);
-			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 +
-						 poff));
-		}
+		if (poff >=3D 0)
+			port =3D skb_header_pointer(skb,
+					nhoff + iph->ihl * 4 + poff + dst,
+					sizeof(*_port), _port);
 		break;
 	}
 	case htons(ETH_P_IPV6): {
-		struct ipv6hdr *iph;
-		int poff;
+		struct ipv6hdr *iph, _iph;
=20
-		if (!pskb_network_may_pull(skb, sizeof(*iph)))
+		iph =3D skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
+		if (!iph)
 			break;
-		iph =3D ipv6_hdr(skb);
 		poff =3D proto_ports_offset(iph->nexthdr);
-		if (poff >=3D 0 &&
-		    pskb_network_may_pull(skb, sizeof(*iph) + poff + 2)) {
-			iph =3D ipv6_hdr(skb);
-			return ntohs(*(__be16 *)((void *)iph + sizeof(*iph) +
-						 poff));
-		}
+		if (poff >=3D 0)
+			port =3D skb_header_pointer(skb,
+					nhoff + sizeof(*iph) + poff + dst,
+					sizeof(*_port), _port);
 		break;
 	}
 	}
=20
-	return addr_fold(skb->sk);
+	return port;
 }
=20
-static u32 flow_get_proto_dst(struct sk_buff *skb)
+static u32 flow_get_proto_src(const struct sk_buff *skb, int nhoff)
 {
-	switch (skb->protocol) {
-	case htons(ETH_P_IP): {
-		struct iphdr *iph;
-		int poff;
+	__be16 _port, *port =3D flow_get_proto_common(skb, nhoff, &_port, 0);
=20
-		if (!pskb_network_may_pull(skb, sizeof(*iph)))
-			break;
-		iph =3D ip_hdr(skb);
-		if (ip_is_fragment(iph))
-			break;
-		poff =3D proto_ports_offset(iph->protocol);
-		if (poff >=3D 0 &&
-		    pskb_network_may_pull(skb, iph->ihl * 4 + 4 + poff)) {
-			iph =3D ip_hdr(skb);
-			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 +
-						 2 + poff));
-		}
-		break;
-	}
-	case htons(ETH_P_IPV6): {
-		struct ipv6hdr *iph;
-		int poff;
+	if (port)
+		return ntohs(*port);
=20
-		if (!pskb_network_may_pull(skb, sizeof(*iph)))
-			break;
-		iph =3D ipv6_hdr(skb);
-		poff =3D proto_ports_offset(iph->nexthdr);
-		if (poff >=3D 0 &&
-		    pskb_network_may_pull(skb, sizeof(*iph) + poff + 4)) {
-			iph =3D ipv6_hdr(skb);
-			return ntohs(*(__be16 *)((void *)iph + sizeof(*iph) +
-						 poff + 2));
-		}
-		break;
-	}
-	}
+	return addr_fold(skb->sk);
+}
+
+static u32 flow_get_proto_dst(const struct sk_buff *skb, int nhoff)
+{
+	__be16 _port, *port =3D flow_get_proto_common(skb, nhoff, &_port, 2);
+
+	if (port)
+		return ntohs(*port);
=20
 	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 }
@@ -223,7 +225,7 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 #define CTTUPLE(skb, member)						\
 ({									\
 	enum ip_conntrack_info ctinfo;					\
-	struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);			\
+	const struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);		\
 	if (ct =3D=3D NULL)							\
 		goto fallback;						\
 	ct->tuplehash[CTINFO2DIR(ctinfo)].tuple.member;			\
@@ -236,7 +238,7 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 })
 #endif
=20
-static u32 flow_get_nfct_src(struct sk_buff *skb)
+static u32 flow_get_nfct_src(const struct sk_buff *skb, int nhoff)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -245,10 +247,10 @@ static u32 flow_get_nfct_src(struct sk_buff *skb)
 		return ntohl(CTTUPLE(skb, src.u3.ip6[3]));
 	}
 fallback:
-	return flow_get_src(skb);
+	return flow_get_src(skb, nhoff);
 }
=20
-static u32 flow_get_nfct_dst(struct sk_buff *skb)
+static u32 flow_get_nfct_dst(const struct sk_buff *skb, int nhoff)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -257,21 +259,21 @@ static u32 flow_get_nfct_dst(struct sk_buff *skb)
 		return ntohl(CTTUPLE(skb, dst.u3.ip6[3]));
 	}
 fallback:
-	return flow_get_dst(skb);
+	return flow_get_dst(skb, nhoff);
 }
=20
-static u32 flow_get_nfct_proto_src(struct sk_buff *skb)
+static u32 flow_get_nfct_proto_src(const struct sk_buff *skb, int nhof=
f)
 {
 	return ntohs(CTTUPLE(skb, src.u.all));
 fallback:
-	return flow_get_proto_src(skb);
+	return flow_get_proto_src(skb, nhoff);
 }
=20
-static u32 flow_get_nfct_proto_dst(struct sk_buff *skb)
+static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb, int nhof=
f)
 {
 	return ntohs(CTTUPLE(skb, dst.u.all));
 fallback:
-	return flow_get_proto_dst(skb);
+	return flow_get_proto_dst(skb, nhoff);
 }
=20
 static u32 flow_get_rtclassid(const struct sk_buff *skb)
@@ -313,17 +315,19 @@ static u32 flow_get_rxhash(struct sk_buff *skb)
=20
 static u32 flow_key_get(struct sk_buff *skb, int key)
 {
+	int nhoff =3D skb_network_offset(skb);
+
 	switch (key) {
 	case FLOW_KEY_SRC:
-		return flow_get_src(skb);
+		return flow_get_src(skb, nhoff);
 	case FLOW_KEY_DST:
-		return flow_get_dst(skb);
+		return flow_get_dst(skb, nhoff);
 	case FLOW_KEY_PROTO:
-		return flow_get_proto(skb);
+		return flow_get_proto(skb, nhoff);
 	case FLOW_KEY_PROTO_SRC:
-		return flow_get_proto_src(skb);
+		return flow_get_proto_src(skb, nhoff);
 	case FLOW_KEY_PROTO_DST:
-		return flow_get_proto_dst(skb);
+		return flow_get_proto_dst(skb, nhoff);
 	case FLOW_KEY_IIF:
 		return flow_get_iif(skb);
 	case FLOW_KEY_PRIORITY:
@@ -333,13 +337,13 @@ static u32 flow_key_get(struct sk_buff *skb, int =
key)
 	case FLOW_KEY_NFCT:
 		return flow_get_nfct(skb);
 	case FLOW_KEY_NFCT_SRC:
-		return flow_get_nfct_src(skb);
+		return flow_get_nfct_src(skb, nhoff);
 	case FLOW_KEY_NFCT_DST:
-		return flow_get_nfct_dst(skb);
+		return flow_get_nfct_dst(skb, nhoff);
 	case FLOW_KEY_NFCT_PROTO_SRC:
-		return flow_get_nfct_proto_src(skb);
+		return flow_get_nfct_proto_src(skb, nhoff);
 	case FLOW_KEY_NFCT_PROTO_DST:
-		return flow_get_nfct_proto_dst(skb);
+		return flow_get_nfct_proto_dst(skb, nhoff);
 	case FLOW_KEY_RTCLASSID:
 		return flow_get_rtclassid(skb);
 	case FLOW_KEY_SKUID:
