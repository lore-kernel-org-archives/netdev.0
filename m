From: Pierre Emeriaud <petrus.lt@gmail.com>
Subject: PROBLEM: Linux 3.9 more-specific ipv6 route ignored until next-hop is
 in neighbor cache
Date: Wed, 3 Jul 2013 00:04:33 +0200
Message-ID: <CA+PSOpyxWf2s_JscuBYfOAW9hVkSqqC1JwdRDQ4WtZrkneQf6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:46195 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797Ab3GBWEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 18:04:34 -0400
Received: by mail-ob0-f180.google.com with SMTP id eh20so6110981obb.25
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 15:04:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Linux 3.9 more-specific ipv6 route ignored until next-hop is in neighbor cache.

When adding a route to 2000::/3 with a next-hop that is not in the
neighbor cache, the route is not preferred over the default.

Tested against 3.9.1-debian and 3.9.8-arch. Not able to reproduce with 3.8.0
$ cat /proc/version
Linux version 3.9.8-1-ARCH (tobias@testing-i686) (gcc version 4.8.1
(GCC) ) #1 SMP PREEMPT Fri Jun 28 07:43:59 CEST 2013

How to reproduce:

# ip -6 route
2001:db8:ee8c:180::/64 dev eth0  proto kernel  metric 256  expires 86176sec
fe80::/64 dev eth0  proto kernel  metric 256
fe80::/64 dev eth1  proto kernel  metric 256
default via fe80::f6ca:e5ff:fe43:d114 dev eth0  proto ra  metric 1024
expires 1576sec

# ip -6 addr add 2001:db8::1/64 dev eth1
# ip -6 route add 2000::/3 via 2001:db8::2/64

$ ip -6 route show
2001:db8::/64 dev eth1  proto kernel  metric 256
2001:db8:ee8c:180::/64 dev eth0  proto kernel  metric 256  expires 86360sec
2000::/3 via 2001:db8::2 dev eth1  metric 1024
fe80::/64 dev eth0  proto kernel  metric 256
fe80::/64 dev eth1  proto kernel  metric 256
default via fe80::f6ca:e5ff:fe43:d114 dev eth0  proto ra  metric 1024
expires 1760sec


$ ip -6 route get 2a00:1450:4007:806::1001
2a00:1450:4007:806::1001 from :: via fe80::f6ca:e5ff:fe43:d114 dev
eth0  src 2001:db8:ee8c:180:21b:77ff:fe30:9e36  metric 0

# ip -6 neig add 2001:db8::2 dev eth1 lladdr 86:74:4c:45:18:f2 nud permanent

# ip -6 route get 2a00:1450:4007:806::1001
2a00:1450:4007:806::1001 from :: via 2001:db8::2 dev eth1  src
2001:db8::1  metric 0


Workaround:
Next hop has to be in the neighbor cache. Static or dynamic entry.
Sending a ping6 to the next-hop works fine.


Regards,
Pierre.
