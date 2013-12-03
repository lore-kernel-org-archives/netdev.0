From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 21:55:26 +0200
Message-ID: <CAJZOPZJ9WM1H9zKNzT5MvQ2UH7RxkTLk2Rhzsk9vdvKz6d2uAw@mail.gmail.com>
References: <529DF340.70602@mellanox.com>
	<1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:35211 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753754Ab3LCTz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 14:55:27 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so21699998pbc.20
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 11:55:26 -0800 (PST)
In-Reply-To: <1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 5:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-12-03 at 17:05 +0200, Or Gerlitz wrote:
>> I've been chasing lately a performance issues which come into play when
>> combining veth and vxlan over fast Ethernet NIC.
>>
>> I came across it while working to enable TCP stateless offloads for
>> vxlan encapsulated traffic in the mlx4 driver, but I can clearly see the
>> issue without any HWoffloads involved, so it would be easier to discuss
>> like that (no offloads involved).
>>
>> The setup involves a stacked {veth --> bridge --> vlxan --> IP stack -->
>> NIC} or {veth --> ovs+vxlan -->  IP stack --> NIC} chain.
>>
>> Basically, in my testbed which uses iperf over 40Gbs Mellanox NICs,
>> vxlan traffic goes up to 5-7Gbs for single session and up to 14Gbs for
>> multiple sessions, as long as veth isn't involved. Once veth is used I
>> can't get to > 7-8Gbs, no matter how many sessions are used. For the
>> time being, I manually took into account the tunneling overhead and
>> reduced the veth pair MTU by 50 bytes.
>>
>> Looking on the kernel TCP counters in a {veth --> bridge --> vxlan -->
>> NIC} configuration, on the client side I see lots of hits for the
>> following TCP counters (the numbers are just single sample, I look on
>> the output of iterative sampling every seconds, e.g using "watch -d -n 1
>> netstat -st"):
>>
>> 67092 segments retransmited
>>
>> 31461 times recovered from packet loss due to SACK data
>> Detected reordering 1045142 times using SACK
>> 436215 fast retransmits
>> 59966 forward retransmits
>>
>> Also on the passive side I see hits for the "Quick ack mode was
>> activated N times" counter, see below full snapshot of the counters from
>> both sides.
>>
>> Without using veth, e.g when running in a {vxlan -> NIC} or {bridge -->
>> vxlan --> NIC},I see hits only for the "recovered from packet loss due
>> to SACK data" counter and fastretransmits counter,  but not for the
>> forward retransmits or "Detected reordering N timesusing SACK". Also,
>> the quick ack mode counter isn't active on the passive side.
>>
>> I tested net.git (3.13-rc2+), 3.12.2 and 3.11.9, I see the same problems
>> on all. At this point I don't really see a past point to go and apply
>> bisection. So I hope this counter report can help to shed some light on
>> the nature of the problem and possible solution, so ideas welcome!!
>>
>> without vxlan, these are the Gbs results for 1/2/4 streams over 3.12.2,
>> the results
>> for the net.git are pretty much the same.
>>
>> 18/32/38  NIC
>> 17/30/35  bridge --> NIC
>> 14/23/35  veth --> bridge --> NIC
>>
>> with vxlan, these are the Gbs results for 1/2/4 streams
>>
>> 6/12/14  vxlan --> IP --> NIC
>> 5/10/14  bridge --> vxlan --> IP --> NIC
>> 6/7/7    veth --> bridge --> vxlan --> IP --> NIC
>>
>> Also, the 3.12.2 number do get any better also when adding a ported
>> version of 82d8189826d5 "veth: extend features to support tunneling" on
>> top of 3.12.2
>>
>> See @ the end the sequence of commands I use for the environment
>>
>> Or.
>>
>>
>> --> TCP counters from active side
>>
>> # netstat -ts
>> IcmpMsg:
>>      InType0: 2
>>      InType8: 1
>>      OutType0: 1
>>      OutType3: 4
>>      OutType8: 2
>> Tcp:
>>      189 active connections openings
>>      4 passive connection openings
>>      0 failed connection attempts
>>      0 connection resets received
>>      4 connections established
>>      22403193 segments received
>>      541234150 segments send out
>>      14248 segments retransmited
>>      0 bad segments received.
>>      5 resets sent
>> UdpLite:
>> TcpExt:
>>      2 invalid SYN cookies received
>>      178 TCP sockets finished time wait in fast timer
>>      10 delayed acks sent
>>      Quick ack mode was activated 1 times
>>      4 packets directly queued to recvmsg prequeue.
>>      3728 packets directly received from backlog
>>      2 packets directly received from prequeue
>>      2524 packets header predicted
>>      4 packets header predicted and directly queued to user
>>      19793310 acknowledgments not containing data received
>>      1216966 predicted acknowledgments
>>      2130 times recovered from packet loss due to SACK data
>>      Detected reordering 73 times using FACK
>>      Detected reordering 11424 times using SACK
>>      55 congestion windows partially recovered using Hoe heuristic
>>      TCPDSACKUndo: 457
>>      2 congestion windows recovered after partial ack
>>      11498 fast retransmits
>>      2748 forward retransmits
>>      2 other TCP timeouts
>>      TCPLossProbes: 4
>>      3 DSACKs sent for old packets
>>      TCPSackShifted: 1037782
>>      TCPSackMerged: 332827
>>      TCPSackShiftFallback: 598055
>>      TCPRcvCoalesce: 380
>>      TCPOFOQueue: 463
>>      TCPSpuriousRtxHostQueues: 192
>> IpExt:
>>      InNoRoutes: 1
>>      InMcastPkts: 191
>>      OutMcastPkts: 28
>>      InBcastPkts: 25
>>      InOctets: 1789360097
>>      OutOctets: 893757758988
>>      InMcastOctets: 8152
>>      OutMcastOctets: 3044
>>      InBcastOctets: 4259
>>      InNoECTPkts: 30117553
>>
>>
>>
>> --> TCP counters from passiveside
>>
>> netstat -ts
>> IcmpMsg:
>>      InType0: 1
>>      InType8: 2
>>      OutType0: 2
>>      OutType3: 5
>>      OutType8: 1
>> Tcp:
>>      75 active connections openings
>>      140 passive connection openings
>>      0 failed connection attempts
>>      0 connection resets received
>>      4 connections established
>>      146888643 segments received
>>      27430160 segments send out
>>      0 segments retransmited
>>      0 bad segments received.
>>      6 resets sent
>> UdpLite:
>> TcpExt:
>>      3 invalid SYN cookies received
>>      72 TCP sockets finished time wait in fast timer
>>      10 delayed acks sent
>>      3 delayed acks further delayed because of locked socket
>>      Quick ack mode was activated 13548 times
>>      4 packets directly queued to recvmsg prequeue.
>>      2 packets directly received from prequeue
>>      139384763 packets header predicted
>>      2 packets header predicted and directly queued to user
>>      671 acknowledgments not containing data received
>>      938 predicted acknowledgments
>>      TCPLossProbes: 2
>>      TCPLossProbeRecovery: 1
>>      14 DSACKs sent for old packets
>>      TCPBacklogDrop: 848
>
> Thats bad : Dropping packets on receiver.
>
> Check also "ifconfig -a" to see if rxdrop is increasing as well.
>
>>      TCPRcvCoalesce: 118368414
>
> lack of GRO : receiver seems to not be able to receive as fast as you want.
>
>>      TCPOFOQueue: 3167879
>
> So many packets are received out of order (because of losses)

I see that there's no GRO also for the non-veth tests which involve
vxlan, and over there the receiving side is capable to consume the
packets, do you have rough explaination why adding veth to the chain
is such game changer which makes things to start falling out?



>
>> IpExt:
>>      InNoRoutes: 1
>>      InMcastPkts: 184
>>      OutMcastPkts: 26
>>      InBcastPkts: 26
>>      InOctets: 1007364296775
>>      OutOctets: 2433872888
>>      InMcastOctets: 6202
>>      OutMcastOctets: 2888
>>      InBcastOctets: 4597
>>      InNoECTPkts: 702313233
>>
>>
>> client side (node 144)
>> ----------------------
>>
>> ip link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dev ethN
>> ifconfig vxlan42 192.168.42.144/24 up
>>
>> brctl addbr br-vx
>> ip link set br-vx up
>>
>> ifconfig br-vx 192.168.52.144/24 up
>> brctl addif br-vx vxlan42
>>
>> ip link add type veth
>> brctl addif br-vx veth1
>> ifconfig veth0 192.168.62.144/24 up
>> ip link set veth1 up
>>
>> ifconfig veth0 mtu 1450
>> ifconfig veth1 mtu 1450
>>
>>
>> server side (node 147)
>> ----------------------
>>
>> ip link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dev ethN
>> ifconfig vxlan42 192.168.42.147/24 up
>>
>> brctl addbr br-vx
>> ip link set br-vx up
>>
>> ifconfig br-vx 192.168.52.147/24 up
>> brctl addif br-vx vxlan42
>>
>>
>> ip link add type veth
>> brctl addif br-vx veth1
>> ifconfig veth0 192.168.62.147/24 up
>> ip link set veth1 up
>>
>> ifconfig veth0 mtu 1450
>> ifconfig veth1 mtu 1450
>>
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
