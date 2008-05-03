From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Need help debugging memory corruption
Date: Sat, 3 May 2008 13:09:51 -0500
Message-ID: <20080503130951.091392ba@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/Ro3VZ+TBrBNm0/e0QTfWH2="
Cc: Chris Snook <csnook@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:61946 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758350AbYECSKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 14:10:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/Ro3VZ+TBrBNm0/e0QTfWH2=
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I'm trying to track down a memory corruption bug in the atl1 network
device driver that is exposed only when operating with 4GB or more
memory.  (NB: The driver uses a 32-bit DMA mask.)  The bug is hit under
certain conditions whenever the network interface is commanded down.

The information provided here is against recent -git, but this problem
also afflicts the atl1 driver in kernels 2.6.2[345].y.  Dmesg and
config attached.

I can reproduce the bug at will by simply using scp to copy a few
hundred megabytes from a remote host, then by executing 'ifconfig eth0
down'.

Here is the relevant console output when the bug is hit.  I note that
the apparent corrupting data beginning at address 0xffff81010fcff402 is
actually a received ethernet frame.  (The value 00:17:31:4e:9d:41 is
the MAC address of the local host, corresponding to the destination
address of a received frame.)

Can someone with more experience than me please take a look and give me
some advice or explain what might be happening here?  (What may be
obvious to you is probably not obvious to me.)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
BUG kmalloc-2048: Poison overwritten
---------------------------------------------------------------------------=
--

INFO: 0xffff81010fcff402-0xffff81010fcff9f9. First byte 0x0 instead of 0x6b
INFO: Allocated in dev_alloc_skb+0x16/0x2c age=3D9459 cpu=3D0 pid=3D2754
INFO: Freed in skb_release_data+0xa8/0xad age=3D9434 cpu=3D0 pid=3D2754
INFO: Slab 0xffffe20005d6f540 objects=3D15 used=3D0 fp=3D0xffff81010fcfb1b0=
 flags=3D0x8000000000002082
INFO: Object 0xffff81010fcff3f0 @offset=3D29680 fp=3D0xffff81010fcfd2d0

Bytes b4 0xffff81010fcff3e0:  3b bd 00 00 01 00 00 00 5a 5a 5a 5a 5a 5a 5a =
5a ;=EF=BF=BD......ZZZZZZZZ
  Object 0xffff81010fcff3f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b kkkkkkkkkkkkkkkk
  Object 0xffff81010fcff400:  6b 6b 00 17 31 4e 9d 41 00 1b fc 95 53 da 08 =
00 kk..1N.A..=EF=BF=BD.S=EF=BF=BD..
  Object 0xffff81010fcff410:  45 08 02 2c 83 1f 40 00 40 06 31 e1 c0 a8 01 =
03 E..,..@.@.1=EF=BF=BD=EF=BF=BD=EF=BF=BD..
  Object 0xffff81010fcff420:  c0 a8 01 70 58 b9 c0 18 93 5f c2 41 51 d2 a7 =
5d =EF=BF=BD=EF=BF=BD.pX=EF=BF=BD=EF=BF=BD.._=EF=BF=BDAQ=D2=A7]
  Object 0xffff81010fcff430:  80 18 00 e8 ee ef 00 00 01 01 08 0a 00 e2 58 =
16 ...=EF=BF=BD=EF=BF=BD=EF=BF=BD.......=EF=BF=BDX.
  Object 0xffff81010fcff440:  00 00 bd 38 4b 93 e4 7f 3e 8d 8c 2b 41 dc 9b =
36 ..=EF=BF=BD8K.=EF=BF=BD.>..+A=EF=BF=BD.6
  Object 0xffff81010fcff450:  4d 9f b7 cf 2a 2c 07 06 d8 2f 23 de 5a 34 90 =
cb M.=EF=BF=BD=EF=BF=BD*,..=EF=BF=BD/#=EF=BF=BDZ4.
  Object 0xffff81010fcff460:  6d d7 36 5b 2c 04 19 06 74 95 3f c5 3c c8 a5 =
