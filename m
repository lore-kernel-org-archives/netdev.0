From: Michael Buesch <mb@bu3sch.de>
Subject: d80211 deadlock with wpa_supplicant and rmmod
Date: Sun, 31 Dec 2006 22:18:00 +0100
Message-ID: <200612312218.00769.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:43872
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933229AbWLaVSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Dec 2006 16:18:54 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I believe we have a deadlock in d80211.
The following triggers it on my 2way SMT machine with preempt.

modprobe bcm43xx-d80211
add sta0
ifconfig sta0 up
start wpa_supplicant on the interface
rmmod bcm43xx-d80211

After that rmmod hangs spinning and wpa_supplicant
stays in D state.

If I first kill wpa_supplicant and then rmmod the module,
it does not deadlock.

Below is sysrq-t output. It looks like it's related to rtnl_mutex.


[    0.000000] Linux version 2.6.19-rc6 (mb@prescott) (gcc version 4.1.2 20060928 (prerelease) (Ubuntu 4.1.1-13ubuntu5)) #1 SMP PREEMPT Sun Dec 31 21:29:46 CET 2006
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003fff0000 (usable)
[    0.000000]  BIOS-e820: 000000003fff0000 - 000000003fff3000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003fff3000 - 0000000040000000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
[    0.000000] 127MB HIGHMEM available.
[    0.000000] 896MB LOWMEM available.
[    0.000000] found SMP MP-table at 000f5f20
[    0.000000] Entering add_active_range(0, 0, 262128) 0 entries of 256 used
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   Normal       4096 ->   229376
[    0.000000]   HighMem    229376 ->   262128
[    0.000000] early_node_map[1] active PFN ranges
[    0.000000]     0:        0 ->   262128
[    0.000000] On node 0 totalpages: 262128
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 4064 pages, LIFO batch:0
[    0.000000]   Normal zone: 1760 pages used for memmap
[    0.000000]   Normal zone: 223520 pages, LIFO batch:31
[    0.000000]   HighMem zone: 255 pages used for memmap
[    0.000000]   HighMem zone: 32497 pages, LIFO batch:7
[    0.000000] DMI 2.2 present.
[    0.000000] ACPI: RSDP (v000 IntelR                                ) @ 0x000f7ae0
[    0.000000] ACPI: RSDT (v001 IntelR AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x3fff3000
[    0.000000] ACPI: FADT (v001 IntelR AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x3fff3040
[    0.000000] ACPI: MADT (v001 IntelR AWRDACPI 0x42302e31 AWRD 0x00000000) @ 0x3fff7240
[    0.000000] ACPI: DSDT (v001 INTELR AWRDACPI 0x00001000 MSFT 0x0100000e) @ 0x00000000
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] Processor #0 15:3 APIC version 20
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] Processor #1 15:3 APIC version 20
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] Allocating PCI resources starting at 50000000 (gap: 40000000:bec00000)
[    0.000000] Detected 2793.090 MHz processor.
[   20.144782] Built 1 zonelists.  Total pages: 260081
[   20.144785] Kernel command line: root=/dev/sda4 ro
[   20.144955] mapped APIC to ffffd000 (fee00000)
[   20.144958] mapped IOAPIC to ffffc000 (fec00000)
[   20.144961] Enabling fast FPU save and restore... done.
[   20.144965] Enabling unmasked SIMD FPU exception support... done.
[   20.144970] Initializing CPU#0
[   20.145111] CPU 0 irqstacks, hard=c052b000 soft=c0529000
[   20.145115] PID hash table entries: 4096 (order: 12, 16384 bytes)
[   20.146618] Console: colour VGA+ 80x25
[   20.148585] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[   20.148648] ... MAX_LOCKDEP_SUBCLASSES:    8
[   20.148698] ... MAX_LOCK_DEPTH:          30
[   20.148747] ... MAX_LOCKDEP_KEYS:        2048
[   20.148797] ... CLASSHASH_SIZE:           1024
[   20.148847] ... MAX_LOCKDEP_ENTRIES:     8192
[   20.148896] ... MAX_LOCKDEP_CHAINS:      8192
[   20.148946] ... CHAINHASH_SIZE:          4096
[   20.148996]  memory used by lock dependency info: 904 kB
[   20.149046]  per task-struct memory footprint: 1200 bytes
[   20.149098] ------------------------
[   20.149270] | Locking API testsuite:
[   20.149320] ----------------------------------------------------------------------------
[   20.149382]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[   20.149445]   --------------------------------------------------------------------------
[   20.149516]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.150473]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.151757]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.153398]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.155014]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.156972]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.158929]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.160888]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.161851]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.162792]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[   20.164067]   --------------------------------------------------------------------------
[   20.164130]               recursive read-lock:             |  ok  |             |  ok  |
[   20.164581]            recursive read-lock #2:             |  ok  |             |  ok  |
[   20.165032]             mixed read-write-lock:             |  ok  |             |  ok  |
[   20.165540]             mixed write-read-lock:             |  ok  |             |  ok  |
[   20.166033]   --------------------------------------------------------------------------
[   20.166096]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[   20.166620]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[   20.167169]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[   20.167718]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[   20.168266]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[   20.168809]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[   20.169361]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[   20.169883]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[   20.170435]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[   20.170978]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[   20.171529]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[   20.172237]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[   20.172950]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[   20.173671]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[   20.174376]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[   20.175077]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[   20.175781]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[   20.176415]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[   20.177088]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[   20.177651]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[   20.178236]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[   20.178866]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[   20.179523]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[   20.180161]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[   20.180832]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[   20.181460]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[   20.182130]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[   20.182763]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[   20.183433]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[   20.184020]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[   20.184644]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[   20.185261]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[   20.185931]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[   20.186518]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[   20.187143]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[   20.187776]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[   20.188451]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[   20.189076]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[   20.189749]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[   20.190387]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[   20.191058]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[   20.191649]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[   20.192279]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[   20.192894]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[   20.193583]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[   20.194176]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[   20.194804]       hard-irq read-recursion/123:  ok  |
[   20.195071]       soft-irq read-recursion/123:  ok  |
[   20.195348]       hard-irq read-recursion/132:  ok  |
[   20.195615]       soft-irq read-recursion/132:  ok  |
[   20.195893]       hard-irq read-recursion/213:  ok  |
[   20.196158]       soft-irq read-recursion/213:  ok  |
[   20.196435]       hard-irq read-recursion/231:  ok  |
[   20.196701]       soft-irq read-recursion/231:  ok  |
[   20.196979]       hard-irq read-recursion/312:  ok  |
[   20.197260]       soft-irq read-recursion/312:  ok  |
[   20.197538]       hard-irq read-recursion/321:  ok  |
[   20.197804]       soft-irq read-recursion/321:  ok  |
[   20.198080] -------------------------------------------------------
[   20.198133] Good, all 218 testcases passed! |
[   20.198182] ---------------------------------
[   20.198552] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[   20.198975] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[   20.255687] Memory: 1031268k/1048512k available (2539k kernel code, 16680k reserved, 1094k data, 204k init, 131008k highmem)
[   20.255770] virtual kernel memory layout:
[   20.255771]     fixmap  : 0xfff81000 - 0xfffff000   ( 504 kB)
[   20.255773]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[   20.255774]     vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
[   20.255775]     lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
[   20.255777]       .init : 0xc04f1000 - 0xc0524000   ( 204 kB)
[   20.255778]       .data : 0xc037acba - 0xc048c58c   (1094 kB)
[   20.255779]       .text : 0xc0100000 - 0xc037acba   (2539 kB)
[   20.256171] Checking if this processor honours the WP bit even in supervisor mode... Ok.
[   20.336802] Calibrating delay using timer specific routine.. 5594.21 BogoMIPS (lpj=11188430)
[   20.337656] Mount-cache hash table entries: 512
[   20.340488] CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 0000041d 00000000 00000000
[   20.340500] monitor/mwait feature present.
[   20.340550] using mwait in idle threads.
[   20.340605] CPU: Trace cache: 12K uops, L1 D cache: 16K
[   20.340691] CPU: L2 cache: 1024K
[   20.340740] CPU: Physical Processor ID: 0
[   20.340804] CPU: After all inits, caps: bfebfbf7 00000000 00000000 00000180 0000041d 00000000 00000000
[   20.340815] Intel machine check architecture supported.
[   20.340871] Intel machine check reporting enabled on CPU#0.
[   20.340923] CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
[   20.340977] CPU0: Thermal monitoring enabled
[   20.341052] Checking 'hlt' instruction... OK.
[   20.356965] Freeing SMP alternatives: 12k freed
[   20.357017] ACPI: Core revision 20060707
[   20.376829] CPU0: Intel(R) Pentium(R) 4 CPU 2.80GHz stepping 03
[   20.376959] lockdep: not fixing up alternatives.
[   20.377230] Booting processor 1/1 eip 2000
[   20.377282] CPU 1 irqstacks, hard=c052c000 soft=c052a000
[   20.387794] Initializing CPU#1
[   20.464584] Calibrating delay using timer specific routine.. 5586.40 BogoMIPS (lpj=11172817)
[   20.464595] CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 0000041d 00000000 00000000
[   20.464605] monitor/mwait feature present.
[   20.464613] CPU: Trace cache: 12K uops, L1 D cache: 16K
[   20.464617] CPU: L2 cache: 1024K
[   20.464620] CPU: Physical Processor ID: 0
[   20.464623] CPU: After all inits, caps: bfebfbf7 00000000 00000000 00000180 0000041d 00000000 00000000
[   20.464633] Intel machine check architecture supported.
[   20.464641] Intel machine check reporting enabled on CPU#1.
[   20.464644] CPU1: Intel P4/Xeon Extended MCE MSRs (12) available
[   20.464649] CPU1: Thermal monitoring enabled
[   20.464978] CPU1: Intel(R) Pentium(R) 4 CPU 2.80GHz stepping 03
[   20.466323] Total of 2 processors activated (11180.62 BogoMIPS).
[   20.466534] ENABLING IO-APIC IRQs
[   20.466858] ..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
[   20.612348] checking TSC synchronization across 2 CPUs: passed.
[    0.007952] Brought up 2 CPUs
[    0.145861] migration_cost=282
[    0.151160] NET: Registered protocol family 16
[    0.152829] ACPI: bus type pci registered
[    0.166369] PCI: PCI BIOS revision 2.10 entry at 0xfba70, last bus=2
[    0.166422] PCI: Using configuration type 1
[    0.166472] Setting up standard PCI resources
[    0.220382] ACPI: Interpreter enabled
[    0.220438] ACPI: Using IOAPIC for interrupt routing
[    0.226258] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.226373] PCI: Probing PCI hardware (bus 00)
[    0.244561] PCI quirk: region 0400-047f claimed by ICH4 ACPI/GPIO/TCO
[    0.244619] PCI quirk: region 0480-04bf claimed by ICH4 GPIO
[    0.244779] PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
[    0.245900] Boot video device is 0000:01:00.0
[    0.247361] PCI: Transparent bridge - 0000:00:1e.0
[    0.247520] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.316806] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
[    0.348809] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 7 9 10 11 12 14 15)
[    0.351126] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 *9 10 11 12 14 15)
[    0.353760] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11 12 14 15)
[    0.356022] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 *10 11 12 14 15)
[    0.358482] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 *10 11 12 14 15)
[    0.361130] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 10 11 12 14 15) *0, disabled.
[    0.363543] ACPI: PCI Interrupt Link [LNK0] (IRQs *3 4 5 7 9 10 11 12 14 15)
[    0.365872] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 7 9 10 *11 12 14 15)
[    0.369049] intel_rng: FWH not detected
[    0.371730] SCSI subsystem initialized
[    0.372098] libata version 2.00 loaded.
[    0.372606] PCI: Using ACPI for IRQ routing
[    0.372658] PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
[    0.399635] PCI: Bridge: 0000:00:01.0
[    0.399686]   IO window: disabled.
[    0.399742]   MEM window: f8000000-f9ffffff
[    0.399797]   PREFETCH window: e8000000-f7ffffff
[    0.399854] PCI: Bridge: 0000:00:1e.0
[    0.399906]   IO window: a000-afff
[    0.399962]   MEM window: fa000000-fa0fffff
[    0.400016]   PREFETCH window: disabled.
[    0.400094] PCI: Setting latency timer of device 0000:00:1e.0 to 64
[    0.400425] NET: Registered protocol family 2
[    0.451633] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.452573] TCP established hash table entries: 65536 (order: 9, 2359296 bytes)
[    0.464934] TCP bind hash table entries: 32768 (order: 8, 1179648 bytes)
[    0.471066] TCP: Hash tables configured (established 65536 bind 32768)
[    0.471241] TCP reno registered
[    0.476384] Machine check exception polling timer started.
[    0.485359] Initializing RT-Tester: OK
[    0.485916] highmem bounce pool size: 64 pages
[    0.489381] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    0.491268] io scheduler noop registered
[    0.491487] io scheduler cfq registered (default)
[    0.834417] Real Time Clock Driver v1.12ac
[    0.835432] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
[    0.836452] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    0.842435] Floppy drive(s): fd0 is 1.44M
[    0.866402] FDC 0 is a post-1991 82077
[    0.873560] loop: loaded (max 8 devices)
[    0.875529] netconsole: not configured, aborting
[    0.875586] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
[    0.875641] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[    0.875933] ICH5: IDE controller at PCI slot 0000:00:1f.1
[    0.876005] ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 16
[    0.876116] ICH5: chipset revision 2
[    0.876166] ICH5: not 100% native mode: will probe irqs later
[    0.876230]     ide0: BM-DMA at 0xf000-0xf007, BIOS settings: hda:DMA, hdb:pio
[    0.876384]     ide1: BM-DMA at 0xf008-0xf00f, BIOS settings: hdc:pio, hdd:pio
[    0.876535] Probing IDE interface ide0...
[    1.457516] Probing IDE interface ide1...
[    2.196401] hdc: CD-W54E, ATAPI CD/DVD-ROM drive
[    2.536171] ide1 at 0x170-0x177,0x376 on irq 15
[    2.539071] hdc: ATAPI 32X CD-ROM CD-R/RW drive, 1280kB Cache, DMA
[    2.539373] Uniform CD-ROM driver Revision: 3.20
[    2.542921] ata_piix 0000:00:1f.2: version 2.00ac6
[    2.542930] ata_piix 0000:00:1f.2: MAP [ P0 -- P1 -- ]
[    2.543173] ACPI: PCI Interrupt 0000:00:1f.2[A] -> GSI 18 (level, low) -> IRQ 16
[    2.543306] PCI: Setting latency timer of device 0000:00:1f.2 to 64
[    2.543689] ata1: SATA max UDMA/133 cmd 0xC000 ctl 0xC402 bmdma 0xD000 irq 16
[    2.543902] ata2: SATA max UDMA/133 cmd 0xC800 ctl 0xCC02 bmdma 0xD008 irq 16
[    2.543979] scsi0 : ata_piix
[    2.705555] ata1.00: ATA-7, max UDMA7, 312581808 sectors: LBA48 
[    2.705609] ata1.00: ata1: dev 0 multi count 16
[    2.707838] ata1.00: configured for UDMA/133
[    2.707908] scsi1 : ata_piix
[    2.877847] ATA: abnormal status 0x7F on port 0xC807
[    2.880356] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG SP1614C  SW10 PQ: 0 ANSI: 5
[    2.883750] SCSI device sda: 312581808 512-byte hdwr sectors (160042 MB)
[    2.883884] sda: Write Protect is off
[    2.883938] sda: Mode Sense: 00 3a 00 00
[    2.884107] SCSI device sda: drive cache: write back
[    2.886440] SCSI device sda: 312581808 512-byte hdwr sectors (160042 MB)
[    2.886586] sda: Write Protect is off
[    2.886639] sda: Mode Sense: 00 3a 00 00
[    2.886836] SCSI device sda: drive cache: write back
[    2.887598]  sda: sda1 sda2 sda3 sda4
[    2.916511] sd 0:0:0:0: Attached scsi disk sda
[    2.919180] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.923145] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.923351] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.926072] mice: PS/2 mouse device common for all mice
[    2.950869] abituguru: testing bank1 sensor 0
[    2.975418] abituguru:   alarm not raised during volt sensor test
[    3.027849] abituguru:   found temp sensor
[    3.028793] abituguru: testing bank1 sensor 1
[    3.051307] abituguru:   alarm not raised during volt sensor test
[    3.103651] abituguru:   found temp sensor
[    3.104599] abituguru: testing bank1 sensor 3
[    3.127671] abituguru:   found volt sensor
[    3.128619] abituguru: testing bank1 sensor 4
[    3.151598] abituguru:   found volt sensor
[    3.152548] abituguru: testing bank1 sensor 10
[    3.175084] abituguru:   alarm not raised during volt sensor test
[    3.227014] abituguru:   alarm not raised during temp sensor test
[    3.227957] abituguru: testing bank1 sensor 8
[    3.250958] abituguru:   alarm not raised during volt sensor test
[    3.302894] abituguru:   alarm not raised during temp sensor test
[    3.303840] abituguru: testing bank1 sensor 14
[    3.326883] abituguru:   alarm not raised during volt sensor test
[    3.378720] abituguru:   alarm not raised during temp sensor test
[    3.379659] abituguru: testing bank1 sensor 2
[    3.403167] abituguru:   found volt sensor
[    3.404112] abituguru: testing bank1 sensor 9
[    3.426693] abituguru:   alarm not raised during volt sensor test
[    3.478583] abituguru:   alarm not raised during temp sensor test
[    3.479531] abituguru: testing bank1 sensor 6
[    3.503024] abituguru:   found volt sensor
[    3.503972] abituguru: testing bank1 sensor 5
[    3.527009] abituguru:   found volt sensor
[    3.527957] abituguru: testing bank1 sensor 11
[    3.550472] abituguru:   alarm not raised during volt sensor test
[    3.602341] abituguru:   alarm not raised during temp sensor test
[    3.603282] abituguru: testing bank1 sensor 15
[    3.626372] abituguru:   alarm not raised during volt sensor test
[    3.678221] abituguru:   alarm not raised during temp sensor test
[    3.679170] abituguru: testing bank1 sensor 13
[    3.702194] abituguru:   alarm not raised during volt sensor test
[    3.754113] abituguru:   alarm not raised during temp sensor test
[    3.755060] abituguru: testing bank1 sensor 7
[    3.778091] abituguru:   alarm not raised during volt sensor test
[    3.829984] abituguru:   alarm not raised during temp sensor test
[    3.830930] abituguru: testing bank1 sensor 12
[    3.853946] abituguru:   alarm not raised during volt sensor test
[    3.905848] abituguru:   alarm not raised during temp sensor test
[    3.906456] abituguru: detecting number of fan sensors
[    3.906459] abituguru:   bank2 sensor 0 does not seem to be a fan sensor: the threshold (0) is below the minimum (5)
[    3.906462] abituguru:  found: 0 fan sensors
[    3.906464] abituguru: detecting number of PWM outputs
[    3.906467] abituguru:   pwm channel 2 does not seem to be a pwm channel: 15 is not a valid temp sensor address
[    3.906470] abituguru:  found: 2 PWM outputs
[    3.906475] abituguru: found Abit uGuru
[    3.908174] Advanced Linux Sound Architecture Driver Version 1.0.13 (Sun Oct 22 08:56:16 2006 UTC).
[    3.915771] ACPI: PCI Interrupt 0000:02:06.0[A] -> GSI 22 (level, low) -> IRQ 17
[    3.920493] Installing spdif_bug patch: Audigy 2 ZS [SB0350]
[    4.004265] ALSA device list:
[    4.004321]   #0: Audigy 2 ZS [SB0350] (rev.4, serial:0x20021102) at 0xa400, irq 17
[    4.004671] TCP cubic registered
[    4.004785] NET: Registered protocol family 1
[    4.005311] NET: Registered protocol family 8
[    4.005363] NET: Registered protocol family 20
[    4.006630] Starting balanced_irq
[    4.006705] Using IPI Shortcut mode
[    4.009301] Time: tsc clocksource has been installed.
[    4.025821] ReiserFS: sda4: found reiserfs format "3.6" with standard journal
[    4.025992] ReiserFS: sda4: using ordered data mode
[    4.032729] ReiserFS: sda4: journal params: device sda4, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
[    4.033439] ReiserFS: sda4: checking transaction log (sda4)
[    4.074498] ReiserFS: sda4: Using r5 hash to sort names
[    4.076112] VFS: Mounted root (reiserfs filesystem) readonly.
[    4.076617] Freeing unused kernel memory: 204k freed
[   16.636806] usbcore: registered new interface driver usbfs
[   16.638209] usbcore: registered new interface driver hub
[   16.639953] usbcore: registered new device driver usb
[   16.643738] uhci_hcd: Unknown symbol usb_hcd_pci_suspend
[   16.643864] uhci_hcd: Unknown symbol usb_hcd_resume_root_hub
[   16.643983] uhci_hcd: Unknown symbol usb_hcd_pci_probe
[   16.644134] uhci_hcd: Unknown symbol usb_check_bandwidth
[   16.644296] uhci_hcd: Unknown symbol usb_disabled
[   16.644404] uhci_hcd: Unknown symbol usb_release_bandwidth
[   16.644639] uhci_hcd: Unknown symbol usb_claim_bandwidth
[   16.644823] uhci_hcd: Unknown symbol usb_hcd_pci_resume
[   16.645016] uhci_hcd: Unknown symbol usb_hcd_giveback_urb
[   16.645145] uhci_hcd: Unknown symbol usb_hcd_poll_rh_status
[   16.645299] uhci_hcd: Unknown symbol usb_hcd_pci_remove
[   16.645404] uhci_hcd: Unknown symbol usb_root_hub_lost_power
[   16.657587] Linux agpgart interface v0.101 (c) Dave Jones
[   16.673383] agpgart: Detected an Intel 865 Chipset.
[   16.681730] agpgart: AGP aperture is 128M @ 0xe0000000
[   16.690959] ACPI: PCI Interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 18
[   16.691135] PCI: Setting latency timer of device 0000:00:1d.7 to 64
[   16.691156] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[   16.699715] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[   16.700673] ehci_hcd 0000:00:1d.7: debug port 1
[   16.700761] PCI: cache line size of 128 is not supported by device 0000:00:1d.7
[   16.700830] ehci_hcd 0000:00:1d.7: irq 18, io mem 0xfa100000
[   16.704780] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[   16.713987] usb usb1: configuration #1 chosen from 1 choice
[   16.718261] hub 1-0:1.0: USB hub found
[   16.719035] hub 1-0:1.0: 8 ports detected
[   16.762335] USB Universal Host Controller Interface driver v3.0
[   16.849065] ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 19
[   16.849201] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[   16.849211] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   16.850193] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[   16.850333] uhci_hcd 0000:00:1d.0: irq 19, io base 0x0000bc00
[   16.855537] usb usb2: configuration #1 chosen from 1 choice
[   16.857930] hub 2-0:1.0: USB hub found
[   16.858687] hub 2-0:1.0: 2 ports detected
[   16.970093] ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 20
[   16.970256] PCI: Setting latency timer of device 0000:00:1d.1 to 64
[   16.970267] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   16.972148] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[   16.972273] uhci_hcd 0000:00:1d.1: irq 20, io base 0x0000b000
[   16.976608] usb usb3: configuration #1 chosen from 1 choice
[   16.978816] hub 3-0:1.0: USB hub found
[   16.978949] hub 3-0:1.0: 2 ports detected
[   17.086793] ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 16
[   17.086924] PCI: Setting latency timer of device 0000:00:1d.2 to 64
[   17.086934] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   17.088225] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[   17.088334] uhci_hcd 0000:00:1d.2: irq 16, io base 0x0000b400
[   17.092704] usb usb4: configuration #1 chosen from 1 choice
[   17.094191] hub 4-0:1.0: USB hub found
[   17.094285] hub 4-0:1.0: 2 ports detected
[   17.205559] ACPI: PCI Interrupt 0000:00:1d.3[A] -> GSI 16 (level, low) -> IRQ 19
[   17.205700] PCI: Setting latency timer of device 0000:00:1d.3 to 64
[   17.205716] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[   17.208628] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[   17.208792] uhci_hcd 0000:00:1d.3: irq 19, io base 0x0000b800
[   17.217339] usb usb5: configuration #1 chosen from 1 choice
[   17.219910] hub 5-0:1.0: USB hub found
[   17.220014] hub 5-0:1.0: 2 ports detected
[   17.225186] ieee1394: Initialized config rom entry `ip1394'
[   17.270651] 8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004)
[   17.275028] usb 2-2: new full speed USB device using uhci_hcd and address 2
[   17.334143] 8139cp 0000:02:02.0: This (id 10ec:8139 rev 10) is not an 8139C+ compatible chip
[   17.334216] 8139cp 0000:02:02.0: Try the "8139too" driver instead.
[   17.395453] gameport: EMU10K1 is pci0000:02:06.1/gameport0, io 0xa800, speed 1569kHz
[   17.467313] usb 2-2: configuration #1 chosen from 1 choice
[   17.472882] hub 2-2:1.0: USB hub found
[   17.475719] hub 2-2:1.0: 3 ports detected
[   17.603487] 8139too Fast Ethernet driver 0.9.28
[   17.604830] ACPI: PCI Interrupt 0000:02:02.0[A] -> GSI 18 (level, low) -> IRQ 16
[   17.608544] eth0: RealTek RTL8139 at 0xf8974000, 00:50:8d:d5:d7:61, IRQ 16
[   17.608607] eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
[   17.671900] ACPI: PCI Interrupt 0000:02:01.0[A] -> GSI 17 (level, low) -> IRQ 21
[   17.759593] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[21]  MMIO=[fa00a000-fa00a7ff]  Max Packet=[2048]  IR/IT contexts=[4/8]
[   17.762562] ACPI: PCI Interrupt 0000:02:06.2[B] -> GSI 23 (level, low) -> IRQ 18
[   17.822097] ohci1394: fw-host1: OHCI-1394 1.1 (PCI): IRQ=[18]  MMIO=[fa00b000-fa00b7ff]  Max Packet=[2048]  IR/IT contexts=[4/8]
[   17.830871] usb 2-2.1: new full speed USB device using uhci_hcd and address 3
[   17.991300] usb 2-2.1: configuration #1 chosen from 1 choice
[   18.189738] input: GenPS/2 Genius Mouse as /class/input/input0
[   18.934671] usbcore: registered new interface driver hiddev
[   18.998091] input: Chicony  PFU-65 USB Keyboard as /class/input/input1
[   19.008743] input: USB HID v1.00 Keyboard [Chicony  PFU-65 USB Keyboard] on usb-0000:00:1d.0-2.1
[   19.008981] usbcore: registered new interface driver usbhid
[   19.009053] drivers/usb/input/hid-core.c: v2.6:USB HID core driver
[   19.070442] ieee1394: Host added: ID:BUS[0-00:1023]  GUID[00508d0000d4d761]
[   19.157776] eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   19.361249] ieee1394: Host added: ID:BUS[1-00:1023]  GUID[00023c01510ed301]
[   19.876802] parport0: PC-style at 0x378 [PCSPP]
[   19.988403] lp0: using parport0 (polling).
[   20.068066] ieee1394: sbp2: Driver forced to serialize I/O (serialize_io=1)
[   20.068136] ieee1394: sbp2: Try serialize_io=0 for better performance
[   20.290819] Adding 1951888k swap on /dev/disk/by-uuid/97f55782-d547-4ac3-8ce6-8c5865c10620.  Priority:-1 extents:1 across:1951888k
[   20.345288] NET: Registered protocol family 17
[   26.318773] NET: Registered protocol family 10
[   26.320105] lo: Disabled Privacy Extensions
[   35.247823] NTFS driver 2.1.27 [Flags: R/O MODULE].
[   35.318176] NTFS volume version 3.0.
[   36.414655] eth0: no IPv6 routers present
[   39.337709] Using specific hotkey driver
[   39.618593] ACPI: Thermal Zone [THRM] (20 C)
[   39.743464] toshiba_acpi: Unknown parameter `hotkeys_over_acpi'
[   39.798975] ACPI: Power Button (FF) [PWRF]
[   39.799008] ACPI: Power Button (CM) [PWRB]
[   39.980050] ibm_acpi: ec object not found
[   44.562998] apm: BIOS not found.
[   63.491851] ACPI: PCI Interrupt 0000:02:04.0[A] -> GSI 20 (level, low) -> IRQ 22
[   63.517064] ssb: Core 0 found: cc 0800, rev 0D, vendor 4243
[   63.517086] ssb: Core 1 found: cc 0812, rev 09, vendor 4243
[   63.517175] ssb: Core 2 found: cc 0804, rev 0C, vendor 4243
[   63.517204] ssb: Core 3 found: cc 080D, rev 07, vendor 4243
[   63.517277] bcm43xx_d80211: Broadcom 4318 WLAN found
[   63.517290] ssb: Switching to core 2
[   63.520898] ssb: Switching to core 1
[   63.520935] bcm43xx_d80211: PHY connected
[   63.520956] bcm43xx_d80211: Detected PHY: Version: 3, Type 2, Revision 7
[   63.521037] bcm43xx_d80211: Detected Radio: ID: 8205017f (Manuf: 17f Ver: 2050 Rev: 8)
[   63.521063] bcm43xx_d80211: Radio turned off
[   63.521079] bcm43xx_d80211: Radio turned off
[   63.634357] wmaster0: Selected rate control algorithm 'simple'
[   65.893123] bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 5, MAC: 00:14:bf:72:8f:b7)
[   65.913004] ssb: Switching to core 0
[   65.913169] ssb: Switching to core 1
[   65.914707] bcm43xx_d80211: PHY connected
[   66.287295] bcm43xx_d80211: firmware revision 15F, patchlevel 7E, date 2006-07-29 05:54:02
[   66.287612] ssb: Switching to core 0
[   66.288097] ssb: Switching to core 1
[   66.299189] bcm43xx_d80211: Radio turned on
[   66.315150] bcm43xx_d80211: ASSERTION FAILED (radio_attenuation < 10) at: drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1482:bcm43xx_find_lopair()
[   66.472443] bcm43xx_d80211: ASSERTION FAILED (radio_attenuation < 10) at: drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1482:bcm43xx_find_lopair()
[   66.476345] bcm43xx_d80211: ASSERTION FAILED (radio_attenuation < 10) at: drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1482:bcm43xx_find_lopair()
[   66.476455] ssb: Switching to core 0
[   66.477179] ssb: Switching to core 1
[   66.478678] bcm43xx_d80211: Chip initialized
[   66.486788] bcm43xx_d80211: 32-bit DMA initialized
[   66.503289] bcm43xx_d80211: Selected 802.11 core (phytype 2)
[   66.508675] wmaster0: Does not support passive scan, disabled
[   66.511930] bcm43xx_d80211: ASSERTION FAILED (radio_attenuation < 10) at: drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1482:bcm43xx_find_lopair()
[   66.533094] sta0: dropped data frame to not associated station 00:00:00:00:00:00
[   66.644469] sta0: starting scan
[   66.644615] HW CONFIG: channel=1 freq=2412 phymode=3
[   66.715761] HW CONFIG: channel=2 freq=2417 phymode=3
[   66.787647] HW CONFIG: channel=3 freq=2422 phymode=3
[   66.859532] HW CONFIG: channel=4 freq=2427 phymode=3
[   66.931397] HW CONFIG: channel=5 freq=2432 phymode=3
[   67.003283] HW CONFIG: channel=6 freq=2437 phymode=3
[   67.075157] HW CONFIG: channel=7 freq=2442 phymode=3
[   67.147041] HW CONFIG: channel=8 freq=2447 phymode=3
[   67.218919] HW CONFIG: channel=9 freq=2452 phymode=3
[   67.290792] HW CONFIG: channel=10 freq=2457 phymode=3
[   67.362685] HW CONFIG: channel=11 freq=2462 phymode=3
[   67.434652] HW CONFIG: channel=1 freq=2412 phymode=3
[   67.442623] sta0: scan completed
[   67.445772] HW CONFIG: channel=6 freq=2437 phymode=3
[   67.453846] sta0: Initial auth_alg=0
[   67.453853] sta0: authenticate with AP 00:90:4c:60:04:00
[   67.455760] sta0: RX authentication from 00:90:4c:60:04:00 (alg=0 transaction=2 status=0)
[   67.455769] sta0: authenticated
[   67.455774] sta0: associate with AP 00:90:4c:60:04:00
[   67.455782] sta0: mismatch in privacy configuration and mixed-cell disabled - abort association
[   67.538859] sta0: dropped data frame to not associated station 00:90:4c:60:04:00
[   67.654182] sta0: associate with AP 00:90:4c:60:04:00
[   67.654190] sta0: mismatch in privacy configuration and mixed-cell disabled - abort association
[   67.654199] sta0: privacy configuration mismatch and mixed-cell disabled - disassociate
[   68.537768] sta0: dropped data frame to not associated station 00:90:4c:60:04:00
[   72.450437] sta0: starting scan
[   72.450583] HW CONFIG: channel=1 freq=2412 phymode=3
[   72.521978] HW CONFIG: channel=2 freq=2417 phymode=3
[   72.593857] HW CONFIG: channel=3 freq=2422 phymode=3
[   72.665736] HW CONFIG: channel=4 freq=2427 phymode=3
[   72.737615] HW CONFIG: channel=5 freq=2432 phymode=3
[   72.809493] HW CONFIG: channel=6 freq=2437 phymode=3
[   72.881373] HW CONFIG: channel=7 freq=2442 phymode=3
[   72.953251] HW CONFIG: channel=8 freq=2447 phymode=3
[   73.025130] HW CONFIG: channel=9 freq=2452 phymode=3
[   73.097010] HW CONFIG: channel=10 freq=2457 phymode=3
[   73.168889] HW CONFIG: channel=11 freq=2462 phymode=3
[   73.240869] HW CONFIG: channel=6 freq=2437 phymode=3
[   73.248818] sta0: scan completed
[   73.251600] HW CONFIG: channel=6 freq=2437 phymode=3
[   73.251781] sta0: Initial auth_alg=0
[   73.251788] sta0: authenticate with AP 00:90:4c:60:04:00
[   73.252061] sta0: Initial auth_alg=0
[   73.252067] sta0: authenticate with AP 00:90:4c:60:04:00
[   73.252785] sta0: RX authentication from 00:90:4c:60:04:00 (alg=0 transaction=2 status=0)
[   73.252792] sta0: authenticated
[   73.252797] sta0: associate with AP 00:90:4c:60:04:00
[   73.252804] sta0: mismatch in privacy configuration and mixed-cell disabled - abort association
[   73.253931] sta0: authentication frame received from 00:90:4c:60:04:00, but not in authenticate state - ignored
[   73.452414] sta0: associate with AP 00:90:4c:60:04:00
[   73.452423] sta0: mismatch in privacy configuration and mixed-cell disabled - abort association
[   73.452432] sta0: privacy configuration mismatch and mixed-cell disabled - disassociate
[   76.008423] sta0: dropped data frame to not associated station 00:90:4c:60:04:00
[   76.527682] sta0: dropped data frame to not associated station 00:90:4c:60:04:00
[   77.525440] sta0: no IPv6 routers present
[   78.244684] sta0: starting scan
[   78.244821] HW CONFIG: channel=1 freq=2412 phymode=3
[   78.316223] HW CONFIG: channel=2 freq=2417 phymode=3
[   78.388102] HW CONFIG: channel=3 freq=2422 phymode=3
[   78.459982] HW CONFIG: channel=4 freq=2427 phymode=3
[   78.531860] HW CONFIG: channel=5 freq=2432 phymode=3
[   78.603739] HW CONFIG: channel=6 freq=2437 phymode=3
[   78.675619] HW CONFIG: channel=7 freq=2442 phymode=3
[   78.747497] HW CONFIG: channel=8 freq=2447 phymode=3
[   78.819376] HW CONFIG: channel=9 freq=2452 phymode=3
[   78.891255] HW CONFIG: channel=10 freq=2457 phymode=3
[   78.963134] HW CONFIG: channel=11 freq=2462 phymode=3
[   79.035114] HW CONFIG: channel=6 freq=2437 phymode=3
[   79.043070] sta0: scan completed
[   79.045910] HW CONFIG: channel=6 freq=2437 phymode=3
[   79.046091] sta0: Initial auth_alg=0
[   79.046097] sta0: authenticate with AP 00:90:4c:60:04:00
[   79.046392] sta0: Initial auth_alg=0
[   79.046397] sta0: authenticate with AP 00:90:4c:60:04:00
[   79.047307] sta0: RX authentication from 00:90:4c:60:04:00 (alg=0 transaction=2 status=0)
[   79.047313] sta0: authenticated
[   79.047319] sta0: associate with AP 00:90:4c:60:04:00
[   79.047326] sta0: mismatch in privacy configuration and mixed-cell disabled - abort association
[   79.048198] sta0: authentication frame received from 00:90:4c:60:04:00, but not in authenticate state - ignored
[   79.246660] sta0: associate with AP 00:90:4c:60:04:00
[   79.246670] sta0: mismatch in privacy configuration and mixed-cell disabled - abort association
[   79.246679] sta0: privacy configuration mismatch and mixed-cell disabled - disassociate
[   80.474104] bcm43xx_d80211: Radio turned off
[   80.474120] ssb: Switching to core 0
[   80.474686] bcm43xx_d80211: DMA-32 0x0200 (RX) max used slots: 1/64
[   80.474693] ssb: Switching to core 1
[   80.501334] bcm43xx_d80211: DMA-32 0x02A0 (TX) max used slots: 0/128
[   80.503069] bcm43xx_d80211: DMA-32 0x0280 (TX) max used slots: 0/128
[   80.506349] bcm43xx_d80211: DMA-32 0x0260 (TX) max used slots: 0/128
[   80.508083] bcm43xx_d80211: DMA-32 0x0240 (TX) max used slots: 0/128
[   80.511183] bcm43xx_d80211: DMA-32 0x0220 (TX) max used slots: 2/128
[   80.512913] bcm43xx_d80211: DMA-32 0x0200 (TX) max used slots: 0/128
[   80.516856] bcm43xx_d80211: Virtual interface removed (type: 0x00000002, ID: 5, MAC: 00:14:bf:72:8f:b7)
[  102.777120] SysRq : HELP : loglevel0-8 reBoot show-all-locks(D) tErm Full kIll saK showMem Nice powerOff showPc unRaw Sync showTasks Unmount 
[  122.499744] SysRq : Show State
[  122.499829] 
[  122.499830]                                                sibling
[  122.499911]   task             PC      pid father child younger older
[  122.500057] init          S C1986B34     0     1      0     2               (NOTLB)
[  122.500322]        c1986b48 00000082 00000002 c1986b34 c1986b30 c1985aec c013565a b97955c9 
[  122.500658]        00000012 c1985aec c19855b0 00000000 c037850f 00000005 c19855b0 c03f54e0 
[  122.501037]        b994ef18 00000012 001aafd4 00000000 c19856bc c1828dc0 c0522140 c03782fd 
[  122.501424] Call Trace:
[  122.501520]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.501617]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.501711]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.501803]  [<c016f835>] sys_select+0x3f/0x1b6
[  122.501893]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.501987]  [<b7ef8410>] 0xb7ef8410
[  122.502078]  =======================
[  122.502129] migration/0   S C013565A     0     2      1             3       (L-TLB)
[  122.502410]        c1990f88 00000086 c198faec c013565a c0119078 00000001 c0634718 b9345de2 
[  122.502754]        00000012 b962fc46 00000000 c1828dd4 c198f5b0 00000001 c198f5b0 f3b8a5b0 
[  122.503140]        b963e216 00000012 0009133b 00000000 c198f6bc c1828dc0 00000001 c1990fc4 
[  122.503527] Call Trace:
[  122.503622]  [<c0119160>] migration_thread+0x143/0x278
[  122.503715]  [<c012e5bd>] kthread+0xde/0xe2
[  122.503807]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.503899]  =======================
[  122.503950] ksoftirqd/0   S C1994FA8     0     3      1             4     2 (L-TLB)
[  122.504230]        c1994fbc 00000096 00000002 c1994fa8 c1994fa4 00000078 c182974c 1b7a896e 
[  122.504573]        00000015 00000078 c182974c 00000001 b3eaf8cf 0000000a c19935b0 c03f54e0 
[  122.504960]        1b966377 00000015 00001267 00000000 c19936bc c1828dc0 c0522140 c1994fa4 
[  122.505347] Call Trace:
[  122.505441]  [<c0121887>] ksoftirqd+0xfe/0x119
[  122.505532]  [<c012e5bd>] kthread+0xde/0xe2
[  122.505622]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.505714]  =======================
[  122.505765] watchdog/0    S C1998FA8     0     4      1             5     3 (L-TLB)
[  122.506045]        c1998fbc 00000096 00000002 c1998fa8 c1998fa4 c1997ae0 00000000 61043ba3 
[  122.506389]        0000001c 00000078 c182974c 00000003 00000002 00000001 c19975b0 c03f54e0 
[  122.506776]        61045624 0000001c 0000096c 00000000 c19976bc c1828dc0 c0522140 c1830dc0 
[  122.507163] Call Trace:
[  122.507258]  [<c0141417>] watchdog+0x4b/0x64
[  122.507349]  [<c012e5bd>] kthread+0xde/0xe2
[  122.507439]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.507530]  =======================
[  122.507580] migration/1   S C19BBF74     0     5      1             6     4 (L-TLB)
[  122.507861]        c19bbf88 00000086 00000002 c19bbf74 c19bbf70 00000001 c0634718 b8f6ab12 
[  122.508204]        00000012 00000000 00000000 c1830dd4 c19ba5b0 00000001 c19ba5b0 c19895b0 
[  122.508591]        b907b92f 00000012 00024c5e 00000001 c19ba6bc c1830dc0 c0522140 c19bbfc4 
[  122.508979] Call Trace:
[  122.509073]  [<c0119160>] migration_thread+0x143/0x278
[  122.509165]  [<c012e5bd>] kthread+0xde/0xe2
[  122.509255]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.509346]  =======================
[  122.509397] ksoftirqd/1   S C19EFFA8     0     6      1             7     5 (L-TLB)
[  122.509676]        c19effbc 00000096 00000002 c19effa8 c19effa4 00000078 c183174c 67945a4f 
[  122.510021]        00000012 0000000a f3b775b0 f3b775b0 675bdf01 00000009 c19ee5b0 c19895b0 
[  122.510408]        679fbf5a 00000012 00000cc9 00000001 c19ee6bc c1830dc0 c0522140 00000246 
[  122.510795] Call Trace:
[  122.510890]  [<c0121887>] ksoftirqd+0xfe/0x119
[  122.510980]  [<c012e5bd>] kthread+0xde/0xe2
[  122.511070]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.511161]  =======================
[  122.511212] watchdog/1    S 00000002     0     7      1             8     6 (L-TLB)
[  122.511491]        c19f3fbc 00000096 00000000 00000002 c0376e09 c19f2ae0 00000000 856efc03 
[  122.511835]        0000001c 00000078 c183174c 00000000 00000002 00000009 c19f25b0 f5ebc5b0 
[  122.512221]        856f1192 0000001c 000009d0 00000001 c19f26bc c1830dc0 c0522140 c1828dc0 
[  122.512609] Call Trace:
[  122.512703]  [<c0141417>] watchdog+0x4b/0x64
[  122.512793]  [<c012e5bd>] kthread+0xde/0xe2
[  122.512883]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.512974]  =======================
[  122.513024] events/0      S 00000001     0     8      1             9     7 (L-TLB)
[  122.513304]        c1a10f80 00000082 c1a0faec 00000001 c1a0f5b0 00000000 c1a0df3c 83c45f4b 
[  122.513647]        0000001c 00000078 c182974c 00000003 00000000 0000000a c1a0f5b0 f74d05b0 
[  122.514034]        83c8467b 0000001c 000060a0 00000000 c1a0f6bc c1828dc0 c1a10f9c c1830dc0 
[  122.514421] Call Trace:
[  122.514516]  [<c012be09>] worker_thread+0x106/0x13d
[  122.514608]  [<c012e5bd>] kthread+0xde/0xe2
[  122.514697]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.514788]  =======================
[  122.514839] events/1      S 00000001     0     9      1            10     8 (L-TLB)
[  122.515118]        c199df80 00000082 c199caec 00000001 c199c5b0 00000000 c1a0ef3c 4ae18c65 
[  122.515462]        0000001c c0634718 c183174c 00000000 00000000 0000000a c199c5b0 f5ebc5b0 
[  122.515849]        4ae5aaf6 0000001c 0000673a 00000001 c199c6bc c1830dc0 c199df9c c1828dc0 
[  122.516236] Call Trace:
[  122.516330]  [<c012be09>] worker_thread+0x106/0x13d
[  122.516421]  [<c012e5bd>] kthread+0xde/0xe2
[  122.516511]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.516601]  =======================
[  122.516652] khelper       S 00000001     0    10      1            11     9 (L-TLB)
[  122.516932]        c1a16f80 00000082 c1a15aec 00000001 c1a155b0 00000000 c1a13f3c d4dbc11e 
[  122.517276]        0000000e c0634718 00000046 00000000 00000000 0000000a c1a155b0 f3b5f5b0 
[  122.517663]        d4ece186 0000000e 0005e6d1 00000001 c1a156bc c1830dc0 c1a16f9c c0134ddc 
[  122.518050] Call Trace:
[  122.518145]  [<c012be09>] worker_thread+0x106/0x13d
[  122.518236]  [<c012e5bd>] kthread+0xde/0xe2
[  122.518326]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.518417]  =======================
[  122.518468] kthread       S C19B7F6C     0    11      1    49     848    10 (L-TLB)
[  122.518750]        c19b7f80 00000082 00000002 c19b7f6c c19b7f68 00000000 c19b4f3c b9345de2 
[  122.519094]        00000012 c0634718 00000046 00000000 00000000 00000001 c19b65b0 c03f54e0 
[  122.519481]        b94f2606 00000012 00033bce 00000000 c19b66bc c1828dc0 c0522140 c0134ddc 
[  122.519868] Call Trace:
[  122.519963]  [<c012be09>] worker_thread+0x106/0x13d
[  122.520056]  [<c012e5bd>] kthread+0xde/0xe2
[  122.520146]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.520237]  =======================
[  122.520288] kblockd/0     S 00000001     0    49     11            50       (L-TLB)
[  122.520568]        c1a5cf80 00000082 c1a5baec 00000001 c1a5b5b0 00000000 c1b3af3c fe004385 
[  122.520912]        0000001b c0634718 00000046 00000000 00000000 0000000a c1a5b5b0 c1a865b0 
[  122.521299]        fe14da0f 0000001b 000067a0 00000000 c1a5b6bc c1828dc0 c1a5cf9c c0134ddc 
[  122.521687] Call Trace:
[  122.521783]  [<c012be09>] worker_thread+0x106/0x13d
[  122.521874]  [<c012e5bd>] kthread+0xde/0xe2
[  122.521964]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.522055]  =======================
[  122.522106] kblockd/1     S 00000001     0    50     11            51    49 (L-TLB)
[  122.522386]        c1a59f80 00000082 c1a58aec 00000001 c1a585b0 00000000 c1b3bf3c 85eb84c4 
[  122.522729]        00000011 c0634718 00000046 00000000 00000000 0000000a c1a585b0 c1a865b0 
[  122.523116]        8601ed80 00000011 0000c808 00000001 c1a586bc c1830dc0 c1a59f9c c0134ddc 
[  122.523503] Call Trace:
[  122.523597]  [<c012be09>] worker_thread+0x106/0x13d
[  122.523688]  [<c012e5bd>] kthread+0xde/0xe2
[  122.523778]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.523869]  =======================
[  122.523919] kacpid        S C1B3DF6C     0    51     11           130    50 (L-TLB)
[  122.524199]        c1b3df80 00000082 00000002 c1b3df6c c1b3df68 00000000 c1b43f3c 0b71d04d 
[  122.524543]        00000000 c0634718 00000046 00000000 00000000 00000007 c1b3c5b0 c19895b0 
[  122.524929]        0b7d603f 00000000 00001614 00000001 c1b3c6bc c1830dc0 c0522140 c0134ddc 
[  122.525316] Call Trace:
[  122.525410]  [<c012be09>] worker_thread+0x106/0x13d
[  122.525502]  [<c012e5bd>] kthread+0xde/0xe2
[  122.525591]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.526390]  =======================
[  122.526441] ata/0         S 00000000     0   130     11           131    51 (L-TLB)
[  122.526721]        c1a62f80 00000082 c1a615b0 00000000 f7c00fec 00000000 f7cf4f3c 162216c4 
[  122.527064]        00000000 c0634718 00000046 00000002 00000000 00000008 c1a615b0 c19b65b0 
[  122.527451]        162ae6ab 00000000 00002f1e 00000000 c1a616bc c1828dc0 c1a62f9c c0134ddc 
[  122.527838] Call Trace:
[  122.527933]  [<c012be09>] worker_thread+0x106/0x13d
[  122.528024]  [<c012e5bd>] kthread+0xde/0xe2
[  122.528113]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.528204]  =======================
[  122.528255] ata/1         S F7C1CF6C     0   131     11           132   130 (L-TLB)
[  122.528535]        f7c1cf80 00000082 00000002 f7c1cf6c f7c1cf68 00000000 f7cf5f3c 162201da 
[  122.528879]        00000000 c0634718 00000046 00000000 00000000 00000008 f7c1f5b0 c19895b0 
[  122.529265]        162c190f 00000000 0000181e 00000001 f7c1f6bc c1830dc0 c0522140 c0134ddc 
[  122.529652] Call Trace:
[  122.529748]  [<c012be09>] worker_thread+0x106/0x13d
[  122.529839]  [<c012e5bd>] kthread+0xde/0xe2
[  122.529928]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.530019]  =======================
[  122.530070] ata_aux       S 00000000     0   132     11           133   131 (L-TLB)
[  122.530350]        c1a84f80 00000082 c1a645b0 00000000 c1bcffec 00000000 f7cf6f3c 162201da 
[  122.530694]        00000000 c0634718 00000046 00000000 00000000 00000008 c1a645b0 c19855b0 
[  122.531080]        162dbb12 00000000 00001459 00000001 c1a646bc c1830dc0 c1a84f9c c0134ddc 
[  122.531467] Call Trace:
[  122.531562]  [<c012be09>] worker_thread+0x106/0x13d
[  122.531653]  [<c012e5bd>] kthread+0xde/0xe2
[  122.531743]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.531833]  =======================
[  122.531884] kseriod       S 00000006     0   133     11           161   132 (L-TLB)
[  122.532164]        f7c0cf8c 00000096 c013565a 00000006 00000000 c04122d4 f7c195b0 3c6b87c9 
[  122.532507]        00000004 00000078 c182974c 00000000 c04122d4 0000000a f7c195b0 c1a9f5b0 
[  122.532894]        3c9a15c2 00000004 000214fc 00000000 f7c196bc c1828dc0 00000292 c1830dc0 
[  122.533281] Call Trace:
[  122.533375]  [<c02a1347>] serio_thread+0xb1/0x2fa
[  122.533470]  [<c012e5bd>] kthread+0xde/0xe2
[  122.533561]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.533652]  =======================
[  122.533704] rt-test-0     S C1AA0FC4     0   161     11           163   133 (L-TLB)
[  122.533984]        c1aa0fb8 00000082 c011fef3 c1aa0fc4 c0376e6d 00000000 00000002 1ca9f927 
[  122.534328]        00000000 f7d18fec c1a955b0 00000000 c1a955b0 00000009 c1a955b0 c19855b0 
[  122.534715]        1cab8449 00000000 0000104a 00000000 c1a956bc c1828dc0 c0134ddc c1986ee8 
[  122.535102] Call Trace:
[  122.535196]  [<c013a931>] test_func+0x7f/0xa6
[  122.535288]  [<c012e5bd>] kthread+0xde/0xe2
[  122.535378]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.535469]  =======================
[  122.535520] rt-test-1     S C1AB3FC4     0   163     11           165   161 (L-TLB)
[  122.535801]        c1ab3fb8 00000082 c011fef3 c1ab3fc4 c0376e6d 00000000 00000002 1c8f2cf7 
[  122.536144]        00000000 c1bc7fec c1abd5b0 00000000 c1abd5b0 00000007 c1abd5b0 c19855b0 
[  122.536531]        1cb35da3 00000000 00000e06 00000001 c1abd6bc c1830dc0 c0134ddc c1986ee8 
[  122.536918] Call Trace:
[  122.537012]  [<c013a931>] test_func+0x7f/0xa6
[  122.537103]  [<c012e5bd>] kthread+0xde/0xe2
[  122.537193]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.537284]  =======================
[  122.537334] rt-test-2     S C1A9AFC4     0   165     11           167   163 (L-TLB)
[  122.537615]        c1a9afb8 00000082 c011fef3 c1a9afc4 c0376e6d 00000000 00000002 1ca9f927 
[  122.537959]        00000000 f7d89fec c1a9c5b0 00000000 c1a9c5b0 00000007 c1a9c5b0 c19855b0 
[  122.538346]        1cbb64c0 00000000 00000bde 00000000 c1a9c6bc c1828dc0 c0134ddc c1986ee8 
[  122.538733] Call Trace:
[  122.538828]  [<c013a931>] test_func+0x7f/0xa6
[  122.538918]  [<c012e5bd>] kthread+0xde/0xe2
[  122.539008]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.539099]  =======================
[  122.539150] rt-test-3     S C1AC5FC4     0   167     11           169   165 (L-TLB)
[  122.539430]        c1ac5fb8 00000082 c011fef3 c1ac5fc4 c0376e6d 00000000 00000002 1c8f2cf7 
[  122.539774]        00000000 c1bc0fec c1ac45b0 00000000 c1ac45b0 00000006 c1ac45b0 c19855b0 
[  122.540161]        1cc3223a 00000000 00000cf5 00000001 c1ac46bc c1830dc0 c0134ddc c1986ee8 
[  122.540548] Call Trace:
[  122.540643]  [<c013a931>] test_func+0x7f/0xa6
[  122.540733]  [<c012e5bd>] kthread+0xde/0xe2
[  122.540823]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.540914]  =======================
[  122.540964] rt-test-4     S C1AD2FC4     0   169     11           171   167 (L-TLB)
[  122.541244]        c1ad2fb8 00000082 c011fef3 c1ad2fc4 c0376e6d 00000000 00000002 1ca9f927 
[  122.541588]        00000000 f7d8cfec c1aa95b0 00000000 c1aa95b0 00000006 c1aa95b0 c19855b0 
[  122.541975]        1ccb21d0 00000000 00000d2d 00000000 c1aa96bc c1828dc0 c0134ddc c1986ee8 
[  122.542362] Call Trace:
[  122.542457]  [<c013a931>] test_func+0x7f/0xa6
[  122.542547]  [<c012e5bd>] kthread+0xde/0xe2
[  122.542638]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.542729]  =======================
[  122.542779] rt-test-5     S C1A90FA4     0   171     11           173   169 (L-TLB)
[  122.543059]        c1a90fb8 00000082 00000002 c1a90fa4 c1a90fa0 00000000 00000002 1ccc1c13 
[  122.543403]        00000000 c1bbafec c1a8f5b0 00000001 c1a8f5b0 00000005 c1a8f5b0 c19895b0 
[  122.543790]        1cd9f401 00000000 00000df5 00000001 c1a8f6bc c1830dc0 c0522140 c1986ee8 
[  122.544177] Call Trace:
[  122.544272]  [<c013a931>] test_func+0x7f/0xa6
[  122.544362]  [<c012e5bd>] kthread+0xde/0xe2
[  122.544452]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.544543]  =======================
[  122.544594] rt-test-6     S C1AA8FA4     0   173     11           175   171 (L-TLB)
[  122.544874]        c1aa8fb8 00000082 00000002 c1aa8fa4 c1aa8fa0 00000000 00000002 1cda9891 
[  122.545218]        00000000 f7daffec c1ace5b0 00000001 c1ace5b0 00000005 c1ace5b0 c03f54e0 
[  122.545605]        1ce1e90e 00000000 00000e7a 00000000 c1ace6bc c1828dc0 c0522140 c1986ee8 
[  122.545992] Call Trace:
[  122.546087]  [<c013a931>] test_func+0x7f/0xa6
[  122.546177]  [<c012e5bd>] kthread+0xde/0xe2
[  122.546267]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.546358]  =======================
[  122.546409] rt-test-7     S C1A8AFA4     0   175     11           177   173 (L-TLB)
[  122.546689]        c1a8afb8 00000082 00000002 c1a8afa4 c1a8afa0 00000000 00000002 1ce678f0 
[  122.547033]        00000000 c1b77fec c1a895b0 00000001 c1a895b0 00000004 c1a895b0 c19895b0 
[  122.547419]        1ce9ac6d 00000000 00000df7 00000001 c1a896bc c1830dc0 c0522140 c1986ee8 
[  122.547807] Call Trace:
[  122.547901]  [<c013a931>] test_func+0x7f/0xa6
[  122.547991]  [<c012e5bd>] kthread+0xde/0xe2
[  122.548081]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.548172]  =======================
[  122.548223] pdflush       S C1A5FF8C     0   177     11           178   175 (L-TLB)
[  122.548503]        c1a5ffa0 00000086 00000002 c1a5ff8c c1a5ff88 c1828dc0 00000296 1cda9891 
[  122.548847]        00000000 c0379c31 00000000 c03fc7f4 c1a555b0 00000003 c1a555b0 c03f54e0 
[  122.549234]        1cf11be2 00000000 00006983 00000000 c1a556bc c1828dc0 c0522140 c014ac53 
[  122.549621] Call Trace:
[  122.549716]  [<c014acf8>] pdflush+0xa5/0x1bd
[  122.549807]  [<c012e5bd>] kthread+0xde/0xe2
[  122.549897]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.549988]  =======================
[  122.550039] pdflush       S C1A87F8C     0   178     11           179   177 (L-TLB)
[  122.550318]        c1a87fa0 00000086 00000002 c1a87f8c c1a87f88 00000296 c0557a00 fe004385 
[  122.550662]        0000001b c0557a00 00000000 c03fc7f4 c1a865b0 0000000a c1a865b0 c03f54e0 
[  122.551049]        fe27c537 0000001b 00045774 00000000 c1a866bc c1828dc0 c0522140 c014ac53 
[  122.551436] Call Trace:
[  122.551531]  [<c014acf8>] pdflush+0xa5/0x1bd
[  122.552329]  [<c012e5bd>] kthread+0xde/0xe2
[  122.552419]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.552510]  =======================
[  122.552561] kswapd0       S C1A56F28     0   179     11           180   178 (L-TLB)
[  122.552841]        c1a56f3c 00000092 00000002 c1a56f28 c1a56f24 c03fc760 c1a515b0 1cda9891 
[  122.553184]        00000000 00000046 00000000 00000000 c03fc760 00000002 c1a515b0 c03f54e0 
[  122.553571]        1d003de2 00000000 000018ce 00000000 c1a516bc c1828dc0 c0522140 c0134ddc 
[  122.553958] Call Trace:
[  122.554053]  [<c014db26>] kswapd+0x3fd/0x421
[  122.554144]  [<c012e5bd>] kthread+0xde/0xe2
[  122.554234]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.554325]  =======================
[  122.554376] aio/0         S 00000000     0   180     11           181   179 (L-TLB)
[  122.554656]        c1aadf80 00000082 c1ab15b0 00000000 f7da8fec 00000000 f7404f3c 1cda9891 
[  122.554999]        00000000 c0634718 00000046 00000002 00000000 00000001 c1ab15b0 c19b65b0 
[  122.555386]        1d0198a4 00000000 00002cbc 00000000 c1ab16bc c1828dc0 c1aadf9c c0134ddc 
[  122.555772] Call Trace:
[  122.555867]  [<c012be09>] worker_thread+0x106/0x13d
[  122.555958]  [<c012e5bd>] kthread+0xde/0xe2
[  122.556048]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.556138]  =======================
[  122.556189] aio/1         S C1A52F6C     0   181     11           791   180 (L-TLB)
[  122.556469]        c1a52f80 00000082 00000002 c1a52f6c c1a52f68 00000000 f7405f3c 1ce678f0 
[  122.556813]        00000000 c0634718 00000046 00000000 00000000 00000001 c1a4e5b0 c19895b0 
[  122.557199]        1d02fb52 00000000 00001789 00000001 c1a4e6bc c1830dc0 c0522140 c0134ddc 
[  122.557586] Call Trace:
[  122.557681]  [<c012be09>] worker_thread+0x106/0x13d
[  122.557773]  [<c012e5bd>] kthread+0xde/0xe2
[  122.557863]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.557954]  =======================
[  122.558004] scsi_eh_0     S F772CF50     0   791     11           792   181 (L-TLB)
[  122.558285]        f772cf64 00000086 00000002 f772cf50 f772cf4c 00000046 00000000 a15f7aee 
[  122.558628]        00000000 00000000 f74df5b0 c0379c47 c19fc000 0000000a f74df5b0 c03f54e0 
[  122.559015]        a1676a28 00000000 00015c2f 00000000 f74df6bc c1828dc0 c0522140 00000000 
[  122.559401] Call Trace:
[  122.559496]  [<c0281301>] scsi_error_handler+0x43/0xb4c
[  122.559589]  [<c012e5bd>] kthread+0xde/0xe2
[  122.559679]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.559770]  =======================
[  122.559820] scsi_eh_1     S F74D4F50     0   792     11           850   791 (L-TLB)
[  122.560100]        f74d4f64 00000086 00000002 f74d4f50 f74d4f4c 00000046 00000000 ab894c9f 
[  122.560444]        00000000 00000000 f761f5b0 c0379c47 f72d4000 00000009 f761f5b0 c03f54e0 
[  122.560831]        ab89af02 00000000 00003a88 00000000 f761f6bc c1828dc0 c0522140 00000000 
[  122.561218] Call Trace:
[  122.561313]  [<c0281301>] scsi_error_handler+0x43/0xb4c
[  122.561404]  [<c012e5bd>] kthread+0xde/0xe2
[  122.561494]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.561585]  =======================
[  122.561636] kirqd         S F7540F44     0   848      1           859    11 (L-TLB)
[  122.561916]        f7540f58 00000086 00000002 f7540f44 f7540f40 00000000 f74e45b0 b87ff3f2 
[  122.562259]        0000001b f74e45b0 f74e4ae0 00000000 f74e45b0 0000000a f74e45b0 c03f54e0 
[  122.562646]        b8805061 0000001b 00004180 00000000 f74e46bc c1828dc0 c0522140 c0379c31 
[  122.563033] Call Trace:
[  122.563127]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.563219]  [<c01109e6>] balanced_irq+0x67/0x567
[  122.563312]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.563403]  =======================
[  122.563454] reiserfs/0    S F74DAF6C     0   850     11           851   792 (L-TLB)
[  122.563734]        f74daf80 00000082 00000002 f74daf6c f74daf68 00000000 f6f6ef3c 03f39406 
[  122.564078]        0000001c c0634718 00000046 00000000 00000000 0000000a f74d65b0 c03f54e0 
[  122.564465]        03f605c2 0000001c 00005baa 00000000 f74d66bc c1828dc0 c0522140 c0134ddc 
[  122.564852] Call Trace:
[  122.564946]  [<c012be09>] worker_thread+0x106/0x13d
[  122.565037]  [<c012e5bd>] kthread+0xde/0xe2
[  122.565127]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.565218]  =======================
[  122.565268] reiserfs/1    S F74AEF6C     0   851     11          1818   850 (L-TLB)
[  122.565548]        f74aef80 00000082 00000002 f74aef6c f74aef68 00000000 f6f6ff3c 8bded52a 
[  122.565893]        00000011 c0634718 00000046 00000000 00000000 0000000a f772b5b0 c19895b0 
[  122.566279]        8be0f5a4 00000011 000055e5 00000001 f772b6bc c1830dc0 c0522140 c0134ddc 
[  122.566666] Call Trace:
[  122.566761]  [<c012be09>] worker_thread+0x106/0x13d
[  122.566852]  [<c012e5bd>] kthread+0xde/0xe2
[  122.566942]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.567033]  =======================
[  122.567084] logd          S F75595B0     0   859      1          1047   848 (NOTLB)
[  122.567364]        c1a47b48 00000082 f75595b0 f75595b0 f7559aec c013565a c012e8b4 a13b57b0 
[  122.567708]        0000000c f7559b14 c182974c 00000002 00000000 0000000a f75595b0 c19855b0 
[  122.568095]        a15b976e 0000000c 00146153 00000000 f75596bc c1828dc0 00000000 c1830dc0 
[  122.568482] Call Trace:
[  122.568576]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.568668]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.568758]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.568849]  [<c016f835>] sys_select+0x3f/0x1b6
[  122.568939]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.569031]  [<b7f31410>] 0xb7f31410
[  122.569120]  =======================
[  122.569170] udevd         S C0189922     0  1047      1          2300   859 (NOTLB)
[  122.569451]        c1ae8b48 00000082 c013565a c0189922 f77225b0 f7722aec c013565a 6b85fe83 
[  122.569795]        0000000f f7722aec f77225b0 00000000 c037850f 00000002 f77225b0 f3b775b0 
[  122.570182]        6bbda949 0000000f 0033a8e3 00000000 f77226bc c1828dc0 f77225b0 c03782fd 
[  122.570569] Call Trace:
[  122.570664]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.570756]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.570846]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.570937]  [<c016f835>] sys_select+0x3f/0x1b6
[  122.571026]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.571118]  [<b7f55410>] 0xb7f55410
[  122.571207]  =======================
[  122.571258] ksuspend_usbd S F5AD6F6C     0  1818     11          1819   851 (L-TLB)
[  122.571538]        f5ad6f80 00000082 00000002 f5ad6f6c f5ad6f68 00000000 f6848f3c d612673f 
[  122.571882]        0000000c c0634718 00000046 00000000 00000000 00000007 f5ad55b0 c19895b0 
[  122.572268]        d618f11f 0000000c 00014068 00000001 f5ad56bc c1830dc0 c0522140 c0134ddc 
[  122.572655] Call Trace:
[  122.572750]  [<c012be09>] worker_thread+0x106/0x13d
[  122.572841]  [<c012e5bd>] kthread+0xde/0xe2
[  122.572931]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.573022]  =======================
[  122.573072] khubd         S C013565A     0  1819     11          1887  1818 (L-TLB)
[  122.573353]        f5adcf38 00000086 f5adfaec c013565a 00000000 f899c9d4 f5adf5b0 31877fa3 
[  122.573697]        00000004 00000076 c182974c 00000000 f899c9d4 0000000a f5adf5b0 f74d95b0 
[  122.574084]        31932dee 00000004 00004f8b 00000000 f5adf6bc c1828dc0 00000000 c1830dc0 
[  122.574471] Call Trace:
[  122.574566]  [<f8983266>] hub_thread+0x52a/0xc72 [usbcore]
[  122.574680]  [<c012e5bd>] kthread+0xde/0xe2
[  122.574770]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.574861]  =======================
[  122.574912] khpsbpkt      S 00000000     0  1887     11          1902  1819 (L-TLB)
[  122.575192]        f74c7fc0 00000082 00000000 00000000 c1bff5b0 00000000 f8a81640 81b0d1cf 
[  122.575536]        00000004 c1bff5b0 00000046 00000001 c1bff5b0 0000000a c1bff5b0 f767c5b0 
[  122.575922]        81cc46cf 00000004 00019f44 00000000 c1bff6bc c1828dc0 f8a8162c 00000286 
[  122.576309] Call Trace:
[  122.576404]  [<f8a3c606>] hpsbpkt_thread+0x85/0x87 [ieee1394]
[  122.576509]  [<c012e5bd>] kthread+0xde/0xe2
[  122.576600]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.576691]  =======================
[  122.576741] kgameportd    S 00000006     0  1902     11          1956  1887 (L-TLB)
[  122.577729]        f5f85f74 00000086 c013565a 00000006 00000000 f89f2f94 f74b15b0 0ccd8a37 
[  122.578073]        00000004 00000076 c182974c 00000001 f89f2f94 00000004 f74b15b0 f767c5b0 
[  122.578459]        0cfd71eb 00000004 00017f35 00000000 f74b16bc c1828dc0 0000005b c1830dc0 
[  122.578846] Call Trace:
[  122.578941]  [<f89f0aa5>] gameport_thread+0xb1/0x41d [gameport]
[  122.579042]  [<c012e5bd>] kthread+0xde/0xe2
[  122.579132]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.579223]  =======================
[  122.579274] knodemgrd_0   S 00000000     0  1956     11          1966  1902 (L-TLB)
[  122.579554]        f5a6ff5c 00000092 000000b7 00000000 0000000f 0130ec80 00000000 71066bec 
[  122.579897]        00000004 00000076 c183174c 00000000 00000000 0000000a f5aa65b0 f761c5b0 
[  122.580284]        7118757b 00000004 00b02de1 00000001 f5aa66bc c1830dc0 c1accf3c c1828dc0 
[  122.580671] Call Trace:
[  122.580765]  [<f8a4193f>] nodemgr_host_thread+0x4fa/0xa2c [ieee1394]
[  122.580885]  [<c012e5bd>] kthread+0xde/0xe2
[  122.580976]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.581066]  =======================
[  122.581117] knodemgrd_1   S F767C5B0     0  1966     11          1981  1956 (L-TLB)
[  122.581398]        c1accf5c 00000092 00000000 f767c5b0 c03782fd 00000246 f55aaa54 822a0c7c 
[  122.581742]        00000004 00000074 c182974c 00000000 f767cae0 00000009 f767c5b0 f77225b0 
[  122.582129]        82592efc 00000004 006f86e7 00000000 f767c6bc c1828dc0 f55f4000 c1830dc0 
[  122.582516] Call Trace:
[  122.582611]  [<f8a4193f>] nodemgr_host_thread+0x4fa/0xa2c [ieee1394]
[  122.582729]  [<c012e5bd>] kthread+0xde/0xe2
[  122.582820]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.582911]  =======================
[  122.582962] kpsmoused     S F74D7F6C     0  1981     11          2319  1966 (L-TLB)
[  122.583242]        f74d7f80 00000082 00000002 f74d7f6c f74d7f68 00000000 f553bf3c 38d60be2 
[  122.583585]        00000004 c0634718 00000046 00000000 00000000 00000001 f74e25b0 c03f54e0 
[  122.583972]        38dd2235 00000004 000022a0 00000000 f74e26bc c1828dc0 c0522140 c0134ddc 
[  122.584359] Call Trace:
[  122.584454]  [<c012be09>] worker_thread+0x106/0x13d
[  122.584545]  [<c012e5bd>] kthread+0xde/0xe2
[  122.584634]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.584725]  =======================
[  122.584776] dhclient3     S C1AC1B34     0  2300      1          2313  1047 (NOTLB)
[  122.585056]        c1ac1b48 00000082 00000002 c1ac1b34 c1ac1b30 00000000 c1ad45b0 a892ea39 
[  122.585399]        00000005 c1ad45b0 c1ad4ae0 00000000 c1ad45b0 00000006 c1ad45b0 c19895b0 
[  122.585787]        a893ea9e 00000005 0000e063 00000001 c1ad46bc c1830dc0 c0522140 c0379c31 
[  122.586174] Call Trace:
[  122.586268]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.586361]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.586451]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.586542]  [<c016f8da>] sys_select+0xe4/0x1b6
[  122.586632]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.586724]  [<b7fcf410>] 0xb7fcf410
[  122.586812]  =======================
[  122.586863] portmap       S F5A6B5B0     0  2313      1          2321  2300 (NOTLB)
[  122.587144]        f7623bf8 00000086 f5a6b5b0 f5a6b5b0 f5a6baec c013565a c012e8b4 4db5bebb 
[  122.587488]        0000000c f5a6b5b0 c183174c 00000000 00000000 0000000a f5a6b5b0 f3ac75b0 
[  122.587875]        4de255e2 0000000c 0004fec6 00000001 f5a6b6bc c1830dc0 00000000 c1828dc0 
[  122.588262] Call Trace:
[  122.588356]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.588448]  [<c016e8ee>] do_sys_poll+0x2d5/0x3f8
[  122.588540]  [<c016ea3c>] sys_poll+0x2b/0x39
[  122.588630]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.588722]  [<b7f37410>] 0xb7f37410
[  122.588811]  =======================
[  122.588861] rpciod/0      S 00000000     0  2319     11          2320  1981 (L-TLB)
[  122.589142]        f551ff80 00000082 f5ab05b0 00000000 f5a67fec 00000000 f5ecef3c f8129e2b 
[  122.589486]        00000005 c0634718 00000046 00000002 00000000 00000009 f5ab05b0 c19b65b0 
[  122.589873]        f81feaea 00000005 000057a8 00000000 f5ab06bc c1828dc0 f551ff9c c0134ddc 
[  122.590260] Call Trace:
[  122.590355]  [<c012be09>] worker_thread+0x106/0x13d
[  122.590446]  [<c012e5bd>] kthread+0xde/0xe2
[  122.590536]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.590627]  =======================
[  122.590678] rpciod/1      S F59FBF6C     0  2320     11                2319 (L-TLB)
[  122.590958]        f59fbf80 00000082 00000002 f59fbf6c f59fbf68 00000000 f56a4f3c f8138c84 
[  122.591302]        00000005 c0634718 00000046 00000000 00000000 00000008 f5f595b0 c19895b0 
[  122.591688]        f828b2df 00000005 00001a22 00000001 f5f596bc c1830dc0 c0522140 c0134ddc 
[  122.592075] Call Trace:
[  122.592169]  [<c012be09>] worker_thread+0x106/0x13d
[  122.592261]  [<c012e5bd>] kthread+0xde/0xe2
[  122.592350]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.592441]  =======================
[  122.592492] lockd         S F7C22F40     0  2321      1          2825  2313 (L-TLB)
[  122.592772]        f7c22f54 00000082 00000002 f7c22f40 f7c22f3c 00000002 c05c8ba0 2482b881 
[  122.593116]        0000000c f7550b14 c013565a 00000006 00000003 0000000a f75505b0 c19895b0 
[  122.593502]        24a20882 0000000c 00008bb0 00000001 f75506bc c1830dc0 c0522140 00000000 
[  122.593889] Call Trace:
[  122.593984]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.594076]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.594168]  [<c01ec793>] lockd+0xe3/0x240
[  122.594261]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.594352]  =======================
[  122.594403] login         S F4203F28     0  2825      1  3720    2826  2321 (NOTLB)
[  122.594685]        f4203f3c 00000092 00000002 f4203f28 f4203f24 00000000 f5f91e84 093edcb0 
[  122.595029]        0000000d c0634718 00000000 c0483c14 c1a5e5b0 00000008 c1a5e5b0 c03f54e0 
[  122.595416]        0959ba53 0000000d 0000c359 00000000 c1a5e6bc c1828dc0 c0522140 c011e6ad 
[  122.595804] Call Trace:
[  122.595899]  [<c011ed25>] do_wait+0x6e1/0xb31
[  122.595991]  [<c011f1a6>] sys_wait4+0x31/0x35
[  122.596081]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.596173]  [<b7f4c410>] 0xb7f4c410
[  122.596262]  =======================
[  122.596313] login         S C013565A     0  2826      1  3808    2827  2825 (NOTLB)
[  122.596594]        c1ad5f3c 00000092 f7566aec c013565a c011e6ad 00000000 f5e32e84 548afcd3 
[  122.596938]        00000010 00000078 c182974c 00000001 f75665b0 00000008 f75665b0 f76845b0 
[  122.597325]        5497c5e6 00000010 00053e68 00000000 f75666bc c1828dc0 00000000 c1830dc0 
[  122.597712] Call Trace:
[  122.597807]  [<c011ed25>] do_wait+0x6e1/0xb31
[  122.597899]  [<c011f1a6>] sys_wait4+0x31/0x35
[  122.597989]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.598081]  [<b7f77410>] 0xb7f77410
[  122.598169]  =======================
[  122.598220] getty         S F7569EB4     0  2827      1          2828  2826 (NOTLB)
[  122.598501]        f7569ec8 00000086 00000002 f7569eb4 f7569eb0 00000002 c05ca7c0 4fbf0418 
[  122.598845]        00000009 c1a9fb14 c013565a 00000006 00000003 00000007 c1a9f5b0 c19895b0 
[  122.599232]        4fc89fd3 00000009 00097ae7 00000001 c1a9f6bc c1830dc0 c0522140 00000000 
[  122.599619] Call Trace:
[  122.599713]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.599805]  [<c02495cd>] read_chan+0x1d0/0x613
[  122.599898]  [<c024624f>] tty_read+0x78/0xbe
[  122.599988]  [<c0163858>] vfs_read+0x89/0x145
[  122.600080]  [<c0163d0e>] sys_read+0x41/0x6a
[  122.600170]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.600262]  [<b7f60410>] 0xb7f60410
[  122.600350]  =======================
[  122.600401] getty         S F74A95B0     0  2828      1          2829  2827 (NOTLB)
[  122.600681]        c1a73ec8 00000086 000001df f74a95b0 f74a9b14 00000002 c05ca7c0 517247d4 
[  122.601025]        00000009 f74a9b14 c013565a 00000000 00000003 00000007 f74a95b0 f5a5d5b0 
[  122.601412]        5187ea91 00000009 000f9900 00000000 f74a96bc c1828dc0 00000046 00000000 
[  122.601799] Call Trace:
[  122.601894]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.601987]  [<c02495cd>] read_chan+0x1d0/0x613
[  122.602079]  [<c024624f>] tty_read+0x78/0xbe
[  122.602169]  [<c0163858>] vfs_read+0x89/0x145
[  122.602260]  [<c0163d0e>] sys_read+0x41/0x6a
[  122.603056]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.603148]  [<b7fc0410>] 0xb7fc0410
[  122.603236]  =======================
[  122.603287] getty         S F59DDEB4     0  2829      1          2830  2828 (NOTLB)
[  122.603568]        f59ddec8 00000086 00000002 f59ddeb4 f59ddeb0 00000002 c012e8b4 4c69f7e1 
[  122.603912]        00000009 f761cb14 c013565a c012e8b4 00000003 00000007 f761c5b0 c19895b0 
[  122.604299]        4c7f00a6 00000009 0014ec90 00000001 f761c6bc c1830dc0 c0522140 00000000 
[  122.604686] Call Trace:
[  122.604781]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.604872]  [<c02495cd>] read_chan+0x1d0/0x613
[  122.604964]  [<c024624f>] tty_read+0x78/0xbe
[  122.605053]  [<c0163858>] vfs_read+0x89/0x145
[  122.605144]  [<c0163d0e>] sys_read+0x41/0x6a
[  122.605233]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.605325]  [<b7f8e410>] 0xb7f8e410
[  122.605414]  =======================
[  122.605464] getty         S F76195B0     0  2830      1          3053  2829 (NOTLB)
[  122.605745]        f4231ec8 00000086 000001df f76195b0 f7619b14 00000002 c05ca7c0 52206c78 
[  122.606090]        00000009 f7619b14 c182974c 00000000 00000003 00000007 f76195b0 f755c5b0 
[  122.606477]        523bcac0 00000009 00197682 00000000 f76196bc c1828dc0 00000046 c1830dc0 
[  122.606864] Call Trace:
[  122.606958]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.607050]  [<c02495cd>] read_chan+0x1d0/0x613
[  122.607141]  [<c024624f>] tty_read+0x78/0xbe
[  122.607231]  [<c0163858>] vfs_read+0x89/0x145
[  122.607321]  [<c0163d0e>] sys_read+0x41/0x6a
[  122.607410]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.607502]  [<b7f8e410>] 0xb7f8e410
[  122.607591]  =======================
[  122.607642] acpid         S F7787AEC     0  3053      1          3171  2830 (NOTLB)
[  122.607923]        f562bbf8 00000086 f77875b0 f7787aec c013565a c012e8b4 f77875b0 f416843b 
[  122.608267]        0000000a 00000078 c182974c 00000000 f6fe8d9c 00000009 f77875b0 f49965b0 
[  122.608654]        f4333f90 0000000a 00178d42 00000000 f77876bc c1828dc0 f77875b0 c1830dc0 
[  122.609041] Call Trace:
[  122.609135]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.609227]  [<c016e8ee>] do_sys_poll+0x2d5/0x3f8
[  122.609318]  [<c016ea3c>] sys_poll+0x2b/0x39
[  122.609408]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.609500]  [<b7fd3410>] 0xb7fd3410
[  122.609589]  =======================
[  122.609640] syslogd       S F76845B0     0  3171      1          3203  3053 (NOTLB)
[  122.609920]        f5a5eb48 00000082 f76845b0 f76845b0 f7684aec c013565a c012e8b4 ee19d8b2 
[  122.610264]        00000017 00000078 c182974c 00000000 00000000 0000000a f76845b0 f764c5b0 
[  122.610651]        ee325d29 00000017 00115bb2 00000000 f76846bc c1828dc0 00000000 c1830dc0 
[  122.611038] Call Trace:
[  122.611133]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.611224]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.611314]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.611405]  [<c016f835>] sys_select+0x3f/0x1b6
[  122.611495]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.611587]  [<b7f0c410>] 0xb7f0c410
[  122.611676]  =======================
[  122.611726] dd            R running     0  3203      1          3205  3171 (NOTLB)
[  122.612006] klogd         S F551DE4C     0  3205      1          3215  3203 (NOTLB)
[  122.612286]        f551de60 00000086 00000002 f551de4c f551de48 f58d9e0c f764c5b0 ee19d8b2 
[  122.612631]        00000017 00000046 00000000 f764c5b0 f764cae0 00000009 f764c5b0 c03f54e0 
[  122.613017]        ee32a544 00000017 0000481b 00000000 f764c6bc c1828dc0 c0522140 f425ce40 
[  122.613404] Call Trace:
[  122.613499]  [<c0168f37>] pipe_wait+0x56/0x79
[  122.613590]  [<c0169580>] pipe_read+0xda/0x3fa
[  122.613681]  [<c016302f>] do_sync_read+0xd5/0x111
[  122.613772]  [<c0163858>] vfs_read+0x89/0x145
[  122.613862]  [<c0163d0e>] sys_read+0x41/0x6a
[  122.613951]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.614043]  [<b7f83410>] 0xb7f83410
[  122.614131]  =======================
[  122.614182] kdm           S F5B51B34     0  3215      1          3255  3205 (NOTLB)
[  122.614462]        f5b51b48 00000082 00000002 f5b51b34 f5b51b30 c012e8b4 c012e8b4 861f4f98 
[  122.614806]        0000000a 00000078 00000000 00000000 f62d4d9c 00000009 f55205b0 c19895b0 
[  122.615193]        86571504 0000000a 00117915 00000001 f55206bc c1830dc0 c0522140 f5520ae0 
[  122.615580] Call Trace:
[  122.615675]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.615766]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.615856]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.615947]  [<c016f835>] sys_select+0x3f/0x1b6
[  122.616037]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.616128]  [<b7fde410>] 0xb7fde410
[  122.616217]  =======================
[  122.616267] cupsd         S F5521B34     0  3255      1          3278  3215 (NOTLB)
[  122.616548]        f5521b48 00000082 00000002 f5521b34 f5521b30 c013565a c012e8b4 459e78b3 
[  122.616891]        0000000a 00000000 00000000 00000000 00000000 00000007 c1a925b0 c19895b0 
[  122.617277]        459fc8dc 0000000a 0000a90c 00000001 c1a926bc c1830dc0 c0522140 c1a925b0 
[  122.617665] Call Trace:
[  122.617760]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.617851]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.617941]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.618032]  [<c016f835>] sys_select+0x3f/0x1b6
[  122.618122]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.618214]  [<b7fd5410>] 0xb7fd5410
[  122.618302]  =======================
[  122.618353] hpiod         S F5B07E30     0  3278      1          3282  3255 (NOTLB)
[  122.618633]        f5b07e44 00200086 00000002 f5b07e30 f5b07e2c 00000000 f5a5d5b0 257c7552 
[  122.618977]        0000000a c013565a c02f9acc 00000003 c03bf66b 00000001 f5a5d5b0 c03f54e0 
[  122.619364]        257efee1 0000000a 0002c248 00000000 f5a5d6bc c1828dc0 c0522140 00000000 
[  122.619751] Call Trace:
[  122.619845]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.619937]  [<c0326010>] inet_csk_accept+0x106/0x229
[  122.620031]  [<c034287d>] inet_accept+0x1f/0xa5
[  122.620122]  [<c02f8ea4>] sys_accept+0xf2/0x1e7
[  122.620214]  [<c02f905f>] sys_socketcall+0xc6/0x271
[  122.620305]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.620397]  [<b7fbe410>] 0xb7fbe410
[  122.620485]  =======================
[  122.620536] python        S F429AB34     0  3282      1          3341  3278 (NOTLB)
[  122.620816]        f429ab48 00200082 00000002 f429ab34 f429ab30 00000000 f5a585b0 76ad1475 
[  122.621159]        0000001c f5a585b0 f5a58ae0 00000000 f5a585b0 0000000a f5a585b0 c03f54e0 
[  122.621546]        76ada67a 0000001c 000077d2 00000000 f5a586bc c1828dc0 c0522140 c0379c31 
[  122.621934] Call Trace:
[  122.622029]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.622120]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.622211]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.622301]  [<c016f8da>] sys_select+0xe4/0x1b6
[  122.622391]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.622483]  [<b7fa8410>] 0xb7fa8410
[  122.622571]  =======================
[  122.622622] apt-index-wat S F5923F30     0  3341      1          3367  3282 (NOTLB)
[  122.622902]        f5923f44 00000086 00000002 f5923f30 f5923f2c 00000000 f77255b0 0c483827 
[  122.623245]        0000001c f77255b0 c0379c47 c1829cd0 00000000 0000000a f77255b0 c03f54e0 
[  122.623632]        0c701300 0000001c 0027bc51 00000000 f77256bc c1828dc0 c0522140 c0131336 
[  122.624019] Call Trace:
[  122.624114]  [<c037892f>] do_nanosleep+0x55/0x70
[  122.624205]  [<c01313ab>] hrtimer_nanosleep+0x3d/0xf1
[  122.624296]  [<c01314b7>] sys_nanosleep+0x58/0x5c
[  122.624386]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.624478]  [<b7f3b410>] 0xb7f3b410
[  122.624567]  =======================
[  122.624617] dbus-daemon   S F4999BE4     0  3367      1          3388  3341 (NOTLB)
[  122.624898]        f4999bf8 00000086 00000002 f4999be4 f4999be0 c012e8b4 00000000 1ad5df66 
[  122.625241]        0000000f 00000074 00000000 00000000 f38f8d9c 0000000a f49985b0 c03f54e0 
[  122.625628]        1adc7579 0000000f 00078d3f 00000000 f49986bc c1828dc0 c0522140 f4998ae0 
[  122.626015] Call Trace:
[  122.626110]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.626202]  [<c016e8ee>] do_sys_poll+0x2d5/0x3f8
[  122.626293]  [<c016ea3c>] sys_poll+0x2b/0x39
[  122.626383]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.627182]  [<b7fde410>] 0xb7fde410
[  122.627271]  =======================
[  122.627322] hald          S F429BBE4     0  3388      1  3389    3461  3367 (NOTLB)
[  122.627603]        f429bbf8 00000086 00000002 f429bbe4 f429bbe0 00000000 f74d35b0 e197dd78 
[  122.627946]        00000018 f74d35b0 f74d3ae0 00000000 f74d35b0 00000008 f74d35b0 c03f54e0 
[  122.628333]        e19d4efa 00000018 00054b85 00000000 f74d36bc c1828dc0 c0522140 c0379c31 
[  122.628720] Call Trace:
[  122.628815]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.628906]  [<c016e8ee>] do_sys_poll+0x2d5/0x3f8
[  122.628997]  [<c016ea3c>] sys_poll+0x2b/0x39
[  122.629087]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.629179]  [<b7fc9410>] 0xb7fc9410
[  122.629267]  =======================
[  122.629318] hald-runner   S C1A4FBE4     0  3389   3388  3395               (NOTLB)
[  122.629598]        c1a4fbf8 00000086 00000002 c1a4fbe4 c1a4fbe0 c012e8b4 00000000 e793fa4e 
[  122.629942]        0000000b 00000000 00000000 00000000 f43b1d9c 00000009 f40995b0 c19895b0 
[  122.630328]        e7b7456a 0000000b 00001292 00000001 f40996bc c1830dc0 c0522140 f4099ae0 
[  122.630715] Call Trace:
[  122.630810]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.630902]  [<c016e8ee>] do_sys_poll+0x2d5/0x3f8
[  122.630993]  [<c016ea3c>] sys_poll+0x2b/0x39
[  122.631083]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.631175]  [<b7f0e410>] 0xb7f0e410
[  122.631263]  =======================
[  122.631314] hald-addon-ac S F562DDA8     0  3395   3389          3397       (NOTLB)
[  122.631595]        f562ddbc 00000096 00000002 f562dda8 f562dda4 c05c0c20 f49965b0 f416843b 
[  122.631939]        0000000a c013565a 00000006 00000003 c03bf66b 00000006 f49965b0 c03f54e0 
[  122.632325]        f4347f17 0000000a 00013f87 00000000 f49966bc c1828dc0 c0522140 00000000 
[  122.632712] Call Trace:
[  122.632807]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.632898]  [<c035bd40>] unix_stream_recvmsg+0x343/0x4ef
[  122.632992]  [<c02f7515>] sock_aio_read+0xd5/0xee
[  122.633083]  [<c016302f>] do_sync_read+0xd5/0x111
[  122.633174]  [<c016390d>] vfs_read+0x13e/0x145
[  122.633264]  [<c0163d0e>] sys_read+0x41/0x6a
[  122.633353]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.633445]  [<b7fcd410>] 0xb7fcd410
[  122.633534]  =======================
[  122.633585] hald-addon-ke S F49C5F38     0  3397   3389          3414  3395 (NOTLB)
[  122.633865]        f49c5f4c 00000096 00000002 f49c5f38 f49c5f34 f54fe800 f74d05b0 83c45f4b 
[  122.634208]        0000001c 00000046 00000000 00000000 f54fe800 0000000a f74d05b0 c03f54e0 
[  122.634595]        83c865db 0000001c 00001f60 00000000 f74d06bc c1828dc0 c0522140 c0134ddc 
[  122.634982] Call Trace:
[  122.635077]  [<f8a24d81>] evdev_read+0xa5/0x17c [evdev]
[  122.635174]  [<c0163858>] vfs_read+0x89/0x145
[  122.635265]  [<c0163d0e>] sys_read+0x41/0x6a
[  122.635354]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.635446]  [<b7f2b410>] 0xb7f2b410
[  122.635534]  =======================
[  122.635585] hald-addon-st S F6217F30     0  3414   3389                3397 (NOTLB)
[  122.635865]        f6217f44 00000086 00000002 f6217f30 f6217f2c 00000000 f74d95b0 3b68df01 
[  122.636209]        0000001c f74d95b0 c0379c47 c1829cd0 00000000 00000009 f74d95b0 c03f54e0 
[  122.636596]        3ba0a98d 0000001c 00006a88 00000000 f74d96bc c1828dc0 c0522140 c0131336 
[  122.636983] Call Trace:
[  122.637077]  [<c037892f>] do_nanosleep+0x55/0x70
[  122.637169]  [<c01313ab>] hrtimer_nanosleep+0x3d/0xf1
[  122.637259]  [<c01314b7>] sys_nanosleep+0x58/0x5c
[  122.637349]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.637441]  [<b7f82410>] 0xb7f82410
[  122.637530]  =======================
[  122.637581] nfsd          S 00000046     0  3461      1          3465  3388 (L-TLB)
[  122.637861]        f7687f3c 00000092 c0634740 00000046 00000000 00000000 f39445b0 24fc95c0 
[  122.638205]        0000000c f39445b0 c183174c 00000001 f39445b0 00000007 f39445b0 f755c5b0 
[  122.638592]        251f4fbc 0000000c 0004fbb6 00000001 f39446bc c1830dc0 000cc9ef c1828dc0 
[  122.638979] Call Trace:
[  122.639074]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.639166]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.639256]  [<c01dcaa1>] nfsd+0xc7/0x296
[  122.639348]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.639439]  =======================
[  122.639490] nfsd          S 00000046     0  3462      1          3463  3468 (L-TLB)
[  122.639771]        f48e5f3c 00000092 c0634740 00000046 00000000 00000000 f755c5b0 24fc95c0 
[  122.640115]        0000000c 00000078 c183174c 00000002 f755c5b0 00000001 f755c5b0 f7c2c5b0 
[  122.640502]        25204d80 0000000c 0000fdc4 00000001 f755c6bc c1830dc0 000cc9ef c1828dc0 
[  122.640889] Call Trace:
[  122.640983]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.641075]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.641165]  [<c01dcaa1>] nfsd+0xc7/0x296
[  122.641255]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.641346]  =======================
[  122.641396] nfsd          S C1A67F28     0  3463      1          3464  3462 (L-TLB)
[  122.641677]        c1a67f3c 00000092 00000002 c1a67f28 c1a67f24 00000000 f76225b0 2a3909ee 
[  122.642020]        0000000c f76225b0 f7622ae0 00000000 f76225b0 00000001 f76225b0 c03f54e0 
[  122.642407]        2a4f3ed7 0000000c 0001e0e5 00000000 f76226bc c1828dc0 c0522140 c0379c31 
[  122.642794] Call Trace:
[  122.642889]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.642980]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.643071]  [<c01dcaa1>] nfsd+0xc7/0x296
[  122.643160]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.643252]  =======================
[  122.643302] nfsd          S F39EDF28     0  3464      1          3472  3463 (L-TLB)
[  122.643583]        f39edf3c 00000092 00000002 f39edf28 f39edf24 00000000 f39425b0 2a39d88c 
[  122.643926]        0000000c f39425b0 f3942ae0 00000000 f39425b0 00000001 f39425b0 c19895b0 
[  122.644313]        2a595882 0000000c 000d55a4 00000001 f39426bc c1830dc0 c0522140 c0379c31 
[  122.644701] Call Trace:
[  122.644795]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.644886]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.644976]  [<c01dcaa1>] nfsd+0xc7/0x296
[  122.645066]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.645157]  =======================
[  122.645208] nfsd          S 00000046     0  3465      1          3466  3461 (L-TLB)
[  122.645488]        f3a13f3c 00000092 c0633878 00000046 00000000 00000000 f40a15b0 2510285c 
[  122.645832]        0000000c f40a15b0 c182974c 00000000 f40a15b0 00000001 f40a15b0 f3a3d5b0 
[  122.646219]        251d5c37 0000000c 0000847c 00000000 f40a16bc c1828dc0 000cc9ef c1830dc0 
[  122.646606] Call Trace:
[  122.646701]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.646792]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.646883]  [<c01dcaa1>] nfsd+0xc7/0x296
[  122.646973]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.647063]  =======================
[  122.647114] nfsd          S 00000046     0  3466      1          3467  3465 (L-TLB)
[  122.647394]        f3a3ef3c 00000092 c0633878 00000046 00000000 00000000 f3a3d5b0 2510285c 
[  122.647738]        0000000c f3a3d5b0 c182974c 00000000 f3a3d5b0 00000001 f3a3d5b0 f3a675b0 
[  122.648125]        251dd858 0000000c 00007c21 00000000 f3a3d6bc c1828dc0 000cc9ef c1830dc0 
[  122.648512] Call Trace:
[  122.648606]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.648698]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.648788]  [<c01dcaa1>] nfsd+0xc7/0x296
[  122.648878]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.648969]  =======================
[  122.649020] nfsd          S 00000046     0  3467      1          3468  3466 (L-TLB)
[  122.649300]        f3a68f3c 00000092 c0633878 00000046 00000000 00000000 f3a675b0 2510285c 
[  122.649644]        0000000c f3a675b0 c182974c 00000000 f3a675b0 00000001 f3a675b0 f3a915b0 
[  122.650031]        251e4d96 0000000c 0000753e 00000000 f3a676bc c1828dc0 000cc9ef c1830dc0 
[  122.650418] Call Trace:
[  122.650512]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.650604]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.650695]  [<c01dcaa1>] nfsd+0xc7/0x296
[  122.650784]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.650875]  =======================
[  122.650926] nfsd          S F3A92F28     0  3468      1          3462  3467 (L-TLB)
[  122.651916]        f3a92f3c 00000092 00000002 f3a92f28 f3a92f24 00000000 f3a915b0 2510285c 
[  122.652259]        0000000c f3a915b0 f3a91ae0 00000000 f3a915b0 00000001 f3a915b0 c03f54e0 
[  122.652646]        251ec274 0000000c 000074de 00000000 f3a916bc c1828dc0 c0522140 c0379c31 
[  122.653033] Call Trace:
[  122.653128]  [<c0377bb6>] schedule_timeout+0x49/0xac
[  122.653219]  [<c0369130>] svc_recv+0x1a5/0x3d5
[  122.653309]  [<c01dcaa1>] nfsd+0xc7/0x296
[  122.653399]  [<c0103b33>] kernel_thread_helper+0x7/0x14
[  122.653490]  =======================
[  122.653541] rpc.mountd    S F754C5B0     0  3472      1          3538  3464 (NOTLB)
[  122.653822]        f3abfb48 00000082 f754c5b0 f754c5b0 f754caec c013565a c012e8b4 2f396a0f 
[  122.654166]        0000000c f754c5b0 c182974c 00000000 00000000 00000001 f754c5b0 f77815b0 
[  122.654553]        2f5614ea 0000000c 000881d5 00000000 f754c6bc c1828dc0 00000000 c1830dc0 
[  122.654939] Call Trace:
[  122.655034]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.655125]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.655215]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.655306]  [<c016f835>] sys_select+0x3f/0x1b6
[  122.655396]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.655488]  [<b7ee7410>] 0xb7ee7410
[  122.655577]  =======================
[  122.655628] rpc.statd     S F7C2C5B0     0  3538      1          3621  3472 (NOTLB)
[  122.655908]        f5f58b48 00000082 f7c2c5b0 f7c2c5b0 f7c2caec c013565a c012e8b4 4def3903 
[  122.656252]        0000000c f7c2c5b0 c182974c 00000000 00000000 00000007 f7c2c5b0 f3ac75b0 
[  122.656639]        4df126cc 0000000c 0007f440 00000000 f7c2c6bc c1828dc0 00000000 c1830dc0 
[  122.657026] Call Trace:
[  122.657121]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.657212]  [<c016ee05>] do_select+0x3bb/0x49c
[  122.657302]  [<c016f0c0>] core_sys_select+0x1da/0x322
[  122.657393]  [<c016f835>] sys_select+0x3f/0x1b6
[  122.657484]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.657576]  [<b7ef1410>] 0xb7ef1410
[  122.657665]  =======================
[  122.657716] atd           S F3B6E5B0     0  3621      1          3640  3538 (NOTLB)
[  122.657996]        f3b6ff44 00000086 c1829ce8 f3b6e5b0 00000000 00000000 f3b6e5b0 75e99d06 
[  122.658340]        0000000c f3b6e5b0 c182974c 00000000 00000000 00000001 f3b6e5b0 f49c45b0 
[  122.658727]        75fbf574 0000000c 001388c5 00000000 f3b6e6bc c1828dc0 f3b6ff6c c1830dc0 
[  122.659114] Call Trace:
[  122.659209]  [<c037892f>] do_nanosleep+0x55/0x70
[  122.659300]  [<c01313ab>] hrtimer_nanosleep+0x3d/0xf1
[  122.659390]  [<c01314b7>] sys_nanosleep+0x58/0x5c
[  122.659480]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.659572]  [<b7ef8410>] 0xb7ef8410
[  122.659661]  =======================
[  122.659711] cron          S F3AC6F30     0  3640      1          3807  3621 (NOTLB)
[  122.659992]        f3ac6f44 00000086 00000002 f3ac6f30 f3ac6f2c 00000000 f3ad05b0 0208c881 
[  122.660335]        00000013 f3ad05b0 c0379c47 c1829cd0 00000000 00000007 f3ad05b0 c03f54e0 
[  122.660723]        0215d3ed 00000013 000cec6a 00000000 f3ad06bc c1828dc0 c0522140 c0131336 
[  122.661110] Call Trace:
[  122.661204]  [<c037892f>] do_nanosleep+0x55/0x70
[  122.661295]  [<c01313ab>] hrtimer_nanosleep+0x3d/0xf1
[  122.661386]  [<c01314b7>] sys_nanosleep+0x58/0x5c
[  122.661476]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.661568]  [<b7f9d410>] 0xb7f9d410
[  122.661657]  =======================
[  122.661707] bash          S F74E7F14     0  3720   2825  3825               (NOTLB)
[  122.661987]        f74e7f28 00000086 00000002 f74e7f14 f74e7f10 00000000 f763fe84 b3ba1362 
[  122.662331]        00000012 c0634718 00000000 c0483c14 c1a465b0 00000009 c1a465b0 c19895b0 
[  122.662718]        b3d0484f 00000012 0007a671 00000001 c1a466bc c1830dc0 c0522140 c011e6ad 
[  122.663105] Call Trace:
[  122.663200]  [<c011ed25>] do_wait+0x6e1/0xb31
[  122.663291]  [<c011f1a6>] sys_wait4+0x31/0x35
[  122.663381]  [<c011f1d1>] sys_waitpid+0x27/0x2b
[  122.663471]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.663563]  [<b7fa5410>] 0xb7fa5410
[  122.663651]  =======================
[  122.663702] wpa_supplican D F4997D10     0  3807      1                3640 (NOTLB)
[  122.663982]        f4997d24 00200082 00000002 f4997d10 f4997d0c f3b775b0 f3b775b0 91154229 
[  122.664326]        00000013 c03094d5 f3b77aec 000002bb f3b775b0 0000000a f3b775b0 c03f54e0 
[  122.664713]        911620cc 00000013 0000c4d8 00000000 f3b776bc c1828dc0 c0522140 c03784ad 
[  122.665101] Call Trace:
[  122.665195]  [<c0378455>] __mutex_lock_slowpath+0xb1/0x286
[  122.665288]  [<c03094d5>] rtnetlink_rcv+0x18/0x42
[  122.665381]  [<c031408b>] netlink_data_ready+0x12/0x54
[  122.665473]  [<c0312dc5>] netlink_sendskb+0x1c/0x33
[  122.665563]  [<c0313f8b>] netlink_sendmsg+0x1b8/0x2a6
[  122.665654]  [<c02f7e40>] sock_sendmsg+0xbf/0xe1
[  122.665744]  [<c02f81bc>] sys_sendto+0x117/0x144
[  122.665835]  [<c02f8220>] sys_send+0x37/0x3b
[  122.665924]  [<c02f90db>] sys_socketcall+0x142/0x271
[  122.666015]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.666106]  [<b7f0a410>] 0xb7f0a410
[  122.666195]  =======================
[  122.666246] bash          S F3AD1EB4     0  3808   2826                     (NOTLB)
[  122.666525]        f3ad1ec8 00000086 00000002 f3ad1eb4 f3ad1eb0 00000002 c05ca7c0 7cc4a518 
[  122.666869]        00000010 f5522b14 c013565a 00000006 00000003 00000001 f55225b0 c19895b0 
[  122.667257]        7cc911f8 00000010 00bb14ec 00000001 f55226bc c1830dc0 c0522140 00000000 
[  122.667644] Call Trace:
[  122.667739]  [<c0377bdb>] schedule_timeout+0x6e/0xac
[  122.667830]  [<c02495cd>] read_chan+0x1d0/0x613
[  122.667921]  [<c024624f>] tty_read+0x78/0xbe
[  122.668010]  [<c0163858>] vfs_read+0x89/0x145
[  122.668101]  [<c0163d0e>] sys_read+0x41/0x6a
[  122.668190]  [<c0102e29>] sysenter_past_esp+0x56/0x8d
[  122.668282]  [<b7f49410>] 0xb7f49410
[  122.668371]  =======================
[  122.668422] rmmod         R running     0  3825   3720                     (NOTLB)
[  122.668702] 
[  122.668703] Showing all locks held in the system:
[  122.668808] 1 lock held by getty/2827:
[  122.668858]  #0:  (&tty->atomic_read_lock){--..}, at: [<c024981d>] read_chan+0x420/0x613
[  122.669106] 1 lock held by getty/2828:
[  122.669156]  #0:  (&tty->atomic_read_lock){--..}, at: [<c024981d>] read_chan+0x420/0x613
[  122.669402] 1 lock held by getty/2829:
[  122.669452]  #0:  (&tty->atomic_read_lock){--..}, at: [<c024981d>] read_chan+0x420/0x613
[  122.669698] 1 lock held by getty/2830:
[  122.669748]  #0:  (&tty->atomic_read_lock){--..}, at: [<c024981d>] read_chan+0x420/0x613
[  122.669997] 1 lock held by wpa_supplicant/3807:
[  122.670048]  #0:  (rtnl_mutex){--..}, at: [<c03094d5>] rtnetlink_rcv+0x18/0x42
[  122.670293] 1 lock held by bash/3808:
[  122.670343]  #0:  (&tty->atomic_read_lock){--..}, at: [<c024981d>] read_chan+0x420/0x613
[  122.670589] 1 lock held by rmmod/3825:
[  122.670639]  #0:  (rtnl_mutex){--..}, at: [<f8d20a8f>] ieee80211_unregister_hw+0x39/0x23a [80211]
[  122.670899] 
[  122.670946] =============================================
[  122.670948] 


-- 
Greetings Michael.
