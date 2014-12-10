From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net: sock] BUG: unable to handle kernel NULL pointer dereference at
 0000000000000007
Date: Wed, 10 Dec 2014 15:29:11 -0800
Message-ID: <20141210232911.GE24163@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nHwqXXcoX0o6fKCv"
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nHwqXXcoX0o6fKCv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
commit 89aa075832b0da4402acebd698d0411dcc82d03e
Author:     Alexei Starovoitov <ast@plumgrid.com>
AuthorDate: Mon Dec 1 15:06:35 2014 -0800
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Fri Dec 5 21:47:32 2014 -0800

    net: sock: allow eBPF programs to be attached to sockets
    
    introduce new setsockopt() command:
    
    setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &prog_fd, sizeof(prog_fd))
    
    where prog_fd was received from syscall bpf(BPF_PROG_LOAD, attr, ...)
    and attr->prog_type == BPF_PROG_TYPE_SOCKET_FILTER
    
    setsockopt() calls bpf_prog_get() which increments refcnt of the program,
    so it doesn't get unloaded while socket is using the program.
    
    The same eBPF program can be attached to multiple sockets.
    
    User task exit automatically closes socket which calls sk_filter_uncharge()
    which decrements refcnt of eBPF program
    
    Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

+------------------------------------------+------------+------------+------------+
|                                          | ddd872bc30 | 89aa075832 | 6c702fab62 |
+------------------------------------------+------------+------------+------------+
| boot_successes                           | 900        | 292        | 20         |
| boot_failures                            | 0          | 8          | 2          |
| BUG:unable_to_handle_kernel              | 0          | 8          | 2          |
| Oops                                     | 0          | 8          | 2          |
| RIP:sk_attach_bpf                        | 0          | 8          | 2          |
| Kernel_panic-not_syncing:Fatal_exception | 0          | 8          | 2          |
| backtrace:sock_setsockopt                | 0          | 8          | 2          |
| backtrace:SyS_setsockopt                 | 0          | 8          | 2          |
+------------------------------------------+------------+------------+------------+

[init] Kernel was tainted on startup. Will ignore flags that are already set.
[init] Started watchdog process, PID is 9354
[main] Main thread is alive.
[   21.233581] BUG: unable to handle kernel NULL pointer dereference at 0000000000000007
[   21.234709] IP: [<ffffffff8156ebda>] sk_attach_bpf+0x39/0xc2
[   21.235503] PGD b12c067 PUD b12d067 PMD 0 
[   21.236124] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   21.236902] Modules linked in:
[   21.237347] CPU: 1 PID: 318 Comm: trinity-main Not tainted 3.18.0-rc6-g89aa075 #214
[   21.238371] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   21.239146] task: ffff8800001e0000 ti: ffff8800001e4000 task.ti: ffff8800001e4000
[   21.240145] RIP: 0010:[<ffffffff8156ebda>]  [<ffffffff8156ebda>] sk_attach_bpf+0x39/0xc2
[   21.241252] RSP: 0018:ffff8800001e7ea8  EFLAGS: 00010282
[   21.241970] RAX: 00000000ffffffea RBX: ffff88000af305c0 RCX: 0000000000000000
[   21.242107] RDX: 0000000000000000 RSI: 0000000000004000 RDI: 0000000000000000
[   21.242107] RBP: ffff8800001e7ec8 R08: 0000000000003601 R09: 0000000000000209
[   21.242107] R10: 0000000000000000 R11: 0000000000000206 R12: 00000000fffffff2
[   21.242107] R13: fffffffffffffff7 R14: 0000000000000c01 R15: 0000000000000004
[   21.242107] FS:  00007f035d5ed700(0000) GS:ffff880012500000(0000) knlGS:0000000000000000
[   21.242107] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   21.242107] CR2: 0000000000000007 CR3: 000000000b141000 CR4: 00000000000406e0
[   21.242107] Stack:
[   21.242107]  0000000000000000 ffff88000af305c0 00000000fffffff2 0000000000000c01
[   21.242107]  ffff8800001e7f28 ffffffff8154cca3 00000032011e7ef8 00000000008a3000
[   21.242107]  ffff880000000c01 ffff8800001e0000 ffff8800001e7f38 ffff88000b7bb780
[   21.242107] Call Trace:
[   21.242107]  [<ffffffff8154cca3>] sock_setsockopt+0x447/0x5ef
[   21.242107]  [<ffffffff81548dfd>] SyS_setsockopt+0x61/0x94
[   21.242107]  [<ffffffff8158ed69>] system_call_fastpath+0x12/0x17
[   21.242107] Code: 40 00 0f 85 ab 00 00 00 55 48 89 e5 41 55 41 54 53 51 48 89 f3 e8 bf 82 b7 ff 49 89 c5 b8 ea ff ff ff 4d 85 ed 0f 84 81 00 00 00 <49> 8b 45 10 83 78 08 01 74 0f 4c 89 ef e8 60 82 b7 ff b8 ea ff 
[   21.242107] RIP  [<ffffffff8156ebda>] sk_attach_bpf+0x39/0xc2
[   21.242107]  RSP <ffff8800001e7ea8>
[   21.242107] CR2: 0000000000000007
[   21.292711] ---[ end trace 5196e3a283419924 ]---
[   21.293361] Kernel panic - not syncing: Fatal exception

