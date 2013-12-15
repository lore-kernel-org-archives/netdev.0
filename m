From: Fengguang Wu <fengguang.wu@intel.com>
Subject: __udp4_lib_rcv: inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
Date: Sun, 15 Dec 2013 14:39:25 +0800
Message-ID: <20131215063925.GC26348@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

commit 975022310233fb0f0193873d79a7b8438070fa82
Author:     Eric Dumazet <edumazet@google.com>
AuthorDate: Wed Dec 11 14:46:51 2013 -0800
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Wed Dec 11 20:21:10 2013 -0500

    udp: ipv4: must add synchronization in udp_sk_rx_dst_set()
    
    Unlike TCP, UDP input path does not hold the socket lock.
    
    Before messing with sk->sk_rx_dst, we must use a spinlock, otherwise
    multiple cpus could leak a refcount.
    
    This patch also takes care of renewing a stale dst entry.
    (When the sk->sk_rx_dst would not be used by IP early demux)
    
    Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

+----------------------------------------------+----+
|                                              |    |
+----------------------------------------------+----+
| boot_successes                               | 0  |
| boot_failures                                | 19 |
| inconsistent_SOFTIRQ-ON-W-IN-SOFTIRQ-W_usage | 19 |
+----------------------------------------------+----+

[   23.564204] [ INFO: inconsistent lock state ]
[   23.564204] 3.13.0-rc3-00689-gb1daf37 #892 Not tainted
[   23.564204] ---------------------------------
[   23.564204] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[   23.564204] swapper/0/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   23.564204]  (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<ffffffff81a27fe2>] __udp4_lib_rcv+0x569/0x79d
[   23.564204] {SOFTIRQ-ON-W} state was registered at:
[   23.564204]   [<ffffffff810b16b7>] __lock_acquire+0x96c/0x185f
[   23.564204]   [<ffffffff810b2c97>] lock_acquire+0xab/0x12e
[   23.564204]   [<ffffffff81af12d3>] _raw_spin_lock+0x3b/0x6d
[   23.564204]   [<ffffffff81a2f13d>] inet_bind+0x18d/0x1dc
[   23.564204]   [<ffffffff8199d62c>] kernel_bind+0x10/0x12
[   23.564204]   [<ffffffff81aae764>] xs_bind+0xa0/0x11e
[   23.564204]   [<ffffffff81ab0271>] xs_create_sock.isra.14+0x20b/0x230
[   23.564204]   [<ffffffff81ab047f>] xs_tcp_setup_socket+0x5f/0x3e5
[   23.564204]   [<ffffffff8108a0d7>] process_one_work+0x247/0x443
[   23.564204]   [<ffffffff8108aeac>] worker_thread+0x1d2/0x2bc
[   23.564204]   [<ffffffff81090228>] kthread+0xf9/0x101
[   23.564204]   [<ffffffff81af92fc>] ret_from_fork+0x7c/0xb0
[   23.564204] irq event stamp: 514170
[   23.564204] hardirqs last  enabled at (514170): [<ffffffff810766af>] local_bh_enable+0xab/0xb5
[   23.564204] hardirqs last disabled at (514169): [<ffffffff8107665a>] local_bh_enable+0x56/0xb5
[   23.564204] softirqs last  enabled at (514148): [<ffffffff81076106>] _local_bh_enable+0x43/0x45
[   23.564204] softirqs last disabled at (514149): [<ffffffff81076779>] irq_exit+0x59/0xa0
[   23.564204] 
[   23.564204] other info that might help us debug this:
[   23.564204]  Possible unsafe locking scenario:
[   23.564204] 
[   23.564204]        CPU0
[   23.564204]        ----
[   23.564204]   lock(&(&sk->sk_dst_lock)->rlock);
[   23.564204]   <Interrupt>
[   23.564204]     lock(&(&sk->sk_dst_lock)->rlock);
[   23.564204] 
[   23.564204]  *** DEADLOCK ***
[   23.564204] 
[   23.564204] 2 locks held by swapper/0/0:
[   23.564204]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff819b258a>] __netif_receive_skb_core+0x168/0x58e
[   23.564204]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff81a0086a>] ip_local_deliver_finish+0x2f/0x2a0
[   23.564204] 
[   23.564204] stack backtrace:
[   23.564204] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-rc3-00689-gb1daf37 #892
[   23.564204] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   23.564204]  0000000000000002 ffff88001ea039a0 ffffffff81ae56fd ffffffff82097490
[   23.564204]  ffff88001ea039f0 ffffffff81addae7 0000000000000001 ffff880000000001
[   23.564204]  ffff880000000000 ffffffff82097c08 0000000000000004 0000000000000006
[   23.564204] Call Trace:
[   23.564204]  <IRQ>  [<ffffffff81ae56fd>] dump_stack+0x4d/0x66
[   23.564204]  [<ffffffff81addae7>] print_usage_bug+0x2a8/0x2b9
[   23.564204]  [<ffffffff810af93a>] ? print_shortest_lock_dependencies+0x193/0x193
[   23.564204]  [<ffffffff810b05b5>] mark_lock+0x33c/0x57c
[   23.564204]  [<ffffffff810b1645>] __lock_acquire+0x8fa/0x185f
[   23.564204]  [<ffffffff8109fd9c>] ? sched_clock_local+0x12/0x72
[   23.564204]  [<ffffffff810addfa>] ? trace_hardirqs_off_caller+0x1f/0xb2
[   23.564204]  [<ffffffff810b2c97>] lock_acquire+0xab/0x12e
[   23.564204]  [<ffffffff81a27fe2>] ? __udp4_lib_rcv+0x569/0x79d
[   23.564204]  [<ffffffff810addfa>] ? trace_hardirqs_off_caller+0x1f/0xb2
[   23.564204]  [<ffffffff81af12d3>] _raw_spin_lock+0x3b/0x6d
[   23.564204]  [<ffffffff81a27fe2>] ? __udp4_lib_rcv+0x569/0x79d
[   23.564204]  [<ffffffff81a27fe2>] __udp4_lib_rcv+0x569/0x79d
[   23.564204]  [<ffffffff81a286ae>] udp_rcv+0x1a/0x1c
[   23.564204]  [<ffffffff81a0098c>] ip_local_deliver_finish+0x151/0x2a0
[   23.564204]  [<ffffffff81a0086a>] ? ip_local_deliver_finish+0x2f/0x2a0
[   23.564204]  [<ffffffff81a0109e>] ip_local_deliver+0x7a/0x7f
[   23.564204]  [<ffffffff81a00e75>] ip_rcv_finish+0x39a/0x461
[   23.564204]  [<ffffffff81a01326>] ip_rcv+0x283/0x2e0
[   23.564204]  [<ffffffff819b28ef>] __netif_receive_skb_core+0x4cd/0x58e
[   23.564204]  [<ffffffff819b258a>] ? __netif_receive_skb_core+0x168/0x58e
[   23.564204]  [<ffffffff819b2dd6>] __netif_receive_skb+0x1d/0x5f
[   23.564204]  [<ffffffff819b2e80>] netif_receive_skb+0x68/0xf4
[   23.564204]  [<ffffffff819b35da>] napi_gro_receive+0x3e/0x80
[   23.564204]  [<ffffffff817be870>] e1000_clean_rx_irq+0x393/0x415
[   23.564204]  [<ffffffff817bcd48>] e1000_clean+0x59d/0x71f
[   23.564204]  [<ffffffff810634d1>] ? kvm_clock_read+0x27/0x31
[   23.564204]  [<ffffffff8103edd0>] ? sched_clock+0x9/0xd
[   23.564204]  [<ffffffff819b3ed0>] net_rx_action+0xf6/0x210
[   23.564204]  [<ffffffff810762fc>] __do_softirq+0xf3/0x27a
[   23.564204]  [<ffffffff81076779>] irq_exit+0x59/0xa0
[   23.564204]  [<ffffffff81afb44d>] do_IRQ+0x9d/0xb4
[   23.564204]  [<ffffffff81af21f2>] common_interrupt+0x72/0x72
[   23.564204]  <EOI>  [<ffffffff81af5ab5>] ? __atomic_notifier_call_chain+0x5/0x9c
[   23.564204]  [<ffffffff810636c8>] ? native_safe_halt+0x6/0x8
[   23.564204]  [<ffffffff8103f9d1>] default_idle+0x38/0xc1
[   23.564204]  [<ffffffff81040154>] arch_cpu_idle+0x18/0x28
[   23.564204]  [<ffffffff810c0ac5>] cpu_startup_entry+0x15c/0x24d
[   23.564204]  [<ffffffff81ad1f25>] rest_init+0xc9/0xcd
[   23.564204]  [<ffffffff81ad1e61>] ? rest_init+0x5/0xcd
[   23.564204]  [<ffffffff823aed77>] start_kernel+0x3d4/0x3e0
[   23.564204]  [<ffffffff823ae7b1>] ? repair_env_string+0x58/0x58
[   23.564204]  [<ffffffff823ae120>] ? early_idt_handlers+0x120/0x120
[   23.564204]  [<ffffffff823ae467>] x86_64_start_reservations+0x2a/0x2c
[   23.564204]  [<ffffffff823ae5a9>] x86_64_start_kernel+0x140/0x14d
[   66.435785] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   66.440815] NFSD: starting 90-second grace period (net ffffffff82196a80)
Kernel tests: Boot OK!

git bisect start b1daf37ff52cf2ff39b2db2399e052ad7965c6aa 374b105797c3d4f29c685f3be535c35f5689b30e --
git bisect  bad c2f84f5177293270c0203fabfd600e11e211fd73  # 12:07      0-      1  Merge 'net/master' into devel-xian-x86_64-201312131052
git bisect good 2481b0b9a5f7af0f748a18a9710371a9cb22c986  # 12:41     20+      1  Merge 'arm-soc/to-build' into devel-xian-x86_64-201312131052
git bisect good c8781cf4a309ae4d1393f5878d4e51987665898c  # 13:08     20+      0  bnx2x: avoid null pointer dereference when enabling SR-IOV
git bisect good fffc15a5012e9052d3b236efc56840841a125416  # 13:36     20+      0  vxlan: release rt when found circular route
git bisect good 4bd7b5127bd02c12c1cc837a7a0b6ce295eb2505  # 13:50     20+      0  micrel: add support for KSZ8041RNLI
git bisect good 9508fdde4d53f0d9e583e841ed08796d2f310be1  # 14:14     20+      1  Revert "8390 : Replace ei_debug with msg_enable/NETIF_MSG_* feature"
git bisect  bad 10574059ce0451c6572c85329c772aa15085f8eb  # 14:28      0-      1  xen-netback: napi: fix abuse of budget
git bisect  bad 975022310233fb0f0193873d79a7b8438070fa82  # 14:28      0-      8  udp: ipv4: must add synchronization in udp_sk_rx_dst_set()
git bisect good a1bf1750871a6f242b0fdb174cc55d2c57e7ed66  # 14:34     25+      0  net:fec: remove duplicate lines in comment about errata ERR006358
# first bad commit: [975022310233fb0f0193873d79a7b8438070fa82] udp: ipv4: must add synchronization in udp_sk_rx_dst_set()
git bisect good a1bf1750871a6f242b0fdb174cc55d2c57e7ed66  # 14:46     75+      0  net:fec: remove duplicate lines in comment about errata ERR006358
git bisect  bad b1daf37ff52cf2ff39b2db2399e052ad7965c6aa  # 14:46      0-     19  Merge 'security/for-linus' into devel-xian-x86_64-201312131052
git bisect good 2cd6a37a65f578f7e23e67986107422ad3c012ba  # 15:23     75+      0  Revert "udp: ipv4: must add synchronization in udp_sk_rx_dst_set()"
git bisect good 8ae516aa8b8161254d3e402b3348b2a9b8d1efd0  # 15:54     75+      1  Merge tag 'trace-fixes-v3.13-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-trace
git bisect  bad 1a63d5777d237952bb06f1a2481c3acc366aeb8d  # 15:57      0-      9  Add linux-next specific files for 20131213

Thanks,
Fengguang

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-nfsroot-cairo-7:20131213110650:x86_64-nfsroot:3.13.0-rc3-00689-gb1daf37:892"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.13.0-rc3-00689-gb1daf37 (kbuild@xian) (gcc v=
ersion 4.8.1 (Debian 4.8.1-8) ) #892 SMP Fri Dec 13 10:57:18 CST 2013
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled panic=3D10 load_ramdisk=3D2 prompt=
_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::nf=
sroot-cairo-7::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actimeo=
=3D600,nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-tests/run-que=
ue/kvm/x86_64-nfsroot/devel-xian-x86_64-201312131052/.vmlinuz-b1daf37ff52cf=
2ff39b2db2399e052ad7965c6aa-20131213105809-3-cairo branch=3Dlinux-devel/dev=
el-xian-x86_64-201312131052 BOOT_IMAGE=3D/kernel/x86_64-nfsroot/b1daf37ff52=
cf2ff39b2db2399e052ad7965c6aa/vmlinuz-3.13.0-rc3-00689-gb1daf37
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   Centaur CentaurHauls
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffe000-0x000000001fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x1fffe max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[ffff8800000fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0305d000, 0x0305dfff] PGTABLE
[    0.000000] BRK [0x0305e000, 0x0305efff] PGTABLE
[    0.000000] BRK [0x0305f000, 0x0305ffff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x1fc00000-0x1fdfffff]
[    0.000000]  [mem 0x1fc00000-0x1fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1c000000-0x1fbfffff]
[    0.000000]  [mem 0x1c000000-0x1fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x1bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x1bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1fe00000-0x1fffdfff]
[    0.000000]  [mem 0x1fe00000-0x1fffdfff] page 4k
[    0.000000] BRK [0x03060000, 0x03060fff] PGTABLE
[    0.000000] ACPI: RSDP 00000000000fd930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffe450 000034 (v01 BOCHS  BXPCRSDT 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001fffff80 000074 (v01 BOCHS  BXPCFACP 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffe490 0011A9 (v01   BXPC   BXDSDT 0000=
0001 INTL 20100528)
[    0.000000] ACPI: FACS 000000001fffff40 000040
[    0.000000] ACPI: SSDT 000000001ffff7a0 000796 (v01 BOCHS  BXPCSSDT 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001ffff680 000080 (v01 BOCHS  BXPCAPIC 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001ffff640 000038 (v01 BOCHS  BXPCHPET 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffdfff]
[    0.000000]   NODE_DATA [mem 0x1fff9000-0x1fffdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1fff8001, boot clock
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001ee0000=
0-ffff88001f5fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffdfff]
[    0.000000] On node 0 totalpages: 130972
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 126974 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:2 nr_=
node_ids:1
[    0.000000] PERCPU: Embedded 476 pages/cpu @ffff88001ea00000 s1920832 r8=
192 d20672 u2097152
[    0.000000] pcpu-alloc: s1920832 r8192 d20672 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:1fff8001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1ea0d200
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 128903
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 load_ramdisk=3D2=
 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=
=3D::::nfsroot-cairo-7::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,noct=
o,actimeo=3D600,nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-test=
s/run-queue/kvm/x86_64-nfsroot/devel-xian-x86_64-201312131052/.vmlinuz-b1da=
f37ff52cf2ff39b2db2399e052ad7965c6aa-20131213105809-3-cairo branch=3Dlinux-=
devel/devel-xian-x86_64-201312131052 BOOT_IMAGE=3D/kernel/x86_64-nfsroot/b1=
daf37ff52cf2ff39b2db2399e052ad7965c6aa/vmlinuz-3.13.0-rc3-00689-gb1daf37
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Memory: 477864K/523888K available (11260K kernel code, 1354K=
 rwdata, 5644K rodata, 3328K init, 11488K bss, 46024K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D2, N=
odes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:4352 nr_irqs:512 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.13.0-rc3-00689-gb1daf37 (kbuild@xian) (gcc v=
ersion 4.8.1 (Debian 4.8.1-8) ) #892 SMP Fri Dec 13 10:57:18 CST 2013
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled panic=3D10 load_ramdisk=3D2 prompt=
_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::nf=
sroot-cairo-7::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actimeo=
=3D600,nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-tests/run-que=
ue/kvm/x86_64-nfsroot/devel-xian-x86_64-201312131052/.vmlinuz-b1daf37ff52cf=
2ff39b2db2399e052ad7965c6aa-20131213105809-3-cairo branch=3Dlinux-devel/dev=
el-xian-x86_64-201312131052 BOOT_IMAGE=3D/kernel/x86_64-nfsroot/b1daf37ff52=
cf2ff39b2db2399e052ad7965c6aa/vmlinuz-3.13.0-rc3-00689-gb1daf37
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   Centaur CentaurHauls
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffe000-0x000000001fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x1fffe max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[ffff8800000fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0305d000, 0x0305dfff] PGTABLE
[    0.000000] BRK [0x0305e000, 0x0305efff] PGTABLE
[    0.000000] BRK [0x0305f000, 0x0305ffff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x1fc00000-0x1fdfffff]
[    0.000000]  [mem 0x1fc00000-0x1fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1c000000-0x1fbfffff]
[    0.000000]  [mem 0x1c000000-0x1fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x1bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x1bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1fe00000-0x1fffdfff]
[    0.000000]  [mem 0x1fe00000-0x1fffdfff] page 4k
[    0.000000] BRK [0x03060000, 0x03060fff] PGTABLE
[    0.000000] ACPI: RSDP 00000000000fd930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffe450 000034 (v01 BOCHS  BXPCRSDT 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001fffff80 000074 (v01 BOCHS  BXPCFACP 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffe490 0011A9 (v01   BXPC   BXDSDT 0000=
0001 INTL 20100528)
[    0.000000] ACPI: FACS 000000001fffff40 000040
[    0.000000] ACPI: SSDT 000000001ffff7a0 000796 (v01 BOCHS  BXPCSSDT 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001ffff680 000080 (v01 BOCHS  BXPCAPIC 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001ffff640 000038 (v01 BOCHS  BXPCHPET 0000=
0001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffdfff]
[    0.000000]   NODE_DATA [mem 0x1fff9000-0x1fffdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1fff8001, boot clock
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001ee0000=
0-ffff88001f5fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffdfff]
[    0.000000] On node 0 totalpages: 130972
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 126974 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:2 nr_=
node_ids:1
[    0.000000] PERCPU: Embedded 476 pages/cpu @ffff88001ea00000 s1920832 r8=
192 d20672 u2097152
[    0.000000] pcpu-alloc: s1920832 r8192 d20672 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:1fff8001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1ea0d200
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 128903
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 load_ramdisk=3D2=
 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=
=3D::::nfsroot-cairo-7::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,noct=
o,actimeo=3D600,nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-test=
s/run-queue/kvm/x86_64-nfsroot/devel-xian-x86_64-201312131052/.vmlinuz-b1da=
f37ff52cf2ff39b2db2399e052ad7965c6aa-20131213105809-3-cairo branch=3Dlinux-=
devel/devel-xian-x86_64-201312131052 BOOT_IMAGE=3D/kernel/x86_64-nfsroot/b1=
daf37ff52cf2ff39b2db2399e052ad7965c6aa/vmlinuz-3.13.0-rc3-00689-gb1daf37
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Memory: 477864K/523888K available (11260K kernel code, 1354K=
 rwdata, 5644K rodata, 3328K init, 11488K bss, 46024K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D2, N=
odes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:4352 nr_irqs:512 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:             |  ok  |     =
        |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |     =
        |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |     =
        |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |     =
        |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |
[    0.000000]                ww contexts mixing:  ok  |  ok  |
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok =
 |
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]            spinlock nest unlocked:  ok  |
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:  ok  |  ok  |  ok  |
[    0.000000]                               try:  ok  |  ok  |  ok  |
[    0.000000]                             block:  ok  |  ok  |  ok  |
[    0.000000]                          spinlock:  ok  |  ok  |  ok  |
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 0 of 0 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2893.018 MHz processor
[    0.003000] Calibrating delay loop (skipped) preset value.. 5786.03 Bogo=
MIPS (lpj=3D2893018)
[    0.004020] pid_max: default: 32768 minimum: 301
[    0.006565] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.007412] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.009074] Mount-cache hash table entries: 256
[    0.013269] Initializing cgroup subsys debug
[    0.014039] Initializing cgroup subsys devices
[    0.015073] Initializing cgroup subsys freezer
[    0.016058] Initializing cgroup subsys blkio
[    0.017357] mce: CPU supports 10 MCE banks
[    0.018091] numa_add_cpu cpu 0 node 0: mask now 0
[    0.019021] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.019021] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.019021] tlb_flushall_shift: 6
[    0.021147] Freeing SMP alternatives memory: 40K (ffffffff82519000 - fff=
fffff82523000)
[    0.030868] ACPI: Core revision 20131115
[    0.082488] ACPI: All ACPI Tables successfully acquired
[    0.085071] ftrace: allocating 44626 entries in 175 pages
[    0.101681] Getting VERSION: 50014
[    0.102026] Getting VERSION: 50014
[    0.103020] Getting ID: 0
[    0.104025] Getting ID: ff000000
[    0.105024] Getting LVT0: 8700
[    0.106016] Getting LVT1: 8400
[    0.107104] enabled ExtINT on CPU#0
[    0.110515] ENABLING IO-APIC IRQs
[    0.111017] init IO_APIC IRQs
[    0.112013]  apic 0 pin 0 not connected
[    0.114051] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.115077] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.116071] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.117068] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.118063] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.119062] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.120057] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.121059] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.122068] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.123062] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.124059] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.125070] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.126063] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.127103] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.128061] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.129047]  apic 0 pin 16 not connected
[    0.130008]  apic 0 pin 17 not connected
[    0.131008]  apic 0 pin 18 not connected
[    0.132007]  apic 0 pin 19 not connected
[    0.133008]  apic 0 pin 20 not connected
[    0.134008]  apic 0 pin 21 not connected
[    0.135008]  apic 0 pin 22 not connected
[    0.136008]  apic 0 pin 23 not connected
[    0.137179] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.138010] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 0=
6, stepping: 01)
[    0.142008] Using local APIC timer interrupts.
[    0.142008] calibrating APIC timer ...
[    0.144000] ... lapic delta =3D 6249927
[    0.144000] ... PM-Timer delta =3D 357983
[    0.144000] ... PM-Timer result ok
[    0.144000] ..... delta 6249927
[    0.144000] ..... mult: 268432320
[    0.144000] ..... calibration result: 999988
[    0.144000] ..... CPU clock speed is 2893.0228 MHz.
[    0.144000] ..... host bus clock speed is 999.0988 MHz.
[    0.144136] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.151764] x86: Booting SMP configuration:
[    0.152010] .... node  #0, CPUs:      #1
[    0.003000] kvm-clock: cpu 1, msr 0:1fff8041, secondary cpu clock
[    0.003000] masked ExtINT on CPU#1
[    0.003000] numa_add_cpu cpu 1 node 0: mask now 0-1

