From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: IP defragmentation must be ECN aware
Date: Wed, 05 Jan 2011 18:52:55 +0100
Message-ID: <1294249975.10633.74.camel@edumazet-laptop>
References: <1294186431.3420.19.camel@edumazet-laptop>
	 <1294235942.2775.191.camel@edumazet-laptop>
	 <20110105091340.3f8833ef@nehalam>
	 <1294249261.10633.54.camel@edumazet-laptop>
	 <20110105094830.63a68230@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40043 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211Ab1AERxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 12:53:06 -0500
Received: by wyb28 with SMTP id 28so15590343wyb.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 09:53:00 -0800 (PST)
In-Reply-To: <20110105094830.63a68230@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 janvier 2011 =C3=A0 09:48 -0800, Stephen Hemminger a =C3=
=A9crit :

> At least make it unsigned int?
>=20

Let's keep it simple and use u8 as you suggested ;)

[PATCH v2] ipv4: IP defragmentation must be ECN aware

RFC3168 (The Addition of Explicit Congestion Notification to IP)
states :

5.3.  Fragmentation

   ECN-capable packets MAY have the DF (Don't Fragment) bit set.
   Reassembly of a fragmented packet MUST NOT lose indications of
   congestion.  In other words, if any fragment of an IP packet to be
   reassembled has the CE codepoint set, then one of two actions MUST b=
e
   taken:

      * Set the CE codepoint on the reassembled packet.  However, this
        MUST NOT occur if any of the other fragments contributing to
        this reassembly carries the Not-ECT codepoint.

      * The packet is dropped, instead of being reassembled, for any
        other reason.

This patch implements this requirement for IPv4, choosing the first
action :=20

If one fragment had NO-ECT codepoint
        reassembled frame has NO-ECT
ElIf one fragment had CE codepoint
        reassembled frame has CE

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Use u8 instead of int in ip4_frag_ecn()
 net/ipv4/ip_fragment.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+)


diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index e6215bd..e6b53a7 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -45,6 +45,7 @@
 #include <linux/udp.h>
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
+#include <net/inet_ecn.h>
=20
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reasse=
mbly.c
@@ -70,11 +71,28 @@ struct ipq {
 	__be32		daddr;
 	__be16		id;
 	u8		protocol;
+	u8		ecn; /* RFC3168 support */
 	int             iif;
 	unsigned int    rid;
 	struct inet_peer *peer;
 };
=20
+#define IPFRAG_ECN_CLEAR  0x01 /* one frag had INET_ECN_NOT_ECT */
+#define IPFRAG_ECN_SET_CE 0x04 /* one frag had INET_ECN_CE */
+
+static inline u8 ip4_frag_ecn(u8 tos)
+{
+	tos =3D (tos & INET_ECN_MASK) + 1;
+	/*
+	 * After the last operation we have (in binary):
+	 * INET_ECN_NOT_ECT =3D> 001
+	 * INET_ECN_ECT_1   =3D> 010
+	 * INET_ECN_ECT_0   =3D> 011
+	 * INET_ECN_CE      =3D> 100
+	 */
+	return (tos & 2) ? 0 : tos;
+}
+
 static struct inet_frags ip4_frags;
=20
 int ip_frag_nqueues(struct net *net)
@@ -137,6 +155,7 @@ static void ip4_frag_init(struct inet_frag_queue *q=
, void *a)
=20
 	qp->protocol =3D arg->iph->protocol;
 	qp->id =3D arg->iph->id;
+	qp->ecn =3D ip4_frag_ecn(arg->iph->tos);
 	qp->saddr =3D arg->iph->saddr;
 	qp->daddr =3D arg->iph->daddr;
 	qp->user =3D arg->user;
@@ -316,6 +335,7 @@ static int ip_frag_reinit(struct ipq *qp)
 	qp->q.fragments =3D NULL;
 	qp->q.fragments_tail =3D NULL;
 	qp->iif =3D 0;
+	qp->ecn =3D 0;
=20
 	return 0;
 }
@@ -328,6 +348,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_=
buff *skb)
 	int flags, offset;
 	int ihl, end;
 	int err =3D -ENOENT;
+	u8 ecn;
=20
 	if (qp->q.last_in & INET_FRAG_COMPLETE)
 		goto err;
@@ -339,6 +360,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_=
buff *skb)
 		goto err;
 	}
=20
+	ecn =3D ip4_frag_ecn(ip_hdr(skb)->tos);
 	offset =3D ntohs(ip_hdr(skb)->frag_off);
 	flags =3D offset & ~IP_OFFSET;
 	offset &=3D IP_OFFSET;
@@ -472,6 +494,7 @@ found:
 	}
 	qp->q.stamp =3D skb->tstamp;
 	qp->q.meat +=3D skb->len;
+	qp->ecn |=3D ecn;
 	atomic_add(skb->truesize, &qp->q.net->mem);
 	if (offset =3D=3D 0)
 		qp->q.last_in |=3D INET_FRAG_FIRST_IN;
@@ -583,6 +606,17 @@ static int ip_frag_reasm(struct ipq *qp, struct sk=
_buff *prev,
 	iph =3D ip_hdr(head);
 	iph->frag_off =3D 0;
 	iph->tot_len =3D htons(len);
+	/* RFC3168 5.3 Fragmentation support
+	 * If one fragment had INET_ECN_NOT_ECT,
+	 *	reassembled frame also has INET_ECN_NOT_ECT
+	 * Elif one fragment had INET_ECN_CE
+	 *	reassembled frame also has INET_ECN_CE
+	 */
+	if (qp->ecn & IPFRAG_ECN_CLEAR)
+		iph->tos &=3D ~INET_ECN_MASK;
+	else if (qp->ecn & IPFRAG_ECN_SET_CE)
+		iph->tos |=3D INET_ECN_CE;
+
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments =3D NULL;
 	qp->q.fragments_tail =3D NULL;


