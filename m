From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 11:46:02 +0200
Message-ID: <4E5619DA.6070902@arndnet.de>
References: <1314226834.6797.5.camel@edumazet-laptop>  <1314229310-8074-1-git-send-email-hagen@jauu.net>  <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>  <1314250134.6797.24.camel@edumazet-laptop>  <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>  <1314260805.2387.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E560BFD.5020301@arndnet.de> <1314263389.2387.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>,
	Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.unitix.de ([176.9.2.175]:41326 "EHLO mail2.unitix.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867Ab1HYJqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 05:46:04 -0400
In-Reply-To: <1314263389.2387.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Am 25.08.2011 11:09, schrieb Eric Dumazet:
> Le jeudi 25 ao=C3=BBt 2011 =C3=A0 10:46 +0200, Arnd Hannemann a =C3=A9=
crit :
>> Am 25.08.2011 10:26, schrieb Eric Dumazet:
>>> Le jeudi 25 ao=C3=BBt 2011 =C3=A0 09:28 +0200, Alexander Zimmermann=
 a =C3=A9crit :
>>>> Am 25.08.2011 um 07:28 schrieb Eric Dumazet:
>>>
>>>>> Real question is : do we really want to process ~1000 timer inter=
rupts
>>>>> per tcp session, ~2000 skb alloc/free/build/handling, possibly ~1=
000 ARP
>>>>> requests, only to make tcp revover in ~1sec when connectivity ret=
urns
>>>>> back. This just doesnt scale.
>>>>
>>>> maybe a stupid question, but 1000?. With an minRTO of 200ms and a =
maximum
>>>> probing time of 120s, we 600 retransmits in a worst-case-senario
>>>> (assumed that we get for every rot retransmission an icmp). No?
>>>
>>> Where is asserted the "max probing time of 120s" ?=20
>>>
>>> It is not the case on my machine :
>>> I have way more retransmits than that, even if spaced by 1600 ms
>>>
>>> 07:16:13.389331 write(3, "\350F\235JC\357\376\363&\3\374\270R\21L\2=
6\324{\37p\342\244i\304\356\241I:\301\332\222\26"..., 48) =3D 48
>>> 07:16:13.389417 select(7, [3 4], [], NULL, NULL) =3D 1 (in [3])
>>> 07:31:39.901311 read(3, 0xff8c4c90, 8192) =3D -1 EHOSTUNREACH (No r=
oute to host)
>>>
>>> Old kernels where performing up to 15 retries, doing exponential ba=
ckoff.
>>>
>>> Now its kind of unlimited, according to experimental results.
>>
>> That shouldn't be. It should stop after the same time a TCP connecti=
on with an
>> RTO of Minimum RTO which is doing 15 retries (tcp_retries2=3D15) and=
 doing exponential backoff.
>> So it should be around 900s*. But it could be that because of the ic=
sk_retransmit wrapover
>> this doesn't work as expected.
>>
>> * 200ms + 400ms + 800ms ...
>=20
> It is 924 second with retries2=3D15 (default value)
>=20
> I said ~1000 probes.
>=20
> If ICMP are not rate limited, that could be about 924*5 probes, inste=
ad
> of 15 probes on old kernels.

At a rate of 5 packets/s if RTT is zero, yes. I would like to say: so
what? But your example with millions of idle connections stands.

> Maybe we should refine the thing a bit, to not reverse backoff unless
> rto is > some_threshold.
>=20
> Say 10s being the value, that would give at most 92 tries.

I personally think that 10s would be too large and eliminate the benefi=
t of the
algorithm, so I would prefer a different solution.

In case of one bulk data TCP session, which was transmitting hundreds o=
f packets/s
before the connectivity disruption those worst case rate of 5 packet/s =
really
seems conservative enough.

However in case of a lot of idle connections, which were transmitting o=
nly
a number of packets per minute. We might increase the rate drastically =
for
a certain period until it throttles down. You say that we have a proble=
m here
correct?

Do you think it would be possible without much hassle to use a kind of =
"global"
rate limiting only for these probe packets of a TCP connection?

> I mean, what is the gain to be able to restart a frozen TCP session w=
ith
> a 1sec latency instead of 10s if it was blocked more than 60 seconds =
?

I'm afraid it does a lot, especially in highly dynamic environments. Yo=
u
don't have just the additional latency, you may actually miss the full
period where connectivity was there, and then just retransmit into the =
next
connectivity disrupted period.

Best regards,
Arnd
