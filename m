From: Brad Campbell <lists2009@fnarfbargle.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Mon, 22 Aug 2011 19:45:21 +0800
Message-ID: <4E524151.2060907@fnarfbargle.com>
References: <20110601011527.GN19505@random.random>	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>	 <4DEB3AE4.8040700@redhat.com>  <4DEB8872.2060801@fnarfbargle.com>	 <1307391746.2642.11.camel@edumazet-laptop>	 <4DEE273F.7090402@fnarfbargle.com>	 <1307453874.3091.14.camel@edumazet-laptop>	 <4E4FB3B7.4040501@fnarfbargle.com>  <4E51F8D4.5070804@redhat.com> <1313995503.2598.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, CaT <cat@zip.com.au>,
	Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fnarfbargle.com ([93.93.131.224]:52377 "EHLO fnarfbargle.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751086Ab1HVLpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 07:45:54 -0400
In-Reply-To: <1313995503.2598.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/08/11 14:45, Eric Dumazet wrote:
> Le lundi 22 ao=C3=BBt 2011 =C3=A0 09:36 +0300, Avi Kivity a =C3=A9cri=
t :
>> On 08/20/2011 04:16 PM, Brad Campbell wrote:
>>> Author: Alexander Duyck<alexander.h.duyck@intel.com>
>>> Date:   Thu Jul 1 13:28:27 2010 +0000
>>>
>>>      x86: Drop CONFIG_MCORE2 check around setting of NET_IP_ALIGN
>>>
>>>      This patch removes the CONFIG_MCORE2 check from around
>>> NET_IP_ALIGN.  It is
>>>      based on a suggestion from Andi Kleen.  The assumption is that
>>> there are
>>>      not any x86 cores where unaligned access is really slow, and t=
his
>>> change
>>>      would allow for a performance improvement to still exist on
>>> configurations
>>>      that are not necessarily optimized for Core 2.
>>>
>>>      Cc: Andi Kleen<ak@linux.intel.com>
>>>      Cc: Thomas Gleixner<tglx@linutronix.de>
>>>      Cc: Ingo Molnar<mingo@redhat.com>
>>>      Cc: "H. Peter Anvin"<hpa@zytor.com>
>>>      Cc: x86@kernel.org
>>>      Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>>>      Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>>      Acked-by: H. Peter Anvin<hpa@zytor.com>
>>>      Signed-off-by: David S. Miller<davem@davemloft.net>
>>>
>>> :040000 040000 5a15867789080a2f67a74b17c4422f85b7a9fb4a
>>> b98769348bd765731ca3ff03b33764257e23226c M    arch
>>>
>>> I can confirm this bug exists in the 3.0 kernel, however I'm unable=
 to
>>> reproduce it on todays git.
>>>
>>> So anyone using netfilter, kvm and bridge on kernels between
>>> 2.6.36-rc1 and 3.0 may hit this bug, but it looks like it is fixed =
in
>>> the current 3.1-rc kernels.
>>>
>>
>> Thanks for this effort.  I don't think this patch is buggy in itself=
, it
>> merely exposed another bug which was fixed later on.
>>
>
> Some piece of hardware has a 2-byte offset requirement, and driver
> incorrectly assumed NET_IP_ALIGN was 2 on x86.
>
> Brad, could you post your config (lsmod, dmesg) again ?
>
> tg3.c code for example uses a private value, not related to NET_IP_AL=
IGN
>
> #define TG3_RAW_IP_ALIGN 2

Both sets of hardware were using Marvell 88e1116 chips (the r8169 drive=
r).

Interestingly on the hardware I just used to reproduce the fault the=20
network path is VM1 -> br1 -> eth0 -> DNAT -> br1 -> VM2

On the machine that originally exhibited the fault the network path was
VM1 -> br1 -> ppp0 -> DNAT -> br1 -> VM2

So on the original machine the packet never even goes near a physical=20
interface.

The problem only exhibited itself if I tried to use the address of eth0=
=20
or ppp0 to get to VM2 from VM1. If I went dirctly from VM1 to VM2 using=
=20
local addresses and never traversed netfilter it never paniced.

I also agree the patch I identified simply unmasked an underlying issue=
,=20
and of course on anything later than the linus 3.0 kernel I can't=20
reproduce it now anyway.

It's nice to know its fixed, but it'd be nice to know *what* fixed it=20
rather than it just went away after some code re-factoring.

I did have a perverse thought about doing a bisect between 3.0.0 and=20
3.1-rc2 to see precisely *what* fixed the problem, but the thought of=20
another 7 hours of crash and burn is not overly appealing.

[    0.000000] Linux version 3.0.0 (brad@srv) (gcc version 4.4.5 (Debia=
n=20
4.4.5-8) ) #5 SMP Mon Jul 25 22:43:34 WST 2011
[    0.000000] Command line: BOOT_IMAGE=3D/bzImage=20
root=3DUUID=3D9162858d-df5e-43d6-8331-6d2b65082b4c ro panic=3D5=20
netconsole=3D6666@192.168.2.1/eth0,5050@192.168.2.87/00:16:cb:a7:dd:d1
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009c400 (usable)
[    0.000000]  BIOS-e820: 000000000009c400 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000dbf80000 (usable)
[    0.000000]  BIOS-e820: 00000000dbf80000 - 00000000dffa0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000dffa0000 - 00000000dffb0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 00000000dffb0000 - 00000000dffe0000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 00000000dffe0000 - 00000000e0000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000000420000000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI present.
[    0.000000] DMI: To Be Filled By O.E.M. To Be Filled By O.E.M./880G=20
Extreme3, BIOS P1.70 06/21/2010
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000=20
(usable) =3D=3D> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000=20
(usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn =3D 0x420000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask FFFF80000000 write-back
[    0.000000]   1 base 000080000000 mask FFFFC0000000 write-back
[    0.000000]   2 base 0000C0000000 mask FFFFE0000000 write-back
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] TOM2: 0000000420000000 aka 16896M
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new=20
0x7010600070106
[    0.000000] e820 update range: 00000000e0000000 - 0000000100000000=20
(usable) =3D=3D> (reserved)
[    0.000000] last_pfn =3D 0xdbf80 max_arch_pfn =3D 0x400000000
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] Base memory trampoline at [ffff88000009a000] 9a000 size =
8192
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: 0000000000000000-00000000dbf80000
[    0.000000]  0000000000 - 00c0000000 page 1G
[    0.000000]  00c0000000 - 00dbe00000 page 2M
[    0.000000]  00dbe00000 - 00dbf80000 page 4k
[    0.000000] kernel direct mapping tables up to dbf80000 @=20
dbf7d000-dbf80000
[    0.000000] init_memory_mapping: 0000000100000000-0000000420000000
[    0.000000]  0100000000 - 0400000000 page 1G
[    0.000000]  0400000000 - 0420000000 page 2M
[    0.000000] kernel direct mapping tables up to 420000000 @=20
41fffe000-420000000
[    0.000000] RAMDISK: 37cd8000 - 37ff0000
[    0.000000] ACPI: RSDP 00000000000fa940 00014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 00000000dffa0000 00044 (v01 062110 RSDT2249=20
20100621 MSFT 00000097)
[    0.000000] ACPI: FACP 00000000dffa0200 00084 (v01 A_M_I  OEMFACP=20
12000601 MSFT 00000097)
[    0.000000] ACPI: DSDT 00000000dffa0450 07D9F (v01  AS368 AS368164=20
00000164 INTL 20051117)
[    0.000000] ACPI: FACS 00000000dffb0000 00040
[    0.000000] ACPI: APIC 00000000dffa0390 0007C (v01 062110 APIC2249=20
20100621 MSFT 00000097)
[    0.000000] ACPI: MCFG 00000000dffa0410 0003C (v01 062110 OEMMCFG=20
20100621 MSFT 00000097)
[    0.000000] ACPI: OEMB 00000000dffb0040 00072 (v01 062110 OEMB2249=20
20100621 MSFT 00000097)
[    0.000000] ACPI: SRAT 00000000dffaa450 00108 (v03 AMD    FAM_F_10=20
00000002 AMD  00000001)
[    0.000000] ACPI: AAFT 00000000dffaa560 00027 (v01 062110 OEMAAFT=20
20100621 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000dffaa590 00038 (v01 062110 OEMHPET=20
20100621 MSFT 00000097)
[    0.000000] ACPI: SSDT 00000000dffaa5d0 00DA4 (v01 A M I  POWERNOW=20
00000001 AMD  00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000]  [ffffea0000000000-ffffea000e7fffff] PMD ->=20
[ffff88040f600000-ffff88041d7fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00420000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009c
[    0.000000]     0: 0x00000100 -> 0x000dbf80
[    0.000000]     0: 0x00100000 -> 0x00420000
[    0.000000] On node 0 totalpages: 4177676
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 2 pages reserved
[    0.000000]   DMA zone: 3922 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 882616 pages, LIFO batch:31
[    0.000000]   Normal zone: 44800 pages used for memmap
[    0.000000]   Normal zone: 3232000 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] enabled)
[    0.000000] ACPI: IOAPIC (id[0x06] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 6, version 33, address 0xfec00000, GS=
I=20
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low leve=
l)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8300 base: 0xfed00000
[    0.000000] SMP: Allowing 6 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] Allocating PCI resources starting at e0000000 (gap:=20
e0000000:1ff00000)
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:6=20
nr_node_ids:1
[    0.000000] PERCPU: Embedded 24 pages/cpu @ffff88041fc00000 s69248=20
r8192 d20864 u262144
[    0.000000] pcpu-alloc: s69248 r8192 d20864 u262144 alloc=3D1*209715=
2
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 - -
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.=20
Total pages: 4118538
[    0.000000] Kernel command line: BOOT_IMAGE=3D/bzImage=20
root=3DUUID=3D9162858d-df5e-43d6-8331-6d2b65082b4c ro panic=3D5=20
netconsole=3D6666@192.168.2.1/eth0,5050@192.168.2.87/00:16:cb:a7:dd:d1
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 2097152 (order: 12,=20
16777216 bytes)
[    0.000000] Inode-cache hash table entries: 1048576 (order: 11,=20
8388608 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Node 0: aperture @ d21e000000 size 32 MB
[    0.000000] Aperture beyond 4GB. Ignoring.
[    0.000000] Your BIOS doesn't leave a aperture memory hole
[    0.000000] Please enable the IOMMU option in the BIOS setup
[    0.000000] This costs you 64 MB of RAM
[    0.000000] Mapping aperture over 65536 KB of RAM @ d0000000
[    0.000000] Memory: 16310976k/17301504k available (4036k kernel code=
,=20
590800k absent, 399728k reserved, 2027k data, 468k init)
[    0.000000] SLUB: Genslabs=3D15, HWalign=3D64, Order=3D0-3, MinObjec=
ts=3D0,=20
CPUs=3D6, Nodes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:512
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 3213.157 MHz processor.
[    0.000003] Calibrating delay loop (skipped), value calculated using=
=20
timer frequency.. 6426.31 BogoMIPS (lpj=3D32131570)
[    0.000064] pid_max: default: 32768 minimum: 301
[    0.000126] Mount-cache hash table entries: 256
[    0.000267] tseg: 0000000000
[    0.000272] CPU: Physical Processor ID: 0
[    0.000304] CPU: Processor Core ID: 0
[    0.000334] mce: CPU supports 6 MCE banks
[    0.000420] Freeing SMP alternatives: 20k freed
[    0.000456] ACPI: Core revision 20110413
[    0.012256] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin=
2=3D-1
[    0.112297] CPU0: AMD Phenom(tm) II X6 1090T Processor stepping 00
[    0.120000] Performance Events: AMD PMU driver.
[    0.120000] ... version:                0
[    0.120000] ... bit width:              48
[    0.120000] ... generic registers:      4
[    0.120000] ... value mask:             0000ffffffffffff
[    0.120000] ... max period:             00007fffffffffff
[    0.120000] ... fixed-purpose events:   0
[    0.120000] ... event mask:             000000000000000f
[    0.120000] Booting Node   0, Processors  #1
[    0.120000] smpboot cpu 1: start_ip =3D 9a000
[    0.280028]  #2
[    0.280056] smpboot cpu 2: start_ip =3D 9a000
[    0.450026]  #3
[    0.450054] smpboot cpu 3: start_ip =3D 9a000
[    0.620025]  #4
[    0.620066] smpboot cpu 4: start_ip =3D 9a000
[    0.790027]  #5 Ok.
[    0.790057] smpboot cpu 5: start_ip =3D 9a000
[    0.960003] Brought up 6 CPUs
[    0.960033] Total of 6 processors activated (38560.60 BogoMIPS).
[    0.963391] devtmpfs: initialized
[    0.963391] xor: automatically using best checksumming function:=20
generic_sse
[    1.009895]    generic_sse: 14408.400 MB/sec
[    1.009928] xor: using function: generic_sse (14408.400 MB/sec)
[    1.010040] NET: Registered protocol family 16
[    1.010079] node 0 link 0: io port [1000, ffffff]
[    1.010079] TOM: 00000000e0000000 aka 3584M
[    1.010079] Fam 10h mmconf [e0000000, efffffff]
[    1.010079] node 0 link 0: mmio [a0000, bffff]
[    1.010079] node 0 link 0: mmio [e0000000, efffffff] =3D=3D> none
[    1.010079] node 0 link 0: mmio [f0000000, fe1fffff]
[    1.010079] node 0 link 0: mmio [fe200000, fe3fffff]
[    1.010079] node 0 link 0: mmio [fe400000, ffefffff]
[    1.010079] TOM2: 0000000420000000 aka 16896M
[    1.010079] bus: [00, 07] on node 0 link 0
[    1.010079] bus: 00 index 0 [io  0x0000-0xffff]
[    1.010080] bus: 00 index 1 [mem 0x000a0000-0x000bffff]
[    1.010081] bus: 00 index 2 [mem 0xf0000000-0xffffffff]
[    1.010082] bus: 00 index 3 [mem 0x420000000-0xfcffffffff]
[    1.010089] Extended Config Space enabled on 1 nodes
[    1.010151] ACPI: bus type pci registered
[    1.010185] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem=20
0xe0000000-0xefffffff] (base 0xe0000000)
[    1.010185] PCI: not using MMCONFIG
[    1.010185] PCI: Using configuration type 1 for base access
[    1.010185] PCI: Using configuration type 1 for extended access
[    1.010185] bio: create slab <bio-0> at 0
[    1.179907] raid6: int64x1   3168 MB/s
[    1.349907] raid6: int64x2   4039 MB/s
[    1.519903] raid6: int64x4   3205 MB/s
[    1.689900] raid6: int64x8   3017 MB/s
[    1.859895] raid6: sse2x1    4891 MB/s
[    2.029898] raid6: sse2x2    7971 MB/s
[    2.199900] raid6: sse2x4    9353 MB/s
[    2.199934] raid6: using algorithm sse2x4 (9353 MB/s)
[    2.200432] ACPI: EC: Look up EC in DSDT
[    2.200983] ACPI: Executed 4 blocks of module-level executable AML c=
ode
[    2.230239] ACPI: Interpreter enabled
[    2.230271] ACPI: (supports S0 S5)
[    2.230358] ACPI: Using IOAPIC for interrupt routing
[    2.230475] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem=20
0xe0000000-0xefffffff] (base 0xe0000000)
[    2.231052] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in=
=20
ACPI motherboard resources
[    2.245403] ACPI: No dock devices found.
[    2.245403] PCI: Using host bridge windows from ACPI; if necessary,=20
use "pci=3Dnocrs" and report a bug
[    2.245403] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    2.245403] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0c=
f7]
[    2.245403] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xff=
ff]
[    2.245403] pci_root PNP0A03:00: host bridge window [mem=20
0x000a0000-0x000bffff]
[    2.245403] pci_root PNP0A03:00: host bridge window [mem=20
0x000d0000-0x000dffff]
[    2.245403] pci_root PNP0A03:00: host bridge window [mem=20
0xf0000000-0xfebfffff]
[    2.245403] pci_root PNP0A03:00: address space collision: host bridg=
e=20
window [mem 0x000d0000-0x000dffff] conflicts with Adapter ROM [mem=20
0x000cf000-0x000d53ff]
[    2.245403] pci 0000:00:00.0: [1022:9601] type 0 class 0x000600
[    2.245403] pci 0000:00:01.0: [1849:9602] type 1 class 0x000604
[    2.245403] pci 0000:00:02.0: [1022:9603] type 1 class 0x000604
[    2.245403] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    2.245403] pci 0000:00:02.0: PME# disabled
[    2.245403] pci 0000:00:03.0: [1022:960b] type 1 class 0x000604
[    2.245403] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    2.245403] pci 0000:00:03.0: PME# disabled
[    2.245403] pci 0000:00:04.0: [1022:9604] type 1 class 0x000604
[    2.245403] pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
[    2.245403] pci 0000:00:04.0: PME# disabled
[    2.245403] pci 0000:00:09.0: [1022:9608] type 1 class 0x000604
[    2.245403] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
[    2.245403] pci 0000:00:09.0: PME# disabled
[    2.245403] pci 0000:00:0a.0: [1022:9609] type 1 class 0x000604
[    2.245403] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
[    2.245403] pci 0000:00:0a.0: PME# disabled
[    2.245403] pci 0000:00:11.0: [1002:4391] type 0 class 0x000106
[    2.245403] pci 0000:00:11.0: reg 10: [io  0x9000-0x9007]
[    2.245403] pci 0000:00:11.0: reg 14: [io  0x8000-0x8003]
[    2.245403] pci 0000:00:11.0: reg 18: [io  0x7000-0x7007]
[    2.245403] pci 0000:00:11.0: reg 1c: [io  0x6000-0x6003]
[    2.245403] pci 0000:00:11.0: reg 20: [io  0x5000-0x500f]
[    2.245403] pci 0000:00:11.0: reg 24: [mem 0xfe1ffc00-0xfe1fffff]
[    2.245403] pci 0000:00:12.0: [1002:4397] type 0 class 0x000c03
[    2.245403] pci 0000:00:12.0: reg 10: [mem 0xfe1fe000-0xfe1fefff]
[    2.245403] pci 0000:00:12.2: [1002:4396] type 0 class 0x000c03
[    2.245403] pci 0000:00:12.2: reg 10: [mem 0xfe1ff800-0xfe1ff8ff]
[    2.245403] pci 0000:00:12.2: supports D1 D2
[    2.245403] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    2.245403] pci 0000:00:12.2: PME# disabled
[    2.245403] pci 0000:00:13.0: [1002:4397] type 0 class 0x000c03
[    2.245403] pci 0000:00:13.0: reg 10: [mem 0xfe1fd000-0xfe1fdfff]
[    2.245403] pci 0000:00:13.2: [1002:4396] type 0 class 0x000c03
[    2.245403] pci 0000:00:13.2: reg 10: [mem 0xfe1ff400-0xfe1ff4ff]
[    2.245403] pci 0000:00:13.2: supports D1 D2
[    2.245403] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    2.245403] pci 0000:00:13.2: PME# disabled
[    2.245403] pci 0000:00:14.0: [1002:4385] type 0 class 0x000c05
[    2.245403] pci 0000:00:14.2: [1002:4383] type 0 class 0x000403
[    2.245403] pci 0000:00:14.2: reg 10: [mem 0xfe1f8000-0xfe1fbfff 64b=
it]
[    2.245403] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
[    2.245403] pci 0000:00:14.2: PME# disabled
[    2.245403] pci 0000:00:14.3: [1002:439d] type 0 class 0x000601
[    2.245403] pci 0000:00:14.4: [1002:4384] type 1 class 0x000604
[    2.245403] pci 0000:00:14.5: [1002:4399] type 0 class 0x000c03
[    2.245403] pci 0000:00:14.5: reg 10: [mem 0xfe1fc000-0xfe1fcfff]
[    2.245403] pci 0000:00:16.0: [1002:4397] type 0 class 0x000c03
[    2.245403] pci 0000:00:16.0: reg 10: [mem 0xfe1f7000-0xfe1f7fff]
[    2.245403] pci 0000:00:16.2: [1002:4396] type 0 class 0x000c03
[    2.245403] pci 0000:00:16.2: reg 10: [mem 0xfe1ff000-0xfe1ff0ff]
[    2.245403] pci 0000:00:16.2: supports D1 D2
[    2.245403] pci 0000:00:16.2: PME# supported from D0 D1 D2 D3hot
[    2.245403] pci 0000:00:16.2: PME# disabled
[    2.245403] pci 0000:00:18.0: [1022:1200] type 0 class 0x000600
[    2.245403] pci 0000:00:18.1: [1022:1201] type 0 class 0x000600
[    2.245403] pci 0000:00:18.2: [1022:1202] type 0 class 0x000600
[    2.245403] pci 0000:00:18.3: [1022:1203] type 0 class 0x000600
[    2.250003] pci 0000:00:18.4: [1022:1204] type 0 class 0x000600
[    2.250040] pci 0000:01:05.0: [1002:9715] type 0 class 0x000300
[    2.250046] pci 0000:01:05.0: reg 10: [mem 0xf0000000-0xf7ffffff pre=
f]
[    2.250050] pci 0000:01:05.0: reg 14: [io  0xa000-0xa0ff]
[    2.250054] pci 0000:01:05.0: reg 18: [mem 0xfe3f0000-0xfe3fffff]
[    2.250061] pci 0000:01:05.0: reg 24: [mem 0xfe200000-0xfe2fffff]
[    2.250070] pci 0000:01:05.0: supports D1 D2
[    2.250097] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    2.250129] pci 0000:00:01.0:   bridge window [io  0xa000-0xafff]
[    2.250131] pci 0000:00:01.0:   bridge window [mem 0xfe200000-0xfe3f=
ffff]
[    2.250134] pci 0000:00:01.0:   bridge window [mem=20
0xf0000000-0xf7ffffff 64bit pref]
[    2.250158] pci 0000:04:00.0: [1000:0073] type 0 class 0x000104
[    2.250165] pci 0000:04:00.0: reg 10: [io  0xc000-0xc0ff]
[    2.250172] pci 0000:04:00.0: reg 14: [mem 0xfe6fc000-0xfe6fffff 64b=
it]
[    2.250180] pci 0000:04:00.0: reg 1c: [mem 0xfe680000-0xfe6bffff 64b=
it]
[    2.250190] pci 0000:04:00.0: reg 30: [mem 0xfe6c0000-0xfe6dffff pre=
f]
[    2.250204] pci 0000:04:00.0: supports D1 D2
[    2.270016] pci 0000:00:02.0: PCI bridge to [bus 04-04]
[    2.270057] pci 0000:00:02.0:   bridge window [io  0xc000-0xcfff]
[    2.270059] pci 0000:00:02.0:   bridge window [mem 0xfe600000-0xfe6f=
ffff]
[    2.270062] pci 0000:00:02.0:   bridge window [mem=20
0xfff00000-0x000fffff pref] (disabled)
[    2.270088] pci 0000:05:00.0: [1000:0073] type 0 class 0x000104
[    2.270096] pci 0000:05:00.0: reg 10: [io  0xd000-0xd0ff]
[    2.270104] pci 0000:05:00.0: reg 14: [mem 0xfe7fc000-0xfe7fffff 64b=
it]
[    2.270112] pci 0000:05:00.0: reg 1c: [mem 0xfe780000-0xfe7bffff 64b=
it]
[    2.270121] pci 0000:05:00.0: reg 30: [mem 0xfe7c0000-0xfe7dffff pre=
f]
[    2.270136] pci 0000:05:00.0: supports D1 D2
[    2.290016] pci 0000:00:03.0: PCI bridge to [bus 05-05]
[    2.290054] pci 0000:00:03.0:   bridge window [io  0xd000-0xdfff]
[    2.290057] pci 0000:00:03.0:   bridge window [mem 0xfe700000-0xfe7f=
ffff]
[    2.290060] pci 0000:00:03.0:   bridge window [mem=20
0xfff00000-0x000fffff pref] (disabled)
[    2.290091] pci 0000:07:00.0: [11ab:7042] type 0 class 0x000100
[    2.290104] pci 0000:07:00.0: reg 10: [mem 0xfe900000-0xfe9fffff 64b=
it]
[    2.290110] pci 0000:07:00.0: reg 18: [io  0xe800-0xe8ff]
[    2.290133] pci 0000:07:00.0: reg 30: [mem 0xfe800000-0xfe8fffff pre=
f]
[    2.290161] pci 0000:07:00.0: disabling ASPM on pre-1.1 PCIe device.=
=20
  You can enable it with 'pcie_aspm=3Dforce'
