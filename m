From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI Express
	devices (v2)
Date: Tue, 16 Mar 2010 17:30:53 -0600
Message-ID: <51f3faa71003161630g69160ea9tc1a2d448682632e5@mail.gmail.com>
References: <20100315150806.GA15354@Dublin.logfs.org>
	 <20100315151041.GA15667@Dublin.logfs.org>
	 <20100315.115748.13754030.davem@davemloft.net>
	 <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com>
	 <20100316083501.GA3489@Dublin.logfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@dublin.logfs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:58735 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993Ab0CPXaz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 19:30:55 -0400
In-Reply-To: <20100316083501.GA3489@Dublin.logfs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 16, 2010 at 2:35 AM, J=F6rn Engel <joern@dublin.logfs.org> =
wrote:
> On Mon, 15 March 2010 17:28:45 -0600, Robert Hancock wrote:
>>
>> What are the symptoms?
>
> No more network. :)
>
> According to ifconfig the interface is up and running. =A0If I read
> /sys/class/net/eth0 correctly, two packets have been sent and none
> received. =A0LED on network card and switch is off. =A0mii-tool is
> unhappy.
>
> With patch in:
> Bikini:~# mii-tool
> =A0No MII transceiver present!.
>
> With patch reverted:
> Bikini:~# mii-tool
> eth0: negotiated 100baseTx-FD flow-control, link ok
>
> I just noticed lspci is also unhappy.
>
> With patch in:
> Bikini:~# lspci -vv > lspci
> pcilib: sysfs_read_vpd: read failed: Connection timed out.
>
> With patch reverted:
> Bikini:~# lspci -vv > lspci2
> Bikini:~# diff -u lspci*
> --- lspci =A0 =A0 =A0 2010-03-16 09:03:02.000000000 +0100
> +++ lspci2 =A0 =A0 =A02010-03-16 09:09:36.000000000 +0100
> @@ -246,7 +246,7 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Vector table: BAR=3D4 offset=3D0000000=
0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PBA: BAR=3D4 offset=3D00000800
> =A0 =A0 =A0 =A0Capabilities: [cc] Vital Product Data
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 Not readable
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 Unknown small resource type 00, will no=
t decode more.
> =A0 =A0 =A0 =A0Capabilities: [100] Advanced Error Reporting
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UESta: =A0DLP- SDES- TLP- FCP- CmpltTO=
- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UEMsk: =A0DLP- SDES- TLP- FCP- CmpltTO=
- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>
> As you might expect, delta is part of the ethernet controller.
>
> All "With patch in" output above is typed off the screen. =A0Beware o=
f
> typos.
>
>> Does setting use_dac=3D0 in the module options
>> for r8169 also resolve the problem?
>
> /sys/modules/r8169 does not exist. =A0How odd. =A0Anyway, simply chan=
ging
> the default in r8169.c to 0 fixes the problems for me. =A0Good call.


I can't really explain how the MII and lspci output is being
affected.. However, it's possible that some of the chips supported by
this driver don't actually support 64-bit DMA. Your chip is quite a
bit older than mine (RTL8102E seems to be one of the older, if not the
oldest, PCI-E chipset supported by the driver).

=46rancois, do you know if that's the case, or do you have any active
contacts at Realtek who can say?

In the meantime, I don't object to reverting the patch for now unless
we get this sorted out quickly..

