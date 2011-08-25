From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 11:09:49 +0200
Message-ID: <1314263389.2387.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314226834.6797.5.camel@edumazet-laptop>
	 <1314229310-8074-1-git-send-email-hagen@jauu.net>
	 <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>
	 <1314250134.6797.24.camel@edumazet-laptop>
	 <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>
	 <1314260805.2387.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E560BFD.5020301@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>,
	Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>
To: Arnd Hannemann <arnd@arndnet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56066 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab1HYJJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 05:09:48 -0400
Received: by wyg24 with SMTP id 24so1488610wyg.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 02:09:47 -0700 (PDT)
In-Reply-To: <4E560BFD.5020301@arndnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 ao=C3=BBt 2011 =C3=A0 10:46 +0200, Arnd Hannemann a =C3=A9c=
rit :
> Hi,
>=20
> Am 25.08.2011 10:26, schrieb Eric Dumazet:
> > Le jeudi 25 ao=C3=BBt 2011 =C3=A0 09:28 +0200, Alexander Zimmermann=
 a =C3=A9crit :
> >> Hi Eric,
> >>
> >> Am 25.08.2011 um 07:28 schrieb Eric Dumazet:
> >=20
> >>> Real question is : do we really want to process ~1000 timer inter=
rupts
> >>> per tcp session, ~2000 skb alloc/free/build/handling, possibly ~1=
000 ARP
> >>> requests, only to make tcp revover in ~1sec when connectivity ret=
urns
> >>> back. This just doesnt scale.
> >>
> >> maybe a stupid question, but 1000?. With an minRTO of 200ms and a =
maximum
> >> probing time of 120s, we 600 retransmits in a worst-case-senario
> >> (assumed that we get for every rot retransmission an icmp). No?
> >=20
> > Where is asserted the "max probing time of 120s" ?=20
> >=20
> > It is not the case on my machine :
> > I have way more retransmits than that, even if spaced by 1600 ms
> >=20
> > 07:16:13.389331 write(3, "\350F\235JC\357\376\363&\3\374\270R\21L\2=
6\324{\37p\342\244i\304\356\241I:\301\332\222\26"..., 48) =3D 48
> > 07:16:13.389417 select(7, [3 4], [], NULL, NULL) =3D 1 (in [3])
> > 07:31:39.901311 read(3, 0xff8c4c90, 8192) =3D -1 EHOSTUNREACH (No r=
oute to host)
> >=20
> > Old kernels where performing up to 15 retries, doing exponential ba=
ckoff.
> >=20
> > Now its kind of unlimited, according to experimental results.
>=20
> That shouldn't be. It should stop after the same time a TCP connectio=
n with an
> RTO of Minimum RTO which is doing 15 retries (tcp_retries2=3D15) and =
doing exponential backoff.
> So it should be around 900s*. But it could be that because of the ics=
k_retransmit wrapover
> this doesn't work as expected.
>=20
> * 200ms + 400ms + 800ms ...

It is 924 second with retries2=3D15 (default value)

I said ~1000 probes.

If ICMP are not rate limited, that could be about 924*5 probes, instead
of 15 probes on old kernels.

Maybe we should refine the thing a bit, to not reverse backoff unless
rto is > some_threshold.

Say 10s being the value, that would give at most 92 tries.

I mean, what is the gain to be able to restart a frozen TCP session wit=
h
a 1sec latency instead of 10s if it was blocked more than 60 seconds ?
