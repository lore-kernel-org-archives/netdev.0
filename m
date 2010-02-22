From: Jorrit Kronjee <j.kronjee@infopact.nl>
Subject: stress testing netfilter's hashlimit
Date: Mon, 22 Feb 2010 15:20:54 +0100
Message-ID: <4B8292C6.4000207@infopact.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infopact.nl ([212.29.160.232]:45779 "EHLO
	smtp1.infopact.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab0BVOVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 09:21:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

I'm not entirely sure if this is the right list for this question, but
if someone could me give me some pointers where to ask otherwise, it
would be most appreciated.

We're trying to stress test netfilter's hashlimit module. To do so,
we've built the following setup.

[ sender ] --> [ bridge ] --> [ receiver ]

Each of these are separate machines. The sender has a Gigabit Ethernet
interface and sends ~410,000 packets per second (52 bytes Ethernet
frames). The bridge has two Gigabit Ethernet interfaces, a quad core
Xeon X3330 and is running Ubuntu 9.10 (Karmic Koala) with kernel
2.6.31-19-generic-pae. The receiver is a non-descript machine with a
Gigabit Ethernet interface and is not really important for my question.
We disabled connection tracking (because the packets are UDP) on the
bridge as follows:

# iptables -t raw -nL
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination        
NOTRACK    all  --  0.0.0.0/0            0.0.0.0/0          

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination        
NOTRACK    all  --  0.0.0.0/0            0.0.0.0/0          

We used brctl to make a bridge between eth3 and eth4 (even though we
don't have a eth[0,1,2]):

# brctl show
bridge name    bridge id        STP enabled    interfaces
br1        8000.001517b30cb3    no        eth3
                            eth4

Even without hashlimit activated we noticed a few packet drops (~50 pps)
on the receiving interface of the bridge. Generating keyboard interrupts
(by switching tty's or just typing) would make the amount of packet
drops increase, sometimes even up to a ~1000 pps, while the load average
remained around 0.00. The sending interface did not show any packet drops.

Because one of the NICs is using the e1000 driver and the other the
e1000e driver and the whole machine is just a bridge anyway, we decided
to switch the cables around, but to no avail. Both NICs showed the same
problem.

I'm wondering if we've reached the limits of our hardware or if there
are ways to tweak it a little bit. Our goal is to be able to process
twice the amount (~800,000 pps) without any drops. Once we're able to do
that, we should be able to test the hashlimit module for our needs. Does
anyone have any ideas on what we should look into? How can I figure out
if this is a hardware limit? And if so, what kind of hardware do I need
to make this work? Theoretically a Gigabit Ethernet NIC should be able
to process a lot more (since 410k * 52 bytes * 8 bits is much smaller
than 1 Gigabit).

I hope someone is able to help me. If there's any additional testing
required then please tell me.

Thanks in advance!

Regards,

Jorrit Kronjee

Oh, by the way, here is some information about the bridge:

# ethtool -i eth3
driver: e1000
version: 7.3.21-k3-NAPI
firmware-version: N/A
bus-info: 0000:04:02.0

# ethtool -i eth4
driver: e1000e
version: 1.1.2.1a-NAPI
firmware-version: 1.3-0
bus-info: 0000:00:19.0

# lspci
00:00.0 Host bridge: Intel Corporation 3200/3210 Chipset DRAM Controller
00:01.0 PCI bridge: Intel Corporation 3200/3210 Chipset Host-Primary PCI
Express Bridge
00:19.0 Ethernet controller: Intel Corporation 82566DM-2 Gigabit Network
Connection (rev 02)
00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
Controller #4 (rev 02)
00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
Controller #5 (rev 02)
00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI
Controller #2 (rev 02)
00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 1 (rev 02)
00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 5 (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
Controller #3 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI
Controller #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
00:1f.0 ISA bridge: Intel Corporation 82801IR (ICH9R) LPC Interface
Controller (rev 02)
00:1f.2 IDE interface: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 4
port SATA IDE Controller (rev 02)
00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller
(rev 02)
00:1f.5 IDE interface: Intel Corporation 82801I (ICH9 Family) 2 port
SATA IDE Controller (rev 02)
01:00.0 RAID bus controller: Areca Technology Corp. Unknown device 1201
03:00.0 VGA compatible controller: Matrox Graphics, Inc. MGA G200e
[Pilot] ServerEngines (SEP1) (rev 02)
04:02.0 Ethernet controller: Intel Corporation 82541GI Gigabit Ethernet
Controller (rev 05)

# ethtool -S eth3
NIC statistics:
     rx_packets: 2053904136
     tx_packets: 136751343
     rx_bytes: 131449844380
     tx_bytes: 8752131643
     rx_broadcast: 29
     tx_broadcast: 374
     rx_multicast: 2635
     tx_multicast: 261
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 2635
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 1263333
     rx_missed_errors: 242487
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     tx_timeout_count: 2
     tx_restart_queue: 628451
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 131449844380
     rx_csum_offload_good: 0
     rx_csum_offload_errors: 0
     rx_header_split: 0
     alloc_rx_buff_failed: 0
     tx_smbus: 0
     rx_smbus: 0
     dropped_smbus: 0

# ethtool -S eth4
NIC statistics:
     rx_packets: 154443470
     tx_packets: 2050030020
     rx_bytes: 9884436894
     tx_bytes: 131201969861
     rx_broadcast: 392
     tx_broadcast: 29
     rx_multicast: 310
     tx_multicast: 2596
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 310
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 4825441
     rx_missed_errors: 14717022
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     tx_timeout_count: 0
     tx_restart_queue: 18404766
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 9884436894
     rx_csum_offload_good: 0
     rx_csum_offload_errors: 0
     rx_header_split: 0
     alloc_rx_buff_failed: 0
     tx_smbus: 0
     rx_smbus: 0
     dropped_smbus: 0
     rx_dma_failed: 0
     tx_dma_failed: 0