>
>> Full dmesg and lspci -vv output might also be useful.
>
> Both with patch in:
> dmesg:
> [ =A0 =A00.000000] Initializing cgroup subsys cpuset
> [ =A0 =A00.000000] Initializing cgroup subsys cpu
> [ =A0 =A00.000000] Linux version 2.6.33 (joern@Dublin) (gcc version 4=
=2E3.3 (Debian 4.3.3-3) ) #40 SMP Tue Mar 16 09:01:02 CET 2010
> [ =A0 =A00.000000] Command line: vga=3D9 root=3D/dev/sda2 loglevel=3D=
9 netconsole=3D4444@192.168.0.39/eth0,6666@192.168.0.10/00:15:58:C5:ED:=
A8 BOOT_IMAGE=3DbzImage
> [ =A0 =A00.000000] BIOS-provided physical RAM map:
> [ =A0 =A00.000000] =A0BIOS-e820: 0000000000000000 - 000000000009f800 =
(usable)
> [ =A0 =A00.000000] =A0BIOS-e820: 000000000009f800 - 00000000000a0000 =
(reserved)
> [ =A0 =A00.000000] =A0BIOS-e820: 00000000000e6000 - 0000000000100000 =
(reserved)
> [ =A0 =A00.000000] =A0BIOS-e820: 0000000000100000 - 00000000bf6b0000 =
(usable)
> [ =A0 =A00.000000] =A0BIOS-e820: 00000000bf6b0000 - 00000000bf6c0000 =
(ACPI data)
> [ =A0 =A00.000000] =A0BIOS-e820: 00000000bf6c0000 - 00000000bf6f0000 =
(ACPI NVS)
> [ =A0 =A00.000000] =A0BIOS-e820: 00000000bf6f0000 - 00000000bf700000 =
(reserved)
> [ =A0 =A00.000000] =A0BIOS-e820: 00000000fed00000 - 00000000fed00400 =
(reserved)
> [ =A0 =A00.000000] =A0BIOS-e820: 00000000fee00000 - 00000000fee01000 =
(reserved)
> [ =A0 =A00.000000] =A0BIOS-e820: 00000000ff380000 - 0000000100000000 =
(reserved)
> [ =A0 =A00.000000] =A0BIOS-e820: 0000000100000000 - 0000000140000000 =
(usable)
> [ =A0 =A00.000000] NX (Execute Disable) protection: active
> [ =A0 =A00.000000] DMI present.
> [ =A0 =A00.000000] AMI BIOS detected: BIOS may corrupt low RAM, worki=
ng around it.
> [ =A0 =A00.000000] e820 update range: 0000000000000000 - 000000000001=
0000 (usable) =3D=3D> (reserved)
> [ =A0 =A00.000000] e820 update range: 0000000000000000 - 000000000000=
1000 (usable) =3D=3D> (reserved)
> [ =A0 =A00.000000] e820 remove range: 00000000000a0000 - 000000000010=
0000 (usable)
> [ =A0 =A00.000000] No AGP bridge found
> [ =A0 =A00.000000] last_pfn =3D 0x140000 max_arch_pfn =3D 0x400000000
> [ =A0 =A00.000000] MTRR default type: uncachable
> [ =A0 =A00.000000] MTRR fixed ranges enabled:
> [ =A0 =A00.000000] =A0 00000-9FFFF write-back
> [ =A0 =A00.000000] =A0 A0000-BFFFF uncachable
> [ =A0 =A00.000000] =A0 C0000-CBFFF write-protect
> [ =A0 =A00.000000] =A0 CC000-DFFFF uncachable
> [ =A0 =A00.000000] =A0 E0000-EFFFF write-through
> [ =A0 =A00.000000] =A0 F0000-FFFFF write-protect
> [ =A0 =A00.000000] MTRR variable ranges enabled:
> [ =A0 =A00.000000] =A0 0 base 000000000 mask F00000000 write-back
> [ =A0 =A00.000000] =A0 1 base 100000000 mask FC0000000 write-back
> [ =A0 =A00.000000] =A0 2 base 0C0000000 mask FC0000000 uncachable
> [ =A0 =A00.000000] =A0 3 base 0BF700000 mask FFFF00000 uncachable
> [ =A0 =A00.000000] =A0 4 base 0BF800000 mask FFF800000 uncachable
> [ =A0 =A00.000000] =A0 5 disabled
> [ =A0 =A00.000000] =A0 6 disabled
> [ =A0 =A00.000000] =A0 7 disabled
> [ =A0 =A00.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0=
x7010600070106
> [ =A0 =A00.000000] e820 update range: 00000000bf700000 - 000000010000=
0000 (usable) =3D=3D> (reserved)
> [ =A0 =A00.000000] last_pfn =3D 0xbf6b0 max_arch_pfn =3D 0x400000000
> [ =A0 =A00.000000] initial memory mapped : 0 - 20000000
> [ =A0 =A00.000000] found SMP MP-table at [ffff8800000ff780] ff780
> [ =A0 =A00.000000] init_memory_mapping: 0000000000000000-00000000bf6b=
0000
> [ =A0 =A00.000000] =A00000000000 - 00bf600000 page 2M
> [ =A0 =A00.000000] =A000bf600000 - 00bf6b0000 page 4k
> [ =A0 =A00.000000] kernel direct mapping tables up to bf6b0000 @ 1600=
0-1b000
> [ =A0 =A00.000000] init_memory_mapping: 0000000100000000-000000014000=
0000
> [ =A0 =A00.000000] =A00100000000 - 0140000000 page 2M
> [ =A0 =A00.000000] kernel direct mapping tables up to 140000000 @ 190=
00-1f000
> [ =A0 =A00.000000] ACPI: RSDP 00000000000f9f60 00014 (v00 ACPIAM)
> [ =A0 =A00.000000] ACPI: RSDT 00000000bf6b0000 00040 (v01 040209 RSDT=
1650 20090402 MSFT 00000097)
> [ =A0 =A00.000000] ACPI: FACP 00000000bf6b0200 00084 (v01 A_M_I =A0OE=
MFACP =A012000601 MSFT 00000097)
> [ =A0 =A00.000000] ACPI: DSDT 00000000bf6b0440 05779 (v01 =A0AS153 AS=
153151 00000151 INTL 20051117)
> [ =A0 =A00.000000] ACPI: FACS 00000000bf6c0000 00040
> [ =A0 =A00.000000] ACPI: APIC 00000000bf6b0390 0006C (v01 040209 APIC=
1650 20090402 MSFT 00000097)
> [ =A0 =A00.000000] ACPI: MCFG 00000000bf6b0400 0003C (v01 040209 OEMM=
CFG =A020090402 MSFT 00000097)
> [ =A0 =A00.000000] ACPI: OEMB 00000000bf6c0040 00071 (v01 040209 OEMB=
1650 20090402 MSFT 00000097)
> [ =A0 =A00.000000] ACPI: AAFT 00000000bf6b5bc0 00027 (v01 040209 OEMA=
AFT =A020090402 MSFT 00000097)
> [ =A0 =A00.000000] ACPI: GSCI 00000000bf6c00c0 02024 (v01 040209 GMCH=
SCI =A020090402 MSFT 00000097)
> [ =A0 =A00.000000] ACPI: SSDT 00000000bf6c2a10 00A7C (v01 DpgPmm =A0 =
=A0CpuPm 00000012 INTL 20051117)
> [ =A0 =A00.000000] ACPI: Local APIC address 0xfee00000
> [ =A0 =A00.000000] No NUMA configuration found
> [ =A0 =A00.000000] Faking a node at 0000000000000000-0000000140000000
> [ =A0 =A00.000000] Initmem setup node 0 0000000000000000-000000014000=
0000
> [ =A0 =A00.000000] =A0 NODE_DATA [0000000100000000 - 0000000100004fff=
]
> [ =A0 =A00.000000] =A0[ffffea0000000000-ffffea00045fffff] PMD -> [fff=
f880100200000-ffff8801039fffff] on node 0
> [ =A0 =A00.000000] Zone PFN ranges:
> [ =A0 =A00.000000] =A0 DMA =A0 =A0 =A00x00000010 -> 0x00001000
> [ =A0 =A00.000000] =A0 DMA32 =A0 =A00x00001000 -> 0x00100000
> [ =A0 =A00.000000] =A0 Normal =A0 0x00100000 -> 0x00140000
> [ =A0 =A00.000000] Movable zone start PFN for each node
> [ =A0 =A00.000000] early_node_map[3] active PFN ranges
> [ =A0 =A00.000000] =A0 =A0 0: 0x00000010 -> 0x0000009f
> [ =A0 =A00.000000] =A0 =A0 0: 0x00000100 -> 0x000bf6b0
> [ =A0 =A00.000000] =A0 =A0 0: 0x00100000 -> 0x00140000
> [ =A0 =A00.000000] On node 0 totalpages: 1046079
> [ =A0 =A00.000000] =A0 DMA zone: 56 pages used for memmap
> [ =A0 =A00.000000] =A0 DMA zone: 0 pages reserved
> [ =A0 =A00.000000] =A0 DMA zone: 3927 pages, LIFO batch:0
> [ =A0 =A00.000000] =A0 DMA32 zone: 14280 pages used for memmap
> [ =A0 =A00.000000] =A0 DMA32 zone: 765672 pages, LIFO batch:31
> [ =A0 =A00.000000] =A0 Normal zone: 3584 pages used for memmap
> [ =A0 =A00.000000] =A0 Normal zone: 258560 pages, LIFO batch:31
> [ =A0 =A00.000000] ACPI: PM-Timer IO Port: 0x808
> [ =A0 =A00.000000] ACPI: Local APIC address 0xfee00000
> [ =A0 =A00.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> [ =A0 =A00.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
> [ =A0 =A00.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled=
)
> [ =A0 =A00.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled=
)
> [ =A0 =A00.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_bas=
e[0])
> [ =A0 =A00.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec000=
00, GSI 0-23
> [ =A0 =A00.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 df=
l dfl)
> [ =A0 =A00.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 hi=
gh level)
> [ =A0 =A00.000000] ACPI: IRQ0 used by override.
> [ =A0 =A00.000000] ACPI: IRQ2 used by override.
> [ =A0 =A00.000000] ACPI: IRQ9 used by override.
> [ =A0 =A00.000000] Using ACPI (MADT) for SMP configuration informatio=
n
> [ =A0 =A00.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
> [ =A0 =A00.000000] nr_irqs_gsi: 24
> [ =A0 =A00.000000] early_res array is doubled to 64 at [1a000 - 1a7ff=
]
> [ =A0 =A00.000000] PM: Registered nosave memory: 000000000009f000 - 0=
0000000000a0000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000000a0000 - 0=
0000000000e6000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000000e6000 - 0=
000000000100000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000bf6b0000 - 0=
0000000bf6c0000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000bf6c0000 - 0=
0000000bf6f0000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000bf6f0000 - 0=
0000000bf700000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000bf700000 - 0=
0000000fed00000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000fed00000 - 0=
0000000fee00000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000fee00000 - 0=
0000000fee01000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000fee01000 - 0=
0000000ff380000
> [ =A0 =A00.000000] PM: Registered nosave memory: 00000000ff380000 - 0=
000000100000000
> [ =A0 =A00.000000] Allocating PCI resources starting at bf700000 (gap=
: bf700000:3f600000)
> [ =A0 =A00.000000] Booting paravirtualized kernel on bare hardware
> [ =A0 =A00.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu=
_ids:4 nr_node_ids:1
> [ =A0 =A00.000000] PERCPU: Embedded 476 pages/cpu @ffff880002600000 s=
1918952 r8192 d22552 u2097152
> [ =A0 =A00.000000] pcpu-alloc: s1918952 r8192 d22552 u2097152 alloc=3D=
1*2097152
> [ =A0 =A00.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3
> [ =A0 =A00.000000] Built 1 zonelists in Node order, mobility grouping=
 on. =A0Total pages: 1028159
> [ =A0 =A00.000000] Policy zone: Normal
> [ =A0 =A00.000000] Kernel command line: vga=3D9 root=3D/dev/sda2 logl=
evel=3D9 netconsole=3D4444@192.168.0.39/eth0,6666@192.168.0.10/00:15:58=
:C5:ED:A8 BOOT_IMAGE=3DbzImage
> [ =A0 =A00.000000] PID hash table entries: 4096 (order: 3, 32768 byte=
s)
> [ =A0 =A00.000000] xsave/xrstor: enabled xstate_bv 0x3, cntxt size 0x=
240
> [ =A0 =A00.000000] Checking aperture...
> [ =A0 =A00.000000] No AGP bridge found
> [ =A0 =A00.000000] Calgary: detecting Calgary via BIOS EBDA area
> [ =A0 =A00.000000] Calgary: Unable to locate Rio Grande table in EBDA=
 - bailing!
> [ =A0 =A00.000000] Subtract (56 early reservations)
> [ =A0 =A00.000000] =A0 #1 [0001000000 - 000241a810] =A0 TEXT DATA BSS
> [ =A0 =A00.000000] =A0 #2 [000241b000 - 000241b12b] =A0 =A0 =A0 =A0 =A0=
 =A0 BRK
> [ =A0 =A00.000000] =A0 #3 [00000ff790 - 0000100000] =A0 BIOS reserved
> [ =A0 =A00.000000] =A0 #4 [00000ff780 - 00000ff790] =A0 =A0MP-table m=
pf
> [ =A0 =A00.000000] =A0 #5 [000009e400 - 00000fcc20] =A0 BIOS reserved
> [ =A0 =A00.000000] =A0 #6 [00000fcd5c - 00000ff780] =A0 BIOS reserved
> [ =A0 =A00.000000] =A0 #7 [00000fcc20 - 00000fcd5c] =A0 =A0MP-table m=
pc
> [ =A0 =A00.000000] =A0 #8 [0000010000 - 0000012000] =A0 =A0 =A0TRAMPO=
LINE
> [ =A0 =A00.000000] =A0 #9 [0000012000 - 0000016000] =A0 =A0 ACPI WAKE=
UP
> [ =A0 =A00.000000] =A0 #10 [0000016000 - 0000019000] =A0 =A0 =A0 =A0 =
PGTABLE
> [ =A0 =A00.000000] =A0 #11 [0000019000 - 000001a000] =A0 =A0 =A0 =A0 =
PGTABLE
> [ =A0 =A00.000000] =A0 #12 [0100000000 - 0100005000] =A0 =A0 =A0 NODE=
_DATA
> [ =A0 =A00.000000] =A0 #13 [000241b140 - 000241c140] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #14 [000241a840 - 000241ab40] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #15 [0100005000 - 0100006000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #16 [0100006000 - 0100007000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #17 [0100200000 - 0103a00000] =A0 =A0 =A0 =A0M=
EMMAP 0
> [ =A0 =A00.000000] =A0 #18 [000241c140 - 000241c640] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #19 [000241c640 - 000246c640] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #20 [000246c640 - 0002480640] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #21 [0002481000 - 0002482000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #22 [000241ab40 - 000241ab83] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #23 [000241abc0 - 000241ae60] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #24 [000241ae80 - 000241aee8] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #25 [000241af00 - 000241af68] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #26 [000241af80 - 000241afe8] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #27 [0002480640 - 00024806a8] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #28 [00024806c0 - 0002480728] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #29 [0002480740 - 00024807a8] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #30 [00024807c0 - 0002480828] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #31 [0002480840 - 00024808a8] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #32 [00024808c0 - 0002480928] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #33 [0002480940 - 00024809a8] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #34 [00024809c0 - 0002480a28] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #35 [0002480a40 - 0002480a60] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #36 [0002480a80 - 0002480aa0] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #37 [0002480ac0 - 0002480b3a] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #38 [0002480b40 - 0002480bba] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #39 [0002600000 - 00027dc000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #40 [0002800000 - 00029dc000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #41 [0002a00000 - 0002bdc000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #42 [0002c00000 - 0002ddc000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #43 [0002480bc0 - 0002480bc8] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #44 [0002480c00 - 0002480c08] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #45 [0002480c40 - 0002480c50] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #46 [0002480c80 - 0002480ca0] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #47 [0002480cc0 - 0002480e10] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #48 [0002480e40 - 0002480ec0] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #49 [0002480ec0 - 0002480f40] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #50 [0002482000 - 000248a000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #51 [000248a000 - 000248a240] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #52 [0002ddc000 - 0006ddc000] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #53 [000248a240 - 00024aa240] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #54 [00024aa240 - 00024ea240] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A0 #55 [000001a800 - 0000022800] =A0 =A0 =A0 =A0 =
BOOTMEM
> [ =A0 =A00.000000] =A023 40 - 80 9e
> [ =A0 =A00.000000] =A0100 100 - 1000 1000
> [ =A0 =A00.000000] =A024eb 2500 - 2600 2600
> [ =A0 =A00.000000] =A027dc - 2800
> [ =A0 =A00.000000] =A029dc - 2a00
> [ =A0 =A00.000000] =A02bdc - 2c00
> [ =A0 =A00.000000] =A06ddc 6e00 - bf680 bf6b0
> [ =A0 =A00.000000] =A0100007 100040 - 100200 100200
> [ =A0 =A00.000000] =A0103a00 103a00 - 140000 140000
> [ =A0 =A00.000000] Memory: 4032292k/5242880k available (3411k kernel =
code, 1058564k absent, 152024k reserved, 3689k data, 2556k init)
> [ =A0 =A00.000000] Hierarchical RCU implementation.
> [ =A0 =A00.000000] NR_IRQS:1280
> [ =A0 =A00.000000] Console: colour dummy device 80x25
> [ =A0 =A00.000000] console [tty0] enabled
> [ =A0 =A00.000000] Lock dependency validator: Copyright (c) 2006 Red =
Hat, Inc., Ingo Molnar
> [ =A0 =A00.000000] ... MAX_LOCKDEP_SUBCLASSES: =A08
> [ =A0 =A00.000000] ... MAX_LOCK_DEPTH: =A0 =A0 =A0 =A0 =A048
> [ =A0 =A00.000000] ... MAX_LOCKDEP_KEYS: =A0 =A0 =A0 =A08191
> [ =A0 =A00.000000] ... CLASSHASH_SIZE: =A0 =A0 =A0 =A0 =A04096
> [ =A0 =A00.000000] ... MAX_LOCKDEP_ENTRIES: =A0 =A0 16384
> [ =A0 =A00.000000] ... MAX_LOCKDEP_CHAINS: =A0 =A0 =A032768
> [ =A0 =A00.000000] ... CHAINHASH_SIZE: =A0 =A0 =A0 =A0 =A016384
> [ =A0 =A00.000000] =A0memory used by lock dependency info: 6367 kB
> [ =A0 =A00.000000] =A0per task-struct memory footprint: 2688 bytes
> [ =A0 =A00.000000] ODEBUG: 11 of 11 active objects replaced
> [ =A0 =A00.000000] Fast TSC calibration using PIT
> [ =A0 =A00.000000] Detected 2880.133 MHz processor.
> [ =A0 =A00.004030] Calibrating delay loop (skipped), value calculated=
 using timer frequency.. 5760.26 BogoMIPS (lpj=3D11520532)
> [ =A0 =A00.004700] Dentry cache hash table entries: 524288 (order: 10=
, 4194304 bytes)
> [ =A0 =A00.008489] Inode-cache hash table entries: 262144 (order: 9, =
2097152 bytes)
> [ =A0 =A00.009422] Mount-cache hash table entries: 256
> [ =A0 =A00.010361] Initializing cgroup subsys ns
> [ =A0 =A00.010368] Initializing cgroup subsys cpuacct
> [ =A0 =A00.010382] Initializing cgroup subsys devices
> [ =A0 =A00.010479] CPU: Physical Processor ID: 0
> [ =A0 =A00.010483] CPU: Processor Core ID: 0
> [ =A0 =A00.010488] mce: CPU supports 6 MCE banks
> [ =A0 =A00.010496] CPU0: Thermal monitoring enabled (TM2)
> [ =A0 =A00.010506] using mwait in idle threads.
> [ =A0 =A00.010510] Performance Events: Core2 events, Intel PMU driver=
=2E
> [ =A0 =A00.010524] ... version: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02
> [ =A0 =A00.010527] ... bit width: =A0 =A0 =A0 =A0 =A0 =A0 =A040
> [ =A0 =A00.010530] ... generic registers: =A0 =A0 =A02
> [ =A0 =A00.010534] ... value mask: =A0 =A0 =A0 =A0 =A0 =A0 000000ffff=
ffffff
> [ =A0 =A00.010538] ... max period: =A0 =A0 =A0 =A0 =A0 =A0 000000007f=
ffffff
> [ =A0 =A00.010541] ... fixed-purpose events: =A0 3
> [ =A0 =A00.010544] ... event mask: =A0 =A0 =A0 =A0 =A0 =A0 0000000700=
000003
> [ =A0 =A00.011517] ACPI: Core revision 20100121
> [ =A0 =A00.028016] ftrace: converting mcount calls to 0f 1f 44 00 00
> [ =A0 =A00.028024] ftrace: allocating 14208 entries in 56 pages
> [ =A0 =A00.032154] Setting APIC routing to flat
> [ =A0 =A00.032565] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D=
-1 pin2=3D-1
> [ =A0 =A00.075613] CPU0: Intel Pentium(R) Dual-Core =A0CPU =A0 =A0 =A0=
E5200 =A0@ 2.50GHz stepping 0a
> [ =A0 =A00.076000] lockdep: fixing up alternatives.
> [ =A0 =A00.076000] Booting Node =A0 0, Processors =A0#1
> [ =A0 =A00.164047] Brought up 2 CPUs
> [ =A0 =A00.164054] Total of 2 processors activated (11519.94 BogoMIPS=
).
> [ =A0 =A00.164753] khelper used greatest stack depth: 5888 bytes left
> [ =A0 =A00.164753] NET: Registered protocol family 16
> [ =A0 =A00.164753] ACPI: bus type pci registered
> [ =A0 =A00.164753] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem =
0xe0000000-0xefffffff] (base 0xe0000000)
> [ =A0 =A00.164753] PCI: not using MMCONFIG
> [ =A0 =A00.164753] PCI: Using configuration type 1 for base access
> [ =A0 =A00.164753] khelper used greatest stack depth: 5808 bytes left
> [ =A0 =A00.172140] bio: create slab <bio-0> at 0
> [ =A0 =A00.182217] ACPI: EC: Look up EC in DSDT
> [ =A0 =A00.190712] ACPI: Executed 1 blocks of module-level executable=
 AML code
> [ =A0 =A00.205132] ACPI: Interpreter enabled
> [ =A0 =A00.205137] ACPI: (supports S0 S1 S3 S4 S5)
> [ =A0 =A00.205224] ACPI: Using IOAPIC for interrupt routing
> [ =A0 =A00.205312] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem =
0xe0000000-0xefffffff] (base 0xe0000000)
> [ =A0 =A00.212093] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reser=
ved in ACPI motherboard resources
> [ =A0 =A00.328031] ACPI: No dock devices found.
> [ =A0 =A00.328040] PCI: Using host bridge windows from ACPI; if neces=
sary, use "pci=3Dnocrs" and report a bug
> [ =A0 =A00.328755] ACPI: PCI Root Bridge [PCI0] (0000:00)
> [ =A0 =A00.328991] pci_root PNP0A08:00: host bridge window [io =A00x0=
000-0x0cf7]
> [ =A0 =A00.328991] pci_root PNP0A08:00: host bridge window [io =A00x0=
d00-0xffff]
> [ =A0 =A00.328991] pci_root PNP0A08:00: host bridge window [mem 0x000=
a0000-0x000bffff]
> [ =A0 =A00.328991] pci_root PNP0A08:00: host bridge window [mem 0x000=
d0000-0x000dffff]
> [ =A0 =A00.328991] pci_root PNP0A08:00: host bridge window [mem 0xbf7=
00000-0xdfffffff]
> [ =A0 =A00.328991] pci_root PNP0A08:00: host bridge window [mem 0xf00=
00000-0xffffffff]
> [ =A0 =A00.328991] pci 0000:00:02.0: reg 10: [mem 0xfea80000-0xfeafff=
ff]
> [ =A0 =A00.328991] pci 0000:00:02.0: reg 14: [io =A00xdc00-0xdc07]
> [ =A0 =A00.328991] pci 0000:00:02.0: reg 18: [mem 0xd0000000-0xdfffff=
ff pref]
> [ =A0 =A00.328991] pci 0000:00:02.0: reg 1c: [mem 0xfe900000-0xfe9fff=
ff]
> [ =A0 =A00.328991] pci 0000:00:1c.0: PME# supported from D0 D3hot D3c=
old
> [ =A0 =A00.328991] pci 0000:00:1c.0: PME# disabled
> [ =A0 =A00.329041] pci 0000:00:1c.1: PME# supported from D0 D3hot D3c=
old
> [ =A0 =A00.329049] pci 0000:00:1c.1: PME# disabled
> [ =A0 =A00.329129] pci 0000:00:1d.0: reg 20: [io =A00xd400-0xd41f]
> [ =A0 =A00.329208] pci 0000:00:1d.1: reg 20: [io =A00xd480-0xd49f]
> [ =A0 =A00.329286] pci 0000:00:1d.2: reg 20: [io =A00xd800-0xd81f]
> [ =A0 =A00.329366] pci 0000:00:1d.3: reg 20: [io =A00xd880-0xd89f]
> [ =A0 =A00.329442] pci 0000:00:1d.7: reg 10: [mem 0xfea77c00-0xfea77f=
ff]
> [ =A0 =A00.329522] pci 0000:00:1d.7: PME# supported from D0 D3hot D3c=
old
> [ =A0 =A00.329530] pci 0000:00:1d.7: PME# disabled
> [ =A0 =A00.329726] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
> [ =A0 =A00.329735] pci 0000:00:1f.0: quirk: [io =A00x0800-0x087f] cla=
imed by ICH6 ACPI/GPIO/TCO
> [ =A0 =A00.329743] pci 0000:00:1f.0: quirk: [io =A00x0480-0x04bf] cla=
imed by ICH6 GPIO
> [ =A0 =A00.329750] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO=
 at 0280 (mask 00ff)
> [ =A0 =A00.329758] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO=
 at 0300 (mask 003f)
> [ =A0 =A00.329824] pci 0000:00:1f.1: reg 10: [io =A00x0000-0x0007]
> [ =A0 =A00.329835] pci 0000:00:1f.1: reg 14: [io =A00x0000-0x0003]
> [ =A0 =A00.329846] pci 0000:00:1f.1: reg 18: [io =A00x08f0-0x08f7]
> [ =A0 =A00.329856] pci 0000:00:1f.1: reg 1c: [io =A00x08f8-0x08fb]
> [ =A0 =A00.329867] pci 0000:00:1f.1: reg 20: [io =A00xffa0-0xffaf]
> [ =A0 =A00.329928] pci 0000:00:1f.2: reg 10: [io =A00xd080-0xd087]
> [ =A0 =A00.329938] pci 0000:00:1f.2: reg 14: [io =A00xd000-0xd003]
> [ =A0 =A00.329948] pci 0000:00:1f.2: reg 18: [io =A00xcc00-0xcc07]
> [ =A0 =A00.329958] pci 0000:00:1f.2: reg 1c: [io =A00xc880-0xc883]
> [ =A0 =A00.329968] pci 0000:00:1f.2: reg 20: [io =A00xc800-0xc80f]
> [ =A0 =A00.330010] pci 0000:00:1f.2: PME# supported from D3hot
> [ =A0 =A00.330016] pci 0000:00:1f.2: PME# disabled
> [ =A0 =A00.330085] pci 0000:00:1f.3: reg 20: [io =A00x0400-0x041f]
> [ =A0 =A00.330192] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
> [ =A0 =A00.330199] pci 0000:00:1c.0: =A0 bridge window [io =A0f000 - =
0000] reg reading
> [ =A0 =A00.330207] pci 0000:00:1c.0: =A0 bridge window [mem 0xfff0000=
0 - 0x000fffff] reg reading
> [ =A0 =A00.330219] pci 0000:00:1c.0: =A0 bridge window [mem 0xfdf0000=
0-0xfdffffff 64bit pref]
> [ =A0 =A00.330329] pci 0000:01:00.0: reg 10: [io =A00xe800-0xe8ff]
> [ =A0 =A00.330359] pci 0000:01:00.0: reg 18: [mem 0xfdeff000-0xfdefff=
ff 64bit pref]
> [ =A0 =A00.330381] pci 0000:01:00.0: reg 20: [mem 0xfdee0000-0xfdeeff=
ff 64bit pref]
> [ =A0 =A00.330395] pci 0000:01:00.0: reg 30: [mem 0x00000000-0x0001ff=
ff pref]
> [ =A0 =A00.330454] pci 0000:01:00.0: supports D1 D2
> [ =A0 =A00.330458] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3h=
ot D3cold
> [ =A0 =A00.330467] pci 0000:01:00.0: PME# disabled
> [ =A0 =A00.330500] pci 0000:00:1c.1: PCI bridge to [bus 01-01]
> [ =A0 =A00.330507] pci 0000:00:1c.1: =A0 bridge window [io =A00xe000-=
0xefff]
> [ =A0 =A00.330515] pci 0000:00:1c.1: =A0 bridge window [mem 0xfeb0000=
0-0xfebfffff]
> [ =A0 =A00.330526] pci 0000:00:1c.1: =A0 bridge window [mem 0xfde0000=
0-0xfdefffff 64bit pref]
> [ =A0 =A00.330638] pci 0000:00:1e.0: PCI bridge to [bus 03-03] (subtr=
active decode)
> [ =A0 =A00.330646] pci 0000:00:1e.0: =A0 bridge window [io =A0f000 - =
0000] reg reading
> [ =A0 =A00.330654] pci 0000:00:1e.0: =A0 bridge window [mem 0xfff0000=
0 - 0x000fffff] reg reading
> [ =A0 =A00.330666] pci 0000:00:1e.0: =A0 bridge window [mem 0xfff0000=
0 - 000fffff pref] reg reading
> [ =A0 =A00.330672] pci 0000:00:1e.0: =A0 bridge window [io =A00x0000-=
0x0cf7] (subtractive decode)
> [ =A0 =A00.330678] pci 0000:00:1e.0: =A0 bridge window [io =A00x0d00-=
0xffff] (subtractive decode)
> [ =A0 =A00.330683] pci 0000:00:1e.0: =A0 bridge window [mem 0x000a000=
0-0x000bffff] (subtractive decode)
> [ =A0 =A00.330690] pci 0000:00:1e.0: =A0 bridge window [mem 0x000d000=
0-0x000dffff] (subtractive decode)
> [ =A0 =A00.330696] pci 0000:00:1e.0: =A0 bridge window [mem 0xbf70000=
0-0xdfffffff] (subtractive decode)
> [ =A0 =A00.330702] pci 0000:00:1e.0: =A0 bridge window [mem 0xf000000=
0-0xffffffff] (subtractive decode)
> [ =A0 =A00.330733] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT=
]
> [ =A0 =A00.332114] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1=
=2E_PRT]
> [ =A0 =A00.332536] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4=
=2E_PRT]
> [ =A0 =A00.332681] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P5=
=2E_PRT]
> [ =A0 =A00.357702] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10=
 *11 12 14 15)
