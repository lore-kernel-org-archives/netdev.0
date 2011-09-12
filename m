From: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>
Subject: Incorrect routing to lo in spite of correct record in routing table
Date: Mon, 12 Sep 2011 23:14:37 +0600
Message-ID: <CAEmTpZGKnU4z4J43XGa-1YZ0WW6rnKdpTRJDFEeUTfVmZQH84g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36319 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab1ILROj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 13:14:39 -0400
Received: by bkbzt4 with SMTP id zt4so2802642bkb.19
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 10:14:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppose this (note netowrk masks):

[mmarkk@mmarkk-devel ~]# uname -a
Linux mmarkk-devel 2.6.32-71.el6.x86_64 #1 SMP Wed Sep 1 01:33:01 EDT
2010 x86_64 x86_64 x86_64 GNU/Linux

[mmarkk@mmarkk-devel ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    inet 127.0.0.1/32 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    inet 10.80.20.21/16 brd 10.80.255.255 scope global eth0
3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
    inet 127.0.0.2/32 scope host dummy0

[mmarkk@mmarkk-devel ~]# ip route show
10.80.0.0/16 dev eth0  proto kernel  scope link  src 10.80.20.21
unreachable 127.0.0.0/8 <---------------------- has been added by hand
default via 10.80.90.40 dev eth0

[mmarkk@mmarkk-devel ~]# ip route show table local
broadcast 10.80.0.0 dev eth0  proto kernel  scope link  src 10.80.20.21
local 10.80.20.21 dev eth0  proto kernel  scope host  src 10.80.20.21
local 127.0.0.2 dev dummy0  proto kernel  scope host  src 127.0.0.2
broadcast 10.80.255.255 dev eth0  proto kernel  scope link  src 10.80.20.21
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1

[mmarkk@mmarkk-devel ~]# ip route flush cache

[mmarkk@mmarkk-devel ~]# ip route get 127.0.0.3
RTNETLINK answers: Network is unreachable <------------ good, that is OK

[mmarkk@mmarkk-devel ~]# ip route get 127.0.0.1
local 127.0.0.1 dev lo  src 127.0.0.1  <--------- Good, that's OK too
    cache <local>  mtu 16436 advmss 16396 hoplimit 64

[mmarkk@mmarkk-devel ~]# ip route get 127.0.0.2
local 127.0.0.2 dev lo  src 127.0.0.2 <------------ HAY! this is not I
want. Why device is "lo" (instead of dummy0) ?!
    cache <local>  mtu 16436 advmss 16396 hoplimit 64

=========================
The problem is that I want to do DNAT to localhost. I know, why DNAT
to 127.0.0.1 (to interface "lo") does not work. I decide to do that
using interface dummy0. It works as expected if I choose any address
not in 127.0.0.0/8.

RFC 3330 said:
-------------
A datagram sent by a higher level protocol to an  address anywhere
within this block should loop back inside the host. This is ordinarily
implemented using only 127.0.0.1/32 for loopback, but no addresses
within this block should ever appear on any network anywhere
-------------
So, my question: Why the kernel routes 127.0.0.2 to lo (instead of dummy0) ?

Well, If kernel is so smart to route any 127.0.0.0/8 to "lo", why it
routes 127.0.0.3 to default gateway if I remove "unreachable
127.0.0.0/8" ?!

I think there is some bug in kernel. What are you thinking about?

-- 
Segmentation fault
