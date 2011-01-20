From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.10)
Date: Thu, 20 Jan 2011 23:46:51 +0100
Message-ID: <1295563611.2613.41.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop> <20110113153436.70d3c0a3@s6510>
	 <4D305598.1010207@trash.net> <4D3055C2.3060807@trash.net>
	 <1295015043.3937.20.camel@edumazet-laptop>
	 <20110114154521.54cc8ef5@nehalam>
	 <1295077542.3977.20.camel@edumazet-laptop>
	 <20110117092532.7d5f5a5b@nehalam>
	 <1295286851.3335.36.camel@edumazet-laptop>
	 <20110118110634.7386c757@nehalam> <1295379257.9097.9.camel@edumazet-laptop>
	 <20110120093838.43f9f9b1@nehalam>
	 <1295547589.2825.497.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57650 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323Ab1ATWq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 17:46:57 -0500
Received: by wwa36 with SMTP id 36so1220652wwa.1
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 14:46:56 -0800 (PST)
In-Reply-To: <1295547589.2825.497.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 janvier 2011 =C3=A0 19:19 +0100, Eric Dumazet a =C3=A9crit =
:
> Le jeudi 20 janvier 2011 =C3=A0 09:38 -0800, Stephen Hemminger a =C3=A9=
crit :
>=20
> ...
>=20
> Hi Stephen
>=20
> I am contemplating choke_linearize_header() (yet another hash
> function... oh well...) and say :
>=20
> Instead of this boolean return, just use skb_get_rxhash(). It perform=
s
> what you want, and return 32bits of information, instead of one bit.
>=20
> (if result (rxhash) is zero, it means you can drop packet because it =
is
> not linearized)
>=20
> So choke_match_flow() can be faster if rxhash differs (no cache miss =
on
> skb->data on an old skb)
> (Do the full check only if rxhash is equal on skb1 / skb2)
>=20
> More over, the skb_get_rxhash() call is _really_ needed only if CHOKe
> triggers :
> if (p->qavg <=3D p->qth_min)
> 	we dont have to compute rxhash at all.
>=20

> If you want, I can send a diff on your v0.10, just tell me !

Here is my diff against v 0.10

Seems to work well here

qdisc choke 11: parent 1:11 limit 130000b min 10833b max 32500b ewma 13=
 Plog 21 Scell_log 30
 Sent 459876256 bytes 836183 pkt (dropped 318428, overlimits 28 requeue=
s 0)=20
 rate 51823Kbit 11779pps backlog 5926323b 10781p requeues 0=20
  marked 0 early 28 pdrop 0 other 0 matched 159200

Thanks !


 net/sched/sch_choke.c |  114 ++++++++++++----------------------------
 1 file changed, 37 insertions(+), 77 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index e1ac560..0e898ed 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -141,63 +141,24 @@ static void choke_drop_by_idx(struct Qdisc *sch, =
unsigned int idx)
 	--sch->q.qlen;
 }
=20
-/* Make sure network and transport headers can be dereferenced */
-static bool choke_linearize_header(struct sk_buff *skb)
-{
-	int nhoff, poff;
-	struct ipv6hdr *ip6;
-	struct iphdr *ip;
-	u8 ip_proto;
-	u32 ihl;
-
-	nhoff =3D skb_network_offset(skb);
-
-	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
-		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
-			return false;
-
-		ip =3D (struct iphdr *) (skb->data + nhoff);
-		if (ip->frag_off & htons(IP_MF | IP_OFFSET))
-			return false;
-
-		ip_proto =3D ip->protocol;
-		ihl =3D ip->ihl;
-		break;
-	case __constant_htons(ETH_P_IPV6):
-		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
-			return false;
-
-		ip6 =3D (struct ipv6hdr *) (skb->data + nhoff);
-		ip_proto =3D ip6->nexthdr;
-		ihl =3D (40 >> 2);
-		break;
-	default:
-		return true;
-	}
-
-	poff =3D proto_ports_offset(ip_proto);
-	if (poff >=3D 0) {
-		nhoff +=3D ihl * 4 + poff;
-		if (!pskb_may_pull(skb, nhoff + 4))
-			return false;
-	}
-
-	return true;
-}
-
 /*
  * Compare flow of two packets
  *  Returns true only if source and destination address and port match=
=2E
  *          false for special cases
  */