[    2.290198] pci 0000:00:04.0: PCI bridge to [bus 07-07]
[    2.290230] pci 0000:00:04.0:   bridge window [io  0xe000-0xefff]
[    2.290232] pci 0000:00:04.0:   bridge window [mem 0xfe800000-0xfe9f=
ffff]
[    2.290235] pci 0000:00:04.0:   bridge window [mem=20
0xfff00000-0x000fffff pref] (disabled)
[    2.290264] pci 0000:02:00.0: [1033:0194] type 0 class 0x000c03
[    2.290277] pci 0000:02:00.0: reg 10: [mem 0xfe4fe000-0xfe4fffff 64b=
it]
[    2.290327] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    2.290330] pci 0000:02:00.0: PME# disabled
[    2.310021] pci 0000:00:09.0: PCI bridge to [bus 02-02]
[    2.310056] pci 0000:00:09.0:   bridge window [io  0xf000-0x0000]=20
(disabled)
[    2.310058] pci 0000:00:09.0:   bridge window [mem 0xfe400000-0xfe4f=
ffff]
[    2.310061] pci 0000:00:09.0:   bridge window [mem=20
0xfff00000-0x000fffff pref] (disabled)
[    2.310092] pci 0000:03:00.0: [10ec:8168] type 0 class 0x000200
[    2.310104] pci 0000:03:00.0: reg 10: [io  0xb800-0xb8ff]
[    2.310122] pci 0000:03:00.0: reg 18: [mem 0xfdfff000-0xfdffffff=20
64bit pref]
[    2.310134] pci 0000:03:00.0: reg 20: [mem 0xfdff8000-0xfdffbfff=20
64bit pref]
[    2.310142] pci 0000:03:00.0: reg 30: [mem 0xfe5e0000-0xfe5fffff pre=
f]
[    2.310167] pci 0000:03:00.0: supports D1 D2
[    2.310169] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    2.310172] pci 0000:03:00.0: PME# disabled
[    2.330022] pci 0000:00:0a.0: PCI bridge to [bus 03-03]
[    2.330056] pci 0000:00:0a.0:   bridge window [io  0xb000-0xbfff]
[    2.330058] pci 0000:00:0a.0:   bridge window [mem 0xfe500000-0xfe5f=
ffff]
[    2.330061] pci 0000:00:0a.0:   bridge window [mem=20
0xfdf00000-0xfdffffff 64bit pref]
[    2.330109] pci 0000:00:14.4: PCI bridge to [bus 06-06] (subtractive=
=20
decode)
[    2.330142] pci 0000:00:14.4:   bridge window [io  0xf000-0x0000]=20
(disabled)
[    2.330145] pci 0000:00:14.4:   bridge window [mem=20
0xfff00000-0x000fffff] (disabled)
[    2.330148] pci 0000:00:14.4:   bridge window [mem=20
0xfff00000-0x000fffff pref] (disabled)
[    2.330150] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7]=20
(subtractive decode)
[    2.330152] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff]=20
(subtractive decode)
[    2.330153] pci 0000:00:14.4:   bridge window [mem=20
0x000a0000-0x000bffff] (subtractive decode)
[    2.330155] pci 0000:00:14.4:   bridge window [mem=20
0xf0000000-0xfebfffff] (subtractive decode)
[    2.330168] pci_bus 0000:00: on NUMA node 0
[    2.330171] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    2.330251] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[    2.330268] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE2._PRT]
[    2.330283] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE3._PRT]
[    2.330296] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE4._PRT]
[    2.330310] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE9._PRT]
[    2.330324] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCEA._PRT]
[    2.330343] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PC._PRT]
[    2.330382]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    2.330420]  pci0000:00: ACPI _OSC request failed (AE_NOT_FOUND),=20
returned control mask: 0x1d
[    2.330453] ACPI _OSC control for PCIe not granted, disabling ASPM
[    2.330576] ACPI: PCI Interrupt Link [LNKA] (IRQs 10 11 14 15) *0
[    2.330576] ACPI: PCI Interrupt Link [LNKB] (IRQs 10 11 14 15) *0
[    2.330576] ACPI: PCI Interrupt Link [LNKC] (IRQs 10 11 14 15) *0
[    2.330763] ACPI: PCI Interrupt Link [LNKD] (IRQs 10 11 14 15) *0
[    2.331002] ACPI: PCI Interrupt Link [LNKE] (IRQs 10 11 14 15) *0
[    2.331234] ACPI: PCI Interrupt Link [LNKF] (IRQs 10 11 14 15) *0
[    2.331466] ACPI: PCI Interrupt Link [LNKG] (IRQs 10 11 14 15) *0
[    2.331698] ACPI: PCI Interrupt Link [LNKH] (IRQs 10 11 14 15) *0
[    2.331926] vgaarb: device added:=20
PCI:0000:01:05.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
[    2.331926] vgaarb: loaded
[    2.331926] vgaarb: bridge control possible 0000:01:05.0
[    2.331926] SCSI subsystem initialized
[    2.331926] libata version 3.00 loaded.
[    2.331926] PCI: Using ACPI for IRQ routing
[    2.341813] PCI: pci_cache_line_size set to 64 bytes
[    2.341867] reserve RAM buffer: 000000000009c400 - 000000000009ffff
[    2.341869] reserve RAM buffer: 00000000dbf80000 - 00000000dbffffff
[    2.341881] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    2.341881] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    2.342205] Switching to clocksource hpet
[    2.342293] pnp: PnP ACPI init
[    2.342293] ACPI: bus type pnp registered
[    2.342293] pnp 00:00: [bus 00-ff]
[    2.342293] pnp 00:00: [io  0x0cf8-0x0cff]
[    2.342293] pnp 00:00: [io  0x0000-0x0cf7 window]
[    2.342293] pnp 00:00: [io  0x0d00-0xffff window]
[    2.342293] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    2.342293] pnp 00:00: [mem 0x000d0000-0x000dffff window]
[    2.342293] pnp 00:00: [mem 0xe0000000-0xdfffffff window disabled]
[    2.342293] pnp 00:00: [mem 0xf0000000-0xfebfffff window]
[    2.342293] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (activ=
e)
[    2.342293] pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
[    2.342293] pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
[    2.342293] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    2.342293] pnp 00:02: [dma 4]
[    2.342293] pnp 00:02: [io  0x0000-0x000f]
[    2.342293] pnp 00:02: [io  0x0081-0x0083]
[    2.342293] pnp 00:02: [io  0x0087]
[    2.342293] pnp 00:02: [io  0x0089-0x008b]
[    2.342293] pnp 00:02: [io  0x008f]
[    2.342293] pnp 00:02: [io  0x00c0-0x00df]
[    2.342293] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (activ=
e)
[    2.342293] pnp 00:03: [io  0x0070-0x0071]
[    2.342293] pnp 00:03: [irq 8]
[    2.342293] pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (activ=
e)
[    2.342293] pnp 00:04: [io  0x0061]
[    2.342293] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (activ=
e)
[    2.342293] pnp 00:05: [io  0x00f0-0x00ff]
[    2.342293] pnp 00:05: [irq 13]
[    2.342293] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (activ=
e)
[    2.342293] pnp 00:06: [io  0x02f8-0x02ff]
[    2.342293] pnp 00:06: [irq 3]
[    2.342293] pnp 00:06: [dma 0 disabled]
[    2.342293] pnp 00:06: Plug and Play ACPI device, IDs PNP0510 (activ=
e)
[    2.342293] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    2.342293] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (activ=
e)
[    2.342293] pnp 00:08: [mem 0xfec00000-0xfec00fff]
[    2.342293] pnp 00:08: [mem 0xfee00000-0xfee00fff]
[    2.342293] system 00:08: [mem 0xfec00000-0xfec00fff] could not be=20
reserved
[    2.342293] system 00:08: [mem 0xfee00000-0xfee00fff] has been reser=
ved
[    2.342293] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    2.342293] pnp 00:09: [io  0x0010-0x001f]
[    2.342293] pnp 00:09: [io  0x0022-0x003f]
[    2.342293] pnp 00:09: [io  0x0062-0x0063]
[    2.342293] pnp 00:09: [io  0x0065-0x006f]
[    2.342293] pnp 00:09: [io  0x0072-0x007f]
[    2.342293] pnp 00:09: [io  0x0080]
[    2.342293] pnp 00:09: [io  0x0084-0x0086]
[    2.342293] pnp 00:09: [io  0x0088]
[    2.342293] pnp 00:09: [io  0x008c-0x008e]
[    2.342293] pnp 00:09: [io  0x0090-0x009f]
[    2.342293] pnp 00:09: [io  0x00a2-0x00bf]
[    2.342293] pnp 00:09: [io  0x00b1]
[    2.342293] pnp 00:09: [io  0x00e0-0x00ef]
[    2.342293] pnp 00:09: [io  0x04d0-0x04d1]
[    2.342293] pnp 00:09: [io  0x040b]
[    2.342293] pnp 00:09: [io  0x04d6]
[    2.342293] pnp 00:09: [io  0x0c00-0x0c01]
[    2.342293] pnp 00:09: [io  0x0c14]
[    2.342293] pnp 00:09: [io  0x0c50-0x0c51]
[    2.342293] pnp 00:09: [io  0x0c52]
[    2.342293] pnp 00:09: [io  0x0c6c]
[    2.342293] pnp 00:09: [io  0x0c6f]
[    2.342293] pnp 00:09: [io  0x0cd0-0x0cd1]
[    2.342293] pnp 00:09: [io  0x0cd2-0x0cd3]
[    2.342293] pnp 00:09: [io  0x0cd4-0x0cd5]
[    2.342293] pnp 00:09: [io  0x0cd6-0x0cd7]
[    2.342293] pnp 00:09: [io  0x0cd8-0x0cdf]
[    2.342293] pnp 00:09: [io  0x0800-0x089f]
[    2.342293] pnp 00:09: [io  0x0000-0xffffffffffffffff disabled]
[    2.342293] pnp 00:09: [io  0x0b00-0x0b1f]
[    2.342293] pnp 00:09: [io  0x0b20-0x0b3f]
[    2.342293] pnp 00:09: [io  0x0900-0x090f]
[    2.342293] pnp 00:09: [io  0x0910-0x091f]
[    2.342293] pnp 00:09: [io  0xfe00-0xfefe]
[    2.342293] pnp 00:09: [io  0x0060-0x005f disabled]
[    2.342293] pnp 00:09: [io  0x0064-0x0063 disabled]
[    2.342293] pnp 00:09: [mem 0xffb80000-0xffbfffff]
[    2.342293] pnp 00:09: [mem 0xfec10000-0xfec1001f]
[    2.342293] pnp 00:09: [mem 0xfed80000-0xfed80fff]
[    2.342293] pnp 00:09: [mem 0x00000000-0xffffffffffffffff disabled]
[    2.342293] system 00:09: [io  0x04d0-0x04d1] has been reserved
[    2.342293] system 00:09: [io  0x040b] has been reserved
[    2.342293] system 00:09: [io  0x04d6] has been reserved
[    2.342293] system 00:09: [io  0x0c00-0x0c01] has been reserved
[    2.342293] system 00:09: [io  0x0c14] has been reserved
[    2.342293] system 00:09: [io  0x0c50-0x0c51] has been reserved
[    2.342293] system 00:09: [io  0x0c52] has been reserved
[    2.342293] system 00:09: [io  0x0c6c] has been reserved
[    2.342293] system 00:09: [io  0x0c6f] has been reserved
[    2.342293] system 00:09: [io  0x0cd0-0x0cd1] has been reserved
[    2.342293] system 00:09: [io  0x0cd2-0x0cd3] has been reserved
[    2.342293] system 00:09: [io  0x0cd4-0x0cd5] has been reserved
[    2.342293] system 00:09: [io  0x0cd6-0x0cd7] has been reserved
[    2.342293] system 00:09: [io  0x0cd8-0x0cdf] has been reserved
[    2.342293] system 00:09: [io  0x0800-0x089f] has been reserved
[    2.342293] system 00:09: [io  0x0b00-0x0b1f] has been reserved
[    2.342293] system 00:09: [io  0x0b20-0x0b3f] has been reserved
[    2.342293] system 00:09: [io  0x0900-0x090f] has been reserved
[    2.342293] system 00:09: [io  0x0910-0x091f] has been reserved
[    2.342293] system 00:09: [io  0xfe00-0xfefe] has been reserved
[    2.342293] system 00:09: [mem 0xffb80000-0xffbfffff] has been reser=
ved
[    2.342293] system 00:09: [mem 0xfec10000-0xfec1001f] has been reser=
ved
[    2.342293] system 00:09: [mem 0xfed80000-0xfed80fff] has been reser=
ved
[    2.342293] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    2.342293] pnp 00:0a: [io  0x0060]
[    2.342293] pnp 00:0a: [io  0x0064]
[    2.342293] pnp 00:0a: [irq 1]
[    2.342293] pnp 00:0a: Plug and Play ACPI device, IDs PNP0303 PNP030=
b=20
(active)
[    2.342293] pnp 00:0b: [io  0x03f8-0x03ff]
[    2.342293] pnp 00:0b: [irq 4]
[    2.342293] pnp 00:0b: [dma 0 disabled]
[    2.342293] pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (activ=
e)
[    2.342316] pnp 00:0c: [io  0x0000-0xffffffffffffffff disabled]
[    2.342317] pnp 00:0c: [io  0x0000-0xffffffffffffffff disabled]
[    2.342319] pnp 00:0c: [io  0x0290-0x029f]
[    2.342365] system 00:0c: [io  0x0290-0x029f] has been reserved
[    2.342396] system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    2.342412] pnp 00:0d: [mem 0xe0000000-0xefffffff]
[    2.342457] system 00:0d: [mem 0xe0000000-0xefffffff] has been reser=
ved
[    2.342489] system 00:0d: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    2.342549] pnp 00:0e: [mem 0x00000000-0x0009ffff]
[    2.342550] pnp 00:0e: [mem 0x000c0000-0x000cffff]
[    2.342551] pnp 00:0e: [mem 0x000e0000-0x000fffff]
[    2.342553] pnp 00:0e: [mem 0x00100000-0xdfffffff]
[    2.342554] pnp 00:0e: [mem 0xfec00000-0xffffffff]
[    2.342629] system 00:0e: [mem 0x00000000-0x0009ffff] could not be=20
reserved
[    2.342660] system 00:0e: [mem 0x000c0000-0x000cffff] could not be=20
reserved
[    2.342691] system 00:0e: [mem 0x000e0000-0x000fffff] could not be=20
reserved
[    2.342723] system 00:0e: [mem 0x00100000-0xdfffffff] could not be=20
reserved
[    2.342754] system 00:0e: [mem 0xfec00000-0xffffffff] could not be=20
reserved
[    2.342785] system 00:0e: Plug and Play ACPI device, IDs PNP0c01 (ac=
tive)
[    2.342835] pnp: PnP ACPI: found 15 devices
[    2.342865] ACPI: ACPI bus type pnp unregistered
[    2.345616] Switched to NOHz mode on CPU #0
[    2.345673] Switched to NOHz mode on CPU #3
[    2.345731] Switched to NOHz mode on CPU #1
[    2.345734] Switched to NOHz mode on CPU #2
[    2.345746] Switched to NOHz mode on CPU #4
[    2.345749] Switched to NOHz mode on CPU #5
[    2.349869] PCI: max bus depth: 1 pci_try_num: 2
[    2.349888] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    2.349919] pci 0000:00:01.0:   bridge window [io  0xa000-0xafff]
[    2.349951] pci 0000:00:01.0:   bridge window [mem 0xfe200000-0xfe3f=
ffff]
[    2.349982] pci 0000:00:01.0:   bridge window [mem=20
0xf0000000-0xf7ffffff 64bit pref]
[    2.350059] pci 0000:00:02.0: PCI bridge to [bus 04-04]
[    2.350090] pci 0000:00:02.0:   bridge window [io  0xc000-0xcfff]
[    2.350122] pci 0000:00:02.0:   bridge window [mem 0xfe600000-0xfe6f=
ffff]
[    2.350153] pci 0000:00:02.0:   bridge window [mem pref disabled]
[    2.350185] pci 0000:00:03.0: PCI bridge to [bus 05-05]
[    2.350216] pci 0000:00:03.0:   bridge window [io  0xd000-0xdfff]
[    2.350249] pci 0000:00:03.0:   bridge window [mem 0xfe700000-0xfe7f=
ffff]
[    2.350280] pci 0000:00:03.0:   bridge window [mem pref disabled]
[    2.350312] pci 0000:00:04.0: PCI bridge to [bus 07-07]
[    2.350343] pci 0000:00:04.0:   bridge window [io  0xe000-0xefff]
[    2.350375] pci 0000:00:04.0:   bridge window [mem 0xfe800000-0xfe9f=
ffff]
[    2.350411] pci 0000:00:04.0:   bridge window [mem pref disabled]
[    2.350443] pci 0000:00:09.0: PCI bridge to [bus 02-02]
[    2.350473] pci 0000:00:09.0:   bridge window [io  disabled]
[    2.350504] pci 0000:00:09.0:   bridge window [mem 0xfe400000-0xfe4f=
ffff]
[    2.350535] pci 0000:00:09.0:   bridge window [mem pref disabled]
[    2.350567] pci 0000:00:0a.0: PCI bridge to [bus 03-03]
[    2.350598] pci 0000:00:0a.0:   bridge window [io  0xb000-0xbfff]
[    2.350629] pci 0000:00:0a.0:   bridge window [mem 0xfe500000-0xfe5f=
ffff]
[    2.350661] pci 0000:00:0a.0:   bridge window [mem=20
0xfdf00000-0xfdffffff 64bit pref]
[    2.350694] pci 0000:00:14.4: PCI bridge to [bus 06-06]
[    2.350724] pci 0000:00:14.4:   bridge window [io  disabled]
[    2.350757] pci 0000:00:14.4:   bridge window [mem disabled]
[    2.350789] pci 0000:00:14.4:   bridge window [mem pref disabled]
[    2.350829] pci 0000:00:02.0: PCI INT A -> GSI 18 (level, low) -> IR=
Q 18
[    2.350861] pci 0000:00:02.0: setting latency timer to 64
[    2.350865] pci 0000:00:03.0: PCI INT A -> GSI 19 (level, low) -> IR=
Q 19
[    2.350897] pci 0000:00:03.0: setting latency timer to 64
[    2.350901] pci 0000:00:04.0: PCI INT A -> GSI 16 (level, low) -> IR=
Q 16
[    2.350932] pci 0000:00:04.0: setting latency timer to 64
[    2.350936] pci 0000:00:09.0: PCI INT A -> GSI 17 (level, low) -> IR=
Q 17
[    2.350967] pci 0000:00:09.0: setting latency timer to 64
[    2.350970] pci 0000:00:0a.0: PCI INT A -> GSI 18 (level, low) -> IR=
Q 18
[    2.351001] pci 0000:00:0a.0: setting latency timer to 64
[    2.351006] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    2.351007] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    2.351009] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    2.351010] pci_bus 0000:00: resource 7 [mem 0xf0000000-0xfebfffff]
[    2.351012] pci_bus 0000:01: resource 0 [io  0xa000-0xafff]
[    2.351013] pci_bus 0000:01: resource 1 [mem 0xfe200000-0xfe3fffff]
[    2.351014] pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff=20
64bit pref]
[    2.351016] pci_bus 0000:04: resource 0 [io  0xc000-0xcfff]
[    2.351017] pci_bus 0000:04: resource 1 [mem 0xfe600000-0xfe6fffff]
[    2.351019] pci_bus 0000:05: resource 0 [io  0xd000-0xdfff]
[    2.351020] pci_bus 0000:05: resource 1 [mem 0xfe700000-0xfe7fffff]
[    2.351021] pci_bus 0000:07: resource 0 [io  0xe000-0xefff]
[    2.351023] pci_bus 0000:07: resource 1 [mem 0xfe800000-0xfe9fffff]
[    2.351024] pci_bus 0000:02: resource 1 [mem 0xfe400000-0xfe4fffff]
[    2.351025] pci_bus 0000:03: resource 0 [io  0xb000-0xbfff]
[    2.351027] pci_bus 0000:03: resource 1 [mem 0xfe500000-0xfe5fffff]
[    2.351028] pci_bus 0000:03: resource 2 [mem 0xfdf00000-0xfdffffff=20
64bit pref]
[    2.351030] pci_bus 0000:06: resource 4 [io  0x0000-0x0cf7]
[    2.351031] pci_bus 0000:06: resource 5 [io  0x0d00-0xffff]
[    2.351032] pci_bus 0000:06: resource 6 [mem 0x000a0000-0x000bffff]
[    2.351034] pci_bus 0000:06: resource 7 [mem 0xf0000000-0xfebfffff]
[    2.351057] NET: Registered protocol family 2
[    2.351135] IP route cache hash table entries: 524288 (order: 10,=20
4194304 bytes)
[    2.352087] TCP established hash table entries: 262144 (order: 10,=20
4194304 bytes)
[    2.353248] TCP bind hash table entries: 65536 (order: 8, 1048576 by=
tes)
[    2.353567] TCP: Hash tables configured (established 262144 bind 655=
36)
[    2.353601] TCP reno registered
[    2.353632] UDP hash table entries: 8192 (order: 6, 262144 bytes)
[    2.353743] UDP-Lite hash table entries: 8192 (order: 6, 262144 byte=
s)
[    2.353926] NET: Registered protocol family 1
[    2.354056] RPC: Registered named UNIX socket transport module.
[    2.354087] RPC: Registered udp transport module.
[    2.354117] RPC: Registered tcp transport module.
[    2.354147] RPC: Registered tcp NFSv4.1 backchannel transport module=
=2E
[    2.354182] pci 0000:00:01.0: MSI quirk detected; subordinate MSI=20
disabled
[    2.500089] pci 0000:01:05.0: Boot video device
[    2.500118] PCI: CLS 64 bytes, default 64
[    2.500152] Unpacking initramfs...
[    2.539130] Freeing initrd memory: 3168k freed
[    2.539863] PCI-DMA: Disabling AGP.
[    2.540036] PCI-DMA: aperture base @ d0000000 size 65536 KB
[    2.540067] PCI-DMA: using GART IOMMU.
[    2.540098] PCI-DMA: Reserving 64MB of IOMMU area in the AGP apertur=
e
[    2.574189] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    2.636100] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    2.636310] msgmni has been set to 31992
[    2.636457] Block layer SCSI generic (bsg) driver version 0.4 loaded=
=20
(major 254)
[    2.636490] io scheduler noop registered
[    2.636519] io scheduler deadline registered
[    2.636606] io scheduler cfq registered (default)
[    2.636711] pcieport 0000:00:02.0: setting latency timer to 64
[    2.636730] pcieport 0000:00:02.0: irq 40 for MSI/MSI-X
[    2.636781] pcieport 0000:00:03.0: setting latency timer to 64
[    2.636795] pcieport 0000:00:03.0: irq 41 for MSI/MSI-X
[    2.636839] pcieport 0000:00:04.0: setting latency timer to 64
[    2.636854] pcieport 0000:00:04.0: irq 42 for MSI/MSI-X
[    2.636898] pcieport 0000:00:09.0: setting latency timer to 64
[    2.636912] pcieport 0000:00:09.0: irq 43 for MSI/MSI-X
[    2.636956] pcieport 0000:00:0a.0: setting latency timer to 64
[    2.636971] pcieport 0000:00:0a.0: irq 44 for MSI/MSI-X
[    2.637246] input: Power Button as=20
/devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    2.637280] ACPI: Power Button [PWRB]
[    2.637353] input: Power Button as=20
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    2.637386] ACPI: Power Button [PWRF]
[    2.637446] ACPI: acpi_idle registered with cpuidle
[    2.658560] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.679110] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    2.699710] serial8250: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
[    2.720581] 00:0b: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    2.720829] Real Time Clock Driver v1.12b
[    2.721594] loop: module loaded
[    2.721752] tun: Universal TUN/TAP device driver, 1.6
[    2.721782] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    2.721866] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.721909] r8169 0000:03:00.0: PCI INT A -> GSI 18 (level, low) ->=20
IRQ 18
[    2.721993] r8169 0000:03:00.0: setting latency timer to 64
[    2.722028] r8169 0000:03:00.0: irq 45 for MSI/MSI-X
[    2.722217] r8169 0000:03:00.0: eth0: RTL8168e/8111e at=20
0xffffc9000000e000, 00:25:22:55:3e:2d, XID 0c100000 IRQ 45
[    2.722289] netconsole: local port 6666
[    2.722332] netconsole: local IP 192.168.2.1
[    2.722361] netconsole: interface 'eth0'
[    2.722391] netconsole: remote port 5050
[    2.722420] netconsole: remote IP 192.168.2.87
[    2.722451] netconsole: remote ethernet address 00:16:cb:a7:dd:d1
[    2.722482] netconsole: device eth0 not up yet, forcing it
[    3.540028] Refined TSC clocksource calibration: 3213.418 MHz.
[    3.540067] Switching to clocksource tsc
[   63.200106] r8169 0000:03:00.0: eth0: unable to load firmware patch=20
rtl_nic/rtl8168e-1.fw (-2)
[   63.223480] r8169 0000:03:00.0: eth0: link down
[   63.223523] r8169 0000:03:00.0: eth0: link down
[   65.179915] r8169 0000:03:00.0: eth0: link up
[   65.182530] console [netcon0] enabled
[   65.182562] netconsole: network logging started
[   65.182738] i8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 =
irq 1
[   65.182771] i8042: PNP: PS/2 appears to have AUX port disabled, if=20
this is incorrect please boot with i8042.nopnp
[   65.183304] serio: i8042 KBD port at 0x60,0x64 irq 1
[   65.183474] mousedev: PS/2 mouse device common for all mice
[   65.183532] i2c /dev entries driver
[   65.183588] md: linear personality registered for level -1
[   65.183619] md: raid0 personality registered for level 0
[   65.183651] md: raid1 personality registered for level 1
[   65.183683] md: raid10 personality registered for level 10
[   65.183714] md: raid6 personality registered for level 6
[   65.183746] md: raid5 personality registered for level 5
[   65.183779] md: raid4 personality registered for level 4
[   65.183968] device-mapper: ioctl: 4.20.0-ioctl (2011-02-02)=20
initialised: dm-devel@redhat.com
[   65.184375] cpuidle: using governor ladder
[   65.185144] cpuidle: using governor menu
[   65.185339] TCP cubic registered
[   65.185377] NET: Registered protocol family 17
[   65.185431] Bridge firewalling registered
[   65.185468] 802.1Q VLAN Support v1.8
[   65.185502] Registering the dns_resolver key type
[   65.185730] registered taskstats version 1
[   65.216255] Freeing unused kernel memory: 468k freed
[   65.226393] udev[1318]: starting version 164
[   65.237596] input: AT Translated Set 2 keyboard as=20
/devices/platform/i8042/serio0/input/input2
[   65.243627] megasas: 00.00.05.38-rc1 Wed. May. 11 17:00:00 PDT 2011
[   65.243694] megasas: 0x1000:0x0073:0x1014:0x03b1: bus 4:slot 0:func =
0
[   65.243765] megaraid_sas 0000:04:00.0: PCI INT A -> GSI 18 (level,=20
low) -> IRQ 18
[   65.243803] megaraid_sas 0000:04:00.0: setting latency timer to 64
[   65.244850] megasas: FW now in Ready state
[   65.245232] megaraid_sas 0000:04:00.0: irq 46 for MSI/MSI-X
[   65.246538] sata_mv 0000:07:00.0: version 1.28
[   65.246610] sata_mv 0000:07:00.0: PCI INT A -> GSI 16 (level, low) -=
>=20
IRQ 16
[   65.246785] sata_mv 0000:07:00.0: Gen-IIE 32 slots 4 ports SCSI mode=
=20
IRQ via INTx
[   65.246825] sata_mv 0000:07:00.0: setting latency timer to 64
[   65.247046] ahci 0000:00:11.0: version 3.0
[   65.247063] ahci 0000:00:11.0: PCI INT A -> GSI 19 (level, low) -> I=
RQ 19
[   65.247146] ahci 0000:00:11.0: irq 47 for MSI/MSI-X
[   65.247256] ahci 0000:00:11.0: AHCI 0001.0200 32 slots 6 ports 6 Gbp=
s=20
0x3f impl SATA mode
[   65.247293] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo=
=20
pmp pio slum part
[   65.247385] usbcore: registered new interface driver usbfs
[   65.247443] usbcore: registered new interface driver hub
[   65.248070] scsi1 : sata_mv
[   65.248189] usbcore: registered new device driver usb
[   65.248450] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driv=
er
[   65.248497] scsi3 : sata_mv
[   65.248728] scsi2 : ahci
[   65.249183] scsi4 : sata_mv
[   65.249270] scsi6 : sata_mv
[   65.249318] ata1: SATA max UDMA/133 mmio m1048576@0xfe900000 port=20
0xfe922000 irq 16
[   65.249354] ata2: SATA max UDMA/133 mmio m1048576@0xfe900000 port=20
0xfe924000 irq 16
[   65.249390] ata3: SATA max UDMA/133 mmio m1048576@0xfe900000 port=20
0xfe926000 irq 16
[   65.249425] ata4: SATA max UDMA/133 mmio m1048576@0xfe900000 port=20
0xfe928000 irq 16
[   65.249981] scsi5 : ahci
[   65.250068] scsi7 : ahci
[   65.250436] scsi8 : ahci
[   65.250534] scsi9 : ahci
[   65.250685] scsi10 : ahci
[   65.250746] ata5: SATA max UDMA/133 abar m1024@0xfe1ffc00 port=20
0xfe1ffd00 irq 47
[   65.250783] ata6: SATA max UDMA/133 abar m1024@0xfe1ffc00 port=20
0xfe1ffd80 irq 47
[   65.250820] ata7: SATA max UDMA/133 abar m1024@0xfe1ffc00 port=20
0xfe1ffe00 irq 47
[   65.250857] ata8: SATA max UDMA/133 abar m1024@0xfe1ffc00 port=20
0xfe1ffe80 irq 47
[   65.250895] ata9: SATA max UDMA/133 abar m1024@0xfe1ffc00 port=20
0xfe1fff00 irq 47
[   65.250933] ata10: SATA max UDMA/133 abar m1024@0xfe1ffc00 port=20
0xfe1fff80 irq 47
[   65.250996] ehci_hcd 0000:00:12.2: PCI INT B -> GSI 17 (level, low)=20
-> IRQ 17
[   65.251056] ehci_hcd 0000:00:12.2: EHCI Host Controller
[   65.251101] ehci_hcd 0000:00:12.2: new USB bus registered, assigned=20
bus number 1
[   65.251148] ehci_hcd 0000:00:12.2: applying AMD=20
SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[   65.251199] QUIRK: Enable AMD PLL fix
[   65.251208] ehci_hcd 0000:00:12.2: debug port 1
[   65.251257] ehci_hcd 0000:00:12.2: irq 17, io mem 0xfe1ff800
[   65.270037] ehci_hcd 0000:00:12.2: USB 2.0 started, EHCI 1.00
[   65.270214] hub 1-0:1.0: USB hub found
[   65.270254] hub 1-0:1.0: 5 ports detected
[   65.270351] ehci_hcd 0000:00:13.2: PCI INT B -> GSI 17 (level, low)=20
-> IRQ 17
[   65.270404] ehci_hcd 0000:00:13.2: EHCI Host Controller
[   65.270454] ehci_hcd 0000:00:13.2: new USB bus registered, assigned=20
bus number 2
[   65.270496] ehci_hcd 0000:00:13.2: applying AMD=20
SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[   65.270551] ehci_hcd 0000:00:13.2: debug port 1
[   65.270595] ehci_hcd 0000:00:13.2: irq 17, io mem 0xfe1ff400
[   65.270605] megasas_init_mfi: fw_support_ieee=3D67108864
[   65.270606] megasas: INIT adapter done
[   65.290144] ehci_hcd 0000:00:13.2: USB 2.0 started, EHCI 1.00
[   65.290258] hub 2-0:1.0: USB hub found
[   65.290292] hub 2-0:1.0: 5 ports detected
[   65.290362] ehci_hcd 0000:00:16.2: PCI INT B -> GSI 17 (level, low)=20
-> IRQ 17
[   65.290407] ehci_hcd 0000:00:16.2: EHCI Host Controller
[   65.290440] ehci_hcd 0000:00:16.2: new USB bus registered, assigned=20
bus number 3
[   65.290478] ehci_hcd 0000:00:16.2: applying AMD=20
SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[   65.290533] ehci_hcd 0000:00:16.2: debug port 1
[   65.290573] ehci_hcd 0000:00:16.2: irq 17, io mem 0xfe1ff000
[   65.320044] ehci_hcd 0000:00:16.2: USB 2.0 started, EHCI 1.00
[   65.320151] hub 3-0:1.0: USB hub found
[   65.320184] hub 3-0:1.0: 4 ports detected
[   65.348414] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   65.348479] ohci_hcd 0000:00:12.0: PCI INT A -> GSI 18 (level, low)=20
-> IRQ 18
[   65.348539] ohci_hcd 0000:00:12.0: OHCI Host Controller
[   65.348574] ohci_hcd 0000:00:12.0: new USB bus registered, assigned=20
bus number 4
[   65.348629] ohci_hcd 0000:00:12.0: irq 18, io mem 0xfe1fe000
[   65.390058] scsi0 : LSI SAS based MegaRAID driver
[   65.402010] scsi 0:0:10:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.402165] sd 0:0:10:0: Attached scsi generic sg0 type 0
[   65.404137] hub 4-0:1.0: USB hub found
[   65.404173] hub 4-0:1.0: 5 ports detected
[   65.404224] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 18 (level, low)=20
-> IRQ 18
[   65.404265] ohci_hcd 0000:00:13.0: OHCI Host Controller
[   65.404298] ohci_hcd 0000:00:13.0: new USB bus registered, assigned=20
bus number 5
[   65.404342] ohci_hcd 0000:00:13.0: irq 18, io mem 0xfe1fd000
[   65.408855] sd 0:0:10:0: [sda] physical block alignment offset: 4096
[   65.408893] sd 0:0:10:0: [sda] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.408928] sd 0:0:10:0: [sda] 4096-byte physical blocks
[   65.410683] scsi 0:0:11:0: Direct-Access     ATA      WDC=20
WD20EARS-00M AB51 PQ: 0 ANSI: 5
[   65.410807] sd 0:0:11:0: Attached scsi generic sg1 type 0
[   65.415759] sd 0:0:11:0: [sdb] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.423407] scsi 0:0:12:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.423536] sd 0:0:12:0: Attached scsi generic sg2 type 0
[   65.430537] sd 0:0:12:0: [sdc] physical block alignment offset: 4096
[   65.430574] sd 0:0:12:0: [sdc] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.430608] sd 0:0:12:0: [sdc] 4096-byte physical blocks
[   65.437120] sd 0:0:11:0: [sdb] Write Protect is off
[   65.437156] sd 0:0:11:0: [sdb] Mode Sense: 73 00 00 08
[   65.437730] sd 0:0:10:0: [sda] Write Protect is off
[   65.437766] sd 0:0:10:0: [sda] Mode Sense: 73 00 00 08
[   65.441716] scsi 0:0:13:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.441835] sd 0:0:13:0: Attached scsi generic sg3 type 0
[   65.444683] sd 0:0:11:0: [sdb] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.445330] scsi 0:0:18:0: Direct-Access     SEAGATE  ST3300655SS=20
   S515 PQ: 0 ANSI: 5
