From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Wed, 31 Oct 2007 23:40:59 +0100
Message-ID: <4729047B.3080003@cosmosbay.com>
References: <4728D54F.2080208@openvz.org>	<20071031194924.2436843e.dada1@cosmosbay.com> <m1hck7hrd1.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48766 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403AbXJaWlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 18:41:10 -0400
In-Reply-To: <m1hck7hrd1.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>=20
>=20
>> Definitly wanted here. Thank you.
>> One more refcounting on each socket creation/deletion was expensive.
>=20
> Really?  Have you actually measured that?  If the overhead is
> measurable and expensive we may want to look at per cpu counters or
> something like that.  So far I don't have any numbers that say any
> of the network namespace work inherently has any overhead.

It seems that on some old opterons (two 246 for example),
"if (atomic_dec_and_test(&net->count))" is rather expensive yes :(

I am not sure per cpu counters help : I tried this and got no speedup. =
(This=20
was on net_device refcnt at that time)

(on this machines, the access through fs/gs selector seems expensive to=
o)

Maybe a lazy mode could be done, ie only do a atomic_dec(), as done in =
dev_put() ?

Also, "count" sits in a cache line that contains mostly read and shared=
=20
fields, you might want to put it in a separate cache line in SMP, to av=
oid=20
cache line ping-pongs.


>=20
>> Maybe we can add a macro to get nd_net from a "struct net_device"
>> so that every instance of
>>
>> if (dev->nd_net !=3D &init_net)
>>     goto drop;
>>
>> can also be optimized away if !CONFIG_NET_NS
>=20
> Well that extra check should be removed once we finish converting
> those code paths.  So I'm not too worried.

OK. Since the conditional test can be predicted by cpu, it certainly do=
esnt=20
matter.

>=20
> If this becomes a big issue I can dig up my old code that
> replaced struct net * with a net_t typedef and used functions
> for all of the comparisons and allowed everything to be compiled
> away.



>=20
> Trouble was it was sufficiently different that it was just enough
> different that people could not immediately understand the code.
>=20


