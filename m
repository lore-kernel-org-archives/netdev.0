From: "Mudric, Dusan (Dusan)" <dmudric@avaya.com>
Subject: IPv6 Address Resolution in Linux 2.6.27
Date: Fri, 8 Feb 2013 20:23:34 +0000
Message-ID: <9142206A0C5BF24CB22755C8EC422E45384AEC24@AZ-US1EXMB03.global.avaya.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p-us1-iereast-outbound.us1.avaya.com ([135.11.29.13]:39879 "EHLO
	p-us1-iereast-outbound.us1.avaya.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946936Ab3BHUdL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 15:33:11 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I experience Address Resolution problem while using Linux 2.6.27.

A and B use global IPv6 addresses.=20
=2E 2009::6:173 - 'A' =A0global address (the capture monitors its port)
=2E 2009::6:172 - 'B' global address

Both A and B are about 8 seconds in the reachable states (STALE / DELAY=
 / PROBE) with full audio, and then ~30 seconds in the INCOMPLETE state=
=2E This happens periodically.

Media behavior when phones talk P2P:
RTP directions   #reference packet  Starting time Time diff [seconds]
172 <- -> 173          940                                13.5         =
         -
172 =A0=A0=A0=A0-> 173        1779                                21.5 =
                8
172 <- -> 173        4134                               63.9           =
   42
172 =A0=A0=A0=A0-> 173         4983                               71.9 =
               8
172 <- -> 173        7361                             114.3            =
 42
172 =A0=A0=A0=A0-> 173         8211                             122.4  =
             8

I added debug info in net\ipv6\ndisc.c ndisc_recv_na() to print src and=
 dst IPs.
I added debug info in neigh_update() to print LL address and a new stat=
e
I enabled NEIGH_PRINTKx and ND_PRINTKx

Observations:
1. 173 discover and lose 172 address in periodic manner - 8 / 42 / 8 / =
42 / .
2. When 173 loses 172 (and when it gets it again) we see ICMPv6 traffic=
: NS from 173 to 172 and NA from 172 to 173
=2E During the time 173 can't reach 172 there are ICMPv6 NS messages fr=
om 173 and NA to 173. 173 ndisc_recv_na() is not called. NAs are silent=
ly discarded somewhere. At the same time, 173 neighbor cache entry does=
 not follow the RFC4861. neigh_update() state changes from INCOMPLETE t=
o STALE do DELAYED after the first timeout. It should stay in INCOMPLET=
E. From DELAYED state it goes to PROBE which is allowed by RFC. It stay=
s in PROBE for 3sec (3 NS retransmissions) and goes to FAILED state. 2s=
ec later is send NS again and goes into DELAYED state.
3. NDP:
a. 172 sends only 3 solicitation request for 173 during the capture per=
iod, while 173 sends solicitation to 172 every second
b. 173 reach 172 only after 172 sends advertisement to 173' LL address =
(not the global one and without the "override" flag)

Q: Is this a known problem? If yes, is there a patch for it?

Regards,=20
Du=B9an Mudri=E6=20

Software Architect
Endpoints & Video Solutions
Avaya Global Communication Systems
Telephone: (613)=A0595-9045
425 Legget Drive, Ottawa, Ontario, K2K 2W2

"I have always believed, and I still believe, that whatever good or bad=
 fortune may come our way, we can always give it meaning and transform =
it into something of value." - Hermann Hesse
