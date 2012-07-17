From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] tg3: frequent freezes
Date: Tue, 17 Jul 2012 07:35:29 +0200
Message-ID: <1342503329.2626.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45096 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab2GQFfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:35:40 -0400
Received: by eaak11 with SMTP id k11so6189eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 22:35:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael

I tried to use an old Dell laptop D630 and its tg3 nic,
but experience almost immediate freezes as soon as I send a lot of data=
=2E

I tried many things but couldnt find the culprit.

Is there any chance you can help me, as this machine is mostly unusable
as is ?

Thanks !

netperf -H remote -t UDP_STREAM -- -m 1400

# ethtool -i eth0
driver: tg3
version: 3.123
firmware-version: 5755m-v3.29
bus-info: 0000:09:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes


I did this small change to know what exact condition was triggered : (i=
ts the RDMAC_STATUS)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index ac9091f..91ff1f2 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6283,8 +6283,12 @@ static void tg3_process_error(struct tg3 *tp)
                real_error =3D true;
        }
=20
-       if (tr32(RDMAC_STATUS) || tr32(WDMAC_STATUS)) {
-               netdev_err(tp->dev, "DMA Status error.  Resetting chip.=
\n");
+       if (tr32(RDMAC_STATUS)) {
+               netdev_err(tp->dev, "RDMA Status error.  Resetting chip=
=2E\n");
+               real_error =3D true;
+       }
+       if (tr32(WDMAC_STATUS)) {
+               netdev_err(tp->dev, "WDMA Status error.  Resetting chip=
=2E\n");
                real_error =3D true;
        }
=20


# lspci -v -s 09:00.0
09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755M Gi=
gabit Ethernet PCI Express (rev 02)
	Subsystem: Dell Device 01f9
	Flags: bus master, fast devsel, latency 0, IRQ 45
	Memory at f1ef0000 (64-bit, non-prefetchable) [size=3D64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Vendor Specific Information: Len=3D78 <?>
	Capabilities: [e8] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
	Capabilities: [d0] Express Endpoint, MSI 00
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [13c] Virtual Channel
	Capabilities: [160] Device Serial Number 00-21-70-ff-fe-b0-e4-89
	Capabilities: [16c] Power Budgeting <?>
	Kernel driver in use: tg3
	Kernel modules: tg3

dmesg :

Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Initializ=
ing cgroup subsys cpuset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Initializ=
ing cgroup subsys cpu
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Linux ver=
sion 3.5.0-rc5+ (root@edumazet-Latitude-D630) (gcc version 4.6.3 (Ubunt=
u/Linaro 4.6.3-1ubuntu5) ) #10 SMP Mon Jul 16 20:05:18 CEST 2012
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] e820: BIO=
S-provided physical RAM map:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x0000000000000000-0x000000000009efff] usable
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x000000000009f000-0x000000000009ffff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x0000000000100000-0x00000000dfe5a7ff] usable
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x00000000dfe5a800-0x00000000dfffffff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x00000000fec00000-0x00000000fec0ffff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x00000000fed18000-0x00000000fed1bfff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x00000000fed20000-0x00000000fed8ffff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x00000000feda0000-0x00000000feda5fff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x00000000fee00000-0x00000000fee0ffff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x00000000ffe00000-0x00000000ffffffff] reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] BIOS-e820=
: [mem 0x0000000100002000-0x000000011fffffff] usable
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Notice: N=
X (Execute Disable) protection cannot be enabled: non-PAE kernel!
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] DMI 2.4 p=
resent.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] DMI: Dell=
 Inc. Latitude D630                   /0WM416, BIOS A15 11/24/2008
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] e820: upd=
ate [mem 0x00000000-0x0000ffff] usable =3D=3D> reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] e820: rem=
ove [mem 0x000a0000-0x000fffff] usable
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] e820: las=
t_pfn =3D 0xdfe5a max_arch_pfn =3D 0x100000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] MTRR defa=
ult type: uncachable
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] MTRR fixe=
d ranges enabled:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   00000-9=
=46FFF write-back
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   A0000-B=
=46FFF uncachable
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   C0000-C=
=46FFF write-protect
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   D0000-E=
=46FFF uncachable
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   F0000-F=
=46FFF write-protect
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] MTRR vari=
able ranges enabled:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   0 base =
000000000 mask F80000000 write-back
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   1 base =
080000000 mask FC0000000 write-back
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   2 base =
0C0000000 mask FE0000000 write-back
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   3 base =
100000000 mask FE0000000 write-back
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   4 base =
0DFF00000 mask FFFF00000 uncachable
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   5 disab=
led
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   6 disab=
led
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   7 disab=
led
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] x86 PAT e=
nabled: cpu 0, old 0x7040600070406, new 0x7010600070106
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] e820: upd=
ate [mem 0xdff00000-0xffffffff] usable =3D=3D> reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] initial m=
emory mapped: [mem 0x00000000-0x01bfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Base memo=
ry trampoline at [c009b000] 9b000 size 16384
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] init_memo=
ry_mapping: [mem 0x00000000-0x377fdfff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]  [mem 0x0=
0000000-0x003fffff] page 4k
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]  [mem 0x0=
0400000-0x373fffff] page 2M
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]  [mem 0x3=
7400000-0x377fdfff] page 4k
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] kernel di=
rect mapping tables up to 0x377fdfff @ [mem 0x01bfa000-0x01bfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] RAMDISK: =
[mem 0x37bae000-0x37dcefff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Allocated=
 new RAMDISK: [mem 0x375dd000-0x377fd4af]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Move RAMD=
ISK from [mem 0x37bae000-0x37dce4af] to [mem 0x375dd000-0x377fd4af]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: RSD=
P 000fbb10 00024 (v02 DELL  )
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: XSD=
T dfe5d200 00064 (v01 DELL    M08     27D80B18 ASL  00000061)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: FAC=
P dfe5d09c 000F4 (v04 DELL    M08     27D80B18 ASL  00000061)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: DSD=
T dfe5d800 06114 (v02 INT430 SYSFexxx 00001001 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: FAC=
S dfe6c000 00040
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: HPE=
T dfe5d300 00038 (v01 DELL    M08     00000001 ASL  00000061)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: API=
C dfe5d400 00068 (v01 DELL    M08     27D80B18 ASL  00000047)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: ASF=
! dfe5d000 0007E (v32 DELL    M08     27D80B18 ASL  00000061)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: MCF=
G dfe5d3c0 0003E (v16 DELL    M08     27D80B18 ASL  00000061)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: TCP=
A dfe5d700 00032 (v01                 00000000 ASL  00000000)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: SLI=
C dfe5d49c 00176 (v01 DELL    M08     27D80B18 ASL  00000061)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: SSD=
T dfe5b97e 004CC (v01  PmRef    CpuPm 00003000 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: Loc=
al APIC address 0xfee00000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] 2694MB HI=
GHMEM available.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] 887MB LOW=
MEM available.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   mapped =
low ram: 0 - 377fe000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   low ram=
: 0 - 377fe000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Zone rang=
es:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   DMA    =
  [mem 0x00010000-0x00ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   Normal =
  [mem 0x01000000-0x377fdfff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   HighMem=
  [mem 0x377fe000-0xdfe59fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Movable z=
one start for each node
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Early mem=
ory node ranges
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   node   =
0: [mem 0x00010000-0x0009efff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   node   =
0: [mem 0x00100000-0xdfe59fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] On node 0=
 totalpages: 916969
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   DMA zon=
e: 32 pages used for memmap
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   DMA zon=
e: 0 pages reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   DMA zon=
e: 3951 pages, LIFO batch:0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   Normal =
zone: 1744 pages used for memmap
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   Normal =
zone: 221486 pages, LIFO batch:31
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   HighMem=
 zone: 5389 pages used for memmap
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]   HighMem=
 zone: 684367 pages, LIFO batch:31
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Using API=
C driver default
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: PM-=
Timer IO Port: 0x1008
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: Loc=
al APIC address 0xfee00000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: LAP=
IC (acpi_id[0x00] lapic_id[0x00] enabled)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: LAP=
IC (acpi_id[0x01] lapic_id[0x01] enabled)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: LAP=
IC_NMI (acpi_id[0x00] high edge lint[0x1])
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: LAP=
IC_NMI (acpi_id[0x01] high edge lint[0x1])
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: IOA=
PIC (id[0x02] address[0xfec00000] gsi_base[0])
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] IOAPIC[0]=
: apic_id 2, version 32, address 0xfec00000, GSI 0-23
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: INT=
_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: INT=
_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: IRQ=
0 used by override.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: IRQ=
2 used by override.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: IRQ=
9 used by override.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Using ACP=
I (MADT) for SMP configuration information
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] ACPI: HPE=
T id: 0x8086a201 base: 0xfed00000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] SMP: Allo=
wing 2 CPUs, 0 hotplug CPUs
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] nr_irqs_g=
si: 40
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] PM: Regis=
tered nosave memory: 000000000009f000 - 00000000000a0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] PM: Regis=
tered nosave memory: 00000000000a0000 - 0000000000100000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] e820: [me=
m 0xe0000000-0xf7ffffff] available for PCI devices
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] setup_per=
cpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_node_ids:1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] PERCPU: E=
mbedded 13 pages/cpu @f59b0000 s29344 r0 d23904 u53248
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] pcpu-allo=
c: s29344 r0 d23904 u53248 alloc=3D13*4096
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] pcpu-allo=
c: [0] 0 [0] 1=20
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Built 1 z=
onelists in Zone order, mobility grouping on.  Total pages: 909804
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Kernel co=
mmand line: BOOT_IMAGE=3D/boot/vmlinuz-3.5.0-rc5+ root=3DUUID=3D09c56f8=
7-9f0f-472f-9825-45848444856d ro quiet splash vt.handoff=3D7
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] PID hash =
table entries: 4096 (order: 2, 16384 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Dentry ca=
che hash table entries: 131072 (order: 7, 524288 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Inode-cac=
he hash table entries: 65536 (order: 6, 262144 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] __ex_tabl=
e already sorted, skipping sort
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Initializ=
ing CPU#0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Initializ=
ing HighMem for node 0 (000377fe:000dfe5a)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Memory: 3=
627252k/3668328k available (4954k kernel code, 40624k reserved, 2699k d=
ata, 432k init, 2759024k highmem)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] virtual k=
ernel memory layout:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]     fixma=
p  : 0xfff16000 - 0xfffff000   ( 932 kB)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]     pkmap=
   : 0xff800000 - 0xffc00000   (4096 kB)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]     vmall=
oc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]     lowme=
m  : 0xc0000000 - 0xf77fe000   ( 887 MB)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]       .in=
it : 0xc177a000 - 0xc17e6000   ( 432 kB)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]       .da=
ta : 0xc14d6ad2 - 0xc17799a0   (2699 kB)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000]       .te=
xt : 0xc1000000 - 0xc14d6ad2   (4954 kB)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Checking =
if this processor honours the WP bit even in supervisor mode...Ok.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] SLUB: Gen=
slabs=3D15, HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D2, Nodes=3D=
1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Hierarchi=
cal RCU implementation.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] NR_IRQS:2=
304 nr_irqs:512 16
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] CPU 0 irq=
stacks, hard=3Df5408000 soft=3Df540a000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Extended =
CMOS year: 2000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Console: =
colour dummy device 80x25
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] console [=
tty0] enabled
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] hpet cloc=
kevent registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Fast TSC =
calibration using PIT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.000000] Detected =
2393.198 MHz processor.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001001] Calibrati=
ng delay loop (skipped), value calculated using timer frequency.. 4786.=
39 BogoMIPS (lpj=3D2393198)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001004] pid_max: =
default: 32768 minimum: 301
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001039] Security =
=46ramework initialized
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001041] SELinux: =
 Initializing.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001049] SELinux: =
 Starting in permissive mode
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001061] Mount-cac=
he hash table entries: 512
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001255] Initializ=
ing cgroup subsys cpuacct
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001257] Initializ=
ing cgroup subsys freezer
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001280] CPU: Phys=
ical Processor ID: 0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001281] CPU: Proc=
essor Core ID: 0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001283] mce: CPU =
supports 6 MCE banks
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001289] CPU0: The=
rmal monitoring enabled (TM2)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001291] using mwa=
it in idle threads.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001355] ACPI: Cor=
e revision 20120320
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.005041] Enabling =
APIC mode:  Flat.  Using 1 I/O APICs
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.006181] ..TIMER: =
vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016192] CPU0: Int=
el(R) Core(TM)2 Duo CPU     T8300  @ 2.40GHz stepping 06
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] Performan=
ce Events: PEBS fmt0+, 4-deep LBR, Core2 events, Intel PMU driver.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] ... versi=
on:                2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] ... bit w=
idth:              40
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] ... gener=
ic registers:      2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] ... value=
 mask:             000000ffffffffff
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] ... max p=
eriod:             000000007fffffff
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] ... fixed=
-purpose events:   3
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] ... event=
 mask:             0000000700000003
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] CPU 1 irq=
stacks, hard=3Df547c000 soft=3Df547e000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.016998] Booting N=
ode   0, Processors  #1 Ok.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.001999] Initializ=
ing CPU#1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.028011] Brought u=
p 2 CPUs
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.028014] Total of =
2 processors activated (9572.79 BogoMIPS).
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.030270] RTC time:=
  5:15:21, date: 07/17/12
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.030270] NET: Regi=
stered protocol family 16
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.030373] kworker/u=
:0 (14) used greatest stack depth: 7192 bytes left
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.031134] ACPI: bus=
 type pci registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.031147] PCI: MMCO=
NFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0=
xf8000000)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.031147] PCI: MMCO=
NFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.031147] PCI: Usin=
g MMCONFIG for extended config space
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.031147] PCI: Usin=
g configuration type 1 for base access
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.031147] dmi type =
0xB1 record - unknown flag
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.031147] kworker/u=
:0 (38) used greatest stack depth: 7008 bytes left
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.039028] bio: crea=
te slab <bio-0> at 0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.039053] ACPI: Add=
ed _OSI(Module Device)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.039053] ACPI: Add=
ed _OSI(Processor Device)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.039053] ACPI: Add=
ed _OSI(3.0 _SCP Extensions)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.039053] ACPI: Add=
ed _OSI(Processor Aggregator Device)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.040593] ACPI: EC:=
 Look up EC in DSDT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.046576] [Firmware=
 Bug]: ACPI: BIOS _OSI(Linux) query ignored
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.050841] ACPI: SSD=
T dfe6c080 00043 (v01  LMPWR  DELLLOM 00001001 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.051040] ACPI: Dyn=
amic OEM Table Load:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.051043] ACPI: SSD=
T   (null) 00043 (v01  LMPWR  DELLLOM 00001001 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.051287] ACPI: SSD=
T dfe5c4b4 002C8 (v01  PmRef  Cpu0Ist 00003000 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.051494] ACPI: Dyn=
amic OEM Table Load:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.051496] ACPI: SSD=
T   (null) 002C8 (v01  PmRef  Cpu0Ist 00003000 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.051614] ACPI: SSD=
T dfe5be4a 005E5 (v01  PmRef  Cpu0Cst 00003001 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.051806] ACPI: Dyn=
amic OEM Table Load:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.051809] ACPI: SSD=
T   (null) 005E5 (v01  PmRef  Cpu0Cst 00003001 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.054181] ACPI: SSD=
T dfe5c77c 000C4 (v01  PmRef  Cpu1Ist 00003000 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.054382] ACPI: Dyn=
amic OEM Table Load:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.054385] ACPI: SSD=
T   (null) 000C4 (v01  PmRef  Cpu1Ist 00003000 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.054458] ACPI: SSD=
T dfe5c42f 00085 (v01  PmRef  Cpu1Cst 00003000 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.054651] ACPI: Dyn=
amic OEM Table Load:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.054654] ACPI: SSD=
T   (null) 00085 (v01  PmRef  Cpu1Cst 00003000 INTL 20050624)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.057156] ACPI: Int=
erpreter enabled
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.057164] ACPI: (su=
pports S0 S3 S4 S5)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.057179] ACPI: Usi=
ng IOAPIC for interrupt routing
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.114537] ACPI: ACP=
I Dock Station Driver: 3 docks/bays found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.114544] PCI: Usin=
g host bridge windows from ACPI; if necessary, use "pci=3Dnocrs" and re=
port a bug
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.121807] ACPI: PCI=
 Root Bridge [PCI0] (domain 0000 [bus 00-ff])
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136309] pci_root =
PNP0A03:00: host bridge window [io  0x0000-0x0cf7]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136312] pci_root =
PNP0A03:00: host bridge window [io  0x0d00-0xffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136314] pci_root =
PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136317] pci_root =
PNP0A03:00: host bridge window [mem 0x000d0000-0x000dffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136319] pci_root =
PNP0A03:00: host bridge window [mem 0xe0000000-0xf7ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136321] pci_root =
PNP0A03:00: host bridge window [mem 0xfc000000-0xfebfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136324] pci_root =
PNP0A03:00: host bridge window [mem 0xfec10000-0xfecfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136326] pci_root =
PNP0A03:00: host bridge window [mem 0xfed1c000-0xfed1ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136328] pci_root =
PNP0A03:00: host bridge window [mem 0xfed90000-0xfed9ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136331] pci_root =
PNP0A03:00: host bridge window [mem 0xfed40000-0xfed44fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136333] pci_root =
PNP0A03:00: host bridge window [mem 0xfeda7000-0xfedfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136335] pci_root =
PNP0A03:00: host bridge window [mem 0xfee10000-0xff9fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136338] pci_root =
PNP0A03:00: host bridge window [mem 0xffc00000-0xffdfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] PCI host =
bridge to bus 0000:00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [io  0x0000-0x0cf7]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [io  0x0d00-0xffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0x000a0000-0x000bffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0x000d0000-0x000dffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xe0000000-0xf7ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xfc000000-0xfebfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xfec10000-0xfecfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xfed1c000-0xfed1ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xfed90000-0xfed9ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xfed40000-0xfed44fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xfeda7000-0xfedfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xfee10000-0xff9fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci_bus 0=
000:00: root bus resource [mem 0xffc00000-0xffdfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci 0000:=
00:00.0: [8086:2a00] type 00 class 0x060000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci 0000:=
00:01.0: [8086:2a01] type 01 class 0x060400
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci 0000:=
00:01.0: PME# supported from D0 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci 0000:=
00:1a.0: [8086:2834] type 00 class 0x0c0300
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci 0000:=
00:1a.0: reg 20: [io  0x6f20-0x6f3f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci 0000:=
00:1a.1: [8086:2835] type 00 class 0x0c0300
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136371] pci 0000:=
00:1a.1: reg 20: [io  0x6f00-0x6f1f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136396] pci 0000:=
00:1a.7: [8086:283a] type 00 class 0x0c0320
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136420] pci 0000:=
00:1a.7: reg 10: [mem 0xfed1c400-0xfed1c7ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136527] pci 0000:=
00:1a.7: PME# supported from D0 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136561] pci 0000:=
00:1b.0: [8086:284b] type 00 class 0x040300
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.136583] pci 0000:=
00:1b.0: reg 10: [mem 0xf6ffc000-0xf6ffffff 64bit]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137082] pci 0000:=
00:1b.0: PME# supported from D0 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137115] pci 0000:=
00:1c.0: [8086:283f] type 01 class 0x060400
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137225] pci 0000:=
00:1c.0: PME# supported from D0 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137258] pci 0000:=
00:1c.1: [8086:2841] type 01 class 0x060400
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137368] pci 0000:=
00:1c.1: PME# supported from D0 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137405] pci 0000:=
00:1c.5: [8086:2849] type 01 class 0x060400
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137515] pci 0000:=
00:1c.5: PME# supported from D0 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137545] pci 0000:=
00:1d.0: [8086:2830] type 00 class 0x0c0300
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137601] pci 0000:=
00:1d.0: reg 20: [io  0x6f80-0x6f9f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137644] pci 0000:=
00:1d.1: [8086:2831] type 00 class 0x0c0300
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137700] pci 0000:=
00:1d.1: reg 20: [io  0x6f60-0x6f7f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137743] pci 0000:=
00:1d.2: [8086:2832] type 00 class 0x0c0300
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137799] pci 0000:=
00:1d.2: reg 20: [io  0x6f40-0x6f5f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137855] pci 0000:=
00:1d.7: [8086:2836] type 00 class 0x0c0320
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137879] pci 0000:=
00:1d.7: reg 10: [mem 0xfed1c000-0xfed1c3ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.137989] pci 0000:=
00:1d.7: PME# supported from D0 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138015] pci 0000:=
00:1e.0: [8086:2448] type 01 class 0x060401
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138112] pci 0000:=
00:1f.0: [8086:2815] type 00 class 0x060100
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138226] pci 0000:=
00:1f.0: quirk: [io  0x1000-0x107f] claimed by ICH6 ACPI/GPIO/TCO
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138232] pci 0000:=
00:1f.0: quirk: [io  0x1080-0x10bf] claimed by ICH6 GPIO
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138237] pci 0000:=
00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0900 (mask 007f)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138243] pci 0000:=
00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 0c80 (mask 003f)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138300] pci 0000:=
00:1f.1: [8086:2850] type 00 class 0x01018a
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138317] pci 0000:=
00:1f.1: reg 10: [io  0x01f0-0x01f7]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138330] pci 0000:=
00:1f.1: reg 14: [io  0x03f4-0x03f7]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138342] pci 0000:=
00:1f.1: reg 18: [io  0x0170-0x0177]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138354] pci 0000:=
00:1f.1: reg 1c: [io  0x0374-0x0377]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138366] pci 0000:=
00:1f.1: reg 20: [io  0x6fa0-0x6faf]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138414] pci 0000:=
00:1f.2: [8086:2828] type 00 class 0x01018f
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138435] pci 0000:=
00:1f.2: reg 10: [io  0x6eb0-0x6eb7]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138447] pci 0000:=
00:1f.2: reg 14: [io  0x6eb8-0x6ebb]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138459] pci 0000:=
00:1f.2: reg 18: [io  0x6ec0-0x6ec7]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138471] pci 0000:=
00:1f.2: reg 1c: [io  0x6ec8-0x6ecb]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138483] pci 0000:=
00:1f.2: reg 20: [io  0x6ee0-0x6eef]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138496] pci 0000:=
00:1f.2: reg 24: [io  0xeff0-0xefff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138541] pci 0000:=
00:1f.2: PME# supported from D3hot
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138560] pci 0000:=
00:1f.3: [8086:283e] type 00 class 0x0c0500
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138577] pci 0000:=
00:1f.3: reg 10: [mem 0xf6ffbf00-0xf6ffbfff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138619] pci 0000:=
00:1f.3: reg 20: [io  0x10c0-0x10df]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138706] pci 0000:=
01:00.0: [10de:042b] type 00 class 0x030000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138725] pci 0000:=
01:00.0: reg 10: [mem 0xf5000000-0xf5ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138746] pci 0000:=
01:00.0: reg 14: [mem 0xe0000000-0xefffffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138767] pci 0000:=
01:00.0: reg 1c: [mem 0xf2000000-0xf3ffffff 64bit]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138781] pci 0000:=
01:00.0: reg 24: [io  0xdf00-0xdf7f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138795] pci 0000:=
01:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138896] pci 0000:=
00:01.0: PCI bridge to [bus 01-01]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138900] pci 0000:=
00:01.0:   bridge window [io  0xd000-0xdfff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138903] pci 0000:=
00:01.0:   bridge window [mem 0xf2000000-0xf6efffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138908] pci 0000:=
00:01.0:   bridge window [mem 0xe0000000-0xefffffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.138968] pci 0000:=
00:1c.0: PCI bridge to [bus 0b-0b]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139069] pci 0000:=
0c:00.0: [14e4:4312] type 00 class 0x028000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139093] pci 0000:=
0c:00.0: reg 10: [mem 0xf1ffc000-0xf1ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139260] pci 0000:=
0c:00.0: supports D1 D2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139284] pci 0000:=
0c:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with=
 'pcie_aspm=3Dforce'
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139297] pci 0000:=
00:1c.1: PCI bridge to [bus 0c-0c]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139305] pci 0000:=
00:1c.1:   bridge window [mem 0xf1f00000-0xf1ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139404] pci 0000:=
09:00.0: [14e4:1673] type 00 class 0x020000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139437] pci 0000:=
09:00.0: reg 10: [mem 0xf1ef0000-0xf1efffff 64bit]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.139623] pci 0000:=
09:00.0: PME# supported from D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141006] pci 0000:=
00:1c.5: PCI bridge to [bus 09-09]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141014] pci 0000:=
00:1c.5:   bridge window [mem 0xf1e00000-0xf1efffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141070] pci 0000:=
03:01.0: [1217:7135] type 02 class 0x060700
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141096] pci 0000:=
03:01.0: reg 10: [mem 0x00000000-0x00000fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141139] pci 0000:=
03:01.0: supports D1 D2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141141] pci 0000:=
03:01.0: PME# supported from D0 D1 D2 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141172] pci 0000:=
03:01.4: [1217:00f7] type 00 class 0x0c0010
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141193] pci 0000:=
03:01.4: reg 10: [mem 0xf1dff000-0xf1dfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141206] pci 0000:=
03:01.4: reg 14: [mem 0xf1dfe800-0xf1dfefff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141290] pci 0000:=
03:01.4: supports D1 D2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141292] pci 0000:=
03:01.4: PME# supported from D0 D1 D2 D3hot D3cold
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141365] pci 0000:=
00:1e.0: PCI bridge to [bus 03-04] (subtractive decode)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141373] pci 0000:=
00:1e.0:   bridge window [mem 0xf1d00000-0xf1dfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141382] pci 0000:=
00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141384] pci 0000:=
00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141387] pci 0000:=
00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141389] pci 0000:=
00:1e.0:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141391] pci 0000:=
00:1e.0:   bridge window [mem 0xe0000000-0xf7ffffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141394] pci 0000:=
00:1e.0:   bridge window [mem 0xfc000000-0xfebfffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141396] pci 0000:=
00:1e.0:   bridge window [mem 0xfec10000-0xfecfffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141399] pci 0000:=
00:1e.0:   bridge window [mem 0xfed1c000-0xfed1ffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141401] pci 0000:=
00:1e.0:   bridge window [mem 0xfed90000-0xfed9ffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141404] pci 0000:=
00:1e.0:   bridge window [mem 0xfed40000-0xfed44fff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141406] pci 0000:=
00:1e.0:   bridge window [mem 0xfeda7000-0xfedfffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141409] pci 0000:=
00:1e.0:   bridge window [mem 0xfee10000-0xff9fffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141411] pci 0000:=
00:1e.0:   bridge window [mem 0xffc00000-0xffdfffff] (subtractive decod=
e)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141463] pci_bus 0=
000:04: [bus 04-07] partially hidden behind transparent bridge 0000:03 =
[bus 03-04]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141494] pci_bus 0=
000:00: on NUMA node 0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141497] ACPI: PCI=
 Interrupt Routing Table [\_SB_.PCI0._PRT]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141711] ACPI: PCI=
 Interrupt Routing Table [\_SB_.PCI0.PCIE._PRT]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141799] ACPI: PCI=
 Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141835] ACPI: PCI=
 Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141876] ACPI: PCI=
 Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141923] ACPI: PCI=
 Interrupt Routing Table [\_SB_.PCI0.RP06._PRT]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141962]  pci0000:=
00: Requesting ACPI _OSC control (0x1d)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141965]  pci0000:=
00: ACPI _OSC request failed (AE_NOT_FOUND), returned control mask: 0x1=
d
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.141966] ACPI _OSC=
 control for PCIe not granted, disabling ASPM
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155051] ACPI: PCI=
 Interrupt Link [LNKA] (IRQs 9 10 11) *5
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155112] ACPI: PCI=
 Interrupt Link [LNKB] (IRQs 5 7) *3
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155170] ACPI: PCI=
 Interrupt Link [LNKC] (IRQs 9 *10 11)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155227] ACPI: PCI=
 Interrupt Link [LNKD] (IRQs 5 7 *9 10 11)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155285] ACPI: PCI=
 Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155346] ACPI: PCI=
 Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155407] ACPI: PCI=
 Interrupt Link [LNKG] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155459] ACPI: PCI=
 Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155497] vgaarb: d=
evice added: PCI:0000:01:00.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dno=
ne
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155497] vgaarb: l=
oaded
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.155497] vgaarb: b=
ridge control possible 0000:01:00.0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.156009] SCSI subs=
ystem initialized
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.156009] libata ve=
rsion 3.00 loaded.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.156014] ACPI: bus=
 type usb registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.156016] usbcore: =
registered new interface driver usbfs
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.156016] usbcore: =
registered new interface driver hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.156016] usbcore: =
registered new device driver usb
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.156016] Advanced =
Linux Sound Architecture Driver Version 1.0.25.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.156016] PCI: Usin=
g ACPI for IRQ routing
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159164] PCI: pci_=
cache_line_size set to 64 bytes
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159266] e820: res=
erve RAM buffer [mem 0x0009f000-0x0009ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159268] e820: res=
erve RAM buffer [mem 0xdfe5a800-0xdfffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159286] cfg80211:=
 Calling CRDA to update world regulatory domain
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159286] NetLabel:=
 Initializing
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159286] NetLabel:=
  domain hash size =3D 128
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159286] NetLabel:=
  protocols =3D UNLABELED CIPSOv4
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159286] NetLabel:=
  unlabeled traffic allowed by default
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159286] HPET: 3 t=
imers in total, 0 timers will be used for per-cpu timer
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159286] hpet0: at=
 MMIO 0xfed00000, IRQs 2, 8, 0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.159286] hpet0: 3 =
comparators, 64-bit 14.318180 MHz counter
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.162000] Switching=
 to clocksource hpet
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.165877] pnp: PnP =
ACPI init
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.165886] ACPI: bus=
 type pnp registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173080] pnp 00:00=
: [bus 00-ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173083] pnp 00:00=
: [io  0x0000-0x0cf7 window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173085] pnp 00:00=
: [io  0x0cf8-0x0cff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173088] pnp 00:00=
: [io  0x0d00-0xffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173090] pnp 00:00=
: [mem 0x000a0000-0x000bffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173092] pnp 00:00=
: [mem 0x000d0000-0x000dffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173095] pnp 00:00=
: [mem 0xe0000000-0xf7ffffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173097] pnp 00:00=
: [mem 0xfc000000-0xfebfffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173099] pnp 00:00=
: [mem 0xfec10000-0xfecfffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173102] pnp 00:00=
: [mem 0xfed1c000-0xfed1ffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173104] pnp 00:00=
: [mem 0xfed90000-0xfed9ffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173106] pnp 00:00=
: [mem 0xfed40000-0xfed44fff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173108] pnp 00:00=
: [mem 0xfeda7000-0xfedfffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173111] pnp 00:00=
: [mem 0xfee10000-0xff9fffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173113] pnp 00:00=
: [mem 0xffc00000-0xffdfffff window]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173200] pnp 00:00=
: Plug and Play ACPI device, IDs PNP0a03 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173227] pnp 00:01=
: [irq 12]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173276] pnp 00:01=
: Plug and Play ACPI device, IDs PNP0f13 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173292] pnp 00:02=
: [io  0x0060]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173294] pnp 00:02=
: [io  0x0064]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173296] pnp 00:02=
: [io  0x0062]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173298] pnp 00:02=
: [io  0x0066]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173304] pnp 00:02=
: [irq 1]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173356] pnp 00:02=
: Plug and Play ACPI device, IDs PNP0303 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173373] pnp 00:03=
: [io  0x0070-0x0071]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173380] pnp 00:03=
: [irq 8]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173382] pnp 00:03=
: [io  0x0072-0x0077]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173431] pnp 00:03=
: Plug and Play ACPI device, IDs PNP0b00 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173447] pnp 00:04=
: [io  0x0061]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173449] pnp 00:04=
: [io  0x0063]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173451] pnp 00:04=
: [io  0x0065]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173453] pnp 00:04=
: [io  0x0067]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173503] pnp 00:04=
: Plug and Play ACPI device, IDs PNP0800 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173518] pnp 00:05=
: [io  0x002e-0x002f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173520] pnp 00:05=
: [io  0x0c80-0x0caf]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173522] pnp 00:05=
: [io  0x0cc0-0x0cff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173524] pnp 00:05=
: [io  0x004e-0x004f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173596] system 00=
:05: [io  0x0c80-0x0caf] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173599] system 00=
:05: [io  0x0cc0-0x0cff] could not be reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173602] system 00=
:05: Plug and Play ACPI device, IDs PNP0c01 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173619] pnp 00:06=
: [dma 4]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173621] pnp 00:06=
: [io  0x0000-0x000f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173623] pnp 00:06=
: [io  0x0080-0x0085]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173625] pnp 00:06=
: [io  0x0087-0x008f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173627] pnp 00:06=
: [io  0x00c0-0x00df]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173629] pnp 00:06=
: [io  0x0010-0x001f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173631] pnp 00:06=
: [io  0x0090-0x0091]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173633] pnp 00:06=
: [io  0x0093-0x009f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173683] pnp 00:06=
: Plug and Play ACPI device, IDs PNP0200 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173697] pnp 00:07=
: [io  0x00f0-0x00ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173703] pnp 00:07=
: [irq 13]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173753] pnp 00:07=
: Plug and Play ACPI device, IDs PNP0c04 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173786] pnp 00:08=
: [mem 0xfed00000-0xfed003ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173857] system 00=
:08: [mem 0xfed00000-0xfed003ff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.173860] system 00=
:08: Plug and Play ACPI device, IDs PNP0103 PNP0c01 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.179278] pnp 00:09=
: [irq 4]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.179281] pnp 00:09=
: [io  0x03f8-0x03ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.179364] pnp 00:09=
: Plug and Play ACPI device, IDs PNP0501 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.193593] pnp 00:0a=
: [mem 0xfed40000-0xfed44fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.193596] pnp 00:0a=
: [io  0x0cb0-0x0cbb]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.193669] system 00=
:0a: [io  0x0cb0-0x0cbb] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.193672] system 00=
:0a: [mem 0xfed40000-0xfed44fff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.193675] system 00=
:0a: Plug and Play ACPI device, IDs PNP0c01 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196421] pnp 00:0b=
: [io  0x0900-0x097f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196424] pnp 00:0b=
: [io  0x0092]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196426] pnp 00:0b=
: [io  0x00b2-0x00b3]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196428] pnp 00:0b=
: [io  0x0020-0x0021]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196430] pnp 00:0b=
: [io  0x00a0-0x00a1]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196432] pnp 00:0b=
: [irq 0 disabled]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196434] pnp 00:0b=
: [io  0x04d0-0x04d1]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196437] pnp 00:0b=
: [io  0x1000-0x1005]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196439] pnp 00:0b=
: [io  0x1008-0x100f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196453] pnp 00:0b=
: disabling [io  0x1000-0x1005] because it overlaps 0000:00:1f.0 BAR 7 =
[io  0x1000-0x107f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196456] pnp 00:0b=
: disabling [io  0x1008-0x100f] because it overlaps 0000:00:1f.0 BAR 7 =
[io  0x1000-0x107f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196535] system 00=
:0b: [io  0x0900-0x097f] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196538] system 00=
:0b: [io  0x04d0-0x04d1] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196541] system 00=
:0b: Plug and Play ACPI device, IDs PNP0c01 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196557] pnp 00:0c=
: [io  0xf400-0xf4fe]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196559] pnp 00:0c=
: [io  0x0086]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196561] pnp 00:0c=
: [io  0x1006-0x1007]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196563] pnp 00:0c=
: [io  0x100a-0x1059]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196565] pnp 00:0c=
: [io  0x1060-0x107f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196567] pnp 00:0c=
: [io  0x1080-0x10bf]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196569] pnp 00:0c=
: [io  0x10c0-0x10df]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196571] pnp 00:0c=
: [io  0x1010-0x102f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196574] pnp 00:0c=
: [io  0x0809]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196587] pnp 00:0c=
: disabling [io  0x1006-0x1007] because it overlaps 0000:00:1f.0 BAR 7 =
[io  0x1000-0x107f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196590] pnp 00:0c=
: disabling [io  0x100a-0x1059] because it overlaps 0000:00:1f.0 BAR 7 =
[io  0x1000-0x107f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196593] pnp 00:0c=
: disabling [io  0x1060-0x107f] because it overlaps 0000:00:1f.0 BAR 7 =
[io  0x1000-0x107f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196596] pnp 00:0c=
: disabling [io  0x1010-0x102f] because it overlaps 0000:00:1f.0 BAR 7 =
[io  0x1000-0x107f]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196673] system 00=
:0c: [io  0xf400-0xf4fe] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196676] system 00=
:0c: [io  0x1080-0x10bf] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196679] system 00=
:0c: [io  0x10c0-0x10df] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196682] system 00=
:0c: [io  0x0809] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.196685] system 00=
:0c: Plug and Play ACPI device, IDs PNP0c01 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215137] pnp 00:0d=
: [mem 0x00000000-0x0009efff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215140] pnp 00:0d=
: [mem 0x0009f000-0x0009ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215142] pnp 00:0d=
: [mem 0x000c0000-0x000cffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215144] pnp 00:0d=
: [mem 0x000e0000-0x000fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215146] pnp 00:0d=
: [mem 0x00100000-0xdfe5a7ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215148] pnp 00:0d=
: [mem 0xdfe5a800-0xdfefffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215150] pnp 00:0d=
: [mem 0xdff00000-0xdfffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215152] pnp 00:0d=
: [mem 0xdff00000-0xe06fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215155] pnp 00:0d=
: [mem 0xffe00000-0xffffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215157] pnp 00:0d=
: [mem 0xffa00000-0xffbfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215159] pnp 00:0d=
: [mem 0xfec00000-0xfec0ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215161] pnp 00:0d=
: [mem 0xfee00000-0xfee0ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215163] pnp 00:0d=
: [mem 0xfed20000-0xfed3ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215165] pnp 00:0d=
: [mem 0xfed45000-0xfed8ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215169] pnp 00:0d=
: [mem 0xfeda0000-0xfeda3fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215171] pnp 00:0d=
: [mem 0xfeda4000-0xfeda4fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215173] pnp 00:0d=
: [mem 0xfeda5000-0xfeda5fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215176] pnp 00:0d=
: [mem 0xfeda6000-0xfeda6fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215178] pnp 00:0d=
: [mem 0xfed18000-0xfed1bfff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215180] pnp 00:0d=
: [mem 0xf8000000-0xfbffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215187] pnp 00:0d=
: disabling [mem 0xdff00000-0xe06fffff] because it overlaps 0000:00:01.=
0 BAR 9 [mem 0xe0000000-0xefffffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215207] pnp 00:0d=
: disabling [mem 0xdff00000-0xe06fffff disabled] because it overlaps 00=
00:01:00.0 BAR 1 [mem 0xe0000000-0xefffffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215293] system 00=
:0d: [mem 0x00000000-0x0009efff] could not be reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215297] system 00=
:0d: [mem 0x0009f000-0x0009ffff] could not be reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215299] system 00=
:0d: [mem 0x000c0000-0x000cffff] could not be reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215302] system 00=
:0d: [mem 0x000e0000-0x000fffff] could not be reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215305] system 00=
:0d: [mem 0x00100000-0xdfe5a7ff] could not be reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215308] system 00=
:0d: [mem 0xdfe5a800-0xdfefffff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215310] system 00=
:0d: [mem 0xdff00000-0xdfffffff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215313] system 00=
:0d: [mem 0xffe00000-0xffffffff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215316] system 00=
:0d: [mem 0xffa00000-0xffbfffff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215319] system 00=
:0d: [mem 0xfec00000-0xfec0ffff] could not be reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215321] system 00=
:0d: [mem 0xfee00000-0xfee0ffff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215324] system 00=
:0d: [mem 0xfed20000-0xfed3ffff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215327] system 00=
:0d: [mem 0xfed45000-0xfed8ffff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215330] system 00=
:0d: [mem 0xfeda0000-0xfeda3fff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215333] system 00=
:0d: [mem 0xfeda4000-0xfeda4fff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215335] system 00=
:0d: [mem 0xfeda5000-0xfeda5fff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215338] system 00=
:0d: [mem 0xfeda6000-0xfeda6fff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215341] system 00=
:0d: [mem 0xfed18000-0xfed1bfff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215343] system 00=
:0d: [mem 0xf8000000-0xfbffffff] has been reserved
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215346] system 00=
:0d: Plug and Play ACPI device, IDs PNP0c01 (active)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215389] pnp: PnP =
ACPI: found 14 devices
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.215391] ACPI: ACP=
I bus type pnp unregistered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253743] pci 0000:=
00:1c.0: bridge window [io  0x1000-0x0fff] to [bus 0b-0b] add_size 1000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253747] pci 0000:=
00:1c.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 0=
b-0b] add_size 200000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253751] pci 0000:=
00:1c.0: bridge window [mem 0x00100000-0x000fffff] to [bus 0b-0b] add_s=
ize 200000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253763] pci 0000:=
00:1c.1: bridge window [io  0x1000-0x0fff] to [bus 0c-0c] add_size 1000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253766] pci 0000:=
00:1c.1: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 0=
c-0c] add_size 200000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253778] pci 0000:=
00:1c.5: bridge window [io  0x1000-0x0fff] to [bus 09-09] add_size 1000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253781] pci 0000:=
00:1c.5: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 0=
9-09] add_size 200000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253800] pci 0000:=
03:01.0: res[7]=3D[io  0x0100-0x00ff] get_res_add_size add_size 100
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253803] pci 0000:=
03:01.0: res[8]=3D[io  0x0100-0x00ff] get_res_add_size add_size 100
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253806] pci 0000:=
00:1e.0: bridge window [io  0x1000-0x0fff] to [bus 03-04] add_size 1000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253809] pci 0000:=
03:01.0: res[9]=3D[mem 0x04000000-0x03ffffff pref] get_res_add_size add=
_size 4000000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253813] pci 0000:=
00:1e.0: bridge window [mem 0x04000000-0x03ffffff pref] to [bus 03-04] =
add_size 4000000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253821] pci 0000:=
00:1e.0: res[9]=3D[mem 0x04000000-0x03ffffff pref] get_res_add_size add=
_size 4000000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253824] pci 0000:=
00:1c.0: res[8]=3D[mem 0x00100000-0x000fffff] get_res_add_size add_size=
 200000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253826] pci 0000:=