> [ =A0 =A00.357702] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *1=
0 11 12 14 15)
> [ =A0 =A00.357702] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 *7 1=
0 11 12 14 15)
> [ =A0 =A00.357702] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 1=
0 11 12 14 15)
> [ =A0 =A00.357702] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10=
 11 12 14 15) *0, disabled.
> [ =A0 =A00.357702] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10=
 11 12 14 15) *0, disabled.
> [ =A0 =A00.357702] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10=
 11 12 14 15) *0, disabled.
> [ =A0 =A00.357702] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 6 7 1=
0 11 12 14 15)
> [ =A0 =A00.360218] vgaarb: device added: PCI:0000:00:02.0,decodes=3Di=
o+mem,owns=3Dio+mem,locks=3Dnone
> [ =A0 =A00.360218] vgaarb: loaded
> [ =A0 =A00.360347] SCSI subsystem initialized
> [ =A0 =A00.360347] libata version 3.00 loaded.
> [ =A0 =A00.360347] usbcore: registered new interface driver usbfs
> [ =A0 =A00.360347] usbcore: registered new interface driver hub
> [ =A0 =A00.360347] usbcore: registered new device driver usb
> [ =A0 =A00.360347] PCI: Using ACPI for IRQ routing
> [ =A0 =A00.360347] PCI: pci_cache_line_size set to 64 bytes
> [ =A0 =A00.360347] reserve RAM buffer: 000000000009f800 - 00000000000=
9ffff
> [ =A0 =A00.360347] reserve RAM buffer: 00000000bf6b0000 - 00000000bff=
fffff
> [ =A0 =A00.360347] hpet clockevent registered
> [ =A0 =A00.360347] HPET: 3 timers in total, 0 timers will be used for=
 per-cpu timer
