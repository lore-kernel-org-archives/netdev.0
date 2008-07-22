From: Vlad Seliverstov <vseliverstov@yandex-team.ru>
Subject: Huge packet loss on Intel 80003ES2LAN
Date: Tue, 22 Jul 2008 14:34:06 +0400
Message-ID: <4885B79E.8060704@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavolo.yandex.ru ([87.250.244.45]:21428 "EHLO cavolo.yandex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855AbYGVKmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 06:42:42 -0400
Received: from [87.250.250.12] (behemot.yandex.ru [87.250.250.12])
	by cavolo.yandex.ru (8.14.2/8.14.2) with ESMTP id m6MAYHFn094531
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 14:34:17 +0400 (MSD)
	(envelope-from vseliverstov@yandex-team.ru)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Recently, I moved my heavily network-loaded server under Ubuntu Hardy to a box with two 80003ES2LAN onboard NICs and began to experience problems with it. The problem is huge packet loss time to time.
Here are ping results from another server (which has address 192.168.0.2) in the same network segment:

for i in `seq 1 15`; do ping -i 0.01 -q -c 1000 192.168.0.1 | grep loss; done
1000 packets transmitted, 1000 received, 0% packet loss, time 9987ms
1000 packets transmitted, 1000 received, 0% packet loss, time 9987ms
1000 packets transmitted, 1000 received, 0% packet loss, time 9987ms
1000 packets transmitted, 940 received, 6% packet loss, time 10223ms
1000 packets transmitted, 649 received, 35% packet loss, time 11067ms
1000 packets transmitted, 745 received, 25% packet loss, time 10768ms
1000 packets transmitted, 831 received, 16% packet loss, time 10386ms
1000 packets transmitted, 879 received, 12% packet loss, time 10336ms
1000 packets transmitted, 956 received, 4% packet loss, time 10211ms
1000 packets transmitted, 575 received, 42% packet loss, time 11016ms
1000 packets transmitted, 578 received, 42% packet loss, time 12278ms
1000 packets transmitted, 840 received, 16% packet loss, time 15177ms
1000 packets transmitted, 1000 received, 0% packet loss, time 16081ms
1000 packets transmitted, 1000 received, 0% packet loss, time 16117ms
1000 packets transmitted, 1000 received, 0% packet loss, time 16107ms

When I dumped traffic on both 192.168.0.1 and 192.168.0.2, I saw both ICMP requests and replies on 192.168.0.1, but no replies on 192.168.0.2 - only requests. And there are no errors on ports on the switch either.
On this box, I use stock Ubuntu kernel with some specific patches applied, but I've got same effect on stock kernel without specific patches too.
I'm ran out of ideas where bug is.

Here is info about 192.168.0.1:

# uptime
 14:20:05 up 4 days, 16:42,  2 users,  load average: 1.21, 1.27, 1.04

# modinfo e1000 | grep ^version
version:        7.3.20-k2-NAPI

# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:30:48:7f:d8:b2  
          inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::230:48ff:fe7f:d8b2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:3344914241 errors:32 dropped:0 overruns:0 frame:32
          TX packets:4314444206 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:32768 
          RX bytes:310498517217 (289.1 GB)  TX bytes:5704710502103 (5.1 TB)
          Base address:0x2000 Memory:d8220000-d8240000

# mpstat 1
Linux 2.6.24-19-server (bsdb) 	07/22/2008

02:23:23 PM  CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
02:23:24 PM  all    0.49    0.00    1.73    0.12    0.00    0.00    0.00   97.65   1349.00
02:23:25 PM  all    0.71    0.00    1.79    0.36    0.00    0.00    0.00   97.14   2303.00
02:23:26 PM  all    2.46    0.00    4.68    0.12    0.00    0.35    0.00   92.39   3008.00
02:23:27 PM  all    4.75    0.00    3.17    0.12    0.00    1.34    0.00   90.62   5289.00
02:23:28 PM  all    6.55    0.00    6.80    0.00    0.13    1.16    0.00   85.37   3361.00
02:23:29 PM  all    6.89    0.00    5.93    0.12    0.00    2.06    0.00   85.01   4035.00
02:23:30 PM  all    1.38    0.00    1.00    0.00    0.00    2.01    0.00   95.61   4340.00
02:23:31 PM  all    7.26    0.00    5.27    0.00    0.00    1.41    0.00   86.07   6666.00
02:23:32 PM  all    3.86    0.00    1.43    0.00    0.00    5.01    0.00   89.70   4022.00
02:23:33 PM  all    6.56    0.00    2.60    0.25    0.12    0.50    0.00   89.98   6992.00
02:23:34 PM  all    5.30    0.00    5.30    0.00    0.00    1.51    0.00   87.89   4142.00
02:23:35 PM  all    0.00    0.00    2.03    0.00    0.00    1.90    0.00   96.07   4414.00
02:23:36 PM  all    1.15    0.00    0.69    0.00    0.23    0.23    0.00   97.70   7500.00
02:23:37 PM  all   14.27    0.00    1.55    0.12    0.00    0.48    0.00   83.59   8372.00
02:23:38 PM  all    7.05    0.00    5.93    0.12    0.00    1.73    0.00   85.17   6428.00

# ethtool -S eth0
NIC statistics:
     rx_packets: 3347723509
     tx_packets: 4318229743
     rx_bytes: 310756843576
     tx_bytes: 5709800262863
     rx_broadcast: 27179
     tx_broadcast: 2
     rx_multicast: 3625
     tx_multicast: 2
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 3625
     collisions: 0
     rx_length_errors: 32
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_missed_errors: 0
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
     tx_restart_queue: 50377745
     rx_long_length_errors: 32
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 224736008
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 310756843576
     rx_csum_offload_good: 3347466995
     rx_csum_offload_errors: 3
     rx_header_split: 0
     alloc_rx_buff_failed: 0
     tx_smbus: 0
     rx_smbus: 4
     dropped_smbus: 0

# ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:		4096
RX Mini:	0
RX Jumbo:	0
TX:		4096
Current hardware settings:
RX:		4096
RX Mini:	0
RX Jumbo:	0
TX:		4096

# lspci -n
00:00.0 0600: 8086:25d8 (rev b1)
00:02.0 0604: 8086:25f7 (rev b1)
00:04.0 0604: 8086:25f8 (rev b1)
00:06.0 0604: 8086:25f9 (rev b1)
00:08.0 0880: 8086:1a38 (rev b1)
00:10.0 0600: 8086:25f0 (rev b1)
00:10.1 0600: 8086:25f0 (rev b1)
00:10.2 0600: 8086:25f0 (rev b1)
00:11.0 0600: 8086:25f1 (rev b1)
00:13.0 0600: 8086:25f3 (rev b1)
00:15.0 0600: 8086:25f5 (rev b1)
00:16.0 0600: 8086:25f6 (rev b1)
00:1c.0 0604: 8086:2690 (rev 09)
00:1d.0 0c03: 8086:2688 (rev 09)
00:1d.1 0c03: 8086:2689 (rev 09)
00:1d.2 0c03: 8086:268a (rev 09)
00:1d.3 0c03: 8086:268b (rev 09)
00:1d.7 0c03: 8086:268c (rev 09)
00:1e.0 0604: 8086:244e (rev d9)
00:1f.0 0601: 8086:2670 (rev 09)
00:1f.1 0101: 8086:269e (rev 09)
00:1f.3 0c05: 8086:269b (rev 09)
01:00.0 0604: 8086:3500 (rev 01)
01:00.3 0604: 8086:350c (rev 01)
02:00.0 0604: 8086:3510 (rev 01)
02:02.0 0604: 8086:3518 (rev 01)
04:00.0 0200: 8086:1096 (rev 01)
04:00.1 0200: 8086:1096 (rev 01)
06:00.0 0100: 1000:0056 (rev 08)
08:00.0 0604: 8086:032c (rev 09)
0a:01.0 0300: 1002:515e (rev 02)

# cat /etc/sysctl.conf 

net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1

vm.vfs_cache_pressure = 100
vm.min_free_kbytes = 262144

net.core.rmem_default = 262144
net.core.rmem_max = 524288
net.core.wmem_default = 262144
net.core.wmem_max = 524288
net.core.optmem_max = 262144
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 65536

net.ipv4.tcp_max_tw_buckets = 65536
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 8
net.ipv4.tcp_rmem = 43690 174760 349520
net.ipv4.tcp_wmem = 32768 131072 262144
net.ipv4.tcp_mem = 262144 524288 1048576
net.ipv4.tcp_max_orphans = 16384
net.ipv4.tcp_fin_timeout = 60
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_syncookies = 0

net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.default.arp_ignore = 1
net.ipv4.conf.default.arp_announce = 2

# dmesg
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.24-19-server (root@bsub) (gcc version 4.2.3 (Ubuntu 4.2.3-2ubuntu7)) #1 SMP Wed Jul 16 17:30:15 MSD 2008 (Ubuntu 2.6.24-19.36+ya1-server)
[    0.000000] Command line: root=UUID=fd5bf9f2-4003-4ebf-84c1-79cff8c45362 ro splash
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009d000 (usable)
[    0.000000]  BIOS-e820: 000000000009d000 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000cc000 - 00000000000d4000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000cff60000 (usable)
[    0.000000]  BIOS-e820: 00000000cff60000 - 00000000cff69000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cff69000 - 00000000cff80000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000cff80000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000001000000000 (usable)
[    0.000000] Entering add_active_range(0, 0, 157) 0 entries of 3200 used
[    0.000000] Entering add_active_range(0, 256, 851808) 1 entries of 3200 used
[    0.000000] Entering add_active_range(0, 1048576, 16777216) 2 entries of 3200 used
[    0.000000] end_pfn_map = 16777216
[    0.000000] DMI present.
[    0.000000] ACPI: RSDP signature @ 0xFFFF8100000F6100 checksum 0
[    0.000000] ACPI: RSDP 000F6100, 0014 (r0 PTLTD )
[    0.000000] ACPI: RSDT CFF63321, 005C (r1 PTLTD    RSDT    6040000  LTP        0)
[    0.000000] ACPI: FACP CFF68E10, 0074 (r1 INTEL  TUMWATER  6040000 PTL         3)
[    0.000000] ACPI: DSDT CFF64E4F, 3FC1 (r1  Intel BLAKFORD  6040000 MSFT  100000E)
[    0.000000] ACPI: FACS CFF69FC0, 0040
[    0.000000] ACPI: APIC CFF68E84, 00C8 (r1 PTLTD  	 APIC    6040000  LTP        0)
[    0.000000] ACPI: MCFG CFF68F4C, 003C (r1 PTLTD    MCFG    6040000  LTP        0)
[    0.000000] ACPI: BOOT CFF68F88, 0028 (r1 PTLTD  $SBFTBL$  6040000  LTP        1)
[    0.000000] ACPI: SPCR CFF68FB0, 0050 (r1 PTLTD  $UCRTBL$  6040000 PTL         1)
[    0.000000] ACPI: SSDT CFF64BF0, 025F (r1  PmRef  Cpu0Tst     3000 INTL 20050228)
[    0.000000] ACPI: SSDT CFF64B4A, 00A6 (r1  PmRef  Cpu7Tst     3000 INTL 20050228)
[    0.000000] ACPI: SSDT CFF64AA4, 00A6 (r1  PmRef  Cpu6Tst     3000 INTL 20050228)
[    0.000000] ACPI: SSDT CFF649FE, 00A6 (r1  PmRef  Cpu5Tst     3000 INTL 20050228)
[    0.000000] ACPI: SSDT CFF64958, 00A6 (r1  PmRef  Cpu4Tst     3000 INTL 20050228)
[    0.000000] ACPI: SSDT CFF648B2, 00A6 (r1  PmRef  Cpu3Tst     3000 INTL 20050228)
[    0.000000] ACPI: SSDT CFF6480C, 00A6 (r1  PmRef  Cpu2Tst     3000 INTL 20050228)
[    0.000000] ACPI: SSDT CFF64766, 00A6 (r1  PmRef  Cpu1Tst     3000 INTL 20050228)
[    0.000000] ACPI: SSDT CFF6337D, 13E9 (r1  PmRef    CpuPm     3000 INTL 20050228)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-0000001000000000
[    0.000000] Entering add_active_range(0, 0, 157) 0 entries of 3200 used
[    0.000000] Entering add_active_range(0, 256, 851808) 1 entries of 3200 used
[    0.000000] Entering add_active_range(0, 1048576, 16777216) 2 entries of 3200 used
[    0.000000] Bootmem setup node 0 0000000000000000-0000001000000000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 -> 16777216
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0:        0 ->      157
[    0.000000]     0:      256 ->   851808
[    0.000000]     0:  1048576 -> 16777216
[    0.000000] On node 0 totalpages: 16580349
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 1385 pages reserved
[    0.000000]   DMA zone: 2556 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 833432 pages, LIFO batch:31
[    0.000000]   Normal zone: 215040 pages used for memmap
[    0.000000]   Normal zone: 15513600 pages, LIFO batch:31
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] Processor #0 (Bootup-CPU)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x04] enabled)
[    0.000000] Processor #4
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] Processor #1
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x05] enabled)
[    0.000000] Processor #5
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x02] enabled)
[    0.000000] Processor #2
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x06] enabled)
[    0.000000] Processor #6
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x03] enabled)
[    0.000000] Processor #3
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
[    0.000000] Processor #7
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec80000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, address 0xfec80000, GSI 24-47
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Setting APIC routing to flat
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] swsusp: Registered nosave memory region: 000000000009d000 - 00000000000a0000
[    0.000000] swsusp: Registered nosave memory region: 00000000000a0000 - 00000000000cc000
[    0.000000] swsusp: Registered nosave memory region: 00000000000cc000 - 00000000000d4000
[    0.000000] swsusp: Registered nosave memory region: 00000000000d4000 - 00000000000e4000
[    0.000000] swsusp: Registered nosave memory region: 00000000000e4000 - 0000000000100000
[    0.000000] swsusp: Registered nosave memory region: 00000000cff60000 - 00000000cff69000
[    0.000000] swsusp: Registered nosave memory region: 00000000cff69000 - 00000000cff80000
[    0.000000] swsusp: Registered nosave memory region: 00000000cff80000 - 00000000d0000000
[    0.000000] swsusp: Registered nosave memory region: 00000000d0000000 - 00000000e0000000
[    0.000000] swsusp: Registered nosave memory region: 00000000e0000000 - 00000000f0000000
[    0.000000] swsusp: Registered nosave memory region: 00000000f0000000 - 00000000fec00000
[    0.000000] swsusp: Registered nosave memory region: 00000000fec00000 - 00000000fec10000
[    0.000000] swsusp: Registered nosave memory region: 00000000fec10000 - 00000000fee00000
[    0.000000] swsusp: Registered nosave memory region: 00000000fee00000 - 00000000fee01000
[    0.000000] swsusp: Registered nosave memory region: 00000000fee01000 - 00000000ff000000
[    0.000000] swsusp: Registered nosave memory region: 00000000ff000000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at d1000000 (gap: d0000000:10000000)
[    0.000000] SMP: Allowing 8 CPUs, 0 hotplug CPUs
[    0.000000] PERCPU: Allocating 41952 bytes of per cpu data
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 16349588
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: root=UUID=fd5bf9f2-4003-4ebf-84c1-79cff8c45362 ro splash
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] TSC calibrated against PM_TIMER
[  101.286499] time.c: Detected 2833.429 MHz processor.
[  101.288561] Console: colour VGA+ 80x25
[  101.288565] console [tty0] enabled
[  101.294865] Checking aperture...
[  101.294922] Calgary: detecting Calgary via BIOS EBDA area
[  101.294924] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[  101.294925] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[  101.320745] Placing software IO TLB between 0x1096000 - 0x5096000
[  101.747550] Memory: 65324148k/67108864k available (2523k kernel code, 997248k reserved, 1335k data, 328k init)
[  101.747659] SLUB: Genslabs=12, HWalign=64, Order=0-1, MinObjects=4, CPUs=8, Nodes=1
[  101.895823] Calibrating delay using timer specific routine.. 5670.09 BogoMIPS (lpj=28350476)
[  101.895953] Security Framework initialized
[  101.896011] SELinux:  Disabled at boot.
[  101.896073] AppArmor: AppArmor initialized
[  101.896127] Failure registering capabilities with primary security module.
[  101.899865] Dentry cache hash table entries: 8388608 (order: 14, 67108864 bytes)
[  101.927464] Inode-cache hash table entries: 4194304 (order: 13, 33554432 bytes)
[  101.940290] Mount-cache hash table entries: 256
[  101.940465] Initializing cgroup subsys ns
[  101.940522] Initializing cgroup subsys cpuacct
[  101.940589] CPU: L1 I cache: 32K, L1 D cache: 32K
[  101.940673] CPU: L2 cache: 6144K
[  101.940724] CPU 0/0 -> Node 0
[  101.940774] using mwait in idle threads.
[  101.940826] CPU: Physical Processor ID: 0
[  101.940877] CPU: Processor Core ID: 0
[  101.940932] CPU0: Thermal monitoring handled by SMI
[  101.940943] SMP alternatives: switching to UP code
[  101.941770] Early unpacking initramfs... done
[  102.189089] ACPI: Core revision 20070126
[  102.189174] ACPI: Looking for DSDT in initramfs... error, file /DSDT.aml not found.
[  102.310002] Using local APIC timer interrupts.
[  102.345311] APIC timer calibration result 20834050
[  102.345312] Detected 20.834 MHz APIC timer.
[  102.345444] SMP alternatives: switching to SMP code
[  102.346187] Booting processor 1/8 APIC 0x4
[  102.356820] Initializing CPU#1
[  102.505197] Calibrating delay using timer specific routine.. 5666.96 BogoMIPS (lpj=28334841)
[  102.505204] CPU: L1 I cache: 32K, L1 D cache: 32K
[  102.505204] CPU: L2 cache: 6144K
[  102.505206] CPU 1/4 -> Node 0
[  102.505207] CPU: Physical Processor ID: 1
[  102.505208] CPU: Processor Core ID: 0
[  102.505213] CPU1: Thermal monitoring enabled (TM2)
[  102.505902] Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz stepping 06
[  102.506005] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[  102.526618] SMP alternatives: switching to SMP code
[  102.527061] Booting processor 2/8 APIC 0x1
[  102.537697] Initializing CPU#2
[  102.684998] Calibrating delay using timer specific routine.. 5666.94 BogoMIPS (lpj=28334704)
[  102.685004] CPU: L1 I cache: 32K, L1 D cache: 32K
[  102.685005] CPU: L2 cache: 6144K
[  102.685007] CPU 2/1 -> Node 0
[  102.685008] CPU: Physical Processor ID: 0
[  102.685009] CPU: Processor Core ID: 1
[  102.685014] CPU2: Thermal monitoring enabled (TM2)
[  102.685703] Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz stepping 06
[  102.685772] checking TSC synchronization [CPU#0 -> CPU#2]: passed.
[  102.707983] SMP alternatives: switching to SMP code
[  102.708753] Booting processor 3/8 APIC 0x5
[  102.719385] Initializing CPU#3
[  102.864798] Calibrating delay using timer specific routine.. 5666.94 BogoMIPS (lpj=28334738)
[  102.864805] CPU: L1 I cache: 32K, L1 D cache: 32K
[  102.864806] CPU: L2 cache: 6144K
[  102.864808] CPU 3/5 -> Node 0
[  102.864809] CPU: Physical Processor ID: 1
[  102.864809] CPU: Processor Core ID: 1
[  102.864815] CPU3: Thermal monitoring enabled (TM2)
[  102.865505] Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz stepping 06
[  102.865589] checking TSC synchronization [CPU#0 -> CPU#3]: passed.
[  102.886207] SMP alternatives: switching to SMP code
[  102.886650] Booting processor 4/8 APIC 0x2
[  102.897282] Initializing CPU#4
[  103.044599] Calibrating delay using timer specific routine.. 5666.93 BogoMIPS (lpj=28334658)
[  103.044605] CPU: L1 I cache: 32K, L1 D cache: 32K
[  103.044606] CPU: L2 cache: 6144K
[  103.044608] CPU 4/2 -> Node 0
[  103.044609] CPU: Physical Processor ID: 0
[  103.044610] CPU: Processor Core ID: 2
[  103.044614] CPU4: Thermal monitoring enabled (TM2)
[  103.045305] Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz stepping 06
[  103.045385] checking TSC synchronization [CPU#0 -> CPU#4]: passed.
[  103.066001] SMP alternatives: switching to SMP code
[  103.066445] Booting processor 5/8 APIC 0x6
[  103.077077] Initializing CPU#5
[  103.224400] Calibrating delay using timer specific routine.. 5666.95 BogoMIPS (lpj=28334791)
[  103.224406] CPU: L1 I cache: 32K, L1 D cache: 32K
[  103.224407] CPU: L2 cache: 6144K
[  103.224409] CPU 5/6 -> Node 0
[  103.224410] CPU: Physical Processor ID: 1
[  103.224411] CPU: Processor Core ID: 2
[  103.224416] CPU5: Thermal monitoring enabled (TM2)
[  103.225105] Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz stepping 06
[  103.225188] checking TSC synchronization [CPU#0 -> CPU#5]: passed.
[  103.245800] SMP alternatives: switching to SMP code
[  103.246245] Booting processor 6/8 APIC 0x3
[  103.256876] Initializing CPU#6
[  103.404200] Calibrating delay using timer specific routine.. 5666.92 BogoMIPS (lpj=28334646)
[  103.404207] CPU: L1 I cache: 32K, L1 D cache: 32K
[  103.404208] CPU: L2 cache: 6144K
[  103.404209] CPU 6/3 -> Node 0
[  103.404210] CPU: Physical Processor ID: 0
[  103.404211] CPU: Processor Core ID: 3
[  103.404216] CPU6: Thermal monitoring enabled (TM2)
[  103.404905] Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz stepping 06
[  103.405002] checking TSC synchronization [CPU#0 -> CPU#6]: passed.
[  103.425620] SMP alternatives: switching to SMP code
[  103.426064] Booting processor 7/8 APIC 0x7
[  103.436696] Initializing CPU#7
[  103.584001] Calibrating delay using timer specific routine.. 5666.92 BogoMIPS (lpj=28334610)
[  103.584008] CPU: L1 I cache: 32K, L1 D cache: 32K
[  103.584009] CPU: L2 cache: 6144K
[  103.584010] CPU 7/7 -> Node 0
[  103.584012] CPU: Physical Processor ID: 1
[  103.584012] CPU: Processor Core ID: 3
[  103.584017] CPU7: Thermal monitoring enabled (TM2)
[  103.584707] Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz stepping 06
[  103.584799] checking TSC synchronization [CPU#0 -> CPU#7]: passed.
[  103.605374] Brought up 8 CPUs
[  103.605531] CPU0 attaching sched-domain:
[  103.605534]  domain 0: span 00000000,00000005
[  103.605535]   groups: 00000000,00000001 00000000,00000004
[  103.605537]   domain 1: span 00000000,000000ff
[  103.605538]    groups: 00000000,00000005 00000000,0000000a 00000000,00000050 00000000,000000a0
[  103.605541]    domain 2: span 00000000,000000ff
[  103.605542]     groups: 00000000,000000ff
[  103.605544] CPU1 attaching sched-domain:
[  103.605545]  domain 0: span 00000000,0000000a
[  103.605546]   groups: 00000000,00000002 00000000,00000008
[  103.605548]   domain 1: span 00000000,000000ff
[  103.605549]    groups: 00000000,0000000a 00000000,00000050 00000000,000000a0 00000000,00000005
[  103.605552]    domain 2: span 00000000,000000ff
[  103.605553]     groups: 00000000,000000ff
[  103.605554] CPU2 attaching sched-domain:
[  103.605555]  domain 0: span 00000000,00000005
[  103.605556]   groups: 00000000,00000004 00000000,00000001
[  103.605558]   domain 1: span 00000000,000000ff
[  103.605559]    groups: 00000000,00000005 00000000,0000000a 00000000,00000050 00000000,000000a0
[  103.605562]    domain 2: span 00000000,000000ff
[  103.605563]     groups: 00000000,000000ff
[  103.605564] CPU3 attaching sched-domain:
[  103.605565]  domain 0: span 00000000,0000000a
[  103.605566]   groups: 00000000,00000008 00000000,00000002
[  103.605568]   domain 1: span 00000000,000000ff
[  103.605569]    groups: 00000000,0000000a 00000000,00000050 00000000,000000a0 00000000,00000005
[  103.605572]    domain 2: span 00000000,000000ff
[  103.605573]     groups: 00000000,000000ff
[  103.605574] CPU4 attaching sched-domain:
[  103.605575]  domain 0: span 00000000,00000050
[  103.605576]   groups: 00000000,00000010 00000000,00000040
[  103.605578]   domain 1: span 00000000,000000ff
[  103.605579]    groups: 00000000,00000050 00000000,000000a0 00000000,00000005 00000000,0000000a
[  103.605582]    domain 2: span 00000000,000000ff
[  103.605583]     groups: 00000000,000000ff
[  103.605585] CPU5 attaching sched-domain:
[  103.605586]  domain 0: span 00000000,000000a0
[  103.605587]   groups: 00000000,00000020 00000000,00000080
[  103.605588]   domain 1: span 00000000,000000ff
[  103.605589]    groups: 00000000,000000a0 00000000,00000005 00000000,0000000a 00000000,00000050
[  103.605592]    domain 2: span 00000000,000000ff
[  103.605593]     groups: 00000000,000000ff
[  103.605595] CPU6 attaching sched-domain:
[  103.605596]  domain 0: span 00000000,00000050
[  103.605597]   groups: 00000000,00000040 00000000,00000010
[  103.605598]   domain 1: span 00000000,000000ff
[  103.605599]    groups: 00000000,00000050 00000000,000000a0 00000000,00000005 00000000,0000000a
[  103.605602]    domain 2: span 00000000,000000ff
[  103.605603]     groups: 00000000,000000ff
[  103.605605] CPU7 attaching sched-domain:
[  103.605606]  domain 0: span 00000000,000000a0
[  103.605607]   groups: 00000000,00000080 00000000,00000020
[  103.605608]   domain 1: span 00000000,000000ff
[  103.605609]    groups: 00000000,000000a0 00000000,00000005 00000000,0000000a 00000000,00000050
[  103.605612]    domain 2: span 00000000,000000ff
[  103.605613]     groups: 00000000,000000ff
[  103.606100] net_namespace: 120 bytes
[  103.606413] Time: 17:37:52  Date: 07/17/08
[  103.606492] NET: Registered protocol family 16
[  103.606694] ACPI: bus type pci registered
[  103.606808] PCI: Using configuration type 1
[  103.607872] ACPI: EC: Look up EC in DSDT
[  103.609090] ACPI: Interpreter enabled
[  103.609142] ACPI: (supports S0 S1 S4 S5)
[  103.609324] ACPI: Using IOAPIC for interrupt routing
[  103.611880] ACPI: PCI Root Bridge [PCI0] (0000:00)
[  103.613623] Force enabled HPET at base address 0xfed00000
[  103.614430] PCI: PXH quirk detected, disabling MSI for SHPC device
[  103.614716] PCI: Transparent bridge - 0000:00:1e.0
[  103.614798] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[  103.615018] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
[  103.615058] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0._PRT]
[  103.615112] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0.BPD0._PRT]
[  103.615173] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0.BPD2._PRT]
[  103.615219] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMF3._PRT]
[  103.615273] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
[  103.615339] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
[  103.615404] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0.PXH0._PRT]
[  103.615469] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIB._PRT]
[  103.620213] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 *7 10 11 14 15)
[  103.620657] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 10 11 14 15)
[  103.621100] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11 14 15)
[  103.621542] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 *10 11 14 15)
[  103.621983] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
[  103.622503] ACPI: PCI Interrupt Link [LNKF] (IRQs 4 5 6 7 10 11 14 15) *0, disabled.
[  103.622990] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
[  103.623509] ACPI: PCI Interrupt Link [LNKH] (IRQs 4 5 6 7 10 11 14 15) *0, disabled.
[  103.624042] Linux Plug and Play Support v0.97 (c) Adam Belay
[  103.624118] pnp: PnP ACPI init
[  103.624174] ACPI: bus type pnp registered
[  103.625901] pnp: PnP ACPI: found 12 devices
[  103.625954] ACPI: ACPI bus type pnp unregistered
[  103.626203] PCI: Using ACPI for IRQ routing
[  103.626256] PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
[  103.673959] NET: Registered protocol family 8
[  103.674012] NET: Registered protocol family 20
[  103.674088] NetLabel: Initializing
[  103.674139] NetLabel:  domain hash size = 128
[  103.674191] NetLabel:  protocols = UNLABELED CIPSOv4
[  103.674253] NetLabel:  unlabeled traffic allowed by default
[  103.674313] PCI-GART: No AMD northbridge found.
[  103.674447] hpet clockevent registered
[  103.674449] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[  103.674628] hpet0: 3 64-bit timers, 14318180 Hz
[  103.675717] AppArmor: AppArmor Filesystem Enabled
[  103.683892] Time: tsc clocksource has been installed.
[  103.696836] system 00:01: ioport range 0x4d0-0x4d1 has been reserved
[  103.696893] system 00:01: ioport range 0x295-0x296 has been reserved
[  103.696949] system 00:01: ioport range 0xca2-0xca3 has been reserved
[  103.697005] system 00:01: ioport range 0xca8-0xcaf has been reserved
[  103.697062] system 00:01: ioport range 0x1000-0x107f has been reserved
[  103.697119] system 00:01: ioport range 0x1180-0x11bf has been reserved
[  103.697176] system 00:01: ioport range 0x800-0x80f has been reserved
[  103.697232] system 00:01: ioport range 0xfe00-0xfe00 has been reserved
[  103.697289] system 00:01: iomem range 0xe0000000-0xefffffff could not be reserved
[  103.697362] system 00:01: iomem range 0xfee00000-0xfee0ffff could not be reserved
[  103.697434] system 00:01: iomem range 0xfec80000-0xfec80fff has been reserved
[  103.697492] system 00:01: iomem range 0xfed1c000-0xfed1ffff has been reserved
[  103.697550] system 00:01: iomem range 0xfe000000-0xfe01ffff has been reserved
[  103.697608] system 00:01: iomem range 0xfe600000-0xfe6fffff has been reserved
[  103.697956] PCI: Bridge: 0000:02:00.0
[  103.698008]   IO window: disabled.
[  103.698061]   MEM window: disabled.
[  103.698113]   PREFETCH window: disabled.
[  103.698167] PCI: Bridge: 0000:02:02.0
[  103.698219]   IO window: 2000-2fff
[  103.698272]   MEM window: d8200000-d82fffff
[  103.698326]   PREFETCH window: d8700000-d87fffff
[  103.698381] PCI: Bridge: 0000:01:00.0
[  103.698433]   IO window: 2000-2fff
[  103.698486]   MEM window: d8200000-d82fffff
[  103.698539]   PREFETCH window: d8700000-d87fffff
[  103.698594] PCI: Bridge: 0000:01:00.3
[  103.698646]   IO window: disabled.
[  103.698698]   MEM window: disabled.
[  103.698750]   PREFETCH window: disabled.
[  103.698804] PCI: Bridge: 0000:00:02.0
[  103.698855]   IO window: 2000-2fff
[  103.698907]   MEM window: d8200000-d83fffff
[  103.698960]   PREFETCH window: d8700000-d87fffff
[  103.699015] PCI: Bridge: 0000:00:04.0
[  103.699067]   IO window: 3000-3fff
[  103.699119]   MEM window: d8400000-d84fffff
[  103.699172]   PREFETCH window: d8000000-d81fffff
[  103.699226] PCI: Bridge: 0000:00:06.0
[  103.699277]   IO window: disabled.
[  103.699329]   MEM window: disabled.
[  103.699381]   PREFETCH window: disabled.
[  103.699434] PCI: Bridge: 0000:08:00.0
[  103.699486]   IO window: disabled.
[  103.699539]   MEM window: disabled.
[  103.699592]   PREFETCH window: disabled.
[  103.699647] PCI: Bridge: 0000:00:1c.0
[  103.699698]   IO window: disabled.
[  103.699751]   MEM window: disabled.
[  103.699803]   PREFETCH window: disabled.
[  103.699857] PCI: Bridge: 0000:00:1e.0
[  103.699909]   IO window: 4000-4fff
[  103.699962]   MEM window: d8500000-d85fffff
[  103.700016]   PREFETCH window: d0000000-d7ffffff
[  103.700081] ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 16
[  103.700186] PCI: Setting latency timer of device 0000:00:02.0 to 64
[  103.700194] ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
[  103.700299] PCI: Setting latency timer of device 0000:01:00.0 to 64
[  103.700309] ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
[  103.700413] PCI: Setting latency timer of device 0000:02:00.0 to 64
[  103.700424] ACPI: PCI Interrupt 0000:02:02.0[A] -> GSI 18 (level, low) -> IRQ 18
[  103.700528] PCI: Setting latency timer of device 0000:02:02.0 to 64
[  103.700538] PCI: Setting latency timer of device 0000:01:00.3 to 64
[  103.700543] ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 16 (level, low) -> IRQ 16
[  103.702204] PCI: Setting latency timer of device 0000:00:04.0 to 64
[  103.702209] ACPI: PCI Interrupt 0000:00:06.0[A] -> GSI 16 (level, low) -> IRQ 16
[  103.702313] PCI: Setting latency timer of device 0000:00:06.0 to 64
[  103.702326] ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 17 (level, low) -> IRQ 17
[  103.702431] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[  103.702446] PCI: Setting latency timer of device 0000:08:00.0 to 64
[  103.702454] PCI: Setting latency timer of device 0000:00:1e.0 to 64
[  103.702461] NET: Registered protocol family 2
[  103.807821] IP route cache hash table entries: 2097152 (order: 12, 16777216 bytes)
[  103.813515] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[  103.816839] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[  103.817295] TCP: Hash tables configured (established 524288 bind 65536)
[  103.817352] TCP reno registered
[  103.846841] checking if image is initramfs... it is
[  104.183346] Switched to high resolution mode on CPU 0
[  104.184737] Switched to high resolution mode on CPU 5
[  104.184742] Switched to high resolution mode on CPU 4
[  104.184748] Switched to high resolution mode on CPU 3
[  104.184752] Switched to high resolution mode on CPU 6
[  104.184756] Switched to high resolution mode on CPU 1
[  104.184759] Switched to high resolution mode on CPU 7
[  104.186272] Switched to high resolution mode on CPU 2
[  104.329238] Freeing initrd memory: 7615k freed
[  104.332022] Simple Boot Flag at 0x38 set to 0x1
[  104.334141] audit: initializing netlink socket (disabled)
[  104.334215] audit(1216316272.960:1): initialized
[  104.339391] Total HugeTLB memory allocated, 0
[  104.341296] VFS: Disk quotas dquot_6.5.1
[  104.341403] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[  104.341609] io scheduler noop registered
[  104.341662] io scheduler anticipatory registered
[  104.341715] io scheduler deadline registered (default)
[  104.341851] io scheduler cfq registered
[  104.344804] Boot video device is 0000:0a:01.0
[  104.345006] PCI: Setting latency timer of device 0000:00:02.0 to 64
[  104.345027] assign_interrupt_mode Found MSI capability
[  104.345105] Allocate Port Service[0000:00:02.0:pcie00]
[  104.345172] PCI: Setting latency timer of device 0000:00:04.0 to 64
[  104.345192] assign_interrupt_mode Found MSI capability
[  104.345262] Allocate Port Service[0000:00:04.0:pcie00]
[  104.345326] PCI: Setting latency timer of device 0000:00:06.0 to 64
[  104.345347] assign_interrupt_mode Found MSI capability
[  104.345416] Allocate Port Service[0000:00:06.0:pcie00]
[  104.345477] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[  104.345506] assign_interrupt_mode Found MSI capability
[  104.345584] Allocate Port Service[0000:00:1c.0:pcie00]
[  104.345615] Allocate Port Service[0000:00:1c.0:pcie02]
[  104.345689] PCI: Setting latency timer of device 0000:01:00.0 to 64
[  104.345715] Allocate Port Service[0000:01:00.0:pcie10]
[  104.345788] PCI: Setting latency timer of device 0000:02:00.0 to 64
[  104.345814] assign_interrupt_mode Found MSI capability
[  104.345891] Allocate Port Service[0000:02:00.0:pcie20]
[  104.345957] PCI: Setting latency timer of device 0000:02:02.0 to 64
[  104.345983] assign_interrupt_mode Found MSI capability
[  104.346060] Allocate Port Service[0000:02:02.0:pcie20]
[  104.368049] Real Time Clock Driver v1.12ac
[  104.368190] Linux agpgart interface v0.102
[  104.368243] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
[  104.368435] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[  104.368602] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[  104.369061] 00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[  104.369282] 00:0a: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[  104.370084] RAMDISK driver initialized: 16 RAM disks of 65536K size 1024 blocksize
[  104.370219] input: Macintosh mouse button emulation as /devices/virtual/input/input0
[  104.370373] PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
[  104.372765] serio: i8042 KBD port at 0x60,0x64 irq 1
[  104.372829] serio: i8042 AUX port at 0x60,0x64 irq 12
[  104.416868] mice: PS/2 mouse device common for all mice
[  104.416965] cpuidle: using governor ladder
[  104.417020] cpuidle: using governor menu
[  104.417203] NET: Registered protocol family 1
[  104.417354] registered taskstats version 1
[  104.417523]   Magic number: 0:667:643
[  104.417679] /home/asm/ubuntu/linux-2.6.24-19.36/linux-2.6.24/drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[  104.417757] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[  104.418042] Freeing unused kernel memory: 328k freed
[  104.525781] fuse init (API version 7.9)
[  104.538619] ACPI: Processor [CPU0] (supports 8 throttling states)
[  104.538973] ACPI: Processor [CPU1] (supports 8 throttling states)
[  104.539397] ACPI: Processor [CPU2] (supports 8 throttling states)
[  104.539767] ACPI: Processor [CPU3] (supports 8 throttling states)
[  104.540147] ACPI: Processor [CPU4] (supports 8 throttling states)
[  104.540590] ACPI: Processor [CPU5] (supports 8 throttling states)
[  104.541018] ACPI: Processor [CPU6] (supports 8 throttling states)
[  104.541390] ACPI: Processor [CPU7] (supports 8 throttling states)
[  104.551231] md: linear personality registered for level -1
[  104.554025] md: multipath personality registered for level -4
[  104.556912] md: raid0 personality registered for level 0
[  104.559869] md: raid1 personality registered for level 1
[  104.562329] xor: automatically using best checksumming function: generic_sse
[  104.602842]    generic_sse: 10558.800 MB/sec
[  104.602895] xor: using function: generic_sse (10558.800 MB/sec)
[  104.603441] async_tx: api initialized (async)
[  104.772664] raid6: int64x1   2503 MB/s
[  104.942470] raid6: int64x2   3172 MB/s
[  105.112280] raid6: int64x4   3277 MB/s
[  105.282094] raid6: int64x8   2608 MB/s
[  105.451903] raid6: sse2x1    3298 MB/s
[  105.621698] raid6: sse2x2    7267 MB/s
[  105.791507] raid6: sse2x4    8077 MB/s
[  105.791559] raid6: using algorithm sse2x4 (8077 MB/s)
[  105.791613] md: raid6 personality registered for level 6
[  105.791667] md: raid5 personality registered for level 5
[  105.791722] md: raid4 personality registered for level 4
[  105.806997] md: raid10 personality registered for level 10
[  105.924522] SCSI subsystem initialized
[  105.936394] Intel(R) PRO/1000 Network Driver - version 7.3.20-k2-NAPI
[  105.936454] Copyright (c) 1999-2006 Intel Corporation.
[  105.936555] ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 18 (level, low) -> IRQ 18
[  105.936669] PCI: Setting latency timer of device 0000:04:00.0 to 64
[  105.940387] usbcore: registered new interface driver usbfs
[  105.940462] usbcore: registered new interface driver hub
[  105.940553] Fusion MPT base driver 3.04.06
[  105.940607] Copyright (c) 1999-2007 LSI Corporation
[  105.941062] usbcore: registered new device driver usb
[  105.945777] libata version 3.00 loaded.
[  105.946231] USB Universal Host Controller Interface driver v3.0
[  105.946339] ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 17 (level, low) -> IRQ 17
[  105.946449] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[  105.946451] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[  105.946707] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
[  105.946802] uhci_hcd 0000:00:1d.0: irq 17, io base 0x00001800
[  105.946941] usb usb1: configuration #1 chosen from 1 choice
[  105.947010] hub 1-0:1.0: USB hub found
[  105.947065] hub 1-0:1.0: 2 ports detected
[  105.947504] Fusion MPT SAS Host driver 3.04.06
[  105.958818] FDC 0 is a post-1991 82077
[  105.977605] e1000: 0000:04:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4) 00:30:48:7f:d8:b2
[  106.030107] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
[  106.030186] ACPI: PCI Interrupt 0000:04:00.1[B] -> GSI 19 (level, low) -> IRQ 19
[  106.030294] PCI: Setting latency timer of device 0000:04:00.1 to 64
[  106.051275] ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
[  106.051384] PCI: Setting latency timer of device 0000:00:1d.1 to 64
[  106.051386] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[  106.051451] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 2
[  106.051544] uhci_hcd 0000:00:1d.1: irq 19, io base 0x00001820
[  106.051661] usb usb2: configuration #1 chosen from 1 choice
[  106.051727] hub 2-0:1.0: USB hub found
[  106.051782] hub 2-0:1.0: 2 ports detected
[  106.067506] e1000: 0000:04:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4) 00:30:48:7f:d8:b3
[  106.120511] e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
[  106.171139] ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
[  106.171246] PCI: Setting latency timer of device 0000:00:1d.2 to 64
[  106.171248] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[  106.171315] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 3
[  106.171409] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001840
[  106.171524] usb usb3: configuration #1 chosen from 1 choice
[  106.171591] hub 3-0:1.0: USB hub found
[  106.171646] hub 3-0:1.0: 2 ports detected
[  106.281007] ACPI: PCI Interrupt 0000:00:1d.3[D] -> GSI 16 (level, low) -> IRQ 16
[  106.281115] PCI: Setting latency timer of device 0000:00:1d.3 to 64
[  106.281117] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[  106.281185] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 4
[  106.281276] uhci_hcd 0000:00:1d.3: irq 16, io base 0x00001860
[  106.281392] usb usb4: configuration #1 chosen from 1 choice
[  106.281458] hub 4-0:1.0: USB hub found
[  106.281513] hub 4-0:1.0: 2 ports detected
[  106.340899] usb 1-1: new low speed USB device using uhci_hcd and address 2
[  106.380969] ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 17 (level, low) -> IRQ 17
[  106.383387] PCI: Setting latency timer of device 0000:00:1d.7 to 64
[  106.383393] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[  106.383506] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 5
[  106.387479] ehci_hcd 0000:00:1d.7: debug port 1
[  106.387536] PCI: cache line size of 32 is not supported by device 0000:00:1d.7
[  106.387542] ehci_hcd 0000:00:1d.7: irq 17, io mem 0xd8600400
[  106.483236] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[  106.483389] usb usb5: configuration #1 chosen from 1 choice
[  106.483464] hub 5-0:1.0: USB hub found
[  106.483521] hub 5-0:1.0: 8 ports detected
[  106.593170] ata_piix 0000:00:1f.1: version 2.12
[  106.593188] ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 18
[  106.593319] PCI: Setting latency timer of device 0000:00:1f.1 to 64
[  106.593415] scsi0 : ata_piix
[  106.593502] scsi1 : ata_piix
[  106.593814] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1880 irq 14
[  106.593873] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1888 irq 15
[  106.800703] ata1.00: ATA-0: PQI IDE DiskOnModule, 060729DA, max MWDMA2
[  106.800765] ata1.00: 4095504 sectors, multi 0: LBA 
[  106.820604] ata1.00: configured for MWDMA2
[  106.860559] ata1.00: configured for MWDMA2
[  106.860614] ata1: EH complete
[  106.860692] ata2: port disabled. ignoring.
[  106.860802] scsi 0:0:0:0: Direct-Access     ATA      PQI IDE DiskOnMo 0607 PQ: 0 ANSI: 5
[  106.860947] ACPI: PCI Interrupt 0000:06:00.0[A] -> GSI 16 (level, low) -> IRQ 16
[  106.861059] mptbase: ioc0: Initiating bringup
[  106.890904] usb 1-1: device not accepting address 2, error -71
[  107.439666] usb 1-1: new low speed USB device using uhci_hcd and address 4
[  107.627120] usb 1-1: configuration #1 chosen from 1 choice
[  107.656055] usbcore: registered new interface driver hiddev
[  107.669573] input: Avocent Avocent USBIAC as /devices/pci0000:00/0000:00:1d.0/usb1/1-1/1-1:1.0/input/input1
[  107.719370] input,hidraw0: USB HID v1.10 Keyboard [Avocent Avocent USBIAC] on usb-0000:00:1d.0-1
[  107.739177] input: Avocent Avocent USBIAC as /devices/pci0000:00/0000:00:1d.0/usb1/1-1/1-1:1.1/input/input2
[  107.841733] input,hidraw1: USB HID v1.10 Mouse [Avocent Avocent USBIAC] on usb-0000:00:1d.0-1
[  107.841941] usbcore: registered new interface driver usbhid
[  107.841997] /home/asm/ubuntu/linux-2.6.24-19.36/linux-2.6.24/drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
[  108.402331] ioc0: LSISAS1064E B3: Capabilities={Initiator}
[  108.402515] PCI: Setting latency timer of device 0000:06:00.0 to 64
[  122.678863] scsi2 : ioc0: LSISAS1064E B3, FwRev=01170200h, Ports=1, MaxQ=286, IRQ=16
[  122.695184] scsi 2:0:0:0: Direct-Access     HITACHI  HUS153014VLS300  A320 PQ: 0 ANSI: 5
[  122.698084] scsi 2:0:1:0: Direct-Access     HITACHI  HUS153014VLS300  A320 PQ: 0 ANSI: 5
[  122.700283] scsi 2:0:2:0: Direct-Access     HITACHI  HUS153014VLS300  A320 PQ: 0 ANSI: 5
[  122.702731] scsi 2:0:3:0: Direct-Access     HITACHI  HUS153014VLS300  A320 PQ: 0 ANSI: 5
[  122.710602] Driver 'sd' needs updating - please use bus_type methods
[  122.710718] sd 0:0:0:0: [sda] 4095504 512-byte hardware sectors (2097 MB)
[  122.710788] sd 0:0:0:0: [sda] Write Protect is off
[  122.710843] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[  122.710858] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[  122.710973] sd 0:0:0:0: [sda] 4095504 512-byte hardware sectors (2097 MB)
[  122.711038] sd 0:0:0:0: [sda] Write Protect is off
[  122.711092] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[  122.711106] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[  122.711183]  sda: sda1
[  122.712021] sd 0:0:0:0: [sda] Attached SCSI disk
[  122.712803] sd 2:0:0:0: [sdb] 287140277 512-byte hardware sectors (147016 MB)
[  122.714097] sd 2:0:0:0: [sdb] Write Protect is off
[  122.714151] sd 2:0:0:0: [sdb] Mode Sense: d3 00 10 08
[  122.715428] sd 2:0:0:0: [sdb] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  122.716241] sd 2:0:0:0: [sdb] 287140277 512-byte hardware sectors (147016 MB)
[  122.717529] sd 2:0:0:0: [sdb] Write Protect is off
[  122.717583] sd 2:0:0:0: [sdb] Mode Sense: d3 00 10 08
[  122.718862] sd 2:0:0:0: [sdb] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  122.718940]  sdb: sdb1
[  122.719331] sd 2:0:0:0: [sdb] Attached SCSI disk
[  122.720596] sd 2:0:1:0: [sdc] 287140277 512-byte hardware sectors (147016 MB)
[  122.722803] sd 2:0:1:0: [sdc] Write Protect is off
[  122.722858] sd 2:0:1:0: [sdc] Mode Sense: d3 00 10 08
[  122.725049] sd 2:0:1:0: [sdc] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  122.725846] sd 2:0:1:0: [sdc] 287140277 512-byte hardware sectors (147016 MB)
[  122.727136] sd 2:0:1:0: [sdc] Write Protect is off
[  122.727191] sd 2:0:1:0: [sdc] Mode Sense: d3 00 10 08
[  122.728465] sd 2:0:1:0: [sdc] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  122.728541]  sdc: sdc1
[  122.728978] sd 2:0:1:0: [sdc] Attached SCSI disk
[  122.729733] sd 2:0:2:0: [sdd] 287140277 512-byte hardware sectors (147016 MB)
[  122.731034] sd 2:0:2:0: [sdd] Write Protect is off
[  122.731090] sd 2:0:2:0: [sdd] Mode Sense: d3 00 10 08
[  122.732360] sd 2:0:2:0: [sdd] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  122.733138] sd 2:0:2:0: [sdd] 287140277 512-byte hardware sectors (147016 MB)
[  122.734422] sd 2:0:2:0: [sdd] Write Protect is off
[  122.734477] sd 2:0:2:0: [sdd] Mode Sense: d3 00 10 08
[  122.735769] sd 2:0:2:0: [sdd] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  122.735846]  sdd: sdd1
[  122.736214] sd 2:0:2:0: [sdd] Attached SCSI disk
[  122.736986] sd 2:0:3:0: [sde] 287140277 512-byte hardware sectors (147016 MB)
[  122.738291] sd 2:0:3:0: [sde] Write Protect is off
[  122.738344] sd 2:0:3:0: [sde] Mode Sense: d3 00 10 08
[  122.739619] sd 2:0:3:0: [sde] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  122.740406] sd 2:0:3:0: [sde] 287140277 512-byte hardware sectors (147016 MB)
[  122.741687] sd 2:0:3:0: [sde] Write Protect is off
[  122.741741] sd 2:0:3:0: [sde] Mode Sense: d3 00 10 08
[  122.743029] sd 2:0:3:0: [sde] Write cache: disabled, read cache: enabled, supports DPO and FUA
[  122.743104]  sde: sde1
[  122.743464] sd 2:0:3:0: [sde] Attached SCSI disk
[  122.746249] sd 0:0:0:0: Attached scsi generic sg0 type 0
[  122.746319] sd 2:0:0:0: Attached scsi generic sg1 type 0
[  122.746385] sd 2:0:1:0: Attached scsi generic sg2 type 0
[  122.746450] sd 2:0:2:0: Attached scsi generic sg3 type 0
[  122.746515] sd 2:0:3:0: Attached scsi generic sg4 type 0
[  122.793128] md: md0 stopped.
[  122.802516] md: bind<sdc1>
[  122.802731] md: bind<sdd1>
[  122.802938] md: bind<sde1>
[  122.803166] md: bind<sdb1>
[  122.808616] raid10: raid set md0 active with 4 out of 4 devices
[  122.808990] md0: bitmap initialized from disk: read 1/1 pages, set 15 bits
[  122.809053] created bitmap (9 pages) for device md0
[  124.632067] input: PC Speaker as /devices/platform/pcspkr/input/input3
[  124.647506] iTCO_vendor_support: vendor-support=0
[  124.657217] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[  124.701396] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[  124.747935] EDAC MC: Ver: 2.1.0 Jul 16 2008
[  124.776063] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
[  124.786522] input: Power Button (FF) as /devices/virtual/input/input4
[  124.810395] EDAC MC0: Giving out device to 'i5000_edac.c' 'I5000': DEV 0000:00:10.0
[  124.810515] EDAC PCI0: Giving out device to module 'i5000_edac' controller 'EDAC PCI controller': DEV '0000:00:10.0' (POLLED)
[  124.811603] iTCO_wdt: Found a 631xESB/632xESB TCO device (Version=2, TCOBASE=0x1060)
[  124.811729] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[  124.846676] intel_rng: FWH not detected
[  124.851395] ACPI: Power Button (FF) [PWRF]
[  124.851567] input: Power Button (CM) as /devices/virtual/input/input5
[  125.054481] e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[  125.609315] ACPI: Power Button (CM) [PWRB]
[  125.707207] NET: Registered protocol family 10
[  125.707498] lo: Disabled Privacy Extensions
[  126.250645] loop: module loaded
[  126.289927] lp: driver loaded but no devices found
[  127.049587] kjournald starting.  Commit interval 300 seconds
[  127.055301] EXT3 FS on md0, internal journal
[  127.055306] EXT3-fs: mounted filesystem with writeback data mode.
[  127.492252] ip_tables: (C) 2000-2006 Netfilter Core Team
[  127.922052] No dock devices found.
[  128.277109] e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[  135.777776] eth0: no IPv6 routers present


-- 
Vlad Seliverstov
www.yandex.ru