[    0.169182] x86: Booted up 1 node, 2 CPUs
[    0.169120] KVM setup async PF for cpu 1
[    0.169120] kvm-stealtime: cpu 1, msr 1ec0d200
[    0.170035] ----------------
[    0.171005] | NMI testsuite:
[    0.172007] --------------------
[    0.173007]   remote IPI:  ok  |
[    0.178006]    local IPI:  ok  |
[    0.186014] --------------------
[    0.187007] Good, all   2 testcases passed! |
[    0.188006] ---------------------------------
[    0.189009] smpboot: Total of 2 processors activated (11572.07 BogoMIPS)
[    0.195172] devtmpfs: initialized
[    0.206319] kworker/u4:0 (17) used greatest stack depth: 5488 bytes left
[    0.220416] xor: measuring software checksum speed
[    0.231011]    prefetch64-sse:  9192.000 MB/sec
[    0.242013]    generic_sse:  8440.000 MB/sec
[    0.243008] xor: using function: prefetch64-sse (9192.000 MB/sec)
[    0.244021] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    0.246238] RTC time: 11:03:41, date: 12/13/13
[    0.249222] NET: Registered protocol family 16
[    0.254133] kworker/u4:0 (21) used greatest stack depth: 5264 bytes left
[    0.261367] cpuidle: using governor ladder
[    0.263221] cpuidle: using governor menu
[    0.265661] ACPI: bus type PCI registered
[    0.270227] dca service started, version 1.12.1
[    0.272384] PCI: Using configuration type 1 for base access
[    0.282251] kworker/u4:0 (48) used greatest stack depth: 5152 bytes left
[    0.510385] bio: create slab <bio-0> at 0
[    0.531018] raid6: sse2x1    3726 MB/s
[    0.549019] raid6: sse2x2    5765 MB/s
[    0.567013] raid6: sse2x4    6312 MB/s
[    0.568010] raid6: using algorithm sse2x4 (6312 MB/s)
[    0.569007] raid6: using intx1 recovery algorithm
[    0.572254] ACPI: Added _OSI(Module Device)
[    0.573010] ACPI: Added _OSI(Processor Device)
[    0.574009] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.575010] ACPI: Added _OSI(Processor Aggregator Device)
[    0.656537] ACPI: Interpreter enabled
[    0.657039] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20131115/hwxface-580)
[    0.661062] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20131115/hwxface-580)
[    0.664227] ACPI: (supports S0 S3 S4 S5)
[    0.665007] ACPI: Using IOAPIC for interrupt routing
[    0.668148] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.690444] ACPI: No dock devices found.
[    0.866288] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.867052] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.869125] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.878336] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.891412] PCI host bridge to bus 0000:00
[    0.892031] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.893022] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.894022] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.895024] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.896022] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.897169] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.902383] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.907182] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.909000] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.914345] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.915679] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.916033] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.922235] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.925017] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.928018] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.938021] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.944167] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.948011] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.950000] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.951000] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.955322] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.957000] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.958000] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.962222] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.964000] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.965000] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.976218] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.978000] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.979000] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.982722] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.984000] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.985000] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.990156] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.994014] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.996000] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    1.000218] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    1.002000] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    1.003000] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    1.008418] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    1.012012] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    1.031361] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    1.037230] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    1.043141] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    1.049075] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    1.053146] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    1.064564] ACPI: Enabled 16 GPEs in block 00 to 0F
[    1.066061] ACPI: \_SB_.PCI0: notify handler is installed
[    1.067254] Found 1 acpi root devices
[    1.073108] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    1.074026] vgaarb: loaded
[    1.075006] vgaarb: bridge control possible 0000:00:02.0
[    1.080347] SCSI subsystem initialized
[    1.083363] libata version 3.00 loaded.
[    1.086499] ACPI: bus type USB registered
[    1.089595] usbcore: registered new interface driver usbfs
[    1.092368] usbcore: registered new interface driver hub
[    1.095096] usbcore: registered new device driver usb
[    1.099427] pps_core: LinuxPPS API ver. 1 registered
[    1.100008] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    1.103053] PTP clock support registered
[    1.107425] wmi: Mapper loaded
[    1.110024] Advanced Linux Sound Architecture Driver Initialized.
[    1.111007] PCI: Using ACPI for IRQ routing
[    1.112009] PCI: pci_cache_line_size set to 64 bytes
[    1.113400] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.114047] e820: reserve RAM buffer [mem 0x1fffe000-0x1fffffff]
[    1.120498] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    1.121054] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    1.124007] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    1.132027] Switched to clocksource kvm-clock
[    1.370377] pnp: PnP ACPI init
[    1.372215] ACPI: bus type PNP registered
[    1.374443] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    1.378640] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.381404] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    1.385573] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.388281] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    1.392440] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.395635] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    1.398981] pnp 00:03: [dma 2]
[    1.401341] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.404587] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.408753] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.411967] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.416214] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.424457] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.430167] pnp: PnP ACPI: found 7 devices
[    1.431945] ACPI: bus type PNP unregistered
[    1.514136] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.517056] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.519030] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.521081] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.523743] NET: Registered protocol family 2
[    1.527320] TCP established hash table entries: 4096 (order: 3, 32768 by=
tes)
[    1.530407] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    1.533156] TCP: Hash tables configured (established 4096 bind 4096)
[    1.535452] TCP: reno registered
[    1.537055] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    1.539178] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    1.542520] NET: Registered protocol family 1
[    1.546274] RPC: Registered named UNIX socket transport module.
[    1.548174] RPC: Registered udp transport module.
[    1.550038] RPC: Registered tcp transport module.
[    1.551978] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.554243] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.556408] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.558542] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.560773] pci 0000:00:02.0: Boot video device
[    1.562817] PCI: CLS 0 bytes, default 64
[    1.953953] DMA-API: preallocated 65536 debug entries
[    1.956041] DMA-API: debugging enabled by kernel config
[    1.958712] kvm: no hardware support
[    1.961474] Machine check injector initialized
[    1.970173] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.972470] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.975551] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    1.979169] Scanning for low memory corruption every 60 seconds
[    1.989577] Initializing RT-Tester: OK
[    1.997622] audit: initializing netlink socket (disabled)
[    1.999913] type=3D2000 audit(1386903822.352:1): initialized
[    2.054490] Kprobe smoke test started
[    2.146215] Kprobe smoke test passed successfully
[    2.151835] bounce pool size: 64 pages
[    2.153651] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    2.303826] NFS: Registering the id_resolver key type
[    2.306063] Key type id_resolver registered
[    2.307802] Key type id_legacy registered
[    2.309589] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    2.323759] fuse init (API version 7.22)
[    2.330557] JFS: nTxBlock =3D 3733, nTxLock =3D 29869
[    2.337238] SGI XFS with ACLs, security attributes, large block/inode nu=
mbers, no debug enabled
[    2.358614] 9p: Installing v9fs 9p2000 file system support
[    2.365304] NILFS version 2 loaded
[    2.375806] bio: create slab <bio-1> at 1
[    2.387379] Btrfs loaded
[    2.388886] msgmni has been set to 933
[    2.398946] async_tx: api initialized (async)
[    2.402234] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    2.405793] io scheduler noop registered
[    2.407530] io scheduler deadline registered
[    2.411360] io scheduler cfq registered (default)
[    2.415609] list_sort_test: start testing list_sort()
[    2.427731] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    2.432602] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    2.436101] ACPI: Power Button [PWRF]
[    2.443802] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    2.464555] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    2.466758] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:3)
[    2.486980] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    2.489132] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:3)
[    2.509744] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    2.530509] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    2.962175] tsc: Refined TSC clocksource calibration: 2892.983 MHz
[    2.975694] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    3.001478] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    3.012820] Initializing Nozomi driver 2.1d
[    3.019413] Non-volatile memory driver v1.3
[    3.021991] Linux agpgart interface v0.103
[    3.024776] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    3.028475] Hangcheck: Using getrawmonotonic().
[    3.030964] [drm] Initialized drm 1.1.0 20060810
[    3.037745] Floppy drive(s): fd0 is 1.44M
[    3.052387] FDC 0 is a S82078B
[    3.075301] brd: module loaded
[    3.095496] loop: module loaded
[    3.099611] virtio-pci 0000:00:04.0: irq 40 for MSI/MSI-X
[    3.101825] virtio-pci 0000:00:04.0: irq 41 for MSI/MSI-X
[    3.105266] blk-mq: CPU -> queue map
[    3.107037]   CPU 0 -> Queue 0
[    3.108630]   CPU 1 -> Queue 0
[    3.113576]  vda: unknown partition table
[    3.119946] virtio-pci 0000:00:05.0: irq 42 for MSI/MSI-X
[    3.122127] virtio-pci 0000:00:05.0: irq 43 for MSI/MSI-X
[    3.125473] blk-mq: CPU -> queue map
[    3.127249]   CPU 0 -> Queue 0
[    3.129090]   CPU 1 -> Queue 0
[    3.134439]  vdb: unknown partition table
[    3.141131] virtio-pci 0000:00:06.0: irq 44 for MSI/MSI-X
[    3.143469] virtio-pci 0000:00:06.0: irq 45 for MSI/MSI-X
[    3.146788] blk-mq: CPU -> queue map
[    3.148573]   CPU 0 -> Queue 0
[    3.150318]   CPU 1 -> Queue 0
[    3.159140]  vdc: unknown partition table
[    3.165081] virtio-pci 0000:00:07.0: irq 46 for MSI/MSI-X
[    3.167290] virtio-pci 0000:00:07.0: irq 47 for MSI/MSI-X
[    3.170553] blk-mq: CPU -> queue map
[    3.172330]   CPU 0 -> Queue 0
[    3.174110]   CPU 1 -> Queue 0
[    3.178293]  vdd: unknown partition table
[    3.184344] virtio-pci 0000:00:08.0: irq 48 for MSI/MSI-X
[    3.186580] virtio-pci 0000:00:08.0: irq 49 for MSI/MSI-X
[    3.189793] blk-mq: CPU -> queue map
[    3.191583]   CPU 0 -> Queue 0
[    3.193365]   CPU 1 -> Queue 0
[    3.197574]  vde: unknown partition table
[    3.203494] virtio-pci 0000:00:09.0: irq 50 for MSI/MSI-X
[    3.205678] virtio-pci 0000:00:09.0: irq 51 for MSI/MSI-X
[    3.208943] blk-mq: CPU -> queue map
[    3.210752]   CPU 0 -> Queue 0
[    3.212548]   CPU 1 -> Queue 0
[    3.217177]  vdf: unknown partition table
[    3.223554] lkdtm: No crash points registered, enable through debugfs
[    3.226661] Uniform Multi-Platform E-IDE driver
[    3.229697] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    3.232520] piix 0000:00:01.1: not 100% native mode: will probe irqs lat=
er
[    3.237554]     ide0: BM-DMA at 0xc1c0-0xc1c7
[    3.239564]     ide1: BM-DMA at 0xc1c8-0xc1cf
[    3.241467] Probing IDE interface ide0...
[    3.763322] Probing IDE interface ide1...
[    4.437230] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    5.052331] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    5.054951] hdc: MWDMA2 mode selected
[    5.057095] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    5.059370] ide1 at 0x170-0x177,0x376 on irq 15
[    5.064112] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[    5.067998] ide-gd driver 1.18
[    5.072727] Loading iSCSI transport class v2.0-870.
[    5.082303] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[    5.084520] Detecting Adaptec I2O RAID controllers...
[    5.087764] Adaptec aacraid driver 1.2-0[30200]-ms
[    5.090661] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    5.095521] isci: Intel(R) C600 SAS Controller Driver - version 1.1.0
[    5.100092] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driv=
er: 8.06.00.08-k.
[    5.105771] iscsi: registered transport (qla4xxx)
[    5.108333] QLogic iSCSI HBA Driver
[    5.110610] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 ES=
T 2006)
[    5.114540] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 20=
06)
[    5.117481] megasas: 06.700.06.00-rc1 Sat. Aug. 31 17:00:00 PDT 2013
[    5.120321] mpt2sas version 16.100.00.00 loaded
[    5.123746] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    5.154766] tun: Universal TUN/TAP device driver, 1.6
[    5.156776] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    5.160705] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    5.162764] Copyright (c) 2007 Atheros Corporation.
[    5.166995] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.18 (Sept 0=
1, 2013)
[    5.171083] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    5.173278] e100: Copyright(c) 1999-2006 Intel Corporation
[    5.175860] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[    5.178265] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    5.563442] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[    5.565760] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[    5.568635] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[    5.570763] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[    5.573530] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.=
5-k
[    5.575887] igb: Copyright (c) 2007-2013 Intel Corporation.
[    5.578536] igbvf: Intel(R) Gigabit Virtual Function Network Driver - ve=
rsion 2.0.2-k
[    5.581528] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[    5.584216] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 3.15.1-k
[    5.587479] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
[    5.590242] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2=
-NAPI
[    5.592668] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[    5.595803] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    5.598935] sky2: driver version 1.30
[    5.601261] pch_gbe: EG20T PCH Gigabit Ethernet Driver - version 1.01
[    5.619879] usbcore: registered new interface driver catc
[    5.623490] usbcore: registered new interface driver kaweth
[    5.625557] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Etherne=
t driver
[    5.629246] usbcore: registered new interface driver pegasus
[    5.631926] usbcore: registered new interface driver rtl8150
[    5.634548] usbcore: registered new interface driver asix
[    5.637086] usbcore: registered new interface driver ax88179_178a
[    5.639724] usbcore: registered new interface driver cdc_ether
[    5.642405] usbcore: registered new interface driver r815x
[    5.645052] usbcore: registered new interface driver cdc_eem
[    5.647580] usbcore: registered new interface driver dm9601
[    5.650293] usbcore: registered new interface driver smsc75xx
[    5.652937] usbcore: registered new interface driver smsc95xx
[    5.655470] usbcore: registered new interface driver gl620a
[    5.657935] usbcore: registered new interface driver net1080
[    5.660495] usbcore: registered new interface driver plusb
[    5.663065] usbcore: registered new interface driver rndis_host
[    5.665621] usbcore: registered new interface driver cdc_subset
[    5.668387] usbcore: registered new interface driver zaurus
[    5.670909] usbcore: registered new interface driver MOSCHIP usb-etherne=
t driver
[    5.674516] usbcore: registered new interface driver int51x1
[    5.677097] usbcore: registered new interface driver cdc_ncm
[    5.679183] Fusion MPT base driver 3.04.20
[    5.680912] Copyright (c) 1999-2008 LSI Corporation
[    5.682971] Fusion MPT SPI Host driver 3.04.20
[    5.685510] Fusion MPT FC Host driver 3.04.20
[    5.687897] Fusion MPT SAS Host driver 3.04.20
[    5.690342] Fusion MPT misc device (ioctl) driver 3.04.20
[    5.693313] mptctl: Registered with Fusion MPT base driver
[    5.695339] mptctl: /dev/mptctl @ (major,minor=3D10,220)
[    5.697787] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    5.700053] ehci-pci: EHCI PCI platform driver
[    5.702451] uhci_hcd: USB Universal Host Controller Interface driver
[    5.706812] usbcore: registered new interface driver usb-storage
[    5.709472] usbcore: registered new interface driver ums-alauda
[    5.712079] usbcore: registered new interface driver ums-cypress
[    5.714615] usbcore: registered new interface driver ums-datafab
[    5.717426] usbcore: registered new interface driver ums-freecom
[    5.719965] usbcore: registered new interface driver ums-isd200
[    5.722501] usbcore: registered new interface driver ums-jumpshot
[    5.725273] usbcore: registered new interface driver ums-karma
[    5.727841] usbcore: registered new interface driver ums-onetouch
[    5.730449] usbcore: registered new interface driver ums-sddr09
[    5.732989] usbcore: registered new interface driver ums-sddr55
[    5.735545] usbcore: registered new interface driver ums-usbat
[    5.738611] usbcore: registered new interface driver usbserial
[    5.741378] usbcore: registered new interface driver usbserial_generic
[    5.744436] usbserial: USB Serial support registered for generic
[    5.747059] usbcore: registered new interface driver belkin_sa
[    5.749649] usbserial: USB Serial support registered for Belkin / Peraco=
m / GoHubs USB Serial Adapter
[    5.753646] usbcore: registered new interface driver mct_u232
[    5.756298] usbserial: USB Serial support registered for MCT U232
[    5.758954] usbcore: registered new interface driver usbtest
[    5.761951] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    5.767735] serio: i8042 KBD port at 0x60,0x64 irq 1
[    5.769899] serio: i8042 AUX port at 0x60,0x64 irq 12
[    5.775372] mousedev: PS/2 mouse device common for all mice
[    5.781768] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    5.790355] rtc_cmos 00:00: RTC can wake from S4
[    5.794407] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    5.797134] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    5.800776] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[    5.804350] i6300esb: initialized (0xffffc90000488000). heartbeat=3D30 s=
ec (nowayout=3D0)
[    5.808213] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    5.810768] iTCO_vendor_support: vendor-support=3D0
[    5.813180] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    5.816652] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    5.821102] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[    5.825368] md: linear personality registered for level -1
[    5.827497] md: raid0 personality registered for level 0
[    5.829628] md: raid1 personality registered for level 1
[    5.833051] md: raid10 personality registered for level 10
[    5.835884] md: raid6 personality registered for level 6
[    5.837997] md: raid5 personality registered for level 5
[    5.840124] md: raid4 personality registered for level 4
[    5.842280] md: multipath personality registered for level -4
[    5.844485] md: faulty personality registered for level -5
[    5.850175] device-mapper: uevent: version 1.0.3
[    5.855191] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised:=
 dm-devel@redhat.com