9a m=EF=BF=BD6[,...t.?=EF=BF=BD<=C8=A5.
 Redzone 0xffff81010fcffbf0:  bb bb bb bb bb bb bb bb                      =
   =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
       =20
 Padding 0xffff81010fcffc30:  5a 5a 5a 5a 5a 5a 5a 5a                      =
   ZZZZZZZZ       =20
Pid: 2757, comm: ifconfig Not tainted 2.6.25 #1

Call Trace:
 [<ffffffff8108cf02>] print_trailer+0x123/0x12c
 [<ffffffff8108cfaf>] check_bytes_and_report+0xa4/0xcb
 [<ffffffff8108d2de>] check_object+0xca/0x212
 [<ffffffff8108d66d>] __free_slab+0x85/0xfd
 [<ffffffff811e5cf2>] ? skb_release_data+0xa8/0xad
 [<ffffffff8108d71d>] discard_slab+0x38/0x3a
 [<ffffffff8108e0f2>] __slab_free+0xdb/0x2ac
 [<ffffffff8108e3fa>] kfree+0xbc/0xcc
 [<ffffffff811e5cf2>] ? skb_release_data+0xa8/0xad
 [<ffffffff811e5cf2>] skb_release_data+0xa8/0xad
 [<ffffffff811e63b3>] skb_release_all+0xc9/0xce
 [<ffffffff811e5b4d>] __kfree_skb+0x11/0x78
 [<ffffffff811e5bdb>] kfree_skb+0x27/0x29
 [<ffffffffa00e63aa>] :atl1:atl1_clean_rx_ring+0x7e/0xe2
 [<ffffffffa00e64d7>] :atl1:atl1_down+0xc9/0xce
 [<ffffffffa00e8dcd>] :atl1:atl1_close+0x18/0x27
 [<ffffffff811ebd43>] dev_close+0x57/0x72
 [<ffffffff811eba47>] dev_change_flags+0xa8/0x164
 [<ffffffff8122f380>] devinet_ioctl+0x26a/0x5f6
 [<ffffffff8122fbad>] inet_ioctl+0x92/0xaa
 [<ffffffff811df5f4>] sock_ioctl+0x1da/0x202
 [<ffffffff8109f186>] vfs_ioctl+0x2a/0x77
 [<ffffffff8109f435>] do_vfs_ioctl+0x262/0x27f
 [<ffffffff8109f4a9>] sys_ioctl+0x57/0x7a
 [<ffffffff8100bff7>] tracesys+0xd5/0xda

FIX kmalloc-2048: Restoring 0xffff81010fcff402-0xffff81010fcff9f9=3D0x6b

Thanks,
Jay

--MP_/Ro3VZ+TBrBNm0/e0QTfWH2=
Content-Type: text/plain; name=atl1-4g-corrupt-dmesg.txt
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=atl1-4g-corrupt-dmesg.txt

Linux version 2.6.25 (jcliburn@finch.hogchain.net) (gcc version 4.1.2 20070925 (Red Hat 4.1.2-27)) #1 SMP Sat May 3 12:13:28 CDT 2008
Command line: ro root=LABEL=/1 console=ttyS0,38400 console=tt
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000cffb0000 (usable)
 BIOS-e820: 00000000cffb0000 - 00000000cffbe000 (ACPI data)
 BIOS-e820: 00000000cffbe000 - 00000000cffe0000 (ACPI NVS)
 BIOS-e820: 00000000cffe0000 - 00000000d0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fecc0000 - 00000000fecc1000 (reserved)
 BIOS-e820: 00000000ff780000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000130000000 (usable)
Entering add_active_range(0, 0, 159) 0 entries of 256 used
Entering add_active_range(0, 256, 851888) 1 entries of 256 used
Entering add_active_range(0, 1048576, 1245184) 2 entries of 256 used
max_pfn_mapped = 1245184
x86: PAT support disabled.
init_memory_mapping
DMI present.
ACPI: RSDP 000FA960, 0014 (r0 ACPIAM)
ACPI: RSDT CFFB0000, 003C (r1 A_M_I_ OEMRSDT  10000715 MSFT       97)
ACPI: FACP CFFB0200, 0084 (r2 A_M_I_ OEMFACP  10000715 MSFT       97)
ACPI: DSDT CFFB05C0, 4E3F (r1  A0498 A0498000        0 INTL 20060113)
ACPI: FACS CFFBE000, 0040
ACPI: APIC CFFB0390, 0068 (r1 A_M_I_ OEMAPIC  10000715 MSFT       97)
ACPI: MCFG CFFB0400, 003C (r1 A_M_I_ OEMMCFG  10000715 MSFT       97)
ACPI: OEMB CFFBE040, 0060 (r1 A_M_I_ AMI_OEM  10000715 MSFT       97)
ACPI: HPET CFFB5400, 0038 (r1 A_M_I_ OEMHPET  10000715 MSFT       97)
ACPI: SSDT CFFB5440, 01C4 (r1 A_M_I_ POWERNOW        1 AMD         1)
Entering add_active_range(0, 0, 159) 0 entries of 256 used
Entering add_active_range(0, 256, 851888) 1 entries of 256 used
Entering add_active_range(0, 1048576, 1245184) 2 entries of 256 used
  early res: 0 [0-fff] BIOS data page
  early res: 1 [6000-7fff] TRAMPOLINE
  early res: 2 [200000-933ae7] TEXT DATA BSS
  early res: 3 [37ce4000-37fefdc9] RAMDISK
  early res: 4 [9fc00-fffff] BIOS reserved
  early res: 5 [8000-dfff] PGTABLE
 [ffffe20000000000-ffffe20002dfffff] PMD -> [ffff810001200000-ffff810003ffffff] on node 0
 [ffffe20002e00000-ffffe200069fffff] PMD -> [ffff81000c000000-ffff81000fbfffff] on node 0
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1245184
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0:        0 ->      159
    0:      256 ->   851888
    0:  1048576 ->  1245184
On node 0 totalpages: 1048399
  DMA zone: 88 pages used for memmap
  DMA zone: 1950 pages reserved
  DMA zone: 1961 pages, LIFO batch:0
  DMA32 zone: 22440 pages used for memmap
  DMA32 zone: 825352 pages, LIFO batch:31
  Normal zone: 4224 pages used for memmap
  Normal zone: 192384 pages, LIFO batch:31
  Movable zone: 0 pages used for memmap
Looks like a VIA chipset. Disabling IOMMU. Override with iommu=allowed
Detected use of extended apic ids on hypertransport bus
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x03] address[0xfecc0000] gsi_base[24])
IOAPIC[1]: apic_id 3, version 0, address 0xfecc0000, GSI 24-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0xffffffff base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000e4000
PM: Registered nosave memory: 00000000000e4000 - 0000000000100000
PM: Registered nosave memory: 00000000cffb0000 - 00000000cffbe000
PM: Registered nosave memory: 00000000cffbe000 - 00000000cffe0000
PM: Registered nosave memory: 00000000cffe0000 - 00000000d0000000
PM: Registered nosave memory: 00000000d0000000 - 00000000fec00000
PM: Registered nosave memory: 00000000fec00000 - 00000000fec01000
PM: Registered nosave memory: 00000000fec01000 - 00000000fecc0000
PM: Registered nosave memory: 00000000fecc0000 - 00000000fecc1000
PM: Registered nosave memory: 00000000fecc1000 - 00000000ff780000
PM: Registered nosave memory: 00000000ff780000 - 0000000100000000
Allocating PCI resources starting at d4000000 (gap: d0000000:2ec00000)
SMP: Allowing 2 CPUs, 0 hotplug CPUs
PERCPU: Allocating 40536 bytes of per cpu data
NR_CPUS: 32, nr_cpu_ids: 2
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1019697
Kernel command line: ro root=LABEL=/1 console=ttyS0,38400 console=tt
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
TSC calibrated against PM_TIMER
Marking TSC unstable due to TSCs unsynchronized
time.c: Detected 1999.772 MHz processor.
Console: colour VGA+ 80x25
console [ttyS0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        2048
... CLASSHASH_SIZE:           1024
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 1648 kB
 per task-struct memory footprint: 2688 bytes
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing software IO TLB between 0x4000000 - 0x8000000
Memory: 4001212k/4980736k available (2480k kernel code, 191740k reserved, 1409k data, 256k init)
CPA: page pool initialized 64 of 64 pages preallocated
SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
Calibrating delay using timer specific routine.. 4000.91 BogoMIPS (lpj=2000457)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Mount-cache hash table entries: 256
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
ACPI: Core revision 20080321
CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
Using local APIC timer interrupts.
APIC timer calibration result 12498583
Detected 12.498 MHz APIC timer.
lockdep: fixing up alternatives.
Booting processor 1/1 ip 6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 3999.46 BogoMIPS (lpj=1999732)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
x86: PAT support disabled.
CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
Brought up 2 CPUs
Total of 2 processors activated (8000.37 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0-1
  groups: 0 1
CPU1 attaching sched-domain:
 domain 0: span 0-1
  groups: 1 0
PM: Adding info for No Bus:platform
net_namespace: 1312 bytes
Time: 12:25:53  Date: 05/03/08
NET: Registered protocol family 16
No dock devices found.
PM: Adding info for No Bus:vtcon0
node 0 link 0: io port [1000, ffffff]
TOM: 00000000d0000000 aka 3328M
node 0 link 0: mmio [e0000000, efffffff]
node 0 link 0: mmio [a0000, bffff]
node 0 link 0: mmio [d0000000, ffffffff]
TOM2: 0000000130000000 aka 4864M
bus: [00,ff] on node 0 link 0
bus: 00 index 0 io port: [0, ffff]
bus: 00 index 1 mmio: [d0000000, ffffffff]
bus: 00 index 2 mmio: [a0000, bffff]
bus: 00 index 3 mmio: [130000000, fcffffffff]
ACPI: bus type pci registered
PM: Adding info for No Bus:id
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: Not using MMCONFIG.
PCI: Using configuration type 1 for base access
PM: Adding info for No Bus:default
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
PCI: Using MMCONFIG at e0000000 - efffffff
PM: Adding info for acpi:LNXSYSTM:00
PM: Adding info for acpi:LNXPWRBN:00
PM: Adding info for acpi:ACPI0007:00
PM: Adding info for acpi:ACPI0007:01
PM: Adding info for acpi:device:00
PM: Adding info for acpi:PNP0A03:00
PM: Adding info for acpi:device:01
PM: Adding info for acpi:device:02
PM: Adding info for acpi:device:03
PM: Adding info for acpi:device:04
PM: Adding info for acpi:device:05
PM: Adding info for acpi:device:06
PM: Adding info for acpi:device:07
PM: Adding info for acpi:device:08
PM: Adding info for acpi:device:09
PM: Adding info for acpi:device:0a
PM: Adding info for acpi:device:0b
PM: Adding info for acpi:device:0c
PM: Adding info for acpi:device:0d
PM: Adding info for acpi:device:0e
PM: Adding info for acpi:device:0f
PM: Adding info for acpi:device:10
PM: Adding info for acpi:device:11
PM: Adding info for acpi:device:12
PM: Adding info for acpi:device:13
PM: Adding info for acpi:device:14
PM: Adding info for acpi:device:15
PM: Adding info for acpi:device:16
PM: Adding info for acpi:device:17
PM: Adding info for acpi:device:18
PM: Adding info for acpi:device:19
PM: Adding info for acpi:device:1a
PM: Adding info for acpi:device:1b
PM: Adding info for acpi:device:1c
PM: Adding info for acpi:device:1d
PM: Adding info for acpi:PNP0000:00
PM: Adding info for acpi:PNP0200:00
PM: Adding info for acpi:PNP0800:00
PM: Adding info for acpi:PNP0C04:00
PM: Adding info for acpi:PNP0700:00
PM: Adding info for acpi:PNP0400:00
PM: Adding info for acpi:PNP0C02:00
PM: Adding info for acpi:PNP0C02:01
PM: Adding info for acpi:PNP0C02:02
PM: Adding info for acpi:ATK0110:00
PM: Adding info for acpi:PNP0100:00
PM: Adding info for acpi:PNP0B00:00
PM: Adding info for acpi:PNP0C02:03
PM: Adding info for acpi:PNP0501:00
PM: Adding info for acpi:PNP0303:00
PM: Adding info for acpi:PNP0F03:00
PM: Adding info for acpi:PNP0C02:04
PM: Adding info for acpi:device:1e
PM: Adding info for acpi:device:1f
PM: Adding info for acpi:device:20
PM: Adding info for acpi:device:21
PM: Adding info for acpi:device:22
PM: Adding info for acpi:device:23
PM: Adding info for acpi:device:24
PM: Adding info for acpi:device:25
PM: Adding info for acpi:device:26
PM: Adding info for acpi:device:27
PM: Adding info for acpi:device:28
PM: Adding info for acpi:device:29
PM: Adding info for acpi:device:2a
PM: Adding info for acpi:PNP0C0E:00
PM: Adding info for acpi:PNP0C01:00
PM: Adding info for acpi:PNP0C0C:00
PM: Adding info for acpi:PNP0C0F:00
PM: Adding info for acpi:PNP0C0F:01
PM: Adding info for acpi:PNP0C0F:02
PM: Adding info for acpi:PNP0C0F:03
PM: Adding info for acpi:PNP0C0F:04
PM: Adding info for acpi:PNP0C0F:05
PM: Adding info for acpi:PNP0C0F:06
PM: Adding info for acpi:PNP0C0F:07
PM: Adding info for acpi:LNXTHERM:00
ACPI: PCI Root Bridge [PCI0] (0000:00)
PM: Adding info for No Bus:pci0000:00
PM: Adding info for No Bus:0000:00
PCI: Scanning bus 0000:00
PCI: Found 0000:00:00.0 [1106/0351] 000600 00
PCI: Found 0000:00:00.1 [1106/1351] 000600 00
PCI: Found 0000:00:00.2 [1106/2351] 000600 00
PCI: Found 0000:00:00.3 [1106/3351] 000600 00
PCI: Found 0000:00:00.4 [1106/4351] 000600 00
PCI: Found 0000:00:00.5 [1106/5351] 000800 00
PCI: Found 0000:00:00.6 [1106/6238] 000600 00
PCI: Found 0000:00:00.7 [1106/7351] 000600 00
PCI: Found 0000:00:01.0 [1106/b999] 000604 01
PCI: Found 0000:00:02.0 [1106/a238] 000604 01
PCI: Found 0000:00:03.0 [1106/c238] 000604 01
PCI: Found 0000:00:03.1 [1106/d238] 000604 01
PCI: Found 0000:00:03.2 [1106/e238] 000604 01
PCI: Found 0000:00:03.3 [1106/f238] 000604 01
PCI: Found 0000:00:0f.0 [1106/0591] 000101 00
PCI: Found 0000:00:0f.1 [1106/0571] 000101 00
PCI: Found 0000:00:10.0 [1106/3038] 000c03 00
PCI: Found 0000:00:10.1 [1106/3038] 000c03 00
PCI: Found 0000:00:10.2 [1106/3038] 000c03 00
PCI: Found 0000:00:10.3 [1106/3038] 000c03 00
PCI: Found 0000:00:10.4 [1106/3104] 000c03 00
PCI: Found 0000:00:11.0 [1106/3337] 000601 00
pci 0000:00:11.0: calling quirk_via_bridge+0x0/0x7d()
PCI: Found 0000:00:11.7 [1106/287e] 000600 00
PCI: Found 0000:00:13.0 [1106/337b] 000604 01
PCI: Found 0000:00:13.1 [1106/337a] 000604 01
PCI: Found 0000:00:18.0 [1022/1100] 000600 00
PCI: Found 0000:00:18.1 [1022/1101] 000600 00
PCI: Found 0000:00:18.2 [1022/1102] 000600 00
PCI: Found 0000:00:18.3 [1022/1103] 000600 00
PCI: Fixups for bus 0000:00
PCI: Scanning behind PCI bridge 0000:00:01.0, config 010100, pass 0
PCI: Scanning bus 0000:01
PCI: Fixups for bus 0000:01
PCI: Bus scan for 0000:01 returning with max=01
PCI: Scanning behind PCI bridge 0000:00:02.0, config 020200, pass 0
PCI: Scanning bus 0000:02
PCI: Found 0000:02:00.0 [10de/0141] 000300 00
PCI: Fixups for bus 0000:02
PCI: Bus scan for 0000:02 returning with max=02
PCI: Scanning behind PCI bridge 0000:00:03.0, config 060600, pass 0
PCI: Scanning bus 0000:06
PCI: Fixups for bus 0000:06
PCI: Bus scan for 0000:06 returning with max=06
PCI: Scanning behind PCI bridge 0000:00:03.1, config 050500, pass 0
PCI: Scanning bus 0000:05
PCI: Fixups for bus 0000:05
PCI: Bus scan for 0000:05 returning with max=05
PCI: Scanning behind PCI bridge 0000:00:03.2, config 040400, pass 0
PCI: Scanning bus 0000:04
PCI: Found 0000:04:00.0 [1969/1048] 000200 00
PCI: Fixups for bus 0000:04
PCI: Bus scan for 0000:04 returning with max=04
PCI: Scanning behind PCI bridge 0000:00:03.3, config 030300, pass 0
PCI: Scanning bus 0000:03
PCI: Fixups for bus 0000:03
PCI: Bus scan for 0000:03 returning with max=03
PCI: Scanning behind PCI bridge 0000:00:13.0, config 808000, pass 0
PCI: Scanning bus 0000:80
PCI: Found 0000:80:01.0 [1106/3288] 000403 00
PCI: Fixups for bus 0000:80
PCI: Bus scan for 0000:80 returning with max=80
PCI: Scanning behind PCI bridge 0000:00:13.1, config 070700, pass 0
PCI: Scanning bus 0000:07
PCI: Fixups for bus 0000:07
PCI: Transparent bridge - 0000:00:13.1
PCI: Bus scan for 0000:07 returning with max=07
PCI: Scanning behind PCI bridge 0000:00:01.0, config 010100, pass 1
PCI: Scanning behind PCI bridge 0000:00:02.0, config 020200, pass 1
PCI: Scanning behind PCI bridge 0000:00:03.0, config 060600, pass 1
PCI: Scanning behind PCI bridge 0000:00:03.1, config 050500, pass 1
PCI: Scanning behind PCI bridge 0000:00:03.2, config 040400, pass 1
PCI: Scanning behind PCI bridge 0000:00:03.3, config 030300, pass 1
PCI: Scanning behind PCI bridge 0000:00:13.0, config 808000, pass 1
PCI: Scanning behind PCI bridge 0000:00:13.1, config 070700, pass 1
PCI: Bus scan for 0000:00 returning with max=80
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBPG._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBP0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBP1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBP2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NBP3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P9._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PA._PRT]
PM: Adding info for pci:0000:00:00.0
PM: Adding info for pci:0000:00:00.1
PM: Adding info for pci:0000:00:00.2
PM: Adding info for pci:0000:00:00.3
PM: Adding info for pci:0000:00:00.4
PM: Adding info for pci:0000:00:00.5
PM: Adding info for pci:0000:00:00.6
PM: Adding info for pci:0000:00:00.7
PM: Adding info for pci:0000:00:01.0
PM: Adding info for pci:0000:00:02.0
PM: Adding info for pci:0000:00:03.0
PM: Adding info for pci:0000:00:03.1
PM: Adding info for pci:0000:00:03.2
PM: Adding info for pci:0000:00:03.3
PM: Adding info for pci:0000:00:0f.0
PM: Adding info for pci:0000:00:0f.1
PM: Adding info for pci:0000:00:10.0
PM: Adding info for pci:0000:00:10.1
PM: Adding info for pci:0000:00:10.2
PM: Adding info for pci:0000:00:10.3
PM: Adding info for pci:0000:00:10.4
PM: Adding info for pci:0000:00:11.0
PM: Adding info for pci:0000:00:11.7
PM: Adding info for pci:0000:00:13.0
PM: Adding info for pci:0000:00:13.1
PM: Adding info for pci:0000:00:18.0
PM: Adding info for pci:0000:00:18.1
PM: Adding info for pci:0000:00:18.2
PM: Adding info for pci:0000:00:18.3
PM: Adding info for No Bus:0000:01
PM: Adding info for pci:0000:02:00.0
PM: Adding info for No Bus:0000:02
PM: Adding info for No Bus:0000:06
PM: Adding info for No Bus:0000:05
PM: Adding info for pci:0000:04:00.0
PM: Adding info for No Bus:0000:04
PM: Adding info for No Bus:0000:03
PM: Adding info for pci:0000:80:01.0
PM: Adding info for No Bus:0000:80
PM: Adding info for No Bus:0000:07
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 *11 12 14 15)
ACPI Warning (tbutils-0217): Incorrect checksum in table [OEMB] - 54, should be 47 [20080321]
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
PM: Adding info for No Bus:pnp0
ACPI: bus type pnp registered
PM: Adding info for pnp:00:00
PM: Adding info for pnp:00:01
PM: Adding info for pnp:00:02
PM: Adding info for pnp:00:03
PM: Adding info for pnp:00:04
PM: Adding info for pnp:00:05
PM: Adding info for pnp:00:06
PM: Adding info for pnp:00:07
PM: Adding info for pnp:00:08
PM: Adding info for pnp:00:09
PM: Adding info for pnp:00:0a
PM: Adding info for pnp:00:0b
PM: Adding info for pnp:00:0c
PM: Adding info for pnp:00:0d
PM: Adding info for pnp:00:0e
PM: Adding info for pnp:00:0f
pnp: PnP ACPI: found 16 devices
ACPI: ACPI bus type pnp unregistered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
system 00:06: ioport range 0xc00-0xc0f has been reserved
system 00:06: ioport range 0xd00-0xd0f has been reserved
system 00:06: ioport range 0xa20-0xa2f has been reserved
system 00:06: ioport range 0xa30-0xa3f has been reserved
system 00:08: ioport range 0x3e0-0x3e7 has been reserved
system 00:08: ioport range 0x4d0-0x4d1 has been reserved
system 00:08: ioport range 0x800-0x87f has been reserved
system 00:08: ioport range 0x400-0x41f has been reserved
system 00:0a: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0a: iomem range 0xfee00000-0xfee00fff has been reserved
system 00:0e: iomem range 0xe0000000-0xefffffff has been reserved
system 00:0f: iomem range 0x0-0x9ffff could not be reserved
system 00:0f: iomem range 0xc0000-0xcffff has been reserved
system 00:0f: iomem range 0xe0000-0xfffff could not be reserved
system 00:0f: iomem range 0x100000-0xcfffffff could not be reserved
system 00:0f: iomem range 0xff380000-0xffffffff could not be reserved
PM: Adding info for No Bus:mem
PM: Adding info for No Bus:kmem
PM: Adding info for No Bus:null
PM: Adding info for No Bus:port
PM: Adding info for No Bus:zero
PM: Adding info for No Bus:full
PM: Adding info for No Bus:random
PM: Adding info for No Bus:urandom
PM: Adding info for No Bus:kmsg
PM: Adding info for No Bus:oldmem
PM: Adding info for No Bus:lo
Switched to high resolution mode on CPU 0
PCI: Bridge: 0000:00:01.0
Switched to high resolution mode on CPU 1
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:02.0
  IO window: disabled.
  MEM window: 0xf9000000-0xfbdfffff
  PREFETCH window: 0x00000000d0000000-0x00000000dfffffff
