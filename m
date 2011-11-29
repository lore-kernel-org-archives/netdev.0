From: booster@wolke7.net
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Tue, 29 Nov 2011 20:56:28 +0100
Message-ID: <4ED538EC.4010509@wolke7.net>
References: <20111125201936.GA26692@elie.hsd1.il.comcast.net> <1322253122.2550.3.camel@edumazet-laptop> <20111125222211.GA13719@electric-eye.fr.zoreil.com> <1322262357.2550.12.camel@edumazet-laptop> <20111126004447.GA14744@electric-eye.fr.zoreil.com> <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com> <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw> <20111129105440.GA2410@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060808080200040305020206"
Cc: hayeswang <hayeswang@realtek.com>,
	'Jonathan Nieder' <jrnieder@gmail.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, 'nic_swsd' <nic_swsd@realtek.com>,
	linux-kernel@vger.kernel.org,
	'Armin Kazmi' <armin.kazmi@tu-dortmund.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:37672 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754477Ab1K2T4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 14:56:39 -0500
In-Reply-To: <20111129105440.GA2410@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060808080200040305020206
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Francois Romieu wrote:
> hayeswang <hayeswang@realtek.com> :
> [...]
>   
>> For the 8168c and the later chips, our hardware engineer says that don't enable
>> the RxFIFOOver of IntrMask and don't clear the RxFIFOOver of IntrStatus. The
>> hardware will automatically escape Rx fifo full situation. Although you try to
>> clear the RxFIFOOver of IntrStatus, maybe the bit wouldn't be cleared. Just
>> disregard it.
>>     
>
> Should "later" be understood as gigabit PCI-E only or is there a similar
> difference of behavior between older fast-ethernet PCI-E and more recent
> ones ?
>
> Gerd, can you try the patch below ? It should match Haye's description.
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 6f06aa1..97b5593 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4885,8 +4885,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
>  	RTL_W16(IntrMitigate, 0x5151);
>  
>  	/* Work around for RxFIFO overflow. */
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_22) {
> +	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
>  		tp->intr_event |= RxFIFOOver | PCSTimeout;
>  		tp->intr_event &= ~RxOverflow;
>  	}
> @@ -5804,6 +5803,10 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  	 */
>  	status = RTL_R16(IntrStatus);
>  	while (status && status != 0xffff) {
> +		status &= ~tp->intr_event;
> +		if (!status)
> +			break;
> +
>  		handled = 1;
>  
>  		/* Handle all of the error cases first. These will reset
> @@ -5818,7 +5821,6 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  			switch (tp->mac_version) {
>  			/* Work around for rx fifo overflow */
>  			case RTL_GIGA_MAC_VER_11:
> -			case RTL_GIGA_MAC_VER_22:
>  			case RTL_GIGA_MAC_VER_26:
>  				netif_stop_queue(dev);
>  				rtl8169_tx_timeout(dev);
> @@ -5828,6 +5830,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  			case RTL_GIGA_MAC_VER_19:
>  			case RTL_GIGA_MAC_VER_20:
>  			case RTL_GIGA_MAC_VER_21:
> +			case RTL_GIGA_MAC_VER_22:
>  			case RTL_GIGA_MAC_VER_23:
>  			case RTL_GIGA_MAC_VER_24:
>  			case RTL_GIGA_MAC_VER_27:
>
>   
Hi Francois, now an ifconfig shows the eth0 interface is up, but no data
is transfered
and a ping is not working.
[   14.522369] r8169 0000:02:00.0: eth0: link down
[   14.522773] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   14.671742] r8169 0000:03:00.0: eth1: link down
[   14.672169] ADDRCONF(NETDEV_UP): eth1: link is not ready
An added output shows that it is really detected as RTL_GIGA_MAC_VER_22.

Any more ideas ?