> [ =A0 =A00.360347] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
> [ =A0 =A00.360347] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
> [ =A0 =A00.372049] Switching to clocksource tsc
> [ =A0 =A00.378630] pnp: PnP ACPI init
> [ =A0 =A00.378664] ACPI: bus type pnp registered
> [ =A0 =A00.386324] pnp: PnP ACPI: found 13 devices
> [ =A0 =A00.386329] ACPI: ACPI bus type pnp unregistered
> [ =A0 =A00.386350] system 00:01: [mem 0xfed14000-0xfed19fff] has been=
 reserved
> [ =A0 =A00.386369] system 00:06: [io =A00x04d0-0x04d1] has been reser=
ved
> [ =A0 =A00.386375] system 00:06: [io =A00x0800-0x087f] has been reser=
ved
> [ =A0 =A00.386380] system 00:06: [io =A00x0480-0x04bf] has been reser=
ved
> [ =A0 =A00.386385] system 00:06: [io =A00x0900-0x090f] has been reser=
ved
> [ =A0 =A00.386391] system 00:06: [mem 0xfed1c000-0xfed1ffff] has been=
 reserved
> [ =A0 =A00.386396] system 00:06: [mem 0xfed20000-0xfed8ffff] has been=
 reserved
> [ =A0 =A00.386412] system 00:08: [mem 0xffc00000-0xfff7ffff] has been=
 reserved
> [ =A0 =A00.386432] system 00:09: [mem 0xfec00000-0xfec00fff] could no=
t be reserved
> [ =A0 =A00.386438] system 00:09: [mem 0xfee00000-0xfee00fff] has been=
 reserved
> [ =A0 =A00.386453] system 00:0a: [io =A00x0290-0x029f] has been reser=
ved
> [ =A0 =A00.386467] system 00:0b: [mem 0xe0000000-0xefffffff] has been=
 reserved
> [ =A0 =A00.386483] system 00:0c: [mem 0x00000000-0x0009ffff] could no=
t be reserved
> [ =A0 =A00.386489] system 00:0c: [mem 0x000c0000-0x000cffff] has been=
 reserved
> [ =A0 =A00.386496] system 00:0c: [mem 0x000e0000-0x000fffff] could no=
t be reserved
> [ =A0 =A00.386503] system 00:0c: [mem 0x00100000-0xbf6fffff] could no=
t be reserved
> [ =A0 =A00.392112] PCI: max bus depth: 1 pci_try_num: 2
> [ =A0 =A00.392155] pci 0000:00:1c.0: BAR 8: assigned [mem 0xbf700000-=
0xbfafffff]
> [ =A0 =A00.392163] pci 0000:00:1c.0: BAR 7: assigned [io =A00x1000-0x=
1fff]
> [ =A0 =A00.392168] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
> [ =A0 =A00.392174] pci 0000:00:1c.0: =A0 bridge window [io =A00x1000-=
0x1fff]
> [ =A0 =A00.392183] pci 0000:00:1c.0: =A0 bridge window [mem 0xbf70000=
0-0xbfafffff]
> [ =A0 =A00.392191] pci 0000:00:1c.0: =A0 bridge window [mem 0xfdf0000=
0-0xfdffffff 64bit pref]
> [ =A0 =A00.392204] pci 0000:01:00.0: BAR 6: assigned [mem 0xfde00000-=
0xfde1ffff pref]
> [ =A0 =A00.392210] pci 0000:00:1c.1: PCI bridge to [bus 01-01]
> [ =A0 =A00.392216] pci 0000:00:1c.1: =A0 bridge window [io =A00xe000-=
0xefff]
> [ =A0 =A00.392225] pci 0000:00:1c.1: =A0 bridge window [mem 0xfeb0000=
0-0xfebfffff]
> [ =A0 =A00.392232] pci 0000:00:1c.1: =A0 bridge window [mem 0xfde0000=
0-0xfdefffff 64bit pref]
> [ =A0 =A00.392244] pci 0000:00:1e.0: PCI bridge to [bus 03-03]
> [ =A0 =A00.392248] pci 0000:00:1e.0: =A0 bridge window [io =A0disable=
d]
> [ =A0 =A00.392257] pci 0000:00:1e.0: =A0 bridge window [mem disabled]
> [ =A0 =A00.392264] pci 0000:00:1e.0: =A0 bridge window [mem pref disa=
bled]
> [ =A0 =A00.392284] pci 0000:00:1c.0: enabling device (0106 -> 0107)
> [ =A0 =A00.392299] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low)=
 -> IRQ 16
> [ =A0 =A00.392307] pci 0000:00:1c.0: setting latency timer to 64
> [ =A0 =A00.392325] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low)=
 -> IRQ 17
