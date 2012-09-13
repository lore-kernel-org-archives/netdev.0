From: "Marc A. Donges" <marc.donges@1und1.de>
Subject: Re: bnx2 cards intermittantly going offline
Date: Thu, 13 Sep 2012 15:51:08 +0200
Message-ID: <20120913135108.GC3650@abomination.net.united.domain>
References: <1295373358.8131.4.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxintern.schlund.de ([212.227.126.201]:53433 "EHLO
	mxintern.schlund.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792Ab2IMN5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 09:57:40 -0400
Content-Disposition: inline
In-Reply-To: <1295373358.8131.4.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[This is a reply to a somewhat older thread]

"Michael Chan" wrote:
> On Tue, 2011-01-18 at 02:54 -0800, Mills, Tony wrote:
>> Last night i setup a machine to monitor overnight and at 3:52 this
>> morning it became unresponsive. 
>> 
> 
> When it becomes unresponsive, please send some packets to the NIC (such
> as ping) and monitor statistics with ethtool -S.  See if the packets are
> being received or discarded.  Also, run tcpdump on the machine to see if
> the packets are properly received by the stack.  Thanks.

Hi Michael, hi netdev,

I appear to be having the same problem as Tony (or at least a problem matching
his description).

The machine uses the BCM5709 chipset:

03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
03:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
04:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
04:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)

It is running Debian stable (with the Debian stable firmware-bnx2 package).

After 55 days of operation the machine (A) suddenly was no longer reachable via
network. Strangely, a second machine (B) that should take over the IP addresses
(keepalived) did not take over. Only after shutting the switchport to which A
is attached did B take over.

Logging in to the machine via serial, I noticed that it did not receive any
packets via the network interface (after unshutting the switchport), only
traffic sent by the host A was visible in tcpdump, no traffic that was sent to
it (there should have been at least ARP traffic). In order to verify this, I
dumped traffic on another host in the broadcast domain and indeed, the traffic
sent out by A is seen on the network, it just doesn't receive any that is sent
to it.

This explains the lack of failover of keepalived, because A still considers
itself master and is able to announce that to the network, while it cannot see
the packets from its partner B (that wants to take over because of its,
meanwhile, higher priority).

No neighbors see the machine in their ARP tables any more.

I think the number of packets that are sent to the host are reflected in the
interface variable rx_ftq_discards: It increases by about 10 per second while
idle, and by about 80 per second when I send floodpings to the machine. Here
you see a dump of the interface statistics spaced ten seconds apart, while
floodpinging the host:

A:~# ethtool -S eth0; sleep 10; echo ---; ethtool -S eth0
NIC statistics:
     rx_bytes: 35498373071360
     rx_error_bytes: 0
     tx_bytes: 35475382869262
     tx_error_bytes: 0
     rx_ucast_packets: 45479514105
     rx_mcast_packets: 9800399
     rx_bcast_packets: 4901866
     tx_ucast_packets: 45364190447
     tx_mcast_packets: 7285029
     tx_bcast_packets: 3111
     tx_mac_errors: 0
     tx_carrier_errors: 0
     rx_crc_errors: 0
     rx_align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     tx_deferred: 0
     tx_excess_collisions: 0
     tx_late_collisions: 0
     tx_total_collisions: 0
     rx_fragments: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_oversize_packets: 0
     rx_64_byte_packets: 3465587589
     rx_65_to_127_byte_packets: 422897833
     rx_128_to_255_byte_packets: 3996306350
     rx_256_to_511_byte_packets: 1500221686
     rx_512_to_1023_byte_packets: 1351649898
     rx_1024_to_1522_byte_packets: 397814646
     rx_1523_to_9022_byte_packets: 0
     tx_64_byte_packets: 3451623430
     tx_65_to_127_byte_packets: 366024709
     tx_128_to_255_byte_packets: 3954496418
     tx_256_to_511_byte_packets: 1499757422
     tx_512_to_1023_byte_packets: 1351506958
     tx_1024_to_1522_byte_packets: 388331444
     tx_1523_to_9022_byte_packets: 0
     rx_xon_frames: 0
     rx_xoff_frames: 0
     tx_xon_frames: 81
     tx_xoff_frames: 81
     rx_mac_ctrl_frames: 0
     rx_filtered_packets: 26701433
     rx_ftq_discards: 1796839
     rx_discards: 369
     rx_fw_discards: 0
