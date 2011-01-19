From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Wed, 19 Jan 2011 19:13:59 +0300
Message-ID: <4D370DC7.6000500@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:12120 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959Ab1ASQOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 11:14:04 -0500
In-Reply-To: <28837.1295382268@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2011 11:24 PM, Jay Vosburgh wrote:
> 	I haven't done much testing with this lately, but I suspect this
> behavior hasn't really changed.  Raising the tcp_reordering sysctl value
> can mitigate this somewhat (by making TCP more tolerant of this), but
> that doesn't help non-TCP protocols.
>
> 	Barring evidence to the contrary, I presume that Oleg's system
> delivers out of order at the receiver.  That's not automatically a
> reason to reject it, but this entire proposal is sufficiently complex to
> configure that very explicit documentation will be necessary.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>

Jay,
I have ran some tests with patched 802.3ad bonding for now
Test system configuration:
2 identical servers with 82576, Gigabit ET2 Quad Port Srvr Adptr 
LowProfile, PCI-E (igb), connected to one switch(Cisco 2960) with all 4 
ports, all ports on each host aggregated into single etherchannel using 
802.3ad(w/patch).
kernel version: vanilla 2.6.32(tcp_reordering - default setting)
igb version - 2.3.4, parameters - default
Ran two tests:
1) unidirectional test using iperf
2) Bidirectional test, iperf client is running with 8 threads
One remark:
Decreasing number of slaves will cause higher active slave utilization( 
for example with 2 slaves iperf test will consume almost full bandwidth 
available in both directions(test parameters are the same, test time 
reduced to 150sec):
[SUM]  0.0-150.3 sec  34640 MBytes  1933 Mbits/sec
[SUM]  0.0-150.5 sec  34875 MBytes  1944 Mbits/sec
)
For me (my use case) risk of some bandwidth loss with 4 slaves is 
acceptable, but my suggestion that building aggregate link with more 
than 4 slaves is inadequate. For 2 slaves this solution should work with 
minimum @overhead@ of any kind. TCP reordering and retransmit numbers in 
my opinion are acceptable for most use cases for such bonding mode I can 
imagine.

What is your opinion on my idea with patch?

I will come back with results for VLAN tunneling case, if this is 
necessary (Nicolas, shall I do that test - I think it will show similar 
results for performance?)

Below are test results(sorry for huge amount of text):

Iperf results:
Test 1:
Receiver:
[root@target2 ~]# iperf -f m -c 192.168.111.128 -B 192.168.111.129 -p 
9999 -t 300
------------------------------------------------------------
Client connecting to 192.168.111.128, TCP port 9999
Binding to local address 192.168.111.129
TCP window size: 32.0 MByte (default)
------------------------------------------------------------
[  3] local 192.168.111.129 port 9999 connected with 192.168.111.128 
port 9999
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-300.0 sec  141643 MBytes  3961 Mbits/sec
Sender:
[root@target1 ~]# iperf -f m -s -B 192.168.111.128 -p 9999 -t 300
------------------------------------------------------------
Server listening on TCP port 9999
Binding to local address 192.168.111.128
TCP window size: 32.0 MByte (default)
------------------------------------------------------------
[  4] local 192.168.111.128 port 9999 connected with 192.168.111.129 
port 9999
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-300.1 sec  141643 MBytes  3959 Mbits/sec
^C[root@target1 ~]#

Test 2:
former "sender" side:
[SUM]  0.0-300.2 sec  111541 MBytes  3117 Mbits/sec
[SUM]  0.0-300.4 sec  110515 MBytes  3086 Mbits/sec
former "receiver" side:
[SUM]  0.0-300.1 sec  110515 MBytes  3089 Mbits/sec
[SUM]  0.0-300.3 sec  111541 MBytes  3116 Mbits/sec




Netstat's:

netstat -st (sender, before 1st test)
[root@target1 ~]# netstat -st
IcmpMsg:
     InType3: 5
     InType8: 3
     OutType0: 3
     OutType3: 4
Tcp:
     26 active connections openings
     7 passive connection openings
     5 failed connection attempts
     1 connection resets received
     4 connections established
     349 segments received
     330 segments send out
     7 segments retransmited
     0 bad segments received.
     5 resets sent
UdpLite:
TcpExt:
     10 TCP sockets finished time wait in slow timer
     8 delayed acks sent
     56 packets directly queued to recvmsg prequeue.
     40 packets directly received from backlog
     317 packets directly received from prequeue
     78 packets header predicted
     36 packets header predicted and directly queued to user
     41 acknowledgments not containing data received
     134 predicted acknowledgments
     0 TCP data loss events
     4 other TCP timeouts
     2 connections reset due to unexpected data
     TCPSackShiftFallback: 1
