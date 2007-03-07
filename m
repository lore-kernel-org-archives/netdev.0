From: Mark Huth <mhuth@mvista.com>
Subject: Re: livelock and soft-lockup with 2.6.20.1
Date: Tue, 06 Mar 2007 17:08:25 -0700
Message-ID: <45EE0279.6010404@mvista.com>
References: <20070306131334.GA8412@tentacle.sectorb.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:45713 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030759AbXCGAI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 19:08:28 -0500
In-Reply-To: <20070306131334.GA8412@tentacle.sectorb.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Vladimir B. Savkin wrote:
> Hello!
>
> Today some topology loop emerged in our network
> which caused our linux router (x86_64, dual opteron) to livelock
> and to produce some soft-lockup messages.
>
> With a presence of the loop, no other things could run on the machine
> but packet processing and printing messages about duplicate address:
> even the keyboard was not responding. I think it's not desirable
> behavior since NAPI was designed to prevent such livelocks.
>   
It may not be desirable, but it is quite possible.  NAPI does not 
prevent userspace starvation.  It improves on the interrupt flood 
problem by allowing the overloaded node to make forward network 
progress, but leaves the issue of a packet flood being able to starve 
normal processes.  I suspect that the soft lockup is from the watchdog, 
but I haven't investigated that specifically.

If your system needs guaranteed response in process scheduling, then you 
need to look at the RT patch from Ingo Molnar.  That patch threads both 
hard and soft irqs, and allows process scheduling rules to be applied to 
the thread priorities.

What happens now is that NAPI defers network receive processing to the 
softirq, which will eventually schedule out to the ksoftirqd thread for 
restart.  But there are so many ways that the softirq gets run in the 
kernel, that simply deferring to the ksoftirqd is sometimes not adequate 
to prevent process starvation.  I haven't looked recently, but the 
ksoftirqd used to be scheduled at higher priority than the normal 
processes, so that didn't help much unless you juggled the process 
priorities.

Fact is, that when you overload a system, the only thing you can do is 
control what load gets serviced and what doesn't.  And a packet storm 
from a loop may well generate just the sort of overload that stalls the 
system in the softirq for network receiving.  Without mechanisms to 
determine which load should be serviced in overload, the softirqs take 
priority over any process activity.

I have a patch that will force the ksoftirqd to run before it will allow 
additional work to be done in the network receive softirq.  If you are 
interested, I need to port it to a recent kernel and post.  I haven't 
done so in the past, because I see the RT kernel work as a better way to 
control the overload behavior of a system.  But if you cannot go to the 
RT kernel for some reason, then I could post the patch.

