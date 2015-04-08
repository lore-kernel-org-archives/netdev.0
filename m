From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Wed, 8 Apr 2015 20:16:23 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1504081938320.14413@nerf40.vanv.qr>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr> <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr> <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr> <5525634A.10207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares41.inai.de ([46.4.122.207]:55627 "EHLO ares41.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752899AbbDHSQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 14:16:24 -0400
In-Reply-To: <5525634A.10207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2015-04-08 19:20, Rick Jones wrote:
> On 04/08/2015 10:09 AM, Jan Engelhardt wrote:
>> The problem won't manifest with netperf even if run for extended
>> period (60 seconds). netperf is probably too smart, exploiting some
>> form of parallelism.
>
> Heh - I rather doubt netperf is all that smart.[...]
> I don't
> know specifically how xinetd-chargen behaves but if it is like the chargen of
> old, I assume that means it is sitting there writing one byte at a time to the
> socket, and perhaps has TCP_NODELAY set.

Interesting thought.

Indeed, stracing reveals that xinetd-chargen is issuing 74-byte write
syscalls. They do however get merged to a certain extent at the TCP
level. tcpdump shows groups of three:

IP 23.19 > 40.1.59411: Flags [P.], ..., length 74
IP 23.19 > 40.1.59411: Flags [.], ..., length 1370
IP 23.19 > 40.1.59411: Flags [P.], ..., length 36
(repeat)

However, presence of small packets is not the issue. As an
alternative to chargen, socat can be used. socat issues 8192-byte
write syscalls, and tcpdump shows just large writes. Now
that I look at it, too large:

IP 23.23:19 > 40.1:59412: Flags [.], seq 25975:28715, ack 1, win 227, options [nop,nop,TS val 44808653 ecr 44808653], length 2740
IP 40.1:59412 > 23.23:19: Flags [.], ack 24605, win 627, options [nop,nop,TS val 44808653 ecr 44808653], length 0
IP 23.23:19 > 40.1:59412: Flags [.], seq 28715:31455, ack 1, win 227, options [nop,nop,TS val 44808653 ecr 44808653], length 2740
IP 40.1:59412 > 23.23:19: Flags [.], ack 25975, win 649, options [nop,nop,TS val 44808653 ecr 44808653], length 0
IP 23.23:19 > 40.1:59412: Flags [.], seq 25975:27345, ack 1, win 227, options [nop,nop,TS val 44808854 ecr 44808653], length 1370
IP 40.1:59412 > 23.23:19: Flags [.], ack 27345, win 672, options [nop,nop,TS val 44808854 ecr 44808854], length 0

2740 bytes is larger than the link MTU. That only works if all
the drivers do their segmentation properly, which does not seem
to happen here.


>If you want to emulate that with netperf, then something like:
>
> netperf -H <receiver> -t TCP_STREAM -- -m 1 -D

One more thing to be aware of is that iptraf counts all the
headers, which netperf likely is not doing.

 -m   1: iptraf  57 MBit/s, netperf   0.69*10^6
 -m  10: iptraf  63 MBit/s, netperf   6.76*10^6
 -m 100: iptraf 114 MBit/s, netperf  75.74*10^6
<no -m>: iptraf~580 MBit/s, netperf 542.00*10^6

However, with chargen/socat, both iptraf and pv agree, around 1
MBit/s [108-120Kbyte/s], so small writes really don't seem to be the
issue, but maybe the (aforeposted) over-mtu-size packets.