PCI: Bridge: 0000:00:03.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: 0x00000000f7f00000-0x00000000f7ffffff
PCI: Bridge: 0000:00:03.1
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: 0x00000000f7e00000-0x00000000f7efffff
PCI: Bridge: 0000:00:03.2
  IO window: disabled.
  MEM window: 0xfbe00000-0xfbefffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:03.3
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: 0x00000000f7d00000-0x00000000f7dfffff
PCI: Bridge: 0000:00:13.0
  IO window: disabled.
  MEM window: 0xfbf00000-0xfbffffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:13.1
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
pci 0000:00:01.0: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 27 (level, low) -> IRQ 27
pci 0000:00:02.0: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:00:02.0 to 64
ACPI: PCI Interrupt 0000:00:03.0[A] -> GSI 31 (level, low) -> IRQ 31
pci 0000:00:03.0: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:00:03.0 to 64
ACPI: PCI Interrupt 0000:00:03.1[B] -> GSI 35 (level, low) -> IRQ 35
pci 0000:00:03.1: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:00:03.1 to 64
ACPI: PCI Interrupt 0000:00:03.2[C] -> GSI 39 (level, low) -> IRQ 39
pci 0000:00:03.2: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:00:03.2 to 64
ACPI: PCI Interrupt 0000:00:03.3[D] -> GSI 43 (level, low) -> IRQ 43
pci 0000:00:03.3: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:00:03.3 to 64
pci 0000:00:13.0: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:00:13.0 to 64
pci 0000:00:13.1: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:00:13.1 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 9, 3670016 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
NET: Registered protocol family 1
checking if image is initramfs... it is
debug: unmapping init memory ffff810037ce4000..ffff810037ff0000
PM: Adding info for No Bus:mcelog
PM: Adding info for platform:pcspkr
PM: Adding info for No Bus:snapshot
audit: initializing netlink socket (disabled)
type=2000 audit(1209817552.445:1): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 7816 for ipc namespace ffffffff813a4920
SELinux:  Registering netfilter hooks
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:00:00.0: calling via_no_dac+0x0/0x34()
pci 0000:00:00.0: calling quirk_disable_all_msi+0x0/0x3a()
pci 0000:00:00.0: MSI quirk detected; MSI disabled
pci 0000:00:00.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:00.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:00.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:00.1: calling via_no_dac+0x0/0x34()
pci 0000:00:00.1: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:00.1: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:00.1: calling pci_fixup_video+0x0/0xab()
pci 0000:00:00.2: calling via_no_dac+0x0/0x34()
pci 0000:00:00.2: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:00.2: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:00.2: calling pci_fixup_video+0x0/0xab()
pci 0000:00:00.3: calling via_no_dac+0x0/0x34()
pci 0000:00:00.3: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:00.3: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:00.3: calling pci_fixup_video+0x0/0xab()
pci 0000:00:00.4: calling via_no_dac+0x0/0x34()
pci 0000:00:00.4: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:00.4: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:00.4: calling pci_fixup_video+0x0/0xab()
pci 0000:00:00.5: calling via_no_dac+0x0/0x34()
pci 0000:00:00.5: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:00.5: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:00.5: calling pci_fixup_video+0x0/0xab()
pci 0000:00:00.6: calling via_no_dac+0x0/0x34()
pci 0000:00:00.6: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:00.6: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:00.6: calling pci_fixup_video+0x0/0xab()
pci 0000:00:00.7: calling via_no_dac+0x0/0x34()
pci 0000:00:00.7: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:00.7: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:00.7: calling pci_fixup_video+0x0/0xab()
pci 0000:00:01.0: calling via_no_dac+0x0/0x34()
PCI: VIA PCI bridge detected.Disabling DAC.
pci 0000:00:01.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:01.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:01.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:02.0: calling via_no_dac+0x0/0x34()
pci 0000:00:02.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:02.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:02.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:03.0: calling via_no_dac+0x0/0x34()
pci 0000:00:03.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:03.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:03.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:03.1: calling via_no_dac+0x0/0x34()
pci 0000:00:03.1: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:03.1: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:03.1: calling pci_fixup_video+0x0/0xab()
pci 0000:00:03.2: calling via_no_dac+0x0/0x34()
pci 0000:00:03.2: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:03.2: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:03.2: calling pci_fixup_video+0x0/0xab()
pci 0000:00:03.3: calling via_no_dac+0x0/0x34()
pci 0000:00:03.3: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:03.3: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:03.3: calling pci_fixup_video+0x0/0xab()
pci 0000:00:0f.0: calling via_no_dac+0x0/0x34()
pci 0000:00:0f.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:0f.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:0f.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:0f.1: calling via_no_dac+0x0/0x34()
pci 0000:00:0f.1: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:0f.1: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:0f.1: calling pci_fixup_video+0x0/0xab()
pci 0000:00:10.0: calling via_no_dac+0x0/0x34()
pci 0000:00:10.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:10.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:10.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:10.1: calling via_no_dac+0x0/0x34()
pci 0000:00:10.1: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:10.1: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:10.1: calling pci_fixup_video+0x0/0xab()
pci 0000:00:10.2: calling via_no_dac+0x0/0x34()
pci 0000:00:10.2: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:10.2: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:10.2: calling pci_fixup_video+0x0/0xab()
pci 0000:00:10.3: calling via_no_dac+0x0/0x34()
pci 0000:00:10.3: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:10.3: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:10.3: calling pci_fixup_video+0x0/0xab()
pci 0000:00:10.4: calling via_no_dac+0x0/0x34()
pci 0000:00:10.4: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:10.4: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:10.4: calling pci_fixup_video+0x0/0xab()
pci 0000:00:11.0: calling via_no_dac+0x0/0x34()
pci 0000:00:11.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:11.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:11.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:11.7: calling via_no_dac+0x0/0x34()
pci 0000:00:11.7: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:11.7: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:11.7: calling pci_fixup_video+0x0/0xab()
pci 0000:00:13.0: calling via_no_dac+0x0/0x34()
pci 0000:00:13.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:13.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:13.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:13.1: calling via_no_dac+0x0/0x34()
pci 0000:00:13.1: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:13.1: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:13.1: calling pci_fixup_video+0x0/0xab()
pci 0000:00:18.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:18.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:18.0: calling pci_fixup_video+0x0/0xab()
pci 0000:00:18.1: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:18.1: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:18.1: calling pci_fixup_video+0x0/0xab()
pci 0000:00:18.2: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:18.2: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:18.2: calling pci_fixup_video+0x0/0xab()
pci 0000:00:18.3: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:00:18.3: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:00:18.3: calling pci_fixup_video+0x0/0xab()
pci 0000:02:00.0: calling nv_msi_ht_cap_quirk+0x0/0x103()
pci 0000:02:00.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:02:00.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:02:00.0: calling pci_fixup_video+0x0/0xab()
pci 0000:02:00.0: Boot video device
pci 0000:04:00.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:04:00.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:04:00.0: calling pci_fixup_video+0x0/0xab()
pci 0000:80:01.0: calling via_no_dac+0x0/0x34()
pci 0000:80:01.0: calling quirk_cardbus_legacy+0x0/0x22()
pci 0000:80:01.0: calling quirk_usb_early_handoff+0x0/0x3d3()
pci 0000:80:01.0: calling pci_fixup_video+0x0/0xab()
PCI: Setting latency timer of device 0000:00:02.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:02.0:pcie00]
PM: Adding info for pci_express:0000:00:02.0:pcie00
Allocate Port Service[0000:00:02.0:pcie01]
PM: Adding info for pci_express:0000:00:02.0:pcie01
Allocate Port Service[0000:00:02.0:pcie02]
PM: Adding info for pci_express:0000:00:02.0:pcie02
Allocate Port Service[0000:00:02.0:pcie03]
PM: Adding info for pci_express:0000:00:02.0:pcie03
PCI: Setting latency timer of device 0000:00:03.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.0:pcie00]
PM: Adding info for pci_express:0000:00:03.0:pcie00
Allocate Port Service[0000:00:03.0:pcie01]
PM: Adding info for pci_express:0000:00:03.0:pcie01
Allocate Port Service[0000:00:03.0:pcie02]
PM: Adding info for pci_express:0000:00:03.0:pcie02
Allocate Port Service[0000:00:03.0:pcie03]
PM: Adding info for pci_express:0000:00:03.0:pcie03
PCI: Setting latency timer of device 0000:00:03.1 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.1:pcie00]
PM: Adding info for pci_express:0000:00:03.1:pcie00
Allocate Port Service[0000:00:03.1:pcie01]
PM: Adding info for pci_express:0000:00:03.1:pcie01
Allocate Port Service[0000:00:03.1:pcie02]
PM: Adding info for pci_express:0000:00:03.1:pcie02
Allocate Port Service[0000:00:03.1:pcie03]
PM: Adding info for pci_express:0000:00:03.1:pcie03
PCI: Setting latency timer of device 0000:00:03.2 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.2:pcie00]
PM: Adding info for pci_express:0000:00:03.2:pcie00
Allocate Port Service[0000:00:03.2:pcie01]
PM: Adding info for pci_express:0000:00:03.2:pcie01
Allocate Port Service[0000:00:03.2:pcie02]
PM: Adding info for pci_express:0000:00:03.2:pcie02
Allocate Port Service[0000:00:03.2:pcie03]
PM: Adding info for pci_express:0000:00:03.2:pcie03
PCI: Setting latency timer of device 0000:00:03.3 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:03.3:pcie00]
PM: Adding info for pci_express:0000:00:03.3:pcie00
Allocate Port Service[0000:00:03.3:pcie01]
PM: Adding info for pci_express:0000:00:03.3:pcie01
Allocate Port Service[0000:00:03.3:pcie02]
PM: Adding info for pci_express:0000:00:03.3:pcie02
Allocate Port Service[0000:00:03.3:pcie03]
PM: Adding info for pci_express:0000:00:03.3:pcie03
AER service couldn't init device 0000:00:02.0:pcie01 - no _OSC support
AER service couldn't init device 0000:00:03.0:pcie01 - no _OSC support
AER service couldn't init device 0000:00:03.1:pcie01 - no _OSC support
AER service couldn't init device 0000:00:03.2:pcie01 - no _OSC support
AER service couldn't init device 0000:00:03.3:pcie01 - no _OSC support
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
PM: Adding info for No Bus:fbcon
PM: Adding info for platform:vesafb.0
PM: Adding info for No Bus:cooling_device0
ACPI: ACPI0007:00 is registered as cooling_device0
ACPI: Processor [P001] (supports 16 throttling states)
PM: Adding info for No Bus:cooling_device1
ACPI: ACPI0007:01 is registered as cooling_device1
PM: Adding info for No Bus:tty
PM: Adding info for No Bus:console
PM: Adding info for No Bus:ptmx
PM: Adding info for No Bus:tty0
PM: Adding info for No Bus:vcs
PM: Adding info for No Bus:vcsa
PM: Adding info for No Bus:tty1
PM: Adding info for No Bus:tty2
PM: Adding info for No Bus:tty3
PM: Adding info for No Bus:tty4
PM: Adding info for No Bus:tty5
PM: Adding info for No Bus:tty6
PM: Adding info for No Bus:tty7
PM: Adding info for No Bus:tty8
PM: Adding info for No Bus:tty9
PM: Adding info for No Bus:tty10
PM: Adding info for No Bus:tty11
PM: Adding info for No Bus:tty12
PM: Adding info for No Bus:tty13
PM: Adding info for No Bus:tty14
PM: Adding info for No Bus:tty15
PM: Adding info for No Bus:tty16
PM: Adding info for No Bus:tty17
PM: Adding info for No Bus:tty18
PM: Adding info for No Bus:tty19
PM: Adding info for No Bus:tty20
PM: Adding info for No Bus:tty21
PM: Adding info for No Bus:tty22
PM: Adding info for No Bus:tty23
PM: Adding info for No Bus:tty24
PM: Adding info for No Bus:tty25
PM: Adding info for No Bus:tty26
PM: Adding info for No Bus:tty27
PM: Adding info for No Bus:tty28
PM: Adding info for No Bus:tty29
PM: Adding info for No Bus:tty30
PM: Adding info for No Bus:tty31
PM: Adding info for No Bus:tty32
PM: Adding info for No Bus:tty33
PM: Adding info for No Bus:tty34
PM: Adding info for No Bus:tty35
PM: Adding info for No Bus:tty36
PM: Adding info for No Bus:tty37
PM: Adding info for No Bus:tty38
PM: Adding info for No Bus:tty39
PM: Adding info for No Bus:tty40
PM: Adding info for No Bus:tty41
PM: Adding info for No Bus:tty42
PM: Adding info for No Bus:tty43
PM: Adding info for No Bus:tty44
PM: Adding info for No Bus:tty45
PM: Adding info for No Bus:tty46
PM: Adding info for No Bus:tty47
PM: Adding info for No Bus:tty48
PM: Adding info for No Bus:tty49
PM: Adding info for No Bus:tty50
PM: Adding info for No Bus:tty51
PM: Adding info for No Bus:tty52
PM: Adding info for No Bus:tty53
PM: Adding info for No Bus:tty54
PM: Adding info for No Bus:tty55
PM: Adding info for No Bus:tty56
PM: Adding info for No Bus:tty57
PM: Adding info for No Bus:tty58
PM: Adding info for No Bus:tty59
PM: Adding info for No Bus:tty60
PM: Adding info for No Bus:tty61
PM: Adding info for No Bus:tty62
PM: Adding info for No Bus:tty63
PM: Adding info for No Bus:rtc
Real Time Clock Driver v1.12ac
PM: Adding info for No Bus:hpet
PM: Adding info for No Bus:nvram
Non-volatile memory driver v1.2
Linux agpgart interface v0.103
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
PM: Adding info for platform:serial8250
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
PM: Adding info for No Bus:ttyS0
PM: Adding info for No Bus:ttyS1
PM: Adding info for No Bus:ttyS2
PM: Adding info for No Bus:ttyS3
PM: Removing info for No Bus:ttyS0
00:0b: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
PM: Adding info for No Bus:ttyS0
PM: Adding info for No Bus:ram0
PM: Adding info for No Bus:1:0
PM: Adding info for No Bus:ram1
PM: Adding info for No Bus:1:1
PM: Adding info for No Bus:ram2
PM: Adding info for No Bus:1:2
PM: Adding info for No Bus:ram3
PM: Adding info for No Bus:1:3
PM: Adding info for No Bus:ram4
PM: Adding info for No Bus:1:4
PM: Adding info for No Bus:ram5
PM: Adding info for No Bus:1:5
PM: Adding info for No Bus:ram6
PM: Adding info for No Bus:1:6
PM: Adding info for No Bus:ram7
PM: Adding info for No Bus:1:7
PM: Adding info for No Bus:ram8
PM: Adding info for No Bus:1:8
PM: Adding info for No Bus:ram9
PM: Adding info for No Bus:1:9
PM: Adding info for No Bus:ram10
PM: Adding info for No Bus:1:10
PM: Adding info for No Bus:ram11
PM: Adding info for No Bus:1:11
PM: Adding info for No Bus:ram12
PM: Adding info for No Bus:1:12
PM: Adding info for No Bus:ram13
PM: Adding info for No Bus:1:13
PM: Adding info for No Bus:ram14
PM: Adding info for No Bus:1:14
PM: Adding info for No Bus:ram15
PM: Adding info for No Bus:1:15
brd: module loaded
PM: Adding info for No Bus:usbmon0
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
PM: Adding info for platform:i8042
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
PM: Adding info for serio:serio0
PM: Adding info for No Bus:mice
PM: Adding info for serio:serio1
mice: PS/2 mouse device common for all mice
PM: Adding info for No Bus:input0
input: AT Translated Set 2 keyboard as /class/input/input0
PM: Adding info for No Bus:event0
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
PM: Adding info for No Bus:cpu_dma_latency
PM: Adding info for No Bus:network_latency
PM: Adding info for No Bus:network_throughput
registered taskstats version 1
  Magic number: 8:862:429