Mark Huth
> After the loop was fixed, the machine has recovered to a normal state.
> Full dmesg output containing two traces is attached.
> Are those soft-lockup messages only consequences of livelock,
> or do they indicate some deadlocks?
>
> ~
> :wq
>                                         With best regards, 
>                                            Vladimir Savkin. 
>
>   
> ------------------------------------------------------------------------
>
> Linux version 2.6.20.1 (vsavkin@phoenix64) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #2 SMP Mon Mar 5 01:33:10 MSK 2007
> Command line: auto BOOT_IMAGE=mar ro root=802 clocksource=tsc idle=poll
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 0000000000098800 (usable)
>  BIOS-e820: 0000000000098800 - 00000000000a0000 (reserved)
>  BIOS-e820: 00000000000c2000 - 0000000000100000 (reserved)
>  BIOS-e820: 0000000000100000 - 00000000bff20000 (usable)
>  BIOS-e820: 00000000bff20000 - 00000000bff28000 (ACPI data)
>  BIOS-e820: 00000000bff28000 - 00000000bff80000 (ACPI NVS)
>  BIOS-e820: 00000000bff80000 - 00000000c0000000 (reserved)
>  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
>  BIOS-e820: 00000000fec00000 - 00000000fec00400 (reserved)
>  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
>  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
>  BIOS-e820: 0000000100000000 - 0000000140000000 (usable)
> Entering add_active_range(0, 0, 152) 0 entries of 3200 used
> Entering add_active_range(0, 256, 786208) 1 entries of 3200 used
> Entering add_active_range(0, 1048576, 1310720) 2 entries of 3200 used
> end_pfn_map = 1310720
> DMI present.
> ACPI: RSDP (v000 PTLTD                                 ) @ 0x00000000000f6f50
> ACPI: RSDT (v001 PTLTD    RSDT   0x06040000  LTP 0x00000000) @ 0x00000000bff24097
> ACPI: FADT (v001 NVIDIA CK8S     0x06040000 PTL_ 0x000f4240) @ 0x00000000bff27dae
> ACPI: SRAT (v001 AMD    HAMMER   0x06040000 AMD  0x00000001) @ 0x00000000bff27e22
> ACPI: SPCR (v001 PTLTD  $UCRTBL$ 0x06040000 PTL  0x00000001) @ 0x00000000bff27f12
> ACPI: MADT (v001 PTLTD  	 APIC   0x06040000  LTP 0x00000000) @ 0x00000000bff27f62
> ACPI: BOOT (v001 PTLTD  $SBFTBL$ 0x06040000  LTP 0x00000001) @ 0x00000000bff27fd8
> ACPI: DSDT (v001 NVIDIA      CK8 0x06040000 MSFT 0x0100000e) @ 0x0000000000000000
> SRAT: PXM 0 -> APIC 0 -> Node 0
> SRAT: PXM 1 -> APIC 1 -> Node 1
> SRAT: Node 0 PXM 0 0-a0000
> Entering add_active_range(0, 0, 152) 0 entries of 3200 used
> SRAT: Node 0 PXM 0 0-80000000
> Entering add_active_range(0, 0, 152) 1 entries of 3200 used
> Entering add_active_range(0, 256, 524288) 1 entries of 3200 used
> SRAT: Node 1 PXM 1 80000000-c0000000
> Entering add_active_range(1, 524288, 786208) 2 entries of 3200 used
> SRAT: Node 1 PXM 1 80000000-140000000
> Entering add_active_range(1, 524288, 786208) 3 entries of 3200 used
> Entering add_active_range(1, 1048576, 1310720) 3 entries of 3200 used
> NUMA: Using 31 for the hash shift.
> Bootmem setup node 0 0000000000000000-0000000080000000
> Bootmem setup node 1 0000000080000000-0000000140000000
> Zone PFN ranges:
>   DMA             0 ->     4096
>   DMA32        4096 ->  1048576
>   Normal    1048576 ->  1310720
> early_node_map[4] active PFN ranges
>     0:        0 ->      152
>     0:      256 ->   524288
>     1:   524288 ->   786208
>     1:  1048576 ->  1310720
> On node 0 totalpages: 524184
>   DMA zone: 56 pages used for memmap
>   DMA zone: 1428 pages reserved
>   DMA zone: 2508 pages, LIFO batch:0
>   DMA32 zone: 7112 pages used for memmap
>   DMA32 zone: 513080 pages, LIFO batch:31
>   Normal zone: 0 pages used for memmap
> On node 1 totalpages: 524064
>   DMA zone: 0 pages used for memmap
>   DMA32 zone: 7168 pages used for memmap
>   DMA32 zone: 254752 pages, LIFO batch:31
>   Normal zone: 3584 pages used for memmap
>   Normal zone: 258560 pages, LIFO batch:31
> Nvidia board detected. Ignoring ACPI timer override.
> If you got timer trouble try acpi_use_timer_override
> ACPI: PM-Timer IO Port: 0x8008
> ACPI: Local APIC address 0xfee00000
> ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> Processor #0 (Bootup-CPU)
> ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> Processor #1
> ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
> ACPI: IOAPIC (id[0x03] address[0xdf200000] gsi_base[24])
> IOAPIC[1]: apic_id 3, address 0xdf200000, GSI 24-27
> ACPI: IOAPIC (id[0x04] address[0xdf201000] gsi_base[28])
> IOAPIC[2]: apic_id 4, address 0xdf201000, GSI 28-31
> ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
> ACPI: IRQ9 used by override.
> Setting APIC routing to flat
> Using ACPI (MADT) for SMP configuration information
> Nosave address range: 0000000000098000 - 0000000000099000
> Nosave address range: 0000000000099000 - 00000000000a0000
> Nosave address range: 00000000000a0000 - 00000000000c2000
> Nosave address range: 00000000000c2000 - 0000000000100000
> Nosave address range: 00000000bff20000 - 00000000bff28000
> Nosave address range: 00000000bff28000 - 00000000bff80000
> Nosave address range: 00000000bff80000 - 00000000c0000000
> Nosave address range: 00000000c0000000 - 00000000e0000000
> Nosave address range: 00000000e0000000 - 00000000f0000000
> Nosave address range: 00000000f0000000 - 00000000fec00000
> Nosave address range: 00000000fec00000 - 00000000fee00000
> Nosave address range: 00000000fee00000 - 00000000fee01000
> Nosave address range: 00000000fee01000 - 00000000fff80000
> Nosave address range: 00000000fff80000 - 0000000100000000
> Allocating PCI resources starting at c2000000 (gap: c0000000:20000000)
> PERCPU: Allocating 32128 bytes of per cpu data
> Built 2 zonelists.  Total pages: 1028900
> Kernel command line: auto BOOT_IMAGE=mar ro root=802 clocksource=tsc idle=poll
> using polling idle threads.
> Initializing CPU#0
> PID hash table entries: 4096 (order: 12, 32768 bytes)
> Console: colour VGA+ 80x25
> Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
> Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
> Checking aperture...
> CPU 0: aperture @ da000000 size 32 MB
> Aperture too small (32 MB)
> No AGP bridge found
> Your BIOS doesn't leave a aperture memory hole
> Please enable the IOMMU option in the BIOS setup
> This costs you 64 MB of RAM
> Mapping aperture over 65536 KB of RAM @ 4000000
> Memory: 4043684k/5242880k available (3195k kernel code, 149308k reserved, 1487k data, 336k init)
> Calibrating delay using timer specific routine.. 4823.60 BogoMIPS (lpj=2411802)
> Mount-cache hash table entries: 256
> CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
> CPU: L2 Cache: 1024K (64 bytes/line)
> CPU 0/0 -> Node 0
> Freeing SMP alternatives: 32k freed
> ACPI: Core revision 20060707
>  tbxface-0107 [01] load_tables           : ACPI Tables successfully acquired
> Parsing all Control Methods:
> Table [DSDT](id 0005) - 563 Objects with 71 Devices 199 Methods 24 Regions
> ACPI Namespace successfully loaded at root ffffffff8076aea0
> evxfevnt-0089 [02] enable                : Transition to ACPI mode successful
> Using local APIC timer interrupts.
> result 12557932
> Detected 12.557 MHz APIC timer.
> Booting processor 1/2 APIC 0x1
> Initializing CPU#1
> Calibrating delay using timer specific routine.. 4821.51 BogoMIPS (lpj=2410757)
> CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
> CPU: L2 Cache: 1024K (64 bytes/line)
> CPU 1/1 -> Node 1
> AMD Opteron(tm) Processor 250 stepping 01
> CPU 1: Syncing TSC to CPU 0.
> CPU 1: synchronized TSC with CPU 0 (last diff -148 cycles, maxerr 851 cycles)
> Brought up 2 CPUs
> testing NMI watchdog ... OK.
> Disabling vsyscall due to use of PM timer
> time.c: Using 3.579545 MHz WALL PM GTOD PM timer.
> time.c: Detected 2411.120 MHz processor.
> migration_cost=512
> NET: Registered protocol family 16
> ACPI: bus type pci registered
> PCI: Using configuration type 1
> evgpeblk-0951 [04] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs on int 0x9
> evgpeblk-1048 [03] ev_initialize_gpe_bloc: Found 6 Wake, Enabled 1 Runtime GPEs in this block
> Completing Region/Field/Buffer/Package initialization:...............................................................
> Initialized 24/24 Regions 1/1 Fields 25/25 Buffers 13/26 Packages (572 nodes)
> Initializing Device/Processor/Thermal objects by executing _INI methods:
> Executed 0 _INI methods requiring 0 _STA executions (examined 77 objects)
> ACPI: Interpreter enabled
> ACPI: Using IOAPIC for interrupt routing
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> PCI: Probing PCI hardware (bus 00)
> ACPI: Assume root bridge [\_SB_.PCI0] bus is 0
> PCI: Scanning bus 0000:00
> PCI: Found 0000:00:00.0 [10de/005e] 000580 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:00.0
> PCI: Found 0000:00:01.0 [10de/0051] 000601 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:01.0
> PCI: Found 0000:00:01.1 [10de/0052] 000c05 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:01.1
> PCI: Found 0000:00:02.0 [10de/005a] 000c03 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:02.0
> PCI: Found 0000:00:02.1 [10de/005b] 000c03 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:02.1
> PCI: Found 0000:00:06.0 [10de/0053] 000101 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:06.0
> PCI: Found 0000:00:07.0 [10de/0054] 000101 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:07.0
> PCI: Found 0000:00:08.0 [10de/0055] 000101 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:08.0
> PCI: Found 0000:00:09.0 [10de/005c] 000604 01
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:09.0
> PCI: Found 0000:00:0d.0 [10de/005d] 000604 01
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:0d.0
> PCI: Found 0000:00:0e.0 [10de/005d] 000604 01
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:0e.0
> PCI: Found 0000:00:18.0 [1022/1100] 000600 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:18.0
> PCI: Found 0000:00:18.1 [1022/1101] 000600 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:18.1
> PCI: Found 0000:00:18.2 [1022/1102] 000600 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:18.2
> PCI: Found 0000:00:18.3 [1022/1103] 000600 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:18.3
> PCI: Found 0000:00:19.0 [1022/1100] 000600 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:19.0
> PCI: Found 0000:00:19.1 [1022/1101] 000600 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:19.1
> PCI: Found 0000:00:19.2 [1022/1102] 000600 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:19.2
> PCI: Found 0000:00:19.3 [1022/1103] 000600 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:00:19.3
> PCI: Fixups for bus 0000:00
> PCI: Scanning behind PCI bridge 0000:00:09.0, config 010100, pass 0
> PCI: Scanning bus 0000:01
> PCI: Found 0000:01:06.0 [1002/4752] 000300 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:01:06.0
> Boot video device is 0000:01:06.0
> PCI: Found 0000:01:08.0 [8086/1229] 000200 00
> PCI: Calling quirk ffffffff8039f910 for 0000:01:08.0
> PCI: Firmware left 0000:01:08.0 e100 interrupts enabled, disabling
> PCI: Calling quirk ffffffff8049ea60 for 0000:01:08.0
> PCI: Calling quirk ffffffff8049ef80 for 0000:01:08.0
> PCI: Fixups for bus 0000:01
> PCI: Transparent bridge - 0000:00:09.0
> PCI: Bus scan for 0000:01 returning with max=01
> PCI: Scanning behind PCI bridge 0000:00:0d.0, config 020200, pass 0
> PCI: Scanning bus 0000:02
> PCI: Fixups for bus 0000:02
> PCI: Bus scan for 0000:02 returning with max=02
> PCI: Scanning behind PCI bridge 0000:00:0e.0, config 030300, pass 0
> PCI: Scanning bus 0000:03
> PCI: Fixups for bus 0000:03
> PCI: Bus scan for 0000:03 returning with max=03
> PCI: Scanning behind PCI bridge 0000:00:09.0, config 010100, pass 1
> PCI: Scanning behind PCI bridge 0000:00:0d.0, config 020200, pass 1
> PCI: Scanning behind PCI bridge 0000:00:0e.0, config 030300, pass 1
> PCI: Bus scan for 0000:00 returning with max=03
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P2P0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.XVR0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.XVR1._PRT]
> ACPI: PCI Interrupt Link [LNK1] (IRQs 16 17 18 19) *0
> ACPI: PCI Interrupt Link [LNK2] (IRQs 16 17 18 19) *0
> ACPI: PCI Interrupt Link [LNK3] (IRQs 16 17 18 19) *0
> ACPI: PCI Interrupt Link [LNK4] (IRQs 16 17 18 19) *0, disabled.
> ACPI: PCI Interrupt Link [LNK5] (IRQs 16 17 18 19) *0, disabled.
> ACPI: PCI Interrupt Link [LSMB] (IRQs 20 21 22 23) *0, disabled.
> ACPI: PCI Interrupt Link [LUS0] (IRQs 20 21 22 23) *0
> ACPI: PCI Interrupt Link [LUS2] (IRQs 20 21 22 23) *0
> ACPI: PCI Interrupt Link [LMAC] (IRQs 20 21 22 23) *0, disabled.
> ACPI: PCI Interrupt Link [LACI] (IRQs 20 21 22 23) *0, disabled.
> ACPI: PCI Interrupt Link [LMCI] (IRQs 20 21 22 23) *0, disabled.
> ACPI: PCI Interrupt Link [LPID] (IRQs 20 21 22 23) *0, disabled.
> ACPI: PCI Interrupt Link [LTID] (IRQs 20 21 22 23) *0
> ACPI: PCI Interrupt Link [LSI1] (IRQs 20 21 22 23) *0, disabled.
> ACPI: PCI Interrupt Link [APCP] (IRQs 20 21 22 23) *0, disabled.
> ACPI: PCI Root Bridge [PCI2] (0000:08)
> PCI: Probing PCI hardware (bus 08)
> ACPI: Assume root bridge [\_SB_.PCI0] bus is 0
> PCI: Scanning bus 0000:08
> PCI: Found 0000:08:0a.0 [1022/7450] 000604 01
> PCI: Calling quirk ffffffff8049ef80 for 0000:08:0a.0
> PCI: Found 0000:08:0a.1 [1022/7451] 000800 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:08:0a.1
> PCI: Found 0000:08:0b.0 [1022/7450] 000604 01
> PCI: Calling quirk ffffffff8049ef80 for 0000:08:0b.0
> PCI: Found 0000:08:0b.1 [1022/7451] 000800 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:08:0b.1
> PCI: Fixups for bus 0000:08
> PCI: Scanning behind PCI bridge 0000:08:0a.0, config 090908, pass 0
> PCI: Scanning bus 0000:09
> PCI: Fixups for bus 0000:09
> PCI: Bus scan for 0000:09 returning with max=09
> PCI: Scanning behind PCI bridge 0000:08:0b.0, config 0a0a08, pass 0
> PCI: Scanning bus 0000:0a
> PCI: Found 0000:0a:03.0 [8086/1026] 000200 00
> PCI: Calling quirk ffffffff8039f910 for 0000:0a:03.0
> PCI: Calling quirk ffffffff8049ea60 for 0000:0a:03.0
> PCI: Calling quirk ffffffff8049ef80 for 0000:0a:03.0
> PCI: Found 0000:0a:09.0 [14e4/1648] 000200 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:0a:09.0
> PCI: Found 0000:0a:09.1 [14e4/1648] 000200 00
> PCI: Calling quirk ffffffff8049ef80 for 0000:0a:09.1
> PCI: Fixups for bus 0000:0a
> PCI: Bus scan for 0000:0a returning with max=0a
> PCI: Scanning behind PCI bridge 0000:08:0a.0, config 090908, pass 1
> PCI: Scanning behind PCI bridge 0000:08:0b.0, config 0a0a08, pass 1
> PCI: Bus scan for 0000:08 returning with max=0a
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI2.G0PA._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI2.G0PB._PRT]
> SCSI subsystem initialized
> libata version 2.00 loaded.
> PCI: Using ACPI for IRQ routing
> PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
> PCI-DMA: Disabling AGP.
> PCI-DMA: aperture base @ 4000000 size 65536 KB
> PCI-DMA: using GART IOMMU.
> PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
>   got res [1000:101f] bus [1000:101f] flags 101 for BAR 0 of 0000:00:01.1
> PCI: moved device 0000:00:01.1 resource 0 (101) to 1000
>   got res [c2000000:c201ffff] bus [c2000000:c201ffff] flags 7202 for BAR 6 of 0000:01:06.0
> PCI: Bridge: 0000:00:09.0
>   IO window: 2000-2fff
>   MEM window: dd100000-deffffff
>   PREFETCH window: c2000000-c20fffff
> PCI: Bridge: 0000:00:0d.0
>   IO window: disabled.
>   MEM window: disabled.
>   PREFETCH window: disabled.
> PCI: Bridge: 0000:00:0e.0
>   IO window: disabled.
>   MEM window: disabled.
>   PREFETCH window: disabled.
> PCI: Setting latency timer of device 0000:00:09.0 to 64
> PCI: Setting latency timer of device 0000:00:0d.0 to 64
> PCI: Setting latency timer of device 0000:00:0e.0 to 64
> PCI: Bridge: 0000:08:0a.0
>   IO window: disabled.
>   MEM window: disabled.
>   PREFETCH window: disabled.
>   got res [c2100000:c213ffff] bus [c2100000:c213ffff] flags 7200 for BAR 6 of 0000:0a:03.0
>   got res [c2140000:c214ffff] bus [c2140000:c214ffff] flags 7200 for BAR 6 of 0000:0a:09.0
>   got res [c2150000:c215ffff] bus [c2150000:c215ffff] flags 7200 for BAR 6 of 0000:0a:09.1
> PCI: Bridge: 0000:08:0b.0
>   IO window: 3000-3fff
>   MEM window: df300000-df3fffff
>   PREFETCH window: c2100000-c21fffff
> NET: Registered protocol family 2
> IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
> TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
> TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> TCP: Hash tables configured (established 262144 bind 65536)
> TCP reno registered
> Simple Boot Flag at 0x36 set to 0x1
> NTFS driver 2.1.28 [Flags: R/O].
> io scheduler noop registered
> io scheduler anticipatory registered (default)
> io scheduler deadline registered
> io scheduler cfq registered
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:00.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:00.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:01.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:01.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:01.1
> PCI: Calling quirk ffffffff8048da50 for 0000:00:01.1
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:02.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:02.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:02.1
> PCI: Calling quirk ffffffff8048da50 for 0000:00:02.1
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:06.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:06.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:07.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:07.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:08.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:08.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:09.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:09.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:0d.0
> PCI: Calling quirk ffffffff8039e9b0 for 0000:00:0d.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:0d.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:0e.0
> PCI: Calling quirk ffffffff8039e9b0 for 0000:00:0e.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:0e.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:18.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:18.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:18.1
> PCI: Calling quirk ffffffff8048da50 for 0000:00:18.1
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:18.2
> PCI: Calling quirk ffffffff8048da50 for 0000:00:18.2
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:18.3
> PCI: Calling quirk ffffffff8048da50 for 0000:00:18.3
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:19.0
> PCI: Calling quirk ffffffff8048da50 for 0000:00:19.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:19.1
> PCI: Calling quirk ffffffff8048da50 for 0000:00:19.1
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:19.2
> PCI: Calling quirk ffffffff8048da50 for 0000:00:19.2
> PCI: Calling quirk ffffffff8039fdf0 for 0000:00:19.3
> PCI: Calling quirk ffffffff8048da50 for 0000:00:19.3
> PCI: Calling quirk ffffffff8039fdf0 for 0000:01:06.0
> PCI: Calling quirk ffffffff8048da50 for 0000:01:06.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:01:08.0
> PCI: Calling quirk ffffffff8039ed70 for 0000:01:08.0
> PCI: Calling quirk ffffffff8048da50 for 0000:01:08.0
> PCI: Calling quirk ffffffff8039f270 for 0000:08:0a.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:08:0a.0
> PCI: Calling quirk ffffffff8048da50 for 0000:08:0a.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:08:0a.1
> PCI: Calling quirk ffffffff8048da50 for 0000:08:0a.1
> PCI: Calling quirk ffffffff8039f270 for 0000:08:0b.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:08:0b.0
> PCI: Calling quirk ffffffff8048da50 for 0000:08:0b.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:08:0b.1
> PCI: Calling quirk ffffffff8048da50 for 0000:08:0b.1
> PCI: Calling quirk ffffffff8039fdf0 for 0000:0a:03.0
> PCI: Calling quirk ffffffff8039ed70 for 0000:0a:03.0
> PCI: Calling quirk ffffffff8048da50 for 0000:0a:03.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:0a:09.0
> PCI: Calling quirk ffffffff8048da50 for 0000:0a:09.0
> PCI: Calling quirk ffffffff8039fdf0 for 0000:0a:09.1
> PCI: Calling quirk ffffffff8048da50 for 0000:0a:09.1
> PCI: Setting latency timer of device 0000:00:0d.0 to 64
> assign_interrupt_mode Found MSI capability
> Allocate Port Service[0000:00:0d.0:pcie00]
> PCI: Setting latency timer of device 0000:00:0e.0 to 64
> assign_interrupt_mode Found MSI capability
> Allocate Port Service[0000:00:0e.0:pcie00]
> lp: driver loaded but no devices found
> Real Time Clock Driver v1.12ac
> Non-volatile memory driver v1.2
> Linux agpgart interface v0.101 (c) Dave Jones
> Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 seconds).
> Hangcheck: Using monotonic_clock().
> Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
> serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> parport0: PC-style at 0x378 (0x778) [PCSPP,TRISTATE,EPP]
> parport0: irq 7 detected
> lp0: using parport0 (polling).
> lp0: console ready
> FDC 0 is a post-1991 82077
> RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
> loop: loaded (max 8 devices)
> Intel(R) PRO/1000 Network Driver - version 7.3.15-k2-NAPI
> Copyright (c) 1999-2006 Intel Corporation.
> ACPI: PCI Interrupt 0000:0a:03.0[A] -> GSI 30 (level, low) -> IRQ 30
> e1000: 0000:0a:03.0: e1000_probe: (PCI-X:100MHz:64-bit) 00:04:23:9f:0f:b2
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> e100: Intel(R) PRO/100 Network Driver, 3.5.17-k2-NAPI
> e100: Copyright(c) 1999-2006 Intel Corporation
> ACPI: PCI Interrupt Link [LNK3] enabled at IRQ 19
> ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [LNK3] -> GSI 19 (level, high) -> IRQ 19
> e100: eth1: e100_probe: addr 0xdd101000, irq 19, MAC addr 00:E0:81:33:57:F2
> tg3.c:v3.72 (January 8, 2007)
> ACPI: PCI Interrupt 0000:0a:09.0[A] -> GSI 28 (level, low) -> IRQ 28
> eth2: Tigon3 [partno(BCM95704A7) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit) 10/100/1000Base-T Ethernet 00:e0:81:33:57:c4
> eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1] 
> eth2: dma_rwctrl[769f4000] dma_mask[64-bit]
> ACPI: PCI Interrupt 0000:0a:09.1[B] -> GSI 29 (level, low) -> IRQ 29
> eth3: Tigon3 [partno(BCM95704A7) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit) 10/100/1000Base-T Ethernet 00:e0:81:33:57:c5
> eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1] 
> eth3: dma_rwctrl[769f4000] dma_mask[64-bit]
> PPP generic driver version 2.4.2
> PPP Deflate Compression module registered
> PPP BSD Compression module registered
> tun: Universal TUN/TAP device driver, 1.6
> tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> netconsole: not configured, aborting
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
> NFORCE-CK804: IDE controller at PCI slot 0000:00:06.0
> NFORCE-CK804: chipset revision 242
> NFORCE-CK804: not 100% native mode: will probe irqs later
> NFORCE-CK804: BIOS didn't set cable bits correctly. Enabling workaround.
> NFORCE-CK804: 0000:00:06.0 (rev f2) UDMA133 controller
>     ide0: BM-DMA at 0x1400-0x1407, BIOS settings: hda:pio, hdb:pio
>     ide1: BM-DMA at 0x1408-0x140f, BIOS settings: hdc:DMA, hdd:pio
> Probing IDE interface ide0...
> Probing IDE interface ide1...
> hdc: HDS722516VLAT80, ATA DISK drive
> ide1 at 0x170-0x177,0x376 on irq 15
> Probing IDE interface ide0...
> hdc: max request size: 512KiB
> hdc: 321672960 sectors (164696 MB) w/7938KiB Cache, CHS=20023/255/63, UDMA(100)
> hdc: cache flushes supported
>  hdc: hdc1 hdc2 hdc3 hdc4
> 3ware Storage Controller device driver for Linux v1.26.02.002.
> sata_nv 0000:00:07.0: version 3.2
> ACPI: PCI Interrupt Link [LTID] enabled at IRQ 23
> ACPI: PCI Interrupt 0000:00:07.0[A] -> Link [LTID] -> GSI 23 (level, high) -> IRQ 23
> sata_nv 0000:00:07.0: Using ADMA mode
> PCI: Setting latency timer of device 0000:00:07.0 to 64
> ata1: SATA max UDMA/133 cmd 0xFFFFC20000006480 ctl 0xFFFFC200000064A0 bmdma 0x1410 irq 23
> ata2: SATA max UDMA/133 cmd 0xFFFFC20000006580 ctl 0xFFFFC200000065A0 bmdma 0x1418 irq 23
> scsi0 : sata_nv
> ata1: SATA link down (SStatus 0 SControl 300)
> scsi1 : sata_nv
> ata2: SATA link down (SStatus 0 SControl 300)
> ACPI: PCI Interrupt Link [LSI1] enabled at IRQ 22
> ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [LSI1] -> GSI 22 (level, high) -> IRQ 22
> sata_nv 0000:00:08.0: Using ADMA mode
> PCI: Setting latency timer of device 0000:00:08.0 to 64
> ata3: SATA max UDMA/133 cmd 0xFFFFC2000001A480 ctl 0xFFFFC2000001A4A0 bmdma 0x1420 irq 22
> ata4: SATA max UDMA/133 cmd 0xFFFFC2000001A580 ctl 0xFFFFC2000001A5A0 bmdma 0x1428 irq 22
> scsi2 : sata_nv
> ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> ata3.00: ATA-7, max UDMA/133, 488397168 sectors: LBA48 
> ata3.00: ata3: dev 0 multi count 16
> ata3.00: configured for UDMA/133
> scsi3 : sata_nv
> ata4: SATA link down (SStatus 0 SControl 300)
> scsi 2:0:0:0: Direct-Access     ATA      WDC WD2500JS-41M 10.0 PQ: 0 ANSI: 5
> ata3: bounce limit 0xFFFFFFFFFFFFFFFF, segment boundary 0xFFFFFFFF, hw segs 61
> SCSI device sda: 488397168 512-byte hdwr sectors (250059 MB)
> sda: Write Protect is off
> sda: Mode Sense: 00 3a 00 00
> SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> SCSI device sda: 488397168 512-byte hdwr sectors (250059 MB)
> sda: Write Protect is off
> sda: Mode Sense: 00 3a 00 00
> SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
>  sda: sda1 sda2 sda4 < sda5 sda6 sda7 sda8 sda9 sda10 sda11 >
> sd 2:0:0:0: Attached scsi disk sda
> sd 2:0:0:0: Attached scsi generic sg0 type 0
> serio: i8042 KBD port at 0x60,0x64 irq 1
> mice: PS/2 mouse device common for all mice
> input: PC Speaker as /class/input/input0
> input: AT Translated Set 2 keyboard as /class/input/input1
> i2c /dev entries driver
> oprofile: using NMI interrupt.
> GACT probability on
> u32 classifier
>     input device check on 
>     Actions configured 
> IPv4 over IPv4 tunneling driver
> GRE over IPv4 tunneling driver
> TCP cubic registered
> Initializing XFRM netlink socket
> NET: Registered protocol family 1
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
> All bugs added by David S. Miller <davem@redhat.com>
> VFS: Mounted root (ext2 filesystem) readonly.
> Freeing unused kernel memory: 336k freed
> Write protecting the kernel read-only data: 1150k
> Adding 4891752k swap on /dev/sda5.  Priority:3 extents:1 across:4891752k
> Adding 1959888k swap on /dev/hdc1.  Priority:2 extents:1 across:1959888k
> NET: Registered protocol family 10
> NET: Registered protocol family 24
> HDLC line discipline: version $Revision: 4.8 $, maxframe=4096
> N_HDLC line discipline registered.
> Netfilter messages via NETLINK v0.30.
> nf_conntrack version 0.5.0 (8192 buckets, 65536 max)
> ReiserFS: sda7: found reiserfs format "3.6" with standard journal
> ReiserFS: sda7: using ordered data mode
> ReiserFS: sda7: journal params: device sda7, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
> ReiserFS: sda7: checking transaction log (sda7)
> ReiserFS: sda7: replayed 246 transactions in 2 seconds
> ReiserFS: sda7: Using r5 hash to sort names
> ReiserFS: sda7: Removing [3573 2687 0x0 SD]..done
> ReiserFS: sda7: There were 1 uncompleted unlinks/truncates. Completed
> ReiserFS: sda6: found reiserfs format "3.6" with standard journal
> ReiserFS: sda6: using ordered data mode
> ReiserFS: sda6: journal params: device sda6, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
> ReiserFS: sda6: checking transaction log (sda6)
> ReiserFS: sda6: replayed 1744 transactions in 1 seconds
> ReiserFS: sda6: Using r5 hash to sort names
> ReiserFS: sda6: Removing [2 76 0x0 SD]..done
> ReiserFS: sda6: Removing [2 75 0x0 SD]..done
> ReiserFS: sda6: Removing [2 74 0x0 SD]..done
> ReiserFS: sda6: Removing [2 60 0x0 SD]..done
> ReiserFS: sda6: Removing [2 58 0x0 SD]..done
> ReiserFS: sda6: Removing [2 12 0x0 SD]..done
> ReiserFS: sda6: There were 6 uncompleted unlinks/truncates. Completed
> ReiserFS: sda8: found reiserfs format "3.6" with standard journal
> ReiserFS: sda8: using ordered data mode
> ReiserFS: sda8: journal params: device sda8, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
> ReiserFS: sda8: checking transaction log (sda8)
> ReiserFS: sda8: replayed 310 transactions in 2 seconds
> ReiserFS: sda8: Using r5 hash to sort names
> ReiserFS: hdc2: found reiserfs format "3.6" with standard journal
> ReiserFS: hdc2: using ordered data mode
> ReiserFS: hdc2: journal params: device hdc2, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
> ReiserFS: hdc2: checking transaction log (hdc2)
> ReiserFS: hdc2: replayed 416 transactions in 4 seconds
> ReiserFS: hdc2: Using r5 hash to sort names
> ReiserFS: sda9: found reiserfs format "3.6" with standard journal
> ReiserFS: sda9: using ordered data mode
> ReiserFS: sda9: journal params: device sda9, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
> ReiserFS: sda9: checking transaction log (sda9)
> ReiserFS: sda9: replayed 391 transactions in 1 seconds
> ReiserFS: sda9: Using r5 hash to sort names
> ReiserFS: sda9: Removing [2 6232 0x0 SD]..done
> ReiserFS: sda9: Removing [2 5952 0x0 SD]..done
> ReiserFS: sda9: Removing [2 5915 0x0 SD]..done
> ReiserFS: sda9: Removing [2 5869 0x0 SD]..done
> ReiserFS: sda9: Removing [2 5846 0x0 SD]..done
> ReiserFS: sda9: There were 5 uncompleted unlinks/truncates. Completed
> ReiserFS: hdc3: found reiserfs format "3.6" with standard journal
> ReiserFS: hdc3: using ordered data mode
> ReiserFS: hdc3: journal params: device hdc3, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
> ReiserFS: hdc3: checking transaction log (hdc3)
> ReiserFS: hdc3: replayed 959 transactions in 3 seconds
> ReiserFS: hdc3: Using r5 hash to sort names
> ReiserFS: hdc4: found reiserfs format "3.6" with standard journal
> ReiserFS: hdc4: using ordered data mode
> ReiserFS: hdc4: journal params: device hdc4, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
> ReiserFS: hdc4: checking transaction log (hdc4)
> ReiserFS: hdc4: replayed 227 transactions in 11 seconds
> ReiserFS: hdc4: Using r5 hash to sort names
> ReiserFS: sda10: found reiserfs format "3.6" with standard journal
> ReiserFS: sda10: using ordered data mode
> ReiserFS: sda10: journal params: device sda10, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
> ReiserFS: sda10: checking transaction log (sda10)
> ReiserFS: sda10: replayed 707 transactions in 2 seconds
> ReiserFS: sda10: Using r5 hash to sort names
> ip_tables: (C) 2000-2006 Netfilter Core Team
> IPv4 FIB: Using LC-trie version 0.407
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex
> vlan0068: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0068: link is not ready
> PM: Writing back config space on device 0000:0a:09.0 at offset b (was 164814e4, writing 164414e4)
> PM: Writing back config space on device 0000:0a:09.0 at offset 3 (was 804000, writing 804010)
> PM: Writing back config space on device 0000:0a:09.0 at offset 2 (was 2000000, writing 2000003)
> PM: Writing back config space on device 0000:0a:09.0 at offset 1 (was 2b00000, writing 2b00106)
> ADDRCONF(NETDEV_UP): eth2: link is not ready
> PM: Writing back config space on device 0000:0a:09.0 at offset b (was 164814e4, writing 164414e4)
> PM: Writing back config space on device 0000:0a:09.0 at offset 3 (was 804000, writing 804010)
> PM: Writing back config space on device 0000:0a:09.0 at offset 2 (was 2000000, writing 2000003)
> PM: Writing back config space on device 0000:0a:09.0 at offset 1 (was 2b00000, writing 2b00106)
> PM: Writing back config space on device 0000:0a:09.0 at offset b (was 164814e4, writing 164414e4)
> PM: Writing back config space on device 0000:0a:09.0 at offset 3 (was 804000, writing 804010)
> PM: Writing back config space on device 0000:0a:09.0 at offset 2 (was 2000000, writing 2000003)
> PM: Writing back config space on device 0000:0a:09.0 at offset 1 (was 2b00000, writing 2b00106)
> PM: Writing back config space on device 0000:0a:09.1 at offset b (was 164814e4, writing 164414e4)
> PM: Writing back config space on device 0000:0a:09.1 at offset 3 (was 804000, writing 804010)
> PM: Writing back config space on device 0000:0a:09.1 at offset 2 (was 2000000, writing 2000003)
> PM: Writing back config space on device 0000:0a:09.1 at offset 1 (was 2b00000, writing 2b00106)
> ADDRCONF(NETDEV_UP): eth3: link is not ready
> vlan0180: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0180: link is not ready
> IPv6 over IPv4 tunneling driver
> vlan0113: add 01:00:5e:00:00:01 mcast address to master interface
> vlan0113: add 33:33:00:00:00:01 mcast address to master interface
> vlan0113: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0170: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0170: link is not ready
> vlan0169: add 01:00:5e:00:00:01 mcast address to master interface
> vlan0169: add 33:33:00:00:00:01 mcast address to master interface
> vlan0169: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0168: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0168: link is not ready
> vlan0167: add 01:00:5e:00:00:01 mcast address to master interface
> vlan0167: add 33:33:00:00:00:01 mcast address to master interface
> vlan0167: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0152: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0152: link is not ready
> vlan0152: add 33:33:00:00:00:01 mcast address to master interface
> vlan0152: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0151: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0151: link is not ready
> vlan0151: add 33:33:00:00:00:01 mcast address to master interface
> vlan0151: add 33:33:ff:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> vlan0153: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0153: link is not ready
> ADDRCONF(NETDEV_UP): vlan0193: link is not ready
> ADDRCONF(NETDEV_UP): vlan0194: link is not ready
> ADDRCONF(NETDEV_UP): vlan0196: link is not ready
> ADDRCONF(NETDEV_UP): vlan0197: link is not ready
> ADDRCONF(NETDEV_UP): vlan0198: link is not ready
> vlan0174: add 01:00:5e:00:00:01 mcast address to master interface
> vlan0174: add 33:33:00:00:00:01 mcast address to master interface
> vlan0174: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0174: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0173: add 01:00:5e:00:00:01 mcast address to master interface
> vlan0173: add 33:33:00:00:00:01 mcast address to master interface
> vlan0173: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0173: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0172: add 01:00:5e:00:00:01 mcast address to master interface
> vlan0172: add 33:33:00:00:00:01 mcast address to master interface
> vlan0172: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0172: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0171: add 01:00:5e:00:00:01 mcast address to master interface
> vlan0171: add 33:33:00:00:00:01 mcast address to master interface
> vlan0171: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0171: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0169: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0200: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0200: link is not ready
> vlan0200: add 33:33:00:00:00:01 mcast address to master interface
> vlan0200: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0201: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0201: link is not ready
> vlan0201: add 33:33:00:00:00:01 mcast address to master interface
> vlan0201: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0202: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0202: link is not ready
> vlan0202: add 33:33:00:00:00:01 mcast address to master interface
> vlan0202: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0154: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0154: link is not ready
> ADDRCONF(NETDEV_CHANGE): vlan0068: link becomes ready
> vlan0068: add 33:33:00:00:00:01 mcast address to master interface
> vlan0068: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0113: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0154: add 33:33:00:00:00:01 mcast address to master interface
> vlan0154: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0155: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0155: link is not ready
> vlan0155: add 33:33:00:00:00:01 mcast address to master interface
> vlan0155: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0156: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0156: link is not ready
> vlan0156: add 33:33:00:00:00:01 mcast address to master interface
> vlan0156: add 33:33:ff:00:00:01 mcast address to master interface
> vlan0175: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0175: link is not ready
> vlan0181: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0181: link is not ready
> vlan0182: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0182: link is not ready
> vlan0167: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0183: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0183: link is not ready
> vlan0176: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0176: link is not ready
> vlan0205: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0205: link is not ready
> vlan0206: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0206: link is not ready
> vlan0207: add 01:00:5e:00:00:01 mcast address to master interface
> vlan0207: add 33:33:00:00:00:01 mcast address to master interface
> vlan0207: add 33:33:ff:9f:0f:b2 mcast address to master interface
> vlan0190: add 01:00:5e:00:00:01 mcast address to master interface
> ADDRCONF(NETDEV_UP): vlan0190: link is not ready
> vlan0173: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0174: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0171: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0172: add 33:33:ff:00:00:00 mcast address to master interface
> tg3: eth3: Link is up at 1000 Mbps, full duplex.
> tg3: eth3: Flow control is on for TX and on for RX.
> vlan0068: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0207: add 33:33:ff:00:00:00 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> ADDRCONF(NETDEV_CHANGE): vlan0151: link becomes ready
> vlan0151: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0152: link becomes ready
> vlan0152: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0153: link becomes ready
> vlan0153: add 33:33:00:00:00:01 mcast address to master interface
> vlan0153: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0154: link becomes ready
> vlan0154: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0155: link becomes ready
> vlan0155: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0156: link becomes ready
> vlan0156: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0168: link becomes ready
> vlan0168: add 33:33:00:00:00:01 mcast address to master interface
> vlan0168: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0170: link becomes ready
> vlan0170: add 33:33:00:00:00:01 mcast address to master interface
> vlan0170: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0176: link becomes ready
> vlan0176: add 33:33:00:00:00:01 mcast address to master interface
> vlan0176: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0180: link becomes ready
> vlan0180: add 33:33:00:00:00:01 mcast address to master interface
> vlan0180: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0182: link becomes ready
> vlan0182: add 33:33:00:00:00:01 mcast address to master interface
> vlan0182: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0193: link becomes ready
> vlan0193: add 33:33:00:00:00:01 mcast address to master interface
> vlan0193: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0194: link becomes ready
> vlan0194: add 33:33:00:00:00:01 mcast address to master interface
> vlan0194: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0196: link becomes ready
> vlan0196: add 33:33:00:00:00:01 mcast address to master interface
> vlan0196: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0197: link becomes ready
> vlan0197: add 33:33:00:00:00:01 mcast address to master interface
> vlan0197: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0198: link becomes ready
> vlan0198: add 33:33:00:00:00:01 mcast address to master interface
> vlan0198: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0200: link becomes ready
> vlan0200: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0201: link becomes ready
> vlan0201: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0202: link becomes ready
> vlan0202: add 33:33:ff:33:57:c5 mcast address to master interface
> ADDRCONF(NETDEV_CHANGE): vlan0205: link becomes ready
> vlan0205: add 33:33:00:00:00:01 mcast address to master interface
> vlan0205: add 33:33:ff:33:57:c5 mcast address to master interface
> vlan0180: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0202: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0152: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0176: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0151: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0170: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0168: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0182: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0200: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0201: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0155: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0154: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0193: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0194: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0156: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0153: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0197: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0196: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0198: add 33:33:ff:00:00:00 mcast address to master interface
> vlan0205: add 33:33:ff:00:00:00 mcast address to master interface
> printk: 365774 messages suppressed.
> eth3: duplicate address detected!
> printk: 346483 messages suppressed.
> eth3: duplicate address detected!
> vlan0068: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0151: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0152: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0171: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0175: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0176: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0180: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0180: del 01:00:5e:00:00:05 mcast address from master interface
> vlan0180: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0181: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0183: add 01:00:5e:00:00:05 mcast address to master interface
> vlan0171: add 33:33:00:00:00:02 mcast address to master interface
> vlan0172: add 33:33:00:00:00:02 mcast address to master interface
> vlan0173: add 33:33:00:00:00:02 mcast address to master interface
> vlan0174: add 33:33:00:00:00:02 mcast address to master interface
> vlan0151: add 33:33:00:00:00:02 mcast address to master interface
> vlan0152: add 33:33:00:00:00:02 mcast address to master interface
> vlan0200: add 33:33:00:00:00:02 mcast address to master interface
> vlan0201: add 33:33:00:00:00:02 mcast address to master interface
> vlan0202: add 33:33:00:00:00:02 mcast address to master interface
> vlan0154: add 33:33:00:00:00:02 mcast address to master interface
> vlan0155: add 33:33:00:00:00:02 mcast address to master interface
> vlan0156: add 33:33:00:00:00:02 mcast address to master interface
> printk: 172701 messages suppressed.
> eth3: duplicate address detected!
> printk: 127248 messages suppressed.
> eth3: duplicate address detected!
> printk: 128039 messages suppressed.
> eth3: duplicate address detected!
> printk: 128701 messages suppressed.
> eth3: duplicate address detected!
> printk: 131442 messages suppressed.
> eth3: duplicate address detected!
> BUG: soft lockup detected on CPU#1!
>
> Call Trace:
>  <IRQ>  [<ffffffff802a87fa>] softlockup_tick+0xfa/0x120
>  [<ffffffff80293f37>] update_process_times+0x57/0x90
>  [<ffffffff80277f04>] smp_local_timer_interrupt+0x34/0x60
>  [<ffffffff80278469>] smp_apic_timer_interrupt+0x59/0x80
>  [<ffffffff80263db6>] apic_timer_interrupt+0x66/0x70
>  [<ffffffff88056fe0>] :nf_conntrack:generic_invert_tuple+0x0/0x20
>  [<ffffffff8020a30a>] kmem_cache_alloc+0x8a/0xa0
>  [<ffffffff88054184>] :nf_conntrack:__nf_conntrack_alloc+0x1e4/0x300
>  [<ffffffff88053429>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
>  [<ffffffff88054e61>] :nf_conntrack:nf_conntrack_in+0x1e1/0x580
>  [<ffffffff8026a799>] _read_lock_bh+0x9/0x20
>  [<ffffffff80235c7c>] nf_iterate+0x5c/0xa0
>  [<ffffffff804d6700>] ip_rcv_finish+0x0/0x2b0
>  [<ffffffff8025b9a4>] nf_hook_slow+0x64/0xe0
>  [<ffffffff804d6700>] ip_rcv_finish+0x0/0x2b0
>  [<ffffffff802c0110>] ____cache_alloc_node+0x90/0x150
>  [<ffffffff802371eb>] ip_rcv+0x27b/0x540
>  [<ffffffff80221630>] netif_receive_skb+0x390/0x420
>  [<ffffffff8043af41>] tg3_poll+0x781/0xa00
>  [<ffffffff8020c8dc>] net_rx_action+0xbc/0x190
>  [<ffffffff802937bc>] run_timer_softirq+0x3c/0x1c0
>  [<ffffffff8021270f>] __do_softirq+0x5f/0xd0
>  [<ffffffff8026430c>] call_softirq+0x1c/0x28
>  <EOI>  [<ffffffff802705ec>] do_softirq+0x2c/0x90
>  [<ffffffff8028fbaf>] local_bh_enable_ip+0x3f/0x60
>  [<ffffffff80240374>] rt_run_flush+0x94/0xe0
>  [<ffffffff804f7a20>] fib_disable_ip+0x20/0x30
>  [<ffffffff804f82b9>] fib_netdev_event+0x29/0xd0
>  [<ffffffff80296c16>] notifier_call_chain+0x26/0x40
>  [<ffffffff804acc07>] unregister_netdevice+0x177/0x240
>  [<ffffffff804acce1>] unregister_netdev+0x11/0x20
>  [<ffffffff8043ebb1>] ppp_shutdown_interface+0x71/0xe0
>  [<ffffffff8043ee4b>] ppp_release+0x2b/0x70
>  [<ffffffff80212d05>] __fput+0xb5/0x1a0
>  [<ffffffff80225401>] filp_close+0x71/0x90
>  [<ffffffff8021ed72>] sys_close+0x92/0xf0
>  [<ffffffff802674d2>] ia32_sysret+0x0/0xa
>
> printk: 130818 messages suppressed.
> eth3: duplicate address detected!
> printk: 130769 messages suppressed.
> eth3: duplicate address detected!
> printk: 129949 messages suppressed.
> eth3: duplicate address detected!
> printk: 118914 messages suppressed.
> eth3: duplicate address detected!
> printk: 128525 messages suppressed.
> eth3: duplicate address detected!
> printk: 131994 messages suppressed.
> eth3: duplicate address detected!
> printk: 130834 messages suppressed.
> eth3: duplicate address detected!
> printk: 127260 messages suppressed.
> eth3: duplicate address detected!
> printk: 126441 messages suppressed.
> eth3: duplicate address detected!
> printk: 126365 messages suppressed.
> eth3: duplicate address detected!
> printk: 127585 messages suppressed.
> eth3: duplicate address detected!
> printk: 128419 messages suppressed.
> eth3: duplicate address detected!
> printk: 123833 messages suppressed.
> eth3: duplicate address detected!
> printk: 125497 messages suppressed.
> eth3: duplicate address detected!
> printk: 123214 messages suppressed.
> eth3: duplicate address detected!
> pptpctrl[4620]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffad1c30 error 4
> pptpctrl[4621]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffa893e0 error 4
> pptpctrl[4628]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000fff3a090 error 4
> pptpctrl[4632]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffbe7540 error 4
> pptpctrl[4709]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000fff908f0 error 4
> vlan0068: add 01:00:5e:00:00:06 mcast address to master interface
> vlan0151: add 01:00:5e:00:00:06 mcast address to master interface
> vlan0152: add 01:00:5e:00:00:06 mcast address to master interface
> vlan0171: add 01:00:5e:00:00:06 mcast address to master interface
> vlan0175: add 01:00:5e:00:00:06 mcast address to master interface
> vlan0176: add 01:00:5e:00:00:06 mcast address to master interface
> vlan0180: add 01:00:5e:00:00:06 mcast address to master interface
> tg3: eth3: Link is down.
> vlan0181: add 01:00:5e:00:00:06 mcast address to master interface
> vlan0183: add 01:00:5e:00:00:06 mcast address to master interface
> vlan0180: del 01:00:5e:00:00:06 mcast address from master interface
> vlan0180: add 01:00:5e:00:00:06 mcast address to master interface
> pptpctrl[5084]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffcfce60 error 4
> vlan0205: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0171: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0172: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0173: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0174: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0152: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0151: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0153: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0175: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0200: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0201: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0154: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0202: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0155: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0156: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0181: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0176: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0182: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0183: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0180: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0068: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0206: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0207: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0113: add 01:00:5e:00:01:29 mcast address to master interface
> vlan0190: add 01:00:5e:00:01:29 mcast address to master interface
> tg3: eth3: Link is up at 1000 Mbps, full duplex.
> tg3: eth3: Flow control is on for TX and on for RX.
> printk: 82979 messages suppressed.
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> eth3: duplicate address detected!
> printk: 153620 messages suppressed.
> eth3: duplicate address detected!
> printk: 153829 messages suppressed.
> eth3: duplicate address detected!
> BUG: soft lockup detected on CPU#0!
>
> Call Trace:
>  <IRQ>  [<ffffffff802a87fa>] softlockup_tick+0xfa/0x120
>  [<ffffffff804d6700>] ip_rcv_finish+0x0/0x2b0
>  [<ffffffff80293f37>] update_process_times+0x57/0x90
>  [<ffffffff80277f04>] smp_local_timer_interrupt+0x34/0x60
>  [<ffffffff80278469>] smp_apic_timer_interrupt+0x59/0x80
>  [<ffffffff80263db6>] apic_timer_interrupt+0x66/0x70
>  [<ffffffff8043ab5d>] tg3_poll+0x39d/0xa00
>  [<ffffffff8043af41>] tg3_poll+0x781/0xa00
>  [<ffffffff8020c8dc>] net_rx_action+0xbc/0x190
>  [<ffffffff802937bc>] run_timer_softirq+0x3c/0x1c0
>  [<ffffffff8021270f>] __do_softirq+0x5f/0xd0
>  [<ffffffff8026430c>] call_softirq+0x1c/0x28
>  <EOI>  [<ffffffff802705ec>] do_softirq+0x2c/0x90
>  [<ffffffff8028fbaf>] local_bh_enable_ip+0x3f/0x60
>  [<ffffffff80240374>] rt_run_flush+0x94/0xe0
>  [<ffffffff804b5590>] linkwatch_event+0x0/0x40
>  [<ffffffff804f8339>] fib_netdev_event+0xa9/0xd0
>  [<ffffffff80296c16>] notifier_call_chain+0x26/0x40
>  [<ffffffff804ac1d1>] netdev_state_change+0x21/0x40
>  [<ffffffff804b5562>] linkwatch_run_queue+0x152/0x180
>  [<ffffffff804b55bb>] linkwatch_event+0x2b/0x40
>  [<ffffffff802518e7>] run_workqueue+0xa7/0x160
>  [<ffffffff8024df60>] worker_thread+0x0/0x190
>  [<ffffffff8024e0ab>] worker_thread+0x14b/0x190
>  [<ffffffff8028a0b0>] default_wake_function+0x0/0x10
>  [<ffffffff8024df60>] worker_thread+0x0/0x190
>  [<ffffffff80234489>] kthread+0xd9/0x120
>  [<ffffffff80263f98>] child_rip+0xa/0x12
>  [<ffffffff802343b0>] kthread+0x0/0x120
>  [<ffffffff80263f8e>] child_rip+0x0/0x12
>
> printk: 154433 messages suppressed.
> eth3: duplicate address detected!
> printk: 152544 messages suppressed.
> eth3: duplicate address detected!
> printk: 150991 messages suppressed.
> eth3: duplicate address detected!
> printk: 151310 messages suppressed.
> eth3: duplicate address detected!
> printk: 153037 messages suppressed.
> eth3: duplicate address detected!
> printk: 151881 messages suppressed.
> eth3: duplicate address detected!
> printk: 153234 messages suppressed.
> eth3: duplicate address detected!
> printk: 154309 messages suppressed.
> eth3: duplicate address detected!
> printk: 152052 messages suppressed.
> eth3: duplicate address detected!
> printk: 152195 messages suppressed.
> eth3: duplicate address detected!
> printk: 154129 messages suppressed.
> eth3: duplicate address detected!
> printk: 153839 messages suppressed.
> eth3: duplicate address detected!
> printk: 151318 messages suppressed.
> eth3: duplicate address detected!
> printk: 151539 messages suppressed.
> eth3: duplicate address detected!
> printk: 152293 messages suppressed.
> eth3: duplicate address detected!
> printk: 153864 messages suppressed.
> eth3: duplicate address detected!
> printk: 153113 messages suppressed.
> eth3: duplicate address detected!
> printk: 154762 messages suppressed.
> eth3: duplicate address detected!
> printk: 153835 messages suppressed.
> eth3: duplicate address detected!
> printk: 154020 messages suppressed.
> eth3: duplicate address detected!
> printk: 152464 messages suppressed.
> eth3: duplicate address detected!
> printk: 155299 messages suppressed.
> eth3: duplicate address detected!
> printk: 153956 messages suppressed.
> eth3: duplicate address detected!
> printk: 152699 messages suppressed.
> eth3: duplicate address detected!
> printk: 151271 messages suppressed.
> eth3: duplicate address detected!
> printk: 154802 messages suppressed.
> eth3: duplicate address detected!
> printk: 152583 messages suppressed.
> eth3: duplicate address detected!
> printk: 151746 messages suppressed.
> eth3: duplicate address detected!
> printk: 152809 messages suppressed.
> eth3: duplicate address detected!
> printk: 151332 messages suppressed.
> eth3: duplicate address detected!
> printk: 151439 messages suppressed.
> eth3: duplicate address detected!
> printk: 152343 messages suppressed.
> eth3: duplicate address detected!
> printk: 151853 messages suppressed.
> eth3: duplicate address detected!
> printk: 152687 messages suppressed.
> eth3: duplicate address detected!
> printk: 150353 messages suppressed.
> eth3: duplicate address detected!
> printk: 153327 messages suppressed.
> eth3: duplicate address detected!
> printk: 153395 messages suppressed.
> eth3: duplicate address detected!
> printk: 151305 messages suppressed.
> eth3: duplicate address detected!
> printk: 152684 messages suppressed.
> eth3: duplicate address detected!
> printk: 152203 messages suppressed.
> eth3: duplicate address detected!
> printk: 152070 messages suppressed.
> eth3: duplicate address detected!
> printk: 149927 messages suppressed.
> eth3: duplicate address detected!
> printk: 151007 messages suppressed.
> eth3: duplicate address detected!
> printk: 151124 messages suppressed.
> eth3: duplicate address detected!
> printk: 151081 messages suppressed.
> eth3: duplicate address detected!
> printk: 151365 messages suppressed.
> eth3: duplicate address detected!
> printk: 151035 messages suppressed.
> eth3: duplicate address detected!
> printk: 152226 messages suppressed.
> eth3: duplicate address detected!
> printk: 152567 messages suppressed.
> eth3: duplicate address detected!
> printk: 153172 messages suppressed.
> eth3: duplicate address detected!
> printk: 151949 messages suppressed.
> eth3: duplicate address detected!
> printk: 151635 messages suppressed.
> eth3: duplicate address detected!
> printk: 151620 messages suppressed.
> eth3: duplicate address detected!
> printk: 150878 messages suppressed.
> eth3: duplicate address detected!
> printk: 150671 messages suppressed.
> eth3: duplicate address detected!
> printk: 151367 messages suppressed.
> eth3: duplicate address detected!
> printk: 151004 messages suppressed.
> eth3: duplicate address detected!
> printk: 151175 messages suppressed.
> eth3: duplicate address detected!
> printk: 151917 messages suppressed.
> eth3: duplicate address detected!
> printk: 151707 messages suppressed.
> eth3: duplicate address detected!
> printk: 152219 messages suppressed.
> eth3: duplicate address detected!
> printk: 151816 messages suppressed.
> eth3: duplicate address detected!
> printk: 150969 messages suppressed.
> eth3: duplicate address detected!
> printk: 152124 messages suppressed.
> eth3: duplicate address detected!
> printk: 152340 messages suppressed.
> eth3: duplicate address detected!
> printk: 151309 messages suppressed.
> eth3: duplicate address detected!
> printk: 150209 messages suppressed.
> eth3: duplicate address detected!
> printk: 149897 messages suppressed.
> eth3: duplicate address detected!
> printk: 151101 messages suppressed.
> eth3: duplicate address detected!
> printk: 151638 messages suppressed.
> eth3: duplicate address detected!
> printk: 151770 messages suppressed.
> eth3: duplicate address detected!
> printk: 152311 messages suppressed.
> eth3: duplicate address detected!
> printk: 151888 messages suppressed.
> eth3: duplicate address detected!
> printk: 151358 messages suppressed.
> eth3: duplicate address detected!
> printk: 152728 messages suppressed.
> eth3: duplicate address detected!
> printk: 151758 messages suppressed.
> eth3: duplicate address detected!
> printk: 151211 messages suppressed.
> eth3: duplicate address detected!
> printk: 151727 messages suppressed.
> eth3: duplicate address detected!
> printk: 151512 messages suppressed.
> eth3: duplicate address detected!
> printk: 150529 messages suppressed.
> eth3: duplicate address detected!
> printk: 148551 messages suppressed.
> eth3: duplicate address detected!
> printk: 149877 messages suppressed.
> eth3: duplicate address detected!
> printk: 150554 messages suppressed.
> eth3: duplicate address detected!
> printk: 149548 messages suppressed.
> eth3: duplicate address detected!
> printk: 149471 messages suppressed.
> eth3: duplicate address detected!
> printk: 149478 messages suppressed.
> eth3: duplicate address detected!
> printk: 150951 messages suppressed.
> eth3: duplicate address detected!
> printk: 151994 messages suppressed.
> eth3: duplicate address detected!
> printk: 150374 messages suppressed.
> eth3: duplicate address detected!
> printk: 151226 messages suppressed.
> eth3: duplicate address detected!
> printk: 149863 messages suppressed.
> eth3: duplicate address detected!
> printk: 150895 messages suppressed.
> eth3: duplicate address detected!
> printk: 150806 messages suppressed.
> eth3: duplicate address detected!
> printk: 150455 messages suppressed.
> eth3: duplicate address detected!
> printk: 150672 messages suppressed.
> eth3: duplicate address detected!
> printk: 152095 messages suppressed.
> eth3: duplicate address detected!
> printk: 151152 messages suppressed.
> eth3: duplicate address detected!
> printk: 152781 messages suppressed.
> eth3: duplicate address detected!
> printk: 150200 messages suppressed.
> eth3: duplicate address detected!
> printk: 151529 messages suppressed.
> eth3: duplicate address detected!
> printk: 151243 messages suppressed.
> eth3: duplicate address detected!
> printk: 152064 messages suppressed.
> eth3: duplicate address detected!
> printk: 150544 messages suppressed.
> eth3: duplicate address detected!
> printk: 151201 messages suppressed.
> eth3: duplicate address detected!
> printk: 151685 messages suppressed.
> eth3: duplicate address detected!
> printk: 148301 messages suppressed.
> eth3: duplicate address detected!
> printk: 150365 messages suppressed.
> eth3: duplicate address detected!
> printk: 151526 messages suppressed.
> eth3: duplicate address detected!
> printk: 152171 messages suppressed.
> eth3: duplicate address detected!
> printk: 150830 messages suppressed.
> eth3: duplicate address detected!
> printk: 150893 messages suppressed.
> eth3: duplicate address detected!
> printk: 149781 messages suppressed.
> eth3: duplicate address detected!
> printk: 151096 messages suppressed.
> eth3: duplicate address detected!
> printk: 150635 messages suppressed.
> eth3: duplicate address detected!
> printk: 149300 messages suppressed.
> eth3: duplicate address detected!
> printk: 149829 messages suppressed.
> eth3: duplicate address detected!
> printk: 150523 messages suppressed.
> eth3: duplicate address detected!
> printk: 150625 messages suppressed.
> eth3: duplicate address detected!
> printk: 151661 messages suppressed.
> eth3: duplicate address detected!
> printk: 152760 messages suppressed.
> eth3: duplicate address detected!
> printk: 150583 messages suppressed.
> eth3: duplicate address detected!
> printk: 150265 messages suppressed.
> eth3: duplicate address detected!
> printk: 151724 messages suppressed.
> eth3: duplicate address detected!
> printk: 150202 messages suppressed.
> eth3: duplicate address detected!
> printk: 150045 messages suppressed.
> eth3: duplicate address detected!
> printk: 150659 messages suppressed.
> eth3: duplicate address detected!
> printk: 151509 messages suppressed.
> eth3: duplicate address detected!
> printk: 150662 messages suppressed.
> eth3: duplicate address detected!
> printk: 150833 messages suppressed.
> eth3: duplicate address detected!
> printk: 151967 messages suppressed.
> eth3: duplicate address detected!
> printk: 152064 messages suppressed.
> eth3: duplicate address detected!
> printk: 151106 messages suppressed.
> eth3: duplicate address detected!
> printk: 150963 messages suppressed.
> eth3: duplicate address detected!
> printk: 151160 messages suppressed.
> eth3: duplicate address detected!
> printk: 151594 messages suppressed.
> eth3: duplicate address detected!
> printk: 150488 messages suppressed.
> eth3: duplicate address detected!
> printk: 149407 messages suppressed.
> eth3: duplicate address detected!
> printk: 148721 messages suppressed.
> eth3: duplicate address detected!
> printk: 150152 messages suppressed.
> eth3: duplicate address detected!
> printk: 151699 messages suppressed.
> eth3: duplicate address detected!
> printk: 152220 messages suppressed.
> eth3: duplicate address detected!
> printk: 151513 messages suppressed.
> eth3: duplicate address detected!
> printk: 151885 messages suppressed.
> eth3: duplicate address detected!
> printk: 152890 messages suppressed.
> eth3: duplicate address detected!
> printk: 151378 messages suppressed.
> eth3: duplicate address detected!
> printk: 150550 messages suppressed.
> eth3: duplicate address detected!
> printk: 149394 messages suppressed.
> eth3: duplicate address detected!
> printk: 150543 messages suppressed.
> eth3: duplicate address detected!
> printk: 150266 messages suppressed.
> eth3: duplicate address detected!
> printk: 150841 messages suppressed.
> eth3: duplicate address detected!
> printk: 151952 messages suppressed.
> eth3: duplicate address detected!
> printk: 152890 messages suppressed.
> eth3: duplicate address detected!
> printk: 152893 messages suppressed.
> eth3: duplicate address detected!
> printk: 151992 messages suppressed.
> eth3: duplicate address detected!
> printk: 151985 messages suppressed.
> eth3: duplicate address detected!
> printk: 151927 messages suppressed.
> eth3: duplicate address detected!
> printk: 152072 messages suppressed.
> eth3: duplicate address detected!
> printk: 150888 messages suppressed.
> eth3: duplicate address detected!
> printk: 152096 messages suppressed.
> eth3: duplicate address detected!
> printk: 152351 messages suppressed.
> eth3: duplicate address detected!
> printk: 151376 messages suppressed.
> eth3: duplicate address detected!
> printk: 150869 messages suppressed.
> eth3: duplicate address detected!
> printk: 152732 messages suppressed.
> eth3: duplicate address detected!
> printk: 152557 messages suppressed.
> eth3: duplicate address detected!
> printk: 150647 messages suppressed.
> eth3: duplicate address detected!
> printk: 150487 messages suppressed.
> eth3: duplicate address detected!
> printk: 150856 messages suppressed.
> eth3: duplicate address detected!
> printk: 150351 messages suppressed.
> eth3: duplicate address detected!
> printk: 152653 messages suppressed.
> eth3: duplicate address detected!
> printk: 153239 messages suppressed.
> eth3: duplicate address detected!
> printk: 153418 messages suppressed.
> eth3: duplicate address detected!
> printk: 151757 messages suppressed.
> eth3: duplicate address detected!
> printk: 150756 messages suppressed.
> eth3: duplicate address detected!
> printk: 152272 messages suppressed.
> eth3: duplicate address detected!
> printk: 152235 messages suppressed.
> eth3: duplicate address detected!
> printk: 155393 messages suppressed.
> eth3: duplicate address detected!
> printk: 156246 messages suppressed.
> eth3: duplicate address detected!
> printk: 153521 messages suppressed.
> eth3: duplicate address detected!
> printk: 151638 messages suppressed.
> eth3: duplicate address detected!
> printk: 152140 messages suppressed.
> eth3: duplicate address detected!
> printk: 152116 messages suppressed.
> eth3: duplicate address detected!
> printk: 152273 messages suppressed.
> eth3: duplicate address detected!
> printk: 150572 messages suppressed.
> eth3: duplicate address detected!
> printk: 151597 messages suppressed.
> eth3: duplicate address detected!
> printk: 152251 messages suppressed.
> eth3: duplicate address detected!
> printk: 151083 messages suppressed.
> eth3: duplicate address detected!
> printk: 152997 messages suppressed.
> eth3: duplicate address detected!
> printk: 151184 messages suppressed.
> eth3: duplicate address detected!
> printk: 152284 messages suppressed.
> eth3: duplicate address detected!
> printk: 152478 messages suppressed.
> eth3: duplicate address detected!
> printk: 151370 messages suppressed.
> eth3: duplicate address detected!
> printk: 150483 messages suppressed.
> eth3: duplicate address detected!
> printk: 152024 messages suppressed.
> eth3: duplicate address detected!
> printk: 153379 messages suppressed.
> eth3: duplicate address detected!
> printk: 153670 messages suppressed.
> eth3: duplicate address detected!
> printk: 150457 messages suppressed.
> eth3: duplicate address detected!
> printk: 151745 messages suppressed.
> eth3: duplicate address detected!
> printk: 153526 messages suppressed.
> eth3: duplicate address detected!
> printk: 151960 messages suppressed.
> eth3: duplicate address detected!
> printk: 151864 messages suppressed.
> eth3: duplicate address detected!
> printk: 151216 messages suppressed.
> eth3: duplicate address detected!
> printk: 151486 messages suppressed.
> eth3: duplicate address detected!
> printk: 151104 messages suppressed.
> eth3: duplicate address detected!
> printk: 150749 messages suppressed.
> eth3: duplicate address detected!
> printk: 151486 messages suppressed.
> eth3: duplicate address detected!
> printk: 150413 messages suppressed.
> eth3: duplicate address detected!
> printk: 151162 messages suppressed.
> eth3: duplicate address detected!
> printk: 151386 messages suppressed.
> eth3: duplicate address detected!
> printk: 150490 messages suppressed.
> eth3: duplicate address detected!
> printk: 150667 messages suppressed.
> eth3: duplicate address detected!
> printk: 151895 messages suppressed.
> eth3: duplicate address detected!
> printk: 152263 messages suppressed.
> eth3: duplicate address detected!
> printk: 151791 messages suppressed.
> eth3: duplicate address detected!
> printk: 151339 messages suppressed.
> eth3: duplicate address detected!
> printk: 150663 messages suppressed.
> eth3: duplicate address detected!
> printk: 152217 messages suppressed.
> eth3: duplicate address detected!
> printk: 152434 messages suppressed.
> eth3: duplicate address detected!
> printk: 151680 messages suppressed.
> eth3: duplicate address detected!
> printk: 151350 messages suppressed.
> eth3: duplicate address detected!
> printk: 151440 messages suppressed.
> eth3: duplicate address detected!
> printk: 152322 messages suppressed.
> eth3: duplicate address detected!
> printk: 151489 messages suppressed.
> eth3: duplicate address detected!
> printk: 151521 messages suppressed.
> eth3: duplicate address detected!
> printk: 152547 messages suppressed.
> eth3: duplicate address detected!
> printk: 151261 messages suppressed.
> eth3: duplicate address detected!
> printk: 151180 messages suppressed.
> eth3: duplicate address detected!
> printk: 151700 messages suppressed.
> eth3: duplicate address detected!
> printk: 152020 messages suppressed.
> eth3: duplicate address detected!
> printk: 151494 messages suppressed.
> eth3: duplicate address detected!
> printk: 151121 messages suppressed.
> eth3: duplicate address detected!
> printk: 152912 messages suppressed.
> eth3: duplicate address detected!
> printk: 152057 messages suppressed.
> eth3: duplicate address detected!
> printk: 152870 messages suppressed.
> eth3: duplicate address detected!
> printk: 151300 messages suppressed.
> eth3: duplicate address detected!
> printk: 152172 messages suppressed.
> eth3: duplicate address detected!
> printk: 152307 messages suppressed.
> eth3: duplicate address detected!
> printk: 151479 messages suppressed.
> eth3: duplicate address detected!
> printk: 152745 messages suppressed.
> eth3: duplicate address detected!
> printk: 153635 messages suppressed.
> eth3: duplicate address detected!
> printk: 153428 messages suppressed.
> eth3: duplicate address detected!
> printk: 151752 messages suppressed.
> eth3: duplicate address detected!
> printk: 151759 messages suppressed.
> eth3: duplicate address detected!
> printk: 153805 messages suppressed.
> eth3: duplicate address detected!
> printk: 151862 messages suppressed.
> eth3: duplicate address detected!
> printk: 155377 messages suppressed.
> eth3: duplicate address detected!
> printk: 152353 messages suppressed.
> eth3: duplicate address detected!
> printk: 152208 messages suppressed.
> eth3: duplicate address detected!
> printk: 153228 messages suppressed.
> eth3: duplicate address detected!
> printk: 151887 messages suppressed.
> eth3: duplicate address detected!
> printk: 152904 messages suppressed.
> eth3: duplicate address detected!
> printk: 153785 messages suppressed.
> eth3: duplicate address detected!
> printk: 152293 messages suppressed.
> eth3: duplicate address detected!
> printk: 151804 messages suppressed.
> eth3: duplicate address detected!
> printk: 151619 messages suppressed.
> eth3: duplicate address detected!
> pptpctrl[7059]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffda3f00 error 4
> pptpctrl[7185]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffc57db0 error 4
> pptpctrl[7307]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffc10d70 error 4
> pptpctrl[7431]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffd446a0 error 4
> pptpctrl[7561]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ff9689c0 error 4
> pptpctrl[7694]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffb20f20 error 4
> pptpctrl[7761]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffe6f7d0 error 4
> pptpctrl[7817]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ff8cda30 error 4
> pptpctrl[7538]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffa75bd0 error 4
> pptpctrl[7032]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000fff458a0 error 4
> pptpctrl[7818]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ff9f9350 error 4
> pptpctrl[7834]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffaf4450 error 4
> pptpctrl[7945]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffefd860 error 4
> pptpctrl[7432]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000fff928f0 error 4
> pptpctrl[7562]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ff85e1c0 error 4
> pptpctrl[7615]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ff9ee350 error 4
> pptpctrl[7689]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ff8e7670 error 4
> pptpctrl[7693]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000fff8a8e0 error 4
> pptpctrl[7178]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffd36690 error 4
> pptpctrl[7249]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffb15470 error 4
> pptpctrl[7321]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffafc460 error 4
> pptpctrl[7391]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffb33c90 error 4
> pptpctrl[7433]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffaa7c00 error 4
> pptpctrl[7464]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffb0c470 error 4
> pptpctrl[7308]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffa2e970 error 4
> pptpctrl[7106]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffb33c90 error 4
> pptpctrl[7907]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffcbc620 error 4
> tg3: eth3: Link is down.
> pptpctrl[7603]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffdb1f10 error 4
> pptpctrl[7771]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ff8861e0 error 4
> tg3: eth3: Link is up at 1000 Mbps, full duplex.
> tg3: eth3: Flow control is off for TX and off for RX.
> tg3: eth3: Link is down.
> tg3: eth3: Link is up at 1000 Mbps, full duplex.
> tg3: eth3: Flow control is on for TX and on for RX.
> pptpctrl[11100]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000ffc8bdf0 error 4
> pptpctrl[11365]: segfault at 0000000000001030 rip 00000000080493aa rsp 00000000fff23080 error 4
>   
