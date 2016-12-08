From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next 0/4] udp: receive path optimizations
Date: Thu, 8 Dec 2016 21:48:19 +0100
Message-ID: <20161208214819.30138d12@redhat.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53730 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752445AbcLHUsY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 15:48:24 -0500
In-Reply-To: <1481218739-27089-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Dec 2016 09:38:55 -0800
Eric Dumazet <edumazet@google.com> wrote:

> This patch series provides about 100 % performance increase under flood. 

Could you please explain a bit more about what kind of testing you are
doing that can show 100% performance improvement?

I've tested this patchset and my tests show *huge* speeds ups, but
reaping the performance benefit depend heavily on setup and enabling
the right UDP socket settings, and most importantly where the
performance bottleneck is: ksoftirqd(producer) or udp_sink(consumer).

Basic setup: Unload all netfilter, and enable ip_early_demux.
 sysctl net/ipv4/ip_early_demux=1

Test generator pktgen UDP packets single flow, 50Gbit/s mlx5 NICs.
 - Vary packet size between 64 and 1514.


Packet-size: 64
$ sudo taskset -c 4 ./udp_sink --port 9 --count $((10**7))
                                ns/pkt  pps             cycles/pkt
recvMmsg/32  	run: 0 10000000	537.70	1859756.90	2155
recvmsg   	run: 0 10000000	510.84	1957541.83	2047
read      	run: 0 10000000	583.40	1714077.14	2338
recvfrom  	run: 0 10000000	600.09	1666411.49	2405

The ksoftirq thread "cost" more than udp_sink, which is idle, and UDP
queue does not get full-enough. Thus, patchset does not have any
effect.


Try to increase pktgen packet size, as this increase the copy cost of
udp_sink.  Thus, a queue can now form, and udp_sink CPU almost have no
idle cycles.  The "read" and "readfrom" did experience some idle
cycles.

Packet-size: 1514
$ sudo taskset -c 4 ./udp_sink --port 9 --count $((10**7))
                                ns/pkt  pps             cycles/pkt
recvMmsg/32  	run: 0 10000000	435.88	2294204.11	1747
recvmsg   	run: 0 10000000	458.06	2183100.64	1835
read      	run: 0 10000000	520.34	1921826.18	2085
recvfrom  	run: 0 10000000	515.48	1939935.27	2066


Next trick connected UDP:

Use connected UDP socket (combined with ip_early_demux), removes the
FIB_lookup from the ksoftirq, and cause tipping point to be better.

Packet-size: 64
$ sudo taskset -c 4 ./udp_sink --port 9 --count $((10**7)) --connect
                                ns/pkt  pps             cycles/pkt
recvMmsg/32  	run: 0 10000000	391.18	2556361.62	1567
recvmsg   	run: 0 10000000	422.95	2364349.69	1695
read      	run: 0 10000000	425.29	2351338.10	1704
recvfrom  	run: 0 10000000	476.74	2097577.57	1910

Change/increase packet size:

Packet-size: 1514
$ sudo taskset -c 4 ./udp_sink --port 9 --count $((10**7)) --connect
                                ns/pkt  pps             cycles/pkt
recvMmsg/32  	run: 0 10000000	457.56	2185481.94	1833
recvmsg   	run: 0 10000000	479.42	2085837.49	1921
read      	run: 0 10000000	398.05	2512233.13	1595
recvfrom  	run: 0 10000000	391.07	2557096.95	1567

A bit strange, changing the packet size, flipped what is the fastest
syscall.

It is also interesting to see that ksoftirq limit is:

Result from "nstat" while using recvmsg, show that ksoftirq is
handling 2.6 Mpps, and consumer/udp_sink is bottleneck with 2Mpps.

[skylake ~]$ nstat > /dev/null && sleep 1  && nstat
#kernel
IpInReceives                    2667577            0.0
IpInDelivers                    2667577            0.0
UdpInDatagrams                  2083580            0.0
UdpInErrors                     583995             0.0
UdpRcvbufErrors                 583995             0.0
IpExtInOctets                   4001340000         0.0
IpExtInNoECTPkts                2667559            0.0

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
