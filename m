From: Bernhard Schmidt <berni@birkenwald.de>
Subject: [IPv6] "sendmsg: invalid argument" to multicast group after some
	time
Date: Sun, 31 Aug 2008 20:20:34 +0200
Message-ID: <20080831182034.GA12035@pest>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:53628 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755057AbYHaS3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 14:29:18 -0400
Received: from pest (pest.oms16.birkenwald.de [IPv6:2001:a60:f001:1:218:f3ff:fe66:c777])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(Client did not present a certificate)
	by mailout.mucip.net (Postfix) with ESMTPSA id 8F7B23414C
	for <netdev@vger.kernel.org>; Sun, 31 Aug 2008 20:20:35 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

this is about the same box as the message from Remi an hour ago, but
most probably not related.

I'm running a Teredo (RFC4830) relay on a i386 Xen domU with kernel
2.6.26 vanilla with the integrated pv_ops feature. This relay function
is implemented in a userspace daemon called Miredo which provides a tun
interface to the OS where native IPv6 for 2001::/32 is routed into. The
traffic is then handled in the userspace daemon and emitted encapsulated
in IPv4/UDP. Apart from a few scalability problems which seem to be
related to the neighbor or route cache size it works fine. The machine
is doing around 2kpps of IPv6 traffic (which means 4kpps of IPv4+IPv6).

As there are a couple of similar relays globally anycasted I'm supposed
to withdraw the route from BGP if the daemon or the machine fails. To do
this I'm running ripngd from the Quagga routing suite, which announces
the Teredo prefix to my core routers using RIPng (RFC2080). On a kernel
level RIPng is basically periodic UDP to a link-local multicast address 
[ff02::9]:521.

Every few hours this announcement fails (no announcements reach the core
routers anymore, which kill the routing entry after a timeout). ripngd
debugging claims that it could not send the announcement due to 
"Invalid argument". There are no outgoing packets in tcpdump anymore.

I even get the same error when doing a multicast ping6:
miredo:~# ping6 -I eth0 ff02::9
PING ff02::9(ff02::9) from fe80::216:3eff:feb9:29f5 eth0: 56 data bytes
ping: sendmsg: Invalid argument                                        
64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.030 ms
64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.018 ms (DUP!)

(fe80::216:3eff:feb9:29f5 is the box itself, it's the only one that ever
answers ... duplicate however)

ping6 to other multicast addresses, even in the same scope works fine

miredo:~# ping6 -I eth0 ff02::2                       
PING ff02::2(ff02::2) from fe80::216:3eff:feb9:29f5 eth0: 56 data bytes
64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.057 ms
64 bytes from fe80::20c:86ff:fe9a:3819: icmp_seq=1 ttl=64 time=0.466 ms (DUP!)
64 bytes from fe80::20c:86ff:fe9a:2819: icmp_seq=1 ttl=64 time=0.476 ms (DUP!)
64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=2 ttl=64 time=0.043 ms       

Now the freaky part ... the multicast ping to ff02::9 (and thus the
RIPng announcements) start to work again when I restart the miredo
daemon. This is sort of unexpected because miredo does not deal with
this address (or multicast) at all.

miredo:~# /etc/init.d/miredo stop                                           
Stopping Teredo IPv6 tunneling daemon: miredo.                              
miredo:~# /etc/init.d/miredo start
Starting Teredo IPv6 tunneling daemon: miredo.
miredo:~# ping6 -c 2 -I eth0 ff02::9
PING ff02::9(ff02::9) from fe80::216:3eff:feb9:29f5 eth0: 56 data bytes
64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.044 ms
64 bytes from fe80::2c0:9fff:fe4b:8ccf: icmp_seq=1 ttl=64 time=0.441 ms (DUP!)
64 bytes from fe80::20c:86ff:fe9a:3819: icmp_seq=1 ttl=64 time=0.458 ms (DUP!)
64 bytes from fe80::20c:86ff:fe9a:2819: icmp_seq=1 ttl=64 time=0.466 ms (DUP!)

Someone else running a miredo relay on Linux has reported the same
problem, only using ospf6d instead of ripngd:

2008/08/31 17:25:54 OSPF6: sendmsg failed: ifindex: 2: Invalid argument (22)

OSPFv3 is link-local multicast as well (own protocol on ff02::5), 
restarting the miredo daemon fixed the problem for him as well.

Regards,
Bernhard
