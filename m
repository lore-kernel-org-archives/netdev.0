From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Fri, 21 Jan 2011 16:55:46 +0300
Message-ID: <4D399062.3060004@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru> <4D3745AF.5040808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mammoth.yandex.ru ([93.158.136.51]:34554 "EHLO
	mammoth.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab1AUN4V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 08:56:21 -0500
In-Reply-To: <4D3745AF.5040808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2011 11:12 PM, Nicolas de Peslo=C3=BCan wrote:

> If you have time for that, then yes, please, do the same test using
> balance-rr+vlan to segregate path. With those results, we whould have
> the opportunity to enhance the documentation with some well tested ca=
ses
> of TCP load balancing on a LAN, not limited to 802.3ad automatic setu=
p.
> Both setups make sense, and assuming the results would be similar is
> probably true, but not reliable enough to assert it into the document=
ation.
>
> Thanks,
>
> Nicolas.
>
Nicolas,
I've ran similar tests for VLAN tunneling scenario. Results are=20
identical, as I expected. The only significat difference is link failur=
e=20
handling. 802.3ad mode allows almost painless load reditribution,=20
balance-rr causes packet loss.
The only question for me now is if my patch could be applied to upstrea=
m=20
version - fixing issues with adaptftion to net-next code aren't the=20
problem, if nobody objects
There were 2 tests:
1) unidirectional test
2) bidirectional test
Below are results:

Iperf results:
test 1:
  iperf -f m -c 192.168.111.128 -B 192.168.111.129 -p 9999 -t 300
------------------------------------------------------------
Client connecting to 192.168.111.128, TCP port 9999
Binding to local address 192.168.111.129
TCP window size: 32.0 MByte (default)
------------------------------------------------------------
[  3] local 192.168.111.129 port 9999 connected with 192.168.111.128=20
port 9999
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-300.0 sec  141637 MBytes  3960 Mbits/sec

test 2:
iperf -f m -c 192.168.111.128 -B 192.168.111.129 -p 9999 -t 300=20
--dualtest -P 4
------------------------------------------------------------
Server listening on TCP port 9999
Binding to local address 192.168.111.129
TCP window size: 32.0 MByte (default)
------------------------------------------------------------
=2E..
[SUM]  0.0-300.2 sec  111334 MBytes  3111 Mbits/sec
[SUM]  0.0-300.4 sec  109582 MBytes  3060 Mbits/sec

TCP stats:
receiver side, before test 1:
[root@target1 ~]# netstat -st
IcmpMsg:
     InType0: 4
     InType3: 6
     InType8: 2
     OutType0: 2
     OutType3: 6
     OutType8: 4
Tcp:
     4 active connections openings
     2 passive connection openings
     3 failed connection attempts
     0 connection resets received
     3 connections established
     10252 segments received
     29766 segments send out
     2 segments retransmited
     0 bad segments received.
     0 resets sent
UdpLite:
TcpExt:
     3 delayed acks sent
     613 packets directly queued to recvmsg prequeue.
     16 packets directly received from backlog
     1760 packets directly received from prequeue
     428 packets header predicted
     10 packets header predicted and directly queued to user
     9295 acknowledgments not containing data received
     265 predicted acknowledgments
     0 TCP data loss events
     1 other TCP timeouts
     TCPSackMerged: 1
     TCPSackShiftFallback: 1
IpExt:
     InMcastPkts: 92
     OutMcastPkts: 64
     InBcastPkts: 2
     InOctets: 1089217
     OutOctets: 265005791
     InMcastOctets: 16294
     OutMcastOctets: 10364
     InBcastOctets: 483


receiver side , after test 1:
[root@target1 ~]netstat -st
IcmpMsg:
     InType0: 17
     InType3: 6
     InType8: 9
     OutType0: 9
     OutType3: 6
     OutType8: 19
Tcp:
     84 active connections openings
     14 passive connection openings
     6 failed connection attempts
     4 connection resets received
     4 connections established
     16684784 segments received
     16704650 segments send out
     22 segments retransmited
     0 bad segments received.
     6 resets sent