00:1c.0: res[9]=3D[mem 0x00100000-0x000fffff 64bit pref] get_res_add_si=
ze add_size 200000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253829] pci 0000:=
00:1c.1: res[9]=3D[mem 0x00100000-0x000fffff 64bit pref] get_res_add_si=
ze add_size 200000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253832] pci 0000:=
00:1c.5: res[9]=3D[mem 0x00100000-0x000fffff 64bit pref] get_res_add_si=
ze add_size 200000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253835] pci 0000:=
00:1c.0: res[7]=3D[io  0x1000-0x0fff] get_res_add_size add_size 1000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253837] pci 0000:=
00:1c.1: res[7]=3D[io  0x1000-0x0fff] get_res_add_size add_size 1000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253840] pci 0000:=
00:1c.5: res[7]=3D[io  0x1000-0x0fff] get_res_add_size add_size 1000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253843] pci 0000:=
00:1e.0: res[7]=3D[io  0x1000-0x0fff] get_res_add_size add_size 1000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253850] pci 0000:=
00:1e.0: BAR 9: can't assign mem pref (size 0x4000000)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253853] pci 0000:=
00:1c.0: BAR 8: assigned [mem 0xf0000000-0xf01fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253857] pci 0000:=
00:1c.0: BAR 9: assigned [mem 0xf0200000-0xf03fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253860] pci 0000:=
00:1c.1: BAR 9: assigned [mem 0xf0400000-0xf05fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253864] pci 0000:=
00:1c.5: BAR 9: assigned [mem 0xf0600000-0xf07fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253868] pci 0000:=
00:1c.0: BAR 7: assigned [io  0x2000-0x2fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253871] pci 0000:=
00:1c.1: BAR 7: assigned [io  0x3000-0x3fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253874] pci 0000:=
00:1c.5: BAR 7: assigned [io  0x4000-0x4fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253877] pci 0000:=
00:1e.0: BAR 7: assigned [io  0x5000-0x5fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253881] pci 0000:=
01:00.0: BAR 6: assigned [mem 0xf4000000-0xf401ffff pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253885] pci 0000:=
00:01.0: PCI bridge to [bus 01-01]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253887] pci 0000:=
00:01.0:   bridge window [io  0xd000-0xdfff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253891] pci 0000:=
00:01.0:   bridge window [mem 0xf2000000-0xf6efffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253895] pci 0000:=
00:01.0:   bridge window [mem 0xe0000000-0xefffffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253899] pci 0000:=
00:1c.0: PCI bridge to [bus 0b-0b]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253903] pci 0000:=
00:1c.0:   bridge window [io  0x2000-0x2fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253910] pci 0000:=
00:1c.0:   bridge window [mem 0xf0000000-0xf01fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253915] pci 0000:=
00:1c.0:   bridge window [mem 0xf0200000-0xf03fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253923] pci 0000:=
00:1c.1: PCI bridge to [bus 0c-0c]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253926] pci 0000:=
00:1c.1:   bridge window [io  0x3000-0x3fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253933] pci 0000:=
00:1c.1:   bridge window [mem 0xf1f00000-0xf1ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253938] pci 0000:=
00:1c.1:   bridge window [mem 0xf0400000-0xf05fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253946] pci 0000:=
00:1c.5: PCI bridge to [bus 09-09]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253950] pci 0000:=
00:1c.5:   bridge window [io  0x4000-0x4fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253956] pci 0000:=
00:1c.5:   bridge window [mem 0xf1e00000-0xf1efffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253961] pci 0000:=
00:1c.5:   bridge window [mem 0xf0600000-0xf07fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253971] pci 0000:=
03:01.0: res[9]=3D[mem 0x04000000-0x03ffffff pref] get_res_add_size add=
_size 4000000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253974] pci 0000:=
03:01.0: res[10]=3D[mem 0x04000000-0x03ffffff] get_res_add_size add_siz=
e 4000000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253977] pci 0000:=
03:01.0: res[7]=3D[io  0x0100-0x00ff] get_res_add_size add_size 100
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253979] pci 0000:=
03:01.0: res[8]=3D[io  0x0100-0x00ff] get_res_add_size add_size 100
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253983] pci 0000:=
03:01.0: BAR 0: assigned [mem 0xfc000000-0xfc000fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.253995] pci 0000:=
03:01.0: BAR 9: can't assign mem pref (size 0x4000000)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254043] pci 0000:=
03:01.0: BAR 10: can't assign mem (size 0x4000000)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254175] pci 0000:=
03:01.0: BAR 7: assigned [io  0x5000-0x50ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254178] pci 0000:=
03:01.0: BAR 8: assigned [io  0x5400-0x54ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254182] pci 0000:=
03:01.0: BAR 0: assigned [mem 0xfc000000-0xfc000fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254193] pci 0000:=
03:01.0: BAR 10: can't assign mem (size 0x4000000)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254201] pci 0000:=
03:01.0: BAR 9: can't assign mem pref (size 0x4000000)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254204] pci 0000:=
03:01.0: BAR 8: assigned [io  0x5000-0x50ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254207] pci 0000:=
03:01.0: BAR 7: assigned [io  0x5400-0x54ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254209] pci 0000:=
03:01.0: CardBus bridge to [bus 04-07]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254211] pci 0000:=
03:01.0:   bridge window [io  0x5400-0x54ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254217] pci 0000:=
03:01.0:   bridge window [io  0x5000-0x50ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254222] pci 0000:=
00:1e.0: PCI bridge to [bus 03-04]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254226] pci 0000:=
00:1e.0:   bridge window [io  0x5000-0x5fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254232] pci 0000:=
00:1e.0:   bridge window [mem 0xf1d00000-0xf1dfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254279] pci 0000:=
00:1e.0: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254287] pci 0000:=
03:01.0: enabling device (0000 -> 0003)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254300] pci_bus 0=
000:00: resource 4 [io  0x0000-0x0cf7]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254303] pci_bus 0=
000:00: resource 5 [io  0x0d00-0xffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254305] pci_bus 0=
000:00: resource 6 [mem 0x000a0000-0x000bffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254307] pci_bus 0=
000:00: resource 7 [mem 0x000d0000-0x000dffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254309] pci_bus 0=
000:00: resource 8 [mem 0xe0000000-0xf7ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254311] pci_bus 0=
000:00: resource 9 [mem 0xfc000000-0xfebfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254314] pci_bus 0=
000:00: resource 10 [mem 0xfec10000-0xfecfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254316] pci_bus 0=
000:00: resource 11 [mem 0xfed1c000-0xfed1ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254318] pci_bus 0=
000:00: resource 12 [mem 0xfed90000-0xfed9ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254320] pci_bus 0=
000:00: resource 13 [mem 0xfed40000-0xfed44fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254322] pci_bus 0=
000:00: resource 14 [mem 0xfeda7000-0xfedfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254324] pci_bus 0=
000:00: resource 15 [mem 0xfee10000-0xff9fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254327] pci_bus 0=
000:00: resource 16 [mem 0xffc00000-0xffdfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254329] pci_bus 0=
000:01: resource 0 [io  0xd000-0xdfff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254331] pci_bus 0=
000:01: resource 1 [mem 0xf2000000-0xf6efffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254333] pci_bus 0=
000:01: resource 2 [mem 0xe0000000-0xefffffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254336] pci_bus 0=
000:0b: resource 0 [io  0x2000-0x2fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254338] pci_bus 0=
000:0b: resource 1 [mem 0xf0000000-0xf01fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254340] pci_bus 0=
000:0b: resource 2 [mem 0xf0200000-0xf03fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254342] pci_bus 0=
000:0c: resource 0 [io  0x3000-0x3fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254345] pci_bus 0=
000:0c: resource 1 [mem 0xf1f00000-0xf1ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254347] pci_bus 0=
000:0c: resource 2 [mem 0xf0400000-0xf05fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254349] pci_bus 0=
000:09: resource 0 [io  0x4000-0x4fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254351] pci_bus 0=
000:09: resource 1 [mem 0xf1e00000-0xf1efffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254353] pci_bus 0=
000:09: resource 2 [mem 0xf0600000-0xf07fffff 64bit pref]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254356] pci_bus 0=
000:03: resource 0 [io  0x5000-0x5fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254358] pci_bus 0=
000:03: resource 1 [mem 0xf1d00000-0xf1dfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254360] pci_bus 0=
000:03: resource 4 [io  0x0000-0x0cf7]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254362] pci_bus 0=
000:03: resource 5 [io  0x0d00-0xffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254364] pci_bus 0=
000:03: resource 6 [mem 0x000a0000-0x000bffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254366] pci_bus 0=
000:03: resource 7 [mem 0x000d0000-0x000dffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254369] pci_bus 0=
000:03: resource 8 [mem 0xe0000000-0xf7ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254371] pci_bus 0=
000:03: resource 9 [mem 0xfc000000-0xfebfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254373] pci_bus 0=
000:03: resource 10 [mem 0xfec10000-0xfecfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254375] pci_bus 0=
000:03: resource 11 [mem 0xfed1c000-0xfed1ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254377] pci_bus 0=
000:03: resource 12 [mem 0xfed90000-0xfed9ffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254379] pci_bus 0=
000:03: resource 13 [mem 0xfed40000-0xfed44fff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254382] pci_bus 0=
000:03: resource 14 [mem 0xfeda7000-0xfedfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254384] pci_bus 0=
000:03: resource 15 [mem 0xfee10000-0xff9fffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254386] pci_bus 0=
000:03: resource 16 [mem 0xffc00000-0xffdfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254388] pci_bus 0=
000:04: resource 0 [io  0x5400-0x54ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254391] pci_bus 0=
000:04: resource 1 [io  0x5000-0x50ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254432] NET: Regi=
stered protocol family 2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254485] IP route =
cache hash table entries: 32768 (order: 5, 131072 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.254649] TCP estab=
lished hash table entries: 131072 (order: 8, 1048576 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255102] TCP bind =
hash table entries: 65536 (order: 7, 524288 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255315] TCP: Hash=
 tables configured (established 131072 bind 65536)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255329] TCP: reno=
 registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255332] UDP hash =
table entries: 512 (order: 2, 16384 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255337] UDP-Lite =
hash table entries: 512 (order: 2, 16384 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255402] NET: Regi=
stered protocol family 1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255492] RPC: Regi=
stered named UNIX socket transport module.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255494] RPC: Regi=
stered udp transport module.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255495] RPC: Regi=
stered tcp transport module.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255497] RPC: Regi=
stered tcp NFSv4.1 backchannel transport module.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255525] pci 0000:=
00:1a.0: uhci_check_and_reset_hc: cmd =3D 0x0080
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255527] pci 0000:=
00:1a.0: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255557] pci 0000:=
00:1a.1: uhci_check_and_reset_hc: cmd =3D 0x0080
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255559] pci 0000:=
00:1a.1: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255634] pci 0000:=
00:1d.0: uhci_check_and_reset_hc: cmd =3D 0x0080
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255636] pci 0000:=
00:1d.0: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255662] pci 0000:=
00:1d.1: uhci_check_and_reset_hc: cmd =3D 0x0080
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255664] pci 0000:=
00:1d.1: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255690] pci 0000:=
00:1d.2: uhci_check_and_reset_hc: cmd =3D 0x0080
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255692] pci 0000:=
00:1d.2: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255764] pci 0000:=
01:00.0: Boot video device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255783] PCI: CLS =
64 bytes, default 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.255837] Trying to=
 unpack rootfs image as initramfs...
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.309303] Freeing i=
nitrd memory: 2180k freed
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.311063] microcode=
: CPU0 sig=3D0x10676, pf=3D0x80, revision=3D0x60c
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.311068] microcode=
: CPU1 sig=3D0x10676, pf=3D0x80, revision=3D0x60c
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.311117] microcode=
: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter O=
ruba
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.311326] kworker/u=
:0 (615) used greatest stack depth: 7000 bytes left
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.311417] audit: in=
itializing netlink socket (disabled)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.311433] type=3D20=
00 audit(1342502121.310:1): initialized
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.359376] highmem b=
ounce pool size: 64 pages
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.359380] HugeTLB r=
egistered 4 MB page size, pre-allocated 0 pages
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.365637] VFS: Disk=
 quotas dquot_6.5.2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.365717] Dquot-cac=
