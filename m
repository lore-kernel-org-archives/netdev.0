From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: 2.6.23-rc4-mm1: unpingable box and NULL dereference at tcp_rto_min()
Date: Sun, 2 Sep 2007 06:36:19 +0400
Message-ID: <20070902023618.GA2537@martell.zuzino.mipt.ru>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:18511 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbXIBCgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 22:36:33 -0400
Received: by nf-out-0910.google.com with SMTP id f5so966407nfh
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2007 19:36:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/
> - dynticks-for-x86_64 has returned

Good news is that, contary to popular belief, -mm is not horrible piece
of crap and NO_HZ on x86_64 worked here straight away.


The bad news is something knocked off box from the net, then panicked it:

Box: Core 2 Duo (E6400), 2G RAM
Setup: x86_64 kernel, no preemption, SLUB with debugging on and almost
       all other debugging on
       atl1 NIC driver, connected to master box, netconsoling to it as well
Load: sequential kernel build with -j9 on many configs I do here (easy)
      LTP in infinite loop
      gdb testsuite in infinite loop with "ulimit -c unlimited"
      ssh session feeding all the above to master box

Box was left alone for several hours, strange things happened while I
was away:
	* unpingable box, frozen ssh sessions
	* still can login via VT console
	* SysRq+t works (see dmesg)
	* SysRq+t left "atl1 0000:03:00.0: tx busy" after output

At this state box was left alone for a couple of more hours, and
eventually panicked with (see full dmesg at the end)

Unable to handle kernel NULL pointer dereference at 0000000000000039 RIP: 
 [<ffffffff803b6f7c>] tcp_rto_min+0xc/0x20

which corresponds to:

	<tcp_rto_min>:
		mov	0x100(%rdi),%rdx
		mov	$0x14,%eax
		testb	$0x20,0x39(%rdx)	<===


See below for full dmesg with SysRq+t output, oops and .config and
tcp_rto_min disassembly:

P.S.: uh-oh, it's "[TCP] Allow minnimum RTO ..." aka 05bb1fad1cde

Linux version 2.6.23-rc4-mm1 (ad@core2) (gcc version 4.1.1 (Gentoo 4.1.1-r3)) #1 SMP Sat Sep 1 10:53:14 MSD 2007
Command line: root=/dev/sda2 netconsole=@10.10.0.42/eth0,9353@10.10.0.1/00:80:48:45:EC:73 ignore_loglevel
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007ff90000 (usable)
 BIOS-e820: 000000007ff90000 - 000000007ff9e000 (ACPI data)
 BIOS-e820: 000000007ff9e000 - 000000007ffe0000 (ACPI NVS)
 BIOS-e820: 000000007ffe0000 - 0000000080000000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffb00000 - 0000000100000000 (reserved)
Entering add_active_range(0, 0, 159) 0 entries of 256 used
Entering add_active_range(0, 256, 524176) 1 entries of 256 used
end_pfn_map = 1048576
DMI 2.4 present.
ACPI: RSDP 000FA980, 0024 (r2 ACPIAM)
ACPI: XSDT 7FF90100, 0054 (r1 KOZIRO FRONTIER  2000707 MSFT       97)
ACPI: FACP 7FF90290, 00F4 (r3 MSTEST OEMFACP   2000707 MSFT       97)
ACPI: DSDT 7FF905C0, 8FA9 (r1  A0637 A0637000        0 INTL 20060113)
ACPI: FACS 7FF9E000, 0040
ACPI: APIC 7FF90390, 006C (r1 MSTEST OEMAPIC   2000707 MSFT       97)
ACPI: MCFG 7FF90400, 003C (r1 MSTEST OEMMCFG   2000707 MSFT       97)
ACPI: SLIC 7FF90440, 0176 (r1 KOZIRO FRONTIER  2000707 MSFT       97)
ACPI: OEMB 7FF9E040, 007B (r1 MSTEST AMI_OEM   2000707 MSFT       97)
ACPI: HPET 7FF99570, 0038 (r1 MSTEST OEMHPET   2000707 MSFT       97)
ACPI: Local APIC address 0xfee00000
Entering add_active_range(0, 0, 159) 0 entries of 256 used
Entering add_active_range(0, 256, 524176) 1 entries of 256 used
sizeof(struct page) = 56
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0:        0 ->      159
    0:      256 ->   524176
On node 0 totalpages: 524079
Node 0 memmap at 0xffff810001000000 size 29360128 first pfn 0xffff810001000000
  DMA zone: 56 pages used for memmap
  DMA zone: 1945 pages reserved
  DMA zone: 1998 pages, LIFO batch:0
  DMA32 zone: 7110 pages used for memmap
  DMA32 zone: 512970 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 (Bootup-CPU)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x8086a202 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at 88000000 (gap: 80000000:7ee00000)
PERCPU: Allocating 416480 bytes of per cpu data
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 514968
Kernel command line: root=/dev/sda2 netconsole=@10.10.0.42/eth0,9353@10.10.0.1/00:80:48:45:EC:73 ignore_loglevel
debug: ignoring loglevel setting.
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
Extended CMOS year: 2000
hpet clockevent registered
TSC calibrated against HPET
time.c: Detected 2135.038 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          30
... MAX_LOCKDEP_KEYS:        2048
... CLASSHASH_SIZE:           1024
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 1712 kB
 per task-struct memory footprint: 2160 bytes
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Memory: 2055448k/2096704k available (1934k kernel code, 40676k reserved, 1153k data, 572k init)
SLUB: Genslabs=11, HWalign=64, Order=0-3, MinObjects=16, CPUs=2, Nodes=1
Calibrating delay using timer specific routine.. 4273.51 BogoMIPS (lpj=21367553)
kswapd reclaim order set to 3
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 2048K
using mwait in idle threads.
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring enabled (TM2)
Freeing SMP alternatives: 16k freed
ACPI: Core revision 20070126
Using local APIC timer interrupts.
APIC timer calibration result 16679980
Detected 16.679 MHz APIC timer.
lockdep: not fixing up alternatives.
Booting processor 1/2 APIC 0x1
Initializing CPU#1
Calibrating delay using timer specific routine.. 4270.10 BogoMIPS (lpj=21350532)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU1: Thermal monitoring enabled (TM2)
Intel(R) Core(TM)2 CPU          6400  @ 2.13GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using configuration type 1
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
PCI quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
PCI quirk: region 0480-04bf claimed by ICH6 GPIO
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P7._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P8._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 11 12 *14 15)
ACPI Warning (tbutils-0217): Incorrect checksum in table [OEMB] -  F8, should be EB [20070126]
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 17 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 2.21 loaded.
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
Time: tsc clocksource has been installed.
Switched to high resolution mode on CPU 0
Switched to high resolution mode on CPU 1
pnp: 00:01: iomem range 0xfed14000-0xfed19fff has been reserved
pnp: 00:08: ioport range 0x290-0x297 has been reserved
pnp: 00:09: iomem range 0xffafe000-0xffb0cbff could not be reserved
pnp: 00:09: iomem range 0xffb00000-0xffbfffff could not be reserved
pnp: 00:09: iomem range 0xfed1c000-0xfed1ffff has been reserved
pnp: 00:09: iomem range 0xfed20000-0xfed8ffff has been reserved
pnp: 00:0c: iomem range 0xfec00000-0xfec00fff has been reserved
pnp: 00:0c: iomem range 0xfee00000-0xfee00fff could not be reserved
pnp: 00:0f: iomem range 0xe0000000-0xefffffff has been reserved
pnp: 00:10: iomem range 0x0-0x9ffff could not be reserved
pnp: 00:10: iomem range 0xc0000-0xcffff has been reserved
pnp: 00:10: iomem range 0xe0000-0xfffff could not be reserved
pnp: 00:10: iomem range 0x100000-0x7fffffff could not be reserved
PCI: Bridge: 0000:00:01.0
  IO window: a000-afff
  MEM window: f8800000-fe8fffff
  PREFETCH window: bfe00000-dfdfffff
PCI: Bridge: 0000:00:1c.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: dfe00000-dfefffff
PCI: Bridge: 0000:00:1c.3
  IO window: disabled.
  MEM window: fea00000-feafffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.4
  IO window: b000-bfff
  MEM window: fe900000-fe9fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1e.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt 0000:00:1c.3[D] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1c.3 to 64
ACPI: PCI Interrupt 0000:00:1c.4[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.4 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 32768 (order: 9, 2359296 bytes)
TCP bind hash table entries: 32768 (order: 9, 2097152 bytes)
TCP: Hash tables configured (established 32768 bind 32768)
TCP reno registered
io scheduler noop registered
io scheduler cfq registered (default)
Boot video device is 0000:01:00.0
Real Time Clock Driver v1.12ac
ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:03:00.0 to 64
atl1 0000:03:00.0: version 2.0.7
netconsole: local port 6665
netconsole: local IP 10.10.0.42
netconsole: interface eth0
netconsole: remote port 9353
netconsole: remote IP 10.10.0.1
netconsole: remote ethernet address 00:80:48:45:ec:73
netconsole: device eth0 not up yet, forcing it
atl1 0000:03:00.0: eth0 link is up 100 Mbps full duplex
console [netcon0] enabled
netconsole: network logging started
ahci 0000:02:00.0: version 2.3
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
ahci 0000:02:00.0: AHCI 0001.0000 32 slots 2 ports 3 Gbps 0x3 impl SATA mode
ahci 0000:02:00.0: flags: 64bit ncq pm led clo pmp pio slum part 
PCI: Setting latency timer of device 0000:02:00.0 to 64
scsi0 : ahci
scsi1 : ahci
ata1: SATA max UDMA/133 abar m8192@0xfe9fe000 port 0xfe9fe100 irq 16
ata2: SATA max UDMA/133 abar m8192@0xfe9fe000 port 0xfe9fe180 irq 16
ata1: SATA link down (SStatus 0 SControl 300)
ata2: SATA link down (SStatus 0 SControl 300)
ata_piix 0000:00:1f.2: version 2.12
ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0xec00 ctl 0xe880 bmdma 0xe400 irq 19
ata4: SATA max UDMA/133 cmd 0xe800 ctl 0xe480 bmdma 0xe408 irq 19
ata3.00: ATA-7: ST3250620AS, 3.AAE, max UDMA/133
ata3.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata3.00: configured for UDMA/133
ata4.00: ATA-7: ST3320620AS, 3.AAK, max UDMA/133
ata4.00: 625142448 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata4.00: configured for UDMA/133
scsi 2:0:0:0: Direct-Access     ATA      ST3250620AS      3.AA PQ: 0 ANSI: 5
sd 2:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
sd 2:0:0:0: [sda] Write Protect is off
sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 2:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
sd 2:0:0:0: [sda] Write Protect is off
sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 2:0:0:0: [sda] Attached SCSI disk
scsi 3:0:0:0: Direct-Access     ATA      ST3320620AS      3.AA PQ: 0 ANSI: 5
sd 3:0:0:0: [sdb] 625142448 512-byte hardware sectors (320073 MB)
sd 3:0:0:0: [sdb] Write Protect is off
sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 3:0:0:0: [sdb] 625142448 512-byte hardware sectors (320073 MB)
sd 3:0:0:0: [sdb] Write Protect is off
sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1
sd 3:0:0:0: [sdb] Attached SCSI disk
ata_piix 0000:00:1f.5: MAP [ P0 P2 P1 P3 ]
ACPI: PCI Interrupt 0000:00:1f.5[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1f.5 to 64
scsi4 : ata_piix
scsi5 : ata_piix
ata5: SATA max UDMA/133 cmd 0xd400 ctl 0xd080 bmdma 0xc880 irq 19
ata6: SATA max UDMA/133 cmd 0xd000 ctl 0xcc00 bmdma 0xc888 irq 19
ACPI: PCI Interrupt 0000:02:00.1[B] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:02:00.1 to 64
scsi6 : pata_jmicron
scsi7 : pata_jmicron
ata7: PATA max UDMA/100 cmd 0xbc00 ctl 0xb880 bmdma 0xb400 irq 17
ata8: PATA max UDMA/100 cmd 0xb800 ctl 0xb480 bmdma 0xb408 irq 17
ata7.01: ATAPI: Optiarc DVD RW AD-7173A, 1-01, max UDMA/66
ata7.01: configured for UDMA/66
scsi 6:0:1:0: CD-ROM            Optiarc  DVD RW AD-7173A  1-01 PQ: 0 ANSI: 5
sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 6:0:1:0: Attached scsi CD-ROM sr0
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
TCP cubic registered
NET: Registered protocol family 1
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 572k freed
Write protecting the kernel read-only data: 2844k
EXT3 FS on sda2, internal journal
Adding 987956k swap on /dev/sda1.  Priority:-1 extents:1 across:987956k
Adding 65528k swap on ./swapfile01.  Priority:-2 extents:441 across:214212k
Adding 65528k swap on ./swapfile01.  Priority:-3 extents:295 across:307176k
Adding 65528k swap on ./swapfile01.  Priority:-4 extents:519 across:291404k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-5 extents:1 across:32k
Adding 32k swap on swapfile03.  Priority:-6 extents:1 across:32k
Adding 32k swap on swapfile04.  Priority:-7 extents:2 across:32k
Adding 32k swap on swapfile05.  Priority:-8 extents:1 across:32k
Adding 32k swap on swapfile06.  Priority:-9 extents:1 across:32k
Adding 32k swap on swapfile07.  Priority:-10 extents:2 across:44k
Adding 32k swap on swapfile08.  Priority:-11 extents:2 across:32k
Adding 32k swap on swapfile09.  Priority:-12 extents:1 across:32k
Adding 32k swap on swapfile10.  Priority:-13 extents:1 across:32k
Adding 32k swap on swapfile11.  Priority:-14 extents:4 across:84k
Adding 32k swap on swapfile12.  Priority:-15 extents:2 across:32k
Adding 32k swap on swapfile13.  Priority:-16 extents:1 across:32k
Adding 32k swap on swapfile14.  Priority:-17 extents:1 across:32k
Adding 32k swap on swapfile15.  Priority:-18 extents:2 across:36k
Adding 32k swap on swapfile16.  Priority:-19 extents:2 across:32k
Adding 32k swap on swapfile17.  Priority:-20 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-21 extents:1 across:32k
Adding 32k swap on swapfile19.  Priority:-22 extents:1 across:32k
Adding 32k swap on swapfile20.  Priority:-23 extents:2 across:32k
Adding 32k swap on swapfile21.  Priority:-24 extents:1 across:32k
Adding 32k swap on swapfile22.  Priority:-25 extents:1 across:32k
Adding 32k swap on swapfile23.  Priority:-26 extents:1 across:32k
Adding 32k swap on swapfile24.  Priority:-27 extents:2 across:32k
Adding 32k swap on swapfile25.  Priority:-28 extents:1 across:32k
Adding 32k swap on swapfile26.  Priority:-29 extents:1 across:32k
Adding 32k swap on swapfile27.  Priority:-30 extents:1 across:32k
Adding 32k swap on swapfile28.  Priority:-31 extents:2 across:32k
Adding 32k swap on swapfile29.  Priority:-32 extents:1 across:32k
Adding 32k swap on swapfile30.  Priority:-33 extents:1 across:32k
Adding 32k swap on swapfile31.  Priority:-34 extents:1 across:32k
Adding 32k swap on swapfile32.  Priority:-35 extents:2 across:32k
warning: process `sysctl01' used the deprecated sysctl system call with 1.1.
warning: process `sysctl01' used the deprecated sysctl system call with 1.2.
warning: process `sysctl03' used the deprecated sysctl system call with 1.1.
warning: process `sysctl03' used the deprecated sysctl system call with 1.1.
warning: process `sysctl04' used the deprecated sysctl system call with 
Adding 65528k swap on ./swapfile01.  Priority:-36 extents:437 across:208464k
Adding 65528k swap on ./swapfile01.  Priority:-37 extents:299 across:307156k
Adding 65528k swap on ./swapfile01.  Priority:-38 extents:436 across:208460k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-39 extents:2 across:44k
Adding 32k swap on swapfile03.  Priority:-40 extents:2 across:32k
Adding 32k swap on swapfile04.  Priority:-41 extents:2 across:32k
Adding 32k swap on swapfile05.  Priority:-42 extents:2 across:88k
Adding 32k swap on swapfile06.  Priority:-43 extents:1 across:32k
Adding 32k swap on swapfile07.  Priority:-44 extents:1 across:32k
Adding 32k swap on swapfile08.  Priority:-45 extents:1 across:32k
Adding 32k swap on swapfile09.  Priority:-46 extents:1 across:32k
Adding 32k swap on swapfile10.  Priority:-47 extents:1 across:32k
Adding 32k swap on swapfile11.  Priority:-48 extents:1 across:32k
Adding 32k swap on swapfile12.  Priority:-49 extents:3 across:44k
Adding 32k swap on swapfile13.  Priority:-50 extents:2 across:32k
Adding 32k swap on swapfile14.  Priority:-51 extents:1 across:32k
Adding 32k swap on swapfile15.  Priority:-52 extents:1 across:32k
Adding 32k swap on swapfile16.  Priority:-53 extents:2 across:32k
Adding 32k swap on swapfile17.  Priority:-54 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-55 extents:3 across:52k
Adding 32k swap on swapfile19.  Priority:-56 extents:1 across:32k
Adding 32k swap on swapfile20.  Priority:-57 extents:1 across:32k
Adding 32k swap on swapfile21.  Priority:-58 extents:1 across:32k
Adding 32k swap on swapfile22.  Priority:-59 extents:2 across:32k
Adding 32k swap on swapfile23.  Priority:-60 extents:1 across:32k
Adding 32k swap on swapfile24.  Priority:-61 extents:1 across:32k
Adding 32k swap on swapfile25.  Priority:-62 extents:1 across:32k
Adding 32k swap on swapfile26.  Priority:-63 extents:1 across:32k
Adding 32k swap on swapfile27.  Priority:-64 extents:2 across:36k
Adding 32k swap on swapfile28.  Priority:-65 extents:2 across:32k
Adding 32k swap on swapfile29.  Priority:-66 extents:1 across:32k
Adding 32k swap on swapfile30.  Priority:-67 extents:2 across:32k
Adding 32k swap on swapfile31.  Priority:-68 extents:2 across:32k
Adding 32k swap on swapfile32.  Priority:-69 extents:1 across:32k
Adding 65528k swap on ./swapfile01.  Priority:-70 extents:437 across:208512k
Adding 65528k swap on ./swapfile01.  Priority:-71 extents:303 across:307096k
Adding 65528k swap on ./swapfile01.  Priority:-72 extents:545 across:306152k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-73 extents:2 across:36k
Adding 32k swap on swapfile03.  Priority:-74 extents:1 across:32k
Adding 32k swap on swapfile04.  Priority:-75 extents:2 across:32k
Adding 32k swap on swapfile05.  Priority:-76 extents:1 across:32k
Adding 32k swap on swapfile06.  Priority:-77 extents:1 across:32k
Adding 32k swap on swapfile07.  Priority:-78 extents:2 across:44k
Adding 32k swap on swapfile08.  Priority:-79 extents:2 across:32k
Adding 32k swap on swapfile09.  Priority:-80 extents:1 across:32k
Adding 32k swap on swapfile10.  Priority:-81 extents:1 across:32k
Adding 32k swap on swapfile11.  Priority:-82 extents:1 across:32k
Adding 32k swap on swapfile12.  Priority:-83 extents:1 across:32k
Adding 32k swap on swapfile13.  Priority:-84 extents:1 across:32k
Adding 32k swap on swapfile14.  Priority:-85 extents:2 across:668k
Adding 32k swap on swapfile15.  Priority:-86 extents:1 across:32k
Adding 32k swap on swapfile16.  Priority:-87 extents:1 across:32k
Adding 32k swap on swapfile17.  Priority:-88 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-89 extents:1 across:32k
Adding 32k swap on swapfile19.  Priority:-90 extents:5 across:56k
Adding 32k swap on swapfile20.  Priority:-91 extents:1 across:32k
Adding 32k swap on swapfile21.  Priority:-92 extents:1 across:32k
Adding 32k swap on swapfile22.  Priority:-93 extents:1 across:32k
Adding 32k swap on swapfile23.  Priority:-94 extents:1 across:32k
Adding 32k swap on swapfile24.  Priority:-95 extents:1 across:32k
Adding 32k swap on swapfile25.  Priority:-96 extents:1 across:32k
Adding 32k swap on swapfile26.  Priority:-97 extents:3 across:44k
Adding 32k swap on swapfile27.  Priority:-98 extents:2 across:32k
Adding 32k swap on swapfile28.  Priority:-99 extents:1 across:32k
Adding 32k swap on swapfile29.  Priority:-100 extents:1 across:32k
Adding 32k swap on swapfile30.  Priority:-101 extents:2 across:32k
Adding 32k swap on swapfile31.  Priority:-102 extents:3 across:48k
Adding 32k swap on swapfile32.  Priority:-103 extents:1 across:32k
Adding 65528k swap on ./swapfile01.  Priority:-104 extents:2819 across:1023220k
Adding 65528k swap on ./swapfile01.  Priority:-105 extents:2126 across:1336040k
Adding 65528k swap on ./swapfile01.  Priority:-106 extents:2783 across:1040412k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-107 extents:2 across:36k
Adding 32k swap on swapfile03.  Priority:-108 extents:1 across:32k
Adding 32k swap on swapfile04.  Priority:-109 extents:2 across:32k
Adding 32k swap on swapfile05.  Priority:-110 extents:2 across:48k
Adding 32k swap on swapfile06.  Priority:-111 extents:1 across:32k
Adding 32k swap on swapfile07.  Priority:-112 extents:4 across:13712k
Adding 32k swap on swapfile08.  Priority:-113 extents:1 across:32k
Adding 32k swap on swapfile09.  Priority:-114 extents:3 across:8060k
Adding 32k swap on swapfile10.  Priority:-115 extents:3 across:80k
Adding 32k swap on swapfile11.  Priority:-116 extents:1 across:32k
Adding 32k swap on swapfile12.  Priority:-117 extents:3 across:95376k
Adding 32k swap on swapfile13.  Priority:-118 extents:1 across:32k
Adding 32k swap on swapfile14.  Priority:-119 extents:1 across:32k
Adding 32k swap on swapfile15.  Priority:-120 extents:2 across:32k
Adding 32k swap on swapfile16.  Priority:-121 extents:4 across:71636k
Adding 32k swap on swapfile17.  Priority:-122 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-123 extents:2 across:60k
Adding 32k swap on swapfile19.  Priority:-124 extents:1 across:32k
Adding 32k swap on swapfile20.  Priority:-125 extents:1 across:32k
Adding 32k swap on swapfile21.  Priority:-126 extents:2 across:7272k
Adding 32k swap on swapfile22.  Priority:-127 extents:1 across:32k
Adding 32k swap on swapfile23.  Priority:-128 extents:1 across:32k
Adding 32k swap on swapfile24.  Priority:-129 extents:1 across:32k
Adding 32k swap on swapfile25.  Priority:-130 extents:1 across:32k
Adding 32k swap on swapfile26.  Priority:-131 extents:1 across:32k
Adding 32k swap on swapfile27.  Priority:-132 extents:1 across:32k
Adding 32k swap on swapfile28.  Priority:-133 extents:1 across:32k
Adding 32k swap on swapfile29.  Priority:-134 extents:2 across:668k
Adding 32k swap on swapfile30.  Priority:-135 extents:2 across:32k
Adding 32k swap on swapfile31.  Priority:-136 extents:3 across:80k
Adding 32k swap on swapfile32.  Priority:-137 extents:1 across:32k
Adding 65528k swap on ./swapfile01.  Priority:-138 extents:244 across:4982272k
Adding 65528k swap on ./swapfile01.  Priority:-139 extents:153 across:4967584k
Adding 65528k swap on ./swapfile01.  Priority:-140 extents:235 across:4962056k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-141 extents:5 across:15384k
Adding 32k swap on swapfile03.  Priority:-142 extents:3 across:12216k
Adding 32k swap on swapfile04.  Priority:-143 extents:5 across:512k
Adding 32k swap on swapfile05.  Priority:-144 extents:7 across:121184k
Adding 32k swap on swapfile06.  Priority:-145 extents:1 across:32k
Adding 32k swap on swapfile07.  Priority:-146 extents:1 across:32k
Adding 32k swap on swapfile08.  Priority:-147 extents:1 across:32k
Adding 32k swap on swapfile09.  Priority:-148 extents:1 across:32k
Adding 32k swap on swapfile10.  Priority:-149 extents:1 across:32k
Adding 32k swap on swapfile11.  Priority:-150 extents:1 across:32k
Adding 32k swap on swapfile12.  Priority:-151 extents:2 across:32k
Adding 32k swap on swapfile13.  Priority:-152 extents:2 across:9964k
Adding 32k swap on swapfile14.  Priority:-153 extents:2 across:1432k
Adding 32k swap on swapfile15.  Priority:-154 extents:4 across:130088k
Adding 32k swap on swapfile16.  Priority:-155 extents:2 across:40k
Adding 32k swap on swapfile17.  Priority:-156 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-157 extents:1 across:32k
Adding 32k swap on swapfile19.  Priority:-158 extents:1 across:32k
Adding 32k swap on swapfile20.  Priority:-159 extents:1 across:32k
Adding 32k swap on swapfile21.  Priority:-160 extents:4 across:520k
Adding 32k swap on swapfile22.  Priority:-161 extents:2 across:120k
Adding 32k swap on swapfile23.  Priority:-162 extents:3 across:84740k
Adding 32k swap on swapfile24.  Priority:-163 extents:1 across:32k
Adding 32k swap on swapfile25.  Priority:-164 extents:4 across:53808k
Adding 32k swap on swapfile26.  Priority:-165 extents:7 across:88k
Adding 32k swap on swapfile27.  Priority:-166 extents:6 across:76k
Adding 32k swap on swapfile28.  Priority:-167 extents:3 across:226336k
Adding 32k swap on swapfile29.  Priority:-168 extents:3 across:80k
Adding 32k swap on swapfile30.  Priority:-169 extents:1 across:32k
Adding 32k swap on swapfile31.  Priority:-170 extents:4 across:1108k
Adding 32k swap on swapfile32.  Priority:-171 extents:3 across:352k
Adding 65528k swap on ./swapfile01.  Priority:-172 extents:233 across:5005176k
Adding 65528k swap on ./swapfile01.  Priority:-173 extents:305 across:5136576k
Adding 65528k swap on ./swapfile01.  Priority:-174 extents:233 across:5005172k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-175 extents:7 across:15616k
Adding 32k swap on swapfile03.  Priority:-176 extents:4 across:2100k
Adding 32k swap on swapfile04.  Priority:-177 extents:3 across:2460k
Adding 32k swap on swapfile05.  Priority:-178 extents:1 across:32k
Adding 32k swap on swapfile06.  Priority:-179 extents:3 across:114224k
Adding 32k swap on swapfile07.  Priority:-180 extents:2 across:40k
Adding 32k swap on swapfile08.  Priority:-181 extents:1 across:32k
Adding 32k swap on swapfile09.  Priority:-182 extents:2 across:40k
Adding 32k swap on swapfile10.  Priority:-183 extents:2 across:32k
Adding 32k swap on swapfile11.  Priority:-184 extents:1 across:32k
Adding 32k swap on swapfile12.  Priority:-185 extents:1 across:32k
Adding 32k swap on swapfile13.  Priority:-186 extents:2 across:264k
Adding 32k swap on swapfile14.  Priority:-187 extents:2 across:32k
Adding 32k swap on swapfile15.  Priority:-188 extents:1 across:32k
Adding 32k swap on swapfile16.  Priority:-189 extents:1 across:32k
Adding 32k swap on swapfile17.  Priority:-190 extents:2 across:32k
Adding 32k swap on swapfile18.  Priority:-191 extents:2 across:232k
Adding 32k swap on swapfile19.  Priority:-192 extents:1 across:32k
Adding 32k swap on swapfile20.  Priority:-193 extents:1 across:32k
Adding 32k swap on swapfile21.  Priority:-194 extents:2 across:32k
Adding 32k swap on swapfile22.  Priority:-195 extents:2 across:32k
Adding 32k swap on swapfile23.  Priority:-196 extents:1 across:32k
Adding 32k swap on swapfile24.  Priority:-197 extents:2 across:264k
Adding 32k swap on swapfile25.  Priority:-198 extents:2 across:32k
Adding 32k swap on swapfile26.  Priority:-199 extents:1 across:32k
Adding 32k swap on swapfile27.  Priority:-200 extents:1 across:32k
Adding 32k swap on swapfile28.  Priority:-201 extents:2 across:32k
Adding 32k swap on swapfile29.  Priority:-202 extents:1 across:32k
Adding 32k swap on swapfile30.  Priority:-203 extents:1 across:32k
Adding 32k swap on swapfile31.  Priority:-204 extents:2 across:232k
Adding 32k swap on swapfile32.  Priority:-205 extents:1 across:32k
Adding 65528k swap on ./swapfile01.  Priority:-206 extents:262 across:3334788k
Adding 65528k swap on ./swapfile01.  Priority:-207 extents:513 across:3293028k
Adding 65528k swap on ./swapfile01.  Priority:-208 extents:234 across:3214248k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-209 extents:2 across:396k
Adding 32k swap on swapfile03.  Priority:-210 extents:2 across:312k
Adding 32k swap on swapfile04.  Priority:-211 extents:2 across:576k
Adding 32k swap on swapfile05.  Priority:-212 extents:3 across:272k
Adding 32k swap on swapfile06.  Priority:-213 extents:1 across:32k
Adding 32k swap on swapfile07.  Priority:-214 extents:3 across:2108k
Adding 32k swap on swapfile08.  Priority:-215 extents:5 across:83148k
Adding 32k swap on swapfile09.  Priority:-216 extents:5 across:812k
Adding 32k swap on swapfile10.  Priority:-217 extents:1 across:32k
Adding 32k swap on swapfile11.  Priority:-218 extents:2 across:32k
Adding 32k swap on swapfile12.  Priority:-219 extents:1 across:32k
Adding 32k swap on swapfile13.  Priority:-220 extents:1 across:32k
Adding 32k swap on swapfile14.  Priority:-221 extents:4 across:2120k
Adding 32k swap on swapfile15.  Priority:-222 extents:1 across:32k
Adding 32k swap on swapfile16.  Priority:-223 extents:1 across:32k
Adding 32k swap on swapfile17.  Priority:-224 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-225 extents:3 across:1224k
Adding 32k swap on swapfile19.  Priority:-226 extents:1 across:32k
Adding 32k swap on swapfile20.  Priority:-227 extents:1 across:32k
Adding 32k swap on swapfile21.  Priority:-228 extents:3 across:36k
Adding 32k swap on swapfile22.  Priority:-229 extents:2 across:32k
Adding 32k swap on swapfile23.  Priority:-230 extents:1 across:32k
Adding 32k swap on swapfile24.  Priority:-231 extents:1 across:32k
Adding 32k swap on swapfile25.  Priority:-232 extents:2 across:32k
Adding 32k swap on swapfile26.  Priority:-233 extents:1 across:32k
Adding 32k swap on swapfile27.  Priority:-234 extents:1 across:32k
Adding 32k swap on swapfile28.  Priority:-235 extents:1 across:32k
Adding 32k swap on swapfile29.  Priority:-236 extents:2 across:32k
Adding 32k swap on swapfile30.  Priority:-237 extents:1 across:32k
Adding 32k swap on swapfile31.  Priority:-238 extents:1 across:32k
Adding 32k swap on swapfile32.  Priority:-239 extents:2 across:32k
Adding 65528k swap on ./swapfile01.  Priority:-240 extents:349 across:291004k
Adding 65528k swap on ./swapfile01.  Priority:-241 extents:446 across:431984k
Adding 65528k swap on ./swapfile01.  Priority:-242 extents:370 across:422936k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-243 extents:3 across:16272k
Adding 32k swap on swapfile03.  Priority:-244 extents:3 across:56k
Adding 32k swap on swapfile04.  Priority:-245 extents:5 across:17720k
Adding 32k swap on swapfile05.  Priority:-246 extents:1 across:32k
Adding 32k swap on swapfile06.  Priority:-247 extents:3 across:114368k
Adding 32k swap on swapfile07.  Priority:-248 extents:3 across:232k
Adding 32k swap on swapfile08.  Priority:-249 extents:1 across:32k
Adding 32k swap on swapfile09.  Priority:-250 extents:5 across:1660k
Adding 32k swap on swapfile10.  Priority:-251 extents:2 across:32k
Adding 32k swap on swapfile11.  Priority:-252 extents:1 across:32k
Adding 32k swap on swapfile12.  Priority:-253 extents:2 across:216k
Adding 32k swap on swapfile13.  Priority:-254 extents:1 across:32k
Adding 32k swap on swapfile14.  Priority:-255 extents:1 across:32k
Adding 32k swap on swapfile15.  Priority:-256 extents:1 across:32k
Adding 32k swap on swapfile16.  Priority:-257 extents:2 across:32k
Adding 32k swap on swapfile17.  Priority:-258 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-259 extents:1 across:32k
Adding 32k swap on swapfile19.  Priority:-260 extents:5 across:500k
Adding 32k swap on swapfile20.  Priority:-261 extents:3 across:272k
Adding 32k swap on swapfile21.  Priority:-262 extents:1 across:32k
Adding 32k swap on swapfile22.  Priority:-263 extents:1 across:32k
Adding 32k swap on swapfile23.  Priority:-264 extents:2 across:232k
Adding 32k swap on swapfile24.  Priority:-265 extents:1 across:32k
Adding 32k swap on swapfile25.  Priority:-266 extents:1 across:32k
Adding 32k swap on swapfile26.  Priority:-267 extents:2 across:32k
Adding 32k swap on swapfile27.  Priority:-268 extents:1 across:32k
Adding 32k swap on swapfile28.  Priority:-269 extents:3 across:40k
Adding 32k swap on swapfile29.  Priority:-270 extents:5 across:18668k
Adding 32k swap on swapfile30.  Priority:-271 extents:3 across:488k
Adding 32k swap on swapfile31.  Priority:-272 extents:1 across:32k
Adding 32k swap on swapfile32.  Priority:-273 extents:1 across:32k
Adding 65528k swap on ./swapfile01.  Priority:-274 extents:444 across:483772k
Adding 65528k swap on ./swapfile01.  Priority:-275 extents:255 across:769156k
Adding 65528k swap on ./swapfile01.  Priority:-276 extents:384 across:589124k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-277 extents:2 across:32k
Adding 32k swap on swapfile03.  Priority:-278 extents:1 across:32k
Adding 32k swap on swapfile04.  Priority:-279 extents:1 across:32k
Adding 32k swap on swapfile05.  Priority:-280 extents:2 across:3220k
Adding 32k swap on swapfile06.  Priority:-281 extents:1 across:32k
Adding 32k swap on swapfile07.  Priority:-282 extents:1 across:32k
Adding 32k swap on swapfile08.  Priority:-283 extents:3 across:44k
Adding 32k swap on swapfile09.  Priority:-284 extents:2 across:44k
Adding 32k swap on swapfile10.  Priority:-285 extents:1 across:32k
Adding 32k swap on swapfile11.  Priority:-286 extents:1 across:32k
Adding 32k swap on swapfile12.  Priority:-287 extents:1 across:32k
Adding 32k swap on swapfile13.  Priority:-288 extents:3 across:200k
Adding 32k swap on swapfile14.  Priority:-289 extents:2 across:668k
Adding 32k swap on swapfile15.  Priority:-290 extents:3 across:116k
Adding 32k swap on swapfile16.  Priority:-291 extents:1 across:32k
Adding 32k swap on swapfile17.  Priority:-292 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-293 extents:3 across:44k
Adding 32k swap on swapfile19.  Priority:-294 extents:1 across:32k
Adding 32k swap on swapfile20.  Priority:-295 extents:1 across:32k
Adding 32k swap on swapfile21.  Priority:-296 extents:2 across:32k
Adding 32k swap on swapfile22.  Priority:-297 extents:1 across:32k
Adding 32k swap on swapfile23.  Priority:-298 extents:1 across:32k
Adding 32k swap on swapfile24.  Priority:-299 extents:2 across:36k
Adding 32k swap on swapfile25.  Priority:-300 extents:1 across:32k
Adding 32k swap on swapfile26.  Priority:-301 extents:4 across:84k
Adding 32k swap on swapfile27.  Priority:-302 extents:1 across:32k
Adding 32k swap on swapfile28.  Priority:-303 extents:1 across:32k
Adding 32k swap on swapfile29.  Priority:-304 extents:2 across:32k
Adding 32k swap on swapfile30.  Priority:-305 extents:4 across:448k
Adding 32k swap on swapfile31.  Priority:-306 extents:1 across:32k
Adding 32k swap on swapfile32.  Priority:-307 extents:1 across:32k
Adding 65528k swap on ./swapfile01.  Priority:-308 extents:404 across:251672k
Adding 65528k swap on ./swapfile01.  Priority:-309 extents:818 across:3493240k
Adding 65528k swap on ./swapfile01.  Priority:-310 extents:420 across:416548k
Unable to find swap-space signature
Adding 32k swap on swapfile02.  Priority:-311 extents:3 across:60k
Adding 32k swap on swapfile03.  Priority:-312 extents:3 across:80k
Adding 32k swap on swapfile04.  Priority:-313 extents:1 across:32k
Adding 32k swap on swapfile05.  Priority:-314 extents:1 across:32k
Adding 32k swap on swapfile06.  Priority:-315 extents:3 across:7436k
Adding 32k swap on swapfile07.  Priority:-316 extents:3 across:60k
Adding 32k swap on swapfile08.  Priority:-317 extents:1 across:32k
Adding 32k swap on swapfile09.  Priority:-318 extents:2 across:56k
Adding 32k swap on swapfile10.  Priority:-319 extents:1 across:32k
Adding 32k swap on swapfile11.  Priority:-320 extents:1 across:32k
Adding 32k swap on swapfile12.  Priority:-321 extents:4 across:1672k
Adding 32k swap on swapfile13.  Priority:-322 extents:1 across:32k
Adding 32k swap on swapfile14.  Priority:-323 extents:2 across:56k
Adding 32k swap on swapfile15.  Priority:-324 extents:1 across:32k
Adding 32k swap on swapfile16.  Priority:-325 extents:2 across:32k
Adding 32k swap on swapfile17.  Priority:-326 extents:1 across:32k
Adding 32k swap on swapfile18.  Priority:-327 extents:1 across:32k
Adding 32k swap on swapfile19.  Priority:-328 extents:1 across:32k
Adding 32k swap on swapfile20.  Priority:-329 extents:1 across:32k
Adding 32k swap on swapfile21.  Priority:-330 extents:2 across:32k
Adding 32k swap on swapfile22.  Priority:-331 extents:1 across:32k
Adding 32k swap on swapfile23.  Priority:-332 extents:1 across:32k
Adding 32k swap on swapfile24.  Priority:-333 extents:1 across:32k
Adding 32k swap on swapfile25.  Priority:-334 extents:5 across:500k
Adding 32k swap on swapfile26.  Priority:-335 extents:7 across:18760k
Adding 32k swap on swapfile27.  Priority:-336 extents:1 across:32k
Adding 32k swap on swapfile28.  Priority:-337 extents:3 across:56k
Adding 32k swap on swapfile29.  Priority:-338 extents:2 across:32k
Adding 32k swap on swapfile30.  Priority:-339 extents:1 across:32k
Adding 32k swap on swapfile31.  Priority:-340 extents:1 across:32k
Adding 32k swap on swapfile32.  Priority:-341 extents:1 across:32k


		[at this point box is knocked off the net,
		 from VT console]


SysRq : Show State
  task                        PC stack   pid father
init          S ffff810003f70540     0     1      0
 ffff8100034899f8 0000000000000096 ffffffff803e28d5 ffffffff805cbfc0
 000000010030f95c ffff810003480000 ffff81001125d320 ffff810003480218
 0000000000000296 0000000000000296 0000000000000400 ffff810003489a08
Call Trace:
 [<ffffffff803dfe5f>] schedule_timeout+0x5f/0xd0
 [<ffffffff8028995d>] do_select+0x44d/0x540
 [<ffffffff80289c55>] core_sys_select+0x205/0x300
 [<ffffffff8028a1f1>] sys_select+0xd1/0x1c0
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007fc61d9a82d3>]

kthreadd      S ffff810004810000     0     2      0
 ffff81000348bf20 0000000000000086 0000000200000000 0000000000000000
 ffff810014d4bdc8 ffff8100034810a0 ffff81000da90000 ffff8100034812b8
 ffffffff804dced8 ffffffff80245ea5 0000000000000000 ffff8100034810a0
Call Trace:
 [<ffffffff8023bb76>] kthreadd+0x146/0x150
es+0xaa/0x100
<4> [<ffffffff8029bb55>] sync_inodes+0x35/0x50
 [<ffffffff8029f03c>] do_sync+0x2c/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

ftest01       D ffff810003f71500     0 16718  16712
 ffff81000d87fd08 0000000000000092 ffff81006b396b18 ffff81006b3963c0
 0000000000000000 ffff81006b3963c0 ffff8100036763c0 ffff81006b3965d8
 0000000000000002 ffff81006b3963c0 ffffffff803e28d5 ffff81000d87fd18
Call Trace:
 [<ffffffff802d1155>] log_wait_commit+0xc5/0x140
 [<ffffffff802cbc8e>] journal_stop+0x12e/0x210
 [<ffffffff8029b279>] __writeback_single_inode+0x2a9/0x350
 [<ffffffff8029b7a7>] generic_sync_sb_inodes+0x227/0x3d0
 [<ffffffff8029ba0b>] sync_inodes_sb+0x9b/0xb0
 [<ffffffff8029baca>] __sync_inodes+0xaa/0x100
 [<ffffffff8029bb55>] sync_inodes+0x35/0x50
 [<ffffffff8029f03c>] do_sync+0x2c/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

pdflush       S ffff810004e224c0     0 16988      2
 ffff8100716e9ee0 0000000000000086 0000000200000001 0000000000000000
 0000000000000000 ffff810003622140 ffff81000b4190a0 ffff810003622358
 ffffffff804e6440 ffffffff80245ea5 0000000000000000 ffff810003622140
Call Trace:
 [<fff [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f3c1b46e810>]

make          S ffff810004e20fc0     0 27369  26324
 ffff81003167bce8 0000000000000096 ffff81006b390758 ffff81006b390000
 0000000000000000 ffff81006b390000 ffff8100648d2140 ffff81006b390218
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b89fff49810>]

make          S ffff810003f6e900     0 28427  26324
 ffff81000d96fce8 0000000000000096 ffff81000b508758 ffff81000b508000
 0000000000000000 ffff81000b508000 ffff81006b390000 ffff81000b508218
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002af937289810>]

make          S ffff810003f6b480     0  7879   2541
 ffff810058835e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100036896c8 ffff81001125a140 ffff8100648d10a0 ffff81001125a358
 ffffffff80505298 ffffffff80245ea5 0000000000000001 ffff81001125a140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f92918f1ce4>]

sh            S ffff810004e25940     0  7887   7879
 ffff810042ec5e98 0000000000000096 0000000200000000 0000000000000002
 ffff810071586d88 ffff8100648d10a0 ffff81006b3931e0 ffff8100648d12b8
 ffffffff80505298 ffffffff80245ea5 0000000000001e00 ffff8100648d10a0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aafe8c7ed85>]

expect        S ffff810004817380     0  7891   7887
 ffff81007ba119f8 0000000000000096 ffffffff803e28d5 ffffffff805cbfc0
 000000010031c27b ffff8100315b90a0 ffff8100055bd320 ffff8100315b92b8
 0000000000000296 0000000000000296 0000000000000040 ffff81007ba11a08
Call Trace:
 [<ffffffff803dfe5f>] schedule_timeout+0x5f/0xd0
 [<ffffffff8028995d>] do_select+0x44d/0x540
 [<ffffffff80289c55>] core_sys_select+0x205/0x300
 [<ffffffff8028a1f1>] sys_select+0xd1/0x1c0
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b430d3852d3>]

gdb           S ffff810003f6d940     0 10505   7891
 ffff810022ac3f28 0000000000000096 0000000200000001 0000000000000000
 0000000003e60000 ffff8100648d4280 ffff810003e60000 ffff8100648d4498
 ffff81000b5c0808 ffffffff80245ea5 00000000ffffffff ffff8100648d4280
Call Trace:
 [<ffffffff80233b11>] sys_rt_sigsuspend+0xc1/0xf0
 [<ffffffff8020be97>] ptregscall_common+0x67/0xb0
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b1998eb7b4a>]

bigcore       R  running task        0 10516  10505
pdflush       S ffff810003f72a00     0   848      2
 ffff810014d4bee0 0000000000000086 0000000200000001 0000000000000000
 0000000000000000 ffff81000da90000 ffff8100055b63c0 ffff81000da90218
 ffffffff804e6440 ffffffff80245ea5 0000000000000000 ffff81000da90000
Call Trace:
 [<ffffffff8025cc1f>] pdflush+0xbf/0x1d0
 [<ffffffff8023b9fb>] kthread+0x4b/0x80
 [<ffffffff8020c9d8>] child_rip+0xa/0x12

make          S ffff810003f6c440     0  6636  28427
 ffff81000b45fe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e9d48 ffff8100081ab1e0 ffff81006b395320 ffff8100081ab3f8
 ffffffff80505298 ffffffff80245ea5 0000000000000001 ffff8100081ab1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b187a333ce4>]

make          S ffff810003f71f80     0  9992   6636
 ffff81005ae4fce8 0000000000000096 ffff8100648d2898 ffff8100648d2140
 0000000000000000 ffff8100648d2140 ffff81000b41e3c0 ffff8100648d2358
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002adfca7d7810>]

make          S ffff810003f68000     0 13188  28427
 ffff81000da81ce8 0000000000000096 ffff81006b395a78 ffff81006b395320
 0000000000000000 ffff81006b395320 ffff8100315bc280 ffff81006b395538
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b01fee9f810>]

make          S ffff810004814440     0 13606  27369
 ffff81002284fce8 0000000000000096 ffff81000da93938 ffff81000da931e0
 0000000000000000 ffff81000da931e0 ffff81000b508000 ffff81000da933f8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ae6660e2810>]

ftest01       S ffff810004814ec0     0 16712   2004
 ffff8100054dfe98 0000000000000096 0000000200000000 0000000000000002
 ffff81006494ba88 ffff810003540000 ffff81000d012140 ffff810003540218
 ffffffff80505298 ffffffff80245ea5 00007fff22ee27a0 ffff810003540000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac1cce4>]

ftest01       D ffff810003f73f00     0 16714  16712
 ffff81000b6e3698 0000000000000096 ffff8100315ba140 ffffffff80249945
 0000000200000001 ffff8100315ba140 ffff81006b3963c0 ffff8100315ba358
 ffff8100315ba8e0 ffff8100315ba140 0000000000000001 0000000000000000
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff802a0f6e>] sync_buffer+0x3e/0x50
 [<ffffffff803dff5a>] __wait_on_bit_lock+0x4a/0x80
 [<ffffffff803e000a>] out_of_line_wait_on_bit_lock+0x7a/0xa0
 [<ffffffff802cbf95>] do_get_write_access+0x225/0x490
 [<ffffffff802cc229>] journal_get_write_access+0x29/0x50
 [<ffffffff802cb63c>] __ext3_journal_get_write_access+0x2c/0x70
 [<ffffffff802bf768>] ext3_get_blocks_handle+0x778/0xb00
 [<ffffffff802bfd4e>] ext3_get_block+0x8e/0x120
 [<ffffffff802a1400>] __block_prepare_write+0x1c0/0x410
 [<ffffffff802a16d4>] block_write_begin+0x54/0xe0
 [<ffffffff802c1511>] ext3_write_begin+0xd1/0x1c0
 [<ffffffff80256981>] generic_file_buffered_write+0x151/0x6c0
 [<ffffffff80257181>] __generic_file_aio_write_nolock+0x291/0x450
 [<ffffffff802573a1>] generic_file_aio_write+0x61/0xd0
 [<ffffffff802bcf23>] ext3_file_write+0x23/0xc0
 [<ffffffff8027b989>] do_sync_write+0xd9/0x120
 [<ffffffff8027c18d>] vfs_write+0xad/0xe0
 [<ffffffff8027c773>] sys_write+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac3d890>]

ftest01       D ffff810003f72a00     0 16715  16712
 ffff810014e29c98 0000000000000096 ffff81000b50a140 ffffffff80249945
 0000000200000001 ffff81000b50a140 ffff8100055b63c0 ffff81000b50a358
 ffff81000b50a898 ffff81000b50a140 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff80255525>] sync_page+0x45/0x60
 [<ffffffff803dff5a>] __wait_on_bit_lock+0x4a/0x80
 [<ffffffff802554bf>] __lock_page+0x5f/0x70
 [<ffffffff8025bf4e>] write_cache_pages+0x1be/0x370
 [<ffffffff8025c153>] do_writepages+0x23/0x40
 [<ffffffff8025628e>] __filemap_fdatawrite_range+0x6e/0x90
 [<ffffffff80256555>] filemap_write_and_wait+0x35/0x50
 [<ffffffff8029badd>] __sync_inodes+0xbd/0x100
 [<ffffffff8029bb55>] sync_inodes+0x35/0x50
 [<ffffffff8029f03c>] do_sync+0x2c/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

ftest01       D ffff810003f70a80     0 16716  16712
 ffff8100317f7be8 0000000000000096 ffff81000b50b1e0 ffffffff80249945
 0000000200000001 ffff81000b50b1e0 ffff81000da90000 ffff81000b50b3f8
 ffff81000b50b938 ffff81000b50b1e0 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff80255525>] sync_page+0x45/0x60
 [<ffffffff803e007f>] __wait_on_bit+0x4f/0x80
 [<ffffffff8025581c>] wait_on_page_bit+0x6c/0x80
 [<ffffffff8025c04d>] write_cache_pages+0x2bd/0x370
 [<ffffffff8025c153>] do_writepages+0x23/0x40
 [<ffffffff8029b251>] __writeback_single_inode+0x281/0x350
 [<ffffffff8029b7a7>] generic_sync_sb_inodes+0x227/0x3d0
 [<ffffffff8029ba0b>] sync_inodes_sb+0x9b/0xb0
 [<ffffffff8029baca>] __sync_inodes+0xaa/0x100
 [<ffffffff8029bb3e>] sync_inodes+0x1e/0x50
 [<ffffffff8029f022>] do_sync+0x12/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

ftest01       D ffff810003f739c0     0 16717  16712
 ffff8100050f5b58 0000000000000096 ffff81000b50e3c0 ffffffff80249945
 0000000200000001 ffff81000b50e3c0 ffff81000b50a140 ffff81000b50e5d8
 ffff81000b50eb18 ffff81000b50e3c0 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff802a0f6e>] sync_buffer+0x3e/0x50
 [<ffffffff803dff5a>] __wait_on_bit_lock+0x4a/0x80
 [<ffffffff803e000a>] out_of_line_wait_on_bit_lock+0x7a/0xa0
 [<ffffffff802a19ce>] __block_write_full_page+0x14e/0x300
 [<ffffffff8025b94d>] __writepage+0xd/0x30
 [<ffffffff8025bfd6>] write_cache_pages+0x246/0x370
 [<ffffffff8025c153>] do_writepages+0x23/0x40
 [<ffffffff8029b079>] __writeback_single_inode+0xa9/0x350
 [<ffffffff8029b7a7>] generic_sync_sb_inodes+0x227/0x3d0
 [<ffffffff8029ba0b>] sync_inodes_sb+0x9b/0xb0
 [<ffffffff8029baca>] __sync_inodes+0xaa/0x100
 [<ffffffff8029bb55>] sync_inodes+0x35/0x50
 [<ffffffff8029f03c>] do_sync+0x2c/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

ftest01       D ffff810003f71500     0 16718  16712
 ffff81000d87fd08 0000000000000092 ffff81006b396b18 ffff81006b3963c0
 0000000000000000 ffff81006b3963c0 ffff8100036763c0 ffff81006b3965d8
 0000000000000002 ffff81006b3963c0 ffffffff803e28d5 ffff81000d87fd18
Call Trace:
 [<ffffffff802d1155>] log_wait_commit+0xc5/0x140
 [<ffffffff802cbc8e>] journal_stop+0x12e/0x210
 [<ffffffff8029b279>] __writeback_single_inode+0x2a9/0x350
 [<ffffffff8029b7a7>] generic_sync_sb_inodes+0x227/0x3d0
 [<ffffffff8029ba0b>] sync_inodes_sb+0x9b/0xb0
 [<ffffffff8029baca>] __sync_inodes+0xaa/0x100
 [<ffffffff8029bb55>] sync_inodes+0x35/0x50
 [<ffffffff8029f03c>] do_sync+0x2c/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

pdflush       S ffff810004e224c0     0 16988      2
 ffff8100716e9ee0 0000000000000086 0000000200000001 0000000000000000
 0000000000000000 ffff810003622140 ffff81000b4190a0 ffff810003622358
 ffffffff804e6440 ffffffff80245ea5 0000000000000000 ffff810003622140
Call Trace:
 [<ffffffff8025cc1f>] pdflush+0xbf/0x1d0
 [<ffffffff8023b9fb>] kthread+0x4b/0x80
 [<ffffffff8020c9d8>] child_rip+0xa/0x12

make          S ffff810004e21500     0 19225  13188
 ffff81000d2d3ce8 0000000000000096 ffff81000b41eb18 ffff81000b41e3c0
 0000000000000000 ffff81000b41e3c0 ffff810011258000 ffff81000b41e5d8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002afa2bd31810>]

make          S ffff810004e22f40     0 19531  28427
 ffff810042ff9ce8 0000000000000096 ffff8100315a97f8 ffff8100315a90a0
 0000000000000000 ffff8100315a90a0 ffff8100648e10a0 ffff8100315a92b8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b57c610a810>]

make          S ffff810003f6e3c0     0 19595   9992
 ffff810064b91ce8 0000000000000096 ffff8100315ac9d8 ffff8100315ac280
 0000000000000000 ffff8100315ac280 ffff8100315bc280 ffff8100315ac498
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b1820a99810>]

bash          R  running task        0 19596   3130
make          S ffff810003f76900     0 19599   9992
 ffff81005af05e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100052ea088 ffff8100315ae3c0 ffff8100648d0000 ffff8100315ae5d8
 ffffffff80505298 ffffffff80245ea5 0000000000000001 ffff8100315ae3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002abae8943ce4>]

sh            S ffff810003f6b9c0     0 19622  19595
 ffff810022823e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100052ead88 ffff8100036263c0 ffff8100315ac280 ffff8100036265d8
 ffffffff80505298 ffffffff80245ea5 0000000000004c00 ffff8100036263c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002abe94d8ed85>]

ccache        S ffff810003f77380     0 19623  19622
 ffff81000da03e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100052eaa48 ffff8100034b63c0 ffff810003624280 ffff8100034b65d8
 ffffffff80505298 ffffffff80245ea5 000000000050e6c0 ffff8100034b63c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab0801e9d85>]

hppa-unknown- S ffff810004e224c0     0 19690  19623
 ffff81000d9f3e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8f408 ffff8100055eb1e0 ffff81001125d320 ffff8100055eb3f8
 ffffffff80505298 ffffffff80245ea5 00007fff2ad431a0 ffff8100055eb1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ba07ff0fd85>]

cc1           R  running task        0 19691  19690
as            S ffff810004e26900     0 19692  19690
 ffff8100588ffce8 0000000000000096 ffff8100081ada78 ffff8100081ad320
 0000000000000000 ffff8100081ad320 ffff8100055e8000 ffff8100081ad538
 ffffffff803e06e7 0000000000000246 ffff81000c19aa90 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab732334810>]

sh            S ffff8100048139c0     0 19762  13606
 ffff810042f8be98 0000000000000096 0000000200000000 0000000000000002
 ffff8100052ea708 ffff8100648e4280 ffff8100036231e0 ffff8100648e4498
 ffffffff80505298 ffffffff80245ea5 0000000000004d00 ffff8100648e4280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b50d81b8d85>]

ccache        S ffff810004812f40     0 19765  19762
 ffff810042dbfe98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8f748 ffff8100648d5320 ffff8100064ba140 ffff8100648d5538
 ffffffff80505298 ffffffff80245ea5 000000000050e6f0 ffff8100648d5320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b8cd03c3d85>]

hppa-unknown- S ffff810004815e80     0 19789  19765
 ffff810042fade98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eb0c8 ffff8100064ba140 ffff8100064bb1e0 ffff8100064ba358
 ffffffff80505298 ffffffff80245ea5 00007fff4974dc10 ffff8100064ba140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002af661506d85>]

cc1           R  running task        0 19790  19789
as            S ffff810003f71a40     0 19791  19789
 ffff810071513ce8 0000000000000096 ffff8100064b8758 ffff8100064b8000
 0000000000000000 ffff8100064b8000 ffff8100064bb1e0 ffff8100064b8218
 ffffffff803e06e7 0000000000000246 ffff81000c199f38 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b50db413810>]

make          S ffff810004811f80     0 19824  28427
 ffff810005115ce8 0000000000000096 ffff8100648e3938 ffff8100648e31e0
 0000000000000000 ffff8100648e31e0 ffff8100315ac280 ffff8100648e33f8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002afcad0bb810>]

make          S ffff810003f70000     0 19877  19824
 ffff810014fb9ce8 0000000000000096 ffff8100648e6b18 ffff8100648e63c0
 0000000000000000 ffff8100648e63c0 ffff81006b3963c0 ffff8100648e65d8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ae10c887810>]

make          S ffff810004810000     0 19901  28427
 ffff810008f6fce8 0000000000000096 ffff8100315aa898 ffff8100315aa140
 0000000000000000 ffff8100315aa140 ffff81000da931e0 ffff8100315aa358
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ba35f3e7810>]

sh            S ffff810004e20540     0 19916  19901
 ffff810022bb5e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e9a08 ffff8100055ba140 ffff810003e65320 ffff8100055ba358
 ffffffff80505298 ffffffff80245ea5 0000000000004d00 ffff8100055ba140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b36b65a7d85>]

ccache        S ffff810004e25400     0 19917  19916
 ffff810004dafe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100052e8008 ffff8100315bb1e0 ffff810003e65320 ffff8100315bb3f8
 ffffffff80505298 ffffffff80245ea5 000000000050e550 ffff8100315bb1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002afcbae3fd85>]

hppa-unknown- S ffff810004e21a40     0 19923  19917
 ffff810014cefe98 0000000000000096 0000000200000000 0000000000000002
 ffff810064948008 ffff8100315ab1e0 ffff8100055e8000 ffff8100315ab3f8
 ffffffff80505298 ffffffff80245ea5 00007fff780bd5f0 ffff8100315ab1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ba232b94d85>]

cc1           R  running task        0 19924  19923
as            S ffff810003f763c0     0 19925  19923
 ffff810064b33ce8 0000000000000096 ffff8100648e5a78 ffff8100648e5320
 0000000000000000 ffff8100648e5320 ffff8100648e2140 ffff8100648e5538
 ffffffff803e06e7 0000000000000246 ffff8100039f9018 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ae42ad93810>]

sh            S ffff8100048163c0     0 19958  19599
 ffff81007165fe98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8c688 ffff8100648d0000 ffff81000369b1e0 ffff8100648d0218
 ffffffff80505298 ffffffff80245ea5 0000000000004d00 ffff8100648d0000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002af5f0854d85>]

ccache        S ffff810004811500     0 19959  19958
 ffff81005acc7e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8c008 ffff810003e65320 ffff81001125c280 ffff810003e65538
 ffffffff80505298 ffffffff80245ea5 000000000050e5a0 ffff810003e65320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ad743036d85>]

make          S ffff810004813480     0 19971  13188
 ffff8100052e7ce8 0000000000000096 ffff81001125c9d8 ffff81001125c280
 0000000000000000 ffff81001125c280 ffff8100315bc280 ffff81001125c498
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b3cf2147810>]

hppa-unknown- S ffff810004816900     0 19972  19959
 ffff81007bbd9e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100052e9d48 ffff8100055be3c0 ffff81001125c280 ffff8100055be5d8
 ffffffff80505298 ffffffff80245ea5 00007fff00fc24c0 ffff8100055be3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab9a9c90d85>]

cc1           R  running task        0 19973  19972
as            S ffff810004816e40     0 19975  19972
 ffff8100648dbce8 0000000000000096 ffff8100055b97f8 ffff8100055b90a0
 0000000000000000 ffff8100055b90a0 ffff8100055b63c0 ffff8100055b92b8
 ffffffff803e06e7 0000000000000246 ffff81000c19b5e8 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ae023439810>]

sh            S ffff810004815400     0 19986  19971
 ffff81000512de98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8e088 ffff81000b41b1e0 ffff8100055e90a0 ffff81000b41b3f8
 ffffffff80505298 ffffffff80245ea5 0000000000004e00 ffff81000b41b1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b1ad8825d85>]

ccache        S ffff8100048178c0     0 19987  19986
 ffff81007bba5e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8e708 ffff810003e663c0 ffff8100081a8000 ffff810003e665d8
 ffffffff80505298 ffffffff80245ea5 000000000050e560 ffff810003e663c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b309db45d85>]

make          S ffff810003f778c0     0 19997  13188
 ffff810022bc3ce8 0000000000000096 ffff8100315bc9d8 ffff8100315bc280
 0000000000000000 ffff8100315bc280 ffff8100315be3c0 ffff8100315bc498
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b938a642810>]

sh            S ffff810004e24440     0 20007  19997
 ffff810042f9fe98 0000000000000096 0000000200000000 0000000000000002
 ffff810071586088 ffff8100081ae3c0 ffff810011258000 ffff8100081ae5d8
 ffffffff80505298 ffffffff80245ea5 0000000000004e00 ffff8100081ae3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b90beb05d85>]

ccache        S ffff810004e21f80     0 20008  20007
 ffff810031683e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eba88 ffff81001125d320 ffff8100064bc280 ffff81001125d538
 ffffffff80505298 ffffffff80245ea5 000000000050e570 ffff81001125d320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b18a090bd85>]

sh            S ffff810004e23f00     0 20022  19531
 ffff81000d181e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eaa48 ffff8100648e10a0 ffff8100064bc280 ffff8100648e12b8
 ffffffff80505298 ffffffff80245ea5 0000000000004e00 ffff8100648e10a0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b5f30c3ad85>]

ccache        S ffff810003f70fc0     0 20023  20022
 ffff81000b755e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e9048 ffff8100648d31e0 ffff8100055b63c0 ffff8100648d33f8
 ffffffff80505298 ffffffff80245ea5 000000000050e550 ffff8100648d31e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ad212107d85>]

hppa-unknown- S ffff810004810540     0 20026  20008
 ffff810014cf5e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e8688 ffff8100081ac280 ffff8100064bb1e0 ffff8100081ac498
 ffffffff80505298 ffffffff80245ea5 00007fff0f26b790 ffff8100081ac280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ac49b9e8d85>]

cc1           R  running task        0 20027  20026
as            S ffff810004e24ec0     0 20028  20026
 ffff81003174fce8 0000000000000096 ffff8100112597f8 ffff8100112590a0
 0000000000000000 ffff8100112590a0 ffff8100648e2140 ffff8100112592b8
 ffffffff803e06e7 0000000000000246 ffff81000c198888 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b46f9211810>]

sh            S ffff810004e278c0     0 20030  19225
 ffff81007142de98 0000000000000096 0000000200000000 0000000000000002
 ffff810071585388 ffff81001125b1e0 ffff810003e663c0 ffff81001125b3f8
 ffffffff80505298 ffffffff80245ea5 0000000000004e00 ffff81001125b1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002af696e43d85>]

ccache        S ffff810004e20000     0 20031  20030
 ffff810071663e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ead88 ffff8100081aa140 ffff81001125b1e0 ffff8100081aa358
 ffffffff80505298 ffffffff80245ea5 000000000050e300 ffff8100081aa140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b2b634b6d85>]

hppa-unknown- S ffff810003f75400     0 20032  20031
 ffff810014f13e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ea3c8 ffff8100081a8000 ffff8100315a8000 ffff8100081a8218
 ffffffff80505298 ffffffff80245ea5 00007fff577fad70 ffff8100081a8000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ba853459d85>]

hppa-unknown- S ffff810003f74ec0     0 20033  19987
 ffff81006488fe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e8d08 ffff8100315a8000 ffff8100315ad320 ffff8100315a8218
 ffffffff80505298 ffffffff80245ea5 00007fff577fad10 ffff8100315a8000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ba853459d85>]

cc1           R  running task        0 20034  20033
cc1           R  running task        0 20035  20032
as            S ffff810004e263c0     0 20036  20033
 ffff810042d8fce8 0000000000000096 ffff810003e649d8 ffff810003e64280
 0000000000000000 ffff810003e64280 ffff8100315a8000 ffff810003e64498
 ffffffff803e06e7 0000000000000246 ffff8100039f80f8 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ace4ae24810>]

sh            S ffff8100048124c0     0 20043  19877
 ffff8100056a9e98 0000000000000096 0000000200000000 0000000000000002
 ffff810071584348 ffff81001125e3c0 ffff8100064bb1e0 ffff81001125e5d8
 ffffffff80505298 ffffffff80245ea5 0000000000004e00 ffff81001125e3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b9a4197ad85>]

ccache        S ffff810004e23480     0 20044  20043
 ffff810004cb7e98 0000000000000096 0000000200000000 0000000000000002
 ffff810071585048 ffff8100315b8000 ffff81000b418000 ffff8100315b8218
 ffffffff80505298 ffffffff80245ea5 000000000050e1e0 ffff8100315b8000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b9a24354d85>]

hppa-unknown- S ffff810004e239c0     0 20045  20044
 ffff810058a7de98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e96c8 ffff81000b418000 ffff8100055e8000 ffff81000b418218
 ffffffff80505298 ffffffff80245ea5 00007fffa138d8a0 ffff81000b418000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aac098c6d85>]

cc1           R  running task        0 20046  20045
hppa-unknown- S ffff810003f73480     0 20047  20023
 ffff810022995e98 0000000000000096 0000000200000000 0000000000000002
 ffff810071587408 ffff8100315bd320 ffff81000b41c280 ffff8100315bd538
 ffffffff80505298 ffffffff80245ea5 00007fff4290ee50 ffff8100315bd320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b1868343d85>]

cc1           R  running task        0 20048  20047
as            S ffff810004812a00     0 20049  20047
 ffff81005af81ce8 0000000000000096 ffff81000b41a898 ffff81000b41a140
 0000000000000000 ffff81000b41a140 ffff810011258000 ffff81000b41a358
 ffffffff803e06e7 0000000000000246 ffff8100039f97a8 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ad0a0892810>]

atl1 0000:03:00.0: tx busy
atl1 0000:03:00.0: tx busy
atl1 0000:03:00.0: tx busy
SysRq : Show State
  task                        PC stack   pid father
init          S ffff810003f70540     0     1      0
 ffff8100034899f8 0000000000000096 ffffffff803e28d5 ffffffff805cbfc0
 0000000100312171 ffff810003480000 ffff81000da94280 ffff810003480218
 0000000000000296 0000000000000296 0000000000000400 ffff810003489a08
Call Trace:
 [<ffffffff803dfe5f>] schedule_timeout+0x5f/0xd0
 [<ffffffff8028995d>] do_select+0x44d/0x540
 [<ffffffff80289c55>] core_sys_select+0x205/0x300
 [<ffffffff8028a1f1>] sys_select+0xd1/0x1c0
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007fc61d9a82d3>]

kthreadd      S ffff810004810000     0     2      0
 ffff81000348bf20 0000000000000086 0000000200000000 0000000000000000
 ffff810014d4bdc8 ffff8100034810a0 ffff81000da90000 ffff8100034812b8
 ffffffff804dced8 ffffffff80245ea5 0000000000000000 ffff8100034810a0
Call Trace:
0 ffff8100057ba140 ffff81000369b3f8
<4> ffffffff80505298 ffffffff80245ea5 0000000000006300 ffff81000369b1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd2 ffff8100315b8218
<4> ffffffff803e06e7 0000000000000246 ffff81000c19b9b0 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b62f7d83810>]

hppa-unknown- S ffff810003f6d400     0 25633  25620
 ffff81005af0de98 0000000000000096 0000000200000000 0000000000000002
 ffff81000368a3c8 ffff8100315bd320 ffff8100055ba140 ffff8100315bd538
 ffffffff80505298 ffffffff80245ea5 00007fffcf8aedb0 ffff8100315bd320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b60db3a5d85>]

cc1           R  running task        0 25634  25633
as            S ffff810004e20540     0 25635  25633
 ffff810031775ce8 0000000000000096 ffff8100315bc9d8 ffff8100315bc280
 0000000000000000 ffff8100315bc280 ffff8100315bb1e0 ffff8100315bc498
 ffffffff803e06e7 0000000000000246 ffff81000c198888 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b3ab8180810>]

make          S ffff810003f724c0     0 25655  19824
 ffff810014da5ce8 0000000000000096 ffff8100055b8758 ffff8100055b8000
 0000000000000000 ffff8100055b8000 ffff81006b395320 ffff8100055b8218
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab35c73f810>]

sh            S ffff810003f74440     0 25706  23111
 ffff81000d88fe98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8f408 ffff8100055eb1e0 ffff81001125b1e0 ffff8100055eb3f8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100055eb1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b1181704d85>]

ccache        S ffff810004810a80     0 25707  25706
 ffff810071699e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8e708 ffff8100055e8000 ffff8100648e2140 ffff8100055e8218
 ffffffff80505298 ffffffff80245ea5 000000000050e560 ffff8100055e8000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aec7ed68d85>]

hppa-unknown- S ffff810003f76900     0 25737  25707
 ffff810014c0fe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ea3c8 ffff810003e64280 ffff81006b3931e0 ffff810003e64498
 ffffffff80505298 ffffffff80245ea5 00007fff3db4f080 ffff810003e64280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b5c6d105d85>]

cc1           R  running task        0 25738  25737
as            S ffff8100048124c0     0 25739  25737
 ffff810008e45ce8 0000000000000096 ffff81001125da78 ffff81001125d320
 0000000000000000 ffff81001125d320 ffff81000da94280 ffff81001125d538
 ffffffff803e06e7 0000000000000246 ffff8100038a39b0 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b35dbe47810>]

sh            S ffff810003f70000     0 25746  24624
 ffff81000b46fe98 0000000000000096 0000000200000000 0000000000000002
 ffff810064948d08 ffff81001125b1e0 ffff8100055b63c0 ffff81001125b3f8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff81001125b1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab752ecdd85>]

ccache        S ffff8100048178c0     0 25747  25746
 ffff810071493e98 0000000000000096 0000000200000000 0000000000000002
 ffff81006494a708 ffff8100081aa140 ffff8100057bb1e0 ffff8100081aa358
 ffffffff80505298 ffffffff80245ea5 000000000050e5c0 ffff8100081aa140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ae4dd7c1d85>]

hppa-unknown- S ffff8100048139c0     0 25756  25747
 ffff8100317b3e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e8d08 ffff8100648431e0 ffff810064840000 ffff8100648433f8
 ffffffff80505298 ffffffff80245ea5 00007fffbf635b50 ffff8100648431e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b69eb61ed85>]

cc1           R  running task        0 25757  25756
as            S ffff810004816900     0 25758  25756
 ffff81000b4f1ce8 0000000000000096 ffff810064846b18 ffff8100648463c0
 0000000000000000 ffff8100648463c0 ffff810064840000 ffff8100648465d8
 ffffffff803e06e7 0000000000000246 ffff81000c19a300 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aae54d8e810>]

sh            S ffff810004815400     0 25766  24631
 ffff810014e85e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ea708 ffff8100064bc280 ffff8100315bb1e0 ffff8100064bc498
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100064bc280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b0e8b83ad85>]

ccache        S ffff810004812a00     0 25767  25766
 ffff810042eb5e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ead88 ffff8100064b8000 ffff8100648d63c0 ffff8100064b8218
 ffffffff80505298 ffffffff80245ea5 000000000050e5c0 ffff8100064b8000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b601d5aed85>]

sh            S ffff810004e21f80     0 25782  25560
 ffff810064887e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064948348 ffff8100036231e0 ffff81000b5090a0 ffff8100036233f8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100036231e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b653b219d85>]

ccache        S ffff810004e24440     0 25783  25782
 ffff81000d043e98 0000000000000096 0000000200000000 0000000000000002
 ffff81006494a088 ffff81000b50c280 ffff810003e60000 ffff81000b50c498
 ffffffff80505298 ffffffff80245ea5 000000000050e5c0 ffff81000b50c280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b60f9a4ed85>]

sh            S ffff810004e20000     0 25793  25655
 ffff8100055f5e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100649496c8 ffff8100064be3c0 ffff81001125e3c0 ffff8100064be5d8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100064be3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b35192ded85>]

ccache        S ffff810004e27380     0 25796  25793
 ffff810064bf3e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100649489c8 ffff8100648410a0 ffff81000b50d320 ffff8100648412b8
 ffffffff80505298 ffffffff80245ea5 000000000050e5a0 ffff8100648410a0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aef7f4b1d85>]

sh            S ffff810003f70fc0     0 25802  25292
 ffff81005aeb7e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eaa48 ffff8100057bb1e0 ffff8100055ba140 ffff8100057bb3f8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100057bb1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b732f2cad85>]

ccache        S ffff810004e23480     0 25803  25802
 ffff81000504fe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eb0c8 ffff81000da95320 ffff81000da92140 ffff81000da95538
 ffffffff80505298 ffffffff80245ea5 000000000050e5a0 ffff81000da95320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b4d31bf1d85>]

hppa-unknown- S ffff8100048163c0     0 25806  25783
 ffff81000d5d1e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8c008 ffff8100648d5320 ffff810003e65320 ffff8100648d5538
 ffffffff80505298 ffffffff80245ea5 00007fff82da92c0 ffff8100648d5320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b7e27ea9d85>]

cc1           R  running task        0 25807  25806
as            S ffff810004814980     0 25808  25806
 ffff810008f85ce8 0000000000000096 ffff8100648d3938 ffff8100648d31e0
 0000000000000000 ffff8100648d31e0 ffff8100648d5320 ffff8100648d33f8
 ffffffff803e06e7 0000000000000246 ffff8100038a04c0 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b8cefe70810>]

hppa-unknown- S ffff810004e263c0     0 25809  25767
 ffff810005239e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8c9c8 ffff8100064ba140 ffff810003e60000 ffff8100064ba358
 ffffffff80505298 ffffffff80245ea5 00007fffa2797cb0 ffff8100064ba140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab5084bad85>]

cc1           R  running task        0 25810  25809
as            S ffff810004e278c0     0 25811  25809
 ffff810022a7dce8 0000000000000096 ffff81000b5097f8 ffff81000b5090a0
 0000000000000000 ffff81000b5090a0 ffff8100064ba140 ffff81000b5092b8
 ffffffff803e06e7 0000000000000246 ffff8100038a17a8 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b9da77c8810>]

hppa-unknown- S ffff810003f75e80     0 25812  25803
 ffff81000d723e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e9a08 ffff81000da92140 ffff81000da94280 ffff81000da92358
 ffffffff80505298 ffffffff80245ea5 00007fffbcce21d0 ffff81000da92140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b2eedf70d85>]

cc1           R  running task        0 25813  25812
as            S ffff810004e20fc0     0 25814  25812
 ffff81000d481ce8 0000000000000096 ffff81000da917f8 ffff81000da910a0
 0000000000000000 ffff81000da910a0 ffff810003e60000 ffff81000da912b8
 ffffffff803e06e7 0000000000000246 ffff81000c198c50 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b8ffb68a810>]

hppa-unknown- S ffff810004e21500     0 25815  25796
 ffff810008dcfe98 0000000000000096 0000000200000000 0000000000000002
 ffff81006494b408 ffff81000b50d320 ffff810003e60000 ffff81000b50d538
 ffffffff80505298 ffffffff80245ea5 00007fffaa0c45d0 ffff81000b50d320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ba800b8dd85>]

cc1           R  running task        0 25816  25815
as            S ffff810003f73480     0 25817  25815
 ffff810004f67ce8 0000000000000096 ffff810003e66b18 ffff810003e663c0
 0000000000000000 ffff810003e663c0 ffff810064840000 ffff810003e665d8
 ffffffff803e06e7 0000000000000246 ffff8100038a2a90 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b304ff0a810>]

sh            S ffff810003f71a40     0 25824  25292
 ffff810022a57e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eba88 ffff8100057be3c0 ffff8100057bc280 ffff8100057be5d8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100057be3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b3937c64d85>]

ccache        S ffff810003f75940     0 25825  25824
 ffff810031769e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eb748 ffff8100057bc280 ffff81000da94280 ffff8100057bc498
 ffffffff80505298 ffffffff80245ea5 000000000050e280 ffff8100057bc280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b118a7f6d85>]

hppa-unknown- S ffff810004810540     0 25826  25825
 ffff81000d849e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8d388 ffff8100081ae3c0 ffff8100055b63c0 ffff8100081ae5d8
 ffffffff80505298 ffffffff80245ea5 00007fff162d17e0 ffff8100081ae3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b2594980d85>]

cc1           D ffff810004812f40     0 25827  25826
 ffff81000d6d9c18 0000000000000092 ffff810003e65320 ffffffff80249945
 0000000200000001 ffff810003e65320 ffff8100081ae3c0 ffff810003e65538
 ffff810002c1b6e8 0000000000000046 ffff810003e801f0 ffff81000d6d9ca8
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff80255525>] sync_page+0x45/0x60
 [<ffffffff803dff5a>] __wait_on_bit_lock+0x4a/0x80
 [<ffffffff802554bf>] __lock_page+0x5f/0x70
 [<ffffffff80255dec>] do_generic_mapping_read+0x21c/0x410
 [<ffffffff8025787c>] generic_file_aio_read+0xdc/0x190
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ac7bfd58810>]

atl1 0000:03:00.0: tx busy
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002af937289810>]

make          S ffff810003f6b480     0  7879   2541
 ffff810058835e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100036896c8 ffff81001125a140 ffff8100648d10a0 ffff81001125a358
 ffffffff80505298 ffffffff80245ea5 0000000000000001 ffff81001125a140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f92918f1ce4>]

sh            S ffff810004e25940     0  7887   7879
 ffff810042ec5e98 0000000000000096 0000000200000000 0000000000000002
 ffff810071586d88 ffff8100648d10a0 ffff81006b3931e0 ffff8100648d12b8
 ffffffff80505298 ffffffff80245ea5 0000000000001e00 ffff8100648d10a0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aafe8c7ed85>]

expect        S ffff810004817380     0  7891   7887
 ffff81007ba119f8 0000000000000096 ffffffff803e28d5 ffffffff805cbfc0
 000000010031c27b ffff8100315b90a0 ffff8100055bd320 ffff8100315b92b8
 0000000000000296 0000000000000296 0000000000000040 ffff81007ba11a08
Call Trace:
 [<ffffffff803dfe5f>] schedule_timeout+0x5f/0xd0
 [<ffffffff8028995d>] do_select+0x44d/0x540
 [<ffffffff80289c55>] core_sys_select+0x205/0x300
 [<ffffffff8028a1f1>] sys_select+0xd1/0x1c0
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b430d3852d3>]

gdb           S ffff810003f6d940     0 10505   7891
 ffff810022ac3f28 0000000000000096 0000000200000001 0000000000000000
 0000000003e60000 ffff8100648d4280 ffff810003e60000 ffff8100648d4498
 ffff81000b5c0808 ffffffff80245ea5 00000000ffffffff ffff8100648d4280
Call Trace:
 [<ffffffff80233b11>] sys_rt_sigsuspend+0xc1/0xf0
 [<ffffffff8020be97>] ptregscall_common+0x67/0xb0
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b1998eb7b4a>]

bigcore       R  running task        0 10516  10505
pdflush       S ffff810003f77380     0   848      2
 ffff810014d4bee0 0000000000000086 0000000200000001 0000000000000000
 0000000000000000 ffff81000da90000 ffff81000da94280 ffff81000da90218
 ffffffff804e6440 ffffffff80245ea5 0000000000000000 ffff81000da90000
Call Trace:
 [<ffffffff8025cc1f>] pdflush+0xbf/0x1d0
 [<ffffffff8023b9fb>] kthread+0x4b/0x80
 [<ffffffff8020c9d8>] child_rip+0xa/0x12

make          S ffff810003f6c440     0  6636  28427
 ffff81000b45fe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e9d48 ffff8100081ab1e0 ffff81006b395320 ffff8100081ab3f8
 ffffffff80505298 ffffffff80245ea5 0000000000000001 ffff8100081ab1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b187a333ce4>]

make          S ffff810003f71f80     0  9992   6636
 ffff81005ae4fce8 0000000000000096 ffff8100648d2898 ffff8100648d2140
 0000000000000000 ffff8100648d2140 ffff8100034b63c0 ffff8100648d2358
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002adfca7d7810>]

make          S ffff810003f68000     0 13188  28427
 ffff81000da81ce8 0000000000000096 ffff81006b395a78 ffff81006b395320
 0000000000000000 ffff81006b395320 ffff8100315be3c0 ffff81006b395538
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b01fee9f810>]

ftest01       S ffff810004814ec0     0 16712   2004
 ffff8100054dfe98 0000000000000096 0000000200000000 0000000000000002
 ffff81006494ba88 ffff810003540000 ffff81000d012140 ffff810003540218
 ffffffff80505298 ffffffff80245ea5 00007fff22ee27a0 ffff810003540000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac1cce4>]

ftest01       D ffff810003f73f00     0 16714  16712
 ffff81000b6e3d48 0000000000000092 ffff8100315ba140 ffffffff80249945
 0000000200000001 ffff8100315ba140 ffff81000b50a140 ffff8100315ba358
 ffff8100315ba898 ffff8100315ba140 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff80255525>] sync_page+0x45/0x60
 [<ffffffff803e007f>] __wait_on_bit+0x4f/0x80
 [<ffffffff8025581c>] wait_on_page_bit+0x6c/0x80
 [<ffffffff8025617e>] wait_on_page_writeback_range+0xbe/0x140
 [<ffffffff80256564>] filemap_write_and_wait+0x44/0x50
 [<ffffffff8029badd>] __sync_inodes+0xbd/0x100
 [<ffffffff8029bb3e>] sync_inodes+0x1e/0x50
 [<ffffffff8029f022>] do_sync+0x12/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

ftest01       D ffff810003f72a00     0 16715  16712
 ffff810014e29bb8 0000000000000092 ffff81000b50a140 ffffffff80249945
 0000000200000001 ffff81000b50a140 ffff81000da94280 ffff81000b50a358
 ffff81000b50a898 ffff81000b50a140 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff80255525>] sync_page+0x45/0x60
 [<ffffffff803e007f>] __wait_on_bit+0x4f/0x80
 [<ffffffff8025581c>] wait_on_page_bit+0x6c/0x80
 [<ffffffff8025c04d>] write_cache_pages+0x2bd/0x370
 [<ffffffff802a7f87>] mpage_writepages+0x37/0x70
 [<ffffffff8025c153>] do_writepages+0x23/0x40
 [<ffffffff8029b079>] __writeback_single_inode+0xa9/0x350
 [<ffffffff8029b7a7>] generic_sync_sb_inodes+0x227/0x3d0
 [<ffffffff8029ba0b>] sync_inodes_sb+0x9b/0xb0
 [<ffffffff8029baca>] __sync_inodes+0xaa/0x100
 [<ffffffff8029bb3e>] sync_inodes+0x1e/0x50
 [<ffffffff8029f03c>] do_sync+0x2c/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

ftest01       D ffff810003f70a80     0 16716  16712
 ffff8100317f7d48 0000000000000092 ffff81000b50b1e0 ffffffff80249945
 0000000200000001 ffff81000b50b1e0 ffff8100036763c0 ffff81000b50b3f8
 ffff81000b50b938 ffff81000b50b1e0 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff80255525>] sync_page+0x45/0x60
 [<ffffffff803e007f>] __wait_on_bit+0x4f/0x80
 [<ffffffff8025581c>] wait_on_page_bit+0x6c/0x80
 [<ffffffff8025617e>] wait_on_page_writeback_range+0xbe/0x140
 [<ffffffff80256564>] filemap_write_and_wait+0x44/0x50
 [<ffffffff8029badd>] __sync_inodes+0xbd/0x100
 [<ffffffff8029bb3e>] sync_inodes+0x1e/0x50
 [<ffffffff8029f022>] do_sync+0x12/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

ftest01       D ffff810003f739c0     0 16717  16712
 ffff8100050f5d58 0000000000000096 ffff81000b50eb18 ffff81000b50e3c0
 0000000000000000 ffff81000b50e3c0 ffff81006b3963c0 ffff81000b50e5d8
 0000000000000002 ffff81000b50e3c0 ffffffff803e28d5 ffff8100050f5d68
Call Trace:
 [<ffffffff802d1155>] log_wait_commit+0xc5/0x140
 [<ffffffff802cbc8e>] journal_stop+0x12e/0x210
 [<ffffffff8029b279>] __writeback_single_inode+0x2a9/0x350
 [<ffffffff8029b34b>] sync_inode+0x2b/0x50
 [<ffffffff802bd0f3>] ext3_sync_file+0xa3/0xb0
 [<ffffffff8029eeb9>] do_fsync+0x69/0xe0
 [<ffffffff8029ef5e>] __do_fsync+0x2e/0x50
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac445d0>]

ftest01       D ffff810003f71500     0 16718  16712
 ffff81000d87fc18 0000000000000092 ffff81006b3963c0 ffffffff80249945
 0000000200000001 ffff81006b3963c0 ffff8100036763c0 ffff81006b3965d8
 ffff81006b396b18 ffff81006b3963c0 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff80255525>] sync_page+0x45/0x60
 [<ffffffff803e007f>] __wait_on_bit+0x4f/0x80
 [<ffffffff8025581c>] wait_on_page_bit+0x6c/0x80
 [<ffffffff8025617e>] wait_on_page_writeback_range+0xbe/0x140
 [<ffffffff8029b163>] __writeback_single_inode+0x193/0x350
 [<ffffffff8029b7a7>] generic_sync_sb_inodes+0x227/0x3d0
 [<ffffffff8029ba0b>] sync_inodes_sb+0x9b/0xb0
 [<ffffffff8029baca>] __sync_inodes+0xaa/0x100
 [<ffffffff8029bb55>] sync_inodes+0x35/0x50
 [<ffffffff8029f03c>] do_sync+0x2c/0x60
 [<ffffffff8029f07e>] sys_sync+0xe/0x20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f331ac44637>]

pdflush       S ffff810003f6f380     0 16988      2
 ffff8100716e9ee0 0000000000000086 0000000200000001 0000000000000000
 0000000000000000 ffff810003622140 ffff8100315bb1e0 ffff810003622358
 ffffffff804e6440 ffffffff80245ea5 0000000000000000 ffff810003622140
Call Trace:
 [<ffffffff8025cc1f>] pdflush+0xbf/0x1d0
 [<ffffffff8023b9fb>] kthread+0x4b/0x80
 [<ffffffff8020c9d8>] child_rip+0xa/0x12

make          S ffff810004811f80     0 19824  28427
 ffff810005115ce8 0000000000000096 ffff8100648e3938 ffff8100648e31e0
 0000000000000000 ffff8100648e31e0 ffff81000b508000 ffff8100648e33f8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002afcad0bb810>]

bash          S ffff810003f69a40     0 20321      1
 ffff81000b727e98 0000000000000096 0000000200000000 0000000000000002
 ffff810071585a08 ffff81000369b1e0 ffff8100057ba140 ffff81000369b3f8
 ffffffff80505298 ffffffff80245ea5 0000000000006300 ffff81000369b1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00007f0f60f89d85>]

make          S ffff810003f778c0     0 23111  13188
 ffff810014e01ce8 0000000000000096 ffff8100315beb18 ffff8100315be3c0
 0000000000000000 ffff8100315be3c0 ffff8100055bb1e0 ffff8100315be5d8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b536ef9b810>]

make          S ffff810004e22a00     0 23826  28427
 ffff81007b849ce8 0000000000000096 ffff8100055bb938 ffff8100055bb1e0
 0000000000000000 ffff8100055bb1e0 ffff8100648e31e0 ffff8100055bb3f8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b9442ce9810>]

make          S ffff810004e21a40     0 24624  23826
 ffff81006494de98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eb408 ffff8100055b0000 ffff8100055b8000 ffff8100055b0218
 ffffffff80505298 ffffffff80245ea5 0000000000000001 ffff8100055b0000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002afabdc44ce4>]

make          S ffff810004e25400     0 24631  23826
 ffff81007b95dce8 0000000000000096 ffff8100034b6b18 ffff8100034b63c0
 0000000000000000 ffff8100034b63c0 ffff8100648e0000 ffff8100034b65d8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ae5de0d3810>]

make          S ffff810004810000     0 25292   9992
 ffff810042e9dce8 0000000000000096 ffff81000369eb18 ffff81000369e3c0
 0000000000000000 ffff81000369e3c0 ffff8100057be3c0 ffff81000369e5d8
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002abe74671810>]

bash          R  running task        0 25400  20321
make          S ffff810004e224c0     0 25496   9992
 ffff810058aa3ce8 0000000000000096 ffff8100648e0758 ffff8100648e0000
 0000000000000000 ffff8100648e0000 ffff810064842140 ffff8100648e0218
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002add48b7a810>]

make          S ffff810004811500     0 25560  23826
 ffff810058bb9ce8 0000000000000096 ffff8100057b8758 ffff8100057b8000
 0000000000000000 ffff8100057b8000 ffff8100055b63c0 ffff8100057b8218
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002abceecc3810>]

sh            S ffff810004e22f40     0 25561  25496
 ffff81005aeabe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ea088 ffff8100055be3c0 ffff8100055b90a0 ffff8100055be5d8
 ffffffff80505298 ffffffff80245ea5 0000000000006300 ffff8100055be3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b7ed7312d85>]

ccache        S ffff810004e23f00     0 25564  25561
 ffff81000d0cfe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e8008 ffff8100055bd320 ffff81000da94280 ffff8100055bd538
 ffffffff80505298 ffffffff80245ea5 000000000050e5d0 ffff8100055bd320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b2198a4ed85>]

make          S ffff810004814440     0 25583  28427
 ffff8100052cbce8 0000000000000096 ffff810064842898 ffff810064842140
 0000000000000000 ffff810064842140 ffff81000369e3c0 ffff810064842358
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b35978a4810>]

sh            S ffff810003f68a80     0 25614  25583
 ffff81000512de98 0000000000000096 0000000200000000 0000000000000002
 ffff8100715870c8 ffff8100081ad320 ffff8100064bc280 ffff8100081ad538
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100081ad320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ad22d562d85>]

ccache        S ffff810003f6bf00     0 25620  25614
 ffff81000d27fe98 0000000000000096 0000000200000000 0000000000000002
 ffff810071587a88 ffff8100112590a0 ffff8100315bb1e0 ffff8100112592b8
 ffffffff80505298 ffffffff80245ea5 000000000050e5a0 ffff8100112590a0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b9dc0a17d85>]

hppa-unknown- S ffff810003f6c980     0 25624  25564
 ffff81000d38de98 0000000000000096 0000000200000000 0000000000000002
 ffff810003688688 ffff8100064bb1e0 ffff8100055ba140 ffff8100064bb3f8
 ffffffff80505298 ffffffff80245ea5 00007fff1cc599c0 ffff8100064bb1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b3c8dff8d85>]

cc1           R  running task        0 25625  25624
as            S ffff810003f6e3c0     0 25629  25624
 ffff810004d9bce8 0000000000000096 ffff8100315b8758 ffff8100315b8000
 0000000000000000 ffff8100315b8000 ffff8100055ba140 ffff8100315b8218
 ffffffff803e06e7 0000000000000246 ffff81000c19b9b0 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b62f7d83810>]

hppa-unknown- S ffff810003f6d400     0 25633  25620
 ffff81005af0de98 0000000000000096 0000000200000000 0000000000000002
 ffff81000368a3c8 ffff8100315bd320 ffff8100055ba140 ffff8100315bd538
 ffffffff80505298 ffffffff80245ea5 00007fffcf8aedb0 ffff8100315bd320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b60db3a5d85>]

cc1           R  running task        0 25634  25633
as            S ffff810004e20540     0 25635  25633
 ffff810031775ce8 0000000000000096 ffff8100315bc9d8 ffff8100315bc280
 0000000000000000 ffff8100315bc280 ffff8100315bb1e0 ffff8100315bc498
 ffffffff803e06e7 0000000000000246 ffff81000c198888 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b3ab8180810>]

make          S ffff810003f724c0     0 25655  19824
 ffff810014da5ce8 0000000000000096 ffff8100055b8758 ffff8100055b8000
 0000000000000000 ffff8100055b8000 ffff81006b395320 ffff8100055b8218
 ffffffff803e06e7 0000000000000246 ffff8100038a3220 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab35c73f810>]

sh            S ffff810003f74440     0 25706  23111
 ffff81000d88fe98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8f408 ffff8100055eb1e0 ffff81001125b1e0 ffff8100055eb3f8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100055eb1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b1181704d85>]

ccache        S ffff810004810a80     0 25707  25706
 ffff810071699e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8e708 ffff8100055e8000 ffff8100648e2140 ffff8100055e8218
 ffffffff80505298 ffffffff80245ea5 000000000050e560 ffff8100055e8000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aec7ed68d85>]

hppa-unknown- S ffff810003f76900     0 25737  25707
 ffff810014c0fe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ea3c8 ffff810003e64280 ffff81006b3931e0 ffff810003e64498
 ffffffff80505298 ffffffff80245ea5 00007fff3db4f080 ffff810003e64280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b5c6d105d85>]

cc1           R  running task        0 25738  25737
as            S ffff8100048124c0     0 25739  25737
 ffff810008e45ce8 0000000000000096 ffff81001125da78 ffff81001125d320
 0000000000000000 ffff81001125d320 ffff81000da94280 ffff81001125d538
 ffffffff803e06e7 0000000000000246 ffff8100038a39b0 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b35dbe47810>]

sh            S ffff810003f70000     0 25746  24624
 ffff81000b46fe98 0000000000000096 0000000200000000 0000000000000002
 ffff810064948d08 ffff81001125b1e0 ffff8100055b63c0 ffff81001125b3f8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff81001125b1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab752ecdd85>]

ccache        S ffff8100048178c0     0 25747  25746
 ffff810071493e98 0000000000000096 0000000200000000 0000000000000002
 ffff81006494a708 ffff8100081aa140 ffff8100057bb1e0 ffff8100081aa358
 ffffffff80505298 ffffffff80245ea5 000000000050e5c0 ffff8100081aa140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ae4dd7c1d85>]

hppa-unknown- S ffff8100048139c0     0 25756  25747
 ffff8100317b3e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e8d08 ffff8100648431e0 ffff810064840000 ffff8100648433f8
 ffffffff80505298 ffffffff80245ea5 00007fffbf635b50 ffff8100648431e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b69eb61ed85>]

cc1           R  running task        0 25757  25756
as            S ffff810004816900     0 25758  25756
 ffff81000b4f1ce8 0000000000000096 ffff810064846b18 ffff8100648463c0
 0000000000000000 ffff8100648463c0 ffff810064840000 ffff8100648465d8
 ffffffff803e06e7 0000000000000246 ffff81000c19a300 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aae54d8e810>]

sh            S ffff810004815400     0 25766  24631
 ffff810014e85e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ea708 ffff8100064bc280 ffff8100315bb1e0 ffff8100064bc498
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100064bc280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b0e8b83ad85>]

ccache        S ffff810004812a00     0 25767  25766
 ffff810042eb5e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043ead88 ffff8100064b8000 ffff8100648d63c0 ffff8100064b8218
 ffffffff80505298 ffffffff80245ea5 000000000050e5c0 ffff8100064b8000
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b601d5aed85>]

sh            S ffff810004e21f80     0 25782  25560
 ffff810064887e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064948348 ffff8100036231e0 ffff81000b5090a0 ffff8100036233f8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100036231e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b653b219d85>]

ccache        S ffff810004e24440     0 25783  25782
 ffff81000d043e98 0000000000000096 0000000200000000 0000000000000002
 ffff81006494a088 ffff81000b50c280 ffff810003e60000 ffff81000b50c498
 ffffffff80505298 ffffffff80245ea5 000000000050e5c0 ffff81000b50c280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b60f9a4ed85>]

sh            S ffff810004e20000     0 25793  25655
 ffff8100055f5e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100649496c8 ffff8100064be3c0 ffff81001125e3c0 ffff8100064be5d8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100064be3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b35192ded85>]

ccache        S ffff810004e27380     0 25796  25793
 ffff810064bf3e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100649489c8 ffff8100648410a0 ffff81000b50d320 ffff8100648412b8
 ffffffff80505298 ffffffff80245ea5 000000000050e5a0 ffff8100648410a0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002aef7f4b1d85>]

sh            S ffff810003f70fc0     0 25802  25292
 ffff81005aeb7e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eaa48 ffff8100057bb1e0 ffff8100055ba140 ffff8100057bb3f8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100057bb1e0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b732f2cad85>]

ccache        S ffff810004e23480     0 25803  25802
 ffff81000504fe98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eb0c8 ffff81000da95320 ffff81000da92140 ffff81000da95538
 ffffffff80505298 ffffffff80245ea5 000000000050e5a0 ffff81000da95320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b4d31bf1d85>]

hppa-unknown- S ffff8100048163c0     0 25806  25783
 ffff81000d5d1e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8c008 ffff8100648d5320 ffff810003e65320 ffff8100648d5538
 ffffffff80505298 ffffffff80245ea5 00007fff82da92c0 ffff8100648d5320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b7e27ea9d85>]

cc1           R  running task        0 25807  25806
as            S ffff810004814980     0 25808  25806
 ffff810008f85ce8 0000000000000096 ffff8100648d3938 ffff8100648d31e0
 0000000000000000 ffff8100648d31e0 ffff8100648d5320 ffff8100648d33f8
 ffffffff803e06e7 0000000000000246 ffff8100038a04c0 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b8cefe70810>]

hppa-unknown- S ffff810004e263c0     0 25809  25767
 ffff810005239e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8c9c8 ffff8100064ba140 ffff810003e60000 ffff8100064ba358
 ffffffff80505298 ffffffff80245ea5 00007fffa2797cb0 ffff8100064ba140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ab5084bad85>]

cc1           R  running task        0 25810  25809
as            S ffff810004e278c0     0 25811  25809
 ffff810022a7dce8 0000000000000096 ffff81000b5097f8 ffff81000b5090a0
 0000000000000000 ffff81000b5090a0 ffff8100064ba140 ffff81000b5092b8
 ffffffff803e06e7 0000000000000246 ffff8100038a17a8 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b9da77c8810>]

hppa-unknown- S ffff810003f75e80     0 25812  25803
 ffff81000d723e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043e9a08 ffff81000da92140 ffff81000da94280 ffff81000da92358
 ffffffff80505298 ffffffff80245ea5 00007fffbcce21d0 ffff81000da92140
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b2eedf70d85>]

cc1           R  running task        0 25813  25812
as            S ffff810004e20fc0     0 25814  25812
 ffff81000d481ce8 0000000000000096 ffff81000da917f8 ffff81000da910a0
 0000000000000000 ffff81000da910a0 ffff810003e60000 ffff81000da912b8
 ffffffff803e06e7 0000000000000246 ffff81000c198c50 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b8ffb68a810>]

hppa-unknown- S ffff810004e21500     0 25815  25796
 ffff810008dcfe98 0000000000000096 0000000200000000 0000000000000002
 ffff81006494b408 ffff81000b50d320 ffff810003e60000 ffff81000b50d538
 ffffffff80505298 ffffffff80245ea5 00007fffaa0c45d0 ffff81000b50d320
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ba800b8dd85>]

cc1           R  running task        0 25816  25815
as            S ffff810003f73480     0 25817  25815
 ffff810004f67ce8 0000000000000096 ffff810003e66b18 ffff810003e663c0
 0000000000000000 ffff810003e663c0 ffff810064840000 ffff810003e665d8
 ffffffff803e06e7 0000000000000246 ffff8100038a2a90 ffffffff80248ad1
Call Trace:
 [<ffffffff80282655>] pipe_wait+0x85/0xb0
 [<ffffffff80282cb9>] pipe_read+0xe9/0x430
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b304ff0a810>]

sh            S ffff810003f71a40     0 25824  25292
 ffff810022a57e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eba88 ffff8100057be3c0 ffff8100057bc280 ffff8100057be5d8
 ffffffff80505298 ffffffff80245ea5 0000000000006400 ffff8100057be3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b3937c64d85>]

ccache        S ffff810003f75940     0 25825  25824
 ffff810031769e98 0000000000000096 0000000200000000 0000000000000002
 ffff8100043eb748 ffff8100057bc280 ffff81000da94280 ffff8100057bc498
 ffffffff80505298 ffffffff80245ea5 000000000050e280 ffff8100057bc280
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b118a7f6d85>]

hppa-unknown- S ffff810004810540     0 25826  25825
 ffff81000d849e98 0000000000000096 0000000200000000 0000000000000002
 ffff810064a8d388 ffff8100081ae3c0 ffff8100055b63c0 ffff8100081ae5d8
 ffffffff80505298 ffffffff80245ea5 00007fff162d17e0 ffff8100081ae3c0
Call Trace:
 [<ffffffff802299f5>] do_wait+0x505/0xd20
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002b2594980d85>]

cc1           D ffff810004812f40     0 25827  25826
 ffff81000d6d9c18 0000000000000092 ffff810003e65320 ffffffff80249945
 0000000200000001 ffff810003e65320 ffff8100081ae3c0 ffff810003e65538
 ffff810002c1b6e8 0000000000000046 ffff810003e801f0 ffff81000d6d9ca8
Call Trace:
 [<ffffffff803df858>] io_schedule+0x28/0x40
 [<ffffffff80255525>] sync_page+0x45/0x60
 [<ffffffff803dff5a>] __wait_on_bit_lock+0x4a/0x80
 [<ffffffff802554bf>] __lock_page+0x5f/0x70
 [<ffffffff80255dec>] do_generic_mapping_read+0x21c/0x410
 [<ffffffff8025787c>] generic_file_aio_read+0xdc/0x190
 [<ffffffff8027baa9>] do_sync_read+0xd9/0x120
 [<ffffffff8027c26a>] vfs_read+0xaa/0xe0
 [<ffffffff8027c6e3>] sys_read+0x53/0x90
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002ac7bfd58810>]

atl1 0000:03:00.0: tx busy
atl1 0000:03:00.0: tx busy
atl1 0000:03:00.0: tx busy
atl1 0000:03:00.0: tx busy
atl1 0000:03:00.0: tx busy


		[unknown amount of time passes]


Unable to handle kernel NULL pointer dereference at 0000000000000039 RIP: 
 [<ffffffff803b6f7c>] tcp_rto_min+0xc/0x20
PGD d0b5067 PUD 14f68067 PMD 0 
Oops: 0000 [1] SMP 
last sysfs file: /kernel/uevent_seqnum
CPU 1 
Pid: 12133, comm: gdbserver Not tainted 2.6.23-rc4-mm1 #1
RIP: 0010:[<ffffffff803b6f7c>]  [<ffffffff803b6f7c>] tcp_rto_min+0xc/0x20
RSP: 0000:ffff8100034bbc98  EFLAGS: 00010246
RAX: 0000000000000014 RBX: ffff8100054faa80 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8100054faa80
RBP: ffff8100054faa80 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000001 R11: 00000000003246d4 R12: ffffffff80503b20
R13: ffff810005427238 R14: 0000000000000086 R15: 000000000000000c
FS:  00002af8ce942cc0(0000) GS:ffff810003418258(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000039 CR3: 000000000d2a3000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff4ff1 DR7: 00000000000d0500
Process gdbserver (pid: 12133, threadinfo ffff81000d1bc000, task ffff8100648d5320)
Stack:  ffffffff803b702f ffff8100054faa80 ffff8100054faa80 ffffffff803b7aa6
 0000000000000001 ffffffff803b96a5 ffff8100054fac30 0000000000000000
 000000018024890d ffff810021084599 0000000100000000 ffffffff00000001
Call Trace:
 [<ffffffff803b702f>] tcp_rtt_estimator+0x9f/0x140
 [<ffffffff803b7aa6>] tcp_ack_saw_tstamp+0x16/0x50
 [<ffffffff803b96a5>] tcp_ack+0x6f5/0x1dd0
 [<ffffffff803be105>] tcp_rcv_established+0x485/0x7b0
 [<ffffffff803c4725>] tcp_v4_do_rcv+0xf5/0x3c0
 [<ffffffff803c6e80>] tcp_v4_rcv+0x860/0x870
 [<ffffffff803a897a>] ip_local_deliver+0x8a/0x170
 [<ffffffff803a8d68>] ip_rcv+0x308/0x570
 [<ffffffff8039257c>] process_backlog+0x7c/0xe0
 [<ffffffff803921cf>] net_rx_action+0xdf/0x1a0
 [<ffffffff8022c873>] __do_softirq+0x73/0xf0
 [<ffffffff8020cd4c>] call_softirq+0x1c/0x30
 [<ffffffff8020f175>] do_softirq+0x55/0xb0
 [<ffffffff8022c5b5>] local_bh_enable+0xc5/0x160
 [<ffffffff803b34f3>] tcp_prequeue_process+0x73/0x90
 [<ffffffff803b5b87>] tcp_recvmsg+0x487/0x910
 [<ffffffff80385570>] sock_common_recvmsg+0x30/0x50
 [<ffffffff80383ba5>] sock_recvmsg+0xd5/0x100
 [<ffffffff80384ade>] sys_recvfrom+0xfe/0x1a0
 [<ffffffff8020bb4e>] system_call+0x7e/0x83
 [<00002af8ce7c5d05>]

INFO: lockdep is turned off.

Code: f6 42 39 20 74 03 8b 42 68 f3 c3 66 66 90 66 66 90 66 66 90 
RIP  [<ffffffff803b6f7c>] tcp_rto_min+0xc/0x20
 RSP <ffff8100034bbc98>
CR2: 0000000000000039
Kernel panic - not syncing: Fatal exception



-------------------------------------------------------------------
#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.23-rc4-mm1
# Sat Sep  1 10:50:59 2007
#
CONFIG_X86_64=y
CONFIG_64BIT=y
CONFIG_X86=y
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_NONIRQ_WAKEUP=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_ZONE_DMA32=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_SEMAPHORE_SLEEPERS=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_QUICKLIST=y
CONFIG_NR_QUICK=2
CONFIG_RWSEM_GENERIC_SPINLOCK=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_X86_CMPXCHG=y
CONFIG_EARLY_PRINTK=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_DMI=y
CONFIG_AUDIT_ARCH=y
CONFIG_GENERIC_BUG=y
# CONFIG_ARCH_HAS_ILOG2_U32 is not set
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
# CONFIG_USER_NS is not set
# CONFIG_AUDIT is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=15
# CONFIG_CONTAINERS is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
# CONFIG_BLK_DEV_INITRD is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_EMBEDDED=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
# CONFIG_SIGNALFD is not set
# CONFIG_TIMERFD is not set
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_SLUB_DEBUG=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_PROC_PAGE_MONITOR is not set
# CONFIG_PROC_KPAGEMAP is not set
CONFIG_RT_MUTEXES=y
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_BLOCK=y
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_BLK_DEV_BSG is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_AS is not set
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_X86_PC=y
# CONFIG_X86_VSMP is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_TSC=y
CONFIG_X86_GOOD_APIC=y
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_X86_HT=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_MTRR=y
CONFIG_SMP=y
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
# CONFIG_PREEMPT_BKL is not set
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_DISCONTIGMEM_MANUAL is not set
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_RESOURCES_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_NR_CPUS=2
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_HOTPLUG_CPU is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_HPET_TIMER=y
# CONFIG_HPET_EMULATE_RTC is not set
# CONFIG_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_START=0x200000
# CONFIG_SECCOMP is not set
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_ISA_DMA_API=y
CONFIG_GENERIC_PENDING_IRQ=y

#
# Power management options
#
CONFIG_PM=y
# CONFIG_PM_LEGACY is not set
# CONFIG_PM_DEBUG is not set
CONFIG_SUSPEND_SMP_POSSIBLE=y
# CONFIG_SUSPEND is not set
CONFIG_HIBERNATION_SMP_POSSIBLE=y
# CONFIG_HIBERNATION is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROC_EVENT is not set
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
# CONFIG_ACPI_BUTTON is not set
# CONFIG_ACPI_FAN is not set
# CONFIG_ACPI_DOCK is not set
# CONFIG_ACPI_PROCESSOR is not set
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_SYSTEM=y
# CONFIG_X86_PM_TIMER is not set
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU idle PM support
#
# CONFIG_CPU_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
# CONFIG_DMAR is not set
# CONFIG_PCIEPORTBUS is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_HT_IRQ is not set
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
# CONFIG_BINFMT_MISC is not set
# CONFIG_IA32_EMULATION is not set
# CONFIG_COMPAT_FOR_U64_ALIGNMENT is not set

#
# Networking
#
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set

#
# QoS and/or fair queueing
#
# CONFIG_NET_SCHED is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set

#
# Wireless
#
# CONFIG_CFG80211 is not set
# CONFIG_WIRELESS_EXT is not set
# CONFIG_MAC80211 is not set
# CONFIG_IEEE80211 is not set
# CONFIG_RFKILL is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
# CONFIG_FW_LOADER is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
CONFIG_PNPACPI=y
# CONFIG_BLK_DEV is not set
# CONFIG_MISC_DEVICES is not set
# CONFIG_IDE is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
CONFIG_SATA_AHCI=y
# CONFIG_SATA_SVW is not set
CONFIG_ATA_PIIX=y
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
CONFIG_PATA_JMICRON=y
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_MD is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
# CONFIG_NETDEVICES_MULTIQUEUE is not set
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_NET_ETHERNET is not set
CONFIG_MII=y
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set
CONFIG_ATL1=y
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_SHAPER is not set
CONFIG_NETCONSOLE=y
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_TSDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
# CONFIG_SERIAL_8250 is not set
CONFIG_FIX_EARLYCON_MEM=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
CONFIG_RTC=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_AGP is not set
# CONFIG_DRM is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_I2C is not set

#
# SPI support
#
# CONFIG_SPI is not set
# CONFIG_SPI_MASTER is not set
# CONFIG_W1 is not set
# CONFIG_POWER_SUPPLY is not set
# CONFIG_HWMON is not set
# CONFIG_WATCHDOG is not set

#
# Sonics Silicon Backplane
#
CONFIG_SSB_POSSIBLE=y
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_SM501 is not set

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set
# CONFIG_DVB_CORE is not set
# CONFIG_DAB is not set

#
# Graphics support
#
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
# CONFIG_VIDEO_SELECT is not set
CONFIG_DUMMY_CONSOLE=y

#
# Sound
#
# CONFIG_SOUND is not set
# CONFIG_HID_SUPPORT is not set
# CONFIG_USB_SUPPORT is not set
# CONFIG_MMC is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set
# CONFIG_VIRTUALIZATION is not set

#
# Userspace I/O
#
# CONFIG_UIO is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_DMIID is not set

#
# File systems
#
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_FS_XATTR is not set
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
# CONFIG_REISER4_FS is not set
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_FS_POSIX_ACL is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_INOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_DNOTIFY is not set
# CONFIG_AUTOFS_FS is not set
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
# CONFIG_MSDOS_FS is not set
# CONFIG_VFAT_FS is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
# CONFIG_CONFIGFS_FS is not set

#
# Layered filesystems
#
# CONFIG_UNION_FS is not set

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set

#
# Network File Systems
#
# CONFIG_NFS_FS is not set
# CONFIG_NFSD is not set
# CONFIG_SMB_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y

#
# Native Language Support
#
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_UTF8 is not set

#
# Distributed Lock Manager
#
# CONFIG_DLM is not set

#
# Instrumentation Support
#
# CONFIG_PROFILING is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_MAGIC_SYSRQ=y
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
CONFIG_DETECT_SOFTLOCKUP=y
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
CONFIG_SLUB_DEBUG_ON=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_LIST=y
# CONFIG_FRAME_POINTER is not set
CONFIG_UNWIND_INFO=y
CONFIG_STACK_UNWIND=y
# CONFIG_PROFILE_LIKELY is not set
# CONFIG_FORCED_INLINING is not set
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DEBUG_SYNCHRO_TEST is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_WANT_EXTRA_DEBUG_INFORMATION is not set
# CONFIG_KGDB is not set
# CONFIG_KGDB_ATTACH_WAIT is not set
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_DEBUG_STACK_USAGE is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
# CONFIG_CRYPTO is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_CRC_CCITT is not set
# CONFIG_CRC16 is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y


--------------------------------------------------------------------
ffffffff803b6f70 <tcp_rto_min>:
ffffffff803b6f70:	48 8b 97 00 01 00 00 	mov    0x100(%rdi),%rdx
ffffffff803b6f77:	b8 14 00 00 00       	mov    $0x14,%eax
ffffffff803b6f7c:	f6 42 39 20          	testb  $0x20,0x39(%rdx)
ffffffff803b6f80:	74 03                	je     ffffffff803b6f85 <tcp_rto_min+0x15>
ffffffff803b6f82:	8b 42 68             	mov    0x68(%rdx),%eax
ffffffff803b6f85:	f3 c3                	repz retq 
ffffffff803b6f87:	66                   	data16
ffffffff803b6f88:	66                   	data16
ffffffff803b6f89:	90                   	nop    
ffffffff803b6f8a:	66                   	data16
ffffffff803b6f8b:	66                   	data16
ffffffff803b6f8c:	90                   	nop    
ffffffff803b6f8d:	66                   	data16
ffffffff803b6f8e:	66                   	data16
ffffffff803b6f8f:	90                   	nop    
