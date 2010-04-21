From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Wed, 21 Apr 2010 13:06:17 +0200
Message-ID: <4BCEDC29.6040303@lastsummer.de>
References: <1271452358.16881.4486.camel@edumazet-laptop>	 <1271520633.16881.4754.camel@edumazet-laptop>	 <20100419.130905.210660275.davem@davemloft.net>	 <20100419.132318.192086187.davem@davemloft.net>	 <1271709121.3845.94.camel@edumazet-laptop>	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>	 <1271743164.3845.128.camel@edumazet-laptop>	 <1271750198.3845.216.camel@edumazet-laptop>	 <4BCDA2B5.4060609@lastsummer.de>	 <i2q65634d661004200809ydba56c35g785ba51900c379f7@mail.gmail.com>	 <4BCEC593.4000007@lastsummer.de> <1271842773.7895.1692.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:45512 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722Ab0DULGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 07:06:24 -0400
In-Reply-To: <1271842773.7895.1692.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mercredi 21 avril 2010 =C3=A0 11:29 +0200, Franco Fichtner a =C3=A9=
crit :
>> Tom Herbert wrote:
>>>> I thought about this for some time...
>>>>
>>>> Do we really need the port numbers here at all? A simple
>>>> addr1^addr2 can provide a good enough pointer for
>>>> distribution amongst CPUs.
>>>>
>>> What about a server behind a TCP proxy?  Also, need to minimize
>>> collisions for RPS to be effective
>> What about routers? What about loopback? This all boils down to
>> the same issue of obscuring IP data by "magical" means and then
>> reattaching functionality by reaching for upper layer information.
>> It is necessary in some cases, but it can cripple performance
>> for other cases.
>>
>> The interesting thing is you don't need to deal with collisions
>> while distributing amonst cpus at all. You just need to make sure
>> the distribution algorithm keeps every single flow attached to
>> the correct cpu.
>>
>> All of the actual flow hashing, tracking and whatever else the
>> traffic needs to go through can be done locally by cpu x which
>> helps a lot with load distribution and cache issues in mind. It
>> also helps locking because there is no global flow lookup table.
>> Oh, and it also reduces collisions with every cpu you add for
>> receiving.
>>
>> I work with a lot of plain office and ISP traffic in mind daily,
>> so please don't misunderstand my motivation here. I'd hate to
>> see poor performance in scenarios in which there is a lot of
>> potential improvement.
>>
>=20
> I am a bit lost by this conversation.
>=20
> Are you saying something is wrong with current schem ?
>=20
> What are exactly your suggestions ?
>=20

Hashing for cpu distribution should be as minimal as it could possibly
be with the least number operations needed to compute a hash, which=20
normally involves touching one cold cache line (ip header). If you add=20
the ports to your mix you have the luxury of solving static ip mappings=
,
but only for protocols that support it. Usage of the destination port
may also prove to be more or less pointless with a lot of http traffic,
because it's most likely static. And you add another potential cold
cache line access. For a lot of traffic scenarios, we'll have a bunch o=
f
internal ips and the internet on the other side, so having a simple has=
h
based on a flavor if internal/external ip is more than enough to work
with for distribution. If the network card can provide a complete hash
all the better. Then this part of my point is void.

But then, hashing for cpu distribution should have nothing todo with
real flow tracking with lookup tables for let's say a firewall or dpi
application, because that data is only needed by local cpu and can
be gathered after distribution. Simply put, the lookup for the flow, if
it is needed, does not belong to distribution. It can be outsourced to
the destination cpu or just simply be ignored, if the application
doesn't care.

> Tom replied to you that a hash derived from (addr1 ^ addr2) would not
> work in situations where all flows goes from machine A to machine B
> (all hashes would be the same)
>=20

Yes, I see the point. And all I'm just asking if it's wise to optimize
for this particular scenario.

If you spin this idea further beyond flow tracking, maybe an applicatio=
n
also needs to do some kind of user tracking by ip. Wouldn't it make
sense to have user based flows on a more local basis, not a global one
because ports will get in the way?

> Current hash is probably more than enough to cover all situations.
>=20

I agree with this, but would like to point out the phrasing "probably
more than enough". :)


=46ranco
