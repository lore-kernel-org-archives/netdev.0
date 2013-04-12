From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] act_csum: fix possible use after free
Date: Fri, 12 Apr 2013 11:07:47 -0700
Message-ID: <1365790067.4459.56.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	=?ISO-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54233 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab3DLSHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 14:07:50 -0400
Received: by mail-pa0-f51.google.com with SMTP id jh10so1583996pab.38
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 11:07:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

tcf_csum_skb_nextlayer() / pskb_may_pull() can change skb->head, so we
must be careful not keeping pointers to previous headers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Gr=C3=A9goire Baron <baronchon@n7mm.org>
---
Compile tested only, a probation period on net-next is welcomed

 net/sched/act_csum.c |   39 +++++++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 14 deletions(-)

diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 08fa1e8..3a4c0ca 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -166,15 +166,17 @@ static int tcf_csum_ipv4_igmp(struct sk_buff *skb=
,
 	return 1;
 }
=20
-static int tcf_csum_ipv6_icmp(struct sk_buff *skb, struct ipv6hdr *ip6=
h,
+static int tcf_csum_ipv6_icmp(struct sk_buff *skb,
 			      unsigned int ihl, unsigned int ipl)
 {
 	struct icmp6hdr *icmp6h;
+	const struct ipv6hdr *ip6h;
=20
 	icmp6h =3D tcf_csum_skb_nextlayer(skb, ihl, ipl, sizeof(*icmp6h));
 	if (icmp6h =3D=3D NULL)
 		return 0;
=20
+	ip6h =3D ipv6_hdr(skb);
 	icmp6h->icmp6_cksum =3D 0;
 	skb->csum =3D csum_partial(icmp6h, ipl - ihl, 0);
 	icmp6h->icmp6_cksum =3D csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
@@ -186,15 +188,17 @@ static int tcf_csum_ipv6_icmp(struct sk_buff *skb=
, struct ipv6hdr *ip6h,
 	return 1;
 }
=20
-static int tcf_csum_ipv4_tcp(struct sk_buff *skb, struct iphdr *iph,
+static int tcf_csum_ipv4_tcp(struct sk_buff *skb,
 			     unsigned int ihl, unsigned int ipl)
 {
 	struct tcphdr *tcph;
+	const struct iphdr *iph;
=20
 	tcph =3D tcf_csum_skb_nextlayer(skb, ihl, ipl, sizeof(*tcph));
 	if (tcph =3D=3D NULL)
 		return 0;
=20
+	iph =3D ip_hdr(skb);
 	tcph->check =3D 0;
 	skb->csum =3D csum_partial(tcph, ipl - ihl, 0);
 	tcph->check =3D tcp_v4_check(ipl - ihl,
@@ -205,15 +209,17 @@ static int tcf_csum_ipv4_tcp(struct sk_buff *skb,=
 struct iphdr *iph,
 	return 1;
 }
=20
-static int tcf_csum_ipv6_tcp(struct sk_buff *skb, struct ipv6hdr *ip6h=
,
+static int tcf_csum_ipv6_tcp(struct sk_buff *skb,
 			     unsigned int ihl, unsigned int ipl)
 {
 	struct tcphdr *tcph;
+	const struct ipv6hdr *ip6h;
=20
 	tcph =3D tcf_csum_skb_nextlayer(skb, ihl, ipl, sizeof(*tcph));
 	if (tcph =3D=3D NULL)
 		return 0;
=20
+	ip6h =3D ipv6_hdr(skb);
 	tcph->check =3D 0;
 	skb->csum =3D csum_partial(tcph, ipl - ihl, 0);
 	tcph->check =3D csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
@@ -225,10 +231,11 @@ static int tcf_csum_ipv6_tcp(struct sk_buff *skb,=
 struct ipv6hdr *ip6h,
 	return 1;
 }
=20
-static int tcf_csum_ipv4_udp(struct sk_buff *skb, struct iphdr *iph,
+static int tcf_csum_ipv4_udp(struct sk_buff *skb,
 			     unsigned int ihl, unsigned int ipl, int udplite)
 {
 	struct udphdr *udph;
+	const struct iphdr *iph;
 	u16 ul;
=20
 	/*
@@ -242,6 +249,7 @@ static int tcf_csum_ipv4_udp(struct sk_buff *skb, s=
truct iphdr *iph,
 	if (udph =3D=3D NULL)
 		return 0;
=20
+	iph =3D ip_hdr(skb);
 	ul =3D ntohs(udph->len);
=20
 	if (udplite || udph->check) {
@@ -276,10 +284,11 @@ ignore_obscure_skb:
 	return 1;
 }
=20
-static int tcf_csum_ipv6_udp(struct sk_buff *skb, struct ipv6hdr *ip6h=
,
+static int tcf_csum_ipv6_udp(struct sk_buff *skb,
 			     unsigned int ihl, unsigned int ipl, int udplite)
 {
 	struct udphdr *udph;
+	const struct ipv6hdr *ip6h;
 	u16 ul;
=20
 	/*
@@ -293,6 +302,7 @@ static int tcf_csum_ipv6_udp(struct sk_buff *skb, s=
truct ipv6hdr *ip6h,
 	if (udph =3D=3D NULL)
 		return 0;
=20
+	ip6h =3D ipv6_hdr(skb);
 	ul =3D ntohs(udph->len);
=20
 	udph->check =3D 0;
@@ -328,7 +338,7 @@ ignore_obscure_skb:
=20
 static int tcf_csum_ipv4(struct sk_buff *skb, u32 update_flags)
 {
-	struct iphdr *iph;
+	const struct iphdr *iph;
 	int ntkoff;
=20
 	ntkoff =3D skb_network_offset(skb);
@@ -353,19 +363,19 @@ static int tcf_csum_ipv4(struct sk_buff *skb, u32=
 update_flags)
 		break;
 	case IPPROTO_TCP:
 		if (update_flags & TCA_CSUM_UPDATE_FLAG_TCP)
-			if (!tcf_csum_ipv4_tcp(skb, iph, iph->ihl * 4,
+			if (!tcf_csum_ipv4_tcp(skb, iph->ihl * 4,
 					       ntohs(iph->tot_len)))
 				goto fail;
 		break;
 	case IPPROTO_UDP:
 		if (update_flags & TCA_CSUM_UPDATE_FLAG_UDP)
-			if (!tcf_csum_ipv4_udp(skb, iph, iph->ihl * 4,
+			if (!tcf_csum_ipv4_udp(skb, iph->ihl * 4,
 					       ntohs(iph->tot_len), 0))
 				goto fail;
 		break;
 	case IPPROTO_UDPLITE:
 		if (update_flags & TCA_CSUM_UPDATE_FLAG_UDPLITE)
-			if (!tcf_csum_ipv4_udp(skb, iph, iph->ihl * 4,
+			if (!tcf_csum_ipv4_udp(skb, iph->ihl * 4,
 					       ntohs(iph->tot_len), 1))
 				goto fail;
 		break;
@@ -377,7 +387,7 @@ static int tcf_csum_ipv4(struct sk_buff *skb, u32 u=
pdate_flags)
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 			goto fail;
=20
-		ip_send_check(iph);
+		ip_send_check(ip_hdr(skb));
 	}
=20
 	return 1;
@@ -456,6 +466,7 @@ static int tcf_csum_ipv6(struct sk_buff *skb, u32 u=
pdate_flags)
 			ixhl =3D ipv6_optlen(ip6xh);
 			if (!pskb_may_pull(skb, hl + ixhl + ntkoff))
 				goto fail;
+			ip6xh =3D (void *)(skb_network_header(skb) + hl);
 			if ((nexthdr =3D=3D NEXTHDR_HOP) &&
 			    !(tcf_csum_ipv6_hopopts(ip6xh, ixhl, &pl)))
 				goto fail;
@@ -464,25 +475,25 @@ static int tcf_csum_ipv6(struct sk_buff *skb, u32=
 update_flags)
 			break;
 		case IPPROTO_ICMPV6:
 			if (update_flags & TCA_CSUM_UPDATE_FLAG_ICMP)
-				if (!tcf_csum_ipv6_icmp(skb, ip6h,
+				if (!tcf_csum_ipv6_icmp(skb,
 							hl, pl + sizeof(*ip6h)))
 					goto fail;
 			goto done;
 		case IPPROTO_TCP:
 			if (update_flags & TCA_CSUM_UPDATE_FLAG_TCP)
-				if (!tcf_csum_ipv6_tcp(skb, ip6h,
+				if (!tcf_csum_ipv6_tcp(skb,
 						       hl, pl + sizeof(*ip6h)))
 					goto fail;
 			goto done;
 		case IPPROTO_UDP:
 			if (update_flags & TCA_CSUM_UPDATE_FLAG_UDP)
-				if (!tcf_csum_ipv6_udp(skb, ip6h, hl,
+				if (!tcf_csum_ipv6_udp(skb, hl,
 						       pl + sizeof(*ip6h), 0))
 					goto fail;
 			goto done;
 		case IPPROTO_UDPLITE:
 			if (update_flags & TCA_CSUM_UPDATE_FLAG_UDPLITE)
-				if (!tcf_csum_ipv6_udp(skb, ip6h, hl,
+				if (!tcf_csum_ipv6_udp(skb, hl,
 						       pl + sizeof(*ip6h), 1))
 					goto fail;
 			goto done;