git bisect start 6c702fab626328c33b539b0c618a5511aed23bed 61ed53deb1c6a4386d8710dbbfcee8779c381931 --
git bisect good d7990b0c34623cd54475a0562c607efbaba4899d  # 18:30     75+      0  cxgb4i/cxgb4 : Refactor macros to conform to uniform standards
git bisect good 8b7f8a99906fc21c287ad63ad3a89cf662b0293e  # 18:53     75+      0  Merge branch 'tipc-next'
git bisect  bad 7ee813653e34209a148d928c81d4495dff3a879f  # 19:09      0-      3  Merge branch 'cxgb4-next'
git bisect  bad 60c04aecd8a72a84869308bdf2289a7aabb9a88c  # 19:13     11-      1  udp: Neaten and reduce size of compute_score functions
git bisect good 244ebd9f8fa8beb7b37bdeebd6c5308b61f98aef  # 19:29    130+      0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
git bisect good f51a5e82ea9aaf05106c00d976e772ca384a9199  # 19:42    130+      0  tun/macvtap: use consume_skb() instead of kfree_skb() when needed
git bisect  bad 6867b17b26d80cfd419e491141feb75082915979  # 20:10      0-      1  test: bpf: expand DIV_KX to DIV_MOD_KX
git bisect  bad 8d0c4697534a739725e429ff062dea393d8860d1  # 20:22      1-      2  Merge branch 'ebpf-next'
git bisect  bad 03f4723ed7a52bd31da26eefe2cdde563ea0f468  # 20:35     66-      1  samples: bpf: example of stateful socket filtering
git bisect  bad 89aa075832b0da4402acebd698d0411dcc82d03e  # 20:47      0-      1  net: sock: allow eBPF programs to be attached to sockets
git bisect good ddd872bc3098f9d9abe1680a6b2013e59e3337f7  # 21:11    300+      0  bpf: verifier: add checks for BPF_ABS | BPF_IND instructions
# first bad commit: [89aa075832b0da4402acebd698d0411dcc82d03e] net: sock: allow eBPF programs to be attached to sockets
git bisect good ddd872bc3098f9d9abe1680a6b2013e59e3337f7  # 21:41    900+      0  bpf: verifier: add checks for BPF_ABS | BPF_IND instructions
# extra tests on HEAD of netdev-next/master
git bisect  bad 6c702fab626328c33b539b0c618a5511aed23bed  # 21:41      0-      2  dummy: use MODULE_VERSION
# extra tests on tree/branch next/master
git bisect  bad 12fd07251e19050ca979d9ce5d4b6bcb41dc00e9  # 21:45      0-      2  Add linux-next specific files for 20141210
# extra tests on tree/branch linus/master
git bisect good 86c6a2fddf0b89b494c7616f2c06cf915c4bff01  # 22:25    900+      0  Merge branch 'sched-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
# extra tests on tree/branch next/master
git bisect  bad 12fd07251e19050ca979d9ce5d4b6bcb41dc00e9  # 22:25      0-     17  Add linux-next specific files for 20141210


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 320
	-smp 2
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--nHwqXXcoX0o6fKCv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-kbuild-2:20141210205228:x86_64-randconfig-s0-12101616:3.18.0-rc6-g89aa075:214"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.18.0-rc6-g89aa075 (kbuild@snb) (gcc version =
4.9.1 (Debian 4.9.1-19) ) #214 SMP PREEMPT Wed Dec 10 20:45:38 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_r=
amdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randco=
nfig-s0-12101616/netdev-next:master:89aa075832b0da4402acebd698d0411dcc82d03=
e:bisect-linux-8/.vmlinuz-89aa075832b0da4402acebd698d0411dcc82d03e-20141210=
204605-64-kbuild branch=3Dnetdev-next/master BOOT_IMAGE=3D/kernel/x86_64-ra=
ndconfig-s0-12101616/89aa075832b0da4402acebd698d0411dcc82d03e/vmlinuz-3.18.=
0-rc6-g89aa075 drbd.minor_count=3D8
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
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
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x400000000
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0284f000, 0x0284ffff] PGTABLE
[    0.000000] BRK [0x02850000, 0x02850fff] PGTABLE
[    0.000000] BRK [0x02851000, 0x02851fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x02852000, 0x02852fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x125fffff]
[    0.000000]  [mem 0x10000000-0x125fffff] page 4k
[    0.000000] BRK [0x02853000, 0x02853fff] PGTABLE
[    0.000000] BRK [0x02854000, 0x02854fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13ffdfff]
[    0.000000]  [mem 0x12800000-0x13ffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x1293d000-0x13feffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FFE450 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FFE490 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x0000000013FFFF40 000040
[    0.000000] ACPI: SSDT 0x0000000013FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FFF680 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FFF640 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:128bd001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00001000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77822 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffffffff57c000 (fec00000)
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:2 nr_cpu_ids:2 nr=
_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff880012400000 s74432 r8192=
 d32064 u1048576
[    0.000000] pcpu-alloc: s74432 r8192 d32064 u1048576 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1240c000
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80519
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64=
-randconfig-s0-12101616/netdev-next:master:89aa075832b0da4402acebd698d0411d=
cc82d03e:bisect-linux-8/.vmlinuz-89aa075832b0da4402acebd698d0411dcc82d03e-2=
0141210204605-64-kbuild branch=3Dnetdev-next/master BOOT_IMAGE=3D/kernel/x8=
6_64-randconfig-s0-12101616/89aa075832b0da4402acebd698d0411dcc82d03e/vmlinu=
z-3.18.0-rc6-g89aa075 drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340 using standar=
d form
[    0.000000] Memory: 270152K/327280K available (5705K kernel code, 1264K =
rwdata, 2520K rodata, 968K init, 12388K bss, 57128K reserved)
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:524544 nr_irqs:440 0
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.18.0-rc6-g89aa075 (kbuild@snb) (gcc version =
4.9.1 (Debian 4.9.1-19) ) #214 SMP PREEMPT Wed Dec 10 20:45:38 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_r=
amdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randco=
nfig-s0-12101616/netdev-next:master:89aa075832b0da4402acebd698d0411dcc82d03=
e:bisect-linux-8/.vmlinuz-89aa075832b0da4402acebd698d0411dcc82d03e-20141210=
204605-64-kbuild branch=3Dnetdev-next/master BOOT_IMAGE=3D/kernel/x86_64-ra=
ndconfig-s0-12101616/89aa075832b0da4402acebd698d0411dcc82d03e/vmlinuz-3.18.=
0-rc6-g89aa075 drbd.minor_count=3D8
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
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
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x400000000
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0284f000, 0x0284ffff] PGTABLE
[    0.000000] BRK [0x02850000, 0x02850fff] PGTABLE
[    0.000000] BRK [0x02851000, 0x02851fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x02852000, 0x02852fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x125fffff]
[    0.000000]  [mem 0x10000000-0x125fffff] page 4k
[    0.000000] BRK [0x02853000, 0x02853fff] PGTABLE
[    0.000000] BRK [0x02854000, 0x02854fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13ffdfff]
[    0.000000]  [mem 0x12800000-0x13ffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x1293d000-0x13feffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FFE450 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FFE490 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x0000000013FFFF40 000040
[    0.000000] ACPI: SSDT 0x0000000013FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FFF680 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FFF640 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:128bd001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00001000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77822 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffffffff57c000 (fec00000)
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:2 nr_cpu_ids:2 nr=
_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff880012400000 s74432 r8192=
 d32064 u1048576
[    0.000000] pcpu-alloc: s74432 r8192 d32064 u1048576 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1240c000
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80519
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64=
-randconfig-s0-12101616/netdev-next:master:89aa075832b0da4402acebd698d0411d=
cc82d03e:bisect-linux-8/.vmlinuz-89aa075832b0da4402acebd698d0411dcc82d03e-2=
0141210204605-64-kbuild branch=3Dnetdev-next/master BOOT_IMAGE=3D/kernel/x8=
6_64-randconfig-s0-12101616/89aa075832b0da4402acebd698d0411dcc82d03e/vmlinu=
z-3.18.0-rc6-g89aa075 drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340 using standar=
d form
[    0.000000] Memory: 270152K/327280K available (5705K kernel code, 1264K =
rwdata, 2520K rodata, 968K init, 12388K bss, 57128K reserved)
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:524544 nr_irqs:440 0
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8127 kB
[    0.000000]  memory used by lock dependency info: 8127 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] allocated 1572864 bytes of page_cgroup
[    0.000000] allocated 1572864 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] ODEBUG: selftest passed
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.528 MHz processor
[    0.000000] tsc: Detected 2693.528 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value..=20
[    0.020000] Calibrating delay loop (skipped) preset value.. 5387.05 Bogo=
MIPS (lpj=3D26935280)
5387.05 BogoMIPS (lpj=3D26935280)
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] ACPI: Core revision 20140926
[    0.020000] ACPI: Core revision 20140926
[    0.022175] ACPI:=20
[    0.022175] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.024004] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.024004] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.026127] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.026127] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.029010] Initializing cgroup subsys memory
[    0.029010] Initializing cgroup subsys memory
[    0.030042] Initializing cgroup subsys hugetlb
[    0.030042] Initializing cgroup subsys hugetlb
[    0.031586] mce: CPU supports 10 MCE banks
[    0.031586] mce: CPU supports 10 MCE banks
[    0.032842] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.032842] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.032842] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.032842] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.036735] debug: unmapping init [mem 0xffffffff81c30000-0xffffffff81c3=
4fff]
[    0.036735] debug: unmapping init [mem 0xffffffff81c30000-0xffffffff81c3=
4fff]
[    0.043305] Getting VERSION: 1050014
[    0.043305] Getting VERSION: 1050014
[    0.044557] Getting VERSION: 1050014
[    0.044557] Getting VERSION: 1050014
[    0.045693] Getting ID: 0
[    0.045693] Getting ID: 0
[    0.050020] Getting ID: ff000000
[    0.050020] Getting ID: ff000000
[    0.060020] Getting LVT0: 8700
[    0.060020] Getting LVT0: 8700
[    0.061005] Getting LVT1: 8400
[    0.061005] Getting LVT1: 8400
[    0.062070] enabled ExtINT on CPU#0
[    0.062070] enabled ExtINT on CPU#0
[    0.064512] ENABLING IO-APIC IRQs
[    0.064512] ENABLING IO-APIC IRQs
[    0.065441] init IO_APIC IRQs
[    0.065441] init IO_APIC IRQs
[    0.066558]  apic 0 pin 0 not connected
[    0.066558]  apic 0 pin 0 not connected
[    0.067677] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.067677] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.070051] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.070051] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.072547] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.072547] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.075001] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.075001] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.077586] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.077586] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.080039] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.080039] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.082632] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.082632] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.085177] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.085177] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.087605] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.087605] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.090040] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.090040] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.092613] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.092613] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.094941] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.094941] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.097243] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.097243] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.100034] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.100034] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.102359] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.102359] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.104733] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.104733] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.107189]  apic 0 pin 16 not connected
[    0.107189]  apic 0 pin 16 not connected
[    0.108255]  apic 0 pin 17 not connected
[    0.108255]  apic 0 pin 17 not connected
[    0.110011]  apic 0 pin 18 not connected
[    0.110011]  apic 0 pin 18 not connected
[    0.111125]  apic 0 pin 19 not connected
[    0.111125]  apic 0 pin 19 not connected
[    0.112362]  apic 0 pin 20 not connected
[    0.112362]  apic 0 pin 20 not connected
[    0.113539]  apic 0 pin 21 not connected
[    0.113539]  apic 0 pin 21 not connected
[    0.114614]  apic 0 pin 22 not connected
[    0.114614]  apic 0 pin 22 not connected
[    0.115798]  apic 0 pin 23 not connected
[    0.115798]  apic 0 pin 23 not connected
[    0.119261] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.119261] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.120014] smpboot: CPU0:=20
[    0.120014] smpboot: CPU0: Intel Core Processor (Haswell)Intel Core Proc=
essor (Haswell) (fam: 06, model: 3c (fam: 06, model: 3c, stepping: 01)
, stepping: 01)
[    0.122520] TSC deadline timer enabled
[    0.122520] TSC deadline timer enabled
[    0.123598] Performance Events:=20
[    0.123598] Performance Events: unsupported p6 CPU model 60 unsupported =
p6 CPU model 60 no PMU driver, software events only.
no PMU driver, software events only.
[    0.180413] x86: Booting SMP configuration:
[    0.180413] x86: Booting SMP configuration:
[    0.181690] .... node  #0, CPUs: =20
[    0.181690] .... node  #0, CPUs:         #1 #1
[    0.160155] kvm-clock: cpu 1, msr 0:128bd041, secondary cpu clock
[    0.160155] masked ExtINT on CPU#1
[    0.210164] x86: Booted up 1 node, 2 CPUs
[    0.210164] x86: Booted up 1 node, 2 CPUs
[    0.211487] ----------------
[    0.211487] ----------------
[    0.212268] | NMI testsuite:
[    0.212268] | NMI testsuite:
[    0.213097] --------------------
[    0.213097] --------------------
[    0.214019]   remote IPI:
[    0.214019]   remote IPI:

[    0.210074] KVM setup async PF for cpu 1
[    0.210074] KVM setup async PF for cpu 1
[    0.211163] kvm-stealtime: cpu 1, msr 1250c000
[    0.211163] kvm-stealtime: cpu 1, msr 1250c000
[    0.230050]   ok  |
[    0.230050]   ok  |

[    0.230724]    local IPI:
[    0.230724]    local IPI:  ok  |  ok  |

[    0.250038] --------------------
[    0.250038] --------------------
[    0.251053] Good, all   2 testcases passed! |
[    0.251053] Good, all   2 testcases passed! |
[    0.252333] ---------------------------------
[    0.252333] ---------------------------------
[    0.253500] smpboot: Total of 2 processors activated (10774.11 BogoMIPS)
[    0.253500] smpboot: Total of 2 processors activated (10774.11 BogoMIPS)
[    0.260241] devtmpfs: initialized
[    0.260241] devtmpfs: initialized
[    0.270754] xor: automatically using best checksumming function:
[    0.270754] xor: automatically using best checksumming function:
[    0.370026]    avx       : 13515.200 MB/sec
[    0.370026]    avx       : 13515.200 MB/sec
[    0.371291] prandom: seed boundary self test passed
[    0.371291] prandom: seed boundary self test passed
[    0.373443] prandom: 100 self tests passed
[    0.373443] prandom: 100 self tests passed
[    0.374582] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    0.374582] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    0.377328] regulator-dummy: no parameters
[    0.377328] regulator-dummy: no parameters
[    0.378713] RTC time: 20:51:59, date: 12/10/14
[    0.378713] RTC time: 20:51:59, date: 12/10/14
[    0.390265] NET: Registered protocol family 16
[    0.390265] NET: Registered protocol family 16
[    0.410028] cpuidle: using governor ladder
[    0.410028] cpuidle: using governor ladder
[    0.440026] cpuidle: using governor menu
[    0.440026] cpuidle: using governor menu
[    0.441548] ACPI: bus type PCI registered
[    0.441548] ACPI: bus type PCI registered
[    0.442760] PCI: Using configuration type 1 for base access
[    0.442760] PCI: Using configuration type 1 for base access
[    0.655341] raid6: sse2x1    2641 MB/s
[    0.655341] raid6: sse2x1    2641 MB/s
[    0.830022] raid6: sse2x2    3245 MB/s
[    0.830022] raid6: sse2x2    3245 MB/s
[    0.994999] raid6: sse2x4    3155 MB/s
[    0.994999] raid6: sse2x4    3155 MB/s
[    0.997313] raid6: using algorithm sse2x2 (3245 MB/s)
[    0.997313] raid6: using algorithm sse2x2 (3245 MB/s)
[    1.000009] raid6: using ssse3x2 recovery algorithm
[    1.000009] raid6: using ssse3x2 recovery algorithm
[    1.004170] ACPI: Added _OSI(Module Device)
[    1.004170] ACPI: Added _OSI(Module Device)
[    1.006564] ACPI: Added _OSI(Processor Device)
[    1.006564] ACPI: Added _OSI(Processor Device)
[    1.010010] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.010010] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.013604] ACPI: Added _OSI(Processor Aggregator Device)
[    1.013604] ACPI: Added _OSI(Processor Aggregator Device)
[    1.019839] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:3)
[    1.019839] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:3)
[    1.044830] ACPI: Interpreter enabled
[    1.044830] ACPI: Interpreter enabled
[    1.048111] ACPI Exception: AE_NOT_FOUND,=20
[    1.048111] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_]While evaluating Sleep State [\_S1_] (20140926/hwxface-580)
 (20140926/hwxface-580)