[   65.445467] sd 0:0:18:0: Attached scsi generic sg4 type 0
[   65.451625] sd 0:0:10:0: [sda] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.451711] sd 0:0:13:0: [sdd] physical block alignment offset: 4096
[   65.451747] sd 0:0:13:0: [sdd] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.451790] sd 0:0:13:0: [sdd] 4096-byte physical blocks
[   65.452285] sd 0:0:18:0: [sde] 585937500 512-byte logical blocks:=20
(300 GB/279 GiB)
[   65.453321] scsi 0:0:19:0: Direct-Access     SEAGATE  ST3300655SS=20
   A005 PQ: 0 ANSI: 5
[   65.453456] sd 0:0:19:0: Attached scsi generic sg5 type 0
[   65.458128] sd 0:0:18:0: [sde] Write Protect is off
[   65.458163] sd 0:0:18:0: [sde] Mode Sense: b3 00 10 08
[   65.459325] sd 0:0:19:0: [sdf] 585937500 512-byte logical blocks:=20
(300 GB/279 GiB)
[   65.459448] scsi 0:0:20:0: Direct-Access     SEAGATE  ST3300655SS=20
   A005 PQ: 0 ANSI: 5
[   65.459583] sd 0:0:20:0: Attached scsi generic sg6 type 0
[   65.464128] hub 5-0:1.0: USB hub found
[   65.464165] hub 5-0:1.0: 5 ports detected
[   65.464214] ohci_hcd 0000:00:14.5: PCI INT C -> GSI 18 (level, low)=20
-> IRQ 18
[   65.464255] ohci_hcd 0000:00:14.5: OHCI Host Controller
[   65.464288] ohci_hcd 0000:00:14.5: new USB bus registered, assigned=20
bus number 6
[   65.464331] ohci_hcd 0000:00:14.5: irq 18, io mem 0xfe1fc000
[   65.464611] sd 0:0:18:0: [sde] Write cache: enabled, read cache:=20
enabled, supports DPO and FUA
[   65.465337] sd 0:0:20:0: [sdg] 585937500 512-byte logical blocks:=20
(300 GB/279 GiB)
[   65.465748] scsi 0:0:21:0: Direct-Access     SEAGATE  ST3300655SS=20
   S515 PQ: 0 ANSI: 5
