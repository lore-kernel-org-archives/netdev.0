From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv4: more compliant RFC 3168 support
Date: Sun, 15 May 2011 18:01:50 +0200
Message-ID: <1305475310.3120.146.camel@edumazet-laptop>
References: <201105141938.28344.v13@v13.gr>
	 <1305464176.3120.113.camel@edumazet-laptop>
	 <1305466542.3120.129.camel@edumazet-laptop> <201105151808.39231.v13@v13.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stefanos Harhalakis <v13@v13.gr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52793 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756656Ab1EOQBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 12:01:54 -0400
Received: by wya21 with SMTP id 21so2897892wya.19
        for <netdev@vger.kernel.org>; Sun, 15 May 2011 09:01:53 -0700 (PDT)
In-Reply-To: <201105151808.39231.v13@v13.gr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 15 mai 2011 =C3=A0 18:08 +0300, Stefanos Harhalakis a =C3=A9=
crit :
> Hello,
>=20
> On Sunday 15 of May 2011, Eric Dumazet wrote:
> > +static inline int ip4_frag_ecn_fold(u8 ecn)
> > +{
> > +	switch (ecn) {
> > +	/* If same ECN combination was observed on all fragments, do noth=
ing */
> > +	case IPFRAG_ECN_NOT_ECT:
> > +	case IPFRAG_ECN_ECT_1:
> > +	case IPFRAG_ECN_ECT_0:
> > +	case IPFRAG_ECN_CE:
> > +	/* if a ECT_1 ECT_0 combination was observed, do nothing as well =
*/
> > +	case IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1:
> > +		return 0;
> > +	/* at least one fragment had CE, and others ECT_0 or ECT_1 */
> > +	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0:
> > +	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1:
> > +	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1:
> > +		return INET_ECN_CE;
> > +	/* other combinations are invalid : drop frame */
> > +	default:
> > +		return -1;
> > +	}
> >  }
>=20
> You may wish to simplify this exhaustive check to:
>=20
> if (unlikely((ecn & IPFRAG_ECN_NOT_ECT) && ecn!=3DIPFRAG_ECN_NOT_ECT)=
)
>   return -1;
> else if (ecn & IPFRAG_ECN_CE)
>   return INET_ECN_CE;
> else
>   return 0;
>=20
> although I'm not sure which method will be faster.
>=20

Problem of this version is that common frames in the Internet (NOT_ECT
or ECT_X or ECT_X) will take the longest path to come to "return 0;"

a switch() version is fast because gcc emits a table based jump

> Also, returning the exact same value for NOT_ECT and ECT_X and then O=
Ring
> this with the TOS seems like it will make it loose the ECT_X info. No=
? (but
> also, I'm not sure if this is needed anyway from that point on).
>=20

I dont understand what you mean here. We really need to not loose ECT_X=
,
and I believe we dont.

-1 : Drop the frame anyway
0 : No change on iph->tos field (we keep its value. it can have ECT_X.
Remember all fragments share same (iph->tos & 3) value)
3 : We make sure iph->tos is ORed with 3 to assert CE on result frame.

> p.s. I'm not sure whether this message will make it to the netdev lis=
t.

It should, no worry.