he hash table entries: 1024 (order 0, 4096 bytes)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.367186] NFS: Regi=
stering the id_resolver key type
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.367199] Key type =
id_resolver registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.367631] msgmni ha=
s been set to 1700
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.367724] SELinux: =
 Registering netfilter hooks
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.368143] Block lay=
er SCSI generic (bsg) driver version 0.4 loaded (major 253)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.368146] io schedu=
ler noop registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.368147] io schedu=
ler deadline registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.368261] io schedu=
ler cfq registered (default)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.368392] pcieport =
0000:00:01.0: irq 40 for MSI/MSI-X
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.368519] pcieport =
0000:00:1c.0: irq 41 for MSI/MSI-X
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.368674] pcieport =
0000:00:1c.1: irq 42 for MSI/MSI-X
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.368829] pcieport =
0000:00:1c.5: irq 43 for MSI/MSI-X
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369010] pci_hotpl=
ug: PCI Hot Plug PCI Core version: 0.5
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369189] ACPI: Dep=
recated procfs I/F for AC is loaded, please retry with CONFIG_ACPI_PROC=
=46S_POWER cleared
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369256] ACPI: AC =
Adapter [AC] (on-line)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369384] input: Li=
d Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369788] ACPI: Lid=
 Switch [LID]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369857] input: Po=
wer Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369860] ACPI: Pow=
er Button [PBTN]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369925] input: Sl=
eep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.369927] ACPI: Sle=
ep Button [SBTN]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.371269] ACPI: Vid=
eo Device [VID] (multi-head: yes  rom: no  post: no)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.371337] input: Vi=
deo Bus as /devices/LNXSYSTM:00/device:00/PNP0A03:00/device:2f/LNXVIDEO=
:00/input/input3
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.371366] [Firmware=
 Bug]: Duplicate ACPI video bus devices for the same VGA controller, pl=
ease try module parameter "video.allow_duplicates=3D1"if the current dr=
iver doesn't work.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.371445] ACPI: Req=
uesting acpi_cpufreq
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.371613] Monitor-M=
wait will be used to enter C-1 state
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.372465] Monitor-M=
wait will be used to enter C-2 state
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.372493] Monitor-M=
wait will be used to enter C-3 state
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.372500] Marking T=
SC unstable due to TSC halts in idle
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.372515] ACPI: acp=
i_idle registered with cpuidle
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.420118] thermal L=
NXTHERM:00: registered as thermal_zone0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.420120] ACPI: The=
rmal Zone [THM] (28 C)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.431107] Serial: 8=
250/16550 driver, 4 ports, IRQ sharing enabled
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.441528] ACPI: Dep=
recated procfs I/F for battery is loaded, please retry with CONFIG_ACPI=
_PROCFS_POWER cleared
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.441533] ACPI: Bat=
tery Slot [BAT0] (battery present)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.441554] ACPI: Dep=
recated procfs I/F for battery is loaded, please retry with CONFIG_ACPI=
_PROCFS_POWER cleared
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.441558] ACPI: Bat=
tery Slot [BAT1] (battery absent)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.698165] serial825=
0: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.719328] 00:09: tt=
yS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.719713] Non-volat=
ile memory driver v1.3
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.719727] Linux agp=
gart interface v0.103
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.720038] [drm] Ini=
tialized drm 1.1.0 20060810
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.720041] [drm:i915=
_init] *ERROR* drm/i915 can't work without intel_agp module!
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.722155] brd: modu=
le loaded
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.723317] loop: mod=
ule loaded
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.723704] ata_piix =
0000:00:1f.1: version 2.13
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.723747] ata_piix =
0000:00:1f.1: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.724240] scsi0 : a=
ta_piix
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.724481] scsi1 : a=
ta_piix
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.726274] ata1: PAT=
A max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x6fa0 irq 14
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.726276] ata2: PAT=
A max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x6fa8 irq 15
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.726306] ata_piix =
0000:00:1f.2: MAP [
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.726307]  P0 P2 P1=
 P3 ]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.726317] ata2: por=
t disabled--ignoring
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.877077] ata_piix =
0000:00:1f.2: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.877546] scsi2 : a=
ta_piix
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.877665] scsi3 : a=
ta_piix
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.879490] ata3: SAT=
A max UDMA/133 cmd 0x6eb0 ctl 0x6eb8 bmdma 0x6ee0 irq 18
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.879497] ata4: SAT=
A max UDMA/133 cmd 0x6ec0 ctl 0x6ec8 bmdma 0x6ee8 irq 18
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.879722] e100: Int=
el(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.879724] e100: Cop=
yright(c) 1999-2006 Intel Corporation
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.879772] e1000: In=
tel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.879774] e1000: Co=
pyright (c) 1999-2006 Intel Corporation.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.879822] sky2: dri=
ver version 1.30
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.879983] yenta_car=
dbus 0000:03:01.0: CardBus bridge found [1028:01f9]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.880029] yenta_car=
dbus 0000:03:01.0: CardBus bridge to [bus 04-07]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.880032] yenta_car=
dbus 0000:03:01.0:   bridge window [io  0x5400-0x54ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.880051] yenta_car=
dbus 0000:03:01.0:   bridge window [io  0x5000-0x50ff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.880068] yenta_car=
dbus 0000:03:01.0:   bridge window [mem 0xf0800000-0xf0bfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.880083] yenta_car=
dbus 0000:03:01.0:   bridge window [mem 0xf0c00000-0xf0ffffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.880113] yenta_car=
dbus 0000:03:01.0: O2: enabling read prefetch/write burst. If you exper=
ience problems or performance issues, use the yenta_socket parameter 'o=
2_speedup=3Doff'
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.880424] ata1.00: =
ATAPI: HL-DT-STCD-RW/DVD-ROM GCC-T10N, A104, max UDMA/33
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.886267] ata1.00: =
configured for UDMA/33
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.891776] scsi 0:0:=
0:0: CD-ROM            HL-DT-ST CDRW/DVD GCCT10N A104 PQ: 0 ANSI: 5
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.897084] sr0: scsi=
3-mmc drive: 24x/24x writer cd/rw xa/form2 cdda tray
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.897087] cdrom: Un=
iform CD-ROM driver Revision: 3.20
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.897224] sr 0:0:0:=
0: Attached scsi CD-ROM sr0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    0.897358] sr 0:0:0:=
0: Attached scsi generic sg0 type 5
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.640114] ata3.00: =
SATA link up 3.0 Gbps (SStatus 123 SControl 300)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.640132] ata3.01: =
SATA link down (SStatus 0 SControl 300)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.643407] ata3.00: =
ATA-8: Hitachi HTS722080K9A300, DCBOCA1H, max UDMA/133
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.643410] ata3.00: =
156301488 sectors, multi 8: LBA48 NCQ (depth 0/32)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.649407] ata3.00: =
configured for UDMA/133
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.649501] scsi 2:0:=
0:0: Direct-Access     ATA      Hitachi HTS72208 DCBO PQ: 0 ANSI: 5
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.649688] sd 2:0:0:=
0: [sda] 156301488 512-byte logical blocks: (80.0 GB/74.5 GiB)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.649733] sd 2:0:0:=
0: [sda] Write Protect is off
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.649736] sd 2:0:0:=
0: [sda] Mode Sense: 00 3a 00 00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.649741] sd 2:0:0:=
0: Attached scsi generic sg1 type 0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.649756] sd 2:0:0:=
0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO=
 or FUA
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.697456]  sda: sda=
1 sda2 < sda5 sda6 >
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    1.697883] sd 2:0:0:=
0: [sda] Attached SCSI disk
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.191050] ata4.01: =
failed to resume link (SControl 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.191098] ata4.00: =
SATA link down (SStatus 0 SControl 300)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.191120] ata4.01: =
SATA link down (SStatus 0 SControl 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.313964] yenta_car=
dbus 0000:03:01.0: ISA IRQ mask 0x0cb8, PCI irq 19
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.313968] yenta_car=
dbus 0000:03:01.0: Socket status: 30000006
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.313971] pci_bus 0=
000:03: Raising subordinate bus# of parent bus (#03) from #04 to #07
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.313977] yenta_car=
dbus 0000:03:01.0: pcmcia: parent PCI bridge window: [io  0x5000-0x5fff=
]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.313980] yenta_car=
dbus 0000:03:01.0: pcmcia: parent PCI bridge window: [mem 0xf1d00000-0x=
f1dfffff]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.313983] pcmcia_so=
cket pcmcia_socket0: cs: memory probe 0xf1d00000-0xf1dfffff:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.313993]  excludin=
g 0xf1df0000-0xf1dfffff
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314690] ehci_hcd:=
 USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314692] ehci_hcd:=
 block sizes: qh 64 qtd 96 itd 160 sitd 96
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314724] ehci_hcd =
0000:00:1a.7: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314728] ehci_hcd =
0000:00:1a.7: EHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314778] ehci_hcd =
0000:00:1a.7: new USB bus registered, assigned bus number 1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314786] ehci_hcd =
0000:00:1a.7: reset hcs_params 0x102204 dbg=3D1 cc=3D2 pcc=3D2 ordered =
!ppc ports=3D4
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314791] ehci_hcd =
0000:00:1a.7: reset hcc_params 6871 thresh 7 uframes 1024 64 bit addr
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314816] ehci_hcd =
0000:00:1a.7: debug port 1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.314822] ehci_hcd =
0000:00:1a.7: reset command 0000002 (park)=3D0 ithresh=3D0 period=3D102=
4 Reset HALT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.318710] ehci_hcd =
0000:00:1a.7: cache line size of 64 is not supported
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.318712] ehci_hcd =
0000:00:1a.7: supports USB remote wakeup
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.318728] ehci_hcd =
0000:00:1a.7: irq 22, io mem 0xfed1c400
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.318733] ehci_hcd =
0000:00:1a.7: init command 0010001 (park)=3D0 ithresh=3D1 period=3D1024=
 RUN
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324024] ehci_hcd =
0000:00:1a.7: USB 2.0 started, EHCI 1.00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324062] usb usb1:=
 default language 0x0409
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324068] usb usb1:=
 udev 1, busnum 1, minor =3D 0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324070] usb usb1:=
 New USB device found, idVendor=3D1d6b, idProduct=3D0002
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324073] usb usb1:=
 New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324075] usb usb1:=
 Product: EHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324077] usb usb1:=
 Manufacturer: Linux 3.5.0-rc5+ ehci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324079] usb usb1:=
 SerialNumber: 0000:00:1a.7
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324171] usb usb1:=
 usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324174] usb usb1:=
 configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324180] usb usb1:=
 adding 1-0:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324231] hub 1-0:1=
=2E0: usb_probe_interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324234] hub 1-0:1=
=2E0: usb_probe_interface - got id
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324236] hub 1-0:1=
=2E0: USB hub found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324240] hub 1-0:1=
=2E0: 4 ports detected
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324242] hub 1-0:1=
=2E0: standalone hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324244] hub 1-0:1=
=2E0: no power switching (usb 1.0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324246] hub 1-0:1=
=2E0: individual port over-current protection
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324248] hub 1-0:1=
=2E0: power on to power good time: 20ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324251] hub 1-0:1=
=2E0: local power source is good
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324253] hub 1-0:1=
=2E0: trying to enable port power on non-switchable hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324320] ehci_hcd =
0000:00:1d.7: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324324] ehci_hcd =
0000:00:1d.7: EHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324376] ehci_hcd =
0000:00:1d.7: new USB bus registered, assigned bus number 2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324383] ehci_hcd =
0000:00:1d.7: reset hcs_params 0x103206 dbg=3D1 cc=3D3 pcc=3D2 ordered =
!ppc ports=3D6
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324388] ehci_hcd =
0000:00:1d.7: reset hcc_params 6871 thresh 7 uframes 1024 64 bit addr
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324410] ehci_hcd =
0000:00:1d.7: debug port 1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.324415] ehci_hcd =
0000:00:1d.7: reset command 0000002 (park)=3D0 ithresh=3D0 period=3D102=
4 Reset HALT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.328294] ehci_hcd =
0000:00:1d.7: cache line size of 64 is not supported
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.328296] ehci_hcd =
0000:00:1d.7: supports USB remote wakeup
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.328309] ehci_hcd =
0000:00:1d.7: irq 20, io mem 0xfed1c000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.328315] ehci_hcd =
0000:00:1d.7: init command 0010001 (park)=3D0 ithresh=3D1 period=3D1024=
 RUN
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334020] ehci_hcd =
0000:00:1d.7: USB 2.0 started, EHCI 1.00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334038] usb usb2:=
 default language 0x0409
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334043] usb usb2:=
 udev 1, busnum 2, minor =3D 128
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334046] usb usb2:=
 New USB device found, idVendor=3D1d6b, idProduct=3D0002
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334048] usb usb2:=
 New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334050] usb usb2:=
 Product: EHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334053] usb usb2:=
 Manufacturer: Linux 3.5.0-rc5+ ehci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334055] usb usb2:=
 SerialNumber: 0000:00:1d.7
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334137] usb usb2:=
 usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334140] usb usb2:=
 configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334145] usb usb2:=
 adding 2-0:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334193] hub 2-0:1=
=2E0: usb_probe_interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334195] hub 2-0:1=
=2E0: usb_probe_interface - got id
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334197] hub 2-0:1=
=2E0: USB hub found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334201] hub 2-0:1=
=2E0: 6 ports detected
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334203] hub 2-0:1=
=2E0: standalone hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334205] hub 2-0:1=
=2E0: no power switching (usb 1.0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334207] hub 2-0:1=
=2E0: individual port over-current protection
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334209] hub 2-0:1=
=2E0: power on to power good time: 20ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334212] hub 2-0:1=
=2E0: local power source is good
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334214] hub 2-0:1=
=2E0: trying to enable port power on non-switchable hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334306] ohci_hcd:=
 USB 1.1 'Open' Host Controller (OHCI) Driver
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334308] ohci_hcd:=
 block sizes: ed 64 td 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334353] uhci_hcd:=
 USB Universal Host Controller Interface driver
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334428] uhci_hcd =
0000:00:1a.0: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334432] uhci_hcd =
0000:00:1a.0: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334485] uhci_hcd =
0000:00:1a.0: new USB bus registered, assigned bus number 3
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334492] uhci_hcd =
0000:00:1a.0: detected 2 ports
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334497] uhci_hcd =
0000:00:1a.0: uhci_check_and_reset_hc: cmd =3D 0x0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334499] uhci_hcd =
0000:00:1a.0: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334515] uhci_hcd =
0000:00:1a.0: supports USB remote wakeup
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334520] uhci_hcd =
0000:00:1a.0: irq 20, io base 0x00006f20
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334547] usb usb3:=
 default language 0x0409
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334552] usb usb3:=
 udev 1, busnum 3, minor =3D 256
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334555] usb usb3:=
 New USB device found, idVendor=3D1d6b, idProduct=3D0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334557] usb usb3:=
 New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334559] usb usb3:=
 Product: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334561] usb usb3:=
 Manufacturer: Linux 3.5.0-rc5+ uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334564] usb usb3:=
 SerialNumber: 0000:00:1a.0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334643] usb usb3:=
 usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334646] usb usb3:=
 configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334651] usb usb3:=
 adding 3-0:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334703] hub 3-0:1=
=2E0: usb_probe_interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334705] hub 3-0:1=
=2E0: usb_probe_interface - got id
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334707] hub 3-0:1=
=2E0: USB hub found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334712] hub 3-0:1=
=2E0: 2 ports detected
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334714] hub 3-0:1=
=2E0: standalone hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334715] hub 3-0:1=
=2E0: no power switching (usb 1.0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334717] hub 3-0:1=
=2E0: individual port over-current protection
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334719] hub 3-0:1=
=2E0: power on to power good time: 2ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334723] hub 3-0:1=
=2E0: local power source is good
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334725] hub 3-0:1=
=2E0: trying to enable port power on non-switchable hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334765] ehci_hcd =
0000:00:1a.7: HS companion for 0000:00:1a.0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334788] uhci_hcd =
0000:00:1a.1: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334791] uhci_hcd =
0000:00:1a.1: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334847] uhci_hcd =
0000:00:1a.1: new USB bus registered, assigned bus number 4
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334855] uhci_hcd =
0000:00:1a.1: detected 2 ports
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334860] uhci_hcd =
0000:00:1a.1: uhci_check_and_reset_hc: cmd =3D 0x0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334862] uhci_hcd =
0000:00:1a.1: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334877] uhci_hcd =
0000:00:1a.1: supports USB remote wakeup
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334891] uhci_hcd =
0000:00:1a.1: irq 21, io base 0x00006f00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334920] usb usb4:=
 default language 0x0409
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334925] usb usb4:=
 udev 1, busnum 4, minor =3D 384
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334928] usb usb4:=
 New USB device found, idVendor=3D1d6b, idProduct=3D0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334930] usb usb4:=
 New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334932] usb usb4:=
 Product: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334934] usb usb4:=
 Manufacturer: Linux 3.5.0-rc5+ uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.334936] usb usb4:=
 SerialNumber: 0000:00:1a.1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335032] usb usb4:=
 usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335034] usb usb4:=
 configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335040] usb usb4:=
 adding 4-0:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335092] hub 4-0:1=
=2E0: usb_probe_interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335094] hub 4-0:1=
=2E0: usb_probe_interface - got id
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335096] hub 4-0:1=
=2E0: USB hub found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335100] hub 4-0:1=
=2E0: 2 ports detected
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335102] hub 4-0:1=
=2E0: standalone hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335104] hub 4-0:1=
=2E0: no power switching (usb 1.0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335106] hub 4-0:1=
=2E0: individual port over-current protection
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335108] hub 4-0:1=
=2E0: power on to power good time: 2ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335111] hub 4-0:1=
=2E0: local power source is good
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335113] hub 4-0:1=
=2E0: trying to enable port power on non-switchable hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335148] ehci_hcd =
0000:00:1a.7: HS companion for 0000:00:1a.1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335172] uhci_hcd =
0000:00:1d.0: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335175] uhci_hcd =
0000:00:1d.0: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335236] uhci_hcd =
0000:00:1d.0: new USB bus registered, assigned bus number 5
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335244] uhci_hcd =
0000:00:1d.0: detected 2 ports
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335248] uhci_hcd =
0000:00:1d.0: uhci_check_and_reset_hc: cmd =3D 0x0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335250] uhci_hcd =
0000:00:1d.0: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335266] uhci_hcd =
0000:00:1d.0: supports USB remote wakeup
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335270] uhci_hcd =
0000:00:1d.0: irq 20, io base 0x00006f80
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335297] usb usb5:=
 default language 0x0409
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335303] usb usb5:=
 udev 1, busnum 5, minor =3D 512
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335305] usb usb5:=
 New USB device found, idVendor=3D1d6b, idProduct=3D0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335308] usb usb5:=
 New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335310] usb usb5:=
 Product: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335312] usb usb5:=
 Manufacturer: Linux 3.5.0-rc5+ uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335314] usb usb5:=
 SerialNumber: 0000:00:1d.0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335397] usb usb5:=
 usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335399] usb usb5:=
 configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335405] usb usb5:=
 adding 5-0:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335459] hub 5-0:1=