> [ =A0 =A00.392333] pci 0000:00:1c.1: setting latency timer to 64
> [ =A0 =A00.392345] pci 0000:00:1e.0: setting latency timer to 64
> [ =A0 =A00.392351] pci_bus 0000:00: resource 4 [io =A00x0000-0x0cf7]
> [ =A0 =A00.392355] pci_bus 0000:00: resource 5 [io =A00x0d00-0xffff]
> [ =A0 =A00.392359] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000b=
ffff]
> [ =A0 =A00.392364] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d=
ffff]
> [ =A0 =A00.392368] pci_bus 0000:00: resource 8 [mem 0xbf700000-0xdfff=
ffff]
> [ =A0 =A00.392372] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xffff=
ffff]
> [ =A0 =A00.392377] pci_bus 0000:02: resource 0 [io =A00x1000-0x1fff]
> [ =A0 =A00.392381] pci_bus 0000:02: resource 1 [mem 0xbf700000-0xbfaf=
ffff]
> [ =A0 =A00.392385] pci_bus 0000:02: resource 2 [mem 0xfdf00000-0xfdff=
ffff 64bit pref]
> [ =A0 =A00.392391] pci_bus 0000:01: resource 0 [io =A00xe000-0xefff]
> [ =A0 =A00.392395] pci_bus 0000:01: resource 1 [mem 0xfeb00000-0xfebf=
ffff]
> [ =A0 =A00.392399] pci_bus 0000:01: resource 2 [mem 0xfde00000-0xfdef=
ffff 64bit pref]
> [ =A0 =A00.392405] pci_bus 0000:03: resource 4 [io =A00x0000-0x0cf7]
> [ =A0 =A00.392409] pci_bus 0000:03: resource 5 [io =A00x0d00-0xffff]
> [ =A0 =A00.392413] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000b=
ffff]
> [ =A0 =A00.392417] pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000d=
ffff]
> [ =A0 =A00.392422] pci_bus 0000:03: resource 8 [mem 0xbf700000-0xdfff=
ffff]
> [ =A0 =A00.392426] pci_bus 0000:03: resource 9 [mem 0xf0000000-0xffff=
ffff]
> [ =A0 =A00.392542] NET: Registered protocol family 2
> [ =A0 =A00.392892] IP route cache hash table entries: 131072 (order: =
8, 1048576 bytes)
> [ =A0 =A00.394859] TCP established hash table entries: 524288 (order:=
 11, 8388608 bytes)
> [ =A0 =A00.398800] TCP bind hash table entries: 65536 (order: 10, 471=
8592 bytes)
> [ =A0 =A00.404716] TCP: Hash tables configured (established 524288 bi=
nd 65536)
> [ =A0 =A00.404775] TCP reno registered
> [ =A0 =A00.404833] UDP hash table entries: 2048 (order: 6, 327680 byt=
es)
> [ =A0 =A00.405251] UDP-Lite hash table entries: 2048 (order: 6, 32768=
0 bytes)
> [ =A0 =A00.405946] NET: Registered protocol family 1
> [ =A0 =A00.405987] pci 0000:00:02.0: Boot video device
> [ =A0 =A00.406165] PCI: CLS 32 bytes, default 64
> [ =A0 =A00.417956] DMA-API: preallocated 32768 debug entries
> [ =A0 =A00.417965] DMA-API: debugging enabled by kernel config
> [ =A0 =A00.417971] PCI-DMA: Using software bounce buffering for IO (S=
WIOTLB)
> [ =A0 =A00.417977] Placing 64MB software IO TLB between ffff880002ddc=
000 - ffff880006ddc000
> [ =A0 =A00.417983] software IO TLB at phys 0x2ddc000 - 0x6ddc000
> [ =A0 =A00.420717] audit: initializing netlink socket (disabled)
> [ =A0 =A00.420763] type=3D2000 audit(1268726481.419:1): initialized
> [ =A0 =A00.421241] HugeTLB registered 2 MB page size, pre-allocated 0=
 pages
> [ =A0 =A00.421938] msgmni has been set to 7875
> [ =A0 =A00.422898] cryptomgr_test used greatest stack depth: 5352 byt=
es left
> [ =A0 =A00.422962] alg: No test for stdrng (krng)
> [ =A0 =A00.423105] Block layer SCSI generic (bsg) driver version 0.4 =
loaded (major 253)
> [ =A0 =A00.423124] io scheduler noop registered
> [ =A0 =A00.423128] io scheduler deadline registered
> [ =A0 =A00.423160] io scheduler cfq registered (default)
> [ =A0 =A00.423484] pcieport 0000:00:1c.0: setting latency timer to 64
> [ =A0 =A00.423551] pcieport 0000:00:1c.0: irq 24 for MSI/MSI-X
> [ =A0 =A00.424181] pcieport 0000:00:1c.1: setting latency timer to 64
> [ =A0 =A00.424244] pcieport 0000:00:1c.1: irq 25 for MSI/MSI-X
> [ =A0 =A00.426515] vesafb: framebuffer at 0xd0000000, mapped to 0xfff=
fc90011580000, using 3750k, total 8128k
> [ =A0 =A00.426522] vesafb: mode is 1600x1200x8, linelength=3D1600, pa=
ges=3D3
> [ =A0 =A00.426526] vesafb: scrolling: redraw
> [ =A0 =A00.426529] vesafb: Pseudocolor: size=3D8:8:8:8, shift=3D0:0:0=
:0
> [ =A0 =A00.444667] Console: switching to colour frame buffer device 2=
00x75
> [ =A0 =A00.462236] fb0: VESA VGA frame buffer device
> [ =A0 =A00.463660] ACPI: SSDT 00000000bf6c20f0 00277 (v01 DpgPmm =A0P=
001Ist 00000011 INTL 20051117)
> [ =A0 =A00.466926] ACPI: SSDT 00000000bf6c2580 00277 (v01 DpgPmm =A0P=
002Ist 00000012 INTL 20051117)
> [ =A0 =A00.484133] intel_rng: FWH not detected
> [ =A0 =A00.484265] Linux agpgart interface v0.103
> [ =A0 =A00.484463] agpgart-intel 0000:00:00.0: Intel G33 Chipset
> [ =A0 =A00.485627] agpgart-intel 0000:00:00.0: detected 7164K stolen =
memory
> [ =A0 =A00.495395] agpgart-intel 0000:00:00.0: AGP aperture is 256M @=
 0xd0000000
> [ =A0 =A00.495610] Serial: 8250/16550 driver, 4 ports, IRQ sharing en=
abled
> [ =A0 =A00.501851] brd: module loaded
> [ =A0 =A00.504130] loop: module loaded
> [ =A0 =A00.504466] ata_piix 0000:00:1f.1: version 2.13
> [ =A0 =A00.504554] ata_piix 0000:00:1f.1: PCI INT A -> GSI 18 (level,=
 low) -> IRQ 18
> [ =A0 =A00.504747] ata_piix 0000:00:1f.1: setting latency timer to 64
> [ =A0 =A00.504984] scsi0 : ata_piix
> [ =A0 =A00.505336] scsi1 : ata_piix
> [ =A0 =A00.510141] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma =
0xffa0 irq 14
> [ =A0 =A00.510238] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma =
0xffa8 irq 15
> [ =A0 =A00.510394] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level,=
 low) -> IRQ 19
> [ =A0 =A00.510496] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
> [ =A0 =A00.510645] ata_piix 0000:00:1f.2: setting latency timer to 64
> [ =A0 =A00.510829] scsi2 : ata_piix
> [ =A0 =A00.511214] scsi3 : ata_piix
> [ =A0 =A00.516880] ata3: SATA max UDMA/133 cmd 0xd080 ctl 0xd000 bmdm=
a 0xc800 irq 19
> [ =A0 =A00.516979] ata4: SATA max UDMA/133 cmd 0xcc00 ctl 0xc880 bmdm=
a 0xc808 irq 19
> [ =A0 =A00.517340] tun: Universal TUN/TAP device driver, 1.6
> [ =A0 =A00.517411] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.=
com>
> [ =A0 =A00.517634] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [ =A0 =A00.517731] r8169 0000:01:00.0: PCI INT A -> GSI 17 (level, lo=
w) -> IRQ 17
> [ =A0 =A00.517853] r8169 0000:01:00.0: (unregistered net_device): usi=
ng 64-bit DMA
> [ =A0 =A00.517975] r8169 0000:01:00.0: setting latency timer to 64
> [ =A0 =A00.518121] r8169 0000:01:00.0: irq 26 for MSI/MSI-X
> [ =A0 =A00.518411] khelper used greatest stack depth: 5136 bytes left
> [ =A0 =A00.518989] r8169 0000:01:00.0: eth0: RTL8102e at 0xffffc90000=
63e000, 00:19:66:ca:2c:7f, XID 04a00000 IRQ 26
> [ =A0 =A00.521192] netconsole: local port 4444
> [ =A0 =A00.521247] netconsole: local IP 192.168.0.39
> [ =A0 =A00.521307] netconsole: interface eth0
> [ =A0 =A00.521359] netconsole: remote port 6666
> [ =A0 =A00.521413] netconsole: remote IP 192.168.0.10
> [ =A0 =A00.521475] netconsole: remote ethernet address 00:15:58:c5:ed=
:a8
> [ =A0 =A00.521564] netconsole: device eth0 not up yet, forcing it
> [ =A0 =A00.523389] r8169 0000:01:00.0: eth0: link down
> [ =A0 =A00.523453] r8169 0000:01:00.0: eth0: link down
> [ =A0 =A00.683957] ata4.00: ATA-7: INTEL SSDSA2M040G2GC, 2CV102HB, ma=
x UDMA/133
> [ =A0 =A00.684071] ata4.00: 78165360 sectors, multi 16: LBA48 NCQ (de=
pth 0/32)
> [ =A0 =A00.691795] ata4.00: configured for UDMA/133
> [ =A0 =A00.699881] ata3.00: ATA-8: Hitachi HDT721025SLA380, STBOA31B,=
 max UDMA/133