UdpLite:
TcpExt:
     39 TCP sockets finished time wait in slow timer
     23 delayed acks sent
     83 delayed acks further delayed because of locked socket
     Quick ack mode was activated 225 times
     1019 packets directly queued to recvmsg prequeue.
     3235352384 packets directly received from backlog
     483600 packets directly received from prequeue
     86065 packets header predicted
     4855 packets header predicted and directly queued to user
     10369 acknowledgments not containing data received
     928 predicted acknowledgments
     0 TCP data loss events
     2 retransmits in slow start
     6 other TCP timeouts
     225 DSACKs sent for old packets
     1 connections reset due to unexpected data
     TCPSackMerged: 1
     TCPSackShiftFallback: 3
IpExt:
     InMcastPkts: 108
     OutMcastPkts: 72
     InBcastPkts: 4
     InOctets: -936746758
     OutOctets: 1556837236
     InMcastOctets: 16774
     OutMcastOctets: 10620
     InBcastOctets: 966

receiver side, after test 2
[root@target1 ~]netstat -st
IcmpMsg:
     InType0: 17
     InType3: 6
     InType8: 12
     OutType0: 12
     OutType3: 6
     OutType8: 19
Tcp:
     144 active connections openings
     25 passive connection openings
     29 failed connection attempts
     7 connection resets received
     4 connections established
     44349148 segments received
     44401154 segments send out
     58434 segments retransmited
     0 bad segments received.
     6 resets sent
UdpLite:
TcpExt:
     58 TCP sockets finished time wait in slow timer
     735072 packets rejects in established connections because of times=
tamp
     34 delayed acks sent
     359 delayed acks further delayed because of locked socket
     Quick ack mode was activated 14800 times
     2112 packets directly queued to recvmsg prequeue.
     3753925448 packets directly received from backlog
     4377976 packets directly received from prequeue
     847653 packets header predicted
     105696 packets header predicted and directly queued to user
     8804473 acknowledgments not containing data received
     154775 predicted acknowledgments
     10465 times recovered from packet loss due to SACK data
     Detected reordering 1 times using FACK
     Detected reordering 11185 times using SACK
     Detected reordering 182 times using time stamp
     2116 congestion windows fully recovered
     18951 congestion windows partially recovered using Hoe heuristic
     TCPDSACKUndo: 58
     8 congestion windows recovered after partial ack
     0 TCP data loss events
     53 timeouts after SACK recovery
     1 timeouts in loss state
     57287 fast retransmits
     12 forward retransmits
     793 retransmits in slow start
     10 other TCP timeouts
     263 sack retransmits failed
     14800 DSACKs sent for old packets
     31 DSACKs sent for out of order packets
     14289 DSACKs received
     43 DSACKs for out of order packets received
     1 connections reset due to unexpected data
     TCPDSACKIgnoredOld: 8615
     TCPDSACKIgnoredNoUndo: 5683
     TCPSackMerged: 1
     TCPSackShiftFallback: 15015212
IpExt:
     InMcastPkts: 116
     OutMcastPkts: 76
     InBcastPkts: 4
     InOctets: 1012355682
     OutOctets: -1540562156
     InMcastOctets: 17014
     OutMcastOctets: 10748
     InBcastOctets: 966


sender side, before test 1:
[root@target2 ~]# netstat -st
IcmpMsg:
     InType3: 4
     InType8: 32
     OutType0: 32
     OutType3: 4
Tcp:
     1 active connections openings
     2 passive connection openings
     0 failed connection attempts
     0 connection resets received
     3 connections established
     30268 segments received
     10217 segments send out
     0 segments retransmited
     0 bad segments received.
     3 resets sent
UdpLite:
TcpExt:
     7 delayed acks sent
     6332 packets directly queued to recvmsg prequeue.
     8 packets directly received from backlog
     46104 packets directly received from prequeue
     27935 packets header predicted
     11 packets header predicted and directly queued to user
     455 acknowledgments not containing data received
     119 predicted acknowledgments
     0 TCP data loss events
     TCPSackShiftFallback: 1
IpExt:
     InMcastPkts: 87
     OutMcastPkts: 54
     InBcastPkts: 2
     InOctets: 265039007
     OutOctets: 1083024
     InMcastOctets: 16444
     OutMcastOctets: 9893
     InBcastOctets: 483