--------------060808080200040305020206
Content-Type: text/plain;
 name="dmesg_20111129_kernel_3.2_r8169-patch2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dmesg_20111129_kernel_3.2_r8169-patch2.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0-rc3+ (root@pokini) (gcc version 4.4.5 (Debian 4.4.5-8) ) #4 SMP Tue Nov 29 19:49:50 CET 2011
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 0000000000090000 (usable)
[    0.000000]  BIOS-e820: 0000000000090000 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000d2000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007f6b0000 (usable)
[    0.000000]  BIOS-e820: 000000007f6b0000 - 000000007f6bc000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007f6bc000 - 000000007f6bf000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007f6bf000 - 0000000080000000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed00000 - 00000000fed00400 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ffb80000 - 0000000100000000 (reserved)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI present.
[    0.000000] DMI: CompuLab CM-iAM/SBC-FITPC2i/CM-iAM/SBC-FITPC2i, BIOS NAPA0001.86C.0000.D.1009141059 09/14/2010
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] last_pfn = 0x7f6b0 max_arch_pfn = 0x1000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-DFFFF uncachable
[    0.000000]   E0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask 080000000 write-back
[    0.000000]   1 base 07F700000 mask 0FFF00000 uncachable
[    0.000000]   2 base 07F800000 mask 0FF800000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] found SMP MP-table at [c00f8600] f8600
[    0.000000] initial memory mapped : 0 - 01a00000
[    0.000000] Base memory trampoline at [c008c000] 8c000 size 16384
[    0.000000] init_memory_mapping: 0000000000000000-00000000379fe000
[    0.000000]  0000000000 - 0000200000 page 4k
[    0.000000]  0000200000 - 0037800000 page 2M
[    0.000000]  0037800000 - 00379fe000 page 4k
[    0.000000] kernel direct mapping tables up to 379fe000 @ 19fa000-1a00000
[    0.000000] RAMDISK: 36355000 - 37ff0000
[    0.000000] Allocated new RAMDISK: 346ba000 - 36354835
[    0.000000] Move RAMDISK from 0000000036355000 - 0000000037fef834 to 346ba000 - 36354834
[    0.000000] ACPI: RSDP 000f85d0 00024 (v02 PTLTD )
[    0.000000] ACPI: XSDT 7f6b70db 00064 (v01 PTLTD  ? XSDT   06040000  LTP 00000000)
[    0.000000] ACPI: FACP 7f6bbdb0 000F4 (v03 INTEL  POULSBO  06040000 INTC 00000032)
[    0.000000] ACPI: DSDT 7f6b803a 03CF2 (v01 INTEL   POULSBO 06040000 INTL 20050624)
[    0.000000] ACPI: FACS 7f6befc0 00040
[    0.000000] ACPI: HPET 7f6bbea4 00038 (v01 INTEL  POULSBO  06040000 INTC 00000032)
[    0.000000] ACPI: MCFG 7f6bbedc 0003C (v01 INTEL  POULSBO  06040000 INTC 00000032)
[    0.000000] ACPI: TCPA 7f6bbf18 00032 (v01 PTLTD  CALISTGA 06040000  PTL 00000001)
[    0.000000] ACPI: TMOR 7f6bbf4a 00026 (v01 PTLTD           06040000 PTL  00000003)
[    0.000000] ACPI: APIC 7f6bbf70 00068 (v01 PTLTD  ? APIC   06040000  LTP 00000000)
[    0.000000] ACPI: BOOT 7f6bbfd8 00028 (v01 PTLTD  $SBFTBL$ 06040000  LTP 00000001)
[    0.000000] ACPI: SSDT 7f6b713f 004DC (v02  PmRef    CpuPm 00003000 INTL 20050624)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 1148MB HIGHMEM available.
[    0.000000] 889MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 379fe000
[    0.000000]   low ram: 0 - 379fe000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000379fe
[    0.000000]   HighMem  0x000379fe -> 0x0007f6b0
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x00000090
[    0.000000]     0: 0x00000100 -> 0x0007f6b0
[    0.000000] On node 0 totalpages: 521776
[    0.000000] free_area_init_node: node 0, pgdat c13fd980, node_mem_map f6a0d200
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3936 pages, LIFO batch:0
[    0.000000]   Normal zone: 1748 pages used for memmap
[    0.000000]   Normal zone: 221994 pages, LIFO batch:31
[    0.000000]   HighMem zone: 2298 pages used for memmap
[    0.000000]   HighMem zone: 291768 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 0000000000090000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000d2000
[    0.000000] PM: Registered nosave memory: 00000000000d2000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 80000000:60000000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 14 pages/cpu @f6800000 s33088 r0 d24256 u1048576
[    0.000000] pcpu-alloc: s33088 r0 d24256 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 517698
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.2.0-rc3+ root=UUID=c8369b5c-f8fa-42d3-a640-ed1feff58e85 ro quiet
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] allocated 8350208 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] Initializing HighMem for node 0 (000379fe:0007f6b0)
[    0.000000] Memory: 2027204k/2087616k available (2852k kernel code, 59900k reserved, 1263k data, 432k init, 1176264k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffd36000 - 0xfffff000   (2852 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0xf81fe000 - 0xff9fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf79fe000   ( 889 MB)
[    0.000000]       .init : 0xc1406000 - 0xc1472000   ( 432 kB)
[    0.000000]       .data : 0xc12c92ed - 0xc1405200   (1263 kB)
[    0.000000]       .text : 0xc1000000 - 0xc12c92ed   (2852 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=f6406000 soft=f6408000
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1994.944 MHz processor.
[    0.004004] Calibrating delay loop (skipped), value calculated using timer frequency.. 3989.88 BogoMIPS (lpj=7979776)
[    0.004012] pid_max: default: 32768 minimum: 301
[    0.004090] Security Framework initialized
[    0.004123] Mount-cache hash table entries: 512
[    0.004324] Initializing cgroup subsys cpuacct
[    0.004334] Initializing cgroup subsys memory
[    0.004348] Initializing cgroup subsys devices
[    0.004353] Initializing cgroup subsys freezer
[    0.004357] Initializing cgroup subsys net_cls
[    0.004362] Initializing cgroup subsys blkio
[    0.004412] CPU: Physical Processor ID: 0
[    0.004416] CPU: Processor Core ID: 0
[    0.004420] mce: CPU supports 5 MCE banks
[    0.004432] CPU0: Thermal monitoring enabled (TM1)
[    0.004439] using mwait in idle threads.
[    0.005498] ACPI: Core revision 20110623
[    0.012104] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.012468] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.054637] CPU0: Intel(R) Atom(TM) CPU Z550   @ 2.00GHz stepping 02
[    0.056003] Performance Events: PEBS fmt0+, Atom events, Intel PMU driver.
[    0.056003] ... version:                3
[    0.056003] ... bit width:              40
[    0.056003] ... generic registers:      2
[    0.056003] ... value mask:             000000ffffffffff
[    0.056003] ... max period:             000000007fffffff
[    0.056003] ... fixed-purpose events:   3
[    0.056003] ... event mask:             0000000700000003
[    0.056003] NMI watchdog enabled, takes one hw-pmu counter.
[    0.056003] CPU 1 irqstacks, hard=f64b4000 soft=f64b6000
[    0.056003] Booting Node   0, Processors  #1 Ok.
[    0.056003] smpboot cpu 1: start_ip = 8c000
[    0.008000] Initializing CPU#1
[    0.144064] NMI watchdog enabled, takes one hw-pmu counter.
[    0.144129] Brought up 2 CPUs
[    0.144135] Total of 2 processors activated (7979.80 BogoMIPS).
[    0.144603] devtmpfs: initialized
[    0.144603] PM: Registering ACPI NVS region at 7f6bc000 (12288 bytes)
[    0.144603] CompuLab SBC-FITPC2 series board detected. Selecting BIOS-method for reboots.
[    0.144603] print_constraints: dummy: 
[    0.144603] NET: Registered protocol family 16
[    0.144665] ACPI: bus type pci registered
[    0.144801] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.144808] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    0.144811] PCI: Using MMCONFIG for extended config space
[    0.144815] PCI: Using configuration type 1 for base access
[    0.145655] bio: create slab <bio-0> at 0
[    0.145655] ACPI: Added _OSI(Module Device)
[    0.145655] ACPI: Added _OSI(Processor Device)
[    0.145655] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.145655] ACPI: Added _OSI(Processor Aggregator Device)
[    0.148348] ACPI: EC: Look up EC in DSDT
[    0.150627] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.151245] ACPI: SSDT 7f6b7cdf 00287 (v02  PmRef  Cpu0Ist 00003000 INTL 20050624)
[    0.151548] ACPI: Dynamic OEM Table Load:
[    0.151554] ACPI: SSDT   (null) 00287 (v02  PmRef  Cpu0Ist 00003000 INTL 20050624)
[    0.151846] ACPI: SSDT 7f6b761b 0063F (v02  PmRef  Cpu0Cst 00003001 INTL 20050624)
[    0.152130] ACPI: Dynamic OEM Table Load:
[    0.152136] ACPI: SSDT   (null) 0063F (v02  PmRef  Cpu0Cst 00003001 INTL 20050624)
[    0.152577] ACPI: SSDT 7f6b7f66 000D4 (v02  PmRef  Cpu1Ist 00003000 INTL 20050624)
[    0.152862] ACPI: Dynamic OEM Table Load:
[    0.152868] ACPI: SSDT   (null) 000D4 (v02  PmRef  Cpu1Ist 00003000 INTL 20050624)
[    0.153037] ACPI: SSDT 7f6b7c5a 00085 (v02  PmRef  Cpu1Cst 00003000 INTL 20050624)
[    0.153306] ACPI: Dynamic OEM Table Load:
[    0.153311] ACPI: SSDT   (null) 00085 (v02  PmRef  Cpu1Cst 00003000 INTL 20050624)
[    0.352171] ACPI: Interpreter enabled
[    0.352196] ACPI: (supports S0 S3 S4 S5)
[    0.352277] ACPI: Using IOAPIC for interrupt routing
[    0.353561] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.360002] ACPI: EC: GPE = 0xd, I/O: command/status = 0x66, data = 0x62
[    0.360252] ACPI: No dock devices found.
[    0.360257] HEST: Table not found.
[    0.360266] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.360419] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.360715] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.360722] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.360727] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.360733] pci_root PNP0A08:00: host bridge window [mem 0x000c0000-0x000dffff]
[    0.360738] pci_root PNP0A08:00: host bridge window [mem 0x000e0000-0x000effff]
[    0.360743] pci_root PNP0A08:00: host bridge window [mem 0x000f0000-0x000fffff]
[    0.360749] pci_root PNP0A08:00: host bridge window [mem 0x7f800000-0xfebfffff]
[    0.360761] pci_root PNP0A08:00: ignoring host bridge window [mem 0x000c0000-0x000dffff] (conflicts with reserved [mem 0x000d2000-0x000fffff])
[    0.360783] pci 0000:00:00.0: [8086:8100] type 0 class 0x000600
[    0.360863] pci 0000:00:02.0: [8086:8108] type 0 class 0x000300
[    0.360885] pci 0000:00:02.0: reg 10: [mem 0xd8080000-0xd80fffff]
[    0.360898] pci 0000:00:02.0: reg 14: [io  0x1800-0x1807]
[    0.360910] pci 0000:00:02.0: reg 18: [mem 0xd0000000-0xd7ffffff]
[    0.360922] pci 0000:00:02.0: reg 1c: [mem 0xd8020000-0xd803ffff]
[    0.361020] pci 0000:00:1b.0: [8086:811b] type 0 class 0x000403
[    0.361039] pci 0000:00:1b.0: reg 10: [mem 0xd8010000-0xd8013fff 64bit]
[    0.361098] pci 0000:00:1b.0: PME# supported from D0 D3hot
[    0.361105] pci 0000:00:1b.0: PME# disabled
[    0.361132] pci 0000:00:1c.0: [8086:8110] type 1 class 0x000604
[    0.361189] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.361195] pci 0000:00:1c.0: PME# disabled
[    0.361225] pci 0000:00:1c.1: [8086:8112] type 1 class 0x000604
[    0.361282] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.361288] pci 0000:00:1c.1: PME# disabled
[    0.361319] pci 0000:00:1d.0: [8086:8114] type 0 class 0x000c03
[    0.361359] pci 0000:00:1d.0: reg 20: [io  0x1820-0x183f]
[    0.361394] pci 0000:00:1d.1: [8086:8115] type 0 class 0x000c03
[    0.361434] pci 0000:00:1d.1: reg 20: [io  0x1840-0x185f]
[    0.361471] pci 0000:00:1d.2: [8086:8116] type 0 class 0x000c03
[    0.361512] pci 0000:00:1d.2: reg 20: [io  0x1860-0x187f]
[    0.361562] pci 0000:00:1d.7: [8086:8117] type 0 class 0x000c03
[    0.361591] pci 0000:00:1d.7: reg 10: [mem 0xd8014000-0xd80143ff]
[    0.361692] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.361700] pci 0000:00:1d.7: PME# disabled
[    0.361725] pci 0000:00:1e.0: [8086:811c] type 0 class 0x000805
[    0.361741] pci 0000:00:1e.0: reg 10: [mem 0xd8014400-0xd80144ff]
[    0.361805] pci 0000:00:1e.1: [8086:811d] type 0 class 0x000805
[    0.361821] pci 0000:00:1e.1: reg 10: [mem 0xd8014800-0xd80148ff]
[    0.361886] pci 0000:00:1e.2: [8086:811e] type 0 class 0x000805
[    0.361902] pci 0000:00:1e.2: reg 10: [mem 0xd8014c00-0xd8014cff]
[    0.361973] pci 0000:00:1f.0: [8086:8119] type 0 class 0x000601
[    0.362047] pci 0000:00:1f.1: [8086:811a] type 0 class 0x000101
[    0.362090] pci 0000:00:1f.1: reg 20: [io  0x1810-0x181f]
[    0.362186] pci 0000:02:00.0: [10ec:8168] type 0 class 0x000200
[    0.362208] pci 0000:02:00.0: reg 10: [io  0x2000-0x20ff]
[    0.362242] pci 0000:02:00.0: reg 18: [mem 0xd8100000-0xd8100fff 64bit]
[    0.362265] pci 0000:02:00.0: reg 20: [mem 0xd8500000-0xd850ffff 64bit pref]
[    0.362282] pci 0000:02:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.362327] pci 0000:02:00.0: supports D1 D2
[    0.362332] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.362340] pci 0000:02:00.0: PME# disabled
[    0.368069] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.368086] pci 0000:00:1c.0:   bridge window [io  0x2000-0x2fff]
[    0.368113] pci 0000:00:1c.0:   bridge window [mem 0xd8100000-0xd81fffff]
[    0.368129] pci 0000:00:1c.0:   bridge window [mem 0xd8500000-0xd85fffff pref]
[    0.368249] pci 0000:03:00.0: [10ec:8168] type 0 class 0x000200
[    0.368286] pci 0000:03:00.0: reg 10: [io  0x3000-0x30ff]
[    0.368342] pci 0000:03:00.0: reg 18: [mem 0xd8200000-0xd8200fff 64bit]
[    0.368365] pci 0000:03:00.0: reg 20: [mem 0xd8600000-0xd860ffff 64bit pref]
[    0.368382] pci 0000:03:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    0.368429] pci 0000:03:00.0: supports D1 D2
[    0.368433] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.368441] pci 0000:03:00.0: PME# disabled
[    0.376065] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    0.376081] pci 0000:00:1c.1:   bridge window [io  0x3000-0x3fff]
[    0.376097] pci 0000:00:1c.1:   bridge window [mem 0xd8200000-0xd82fffff]
[    0.376113] pci 0000:00:1c.1:   bridge window [mem 0xd8600000-0xd86fffff pref]
[    0.376142] pci_bus 0000:00: on NUMA node 0
[    0.376162] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.376480] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
[    0.376574] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
[    0.376727]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    0.376734]  pci0000:00: ACPI _OSC request failed (AE_NOT_FOUND), returned control mask: 0x1d
[    0.376738] ACPI _OSC control for PCIe not granted, disabling ASPM
[    0.382772] ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 *7 10 12 14 15)
[    0.382876] ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 *4 5 6 7 11 12 14 15)
[    0.382976] ACPI: PCI Interrupt Link [LNKC] (IRQs 1 *3 4 5 6 7 10 12 14 15)
[    0.383075] ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 *5 6 7 11 12 14 15)
[    0.383174] ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.383276] ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 7 *11 12 14 15)
[    0.383375] ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 7 *10 12 14 15)
[    0.383475] ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 7 11 12 14 15) *10
[    0.383689] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.383689] vgaarb: loaded
[    0.383689] vgaarb: bridge control possible 0000:00:02.0
[    0.383689] PCI: Using ACPI for IRQ routing
[    0.391026] PCI: pci_cache_line_size set to 64 bytes
[    0.391112] Expanded resource reserved due to conflict with PCI Bus 0000:00
[    0.391118] reserve RAM buffer: 000000007f6b0000 - 000000007fffffff 
[    0.391349] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.391358] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.391367] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.396192] Switching to clocksource hpet
[    0.399102] pnp: PnP ACPI init
[    0.399149] ACPI: bus type pnp registered
[    0.399445] pnp 00:00: [bus 00-ff]
[    0.399451] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.399457] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.399461] pnp 00:00: [io  0x0d00-0xffff window]
[    0.399467] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.399472] pnp 00:00: [mem 0x000c0000-0x000dffff window]
[    0.399477] pnp 00:00: [mem 0x000e0000-0x000effff window]
[    0.399482] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    0.399487] pnp 00:00: [mem 0x7f800000-0xfebfffff window]
[    0.399492] pnp 00:00: [mem 0xfed40000-0xfed44fff window]
[    0.399608] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    0.399684] pnp 00:01: [mem 0xfd000000-0xfd003fff]
[    0.399690] pnp 00:01: [mem 0xe0000000-0xefffffff]
[    0.399695] pnp 00:01: [mem 0xfed00000-0xfed3ffff]
[    0.399700] pnp 00:01: [mem 0xfed40000-0xfed44fff]
[    0.399704] pnp 00:01: [mem 0xfed45000-0xfed4bfff]
[    0.399804] system 00:01: [mem 0xfd000000-0xfd003fff] has been reserved
[    0.399811] system 00:01: [mem 0xe0000000-0xefffffff] has been reserved
[    0.399817] system 00:01: [mem 0xfed00000-0xfed3ffff] could not be reserved
[    0.399823] system 00:01: [mem 0xfed40000-0xfed44fff] has been reserved
[    0.399830] system 00:01: [mem 0xfed45000-0xfed4bfff] has been reserved
[    0.399838] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.400184] pnp 00:02: [io  0x0000-0x001f]
[    0.400189] pnp 00:02: [io  0x0081-0x0091]
[    0.400194] pnp 00:02: [io  0x0093-0x009f]
[    0.400198] pnp 00:02: [io  0x00c0-0x00df]
[    0.400203] pnp 00:02: [dma 4]
[    0.400276] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.400297] pnp 00:03: [mem 0xff000000-0xffffffff]
[    0.400366] pnp 00:03: Plug and Play ACPI device, IDs INT0800 (active)
[    0.400431] pnp 00:04: [irq 0 disabled]
[    0.400453] pnp 00:04: [irq 8]
[    0.400458] pnp 00:04: [mem 0xfed00000-0xfed003ff]
[    0.400528] pnp 00:04: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.400557] pnp 00:05: [io  0x00f0]
[    0.400567] pnp 00:05: [irq 13]
[    0.400636] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.400662] pnp 00:06: [io  0x002e-0x002f]
[    0.400667] pnp 00:06: [io  0x004e-0x004f]
[    0.400671] pnp 00:06: [io  0x0061]
[    0.400675] pnp 00:06: [io  0x0063]
[    0.400680] pnp 00:06: [io  0x0065]
[    0.400684] pnp 00:06: [io  0x0067]
[    0.400691] pnp 00:06: [io  0x0070]
[    0.400695] pnp 00:06: [io  0x0080]
[    0.400699] pnp 00:06: [io  0x0092]
[    0.400703] pnp 00:06: [io  0x00b2-0x00b3]
[    0.400708] pnp 00:06: [io  0x0295-0x0296]
[    0.400712] pnp 00:06: [io  0x0680-0x069f]
[    0.400717] pnp 00:06: [io  0x8080]
[    0.400721] pnp 00:06: [io  0x1000-0x107f]
[    0.400726] pnp 00:06: [io  0x1180-0x11bf]
[    0.400730] pnp 00:06: [io  0x1640-0x164f]
[    0.400843] system 00:06: [io  0x0295-0x0296] has been reserved
[    0.400849] system 00:06: [io  0x0680-0x069f] has been reserved
[    0.400855] system 00:06: [io  0x8080] has been reserved
[    0.400861] system 00:06: [io  0x1000-0x107f] has been reserved
[    0.400867] system 00:06: [io  0x1180-0x11bf] has been reserved
[    0.400872] system 00:06: [io  0x1640-0x164f] has been reserved
[    0.400879] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.400930] pnp 00:07: [io  0x0070-0x0073]
[    0.401000] pnp 00:07: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.401167] pnp 00:08: [io  0x002e-0x002f]
[    0.401173] pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
[    0.401273] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.401742] pnp 00:09: [io  0x03f8-0x03ff]
[    0.401754] pnp 00:09: [irq 4]
[    0.402071] pnp 00:09: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.402097] pnp: PnP ACPI: found 10 devices
[    0.402101] ACPI: ACPI bus type pnp unregistered
[    0.402108] PnPBIOS: Disabled by ACPI PNP
[    0.441970] PCI: max bus depth: 1 pci_try_num: 2
[    0.442004] pci 0000:02:00.0: BAR 6: assigned [mem 0xd8520000-0xd853ffff pref]
[    0.442010] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.442016] pci 0000:00:1c.0:   bridge window [io  0x2000-0x2fff]
[    0.442025] pci 0000:00:1c.0:   bridge window [mem 0xd8100000-0xd81fffff]
[    0.442032] pci 0000:00:1c.0:   bridge window [mem 0xd8500000-0xd85fffff pref]
[    0.442044] pci 0000:03:00.0: BAR 6: assigned [mem 0xd8620000-0xd863ffff pref]
[    0.442049] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    0.442055] pci 0000:00:1c.1:   bridge window [io  0x3000-0x3fff]
[    0.442063] pci 0000:00:1c.1:   bridge window [mem 0xd8200000-0xd82fffff]
[    0.442070] pci 0000:00:1c.1:   bridge window [mem 0xd8600000-0xd86fffff pref]
[    0.442110] pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.442118] pci 0000:00:1c.0: setting latency timer to 64
[    0.442135] pci 0000:00:1c.1: PCI INT B -> GSI 16 (level, low) -> IRQ 16
[    0.442142] pci 0000:00:1c.1: setting latency timer to 64
[    0.442150] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.442155] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.442160] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.442166] pci_bus 0000:00: resource 7 [mem 0x000e0000-0x000effff]
[    0.442171] pci_bus 0000:00: resource 8 [mem 0x000f0000-0x000fffff]
[    0.442176] pci_bus 0000:00: resource 9 [mem 0x7f800000-0xfebfffff]
[    0.442182] pci_bus 0000:02: resource 0 [io  0x2000-0x2fff]
[    0.442187] pci_bus 0000:02: resource 1 [mem 0xd8100000-0xd81fffff]
[    0.442192] pci_bus 0000:02: resource 2 [mem 0xd8500000-0xd85fffff pref]
[    0.442197] pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
[    0.442203] pci_bus 0000:03: resource 1 [mem 0xd8200000-0xd82fffff]
[    0.442208] pci_bus 0000:03: resource 2 [mem 0xd8600000-0xd86fffff pref]
[    0.442331] NET: Registered protocol family 2
[    0.442456] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.443002] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.444129] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    0.444719] TCP: Hash tables configured (established 131072 bind 65536)
[    0.444726] TCP reno registered
[    0.444734] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.444760] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.445057] NET: Registered protocol family 1
[    0.445101] pci 0000:00:02.0: Boot video device
[    0.445233] PCI: CLS 64 bytes, default 64
[    0.445359] Unpacking initramfs...
[    1.710733] Freeing initrd memory: 29292k freed
[    1.749307] Simple Boot Flag at 0x36 set to 0x1
[    1.750224] audit: initializing netlink socket (disabled)
[    1.750251] type=2000 audit(1322593573.744:1): initialized
[    1.776285] highmem bounce pool size: 64 pages
[    1.776295] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.786376] VFS: Disk quotas dquot_6.5.2
[    1.786438] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    1.786564] msgmni has been set to 1719
[    1.786864] alg: No test for stdrng (krng)
[    1.786929] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    1.786935] io scheduler noop registered
[    1.786939] io scheduler deadline registered
[    1.786966] io scheduler cfq registered (default)
[    1.787418] intel_idle: MWAIT substates: 0x3020220
[    1.787431] intel_idle: v0.4 model 0x1C
[    1.787434] intel_idle: lapic_timer_reliable_states 0x2
[    1.787439] Marking TSC unstable due to TSC halts in idle states deeper than C2
[    1.787526] ERST: Table is not found!
[    1.787529] GHES: HEST is not enabled!
[    1.787557] isapnp: Scanning for PnP cards...
[    2.141677] isapnp: No Plug & Play device found
[    2.141827] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    2.162261] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.185012] 00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.200569] Linux agpgart interface v0.103
[    2.200981] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    2.202877] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.202891] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.203180] mousedev: PS/2 mouse device common for all mice
[    2.203267] rtc_cmos 00:07: RTC can wake from S4
[    2.203419] rtc_cmos 00:07: rtc core: registered rtc_cmos as rtc0
[    2.203448] rtc0: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    2.203652] cpuidle: using governor ladder
[    2.203955] cpuidle: using governor menu
[    2.204473] TCP cubic registered
[    2.204569] NET: Registered protocol family 10
[    2.205715] Mobile IPv6
[    2.205721] NET: Registered protocol family 17
[    2.205730] Registering the dns_resolver key type
[    2.205771] Using IPI No-Shortcut mode
[    2.206046] PM: Hibernation image not present or could not be loaded.
[    2.206066] registered taskstats version 1
[    2.211447] rtc_cmos 00:07: setting system clock to 2011-11-29 19:06:14 UTC (1322593574)
[    2.211553] Initializing network drop monitor service
[    2.211773] Freeing unused kernel memory: 432k freed
[    2.212234] Write protecting the kernel text: 2856k
[    2.212283] Write protecting the kernel read-only data: 1004k
[    2.212288] NX-protecting the kernel data: 3288k
[    2.241196] udev[49]: starting version 164
[    2.373132] r8169 Gigabit Ethernet driver 2.3LK-NAPI-patched loaded
[    2.373184] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    2.373233] r8169 0000:02:00.0: setting latency timer to 64
[    2.373313] r8169 0000:02:00.0: irq 40 for MSI/MSI-X
[    2.374681] r8169 0000:02:00.0: eth0: RTL8168c/8111c[21] at 0xf93d0000, 00:01:c0:08:aa:31, XID 1c4000c0 IRQ 40
[    2.374692] r8169 0000:02:00.0: eth0: jumbo features [frames: 6128 bytes, tx checksumming: ko]
[    2.399586] sdhci: Secure Digital Host Controller Interface driver
[    2.399593] sdhci: Copyright(c) Pierre Ossman
[    2.413764] sdhci-pci 0000:00:1e.0: SDHCI controller found [8086:811c] (rev 7)
[    2.413818] sdhci-pci 0000:00:1e.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    2.413878] sdhci-pci 0000:00:1e.0: setting latency timer to 64
[    2.413926] mmc0: no vmmc regulator found
[    2.414010] Registered led device: mmc0::
[    2.415106] mmc0: SDHCI controller on PCI [0000:00:1e.0] using DMA
[    2.415282] thermal LNXTHERM:00: registered as thermal_zone0
[    2.415288] ACPI: Thermal Zone [TZ00] (0 C)
[    2.415843] ACPI: Invalid active0 threshold
[    2.422303] thermal LNXTHERM:01: registered as thermal_zone1
[    2.422311] ACPI: Thermal Zone [TZ01] (0 C)
[    2.427431] SCSI subsystem initialized
[    2.431622] r8169 Gigabit Ethernet driver 2.3LK-NAPI-patched loaded
[    2.431676] r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    2.431733] r8169 0000:03:00.0: setting latency timer to 64
[    2.431811] r8169 0000:03:00.0: irq 41 for MSI/MSI-X
[    2.433956] sdhci-pci 0000:00:1e.1: SDHCI controller found [8086:811d] (rev 7)
[    2.434010] sdhci-pci 0000:00:1e.1: PCI INT B -> GSI 20 (level, low) -> IRQ 20
[    2.434073] sdhci-pci 0000:00:1e.1: setting latency timer to 64
[    2.434115] mmc1: no vmmc regulator found
[    2.434191] Registered led device: mmc1::
[    2.435277] mmc1: SDHCI controller on PCI [0000:00:1e.1] using DMA
[    2.435292] r8169 0000:03:00.0: eth1: RTL8168c/8111c[21] at 0xf838c000, 00:01:c0:08:aa:32, XID 1c4000c0 IRQ 41
[    2.435301] r8169 0000:03:00.0: eth1: jumbo features [frames: 6128 bytes, tx checksumming: ko]
[    2.435308] sdhci-pci 0000:00:1e.2: SDHCI controller found [8086:811e] (rev 7)
[    2.435341] sdhci-pci 0000:00:1e.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    2.435387] sdhci-pci 0000:00:1e.2: setting latency timer to 64
[    2.435424] mmc2: no vmmc regulator found
[    2.435504] Registered led device: mmc2::
[    2.437722] usbcore: registered new interface driver usbfs
[    2.437787] usbcore: registered new interface driver hub
[    2.448176] usbcore: registered new device driver usb
[    2.450507] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.454753] mmc2: SDHCI controller on PCI [0000:00:1e.2] using DMA
[    2.461198] ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 21 (level, low) -> IRQ 21
[    2.461245] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    2.461255] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    2.461314] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    2.461378] ehci_hcd 0000:00:1d.7: debug port 1
[    2.465282] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[    2.477570] ehci_hcd 0000:00:1d.7: irq 21, io mem 0xd8014000
[    2.484064] libata version 3.00 loaded.
[    2.492061] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    2.492158] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    2.492167] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.492173] usb usb1: Product: EHCI Host Controller
[    2.492179] usb usb1: Manufacturer: Linux 3.2.0-rc3+ ehci_hcd
[    2.492184] usb usb1: SerialNumber: 0000:00:1d.7
[    2.492525] hub 1-0:1.0: USB hub found
[    2.492541] hub 1-0:1.0: 8 ports detected
[    2.494637] uhci_hcd: USB Universal Host Controller Interface driver
[    2.494760] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    2.494784] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    2.494794] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    2.494827] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    2.494897] uhci_hcd 0000:00:1d.0: irq 23, io base 0x00001820
[    2.494993] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    2.495001] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.495008] usb usb2: Product: UHCI Host Controller
[    2.495014] usb usb2: Manufacturer: Linux 3.2.0-rc3+ uhci_hcd
[    2.495020] usb usb2: SerialNumber: 0000:00:1d.0
[    2.495346] hub 2-0:1.0: USB hub found
[    2.495357] hub 2-0:1.0: 2 ports detected
[    2.495531] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    2.495546] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    2.495552] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    2.495569] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    2.495620] uhci_hcd 0000:00:1d.1: irq 19, io base 0x00001840
[    2.495689] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    2.495694] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.495699] usb usb3: Product: UHCI Host Controller
[    2.495703] usb usb3: Manufacturer: Linux 3.2.0-rc3+ uhci_hcd
[    2.495707] usb usb3: SerialNumber: 0000:00:1d.1
[    2.495967] hub 3-0:1.0: USB hub found
[    2.495977] hub 3-0:1.0: 2 ports detected
[    2.496234] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    2.496254] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    2.496262] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    2.496282] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    2.496323] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001860
[    2.496411] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    2.496419] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.496426] usb usb4: Product: UHCI Host Controller
[    2.496431] usb usb4: Manufacturer: Linux 3.2.0-rc3+ uhci_hcd
[    2.496437] usb usb4: SerialNumber: 0000:00:1d.2
[    2.497386] hub 4-0:1.0: USB hub found
[    2.497403] hub 4-0:1.0: 2 ports detected
[    2.498183] pata_sch 0000:00:1f.1: version 0.2
[    2.498303] pata_sch 0000:00:1f.1: setting latency timer to 64
[    2.499599] scsi0 : pata_sch
[    2.499905] scsi1 : pata_sch
[    2.500690] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1810 irq 14
[    2.500699] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1818 irq 15
[    2.664865] ata1.00: ATA-8: Hitachi HTE545050B9A300, PB4OC64G, max UDMA/133
[    2.664875] ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    2.680854] ata1.00: configured for UDMA/100
[    2.681116] scsi 0:0:0:0: Direct-Access     ATA      Hitachi HTE54505 PB4O PQ: 0 ANSI: 5
[    2.804316] usb 1-1: new high-speed USB device number 2 using ehci_hcd
[    2.858028] sd 0:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[    2.858215] sd 0:0:0:0: [sda] Write Protect is off
[    2.858224] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.858304] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.888120]  sda: sda1 sda2 sda3
[    2.889272] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.937824] usb 1-1: New USB device found, idVendor=05e3, idProduct=0608
[    2.937846] usb 1-1: New USB device strings: Mfr=0, Product=1, SerialNumber=0
[    2.937862] usb 1-1: Product: USB2.0 Hub
[    2.938918] hub 1-1:1.0: USB hub found
[    2.939294] hub 1-1:1.0: 4 ports detected
[    3.052100] usb 1-2: new high-speed USB device number 3 using ehci_hcd
[    3.185105] usb 1-2: New USB device found, idVendor=0409, idProduct=005a
[    3.185114] usb 1-2: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    3.185683] hub 1-2:1.0: USB hub found
[    3.185775] hub 1-2:1.0: 4 ports detected
[    3.296051] usb 1-7: new high-speed USB device number 4 using ehci_hcd
[    3.323755] PM: Starting manual resume from disk
[    3.323762] PM: Hibernation image partition 8:2 present
[    3.323766] PM: Looking for hibernation image.
[    3.324238] PM: Image not found (code -22)
[    3.324248] PM: Hibernation image not present or could not be loaded.
[    3.444138] EXT4-fs (sda3): mounted filesystem with ordered data mode. Opts: (null)
[    3.445439] usb 1-7: New USB device found, idVendor=148f, idProduct=3070
[    3.445450] usb 1-7: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.445457] usb 1-7: Product: 802.11 n WLAN
[    3.445462] usb 1-7: Manufacturer: Ralink
[    3.445468] usb 1-7: SerialNumber: 1.0
[    3.520747] usb 1-1.1: new high-speed USB device number 5 using ehci_hcd
[    3.614733] usb 1-1.1: New USB device found, idVendor=05e3, idProduct=0608
[    3.614752] usb 1-1.1: New USB device strings: Mfr=0, Product=1, SerialNumber=0
[    3.614766] usb 1-1.1: Product: USB2.0 Hub
[    3.615643] hub 1-1.1:1.0: USB hub found
[    3.616104] hub 1-1.1:1.0: 4 ports detected
[    3.704708] usb 1-2.4: new low-speed USB device number 6 using ehci_hcd
[    3.875127] usb 1-2.4: New USB device found, idVendor=0557, idProduct=2213
[    3.875147] usb 1-2.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    3.875160] usb 1-2.4: Product: CS1784
[    3.875170] usb 1-2.4: Manufacturer: ATEN
[    3.952749] usb 1-1.1.1: new full-speed USB device number 7 using ehci_hcd
[    4.046154] usb 1-1.1.1: New USB device found, idVendor=03eb, idProduct=204b
[    4.046164] usb 1-1.1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    4.046170] usb 1-1.1.1: Product: CUL868
[    4.046175] usb 1-1.1.1: Manufacturer: busware.de
[    5.494821] udev[269]: starting version 164
[    6.391381] ACPI: AC Adapter [ADP1] (on-line)
[    6.394203] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    6.394219] ACPI: Power Button [PWRB]
[    6.394434] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    6.394448] ACPI: Power Button [PWRF]
[    6.394463] ACPI Error: Could not enable PowerButton event (20110623/evxfevnt-199)
[    6.394474] ACPI Warning: Could not enable fixed event 0x2 (20110623/evxface-198)
[    6.409361] input: PC Speaker as /devices/platform/pcspkr/input/input2
[    6.416384] button: probe of LNXPWRBN:00 failed with error -22
[    6.531189] ACPI: Battery Slot [BAT0] (battery absent)
[    6.531254] ACPI: Battery Slot [BAT1] (battery absent)
[    6.531317] ACPI: Battery Slot [BAT2] (battery absent)
[    6.709244] cdc_acm 1-1.1.1:1.0: ttyACM0: USB ACM device
[    6.710196] usbcore: registered new interface driver cdc_acm
[    6.710216] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[    7.062048] cfg80211: Calling CRDA to update world regulatory domain
[    7.694749] [drm] Initialized drm 1.1.0 20060810
[    8.155838] input: ATEN CS1784 as /devices/pci0000:00/0000:00:1d.7/usb1/1-2/1-2.4/1-2.4:1.0/input/input3
[    8.156228] generic-usb 0003:0557:2213.0001: input,hidraw0: USB HID v1.00 Keyboard [ATEN CS1784] on usb-0000:00:1d.7-2.4/input0
[    8.180903] input: ATEN CS1784 as /devices/pci0000:00/0000:00:1d.7/usb1/1-2/1-2.4/1-2.4:1.1/input/input4
[    8.182032] generic-usb 0003:0557:2213.0002: input,hidraw1: USB HID v1.00 Mouse [ATEN CS1784] on usb-0000:00:1d.7-2.4/input1
[    8.182415] usbcore: registered new interface driver usbhid
[    8.182422] usbhid: USB HID core driver
[    8.185621] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    8.185692] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[    8.476755] hda_codec: ALC662 rev1: SKU not ready 0x411111f0
[    8.478960] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/input/input5
[    8.483610] input: HDA Intel MID Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card0/input6
[    8.516422] psb_gfx: module is from the staging directory, the quality is unknown, you have been warned.
[    8.520574] gma500 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    8.520586] gma500 0000:00:02.0: setting latency timer to 64
[    8.521453] ioremap error for 0x7f6bc000-0x7f6bf000, requested 0x10, got 0x0
[    8.521677] Stolen memory information
[    8.521683]        base in RAM: 0x7f800000
[    8.521688]        size: 8060K, calculated by (GTT RAM base) - (Stolen base), seems wrong
[    8.521694]       the correct size should be: 8M(dvmt mode=3)
[    8.524340] Set up 2015 stolen pages starting at 0x7f800000, GTT offset 0K
[    8.524518] [drm] SGX core id = 0x01130000
[    8.524524] [drm] SGX core rev major = 0x01, minor = 0x02
[    8.524529] [drm] SGX core rev maintenance = 0x01, designer = 0x00
[    8.540571] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    8.620705] acpi device:05: registered as cooling_device2
[    8.672686] acpi device:06: registered as cooling_device3
[    8.673081] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input7
[    8.673371] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
[    8.673451] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    8.673456] [drm] No driver support for vblank timestamp query.
[    8.788053] usb 1-7: reset high-speed USB device number 4 using ehci_hcd
[    9.016823] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    9.018715] Registered led device: rt2800usb-phy0::radio
[    9.018785] Registered led device: rt2800usb-phy0::assoc
[    9.018856] Registered led device: rt2800usb-phy0::quality
[    9.018941] usbcore: registered new interface driver rt2800usb
[    9.506796] Raw EDID:
[    9.506855]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[    9.506914]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[    9.506972]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[    9.507030]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[    9.507088]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[    9.507145]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[    9.507203]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[    9.507261]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[    9.507323] gma500 0000:00:02.0: LVDS-1: EDID block 0 invalid.
[   10.689641] Raw EDID:
[   10.689699]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.689758]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.689816]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.689874]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.689932]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.689990]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.690047]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.690105]  	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   10.690186] gma500 0000:00:02.0: LVDS-1: EDID block 0 invalid.
[   10.736995] gma500 0000:00:02.0: allocated 1024x768 fb
[   10.737183] fbcon: psbfb (fb0) is primary device
[   11.150278] Console: switching to colour frame buffer device 128x48
[   11.157488] fb0: psbfb frame buffer device
[   11.157491] drm: registered panic notifier
[   11.157609] gma500 0000:00:02.0: Backlight lvds set brightness 7a120000
[   11.157619] [drm] Initialized gma500 1.0.0 2011-06-06 for 0000:00:02.0 on minor 0
[   11.639469] Adding 3906556k swap on /dev/sda2.  Priority:-1 extents:1 across:3906556k 
[   11.646926] EXT4-fs (sda3): re-mounted. Opts: (null)
[   11.934184] EXT4-fs (sda3): re-mounted. Opts: errors=remount-ro
[   12.150401] loop: module loaded
[   14.522369] r8169 0000:02:00.0: eth0: link down
[   14.522773] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   14.671742] r8169 0000:03:00.0: eth1: link down
[   14.672169] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   15.905781] fuse init (API version 7.17)
[   20.739159] RPC: Registered named UNIX socket transport module.
[   20.739165] RPC: Registered udp transport module.
[   20.739169] RPC: Registered tcp transport module.
[   20.739172] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   22.696401] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   23.736879] svc: failed to register lockdv1 RPC service (errno 97).
[   23.736974] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   23.883115] NFSD: starting 90-second grace period
[   27.350333] sshd (1622): /proc/1622/oom_adj is deprecated, please use /proc/1622/oom_score_adj instead.

--------------060808080200040305020206--
