From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Mon, 03 Oct 2011 11:25:31 -0400
Message-ID: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=====================_-2087498783==_"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.binnacle.cx ([74.95.187.105]:36282 "EHLO mx.binnacle.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755816Ab1JCPwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Oct 2011 11:52:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=====================_-2087498783==_
Content-Type: text/plain; charset="us-ascii"

Ran 'nohalt' and 'poll=idle' tests and they
were a complete bust.  'nohalt' gave slightly
better performance with 2.6.18(rhel) and
slightly worse performance with 2.6.39.27.
'poll=idle' improved 2.6.39.27 by 2.7%,
which is nowhere near good enough to have
servers running at full power--about double
idle power according to the UPS.  'poll=idle'
did cause the idle-loop to show up in 'perf'
at the top of the list consuming 45% of the
CPU.  So the one thing it does is permit one
to see exactly how much absolute CPU is
consumed by each component during test runs
rather than providing a relative number.

I've come to the conclusion that Eric is right
and the primary issue is an increase in the
cost of scheduler context switches.  Have
been watching this number and it has held
pretty close to 200k/sec under all scenarios
and kernel versions, so it has to be
a longer code-path, bigger cache pressure
or both in the scheduler.  Sadly this makes
newer kernels a no-go for us.

At 07:47 AM 10/2/2011 -0700, Stephen Hemminger wrote:
>Try disabling PCI DMA remapping. The additional
>overhead of setting up IO mapping can be a
>performance buzz kill. Try CONGIG_DMAR=n

I decided to skip this.  Can't see how it
will make more than a percent or two
difference since the problem is not the
network stack.

At 09:21 AM 10/2/2011 +0200, Eric Dumazet wrote:
>On new kernels, you can check if your udp sockets
>drops frames because of rcvbuffer being full (cat
>/proc/net/udp, check last column 'drops')

Zero, of course.  This info is also
shown lumped in the 'netstat -s'
"packet receive errors" counter.
Have been watching it all along.

>To check if softirq processing hit some limits :
>cat /proc/net/softnet_stat

Zero drops.  Some noise-level squeezing.

Nice stat!  Wish I had known about this
four or five years ago.

>Please send full "dmesg" output 

Attached.


--=====================_-2087498783==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="dmesg_c6_263904.txt"

Linux version 2.6.39.4 (x@x) (gcc version 4.4.4 20100726 (Red Hat 4.4.4-13) (GCC) ) #1 SMP Sat Oct 1 21:11:47 EDT 2011
Command line: ro root=/dev/vg00/lv06 console=ttyS2,115200 hugepages=4096 nohalt
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009dc00 (usable)
 BIOS-e820: 000000000009dc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000d7e80000 (usable)
 BIOS-e820: 00000000d7e8e000 - 00000000d7e90000 type 9
 BIOS-e820: 00000000d7e90000 - 00000000d7eb4000 (ACPI data)
 BIOS-e820: 00000000d7eb4000 - 00000000d7ee0000 (ACPI NVS)
 BIOS-e820: 00000000d7ee0000 - 00000000d8000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000ffe00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000428000000 (usable)
NX (Execute Disable) protection: active
DMI present.
DMI: Supermicro H8DG6/H8DGi/H8DG6/H8DGi, BIOS 1.0        09/09/10  
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
No AGP bridge found
last_pfn = 0x428000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-EFFFF uncachable
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000000 mask FFFF80000000 write-back
  1 base 000080000000 mask FFFFC0000000 write-back
  2 base 0000C0000000 mask FFFFF0000000 write-back
  3 base 0000D0000000 mask FFFFF8000000 write-back
  4 disabled
  5 disabled
  6 disabled
  7 disabled
TOM2: 0000000428000000 aka 17024M
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
e820 update range: 00000000d8000000 - 0000000100000000 (usable) ==> (reserved)
last_pfn = 0xd7e80 max_arch_pfn = 0x400000000
found SMP MP-table at [ffff8800000ff780] ff780
initial memory mapped : 0 - 20000000
Base memory trampoline at [ffff880000098000] 98000 size 20480
Using GB pages for direct mapping
init_memory_mapping: 0000000000000000-00000000d7e80000
 0000000000 - 00c0000000 page 1G
 00c0000000 - 00d7e00000 page 2M
 00d7e00000 - 00d7e80000 page 4k
kernel direct mapping tables up to d7e80000 @ d7e7d000-d7e80000
init_memory_mapping: 0000000100000000-0000000428000000
 0100000000 - 0400000000 page 1G
 0400000000 - 0428000000 page 2M
kernel direct mapping tables up to 428000000 @ 427ffe000-428000000
RAMDISK: 37451000 - 37ff0000
ACPI: RSDP 00000000000fa320 00024 (v02 ACPIAM)
ACPI: XSDT 00000000d7e90100 00084 (v01 SMCI            20100909 MSFT 00000097)
ACPI: FACP 00000000d7e90290 000F4 (v03 090910 FACP2028 20100909 MSFT 00000097)
ACPI: DSDT 00000000d7e90670 06E54 (v01  1BC11 1BC11000 00000000 INTL 20051117)
ACPI: FACS 00000000d7eb4000 00040
ACPI: APIC 00000000d7e90390 00118 (v01 090910 APIC2028 20100909 MSFT 00000097)
ACPI: MCFG 00000000d7e904b0 0003C (v01 090910 OEMMCFG  20100909 MSFT 00000097)
ACPI: OEMB 00000000d7eb4040 000BC (v01 090910 OEMB2028 20100909 MSFT 00000097)
ACPI: HPET 00000000d7e9a670 00038 (v01 090910 OEMHPET  20100909 MSFT 00000097)
ACPI: SRAT 00000000d7e9a6b0 00190 (v02 AMD    F10      00000001 AMD  00000001)
ACPI: SLIT 00000000d7e9a840 00030 (v01 AMD    F10      00000001 AMD  00000001)
ACPI: SSDT 00000000d7e9a870 01E48 (v01 A M I  POWERNOW 00000001 AMD  00000001)
ACPI: EINJ 00000000d7e9c6c0 00130 (v01  AMIER AMI_EINJ 20100909 MSFT 00000097)
ACPI: BERT 00000000d7e9c850 00030 (v01  AMIER AMI_BERT 20100909 MSFT 00000097)
ACPI: ERST 00000000d7e9c880 001B0 (v01  AMIER AMI_ERST 20100909 MSFT 00000097)
ACPI: HEST 00000000d7e9ca30 000A8 (v01  AMIER ABC_HEST 20100909 MSFT 00000097)
ACPI: Local APIC address 0xfee00000
SRAT: PXM 0 -> APIC 0x10 -> Node 0
SRAT: PXM 0 -> APIC 0x11 -> Node 0
SRAT: PXM 0 -> APIC 0x12 -> Node 0
SRAT: PXM 0 -> APIC 0x13 -> Node 0
SRAT: PXM 0 -> APIC 0x14 -> Node 0
SRAT: PXM 0 -> APIC 0x15 -> Node 0
SRAT: PXM 1 -> APIC 0x16 -> Node 1
SRAT: PXM 1 -> APIC 0x17 -> Node 1
SRAT: PXM 1 -> APIC 0x18 -> Node 1
SRAT: PXM 1 -> APIC 0x19 -> Node 1
SRAT: PXM 1 -> APIC 0x1a -> Node 1
SRAT: PXM 1 -> APIC 0x1b -> Node 1
SRAT: Node 0 PXM 0 0-a0000
SRAT: Node 0 PXM 0 100000-d8000000
SRAT: Node 0 PXM 0 100000000-228000000
SRAT: Node 1 PXM 1 228000000-428000000
NUMA: Initialized distance table, cnt=2
NUMA: Node 0 [0,a0000) + [100000,d8000000) -> [0,d8000000)
NUMA: Node 0 [0,d8000000) + [100000000,228000000) -> [0,228000000)
NUMA: Allocated memnodemap from 427fffec0 - 428000000
NUMA: Using 27 for the hash shift.
Initmem setup node 0 0000000000000000-0000000228000000
  NODE_DATA [0000000227fd9000 - 0000000227ffffff]
Initmem setup node 1 0000000228000000-0000000428000000
  NODE_DATA [0000000427fd7000 - 0000000427ffdfff]
[ffffea00078c0000-ffffea00079fffff] potential offnode page_structs
 [ffffea0000000000-ffffea00079fffff] PMD -> [ffff88021fe00000-ffff880226ffffff] on node 0
 [ffffea0007a00000-ffffea000e9fffff] PMD -> [ffff88041f600000-ffff8804265fffff] on node 1
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00428000
Movable zone start PFN for each node
early_node_map[4] active PFN ranges
    0: 0x00000010 -> 0x0000009d
    0: 0x00000100 -> 0x000d7e80
    0: 0x00100000 -> 0x00228000
    1: 0x00228000 -> 0x00428000
