From: Jim Paris <jim@jtan.com>
Subject: IPv6 problems (mtu is less than advmss?)
Date: Mon, 21 Jan 2008 05:52:27 -0500
Message-ID: <20080121105227.GA8306@jim.sh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from NEUROSIS.MIT.EDU ([18.95.3.133]:52154 "EHLO neurosis.jim.sh"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044AbYAULGE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 06:06:04 -0500
Received: from neurosis.jim.sh (localhost [127.0.0.1])
	by neurosis.jim.sh (8.14.1/8.14.1/Debian-9) with ESMTP id m0LAqST3008349
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 05:52:28 -0500
Received: (from jim@localhost)
	by neurosis.jim.sh (8.14.1/8.14.1/Submit) id m0LAqRA2008348
	for netdev@vger.kernel.org; Mon, 21 Jan 2008 05:52:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When the IPv6 default route is first autoconfigured, it seems the
advertised MSS doesn't get set properly.

I have computer A connected to an external interface with IPv4 and
tunneling IPv6 using 6to4.  It runs radvd on an internal interface to
provide connectivity to my LAN.  radvd.conf contains:

  interface brint {
	AdvLinkMTU 1420;    # advertise tiny MTU due to tunnel
	AdvSendAdvert on;
	prefix 0:0:0:1::/64
	{ Base6to4Interface brext; };
  };

Computer B is on the LAN and autoconfigures an IPv6 address.  However,
I have problems with some specific hosts [1].  They're probably doing
broken ICMP/PMTU filtering or something, but I've tracked down some
weirdness in the kernel:

  computerA# /etc/init.d/radvd start

  computerB# ifconfig eth0 down
  computerB# ifconfig eth0 up
  computerB# ip -6 route
  2002:125f:205:1::/64 dev eth0  proto kernel  metric 256  expires 2592312sec mtu 1420 advmss 1360 hoplimit 4294967295
  fe80::/64 dev eth0  metric 256  expires 21334361sec mtu 1420 advmss 1360 hoplimit 4294967295
  ff00::/8 dev eth0  metric 256  expires 21334361sec mtu 1420 advmss 1360 hoplimit 4294967295
  default via fe80::230:48ff:fe8b:5df4 dev eth0  proto kernel  metric 1024  expires 1788sec mtu 1420 advmss 1440 hoplimit 64

At this point, I see the network problems.  Note how the advmss in the
last line is not only larger than all the other lines, it's even
bigger than the MTU.  I won't be able to download [1] until I manually
fix advmss, _or_ just restart radvd on the other computer:

  computerA# /etc/init.d/radvd restart

  computerB# ip -6 route
  2002:125f:205:1::/64 dev eth0  proto kernel  metric 256  expires 2592160sec mtu 1420 advmss 1360 hoplimit 4294967295
  fe80::/64 dev eth0  metric 256  expires 21334355sec mtu 1420 advmss 1360 hoplimit 4294967295
  ff00::/8 dev eth0  metric 256  expires 21334355sec mtu 1420 advmss 1360 hoplimit 4294967295
  default via fe80::230:48ff:fe8b:5df4 dev eth0  proto kernel  metric 1024  expires 1798sec mtu 1420 advmss 1360 hoplimit 64

Now the advmss is better and everything works fine.  It seems that if
it's being created for the first time, the advmss is not correctly set
based on the MTU, but if there's already a route when it gets the RA,
it reconfigures it correctly.

Computer A is 2.6.23.1 and computer B is 2.6.24-rc8, both x86_64.

Any suggestions or other debugging I can do?

-jim

[1] wget -6 http://releases.mozilla.org/pub/mozilla.org/addons/12/all-in-one_gestures-0.18.0-fx.xpi