> [ =A0 =A00.699997] ata3.00: 488397168 sectors, multi 16: LBA48 NCQ (d=
epth 0/32)
> [ =A0 =A00.715852] ata3.00: configured for UDMA/133
> [ =A0 =A00.716480] scsi 2:0:0:0: Direct-Access =A0 =A0 ATA =A0 =A0 =A0=
Hitachi HDT72102 STBO PQ: 0 ANSI: 5
> [ =A0 =A00.720035] sd 2:0:0:0: [sda] 488397168 512-byte logical block=
s: (250 GB/232 GiB)
> [ =A0 =A00.720618] scsi 3:0:0:0: Direct-Access =A0 =A0 ATA =A0 =A0 =A0=
INTEL SSDSA2M040 2CV1 PQ: 0 ANSI: 5
> [ =A0 =A00.721050] sd 3:0:0:0: [sdb] 78165360 512-byte logical blocks=
: (40.0 GB/37.2 GiB)
> [ =A0 =A00.721222] sd 3:0:0:0: [sdb] Write Protect is off
> [ =A0 =A00.721224] sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
> [ =A0 =A00.721293] sd 3:0:0:0: [sdb] Write cache: enabled, read cache=
: enabled, doesn't support DPO or FUA
> [ =A0 =A00.721833] =A0sdb: unknown partition table
> [ =A0 =A00.742050] sd 2:0:0:0: [sda] Write Protect is off
> [ =A0 =A00.742549] sd 3:0:0:0: [sdb] Attached SCSI disk
> [ =A0 =A00.748771] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [ =A0 =A00.752242] sd 2:0:0:0: [sda] Write cache: enabled, read cache=
: enabled, doesn't support DPO or FUA
> [ =A0 =A00.756154] =A0sda: sda1 sda2 sda3
> [ =A0 =A00.780333] sd 2:0:0:0: [sda] Attached SCSI disk
> [ =A0 =A01.736062] async/3 used greatest stack depth: 4776 bytes left
> [ =A0 =A01.739753] async/2 used greatest stack depth: 4720 bytes left
> [ =A0 =A04.528033] netconsole: timeout waiting for carrier
> [ =A0 =A06.156819] console [netcon0] enabled
> [ =A0 =A06.156820] netconsole: network logging started
> [ =A0 =A06.157229] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI=
) Driver
> [ =A0 =A06.157286] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level,=
 low) -> IRQ 23
> [ =A0 =A06.157320] ehci_hcd 0000:00:1d.7: setting latency timer to 64
> [ =A0 =A06.157324] ehci_hcd 0000:00:1d.7: EHCI Host Controller
> [ =A0 =A06.157793] ehci_hcd 0000:00:1d.7: new USB bus registered, ass=
igned bus number 1
> [ =A0 =A06.157860] ehci_hcd 0000:00:1d.7: using broken periodic worka=
round
> [ =A0 =A06.157874] ehci_hcd 0000:00:1d.7: debug port 1
> [ =A0 =A06.161767] ehci_hcd 0000:00:1d.7: cache line size of 32 is no=
t supported
> [ =A0 =A06.161803] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfea77c00
> [ =A0 =A06.176032] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
> [ =A0 =A06.176180] usb usb1: New USB device found, idVendor=3D1d6b, i=
dProduct=3D0002
> [ =A0 =A06.176182] usb usb1: New USB device strings: Mfr=3D3, Product=
=3D2, SerialNumber=3D1
> [ =A0 =A06.176183] usb usb1: Product: EHCI Host Controller
> [ =A0 =A06.176184] usb usb1: Manufacturer: Linux 2.6.33 ehci_hcd
> [ =A0 =A06.176185] usb usb1: SerialNumber: 0000:00:1d.7
> [ =A0 =A06.176831] hub 1-0:1.0: USB hub found
> [ =A0 =A06.176860] hub 1-0:1.0: 8 ports detected
> [ =A0 =A06.177512] uhci_hcd: USB Universal Host Controller Interface =
driver
> [ =A0 =A06.202365] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level,=
 low) -> IRQ 23
> [ =A0 =A06.202374] uhci_hcd 0000:00:1d.0: setting latency timer to 64
> [ =A0 =A06.202378] uhci_hcd 0000:00:1d.0: UHCI Host Controller
> [ =A0 =A06.202540] uhci_hcd 0000:00:1d.0: new USB bus registered, ass=
igned bus number 2
> [ =A0 =A06.202575] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000d400
> [ =A0 =A06.202667] usb usb2: New USB device found, idVendor=3D1d6b, i=
dProduct=3D0001
> [ =A0 =A06.202669] usb usb2: New USB device strings: Mfr=3D3, Product=
=3D2, SerialNumber=3D1
> [ =A0 =A06.202671] usb usb2: Product: UHCI Host Controller
> [ =A0 =A06.202672] usb usb2: Manufacturer: Linux 2.6.33 uhci_hcd
> [ =A0 =A06.202673] usb usb2: SerialNumber: 0000:00:1d.0
> [ =A0 =A06.202988] hub 2-0:1.0: USB hub found
> [ =A0 =A06.203030] hub 2-0:1.0: 2 ports detected
> [ =A0 =A06.203335] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level,=
 low) -> IRQ 19
> [ =A0 =A06.203344] uhci_hcd 0000:00:1d.1: setting latency timer to 64
> [ =A0 =A06.203347] uhci_hcd 0000:00:1d.1: UHCI Host Controller
> [ =A0 =A06.203508] uhci_hcd 0000:00:1d.1: new USB bus registered, ass=
igned bus number 3
> [ =A0 =A06.203544] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000d480
> [ =A0 =A06.203639] usb usb3: New USB device found, idVendor=3D1d6b, i=
dProduct=3D0001
> [ =A0 =A06.203641] usb usb3: New USB device strings: Mfr=3D3, Product=
=3D2, SerialNumber=3D1
> [ =A0 =A06.203642] usb usb3: Product: UHCI Host Controller
> [ =A0 =A06.203643] usb usb3: Manufacturer: Linux 2.6.33 uhci_hcd
> [ =A0 =A06.203645] usb usb3: SerialNumber: 0000:00:1d.1
> [ =A0 =A06.203962] hub 3-0:1.0: USB hub found
> [ =A0 =A06.203974] hub 3-0:1.0: 2 ports detected
> [ =A0 =A06.204275] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level,=
 low) -> IRQ 18
> [ =A0 =A06.204284] uhci_hcd 0000:00:1d.2: setting latency timer to 64
> [ =A0 =A06.204287] uhci_hcd 0000:00:1d.2: UHCI Host Controller
> [ =A0 =A06.204447] uhci_hcd 0000:00:1d.2: new USB bus registered, ass=
igned bus number 4
> [ =A0 =A06.204499] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000d800
> [ =A0 =A06.204595] usb usb4: New USB device found, idVendor=3D1d6b, i=
dProduct=3D0001
> [ =A0 =A06.204597] usb usb4: New USB device strings: Mfr=3D3, Product=
=3D2, SerialNumber=3D1
> [ =A0 =A06.204599] usb usb4: Product: UHCI Host Controller
> [ =A0 =A06.204600] usb usb4: Manufacturer: Linux 2.6.33 uhci_hcd
> [ =A0 =A06.204601] usb usb4: SerialNumber: 0000:00:1d.2
> [ =A0 =A06.204978] hub 4-0:1.0: USB hub found
> [ =A0 =A06.204989] hub 4-0:1.0: 2 ports detected
> [ =A0 =A06.205269] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level,=
 low) -> IRQ 16
> [ =A0 =A06.205278] uhci_hcd 0000:00:1d.3: setting latency timer to 64
> [ =A0 =A06.205281] uhci_hcd 0000:00:1d.3: UHCI Host Controller
> [ =A0 =A06.205448] uhci_hcd 0000:00:1d.3: new USB bus registered, ass=
igned bus number 5
> [ =A0 =A06.205498] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000d880
> [ =A0 =A06.205597] usb usb5: New USB device found, idVendor=3D1d6b, i=
dProduct=3D0001
> [ =A0 =A06.205599] usb usb5: New USB device strings: Mfr=3D3, Product=
=3D2, SerialNumber=3D1
> [ =A0 =A06.205600] usb usb5: Product: UHCI Host Controller
> [ =A0 =A06.205601] usb usb5: Manufacturer: Linux 2.6.33 uhci_hcd
> [ =A0 =A06.205602] usb usb5: SerialNumber: 0000:00:1d.3
> [ =A0 =A06.205912] hub 5-0:1.0: USB hub found
> [ =A0 =A06.205924] hub 5-0:1.0: 2 ports detected
> [ =A0 =A06.206303] Initializing USB Mass Storage driver...
> [ =A0 =A06.206428] usbcore: registered new interface driver usb-stora=
ge
> [ =A0 =A06.206429] USB Mass Storage support registered.
> [ =A0 =A06.206889] PNP: No PS/2 controller found. Probing ports direc=
tly.
> [ =A0 =A06.251877] serio: i8042 KBD port at 0x60,0x64 irq 1
> [ =A0 =A06.251903] serio: i8042 AUX port at 0x60,0x64 irq 12
> [ =A0 =A06.252259] mice: PS/2 mouse device common for all mice
> [ =A0 =A06.252393] rtc_cmos 00:03: RTC can wake from S4
> [ =A0 =A06.252606] rtc_cmos 00:03: rtc core: registered rtc_cmos as r=
tc0
> [ =A0 =A06.252637] rtc0: alarms up to one month, y3k, 114 bytes nvram=
, hpet irqs
> [ =A0 =A06.446711] cpuidle: using governor ladder
> [ =A0 =A06.446714] cpuidle: using governor menu
> [ =A0 =A06.449762] usbcore: registered new interface driver hiddev
> [ =A0 =A06.449873] usbcore: registered new interface driver usbhid
> [ =A0 =A06.449874] usbhid: USB HID core driver
> [ =A0 =A06.450050] oprofile: using NMI interrupt.
> [ =A0 =A06.469847] TCP cubic registered
> [ =A0 =A06.469851] NET: Registered protocol family 17
> [ =A0 =A06.499369] registered taskstats version 1
> [ =A0 =A06.503448] rtc_cmos 00:03: setting system clock to 2010-03-16=
 08:01:28 UTC (1268726488)
