From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: network stream fairness
Date: Sun, 29 Nov 2015 03:41:20 +0100
Message-ID: <20151129024120.GA6522@lnxniklass.se.axis.com>
References: <5640BEAC.10404@axis.com>
 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>
 <5640C15E.805@axis.com>
 <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <564F3D3D.7050004@axis.com>
 <1448043414.22599.287.camel@edumazet-glaptop2.roam.corp.google.com>
 <5655ADC7.3040606@axis.com>
 <1448459372.22599.324.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:49377 "EHLO
	bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbbK2ClZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2015 21:41:25 -0500
Content-Disposition: inline
In-Reply-To: <1448459372.22599.324.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings fellow hackers :)

I have managed to reproduce my streaming unfairness with the intel e1000 driver.

I believe that commit
605ad7f184b6 ("tcp: refine TSO autosizing")
changed the behavior for 100 Mbps NIC:s with TSO enabled.

I have 2 e1000 cards connected in the same computer, with a network cable
connecting the NIC:s directly.

Please note that I used a intel e1000 card/driver,
since the e1000e driver turns off TSO when setting the speed to 100.
I also added netif_set_gso_max_size(netdev, 16384) to the e1000 driver,
but that did not affect the end result.

See iperf results with and without 605ad7f184b6 at the end of this mail.

When talking to Eric I've learned that TCP is not fair by design,
so I guess that one could argue that we previously, by coincidence,
happened to be more fair, and that we now just happen to be not as fair.

If I didn't know that though, my expectations would be that the
Fair Queue packet scheduler would behave just like its name says, fair. :P

Working within normal parameters or not, at least now we know that the patch
actually did cause a change in behavior for 100 Mbps NIC:s with TSO enabled.




My setup script, to not use loopback, etc., looks like this (thx Steve Kehlet):

tc qdisc replace dev eth0 root fq
tc qdisc replace dev eth2 root fq

ethtool -s eth2 speed 100 duplex full autoneg on
ethtool -s eth0 speed 100 duplex full autoneg on

ip addr add 10.50.0.1/24 dev eth2
ip addr add 10.50.1.1/24 dev eth0

iptables -t nat -A POSTROUTING -s 10.50.0.1 -d 10.60.1.1 -j SNAT --to-source 10.60.0.1
iptables -t nat -A PREROUTING -d 10.60.0.1 -j DNAT --to-destination 10.50.0.1
iptables -t nat -A POSTROUTING -s 10.50.1.1 -d 10.60.0.1 -j SNAT --to-source 10.60.1.1
iptables -t nat -A PREROUTING -d 10.60.1.1 -j DNAT --to-destination 10.50.1.1

ip route add 10.60.1.1 dev eth2
arp -i eth2 -s 10.60.1.1 00:11:22:33:44:55 # MAC address of eth0

ip route add 10.60.0.1 dev eth0
arp -i eth0 -s 10.60.0.1 55:44:33:22:11:00 # MAC address of eth2

Running iperf locked to a certain NIC:
iperf3 -B 10.50.0.1 -s
iperf3 -B 10.50.1.1 -c 10.60.0.1 -t 240 -P 2




Vanilla 4.3, sch_fq, e1000 driver, 100 Mbps speed, TSO on:

Connecting to host 10.60.0.1, port 5201
[  4] local 10.50.1.1 port 40698 connected to 10.60.0.1 port 5201
[  6] local 10.50.1.1 port 39755 connected to 10.60.0.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  5.78 MBytes  48.4 Mbits/sec    0   46.7 KBytes       
[  6]   0.00-1.00   sec  5.70 MBytes  47.8 Mbits/sec    0   48.1 KBytes       
[SUM]   0.00-1.00   sec  11.5 MBytes  96.2 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   1.00-2.00   sec  5.53 MBytes  46.4 Mbits/sec    0   49.5 KBytes       
[  6]   1.00-2.00   sec  5.65 MBytes  47.4 Mbits/sec    0   48.1 KBytes       
[SUM]   1.00-2.00   sec  11.2 MBytes  93.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   2.00-3.00   sec  5.65 MBytes  47.4 Mbits/sec    0   49.5 KBytes       
[  6]   2.00-3.00   sec  5.59 MBytes  46.9 Mbits/sec    0   48.1 KBytes       
[SUM]   2.00-3.00   sec  11.2 MBytes  94.3 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   3.00-4.00   sec  4.86 MBytes  40.8 Mbits/sec    0   49.5 KBytes       
[  6]   3.00-4.00   sec  6.44 MBytes  54.0 Mbits/sec    0   66.5 KBytes       
[SUM]   3.00-4.00   sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   4.00-5.00   sec  4.01 MBytes  33.6 Mbits/sec    0   49.5 KBytes       
[  6]   4.00-5.00   sec  7.22 MBytes  60.5 Mbits/sec    0   66.5 KBytes       
[SUM]   4.00-5.00   sec  11.2 MBytes  94.2 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   5.00-6.00   sec  4.31 MBytes  36.2 Mbits/sec    0   49.5 KBytes       
[  6]   5.00-6.00   sec  6.84 MBytes  57.3 Mbits/sec    0   66.5 KBytes       
[SUM]   5.00-6.00   sec  11.1 MBytes  93.5 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   6.00-7.00   sec  4.44 MBytes  37.2 Mbits/sec    0   49.5 KBytes       
[  6]   6.00-7.00   sec  6.91 MBytes  58.0 Mbits/sec    0   66.5 KBytes       
[SUM]   6.00-7.00   sec  11.3 MBytes  95.2 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   7.00-8.00   sec  4.31 MBytes  36.2 Mbits/sec    0   49.5 KBytes       
[  6]   7.00-8.00   sec  6.84 MBytes  57.3 Mbits/sec    0   66.5 KBytes       
[SUM]   7.00-8.00   sec  11.1 MBytes  93.5 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   8.00-9.00   sec  4.50 MBytes  37.7 Mbits/sec    0   49.5 KBytes       
[  6]   8.00-9.00   sec  6.76 MBytes  56.7 Mbits/sec    0   66.5 KBytes       
[SUM]   8.00-9.00   sec  11.3 MBytes  94.4 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   9.00-10.00  sec  4.19 MBytes  35.2 Mbits/sec    0   49.5 KBytes       
[  6]   9.00-10.00  sec  6.99 MBytes  58.6 Mbits/sec    0   66.5 KBytes       
[SUM]   9.00-10.00  sec  11.2 MBytes  93.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]  10.00-11.00  sec  4.25 MBytes  35.7 Mbits/sec    0   49.5 KBytes       
[  6]  10.00-11.00  sec  6.99 MBytes  58.6 Mbits/sec    0   66.5 KBytes       
[SUM]  10.00-11.00  sec  11.2 MBytes  94.3 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]  11.00-12.00  sec  4.19 MBytes  35.2 Mbits/sec    0   49.5 KBytes       
[  6]  11.00-12.00  sec  7.06 MBytes  59.3 Mbits/sec    0   66.5 KBytes       
[SUM]  11.00-12.00  sec  11.3 MBytes  94.4 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]  12.00-13.00  sec  4.50 MBytes  37.7 Mbits/sec    0   49.5 KBytes       
[  6]  12.00-13.00  sec  6.68 MBytes  56.1 Mbits/sec    0   66.5 KBytes       
[SUM]  12.00-13.00  sec  11.2 MBytes  93.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]  13.00-14.00  sec  4.01 MBytes  33.6 Mbits/sec    0   49.5 KBytes       
[  6]  13.00-14.00  sec  7.22 MBytes  60.5 Mbits/sec    0   66.5 KBytes       
[SUM]  13.00-14.00  sec  11.2 MBytes  94.2 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-14.00  sec  64.5 MBytes  38.7 Mbits/sec    0             sender
[  4]   0.00-14.00  sec  64.5 MBytes  38.6 Mbits/sec                  receiver
[  6]   0.00-14.00  sec  92.9 MBytes  55.6 Mbits/sec    0             sender
[  6]   0.00-14.00  sec  92.7 MBytes  55.6 Mbits/sec                  receiver
[SUM]   0.00-14.00  sec   157 MBytes  94.3 Mbits/sec    0             sender
[SUM]   0.00-14.00  sec   157 MBytes  94.2 Mbits/sec                  receiver

