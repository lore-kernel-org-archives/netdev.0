From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [rhashtable] WARNING: CPU: 0 PID: 1 at lib/debugobjects.c:301
 __debug_object_init()
Date: Tue, 14 Jul 2015 13:21:36 +0800
Message-ID: <20150714052136.GA20251@wfg-t540p.sh.intel.com>
References: <20150714051957.GB19723@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LKP <lkp@01.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37388 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751858AbbGNFWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 01:22:11 -0400
Content-Disposition: inline
In-Reply-To: <20150714051957.GB19723@wfg-t540p.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry please ignore -- this no longer happen in linux-next, so should be fine.

On Tue, Jul 14, 2015 at 01:19:57PM +0800, Fengguang Wu wrote:
> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> 
> commit 97defe1ecf868b8127f8e62395499d6a06e4c4b1
> Author:     Thomas Graf <tgraf@suug.ch>
> AuthorDate: Fri Jan 2 23:00:20 2015 +0100
> Commit:     David S. Miller <davem@davemloft.net>
> CommitDate: Sat Jan 3 14:32:57 2015 -0500
> 
>     rhashtable: Per bucket locks & deferred expansion/shrinking
>     
>     Introduces an array of spinlocks to protect bucket mutations. The number
>     of spinlocks per CPU is configurable and selected based on the hash of
>     the bucket. This allows for parallel insertions and removals of entries
>     which do not share a lock.
>     
>     The patch also defers expansion and shrinking to a worker queue which
>     allows insertion and removal from atomic context. Insertions and
>     deletions may occur in parallel to it and are only held up briefly
>     while the particular bucket is linked or unzipped.
>     
>     Mutations of the bucket table pointer is protected by a new mutex, read
>     access is RCU protected.
>     
>     In the event of an expansion or shrinking, the new bucket table allocated
>     is exposed as a so called future table as soon as the resize process
>     starts.  Lookups, deletions, and insertions will briefly use both tables.
>     The future table becomes the main table after an RCU grace period and
>     initial linking of the old to the new table was performed. Optimization
>     of the chains to make use of the new number of buckets follows only the
>     new table is in use.
>     
>     The side effect of this is that during that RCU grace period, a bucket
>     traversal using any rht_for_each() variant on the main table will not see
>     any insertions performed during the RCU grace period which would at that
>     point land in the future table. The lookup will see them as it searches
>     both tables if needed.
>     
>     Having multiple insertions and removals occur in parallel requires nelems
>     to become an atomic counter.
>     
>     Signed-off-by: Thomas Graf <tgraf@suug.ch>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> +------------------------------------------------------+------------+------------+------------+
> |                                                      | 113948d841 | 97defe1ecf | 05016b0f0a |
> +------------------------------------------------------+------------+------------+------------+
> | boot_successes                                       | 61         | 0          | 0          |
> | boot_failures                                        | 27         | 22         | 1931       |
> | WARNING:at_net/netlink/genetlink.c:#genl_unbind()    | 27         | 1          |            |
> | backtrace:do_group_exit                              | 27         | 1          |            |
> | backtrace:SyS_exit_group                             | 27         | 1          |            |
> | WARNING:at_lib/debugobjects.c:#__debug_object_init() | 0          | 22         | 1931       |
> | backtrace:__debug_object_init                        | 0          | 22         | 1931       |
> | backtrace:warn_slowpath_null                         | 0          | 22         | 1931       |
> | backtrace:debug_object_init                          | 0          | 22         | 1931       |
> | backtrace:__init_work                                | 0          | 22         | 1931       |
> | backtrace:rhashtable_init                            | 0          | 22         | 1931       |
> | backtrace:test_rht_init                              | 0          | 22         | 1931       |
> | backtrace:kernel_init_freeable                       | 0          | 22         | 1931       |
> | backtrace:init_timer_key                             | 0          | 22         |            |
> | RIP:__asan_load8                                     | 0          | 0          | 6          |
> | Kernel_panic-not_syncing:softlockup:hung_tasks       | 0          | 0          | 18         |
> | backtrace:erase_augmented                            | 0          | 0          | 4          |
> | backtrace:rbtree_test_init                           | 0          | 0          | 18         |
> | RIP:__asan_loadN                                     | 0          | 0          | 4          |
> | backtrace:insert_augmented                           | 0          | 0          | 5          |
> | RIP:__asan_load4                                     | 0          | 0          | 2          |
> | backtrace:apic_timer_interrupt                       | 0          | 0          | 6          |
> | RIP:insert_augmented                                 | 0          | 0          | 2          |
> | backtrace:rb_erase                                   | 0          | 0          | 1          |
> | invoked_oom-killer:gfp_mask=0x                       | 0          | 0          | 29         |
> | Mem-Info                                             | 0          | 0          | 29         |
> | Out_of_memory:Kill_process                           | 0          | 0          | 29         |
> | backtrace:__mm_populate                              | 0          | 0          | 24         |
> | backtrace:SyS_mlockall                               | 0          | 0          | 23         |
> | backtrace:vm_mmap_pgoff                              | 0          | 0          | 2          |
> | backtrace:SyS_mmap_pgoff                             | 0          | 0          | 2          |
> | backtrace:SyS_mmap                                   | 0          | 0          | 2          |
> | backtrace:SyS_brk                                    | 0          | 0          | 1          |
> | backtrace:SyS_mlock                                  | 0          | 0          | 2          |
> | backtrace:insert                                     | 0          | 0          | 2          |
> | RIP:__rb_insert_augmented                            | 0          | 0          | 2          |
> | RIP:rb_erase                                         | 0          | 0          | 1          |
> | RIP:__asan_store8                                    | 0          | 0          | 1          |
> +------------------------------------------------------+------------+------------+------------+
> 
> [    0.067580] Running resizable hashtable tests...
> [    0.068019] ODEBUG: object is on stack, but not annotated
> [    0.068499] ------------[ cut here ]------------
> [    0.068917] WARNING: CPU: 0 PID: 1 at lib/debugobjects.c:301 __debug_object_init+0x4a5/0x51c()
> [    0.069833] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.19.0-rc2-00323-g97defe1 #1
> [    0.070000]  0000000000000000 ffff880000167b18 ffffffff819a17c8 0000000000000000
> [    0.070000]  0000000000000009 ffff880000167b58 ffffffff8108e5fd ffff880000167b78
> [    0.070000]  ffffffff81344308 00000000000e0b40 ffff880000167d20 ffff880000040528
> [    0.070000] Call Trace:
> [    0.070000]  [<ffffffff819a17c8>] dump_stack+0x7f/0xa7
> [    0.070000]  [<ffffffff8108e5fd>] warn_slowpath_common+0xc6/0xdf
> [    0.070000]  [<ffffffff81344308>] ? __debug_object_init+0x4a5/0x51c
> [    0.070000]  [<ffffffff8108e6c4>] warn_slowpath_null+0x15/0x17
> [    0.070000]  [<ffffffff81344308>] __debug_object_init+0x4a5/0x51c
> [    0.070000]  [<ffffffff8132b764>] ? rhashtable_init+0x199/0x263
> [    0.070000]  [<ffffffff813443aa>] debug_object_init+0x2b/0x2d
> [    0.070000]  [<ffffffff810aec83>] __init_work+0x32/0x34
> [    0.070000]  [<ffffffff8132b7a5>] rhashtable_init+0x1da/0x263
> [    0.070000]  [<ffffffff82686321>] ? test_rht_lookup+0x127/0x127
> [    0.070000]  [<ffffffff826863af>] test_rht_init+0x8e/0x7ba
> [    0.070000]  [<ffffffff813299c2>] ? percpu_ida_free_tags+0x40/0x40
> [    0.070000]  [<ffffffff81329aec>] ? jhash+0x12a/0x12a
> [    0.070000]  [<ffffffff81329b04>] ? rht_grow_above_75+0x18/0x18
> [    0.070000]  [<ffffffff813299c2>] ? percpu_ida_free_tags+0x40/0x40
> [    0.070000]  [<ffffffff81329aec>] ? jhash+0x12a/0x12a
> [    0.070000]  [<ffffffff81329b04>] ? rht_grow_above_75+0x18/0x18
> [    0.070000]  [<ffffffff82686321>] ? test_rht_lookup+0x127/0x127
> [    0.070000]  [<ffffffff8264b4d6>] do_one_initcall+0x195/0x29d
> [    0.070000]  [<ffffffff810b8a74>] ? parse_args+0x45c/0x599
> [    0.070000]  [<ffffffff8264b7f2>] kernel_init_freeable+0x214/0x2d4
> [    0.070000]  [<ffffffff8199a31a>] ? rest_init+0x15f/0x15f
> [    0.070000]  [<ffffffff8199a323>] kernel_init+0x9/0x157
> [    0.070000]  [<ffffffff819aea3c>] ret_from_fork+0x7c/0xb0
> [    0.070000]  [<ffffffff8199a31a>] ? rest_init+0x15f/0x15f
> [    0.070000] ---[ end trace 46f45e814d896ecc ]---
> [    0.070060] ODEBUG: object is on stack, but not annotated
> 
> git bisect start 05016b0f0a9d900e976db7f50a7761c0aefe5a1c v3.19 --
> git bisect  bad d3f180ea1a44aecba1b0dab2a253428e77f906bf  # 08:50      0-     19  Merge tag 'powerpc-3.20-1' of git://git.kernel.org/pub/scm/linux/kernel/git/mpe/linux
> git bisect good 872912352c5be930e9568e5f3b6d73107d9f278d  # 08:55     22+      0  Merge tag 'pm+acpi-3.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm
> git bisect  bad a323ae93a74f669d890926187c68c711895e3454  # 09:00      0-     22  Merge tag 'sound-3.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
> git bisect good 870fd0f5df4e131467612cc46db46fc3b69fd706  # 09:04     22+      0  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jikos/hid
> git bisect  bad c5ce28df0e7c01a1de23c36ebdefcd803f2b6cbb  # 09:09      0-     16  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
> git bisect good 1d9c5d79e6e4385aea6f69c23ba543717434ed70  # 09:14     22+      0  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jikos/livepatching
> git bisect good 29afc4e9a408f2304e09c6dd0dbcfbd2356d0faa  # 09:18     22+      0  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jikos/trivial
> git bisect  bad fd3e646c87ab3f2ba98aa25394581af27cc78dc5  # 09:27      0-     22  net: act_bpf: fix size mismatch on filter preparation
> git bisect  bad e84448d52190413400663736067f826f28a04ad6  # 09:32      0-     22  xen-netfront: refactor skb slot counting
> git bisect  bad 829a3ada9cc7d4c30fa61f8033403fb6c8f8092a  # 09:38      0-      1  geneve: Simplify locking.
> git bisect good a4c9ea5e8fec680134d22aa99b54d1cd8c226ebd  # 09:42     22+     12  geneve: Add Geneve GRO support
> git bisect good 255047b0dca31e6b8ce254481a0b65d559d2ebb8  # 09:46     20+      0  Bluetooth: Add timing information to SMP test case runs
> git bisect good 354f473ee2c5d01c1cf90f747f95218ee3e73e95  # 09:52     22+      0  ath9k: fix typo
> git bisect good d312da293f787e1b19c57acb58e8c1b171c4a04a  # 09:59     22+      0  ixgbe: convert to CYCLECOUNTER_MASK macro.
> git bisect good b8e1943e9f754219bcfb40bac4a605b5348acb25  # 10:03     22+      8  rhashtable: Factor out bucket_tail() function
> git bisect  bad f89bd6f87a53ce5a7d60662429591ebac2745c10  # 10:08      0-     22  rhashtable: Supports for nulls marker
> git bisect good 113948d841e8d78039e5dbbb5248f5b73e99eafa  # 10:12     22+     13  spinlock: Add spin_lock_bh_nested()
> git bisect  bad 97defe1ecf868b8127f8e62395499d6a06e4c4b1  # 10:16      0-     22  rhashtable: Per bucket locks & deferred expansion/shrinking
> # first bad commit: [97defe1ecf868b8127f8e62395499d6a06e4c4b1] rhashtable: Per bucket locks & deferred expansion/shrinking
> git bisect good 113948d841e8d78039e5dbbb5248f5b73e99eafa  # 10:19     66+     27  spinlock: Add spin_lock_bh_nested()
> # extra tests with DEBUG_INFO
> git bisect  bad 97defe1ecf868b8127f8e62395499d6a06e4c4b1  # 10:25      0-     66  rhashtable: Per bucket locks & deferred expansion/shrinking
> # extra tests on HEAD of linux-devel/devel-spot-201507122014
> git bisect good 3afd2c3f65a385c405a084d80431c84b103cb6df  # 10:28     66+     49  0day head guard for 'devel-spot-201507122014'
> # extra tests on tree/branch linus/master
> git bisect good f760b87f8f12eb262f14603e65042996fe03720e  # 10:33     66+      0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> # extra tests on tree/branch linus/master
> git bisect good f760b87f8f12eb262f14603e65042996fe03720e  # 10:33     66+      0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> # extra tests on tree/branch next/master
> git bisect good 2eb62d762a2112579f259903e62ba18d16c51f66  # 10:36     66+     20  Add linux-next specific files for 20150713
> 
> 
> This script may reproduce the error.
> 
> ----------------------------------------------------------------------------
> #!/bin/bash
> 
> kernel=$1
> initrd=yocto-minimal-x86_64.cgz
> 
> wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd
> 
> kvm=(
> 	qemu-system-x86_64
> 	-enable-kvm
> 	-cpu Haswell,+smep,+smap
> 	-kernel $kernel
> 	-initrd $initrd
> 	-m 256
> 	-smp 1
> 	-device e1000,netdev=net0
> 	-netdev user,id=net0
> 	-boot order=nc
> 	-no-reboot
> 	-watchdog i6300esb
> 	-rtc base=localtime
> 	-serial stdio
> 	-display none
> 	-monitor null 
> )
> 
> append=(
> 	hung_task_panic=1
> 	earlyprintk=ttyS0,115200
> 	systemd.log_level=err
> 	debug
> 	apic=debug
> 	sysrq_always_enabled
> 	rcupdate.rcu_cpu_stall_timeout=100
> 	panic=-1
> 	softlockup_panic=1
> 	nmi_watchdog=panic
> 	oops=panic
> 	load_ramdisk=2
> 	prompt_ramdisk=0
> 	console=ttyS0,115200
> 	console=tty0
> 	vga=normal
> 	root=/dev/ram0
> 	rw
> 	drbd.minor_count=8
> )
> 
> "${kvm[@]}" --append "${append[*]}"
> ----------------------------------------------------------------------------
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/lkp                          Intel Corporation

