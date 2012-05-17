From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Thu, 17 May 2012 16:42:33 +0300
Message-ID: <88c43001441945e1431609db252b69e7@visp.net.lb>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>,
	<jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<therbert@google.com>, <eric.dumazet@gmail.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:39830 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965074Ab2EQNmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 09:42:52 -0400
In-Reply-To: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found commit that cause problem:

author	Tom Herbert <therbert@google.com>
Mon, 28 Nov 2011 16:33:16 +0000 (16:33 +0000)
committer	David S. Miller <davem@davemloft.net>
Tue, 29 Nov 2011 17:46:19 +0000 (12:46 -0500)
commit	3f0cfa3bc11e7f00c9994e0f469cbc0e7da7b00c
tree	d6670a4f94b2b9dedacc38edb6f0e1306b889f6b	tree | snapshot
parent	114cf5802165ee93e3ab461c9c505cd94a08b800	commit | diff
e1000e: Support for byte queue limits

Changes to e1000e to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

If i reverse it, problem disappearing.

How i reproduce it:
In two consoles do "fast" ping to nearby host
ping 194.146.XXX.XXX -s1472 -i0.0001
ping 194.146.XXX.XXX -s1472 -i0.1

For third open ssh to host with "problem", open mcedit, and just scroll 
down large text file.
After few seconds some "stalls" will occur, and in ping history i can 
see:
1480 bytes from 194.146.153.7: icmp_req=1797 ttl=64 time=0.161 ms
1480 bytes from 194.146.153.7: icmp_req=1798 ttl=64 time=0.198 ms
1480 bytes from 194.146.153.7: icmp_req=1799 ttl=64 time=0.340 ms
1480 bytes from 194.146.153.7: icmp_req=1800 ttl=64 time=0.381 ms
1480 bytes from 194.146.153.7: icmp_req=1801 ttl=64 time=914 ms
1480 bytes from 194.146.153.7: icmp_req=1802 ttl=64 time=804 ms
1480 bytes from 194.146.153.7: icmp_req=1803 ttl=64 time=704 ms
1480 bytes from 194.146.153.7: icmp_req=1804 ttl=64 time=594 ms
1480 bytes from 194.146.153.7: icmp_req=1805 ttl=64 time=0.287 ms
1480 bytes from 194.146.153.7: icmp_req=1806 ttl=64 time=0.226 ms


If i apply small patch - problem will disappear. Sure it is not a 
solution, but
let me know how i can help to debug problem more.

--- netdev.c    2012-05-12 20:08:37.000000000 +0300
+++ netdev.c.patched    2012-05-17 16:32:28.895760472 +0300
@@ -1135,7 +1135,7 @@

         tx_ring->next_to_clean = i;

-       netdev_completed_queue(netdev, pkts_compl, bytes_compl);
+//     netdev_completed_queue(netdev, pkts_compl, bytes_compl);

  #define TX_WAKE_THRESHOLD 32
         if (count && netif_carrier_ok(netdev) &&
@@ -2263,7 +2263,7 @@
                 e1000_put_txbuf(adapter, buffer_info);
         }

-       netdev_reset_queue(adapter->netdev);
+//     netdev_reset_queue(adapter->netdev);
         size = sizeof(struct e1000_buffer) * tx_ring->count;
         memset(tx_ring->buffer_info, 0, size);

