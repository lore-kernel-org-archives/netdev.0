From: Walt Holman <walt@holmansrus.com>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Thu, 20 Aug 2009 06:54:23 -0500 (CDT)
Message-ID: <985009134.71250769263099.JavaMail.root@mail.holmansrus.com>
References: <1359163732.51250769223038.JavaMail.root@mail.holmansrus.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_3_1037504760.1250769263096"
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754122AbZHTLyi@vger.kernel.org>
In-Reply-To: <1359163732.51250769223038.JavaMail.root@mail.holmansrus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_3_1037504760.1250769263096
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit


----- "Krzysztof Halasa" <khc@pm.waw.pl> wrote:

> > Since patching to 2.6.30.5 I'm experiencing periodic timeouts on my
> > e100 which is used as my WAN interface on a server/router box.
> Nothing
> > is reported in any logs and eventually the traffic resumes. It
> seems
> > to happen at fairly regular intervals, although I've not timed
> them.
> > The timeouts last for approx. 60-120 seconds and then traffic
> resumes
> > normally with no hint of what happened.
> 
> x86-64, intel P965...
> 
> Can you provide "dmesg" output, please?
> 
> I wonder what additional side effect did the patch cause. Streaming
> allocs on such x86 should already be coherent, no?
> 
> Perhaps you have more than 2 GB RAM (or so) and swiotlb has to
> provide
> buffering? I think of something like:
> 
> - the driver does "sync for CPU" and examines status
> - the descriptor is tested to be still empty
> - meanwhile e100 chip changes the status in the descriptor
> - the driver does "sync for device" (it's what the patch added)
> - at this point swiotlb doesn't know the descriptor is clean and
> writes
>   it out, thus dropping the change done by the e100 chip.
> 
> Does the above seem plausible? I admit I'm not swiotlb expert, it's
> a pure guess that it simply and blindly moves data in and out.
> 
> If that's the case, I don't really know how could it work without the
> patch in question. Perhaps the timings were just right?
> 
> What can we do with it? Rewriting to use consistent allocs, of
> course.
> Temporarily adding #ifdef CONFIG_ARM around the
> pci_dma_sync_single_for_device()? Not sure if other archs were
> affected.
> 
> The root problem is that the driver shouldn't use streaming
> allocations
> for its descriptors (they are written from both sides
> simultaneously).
> Only skb->data can be streaming.
> -- 
> Krzysztof Halasa

Hi Krzystof,

dmesg is attached. This box does have >2GB Ram (6GB total).  The dmesg will show e100 init'd 3 times since the first is the stock modprobe, 2nd was forced with use_io and the 3rd modprobe was after reverting the patch.

-Walt

------=_Part_3_1037504760.1250769263096
Content-Type: text/plain; name=dmesg.txt
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=dmesg.txt

[    0.000000] Linux version 2.6.30-patched-r5 (root@waltsputer) (gcc version 4.3.3 (Ubuntu 4.3.3-5ubuntu4) ) #1 SMP PREEMPT Wed Aug 19 17:51:30 CDT 2009
[    0.000000] Command line: root=/dev/mapper/vg0-root ro resume=/dev/vg0/swap splash vga=791 elevator=deadline 
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 0000000000098000 (usable)
[    0.000000]  BIOS-e820: 0000000000098000 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e3000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000cffb0000 (usable)
[    0.000000]  BIOS-e820: 00000000cffb0000 - 00000000cffbe000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cffbe000 - 00000000cfff0000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000cfff0000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ffb00000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 00000001b0000000 (usable)
[    0.000000] DMI present.
[    0.000000] AMI BIOS detected: BIOS may corrupt low RAM, working around it.
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] last_pfn = 0x1b0000 max_arch_pfn = 0x100000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-DFFFF write-protect
[    0.000000]   E0000-EFFFF write-through
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 1B0000000 mask FF0000000 uncachable
[    0.000000]   1 base 1C0000000 mask FC0000000 uncachable
[    0.000000]   2 base 000000000 mask E00000000 write-back
[    0.000000]   3 base 0D0000000 mask FF0000000 uncachable
[    0.000000]   4 base 0E0000000 mask FE0000000 uncachable
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820 update range: 00000000d0000000 - 0000000100000000 (usable) ==> (reserved)
[    0.000000] last_pfn = 0xcffb0 max_arch_pfn = 0x100000000
[    0.000000] init_memory_mapping: 0000000000000000-00000000cffb0000
[    0.000000]  0000000000 - 00cfe00000 page 2M
[    0.000000]  00cfe00000 - 00cffb0000 page 4k
[    0.000000] kernel direct mapping tables up to cffb0000 @ 10000-16000
[    0.000000] init_memory_mapping: 0000000100000000-00000001b0000000
[    0.000000]  0100000000 - 01b0000000 page 2M
[    0.000000] kernel direct mapping tables up to 1b0000000 @ 14000-1c000
[    0.000000] RAMDISK: 37a3a000 - 37fef4b7
[    0.000000] ACPI: RSDP 00000000000f93a0 00014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 00000000cffb0000 00038 (v01 M S I  OEMRSDT  12000701 MSFT 00000097)
[    0.000000] ACPI: FACP 00000000cffb0200 00084 (v02 M S I  OEMFACP  12000701 MSFT 00000097)
[    0.000000] ACPI: DSDT 00000000cffb0440 052CE (v01  0AAAA 0AAAA000 00000000 INTL 20051117)
[    0.000000] ACPI: FACS 00000000cffbe000 00040
[    0.000000] ACPI: APIC 00000000cffb0390 0006C (v01 M S I  OEMAPIC  12000701 MSFT 00000097)
[    0.000000] ACPI: MCFG 00000000cffb0400 0003C (v01 M S I  OEMMCFG  12000701 MSFT 00000097)
[    0.000000] ACPI: OEMB 00000000cffbe040 00061 (v01 M S I  AMI_OEM  12000701 MSFT 00000097)
[    0.000000] ACPI: SSDT 00000000cffbe9d0 00A7C (v01 DpgPmm    CpuPm 00000012 INTL 20051117)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] (8 early reservations) ==> bootmem [0000000000 - 01b0000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
[    0.000000]   #2 [0000200000 - 0000730ca8]    TEXT DATA BSS ==> [0000200000 - 0000730ca8]
[    0.000000]   #3 [0037a3a000 - 0037fef4b7]          RAMDISK ==> [0037a3a000 - 0037fef4b7]
[    0.000000]   #4 [0000098000 - 0000100000]    BIOS reserved ==> [0000098000 - 0000100000]
[    0.000000]   #5 [0000731000 - 0000731133]              BRK ==> [0000731000 - 0000731133]
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE ==> [0000010000 - 0000014000]
[    0.000000]   #7 [0000014000 - 0000017000]          PGTABLE ==> [0000014000 - 0000017000]
[    0.000000] found SMP MP-table at [ffff8800000ff780] ff780
[    0.000000]  [ffffe20000000000-ffffe20005ffffff] PMD -> [ffff880028200000-ffff88002e1fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x001b0000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x00000098
[    0.000000]     0: 0x00000100 -> 0x000cffb0
[    0.000000]     0: 0x00100000 -> 0x001b0000
[    0.000000] On node 0 totalpages: 1572664
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 1442 pages reserved
[    0.000000]   DMA zone: 2478 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 833512 pages, LIFO batch:31
[    0.000000]   Normal zone: 9856 pages used for memmap
[    0.000000]   Normal zone: 711040 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] nr_irqs_gsi: 24
[    0.000000] PM: Registered nosave memory: 0000000000098000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e3000
[    0.000000] PM: Registered nosave memory: 00000000000e3000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 00000000cffb0000 - 00000000cffbe000
[    0.000000] PM: Registered nosave memory: 00000000cffbe000 - 00000000cfff0000
[    0.000000] PM: Registered nosave memory: 00000000cfff0000 - 00000000d0000000
[    0.000000] PM: Registered nosave memory: 00000000d0000000 - 00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 - 00000000ffb00000
[    0.000000] PM: Registered nosave memory: 00000000ffb00000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at d4000000 (gap: d0000000:2ee00000)
[    0.000000] NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 25 pages at ffff880028034000, static data 70176 bytes
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1547030
[    0.000000] Kernel command line: root=/dev/mapper/vg0-root ro resume=/dev/vg0/swap splash vga=791 elevator=deadline 
[    0.000000] Initializing CPU#0
[    0.000000] NR_IRQS:384
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2400.190 MHz processor.
[    0.000999] Console: colour dummy device 80x25
[    0.000999] console [tty0] enabled
[    0.000999] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.000999] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000999] Checking aperture...
[    0.000999] No AGP bridge found
[    0.000999] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.000999] Placing 64MB software IO TLB between ffff880020000000 - ffff880024000000
[    0.000999] software IO TLB at phys 0x20000000 - 0x24000000
[    0.000999] Memory: 6101284k/7077888k available (3010k kernel code, 787232k absent, 188416k reserved, 1325k data, 384k init)
[    0.000999] SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.001009] Calibrating delay loop (skipped), value calculated using timer frequency.. 4800.38 BogoMIPS (lpj=2400190)
[    0.001041] Security Framework initialized
[    0.001049] SELinux:  Disabled at boot.
[    0.001059] Mount-cache hash table entries: 256
[    0.001198] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.001204] CPU: L2 cache: 4096K
[    0.001210] CPU: Physical Processor ID: 0
[    0.001214] CPU: Processor Core ID: 0
[    0.001224] CPU0: Thermal monitoring enabled (TM2)
[    0.001230] using mwait in idle threads.
[    0.001251] ACPI: Core revision 20090320
[    0.008759] Setting APIC routing to flat
[    0.008998] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.019119] CPU0: Intel(R) Core(TM)2 CPU          6600  @ 2.40GHz stepping 06
[    0.019996] Booting processor 1 APIC 0x1 ip 0x6000
[    0.000999] Initializing CPU#1
[    0.000999] Calibrating delay using timer specific routine.. 4798.99 BogoMIPS (lpj=2399499)
[    0.000999] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.000999] CPU: L2 cache: 4096K
[    0.000999] CPU: Physical Processor ID: 0
[    0.000999] CPU: Processor Core ID: 1
[    0.000999] CPU1: Thermal monitoring enabled (TM2)
[    0.000999] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
[    0.091152] CPU1: Intel(R) Core(TM)2 CPU          6600  @ 2.40GHz stepping 06
[    0.091206] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[    0.092012] Brought up 2 CPUs
[    0.092018] Total of 2 processors activated (9599.37 BogoMIPS).
[    0.092085] net_namespace: 1712 bytes
[    0.092085] NET: Registered protocol family 16
[    0.092085] ACPI: bus type pci registered
[    0.092993] dca service started, version 1.8
[    0.093020] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.093027] PCI: Not using MMCONFIG.
[    0.093031] PCI: Using configuration type 1 for base access
[    0.095028] bio: create slab <bio-0> at 0
[    0.096550] ACPI: EC: Look up EC in DSDT
[    0.105318] ACPI: Interpreter enabled
[    0.105325] ACPI: (supports S0 S1 S3 S4 S5)
[    0.105351] ACPI: Using IOAPIC for interrupt routing
[    0.105406] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.108911] PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
[    0.118543] PCI: Using MMCONFIG at e0000000 - efffffff
[    0.128037] ACPI Warning (tbutils-0246): Incorrect checksum in table [OEMB] - 3D, should be 34 [20090320]
[    0.128162] ACPI: No dock devices found.
[    0.128370] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.128400] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.128400] pci 0000:00:01.0: PME# disabled
[    0.128400] pci 0000:00:1a.0: reg 20 io port: [0xac00-0xac1f]
[    0.128400] pci 0000:00:1a.1: reg 20 io port: [0xa880-0xa89f]
[    0.128400] pci 0000:00:1a.7: reg 10 32bit mmio: [0xfbfffc00-0xfbffffff]
[    0.128400] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    0.128400] pci 0000:00:1a.7: PME# disabled
[    0.128400] pci 0000:00:1b.0: reg 10 64bit mmio: [0xfbff8000-0xfbffbfff]
[    0.128400] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.128400] pci 0000:00:1b.0: PME# disabled
[    0.128400] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.128400] pci 0000:00:1c.0: PME# disabled
[    0.129027] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.129034] pci 0000:00:1c.4: PME# disabled
[    0.129087] pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
[    0.129094] pci 0000:00:1c.5: PME# disabled
[    0.129135] pci 0000:00:1d.0: reg 20 io port: [0xa800-0xa81f]
[    0.129178] pci 0000:00:1d.1: reg 20 io port: [0xa480-0xa49f]
[    0.129220] pci 0000:00:1d.2: reg 20 io port: [0xa400-0xa41f]
[    0.129268] pci 0000:00:1d.7: reg 10 32bit mmio: [0xfbfff800-0xfbfffbff]
[    0.129312] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.129319] pci 0000:00:1d.7: PME# disabled
[    0.129426] pci 0000:00:1f.0: quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
[    0.129436] pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
[    0.129443] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0a00 (mask 00ff)
[    0.129501] pci 0000:00:1f.2: reg 10 io port: [0xa080-0xa087]
[    0.129507] pci 0000:00:1f.2: reg 14 io port: [0xa000-0xa003]
[    0.129512] pci 0000:00:1f.2: reg 18 io port: [0x9c00-0x9c07]
[    0.129517] pci 0000:00:1f.2: reg 1c io port: [0x9880-0x9883]
[    0.129522] pci 0000:00:1f.2: reg 20 io port: [0x9800-0x981f]
[    0.129527] pci 0000:00:1f.2: reg 24 32bit mmio: [0xfbfff000-0xfbfff7ff]
[    0.129551] pci 0000:00:1f.2: PME# supported from D3hot
[    0.129557] pci 0000:00:1f.2: PME# disabled
[    0.129581] pci 0000:00:1f.3: reg 10 32bit mmio: [0xfbffec00-0xfbffecff]
[    0.129596] pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
[    0.129637] pci 0000:01:00.0: reg 10 32bit mmio: [0xfd000000-0xfdffffff]
[    0.129644] pci 0000:01:00.0: reg 14 64bit mmio: [0xd0000000-0xdfffffff]
[    0.129652] pci 0000:01:00.0: reg 1c 64bit mmio: [0xfc000000-0xfcffffff]
[    0.129657] pci 0000:01:00.0: reg 24 io port: [0xbc00-0xbc7f]
[    0.129661] pci 0000:01:00.0: reg 30 32bit mmio: [0xfe8e0000-0xfe8fffff]
[    0.129712] pci 0000:00:01.0: bridge io port: [0xb000-0xbfff]
[    0.129715] pci 0000:00:01.0: bridge 32bit mmio: [0xfc000000-0xfe8fffff]
[    0.129719] pci 0000:00:01.0: bridge 64bit mmio pref: [0xd0000000-0xdfffffff]
[    0.129842] pci 0000:03:00.0: reg 24 32bit mmio: [0xfe9fe000-0xfe9fffff]
[    0.129851] pci 0000:03:00.0: reg 30 32bit mmio: [0xfe9e0000-0xfe9effff]
[    0.129880] pci 0000:03:00.0: PME# supported from D3hot
[    0.129889] pci 0000:03:00.0: PME# disabled
[    0.129940] pci 0000:03:00.1: reg 10 io port: [0xcc00-0xcc07]
[    0.129949] pci 0000:03:00.1: reg 14 io port: [0xc880-0xc883]
[    0.129957] pci 0000:03:00.1: reg 18 io port: [0xc800-0xc807]
[    0.129965] pci 0000:03:00.1: reg 1c io port: [0xc480-0xc483]
[    0.129974] pci 0000:03:00.1: reg 20 io port: [0xc400-0xc40f]
[    0.130064] pci 0000:00:1c.4: bridge io port: [0xc000-0xcfff]
[    0.130067] pci 0000:00:1c.4: bridge 32bit mmio: [0xfe900000-0xfe9fffff]
[    0.130125] pci 0000:04:00.0: reg 10 io port: [0xd800-0xd8ff]
[    0.130145] pci 0000:04:00.0: reg 18 64bit mmio: [0xfeaff000-0xfeafffff]
[    0.130166] pci 0000:04:00.0: reg 30 32bit mmio: [0xfeac0000-0xfeadffff]
[    0.130209] pci 0000:04:00.0: supports D1 D2
[    0.130211] pci 0000:04:00.0: PME# supported from D1 D2 D3hot D3cold
[    0.130220] pci 0000:04:00.0: PME# disabled
[    0.130266] pci 0000:00:1c.5: bridge io port: [0xd000-0xdfff]
[    0.130270] pci 0000:00:1c.5: bridge 32bit mmio: [0xfea00000-0xfeafffff]
[    0.130303] pci 0000:05:00.0: reg 10 32bit mmio: [0xfebff000-0xfebfffff]
[    0.130309] pci 0000:05:00.0: reg 14 io port: [0xec00-0xec3f]
[    0.130315] pci 0000:05:00.0: reg 18 32bit mmio: [0xfebc0000-0xfebdffff]
[    0.130333] pci 0000:05:00.0: reg 30 32bit mmio: [0xfebe0000-0xfebeffff]
[    0.130350] pci 0000:05:00.0: supports D1 D2
[    0.130352] pci 0000:05:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.130359] pci 0000:05:00.0: PME# disabled
[    0.130397] pci 0000:05:04.0: reg 10 32bit mmio: [0xfebfe800-0xfebfefff]
[    0.130403] pci 0000:05:04.0: reg 14 io port: [0xe880-0xe8ff]
[    0.130442] pci 0000:05:04.0: supports D2
[    0.130444] pci 0000:05:04.0: PME# supported from D2 D3hot D3cold
[    0.130451] pci 0000:05:04.0: PME# disabled
[    0.130493] pci 0000:00:1e.0: transparent bridge
[    0.130500] pci 0000:00:1e.0: bridge io port: [0xe000-0xefff]
[    0.130503] pci 0000:00:1e.0: bridge 32bit mmio: [0xfeb00000-0xfebfffff]
[    0.130524] pci_bus 0000:00: on NUMA node 0
[    0.130529] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.130668] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[    0.130773] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
[    0.130834] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P8._PRT]
[    0.130892] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P9._PRT]
[    0.145066] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.145189] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    0.145312] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 11 12 *14 15)
[    0.145433] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    0.145553] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    0.145673] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 *15)
[    0.145793] ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 7 10 11 12 14 15)
[    0.146068] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    0.146126] SCSI subsystem initialized
[    0.146126] libata version 3.00 loaded.
[    0.146126] usbcore: registered new interface driver usbfs
[    0.146126] usbcore: registered new interface driver hub
[    0.146126] usbcore: registered new device driver usb
[    0.146126] PCI: Using ACPI for IRQ routing
[    0.155043] pnp: PnP ACPI init
[    0.155058] ACPI: bus type pnp registered
[    0.159165] pnp: PnP ACPI: found 17 devices
[    0.159171] ACPI: ACPI bus type pnp unregistered
[    0.159182] system 00:01: iomem range 0xfed14000-0xfed19fff has been reserved
[    0.159193] system 00:0a: ioport range 0xa10-0xaef has been reserved
[    0.159199] system 00:0a: ioport range 0xae0-0xaef has been reserved
[    0.159208] system 00:0b: ioport range 0x4d0-0x4d1 has been reserved
[    0.159214] system 00:0b: ioport range 0x800-0x87f has been reserved
[    0.159221] system 00:0b: ioport range 0x480-0x4bf has been reserved
[    0.159227] system 00:0b: iomem range 0xfed1c000-0xfed1ffff has been reserved
[    0.159234] system 00:0b: iomem range 0xfed20000-0xfed8ffff has been reserved
[    0.159243] system 00:0d: iomem range 0xffc00000-0xffefffff has been reserved
[    0.159252] system 00:0e: iomem range 0xfec00000-0xfec00fff could not be reserved
[    0.159260] system 00:0e: iomem range 0xfee00000-0xfee00fff has been reserved
[    0.159269] system 00:0f: iomem range 0xe0000000-0xefffffff has been reserved
[    0.159278] system 00:10: iomem range 0x0-0x9ffff could not be reserved
[    0.159284] system 00:10: iomem range 0xc0000-0xcffff has been reserved
[    0.159290] system 00:10: iomem range 0xe0000-0xfffff could not be reserved
[    0.159297] system 00:10: iomem range 0x100000-0xcfffffff could not be reserved
[    0.164187] pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
[    0.164194] pci 0000:00:01.0:   IO window: 0xb000-0xbfff
[    0.164201] pci 0000:00:01.0:   MEM window: 0xfc000000-0xfe8fffff
[    0.164207] pci 0000:00:01.0:   PREFETCH window: 0x000000d0000000-0x000000dfffffff
[    0.164217] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
[    0.164223] pci 0000:00:1c.0:   IO window: disabled
[    0.164230] pci 0000:00:1c.0:   MEM window: disabled
[    0.164236] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.164245] pci 0000:00:1c.4: PCI bridge, secondary bus 0000:03
[    0.164251] pci 0000:00:1c.4:   IO window: 0xc000-0xcfff
[    0.164259] pci 0000:00:1c.4:   MEM window: 0xfe900000-0xfe9fffff
[    0.164266] pci 0000:00:1c.4:   PREFETCH window: disabled
[    0.164274] pci 0000:00:1c.5: PCI bridge, secondary bus 0000:04
[    0.164280] pci 0000:00:1c.5:   IO window: 0xd000-0xdfff
[    0.164288] pci 0000:00:1c.5:   MEM window: 0xfea00000-0xfeafffff
[    0.164295] pci 0000:00:1c.5:   PREFETCH window: disabled
[    0.164304] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:05
[    0.164310] pci 0000:00:1e.0:   IO window: 0xe000-0xefff
[    0.164318] pci 0000:00:1e.0:   MEM window: 0xfeb00000-0xfebfffff
[    0.164325] pci 0000:00:1e.0:   PREFETCH window: 0x000000f0000000-0x000000f00fffff
[    0.164342] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.164349] pci 0000:00:01.0: setting latency timer to 64
[    0.164356] pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.164363] pci 0000:00:1c.0: setting latency timer to 64
[    0.164369] pci 0000:00:1c.4: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.164376] pci 0000:00:1c.4: setting latency timer to 64
[    0.164382] pci 0000:00:1c.5: PCI INT B -> GSI 16 (level, low) -> IRQ 16
[    0.164389] pci 0000:00:1c.5: setting latency timer to 64
[    0.164394] pci 0000:00:1e.0: setting latency timer to 64
[    0.164398] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.164400] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
[    0.164402] pci_bus 0000:01: resource 0 io:  [0xb000-0xbfff]
[    0.164404] pci_bus 0000:01: resource 1 mem: [0xfc000000-0xfe8fffff]
[    0.164406] pci_bus 0000:01: resource 2 pref mem [0xd0000000-0xdfffffff]
[    0.164409] pci_bus 0000:03: resource 0 io:  [0xc000-0xcfff]
[    0.164411] pci_bus 0000:03: resource 1 mem: [0xfe900000-0xfe9fffff]
[    0.164413] pci_bus 0000:04: resource 0 io:  [0xd000-0xdfff]
[    0.164415] pci_bus 0000:04: resource 1 mem: [0xfea00000-0xfeafffff]
[    0.164417] pci_bus 0000:05: resource 0 io:  [0xe000-0xefff]
[    0.164419] pci_bus 0000:05: resource 1 mem: [0xfeb00000-0xfebfffff]
[    0.164421] pci_bus 0000:05: resource 2 pref mem [0xf0000000-0xf00fffff]
[    0.164423] pci_bus 0000:05: resource 3 io:  [0x00-0xffff]
[    0.164425] pci_bus 0000:05: resource 4 mem: [0x000000-0xffffffffffffffff]
[    0.164438] NET: Registered protocol family 2
[    0.175320] IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.176457] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[    0.178204] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.178762] TCP: Hash tables configured (established 262144 bind 65536)
[    0.178769] TCP reno registered
[    0.181438] NET: Registered protocol family 1
[    0.181507] Trying to unpack rootfs image as initramfs...
[    0.323858] Freeing initrd memory: 5845k freed
[    0.327609] Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.327820] audit: initializing netlink socket (disabled)
[    0.327837] type=2000 audit(1250706533.327:1): initialized
[    0.330179] VFS: Disk quotas dquot_6.5.2
[    0.330232] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.330845] msgmni has been set to 11929
[    0.330986] alg: No test for stdrng (krng)
[    0.330996] io scheduler noop registered
[    0.331003] io scheduler anticipatory registered
[    0.331008] io scheduler deadline registered (default)
[    0.331020] io scheduler cfq registered
[    0.331145] pci 0000:01:00.0: Boot video device
[    0.331161] pci 0000:05:00.0: Firmware left e100 interrupts enabled; disabling
[    0.331297] pcieport-driver 0000:00:01.0: irq 24 for MSI/MSI-X
[    0.331308] pcieport-driver 0000:00:01.0: setting latency timer to 64
[    0.331440] pcieport-driver 0000:00:1c.0: irq 25 for MSI/MSI-X
[    0.331451] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    0.331610] pcieport-driver 0000:00:1c.4: irq 26 for MSI/MSI-X
[    0.331621] pcieport-driver 0000:00:1c.4: setting latency timer to 64
[    0.331783] pcieport-driver 0000:00:1c.5: irq 27 for MSI/MSI-X
[    0.331794] pcieport-driver 0000:00:1c.5: setting latency timer to 64
[    0.332185] vesafb: framebuffer at 0xd0000000, mapped to 0xffffc20010100000, using 3072k, total 262144k
[    0.332194] vesafb: mode is 1024x768x16, linelength=2048, pages=1
[    0.332200] vesafb: scrolling: redraw
[    0.332205] vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
[    0.344339] Console: switching to colour frame buffer device 128x48
[    0.355413] fb0: VESA VGA frame buffer device
[    0.355636] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.355807] ACPI: Power Button [PWRF]
[    0.355980] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
[    0.356171] ACPI: Power Button [PWRB]
[    0.356751] ACPI: SSDT 00000000cffbe0b0 00277 (v01 DpgPmm  P001Ist 00000011 INTL 20051117)
[    0.357236] processor ACPI_CPU:00: registered as cooling_device0
[    0.357773] ACPI: SSDT 00000000cffbe540 00277 (v01 DpgPmm  P002Ist 00000012 INTL 20051117)
[    0.358242] processor ACPI_CPU:01: registered as cooling_device1
[    0.386443] Non-volatile memory driver v1.3
[    0.386638] Linux agpgart interface v0.103
[    0.386823] Floppy drive(s): fd0 is 1.44M
[    0.401137] FDC 0 is a post-1991 82077
[    0.403337] brd: module loaded
[    0.404014] loop: module loaded
[    0.404170] Driver 'sd' needs updating - please use bus_type methods
[    0.404356] ahci 0000:00:1f.2: version 3.0
[    0.404370] ahci 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    0.404572] ahci 0000:00:1f.2: irq 28 for MSI/MSI-X
[    0.404614] ahci: SSS flag set, parallel bus scan disabled
[    0.407056] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl RAID mode
[    0.409668] ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pio slum part ems 
[    0.412392] ahci 0000:00:1f.2: setting latency timer to 64
[    0.417770] scsi0 : ahci
[    0.420629] scsi1 : ahci
[    0.423454] scsi2 : ahci
[    0.426301] scsi3 : ahci
[    0.429142] scsi4 : ahci
[    0.431992] scsi5 : ahci
[    0.434936] ata1: SATA max UDMA/133 abar m2048@0xfbfff000 port 0xfbfff100 irq 28
[    0.437952] ata2: SATA max UDMA/133 abar m2048@0xfbfff000 port 0xfbfff180 irq 28
[    0.440976] ata3: SATA max UDMA/133 abar m2048@0xfbfff000 port 0xfbfff200 irq 28
[    0.444013] ata4: SATA max UDMA/133 abar m2048@0xfbfff000 port 0xfbfff280 irq 28
[    0.447062] ata5: SATA max UDMA/133 abar m2048@0xfbfff000 port 0xfbfff300 irq 28
[    0.450124] ata6: SATA max UDMA/133 abar m2048@0xfbfff000 port 0xfbfff380 irq 28
[    0.453221] ahci 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.456436] ahci 0000:03:00.0: JMB361 has only one port, port_map 0x3 -> 0x1
[    0.470776] ahci 0000:03:00.0: AHCI 0001.0000 32 slots 2 ports 3 Gbps 0x1 impl SATA mode
[    0.474236] ahci 0000:03:00.0: flags: 64bit ncq pm led clo pmp pio slum part 
[    0.477746] ahci 0000:03:00.0: setting latency timer to 64
[    0.477851] scsi6 : ahci
[    0.481451] scsi7 : ahci
[    0.485072] ata7: SATA max UDMA/133 abar m8192@0xfe9fe000 port 0xfe9fe100 irq 16
[    0.488833] ata8: DUMMY
[    0.492673] pata_jmicron 0000:03:00.1: enabling device (0000 -> 0001)
[    0.496640] pata_jmicron 0000:03:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.500622] pata_jmicron 0000:03:00.1: setting latency timer to 64
[    0.500678] scsi8 : pata_jmicron
[    0.504633] scsi9 : pata_jmicron
[    0.508441] ata9: PATA max UDMA/100 cmd 0xcc00 ctl 0xc880 bmdma 0xc400 irq 17
[    0.512257] ata10: PATA max UDMA/100 cmd 0xc800 ctl 0xc480 bmdma 0xc408 irq 17
[    0.516226] usbmon: debugfs is not available
[    0.519912] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.523647] ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.527356] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[    0.527359] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[    0.530996] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
[    0.538457] ehci_hcd 0000:00:1a.7: debug port 1
[    0.541950] ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
[    0.541961] ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfbfffc00
[    0.554855] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[    0.558411] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    0.561997] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.565629] usb usb1: Product: EHCI Host Controller
[    0.569276] usb usb1: Manufacturer: Linux 2.6.30-patched-r5 ehci_hcd
[    0.572945] usb usb1: SerialNumber: 0000:00:1a.7
[    0.576635] usb usb1: configuration #1 chosen from 1 choice
[    0.580269] hub 1-0:1.0: USB hub found
[    0.583778] hub 1-0:1.0: 4 ports detected
[    0.587391] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    0.590886] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    0.590888] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    0.594437] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
[    0.601979] ehci_hcd 0000:00:1d.7: debug port 1
[    0.605636] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    0.605647] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfbfff800
[    0.618957] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    0.622780] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    0.626570] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.630446] usb usb2: Product: EHCI Host Controller
[    0.634368] usb usb2: Manufacturer: Linux 2.6.30-patched-r5 ehci_hcd
[    0.638406] usb usb2: SerialNumber: 0000:00:1d.7
[    0.642539] usb usb2: configuration #1 chosen from 1 choice
[    0.646738] hub 2-0:1.0: USB hub found
[    0.650818] hub 2-0:1.0: 6 ports detected
[    0.655016] uhci_hcd: USB Universal Host Controller Interface driver
[    0.659162] uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.663271] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[    0.663274] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    0.667340] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
[    0.671519] uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000ac00
[    0.675632] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    0.679747] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.683850] usb usb3: Product: UHCI Host Controller
[    0.687932] usb usb3: Manufacturer: Linux 2.6.30-patched-r5 uhci_hcd
[    0.692019] usb usb3: SerialNumber: 0000:00:1a.0
[    0.696204] usb usb3: configuration #1 chosen from 1 choice
[    0.700349] hub 3-0:1.0: USB hub found
[    0.704385] hub 3-0:1.0: 2 ports detected
[    0.708483] uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[    0.712508] uhci_hcd 0000:00:1a.1: setting latency timer to 64
[    0.712511] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[    0.716488] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
[    0.720509] uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000a880
[    0.724500] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    0.728519] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.732578] usb usb4: Product: UHCI Host Controller
[    0.736643] usb usb4: Manufacturer: Linux 2.6.30-patched-r5 uhci_hcd
[    0.740710] usb usb4: SerialNumber: 0000:00:1a.1
[    0.744798] usb usb4: configuration #1 chosen from 1 choice
[    0.748847] hub 4-0:1.0: USB hub found
[    0.752815] hub 4-0:1.0: 2 ports detected
[    0.756878] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    0.760910] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    0.760913] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    0.764926] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 5
[    0.769016] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000a800
[    0.773048] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    0.777116] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.781196] usb usb5: Product: UHCI Host Controller
[    0.785243] usb usb5: Manufacturer: Linux 2.6.30-patched-r5 uhci_hcd
[    0.789364] usb usb5: SerialNumber: 0000:00:1d.0
[    0.793539] usb usb5: configuration #1 chosen from 1 choice
[    0.797670] hub 5-0:1.0: USB hub found
[    0.801726] hub 5-0:1.0: 2 ports detected
[    0.805858] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    0.809940] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    0.809943] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    0.814003] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 6
[    0.818112] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000a480
[    0.822187] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    0.826343] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.830484] usb usb6: Product: UHCI Host Controller
[    0.834574] usb usb6: Manufacturer: Linux 2.6.30-patched-r5 uhci_hcd
[    0.838706] usb usb6: SerialNumber: 0000:00:1d.1
[    0.842861] usb usb6: configuration #1 chosen from 1 choice
[    0.847007] hub 6-0:1.0: USB hub found
[    0.851041] hub 6-0:1.0: 2 ports detected
[    0.855171] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.859229] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    0.859232] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    0.863272] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 7
[    0.867332] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000a400
[    0.871376] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    0.875446] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.879575] usb usb7: Product: UHCI Host Controller
[    0.883649] usb usb7: Manufacturer: Linux 2.6.30-patched-r5 uhci_hcd
[    0.887770] usb usb7: SerialNumber: 0000:00:1d.2
[    0.891913] usb usb7: configuration #1 chosen from 1 choice
[    0.896049] hub 7-0:1.0: USB hub found
[    0.900075] hub 7-0:1.0: 2 ports detected
[    0.904285] usbcore: registered new interface driver libusual
[    0.908366] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
[    0.914503] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.918576] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.922711] mice: PS/2 mouse device common for all mice
[    0.926965] input: PC Speaker as /devices/platform/pcspkr/input/input2
[    0.931177] rtc_cmos 00:03: RTC can wake from S4
[    0.935325] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    0.939456] rtc0: alarms up to one month, y3k, 114 bytes nvram
[    0.943610] md: linear personality registered for level -1
[    0.947745] md: raid0 personality registered for level 0
[    0.951841] md: raid1 personality registered for level 1
[    0.955862] md: multipath personality registered for level -4
[    0.959897] cpuidle: using governor ladder
[    0.963871] cpuidle: using governor menu
[    0.968383] usbcore: registered new interface driver hiddev
[    0.972366] usbcore: registered new interface driver usbhid
[    0.976248] usbhid: v2.6:USB HID core driver
[    0.980232] TCP bic registered
[    0.984054] TCP cubic registered
[    0.987855] TCP westwood registered
[    0.991605] TCP highspeed registered
[    0.995314] TCP hybla registered
[    0.998936] TCP htcp registered
[    1.002506] TCP vegas registered
[    1.006099] TCP veno registered
[    1.009545] TCP scalable registered
[    1.012952] TCP lp registered
[    1.016790] TCP yeah registered
[    1.020104] TCP illinois registered
[    1.023438] NET: Registered protocol family 17
[    1.024617] ata9.00: ATAPI: HL-DT-ST GCE-8527B, 1.04, max UDMA/33
[    1.024651] ata9.01: ATAPI: TSSTcorpCD/DVDW SH-S182M, SB06, max UDMA/33
[    1.033976] NET: Registered protocol family 15
[    1.057894] ata9.00: configured for UDMA/33
[    1.067893] ata9.01: configured for UDMA/33
[    1.090351] Switched to high resolution mode on CPU 1
[    1.091097] Switched to high resolution mode on CPU 0
[    1.092055] ata7: SATA link down (SStatus 0 SControl 300)
[    1.092098] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.092641] ata1.00: ATA-7: WDC WD2500KS-00MJB0, 02.01C03, max UDMA/133
[    1.092644] ata1.00: 488397168 sectors, multi 16: LBA48 
[    1.093277] ata1.00: configured for UDMA/133
[    1.110570] scsi 0:0:0:0: Direct-Access     ATA      WDC WD2500KS-00M 02.0 PQ: 0 ANSI: 5
[    1.114714] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
[    1.118621] sd 0:0:0:0: [sda] Write Protect is off
[    1.122398] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.122425] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.126401]  sda: sda1 sda2
[    1.147955] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.469012] usb 5-1: new low speed USB device using uhci_hcd and address 2
[    1.638977] usb 5-1: New USB device found, idVendor=046d, idProduct=c312
[    1.642910] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    1.646869] usb 5-1: Product: USB Multimedia Keyboard
[    1.650779] usb 5-1: Manufacturer: BTC
[    1.654709] usb 5-1: configuration #1 chosen from 1 choice
[    1.676332] input: BTC USB Multimedia Keyboard as /devices/pci0000:00/0000:00:1d.0/usb5/5-1/5-1:1.0/input/input3
[    1.680667] generic-usb 0003:046D:C312.0001: input,hidraw0: USB HID v1.10 Keyboard [BTC USB Multimedia Keyboard] on usb-0000:00:1d.0-1/input0
[    1.730083] input: BTC USB Multimedia Keyboard as /devices/pci0000:00/0000:00:1d.0/usb5/5-1/5-1:1.1/input/input4
[    1.735029] generic-usb 0003:046D:C312.0002: input,hiddev96,hidraw1: USB HID v1.10 Device [BTC USB Multimedia Keyboard] on usb-0000:00:1d.0-1/input1
[    1.837016] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.842542] ata2.00: ATA-7: WDC WD2500KS-00MJB0, 02.01C03, max UDMA/133
[    1.847626] ata2.00: 488397168 sectors, multi 16: LBA48 
[    1.853381] ata2.00: configured for UDMA/133
[    1.880079] scsi 1:0:0:0: Direct-Access     ATA      WDC WD2500KS-00M 02.0 PQ: 0 ANSI: 5
[    1.885628] sd 1:0:0:0: [sdb] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
[    1.891057] sd 1:0:0:0: [sdb] Write Protect is off
[    1.896471] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    1.896503] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.902211]  sdb: sdb1 sdb2 < >
[    1.938583] sd 1:0:0:0: [sdb] Attached SCSI disk
[    1.954042] usb 5-2: new low speed USB device using uhci_hcd and address 3
[    2.117937] usb 5-2: New USB device found, idVendor=0764, idProduct=0501
[    2.123823] usb 5-2: New USB device strings: Mfr=3, Product=1, SerialNumber=0
[    2.129766] usb 5-2: Product:  CP 1350C
[    2.134998] usb 5-2: Manufacturer: CPS
[    2.140192] usb 5-2: configuration #1 chosen from 1 choice
[    2.303066] generic-usb 0003:0764:0501.0003: hiddev97,hidraw2: USB HID v1.10 Device [CPS  CP 1350C] on usb-0000:00:1d.0-2/input0
[    2.521011] usb 6-1: new low speed USB device using uhci_hcd and address 2
[    2.602053] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    2.610142] ata3.00: ATA-8: WDC WD5000AAKS-22A7B0, 01.03B01, max UDMA/133
[    2.616527] ata3.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    2.624184] ata3.00: configured for UDMA/133
[    2.641079] scsi 2:0:0:0: Direct-Access     ATA      WDC WD5000AAKS-2 01.0 PQ: 0 ANSI: 5
[    2.647820] sd 2:0:0:0: [sdc] 976773168 512-byte hardware sectors: (500 GB/465 GiB)
[    2.654327] sd 2:0:0:0: [sdc] Write Protect is off
[    2.660711] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    2.660743] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.667365]  sdc: sdc1 sdc2
[    2.688278] sd 2:0:0:0: [sdc] Attached SCSI disk
[    2.708030] usb 6-1: New USB device found, idVendor=046d, idProduct=c00c
[    2.714495] usb 6-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.720927] usb 6-1: Product: USB Mouse
[    2.727287] usb 6-1: Manufacturer: Logitech
[    2.733699] usb 6-1: configuration #1 chosen from 1 choice
[    2.758341] input: Logitech USB Mouse as /devices/pci0000:00/0000:00:1d.1/usb6/6-1/6-1:1.0/input/input5
[    2.765097] generic-usb 0003:046D:C00C.0004: input,hidraw3: USB HID v1.10 Mouse [Logitech USB Mouse] on usb-0000:00:1d.1-1/input0
[    3.370015] ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    3.377091] ata4.00: ATA-7: WDC WD2500KS-00MJB0, 02.01C03, max UDMA/133
[    3.383517] ata4.00: 488397168 sectors, multi 16: LBA48 
[    3.390421] ata4.00: configured for UDMA/133
[    3.417096] scsi 3:0:0:0: Direct-Access     ATA      WDC WD2500KS-00M 02.0 PQ: 0 ANSI: 5
[    3.423381] sd 3:0:0:0: [sdd] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
[    3.429478] sd 3:0:0:0: [sdd] Write Protect is off
[    3.435479] sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
[    3.435517] sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.441740]  sdd: unknown partition table
[    3.463357] sd 3:0:0:0: [sdd] Attached SCSI disk
[    4.162015] ata5: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    4.168883] ata5.00: ATA-8: WDC WD5000AAKS-00A7B0, 01.03B01, max UDMA/133
[    4.174963] ata5.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    4.181959] ata5.00: configured for UDMA/133
[    4.209073] scsi 4:0:0:0: Direct-Access     ATA      WDC WD5000AAKS-0 01.0 PQ: 0 ANSI: 5
[    4.215403] sd 4:0:0:0: [sde] 976773168 512-byte hardware sectors: (500 GB/465 GiB)
[    4.221521] sd 4:0:0:0: [sde] Write Protect is off
[    4.227559] sd 4:0:0:0: [sde] Mode Sense: 00 3a 00 00
[    4.227584] sd 4:0:0:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    4.233837]  sde: sde1 sde2
[    4.246165] sd 4:0:0:0: [sde] Attached SCSI disk
[    4.938014] ata6: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    4.944756] ata6.00: ATA-7: WDC WD2500KS-00MJB0, 02.01C03, max UDMA/133
[    4.950880] ata6.00: 488397168 sectors, multi 16: LBA48 
[    4.957477] ata6.00: configured for UDMA/133
[    4.985075] scsi 5:0:0:0: Direct-Access     ATA      WDC WD2500KS-00M 02.0 PQ: 0 ANSI: 5
[    4.991370] sd 5:0:0:0: [sdf] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
[    4.997428] sd 5:0:0:0: [sdf] Write Protect is off
[    5.003331] sd 5:0:0:0: [sdf] Mode Sense: 00 3a 00 00
[    5.003356] sd 5:0:0:0: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.009477]  sdf:<5>scsi 8:0:0:0: CD-ROM            HL-DT-ST CD-RW GCE-8527B  1.04 PQ: 0 ANSI: 5
[    5.015575] scsi 8:0:1:0: CD-ROM            TSSTcorp CD/DVDW SH-S182M SB06 PQ: 0 ANSI: 5
[    5.024442]  sdf1 sdf2
[    5.029907] sd 5:0:0:0: [sdf] Attached SCSI disk
[    5.183707] rtc_cmos 00:03: setting system clock to 2009-08-19 18:28:59 UTC (1250706539)
[    5.189798] Freeing unused kernel memory: 384k freed
[    5.318498] device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel@redhat.com
[    5.328988] fuse init (API version 7.11)
[    5.341688] xor: automatically using best checksumming function: generic_sse
[    5.346127]    generic_sse:  8392.000 MB/sec
[    5.346129] xor: using function: generic_sse (8392.000 MB/sec)
[    5.346454] async_tx: api initialized (async)
[    5.364133] raid6: int64x1   1800 MB/s
[    5.381142] raid6: int64x2   2714 MB/s
[    5.398149] raid6: int64x4   2078 MB/s
[    5.415145] raid6: int64x8   1847 MB/s
[    5.432140] raid6: sse2x1    4210 MB/s
[    5.449142] raid6: sse2x2    4476 MB/s
[    5.466130] raid6: sse2x4    7144 MB/s
[    5.466132] raid6: using algorithm sse2x4 (7144 MB/s)
[    5.467793] md: raid6 personality registered for level 6
[    5.467795] md: raid5 personality registered for level 5
[    5.467797] md: raid4 personality registered for level 4
[    5.472406] md: raid10 personality registered for level 10
[    5.615588] Driver 'sr' needs updating - please use bus_type methods
[    5.622646] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    5.622667] r8169 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    5.622688] r8169 0000:04:00.0: setting latency timer to 64
[    5.622841] r8169 0000:04:00.0: irq 29 for MSI/MSI-X
[    5.622952] eth0: RTL8168b/8111b at 0xffffc200100d4000, 00:16:17:d3:d0:e7, XID 38000000 IRQ 29
[    5.623060] sr0: scsi3-mmc drive: 40x/52x writer cd/rw xa/form2 cdda tray
[    5.623063] Uniform CD-ROM driver Revision: 3.20
[    5.623139] sr 8:0:0:0: Attached scsi CD-ROM sr0
[    5.625511] sr1: scsi3-mmc drive: 62x/62x writer dvd-ram cd/rw xa/form2 cdda tray
[    5.625565] sr 8:0:1:0: Attached scsi CD-ROM sr1
[    5.627819] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    5.627853] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    5.627888] sd 2:0:0:0: Attached scsi generic sg2 type 0
[    5.627922] sd 3:0:0:0: Attached scsi generic sg3 type 0
[    5.627957] sd 4:0:0:0: Attached scsi generic sg4 type 0
[    5.628005] sd 5:0:0:0: Attached scsi generic sg5 type 0
[    5.628039] sr 8:0:0:0: Attached scsi generic sg6 type 5
[    5.628071] sr 8:0:1:0: Attached scsi generic sg7 type 5
[    5.658545] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    5.658548] e100: Copyright(c) 1999-2006 Intel Corporation
[    5.658577] e100 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    5.701394] e100 0000:05:00.0: PME# disabled
[    5.701480] e100: eth1: e100_probe: addr 0xfebff000, irq 16, MAC addr 00:02:b3:8d:48:07
[    5.701509] ohci1394 0000:05:04.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[    5.755203] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[20]  MMIO=[febfe800-febfefff]  Max Packet=[2048]  IR/IT contexts=[4/8]
[    5.849984] md: bind<sdc1>
[    5.877118] md: bind<sdc2>
[    5.902731] md: bind<sde1>
[    5.904573] raid1: raid set md2 active with 2 out of 2 mirrors
[    5.909643] md: bind<sdf1>
[    5.911421] md: bind<sdf2>
[    5.932572] md: bind<sde2>
[    5.933917] md3: setting max_sectors to 128, segment boundary to 32767
[    5.933921] raid0: looking at sde2
[    5.933923] raid0:   comparing sde2(976350208)<6> with sde2(976350208)
[    5.933926] raid0:   END
[    5.933927] raid0:   ==> UNIQUE
[    5.933928] raid0: 1 zones
[    5.933930] raid0: looking at sdc2
[    5.933932] raid0:   comparing sdc2(976350208)<6> with sde2(976350208)
[    5.933935] raid0:   EQUAL
[    5.933936] raid0: FINAL 1 zones
[    5.933938] raid0: done.
[    5.933940] raid0 : md_size is 1952700416 sectors.
[    5.933942] raid0 : conf->spacing is 1952700416 sectors.
[    5.933944] raid0 : nb_zone is 1.
[    5.933945] raid0 : Allocating 8 bytes for hash.
[    5.958943] md: bind<sda2>
[    5.959117] md: bind<sda1>
[    5.979243] md1: setting max_sectors to 128, segment boundary to 32767
[    5.979247] raid0: looking at sda2
[    5.979249] raid0:   comparing sda2(487990272)<6> with sda2(487990272)
[    5.979252] raid0:   END
[    5.979253] raid0:   ==> UNIQUE
[    5.979255] raid0: 1 zones
[    5.979256] raid0: looking at sdf2
[    5.979258] raid0:   comparing sdf2(487990272)<6> with sda2(487990272)
[    5.979260] raid0:   EQUAL
[    5.979262] raid0: FINAL 1 zones
[    5.979264] raid0: done.
[    5.979266] raid0 : md_size is 975980544 sectors.
[    5.979269] raid0 : conf->spacing is 975980544 sectors.
[    5.979270] raid0 : nb_zone is 1.
[    5.979272] raid0 : Allocating 8 bytes for hash.
[    5.980408] raid1: raid set md0 active with 2 out of 2 mirrors
[    6.030719]  md2: unknown partition table
[    6.037804]  md1: unknown partition table
[    6.041751]  md0: unknown partition table
[    6.068642]  md3: unknown partition table
[    7.018162] ieee1394: Host added: ID:BUS[0-00:1023]  GUID[0010dc00010457f8]
[    7.061663] PM: Starting manual resume from disk
[    7.064424] EXT4-fs: barriers enabled
[    7.074626] kjournald2 starting: pid 3223, dev dm-5:8, commit interval 5 seconds
[    7.074639] EXT4-fs: delayed allocation enabled
[    7.074642] EXT4-fs: file extents enabled
[    7.074788] EXT4-fs: mballoc enabled
[    7.074802] EXT4-fs: mounted filesystem dm-5 with ordered data mode
[    8.394730] udev: starting version 141
[    8.607493] nvidia: module license 'NVIDIA' taints kernel.
[    8.607498] Disabling lock debugging due to kernel taint
[    8.634600] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    8.634725] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    8.640466] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    8.994059] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    8.994684] HDA Intel 0000:00:1b.0: irq 30 for MSI/MSI-X
[    8.994715] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    9.057771] hda_codec: Unknown model for ALC883, trying auto-probe from BIOS...
[    9.057942] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/input/input6
[    9.083984] nvidia 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.083995] nvidia 0000:01:00.0: setting latency timer to 64
[    9.084354] NVRM: loading NVIDIA UNIX x86_64 Kernel Module  185.18.31  Tue Jul 28 17:52:27 PDT 2009
[   10.440559] i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[   10.486046] f71882fg: Found f71882fg chip at 0xa10, revision 32
[   10.486316] f71882fg f71882fg.2576: Fan: 1 is in duty-cycle mode
[   10.486320] f71882fg f71882fg.2576: Fan: 2 is in duty-cycle mode
[   10.486323] f71882fg f71882fg.2576: Fan: 3 is in duty-cycle mode
[   10.486326] f71882fg f71882fg.2576: Fan: 4 is in duty-cycle mode
[   10.500843] netconsole: local port 6665
[   10.500848] netconsole: local IP 192.168.0.1
[   10.500850] netconsole: interface eth0
[   10.500852] netconsole: remote port 514
[   10.500855] netconsole: remote IP 192.168.0.221
[   10.500857] netconsole: remote ethernet address 00:0d:88:64:b8:d3
[   10.500861] netconsole: device eth0 not up yet, forcing it
[   10.501083] r8169: eth0: link up
[   10.501089] r8169: eth0: link up
[   10.502309] netconsole: carrier detect appears untrustworthy, waiting 4 seconds
[   10.704236] e100: eth1 NIC Link is Up 100 Mbps Full Duplex
[   14.506026] console [netcon0] enabled
[   14.512246] netconsole: network logging started
[   14.770052] Adding 3145720k swap on /dev/mapper/vg0-swap.  Priority:-1 extents:1 across:3145720k 
[   15.387243] EXT4 FS on dm-5, internal journal on dm-5:8
[   16.527199] EXT4-fs: barriers enabled
[   16.536649] kjournald2 starting: pid 5389, dev dm-3:8, commit interval 5 seconds
[   16.536844] EXT4 FS on dm-3, internal journal on dm-3:8
[   16.536847] EXT4-fs: delayed allocation enabled
[   16.536850] EXT4-fs: file extents enabled
[   16.537244] EXT4-fs: mballoc enabled
[   16.537260] EXT4-fs: mounted filesystem dm-3 with ordered data mode
[   16.554360] EXT4-fs: barriers enabled
[   16.564822] kjournald2 starting: pid 5390, dev dm-0:8, commit interval 5 seconds
[   16.565007] EXT4 FS on dm-0, internal journal on dm-0:8
[   16.565010] EXT4-fs: delayed allocation enabled
[   16.565012] EXT4-fs: file extents enabled
[   16.567658] EXT4-fs: mballoc enabled
[   16.567673] EXT4-fs: mounted filesystem dm-0 with ordered data mode
[   16.578518] EXT4-fs: barriers enabled
[   16.584093] kjournald2 starting: pid 5391, dev dm-2:8, commit interval 5 seconds
[   16.584296] EXT4 FS on dm-2, internal journal on dm-2:8
[   16.584298] EXT4-fs: delayed allocation enabled
[   16.584300] EXT4-fs: file extents enabled
[   16.584451] EXT4-fs: mballoc enabled
[   16.584464] EXT4-fs: mounted filesystem dm-2 with ordered data mode
[   16.588407] EXT4-fs: barriers enabled
[   16.591760] kjournald2 starting: pid 5392, dev dm-4:8, commit interval 5 seconds
[   16.591961] EXT4 FS on dm-4, internal journal on dm-4:8
[   16.591964] EXT4-fs: delayed allocation enabled
[   16.591966] EXT4-fs: file extents enabled
[   16.592052] EXT4-fs: mballoc enabled
[   16.592065] EXT4-fs: mounted filesystem dm-4 with ordered data mode
[   16.593618] EXT4-fs: barriers enabled
[   16.598778] kjournald2 starting: pid 5393, dev dm-7:8, commit interval 5 seconds
[   16.598976] EXT4 FS on dm-7, internal journal on dm-7:8
[   16.598979] EXT4-fs: delayed allocation enabled
[   16.598981] EXT4-fs: file extents enabled
[   16.599676] EXT4-fs: mballoc enabled
[   16.599689] EXT4-fs: mounted filesystem dm-7 with ordered data mode
[   16.613323] kjournald starting.  Commit interval 5 seconds
[   16.662738] EXT3 FS on md2, internal journal
[   16.662744] EXT3-fs: mounted filesystem with writeback data mode.
[   17.511110] EXT4-fs: barriers enabled
[   17.521147] kjournald2 starting: pid 5410, dev dm-10:8, commit interval 5 seconds
[   17.521332] EXT4 FS on dm-10, internal journal on dm-10:8
[   17.521335] EXT4-fs: delayed allocation enabled
[   17.521337] EXT4-fs: file extents enabled
[   17.522890] EXT4-fs: mballoc enabled
[   17.522906] EXT4-fs: mounted filesystem dm-10 with ordered data mode
[   22.347094] Bridge firewalling registered
[   22.349970] device eth0 entered promiscuous mode
[   22.352962] br0: port 1(eth0) entering learning state
[   23.425669] NET: Registered protocol family 10
[   23.425825] lo: Disabled Privacy Extensions
[   33.572072] RPC: Registered udp transport module.
[   33.572074] RPC: Registered tcp transport module.
[   33.627093] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   33.671003] eth0: no IPv6 routers present
[   34.065013] br0: no IPv6 routers present
[   34.343028] eth1: no IPv6 routers present
[   37.352007] br0: port 1(eth0) entering forwarding state
[   40.624730] kjournald starting.  Commit interval 5 seconds
[   40.624744] EXT3 FS on loop0, internal journal
[   40.624748] EXT3-fs: mounted filesystem with writeback data mode.
[   41.152968] svc: failed to register lockdv1 RPC service (errno 97).
[   43.016748] Bluetooth: Core ver 2.15
[   43.018111] NET: Registered protocol family 31
[   43.018114] Bluetooth: HCI device and connection manager initialized
[   43.018117] Bluetooth: HCI socket layer initialized
[   43.030150] Bluetooth: L2CAP ver 2.13
[   43.030152] Bluetooth: L2CAP socket layer initialized
[   43.036233] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   43.036236] Bluetooth: BNEP filters: protocol multicast
[   43.053474] Bluetooth: SCO (Voice Link) ver 0.6
[   43.053477] Bluetooth: SCO socket layer initialized
[   43.355260] warning: `dhcpd3' uses 32-bit capabilities (legacy support in use)
[   46.031969] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   46.032981] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
[   46.032984] nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack module option or
[   46.032987] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
[   46.171814] Netfilter messages via NETLINK v0.30.
[   46.175122] ctnetlink v0.93: registering with nfnetlink.
[   46.274012] ip_tables: (C) 2000-2006 Netfilter Core Team
[   46.314164] Ebtables v2.0 registered
[   46.745444] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.756588] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.757862] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.759230] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.760447] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.761479] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.762675] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.763710] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.764928] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.765989] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.788666] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.790720] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.792690] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.794183] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.797501] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   46.808203] physdev match: using --physdev-out in the OUTPUT, FORWARD and POSTROUTING chains for non-bridged traffic is not supported anymore.
[   51.466763] tun: Universal TUN/TAP device driver, 1.6
[   51.466771] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   51.554970] device tap0 entered promiscuous mode
[   51.562932] br0: port 2(tap0) entering learning state
[   61.943007] tap0: no IPv6 routers present
[   66.562008] br0: port 2(tap0) entering forwarding state
[  188.037005] tap1: no IPv6 routers present
[  604.446194] br0: port 2(tap0) entering disabled state
[  604.464975] br0: port 2(tap0) entering disabled state
[  608.171021] br0: port 1(eth0) entering disabled state
[  608.220021] device eth0 left promiscuous mode
[  608.220027] br0: port 1(eth0) entering disabled state
[  608.254047] e100 0000:05:00.0: PCI INT A disabled
[  610.262158] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[  610.262163] e100: Copyright(c) 1999-2006 Intel Corporation
[  610.262203] e100 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[  610.262212] e100: 0000:05:00.0: e100_probe: using i/o access mode
[  610.292593] e100 0000:05:00.0: PME# disabled
[  610.292928] e100: eth1: e100_probe: addr 0xec00, irq 16, MAC addr 00:02:b3:8d:48:07
[  610.391181] ADDRCONF(NETDEV_UP): eth1: link is not ready
[  612.701223] e100: eth1 NIC Link is Up 100 Mbps Full Duplex
[  612.702538] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[  623.121006] eth1: no IPv6 routers present
[  653.265277] device eth0 entered promiscuous mode
[  653.289450] r8169: eth0: link up
[  653.291979] br0: port 1(eth0) entering learning state
[  663.718008] eth0: no IPv6 routers present
[  663.878004] br0: no IPv6 routers present
[  668.291009] br0: port 1(eth0) entering forwarding state
[ 1328.222191] br0: port 1(eth0) entering disabled state
[ 1328.253472] device eth0 left promiscuous mode
[ 1328.253479] br0: port 1(eth0) entering disabled state
[ 1336.066201] e100 0000:05:00.0: PCI INT A disabled
[ 1339.306300] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[ 1339.306305] e100: Copyright(c) 1999-2006 Intel Corporation
[ 1339.306345] e100 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[ 1339.337539] e100 0000:05:00.0: PME# disabled
[ 1339.337699] e100: eth1: e100_probe: addr 0xfebff000, irq 16, MAC addr 00:02:b3:8d:48:07
[ 1339.395030] ADDRCONF(NETDEV_UP): eth1: link is not ready
[ 1341.704232] e100: eth1 NIC Link is Up 100 Mbps Full Duplex
[ 1341.705560] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[ 1348.231171] device eth0 entered promiscuous mode
[ 1348.233317] r8169: eth0: link up
[ 1348.237116] br0: port 1(eth0) entering learning state
[ 1358.297129] br0: no IPv6 routers present
[ 1359.157130] eth0: no IPv6 routers present
[ 1363.237131] br0: port 1(eth0) entering forwarding state
[ 1384.161011] br0: port 1(eth0) entering disabled state
[ 1384.194844] device eth0 left promiscuous mode
[ 1384.194850] br0: port 1(eth0) entering disabled state
[ 1384.325211] ADDRCONF(NETDEV_UP): eth1: link is not ready
[ 1384.371575] device eth0 entered promiscuous mode
[ 1384.373224] r8169: eth0: link up
[ 1384.377223] br0: port 1(eth0) entering learning state
[ 1395.181005] br0: no IPv6 routers present
[ 1395.239005] eth0: no IPv6 routers present
[ 1395.613990] ADDRCONF(NETDEV_UP): eth1: link is not ready
[ 1397.704232] e100: eth1 NIC Link is Up 100 Mbps Full Duplex
[ 1397.705557] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[ 1399.377010] br0: port 1(eth0) entering forwarding state
[ 1407.797005] eth1: no IPv6 routers present
[ 1443.531430] device tap1 entered promiscuous mode
[ 1443.536931] br0: port 2(tap1) entering learning state
[ 1448.309009] tap0: no IPv6 routers present
[ 1453.974007] tap1: no IPv6 routers present
[ 1458.536072] br0: port 2(tap1) entering forwarding state
[43624.334005] tap0: no IPv6 routers present

------=_Part_3_1037504760.1250769263096--