=2E0: usb_probe_interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335461] hub 5-0:1=
=2E0: usb_probe_interface - got id
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335463] hub 5-0:1=
=2E0: USB hub found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335467] hub 5-0:1=
=2E0: 2 ports detected
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335469] hub 5-0:1=
=2E0: standalone hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335471] hub 5-0:1=
=2E0: no power switching (usb 1.0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335472] hub 5-0:1=
=2E0: individual port over-current protection
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335474] hub 5-0:1=
=2E0: power on to power good time: 2ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335478] hub 5-0:1=
=2E0: local power source is good
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335480] hub 5-0:1=
=2E0: trying to enable port power on non-switchable hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335518] ehci_hcd =
0000:00:1d.7: HS companion for 0000:00:1d.0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335536] uhci_hcd =
0000:00:1d.1: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335540] uhci_hcd =
0000:00:1d.1: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335595] uhci_hcd =
0000:00:1d.1: new USB bus registered, assigned bus number 6
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335603] uhci_hcd =
0000:00:1d.1: detected 2 ports
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335609] uhci_hcd =
0000:00:1d.1: uhci_check_and_reset_hc: cmd =3D 0x0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335611] uhci_hcd =
0000:00:1d.1: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335627] uhci_hcd =
0000:00:1d.1: supports USB remote wakeup
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335632] uhci_hcd =
0000:00:1d.1: irq 21, io base 0x00006f60
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335659] usb usb6:=
 default language 0x0409
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335665] usb usb6:=
 udev 1, busnum 6, minor =3D 640
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335667] usb usb6:=
 New USB device found, idVendor=3D1d6b, idProduct=3D0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335670] usb usb6:=
 New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335672] usb usb6:=
 Product: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335674] usb usb6:=
 Manufacturer: Linux 3.5.0-rc5+ uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335676] usb usb6:=
 SerialNumber: 0000:00:1d.1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335760] usb usb6:=
 usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335763] usb usb6:=
 configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335768] usb usb6:=
 adding 6-0:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335821] hub 6-0:1=
=2E0: usb_probe_interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335823] hub 6-0:1=
=2E0: usb_probe_interface - got id
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335825] hub 6-0:1=
=2E0: USB hub found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335828] hub 6-0:1=
=2E0: 2 ports detected
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335830] hub 6-0:1=
=2E0: standalone hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335832] hub 6-0:1=
=2E0: no power switching (usb 1.0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335834] hub 6-0:1=
=2E0: individual port over-current protection
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335836] hub 6-0:1=
=2E0: power on to power good time: 2ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335840] hub 6-0:1=
=2E0: local power source is good
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335842] hub 6-0:1=
=2E0: trying to enable port power on non-switchable hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335882] ehci_hcd =
0000:00:1d.7: HS companion for 0000:00:1d.1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335901] uhci_hcd =
0000:00:1d.2: setting latency timer to 64
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335904] uhci_hcd =
0000:00:1d.2: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335963] uhci_hcd =
0000:00:1d.2: new USB bus registered, assigned bus number 7
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335971] uhci_hcd =
0000:00:1d.2: detected 2 ports
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335976] uhci_hcd =
0000:00:1d.2: uhci_check_and_reset_hc: cmd =3D 0x0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335978] uhci_hcd =
0000:00:1d.2: Performing full reset
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335994] uhci_hcd =
0000:00:1d.2: supports USB remote wakeup
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.335998] uhci_hcd =
0000:00:1d.2: irq 22, io base 0x00006f40
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336037] usb usb7:=
 default language 0x0409
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336043] usb usb7:=
 udev 1, busnum 7, minor =3D 768
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336045] usb usb7:=
 New USB device found, idVendor=3D1d6b, idProduct=3D0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336048] usb usb7:=
 New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336050] usb usb7:=
 Product: UHCI Host Controller
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336052] usb usb7:=
 Manufacturer: Linux 3.5.0-rc5+ uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336054] usb usb7:=
 SerialNumber: 0000:00:1d.2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336140] usb usb7:=
 usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336143] usb usb7:=
 configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336148] usb usb7:=
 adding 7-0:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336201] hub 7-0:1=
=2E0: usb_probe_interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336203] hub 7-0:1=
=2E0: usb_probe_interface - got id
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336205] hub 7-0:1=
=2E0: USB hub found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336209] hub 7-0:1=
=2E0: 2 ports detected
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336211] hub 7-0:1=
=2E0: standalone hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336212] hub 7-0:1=
=2E0: no power switching (usb 1.0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336214] hub 7-0:1=
=2E0: individual port over-current protection
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336216] hub 7-0:1=
=2E0: power on to power good time: 2ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336220] hub 7-0:1=
=2E0: local power source is good
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336222] hub 7-0:1=
=2E0: trying to enable port power on non-switchable hub
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336260] ehci_hcd =
0000:00:1d.7: HS companion for 0000:00:1d.2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336360] usbcore: =
registered new interface driver usblp
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336361] Initializ=
ing USB Mass Storage driver...
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336431] usbcore: =
registered new interface driver usb-storage
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336433] USB Mass =
Storage support registered.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336501] usbcore: =
registered new interface driver libusual
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.336622] i8042: PN=
P: PS/2 Controller [PNP0303:KBC,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.340180] serio: i8=
042 KBD port at 0x60,0x64 irq 1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.340185] serio: i8=
042 AUX port at 0x60,0x64 irq 12
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.340310] mousedev:=
 PS/2 mouse device common for all mice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.340639] rtc_cmos =
00:03: RTC can wake from S4
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.340809] rtc_cmos =
00:03: rtc core: registered rtc_cmos as rtc0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.340842] rtc0: ala=
rms up to one month, y3k, 114 bytes nvram, hpet irqs
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.341412] device-ma=
pper: ioctl: 4.22.0-ioctl (2011-10-19) initialised: dm-devel@redhat.com
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.341516] cpuidle: =
using governor ladder
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.341570] cpuidle: =
using governor menu
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.341572] EFI Varia=
bles Facility v0.08 2004-May-17
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.343050] usbcore: =
registered new interface driver usbhid
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.343052] usbhid: U=
SB HID core driver
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.343314] input: AT=
 Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/inpu=
t4
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.344748] snd_hda_i=
ntel 0000:00:1b.0: irq 44 for MSI/MSI-X
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.365507] Netfilter=
 messages via NETLINK v0.30.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.365519] nf_conntr=
ack version 0.5.0 (16384 buckets, 65536 max)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.365726] ctnetlink=
 v0.93: registering with nfnetlink.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.365886] ip_tables=
: (C) 2000-2006 Netfilter Core Team
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.365923] TCP: cubi=
c registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.365924] Initializ=
ing XFRM netlink socket
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.366411] NET: Regi=
stered protocol family 10
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.366730] ip6_table=
s: (C) 2000-2006 Netfilter Core Team
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.366760] sit: IPv6=
 over IPv4 tunneling driver
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.367042] NET: Regi=
stered protocol family 17
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.367061] Key type =
dns_resolver registered
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.367186] Using IPI=
 No-Shortcut mode
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.367364] PM: Hiber=
nation image not present or could not be loaded.
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.367375] registere=
d taskstats version 1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.367764]   Magic n=
umber: 4:530:264
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.367838] console [=
netcon0] enabled
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.367839] netconsol=
e: network logging started
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.424057] ehci_hcd =
0000:00:1a.7: GetStatus port:2 status 001803 0  ACK POWER sig=3Dj CSC C=
ONNECT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.424060] hub 1-0:1=
=2E0: port 2: status 0501 change 0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.434044] ehci_hcd =
0000:00:1d.7: GetStatus port:2 status 001803 0  ACK POWER sig=3Dj CSC C=
ONNECT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.434047] hub 2-0:1=
=2E0: port 2: status 0501 change 0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.434063] ehci_hcd =
0000:00:1d.7: GetStatus port:5 status 001803 0  ACK POWER sig=3Dj CSC C=
ONNECT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.434066] hub 2-0:1=
=2E0: port 5: status 0501 change 0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.434087] uhci_hcd =
0000:00:1a.0: port 2 portsc 008a,00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.435065] uhci_hcd =
0000:00:1d.0: port 2 portsc 0082,00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.435085] hub 4-0:1=
=2E0: state 7 ports 2 chg 0000 evt 0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.435088] hub 6-0:1=
=2E0: state 7 ports 2 chg 0000 evt 0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.436039] uhci_hcd =
0000:00:1d.2: port 1 portsc 008a,00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.459862] ALSA devi=
ce list:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.459864]   #0: HDA=
 Intel at 0xf6ffc000 irq 44
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.459939] Freeing u=
nused kernel memory: 432k freed
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.460137] Write pro=
tecting the kernel text: 4956k
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.460182] Write pro=
tecting the kernel read-only data: 2352k
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.463890] exe (1104=
) used greatest stack depth: 6920 bytes left
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.465795] modprobe =
(1108) used greatest stack depth: 6772 bytes left
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.508341] ata_id (1=
185) used greatest stack depth: 6676 bytes left
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.524318] hub 1-0:1=
=2E0: state 7 ports 4 chg 0004 evt 0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.524329] hub 1-0:1=
=2E0: port 2, status 0501, change 0000, 480 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.537225] ata_id (1=
186) used greatest stack depth: 6336 bytes left
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.545213] tg3.c:v3.=
123 (March 21, 2012)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.557325] tg3 0000:=
09:00.0: eth0: Tigon3 [partno(BCM95755m) rev a002] (PCI Express) MAC ad=
dress 00:21:70:b0:e4:89
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.557330] tg3 0000:=
09:00.0: eth0: attached PHY is 5755 (10/100/1000Base-T Ethernet) (WireS=
peed[1], EEE[0])
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.557333] tg3 0000:=
09:00.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.557336] tg3 0000:=
09:00.0: eth0: dma_rwctrl[76180000] dma_mask[64-bit]
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.575273] ehci_hcd =
0000:00:1a.7: port 2 full speed --> companion
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.575280] ehci_hcd =
0000:00:1a.7: GetStatus port:2 status 003801 0  ACK POWER OWNER sig=3Dj=
 CONNECT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.575285] hub 1-0:1=
=2E0: port 2 not reset yet, waiting 50ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.626046] ehci_hcd =
0000:00:1a.7: GetStatus port:2 status 003002 0  ACK POWER OWNER sig=3Ds=
e0 CSC
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.626081] hub 2-0:1=
=2E0: state 7 ports 6 chg 0024 evt 0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.626091] hub 2-0:1=
=2E0: port 2, status 0501, change 0000, 480 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.677230] ehci_hcd =
0000:00:1d.7: port 2 full speed --> companion
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.677235] ehci_hcd =
0000:00:1d.7: GetStatus port:2 status 003801 0  ACK POWER OWNER sig=3Dj=
 CONNECT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.677239] hub 2-0:1=
=2E0: port 2 not reset yet, waiting 50ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.728060] ehci_hcd =
0000:00:1d.7: GetStatus port:2 status 003002 0  ACK POWER OWNER sig=3Ds=
e0 CSC
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.728096] hub 2-0:1=
=2E0: port 5, status 0501, change 0000, 480 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.779233] ehci_hcd =
0000:00:1d.7: port 5 full speed --> companion
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.779237] ehci_hcd =
0000:00:1d.7: GetStatus port:5 status 003801 0  ACK POWER OWNER sig=3Dj=
 CONNECT
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.779257] hub 2-0:1=
=2E0: port 5 not reset yet, waiting 50ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.810447] EXT4-fs (=
sda5): INFO: recovery required on readonly filesystem
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.810450] EXT4-fs (=
sda5): write access will be enabled during recovery
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.830075] ehci_hcd =
0000:00:1d.7: GetStatus port:5 status 003002 0  ACK POWER OWNER sig=3Ds=
e0 CSC
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.830106] hub 3-0:1=
=2E0: state 7 ports 2 chg 0000 evt 0004
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.830118] uhci_hcd =
0000:00:1a.0: port 2 portsc 0093,00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.830129] hub 3-0:1=
=2E0: port 2, status 0101, change 0001, 12 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    2.934051] hub 3-0:1=
=2E0: debounce: port 2: total 100ms stable 100ms status 0x101
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.036051] usb 3-2: =
new full-speed USB device number 2 using uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.307632] usb 3-2: =
skipped 1 descriptor after interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.307638] usb 3-2: =
udev 2, busnum 3, minor =3D 257
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.307644] usb 3-2: =
New USB device found, idVendor=3D413c, idProduct=3D8140
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.307649] usb 3-2: =
New USB device strings: Mfr=3D0, Product=3D0, SerialNumber=3D0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.307764] usb 3-2: =
usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.307768] usb 3-2: =
configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.310637] usb 3-2: =
adding 3-2:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.310731] usb 3-2: =
adding 3-2:1.1 (config #1, interface 1)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.310776] usb 3-2: =
adding 3-2:1.2 (config #1, interface 2)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.310817] hub 5-0:1=
=2E0: state 7 ports 2 chg 0000 evt 0004
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.310826] uhci_hcd =
0000:00:1d.0: port 2 portsc 0093,00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.310833] hub 5-0:1=
=2E0: port 2, status 0101, change 0001, 12 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.359362] input: Du=
alPoint Stick as /devices/platform/i8042/serio1/input/input5
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.379610] input: Al=
psPS/2 ALPS DualPoint TouchPad as /devices/platform/i8042/serio1/input/=
input6
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.415041] hub 5-0:1=
=2E0: debounce: port 2: total 100ms stable 100ms status 0x101
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417591] EXT4-fs (=
sda5): orphan cleanup on readonly fs
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417599] EXT4-fs (=
sda5): ext4_orphan_cleanup: deleting unreferenced inode 272846
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417625] EXT4-fs (=
sda5): ext4_orphan_cleanup: deleting unreferenced inode 272844
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417633] EXT4-fs (=
sda5): ext4_orphan_cleanup: deleting unreferenced inode 272842
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417640] EXT4-fs (=
sda5): ext4_orphan_cleanup: deleting unreferenced inode 272839
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417647] EXT4-fs (=
sda5): ext4_orphan_cleanup: deleting unreferenced inode 272831
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417655] EXT4-fs (=
sda5): ext4_orphan_cleanup: deleting unreferenced inode 272830
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417664] EXT4-fs (=
sda5): ext4_orphan_cleanup: deleting unreferenced inode 3801323
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417700] EXT4-fs (=
sda5): ext4_orphan_cleanup: deleting unreferenced inode 3801338
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417730] EXT4-fs (=
sda5): 8 orphan inodes deleted
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.417732] EXT4-fs (=
sda5): recovery complete
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.454067] usb usb4:=
 suspend_rh (auto-stop)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.454099] usb usb6:=
 suspend_rh (auto-stop)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.517099] usb 5-2: =
