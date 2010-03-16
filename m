From: =?utf-8?Q?J=F6rn?= Engel <joern@dublin.logfs.org>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI
	Express devices (v2)
Date: Tue, 16 Mar 2010 09:35:01 +0100
Message-ID: <20100316083501.GA3489@Dublin.logfs.org>
References: <20100315150806.GA15354@Dublin.logfs.org> <20100315151041.GA15667@Dublin.logfs.org> <20100315.115748.13754030.davem@davemloft.net> <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: Robert Hancock <hancockrwd@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 March 2010 17:28:45 -0600, Robert Hancock wrote:
> 
> What are the symptoms?

No more network. :)

According to ifconfig the interface is up and running.  If I read
/sys/class/net/eth0 correctly, two packets have been sent and none
received.  LED on network card and switch is off.  mii-tool is
unhappy.

With patch in:
Bikini:~# mii-tool
  No MII transceiver present!.

With patch reverted:
Bikini:~# mii-tool
eth0: negotiated 100baseTx-FD flow-control, link ok

I just noticed lspci is also unhappy.

With patch in:
Bikini:~# lspci -vv > lspci
pcilib: sysfs_read_vpd: read failed: Connection timed out.

With patch reverted:
Bikini:~# lspci -vv > lspci2
Bikini:~# diff -u lspci*
--- lspci       2010-03-16 09:03:02.000000000 +0100
+++ lspci2      2010-03-16 09:09:36.000000000 +0100
@@ -246,7 +246,7 @@
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [cc] Vital Product Data
-               Not readable
+               Unknown small resource type 00, will not decode more.
        Capabilities: [100] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-

As you might expect, delta is part of the ethernet controller.

All "With patch in" output above is typed off the screen.  Beware of
typos.

> Does setting use_dac=0 in the module options
> for r8169 also resolve the problem?

/sys/modules/r8169 does not exist.  How odd.  Anyway, simply changing
the default in r8169.c to 0 fixes the problems for me.  Good call.

> Full dmesg and lspci -vv output might also be useful.

