From: Rick Jones <rick.jones2@hp.com>
Subject: Re: data vs overhead bytes, netperf aggregate RR and retransmissions
Date: Thu, 04 Aug 2011 10:26:16 -0700
Message-ID: <4E3AD638.6030009@hp.com>
References: <4E386E98.1090606@hp.com> <CAEuXFEzemZxw5PVTzJeEZD=csyrB6uTWO6m-hZTdKqUvhBAhxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:35625 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab1HDR0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 13:26:18 -0400
In-Reply-To: <CAEuXFEzemZxw5PVTzJeEZD=csyrB6uTWO6m-hZTdKqUvhBAhxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2011 11:37 PM, Jesse Brandeburg wrote:
> On Tue, Aug 2, 2011 at 2:39 PM, Rick Jones<rick.jones2@hp.com>  wrote:
>> driver: igb
>> version: 2.1.0-k2
>> firmware-version: 1.8-2
>> bus-info: 0000:05:00.0
>>
>> One of the things fixed recently in netperf (top-of-trunk, beyond 2.5.0) is
>> I actually have reporting of per-connection TCP retransmissions working.  I
>> was looking at that, and noticed a bunch of retransmissions at the 256 burst
>> level with 24 concurrent netperfs.  I figured it was simple overload of say
>> the switch or the one port active on the SUT (I do have one system talking
>> to two, so perhaps some incast).  Burst 64 had retrans as well.  Burst 16
>> and below did not.  That pattern repeated at 12 concurrent netperfs, and 8,
>> and 4 and 2 and even 1 - yes, a single netperf aggregate TCP_RR test with a
>> burst of 64 was reporting TCP retransmissions.  No incasting issues there.
>>   The network was otherwise clean.
>
> Rick, can you reboot and try with idle=poll OR set ethtool -C ethX rx-usecs 0
> both tests would be interesting, possibly relating your issue to cpu
> power management and/or interrupt throttling, or some combo of both.

I can do the latter easily enough.  Still, doesn't the bit with altering 
the socket buffer sizes making the retransmissions go away suggest there 
aren't issues down at the NIC?  Well, apart from perhaps using a 
relatively gianormous buffer for a small packet...

> Also please check the ethtool -S ethX stats from the hardware, and
> include them in your reply.

So,  at a burst of 64, rx-usecs set to 0 on both sides:

# netstat -s > before.netstat; ethtool -S eth0 > before.ethtool; 
./netperf -t TCP_RR -l 30 -H mumble.181 -P 0 -- -r 1 -b 64 -D  -o 
throughput,burst_size,local_transport_retrans,remote_transport_retrans,lss_size_end,lsr_size_end,rss_size_end,rsr_size_end; 
netstat -s > after.netstat; ethtool -S eth0 > after.ethtool
167602.12,64,27,125,121200,117760,16384,101200

27 retransmissions on the netperf side, 125 on the netserver side:

The ethtool stats look clean on both sides.

