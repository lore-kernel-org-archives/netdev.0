From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Tue, 16 Sep 2014 06:59:19 -0700
Message-ID: <1410875959.7106.200.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140915184517.6c5474e5@redhat.com>
	 <20140916152221.41811287@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:57176 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966AbaIPN7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 09:59:21 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq14so8965931pab.39
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 06:59:21 -0700 (PDT)
In-Reply-To: <20140916152221.41811287@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-16 at 15:22 +0200, Jesper Dangaard Brouer wrote:

> Zooming in on high-prio ping only, and comparing TSO vs GSO:
>  http://people.netfilter.org/hawk/qdisc/measure01/compare_TSO_vs_GSO__ping_hiprio.png
>  http://people.netfilter.org/hawk/qdisc/measure01/compare_TSO_vs_GSO__ping_cdf.png
> 
> - It clearly shows that GSO have lower/better ping values that TSO,
>   e.g. smaller HoL blocking

If you use a single TX queue on the NIC (no prio aware), this makes no
sense....

GSO is exactly sending the same packet train on the wire, it only uses
more cpu on the host to segment packets. While doing the segmentation,
no packet can be sent to the NIC, so this should be _adding_ some
latencies, unless the TSO engine on your NIC is brain damaged.

The high prio ping packet cannot be inserted in the middle of a GSO
train.

ping is not very good to measure very small rtt actually.

With the TCP usec rtt work I did lately, you'll get more precise results
from a TCP_RR flow, as Tom and I explained.

Proof :

lpaa23:~# ping -n -c 10 10.246.7.152
PING 10.246.7.152 (10.246.7.152) 56(84) bytes of data.
64 bytes from 10.246.7.152: icmp_req=1 ttl=64 time=0.196 ms
64 bytes from 10.246.7.152: icmp_req=2 ttl=64 time=0.161 ms
64 bytes from 10.246.7.152: icmp_req=3 ttl=64 time=0.183 ms
64 bytes from 10.246.7.152: icmp_req=4 ttl=64 time=0.070 ms
64 bytes from 10.246.7.152: icmp_req=5 ttl=64 time=0.195 ms
64 bytes from 10.246.7.152: icmp_req=6 ttl=64 time=0.163 ms
64 bytes from 10.246.7.152: icmp_req=7 ttl=64 time=0.169 ms
64 bytes from 10.246.7.152: icmp_req=8 ttl=64 time=0.183 ms
64 bytes from 10.246.7.152: icmp_req=9 ttl=64 time=0.150 ms
64 bytes from 10.246.7.152: icmp_req=10 ttl=64 time=0.208 ms

--- 10.246.7.152 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 8999ms
rtt min/avg/max/mdev = 0.070/0.167/0.208/0.040 ms

While with TCP_RR, you'll get the ~20 usec rtt we really have on this
link :


netperf -H 10.246.7.152 -t TCP_RR -l 100 &
ss -temoi dst 10.246.7.152

...
ESTAB       0      1
10.246.7.151:59804
10.246.7.152:45623    timer:(on,201ms,0) ino:14821 sk:ffff881fcb48a740
<->
	 skmem:(r0,rb357120,t2304,tb46080,f1792,w2304,o0,bl0) ts sack cubic
wscale:6,6 rto:201 rtt:0.019/0.003 ato:40 mss:1448 cwnd:10 send
6096.8Mbps pacing_rate 11656.9Mbps unacked:1 rcv_rtt:572 rcv_space:29470

And if you take a look at tcpdump, you'll see that 20 usec is the
reality.

lpaa23:~# tcpdump -p -n -s 128 -i eth0 -c 10 host 10.246.7.152
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 128 bytes
06:53:59.278218 IP 10.246.7.152.43699 > 10.246.7.151.49454: P 1088080991:1088080992(1) ack 811259668 win 453 <nop,nop,timestamp 1151215 1152060>
06:53:59.278260 IP 10.246.7.151.49454 > 10.246.7.152.43699: P 1:2(1) ack 1 win 457 <nop,nop,timestamp 1152060 1151215>
06:53:59.278268 IP 10.246.7.152.43699 > 10.246.7.151.49454: P 1:2(1) ack 2 win 453 <nop,nop,timestamp 1151215 1152060>
06:53:59.278220 IP 10.246.7.151.49454 > 10.246.7.152.43699: P 2:3(1) ack 2 win 457 <nop,nop,timestamp 1152060 1151215>
06:53:59.278232 IP 10.246.7.152.43699 > 10.246.7.151.49454: P 2:3(1) ack 3 win 453 <nop,nop,timestamp 1151215 1152060>
06:53:59.278240 IP 10.246.7.151.49454 > 10.246.7.152.43699: P 3:4(1) ack 3 win 457 <nop,nop,timestamp 1152060 1151215>
06:53:59.278252 IP 10.246.7.152.43699 > 10.246.7.151.49454: P 3:4(1) ack 4 win 453 <nop,nop,timestamp 1151215 1152060>
06:53:59.278259 IP 10.246.7.151.49454 > 10.246.7.152.43699: P 4:5(1) ack 4 win 457 <nop,nop,timestamp 1152060 1151215>
06:53:59.278282 IP 10.246.7.152.43699 > 10.246.7.151.49454: P 4:5(1) ack 5 win 453 <nop,nop,timestamp 1151215 1152060>
06:53:59.278289 IP 10.246.7.151.49454 > 10.246.7.152.43699: P 5:6(1) ack 5 win 457 <nop,nop,timestamp 1152060 1151215>

ping is slower :

lpaa23:~# tcpdump -p -n -s 128 -i eth0 -c 10 host 10.246.7.152
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 128 bytes
06:57:29.666168 IP 10.246.7.151 > 10.246.7.152: ICMP echo request, id 11062, seq 4, length 64
06:57:29.666355 IP 10.246.7.152 > 10.246.7.151: ICMP echo reply, id 11062, seq 4, length 64
06:57:30.666220 IP 10.246.7.151 > 10.246.7.152: ICMP echo request, id 11062, seq 5, length 64
06:57:30.666408 IP 10.246.7.152 > 10.246.7.151: ICMP echo reply, id 11062, seq 5, length 64
06:57:31.666147 IP 10.246.7.151 > 10.246.7.152: ICMP echo request, id 11062, seq 6, length 64
06:57:31.666333 IP 10.246.7.152 > 10.246.7.151: ICMP echo reply, id 11062, seq 6, length 64
06:57:32.666164 IP 10.246.7.151 > 10.246.7.152: ICMP echo request, id 11062, seq 7, length 64
06:57:32.666359 IP 10.246.7.152 > 10.246.7.151: ICMP echo reply, id 11062, seq 7, length 64

Really, do not rely too much on ping.
If you do, we cant really trust your results.