[    1.053137] ACPI Exception: AE_NOT_FOUND,=20
[    1.053137] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_]While evaluating Sleep State [\_S2_] (20140926/hwxface-580)
 (20140926/hwxface-580)
[    1.059265] ACPI: (supports S0 S3 S5)
[    1.059265] ACPI: (supports S0 S3 S5)
[    1.060010] ACPI: Using IOAPIC for interrupt routing
[    1.060010] ACPI: Using IOAPIC for interrupt routing
[    1.063832] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.063832] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.099837] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.099837] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.110018] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    1.110018] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    1.116568] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.116568] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.123848] PCI host bridge to bus 0000:00
[    1.123848] PCI host bridge to bus 0000:00
[    1.127229] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.127229] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.130015] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.130015] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.135736] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.135736] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.140013] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.140013] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.144298] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    1.144298] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    1.149256] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.149256] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.160793] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.160793] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.166826] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.166826] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.174968] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    1.174968] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    1.177983] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    1.177983] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    1.180010] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.180010] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.181989] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    1.181989] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    1.184265] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.184265] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.186873] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.186873] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.189528] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    1.189528] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    1.190027] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    1.190027] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    1.193113] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.193113] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.199127] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    1.199127] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    1.201680] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.201680] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.210833] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    1.210833] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    1.214050] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.214050] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.217216] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    1.217216] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    1.220012] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.220012] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.227892] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    1.227892] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    1.230591] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    1.230591] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    1.233081] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    1.233081] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    1.239469] pci_bus 0000:00: on NUMA node 0
[    1.239469] pci_bus 0000:00: on NUMA node 0
[    1.241612] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    1.241612] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    1.243877] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    1.243877] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    1.246245] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    1.246245] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    1.248441] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    1.248441] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    1.250270] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    1.250270] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    1.252964] ACPI:=20
[    1.252964] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    1.255483] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.255483] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.257193] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    1.257193] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    1.259876] vgaarb: loaded
[    1.259876] vgaarb: loaded
[    1.260009] vgaarb: bridge control possible 0000:00:02.0
[    1.260009] vgaarb: bridge control possible 0000:00:02.0
[    1.262970] SCSI subsystem initialized
[    1.262970] SCSI subsystem initialized
[    1.264478] libata version 3.00 loaded.
[    1.264478] libata version 3.00 loaded.
[    1.265813] ACPI: bus type USB registered
[    1.265813] ACPI: bus type USB registered
[    1.267248] usbcore: registered new interface driver usbfs
[    1.267248] usbcore: registered new interface driver usbfs
[    1.268986] usbcore: registered new interface driver hub
[    1.268986] usbcore: registered new interface driver hub
[    1.280000] usbcore: registered new device driver usb
[    1.280000] usbcore: registered new device driver usb
[    1.280000] PCI: Using ACPI for IRQ routing
[    1.280000] PCI: Using ACPI for IRQ routing
[    1.280000] PCI: pci_cache_line_size set to 64 bytes
[    1.280000] PCI: pci_cache_line_size set to 64 bytes
[    1.280000] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.280000] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.280000] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    1.280000] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    1.280128] Switched to clocksource kvm-clock
[    1.280128] Switched to clocksource kvm-clock
[    1.282092] pnp: PnP ACPI init
[    1.282092] pnp: PnP ACPI init
[    1.283231] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    1.283231] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    1.285707] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.285707] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.287866] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    1.287866] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    1.290000] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.290000] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.290000] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    1.290000] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    1.290000] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.290000] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.290000] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    1.290000] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    1.310378] pnp 00:03: [dma 2]
[    1.310378] pnp 00:03: [dma 2]
[    1.311470] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.311470] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.313675] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.313675] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.316217] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.316217] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.319325] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.319325] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.323636] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.323636] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.329035] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:3)
[    1.329035] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:3)
[    1.333725] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.333725] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.339330] pnp: PnP ACPI: found 7 devices
[    1.339330] pnp: PnP ACPI: found 7 devices
[    1.352067] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.352067] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.355243] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.355243] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.359037] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.359037] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.363169] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.363169] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.367328] NET: Registered protocol family 1
[    1.367328] NET: Registered protocol family 1
[    1.371364] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.371364] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.374826] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.374826] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.378826] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.378826] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.383256] pci 0000:00:02.0: Video device with shadowed ROM
[    1.383256] pci 0000:00:02.0: Video device with shadowed ROM
[    1.387198] PCI: CLS 0 bytes, default 64
[    1.387198] PCI: CLS 0 bytes, default 64
[    1.390345] Unpacking initramfs...
[    1.390345] Unpacking initramfs...
[    3.219637] debug: unmapping init [mem 0xffff88001293d000-0xffff880013fe=
ffff]
[    3.219637] debug: unmapping init [mem 0xffff88001293d000-0xffff880013fe=
ffff]
[    3.265050] sha1_ssse3: Using AVX optimized SHA-1 implementation
[    3.265050] sha1_ssse3: Using AVX optimized SHA-1 implementation
[    3.269333] sha256_ssse3: Using AVX optimized SHA-256 implementation
[    3.269333] sha256_ssse3: Using AVX optimized SHA-256 implementation
[    3.287583] AVX2 or AES-NI instructions are not detected.
[    3.287583] AVX2 or AES-NI instructions are not detected.
[    3.289552] spin_lock-torture:--- Start of test [debug]: nwriters_stress=
=3D4 nreaders_stress=3D0 stat_interval=3D60 verbose=3D1 shuffle_interval=3D=
3 stutter=3D5 shutdown_secs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    3.289552] spin_lock-torture:--- Start of test [debug]: nwriters_stress=
=3D4 nreaders_stress=3D0 stat_interval=3D60 verbose=3D1 shuffle_interval=3D=
3 stutter=3D5 shutdown_secs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    3.301857] spin_lock-torture: Creating torture_shuffle task
[    3.301857] spin_lock-torture: Creating torture_shuffle task
[    3.307952] spin_lock-torture: torture_shuffle task started
[    3.307952] spin_lock-torture: torture_shuffle task started
[    3.309824] spin_lock-torture: Creating torture_stutter task
[    3.309824] spin_lock-torture: Creating torture_stutter task
[    3.313956] spin_lock-torture: torture_stutter task started
[    3.313956] spin_lock-torture: torture_stutter task started
[    3.315822] spin_lock-torture: Creating lock_torture_writer task
[    3.315822] spin_lock-torture: Creating lock_torture_writer task
[    3.319954] spin_lock-torture: lock_torture_writer task started
[    3.319954] spin_lock-torture: lock_torture_writer task started
[    3.331936] spin_lock-torture: Creating lock_torture_writer task
[    3.331936] spin_lock-torture: Creating lock_torture_writer task
[    3.337329] spin_lock-torture: Creating lock_torture_writer task
[    3.337329] spin_lock-torture: Creating lock_torture_writer task
[    3.341480] spin_lock-torture: lock_torture_writer task started
[    3.341480] spin_lock-torture: lock_torture_writer task started
[    3.345527] spin_lock-torture: lock_torture_writer task started
[    3.345527] spin_lock-torture: lock_torture_writer task started
[    3.351954] spin_lock-torture: Creating lock_torture_writer task
[    3.351954] spin_lock-torture: Creating lock_torture_writer task
[    3.356200] spin_lock-torture: Creating lock_torture_stats task
[    3.356200] spin_lock-torture: Creating lock_torture_stats task
[    3.359233] spin_lock-torture: lock_torture_writer task started
[    3.359233] spin_lock-torture: lock_torture_writer task started
[    3.364311] spin_lock-torture: lock_torture_stats task started
[    3.364311] spin_lock-torture: lock_torture_stats task started
[    3.368065] torture_init_begin: refusing rcu init: spin_lock running
[    3.368065] torture_init_begin: refusing rcu init: spin_lock running

[    3.381786] futex hash table entries: 512 (order: 4, 65536 bytes)
[    3.381786] futex hash table entries: 512 (order: 4, 65536 bytes)
[    3.387028] Initialise system trusted keyring
[    3.387028] Initialise system trusted keyring
[    3.392338] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    3.392338] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    3.398068] zbud: loaded
[    3.398068] zbud: loaded
[    3.401172] VFS: Disk quotas dquot_6.5.2
[    3.401172] VFS: Disk quotas dquot_6.5.2
[    3.403244] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    3.403244] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    3.409302] fuse init (API version 7.23)
[    3.409302] fuse init (API version 7.23)
[    3.413526] JFS: nTxBlock =3D 2110, nTxLock =3D 16884
[    3.413526] JFS: nTxBlock =3D 2110, nTxLock =3D 16884
[    3.424018] SGI XFS with ACLs, security attributes, no debug enabled
[    3.424018] SGI XFS with ACLs, security attributes, no debug enabled
[    3.432441] gfs2: GFS2 installed
[    3.432441] gfs2: GFS2 installed
[    3.433652] Key type big_key registered
[    3.433652] Key type big_key registered
[    3.456864] Key type asymmetric registered
[    3.456864] Key type asymmetric registered
[    3.458317] Asymmetric key parser 'x509' registered
[    3.458317] Asymmetric key parser 'x509' registered
[    3.460135] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 253)
[    3.460135] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 253)
[    3.462300] io scheduler noop registered
[    3.462300] io scheduler noop registered
[    3.463570] io scheduler cfq registered (default)
[    3.463570] io scheduler cfq registered (default)
[    3.465009] start plist test
[    3.465009] start plist test
[    3.467288] end plist test
[    3.467288] end plist test
[    3.468692] rbtree testing
[    3.468692] rbtree testing

