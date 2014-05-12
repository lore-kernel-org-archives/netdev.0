From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: update Destination Cache entries when gateway turn
 into host
Date: Mon, 12 May 2014 11:07:43 +0800
Message-ID: <53703AFF.2040208@cn.fujitsu.com>
References: <536C4A74.2050103@cn.fujitsu.com> <1399856097.16759.116198185.2A93B8D8@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:48367 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750822AbaELDK3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:10:29 -0400
In-Reply-To: <1399856097.16759.116198185.2A93B8D8@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B405=E6=9C=8812=E6=97=A5 08:54, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Thu, May 8, 2014, at 20:24, Duan Jiong wrote:
>>
>> RFC 4861 states in 7.2.5:
>>
>> 	The IsRouter flag in the cache entry MUST be set based on the
>>          Router flag in the received advertisement.  In those cases
>>          where the IsRouter flag changes from TRUE to FALSE as a res=
ult
>>          of this update, the node MUST remove that router from the
>>          Default Router List and update the Destination Cache entrie=
s
>>          for all destinations using that neighbor as a router as
>>          specified in Section 7.3.3.  This is needed to detect when =
a
>>          node that is used as a router stops forwarding packets due =
to
>>          being configured as a host.
>>
>> Currently, when dealing with NA Message which IsRouter flag changes =
from
>> TRUE to FALSE, the kernel only removes router from the Default Route=
r List,
>> and don't update the Destination Cache entries.
>>
>> Now in order to update those Destination Cache entries, i introduce
>> function rt6_clean_tohost().
>>
>> [...]
>>
>> +/*remove routers and update dst entries when gateway turn into host=
=2E*/
>> +static int fib6_clean_tohost(struct rt6_info *rt, void *arg)
>> +{
>> +	struct in6_addr *gateway =3D (struct in6_addr *)arg;
>> +
>> +	if (((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
>> +	    =3D=3D (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
>> +	    && ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {
>> +		return -1;
>> +	} else if (((rt->rt6i_flags & (RTF_GATEWAY | RTF_CACHE))
>> +		      =3D=3D (RTF_GATEWAY | RTF_CACHE))
>> +		    && ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {
>> +		rt->rt6i_flags |=3D RTF_REJECT;
>> +		rt->dst.error =3D -ENETUNREACH;
>> +	}
>> +	return 0;
>> +}
>=20
> I am not so happy with that but have not tried that.
>=20
> The Destination Cache you quote from the RFC (if you follow 7.3.3.) a=
ctually refers to the neighbouring
> subsystem, where we would need to generate subsequent errors in case =
we try to forward a packet
> through a this particular router.
>=20
> The reason why I am not that happy is, that the semantics when neighb=
our nodes are cleared is well
> defined but we don't have that semantics when those rt6_nodes get cle=
ared up. E.g. consider a router which just temporarily switches forward=
ing off and on.
>=20
> I guess we need to inspect NTF_ROUTER flag in the output path somehow=
=2E :/

Why we need to inspect NTF_ROUTER flag?
In my opinion, the problem is that we can't use the neighbour node as n=
ext hop.

Actually, after a node switches from being a router to being a host, we=
 should=20
perform next-hop determination rather than continue sending traffic to =
the former
router, so we could just delete those Destination Cache entries.

You can refer to the below:
RFC 4861 states in 6.3.5:=20
   Whenever the Lifetime of an entry in the Default Router List expires=
,
   that entry is discarded.  When removing a router from the Default
   Router list, the node MUST update the Destination Cache in such a wa=
y
   that all entries using the router perform next-hop determination
   again rather than continue sending traffic to the (deleted) router.

Thanks,
  Duan
>=20
> Greetings,
>=20
>   Hannes
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> .
>=20