debug: unmapping init memory ffffffff81423000..ffffffff81463000
Write protecting the kernel read-only data: 3604k
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:10.0[A] -> GSI 20 (level, low) -> IRQ 20
uhci_hcd 0000:00:10.0: calling quirk_via_vlink+0x0/0xc7()
uhci_hcd 0000:00:10.0: UHCI Host Controller
PM: Adding info for No Bus:usb_host1
PM: Adding info for No Bus:usbmon1
uhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:10.0: irq 20, io base 0x0000d480
PM: Adding info for usb:usb1
PM: Adding info for No Bus:usbdev1.1_ep00
usb usb1: configuration #1 chosen from 1 choice
PM: Adding info for usb:1-0:1.0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
PM: Adding info for No Bus:usbdev1.1_ep81
ACPI: PCI Interrupt 0000:00:10.1[B] -> GSI 22 (level, low) -> IRQ 22
uhci_hcd 0000:00:10.1: calling quirk_via_vlink+0x0/0xc7()
uhci_hcd 0000:00:10.1: UHCI Host Controller
PM: Adding info for No Bus:usb_host2
PM: Adding info for No Bus:usbmon2
uhci_hcd 0000:00:10.1: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:10.1: irq 22, io base 0x0000d800
PM: Adding info for usb:usb2
PM: Adding info for No Bus:usbdev2.1_ep00
usb usb2: configuration #1 chosen from 1 choice
PM: Adding info for usb:2-0:1.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
PM: Adding info for No Bus:usbdev2.1_ep81
ACPI: PCI Interrupt 0000:00:10.2[C] -> GSI 21 (level, low) -> IRQ 21
uhci_hcd 0000:00:10.2: calling quirk_via_vlink+0x0/0xc7()
uhci_hcd 0000:00:10.2: UHCI Host Controller
PM: Adding info for No Bus:usb_host3
PM: Adding info for No Bus:usbmon3
uhci_hcd 0000:00:10.2: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:10.2: irq 21, io base 0x0000d880
PM: Adding info for usb:usb3
PM: Adding info for No Bus:usbdev3.1_ep00
usb usb3: configuration #1 chosen from 1 choice
PM: Adding info for usb:3-0:1.0
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
PM: Adding info for No Bus:usbdev3.1_ep81
ACPI: PCI Interrupt 0000:00:10.3[D] -> GSI 23 (level, low) -> IRQ 23
uhci_hcd 0000:00:10.3: calling quirk_via_vlink+0x0/0xc7()
uhci_hcd 0000:00:10.3: UHCI Host Controller
PM: Adding info for No Bus:usb_host4
PM: Adding info for No Bus:usbmon4
uhci_hcd 0000:00:10.3: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:10.3: irq 23, io base 0x0000dc00
PM: Adding info for usb:usb4
usb 2-1: new low speed USB device using uhci_hcd and address 2
PM: Adding info for No Bus:usbdev4.1_ep00
usb usb4: configuration #1 chosen from 1 choice
PM: Adding info for usb:4-0:1.0
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
PM: Adding info for No Bus:usbdev4.1_ep81
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ACPI: PCI Interrupt 0000:00:10.4[C] -> GSI 21 (level, low) -> IRQ 21
ehci_hcd 0000:00:10.4: calling quirk_via_vlink+0x0/0xc7()
ehci_hcd 0000:00:10.4: EHCI Host Controller
PM: Adding info for No Bus:usb_host5
PM: Adding info for No Bus:usbmon5
ehci_hcd 0000:00:10.4: new USB bus registered, assigned bus number 5
ehci_hcd 0000:00:10.4: irq 21, io mem 0xf8fffc00
ehci_hcd 0000:00:10.4: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb 2-1: device descriptor read/all, error -71
PM: Adding info for usb:usb5
PM: Adding info for No Bus:usbdev5.1_ep00
usb usb5: configuration #1 chosen from 1 choice
PM: Adding info for usb:5-0:1.0
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 8 ports detected
hub 2-0:1.0: unable to enumerate USB device on port 1
PM: Adding info for No Bus:usbdev5.1_ep81
SCSI subsystem initialized
Driver 'sd' needs updating - please use bus_type methods
libata version 3.00 loaded.
sata_via 0000:00:0f.0: version 2.3
ACPI: PCI Interrupt 0000:00:0f.0[B] -> GSI 21 (level, low) -> IRQ 21
sata_via 0000:00:0f.0: calling quirk_via_vlink+0x0/0xc7()
sata_via 0000:00:0f.0: routed to hard irq line 10
scsi0 : sata_via
PM: Adding info for No Bus:host0
PM: Adding info for No Bus:host0
scsi1 : sata_via
PM: Adding info for No Bus:host1
PM: Adding info for No Bus:host1
ata1: SATA max UDMA/133 cmd 0xec00 ctl 0xe880 bmdma 0xe400 irq 21
ata2: SATA max UDMA/133 cmd 0xe800 ctl 0xe480 bmdma 0xe408 irq 21
ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata1.00: ATA-7: WDC WD2500KS-00MJB0, 02.01C03, max UDMA/133
ata1.00: 488397168 sectors, multi 16: LBA48 
ata1.00: configured for UDMA/133
hub 5-0:1.0: unable to enumerate USB device on port 3
ata2: SATA link down 1.5 Gbps (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      WDC WD2500KS-00M 02.0 PQ: 0 ANSI: 5
PM: Adding info for No Bus:target0:0:0
PM: Adding info for scsi:0:0:0:0
PM: Adding info for No Bus:0:0:0:0
sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
PM: Adding info for No Bus:sda
sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda:<6>usb 2-1: new low speed USB device using uhci_hcd and address 4
 sda1 sda2 sda3 sda4 < sda5 sda6 sda7 sda8 >
PM: Adding info for No Bus:sda1
PM: Adding info for No Bus:sda2
PM: Adding info for No Bus:sda3
PM: Adding info for No Bus:sda4
PM: Adding info for No Bus:sda5
PM: Adding info for No Bus:sda6
PM: Adding info for No Bus:sda7
PM: Adding info for No Bus:sda8
PM: Adding info for No Bus:8:0
sd 0:0:0:0: [sda] Attached SCSI disk
PM: Adding info for No Bus:0:0:0:0
PM: Adding info for No Bus:0:0:0:0
PM: Adding info for usb:2-1
PM: Adding info for No Bus:usbdev2.4_ep00
usb 2-1: configuration #1 chosen from 1 choice
PM: Adding info for usb:2-1:1.0
PM: Adding info for No Bus:input1
input: Microsoft Basic Optical Mouse as /class/input/input1
PM: Adding info for No Bus:mouse0
PM: Adding info for No Bus:event1
input: USB HID v1.10 Mouse [Microsoft Basic Optical Mouse] on usb-0000:00:10.1-1
PM: Adding info for No Bus:usbdev2.4_ep81
pata_via 0000:00:0f.1: version 0.3.3
pata_via 0000:00:0f.1: calling quirk_via_vlink+0x0/0xc7()
scsi2 : pata_via
PM: Adding info for No Bus:host2
PM: Adding info for No Bus:host2
scsi3 : pata_via
PM: Adding info for No Bus:host3
PM: Adding info for No Bus:host3
ata3: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xfc00 irq 14
ata4: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xfc08 irq 15
ata3.00: ATAPI: _NEC DVD_RW ND-3550A, 1.05, max UDMA/33
ata3.00: configured for UDMA/33
scsi 2:0:0:0: CD-ROM            _NEC     DVD_RW ND-3550A  1.05 PQ: 0 ANSI: 5
PM: Adding info for No Bus:target2:0:0
PM: Adding info for scsi:2:0:0:0
PM: Adding info for No Bus:2:0:0:0
PM: Adding info for No Bus:2:0:0:0
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
SELinux:  Disabled at runtime.
SELinux:  Unregistering netfilter hooks
type=1404 audit(1209817561.932:2): selinux=0 auid=4294967295 ses=4294967295
PM: Adding info for No Bus:vcs1
PM: Adding info for No Bus:vcsa1
PM: Removing info for No Bus:vcs1
PM: Removing info for No Bus:vcsa1
PM: Adding info for No Bus:vcs1
PM: Adding info for No Bus:vcsa1
PM: Removing info for No Bus:vcs1
PM: Removing info for No Bus:vcsa1
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
PM: Adding info for platform:floppy.0
PM: Adding info for No Bus:fd0
PM: Adding info for No Bus:2:0
PM: Adding info for No Bus:sg0
sd 0:0:0:0: Attached scsi generic sg0 type 0
PM: Adding info for No Bus:sg1
scsi 2:0:0:0: Attached scsi generic sg1 type 5
Driver 'sr' needs updating - please use bus_type methods
sr0: scsi3-mmc drive: 48x/48x writer cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
PM: Adding info for No Bus:sr0
PM: Adding info for No Bus:11:0
sr 2:0:0:0: Attached scsi CD-ROM sr0
PM: Adding info for No Bus:input2
input: Power Button (FF) as /class/input/input2
PM: Adding info for No Bus:event2
ACPI: Power Button (FF) [PWRF]
PM: Adding info for No Bus:input3
input: Sleep Button (CM) as /class/input/input3
PM: Adding info for No Bus:event3
ACPI: Sleep Button (CM) [SLPB]
PM: Adding info for No Bus:input4
input: Power Button (CM) as /class/input/input4
PM: Adding info for No Bus:event4
ACPI: Power Button (CM) [PWRB]
PM: Adding info for No Bus:input5
input: PC Speaker as /class/input/input5
PM: Adding info for No Bus:event5
ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 36 (level, low) -> IRQ 36
PCI: Setting latency timer of device 0000:04:00.0 to 64
atl1 0000:04:00.0: version 2.1.1
parport_pc 00:05: reported by Plug and Play ACPI
parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE,EPP]
PM: Adding info for No Bus:eth0
parport0: Printer, HEWLETT-PACKARD DESKJET 840C
PM: Adding info for platform:parport_pc.956
PM: Removing info for platform:parport_pc.956
PM: Adding info for platform:parport_pc.888
PM: Removing info for platform:parport_pc.888
PM: Adding info for platform:parport_pc.632
PM: Removing info for platform:parport_pc.632
PM: Adding info for No Bus:timer
PM: Adding info for No Bus:seq
PM: Adding info for No Bus:sequencer
PM: Adding info for No Bus:sequencer2
ACPI: PCI Interrupt 0000:80:01.0[A] -> GSI 17 (level, low) -> IRQ 17
HDA Intel 0000:80:01.0: calling quirk_via_vlink+0x0/0xc7()
PCI: Setting latency timer of device 0000:80:01.0 to 64
PCI: Disallowing DAC for device 0000:80:01.0
hda_codec: Unknown model for ALC861, trying auto-probe from BIOS...
PM: Adding info for No Bus:pcmC0D1p
PM: Adding info for No Bus:adsp
PM: Adding info for No Bus:pcmC0D0p
PM: Adding info for No Bus:pcmC0D0c
PM: Adding info for No Bus:dsp
PM: Adding info for No Bus:audio
PM: Adding info for No Bus:hwC0D0
PM: Adding info for No Bus:controlC0
PM: Adding info for No Bus:mixer
PM: Adding info for No Bus:vcs1
PM: Adding info for No Bus:vcsa1
PM: Removing info for No Bus:vcs1
PM: Removing info for No Bus:vcsa1
PM: Adding info for No Bus:device-mapper
device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initialised: dm-devel@redhat.com
device-mapper: multipath: version 1.0.5 loaded
EXT3 FS on sda7, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda6, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda8, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
warning: process `kudzu' used the deprecated sysctl system call with 1.23.
powernow-k8: Found 1 AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ processors (2 cpu cores) (version 2.20.00)
powernow-k8:    0 : fid 0xc (2000 MHz), vid 0x8
powernow-k8:    1 : fid 0xa (1800 MHz), vid 0xa
powernow-k8:    2 : fid 0x2 (1000 MHz), vid 0x12
Clocksource tsc unstable (delta = -147933304 ns)
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
ip6_tables: (C) 2000-2006 Netfilter Core Team
ip_tables: (C) 2000-2006 Netfilter Core Team
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
atl1 0000:04:00.0: Unable to enable MSI: -22
atl1 0000:04:00.0: eth0 link is up 1000 Mbps full duplex
warning: `dbus-daemon' uses 32-bit capabilities (legacy support in use)
fuse init (API version 7.9)
PM: Adding info for No Bus:fuse
eth0: no IPv6 routers present
PM: Adding info for No Bus:vcs2
PM: Adding info for No Bus:vcsa2
PM: Removing info for No Bus:vcs2
PM: Removing info for No Bus:vcsa2
PM: Adding info for No Bus:vcs2
PM: Adding info for No Bus:vcsa2
PM: Adding info for No Bus:vcs5
PM: Adding info for No Bus:vcsa5
PM: Removing info for No Bus:vcs5
PM: Removing info for No Bus:vcsa5
PM: Adding info for No Bus:vcs5
PM: Adding info for No Bus:vcsa5
PM: Adding info for No Bus:vcs6
PM: Adding info for No Bus:vcsa6
PM: Removing info for No Bus:vcs6
PM: Removing info for No Bus:vcsa6
PM: Adding info for No Bus:vcs6
PM: Adding info for No Bus:vcsa6
PM: Adding info for No Bus:vcs1
PM: Adding info for No Bus:vcsa1
PM: Removing info for No Bus:vcs1
PM: Removing info for No Bus:vcsa1
PM: Adding info for No Bus:vcs1
PM: Adding info for No Bus:vcsa1
PM: Adding info for No Bus:vcs3
PM: Adding info for No Bus:vcsa3
PM: Removing info for No Bus:vcs3
PM: Removing info for No Bus:vcsa3
PM: Adding info for No Bus:vcs3
PM: Adding info for No Bus:vcsa3
PM: Adding info for No Bus:vcs4
PM: Adding info for No Bus:vcsa4
PM: Removing info for No Bus:vcs4
PM: Removing info for No Bus:vcsa4
PM: Adding info for No Bus:vcs4
PM: Adding info for No Bus:vcsa4
PM: Adding info for No Bus:vcs7
PM: Adding info for No Bus:vcsa7
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 24 (level, low) -> IRQ 24