[    4.220155] tsc: Refined TSC clocksource calibration: 2693.505 MHz
[    4.220155] tsc: Refined TSC clocksource calibration: 2693.505 MHz
[    4.420413]  -> 25613 cycles
[    4.420413]  -> 25613 cycles
[    4.502086] augmented rbtree testing
[    4.502086] augmented rbtree testing -> 35465 cycles
 -> 35465 cycles
[    5.932322] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    5.932322] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    5.937716] ACPI: Power Button [PWRF]
[    5.937716] ACPI: Power Button [PWRF]
[    6.080653] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    6.080653] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    6.135959] serial 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 1=
15200) is a 16550A
[    6.135959] serial 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 1=
15200) is a 16550A
[    6.145863] lp: driver loaded but no devices found
[    6.145863] lp: driver loaded but no devices found
[    6.148636] ppdev: user-space parallel port driver
[    6.148636] ppdev: user-space parallel port driver
[    6.151428] dummy-irq: no IRQ given.  Use irq=3DN
[    6.151428] dummy-irq: no IRQ given.  Use irq=3DN
[    6.156889] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    6.156889] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    6.161083] SCSI Media Changer driver v0.25=20
[    6.161083] SCSI Media Changer driver v0.25=20
[    6.193657] scsi_debug: host protection
[    6.193657] scsi_debug: host protection
[    6.195690] scsi host0: scsi_debug, version 1.84 [20140706], dev_size_mb=
=3D8, opts=3D0x0
[    6.195690] scsi host0: scsi_debug, version 1.84 [20140706], dev_size_mb=
=3D8, opts=3D0x0
[    6.201859] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       01=
84 PQ: 0 ANSI: 6
[    6.201859] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       01=
84 PQ: 0 ANSI: 6
[    6.210400] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    6.210400] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    6.212669] ehci-pci: EHCI PCI platform driver
[    6.212669] ehci-pci: EHCI PCI platform driver
[    6.212973] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    6.212973] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    6.216075] ehci-platform: EHCI generic platform driver
[    6.216075] ehci-platform: EHCI generic platform driver
[    6.217870] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    6.217870] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    6.220383] ohci-pci: OHCI PCI platform driver
[    6.220383] ohci-pci: OHCI PCI platform driver
[    6.221864] ohci-platform: OHCI generic platform driver
[    6.221864] ohci-platform: OHCI generic platform driver
[    6.227116] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[    6.227116] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[    6.234626] usbcore: registered new interface driver cdc_wdm
[    6.234626] usbcore: registered new interface driver cdc_wdm
[    6.236540] usbcore: registered new interface driver adutux
[    6.236540] usbcore: registered new interface driver adutux
[    6.241810] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.=
00 MiB)
[    6.241810] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.=
00 MiB)
[    6.249777] usbcore: registered new interface driver appledisplay
[    6.249777] usbcore: registered new interface driver appledisplay
[    6.254188] usbcore: registered new interface driver iowarrior
[    6.254188] usbcore: registered new interface driver iowarrior
[    6.256201] usbcore: registered new interface driver ldusb
[    6.256201] usbcore: registered new interface driver ldusb
[    6.261536] usbcore: registered new interface driver lvs
[    6.261536] usbcore: registered new interface driver lvs
[    6.268313] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    6.268313] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    6.270084] sd 0:0:0:0: [sda] Write Protect is off
[    6.270084] sd 0:0:0:0: [sda] Write Protect is off
[    6.270087] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[    6.270087] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[    6.281175] serio: i8042 KBD port at 0x60,0x64 irq 1
[    6.281175] serio: i8042 KBD port at 0x60,0x64 irq 1
[    6.287675] serio: i8042 AUX port at 0x60,0x64 irq 12
[    6.287675] serio: i8042 AUX port at 0x60,0x64 irq 12
[    6.300067] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 supports DPO and FUA
[    6.300067] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 supports DPO and FUA
[    6.430094]  sda: unknown partition table
[    6.430094]  sda: unknown partition table
[    6.471456] usbcore: registered new interface driver usbtouchscreen
[    6.471456] usbcore: registered new interface driver usbtouchscreen
[    6.476067] rtc (null): invalid alarm value: 1900-1-10 0:0:0
[    6.476067] rtc (null): invalid alarm value: 1900-1-10 0:0:0
[    6.478728] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    6.478728] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    6.481750] rtc-test rtc-test.0: rtc core: registered test as rtc0
[    6.481750] rtc-test rtc-test.0: rtc core: registered test as rtc0
[    6.484098] rtc (null): invalid alarm value: 1900-1-10 0:0:0
[    6.484098] rtc (null): invalid alarm value: 1900-1-10 0:0:0
[    6.486178] rtc-test rtc-test.1: rtc core: registered test as rtc1
[    6.486178] rtc-test rtc-test.1: rtc core: registered test as rtc1
[    6.488369] i2c /dev entries driver
[    6.488369] i2c /dev entries driver
[    6.490409] sd 0:0:0:0: [sda] Attached SCSI disk
[    6.490409] sd 0:0:0:0: [sda] Attached SCSI disk
[    6.490715] usbcore: registered new interface driver i2c-diolan-u2c
[    6.490715] usbcore: registered new interface driver i2c-diolan-u2c
[    6.491500] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    6.491500] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    6.500168] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D1)
[    6.500168] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D1)
[    6.502240] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[    6.502240] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[    6.504912] ib700wdt: START method I/O 443 is not available
[    6.504912] ib700wdt: START method I/O 443 is not available
[    6.510207] ib700wdt: probe of ib700wdt failed with error -5
[    6.510207] ib700wdt: probe of ib700wdt failed with error -5
[    6.512242] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[    6.512242] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[    6.514860] wafer5823wdt: I/O address 0x0443 already in use
[    6.514860] wafer5823wdt: I/O address 0x0443 already in use
[    6.516736] sc1200wdt: build 20020303
[    6.516736] sc1200wdt: build 20020303
[    6.518008] sc1200wdt: io parameter must be specified
[    6.518008] sc1200wdt: io parameter must be specified
[    6.519693] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    6.519693] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    6.523396] smsc37b787_wdt: Unable to register miscdev on minor 130
[    6.523396] smsc37b787_wdt: Unable to register miscdev on minor 130
[    6.525410] w83877f_wdt: I/O address 0x0443 already in use
[    6.525410] w83877f_wdt: I/O address 0x0443 already in use
[    6.527330] w83977f_wdt: driver v1.00
[    6.527330] w83977f_wdt: driver v1.00
[    6.528511] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    6.528511] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    6.530722] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    6.530722] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    6.532689] machzwd: no ZF-Logic found
[    6.532689] machzwd: no ZF-Logic found
[    6.534277] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    6.534277] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    6.536891] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    6.536891] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    6.539843] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[    6.539843] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[    6.545185] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    6.545185] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    6.549216]  fake-fmc-carrier: mezzanine 0
[    6.549216]  fake-fmc-carrier: mezzanine 0
[    6.551457]       Manufacturer: fake-vendor
[    6.551457]       Manufacturer: fake-vendor
[    6.552816]       Product name: fake-design-for-testing
[    6.552816]       Product name: fake-design-for-testing
[    6.555330] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[    6.555330] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[    6.557634] fmc_trivial: probe of fake-design-for-testing-f001 failed wi=
th error -95
[    6.557634] fmc_trivial: probe of fake-design-for-testing-f001 failed wi=
th error -95
[    6.560289] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[    6.560289] fmc fake-design-for-testing-f001: Driver has no ID: matches =
all
[    6.563426] fmc_chardev fake-design-for-testing-f001: Created misc devic=
e "fake-design-for-testing-f001"
[    6.563426] fmc_chardev fake-design-for-testing-f001: Created misc devic=
e "fake-design-for-testing-f001"
[    6.577444]=20
[    6.577444] printing PIC contents
[    6.577444]=20
[    6.577444] printing PIC contents
[    6.579013] ... PIC  IMR: ffff
[    6.579013] ... PIC  IMR: ffff
[    6.586673] ... PIC  IRR: 1013
[    6.586673] ... PIC  IRR: 1013
[    6.587768] ... PIC  ISR: 0000
[    6.587768] ... PIC  ISR: 0000
[    6.588760] ... PIC ELCR: 0c00
[    6.588760] ... PIC ELCR: 0c00
[    6.589794] printing local APIC contents on CPU#0/0:
[    6.589794] printing local APIC contents on CPU#0/0:
[    6.591233] ... APIC ID:      00000000 (0)
[    6.591233] ... APIC ID:      00000000 (0)
[    6.592389] ... APIC VERSION: 01050014
[    6.592389] ... APIC VERSION: 01050014
[    6.593494] ... APIC TASKPRI: 00000000 (00)
[    6.593494] ... APIC TASKPRI: 00000000 (00)
[    6.595120] ... APIC PROCPRI: 00000000
[    6.595120] ... APIC PROCPRI: 00000000
[    6.596640] ... APIC LDR: 01000000
[    6.596640] ... APIC LDR: 01000000
[    6.597712] ... APIC DFR: ffffffff
[    6.597712] ... APIC DFR: ffffffff
[    6.598752] ... APIC SPIV: 000001ff
[    6.598752] ... APIC SPIV: 000001ff
[    6.599782] ... APIC ISR field:
[    6.599782] ... APIC ISR field:
[    6.599782] 00000000
[    6.599782] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    6.599782] ... APIC TMR field:
[    6.599782] ... APIC TMR field:
[    6.599782] 00000000
[    6.599782] 000000000200000002000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    6.599782] ... APIC IRR field:
[    6.599782] ... APIC IRR field:
[    6.599782] 00000000
[    6.599782] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000002000000020000000