@@ -5056,7 +5056,7 @@
         /* if count is 0 then mapping error has occurred */
         count = e1000_tx_map(adapter, skb, first, max_per_txd, 
nr_frags, mss);
         if (count) {
-               netdev_sent_queue(netdev, skb->len);
+//             netdev_sent_queue(netdev, skb->len);
                 e1000_tx_queue(adapter, tx_flags, count);
                 /* Make sure there is space in the ring for the next 
send. */
                 e1000_maybe_stop_tx(netdev, MAX_SKB_FRAGS + 2);



On 2012-05-15 17:15, Denys Fedoryshchenko wrote:
> Hi
>
> I have two identical servers, Sun Fire X4150, both has different
> flavors of Linux, x86_64 and i386.
> 04:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
> Ethernet Controller (Copper) (rev 01)
> 04:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
> Ethernet Controller (Copper) (rev 01)
> 0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit
> Ethernet Controller (rev 06)
> 0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit
> Ethernet Controller (rev 06)
> I am using now interface:
> #ethtool -i eth0
> driver: e1000e
> version: 1.9.5-k
> firmware-version: 2.1-11
> bus-info: 0000:04:00.0
> There is 2 CPU , Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz .
>
> i386 was acting as NAT and shaper, and as soon as i removed shaper
> from it, i started to experience strange lockups, e.g. traffic is
> normal for 5-30 seconds, then short lockup for 500-3000ms (usually
> around 1000ms) with dropped packets counter increasing. I was
> suspecting it is due load, but it seems was wrong.
> Recently, on another server, x86_64 i am using as development, i
> upgrade kernel (it was old, from 2.6 series) and on completely idle
> machine started to experience same latency spikes, while i am just
> running mc and for example typing in text editor - i notice "stalls".
> After i investigate it a little more, i notice also small amount of
> drops on interface. No tcpdump running. Also this machine is idle, 
> and
> the only traffic there - some small broadcasts from network, my ssh,
> and ping.
>
> Dropped packets in ifconfig
>           RX packets:3752868 errors:0 dropped:5350 overruns:0 frame:0
> Counter is increasing sometimes, when this stall happening.
>
> ethtool -S is clean, there is no dropped packets.
>
> I did tried to check load (mpstat and perf), there is nothing
> suspicious, latencytop also doesn't show anything suspicious.
> dropwatch report a lot of drops, but mostly because there is some
> broadcasts and etc. tcpdump at the moment of such drops doesn't show
> anything suspicious.
> Changed qdisc from default fifo_fast to bfifo, without any result.
> Tried:  ethtool -K eth0 tso off gso off gro off sg off , no result
> Problem occured at 3.3.6 - 3.4.0-rc7, most probably 3.3.0 also, but i
> don't remember for sure. I thik on some kernels like 3.1 probably it
> doesn't occur, i will check it soon, because it is not always 
> reliable
> to reproduce it. All tests i did on 3.4.0-rc7.
>
> I did run also in background tcpdump, additionally iptables with
> timestamps, and at time when stall occured, seems i am still 
> receiving
> packets properly, also on iperf udp  (from some host to this SunFire)
> at this moments no packets missing. But i am sure RX interface errors
> are increasing.
> If i do iperf from SunFire to test host - there is packetloss at
> moments when stall occured.
>
> I suspect that by some reason network card stop to transmit, but
> unable to pinpoint issue. All other hosts in this network are fine 
> and
> don't have such problems.
> Can you help me with that please? Maybe i can provide more debug
> information, compile with patches and etc. Also i will try to 
> fallback
> to 3.1 and 3.0 kernels.
>
> Here it is how it occurs and i am reproducing it:
> I'm just opening file, and start to scroll it in mc, then in another
> console i run ping
> [1337089061.844167] 1480 bytes from 194.146.153.20: icmp_req=162
> ttl=64 time=0.485 ms
> [1337089061.944138] 1480 bytes from 194.146.153.20: icmp_req=163
> ttl=64 time=0.470 ms
> [1337089062.467759] 1480 bytes from 194.146.153.20: icmp_req=164
> ttl=64 time=424 ms
> [1337089062.467899] 1480 bytes from 194.146.153.20: icmp_req=165
> ttl=64 time=324 ms
> [1337089062.468058] 1480 bytes from 194.146.153.20: icmp_req=166
> ttl=64 time=214 ms
> [1337089062.468161] 1480 bytes from 194.146.153.20: icmp_req=167
> ttl=64 time=104 ms
> [1337089062.468958] 1480 bytes from 194.146.153.20: icmp_req=168
> ttl=64 time=1.15 ms
> [1337089062.568604] 1480 bytes from 194.146.153.20: icmp_req=169
> ttl=64 time=0.477 ms
> [1337089062.668909] 1480 bytes from 194.146.153.20: icmp_req=170
> ttl=64 time=0.667 ms
>
> Remote host tcpdump:
> 1337089061.934737 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 163, length 1480
> 1337089062.458360 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 164, length 1480
> 1337089062.458380 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 164, length 1480
> 1337089062.458481 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 165, length 1480
> 1337089062.458502 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 165, length 1480
> 1337089062.458606 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 166, length 1480
> 1337089062.458623 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 166, length 1480
> 1337089062.458729 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 167, length 1480
> 1337089062.458745 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 167, length 1480
> 1337089062.459537 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 168, length 1480
> 1337089062.459545 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 168, length 1480
>
> Local host(SunFire) tcpdump:
> 1337089061.844140 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 162, length 1480
> 1337089061.943661 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 163, length 1480
> 1337089061.944124 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 163, length 1480
> 1337089062.465622 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 164, length 1480
> 1337089062.465630 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 165, length 1480
> 1337089062.465632 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 166, length 1480
> 1337089062.465634 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 167, length 1480
> 1337089062.467730 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 164, length 1480
> 1337089062.467785 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 168, length 1480
> 1337089062.467884 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 165, length 1480
> 1337089062.468035 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 166, length 1480
> 1337089062.468129 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 167, length 1480
> 1337089062.468928 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 168, length 1480
> 1337089062.568112 IP 194.146.153.22 > 194.146.153.20: ICMP echo
> request, id 3486, seq 169, length 1480
> 1337089062.568578 IP 194.146.153.20 > 194.146.153.22: ICMP echo
> reply, id 3486, seq 169, length 1480
>
> lspci -t
> centaur src # lspci -t
> -[0000:00]-+-00.0
>            +-02.0-[01-05]--+-00.0-[02-04]--+-00.0-[03]--
>            |               |               \-02.0-[04]--+-00.0
>            |               |                            \-00.1
>            |               \-00.3-[05]--
>            +-03.0-[06]--
>            +-04.0-[07]----00.0
>            +-05.0-[08]--
>            +-06.0-[09]--
>            +-07.0-[0a]--
>            +-08.0
>            +-10.0
>            +-10.1
>            +-10.2
>            +-11.0
>            +-13.0
>            +-15.0
>            +-16.0
>            +-1c.0-[0b]--+-00.0
>            |            \-00.1
>            +-1d.0
>            +-1d.1
>            +-1d.2
>            +-1d.3
>            +-1d.7
>            +-1e.0-[0c]----05.0
>            +-1f.0
>            +-1f.1
>            +-1f.2
>            \-1f.3
> lspci
> 00:00.0 Host bridge: Intel Corporation 5000P Chipset Memory
> Controller Hub (rev b1)
> 00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
> x4 Port 2 (rev b1)
> 00:03.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
> x4 Port 3 (rev b1)
> 00:04.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
> x8 Port 4-5 (rev b1)
> 00:05.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
> x4 Port 5 (rev b1)
> 00:06.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
> x8 Port 6-7 (rev b1)
> 00:07.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
> x4 Port 7 (rev b1)
> 00:08.0 System peripheral: Intel Corporation 5000 Series Chipset DMA
> Engine (rev b1)
> 00:10.0 Host bridge: Intel Corporation 5000 Series Chipset FSB
> Registers (rev b1)
> 00:10.1 Host bridge: Intel Corporation 5000 Series Chipset FSB
> Registers (rev b1)
> 00:10.2 Host bridge: Intel Corporation 5000 Series Chipset FSB
> Registers (rev b1)
> 00:11.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved
> Registers (rev b1)
> 00:13.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved
> Registers (rev b1)
> 00:15.0 Host bridge: Intel Corporation 5000 Series Chipset FBD
> Registers (rev b1)
> 00:16.0 Host bridge: Intel Corporation 5000 Series Chipset FBD
> Registers (rev b1)
> 00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset
> PCI Express Root Port 1 (rev 09)
> 00:1d.0 USB controller: Intel Corporation 631xESB/632xESB/3100
> Chipset UHCI USB Controller #1 (rev 09)
> 00:1d.1 USB controller: Intel Corporation 631xESB/632xESB/3100
> Chipset UHCI USB Controller #2 (rev 09)
> 00:1d.2 USB controller: Intel Corporation 631xESB/632xESB/3100
> Chipset UHCI USB Controller #3 (rev 09)
> 00:1d.3 USB controller: Intel Corporation 631xESB/632xESB/3100
> Chipset UHCI USB Controller #4 (rev 09)
> 00:1d.7 USB controller: Intel Corporation 631xESB/632xESB/3100
> Chipset EHCI USB2 Controller (rev 09)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9)
> 00:1f.0 ISA bridge: Intel Corporation 631xESB/632xESB/3100 Chipset
> LPC Interface Controller (rev 09)
> 00:1f.1 IDE interface: Intel Corporation 631xESB/632xESB IDE
> Controller (rev 09)
> 00:1f.2 SATA controller: Intel Corporation 631xESB/632xESB SATA AHCI
> Controller (rev 09)
> 00:1f.3 SMBus: Intel Corporation 631xESB/632xESB/3100 Chipset SMBus
> Controller (rev 09)
> 01:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
> Upstream Port (rev 01)
> 01:00.3 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express to
> PCI-X Bridge (rev 01)
> 02:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
> Downstream Port E1 (rev 01)
> 02:02.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
> Downstream Port E3 (rev 01)
> 04:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
> Ethernet Controller (Copper) (rev 01)
> 04:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
> Ethernet Controller (Copper) (rev 01)
> 07:00.0 RAID bus controller: Adaptec AAC-RAID (rev 09)
> 0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit
> Ethernet Controller (rev 06)
> 0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit
> Ethernet Controller (rev 06)
> 0c:05.0 VGA compatible controller: ASPEED Technology, Inc. ASPEED
> Graphics Family
>
>
> dmesg:
> [    4.936885] e1000: Intel(R) PRO/1000 Network Driver - version
> 7.3.21-k8-NAPI
> [    4.936887] e1000: Copyright (c) 1999-2006 Intel Corporation.
> [    4.936966] e1000e: Intel(R) PRO/1000 Network Driver - 1.9.5-k
> [    4.936967] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
> [    4.938529] e1000e 0000:04:00.0: (unregistered net_device):
> Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
> [    4.939598] e1000e 0000:04:00.0: irq 65 for MSI/MSI-X
> [    4.992246] e1000e 0000:04:00.0: eth0: (PCI Express:2.5GT/s:Width
> x4) 00:1e:68:04:99:f8
> [    4.992657] e1000e 0000:04:00.0: eth0: Intel(R) PRO/1000 Network
> Connection
> [    4.992964] e1000e 0000:04:00.0: eth0: MAC: 5, PHY: 5, PBA No: 
> FFFFFF-0FF
> [    4.994745] e1000e 0000:04:00.1: (unregistered net_device):
> Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
> [    4.996233] e1000e 0000:04:00.1: irq 66 for MSI/MSI-X
> [    5.050901] e1000e 0000:04:00.1: eth1: (PCI Express:2.5GT/s:Width
> x4) 00:1e:68:04:99:f9
> [    5.051317] e1000e 0000:04:00.1: eth1: Intel(R) PRO/1000 Network
> Connection
> [    5.051623] e1000e 0000:04:00.1: eth1: MAC: 5, PHY: 5, PBA No: 
> FFFFFF-0FF
> [    5.051857] e1000e 0000:0b:00.0: Disabling ASPM  L1
> [    5.052168] e1000e 0000:0b:00.0: (unregistered net_device):
> Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
> [    5.052611] e1000e 0000:0b:00.0: irq 67 for MSI/MSI-X
> [    5.223454] e1000e 0000:0b:00.0: eth2: (PCI Express:2.5GT/s:Width
> x4) 00:1e:68:04:99:fa
> [    5.223864] e1000e 0000:0b:00.0: eth2: Intel(R) PRO/1000 Network
> Connection
> [    5.224178] e1000e 0000:0b:00.0: eth2: MAC: 0, PHY: 4, PBA No: 
> C83246-002
> [    5.224412] e1000e 0000:0b:00.1: Disabling ASPM  L1
> [    5.224709] e1000e 0000:0b:00.1: (unregistered net_device):
> Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
> [    5.225168] e1000e 0000:0b:00.1: irq 68 for MSI/MSI-X
> [    5.397603] e1000e 0000:0b:00.1: eth3: (PCI Express:2.5GT/s:Width
> x4) 00:1e:68:04:99:fb
> [    5.398021] e1000e 0000:0b:00.1: eth3: Intel(R) PRO/1000 Network
> Connection
> [    5.398336] e1000e 0000:0b:00.1: eth3: MAC: 0, PHY: 4, PBA No: 
> C83246-002
> [   13.859817] e1000e 0000:04:00.0: irq 65 for MSI/MSI-X
> [   13.962309] e1000e 0000:04:00.0: irq 65 for MSI/MSI-X
> [   17.150392] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex,
> Flow Control: None
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

---
Network engineer
Denys Fedoryshchenko

Dora Highway - Center Cebaco - 2nd Floor
Beirut, Lebanon
Tel:	+961 1 247373
E-Mail: denys@visp.net.lb