--MP_/Ro3VZ+TBrBNm0/e0QTfWH2=
Content-Type: text/plain; name=atl1-4g-corrupt-config.txt
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=atl1-4g-corrupt-config.txt

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.25
# Sat May  3 12:02:27 2008
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_DEFCONFIG_LIST="arch/x86/configs/x86_64_defconfig"
# CONFIG_GENERIC_LOCKBREAK is not set
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
# CONFIG_GENERIC_GPIO is not set
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_GENERIC_SPINLOCK=y
# CONFIG_RWSEM_XCHGADD_ALGORITHM is not set
# CONFIG_ARCH_HAS_ILOG2_U32 is not set
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_AOUT=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_X86_SMP=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_BIOS_REBOOT=y
CONFIG_X86_TRAMPOLINE=y
# CONFIG_KTIME_SCALAR is not set

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_TREE=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
# CONFIG_CGROUPS is not set
CONFIG_GROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_USER_SCHED=y
# CONFIG_CGROUP_SCHED is not set
CONFIG_SYSFS_DEPRECATED=y
CONFIG_SYSFS_DEPRECATED_V2=y
CONFIG_RELAY=y
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
CONFIG_USER_NS=y
# CONFIG_PID_NS is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
# CONFIG_EMBEDDED is not set
CONFIG_SYSCTL_SYSCALL=y
CONFIG_SYSCTL_SYSCALL_CHECK=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_EXTRA_PASS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_COMPAT_BRK=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_ANON_INODES=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
# CONFIG_MARKERS is not set
CONFIG_OPROFILE=m
CONFIG_HAVE_OPROFILE=y
CONFIG_KPROBES=y
CONFIG_KRETPROBES=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
# CONFIG_HAVE_DMA_ATTRS is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_KMOD=y
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_BLK_DEV_BSG=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_CLASSIC_RCU=y

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_X86_PC=y
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_NUMAQ is not set
# CONFIG_X86_SUMMIT is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_VISWS is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_ES7000 is not set
# CONFIG_X86_RDC321X is not set
# CONFIG_X86_VSMP is not set
# CONFIG_PARAVIRT_GUEST is not set
CONFIG_MEMTEST_BOOTPARAM=y
CONFIG_MEMTEST_BOOTPARAM_VALUE=0
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
CONFIG_MK8=y
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP2 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_CPU=y
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=32
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_I8K=m
CONFIG_MICROCODE=m
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y

