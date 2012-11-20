From: Jan =?UTF-8?Q?Dvo=C5=99=C3=A1k?= <mordae@anilinux.org>
Subject: PROBLEM: losing addresses if reusing interface names too fast
Date: Tue, 20 Nov 2012 12:38:16 +0100
Message-ID: <20121120123816.d576e0d2b0ac22f4809fec94@anilinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [80.79.23.148] ([80.79.23.148]:35241 "EHLO anilinux.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752196Ab2KTLi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2012 06:38:57 -0500
Received: from [88.103.20.104] (helo=gesher)
	by anilinux.org with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.77)
	(envelope-from <mordae@anilinux.org>)
	id 1Tam9n-0006jl-3D
	for netdev@vger.kernel.org; Tue, 20 Nov 2012 12:38:23 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(re-sent with proper subject)

Summary: If I reuse interface names too fast, I end up losing newly
         configured addresses on the new interface.

Detailed Description:

I have noticed a surprising behavior when removing virtual interfaces.
For example, removing a bridge with configured IP addresses and then
quickly creating another interface with identical name will cause the
addresses to be removed from the new interface a second or so later.

How To Reproduce:

brctl addbr foobar
ip addr add 10.20.30.40/24 dev foobar
ip addr show dev foobar

# 40: foobar: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
#     link/ether 12:12:f5:1b:c6:8e brd ff:ff:ff:ff:ff:ff
#     inet 10.20.30.40/24 scope global foobar

sleep 1

ip link set down dev foobar
brctl delbr foobar
ip link add name foobar link em1 type vlan id 42
ip addr add 10.20.30.40/24 dev foobar
ip addr show dev foobar

# 41: foobar@em1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
#     link/ether 00:21:cc:63:ec:3c brd ff:ff:ff:ff:ff:ff
#     inet 10.20.30.40/24 scope global foobar

sleep 3

ip addr show dev foobar
# 41: foobar@em1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
#     link/ether 00:21:cc:63:ec:3c brd ff:ff:ff:ff:ff:ff

ip link del foobar type vlan


Other Relevant Observations:

If you monitor udev during course of this script, you will get
following sequence, spaces where sleeps were:

KERNEL[457506.286789] add      /devices/virtual/net/foobar (net)

KERNEL[457507.298630] remove   /devices/virtual/net/foobar (net)
KERNEL[457507.309597] add      /devices/virtual/net/foobar (net)

KERNEL[457510.324433] remove   /devices/virtual/net/foobar (net)


This means that I can't event wait for the bridge to get completely
removed, kernel tells me it's gone as soon as I delete it.


Could you please advise a workaround or confirm this as a bug?

Best regards,
	Jan Dvorak
