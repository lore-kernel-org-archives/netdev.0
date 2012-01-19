From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Thu, 19 Jan 2012 10:42:03 +0100
Message-ID: <4F17E56B.1050501@broadcom.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
 <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
 <4F142D84.4060405@broadcom.com> <4F145F52.9010200@broadcom.com>
 <CA+55aFyMY5o7irG+=c4ZrfftMu6OJvoyFFY4KNO8rCe90P0mhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=------------040405090007000003050001
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	"Larry Finger" <Larry.Finger@lwfinger.net>,
	"Network Development" <netdev@vger.kernel.org>,
	dri-devel@lists.freedesktop.org, "David Airlie" <airlied@linux.ie>,
	"Jerome Glisse" <jglisse@redhat.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2825 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755929Ab2ASJmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 04:42:21 -0500
In-Reply-To: <CA+55aFyMY5o7irG+=c4ZrfftMu6OJvoyFFY4KNO8rCe90P0mhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--------------040405090007000003050001
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit

On 01/17/2012 02:12 AM, Linus Torvalds wrote:
> 2012/1/16 Arend van Spriel <arend@broadcom.com>:
>>
>> I build a new kernel with MCE enabled. Same issue. I did not load bcma
>> or brcmsmac yet. Attached is trace I could pull from the kernel log
>> (str-test-*).
> 
> Oh well. Everything looks fine in the test traces - the warnings are
> annoying and nasty, but a known issue and not dangerous (and I have a
> patch in my tree to fix them now).
> 
> So if the real suspend fails, it's some other subsystem that has
> gotten broken. I don't think I have any other reports like that yet,
> and there is not a lot to go on. If you could try to bisect it (I
> assume plain Linux-3.2 works fine?) that woudl be wonderful, otherwise
> I think we're stuck waiting for somebody else to hit it and figure it
> out.
> 
>                  Linus
> 

Hi Linus,

No trivial bisect. I wish I had a faster build machine, but alas. I
suspected some issue in DRM and the bisect took me into drm-core-next
branch. I ended up at the following commit:

dc97b3409a790d2a21aac6e5cdb99558b5944119 is the first bad commit
commit dc97b3409a790d2a21aac6e5cdb99558b5944119
Author: Jerome Glisse <jglisse@redhat.com>
Date:   Fri Nov 18 11:47:03 2011 -0500

    drm/ttm: callback move_notify any time bo placement change v4

    Previously we were calling back move_notify in error path when the
    bo is returned to it's original position or when destroy the bo.
    When destroying the bo set the new mem placement as NULL when calling
    back in the driver.

    Updating nouveau to deal with NULL placement properly.

    v2: reserve the object before calling move_notify in bo destroy path
        at that point ttm should be the only piece of code interacting
        with the object so atomic_set is safe here.
    v3: callback move notify only once the bo is in its new position
        call move notify want swaping out the buffer
    v4:- don't call move_notify when swapin out bo, assume driver should
         do what is appropriate in swap notify
       - move move_notify call back to ttm_bo_cleanup_memtype_use for
         destroy path

    Reviewed-by: Jerome Glisse <jglisse@redhat.com>
    Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>

Actually, this commit was already bothering my bisect as it gave me a
NULL pointer deref on system startup. I patched it to proceed the bisect
(see attached diff). The NULL deref was fixed in the drm-nouveau-next
branch (f7b24c4 drm/nouveau/ttm: fix crash as a result of a recent ttm
change). However, the suspend/resume issue was not resolved.

Gr. AvS
---------------------
01:00.0 VGA compatible controller: nVidia Corporation GT218 [NVS 3100M]
(rev a2) (prog-if 00 [VGA controller])
        Subsystem: Dell Device 040a
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at e2000000 (32-bit, non-prefetchable) [size=16M]
        Region 1: Memory at d0000000 (64-bit, prefetchable) [size=256M]
        Region 3: Memory at e0000000 (64-bit, prefetchable) [size=32M]
        Region 5: I/O ports at 7000 [size=128]
        Expansion ROM at e3000000 [disabled] [size=512K]
        Capabilities: <access denied>
        Kernel driver in use: nouveau
        Kernel modules: nouveau, nvidiafb

--------------040405090007000003050001
Content-Type: text/plain;
 name=nouveau_bo.diff
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=nouveau_bo.diff