[    6.599782] ... APIC ESR: 00000000
[    6.599782] ... APIC ESR: 00000000
[    6.599782] ... APIC ICR: 000008fd
[    6.599782] ... APIC ICR: 000008fd
[    6.599782] ... APIC ICR2: 02000000
[    6.599782] ... APIC ICR2: 02000000
[    6.599782] ... APIC LVTT: 000400ef
[    6.599782] ... APIC LVTT: 000400ef
[    6.599782] ... APIC LVTPC: 00010000
[    6.599782] ... APIC LVTPC: 00010000
[    6.599782] ... APIC LVT0: 00010700
[    6.599782] ... APIC LVT0: 00010700
[    6.599782] ... APIC LVT1: 00000400
[    6.599782] ... APIC LVT1: 00000400
[    6.599782] ... APIC LVTERR: 000000fe
[    6.599782] ... APIC LVTERR: 000000fe
[    6.599782] ... APIC TMICT: 00000000
[    6.599782] ... APIC TMICT: 00000000
[    6.599782] ... APIC TMCCT: 00000000
[    6.599782] ... APIC TMCCT: 00000000
[    6.599782] ... APIC TDCR: 00000000
[    6.599782] ... APIC TDCR: 00000000
[    6.599782]=20
[    6.599782]=20
[    6.647275] number of MP IRQ sources: 15.
[    6.647275] number of MP IRQ sources: 15.
[    6.648590] number of IO-APIC #0 registers: 24.
[    6.648590] number of IO-APIC #0 registers: 24.
[    6.650063] testing the IO APIC.......................
[    6.650063] testing the IO APIC.......................
[    6.651732] IO APIC #0......
[    6.651732] IO APIC #0......
[    6.653576] .... register #00: 00000000
[    6.653576] .... register #00: 00000000
[    6.654812] .......    : physical APIC id: 00
[    6.654812] .......    : physical APIC id: 00
[    6.656215] .......    : Delivery Type: 0
[    6.656215] .......    : Delivery Type: 0
[    6.657505] .......    : LTS          : 0
[    6.657505] .......    : LTS          : 0
[    6.658788] .... register #01: 00170011
[    6.658788] .... register #01: 00170011
[    6.660041] .......     : max redirection entries: 17
[    6.660041] .......     : max redirection entries: 17
[    6.661655] .......     : PRQ implemented: 0
[    6.661655] .......     : PRQ implemented: 0
[    6.673096] .......     : IO APIC version: 11
[    6.673096] .......     : IO APIC version: 11
[    6.675117] .... register #02: 00000000
[    6.675117] .... register #02: 00000000
[    6.676353] .......     : arbitration: 00
[    6.676353] .......     : arbitration: 00
[    6.677635] .... IRQ redirection table:
[    6.677635] .... IRQ redirection table:
[    6.678884] 1    0    0   0   0    0    0    00
[    6.678884] 1    0    0   0   0    0    0    00
[    6.680367] 0    0    0   0   0    1    1    31
[    6.680367] 0    0    0   0   0    1    1    31
[    6.681833] 0    0    0   0   0    1    1    30
[    6.681833] 0    0    0   0   0    1    1    30
[    6.693374] 0    0    0   0   0    1    1    33
[    6.693374] 0    0    0   0   0    1    1    33
[    6.694836] 1    0    0   0   0    1    1    34
[    6.694836] 1    0    0   0   0    1    1    34
[    6.696309] 1    1    0   0   0    1    1    35
[    6.696309] 1    1    0   0   0    1    1    35
[    6.697771] 0    0    0   0   0    1    1    36
[    6.697771] 0    0    0   0   0    1    1    36
[    6.699238] 0    0    0   0   0    1    1    37
[    6.699238] 0    0    0   0   0    1    1    37
[    6.700721] 0    0    0   0   0    1    1    38
[    6.700721] 0    0    0   0   0    1    1    38
[    6.713298] 0    1    0   0   0    1    1    39
[    6.713298] 0    1    0   0   0    1    1    39
[    6.714766] 1    1    0   0   0    1    1    3A
[    6.714766] 1    1    0   0   0    1    1    3A
[    6.716231] 1    1    0   0   0    1    1    3B
[    6.716231] 1    1    0   0   0    1    1    3B
[    6.717692] 0    0    0   0   0    1    1    3C
[    6.717692] 0    0    0   0   0    1    1    3C
[    6.719148] 0    0    0   0   0    1    1    3D
[    6.719148] 0    0    0   0   0    1    1    3D
[    6.720637] 0    0    0   0   0    1    1    3E
[    6.720637] 0    0    0   0   0    1    1    3E
[    6.722095] 0    0    0   0   0    1    1    3F
[    6.722095] 0    0    0   0   0    1    1    3F
[    6.733610] 1    0    0   0   0    0    0    00
[    6.733610] 1    0    0   0   0    0    0    00
[    6.735074] 1    0    0   0   0    0    0    00
[    6.735074] 1    0    0   0   0    0    0    00
[    6.736542] 1    0    0   0   0    0    0    00
[    6.736542] 1    0    0   0   0    0    0    00
[    6.737999] 1    0    0   0   0    0    0    00
[    6.737999] 1    0    0   0   0    0    0    00
[    6.739463] 1    0    0   0   0    0    0    00
[    6.739463] 1    0    0   0   0    0    0    00
[    6.741033] 1    0    0   0   0    0    0    00
[    6.741033] 1    0    0   0   0    0    0    00
[    6.752584] 1    0    0   0   0    0    0    00
[    6.752584] 1    0    0   0   0    0    0    00
[    6.754054] 1    0    0   0   0    0    0    00
[    6.754054] 1    0    0   0   0    0    0    00
[    6.755505] IRQ to pin mappings:
[    6.755505] IRQ to pin mappings:
[    6.756545] IRQ0=20
[    6.756545] IRQ0 -> 0:2-> 0:2

[    6.757393] IRQ1=20
[    6.757393] IRQ1 -> 0:1-> 0:1

[    6.758238] IRQ3=20
[    6.758238] IRQ3 -> 0:3-> 0:3

[    6.759083] IRQ4=20
[    6.759083] IRQ4 -> 0:4-> 0:4

[    6.759926] IRQ5=20
[    6.759926] IRQ5 -> 0:5-> 0:5

[    6.760804] IRQ6=20
[    6.760804] IRQ6 -> 0:6-> 0:6

[    6.761651] IRQ7=20
[    6.761651] IRQ7 -> 0:7-> 0:7

[    6.772550] IRQ8=20
[    6.772550] IRQ8 -> 0:8-> 0:8

[    6.773400] IRQ9=20
[    6.773400] IRQ9 -> 0:9-> 0:9

[    6.774250] IRQ10=20
[    6.774250] IRQ10 -> 0:10-> 0:10

[    6.775145] IRQ11=20
[    6.775145] IRQ11 -> 0:11-> 0:11

[    6.776046] IRQ12=20
[    6.776046] IRQ12 -> 0:12-> 0:12

[    6.776943] IRQ13=20
[    6.776943] IRQ13 -> 0:13-> 0:13

[    6.777840] IRQ14=20
[    6.777840] IRQ14 -> 0:14-> 0:14

[    6.778740] IRQ15=20
[    6.778740] IRQ15 -> 0:15-> 0:15

[    6.779633] .................................... done.
[    6.779633] .................................... done.
[    6.783204] bootconsole [earlyser0] disabled
[    6.783204] bootconsole [earlyser0] disabled
[    6.784763] Loading compiled-in X.509 certificates
[    6.786667] Loaded X.509 cert 'Magrathea: Glacier signing key: 1216b44b4=
13bd14bd0c40a377a3aab241f9a3fea'
[    6.792751] Btrfs loaded
[    6.794549]   Magic number: 10:250:902
[    6.795306] tty ptyvf: hash matches
[    6.796280] Unregister pv shared memory for cpu 0
[    6.832547] CPU 0 is now offline
[    6.833966] debug: unmapping init [mem 0xffffffff81b3e000-0xffffffff81c2=
ffff]
[    6.835238] Write protecting the kernel read-only data: 10240k
[    6.836533] debug: unmapping init [mem 0xffff880001595000-0xffff8800015f=
ffff]
[    6.837767] debug: unmapping init [mem 0xffff880001876000-0xffff8800019f=
ffff]
[    6.863402] random: init urandom read with 3 bits of entropy available
mountall: Event failed
[    7.191810] init: Failed to create pty - disabling logging for job
[    7.203242] init: Temporary process spawn error: No space left on device
[    7.651133] udevd[221]: starting version 175
[    7.660595] init: plymouth-log main process (219) terminated with status=
 1
udevd[221]: error creating signalfd
[    7.729042] init: udev main process (221) terminated with status 5
[    7.740443] init: udev main process ended, respawning
[    7.751619] udevd[234]: starting version 175
udevd[234]: error creating signalfd
[    7.755065] init: udev main process (234) terminated with status 5
[    7.755970] init: udev main process ended, respawning
[    7.764273] udevd[236]: starting version 175
udevd[236]: error creating signalfd
[    7.771844] init: udev main process (236) terminated with status 5
[    7.772842] init: udev main process ended, respawning
[    7.791427] udevd[238]: starting version 175
udevd[238]: error creating signalfd
[    7.794595] init: udev main process (238) terminated with status 5
[    7.795505] init: udev main process ended, respawning
[    7.803943] udevd[240]: starting version 175
udevd[240]: error creating signalfd
[    7.807623] init: udev main process (240) terminated with status 5
[    7.808732] init: udev main process ended, respawning
[    7.817357] udevd[242]: starting version 175
udevd[242]: error creating signalfd
[    7.820694] init: udev main process (242) terminated with status 5
[    7.821603] init: udev main process ended, respawning
[    7.837425] udevd[244]: starting version 175
udevd[244]: error creating signalfd
[    7.840895] init: udev main process (244) terminated with status 5
[    7.841814] init: udev main process ended, respawning
[    7.854323] udevd[246]: starting version 175
udevd[246]: error creating signalfd
[    7.857714] init: udev main process (246) terminated with status 5
[    7.858622] init: udev main process ended, respawning
[    7.874546] udevd[248]: starting version 175
udevd[248]: error creating signalfd
[    7.877585] init: udev main process (248) terminated with status 5
[    7.878487] init: udev main process ended, respawning
[    7.887320] udevd[250]: starting version 175
udevd[250]: error creating signalfd
[    7.891190] init: udev main process (250) terminated with status 5
[    7.892298] init: udev main process ended, respawning
[    7.907592] udevd[252]: starting version 175
udevd[252]: error creating signalfd
[    7.911942] init: udev main process (252) terminated with status 5
[    7.912923] init: udev respawning too fast, stopped
[    8.100405] init: udev-fallback-graphics main process (254) terminated w=
ith status 127
[    8.254187] init: networking main process (258) terminated with status 1
Kernel tests: Boot OK!
Kernel tests: Boot OK!
Trinity v1.4pre  Dave Jones <davej@redhat.com>
[init] Marking syscall get_robust_list (64bit:274 32bit:312) as to be disab=
led.
Done parsing arguments.
Marking all syscalls as enabled.
[init] Disabling syscalls marked as disabled by command line options
[init] Marked 64-bit syscall get_robust_list (274) as deactivated.
[init] Marked 32-bit syscall get_robust_list (312) as deactivated.
[init] 32-bit syscalls: 350 enabled, 1 disabled.  64-bit syscalls: 313 enab=
led, 1 disabled.
DANGER: RUNNING AS ROOT.
Unless you are running in a virtual machine, this could cause serious probl=
ems such as overwriting CMOS
or similar which could potentially make this machine unbootable without a f=
irmware reset.

