From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
Subject: [PATCH net-next 3/3] ipv4: ICMP packet inspection for multipath
Date: Wed, 17 Jun 2015 22:08:06 +0200
Message-ID: <1434571686-5149-4-git-send-email-pch@ordbogen.com>
References: <1434571686-5149-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-api@vger.kernel.org,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([86.58.170.13]:60802 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbbFQUOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 16:14:42 -0400
In-Reply-To: <1434571686-5149-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP packets are inspected to let them route together with the flow the=
y
belong to, allowing anycast environments to work with ECMP.

Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
---
 net/ipv4/icmp.c  | 27 ++++++++++++++++++-
 net/ipv4/route.c | 80 ++++++++++++++++++++++++++++++++++++++++++++++--=
--------
 2 files changed, 92 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 3abcfea..20f1d5e 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -447,6 +447,7 @@ static struct rtable *icmp_route_lookup(struct net =
*net,
 {
 	struct rtable *rt, *rt2;
 	struct flowi4 fl4_dec;
+	struct flowi4 mp_flow;
 	int err;
=20
 	memset(fl4, 0, sizeof(*fl4));
@@ -459,7 +460,31 @@ static struct rtable *icmp_route_lookup(struct net=
 *net,
 	fl4->fl4_icmp_type =3D type;
 	fl4->fl4_icmp_code =3D code;
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
-	rt =3D __ip_route_output_key(net, fl4, NULL);
+
+	/* Source and destination is swapped. See ip_multipath_flow */
+	mp_flow.saddr =3D iph->daddr;
+	mp_flow.daddr =3D iph->saddr;
+	mp_flow.flowi4_proto =3D iph->protocol;
+	mp_flow.fl4_sport =3D 0;
+	mp_flow.fl4_dport =3D 0;
+	if (!ip_is_fragment(iph)) {
+		if (iph->protocol =3D=3D IPPROTO_TCP ||
+		    iph->protocol =3D=3D IPPROTO_UDP ||
+		    iph->protocol =3D=3D IPPROTO_SCTP) {
+			__be16 _ports[2];
+			const __be16 *ports;
+
+			ports =3D skb_header_pointer(skb_in, iph->ihl * 4,
+						   sizeof(_ports),
+						   &_ports);
+			if (ports) {
+				mp_flow.fl4_sport =3D ports[1];
+				mp_flow.fl4_dport =3D ports[0];
+			}
+		}
+	}
+
+	rt =3D __ip_route_output_key(net, fl4, &mp_flow);
 	if (IS_ERR(rt))
 		return rt;
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a1ec62c..bab4318 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1635,31 +1635,83 @@ out:
 /* Fill flow key data based on packet for use in multipath routing. */
 static void ip_multipath_flow(const struct sk_buff *skb, struct flowi4=
 *flow)
 {
-	const struct iphdr *iph;
-
-	iph =3D ip_hdr(skb);
-
-	flow->saddr =3D iph->saddr;
-	flow->daddr =3D iph->daddr;
-	flow->flowi4_proto =3D iph->protocol;
+	struct icmphdr _icmph;
+	struct iphdr _inner_iph;
+	const struct iphdr *outer_iph;
+	const struct icmphdr *icmph;
+	const struct iphdr *inner_iph;
+	unsigned int offset;
+	__be16 _ports[2];
+	const __be16 *ports;
+
+	outer_iph =3D ip_hdr(skb);
+
+	flow->saddr =3D outer_iph->saddr;
+	flow->daddr =3D outer_iph->daddr;
+	flow->flowi4_proto =3D outer_iph->protocol;
 	flow->fl4_sport =3D 0;
 	flow->fl4_dport =3D 0;
=20
-	if (unlikely(ip_is_fragment(iph)))
+	if (unlikely(ip_is_fragment(outer_iph)))
 		return;
=20
-	if (iph->protocol =3D=3D IPPROTO_TCP ||
-	    iph->protocol =3D=3D IPPROTO_UDP ||
-	    iph->protocol =3D=3D IPPROTO_SCTP) {
-		__be16 _ports;
-		const __be16 *ports;
+	offset =3D outer_iph->ihl * 4;
=20
-		ports =3D skb_header_pointer(skb, iph->ihl * 4, sizeof(_ports),
+	if (outer_iph->protocol =3D=3D IPPROTO_TCP ||
+	    outer_iph->protocol =3D=3D IPPROTO_UDP ||
+	    outer_iph->protocol =3D=3D IPPROTO_SCTP) {
+		ports =3D skb_header_pointer(skb, offset, sizeof(_ports),
 					   &_ports);
 		if (ports) {
 			flow->fl4_sport =3D ports[0];
 			flow->fl4_dport =3D ports[1];
 		}
+
+		return;
+	}
+
+	if (outer_iph->protocol !=3D IPPROTO_ICMP)
+		return;
+
+	icmph =3D skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	if (!icmph)
+		return;
+
+	if (icmph->type !=3D ICMP_DEST_UNREACH &&
+	    icmph->type !=3D ICMP_SOURCE_QUENCH &&
+	    icmph->type !=3D ICMP_REDIRECT &&
+	    icmph->type !=3D ICMP_TIME_EXCEEDED &&
+	    icmph->type !=3D ICMP_PARAMETERPROB) {
+		return;
+	}
+
+	offset +=3D sizeof(_icmph);
+	inner_iph =3D skb_header_pointer(skb, offset, sizeof(_inner_iph),
+				       &_inner_iph);
+	if (inner_iph)
+		return;
+
+	/* Since the ICMP payload contains a packet sent from the current
+	 * recipient, we swap source and destination addresses and ports
+	 */
+	flow->saddr =3D inner_iph->daddr;
+	flow->daddr =3D inner_iph->saddr;
+	flow->flowi4_proto =3D inner_iph->protocol;
+
+	if (unlikely(ip_is_fragment(inner_iph)))
+		return;
+
+	if (inner_iph->protocol !=3D IPPROTO_TCP &&
+	    inner_iph->protocol !=3D IPPROTO_UDP &&
+	    inner_iph->protocol !=3D IPPROTO_SCTP) {
+		return;
+	}
+
+	offset +=3D inner_iph->ihl * 4;
+	ports =3D skb_header_pointer(skb, offset, sizeof(_ports), &_ports);
+	if (ports) {
+		flow->fl4_sport =3D ports[1];
+		flow->fl4_dport =3D ports[0];
 	}
 }
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
--=20
2.1.4