> [ =A0 =A06.539784] EXT3-fs (sda2): recovery required on readonly file=
system
> [ =A0 =A06.543559] EXT3-fs (sda2): write access will be enabled durin=
g recovery
> [ =A0 =A06.587902] kjournald starting. =A0Commit interval 5 seconds
> [ =A0 =A06.591792] EXT3-fs (sda2): recovery complete
> [ =A0 =A06.596352] EXT3-fs (sda2): mounted filesystem with writeback =
data mode
> [ =A0 =A06.600318] VFS: Mounted root (ext3 filesystem) readonly on de=
vice 8:2.
> [ =A0 =A06.604202] Freeing unused kernel memory: 2556k freed
> [ =A0 =A06.609265] Write protecting the kernel read-only data: 6144k
> [ =A0 =A06.613463] Freeing unused kernel memory: 664k freed
> [ =A0 =A06.617826] Freeing unused kernel memory: 332k freed
> [ =A0 =A06.860063] usb 3-2: new low speed USB device using uhci_hcd a=
nd address 2
> [ =A0 =A07.115503] usb 3-2: New USB device found, idVendor=3D1241, id=
Product=3D1503
> [ =A0 =A07.119525] usb 3-2: New USB device strings: Mfr=3D1, Product=3D=
2, SerialNumber=3D0
> [ =A0 =A07.123498] usb 3-2: Product: USB Keyboard
> [ =A0 =A07.127376] usb 3-2: Manufacturer:
> [ =A0 =A07.181976] input: =A0 USB Keyboard as /class/input/input0
> [ =A0 =A07.186467] generic-usb 0003:1241:1503.0001: input,hidraw0: US=
B HID v1.10 Keyboard [ =A0USB Keyboard] on usb-0000:00:1d.1-2/input0
> [ =A0 =A07.274776] input: =A0 USB Keyboard as /class/input/input1
> [ =A0 =A07.279002] generic-usb 0003:1241:1503.0002: input,hidraw1: US=
B HID v1.10 Device [ =A0USB Keyboard] on usb-0000:00:1d.1-2/input1
> [ =A0 =A07.338603] stty used greatest stack depth: 3744 bytes left
> [ =A0 =A07.724093] touch used greatest stack depth: 3664 bytes left
> [ =A0 =A08.919804] egrep used greatest stack depth: 3344 bytes left
> [ =A0 10.713241] EXT3-fs (sda2): using internal journal
> [ =A0 11.708808] kjournald starting. =A0Commit interval 5 seconds
> [ =A0 11.713511] EXT3-fs (sda1): using internal journal
> [ =A0 11.718095] EXT3-fs (sda1): mounted filesystem with writeback da=
ta mode
> [ =A0 12.975258] rc used greatest stack depth: 3136 bytes left
>
> lspci -vv:
> 00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P31 Express DRAM=
 Controller (rev 10)
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 29c0
> =A0 =A0 =A0 =A0Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfas=
t >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Capabilities: [e0] Vendor Specific Information <?>
> =A0 =A0 =A0 =A0Kernel driver in use: agpgart-intel
>
> 00:02.0 VGA compatible controller: Intel Corporation 82G33/G31 Expres=
s Integrated Graphics Controller (rev 10) (prog-if 00 [VGA controller])
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 29c2
> =A0 =A0 =A0 =A0Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfas=
t >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Interrupt: pin A routed to IRQ 11
> =A0 =A0 =A0 =A0Region 0: Memory at fea80000 (32-bit, non-prefetchable=
) [size=3D512K]
> =A0 =A0 =A0 =A0Region 1: I/O ports at dc00 [size=3D8]
> =A0 =A0 =A0 =A0Region 2: Memory at d0000000 (32-bit, prefetchable) [s=
ize=3D256M]
> =A0 =A0 =A0 =A0Region 3: Memory at fe900000 (32-bit, non-prefetchable=
) [size=3D1M]
> =A0 =A0 =A0 =A0Expansion ROM at <unassigned> [disabled]
> =A0 =A0 =A0 =A0Capabilities: [90] MSI: Enable- Count=3D1/1 Maskable- =
64bit-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Address: 00000000 =A0Data: 0000
> =A0 =A0 =A0 =A0Capabilities: [d0] Power Management version 2
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Flags: PMEClk- DSI+ D1- D2- AuxCurrent=
=3D0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Status: D0 NoSoftRst- PME-Enable- DSel=
=3D0 DScale=3D0 PME-
>
> 00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Expres=
s Port 1 (rev 01) (prog-if 00 [Normal decode])
> =A0 =A0 =A0 =A0Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfas=
t >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0, Cache Line Size: 32 bytes
> =A0 =A0 =A0 =A0Bus: primary=3D00, secondary=3D02, subordinate=3D02, s=
ec-latency=3D0
> =A0 =A0 =A0 =A0I/O behind bridge: 00001000-00001fff
> =A0 =A0 =A0 =A0Memory behind bridge: bf700000-bfafffff
> =A0 =A0 =A0 =A0Prefetchable memory behind bridge: 00000000fdf00000-00=
000000fdffffff
> =A0 =A0 =A0 =A0Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfas=
t >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> =A0 =A0 =A0 =A0BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- F=
astB2B-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PriDiscTmr- SecDiscTmr- DiscTmrStat- D=
iscTmrSERREn-
> =A0 =A0 =A0 =A0Capabilities: [40] Express (v1) Root Port (Slot+), MSI=
 00
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCap: MaxPayload 128 bytes, PhantFun=
c 0, Latency L0s unlimited, L1 unlimited
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ExtTag- RBE- FLReset-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCtl: Report errors: Correctable- No=
n-Fatal- Fatal- Unsupported-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RlxdOrd- ExtTag- Phant=
=46unc- AuxPwr- NoSnoop-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MaxPayload 128 bytes, =
MaxReadReq 128 bytes
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevSta: CorrErr- UncorrErr- FatalErr- =
UnsuppReq- AuxPwr+ TransPend-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCap: Port #1, Speed 2.5GT/s, Width =
x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ClockPM- Surprise- LLA=
ctRep+ BwNot-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCtl: ASPM Disabled; RCB 64 bytes Di=
sabled- Retrain- CommClk-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ExtSynch- ClockPM- Aut=
WidDis- BWInt- AutBWInt-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkSta: Speed 2.5GT/s, Width x0, TrErr=
- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SltCap: AttnBtn- PwrCtrl- MRL- AttnInd=
- PwrInd- HotPlug+ Surpise+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Slot # 11, PowerLimit =
25.000000; Interlock- NoCompl-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SltCtl: Enable: AttnBtn- PwrFlt- MRL- =
PresDet- CmdCplt- HPIrq- LinkChg-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Control: AttnInd Unkno=
wn, PwrInd Unknown, Power- Interlock-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SltSta: Status: AttnBtn- PowerFlt- MRL=
- CmdCplt- PresDet- Interlock-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Changed: MRL- PresDet-=
 LinkState-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RootCtl: ErrCorrectable- ErrNon-Fatal-=
 ErrFatal- PMEIntEna- CRSVisible-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RootCap: CRSVisible-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RootSta: PME ReqID 0000, PMEStatus- PM=
EPending-
> =A0 =A0 =A0 =A0Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- =
64bit-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Address: fee0300c =A0Data: 4149
> =A0 =A0 =A0 =A0Capabilities: [90] Subsystem: ASRock Incorporation Dev=
ice 27d0
> =A0 =A0 =A0 =A0Capabilities: [a0] Power Management version 2
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Flags: PMEClk- DSI- D1- D2- AuxCurrent=
=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Status: D0 NoSoftRst- PME-Enable- DSel=
=3D0 DScale=3D0 PME-
> =A0 =A0 =A0 =A0Capabilities: [100] Virtual Channel <?>
> =A0 =A0 =A0 =A0Capabilities: [180] Root Complex Link <?>
> =A0 =A0 =A0 =A0Kernel driver in use: pcieport
>
> 00:1c.1 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Expres=
s Port 2 (rev 01) (prog-if 00 [Normal decode])
> =A0 =A0 =A0 =A0Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfas=
t >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0, Cache Line Size: 32 bytes
> =A0 =A0 =A0 =A0Bus: primary=3D00, secondary=3D01, subordinate=3D01, s=
ec-latency=3D0
> =A0 =A0 =A0 =A0I/O behind bridge: 0000e000-0000efff
> =A0 =A0 =A0 =A0Memory behind bridge: feb00000-febfffff
> =A0 =A0 =A0 =A0Prefetchable memory behind bridge: 00000000fde00000-00=
000000fdefffff
> =A0 =A0 =A0 =A0Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfas=
t >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> =A0 =A0 =A0 =A0BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- F=
astB2B-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PriDiscTmr- SecDiscTmr- DiscTmrStat- D=
iscTmrSERREn-
> =A0 =A0 =A0 =A0Capabilities: [40] Express (v1) Root Port (Slot+), MSI=
 00
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCap: MaxPayload 128 bytes, PhantFun=
c 0, Latency L0s unlimited, L1 unlimited
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ExtTag- RBE- FLReset-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCtl: Report errors: Correctable- No=
n-Fatal- Fatal- Unsupported-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RlxdOrd- ExtTag- Phant=
=46unc- AuxPwr- NoSnoop-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MaxPayload 128 bytes, =
MaxReadReq 128 bytes
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevSta: CorrErr+ UncorrErr- FatalErr- =
UnsuppReq- AuxPwr+ TransPend-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCap: Port #2, Speed 2.5GT/s, Width =
x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ClockPM- Surprise- LLA=
ctRep+ BwNot-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCtl: ASPM Disabled; RCB 64 bytes Di=
sabled- Retrain- CommClk+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ExtSynch- ClockPM- Aut=
WidDis- BWInt- AutBWInt-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkSta: Speed 2.5GT/s, Width x1, TrErr=
- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SltCap: AttnBtn- PwrCtrl- MRL- AttnInd=
- PwrInd- HotPlug+ Surpise+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Slot # =A00, PowerLimi=
t 0.000000; Interlock- NoCompl-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SltCtl: Enable: AttnBtn- PwrFlt- MRL- =
PresDet- CmdCplt- HPIrq- LinkChg-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Control: AttnInd Unkno=
wn, PwrInd Unknown, Power- Interlock-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SltSta: Status: AttnBtn- PowerFlt- MRL=
- CmdCplt- PresDet+ Interlock-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Changed: MRL- PresDet-=
 LinkState-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RootCtl: ErrCorrectable- ErrNon-Fatal-=
 ErrFatal- PMEIntEna- CRSVisible-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RootCap: CRSVisible-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RootSta: PME ReqID 0000, PMEStatus- PM=