IpExt:
     InMcastPkts: 74
     OutMcastPkts: 62
     InOctets: 76001
     OutOctets: 82234
     InMcastOctets: 13074
     OutMcastOctets: 10428

netstat -st (sender, after 1st test)
[root@target1 ~]netstat -st
IcmpMsg:
     InType3: 5
     InType8: 7
     OutType0: 7
     OutType3: 4
Tcp:
     71 active connections openings
     15 passive connection openings
     5 failed connection attempts
     4 connection resets received
     4 connections established
     16674161 segments received
     16674113 segments send out
     7 segments retransmited
     0 bad segments received.
     5 resets sent
UdpLite:
TcpExt:
     31 TCP sockets finished time wait in slow timer
     13 delayed acks sent
     42 delayed acks further delayed because of locked socket
     Quick ack mode was activated 297 times
     239 packets directly queued to recvmsg prequeue.
     2388220516 packets directly received from backlog
     595165 packets directly received from prequeue
     16954 packets header predicted
     445 packets header predicted and directly queued to user
     129 acknowledgments not containing data received
     322 predicted acknowledgments
     0 TCP data loss events
     4 other TCP timeouts
     297 DSACKs sent for old packets
     2 connections reset due to unexpected data
     TCPSackShiftFallback: 1
IpExt:
     InMcastPkts: 86
     OutMcastPkts: 68
     InBcastPkts: 2
     InOctets: -930738047
     OutOctets: 1321936884
     InMcastOctets: 13434
     OutMcastOctets: 10620
     InBcastOctets: 483

netstat -st (receiver, before 1st test)
[root@target2 ~]# netstat -st
IcmpMsg:
     InType3: 5
     InType8: 3
     OutType0: 3
     OutType3: 4
Tcp:
     23 active connections openings
     6 passive connection openings
     3 failed connection attempts
     1 connection resets received
     3 connections established
     309 segments received
     264 segments send out
     7 segments retransmited
     0 bad segments received.
     6 resets sent
UdpLite:
TcpExt:
     10 TCP sockets finished time wait in slow timer
     5 delayed acks sent
     74 packets directly queued to recvmsg prequeue.
     16 packets directly received from backlog
     377 packets directly received from prequeue
     62 packets header predicted
     35 packets header predicted and directly queued to user
     32 acknowledgments not containing data received
     106 predicted acknowledgments
     0 TCP data loss events
     4 other TCP timeouts
     1 connections reset due to early user close
IpExt:
     InMcastPkts: 75
     OutMcastPkts: 62
     InOctets: 64952
     OutOctets: 66396
     InMcastOctets: 13428
     OutMcastOctets: 10403

netstat -st (sender, after 1st test)
[root@target2 ~]# netstat -st
IcmpMsg:
     InType3: 5
     InType8: 8
     OutType0: 8
     OutType3: 4
Tcp:
     70 active connections openings
     14 passive connection openings
     3 failed connection attempts
     4 connection resets received
     4 connections established
     16674253 segments received
     16673801 segments send out
     487 segments retransmited
     0 bad segments received.
     6 resets sent
UdpLite:
TcpExt:
     32 TCP sockets finished time wait in slow timer
     15 delayed acks sent
     228 packets directly queued to recvmsg prequeue.
     24 packets directly received from backlog
     1081 packets directly received from prequeue
     146 packets header predicted
     124 packets header predicted and directly queued to user
     10913589 acknowledgments not containing data received
     573 predicted acknowledgments
     185 times recovered from packet loss due to SACK data
     Detected reordering 1 times using FACK
     Detected reordering 8 times using SACK
     Detected reordering 2 times using time stamp
     1 congestion windows fully recovered
     23 congestion windows partially recovered using Hoe heuristic
     TCPDSACKUndo: 1
     0 TCP data loss events
     471 fast retransmits
     9 forward retransmits
     4 other TCP timeouts
     297 DSACKs received
     1 connections reset due to early user close
     TCPDSACKIgnoredOld: 258
     TCPDSACKIgnoredNoUndo: 39
     TCPSackShiftFallback: 35790574
IpExt:
     InMcastPkts: 89
     OutMcastPkts: 69
     InBcastPkts: 2
     InOctets: 1321825004
     OutOctets: -928982419
     InMcastOctets: 13848
     OutMcastOctets: 10627
     InBcastOctets: 483

Second test:

former "sender" side:
[root@target1 ~]# netstat -st
IcmpMsg:
     InType3: 5
     InType8: 13
     OutType0: 13
     OutType3: 4
Tcp:
     556 active connections openings
     65 passive connection openings
     391 failed connection attempts
     15 connection resets received
     4 connections established
     52164640 segments received
     52117884 segments send out
     62522 segments retransmited
     0 bad segments received.
     33 resets sent
UdpLite:
TcpExt:
     27 invalid SYN cookies received
     74 TCP sockets finished time wait in slow timer
     698540 packets rejects in established connections because of timestamp
     51 delayed acks sent
     487 delayed acks further delayed because of locked socket
     Quick ack mode was activated 18838 times
     7 times the listen queue of a socket overflowed
     7 SYNs to LISTEN sockets ignored
     1632 packets directly queued to recvmsg prequeue.
     4137769996 packets directly received from backlog
     5723253 packets directly received from prequeue
     1365131 packets header predicted
     136330 packets header predicted and directly queued to user
     10241415 acknowledgments not containing data received
     156502 predicted acknowledgments
     10983 times recovered from packet loss due to SACK data
     Detected reordering 4 times using FACK
     Detected reordering 10095 times using SACK
     Detected reordering 138 times using time stamp
     2107 congestion windows fully recovered
     18612 congestion windows partially recovered using Hoe heuristic
     TCPDSACKUndo: 80
     5 congestion windows recovered after partial ack
     0 TCP data loss events
     52 timeouts after SACK recovery
     2 timeouts in loss state
     61206 fast retransmits
     7 forward retransmits
     984 retransmits in slow start
     8 other TCP timeouts
     258 sack retransmits failed
     18838 DSACKs sent for old packets
     274 DSACKs sent for out of order packets
     14169 DSACKs received
     34 DSACKs for out of order packets received
     2 connections reset due to unexpected data
     TCPDSACKIgnoredOld: 8694
     TCPDSACKIgnoredNoUndo: 5482
     TCPSackShiftFallback: 18352494
IpExt:
     InMcastPkts: 104
     OutMcastPkts: 77
     InBcastPkts: 6
     InOctets: -474718903
     OutOctets: 1280495238
     InMcastOctets: 13974
     OutMcastOctets: 10908
     InBcastOctets: 1449



former "receiver" side:
[root@target2 ~]# netstat -st
IcmpMsg:
     InType3: 5
     InType8: 14
     OutType0: 14
     OutType3: 4
Tcp:
     182 active connections openings
     39 passive connection openings
     4 failed connection attempts
     12 connection resets received
     4 connections established
     52098089 segments received
     52180386 segments send out
     68994 segments retransmited
     0 bad segments received.
     1070 resets sent
UdpLite:
TcpExt:
     12 TCP sockets finished time wait in fast timer
     102 TCP sockets finished time wait in slow timer
     770084 packets rejects in established connections because of timestamp
     37 delayed acks sent
     261 delayed acks further delayed because of locked socket
     Quick ack mode was activated 14276 times
     1466 packets directly queued to recvmsg prequeue.
     1190723332 packets directly received from backlog
     4781569 packets directly received from prequeue
     776470 packets header predicted
     97281 packets header predicted and directly queued to user
     24979561 acknowledgments not containing data received
     484206 predicted acknowledgments
     11461 times recovered from packet loss due to SACK data
     Detected reordering 15 times using FACK
     Detected reordering 15520 times using SACK
     Detected reordering 208 times using time stamp
     2046 congestion windows fully recovered
     18402 congestion windows partially recovered using Hoe heuristic
     TCPDSACKUndo: 82
     13 congestion windows recovered after partial ack
     0 TCP data loss events
     49 timeouts after SACK recovery
     1 timeouts in loss state
     62078 fast retransmits
     5340 forward retransmits
     1181 retransmits in slow start
     20 other TCP timeouts
     322 sack retransmits failed
     14276 DSACKs sent for old packets
     36 DSACKs sent for out of order packets
     17940 DSACKs received
     254 DSACKs for out of order packets received
     4 connections reset due to early user close
     TCPDSACKIgnoredOld: 12703
     TCPDSACKIgnoredNoUndo: 5251
     TCPSackShiftFallback: 57141117
IpExt:
     InMcastPkts: 104
     OutMcastPkts: 76
     InBcastPkts: 6
     InOctets: 902997645
     OutOctets: -82887048
     InMcastOctets: 14296
     OutMcastOctets: 10851
     InBcastOctets: 1449
[root@target2 ~]#








-- 
Best regards,
Oleg Ukhno.
ITO Team Lead,
Yandex LLC.