diff --git a/drivers/gpu/drm/nouveau/nouveau_bo.c b/drivers/gpu/drm/nouveau/nouveau_bo.c
index b1b33a1..680b2f7 100644
--- a/drivers/gpu/drm/nouveau/nouveau_bo.c
+++ b/drivers/gpu/drm/nouveau/nouveau_bo.c
@@ -810,7 +810,7 @@ out:
 static void
 nouveau_bo_move_ntfy(struct ttm_buffer_object *bo, struct ttm_mem_reg *new_mem)
 {
-	struct nouveau_mem *node = new_mem->mm_node;
+	struct nouveau_mem *node;
 	struct nouveau_bo *nvbo = nouveau_bo(bo);
 	struct nouveau_vma *vma;
 
@@ -820,6 +820,7 @@ nouveau_bo_move_ntfy(struct ttm_buffer_object *bo, struct ttm_mem_reg *new_mem)
 		} else
 		if (new_mem && new_mem->mem_type == TTM_PL_TT &&
 		    nvbo->page_shift == vma->vm->spg_shift) {
+			node = new_mem->mm_node;
 			nouveau_vm_map_sg(vma, 0, new_mem->
 					  num_pages << PAGE_SHIFT,
 					  node, node->pages);

--------------040405090007000003050001
Content-Type: text/plain;
 name=dmesg-3.2.0-rc1-00070-gdc97b34-dirty.txt
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=dmesg-3.2.0-rc1-00070-gdc97b34-dirty.txt

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0-rc1-00070-gdc97b34-dirty (root@arend-vb-linux) (gcc version 4.6.1 (Ubuntu/Linaro 4.6.1-9ubuntu3) ) #18 SMP Wed Jan 18 19:42:00 CET 2012
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009ac00 (usable)
[    0.000000]  BIOS-e820: 000000000009ac00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000cf65f000 (usable)
[    0.000000]  BIOS-e820: 00000000cf65f000 - 00000000cf67f000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cf67f000 - 00000000cf76f000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000cf76f000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000f8000000 - 00000000fc000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed10000 - 00000000fed14000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed18000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff800000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 000000012c000000 (usable)
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: non-PAE kernel!
[    0.000000] DMI 2.6 present.
[    0.000000] DMI: Dell Inc. Latitude E6410/07XJP9, BIOS A07 02/15/2011
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] last_pfn = 0xcf65f max_arch_pfn = 0x100000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 080000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FF0000000 write-back
[    0.000000]   3 base 100000000 mask FE0000000 write-back
[    0.000000]   4 base 120000000 mask FF0000000 write-back
[    0.000000]   5 base 12C000000 mask FFC000000 uncachable
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820 update range: 00000000d0000000 - 0000000100000000 (usable) ==> (reserved)
[    0.000000] found SMP MP-table at [c00f2200] f2200
[    0.000000] initial memory mapped : 0 - 01c00000
[    0.000000] Base memory trampoline at [c0096000] 96000 size 16384
[    0.000000] init_memory_mapping: 0000000000000000-00000000377fe000
[    0.000000]  0000000000 - 0000400000 page 4k
[    0.000000]  0000400000 - 0037400000 page 2M
[    0.000000]  0037400000 - 00377fe000 page 4k
[    0.000000] kernel direct mapping tables up to 377fe000 @ 1bfb000-1c00000
[    0.000000] RAMDISK: 37c09000 - 37ff0000
[    0.000000] Allocated new RAMDISK: 37417000 - 377fd64f
[    0.000000] Move RAMDISK from 0000000037c09000 - 0000000037fef64e to 37417000 - 377fd64e
[    0.000000] ACPI: RSDP 000fe300 00024 (v02 DELL  )
[    0.000000] ACPI: XSDT cf67de18 00064 (v01 DELL    E2      06222004 MSFT 00010013)
[    0.000000] ACPI: FACP cf75fc18 000F4 (v04 DELL    E2      06222004 MSFT 00010013)
[    0.000000] ACPI Warning: 32/64 FACS address mismatch in FADT - two FACS tables! (20110623/tbfadt-369)
[    0.000000] ACPI Warning: 32/64X FACS address mismatch in FADT - 0xCF76BF40/0x00000000CF76ED40, using 32 (20110623/tbfadt-489)
[    0.000000] ACPI: DSDT cf73e018 0A24E (v01 DELL    E2      00001001 INTL 20080729)
[    0.000000] ACPI: FACS cf76bf40 00040
[    0.000000] ACPI: APIC cf67cf18 0008C (v02 DELL    E2      06222004 MSFT 00010013)
[    0.000000] ACPI: TCPA cf76dd18 00032 (v02                 00000000      00000000)
[    0.000000] ACPI: MCFG cf76dc98 0003C (v01 A M I  GMCH945. 06222004 MSFT 00000097)
[    0.000000] ACPI: HPET cf76dc18 00038 (v01 DELL    E2      00000001 ASL  00000061)
[    0.000000] ACPI: BOOT cf76db98 00028 (v01 DELL   E2       06222004 AMI  00010013)
[    0.000000] ACPI: SLIC cf766818 00176 (v03 DELL    E2      06222004 MSFT 00010013)
[    0.000000] ACPI: SSDT cf74d018 009F1 (v01  PmRef    CpuPm 00003000 INTL 20080729)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 2430MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x000cf65f
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009a
[    0.000000]     0: 0x00000100 -> 0x000cf65f
[    0.000000] On node 0 totalpages: 849385
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3946 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 4861 pages used for memmap
[    0.000000]   HighMem zone: 617316 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x04] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x06] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] disabled)
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] SMP: Allowing 8 CPUs, 4 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009a000 - 000000000009b000
[    0.000000] PM: Registered nosave memory: 000000000009b000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at d0000000 (gap: d0000000:28000000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:8 nr_node_ids:1
[    0.000000] PERCPU: Embedded 13 pages/cpu @f5400000 s30592 r0 d22656 u524288
[    0.000000] pcpu-alloc: s30592 r0 d22656 u524288 alloc=1*4194304
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 842748
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.2.0-rc1-00070-gdc97b34-dirty root=UUID=7051116f-03ec-4df3-a8ff-813fb03aec9f ro ignore_loglevel console=tty0 console=ttyS0,115200
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:000cf65f)
[    0.000000] Memory: 3357100k/3398012k available (4807k kernel code, 40440k reserved, 2264k data, 556k init, 2488708k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff16000 - 0xfffff000   ( 932 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc16e8000 - 0xc1773000   ( 556 kB)
[    0.000000]       .data : 0xc14b1f2a - 0xc16e7f80   (2264 kB)
[    0.000000]       .text : 0xc1000000 - 0xc14b1f2a   (4807 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] NR_IRQS:2304 nr_irqs:744 16
[    0.000000] CPU 0 irqstacks, hard=f500a000 soft=f500c000
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] allocated 13631488 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.004000] Detected 2792.471 MHz processor.
[    0.000001] Calibrating delay loop (skipped), value calculated using timer frequency.. 5584.94 BogoMIPS (lpj=11169884)
[    0.010816] pid_max: default: 32768 minimum: 301
[    0.015507] Security Framework initialized
[    0.019667] AppArmor: AppArmor initialized
[    0.023850] Mount-cache hash table entries: 512
[    0.028538] Initializing cgroup subsys cpuacct
[    0.033041] Initializing cgroup subsys memory
[    0.037456] Initializing cgroup subsys devices
[    0.041952] Initializing cgroup subsys freezer
[    0.046448] Initializing cgroup subsys net_cls
[    0.050962] CPU: Physical Processor ID: 0
[    0.055208] CPU: Processor Core ID: 0
[    0.058926] mce: CPU supports 9 MCE banks
[    0.062996] CPU0: Thermal monitoring handled by SMI
[    0.067929] using mwait in idle threads.
[    0.073143] ACPI: Core revision 20110623
[    0.081604] ftrace: allocating 20148 entries in 40 pages
[    0.091886] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.097734] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
[    0.143221] CPU0: Intel(R) Core(TM) i7 CPU       M 640  @ 2.80GHz stepping 05
[    0.256222] Performance Events: PEBS fmt1+, Westmere events, Intel PMU driver.
[    0.263689] ... version:                3
[    0.267747] ... bit width:              48
[    0.271895] ... generic registers:      4
[    0.277626] ... value mask:             0000ffffffffffff
[    0.282987] ... max period:             000000007fffffff
[    0.288345] ... fixed-purpose events:   3
[    0.292406] ... event mask:             000000070000000f
[    0.297891] CPU 1 irqstacks, hard=f41ce000 soft=f41d8000
[    0.303251] Booting Node   0, Processors  #1
[    0.307452] smpboot cpu 1: start_ip = 96000
[    0.322208] Initializing CPU#1
[    0.403979] CPU1: Thermal monitoring handled by SMI
[    0.428964] CPU 2 irqstacks, hard=f41e2000 soft=f41e4000
[    0.434327]  #2
[    0.435952] smpboot cpu 2: start_ip = 96000
[    0.450570] Initializing CPU#2
[    0.531756] CPU2: Thermal monitoring handled by SMI
[    0.556762] CPU 3 irqstacks, hard=f41ee000 soft=f41f0000
[    0.562124]  #3
[    0.563749] smpboot cpu 3: start_ip = 96000
[    0.578366] Initializing CPU#3
[    0.659530] CPU3: Thermal monitoring handled by SMI
[    0.684405] Brought up 4 CPUs
[    0.687427] Total of 4 processors activated (22342.55 BogoMIPS).
[    0.695545] devtmpfs: initialized
[    0.699018] PM: Registering ACPI NVS region at cf67f000 (983040 bytes)
[    0.706277] print_constraints: dummy:
[    0.710243] RTC time:  9:35:48, date: 01/19/12
[    0.714762] NET: Registered protocol family 16
[    0.719309] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.726931] ACPI: bus type pci registered
[    0.731041] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.740397] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.747228] PCI: Using MMCONFIG for extended config space
[    0.752677] PCI: Using configuration type 1 for base access
[    0.758302] dmi type 0xB1 record - unknown flag
[    0.763433] bio: create slab <bio-0> at 0
[    0.767544] ACPI: Added _OSI(Module Device)
[    0.771778] ACPI: Added _OSI(Processor Device)
[    0.776273] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.781025] ACPI: Added _OSI(Processor Aggregator Device)
[    0.787589] ACPI: EC: Look up EC in DSDT
[    0.819265] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.887417] ACPI: SSDT cf7eaa18 004B6 (v01  PmRef  Cpu0Ist 00003000 INTL 20080729)
[    0.895428] ACPI: Dynamic OEM Table Load:
[    0.899615] ACPI: SSDT   (null) 004B6 (v01  PmRef  Cpu0Ist 00003000 INTL 20080729)
[    0.907469] ACPI: SSDT cf7e8018 00891 (v01  PmRef  Cpu0Cst 00003001 INTL 20080729)
[    0.915461] ACPI: Dynamic OEM Table Load:
[    0.919644] ACPI: SSDT   (null) 00891 (v01  PmRef  Cpu0Cst 00003001 INTL 20080729)
[    0.951246] ACPI: SSDT cf7e9a98 00303 (v01  PmRef    ApIst 00003000 INTL 20080729)
[    0.959296] ACPI: Dynamic OEM Table Load:
[    0.963484] ACPI: SSDT   (null) 00303 (v01  PmRef    ApIst 00003000 INTL 20080729)
[    0.983086] ACPI: SSDT cf7e7d98 00119 (v01  PmRef    ApCst 00003000 INTL 20080729)
[    0.991100] ACPI: Dynamic OEM Table Load:
[    0.995286] ACPI: SSDT   (null) 00119 (v01  PmRef    ApCst 00003000 INTL 20080729)
[    1.086872] ACPI: Interpreter enabled
[    1.090595] ACPI: (supports S0 S3 S4 S5)
[    1.094843] ACPI: Using IOAPIC for interrupt routing
[    1.767048] ACPI: EC: GPE = 0x10, I/O: command/status = 0x934, data = 0x930
[    1.794594] ACPI: No dock devices found.
[    1.798568] HEST: Table not found.
[    1.802023] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.811478] \_SB_.PCI0:_OSC invalid UUID
[    1.815453] _OSC request data:1 8 1f
[    1.819420] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    1.826094] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    1.832755] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    1.839415] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    1.846779] pci_root PNP0A08:00: host bridge window [mem 0xd0000000-0xfeafffff]
[    1.854151] pci 0000:00:00.0: [8086:0044] type 0 class 0x000600
[    1.860145] pci 0000:00:01.0: [8086:0045] type 1 class 0x000604
[    1.866132] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    1.872272] pci 0000:00:01.0: PME# disabled
[    1.876555] pci 0000:00:19.0: [8086:10ea] type 0 class 0x000200
[    1.882543] pci 0000:00:19.0: reg 10: [mem 0xe9600000-0xe961ffff]
[    1.888693] pci 0000:00:19.0: reg 14: [mem 0xe9680000-0xe9680fff]
[    1.894842] pci 0000:00:19.0: reg 18: [io  0x8040-0x805f]
[    1.900353] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
[    1.906497] pci 0000:00:19.0: PME# disabled
[    1.910755] pci 0000:00:1a.0: [8086:3b3c] type 0 class 0x000c03
[    1.916743] pci 0000:00:1a.0: reg 10: [mem 0xe9670000-0xe96703ff]
[    1.922968] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    1.929109] pci 0000:00:1a.0: PME# disabled
[    1.933371] pci 0000:00:1b.0: [8086:3b56] type 0 class 0x000403
[    1.939355] pci 0000:00:1b.0: reg 10: [mem 0xe9660000-0xe9663fff 64bit]
[    1.946085] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    1.952225] pci 0000:00:1b.0: PME# disabled
[    1.956484] pci 0000:00:1c.0: [8086:3b42] type 1 class 0x000604
[    1.962526] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    1.968669] pci 0000:00:1c.0: PME# disabled
[    1.972929] pci 0000:00:1c.1: [8086:3b44] type 1 class 0x000604
[    1.978969] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    1.985112] pci 0000:00:1c.1: PME# disabled
[    1.989370] pci 0000:00:1c.2: [8086:3b46] type 1 class 0x000604
[    1.995409] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    2.001554] pci 0000:00:1c.2: PME# disabled
[    2.005813] pci 0000:00:1c.3: [8086:3b48] type 1 class 0x000604
[    2.011852] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    2.017992] pci 0000:00:1c.3: PME# disabled
[    2.022260] pci 0000:00:1d.0: [8086:3b34] type 0 class 0x000c03
[    2.028249] pci 0000:00:1d.0: reg 10: [mem 0xe9650000-0xe96503ff]
[    2.034471] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    2.040611] pci 0000:00:1d.0: PME# disabled
[    2.044867] pci 0000:00:1e.0: [8086:2448] type 1 class 0x000604
[    2.050903] pci 0000:00:1f.0: [8086:3b07] type 0 class 0x000601
[    2.056982] pci 0000:00:1f.2: [8086:3b2f] type 0 class 0x000106
[    2.062971] pci 0000:00:1f.2: reg 10: [io  0x8090-0x8097]
[    2.068427] pci 0000:00:1f.2: reg 14: [io  0x8080-0x8083]
[    2.073883] pci 0000:00:1f.2: reg 18: [io  0x8070-0x8077]
[    2.079337] pci 0000:00:1f.2: reg 1c: [io  0x8060-0x8063]
[    2.084791] pci 0000:00:1f.2: reg 20: [io  0x8020-0x803f]
[    2.090247] pci 0000:00:1f.2: reg 24: [mem 0xe9640000-0xe96407ff]
[    2.096429] pci 0000:00:1f.2: PME# supported from D3hot
[    2.101706] pci 0000:00:1f.2: PME# disabled
[    2.105957] pci 0000:00:1f.3: [8086:3b30] type 0 class 0x000c05
[    2.111941] pci 0000:00:1f.3: reg 10: [mem 0xe9630000-0xe96300ff 64bit]
[    2.118630] pci 0000:00:1f.3: reg 20: [io  0x8000-0x801f]
[    2.124120] pci 0000:00:1f.6: [8086:3b32] type 0 class 0x001180
[    2.130112] pci 0000:00:1f.6: reg 10: [mem 0xe9620000-0xe9620fff 64bit]
[    2.136878] pci 0000:01:00.0: [10de:0a6c] type 0 class 0x000300
[    2.142850] pci 0000:01:00.0: reg 10: [mem 0xe2000000-0xe2ffffff]
[    2.148997] pci 0000:01:00.0: reg 14: [mem 0xd0000000-0xdfffffff 64bit pref]
[    2.156096] pci 0000:01:00.0: reg 1c: [mem 0xe0000000-0xe1ffffff 64bit pref]
[    2.163191] pci 0000:01:00.0: reg 24: [io  0x7000-0x707f]
[    2.168643] pci 0000:01:00.0: reg 30: [mem 0xe3000000-0xe307ffff pref]
[    2.175248] pci 0000:01:00.1: [10de:0be3] type 0 class 0x000403
[    2.181222] pci 0000:01:00.1: reg 10: [mem 0xe3080000-0xe3083fff]
[    2.187417] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    2.192689] pci 0000:00:01.0:   bridge window [io  0x7000-0x7fff]
[    2.198825] pci 0000:00:01.0:   bridge window [mem 0xd0000000-0xe30fffff]
[    2.205708] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    2.210978] pci 0000:00:1c.0:   bridge window [io  0x6000-0x6fff]
[    2.217117] pci 0000:00:1c.0:   bridge window [mem 0xe8200000-0xe95fffff]
[    2.224073] pci 0000:03:00.0: [14e4:4353] type 0 class 0x000280
[    2.230105] pci 0000:03:00.0: reg 10: [mem 0xe6e00000-0xe6e03fff 64bit]
[    2.236963] pci 0000:03:00.0: supports D1 D2
[    2.241278] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    2.247448] pci 0000:03:00.0: PME# disabled
[    2.251780] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    2.257053] pci 0000:00:1c.1:   bridge window [io  0x5000-0x5fff]
[    2.263192] pci 0000:00:1c.1:   bridge window [mem 0xe6e00000-0xe81fffff]
[    2.270148] pci 0000:04:00.0: [1180:e476] type 2 class 0x000607
[    2.276177] pci 0000:04:00.0: reg 10: [mem 0xe5940000-0xe5940fff]
[    2.282411] pci 0000:04:00.0: supports D1 D2
[    2.286729] pci 0000:04:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.293434] pci 0000:04:00.0: PME# disabled
[    2.297755] pci 0000:04:00.1: [1180:e822] type 0 class 0x000805
[    2.303783] pci 0000:04:00.1: reg 10: [mem 0xe5930000-0xe59300ff]
[    2.310094] pci 0000:04:00.1: supports D1 D2
[    2.314410] pci 0000:04:00.1: PME# supported from D0 D1 D2 D3hot D3cold
[    2.321115] pci 0000:04:00.1: PME# disabled
[    2.325439] pci 0000:04:00.4: [1180:e832] type 0 class 0x000c00
[    2.331467] pci 0000:04:00.4: reg 10: [mem 0xe5900000-0xe59007ff]
[    2.337780] pci 0000:04:00.4: supports D1 D2
[    2.342096] pci 0000:04:00.4: PME# supported from D0 D1 D2 D3hot D3cold
[    2.348802] pci 0000:04:00.4: PME# disabled
[    2.353141] pci 0000:00:1c.2: PCI bridge to [bus 04-05]
[    2.358413] pci 0000:00:1c.2:   bridge window [io  0x2000-0x3fff]
[    2.364553] pci 0000:00:1c.2:   bridge window [mem 0xe3100000-0xe59fffff]
[    2.371475] pci_bus 0000:05: [bus 05-08] partially hidden behind bridge 0000:04 [bus 04-05]
[    2.379927] pci 0000:00:1c.3: PCI bridge to [bus 06-0b]
[    2.385200] pci 0000:00:1c.3:   bridge window [io  0x4000-0x4fff]
[    2.391338] pci 0000:00:1c.3:   bridge window [mem 0xe5a00000-0xe6dfffff]
[    2.398239] pci 0000:00:1e.0: PCI bridge to [bus 0c-0c] (subtractive decode)
[    2.405339] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    2.413305] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    2.421270] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    2.429929] pci 0000:00:1e.0:   bridge window [mem 0xd0000000-0xfeafffff] (subtractive decode)
[    2.438615] pci_bus 0000:00: on NUMA node 0
[    2.442847] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    2.448930] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
[    2.457043] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[    2.463518] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
[    2.469951] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
[    2.476384] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP03._PRT]
[    2.482818] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP04._PRT]
[    2.489302] \_SB_.PCI0:_OSC invalid UUID
[    2.493271] _OSC request data:1 1f 1f
[    2.497309]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    2.503034] \_SB_.PCI0:_OSC invalid UUID
[    2.507003] _OSC request data:1 0 1d
[    2.510950]  pci0000:00: ACPI _OSC request failed (AE_ERROR), returned control mask: 0x1d
[    2.519173] ACPI _OSC control for PCIe not granted, disabling ASPM
[    2.528110] ACPI: PCI Root Bridge [CPBG] (domain 0000 [bus 3f])
[    2.534113] pci 0000:3f:00.0: [8086:2c62] type 0 class 0x000600
[    2.540089] pci 0000:3f:00.1: [8086:2d01] type 0 class 0x000600
[    2.546067] pci 0000:3f:02.0: [8086:2d10] type 0 class 0x000600
[    2.552041] pci 0000:3f:02.1: [8086:2d11] type 0 class 0x000600
[    2.558014] pci 0000:3f:02.2: [8086:2d12] type 0 class 0x000600
[    2.563989] pci 0000:3f:02.3: [8086:2d13] type 0 class 0x000600
[    2.569969] pci_bus 0000:3f: on NUMA node 0
[    2.574201]  pci0000:3f: Requesting ACPI _OSC control (0x1d)
[    2.579904]  pci0000:3f: ACPI _OSC request failed (AE_NOT_FOUND), returned control mask: 0x1d
[    2.588476] ACPI _OSC control for PCIe not granted, disabling ASPM
[    2.594859] ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    2.602937] ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 7 11 12 14 15) *10
[    2.611015] ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 *5 6 7 10 12 14 15)
[    2.618765] ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 11 12 14 15) *10
[    2.626846] ACPI: PCI Interrupt Link [LNKE] (IRQs 1 *3 4 5 6 7 10 12 14 15)
[    2.634599] ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 7 11 12 14 15) *0, disabled.
[    2.643607] ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    2.651694] ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 7 11 12 14 15) *0, disabled.
[    2.660718] vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    2.668860] vgaarb: loaded
[    2.671617] vgaarb: bridge control possible 0000:01:00.0
[    2.677035] SCSI subsystem initialized
[    2.680861] libata version 3.00 loaded.
[    2.684775] usbcore: registered new interface driver usbfs
[    2.690312] usbcore: registered new interface driver hub
[    2.695683] usbcore: registered new device driver usb
[    2.700874] wmi: Mapper loaded
[    2.704082] PCI: Using ACPI for IRQ routing
[    2.710454] PCI: pci_cache_line_size set to 64 bytes
[    2.715540] reserve RAM buffer: 000000000009ac00 - 000000000009ffff
[    2.721752] reserve RAM buffer: 00000000cf65f000 - 00000000cfffffff
[    2.728267] NetLabel: Initializing
[    2.731959] NetLabel:  domain hash size = 128
[    2.736361] NetLabel:  protocols = UNLABELED CIPSOv4
[    2.741377] NetLabel:  unlabeled traffic allowed by default
[    2.747029] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    2.753800] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    2.761689] Switching to clocksource hpet
[    2.770322] AppArmor: AppArmor Filesystem Enabled
[    2.775105] pnp: PnP ACPI init
[    2.778224] ACPI: bus type pnp registered
[    2.782537] pnp 00:00: [bus 00-3e]
[    2.785997] pnp 00:00: [io  0x0000-0x0cf7 window]
[    2.790750] pnp 00:00: [io  0x0cf8-0x0cff]
[    2.794898] pnp 00:00: [io  0x0d00-0xffff window]
[    2.799652] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    2.805100] pnp 00:00: [mem 0x000c0000-0x000c3fff window]
[    2.810549] pnp 00:00: [mem 0x000c4000-0x000c7fff window]
[    2.815998] pnp 00:00: [mem 0x000c8000-0x000cbfff window]
[    2.821444] pnp 00:00: [mem 0x000cc000-0x000cffff window]
[    2.826892] pnp 00:00: [mem 0x000d0000-0x000d3fff window]
[    2.832341] pnp 00:00: [mem 0x000d4000-0x000d7fff window]
[    2.837789] pnp 00:00: [mem 0x000d8000-0x000dbfff window]
[    2.843237] pnp 00:00: [mem 0x000dc000-0x000dffff window]
[    2.848685] pnp 00:00: [mem 0x000e0000-0x000e3fff window]
[    2.854134] pnp 00:00: [mem 0x000e4000-0x000e7fff window]
[    2.859582] pnp 00:00: [mem 0x000e8000-0x000ebfff window]
[    2.865030] pnp 00:00: [mem 0x000ec000-0x000effff window]
[    2.870476] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    2.875922] pnp 00:00: [mem 0xd0000000-0xfeafffff window]
[    2.881370] pnp 00:00: [mem 0xfed40000-0xfed44fff window]
[    2.886856] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    2.894153] pnp 00:01: [io  0x0000-0x001f]
[    2.898303] pnp 00:01: [io  0x0081-0x0091]
[    2.902450] pnp 00:01: [io  0x0093-0x009f]
[    2.906599] pnp 00:01: [io  0x00c0-0x00df]
[    2.910747] pnp 00:01: [dma 4]
[    2.913870] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    2.920449] pnp 00:02: [mem 0xff000000-0xffffffff]
[    2.925304] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
[    2.931930] pnp 00:03: [mem 0xfed00000-0xfed003ff]
[    2.936786] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
[    2.943369] pnp 00:04: [io  0x00f0]
[    2.946920] pnp 00:04: [irq 13]
[    2.950130] pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
[    2.956712] pnp 00:05: [io  0x002e-0x002f]
[    2.960860] pnp 00:05: [io  0x004e-0x004f]
[    2.965006] pnp 00:05: [io  0x0061]
[    2.968546] pnp 00:05: [io  0x0063]
[    2.972088] pnp 00:05: [io  0x0065]
[    2.975631] pnp 00:05: [io  0x0067]
[    2.979173] pnp 00:05: [io  0x0070]
[    2.982715] pnp 00:05: [io  0x0080]
[    2.986258] pnp 00:05: [io  0x0092]
[    2.989800] pnp 00:05: [io  0x00b2-0x00b3]
[    2.993948] pnp 00:05: [io  0x0680-0x069f]
[    2.998095] pnp 00:05: [io  0x1000-0x1003]
[    3.002242] pnp 00:05: [io  0x1004-0x1013]
[    3.006388] pnp 00:05: [io  0xffff]
[    3.009930] pnp 00:05: [io  0x0400-0x047f]
[    3.014077] pnp 00:05: [io  0x0500-0x057f]
[    3.018224] pnp 00:05: [io  0x164e-0x164f]
[    3.022406] system 00:05: [io  0x0680-0x069f] has been reserved
[    3.028376] system 00:05: [io  0x1000-0x1003] has been reserved
[    3.034343] system 00:05: [io  0x1004-0x1013] has been reserved
[    3.040311] system 00:05: [io  0xffff] has been reserved
[    3.045673] system 00:05: [io  0x0400-0x047f] has been reserved
[    3.051640] system 00:05: [io  0x0500-0x057f] has been reserved
[    3.057608] system 00:05: [io  0x164e-0x164f] has been reserved
[    3.063575] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.070416] pnp 00:06: [io  0x0070-0x0077]
[    3.074566] pnp 00:06: [irq 8]
[    3.077690] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
[    3.084272] pnp 00:07: [io  0x0060]
[    3.087814] pnp 00:07: [io  0x0064]
[    3.091357] pnp 00:07: [irq 1]
[    3.094481] pnp 00:07: Plug and Play ACPI device, IDs PNP0303 (active)
[    3.109478] pnp 00:08: [io  0x03f8-0x03ff]
[    3.113632] pnp 00:08: [irq 4]
[    3.116777] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    3.133155] pnp 00:09: [io  0x0378-0x037b]
[    3.137308] pnp 00:09: [irq 7]
[    3.140448] pnp 00:09: Plug and Play ACPI device, IDs PNP0401 (active)
[    3.147031] pnp 00:0a: [irq 12]
[    3.150244] pnp 00:0a: Plug and Play ACPI device, IDs DLL040a PNP0f13 (active)
[    3.157683] pnp 00:0b: [mem 0xfed1c000-0xfed1ffff]
[    3.162527] pnp 00:0b: [mem 0xfed10000-0xfed13fff]
[    3.167369] pnp 00:0b: [mem 0xfed18000-0xfed18fff]
[    3.172212] pnp 00:0b: [mem 0xfed19000-0xfed19fff]
[    3.177054] pnp 00:0b: [mem 0xf8000000-0xfbffffff]
[    3.181894] pnp 00:0b: [mem 0xfed20000-0xfed3ffff]
[    3.186734] pnp 00:0b: [mem 0xfed90000-0xfed8ffff disabled]
[    3.192353] pnp 00:0b: [mem 0xfed45000-0xfed8ffff]
[    3.197197] pnp 00:0b: [mem 0xff000000-0xffffffff]
[    3.202037] pnp 00:0b: [mem 0xfee00000-0xfeefffff]
[    3.206878] pnp 00:0b: [mem 0xe96c0000-0xe96c0fff]
[    3.211758] system 00:0b: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    3.218420] system 00:0b: [mem 0xfed10000-0xfed13fff] has been reserved
[    3.225080] system 00:0b: [mem 0xfed18000-0xfed18fff] has been reserved
[    3.231740] system 00:0b: [mem 0xfed19000-0xfed19fff] has been reserved
[    3.238400] system 00:0b: [mem 0xf8000000-0xfbffffff] has been reserved
[    3.245061] system 00:0b: [mem 0xfed20000-0xfed3ffff] has been reserved
[    3.251722] system 00:0b: [mem 0xfed45000-0xfed8ffff] has been reserved
[    3.258382] system 00:0b: [mem 0xff000000-0xffffffff] could not be reserved
[    3.265390] system 00:0b: [mem 0xfee00000-0xfeefffff] could not be reserved
[    3.272396] system 00:0b: [mem 0xe96c0000-0xe96c0fff] has been reserved
[    3.279055] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.285940] pnp 00:0c: [irq 23]
[    3.289159] pnp 00:0c: Plug and Play ACPI device, IDs SMO8800 (active)
[    3.300811] pnp 00:0d: [bus 3f]
[    3.304034] pnp 00:0d: Plug and Play ACPI device, IDs PNP0a03 (active)
[    3.321249] pnp: PnP ACPI: found 14 devices
[    3.325485] ACPI: ACPI bus type pnp unregistered
[    3.366216] PCI: max bus depth: 2 pci_try_num: 3
[    3.370941] pci 0000:00:1c.3: BAR 15: assigned [mem 0xe9700000-0xe98fffff 64bit pref]
[    3.378826] pci 0000:00:1c.2: BAR 15: assigned [mem 0xec000000-0xefffffff pref]
[    3.386191] pci 0000:00:1c.1: BAR 15: assigned [mem 0xe9900000-0xe9afffff 64bit pref]
[    3.394077] pci 0000:00:1c.0: BAR 15: assigned [mem 0xe9b00000-0xe9cfffff 64bit pref]
[    3.401961] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    3.407237] pci 0000:00:01.0:   bridge window [io  0x7000-0x7fff]
[    3.413378] pci 0000:00:01.0:   bridge window [mem 0xd0000000-0xe30fffff]
[    3.420214] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    3.427165] pci 0000:00:1c.0:   bridge window [io  0x6000-0x6fff]
[    3.433308] pci 0000:00:1c.0:   bridge window [mem 0xe8200000-0xe95fffff]
[    3.440146] pci 0000:00:1c.0:   bridge window [mem 0xe9b00000-0xe9cfffff 64bit pref]
[    3.447949] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    3.453225] pci 0000:00:1c.1:   bridge window [io  0x5000-0x5fff]
[    3.459369] pci 0000:00:1c.1:   bridge window [mem 0xe6e00000-0xe81fffff]
[    3.466206] pci 0000:00:1c.1:   bridge window [mem 0xe9900000-0xe9afffff 64bit pref]
[    3.474012] pci 0000:04:00.0: BAR 16: can't assign mem (size 0x4000000)
[    3.480674] pci 0000:04:00.0: BAR 15: assigned [mem 0xec000000-0xefffffff pref]
[    3.488040] pci 0000:04:00.0: BAR 14: assigned [io  0x2000-0x20ff]
[    3.494269] pci 0000:04:00.0: BAR 13: assigned [io  0x2400-0x24ff]
[    3.500497] pci 0000:04:00.0: CardBus bridge to [bus 05-08]
[    3.506118] pci 0000:04:00.0:   bridge window [io  0x2400-0x24ff]
[    3.512261] pci 0000:04:00.0:   bridge window [io  0x2000-0x20ff]
[    3.518405] pci 0000:04:00.0:   bridge window [mem 0xec000000-0xefffffff pref]
[    3.525687] pci 0000:00:1c.2: PCI bridge to [bus 04-05]
[    3.530963] pci 0000:00:1c.2:   bridge window [io  0x2000-0x3fff]
[    3.537110] pci 0000:00:1c.2:   bridge window [mem 0xe3100000-0xe59fffff]
[    3.543947] pci 0000:00:1c.2:   bridge window [mem 0xec000000-0xefffffff pref]
[    3.551231] pci 0000:00:1c.3: PCI bridge to [bus 06-0b]
[    3.556509] pci 0000:00:1c.3:   bridge window [io  0x4000-0x4fff]
[    3.562654] pci 0000:00:1c.3:   bridge window [mem 0xe5a00000-0xe6dfffff]
[    3.569490] pci 0000:00:1c.3:   bridge window [mem 0xe9700000-0xe98fffff 64bit pref]
[    3.577297] pci 0000:00:1e.0: PCI bridge to [bus 0c-0c]
[    3.582592] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    3.589343] pci 0000:00:01.0: setting latency timer to 64
[    3.594795] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    3.601545] pci 0000:00:1c.0: setting latency timer to 64
[    3.607000] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    3.613752] pci 0000:00:1c.1: setting latency timer to 64
[    3.619209] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    3.625957] pci 0000:00:1c.2: setting latency timer to 64
[    3.631410] pci 0000:04:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    3.638163] pci 0000:04:00.0: setting latency timer to 64
[    3.643619] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    3.650369] pci 0000:00:1c.3: setting latency timer to 64
[    3.655823] pci 0000:00:1e.0: setting latency timer to 64
[    3.661274] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    3.666894] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    3.672515] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    3.678829] pci_bus 0000:00: resource 7 [mem 0xd0000000-0xfeafffff]
[    3.685143] pci_bus 0000:01: resource 0 [io  0x7000-0x7fff]
[    3.690762] pci_bus 0000:01: resource 1 [mem 0xd0000000-0xe30fffff]
[    3.697077] pci_bus 0000:02: resource 0 [io  0x6000-0x6fff]
[    3.702845] pci_bus 0000:02: resource 1 [mem 0xe8200000-0xe95fffff]
[    3.709159] pci_bus 0000:02: resource 2 [mem 0xe9b00000-0xe9cfffff 64bit pref]
[    3.716436] pci_bus 0000:03: resource 0 [io  0x5000-0x5fff]
[    3.722057] pci_bus 0000:03: resource 1 [mem 0xe6e00000-0xe81fffff]
[    3.728372] pci_bus 0000:03: resource 2 [mem 0xe9900000-0xe9afffff 64bit pref]
[    3.735650] pci_bus 0000:04: resource 0 [io  0x2000-0x3fff]
[    3.741272] pci_bus 0000:04: resource 1 [mem 0xe3100000-0xe59fffff]
[    3.747585] pci_bus 0000:04: resource 2 [mem 0xec000000-0xefffffff pref]
[    3.754335] pci_bus 0000:05: resource 0 [io  0x2400-0x24ff]
[    3.759955] pci_bus 0000:05: resource 1 [io  0x2000-0x20ff]
[    3.765576] pci_bus 0000:05: resource 2 [mem 0xec000000-0xefffffff pref]
[    3.772322] pci_bus 0000:06: resource 0 [io  0x4000-0x4fff]
[    3.777941] pci_bus 0000:06: resource 1 [mem 0xe5a00000-0xe6dfffff]
[    3.784254] pci_bus 0000:06: resource 2 [mem 0xe9700000-0xe98fffff 64bit pref]
[    3.791531] pci_bus 0000:0c: resource 4 [io  0x0000-0x0cf7]
[    3.797152] pci_bus 0000:0c: resource 5 [io  0x0d00-0xffff]
[    3.802772] pci_bus 0000:0c: resource 6 [mem 0x000a0000-0x000bffff]
[    3.809087] pci_bus 0000:0c: resource 7 [mem 0xd0000000-0xfeafffff]
[    3.815426] NET: Registered protocol family 2
[    3.819876] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    3.827183] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    3.834851] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    3.841621] TCP: Hash tables configured (established 131072 bind 65536)
[    3.848282] TCP reno registered
[    3.851472] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    3.857442] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    3.863888] NET: Registered protocol family 1
[    3.868366] pci 0000:01:00.0: Boot video device
[    3.872973] PCI: CLS 64 bytes, default 64
[    3.877071] Trying to unpack rootfs image as initramfs...
[    3.947547] Freeing initrd memory: 3996k freed
[    3.952750] Simple Boot Flag at 0xf1 set to 0x1
[    3.957705] audit: initializing netlink socket (disabled)
[    3.963163] type=2000 audit(1326965749.760:1): initialized
[    3.985260] highmem bounce pool size: 64 pages
[    3.989762] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[    3.997275] VFS: Disk quotas dquot_6.5.2
[    4.001291] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    4.008170] fuse init (API version 7.17)
[    4.012231] msgmni has been set to 1703
[    4.016281] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    4.023730] io scheduler noop registered
[    4.027702] io scheduler deadline registered
[    4.032027] io scheduler cfq registered (default)
[    4.036854] pcieport 0000:00:01.0: setting latency timer to 64
[    4.042758] pcieport 0000:00:01.0: irq 40 for MSI/MSI-X
[    4.048275] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    4.053914] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    4.060621] intel_idle: MWAIT substates: 0x1120
[    4.065201] intel_idle: v0.4 model 0x25
[    4.069089] intel_idle: lapic_timer_reliable_states 0xffffffff
[    4.075400] ACPI: Deprecated procfs I/F for AC is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    4.085534] ACPI: AC Adapter [AC] (on-line)
[    4.089864] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input0
[    4.098545] ACPI: Lid Switch [LID]
[    4.102030] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
[    4.110264] ACPI: Power Button [PBTN]
[    4.114002] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    4.122233] ACPI: Sleep Button [SBTN]
[    4.125972] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    4.133423] ACPI: Power Button [PWRF]
[    4.195570] ERST: Table is not found!
[    4.199361] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    4.226400] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    4.238444] ACPI: Deprecated procfs I/F for battery is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    4.248762] ACPI: Battery Slot [BAT0] (battery present)
[    4.483398] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    4.562866] ACPI: Deprecated procfs I/F for battery is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    4.563899] brd: module loaded
[    4.564452] loop: module loaded
[    4.564719] Fixed MDIO Bus: probed
[    4.564734] tun: Universal TUN/TAP device driver, 1.6
[    4.564735] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    4.564776] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    4.564792] ehci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.564802] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[    4.564806] ehci_hcd 0000:00:1a.0: EHCI Host Controller
[    4.564810] ehci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    4.564854] ehci_hcd 0000:00:1a.0: debug port 2
[    4.568768] ehci_hcd 0000:00:1a.0: cache line size of 64 is not supported
[    4.568785] ehci_hcd 0000:00:1a.0: irq 16, io mem 0xe9670000
[    4.582489] ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    4.582605] hub 1-0:1.0: USB hub found
[    4.582608] hub 1-0:1.0: 3 ports detected
[    4.582665] ehci_hcd 0000:00:1d.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    4.582675] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[    4.582678] ehci_hcd 0000:00:1d.0: EHCI Host Controller
[    4.582681] ehci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    4.582722] ehci_hcd 0000:00:1d.0: debug port 2
[    4.586640] ehci_hcd 0000:00:1d.0: cache line size of 64 is not supported
[    4.586652] ehci_hcd 0000:00:1d.0: irq 17, io mem 0xe9650000
[    4.602459] ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    4.602537] hub 2-0:1.0: USB hub found
[    4.602539] hub 2-0:1.0: 3 ports detected
[    4.602590] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    4.602598] uhci_hcd: USB Universal Host Controller Interface driver
[    4.602640] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    4.602861] i8042: Warning: Keylock active
[    4.604176] serio: i8042 KBD port at 0x60,0x64 irq 1
[    4.604180] serio: i8042 AUX port at 0x60,0x64 irq 12
[    4.604275] mousedev: PS/2 mouse device common for all mice
[    4.604451] rtc_cmos 00:06: RTC can wake from S4
[    4.604641] rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
[    4.604697] rtc0: alarms up to one year, y3k, 242 bytes nvram, hpet irqs
[    4.604777] cpuidle: using governor ladder
[    4.791194] ACPI: Battery Slot [BAT1] (battery absent)
[    4.791344] cpuidle: using governor menu
[    4.791346] EFI Variables Facility v0.08 2004-May-17
[    4.791472] TCP cubic registered
[    4.791550] NET: Registered protocol family 10
[    4.791849] NET: Registered protocol family 17
[    4.791858] Registering the dns_resolver key type
[    4.791870] Using IPI No-Shortcut mode
[    4.791995] PM: Hibernation image not present or could not be loaded.
[    4.792002] registered taskstats version 1
[    4.792698]   Magic number: 12:378:576
[    4.842243] rtc_cmos 00:06: setting system clock to 2012-01-19 09:35:52 UTC (1326965752)
[    4.850732] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
[    4.860116] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    4.866173] EDD information not available.
[    4.870595] Freeing unused kernel memory: 556k freed
[    4.875731] Write protecting the kernel text: 4808k
[    4.880719] Write protecting the kernel read-only data: 1908k
[    4.898665] udev[60]: starting version 163
[    4.918198] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k
[    4.924092] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[    4.926901] sdhci: Secure Digital Host Controller Interface driver
[    4.926903] sdhci: Copyright(c) Pierre Ossman
[    4.927120] sdhci-pci 0000:04:00.1: SDHCI controller found [1180:e822] (rev 3)
[    4.927145] sdhci-pci 0000:04:00.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    4.927185] sdhci-pci 0000:04:00.1: setting latency timer to 64
[    4.927210] mmc0: no vmmc regulator found
[    4.927235] Registered led device: mmc0::
[    4.928287] mmc0: SDHCI controller on PCI [0000:04:00.1] using DMA
[    4.976727] ahci 0000:00:1f.2: version 3.0
[    4.977863] firewire_ohci 0000:04:00.4: PCI INT C -> GSI 16 (level, low) -> IRQ 16
[    4.977873] firewire_ohci 0000:04:00.4: setting latency timer to 64
[    4.978171] Refined TSC clocksource calibration: 2792.981 MHz.
[    4.978178] Switching to clocksource tsc
[    5.005025] ahci 0000:00:1f.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    5.013643] ahci 0000:00:1f.2: irq 41 for MSI/MSI-X
[    5.021976] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 3 Gbps 0x33 impl SATA mode
[    5.030251] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems sxs apst
[    5.033866] firewire_ohci 0000:04:00.4: irq 42 for MSI/MSI-X
[    5.033927] firewire_ohci: Added fw-ohci device 0000:04:00.4, OHCI v1.0, 4 IR + 4 IT contexts, quirks 0x1
[    5.037690] usb 1-1: new high-speed USB device number 2 using ehci_hcd
[    5.060562] ahci 0000:00:1f.2: setting latency timer to 64
[    5.094128] scsi0 : ahci
[    5.096822] scsi1 : ahci
[    5.099495] scsi2 : ahci
[    5.102165] scsi3 : ahci
[    5.104834] scsi4 : ahci
[    5.107498] scsi5 : ahci
[    5.110471] ata1: SATA max UDMA/133 abar m2048@0xe9640000 port 0xe9640100 irq 41
[    5.117916] ata2: SATA max UDMA/133 abar m2048@0xe9640000 port 0xe9640180 irq 41
[    5.125361] ata3: DUMMY
[    5.127858] ata4: DUMMY
[    5.130359] ata5: SATA max UDMA/133 abar m2048@0xe9640000 port 0xe9640300 irq 41
[    5.137803] ata6: SATA max UDMA/133 abar m2048@0xe9640000 port 0xe9640380 irq 41
[    5.145338] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[    5.152356] e1000e 0000:00:19.0: setting latency timer to 64
[    5.158159] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    5.194110] hub 1-1:1.0: USB hub found
[    5.198104] hub 1-1:1.0: 6 ports detected
[    5.313312] usb 2-1: new high-speed USB device number 2 using ehci_hcd
[    5.391704] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 5c:26:0a:4b:44:22
[    5.399760] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[    5.406812] e1000e 0000:00:19.0: eth0: MAC: 9, PHY: 10, PBA No: 3041FF-0FF
[    5.449682] hub 2-1:1.0: USB hub found
[    5.453666] hub 2-1:1.0: 8 ports detected
[    5.464989] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    5.471244] ata5: SATA link down (SStatus 0 SControl 300)
[    5.476791] ata6: SATA link down (SStatus 0 SControl 300)
[    5.482268] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    5.488499] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
[    5.497335] ata2.00: ATAPI: HL-DT-ST DVD-ROM DU30N, A100, max UDMA/133
[    5.508107] ata2.00: configured for UDMA/133
[    5.523713] ata1.00: ATA-8: ST9250410AS, D005SDM1, max UDMA/133
[    5.529677] ata1.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    5.532896] firewire_core: created device fw0: GUID 065316c1314fc000, S400
[    5.543637] usb 1-1.1: new high-speed USB device number 3 using ehci_hcd
[    5.545636] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
[    5.559249] ata1.00: configured for UDMA/133
[    5.563767] scsi 0:0:0:0: Direct-Access     ATA      ST9250410AS      D005 PQ: 0 ANSI: 5
[    5.572026] sd 0:0:0:0: [sda] 488397168 512-byte logical blocks: (250 GB/232 GiB)
[    5.572073] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    5.585012] sd 0:0:0:0: [sda] Write Protect is off
[    5.589886] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    5.590688] scsi 1:0:0:0: CD-ROM            HL-DT-ST DVD-ROM DU30N    A100 PQ: 0 ANSI: 5
[    5.603150] sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
[    5.603157] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.618456] cdrom: Uniform CD-ROM driver Revision: 3.20
[    5.623885] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    5.628626] sr 1:0:0:0: Attached scsi generic sg1 type 5
[    5.661419] hub 1-1.1:1.0: USB hub found
[    5.665546] hub 1-1.1:1.0: 3 ports detected
[    5.682946]  sda: sda1 sda2 < sda5 sda6 sda7 >
[    5.688150] sd 0:0:0:0: [sda] Attached SCSI disk
[    5.740675] usb 1-1.2: new high-speed USB device number 4 using ehci_hcd
[    5.837372] hub 1-1.2:1.0: USB hub found
[    5.841422] hub 1-1.2:1.0: 3 ports detected
[    5.916355] usb 1-1.4: new high-speed USB device number 5 using ehci_hcd
[    6.096069] usb 2-1.7: new full-speed USB device number 3 using ehci_hcd
[    6.224362] EXT4-fs (sda5): mounted filesystem with ordered data mode. Opts: (null)
[    6.271754] usb 2-1.8: new full-speed USB device number 4 using ehci_hcd
[    6.394581] usb 2-1.8: config 0 descriptor??
[   13.822641] Adding 5915644k swap on /dev/sda1.  Priority:-1 extents:1 across:5915644k
[   13.828396] udev[300]: starting version 163
[   14.121075] type=1400 audit(1326965761.841:2): apparmor="STATUS" operation="profile_load" name="/sbin/dhclient3" pid=489 comm="apparmor_parser"
[   14.134001] type=1400 audit(1326965761.857:3): apparmor="STATUS" operation="profile_replace" name="/sbin/dhclient3" pid=517 comm="apparmor_parser"
[   14.147188] type=1400 audit(1326965761.869:4): apparmor="STATUS" operation="profile_load" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=489 comm="apparmor_parser"
[   14.162737] type=1400 audit(1326965761.885:5): apparmor="STATUS" operation="profile_replace" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=517 comm="apparmor_parser"
[   14.178529] type=1400 audit(1326965761.901:6): apparmor="STATUS" operation="profile_load" name="/usr/lib/connman/scripts/dhclient-script" pid=489 comm="apparmor_parser"
[   14.193641] type=1400 audit(1326965761.913:7): apparmor="STATUS" operation="profile_replace" name="/usr/lib/connman/scripts/dhclient-script" pid=517 comm="apparmor_parser"
[   14.315332] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   14.348050] intel ips 0000:00:1f.6: CPU TDP doesn't match expected value (found 25, expected 29)
[   14.351909] bcma-pci-bridge 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[   14.351926] bcma-pci-bridge 0000:03:00.0: setting latency timer to 64
[   14.352005] bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x22, class 0x0)
[   14.352043] bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x17, class 0x0)
[   14.352135] bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x0F, class 0x0)
[   14.352305] bcma: Switched to core: 0x800
[   14.352321] bcma: Found rev 6 PMU (capabilities 0x108C2606)
[   14.352342] bcma: Switched to core: 0x820
[   14.358583] Linux agpgart interface v0.103
[   14.381524] bcma: Switched to core: 0x800
[   14.384096] bcma: Bus registered
[   14.420123] intel ips 0000:00:1f.6: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[   14.427421] intel ips 0000:00:1f.6: failed to get i915 symbols, graphics turbo disabled
[   14.435574] intel ips 0000:00:1f.6: IPS driver initialized, MCP temp limit 90
[   14.475991] input: Dell WMI hotkeys as /devices/virtual/input/input5
[   14.546270] [drm] Initialized drm 1.1.0 20060810
[   14.772745] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[   14.780431] snd_hda_intel 0000:00:1b.0: irq 44 for MSI/MSI-X
[   14.786174] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[   15.295927] ACPI Exception: AE_TIME, Returned by Handler for [EmbeddedControl] (20110623/evregion-478)
[   15.305416] ACPI Error: Method parse/execution failed [\_SB_.PCI0.LPCB.ECDV.ECR1] (Node f502b738), AE_TIME (20110623/psparse-536)
[   15.317393] ACPI Error: Method parse/execution failed [\ECRB] (Node f502b810), AE_TIME (20110623/psparse-536)
[   15.327613] ACPI Error: Method parse/execution failed [\ECG5] (Node f502b8b8), AE_TIME (20110623/psparse-536)
[   15.337838] ACPI Error: Method parse/execution failed [\_SB_.AC__._PSR] (Node f502bca8), AE_TIME (20110623/psparse-536)
[   15.348925] ACPI Exception: AE_TIME, Error reading AC Adapter state (20110623/ac-118)
[   17.612430] input: HDA Intel Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input6
[   17.620573] input: HDA Intel Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input7
[   17.628753] input: HDA Intel Line-out as /devices/pci0000:00/0000:00:1b.0/sound/card0/input8
[   17.637398] input: HDA Intel Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card0/input9
[   17.647903] snd_hda_intel 0000:01:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[   17.655525] hda_intel: Disabling MSI
[   17.659189] snd_hda_intel 0000:01:00.1: setting latency timer to 64
[   17.828232] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro
[   18.284843] input: PS/2 Generic Mouse as /devices/platform/i8042/serio1/input/input10
[   18.302829] acpi device:03: registered as cooling_device4
[   18.342900] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/device:01/LNXVIDEO:00/input/input11
[   18.352983] ACPI: Video Device [VID] (multi-head: yes  rom: no  post: no)
[   18.877719] HDMI status: Codec=0 Pin=5 Presence_Detect=0 ELD_Valid=0
[   18.913652] HDMI status: Codec=1 Pin=5 Presence_Detect=0 ELD_Valid=0
[   18.949589] HDMI status: Codec=2 Pin=5 Presence_Detect=0 ELD_Valid=0
[   18.985527] HDMI status: Codec=3 Pin=5 Presence_Detect=0 ELD_Valid=0
[   19.005646] input: HDA NVidia HDMI/DP,pcm=9 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card1/input12
[   19.016038] input: HDA NVidia HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card1/input13
[   19.026555] input: HDA NVidia HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card1/input14
[   19.036881] input: HDA NVidia HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card1/input15
[   19.048847] nouveau 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   19.055958] nouveau 0000:01:00.0: setting latency timer to 64
[   19.063090] [drm] nouveau 0000:01:00.0: Detected an NV50 generation card (0x0a8600b1)
[   19.074664] [drm] nouveau 0000:01:00.0: Attempting to load BIOS image from PRAMIN
[   19.160380] [drm] nouveau 0000:01:00.0: ... appears to be valid
[   19.166356] [drm] nouveau 0000:01:00.0: BIT BIOS found
[   19.171542] [drm] nouveau 0000:01:00.0: Bios version 70.18.53.00
[   19.177599] [drm] nouveau 0000:01:00.0: TMDS table version 2.0
[   19.183481] [drm] nouveau 0000:01:00.0: Found Display Configuration Block version 4.0
[   19.191367] [drm] nouveau 0000:01:00.0: Raw DCB entry 0: 048003b6 0f200014
[   19.198288] [drm] nouveau 0000:01:00.0: Raw DCB entry 1: 02033300 00000000
[   19.205243] [drm] nouveau 0000:01:00.0: Raw DCB entry 2: 088223a6 0f220010
[   19.212163] [drm] nouveau 0000:01:00.0: Raw DCB entry 3: 08022362 00020010
[   19.219086] [drm] nouveau 0000:01:00.0: Raw DCB entry 4: 028113c6 0f220010
[   19.226009] [drm] nouveau 0000:01:00.0: Raw DCB entry 5: 02011382 00020010
[   19.232928] [drm] nouveau 0000:01:00.0: Raw DCB entry 6: 0000000e 00000000
[   19.239847] [drm] nouveau 0000:01:00.0: DCB connector table: VHER 0x40 5 16 4
[   19.247023] [drm] nouveau 0000:01:00.0:   0: 0x00002047: type 0x47 idx 0 tag 0x08
[   19.254559] [drm] nouveau 0000:01:00.0:   1: 0x00101146: type 0x46 idx 1 tag 0x07
[   19.262092] [drm] nouveau 0000:01:00.0:   2: 0x00410246: type 0x46 idx 2 tag 0x51
[   19.269626] [drm] nouveau 0000:01:00.0:   3: 0x00000300: type 0x00 idx 3 tag 0xff
[   19.277163] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 0 at offset 0x6F74
[   19.345561] [drm] nouveau 0000:01:00.0: 0x7241: Condition still not met after 20ms, skipping following opcodes
[   19.375417] [drm] nouveau 0000:01:00.0: 0x7245: Condition still not met after 20ms, skipping following opcodes
[   19.405297] [drm] nouveau 0000:01:00.0: 0x73F2: Condition still not met after 20ms, skipping following opcodes
[   19.415349] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 1 at offset 0x741F
[   19.430756] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 2 at offset 0x7FCB
[   19.438470] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 3 at offset 0x7FE4
[   19.488647] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table 4 at offset 0x80CB
[   19.496398] [drm] nouveau 0000:01:00.0: Parsing VBIOS init table at offset 0x8130
[   19.523740] [drm] nouveau 0000:01:00.0: 0x6DE8: Condition still not met after 20ms, skipping following opcodes
[   19.552652] [drm] nouveau 0000:01:00.0: 3 available performance level(s)
[   19.559416] [drm] nouveau 0000:01:00.0: 0: core 135MHz shader 270MHz memory 135MHz timing 2 voltage 850mV
[   19.569035] [drm] nouveau 0000:01:00.0: 1: core 405MHz shader 810MHz memory 405MHz timing 1 voltage 850mV
[   19.578649] [drm] nouveau 0000:01:00.0: 3: core 606MHz shader 1468MHz memory 790MHz timing 0 voltage 1000mV
[   19.588507] [drm] nouveau 0000:01:00.0: c: core 405MHz shader 810MHz memory 405MHz voltage 1000mV
[   19.602137] [TTM] Zone  kernel: Available graphics memory: 436472 kiB.
[   19.608710] [TTM] Zone highmem: Available graphics memory: 1680826 kiB.
[   19.615368] [TTM] Initializing pool allocator.
[   19.619869] [drm] nouveau 0000:01:00.0: Detected 512MiB VRAM
[   19.626511] [drm] nouveau 0000:01:00.0: 512 MiB GART (aperture)
[   19.683579] [drm] nouveau 0000:01:00.0: ACPI backlight interface available, not registering our own
[   19.721679] EXT4-fs (sda7): mounted filesystem with ordered data mode. Opts: (null)
[   19.733559] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   19.740219] [drm] No driver support for vblank timestamp query.
[   19.923941] sshd (790): /proc/790/oom_adj is deprecated, please use /proc/790/oom_score_adj instead.
[   19.994246] [drm] nouveau 0000:01:00.0: allocated 1440x900 fb: 0x310000, bo f1383600
[   20.002175] fbcon: nouveaufb (fb0) is primary device
[   20.319091] Console: switching to colour frame buffer device 180x56
[   20.327293] fb0: nouveaufb frame buffer device
[   20.327295] drm: registered panic notifier
[   20.327301] [drm] Initialized nouveau 0.0.16 20090420 for 0000:01:00.0 on minor 0
[   20.344670] dell_wmi: Received unknown WMI event (0x11)
[   20.467523] type=1400 audit(1326965768.201:8): apparmor="STATUS" operation="profile_load" name="/usr/share/gdm/guest-session/Xsession" pid=910 comm="apparmor_parser"
[   20.507112] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   20.566884] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   20.573174] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   20.579764] type=1400 audit(1326965768.313:9): apparmor="STATUS" operation="profile_load" name="/usr/sbin/tcpdump" pid=921 comm="apparmor_parser"
[   20.600823] type=1400 audit(1326965768.333:10): apparmor="STATUS" operation="profile_replace" name="/sbin/dhclient3" pid=911 comm="apparmor_parser"
[   20.614269] type=1400 audit(1326965768.345:11): apparmor="STATUS" operation="profile_replace" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=911 comm="apparmor_parser"
[   20.632881] type=1400 audit(1326965768.365:12): apparmor="STATUS" operation="profile_replace" name="/usr/lib/connman/scripts/dhclient-script" pid=911 comm="apparmor_parser"
[   20.691287] type=1400 audit(1326965768.425:13): apparmor="STATUS" operation="profile_load" name="/usr/lib/cups/backend/cups-pdf" pid=831 comm="apparmor_parser"
[   20.706734] type=1400 audit(1326965768.441:14): apparmor="STATUS" operation="profile_load" name="/usr/sbin/cupsd" pid=831 comm="apparmor_parser"
[   20.742554] type=1400 audit(1326965768.477:15): apparmor="STATUS" operation="profile_replace" name="/usr/lib/cups/backend/cups-pdf" pid=914 comm="apparmor_parser"
[   20.757483] type=1400 audit(1326965768.489:16): apparmor="STATUS" operation="profile_replace" name="/usr/sbin/cupsd" pid=914 comm="apparmor_parser"
[   23.179490] type=1400 audit(1326965770.917:17): apparmor="STATUS" operation="profile_load" name="/usr/bin/evince" pid=912 comm="apparmor_parser"
[   23.695828] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[   23.705543] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   26.132161] hda-intel: IRQ timing workaround is activated for card #1. Suggest a bigger bdl_pos_adj.
[   26.820446] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro,commit=0
[   26.829123] EXT4-fs (sda7): re-mounted. Opts: commit=0
[   34.247153] eth0: no IPv6 routers present


--------------040405090007000003050001--