#
# Memory hotplug is currently incompatible with Software Suspend
#
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_RESOURCES_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MTRR=y
# CONFIG_X86_PAT is not set
CONFIG_EFI=y
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_VERBOSE=y
CONFIG_CAN_PM_TRACE=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_SLEEP=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_BAY=m
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_WMI is not set
# CONFIG_ACPI_ASUS is not set
CONFIG_ACPI_TOSHIBA=m
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_SYSTEM=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_SBS=m

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=m
CONFIG_CPU_FREQ_DEBUG=y
CONFIG_CPU_FREQ_STAT=m
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=m
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

#
# CPUFreq processor drivers
#
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_POWERNOW_K8_ACPI=y
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=m

#
# shared options
#
# CONFIG_X86_ACPI_CPUFREQ_PROC_INTF is not set
CONFIG_X86_SPEEDSTEP_LIB=m
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_DMAR is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=m
CONFIG_PCIEAER=y
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
CONFIG_PCI_LEGACY=y
CONFIG_PCI_DEBUG=y
CONFIG_HT_IRQ=y
CONFIG_ISA_DMA_API=y
CONFIG_K8_NB=y
# CONFIG_PCCARD is not set
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_FAKE=m
CONFIG_HOTPLUG_PCI_ACPI=m
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_MISC=y
# CONFIG_IA32_EMULATION is not set
# CONFIG_COMPAT_FOR_U64_ALIGNMENT is not set

