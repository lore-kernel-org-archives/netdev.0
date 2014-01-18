From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: IGMP joins come from the wrong SA/interface
Date: Sat, 18 Jan 2014 20:11:07 +0100
Message-ID: <20140118191107.GA21979@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:54510 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaARTLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 14:11:11 -0500
Received: from pannekake.samfundet.no ([2001:67c:29f4::50] ident=unknown)
	by cassarossa.samfundet.no with esmtps (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1W4bIR-0002VJ-Lm
	for netdev@vger.kernel.org; Sat, 18 Jan 2014 20:11:08 +0100
Received: from sesse by pannekake.samfundet.no with local (Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1W4bIR-000836-AR
	for netdev@vger.kernel.org; Sat, 18 Jan 2014 20:11:07 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a relatively complicated setup at home with multiple VLANs, some
bridging etc., but what's most important is that multicast and unicast =
go
different directions (since my ISP doesn't support multicast, I have a =
PIM
tunnel terminated at a Cisco box). I'm running kernel 3.12.5.

My routing table looks like this:

  sesse@morgental:~$ sudo ip route
  default via 178.82.50.1 dev br0=20
  10.1.0.0/24 dev eth0.2  proto kernel  scope link  src 10.1.0.1=20
  10.3.0.0/24 dev eth0.3  proto kernel  scope link  src 10.3.0.1=20
  178.82.50.0/23 dev br0  proto kernel  scope link  src 178.82.50.98=20
  multicast 224.0.0.0/4 dev eth0.2  scope link  src 10.1.0.1=20
  239.0.0.0/8 dev eth0.11  scope link=20

Note especially the multicast line, which I've added as follows:

  sudo ip route add multicast 224.0.0.0/4 dev eth0.2 src 10.1.0.1=20

Still, when trying to join a multicast group, the source address
is wrong:

  20:03:11.161288 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], prot=
o IGMP (2), length 40, options (RA))
      178.82.50.98 > 224.0.0.22: igmp v3 report, 1 group record(s) [gad=
dr 239.1.1.20 to_ex { }]
  20:03:11.161312 ethertype IPv4, IP (tos 0xc0, ttl 1, id 0, offset 0, =
flags [DF], proto IGMP (2), length 40, options (RA))
      178.82.50.98 > 224.0.0.22: igmp v3 report, 1 group record(s) [gad=
dr 239.1.1.20 to_ex { }]

It doesn't even come on eth0.2. I don't actually understand which
interface it comes up on (it doesn't show up on eth0.2, br0, or
any of the component devices of br0), but it shows up on the
=E2=80=9Cany=E2=80=9D device in tcpdump, and on eth0, which I don't hav=
e a single
IPv4 address on.

It doesn't matter if I drop the =E2=80=9Cmulticast=E2=80=9D token from =
the ip route line.
Behavior is still exactly the same; it comes out of eth0 instead of eth=
0.2,
with the wrong source address.

This used to work, once upon a time, but I fear it broke during a
kernel upgrade. It's hard for me to say exactly when; probably
a few months ago. Any ideas?

/* Steinar */
--=20
Homepage: http://www.sesse.net/