> early console in setup code
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.19.0-rc2-00323-g97defe1 (kbuild@lkp-ib03) (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Tue Jul 14 10:14:59 CST 2015
> [    0.000000] Command line: hung_task_panic=1 earlyprintk=ttyS0,115200 systemd.log_level=err debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kbuild-tests/run-queue/kvm/x86_64-randconfig-a0-07122340/linux-devel:devel-spot-201507122014:97defe1ecf868b8127f8e62395499d6a06e4c4b1:bisect-linux-1/.vmlinuz-97defe1ecf868b8127f8e62395499d6a06e4c4b1-20150714101515-19-ivb41 branch=linux-devel/devel-spot-201507122014 BOOT_IMAGE=/pkg/linux/x86_64-randconfig-a0-07122340/gcc-4.9/97defe1ecf868b8127f8e62395499d6a06e4c4b1/vmlinuz-3.19.0-rc2-00323-g97defe1 drbd.minor_count=8
> [    0.000000] KERNEL supported cpus:
> [    0.000000]   AMD AuthenticAMD
> [    0.000000]   Centaur CentaurHauls
> [    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
> [    0.000000] CPU: Your system may be unstable.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000ffdffff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000ffe0000-0x000000000fffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] Hypervisor detected: KVM
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn = 0xffe0 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: write-back
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF uncachable
> [    0.000000]   C0000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 0080000000 mask FF80000000 uncachable
> [    0.000000]   1 disabled
> [    0.000000]   2 disabled
> [    0.000000]   3 disabled
> [    0.000000]   4 disabled
> [    0.000000]   5 disabled
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
> [    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> [    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
> [    0.000000] found SMP MP-table at [mem 0x000f0e90-0x000f0e9f] mapped at [ffff8800000f0e90]
> [    0.000000]   mpc: f0ea0-f0fa8
> [    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] BRK [0x03591000, 0x03591fff] PGTABLE
> [    0.000000] BRK [0x03592000, 0x03592fff] PGTABLE
> [    0.000000] BRK [0x03593000, 0x03593fff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
> [    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 2M
> [    0.000000] init_memory_mapping: [mem 0x0c000000-0x0f9fffff]
> [    0.000000]  [mem 0x0c000000-0x0f9fffff] page 2M
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
> [    0.000000]  [mem 0x00100000-0x001fffff] page 4k
> [    0.000000]  [mem 0x00200000-0x0bffffff] page 2M
> [    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0ffdffff]
> [    0.000000]  [mem 0x0fc00000-0x0fdfffff] page 2M
> [    0.000000]  [mem 0x0fe00000-0x0ffdffff] page 4k
> [    0.000000] BRK [0x03594000, 0x03594fff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x0fcce000-0x0ffd7fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000000F0CB0 000014 (v00 BOCHS )
> [    0.000000] ACPI: RSDT 0x000000000FFE1854 000034 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACP 0x000000000FFE0B37 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
> [    0.000000] ACPI: DSDT 0x000000000FFE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACS 0x000000000FFE0000 000040
> [    0.000000] ACPI: SSDT 0x000000000FFE0BAB 000BF9 (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: APIC 0x000000000FFE17A4 000078 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
> [    0.000000] ACPI: HPET 0x000000000FFE181C 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at [mem 0x0000000000000000-0x000000000ffdffff]
> [    0.000000] NODE_DATA(0) allocated [mem 0x0ffdc000-0x0ffdffff]
> [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> [    0.000000] kvm-clock: cpu 0, msr 0:ffdb001, primary cpu clock
> [    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000f000000-ffff88000f3fffff] on node 0
> [    0.000000] Zone ranges:
> [    0.000000]   DMA32    [mem 0x00001000-0x0ffdffff]
> [    0.000000]   Normal   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00001000-0x0009efff]
> [    0.000000]   node   0: [mem 0x00100000-0x0ffdffff]
> [    0.000000] Initmem setup node 0 [mem 0x00001000-0x0ffdffff]
> [    0.000000] On node 0 totalpages: 65406
> [    0.000000]   DMA32 zone: 1024 pages used for memmap
> [    0.000000]   DMA32 zone: 21 pages reserved
> [    0.000000]   DMA32 zone: 65406 pages, LIFO batch:15
> [    0.000000] ACPI: PM-Timer IO Port: 0x608
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
> [    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC INT 02
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
> [    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC INT 05
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC INT 09
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
> [    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC INT 0a
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
> [    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC INT 0b
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC INT 01
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC INT 03
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC INT 04
> [    0.000000] ACPI: IRQ5 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC INT 06
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC INT 07
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC INT 08
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] ACPI: IRQ10 used by override.
> [    0.000000] ACPI: IRQ11 used by override.
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC INT 0c
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC INT 0d
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC INT 0e
> [    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC INT 0f
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
> [    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
> [    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
> [    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:1 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88000fa00000 s84288 r0 d30400 u2097152
> [    0.000000] pcpu-alloc: s84288 r0 d30400 u2097152 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 0 
> [    0.000000] KVM setup async PF for cpu 0
> [    0.000000] kvm-stealtime: cpu 0, msr fa0ce00
> [    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 64361
> [    0.000000] Policy zone: DMA32
> [    0.000000] Kernel command line: hung_task_panic=1 earlyprintk=ttyS0,115200 systemd.log_level=err debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kbuild-tests/run-queue/kvm/x86_64-randconfig-a0-07122340/linux-devel:devel-spot-201507122014:97defe1ecf868b8127f8e62395499d6a06e4c4b1:bisect-linux-1/.vmlinuz-97defe1ecf868b8127f8e62395499d6a06e4c4b1-20150714101515-19-ivb41 branch=linux-devel/devel-spot-201507122014 BOOT_IMAGE=/pkg/linux/x86_64-randconfig-a0-07122340/gcc-4.9/97defe1ecf868b8127f8e62395499d6a06e4c4b1/vmlinuz-3.19.0-rc2-00323-g97defe1 drbd.minor_count=8
> [    0.000000] sysrq: sysrq always enabled.
> [    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
> [    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340 using standard form
> [    0.000000] Memory: 215660K/261624K available (9929K kernel code, 6348K rwdata, 5848K rodata, 1100K init, 14608K bss, 45964K reserved, 0K cma-reserved)
> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=1
> [    0.000000] Running RCU self tests
> [    0.000000] NR_IRQS:4352 nr_irqs:256 16
> [    0.000000] console [ttyS0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
> [    0.000000] ... CHAINHASH_SIZE:          32768
> [    0.000000]  memory used by lock dependency info: 8159 kB
> [    0.000000]  per task-struct memory footprint: 1920 bytes
> [    0.000000] ------------------------
> [    0.000000] | Locking API testsuite:
> [    0.000000] ----------------------------------------------------------------------------
> [    0.000000]                                  | spin |wlock |rlock |mutex | wsem | rsem |
> [    0.000000]   --------------------------------------------------------------------------
> [    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]   --------------------------------------------------------------------------
> [    0.000000]               recursive read-lock:             |  ok  |             |  ok  |
> [    0.000000]            recursive read-lock #2:             |  ok  |             |  ok  |
> [    0.000000]             mixed read-write-lock:             |  ok  |             |  ok  |
> [    0.000000]             mixed write-read-lock:             |  ok  |             |  ok  |
> [    0.000000]   --------------------------------------------------------------------------
> [    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
> [    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
> [    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
> [    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
> [    0.000000]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
> [    0.000000]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
> [    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
> [    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
> [    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
> [    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
> [    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
> [    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
> [    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
> [    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
> [    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
> [    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
> [    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
> [    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
> [    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
> [    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
> [    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
> [    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
> [    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
> [    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
> [    0.000000]       hard-irq read-recursion/123:  ok  |
> [    0.000000]       soft-irq read-recursion/123:  ok  |
> [    0.000000]       hard-irq read-recursion/132:  ok  |
> [    0.000000]       soft-irq read-recursion/132:  ok  |
> [    0.000000]       hard-irq read-recursion/213:  ok  |
> [    0.000000]       soft-irq read-recursion/213:  ok  |
> [    0.000000]       hard-irq read-recursion/231:  ok  |
> [    0.000000]       soft-irq read-recursion/231:  ok  |
> [    0.000000]       hard-irq read-recursion/312:  ok  |
> [    0.000000]       soft-irq read-recursion/312:  ok  |
> [    0.000000]       hard-irq read-recursion/321:  ok  |
> [    0.000000]       soft-irq read-recursion/321:  ok  |
> [    0.000000]   --------------------------------------------------------------------------
> [    0.000000]   | Wound/wait tests |
> [    0.000000]   ---------------------
> [    0.000000]                   ww api failures:  ok  |  ok  |  ok  |
> [    0.000000]                ww contexts mixing:  ok  |  ok  |
> [    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok  |
> [    0.000000]                locking mismatches:  ok  |  ok  |  ok  |
> [    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
> [    0.000000]            spinlock nest unlocked:  ok  |
> [    0.000000]   -----------------------------------------------------
> [    0.000000]                                  |block | try  |context|
> [    0.000000]   -----------------------------------------------------
> [    0.000000]                           context:  ok  |  ok  |  ok  |
> [    0.000000]                               try:  ok  |  ok  |  ok  |
> [    0.000000]                             block:  ok  |  ok  |  ok  |
> [    0.000000]                          spinlock:  ok  |  ok  |  ok  |
> [    0.000000] -------------------------------------------------------
> [    0.000000] Good, all 253 testcases passed! |
> [    0.000000] ---------------------------------
> [    0.000000] hpet clockevent registered
> [    0.000000] tsc: Detected 2693.506 MHz processor
> [    0.020000] Calibrating delay loop (skipped) preset value.. 5387.01 BogoMIPS (lpj=26935060)
> [    0.020000] pid_max: default: 4096 minimum: 301
> [    0.020000] ACPI: Core revision 20141107
> [    0.020000] ACPI: All ACPI Tables successfully acquired
> [    0.020000] Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
> [    0.020000] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
> [    0.020000] Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
> [    0.020000] Mountpoint-cache hash table entries: 512 (order: 0, 4096 bytes)
> [    0.020000] Initializing cgroup subsys devices
> [    0.020026] Initializing cgroup subsys net_cls
> [    0.020446] Initializing cgroup subsys perf_event
> [    0.020885] Initializing cgroup subsys debug
> [    0.021375] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> [    0.021375] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> [    0.031143] Freeing SMP alternatives memory: 20K (ffffffff82748000 - ffffffff8274d000)
> [    0.035960] Getting VERSION: 1050014
> [    0.036312] Getting VERSION: 1050014
> [    0.036652] Getting ID: 0
> [    0.036905] Getting ID: ff000000
> [    0.037211] Getting LVT0: 8700
> [    0.037502] Getting LVT1: 8400
> [    0.037806] enabled ExtINT on CPU#0
> [    0.038761] ENABLING IO-APIC IRQs
> [    0.039086] init IO_APIC IRQs
> [    0.039365]  apic 0 pin 0 not connected
> [    0.039759] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
> [    0.040040] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
> [    0.040770] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
> [    0.041508] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
> [    0.042249] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
> [    0.042983] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
> [    0.043725] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
> [    0.044466] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
> [    0.045211] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
> [    0.045966] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
> [    0.046698] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
> [    0.047450] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
> [    0.048203] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
> [    0.048953] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
> [    0.050024] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
> [    0.050784] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
> [    0.051536]  apic 0 pin 16 not connected
> [    0.051897]  apic 0 pin 17 not connected
> [    0.052264]  apic 0 pin 18 not connected
> [    0.052623]  apic 0 pin 19 not connected
> [    0.052982]  apic 0 pin 20 not connected
> [    0.053349]  apic 0 pin 21 not connected
> [    0.053710]  apic 0 pin 22 not connected
> [    0.054069]  apic 0 pin 23 not connected
> [    0.054573] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.055105] smpboot: CPU0: GenuineIntel Intel Core Processor (Haswell) (fam: 06, model: 3c, stepping: 01)
> [    0.056030] TSC deadline timer enabled
> [    0.056415] Performance Events: no PMU driver, software events only.
> [    0.058771] x86: Booted up 1 node, 1 CPUs
> [    0.059151] ----------------
> [    0.059420] | NMI testsuite:
> [    0.059683] --------------------
> [    0.059985]   remote IPI:  ok  |
> [    0.060000]    local IPI:  ok  |
> [    0.060000] --------------------
> [    0.060000] Good, all   2 testcases passed! |
> [    0.060000] ---------------------------------
> [    0.060000] smpboot: Total of 1 processors activated (5387.01 BogoMIPS)
> [    0.060000] NMI watchdog: disabled (cpu0): hardware events not enabled
> [    0.060000] devtmpfs: initialized
> [    0.060000] NET: Registered protocol family 16
> [    0.060834] cpuidle: using governor ladder
> [    0.061216] cpuidle: using governor menu
> [    0.061939] ACPI: bus type PCI registered
> [    0.062387] PCI: Using configuration type 1 for base access
> [    0.067580] Running resizable hashtable tests...
> [    0.068019] ODEBUG: object is on stack, but not annotated
> [    0.068499] ------------[ cut here ]------------
> [    0.068917] WARNING: CPU: 0 PID: 1 at lib/debugobjects.c:301 __debug_object_init+0x4a5/0x51c()
> [    0.069833] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.19.0-rc2-00323-g97defe1 #1
> [    0.070000]  0000000000000000 ffff880000167b18 ffffffff819a17c8 0000000000000000
> [    0.070000]  0000000000000009 ffff880000167b58 ffffffff8108e5fd ffff880000167b78
> [    0.070000]  ffffffff81344308 00000000000e0b40 ffff880000167d20 ffff880000040528
> [    0.070000] Call Trace:
> [    0.070000]  [<ffffffff819a17c8>] dump_stack+0x7f/0xa7
> [    0.070000]  [<ffffffff8108e5fd>] warn_slowpath_common+0xc6/0xdf
> [    0.070000]  [<ffffffff81344308>] ? __debug_object_init+0x4a5/0x51c
> [    0.070000]  [<ffffffff8108e6c4>] warn_slowpath_null+0x15/0x17
> [    0.070000]  [<ffffffff81344308>] __debug_object_init+0x4a5/0x51c
> [    0.070000]  [<ffffffff8132b764>] ? rhashtable_init+0x199/0x263
> [    0.070000]  [<ffffffff813443aa>] debug_object_init+0x2b/0x2d
> [    0.070000]  [<ffffffff810aec83>] __init_work+0x32/0x34
> [    0.070000]  [<ffffffff8132b7a5>] rhashtable_init+0x1da/0x263
> [    0.070000]  [<ffffffff82686321>] ? test_rht_lookup+0x127/0x127
> [    0.070000]  [<ffffffff826863af>] test_rht_init+0x8e/0x7ba
> [    0.070000]  [<ffffffff813299c2>] ? percpu_ida_free_tags+0x40/0x40
> [    0.070000]  [<ffffffff81329aec>] ? jhash+0x12a/0x12a
> [    0.070000]  [<ffffffff81329b04>] ? rht_grow_above_75+0x18/0x18
> [    0.070000]  [<ffffffff813299c2>] ? percpu_ida_free_tags+0x40/0x40
> [    0.070000]  [<ffffffff81329aec>] ? jhash+0x12a/0x12a
> [    0.070000]  [<ffffffff81329b04>] ? rht_grow_above_75+0x18/0x18
> [    0.070000]  [<ffffffff82686321>] ? test_rht_lookup+0x127/0x127
> [    0.070000]  [<ffffffff8264b4d6>] do_one_initcall+0x195/0x29d
> [    0.070000]  [<ffffffff810b8a74>] ? parse_args+0x45c/0x599
> [    0.070000]  [<ffffffff8264b7f2>] kernel_init_freeable+0x214/0x2d4
> [    0.070000]  [<ffffffff8199a31a>] ? rest_init+0x15f/0x15f
> [    0.070000]  [<ffffffff8199a323>] kernel_init+0x9/0x157
> [    0.070000]  [<ffffffff819aea3c>] ret_from_fork+0x7c/0xb0
> [    0.070000]  [<ffffffff8199a31a>] ? rest_init+0x15f/0x15f
> [    0.070000] ---[ end trace 46f45e814d896ecc ]---
> [    0.070060] ODEBUG: object is on stack, but not annotated
> [    0.070547] ------------[ cut here ]------------
> [    0.070965] WARNING: CPU: 0 PID: 1 at lib/debugobjects.c:301 __debug_object_init+0x4a5/0x51c()
> [    0.071880] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W      3.19.0-rc2-00323-g97defe1 #1
> [    0.072644]  0000000000000000 ffff880000167ad8 ffffffff819a17c8 0000000000000000
> [    0.073347]  0000000000000009 ffff880000167b18 ffffffff8108e5fd ffff880000167b38
> [    0.074058]  ffffffff81344308 00000000000e0b40 ffff880000167d60 ffff880000040500
> [    0.074767] Call Trace:
> [    0.074993]  [<ffffffff819a17c8>] dump_stack+0x7f/0xa7
> [    0.075452]  [<ffffffff8108e5fd>] warn_slowpath_common+0xc6/0xdf
> [    0.075991]  [<ffffffff81344308>] ? __debug_object_init+0x4a5/0x51c
> [    0.076547]  [<ffffffff8108e6c4>] warn_slowpath_null+0x15/0x17
> [    0.077070]  [<ffffffff81344308>] __debug_object_init+0x4a5/0x51c
> [    0.077615]  [<ffffffff813443aa>] debug_object_init+0x2b/0x2d
> [    0.078126]  [<ffffffff81127a51>] init_timer_key+0x29/0x313
> [    0.078622]  [<ffffffff8132b811>] rhashtable_init+0x246/0x263
> [    0.079133]  [<ffffffff82686321>] ? test_rht_lookup+0x127/0x127
> [    0.079663]  [<ffffffff826863af>] test_rht_init+0x8e/0x7ba
> [    0.080000]  [<ffffffff813299c2>] ? percpu_ida_free_tags+0x40/0x40
> [    0.080000]  [<ffffffff81329aec>] ? jhash+0x12a/0x12a
> [    0.080000]  [<ffffffff81329b04>] ? rht_grow_above_75+0x18/0x18
> [    0.080000]  [<ffffffff813299c2>] ? percpu_ida_free_tags+0x40/0x40
> [    0.080000]  [<ffffffff81329aec>] ? jhash+0x12a/0x12a
> [    0.080000]  [<ffffffff81329b04>] ? rht_grow_above_75+0x18/0x18
> [    0.080000]  [<ffffffff8132a766>] ? rhashtable_shrink+0x1f3/0x1f3
> [    0.080000]  [<ffffffff82686321>] ? test_rht_lookup+0x127/0x127
> [    0.080000]  [<ffffffff8264b4d6>] do_one_initcall+0x195/0x29d
> [    0.080000]  [<ffffffff810b8a74>] ? parse_args+0x45c/0x599
> [    0.080000]  [<ffffffff8264b7f2>] kernel_init_freeable+0x214/0x2d4
> [    0.080000]  [<ffffffff8199a31a>] ? rest_init+0x15f/0x15f
> [    0.080000]  [<ffffffff8199a323>] kernel_init+0x9/0x157
> [    0.080000]  [<ffffffff819aea3c>] ret_from_fork+0x7c/0xb0
> [    0.080000]  [<ffffffff8199a31a>] ? rest_init+0x15f/0x15f
> [    0.080000] ---[ end trace 46f45e814d896ecd ]---
> [    0.080009]   Adding 2048 keys
> [    0.081894]   Traversal complete: counted=2048, nelems=2048, entries=2048
> [    0.099367]   Table expansion iteration 0...
> [    0.100901]   Verifying lookups...
> [    0.110243]   Table expansion iteration 1...
> [    0.111731]   Verifying lookups...
> [    0.117208]   Table expansion iteration 2...
> [    0.119014]   Verifying lookups...
> [    0.122539]   Table expansion iteration 3...
> [    0.124306]   Verifying lookups...
> [    0.126860]   Table shrinkage iteration 0...
> [    0.127488]   Verifying lookups...
> [    0.131006]   Table shrinkage iteration 1...
> [    0.131544]   Verifying lookups...
> [    0.137027]   Table shrinkage iteration 2...
> [    0.137539]   Verifying lookups...
> [    0.146877]   Table shrinkage iteration 3...
> [    0.147369]   Verifying lookups...
> [    0.164947]   Traversal complete: counted=2048, nelems=2048, entries=2048
> [    0.165572]   Deleting 2048 keys
> [    0.173028] ACPI: Added _OSI(Module Device)
> [    0.173420] ACPI: Added _OSI(Processor Device)
> [    0.173817] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.174238] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.176275] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
> [    0.179852] ACPI: Interpreter enabled
> [    0.180011] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20141107/hwxface-580)
> [    0.180861] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20141107/hwxface-580)
> [    0.181728] ACPI: (supports S0 S3 S5)
> [    0.182060] ACPI: Using IOAPIC for interrupt routing
> [    0.182544] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.193079] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    0.193658] acpi PNP0A03:00: _OSC: OS supports [Segments]
> [    0.194190] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    0.195228] PCI host bridge to bus 0000:00
> [    0.195614] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    0.196107] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
> [    0.196654] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff]
> [    0.197202] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff]
> [    0.197749] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf]
> [    0.198300] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff]
> [    0.198846] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
> [    0.199459] pci_bus 0000:00: root bus resource [mem 0x10000000-0xfebfffff]
> [    0.200070] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
> [    0.201225] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
> [    0.202385] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
> [    0.213206] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
> [    0.218001] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
> [    0.218645] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
> [    0.219220] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
> [    0.219854] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
> [    0.220337] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
> [    0.221204] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
> [    0.221846] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
> [    0.222868] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
> [    0.227885] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
> [    0.232187] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
> [    0.252175] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
> [    0.253203] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
> [    0.257976] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
> [    0.262130] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
> [    0.282121] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
> [    0.283113] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
> [    0.289662] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
> [    0.296107] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
> [    0.324095] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
> [    0.330014] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
> [    0.335075] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
> [    0.354703] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
> [    0.359517] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
> [    0.364278] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
> [    0.384758] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
> [    0.389574] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
> [    0.394226] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
> [    0.416914] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
> [    0.420011] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
> [    0.424744] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
> [    0.445314] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
> [    0.450022] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
> [    0.454830] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
> [    0.474752] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
> [    0.479562] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
> [    0.484228] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
> [    0.508787] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
> [    0.511087] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
> [    0.525678] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
> [    0.526448] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
> [    0.527213] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
> [    0.527979] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
> [    0.528647] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
> [    0.529750] ACPI: Enabled 16 GPEs in block 00 to 0F
> [    0.530620] vgaarb: setting as boot device: PCI:0000:00:02.0
> [    0.531404] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
> [    0.532507] vgaarb: loaded
> [    0.532887] vgaarb: bridge control possible 0000:00:02.0
> [    0.534022] pps_core: LinuxPPS API ver. 1 registered
> [    0.534475] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [    0.535289] PTP clock support registered
> [    0.535937] PCI: Using ACPI for IRQ routing
> [    0.536327] PCI: pci_cache_line_size set to 64 bytes
> [    0.536951] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
> [    0.537493] e820: reserve RAM buffer [mem 0x0ffe0000-0x0fffffff]
> [    0.538634] NET: Registered protocol family 23
> [    0.539600] Switched to clocksource kvm-clock
> [    0.540000] Warning: could not register all branches stats
> [    0.540000] Warning: could not register annotated branches stats
> [    0.562817] pnp: PnP ACPI init
> [    0.563211] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
> [    0.564012] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    0.564662] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
> [    0.565443] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
> [    0.566076] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
> [    0.566877] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
> [    0.567530] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
> [    0.568260] pnp 00:03: [dma 2]
> [    0.568597] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
> [    0.569265] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
> [    0.570066] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
> [    0.570724] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
> [    0.571497] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
> [    0.572636] pnp: PnP ACPI: found 6 devices
> [    0.578699] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
> [    0.579199] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff]
> [    0.579701] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff]
> [    0.580217] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf]
> [    0.580723] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff]
> [    0.581225] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
> [    0.581788] pci_bus 0000:00: resource 10 [mem 0x10000000-0xfebfffff]
> [    0.582408] NET: Registered protocol family 2
> [    0.583230] TCP established hash table entries: 2048 (order: 2, 16384 bytes)
> [    0.583936] TCP bind hash table entries: 2048 (order: 5, 131072 bytes)
> [    0.584624] TCP: Hash tables configured (established 2048 bind 2048)
> [    0.585233] TCP: reno registered
> [    0.585539] UDP hash table entries: 128 (order: 2, 20480 bytes)
> [    0.586088] UDP-Lite hash table entries: 128 (order: 2, 20480 bytes)
> [    0.586894] NET: Registered protocol family 1
> [    0.587385] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
> [    0.587929] pci 0000:00:01.0: PIIX3: Enabling Passive Release
> [    0.588456] pci 0000:00:01.0: Activating ISA DMA hang workarounds
> [    0.589029] pci 0000:00:02.0: Video device with shadowed ROM
> [    0.589606] PCI: CLS 0 bytes, default 64
> [    0.590309] Unpacking initramfs...
> [    0.670359] Freeing initrd memory: 3112K (ffff88000fcce000 - ffff88000ffd8000)
> [    0.673391] sha1_ssse3: Using AVX optimized SHA-1 implementation
> [    0.674094] sha256_ssse3: Using AVX optimized SHA-256 implementation
> [    0.677545] futex hash table entries: 16 (order: -1, 2048 bytes)
> [    0.678109] Initialise system trusted keyring
> [    0.685096] page_owner is disabled
> [    0.685419] zbud: loaded
> [    0.687031] DLM installed
> [    0.690859] NET: Registered protocol family 38
> [    0.691285] start plist test
> [    0.696363] end plist test
> [    0.696800] test_firmware: interface ready
> [    0.697536] xz_dec_test: module loaded
> [    0.697888] xz_dec_test: Create a device node with 'mknod xz_dec_test c 251 0' and write .xz files to it.
> [    0.698753] rbtree testing -> 13954 cycles
> [    1.279440] augmented rbtree testing -> 19345 cycles
> [    2.080931] tsc: Refined TSC clocksource calibration: 2693.501 MHz
> [    2.082393] no IO addresses supplied
> [    2.082871] hgafb: HGA card not detected.
> [    2.083255] hgafb: probe of hgafb.0 failed with error -22
> [    2.086116] uvesafb: Getting VBE info block failed (eax=0x10a, err=0)
> [    2.086706] uvesafb: vbe_init() failed with -22
> [    2.087119] uvesafb: probe of uvesafb.0 failed with error -22
> [    2.087709] ipmi message handler version 39.2
> [    2.088111] ipmi device interface
> [    2.088480] IPMI System Interface driver.
> [    2.088924] ipmi_si: Adding default-specified kcs state machine
> [    2.089471] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
> [    2.090505] ipmi_si: Interface detection failed
> [    2.090925] ipmi_si: Adding default-specified smic state machine
> [    2.091476] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
> [    2.092374] ipmi_si: Interface detection failed
> [    2.092788] ipmi_si: Adding default-specified bt state machine
> [    2.093322] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
> [    2.094199] ipmi_si: Interface detection failed
> [    2.094739] ipmi_si: Unable to find any System Interface(s)
> [    2.095245] IPMI SSIF Interface driver
> [    2.095608] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
> [    2.096290] IPMI poweroff: Unable to register powercycle sysctl
> [    2.097077] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
> [    2.097758] ACPI: Power Button [PWRF]
> [    2.134949] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> [    2.160803] serial 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> [    2.162845] ppdev: user-space parallel port driver
> [    2.163284] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
> [    2.164320] dummy-irq: no IRQ given.  Use irq=N
> [    2.164877] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
> [    2.165702] c2port c2port0: C2 port uc added
> [    2.166091] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
> [    2.167191] HSI/SSI char device loaded
> [    2.168258] libphy: Fixed MDIO Bus: probed
> [    2.168982] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
> [    2.169991] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <johns393@maroon.tc.umn.edu>
> [    2.170804] vcan: Virtual CAN interface driver
> [    2.171211] CAN device driver interface
> [    2.171626] cc770: CAN netdevice driver
> [    2.172084] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
> [    2.172719] e1000: Copyright (c) 1999-2006 Intel Corporation.
> [    2.319364] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
> [    2.319909] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
> [    2.662452] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
> [    2.663126] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
> [    2.663837] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
> [    2.664357] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
> [    2.664932] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.2.15-k
> [    2.665552] igb: Copyright (c) 2007-2014 Intel Corporation.
> [    2.666092] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.0.1-k
> [    2.666774] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
> [    2.668275] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
> [    2.669776] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    2.670291] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    2.671087] parkbd: no such parport
> [    2.712484] mousedev: PS/2 mouse device common for all mice
> [    2.713703] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
> [    2.716273] i2c /dev entries driver
> [    2.716830] pps_parport: parallel port PPS client
> [    2.717283] Driver for 1-wire Dallas network protocol.
> [    2.717833] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
> [    2.719009] f71882fg: Not a Fintek device
> [    2.719391] f71882fg: Not a Fintek device
> [    2.721333] CAPI 2.0 started up with major 68 (no middleware)
> [    2.721859] Modular ISDN core version 1.1.29
> [    2.722363] NET: Registered protocol family 34
> [    2.722776] mISDN: Layer-1-over-IP driver Rev. 2.00
> [    2.723397] 0 virtual devices registered
> [    2.724121] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
> [    2.725786]  fake-fmc-carrier: mezzanine 0
> [    2.726164]       Manufacturer: fake-vendor
> [    2.726539]       Product name: fake-design-for-testing
> [    2.727073] fmc fake-design-for-testing-f001: Driver has no ID: matches all
> [    2.727711] fmc_write_eeprom fake-design-for-testing-f001: fmc_write_eeprom: no busid passed, refusing all cards
> [    2.728648] fmc fake-design-for-testing-f001: Driver has no ID: matches all
> [    2.729427] fmc_chardev fake-design-for-testing-f001: Created misc device "fake-design-for-testing-f001"
> [    2.730742] Audio Excel DSP 16 init driver Copyright (C) Riccardo Facchetti 1995-98
> [    2.731420] aedsp16: I/O, IRQ and DMA are mandatory
> [    2.731860] pss: mss_io, mss_dma, mss_irq and pss_io must be set.
> [    2.732392] ad1848/cs4248 codec driver Copyright (C) by Hannu Savolainen 1993-1996
> [    2.733061] ad1848: No ISAPnP cards found, trying standard ones...
> [    2.733603] MediaTrix audio driver Copyright (C) by Hannu Savolainen 1993-1996
> [    2.734237] I/O, IRQ, DMA and type are mandatory
> [    2.734652] sb: Init: Starting Probe...
> [    2.735024] sb: Init: Done
> [    2.735294] Cyrix Kahlua VSA1 XpressAudio support (c) Copyright 2003 Red Hat Inc
> [    2.735981] uart6850: irq and io must be set.
> [    2.736375] MIDI Loopback device driver
> [    2.736935] oprofile: using timer interrupt.
> [    2.737356] pktgen: Packet Generator for packet performance testing. Version: 2.74
> [    2.738185] drop_monitor: Initializing network drop monitor service
> [    2.738822] NET: Registered protocol family 26
> [    2.739254] Netfilter messages via NETLINK v0.30.
> [    2.739708] nfnl_acct: registering with nfnetlink.
> [    2.740235] nf_conntrack version 0.5.0 (1709 buckets, 6836 max)
> [    2.741014] ctnetlink v0.93: registering with nfnetlink.
> [    2.741662] nf_tables: (c) 2007-2009 Patrick McHardy <kaber@trash.net>
> [    2.742556] xt_time: kernel timezone is -0000
> [    2.742973] IPVS: Registered protocols (SCTP, AH, ESP)
> [    2.743577] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
> [    2.744236] IPVS: Each connection entry needs 376 bytes at least
> [    2.744807] IPVS: Creating netns size=1728 id=0
> [    2.745249] IPVS: ipvs loaded.
> [    2.745547] IPVS: [rr] scheduler registered.
> [    2.745941] IPVS: [wrr] scheduler registered.
> [    2.746335] IPVS: [lc] scheduler registered.
> [    2.746727] IPVS: [lblc] scheduler registered.
> [    2.747130] IPVS: [lblcr] scheduler registered.
> [    2.747537] IPVS: [sh] scheduler registered.
> [    2.747926] ipip: IPv4 over IPv4 tunneling driver
> [    2.748769] ip_tables: (C) 2000-2006 Netfilter Core Team
> [    2.749269] arp_tables: (C) 2002 David S. Miller
> [    2.749724] TCP: westwood registered
> [    2.750090] TCP: highspeed registered
> [    2.750428] TCP: htcp registered
> [    2.750737] TCP: vegas registered
> [    2.751040] TCP: veno registered
> [    2.751335] TCP: yeah registered
> [    2.751631] TCP: illinois registered
> [    2.751968] NET: Registered protocol family 17
> [    2.752383] NET: Registered protocol family 15
> [    2.752851] bridge: automatic filtering via arp/ip/ip6tables has been deprecated. Update your scripts to load br_netfilter if you need this
