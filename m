From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: use a 64bit load/store in output path
Date: Thu, 01 Dec 2011 08:28:41 +0100
Message-ID: <1322724521.2577.29.camel@edumazet-laptop>
References: <1322715653.2577.25.camel@edumazet-laptop>
	 <20111201.014813.1241057161065435427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57039 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab1LAH2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 02:28:46 -0500
Received: by eaak14 with SMTP id k14so1735378eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 23:28:45 -0800 (PST)
In-Reply-To: <20111201.014813.1241057161065435427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 01:48 -0500, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 01 Dec 2011 06:00:53 +0100
>=20
> > gcc compiler is smart enough to use a single load/store if we
> > memcpy(dptr, sptr, 8) on x86_64, regardless of
> > CONFIG_CC_OPTIMIZE_FOR_SIZE
> >    =20
> > In IP header, daddr immediately follows saddr, this wont change in =
the
> > future. We only need to make sure our flowi4 (saddr,daddr) fields w=
ont
> > break the rule.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Hmmm, this triggers a strange new build warning:
>=20
> net/dccp/ipv4.c: In function =E2=80=98dccp_v4_route_skb=E2=80=99:
> net/dccp/ipv4.c:481:3: warning: initialized field with side-effects o=
verwritten [enabled by default]
> net/dccp/ipv4.c:481:3: warning: (near initialization for =E2=80=98fl4=
=E2=80=99) [enabled by default]

Hmm, seems a compiler bug, since following fixes the warning ?

[PATCH net-next] dccp: fix a compiler warning

net/dccp/ipv4.c: In function =E2=80=98dccp_v4_route_skb=E2=80=99:
net/dccp/ipv4.c:481:3: warning: initialized field with
	side-effects overwritten [enabled by default]
net/dccp/ipv4.c:481:3: warning: (near initialization
	for =E2=80=98fl4=E2=80=99) [enabled by default]


Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/dccp/ipv4.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 3f4e541..1c67fe8 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -474,10 +474,11 @@ static struct dst_entry* dccp_v4_route_skb(struct=
 net *net, struct sock *sk,
 					   struct sk_buff *skb)
 {
 	struct rtable *rt;
+	const struct iphdr *iph =3D ip_hdr(skb);
 	struct flowi4 fl4 =3D {
 		.flowi4_oif =3D skb_rtable(skb)->rt_iif,
-		.daddr =3D ip_hdr(skb)->saddr,
-		.saddr =3D ip_hdr(skb)->daddr,
+		.daddr =3D iph->saddr,
+		.saddr =3D iph->daddr,
 		.flowi4_tos =3D RT_CONN_FLAGS(sk),
 		.flowi4_proto =3D sk->sk_protocol,
 		.fl4_sport =3D dccp_hdr(skb)->dccph_dport,
