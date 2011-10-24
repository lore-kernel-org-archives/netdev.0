From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] cls_flow: Add tunnel support to the flow classifier
Date: Mon, 24 Oct 2011 05:14:41 +0200
Message-ID: <1319426081.2517.20.camel@edumazet-laptop>
References: <1318806373.7169.35.camel@ganymede>
	 <1318833623.2500.45.camel@edumazet-laptop>
	 <1319419287.20602.21.camel@ganymede>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Dan Siemon <dan@coverfire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33980 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708Ab1JXDOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 23:14:46 -0400
Received: by wyg36 with SMTP id 36so5702747wyg.19
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2011 20:14:45 -0700 (PDT)
In-Reply-To: <1319419287.20602.21.camel@ganymede>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 23 octobre 2011 =C3=A0 21:21 -0400, Dan Siemon a =C3=A9crit=
 :

> Thanks for the review.
>=20
> Are you arguing this use case isn't worth addressing or that there is=
 a
> more efficient way to implement this with less code?
>=20

Its worth doing it, but also needs more efficient code ;)

As long as we were reading only bytes in the first 64 bytes of the
frame, existing code was probably fine and efficient.

If we want to add features and features, this is going to ask more byte=
s
so can trigger expensive skb head reallocs.

> > IPv6 part is also a bit limited : It assumes TCP/UDP headers are th=
e
> > first ones. Maybe its time to use ipv6_skip_exthdr() ?
>=20
> I noticed this too but the existing src-proto and dst-proto don't han=
dle
> this case either. Maybe I can look into fixing those as well.
>=20

Yes.

> > Note also that if we pull (with pskb_network_may_pull()) too many b=
ytes,
> > we kill routing performance on paged frags devices, wich are now
> > becoming very common.
>=20
> I don't know what paged frag devices means but I trust you are correc=
t :)
>=20
> The existing keys also use pskb_network_may_pull(). Should they be ch=
anged as well?
>=20

A frame delivered by such device has for example 64 bytes present in sk=
b
head, but remaining of data sits in attached fragment(s).=20

=46or example :
drivers/net/ethernet/emulex/benet/be.h
/* Number of bytes of an RX frame that are copied to skb->data */
#define BE_HDR_LEN      ((u16) 64)

This works well if this fragment stay as is until being delivered to
userland, or forwarded.

Using pskb_network_may_pull() on data present on fragment might force t=
o
reallocate skb head because it was too small, including a copy of struc=
t
skb_shared_info, and all headroom (usually 64 bytes were reserved by
dev_alloc_skb()).

Adding tunnelling code definitely can increase the max offset of
inspected data from the frame beyond 64.

skb_header_pointer() can access to frag data without reallocations.

You can find many use examples in net/sched/cls_u32.c & net/netfilter

If you prefer, I can do the preliminary work=20

Here is a patch to give a hint :

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 6994214..cda6bf1 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -65,19 +65,27 @@ static inline u32 addr_fold(void *addr)
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
@@ -236,7 +244,7 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 })
 #endif
=20
-static u32 flow_get_nfct_src(struct sk_buff *skb)
+static u32 flow_get_nfct_src(const struct sk_buff *skb, int nhoff)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -245,7 +253,7 @@ static u32 flow_get_nfct_src(struct sk_buff *skb)
 		return ntohl(CTTUPLE(skb, src.u3.ip6[3]));
 	}
 fallback:
-	return flow_get_src(skb);
+	return flow_get_src(skb, nhoff);
 }
=20
 static u32 flow_get_nfct_dst(struct sk_buff *skb)
@@ -313,9 +321,11 @@ static u32 flow_get_rxhash(struct sk_buff *skb)
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
 		return flow_get_dst(skb);
 	case FLOW_KEY_PROTO:
@@ -333,7 +343,7 @@ static u32 flow_key_get(struct sk_buff *skb, int ke=
y)
 	case FLOW_KEY_NFCT:
 		return flow_get_nfct(skb);
 	case FLOW_KEY_NFCT_SRC:
-		return flow_get_nfct_src(skb);
+		return flow_get_nfct_src(skb, nhoff);
 	case FLOW_KEY_NFCT_DST:
 		return flow_get_nfct_dst(skb);
 	case FLOW_KEY_NFCT_PROTO_SRC:
