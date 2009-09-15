From: "Graham, David" <david.graham@intel.com>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during
 resume
Date: Tue, 15 Sep 2009 15:54:20 -0700
Message-ID: <13830B75AD5A2F42848F92269B11996F5BF592C3@orsmsx509.amr.corp.intel.com>
References: <20090915120538.GA26806@bizet.domek.prywatny>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Rafael J. Wysocki"
	<rjw@sisk.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090915120538.GA26806@bizet.domek.prywatny>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

A v2.6.30..v2.6.31 diff shows that this is probably exposed by Rafael Wysocki's commit 6905b1f1, which now allows systems with e100 to sleep. If I understand correctly, it looks like these systems simply couldn't sleep before. Is that right Rafael?. I don't think its likely that the commit is a direct cause of the problem, but that the suspend/resume cycle now allows us to see another issue. Maybe e100 is leaking memory on suspend/resume cycles, or something else is leaking memory, or memory is becoming fragmented and the e100 driver is improperly requesting and being failed on an 'atomic' memory allocation  from a heavily fragmented memory map. Or something else.

So we ( Jesse Brandeburg & I ) have some ideas, and I am trying to get a symptom here. and going through the e100 memory allocation code looking for clues.

Dave

________________________________________
From: Karol Lewandowski [karol.k.lewandowski@gmail.com]
Sent: Tuesday, September 15, 2009 5:05 AM
To: e1000-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org
Subject: [E1000-devel] [BUG 2.6.30+] e100 sometimes causes oops during resume

Hello,

I'm getting following oops sometimes during resume on my Thinkpad T21
(where "sometimes" means about 10/1 good/bad ratio):

ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 26450, comm: ifconfig Not tainted 2.6.31-rc9-revert #13
Call Trace:
 [<c015c1cc>] ? __alloc_pages_nodemask+0x402/0x444
 [<c0104de7>] ? dma_generic_alloc_coherent+0x4a/0xab
 [<c0104d9d>] ? dma_generic_alloc_coherent+0x0/0xab
 [<c0298f5b>] ? e100_alloc_cbs+0xc7/0x174
 [<c0299fea>] ? e100_up+0x1b/0xf5
 [<c029a0db>] ? e100_open+0x17/0x41
 [<c02fb0bf>] ? dev_open+0x8f/0xc5
 [<c02fa879>] ? dev_change_flags+0xa2/0x155
 [<c03305b6>] ? devinet_ioctl+0x22a/0x51c
 [<c02ee45e>] ? sock_ioctl+0x0/0x1e4
 [<c02ee61e>] ? sock_ioctl+0x1c0/0x1e4
 [<c02ee45e>] ? sock_ioctl+0x0/0x1e4
 [<c017ef06>] ? vfs_ioctl+0x16/0x4a
 [<c017f7cd>] ? do_vfs_ioctl+0x48a/0x4c1
 [<c0167e07>] ? handle_mm_fault+0x1e0/0x42c
 [<c034bd9c>] ? do_page_fault+0x2ce/0x2e4
 [<c017f830>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   9
Active_anon:10268 active_file:11642 inactive_anon:24589
 inactive_file:13029 unevictable:0 dirty:9 writeback:0 unstable:0
 free:894 slab:2149 mapped:3962 pagetables:449 bounce:0
DMA free:1076kB min:124kB low:152kB high:184kB active_anon:936kB inactive_anon:3388kB active_file:2776kB inactive_file:3080kB unevictable:0kB present:15868kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2500kB min:1908kB low:2384kB high:2860kB active_anon:40136kB inactive_anon:94968kB active_file:43792kB inactive_file:49036kB unevictable:0kB present:243776kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 1*4kB 0*8kB 3*16kB 2*32kB 1*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1076kB
Normal: 415*4kB 65*8kB 18*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2500kB
29934 total pagecache pages
5112 pages in swap cache
Swap cache stats: add 104796, delete 99684, find 78817/93038
Free swap  = 457116kB
Total swap = 514040kB
65520 pages RAM
1667 pages reserved
11094 pages shared
56751 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 26450, comm: ifconfig Not tainted 2.6.31-rc9-revert #13
Call Trace:
 [<c015c1cc>] ? __alloc_pages_nodemask+0x402/0x444
 [<c0104de7>] ? dma_generic_alloc_coherent+0x4a/0xab
 [<c0104d9d>] ? dma_generic_alloc_coherent+0x0/0xab
 [<c0298f5b>] ? e100_alloc_cbs+0xc7/0x174
 [<c0299fea>] ? e100_up+0x1b/0xf5
 [<c029a0db>] ? e100_open+0x17/0x41
 [<c02fb0bf>] ? dev_open+0x8f/0xc5
 [<c02fa879>] ? dev_change_flags+0xa2/0x155
 [<c03305b6>] ? devinet_ioctl+0x22a/0x51c
 [<c02ee45e>] ? sock_ioctl+0x0/0x1e4
 [<c02ee61e>] ? sock_ioctl+0x1c0/0x1e4
 [<c02ee45e>] ? sock_ioctl+0x0/0x1e4
 [<c017ef06>] ? vfs_ioctl+0x16/0x4a
 [<c017f7cd>] ? do_vfs_ioctl+0x48a/0x4c1
 [<c016a217>] ? unmap_region+0xa2/0xd1
 [<c016a289>] ? remove_vma+0x43/0x48
 [<c016ad7a>] ? do_munmap+0x20e/0x228
 [<c017f830>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   8
Active_anon:10316 active_file:11612 inactive_anon:24605
 inactive_file:13025 unevictable:0 dirty:9 writeback:66 unstable:0
 free:864 slab:2149 mapped:3985 pagetables:462 bounce:0
DMA free:1076kB min:124kB low:152kB high:184kB active_anon:936kB inactive_anon:3388kB active_file:2776kB inactive_file:3080kB unevictable:0kB present:15868kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2380kB min:1908kB low:2384kB high:2860kB active_anon:40328kB inactive_anon:95032kB active_file:43672kB inactive_file:49020kB unevictable:0kB present:243776kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 1*4kB 0*8kB 3*16kB 2*32kB 1*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1076kB
Normal: 415*4kB 60*8kB 15*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2380kB
29960 total pagecache pages
5172 pages in swap cache
Swap cache stats: add 104862, delete 99690, find 78819/93040
Free swap  = 456856kB
Total swap = 514040kB
65520 pages RAM
1667 pages reserved
11419 pages shared
56744 pages non-shared


This is caused by ifup scripts that try to bring interface up after
resume.  When I do so manually it doesn't produce error.  System seems
to behave normally despite that error.

This is on 2.6.31-rc9 (with unrelated patch reverted), 2.6.31-rc8
shown similiar behaviour. Neither 2.6.31 nor Linus' HEAD seems to
address this issue.


Hardware:

0:03.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet Pro 100 (rev 09)
        Subsystem: Intel Corporation EtherExpress PRO/100+ MiniPCI
        Flags: bus master, medium devsel, latency 66, IRQ 11
        Memory at e8120000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at 1800 [size=64]
        Memory at e8100000 (32-bit, non-prefetchable) [size=128K]
        [virtual] Expansion ROM at 20100000 [disabled] [size=1M]
        Capabilities: [dc] Power Management version 2
        Kernel driver in use: e100

Full dmesg follows, including successful suspend-resume and oops (at
end) of unsuccessful one.


Linux version 2.6.31-rc9-revert (karol@wagner) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #13 Mon Sep 7 21:16:17 CEST 2009
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000fff0000 (usable)
 BIOS-e820: 000000000fff0000 - 000000000fffec00 (ACPI data)
 BIOS-e820: 000000000fffec00 - 0000000010000000 (ACPI NVS)
 BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
DMI 2.3 present.
last_pfn = 0xfff0 max_arch_pfn = 0x100000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-CBFFF write-protect
  CC000-DFFFF uncachable
  E0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000 mask FF0000000 write-back
  1 disabled
  2 disabled
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
initial memory mapped : 0 - 00800000
init_memory_mapping: 0000000000000000-000000000fff0000
 0000000000 - 0000400000 page 4k
 0000400000 - 000fc00000 page 2M
 000fc00000 - 000fff0000 page 4k
kernel direct mapping tables up to fff0000 @ 7000-c000
ACPI: RSDP 000f7120 00014 (v00 PTLTD )
ACPI: RSDT 0fff4c5d 0002C (v01 PTLTD    RSDT   06041160  LTP 00000000)
ACPI: FACP 0fffeb65 00074 (v01 IBM    TP-T21   06041160      00000000)
ACPI: DSDT 0fff4c89 09EDC (v01 IBM    TP-T21   06041160 MSFT 0100000C)
ACPI: FACS 0ffff000 00040
ACPI: BOOT 0fffebd9 00027 (v01 PTLTD  $SBFTBL$ 06041160  LTP 00000001)
255MB LOWMEM available.
  mapped low ram: 0 - 0fff0000
  low ram: 0 - 0fff0000
  node 0 low ram: 00000000 - 0fff0000
  node 0 bootmap 00001000 - 00003000
(6 early reservations) ==> bootmem [0000000000 - 000fff0000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000100000 - 0000516940]    TEXT DATA BSS ==> [0000100000 - 0000516940]
  #2 [000009f800 - 0000100000]    BIOS reserved ==> [000009f800 - 0000100000]
  #3 [0000517000 - 00005190d9]              BRK ==> [0000517000 - 00005190d9]
  #4 [0000007000 - 0000008000]          PGTABLE ==> [0000007000 - 0000008000]
  #5 [0000001000 - 0000003000]          BOOTMAP ==> [0000001000 - 0000003000]
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  Normal   0x00001000 -> 0x0000fff0
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x0000fff0
On node 0 totalpages: 65423
free_area_init_node: node 0, pgdat c0458514, node_mem_map c1000000
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3967 pages, LIFO batch:0
  Normal zone: 480 pages used for memmap
  Normal zone: 60944 pages, LIFO batch:15
ACPI: PM-Timer IO Port: 0x1008
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
Allocating PCI resources starting at 10000000 (gap: 10000000:eff80000)
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64911
Kernel command line: root=/dev/sda2 resume=/dev/sda1 ro
PID hash table entries: 1024 (order: 10, 4096 bytes)
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
Memory: 255100k/262080k available (2359k kernel code, 6468k reserved, 1086k data, 256k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffe5000 - 0xfffff000   ( 104 kB)
    vmalloc : 0xd07f0000 - 0xfffe3000   ( 759 MB)
    lowmem  : 0xc0000000 - 0xcfff0000   ( 255 MB)
      .init : 0xc045e000 - 0xc049e000   ( 256 kB)
      .data : 0xc034dc2b - 0xc045d720   (1086 kB)
      .text : 0xc0100000 - 0xc034dc2b   (2359 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
SLUB: Genslabs=13, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
NR_IRQS:16
CPU 0 irqstacks, hard=c042b000 soft=c042c000
Fast TSC calibration using PIT
Detected 796.603 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Calibrating delay loop (skipped), value calculated using timer frequency.. 1593.20 BogoMIPS (lpj=3186412)
Mount-cache hash table entries: 512
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
mce: CPU supports 5 MCE banks
Performance Counters:
no APIC, boot with the "lapic" boot parameter to force-enable it.
no hardware sampling interrupt available.
p6 PMU driver.
... version:                 0
... bit width:               32
... generic counters:        2
... value mask:              00000000ffffffff
... max period:              000000007fffffff
... fixed-purpose counters:  0
... counter mask:            0000000000000003
CPU: Intel Pentium III (Coppermine) stepping 0a
Checking 'hlt' instruction... OK.
ACPI: Core revision 20090521
ACPI: setting ELCR to 0200 (from 0800)
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xfd94f, last bus=7
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3 S4 S5)
ACPI: Using PIC for interrupt routing
ACPI: EC: non-query interrupt received, switching to interrupt mode
ACPI: EC: GPE = 0x9, I/O: command/status = 0x66, data = 0x62
ACPI: EC: driver started in interrupt mode
ACPI: Power Resource [PSER] (off)
ACPI: Power Resource [PSIO] (on)
ACPI: ACPI Dock Station Driver: 3 docks/bays found
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:00.0: reg 10 32bit mmio: [0xf8000000-0xfbffffff]
pci 0000:00:02.0: reg 10 32bit mmio: [0x50000000-0x50000fff]
pci 0000:00:02.0: supports D1 D2
pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:02.0: PME# disabled
pci 0000:00:02.1: reg 10 32bit mmio: [0x50100000-0x50100fff]
pci 0000:00:02.1: supports D1 D2
pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:02.1: PME# disabled
pci 0000:00:03.0: reg 10 32bit mmio: [0xe8120000-0xe8120fff]
pci 0000:00:03.0: reg 14 io port: [0x1800-0x183f]
pci 0000:00:03.0: reg 18 32bit mmio: [0xe8100000-0xe811ffff]
pci 0000:00:03.0: reg 30 32bit mmio: [0x000000-0x0fffff]
pci 0000:00:03.0: supports D1 D2
pci 0000:00:03.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:03.0: PME# disabled
pci 0000:00:03.1: reg 10 io port: [0x1840-0x1847]
pci 0000:00:03.1: reg 14 32bit mmio: [0xe8121000-0xe8121fff]
pci 0000:00:03.1: supports D1 D2
pci 0000:00:03.1: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:03.1: PME# disabled
pci 0000:00:05.0: reg 10 32bit mmio: [0xe8122000-0xe8122fff]
pci 0000:00:05.0: reg 14 32bit mmio: [0xe8000000-0xe80fffff]
pci 0000:00:05.0: supports D1 D2
pci 0000:00:07.1: reg 20 io port: [0x1850-0x185f]
pci 0000:00:07.2: reg 20 io port: [0x1860-0x187f]
pci 0000:00:07.3: quirk: region 1000-103f claimed by PIIX4 ACPI
pci 0000:00:07.3: quirk: region 1040-104f claimed by PIIX4 SMB
pci 0000:00:07.3: PIIX4 devres C PIO at 15e8-15ef
pci 0000:00:07.3: PIIX4 devres I PIO at 03f0-03f7
pci 0000:00:07.3: PIIX4 devres J PIO at 002e-002f
pci 0000:01:00.0: reg 10 32bit mmio: [0xf0000000-0xf7ffffff]
pci 0000:01:00.0: reg 30 32bit mmio: [0x000000-0x00ffff]
pci 0000:01:00.0: supports D1 D2
pci 0000:00:01.0: bridge 32bit mmio: [0xf0000000-0xf7ffffff]
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11)
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: mem resource (0x0-0x9ffff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xc0000-0xc3fff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xc4000-0xc7fff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xc8000-0xcbfff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xcc000-0xcffff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xd0000-0xcffff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xd4000-0xd3fff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xd8000-0xd7fff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xdc000-0xdbfff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xe0000-0xe3fff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xe4000-0xe7fff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xe8000-0xebfff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xec000-0xeffff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp 00:00: mem resource (0xf0000-0xfffff) overlaps 0000:00:03.0 BAR 6 (0x0-0xfffff), disabling
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
system 00:00: iomem range 0x100000-0xfffffff could not be reserved
system 00:00: iomem range 0xfff80000-0xffffffff has been reserved
system 00:02: ioport range 0x1000-0x103f has been reserved
system 00:02: ioport range 0x1040-0x104f has been reserved
system 00:02: ioport range 0xfe00-0xfe0f has been reserved
system 00:09: ioport range 0x15e0-0x15ef has been reserved
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: disabled
pci 0000:00:01.0:   MEM window: 0xf0000000-0xf7ffffff
pci 0000:00:01.0:   PREFETCH window: 0x20000000-0x200fffff
pci 0000:00:02.0: CardBus bridge, secondary bus 0000:02
pci 0000:00:02.0:   IO window: 0x001400-0x0014ff
pci 0000:00:02.0:   IO window: 0x001c00-0x001cff
pci 0000:00:02.0:   PREFETCH window: 0x10000000-0x13ffffff
pci 0000:00:02.0:   MEM window: 0x14000000-0x17ffffff
pci 0000:00:02.1: CardBus bridge, secondary bus 0000:06
pci 0000:00:02.1:   IO window: 0x002000-0x0020ff
pci 0000:00:02.1:   IO window: 0x002400-0x0024ff
pci 0000:00:02.1:   PREFETCH window: 0x18000000-0x1bffffff
pci 0000:00:02.1:   MEM window: 0x1c000000-0x1fffffff
pci 0000:00:02.0: power state changed by ACPI to D0
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
pci 0000:00:02.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
pci 0000:00:02.1: power state changed by ACPI to D0
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
pci 0000:00:02.1: PCI INT B -> Link[LNKB] -> GSI 11 (level, low) -> IRQ 11
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
pci_bus 0000:01: resource 1 mem: [0xf0000000-0xf7ffffff]
pci_bus 0000:01: resource 2 pref mem [0x20000000-0x200fffff]
pci_bus 0000:02: resource 0 io:  [0x1400-0x14ff]
pci_bus 0000:02: resource 1 io:  [0x1c00-0x1cff]
pci_bus 0000:02: resource 2 pref mem [0x10000000-0x13ffffff]
pci_bus 0000:02: resource 3 mem: [0x14000000-0x17ffffff]
pci_bus 0000:06: resource 0 io:  [0x2000-0x20ff]
pci_bus 0000:06: resource 1 io:  [0x2400-0x24ff]
pci_bus 0000:06: resource 2 pref mem [0x18000000-0x1bffffff]
pci_bus 0000:06: resource 3 mem: [0x1c000000-0x1fffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
TCP established hash table entries: 8192 (order: 4, 65536 bytes)
TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
TCP: Hash tables configured (established 8192 bind 8192)
TCP reno registered
NET: Registered protocol family 1
Simple Boot Flag at 0x35 set to 0x1
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
ROMFS MTD (C) 2007 Red Hat, Inc.
msgmni has been set to 498
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:00:00.0: Limiting direct PCI/PCI transfers
pci 0000:01:00.0: Boot video device
savagefb 0000:01:00.0: power state changed by ACPI to D0
savagefb 0000:01:00.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
savagefb: mapped io at d0880000
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
savagefb: mapped framebuffer at d0980000, pbase == f0000000
savagefb v0.4.0_2.6: 8064kB VRAM, using 800x600, 37.878kHz, 60Hz
Console: switching to colour frame buffer device 100x37
fb: S3 Savage/IX-MV frame buffer device
vga16fb: initializing
vga16fb: mapped to 0xc00a0000
fb1: VGA16 VGA frame buffer device
ACPI: AC Adapter [AC] (on-line)
input: Power Button as /class/input/input0
ACPI: Power Button [PWRF]
input: Lid Switch as /class/input/input1
ACPI: Lid Switch [LID]
input: Sleep Button as /class/input/input2
ACPI: Sleep Button [SLPB]
Marking TSC unstable due to TSC halts in idle
ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3])
processor LNXCPU:00: registered as cooling_device0
Switched to high resolution mode on CPU 0
ACPI: Processor [CPU0] (supports 8 throttling states)
thermal LNXTHERM:01: registered as thermal_zone0
ACPI: Thermal Zone [THM0] (44 C)
Linux agpgart interface v0.103
agpgart-intel 0000:00:00.0: Intel 440BX Chipset
agpgart-intel 0000:00:00.0: AGP aperture is 64M @ 0xf8000000
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
serial 00:0c: activated
00:0c: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
serial 0000:00:03.1: PCI INT A -> Link[LNKC] -> GSI 11 (level, low) -> IRQ 11
parport_pc 00:0d: reported by Plug and Play ACPI
parport0: PC-style at 0x3bc, irq 7 [PCSPP,TRISTATE]
ACPI: Battery Slot [BAT0] (battery present)
brd: module loaded
loop: module loaded
ata_piix 0000:00:07.1: version 2.13
scsi0 : ata_piix
scsi1 : ata_piix
ata1: PATA max UDMA/33 cmd 0x1f0 ctl 0x3f6 bmdma 0x1850 irq 14
ata2: PATA max UDMA/33 cmd 0x170 ctl 0x376 bmdma 0x1858 irq 15
e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 11 (level, low) -> IRQ 11
e100 0000:00:03.0: PME# disabled
e100: eth0: e100_probe: addr 0xe8120000, irq 11, MAC addr 00:10:a4:89:e8:84
PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
rtc_cmos 00:06: RTC can wake from S4
rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, y3k, 242 bytes nvram
device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
cpuidle: using governor ladder
cpuidle: using governor menu
Advanced Linux Sound Architecture Driver Version 1.0.20.
input: AT Translated Set 2 keyboard as /class/input/input3
ALSA device list:
  No soundcards found.
TCP cubic registered
NET: Registered protocol family 17
ata1.00: ATA-7: SAMSUNG HM060HC, YJ100-19, max UDMA/100
ata1.00: 117231408 sectors, multi 16: LBA48
ata1.00: configured for UDMA/33
scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HM060HC  YJ10 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 117231408 512-byte logical blocks: (60.0 GB/55.8 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda:
sd 0:0:0:0: Attached scsi generic sg0 type 0
 sda1 sda2 sda3 sda4
sd 0:0:0:0: [sda] Attached SCSI disk
Clocksource tsc unstable (delta = -117760284 ns)
IBM TrackPoint firmware: 0x0e, buttons: 3/3
input: TPPS/2 IBM TrackPoint as /class/input/input4
rtc_cmos 00:06: setting system clock to 2009-09-10 08:21:25 UTC (1252570885)
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with writeback data mode.
VFS: Mounted root (ext3 filesystem) readonly on device 8:2.
Freeing unused kernel memory: 256k freed
uhci_hcd: USB Universal Host Controller Interface driver
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
uhci_hcd 0000:00:07.2: UHCI Host Controller
uhci_hcd 0000:00:07.2: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:07.2: irq 11, io base 0x00001860
usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: UHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.31-rc9-revert uhci_hcd
usb usb1: SerialNumber: 0000:00:07.2
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
yenta_cardbus 0000:00:02.0: CardBus bridge found [1014:0130]
yenta_cardbus 0000:00:02.0: Using INTVAL to route CSC interrupts to PCI
yenta_cardbus 0000:00:02.0: Routing CardBus interrupts to PCI
yenta_cardbus 0000:00:02.0: TI: mfunc 0x00001000, devctl 0x66
yenta_cardbus 0000:00:02.0: ISA IRQ mask 0x0438, PCI irq 11
yenta_cardbus 0000:00:02.0: Socket status: 30000006
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
ALSA sound/pci/cs46xx/cs46xx_lib.c:432: cs46xx: failure waiting for FIFO command to complete
input: PC Speaker as /class/input/input5
Non-volatile memory driver v1.3
thinkpad_acpi: ThinkPad ACPI Extras v0.23
thinkpad_acpi: http://ibm-acpi.sf.net/
thinkpad_acpi: ThinkPad BIOS KZET34WW (1.16 ), EC unknown
Registered led device: tpacpi::thinklight
Registered led device: tpacpi::power
Registered led device: tpacpi::standby
input: ThinkPad Extra Buttons as /class/input/input6
yenta_cardbus 0000:00:02.1: CardBus bridge found [1014:0130]
yenta_cardbus 0000:00:02.1: Using INTVAL to route CSC interrupts to PCI
yenta_cardbus 0000:00:02.1: Routing CardBus interrupts to PCI
yenta_cardbus 0000:00:02.1: TI: mfunc 0x00001000, devctl 0x66
yenta_cardbus 0000:00:02.1: ISA IRQ mask 0x0438, PCI irq 11
yenta_cardbus 0000:00:02.1: Socket status: 30000006
Adding 514040k swap on /dev/sda1.  Priority:-1 extents:1 across:514040k
EXT3 FS on sda2, internal journal
fuse init (API version 7.12)
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda3, internal journal
EXT3-fs: mounted filesystem with writeback data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda4, internal journal
EXT3-fs: mounted filesystem with writeback data mode.
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
lp0: using parport0 (interrupt-driven).
lp0: console ready
ppdev: user-space parallel port driver
[drm] Initialized drm 1.1.0 20060810
eth0: no IPv6 routers present
[drm] Initialized savage 2.4.1 20050313 for 0000:01:00.0 on minor 0
usb 1-1: new low speed USB device using uhci_hcd and address 2
usb 1-1: New USB device found, idVendor=046d, idProduct=c050
usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 1-1: Product: USB-PS/2 Optical Mouse
usb 1-1: Manufacturer: Logitech
usb 1-1: configuration #1 chosen from 1 choice
usbcore: registered new interface driver hiddev
input: Logitech USB-PS/2 Optical Mouse as /class/input/input7
generic-usb 0003:046D:C050.0001: input: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:07.2-1/input0
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.01 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.00 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
ACPI handle has no context!
e100 0000:00:03.0: PCI INT A disabled
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# disabled
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
usb 1-1: reset low speed USB device using uhci_hcd and address 2
Restarting tasks ... done.
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.01 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.02 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
ACPI handle has no context!
ACPI handle has no context!
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
usb 1-1: reset low speed USB device using uhci_hcd and address 2
Restarting tasks ... done.
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
ALSA sound/pci/cs46xx/dsp_spos.c:1884: dsp_spos: SPIOWriteTask not responding
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.00 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.04 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
ACPI handle has no context!
ACPI handle has no context!
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
usb 1-1: reset low speed USB device using uhci_hcd and address 2
Restarting tasks ... done.
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
ALSA sound/pci/cs46xx/dsp_spos.c:1884: dsp_spos: SPIOWriteTask not responding
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
ALSA sound/pci/cs46xx/cs46xx_lib.c:432: cs46xx: failure waiting for FIFO command to complete
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.02 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.06 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
ACPI handle has no context!
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# disabled
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
usb 1-1: reset low speed USB device using uhci_hcd and address 2
Restarting tasks ... done.
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.00 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.06 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
ACPI handle has no context!
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# disabled
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
usb 1-1: reset low speed USB device using uhci_hcd and address 2
Restarting tasks ... done.
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.02 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.05 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
ACPI handle has no context!
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# disabled
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
usb 1-1: reset low speed USB device using uhci_hcd and address 2
Restarting tasks ... done.
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present
udevd version 125 started
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.04 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.08 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
ACPI handle has no context!
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# disabled
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
usb 1-1: reset low speed USB device using uhci_hcd and address 2
Restarting tasks ... done.
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.00 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
ACPI handle has no context!
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# disabled
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
usb 1-1: reset low speed USB device using uhci_hcd and address 2
Restarting tasks ... done.
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present
usb 1-1: USB disconnect, address 2
Sound Fusion CS46xx 0000:00:05.0: PCI INT A disabled
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.02 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.05 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
parport_pc 00:0d: disabled
serial 00:0c: disabled
savagefb 0000:01:00.0: power state changed by ACPI to D3
uhci_hcd 0000:00:07.2: PCI INT D disabled
ACPI handle has no context!
e100 0000:00:03.0: PME# enabled
ACPI: Preparing to enter system sleep state S3
Back to C!
ACPI: Waking up from system sleep state S3
pci 0000:00:01.0: restoring config space at offset 0x9 (was 0xfff0, writing 0x20002000)
pci 0000:00:01.0: restoring config space at offset 0x7 (was 0x2a000f0, writing 0x22a000f0)
e100 0000:00:03.0: restoring config space at offset 0x1 (was 0x2900013, writing 0x2900017)
savagefb 0000:01:00.0: power state changed by ACPI to D0
e100 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# disabled
uhci_hcd 0000:00:07.2: PCI INT D -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
usb usb1: root hub lost power or was reset
savagefb: probed videoram:  8192k
savagefb: Detected current MCLK value of 83045 kHz
savagefb: 1024x768 TFT LCD panel detected and active
savagefb: Limiting video mode to 1024x768
serial 00:0c: activated
parport_pc 00:0d: activated
sd 0:0:0:0: [sda] Starting disk
ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:42:00:00:00:a0 filtered out
ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 filtered out
ata1.00: configured for UDMA/33
ata1.00: configured for UDMA/33
ata1: EH complete
Restarting tasks ... done.
Sound Fusion CS46xx 0000:00:05.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 26450, comm: ifconfig Not tainted 2.6.31-rc9-revert #13
Call Trace:
 [<c015c1cc>] ? __alloc_pages_nodemask+0x402/0x444
 [<c0104de7>] ? dma_generic_alloc_coherent+0x4a/0xab
 [<c0104d9d>] ? dma_generic_alloc_coherent+0x0/0xab
 [<c0298f5b>] ? e100_alloc_cbs+0xc7/0x174
 [<c0299fea>] ? e100_up+0x1b/0xf5
 [<c029a0db>] ? e100_open+0x17/0x41
 [<c02fb0bf>] ? dev_open+0x8f/0xc5
 [<c02fa879>] ? dev_change_flags+0xa2/0x155
 [<c03305b6>] ? devinet_ioctl+0x22a/0x51c
 [<c02ee45e>] ? sock_ioctl+0x0/0x1e4
 [<c02ee61e>] ? sock_ioctl+0x1c0/0x1e4
 [<c02ee45e>] ? sock_ioctl+0x0/0x1e4
 [<c017ef06>] ? vfs_ioctl+0x16/0x4a
 [<c017f7cd>] ? do_vfs_ioctl+0x48a/0x4c1
 [<c0167e07>] ? handle_mm_fault+0x1e0/0x42c
 [<c034bd9c>] ? do_page_fault+0x2ce/0x2e4
 [<c017f830>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   9
Active_anon:10268 active_file:11642 inactive_anon:24589
 inactive_file:13029 unevictable:0 dirty:9 writeback:0 unstable:0
 free:894 slab:2149 mapped:3962 pagetables:449 bounce:0
DMA free:1076kB min:124kB low:152kB high:184kB active_anon:936kB inactive_anon:3388kB active_file:2776kB inactive_file:3080kB unevictable:0kB present:15868kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2500kB min:1908kB low:2384kB high:2860kB active_anon:40136kB inactive_anon:94968kB active_file:43792kB inactive_file:49036kB unevictable:0kB present:243776kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 1*4kB 0*8kB 3*16kB 2*32kB 1*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1076kB
Normal: 415*4kB 65*8kB 18*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2500kB
29934 total pagecache pages
5112 pages in swap cache
Swap cache stats: add 104796, delete 99684, find 78817/93038
Free swap  = 457116kB
Total swap = 514040kB
65520 pages RAM
1667 pages reserved
11094 pages shared
56751 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 26450, comm: ifconfig Not tainted 2.6.31-rc9-revert #13
Call Trace:
 [<c015c1cc>] ? __alloc_pages_nodemask+0x402/0x444
 [<c0104de7>] ? dma_generic_alloc_coherent+0x4a/0xab
 [<c0104d9d>] ? dma_generic_alloc_coherent+0x0/0xab
 [<c0298f5b>] ? e100_alloc_cbs+0xc7/0x174
 [<c0299fea>] ? e100_up+0x1b/0xf5
 [<c029a0db>] ? e100_open+0x17/0x41
 [<c02fb0bf>] ? dev_open+0x8f/0xc5
 [<c02fa879>] ? dev_change_flags+0xa2/0x155
 [<c03305b6>] ? devinet_ioctl+0x22a/0x51c
 [<c02ee45e>] ? sock_ioctl+0x0/0x1e4
 [<c02ee61e>] ? sock_ioctl+0x1c0/0x1e4
 [<c02ee45e>] ? sock_ioctl+0x0/0x1e4
 [<c017ef06>] ? vfs_ioctl+0x16/0x4a
 [<c017f7cd>] ? do_vfs_ioctl+0x48a/0x4c1
 [<c016a217>] ? unmap_region+0xa2/0xd1
 [<c016a289>] ? remove_vma+0x43/0x48
 [<c016ad7a>] ? do_munmap+0x20e/0x228
 [<c017f830>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   8
Active_anon:10316 active_file:11612 inactive_anon:24605
 inactive_file:13025 unevictable:0 dirty:9 writeback:66 unstable:0
 free:864 slab:2149 mapped:3985 pagetables:462 bounce:0
DMA free:1076kB min:124kB low:152kB high:184kB active_anon:936kB inactive_anon:3388kB active_file:2776kB inactive_file:3080kB unevictable:0kB present:15868kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2380kB min:1908kB low:2384kB high:2860kB active_anon:40328kB inactive_anon:95032kB active_file:43672kB inactive_file:49020kB unevictable:0kB present:243776kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 1*4kB 0*8kB 3*16kB 2*32kB 1*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1076kB
Normal: 415*4kB 60*8kB 15*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2380kB
29960 total pagecache pages
5172 pages in swap cache
Swap cache stats: add 104862, delete 99690, find 78819/93040
Free swap  = 456856kB
Total swap = 514040kB
65520 pages RAM
1667 pages reserved
11419 pages shared
56744 pages non-shared
usb 1-1: new low speed USB device using uhci_hcd and address 3
usb 1-1: New USB device found, idVendor=046d, idProduct=c050
usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 1-1: Product: USB-PS/2 Optical Mouse
usb 1-1: Manufacturer: Logitech
usb 1-1: configuration #1 chosen from 1 choice
input: Logitech USB-PS/2 Optical Mouse as /class/input/input8
generic-usb 0003:046D:C050.0002: input: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:07.2-1/input0
e100 0000:00:03.0: firmware: using built-in firmware e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present


------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
