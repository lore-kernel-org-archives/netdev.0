From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 17:05:36 +0200
Message-ID: <529DF340.70602@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:41126 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753616Ab3LCPFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 10:05:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been chasing lately a performance issues which come into play when 
combining veth and vxlan over fast Ethernet NIC.

I came across it while working to enable TCP stateless offloads for 
vxlan encapsulated traffic in the mlx4 driver, but I can clearly see the 
issue without any HWoffloads involved, so it would be easier to discuss 
like that (no offloads involved).

The setup involves a stacked {veth --> bridge --> vlxan --> IP stack --> 
NIC} or {veth --> ovs+vxlan -->  IP stack --> NIC} chain.

Basically, in my testbed which uses iperf over 40Gbs Mellanox NICs, 
vxlan traffic goes up to 5-7Gbs for single session and up to 14Gbs for 
multiple sessions, as long as veth isn't involved. Once veth is used I 
can't get to > 7-8Gbs, no matter how many sessions are used. For the 
time being, I manually took into account the tunneling overhead and 
reduced the veth pair MTU by 50 bytes.

Looking on the kernel TCP counters in a {veth --> bridge --> vxlan --> 
NIC} configuration, on the client side I see lots of hits for the 
following TCP counters (the numbers are just single sample, I look on 
the output of iterative sampling every seconds, e.g using "watch -d -n 1 
netstat -st"):

67092 segments retransmited

31461 times recovered from packet loss due to SACK data
Detected reordering 1045142 times using SACK
436215 fast retransmits
59966 forward retransmits

Also on the passive side I see hits for the "Quick ack mode was 
activated N times" counter, see below full snapshot of the counters from 
both sides.

Without using veth, e.g when running in a {vxlan -> NIC} or {bridge --> 
vxlan --> NIC},I see hits only for the "recovered from packet loss due 
to SACK data" counter and fastretransmits counter,  but not for the 
forward retransmits or "Detected reordering N timesusing SACK". Also, 
the quick ack mode counter isn't active on the passive side.

I tested net.git (3.13-rc2+), 3.12.2 and 3.11.9, I see the same problems 
on all. At this point I don't really see a past point to go and apply 
bisection. So I hope this counter report can help to shed some light on 
the nature of the problem and possible solution, so ideas welcome!!

without vxlan, these are the Gbs results for 1/2/4 streams over 3.12.2, 
the results
for the net.git are pretty much the same.

18/32/38  NIC
17/30/35  bridge --> NIC
14/23/35  veth --> bridge --> NIC

with vxlan, these are the Gbs results for 1/2/4 streams

6/12/14  vxlan --> IP --> NIC
5/10/14  bridge --> vxlan --> IP --> NIC
6/7/7    veth --> bridge --> vxlan --> IP --> NIC

Also, the 3.12.2 number do get any better also when adding a ported 
version of 82d8189826d5 "veth: extend features to support tunneling" on 
top of 3.12.2

See @ the end the sequence of commands I use for the environment

Or.


--> TCP counters from active side

# netstat -ts
IcmpMsg:
     InType0: 2
     InType8: 1
     OutType0: 1
     OutType3: 4
     OutType8: 2
Tcp:
     189 active connections openings
     4 passive connection openings
     0 failed connection attempts
     0 connection resets received
     4 connections established
     22403193 segments received
     541234150 segments send out
     14248 segments retransmited
     0 bad segments received.
     5 resets sent
UdpLite:
TcpExt:
     2 invalid SYN cookies received
     178 TCP sockets finished time wait in fast timer
     10 delayed acks sent
     Quick ack mode was activated 1 times
     4 packets directly queued to recvmsg prequeue.
     3728 packets directly received from backlog
     2 packets directly received from prequeue
     2524 packets header predicted
     4 packets header predicted and directly queued to user
     19793310 acknowledgments not containing data received
     1216966 predicted acknowledgments
     2130 times recovered from packet loss due to SACK data
     Detected reordering 73 times using FACK
     Detected reordering 11424 times using SACK
     55 congestion windows partially recovered using Hoe heuristic
     TCPDSACKUndo: 457
     2 congestion windows recovered after partial ack
     11498 fast retransmits
     2748 forward retransmits
     2 other TCP timeouts
     TCPLossProbes: 4
     3 DSACKs sent for old packets
     TCPSackShifted: 1037782
     TCPSackMerged: 332827
     TCPSackShiftFallback: 598055
     TCPRcvCoalesce: 380
     TCPOFOQueue: 463
     TCPSpuriousRtxHostQueues: 192
IpExt:
     InNoRoutes: 1
     InMcastPkts: 191
     OutMcastPkts: 28
     InBcastPkts: 25
     InOctets: 1789360097
     OutOctets: 893757758988
     InMcastOctets: 8152
     OutMcastOctets: 3044
     InBcastOctets: 4259
     InNoECTPkts: 30117553



--> TCP counters from passiveside

netstat -ts
IcmpMsg:
     InType0: 1
     InType8: 2
     OutType0: 2
     OutType3: 5
     OutType8: 1
Tcp:
     75 active connections openings
     140 passive connection openings
     0 failed connection attempts
     0 connection resets received
     4 connections established
     146888643 segments received
     27430160 segments send out
     0 segments retransmited
     0 bad segments received.
     6 resets sent
UdpLite:
TcpExt:
     3 invalid SYN cookies received
     72 TCP sockets finished time wait in fast timer
     10 delayed acks sent
     3 delayed acks further delayed because of locked socket
     Quick ack mode was activated 13548 times
     4 packets directly queued to recvmsg prequeue.
     2 packets directly received from prequeue
     139384763 packets header predicted
     2 packets header predicted and directly queued to user
     671 acknowledgments not containing data received
     938 predicted acknowledgments
     TCPLossProbes: 2
     TCPLossProbeRecovery: 1
     14 DSACKs sent for old packets
     TCPBacklogDrop: 848
     TCPRcvCoalesce: 118368414
     TCPOFOQueue: 3167879
IpExt:
     InNoRoutes: 1
     InMcastPkts: 184
     OutMcastPkts: 26
     InBcastPkts: 26
     InOctets: 1007364296775
     OutOctets: 2433872888
     InMcastOctets: 6202
     OutMcastOctets: 2888
     InBcastOctets: 4597
     InNoECTPkts: 702313233


client side (node 144)
----------------------

ip link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dev ethN
ifconfig vxlan42 192.168.42.144/24 up

brctl addbr br-vx
ip link set br-vx up

ifconfig br-vx 192.168.52.144/24 up
brctl addif br-vx vxlan42

ip link add type veth
brctl addif br-vx veth1
ifconfig veth0 192.168.62.144/24 up
ip link set veth1 up

ifconfig veth0 mtu 1450
ifconfig veth1 mtu 1450


server side (node 147)
----------------------

ip link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dev ethN
ifconfig vxlan42 192.168.42.147/24 up

brctl addbr br-vx
ip link set br-vx up

ifconfig br-vx 192.168.52.147/24 up
brctl addif br-vx vxlan42


ip link add type veth
brctl addif br-vx veth1
ifconfig veth0 192.168.62.147/24 up
ip link set veth1 up

ifconfig veth0 mtu 1450
ifconfig veth1 mtu 1450