On node 0 totalpages: 2096653
  DMA zone: 56 pages used for memmap
  DMA zone: 5 pages reserved
  DMA zone: 3920 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 865976 pages, LIFO batch:31
  Normal zone: 16576 pages used for memmap
  Normal zone: 1195840 pages, LIFO batch:31
On node 1 totalpages: 2097152
  Normal zone: 28672 pages used for memmap
  Normal zone: 2068480 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x10] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x11] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x12] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x13] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x14] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x15] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x16] enabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x17] enabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x18] enabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x19] enabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x1a] enabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x1b] enabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x8c] disabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x8d] disabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x8e] disabled)
ACPI: LAPIC (acpi_id[0x10] lapic_id[0x8f] disabled)
ACPI: LAPIC (acpi_id[0x11] lapic_id[0x90] disabled)
ACPI: LAPIC (acpi_id[0x12] lapic_id[0x91] disabled)
ACPI: LAPIC (acpi_id[0x13] lapic_id[0x92] disabled)
ACPI: LAPIC (acpi_id[0x14] lapic_id[0x93] disabled)
ACPI: LAPIC (acpi_id[0x15] lapic_id[0x94] disabled)
ACPI: LAPIC (acpi_id[0x16] lapic_id[0x95] disabled)
ACPI: LAPIC (acpi_id[0x17] lapic_id[0x96] disabled)
ACPI: LAPIC (acpi_id[0x18] lapic_id[0x97] disabled)
ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 0, version 33, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8300 base: 0xfed00000
SMP: Allowing 24 CPUs, 12 hotplug CPUs
nr_irqs_gsi: 40
Allocating PCI resources starting at f0000000 (gap: f0000000:fe00000)
Booting paravirtualized kernel on bare hardware
setup_percpu: NR_CPUS:4096 nr_cpumask_bits:24 nr_cpu_ids:24 nr_node_ids:2
PERCPU: Embedded 29 pages/cpu @ffff880227c00000 s89280 r8192 d21312 u131072
pcpu-alloc: s89280 r8192 d21312 u131072 alloc=1*2097152
pcpu-alloc: [0] 00 01 02 03 04 05 12 14 16 18 20 22 -- -- -- -- 
pcpu-alloc: [1] 06 07 08 09 10 11 13 15 17 19 21 23 -- -- -- -- 
Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 4134216
Policy zone: Normal
Kernel command line: ro root=/dev/vg00/lv06 console=ttyS2,115200 hugepages=4096 nohalt
PID hash table entries: 4096 (order: 3, 32768 bytes)
Checking aperture...
No AGP bridge found
Node 0: aperture @ 4000000 size 32 MB
Aperture pointing to e820 RAM. Ignoring.
Your BIOS doesn't leave a aperture memory hole
Please enable the IOMMU option in the BIOS setup
This costs you 64 MB of RAM
Mapping aperture over 65536 KB of RAM @ c0000000
Memory: 16381060k/17432576k available (4511k kernel code, 657356k absent, 394160k reserved, 7763k data, 1476k init)
Hierarchical RCU implementation.
	RCU-based detection of stalled CPUs is disabled.
NR_IRQS:262400 nr_irqs:872 16
Extended CMOS year: 2000
Console: colour VGA+ 80x25
console [ttyS2] enabled
hpet clockevent registered
Fast TSC calibration using PIT
Detected 2200.130 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 4400.26 BogoMIPS (lpj=2200130)
pid_max: default: 32768 minimum: 301
Security Framework initialized
Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Mount-cache hash table entries: 256
tseg: 00d7f00000
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 6 MCE banks
ACPI: Core revision 20110316
ftrace: allocating 17729 entries in 70 pages
Setting APIC routing to physical flat
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: AMD Opteron(tm) Processor 6174 stepping 01
Performance Events: AMD PMU driver.
... version:                0
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             00007fffffffffff
... fixed-purpose events:   0
... event mask:             000000000000000f
Booting Node   0, Processors  #1
smpboot cpu 1: start_ip = 98000
 #2
smpboot cpu 2: start_ip = 98000
 #3
smpboot cpu 3: start_ip = 98000
 #4
smpboot cpu 4: start_ip = 98000
 #5
smpboot cpu 5: start_ip = 98000
 Ok.
Booting Node   1, Processors  #6
smpboot cpu 6: start_ip = 98000
 #7
smpboot cpu 7: start_ip = 98000
 #8
smpboot cpu 8: start_ip = 98000
 #9
smpboot cpu 9: start_ip = 98000
 #10
smpboot cpu 10: start_ip = 98000
 #11