sender side , after test 1:
[root@target2 ~]# netstat -st
IcmpMsg:
     InType3: 4
     InType8: 53
     OutType0: 53
     OutType3: 4
Tcp:
     69 active connections openings
     12 passive connection openings
     2 failed connection attempts
     4 connection resets received
     4 connections established
     16704819 segments received
     16684841 segments send out
     401 segments retransmited
     0 bad segments received.
     10 resets sent
UdpLite:
TcpExt:
     31 TCP sockets finished time wait in slow timer
     25 delayed acks sent
     6515 packets directly queued to recvmsg prequeue.
     24 packets directly received from backlog
     46988 packets directly received from prequeue
     27974 packets header predicted
     115 packets header predicted and directly queued to user
     10259331 acknowledgments not containing data received
     12483 predicted acknowledgments
     166 times recovered from packet loss due to SACK data
     Detected reordering 1 times using FACK
     Detected reordering 7 times using SACK
     Detected reordering 1 times using time stamp
     1 congestion windows fully recovered
     41 congestion windows partially recovered using Hoe heuristic
     0 TCP data loss events
     386 fast retransmits
     5 forward retransmits
     3 other TCP timeouts
     1 times receiver scheduled too late for direct processing
     225 DSACKs received
     1 connections reset due to unexpected data
     TCPDSACKIgnoredOld: 167
     TCPDSACKIgnoredNoUndo: 58
     TCPSackShiftFallback: 30925668
IpExt:
     InMcastPkts: 103
     OutMcastPkts: 62
     InBcastPkts: 4
     InOctets: 1556368288
     OutOctets: -934790015
     InMcastOctets: 16924
     OutMcastOctets: 10149
     InBcastOctets: 966

sender side, after test 2:
[root@target2 ~]# netstat -st
IcmpMsg:
     InType3: 4
     InType8: 56
     OutType0: 56
     OutType3: 4
Tcp:
     117 active connections openings
     25 passive connection openings
     2 failed connection attempts
     7 connection resets received
     4 connections established
     44383169 segments received
     44367187 segments send out
     59660 segments retransmited
     0 bad segments received.
     34 resets sent
UdpLite:
TcpExt:
     2 TCP sockets finished time wait in fast timer
     57 TCP sockets finished time wait in slow timer
     717082 packets rejects in established connections because of times=
tamp
     46 delayed acks sent
     202 delayed acks further delayed because of locked socket
     Quick ack mode was activated 14356 times
     7432 packets directly queued to recvmsg prequeue.
     135038632 packets directly received from backlog
     3633432 packets directly received from prequeue
     783534 packets header predicted
     94671 packets header predicted and directly queued to user
     20034470 acknowledgments not containing data received
     177885 predicted acknowledgments
     10851 times recovered from packet loss due to SACK data
     Detected reordering 6 times using FACK
     Detected reordering 9217 times using SACK
     Detected reordering 111 times using time stamp
     2125 congestion windows fully recovered
     19325 congestion windows partially recovered using Hoe heuristic
     TCPDSACKUndo: 71
     7 congestion windows recovered after partial ack
     0 TCP data loss events
     52 timeouts after SACK recovery
     58562 fast retransmits
     67 forward retransmits
     736 retransmits in slow start
     8 other TCP timeouts
     226 sack retransmits failed
     1 times receiver scheduled too late for direct processing
     14356 DSACKs sent for old packets
     44 DSACKs sent for out of order packets
     14679 DSACKs received
     31 DSACKs for out of order packets received
     1 connections reset due to unexpected data
     TCPDSACKIgnoredOld: 8899
     TCPDSACKIgnoredNoUndo: 5791
     TCPSackShiftFallback: 47227517
IpExt:
     InMcastPkts: 109
     OutMcastPkts: 65
     InBcastPkts: 4
     InOctets: -1885181292
     OutOctets: 1366995261
     InMcastOctets: 17104
     OutMcastOctets: 10245
     InBcastOctets: 966

--=20
Best regards,
Oleg Ukhno,
ITO Team lead
Yandex LLC.

