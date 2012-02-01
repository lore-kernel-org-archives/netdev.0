From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Wed, 01 Feb 2012 15:07:42 +0100
Message-ID: <1328105262.2595.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	 <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
	 <4F264A6C.3070706@mellanox.com> <1327910672.2891.12.camel@edumazet-laptop>
	 <20120130081849.GA7848@gondor.apana.org.au>
	 <1327913583.2288.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120130085742.GA8262@gondor.apana.org.au>
	 <CAJZOPZJb1HvcS0XXKLvoDuoi1EfYTY-awwY2g0aHWoS=4qmdyQ@mail.gmail.com>
	 <20120201083837.GA7081@gondor.apana.org.au>
	 <CAJZOPZJVAQoy0B30zqkROOBp_-bF6=EdU2L9V025fJgTexVuFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Roland Dreier <roland@kernel.org>, netdev@vger.kernel.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50498 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817Ab2BAOHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 09:07:46 -0500
In-Reply-To: <CAJZOPZJVAQoy0B30zqkROOBp_-bF6=EdU2L9V025fJgTexVuFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 11:43 +0200, Or Gerlitz a =C3=A9=
crit :
> On Wed, Feb 1, 2012 at 10:38 AM, Herbert Xu <herbert@gondor.apana.org=
=2Eau> wrote:
> > On Wed, Feb 01, 2012 at 10:23:22AM +0200, Or Gerlitz wrote:
>=20
> >> So what would you recommend here? not sure if you saw that, but Sh=
lomo
> >> suggested to add new entry to the header ops, compare_header e.g s=
uch
> >> that if skb->dev has this callback use it instead of
> >> compare_ether_header in __napi_gro_receive, makes sense?
>=20
> > If we just turn it into a memcmp with a variable length would
> > that work for you?
>=20
> I think yes, FWIW we will compare the IPoIB header, Roland is that ok=
ay for you?

A memcmp(xxx, yyy, variable_len) will be out of line and slow, its a bi=
t
sad ...

Are skb_mac_header(p) / skb_gro_mac_header(skb) going to point to IPoIB
header ?

Maybe we can keep a fastpath for ethernet case...
(the "if (hlen =3D=3D ETH_HLEN) being always predicted)

Maybe need to introduce gro_hard_header_len as well)

diff --git a/net/core/dev.c b/net/core/dev.c
index 115dee1..62abee4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3500,14 +3500,20 @@ static inline gro_result_t
 __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
+	unsigned int hlen =3D skb->dev->hard_header_len;
=20
 	for (p =3D napi->gro_list; p; p =3D p->next) {
 		unsigned long diffs;
=20
 		diffs =3D (unsigned long)p->dev ^ (unsigned long)skb->dev;
 		diffs |=3D p->vlan_tci ^ skb->vlan_tci;
-		diffs |=3D compare_ether_header(skb_mac_header(p),
-					      skb_gro_mac_header(skb));
+		if (hlen =3D=3D ETH_HLEN)
+			diffs |=3D compare_ether_header(skb_mac_header(p),
+						      skb_gro_mac_header(skb));
+		else if (!diffs)
+			diffs =3D memcmp(skb_mac_header(p),
+					skb_gro_mac_header(skb),
+					skb->dev->hard_header_len);
 		NAPI_GRO_CB(p)->same_flow =3D !diffs;
 		NAPI_GRO_CB(p)->flush =3D 0;
 	}
