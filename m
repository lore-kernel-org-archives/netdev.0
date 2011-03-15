From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bloat] shaper team forming up
Date: Tue, 15 Mar 2011 05:42:46 +0100
Message-ID: <1300164166.2649.70.camel@edumazet-laptop>
References: <87wrk1a4gx.fsf@cruithne.co.teklibre.org>
	 <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	 <1300134277.2649.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave =?ISO-8859-1?Q?T=E4ht?= <d@taht.net>,
	netdev <netdev@vger.kernel.org>
To: Jonathan Morton <chromatix99@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40834 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab1COEmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 00:42:50 -0400
Received: by wwa36 with SMTP id 36so266128wwa.1
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 21:42:49 -0700 (PDT)
In-Reply-To: <1300134277.2649.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 21:24 +0100, Eric Dumazet a =C3=A9crit :

remove CC to bloat lists for now, adding David Miller to thread.

> Le lundi 14 mars 2011 =C3=A0 21:55 +0200, Jonathan Morton a =C3=A9cri=
t :
> > On 14 Mar, 2011, at 9:26 pm, Dave T=C3=A4ht wrote:
> >=20
> > > Over the weekend, Dan Siemons uncovered a possible bad interactio=
n
> > > between ECN and the default pfifo_fast qdisc in Linux.
> > >=20
> > > http://www.coverfire.com/archives/2011/03/13/pfifo_fast-and-ecn/
> >=20
> > This seems to be more complicated that it appears.  It looks as tho=
ugh
> > Linux has re-used the LSB of the old TOS field for some "link local=
"
> > flag which is used by routing.
> >=20
> > It's not immediately obvious whether pfifo_fast is using this new
> > interpretation though.  If it isn't, the fix should be to remove th=
e
> > RTO_ONLINK bit from the mask it's using on the tos field.  The othe=
r
> > half of the mask correctly excludes the ECN bits from the field.
> >=20
>=20
> CC netdev, where linux network dev can take a look.
>=20
> I would say that this is a wrong analysis :=20
>=20
> 1) ECN uses two low order bits of TOS byte
>=20
> 2) pfifo_fast uses skb->priority
>=20
>=20
> skb->priority =3D rt_tos2priority(iph->tos);
>=20
> #define IPTOS_TOS_MASK            0x1E
> #define IPTOS_TOS(tos)            ((tos)&IPTOS_TOS_MASK)
>=20
> static inline char rt_tos2priority(u8 tos)
> {
> 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
> }
>=20
> No interference between two mechanisms, unless sysadmin messed up thi=
ngs
> (skb_edit)
>=20
>=20

David, it seems ip_tos2prio is wrong on its 2nd entry :

#define TC_PRIO_BESTEFFORT              0
#define TC_PRIO_FILLER                  1
#define TC_PRIO_BULK                    2
#define TC_PRIO_INTERACTIVE_BULK        4
#define TC_PRIO_INTERACTIVE             6
#define TC_PRIO_CONTROL                 7

#define TC_PRIO_MAX                     15

net/ipv4/route.c:170:#define ECN_OR_COST(class) TC_PRIO_##class

const __u8 ip_tos2prio[16] =3D {
	TC_PRIO_BESTEFFORT,   /* 0 : for flow without ECN */
	ECN_OR_COST(FILLER), /* 1 : flow with ECN */
	...
};




This means ECN enabled flows got TC_PRIO_FILLER (what the hell is
that ?)

pfifo_fast has :

static const u8 prio2band[TC_PRIO_MAX+1] =3D
	{ 1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1 };

So a non ECN enabled flow goes to band 1, while an ECN enabled one is i=
n
band 2 (!).  Thus, ECN enabled flows have a chance being droped more
often than non ECN flows. Thats not fair...

What do you think ?

Thanks

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6ed6603..fabfe81 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -171,7 +171,7 @@ static struct dst_ops ipv4_dst_ops =3D {
=20
 const __u8 ip_tos2prio[16] =3D {
 	TC_PRIO_BESTEFFORT,
-	ECN_OR_COST(FILLER),
+	ECN_OR_COST(BESTEFFORT),
 	TC_PRIO_BESTEFFORT,
 	ECN_OR_COST(BESTEFFORT),
 	TC_PRIO_BULK,


