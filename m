From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: IPSec freeze
Date: Sun, 15 Jul 2007 08:29:27 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13230225@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:42077 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbXGOGiQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 02:38:16 -0400
Received: from exch.facton.local (exch [192.168.200.5])
	by alpha.facton.com (8.13.8/8.13.8/FACTON) with ESMTP id l6F6TRuN004008
	for <netdev@vger.kernel.org>; Sun, 15 Jul 2007 08:29:27 +0200
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Today a new site joined our Linux IPSec VPN, now all the other routers
(all 2.6.22) freeze hard reproducible.
No oops, no sysreq, only hard reset rewakes them.

The only difference of the new site compared to the others: ADSL, thus a
MTU of 1492, the others have 1500.
Disabling IPSec und doing normal operations between the routers is fine,
PMTU is honored correctly.
If I set the MTU of the other routers to 1492 I can avoid the IPSec
crash.

Some kind of strange need-to-frag-ICMP that causes such things?
Any ideas how to debug this?

Thanks!
Daniel

Here a tcpdump of a router (1.1.1.1, obfuscated) just before it died:

07:58:23.588064 IP (tos 0x0, ttl  64, id 8192, offset 0, flags [DF],
proto: ESP (50), length: 1496) 1.1.1.1 > 2.2.2.2:
ESP(spi=0xae81babb,seq=0x15), length 1476
07:58:23.590414 IP (tos 0x0, ttl  48, id 22785, offset 0, flags [DF],
proto: ESP (50), length: 152) 2.2.2.2 > 1.1.1.1:
ESP(spi=0x593f3550,seq=0xf), length 132
07:58:23.592928 IP (tos 0x0, ttl  48, id 22785, offset 0, flags [DF],
proto: ESP (50), length: 104) 2.2.2.2 > 1.1.1.1:
ESP(spi=0x593f3550,seq=0x10), length 84
07:58:23.593246 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto:
ESP (50), length: 1496) 1.1.1.1 > 2.2.2.2: ESP(spi=0xae81babb,seq=0x16),
length 1476
07:58:23.596486 IP (tos 0x0, ttl  48, id 22785, offset 0, flags [DF],
proto: ESP (50), length: 152) 2.2.2.2 > 1.1.1.1:
ESP(spi=0x593f3550,seq=0x11), length 132
07:58:23.596806 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto:
ESP (50), length: 1496) 1.1.1.1 > 2.2.2.2: ESP(spi=0xae81babb,seq=0x17),
length 1476
07:58:23.596859 IP (tos 0x0, ttl  64, id 10655, offset 0, flags [DF],
proto: ESP (50), length: 200) 1.1.1.1 > 2.2.2.2:
ESP(spi=0xae81babb,seq=0x18), length 180
07:58:23.726550 IP (tos 0x0, ttl  50, id 8192, offset 0, flags [none],
proto: ICMP (1), length: 56) 67.38.70.235 > 1.1.1.1: ICMP 2.2.2.2
unreachable - need to frag (mtu 1492), length 36
        IP (tos 0x0, ttl  45, id 8192, offset 0, flags [DF], proto: ESP
(50), length: 1496) 1.1.1.1 > 2.2.2.2: [|ESP]
07:58:23.731648 IP (tos 0x0, ttl  50, id 0, offset 0, flags [none],
proto: ICMP (1), length: 56) 67.38.70.235 > 1.1.1.1: ICMP 2.2.2.2
unreachable - need to frag (mtu 1492), length 36
        IP (tos 0x0, ttl  45, id 0, offset 0, flags [DF], proto: ESP
(50), length: 1496) 1.1.1.1 > 2.2.2.2: [|ESP]
07:58:23.734776 IP (tos 0x0, ttl  50, id 0, offset 0, flags [none],
proto: ICMP (1), length: 56) 67.38.70.235 > 1.1.1.1: ICMP 2.2.2.2
unreachable - need to frag (mtu 1492), length 36
        IP (tos 0x0, ttl  45, id 0, offset 0, flags [DF], proto: ESP
(50), length: 1496) 1.1.1.1 > 2.2.2.2: [|ESP]
07:58:23.740504 IP (tos 0x0, ttl  48, id 22785, offset 0, flags [DF],
proto: ESP (50), length: 104) 2.2.2.2 > 1.1.1.1:
ESP(spi=0x593f3550,seq=0x12), length 84
07:58:23.743108 IP (tos 0x0, ttl  48, id 22785, offset 0, flags [DF],
proto: ESP (50), length: 104) 2.2.2.2 > 1.1.1.1:
ESP(spi=0x593f3550,seq=0x13), length 84
07:58:23.754123 IP (tos 0x0, ttl  48, id 22785, offset 0, flags [DF],
proto: ESP (50), length: 104) 2.2.2.2 > 1.1.1.1:
ESP(spi=0x593f3550,seq=0x14), length 84

Here a log of another death from inside the tunnel (last packet is again
the time of crash):
The Tunnel MTU of 1430 is correct for an outer MTU of 1500, but the
additional -8 doesn't take place?!?

05:17:18.563448 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1460
05:17:18.563468 IP 192.168.200.254 > 192.168.200.1: ICMP 192.168.203.1
unreachable - need to frag (mtu 1430), length 556
05:17:18.563471 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1460
05:17:18.563479 IP 192.168.200.254 > 192.168.200.1: ICMP 192.168.203.1
unreachable - need to frag (mtu 1430), length 556
05:17:18.563481 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1460
05:17:18.563490 IP 192.168.200.254 > 192.168.200.1: ICMP 192.168.203.1
unreachable - need to frag (mtu 1430), length 556
05:17:18.563492 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1460
05:17:18.563499 IP 192.168.200.254 > 192.168.200.1: ICMP 192.168.203.1
unreachable - need to frag (mtu 1430), length 556
05:17:18.563616 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1390
05:17:18.882785 IP 192.168.203.1.3084 > 192.168.200.1.80: tcp 0
05:17:18.882921 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1390
05:17:18.883097 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1390
05:17:19.042207 IP 192.168.203.1.3084 > 192.168.200.1.80: tcp 0