ctrl-c now unless you really know what you are doing.
[   18.483776] init: tty4 main process (289) terminated with status 1
[   18.484709] init: tty4 main process ended, respawning
[   18.485868] init: tty5 main process (290) terminated with status 1
[   18.486802] init: tty5 main process ended, respawning
[   18.487873] init: tty2 main process (291) terminated with status 1
[   18.492497] init: tty2 main process ended, respawning
[   18.493571] init: tty3 main process (292) terminated with status 1
[   18.494480] init: tty3 main process ended, respawning
[   18.515084] init: tty6 main process (293) terminated with status 1
[   18.516013] init: tty6 main process ended, respawning
fopen: No such file or directory
Couldn't read pid_max from proc
[init] Using pid_max =3D 4194304
[init] Kernel was tainted on startup. Will ignore flags that are already se=
t.
[init] Started watchdog process, PID is 9354
[main] Main thread is alive.
[   21.233581] BUG: unable to handle kernel NULL pointer dereference at 000=
0000000000007
[   21.234709] IP: [<ffffffff8156ebda>] sk_attach_bpf+0x39/0xc2
[   21.235503] PGD b12c067 PUD b12d067 PMD 0=20
[   21.236124] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   21.236902] Modules linked in:
[   21.237347] CPU: 1 PID: 318 Comm: trinity-main Not tainted 3.18.0-rc6-g8=
9aa075 #214
[   21.238371] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   21.239146] task: ffff8800001e0000 ti: ffff8800001e4000 task.ti: ffff880=
0001e4000
[   21.240145] RIP: 0010:[<ffffffff8156ebda>]  [<ffffffff8156ebda>] sk_atta=
ch_bpf+0x39/0xc2
[   21.241252] RSP: 0018:ffff8800001e7ea8  EFLAGS: 00010282
[   21.241970] RAX: 00000000ffffffea RBX: ffff88000af305c0 RCX: 00000000000=
00000
[   21.242107] RDX: 0000000000000000 RSI: 0000000000004000 RDI: 00000000000=
00000
[   21.242107] RBP: ffff8800001e7ec8 R08: 0000000000003601 R09: 00000000000=
00209
[   21.242107] R10: 0000000000000000 R11: 0000000000000206 R12: 00000000fff=
ffff2
[   21.242107] R13: fffffffffffffff7 R14: 0000000000000c01 R15: 00000000000=
00004
[   21.242107] FS:  00007f035d5ed700(0000) GS:ffff880012500000(0000) knlGS:=
0000000000000000
[   21.242107] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   21.242107] CR2: 0000000000000007 CR3: 000000000b141000 CR4: 00000000000=
406e0
[   21.242107] Stack:
[   21.242107]  0000000000000000 ffff88000af305c0 00000000fffffff2 00000000=
00000c01
[   21.242107]  ffff8800001e7f28 ffffffff8154cca3 00000032011e7ef8 00000000=
008a3000
[   21.242107]  ffff880000000c01 ffff8800001e0000 ffff8800001e7f38 ffff8800=
0b7bb780
[   21.242107] Call Trace:
[   21.242107]  [<ffffffff8154cca3>] sock_setsockopt+0x447/0x5ef
[   21.242107]  [<ffffffff81548dfd>] SyS_setsockopt+0x61/0x94
[   21.242107]  [<ffffffff8158ed69>] system_call_fastpath+0x12/0x17
[   21.242107] Code: 40 00 0f 85 ab 00 00 00 55 48 89 e5 41 55 41 54 53 51 =
48 89 f3 e8 bf 82 b7 ff 49 89 c5 b8 ea ff ff ff 4d 85 ed 0f 84 81 00 00 00 =
<49> 8b 45 10 83 78 08 01 74 0f 4c 89 ef e8 60 82 b7 ff b8 ea ff=20
[   21.242107] RIP  [<ffffffff8156ebda>] sk_attach_bpf+0x39/0xc2
[   21.242107]  RSP <ffff8800001e7ea8>
[   21.242107] CR2: 0000000000000007
[   21.292711] ---[ end trace 5196e3a283419924 ]---
[   21.293361] Kernel panic - not syncing: Fatal exception
[   21.294141] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range=
: 0xffffffff80000000-0xffffffff9fffffff)

Elapsed time: 35
qemu-system-x86_64 -enable-kvm -cpu Haswell,+smep,+smap -kernel /kernel/x86=
_64-randconfig-s0-12101616/89aa075832b0da4402acebd698d0411dcc82d03e/vmlinuz=
-3.18.0-rc6-g89aa075 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,11520=
0 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D=
100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_=
ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3D=
normal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randc=
onfig-s0-12101616/netdev-next:master:89aa075832b0da4402acebd698d0411dcc82d0=
3e:bisect-linux-8/.vmlinuz-89aa075832b0da4402acebd698d0411dcc82d03e-2014121=
0204605-64-kbuild branch=3Dnetdev-next/master BOOT_IMAGE=3D/kernel/x86_64-r=
andconfig-s0-12101616/89aa075832b0da4402acebd698d0411dcc82d03e/vmlinuz-3.18=
=2E0-rc6-g89aa075 drbd.minor_count=3D8'  -initrd /kernel-tests/initrd/quant=
al-core-x86_64.cgz -m 320 -smp 2 -net nic,vlan=3D1,model=3De1000 -net user,=
vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocalti=
me -pidfile /dev/shm/kboot/pid-quantal-kbuild-2 -serial file:/dev/shm/kboot=
/serial-quantal-kbuild-2 -daemonize -display none -monitor null=20

--nHwqXXcoX0o6fKCv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.18.0-rc6-g89aa075"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.18.0-rc6 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
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
CONFIG_FIX_EARLYCON_MEM=y
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
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
# CONFIG_FHANDLE is not set
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_LEGACY_ALLOC_HWIRQ=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
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
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
# CONFIG_NO_HZ_FULL_ALL is not set
# CONFIG_NO_HZ_FULL_SYSIDLE is not set
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
# CONFIG_TASKS_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_RCU_USER_QS=y
CONFIG_CONTEXT_TRACKING_FORCE=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FANOUT_EXACT=y
CONFIG_RCU_FAST_NO_HZ=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_BOOST is not set
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
CONFIG_RCU_NOCB_CPU_ZERO=y
# CONFIG_RCU_NOCB_CPU_ALL is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_BLK_CGROUP is not set
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
# CONFIG_SIGNALFD is not set
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_SYSTEM_TRUSTED_KEYRING=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
# CONFIG_JUMP_LABEL is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
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
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
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
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_MODULE_SIG=y
# CONFIG_MODULE_SIG_FORCE is not set
# CONFIG_MODULE_SIG_ALL is not set
# CONFIG_MODULE_SIG_SHA1 is not set
# CONFIG_MODULE_SIG_SHA224 is not set
# CONFIG_MODULE_SIG_SHA256 is not set
CONFIG_MODULE_SIG_SHA384=y
# CONFIG_MODULE_SIG_SHA512 is not set
CONFIG_MODULE_SIG_HASH="sha384"
CONFIG_MODULE_COMPRESS=y
# CONFIG_MODULE_COMPRESS_GZIP is not set
CONFIG_MODULE_COMPRESS_XZ=y
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
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
CONFIG_IOSCHED_DEADLINE=m
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUE_RWLOCK=y
CONFIG_QUEUE_RWLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_MPPARSE is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_IOSF_MBI is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
# CONFIG_DIRECT_GBPAGES is not set
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
# CONFIG_ARCH_MEMORY_PROBE is not set
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
# CONFIG_MEM_SOFT_DIRTY is not set
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=y
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=m
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
# CONFIG_CPU_FREQ_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_GOV_ONDEMAND=m
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=m
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=m
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=m
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
CONFIG_MTD_BLOCK_RO=m
CONFIG_FTL=m
CONFIG_NFTL=m
CONFIG_NFTL_RW=y
CONFIG_INFTL=m
CONFIG_RFD_FTL=m
CONFIG_SSFDC=m
CONFIG_SM_FTL=m
CONFIG_MTD_OOPS=m

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_GEN_PROBE=m
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
CONFIG_MTD_CFI_LE_BYTE_SWAP=y
# CONFIG_MTD_CFI_GEOMETRY is not set
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
# CONFIG_MTD_OTP is not set
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
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=m
# CONFIG_MTD_PHYSMAP_COMPAT is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=m

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=m
CONFIG_MTD_PHRAM=m
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=m
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=m
CONFIG_MTD_NAND_BCH=m
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_DENALI=m
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_GPIO is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=m
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=m
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH=y
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
CONFIG_MTD_NAND_DOCG4=m
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=m
CONFIG_MTD_NAND_PLATFORM=m
CONFIG_MTD_ONENAND=m
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=m
CONFIG_MTD_ONENAND_OTP=y
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=m
CONFIG_MTD_QINFO_PROBE=m
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_MTD_UBI_BLOCK=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_OSD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
CONFIG_AD525X_DPOT=m
# CONFIG_AD525X_DPOT_I2C is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=m
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=m
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
# CONFIG_HMC6352 is not set
CONFIG_DS1682=m
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_USB_SWITCH_FSA9480=m
# CONFIG_SRAM is not set
CONFIG_C2PORT=m
CONFIG_C2PORT_DURAMAR_2150=m

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=m
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=m

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=m
CONFIG_IDE_GD_ATA=y
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECS=m
# CONFIG_BLK_DEV_DELKIN is not set
CONFIG_BLK_DEV_IDECD=m
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=m
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=m
CONFIG_BLK_DEV_PLATFORM=m
CONFIG_BLK_DEV_CMD640=m
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
# CONFIG_BLK_DEV_IDEPNP is not set