Netperf side:
  beforeafter before.ethtool after.ethtool NIC statistics:
      rx_packets: 5021655
      tx_packets: 5025802
      rx_bytes: 356547801
      tx_bytes: 356850352
      rx_broadcast: 0
      tx_broadcast: 0
      rx_multicast: 1
      tx_multicast: 0
      multicast: 1
      collisions: 0
      rx_crc_errors: 0
      rx_no_buffer_count: 0
      rx_missed_errors: 0
      tx_aborted_errors: 0
      tx_carrier_errors: 0
      tx_window_errors: 0
      tx_abort_late_coll: 0
      tx_deferred_ok: 0
      tx_single_coll_ok: 0
      tx_multi_coll_ok: 0
      tx_timeout_count: 0
      rx_long_length_errors: 0
      rx_short_length_errors: 0
      rx_align_errors: 0
      tx_tcp_seg_good: 0
      tx_tcp_seg_failed: 0
      rx_flow_control_xon: 0
      rx_flow_control_xoff: 0
      tx_flow_control_xon: 0
      tx_flow_control_xoff: 0
      rx_long_byte_count: 356547801
      tx_dma_out_of_sync: 0
      tx_smbus: 0
      rx_smbus: 0
      dropped_smbus: 0
      rx_errors: 0
      tx_errors: 0
      tx_dropped: 0
      rx_length_errors: 0
      rx_over_errors: 0
      rx_frame_errors: 0
      rx_fifo_errors: 0
      tx_queue_1_packets: 0
      tx_queue_1_bytes: 0
      tx_queue_1_restart: 0
      tx_queue_2_packets: 0
      tx_queue_2_bytes: 0
      tx_queue_2_restart: 0
      tx_queue_3_packets: 5025801
      tx_queue_3_bytes: 336747030
      tx_queue_3_restart: 0
      tx_queue_4_packets: 0
      tx_queue_4_bytes: 0
      tx_queue_4_restart: 0
      tx_queue_5_packets: 1
      tx_queue_5_bytes: 114
      tx_queue_5_restart: 0
      tx_queue_6_packets: 0
      tx_queue_6_bytes: 0
      tx_queue_6_restart: 0
      tx_queue_7_packets: 0
      tx_queue_7_bytes: 0
      tx_queue_7_restart: 0
      rx_queue_0_packets: 1
      rx_queue_0_bytes: 340
      rx_queue_0_drops: 0
      rx_queue_0_csum_err: 0
      rx_queue_0_alloc_failed: 0
      rx_queue_1_packets: 0
      rx_queue_1_bytes: 0
      rx_queue_1_drops: 0
      rx_queue_1_csum_err: 0
      rx_queue_1_alloc_failed: 0
      rx_queue_2_packets: 5021647
      rx_queue_2_bytes: 336459603
      rx_queue_2_drops: 0
      rx_queue_2_csum_err: 0
      rx_queue_2_alloc_failed: 0
      rx_queue_3_packets: 0
      rx_queue_3_bytes: 0
      rx_queue_3_drops: 0
      rx_queue_3_csum_err: 0
      rx_queue_3_alloc_failed: 0
      rx_queue_4_packets: 0
      rx_queue_4_bytes: 0
      rx_queue_4_drops: 0
      rx_queue_4_csum_err: 0
      rx_queue_4_alloc_failed: 0
      rx_queue_5_packets: 6
      rx_queue_5_bytes: 1172
      rx_queue_5_drops: 0
      rx_queue_5_csum_err: 0
      rx_queue_5_alloc_failed: 0
      rx_queue_6_packets: 0
      rx_queue_6_bytes: 0
      rx_queue_6_drops: 0
      rx_queue_6_csum_err: 0
      rx_queue_6_alloc_failed: 0
      rx_queue_7_packets: 1
      rx_queue_7_bytes: 66
      rx_queue_7_drops: 0
      rx_queue_7_csum_err: 0
      rx_queue_7_alloc_failed: 0

Netserver side, only the non-zero stats to save space in the email:
# beforeafter before.ethtool after.ethtool | grep -v " 0$"
NIC statistics:
      rx_packets: 5025804
      tx_packets: 5021656
      rx_bytes: 356850742
      tx_bytes: 356547772
      rx_multicast: 1
      tx_multicast: 1
      multicast: 1
      rx_long_byte_count: 356850742
      tx_queue_0_packets: 1
      tx_queue_0_bytes: 169
      tx_queue_3_packets: 2
      tx_queue_3_bytes: 148
      tx_queue_4_packets: 1
      tx_queue_4_bytes: 114
      tx_queue_5_packets: 6
      tx_queue_5_bytes: 1188
      tx_queue_6_packets: 5021646
      tx_queue_6_bytes: 336459529
      rx_queue_0_packets: 1
      rx_queue_0_bytes: 340
      rx_queue_1_packets: 5025792
      rx_queue_1_bytes: 336745916
      rx_queue_5_packets: 9
      rx_queue_5_bytes: 1114
      rx_queue_6_packets: 1
      rx_queue_6_bytes: 90
      rx_queue_7_packets: 1
      rx_queue_7_bytes: 66

Netstat statistics on the netperf side:

# beforeafter before.netstat after.netstat
Ip:
     5021654 total packets received
     0 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     5021654 incoming packets delivered
     5025802 requests sent out
     0 outgoing packets dropped
     0 dropped because of missing route
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
         destination unreachable: 0
         echo requests: 0
         echo replies: 0
         timestamp request: 0
         address mask request: 0
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
         destination unreachable: 0
         echo request: 0
         echo replies: 0
         timestamp replies: 0
IcmpMsg:
         InType0: 0
         InType3: 0
         InType8: 0
         InType13: 0
         InType15: 0
         InType17: 0
         InType37: 0
         OutType0: 0

Yes, there seems to be a bug in the Ubuntu 11.04 netstat - there should 
be a Tcp: header here.  It isn't being caused by beforeafter.

     0 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     5021654 segments received
     5025775 segments send out
     27 segments retransmited

There are the netperf side's 27 retransmissions

     0 bad segments received.
     0 resets sent