[   65.465906] sd 0:0:21:0: Attached scsi generic sg7 type 0
[   65.470327] sd 0:0:19:0: [sdf] Write Protect is off
[   65.470362] sd 0:0:19:0: [sdf] Mode Sense: b3 00 10 08
[   65.476731] sd 0:0:21:0: [sdh] 585937500 512-byte logical blocks:=20
(300 GB/279 GiB)
[   65.476846] sd 0:0:20:0: [sdg] Write Protect is off
[   65.476892] sd 0:0:20:0: [sdg] Mode Sense: b3 00 10 08
[   65.476916] sd 0:0:19:0: [sdf] Write cache: enabled, read cache:=20
enabled, supports DPO and FUA
[   65.482548] sd 0:0:21:0: [sdh] Write Protect is off
[   65.482586] sd 0:0:21:0: [sdh] Mode Sense: b3 00 10 08
[   65.483436] sd 0:0:20:0: [sdg] Write cache: enabled, read cache:=20
enabled, supports DPO and FUA
[   65.488248] sd 0:0:21:0: [sdh] Write cache: enabled, read cache:=20
enabled, supports DPO and FUA
[   65.494395]  sde: unknown partition table
[   65.501262]  sdb: unknown partition table
[   65.503732] sd 0:0:12:0: [sdc] Write Protect is off
[   65.503776] sd 0:0:12:0: [sdc] Mode Sense: 73 00 00 08
[   65.505389]  sdf: unknown partition table
[   65.506463] sd 0:0:18:0: [sde] Attached SCSI disk
[   65.511538]  sdh: unknown partition table
[   65.512582]  sda: unknown partition table
[   65.519104] sd 0:0:12:0: [sdc] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.521490]  sdg: unknown partition table
[   65.524125] hub 6-0:1.0: USB hub found
[   65.524162] hub 6-0:1.0: 2 ports detected
[   65.524211] ohci_hcd 0000:00:16.0: PCI INT A -> GSI 18 (level, low)=20
-> IRQ 18
[   65.524252] ohci_hcd 0000:00:16.0: OHCI Host Controller
[   65.524285] ohci_hcd 0000:00:16.0: new USB bus registered, assigned=20
bus number 7
[   65.524332] ohci_hcd 0000:00:16.0: irq 18, io mem 0xfe1f7000
[   65.526953] sd 0:0:19:0: [sdf] Attached SCSI disk
[   65.529657] sd 0:0:21:0: [sdh] Attached SCSI disk
[   65.531531] sd 0:0:13:0: [sdd] Write Protect is off
[   65.531569] sd 0:0:13:0: [sdd] Mode Sense: 73 00 00 08
[   65.532606] sd 0:0:20:0: [sdg] Attached SCSI disk
[   65.537818] megasas: 0x1000:0x0073:0x1014:0x03b1: bus 5:slot 0:func =
0
[   65.537887] megaraid_sas 0000:05:00.0: PCI INT A -> GSI 19 (level,=20
low) -> IRQ 19
[   65.537923] megaraid_sas 0000:05:00.0: setting latency timer to 64
[   65.537974] megasas: FW now in Ready state
[   65.538034] megaraid_sas 0000:05:00.0: irq 48 for MSI/MSI-X
[   65.543918] sd 0:0:13:0: [sdd] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.545106] sd 0:0:11:0: [sdb] Attached SCSI disk
[   65.560038] megasas_init_mfi: fw_support_ieee=3D67108864
[   65.560079] megasas: INIT adapter done
[   65.563406] sd 0:0:10:0: [sda] Attached SCSI disk
[   65.570045]  sdc: unknown partition table
[   65.584124] hub 7-0:1.0: USB hub found
[   65.584161] hub 7-0:1.0: 4 ports detected
[   65.593514]  sdd: unknown partition table
[   65.600047] ata9: SATA link down (SStatus 0 SControl 300)
[   65.600107] ata7: SATA link down (SStatus 0 SControl 300)
[   65.600170] ata8: SATA link down (SStatus 0 SControl 300)
[   65.600261] ata10: SATA link down (SStatus 0 SControl 300)
[   65.623341] sd 0:0:12:0: [sdc] Attached SCSI disk
[   65.642020] sd 0:0:13:0: [sdd] Attached SCSI disk
[   65.650037] scsi11 : LSI SAS based MegaRAID driver
[   65.661988] scsi 11:0:9:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.662113] sd 11:0:9:0: Attached scsi generic sg8 type 0
[   65.668949] sd 11:0:9:0: [sdi] physical block alignment offset: 4096
[   65.668986] sd 11:0:9:0: [sdi] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.669020] sd 11:0:9:0: [sdi] 4096-byte physical blocks
[   65.675059] scsi 11:0:10:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.675182] sd 11:0:10:0: Attached scsi generic sg9 type 0
[   65.681812] sd 11:0:10:0: [sdj] physical block alignment offset: 409=
6
[   65.681849] sd 11:0:10:0: [sdj] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.681884] sd 11:0:10:0: [sdj] 4096-byte physical blocks
[   65.698957] sd 11:0:9:0: [sdi] Write Protect is off
[   65.698993] sd 11:0:9:0: [sdi] Mode Sense: 73 00 00 08
[   65.709639] scsi 11:0:13:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.709759] sd 11:0:13:0: Attached scsi generic sg10 type 0
[   65.711168] sd 11:0:9:0: [sdi] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.716961] sd 11:0:13:0: [sdk] physical block alignment offset: 409=
6
[   65.716998] sd 11:0:13:0: [sdk] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.717035] sd 11:0:13:0: [sdk] 4096-byte physical blocks
[   65.742927] scsi 11:0:14:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.743040] sd 11:0:14:0: Attached scsi generic sg11 type 0
[   65.747118] sd 11:0:13:0: [sdk] Write Protect is off
[   65.747153] sd 11:0:13:0: [sdk] Mode Sense: 73 00 00 08
[   65.749113] sd 11:0:14:0: [sdl] physical block alignment offset: 409=
6
[   65.749150] sd 11:0:14:0: [sdl] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.749184] sd 11:0:14:0: [sdl] 4096-byte physical blocks
[   65.749947] sd 11:0:10:0: [sdj] Write Protect is off
[   65.749982] sd 11:0:10:0: [sdj] Mode Sense: 73 00 00 08
[   65.750068] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[   65.759269] sd 11:0:13:0: [sdk] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.759275]  sdi: unknown partition table
[   65.761631] sd 11:0:10:0: [sdj] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.777351] sd 11:0:14:0: [sdl] Write Protect is off
[   65.777386] sd 11:0:14:0: [sdl] Mode Sense: 73 00 00 08
[   65.787708] sd 11:0:14:0: [sdl] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.790285] ata1.00: ATA-8: FM-25S2S-60GBP2, 2.1, max UDMA/133
[   65.790321] ata1.00: 117231408 sectors, multi 1: LBA48 NCQ (depth 31=
/32)
[   65.800049] ata6: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[   65.800102] ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[   65.803492] scsi 11:0:15:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.803611] sd 11:0:15:0: Attached scsi generic sg12 type 0
[   65.807891] sd 11:0:9:0: [sdi] Attached SCSI disk
[   65.808134]  sdj: unknown partition table
[   65.808954] ata5.00: ATA-8: WDC WD1002FAEX-00Z3A0, 05.01D05, max UDM=
A/133
[   65.808989] ata5.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth=20
31/32), AA
[   65.809689]  sdk: unknown partition table
[   65.810820] sd 11:0:15:0: [sdm] physical block alignment offset: 409=
6
[   65.810865] sd 11:0:15:0: [sdm] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.810902] sd 11:0:15:0: [sdm] 4096-byte physical blocks
[   65.811042] ata5.00: configured for UDMA/133
[   65.812159] ata6.00: ATA-8: WDC WD1002FAEX-00Z3A0, 05.01D05, max UDM=
A/133
[   65.812194] ata6.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth=20
31/32), AA
[   65.814325] ata6.00: configured for UDMA/133
[   65.833497]  sdl: unknown partition table
[   65.841554] sd 11:0:15:0: [sdm] Write Protect is off
[   65.841590] sd 11:0:15:0: [sdm] Mode Sense: 73 00 00 08
[   65.850283] ata1.00: configured for UDMA/133
[   65.850387] scsi 1:0:0:0: Direct-Access     ATA      FM-25S2S-60GBP2=
=20
  2.1  PQ: 0 ANSI: 5