#
# Networking
#
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_ASK_IP_FIB_HASH=y
# CONFIG_IP_FIB_TRIE is not set
CONFIG_IP_FIB_HASH=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
# CONFIG_INET_LRO is not set
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=m
CONFIG_TCP_CONG_ILLINOIS=m
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IP_VS=m
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IPV6=m
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=m
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
CONFIG_IPV6_SIT=m
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
# CONFIG_IPV6_MROUTE is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_CT_ACCT=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CT_PROTO_DCCP is not set
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=m
CONFIG_NF_CT_PROTO_UDPLITE=m
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
CONFIG_NETFILTER_XTABLES=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
# CONFIG_NETFILTER_XT_TARGET_RATEEST is not set
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
# CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP is not set
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
# CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
# CONFIG_NETFILTER_XT_MATCH_TIME is not set
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_CONNTRACK_IPV4=m
# CONFIG_NF_CONNTRACK_PROC_COMPAT is not set
CONFIG_IP_NF_QUEUE=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_RECENT=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_MATCH_ADDRTYPE=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_LOG=m
CONFIG_IP_NF_TARGET_ULOG=m
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_PROTO_UDPLITE=m
CONFIG_NF_NAT_PROTO_SCTP=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_NF_NAT_SIP=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_CONNTRACK_IPV6=m
CONFIG_IP6_NF_QUEUE=m
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_RT=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_LOG=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_RAW=m

#
# Bridge: Netfilter Configuration
#
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_ULOG=m
# CONFIG_BRIDGE_EBT_NFLOG is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=m
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
CONFIG_BRIDGE=m
CONFIG_VLAN_8021Q=m
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_RR=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_INGRESS=m

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_ROUTE=y
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
# CONFIG_NET_CLS_FLOW is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_ACT_IPT=m
# CONFIG_NET_ACT_NAT is not set
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_NET_TCPPROBE is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y

#
# Wireless
#
# CONFIG_CFG80211 is not set
# CONFIG_WIRELESS_EXT is not set
# CONFIG_MAC80211 is not set
# CONFIG_IEEE80211 is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=m
# CONFIG_MTD_DEBUG is not set
CONFIG_MTD_CONCAT=m
CONFIG_MTD_PARTITIONS=y
CONFIG_MTD_REDBOOT_PARTS=m
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_CHAR=m
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
CONFIG_MTD_BLOCK_RO=m
CONFIG_FTL=m
CONFIG_NFTL=m
CONFIG_NFTL_RW=y
CONFIG_INFTL=m
CONFIG_RFD_FTL=m
CONFIG_SSFDC=m
# CONFIG_MTD_OOPS is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=m
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=m
CONFIG_MTD_CFI_AMDSTD=m
CONFIG_MTD_CFI_STAA=m
CONFIG_MTD_CFI_UTIL=m
CONFIG_MTD_RAM=m
CONFIG_MTD_ROM=m
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_SC520CDP=m
CONFIG_MTD_NETSC520=m
CONFIG_MTD_TS5500=m
# CONFIG_MTD_SBC_GXX is not set
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
CONFIG_MTD_ESB2ROM=m
CONFIG_MTD_CK804XROM=m
CONFIG_MTD_SCB2_FLASH=m
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_DILNETPC is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_PCI=m
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=m
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOC2000 is not set
# CONFIG_MTD_DOC2001 is not set
# CONFIG_MTD_DOC2001PLUS is not set
CONFIG_MTD_NAND=m
# CONFIG_MTD_NAND_VERIFY_WRITE is not set
CONFIG_MTD_NAND_ECC_SMC=y
# CONFIG_MTD_NAND_MUSEUM_IDS is not set
CONFIG_MTD_NAND_IDS=m
CONFIG_MTD_NAND_DISKONCHIP=m
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
CONFIG_MTD_NAND_CAFE=m
CONFIG_MTD_NAND_NANDSIM=m
# CONFIG_MTD_NAND_PLATFORM is not set
# CONFIG_MTD_ALAUDA is not set
# CONFIG_MTD_ONENAND is not set

#
# UBI - Unsorted block images
#
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_RESERVE=1
# CONFIG_MTD_UBI_GLUEBI is not set

#
# UBI debugging options
#
# CONFIG_MTD_UBI_DEBUG is not set
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=m
CONFIG_PARIDE=m

#
# Parallel IDE high-level drivers
#
CONFIG_PARIDE_PD=m
CONFIG_PARIDE_PCD=m
CONFIG_PARIDE_PF=m
CONFIG_PARIDE_PT=m
CONFIG_PARIDE_PG=m