smpboot cpu 11: start_ip = 98000
Brought up 12 CPUs
Total of 12 processors activated (52804.99 BogoMIPS).
devtmpfs: initialized
print_constraints: dummy: 
NET: Registered protocol family 16
node 0 link 3: io port [5000, efff]
TOM: 00000000d8000000 aka 3456M
Fam 10h mmconf [e0000000, efffffff]
node 0 link 3: mmio [db000000, dfffffff]
node 0 link 3: mmio [a0000, bffff]
node 0 link 3: mmio [f0000000, ffffffff]
TOM2: 0000000428000000 aka 17024M
bus: [00, 0c] on node 0 link 3
bus: 00 index 0 [io  0x0000-0xffff]
bus: 00 index 1 [mem 0xd8000000-0xdfffffff]
bus: 00 index 2 [mem 0x000a0000-0x000bffff]
bus: 00 index 3 [mem 0xf0000000-0xffffffff]
bus: 00 index 4 [mem 0x428000000-0xfcffffffff]
Extended Config Space enabled on 2 nodes
ACPI: bus type pci registered
PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
\_SB_:_OSC evaluation returned wrong type
_OSC request data:1 7 
ACPI: Executed 4 blocks of module-level executable AML code
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-0c])
pci_root PNP0A08:00: host bridge window [io  0x0000-0x03af]
pci_root PNP0A08:00: host bridge window [io  0x03e0-0x0cf7]
pci_root PNP0A08:00: host bridge window [io  0x03b0-0x03bb]
pci_root PNP0A08:00: host bridge window [io  0x03c0-0x03df]
pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
pci_root PNP0A08:00: host bridge window [mem 0x000d0000-0x000dffff]
pci_root PNP0A08:00: host bridge window [mem 0xde000000-0xdfffffff]
pci_root PNP0A08:00: host bridge window [mem 0xdb000000-0xddffffff]
pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed44fff]
pci 0000:00:00.0: [1002:5a10] type 0 class 0x000600
pci 0000:00:02.0: [1002:5a16] type 1 class 0x000604
pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
pci 0000:00:02.0: PME# disabled
pci 0000:00:04.0: [1002:5a18] type 1 class 0x000604
pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
pci 0000:00:04.0: PME# disabled
pci 0000:00:0b.0: [1002:5a1f] type 1 class 0x000604
pci 0000:00:0b.0: PME# supported from D0 D3hot D3cold
pci 0000:00:0b.0: PME# disabled
pci 0000:00:0c.0: [1002:5a20] type 1 class 0x000604
pci 0000:00:0c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:0c.0: PME# disabled
pci 0000:00:0d.0: [1002:5a1e] type 1 class 0x000604
pci 0000:00:0d.0: PME# supported from D0 D3hot D3cold
pci 0000:00:0d.0: PME# disabled
pci 0000:00:11.0: [1002:4390] type 0 class 0x000101
pci 0000:00:11.0: reg 10: [io  0x9000-0x9007]
pci 0000:00:11.0: reg 14: [io  0x8000-0x8003]
pci 0000:00:11.0: reg 18: [io  0x7000-0x7007]
pci 0000:00:11.0: reg 1c: [io  0x6000-0x6003]
pci 0000:00:11.0: reg 20: [io  0x5000-0x500f]
pci 0000:00:11.0: reg 24: [mem 0xdf6f8400-0xdf6f87ff]
pci 0000:00:11.0: set SATA to AHCI mode
pci 0000:00:12.0: [1002:4397] type 0 class 0x000c03
pci 0000:00:12.0: reg 10: [mem 0xdf6f7000-0xdf6f7fff]
pci 0000:00:12.1: [1002:4398] type 0 class 0x000c03
pci 0000:00:12.1: reg 10: [mem 0xdf6f6000-0xdf6f6fff]
pci 0000:00:12.2: [1002:4396] type 0 class 0x000c03
pci 0000:00:12.2: reg 10: [mem 0xdf6f8800-0xdf6f88ff]
pci 0000:00:12.2: supports D1 D2
pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
pci 0000:00:12.2: PME# disabled
pci 0000:00:13.0: [1002:4397] type 0 class 0x000c03
pci 0000:00:13.0: reg 10: [mem 0xdf6fa000-0xdf6fafff]
pci 0000:00:13.1: [1002:4398] type 0 class 0x000c03
pci 0000:00:13.1: reg 10: [mem 0xdf6f9000-0xdf6f9fff]
pci 0000:00:13.2: [1002:4396] type 0 class 0x000c03
pci 0000:00:13.2: reg 10: [mem 0xdf6f8c00-0xdf6f8cff]
pci 0000:00:13.2: supports D1 D2
pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
pci 0000:00:13.2: PME# disabled
pci 0000:00:14.0: [1002:4385] type 0 class 0x000c05
pci 0000:00:14.1: [1002:439c] type 0 class 0x000101
pci 0000:00:14.1: reg 10: [io  0x0000-0x0007]
pci 0000:00:14.1: reg 14: [io  0x0000-0x0003]
pci 0000:00:14.1: reg 18: [io  0x0000-0x0007]
pci 0000:00:14.1: reg 1c: [io  0x0000-0x0003]
pci 0000:00:14.1: reg 20: [io  0xff00-0xff0f]
pci 0000:00:14.3: [1002:439d] type 0 class 0x000601
pci 0000:00:14.4: [1002:4384] type 1 class 0x000604
pci 0000:00:14.5: [1002:4399] type 0 class 0x000c03
pci 0000:00:14.5: reg 10: [mem 0xdf6fb000-0xdf6fbfff]
pci 0000:00:18.0: [1022:1200] type 0 class 0x000600
pci 0000:00:18.1: [1022:1201] type 0 class 0x000600
pci 0000:00:18.2: [1022:1202] type 0 class 0x000600
pci 0000:00:18.3: [1022:1203] type 0 class 0x000600
pci 0000:00:18.4: [1022:1204] type 0 class 0x000600
pci 0000:00:19.0: [1022:1200] type 0 class 0x000600
pci 0000:00:19.1: [1022:1201] type 0 class 0x000600
pci 0000:00:19.2: [1022:1202] type 0 class 0x000600
pci 0000:00:19.3: [1022:1203] type 0 class 0x000600
pci 0000:00:19.4: [1022:1204] type 0 class 0x000600
pci 0000:09:00.0: [111d:8018] type 1 class 0x000604
pci 0000:09:00.0: PME# supported from D0 D3hot D3cold
pci 0000:09:00.0: PME# disabled
pci 0000:00:02.0: PCI bridge to [bus 09-0c]
pci 0000:00:02.0:   bridge window [io  0xd000-0xefff]
pci 0000:00:02.0:   bridge window [mem 0xdfe00000-0xdfffffff]
pci 0000:00:02.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:0a:02.0: [111d:8018] type 1 class 0x000604
pci 0000:0a:02.0: PME# supported from D0 D3hot D3cold
pci 0000:0a:02.0: PME# disabled
pci 0000:0a:04.0: [111d:8018] type 1 class 0x000604
pci 0000:0a:04.0: PME# supported from D0 D3hot D3cold
pci 0000:0a:04.0: PME# disabled
pci 0000:09:00.0: PCI bridge to [bus 0a-0c]
pci 0000:09:00.0:   bridge window [io  0xd000-0xefff]
pci 0000:09:00.0:   bridge window [mem 0xdfe00000-0xdfffffff]
pci 0000:09:00.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:0c:00.0: [8086:10bc] type 0 class 0x000200
pci 0000:0c:00.0: reg 10: [mem 0xdffe0000-0xdfffffff]
pci 0000:0c:00.0: reg 14: [mem 0xdffc0000-0xdffdffff]
pci 0000:0c:00.0: reg 18: [io  0xe800-0xe81f]
pci 0000:0c:00.0: reg 30: [mem 0xdffa0000-0xdffbffff pref]
pci 0000:0c:00.0: PME# supported from D0 D3hot D3cold
pci 0000:0c:00.0: PME# disabled
pci 0000:0c:00.1: [8086:10bc] type 0 class 0x000200
pci 0000:0c:00.1: reg 10: [mem 0xdff80000-0xdff9ffff]
pci 0000:0c:00.1: reg 14: [mem 0xdff60000-0xdff7ffff]
pci 0000:0c:00.1: reg 18: [io  0xe400-0xe41f]
pci 0000:0c:00.1: reg 30: [mem 0xdff40000-0xdff5ffff pref]
pci 0000:0c:00.1: PME# supported from D0 D3hot D3cold
pci 0000:0c:00.1: PME# disabled
pci 0000:0c:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:0a:02.0: PCI bridge to [bus 0c-0c]
pci 0000:0a:02.0:   bridge window [io  0xe000-0xefff]
pci 0000:0a:02.0:   bridge window [mem 0xdff00000-0xdfffffff]
pci 0000:0a:02.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:0b:00.0: [8086:10bc] type 0 class 0x000200
pci 0000:0b:00.0: reg 10: [mem 0xdfee0000-0xdfefffff]
pci 0000:0b:00.0: reg 14: [mem 0xdfec0000-0xdfedffff]
pci 0000:0b:00.0: reg 18: [io  0xd800-0xd81f]
pci 0000:0b:00.0: reg 30: [mem 0xdfea0000-0xdfebffff pref]
pci 0000:0b:00.0: PME# supported from D0 D3hot
pci 0000:0b:00.0: PME# disabled
pci 0000:0b:00.1: [8086:10bc] type 0 class 0x000200
pci 0000:0b:00.1: reg 10: [mem 0xdfe80000-0xdfe9ffff]
pci 0000:0b:00.1: reg 14: [mem 0xdfe60000-0xdfe7ffff]
pci 0000:0b:00.1: reg 18: [io  0xd400-0xd41f]
pci 0000:0b:00.1: reg 30: [mem 0xdfe40000-0xdfe5ffff pref]
pci 0000:0b:00.1: PME# supported from D0 D3hot
pci 0000:0b:00.1: PME# disabled
pci 0000:0b:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:0a:04.0: PCI bridge to [bus 0b-0b]
pci 0000:0a:04.0:   bridge window [io  0xd000-0xdfff]
pci 0000:0a:04.0:   bridge window [mem 0xdfe00000-0xdfefffff]
pci 0000:0a:04.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:08:00.0: [8086:105e] type 0 class 0x000200
pci 0000:08:00.0: reg 10: [mem 0xdfde0000-0xdfdfffff]
pci 0000:08:00.0: reg 14: [mem 0xdfdc0000-0xdfddffff]
pci 0000:08:00.0: reg 18: [io  0xc800-0xc81f]
pci 0000:08:00.0: reg 30: [mem 0xdfda0000-0xdfdbffff pref]
pci 0000:08:00.0: PME# supported from D0 D3hot D3cold
pci 0000:08:00.0: PME# disabled
pci 0000:08:00.1: [8086:105e] type 0 class 0x000200
pci 0000:08:00.1: reg 10: [mem 0xdfd80000-0xdfd9ffff]
pci 0000:08:00.1: reg 14: [mem 0xdfd60000-0xdfd7ffff]
pci 0000:08:00.1: reg 18: [io  0xc400-0xc41f]
pci 0000:08:00.1: reg 30: [mem 0xdfd40000-0xdfd5ffff pref]
pci 0000:08:00.1: PME# supported from D0 D3hot D3cold
pci 0000:08:00.1: PME# disabled
pci 0000:08:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:00:04.0: PCI bridge to [bus 08-08]
pci 0000:00:04.0:   bridge window [io  0xc000-0xcfff]
pci 0000:00:04.0:   bridge window [mem 0xdfd00000-0xdfdfffff]
pci 0000:00:04.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:04:00.0: [111d:806a] type 1 class 0x000604
pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
pci 0000:04:00.0: PME# disabled
pci 0000:00:0b.0: PCI bridge to [bus 04-07]
pci 0000:00:0b.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:0b.0:   bridge window [mem 0xdf900000-0xdfcfffff]
pci 0000:00:0b.0:   bridge window [mem 0xdc000000-0xddffffff 64bit pref]
pci 0000:05:02.0: [111d:806a] type 1 class 0x000604
pci 0000:05:02.0: PME# supported from D0 D3hot D3cold
pci 0000:05:02.0: PME# disabled
pci 0000:05:04.0: [111d:806a] type 1 class 0x000604
pci 0000:05:04.0: PME# supported from D0 D3hot D3cold
pci 0000:05:04.0: PME# disabled
pci 0000:04:00.0: PCI bridge to [bus 05-07]
pci 0000:04:00.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:04:00.0:   bridge window [mem 0xdf900000-0xdfcfffff]
pci 0000:04:00.0:   bridge window [mem 0xdc000000-0xddffffff 64bit pref]
pci 0000:07:00.0: [14c1:0008] type 0 class 0x000200
pci 0000:07:00.0: reg 10: [mem 0xdd000000-0xddffffff 64bit pref]
pci 0000:07:00.0: reg 18: [mem 0xdfc00000-0xdfcfffff 64bit]
pci 0000:07:00.0: reg 30: [mem 0xdfb80000-0xdfbfffff pref]
pci 0000:05:02.0: PCI bridge to [bus 07-07]
pci 0000:05:02.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:05:02.0:   bridge window [mem 0xdfb00000-0xdfcfffff]
pci 0000:05:02.0:   bridge window [mem 0xdd000000-0xddffffff 64bit pref]
pci 0000:06:00.0: [14c1:0008] type 0 class 0x000200
pci 0000:06:00.0: reg 10: [mem 0xdc000000-0xdcffffff 64bit pref]
pci 0000:06:00.0: reg 18: [mem 0xdfa00000-0xdfafffff 64bit]
pci 0000:06:00.0: reg 30: [mem 0xdf980000-0xdf9fffff pref]
pci 0000:05:04.0: PCI bridge to [bus 06-06]
pci 0000:05:04.0:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:05:04.0:   bridge window [mem 0xdf900000-0xdfafffff]
pci 0000:05:04.0:   bridge window [mem 0xdc000000-0xdcffffff 64bit pref]
pci 0000:03:00.0: [1000:0072] type 0 class 0x000107
pci 0000:03:00.0: reg 10: [io  0xb000-0xb0ff]
pci 0000:03:00.0: reg 14: [mem 0xdf83c000-0xdf83ffff 64bit]
pci 0000:03:00.0: reg 1c: [mem 0xdf840000-0xdf87ffff 64bit]
pci 0000:03:00.0: reg 30: [mem 0xdf880000-0xdf8fffff pref]
pci 0000:03:00.0: supports D1 D2
pci 0000:00:0c.0: PCI bridge to [bus 03-03]
pci 0000:00:0c.0:   bridge window [io  0xb000-0xbfff]
pci 0000:00:0c.0:   bridge window [mem 0xdf800000-0xdf8fffff]
pci 0000:00:0c.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:02:00.0: [8086:10c9] type 0 class 0x000200
pci 0000:02:00.0: reg 10: [mem 0xdf7e0000-0xdf7fffff]
pci 0000:02:00.0: reg 14: [mem 0xdf7c0000-0xdf7dffff]
pci 0000:02:00.0: reg 18: [io  0xa800-0xa81f]
pci 0000:02:00.0: reg 1c: [mem 0xdf79c000-0xdf79ffff]
pci 0000:02:00.0: reg 30: [mem 0xdf7a0000-0xdf7bffff pref]
pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
pci 0000:02:00.0: PME# disabled
pci 0000:02:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: [8086:10c9] type 0 class 0x000200
pci 0000:02:00.1: reg 10: [mem 0xdf760000-0xdf77ffff]
pci 0000:02:00.1: reg 14: [mem 0xdf740000-0xdf75ffff]
pci 0000:02:00.1: reg 18: [io  0xa400-0xa41f]
pci 0000:02:00.1: reg 1c: [mem 0xdf71c000-0xdf71ffff]
pci 0000:02:00.1: reg 30: [mem 0xdf720000-0xdf73ffff pref]
pci 0000:02:00.1: PME# supported from D0 D3hot D3cold
pci 0000:02:00.1: PME# disabled
pci 0000:02:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:00:0d.0: PCI bridge to [bus 02-02]
pci 0000:00:0d.0:   bridge window [io  0xa000-0xafff]
pci 0000:00:0d.0:   bridge window [mem 0xdf700000-0xdf7fffff]
pci 0000:00:0d.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:01:04.0: [102b:0532] type 0 class 0x000300
pci 0000:01:04.0: reg 10: [mem 0xdb000000-0xdbffffff pref]
pci 0000:01:04.0: reg 14: [mem 0xde7fc000-0xde7fffff]
pci 0000:01:04.0: reg 18: [mem 0xde800000-0xdeffffff]
pci 0000:00:14.4: PCI bridge to [bus 01-01] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0xf000-0x0000] (disabled)
pci 0000:00:14.4:   bridge window [mem 0xde700000-0xdeffffff]
pci 0000:00:14.4:   bridge window [mem 0xdb000000-0xdbffffff pref]
pci 0000:00:14.4:   bridge window [io  0x0000-0x03af] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x03e0-0x0cf7] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x03b0-0x03bb] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x03c0-0x03df] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xde000000-0xdfffffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xdb000000-0xddffffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xfed40000-0xfed44fff] (subtractive decode)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PC02._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PC04._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PC0B._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PC._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PC0C._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PC0D._PRT]
 pci0000:00: Requesting ACPI _OSC control (0x1d)
 pci0000:00: ACPI _OSC control (0x1d) granted
