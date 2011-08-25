From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 07:28:54 +0200
Message-ID: <1314250134.6797.24.camel@edumazet-laptop>
References: <1314226834.6797.5.camel@edumazet-laptop>
	 <1314229310-8074-1-git-send-email-hagen@jauu.net>
	 <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55375 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab1HYF3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 01:29:01 -0400
Received: by wwf5 with SMTP id 5so1963908wwf.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 22:29:00 -0700 (PDT)
In-Reply-To: <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 ao=C3=BBt 2011 =C3=A0 18:50 -0700, Yuchung Cheng a =C3=A9=
crit :
> On Wed, Aug 24, 2011 at 4:41 PM, Hagen Paul Pfeifer <hagen@jauu.net> =
wrote:
> > Check if calculated RTO is less then TCP_RTO_MIN. If this is true w=
e
> > adjust the value to TCP_RTO_MIN.
> >
> but tp->rttvar is already lower-bounded via tcp_rto_min()?
>=20
> static inline void tcp_set_rto(struct sock *sk)
> {
> ...
>=20
>   /* NOTE: clamping at TCP_RTO_MIN is not required, current algo
>    * guarantees that rto is higher.
>    */
>   tcp_bound_rto(sk);
> }

Yes, and furthermore, we also limit ICMP rate, so in in my tests, I
reach in a few rounds icsk_rto > 1sec

07:16:13.010633 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 3833540215:38335402=
63(48) ack 2593537670 win 305
07:16:13.221111 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:13.661151 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:14.541153 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:16.301152 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
<from this point, icsk_rto=3D1.76sec >
07:16:18.061158 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:19.821158 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:21.581018 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:23.341156 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:25.101151 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:26.861155 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:28.621158 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:30.381152 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20
07:16:32.141157 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 win =
305=20

Real question is : do we really want to process ~1000 timer interrupts
per tcp session, ~2000 skb alloc/free/build/handling, possibly ~1000 AR=
P
requests, only to make tcp revover in ~1sec when connectivity returns
back. This just doesnt scale.

On a server handling ~1.000.000 (long living) sessions, using
application side keepalives (say one message sent every minute on each
session), a temporary connectivity disruption _could_ makes it enter a
critical zone, burning cpu and memory.

It seems TCP-LCD (RFC6069) depends very much on ICMP being rate limited=
=2E

I'll have to check what happens on multiple sessions : We might have
cpus fighting on a single inetpeer and throtle, thus allowing backoff t=
o
increase after all.=20
