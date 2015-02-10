From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next 6/6] ipv6: Allow for partial checksums on
 non-ufo packets
Date: Tue, 10 Feb 2015 15:07:04 +0100
Message-ID: <20150210140704.GA3372@kria>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
 <1422718818-21093-7-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:49130 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753223AbbBJOHN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2015 09:07:13 -0500
Content-Disposition: inline
In-Reply-To: <1422718818-21093-7-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-01-31, 10:40:18 -0500, Vladislav Yasevich wrote:
> Currntly, if we are not doing UFO on the packet, all UDP
> packets will start with CHECKSUM_NONE and thus perform full
> checksum computations in software even if device support
> IPv6 checksum offloading.
> 
> Let's start start with CHECKSUM_PARTIAL if the device
> supports it and we are sending only a single packet at
> or below mtu size.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---

This patch causes ICMPv6 checksumming issues for me.

On my tg3 device and on a qemu VM with e1000 emulation, outgoing pings
have a bad checksum.  Router solicitations also have a bad checksum,
so autoconf fails.  When I revert this patch, or when I disable
tx-checksumming with ethtool, everything looks okay again.

On tg3, replies to ping seem always good.

On e1000, replies to ping work (more or less).  Sometimes the checksum
is bad, sometimes it's good.


% ping6 fec0::3456
PING fec0::3456(fec0::3456) 56 data bytes
64 bytes from fec0::3456: icmp_seq=1 ttl=64 time=0.433 ms
64 bytes from fec0::3456: icmp_seq=2 ttl=64 time=0.457 ms
64 bytes from fec0::3456: icmp_seq=10 ttl=64 time=0.448 ms
64 bytes from fec0::3456: icmp_seq=11 ttl=64 time=0.451 ms
64 bytes from fec0::3456: icmp_seq=18 ttl=64 time=0.485 ms
64 bytes from fec0::3456: icmp_seq=20 ttl=64 time=0.476 ms
64 bytes from fec0::3456: icmp_seq=22 ttl=64 time=0.448 ms
64 bytes from fec0::3456: icmp_seq=26 ttl=64 time=0.438 ms
64 bytes from fec0::3456: icmp_seq=27 ttl=64 time=0.413 ms
64 bytes from fec0::3456: icmp_seq=28 ttl=64 time=0.452 ms
64 bytes from fec0::3456: icmp_seq=29 ttl=64 time=0.440 ms
64 bytes from fec0::3456: icmp_seq=30 ttl=64 time=0.485 ms
64 bytes from fec0::3456: icmp_seq=32 ttl=64 time=0.473 ms
64 bytes from fec0::3456: icmp_seq=33 ttl=64 time=0.472 ms
64 bytes from fec0::3456: icmp_seq=34 ttl=64 time=0.395 ms
64 bytes from fec0::3456: icmp_seq=35 ttl=64 time=0.456 ms
64 bytes from fec0::3456: icmp_seq=36 ttl=64 time=0.409 ms
^C
--- fec0::3456 ping statistics ---
36 packets transmitted, 17 received, 52% packet loss, time 34998ms
rtt min/avg/max/mdev = 0.395/0.448/0.485/0.037 ms


I've seen a few strange source addresses, but I don't know if it's
related.

% ping6 fec0::3456
PING fec0::3456(fec0::3456) 56 data bytes
64 bytes from fec0::ff:ff00:0:3456: icmp_seq=1 ttl=64 time=0.423 ms   <---
64 bytes from fec0::3456: icmp_seq=4 ttl=64 time=0.396 ms
64 bytes from fec0::3456: icmp_seq=5 ttl=64 time=0.400 ms


This could be a driver issue, or just exposing another problem
somewhere else, I don't know.

Any idea?


Thanks

-- 
Sabrina