[   65.850502] sd 1:0:0:0: Attached scsi generic sg13 type 0
[   65.850529] sd 1:0:0:0: [sdn] 117231408 512-byte logical blocks:=20
(60.0 GB/55.8 GiB)
[   65.850653] sd 1:0:0:0: [sdn] Write Protect is off
[   65.850687] sd 1:0:0:0: [sdn] Mode Sense: 00 3a 00 00
[   65.850712] sd 1:0:0:0: [sdn] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.851123]  sdn: unknown partition table
[   65.851320] sd 1:0:0:0: [sdn] Attached SCSI disk
[   65.853501] sd 11:0:15:0: [sdm] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   65.853583] sd 11:0:10:0: [sdj] Attached SCSI disk
[   65.860607] sd 11:0:13:0: [sdk] Attached SCSI disk
[   65.876691] sd 11:0:14:0: [sdl] Attached SCSI disk
[   65.890059] usb 4-2: new full speed USB device number 2 using ohci_h=
cd
[   65.902817]  sdm: unknown partition table
[   65.921026] scsi 11:0:16:0: Direct-Access     ATA      WDC=20
WD20EARS-60M AB51 PQ: 0 ANSI: 5
[   65.921149] sd 11:0:16:0: Attached scsi generic sg14 type 0
[   65.928106] sd 11:0:16:0: [sdo] physical block alignment offset: 409=
6
[   65.928143] sd 11:0:16:0: [sdo] 3907029168 512-byte logical blocks:=20
(2.00 TB/1.81 TiB)
[   65.928177] sd 11:0:16:0: [sdo] 4096-byte physical blocks
[   65.953117] sd 11:0:15:0: [sdm] Attached SCSI disk
[   66.030173] sd 11:0:16:0: [sdo] Write Protect is off
[   66.030211] sd 11:0:16:0: [sdo] Mode Sense: 73 00 00 08
[   66.043679] sd 11:0:16:0: [sdo] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   66.092356]  sdo: unknown partition table
[   66.182327] sd 11:0:16:0: [sdo] Attached SCSI disk
[   66.200059] ata2: SATA link down (SStatus 0 SControl 300)
[   66.550061] ata3: SATA link down (SStatus 0 SControl 300)
[   66.900053] ata4: SATA link down (SStatus 0 SControl 300)
[   66.900198] scsi 2:0:0:0: Direct-Access     ATA      WDC WD1002FAEX-=
0=20
05.0 PQ: 0 ANSI: 5
[   66.900325] sd 2:0:0:0: [sdp] 1953525168 512-byte logical blocks:=20
(1.00 TB/931 GiB)
[   66.900327] sd 2:0:0:0: Attached scsi generic sg15 type 0
[   66.900427] scsi 5:0:0:0: Direct-Access     ATA      WDC WD1002FAEX-=
0=20
05.0 PQ: 0 ANSI: 5
[   66.900464] sd 2:0:0:0: [sdp] Write Protect is off
[   66.900467] sd 2:0:0:0: [sdp] Mode Sense: 00 3a 00 00
[   66.900491] sd 2:0:0:0: [sdp] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   66.900643] sd 5:0:0:0: [sdq] 1953525168 512-byte logical blocks:=20
(1.00 TB/931 GiB)
[   66.900645] sd 5:0:0:0: Attached scsi generic sg16 type 0
[   66.900773] sd 5:0:0:0: [sdq] Write Protect is off
[   66.900808] sd 5:0:0:0: [sdq] Mode Sense: 00 3a 00 00
[   66.900829] sd 5:0:0:0: [sdq] Write cache: enabled, read cache:=20
enabled, doesn't support DPO or FUA
[   66.904434]  sdq: sdq1 sdq2
[   66.904681] sd 5:0:0:0: [sdq] Attached SCSI disk
[   66.909577]  sdp: sdp1 sdp2
[   66.909810] sd 2:0:0:0: [sdp] Attached SCSI disk
[   67.191179] md: md1 stopped.
[   67.191764] md: bind<sdq1>
[   67.191895] md: bind<sdp1>
[   67.192591] bio: create slab <bio-1> at 1
[   67.192670] md/raid1:md1: active with 2 out of 2 mirrors
[   67.192714] md1: detected capacity change from 0 to 524222464
[   67.200588]  md1: unknown partition table
[   67.207511] md: md2 stopped.
[   67.208237] md: bind<sdq2>
[   67.209779] md: bind<sdp2>
[   67.210543] md/raid10:md2: active with 2 out of 2 devices
[   67.210673] created bitmap (8 pages) for device md2
[   67.210934] md2: bitmap initialized from disk: read 1/1 pages, set 2=
=20
of 14897 bits
[   67.219474] md2: detected capacity change from 0 to 999677755392
[   67.224116]  md2: p1 p2 p3
[   67.230750] md: md10 stopped.
[   67.244399] md: bind<sde>
[   67.244619] md: bind<sdf>
[   67.244823] md: bind<sdg>
[   67.248205] md: bind<sdh>
[   67.248955] md/raid10:md10: active with 4 out of 4 devices
[   67.252191] created bitmap (5 pages) for device md10
[   67.252505] md10: bitmap initialized from disk: read 1/1 pages, set =
0=20
of 8941 bits
[   67.264422] md10: detected capacity change from 0 to 599997284352
[   67.271735]  md10: unknown partition table
[   67.296795] md: md0 stopped.
[   67.398685] md: bind<sdd>
[   67.404514] md: bind<sdm>
[   67.404703] md: bind<sdb>
[   67.408534] md: bind<sdj>
[   67.411132] md: bind<sdi>
[   67.411724] md: bind<sdl>
[   67.430316] md: bind<sda>
[   67.430607] md: bind<sdc>
[   67.430770] md: bind<sdk>
[   67.430922] md: bind<sdo>
[   67.431657] md/raid:md0: device sdo operational as raid disk 0
[   67.431694] md/raid:md0: device sdk operational as raid disk 9
[   67.431726] md/raid:md0: device sdc operational as raid disk 8
[   67.431758] md/raid:md0: device sda operational as raid disk 7
[   67.431793] md/raid:md0: device sdl operational as raid disk 6
[   67.431824] md/raid:md0: device sdi operational as raid disk 5
[   67.431856] md/raid:md0: device sdj operational as raid disk 4
[   67.431891] md/raid:md0: device sdb operational as raid disk 3
[   67.431925] md/raid:md0: device sdm operational as raid disk 2
[   67.431956] md/raid:md0: device sdd operational as raid disk 1
[   67.432356] md/raid:md0: allocated 10572kB
[   67.432418] md/raid:md0: raid level 6 active with 10 out of 10=20
devices, algorithm 2
[   67.432457] RAID conf printout:
[   67.432458]  --- level:6 rd:10 wd:10
[   67.432459]  disk 0, o:1, dev:sdo
[   67.432461]  disk 1, o:1, dev:sdd
[   67.432462]  disk 2, o:1, dev:sdm
[   67.432463]  disk 3, o:1, dev:sdb
[   67.432463]  disk 4, o:1, dev:sdj
[   67.432464]  disk 5, o:1, dev:sdi
[   67.432465]  disk 6, o:1, dev:sdl
[   67.432466]  disk 7, o:1, dev:sda
[   67.432467]  disk 8, o:1, dev:sdc
[   67.432468]  disk 9, o:1, dev:sdk
[   67.466604] created bitmap (15 pages) for device md0
[   67.466953] md0: bitmap initialized from disk: read 1/1 pages, set 0=
=20
of 29809 bits
[   67.472708] md0: detected capacity change from 0 to 16003181314048
[   67.511792]  md0: unknown partition table
[   67.680098] EXT4-fs (md2p1): INFO: recovery required on readonly=20
filesystem
[   67.680135] EXT4-fs (md2p1): write access will be enabled during rec=
overy
[   69.810256] EXT4-fs (md2p1): recovery complete
[   69.810604] EXT4-fs (md2p1): mounted filesystem with ordered data=20
mode. Opts: (null)
[   70.548329] udev[1803]: starting version 164
[   70.676012] usbcore: registered new interface driver usbserial
[   70.676059] USB Serial support registered for generic
[   70.676103] usbcore: registered new interface driver usbserial_gener=
ic
[   70.676147] usbserial: USB Serial Driver core
[   70.683832] USB Serial support registered for pl2303
[   70.683881] pl2303 4-2:1.0: pl2303 converter detected
[   70.698118] piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00=
,=20
revision 0
[   70.701760] xhci_hcd 0000:02:00.0: PCI INT A -> GSI 17 (level, low)=20
-> IRQ 17
[   70.701834] xhci_hcd 0000:02:00.0: setting latency timer to 64
[   70.701837] xhci_hcd 0000:02:00.0: xHCI Host Controller
[   70.701877] xhci_hcd 0000:02:00.0: new USB bus registered, assigned=20
bus number 8
[   70.702046] xhci_hcd 0000:02:00.0: irq 17, io mem 0xfe4fe000
[   70.702134] xhci_hcd 0000:02:00.0: irq 49 for MSI/MSI-X
[   70.702138] xhci_hcd 0000:02:00.0: irq 50 for MSI/MSI-X
[   70.702140] xhci_hcd 0000:02:00.0: irq 51 for MSI/MSI-X
[   70.702142] xhci_hcd 0000:02:00.0: irq 52 for MSI/MSI-X
[   70.702144] xhci_hcd 0000:02:00.0: irq 53 for MSI/MSI-X
[   70.702146] xhci_hcd 0000:02:00.0: irq 54 for MSI/MSI-X
[   70.702148] xhci_hcd 0000:02:00.0: irq 55 for MSI/MSI-X
[   70.702325] xHCI xhci_add_endpoint called for root hub
[   70.702327] xHCI xhci_check_bandwidth called for root hub
[   70.702347] hub 8-0:1.0: USB hub found
[   70.702384] hub 8-0:1.0: 2 ports detected
[   70.702526] xhci_hcd 0000:02:00.0: xHCI Host Controller
[   70.702567] xhci_hcd 0000:02:00.0: new USB bus registered, assigned=20
bus number 9
[   70.704246] usb 4-2: pl2303 converter now attached to ttyUSB0
[   70.704320] usbcore: registered new interface driver pl2303
[   70.704367] pl2303: Prolific PL2303 USB to serial adaptor driver
[   70.705493] xHCI xhci_add_endpoint called for root hub
[   70.705495] xHCI xhci_check_bandwidth called for root hub
[   70.705526] hub 9-0:1.0: USB hub found
[   70.705569] hub 9-0:1.0: 2 ports detected
[   71.350688] EXT4-fs (md2p1): re-mounted. Opts: (null)
[   71.586339] EXT4-fs (md2p1): re-mounted. Opts:=20
errors=3Dremount-ro,commit=3D30
[   71.688584] kvm: Nested Virtualization enabled
[   71.688624] kvm: Nested Paging enabled
[   71.715947] powernow-k8: Found 1 AMD Phenom(tm) II X6 1090T Processo=
r=20
(6 cpu cores) (version 2.20.00)
[   71.715994] powernow-k8: Core Performance Boosting: on.
[   71.716050] powernow-k8:    0 : pstate 0 (3200 MHz)
[   71.716081] powernow-k8:    1 : pstate 1 (2400 MHz)
[   71.716112] powernow-k8:    2 : pstate 2 (1600 MHz)
[   71.716144] powernow-k8:    3 : pstate 3 (800 MHz)
[   71.741872] w83627ehf: Found NCT6775F chip at 0x290
[  113.081227] fuse init (API version 7.16)
[  113.463322] EXT4-fs (md2p3): mounted filesystem with ordered data=20
mode. Opts: commit=3D30
[  113.523249] EXT4-fs (md2p2): mounted filesystem with ordered data=20
mode. Opts: commit=3D30
[  113.603188] EXT4-fs (md10): mounted filesystem with ordered data=20
mode. Opts: commit=3D30
[  114.034563] EXT4-fs (md0): mounted filesystem with ordered data mode=
=2E=20
Opts: commit=3D30,acl
[  116.104972] Adding 20971516k swap on /raid10/SWAP/srv.swap.=20
Priority:-1 extents:13 across:22421500k
[  116.578585] NET: Registered protocol family 15
[  138.220721] device br1_dummy entered promiscuous mode
[  180.833074] u32 classifier
[  180.833129]     Actions configured
[  191.222339] PPP generic driver version 2.4.2
[  192.068503] NET: Registered protocol family 24
[  192.759974] ip_tables: (C) 2000-2006 Netfilter Core Team
[  192.772071] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[  193.055922] HTB: quantum of class 10040 is small. Consider r2q chang=
e.
[  204.360085] sshd (3856): /proc/3856/oom_adj is deprecated, please us=
e=20
/proc/3856/oom_score_adj instead.
[  212.869525] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state=20
recovery directory
[  212.875925] NFSD: starting 90-second grace period

