From: Tony Battersby <tonyb@cybernetics.com>
Subject: BUG: sky2: hw csum failure with dual-port copper NIC on SMP
Date: Tue, 13 Nov 2007 12:51:33 -0500
Message-ID: <4739E425.20408@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: shemminger@linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host06.cybernetics.com ([206.246.200.22]:2303 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754595AbXKMSUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 13:20:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am getting "hw csum failure" messages with sky2.  I have seen this
problem reported elsewhere with a fibre NIC, but I am using a copper
NIC.  It seems to be triggered by SMP.  It is easy to reproduce in
2.6.23.  2.6.24-rc2-git3 still has the problem, but it happens less
frequently.

To reproduce the problem, I am using a simple network benchmark program
that I wrote that basically does send()/recv() as fast as possible using
a memory buffer (null data, no disk I/O, no data integrity checking).
The computer with the SysKonnect NIC acts as the server.  I have two
other computers with Intel PRO/1000 NICs that are directly cabled to the
two ports on the SysKonnect NIC.  Each of them runs the client program,
which connects to the server, send()s 10 GB, and then recv()s 10 GB.
Essentially, both ports on the Syskonnect NIC are receiving at the
maximum rate for a few minutes, and then transmitting at the maximum
rate for a few minutes.  Sustained throughput is about 117 MB/s on both
ports simultaneously.

The "hw csum failure" does not seem to affect the test.  send()/recv()
continue to work normally.  Nothing locks up.

I get several "hw csum failure" messages per minute on 2.6.23-SMP.  The
error does not happen with 2.6.23 if I boot with "max_cpus=1".  The
message seems less frequent with 2.6.24-SMP, but it still happens once
every minute or so.

The "hw csum failure" message does not happen when only one port is in
use.  You have to stress both ports simultaneously to reproduce the
problem.

Another cosmetic issue is that "ifconfig" shows eth2 at IRQ 16 and eth3
at IRQ 218, when in fact both are at IRQ 218.  IRQ 16 is the regular
interrupt line and IRQ 218 is the MSI interrupt.  I imagine that the
driver is just reporting the IRQ incorrectly in this case.  It is just a
minor cosmetic issue which doesn't break anything.

Let me know if I can be of any further assistance in tracking down this
problem.

NIC: Syskonnect SK-9E22 dual-port copper PCI-express
motherboard: SuperMicro PDSME
CPU: Pentium D 945 (dual-core 3.4 GHz)
kernel versions: 2.6.23 and 2.6.24-rc2-git3

All information below is from 2.6.24-rc2-git3.

portion of dmesg showing error:
<unknown>: hw csum failure.
 [<c02c0910>] skb_copy_and_csum_datagram_iovec+0x120/0x130
 [<c0180913>] __set_page_dirty+0x83/0x140
 [<c02ef2c1>] tcp_rcv_established+0x981/0x9a0
 [<c02f6490>] tcp_v4_do_rcv+0xc0/0x370
 [<c02ba042>] release_sock+0x12/0xa0
 [<c02bb0f1>] sk_wait_data+0xa1/0xd0
 [<c02e3ef8>] tcp_prequeue_process+0x48/0x70
 [<c02e4ea1>] tcp_recvmsg+0x671/0xc50
 [<c0117bc3>] enqueue_task_fair+0x73/0xb0
 [<c02ba305>] sock_common_recvmsg+0x45/0x70
 [<c02b98d8>] sock_recvmsg+0xd8/0x130
 [<c012eef0>] autoremove_wake_function+0x0/0x50
 [<c0120d62>] __do_softirq+0x82/0x100
 [<c0120f12>] irq_exit+0x52/0x90
 [<c010f6b4>] smp_apic_timer_interrupt+0x54/0x80
 [<c02b9c6b>] sys_recvfrom+0xeb/0x180
 [<c0111cea>] read_hpet+0xa/0x10
 [<c01347f0>] getnstimeofday+0x40/0xf0
 [<c0118c20>] rebalance_domains+0x110/0x3e0
 [<c02b9d33>] sys_recv+0x33/0x40
 [<c02b9ea5>] sys_socketcall+0x165/0x280
 [<c0102a4e>] sysenter_past_esp+0x5f/0x85
 =======================

dmesg | grep sky2
sky2 0000:04:00.0: v1.20 addr 0xea300000 irq 16 Yukon-XL (0xb3) rev 1
sky2 0000:04:00.0: PCI Express Advanced Error Reporting not configured or MMCONFIG problem?
sky2 eth2: addr 00:00:5a:72:b8:91
sky2 eth3: addr 00:00:5a:72:b8:92
sky2 eth2: enabling interface
sky2 eth3: enabling interface
sky2 eth2: Link is up at 1000 Mbps, full duplex, flow control both
sky2 eth3: Link is up at 1000 Mbps, full duplex, flow control both

ifconfig
eth2      Link encap:Ethernet  HWaddr 00:00:5A:72:B8:91  
          inet addr:192.168.1.10  Bcast:192.168.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:34910877 errors:0 dropped:0 overruns:0 frame:0
          TX packets:22659597 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:3207874526 (2.9 GiB)  TX bytes:2888042042 (2.6 GiB)
          Interrupt:16 

eth3      Link encap:Ethernet  HWaddr 00:00:5A:72:B8:92  
          inet addr:137.157.10.224  Bcast:137.157.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:34902414 errors:0 dropped:0 overruns:0 frame:0
          TX packets:22641940 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:3207442696 (2.9 GiB)  TX bytes:2886952355 (2.6 GiB)
          Interrupt:218 

ethtool -i eth2
driver: sky2
version: 1.20
firmware-version: N/A
bus-info: 0000:04:00.0

ethtool eth2
Settings for eth2:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pg
	Wake-on: d
	Current message level: 0x000000ff (255)
	Link detected: yes

ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on

ethtool -S eth2
NIC statistics:
     tx_bytes: 33946810766
     rx_bytes: 33901041384
     tx_broadcast: 0
     rx_broadcast: 1
     tx_multicast: 0
     rx_multicast: 0
     tx_unicast: 35564726
     rx_unicast: 34910876
     tx_mac_pause: 0
     rx_mac_pause: 0
     collisions: 0
     late_collision: 0
     aborted: 0
     single_collisions: 0
     multi_collisions: 0
     rx_short: 0
     rx_runt: 0
     rx_64_byte_packets: 13
     rx_65_to_127_byte_packets: 13166182
     rx_128_to_255_byte_packets: 5
     rx_256_to_511_byte_packets: 6049
     rx_512_to_1023_byte_packets: 23940
     rx_1024_to_1518_byte_packets: 21714688
     rx_1518_to_max_byte_packets: 0
     rx_too_long: 0
     rx_fifo_overflow: 0
     rx_jabber: 0
     rx_fcs_error: 0
     tx_64_byte_packets: 13
     tx_65_to_127_byte_packets: 10811129
     tx_128_to_255_byte_packets: 873915
     tx_256_to_511_byte_packets: 955169
     tx_512_to_1023_byte_packets: 2245568
     tx_1024_to_1518_byte_packets: 20678932
     tx_1519_to_max_byte_packets: 0
     tx_fifo_underrun: 0

ethtool -i eth3
driver: sky2
version: 1.20
firmware-version: N/A
bus-info: 0000:04:00.0

ethtool eth3
Settings for eth3:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pg
	Wake-on: d
	Current message level: 0x000000ff (255)
	Link detected: yes

ethtool -k eth3
Offload parameters for eth3:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on

ethtool -S eth3
NIC statistics:
     tx_bytes: 33948750825
     rx_bytes: 33900457220
     tx_broadcast: 0
     rx_broadcast: 137
     tx_multicast: 0
     rx_multicast: 0
     tx_unicast: 35591358
     rx_unicast: 34902277
     tx_mac_pause: 0
     rx_mac_pause: 0
     collisions: 31
     late_collision: 0
     aborted: 0
     single_collisions: 29
     multi_collisions: 1
     rx_short: 0
     rx_runt: 0
     rx_64_byte_packets: 64
     rx_65_to_127_byte_packets: 13151060
     rx_128_to_255_byte_packets: 23
     rx_256_to_511_byte_packets: 7867
     rx_512_to_1023_byte_packets: 36713
     rx_1024_to_1518_byte_packets: 21706687
     rx_1518_to_max_byte_packets: 0
     rx_too_long: 0
     rx_fifo_overflow: 0
     rx_jabber: 0
     rx_fcs_error: 0
     tx_64_byte_packets: 21
     tx_65_to_127_byte_packets: 10750614
     tx_128_to_255_byte_packets: 945463
     tx_256_to_511_byte_packets: 1004551
     tx_512_to_1023_byte_packets: 2153163
     tx_1024_to_1518_byte_packets: 20737546
     tx_1519_to_max_byte_packets: 0
     tx_fifo_underrun: 0

cat /proc/interrupts
           CPU0       CPU1       
  0:         89          0   IO-APIC-edge      timer
  1:        207          0   IO-APIC-edge      i8042
  7:          0          0   IO-APIC-edge      parport0
  8:          3          0   IO-APIC-edge      rtc
  9:          0          0   IO-APIC-fasteoi   acpi
 12:          5          0   IO-APIC-edge      i8042
 14:        784          0   IO-APIC-edge      ide0
 16:          0          0   IO-APIC-fasteoi   uhci_hcd:usb5
 18:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 19:          0          0   IO-APIC-fasteoi   uhci_hcd:usb3
 20:          0          0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb2
218:    4482759    4446537   PCI-MSI-edge      eth2
219:          0          0   PCI-MSI-edge      ahci
NMI:          0          0   Non-maskable interrupts
LOC:      65542      48825   Local timer interrupts
RES:        226         59   Rescheduling interrupts
CAL:         80         60   function call interrupts
TLB:         22         52   TLB shootdowns
TRM:          0          0   Thermal event interrupts
SPU:          0          0   Spurious interrupts
ERR:          0
MIS:          0

lspci -vv
04:00.0 0200: 1148:9e00 (rev 14)
04:00.0 Ethernet controller: SysKonnect SK-9Exx 10/100/1000Base-T Adapter (rev 14)
	Subsystem: SysKonnect SK-9E22 Server Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size 08
	Interrupt: pin A routed to IRQ 218
	Region 0: Memory at ea300000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 8000 [size=256]
	[virtual] Expansion ROM at ea320000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0200c  Data: 413a
	Capabilities: [e0] Express Legacy Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr+ NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s, Port 0
		Link: Latency L0s <256ns, L1 unlimited
		Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x4



