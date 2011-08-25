From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 09:28:42 +0200
Message-ID: <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>
References: <1314226834.6797.5.camel@edumazet-laptop>
 <1314229310-8074-1-git-send-email-hagen@jauu.net>
 <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>
 <1314250134.6797.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Hannemann Arnd <arnd@arndnet.de>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:53644 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750989Ab1HYH2p convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 03:28:45 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LQH001HO3FW2Z30@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 25 Aug 2011 09:28:44 +0200 (CEST)
Received: from [192.168.4.12] ([unknown] [77.109.115.129])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LQH00F0E3FV4L10@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 25 Aug 2011 09:28:44 +0200 (CEST)
In-reply-to: <1314250134.6797.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Am 25.08.2011 um 07:28 schrieb Eric Dumazet:

> Le mercredi 24 ao=FBt 2011 =E0 18:50 -0700, Yuchung Cheng a =E9crit :
>> On Wed, Aug 24, 2011 at 4:41 PM, Hagen Paul Pfeifer <hagen@jauu.net>=
 wrote:
>>> Check if calculated RTO is less then TCP_RTO_MIN. If this is true w=
e
>>> adjust the value to TCP_RTO_MIN.
>>>=20
>> but tp->rttvar is already lower-bounded via tcp_rto_min()?
>>=20
>> static inline void tcp_set_rto(struct sock *sk)
>> {
>> ...
>>=20
>>  /* NOTE: clamping at TCP_RTO_MIN is not required, current algo
>>   * guarantees that rto is higher.
>>   */
>>  tcp_bound_rto(sk);
>> }
>=20
> Yes, and furthermore, we also limit ICMP rate, so in in my tests, I
> reach in a few rounds icsk_rto > 1sec
>=20
> 07:16:13.010633 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 3833540215:383354=
0263(48) ack 2593537670 win 305
> 07:16:13.221111 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:13.661151 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:14.541153 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:16.301152 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> <from this point, icsk_rto=3D1.76sec >
> 07:16:18.061158 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:19.821158 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:21.581018 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:23.341156 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:25.101151 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:26.861155 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:28.621158 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:30.381152 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
> 07:16:32.141157 IP 10.2.1.2.59352 > 10.2.1.1.ssh: P 0:48(48) ack 1 wi=
n 305=20
>=20
> Real question is : do we really want to process ~1000 timer interrupt=
s
> per tcp session, ~2000 skb alloc/free/build/handling, possibly ~1000 =
ARP
> requests, only to make tcp revover in ~1sec when connectivity returns
> back. This just doesnt scale.

maybe a stupid question, but 1000?. With an minRTO of 200ms and a maxim=
um
probing time of 120s, we 600 retransmits in a worst-case-senario
(assumed that we get for every rot retransmission an icmp). No?

>=20
> On a server handling ~1.000.000 (long living) sessions, using
> application side keepalives (say one message sent every minute on eac=
h
> session), a temporary connectivity disruption _could_ makes it enter =
a
> critical zone, burning cpu and memory.
>=20
> It seems TCP-LCD (RFC6069) depends very much on ICMP being rate limit=
ed.

This is right. We assume that a server/router sends only icmps when the=
y
have free cycles.

>=20
> I'll have to check what happens on multiple sessions : We might have
> cpus fighting on a single inetpeer and throtle, thus allowing backoff=
 to
> increase after all.=20
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//