brad@srv:~$ lsmod
Module                  Size  Used by
nfs                   294438  1
xt_length               1200  2
xt_CLASSIFY             1075  5
sch_sfq                 6676  2
xt_CHECKSUM             1213  2
iptable_mangle          1471  1
xt_TCPMSS               2551  2
ipt_REJECT              2229  1
ipt_MASQUERADE          1743  10
ipt_REDIRECT            1117  1
xt_recent               8207  2
xt_state                1210  6
xt_tcpudp               2451  28
iptable_filter          1426  1
iptable_nat             3977  1
nf_nat                 16789  3 ipt_MASQUERADE,ipt_REDIRECT,iptable_nat
nf_conntrack_ipv4      11852  9 iptable_nat,nf_nat
nf_conntrack           60821  5=20
ipt_MASQUERADE,xt_state,iptable_nat,nf_nat,nf_conntrack_ipv4
nf_defrag_ipv4          1401  1 nf_conntrack_ipv4
ip_tables              16538  3 iptable_mangle,iptable_filter,iptable_n=
at
x_tables               20342  14=20
xt_length,xt_CLASSIFY,xt_CHECKSUM,iptable_mangle,xt_TCPMSS,ipt_REJECT,i=
pt_MASQUERADE,ipt_REDIRECT,xt_recent,xt_state,xt_tcpudp,iptable_filter,=
iptable_nat,ip_tables
pppoe                   9558  2
pppox                   2156  1 pppoe
ppp_generic            24227  6 pppoe,pppox
slhc                    5277  1 ppp_generic
cls_u32                 6356  6
sch_htb                14352  2
deflate                 1921  0
zlib_deflate           21196  1 deflate
des_generic            16119  0
cbc                     2705  0
ecb                     1959  0
crypto_blkcipher       13629  2 cbc,ecb
sha1_generic            2079  0
md5                     3985  0
hmac                    2961  0
crypto_hash            14471  3 sha1_generic,md5,hmac
cryptomgr               2652  0
aead                    6121  1 cryptomgr
crypto_algapi          15273  9=20
deflate,des_generic,cbc,ecb,crypto_blkcipher,hmac,crypto_hash,cryptomgr=
,aead
af_key                 27356  0
fuse                   66684  1
w83627ehf              32036  0
hwmon_vid               2851  1 w83627ehf
vhost_net              17239  5
powernow_k8            12884  0
mperf                   1247  1 powernow_k8
kvm_amd                54109  20
kvm                   238605  1 kvm_amd
xhci_hcd               66960  0
k10temp                 3199  0
i2c_piix4               8375  0
pl2303                 12716  1
usbserial              34420  3 pl2303
ohci_hcd               17897  0
ehci_hcd               33721  0
usbcore               131192  5 xhci_hcd,pl2303,usbserial,ohci_hcd,ehci=
_hcd
ahci                   20732  4
libahci                21186  1 ahci
sata_mv                26923  0
megaraid_sas           71785  14
