From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Fri, 10 Apr 2015 16:06:42 +0100
Message-ID: <21799.59138.666831.970946@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<21796.6843.983774.271495@mariner.uk.xensource.com>
	<21796.7755.270785.292996@mariner.uk.xensource.com>
	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1428448976.4720.15.camel@prashant>
	<21797.13348.524963.29127@mariner.uk.xensource.com>
	<1428543798.4720.20.camel@prashant>
	<21798.24161.922394.539733@mariner.uk.xensource.com>
	<1428595851.4720.22.camel@prashant>
	<21798.44949.156680.399387@mariner.uk.xensource.com>
	<21798.46590.928152.666550@mariner.uk.xensource.com>
	<1428602883.4720.31.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43568 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933321AbbDJPH4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 11:07:56 -0400
In-Reply-To: <1428602883.4720.31.camel@prashant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant Sreedharan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> thanks for the repo, the RX drop counter is updated at few places in the
> driver. Please use the attached debug patch and provide the logs

Thanks.  I applied just that patch on top of 3.14.34, 32-bit, and got
no additional messages of any kind.

(I switched to a different test box "elbling1" with the same symptoms:
~25% packet loss in ping under 64-bit Xen with 32-bit x86 Linux; 100%
loss Linux x86 32-bit baremetal with `iommu=soft swiotlb=force'.  In
each case I had disabled the bridge setup so was just using eth0.)

Once again, tcpdumping eth0 with machine booted baremetal with the
`iommu...' boot options shows corrupted packets on the receive path:

Full transcript below.  The non-corrupted packets (ARP requests) in
the tcpdump are outgoing: 172.16.144.31 is elbling1.

I think the packets are being dropped by the non-tg3 part of the
kernel due to their protocol field having been corrupted.

Thanks,
Ian.

Apr 10 14:42:11.628982 Loading Linux 3.14.34+ ...
Apr 10 14:42:11.700882 Loading initial ramdisk ...
Apr 10 14:42:12.140916 [    0.000000] Ini
Apr 10 14:42:13.796944 <Modem lines changed: -CTS>
tializing cgroup subsys cpuset
Apr 10 14:42:13.804890 [    0.000000] Initializing cgroup subsys cpu
Apr 10 14:42:13.804931 [    0.000000] Initializing cgroup subsys cpuacct
Apr 10 14:42:13.813042 [    0.000000] Linux version 3.14.34+ (osstest@elbling1) (gcc version 4.7.2 (Debian 4.7.2-5) ) #1 SMP Fri Apr 10 13:31:52 BST 2015
Apr 10 14:42:13.828967 [    0.000000] e820: BIOS-provided physical RAM map:
Apr 10 14:42:13.829020 [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009bfff] usable
Apr 10 14:42:13.836961 [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cd2effff] usable
Apr 10 14:42:13.844897 [    0.000000] BIOS-e820: [mem 0x00000000cd2f0000-0x00000000cd31bfff] reserved
Apr 10 14:42:13.852982 [    0.000000] BIOS-e820: [mem 0x00000000cd31c000-0x00000000cd35afff] ACPI data
Apr 10 14:42:13.860922 [    0.000000] BIOS-e820: [mem 0x00000000cd35b000-0x00000000cfffffff] reserved
Apr 10 14:42:13.868980 [    0.000000] BIOS-e820: [mem 0x00000000e0000000-0x00000000efffffff] reserved
Apr 10 14:42:13.876928 [    0.000000] BIOS-e820: [mem 0x00000000fe000000-0x00000000ffffffff] reserved
Apr 10 14:42:13.885122 [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000022fffffff] usable
Apr 10 14:42:13.892928 [    0.000000] NX (Execute Disable) protection: active
Apr 10 14:42:13.900915 [    0.000000] SMBIOS 2.7 present.
Apr 10 14:42:13.900943 [    0.000000] e820: last_pfn = 0x230000 max_arch_pfn = 0x1000000
Apr 10 14:42:13.908939 [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
Apr 10 14:42:13.917008 [    0.000000] found SMP MP-table at [mem 0x000fe710-0x000fe71f] mapped at [c00fe710]
Apr 10 14:42:13.924858 [    0.000000] Scanning 1 areas for low memory corruption
Apr 10 14:42:13.932869 [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
Apr 10 14:42:13.940930 [    0.000000] init_memory_mapping: [mem 0x37400000-0x375fffff]
Apr 10 14:42:13.940991 [    0.000000] init_memory_mapping: [mem 0x34000000-0x373fffff]
Apr 10 14:42:13.948960 [    0.000000] init_memory_mapping: [mem 0x00100000-0x33ffffff]
Apr 10 14:42:13.956987 [    0.000000] init_memory_mapping: [mem 0x37600000-0x377fdfff]
Apr 10 14:42:13.964934 [    0.000000] RAMDISK: [mem 0x361ca000-0x370dcfff]
Apr 10 14:42:13.964954 [    0.000000] ACPI: RSDP 000f1100 000024 (v02 DELL  )
Apr 10 14:42:13.972914 [    0.000000] ACPI: XSDT 000f1248 0000A4 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:13.981004 [    0.000000] ACPI: FACP cd33534c 0000F4 (v03 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:13.988881 [    0.000000] ACPI: DSDT cd31c000 0072F1 (v01 DELL   PE_SC3   00000001 INTL 20110211)
Apr 10 14:42:13.996888 [    0.000000] ACPI: FACS cd337000 000040
Apr 10 14:42:14.004875 [    0.000000] ACPI: APIC cd334478 0001DE (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.012957 [    0.000000] ACPI: SPCR cd334664 000050 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.020975 [    0.000000] ACPI: HPET cd3346b8 000038 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.028883 [    0.000000] ACPI: DMAR cd3346f4 0000D8 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.036846 [    0.000000] ACPI: MCFG cd334a10 00003C (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.044835 [    0.000000] ACPI: WD__ cd334a50 000134 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.052835 [    0.000000] ACPI: SLIC cd334b88 000024 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.060908 [    0.000000] ACPI: ERST cd3234b4 000270 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.068908 [    0.000000] ACPI: HEST cd323724 000578 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.077018 [    0.000000] ACPI: BERT cd3232f4 000030 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.084889 [    0.000000] ACPI: EINJ cd323324 000190 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.092911 [    0.000000] ACPI: TCPA cd3352e4 000064 (v02 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.108992 [    0.000000] ACPI: PC__ cd335274 00006E (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.116983 [    0.000000] ACPI: SRAT cd334db0 0004C0 (v01 DELL   PE_SC3   00000001 DELL 00000001)
Apr 10 14:42:14.124986 [    0.000000] ACPI: SSDT cd338000 0012F8 (v01 INTEL  PPM RCM  80000001 INTL 20061109)
Apr 10 14:42:14.133024 [    0.000000] 8072MB HIGHMEM available.
Apr 10 14:42:14.133044 [    0.000000] 887MB LOWMEM available.
Apr 10 14:42:14.140990 [    0.000000]   mapped low ram: 0 - 377fe000
Apr 10 14:42:14.141010 [    0.000000]   low ram: 0 - 377fe000
Apr 10 14:42:14.148921 [    0.000000] Zone ranges:
Apr 10 14:42:14.148939 [    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
Apr 10 14:42:14.156983 [    0.000000]   Normal   [mem 0x01000000-0x377fdfff]
Apr 10 14:42:14.157002 [    0.000000]   HighMem  [mem 0x377fe000-0x2fffffff]
Apr 10 14:42:14.164882 [    0.000000] Movable zone start for each node
Apr 10 14:42:14.173044 [    0.000000] Early memory node ranges
Apr 10 14:42:14.173083 [    0.000000]   node   0: [mem 0x00001000-0x0009bfff]
Apr 10 14:42:14.180959 [    0.000000]   node   0: [mem 0x00100000-0xcd2effff]
Apr 10 14:42:14.188873 [    0.000000]   node   0: [mem 0x00000000-0x2fffffff]
Apr 10 14:42:14.188904 [    0.000000] Using APIC driver default
Apr 10 14:42:14.196971 [    0.000000] ACPI: PM-Timer IO Port: 0x808
Apr 10 14:42:14.196991 [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Apr 10 14:42:14.204997 [    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
Apr 10 14:42:14.212964 [    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
Apr 10 14:42:14.220986 [    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)
Apr 10 14:42:14.228972 [    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x44] disabled)
Apr 10 14:42:14.228993 [    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x45] disabled)
Apr 10 14:42:14.236910 [    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x46] disabled)
Apr 10 14:42:14.244905 [    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x47] disabled)
Apr 10 14:42:14.252873 [    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x48] disabled)
Apr 10 14:42:14.260928 [    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x49] disabled)
Apr 10 14:42:14.268936 [    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x4a] disabled)
Apr 10 14:42:14.268958 [    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x4b] disabled)
Apr 10 14:42:14.276918 [    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x4c] disabled)
Apr 10 14:42:14.284907 [    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x4d] disabled)
Apr 10 14:42:14.292916 [    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x4e] disabled)
Apr 10 14:42:14.300918 [    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x4f] disabled)
Apr 10 14:42:14.300946 [    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x50] disabled)
Apr 10 14:42:14.308849 [    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x51] disabled)
Apr 10 14:42:14.316978 [    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x52] disabled)
Apr 10 14:42:14.324900 [    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x53] disabled)
Apr 10 14:42:14.333012 [    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x54] disabled)
Apr 10 14:42:14.341035 [    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x55] disabled)
Apr 10 14:42:14.341075 [    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x56] disabled)
Apr 10 14:42:14.348921 [    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x57] disabled)
Apr 10 14:42:14.356895 [    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x58] disabled)
Apr 10 14:42:14.364983 [    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x59] disabled)
Apr 10 14:42:14.372982 [    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x5a] disabled)
Apr 10 14:42:14.381023 [    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x5b] disabled)
Apr 10 14:42:14.381062 [    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x5c] disabled)
Apr 10 14:42:14.388987 [    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x5d] disabled)
Apr 10 14:42:14.397012 [    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x5e] disabled)
Apr 10 14:42:14.404884 [    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0x5f] disabled)
Apr 10 14:42:14.412891 [    0.000000] ACPI: LAPIC (acpi_id[0x21] lapic_id[0x60] disabled)
Apr 10 14:42:14.420974 [    0.000000] ACPI: LAPIC (acpi_id[0x22] lapic_id[0x61] disabled)
Apr 10 14:42:14.421013 [    0.000000] ACPI: LAPIC (acpi_id[0x23] lapic_id[0x62] disabled)
Apr 10 14:42:14.428976 [    0.000000] ACPI: LAPIC (acpi_id[0x24] lapic_id[0x63] disabled)
Apr 10 14:42:14.437031 [    0.000000] ACPI: LAPIC (acpi_id[0x25] lapic_id[0x64] disabled)
Apr 10 14:42:14.444989 [    0.000000] ACPI: LAPIC (acpi_id[0x26] lapic_id[0x65] disabled)
Apr 10 14:42:14.452866 [    0.000000] ACPI: LAPIC (acpi_id[0x27] lapic_id[0x66] disabled)
Apr 10 14:42:14.452906 [    0.000000] ACPI: LAPIC (acpi_id[0x28] lapic_id[0x67] disabled)
Apr 10 14:42:14.460902 [    0.000000] ACPI: LAPIC (acpi_id[0x29] lapic_id[0x68] disabled)
Apr 10 14:42:14.468979 [    0.000000] ACPI: LAPIC (acpi_id[0x2a] lapic_id[0x69] disabled)
Apr 10 14:42:14.477000 [    0.000000] ACPI: LAPIC (acpi_id[0x2b] lapic_id[0x6a] disabled)
Apr 10 14:42:14.484877 [    0.000000] ACPI: LAPIC (acpi_id[0x2c] lapic_id[0x6b] disabled)
Apr 10 14:42:14.492970 [    0.000000] ACPI: LAPIC (acpi_id[0x2d] lapic_id[0x6c] disabled)
Apr 10 14:42:14.493008 [    0.000000] ACPI: LAPIC (acpi_id[0x2e] lapic_id[0x6d] disabled)
Apr 10 14:42:14.500996 [    0.000000] ACPI: LAPIC (acpi_id[0x2f] lapic_id[0x6e] disabled)
Apr 10 14:42:14.508985 [    0.000000] ACPI: LAPIC (acpi_id[0x30] lapic_id[0x6f] disabled)
Apr 10 14:42:14.516950 [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
Apr 10 14:42:14.524977 [    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
Apr 10 14:42:14.532843 [    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
Apr 10 14:42:14.540817 [    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec3f000] gsi_base[32])
Apr 10 14:42:14.540842 [    0.000000] IOAPIC[1]: apic_id 1, version 32, address 0xfec3f000, GSI 32-55
Apr 10 14:42:14.548854 [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
Apr 10 14:42:14.556982 [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Apr 10 14:42:14.564949 [    0.000000] Using ACPI (MADT) for SMP configuration information
Apr 10 14:42:14.572918 [    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
Apr 10 14:42:14.580844 [    0.000000] smpboot: 48 Processors exceeds NR_CPUS limit of 8
Apr 10 14:42:14.588903 [    0.000000] smpboot: Allowing 8 CPUs, 4 hotplug CPUs
Apr 10 14:42:14.588934 [    0.000000] PM: Registered nosave memory: [mem 0x0009c000-0x000fffff]
Apr 10 14:42:14.596988 [    0.000000] e820: [mem 0xd0000000-0xdfffffff] available for PCI devices
Apr 10 14:42:14.604907 [    0.000000] Booting paravirtualized kernel on bare hardware
Apr 10 14:42:14.612867 [    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:8 nr_node_ids:1
Apr 10 14:42:14.620866 [    0.000000] PERCPU: Embedded 14 pages/cpu @f777b000 s33920 r0 d23424 u57344
Apr 10 14:42:14.628850 [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2083739
Apr 10 14:42:14.636819 [    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.14.34+ root=/dev/mapper/elbling1-root ro BOOTIF=01-b0-83-fe-db-b6-69 console=ttyS0,115200 iommu=soft swiotlb=force
Apr 10 14:42:14.652908 [    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
Apr 10 14:42:14.660918 [    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Apr 10 14:42:14.668798 [    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Apr 10 14:42:14.676793 [    0.000000] Initializing CPU#0
Apr 10 14:42:14.676829 [    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
Apr 10 14:42:14.684867 [    0.000000] Initializing HighMem for node 0 (000377fe:00230000)
Apr 10 14:42:14.692889 [    0.000000] Initializing Movable for node 0 (00000000:00000000)
Apr 10 14:42:14.700889 [    0.000000] Memory: 8176616K/8342060K available (6937K kernel code, 460K rwdata, 2064K rodata, 676K init, 724K bss, 165444K reserved, 7433160K highmem)
Apr 10 14:42:14.716870 [    0.000000] virtual kernel memory layout:
Apr 10 14:42:14.716897 [    0.000000]     fixmap  : 0xfff14000 - 0xfffff000   ( 940 kB)
Apr 10 14:42:14.724937 [    0.000000]     pkmap   : 0xff800000 - 0xffa00000   (2048 kB)
Apr 10 14:42:14.732943 [    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
Apr 10 14:42:14.740854 [    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
Apr 10 14:42:14.740890 [    0.000000]       .init : 0xc1941000 - 0xc19ea000   ( 676 kB)
Apr 10 14:42:14.749040 [    0.000000]       .data : 0xc16c68f7 - 0xc19402c0   (2534 kB)
Apr 10 14:42:14.756926 [    0.000000]       .text : 0xc1000000 - 0xc16c68f7   (6938 kB)
Apr 10 14:42:14.764930 [    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
Apr 10 14:42:14.772909 [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
Apr 10 14:42:14.780936 [    0.000000] Hierarchical RCU implementation.
Apr 10 14:42:14.780982 [    0.000000] NR_IRQS:2304 nr_irqs:1288 16
Apr 10 14:42:14.788906 [    0.000000] Console: colour VGA+ 80x25
Apr 10 14:42:14.788941 [    0.000000] console [ttyS0] enabled
Apr 10 14:42:14.796860 [    0.000000] tsc: Fast TSC calibration using PIT
Apr 10 14:42:14.820865 [    0.000000] tsc: Detected 2399.906 MHz processor
Apr 10 14:42:14.829065 [    0.000002] Calibrating delay loop (skipped), value calculated using timer frequency.. 4799.81 BogoMIPS (lpj=2399906)
Apr 10 14:42:14.844905 [    0.011875] pid_max: default: 32768 minimum: 301
Apr 10 14:42:14.844934 [    0.017037] ACPI: Core revision 20131218
Apr 10 14:42:14.852849 [    0.022661] ACPI: All ACPI Tables successfully acquired
Apr 10 14:42:14.860911 [    0.029234] Security Framework initialized
Apr 10 14:42:14.860932 [    0.033805] SELinux:  Initializing.
Apr 10 14:42:14.868890 [    0.037714] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
Apr 10 14:42:14.876862 [    0.045106] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
Apr 10 14:42:14.884855 [    0.053132] Initializing cgroup subsys freezer
Apr 10 14:42:14.884877 [    0.058124] CPU: Physical Processor ID: 0
Apr 10 14:42:14.892849 [    0.062604] CPU: Processor Core ID: 0
Apr 10 14:42:14.892883 [    0.068512] mce: CPU supports 21 MCE banks
Apr 10 14:42:14.900827 [    0.073124] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
Apr 10 14:42:14.908801 [    0.073124] Last level dTLB entries: 4KB 512, 2MB 0, 4MB 0, 1GB 4
Apr 10 14:42:14.916863 [    0.073124] tlb_flushall_shift: 6
Apr 10 14:42:14.916882 [    0.089944] Freeing SMP alternatives memory: 28K (c19ea000 - c19f1000)
Apr 10 14:42:14.924785 [    0.098398] Enabling APIC mode:  Flat.  Using 2 I/O APICs
Apr 10 14:42:14.932927 [    0.104928] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
Apr 10 14:42:14.940950 [    0.121644] smpboot: CPU0: Intel(R) Xeon(R) CPU E5-2407 v2 @ 2.40GHz (fam: 06, model: 3e, stepping: 04)
Apr 10 14:42:14.965097 [    0.132179] Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge events, full-width counters, Intel PMU driver.
Apr 10 14:42:14.972986 [    0.143703] ... version:                3
Apr 10 14:42:14.980973 [    0.148177] ... bit width:              48
Apr 10 14:42:14.981019 [    0.152749] ... generic registers:      8
Apr 10 14:42:14.988990 [    0.157223] ... value mask:             0000ffffffffffff
Apr 10 14:42:14.996916 [    0.163152] ... max period:             0000ffffffffffff
Apr 10 14:42:14.996980 [    0.169082] ... fixed-purpose events:   3
Apr 10 14:42:15.004937 [    0.173555] ... event mask:             00000007000000ff
Apr 10 14:42:15.013069 [    0.179721] x86: Booting SMP configuration:
Apr 10 14:42:15.013107 [    0.184392] .... node  #0, CPUs:      #1
Apr 10 14:42:15.028970 [    0.200048] Initializing CPU#1
Apr 10 14:42:15.036867 [    0.207654]  #2
Apr 10 14:42:15.052818 [    0.219967] Initializing CPU#2
Apr 10 14:42:15.052858 [    0.227573]  #3
Apr 10 14:42:15.068815 [    0.239888] Initializing CPU#3
Apr 10 14:42:15.076879 [    0.247396] x86: Booted up 1 node, 4 CPUs
Apr 10 14:42:15.084986 [    0.251871] smpboot: Total of 4 processors activated (19199.24 BogoMIPS)
Apr 10 14:42:15.092835 [    0.264271] devtmpfs: initialized
Apr 10 14:42:15.100974 [    0.268530] RTC time: 14:42:15, date: 04/10/15
Apr 10 14:42:15.101010 [    0.273531] NET: Registered protocol family 16
Apr 10 14:42:15.108992 [    0.278818] cpuidle: using governor ladder
Apr 10 14:42:15.116949 [    0.283392] cpuidle: using governor menu
Apr 10 14:42:15.116984 [    0.287873] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
Apr 10 14:42:15.124921 [    0.296328] ACPI: bus type PCI registered
Apr 10 14:42:15.133039 [    0.300879] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
Apr 10 14:42:15.140996 [    0.311275] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
Apr 10 14:42:15.148995 [    0.318854] PCI: Using MMCONFIG for extended config space
Apr 10 14:42:15.157026 [    0.324882] PCI: Using configuration type 1 for base access
Apr 10 14:42:15.157065 [    0.331307] PCI: Dell System detected, enabling pci=bfsort.
Apr 10 14:42:15.165030 [    0.344444] bio: create slab <bio-0> at 0
Apr 10 14:42:15.180976 [    0.349052] ACPI: Added _OSI(Module Device)
Apr 10 14:42:15.181013 [    0.353724] ACPI: Added _OSI(Processor Device)
Apr 10 14:42:15.188992 [    0.358685] ACPI: Added _OSI(3.0 _SCP Extensions)
Apr 10 14:42:15.196979 [    0.363937] ACPI: Added _OSI(Processor Aggregator Device)
Apr 10 14:42:15.197028 [    0.371345] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
Apr 10 14:42:15.205008 [    0.379015] ACPI: Interpreter enabled
Apr 10 14:42:15.212975 [    0.383111] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20131218/hwxface-580)
Apr 10 14:42:15.220979 [    0.393433] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20131218/hwxface-580)
Apr 10 14:42:15.236969 [    0.403751] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20131218/hwxface-580)
Apr 10 14:42:15.244982 [    0.414076] ACPI: (supports S0 S4 S5)
Apr 10 14:42:15.245028 [    0.418164] ACPI: Using IOAPIC for interrupt routing
Apr 10 14:42:15.253008 [    0.423750] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
Apr 10 14:42:15.260972 [    0.434019] ACPI: No dock devices found.
Apr 10 14:42:15.268813 [    0.444678] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
Apr 10 14:42:15.284921 [    0.451585] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
Apr 10 14:42:15.292943 [    0.460934] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
Apr 10 14:42:15.300883 [    0.470803] PCI host bridge to bus 0000:00
Apr 10 14:42:15.308881 [    0.475378] pci_bus 0000:00: root bus resource [bus 00-3e]
Apr 10 14:42:15.308923 [    0.481503] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
Apr 10 14:42:15.316958 [    0.488405] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7]
Apr 10 14:42:15.325003 [    0.495305] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df]
Apr 10 14:42:15.332976 [    0.502207] pci_bus 0000:00: root bus resource [io  0x0d00-0x1fff]
Apr 10 14:42:15.340951 [    0.509108] pci_bus 0000:00: root bus resource [io  0x2000-0xffff]
Apr 10 14:42:15.348955 [    0.516010] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
Apr 10 14:42:15.356871 [    0.523689] pci_bus 0000:00: root bus resource [mem 0xd0000000-0xfbffffff]
Apr 10 14:42:15.356919 [    0.531367] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff]
Apr 10 14:42:15.364850 [    0.540365] pci 0000:00:1a.0: System wakeup disabled by ACPI
Apr 10 14:42:15.372839 [    0.547341] pci 0000:00:1d.0: System wakeup disabled by ACPI
Apr 10 14:42:15.380823 [    0.555694] pci 0000:00:01.0: PCI bridge to [bus 01]
Apr 10 14:42:15.389015 [    0.561295] pci 0000:00:03.0: PCI bridge to [bus 08]
Apr 10 14:42:15.396937 [    0.566913] pci 0000:00:11.0: PCI bridge to [bus 09]
Apr 10 14:42:15.404959 [    0.572527] pci 0000:00:1c.0: PCI bridge to [bus 0a]
Apr 10 14:42:15.404998 [    0.580112] pci 0000:00:1c.4: PCI bridge to [bus 02]
Apr 10 14:42:15.412870 [    0.590813] pci 0000:00:1c.7: PCI bridge to [bus 03-07]
Apr 10 14:42:15.428802 [    0.607398] pci 0000:03:00.0: PCI bridge to [bus 04-07]
Apr 10 14:42:15.444815 [    0.619161] pci 0000:04:00.0: PCI bridge to [bus 05-06]
Apr 10 14:42:15.452961 [    0.632031] pci 0000:05:00.0: PCI bridge to [bus 06]
Apr 10 14:42:15.468945 [    0.639624] pci 0000:04:01.0: PCI bridge to [bus 07]
Apr 10 14:42:15.476962 [    0.646574] pci 0000:00:1e.0: PCI bridge to [bus 0b] (subtractive decode)
Apr 10 14:42:15.484951 [    0.654448] acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
Apr 10 14:42:15.492963 [    0.662925] ACPI: PCI Root Bridge [P0B1] (domain 0000 [bus 3f])
Apr 10 14:42:15.500968 [    0.669530] acpi PNP0A08:02: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
Apr 10 14:42:15.508990 [    0.678877] acpi PNP0A08:02: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
Apr 10 14:42:15.517003 [    0.687868] PCI host bridge to bus 0000:3f
Apr 10 14:42:15.524974 [    0.692443] pci_bus 0000:3f: root bus resource [bus 3f]
Apr 10 14:42:15.525020 [    0.700366] acpi PNP0A08:02: Disabling ASPM (FADT indicates it is unsupported)
Apr 10 14:42:15.540973 [    0.708464] ACPI: PCI Root Bridge [P1B1] (domain 0000 [bus 7f])
Apr 10 14:42:15.541014 [    0.715076] acpi PNP0A08:03: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
Apr 10 14:42:15.556853 [    0.724422] acpi PNP0A08:03: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
Apr 10 14:42:15.564830 [    0.733402] PCI host bridge to bus 0000:7f
Apr 10 14:42:15.564855 [    0.737977] pci_bus 0000:7f: root bus resource [bus 7f]
Apr 10 14:42:15.572999 [    0.743841] acpi PNP0A08:03: Disabling ASPM (FADT indicates it is unsupported)
Apr 10 14:42:15.580868 [    0.751953] ACPI: PCI Interrupt Link [LK00] (IRQs 3 4 5 6 7 11 14 *15)
Apr 10 14:42:15.588995 [    0.759387] ACPI: PCI Interrupt Link [LK01] (IRQs 3 4 5 6 7 11 *14 15)
Apr 10 14:42:15.596974 [    0.766820] ACPI: PCI Interrupt Link [LK02] (IRQs 3 4 5 6 7 11 14 15) *0, disabled.
Apr 10 14:42:15.604956 [    0.775536] ACPI: PCI Interrupt Link [LK03] (IRQs 3 4 5 6 7 *11 14 15)
Apr 10 14:42:15.613003 [    0.782968] ACPI: PCI Interrupt Link [LK04] (IRQs 3 4 *5 6 7 11 14 15)
Apr 10 14:42:15.620988 [    0.790394] ACPI: PCI Interrupt Link [LK05] (IRQs 3 4 5 6 7 11 14 15) *0, disabled.
Apr 10 14:42:15.628973 [    0.799106] ACPI: PCI Interrupt Link [LK06] (IRQs 3 4 5 *6 7 11 14 15)
Apr 10 14:42:15.636953 [    0.806539] ACPI: PCI Interrupt Link [LK07] (IRQs 3 4 5 6 7 11 *14 15)
Apr 10 14:42:15.644965 [    0.813983] ACPI: Enabled 3 GPEs in block 00 to 3F
Apr 10 14:42:15.645013 [    0.819646] vgaarb: device added: PCI:0000:06:00.0,decodes=io+mem,owns=io+mem,locks=none
Apr 10 14:42:15.660946 [    0.828687] vgaarb: loaded
Apr 10 14:42:15.660988 [    0.831698] vgaarb: bridge control possible 0000:06:00.0
Apr 10 14:42:15.668877 [    0.837732] SCSI subsystem initialized
Apr 10 14:42:15.668917 [    0.842097] ACPI: bus type USB registered
Apr 10 14:42:15.676859 [    0.846620] usbcore: registered new interface driver usbfs
Apr 10 14:42:15.684848 [    0.852761] usbcore: registered new interface driver hub
Apr 10 14:42:15.684888 [    0.858722] usbcore: registered new device driver usb
Apr 10 14:42:15.692971 [    0.864441] pps_core: LinuxPPS API ver. 1 registered
Apr 10 14:42:15.700960 [    0.869984] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
Apr 10 14:42:15.708968 [    0.880203] PTP clock support registered
Apr 10 14:42:15.716975 [    0.884694] Advanced Linux Sound Architecture Driver Initialized.
Apr 10 14:42:15.717025 [    0.891500] PCI: Using ACPI for IRQ routing
Apr 10 14:42:15.724853 [    0.903071] cfg80211: Calling CRDA to update world regulatory domain
Apr 10 14:42:15.740957 [    0.910199] NetLabel: Initializing
Apr 10 14:42:15.740991 [    0.913996] NetLabel:  domain hash size = 128
Apr 10 14:42:15.748995 [    0.918858] NetLabel:  protocols = UNLABELED CIPSOv4
Apr 10 14:42:15.756866 [    0.924417] NetLabel:  unlabeled traffic allowed by default
Apr 10 14:42:15.756915 [    0.930826] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
Apr 10 14:42:15.764847 [    0.937816] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
Apr 10 14:42:15.772921 [    0.946356] Switched to clocksource hpet
Apr 10 14:42:15.780837 [    0.955031] pnp: PnP ACPI init
Apr 10 14:42:15.788858 [    0.958447] ACPI: bus type PNP registered
Apr 10 14:42:15.788897 [    0.963905] system 00:06: [io  0x0800-0x087f] could not be reserved
Apr 10 14:42:15.796884 [    0.970909] system 00:06: [io  0x0880-0x08ff] has been reserved
Apr 10 14:42:15.804885 [    0.977520] system 00:06: [io  0x0900-0x091f] has been reserved
Apr 10 14:42:15.812846 [    0.984133] system 00:06: [io  0x0920-0x0923] has been reserved
Apr 10 14:42:15.820850 [    0.990745] system 00:06: [io  0x0924] has been reserved
Apr 10 14:42:15.828838 [    0.996678] system 00:06: [io  0x0370-0x0377] has been reserved
Apr 10 14:42:15.828878 [    1.003291] system 00:06: [io  0x0ca0-0x0ca7] has been reserved
Apr 10 14:42:15.837022 [    1.009904] system 00:06: [io  0x0ca9-0x0cab] has been reserved
Apr 10 14:42:15.844856 [    1.016516] system 00:06: [io  0x0cad-0x0caf] has been reserved
Apr 10 14:42:15.853008 [    1.023129] system 00:06: [io  0x0cb0-0x0cbf] has been reserved
Apr 10 14:42:15.860959 [    1.029832] system 00:07: [io  0x0ca8] has been reserved
Apr 10 14:42:15.860998 [    1.035768] system 00:07: [io  0x0cac] has been reserved
Apr 10 14:42:15.868997 [    1.042018] system 00:08: [mem 0xe0000000-0xe3efffff] has been reserved
Apr 10 14:42:15.877073 [    1.049507] system 00:09: [mem 0xe3f00000-0xe3ffffff] has been reserved
Apr 10 14:42:15.884856 [    1.056974] system 00:0a: [mem 0xdf100000-0xdf101fff] has been reserved
Apr 10 14:42:15.892845 [    1.064569] pnp: PnP ACPI: found 12 devices
Apr 10 14:42:15.900838 [    1.069241] ACPI: bus type PNP unregistered
Apr 10 14:42:15.900876 [    1.112030] pci 0000:02:00.1: address space collision: [mem 0xdd000000-0xdd03ffff pref] conflicts with 0000:02:00.0 [mem 0xdd000000-0xdd03ffff pref]
Apr 10 14:42:15.956946 [    1.127870] pci 0000:00:01.0: PCI bridge to [bus 01]
Apr 10 14:42:15.964995 [    1.133417] pci 0000:00:01.0:   bridge window [io  0xf000-0xffff]
Apr 10 14:42:15.972843 [    1.140225] pci 0000:00:01.0:   bridge window [mem 0xdc000000-0xdcffffff]
Apr 10 14:42:15.972901 [    1.147803] pci 0000:00:03.0: PCI bridge to [bus 08]
Apr 10 14:42:15.981020 [    1.153356] pci 0000:00:11.0: PCI bridge to [bus 09]
Apr 10 14:42:15.989028 [    1.158912] pci 0000:00:1c.0: PCI bridge to [bus 0a]
Apr 10 14:42:15.996938 [    1.164470] pci 0000:02:00.1: BAR 6: assigned [mem 0xd9000000-0xd903ffff pref]
Apr 10 14:42:16.004822 [    1.172539] pci 0000:00:1c.4: PCI bridge to [bus 02]
Apr 10 14:42:16.004847 [    1.178079] pci 0000:00:1c.4:   bridge window [mem 0xdd000000-0xdd7fffff]
Apr 10 14:42:16.012889 [    1.185665] pci 0000:00:1c.4:   bridge window [mem 0xd9000000-0xd90fffff 64bit pref]
Apr 10 14:42:16.020856 [    1.194318] pci 0000:05:00.0: PCI bridge to [bus 06]
Apr 10 14:42:16.028815 [    1.200002] pci 0000:05:00.0:   bridge window [mem 0xdd800000-0xde7fffff]
Apr 10 14:42:16.036887 [    1.207674] pci 0000:05:00.0:   bridge window [mem 0xd8000000-0xd8ffffff 64bit pref]
Apr 10 14:42:16.044918 [    1.216515] pci 0000:04:00.0: PCI bridge to [bus 05-06]
Apr 10 14:42:16.052805 [    1.222491] pci 0000:04:00.0:   bridge window [mem 0xdd800000-0xde7fffff]
Apr 10 14:42:16.060795 [    1.230168] pci 0000:04:00.0:   bridge window [mem 0xd8000000-0xd8ffffff 64bit pref]
Apr 10 14:42:16.068812 [    1.239012] pci 0000:04:01.0: PCI bridge to [bus 07]
Apr 10 14:42:16.076810 [    1.244701] pci 0000:04:01.0:   bridge window [mem 0xdef00000-0xdeffffff]
Apr 10 14:42:16.084820 [    1.252637] pci 0000:03:00.0: PCI bridge to [bus 04-07]
Apr 10 14:42:16.084891 [    1.258607] pci 0000:03:00.0:   bridge window [mem 0xdd800000-0xdeffffff]
Apr 10 14:42:16.092822 [    1.266273] pci 0000:03:00.0:   bridge window [mem 0xd8000000-0xd8ffffff 64bit pref]
Apr 10 14:42:16.100801 [    1.275162] pci 0000:00:1c.7: PCI bridge to [bus 03-07]
Apr 10 14:42:16.108785 [    1.281005] pci 0000:00:1c.7:   bridge window [mem 0xdd800000-0xdeffffff]
Apr 10 14:42:16.116800 [    1.288594] pci 0000:00:1c.7:   bridge window [mem 0xd8000000-0xd8ffffff 64bit pref]
Apr 10 14:42:16.124824 [    1.297253] pci 0000:00:1e.0: PCI bridge to [bus 0b]
Apr 10 14:42:16.132764 [    1.302973] NET: Registered protocol family 2
Apr 10 14:42:16.132786 [    1.308165] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
Apr 10 14:42:16.148815 [    1.316064] TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
Apr 10 14:42:16.148862 [    1.323280] TCP: Hash tables configured (established 8192 bind 8192)
Apr 10 14:42:16.156792 [    1.330403] TCP: reno registered
Apr 10 14:42:16.164771 [    1.334015] UDP hash table entries: 512 (order: 2, 16384 bytes)
Apr 10 14:42:16.172805 [    1.340636] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
Apr 10 14:42:16.172845 [    1.347815] NET: Registered protocol family 1
Apr 10 14:42:16.180830 [    1.352838] RPC: Registered named UNIX socket transport module.
Apr 10 14:42:16.188816 [    1.359467] RPC: Registered udp transport module.
Apr 10 14:42:16.196783 [    1.364725] RPC: Registered tcp transport module.
Apr 10 14:42:16.196820 [    1.369985] RPC: Registered tcp NFSv4.1 backchannel transport module.
Apr 10 14:42:16.204781 [    1.389953] Unpacking initramfs...
Apr 10 14:42:16.220784 [    1.930842] Freeing initrd memory: 15436K (f61ca000 - f70dd000)
Apr 10 14:42:16.764884 [    1.937459] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Apr 10 14:42:16.772944 [    1.944659] software IO TLB [mem 0x2dbca000-0x31bca000] (64MB) mapped at [edbca000-f1bc9fff]
Apr 10 14:42:16.780986 [    1.954690] kvm: already loaded the other module
Apr 10 14:42:16.788940 [    1.960551] microcode: CPU0 sig=0x306e4, pf=0x8, revision=0x427
Apr 10 14:42:16.796945 [    1.967172] microcode: CPU1 sig=0x306e4, pf=0x8, revision=0x427
Apr 10 14:42:16.804958 [    1.973790] microcode: CPU2 sig=0x306e4, pf=0x8, revision=0x427
Apr 10 14:42:16.804993 [    1.980414] microcode: CPU3 sig=0x306e4, pf=0x8, revision=0x427
Apr 10 14:42:16.812928 [    1.987100] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
Apr 10 14:42:16.828900 [    1.997547] Scanning for low memory corruption every 60 seconds
Apr 10 14:42:16.828924 [    2.005008] futex hash table entries: 2048 (order: 5, 131072 bytes)
Apr 10 14:42:16.836962 [    2.012084] audit: initializing netlink subsys (disabled)
Apr 10 14:42:16.844930 [    2.018136] audit: type=2000 audit(1428676934.384:1): initialized
Apr 10 14:42:16.852880 [    2.055186] bounce pool size: 64 pages
Apr 10 14:42:16.884843 [    2.059381] HugeTLB registered 2 MB page size, pre-allocated 0 pages
Apr 10 14:42:16.892901 [    2.070788] VFS: Disk quotas dquot_6.5.2
Apr 10 14:42:16.900916 [    2.075280] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
Apr 10 14:42:16.908936 [    2.083208] NFS: Registering the id_resolver key type
Apr 10 14:42:16.916922 [    2.088863] Key type id_resolver registered
Apr 10 14:42:16.924921 [    2.093537] Key type id_legacy registered
Apr 10 14:42:16.924941 [    2.098102] msgmni has been set to 1482
Apr 10 14:42:16.932924 [    2.102992] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
Apr 10 14:42:16.940922 [    2.111258] io scheduler noop registered
Apr 10 14:42:16.940942 [    2.115640] io scheduler deadline registered
Apr 10 14:42:16.948942 [    2.120549] io scheduler cfq registered (default)
Apr 10 14:42:16.956827 [    2.134825] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
Apr 10 14:42:16.972911 [    2.141346] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
Apr 10 14:42:16.980883 [    2.149613] ACPI: Power Button [PWRF]
Apr 10 14:42:16.980902 [    2.154788] xenfs: not registering filesystem on non-xen platform
Apr 10 14:42:16.988906 [    2.161767] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
Apr 10 14:42:16.996904 Apr 10 14:42:16.996919 <Modem lines changed: -DSR>
[    2.189422] 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a
Apr 10 14:42:17.020954 <Modem lines changed: +DSR>
 16550A
Apr 10 14:42:17.028901 [    2.218294] 00:05: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
Apr 10 14:42:17.052932 [    2.227299] Non-volatile memory driver v1.3
Apr 10 14:42:17.061013 [    2.233698] loop: module loaded
Apr 10 14:42:17.068837 [    2.237664] nbd: registered device at major 43
Apr 10 14:42:17.068878 [    2.256437] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 3 Gbps 0x1f impl SATA mode
Apr 10 14:42:17.092895 [    2.265578] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems apst 
Apr 10 14:42:17.100868 [    2.283638] scsi0 : ahci
Apr 10 14:42:17.116984 [    2.286715] scsi1 : ahci
Apr 10 14:42:17.117008 [    2.289742] scsi2 : ahci
Apr 10 14:42:17.117023 [    2.292761] scsi3 : ahci
Apr 10 14:42:17.124922 [    2.295780] scsi4 : ahci
Apr 10 14:42:17.124941 [    2.298803] scsi5 : ahci
Apr 10 14:42:17.132907 [    2.301765] ata1: SATA max UDMA/133 abar m2048@0xdf0ff000 port 0xdf0ff100 irq 81
Apr 10 14:42:17.140925 [    2.310030] ata2: SATA max UDMA/133 abar m2048@0xdf0ff000 port 0xdf0ff180 irq 81
Apr 10 14:42:17.148913 [    2.318293] ata3: SATA max UDMA/133 abar m2048@0xdf0ff000 port 0xdf0ff200 irq 81
Apr 10 14:42:17.156928 [    2.326557] ata4: SATA max UDMA/133 abar m2048@0xdf0ff000 port 0xdf0ff280 irq 81
Apr 10 14:42:17.164939 [    2.334812] ata5: SATA max UDMA/133 abar m2048@0xdf0ff000 port 0xdf0ff300 irq 81
Apr 10 14:42:17.172956 [    2.343076] ata6: DUMMY
Apr 10 14:42:17.172995 [    2.346445] tun: Universal TUN/TAP device driver, 1.6
Apr 10 14:42:17.180887 [    2.352098] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
Apr 10 14:42:17.188918 [    2.359229] tg3.c:v3.136 (Jan 03, 2014)
Apr 10 14:42:17.188943 [    2.370112] tg3 0000:02:00.0 eth0: Tigon3 [partno(BCM95720) rev 5720000] (PCI Express) MAC address b0:83:fe:db:b6:69
Apr 10 14:42:17.212836 [    2.381874] tg3 0000:02:00.0 eth0: attached PHY is 5720C (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[1])
Apr 10 14:42:17.220919 [    2.392855] tg3 0000:02:00.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
Apr 10 14:42:17.228818 [    2.401595] tg3 0000:02:00.0 eth0: dma_rwctrl[00000001] dma_mask[64-bit]
Apr 10 14:42:17.236802 [    2.426525] tg3 0000:02:00.1 eth1: Tigon3 [partno(BCM95720) rev 5720000] (PCI Express) MAC address b0:83:fe:db:b6:6a
Apr 10 14:42:17.268819 [    2.438285] tg3 0000:02:00.1 eth1: attached PHY is 5720C (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[1])
Apr 10 14:42:17.276831 [    2.449266] tg3 0000:02:00.1 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
Apr 10 14:42:17.284824 [    2.458014] tg3 0000:02:00.1 eth1: dma_rwctrl[00000001] dma_mask[64-bit]
Apr 10 14:42:17.292787 [    2.465673] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
Apr 10 14:42:17.300818 [    2.472482] e100: Copyright(c) 1999-2006 Intel Corporation
Apr 10 14:42:17.308821 [    2.478697] sky2: driver version 1.30
Apr 10 14:42:17.308842 [    2.483428] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Apr 10 14:42:17.316812 [    2.490726] ehci-pci: EHCI PCI platform driver
Apr 10 14:42:17.324812 [    2.496013] ehci-pci 0000:00:1a.0: EHCI Host Controller
Apr 10 14:42:17.332816 [    2.502039] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
Apr 10 14:42:17.340886 [    2.510320] ehci-pci 0000:00:1a.0: debug port 2
Apr 10 14:42:17.340908 [    2.519310] ehci-pci 0000:00:1a.0: irq 23, io mem 0xdf0fd000
Apr 10 14:42:17.356782 [    2.531611] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
Apr 10 14:42:17.364851 [    2.538083] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
Apr 10 14:42:17.372887 [    2.545661] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Apr 10 14:42:17.380812 [    2.553733] usb usb1: Product: EHCI Host Controller
Apr 10 14:42:17.388828 [    2.559184] usb usb1: Manufacturer: Linux 3.14.34+ ehci_hcd
Apr 10 14:42:17.396873 [    2.565412] usb usb1: SerialNumber: 0000:00:1a.0
Apr 10 14:42:17.396893 [    2.570929] hub 1-0:1.0: USB hub found
Apr 10 14:42:17.404779 [    2.575128] hub 1-0:1.0: 2 ports detected
Apr 10 14:42:17.404800 [    2.579998] ehci-pci 0000:00:1d.0: EHCI Host Controller
Apr 10 14:42:17.412821 [    2.586070] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
Apr 10 14:42:17.420803 [    2.594348] ehci-pci 0000:00:1d.0: debug port 2
Apr 10 14:42:17.428807 [    2.603329] ehci-pci 0000:00:1d.0: irq 22, io mem 0xdf0fe000
Apr 10 14:42:17.436820 [    2.614677] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
Apr 10 14:42:17.452870 [    2.621140] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
Apr 10 14:42:17.452919 [    2.628728] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Apr 10 14:42:17.460970 [    2.636800] usb usb2: Product: EHCI Host Controller
Apr 10 14:42:17.468970 [    2.642252] usb usb2: Manufacturer: Linux 3.14.34+ ehci_hcd
Apr 10 14:42:17.476970 [    2.648481] usb usb2: SerialNumber: 0000:00:1d.0
Apr 10 14:42:17.484891 [    2.650745] ata2: SATA link down (SStatus 0 SControl 300)
Apr 10 14:42:17.484937 [    2.650777] ata1: SATA link down (SStatus 0 SControl 300)
Apr 10 14:42:17.492844 [    2.650808] ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
Apr 10 14:42:17.500845 [    2.650841] ata3: SATA link down (SStatus 0 SControl 300)
Apr 10 14:42:17.508844 [    2.650869] ata4: SATA link down (SStatus 0 SControl 300)
Apr 10 14:42:17.508884 [    2.653564] ata5.00: ATAPI: HL-DT-ST DVD-ROM DTA0N, D3B0, max UDMA/100
Apr 10 14:42:17.516838 [    2.655744] ata5.00: configured for UDMA/100
Apr 10 14:42:17.524852 [    2.659757] scsi 4:0:0:0: CD-ROM            HL-DT-ST DVD-ROM DTA0N    D3B0 PQ: 0 ANSI: 5
Apr 10 14:42:17.532829 [    2.706064] hub 2-0:1.0: USB hub found
Apr 10 14:42:17.540812 [    2.709170] sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
Apr 10 14:42:17.548820 [    2.709173] cdrom: Uniform CD-ROM driver Revision: 3.20
Apr 10 14:42:17.548860 [    2.709713] sr 4:0:0:0: Attached scsi generic sg0 type 5
Apr 10 14:42:17.556806 [    2.728925] hub 2-0:1.0: 2 ports detected
Apr 10 14:42:17.564831 [    2.733636] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
Apr 10 14:42:17.564892 [    2.740549] ohci-pci: OHCI PCI platform driver
Apr 10 14:42:17.572827 [    2.745661] uhci_hcd: USB Universal Host Controller Interface driver
Apr 10 14:42:17.580834 [    2.752967] usbcore: registered new interface driver usblp
Apr 10 14:42:17.588823 [    2.759260] usbcore: registered new interface driver usb-storage
Apr 10 14:42:17.596823 [    2.766257] i8042: PNP: No PS/2 controller found. Probing ports directly.
Apr 10 14:42:17.604798 [    2.961962] tsc: Refined TSC clocksource calibration: 2400.001 MHz
Apr 10 14:42:17.796821 [    3.811176] i8042: No controller found
Apr 10 14:42:18.644776 [    3.815479] mousedev: PS/2 mouse device common for all mice
Apr 10 14:42:18.644805 [    3.821941] rtc_cmos 00:03: RTC can wake from S4
Apr 10 14:42:18.652870 [    3.827271] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
Apr 10 14:42:18.660840 [    3.834104] rtc_cmos 00:03: alarms up to one day, y3k, 242 bytes nvram, hpet irqs
Apr 10 14:42:18.668769 [    3.842681] device-mapper: uevent: version 1.0.3
Apr 10 14:42:18.676796 [    3.847973] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
Apr 10 14:42:18.684853 [    3.857489] hidraw: raw HID events driver (C) Jiri Kosina
Apr 10 14:42:18.692857 [    3.864214] usbcore: registered new interface driver usbhid
Apr 10 14:42:18.700892 [    3.870437] usbhid: USB HID core driver
Apr 10 14:42:18.700911 [    3.875226] Netfilter messages via NETLINK v0.30.
Apr 10 14:42:18.708844 [    3.880493] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
Apr 10 14:42:18.716762 [    3.887475] ctnetlink v0.93: registering with nfnetlink.
Apr 10 14:42:18.716783 [    3.893485] ip_tables: (C) 2000-2006 Netfilter Core Team
Apr 10 14:42:18.724820 [    3.899441] TCP: cubic registered
Apr 10 14:42:18.732852 [    3.903140] Initializing XFRM netlink socket
Apr 10 14:42:18.732872 [    3.908138] NET: Registered protocol family 10
Apr 10 14:42:18.740831 [    3.913340] ip6_tables: (C) 2000-2006 Netfilter Core Team
Apr 10 14:42:18.748854 [    3.916717] usb 1-1: new high-speed USB device number 2 using ehci-pci
Apr 10 14:42:18.756933 [    3.926699] sit: IPv6 over IPv4 tunneling driver
Apr 10 14:42:18.756971 [    3.932086] NET: Registered protocol family 17
Apr 10 14:42:18.764936 [    3.937071] Key type dns_resolver registered
Apr 10 14:42:18.764972 [    3.942248] Using IPI No-Shortcut mode
Apr 10 14:42:18.772794 [    3.946621] registered taskstats version 1
Apr 10 14:42:18.780911 [    3.953840]   Magic number: 11:905:737
Apr 10 14:42:18.780965 [    3.958064] console [netcon0] enabled
Apr 10 14:42:18.788993 [    3.962154] netconsole: network logging started
Apr 10 14:42:18.797063 [    3.967249] ALSA device list:
Apr 10 14:42:18.797113 [    3.970565]   No soundcards found
Apr 10 14:42:18.797168 <Modem lines changed: +CTS>
.
Apr 10 14:42:18.804801 [    3.974481] Switched to clocksource tsc
Apr 10 14:42:18.804837 [    3.978908] Freeing unused kernel memory: 676K (c1941000 - c19ea000)
Apr 10 14:42:18.812875 [    3.986061] Write protecting the kernel text: 6940k
Apr 10 14:42:18.820808 [    3.991567] Write protecting the kernel read-only data: 2072k
Apr 10 14:42:18.820849 [    3.997984] NX-protecting the kernel data: 3300k
Apr 10 14:42:18.828835 Loading, please wait...
Apr 10 14:42:18.828853 [    4.012072] udevd[1149]: starting version 175
Apr 10 14:42:18.844823 [    4.031102] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
Apr 10 14:42:18.868831 [    4.038585] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
Apr 10 14:42:18.876774 [    4.041936] megasas: 06.700.06.00-rc1 Sat. Aug. 31 17:00:00 PDT 2013
Apr 10 14:42:18.876826 [    4.041953] megasas: 0x1000:0x0073:0x1028:0x1f51: bus 1:slot 0:func 0
Apr 10 14:42:18.884830 [    4.055760] megasas: FW now in Ready state
Apr 10 14:42:18.892759 [    4.055793] megaraid_sas 0000:01:00.0: [scsi6]: FW supports<0> MSIX vector,Online CPUs: <4>,Current MSIX <1>
Apr 10 14:42:18.900812 [    4.077498] hub 1-1:1.0: USB hub found
Apr 10 14:42:18.908829 [    4.082014] hub 1-1:1.0: 6 ports detected
Apr 10 14:42:18.916736 [    4.160915] megasas_init_mfi: fw_support_ieee=67108864
Apr 10 14:42:18.996818 [    4.166461] megasas: INIT adapter done
Apr 10 14:42:18.996860 [    4.188945] usb 2-1: new high-speed USB device number 2 using ehci-pci
Apr 10 14:42:19.020981 [    4.232965] megaraid_sas 0000:01:00.0: Controller type: iMR
Apr 10 14:42:19.068767 [    4.239203] scsi6 : LSI SAS based MegaRAID driver
Apr 10 14:42:19.068809 [    4.246050] scsi 6:0:0:0: Direct-Access     ATA      TOSHIBA MG03ACA1 FL1D PQ: 0 ANSI: 5
Apr 10 14:42:19.084818 [    4.255231] sd 6:0:0:0: Attached scsi generic sg1 type 0
Apr 10 14:42:19.084848 [    4.262659] sd 6:0:0:0: [sda] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
Apr 10 14:42:19.100757 [    4.294906] scsi 6:0:32:0: Enclosure         DP       BP12G+           1.00 PQ: 0 ANSI: 5
Apr 10 14:42:19.132852 [    4.304156] scsi 6:0:32:0: Attached scsi generic sg2 type 13
Apr 10 14:42:19.140939 [    4.310317] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
Apr 10 14:42:19.140984 [    4.310318] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
Apr 10 14:42:19.148834 [    4.310460] hub 2-1:1.0: USB hub found
Apr 10 14:42:19.156849 [    4.310564] hub 2-1:1.0: 8 ports detected
Apr 10 14:42:19.164753 [    4.357287] sd 6:0:0:0: [sda] Write Protect is off
Apr 10 14:42:19.188820 [    4.364226] sd 6:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Apr 10 14:42:19.196827 [    4.385127] usb 1-1.6: new high-speed USB device number 3 using ehci-pci
Apr 10 14:42:19.220785 [    4.459083]  sda: sda1 sda2 < sda5 >
Apr 10 14:42:19.292804 [    4.478328] usb 1-1.6: New USB device found, idVendor=0624, idProduct=0248
Apr 10 14:42:19.308825 [    4.486023] usb 1-1.6: New USB device strings: Mfr=1, Product=2, SerialNumber=3
Apr 10 14:42:19.316930 [    4.494195] usb 1-1.6: Product: Gadget USB HUB
Apr 10 14:42:19.324993 [    4.499164] usb 1-1.6: Manufacturer: no manufacturer
Apr 10 14:42:19.332988 [    4.504715] usb 1-1.6: SerialNumber: 0123456789
Apr 10 14:42:19.333024 [    4.510162] hub 1-1.6:1.0: USB hub found
Apr 10 14:42:19.340855 [    4.514728] hub 1-1.6:1.0: 6 ports detected
Apr 10 14:42:19.348773 [    4.533688] sd 6:0:0:0: [sda] Attached SCSI disk
Apr 10 14:42:19.364900 [    4.803664] usb 1-1.6.1: new high-speed USB device number 4 using ehci-pci
Apr 10 14:42:19.636857 Begin: Loading essential drivers ... done.
Apr 10 14:42:19.676953 Begin: Running /scripts/init-premount ... done.
Apr 10 14:42:19.684891 Begin: Mounting roo[    4.859290] random: lvm urandom read with 93 bits of entropy available
Apr 10 14:42:19.692871 t file system ... Begin: Running /scripts/local-top ... [    4.896403] usb 1-1.6.1: New USB device found, idVendor=0624, idProduct=0249
Apr 10 14:42:19.732882 [    4.904288] usb 1-1.6.1: New USB device strings: Mfr=4, Product=5, SerialNumber=6
Apr 10 14:42:19.740927 [    4.912654] usb 1-1.6.1: Product: Keyboard/Mouse Function
Apr 10 14:42:19.740982 [    4.918692] usb 1-1.6.1: Manufacturer: Avocent
Apr 10 14:42:19.748828 [    4.923660] usb 1-1.6.1: SerialNumber: 20120917
Apr 10 14:42:19.756788 [    4.934569] input: Avocent Keyboard/Mouse Function as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.6/1-1.6.1/1-1.6.1:1.0/0003:0624:0249.0001/input/input1
Apr 10 14:42:19.772790 [    4.950188] hid-generic 0003:0624:0249.0001: input,hidraw0: USB HID v1.00 Keyboard [Avocent Keyboard/Mouse Function] on usb-0000:00:1a.0-1.6.1/input0
Apr 10 14:42:19.788784 [    4.966137] input: Avocent Keyboard/Mouse Function as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.6/1-1.6.1/1-1.6.1:1.1/0003:0624:0249.0002/input/input2
Apr 10 14:42:19.804833 [    4.981730] hid-generic 0003:0624:0249.0002: input,hidraw1: USB HID v1.00 Mouse [Avocent Keyboard/Mouse Function] on usb-0000:00:1a.0-1.6.1/input1
Apr 10 14:42:19.820763 [    4.997389] input: Avocent Keyboard/Mouse Function as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.6/1-1.6.1/1-1.6.1:1.2/0003:0624:0249.0003/input/input3
Apr 10 14:42:19.836750 [    5.013042] hid-generic 0003:0624:0249.0003: input,hidraw2: USB HID v1.00 Mouse [Avocent Keyboard/Mouse Function] on usb-0000:00:1a.0-1.6.1/input2
Apr 10 14:42:19.852797 [    5.017967] bio: create slab <bio-1> at 1
Apr 10 14:42:19.860753 [    5.060159] random: nonblocking pool is initialized
Apr 10 14:42:19.892748 done.
Apr 10 14:42:20.228799 Begin: Running /scripts/local-pr[    5.427892] PM: Starting manual resume from disk
Apr 10 14:42:20.260820 emount ... done.
Apr 10 14:42:20.268768 [    5.458247] EXT4-fs (dm-0): mounting ext3 file system using the ext4 subsystem
Apr 10 14:42:20.292829 [    5.481575] EXT4-fs (dm-0): mounted filesystem with ordered data mode. Opts: (null)
Apr 10 14:42:20.316825 Begin: Running /scripts/local-bottom ... done.
Apr 10 14:42:20.316861 done.
Apr 10 14:42:20.324776 Begin: Running /scripts/init-bottom ... done.
Apr 10 14:42:20.348805 SELinux:  Could not open policy file <= /etc/selinux/targeted/policy/policy.29:  No such file or directory
Apr 10 14:42:20.556846 Apr 10 14:42:20.556876 <Modem lines changed: -CTS -DSR>
INIT: version 2.88 booting
Apr 10 14:42:20.572847 Using makefile-style concurrent boot in runlevel S.
Apr 10 14:42:20.788829 Apr 10 14:42:20.788851 <Modem lines changed: +CTS +DSR>
Starting the hotplug events dispatcher: udevd[    6.233533] udevd[1543]: starting version 175
Apr 10 14:42:21.060808 .
Apr 10 14:42:21.060827 Synthesizing the initial hotplug events...done.
Apr 10 14:42:21.100751 Waiting for /dev to be fully populated...done.
Apr 10 14:42:21.644825 Setting preliminary keymap...done.
Apr 10 14:42:22.044838 Setting up LVM Volume Groups...done.
Apr 10 14:42:22.548867 [    7.742454] EXT4-fs (dm-0): re-mounted. Opts: (null)
Apr 10 14:42:22.572821 Checking root file system...fsck from util-linux 2.20.1
Apr 10 14:42:22.604813 /dev/mapper/elbling1-root: clean, 38131/610800 files, 378748/244[    8.132117] EXT4-fs (dm-0): re-mounted. Opts: errors=remount-ro
Apr 10 14:42:22.964842 1216 blocks
Apr 10 14:42:22.964894 done.
Apr 10 14:42:22.964928 Loading kernel module loop.
Apr 10 14:42:23.052850 Cleaning up temporary files... /tmp.
Apr 10 14:42:23.092830 Activating lvm and md swap...[    8.615295] Adding 1949692k swap on /dev/mapper/elbling1-swap_1.  Priority:-1 extents:1 across:1949692k 
Apr 10 14:42:23.452783 done.
Apr 10 14:42:23.452836 Checking file systems...fsck from util-linux 2.20.1
Apr 10 14:42:23.476844 /dev/sda1: clean, 249/73152 files, 77293/291840 blocks
Apr 10 14:42:23.604845 done.
Apr 10 14:42:23.604881 Mounting local filesystems...[    8.924949] EXT4-fs (sda1): mounting ext3 file system using the ext4 subsystem
Apr 10 14:42:23.756803 [    8.943101] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
Apr 10 14:42:23.772814 done.
Apr 10 14:42:23.780772 Activating swapfile swap...done.
Apr 10 14:42:23.812802 Cleaning up temporary files....
Apr 10 14:42:23.892809 Setting kernel variables ...done.
Apr 10 14:42:23.932818 Configuring network interfaces...[    9.356191] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Apr 10 14:42:24.188775 done.
Apr 10 14:42:24.252844 Starting rpcbind daemon....
Apr 10 14:42:24.404814 Starting NFS common utilities: statd idmapd.
Apr 10 14:42:24.612768 Cleaning up temporary files....
Apr 10 14:42:24.644783 Setting console screen modes.
Apr 10 14:42:24.684817 setterm: cannot (un)set powersave mode: Inappropriate ioctl for device
Apr 10 14:42:24.740791 Skipping font and keymap setup (handled by console-setup).
Apr 10 14:42:24.748841 Setting up console font and keymap...done.
Apr 10 14:42:24.900820 Setting up X socket directories... /tmp/.X11-unix /tmp/.ICE-unix.
Apr 10 14:42:24.916859 INIT: Entering runlevel: 2
Apr 10 14:42:24.940801 Using makefile-style concurrent boot in runlevel 2.
Apr 10 14:42:24.948819 Starting rpcbind daemon...Already running..
Apr 10 14:42:24.988796 Starting NFS common utilities: statd idmapd.
Apr 10 14:42:25.004894 Starting enhanced syslogd: rsyslogd.
Apr 10 14:42:25.084871 Starting ACPI services....
Apr 10 14:42:25.204800 Starting web server: apache2.
Apr 10 14:42:25.372878 Starting deferred execution scheduler: atd.
Apr 10 14:42:25.508951 Starting periodic command scheduler: cron.
Apr 10 14:42:25.644872 Starting system message bus: dbus.
Apr 10 14:42:26.028886 Starting OpenBSD Secure Shell server: sshd.
Apr 10 14:42:26.181455 Starting libvirt management daemon: libvirtd2015-04-10 14:42:23.749+0000: 3251: info : libvirt version: 1.2.15
Apr 10 14:42:26.300832 2015-04-10 14:42:23.749+0000: 3251: debug : virLogParseOutputs:1091 : outputs=1:file:/var/log/libvirt/libvirtd.log
Apr 10 14:42:26.316787 .
Apr 10 14:42:26.316815 [   11.593825] device virbr0-nic entered promiscuous mode
Apr 10 14:42:26.420797 [   11.627339] device virbr0-nic left promiscuous mode
Apr 10 14:42:26.452820 [   11.632803] virbr0: port 1(virbr0-nic) entered disabled state
Apr 10 14:42:26.460811 [   12.802428] tg3 0000:02:00.0 eth0: Link is up at 1000 Mbps, full duplex
Apr 10 14:42:27.628845 [   12.809825] tg3 0000:02:00.0 eth0: Flow control is off for TX and off for RX
Apr 10 14:42:27.636826 [   12.817702] tg3 0000:02:00.0 eth0: EEE is disabled
Apr 10 14:42:27.644861 [   12.823072] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Apr 10 14:42:27.652892 Starting MTA:Starting NTP server: ntpd exim4.
Apr 10 14:44:26.332848 .
Apr 10 14:44:26.356753 
Apr 10 14:44:27.412811 Debian GNU/Linux 7 elbling1 ttyS0
Apr 10 14:44:27.412856 
Apr 10 14:44:27.412879 elbling1 login: INIT: Id "xc" respawning too fast: disabled for 5 minutes
Apr 10 14:46:06.432849 root
Apr 10 14:46:53.044848 Password: 
Apr 10 14:46:54.284821 Last login: Fri Apr 10 15:26:40 BST 2015 from 172.16.144.1 on pts/1
Apr 10 14:46:54.388869 Linux elbling1 3.14.34+ #1 SMP Fri Apr 10 13:31:52 BST 2015 i686
Apr 10 14:46:54.396829 
Apr 10 14:46:54.396867 The programs included with the Debian GNU/Linux system are free software;
Apr 10 14:46:54.404834 the exact distribution terms for each program are described in the
Apr 10 14:46:54.412821 individual files in /usr/share/doc/*/copyright.
Apr 10 14:46:54.412874 
Apr 10 14:46:54.412904 Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
Apr 10 14:46:54.420822 permitted by applicable law.
Apr 10 14:46:54.420868 root@elbling1:~# tcpdump -pvvs500 -lnieth0
Apr 10 14:47:08.884804 tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 500 bytes
Apr 10 14:47:08.956806 15:47:07.380420 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 172.16.144.3 tell 172.16.144.31, length 28
Apr 10 14:47:09.852879 15:47:07.380644 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:09.860807 15:47:08.383020 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 172.16.144.3 tell 172.16.144.31, length 28
Apr 10 14:47:10.852839 15:47:08.383232 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:10.860863 15:47:09.000124 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:11.468814 15:47:09.385022 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 172.16.144.3 tell 172.16.144.31, length 28
Apr 10 14:47:11.852881 15:47:09.385335 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:11.868866 15:47:09.996916 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:12.468852 15:47:10.968963 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:13.436835 15:47:10.996922 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:13.468791 15:47:11.665913 cc:cc:cc:cc:cc:cc > cc:cc:cc:cc:cc:cc, ethertype Unknown (0xcccc), length 60: 
Apr 10 14:47:14.132879 	0x0000:  cccc cccc cccc cccc cccc cccc cccc cccc  ................
Apr 10 14:47:14.140858 	0x0010:  cccc cccc cccc cccc cccc cccc cccc cccc  ................
Apr 10 14:47:14.148875 	0x0020:  cccc cccc cccc cccc cccc cccc cccc       ..............
Apr 10 14:47:14.156796 15:47:11.968945 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:14.436888 15:47:11.997044 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:47:14.468805 ^C
Apr 10 14:47:15.124888 13 packets captured
Apr 10 14:47:15.124927 13 packets received by filter
Apr 10 14:47:15.124955 0 packets dropped by kernel
Apr 10 14:47:15.132847 root@elbling1:~# 
Apr 10 14:47:29.236816 root@elbling1:~# tcpdump -pvvs500 -lnieth0
Apr 10 14:48:28.756854 tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 500 bytes
Apr 10 14:48:28.780857 15:48:26.398823 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 84
Apr 10 14:48:28.868859 15:48:26.789310 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:48:29.260843 15:48:27.398734 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 84
Apr 10 14:48:29.868967 15:48:27.513706 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:48:29.980841 15:48:27.789337 00:00:01:00:00:00 > ec:95:d0:69:03:00, ethertype Unknown (0x9907), length 60: 
Apr 10 14:48:30.260840 	0x0000:  0000 0000 0000 0000 0000 000d 79f7 000d  ............y...
Apr 10 14:48:30.260890 	0x0010:  79f7 14ac 50ed 40bf 6ec1 303f 93f6 4600  y...P.@.n.0?..F.
Apr 10 14:48:30.268836 	0x0020:  0000 0000 0000 0100 0400 8006 0000       ..............
Apr 10 14:48:30.276784 15:48:28.088081 cc:cc:cc:cc:cc:cc > cc:cc:cc:cc:cc:cc, ethertype Unknown (0xcccc), length 60: 
Apr 10 14:48:30.556846 	0x0000:  cccc cccc cccc cccc cccc cccc cccc cccc  ................
Apr 10 14:48:30.564817 	0x0010:  cccc cccc cccc cccc cccc cccc cccc cccc  ................
Apr 10 14:48:30.572795 	0x0020:  cccc cccc cccc cccc cccc cccc cccc       ..............
Apr 10 14:48:30.572834 15:48:28.398750 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 84
Apr 10 14:48:30.868865 15:48:28.410921 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:48:30.884783 15:48:28.789491 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:48:31.260781 15:48:29.085326 00:00:00:00:00:00 > 00:00:00:00:00:00 Null Information, send seq 0, rcv seq 0, Flags [Command], length 46
Apr 10 14:48:31.556831 ^C
Apr 10 14:48:31.572803 10 packets captured
Apr 10 14:48:31.572837 10 packets received by filter
Apr 10 14:48:31.572868 0 packets dropped by kernel
Apr 10 14:48:31.580753 root@elbling1:~# tail /var/log/kern.log 
Apr 10 14:49:20.700859 Apr 10 15:42:22 elbling1 kernel: [    9.236588] tg3 0000:02:00.0: irq 86 for MSI/MSI-X
Apr 10 14:49:20.708893 Apr 10 15:42:22 elbling1 kernel: [    9.236600] tg3 0000:02:00.0: irq 87 for MSI/MSI-X
Apr 10 14:49:20.716811 Apr 10 15:42:22 elbling1 kernel: [    9.356191] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Apr 10 14:49:20.724828 Apr 10 15:42:23 elbling1 kernel: [   11.593825] device virbr0-nic entered promiscuous mode
Apr 10 14:49:20.732820 Apr 10 15:42:23 elbling1 kernel: [   11.627339] device virbr0-nic left promiscuous mode
Apr 10 14:49:20.748797 Apr 10 15:42:23 elbling1 kernel: [   11.632803] virbr0: port 1(virbr0-nic) entered disabled state
Apr 10 14:49:20.756816 Apr 10 15:42:25 elbling1 kernel: [   12.802428] tg3 0000:02:00.0 eth0: Link is up at 1000 Mbps, full duplex
Apr 10 14:49:20.764831 Apr 10 15:42:25 elbling1 kernel: [   12.809825] tg3 0000:02:00.0 eth0: Flow control is off for TX and off for RX
Apr 10 14:49:20.772809 Apr 10 15:42:25 elbling1 kernel: [   12.817702] tg3 0000:02:00.0 eth0: EEE is disabled
Apr 10 14:49:20.780836 Apr 10 15:42:25 elbling1 kernel: [   12.823072] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Apr 10 14:49:20.796787 root@elbling1:~# tail /var/log/debug 
Apr 10 14:49:24.444842 Apr 10 15:42:22 elbling1 kernel: [    4.362648] sd 6:0:0:0: [sda] Mode Sense: 73 00 00 08
Apr 10 14:49:24.452803 Apr 10 15:42:22 elbling1 kernel: [    5.434267] PM: Hibernation image partition 253:1 present
Apr 10 14:49:24.460816 Apr 10 15:42:22 elbling1 kernel: [    5.434270] PM: Looking for hibernation image.
Apr 10 14:49:24.468820 Apr 10 15:42:22 elbling1 kernel: [    5.444900] PM: Image not found (code -22)
Apr 10 14:49:24.476805 Apr 10 15:42:22 elbling1 kernel: [    5.444905] PM: Hibernation image not present or could not be loaded.
Apr 10 14:49:24.484818 Apr 10 15:42:22 elbling1 kernel: [    9.236550] tg3 0000:02:00.0: irq 83 for MSI/MSI-X
Apr 10 14:49:24.500863 Apr 10 15:42:22 elbling1 kernel: [    9.236565] tg3 0000:02:00.0: irq 84 for MSI/MSI-X
Apr 10 14:49:24.508808 Apr 10 15:42:22 elbling1 kernel: [    9.236577] tg3 0000:02:00.0: irq 85 for MSI/MSI-X
Apr 10 14:49:24.516813 Apr 10 15:42:22 elbling1 kernel: [    9.236588] tg3 0000:02:00.0: irq 86 for MSI/MSI-X
Apr 10 14:49:24.524810 Apr 10 15:42:22 elbling1 kernel: [    9.236600] tg3 0000:02:00.0: irq 87 for MSI/MSI-X

Also:

root@elbling1:~# ethtool -S eth0 | grep -v ': 0$'
NIC statistics:
     rx_octets: 352487
     rx_ucast_packets: 250
     rx_mcast_packets: 1165
     rx_bcast_packets: 1806
     tx_octets: 15848
     tx_mcast_packets: 8
     tx_bcast_packets: 237
root@elbling1:~# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr b0:83:fe:db:b6:69
          inet addr:172.16.144.31  Bcast:172.16.147.255
          Mask:255.255.252.0
          inet6 addr: fe80::b283:feff:fedb:b669/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:3245 errors:0 dropped:223 overruns:0 frame:0
          TX packets:245 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:355364 (347.0 KiB)  TX bytes:15848 (15.4 KiB)
          Interrupt:16

root@elbling1:~#
