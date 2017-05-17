From: Logan Gunthorpe <logang@deltatee.com>
Subject: BUG: nvmet with cxgb4 is broken in v4.12-rc1
Date: Wed, 17 May 2017 11:38:46 -0600
Message-ID: <66da3b58-f722-28f0-1ed9-70f1e47276a4@deltatee.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------5948F4B25C32456C29F3396F"
Cc: Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stephen Bates <sbates@raithlin.com>,
        SWise OGC <swise@opengridcomputing.com>,
        netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
        Sagi Grimberg <sagi@grimberg.me>
To: Arjun Vynipadath <arjun@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ale.deltatee.com ([207.54.116.67]:39238 "EHLO ale.deltatee.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752530AbdEQRjA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 13:39:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------5948F4B25C32456C29F3396F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hello,

Another cxgb4 bug report for you. Testing nvmet over our T62100-LP-CR
stopped working in v4.12-rc1. We are seeing two oopses: a general
protection fault in nvmet_rdma_free_rsps and a WQ_MEM_RECLAIM warning.
These occur after a suspect cxgb4 message. Please see the full dmesg log
which is attached.

> [   41.093555] cxgb4 0000:07:00.4: AE qpid 1034 opcode 0 status 0x1 type 1 len 0x0 wrid.hi 0x0 wrid.lo 0x0
> [   41.093673] nvmet_rdma: received IB QP event: QP access error (3)

I've bisected to find this commit is the culprit:

bb58d079: cxgb4: Update IngPad and IngPack values

A bisect log is also attached. Reverting that commit also fixes the issue.

Thanks,

Logan

--------------5948F4B25C32456C29F3396F
Content-Type: text/x-log;
 name="bisect.nvmet1.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="bisect.nvmet1.log"

git bisect start
# good: [a351e9b9fc24e982ec2f0e76379a49826036da12] Linux 4.11
git bisect good a351e9b9fc24e982ec2f0e76379a49826036da12
# bad: [2ea659a9ef488125eb46da6eb571de5eae5c43f6] Linux 4.12-rc1
git bisect bad 2ea659a9ef488125eb46da6eb571de5eae5c43f6
# bad: [221656e7c4ce342b99c31eca96c1cbb6d1dce45f] Merge tag 'sound-4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect bad 221656e7c4ce342b99c31eca96c1cbb6d1dce45f
# bad: [8d65b08debc7e62b2c6032d7fe7389d895b92cbc] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect bad 8d65b08debc7e62b2c6032d7fe7389d895b92cbc
# bad: [cec381919818a9a0cb85600b3c82404bdd38cf36] Merge tag 'mac80211-next-for-davem-2017-04-28' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next
git bisect bad cec381919818a9a0cb85600b3c82404bdd38cf36
# bad: [5cd8985a19090f2b0ce8700ae3ec19e06a4fc5e9] net-next: dsa: add Mediatek tag RX/TX handler
git bisect bad 5cd8985a19090f2b0ce8700ae3ec19e06a4fc5e9
# bad: [b4f0a66155564aaf7e98492e027efad9f797c244] net: stmmac: fix dma operation mode config for older versions
git bisect bad b4f0a66155564aaf7e98492e027efad9f797c244
# good: [6689da155bdcd17abfe4d3a8b1e245d9ed4b5f2c] net: bcmgenet: manage dma interrupts in napi code
git bisect good 6689da155bdcd17abfe4d3a8b1e245d9ed4b5f2c
# good: [41e95736b30833710c1e77a2877c2d71133450f7] Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
git bisect good 41e95736b30833710c1e77a2877c2d71133450f7
# good: [cccf6f5cdc96ef6fa02f27ecd8073406a402929a] qed: Make qed_iov_mark_vf_flr() return bool
git bisect good cccf6f5cdc96ef6fa02f27ecd8073406a402929a
# bad: [33e85b8dd69e7f2fbf77f04bfc97ea7c76bccf9b] net: stmmac: Restore DT backwards-compatibility
git bisect bad 33e85b8dd69e7f2fbf77f04bfc97ea7c76bccf9b
# bad: [c7cd4c9bf8df87027e739fe66d0a55951f6875d8] mlxsw: spectrum: fix swapped order of arguments packets and bytes
git bisect bad c7cd4c9bf8df87027e739fe66d0a55951f6875d8
# good: [f22913d0b5560ae621e8a7391e9547d5a6fd8893] ixgb: use new API ethtool_{get|set}_link_ksettings
git bisect good f22913d0b5560ae621e8a7391e9547d5a6fd8893
# good: [7ada7ca562714632d0fc9abb24e27cab67bdbf0d] Merge branch '1GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
git bisect good 7ada7ca562714632d0fc9abb24e27cab67bdbf0d
# good: [424fa00ea325b0153c321667f39643f68ae9d1b0] net: dwc-xlgmac: include dcbnl.h
git bisect good 424fa00ea325b0153c321667f39643f68ae9d1b0
# bad: [bb58d07964f2f09e133b46541447c567a7306dc1] cxgb4: Update IngPad and IngPack values
git bisect bad bb58d07964f2f09e133b46541447c567a7306dc1
# good: [3588f29e061cef19ac0092e4f6917717fed5b1d4] net: dwc-xlgmac: add module license
git bisect good 3588f29e061cef19ac0092e4f6917717fed5b1d4
# first bad commit: [bb58d07964f2f09e133b46541447c567a7306dc1] cxgb4: Update IngPad and IngPack values

--------------5948F4B25C32456C29F3396F
Content-Type: text/x-log;
 name="dmesg.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dmesg.log"

[    0.000000] Linux version 4.12.0-rc1.spreadpfn (gunthorp@cgy1-donard) (gcc version 4.9.2 (Debian 4.9.2-10) ) #340 SMP Wed May 17 11:27:02 MDT 2017
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-4.11.0-next-20170510.spread-pfn+ root=/dev/mapper/cgy1--donard-root ro memmap=2G!14G quiet
[    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
[    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
[    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'standard' format.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000008dbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000008dc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007dd14fff] usable
[    0.000000] BIOS-e820: [mem 0x000000007dd15000-0x000000007dda3fff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007dda4000-0x000000007deadfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007deae000-0x000000007e0cafff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007e0cb000-0x000000007f36bfff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007f36c000-0x000000007f7fffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x0000000080000000-0x000000008fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed3ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000047fffffff] usable
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] e820: user-defined physical RAM map:
[    0.000000] user: [mem 0x0000000000000000-0x000000000008dbff] usable
[    0.000000] user: [mem 0x000000000008dc00-0x000000000009ffff] reserved
[    0.000000] user: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] user: [mem 0x0000000000100000-0x000000007dd14fff] usable
[    0.000000] user: [mem 0x000000007dd15000-0x000000007dda3fff] reserved
[    0.000000] user: [mem 0x000000007dda4000-0x000000007deadfff] ACPI data
[    0.000000] user: [mem 0x000000007deae000-0x000000007e0cafff] ACPI NVS
[    0.000000] user: [mem 0x000000007e0cb000-0x000000007f36bfff] reserved
[    0.000000] user: [mem 0x000000007f36c000-0x000000007f7fffff] ACPI NVS
[    0.000000] user: [mem 0x0000000080000000-0x000000008fffffff] reserved
[    0.000000] user: [mem 0x00000000fed1c000-0x00000000fed3ffff] reserved
[    0.000000] user: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
[    0.000000] user: [mem 0x0000000100000000-0x000000037fffffff] usable
[    0.000000] user: [mem 0x0000000380000000-0x00000003ffffffff] persistent (type 12)
[    0.000000] user: [mem 0x0000000400000000-0x000000047fffffff] usable
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Supermicro SYS-7047GR-TRF/X9DRG-QF, BIOS 3.0a 12/05/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x480000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask 3FFC00000000 write-back
[    0.000000]   1 base 000400000000 mask 3FFF80000000 write-back
[    0.000000]   2 base 000080000000 mask 3FFF80000000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
[    0.000000] e820: update [mem 0x80000000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0x7dd15 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fdbb0-0x000fdbbf] mapped at [ffff8800000fdbb0]
[    0.000000] Base memory trampoline at [ffff880000087000] 87000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] BRK [0x02145000, 0x02145fff] PGTABLE
[    0.000000] BRK [0x02146000, 0x02146fff] PGTABLE
[    0.000000] BRK [0x02147000, 0x02147fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x374a4000-0x37a49fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F04A0 000024 (v02 SUPERM)
[    0.000000] ACPI: XSDT 0x000000007DDD9090 00009C (v01 SUPERM SMCI--MB 00000001 AMI  00010013)
[    0.000000] ACPI: FACP 0x000000007DDE4D88 0000F4 (v04 SUPERM SMCI--MB 00000001 AMI  00010013)
[    0.000000] ACPI: DSDT 0x000000007DDD91B8 00BBCD (v02 SUPERM SMCI--MB 00000000 INTL 20091112)
[    0.000000] ACPI: FACS 0x000000007E0C2080 000040
[    0.000000] ACPI: APIC 0x000000007DDE4E80 0000D4 (v03                 00000001 AMI  00010013)
[    0.000000] ACPI: FPDT 0x000000007DDE4F58 000044 (v01                 00000001 AMI  00010013)
[    0.000000] ACPI: SRAT 0x000000007DDE4FA0 000330 (v01 A M I  AMI SRAT 00000001 AMI. 00000000)
[    0.000000] ACPI: SLIT 0x000000007DDE52D0 000030 (v01 A M I  AMI SLIT 00000000 AMI. 00000000)
[    0.000000] ACPI: HPET 0x000000007DDE5300 000038 (v01 SUPERM SMCI--MB 00000001 AMI. 00000005)
[    0.000000] ACPI: PRAD 0x000000007DDE5338 0000BE (v02 PRADID PRADTID  00000001 MSFT 04000000)
[    0.000000] ACPI: SPMI 0x000000007DDE53F8 000040 (v05 A M I  OEMSPMI  00000000 AMI. 00000000)
[    0.000000] ACPI: SSDT 0x000000007DDE5438 0C7AE8 (v02 INTEL  CpuPm    00004000 INTL 20091112)
[    0.000000] ACPI: EINJ 0x000000007DEACF20 000130 (v01 AMI    AMI EINJ 00000000      00000000)
[    0.000000] ACPI: ERST 0x000000007DEAD050 000230 (v01 AMIER  AMI ERST 00000000      00000000)
[    0.000000] ACPI: HEST 0x000000007DEAD280 0000A8 (v01 AMI    AMI HEST 00000000      00000000)
[    0.000000] ACPI: BERT 0x000000007DEAD328 000030 (v01 AMI    AMI BERT 00000000      00000000)
[    0.000000] ACPI: DMAR 0x000000007DEAD358 000160 (v01 A M I  OEMDMAR  00000001 INTL 00000001)
[    0.000000] ACPI: MCFG 0x000000007DEAD4B8 00003C (v01 SUPERM SMCI--MB 00000001 MSFT 00000097)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x26 -> Node 1
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x27fffffff]
[    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x280000000-0x47fffffff]
[    0.000000] NUMA: Initialized distance table, cnt=2
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x27fffffff] -> [mem 0x00000000-0x27fffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x27fffc000-0x27fffffff]
[    0.000000] NODE_DATA(1) allocated [mem 0x47fff9000-0x47fffcfff]
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000000001000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000047fffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000008cfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007dd14fff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000027fffffff]
[    0.000000]   node   1: [mem 0x0000000280000000-0x000000037fffffff]
[    0.000000]   node   1: [mem 0x0000000400000000-0x000000047fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000027fffffff]
[    0.000000] On node 0 totalpages: 2088097
[    0.000000]   DMA32 zone: 8051 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 515233 pages, LIFO batch:31
[    0.000000]   Normal zone: 24576 pages used for memmap
[    0.000000]   Normal zone: 1572864 pages, LIFO batch:31
[    0.000000] Initmem setup node 1 [mem 0x0000000280000000-0x000000047fffffff]
[    0.000000] On node 1 totalpages: 1572864
[    0.000000]   Normal zone: 24576 pages used for memmap
[    0.000000]   Normal zone: 1572864 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
[    0.000000] IOAPIC[1]: apic_id 2, version 32, address 0xfec01000, GSI 24-47
[    0.000000] IOAPIC[2]: apic_id 3, version 32, address 0xfec40000, GSI 48-71
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 8 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0008d000-0x0008dfff]
[    0.000000] PM: Registered nosave memory: [mem 0x0008e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x7dd15000-0x7dda3fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7dda4000-0x7deadfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7deae000-0x7e0cafff]
[    0.000000] PM: Registered nosave memory: [mem 0x7e0cb000-0x7f36bfff]
[    0.000000] PM: Registered nosave memory: [mem 0x7f36c000-0x7f7fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x7f800000-0x7fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x80000000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed3ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed40000-0xfeffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x380000000-0x3ffffffff]
[    0.000000] e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:8 nr_node_ids:2
[    0.000000] percpu: Embedded 37 pages/cpu @ffff880277c00000 s113624 r8192 d29736 u524288
[    0.000000] pcpu-alloc: s113624 r8192 d29736 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 [1] 4 5 6 7 
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  Total pages: 3603737
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.11.0-next-20170510.spread-pfn+ root=/dev/mapper/cgy1--donard-root ro memmap=2G!14G quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 14323652K/14643844K available (9597K kernel code, 1380K rwdata, 3360K rodata, 1140K init, 704K bss, 320192K reserved, 0K cma-reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=8.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=8
[    0.000000] NR_IRQS:33024 nr_irqs:1304 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.004000] tsc: Detected 2400.003 MHz processor
[    0.004000] Calibrating delay loop (skipped), value calculated using timer frequency.. 4800.00 BogoMIPS (lpj=9600012)
[    0.004000] pid_max: default: 32768 minimum: 301
[    0.004000] ACPI: Core revision 20170303
[    0.055723] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.055768] Security Framework initialized
[    0.055770] AppArmor: AppArmor disabled by boot time parameter
[    0.056530] Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
[    0.059758] Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.061197] Mount-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.061215] Mountpoint-cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.061516] CPU: Physical Processor ID: 0
[    0.061516] CPU: Processor Core ID: 0
[    0.061524] mce: CPU supports 16 MCE banks
[    0.061537] CPU0: Thermal monitoring enabled (TM1)
[    0.061564] process: using mwait in idle threads
[    0.061568] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
[    0.061568] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.061725] Freeing SMP alternatives memory: 36K
[    0.062069] smpboot: Max logical packages: 2
[    0.062083] DMAR: Host address width 46
[    0.062085] DMAR: DRHD base: 0x000000fbffe000 flags: 0x0
[    0.062092] DMAR: dmar0: reg_base_addr fbffe000 ver 1:0 cap d2078c106f0462 ecap f020fe
[    0.062093] DMAR: DRHD base: 0x000000c3ffc000 flags: 0x1
[    0.062097] DMAR: dmar1: reg_base_addr c3ffc000 ver 1:0 cap d2078c106f0462 ecap f020fe
[    0.062098] DMAR: RMRR base: 0x0000007dd7a000 end: 0x0000007dd86fff
[    0.062099] DMAR: ATSR flags: 0x0
[    0.062101] DMAR: RHSA base: 0x000000fbffe000 proximity domain: 0x1
[    0.062102] DMAR: RHSA base: 0x000000c3ffc000 proximity domain: 0x0
[    0.062104] DMAR-IR: IOAPIC id 3 under DRHD base  0xfbffe000 IOMMU 0
[    0.062105] DMAR-IR: IOAPIC id 0 under DRHD base  0xc3ffc000 IOMMU 1
[    0.062106] DMAR-IR: IOAPIC id 2 under DRHD base  0xc3ffc000 IOMMU 1
[    0.062107] DMAR-IR: HPET id 0 under DRHD base 0xc3ffc000
[    0.062109] DMAR-IR: Queued invalidation will be enabled to support x2apic and Intr-remapping.
[    0.062906] DMAR-IR: Enabled IRQ remapping in x2apic mode
[    0.062907] x2apic enabled
[    0.062912] Switched APIC routing to cluster x2apic.
[    0.063566] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.103267] TSC deadline timer enabled
[    0.103271] smpboot: CPU0: Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz (family: 0x6, model: 0x2d, stepping: 0x7)
[    0.103361] Performance Events: PEBS fmt1+, SandyBridge events, 16-deep LBR, full-width counters, Intel PMU driver.
[    0.103385] ... version:                3
[    0.103386] ... bit width:              48
[    0.103387] ... generic registers:      8
[    0.103387] ... value mask:             0000ffffffffffff
[    0.103388] ... max period:             00007fffffffffff
[    0.103388] ... fixed-purpose events:   3
[    0.103389] ... event mask:             00000007000000ff
[    0.104000] smp: Bringing up secondary CPUs ...
[    0.104000] x86: Booting SMP configuration:
[    0.104000] .... node  #0, CPUs:      #1
[    0.182048] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.182048]  #2 #3
[    0.342050] .... node  #1, CPUs:   #4 #5 #6 #7
[    0.666058] smp: Brought up 2 nodes, 8 CPUs
[    0.666058] smpboot: Total of 8 processors activated (38410.12 BogoMIPS)
[    0.668179] sched_clock: Marking stable (668000000, 0)->(687400104, -19400104)
[    0.668596] devtmpfs: initialized
[    0.668661] x86/mm: Memory block size: 128MB
[    0.671765] PM: Registering ACPI NVS region [mem 0x7deae000-0x7e0cafff] (2215936 bytes)
[    0.671831] PM: Registering ACPI NVS region [mem 0x7f36c000-0x7f7fffff] (4800512 bytes)
[    0.672011] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.672031] futex hash table entries: 2048 (order: 5, 131072 bytes)
[    0.673987] NET: Registered protocol family 16
[    0.674219] cpuidle: using governor ladder
[    0.674223] cpuidle: using governor menu
[    0.674260] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.674261] ACPI: bus type PCI registered
[    0.674262] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.674319] dca service started, version 1.12.1
[    0.674336] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000-0x8fffffff] (base 0x80000000)
[    0.674339] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
[    0.674346] pmd_set_huge: Cannot satisfy [mem 0x80000000-0x80200000] with a huge-page mapping due to MTRR override.
[    0.674629] PCI: Using configuration type 1 for base access
[    0.675208] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.675220] core: PMU erratum BJ122, BV98, HSD29 workaround disabled, HT off
[    0.675622] mtrr: your CPUs had inconsistent fixed MTRR settings
[    0.675623] mtrr: probably your BIOS does not setup all CPUs.
[    0.675623] mtrr: corrected configuration.
[    0.677878] HugeTLB registered 1 GB page size, pre-allocated 0 pages
[    0.677879] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.678198] ACPI: Added _OSI(Module Device)
[    0.678199] ACPI: Added _OSI(Processor Device)
[    0.678199] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.678200] ACPI: Added _OSI(Processor Aggregator Device)
[    0.678385] ACPI: Executed 1 blocks of module-level executable AML code
[    0.995766] ACPI: Interpreter enabled
[    0.995785] ACPI: (supports S0 S1 S4 S5)
[    0.995786] ACPI: Using IOAPIC for interrupt routing
[    0.995861] HEST: Table parsing has been initialized.
[    0.995863] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.015057] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-7e])
[    1.015062] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    1.015232] acpi PNP0A08:00: _OSC: platform does not support [PME AER]
[    1.015392] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PCIeCapability]
[    1.015393] acpi PNP0A08:00: FADT indicates ASPM is unsupported, using BIOS configuration
[    1.015714] PCI host bridge to bus 0000:00
[    1.015716] pci_bus 0000:00: root bus resource [io  0x0000-0x03af window]
[    1.015717] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7 window]
[    1.015719] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df window]
[    1.015720] pci_bus 0000:00: root bus resource [io  0x0d00-0x9fff window]
[    1.015721] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    1.015722] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dffff window]
[    1.015724] pci_bus 0000:00: root bus resource [mem 0xfed08000-0xfed08fff window]
[    1.015725] pci_bus 0000:00: root bus resource [mem 0xfed0e000-0xfed0ffff window]
[    1.015726] pci_bus 0000:00: root bus resource [mem 0x80000000-0xc3ffffff window]
[    1.015727] pci_bus 0000:00: root bus resource [mem 0x380000000000-0x381fffffffff window]
[    1.015729] pci_bus 0000:00: root bus resource [bus 00-7e]
[    1.015740] pci 0000:00:00.0: [8086:3c00] type 00 class 0x060000
[    1.015814] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    1.015912] pci 0000:00:01.0: [8086:3c02] type 01 class 0x060400
[    1.015990] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    1.016058] pci 0000:00:01.0: System wakeup disabled by ACPI
[    1.016100] pci 0000:00:02.0: [8086:3c04] type 01 class 0x060400
[    1.016177] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    1.016242] pci 0000:00:02.0: System wakeup disabled by ACPI
[    1.016282] pci 0000:00:03.0: [8086:3c08] type 01 class 0x060400
[    1.016360] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    1.016425] pci 0000:00:03.0: System wakeup disabled by ACPI
[    1.016463] pci 0000:00:04.0: [8086:3c20] type 00 class 0x088000
[    1.016479] pci 0000:00:04.0: reg 0x10: [mem 0x381ffff20000-0x381ffff23fff 64bit]
[    1.016612] pci 0000:00:04.1: [8086:3c21] type 00 class 0x088000
[    1.016626] pci 0000:00:04.1: reg 0x10: [mem 0x381ffff1c000-0x381ffff1ffff 64bit]
[    1.016758] pci 0000:00:04.2: [8086:3c22] type 00 class 0x088000
[    1.016773] pci 0000:00:04.2: reg 0x10: [mem 0x381ffff18000-0x381ffff1bfff 64bit]
[    1.016905] pci 0000:00:04.3: [8086:3c23] type 00 class 0x088000
[    1.016920] pci 0000:00:04.3: reg 0x10: [mem 0x381ffff14000-0x381ffff17fff 64bit]
[    1.017051] pci 0000:00:04.4: [8086:3c24] type 00 class 0x088000
[    1.017066] pci 0000:00:04.4: reg 0x10: [mem 0x381ffff10000-0x381ffff13fff 64bit]
[    1.017197] pci 0000:00:04.5: [8086:3c25] type 00 class 0x088000
[    1.017211] pci 0000:00:04.5: reg 0x10: [mem 0x381ffff0c000-0x381ffff0ffff 64bit]
[    1.017343] pci 0000:00:04.6: [8086:3c26] type 00 class 0x088000
[    1.017357] pci 0000:00:04.6: reg 0x10: [mem 0x381ffff08000-0x381ffff0bfff 64bit]
[    1.017488] pci 0000:00:04.7: [8086:3c27] type 00 class 0x088000
[    1.017502] pci 0000:00:04.7: reg 0x10: [mem 0x381ffff04000-0x381ffff07fff 64bit]
[    1.017633] pci 0000:00:05.0: [8086:3c28] type 00 class 0x088000
[    1.017758] pci 0000:00:05.2: [8086:3c2a] type 00 class 0x088000
[    1.017882] pci 0000:00:05.4: [8086:3c2c] type 00 class 0x080020
[    1.017892] pci 0000:00:05.4: reg 0x10: [mem 0xc2a04000-0xc2a04fff]
[    1.018026] pci 0000:00:11.0: [8086:1d3e] type 01 class 0x060400
[    1.018121] pci 0000:00:11.0: PME# supported from D0 D3hot D3cold
[    1.018221] pci 0000:00:16.0: [8086:1d3a] type 00 class 0x078000
[    1.018238] pci 0000:00:16.0: reg 0x10: [mem 0xfed0e000-0xfed0e00f 64bit]
[    1.018300] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    1.018382] pci 0000:00:16.1: [8086:1d3b] type 00 class 0x078000
[    1.018399] pci 0000:00:16.1: reg 0x10: [mem 0xfed0f000-0xfed0f00f 64bit]
[    1.018460] pci 0000:00:16.1: PME# supported from D0 D3hot D3cold
[    1.018554] pci 0000:00:1a.0: [8086:1d2d] type 00 class 0x0c0320
[    1.018571] pci 0000:00:1a.0: reg 0x10: [mem 0xc2a02000-0xc2a023ff]
[    1.018653] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    1.018707] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    1.018743] pci 0000:00:1b.0: [8086:1d20] type 00 class 0x040300
[    1.018760] pci 0000:00:1b.0: reg 0x10: [mem 0x381ffff00000-0x381ffff03fff 64bit]
[    1.018831] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    1.018916] pci 0000:00:1c.0: [8086:1d10] type 01 class 0x060400
[    1.018992] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    1.019050] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    1.019090] pci 0000:00:1c.7: [8086:1d1e] type 01 class 0x060400
[    1.019166] pci 0000:00:1c.7: PME# supported from D0 D3hot D3cold
[    1.019223] pci 0000:00:1c.7: System wakeup disabled by ACPI
[    1.019258] pci 0000:00:1d.0: [8086:1d26] type 00 class 0x0c0320
[    1.019274] pci 0000:00:1d.0: reg 0x10: [mem 0xc2a01000-0xc2a013ff]
[    1.019361] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    1.019416] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    1.019451] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    1.019545] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    1.019581] pci 0000:00:1f.0: [8086:1d41] type 00 class 0x060100
[    1.019757] pci 0000:00:1f.2: [8086:1d02] type 00 class 0x010601
[    1.019771] pci 0000:00:1f.2: reg 0x10: [io  0x9050-0x9057]
[    1.019778] pci 0000:00:1f.2: reg 0x14: [io  0x9040-0x9043]
[    1.019785] pci 0000:00:1f.2: reg 0x18: [io  0x9030-0x9037]
[    1.019792] pci 0000:00:1f.2: reg 0x1c: [io  0x9020-0x9023]
[    1.019798] pci 0000:00:1f.2: reg 0x20: [io  0x9000-0x901f]
[    1.019805] pci 0000:00:1f.2: reg 0x24: [mem 0xc2a00000-0xc2a007ff]
[    1.019845] pci 0000:00:1f.2: PME# supported from D3hot
[    1.019926] pci 0000:00:1f.3: [8086:1d22] type 00 class 0x0c0500
[    1.019940] pci 0000:00:1f.3: reg 0x10: [mem 0x381ffff24000-0x381ffff240ff 64bit]
[    1.019959] pci 0000:00:1f.3: reg 0x20: [io  0x1180-0x119f]
[    1.020054] pci 0000:00:1f.6: [8086:1d24] type 00 class 0x118000
[    1.020073] pci 0000:00:1f.6: reg 0x10: [mem 0xfed08000-0xfed08fff 64bit]
[    1.020241] pci 0000:00:01.0: PCI bridge to [bus 01]
[    1.020287] pci 0000:00:02.0: PCI bridge to [bus 02]
[    1.020432] pci 0000:03:00.0: [11f8:8543] type 01 class 0x060400
[    1.022863] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    1.036320] pci 0000:00:03.0: PCI bridge to [bus 03-07]
[    1.036325] pci 0000:00:03.0:   bridge window [mem 0xa0000000-0xc1ffffff]
[    1.036329] pci 0000:00:03.0:   bridge window [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.036744] pci 0000:04:00.0: [11f8:8543] type 01 class 0x060400
[    1.040260] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
[    1.041999] pci 0000:04:01.0: [11f8:8543] type 01 class 0x060400
[    1.045792] pci 0000:04:01.0: PME# supported from D0 D3hot D3cold
[    1.046308] pci 0000:04:02.0: [11f8:8543] type 01 class 0x060400
[    1.050099] pci 0000:04:02.0: PME# supported from D0 D3hot D3cold
[    1.052288] pci 0000:03:00.0: PCI bridge to [bus 04-07]
[    1.052366] pci 0000:03:00.0:   bridge window [mem 0xa0000000-0xc1ffffff]
[    1.052418] pci 0000:03:00.0:   bridge window [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.053886] pci 0000:05:00.0: [11f8:f117] type 00 class 0x010802
[    1.054162] pci 0000:05:00.0: reg 0x10: [mem 0xc1f00000-0xc1f03fff 64bit]
[    1.055794] pci 0000:05:00.0: reg 0x20: [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.058231] pci 0000:04:00.0: PCI bridge to [bus 05]
[    1.059502] pci 0000:04:00.0:   bridge window [mem 0xc1f00000-0xc1ffffff]
[    1.059554] pci 0000:04:00.0:   bridge window [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.060033] pci 0000:06:00.0: [111d:80d1] type 00 class 0x010802
[    1.061512] pci 0000:06:00.0: reg 0x10: [mem 0xc1e00000-0xc1e03fff 64bit]
[    1.065985] pci 0000:04:01.0: PCI bridge to [bus 06]
[    1.066062] pci 0000:04:01.0:   bridge window [mem 0xc1e00000-0xc1efffff]
[    1.067730] pci 0000:07:00.0: [1425:6007] type 00 class 0x020000
[    1.068021] pci 0000:07:00.0: reg 0x10: [mem 0xc1900000-0xc197ffff 64bit]
[    1.069374] pci 0000:07:00.0: reg 0x18: [mem 0xc1880000-0xc18fffff 64bit]
[    1.069512] pci 0000:07:00.0: reg 0x20: [mem 0xc1c0a000-0xc1c0bfff 64bit]
[    1.069600] pci 0000:07:00.0: reg 0x30: [mem 0xc1800000-0xc187ffff pref]
[    1.073356] pci 0000:07:00.0: reg 0x1ec: [mem 0xc1c3c000-0xc1c3cfff 64bit]
[    1.073357] pci 0000:07:00.0: VF(n) BAR0 space: [mem 0xc1c3c000-0xc1c4bfff 64bit] (contains BAR0 for 16 VFs)
[    1.073494] pci 0000:07:00.0: reg 0x1f4: [mem 0xc1b00000-0xc1b07fff 64bit]
[    1.073496] pci 0000:07:00.0: VF(n) BAR2 space: [mem 0xc1b00000-0xc1b7ffff 64bit] (contains BAR2 for 16 VFs)
[    1.073632] pci 0000:07:00.0: reg 0x1fc: [mem 0xc1be0000-0xc1be1fff 64bit]
[    1.073633] pci 0000:07:00.0: VF(n) BAR4 space: [mem 0xc1be0000-0xc1bfffff 64bit] (contains BAR4 for 16 VFs)
[    1.077124] pci 0000:07:00.1: [1425:6007] type 00 class 0x020000
[    1.077389] pci 0000:07:00.1: reg 0x10: [mem 0xc1780000-0xc17fffff 64bit]
[    1.077528] pci 0000:07:00.1: reg 0x18: [mem 0xc1700000-0xc177ffff 64bit]
[    1.077665] pci 0000:07:00.1: reg 0x20: [mem 0xc1c08000-0xc1c09fff 64bit]
[    1.077753] pci 0000:07:00.1: reg 0x30: [mem 0xc1680000-0xc16fffff pref]
[    1.081329] pci 0000:07:00.1: reg 0x1ec: [mem 0xc1c2c000-0xc1c2cfff 64bit]
[    1.081331] pci 0000:07:00.1: VF(n) BAR0 space: [mem 0xc1c2c000-0xc1c3bfff 64bit] (contains BAR0 for 16 VFs)
[    1.081470] pci 0000:07:00.1: reg 0x1f4: [mem 0xc1a80000-0xc1a87fff 64bit]
[    1.081471] pci 0000:07:00.1: VF(n) BAR2 space: [mem 0xc1a80000-0xc1afffff 64bit] (contains BAR2 for 16 VFs)
[    1.081607] pci 0000:07:00.1: reg 0x1fc: [mem 0xc1bc0000-0xc1bc1fff 64bit]
[    1.081608] pci 0000:07:00.1: VF(n) BAR4 space: [mem 0xc1bc0000-0xc1bdffff 64bit] (contains BAR4 for 16 VFs)
[    1.085061] pci 0000:07:00.2: [1425:6007] type 00 class 0x020000
[    1.085327] pci 0000:07:00.2: reg 0x10: [mem 0xc1600000-0xc167ffff 64bit]
[    1.085464] pci 0000:07:00.2: reg 0x18: [mem 0xc1580000-0xc15fffff 64bit]
[    1.085603] pci 0000:07:00.2: reg 0x20: [mem 0xc1c06000-0xc1c07fff 64bit]
[    1.086935] pci 0000:07:00.2: reg 0x30: [mem 0xc1500000-0xc157ffff pref]
[    1.089267] pci 0000:07:00.2: reg 0x1ec: [mem 0xc1c1c000-0xc1c1cfff 64bit]
[    1.089268] pci 0000:07:00.2: VF(n) BAR0 space: [mem 0xc1c1c000-0xc1c2bfff 64bit] (contains BAR0 for 16 VFs)
[    1.089405] pci 0000:07:00.2: reg 0x1f4: [mem 0xc1a00000-0xc1a07fff 64bit]
[    1.089406] pci 0000:07:00.2: VF(n) BAR2 space: [mem 0xc1a00000-0xc1a7ffff 64bit] (contains BAR2 for 16 VFs)
[    1.089543] pci 0000:07:00.2: reg 0x1fc: [mem 0xc1ba0000-0xc1ba1fff 64bit]
[    1.089545] pci 0000:07:00.2: VF(n) BAR4 space: [mem 0xc1ba0000-0xc1bbffff 64bit] (contains BAR4 for 16 VFs)
[    1.093026] pci 0000:07:00.3: [1425:6007] type 00 class 0x020000
[    1.093292] pci 0000:07:00.3: reg 0x10: [mem 0xc1480000-0xc14fffff 64bit]
[    1.093430] pci 0000:07:00.3: reg 0x18: [mem 0xc1400000-0xc147ffff 64bit]
[    1.094784] pci 0000:07:00.3: reg 0x20: [mem 0xc1c04000-0xc1c05fff 64bit]
[    1.094872] pci 0000:07:00.3: reg 0x30: [mem 0xc1380000-0xc13fffff pref]
[    1.097199] pci 0000:07:00.3: reg 0x1ec: [mem 0xc1c0c000-0xc1c0cfff 64bit]
[    1.097200] pci 0000:07:00.3: VF(n) BAR0 space: [mem 0xc1c0c000-0xc1c1bfff 64bit] (contains BAR0 for 16 VFs)
[    1.097337] pci 0000:07:00.3: reg 0x1f4: [mem 0xc1980000-0xc1987fff 64bit]
[    1.097338] pci 0000:07:00.3: VF(n) BAR2 space: [mem 0xc1980000-0xc19fffff 64bit] (contains BAR2 for 16 VFs)
[    1.098724] pci 0000:07:00.3: reg 0x1fc: [mem 0xc1b80000-0xc1b81fff 64bit]
[    1.098725] pci 0000:07:00.3: VF(n) BAR4 space: [mem 0xc1b80000-0xc1b9ffff 64bit] (contains BAR4 for 16 VFs)
[    1.100956] pci 0000:07:00.4: [1425:6407] type 00 class 0x020000
[    1.101222] pci 0000:07:00.4: reg 0x10: [mem 0xc1300000-0xc137ffff 64bit]
[    1.101360] pci 0000:07:00.4: reg 0x18: [mem 0xc0000000-0xc0ffffff 64bit]
[    1.102723] pci 0000:07:00.4: reg 0x20: [mem 0xa0000000-0xbfffffff 64bit]
[    1.105303] pci 0000:07:00.5: [1425:6507] type 00 class 0x010000
[    1.106786] pci 0000:07:00.5: reg 0x10: [mem 0xc1280000-0xc12fffff 64bit]
[    1.106924] pci 0000:07:00.5: reg 0x18: [mem 0xc1200000-0xc127ffff 64bit]
[    1.107062] pci 0000:07:00.5: reg 0x20: [mem 0xc1c02000-0xc1c03fff 64bit]
[    1.107149] pci 0000:07:00.5: reg 0x30: [mem 0xc1180000-0xc11fffff pref]
[    1.110892] pci 0000:07:00.6: [1425:6607] type 00 class 0x0c0400
[    1.111157] pci 0000:07:00.6: reg 0x10: [mem 0xc1100000-0xc117ffff 64bit]
[    1.112509] pci 0000:07:00.6: reg 0x18: [mem 0xc1080000-0xc10fffff 64bit]
[    1.112647] pci 0000:07:00.6: reg 0x20: [mem 0xc1c00000-0xc1c01fff 64bit]
[    1.112735] pci 0000:07:00.6: reg 0x30: [mem 0xc1000000-0xc107ffff pref]
[    1.116590] pci 0000:04:02.0: PCI bridge to [bus 07]
[    1.116668] pci 0000:04:02.0:   bridge window [mem 0xa0000000-0xc1cfffff]
[    1.117033] pci 0000:08:00.0: [8086:1d6b] type 00 class 0x010700
[    1.117057] pci 0000:08:00.0: reg 0x10: [mem 0x381fc047c000-0x381fc047ffff 64bit pref]
[    1.117071] pci 0000:08:00.0: reg 0x18: [mem 0x381fc0000000-0x381fc03fffff 64bit pref]
[    1.117081] pci 0000:08:00.0: reg 0x20: [io  0x8000-0x80ff]
[    1.117192] pci 0000:08:00.0: reg 0x164: [mem 0x381fc0400000-0x381fc0403fff 64bit pref]
[    1.117193] pci 0000:08:00.0: VF(n) BAR0 space: [mem 0x381fc0400000-0x381fc047bfff 64bit pref] (contains BAR0 for 31 VFs)
[    1.117387] pci 0000:00:11.0: PCI bridge to [bus 08]
[    1.117391] pci 0000:00:11.0:   bridge window [io  0x8000-0x8fff]
[    1.117400] pci 0000:00:11.0:   bridge window [mem 0x381fc0000000-0x381fc04fffff 64bit pref]
[    1.117461] pci 0000:09:00.0: [8086:1521] type 00 class 0x020000
[    1.117493] pci 0000:09:00.0: reg 0x10: [mem 0xc2920000-0xc293ffff]
[    1.117517] pci 0000:09:00.0: reg 0x18: [io  0x7020-0x703f]
[    1.117530] pci 0000:09:00.0: reg 0x1c: [mem 0xc2944000-0xc2947fff]
[    1.117667] pci 0000:09:00.0: PME# supported from D0 D3hot D3cold
[    1.117713] pci 0000:09:00.0: reg 0x184: [mem 0x381fc0660000-0x381fc0663fff 64bit pref]
[    1.117715] pci 0000:09:00.0: VF(n) BAR0 space: [mem 0x381fc0660000-0x381fc067ffff 64bit pref] (contains BAR0 for 8 VFs)
[    1.117744] pci 0000:09:00.0: reg 0x190: [mem 0x381fc0640000-0x381fc0643fff 64bit pref]
[    1.117745] pci 0000:09:00.0: VF(n) BAR3 space: [mem 0x381fc0640000-0x381fc065ffff 64bit pref] (contains BAR3 for 8 VFs)
[    1.117863] pci 0000:09:00.1: [8086:1521] type 00 class 0x020000
[    1.117893] pci 0000:09:00.1: reg 0x10: [mem 0xc2900000-0xc291ffff]
[    1.117918] pci 0000:09:00.1: reg 0x18: [io  0x7000-0x701f]
[    1.117931] pci 0000:09:00.1: reg 0x1c: [mem 0xc2940000-0xc2943fff]
[    1.118063] pci 0000:09:00.1: PME# supported from D0 D3hot D3cold
[    1.118108] pci 0000:09:00.1: reg 0x184: [mem 0x381fc0620000-0x381fc0623fff 64bit pref]
[    1.118109] pci 0000:09:00.1: VF(n) BAR0 space: [mem 0x381fc0620000-0x381fc063ffff 64bit pref] (contains BAR0 for 8 VFs)
[    1.118138] pci 0000:09:00.1: reg 0x190: [mem 0x381fc0600000-0x381fc0603fff 64bit pref]
[    1.118139] pci 0000:09:00.1: VF(n) BAR3 space: [mem 0x381fc0600000-0x381fc061ffff 64bit pref] (contains BAR3 for 8 VFs)
[    1.126817] pci 0000:00:1c.0: PCI bridge to [bus 09-0a]
[    1.126821] pci 0000:00:1c.0:   bridge window [io  0x7000-0x7fff]
[    1.126824] pci 0000:00:1c.0:   bridge window [mem 0xc2900000-0xc29fffff]
[    1.126829] pci 0000:00:1c.0:   bridge window [mem 0x381fc0600000-0x381fc06fffff 64bit pref]
[    1.127182] pci 0000:0b:00.0: [1912:0013] type 01 class 0x060400
[    1.129501] pci 0000:0b:00.0: PME# supported from D0 D3hot D3cold
[    1.130120] pci 0000:00:1c.7: PCI bridge to [bus 0b-0f]
[    1.130126] pci 0000:00:1c.7:   bridge window [mem 0xc2000000-0xc28fffff]
[    1.130131] pci 0000:00:1c.7:   bridge window [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.131207] pci 0000:0c:00.0: [1912:0013] type 01 class 0x060400
[    1.133905] pci 0000:0c:00.0: PME# supported from D0 D3hot D3cold
[    1.134850] pci 0000:0c:01.0: [1912:0013] type 01 class 0x060400
[    1.137703] pci 0000:0c:01.0: PME# supported from D0 D3hot D3cold
[    1.139959] pci 0000:0b:00.0: PCI bridge to [bus 0c-0f]
[    1.140152] pci 0000:0b:00.0:   bridge window [mem 0xc2000000-0xc28fffff]
[    1.140277] pci 0000:0b:00.0:   bridge window [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.141387] pci 0000:0d:00.0: [1912:0012] type 01 class 0x060400
[    1.144857] pci 0000:0c:00.0: PCI bridge to [bus 0d-0e]
[    1.145073] pci 0000:0c:00.0:   bridge window [mem 0xc2000000-0xc28fffff]
[    1.145217] pci 0000:0c:00.0:   bridge window [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.146196] pci 0000:0e:00.0: [102b:0534] type 00 class 0x030000
[    1.146642] pci 0000:0e:00.0: reg 0x10: [mem 0x9f000000-0x9fffffff pref]
[    1.146903] pci 0000:0e:00.0: reg 0x14: [mem 0xc2800000-0xc2803fff]
[    1.147164] pci 0000:0e:00.0: reg 0x18: [mem 0xc2000000-0xc27fffff]
[    1.151166] pci 0000:0d:00.0: PCI bridge to [bus 0e]
[    1.151389] pci 0000:0d:00.0:   bridge window [mem 0xc2000000-0xc28fffff]
[    1.151534] pci 0000:0d:00.0:   bridge window [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.152683] pci 0000:0c:01.0: PCI bridge to [bus 0f]
[    1.154081] pci 0000:00:1e.0: PCI bridge to [bus 10] (subtractive decode)
[    1.154090] pci 0000:00:1e.0:   bridge window [io  0x0000-0x03af window] (subtractive decode)
[    1.154091] pci 0000:00:1e.0:   bridge window [io  0x03e0-0x0cf7 window] (subtractive decode)
[    1.154092] pci 0000:00:1e.0:   bridge window [io  0x03b0-0x03df window] (subtractive decode)
[    1.154094] pci 0000:00:1e.0:   bridge window [io  0x0d00-0x9fff window] (subtractive decode)
[    1.154095] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff window] (subtractive decode)
[    1.154096] pci 0000:00:1e.0:   bridge window [mem 0x000c0000-0x000dffff window] (subtractive decode)
[    1.154097] pci 0000:00:1e.0:   bridge window [mem 0xfed08000-0xfed08fff window] (subtractive decode)
[    1.154098] pci 0000:00:1e.0:   bridge window [mem 0xfed0e000-0xfed0ffff window] (subtractive decode)
[    1.154100] pci 0000:00:1e.0:   bridge window [mem 0x80000000-0xc3ffffff window] (subtractive decode)
[    1.154101] pci 0000:00:1e.0:   bridge window [mem 0x380000000000-0x381fffffffff window] (subtractive decode)
[    1.154141] pci_bus 0000:00: on NUMA node 0
[    1.154843] ACPI: PCI Root Bridge [UNC0] (domain 0000 [bus 7f])
[    1.154846] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    1.154873] acpi PNP0A03:00: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
[    1.154874] acpi PNP0A03:00: FADT indicates ASPM is unsupported, using BIOS configuration
[    1.154939] PCI host bridge to bus 0000:7f
[    1.154940] pci_bus 0000:7f: root bus resource [bus 7f]
[    1.154949] pci 0000:7f:08.0: [8086:3c80] type 00 class 0x088000
[    1.155004] pci 0000:7f:08.3: [8086:3c83] type 00 class 0x088000
[    1.155067] pci 0000:7f:08.4: [8086:3c84] type 00 class 0x088000
[    1.155135] pci 0000:7f:09.0: [8086:3c90] type 00 class 0x088000
[    1.155185] pci 0000:7f:09.3: [8086:3c93] type 00 class 0x088000
[    1.155245] pci 0000:7f:09.4: [8086:3c94] type 00 class 0x088000
[    1.155312] pci 0000:7f:0a.0: [8086:3cc0] type 00 class 0x088000
[    1.155355] pci 0000:7f:0a.1: [8086:3cc1] type 00 class 0x088000
[    1.155399] pci 0000:7f:0a.2: [8086:3cc2] type 00 class 0x088000
[    1.155443] pci 0000:7f:0a.3: [8086:3cd0] type 00 class 0x088000
[    1.155488] pci 0000:7f:0b.0: [8086:3ce0] type 00 class 0x088000
[    1.155528] pci 0000:7f:0b.3: [8086:3ce3] type 00 class 0x088000
[    1.155571] pci 0000:7f:0c.0: [8086:3ce8] type 00 class 0x088000
[    1.155611] pci 0000:7f:0c.1: [8086:3ce8] type 00 class 0x088000
[    1.155654] pci 0000:7f:0c.6: [8086:3cf4] type 00 class 0x088000
[    1.155694] pci 0000:7f:0c.7: [8086:3cf6] type 00 class 0x088000
[    1.155735] pci 0000:7f:0d.0: [8086:3ce8] type 00 class 0x088000
[    1.155777] pci 0000:7f:0d.1: [8086:3ce8] type 00 class 0x088000
[    1.155822] pci 0000:7f:0d.6: [8086:3cf5] type 00 class 0x088000
[    1.155863] pci 0000:7f:0e.0: [8086:3ca0] type 00 class 0x088000
[    1.155906] pci 0000:7f:0e.1: [8086:3c46] type 00 class 0x110100
[    1.155954] pci 0000:7f:0f.0: [8086:3ca8] type 00 class 0x088000
[    1.156011] pci 0000:7f:0f.1: [8086:3c71] type 00 class 0x088000
[    1.156070] pci 0000:7f:0f.2: [8086:3caa] type 00 class 0x088000
[    1.156126] pci 0000:7f:0f.3: [8086:3cab] type 00 class 0x088000
[    1.156184] pci 0000:7f:0f.4: [8086:3cac] type 00 class 0x088000
[    1.156240] pci 0000:7f:0f.5: [8086:3cad] type 00 class 0x088000
[    1.156297] pci 0000:7f:0f.6: [8086:3cae] type 00 class 0x088000
[    1.156349] pci 0000:7f:10.0: [8086:3cb0] type 00 class 0x088000
[    1.156409] pci 0000:7f:10.1: [8086:3cb1] type 00 class 0x088000
[    1.156470] pci 0000:7f:10.2: [8086:3cb2] type 00 class 0x088000
[    1.156530] pci 0000:7f:10.3: [8086:3cb3] type 00 class 0x088000
[    1.156589] pci 0000:7f:10.4: [8086:3cb4] type 00 class 0x088000
[    1.156655] pci 0000:7f:10.5: [8086:3cb5] type 00 class 0x088000
[    1.156715] pci 0000:7f:10.6: [8086:3cb6] type 00 class 0x088000
[    1.156775] pci 0000:7f:10.7: [8086:3cb7] type 00 class 0x088000
[    1.156834] pci 0000:7f:11.0: [8086:3cb8] type 00 class 0x088000
[    1.156887] pci 0000:7f:13.0: [8086:3ce4] type 00 class 0x088000
[    1.156930] pci 0000:7f:13.1: [8086:3c43] type 00 class 0x110100
[    1.156975] pci 0000:7f:13.4: [8086:3ce6] type 00 class 0x110100
[    1.157019] pci 0000:7f:13.5: [8086:3c44] type 00 class 0x110100
[    1.157063] pci 0000:7f:13.6: [8086:3c45] type 00 class 0x088000
[    1.157113] pci_bus 0000:7f: on NUMA node 0
[    1.157304] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 80-fe])
[    1.157307] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    1.157477] acpi PNP0A08:01: _OSC: platform does not support [PME AER]
[    1.157630] acpi PNP0A08:01: _OSC: OS now controls [PCIeHotplug PCIeCapability]
[    1.157631] acpi PNP0A08:01: FADT indicates ASPM is unsupported, using BIOS configuration
[    1.157858] PCI host bridge to bus 0000:80
[    1.157860] pci_bus 0000:80: root bus resource [io  0xa000-0xffff window]
[    1.157861] pci_bus 0000:80: root bus resource [mem 0xc4000000-0xfbffffff window]
[    1.157862] pci_bus 0000:80: root bus resource [mem 0x382000000000-0x383fffffffff window]
[    1.157864] pci_bus 0000:80: root bus resource [bus 80-fe]
[    1.157877] pci 0000:80:00.0: [8086:3c01] type 01 class 0x060400
[    1.157962] pci 0000:80:00.0: PME# supported from D0 D3hot D3cold
[    1.158008] pci 0000:80:00.0: System wakeup disabled by ACPI
[    1.158050] pci 0000:80:01.0: [8086:3c02] type 01 class 0x060400
[    1.158136] pci 0000:80:01.0: PME# supported from D0 D3hot D3cold
[    1.158182] pci 0000:80:01.0: System wakeup disabled by ACPI
[    1.158225] pci 0000:80:02.0: [8086:3c04] type 01 class 0x060400
[    1.158311] pci 0000:80:02.0: PME# supported from D0 D3hot D3cold
[    1.158356] pci 0000:80:02.0: System wakeup disabled by ACPI
[    1.158399] pci 0000:80:03.0: [8086:3c08] type 01 class 0x060400
[    1.158486] pci 0000:80:03.0: PME# supported from D0 D3hot D3cold
[    1.158531] pci 0000:80:03.0: System wakeup disabled by ACPI
[    1.158573] pci 0000:80:04.0: [8086:3c20] type 00 class 0x088000
[    1.158589] pci 0000:80:04.0: reg 0x10: [mem 0x383ffff1c000-0x383ffff1ffff 64bit]
[    1.158708] pci 0000:80:04.1: [8086:3c21] type 00 class 0x088000
[    1.158724] pci 0000:80:04.1: reg 0x10: [mem 0x383ffff18000-0x383ffff1bfff 64bit]
[    1.158842] pci 0000:80:04.2: [8086:3c22] type 00 class 0x088000
[    1.158858] pci 0000:80:04.2: reg 0x10: [mem 0x383ffff14000-0x383ffff17fff 64bit]
[    1.158982] pci 0000:80:04.3: [8086:3c23] type 00 class 0x088000
[    1.159000] pci 0000:80:04.3: reg 0x10: [mem 0x383ffff10000-0x383ffff13fff 64bit]
[    1.159118] pci 0000:80:04.4: [8086:3c24] type 00 class 0x088000
[    1.159134] pci 0000:80:04.4: reg 0x10: [mem 0x383ffff0c000-0x383ffff0ffff 64bit]
[    1.159252] pci 0000:80:04.5: [8086:3c25] type 00 class 0x088000
[    1.159268] pci 0000:80:04.5: reg 0x10: [mem 0x383ffff08000-0x383ffff0bfff 64bit]
[    1.159387] pci 0000:80:04.6: [8086:3c26] type 00 class 0x088000
[    1.159403] pci 0000:80:04.6: reg 0x10: [mem 0x383ffff04000-0x383ffff07fff 64bit]
[    1.159519] pci 0000:80:04.7: [8086:3c27] type 00 class 0x088000
[    1.159535] pci 0000:80:04.7: reg 0x10: [mem 0x383ffff00000-0x383ffff03fff 64bit]
[    1.159653] pci 0000:80:05.0: [8086:3c28] type 00 class 0x088000
[    1.159765] pci 0000:80:05.2: [8086:3c2a] type 00 class 0x088000
[    1.159875] pci 0000:80:05.4: [8086:3c2c] type 00 class 0x080020
[    1.159887] pci 0000:80:05.4: reg 0x10: [mem 0xfbf00000-0xfbf00fff]
[    1.160041] pci 0000:80:00.0: PCI bridge to [bus 81]
[    1.160090] pci 0000:80:01.0: PCI bridge to [bus 82]
[    1.160136] pci 0000:80:02.0: PCI bridge to [bus 83]
[    1.160182] pci 0000:80:03.0: PCI bridge to [bus 84]
[    1.160215] pci_bus 0000:80: on NUMA node 1
[    1.160293] ACPI: PCI Root Bridge [UNC1] (domain 0000 [bus ff])
[    1.160296] acpi PNP0A03:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    1.160322] acpi PNP0A03:01: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
[    1.160323] acpi PNP0A03:01: FADT indicates ASPM is unsupported, using BIOS configuration
[    1.160383] PCI host bridge to bus 0000:ff
[    1.160385] pci_bus 0000:ff: root bus resource [bus ff]
[    1.160394] pci 0000:ff:08.0: [8086:3c80] type 00 class 0x088000
[    1.160455] pci 0000:ff:08.3: [8086:3c83] type 00 class 0x088000
[    1.160525] pci 0000:ff:08.4: [8086:3c84] type 00 class 0x088000
[    1.160600] pci 0000:ff:09.0: [8086:3c90] type 00 class 0x088000
[    1.160657] pci 0000:ff:09.3: [8086:3c93] type 00 class 0x088000
[    1.160723] pci 0000:ff:09.4: [8086:3c94] type 00 class 0x088000
[    1.160798] pci 0000:ff:0a.0: [8086:3cc0] type 00 class 0x088000
[    1.160845] pci 0000:ff:0a.1: [8086:3cc1] type 00 class 0x088000
[    1.160892] pci 0000:ff:0a.2: [8086:3cc2] type 00 class 0x088000
[    1.160938] pci 0000:ff:0a.3: [8086:3cd0] type 00 class 0x088000
[    1.160988] pci 0000:ff:0b.0: [8086:3ce0] type 00 class 0x088000
[    1.161034] pci 0000:ff:0b.3: [8086:3ce3] type 00 class 0x088000
[    1.161083] pci 0000:ff:0c.0: [8086:3ce8] type 00 class 0x088000
[    1.161129] pci 0000:ff:0c.1: [8086:3ce8] type 00 class 0x088000
[    1.161178] pci 0000:ff:0c.6: [8086:3cf4] type 00 class 0x088000
[    1.161226] pci 0000:ff:0c.7: [8086:3cf6] type 00 class 0x088000
[    1.161273] pci 0000:ff:0d.0: [8086:3ce8] type 00 class 0x088000
[    1.161319] pci 0000:ff:0d.1: [8086:3ce8] type 00 class 0x088000
[    1.161368] pci 0000:ff:0d.6: [8086:3cf5] type 00 class 0x088000
[    1.161417] pci 0000:ff:0e.0: [8086:3ca0] type 00 class 0x088000
[    1.161471] pci 0000:ff:0e.1: [8086:3c46] type 00 class 0x110100
[    1.161531] pci 0000:ff:0f.0: [8086:3ca8] type 00 class 0x088000
[    1.161599] pci 0000:ff:0f.1: [8086:3c71] type 00 class 0x088000
[    1.161668] pci 0000:ff:0f.2: [8086:3caa] type 00 class 0x088000
[    1.161734] pci 0000:ff:0f.3: [8086:3cab] type 00 class 0x088000
[    1.161804] pci 0000:ff:0f.4: [8086:3cac] type 00 class 0x088000
[    1.161873] pci 0000:ff:0f.5: [8086:3cad] type 00 class 0x088000
[    1.161942] pci 0000:ff:0f.6: [8086:3cae] type 00 class 0x088000
[    1.161996] pci 0000:ff:10.0: [8086:3cb0] type 00 class 0x088000
[    1.162065] pci 0000:ff:10.1: [8086:3cb1] type 00 class 0x088000
[    1.162131] pci 0000:ff:10.2: [8086:3cb2] type 00 class 0x088000
[    1.162199] pci 0000:ff:10.3: [8086:3cb3] type 00 class 0x088000
[    1.162266] pci 0000:ff:10.4: [8086:3cb4] type 00 class 0x088000
[    1.162335] pci 0000:ff:10.5: [8086:3cb5] type 00 class 0x088000
[    1.162400] pci 0000:ff:10.6: [8086:3cb6] type 00 class 0x088000
[    1.162467] pci 0000:ff:10.7: [8086:3cb7] type 00 class 0x088000
[    1.162531] pci 0000:ff:11.0: [8086:3cb8] type 00 class 0x088000
[    1.162592] pci 0000:ff:13.0: [8086:3ce4] type 00 class 0x088000
[    1.162642] pci 0000:ff:13.1: [8086:3c43] type 00 class 0x110100
[    1.162695] pci 0000:ff:13.4: [8086:3ce6] type 00 class 0x110100
[    1.162746] pci 0000:ff:13.5: [8086:3c44] type 00 class 0x110100
[    1.162798] pci 0000:ff:13.6: [8086:3c45] type 00 class 0x088000
[    1.162857] pci_bus 0000:ff: on NUMA node 1
[    1.162954] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    1.163010] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    1.163064] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 10 11 12 14 15)
[    1.163117] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 10 *11 12 14 15)
[    1.163169] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0
[    1.163222] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0
[    1.163274] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    1.163327] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    1.165856] ACPI: Enabled 1 GPEs in block 00 to 3F
[    1.166392] pci 0000:0e:00.0: vgaarb: setting as boot VGA device
[    1.166394] pci 0000:0e:00.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    1.166407] pci 0000:0e:00.0: vgaarb: bridge control possible
[    1.166408] vgaarb: loaded
[    1.166527] SCSI subsystem initialized
[    1.166581] libata version 3.00 loaded.
[    1.166586] ACPI: bus type USB registered
[    1.166613] usbcore: registered new interface driver usbfs
[    1.166622] usbcore: registered new interface driver hub
[    1.166642] usbcore: registered new device driver usb
[    1.166668] pps_core: LinuxPPS API ver. 1 registered
[    1.166669] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.166672] PTP clock support registered
[    1.166743] EDAC MC: Ver: 3.0.0
[    1.167918] wmi: Mapper loaded
[    1.167924] PCI: Using ACPI for IRQ routing
[    1.172238] PCI: pci_cache_line_size set to 64 bytes
[    1.173105] e820: reserve RAM buffer [mem 0x0008dc00-0x0008ffff]
[    1.173107] e820: reserve RAM buffer [mem 0x7dd15000-0x7fffffff]
[    1.173302] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    1.173307] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    1.175362] clocksource: Switched to clocksource hpet
[    1.183480] VFS: Disk quotas dquot_6.6.0
[    1.183515] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.183574] FS-Cache: Loaded
[    1.183653] pnp: PnP ACPI init
[    1.183761] system 00:00: [mem 0xfc000000-0xfcffffff] has been reserved
[    1.183763] system 00:00: [mem 0xfd000000-0xfdffffff] has been reserved
[    1.183764] system 00:00: [mem 0xfe000000-0xfeafffff] has been reserved
[    1.183765] system 00:00: [mem 0xfeb00000-0xfebfffff] has been reserved
[    1.183768] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.183891] system 00:01: [mem 0xc3ffc000-0xc3ffdfff] could not be reserved
[    1.183893] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.183925] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.184031] system 00:03: [io  0x04d0-0x04d1] has been reserved
[    1.184033] system 00:03: [mem 0x00000400-0x000004ff] could not be reserved
[    1.184035] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.184164] system 00:04: [io  0x0a00-0x0a07] has been reserved
[    1.184167] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.184240] pnp 00:05: Plug and Play ACPI device, IDs PNP0f03 PNP0f13 (active)
[    1.184417] system 00:06: [io  0x0370-0x0371] has been reserved
[    1.184418] system 00:06: [io  0x0a00-0x0a07] has been reserved
[    1.184420] system 00:06: [io  0x0a10-0x0a3f] has been reserved
[    1.184422] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.184605] pnp 00:07: [dma 0 disabled]
[    1.184654] pnp 00:07: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.184825] pnp 00:08: [dma 0 disabled]
[    1.184870] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.185101] system 00:09: [io  0x0400-0x0453] has been reserved
[    1.185103] system 00:09: [io  0x0458-0x047f] has been reserved
[    1.185105] system 00:09: [io  0x1180-0x119f] has been reserved
[    1.185106] system 00:09: [io  0x0500-0x057f] has been reserved
[    1.185108] system 00:09: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    1.185110] system 00:09: [mem 0xfec00000-0xfecfffff] could not be reserved
[    1.185111] system 00:09: [mem 0xff000000-0xffffffff] has been reserved
[    1.185114] system 00:09: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.185218] system 00:0a: [io  0x0454-0x0457] has been reserved
[    1.185221] system 00:0a: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    1.185396] system 00:0b: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.185504] system 00:0c: [mem 0xfbffe000-0xfbffffff] could not be reserved
[    1.185506] system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.185693] system 00:0d: [mem 0x00000000-0x0009ffff] could not be reserved
[    1.185695] system 00:0d: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.185930] pnp: PnP ACPI: found 14 devices
[    1.192162] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    1.192340] pci 0000:04:00.0: bridge window [io  0x1000-0x0fff] to [bus 05] add_size 1000
[    1.192494] pci 0000:04:01.0: bridge window [io  0x1000-0x0fff] to [bus 06] add_size 1000
[    1.192496] pci 0000:04:01.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 06] add_size 200000 add_align 100000
[    1.192652] pci 0000:04:02.0: bridge window [io  0x1000-0x0fff] to [bus 07] add_size 1000
[    1.192654] pci 0000:04:02.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 07] add_size 200000 add_align 100000
[    1.192833] pci 0000:03:00.0: bridge window [io  0x1000-0x0fff] to [bus 04-07] add_size 3000
[    1.192840] pci 0000:00:03.0: bridge window [io  0x1000-0x0fff] to [bus 03-07] add_size 3000
[    1.193806] pci 0000:00:03.0: BAR 13: assigned [io  0x2000-0x4fff]
[    1.193808] pci 0000:00:01.0: PCI bridge to [bus 01]
[    1.193817] pci 0000:00:02.0: PCI bridge to [bus 02]
[    1.193827] pci 0000:03:00.0: BAR 13: assigned [io  0x2000-0x4fff]
[    1.193833] pci 0000:04:01.0: BAR 15: no space for [mem size 0x00200000 64bit pref]
[    1.193834] pci 0000:04:01.0: BAR 15: failed to assign [mem size 0x00200000 64bit pref]
[    1.193837] pci 0000:04:02.0: BAR 15: no space for [mem size 0x00200000 64bit pref]
[    1.193838] pci 0000:04:02.0: BAR 15: failed to assign [mem size 0x00200000 64bit pref]
[    1.193839] pci 0000:04:00.0: BAR 13: assigned [io  0x2000-0x2fff]
[    1.193841] pci 0000:04:01.0: BAR 13: assigned [io  0x3000-0x3fff]
[    1.193842] pci 0000:04:02.0: BAR 13: assigned [io  0x4000-0x4fff]
[    1.193845] pci 0000:04:02.0: BAR 15: no space for [mem size 0x00200000 64bit pref]
[    1.193847] pci 0000:04:02.0: BAR 15: failed to assign [mem size 0x00200000 64bit pref]
[    1.193849] pci 0000:04:01.0: BAR 15: no space for [mem size 0x00200000 64bit pref]
[    1.193850] pci 0000:04:01.0: BAR 15: failed to assign [mem size 0x00200000 64bit pref]
[    1.193851] pci 0000:04:00.0: PCI bridge to [bus 05]
[    1.193863] pci 0000:04:00.0:   bridge window [io  0x2000-0x2fff]
[    1.193916] pci 0000:04:00.0:   bridge window [mem 0xc1f00000-0xc1ffffff]
[    1.194019] pci 0000:04:00.0:   bridge window [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.194189] pci 0000:04:01.0: PCI bridge to [bus 06]
[    1.194202] pci 0000:04:01.0:   bridge window [io  0x3000-0x3fff]
[    1.194254] pci 0000:04:01.0:   bridge window [mem 0xc1e00000-0xc1efffff]
[    1.194527] pci 0000:04:02.0: PCI bridge to [bus 07]
[    1.194539] pci 0000:04:02.0:   bridge window [io  0x4000-0x4fff]
[    1.194592] pci 0000:04:02.0:   bridge window [mem 0xa0000000-0xc1cfffff]
[    1.194864] pci 0000:03:00.0: PCI bridge to [bus 04-07]
[    1.194877] pci 0000:03:00.0:   bridge window [io  0x2000-0x4fff]
[    1.194925] pci 0000:03:00.0:   bridge window [mem 0xa0000000-0xc1ffffff]
[    1.195051] pci 0000:03:00.0:   bridge window [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.195256] pci 0000:00:03.0: PCI bridge to [bus 03-07]
[    1.195258] pci 0000:00:03.0:   bridge window [io  0x2000-0x4fff]
[    1.195262] pci 0000:00:03.0:   bridge window [mem 0xa0000000-0xc1ffffff]
[    1.195264] pci 0000:00:03.0:   bridge window [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.195269] pci 0000:00:11.0: PCI bridge to [bus 08]
[    1.195271] pci 0000:00:11.0:   bridge window [io  0x8000-0x8fff]
[    1.195279] pci 0000:00:11.0:   bridge window [mem 0x381fc0000000-0x381fc04fffff 64bit pref]
[    1.195285] pci 0000:00:1c.0: PCI bridge to [bus 09-0a]
[    1.195287] pci 0000:00:1c.0:   bridge window [io  0x7000-0x7fff]
[    1.195291] pci 0000:00:1c.0:   bridge window [mem 0xc2900000-0xc29fffff]
[    1.195294] pci 0000:00:1c.0:   bridge window [mem 0x381fc0600000-0x381fc06fffff 64bit pref]
[    1.195300] pci 0000:0d:00.0: PCI bridge to [bus 0e]
[    1.195440] pci 0000:0d:00.0:   bridge window [mem 0xc2000000-0xc28fffff]
[    1.195533] pci 0000:0d:00.0:   bridge window [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.195728] pci 0000:0c:00.0: PCI bridge to [bus 0d-0e]
[    1.195872] pci 0000:0c:00.0:   bridge window [mem 0xc2000000-0xc28fffff]
[    1.195966] pci 0000:0c:00.0:   bridge window [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.196160] pci 0000:0c:01.0: PCI bridge to [bus 0f]
[    1.196662] pci 0000:0b:00.0: PCI bridge to [bus 0c-0f]
[    1.196788] pci 0000:0b:00.0:   bridge window [mem 0xc2000000-0xc28fffff]
[    1.196873] pci 0000:0b:00.0:   bridge window [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.197112] pci 0000:00:1c.7: PCI bridge to [bus 0b-0f]
[    1.197116] pci 0000:00:1c.7:   bridge window [mem 0xc2000000-0xc28fffff]
[    1.197120] pci 0000:00:1c.7:   bridge window [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.197125] pci 0000:00:1e.0: PCI bridge to [bus 10]
[    1.197135] pci_bus 0000:00: resource 4 [io  0x0000-0x03af window]
[    1.197137] pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7 window]
[    1.197138] pci_bus 0000:00: resource 6 [io  0x03b0-0x03df window]
[    1.197139] pci_bus 0000:00: resource 7 [io  0x0d00-0x9fff window]
[    1.197140] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff window]
[    1.197141] pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff window]
[    1.197143] pci_bus 0000:00: resource 10 [mem 0xfed08000-0xfed08fff window]
[    1.197144] pci_bus 0000:00: resource 11 [mem 0xfed0e000-0xfed0ffff window]
[    1.197145] pci_bus 0000:00: resource 12 [mem 0x80000000-0xc3ffffff window]
[    1.197146] pci_bus 0000:00: resource 13 [mem 0x380000000000-0x381fffffffff window]
[    1.197147] pci_bus 0000:03: resource 0 [io  0x2000-0x4fff]
[    1.197149] pci_bus 0000:03: resource 1 [mem 0xa0000000-0xc1ffffff]
[    1.197150] pci_bus 0000:03: resource 2 [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.197151] pci_bus 0000:04: resource 0 [io  0x2000-0x4fff]
[    1.197152] pci_bus 0000:04: resource 1 [mem 0xa0000000-0xc1ffffff]
[    1.197153] pci_bus 0000:04: resource 2 [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.197154] pci_bus 0000:05: resource 0 [io  0x2000-0x2fff]
[    1.197155] pci_bus 0000:05: resource 1 [mem 0xc1f00000-0xc1ffffff]
[    1.197156] pci_bus 0000:05: resource 2 [mem 0x381f80000000-0x381fbfffffff 64bit pref]
[    1.197157] pci_bus 0000:06: resource 0 [io  0x3000-0x3fff]
[    1.197158] pci_bus 0000:06: resource 1 [mem 0xc1e00000-0xc1efffff]
[    1.197160] pci_bus 0000:07: resource 0 [io  0x4000-0x4fff]
[    1.197161] pci_bus 0000:07: resource 1 [mem 0xa0000000-0xc1cfffff]
[    1.197162] pci_bus 0000:08: resource 0 [io  0x8000-0x8fff]
[    1.197163] pci_bus 0000:08: resource 2 [mem 0x381fc0000000-0x381fc04fffff 64bit pref]
[    1.197164] pci_bus 0000:09: resource 0 [io  0x7000-0x7fff]
[    1.197165] pci_bus 0000:09: resource 1 [mem 0xc2900000-0xc29fffff]
[    1.197167] pci_bus 0000:09: resource 2 [mem 0x381fc0600000-0x381fc06fffff 64bit pref]
[    1.197168] pci_bus 0000:0b: resource 1 [mem 0xc2000000-0xc28fffff]
[    1.197169] pci_bus 0000:0b: resource 2 [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.197170] pci_bus 0000:0c: resource 1 [mem 0xc2000000-0xc28fffff]
[    1.197171] pci_bus 0000:0c: resource 2 [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.197172] pci_bus 0000:0d: resource 1 [mem 0xc2000000-0xc28fffff]
[    1.197173] pci_bus 0000:0d: resource 2 [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.197174] pci_bus 0000:0e: resource 1 [mem 0xc2000000-0xc28fffff]
[    1.197175] pci_bus 0000:0e: resource 2 [mem 0x9f000000-0x9fffffff 64bit pref]
[    1.197177] pci_bus 0000:10: resource 4 [io  0x0000-0x03af window]
[    1.197178] pci_bus 0000:10: resource 5 [io  0x03e0-0x0cf7 window]
[    1.197179] pci_bus 0000:10: resource 6 [io  0x03b0-0x03df window]
[    1.197180] pci_bus 0000:10: resource 7 [io  0x0d00-0x9fff window]
[    1.197181] pci_bus 0000:10: resource 8 [mem 0x000a0000-0x000bffff window]
[    1.197182] pci_bus 0000:10: resource 9 [mem 0x000c0000-0x000dffff window]
[    1.197183] pci_bus 0000:10: resource 10 [mem 0xfed08000-0xfed08fff window]
[    1.197185] pci_bus 0000:10: resource 11 [mem 0xfed0e000-0xfed0ffff window]
[    1.197186] pci_bus 0000:10: resource 12 [mem 0x80000000-0xc3ffffff window]
[    1.197187] pci_bus 0000:10: resource 13 [mem 0x380000000000-0x381fffffffff window]
[    1.197273] pci 0000:80:00.0: PCI bridge to [bus 81]
[    1.197282] pci 0000:80:01.0: PCI bridge to [bus 82]
[    1.197291] pci 0000:80:02.0: PCI bridge to [bus 83]
[    1.197300] pci 0000:80:03.0: PCI bridge to [bus 84]
[    1.197310] pci_bus 0000:80: resource 4 [io  0xa000-0xffff window]
[    1.197311] pci_bus 0000:80: resource 5 [mem 0xc4000000-0xfbffffff window]
[    1.197312] pci_bus 0000:80: resource 6 [mem 0x382000000000-0x383fffffffff window]
[    1.197382] NET: Registered protocol family 2
[    1.197578] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    1.197806] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    1.197963] TCP: Hash tables configured (established 131072 bind 65536)
[    1.198024] UDP hash table entries: 8192 (order: 6, 262144 bytes)
[    1.198084] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
[    1.198185] NET: Registered protocol family 1
[    1.198327] RPC: Registered named UNIX socket transport module.
[    1.198328] RPC: Registered udp transport module.
[    1.198328] RPC: Registered tcp transport module.
[    1.198329] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.244018] pci 0000:0e:00.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    1.244211] PCI: CLS 64 bytes, default 64
[    1.244266] Unpacking initramfs...
[    1.341491] Freeing initrd memory: 5784K
[    1.341626] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.341628] software IO TLB [mem 0x79d15000-0x7dd15000] (64MB) mapped at [ffff880079d15000-ffff88007dd14fff]
[    1.341784] RAPL PMU: API unit is 2^-32 Joules, 3 fixed counters, 163840 ms ovfl timer
[    1.341785] RAPL PMU: hw unit of domain pp0-core 2^-16 Joules
[    1.341786] RAPL PMU: hw unit of domain package 2^-16 Joules
[    1.341787] RAPL PMU: hw unit of domain dram 2^-16 Joules
[    1.345675] audit: initializing netlink subsys (disabled)
[    1.345755] audit: type=2000 audit(1495042110.190:1): state=initialized audit_enabled=0 res=1
[    1.346585] workingset: timestamp_bits=40 max_order=22 bucket_order=0
[    1.346968] FS-Cache: Netfs 'nfs' registered for caching
[    1.347088] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    1.347187] fuse init (API version 7.26)
[    1.348082] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 245)
[    1.348083] io scheduler noop registered
[    1.348084] io scheduler deadline registered
[    1.348098] io scheduler cfq registered (default)
[    1.348099] io scheduler mq-deadline registered
[    1.348100] io scheduler kyber registered
[    1.362589] pciehp 0000:04:00.0:pcie204: Slot #1 AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise- Interlock- NoCompl+ LLActRep+
[    1.362719] pciehp 0000:04:01.0:pcie204: Slot #2 AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise- Interlock- NoCompl+ LLActRep+
[    1.362839] pciehp 0000:04:02.0:pcie204: Slot #3 AttnBtn+ PwrCtrl+ MRL- AttnInd+ PwrInd+ HotPlug+ Surprise- Interlock- NoCompl+ LLActRep+
[    1.363125] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    1.363139] intel_idle: MWAIT substates: 0x21120
[    1.363140] intel_idle: v0.4.1 model 0x2D
[    1.363477] intel_idle: lapic_timer_reliable_states 0xffffffff
[    1.363484] ipmi message handler version 39.2
[    1.363486] ipmi device interface
[    1.363506] ipmi_si IPI0001:00: ipmi_si: probing via ACPI
[    1.363525] ipmi_si IPI0001:00: [io  0x0ca2] regsize 1 spacing 1 irq 0
[    1.363526] ipmi_si: Adding ACPI-specified kcs state machine
[    1.363531] IPMI System Interface driver.
[    1.363554] ipmi_si: probing via SMBIOS
[    1.363556] ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
[    1.363557] ipmi_si: SMBIOS-specified kcs state machine: duplicate
[    1.363558] ipmi_si: probing via SPMI
[    1.363559] ipmi_si: SPMI: io 0xca2 regsize 1 spacing 1 irq 0
[    1.363560] ipmi_si: SPMI-specified kcs state machine: duplicate
[    1.363562] ipmi_si: Trying ACPI-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    1.721571] ipmi_si IPI0001:00: Found new BMC (man_id: 0x002a7c, prod_id: 0xaabb, dev_id: 0x20)
[    1.721672] ipmi_si IPI0001:00: IPMI kcs interface initialized
[    1.733191] IPMI Watchdog: driver initialized
[    1.733192] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    1.738042] IPMI poweroff: ATCA Detect mfg 0x2A7C prod 0xAABB
[    1.738048] IPMI poweroff: Found a chassis style poweroff function
[    1.738121] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    1.738135] ACPI: Power Button [PWRB]
[    1.738192] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    1.738199] ACPI: Power Button [PWRF]
[    1.749077] ERST: Error Record Serialization Table (ERST) support is initialized.
[    1.749079] pstore: using zlib compression
[    1.749083] pstore: Registered erst as persistent store backend
[    1.749202] GHES: APEI firmware first mode is enabled by WHEA _OSC.
[    1.749219] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    1.944895] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.965335] 00:07: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    1.985788] 00:08: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
[    1.986316] Linux agpgart interface v0.103
[    1.990419] loop: module loaded
[    1.990663] isci: Intel(R) C600 SAS Controller Driver - version 1.2.0
[    1.990678] isci 0000:08:00.0: driver configured for rev: 6 silicon
[    1.990684] isci 0000:08:00.0: OEM parameter table found in OROM
[    1.990686] isci 0000:08:00.0: OEM SAS parameters (version: 1.0) loaded (platform)
[    1.990825] nd_pmem namespace0.0: unable to guarantee persistence of writes
[    1.991002] isci 0000:08:00.0: SCU controller 0: phy 3-0 cables: {short, short, short, short}
[    1.993305] scsi host0: isci
[    2.011389] nvme nvme0: pci function 0000:05:00.0
[    2.011433] nvme nvme1: pci function 0000:06:00.0
[    2.014190] ahci 0000:00:1f.2: version 3.0
[    2.018652] pmem0: detected capacity change from 0 to 2147483648
[    2.024613] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x3f impl SATA mode
[    2.024616] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems apst 
[    2.084229] scsi host1: ahci
[    2.084663] scsi host2: ahci
[    2.085126] scsi host3: ahci
[    2.085481] scsi host4: ahci
[    2.085681] scsi host5: ahci
[    2.085849] scsi host6: ahci
[    2.085923] ata1: SATA max UDMA/133 abar m2048@0xc2a00000 port 0xc2a00100 irq 60
[    2.085925] ata2: SATA max UDMA/133 abar m2048@0xc2a00000 port 0xc2a00180 irq 60
[    2.085927] ata3: SATA max UDMA/133 abar m2048@0xc2a00000 port 0xc2a00200 irq 60
[    2.085928] ata4: SATA max UDMA/133 abar m2048@0xc2a00000 port 0xc2a00280 irq 60
[    2.085930] ata5: SATA max UDMA/133 abar m2048@0xc2a00000 port 0xc2a00300 irq 60
[    2.085931] ata6: SATA max UDMA/133 abar m2048@0xc2a00000 port 0xc2a00380 irq 60
[    2.086215] Rounding down aligned max_sectors from 4294967295 to 4294967288
[    2.086407] Chelsio T4/T5/T6 Network Driver - version 2.0.0-ko
[    2.191426] cxgb4 0000:07:00.4: Coming up as MASTER: Initializing adapter
[    2.363435] tsc: Refined TSC clocksource calibration: 2399.999 MHz
[    2.363443] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2298364cab5, max_idle_ns: 440795214892 ns
[    2.398529] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    2.398569] ata2: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    2.398601] ata3: SATA link down (SStatus 0 SControl 300)
[    2.399720] ata2.00: ATA-8: WDC WD5003ABYZ-011FA0, 01.01S03, max UDMA/133
[    2.399724] ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    2.399916] ata1.00: ATA-9: INTEL SSDSC2BW480A3F, 400i, max UDMA/133
[    2.399919] ata1.00: 937703088 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    2.401138] ata2.00: configured for UDMA/133
[    2.402496] ata6: SATA link down (SStatus 0 SControl 300)
[    2.402523] ata5: SATA link down (SStatus 0 SControl 300)
[    2.402542] ata4: SATA link down (SStatus 0 SControl 300)
[    2.409872] ata1.00: configured for UDMA/133
[    2.907460] cxgb4 0000:07:00.4: Direct firmware load for cxgb4/t6-config.txt failed with error -2
[    3.355695] sas: phy-0:3 added to port-0:0, phy_mask:0x8 (       12345678c)
[    3.355710] sas: DOING DISCOVERY on port 0, pid:5
[    3.355805] sas: DONE DISCOVERY on port 0, pid:5, result:0
[    3.355872] sas: Enter sas_scsi_recover_host busy: 0 failed: 0
[    3.355980] sas: ata7: end_device-0:0: dev error handler
[    3.387719] clocksource: Switched to clocksource tsc
[    3.544449] ata7.00: ATA-9: ST1000DM003-1CH162, CC47, max UDMA/133
[    3.544462] ata7.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32)
[    3.545266] ata7.00: configured for UDMA/133
[    3.545279] sas: --- Exit sas_scsi_recover_host: busy: 0 failed: 0 tries: 1
[    3.545904] scsi 0:0:0:0: Direct-Access     ATA      ST1000DM003-1CH1 CC47 PQ: 0 ANSI: 5
[    3.546080] sd 0:0:0:0: [sda] 1953525168 512-byte logical blocks: (1.00 TB/932 GiB)
[    3.546081] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    3.546089] sd 0:0:0:0: [sda] Write Protect is off
[    3.546091] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.546102] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.546171] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    3.546545] scsi 1:0:0:0: Direct-Access     ATA      INTEL SSDSC2BW48 400i PQ: 0 ANSI: 5
[    3.546686] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    3.546735] sd 1:0:0:0: [sdb] 937703088 512-byte logical blocks: (480 GB/447 GiB)
[    3.546743] sd 1:0:0:0: [sdb] Write Protect is off
[    3.546744] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    3.546755] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.547005] scsi 2:0:0:0: Direct-Access     ATA      WDC WD5003ABYZ-0 1S03 PQ: 0 ANSI: 5
[    3.547162] sd 2:0:0:0: [sdc] 976773168 512-byte logical blocks: (500 GB/466 GiB)
[    3.547169] sd 2:0:0:0: [sdc] Write Protect is off
[    3.547171] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    3.547182] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.547189] sd 2:0:0:0: Attached scsi generic sg2 type 0
[    3.548101]  sdb: sdb1 sdb2
[    3.548305] sd 1:0:0:0: [sdb] Attached SCSI disk
[    3.561066]  sdc: sdc1
[    3.561297] sd 2:0:0:0: [sdc] Attached SCSI disk
[    3.568948]  sda: sda1 sda2 < sda5 >
[    3.569166] sd 0:0:0:0: [sda] Attached SCSI disk
[    4.907444] cxgb4 0000:07:00.4: Successfully configured using Firmware Configuration File "Firmware Default", version 0x0, computed checksum 0x0
[    5.051439] cxgb4 0000:07:00.4: max_ordird_qp 255 max_ird_adapter 622592
[    5.148507] cxgb4 0000:07:00.4: 66 MSI-X vectors allocated, nic 16 per uld 8
[    5.148578] cxgb4 0000:07:00.4: PCIe link speed is 8.0GT/s, device supports 8.0GT/s
[    5.148579] cxgb4 0000:07:00.4: PCIe link width is x16, device supports x16
[    5.171625] cxgb4 0000:07:00.4 eth0: eth0: Chelsio T62100-LP-CR (0000:07:00.4) 25G/40G/100GBASE-CR4_QSFP
[    5.171781] cxgb4 0000:07:00.4 eth1: eth1: Chelsio T62100-LP-CR (0000:07:00.4) 25G/40G/100GBASE-CR4_QSFP
[    5.171834] cxgb4 0000:07:00.4: Chelsio T62100-LP-CR rev 0
[    5.171835] cxgb4 0000:07:00.4: S/N: PT51160053, P/N: 11012106004
[    5.171837] cxgb4 0000:07:00.4: Firmware version: 1.16.43.0
[    5.171838] cxgb4 0000:07:00.4: Bootstrap version: 255.255.255.255
[    5.171839] cxgb4 0000:07:00.4: TP Microcode version: 0.1.23.2
[    5.171840] cxgb4 0000:07:00.4: No Expansion ROM loaded
[    5.171841] cxgb4 0000:07:00.4: Configuration: RNIC MSI-X, Offload capable
[    5.183584] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
[    5.183585] igb: Copyright (c) 2007-2014 Intel Corporation.
[    5.265939] igb 0000:09:00.0: DCA enabled
[    5.266153] igb 0000:09:00.0: added PHC on eth2
[    5.266154] igb 0000:09:00.0: Intel(R) Gigabit Ethernet Network Connection
[    5.266156] igb 0000:09:00.0: eth2: (PCIe:5.0Gb/s:Width x4) 00:25:90:e8:29:c0
[    5.266229] igb 0000:09:00.0: eth2: PBA No: 106100-000
[    5.266231] igb 0000:09:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    5.337335] igb 0000:09:00.1: DCA enabled
[    5.337442] igb 0000:09:00.1: added PHC on eth3
[    5.337444] igb 0000:09:00.1: Intel(R) Gigabit Ethernet Network Connection
[    5.337445] igb 0000:09:00.1: eth3: (PCIe:5.0Gb/s:Width x4) 00:25:90:e8:29:c1
[    5.337519] igb 0000:09:00.1: eth3: PBA No: 106100-000
[    5.337521] igb 0000:09:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[    5.337865] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    5.337875] ehci-pci: EHCI PCI platform driver
[    5.338146] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    5.338155] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    5.338167] ehci-pci 0000:00:1a.0: debug port 2
[    5.342072] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
[    5.342088] ehci-pci 0000:00:1a.0: irq 16, io mem 0xc2a02000
[    5.355435] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    5.355485] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    5.355486] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.355487] usb usb1: Product: EHCI Host Controller
[    5.355488] usb usb1: Manufacturer: Linux 4.12.0-rc1.spreadpfn ehci_hcd
[    5.355489] usb usb1: SerialNumber: 0000:00:1a.0
[    5.355652] hub 1-0:1.0: USB hub found
[    5.355658] hub 1-0:1.0: 2 ports detected
[    5.356048] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    5.356054] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    5.356064] ehci-pci 0000:00:1d.0: debug port 2
[    5.359985] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[    5.359997] ehci-pci 0000:00:1d.0: irq 23, io mem 0xc2a01000
[    5.375428] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    5.375477] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    5.375478] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.375479] usb usb2: Product: EHCI Host Controller
[    5.375480] usb usb2: Manufacturer: Linux 4.12.0-rc1.spreadpfn ehci_hcd
[    5.375482] usb usb2: SerialNumber: 0000:00:1d.0
[    5.375680] hub 2-0:1.0: USB hub found
[    5.375685] hub 2-0:1.0: 2 ports detected
[    5.375919] i8042: PNP: PS/2 Controller [PNP0f03:PS2M] at 0x60,0x64 irq 12
[    5.375920] i8042: PNP: PS/2 controller doesn't have KBD irq; using default 1
[    5.378793] serio: i8042 KBD port at 0x60,0x64 irq 1
[    5.378800] serio: i8042 AUX port at 0x60,0x64 irq 12
[    5.379199] mousedev: PS/2 mouse device common for all mice
[    5.379379] input: PC Speaker as /devices/platform/pcspkr/input/input2
[    5.379552] rtc_cmos 00:02: RTC can wake from S4
[    5.379841] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[    5.379875] rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[    5.380075] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
[    5.381799] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[    5.381845] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[    5.381860] iTCO_vendor_support: vendor-support=0
[    5.381878] device-mapper: uevent: version 1.0.3
[    5.382041] device-mapper: ioctl: 4.35.0-ioctl (2016-06-23) initialised: dm-devel@redhat.com
[    5.683429] usb 1-1: new high-speed USB device number 2 using ehci-pci
[    5.703428] usb 2-1: new high-speed USB device number 2 using ehci-pci
[    5.831805] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[    5.831807] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    5.832058] hub 1-1:1.0: USB hub found
[    5.832131] hub 1-1:1.0: 6 ports detected
[    5.851807] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[    5.851809] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    5.852048] hub 2-1:1.0: USB hub found
[    5.852129] hub 2-1:1.0: 8 ports detected
[    5.859413] iw_cxgb4: Chelsio T4/T5 RDMA Driver - version 0.1
[    5.859877] hidraw: raw HID events driver (C) Jiri Kosina
[    5.859925] usbcore: registered new interface driver usbhid
[    5.859926] usbhid: USB HID core driver
[    5.860024] drop_monitor: Initializing network drop monitor service
[    5.860056] Netfilter messages via NETLINK v0.30.
[    5.860256] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
[    5.860304] ctnetlink v0.93: registering with nfnetlink.
[    5.860393] ip_tables: (C) 2000-2006 Netfilter Core Team
[    5.860443] Initializing XFRM netlink socket
[    5.860475] NET: Registered protocol family 10
[    5.861015] Segment Routing with IPv6
[    5.861029] mip6: Mobile IPv6
[    5.861032] NET: Registered protocol family 17
[    5.861045] Bridge firewalling registered
[    5.861067] Key type dns_resolver registered
[    5.862366] microcode: sig=0x206d7, pf=0x1, revision=0x710
[    5.862688] microcode: Microcode Update Driver: v2.2.
[    5.862718] AVX version of gcm_enc/dec engaged.
[    5.862719] AES CTR mode by8 optimization enabled
[    5.875298] alg: No test for pcbc(aes) (pcbc-aes-aesni)
[    5.875566] registered taskstats version 1
[    5.878163] rtc_cmos 00:02: setting system clock to 2017-05-17 17:28:35 UTC (1495042115)
[    5.879627] PM: Hibernation image not present or could not be loaded.
[    5.881170] Freeing unused kernel memory: 1140K
[    5.881171] Write protecting the kernel read-only data: 14336k
[    5.881729] Freeing unused kernel memory: 616K
[    5.883445] Freeing unused kernel memory: 736K
[    5.897585] systemd-udevd[234]: starting version 215
[    5.898114] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    5.988573] random: fast init done
[    6.123429] usb 1-1.3: new full-speed USB device number 3 using ehci-pci
[    6.233093] usb 1-1.3: New USB device found, idVendor=046b, idProduct=ff10
[    6.233097] usb 1-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    6.233099] usb 1-1.3: Product: Virtual Keyboard and Mouse
[    6.233102] usb 1-1.3: Manufacturer: American Megatrends Inc.
[    6.234887] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.3/1-1.3:1.0/0003:046B:FF10.0001/input/input6
[    6.235300] hid-generic 0003:046B:FF10.0001: input,hidraw0: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.0-1.3/input0
[    6.236376] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.3/1-1.3:1.1/0003:046B:FF10.0002/input/input7
[    6.236765] hid-generic 0003:046B:FF10.0002: input,hidraw1: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.0-1.3/input1
[    6.674437] PM: Starting manual resume from disk
[    6.674443] PM: Hibernation image partition 253:1 present
[    6.674444] PM: Looking for hibernation image.
[    6.674758] PM: Image not found (code -22)
[    6.674760] PM: Hibernation image not present or could not be loaded.
[    6.771839] EXT4-fs (dm-0): mounted filesystem with ordered data mode. Opts: (null)
[    7.306305] systemd[1]: systemd 215 running in system mode. (+PAM +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ -SECCOMP -APPARMOR)
[    7.306498] systemd[1]: Detected architecture 'x86-64'.
[    7.325696] systemd[1]: Set hostname to <cgy1-donard>.
[    7.780158] random: crng init done
[    7.780193] systemd-sysv-generator[337]: Ignoring creation of an alias console-setup.service for itself
[    8.426709] systemd[1]: [/lib/systemd/system/docker.service:25] Unknown lvalue 'Delegate' in section 'Service'
[    8.747646] systemd[1]: Cannot add dependency job for unit lvm2-lvmpolld.socket, ignoring: Unit lvm2-lvmpolld.socket failed to load: No such file or directory.
[    8.747702] systemd[1]: Cannot add dependency job for unit flocker-control-api.socket, ignoring: Unit flocker-control-api.socket failed to load: No such file or directory.
[    8.747706] systemd[1]: Cannot add dependency job for unit flocker-control-agent.socket, ignoring: Unit flocker-control-agent.socket failed to load: No such file or directory.
[    8.747709] systemd[1]: Cannot add dependency job for unit rpcbind.socket, ignoring: Unit rpcbind.socket failed to load: No such file or directory.
[    8.747722] systemd[1]: Cannot add dependency job for unit apt-daily.timer, ignoring: Unit apt-daily.timer failed to load: No such file or directory.
[    8.747738] systemd[1]: Cannot add dependency job for unit flocker-container-agent.service, ignoring: Unit flocker-container-agent.service failed to load: No such file or directory.
[    9.350026] systemd-udevd[357]: starting version 215
[    9.971302] igb 0000:09:00.1 rename5: renamed from eth3
[    9.999519] systemd-udevd[373]: renamed network interface eth3 to rename5
[    9.999633] igb 0000:09:00.0 rename4: renamed from eth2
[   10.015479] systemd-udevd[370]: renamed network interface eth2 to rename4
[   10.015656] cxgb4 0000:07:00.4 cxgb1: renamed from eth1
[   10.039501] systemd-udevd[387]: renamed network interface eth1 to cxgb1
[   10.039506] cxgb4 0000:07:00.4 cxgb0: renamed from eth0
[   10.055545] systemd-udevd[389]: renamed network interface eth0 to cxgb0
[   10.055772] igb 0000:09:00.1 eth1: renamed from rename5
[   10.083496] systemd-udevd[373]: renamed network interface eth3 to eth1
[   10.083508] igb 0000:09:00.0 eth0: renamed from rename4
[   10.107502] systemd-udevd[370]: renamed network interface eth2 to eth0
[   10.701736] Adding 16650236k swap on /dev/mapper/cgy1--donard-swap_1.  Priority:-1 extents:1 across:16650236k 
[   12.037576] EXT4-fs (dm-0): re-mounted. Opts: errors=remount-ro
[   12.145261] EXT4-fs (pmem0): VFS: Can't find ext4 filesystem
[   12.148250] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: (null)
[   12.291980] EXT4-fs (sda1): mounted filesystem without journal. Opts: (null)
[   12.662774] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: (null)
[   12.928875] systemd-journald[456]: Received request to flush runtime journal from PID 1
[   14.471620] iw_cxgb4: 0000:07:00.4: Up
[   14.471625] iw_cxgb4: 0000:07:00.4: On-Chip Queues not supported on this device
[   14.512611] IPv6: ADDRCONF(NETDEV_UP): cxgb0: link is not ready
[   14.588575] IPv6: ADDRCONF(NETDEV_UP): cxgb1: link is not ready
[   14.594648] cxgb4 0000:07:00.4 cxgb0: passive DA module inserted
[   14.594890] cxgb4 0000:07:00.4 cxgb1: passive DA module inserted
[   14.789874] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   15.323774] cxgb4 0000:07:00.4 cxgb0: link up, 100Gbps, full-duplex, Tx/Rx PAUSE
[   15.323796] IPv6: ADDRCONF(NETDEV_CHANGE): cxgb0: link becomes ready
[   15.333756] cxgb4 0000:07:00.4 cxgb1: link up, 100Gbps, full-duplex, Tx/Rx PAUSE
[   15.333785] IPv6: ADDRCONF(NETDEV_CHANGE): cxgb1: link becomes ready
[   18.108792] igb 0000:09:00.0 eth0: igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[   18.109007] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   28.178954] IPMI message handler: Event queue full, discarding incoming events
[   38.027593] IPv6: ADDRCONF(NETDEV_UP): docker0: link is not ready
[   38.650012] nvmet: adding nsid 1 to subsystem test1
[   38.653921] iwpm_register_pid: Unable to send a nlmsg (client = 2)
[   38.654082] nvmet_rdma: enabling port 1 (172.17.10.1:4420)
[   40.922701] nvmet: creating controller 1 for subsystem test1 for NQN nqn.2014-08.org.nvmexpress:NVMf:uuid:bde4a8bd-b7f4-49b1-adbc-2c7000d7f205.
[   40.933824] nvmet: adding queue 1 to ctrl 1.
[   40.933879] nvmet: adding queue 2 to ctrl 1.
[   40.933921] nvmet: adding queue 3 to ctrl 1.
[   40.933965] nvmet: adding queue 4 to ctrl 1.
[   40.934003] nvmet: adding queue 5 to ctrl 1.
[   40.934039] nvmet: adding queue 6 to ctrl 1.
[   40.934078] nvmet: adding queue 7 to ctrl 1.
[   40.934141] nvmet: adding queue 8 to ctrl 1.
[   41.093555] cxgb4 0000:07:00.4: AE qpid 1034 opcode 0 status 0x1 type 1 len 0x0 wrid.hi 0x0 wrid.lo 0x0
[   41.093673] nvmet_rdma: received IB QP event: QP access error (3)
[   41.093807] nvmet_rdma: freeing queue 5
[   41.107641] general protection fault: 0000 [#1] SMP
[   41.107736] Modules linked in:
[   41.107825] CPU: 0 PID: 59 Comm: kworker/0:1 Not tainted 4.12.0-rc1.spreadpfn #340
[   41.107922] Hardware name: Supermicro SYS-7047GR-TRF/X9DRG-QF, BIOS 3.0a 12/05/2013
[   41.108024] Workqueue: events nvmet_rdma_release_queue_work
[   41.108117] task: ffff88027661b1c0 task.stack: ffffc90001b9c000
[   41.108211] RIP: 0010:nvmet_rdma_free_rsps+0x8a/0xe0
[   41.108302] RSP: 0018:ffffc90001b9fe20 EFLAGS: 00010282
[   41.108395] RAX: dead000000000200 RBX: ffff880469004058 RCX: ffffc90001b9fdb8
[   41.108491] RDX: dead000000000100 RSI: ffffc90001b9fd98 RDI: ffff880277800100
[   41.108588] RBP: 0000000000004058 R08: 0000000000000000 R09: ffffffff81431d70
[   41.108684] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000023800
[   41.108781] R13: ffff88046be1f800 R14: ffff88026a0b8480 R15: 0ffff880277c1df1
[   41.108878] FS:  0000000000000000(0000) GS:ffff880277c00000(0000) knlGS:0000000000000000
[   41.108977] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   41.109070] CR2: 00007f4edf213148 CR3: 0000000001e0a000 CR4: 00000000000406f0
[   41.109187] Call Trace:
[   41.109296]  ? nvmet_rdma_free_queue+0x51/0x90
[   41.109408]  ? nvmet_rdma_release_queue_work+0x1a/0x50
[   41.109524]  ? process_one_work+0x13d/0x360
[   41.109635]  ? worker_thread+0x5d/0x380
[   41.109746]  ? flush_delayed_work+0x30/0x30
[   41.109858]  ? kthread+0x10f/0x150
[   41.109966]  ? kthread_park+0x50/0x50
[   41.110124]  ? kthread_park+0x50/0x50
[   41.110236]  ? ret_from_fork+0x23/0x30
[   41.110346] Code: 00 00 48 81 c5 38 02 00 00 e8 43 8f c4 ff 4c 39 e5 74 59 48 89 eb 49 03 9d c0 00 00 00 48 8b 83 30 02 00 00 48 8b 93 28 02 00 00 <48> 89 42 08 48 89 10 48 b8 00 01 00 00 00 00 ad de 48 89 83 28 
[   41.110556] RIP: nvmet_rdma_free_rsps+0x8a/0xe0 RSP: ffffc90001b9fe20
[   41.110691] ---[ end trace 5c4c5321c1018d73 ]---
[   51.162361] nvmet_rdma: freeing queue 1
[   51.166132] nvmet_rdma: freeing queue 2
[   51.170295] nvmet_rdma: freeing queue 3
[   51.174109] nvmet_rdma: freeing queue 4
[   51.186095] nvmet_rdma: freeing queue 6
[   51.191235] nvmet_rdma: freeing queue 7
[   51.194218] nvmet_rdma: freeing queue 8
[   51.198506] nvmet_rdma: freeing queue 0
[   51.202472] workqueue: WQ_MEM_RECLAIM iw_cm_wq:cm_work_handler is flushing !WQ_MEM_RECLAIM events:          (null)
[   51.202480] ------------[ cut here ]------------
[   51.202753] WARNING: CPU: 0 PID: 153 at kernel/workqueue.c:2423 check_flush_dependency+0xaa/0x130
[   51.202899] Modules linked in:
[   51.203014] CPU: 0 PID: 153 Comm: kworker/u16:1 Tainted: G      D         4.12.0-rc1.spreadpfn #340
[   51.203161] Hardware name: Supermicro SYS-7047GR-TRF/X9DRG-QF, BIOS 3.0a 12/05/2013
[   51.203305] Workqueue: iw_cm_wq cm_work_handler
[   51.203421] task: ffff880476b58500 task.stack: ffffc90002214000
[   51.203541] RIP: 0010:check_flush_dependency+0xaa/0x130
[   51.203658] RSP: 0018:ffffc90002217ab0 EFLAGS: 00010282
[   51.203776] RAX: 0000000000000066 RBX: ffff880277803a00 RCX: ffffffff81e55b98
[   51.203989] RDX: 0000000000000001 RSI: 0000000000000086 RDI: ffffffff820b984c
[   51.204110] RBP: ffff880274a9ef00 R08: 0000000000000066 R09: 00000000000004ce
[   51.204232] R10: ffffc90002217b90 R11: 000000006c756e28 R12: 0000000000000000
[   51.204353] R13: ffff880277803a68 R14: ffff880277803a20 R15: ffffc90002217b00
[   51.204475] FS:  0000000000000000(0000) GS:ffff880277c00000(0000) knlGS:0000000000000000
[   51.204621] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   51.204739] CR2: 000000c420520698 CR3: 0000000001e0a000 CR4: 00000000000406f0
[   51.204860] Call Trace:
[   51.204974]  ? flush_workqueue+0x123/0x3b0
[   51.205091]  ? nvmet_rdma_cm_handler+0xa76/0xdf0
[   51.205207]  ? nvmet_rdma_cm_handler+0xa76/0xdf0
[   51.205324]  ? cma_attach_to_dev+0xd/0x40
[   51.205441]  ? nvmet_rdma_cm_reject+0x70/0x70
[   51.205559]  ? iw_conn_req_handler+0x16b/0x1e0
[   51.205676]  ? cm_work_handler+0xc93/0xcb0
[   51.205811]  ? process_one_work+0x13d/0x360
[   51.205927]  ? worker_thread+0x5d/0x380
[   51.206050]  ? flush_delayed_work+0x30/0x30
[   51.206196]  ? kthread+0x10f/0x150
[   51.206348]  ? kthread_park+0x50/0x50
[   51.206465]  ? ioat_cleanup_preamble+0x90/0x90
[   51.206586]  ? ret_from_fork+0x23/0x30
[   51.206724] Code: 9a 48 8b 55 18 48 8d b0 b0 00 00 00 48 8d 8b b0 00 00 00 4d 89 e0 48 c7 c7 18 8e bf 81 31 c0 c6 05 4c 5e d8 00 01 e8 85 ef 0b 00 <0f> ff e9 69 ff ff ff 45 31 e4 e9 58 ff ff ff 65 48 8b 04 25 c0 
[   51.206958] ---[ end trace 5c4c5321c1018d74 ]---

--------------5948F4B25C32456C29F3396F--