#
# PCI IDE chipsets support
#
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_PIIX is not set
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
# CONFIG_BLK_DEV_IDEDMA is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
# CONFIG_SCSI_ENCLOSURE is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_ISCI is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
CONFIG_SCSI_VIRTIO=m
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
# CONFIG_PCMCIA_AHA152X is not set
# CONFIG_PCMCIA_FDOMAIN is not set
CONFIG_PCMCIA_QLOGIC=m
CONFIG_PCMCIA_SYM53C500=m
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=m
CONFIG_SCSI_OSD_DPRINT_SENSE=1
CONFIG_SCSI_OSD_DEBUG=y
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
# CONFIG_MD is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=m
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=m

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
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_AD7879=m
CONFIG_TOUCHSCREEN_AD7879_I2C=m
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_AUO_PIXCIR=m
CONFIG_TOUCHSCREEN_BU21013=m
CONFIG_TOUCHSCREEN_CY8CTMG110=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=m
CONFIG_TOUCHSCREEN_CYTTSP_I2C=m
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=m
CONFIG_TOUCHSCREEN_DYNAPRO=m
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=m
CONFIG_TOUCHSCREEN_FUJITSU=m
# CONFIG_TOUCHSCREEN_ILI210X is not set
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_ELO=m
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
CONFIG_TOUCHSCREEN_WACOM_I2C=m
CONFIG_TOUCHSCREEN_MAX11801=y
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=m
CONFIG_TOUCHSCREEN_MK712=m
CONFIG_TOUCHSCREEN_PENMOUNT=m
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=m
CONFIG_TOUCHSCREEN_TOUCHWIN=m
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_MC13783=m
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
# CONFIG_TOUCHSCREEN_USB_3M is not set
CONFIG_TOUCHSCREEN_USB_ITM=y
# CONFIG_TOUCHSCREEN_USB_ETURBO is not set
CONFIG_TOUCHSCREEN_USB_GUNZE=y
# CONFIG_TOUCHSCREEN_USB_DMC_TSC10 is not set
# CONFIG_TOUCHSCREEN_USB_IRTOUCH is not set
# CONFIG_TOUCHSCREEN_USB_IDEALTEK is not set
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
# CONFIG_TOUCHSCREEN_USB_JASTEC is not set
CONFIG_TOUCHSCREEN_USB_ELO=y
# CONFIG_TOUCHSCREEN_USB_E2I is not set
# CONFIG_TOUCHSCREEN_USB_ZYTRONIC is not set
# CONFIG_TOUCHSCREEN_USB_ETT_TC45USB is not set
CONFIG_TOUCHSCREEN_USB_NEXIO=y
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
CONFIG_TOUCHSCREEN_TOUCHIT213=m
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_SUR40=m
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZFORCE=m
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=m
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_FINTEK is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=m
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
# CONFIG_IPMI_SI_PROBE_DEFAULTS is not set
CONFIG_IPMI_WATCHDOG=m
# CONFIG_IPMI_POWEROFF is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
# CONFIG_CARDMAN_4040 is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=y
# CONFIG_TCG_TIS is not set
# CONFIG_TCG_TIS_I2C_ATMEL is not set
CONFIG_TCG_TIS_I2C_INFINEON=m
CONFIG_TCG_TIS_I2C_NUVOTON=m
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=m
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=y
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=m
# CONFIG_I2C_ALGOPCF is not set
CONFIG_I2C_ALGOPCA=y

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
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_KEMPLD is not set
CONFIG_I2C_OCORES=m
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=m
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=m
CONFIG_HSI=m
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=m
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=m
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
# CONFIG_GPIO_DA9055 is not set
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=m
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_IT8761E=y
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_SCH311X is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_CRYSTAL_COVE is not set
CONFIG_GPIO_LP3943=m
CONFIG_GPIO_MAX7300=m
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
# CONFIG_GPIO_PCA953X is not set
CONFIG_GPIO_PCF857X=m
CONFIG_GPIO_SX150X=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
CONFIG_GPIO_WM8994=m
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MCP23S08 is not set

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
# CONFIG_GPIO_KEMPLD is not set

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_PALMAS=y

#
# USB GPIO expanders:
#
CONFIG_GPIO_VIPERBOARD=m
CONFIG_W1=m

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2490 is not set
CONFIG_W1_MASTER_DS2482=m
CONFIG_W1_MASTER_DS1WM=m
CONFIG_W1_MASTER_GPIO=m

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2408=m
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=m
CONFIG_W1_SLAVE_DS2406=m
CONFIG_W1_SLAVE_DS2423=m
CONFIG_W1_SLAVE_DS2431=m
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=m
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=m
CONFIG_W1_SLAVE_DS28E04=m
CONFIG_W1_SLAVE_BQ27000=m
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
CONFIG_TEST_POWER=m
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27x00=y
# CONFIG_BATTERY_BQ27X00_I2C is not set
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_MAX17040=m
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MANAGER=y
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=m
CONFIG_CHARGER_BQ24735=m
CONFIG_CHARGER_SMB347=y
CONFIG_POWER_RESET=y
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
CONFIG_SENSORS_AD7414=m
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7410=m
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DA9055=m
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=m
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_MC13783_ADC is not set
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_GL518SM=m
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_G762=m
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=m
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_POWR1220=m
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LTC2945=m
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
CONFIG_SENSORS_LTC4222=m
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=m
CONFIG_SENSORS_LTC4261=m
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_MAX6697=m
CONFIG_SENSORS_HTU21=m
CONFIG_SENSORS_MCP3021=m
CONFIG_SENSORS_MENF21BMC_HWMON=m
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=m
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6683=m
CONFIG_SENSORS_NCT6775=m
CONFIG_SENSORS_PCF8591=m
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=m
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=m
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=m
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=m
CONFIG_SENSORS_SMM665=m
# CONFIG_SENSORS_ADC128D818 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=m
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
CONFIG_SENSORS_TMP103=m
CONFIG_SENSORS_TMP401=m
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=m
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=m
# CONFIG_X86_PKG_TEMP_THERMAL is not set
# CONFIG_INT340X_THERMAL is not set

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_DA9055_WATCHDOG=y
CONFIG_MENF21BMC_WATCHDOG=m
CONFIG_XILINX_WATCHDOG=y
CONFIG_DW_WATCHDOG=y
# CONFIG_TWL4030_WATCHDOG is not set
CONFIG_RETU_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=m
CONFIG_SC1200_WDT=y
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=m
CONFIG_CPU5_WDT=m
CONFIG_SMSC_SCH311X_WDT=m
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=m
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=m
# CONFIG_MEN_A21_WDT is not set

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
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_AXP20X=y
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
# CONFIG_HTC_PASIC3 is not set
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MENF21BMC=y
CONFIG_MFD_VIPERBOARD=m
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=m
# CONFIG_PCF50633_ADC is not set
CONFIG_PCF50633_GPIO=m
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RTSX_USB=m
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_RN5T618 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=y
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=m
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=m
# CONFIG_MFD_TPS65218 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=m
CONFIG_MFD_LM3533=m
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=m
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=m
CONFIG_REGULATOR_ACT8865=m
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_AB3100=y
CONFIG_REGULATOR_AXP20X=y
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_DA9055=m
CONFIG_REGULATOR_DA9210=m
CONFIG_REGULATOR_DA9211=m
CONFIG_REGULATOR_FAN53555=m
CONFIG_REGULATOR_GPIO=m
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=m
CONFIG_REGULATOR_LP3971=m
CONFIG_REGULATOR_LP3972=m
# CONFIG_REGULATOR_LP872X is not set
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LP8788=y
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_MAX14577=m
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=m
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_MAX8973=y
CONFIG_REGULATOR_MAX77686=m
CONFIG_REGULATOR_MAX77693=m
CONFIG_REGULATOR_MAX77802=y
# CONFIG_REGULATOR_MC13783 is not set
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_PALMAS=y
# CONFIG_REGULATOR_PCF50633 is not set
CONFIG_REGULATOR_PFUZE100=m
# CONFIG_REGULATOR_PWM is not set
CONFIG_REGULATOR_S2MPA01=m
CONFIG_REGULATOR_S2MPS11=m
CONFIG_REGULATOR_S5M8767=m
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=m
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65217=m
CONFIG_REGULATOR_TPS65912=m
# CONFIG_REGULATOR_TWL4030 is not set
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_REGULATOR_WM8994=m
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set

#
# Direct Rendering Manager
#
# CONFIG_DRM is not set

#
# Frame buffer Devices
#
# CONFIG_FB is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=m
CONFIG_BACKLIGHT_LM3533=m
CONFIG_BACKLIGHT_PWM=m
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=m
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=m
CONFIG_BACKLIGHT_PCF50633=m
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=m
# CONFIG_BACKLIGHT_PANDORA is not set
CONFIG_BACKLIGHT_TPS65217=m
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_VGASTATE is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=m
CONFIG_HIDRAW=y
CONFIG_UHID=m
CONFIG_HID_GENERIC=m

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=m
CONFIG_HID_APPLEIR=m
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=m
# CONFIG_HID_CHERRY is not set
CONFIG_HID_CHICONY=m
# CONFIG_HID_CP2112 is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=m
CONFIG_HID_ELECOM=m
CONFIG_HID_ELO=m
# CONFIG_HID_EZKEY is not set
CONFIG_HID_HOLTEK=m
CONFIG_HOLTEK_FF=y
# CONFIG_HID_GT683R is not set
CONFIG_HID_HUION=m
CONFIG_HID_KEYTOUCH=m
# CONFIG_HID_KYE is not set
CONFIG_HID_UCLOGIC=m
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=m
CONFIG_HID_LCPOWER=m
CONFIG_HID_LENOVO=m
CONFIG_HID_LOGITECH=m
# CONFIG_HID_LOGITECH_DJ is not set
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=m
CONFIG_HID_MICROSOFT=m
CONFIG_HID_MONTEREY=m
CONFIG_HID_MULTITOUCH=m
CONFIG_HID_NTRIG=m
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PENMOUNT=m
CONFIG_HID_PETALYNX=m
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PRIMAX=m
CONFIG_HID_ROCCAT=m
CONFIG_HID_SAITEK=m
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SONY=m
CONFIG_SONY_FF=y
CONFIG_HID_SPEEDLINK=m
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=m
CONFIG_HID_RMI=m
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=m
CONFIG_HID_WIIMOTE=m
CONFIG_HID_XINMO=m
CONFIG_HID_ZEROPLUS=m
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=m
CONFIG_HID_SENSOR_HUB=m

#
# USB HID support
#
CONFIG_USB_HID=m
# CONFIG_HID_PID is not set
CONFIG_USB_HIDDEV=y