[    5.862705] device-mapper: multipath: version 1.6.0 loaded
[    5.864948] device-mapper: multipath round-robin: version 1.0.0 loaded
[    5.867314] device-mapper: multipath queue-length: version 0.1.0 loaded
[    5.869698] device-mapper: multipath service-time: version 0.2.0 loaded
[    5.874957] device-mapper: dm-log-userspace: version 1.1.0 loaded
[    5.878738] usbcore: registered new interface driver usbhid
[    5.880895] usbhid: USB HID core driver
[    5.885325] dell_wmi: No known WMI GUID found
[    5.887227] acer_wmi: Acer Laptop ACPI-WMI Extras
[    5.889204] acer_wmi: No or unsupported WMI interface, unable to load
[    5.894950] oprofile: using NMI interrupt.
[    5.898107] netem: version 1.3
[    5.899722] Netfilter messages via NETLINK v0.30.
[    5.901944] nf_conntrack version 0.5.0 (3733 buckets, 14932 max)
[    5.907133] ctnetlink v0.93: registering with nfnetlink.
[    5.911702] xt_time: kernel timezone is -0000
[    5.914241] ip_tables: (C) 2000-2006 Netfilter Core Team
[    5.916670] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[    5.919218] arp_tables: (C) 2002 David S. Miller
[    5.922544] TCP: bic registered
[    5.924194] TCP: cubic registered
[    5.925872] TCP: westwood registered
[    5.927609] TCP: highspeed registered
[    5.929329] TCP: hybla registered
[    5.930983] TCP: htcp registered
[    5.932683] TCP: vegas registered
[    5.934341] TCP: veno registered
[    5.935993] TCP: scalable registered
[    5.937701] TCP: lp registered
[    5.939248] TCP: yeah registered
[    5.940843] TCP: illinois registered
[    5.942529] Initializing XFRM netlink socket
[    5.951539] NET: Registered protocol family 10
[    5.958129] sit: IPv6 over IPv4 tunneling driver
[    5.962686] NET: Registered protocol family 17
[    5.964779] NET: Registered protocol family 15
[    5.967913] Bridge firewalling registered
[    5.969844] Ebtables v2.0 registered
[    5.975473] 9pnet: Installing 9P2000 support
[    5.977978] Key type dns_resolver registered
[    5.983278]=20
[    5.983278] printing PIC contents
[    5.986084] ... PIC  IMR: ffff
[    5.987056] ... PIC  IRR: 1153
[    5.989219] ... PIC  ISR: 0000
[    5.991111] ... PIC ELCR: 0c00
[    5.992855] printing local APIC contents on CPU#0/0:
[    5.993833] ... APIC ID:      00000000 (0)
[    5.993833] ... APIC VERSION: 00050014
[    5.993833] ... APIC TASKPRI: 00000000 (00)
[    5.993833] ... APIC PROCPRI: 00000000
[    5.993833] ... APIC LDR: 01000000
[    5.993833] ... APIC DFR: ffffffff
[    5.993833] ... APIC SPIV: 000001ff
[    5.993833] ... APIC ISR field:
[    5.993833] 000000000000000000000000000000000000000000000000000000000000=
0000
[    5.993833] ... APIC TMR field:
[    5.993833] 000000000200000000000000000000000000000000000000000000000000=
0000
[    5.993833] ... APIC IRR field:
[    5.993833] 000000000000000000000000000000000000000000000000000000000000=
8000
[    5.993833] ... APIC ESR: 00000000
[    5.993833] ... APIC ICR: 000008fd
[    5.993833] ... APIC ICR2: 02000000
[    5.993833] ... APIC LVTT: 000000ef
[    5.993833] ... APIC LVTPC: 00010000
[    5.993833] ... APIC LVT0: 00010700
[    5.993833] ... APIC LVT1: 00000400
[    5.993833] ... APIC LVTERR: 000000fe
[    5.993833] ... APIC TMICT: 000027ad
[    5.993833] ... APIC TMCCT: 00000000
[    5.993833] ... APIC TDCR: 00000003
[    5.993833]=20
[    6.041510] number of MP IRQ sources: 15.
[    6.043290] number of IO-APIC #0 registers: 24.
[    6.045199] testing the IO APIC.......................
[    6.047268] IO APIC #0......
[    6.048873] .... register #00: 00000000
[    6.050711] .......    : physical APIC id: 00
[    6.052618] .......    : Delivery Type: 0
[    6.054424] .......    : LTS          : 0
[    6.056213] .... register #01: 00170011
[    6.057981] .......     : max redirection entries: 17
[    6.060070] .......     : PRQ implemented: 0
[    6.061928] .......     : IO APIC version: 11
[    6.063830] .... register #02: 00000000
[    6.065598] .......     : arbitration: 00
[    6.067379] .... IRQ redirection table:
[    6.069117] 1    0    0   0   0    0    0    00
[    6.071049] 0    0    0   0   0    1    1    31
[    6.072955] 0    0    0   0   0    1    1    30
[    6.074895] 0    0    0   0   0    1    1    33
[    6.090209] 1    0    0   0   0    1    1    34
[    6.092217] 1    1    0   0   0    1    1    35
[    6.094151] 0    0    0   0   0    1    1    36
[    6.096087] 0    0    0   0   0    1    1    37
[    6.097989] 0    0    0   0   0    1    1    38
[    6.099931] 0    1    0   0   0    1    1    39
[    6.101909] 1    1    0   0   0    1    1    3A
[    6.103841] 1    1    0   0   0    1    1    3B
[    6.105792] 0    0    0   0   0    1    1    3C
[    6.107741] 0    0    0   0   0    1    1    3D
[    6.109682] 0    0    0   0   0    1    1    3E
[    6.111649] 0    0    0   0   0    1    1    3F
[    6.113607] 1    0    0   0   0    0    0    00
[    6.115585] 1    0    0   0   0    0    0    00
[    6.117550] 1    0    0   0   0    0    0    00
[    6.119517] 1    0    0   0   0    0    0    00
[    6.121538] 1    0    0   0   0    0    0    00
[    6.123467] 1    0    0   0   0    0    0    00
[    6.125402] 1    0    0   0   0    0    0    00
[    6.127356] 1    0    0   0   0    0    0    00
[    6.129281] IRQ to pin mappings:
[    6.130883] IRQ0 -> 0:2
[    6.132711] IRQ1 -> 0:1
[    6.134467] IRQ3 -> 0:3
[    6.136212] IRQ4 -> 0:4
[    6.137944] IRQ5 -> 0:5
[    6.139710] IRQ6 -> 0:6
[    6.141512] IRQ7 -> 0:7
[    6.143256] IRQ8 -> 0:8
[    6.144999] IRQ9 -> 0:9
[    6.146762] IRQ10 -> 0:10
[    6.148558] IRQ11 -> 0:11
[    6.150380] IRQ12 -> 0:12
[    6.152200] IRQ13 -> 0:13
[    6.153972] IRQ14 -> 0:14
[    6.155807] IRQ15 -> 0:15
[    6.157625] .................................... done.
[    6.162928] registered taskstats version 1
[    6.168126]   Magic number: 9:691:74
[    6.170725] console [netcon0] enabled
[    6.172450] netconsole: network logging started
[    6.174565] rtc_cmos 00:00: setting system clock to 2013-12-13 11:03:47 =
UTC (1386932627)
[    6.191560] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    6.395352] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input3
[    8.192673] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Contr=
ol: RX
[    8.196701] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    8.206097] Sending DHCP requests ., OK
[    8.214065] IP-Config: Got DHCP answer from 10.0.2.2, my address is 10.0=
=2E2.15
[    8.218606] IP-Config: Complete:
[    8.220222]      device=3Deth0, hwaddr=3D52:54:00:12:34:56, ipaddr=3D10.=
0.2.15, mask=3D255.255.255.0, gw=3D10.0.2.2
[    8.223891]      host=3Dnfsroot-cairo-7, domain=3D, nis-domain=3D(none)
[    8.226099]      bootserver=3D10.0.2.2, rootserver=3D192.168.1.1, rootpa=
th=3D
[    8.227612]      nameserver0=3D10.0.2.3
[    8.230650] PM: Hibernation image not present or could not be loaded.
[    8.232923] ALSA device list:
[    8.234465]   No soundcards found.
[    8.236792] md: Waiting for all devices to be available before autodetect
[    8.239162] md: If you don't use raid, use raid=3Dnoautodetect
[    8.245809] md: Autodetecting RAID arrays.
[    8.247594] md: Scanned 0 and added 0 devices.
[    8.249355] md: autorun ...
[    8.250898] md: ... autorun DONE.
[   11.274286] VFS: Mounted root (nfs filesystem) on device 0:15.
[   11.277815] devtmpfs: mounted
[   11.284784] Freeing unused kernel memory: 3328K (ffffffff821d9000 - ffff=
ffff82519000)
[   11.634713] modprobe (1953) used greatest stack depth: 3896 bytes left
[   11.972695] echo (1965) used greatest stack depth: 3872 bytes left
[   13.143111] udevd[2087]: starting version 175
[   13.941058] pci-db (2123) used greatest stack depth: 3632 bytes left
[   14.781830] hwclock (2226) used greatest stack depth: 3552 bytes left
[   17.763814] random: vgscan urandom read with 102 bits of entropy availab=
le
[   22.409442] random: nonblocking pool is initialized
[   23.563370]=20
[   23.564204] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   23.564204] [ INFO: inconsistent lock state ]
[   23.564204] 3.13.0-rc3-00689-gb1daf37 #892 Not tainted
[   23.564204] ---------------------------------
[   23.564204] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[   23.564204] swapper/0/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   23.564204]  (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<ffffffff81a27fe=
2>] __udp4_lib_rcv+0x569/0x79d
[   23.564204] {SOFTIRQ-ON-W} state was registered at:
[   23.564204]   [<ffffffff810b16b7>] __lock_acquire+0x96c/0x185f
[   23.564204]   [<ffffffff810b2c97>] lock_acquire+0xab/0x12e
[   23.564204]   [<ffffffff81af12d3>] _raw_spin_lock+0x3b/0x6d
[   23.564204]   [<ffffffff81a2f13d>] inet_bind+0x18d/0x1dc
[   23.564204]   [<ffffffff8199d62c>] kernel_bind+0x10/0x12
[   23.564204]   [<ffffffff81aae764>] xs_bind+0xa0/0x11e
[   23.564204]   [<ffffffff81ab0271>] xs_create_sock.isra.14+0x20b/0x230
[   23.564204]   [<ffffffff81ab047f>] xs_tcp_setup_socket+0x5f/0x3e5
[   23.564204]   [<ffffffff8108a0d7>] process_one_work+0x247/0x443
[   23.564204]   [<ffffffff8108aeac>] worker_thread+0x1d2/0x2bc
[   23.564204]   [<ffffffff81090228>] kthread+0xf9/0x101
[   23.564204]   [<ffffffff81af92fc>] ret_from_fork+0x7c/0xb0
[   23.564204] irq event stamp: 514170
[   23.564204] hardirqs last  enabled at (514170): [<ffffffff810766af>] loc=
al_bh_enable+0xab/0xb5
[   23.564204] hardirqs last disabled at (514169): [<ffffffff8107665a>] loc=
al_bh_enable+0x56/0xb5
[   23.564204] softirqs last  enabled at (514148): [<ffffffff81076106>] _lo=
cal_bh_enable+0x43/0x45
[   23.564204] softirqs last disabled at (514149): [<ffffffff81076779>] irq=
_exit+0x59/0xa0
[   23.564204]=20
[   23.564204] other info that might help us debug this:
[   23.564204]  Possible unsafe locking scenario:
[   23.564204]=20
[   23.564204]        CPU0
[   23.564204]        ----
[   23.564204]   lock(&(&sk->sk_dst_lock)->rlock);
[   23.564204]   <Interrupt>
[   23.564204]     lock(&(&sk->sk_dst_lock)->rlock);
[   23.564204]=20
[   23.564204]  *** DEADLOCK ***
[   23.564204]=20
[   23.564204] 2 locks held by swapper/0/0:
[   23.564204]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff819b258a>] __ne=
tif_receive_skb_core+0x168/0x58e
[   23.564204]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff81a0086a>] ip_l=
ocal_deliver_finish+0x2f/0x2a0
[   23.564204]=20
[   23.564204] stack backtrace:
[   23.564204] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-rc3-00689-g=
b1daf37 #892
[   23.564204] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   23.564204]  0000000000000002 ffff88001ea039a0 ffffffff81ae56fd ffffffff=
82097490
[   23.564204]  ffff88001ea039f0 ffffffff81addae7 0000000000000001 ffff8800=
00000001
[   23.564204]  ffff880000000000 ffffffff82097c08 0000000000000004 00000000=
00000006
[   23.564204] Call Trace:
[   23.564204]  <IRQ>  [<ffffffff81ae56fd>] dump_stack+0x4d/0x66
[   23.564204]  [<ffffffff81addae7>] print_usage_bug+0x2a8/0x2b9
[   23.564204]  [<ffffffff810af93a>] ? print_shortest_lock_dependencies+0x1=
93/0x193
[   23.564204]  [<ffffffff810b05b5>] mark_lock+0x33c/0x57c
[   23.564204]  [<ffffffff810b1645>] __lock_acquire+0x8fa/0x185f
[   23.564204]  [<ffffffff8109fd9c>] ? sched_clock_local+0x12/0x72
[   23.564204]  [<ffffffff810addfa>] ? trace_hardirqs_off_caller+0x1f/0xb2
[   23.564204]  [<ffffffff810b2c97>] lock_acquire+0xab/0x12e
[   23.564204]  [<ffffffff81a27fe2>] ? __udp4_lib_rcv+0x569/0x79d
[   23.564204]  [<ffffffff810addfa>] ? trace_hardirqs_off_caller+0x1f/0xb2
[   23.564204]  [<ffffffff81af12d3>] _raw_spin_lock+0x3b/0x6d
[   23.564204]  [<ffffffff81a27fe2>] ? __udp4_lib_rcv+0x569/0x79d
[   23.564204]  [<ffffffff81a27fe2>] __udp4_lib_rcv+0x569/0x79d
[   23.564204]  [<ffffffff81a286ae>] udp_rcv+0x1a/0x1c
[   23.564204]  [<ffffffff81a0098c>] ip_local_deliver_finish+0x151/0x2a0
[   23.564204]  [<ffffffff81a0086a>] ? ip_local_deliver_finish+0x2f/0x2a0
[   23.564204]  [<ffffffff81a0109e>] ip_local_deliver+0x7a/0x7f
[   23.564204]  [<ffffffff81a00e75>] ip_rcv_finish+0x39a/0x461
[   23.564204]  [<ffffffff81a01326>] ip_rcv+0x283/0x2e0
[   23.564204]  [<ffffffff819b28ef>] __netif_receive_skb_core+0x4cd/0x58e
[   23.564204]  [<ffffffff819b258a>] ? __netif_receive_skb_core+0x168/0x58e
[   23.564204]  [<ffffffff819b2dd6>] __netif_receive_skb+0x1d/0x5f
[   23.564204]  [<ffffffff819b2e80>] netif_receive_skb+0x68/0xf4
[   23.564204]  [<ffffffff819b35da>] napi_gro_receive+0x3e/0x80
[   23.564204]  [<ffffffff817be870>] e1000_clean_rx_irq+0x393/0x415
[   23.564204]  [<ffffffff817bcd48>] e1000_clean+0x59d/0x71f
[   23.564204]  [<ffffffff810634d1>] ? kvm_clock_read+0x27/0x31
[   23.564204]  [<ffffffff8103edd0>] ? sched_clock+0x9/0xd
[   23.564204]  [<ffffffff819b3ed0>] net_rx_action+0xf6/0x210
[   23.564204]  [<ffffffff810762fc>] __do_softirq+0xf3/0x27a
[   23.564204]  [<ffffffff81076779>] irq_exit+0x59/0xa0
[   23.564204]  [<ffffffff81afb44d>] do_IRQ+0x9d/0xb4
[   23.564204]  [<ffffffff81af21f2>] common_interrupt+0x72/0x72
[   23.564204]  <EOI>  [<ffffffff81af5ab5>] ? __atomic_notifier_call_chain+=
0x5/0x9c
[   23.564204]  [<ffffffff810636c8>] ? native_safe_halt+0x6/0x8
[   23.564204]  [<ffffffff8103f9d1>] default_idle+0x38/0xc1
[   23.564204]  [<ffffffff81040154>] arch_cpu_idle+0x18/0x28
[   23.564204]  [<ffffffff810c0ac5>] cpu_startup_entry+0x15c/0x24d
[   23.564204]  [<ffffffff81ad1f25>] rest_init+0xc9/0xcd
[   23.564204]  [<ffffffff81ad1e61>] ? rest_init+0x5/0xcd
[   23.564204]  [<ffffffff823aed77>] start_kernel+0x3d4/0x3e0
[   23.564204]  [<ffffffff823ae7b1>] ? repair_env_string+0x58/0x58
[   23.564204]  [<ffffffff823ae120>] ? early_idt_handlers+0x120/0x120
[   23.564204]  [<ffffffff823ae467>] x86_64_start_reservations+0x2a/0x2c
[   23.564204]  [<ffffffff823ae5a9>] x86_64_start_kernel+0x140/0x14d
[   66.435785] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recov=
ery directory
[   66.440815] NFSD: starting 90-second grace period (net ffffffff82196a80)
Kernel tests: Boot OK!
[   67.934595] Unregister pv shared memory for cpu 1
[   67.942329] numa_remove_cpu cpu 1 node 0: mask now 0
[   67.945771] smpboot: CPU 1 is now offline
[   67.954077] blk-mq: CPU -> queue map
[   67.955848]   CPU 0 -> Queue 0
[   67.957456] blk-mq: CPU -> queue map
[   67.959170]   CPU 0 -> Queue 0
[   67.960760] blk-mq: CPU -> queue map
[   67.962448]   CPU 0 -> Queue 0
[   67.964039] blk-mq: CPU -> queue map
[   67.965619]   CPU 0 -> Queue 0
[   67.966980] blk-mq: CPU -> queue map
[   67.968653]   CPU 0 -> Queue 0
[   67.970277] blk-mq: CPU -> queue map
[   67.972049]   CPU 0 -> Queue 0
[   68.093292] x86: Booting SMP configuration:
[   68.095201] smpboot: Booting Node 0 Processor 1 APIC 0x1
[   67.943021] kvm-clock: cpu 1, msr 0:1fff8041, secondary cpu clock
[   67.943021] masked ExtINT on CPU#1
[   67.943021] numa_add_cpu cpu 1 node 0: mask now 0-1
[   68.131676] KVM setup async PF for cpu 1
[   68.132619] kvm-stealtime: cpu 1, msr 1ec0d200
[   68.138066] blk-mq: CPU -> queue map
[   68.139922]   CPU 0 -> Queue 0
[   68.141462]   CPU 1 -> Queue 0
[   68.143017] blk-mq: CPU -> queue map
[   68.144618]   CPU 0 -> Queue 0
[   68.146128]   CPU 1 -> Queue 0
[   68.147674] blk-mq: CPU -> queue map
[   68.149269]   CPU 0 -> Queue 0
[   68.150812]   CPU 1 -> Queue 0
[   68.152338] blk-mq: CPU -> queue map
[   68.153913]   CPU 0 -> Queue 0
[   68.155409]   CPU 1 -> Queue 0
[   68.156963] blk-mq: CPU -> queue map
[   68.158589]   CPU 0 -> Queue 0
[   68.160158]   CPU 1 -> Queue 0
[   68.161720] blk-mq: CPU -> queue map
[   68.163327]   CPU 0 -> Queue 0
[   68.164857]   CPU 1 -> Queue 0
[   69.174690] Unregister pv shared memory for cpu 1
[   69.182263] numa_remove_cpu cpu 1 node 0: mask now 0
[   69.185679] smpboot: CPU 1 is now offline
[   69.192472] blk-mq: CPU -> queue map
[   69.194224]   CPU 0 -> Queue 0
[   69.195823] blk-mq: CPU -> queue map
[   69.197525]   CPU 0 -> Queue 0
[   69.199157] blk-mq: CPU -> queue map
[   69.200834]   CPU 0 -> Queue 0
[   69.202470] blk-mq: CPU -> queue map
[   69.204199]   CPU 0 -> Queue 0
[   69.205810] blk-mq: CPU -> queue map
[   69.207501]   CPU 0 -> Queue 0
[   69.209135] blk-mq: CPU -> queue map
[   69.210826]   CPU 0 -> Queue 0
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
[3807] Marking 64-bit syscall 274 (get_robust_list) as AVOID
[3807] Marking 32-bit syscall 312 (get_robust_list) as AVOID
[   79.231373] x86: Booting SMP configuration:
[   79.233120] smpboot: Booting Node 0 Processor 1 APIC 0x1
[   69.183028] kvm-clock: cpu 1, msr 0:1fff8041, secondary cpu clock
[   69.183028] masked ExtINT on CPU#1
[   69.183028] numa_add_cpu cpu 1 node 0: mask now 0-1
[   79.289704] KVM setup async PF for cpu 1
[   79.290632] kvm-stealtime: cpu 1, msr 1ec0d200
[   79.297426] blk-mq: CPU -> queue map
[   79.299164]   CPU 0 -> Queue 0
[   79.300744]   CPU 1 -> Queue 0
[   79.302324] blk-mq: CPU -> queue map
[   79.304065]   CPU 0 -> Queue 0
[   79.305642]   CPU 1 -> Queue 0
[   79.306934] blk-mq: CPU -> queue map
[   79.308392]   CPU 0 -> Queue 0
[   79.309745]   CPU 1 -> Queue 0
[   79.311392] blk-mq: CPU -> queue map
[   79.313022]   CPU 0 -> Queue 0
[   79.315563]   CPU 1 -> Queue 0
[   79.317186] blk-mq: CPU -> queue map
[   79.318843]   CPU 0 -> Queue 0
[   79.320075]   CPU 1 -> Queue 0
[   79.321618] blk-mq: CPU -> queue map
[   79.323284]   CPU 0 -> Queue 0
[   79.324960]   CPU 1 -> Queue 0
Couldn't open /dev/ptyw5 : Input/output error
[   79.920082] Bits 55-60 of /proc/PID/pagemap entries are about to stop be=
ing page-shift some time soon. See the linux/Documentation/vm/pagemap.txt f=
or details.
Couldn't open /dev/ptyxc : Input/output error
Couldn't open /dev/ptyx4 : Input/output error
Couldn't open /dev/ptyu1 : Input/output error
[3814] Watchdog is alive
[3807] Started watchdog thread 3814
537 iterations.
895 iterations.
[   96.511800] warning: process `trinity-child0' used the deprecated sysctl=
 system call with=20
1118 iterations.
1556 iterations.
1916 iterations.
2331 iterations.
2353 iterations.
2375 iterations.
2953 iterations.
2959 iterations.
4347 iterations.
5523 iterations.
6527 iterations.
8122 iterations.
8183 iterations.
8223 iterations.
8831 iterations.
8917 iterations.
9014 iterations.
9059 iterations.
9271 iterations.
9297 iterations.
9343 iterations.
9630 iterations.
10705 iterations.
11079 iterations.
11139 iterations.
/etc/kernel-tests/99-trinity: line 18:  3807 Killed                  chroot=
 --userspec nobody:nogroup $mnt /usr/local/bin/trinity -q -x get_robust_lis=
t -N 99999
umount: /fs/trinity/sys: device is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
/etc/kernel-tests/99-trinity: line 20: kill: (3807) - No such process
run-parts: /etc/kernel-tests/99-trinity exited with return code 1
[  178.459861] nfsd: last server has exited, flushing export cache
[  188.107339] Unregister pv shared memory for cpu 0
[  188.109268] Unregister pv shared memory for cpu 1
[  188.135978] reboot: Restarting system
[  188.137748] reboot: machine restart
Elapsed time: 190
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-nfsroot/b1=
daf37ff52cf2ff39b2db2399e052ad7965c6aa/vmlinuz-3.13.0-rc3-00689-gb1daf37 -a=
ppend 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=3Ddebug sy=
srq_always_enabled panic=3D10 load_ramdisk=3D2 prompt_ramdisk=3D0 console=
=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::nfsroot-cairo-7::dhcp =
nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D600,nolock,rsize=
=3D524288,wsize=3D524288 rw link=3D/kernel-tests/run-queue/kvm/x86_64-nfsro=
ot/devel-xian-x86_64-201312131052/.vmlinuz-b1daf37ff52cf2ff39b2db2399e052ad=
7965c6aa-20131213105809-3-cairo branch=3Dlinux-devel/devel-xian-x86_64-2013=
12131052 BOOT_IMAGE=3D/kernel/x86_64-nfsroot/b1daf37ff52cf2ff39b2db2399e052=
ad7965c6aa/vmlinuz-3.13.0-rc3-00689-gb1daf37'  -m 512M -smp 2 -net nic,vlan=
=3D1,model=3De1000 -net user,vlan=3D1,hostfwd=3Dtcp::33209-:22 -boot order=
=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive file=3D/fs=
/LABEL=3DKVM/disk0-nfsroot-cairo-7,media=3Ddisk,if=3Dvirtio -drive file=3D/=
fs/LABEL=3DKVM/disk1-nfsroot-cairo-7,media=3Ddisk,if=3Dvirtio -drive file=
=3D/fs/LABEL=3DKVM/disk2-nfsroot-cairo-7,media=3Ddisk,if=3Dvirtio -drive fi=
le=3D/fs/LABEL=3DKVM/disk3-nfsroot-cairo-7,media=3Ddisk,if=3Dvirtio -drive =
file=3D/fs/LABEL=3DKVM/disk4-nfsroot-cairo-7,media=3Ddisk,if=3Dvirtio -driv=
e file=3D/fs/LABEL=3DKVM/disk5-nfsroot-cairo-7,media=3Ddisk,if=3Dvirtio -pi=
dfile /dev/shm/kboot/pid-nfsroot-cairo-7 -serial file:/dev/shm/kboot/serial=
-nfsroot-cairo-7 -daemonize -display none -monitor null=20

--PEIAKu/WMn1b1Hv9
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="x86_64-nfsroot-b1daf37ff52cf2ff39b2db2399e052ad7965c6aa-inconsistent--130714.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IDM3NGIxMDU3OTdjM2Q0ZjI5YzY4NWYzYmU1MzVjMzVmNTY4OWIzMGUK
UHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgYjFkYWYzNy4uLiBNZXJnZSAnc2VjdXJpdHkv
Zm9yLWxpbnVzJyBpbnRvIGRldmVsLXhpYW4teDg2XzY0LTIwMTMxMjEzMTA1MgpIRUFEIGlz
IG5vdyBhdCAzNzRiMTA1Li4uIExpbnV4IDMuMTMtcmMzCmxzIC1hIC9rZXJuZWwtdGVzdHMv
cnVuLXF1ZXVlL2t2bS94ODZfNjQtbmZzcm9vdC9saW51eC1kZXZlbDpkZXZlbC14aWFuLXg4
Nl82NC0yMDEzMTIxMzEwNTI6Mzc0YjEwNTc5N2MzZDRmMjljNjg1ZjNiZTUzNWMzNWY1Njg5
YjMwZTpiaXNlY3QtbW0KIFNVQ0NFU1MKCmJpc2VjdDogZ29vZCBjb21taXQgMzc0YjEwNTc5
N2MzZDRmMjljNjg1ZjNiZTUzNWMzNWY1Njg5YjMwZQpnaXQgYmlzZWN0IHN0YXJ0IGIxZGFm
MzdmZjUyY2YyZmYzOWIyZGIyMzk5ZTA1MmFkNzk2NWM2YWEgMzc0YjEwNTc5N2MzZDRmMjlj
Njg1ZjNiZTUzNWMzNWY1Njg5YjMwZSAtLQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyAz
NzRiMTA1Li4uIExpbnV4IDMuMTMtcmMzCkhFQUQgaXMgbm93IGF0IGMyZjg0ZjUuLi4gTWVy
Z2UgJ25ldC9tYXN0ZXInIGludG8gZGV2ZWwteGlhbi14ODZfNjQtMjAxMzEyMTMxMDUyCmxz
IC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtbmZzcm9vdC9saW51eC1k
ZXZlbDpkZXZlbC14aWFuLXg4Nl82NC0yMDEzMTIxMzEwNTI6YzJmODRmNTE3NzI5MzI3MGMw
MjAzZmFiZmQ2MDBlMTFlMjExZmQ3MzpiaXNlY3QtbW0KCjIwMTMtMTItMTMtMTE6MzI6MzMg
YzJmODRmNTE3NzI5MzI3MGMwMjAzZmFiZmQ2MDBlMTFlMjExZmQ3MyBjb21waWxpbmcKOTQ1
IHJlYWwgIDE2NTMgdXNlciAgMTQzIHN5cyAgMTkwLjA5JSBjcHUgCXg4Nl82NC1uZnNyb290
CgoyMDEzLTEyLTEzLTExOjU2OjI1IGRldGVjdGluZyBib290IHN0YXRlIDMuMTMuMC1yYzMt
MDEwMTQtZ2MyZjg0ZjUuLi4uLi4uLi4uLi4uLi4uLi4uLi4gVEVTVCBGQUlMVVJFClsgICAx
OC40MDA2MzVdIFsgSU5GTzogaW5jb25zaXN0ZW50IGxvY2sgc3RhdGUgXQpbICAgMTguNDAw
NjM1XSAzLjEzLjAtcmMzLTAxMDE0LWdjMmY4NGY1ICM1NjAgTm90IHRhaW50ZWQKWyAgIDE4
LjQwMDYzNV0gLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClsgICAxOC40MDA2
MzVdIGluY29uc2lzdGVudCB7U09GVElSUS1PTi1XfSAtPiB7SU4tU09GVElSUS1XfSB1c2Fn
ZS4KWyAgIDE4LjQwMDYzNV0gc3dhcHBlci8xLzAgW0hDMFswXTpTQzFbMV06SEUxOlNFMF0g
dGFrZXM6ClsgICAxOC40MDA2MzVdICAoJigmc2stPnNrX2RzdF9sb2NrKS0+cmxvY2speysu
Py4uLn0sIGF0OiBbPGZmZmZmZmZmODFhMjQyMmI+XSBfX3VkcDRfbGliX3JjdisweDU2OS8w
eDc5ZApbICAgMTguNDAwNjM1XSB7U09GVElSUS1PTi1XfSBzdGF0ZSB3YXMgcmVnaXN0ZXJl
ZCBhdDoKWyAgIDE4LjQwMDYzNV0gICBbPGZmZmZmZmZmODEwYjE2Y2M+XSBfX2xvY2tfYWNx
dWlyZSsweDk3NS8weDE4NjgKWyAgIDE4LjQwMDYzNV0gICBbPGZmZmZmZmZmODEwYjJjYWM+
XSBsb2NrX2FjcXVpcmUrMHhhYi8weDEyZQpbICAgMTguNDAwNjM1XSAgIFs8ZmZmZmZmZmY4
MWFlZDZmMz5dIF9yYXdfc3Bpbl9sb2NrKzB4M2IvMHg2ZApbICAgMTguNDAwNjM1XSAgIFs8
ZmZmZmZmZmY4MWEyYjNhYj5dIGluZXRfYmluZCsweDE4ZC8weDFkYwpbICAgMTguNDAwNjM1
XSAgIFs8ZmZmZmZmZmY4MTk5OTZhYz5dIGtlcm5lbF9iaW5kKzB4MTAvMHgxMgpbICAgMTgu
NDAwNjM1XSAgIFs8ZmZmZmZmZmY4MWFhYWI0ND5dIHhzX2JpbmQrMHhhMC8weDExZQpbICAg
MTguNDAwNjM1XSAgIFs8ZmZmZmZmZmY4MWFhYzY1MT5dIHhzX2NyZWF0ZV9zb2NrLmlzcmEu
MTQrMHgyMGIvMHgyMzAKWyAgIDE4LjQwMDYzNV0gICBbPGZmZmZmZmZmODFhYWM4NWY+XSB4
c190Y3Bfc2V0dXBfc29ja2V0KzB4NWYvMHgzZTUKWyAgIDE4LjQwMDYzNV0gICBbPGZmZmZm
ZmZmODEwOGEwZDc+XSBwcm9jZXNzX29uZV93b3JrKzB4MjQ3LzB4NDQzClsgICAxOC40MDA2
MzVdICAgWzxmZmZmZmZmZjgxMDhhZWFjPl0gd29ya2VyX3RocmVhZCsweDFkMi8weDJiYwpb
ICAgMTguNDAwNjM1XSAgIFs8ZmZmZmZmZmY4MTA5MDIyOD5dIGt0aHJlYWQrMHhmOS8weDEw
MQpbICAgMTguNDAwNjM1XSAgIFs8ZmZmZmZmZmY4MWFmNTZmYz5dIHJldF9mcm9tX2Zvcmsr
MHg3Yy8weGIwClsgICAxOC40MDA2MzVdIGlycSBldmVudCBzdGFtcDogMzg0NDc4ClsgICAx
OC40MDA2MzVdIGhhcmRpcnFzIGxhc3QgIGVuYWJsZWQgYXQgKDM4NDQ3OCk6IFs8ZmZmZmZm
ZmY4MTA3NjZhZj5dIGxvY2FsX2JoX2VuYWJsZSsweGFiLzB4YjUKWyAgIDE4LjQwMDYzNV0g
aGFyZGlycXMgbGFzdCBkaXNhYmxlZCBhdCAoMzg0NDc3KTogWzxmZmZmZmZmZjgxMDc2NjVh
Pl0gbG9jYWxfYmhfZW5hYmxlKzB4NTYvMHhiNQpbICAgMTguNDAwNjM1XSBzb2Z0aXJxcyBs
YXN0ICBlbmFibGVkIGF0ICgzODQ0NTYpOiBbPGZmZmZmZmZmODEwNzYxMDY+XSBfbG9jYWxf
YmhfZW5hYmxlKzB4NDMvMHg0NQpbICAgMTguNDAwNjM1XSBzb2Z0aXJxcyBsYXN0IGRpc2Fi
bGVkIGF0ICgzODQ0NTcpOiBbPGZmZmZmZmZmODEwNzY3Nzk+XSBpcnFfZXhpdCsweDU5LzB4
YTAKWyAgIDE4LjQwMDYzNV0gClsgICAxOC40MDA2MzVdIG90aGVyIGluZm8gdGhhdCBtaWdo
dCBoZWxwIHVzIGRlYnVnIHRoaXM6ClsgICAxOC40MDA2MzVdICBQb3NzaWJsZSB1bnNhZmUg
bG9ja2luZyBzY2VuYXJpbzoKWyAgIDE4LjQwMDYzNV0gClsgICAxOC40MDA2MzVdICAgICAg
ICBDUFUwClsgICAxOC40MDA2MzVdICAgICAgICAtLS0tClsgICAxOC40MDA2MzVdICAgbG9j
aygmKCZzay0+c2tfZHN0X2xvY2spLT5ybG9jayk7ClsgICAxOC40MDA2MzVdICAgPEludGVy
cnVwdD4KWyAgIDE4LjQwMDYzNV0gICAgIGxvY2soJigmc2stPnNrX2RzdF9sb2NrKS0+cmxv
Y2spOwpbICAgMTguNDAwNjM1XSAKWyAgIDE4LjQwMDYzNV0gICoqKiBERUFETE9DSyAqKioK
WyAgIDE4LjQwMDYzNV0gClsgICAxOC40MDA2MzVdIDIgbG9ja3MgaGVsZCBieSBzd2FwcGVy
LzEvMDoKWyAgIDE4LjQwMDYzNV0gICMwOiAgKHJjdV9yZWFkX2xvY2spey4rLisuLn0sIGF0
OiBbPGZmZmZmZmZmODE5YWU2NWY+XSBfX25ldGlmX3JlY2VpdmVfc2tiX2NvcmUrMHgxNjgv
MHg1OGUKWyAgIDE4LjQwMDYzNV0gICMxOiAgKHJjdV9yZWFkX2xvY2spey4rLisuLn0sIGF0
OiBbPGZmZmZmZmZmODE5ZmM5YzQ+XSBpcF9sb2NhbF9kZWxpdmVyX2ZpbmlzaCsweDJmLzB4
MmEwClsgICAxOC40MDA2MzVdIApbICAgMTguNDAwNjM1XSBzdGFjayBiYWNrdHJhY2U6Clsg
ICAxOC40MDA2MzVdIENQVTogMSBQSUQ6IDAgQ29tbTogc3dhcHBlci8xIE5vdCB0YWludGVk
IDMuMTMuMC1yYzMtMDEwMTQtZ2MyZjg0ZjUgIzU2MApbICAgMTguNDAwNjM1XSBIYXJkd2Fy
ZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDExClsgICAxOC40MDA2
MzVdICAwMDAwMDAwMDAwMDAwMDAyIGZmZmY4ODAwMWVjMDM5OTAgZmZmZmZmZmY4MWFlMWIy
NiBmZmZmODgwMDFlN2M4MDAwClsgICAxOC40MDA2MzVdICBmZmZmODgwMDFlYzAzOWUwIGZm
ZmZmZmZmODFhZDllZGQgMDAwMDAwMDAwMDAwMDAwMSBmZmZmODgwMDAwMDAwMDAxClsgICAx
OC40MDA2MzVdICBmZmZmODgwMDAwMDAwMDAwIGZmZmY4ODAwMWU3Yzg3NzggMDAwMDAwMDAw
MDAwMDAwNCAwMDAwMDAwMDAwMDAwMDA2ClsgICAxOC40MDA2MzVdIENhbGwgVHJhY2U6Clsg
ICAxOC40MDA2MzVdICA8SVJRPiAgWzxmZmZmZmZmZjgxYWUxYjI2Pl0gZHVtcF9zdGFjaysw
eDRkLzB4NjYKWyAgIDE4LjQwMDYzNV0gIFs8ZmZmZmZmZmY4MWFkOWVkZD5dIHByaW50X3Vz
YWdlX2J1ZysweDJhOC8weDJiOQpbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxMGFmOTQ2
Pl0gPyBwcmludF9zaG9ydGVzdF9sb2NrX2RlcGVuZGVuY2llcysweDE5My8weDE5MwpbICAg
MTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxMGIwNWMxPl0gbWFya19sb2NrKzB4MzNjLzB4NTdj
ClsgICAxOC40MDA2MzVdICBbPGZmZmZmZmZmODEwYjE2NWE+XSBfX2xvY2tfYWNxdWlyZSsw
eDkwMy8weDE4NjgKWyAgIDE4LjQwMDYzNV0gIFs8ZmZmZmZmZmY4MTA5MjAxOT5dID8gcnVu
X3Bvc2l4X2NwdV90aW1lcnMrMHgzZS8weDQ4OApbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZm
ZjgxMGFkZTA2Pl0gPyB0cmFjZV9oYXJkaXJxc19vZmZfY2FsbGVyKzB4MWYvMHhiMgpbICAg
MTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxMGIyY2FjPl0gbG9ja19hY3F1aXJlKzB4YWIvMHgx
MmUKWyAgIDE4LjQwMDYzNV0gIFs8ZmZmZmZmZmY4MWEyNDIyYj5dID8gX191ZHA0X2xpYl9y
Y3YrMHg1NjkvMHg3OWQKWyAgIDE4LjQwMDYzNV0gIFs8ZmZmZmZmZmY4MTBhZGUwNj5dID8g
dHJhY2VfaGFyZGlycXNfb2ZmX2NhbGxlcisweDFmLzB4YjIKWyAgIDE4LjQwMDYzNV0gIFs8
ZmZmZmZmZmY4MWFlZDZmMz5dIF9yYXdfc3Bpbl9sb2NrKzB4M2IvMHg2ZApbICAgMTguNDAw
NjM1XSAgWzxmZmZmZmZmZjgxYTI0MjJiPl0gPyBfX3VkcDRfbGliX3JjdisweDU2OS8weDc5
ZApbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxYTI0MjJiPl0gX191ZHA0X2xpYl9yY3Yr
MHg1NjkvMHg3OWQKWyAgIDE4LjQwMDYzNV0gIFs8ZmZmZmZmZmY4MWEyNDhmNz5dIHVkcF9y
Y3YrMHgxYS8weDFjClsgICAxOC40MDA2MzVdICBbPGZmZmZmZmZmODE5ZmNhZTY+XSBpcF9s
b2NhbF9kZWxpdmVyX2ZpbmlzaCsweDE1MS8weDJhMApbICAgMTguNDAwNjM1XSAgWzxmZmZm
ZmZmZjgxOWZjOWM0Pl0gPyBpcF9sb2NhbF9kZWxpdmVyX2ZpbmlzaCsweDJmLzB4MmEwClsg
ICAxOC40MDA2MzVdICBbPGZmZmZmZmZmODE5ZmQxZjg+XSBpcF9sb2NhbF9kZWxpdmVyKzB4
N2EvMHg3ZgpbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxOWZjZmNmPl0gaXBfcmN2X2Zp
bmlzaCsweDM5YS8weDQ2MQpbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxOWZkNDk1Pl0g
aXBfcmN2KzB4Mjk4LzB4MmY3ClsgICAxOC40MDA2MzVdICBbPGZmZmZmZmZmODE5YWU5YzQ+
XSBfX25ldGlmX3JlY2VpdmVfc2tiX2NvcmUrMHg0Y2QvMHg1OGUKWyAgIDE4LjQwMDYzNV0g
IFs8ZmZmZmZmZmY4MTlhZTY1Zj5dID8gX19uZXRpZl9yZWNlaXZlX3NrYl9jb3JlKzB4MTY4
LzB4NThlClsgICAxOC40MDA2MzVdICBbPGZmZmZmZmZmODE5YWVlYWI+XSBfX25ldGlmX3Jl
Y2VpdmVfc2tiKzB4MWQvMHg1ZgpbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxOWFlZjU1
Pl0gbmV0aWZfcmVjZWl2ZV9za2IrMHg2OC8weGY0ClsgICAxOC40MDA2MzVdICBbPGZmZmZm
ZmZmODE5YWY2YWY+XSBuYXBpX2dyb19yZWNlaXZlKzB4M2UvMHg4MApbICAgMTguNDAwNjM1
XSAgWzxmZmZmZmZmZjgxN2JhYTc0Pl0gZTEwMDBfY2xlYW5fcnhfaXJxKzB4MzkzLzB4NDE1
ClsgICAxOC40MDA2MzVdICBbPGZmZmZmZmZmODE3YjhmNGM+XSBlMTAwMF9jbGVhbisweDU5
ZC8weDcxZgpbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxMDYzNGQxPl0gPyBrdm1fY2xv
Y2tfcmVhZCsweDI3LzB4MzEKWyAgIDE4LjQwMDYzNV0gIFs8ZmZmZmZmZmY4MTAzZWRkMD5d
ID8gc2NoZWRfY2xvY2srMHg5LzB4ZApbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxOWFm
ZmE1Pl0gbmV0X3J4X2FjdGlvbisweGY2LzB4MjEwClsgICAxOC40MDA2MzVdICBbPGZmZmZm
ZmZmODEwNzYyZmM+XSBfX2RvX3NvZnRpcnErMHhmMy8weDI3YQpbICAgMTguNDAwNjM1XSAg
WzxmZmZmZmZmZjgxMDc2Nzc5Pl0gaXJxX2V4aXQrMHg1OS8weGEwClsgICAxOC40MDA2MzVd
ICBbPGZmZmZmZmZmODFhZjc4NGQ+XSBkb19JUlErMHg5ZC8weGI0ClsgICAxOC40MDA2MzVd
ICBbPGZmZmZmZmZmODFhZWU1ZjI+XSBjb21tb25faW50ZXJydXB0KzB4NzIvMHg3MgpbICAg
MTguNDAwNjM1XSAgPEVPST4gIFs8ZmZmZmZmZmY4MWFmMWViNT5dID8gX19hdG9taWNfbm90
aWZpZXJfY2FsbF9jaGFpbisweDUvMHg5YwpbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgx
YWYxZWI1Pl0gPyBfX2F0b21pY19ub3RpZmllcl9jYWxsX2NoYWluKzB4NS8weDljClsgICAx
OC40MDA2MzVdICBbPGZmZmZmZmZmODEwNjM2Yzg+XSA/IG5hdGl2ZV9zYWZlX2hhbHQrMHg2
LzB4OApbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZmZjgxMGIwYTk1Pl0gPyB0cmFjZV9oYXJk
aXJxc19vbisweGQvMHhmClsgICAxOC40MDA2MzVdICBbPGZmZmZmZmZmODEwM2Y5ZDE+XSBk
ZWZhdWx0X2lkbGUrMHgzOC8weGMxClsgICAxOC40MDA2MzVdICBbPGZmZmZmZmZmODEwNDAx
NTQ+XSBhcmNoX2NwdV9pZGxlKzB4MTgvMHgyOApbICAgMTguNDAwNjM1XSAgWzxmZmZmZmZm
ZjgxMGMwYWUwPl0gY3B1X3N0YXJ0dXBfZW50cnkrMHgxNWMvMHgyNGQKWyAgIDE4LjQwMDYz
NV0gIFs8ZmZmZmZmZmY4MTA1YTE4Zj5dIHN0YXJ0X3NlY29uZGFyeSsweDI0Ny8weDI1MApb
ICAgNDIuMTU1Mzg5XSByYW5kb206IG5vbmJsb2NraW5nIHBvb2wgaXMgaW5pdGlhbGl6ZWQK
WyAgIDU4LjMwMTIxM10gTkZTRDogVXNpbmcgL3Zhci9saWIvbmZzL3Y0cmVjb3ZlcnkgYXMg
dGhlIE5GU3Y0IHN0YXRlIHJlY292ZXJ5IGRpcmVjdG9yeQpbICAgNTguMzA1MjAxXSBORlNE
OiBzdGFydGluZyA5MC1zZWNvbmQgZ3JhY2UgcGVyaW9kIChuZXQgZmZmZmZmZmY4MjE4Njlj
MCkKL2tlcm5lbC94ODZfNjQtbmZzcm9vdC9jMmY4NGY1MTc3MjkzMjcwYzAyMDNmYWJmZDYw
MGUxMWUyMTFmZDczL2RtZXNnLW5mc3Jvb3QtaW5uLTE0OjIwMTMxMjEzMTIwNzAyOng4Nl82
NC1uZnNyb290OjMuMTMuMC1yYzMtMDEwMTQtZ2MyZjg0ZjU6NTYwCjA6MToxIGFsbF9nb29k
OmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW1SRVBFQVQgQ09VTlQ6IDIwICAjIC9jYy93Zmcv
bW0tYmlzZWN0Ly5yZXBlYXQbWzBtCgpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyBjMmY4
NGY1Li4uIE1lcmdlICduZXQvbWFzdGVyJyBpbnRvIGRldmVsLXhpYW4teDg2XzY0LTIwMTMx
MjEzMTA1MgpIRUFEIGlzIG5vdyBhdCAyNDgxYjBiLi4uIE1lcmdlICdhcm0tc29jL3RvLWJ1
aWxkJyBpbnRvIGRldmVsLXhpYW4teDg2XzY0LTIwMTMxMjEzMTA1MgpscyAtYSAva2VybmVs
LXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LW5mc3Jvb3QvbGludXgtZGV2ZWw6ZGV2ZWwt
eGlhbi14ODZfNjQtMjAxMzEyMTMxMDUyOjI0ODFiMGI5YTVmN2FmMGY3NDhhMThhOTcxMDM3
MWE5Y2IyMmM5ODY6YmlzZWN0LW1tCgoyMDEzLTEyLTEzLTEyOjA3OjE3IDI0ODFiMGI5YTVm
N2FmMGY3NDhhMThhOTcxMDM3MWE5Y2IyMmM5ODYgY29tcGlsaW5nCjM4MCByZWFsICA4MzMg
dXNlciAgNjkgc3lzICAyMzcuNTIlIGNwdSAJeDg2XzY0LW5mc3Jvb3QKCjIwMTMtMTItMTMt
MTI6MjE6MjggZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMy4wLXJjMy0wMDg3MC1nMjQ4MWIw
Yi4uLi4uLi4uLi4uCTEJMgkzCTQuCTYJOC4uLi4uCTkuCTEwLi4uCTExLi4uCTEyLi4uCTE3
CTIwIFNVQ0NFU1MKClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2FzIDI0ODFiMGIuLi4gTWVy
Z2UgJ2FybS1zb2MvdG8tYnVpbGQnIGludG8gZGV2ZWwteGlhbi14ODZfNjQtMjAxMzEyMTMx
MDUyCkhFQUQgaXMgbm93IGF0IDNjMGVlZTMuLi4gTGludXggMi42LjM3CkJpc2VjdGluZzog
NzEgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDYgc3RlcHMp
CltjODc4MWNmNGEzMDlhZTRkMTM5M2Y1ODc4ZDRlNTE5ODc2NjU4OThjXSBibngyeDogYXZv
aWQgbnVsbCBwb2ludGVyIGRlcmVmZXJlbmNlIHdoZW4gZW5hYmxpbmcgU1ItSU9WCnJ1bm5p
bmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93
ZmcvbW0vb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2
XzY0LW5mc3Jvb3QvbGludXgtZGV2ZWw6ZGV2ZWwteGlhbi14ODZfNjQtMjAxMzEyMTMxMDUy
OmM4NzgxY2Y0YTMwOWFlNGQxMzkzZjU4NzhkNGU1MTk4NzY2NTg5OGM6YmlzZWN0LW1tCgoy
MDEzLTEyLTEzLTEyOjQyOjEzIGM4NzgxY2Y0YTMwOWFlNGQxMzkzZjU4NzhkNGU1MTk4NzY2
NTg5OGMgY29tcGlsaW5nCjc0NCByZWFsICAxNjc4IHVzZXIgIDE0MiBzeXMgIDI0NC41NSUg
Y3B1IAl4ODZfNjQtbmZzcm9vdAoKMjAxMy0xMi0xMy0xMzowMjozMyBkZXRlY3RpbmcgYm9v
dCBzdGF0ZSAzLjEzLjAtcmMyLTAwNTAwLWdjODc4MWNmLi4uLi4uLgk2CTExCTEzCTE4CTIw
IFNVQ0NFU1MKCkJpc2VjdGluZzogMzUgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDUgc3RlcHMpCltmZmZjMTVhNTAxMmU5MDUyZDNiMjM2ZWZjNTY4NDA4
NDFhMTI1NDE2XSB2eGxhbjogcmVsZWFzZSBydCB3aGVuIGZvdW5kIGNpcmN1bGFyIHJvdXRl
CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAv
aG9tZS93ZmcvbW0vb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9r
dm0veDg2XzY0LW5mc3Jvb3QvbGludXgtZGV2ZWw6ZGV2ZWwteGlhbi14ODZfNjQtMjAxMzEy
MTMxMDUyOmZmZmMxNWE1MDEyZTkwNTJkM2IyMzZlZmM1Njg0MDg0MWExMjU0MTY6YmlzZWN0
LW1tCgoyMDEzLTEyLTEzLTEzOjA4OjM3IGZmZmMxNWE1MDEyZTkwNTJkM2IyMzZlZmM1Njg0
MDg0MWExMjU0MTYgY29tcGlsaW5nCjUyMCByZWFsICA1NzUgdXNlciAgNTAgc3lzICAxMjAu
MzMlIGNwdSAJeDg2XzY0LW5mc3Jvb3QKCjIwMTMtMTItMTMtMTM6Mjc6MjMgZGV0ZWN0aW5n
IGJvb3Qgc3RhdGUgMy4xMy4wLXJjMi0wMDUzNi1nZmZmYzE1YS4uLi4uLgkyCTQJMTEuCTE4
LgkxOS4uLi4JMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAxNyByZXZpc2lvbnMgbGVmdCB0byB0
ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNCBzdGVwcykKWzRiZDdiNTEyN2JkMDJjMTJjMWNj
ODM3YTdhMGI2Y2UyOTVlYjI1MDVdIG1pY3JlbDogYWRkIHN1cHBvcnQgZm9yIEtTWjgwNDFS
TkxJCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5z
aCAvaG9tZS93ZmcvbW0vb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1
ZS9rdm0veDg2XzY0LW5mc3Jvb3QvbGludXgtZGV2ZWw6ZGV2ZWwteGlhbi14ODZfNjQtMjAx
MzEyMTMxMDUyOjRiZDdiNTEyN2JkMDJjMTJjMWNjODM3YTdhMGI2Y2UyOTVlYjI1MDU6Ymlz
ZWN0LW1tCgoyMDEzLTEyLTEzLTEzOjM2OjMwIDRiZDdiNTEyN2JkMDJjMTJjMWNjODM3YTdh
MGI2Y2UyOTVlYjI1MDUgY29tcGlsaW5nCjExMCByZWFsICA1MiB1c2VyICA5IHN5cyAgNTUu
MTklIGNwdSAJeDg2XzY0LW5mc3Jvb3QKCjIwMTMtMTItMTMtMTM6NDU6NDMgZGV0ZWN0aW5n
IGJvb3Qgc3RhdGUgMy4xMy4wLXJjMi0wMDU1NC1nNGJkN2I1MS4uLi4uLgk1CTEyCTE4CTIw
IFNVQ0NFU1MKCkJpc2VjdGluZzogOCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRo
aXMgKHJvdWdobHkgMyBzdGVwcykKWzk1MDhmZGRlNGQ1M2YwZDllNTgzZTg0MWVkMDg3OTZk
MmYzMTBiZTFdIFJldmVydCAiODM5MCA6IFJlcGxhY2UgZWlfZGVidWcgd2l0aCBtc2dfZW5h
YmxlL05FVElGX01TR18qIGZlYXR1cmUiCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbW0vb2JqLWJpc2VjdApscyAtYSAv
a2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LW5mc3Jvb3QvbGludXgtZGV2ZWw6
ZGV2ZWwteGlhbi14ODZfNjQtMjAxMzEyMTMxMDUyOjk1MDhmZGRlNGQ1M2YwZDllNTgzZTg0
MWVkMDg3OTZkMmYzMTBiZTE6YmlzZWN0LW1tCgoyMDEzLTEyLTEzLTEzOjUwOjUwIDk1MDhm
ZGRlNGQ1M2YwZDllNTgzZTg0MWVkMDg3OTZkMmYzMTBiZTEgcmV1c2UgL2tlcm5lbC94ODZf
NjQtbmZzcm9vdC85NTA4ZmRkZTRkNTNmMGQ5ZTU4M2U4NDFlZDA4Nzk2ZDJmMzEwYmUxL3Zt
bGludXotMy4xMy4wLXJjMi0wMDI1NC1nOTUwOGZkZAoKMjAxMy0xMi0xMy0xMzo1MDo1MCBk
ZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uLi4uLgkxCTIuCTMuLi4JNQk2Li4uCTcJOC4JMTAu
LgkxMS4uLi4uCTEzLi4JMTQuLi4JMTYuLi4JMTcJMTguCTIwIFNVQ0NFU1MKCkJpc2VjdGlu
ZzogNCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMiBzdGVw
cykKWzEwNTc0MDU5Y2UwNDUxYzY1NzJjODUzMjljNzcyYWExNTA4NWY4ZWJdIHhlbi1uZXRi
YWNrOiBuYXBpOiBmaXggYWJ1c2Ugb2YgYnVkZ2V0CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3Rz
L2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbW0vb2JqLWJpc2VjdAps
cyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LW5mc3Jvb3QvbGludXgt
ZGV2ZWw6ZGV2ZWwteGlhbi14ODZfNjQtMjAxMzEyMTMxMDUyOjEwNTc0MDU5Y2UwNDUxYzY1
NzJjODUzMjljNzcyYWExNTA4NWY4ZWI6YmlzZWN0LW1tCgoyMDEzLTEyLTEzLTE0OjE0OjM0
IDEwNTc0MDU5Y2UwNDUxYzY1NzJjODUzMjljNzcyYWExNTA4NWY4ZWIgY29tcGlsaW5nCjM3
IHJlYWwgIDQ3IHVzZXIgIDggc3lzICAxNDcuMDQlIGNwdSAJeDg2XzY0LW5mc3Jvb3QKCjIw
MTMtMTItMTMtMTQ6MTk6MjggZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMy4wLXJjMi0wMDU2
Ny1nMTA1NzQwNS4uLi4uLi4uLi4uLi4uLi4uIFRFU1QgRkFJTFVSRQpbICAgMjEuMjkyMzA5
XSBbIElORk86IGluY29uc2lzdGVudCBsb2NrIHN0YXRlIF0KWyAgIDIxLjI5MjMwOV0gMy4x
My4wLXJjMi0wMDU2Ny1nMTA1NzQwNSAjNTY1IE5vdCB0YWludGVkClsgICAyMS4yOTIzMDld
IC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpbICAgMjEuMjkyMzA5XSBpbmNv
bnNpc3RlbnQge1NPRlRJUlEtT04tV30gLT4ge0lOLVNPRlRJUlEtV30gdXNhZ2UuClsgICAy
MS4yOTIzMDldIHN3YXBwZXIvMC8wIFtIQzBbMF06U0MxWzFdOkhFMTpTRTBdIHRha2VzOgpb
ICAgMjEuMjkyMzA5XSAgKCYoJnNrLT5za19kc3RfbG9jayktPnJsb2NrKXsrLj8uLi59LCBh
dDogWzxmZmZmZmZmZjgxYTI0MzNiPl0gX191ZHA0X2xpYl9yY3YrMHg1NjkvMHg3OWQKWyAg
IDIxLjI5MjMwOV0ge1NPRlRJUlEtT04tV30gc3RhdGUgd2FzIHJlZ2lzdGVyZWQgYXQ6Clsg
ICAyMS4yOTIzMDldICAgWzxmZmZmZmZmZjgxMGIxNmNjPl0gX19sb2NrX2FjcXVpcmUrMHg5
NzUvMHgxODY4ClsgICAyMS4yOTIzMDldICAgWzxmZmZmZmZmZjgxMGIyY2FjPl0gbG9ja19h
Y3F1aXJlKzB4YWIvMHgxMmUKWyAgIDIxLjI5MjMwOV0gICBbPGZmZmZmZmZmODFhZWQ4MDM+
XSBfcmF3X3NwaW5fbG9jaysweDNiLzB4NmQKWyAgIDIxLjI5MjMwOV0gICBbPGZmZmZmZmZm
ODFhMmI0YmI+XSBpbmV0X2JpbmQrMHgxOGQvMHgxZGMKWyAgIDIxLjI5MjMwOV0gICBbPGZm
ZmZmZmZmODE5OTk3YmM+XSBrZXJuZWxfYmluZCsweDEwLzB4MTIKWyAgIDIxLjI5MjMwOV0g
ICBbPGZmZmZmZmZmODFhYWFjNTQ+XSB4c19iaW5kKzB4YTAvMHgxMWUKWyAgIDIxLjI5MjMw
OV0gICBbPGZmZmZmZmZmODFhYWM3NjE+XSB4c19jcmVhdGVfc29jay5pc3JhLjE0KzB4MjBi
LzB4MjMwClsgICAyMS4yOTIzMDldICAgWzxmZmZmZmZmZjgxYWFjOTZmPl0geHNfdGNwX3Nl
dHVwX3NvY2tldCsweDVmLzB4M2U1ClsgICAyMS4yOTIzMDldICAgWzxmZmZmZmZmZjgxMDhh
MGQ3Pl0gcHJvY2Vzc19vbmVfd29yaysweDI0Ny8weDQ0MwpbICAgMjEuMjkyMzA5XSAgIFs8
ZmZmZmZmZmY4MTA4YWVhYz5dIHdvcmtlcl90aHJlYWQrMHgxZDIvMHgyYmMKWyAgIDIxLjI5
MjMwOV0gICBbPGZmZmZmZmZmODEwOTAyMjg+XSBrdGhyZWFkKzB4ZjkvMHgxMDEKWyAgIDIx
LjI5MjMwOV0gICBbPGZmZmZmZmZmODFhZjU4M2M+XSByZXRfZnJvbV9mb3JrKzB4N2MvMHhi
MApbICAgMjEuMjkyMzA5XSBpcnEgZXZlbnQgc3RhbXA6IDUxNjUxNgpbICAgMjEuMjkyMzA5
XSBoYXJkaXJxcyBsYXN0ICBlbmFibGVkIGF0ICg1MTY1MTYpOiBbPGZmZmZmZmZmODEwNzY2
YWY+XSBsb2NhbF9iaF9lbmFibGUrMHhhYi8weGI1ClsgICAyMS4yOTIzMDldIGhhcmRpcnFz
IGxhc3QgZGlzYWJsZWQgYXQgKDUxNjUxNSk6IFs8ZmZmZmZmZmY4MTA3NjY1YT5dIGxvY2Fs
X2JoX2VuYWJsZSsweDU2LzB4YjUKWyAgIDIxLjI5MjMwOV0gc29mdGlycXMgbGFzdCAgZW5h
YmxlZCBhdCAoNTE2NDk0KTogWzxmZmZmZmZmZjgxMDc2MTA2Pl0gX2xvY2FsX2JoX2VuYWJs
ZSsweDQzLzB4NDUKWyAgIDIxLjI5MjMwOV0gc29mdGlycXMgbGFzdCBkaXNhYmxlZCBhdCAo
NTE2NDk1KTogWzxmZmZmZmZmZjgxMDc2Nzc5Pl0gaXJxX2V4aXQrMHg1OS8weGEwClsgICAy
MS4yOTIzMDldIApbICAgMjEuMjkyMzA5XSBvdGhlciBpbmZvIHRoYXQgbWlnaHQgaGVscCB1
cyBkZWJ1ZyB0aGlzOgpbICAgMjEuMjkyMzA5XSAgUG9zc2libGUgdW5zYWZlIGxvY2tpbmcg
c2NlbmFyaW86ClsgICAyMS4yOTIzMDldIApbICAgMjEuMjkyMzA5XSAgICAgICAgQ1BVMApb
ICAgMjEuMjkyMzA5XSAgICAgICAgLS0tLQpbICAgMjEuMjkyMzA5XSAgIGxvY2soJigmc2st
PnNrX2RzdF9sb2NrKS0+cmxvY2spOwpbICAgMjEuMjkyMzA5XSAgIDxJbnRlcnJ1cHQ+Clsg
ICAyMS4yOTIzMDldICAgICBsb2NrKCYoJnNrLT5za19kc3RfbG9jayktPnJsb2NrKTsKWyAg
IDIxLjI5MjMwOV0gClsgICAyMS4yOTIzMDldICAqKiogREVBRExPQ0sgKioqClsgICAyMS4y
OTIzMDldIApbICAgMjEuMjkyMzA5XSAyIGxvY2tzIGhlbGQgYnkgc3dhcHBlci8wLzA6Clsg
ICAyMS4yOTIzMDldICAjMDogIChyY3VfcmVhZF9sb2NrKXsuKy4rLi59LCBhdDogWzxmZmZm
ZmZmZjgxOWFlNzZmPl0gX19uZXRpZl9yZWNlaXZlX3NrYl9jb3JlKzB4MTY4LzB4NThlClsg
ICAyMS4yOTIzMDldICAjMTogIChyY3VfcmVhZF9sb2NrKXsuKy4rLi59LCBhdDogWzxmZmZm
ZmZmZjgxOWZjYWQ0Pl0gaXBfbG9jYWxfZGVsaXZlcl9maW5pc2grMHgyZi8weDJhMApbICAg
MjEuMjkyMzA5XSAKWyAgIDIxLjI5MjMwOV0gc3RhY2sgYmFja3RyYWNlOgpbICAgMjEuMjky
MzA5XSBDUFU6IDAgUElEOiAwIENvbW06IHN3YXBwZXIvMCBOb3QgdGFpbnRlZCAzLjEzLjAt
cmMyLTAwNTY3LWcxMDU3NDA1ICM1NjUKWyAgIDIxLjI5MjMwOV0gSGFyZHdhcmUgbmFtZTog
Qm9jaHMgQm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICAgMjEuMjkyMzA5XSAgMDAw
MDAwMDAwMDAwMDAwMiBmZmZmODgwMDFlYTAzOTkwIGZmZmZmZmZmODFhZTFjMzYgZmZmZmZm
ZmY4MjA4OTQ5MApbICAgMjEuMjkyMzA5XSAgZmZmZjg4MDAxZWEwMzllMCBmZmZmZmZmZjgx
YWQ5ZmVkIDAwMDAwMDAwMDAwMDAwMDEgZmZmZjg4MDAwMDAwMDAwMQpbICAgMjEuMjkyMzA5
XSAgZmZmZjg4MDAwMDAwMDAwMCBmZmZmZmZmZjgyMDg5YzA4IDAwMDAwMDAwMDAwMDAwMDQg
MDAwMDAwMDAwMDAwMDAwNgpbICAgMjEuMjkyMzA5XSBDYWxsIFRyYWNlOgpbICAgMjEuMjky
MzA5XSAgPElSUT4gIFs8ZmZmZmZmZmY4MWFlMWMzNj5dIGR1bXBfc3RhY2srMHg0ZC8weDY2
ClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZmODFhZDlmZWQ+XSBwcmludF91c2FnZV9idWcr
MHgyYTgvMHgyYjkKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTBhZjk0Nj5dID8gcHJp
bnRfc2hvcnRlc3RfbG9ja19kZXBlbmRlbmNpZXMrMHgxOTMvMHgxOTMKWyAgIDIxLjI5MjMw
OV0gIFs8ZmZmZmZmZmY4MTBiMDVjMT5dIG1hcmtfbG9jaysweDMzYy8weDU3YwpbICAgMjEu
MjkyMzA5XSAgWzxmZmZmZmZmZjgxMGIxNjVhPl0gX19sb2NrX2FjcXVpcmUrMHg5MDMvMHgx
ODY4ClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZmODEwOTIwMTk+XSA/IHJ1bl9wb3NpeF9j
cHVfdGltZXJzKzB4M2UvMHg0ODgKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTBhZGUw
Nj5dID8gdHJhY2VfaGFyZGlycXNfb2ZmX2NhbGxlcisweDFmLzB4YjIKWyAgIDIxLjI5MjMw
OV0gIFs8ZmZmZmZmZmY4MTBiMmNhYz5dIGxvY2tfYWNxdWlyZSsweGFiLzB4MTJlClsgICAy
MS4yOTIzMDldICBbPGZmZmZmZmZmODFhMjQzM2I+XSA/IF9fdWRwNF9saWJfcmN2KzB4NTY5
LzB4NzlkClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZmODEwYWRlMDY+XSA/IHRyYWNlX2hh
cmRpcnFzX29mZl9jYWxsZXIrMHgxZi8weGIyClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZm
ODFhZWQ4MDM+XSBfcmF3X3NwaW5fbG9jaysweDNiLzB4NmQKWyAgIDIxLjI5MjMwOV0gIFs8
ZmZmZmZmZmY4MWEyNDMzYj5dID8gX191ZHA0X2xpYl9yY3YrMHg1NjkvMHg3OWQKWyAgIDIx
LjI5MjMwOV0gIFs8ZmZmZmZmZmY4MWEyNDMzYj5dIF9fdWRwNF9saWJfcmN2KzB4NTY5LzB4
NzlkClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZmODFhMjRhMDc+XSB1ZHBfcmN2KzB4MWEv
MHgxYwpbICAgMjEuMjkyMzA5XSAgWzxmZmZmZmZmZjgxOWZjYmY2Pl0gaXBfbG9jYWxfZGVs
aXZlcl9maW5pc2grMHgxNTEvMHgyYTAKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTlm
Y2FkND5dID8gaXBfbG9jYWxfZGVsaXZlcl9maW5pc2grMHgyZi8weDJhMApbICAgMjEuMjky
MzA5XSAgWzxmZmZmZmZmZjgxOWZkMzA4Pl0gaXBfbG9jYWxfZGVsaXZlcisweDdhLzB4N2YK
WyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTlmZDBkZj5dIGlwX3Jjdl9maW5pc2grMHgz
OWEvMHg0NjEKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTlmZDVhNT5dIGlwX3Jjdisw
eDI5OC8weDJmNwpbICAgMjEuMjkyMzA5XSAgWzxmZmZmZmZmZjgxOWFlYWQ0Pl0gX19uZXRp
Zl9yZWNlaXZlX3NrYl9jb3JlKzB4NGNkLzB4NThlClsgICAyMS4yOTIzMDldICBbPGZmZmZm
ZmZmODE5YWU3NmY+XSA/IF9fbmV0aWZfcmVjZWl2ZV9za2JfY29yZSsweDE2OC8weDU4ZQpb
ICAgMjEuMjkyMzA5XSAgWzxmZmZmZmZmZjgxOWFlZmJiPl0gX19uZXRpZl9yZWNlaXZlX3Nr
YisweDFkLzB4NWYKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTlhZjA2NT5dIG5ldGlm
X3JlY2VpdmVfc2tiKzB4NjgvMHhmNApbICAgMjEuMjkyMzA5XSAgWzxmZmZmZmZmZjgxOWFm
N2JmPl0gbmFwaV9ncm9fcmVjZWl2ZSsweDNlLzB4ODAKWyAgIDIxLjI5MjMwOV0gIFs8ZmZm
ZmZmZmY4MTdiYWNhYj5dIGUxMDAwX2NsZWFuX3J4X2lycSsweDM5My8weDQxNQpbICAgMjEu
MjkyMzA5XSAgWzxmZmZmZmZmZjgxN2I5MTgzPl0gZTEwMDBfY2xlYW4rMHg1OWQvMHg3MWYK
WyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTA2MzRkMT5dID8ga3ZtX2Nsb2NrX3JlYWQr
MHgyNy8weDMxClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZmODEwM2VkZDA+XSA/IHNjaGVk
X2Nsb2NrKzB4OS8weGQKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTliMDBiNT5dIG5l
dF9yeF9hY3Rpb24rMHhmNi8weDIxMApbICAgMjEuMjkyMzA5XSAgWzxmZmZmZmZmZjgxMDc2
MmZjPl0gX19kb19zb2Z0aXJxKzB4ZjMvMHgyN2EKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZm
ZmY4MTA3Njc3OT5dIGlycV9leGl0KzB4NTkvMHhhMApbICAgMjEuMjkyMzA5XSAgWzxmZmZm
ZmZmZjgxYWY3OThkPl0gZG9fSVJRKzB4OWQvMHhiNApbICAgMjEuMjkyMzA5XSAgWzxmZmZm
ZmZmZjgxYWVlNzMyPl0gY29tbW9uX2ludGVycnVwdCsweDcyLzB4NzIKWyAgIDIxLjI5MjMw
OV0gIDxFT0k+ICBbPGZmZmZmZmZmODFhZjFmZjU+XSA/IF9fYXRvbWljX25vdGlmaWVyX2Nh
bGxfY2hhaW4rMHg1LzB4OWMKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MTA2MzZjOD5d
ID8gbmF0aXZlX3NhZmVfaGFsdCsweDYvMHg4ClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZm
ODEwM2Y5ZDE+XSBkZWZhdWx0X2lkbGUrMHgzOC8weGMxClsgICAyMS4yOTIzMDldICBbPGZm
ZmZmZmZmODEwNDAxNTQ+XSBhcmNoX2NwdV9pZGxlKzB4MTgvMHgyOApbICAgMjEuMjkyMzA5
XSAgWzxmZmZmZmZmZjgxMGMwYWUwPl0gY3B1X3N0YXJ0dXBfZW50cnkrMHgxNWMvMHgyNGQK
WyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MWFjZTQyNT5dIHJlc3RfaW5pdCsweGM5LzB4
Y2QKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MWFjZTM2MT5dID8gcmVzdF9pbml0KzB4
NS8weGNkClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZmODIzOWVkNzc+XSBzdGFydF9rZXJu
ZWwrMHgzZDQvMHgzZTAKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MjM5ZTdiMT5dID8g
cmVwYWlyX2Vudl9zdHJpbmcrMHg1OC8weDU4ClsgICAyMS4yOTIzMDldICBbPGZmZmZmZmZm
ODIzOWUxMjA+XSA/IGVhcmx5X2lkdF9oYW5kbGVycysweDEyMC8weDEyMApbICAgMjEuMjky
MzA5XSAgWzxmZmZmZmZmZjgyMzllNDY3Pl0geDg2XzY0X3N0YXJ0X3Jlc2VydmF0aW9ucysw
eDJhLzB4MmMKWyAgIDIxLjI5MjMwOV0gIFs8ZmZmZmZmZmY4MjM5ZTVhOT5dIHg4Nl82NF9z
dGFydF9rZXJuZWwrMHgxNDAvMHgxNGQKWyAgIDU5LjU4MDE4Ml0gcmMgKDE5NDkpIHVzZWQg
Z3JlYXRlc3Qgc3RhY2sgZGVwdGg6IDM2NzIgYnl0ZXMgbGVmdApbICAgNjMuMjQ2NTM5XSBO
RlNEOiBVc2luZyAvdmFyL2xpYi9uZnMvdjRyZWNvdmVyeSBhcyB0aGUgTkZTdjQgc3RhdGUg
cmVjb3ZlcnkgZGlyZWN0b3J5ClsgICA2My4yNTA3MzRdIE5GU0Q6IHN0YXJ0aW5nIDkwLXNl
Y29uZCBncmFjZSBwZXJpb2QgKG5ldCBmZmZmZmZmZjgyMTg2OWMwKQova2VybmVsL3g4Nl82
NC1uZnNyb290LzEwNTc0MDU5Y2UwNDUxYzY1NzJjODUzMjljNzcyYWExNTA4NWY4ZWIvZG1l
c2ctbmZzcm9vdC1jYWlyby0xODoyMDEzMTIxMzE0Mjc1MTp4ODZfNjQtbmZzcm9vdDozLjEz
LjAtcmMyLTAwNTY3LWcxMDU3NDA1OjU2NQowOjE6MSBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBi
b290cwobWzE7MzVtUkVQRUFUIENPVU5UOiAyMCAgIyAvY2Mvd2ZnL21tLWJpc2VjdC8ucmVw
ZWF0G1swbQoKQmlzZWN0aW5nOiAxIHJldmlzaW9uIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlz
IChyb3VnaGx5IDEgc3RlcCkKWzk3NTAyMjMxMDIzM2ZiMGYwMTkzODczZDc5YTdiODQzODA3
MGZhODJdIHVkcDogaXB2NDogbXVzdCBhZGQgc3luY2hyb25pemF0aW9uIGluIHVkcF9za19y
eF9kc3Rfc2V0KCkKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1m
YWlsdXJlLnNoIC9ob21lL3dmZy9tbS9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMv
cnVuLXF1ZXVlL2t2bS94ODZfNjQtbmZzcm9vdC9saW51eC1kZXZlbDpkZXZlbC14aWFuLXg4
Nl82NC0yMDEzMTIxMzEwNTI6OTc1MDIyMzEwMjMzZmIwZjAxOTM4NzNkNzlhN2I4NDM4MDcw
ZmE4MjpiaXNlY3QtbW0KIFRFU1QgRkFJTFVSRQpbICAgMTkuODg4OTM4XSBbIElORk86IGlu
Y29uc2lzdGVudCBsb2NrIHN0YXRlIF0KWyAgIDE5Ljg4ODkzOF0gMy4xMy4wLXJjMi0wMDI1
Ni1nOTc1MDIyMyAjNzk0IE5vdCB0YWludGVkClsgICAxOS44ODg5MzhdIC0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpbICAgMTkuODg4OTM4XSBpbmNvbnNpc3RlbnQge1NP
RlRJUlEtT04tV30gLT4ge0lOLVNPRlRJUlEtV30gdXNhZ2UuClsgICAxOS44ODg5MzhdIHN3
YXBwZXIvMC8wIFtIQzBbMF06U0MxWzFdOkhFMTpTRTBdIHRha2VzOgpbICAgMTkuODg4OTM4
XSAgKCYoJnNrLT5za19kc3RfbG9jayktPnJsb2NrKXsrLj8uLi59LCBhdDogWzxmZmZmZmZm
ZjgxYTI3ODEyPl0gX191ZHA0X2xpYl9yY3YrMHg1NjkvMHg3OWQKWyAgIDE5Ljg4ODkzOF0g
e1NPRlRJUlEtT04tV30gc3RhdGUgd2FzIHJlZ2lzdGVyZWQgYXQ6ClsgICAxOS44ODg5Mzhd
ICAgWzxmZmZmZmZmZjgxMGIxNmI3Pl0gX19sb2NrX2FjcXVpcmUrMHg5NmMvMHgxODVmClsg
ICAxOS44ODg5MzhdICAgWzxmZmZmZmZmZjgxMGIyYzk3Pl0gbG9ja19hY3F1aXJlKzB4YWIv
MHgxMmUKWyAgIDE5Ljg4ODkzOF0gICBbPGZmZmZmZmZmODFhZjBhZmI+XSBfcmF3X3NwaW5f
bG9jaysweDNiLzB4NmQKWyAgIDE5Ljg4ODkzOF0gICBbPGZmZmZmZmZmODFhMmU5NmQ+XSBp
bmV0X2JpbmQrMHgxOGQvMHgxZGMKWyAgIDE5Ljg4ODkzOF0gICBbPGZmZmZmZmZmODE5OWNl
NWM+XSBrZXJuZWxfYmluZCsweDEwLzB4MTIKWyAgIDE5Ljg4ODkzOF0gICBbPGZmZmZmZmZm
ODFhYWRmOTQ+XSB4c19iaW5kKzB4YTAvMHgxMWUKWyAgIDE5Ljg4ODkzOF0gICBbPGZmZmZm
ZmZmODFhYWZhYTE+XSB4c19jcmVhdGVfc29jay5pc3JhLjE0KzB4MjBiLzB4MjMwClsgICAx
OS44ODg5MzhdICAgWzxmZmZmZmZmZjgxYWFmY2FmPl0geHNfdGNwX3NldHVwX3NvY2tldCsw
eDVmLzB4M2U1ClsgICAxOS44ODg5MzhdICAgWzxmZmZmZmZmZjgxMDhhMGQ3Pl0gcHJvY2Vz
c19vbmVfd29yaysweDI0Ny8weDQ0MwpbICAgMTkuODg4OTM4XSAgIFs8ZmZmZmZmZmY4MTA4
YWVhYz5dIHdvcmtlcl90aHJlYWQrMHgxZDIvMHgyYmMKWyAgIDE5Ljg4ODkzOF0gICBbPGZm
ZmZmZmZmODEwOTAyMjg+XSBrdGhyZWFkKzB4ZjkvMHgxMDEKWyAgIDE5Ljg4ODkzOF0gICBb
PGZmZmZmZmZmODFhZjhhZmM+XSByZXRfZnJvbV9mb3JrKzB4N2MvMHhiMApbICAgMTkuODg4
OTM4XSBpcnEgZXZlbnQgc3RhbXA6IDU0NjM2OApbICAgMTkuODg4OTM4XSBoYXJkaXJxcyBs
YXN0ICBlbmFibGVkIGF0ICg1NDYzNjgpOiBbPGZmZmZmZmZmODEwNzY2YWY+XSBsb2NhbF9i
aF9lbmFibGUrMHhhYi8weGI1ClsgICAxOS44ODg5MzhdIGhhcmRpcnFzIGxhc3QgZGlzYWJs
ZWQgYXQgKDU0NjM2Nyk6IFs8ZmZmZmZmZmY4MTA3NjY1YT5dIGxvY2FsX2JoX2VuYWJsZSsw
eDU2LzB4YjUKWyAgIDE5Ljg4ODkzOF0gc29mdGlycXMgbGFzdCAgZW5hYmxlZCBhdCAoNTQ2
MzQ2KTogWzxmZmZmZmZmZjgxMDc2MTA2Pl0gX2xvY2FsX2JoX2VuYWJsZSsweDQzLzB4NDUK
WyAgIDE5Ljg4ODkzOF0gc29mdGlycXMgbGFzdCBkaXNhYmxlZCBhdCAoNTQ2MzQ3KTogWzxm
ZmZmZmZmZjgxMDc2Nzc5Pl0gaXJxX2V4aXQrMHg1OS8weGEwClsgICAxOS44ODg5MzhdIApb
ICAgMTkuODg4OTM4XSBvdGhlciBpbmZvIHRoYXQgbWlnaHQgaGVscCB1cyBkZWJ1ZyB0aGlz
OgpbICAgMTkuODg4OTM4XSAgUG9zc2libGUgdW5zYWZlIGxvY2tpbmcgc2NlbmFyaW86Clsg
ICAxOS44ODg5MzhdIApbICAgMTkuODg4OTM4XSAgICAgICAgQ1BVMApbICAgMTkuODg4OTM4
XSAgICAgICAgLS0tLQpbICAgMTkuODg4OTM4XSAgIGxvY2soJigmc2stPnNrX2RzdF9sb2Nr
KS0+cmxvY2spOwpbICAgMTkuODg4OTM4XSAgIDxJbnRlcnJ1cHQ+ClsgICAxOS44ODg5Mzhd
ICAgICBsb2NrKCYoJnNrLT5za19kc3RfbG9jayktPnJsb2NrKTsKWyAgIDE5Ljg4ODkzOF0g
ClsgICAxOS44ODg5MzhdICAqKiogREVBRExPQ0sgKioqClsgICAxOS44ODg5MzhdIApbICAg
MTkuODg4OTM4XSAyIGxvY2tzIGhlbGQgYnkgc3dhcHBlci8wLzA6ClsgICAxOS44ODg5Mzhd
ICAjMDogIChyY3VfcmVhZF9sb2NrKXsuKy4rLi59LCBhdDogWzxmZmZmZmZmZjgxOWIxZGJh
Pl0gX19uZXRpZl9yZWNlaXZlX3NrYl9jb3JlKzB4MTY4LzB4NThlClsgICAxOS44ODg5Mzhd
ICAjMTogIChyY3VfcmVhZF9sb2NrKXsuKy4rLi59LCBhdDogWzxmZmZmZmZmZjgxYTAwMDlh
Pl0gaXBfbG9jYWxfZGVsaXZlcl9maW5pc2grMHgyZi8weDJhMApbICAgMTkuODg4OTM4XSAK
WyAgIDE5Ljg4ODkzOF0gc3RhY2sgYmFja3RyYWNlOgpbICAgMTkuODg4OTM4XSBDUFU6IDAg
UElEOiAwIENvbW06IHN3YXBwZXIvMCBOb3QgdGFpbnRlZCAzLjEzLjAtcmMyLTAwMjU2LWc5
NzUwMjIzICM3OTQKWyAgIDE5Ljg4ODkzOF0gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMs
IEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICAgMTkuODg4OTM4XSAgMDAwMDAwMDAwMDAwMDAw
MiBmZmZmODgwMDFlYTAzOWEwIGZmZmZmZmZmODFhZTRmMmQgZmZmZmZmZmY4MjA5NzQ5MApb
ICAgMTkuODg4OTM4XSAgZmZmZjg4MDAxZWEwMzlmMCBmZmZmZmZmZjgxYWRkMzE3IDAwMDAw
MDAwMDAwMDAwMDEgZmZmZjg4MDAwMDAwMDAwMQpbICAgMTkuODg4OTM4XSAgZmZmZjg4MDAw
MDAwMDAwMCBmZmZmZmZmZjgyMDk3YzA4IDAwMDAwMDAwMDAwMDAwMDQgMDAwMDAwMDAwMDAw
MDAwNgpbICAgMTkuODg4OTM4XSBDYWxsIFRyYWNlOgpbICAgMTkuODg4OTM4XSAgPElSUT4g
IFs8ZmZmZmZmZmY4MWFlNGYyZD5dIGR1bXBfc3RhY2srMHg0ZC8weDY2ClsgICAxOS44ODg5
MzhdICBbPGZmZmZmZmZmODFhZGQzMTc+XSBwcmludF91c2FnZV9idWcrMHgyYTgvMHgyYjkK
WyAgIDE5Ljg4ODkzOF0gIFs8ZmZmZmZmZmY4MTBhZjkzYT5dID8gcHJpbnRfc2hvcnRlc3Rf
bG9ja19kZXBlbmRlbmNpZXMrMHgxOTMvMHgxOTMKWyAgIDE5Ljg4ODkzOF0gIFs8ZmZmZmZm
ZmY4MTBiMDViNT5dIG1hcmtfbG9jaysweDMzYy8weDU3YwpbICAgMTkuODg4OTM4XSAgWzxm
ZmZmZmZmZjgxMGIxNjQ1Pl0gX19sb2NrX2FjcXVpcmUrMHg4ZmEvMHgxODVmClsgICAxOS44
ODg5MzhdICBbPGZmZmZmZmZmODEwOWZkOWM+XSA/IHNjaGVkX2Nsb2NrX2xvY2FsKzB4MTIv
MHg3MgpbICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgxMGFkZGZhPl0gPyB0cmFjZV9oYXJk
aXJxc19vZmZfY2FsbGVyKzB4MWYvMHhiMgpbICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgx
MGIyYzk3Pl0gbG9ja19hY3F1aXJlKzB4YWIvMHgxMmUKWyAgIDE5Ljg4ODkzOF0gIFs8ZmZm
ZmZmZmY4MWEyNzgxMj5dID8gX191ZHA0X2xpYl9yY3YrMHg1NjkvMHg3OWQKWyAgIDE5Ljg4
ODkzOF0gIFs8ZmZmZmZmZmY4MTBhZGRmYT5dID8gdHJhY2VfaGFyZGlycXNfb2ZmX2NhbGxl
cisweDFmLzB4YjIKWyAgIDE5Ljg4ODkzOF0gIFs8ZmZmZmZmZmY4MWFmMGFmYj5dIF9yYXdf
c3Bpbl9sb2NrKzB4M2IvMHg2ZApbICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgxYTI3ODEy
Pl0gPyBfX3VkcDRfbGliX3JjdisweDU2OS8weDc5ZApbICAgMTkuODg4OTM4XSAgWzxmZmZm
ZmZmZjgxYTI3ODEyPl0gX191ZHA0X2xpYl9yY3YrMHg1NjkvMHg3OWQKWyAgIDE5Ljg4ODkz
OF0gIFs8ZmZmZmZmZmY4MWEyN2VkZT5dIHVkcF9yY3YrMHgxYS8weDFjClsgICAxOS44ODg5
MzhdICBbPGZmZmZmZmZmODFhMDAxYmM+XSBpcF9sb2NhbF9kZWxpdmVyX2ZpbmlzaCsweDE1
MS8weDJhMApbICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgxYTAwMDlhPl0gPyBpcF9sb2Nh
bF9kZWxpdmVyX2ZpbmlzaCsweDJmLzB4MmEwClsgICAxOS44ODg5MzhdICBbPGZmZmZmZmZm
ODFhMDA4Y2U+XSBpcF9sb2NhbF9kZWxpdmVyKzB4N2EvMHg3ZgpbICAgMTkuODg4OTM4XSAg
WzxmZmZmZmZmZjgxYTAwNmE1Pl0gaXBfcmN2X2ZpbmlzaCsweDM5YS8weDQ2MQpbICAgMTku
ODg4OTM4XSAgWzxmZmZmZmZmZjgxYTAwYjU2Pl0gaXBfcmN2KzB4MjgzLzB4MmUwClsgICAx
OS44ODg5MzhdICBbPGZmZmZmZmZmODE5YjIxMWY+XSBfX25ldGlmX3JlY2VpdmVfc2tiX2Nv
cmUrMHg0Y2QvMHg1OGUKWyAgIDE5Ljg4ODkzOF0gIFs8ZmZmZmZmZmY4MTliMWRiYT5dID8g
X19uZXRpZl9yZWNlaXZlX3NrYl9jb3JlKzB4MTY4LzB4NThlClsgICAxOS44ODg5MzhdICBb
PGZmZmZmZmZmODE5YjI2MDY+XSBfX25ldGlmX3JlY2VpdmVfc2tiKzB4MWQvMHg1ZgpbICAg
MTkuODg4OTM4XSAgWzxmZmZmZmZmZjgxOWIyNmIwPl0gbmV0aWZfcmVjZWl2ZV9za2IrMHg2
OC8weGY0ClsgICAxOS44ODg5MzhdICBbPGZmZmZmZmZmODE5YjJlMGE+XSBuYXBpX2dyb19y
ZWNlaXZlKzB4M2UvMHg4MApbICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgxN2JlODI2Pl0g
ZTEwMDBfY2xlYW5fcnhfaXJxKzB4MzkzLzB4NDE1ClsgICAxOS44ODg5MzhdICBbPGZmZmZm
ZmZmODE3YmNjZmU+XSBlMTAwMF9jbGVhbisweDU5ZC8weDcxZgpbICAgMTkuODg4OTM4XSAg
WzxmZmZmZmZmZjgxMDYzNGQxPl0gPyBrdm1fY2xvY2tfcmVhZCsweDI3LzB4MzEKWyAgIDE5
Ljg4ODkzOF0gIFs8ZmZmZmZmZmY4MTAzZWRkMD5dID8gc2NoZWRfY2xvY2srMHg5LzB4ZApb
ICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgxOWIzNzAwPl0gbmV0X3J4X2FjdGlvbisweGY2
LzB4MjEwClsgICAxOS44ODg5MzhdICBbPGZmZmZmZmZmODEwNzYyZmM+XSBfX2RvX3NvZnRp
cnErMHhmMy8weDI3YQpbICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgxMDc2Nzc5Pl0gaXJx
X2V4aXQrMHg1OS8weGEwClsgICAxOS44ODg5MzhdICBbPGZmZmZmZmZmODFhZmFjNGQ+XSBk
b19JUlErMHg5ZC8weGI0ClsgICAxOS44ODg5MzhdICBbPGZmZmZmZmZmODFhZjE5ZjI+XSBj
b21tb25faW50ZXJydXB0KzB4NzIvMHg3MgpbICAgMTkuODg4OTM4XSAgPEVPST4gIFs8ZmZm
ZmZmZmY4MWFmNTJiNT5dID8gX19hdG9taWNfbm90aWZpZXJfY2FsbF9jaGFpbisweDUvMHg5
YwpbICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgxMDYzNmM4Pl0gPyBuYXRpdmVfc2FmZV9o
YWx0KzB4Ni8weDgKWyAgIDE5Ljg4ODkzOF0gIFs8ZmZmZmZmZmY4MTAzZjlkMT5dIGRlZmF1
bHRfaWRsZSsweDM4LzB4YzEKWyAgIDE5Ljg4ODkzOF0gIFs8ZmZmZmZmZmY4MTA0MDE1ND5d
IGFyY2hfY3B1X2lkbGUrMHgxOC8weDI4ClsgICAxOS44ODg5MzhdICBbPGZmZmZmZmZmODEw
YzBhYzU+XSBjcHVfc3RhcnR1cF9lbnRyeSsweDE1Yy8weDI0ZApbICAgMTkuODg4OTM4XSAg
WzxmZmZmZmZmZjgxYWQxNzU1Pl0gcmVzdF9pbml0KzB4YzkvMHhjZApbICAgMTkuODg4OTM4
XSAgWzxmZmZmZmZmZjgxYWQxNjkxPl0gPyByZXN0X2luaXQrMHg1LzB4Y2QKWyAgIDE5Ljg4
ODkzOF0gIFs8ZmZmZmZmZmY4MjNhZWQ3Nz5dIHN0YXJ0X2tlcm5lbCsweDNkNC8weDNlMApb
ICAgMTkuODg4OTM4XSAgWzxmZmZmZmZmZjgyM2FlN2IxPl0gPyByZXBhaXJfZW52X3N0cmlu
ZysweDU4LzB4NTgKWyAgIDE5Ljg4ODkzOF0gIFs8ZmZmZmZmZmY4MjNhZTEyMD5dID8gZWFy
bHlfaWR0X2hhbmRsZXJzKzB4MTIwLzB4MTIwClsgICAxOS44ODg5MzhdICBbPGZmZmZmZmZm
ODIzYWU0Njc+XSB4ODZfNjRfc3RhcnRfcmVzZXJ2YXRpb25zKzB4MmEvMHgyYwpbICAgMTku
ODg4OTM4XSAgWzxmZmZmZmZmZjgyM2FlNWE5Pl0geDg2XzY0X3N0YXJ0X2tlcm5lbCsweDE0
MC8weDE0ZApbICAgNzYuNDE1NDQ5XSBORlNEOiBVc2luZyAvdmFyL2xpYi9uZnMvdjRyZWNv
dmVyeSBhcyB0aGUgTkZTdjQgc3RhdGUgcmVjb3ZlcnkgZGlyZWN0b3J5ClsgICA3Ni40MTg5
NzVdIE5GU0Q6IHN0YXJ0aW5nIDkwLXNlY29uZCBncmFjZSBwZXJpb2QgKG5ldCBmZmZmZmZm
ZjgyMTk2YTAwKQpLZXJuZWwgdGVzdHM6IEJvb3QgT0shCi9rZXJuZWwveDg2XzY0LW5mc3Jv
b3QvOTc1MDIyMzEwMjMzZmIwZjAxOTM4NzNkNzlhN2I4NDM4MDcwZmE4Mi9kbWVzZy1uZnNy
b290LWNhaXJvLTExOjIwMTMxMjEyMjAwNzQ2Ong4Nl82NC1uZnNyb290OjMuMTMuMC1yYzIt
MDAyNTYtZzk3NTAyMjM6Nzk0Ci9rZXJuZWwveDg2XzY0LW5mc3Jvb3QvOTc1MDIyMzEwMjMz
ZmIwZjAxOTM4NzNkNzlhN2I4NDM4MDcwZmE4Mi9kbWVzZy1uZnNyb290LWNhaXJvLTEzOjIw
MTMxMjEyMjAwOTE2Ong4Nl82NC1uZnNyb290OjMuMTMuMC1yYzItMDAyNTYtZzk3NTAyMjM6
Nzk0Ci9rZXJuZWwveDg2XzY0LW5mc3Jvb3QvOTc1MDIyMzEwMjMzZmIwZjAxOTM4NzNkNzlh
N2I4NDM4MDcwZmE4Mi9kbWVzZy1uZnNyb290LWlubi03OjIwMTMxMjEyMjAwOTE3Ong4Nl82
NC1uZnNyb290OjMuMTMuMC1yYzItMDAyNTYtZzk3NTAyMjM6Nzk0Ci9rZXJuZWwveDg2XzY0
LW5mc3Jvb3QvOTc1MDIyMzEwMjMzZmIwZjAxOTM4NzNkNzlhN2I4NDM4MDcwZmE4Mi9kbWVz
Zy1uZnNyb290LXhpYW4tMTE6MjAxMzEyMTIyMDA3NDY6eDg2XzY0LW5mc3Jvb3Q6My4xMy4w
LXJjMi0wMDI1Ni1nOTc1MDIyMzo3OTQKL2tlcm5lbC94ODZfNjQtbmZzcm9vdC85NzUwMjIz
MTAyMzNmYjBmMDE5Mzg3M2Q3OWE3Yjg0MzgwNzBmYTgyL2RtZXNnLW5mc3Jvb3QtaW5uLTE2
OjIwMTMxMjEyMjAxMTAzOng4Nl82NC1uZnNyb290OjMuMTMuMC1yYzItMDAyNTYtZzk3NTAy
MjM6Nzk0Ci9rZXJuZWwveDg2XzY0LW5mc3Jvb3QvOTc1MDIyMzEwMjMzZmIwZjAxOTM4NzNk
NzlhN2I4NDM4MDcwZmE4Mi9kbWVzZy1uZnNyb290LWNhaXJvLTM6MjAxMzEyMTIyMDA5MDI6
eDg2XzY0LW5mc3Jvb3Q6My4xMy4wLXJjMi0wMDI1Ni1nOTc1MDIyMzo3OTQKMTo2OjggYWxs
X2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bVJFUEVBVCBDT1VOVDogMjUgICMgL2Nj
L3dmZy9tbS1iaXNlY3QvLnJlcGVhdBtbMG0KCkJpc2VjdGluZzogMCByZXZpc2lvbnMgbGVm
dCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMCBzdGVwcykKW2ExYmYxNzUwODcxYTZm
MjQyYjBmZGIxNzRjYzU1ZDJjNTdlN2VkNjZdIG5ldDpmZWM6IHJlbW92ZSBkdXBsaWNhdGUg
bGluZXMgaW4gY29tbWVudCBhYm91dCBlcnJhdGEgRVJSMDA2MzU4CnJ1bm5pbmcgL2Mva2Vy
bmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbW0vb2Jq
LWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LW5mc3Jv
b3QvbGludXgtZGV2ZWw6ZGV2ZWwteGlhbi14ODZfNjQtMjAxMzEyMTMxMDUyOmExYmYxNzUw
ODcxYTZmMjQyYjBmZGIxNzRjYzU1ZDJjNTdlN2VkNjY6YmlzZWN0LW1tCgoyMDEzLTEyLTEz
LTE0OjI4OjI1IGExYmYxNzUwODcxYTZmMjQyYjBmZGIxNzRjYzU1ZDJjNTdlN2VkNjYgcmV1
c2UgL2tlcm5lbC94ODZfNjQtbmZzcm9vdC9hMWJmMTc1MDg3MWE2ZjI0MmIwZmRiMTc0Y2M1
NWQyYzU3ZTdlZDY2L3ZtbGludXotMy4xMy4wLXJjMi0wMDI1NS1nYTFiZjE3NQoKMjAxMy0x
Mi0xMy0xNDoyODoyNSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uLi4uLi4JMTEJMjAJMjUg
U1VDQ0VTUwoKOTc1MDIyMzEwMjMzZmIwZjAxOTM4NzNkNzlhN2I4NDM4MDcwZmE4MiBpcyB0
aGUgZmlyc3QgYmFkIGNvbW1pdApjb21taXQgOTc1MDIyMzEwMjMzZmIwZjAxOTM4NzNkNzlh
N2I4NDM4MDcwZmE4MgpBdXRob3I6IEVyaWMgRHVtYXpldCA8ZWR1bWF6ZXRAZ29vZ2xlLmNv
bT4KRGF0ZTogICBXZWQgRGVjIDExIDE0OjQ2OjUxIDIwMTMgLTA4MDAKCiAgICB1ZHA6IGlw
djQ6IG11c3QgYWRkIHN5bmNocm9uaXphdGlvbiBpbiB1ZHBfc2tfcnhfZHN0X3NldCgpCiAg
ICAKICAgIFVubGlrZSBUQ1AsIFVEUCBpbnB1dCBwYXRoIGRvZXMgbm90IGhvbGQgdGhlIHNv
Y2tldCBsb2NrLgogICAgCiAgICBCZWZvcmUgbWVzc2luZyB3aXRoIHNrLT5za19yeF9kc3Qs
IHdlIG11c3QgdXNlIGEgc3BpbmxvY2ssIG90aGVyd2lzZQogICAgbXVsdGlwbGUgY3B1cyBj
b3VsZCBsZWFrIGEgcmVmY291bnQuCiAgICAKICAgIFRoaXMgcGF0Y2ggYWxzbyB0YWtlcyBj
YXJlIG9mIHJlbmV3aW5nIGEgc3RhbGUgZHN0IGVudHJ5LgogICAgKFdoZW4gdGhlIHNrLT5z
a19yeF9kc3Qgd291bGQgbm90IGJlIHVzZWQgYnkgSVAgZWFybHkgZGVtdXgpCiAgICAKICAg
IEZpeGVzOiA0MjFiMzg4NWJmNmQgKCJ1ZHA6IGlwdjQ6IEFkZCB1ZHAgZWFybHkgZGVtdXgi
KQogICAgU2lnbmVkLW9mZi1ieTogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUuY29t
PgogICAgQ2M6IFNoYXduIEJvaHJlciA8c2JvaHJlckByZ21hZHZpc29ycy5jb20+CiAgICBT
aWduZWQtb2ZmLWJ5OiBEYXZpZCBTLiBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+Cgo6
MDQwMDAwIDA0MDAwMCBlY2QzYjIwMTIxYzZlNGE4NDQ2MTFhNzg4ZTIyYzViMTRkYmEyNTBk
IDZlYmMxMjc4NjIxYjczOWEwMTc3OWUyMzAyMWJjNWJkNTM1M2Q2YTMgTQluZXQKYmlzZWN0
IHJ1biBzdWNjZXNzCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQt
bmZzcm9vdC9saW51eC1kZXZlbDpkZXZlbC14aWFuLXg4Nl82NC0yMDEzMTIxMzEwNTI6YTFi
ZjE3NTA4NzFhNmYyNDJiMGZkYjE3NGNjNTVkMmM1N2U3ZWQ2NjpiaXNlY3QtbW0KCjIwMTMt
MTItMTMtMTQ6MzQ6MzEgYTFiZjE3NTA4NzFhNmYyNDJiMGZkYjE3NGNjNTVkMmM1N2U3ZWQ2
NiByZXVzZSAva2VybmVsL3g4Nl82NC1uZnNyb290L2ExYmYxNzUwODcxYTZmMjQyYjBmZGIx
NzRjYzU1ZDJjNTdlN2VkNjYvdm1saW51ei0zLjEzLjAtcmMyLTAwMjU1LWdhMWJmMTc1Cgoy
MDEzLTEyLTEzLTE0OjM0OjMxIGRldGVjdGluZyBib290IHN0YXRlIC4uLi4uLi4JMjgJMzIJ
MzYJMzkJNDQJNDkJNTUJNjEJNjUJNjcuCTY4Lgk3MQk3Mwk3NSBTVUNDRVNTCgpscyAtYSAv
a2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LW5mc3Jvb3QvbGludXgtZGV2ZWw6
ZGV2ZWwteGlhbi14ODZfNjQtMjAxMzEyMTMxMDUyOmIxZGFmMzdmZjUyY2YyZmYzOWIyZGIy
Mzk5ZTA1MmFkNzk2NWM2YWE6YmlzZWN0LW1tCiBURVNUIEZBSUxVUkUKWyAgIDI0LjEyNjI0
NF0gWyBJTkZPOiBpbmNvbnNpc3RlbnQgbG9jayBzdGF0ZSBdClsgICAyNC4xMjYyNDRdIDMu
MTMuMC1yYzMtMDA2ODktZ2IxZGFmMzcgIzg5MiBOb3QgdGFpbnRlZApbICAgMjQuMTI2MjQ0
XSAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KWyAgIDI0LjEyNjI0NF0gaW5j
b25zaXN0ZW50IHtTT0ZUSVJRLU9OLVd9IC0+IHtJTi1TT0ZUSVJRLVd9IHVzYWdlLgpbICAg
MjQuMTI2MjQ0XSBzd2FwcGVyLzEvMCBbSEMwWzBdOlNDMVsxXTpIRTE6U0UwXSB0YWtlczoK
WyAgIDI0LjEyNjI0NF0gICgmKCZzay0+c2tfZHN0X2xvY2spLT5ybG9jayl7Ky4/Li4ufSwg
YXQ6IFs8ZmZmZmZmZmY4MWEyN2ZlMj5dIF9fdWRwNF9saWJfcmN2KzB4NTY5LzB4NzlkClsg
ICAyNC4xMjYyNDRdIHtTT0ZUSVJRLU9OLVd9IHN0YXRlIHdhcyByZWdpc3RlcmVkIGF0Ogpb
ICAgMjQuMTI2MjQ0XSAgIFs8ZmZmZmZmZmY4MTBiMTZiNz5dIF9fbG9ja19hY3F1aXJlKzB4
OTZjLzB4MTg1ZgpbICAgMjQuMTI2MjQ0XSAgIFs8ZmZmZmZmZmY4MTBiMmM5Nz5dIGxvY2tf
YWNxdWlyZSsweGFiLzB4MTJlClsgICAyNC4xMjYyNDRdICAgWzxmZmZmZmZmZjgxYWYxMmQz
Pl0gX3Jhd19zcGluX2xvY2srMHgzYi8weDZkClsgICAyNC4xMjYyNDRdICAgWzxmZmZmZmZm
ZjgxYTJmMTNkPl0gaW5ldF9iaW5kKzB4MThkLzB4MWRjClsgICAyNC4xMjYyNDRdICAgWzxm
ZmZmZmZmZjgxOTlkNjJjPl0ga2VybmVsX2JpbmQrMHgxMC8weDEyClsgICAyNC4xMjYyNDRd
ICAgWzxmZmZmZmZmZjgxYWFlNzY0Pl0geHNfYmluZCsweGEwLzB4MTFlClsgICAyNC4xMjYy
NDRdICAgWzxmZmZmZmZmZjgxYWIwMjcxPl0geHNfY3JlYXRlX3NvY2suaXNyYS4xNCsweDIw
Yi8weDIzMApbICAgMjQuMTI2MjQ0XSAgIFs8ZmZmZmZmZmY4MWFiMDQ3Zj5dIHhzX3RjcF9z
ZXR1cF9zb2NrZXQrMHg1Zi8weDNlNQpbICAgMjQuMTI2MjQ0XSAgIFs8ZmZmZmZmZmY4MTA4
YTBkNz5dIHByb2Nlc3Nfb25lX3dvcmsrMHgyNDcvMHg0NDMKWyAgIDI0LjEyNjI0NF0gICBb
PGZmZmZmZmZmODEwOGFlYWM+XSB3b3JrZXJfdGhyZWFkKzB4MWQyLzB4MmJjClsgICAyNC4x
MjYyNDRdICAgWzxmZmZmZmZmZjgxMDkwMjI4Pl0ga3RocmVhZCsweGY5LzB4MTAxClsgICAy
NC4xMjYyNDRdICAgWzxmZmZmZmZmZjgxYWY5MmZjPl0gcmV0X2Zyb21fZm9yaysweDdjLzB4
YjAKWyAgIDI0LjEyNjI0NF0gaXJxIGV2ZW50IHN0YW1wOiAzNjQ4NTYKWyAgIDI0LjEyNjI0
NF0gaGFyZGlycXMgbGFzdCAgZW5hYmxlZCBhdCAoMzY0ODU2KTogWzxmZmZmZmZmZjgxMDc2
NmFmPl0gbG9jYWxfYmhfZW5hYmxlKzB4YWIvMHhiNQpbICAgMjQuMTI2MjQ0XSBoYXJkaXJx
cyBsYXN0IGRpc2FibGVkIGF0ICgzNjQ4NTUpOiBbPGZmZmZmZmZmODEwNzY2NWE+XSBsb2Nh
bF9iaF9lbmFibGUrMHg1Ni8weGI1ClsgICAyNC4xMjYyNDRdIHNvZnRpcnFzIGxhc3QgIGVu
YWJsZWQgYXQgKDM2NDgzNCk6IFs8ZmZmZmZmZmY4MTA3NjEwNj5dIF9sb2NhbF9iaF9lbmFi
bGUrMHg0My8weDQ1ClsgICAyNC4xMjYyNDRdIHNvZnRpcnFzIGxhc3QgZGlzYWJsZWQgYXQg
KDM2NDgzNSk6IFs8ZmZmZmZmZmY4MTA3Njc3OT5dIGlycV9leGl0KzB4NTkvMHhhMApbICAg
MjQuMTI2MjQ0XSAKWyAgIDI0LjEyNjI0NF0gb3RoZXIgaW5mbyB0aGF0IG1pZ2h0IGhlbHAg
dXMgZGVidWcgdGhpczoKWyAgIDI0LjEyNjI0NF0gIFBvc3NpYmxlIHVuc2FmZSBsb2NraW5n
IHNjZW5hcmlvOgpbICAgMjQuMTI2MjQ0XSAKWyAgIDI0LjEyNjI0NF0gICAgICAgIENQVTAK
WyAgIDI0LjEyNjI0NF0gICAgICAgIC0tLS0KWyAgIDI0LjEyNjI0NF0gICBsb2NrKCYoJnNr
LT5za19kc3RfbG9jayktPnJsb2NrKTsKWyAgIDI0LjEyNjI0NF0gICA8SW50ZXJydXB0Pgpb
ICAgMjQuMTI2MjQ0XSAgICAgbG9jaygmKCZzay0+c2tfZHN0X2xvY2spLT5ybG9jayk7Clsg
ICAyNC4xMjYyNDRdIApbICAgMjQuMTI2MjQ0XSAgKioqIERFQURMT0NLICoqKgpbICAgMjQu
MTI2MjQ0XSAKWyAgIDI0LjEyNjI0NF0gMiBsb2NrcyBoZWxkIGJ5IHN3YXBwZXIvMS8wOgpb
ICAgMjQuMTI2MjQ0XSAgIzA6ICAocmN1X3JlYWRfbG9jayl7LisuKy4ufSwgYXQ6IFs8ZmZm
ZmZmZmY4MTliMjU4YT5dIF9fbmV0aWZfcmVjZWl2ZV9za2JfY29yZSsweDE2OC8weDU4ZQpb
ICAgMjQuMTI2MjQ0XSAgIzE6ICAocmN1X3JlYWRfbG9jayl7LisuKy4ufSwgYXQ6IFs8ZmZm
ZmZmZmY4MWEwMDg2YT5dIGlwX2xvY2FsX2RlbGl2ZXJfZmluaXNoKzB4MmYvMHgyYTAKWyAg
IDI0LjEyNjI0NF0gClsgICAyNC4xMjYyNDRdIHN0YWNrIGJhY2t0cmFjZToKWyAgIDI0LjEy
NjI0NF0gQ1BVOiAxIFBJRDogMCBDb21tOiBzd2FwcGVyLzEgTm90IHRhaW50ZWQgMy4xMy4w
LXJjMy0wMDY4OS1nYjFkYWYzNyAjODkyClsgICAyNC4xMjYyNDRdIEhhcmR3YXJlIG5hbWU6
IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTEKWyAgIDI0LjEyNjI0NF0gIDAw
MDAwMDAwMDAwMDAwMDIgZmZmZjg4MDAxZWMwMzlhMCBmZmZmZmZmZjgxYWU1NmZkIGZmZmY4
ODAwMWU3YzgwMDAKWyAgIDI0LjEyNjI0NF0gIGZmZmY4ODAwMWVjMDM5ZjAgZmZmZmZmZmY4
MWFkZGFlNyAwMDAwMDAwMDAwMDAwMDAxIGZmZmY4ODAwMDAwMDAwMDEKWyAgIDI0LjEyNjI0
NF0gIGZmZmY4ODAwMDAwMDAwMDAgZmZmZjg4MDAxZTdjODc3OCAwMDAwMDAwMDAwMDAwMDA0
IDAwMDAwMDAwMDAwMDAwMDYKWyAgIDI0LjEyNjI0NF0gQ2FsbCBUcmFjZToKWyAgIDI0LjEy
NjI0NF0gIDxJUlE+ICBbPGZmZmZmZmZmODFhZTU2ZmQ+XSBkdW1wX3N0YWNrKzB4NGQvMHg2
NgpbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxYWRkYWU3Pl0gcHJpbnRfdXNhZ2VfYnVn
KzB4MmE4LzB4MmI5ClsgICAyNC4xMjYyNDRdICBbPGZmZmZmZmZmODEwYWY5M2E+XSA/IHBy
aW50X3Nob3J0ZXN0X2xvY2tfZGVwZW5kZW5jaWVzKzB4MTkzLzB4MTkzClsgICAyNC4xMjYy
NDRdICBbPGZmZmZmZmZmODEwYjA1YjU+XSBtYXJrX2xvY2srMHgzM2MvMHg1N2MKWyAgIDI0
LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MTBiMTY0NT5dIF9fbG9ja19hY3F1aXJlKzB4OGZhLzB4
MTg1ZgpbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxMDlmZDljPl0gPyBzY2hlZF9jbG9j
a19sb2NhbCsweDEyLzB4NzIKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MTBhZGRmYT5d
ID8gdHJhY2VfaGFyZGlycXNfb2ZmX2NhbGxlcisweDFmLzB4YjIKWyAgIDI0LjEyNjI0NF0g
IFs8ZmZmZmZmZmY4MTBiMmM5Nz5dIGxvY2tfYWNxdWlyZSsweGFiLzB4MTJlClsgICAyNC4x
MjYyNDRdICBbPGZmZmZmZmZmODFhMjdmZTI+XSA/IF9fdWRwNF9saWJfcmN2KzB4NTY5LzB4
NzlkClsgICAyNC4xMjYyNDRdICBbPGZmZmZmZmZmODEwYWRkZmE+XSA/IHRyYWNlX2hhcmRp
cnFzX29mZl9jYWxsZXIrMHgxZi8weGIyClsgICAyNC4xMjYyNDRdICBbPGZmZmZmZmZmODFh
ZjEyZDM+XSBfcmF3X3NwaW5fbG9jaysweDNiLzB4NmQKWyAgIDI0LjEyNjI0NF0gIFs8ZmZm
ZmZmZmY4MWEyN2ZlMj5dID8gX191ZHA0X2xpYl9yY3YrMHg1NjkvMHg3OWQKWyAgIDI0LjEy
NjI0NF0gIFs8ZmZmZmZmZmY4MWEyN2ZlMj5dIF9fdWRwNF9saWJfcmN2KzB4NTY5LzB4Nzlk
ClsgICAyNC4xMjYyNDRdICBbPGZmZmZmZmZmODFhMjg2YWU+XSB1ZHBfcmN2KzB4MWEvMHgx
YwpbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxYTAwOThjPl0gaXBfbG9jYWxfZGVsaXZl
cl9maW5pc2grMHgxNTEvMHgyYTAKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MWEwMDg2
YT5dID8gaXBfbG9jYWxfZGVsaXZlcl9maW5pc2grMHgyZi8weDJhMApbICAgMjQuMTI2MjQ0
XSAgWzxmZmZmZmZmZjgxYTAxMDllPl0gaXBfbG9jYWxfZGVsaXZlcisweDdhLzB4N2YKWyAg
IDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MWEwMGU3NT5dIGlwX3Jjdl9maW5pc2grMHgzOWEv
MHg0NjEKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MWEwMTMyNj5dIGlwX3JjdisweDI4
My8weDJlMApbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxOWIyOGVmPl0gX19uZXRpZl9y
ZWNlaXZlX3NrYl9jb3JlKzB4NGNkLzB4NThlClsgICAyNC4xMjYyNDRdICBbPGZmZmZmZmZm
ODE5YjI1OGE+XSA/IF9fbmV0aWZfcmVjZWl2ZV9za2JfY29yZSsweDE2OC8weDU4ZQpbICAg
MjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxOWIyZGQ2Pl0gX19uZXRpZl9yZWNlaXZlX3NrYisw
eDFkLzB4NWYKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MTliMmU4MD5dIG5ldGlmX3Jl
Y2VpdmVfc2tiKzB4NjgvMHhmNApbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxOWIzNWRh
Pl0gbmFwaV9ncm9fcmVjZWl2ZSsweDNlLzB4ODAKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZm
ZmY4MTdiZTg3MD5dIGUxMDAwX2NsZWFuX3J4X2lycSsweDM5My8weDQxNQpbICAgMjQuMTI2
MjQ0XSAgWzxmZmZmZmZmZjgxN2JjZDQ4Pl0gZTEwMDBfY2xlYW4rMHg1OWQvMHg3MWYKWyAg
IDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MTA2MzRkMT5dID8ga3ZtX2Nsb2NrX3JlYWQrMHgy
Ny8weDMxClsgICAyNC4xMjYyNDRdICBbPGZmZmZmZmZmODEwM2VkZDA+XSA/IHNjaGVkX2Ns
b2NrKzB4OS8weGQKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MTliM2VkMD5dIG5ldF9y
eF9hY3Rpb24rMHhmNi8weDIxMApbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxMDc2MmZj
Pl0gX19kb19zb2Z0aXJxKzB4ZjMvMHgyN2EKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4
MTA3Njc3OT5dIGlycV9leGl0KzB4NTkvMHhhMApbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZm
ZjgxYWZiNDRkPl0gZG9fSVJRKzB4OWQvMHhiNApbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZm
ZjgxYWYyMWYyPl0gY29tbW9uX2ludGVycnVwdCsweDcyLzB4NzIKWyAgIDI0LjEyNjI0NF0g
IDxFT0k+ICBbPGZmZmZmZmZmODFhZjVhYjU+XSA/IF9fYXRvbWljX25vdGlmaWVyX2NhbGxf
Y2hhaW4rMHg1LzB4OWMKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MWFmNWFiNT5dID8g
X19hdG9taWNfbm90aWZpZXJfY2FsbF9jaGFpbisweDUvMHg5YwpbICAgMjQuMTI2MjQ0XSAg
WzxmZmZmZmZmZjgxMDYzNmM4Pl0gPyBuYXRpdmVfc2FmZV9oYWx0KzB4Ni8weDgKWyAgIDI0
LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MTBiMGE4OT5dID8gdHJhY2VfaGFyZGlycXNfb24rMHhk
LzB4ZgpbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxMDNmOWQxPl0gZGVmYXVsdF9pZGxl
KzB4MzgvMHhjMQpbICAgMjQuMTI2MjQ0XSAgWzxmZmZmZmZmZjgxMDQwMTU0Pl0gYXJjaF9j
cHVfaWRsZSsweDE4LzB4MjgKWyAgIDI0LjEyNjI0NF0gIFs8ZmZmZmZmZmY4MTBjMGFjNT5d
IGNwdV9zdGFydHVwX2VudHJ5KzB4MTVjLzB4MjRkClsgICAyNC4xMjYyNDRdICBbPGZmZmZm
ZmZmODEwNWExMWY+XSBzdGFydF9zZWNvbmRhcnkrMHgyNDcvMHgyNTAKWyAgIDU4LjgwMDc1
Nl0gcmFuZG9tOiBub25ibG9ja2luZyBwb29sIGlzIGluaXRpYWxpemVkClsgICA2NS4zNzYx
NzJdIE5GU0Q6IFVzaW5nIC92YXIvbGliL25mcy92NHJlY292ZXJ5IGFzIHRoZSBORlN2NCBz
dGF0ZSByZWNvdmVyeSBkaXJlY3RvcnkKWyAgIDY1LjM4MDE4OV0gTkZTRDogc3RhcnRpbmcg
OTAtc2Vjb25kIGdyYWNlIHBlcmlvZCAobmV0IGZmZmZmZmZmODIxOTZhODApCi9rZXJuZWwv
eDg2XzY0LW5mc3Jvb3QvYjFkYWYzN2ZmNTJjZjJmZjM5YjJkYjIzOTllMDUyYWQ3OTY1YzZh
YS9kbWVzZy1uZnNyb290LWF0aGVucy0xNjoyMDEzMTIxMzExMzIxMTp4ODZfNjQtbmZzcm9v
dDozLjEzLjAtcmMzLTAwNjg5LWdiMWRhZjM3Ojg5Mgova2VybmVsL3g4Nl82NC1uZnNyb290
L2IxZGFmMzdmZjUyY2YyZmYzOWIyZGIyMzk5ZTA1MmFkNzk2NWM2YWEvZG1lc2ctbmZzcm9v
dC1qYWtldG93bi0yNzoyMDEzMTIxMzExMzIwMzp4ODZfNjQtbmZzcm9vdDozLjEzLjAtcmMz
LTAwNjg5LWdiMWRhZjM3Ojg5Mgova2VybmVsL3g4Nl82NC1uZnNyb290L2IxZGFmMzdmZjUy
Y2YyZmYzOWIyZGIyMzk5ZTA1MmFkNzk2NWM2YWEvZG1lc2ctbmZzcm9vdC14aWFuLTI5OjIw
MTMxMjEzMTEzMTEzOng4Nl82NC1uZnNyb290OjMuMTMuMC1yYzMtMDA2ODktZ2IxZGFmMzc6
ODkyCi9rZXJuZWwveDg2XzY0LW5mc3Jvb3QvYjFkYWYzN2ZmNTJjZjJmZjM5YjJkYjIzOTll
MDUyYWQ3OTY1YzZhYS9kbWVzZy1uZnNyb290LWNhaXJvLTc6MjAxMzEyMTMxMTA2NTA6eDg2
XzY0LW5mc3Jvb3Q6My4xMy4wLXJjMy0wMDY4OS1nYjFkYWYzNzo4OTIKL2tlcm5lbC94ODZf
NjQtbmZzcm9vdC9iMWRhZjM3ZmY1MmNmMmZmMzliMmRiMjM5OWUwNTJhZDc5NjVjNmFhL2Rt
ZXNnLW5mc3Jvb3QtaW5uLTEyOjIwMTMxMjEzMTEwMjM5Ong4Nl82NC1uZnNyb290OjMuMTMu
MC1yYzMtMDA2ODktZ2IxZGFmMzc6ODkyCi9rZXJuZWwveDg2XzY0LW5mc3Jvb3QvYjFkYWYz
N2ZmNTJjZjJmZjM5YjJkYjIzOTllMDUyYWQ3OTY1YzZhYS9kbWVzZy1uZnNyb290LWF0aGVu
cy0zMToyMDEzMTIxMzExMzEzMTp4ODZfNjQtbmZzcm9vdDozLjEzLjAtcmMzLTAwNjg5LWdi
MWRhZjM3Ojg5Mgova2VybmVsL3g4Nl82NC1uZnNyb290L2IxZGFmMzdmZjUyY2YyZmYzOWIy
ZGIyMzk5ZTA1MmFkNzk2NWM2YWEvZG1lc2ctbmZzcm9vdC1zbmItMzA6MjAxMzEyMTMxMTE0
MTE6eDg2XzY0LW5mc3Jvb3Q6My4xMy4wLXJjMy0wMDY4OS1nYjFkYWYzNzo4OTIKL2tlcm5l
bC94ODZfNjQtbmZzcm9vdC9iMWRhZjM3ZmY1MmNmMmZmMzliMmRiMjM5OWUwNTJhZDc5NjVj
NmFhL2RtZXNnLW5mc3Jvb3QteGlhbi0yODoyMDEzMTIxMzExMzExNzp4ODZfNjQtbmZzcm9v
dDozLjEzLjAtcmMzLTAwNjg5LWdiMWRhZjM3Ojg5Mgova2VybmVsL3g4Nl82NC1uZnNyb290
L2IxZGFmMzdmZjUyY2YyZmYzOWIyZGIyMzk5ZTA1MmFkNzk2NWM2YWEvZG1lc2ctbmZzcm9v
dC1hdGhlbnMtNToyMDEzMTIxMzExMzEyMDp4ODZfNjQtbmZzcm9vdDozLjEzLjAtcmMzLTAw
Njg5LWdiMWRhZjM3Ojg5Mgova2VybmVsL3g4Nl82NC1uZnNyb290L2IxZGFmMzdmZjUyY2Yy
ZmYzOWIyZGIyMzk5ZTA1MmFkNzk2NWM2YWEvZG1lc2ctbmZzcm9vdC1zbmItMTY6MjAxMzEy
MTMxMTA3NDc6eDg2XzY0LW5mc3Jvb3Q6My4xMy4wLXJjMy0wMDY4OS1nYjFkYWYzNzo4OTIK
L2tlcm5lbC94ODZfNjQtbmZzcm9vdC9iMWRhZjM3ZmY1MmNmMmZmMzliMmRiMjM5OWUwNTJh
ZDc5NjVjNmFhL2RtZXNnLW5mc3Jvb3QtYXRoZW5zLTMwOjIwMTMxMjEzMTEzMTIyOng4Nl82
NC1uZnNyb290OjMuMTMuMC1yYzMtMDA2ODktZ2IxZGFmMzc6ODkyCi9rZXJuZWwveDg2XzY0
LW5mc3Jvb3QvYjFkYWYzN2ZmNTJjZjJmZjM5YjJkYjIzOTllMDUyYWQ3OTY1YzZhYS9kbWVz
Zy1uZnNyb290LXhpYW4tMjQ6MjAxMzEyMTMxMTExMzQ6eDg2XzY0LW5mc3Jvb3Q6My4xMy4w
LXJjMy0wMDY4OS1nYjFkYWYzNzo4OTIKL2tlcm5lbC94ODZfNjQtbmZzcm9vdC9iMWRhZjM3
ZmY1MmNmMmZmMzliMmRiMjM5OWUwNTJhZDc5NjVjNmFhL2RtZXNnLW5mc3Jvb3QteGlhbi00
OjIwMTMxMjEzMTExMTI1Ong4Nl82NC1uZnNyb290OjMuMTMuMC1yYzMtMDA2ODktZ2IxZGFm
Mzc6ODkyCi9rZXJuZWwveDg2XzY0LW5mc3Jvb3QvYjFkYWYzN2ZmNTJjZjJmZjM5YjJkYjIz
OTllMDUyYWQ3OTY1YzZhYS9kbWVzZy1uZnNyb290LWF0aGVucy0zOjIwMTMxMjEzMTEzMTE0
Ong4Nl82NC1uZnNyb290OjMuMTMuMC1yYzMtMDA2ODktZ2IxZGFmMzc6ODkyCi9rZXJuZWwv
eDg2XzY0LW5mc3Jvb3QvYjFkYWYzN2ZmNTJjZjJmZjM5YjJkYjIzOTllMDUyYWQ3OTY1YzZh
YS9kbWVzZy1uZnNyb290LWpha2V0b3duLTE3OjIwMTMxMjEzMTExMDQ5Ong4Nl82NC1uZnNy
b290OjMuMTMuMC1yYzMtMDA2ODktZ2IxZGFmMzc6ODkyCi9rZXJuZWwveDg2XzY0LW5mc3Jv
b3QvYjFkYWYzN2ZmNTJjZjJmZjM5YjJkYjIzOTllMDUyYWQ3OTY1YzZhYS9kbWVzZy1uZnNy
b290LWNhaXJvLTc6MjAxMzEyMTMxMTMxMDU6eDg2XzY0LW5mc3Jvb3Q6My4xMy4wLXJjMy0w
MDY4OS1nYjFkYWYzNzo4OTIKL2tlcm5lbC94ODZfNjQtbmZzcm9vdC9iMWRhZjM3ZmY1MmNm
MmZmMzliMmRiMjM5OWUwNTJhZDc5NjVjNmFhL2RtZXNnLW5mc3Jvb3QtamFrZXRvd24tMTE6
MjAxMzEyMTMxMTEzNTE6eDg2XzY0LW5mc3Jvb3Q6My4xMy4wLXJjMy0wMDY4OS1nYjFkYWYz
Nzo4OTIKL2tlcm5lbC94ODZfNjQtbmZzcm9vdC9iMWRhZjM3ZmY1MmNmMmZmMzliMmRiMjM5
OWUwNTJhZDc5NjVjNmFhL2RtZXNnLW5mc3Jvb3QtYXRoZW5zLTE3OjIwMTMxMjEzMTEzMjA3
Ong4Nl82NC1uZnNyb290OjMuMTMuMC1yYzMtMDA2ODktZ2IxZGFmMzc6ODkyCi9rZXJuZWwv
eDg2XzY0LW5mc3Jvb3QvYjFkYWYzN2ZmNTJjZjJmZjM5YjJkYjIzOTllMDUyYWQ3OTY1YzZh
YS9kbWVzZy1uZnNyb290LWlubi0yODoyMDEzMTIxMzExMDMxMDp4ODZfNjQtbmZzcm9vdDoz
LjEzLjAtcmMzLTAwNjg5LWdiMWRhZjM3Ojg5MgowOjE5OjE5IGFsbF9nb29kOmJhZDphbGxf
YmFkIGJvb3RzCgpbZGV0YWNoZWQgSEVBRCAyY2Q2YTM3XSBSZXZlcnQgInVkcDogaXB2NDog
bXVzdCBhZGQgc3luY2hyb25pemF0aW9uIGluIHVkcF9za19yeF9kc3Rfc2V0KCkiCiAxIGZp
bGUgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCspLCAxNiBkZWxldGlvbnMoLSkKbHMgLWEgL2tl
cm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1uZnNyb290L2xpbnV4LWRldmVsOmRl
dmVsLXhpYW4teDg2XzY0LTIwMTMxMjEzMTA1MjoyY2Q2YTM3YTY1ZjU3OGY3ZTIzZTY3OTg2
MTA3NDIyYWQzYzAxMmJhOmJpc2VjdC1tbQoKMjAxMy0xMi0xMy0xNDo0NjoyNiAyY2Q2YTM3
YTY1ZjU3OGY3ZTIzZTY3OTg2MTA3NDIyYWQzYzAxMmJhIGNvbXBpbGluZwoKMjAxMy0xMi0x
My0xNTowMDozMSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEzLjAtcmMzLTAxMzI2LWcyY2Q2
YTM3Li4uLi4uLi4uLi4JMi4uLi4JMwk0Li4JNgk3LgkxMAkxNQkyMAkyMgkyNC4JMjcJMjgJ
MjkJMzMJMzUJMzcuLgkzOAk0MC4uLi4JNzIJNzUgU1VDQ0VTUwoKCj09PT09PT09PSB1cHN0
cmVhbSA9PT09PT09PT0KRmV0Y2hpbmcgbGludXMKRmV0Y2hpbmcgbGludXMKbHMgLWEgL2tl
cm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1uZnNyb290L2xpbnV4LWRldmVsOmRl
dmVsLXhpYW4teDg2XzY0LTIwMTMxMjEzMTA1Mjo4YWU1MTZhYThiODE2MTI1NGQzZTQwMmIz
MzQ4YjJhOWI4ZDFlZmQwOmJpc2VjdC1tbQoKMjAxMy0xMi0xMy0xNToyMzo1MiA4YWU1MTZh
YThiODE2MTI1NGQzZTQwMmIzMzQ4YjJhOWI4ZDFlZmQwIGNvbXBpbGluZwoKMjAxMy0xMi0x
My0xNTozNzo0OSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEzLjAtcmMxLTAwMTQxLWc4YWU1
MTZhLi4uLi4uCTEJNC4JNgkxMQkxMgkxNAkxNgkxOC4JMjAuLgkyNQkyOQkzMC4JMzIJMzQu
CTM5CTQ3CTU0CTU5CTY4CTcxCTc0CTc1IFNVQ0NFU1MKCgo9PT09PT09PT0gbGludXgtbmV4
dCA9PT09PT09PT0KRmV0Y2hpbmcgbmV4dApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1
ZS9rdm0veDg2XzY0LW5mc3Jvb3QvbGludXgtZGV2ZWw6ZGV2ZWwteGlhbi14ODZfNjQtMjAx
MzEyMTMxMDUyOjFhNjNkNTc3N2QyMzc5NTJiYjA2ZjFhMjQ4MWMzYWNjMzY2YWViOGQ6Ymlz
ZWN0LW1tCiBURVNUIEZBSUxVUkUKWyAgICAyLjQ0NzI5M10gdHNjOiBSZWZpbmVkIFRTQyBj
bG9ja3NvdXJjZSBjYWxpYnJhdGlvbjogMjg5Mi45ODIgTUh6ClsgICAgMi40NTAzMjFdIHZp
cnRpby1wY2kgMDAwMDowMDowNC4wOiBpcnEgNDAgZm9yIE1TSS9NU0ktWApbICAgIDIuNDUx
NjQ5XSB2aXJ0aW8tcGNpIDAwMDA6MDA6MDQuMDogaXJxIDQxIGZvciBNU0kvTVNJLVgKWyAg
ICAyLjQ1MzA0OF0gQlVHOiBrZXkgZmZmZjg4MDAxOTJlNmFkMCBub3QgaW4gLmRhdGEhClsg
ICAgMi40NTQyMjNdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQova2Vy
bmVsL3g4Nl82NC1uZnNyb290LzFhNjNkNTc3N2QyMzc5NTJiYjA2ZjFhMjQ4MWMzYWNjMzY2
YWViOGQvZG1lc2ctbmZzcm9vdC1sa3AtdHQwMi0xNjoyMDEzMTIxMzE0Mjk0NTp4ODZfNjQt
bmZzcm9vdDozLjEzLjAtcmMzLW5leHQtMjAxMzEyMTMtMDQ0OTktZzFhNjNkNTc6MwowOjE6
OSBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwobWzE7MzVtUkVQRUFUIENPVU5UOiAxMDAg
ICMgL2NjL3dmZy9tbS1iaXNlY3QvLnJlcGVhdBtbMG0KCg==

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.13.0-rc3-00689-gb1daf37"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.13.0-rc3 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_FHANDLE is not set
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ_FULL is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_TREE_RCU_TRACE=y
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=18
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_NUMA_BALANCING is not set
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
CONFIG_DEBUG_BLK_CGROUP=y
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
# CONFIG_UIDGID_STRICT_TYPE_CHECKS is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
# CONFIG_CPU_SUP_AMD is not set
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=64
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
# CONFIG_KEXEC_JUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_EC_DEBUGFS=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_SBS=y
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
CONFIG_X86_ACPI_CPUFREQ=y
# CONFIG_X86_POWERNOW_K8 is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
# CONFIG_PCIEASPM is not set
CONFIG_PCIE_PME=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
# CONFIG_PCCARD is not set
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
# CONFIG_NETFILTER_NETLINK_ACCT is not set
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
# CONFIG_NF_CONNTRACK_TIMESTAMP is not set
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
# CONFIG_NF_CONNTRACK_SNMP is not set
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_QUEUE_CT is not set
# CONFIG_NF_TABLES is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_AUDIT is not set
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LED=y
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
# CONFIG_NETFILTER_XT_MATCH_BPF is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
# CONFIG_NETFILTER_XT_MATCH_CONNLABEL is not set
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
# CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
# CONFIG_IP_SET is not set
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
# CONFIG_IP_NF_MATCH_RPFILTER is not set
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
# CONFIG_IP_NF_TARGET_SYNPROXY is not set
CONFIG_IP_NF_TARGET_ULOG=y
# CONFIG_NF_NAT_IPV4 is not set
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_CLUSTERIP=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# IPv6: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV6 is not set
# CONFIG_NF_CONNTRACK_IPV6 is not set
# CONFIG_IP6_NF_IPTABLES is not set
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE_EBT_BROUTE=y
CONFIG_BRIDGE_EBT_T_FILTER=y
CONFIG_BRIDGE_EBT_T_NAT=y
CONFIG_BRIDGE_EBT_802_3=y
CONFIG_BRIDGE_EBT_AMONG=y
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
# CONFIG_BRIDGE_EBT_IP6 is not set
CONFIG_BRIDGE_EBT_LIMIT=y
CONFIG_BRIDGE_EBT_MARK=y
CONFIG_BRIDGE_EBT_PKTTYPE=y
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
CONFIG_BRIDGE_EBT_ARPREPLY=y
CONFIG_BRIDGE_EBT_DNAT=y
CONFIG_BRIDGE_EBT_MARK_T=y
CONFIG_BRIDGE_EBT_REDIRECT=y
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
CONFIG_BRIDGE_EBT_ULOG=y
CONFIG_BRIDGE_EBT_NFLOG=y
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
# CONFIG_NET_SCH_CBQ is not set
# CONFIG_NET_SCH_HTB is not set
# CONFIG_NET_SCH_HFSC is not set
# CONFIG_NET_SCH_PRIO is not set
# CONFIG_NET_SCH_MULTIQ is not set
# CONFIG_NET_SCH_RED is not set
# CONFIG_NET_SCH_SFB is not set
# CONFIG_NET_SCH_SFQ is not set
# CONFIG_NET_SCH_TEQL is not set
# CONFIG_NET_SCH_TBF is not set
# CONFIG_NET_SCH_GRED is not set
# CONFIG_NET_SCH_DSMARK is not set
CONFIG_NET_SCH_NETEM=y
# CONFIG_NET_SCH_DRR is not set
# CONFIG_NET_SCH_MQPRIO is not set
# CONFIG_NET_SCH_CHOKE is not set
# CONFIG_NET_SCH_QFQ is not set
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
# CONFIG_NET_SCH_FQ is not set
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
# CONFIG_NET_CLS_BASIC is not set
# CONFIG_NET_CLS_TCINDEX is not set
# CONFIG_NET_CLS_ROUTE4 is not set
# CONFIG_NET_CLS_FW is not set
# CONFIG_NET_CLS_U32 is not set
# CONFIG_NET_CLS_RSVP is not set
# CONFIG_NET_CLS_RSVP6 is not set
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_CLS_CGROUP is not set
# CONFIG_NET_CLS_BPF is not set
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_TCPPROBE is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
CONFIG_BLK_DEV_FD=y
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=128
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ATMEL_SSC is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Host Driver
#
# CONFIG_INTEL_MIC_HOST is not set

#
# Intel MIC Card Driver
#
# CONFIG_INTEL_MIC_CARD is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
# CONFIG_IDE_GD_ATAPI is not set
# CONFIG_BLK_DEV_IDECD is not set
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=y
CONFIG_AIC94XX_DEBUG=y
CONFIG_SCSI_MVSAS=y
CONFIG_SCSI_MVSAS_DEBUG=y
# CONFIG_SCSI_MVSAS_TASKLET is not set
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_GDTH=y
CONFIG_SCSI_ISCI=y
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
# CONFIG_SATA_HIGHBANK is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_RCAR is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARASAN_CF is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PLATFORM=y
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM=y
CONFIG_DM_DEBUG=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
# CONFIG_DM_CACHE is not set
CONFIG_DM_MIRROR=y
CONFIG_DM_LOG_USERSPACE=y
# CONFIG_DM_RAID is not set
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
# CONFIG_DM_VERITY is not set
# CONFIG_DM_SWITCH is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
CONFIG_DUMMY=y
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=y
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
# CONFIG_ALX is not set
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
# CONFIG_BNX2X is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
# CONFIG_DE2104X is not set
# CONFIG_TULIP is not set
# CONFIG_DE4X5 is not set
# CONFIG_WINBOND_840 is not set
# CONFIG_DM9102 is not set
# CONFIG_ULI526X is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGB_DCA=y
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
CONFIG_IP1000=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
CONFIG_SKGE=y
# CONFIG_SKGE_DEBUG is not set
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
# CONFIG_SKY2_DEBUG is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_NE2K_PCI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_PCH_GBE=y
# CONFIG_ETHOC is not set
# CONFIG_NET_PACKET_ENGINE is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
CONFIG_R8169=y
# CONFIG_SH_ETH is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
CONFIG_SIS190=y
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_ICPLUS_PHY=y
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
# CONFIG_USB_NET_CDC_MBIM is not set
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
# CONFIG_USB_NET_CX82310_ETH is not set
# CONFIG_USB_NET_KALMIA is not set
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_NET_INT51X1=y
# CONFIG_USB_IPHETH is not set
# CONFIG_USB_SIERRA_NET is not set
# CONFIG_USB_VL600 is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_UINPUT=y
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
# CONFIG_INPUT_CMA3000 is not set
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=16
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HPET_MMAP_DEFAULT=y
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_HTU21 is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
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
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_X86_PKG_TEMP_THERMAL=m

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
# CONFIG_SC520_WDT is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83697UG_WDT is not set
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
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
CONFIG_LPC_ICH=y
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_INTEL=y
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I2C_NXP_TDA998X is not set
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_I915_FBDEV=y
# CONFIG_DRM_I915_PRELIMINARY_HW_SUPPORT is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_EFI is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_TMIO is not set
# CONFIG_FB_SMSCUFX is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_GOLDFISH is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=1024
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
# CONFIG_LOGO is not set
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
CONFIG_SND_PCM_XRUN_DEBUG=y
CONFIG_SND_VMASTER=y
CONFIG_SND_KCTL_JACK=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_ALOOP is not set
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
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
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_CTXFI is not set
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
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
CONFIG_SND_HDA_PATCH_LOADER=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CA0132=y
# CONFIG_SND_HDA_CODEC_CA0132_DSP is not set
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
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
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
# CONFIG_SND_USB is not set
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_HUION is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SONY is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FUSBH200_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_ONETOUCH=y
CONFIG_USB_STORAGE_KARMA=y
CONFIG_USB_STORAGE_CYPRESS_ATACB=y
# CONFIG_USB_STORAGE_ENE_UB6250 is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
CONFIG_USB_SERIAL_BELKIN=y
# CONFIG_USB_SERIAL_CH341 is not set
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_CP210X is not set
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
# CONFIG_USB_SERIAL_EMPEG is not set
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_F81232 is not set
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
# CONFIG_USB_SERIAL_IUU is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
CONFIG_USB_SERIAL_MCT_U232=y
# CONFIG_USB_SERIAL_METRO is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
# CONFIG_USB_SERIAL_PL2303 is not set
# CONFIG_USB_SERIAL_OTI6858 is not set
# CONFIG_USB_SERIAL_QCAUX is not set
# CONFIG_USB_SERIAL_QUALCOMM is not set
# CONFIG_USB_SERIAL_SPCP8X5 is not set
# CONFIG_USB_SERIAL_SAFE is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_SYMBOL is not set
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
# CONFIG_USB_SERIAL_OPTICON is not set
# CONFIG_USB_SERIAL_XSENS_MT is not set
# CONFIG_USB_SERIAL_WISHBONE is not set
# CONFIG_USB_SERIAL_ZTE is not set
# CONFIG_USB_SERIAL_SSU100 is not set
# CONFIG_USB_SERIAL_QT2 is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_RCAR_PHY is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_LP3944 is not set
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_PCA9685 is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_DELL_NETBOOKS is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
# CONFIG_LEDS_TRIGGER_IDE_DISK is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_DS2404 is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
# CONFIG_DW_DMAC_CORE is not set
# CONFIG_DW_DMAC is not set
# CONFIG_DW_DMAC_PCI is not set
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
# CONFIG_NET_DMA is not set
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
# CONFIG_UIO_DMEM_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_WMI=y
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WMI=y
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_THINKPAD_ACPI=y
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=y
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_MXM_WMI is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
# CONFIG_GENERIC_PHY is not set
# CONFIG_PHY_EXYNOS_MIPI_VIDEO is not set
# CONFIG_POWERCAP is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
# CONFIG_EFI_VARS is not set
# CONFIG_UEFI_CPER is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT23=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
# CONFIG_EXT4_FS_SECURITY is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_PSTORE is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_F2FS_FS is not set
# CONFIG_EFIVAR_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
CONFIG_CIFS_STATS=y
CONFIG_CIFS_STATS2=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_ACL is not set
CONFIG_CIFS_DEBUG=y
CONFIG_CIFS_DEBUG2=y
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB2 is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_SLUB_DEBUG_ON=y
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_RCU_CPU_STALL_INFO=y
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
CONFIG_FAIL_MAKE_REQUEST=y
# CONFIG_FAIL_IO_TIMEOUT is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
# CONFIG_UPROBE_EVENT is not set
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
CONFIG_MMIOTRACE_TEST=m
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
CONFIG_TEST_LIST_SORT=y
CONFIG_KPROBES_SANITY_TEST=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_DMA_API_DEBUG=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_EARLY_PRINTK_EFI is not set
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DEBUG_SET_MODULE_RONX is not set
CONFIG_DEBUG_NX_TEST=m
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=y
# CONFIG_CRYPTO_TEST is not set

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_X86_64 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAST6 is not set
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
# CONFIG_KVM_AMD is not set
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
# CONFIG_CPUMASK_OFFSTACK is not set
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--PEIAKu/WMn1b1Hv9--