ACPI: PCI Interrupt Link [LNKA] (IRQs 4 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 4 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 4 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 4 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKF] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 4 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 4 7 10 11 12 14 15) *0, disabled.
vgaarb: device added: PCI:0000:01:04.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
reserve RAM buffer: 000000000009dc00 - 000000000009ffff 
reserve RAM buffer: 00000000d7e80000 - 00000000d7ffffff 
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 32-bit 14.318180 MHz counter
Switching to clocksource hpet
Switched to NOHz mode on CPU #0
Switched to NOHz mode on CPU #6
Switched to NOHz mode on CPU #1
Switched to NOHz mode on CPU #8
Switched to NOHz mode on CPU #5
Switched to NOHz mode on CPU #3
Switched to NOHz mode on CPU #7
Switched to NOHz mode on CPU #4
Switched to NOHz mode on CPU #2
Switched to NOHz mode on CPU #9
Switched to NOHz mode on CPU #10
Switched to NOHz mode on CPU #11
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: [bus 00-0c]
pnp 00:00: [io  0x0cf8-0x0cff]
pnp 00:00: [io  0x0000-0x03af window]
pnp 00:00: [io  0x03e0-0x0cf7 window]
pnp 00:00: [io  0x03b0-0x03bb window]
pnp 00:00: [io  0x03c0-0x03df window]
pnp 00:00: [io  0x0d00-0xffff window]
pnp 00:00: [mem 0x000a0000-0x000bffff window]
pnp 00:00: [mem 0x000d0000-0x000dffff window]
pnp 00:00: [mem 0xde000000-0xdfffffff window]
pnp 00:00: [mem 0xdb000000-0xddffffff window]
pnp 00:00: [mem 0xfed40000-0xfed44fff]
pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:02: [mem 0x00000000-0xffffffffffffffff disabled]
system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:03: [dma 4]
pnp 00:03: [io  0x0000-0x000f]
pnp 00:03: [io  0x0081-0x0083]
pnp 00:03: [io  0x0087]
pnp 00:03: [io  0x0089-0x008b]
pnp 00:03: [io  0x008f]
pnp 00:03: [io  0x00c0-0x00df]
pnp 00:03: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:04: [io  0x0070-0x0071]
pnp 00:04: [irq 8]
pnp 00:04: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:05: [io  0x0061]
pnp 00:05: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:06: [io  0x00f0-0x00ff]
pnp 00:06: [irq 13]
pnp 00:06: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:07: [mem 0xfed00000-0xfed003ff]
pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:08: [io  0x0060]
pnp 00:08: [io  0x0064]
pnp 00:08: [mem 0xfec00000-0xfec00fff]
pnp 00:08: [mem 0xfee00000-0xfee00fff]
system 00:08: [mem 0xfec00000-0xfec00fff] could not be reserved
system 00:08: [mem 0xfee00000-0xfee00fff] has been reserved
system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: [io  0x0010-0x001f]
pnp 00:09: [io  0x0022-0x003f]
pnp 00:09: [io  0x0062-0x0063]
pnp 00:09: [io  0x0065-0x006f]
pnp 00:09: [io  0x0072-0x007f]
pnp 00:09: [io  0x0080]
pnp 00:09: [io  0x0084-0x0086]
pnp 00:09: [io  0x0088]
pnp 00:09: [io  0x008c-0x008e]
pnp 00:09: [io  0x0090-0x009f]
pnp 00:09: [io  0x00a2-0x00bf]
pnp 00:09: [io  0x00b1]
pnp 00:09: [io  0x00e0-0x00ef]
pnp 00:09: [io  0x0ca2-0x0ca3]
pnp 00:09: [io  0x0550-0x0551]
pnp 00:09: [io  0x04d0-0x04d1]
pnp 00:09: [io  0x040b]
pnp 00:09: [io  0x04d6]
pnp 00:09: [io  0x0c00-0x0c01]
pnp 00:09: [io  0x0c14]
pnp 00:09: [io  0x0c50-0x0c51]
pnp 00:09: [io  0x0c52]
pnp 00:09: [io  0x0c6c]
pnp 00:09: [io  0x0c6f]
pnp 00:09: [io  0x0cd0-0x0cd1]
pnp 00:09: [io  0x0cd2-0x0cd3]
pnp 00:09: [io  0x0cd4-0x0cd5]
pnp 00:09: [io  0x0cd6-0x0cd7]
pnp 00:09: [io  0x0cd8-0x0cdf]
pnp 00:09: [io  0x0800-0x089f]
pnp 00:09: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:09: [io  0x0b00-0x0b0f]
pnp 00:09: [io  0x0b20-0x0b3f]
pnp 00:09: [io  0x0900-0x090f]
pnp 00:09: [io  0x0910-0x091f]
pnp 00:09: [io  0xfe00-0xfefe]
pnp 00:09: [io  0x0060]
pnp 00:09: [io  0x0064]
pnp 00:09: [mem 0xffb80000-0xffbfffff]
pnp 00:09: [mem 0xfec10000-0xfec1001f]
system 00:09: [io  0x0ca2-0x0ca3] has been reserved
system 00:09: [io  0x0550-0x0551] has been reserved
system 00:09: [io  0x04d0-0x04d1] has been reserved
system 00:09: [io  0x040b] has been reserved
system 00:09: [io  0x04d6] has been reserved
system 00:09: [io  0x0c00-0x0c01] has been reserved
system 00:09: [io  0x0c14] has been reserved
system 00:09: [io  0x0c50-0x0c51] has been reserved
system 00:09: [io  0x0c52] has been reserved
system 00:09: [io  0x0c6c] has been reserved
system 00:09: [io  0x0c6f] has been reserved
system 00:09: [io  0x0cd0-0x0cd1] has been reserved
system 00:09: [io  0x0cd2-0x0cd3] has been reserved
system 00:09: [io  0x0cd4-0x0cd5] has been reserved
system 00:09: [io  0x0cd6-0x0cd7] has been reserved
system 00:09: [io  0x0cd8-0x0cdf] has been reserved
system 00:09: [io  0x0800-0x089f] has been reserved
system 00:09: [io  0x0b00-0x0b0f] has been reserved
system 00:09: [io  0x0b20-0x0b3f] has been reserved
system 00:09: [io  0x0900-0x090f] has been reserved
system 00:09: [io  0x0910-0x091f] has been reserved
system 00:09: [io  0xfe00-0xfefe] has been reserved
system 00:09: [mem 0xffb80000-0xffbfffff] has been reserved
system 00:09: [mem 0xfec10000-0xfec1001f] has been reserved
system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0a: [io  0x03f8-0x03ff]
pnp 00:0a: [irq 4]
pnp 00:0a: [dma 0 disabled]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0b: [io  0x02f8-0x02ff]
pnp 00:0b: [irq 3]
pnp 00:0b: [dma 0 disabled]
pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0c: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:0c: [io  0x0a00-0x0a0f]
pnp 00:0c: [io  0x0a10-0x0a1f]
system 00:0c: [io  0x0a00-0x0a0f] has been reserved
system 00:0c: [io  0x0a10-0x0a1f] has been reserved
system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0d: [io  0x03e8-0x03ef]
pnp 00:0d: [irq 7]
pnp 00:0d: [dma 0 disabled]
pnp 00:0d: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0e: [io  0x164e-0x164f]
pnp 00:0e: [io  0x0000-0xffffffffffffffff disabled]
system 00:0e: [io  0x164e-0x164f] has been reserved
system 00:0e: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0f: [mem 0xe0000000-0xefffffff]
system 00:0f: [mem 0xe0000000-0xefffffff] has been reserved
system 00:0f: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:10: [mem 0x000c0000-0x000cffff]
pnp 00:10: [mem 0x000e0000-0x000fffff]
pnp 00:10: [mem 0xfec00000-0xffffffff]
system 00:10: [mem 0x000c0000-0x000cffff] has been reserved
system 00:10: [mem 0x000e0000-0x000fffff] could not be reserved
system 00:10: [mem 0xfec00000-0xffffffff] could not be reserved
system 00:10: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp: PnP ACPI: found 17 devices
ACPI: ACPI bus type pnp unregistered
pci 0000:0a:02.0: PCI bridge to [bus 0c-0c]
pci 0000:0a:02.0:   bridge window [io  0xe000-0xefff]
pci 0000:0a:02.0:   bridge window [mem 0xdff00000-0xdfffffff]
pci 0000:0a:02.0:   bridge window [mem pref disabled]
pci 0000:0a:04.0: PCI bridge to [bus 0b-0b]
pci 0000:0a:04.0:   bridge window [io  0xd000-0xdfff]
pci 0000:0a:04.0:   bridge window [mem 0xdfe00000-0xdfefffff]
pci 0000:0a:04.0:   bridge window [mem pref disabled]
pci 0000:09:00.0: PCI bridge to [bus 0a-0c]
pci 0000:09:00.0:   bridge window [io  0xd000-0xefff]
pci 0000:09:00.0:   bridge window [mem 0xdfe00000-0xdfffffff]
pci 0000:09:00.0:   bridge window [mem pref disabled]
pci 0000:00:02.0: PCI bridge to [bus 09-0c]
pci 0000:00:02.0:   bridge window [io  0xd000-0xefff]
pci 0000:00:02.0:   bridge window [mem 0xdfe00000-0xdfffffff]
pci 0000:00:02.0:   bridge window [mem pref disabled]
pci 0000:00:04.0: PCI bridge to [bus 08-08]
pci 0000:00:04.0:   bridge window [io  0xc000-0xcfff]
pci 0000:00:04.0:   bridge window [mem 0xdfd00000-0xdfdfffff]
pci 0000:00:04.0:   bridge window [mem pref disabled]
pci 0000:05:02.0: PCI bridge to [bus 07-07]
pci 0000:05:02.0:   bridge window [io  disabled]
pci 0000:05:02.0:   bridge window [mem 0xdfb00000-0xdfcfffff]
pci 0000:05:02.0:   bridge window [mem 0xdd000000-0xddffffff 64bit pref]
pci 0000:05:04.0: PCI bridge to [bus 06-06]
pci 0000:05:04.0:   bridge window [io  disabled]
pci 0000:05:04.0:   bridge window [mem 0xdf900000-0xdfafffff]
pci 0000:05:04.0:   bridge window [mem 0xdc000000-0xdcffffff 64bit pref]
pci 0000:04:00.0: PCI bridge to [bus 05-07]
pci 0000:04:00.0:   bridge window [io  disabled]
pci 0000:04:00.0:   bridge window [mem 0xdf900000-0xdfcfffff]
pci 0000:04:00.0:   bridge window [mem 0xdc000000-0xddffffff 64bit pref]
pci 0000:00:0b.0: PCI bridge to [bus 04-07]
pci 0000:00:0b.0:   bridge window [io  disabled]
pci 0000:00:0b.0:   bridge window [mem 0xdf900000-0xdfcfffff]
pci 0000:00:0b.0:   bridge window [mem 0xdc000000-0xddffffff 64bit pref]
pci 0000:00:0c.0: PCI bridge to [bus 03-03]
pci 0000:00:0c.0:   bridge window [io  0xb000-0xbfff]
pci 0000:00:0c.0:   bridge window [mem 0xdf800000-0xdf8fffff]
pci 0000:00:0c.0:   bridge window [mem pref disabled]
pci 0000:02:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: BAR 7: can't assign mem (size 0x20000)
pci 0000:02:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.0: BAR 10: can't assign mem (size 0x20000)
pci 0000:02:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: BAR 7: can't assign mem (size 0x20000)
pci 0000:02:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
pci 0000:02:00.1: BAR 10: can't assign mem (size 0x20000)
pci 0000:00:0d.0: PCI bridge to [bus 02-02]
pci 0000:00:0d.0:   bridge window [io  0xa000-0xafff]
pci 0000:00:0d.0:   bridge window [mem 0xdf700000-0xdf7fffff]
pci 0000:00:0d.0:   bridge window [mem pref disabled]
pci 0000:00:14.4: PCI bridge to [bus 01-01]
pci 0000:00:14.4:   bridge window [io  disabled]
pci 0000:00:14.4:   bridge window [mem 0xde700000-0xdeffffff]
pci 0000:00:14.4:   bridge window [mem 0xdb000000-0xdbffffff pref]
pci 0000:00:02.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
pci 0000:00:02.0: setting latency timer to 64
pci 0000:09:00.0: setting latency timer to 64
pci 0000:0a:02.0: setting latency timer to 64
pci 0000:0a:04.0: setting latency timer to 64
pci 0000:00:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:04.0: setting latency timer to 64
pci 0000:00:0b.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
pci 0000:00:0b.0: setting latency timer to 64
pci 0000:04:00.0: setting latency timer to 64
pci 0000:05:02.0: setting latency timer to 64
pci 0000:05:04.0: setting latency timer to 64
pci 0000:00:0c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:0c.0: setting latency timer to 64
pci 0000:00:0d.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:0d.0: setting latency timer to 64
pci_bus 0000:00: resource 4 [io  0x0000-0x03af]
pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7]
pci_bus 0000:00: resource 6 [io  0x03b0-0x03bb]
pci_bus 0000:00: resource 7 [io  0x03c0-0x03df]
pci_bus 0000:00: resource 8 [io  0x0d00-0xffff]
pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 10 [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: resource 11 [mem 0xde000000-0xdfffffff]
pci_bus 0000:00: resource 12 [mem 0xdb000000-0xddffffff]
pci_bus 0000:00: resource 13 [mem 0xfed40000-0xfed44fff]
pci_bus 0000:09: resource 0 [io  0xd000-0xefff]
pci_bus 0000:09: resource 1 [mem 0xdfe00000-0xdfffffff]
pci_bus 0000:0a: resource 0 [io  0xd000-0xefff]
pci_bus 0000:0a: resource 1 [mem 0xdfe00000-0xdfffffff]
pci_bus 0000:0c: resource 0 [io  0xe000-0xefff]
pci_bus 0000:0c: resource 1 [mem 0xdff00000-0xdfffffff]
pci_bus 0000:0b: resource 0 [io  0xd000-0xdfff]
pci_bus 0000:0b: resource 1 [mem 0xdfe00000-0xdfefffff]
pci_bus 0000:08: resource 0 [io  0xc000-0xcfff]
pci_bus 0000:08: resource 1 [mem 0xdfd00000-0xdfdfffff]
pci_bus 0000:04: resource 1 [mem 0xdf900000-0xdfcfffff]
pci_bus 0000:04: resource 2 [mem 0xdc000000-0xddffffff 64bit pref]
pci_bus 0000:05: resource 1 [mem 0xdf900000-0xdfcfffff]
pci_bus 0000:05: resource 2 [mem 0xdc000000-0xddffffff 64bit pref]
pci_bus 0000:07: resource 1 [mem 0xdfb00000-0xdfcfffff]
pci_bus 0000:07: resource 2 [mem 0xdd000000-0xddffffff 64bit pref]
pci_bus 0000:06: resource 1 [mem 0xdf900000-0xdfafffff]
pci_bus 0000:06: resource 2 [mem 0xdc000000-0xdcffffff 64bit pref]
pci_bus 0000:03: resource 0 [io  0xb000-0xbfff]
pci_bus 0000:03: resource 1 [mem 0xdf800000-0xdf8fffff]
pci_bus 0000:02: resource 0 [io  0xa000-0xafff]
pci_bus 0000:02: resource 1 [mem 0xdf700000-0xdf7fffff]
pci_bus 0000:01: resource 1 [mem 0xde700000-0xdeffffff]
pci_bus 0000:01: resource 2 [mem 0xdb000000-0xdbffffff pref]
pci_bus 0000:01: resource 4 [io  0x0000-0x03af]
pci_bus 0000:01: resource 5 [io  0x03e0-0x0cf7]
pci_bus 0000:01: resource 6 [io  0x03b0-0x03bb]
pci_bus 0000:01: resource 7 [io  0x03c0-0x03df]
pci_bus 0000:01: resource 8 [io  0x0d00-0xffff]
pci_bus 0000:01: resource 9 [mem 0x000a0000-0x000bffff]
pci_bus 0000:01: resource 10 [mem 0x000d0000-0x000dffff]
pci_bus 0000:01: resource 11 [mem 0xde000000-0xdfffffff]
pci_bus 0000:01: resource 12 [mem 0xdb000000-0xddffffff]
pci_bus 0000:01: resource 13 [mem 0xfed40000-0xfed44fff]
NET: Registered protocol family 2
IP route cache hash table entries: 524288 (order: 10, 4194304 bytes)
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
UDP hash table entries: 8192 (order: 6, 262144 bytes)
UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
NET: Registered protocol family 1
pci 0000:01:04.0: Boot video device
PCI: CLS 64 bytes, default 64
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 11900k freed
PCI-DMA: Disabling AGP.
PCI-DMA: aperture base @ c0000000 size 65536 KB
PCI-DMA: using GART IOMMU.
PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
HugeTLB registered 2 MB page size, pre-allocated 4096 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 32146
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
pcieport 0000:00:02.0: setting latency timer to 64
pcieport 0000:00:02.0: irq 40 for MSI/MSI-X
pcieport 0000:00:04.0: setting latency timer to 64
pcieport 0000:00:04.0: irq 41 for MSI/MSI-X
pcieport 0000:00:0b.0: setting latency timer to 64
pcieport 0000:00:0b.0: irq 42 for MSI/MSI-X
pcieport 0000:00:0c.0: setting latency timer to 64
pcieport 0000:00:0c.0: irq 43 for MSI/MSI-X
pcieport 0000:00:0d.0: setting latency timer to 64
pcieport 0000:00:0d.0: irq 44 for MSI/MSI-X
pcieport 0000:09:00.0: setting latency timer to 64
pcieport 0000:0a:02.0: setting latency timer to 64
pcieport 0000:0a:02.0: irq 45 for MSI/MSI-X
pcieport 0000:0a:04.0: setting latency timer to 64
pcieport 0000:0a:04.0: irq 46 for MSI/MSI-X
pcieport 0000:04:00.0: setting latency timer to 64
pcieport 0000:05:02.0: setting latency timer to 64
pcieport 0000:05:02.0: irq 47 for MSI/MSI-X
pcieport 0000:05:04.0: setting latency timer to 64
pcieport 0000:05:04.0: irq 48 for MSI/MSI-X
pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
pcieport 0000:09:00.0: Signaling PME through PCIe PME interrupt
pcieport 0000:0a:02.0: Signaling PME through PCIe PME interrupt
pci 0000:0c:00.0: Signaling PME through PCIe PME interrupt
pci 0000:0c:00.1: Signaling PME through PCIe PME interrupt
pcieport 0000:0a:04.0: Signaling PME through PCIe PME interrupt
pci 0000:0b:00.0: Signaling PME through PCIe PME interrupt
pci 0000:0b:00.1: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:04.0: Signaling PME through PCIe PME interrupt
pci 0000:08:00.0: Signaling PME through PCIe PME interrupt
pci 0000:08:00.1: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:04.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:0b.0: Signaling PME through PCIe PME interrupt
pcieport 0000:04:00.0: Signaling PME through PCIe PME interrupt
pcieport 0000:05:02.0: Signaling PME through PCIe PME interrupt
pci 0000:07:00.0: Signaling PME through PCIe PME interrupt
pcieport 0000:05:04.0: Signaling PME through PCIe PME interrupt
pci 0000:06:00.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:0b.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:0c.0: Signaling PME through PCIe PME interrupt
pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:0c.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:0d.0: Signaling PME through PCIe PME interrupt
pci 0000:02:00.0: Signaling PME through PCIe PME interrupt
pci 0000:02:00.1: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:0d.0:pcie01: service driver pcie_pme loaded
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ACPI: acpi_idle registered with cpuidle
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Refined TSC clocksource calibration: 2200.025 MHz.
Switching to clocksource tsc
serial8250: ttyS2 at I/O 0x3e8 (irq = 7) is a 16550A
00:0a: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:0b: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
00:0d: ttyS2 at I/O 0x3e8 (irq = 7) is a 16550A
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
brd: module loaded
loop: module loaded
Fixed MDIO Bus: probed
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:12.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ehci_hcd 0000:00:12.2: EHCI Host Controller
ehci_hcd 0000:00:12.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
ehci_hcd 0000:00:12.2: debug port 1
ehci_hcd 0000:00:12.2: irq 17, io mem 0xdf6f8800
ehci_hcd 0000:00:12.2: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.39.4 ehci_hcd
usb usb1: SerialNumber: 0000:00:12.2
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ehci_hcd 0000:00:13.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ehci_hcd 0000:00:13.2: EHCI Host Controller
ehci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
ehci_hcd 0000:00:13.2: debug port 1
ehci_hcd 0000:00:13.2: irq 19, io mem 0xdf6f8c00
ehci_hcd 0000:00:13.2: USB 2.0 started, EHCI 1.00
usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.39.4 ehci_hcd
usb usb2: SerialNumber: 0000:00:13.2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:12.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:12.0: OHCI Host Controller
ohci_hcd 0000:00:12.0: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:12.0: irq 16, io mem 0xdf6f7000
usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: OHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.39.4 ohci_hcd
usb usb3: SerialNumber: 0000:00:12.0
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 3 ports detected
ohci_hcd 0000:00:12.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:12.1: OHCI Host Controller
ohci_hcd 0000:00:12.1: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:12.1: irq 16, io mem 0xdf6f6000
usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: OHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.39.4 ohci_hcd
usb usb4: SerialNumber: 0000:00:12.1
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 3 ports detected
ohci_hcd 0000:00:13.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 5
ohci_hcd 0000:00:13.0: irq 18, io mem 0xdf6fa000
usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb5: Product: OHCI Host Controller
usb usb5: Manufacturer: Linux 2.6.39.4 ohci_hcd
usb usb5: SerialNumber: 0000:00:13.0
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 3 ports detected
ohci_hcd 0000:00:13.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 6
ohci_hcd 0000:00:13.1: irq 18, io mem 0xdf6f9000
usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb6: Product: OHCI Host Controller
usb usb6: Manufacturer: Linux 2.6.39.4 ohci_hcd
usb usb6: SerialNumber: 0000:00:13.1
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 3 ports detected
ohci_hcd 0000:00:14.5: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:14.5: OHCI Host Controller
ohci_hcd 0000:00:14.5: new USB bus registered, assigned bus number 7
ohci_hcd 0000:00:14.5: irq 18, io mem 0xdf6fb000
usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb7: Product: OHCI Host Controller
usb usb7: Manufacturer: Linux 2.6.39.4 ohci_hcd
usb usb7: SerialNumber: 0000:00:14.5
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
uhci_hcd: USB Universal Host Controller Interface driver
i8042: PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mousedev: PS/2 mouse device common for all mice
rtc_cmos 00:04: RTC can wake from S4
rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
cpuidle: using governor ladder
cpuidle: using governor menu
EFI Variables Facility v0.08 2004-May-17
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
Registering the dns_resolver key type
registered taskstats version 1
IMA: No TPM chip found, activating TPM-bypass!
rtc_cmos 00:04: setting system clock to 2011-10-03 09:10:37 UTC (1317633037)
Initializing network drop monitor service
Freeing unused kernel memory: 1476k freed
Write protecting the kernel read-only data: 10240k
Freeing unused kernel memory: 1612k freed
Freeing unused kernel memory: 1928k freed
dracut: dracut-004-33.2.el6_0
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.20.0-ioctl (2011-02-02) initialised: dm-devel@redhat.com
udev: starting version 147
udevd (160): /proc/160/oom_adj is deprecated, please use /proc/160/oom_score_adj instead.
dracut: Starting plymouth daemon
mpt2sas version 08.100.00.00 loaded
scsi0 : Fusion MPT SAS Host
mpt2sas 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
mpt2sas 0000:03:00.0: setting latency timer to 64
mpt2sas0: 64 BIT PCI BUS DMA ADDRESSING SUPPORTED, total mem (16463928 kB)
mpt2sas 0000:03:00.0: irq 49 for MSI/MSI-X
mpt2sas0: PCI-MSI-X enabled: IRQ 49
mpt2sas0: iomem(0x00000000df83c000), mapped(0xffffc90001878000), size(16384)
mpt2sas0: ioport(0x000000000000b000), size(256)
usb 7-1: new full speed USB device number 2 using ohci_hcd
mpt2sas0: sending diag reset !!
usb 7-1: New USB device found, idVendor=0557, idProduct=2221
usb 7-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 7-1: Product: Hermon USB hidmouse Device
usb 7-1: Manufacturer: Winbond Electronics Corp
input: Winbond Electronics Corp Hermon USB hidmouse Device as /devices/pci0000:00/0000:00:14.5/usb7/7-1/7-1:1.0/input/input2
generic-usb 0003:0557:2221.0001: input,hidraw0: USB HID v1.00 Mouse [Winbond Electronics Corp Hermon USB hidmouse Device] on usb-0000:00:14.5-1/input0
input: Winbond Electronics Corp Hermon USB hidmouse Device as /devices/pci0000:00/0000:00:14.5/usb7/7-1/7-1:1.1/input/input3
generic-usb 0003:0557:2221.0002: input,hidraw1: USB HID v1.00 Keyboard [Winbond Electronics Corp Hermon USB hidmouse Device] on usb-0000:00:14.5-1/input1
mpt2sas0: diag reset: SUCCESS
mpt2sas0: Allocated physical memory: size(6835 kB)
mpt2sas0: Current Controller Queue Depth(3034), Max Controller Queue Depth(3167)
mpt2sas0: Scatter Gather Elements per IO(128)
mpt2sas0: LSISAS2008: FWVersion(02.00.50.00), ChipRevision(0x02), BiosVersion(07.01.01.00)
mpt2sas0: Protocol=(Initiator,Target), Capabilities=(Raid,TLR,EEDP,Snapshot Buffer,Diag Trace Buffer,Task Set Full,NCQ)
mpt2sas0: sending port enable !!
mpt2sas0: host_add: handle(0x0001), sas_addr(0x50030480003a2760), phys(8)
mpt2sas0: port enable: SUCCESS
scsi 0:0:0:0: Direct-Access     ATA      WDC WD3000HLFS-0 4V02 PQ: 0 ANSI: 5
scsi 0:0:0:0: SATA: handle(0x0009), sas_addr(0x4433221100000000), phy(0), device_name(0x4ee0500161d7561b)
scsi 0:0:0:0: SATA: enclosure_logical_id(0x50030480003a2760), slot(0)
scsi 0:0:0:0: atapi(n), ncq(y), asyn_notify(n), smart(y), fua(y), sw_preserve(y)
scsi 0:0:0:0: qdepth(32), tagged(1), simple(0), ordered(0), scsi_level(6), cmd_que(1)
scsi 0:0:1:0: Direct-Access     ATA      WDC WD20EARS-00S 0A80 PQ: 0 ANSI: 5
scsi 0:0:1:0: SATA: handle(0x000a), sas_addr(0x4433221104000000), phy(4), device_name(0x4ee2500145735934)
scsi 0:0:1:0: SATA: enclosure_logical_id(0x50030480003a2760), slot(4)
scsi 0:0:1:0: atapi(n), ncq(y), asyn_notify(n), smart(y), fua(y), sw_preserve(y)
scsi 0:0:1:0: qdepth(32), tagged(1), simple(0), ordered(0), scsi_level(6), cmd_que(1)
ahci 0000:00:11.0: version 3.0
ahci 0000:00:11.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
ahci 0000:00:11.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
ata1: SATA max UDMA/133 abar m1024@0xdf6f8400 port 0xdf6f8500 irq 22
ata2: SATA max UDMA/133 abar m1024@0xdf6f8400 port 0xdf6f8580 irq 22
ata3: SATA max UDMA/133 abar m1024@0xdf6f8400 port 0xdf6f8600 irq 22
ata4: SATA max UDMA/133 abar m1024@0xdf6f8400 port 0xdf6f8680 irq 22
ata3: SATA link down (SStatus 0 SControl 300)
ata2: SATA link down (SStatus 0 SControl 300)
ata1: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
pata_atiixp 0000:00:14.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pata_atiixp 0000:00:14.1: setting latency timer to 64
scsi5 : pata_atiixp
scsi6 : pata_atiixp
ata5: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xff00 irq 14
ata6: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xff08 irq 15
sd 0:0:1:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
sd 0:0:0:0: [sda] 586072368 512-byte logical blocks: (300 GB/279 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 73 00 00 08
sd 0:0:1:0: [sdb] Write Protect is off
sd 0:0:1:0: [sdb] Mode Sense: 73 00 00 08
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
 sdb: sdb1 sdb2 sdb3 sdb4 < sdb5 sdb6 sdb7 >
sd 0:0:1:0: [sdb] Attached SCSI disk
dracut: Scanning devices sda2 sdb2 sdb5 sdb7  for LVM volume groups 
dracut: Reading all physical volumes. This may take a while...
dracut: Found volume group "vg02" using metadata type lvm2
dracut: Found volume group "vg01" using metadata type lvm2
dracut: Found volume group "vg09" using metadata type lvm2
dracut: Found volume group "vg00" using metadata type lvm2
dracut: 1 logical volume(s) in volume group "vg02" now active
dracut: 1 logical volume(s) in volume group "vg01" now active
dracut: 3 logical volume(s) in volume group "vg09" now active
dracut: 4 logical volume(s) in volume group "vg00" now active
EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
dracut: Mounted root filesystem /dev/mapper/vg00-lv06
dracut: Loading SELinux policy
dracut: /sbin/load_policy: Can't load policy: No such device
dracut: Switching root
udev: starting version 147
sd 0:0:0:0: Attached scsi generic sg0 type 0
sd 0:0:1:0: Attached scsi generic sg1 type 0
piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00, revision 0
MCE: In-kernel MCE decoding enabled.
EDAC MC: Ver: 2.1.0 Oct  1 2011
AMD64 EDAC driver v3.4.0
EDAC amd64: DRAM ECC enabled.
EDAC amd64: F10h detected (node 0).
EDAC MC: DCT0 chip selects:
EDAC amd64: MC: 0:  1024MB 1:  1024MB
EDAC amd64: MC: 2:  1024MB 3:  1024MB
EDAC amd64: MC: 4:     0MB 5:     0MB
EDAC amd64: MC: 6:     0MB 7:     0MB
EDAC MC: DCT1 chip selects:
EDAC amd64: MC: 0:  1024MB 1:  1024MB
EDAC amd64: MC: 2:  1024MB 3:  1024MB
EDAC amd64: MC: 4:     0MB 5:     0MB
EDAC amd64: MC: 6:     0MB 7:     0MB
EDAC amd64: using x8 syndromes.
EDAC amd64: MCT channel count: 2
EDAC amd64: CS0: Unbuffered DDR3 RAM
EDAC amd64: CS1: Unbuffered DDR3 RAM
EDAC amd64: CS2: Unbuffered DDR3 RAM
EDAC amd64: CS3: Unbuffered DDR3 RAM
EDAC MC0: Giving out device to 'amd64_edac' 'F10h': DEV 0000:00:18.2
EDAC amd64: DRAM ECC enabled.
EDAC amd64: F10h detected (node 1).
EDAC MC: DCT0 chip selects:
EDAC amd64: MC: 0:  1024MB 1:  1024MB
EDAC amd64: MC: 2:  1024MB 3:  1024MB
EDAC amd64: MC: 4:     0MB 5:     0MB
EDAC amd64: MC: 6:     0MB 7:     0MB
EDAC MC: DCT1 chip selects:
EDAC amd64: MC: 0:  1024MB 1:  1024MB
EDAC amd64: MC: 2:  1024MB 3:  1024MB
EDAC amd64: MC: 4:     0MB 5:     0MB
EDAC amd64: MC: 6:     0MB 7:     0MB
EDAC amd64: using x8 syndromes.
EDAC amd64: MCT channel count: 2
EDAC amd64: CS0: Unbuffered DDR3 RAM
EDAC amd64: CS1: Unbuffered DDR3 RAM
EDAC amd64: CS2: Unbuffered DDR3 RAM
EDAC amd64: CS3: Unbuffered DDR3 RAM
EDAC MC1: Giving out device to 'amd64_edac' 'F10h': DEV 0000:00:19.2
EDAC PCI0: Giving out device to module 'amd64_edac' controller 'EDAC PCI controller': DEV '0000:00:18.2' (POLLED)
input: PC Speaker as /devices/platform/pcspkr/input/input4
EXT4-fs (dm-8): re-mounted. Opts: (null)
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sda1): using internal journal
EXT3-fs (sda1): mounted filesystem with ordered data mode
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (dm-7): using internal journal
EXT3-fs (dm-7): mounted filesystem with ordered data mode
EXT4-fs (dm-0): warning: maximal mount count reached, running e2fsck is recommended
EXT4-fs (dm-0): mounted filesystem with ordered data mode. Opts: journal_async_commit,commit=60,stripe=64
e1000e: Intel(R) PRO/1000 Network Driver - 1.6.2-NAPI
e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
e1000e 0000:0c:00.0: Disabling ASPM  L1
e1000e 0000:0c:00.0: PCI INT B -> GSI 17 (level, low) -> IRQ 17
e1000e 0000:0c:00.0: setting latency timer to 64
e1000e 0000:0c:00.0: irq 50 for MSI/MSI-X
e1000e 0000:0c:00.0: eth0: (PCI Express:2.5GT/s:Width x4) 00:15:17:bf:06:61
e1000e 0000:0c:00.0: eth0: Intel(R) PRO/1000 Network Connection
e1000e 0000:0c:00.0: eth0: MAC: 1, PHY: 4, PBA No: D64202-004
e1000e 0000:0c:00.1: Disabling ASPM  L1
e1000e 0000:0c:00.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
e1000e 0000:0c:00.1: setting latency timer to 64
e1000e 0000:0c:00.1: irq 51 for MSI/MSI-X
e1000e 0000:0c:00.1: eth1: (PCI Express:2.5GT/s:Width x4) 00:15:17:bf:06:60
e1000e 0000:0c:00.1: eth1: Intel(R) PRO/1000 Network Connection
e1000e 0000:0c:00.1: eth1: MAC: 1, PHY: 4, PBA No: D64202-004
e1000e 0000:0b:00.0: Disabling ASPM  L1
e1000e 0000:0b:00.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
e1000e 0000:0b:00.0: setting latency timer to 64
e1000e 0000:0b:00.0: irq 52 for MSI/MSI-X
e1000e 0000:0b:00.0: eth2: (PCI Express:2.5GT/s:Width x4) 00:15:17:bf:06:63
e1000e 0000:0b:00.0: eth2: Intel(R) PRO/1000 Network Connection
e1000e 0000:0b:00.0: eth2: MAC: 1, PHY: 4, PBA No: D64202-004
e1000e 0000:0b:00.1: Disabling ASPM  L1
e1000e 0000:0b:00.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
e1000e 0000:0b:00.1: setting latency timer to 64
e1000e 0000:0b:00.1: irq 53 for MSI/MSI-X
e1000e 0000:0b:00.1: eth3: (PCI Express:2.5GT/s:Width x4) 00:15:17:bf:06:62
e1000e 0000:0b:00.1: eth3: Intel(R) PRO/1000 Network Connection
e1000e 0000:0b:00.1: eth3: MAC: 1, PHY: 4, PBA No: D64202-004
e1000e 0000:08:00.0: Disabling ASPM  L1
e1000e 0000:08:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
e1000e 0000:08:00.0: setting latency timer to 64
e1000e 0000:08:00.0: irq 54 for MSI/MSI-X
e1000e 0000:08:00.0: eth4: (PCI Express:2.5GT/s:Width x4) 00:15:17:8b:94:18
e1000e 0000:08:00.0: eth4: Intel(R) PRO/1000 Network Connection
e1000e 0000:08:00.0: eth4: MAC: 1, PHY: 4, PBA No: D50868-003
e1000e 0000:08:00.1: Disabling ASPM  L1
e1000e 0000:08:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
e1000e 0000:08:00.1: setting latency timer to 64
e1000e 0000:08:00.1: irq 55 for MSI/MSI-X
e1000e 0000:08:00.1: eth5: (PCI Express:2.5GT/s:Width x4) 00:15:17:8b:94:19
e1000e 0000:08:00.1: eth5: Intel(R) PRO/1000 Network Connection
e1000e 0000:08:00.1: eth5: MAC: 1, PHY: 4, PBA No: D50868-003
dca service started, version 1.12.1
igb: Unknown parameter `IntMode'
myri10ge: Version 1.5.2-1.459
myri10ge 0000:07:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
myri10ge 0000:07:00.0: setting latency timer to 64
myri10ge 0000:07:00.0: Not enabling ECRC on non-root port 0000:05:02.0
myri10ge 0000:07:00.0: irq 56 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 57 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 58 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 59 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 60 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 61 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 62 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 63 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 56 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 57 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 58 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 59 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 60 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 61 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 62 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 63 for MSI/MSI-X
myri10ge 0000:07:00.0: 8 MSI-X IRQs, tx bndry 4096, fw myri10ge_rss_eth_z8e.dat, WC Enabled
myri10ge 0000:06:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
myri10ge 0000:06:00.0: setting latency timer to 64
myri10ge 0000:06:00.0: Not enabling ECRC on non-root port 0000:05:04.0
myri10ge 0000:06:00.0: irq 56 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 57 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 58 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 59 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 60 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 61 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 62 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 63 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 56 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 57 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 58 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 59 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 60 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 61 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 62 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 63 for MSI/MSI-X
myri10ge 0000:06:00.0: 8 MSI-X IRQs, tx bndry 4096, fw myri10ge_rss_eth_z8e.dat, WC Enabled
NET: Registered protocol family 10
e1000e 0000:0c:00.0: irq 50 for MSI/MSI-X
e1000e 0000:0c:00.0: irq 50 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth0: link is not ready
e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
e1000e 0000:0c:00.1: irq 51 for MSI/MSI-X
e1000e 0000:0c:00.1: irq 51 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth1: link is not ready
e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
e1000e 0000:0b:00.0: irq 52 for MSI/MSI-X
e1000e 0000:0b:00.0: irq 52 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth2: link is not ready
eth0: no IPv6 routers present
e1000e 0000:0b:00.1: irq 53 for MSI/MSI-X
e1000e 0000:0b:00.1: irq 53 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth3: link is not ready
e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
e1000e: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
eth1: no IPv6 routers present
e1000e 0000:08:00.0: irq 54 for MSI/MSI-X
e1000e 0000:08:00.0: irq 54 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth4: link is not ready
e1000e: eth4 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
ADDRCONF(NETDEV_CHANGE): eth4: link becomes ready
e1000e 0000:08:00.1: irq 55 for MSI/MSI-X
e1000e 0000:08:00.1: irq 55 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth5: link is not ready
e1000e: eth5 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
eth2: no IPv6 routers present
eth3: no IPv6 routers present
myri10ge 0000:07:00.0: irq 56 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 57 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 58 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 59 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 60 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 61 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 62 for MSI/MSI-X
myri10ge 0000:07:00.0: irq 63 for MSI/MSI-X
myri10ge 0000:07:00.0: eth6: link down
myri10ge 0000:06:00.0: irq 64 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 65 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 66 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 67 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 68 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 69 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 70 for MSI/MSI-X
myri10ge 0000:06:00.0: irq 71 for MSI/MSI-X
myri10ge 0000:06:00.0: eth7: link down
eth6: no IPv6 routers present
eth7: no IPv6 routers present
e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
e1000e: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
e1000e: eth4 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
e1000e: eth5 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (dm-5): using internal journal
EXT3-fs (dm-5): mounted filesystem with ordered data mode

--=====================_-2087498783==_--