Udp:
     0 packets received
     0 packets to unknown port received.
     0 packet receive errors
     0 packets sent
     SndbufErrors: 0
UdpLite:
TcpExt:
     0 invalid SYN cookies received
     17 packets pruned from receive queue because of socket buffer overrun

Those perhaps contributed to netserver's retransmissions

     0 TCP sockets finished time wait in fast timer
     1 delayed acks sent
     0 delayed acks further delayed because of locked socket
     Quick ack mode was activated 0 times
     232 packets directly queued to recvmsg prequeue.
     7 bytes directly in process context from backlog
     191 bytes directly received in process context from prequeue
     0 packets dropped from prequeue
     5019673 packet headers predicted
     175 packets header predicted and directly queued to user
     115 acknowledgments not containing data payload received
     3309056 predicted acknowledgments
     13 times recovered from packet loss by selective acknowledgements
     0 congestion windows recovered without slow start by DSACK
     0 congestion windows recovered without slow start after partial ack
     35 TCP data loss events
     TCPLostRetransmit: 0
     0 timeouts after SACK recovery
     23 fast retransmits
     4 forward retransmits
     0 retransmits in slow start
     0 other TCP timeouts
     0 SACK retransmits failed
     0 times receiver scheduled too late for direct processing
     952 packets collapsed in receive queue due to low socket buffer

Looks like there was at least some compression going-on.

     0 DSACKs sent for old packets
     0 DSACKs received
     0 connections reset due to early user close
     0 connections aborted due to timeout
     TCPDSACKIgnoredOld: 0
     TCPDSACKIgnoredNoUndo: 0
     TCPSpuriousRTOs: 0
     TCPSackShifted: 0
     TCPSackMerged: 71
     TCPSackShiftFallback: 23
     TCPBacklogDrop: 125
     IPReversePathFilter: 0
IpExt:
     InBcastPkts: 0
     InOctets: 266157685
     OutOctets: 266385916
     InBcastOctets: 0

Netserver side netstat:
# beforeafter before.netstat after.netstat
Ip:
     5025803 total packets received
     0 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     5025803 incoming packets delivered
     5021655 requests sent out
     0 dropped because of missing route
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
         destination unreachable: 0
         echo requests: 0
         echo replies: 0
         timestamp request: 0
         address mask request: 0
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
         destination unreachable: 0
         echo request: 0
         echo replies: 0
         timestamp replies: 0
IcmpMsg:
         InType0: 0
         InType3: 0
         InType8: 0
         InType13: 0
         InType15: 0
         InType17: 0
         InType37: 0
         OutType0: 0
     0 failed connection attempts
     0 connection resets received
     0 connections established
     5025802 segments received
     5021529 segments send out
     125 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     1 packets received
     0 packets to unknown port received.
     0 packet receive errors
     1 packets sent
UdpLite:
TcpExt:
     0 invalid SYN cookies received
     0 resets received for embryonic SYN_RECV sockets
     8 packets pruned from receive queue because of socket buffer overrun
     0 TCP sockets finished time wait in fast timer
     0 delayed acks sent
     0 delayed acks further delayed because of locked socket
     Quick ack mode was activated 0 times
     79335 packets directly queued to recvmsg prequeue.
     13653 bytes directly in process context from backlog
     73540 bytes directly received in process context from prequeue
     0 packets dropped from prequeue
     4937282 packet headers predicted
     86900 packets header predicted and directly queued to user
     739 acknowledgments not containing data payload received
     3278603 predicted acknowledgments
     69 times recovered from packet loss by selective acknowledgements
     0 congestion windows recovered without slow start after partial ack
     76 TCP data loss events
     TCPLostRetransmit: 0
     0 timeouts after SACK recovery
     0 timeouts in loss state
     119 fast retransmits
     6 forward retransmits
     0 retransmits in slow start
     0 other TCP timeouts
     0 SACK retransmits failed
     0 times receiver scheduled too late for direct processing
     412 packets collapsed in receive queue due to low socket buffer
     0 DSACKs sent for old packets
     0 DSACKs received
     0 connections reset due to early user close
     0 connections aborted due to timeout
     0 times unabled to send RST due to no memory
     TCPDSACKIgnoredOld: 0
     TCPDSACKIgnoredNoUndo: 0
     TCPSpuriousRTOs: 0
     TCPSackShifted: 0
     TCPSackMerged: 573
     TCPSackShiftFallback: 125
     TCPBacklogDrop: 27
     IPReversePathFilter: 0
IpExt:
     InBcastPkts: 0
     InOctets: -2097789687
     OutOctets: -269886774
     InBcastOctets: 0