#
# Parallel IDE protocol modules
#
# CONFIG_PARIDE_ATEN is not set
# CONFIG_PARIDE_BPCK is not set
# CONFIG_PARIDE_COMM is not set
# CONFIG_PARIDE_DSTR is not set
# CONFIG_PARIDE_FIT2 is not set
# CONFIG_PARIDE_FIT3 is not set
# CONFIG_PARIDE_EPAT is not set
# CONFIG_PARIDE_EPIA is not set
# CONFIG_PARIDE_FRIQ is not set
# CONFIG_PARIDE_FRPW is not set
# CONFIG_PARIDE_KBIC is not set
# CONFIG_PARIDE_KTTI is not set
# CONFIG_PARIDE_ON20 is not set
# CONFIG_PARIDE_ON26 is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_CRYPTOLOOP=m
CONFIG_BLK_DEV_NBD=m
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_MISC_DEVICES=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=m
# CONFIG_TIFM_7XX1 is not set
# CONFIG_ACER_WMI is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=m
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=m
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
# CONFIG_SCSI_FC_TGT_ATTRS is not set
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
# CONFIG_SCSI_SAS_LIBSAS_DEBUG is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_GDTH=m
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_SRP is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y
CONFIG_SATA_AHCI=m
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y
# CONFIG_SATA_SVW is not set
CONFIG_ATA_PIIX=m
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
CONFIG_SATA_VIA=m
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_PATA_ACPI is not set
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_ATA_GENERIC=m
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
CONFIG_PATA_MPIIX=m
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
CONFIG_PATA_VIA=m
# CONFIG_PATA_WINBOND is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_RAID5_RESHAPE=y
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
CONFIG_BLK_DEV_DM=m
CONFIG_DM_DEBUG=y
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_MIRROR=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_EMC=m
CONFIG_DM_MULTIPATH_RDAC=m
# CONFIG_DM_MULTIPATH_HP is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
# CONFIG_NETDEVICES_MULTIQUEUE is not set
CONFIG_IFB=m
CONFIG_DUMMY=m
CONFIG_BONDING=m
CONFIG_MACVLAN=m
CONFIG_EQUALIZER=m
CONFIG_TUN=m
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_PHYLIB is not set
CONFIG_NET_ETHERNET=y
CONFIG_MII=m
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_TULIP is not set
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
# CONFIG_NET_PCI is not set
# CONFIG_B44 is not set
# CONFIG_NET_POCKET is not set
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_E1000E_ENABLED is not set
# CONFIG_IP1000 is not set
# CONFIG_IGB is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_R8169=m
CONFIG_R8169_NAPI=y
CONFIG_R8169_VLAN=y
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set
CONFIG_ATL1=m
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set
# CONFIG_IWLWIFI is not set
# CONFIG_IWLWIFI_LEDS is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
CONFIG_PLIP=m
CONFIG_PPP=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_PPP_DEFLATE=m
# CONFIG_PPP_BSDCOMP is not set
CONFIG_PPP_MPPE=m
CONFIG_PPPOE=m
CONFIG_PPPOL2TP=m
CONFIG_SLIP=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLHC=m
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
# CONFIG_NET_FC is not set
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NETPOLL_TRAP=y
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=m

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=m
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
CONFIG_INPUT_UINPUT=m

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_DEVKMEM=y
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_COMPUTONE is not set
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_DIGIEPCA is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_ISI is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_N_HDLC is not set
# CONFIG_RISCOM8 is not set
# CONFIG_SPECIALIX is not set
# CONFIG_SX is not set
# CONFIG_RIO is not set
# CONFIG_STALDRV is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_CONSOLE_POLL=y
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_PRINTER=m
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=m
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_NVRAM=y
CONFIG_RTC=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
CONFIG_MWAVE=m
# CONFIG_PC8736x_GPIO is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
# CONFIG_HPET_RTC_IRQ is not set
# CONFIG_HPET_MMAP is not set
CONFIG_HANGCHECK_TIMER=m
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_ALGOBIT=m

#
# I2C Hardware Bus support
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=m
# CONFIG_I2C_I810 is not set
CONFIG_I2C_PIIX4=m
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PARPORT is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_PROSAVAGE is not set
# CONFIG_I2C_SAVAGE4 is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_TINY_USB is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set
# CONFIG_I2C_VOODOO3 is not set
# CONFIG_I2C_PCA_PLATFORM is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_DS1682 is not set
CONFIG_SENSORS_EEPROM=m
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_PCF8575 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_MAX6875 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set
# CONFIG_SPI is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7473 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHER is not set
# CONFIG_SENSORS_FSCPOS is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_CORETEMP=m
# CONFIG_SENSORS_IBMPEX is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_HWMON_DEBUG_CHIP is not set
CONFIG_THERMAL=y
CONFIG_WATCHDOG=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_SC520_WDT is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=m
CONFIG_ITCO_WDT=m
CONFIG_ITCO_VENDOR_SUPPORT=y
# CONFIG_IT8712F_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set

#
# Sonics Silicon Backplane
#
CONFIG_SSB_POSSIBLE=y
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set

#
# Multimedia devices
#

#
# Multimedia core support
#
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2_COMMON=m
# CONFIG_VIDEO_ALLOW_V4L1 is not set
CONFIG_VIDEO_V4L1_COMPAT=y
# CONFIG_DVB_CORE is not set
CONFIG_VIDEO_MEDIA=m

#
# Multimedia drivers
#
CONFIG_MEDIA_TUNER=m
# CONFIG_MEDIA_TUNER_CUSTOMIZE is not set
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_CAPTURE_DRIVERS is not set
# CONFIG_RADIO_ADAPTERS is not set
# CONFIG_DAB is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_DRM=m
CONFIG_DRM_TDFX=m
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_I810=m
CONFIG_DRM_I830=m
CONFIG_DRM_I915=m
CONFIG_DRM_MGA=m
CONFIG_DRM_SIS=m
CONFIG_DRM_VIA=m
CONFIG_DRM_SAVAGE=m
CONFIG_VGASTATE=m
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=m
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
CONFIG_FB_VGA16=m
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
# CONFIG_FB_EFI is not set
# CONFIG_FB_IMAC is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_LE80578 is not set
CONFIG_FB_INTEL=m
# CONFIG_FB_INTEL_DEBUG is not set
CONFIG_FB_INTEL_I2C=y
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_VIRTUAL is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_CORGI is not set
CONFIG_BACKLIGHT_PROGEAR=m

#
# Display device support
#
CONFIG_DISPLAY_SUPPORT=m

#
# Display hardware drivers
#

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_VIDEO_SELECT=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y

#
# Sound
#
CONFIG_SOUND=m

#
# Advanced Linux Sound Architecture
#
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
CONFIG_SND_PCM_OSS=m
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_RTCTIMER=m
CONFIG_SND_SEQ_RTCTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y

#
# Generic devices
#
# CONFIG_SND_PCSP is not set
CONFIG_SND_MPU401_UART=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DUMMY=m
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set
# CONFIG_SND_PORTMAN2X4 is not set

#
# PCI devices
#
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_ATIHDMI=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_HIFIER is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0

#
# USB devices
#
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_USX2Y is not set
# CONFIG_SND_USB_CAIAQ is not set

#
# System on Chip audio support
#
# CONFIG_SND_SOC is not set

#
# ALSA SoC audio for Freescale SOCs
#

#
# SoC Audio for the Texas Instruments OMAP
#

#
# Open Sound System
#
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=m
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
CONFIG_HID_DEBUG=y
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=y
CONFIG_USB_HIDINPUT_POWERBOOK=y
CONFIG_HID_FF=y
CONFIG_HID_PID=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_PANTHERLORD_FF=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_ZEROPLUS_FF=y
CONFIG_USB_HIDDEV=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_SUSPEND=y
# CONFIG_USB_OTG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
# CONFIG_USB_ISP116X_HCD is not set
CONFIG_USB_OHCI_HCD=m
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=m
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# may also be needed; see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
# CONFIG_USB_STORAGE_ISD200 is not set
CONFIG_USB_STORAGE_DPCM=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
# CONFIG_USB_STORAGE_ONETOUCH is not set
CONFIG_USB_STORAGE_KARMA=y
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
CONFIG_USB_MON=y

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
CONFIG_USB_LED=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_GADGET is not set
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set

#
# MMC/SD Card Drivers
#
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_BOUNCE=y
# CONFIG_SDIO_UART is not set

#
# MMC/SD Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
# CONFIG_MMC_RICOH_MMC is not set
CONFIG_MMC_WBSD=m
CONFIG_MMC_TIFM_SD=m
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_CLEVO_MAIL is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y

#
# Reporting subsystems
#
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=m
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82975X=m
CONFIG_EDAC_I3000=m
CONFIG_EDAC_I5000=m
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=m
CONFIG_UIO_CIF=m
# CONFIG_UIO_SMX is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_EFI_VARS=y
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT2_FS_XIP=y
CONFIG_FS_XIP=y
CONFIG_EXT3_FS=m
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=m
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=m
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_DNOTIFY=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS_FS=m
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=m
CONFIG_GENERIC_ACL=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
CONFIG_ROMFS_FS=m
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_BIND34=y
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_RPCSEC_GSS_SPKM3=m
# CONFIG_SMB_FS is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_EXPERIMENTAL is not set
CONFIG_NCP_FS=m
CONFIG_NCPFS_PACKET_SIGNING=y
CONFIG_NCPFS_IOCTL_LOCKING=y
CONFIG_NCPFS_STRONG=y
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
CONFIG_NCPFS_SMALLDOS=y
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
CONFIG_CODA_FS=m
# CONFIG_CODA_FS_OLD_API is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
CONFIG_DETECT_SOFTLOCKUP=y
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_SPINLOCK_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_SG is not set
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_LKDTM is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_SAMPLES is not set
CONFIG_KGDB=y
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
CONFIG_KGDB_TESTS=y
# CONFIG_KGDB_TESTS_ON_BOOT is not set
# CONFIG_NONPROMISC_DEVMEM is not set
CONFIG_EARLY_PRINTK=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_PAGEALLOC=y
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
# CONFIG_DIRECT_GBPAGES is not set
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_NX_TEST is not set
CONFIG_X86_MPPARSE=y
# CONFIG_IOMMU_DEBUG is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
CONFIG_SECURITY=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_CAPABILITIES=y
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
# CONFIG_SECURITY_ROOTPLUG is not set
CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR=0
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
CONFIG_SECURITY_SELINUX_DISABLE=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
CONFIG_SECURITY_SELINUX_ENABLE_SECMARK_DEFAULT=y
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
# CONFIG_SECURITY_SMACK is not set
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=m
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
# CONFIG_CRYPTO_CTR is not set
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
# CONFIG_CRYPTO_XTS is not set

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=m
# CONFIG_CRYPTO_AES_X86_64 is not set
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=m
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=m
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y

--MP_/Ro3VZ+TBrBNm0/e0QTfWH2=--
