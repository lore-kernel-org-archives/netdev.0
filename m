From: d@taht.net (Dave =?utf-8?Q?T=C3=A4ht?=)
Subject: ECN + pfifo_fast borked? (Was Re: [Bloat] shaper team forming up)
Date: Mon, 14 Mar 2011 23:27:28 -0600
Message-ID: <87ipvlosvz.fsf_-_@cruithne.co.teklibre.org>
References: <87wrk1a4gx.fsf@cruithne.co.teklibre.org>
	<5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	<1300134277.2649.19.camel@edumazet-laptop>
	<1300164166.2649.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonathan Morton <chromatix99@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-145-127-229-Colorado.hfc.comcastbusiness.net ([75.145.127.229]:50145
	"EHLO gw.co.teklibre.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752136Ab1COF1c convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 01:27:32 -0400
Received: from cruithne.co.teklibre.org (unknown [IPv6:2002:4b91:7fe5:1::20])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "cruithne.co.teklibre.org", Issuer "CA Cert Signing Authority" (verified OK))
	by gw.co.teklibre.org (Postfix) with ESMTPS id A1D3C5EA3C
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 23:27:30 -0600 (MDT)
In-Reply-To: <1300164166.2649.70.camel@edumazet-laptop> (Eric Dumazet's
	message of "Tue, 15 Mar 2011 05:42:46 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le lundi 14 mars 2011 =C3=A0 21:24 +0100, Eric Dumazet a =C3=A9crit :
>
> remove CC to bloat lists for now, adding David Miller to thread.
>
>> Le lundi 14 mars 2011 =C3=A0 21:55 +0200, Jonathan Morton a =C3=A9cr=
it :
>> > On 14 Mar, 2011, at 9:26 pm, Dave T=C3=A4ht wrote:
>> >=20
>> > > Over the weekend, Dan Siemon uncovered a possible bad interactio=
n
>> > > between ECN and the default pfifo_fast qdisc in Linux.
>> > >=20
>> > > http://www.coverfire.com/archives/2011/03/13/pfifo_fast-and-ecn/
>> >=20

Totally irrelevant bit elided

>> CC netdev, where linux network dev can take a look.
>>=20
>> I would say that this is a wrong analysis :=20
>>=20
>> 1) ECN uses two low order bits of TOS byte
>>=20
>> 2) pfifo_fast uses skb->priority
>>=20
>>=20
>> skb->priority =3D rt_tos2priority(iph->tos);
>>=20
>> #define IPTOS_TOS_MASK            0x1E
>> #define IPTOS_TOS(tos)            ((tos)&IPTOS_TOS_MASK)
>>=20
>> static inline char rt_tos2priority(u8 tos)
>> {
>> 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
>> }
>>=20
>> No interference between two mechanisms, unless sysadmin messed up th=
ings
>> (skb_edit)
>>=20
>>=20
>
> David, it seems ip_tos2prio is wrong on its 2nd entry :
>
> #define TC_PRIO_BESTEFFORT              0
> #define TC_PRIO_FILLER                  1
> #define TC_PRIO_BULK                    2
> #define TC_PRIO_INTERACTIVE_BULK        4
> #define TC_PRIO_INTERACTIVE             6
> #define TC_PRIO_CONTROL                 7
>
> #define TC_PRIO_MAX                     15
>
> net/ipv4/route.c:170:#define ECN_OR_COST(class) TC_PRIO_##class
>
> const __u8 ip_tos2prio[16] =3D {
> 	TC_PRIO_BESTEFFORT,   /* 0 : for flow without ECN */
> 	ECN_OR_COST(FILLER), /* 1 : flow with ECN */
> 	...
> };
>
>
>
>
> This means ECN enabled flows got TC_PRIO_FILLER (what the hell is
> that ?)
>
> pfifo_fast has :
>
> static const u8 prio2band[TC_PRIO_MAX+1] =3D
> 	{ 1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1 };
>
> So a non ECN enabled flow goes to band 1, while an ECN enabled one is=
 in
> band 2 (!).  Thus, ECN enabled flows have a chance being droped more
> often than non ECN flows. Thats not fair...
>
> What do you think ?

Well, that makes 3 of us that think it's wrong. Can we get more?=20

(I'll run through the math again in the morning)

It's most often not actually "enablement" but "assertion", when for
example an ECN bit is put on an ACK packet (by an application, or qdisc=
)
, it drops that ACK packet into the 2 queue - leaving all the other
non-ECN asserted packets in that flow to flow out ahead of it.

Or so dan siemon & I & now you, think. It's late and I really want to r=
echeck
the math and the shifts in the morning. However, if true... this would
explain much ECN related weirdness precisely where it has been hard to
measure, on heavily loaded systems.

>
> Thanks
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6ed6603..fabfe81 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -171,7 +171,7 @@ static struct dst_ops ipv4_dst_ops =3D {
> =20
>  const __u8 ip_tos2prio[16] =3D {
>  	TC_PRIO_BESTEFFORT,
> -	ECN_OR_COST(FILLER),
> +	ECN_OR_COST(BESTEFFORT),
>  	TC_PRIO_BESTEFFORT,
>  	ECN_OR_COST(BESTEFFORT),
>  	TC_PRIO_BULK,
>

I think this is a good short term fix, but it will mildly upset people
that actually still use minimum cost and don't use ECN. That said,=20
RFC1349 has been obsolete for a decade now, and ECN enabled servers are
at 12% penetration according to MIT.

Still, long term, doing a sch_pfifo_dscp that would be fully compliant
with the relevant modern RFCs and eventually making that the standard
would be good.

--=20
Dave Taht
http://nex-6.taht.net
