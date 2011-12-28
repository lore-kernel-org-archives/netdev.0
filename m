From: Tim Hartrick <tim@edgecast.com>
Subject: Crash in ip_expire/icmp_send - 2.6.38.2 (Ubuntu 11.04 natty)
Date: Tue, 27 Dec 2011 20:32:21 -0700
Message-ID: <1325043141.4354.20.camel@boudreau>
Reply-To: tim@edgecast.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58011 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab1L1Dcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 22:32:35 -0500
Received: by iaeh11 with SMTP id h11so21340945iae.19
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 19:32:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netdev,

We have observed the crash cited below on a number of our load-balancing
systems recently.  The systems in question are running LVS in DR mode on
two pairs of bonded (ifenslave) 1G Intel interfaces.  There is very
little else running on the systems.  This particular instance occurred
within seconds of using "ip route add a.b.c.d/x dev bond1" but we have
observed it on other occasions.

Using crash the problem has been isolated to this section of code:

void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
{
        struct iphdr *iph;
        int room;
        struct icmp_bxm icmp_param;
        struct rtable *rt = skb_rtable(skb_in);
        struct ipcm_cookie ipc;
        __be32 saddr;
        u8  tos;
        struct net *net;
        struct sock *sk;

        if (!rt)
                goto out;
        net = dev_net(rt->dst.dev);

        /*
         *      Find the original header. It is expected to be valid, of course.
         *      Check this, icmp_send is called from the most obscure devices
         *      sometimes.
         */
        iph = ip_hdr(skb_in);

The crash occurs because the rt->dst.dev is NULL.  The crash occurs at
icmp_send+95.  I will be happy to furnish the dump for further
inspection upon request.

0xffffffff81541e50 <icmp_send>: push   %rbp
0xffffffff81541e51 <icmp_send+1>:       mov    %rsp,%rbp
0xffffffff81541e54 <icmp_send+4>:       sub    $0x190,%rsp
0xffffffff81541e5b <icmp_send+11>:      mov    %rbx,-0x28(%rbp)
0xffffffff81541e5f <icmp_send+15>:      mov    %r12,-0x20(%rbp)
0xffffffff81541e63 <icmp_send+19>:      mov    %r13,-0x18(%rbp)
0xffffffff81541e67 <icmp_send+23>:      mov    %r14,-0x10(%rbp)
0xffffffff81541e6b <icmp_send+27>:      mov    %r15,-0x8(%rbp)
0xffffffff81541e6f <icmp_send+31>:      nopl   0x0(%rax,%rax,1)
0xffffffff81541e74 <icmp_send+36>:      mov    %gs:0x28,%rax
0xffffffff81541e7d <icmp_send+45>:      mov    %rax,-0x38(%rbp)
0xffffffff81541e81 <icmp_send+49>:      xor    %eax,%eax
0xffffffff81541e83 <icmp_send+51>:      mov    %edx,%r15d
0xffffffff81541e86 <icmp_send+54>:      mov    0x58(%rdi),%rdx
0xffffffff81541e8a <icmp_send+58>:      mov    %rdi,%rbx
0xffffffff81541e8d <icmp_send+61>:      mov    %esi,%r12d
0xffffffff81541e90 <icmp_send+64>:      mov    %ecx,%r14d
0xffffffff81541e93 <icmp_send+67>:      and    $0xfffffffffffffffe,%rdx
0xffffffff81541e97 <icmp_send+71>:      je     0xffffffff81542200 <icmp_send+944>
0xffffffff81541e9d <icmp_send+77>:      mov    %rdx,-0x128(%rbp)
0xffffffff81541ea4 <icmp_send+84>:      mov    0x18(%rdx),%rax
0xffffffff81541ea8 <icmp_send+88>:      mov    0xd8(%rdi),%r13
0xffffffff81541eaf <icmp_send+95>:      mov    0x3e0(%rax),%r10
0xffffffff81541eb6 <icmp_send+102>:     mov    0xc4(%rdi),%eax
0xffffffff81541ebc <icmp_send+108>:     add    %rax,%r13


Here is the dmesg:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.38-8ec95-server (root@boudreau) (gcc version 4.4.3 (Ubuntu 4.4.3-4ubuntu5) ) #42 SMP Wed Nov 30 17:23:06 PST 2011 (Ubuntu 2.6.38-8ec95.42-server 2.6.38.2)
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-2.6.38-8ec95-server root=UUID=76c006c2-9fca-4474-ab11-161a4615e508 ro crashkernel=384M-2G:64M,2G-:128M quiet
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000cf379000 (usable)
[    0.000000]  BIOS-e820: 00000000cf379000 - 00000000cf38f000 (reserved)
[    0.000000]  BIOS-e820: 00000000cf38f000 - 00000000cf3ce000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cf3ce000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fe000000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 00000001b0000000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.6 present.
[    0.000000] DMI: Dell Inc. PowerEdge R410/01V648, BIOS 1.8.2 08/19/2011
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x1b0000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-C7FFF write-protect
[    0.000000]   C8000-CFFFF write-back
[    0.000000]   D0000-D3FFF write-protect
[    0.000000]   D4000-EBFFF uncachable
[    0.000000]   EC000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FF80000000 write-back
[    0.000000]   1 base 0080000000 mask FFC0000000 write-back
[    0.000000]   2 base 00C0000000 mask FFF0000000 write-back
[    0.000000]   3 base 0100000000 mask FF80000000 write-back
[    0.000000]   4 base 0180000000 mask FFE0000000 write-back
[    0.000000]   5 base 01A0000000 mask FFF0000000 write-back
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820 update range: 00000000d0000000 - 0000000100000000 (usable) ==> (reserved)
[    0.000000] last_pfn = 0xcf379 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [ffff8800000fe710] fe710
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: 0000000000000000-00000000cf379000
[    0.000000]  0000000000 - 00c0000000 page 1G
[    0.000000]  00c0000000 - 00cf200000 page 2M
[    0.000000]  00cf200000 - 00cf379000 page 4k
[    0.000000] kernel direct mapping tables up to cf379000 @ 1fffd000-20000000
[    0.000000] init_memory_mapping: 0000000100000000-00000001b0000000
[    0.000000]  0100000000 - 0180000000 page 1G
[    0.000000]  0180000000 - 01b0000000 page 2M
[    0.000000] kernel direct mapping tables up to 1b0000000 @ cf377000-cf379000
[    0.000000] RAMDISK: 37703000 - 37ff0000
[    0.000000] Reserving 128MB of memory at 752MB for crashkernel (System RAM: 6912MB)
[    0.000000] ACPI: RSDP 00000000000f1090 00024 (v02 DELL  )
[    0.000000] ACPI: XSDT 00000000000f1194 0009C (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: FACP 00000000cf3b3f9c 000F4 (v03 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: DSDT 00000000cf38f000 03B51 (v01 DELL   PE_SC3   00000001 INTL 20050624)
[    0.000000] ACPI: FACS 00000000cf3b6000 00040
[    0.000000] ACPI: APIC 00000000cf3b3478 0015E (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: SPCR 00000000cf3b35d8 00050 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: HPET 00000000cf3b362c 00038 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: DM__ 00000000cf3b3668 001C0 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: MCFG 00000000cf3b38c4 0003C (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: WD__ 00000000cf3b3904 00134 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: SLIC 00000000cf3b3a3c 00024 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: ERST 00000000cf392cd4 00270 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: HEST 00000000cf392f44 003A8 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: BERT 00000000cf392b54 00030 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: EINJ 00000000cf392b84 00150 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: SRAT 00000000cf3b3bc0 00370 (v01 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: TCPA 00000000cf3b3f34 00064 (v02 DELL   PE_SC3   00000001 DELL 00000001)
[    0.000000] ACPI: SSDT 00000000cf3b7000 06C0C (v01  INTEL PPM RCM  80000001 INTL 20061109)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x00 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x02 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x04 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x30 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x10 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x32 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x12 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x14 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x01 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x03 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x05 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x31 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x11 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x33 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x13 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x15 -> Node 1
[    0.000000] SRAT: Node 1 PXM 2 0-c0000000
[    0.000000] SRAT: Node 0 PXM 1 c0000000-d0000000
[    0.000000] SRAT: Node 0 PXM 1 100000000-1b0000000
[    0.000000] SRAT: Node 0 [c0000000,d0000000) + [100000000,1b0000000) -> [c0000000,1b0000000)
[    0.000000] NUMA: Using 30 for the hash shift.
[    0.000000] Initmem setup node 0 00000000c0000000-00000001b0000000
[    0.000000]   NODE_DATA [00000001afffb000 - 00000001afffffff]
[    0.000000] Initmem setup node 1 0000000000000000-00000000c0000000
[    0.000000]   NODE_DATA [00000000bfffb000 - 00000000bfffffff]
[    0.000000]  [ffffea0000000000-ffffea00029fffff] PMD -> [ffff8800bc600000-ffff8800beffffff] on node 1
[    0.000000]  [ffffea0002a00000-ffffea0005ffffff] PMD -> [ffff8801ace00000-ffff8801af9fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x001b0000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[4] active PFN ranges
[    0.000000]     1: 0x00000010 -> 0x000000a0
[    0.000000]     1: 0x00000100 -> 0x000c0000
[    0.000000]     0: 0x000c0000 -> 0x000cf379
[    0.000000]     0: 0x00100000 -> 0x001b0000
[    0.000000] On node 0 totalpages: 783225
[    0.000000]   DMA32 zone: 3584 pages used for memmap
[    0.000000]   DMA32 zone: 58745 pages, LIFO batch:15
[    0.000000]   Normal zone: 9856 pages used for memmap
[    0.000000]   Normal zone: 711040 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 786320
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 8 pages reserved
[    0.000000]   DMA zone: 3920 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 10696 pages used for memmap
[    0.000000]   DMA32 zone: 771640 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x20] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x22] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x24] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x30] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x32] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x34] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x21] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x23] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x25] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x31] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x11] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x33] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x13] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x35] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x15] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec80000] gsi_base[32])
[    0.000000] IOAPIC[1]: apic_id 1, version 32, address 0xfec80000, GSI 32-55
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] SMP: Allowing 32 CPUs, 8 hotplug CPUs
[    0.000000] nr_irqs_gsi: 72
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 00000000cf379000 - 00000000cf38f000
[    0.000000] PM: Registered nosave memory: 00000000cf38f000 - 00000000cf3ce000
[    0.000000] PM: Registered nosave memory: 00000000cf3ce000 - 00000000d0000000
[    0.000000] PM: Registered nosave memory: 00000000d0000000 - 00000000e0000000
[    0.000000] PM: Registered nosave memory: 00000000e0000000 - 00000000f0000000
[    0.000000] PM: Registered nosave memory: 00000000f0000000 - 00000000fe000000
[    0.000000] PM: Registered nosave memory: 00000000fe000000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at d0000000 (gap: d0000000:10000000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:32 nr_node_ids:2
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff8800bfc00000 s84352 r8192 d22144 u131072
[    0.000000] pcpu-alloc: s84352 r8192 d22144 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 02 04 06 08 10 12 14 16 18 20 22 24 26 28 30 
[    0.000000] pcpu-alloc: [1] 01 03 05 07 09 11 13 15 17 19 21 23 25 27 29 31 
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  Total pages: 1545345
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-2.6.38-8ec95-server root=UUID=76c006c2-9fca-4474-ab11-161a4615e508 ro crashkernel=384M-2G:64M,2G-:128M quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 5966492k/7077888k available (6013k kernel code, 799708k absent, 311688k reserved, 5042k data, 888k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=32, Nodes=2
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000]  RCU-based detection of stalled CPUs is disabled.
[    0.000000] NR_IRQS:16640 nr_irqs:1480 16
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 62914560 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.010000] Detected 2660.096 MHz processor.
[    0.000009] Calibrating delay loop (skipped), value calculated using timer frequency.. 5320.19 BogoMIPS (lpj=26600960)
[    0.000012] pid_max: default: 32768 minimum: 301
[    0.000044] Security Framework initialized
[    0.000056] AppArmor: AppArmor initialized
[    0.000057] Yama: becoming mindful.
[    0.000622] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.002198] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.002866] Mount-cache hash table entries: 256
[    0.003027] Initializing cgroup subsys ns
[    0.003030] ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
[    0.003032] Initializing cgroup subsys cpuacct
[    0.003037] Initializing cgroup subsys memory
[    0.003057] Initializing cgroup subsys devices
[    0.003059] Initializing cgroup subsys freezer
[    0.003060] Initializing cgroup subsys net_cls
[    0.003062] Initializing cgroup subsys blkio
[    0.003094] CPU: Physical Processor ID: 1
[    0.003095] CPU: Processor Core ID: 0
[    0.003100] mce: CPU supports 9 MCE banks
[    0.003109] CPU0: Thermal monitoring enabled (TM1)
[    0.003116] using mwait in idle threads.
[    0.004884] ACPI: Core revision 20110112
[    0.006687] ftrace: allocating 24023 entries in 95 pages
[    0.012861] Setting APIC routing to physical flat
[    0.013283] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.113042] CPU0: Intel(R) Xeon(R) CPU           X5650  @ 2.67GHz stepping 02
[    0.228452] Performance Events: PEBS fmt1+, Westmere events, Intel PMU driver.
[    0.228457] ... version:                3
[    0.228458] ... bit width:              48
[    0.228459] ... generic registers:      4
[    0.228460] ... value mask:             0000ffffffffffff
[    0.228461] ... max period:             000000007fffffff
[    0.228462] ... fixed-purpose events:   3
[    0.228463] ... event mask:             000000070000000f
[    0.228721] Booting Node   1, Processors  #1 Ok.
[    0.408198] Booting Node   0, Processors  #2 Ok.
[    0.587733] Booting Node   1, Processors  #3 Ok.
[    0.767213] Booting Node   0, Processors  #4 Ok.
[    0.946846] Booting Node   1, Processors  #5 Ok.
[    1.126313] Booting Node   0, Processors  #6 Ok.
[    1.305903] Booting Node   1, Processors  #7 Ok.
[    1.485484] Booting Node   0, Processors  #8 Ok.
[    1.665014] Booting Node   1, Processors  #9 Ok.
[    1.844572] Booting Node   0, Processors  #10 Ok.
[    2.024105] Booting Node   1, Processors  #11 Ok.
[    2.203582] Booting Node   0, Processors  #12 Ok.
[    2.383245] Booting Node   1, Processors  #13 Ok.
[    2.562728] Booting Node   0, Processors  #14 Ok.
[    2.742268] Booting Node   1, Processors  #15 Ok.
[    2.921850] Booting Node   0, Processors  #16 Ok.
[    3.101446] Booting Node   1, Processors  #17 Ok.
[    3.280939] Booting Node   0, Processors  #18 Ok.
[    3.460470] Booting Node   1, Processors  #19 Ok.
[    3.640060] Booting Node   0, Processors  #20 Ok.
[    3.819608] Booting Node   1, Processors  #21 Ok.
[    3.999089] Booting Node   0, Processors  #22 Ok.
[    4.178647] Booting Node   1, Processors  #23
[    4.358178] Brought up 24 CPUs
[    4.358180] Total of 24 processors activated (127681.05 BogoMIPS).
[    4.378980] devtmpfs: initialized
[    4.382662] print_constraints: dummy: 
[    4.382687] Time: 18:15:06  Date: 12/06/11
[    4.382732] NET: Registered protocol family 16
[    4.382839] Trying to unpack rootfs image as initramfs...
[    4.382859] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    4.382862] ACPI: bus type pci registered
[    4.382949] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    4.382953] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    4.410763] PCI: Using configuration type 1 for base access
[    4.412101] bio: create slab <bio-0> at 0
[    4.413180] ACPI: EC: Look up EC in DSDT
[    4.414535] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    4.418222] ACPI: Interpreter enabled
[    4.418226] ACPI: (supports S0 S4 S5)
[    4.418240] ACPI: Using IOAPIC for interrupt routing
[    4.422476] ACPI: No dock devices found.
[    4.422591] HEST: Table parsing has been initialized.
[    4.422595] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    4.422835] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    4.423039] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    4.423043] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    4.423045] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    4.423048] pci_root PNP0A08:00: host bridge window [mem 0xd0000000-0xfdffffff]
[    4.423051] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed44fff]
[    4.423068] pci 0000:00:00.0: [8086:3403] type 0 class 0x000600
[    4.423113] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    4.423117] pci 0000:00:00.0: PME# disabled
[    4.423138] pci 0000:00:01.0: [8086:3408] type 1 class 0x000604
[    4.423180] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    4.423183] pci 0000:00:01.0: PME# disabled
[    4.423204] pci 0000:00:03.0: [8086:340a] type 1 class 0x000604
[    4.423245] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    4.423249] pci 0000:00:03.0: PME# disabled
[    4.423271] pci 0000:00:07.0: [8086:340e] type 1 class 0x000604
[    4.423313] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    4.423317] pci 0000:00:07.0: PME# disabled
[    4.423342] pci 0000:00:14.0: [8086:342e] type 0 class 0x000800
[    4.423400] pci 0000:00:14.1: [8086:3422] type 0 class 0x000800
[    4.423455] pci 0000:00:14.2: [8086:3423] type 0 class 0x000800
[    4.423520] pci 0000:00:1a.0: [8086:3a37] type 0 class 0x000c03
[    4.423561] pci 0000:00:1a.0: reg 20: [io  0xcc40-0xcc5f]
[    4.423607] pci 0000:00:1a.1: [8086:3a38] type 0 class 0x000c03
[    4.423649] pci 0000:00:1a.1: reg 20: [io  0xcc60-0xcc7f]
[    4.423701] pci 0000:00:1a.7: [8086:3a3c] type 0 class 0x000c03
[    4.423722] pci 0000:00:1a.7: reg 10: [mem 0xdf0fe000-0xdf0fe3ff]
[    4.423793] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    4.423798] pci 0000:00:1a.7: PME# disabled
[    4.423819] pci 0000:00:1d.0: [8086:3a34] type 0 class 0x000c03
[    4.423860] pci 0000:00:1d.0: reg 20: [io  0xcc80-0xcc9f]
[    4.423905] pci 0000:00:1d.1: [8086:3a35] type 0 class 0x000c03
[    4.423946] pci 0000:00:1d.1: reg 20: [io  0xcca0-0xccbf]
[    4.423989] pci 0000:00:1d.2: [8086:3a36] type 0 class 0x000c03
[    4.424030] pci 0000:00:1d.2: reg 20: [io  0xccc0-0xccdf]
[    4.424073] pci 0000:00:1d.3: [8086:3a39] type 0 class 0x000c03
[    4.424114] pci 0000:00:1d.3: reg 20: [io  0xcce0-0xccff]
[    4.424165] pci 0000:00:1d.7: [8086:3a3a] type 0 class 0x000c03
[    4.424186] pci 0000:00:1d.7: reg 10: [mem 0xdf0ff000-0xdf0ff3ff]
[    4.424256] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    4.424261] pci 0000:00:1d.7: PME# disabled
[    4.424280] pci 0000:00:1e.0: [8086:244e] type 1 class 0x000604
[    4.424336] pci 0000:00:1f.0: [8086:3a16] type 0 class 0x000601
[    4.424416] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0c00 (mask 007f)
[    4.424420] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 000f)
[    4.424424] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 00e0 (mask 000f)
[    4.424460] pci 0000:00:1f.2: [8086:3a20] type 0 class 0x000101
[    4.424475] pci 0000:00:1f.2: reg 10: [io  0xc8e0-0xc8e7]
[    4.424483] pci 0000:00:1f.2: reg 14: [io  0xc8d0-0xc8d3]
[    4.424491] pci 0000:00:1f.2: reg 18: [io  0xc8e8-0xc8ef]
[    4.424499] pci 0000:00:1f.2: reg 1c: [io  0xc8d4-0xc8d7]
[    4.424507] pci 0000:00:1f.2: reg 20: [io  0xcc00-0xcc0f]
[    4.424516] pci 0000:00:1f.2: reg 24: [io  0xcc10-0xcc1f]
[    4.424557] pci 0000:00:1f.5: [8086:3a26] type 0 class 0x000101
[    4.424573] pci 0000:00:1f.5: reg 10: [io  0xc8f0-0xc8f7]
[    4.424581] pci 0000:00:1f.5: reg 14: [io  0xc8d8-0xc8db]
[    4.424589] pci 0000:00:1f.5: reg 18: [io  0xc8f8-0xc8ff]
[    4.424597] pci 0000:00:1f.5: reg 1c: [io  0xc8dc-0xc8df]
[    4.424605] pci 0000:00:1f.5: reg 20: [io  0xcc20-0xcc2f]
[    4.424613] pci 0000:00:1f.5: reg 24: [io  0xcc30-0xcc3f]
[    4.424693] pci 0000:01:00.0: [14e4:163b] type 0 class 0x000200
[    4.424709] pci 0000:01:00.0: reg 10: [mem 0xd8000000-0xd9ffffff 64bit]
[    4.424772] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
[    4.424776] pci 0000:01:00.0: PME# disabled
[    4.424805] pci 0000:01:00.1: [14e4:163b] type 0 class 0x000200
[    4.424821] pci 0000:01:00.1: reg 10: [mem 0xda000000-0xdbffffff 64bit]
[    4.424884] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
[    4.424888] pci 0000:01:00.1: PME# disabled
[    4.424913] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    4.424917] pci 0000:00:01.0:   bridge window [io  0xf000-0x0000] (disabled)
[    4.424921] pci 0000:00:01.0:   bridge window [mem 0xd8000000-0xdbffffff]
[    4.424926] pci 0000:00:01.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    4.424969] pci 0000:02:00.0: [1000:0058] type 0 class 0x000100
[    4.424981] pci 0000:02:00.0: reg 10: [io  0xfc00-0xfcff]
[    4.424993] pci 0000:02:00.0: reg 14: [mem 0xdf2ec000-0xdf2effff 64bit]
[    4.425006] pci 0000:02:00.0: reg 1c: [mem 0xdf2f0000-0xdf2fffff 64bit]
[    4.425021] pci 0000:02:00.0: reg 30: [mem 0xdf100000-0xdf1fffff pref]
[    4.425043] pci 0000:02:00.0: supports D1 D2
[    4.425060] pci 0000:00:03.0: PCI bridge to [bus 02-02]
[    4.425064] pci 0000:00:03.0:   bridge window [io  0xf000-0xffff]
[    4.425067] pci 0000:00:03.0:   bridge window [mem 0xdf100000-0xdf2fffff]
[    4.425073] pci 0000:00:03.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    4.425116] pci 0000:03:00.0: [111d:8018] type 1 class 0x000604
[    4.425173] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    4.425178] pci 0000:03:00.0: PME# disabled
[    4.425196] pci 0000:00:07.0: PCI bridge to [bus 03-06]
[    4.425200] pci 0000:00:07.0:   bridge window [io  0xd000-0xefff]
[    4.425204] pci 0000:00:07.0:   bridge window [mem 0xdd000000-0xdeffffff]
[    4.425209] pci 0000:00:07.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    4.425256] pci 0000:04:02.0: [111d:8018] type 1 class 0x000604
[    4.425315] pci 0000:04:02.0: PME# supported from D0 D3hot D3cold
[    4.425319] pci 0000:04:02.0: PME# disabled
[    4.425346] pci 0000:04:04.0: [111d:8018] type 1 class 0x000604
[    4.425406] pci 0000:04:04.0: PME# supported from D0 D3hot D3cold
[    4.425411] pci 0000:04:04.0: PME# disabled
[    4.425450] pci 0000:03:00.0: PCI bridge to [bus 04-06]
[    4.425458] pci 0000:03:00.0:   bridge window [io  0xd000-0xefff]
[    4.425463] pci 0000:03:00.0:   bridge window [mem 0xdd000000-0xdeffffff]
[    4.425470] pci 0000:03:00.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    4.425530] pci 0000:05:00.0: [8086:10e8] type 0 class 0x000200
[    4.425547] pci 0000:05:00.0: reg 10: [mem 0xde7c0000-0xde7dffff]
[    4.425559] pci 0000:05:00.0: reg 14: [mem 0xde800000-0xdebfffff]
[    4.425571] pci 0000:05:00.0: reg 18: [io  0xecc0-0xecdf]
[    4.425583] pci 0000:05:00.0: reg 1c: [mem 0xde7b8000-0xde7bbfff]
[    4.425615] pci 0000:05:00.0: reg 30: [mem 0xde000000-0xde3fffff pref]
[    4.425653] pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
[    4.425658] pci 0000:05:00.0: PME# disabled
[    4.425707] pci 0000:05:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.425732] pci 0000:05:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.425766] pci 0000:05:00.1: [8086:10e8] type 0 class 0x000200
[    4.425782] pci 0000:05:00.1: reg 10: [mem 0xde7e0000-0xde7fffff]
[    4.425795] pci 0000:05:00.1: reg 14: [mem 0xdec00000-0xdeffffff]
[    4.425807] pci 0000:05:00.1: reg 18: [io  0xece0-0xecff]
[    4.425819] pci 0000:05:00.1: reg 1c: [mem 0xde7bc000-0xde7bffff]
[    4.425850] pci 0000:05:00.1: reg 30: [mem 0xde000000-0xde3fffff pref]
[    4.425888] pci 0000:05:00.1: PME# supported from D0 D3hot D3cold
[    4.425893] pci 0000:05:00.1: PME# disabled
[    4.425936] pci 0000:05:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.425961] pci 0000:05:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.425994] pci 0000:04:02.0: PCI bridge to [bus 05-05]
[    4.426001] pci 0000:04:02.0:   bridge window [io  0xe000-0xefff]
[    4.426006] pci 0000:04:02.0:   bridge window [mem 0xde000000-0xdeffffff]
[    4.426013] pci 0000:04:02.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    4.426075] pci 0000:06:00.0: [8086:10e8] type 0 class 0x000200
[    4.426092] pci 0000:06:00.0: reg 10: [mem 0xdd7c0000-0xdd7dffff]
[    4.426104] pci 0000:06:00.0: reg 14: [mem 0xdd800000-0xddbfffff]
[    4.426117] pci 0000:06:00.0: reg 18: [io  0xdcc0-0xdcdf]
[    4.426129] pci 0000:06:00.0: reg 1c: [mem 0xdd7b8000-0xdd7bbfff]
[    4.426160] pci 0000:06:00.0: reg 30: [mem 0xdd000000-0xdd3fffff pref]
[    4.426199] pci 0000:06:00.0: PME# supported from D0 D3hot
[    4.426204] pci 0000:06:00.0: PME# disabled
[    4.426252] pci 0000:06:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.426277] pci 0000:06:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.426313] pci 0000:06:00.1: [8086:10e8] type 0 class 0x000200
[    4.426329] pci 0000:06:00.1: reg 10: [mem 0xdd7e0000-0xdd7fffff]
[    4.426342] pci 0000:06:00.1: reg 14: [mem 0xddc00000-0xddffffff]
[    4.426354] pci 0000:06:00.1: reg 18: [io  0xdce0-0xdcff]
[    4.426366] pci 0000:06:00.1: reg 1c: [mem 0xdd7bc000-0xdd7bffff]
[    4.426397] pci 0000:06:00.1: reg 30: [mem 0xdd000000-0xdd3fffff pref]
[    4.426436] pci 0000:06:00.1: PME# supported from D0 D3hot
[    4.426441] pci 0000:06:00.1: PME# disabled
[    4.426485] pci 0000:06:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.426509] pci 0000:06:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.426542] pci 0000:04:04.0: PCI bridge to [bus 06-06]
[    4.426549] pci 0000:04:04.0:   bridge window [io  0xd000-0xdfff]
[    4.426554] pci 0000:04:04.0:   bridge window [mem 0xdd000000-0xddffffff]
[    4.426561] pci 0000:04:04.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    4.426614] pci 0000:07:03.0: [102b:0532] type 0 class 0x000300
[    4.426631] pci 0000:07:03.0: reg 10: [mem 0xd7800000-0xd7ffffff pref]
[    4.426641] pci 0000:07:03.0: reg 14: [mem 0xdc7fc000-0xdc7fffff]
[    4.426651] pci 0000:07:03.0: reg 18: [mem 0xdc800000-0xdcffffff]
[    4.426683] pci 0000:07:03.0: reg 30: [mem 0x00000000-0x0000ffff pref]
[    4.426740] pci 0000:00:1e.0: PCI bridge to [bus 07-07] (subtractive decode)
[    4.426744] pci 0000:00:1e.0:   bridge window [io  0xf000-0x0000] (disabled)
[    4.426749] pci 0000:00:1e.0:   bridge window [mem 0xdc000000-0xdcffffff]
[    4.426755] pci 0000:00:1e.0:   bridge window [mem 0xd7800000-0xd7ffffff 64bit pref]
[    4.426758] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    4.426762] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    4.426764] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    4.426768] pci 0000:00:1e.0:   bridge window [mem 0xd0000000-0xfdffffff] (subtractive decode)
[    4.426771] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfed44fff] (subtractive decode)
[    4.426788] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    4.427225] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
[    4.427296] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
[    4.427370] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX7._PRT]
[    4.427450] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.COMP._PRT]
[    4.430296] ACPI: PCI Interrupt Link [LK00] (IRQs 3 4 5 6 7 10 11 14 *15)
[    4.430362] ACPI: PCI Interrupt Link [LK01] (IRQs 3 4 5 6 7 10 11 *14 15)
[    4.430424] ACPI: PCI Interrupt Link [LK02] (IRQs 3 4 5 6 7 10 *11 14 15)
[    4.430492] ACPI: PCI Interrupt Link [LK03] (IRQs 3 4 5 6 7 *10 11 14 15)
[    4.430557] ACPI: PCI Interrupt Link [LK04] (IRQs 3 4 *5 6 7 10 11 14 15)
[    4.430619] ACPI: PCI Interrupt Link [LK05] (IRQs 3 4 5 *6 7 10 11 14 15)
[    4.430682] ACPI: PCI Interrupt Link [LK06] (IRQs 3 4 5 6 7 10 *11 14 15)
[    4.430747] ACPI: PCI Interrupt Link [LK07] (IRQs 3 4 5 6 7 10 11 *14 15)
[    4.430871] vgaarb: device added: PCI:0000:07:03.0,decodes=io+mem,owns=io+mem,locks=none
[    4.430874] vgaarb: loaded
[    4.431056] SCSI subsystem initialized
[    4.431115] libata version 3.00 loaded.
[    4.431161] usbcore: registered new interface driver usbfs
[    4.431172] usbcore: registered new interface driver hub
[    4.431202] usbcore: registered new device driver usb
[    4.431314] wmi: Mapper loaded
[    4.431316] PCI: Using ACPI for IRQ routing
[    4.431319] PCI: pci_cache_line_size set to 64 bytes
[    4.431415] reserve RAM buffer: 00000000cf379000 - 00000000cfffffff 
[    4.431526] NetLabel: Initializing
[    4.431528] NetLabel:  domain hash size = 128
[    4.431529] NetLabel:  protocols = UNLABELED CIPSOv4
[    4.431543] NetLabel:  unlabeled traffic allowed by default
[    4.431585] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    4.431590] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
[    4.433607] Switching to clocksource hpet
[    4.437864] Switched to NOHz mode on CPU #0
[    4.437898] Switched to NOHz mode on CPU #22
[    4.437902] Switched to NOHz mode on CPU #14
[    4.437918] Switched to NOHz mode on CPU #18
[    4.437922] Switched to NOHz mode on CPU #11
[    4.437926] Switched to NOHz mode on CPU #6
[    4.437933] Switched to NOHz mode on CPU #10
[    4.437935] Switched to NOHz mode on CPU #5
[    4.437938] Switched to NOHz mode on CPU #3
[    4.437942] Switched to NOHz mode on CPU #8
[    4.437944] Switched to NOHz mode on CPU #2
[    4.437947] Switched to NOHz mode on CPU #21
[    4.437952] Switched to NOHz mode on CPU #20
[    4.437960] Switched to NOHz mode on CPU #4
[    4.437966] Switched to NOHz mode on CPU #13
[    4.437971] Switched to NOHz mode on CPU #12
[    4.437983] Switched to NOHz mode on CPU #17
[    4.437987] Switched to NOHz mode on CPU #16
[    4.437989] Switched to NOHz mode on CPU #23
[    4.437994] Switched to NOHz mode on CPU #15
[    4.438003] Switched to NOHz mode on CPU #9
[    4.438007] Switched to NOHz mode on CPU #19
[    4.438010] Switched to NOHz mode on CPU #1
[    4.438014] Switched to NOHz mode on CPU #7
[    4.441892] AppArmor: AppArmor Filesystem Enabled
[    4.441922] pnp: PnP ACPI init
[    4.441941] ACPI: bus type pnp registered
[    4.442110] pnp 00:00: [bus 00-ff]
[    4.442113] pnp 00:00: [io  0x0cf8-0x0cff]
[    4.442116] pnp 00:00: [io  0x0000-0x0cf7 window]
[    4.442119] pnp 00:00: [io  0x0d00-0xffff window]
[    4.442122] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    4.442125] pnp 00:00: [mem 0xd0000000-0xfdffffff window]
[    4.442127] pnp 00:00: [mem 0xfed40000-0xfed44fff window]
[    4.442195] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    4.442245] pnp 00:01: [io  0x0080-0x009f]
[    4.442248] pnp 00:01: [io  0x0000-0x001f]
[    4.442250] pnp 00:01: [io  0x00c0-0x00df]
[    4.442253] pnp 00:01: [dma 4]
[    4.442290] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    4.442315] pnp 00:02: [io  0x00f0-0x00ff]
[    4.442325] pnp 00:02: [irq 13]
[    4.442362] pnp 00:02: Plug and Play ACPI device, IDs PNP0c04 (active)
[    4.442393] pnp 00:03: [io  0x0061]
[    4.442469] system 00:03: Plug and Play ACPI device, IDs PNP0c01 (active)
[    4.442495] pnp 00:04: [io  0x0070-0x007f]
[    4.442502] pnp 00:04: [irq 8]
[    4.442540] pnp 00:04: Plug and Play ACPI device, IDs PNP0b00 (active)
[    4.442741] pnp 00:05: [io  0x03f8-0x03ff]
[    4.442748] pnp 00:05: [irq 4]
[    4.442879] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    4.443073] pnp 00:06: [io  0x02f8-0x02ff]
[    4.443080] pnp 00:06: [irq 3]
[    4.443207] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    4.444236] pnp 00:07: [io  0x0800-0x087f]
[    4.444239] pnp 00:07: [io  0x00e0-0x00e7]
[    4.444241] pnp 00:07: [io  0x0880-0x08ff]
[    4.444243] pnp 00:07: [io  0x0900-0x091f]
[    4.444245] pnp 00:07: [io  0x0920-0x0923]
[    4.444248] pnp 00:07: [io  0x0924]
[    4.444250] pnp 00:07: [io  0x0c00-0x0c7f]
[    4.444252] pnp 00:07: [io  0x0ca0-0x0ca7]
[    4.444254] pnp 00:07: [io  0x0ca9-0x0cab]
[    4.444256] pnp 00:07: [io  0x0cad-0x0caf]
[    4.444259] pnp 00:07: [io  0x0060]
[    4.444261] pnp 00:07: [io  0x0064]
[    4.444347] system 00:07: [io  0x0800-0x087f] has been reserved
[    4.444350] system 00:07: [io  0x0880-0x08ff] has been reserved
[    4.444353] system 00:07: [io  0x0900-0x091f] has been reserved
[    4.444356] system 00:07: [io  0x0920-0x0923] has been reserved
[    4.444359] system 00:07: [io  0x0924] has been reserved
[    4.444362] system 00:07: [io  0x0c00-0x0c7f] has been reserved
[    4.444365] system 00:07: [io  0x0ca0-0x0ca7] has been reserved
[    4.444369] system 00:07: [io  0x0ca9-0x0cab] has been reserved
[    4.444372] system 00:07: [io  0x0cad-0x0caf] has been reserved
[    4.444376] system 00:07: Plug and Play ACPI device, IDs PNP0c01 (active)
[    4.444435] pnp 00:08: [io  0x0ca8]
[    4.444438] pnp 00:08: [io  0x0cac]
[    4.444440] pnp 00:08: [irq 0 disabled]
[    4.444508] system 00:08: [io  0x0ca8] has been reserved
[    4.444511] system 00:08: [io  0x0cac] has been reserved
[    4.444515] system 00:08: Plug and Play ACPI device, IDs IPI0001 PNP0c01 (active)
[    4.445296] pnp 00:09: [mem 0xe0000000-0xefffffff]
[    4.445369] system 00:09: [mem 0xe0000000-0xefffffff] has been reserved
[    4.445374] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    4.445431] pnp 00:0a: [mem 0xfed00000-0xfed003ff]
[    4.445473] pnp 00:0a: Plug and Play ACPI device, IDs PNP0103 (active)
[    4.445491] pnp 00:0b: [mem 0xfed90000-0xfed91fff]
[    4.445568] system 00:0b: [mem 0xfed90000-0xfed91fff] has been reserved
[    4.445572] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    4.445787] pnp: PnP ACPI: found 12 devices
[    4.445789] ACPI: ACPI bus type pnp unregistered
[    4.452681] pci 0000:05:00.1: address space collision: [mem 0xde000000-0xde3fffff pref] conflicts with 0000:05:00.0 [mem 0xde000000-0xde3fffff pref]
[    4.452688] pci 0000:06:00.1: address space collision: [mem 0xdd000000-0xdd3fffff pref] conflicts with 0000:06:00.0 [mem 0xdd000000-0xdd3fffff pref]
[    4.452754] pci 0000:00:07.0: BAR 15: assigned [mem 0xd0000000-0xd07fffff pref]
[    4.452757] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    4.452760] pci 0000:00:01.0:   bridge window [io  disabled]
[    4.452765] pci 0000:00:01.0:   bridge window [mem 0xd8000000-0xdbffffff]
[    4.452769] pci 0000:00:01.0:   bridge window [mem pref disabled]
[    4.452775] pci 0000:00:03.0: PCI bridge to [bus 02-02]
[    4.452778] pci 0000:00:03.0:   bridge window [io  0xf000-0xffff]
[    4.452783] pci 0000:00:03.0:   bridge window [mem 0xdf100000-0xdf2fffff]
[    4.452787] pci 0000:00:03.0:   bridge window [mem pref disabled]
[    4.452794] pci 0000:03:00.0: BAR 15: assigned [mem 0xd0000000-0xd07fffff pref]
[    4.452798] pci 0000:04:02.0: BAR 15: assigned [mem 0xd0000000-0xd03fffff pref]
[    4.452802] pci 0000:04:04.0: BAR 15: assigned [mem 0xd0400000-0xd07fffff pref]
[    4.452820] pci 0000:05:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.452837] pci 0000:05:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.452853] pci 0000:05:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.452870] pci 0000:05:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.452887] pci 0000:05:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.452903] pci 0000:05:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.452920] pci 0000:05:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.452936] pci 0000:05:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.452953] pci 0000:05:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.452969] pci 0000:05:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.452986] pci 0000:05:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.452989] pci 0000:05:00.1: BAR 6: assigned [mem 0xd0000000-0xd03fffff pref]
[    4.453006] pci 0000:05:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453023] pci 0000:05:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453026] pci 0000:05:00.0: BAR 7: assigned [mem 0xde400000-0xde41ffff 64bit]
[    4.453035] pci 0000:05:00.0: BAR 7: set to [mem 0xde400000-0xde41ffff 64bit] (PCI address [0xde400000-0xde41ffff])
[    4.453052] pci 0000:05:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453069] pci 0000:05:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453072] pci 0000:05:00.0: BAR 10: assigned [mem 0xde420000-0xde43ffff 64bit]
[    4.453080] pci 0000:05:00.0: BAR 10: set to [mem 0xde420000-0xde43ffff 64bit] (PCI address [0xde420000-0xde43ffff])
[    4.453098] pci 0000:05:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453114] pci 0000:05:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453118] pci 0000:05:00.1: BAR 7: assigned [mem 0xde440000-0xde45ffff 64bit]
[    4.453126] pci 0000:05:00.1: BAR 7: set to [mem 0xde440000-0xde45ffff 64bit] (PCI address [0xde440000-0xde45ffff])
[    4.453143] pci 0000:05:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453159] pci 0000:05:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453163] pci 0000:05:00.1: BAR 10: assigned [mem 0xde460000-0xde47ffff 64bit]
[    4.453171] pci 0000:05:00.1: BAR 10: set to [mem 0xde460000-0xde47ffff 64bit] (PCI address [0xde460000-0xde47ffff])
[    4.453174] pci 0000:04:02.0: PCI bridge to [bus 05-05]
[    4.453178] pci 0000:04:02.0:   bridge window [io  0xe000-0xefff]
[    4.453185] pci 0000:04:02.0:   bridge window [mem 0xde000000-0xdeffffff]
[    4.453190] pci 0000:04:02.0:   bridge window [mem 0xd0000000-0xd03fffff pref]
[    4.453213] pci 0000:06:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453229] pci 0000:06:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453246] pci 0000:06:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453263] pci 0000:06:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453279] pci 0000:06:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453296] pci 0000:06:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453312] pci 0000:06:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453329] pci 0000:06:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453346] pci 0000:06:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453362] pci 0000:06:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453379] pci 0000:06:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453382] pci 0000:06:00.1: BAR 6: assigned [mem 0xd0400000-0xd07fffff pref]
[    4.453399] pci 0000:06:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453415] pci 0000:06:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453418] pci 0000:06:00.0: BAR 7: assigned [mem 0xdd400000-0xdd41ffff 64bit]
[    4.453427] pci 0000:06:00.0: BAR 7: set to [mem 0xdd400000-0xdd41ffff 64bit] (PCI address [0xdd400000-0xdd41ffff])
[    4.453444] pci 0000:06:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453460] pci 0000:06:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453464] pci 0000:06:00.0: BAR 10: assigned [mem 0xdd420000-0xdd43ffff 64bit]
[    4.453472] pci 0000:06:00.0: BAR 10: set to [mem 0xdd420000-0xdd43ffff 64bit] (PCI address [0xdd420000-0xdd43ffff])
[    4.453489] pci 0000:06:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453506] pci 0000:06:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
[    4.453509] pci 0000:06:00.1: BAR 7: assigned [mem 0xdd440000-0xdd45ffff 64bit]
[    4.453517] pci 0000:06:00.1: BAR 7: set to [mem 0xdd440000-0xdd45ffff 64bit] (PCI address [0xdd440000-0xdd45ffff])
[    4.453534] pci 0000:06:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453551] pci 0000:06:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
[    4.453554] pci 0000:06:00.1: BAR 10: assigned [mem 0xdd460000-0xdd47ffff 64bit]
[    4.453562] pci 0000:06:00.1: BAR 10: set to [mem 0xdd460000-0xdd47ffff 64bit] (PCI address [0xdd460000-0xdd47ffff])
[    4.453566] pci 0000:04:04.0: PCI bridge to [bus 06-06]
[    4.453570] pci 0000:04:04.0:   bridge window [io  0xd000-0xdfff]
[    4.453576] pci 0000:04:04.0:   bridge window [mem 0xdd000000-0xddffffff]
[    4.453582] pci 0000:04:04.0:   bridge window [mem 0xd0400000-0xd07fffff pref]
[    4.453590] pci 0000:03:00.0: PCI bridge to [bus 04-06]
[    4.453593] pci 0000:03:00.0:   bridge window [io  0xd000-0xefff]
[    4.453600] pci 0000:03:00.0:   bridge window [mem 0xdd000000-0xdeffffff]
[    4.453606] pci 0000:03:00.0:   bridge window [mem 0xd0000000-0xd07fffff pref]
[    4.453614] pci 0000:00:07.0: PCI bridge to [bus 03-06]
[    4.453617] pci 0000:00:07.0:   bridge window [io  0xd000-0xefff]
[    4.453622] pci 0000:00:07.0:   bridge window [mem 0xdd000000-0xdeffffff]
[    4.453626] pci 0000:00:07.0:   bridge window [mem 0xd0000000-0xd07fffff pref]
[    4.453645] pci 0000:07:03.0: BAR 6: assigned [mem 0xdc000000-0xdc00ffff pref]
[    4.453648] pci 0000:00:1e.0: PCI bridge to [bus 07-07]
[    4.453650] pci 0000:00:1e.0:   bridge window [io  disabled]
[    4.453656] pci 0000:00:1e.0:   bridge window [mem 0xdc000000-0xdcffffff]
[    4.453660] pci 0000:00:1e.0:   bridge window [mem 0xd7800000-0xd7ffffff 64bit pref]
[    4.453687] pci 0000:00:01.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    4.453692] pci 0000:00:01.0: setting latency timer to 64
[    4.453699] pci 0000:00:03.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    4.453703] pci 0000:00:03.0: setting latency timer to 64
[    4.453710] pci 0000:00:07.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    4.453714] pci 0000:00:07.0: setting latency timer to 64
[    4.453722] pci 0000:03:00.0: setting latency timer to 64
[    4.453731] pci 0000:04:02.0: setting latency timer to 64
[    4.453740] pci 0000:04:04.0: setting latency timer to 64
[    4.453748] pci 0000:00:1e.0: setting latency timer to 64
[    4.453752] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    4.453755] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    4.453758] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    4.453761] pci_bus 0000:00: resource 7 [mem 0xd0000000-0xfdffffff]
[    4.453763] pci_bus 0000:00: resource 8 [mem 0xfed40000-0xfed44fff]
[    4.453766] pci_bus 0000:01: resource 1 [mem 0xd8000000-0xdbffffff]
[    4.453769] pci_bus 0000:02: resource 0 [io  0xf000-0xffff]
[    4.453772] pci_bus 0000:02: resource 1 [mem 0xdf100000-0xdf2fffff]
[    4.453775] pci_bus 0000:03: resource 0 [io  0xd000-0xefff]
[    4.453777] pci_bus 0000:03: resource 1 [mem 0xdd000000-0xdeffffff]
[    4.453780] pci_bus 0000:03: resource 2 [mem 0xd0000000-0xd07fffff pref]
[    4.453783] pci_bus 0000:04: resource 0 [io  0xd000-0xefff]
[    4.453786] pci_bus 0000:04: resource 1 [mem 0xdd000000-0xdeffffff]
[    4.453789] pci_bus 0000:04: resource 2 [mem 0xd0000000-0xd07fffff pref]
[    4.453791] pci_bus 0000:05: resource 0 [io  0xe000-0xefff]
[    4.453794] pci_bus 0000:05: resource 1 [mem 0xde000000-0xdeffffff]
[    4.453797] pci_bus 0000:05: resource 2 [mem 0xd0000000-0xd03fffff pref]
[    4.453800] pci_bus 0000:06: resource 0 [io  0xd000-0xdfff]
[    4.453802] pci_bus 0000:06: resource 1 [mem 0xdd000000-0xddffffff]
[    4.453805] pci_bus 0000:06: resource 2 [mem 0xd0400000-0xd07fffff pref]
[    4.453808] pci_bus 0000:07: resource 1 [mem 0xdc000000-0xdcffffff]
[    4.453811] pci_bus 0000:07: resource 2 [mem 0xd7800000-0xd7ffffff 64bit pref]
[    4.453814] pci_bus 0000:07: resource 4 [io  0x0000-0x0cf7]
[    4.453816] pci_bus 0000:07: resource 5 [io  0x0d00-0xffff]
[    4.453819] pci_bus 0000:07: resource 6 [mem 0x000a0000-0x000bffff]
[    4.453822] pci_bus 0000:07: resource 7 [mem 0xd0000000-0xfdffffff]
[    4.453825] pci_bus 0000:07: resource 8 [mem 0xfed40000-0xfed44fff]
[    4.453875] NET: Registered protocol family 2
[    4.454212] IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    4.455620] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    4.457676] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    4.457887] TCP: Hash tables configured (established 524288 bind 65536)
[    4.457890] TCP reno registered
[    4.457909] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    4.457968] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    4.458224] NET: Registered protocol family 1
[    4.473748] pci 0000:07:03.0: Boot video device
[    4.473753] PCI: CLS 64 bytes, default 64
[    4.473755] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    4.473758] Placing 64MB software IO TLB between ffff8800b8600000 - ffff8800bc600000
[    4.473761] software IO TLB at phys 0xb8600000 - 0xbc600000
[    4.475606] audit: initializing netlink socket (disabled)
[    4.475616] type=2000 audit(1323195306.130:1): initialized
[    4.498417] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    4.500820] VFS: Disk quotas dquot_6.5.2
[    4.500912] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    4.501784] fuse init (API version 7.16)
[    4.501903] msgmni has been set to 11653
[    4.502185] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    4.502218] io scheduler noop registered
[    4.502221] io scheduler deadline registered (default)
[    4.502276] io scheduler cfq registered
[    4.502526] pcieport 0000:03:00.0: setting latency timer to 64
[    4.502613] pcieport 0000:04:02.0: setting latency timer to 64
[    4.502684] pcieport 0000:04:02.0: irq 72 for MSI/MSI-X
[    4.502755] pcieport 0000:04:04.0: setting latency timer to 64
[    4.502814] pcieport 0000:04:04.0: irq 73 for MSI/MSI-X
[    4.502909] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    4.502938] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    4.502991] intel_idle: MWAIT substates: 0x1120
[    4.502993] intel_idle: v0.4 model 0x2C
[    4.502995] intel_idle: lapic_timer_reliable_states 0xffffffff
[    4.503266] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    4.503272] ACPI: Power Button [PWRF]
[    4.503372] ACPI: acpi_idle yielding to intel_idle
[    4.506474] ERST: Error Record Serialization Table (ERST) support is initialized.
[    4.506558] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    4.527072] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    4.546583] Freeing initrd memory: 9140k freed
[    4.693573] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    4.756111] 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    4.776739] 00:06: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    4.777116] Linux agpgart interface v0.103
[    4.778857] brd: module loaded
[    4.779645] loop: module loaded
[    4.779769] i2c-core: driver [adp5520] using legacy suspend method
[    4.779772] i2c-core: driver [adp5520] using legacy resume method
[    4.779895] ata_piix 0000:00:1f.2: version 2.13
[    4.779917] ata_piix 0000:00:1f.2: PCI INT C -> GSI 23 (level, low) -> IRQ 23
[    4.779922] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    4.932464] ata_piix 0000:00:1f.2: setting latency timer to 64
[    4.932820] scsi0 : ata_piix
[    4.932932] scsi1 : ata_piix
[    4.932986] ata1: SATA max UDMA/133 cmd 0xc8e0 ctl 0xc8d0 bmdma 0xcc00 irq 23
[    4.932991] ata2: SATA max UDMA/133 cmd 0xc8e8 ctl 0xc8d4 bmdma 0xcc08 irq 23
[    4.933018] ata_piix 0000:00:1f.5: PCI INT D -> GSI 22 (level, low) -> IRQ 22
[    4.933023] ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
[    5.092057] ata_piix 0000:00:1f.5: setting latency timer to 64
[    5.092319] scsi2 : ata_piix
[    5.092395] scsi3 : ata_piix
[    5.092446] ata3: SATA max UDMA/133 cmd 0xc8f0 ctl 0xc8d8 bmdma 0xcc20 irq 22
[    5.092451] ata4: SATA max UDMA/133 cmd 0xc8f8 ctl 0xc8dc bmdma 0xcc28 irq 22
[    5.092843] Fixed MDIO Bus: probed
[    5.092878] PPP generic driver version 2.4.2
[    5.092927] tun: Universal TUN/TAP device driver, 1.6
[    5.092930] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    5.093051] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    5.093076] ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 19 (level, low) -> IRQ 19
[    5.093113] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[    5.093117] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[    5.093171] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
[    5.093250] ehci_hcd 0000:00:1a.7: debug port 1
[    5.097115] ehci_hcd 0000:00:1a.7: cache line size of 64 is not supported
[    5.097135] ehci_hcd 0000:00:1a.7: irq 19, io mem 0xdf0fe000
[    5.112002] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[    5.112197] hub 1-0:1.0: USB hub found
[    5.112202] hub 1-0:1.0: 4 ports detected
[    5.112294] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 21 (level, low) -> IRQ 21
[    5.112310] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    5.112314] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    5.112375] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
[    5.112450] ehci_hcd 0000:00:1d.7: debug port 1
[    5.116324] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[    5.116345] ehci_hcd 0000:00:1d.7: irq 21, io mem 0xdf0ff000
[    5.131949] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    5.132100] hub 2-0:1.0: USB hub found
[    5.132104] hub 2-0:1.0: 4 ports detected
[    5.132192] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    5.132207] uhci_hcd: USB Universal Host Controller Interface driver
[    5.132277] uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    5.132284] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[    5.132288] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    5.132336] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
[    5.132402] uhci_hcd 0000:00:1a.0: irq 17, io base 0x0000cc40
[    5.132572] hub 3-0:1.0: USB hub found
[    5.132576] hub 3-0:1.0: 2 ports detected
[    5.132661] uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 18 (level, low) -> IRQ 18
[    5.132667] uhci_hcd 0000:00:1a.1: setting latency timer to 64
[    5.132671] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[    5.132718] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
[    5.132784] uhci_hcd 0000:00:1a.1: irq 18, io base 0x0000cc60
[    5.132951] hub 4-0:1.0: USB hub found
[    5.132956] hub 4-0:1.0: 2 ports detected
[    5.133032] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
[    5.133038] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    5.133042] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    5.133088] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 5
[    5.141963] uhci_hcd 0000:00:1d.0: irq 21, io base 0x0000cc80
[    5.142132] hub 5-0:1.0: USB hub found
[    5.142136] hub 5-0:1.0: 2 ports detected
[    5.142232] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 20 (level, low) -> IRQ 20
[    5.142238] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    5.142242] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    5.142290] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 6
[    5.142356] uhci_hcd 0000:00:1d.1: irq 20, io base 0x0000cca0
[    5.142523] hub 6-0:1.0: USB hub found
[    5.142528] hub 6-0:1.0: 2 ports detected
[    5.142601] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 21 (level, low) -> IRQ 21
[    5.142608] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    5.142611] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    5.142657] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 7
[    5.142714] uhci_hcd 0000:00:1d.2: irq 21, io base 0x0000ccc0
[    5.142880] hub 7-0:1.0: USB hub found
[    5.142885] hub 7-0:1.0: 2 ports detected
[    5.142960] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 20 (level, low) -> IRQ 20
[    5.142967] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    5.142970] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    5.143021] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 8
[    5.143077] uhci_hcd 0000:00:1d.3: irq 20, io base 0x0000cce0
[    5.143243] hub 8-0:1.0: USB hub found
[    5.143254] hub 8-0:1.0: 2 ports detected
[    5.143390] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    5.146098] serio: i8042 KBD port at 0x60,0x64 irq 1
[    5.146107] serio: i8042 AUX port at 0x60,0x64 irq 12
[    5.146252] mousedev: PS/2 mouse device common for all mice
[    5.146365] rtc_cmos 00:04: RTC can wake from S4
[    5.146524] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
[    5.146552] rtc0: alarms up to one day, y3k, 242 bytes nvram, hpet irqs
[    5.146713] device-mapper: uevent: version 1.0.3
[    5.146830] device-mapper: ioctl: 4.19.1-ioctl (2011-01-07) initialised: dm-devel@redhat.com
[    5.146915] device-mapper: multipath: version 1.2.0 loaded
[    5.146918] device-mapper: multipath round-robin: version 1.0.0 loaded
[    5.147797] cpuidle: using governor ladder
[    5.148942] cpuidle: using governor menu
[    5.149295] TCP cubic registered
[    5.149464] NET: Registered protocol family 10
[    5.150281] NET: Registered protocol family 17
[    5.150302] Registering the dns_resolver key type
[    5.150594] PM: Hibernation image not present or could not be loaded.
[    5.150607] registered taskstats version 1
[    5.151173]   Magic number: 7:117:291
[    5.151226] tty tty24: hash matches
[    5.152327] rtc_cmos 00:04: setting system clock to 2011-12-06 18:15:07 UTC (1323195307)
[    5.152330] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    5.152332] EDD information not available.
[    5.431277] usb 1-3: new high speed USB device using ehci_hcd and address 2
[    5.471159] Refined TSC clocksource calibration: 2659.999 MHz.
[    5.471164] Switching to clocksource tsc
[    5.581562] hub 1-3:1.0: USB hub found
[    5.581771] hub 1-3:1.0: 4 ports detected
[    5.600867] ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    5.620922] ata3.00: ATAPI: TEAC DVD-ROM DV-28SW, R.2A, max UDMA/100
[    5.660833] ata3.00: configured for UDMA/100
[    5.820303] usb 2-3: new high speed USB device using ehci_hcd and address 3
[    5.999834] ata2.00: failed to resume link (SControl 0)
[    6.159445] ata4: failed to resume link (SControl 0)
[    6.170224] ata4: SATA link down (SStatus 4 SControl 0)
[    6.249206] usb 5-2: new full speed USB device using uhci_hcd and address 2
[    6.348976] ata1.01: failed to resume link (SControl 0)
[    6.359784] ata1.00: SATA link down (SStatus 0 SControl 300)
[    6.359798] ata1.01: SATA link down (SStatus 0 SControl 0)
[    7.067173] ata2.01: failed to resume link (SControl 0)
[    7.077957] ata2.00: SATA link down (SStatus 0 SControl 0)
[    7.077971] ata2.01: SATA link down (SStatus 0 SControl 0)
[    7.087919] scsi 2:0:0:0: CD-ROM            TEAC     DVD-ROM DV-28SW  R.2A PQ: 0 ANSI: 5
[    7.100009] sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
[    7.100013] cdrom: Uniform CD-ROM driver Revision: 3.20
[    7.100145] sr 2:0:0:0: Attached scsi CD-ROM sr0
[    7.100215] sr 2:0:0:0: Attached scsi generic sg0 type 5
[    7.104816] Freeing unused kernel memory: 888k freed
[    7.105003] Write protecting the kernel read-only data: 10240k
[    7.110696] Freeing unused kernel memory: 112k freed
[    7.121056] Freeing unused kernel memory: 1436k freed
[    7.142274] udev: starting version 151
[    7.142443] udevd (144): /proc/144/oom_adj is deprecated, please use /proc/144/oom_score_adj instead.
[    7.166251] dca service started, version 1.12.1
[    7.185745] usbcore: registered new interface driver uas
[    7.191586] Intel(R) Gigabit Ethernet Network Driver - version 2.1.0-k2
[    7.191589] Copyright (c) 2007-2009 Intel Corporation.
[    7.191639] igb 0000:05:00.0: PCI INT A -> GSI 47 (level, low) -> IRQ 47
[    7.191652] igb 0000:05:00.0: setting latency timer to 64
[    7.191963] igb 0000:05:00.0: irq 74 for MSI/MSI-X
[    7.191971] igb 0000:05:00.0: irq 75 for MSI/MSI-X
[    7.191980] igb 0000:05:00.0: irq 76 for MSI/MSI-X
[    7.191988] igb 0000:05:00.0: irq 77 for MSI/MSI-X
[    7.191996] igb 0000:05:00.0: irq 78 for MSI/MSI-X
[    7.192004] igb 0000:05:00.0: irq 79 for MSI/MSI-X
[    7.192012] igb 0000:05:00.0: irq 80 for MSI/MSI-X
[    7.192020] igb 0000:05:00.0: irq 81 for MSI/MSI-X
[    7.192028] igb 0000:05:00.0: irq 82 for MSI/MSI-X
[    7.192085] igb 0000:05:00.0: 0 vfs allocated
[    7.199436] Initializing USB Mass Storage driver...
[    7.199730] scsi4 : usb-storage 2-3:1.0
[    7.200110] scsi5 : usb-storage 2-3:1.1
[    7.200302] usbcore: registered new interface driver usb-storage
[    7.200305] USB Mass Storage support registered.
[    7.210056] input: Avocent USB Composite Device-0 as /devices/pci0000:00/0000:00:1d.0/usb5/5-2/5-2:1.0/input/input1
[    7.210199] generic-usb 0003:0624:0248.0001: input,hidraw0: USB HID v1.00 Keyboard [Avocent USB Composite Device-0] on usb-0000:00:1d.0-2/input0
[    7.214005] input: Avocent USB Composite Device-0 as /devices/pci0000:00/0000:00:1d.0/usb5/5-2/5-2:1.1/input/input2
[    7.214193] generic-usb 0003:0624:0248.0002: input,hidraw1: USB HID v1.00 Mouse [Avocent USB Composite Device-0] on usb-0000:00:1d.0-2/input1
[    7.214216] usbcore: registered new interface driver usbhid
[    7.214220] usbhid: USB HID core driver
[    7.227801] Fusion MPT base driver 3.04.18
[    7.227804] Copyright (c) 1999-2008 LSI Corporation
[    7.252188] Fusion MPT SAS Host driver 3.04.18
[    7.252230] mptsas 0000:02:00.0: PCI INT A -> GSI 32 (level, low) -> IRQ 32
[    7.252426] mptbase: ioc0: Initiating bringup
[    7.437214] igb 0000:05:00.0: Intel(R) Gigabit Ethernet Network Connection
[    7.437219] igb 0000:05:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:1b:21:c9:77:10
[    7.437543] igb 0000:05:00.0: eth0: PBA No: G18771-002
[    7.437546] igb 0000:05:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    7.437574] igb 0000:05:00.1: PCI INT B -> GSI 46 (level, low) -> IRQ 46
[    7.437583] igb 0000:05:00.1: setting latency timer to 64
[    7.438948] igb 0000:05:00.1: irq 83 for MSI/MSI-X
[    7.438957] igb 0000:05:00.1: irq 84 for MSI/MSI-X
[    7.438965] igb 0000:05:00.1: irq 85 for MSI/MSI-X
[    7.438973] igb 0000:05:00.1: irq 86 for MSI/MSI-X
[    7.438981] igb 0000:05:00.1: irq 87 for MSI/MSI-X
[    7.438989] igb 0000:05:00.1: irq 88 for MSI/MSI-X
[    7.438997] igb 0000:05:00.1: irq 89 for MSI/MSI-X
[    7.439004] igb 0000:05:00.1: irq 90 for MSI/MSI-X
[    7.439012] igb 0000:05:00.1: irq 91 for MSI/MSI-X
[    7.439066] igb 0000:05:00.1: 0 vfs allocated
[    7.686588] igb 0000:05:00.1: Intel(R) Gigabit Ethernet Network Connection
[    7.686593] igb 0000:05:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:1b:21:c9:77:11
[    7.686918] igb 0000:05:00.1: eth1: PBA No: G18771-002
[    7.686921] igb 0000:05:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    7.686948] igb 0000:06:00.0: PCI INT A -> GSI 38 (level, low) -> IRQ 38
[    7.686957] igb 0000:06:00.0: setting latency timer to 64
[    7.687257] igb 0000:06:00.0: irq 92 for MSI/MSI-X
[    7.687265] igb 0000:06:00.0: irq 93 for MSI/MSI-X
[    7.687274] igb 0000:06:00.0: irq 94 for MSI/MSI-X
[    7.687282] igb 0000:06:00.0: irq 95 for MSI/MSI-X
[    7.687290] igb 0000:06:00.0: irq 96 for MSI/MSI-X
[    7.687298] igb 0000:06:00.0: irq 97 for MSI/MSI-X
[    7.687306] igb 0000:06:00.0: irq 98 for MSI/MSI-X
[    7.687317] igb 0000:06:00.0: irq 99 for MSI/MSI-X
[    7.687325] igb 0000:06:00.0: irq 100 for MSI/MSI-X
[    7.687379] igb 0000:06:00.0: 0 vfs allocated
[    7.936006] igb 0000:06:00.0: Intel(R) Gigabit Ethernet Network Connection
[    7.936011] igb 0000:06:00.0: eth2: (PCIe:2.5Gb/s:Width x4) 00:1b:21:c9:77:14
[    7.936336] igb 0000:06:00.0: eth2: PBA No: G18771-002
[    7.936339] igb 0000:06:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    7.936367] igb 0000:06:00.1: PCI INT B -> GSI 45 (level, low) -> IRQ 45
[    7.936376] igb 0000:06:00.1: setting latency timer to 64
[    7.936676] igb 0000:06:00.1: irq 101 for MSI/MSI-X
[    7.936685] igb 0000:06:00.1: irq 102 for MSI/MSI-X
[    7.936693] igb 0000:06:00.1: irq 103 for MSI/MSI-X
[    7.936701] igb 0000:06:00.1: irq 104 for MSI/MSI-X
[    7.936709] igb 0000:06:00.1: irq 105 for MSI/MSI-X
[    7.936717] igb 0000:06:00.1: irq 106 for MSI/MSI-X
[    7.936725] igb 0000:06:00.1: irq 107 for MSI/MSI-X
[    7.936734] igb 0000:06:00.1: irq 108 for MSI/MSI-X
[    7.936742] igb 0000:06:00.1: irq 109 for MSI/MSI-X
[    7.936798] igb 0000:06:00.1: 0 vfs allocated
[    8.185426] igb 0000:06:00.1: Intel(R) Gigabit Ethernet Network Connection
[    8.185431] igb 0000:06:00.1: eth3: (PCIe:2.5Gb/s:Width x4) 00:1b:21:c9:77:15
[    8.185756] igb 0000:06:00.1: eth3: PBA No: G18771-002
[    8.185759] igb 0000:06:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    8.199747] scsi 5:0:0:0: CD-ROM            iDRAC    Virtual CD       0323 PQ: 0 ANSI: 0
[    8.201390] scsi 4:0:0:0: Direct-Access     iDRAC    LCDRIVE          0323 PQ: 0 ANSI: 0 CCS
[    8.202814] sd 4:0:0:0: Attached scsi generic sg1 type 0
[    8.202955] scsi 5:0:0:1: Direct-Access     iDRAC    Virtual Floppy   0323 PQ: 0 ANSI: 0 CCS
[    8.205005] sd 4:0:0:0: [sda] Attached SCSI removable disk
[    8.310830] sr1: scsi3-mmc drive: 0x/0x cd/rw caddy
[    8.310991] sr 5:0:0:0: Attached scsi CD-ROM sr1
[    8.311098] sr 5:0:0:0: Attached scsi generic sg2 type 5
[    8.311585] sd 5:0:0:1: Attached scsi generic sg3 type 0
[    8.314018] sd 5:0:0:1: [sdb] Attached SCSI removable disk
[    8.832747] ioc0: LSISAS1068E B3: Capabilities={Initiator}
[    8.832772] mptsas 0000:02:00.0: setting latency timer to 64
[   26.213964] scsi6 : ioc0: LSISAS1068E B3, FwRev=00192f00h, Ports=1, MaxQ=266, IRQ=32
[   26.251156] mptsas: ioc0: attaching sata device: fw_channel 0, fw_id 9, phy 0, sas_addr 0x1221000000000000
[   26.254164] scsi 6:0:0:0: Direct-Access     ATA      WDC WD2502ABYS-1 3B05 PQ: 0 ANSI: 5
[   26.256186] scsi 6:0:0:0: Attached scsi generic sg4 type 0
[   26.257938] mptsas: ioc0: attaching sata device: fw_channel 0, fw_id 1, phy 1, sas_addr 0x1221000001000000
[   26.260875] scsi 6:0:1:0: Direct-Access     ATA      WDC WD2502ABYS-1 3B05 PQ: 0 ANSI: 5
[   26.262975] scsi 6:0:1:0: Attached scsi generic sg5 type 0
[   26.264753] mptsas: ioc0: attaching raid volume, channel 1, id 0
[   26.265591] scsi 6:1:0:0: Direct-Access     Dell     VIRTUAL DISK     1028 PQ: 0 ANSI: 5
[   26.273007] sd 6:1:0:0: Attached scsi generic sg6 type 0
[   26.273176] sd 6:1:0:0: [sdc] 487063552 512-byte logical blocks: (249 GB/232 GiB)
[   26.273907] sd 6:1:0:0: [sdc] Write Protect is off
[   26.273911] sd 6:1:0:0: [sdc] Mode Sense: 03 00 00 08
[   26.274392] sd 6:1:0:0: [sdc] Got wrong page
[   26.274395] sd 6:1:0:0: [sdc] Assuming drive cache: write through
[   26.275999] sd 6:1:0:0: [sdc] Got wrong page
[   26.276002] sd 6:1:0:0: [sdc] Assuming drive cache: write through
[   26.291530]  sdc: sdc1 sdc2 sdc3
[   26.294276] sd 6:1:0:0: [sdc] Got wrong page
[   26.294279] sd 6:1:0:0: [sdc] Assuming drive cache: write through
[   26.294282] sd 6:1:0:0: [sdc] Attached SCSI disk
[   26.483526] EXT4-fs (sdc3): INFO: recovery required on readonly filesystem
[   26.483530] EXT4-fs (sdc3): write access will be enabled during recovery
[   26.536450] EXT4-fs (sdc3): recovery complete
[   26.537124] EXT4-fs (sdc3): mounted filesystem with ordered data mode. Opts: (null)
[   27.938762] udev: starting version 151
[   27.940560] Adding 4882428k swap on /dev/sdc2.  Priority:-1 extents:1 across:4882428k 
[   27.956637] lp: driver loaded but no devices found
[   27.962271] bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.21 (Dec 23, 2010)
[   27.962313] bnx2 0000:01:00.0: PCI INT A -> GSI 36 (level, low) -> IRQ 36
[   27.962322] bnx2 0000:01:00.0: setting latency timer to 64
[   27.963267] ACPI Error: No handler for Region [IPMI] (ffff8801a8c29240) [IPMI] (20110112/evregion-369)
[   27.963277] ACPI Error: Region IPMI(0x7) has no handler (20110112/exfldio-292)
[   27.963286] ACPI Error: Method parse/execution failed [\_SB_.PMI0._GHL] (Node ffff8801a8c28b18), AE_NOT_EXIST (20110112/psparse-536)
[   27.963303] ACPI Error: Method parse/execution failed [\_SB_.PMI0._PMC] (Node ffff8801a8c28a78), AE_NOT_EXIST (20110112/psparse-536)
[   27.963322] ACPI Exception: AE_NOT_EXIST, Evaluating _PMC (20110112/power_meter-773)
[   27.981894] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   28.004349] EDAC MC: Ver: 2.1.0 Nov 30 2011
[   28.007943] EDAC i7core: Driver loaded.
[   28.020502] type=1400 audit(1323195330.413:2): apparmor="STATUS" operation="profile_load" name="/sbin/dhclient3" pid=588 comm="apparmor_parser"
[   28.021188] type=1400 audit(1323195330.413:3): apparmor="STATUS" operation="profile_load" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=588 comm="apparmor_parser"
[   28.021572] type=1400 audit(1323195330.413:4): apparmor="STATUS" operation="profile_load" name="/usr/lib/connman/scripts/dhclient-script" pid=588 comm="apparmor_parser"
[   28.105123] udev: renamed network interface eth2 to eth4
[   28.111062] EXT4-fs (sdc3): re-mounted. Opts: errors=remount-ro
[   28.144155] EXT4-fs (sdc1): mounted filesystem with ordered data mode. Opts: (null)
[   28.154996] udev: renamed network interface eth3 to eth5
[   28.155930] bnx2 0000:01:00.0: eth0: Broadcom NetXtreme II BCM5716 1000Base-T (C0) PCI Express found at mem d8000000, IRQ 36, node addr 78:2b:cb:51:4b:ad
[   28.155977] bnx2 0000:01:00.1: PCI INT B -> GSI 48 (level, low) -> IRQ 48
[   28.155985] bnx2 0000:01:00.1: setting latency timer to 64
[   28.240937] type=1400 audit(1323195330.633:5): apparmor="STATUS" operation="profile_load" name="/usr/sbin/tcpdump" pid=714 comm="apparmor_parser"
[   28.241249] type=1400 audit(1323195330.633:6): apparmor="STATUS" operation="profile_replace" name="/sbin/dhclient3" pid=713 comm="apparmor_parser"
[   28.241938] type=1400 audit(1323195330.633:7): apparmor="STATUS" operation="profile_replace" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=713 comm="apparmor_parser"
[   28.242325] type=1400 audit(1323195330.633:8): apparmor="STATUS" operation="profile_replace" name="/usr/lib/connman/scripts/dhclient-script" pid=713 comm="apparmor_parser"
[   28.354541] udev: renamed network interface eth0_rename to eth2
[   28.355550] bnx2 0000:01:00.1: eth1: Broadcom NetXtreme II BCM5716 1000Base-T (C0) PCI Express found at mem da000000, IRQ 48, node addr 78:2b:cb:51:4b:ae
[   28.434397] udev: renamed network interface eth1_rename to eth3
[   28.485032] bonding: Ethernet Channel Bonding Driver: v3.7.0 (June 2, 2010)
[   28.485035] bonding: Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.
[   28.491378] bonding: bond0: doing slave updates when interface is down.
[   28.491383] bonding: bond0: Adding slave eth2.
[   28.491385] bonding: bond0: master_dev is not up in bond_enslave
[   28.574733] bonding: bond0: Warning: failed to get speed and duplex from eth2, assumed to be 100Mb/sec and Full.
[   28.574746] bonding: bond0: enslaving eth2 as an active interface with an up link.
[   28.578294] bonding: bond0: doing slave updates when interface is down.
[   28.578299] bonding: bond0: Adding slave eth3.
[   28.578301] bonding: bond0: master_dev is not up in bond_enslave
[   28.661539] bonding: bond0: Warning: failed to get speed and duplex from eth3, assumed to be 100Mb/sec and Full.
[   28.661549] bonding: bond0: enslaving eth3 as an active interface with an up link.
[   28.662514] bonding: bond0: setting mode to balance-xor (2).
[   28.662556] bonding: bond0: Setting MII monitoring interval to 100.
[   28.707169] bonding: bond1 is being created...
[   28.711478] bonding: bond1: doing slave updates when interface is down.
[   28.711483] bonding: bond1: Adding slave eth4.
[   28.711485] bonding: bond1: master_dev is not up in bond_enslave
[   28.794818] bonding: bond1: Warning: failed to get speed and duplex from eth4, assumed to be 100Mb/sec and Full.
[   28.794830] bonding: bond1: enslaving eth4 as an active interface with an up link.
[   28.798780] bonding: bond1: doing slave updates when interface is down.
[   28.798785] bonding: bond1: Adding slave eth5.
[   28.798787] bonding: bond1: master_dev is not up in bond_enslave
[   28.882047] bonding: bond1: Warning: failed to get speed and duplex from eth5, assumed to be 100Mb/sec and Full.
[   28.882057] bonding: bond1: enslaving eth5 as an active interface with an up link.
[   28.883081] bonding: bond1: setting mode to balance-xor (2).
[   28.883127] bonding: bond1: Setting MII monitoring interval to 100.
[   28.974824] bonding: bond0: link status definitely down for interface eth2, disabling it
[   28.974831] bonding: bond0: now running without any active interface !
[   28.974833] bonding: bond0: link status definitely down for interface eth3, disabling it
[   28.976297] bonding: bond1: link status definitely down for interface eth4, disabling it
[   28.976301] bonding: bond1: now running without any active interface !
[   28.976304] bonding: bond1: link status definitely down for interface eth5, disabling it
[   30.668520] igb: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   30.687968] bonding: bond0: link status definitely up for interface eth2, 1000 Mbps full duplex.
[   30.687978] bonding: bond0: first active interface up!
[   30.718394] igb: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   30.787721] bonding: bond0: link status definitely up for interface eth3, 1000 Mbps full duplex.
[   30.997697] igb: eth5 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   31.037555] igb: eth4 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   31.086968] bonding: bond1: link status definitely up for interface eth4, 1000 Mbps full duplex.
[   31.086977] bonding: bond1: first active interface up!
[   31.086983] bonding: bond1: link status definitely up for interface eth5, 1000 Mbps full duplex.
[   39.086899] bond1: no IPv6 routers present
[   39.595622] bond0: no IPv6 routers present
[ 4138.605233] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[ 4138.623745] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[ 4138.625039] IPVS: Connection hash table configured (size=1048576, memory=16384Kbytes)
[ 4138.627618] IPVS: ipvs loaded.
[ 4159.433408] ip_tables: (C) 2000-2006 Netfilter Core Team
[ 4163.333618] IPVS: [wrr] scheduler registered.
[94533.680773] IPVS: WRR: no destination available: no destinations present
[94533.681949] IPVS: WRR: no destination available: no destinations present
[94533.694517] IPVS: WRR: no destination available: no destinations present
[94533.695114] IPVS: WRR: no destination available: no destinations present
[94533.697832] IPVS: WRR: no destination available: no destinations present
[94533.704426] IPVS: WRR: no destination available: no destinations present
[94533.704734] IPVS: WRR: no destination available: no destinations present
[94533.712335] IPVS: WRR: no destination available: no destinations present
[94533.713600] IPVS: WRR: no destination available: no destinations present
[94533.717609] IPVS: WRR: no destination available: no destinations present
[108055.578136] BUG: unable to handle kernel NULL pointer dereference at 00000000000003e0
[108055.578162] IP: [<ffffffff81541eaf>] icmp_send+0x5f/0x760
[108055.578182] PGD 0 
[108055.578191] Oops: 0000 [#1] SMP 
[108055.578204] last sysfs file: /sys/module/ip_tables/initstate
[108055.578219] CPU 17 
[108055.578226] Modules linked in: ip_vs_wrr iptable_mangle xt_mark ip_tables x_tables ip_vs nf_conntrack libcrc32c bonding psmouse i7core_edac edac_core joydev dcdbas serio_raw ghes power_meter bnx2 hed lp parport mptsas mptscsih mptbase scsi_transport_sas usbhid usb_storage igb hid uas dca
[108055.578365] 
[108055.578385] Pid: 0, comm: kworker/0:1 Not tainted 2.6.38-8ec95-server #42 Dell Inc. PowerEdge R410/01V648
[108055.578514] RIP: 0010:[<ffffffff81541eaf>]  [<ffffffff81541eaf>] icmp_send+0x5f/0x760
[108055.578563] RSP: 0018:ffff8800bfd03c40  EFLAGS: 00010286
[108055.578589] RAX: 0000000000000000 RBX: ffff88009bc51e00 RCX: 0000000000000000
[108055.578633] RDX: ffff88016467ca00 RSI: 000000000000000b RDI: ffff88009bc51e00
[108055.578676] RBP: ffff8800bfd03dd0 R08: ffff8800bfd0f9f0 R09: 0000000000000100
[108055.578720] R10: 0000000000000001 R11: 0000000000000010 R12: 000000000000000b
[108055.578763] R13: ffff88007113c800 R14: 0000000000000000 R15: 0000000000000001
[108055.578807] FS:  0000000000000000(0000) GS:ffff8800bfd00000(0000) knlGS:0000000000000000
[108055.578852] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[108055.578879] CR2: 00000000000003e0 CR3: 0000000001a03000 CR4: 00000000000006e0
[108055.578923] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[108055.578967] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[108055.579010] Process kworker/0:1 (pid: 0, threadinfo ffff8801a8e36000, task ffff8801a8e2db80)
[108055.579056] Stack:
[108055.579076]  0000000000000000 ffff8800bfd03c58 ffffffffa00446d4 ffff8800bfd03ca8
[108055.579129]  ffffffff810d19e0 ffff880037ab5d00 0000000000000640 00000000ffffffff
[108055.579181]  ffff8800b47e3000 ffff8800b4612680 ffff8800b47e3084 ffff8800bfd03ca8
[108055.579234] Call Trace:
[108055.579255]  <IRQ> 
[108055.579283]  [<ffffffffa00446d4>] ? igb_msix_ring+0x64/0x80 [igb]
[108055.579314]  [<ffffffff810d19e0>] ? handle_IRQ_event+0x50/0x170
[108055.579345]  [<ffffffff815d4c6e>] ? _raw_spin_lock+0xe/0x20
[108055.579372]  [<ffffffff810d40de>] ? handle_edge_irq+0xee/0x180
[108055.579402]  [<ffffffff8100ea22>] ? handle_irq+0x22/0x30
[108055.579430]  [<ffffffff8106bd78>] ? irq_exit+0x48/0x90
[108055.579457]  [<ffffffff815d4c6e>] ? _raw_spin_lock+0xe/0x20
[108055.579485]  [<ffffffff81150a18>] ? add_partial+0x58/0x90
[108055.579516]  [<ffffffffa01b6660>] ? ip_vs_conn_expire+0x0/0x340 [ip_vs]
[108055.579547]  [<ffffffff81154974>] ? __slab_free+0xa4/0x140
[108055.579575]  [<ffffffff81513cc2>] ip_expire+0x102/0x160
[108055.579602]  [<ffffffff81513bc0>] ? ip_expire+0x0/0x160
[108055.579628]  [<ffffffff81513bc0>] ? ip_expire+0x0/0x160
[108055.579655]  [<ffffffff81073862>] call_timer_fn+0x42/0x120
[108055.579683]  [<ffffffff81513bc0>] ? ip_expire+0x0/0x160
[108055.579710]  [<ffffffff81074c94>] run_timer_softirq+0x144/0x260
[108055.579741]  [<ffffffff810910e9>] ? ktime_get+0x69/0x100
[108055.579769]  [<ffffffff8106beeb>] __do_softirq+0xab/0x200
[108055.579797]  [<ffffffff810964bf>] ? tick_program_event+0x1f/0x30
[108055.579826]  [<ffffffff8100cf5c>] call_softirq+0x1c/0x30
[108055.579853]  [<ffffffff8100e9c5>] do_softirq+0x65/0xa0
[108055.579880]  [<ffffffff8106bdb5>] irq_exit+0x85/0x90
[108055.579908]  [<ffffffff815dd010>] smp_apic_timer_interrupt+0x70/0x9b
[108055.579937]  [<ffffffff8100ca13>] apic_timer_interrupt+0x13/0x20
[108055.579965]  <EOI> 
[108055.579990]  [<ffffffff814b2f22>] ? poll_idle+0x42/0x80
[108055.580018]  [<ffffffff814b2ef3>] ? poll_idle+0x13/0x80
[108055.580045]  [<ffffffff814b42a9>] ? menu_select+0x149/0x350
[108055.580073]  [<ffffffff814b3142>] cpuidle_idle_call+0xb2/0x1b0
[108055.580104]  [<ffffffff8100b067>] cpu_idle+0xb7/0x110
[108055.580132]  [<ffffffff815cc384>] start_secondary+0xc2/0xc4
[108055.580159] Code: 89 d7 48 8b 57 58 48 89 fb 41 89 f4 41 89 ce 48 83 e2 fe 0f 84 63 03 00 00 48 89 95 d8 fe ff ff 48 8b 42 18 4c 8b af d8 00 00 00 <4c> 8b 90 e0 03 00 00 8b 87 c4 00 00 00 49 01 c5 0f 82 3b 03 00 
[108055.580377] RIP  [<ffffffff81541eaf>] icmp_send+0x5f/0x760
[108055.580408]  RSP <ffff8800bfd03c40>
[108055.580430] CR2: 00000000000003e0