Both with patch in:
dmesg:
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.33 (joern@Dublin) (gcc version 4.3.3 (Debian 4.3.3-3) ) #40 SMP Tue Mar 16 09:01:02 CET 2010
[    0.000000] Command line: vga=9 root=/dev/sda2 loglevel=9 netconsole=4444@192.168.0.39/eth0,6666@192.168.0.10/00:15:58:C5:ED:A8 BOOT_IMAGE=bzImage 
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000bf6b0000 (usable)
[    0.000000]  BIOS-e820: 00000000bf6b0000 - 00000000bf6c0000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000bf6c0000 - 00000000bf6f0000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000bf6f0000 - 00000000bf700000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed00000 - 00000000fed00400 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff380000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000000140000000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI present.
[    0.000000] AMI BIOS detected: BIOS may corrupt low RAM, working around it.
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 update range: 0000000000000000 - 0000000000001000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CBFFF write-protect
[    0.000000]   CC000-DFFFF uncachable
[    0.000000]   E0000-EFFFF write-through
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F00000000 write-back
[    0.000000]   1 base 100000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FC0000000 uncachable
[    0.000000]   3 base 0BF700000 mask FFFF00000 uncachable
[    0.000000]   4 base 0BF800000 mask FFF800000 uncachable
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820 update range: 00000000bf700000 - 0000000100000000 (usable) ==> (reserved)
[    0.000000] last_pfn = 0xbf6b0 max_arch_pfn = 0x400000000
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] found SMP MP-table at [ffff8800000ff780] ff780
[    0.000000] init_memory_mapping: 0000000000000000-00000000bf6b0000
[    0.000000]  0000000000 - 00bf600000 page 2M
[    0.000000]  00bf600000 - 00bf6b0000 page 4k
[    0.000000] kernel direct mapping tables up to bf6b0000 @ 16000-1b000
[    0.000000] init_memory_mapping: 0000000100000000-0000000140000000
[    0.000000]  0100000000 - 0140000000 page 2M
[    0.000000] kernel direct mapping tables up to 140000000 @ 19000-1f000
[    0.000000] ACPI: RSDP 00000000000f9f60 00014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 00000000bf6b0000 00040 (v01 040209 RSDT1650 20090402 MSFT 00000097)
[    0.000000] ACPI: FACP 00000000bf6b0200 00084 (v01 A_M_I  OEMFACP  12000601 MSFT 00000097)
[    0.000000] ACPI: DSDT 00000000bf6b0440 05779 (v01  AS153 AS153151 00000151 INTL 20051117)
[    0.000000] ACPI: FACS 00000000bf6c0000 00040
[    0.000000] ACPI: APIC 00000000bf6b0390 0006C (v01 040209 APIC1650 20090402 MSFT 00000097)
[    0.000000] ACPI: MCFG 00000000bf6b0400 0003C (v01 040209 OEMMCFG  20090402 MSFT 00000097)
[    0.000000] ACPI: OEMB 00000000bf6c0040 00071 (v01 040209 OEMB1650 20090402 MSFT 00000097)
[    0.000000] ACPI: AAFT 00000000bf6b5bc0 00027 (v01 040209 OEMAAFT  20090402 MSFT 00000097)
[    0.000000] ACPI: GSCI 00000000bf6c00c0 02024 (v01 040209 GMCHSCI  20090402 MSFT 00000097)
[    0.000000] ACPI: SSDT 00000000bf6c2a10 00A7C (v01 DpgPmm    CpuPm 00000012 INTL 20051117)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-0000000140000000
[    0.000000] Initmem setup node 0 0000000000000000-0000000140000000
[    0.000000]   NODE_DATA [0000000100000000 - 0000000100004fff]
[    0.000000]  [ffffea0000000000-ffffea00045fffff] PMD -> [ffff880100200000-ffff8801039fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00140000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x000bf6b0
[    0.000000]     0: 0x00100000 -> 0x00140000
[    0.000000] On node 0 totalpages: 1046079
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3927 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 765672 pages, LIFO batch:31
[    0.000000]   Normal zone: 3584 pages used for memmap
[    0.000000]   Normal zone: 258560 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] nr_irqs_gsi: 24
[    0.000000] early_res array is doubled to 64 at [1a000 - 1a7ff]
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e6000
[    0.000000] PM: Registered nosave memory: 00000000000e6000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 00000000bf6b0000 - 00000000bf6c0000
[    0.000000] PM: Registered nosave memory: 00000000bf6c0000 - 00000000bf6f0000
[    0.000000] PM: Registered nosave memory: 00000000bf6f0000 - 00000000bf700000
[    0.000000] PM: Registered nosave memory: 00000000bf700000 - 00000000fed00000
[    0.000000] PM: Registered nosave memory: 00000000fed00000 - 00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 - 00000000ff380000
[    0.000000] PM: Registered nosave memory: 00000000ff380000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at bf700000 (gap: bf700000:3f600000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 476 pages/cpu @ffff880002600000 s1918952 r8192 d22552 u2097152
[    0.000000] pcpu-alloc: s1918952 r8192 d22552 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1028159
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: vga=9 root=/dev/sda2 loglevel=9 netconsole=4444@192.168.0.39/eth0,6666@192.168.0.10/00:15:58:C5:ED:A8 BOOT_IMAGE=bzImage 
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave/xrstor: enabled xstate_bv 0x3, cntxt size 0x240
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Subtract (56 early reservations)
[    0.000000]   #1 [0001000000 - 000241a810]   TEXT DATA BSS
[    0.000000]   #2 [000241b000 - 000241b12b]             BRK
[    0.000000]   #3 [00000ff790 - 0000100000]   BIOS reserved
[    0.000000]   #4 [00000ff780 - 00000ff790]    MP-table mpf
[    0.000000]   #5 [000009e400 - 00000fcc20]   BIOS reserved
[    0.000000]   #6 [00000fcd5c - 00000ff780]   BIOS reserved
[    0.000000]   #7 [00000fcc20 - 00000fcd5c]    MP-table mpc
[    0.000000]   #8 [0000010000 - 0000012000]      TRAMPOLINE
[    0.000000]   #9 [0000012000 - 0000016000]     ACPI WAKEUP
[    0.000000]   #10 [0000016000 - 0000019000]         PGTABLE
[    0.000000]   #11 [0000019000 - 000001a000]         PGTABLE
[    0.000000]   #12 [0100000000 - 0100005000]       NODE_DATA
[    0.000000]   #13 [000241b140 - 000241c140]         BOOTMEM
[    0.000000]   #14 [000241a840 - 000241ab40]         BOOTMEM
[    0.000000]   #15 [0100005000 - 0100006000]         BOOTMEM
[    0.000000]   #16 [0100006000 - 0100007000]         BOOTMEM
[    0.000000]   #17 [0100200000 - 0103a00000]        MEMMAP 0
[    0.000000]   #18 [000241c140 - 000241c640]         BOOTMEM
[    0.000000]   #19 [000241c640 - 000246c640]         BOOTMEM
[    0.000000]   #20 [000246c640 - 0002480640]         BOOTMEM
[    0.000000]   #21 [0002481000 - 0002482000]         BOOTMEM
[    0.000000]   #22 [000241ab40 - 000241ab83]         BOOTMEM
[    0.000000]   #23 [000241abc0 - 000241ae60]         BOOTMEM
[    0.000000]   #24 [000241ae80 - 000241aee8]         BOOTMEM
[    0.000000]   #25 [000241af00 - 000241af68]         BOOTMEM
[    0.000000]   #26 [000241af80 - 000241afe8]         BOOTMEM
[    0.000000]   #27 [0002480640 - 00024806a8]         BOOTMEM
[    0.000000]   #28 [00024806c0 - 0002480728]         BOOTMEM
[    0.000000]   #29 [0002480740 - 00024807a8]         BOOTMEM
[    0.000000]   #30 [00024807c0 - 0002480828]         BOOTMEM
[    0.000000]   #31 [0002480840 - 00024808a8]         BOOTMEM
[    0.000000]   #32 [00024808c0 - 0002480928]         BOOTMEM
[    0.000000]   #33 [0002480940 - 00024809a8]         BOOTMEM
[    0.000000]   #34 [00024809c0 - 0002480a28]         BOOTMEM
[    0.000000]   #35 [0002480a40 - 0002480a60]         BOOTMEM
[    0.000000]   #36 [0002480a80 - 0002480aa0]         BOOTMEM
[    0.000000]   #37 [0002480ac0 - 0002480b3a]         BOOTMEM
[    0.000000]   #38 [0002480b40 - 0002480bba]         BOOTMEM
[    0.000000]   #39 [0002600000 - 00027dc000]         BOOTMEM
[    0.000000]   #40 [0002800000 - 00029dc000]         BOOTMEM
[    0.000000]   #41 [0002a00000 - 0002bdc000]         BOOTMEM
[    0.000000]   #42 [0002c00000 - 0002ddc000]         BOOTMEM
[    0.000000]   #43 [0002480bc0 - 0002480bc8]         BOOTMEM
[    0.000000]   #44 [0002480c00 - 0002480c08]         BOOTMEM
[    0.000000]   #45 [0002480c40 - 0002480c50]         BOOTMEM
[    0.000000]   #46 [0002480c80 - 0002480ca0]         BOOTMEM
[    0.000000]   #47 [0002480cc0 - 0002480e10]         BOOTMEM
[    0.000000]   #48 [0002480e40 - 0002480ec0]         BOOTMEM
[    0.000000]   #49 [0002480ec0 - 0002480f40]         BOOTMEM
[    0.000000]   #50 [0002482000 - 000248a000]         BOOTMEM
[    0.000000]   #51 [000248a000 - 000248a240]         BOOTMEM
[    0.000000]   #52 [0002ddc000 - 0006ddc000]         BOOTMEM
[    0.000000]   #53 [000248a240 - 00024aa240]         BOOTMEM
[    0.000000]   #54 [00024aa240 - 00024ea240]         BOOTMEM
[    0.000000]   #55 [000001a800 - 0000022800]         BOOTMEM
[    0.000000]  23 40 - 80 9e
[    0.000000]  100 100 - 1000 1000
[    0.000000]  24eb 2500 - 2600 2600
[    0.000000]  27dc - 2800
[    0.000000]  29dc - 2a00
[    0.000000]  2bdc - 2c00
[    0.000000]  6ddc 6e00 - bf680 bf6b0
[    0.000000]  100007 100040 - 100200 100200
[    0.000000]  103a00 103a00 - 140000 140000
[    0.000000] Memory: 4032292k/5242880k available (3411k kernel code, 1058564k absent, 152024k reserved, 3689k data, 2556k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:1280
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: 11 of 11 active objects replaced
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2880.133 MHz processor.
[    0.004030] Calibrating delay loop (skipped), value calculated using timer frequency.. 5760.26 BogoMIPS (lpj=11520532)
[    0.004700] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.008489] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.009422] Mount-cache hash table entries: 256
[    0.010361] Initializing cgroup subsys ns
[    0.010368] Initializing cgroup subsys cpuacct
[    0.010382] Initializing cgroup subsys devices
[    0.010479] CPU: Physical Processor ID: 0
[    0.010483] CPU: Processor Core ID: 0
[    0.010488] mce: CPU supports 6 MCE banks
[    0.010496] CPU0: Thermal monitoring enabled (TM2)
[    0.010506] using mwait in idle threads.
[    0.010510] Performance Events: Core2 events, Intel PMU driver.
[    0.010524] ... version:                2
[    0.010527] ... bit width:              40
[    0.010530] ... generic registers:      2
[    0.010534] ... value mask:             000000ffffffffff
[    0.010538] ... max period:             000000007fffffff
[    0.010541] ... fixed-purpose events:   3
[    0.010544] ... event mask:             0000000700000003
[    0.011517] ACPI: Core revision 20100121
[    0.028016] ftrace: converting mcount calls to 0f 1f 44 00 00
[    0.028024] ftrace: allocating 14208 entries in 56 pages
[    0.032154] Setting APIC routing to flat
[    0.032565] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.075613] CPU0: Intel Pentium(R) Dual-Core  CPU      E5200  @ 2.50GHz stepping 0a
[    0.076000] lockdep: fixing up alternatives.
[    0.076000] Booting Node   0, Processors  #1
[    0.164047] Brought up 2 CPUs
[    0.164054] Total of 2 processors activated (11519.94 BogoMIPS).
[    0.164753] khelper used greatest stack depth: 5888 bytes left
[    0.164753] NET: Registered protocol family 16
[    0.164753] ACPI: bus type pci registered
[    0.164753] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.164753] PCI: not using MMCONFIG
[    0.164753] PCI: Using configuration type 1 for base access
[    0.164753] khelper used greatest stack depth: 5808 bytes left
[    0.172140] bio: create slab <bio-0> at 0
[    0.182217] ACPI: EC: Look up EC in DSDT
[    0.190712] ACPI: Executed 1 blocks of module-level executable AML code
[    0.205132] ACPI: Interpreter enabled
[    0.205137] ACPI: (supports S0 S1 S3 S4 S5)
[    0.205224] ACPI: Using IOAPIC for interrupt routing
[    0.205312] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.212093] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in ACPI motherboard resources
[    0.328031] ACPI: No dock devices found.
[    0.328040] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.328755] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.328991] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.328991] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.328991] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.328991] pci_root PNP0A08:00: host bridge window [mem 0x000d0000-0x000dffff]
[    0.328991] pci_root PNP0A08:00: host bridge window [mem 0xbf700000-0xdfffffff]
[    0.328991] pci_root PNP0A08:00: host bridge window [mem 0xf0000000-0xffffffff]
[    0.328991] pci 0000:00:02.0: reg 10: [mem 0xfea80000-0xfeafffff]
[    0.328991] pci 0000:00:02.0: reg 14: [io  0xdc00-0xdc07]
[    0.328991] pci 0000:00:02.0: reg 18: [mem 0xd0000000-0xdfffffff pref]
[    0.328991] pci 0000:00:02.0: reg 1c: [mem 0xfe900000-0xfe9fffff]
[    0.328991] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.328991] pci 0000:00:1c.0: PME# disabled
[    0.329041] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.329049] pci 0000:00:1c.1: PME# disabled
[    0.329129] pci 0000:00:1d.0: reg 20: [io  0xd400-0xd41f]
[    0.329208] pci 0000:00:1d.1: reg 20: [io  0xd480-0xd49f]
[    0.329286] pci 0000:00:1d.2: reg 20: [io  0xd800-0xd81f]
[    0.329366] pci 0000:00:1d.3: reg 20: [io  0xd880-0xd89f]
[    0.329442] pci 0000:00:1d.7: reg 10: [mem 0xfea77c00-0xfea77fff]
[    0.329522] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.329530] pci 0000:00:1d.7: PME# disabled
[    0.329726] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    0.329735] pci 0000:00:1f.0: quirk: [io  0x0800-0x087f] claimed by ICH6 ACPI/GPIO/TCO
[    0.329743] pci 0000:00:1f.0: quirk: [io  0x0480-0x04bf] claimed by ICH6 GPIO
[    0.329750] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0280 (mask 00ff)
[    0.329758] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0300 (mask 003f)
[    0.329824] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.329835] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.329846] pci 0000:00:1f.1: reg 18: [io  0x08f0-0x08f7]
[    0.329856] pci 0000:00:1f.1: reg 1c: [io  0x08f8-0x08fb]
[    0.329867] pci 0000:00:1f.1: reg 20: [io  0xffa0-0xffaf]
[    0.329928] pci 0000:00:1f.2: reg 10: [io  0xd080-0xd087]
[    0.329938] pci 0000:00:1f.2: reg 14: [io  0xd000-0xd003]
[    0.329948] pci 0000:00:1f.2: reg 18: [io  0xcc00-0xcc07]
[    0.329958] pci 0000:00:1f.2: reg 1c: [io  0xc880-0xc883]
[    0.329968] pci 0000:00:1f.2: reg 20: [io  0xc800-0xc80f]
[    0.330010] pci 0000:00:1f.2: PME# supported from D3hot
[    0.330016] pci 0000:00:1f.2: PME# disabled
[    0.330085] pci 0000:00:1f.3: reg 20: [io  0x0400-0x041f]
[    0.330192] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.330199] pci 0000:00:1c.0:   bridge window [io  f000 - 0000] reg reading
[    0.330207] pci 0000:00:1c.0:   bridge window [mem 0xfff00000 - 0x000fffff] reg reading
[    0.330219] pci 0000:00:1c.0:   bridge window [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.330329] pci 0000:01:00.0: reg 10: [io  0xe800-0xe8ff]
[    0.330359] pci 0000:01:00.0: reg 18: [mem 0xfdeff000-0xfdefffff 64bit pref]
[    0.330381] pci 0000:01:00.0: reg 20: [mem 0xfdee0000-0xfdeeffff 64bit pref]
[    0.330395] pci 0000:01:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.330454] pci 0000:01:00.0: supports D1 D2
[    0.330458] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.330467] pci 0000:01:00.0: PME# disabled
[    0.330500] pci 0000:00:1c.1: PCI bridge to [bus 01-01]
[    0.330507] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.330515] pci 0000:00:1c.1:   bridge window [mem 0xfeb00000-0xfebfffff]
[    0.330526] pci 0000:00:1c.1:   bridge window [mem 0xfde00000-0xfdefffff 64bit pref]
[    0.330638] pci 0000:00:1e.0: PCI bridge to [bus 03-03] (subtractive decode)
[    0.330646] pci 0000:00:1e.0:   bridge window [io  f000 - 0000] reg reading
[    0.330654] pci 0000:00:1e.0:   bridge window [mem 0xfff00000 - 0x000fffff] reg reading
[    0.330666] pci 0000:00:1e.0:   bridge window [mem 0xfff00000 - 000fffff pref] reg reading
[    0.330672] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    0.330678] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.330683] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.330690] pci 0000:00:1e.0:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
[    0.330696] pci 0000:00:1e.0:   bridge window [mem 0xbf700000-0xdfffffff] (subtractive decode)
[    0.330702] pci 0000:00:1e.0:   bridge window [mem 0xf0000000-0xffffffff] (subtractive decode)
[    0.330733] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.332114] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[    0.332536] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
[    0.332681] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P5._PRT]
[    0.357702] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.357702] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.357702] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.357702] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    0.357702] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.357702] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.357702] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    0.357702] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 6 7 10 11 12 14 15)
[    0.360218] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.360218] vgaarb: loaded
[    0.360347] SCSI subsystem initialized
[    0.360347] libata version 3.00 loaded.
[    0.360347] usbcore: registered new interface driver usbfs
[    0.360347] usbcore: registered new interface driver hub
[    0.360347] usbcore: registered new device driver usb
[    0.360347] PCI: Using ACPI for IRQ routing
[    0.360347] PCI: pci_cache_line_size set to 64 bytes
[    0.360347] reserve RAM buffer: 000000000009f800 - 000000000009ffff 
[    0.360347] reserve RAM buffer: 00000000bf6b0000 - 00000000bfffffff 
[    0.360347] hpet clockevent registered
[    0.360347] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.360347] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.360347] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.372049] Switching to clocksource tsc
[    0.378630] pnp: PnP ACPI init
[    0.378664] ACPI: bus type pnp registered
[    0.386324] pnp: PnP ACPI: found 13 devices
[    0.386329] ACPI: ACPI bus type pnp unregistered
[    0.386350] system 00:01: [mem 0xfed14000-0xfed19fff] has been reserved
[    0.386369] system 00:06: [io  0x04d0-0x04d1] has been reserved
[    0.386375] system 00:06: [io  0x0800-0x087f] has been reserved
[    0.386380] system 00:06: [io  0x0480-0x04bf] has been reserved
[    0.386385] system 00:06: [io  0x0900-0x090f] has been reserved
[    0.386391] system 00:06: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.386396] system 00:06: [mem 0xfed20000-0xfed8ffff] has been reserved
[    0.386412] system 00:08: [mem 0xffc00000-0xfff7ffff] has been reserved
[    0.386432] system 00:09: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.386438] system 00:09: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.386453] system 00:0a: [io  0x0290-0x029f] has been reserved
[    0.386467] system 00:0b: [mem 0xe0000000-0xefffffff] has been reserved
[    0.386483] system 00:0c: [mem 0x00000000-0x0009ffff] could not be reserved
[    0.386489] system 00:0c: [mem 0x000c0000-0x000cffff] has been reserved
[    0.386496] system 00:0c: [mem 0x000e0000-0x000fffff] could not be reserved
[    0.386503] system 00:0c: [mem 0x00100000-0xbf6fffff] could not be reserved
[    0.392112] PCI: max bus depth: 1 pci_try_num: 2
[    0.392155] pci 0000:00:1c.0: BAR 8: assigned [mem 0xbf700000-0xbfafffff]
[    0.392163] pci 0000:00:1c.0: BAR 7: assigned [io  0x1000-0x1fff]
[    0.392168] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.392174] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    0.392183] pci 0000:00:1c.0:   bridge window [mem 0xbf700000-0xbfafffff]
[    0.392191] pci 0000:00:1c.0:   bridge window [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.392204] pci 0000:01:00.0: BAR 6: assigned [mem 0xfde00000-0xfde1ffff pref]
[    0.392210] pci 0000:00:1c.1: PCI bridge to [bus 01-01]
[    0.392216] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.392225] pci 0000:00:1c.1:   bridge window [mem 0xfeb00000-0xfebfffff]
[    0.392232] pci 0000:00:1c.1:   bridge window [mem 0xfde00000-0xfdefffff 64bit pref]
[    0.392244] pci 0000:00:1e.0: PCI bridge to [bus 03-03]
[    0.392248] pci 0000:00:1e.0:   bridge window [io  disabled]
[    0.392257] pci 0000:00:1e.0:   bridge window [mem disabled]
[    0.392264] pci 0000:00:1e.0:   bridge window [mem pref disabled]
[    0.392284] pci 0000:00:1c.0: enabling device (0106 -> 0107)
[    0.392299] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.392307] pci 0000:00:1c.0: setting latency timer to 64
[    0.392325] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.392333] pci 0000:00:1c.1: setting latency timer to 64
[    0.392345] pci 0000:00:1e.0: setting latency timer to 64
[    0.392351] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.392355] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.392359] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.392364] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
[    0.392368] pci_bus 0000:00: resource 8 [mem 0xbf700000-0xdfffffff]
[    0.392372] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xffffffff]
[    0.392377] pci_bus 0000:02: resource 0 [io  0x1000-0x1fff]
[    0.392381] pci_bus 0000:02: resource 1 [mem 0xbf700000-0xbfafffff]
[    0.392385] pci_bus 0000:02: resource 2 [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.392391] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
[    0.392395] pci_bus 0000:01: resource 1 [mem 0xfeb00000-0xfebfffff]
[    0.392399] pci_bus 0000:01: resource 2 [mem 0xfde00000-0xfdefffff 64bit pref]
[    0.392405] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
[    0.392409] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
[    0.392413] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
[    0.392417] pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000dffff]
[    0.392422] pci_bus 0000:03: resource 8 [mem 0xbf700000-0xdfffffff]
[    0.392426] pci_bus 0000:03: resource 9 [mem 0xf0000000-0xffffffff]
[    0.392542] NET: Registered protocol family 2
[    0.392892] IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.394859] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    0.398800] TCP bind hash table entries: 65536 (order: 10, 4718592 bytes)
[    0.404716] TCP: Hash tables configured (established 524288 bind 65536)
[    0.404775] TCP reno registered
[    0.404833] UDP hash table entries: 2048 (order: 6, 327680 bytes)
[    0.405251] UDP-Lite hash table entries: 2048 (order: 6, 327680 bytes)
[    0.405946] NET: Registered protocol family 1
[    0.405987] pci 0000:00:02.0: Boot video device
[    0.406165] PCI: CLS 32 bytes, default 64
[    0.417956] DMA-API: preallocated 32768 debug entries
[    0.417965] DMA-API: debugging enabled by kernel config
[    0.417971] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.417977] Placing 64MB software IO TLB between ffff880002ddc000 - ffff880006ddc000
[    0.417983] software IO TLB at phys 0x2ddc000 - 0x6ddc000
[    0.420717] audit: initializing netlink socket (disabled)
[    0.420763] type=2000 audit(1268726481.419:1): initialized
[    0.421241] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.421938] msgmni has been set to 7875
[    0.422898] cryptomgr_test used greatest stack depth: 5352 bytes left
[    0.422962] alg: No test for stdrng (krng)
[    0.423105] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    0.423124] io scheduler noop registered
[    0.423128] io scheduler deadline registered
[    0.423160] io scheduler cfq registered (default)
[    0.423484] pcieport 0000:00:1c.0: setting latency timer to 64
[    0.423551] pcieport 0000:00:1c.0: irq 24 for MSI/MSI-X
[    0.424181] pcieport 0000:00:1c.1: setting latency timer to 64
[    0.424244] pcieport 0000:00:1c.1: irq 25 for MSI/MSI-X
[    0.426515] vesafb: framebuffer at 0xd0000000, mapped to 0xffffc90011580000, using 3750k, total 8128k
[    0.426522] vesafb: mode is 1600x1200x8, linelength=1600, pages=3
[    0.426526] vesafb: scrolling: redraw
[    0.426529] vesafb: Pseudocolor: size=8:8:8:8, shift=0:0:0:0
[    0.444667] Console: switching to colour frame buffer device 200x75
[    0.462236] fb0: VESA VGA frame buffer device
[    0.463660] ACPI: SSDT 00000000bf6c20f0 00277 (v01 DpgPmm  P001Ist 00000011 INTL 20051117)
[    0.466926] ACPI: SSDT 00000000bf6c2580 00277 (v01 DpgPmm  P002Ist 00000012 INTL 20051117)
[    0.484133] intel_rng: FWH not detected
[    0.484265] Linux agpgart interface v0.103
[    0.484463] agpgart-intel 0000:00:00.0: Intel G33 Chipset
[    0.485627] agpgart-intel 0000:00:00.0: detected 7164K stolen memory
[    0.495395] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    0.495610] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.501851] brd: module loaded
[    0.504130] loop: module loaded
[    0.504466] ata_piix 0000:00:1f.1: version 2.13
[    0.504554] ata_piix 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    0.504747] ata_piix 0000:00:1f.1: setting latency timer to 64
[    0.504984] scsi0 : ata_piix
[    0.505336] scsi1 : ata_piix
[    0.510141] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    0.510238] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    0.510394] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    0.510496] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    0.510645] ata_piix 0000:00:1f.2: setting latency timer to 64
[    0.510829] scsi2 : ata_piix
[    0.511214] scsi3 : ata_piix
[    0.516880] ata3: SATA max UDMA/133 cmd 0xd080 ctl 0xd000 bmdma 0xc800 irq 19
[    0.516979] ata4: SATA max UDMA/133 cmd 0xcc00 ctl 0xc880 bmdma 0xc808 irq 19
[    0.517340] tun: Universal TUN/TAP device driver, 1.6
[    0.517411] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    0.517634] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    0.517731] r8169 0000:01:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.517853] r8169 0000:01:00.0: (unregistered net_device): using 64-bit DMA
[    0.517975] r8169 0000:01:00.0: setting latency timer to 64
[    0.518121] r8169 0000:01:00.0: irq 26 for MSI/MSI-X
[    0.518411] khelper used greatest stack depth: 5136 bytes left
[    0.518989] r8169 0000:01:00.0: eth0: RTL8102e at 0xffffc9000063e000, 00:19:66:ca:2c:7f, XID 04a00000 IRQ 26
[    0.521192] netconsole: local port 4444
[    0.521247] netconsole: local IP 192.168.0.39
[    0.521307] netconsole: interface eth0
[    0.521359] netconsole: remote port 6666
[    0.521413] netconsole: remote IP 192.168.0.10
[    0.521475] netconsole: remote ethernet address 00:15:58:c5:ed:a8
[    0.521564] netconsole: device eth0 not up yet, forcing it
[    0.523389] r8169 0000:01:00.0: eth0: link down
[    0.523453] r8169 0000:01:00.0: eth0: link down
[    0.683957] ata4.00: ATA-7: INTEL SSDSA2M040G2GC, 2CV102HB, max UDMA/133
[    0.684071] ata4.00: 78165360 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    0.691795] ata4.00: configured for UDMA/133
[    0.699881] ata3.00: ATA-8: Hitachi HDT721025SLA380, STBOA31B, max UDMA/133
[    0.699997] ata3.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    0.715852] ata3.00: configured for UDMA/133
[    0.716480] scsi 2:0:0:0: Direct-Access     ATA      Hitachi HDT72102 STBO PQ: 0 ANSI: 5
[    0.720035] sd 2:0:0:0: [sda] 488397168 512-byte logical blocks: (250 GB/232 GiB)
[    0.720618] scsi 3:0:0:0: Direct-Access     ATA      INTEL SSDSA2M040 2CV1 PQ: 0 ANSI: 5
[    0.721050] sd 3:0:0:0: [sdb] 78165360 512-byte logical blocks: (40.0 GB/37.2 GiB)
[    0.721222] sd 3:0:0:0: [sdb] Write Protect is off
[    0.721224] sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    0.721293] sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    0.721833]  sdb: unknown partition table
[    0.742050] sd 2:0:0:0: [sda] Write Protect is off
[    0.742549] sd 3:0:0:0: [sdb] Attached SCSI disk
[    0.748771] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    0.752242] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    0.756154]  sda: sda1 sda2 sda3
[    0.780333] sd 2:0:0:0: [sda] Attached SCSI disk
[    1.736062] async/3 used greatest stack depth: 4776 bytes left
[    1.739753] async/2 used greatest stack depth: 4720 bytes left
[    4.528033] netconsole: timeout waiting for carrier
[    6.156819] console [netcon0] enabled
[    6.156820] netconsole: network logging started
[    6.157229] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    6.157286] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    6.157320] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    6.157324] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    6.157793] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    6.157860] ehci_hcd 0000:00:1d.7: using broken periodic workaround
[    6.157874] ehci_hcd 0000:00:1d.7: debug port 1
[    6.161767] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    6.161803] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfea77c00
[    6.176032] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    6.176180] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    6.176182] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.176183] usb usb1: Product: EHCI Host Controller
[    6.176184] usb usb1: Manufacturer: Linux 2.6.33 ehci_hcd
[    6.176185] usb usb1: SerialNumber: 0000:00:1d.7
[    6.176831] hub 1-0:1.0: USB hub found
[    6.176860] hub 1-0:1.0: 8 ports detected
[    6.177512] uhci_hcd: USB Universal Host Controller Interface driver
[    6.202365] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    6.202374] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    6.202378] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    6.202540] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    6.202575] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000d400
[    6.202667] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    6.202669] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.202671] usb usb2: Product: UHCI Host Controller
[    6.202672] usb usb2: Manufacturer: Linux 2.6.33 uhci_hcd
[    6.202673] usb usb2: SerialNumber: 0000:00:1d.0
[    6.202988] hub 2-0:1.0: USB hub found
[    6.203030] hub 2-0:1.0: 2 ports detected
[    6.203335] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    6.203344] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    6.203347] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    6.203508] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    6.203544] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000d480
[    6.203639] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    6.203641] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.203642] usb usb3: Product: UHCI Host Controller
[    6.203643] usb usb3: Manufacturer: Linux 2.6.33 uhci_hcd
[    6.203645] usb usb3: SerialNumber: 0000:00:1d.1
[    6.203962] hub 3-0:1.0: USB hub found
[    6.203974] hub 3-0:1.0: 2 ports detected
[    6.204275] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    6.204284] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    6.204287] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    6.204447] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    6.204499] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000d800
[    6.204595] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    6.204597] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.204599] usb usb4: Product: UHCI Host Controller
[    6.204600] usb usb4: Manufacturer: Linux 2.6.33 uhci_hcd
[    6.204601] usb usb4: SerialNumber: 0000:00:1d.2
[    6.204978] hub 4-0:1.0: USB hub found
[    6.204989] hub 4-0:1.0: 2 ports detected
[    6.205269] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) -> IRQ 16
[    6.205278] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    6.205281] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    6.205448] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    6.205498] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000d880
[    6.205597] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    6.205599] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.205600] usb usb5: Product: UHCI Host Controller
[    6.205601] usb usb5: Manufacturer: Linux 2.6.33 uhci_hcd
[    6.205602] usb usb5: SerialNumber: 0000:00:1d.3
[    6.205912] hub 5-0:1.0: USB hub found
[    6.205924] hub 5-0:1.0: 2 ports detected
[    6.206303] Initializing USB Mass Storage driver...
[    6.206428] usbcore: registered new interface driver usb-storage
[    6.206429] USB Mass Storage support registered.
[    6.206889] PNP: No PS/2 controller found. Probing ports directly.
[    6.251877] serio: i8042 KBD port at 0x60,0x64 irq 1
[    6.251903] serio: i8042 AUX port at 0x60,0x64 irq 12
[    6.252259] mice: PS/2 mouse device common for all mice
[    6.252393] rtc_cmos 00:03: RTC can wake from S4
[    6.252606] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    6.252637] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[    6.446711] cpuidle: using governor ladder
[    6.446714] cpuidle: using governor menu
[    6.449762] usbcore: registered new interface driver hiddev
[    6.449873] usbcore: registered new interface driver usbhid
[    6.449874] usbhid: USB HID core driver
[    6.450050] oprofile: using NMI interrupt.
[    6.469847] TCP cubic registered
[    6.469851] NET: Registered protocol family 17
[    6.499369] registered taskstats version 1
[    6.503448] rtc_cmos 00:03: setting system clock to 2010-03-16 08:01:28 UTC (1268726488)
[    6.539784] EXT3-fs (sda2): recovery required on readonly filesystem
[    6.543559] EXT3-fs (sda2): write access will be enabled during recovery
[    6.587902] kjournald starting.  Commit interval 5 seconds
[    6.591792] EXT3-fs (sda2): recovery complete
[    6.596352] EXT3-fs (sda2): mounted filesystem with writeback data mode
[    6.600318] VFS: Mounted root (ext3 filesystem) readonly on device 8:2.
[    6.604202] Freeing unused kernel memory: 2556k freed
[    6.609265] Write protecting the kernel read-only data: 6144k
[    6.613463] Freeing unused kernel memory: 664k freed
[    6.617826] Freeing unused kernel memory: 332k freed
[    6.860063] usb 3-2: new low speed USB device using uhci_hcd and address 2
[    7.115503] usb 3-2: New USB device found, idVendor=1241, idProduct=1503
[    7.119525] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.123498] usb 3-2: Product: USB Keyboard
[    7.127376] usb 3-2: Manufacturer:  
[    7.181976] input:   USB Keyboard as /class/input/input0
[    7.186467] generic-usb 0003:1241:1503.0001: input,hidraw0: USB HID v1.10 Keyboard [  USB Keyboard] on usb-0000:00:1d.1-2/input0
[    7.274776] input:   USB Keyboard as /class/input/input1
[    7.279002] generic-usb 0003:1241:1503.0002: input,hidraw1: USB HID v1.10 Device [  USB Keyboard] on usb-0000:00:1d.1-2/input1
[    7.338603] stty used greatest stack depth: 3744 bytes left
[    7.724093] touch used greatest stack depth: 3664 bytes left
[    8.919804] egrep used greatest stack depth: 3344 bytes left
[   10.713241] EXT3-fs (sda2): using internal journal
[   11.708808] kjournald starting.  Commit interval 5 seconds
[   11.713511] EXT3-fs (sda1): using internal journal
[   11.718095] EXT3-fs (sda1): mounted filesystem with writeback data mode
[   12.975258] rc used greatest stack depth: 3136 bytes left

lspci -vv:
00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P31 Express DRAM Controller (rev 10)
	Subsystem: ASRock Incorporation Device 29c0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>
	Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation 82G33/G31 Express Integrated Graphics Controller (rev 10) (prog-if 00 [VGA controller])
	Subsystem: ASRock Incorporation Device 29c2
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at fea80000 (32-bit, non-prefetchable) [size=512K]
	Region 1: I/O ports at dc00 [size=8]
	Region 2: Memory at d0000000 (32-bit, prefetchable) [size=256M]
	Region 3: Memory at fe900000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-

00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1 (rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: bf700000-bfafffff
	Prefetchable memory behind bridge: 00000000fdf00000-00000000fdffffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot # 11, PowerLimit 25.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4149
	Capabilities: [90] Subsystem: ASRock Incorporation Device 27d0
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [180] Root Complex Link <?>
	Kernel driver in use: pcieport

00:1c.1 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 2 (rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: feb00000-febfffff
	Prefetchable memory behind bridge: 00000000fde00000-00000000fdefffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  0, PowerLimit 0.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4151
	Capabilities: [90] Subsystem: ASRock Incorporation Device 27d2
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [180] Root Complex Link <?>
	Kernel driver in use: pcieport

00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #1 (rev 01) (prog-if 00 [UHCI])
	Subsystem: ASRock Incorporation Device 27c8
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at d400 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.1 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #2 (rev 01) (prog-if 00 [UHCI])
	Subsystem: ASRock Incorporation Device 27c9
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at d480 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.2 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #3 (rev 01) (prog-if 00 [UHCI])
	Subsystem: ASRock Incorporation Device 27ca
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at d800 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.3 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #4 (rev 01) (prog-if 00 [UHCI])
	Subsystem: ASRock Incorporation Device 27cb
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 16
	Region 4: I/O ports at d880 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.7 USB Controller: Intel Corporation 82801G (ICH7 Family) USB2 EHCI Controller (rev 01) (prog-if 20 [EHCI])
	Subsystem: ASRock Incorporation Device 27cc
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at fea77c00 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1) (prog-if 01 [Subtractive decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=32
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: ASRock Incorporation Device 244e

00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface Bridge (rev 01)
	Subsystem: ASRock Incorporation Device 27b8
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>

00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE Controller (rev 01) (prog-if 8a [Master SecP PriP])
	Subsystem: ASRock Incorporation Device 27df
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
	Latency: 0
	Interrupt: pin A routed to IRQ 18
	Region 0: I/O ports at 01f0 [size=8]
	Region 1: I/O ports at 03f4 [size=1]
	Region 2: I/O ports at 0170 [size=8]
	Region 3: I/O ports at 0374 [size=1]
	Region 4: I/O ports at ffa0 [size=16]
	Kernel driver in use: ata_piix

00:1f.2 IDE interface: Intel Corporation 82801GB/GR/GH (ICH7 Family) SATA IDE Controller (rev 01) (prog-if 8f [Master SecP SecO PriP PriO])
	Subsystem: ASRock Incorporation Device 27c0
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 0: I/O ports at d080 [size=8]
	Region 1: I/O ports at d000 [size=4]
	Region 2: I/O ports at cc00 [size=8]
	Region 3: I/O ports at c880 [size=4]
	Region 4: I/O ports at c800 [size=16]
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: ata_piix

00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 01)
	Subsystem: ASRock Incorporation Device 27da
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 5
	Region 4: I/O ports at 0400 [size=32]

01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E/RTL8102E PCI Express Fast Ethernet controller (rev 02)
	Subsystem: ASRock Incorporation Device 8136
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 26
	Region 0: I/O ports at e800 [size=256]
	Region 2: Memory at fdeff000 (64-bit, prefetchable) [size=4K]
	Region 4: Memory at fdee0000 (64-bit, prefetchable) [size=64K]
	[virtual] Expansion ROM at fde00000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4169
	Capabilities: [70] Express (v2) Endpoint, MSI 01
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [ac] MSI-X: Enable- Count=2 Masked-
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00000800
	Capabilities: [cc] Vital Product Data
		Not readable
	Capabilities: [100] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140] Virtual Channel <?>
	Capabilities: [160] Device Serial Number 08-00-00-00-ff-ff-00-00
	Kernel driver in use: r8169
