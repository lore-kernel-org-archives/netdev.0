From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Is veth in net-next reordering traffic?
Date: Thu, 07 May 2015 09:01:49 -0700
Message-ID: <554B8C6D.70404@hp.com>
References: <554AC83F.7070609@hp.com> <1430968617.14545.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:36626 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbbEGQBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 12:01:50 -0400
In-Reply-To: <1430968617.14545.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2015 08:16 PM, Eric Dumazet wrote:
> On Wed, 2015-05-06 at 19:04 -0700, Rick Jones wrote:
>> I've been messing about with a setup approximating what an OpenStack
>> Nova Compute node creates for the private networking plumbing when using
>> OVX+VxLAN.  Just without the VM.  So, I have a linux bridge (named qbr),
>> a veth pair (named qvb and qvo) joining that to an OVS switch (called
>> br-int) which then has a patch pair joining that OVS bridge to another
>> OVS bridge (br-tun) which has a vxlan tunnel defined.
>
> veth can certainly reorder traffic, unless you use cpu binding with your
> netperf (sender side)

Is the seemingly high proportion of spurious retransmissions a concern? 
  (Assuming I'm looking at an interpreting correct stats):

Unbound:
root@qu-stbaz1-perf0000:~# netstat -s > beforestat; netperf -H 
192.168.0.22 -l 30 -- -O throughput,local_transport_retrans; netstat -s 
 > afterstat;~raj/beforeafter beforestat afterstat | grep -i -e reord -e 
dsack
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.0.22 () port 0 AF_INET : demo
Throughput Local
            Transport
            Retransmissions

2864.44    8892
     Detected reordering 0 times using FACK
     Detected reordering 334059 times using SACK
     Detected reordering 9722 times using time stamp
     5 congestion windows recovered without slow start by DSACK
     0 DSACKs sent for old packets
     8114 DSACKs received
     0 DSACKs for out of order packets received
     TCPDSACKIgnoredOld: 26
     TCPDSACKIgnoredNoUndo: 6153


Bound (CPU 1 picked arbitrarily):
root@qu-stbaz1-perf0000:~# netstat -s > beforestat; netperf -H 
192.168.0.22 -l 30 -T 1 -- -O throughput,local_transport_retrans; 
netstat -s > afterstat;~raj/beforeafter beforestat afterstat | grep -i 
-e reord -e dsack
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.0.22 () port 0 AF_INET : demo : cpu bind
Throughput Local
            Transport
            Retransmissions

3278.14    4099
     Detected reordering 0 times using FACK
     Detected reordering 8154 times using SACK
     Detected reordering 3 times using time stamp
     1 congestion windows recovered without slow start by DSACK
     0 DSACKs sent for old packets
     669 DSACKs received
     169 DSACKs for out of order packets received
     TCPDSACKIgnoredOld: 0
     TCPDSACKIgnoredNoUndo: 37

I suppose then that is also why I see so many tx queues getting involved 
in ixgbe for just a single stream?

(ethtool stats over a 5 second interval run through beforeafter)

5
NIC statistics:
      rx_packets: 541461
      tx_packets: 1010748
      rx_bytes: 63833156
      tx_bytes: 1529215668
      rx_pkts_nic: 541461
      tx_pkts_nic: 1010748
      rx_bytes_nic: 65998760
      tx_bytes_nic: 1533258678
      multicast: 14
      fdir_match: 9
      fdir_miss: 541460
      tx_restart_queue: 150
      tx_queue_0_packets: 927983
      tx_queue_0_bytes: 1404085816
      tx_queue_1_packets: 19872
      tx_queue_1_bytes: 30086064
      tx_queue_2_packets: 10650
      tx_queue_2_bytes: 16121144
      tx_queue_3_packets: 1200
      tx_queue_3_bytes: 1815402
      tx_queue_4_packets: 409
      tx_queue_4_bytes: 619226
      tx_queue_5_packets: 459
      tx_queue_5_bytes: 694926
      tx_queue_8_packets: 49715
      tx_queue_8_bytes: 75096650
      tx_queue_16_packets: 460
      tx_queue_16_bytes: 696440
      rx_queue_0_packets: 10
      rx_queue_0_bytes: 654
      rx_queue_3_packets: 541437
      rx_queue_3_bytes: 63830248
      rx_queue_6_packets: 14
      rx_queue_6_bytes: 2254

Versus a bound netperf:

5
NIC statistics:
      rx_packets: 1123827
      tx_packets: 1619156
      rx_bytes: 140008757
      tx_bytes: 2450188854
      rx_pkts_nic: 1123816
      tx_pkts_nic: 1619197
      rx_bytes_nic: 144502745
      tx_bytes_nic: 2456723162
      multicast: 13
      fdir_match: 4
      fdir_miss: 1123834
      tx_restart_queue: 757
      tx_queue_0_packets: 1373194
      tx_queue_0_bytes: 2078088490
      tx_queue_1_packets: 245959
      tx_queue_1_bytes: 372099706
      tx_queue_13_packets: 3
      tx_queue_13_bytes: 658
      rx_queue_0_packets: 4
      rx_queue_0_bytes: 264
      rx_queue_3_packets: 1123810
      rx_queue_3_bytes: 140006400
      rx_queue_6_packets: 13
      rx_queue_6_bytes: 2093