-static bool choke_match_flow(const struct sk_buff *skb1,
-			     const struct sk_buff *skb2)
+static bool choke_match_flow(struct sk_buff *skb1,
+			     struct sk_buff *skb2)
 {
 	int off1, off2, poff;
+	const u32 *ports1, *ports2;
+	u8 ip_proto;
=20
 	if (skb1->protocol !=3D skb2->protocol)
 		return false;
+	if (skb_get_rxhash(skb1) !=3D skb_get_rxhash(skb2))
+		return false;
+	if (!skb_get_rxhash(skb1))
+		return true;
=20
 	off1 =3D skb_network_offset(skb1);
 	off2 =3D skb_network_offset(skb2);
@@ -209,27 +170,14 @@ static bool choke_match_flow(const struct sk_buff=
 *skb1,
 		ip1 =3D (struct iphdr *) (skb1->data + off1);
 		ip2 =3D (struct iphdr *) (skb2->data + off2);
=20
-		if (ip1->protocol !=3D ip2->protocol ||
+		ip_proto =3D ip1->protocol;
+		if (ip_proto !=3D ip2->protocol ||
 		    ip1->saddr !=3D ip2->saddr || ip1->daddr !=3D ip2->daddr)
 			return false;
-
-		if (ip1->frag_off & htons(IP_MF | IP_OFFSET) ||
-		    ip2->frag_off & htons(IP_MF | IP_OFFSET))
-			return ip1->id =3D=3D ip2->id;
-
-		poff =3D proto_ports_offset(ip1->protocol);
-		if (poff < 0)
-			return true;
-		else {
-			const u32 *ports1, *ports2;
-
-			ports1 =3D (__force u32 *) (skb1->data + off1
-						  + ip1->ihl * 4 + poff);
-			ports2 =3D (__force u32 *) (skb2->data + off2
-						  + ip2->ihl * 4 + poff);
-
-			return *ports1 =3D=3D *ports2;
-		}
+		if ((ip1->frag_off | ip2->frag_off) & htons(IP_MF | IP_OFFSET))
+			ip_proto =3D 0;
+		off1 +=3D ip1->ihl * 4;
+		off2 +=3D ip2->ihl * 4;
 		break;
 	}
=20
@@ -239,15 +187,32 @@ static bool choke_match_flow(const struct sk_buff=
 *skb1,
 		ip1 =3D (struct ipv6hdr *) (skb1->data + off1);
 		ip2 =3D (struct ipv6hdr *) (skb2->data + off2);
=20
-		return (ip1->nexthdr =3D=3D ip2->nexthdr &&
-			ipv6_addr_cmp(&ip1->saddr, &ip2->saddr) =3D=3D 0 &&
-			ipv6_addr_cmp(&ip1->daddr, &ip2->daddr) =3D=3D 0);
+		ip_proto =3D ip1->nexthdr;
+		if (ip_proto !=3D ip2->nexthdr ||
+		    ipv6_addr_cmp(&ip1->saddr, &ip2->saddr) ||
+		    ipv6_addr_cmp(&ip1->daddr, &ip2->daddr))
+			return false;
+		off1 +=3D 40;
+		off2 +=3D 40;
 	}
=20
 	default: /* Maybe compare MAC header here? */
 		return false;
 	}
-	/* not reached */
+	poff =3D proto_ports_offset(ip_proto);
+	if (poff < 0)
+		return true;
+	off1 +=3D poff;
+	off2 +=3D poff;
+	if (!pskb_may_pull(skb1, off1 + 4))
+		return false;
+
+	if (!pskb_may_pull(skb2, off2 + 4))
+		return false;
+
+	ports1 =3D (__force u32 *)(skb1->data + off1);
+	ports2 =3D (__force u32 *)(skb2->data + off2);
+	return *ports1 =3D=3D *ports2;
 }
=20
 static inline void choke_set_classid(struct sk_buff *skb, u16 classid)
@@ -319,10 +284,10 @@ static struct sk_buff *choke_peek_random(const st=
ruct choke_sched_data *q,
  * returns true if matched and sets *pidx
  */
 static bool choke_match_random(const struct choke_sched_data *q,
-			       const struct sk_buff *nskb,
+			       struct sk_buff *nskb,
 			       unsigned int *pidx)
 {
-	const struct sk_buff *oskb;
+	struct sk_buff *oskb;
=20
 	if (q->head =3D=3D q->tail)
 		return false;
@@ -331,7 +296,6 @@ static bool choke_match_random(const struct choke_s=
ched_data *q,
 	if (q->filter_list)
 		return choke_get_classid(nskb) =3D=3D choke_get_classid(oskb);
=20
-
 	return choke_match_flow(oskb, nskb);
 }
=20
@@ -345,10 +309,6 @@ static int choke_enqueue(struct sk_buff *skb, stru=
ct Qdisc *sch)
 		/* If using external classifiers, get result and record it. */
 		if (!choke_classify(skb, sch, &ret))
 			goto other_drop;	/* Packet was eaten by filter */
-	} else {
-		/* for internal classifier, make header accessible */
-		if (!choke_linearize_header(skb))
-			goto other_drop;
 	}
=20
 	/* Compute average queue usage (see RED) */


