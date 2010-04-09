From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Strange packet drops with heavy firewalling
Date: Fri, 09 Apr 2010 14:33:31 +0200
Message-ID: <m3vdc0ztyc.fsf@ursa.amorsen.dk>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	<1270813662.2623.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:33235 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab0DIMdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Apr 2010 08:33:38 -0400
In-Reply-To: <1270813662.2623.85.camel@edumazet-laptop> (Eric Dumazet's
	message of "Fri, 09 Apr 2010 13:47:42 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> might be micro bursts, check 'ethtool -g eth0' RX parameters (increase
> RX ring from 200 to 511 if you want more buffers ?)

I tried that already actually. (I didn't expect it to cause traffic
interruption, but it did. Oh well.)

It didn't make a difference, at least not one I could detect from the
number of packet drops and the CPU utilization.

> cat /proc/net/softnet_stat

000002d9 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
42bc8143 00000000 0000024c 00000000 00000000 00000000 00000000 00000000 00000000
0000031b 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1c5a35e9 00000000 000005f7 00000000 00000000 00000000 00000000 00000000 00000000

I am not quite sure how to interpret that...

> cat /proc/interrupts

  79:       1240 4050590849       1253       1263   PCI-MSI-edge      eth0
  80:         12          9         14 3613521843   PCI-MSI-edge      eth1

> (check eth0 IRQS are delivered to one cpu)

Yes CPU1 handles eth0 and CPU3 handles eth1.

> grep . /proc/sys/net/ipv4/netfilter/ip_conntrack_*

nf_conntrack_acct:1
nf_conntrack_buckets:8192
nf_conntrack_checksum:1
nf_conntrack_count:49311
nf_conntrack_events:1
nf_conntrack_events_retry_timeout:15
nf_conntrack_expect_max:2048
nf_conntrack_generic_timeout:600
nf_conntrack_icmp_timeout:30
nf_conntrack_log_invalid:1
nf_conntrack_max:1048576
nf_conntrack_tcp_be_liberal:0
nf_conntrack_tcp_loose:1
nf_conntrack_tcp_max_retrans:3
nf_conntrack_tcp_timeout_close:10
nf_conntrack_tcp_timeout_close_wait:60
nf_conntrack_tcp_timeout_established:432000
nf_conntrack_tcp_timeout_fin_wait:120
nf_conntrack_tcp_timeout_last_ack:30
nf_conntrack_tcp_timeout_max_retrans:300
nf_conntrack_tcp_timeout_syn_recv:60
nf_conntrack_tcp_timeout_syn_sent:120
nf_conntrack_tcp_timeout_time_wait:120
nf_conntrack_tcp_timeout_unacknowledged:300
nf_conntrack_udp_timeout:30
nf_conntrack_udp_timeout_stream:180

> (might need to increase ip_conntrack_buckets)

You got me there. I had forgotten nf_conntrack.hashsize=1048576
and nf_conntrack.expect_hashsize=32768 on the kernel command line. It
was on the hot standby firewall, but not on the primary one. I will do a
failover to the hot standby sometime during the weekend.

It still isn't possible to change without a reboot, is it?

> ethtool -c eth0
> (might change coalesce params to reduce number of irqs)

Coalesce parameters for eth0:
Adaptive RX: off  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 20
rx-frames: 5
rx-usecs-irq: 0
rx-frames-irq: 5

tx-usecs: 72
tx-frames: 53
tx-usecs-irq: 0
tx-frames-irq: 5

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

I played quite a lot with the parameters but it did not seem to make any
difference. I didn't try adaptive though, but the load is fairly static
so it didn't seem appropriate.

> ethtool -g eth0

Ring parameters for eth0:
Pre-set maximums:
RX:		511
RX Mini:	0
RX Jumbo:	0
TX:		511
Current hardware settings:
RX:		200
RX Mini:	0
RX Jumbo:	0
TX:		511

Right now RX is 200, but when it was 511 it didn't seem to make a
difference.

Thank you very much for the help! I will report back whether it was the
hash buckets.


/Benny
