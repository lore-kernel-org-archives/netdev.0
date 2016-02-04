From: Rick Jones <rick.jones2@hpe.com>
Subject: Disabling XPS for 4.4.0-1+ixgbe+OpenStack VM over a VLAN means 65%
 increase in netperf TCP_STREAM
Date: Thu, 4 Feb 2016 11:13:24 -0800
Message-ID: <56B3A2D4.1010309@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:2290 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126AbcBDTN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 14:13:26 -0500
Received: from g4t3433.houston.hp.com (g4t3433.houston.hp.com [16.210.25.219])
	by g4t3426.houston.hp.com (Postfix) with ESMTP id 6539D49
	for <netdev@vger.kernel.org>; Thu,  4 Feb 2016 19:13:25 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g4t3433.houston.hp.com (Postfix) with ESMTP id 475F04C
	for <netdev@vger.kernel.org>; Thu,  4 Feb 2016 19:13:25 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks -

I was doing some performance work with OpenStack Liberty on systems with 
2x E5-2650L v3 @ 1.80GHz processors and 560FLR (Intel 82599ES) NICs onto 
which I'd placed a 4.4.0-1 kernel.  I was actually interested in the 
effect of removing the linux bridge from all the plumbing OpenStack 
creates (it is there for iptables-based implementation of security group 
rules because OS Liberty doesn't enable them on the OVS bridge(s) it 
creates), and I'd noticed that when I removed the linux bridge from the 
"stack" instance-to-instance (vm-to-vm) performance across a VLAN-based 
Neutron private network dropped.  Quite unexpected.

On a lark, I tried explicitly binding the NIC's IRQs and Boom! the 
single-stream performance shot-up to near link-rate.  I couldn't recall 
explicit binding of IRQs doing that much for single-stream netperf 
TCP_STREAM before.

I asked the Intel folks about that, they suggested I try disabling XPS. 
  So, with that I see the following on single-stream tests between the 
VMs on that VLAN-based private network as created by OpenStack Liberty:


	   99% Confident within +/- 2.5% of "real" average
		TCP_RR in Trans/s TCP_STREAM in Mbit/s

                    XPS Enabled   XPS Disabled   Delta
TCP_STREAM            5353	    8841 (*)    65.2%
TCP_RR                8562          9666        12.9%

The Intel folks suggested something about the process scheduler moving 
the sender around and ultimately causing some packet re-ordering.  That 
could I suppose explain the TCP_STREAM difference, but not the TCP_RR 
since that has just a single segment in flight at one time.

I can try to get perf/whatnot installed on the systems - suggestions as 
to what metrics to look at are welcome.

happy benchmarking,

rick jones
* If I disable XPS on the sending side only, it is more like 7700 Mbit/s

netstats from the receiver over a netperf TCP_STREAM test's duration 
with XPS enabled:

$ netperf -H 10.240.50.191 -- -o throughput,local_transport_retrans
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
10.240.50.191 () port 0 AF_INET : demo
Throughput,Local Transport Retransmissions
5292.74,4555


$ ./beforeafter before after
Ip:
     327837 total packets received
     0 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     327837 incoming packets delivered
     293438 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
         destination unreachable: 0
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
         destination unreachable: 0
IcmpMsg:
         InType3: 0
         OutType3: 0
Tcp:
     0 active connections openings
     2 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     327837 segments received
     293438 segments send out
     0 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     0 packets received
     0 packets to unknown port received.
     0 packet receive errors
     0 packets sent
     IgnoredMulti: 0
UdpLite:
TcpExt:
     0 TCP sockets finished time wait in fast timer
     0 delayed acks sent
     Quick ack mode was activated 1016 times
     50386 packets directly queued to recvmsg prequeue.
     309545872 bytes directly in process context from backlog
     2874395424 bytes directly received in process context from prequeue
     86591 packet headers predicted
     84934 packets header predicted and directly queued to user
     6 acknowledgments not containing data payload received
     20 predicted acknowledgments
     1017 DSACKs sent for old packets
     TCPRcvCoalesce: 157097
     TCPOFOQueue: 78206
     TCPOrigDataSent: 24
IpExt:
     InBcastPkts: 0
     InOctets: 6643231012
     OutOctets: 17203936
     InBcastOctets: 0
     InNoECTPkts: 327837

And now with it disabled on both sides:
$ netperf -H 10.240.50.191 -- -o throughput,local_transport_retrans
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
10.240.50.191 () port 0 AF_INET : demo
Throughput,Local Transport Retransmissions
8656.84,1903
$ ./beforeafter noxps_before noxps_avter
Ip:
     251831 total packets received
     0 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     251831 incoming packets delivered
     218415 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
         destination unreachable: 0
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
         destination unreachable: 0
IcmpMsg:
         InType3: 0
         OutType3: 0
Tcp:
     0 active connections openings
     2 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     251831 segments received
     218415 segments send out
     0 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     0 packets received
     0 packets to unknown port received.
     0 packet receive errors
     0 packets sent
     IgnoredMulti: 0
UdpLite:
TcpExt:
     0 TCP sockets finished time wait in fast timer
     0 delayed acks sent
     Quick ack mode was activated 48 times
     91752 packets directly queued to recvmsg prequeue.
     846851580 bytes directly in process context from backlog
     5442436572 bytes directly received in process context from prequeue
     102517 packet headers predicted
     146102 packets header predicted and directly queued to user
     6 acknowledgments not containing data payload received
     26 predicted acknowledgments
     TCPLossProbes: 0
     TCPLossProbeRecovery: 0
     48 DSACKs sent for old packets
     0 DSACKs received
     TCPRcvCoalesce: 45658
     TCPOFOQueue: 967
     TCPOrigDataSent: 30
IpExt:
     InBcastPkts: 0
     InOctets: 10837972268
     OutOctets: 11413100
     InBcastOctets: 0
     InNoECTPkts: 251831
