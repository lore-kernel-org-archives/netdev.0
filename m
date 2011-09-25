From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Sun, 25 Sep 2011 21:24:44 +0200
Message-ID: <1316978684.2531.7.camel@edumazet-laptop>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <1316825745.1865.24.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Jim Gettys <jg@freedesktop.org>,
	Dave Taht <dave.taht@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57120 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab1IYTYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 15:24:54 -0400
Received: by wyg34 with SMTP id 34so5328146wyg.19
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2011 12:24:53 -0700 (PDT)
In-Reply-To: <1316825745.1865.24.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 septembre 2011 =C3=A0 20:55 -0400, Jamal Hadi Salim a =C3=
=A9crit :

> So  small confusion for me, Eric:
> Is theres some middlebox clearing the ECT but allowing the TCP header
> ECN flags to be set during SYN echange?  If yes, why would not allowi=
ng
> quickack help?

As you may know, the SYN and SYNACK packets dont have ECT bits, as
mandated by RFC. So there is no way to detect a TOS blackhole in TCP
session init.

On following trace taken from my laptop connecting to a ssh server
(192.168.2.1), you can see that my laptop sends ECT messages, but never
receive ECT bits. Each sides believe the session is ECN enabled, as the
SYN and SYNACK messages have the appropriate ECN markers.

So we have somewhere a box that mask the TOS bits. This is a well known
effect on some networks, unfortunately.

The 'linux funny extension' is wrong in this case, since I have no
retransmits, no losses, yet my laptop is in quickack mode (it sends an
ACK for every incoming data packet), because you assumed receiving a
packet with no ECT bits means this packet was a retransmit.



21:14:44.665405 IP (tos 0x0, ttl 64, id 63689, offset 0, flags [DF], pr=
oto TCP (6), length 60)
    192.168.2.32.39529 > 192.168.2.1.22: Flags [SEW], cksum 0xf2ea (inc=
orrect -> 0x2151), seq 1589453915, win 14600, options [mss 1460,sackOK,=
TS val 56466 ecr 0,nop,wscale 7], length 0

21:14:44.773643 IP (tos 0x0, ttl 46, id 0, offset 0, flags [DF], proto =
TCP (6), length 60)
    192.168.2.1.22 > 192.168.2.32.39529: Flags [S.E], cksum 0xbce1 (cor=
rect), seq 1422101564, ack 1589453916, win 14480, options [mss 1452,sac=
kOK,TS val 176781781 ecr 56466,nop,wscale 7], length 0

21:14:44.773691 IP (tos 0x0, ttl 64, id 63690, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.2.32.39529 > 192.168.2.1.22: Flags [.], cksum 0xf2e2 (incor=
rect -> 0x23f8), ack 1, win 115, options [nop,nop,TS val 56477 ecr 1767=
81781], length 0

21:14:44.888804 IP (tos 0x0, ttl 46, id 62941, offset 0, flags [DF], pr=
oto TCP (6), length 91)
    192.168.2.1.22 > 192.168.2.32.39529: Flags [P.], cksum 0x64d1 (corr=
ect), seq 1:40, ack 1, win 114, options [nop,nop,TS val 176781792 ecr 5=
6477], length 39

21:14:44.888842 IP (tos 0x0, ttl 64, id 63691, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.2.32.39529 > 192.168.2.1.22: Flags [.], cksum 0xf2e2 (incor=
rect -> 0x23ba), ack 40, win 115, options [nop,nop,TS val 56489 ecr 176=
781792], length 0

21:14:44.888929 IP (tos 0x2,ECT(0), ttl 64, id 63692, offset 0, flags [=
DF], proto TCP (6), length 91)
    192.168.2.32.39529 > 192.168.2.1.22: Flags [P.], cksum 0x649d (corr=
ect), seq 1:40, ack 40, win 115, options [nop,nop,TS val 56489 ecr 1767=
81792], length 39

21:14:44.993714 IP (tos 0x0, ttl 46, id 62942, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.2.1.22 > 192.168.2.32.39529: Flags [.], cksum 0x2389 (corre=
ct), ack 40, win 114, options [nop,nop,TS val 176781803 ecr 56489], len=
gth 0

21:14:44.993758 IP (tos 0x2,ECT(0), ttl 64, id 63693, offset 0, flags [=
DF], proto TCP (6), length 1196)
    192.168.2.32.39529 > 192.168.2.1.22: Flags [P.], cksum 0x1e1b (corr=
ect), seq 40:1184, ack 40, win 115, options [nop,nop,TS val 56499 ecr 1=
76781803], length 1144

21:14:44.994447 IP (tos 0x0, ttl 46, id 62943, offset 0, flags [DF], pr=
oto TCP (6), length 900)
    192.168.2.1.22 > 192.168.2.32.39529: Flags [P.], cksum 0xd3d4 (corr=
ect), seq 40:888, ack 40, win 114, options [nop,nop,TS val 176781803 ec=
r 56489], length 848

21:14:44.994463 IP (tos 0x0, ttl 64, id 63694, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.2.32.39529 > 192.168.2.1.22: Flags [.], cksum 0xf2e2 (incor=
rect -> 0x1ba9), ack 888, win 128, options [nop,nop,TS val 56499 ecr 17=
6781803], length 0

21:14:45.546332 IP (tos 0x0, ttl 64, id 63695, offset 0, flags [DF], pr=
oto TCP (6), length 1196)
    192.168.2.32.39529 > 192.168.2.1.22: Flags [P.], cksum 0x1a8c (corr=
ect), seq 40:1184, ack 888, win 128, options [nop,nop,TS val 56549 ecr =
176781803], length 1144