new full-speed USB device number 2 using uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.520367] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.521349] EXT4-fs (=
sda5): mounted filesystem with ordered data mode. Opts: (null)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.521436] exe (1259=
) used greatest stack depth: 6208 bytes left
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.524342] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.529363] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.631061] usb 5-2: =
device descriptor read/64, error -71
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.735371] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.739354] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.742367] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    3.844069] usb 5-2: =
device descriptor read/64, error -71
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.047040] usb 5-2: =
new full-speed USB device number 3 using uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.050378] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.053380] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.057370] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.159055] usb 5-2: =
device descriptor read/64, error -71
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.263388] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.266390] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.270389] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.372056] usb 5-2: =
device descriptor read/64, error -71
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.491226] init: ure=
adahead main process (1281) terminated with status 5
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.575116] usb 5-2: =
new full-speed USB device number 4 using uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.578400] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.782402] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    4.983052] usb 5-2: =
device not accepting address 4, error -71
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.085057] usb 5-2: =
new full-speed USB device number 5 using uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.088417] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.292403] usb 5-2: =
uhci_result_common: failed with status 440000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.493028] usb 5-2: =
device not accepting address 5, error -71
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.493053] hub 5-0:1=
=2E0: unable to enumerate USB device on port 2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.493064] hub 7-0:1=
=2E0: state 7 ports 2 chg 0000 evt 0002
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.493073] uhci_hcd =
0000:00:1d.2: port 1 portsc 0093,00
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.493079] hub 7-0:1=
=2E0: port 1, status 0101, change 0001, 12 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.598036] hub 7-0:1=
=2E0: debounce: port 1: total 100ms stable 100ms status 0x101
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.700029] usb 7-1: =
new full-speed USB device number 2 using uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.820037] usb 7-1: =
ep0 maxpacket =3D 8
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.837176] usb 7-1: =
udev 2, busnum 7, minor =3D 769
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.837180] usb 7-1: =
New USB device found, idVendor=3D0b97, idProduct=3D7761
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.837182] usb 7-1: =
New USB device strings: Mfr=3D0, Product=3D0, SerialNumber=3D0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.837261] usb 7-1: =
usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.837264] usb 7-1: =
configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.840184] usb 7-1: =
adding 7-1:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.840207] hub 7-1:1=
=2E0: usb_probe_interface
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.840210] hub 7-1:1=
=2E0: usb_probe_interface - got id
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.840212] hub 7-1:1=
=2E0: USB hub found
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.842167] hub 7-1:1=
=2E0: 4 ports detected
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.842170] hub 7-1:1=
=2E0: compound device; port removable status: RFRR
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.842173] hub 7-1:1=
=2E0: individual port power switching
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.842174] hub 7-1:1=
=2E0: individual port over-current protection
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.842177] hub 7-1:1=
=2E0: power on to power good time: 100ms
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.844169] hub 7-1:1=
=2E0: local power source is lost (inactive)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.844172] hub 7-1:1=
=2E0: enabling power on all ports
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.848207] hub 1-0:1=
=2E0: state 7 ports 4 chg 0000 evt 0004
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.848216] ehci_hcd =
0000:00:1a.7: GetStatus port:2 status 003002 0  ACK POWER OWNER sig=3Ds=
e0 CSC
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.848224] hub 1-0:1=
=2E0: port 2, status 0100, change 0001, 12 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.950179] hub 7-1:1=
=2E0: port 2: status 0101 change 0001
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.953044] hub 1-0:1=
=2E0: debounce: port 2: total 100ms stable 100ms status 0x100
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.953049] hub 2-0:1=
=2E0: state 7 ports 6 chg 0000 evt 0024
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.953057] ehci_hcd =
0000:00:1d.7: GetStatus port:2 status 003002 0  ACK POWER OWNER sig=3Ds=
e0 CSC
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    5.953064] hub 2-0:1=
=2E0: port 2, status 0100, change 0001, 12 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.053045] uhci_hcd =
0000:00:1d.2: reserve dev 2 ep81-INT, period 128, phase 0, 12 us
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.057032] hub 2-0:1=
=2E0: debounce: port 2: total 100ms stable 100ms status 0x100
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.057040] ehci_hcd =
0000:00:1d.7: GetStatus port:5 status 003002 0  ACK POWER OWNER sig=3Ds=
e0 CSC
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.057047] hub 2-0:1=
=2E0: port 5, status 0100, change 0001, 12 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.162041] hub 2-0:1=
=2E0: debounce: port 5: total 100ms stable 100ms status 0x100
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.162046] hub 7-0:1=
=2E0: state 7 ports 2 chg 0000 evt 0002
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.162055] hub 7-1:1=
=2E0: state 7 ports 4 chg 0004 evt 0000
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.163187] hub 7-1:1=
=2E0: port 2, status 0101, change 0000, 12 Mb/s
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.228191] usb 7-1.2=
: new full-speed USB device number 3 using uhci_hcd
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.323192] usb 7-1.2=
: skipped 1 descriptor after endpoint
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.328191] usb 7-1.2=
: default language 0x0409
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.338184] usb 7-1.2=
: udev 3, busnum 7, minor =3D 770
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.338187] usb 7-1.2=
: New USB device found, idVendor=3D0b97, idProduct=3D7772
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.338190] usb 7-1.2=
: New USB device strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.338192] usb 7-1.2=
: Product: O2Micro CCID SC Reader
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.338194] usb 7-1.2=
: Manufacturer: O2
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.338245] usb 7-1.2=
: usb_probe_device
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.338249] usb 7-1.2=
: configuration #1 chosen from 1 choice
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    6.341201] usb 7-1.2=
: adding 7-1.2:1.0 (config #1, interface 0)
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    7.723487] udevd[387=
9]: starting version 175
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    8.116288] Adding 46=
73532k swap on /dev/sda6.  Priority:-1 extents:1 across:4673532k=20
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    8.895300] EXT4-fs (=
sda5): re-mounted. Opts: errors=3Dremount-ro
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    9.617379] pcmcia_so=
cket pcmcia_socket0: cs: memory probe 0x0c0000-0x0fffff:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    9.617388]  excludin=
g 0xc0000-0xcffff 0xe0000-0xfffff
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    9.617416] pcmcia_so=
cket pcmcia_socket0: cs: memory probe 0xa0000000-0xa0ffffff:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    9.617433]  excludin=
g 0xa0000000-0xa0ffffff
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    9.617449] pcmcia_so=
cket pcmcia_socket0: cs: memory probe 0x60000000-0x60ffffff:
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [    9.617467]  excludin=
g 0x60000000-0x60ffffff
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [   12.142918] init: idm=
apd main process (4285) terminated with status 1
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [   12.142942] init: idm=
apd main process ended, respawning
Jul 17 07:15:33 edumazet-Latitude-D630 kernel: [   12.772245] init: fai=
lsafe main process (4217) killed by TERM signal
Jul 17 07:15:34 edumazet-Latitude-D630 kernel: [   13.886855] init: ude=
v-fallback-graphics main process (4362) terminated with status 1
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Found user '=
avahi' (UID 107) and group 'avahi' (GID 118).
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Successfully=
 dropped root privileges.
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: avahi-daemon=
 0.6.30 starting up.
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Bluetooth daem=
on 4.98
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Starting SDP s=
erver
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Server initial=
ization failed
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Failed to init=
 alert plugin
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Failed to init=
 time plugin
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Failed to init=
 proximity plugin
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Successfully=
 called chroot().
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Successfully=
 dropped remaining capabilities.
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Loading serv=
ice file /services/udisks.service.
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Network inte=
rface enumeration completed.
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Registering =
HINFO record with values 'I686'/'LINUX'.
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Server start=
up complete. Host name is edumazet-Latitude-D630.local. Local service c=
ookie is 849625138.
Jul 17 07:15:35 edumazet-Latitude-D630 avahi-daemon[4380]: Service "edu=
mazet-Latitude-D630" (/services/udisks.service) successfully establishe=
d.
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Can't init bne=
p module
Jul 17 07:15:35 edumazet-Latitude-D630 bluetoothd[4382]: Failed to init=
 network plugin
Jul 17 07:15:35 edumazet-Latitude-D630 modem-manager[4351]: <info>  Mod=
emManager (version 0.5.2.0) starting...
Jul 17 07:15:36 edumazet-Latitude-D630 bluetoothd[4382]: Unable to star=
t SCO server socket
Jul 17 07:15:36 edumazet-Latitude-D630 bluetoothd[4382]: Failed to init=
 audio plugin
Jul 17 07:15:36 edumazet-Latitude-D630 bluetoothd[4382]: Failed to init=
 gatt_example plugin
Jul 17 07:15:36 edumazet-Latitude-D630 bluetoothd[4382]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:36 edumazet-Latitude-D630 bluetoothd[4382]: adapter_ops_se=
tup failed
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Option High-Speed
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin SimTech
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Novatel
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin MotoC
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Sierra
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Longcheer
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Generic
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Wavecom
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin X22X
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Nokia
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin AnyData
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin ZTE
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Option
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Gobi
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Samsung
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Linktop
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Ericsson MBM
Jul 17 07:15:36 edumazet-Latitude-D630 modem-manager[4351]: <info>  Loa=
ded plugin Huawei
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.299404] init: blu=
etooth main process (4382) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.299428] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 cron[4420]: (CRON) INFO (pidfile=
 fd =3D 3)
Jul 17 07:15:37 edumazet-Latitude-D630 NetworkManager[4424]: <info> Net=
workManager (version 0.9.4.0) is starting...
Jul 17 07:15:37 edumazet-Latitude-D630 NetworkManager[4424]: <info> Rea=
d config file /etc/NetworkManager/NetworkManager.conf
Jul 17 07:15:37 edumazet-Latitude-D630 anacron[4437]: Anacron 2.3 start=
ed on 2012-07-17
Jul 17 07:15:37 edumazet-Latitude-D630 acpid: starting up with proc fs
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 cron[4442]: (CRON) STARTUP (fork=
 ok)
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 anacron[4437]: Will run job `cro=
n.daily' in 5 min.
Jul 17 07:15:37 edumazet-Latitude-D630 anacron[4437]: Jobs will be exec=
uted sequentially
Jul 17 07:15:37 edumazet-Latitude-D630 acpid: 35 rules loaded
Jul 17 07:15:37 edumazet-Latitude-D630 acpid: waiting for events: event=
 logging is off
Jul 17 07:15:37 edumazet-Latitude-D630 cron[4442]: (CRON) INFO (Running=
 @reboot jobs)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4460]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.729051] init: blu=
etooth main process (4460) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.729076] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4483]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.745351] init: blu=
etooth main process (4483) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.745374] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4506]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.761779] init: blu=
etooth main process (4506) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.761803] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4530]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.778402] init: blu=
etooth main process (4530) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.778428] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4554]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.794511] init: blu=
etooth main process (4554) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.794534] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4577]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.810758] init: blu=
etooth main process (4577) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.810782] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4600]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.826954] init: blu=
etooth main process (4600) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.826977] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4623]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.843608] init: blu=
etooth main process (4623) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.843633] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4647]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.860654] init: blu=
etooth main process (4647) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.860678] init: blu=
etooth main process ended, respawning
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Bluetooth daem=
on 4.98
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Starting SDP s=
erver
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: opening L2CAP =
socket: Address family not supported by protocol
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Server initial=
ization failed
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Failed to init=
 alert plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Failed to init=
 time plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Failed to init=
 proximity plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Failed to open=
 control socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Can't init bne=
p module
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Failed to init=
 network plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Unable to star=
t SCO server socket
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Failed to init=
 audio plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Failed to init=
 gatt_example plugin
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: Can't open HCI=
 socket: Address family not supported by protocol (97)
Jul 17 07:15:37 edumazet-Latitude-D630 bluetoothd[4671]: adapter_ops_se=
tup failed
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.877127] init: blu=
etooth main process (4671) terminated with status 1
Jul 17 07:15:37 edumazet-Latitude-D630 kernel: [   16.877152] init: blu=
etooth respawning too fast, stopped
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping uarts
Jul 17 07:15:37 edumazet-Latitude-D630 bluez: Stopping rfcomm
Jul 17 07:15:38 edumazet-Latitude-D630 NetworkManager[4424]: <info> VPN=
: loaded org.freedesktop.NetworkManager.pptp
Jul 17 07:15:38 edumazet-Latitude-D630 NetworkManager[4424]: <info> DNS=
: loaded plugin dnsmasq
Jul 17 07:15:38 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.PolicyKit1' (using servicehelper)
Jul 17 07:15:39 edumazet-Latitude-D630 polkitd[4702]: started daemon ve=
rsion 0.104 using authority implementation `local' version `0.104'
Jul 17 07:15:39 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.PolicyKit1'
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: init!
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: update_system_hostname
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
nIfupdown: management mode: unmanaged
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: devices added (path: /sys/devices/pci0000:00/0000:00:1c.5/0=
000:09:00.0/net/eth0, iface: eth0)
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: device added (path: /sys/devices/pci0000:00/0000:00:1c.5/00=
00:09:00.0/net/eth0, iface: eth0): no ifupdown configuration found.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: devices added (path: /sys/devices/virtual/net/lo, iface: lo=
)
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: device added (path: /sys/devices/virtual/net/lo, iface: lo)=
: no ifupdown configuration found.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: devices added (path: /sys/devices/virtual/net/sit0, iface: =
sit0)
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: device added (path: /sys/devices/virtual/net/sit0, iface: s=
it0): no ifupdown configuration found.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: end _init.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> Loa=
ded plugin ifupdown: (C) 2008 Canonical Ltd.  To report bugs please use=
 the NetworkManager mailing list.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> Loa=
ded plugin keyfile: (c) 2007 - 2010 Red Hat, Inc.  To report bugs pleas=
e use the NetworkManager mailing list.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    Ifupdow=
n: get unmanaged devices count: 0
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: (143950672) ... get_connections.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    SCPlugi=
n-Ifupdown: (143950672) ... get_connections (managed=3Dfalse): return e=
mpty list.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    keyfile=
: parsing CEROwrt ...=20
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    keyfile=
:     read connection 'CEROwrt'
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]:    Ifupdow=
n: get unmanaged devices count: 0
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> mod=
em-manager is now available
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> mon=
itoring kernel firmware directory '/lib/firmware'.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> WiF=
i enabled by radio killswitch; enabled by state file
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> WWA=
N enabled by radio killswitch; enabled by state file
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> WiM=
AX enabled by radio killswitch; enabled by state file
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> Net=
working is enabled by state file
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <warn> fai=
led to allocate link cache: (-10) Operation not supported
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): carrier is OFF
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): new Ethernet device (driver: 'tg3' ifindex: 3)
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): exported as /org/freedesktop/NetworkManager/Devices/0
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): now managed
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): device state change: unmanaged -> unavailable (reason 'managed') [=
10 20 2]
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): bringing up device.
Jul 17 07:15:39 edumazet-Latitude-D630 kernel: [   18.939690] tg3 0000:=
09:00.0: irq 45 for MSI/MSI-X
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): preparing device.
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): deactivating device (reason 'managed') [2]
Jul 17 07:15:39 edumazet-Latitude-D630 kernel: [   18.977381] IPv6: ADD=
RCONF(NETDEV_UP): eth0: link is not ready
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <info> Add=
ed default wired connection 'Connexion filaire 1' for /sys/devices/pci0=
000:00/0000:00:1c.5/0000:09:00.0/net/eth0
Jul 17 07:15:39 edumazet-Latitude-D630 NetworkManager[4424]: <warn> blu=
ez error getting default adapter: The name org.bluez was not provided b=
y any .service files
Jul 17 07:15:40  NetworkManager[4424]: last message repeated 10 times
Jul 17 07:15:40 edumazet-Latitude-D630 acpid: client connected from 469=
8[0:0]
Jul 17 07:15:40 edumazet-Latitude-D630 acpid: 1 client rule loaded
Jul 17 07:15:42 edumazet-Latitude-D630 kernel: [   21.769713] mtrr: bas=
e(0xf3000000) is not aligned on a size(0xe00000) boundary
Jul 17 07:15:43 edumazet-Latitude-D630 kernel: [   22.027752] tg3 0000:=
09:00.0: eth0: Link is up at 1000 Mbps, full duplex
Jul 17 07:15:43 edumazet-Latitude-D630 kernel: [   22.027755] tg3 0000:=
09:00.0: eth0: Flow control is on for TX and on for RX
Jul 17 07:15:43 edumazet-Latitude-D630 kernel: [   22.027866] IPv6: ADD=
RCONF(NETDEV_CHANGE): eth0: link becomes ready
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): carrier now ON (device state 20)
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): device state change: unavailable -> disconnected (reason 'carrier-=
changed') [20 30 40]
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Aut=
o-activating connection 'Connexion filaire 1'.
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) starting connection 'Connexion filaire 1'
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): device state change: disconnected -> prepare (reason 'none') [30 4=
0 0]
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 1 of 5 (Device Prepare) scheduled...
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 1 of 5 (Device Prepare) started...
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 2 of 5 (Device Configure) scheduled...
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 1 of 5 (Device Prepare) complete.
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 2 of 5 (Device Configure) starting...
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): device state change: prepare -> config (reason 'none') [40 50 0]
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 2 of 5 (Device Configure) successful.
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 3 of 5 (IP Configure Start) scheduled.
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 2 of 5 (Device Configure) complete.
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 3 of 5 (IP Configure Start) started...
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): device state change: config -> ip-config (reason 'none') [50 70 0]
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Beginning DHCPv4 transaction (timeout in 45 seconds)
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> dhc=
lient started with pid 4823
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Beginning IP6 addrconf.
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 3 of 5 (IP Configure Start) complete.
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: Internet Systems Conso=
rtium DHCP Client 4.1-ESV-R4
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: Copyright 2004-2011 In=
ternet Systems Consortium.
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: All rights reserved.
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: For info, please visit=
 https://www.isc.org/software/dhcp/
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient:=20
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): DHCPv4 state changed nbi -> preinit
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: Listening on LPF/eth0/=
00:21:70:b0:e4:89
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: Sending on   LPF/eth0/=
00:21:70:b0:e4:89
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: Sending on   Socket/fa=
llback
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: DHCPDISCOVER on eth0 t=
o 255.255.255.255 port 67 interval 3
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: DHCPREQUEST of 172.30.=
42.13 on eth0 to 255.255.255.255 port 67
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: DHCPOFFER of 172.30.42=
=2E13 from 172.30.42.1
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: DHCPACK of 172.30.42.1=
3 from 172.30.42.1
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): DHCPv4 state changed preinit -> bound
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info>   a=
ddress 172.30.42.13
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info>   p=
refix 27 (255.255.255.224)
Jul 17 07:15:43 edumazet-Latitude-D630 dhclient: bound to 172.30.42.13 =
-- renewal in 32510 seconds.
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info>   g=
ateway 172.30.42.1
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info>   h=
ostname 'edumazet-Latitude-D630'
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info>   n=
ameserver '172.30.42.1'
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info>   d=
omain name 'home.lan'
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info>   w=
ins '172.30.42.1'
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 5 of 5 (IPv4 Configure Commit) scheduled...
Jul 17 07:15:43 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 5 of 5 (IPv4 Commit) started...
Jul 17 07:15:43 edumazet-Latitude-D630 avahi-daemon[4380]: Joining mDNS=
 multicast group on interface eth0.IPv4 with address 172.30.42.13.
Jul 17 07:15:43 edumazet-Latitude-D630 avahi-daemon[4380]: New relevant=
 interface eth0.IPv4 for mDNS.
Jul 17 07:15:43 edumazet-Latitude-D630 avahi-daemon[4380]: Registering =
new address record for 172.30.42.13 on eth0.IPv4.
Jul 17 07:15:43 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.Accounts' (using servicehelper)
Jul 17 07:15:43 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.Accounts'
Jul 17 07:15:43 edumazet-Latitude-D630 accounts-daemon[4833]: started d=
aemon version 0.6.15
Jul 17 07:15:44 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.ConsoleKit' (using servicehelper)
Jul 17 07:15:44 edumazet-Latitude-D630 NetworkManager[4424]: <info> DNS=
: starting dnsmasq...
Jul 17 07:15:44 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.ConsoleKit'
Jul 17 07:15:44 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): writing resolv.conf to /sbin/resolvconf
Jul 17 07:15:44 edumazet-Latitude-D630 dnsmasq[4914]: d=C3=A9marrage av=
ec le cache d=C3=A9sactiv=C3=A9 (version 2.59)
Jul 17 07:15:44 edumazet-Latitude-D630 dnsmasq[4914]: options =C3=A0 la=
 compilation : IPv6 GNU-getopt DBus i18n DHCP TFTP conntrack IDN
Jul 17 07:15:44 edumazet-Latitude-D630 dnsmasq[4914]: utilise le serveu=
r de nom 172.30.42.1#53
Jul 17 07:15:45 edumazet-Latitude-D630 avahi-daemon[4380]: Joining mDNS=
 multicast group on interface eth0.IPv6 with address fe80::221:70ff:feb=