EPending-
> =A0 =A0 =A0 =A0Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- =
64bit-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Address: fee0300c =A0Data: 4151
> =A0 =A0 =A0 =A0Capabilities: [90] Subsystem: ASRock Incorporation Dev=
ice 27d2
> =A0 =A0 =A0 =A0Capabilities: [a0] Power Management version 2
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Flags: PMEClk- DSI- D1- D2- AuxCurrent=
=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Status: D0 NoSoftRst- PME-Enable- DSel=
=3D0 DScale=3D0 PME-
> =A0 =A0 =A0 =A0Capabilities: [100] Virtual Channel <?>
> =A0 =A0 =A0 =A0Capabilities: [180] Root Complex Link <?>
> =A0 =A0 =A0 =A0Kernel driver in use: pcieport
>
> 00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UH=
CI Controller #1 (rev 01) (prog-if 00 [UHCI])
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27c8
> =A0 =A0 =A0 =A0Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Interrupt: pin A routed to IRQ 23
> =A0 =A0 =A0 =A0Region 4: I/O ports at d400 [size=3D32]
> =A0 =A0 =A0 =A0Kernel driver in use: uhci_hcd
>
> 00:1d.1 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UH=
CI Controller #2 (rev 01) (prog-if 00 [UHCI])
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27c9
> =A0 =A0 =A0 =A0Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Interrupt: pin B routed to IRQ 19
> =A0 =A0 =A0 =A0Region 4: I/O ports at d480 [size=3D32]
> =A0 =A0 =A0 =A0Kernel driver in use: uhci_hcd
>
> 00:1d.2 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UH=
CI Controller #3 (rev 01) (prog-if 00 [UHCI])
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27ca
> =A0 =A0 =A0 =A0Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Interrupt: pin C routed to IRQ 18
> =A0 =A0 =A0 =A0Region 4: I/O ports at d800 [size=3D32]
> =A0 =A0 =A0 =A0Kernel driver in use: uhci_hcd
>
> 00:1d.3 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UH=
CI Controller #4 (rev 01) (prog-if 00 [UHCI])
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27cb
> =A0 =A0 =A0 =A0Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Interrupt: pin D routed to IRQ 16
> =A0 =A0 =A0 =A0Region 4: I/O ports at d880 [size=3D32]
> =A0 =A0 =A0 =A0Kernel driver in use: uhci_hcd
>
> 00:1d.7 USB Controller: Intel Corporation 82801G (ICH7 Family) USB2 E=
HCI Controller (rev 01) (prog-if 20 [EHCI])
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27cc
> =A0 =A0 =A0 =A0Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Interrupt: pin A routed to IRQ 23
> =A0 =A0 =A0 =A0Region 0: Memory at fea77c00 (32-bit, non-prefetchable=
) [size=3D1K]
> =A0 =A0 =A0 =A0Capabilities: [50] Power Management version 2
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Flags: PMEClk- DSI- D1- D2- AuxCurrent=
=3D375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Status: D0 NoSoftRst- PME-Enable- DSel=
=3D0 DScale=3D0 PME-
> =A0 =A0 =A0 =A0Capabilities: [58] Debug port: BAR=3D1 offset=3D00a0
> =A0 =A0 =A0 =A0Kernel driver in use: ehci_hcd
>
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1) (prog=
-if 01 [Subtractive decode])
> =A0 =A0 =A0 =A0Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfas=
t >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Bus: primary=3D00, secondary=3D03, subordinate=3D03, s=
ec-latency=3D32
> =A0 =A0 =A0 =A0Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> =A0 =A0 =A0 =A0BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- F=
astB2B-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PriDiscTmr- SecDiscTmr- DiscTmrStat- D=
iscTmrSERREn-
> =A0 =A0 =A0 =A0Capabilities: [50] Subsystem: ASRock Incorporation Dev=
ice 244e
>
> 00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC In=
terface Bridge (rev 01)
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27b8
> =A0 =A0 =A0 =A0Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Capabilities: [e0] Vendor Specific Information <?>
>
> 00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE Con=
troller (rev 01) (prog-if 8a [Master SecP PriP])
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27df
> =A0 =A0 =A0 =A0Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Interrupt: pin A routed to IRQ 18
> =A0 =A0 =A0 =A0Region 0: I/O ports at 01f0 [size=3D8]
> =A0 =A0 =A0 =A0Region 1: I/O ports at 03f4 [size=3D1]
> =A0 =A0 =A0 =A0Region 2: I/O ports at 0170 [size=3D8]
> =A0 =A0 =A0 =A0Region 3: I/O ports at 0374 [size=3D1]
> =A0 =A0 =A0 =A0Region 4: I/O ports at ffa0 [size=3D16]
> =A0 =A0 =A0 =A0Kernel driver in use: ata_piix
>
> 00:1f.2 IDE interface: Intel Corporation 82801GB/GR/GH (ICH7 Family) =
SATA IDE Controller (rev 01) (prog-if 8f [Master SecP SecO PriP PriO])
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27c0
> =A0 =A0 =A0 =A0Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0
> =A0 =A0 =A0 =A0Interrupt: pin B routed to IRQ 19
> =A0 =A0 =A0 =A0Region 0: I/O ports at d080 [size=3D8]
> =A0 =A0 =A0 =A0Region 1: I/O ports at d000 [size=3D4]
> =A0 =A0 =A0 =A0Region 2: I/O ports at cc00 [size=3D8]
> =A0 =A0 =A0 =A0Region 3: I/O ports at c880 [size=3D4]
> =A0 =A0 =A0 =A0Region 4: I/O ports at c800 [size=3D16]
> =A0 =A0 =A0 =A0Capabilities: [70] Power Management version 2
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Flags: PMEClk- DSI- D1- D2- AuxCurrent=
=3D0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Status: D0 NoSoftRst- PME-Enable- DSel=
=3D0 DScale=3D0 PME-
> =A0 =A0 =A0 =A0Kernel driver in use: ata_piix
>
> 00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controlle=
r (rev 01)
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 27da
> =A0 =A0 =A0 =A0Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> =A0 =A0 =A0 =A0Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmed=
ium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Interrupt: pin B routed to IRQ 5
> =A0 =A0 =A0 =A0Region 4: I/O ports at 0400 [size=3D32]
>
> 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E=
/RTL8102E PCI Express Fast Ethernet controller (rev 02)
> =A0 =A0 =A0 =A0Subsystem: ASRock Incorporation Device 8136
> =A0 =A0 =A0 =A0Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGAS=
noop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfas=
t >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> =A0 =A0 =A0 =A0Latency: 0, Cache Line Size: 32 bytes
> =A0 =A0 =A0 =A0Interrupt: pin A routed to IRQ 26
> =A0 =A0 =A0 =A0Region 0: I/O ports at e800 [size=3D256]
> =A0 =A0 =A0 =A0Region 2: Memory at fdeff000 (64-bit, prefetchable) [s=
ize=3D4K]
> =A0 =A0 =A0 =A0Region 4: Memory at fdee0000 (64-bit, prefetchable) [s=
ize=3D64K]
> =A0 =A0 =A0 =A0[virtual] Expansion ROM at fde00000 [disabled] [size=3D=
128K]
> =A0 =A0 =A0 =A0Capabilities: [40] Power Management version 3
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=
=3D375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Status: D0 NoSoftRst+ PME-Enable- DSel=
=3D0 DScale=3D0 PME-
> =A0 =A0 =A0 =A0Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskable- =
64bit+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Address: 00000000fee0300c =A0Data: 416=
9
> =A0 =A0 =A0 =A0Capabilities: [70] Express (v2) Endpoint, MSI 01
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCap: MaxPayload 256 bytes, PhantFun=
c 0, Latency L0s <512ns, L1 <64us
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ExtTag- AttnBtn- AttnI=
nd- PwrInd- RBE+ FLReset-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCtl: Report errors: Correctable- No=
n-Fatal- Fatal- Unsupported-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RlxdOrd+ ExtTag- Phant=
=46unc- AuxPwr- NoSnoop-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MaxPayload 128 bytes, =
MaxReadReq 4096 bytes
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevSta: CorrErr+ UncorrErr- FatalErr- =
UnsuppReq+ AuxPwr+ TransPend-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCap: Port #0, Speed 2.5GT/s, Width =
x1, ASPM L0s L1, Latency L0 <512ns, L1 <64us
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ClockPM+ Surprise- LLA=
ctRep- BwNot-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCtl: ASPM Disabled; RCB 64 bytes Di=
sabled- Retrain- CommClk+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ExtSynch- ClockPM- Aut=
WidDis- BWInt- AutBWInt-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkSta: Speed 2.5GT/s, Width x1, TrErr=
- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCap2: Completion Timeout: Not Suppo=
rted, TimeoutDis+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCtl2: Completion Timeout: 50us to 5=
0ms, TimeoutDis-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCtl2: Target Link Speed: 2.5GT/s, E=
nterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Transmit Margin: Norm=
al Operating Range, EnterModifiedCompliance- ComplianceSOS-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Compliance De-emphasi=
s: -6dB
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkSta2: Current De-emphasis Level: -6=
dB
> =A0 =A0 =A0 =A0Capabilities: [ac] MSI-X: Enable- Count=3D2 Masked-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Vector table: BAR=3D4 offset=3D0000000=
0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PBA: BAR=3D4 offset=3D00000800
> =A0 =A0 =A0 =A0Capabilities: [cc] Vital Product Data
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Not readable
> =A0 =A0 =A0 =A0Capabilities: [100] Advanced Error Reporting
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UESta: =A0DLP- SDES- TLP- FCP- CmpltTO=
- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UEMsk: =A0DLP- SDES- TLP- FCP- CmpltTO=
- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- =
CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CESta: =A0RxErr+ BadTLP- BadDLLP- Roll=
over- Timeout- NonFatalErr+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CEMsk: =A0RxErr- BadTLP- BadDLLP- Roll=
over- Timeout- NonFatalErr+
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0AERCap: First Error Pointer: 00, GenCa=
p+ CGenEn- ChkCap+ ChkEn-
> =A0 =A0 =A0 =A0Capabilities: [140] Virtual Channel <?>
> =A0 =A0 =A0 =A0Capabilities: [160] Device Serial Number 08-00-00-00-f=
f-ff-00-00
> =A0 =A0 =A0 =A0Kernel driver in use: r8169
>
>
