From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 15:12:04 -0700
Message-ID: <4E98B3B4.20406@hp.com>
References: <1318576791.2533.99.camel@edumazet-laptop> <20111014.034224.1197576516015404466.davem@davemloft.net> <4E985A3F.5080103@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:12833 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab1JNWMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 18:12:07 -0400
In-Reply-To: <4E985A3F.5080103@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I believe that may be the case - at least during something like:
>
> netperf -t TCP_RR -H <host> -l 30 -- -b 256 -D
>
> which on an otherwise quiet test setup will report a non-trivial number
> of retransmissions - either via looking at netstat -s output, or by
> adding local_transport_retrans,remote_transport_retrans to an output
> selector for netperf (eg -o
> throughput,burst_size,local_transport_retrans,remote_transport_retrans,lss_size_end,rsr_size_end)
>
>
> (I plan on providing more data after a laptop has gone through some
> upgrades)

So, a test as above from a system running 2.6.38-11-generic to a system 
running 3.0.0-12-generic.  On the sender we have:

raj@tardy:~/netperf2_trunk$ netstat -s > before; src/netperf -H 
raj-8510w.americas.hpqcorp.net -t tcp_rr -- -b 256 -D -o 
throughput,local_transport_retrans,remote_transport_retrans,lss_size_end,rsr_size_end 
; netstat -s > after
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to internal-host.americas.hpqcorp.net (16.89.245.115) port 0 AF_INET : 
nodelay : first burst 256
Throughput,Local Transport Retransmissions,Remote Transport 
Retransmissions,Local Send Socket Size Final,Remote Recv Socket Size Final
76752.43,274,0,16384,98304

274 retransmissions at the sender.  The "beforeafter" of that on the sender:

raj@tardy:~/netperf2_trunk$ cat delta.send
Ip:
     766747 total packets received
     12 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     766735 incoming packets delivered
     734689 requests sent out
     0 dropped because of missing route
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
         destination unreachable: 0
         echo requests: 0
         echo replies: 0
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
         destination unreachable: 0
         echo request: 0
         echo replies: 0
IcmpMsg:
         InType0: 0
         InType3: 0
         InType8: 0
         OutType0: 0
         OutType3: 0
         OutType8: 0
Tcp:
     2 active connections openings
     0 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     766727 segments received
     734408 segments send out
     274 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     7 packets received
     0 packets to unknown port received.
     0 packet receive errors
     7 packets sent
UdpLite:
TcpExt:
     0 packets pruned from receive queue because of socket buffer overrun
     0 ICMP packets dropped because they were out-of-window
     0 TCP sockets finished time wait in fast timer
     2 delayed acks sent
     0 delayed acks further delayed because of locked socket
     Quick ack mode was activated 0 times
     170856 packets directly queued to recvmsg prequeue.
     1204 bytes directly in process context from backlog
     170678 bytes directly received in process context from prequeue
     592090 packet headers predicted
     170626 packets header predicted and directly queued to user
     1375 acknowledgments not containing data payload received
     174911 predicted acknowledgments
     150 times recovered from packet loss by selective acknowledgements
     0 congestion windows recovered without slow start by DSACK
     0 congestion windows recovered without slow start after partial ack
     299 TCP data loss events
     TCPLostRetransmit: 9
     0 timeouts after reno fast retransmit
     0 timeouts after SACK recovery
     253 fast retransmits
     14 forward retransmits
     6 retransmits in slow start
     0 other TCP timeouts
     1 SACK retransmits failed
     0 times receiver scheduled too late for direct processing
     0 packets collapsed in receive queue due to low socket buffer
     0 DSACKs sent for old packets
     0 DSACKs received
     0 connections reset due to unexpected data
     0 connections reset due to early user close
     0 connections aborted due to timeout
     0 times unabled to send RST due to no memory
     TCPDSACKIgnoredOld: 0
     TCPDSACKIgnoredNoUndo: 0
     TCPSackShifted: 0
     TCPSackMerged: 1031
     TCPSackShiftFallback: 240
     TCPBacklogDrop: 0
     IPReversePathFilter: 0
IpExt:
     InMcastPkts: 0
     OutMcastPkts: 0
     InBcastPkts: 1
     InOctets: -1012182764
     OutOctets: -1436530450
     InMcastOctets: 0
     OutMcastOctets: 0
     InBcastOctets: 147

and then the deltas on the receiver:

raj@raj-8510w:~/netperf2_trunk$ cat delta.recv
Ip:
     734669 total packets received
     0 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     734669 incoming packets delivered
     766696 requests sent out
     0 dropped because of missing route
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
         destination unreachable: 0
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
IcmpMsg:
         InType3: 0
Tcp:
     0 active connections openings
     2 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     734651 segments received
     766695 segments send out
     0 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     1 packets received
     0 packets to unknown port received.
     0 packet receive errors
     1 packets sent
UdpLite:
TcpExt:
     28 packets pruned from receive queue because of socket buffer overrun
     0 delayed acks sent
     0 delayed acks further delayed because of locked socket
     19 packets directly queued to recvmsg prequeue.
     0 bytes directly in process context from backlog
     667 bytes directly received in process context from prequeue
     727842 packet headers predicted
     9 packets header predicted and directly queued to user
     161 acknowledgments not containing data payload received
     229704 predicted acknowledgments
     6774 packets collapsed in receive queue due to low socket buffer
     TCPBacklogDrop: 276
IpExt:
     InMcastPkts: 0
     OutMcastPkts: 0
     InBcastPkts: 17
     OutBcastPkts: 0
     InOctets: 38973144
     OutOctets: 40673137
     InMcastOctets: 0
     OutMcastOctets: 0
     InBcastOctets: 1816
     OutBcastOctets: 0

this is an otherwise clean network, no errors reported by ifconfig or 
ethtool -S, and the packet rate was well within the limits of 1 GbE and 
the ProCurve 2724 switch between the two systems.

 From just a very quick look it looks like tcp_v[46]_rcv is called, 
finds that the socket is owned by the user, attempts to add to the 
backlog, but the path called by sk_add_backlog does not seem to make any 
attempts to compress things, so when the quantity of data is << the 
truesize it starts tossing babies out with the bathwater.

rick jones