0:e489.
Jul 17 07:15:45 edumazet-Latitude-D630 avahi-daemon[4380]: New relevant=
 interface eth0.IPv6 for mDNS.
Jul 17 07:15:45 edumazet-Latitude-D630 avahi-daemon[4380]: Registering =
new address record for fe80::221:70ff:feb0:e489 on eth0.*.
Jul 17 07:15:45 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): device state change: ip-config -> activated (reason 'none') [70 10=
0 0]
Jul 17 07:15:45 edumazet-Latitude-D630 NetworkManager[4424]: <info> Pol=
icy set 'Connexion filaire 1' (eth0) as default for IPv4 routing and DN=
S.
Jul 17 07:15:45 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) successful, device activated.
Jul 17 07:15:45 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 5 of 5 (IPv4 Commit) complete.
Jul 17 07:15:45 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.nm_dispatcher' (using servicehelper)
Jul 17 07:15:45 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.nm_dispatcher'
Jul 17 07:15:49 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.UPower' (using servicehelper)
Jul 17 07:15:49 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.UPower'
Jul 17 07:15:50 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.ColorManager' (using servicehelper)
Jul 17 07:15:50 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.ColorManager'
Jul 17 07:15:53 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.RealtimeKit1' (using servicehelper)
Jul 17 07:15:53 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.RealtimeKit1'
Jul 17 07:15:53 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 called chroot.
Jul 17 07:15:53 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 dropped privileges.
Jul 17 07:15:53 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 limited resources.
Jul 17 07:15:53 edumazet-Latitude-D630 rtkit-daemon[5160]: Running.
Jul 17 07:15:53 edumazet-Latitude-D630 rtkit-daemon[5160]: Watchdog thr=
ead running.
Jul 17 07:15:53 edumazet-Latitude-D630 rtkit-daemon[5160]: Canary threa=
d running.
Jul 17 07:15:53 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 made thread 5158 of process 5158 (n/a) owned by '104' high priority at=
 nice level -11.
Jul 17 07:15:53 edumazet-Latitude-D630 rtkit-daemon[5160]: Supervising =
1 threads of 1 processes of 1 users.
Jul 17 07:15:55 edumazet-Latitude-D630 ntpdate[5014]: step time server =
91.189.94.4 offset 0.829162 sec
Jul 17 07:15:55 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 made thread 5166 of process 5158 (n/a) owned by '104' RT at priority 5=
=2E
Jul 17 07:15:55 edumazet-Latitude-D630 rtkit-daemon[5160]: Supervising =
2 threads of 1 processes of 1 users.
Jul 17 07:15:55 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 made thread 5167 of process 5158 (n/a) owned by '104' RT at priority 5=
=2E
Jul 17 07:15:55 edumazet-Latitude-D630 rtkit-daemon[5160]: Supervising =
3 threads of 1 processes of 1 users.
Jul 17 07:15:55 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 made thread 5170 of process 5170 (n/a) owned by '104' high priority at=
 nice level -11.
Jul 17 07:15:55 edumazet-Latitude-D630 rtkit-daemon[5160]: Supervising =
4 threads of 2 processes of 1 users.
Jul 17 07:15:55 edumazet-Latitude-D630 pulseaudio[5170]: [pulseaudio] p=
id.c: Daemon already running.
Jul 17 07:16:04 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): IP6 addrconf timed out or failed.
Jul 17 07:16:04 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 4 of 5 (IPv6 Configure Timeout) scheduled...
Jul 17 07:16:04 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 4 of 5 (IPv6 Configure Timeout) started...
Jul 17 07:16:04 edumazet-Latitude-D630 NetworkManager[4424]: <info> Act=
ivation (eth0) Stage 4 of 5 (IPv6 Configure Timeout) complete.
Jul 17 07:16:19 edumazet-Latitude-D630 gnome-session[5234]: WARNING: Se=
ssion 'ubuntu' runnable check failed: Quitt=C3=A9 avec le code 5
Jul 17 07:16:20 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 made thread 5308 of process 5308 (n/a) owned by '1000' high priority a=
t nice level -11.
Jul 17 07:16:20 edumazet-Latitude-D630 rtkit-daemon[5160]: Supervising =
4 threads of 2 processes of 2 users.
Jul 17 07:16:21 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 made thread 5311 of process 5308 (n/a) owned by '1000' RT at priority =
5.
Jul 17 07:16:21 edumazet-Latitude-D630 rtkit-daemon[5160]: Supervising =
5 threads of 2 processes of 2 users.
Jul 17 07:16:21 edumazet-Latitude-D630 rtkit-daemon[5160]: Successfully=
 made thread 5312 of process 5308 (n/a) owned by '1000' RT at priority =
5.
Jul 17 07:16:21 edumazet-Latitude-D630 rtkit-daemon[5160]: Supervising =
6 threads of 2 processes of 2 users.
Jul 17 07:16:27 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.UDisks' (using servicehelper)
Jul 17 07:16:28 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.UDisks'
Jul 17 07:16:41 edumazet-Latitude-D630 goa[5628]: goa-daemon version 3.=
4.0 starting [main.c:112, main()]
Jul 17 07:17:01 edumazet-Latitude-D630 CRON[5658]: (root) CMD (   cd / =
&& run-parts --report /etc/cron.hourly)
Jul 17 07:17:30 edumazet-Latitude-D630 dbus[4327]: [system] Activating =
service name=3D'org.freedesktop.PackageKit' (using servicehelper)
Jul 17 07:17:31 edumazet-Latitude-D630 AptDaemon: INFO: Initializing da=
emon
Jul 17 07:17:32 edumazet-Latitude-D630 AptDaemon.PackageKit: INFO: Init=
ializing PackageKit compat layer
Jul 17 07:17:32 edumazet-Latitude-D630 dbus[4327]: [system] Successfull=
y activated service 'org.freedesktop.PackageKit'
Jul 17 07:17:32 edumazet-Latitude-D630 AptDaemon.PackageKit: INFO: Init=
ializing PackageKit transaction
Jul 17 07:17:32 edumazet-Latitude-D630 AptDaemon.Worker: INFO: Simulati=
ng trans: /org/debian/apt/transaction/bee5048fc27b41cb98eb6722cfee5e09
Jul 17 07:17:32 edumazet-Latitude-D630 AptDaemon.Worker: INFO: Processi=
ng transaction /org/debian/apt/transaction/bee5048fc27b41cb98eb6722cfee=
5e09
Jul 17 07:17:34 edumazet-Latitude-D630 AptDaemon.PackageKit: INFO: Get =
updates()
Jul 17 07:17:35 edumazet-Latitude-D630 AptDaemon.Worker: INFO: Finished=
 transaction /org/debian/apt/transaction/bee5048fc27b41cb98eb6722cfee5e=