---
NIC statistics:
     rx_bytes: 35498373162770
     rx_error_bytes: 0
     tx_bytes: 35475382869262
     tx_error_bytes: 0
     rx_ucast_packets: 45479514920
     rx_mcast_packets: 9800483
     rx_bcast_packets: 4901876
     tx_ucast_packets: 45364190447
     tx_mcast_packets: 7285029
     tx_bcast_packets: 3111
     tx_mac_errors: 0
     tx_carrier_errors: 0
     rx_crc_errors: 0
     rx_align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     tx_deferred: 0
     tx_excess_collisions: 0
     tx_late_collisions: 0
     tx_total_collisions: 0
     rx_fragments: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_oversize_packets: 0
     rx_64_byte_packets: 3465587625
     rx_65_to_127_byte_packets: 422898706
     rx_128_to_255_byte_packets: 3996306350
     rx_256_to_511_byte_packets: 1500221686
     rx_512_to_1023_byte_packets: 1351649898
     rx_1024_to_1522_byte_packets: 397814646
     rx_1523_to_9022_byte_packets: 0
     tx_64_byte_packets: 3451623430
     tx_65_to_127_byte_packets: 366024709
     tx_128_to_255_byte_packets: 3954496418
     tx_256_to_511_byte_packets: 1499757422
     tx_512_to_1023_byte_packets: 1351506958
     tx_1024_to_1522_byte_packets: 388331444
     tx_1523_to_9022_byte_packets: 0
     rx_xon_frames: 0
     rx_xoff_frames: 0
     tx_xon_frames: 81
     tx_xoff_frames: 81
     rx_mac_ctrl_frames: 0
     rx_filtered_packets: 26701433
     rx_ftq_discards: 1797748
     rx_discards: 369
     rx_fw_discards: 0

The number of interrupts for the NIC is no longer increasing on host A. It is increasing on the otherwise identical and now active host B.

A:~# cat /proc/interrupts | fgrep eth0; sleep 10; echo ---; cat /proc/interrupts | fgrep eth0
  74:    7353715          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-0
  75:  150160682          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-1
  76:  261739096          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-2
  77: 3118389637          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-3
  78: 3538415303          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-4
  79: 3437432016          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-5
  80: 4130864322          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-6
  81: 3844677189          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-7
---
  74:    7353715          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-0
  75:  150160682          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-1
  76:  261739096          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-2
  77: 3118389637          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-3
  78: 3538415303          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-4
  79: 3437432016          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-5
  80: 4130864322          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-6
  81: 3844677189          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-7

B:~# cat /proc/interrupts | fgrep eth0; sleep 10; echo ---; cat /proc/interrupts | fgrep eth0
  74:    8496700          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-0
  75: 2605649299          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-1
  76: 2278350057          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-2
  77: 2119009356          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-3
  78: 2004958460          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-4
  79: 2005171437          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-5
  80: 2318332903          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-6
  81: 2087470150          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-7
---
  74:    8496713          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-0
  75: 2605688265          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-1
  76: 2278397958          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-2
  77: 2119043500          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-3
  78: 2005000430          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-4
  79: 2005205617          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-5
  80: 2318373260          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-6
  81: 2087518969          0          0          0          0          0          0          0  IR-PCI-MSI-edge      eth0-7

There are no (significant) interface errors on the switchport of machine A (Cisco 6500):
  Input queue: 0/2000/0/0 (size/max/drops/flushes); Total output drops: 3354643
  Queueing strategy: fifo
  Output queue: 0/40 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 73000 bits/sec, 90 packets/sec
     139005756894 packets input, 106028470724434 bytes, 0 no buffer
     Received 41673355 broadcasts (41644823 multicasts)
     0 runts, 0 giants, 0 throttles 
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored
     0 watchdog, 0 multicast, 0 pause input
     0 input packets with dribble condition detected
     139565849434 packets output, 106109148647056 bytes, 0 underruns
     0 output errors, 0 collisions, 3 interface resets
     0 babbles, 0 late collision, 0 deferred
     0 lost carrier, 0 no carrier, 0 PAUSE output
     0 output buffer failures, 0 output buffers swapped out

For reference, switchport of machine B:
  Input queue: 0/2000/0/0 (size/max/drops/flushes); Total output drops: 561319
  Queueing strategy: fifo
  Output queue: 0/40 (size/max)
  5 minute input rate 168420000 bits/sec, 27846 packets/sec
  5 minute output rate 168547000 bits/sec, 27951 packets/sec
     12477681177 packets input, 9891434829664 bytes, 0 no buffer
     Received 4452361 broadcasts (4434737 multicasts)
     0 runts, 0 giants, 0 throttles 
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored
     0 watchdog, 0 multicast, 0 pause input
     0 input packets with dribble condition detected
     12725512555 packets output, 9944380037353 bytes, 0 underruns
     0 output errors, 0 collisions, 2 interface resets
     0 babbles, 0 late collision, 0 deferred
     0 lost carrier, 0 no carrier, 0 PAUSE output
     0 output buffer failures, 0 output buffers swapped out

This error occured about five hours ago, the interface did not recover.

We have five pairs of basically identical machines performing the same task
(each pair for one site). The error has not occured with any other one, but
this site is the busiest:

eth0      Link encap:Ethernet  HWaddr 3c:d9:2b:ef:f6:3c  
          inet addr:172.16.100.23  Bcast:172.16.100.63  Mask:255.255.255.192
          inet6 addr: fe80::3ed9:2bff:feef:f63c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:45494315484 errors:1896322 dropped:1896322 overruns:0 frame:1896322
          TX packets:45371478602 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:35498383041926 (32.2 TiB)  TX bytes:35475382870222 (32.2 TiB)
          Interrupt:30 Memory:f4000000-f4012800 

The host performs NAT, input and output interface being eth0, therefore the RX and TX counters are similar.

I would appreciate any suggestions for diagnosing this further.

Kind regards
Marc