#
# USB HID Boot Protocol drivers
#
CONFIG_USB_KBD=m
CONFIG_USB_MOUSE=m

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_OTG_FSM=m
CONFIG_USB_MON=m
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=m
CONFIG_USB_EHCI_HCD=y
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=m
CONFIG_USB_ISP1760_HCD=m
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FUSBH200_HCD is not set
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
CONFIG_USB_OHCI_HCD_SSB=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
# CONFIG_USB_SL811_HCD is not set
CONFIG_USB_R8A66597_HCD=m
CONFIG_USB_HCD_SSB=y
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=y
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_STORAGE is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MICROTEK=m
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y
CONFIG_USB_MUSB_TUSB6010=m
CONFIG_USB_MUSB_UX500=m
CONFIG_USB_UX500_DMA=y
# CONFIG_MUSB_PIO_ONLY is not set
CONFIG_USB_DWC3=m
CONFIG_USB_DWC3_HOST=y
# CONFIG_USB_DWC3_GADGET is not set
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=m

#
# Debugging features
#
CONFIG_USB_DWC3_DEBUG=y
CONFIG_USB_DWC3_VERBOSE=y
# CONFIG_DWC3_HOST_USB3_LPM_ENABLE is not set
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
CONFIG_USB_LED=m
CONFIG_USB_CYPRESS_CY7C63=m
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=m
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=m
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=m
CONFIG_USB_YUREX=m
CONFIG_USB_EZUSB_FX2=m
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_LINK_LAYER_TEST=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_TAHVO_USB=m
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
CONFIG_USB_ISP1301=y
CONFIG_USB_GADGET=m
# CONFIG_USB_GADGET_DEBUG is not set
CONFIG_USB_GADGET_DEBUG_FILES=y
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=m
# CONFIG_USB_GR_UDC is not set
CONFIG_USB_R8A66597=m
# CONFIG_USB_PXA27X is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_MV_U3D is not set
CONFIG_USB_M66592=m
# CONFIG_USB_AMD5536UDC is not set
CONFIG_USB_NET2272=m
# CONFIG_USB_NET2272_DMA is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
CONFIG_USB_DUMMY_HCD=m
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_SS_LB=m
CONFIG_USB_F_MASS_STORAGE=m
CONFIG_USB_F_FS=m
# CONFIG_USB_CONFIGFS is not set
CONFIG_USB_ZERO=m
# CONFIG_USB_ZERO_HNPTEST is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
CONFIG_USB_FUNCTIONFS=m
# CONFIG_USB_FUNCTIONFS_ETH is not set
# CONFIG_USB_FUNCTIONFS_RNDIS is not set
CONFIG_USB_FUNCTIONFS_GENERIC=y
CONFIG_USB_MASS_STORAGE=m
# CONFIG_USB_G_SERIAL is not set
CONFIG_USB_G_PRINTER=m
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
CONFIG_USB_G_HID=m
# CONFIG_USB_G_DBGP is not set
CONFIG_USB_LED_TRIG=y
# CONFIG_UWB is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
CONFIG_MSPRO_BLOCK=m
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_USB=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=m

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=m
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_PCA9532=m
CONFIG_LEDS_PCA9532_GPIO=y
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
CONFIG_LEDS_LP55XX_COMMON=m
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=m
CONFIG_LEDS_LP8501=m
# CONFIG_LEDS_LP8788 is not set
CONFIG_LEDS_CLEVO_MAIL=m
CONFIG_LEDS_PCA955X=m
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_PWM=m
CONFIG_LEDS_REGULATOR=m
CONFIG_LEDS_BD2802=m
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=m
# CONFIG_LEDS_MC13783 is not set
CONFIG_LEDS_TCA6507=m
CONFIG_LEDS_LM355x=m
CONFIG_LEDS_MENF21BMC=m

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_ONESHOT=m
# CONFIG_LEDS_TRIGGER_IDE_DISK is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_GPIO=m
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_ACCESSIBILITY=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=m
CONFIG_RTC_DRV_DS3232=m
# CONFIG_RTC_DRV_LP8788 is not set
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX77686=m
CONFIG_RTC_DRV_MAX77802=y
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=m
CONFIG_RTC_DRV_ISL12057=m
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=m
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF85063=y
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_TWL4030=y
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=y
# CONFIG_RTC_DRV_RX8581 is not set
CONFIG_RTC_DRV_RX8025=m
CONFIG_RTC_DRV_EM3027=m
CONFIG_RTC_DRV_RV3029C2=m
CONFIG_RTC_DRV_S5M=m

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=m
CONFIG_RTC_DRV_DS1553=m
CONFIG_RTC_DRV_DS1742=m
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_DA9055=y
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=m
# CONFIG_RTC_DRV_PCF50633 is not set
CONFIG_RTC_DRV_AB3100=y

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_MC13XXX is not set
# CONFIG_RTC_DRV_XGENE is not set

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
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=m
# CONFIG_DW_DMAC_PCI is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
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
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
CONFIG_VIRTIO_MMIO=m
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
CONFIG_COMEDI=m
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
# CONFIG_COMEDI_MISC_DRIVERS is not set
CONFIG_COMEDI_ISA_DRIVERS=y
CONFIG_COMEDI_PCL711=m
CONFIG_COMEDI_PCL724=m
CONFIG_COMEDI_PCL726=m
CONFIG_COMEDI_PCL730=m
# CONFIG_COMEDI_PCM3724 is not set
# CONFIG_COMEDI_AMPLC_DIO200_ISA is not set
CONFIG_COMEDI_AMPLC_PC236_ISA=m
CONFIG_COMEDI_AMPLC_PC263_ISA=m
CONFIG_COMEDI_RTI800=m
CONFIG_COMEDI_RTI802=m
# CONFIG_COMEDI_DAC02 is not set
CONFIG_COMEDI_DAS16M1=m
# CONFIG_COMEDI_DAS08_ISA is not set
# CONFIG_COMEDI_DAS800 is not set
# CONFIG_COMEDI_DAS6402 is not set
# CONFIG_COMEDI_DT2801 is not set
CONFIG_COMEDI_DT2811=m
CONFIG_COMEDI_DT2814=m
CONFIG_COMEDI_DT2815=m
# CONFIG_COMEDI_DT2817 is not set
CONFIG_COMEDI_DMM32AT=m
# CONFIG_COMEDI_UNIOXX5 is not set
CONFIG_COMEDI_FL512=m
# CONFIG_COMEDI_AIO_AIO12_8 is not set
CONFIG_COMEDI_AIO_IIRO_16=m
CONFIG_COMEDI_II_PCI20KC=m
CONFIG_COMEDI_C6XDIGIO=m
CONFIG_COMEDI_MPC624=m
CONFIG_COMEDI_ADQ12B=m
CONFIG_COMEDI_NI_AT_AO=m
# CONFIG_COMEDI_NI_ATMIO is not set
CONFIG_COMEDI_NI_ATMIO16D=m
# CONFIG_COMEDI_NI_LABPC_ISA is not set
CONFIG_COMEDI_PCMAD=m
CONFIG_COMEDI_PCMDA12=m
CONFIG_COMEDI_PCMMIO=m
CONFIG_COMEDI_PCMUIO=m
CONFIG_COMEDI_MULTIQ3=m
# CONFIG_COMEDI_S526 is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
# CONFIG_COMEDI_PCMCIA_DRIVERS is not set
CONFIG_COMEDI_USB_DRIVERS=y
CONFIG_COMEDI_DT9812=m
CONFIG_COMEDI_NI_USB6501=m
CONFIG_COMEDI_USBDUX=m
CONFIG_COMEDI_USBDUXFAST=m
CONFIG_COMEDI_USBDUXSIGMA=m
# CONFIG_COMEDI_VMK80XX is not set
CONFIG_COMEDI_8255=m
CONFIG_COMEDI_KCOMEDILIB=m
CONFIG_COMEDI_AMPLC_PC236=m
# CONFIG_PANEL is not set
# CONFIG_RTS5208 is not set
# CONFIG_BCM_WIMAX is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
CONFIG_TOUCHSCREEN_CLEARPAD_TM1217=y
CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4=y
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_LTE_GDM724X is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
# CONFIG_GS_FPGABOOT is not set
CONFIG_CRYPTO_SKEIN=y
CONFIG_CRYPTO_THREEFISH=y
# CONFIG_UNISYSSPAR is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=m
CONFIG_CHROMEOS_PSTORE=y

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SOC_TI is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=m
CONFIG_EXTCON_MAX14577=m
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_PALMAS=m
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=y
CONFIG_MEMORY=y
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_LP3943=m
CONFIG_PWM_LPSS=m
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_TWL=y
CONFIG_PWM_TWL_LED=m
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=m
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=m
# CONFIG_MCB is not set
# CONFIG_THUNDERBOLT is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_MEMCONSOLE=m

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
# CONFIG_EXT2_FS_POSIX_ACL is not set
# CONFIG_EXT2_FS_SECURITY is not set
CONFIG_EXT2_FS_XIP=y
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_USE_FOR_EXT23 is not set
# CONFIG_EXT4_FS_POSIX_ACL is not set
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_DEBUG=y
CONFIG_FS_XIP=y
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
CONFIG_JFS_STATISTICS=y
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
CONFIG_XFS_WARN=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
CONFIG_NILFS2_FS=m
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=m
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=m
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=m

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_VFAT_FS is not set
CONFIG_FAT_DEFAULT_CODEPAGE=437
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_SYSCTL is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=m
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=m
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=m
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=m
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=m
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=m
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=m
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=m
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=m

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
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
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_TIMER_STATS=y
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
CONFIG_DEBUG_PI_LIST=y
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST_RUNNABLE=y
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_VERBOSE=y
# CONFIG_RCU_CPU_STALL_INFO is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_LKDTM=m
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_INTERVAL_TREE_TEST=m
# CONFIG_PERCPU_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=m
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_LKM=m
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
# CONFIG_TEST_FIRMWARE is not set
CONFIG_TEST_UDELAY=m
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_SET_MODULE_RONX=y
CONFIG_DEBUG_NX_TEST=m
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
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
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
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
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
# CONFIG_CRYPTO_HMAC is not set
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=m
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=m
CONFIG_CRYPTO_SHA1_MB=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=m
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=m
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_DES3_EDE_X86_64=m
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
# CONFIG_CRYPTO_DRBG_HMAC is not set
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
# CONFIG_CRYPTO_DEV_PADLOCK_AES is not set
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=m
# CONFIG_PKCS7_TEST_KEY is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_BINARY_PRINTF is not set

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
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=m
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_ARCH_HAS_SG_CHAIN=y

--nHwqXXcoX0o6fKCv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--nHwqXXcoX0o6fKCv--