09
Jul 17 07:18:13 edumazet-Latitude-D630 kernel: [  171.807545] git (5835=
) used greatest stack depth: 6172 bytes left
Jul 17 07:18:13 edumazet-Latitude-D630 kernel: [  171.857417] git (5834=
) used greatest stack depth: 6012 bytes left
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  264.427149] tg3 0000:=
09:00.0: eth0: RDMA Status error.  Resetting chip.
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  264.475600] hrtimer: =
interrupt took 15773745 ns
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247878] tg3 0000:=
09:00.0: eth0: 0x00000000: 0x167314e4, 0x40100506, 0x02000002, 0x000000=
10
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247882] tg3 0000:=
09:00.0: eth0: 0x00000010: 0xf1ef0004, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247885] tg3 0000:=
09:00.0: eth0: 0x00000020: 0x00000000, 0x00000000, 0x00000000, 0x01f910=
28
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247888] tg3 0000:=
09:00.0: eth0: 0x00000030: 0xfff90000, 0x00000048, 0x00000000, 0x000001=
03
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247891] tg3 0000:=
09:00.0: eth0: 0x00000040: 0x00000000, 0x00000000, 0xc0035001, 0x640020=
08
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247894] tg3 0000:=
09:00.0: eth0: 0x00000050: 0x00ac5803, 0xfed7afff, 0x0078e809, 0x0d7fe0=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247897] tg3 0000:=
09:00.0: eth0: 0x00000060: 0x00000000, 0x00000000, 0xa0020298, 0x761800=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247900] tg3 0000:=
09:00.0: eth0: 0x00000070: 0x000010f2, 0x000000c0, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247903] tg3 0000:=
09:00.0: eth0: 0x00000080: 0x167314e4, 0x00000000, 0x04130034, 0xec08f0=
82
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247906] tg3 0000:=
09:00.0: eth0: 0x00000090: 0x0100db19, 0x00000000, 0x00000000, 0x000001=
51
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247909] tg3 0000:=
09:00.0: eth0: 0x000000a0: 0x00000000, 0x00000089, 0x00000000, 0x000001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247912] tg3 0000:=
09:00.0: eth0: 0x000000b0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247915] tg3 0000:=
09:00.0: eth0: 0x000000c0: 0x00000000, 0x00000000, 0x0000000e, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247918] tg3 0000:=
09:00.0: eth0: 0x000000d0: 0x00010010, 0x05048fa0, 0x00132000, 0x00076c=
11
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247921] tg3 0000:=
09:00.0: eth0: 0x000000e0: 0x10110141, 0x00000000, 0x0081d005, 0xfee020=
0c
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247924] tg3 0000:=
09:00.0: eth0: 0x000000f0: 0x00000000, 0x00004199, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247927] tg3 0000:=
09:00.0: eth0: 0x00000100: 0x13c10001, 0x00004000, 0x00000000, 0x000620=
11
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247930] tg3 0000:=
09:00.0: eth0: 0x00000110: 0x000030c1, 0x00002000, 0x000000ae, 0x400000=
01
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247933] tg3 0000:=
09:00.0: eth0: 0x00000120: 0x0000000f, 0xf1ef0204, 0xd89e18c0, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247936] tg3 0000:=
09:00.0: eth0: 0x00000130: 0x00000000, 0x00000000, 0x00000000, 0x160100=
02
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247939] tg3 0000:=
09:00.0: eth0: 0x00000150: 0x80000001, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247943] tg3 0000:=
09:00.0: eth0: 0x00000160: 0x16c10003, 0xfeb0e489, 0x002170ff, 0x000100=
04
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247946] tg3 0000:=
09:00.0: eth0: 0x00000170: 0x00000000, 0x0007810e, 0x00000001, 0x2c0c3c=
0e
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247949] tg3 0000:=
09:00.0: eth0: 0x00000180: 0x3f062304, 0x00000000, 0x00000000, 0xffffff=
ff
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247952] tg3 0000:=
09:00.0: eth0: 0x00000200: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247955] tg3 0000:=
09:00.0: eth0: 0x00000210: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247957] tg3 0000:=
09:00.0: eth0: 0x00000220: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247960] tg3 0000:=
09:00.0: eth0: 0x00000230: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247963] tg3 0000:=
09:00.0: eth0: 0x00000240: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247966] tg3 0000:=
09:00.0: eth0: 0x00000250: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247969] tg3 0000:=
09:00.0: eth0: 0x00000260: 0x00000000, 0xe9000000, 0x00000000, 0x000001=
51
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247973] tg3 0000:=
09:00.0: eth0: 0x00000270: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247975] tg3 0000:=
09:00.0: eth0: 0x00000280: 0x00000000, 0x00000089, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247979] tg3 0000:=
09:00.0: eth0: 0x000002a0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247981] tg3 0000:=
09:00.0: eth0: 0x000002b0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247984] tg3 0000:=
09:00.0: eth0: 0x000002c0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247987] tg3 0000:=
09:00.0: eth0: 0x000002d0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247990] tg3 0000:=
09:00.0: eth0: 0x000002e0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247993] tg3 0000:=
09:00.0: eth0: 0x000002f0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247996] tg3 0000:=
09:00.0: eth0: 0x00000300: 0x00000000, 0x0000013a, 0x00000000, 0xe90001=
3a
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.247999] tg3 0000:=
09:00.0: eth0: 0x00000310: 0x00000000, 0xe900013a, 0x00000000, 0xe90001=
3a
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248013] tg3 0000:=
09:00.0: eth0: 0x00000320: 0x00000000, 0xe900013a, 0x00000000, 0xe90001=
3a
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248016] tg3 0000:=
09:00.0: eth0: 0x00000330: 0x00000000, 0xe900013a, 0x00000000, 0xe90001=
3a
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248019] tg3 0000:=
09:00.0: eth0: 0x00000340: 0x00000000, 0xe900013a, 0x00000000, 0xe90001=
3a
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248022] tg3 0000:=
09:00.0: eth0: 0x00000350: 0x00000000, 0xe900013a, 0x00000000, 0xe90001=
3a
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248025] tg3 0000:=
09:00.0: eth0: 0x00000360: 0x00000000, 0xe900013a, 0x00000000, 0xe90001=
3a
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248028] tg3 0000:=
09:00.0: eth0: 0x00000370: 0x00000000, 0xe900013a, 0x00000000, 0xe90001=
3a
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248031] tg3 0000:=
09:00.0: eth0: 0x00000380: 0x00000000, 0x00000127, 0x00000000, 0xe90001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248034] tg3 0000:=
09:00.0: eth0: 0x00000390: 0x00000000, 0xe9000127, 0x00000000, 0xe90001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248037] tg3 0000:=
09:00.0: eth0: 0x000003a0: 0x00000000, 0xe9000127, 0x00000000, 0xe90001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248040] tg3 0000:=
09:00.0: eth0: 0x000003b0: 0x00000000, 0xe9000127, 0x00000000, 0xe90001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248043] tg3 0000:=
09:00.0: eth0: 0x000003c0: 0x00000000, 0xe9000127, 0x00000000, 0xe90001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248046] tg3 0000:=
09:00.0: eth0: 0x000003d0: 0x00000000, 0xe9000127, 0x00000000, 0xe90001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248049] tg3 0000:=
09:00.0: eth0: 0x000003e0: 0x00000000, 0xe9000127, 0x00000000, 0xe90001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248052] tg3 0000:=
09:00.0: eth0: 0x000003f0: 0x00000000, 0xe9000127, 0x00000000, 0xe90001=
27
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248055] tg3 0000:=
09:00.0: eth0: 0x00000400: 0x00e04808, 0x00400000, 0x00001000, 0x00009b=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248058] tg3 0000:=
09:00.0: eth0: 0x00000410: 0x00000021, 0x70b0e489, 0x00000021, 0x70b0e4=
89
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248061] tg3 0000:=
09:00.0: eth0: 0x00000420: 0x00000021, 0x70b0e489, 0x00000021, 0x70b0e4=
89
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248064] tg3 0000:=
09:00.0: eth0: 0x00000430: 0x00000000, 0x00000000, 0x000000e6, 0x000005=
f2
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248067] tg3 0000:=
09:00.0: eth0: 0x00000440: 0x00000000, 0x00000000, 0x00000000, 0x083103=
01
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248070] tg3 0000:=
09:00.0: eth0: 0x00000450: 0x00000001, 0x000c0000, 0x00000000, 0x000001=
12
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248073] tg3 0000:=
09:00.0: eth0: 0x00000460: 0x00000008, 0x00002620, 0x01000406, 0x000000=
06
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248076] tg3 0000:=
09:00.0: eth0: 0x00000470: 0xa0000010, 0x00000000, 0x00000000, 0x500000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248079] tg3 0000:=
09:00.0: eth0: 0x00000480: 0x42000000, 0x7fffffff, 0x06000004, 0x7fffff=
ff
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248082] tg3 0000:=
09:00.0: eth0: 0x00000500: 0x00000008, 0x00000002, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248085] tg3 0000:=
09:00.0: eth0: 0x00000590: 0x00e00000, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248088] tg3 0000:=
09:00.0: eth0: 0x00000600: 0xffffffff, 0x00f80011, 0x00000000, 0x00001f=
04
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248091] tg3 0000:=
09:00.0: eth0: 0x00000610: 0xffffffff, 0x00000000, 0x07c00004, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248094] tg3 0000:=
09:00.0: eth0: 0x00000620: 0x00000040, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248097] tg3 0000:=
09:00.0: eth0: 0x00000800: 0x00000000, 0xffffffff, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248100] tg3 0000:=
09:00.0: eth0: 0x00000810: 0x00000000, 0xffffffff, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248103] tg3 0000:=
09:00.0: eth0: 0x00000820: 0x00000000, 0x00000000, 0xffffffff, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248106] tg3 0000:=
09:00.0: eth0: 0x00000830: 0x00000000, 0xffffffff, 0xffffffff, 0xffffff=
ff
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248109] tg3 0000:=
09:00.0: eth0: 0x00000840: 0xffffffff, 0xffffffff, 0xffffffff, 0xffffff=
ff
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248112] tg3 0000:=
09:00.0: eth0: 0x00000850: 0xffffffff, 0xffffffff, 0xffffffff, 0xffffff=
ff
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248115] tg3 0000:=
09:00.0: eth0: 0x00000860: 0xffffffff, 0xffffffff, 0xffffffff, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248118] tg3 0000:=
09:00.0: eth0: 0x00000880: 0x00000040, 0x0000284c, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248121] tg3 0000:=
09:00.0: eth0: 0x00000890: 0x00000001, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248124] tg3 0000:=
09:00.0: eth0: 0x000008f0: 0x00000001, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248127] tg3 0000:=
09:00.0: eth0: 0x00000c00: 0x0000000a, 0x00000000, 0x00000003, 0x000000=
01
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248130] tg3 0000:=
09:00.0: eth0: 0x00000c10: 0x00000000, 0x00000007, 0x00000000, 0x05a200=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248133] tg3 0000:=
09:00.0: eth0: 0x00000c80: 0x000cd840, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248136] tg3 0000:=
09:00.0: eth0: 0x00000ce0: 0x3273d002, 0x00000000, 0x000005a2, 0x000410=
28
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248139] tg3 0000:=
09:00.0: eth0: 0x00000cf0: 0x00000000, 0x5000007c, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248142] tg3 0000:=
09:00.0: eth0: 0x00001000: 0x00000002, 0x00000000, 0xa0000296, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248145] tg3 0000:=
09:00.0: eth0: 0x00001010: 0x00f80f80, 0x00000296, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248148] tg3 0000:=
09:00.0: eth0: 0x00001400: 0x00000006, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248151] tg3 0000:=
09:00.0: eth0: 0x00001440: 0x000000fd, 0x000000fd, 0x000000fd, 0x000000=
fd
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248154] tg3 0000:=
09:00.0: eth0: 0x00001450: 0x000000fd, 0x000000fd, 0x000000fd, 0x000000=
fd
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248157] tg3 0000:=
09:00.0: eth0: 0x00001460: 0x000000fd, 0x000000fd, 0x000000fd, 0x000000=
fd
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248160] tg3 0000:=
09:00.0: eth0: 0x00001470: 0x000000fd, 0x000000fd, 0x000000fd, 0x000000=
fd
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248163] tg3 0000:=
09:00.0: eth0: 0x00001480: 0x00000004, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248166] tg3 0000:=
09:00.0: eth0: 0x00001800: 0x00000016, 0x00000000, 0x00000128, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248169] tg3 0000:=
09:00.0: eth0: 0x00001840: 0x00000000, 0x00000000, 0x00000210, 0x000000=
10
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248172] tg3 0000:=
09:00.0: eth0: 0x00001850: 0x34be3270, 0x00000000, 0x00004270, 0x012801=
28
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248175] tg3 0000:=
09:00.0: eth0: 0x00001860: 0x01000300, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248178] tg3 0000:=
09:00.0: eth0: 0x00001c00: 0x00000002, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248181] tg3 0000:=
09:00.0: eth0: 0x00002000: 0x00000002, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248184] tg3 0000:=
09:00.0: eth0: 0x00002010: 0x00000181, 0x00000001, 0x007a800b, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248187] tg3 0000:=
09:00.0: eth0: 0x00002100: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248190] tg3 0000:=
09:00.0: eth0: 0x00002110: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248193] tg3 0000:=
09:00.0: eth0: 0x00002120: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248196] tg3 0000:=
09:00.0: eth0: 0x00002130: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248199] tg3 0000:=
09:00.0: eth0: 0x00002140: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248202] tg3 0000:=
09:00.0: eth0: 0x00002150: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248205] tg3 0000:=
09:00.0: eth0: 0x00002160: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248208] tg3 0000:=
09:00.0: eth0: 0x00002170: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248211] tg3 0000:=
09:00.0: eth0: 0x00002180: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248214] tg3 0000:=
09:00.0: eth0: 0x00002190: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248217] tg3 0000:=
09:00.0: eth0: 0x000021a0: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248220] tg3 0000:=
09:00.0: eth0: 0x000021b0: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248222] tg3 0000:=
09:00.0: eth0: 0x000021c0: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248225] tg3 0000:=
09:00.0: eth0: 0x000021d0: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248228] tg3 0000:=
09:00.0: eth0: 0x000021e0: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248231] tg3 0000:=
09:00.0: eth0: 0x000021f0: 0x000db2d9, 0x000db2d9, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248234] tg3 0000:=
09:00.0: eth0: 0x00002200: 0x00059dff, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248237] tg3 0000:=
09:00.0: eth0: 0x00002400: 0x00000012, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248240] tg3 0000:=
09:00.0: eth0: 0x00002450: 0x00000000, 0x34f70000, 0x02000000, 0x000060=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248243] tg3 0000:=
09:00.0: eth0: 0x00002470: 0x00000000, 0x0000008a, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248246] tg3 0000:=
09:00.0: eth0: 0x000024c0: 0x08000001, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248249] tg3 0000:=
09:00.0: eth0: 0x00002800: 0x00000006, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248252] tg3 0000:=
09:00.0: eth0: 0x00002c00: 0x00000006, 0x00000000, 0x00000000, 0x000000=
c8
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248255] tg3 0000:=
09:00.0: eth0: 0x00002c10: 0x00000000, 0x00000000, 0x00000008, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248258] tg3 0000:=
09:00.0: eth0: 0x00002c20: 0x00000001, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248261] tg3 0000:=
09:00.0: eth0: 0x00003000: 0x00000006, 0x00000000, 0x00000000, 0x000000=
c8
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248264] tg3 0000:=
09:00.0: eth0: 0x00003800: 0x00000007, 0x00000001, 0x0000000e, 0x051602=
8b
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248267] tg3 0000:=
09:00.0: eth0: 0x00003810: 0x00000100, 0x00000082, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248271] tg3 0000:=
09:00.0: eth0: 0x00003c00: 0x00000302, 0x00000000, 0x00000014, 0x000000=
48
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248273] tg3 0000:=
09:00.0: eth0: 0x00003c10: 0x00000005, 0x00000035, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248276] tg3 0000:=
09:00.0: eth0: 0x00003c20: 0x00000005, 0x00000005, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248279] tg3 0000:=
09:00.0: eth0: 0x00003c30: 0x00000000, 0x00000000, 0x00000000, 0x34bbf0=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248282] tg3 0000:=
09:00.0: eth0: 0x00003c40: 0x00000000, 0x00000b00, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248285] tg3 0000:=
09:00.0: eth0: 0x00003c50: 0x00000000, 0x0000008a, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248288] tg3 0000:=
09:00.0: eth0: 0x00003c80: 0x0000008a, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248291] tg3 0000:=
09:00.0: eth0: 0x00003cc0: 0x000000f8, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248294] tg3 0000:=
09:00.0: eth0: 0x00004000: 0x00000002, 0x00000000, 0x0000d9ce, 0x000430=
98
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248297] tg3 0000:=
09:00.0: eth0: 0x00004010: 0x00416070, 0x002da012, 0x00800440, 0x0041b1=
02
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248300] tg3 0000:=
09:00.0: eth0: 0x00004020: 0x0037f613, 0x00000000, 0x00000010, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248303] tg3 0000:=
09:00.0: eth0: 0x00004030: 0x00000010, 0x00000030, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248306] tg3 0000:=
09:00.0: eth0: 0x00004040: 0x00000000, 0x00000000, 0x01087620, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248309] tg3 0000:=
09:00.0: eth0: 0x00004050: 0x00000000, 0x00000000, 0x002d9010, 0x0040b0=
02
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248312] tg3 0000:=
09:00.0: eth0: 0x00004060: 0x00417000, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248315] tg3 0000:=
09:00.0: eth0: 0x00004400: 0x00000006, 0x00000000, 0x00011280, 0x00009d=
80
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248318] tg3 0000:=
09:00.0: eth0: 0x00004410: 0x00000000, 0x00000010, 0x00000060, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248321] tg3 0000:=
09:00.0: eth0: 0x00004420: 0x0000003d, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248324] tg3 0000:=
09:00.0: eth0: 0x00004440: 0x00000000, 0x00000000, 0x00000000, 0x00a058=
1d
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248327] tg3 0000:=
09:00.0: eth0: 0x00004450: 0x00010d3a, 0x00b600b7, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248330] tg3 0000:=
09:00.0: eth0: 0x00004800: 0x080303fe, 0x00000010, 0x00000000, 0x000000=
20
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248333] tg3 0000:=
09:00.0: eth0: 0x00004810: 0x00000011, 0x00000003, 0x00100374, 0x000000=
07
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248336] tg3 0000:=
09:00.0: eth0: 0x00004820: 0x03ea001c, 0x0000000f, 0xa4b303a8, 0x3273ba=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248339] tg3 0000:=
09:00.0: eth0: 0x00004830: 0x000003a4, 0x00000003, 0x000008db, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248342] tg3 0000:=
09:00.0: eth0: 0x00004840: 0x0017ec81, 0x0017ec80, 0x030e2200, 0x172a29=
19
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248345] tg3 0000:=
09:00.0: eth0: 0x00004850: 0xffff8ef4, 0xb1ed05a2, 0x0b0a0b0a, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248348] tg3 0000:=
09:00.0: eth0: 0x00004860: 0x00000017, 0x04296000, 0x10075968, 0x1000ff=
fa
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248351] tg3 0000:=
09:00.0: eth0: 0x00004870: 0x00004188, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248354] tg3 0000:=
09:00.0: eth0: 0x00004900: 0x00000002, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248357] tg3 0000:=
09:00.0: eth0: 0x00004c00: 0x200003fe, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248360] tg3 0000:=
09:00.0: eth0: 0x00004c10: 0x0000002a, 0x00000000, 0x00000006, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248363] tg3 0000:=
09:00.0: eth0: 0x00004c20: 0x00000000, 0x00000000, 0x00000000, 0x000000=
06
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248366] tg3 0000:=
09:00.0: eth0: 0x00004c30: 0x00000000, 0x00000000, 0x0000006b, 0x000000=
6b
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248369] tg3 0000:=
09:00.0: eth0: 0x00004c40: 0x00000000, 0x34bbf000, 0x00010020, 0x000000=
20
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248372] tg3 0000:=
09:00.0: eth0: 0x00004c50: 0x07fffe89, 0x022913ff, 0x00000000, 0x450aea=
ea
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248375] tg3 0000:=
09:00.0: eth0: 0x00005000: 0x00009800, 0x80000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248378] tg3 0000:=
09:00.0: eth0: 0x00005010: 0x00000000, 0x00000000, 0x00000000, 0x00010f=
6c
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248381] tg3 0000:=
09:00.0: eth0: 0x00005020: 0x1452000e, 0x00000000, 0x00000000, 0x400000=
20
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248384] tg3 0000:=
09:00.0: eth0: 0x00005030: 0x00000000, 0x0000001d, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248387] tg3 0000:=
09:00.0: eth0: 0x00005040: 0x00000000, 0x00000000, 0x00010946, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248390] tg3 0000:=
09:00.0: eth0: 0x00005200: 0x00000000, 0x00000b50, 0x00000b50, 0x0201c0=
d1
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248393] tg3 0000:=
09:00.0: eth0: 0x00005210: 0x00000001, 0x000109c4, 0x81100000, 0xb49a89=
ab
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248396] tg3 0000:=
09:00.0: eth0: 0x00005220: 0x000109c4, 0x81100000, 0x81100000, 0x0001bf=
a0
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248399] tg3 0000:=
09:00.0: eth0: 0x00005230: 0x00080000, 0x00000b50, 0x00000000, 0xc00000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248402] tg3 0000:=
09:00.0: eth0: 0x00005240: 0x00000b50, 0x0001bfa0, 0x4b657654, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248405] tg3 0000:=
09:00.0: eth0: 0x00005250: 0x00000000, 0x84546480, 0x00000000, 0x0201c0=
d1
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248408] tg3 0000:=
09:00.0: eth0: 0x00005260: 0x81100000, 0xb49a89ab, 0x000109c4, 0xec08f0=
82
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248411] tg3 0000:=
09:00.0: eth0: 0x00005270: 0x00000000, 0x00000000, 0x84546480, 0xb49a89=
ab
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248414] tg3 0000:=
09:00.0: eth0: 0x00005800: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248417] tg3 0000:=
09:00.0: eth0: 0x00005810: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248420] tg3 0000:=
09:00.0: eth0: 0x00005820: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248423] tg3 0000:=
09:00.0: eth0: 0x00005830: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248426] tg3 0000:=
09:00.0: eth0: 0x00005840: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248429] tg3 0000:=
09:00.0: eth0: 0x00005850: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248432] tg3 0000:=
09:00.0: eth0: 0x00005860: 0x00000000, 0xe9000000, 0x00000000, 0x000001=
51
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248435] tg3 0000:=
09:00.0: eth0: 0x00005870: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248438] tg3 0000:=
09:00.0: eth0: 0x00005880: 0x00000000, 0x00000089, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248441] tg3 0000:=
09:00.0: eth0: 0x000058a0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248444] tg3 0000:=
09:00.0: eth0: 0x000058b0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248447] tg3 0000:=
09:00.0: eth0: 0x000058c0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248450] tg3 0000:=
09:00.0: eth0: 0x000058d0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248453] tg3 0000:=
09:00.0: eth0: 0x000058e0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248456] tg3 0000:=
09:00.0: eth0: 0x000058f0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248459] tg3 0000:=
09:00.0: eth0: 0x00005900: 0x00000000, 0x0000013a, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248462] tg3 0000:=
09:00.0: eth0: 0x00005910: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248465] tg3 0000:=
09:00.0: eth0: 0x00005920: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248468] tg3 0000:=
09:00.0: eth0: 0x00005930: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248471] tg3 0000:=
09:00.0: eth0: 0x00005940: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248474] tg3 0000:=
09:00.0: eth0: 0x00005950: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248477] tg3 0000:=
09:00.0: eth0: 0x00005960: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248480] tg3 0000:=
09:00.0: eth0: 0x00005970: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248483] tg3 0000:=
09:00.0: eth0: 0x00005980: 0x00000000, 0x00000127, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248486] tg3 0000:=
09:00.0: eth0: 0x00005990: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248489] tg3 0000:=
09:00.0: eth0: 0x000059a0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248491] tg3 0000:=
09:00.0: eth0: 0x000059b0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248494] tg3 0000:=
09:00.0: eth0: 0x000059c0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248497] tg3 0000:=
09:00.0: eth0: 0x000059d0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248500] tg3 0000:=
09:00.0: eth0: 0x000059e0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248503] tg3 0000:=
09:00.0: eth0: 0x000059f0: 0x00000000, 0xe9000000, 0x00000000, 0xe90000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248506] tg3 0000:=
09:00.0: eth0: 0x00005a00: 0x00012001, 0x00000000, 0x00010000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248509] tg3 0000:=
09:00.0: eth0: 0x00006000: 0x00000002, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248513] tg3 0000:=
09:00.0: eth0: 0x00006800: 0x04130034, 0xec08f082, 0x0100db19, 0x0dedbb=
9b
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248516] tg3 0000:=
09:00.0: eth0: 0x00006810: 0x81100000, 0xffffffff, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248519] tg3 0000:=
09:00.0: eth0: 0x00006830: 0xffffffff, 0xffffffff, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248522] tg3 0000:=
09:00.0: eth0: 0x00006840: 0x00000004, 0x00000000, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248525] tg3 0000:=
09:00.0: eth0: 0x00006890: 0x02000001, 0x8001b000, 0x00000000, 0x001020=
40
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248528] tg3 0000:=
09:00.0: eth0: 0x000068a0: 0x0000002b, 0x200102c1, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248531] tg3 0000:=
09:00.0: eth0: 0x00007010: 0x00000000, 0x5f479a71, 0x00570081, 0x688483=
53
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248534] tg3 0000:=
09:00.0: eth0: 0x00007020: 0x00000000, 0x00000000, 0xaf000406, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248537] tg3 0000:=
09:00.0: eth0: 0x00007030: 0x0003e200, 0x000000c4, 0x00040000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248540] tg3 0000:=
09:00.0: eth0: 0x00007400: 0x00000000, 0x002aaa2a, 0x00000000, 0x000000=
00
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248546] tg3 0000:=
09:00.0: eth0: 0: Host status block [00000005:000000ea:(0000:008a:0000)=
:(008a:00f8)]
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.248549] tg3 0000:=
09:00.0: eth0: 0: NAPI info [000000e9:000000e9:(013a:00f8:01ff):0089:(0=
151:0000:0000:0000)]
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.352470] tg3 0000:=
09:00.0: tg3_stop_block timed out, ofs=3D1400 enable_bit=3D2
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.455012] tg3 0000:=
09:00.0: tg3_stop_block timed out, ofs=3Dc00 enable_bit=3D2
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.557436] tg3 0000:=
09:00.0: tg3_stop_block timed out, ofs=3D4800 enable_bit=3D2
Jul 17 07:19:48 edumazet-Latitude-D630 kernel: [  266.579224] tg3 0000:=
09:00.0: eth0: Link is down
Jul 17 07:19:48 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): carrier now OFF (device state 100, deferring action for 4 seconds)
Jul 17 07:19:51 edumazet-Latitude-D630 NetworkManager[4424]: <info> (et=
h0): carrier now ON (device state 100)
Jul 17 07:19:51 edumazet-Latitude-D630 kernel: [  269.707278] tg3 0000:=
09:00.0: eth0: Link is up at 1000 Mbps, full duplex
Jul 17 07:19:51 edumazet-Latitude-D630 kernel: [  269.707290] tg3 0000:=
09:00.0: eth0: Flow control is on for TX and on for RX
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720137] ---------=
---[ cut here ]------------
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720156] WARNING: =
at net/sched/sch_generic.c:255 dev_watchdog+0xba/0x111()
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720161] Hardware =
name: Latitude D630                  =20
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720166] NETDEV WA=
TCHDOG: eth0 (tg3): transmit queue 0 timed out
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720170] Modules l=
inked in: tg3
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720182] Pid: 0, c=
omm: swapper/1 Not tainted 3.5.0-rc5+ #10
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720186] Call Trac=
e:
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720199]  [<c10235=
d6>] warn_slowpath_common+0x63/0x78
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720206]  [<c13ca7=
b0>] ? dev_watchdog+0xba/0x111
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720214]  [<c10236=
4f>] warn_slowpath_fmt+0x26/0x2a
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720221]  [<c13ca7=
b0>] dev_watchdog+0xba/0x111
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720231]  [<c102dc=
57>] run_timer_softirq+0x146/0x1ea
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720238]  [<c13ca6=
f6>] ? netif_tx_unlock+0x3e/0x3e
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720247]  [<c10292=
71>] __do_softirq+0x93/0x12f
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720256]  [<c10291=
de>] ? local_bh_enable+0xa/0xa
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720260]  <IRQ>  [=
<c1029467>] ? irq_exit+0x35/0x82
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720275]  [<c1016c=
29>] ? smp_apic_timer_interrupt+0x5e/0x6c
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720284]  [<c14d10=
5e>] ? apic_timer_interrupt+0x2a/0x30
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720295]  [<c134f3=
88>] ? ladder_select_state+0x130/0x130
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720303]  [<c13400=
7b>] ? atomic_add_return+0x7/0xd
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720314]  [<c10753=
31>] ? rcu_idle_exit+0x69/0x6e
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720323]  [<c1007a=
81>] ? cpu_idle+0x55/0x6a
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720333]  [<c14c5a=
fb>] ? start_secondary+0x183/0x188
Jul 17 07:19:56 edumazet-Latitude-D630 kernel: [  274.720339] ---[ end =
trace 524bdd2822b0240d ]---