iperf Done.




Kernel 4.3, 605ad7f184b6 reverted, sch_fq, e1000 driver, 100 Mbps speed, TSO on:

Connecting to host 10.60.0.1, port 5201
[  4] local 10.50.1.1 port 40949 connected to 10.60.0.1 port 5201
[  6] local 10.50.1.1 port 39238 connected to 10.60.0.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  6.09 MBytes  51.1 Mbits/sec    0    219 KBytes       
[  6]   0.00-1.00   sec  6.05 MBytes  50.8 Mbits/sec    0    219 KBytes       
[SUM]   0.00-1.00   sec  12.1 MBytes   102 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   1.00-2.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]   1.00-2.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]   1.00-2.00   sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   2.00-3.00   sec  5.47 MBytes  45.9 Mbits/sec    0    219 KBytes       
[  6]   2.00-3.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]   2.00-3.00   sec  11.1 MBytes  93.3 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   3.00-4.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]   3.00-4.00   sec  5.47 MBytes  45.9 Mbits/sec    0    219 KBytes       
[SUM]   3.00-4.00   sec  11.1 MBytes  93.3 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   4.00-5.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]   4.00-5.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]   4.00-5.00   sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   5.00-6.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]   5.00-6.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]   5.00-6.00   sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   6.00-7.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]   6.00-7.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]   6.00-7.00   sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   7.00-8.00   sec  5.47 MBytes  45.9 Mbits/sec    0    219 KBytes       
[  6]   7.00-8.00   sec  5.47 MBytes  45.9 Mbits/sec    0    219 KBytes       
[SUM]   7.00-8.00   sec  10.9 MBytes  91.7 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   8.00-9.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]   8.00-9.00   sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]   8.00-9.00   sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]   9.00-10.00  sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]   9.00-10.00  sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]   9.00-10.00  sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]  10.00-11.00  sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]  10.00-11.00  sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]  10.00-11.00  sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]  11.00-12.00  sec  5.47 MBytes  45.9 Mbits/sec    0    219 KBytes       
[  6]  11.00-12.00  sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]  11.00-12.00  sec  11.1 MBytes  93.3 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]  12.00-13.00  sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]  12.00-13.00  sec  5.47 MBytes  45.9 Mbits/sec    0    219 KBytes       
[SUM]  12.00-13.00  sec  11.1 MBytes  93.3 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  4]  13.00-14.00  sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[  6]  13.00-14.00  sec  5.65 MBytes  47.4 Mbits/sec    0    219 KBytes       
[SUM]  13.00-14.00  sec  11.3 MBytes  94.8 Mbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-14.00  sec  79.0 MBytes  47.3 Mbits/sec    0             sender
[  4]   0.00-14.00  sec  78.6 MBytes  47.1 Mbits/sec                  receiver
[  6]   0.00-14.00  sec  79.0 MBytes  47.3 Mbits/sec    0             sender
[  6]   0.00-14.00  sec  78.6 MBytes  47.1 Mbits/sec                  receiver
[SUM]   0.00-14.00  sec   158 MBytes  94.7 Mbits/sec    0             sender
[SUM]   0.00-14.00  sec   157 MBytes  94.2 Mbits/sec                  receiver

iperf Done.
