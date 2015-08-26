From: Phil Sutter <phil@nwl.cc>
Subject: Re: [rhashtable-test] EIP is at lock_is_held
Date: Wed, 26 Aug 2015 13:15:29 +0200
Message-ID: <20150826111529.GF20760@orbit.nwl.cc>
References: <20150824044043.GA30102@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: wfg@linux.intel.com, LKP <lkp@01.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:41567 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756236AbbHZLPc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 07:15:32 -0400
Content-Disposition: inline
In-Reply-To: <20150824044043.GA30102@wfg-t540p.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(Full-quoting here due to added maling lists.)

Looks like this is a problem of slow systems. I will try to reproduce
and come up with a similar fix as in commit 685a015 ("rhashtable: Allow
other tasks to be scheduled in large lookup loops").

Thanks for reporting,

Phil

On Mon, Aug 24, 2015 at 12:40:43PM +0800, Fengguang Wu wrote:
> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git master
> 
> commit f4a3e90ba5739cfd761b6befadae9728bd3641ed
> Author:     Phil Sutter <phil@nwl.cc>
> AuthorDate: Sat Aug 15 00:37:15 2015 +0200
> Commit:     David S. Miller <davem@davemloft.net>
> CommitDate: Mon Aug 17 14:33:47 2015 -0700
> 
>     rhashtable-test: extend to test concurrency
>     
>     After having tested insertion, lookup, table walk and removal, spawn a
>     number of threads running operations on the same rhashtable. Each of
>     them will:
>     
>     1) insert it's own set of objects,
>     2) lookup every successfully inserted object and finally
>     3) remove objects in several rounds until all of them have been removed,
>        making sure the remaining ones are still found after each round.
>     
>     This should put a good amount of load onto the system and due to
>     synchronising thread startup via two semaphores also extensive
>     concurrent table access.
>     
>     The default number of ten threads returned within half a second on my
>     local VM with two cores. Running 200 threads took about four seconds. If
>     slow systems suffer too much from this though, the default could be
>     lowered or even set to zero so this extended test does not run at all by
>     default.
>     
>     Signed-off-by: Phil Sutter <phil@nwl.cc>
>     Acked-by: Thomas Graf <tgraf@suug.ch>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> +----------------------------------------------------+------------+------------+------------+
> |                                                    | c1f066d4ee | f4a3e90ba5 | 6967aa466b |
> +----------------------------------------------------+------------+------------+------------+
> | boot_successes                                     | 1060       | 808        | 106        |
> | boot_failures                                      | 1          | 102        | 21         |
> | INFO:possible_circular_locking_dependency_detected | 1          |            |            |
> | backtrace:vfs_readv                                | 1          |            |            |
> | backtrace:SyS_readv                                | 1          |            |            |
> | backtrace:blk_mq_sysfs_unregister                  | 1          |            |            |
> | backtrace:blk_mq_queue_reinit_notify               | 1          |            |            |
> | backtrace:debug_hotplug_cpu                        | 1          |            |            |
> | backtrace:kernel_init_freeable                     | 1          |            |            |
> | EIP_is_at_lock_is_held                             | 0          | 63         | 16         |
> | Kernel_panic-not_syncing:softlockup:hung_tasks     | 0          | 102        | 19         |
> | backtrace:threadfunc                               | 0          | 101        | 19         |
> | EIP_is_at_rcu_read_lock_held                       | 0          | 10         | 5          |
> | EIP_is_at_rcu_lockdep_current_cpu_online           | 0          | 9          |            |
> | EIP_is_at_thread_lookup_test                       | 0          | 11         | 1          |
> | EIP_is_at_lock_release                             | 0          | 3          |            |
> | EIP_is_at_lockdep_rht_bucket_is_held               | 0          | 3          |            |
> | EIP_is_at_rcu_is_watching                          | 0          | 5          |            |
> | backtrace:apic_timer_interrupt                     | 0          | 3          |            |
> | EIP_is_at_lock_acquire                             | 0          | 12         | 2          |
> | EIP_is_at_jhash                                    | 0          | 11         |            |
> | EIP_is_at_raw_spin_lock_bh                         | 0          | 1          |            |
> | EIP_is_at_debug_lockdep_rcu_enabled                | 0          | 13         |            |
> | EIP_is_at_lockdep_rht_mutex_is_held                | 0          | 3          | 2          |
> | EIP_is_at_raw_spin_unlock_bh                       | 0          | 1          |            |
> | EIP_is_at_do_raw_spin_lock                         | 0          | 1          |            |
> | EIP_is_at__local_bh_enable_ip                      | 0          | 1          |            |
> | EIP_is_at_threadfunc                               | 0          | 1          |            |
> | IP-Config:Auto-configuration_of_network_failed     | 0          | 0          | 2          |
> +----------------------------------------------------+------------+------------+------------+
> 
> [    6.673473] Testing concurrent rhashtable access from 10 threads
> [   32.066733] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [rhashtable_thra:103]
> [   32.068432] irq event stamp: 1362768
> [   32.069045] hardirqs last  enabled at (1362767): [<c2df1f47>] restore_all_notrace+0x0/0x18
> [   32.070037] hardirqs last disabled at (1362768): [<c2df29ab>] apic_timer_interrupt+0x2b/0x40
> [   32.070037] softirqs last  enabled at (1362766): [<c11086ff>] __do_softirq+0x2af/0x380
> [   32.070037] softirqs last disabled at (1362761): [<c1072d5b>] do_softirq_own_stack+0x2b/0x40
> [   32.070037] CPU: 0 PID: 103 Comm: rhashtable_thra Not tainted 4.2.0-rc6-00979-gf4a3e90 #1
> [   32.070037] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   32.070037] task: cb1acf80 ti: c0054000 task.ti: c0054000
> [   32.070037] EIP: 0060:[<c1188b82>] EFLAGS: 00000246 CPU: 0
> [   32.070037] EIP is at lock_is_held+0xb2/0xe0
> [   32.070037] EAX: 00000246 EBX: 00000246 ECX: 00000001 EDX: c385ee50
> [   32.070037] ESI: 00000001 EDI: 00000000 EBP: c0055ea8 ESP: c0055ea0
> [   32.070037]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [   32.070037] CR0: 8005003b CR2: ffffffff CR3: 03cfa000 CR4: 000006b0
> [   32.070037] Stack:
> [   32.083360] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [rhashtable_thra:109]
> [   32.083362] irq event stamp: 1377938
> [   32.083372] hardirqs last  enabled at (1377937): [<c2df1f47>] restore_all_notrace+0x0/0x18
> [   32.083376] hardirqs last disabled at (1377938): [<c2df29ab>] apic_timer_interrupt+0x2b/0x40
> [   32.083380] softirqs last  enabled at (1377936): [<c11086ff>] __do_softirq+0x2af/0x380
> [   32.083384] softirqs last disabled at (1377933): [<c1072d5b>] do_softirq_own_stack+0x2b/0x40
> [   32.083388] CPU: 1 PID: 109 Comm: rhashtable_thra Not tainted 4.2.0-rc6-00979-gf4a3e90 #1
> [   32.083389] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   32.083391] task: cb1a9a80 ti: ca914000 task.ti: ca914000
> [   32.083394] EIP: 0060:[<c173ff3e>] EFLAGS: 00000246 CPU: 1
> [   32.083399] EIP is at lockdep_rht_mutex_is_held+0xe/0x50
> [   32.083401] EAX: c46d3880 EBX: cb1f4000 ECX: 00000001 EDX: 00000001
> [   32.083402] ESI: 300003f1 EDI: 00000000 EBP: ca915eec ESP: ca915eb4
> [   32.083403]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [   32.083405] CR0: 8005003b CR2: 00000000 CR3: 03cfa000 CR4: 000006b0
> [   32.083410] Stack:
> [   32.083415]  c17470a3 00000000 d35ec050 d35ec048 000001f8 300003f1 0004c780 000098f0
> [   32.083420]  000698f0 c46d3880 ca915ed4 00000000 d3899974 c0100000 ca915f34 c1748215
> [   32.083424]  d35ec050 00000030 00000006 00000000 d35ec048 00061aa0 0000c354 d3899970
> [   32.083424] Call Trace:
> [   32.083429]  [<c17470a3>] ? thread_lookup_test+0x683/0x7f0
> [   32.083432]  [<c1748215>] threadfunc+0x1005/0x1550
> [   32.083434]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.083436]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.083440]  [<c113cd37>] kthread+0x127/0x170
> [   32.083443]  [<c2df1d81>] ret_from_kernel_thread+0x21/0x30
> [   32.083445]  [<c113cc10>] ? __kthread_unpark+0xd0/0xd0
> [   32.083479] Code: 0d 6b 01 83 05 d8 fb 6c c4 01 83 15 dc fb 6c c4 00 b8 ef ff ff ff 5b 5e 5d c3 8d 76 00 83 05 68 e0 6c c4 01 83 15 6c e0 6c c4 00 <8b> 15 d4 a5 8d c3 85 d2 75 08 b8 01 00 00 00 c3 66 90 55 89 e5
> [   32.083536] Kernel panic - not syncing: softlockup: hung tasks
> [   32.083540] CPU: 1 PID: 109 Comm: rhashtable_thra Tainted: G             L  4.2.0-rc6-00979-gf4a3e90 #1
> [   32.083541] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   32.083547]  00000000 ca915db4 c2dc56f2 00000016 ca915dcc c2dc082b ee6b2800 00000016
> [   32.083553]  ee6b2800 00000000 ca915df0 c1217583 c359d4c6 ca915e78 00000000 00000007
> [   32.083559]  d1381800 d13813a0 c12171d0 ca915e24 c11cf4b3 00000000 7850e875 00000007
> [   32.083559] Call Trace:
> [   32.083563]  [<c2dc56f2>] dump_stack+0xb8/0x108
> [   32.083565]  [<c2dc082b>] panic+0x12b/0x3e6
> [   32.083570]  [<c1217583>] watchdog_timer_fn+0x3b3/0x430
> [   32.083572]  [<c12171d0>] ? watchdog+0x70/0x70
> [   32.083578]  [<c11cf4b3>] __hrtimer_run_queues+0x123/0x2e0
> [   32.083581]  [<c11d07a4>] hrtimer_interrupt+0xc4/0x2c0
> [   32.083584]  [<c1186ef7>] ? trace_hardirqs_off+0x27/0x40
> [   32.083587]  [<c11c7a3a>] ? rcu_irq_enter+0x14a/0x160
> [   32.083590]  [<c10c8117>] local_apic_timer_interrupt+0x37/0x90
> [   32.083593]  [<c10c8d28>] smp_apic_timer_interrupt+0x58/0x90
> [   32.083596]  [<c2df29b2>] apic_timer_interrupt+0x32/0x40
> [   32.083599]  [<c173ff3e>] ? lockdep_rht_mutex_is_held+0xe/0x50
> [   32.083601]  [<c17470a3>] ? thread_lookup_test+0x683/0x7f0
> [   32.083604]  [<c1748215>] threadfunc+0x1005/0x1550
> [   32.083606]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.083608]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.083611]  [<c113cd37>] kthread+0x127/0x170
> [   32.083614]  [<c2df1d81>] ret_from_kernel_thread+0x21/0x30
> [   32.083616]  [<c113cc10>] ? __kthread_unpark+0xd0/0xd0
> [   32.070037]  d0984000 300000bd c0055eb0 c11bef6d c0055eec c1746eb1 00000000 d35ec008
> [   32.070037]  d35ec000 0000005e 300000bd 0000d030 00001a06 00001a06 c46d3880 c0055ed4
> [   32.070037]  00000000 d364fa74 c0100000 c0055f34 c1748215 d35ec008 00000030 00000006
> [   32.070037] Call Trace:
> [   32.070037]  [<c11bef6d>] rcu_read_lock_held+0xdd/0xf0
> [   32.070037]  [<c1746eb1>] thread_lookup_test+0x491/0x7f0
> [   32.070037]  [<c1748215>] threadfunc+0x1005/0x1550
> [   32.070037]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.070037]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.070037]  [<c113cd37>] kthread+0x127/0x170
> [   32.070037]  [<c2df1d81>] ret_from_kernel_thread+0x21/0x30
> [   32.070037]  [<c113cc10>] ? __kthread_unpark+0xd0/0xd0
> [   32.070037] Code: 89 f0 e8 d2 fe ff ff 89 c6 83 05 28 2e ec c3 01 83 15 2c 2e ec c3 00 64 a1 28 38 ce c3 c7 80 10 04 00 00 00 00 00 00 89 d8 50 9d <8d> 74 26 00 83 05 30 2e ec c3 01 83 15 34 2e ec c3 00 89 f0 5b
> [   32.086676] Shutting down cpus with NMI
> [   32.086676] Kernel Offset: disabled
> 
> 
> git bisect start 6967aa466b743f215b75a55d046ab4062d716ad5 2c6625cd545bdd66acff14f3394865d43920a5c7 --
> git bisect good cbf6b6653e9a289d010d9a1b66a2397849821191  # 04:21    910+      2  Merge 'kees/format-security' into devel-spot-201508210128
> git bisect good 9ecca26e13e2d7ff423ae1d092413c629412035b  # 04:56    908+      0  Merge 'xen-tip/for-linus-4.3' into devel-spot-201508210128
> git bisect good b5263785bfb0e5434cdb51bd21a82de2ebe1c676  # 05:49    910+      3  Merge 'tip/perf/urgent' into devel-spot-201508210128
> git bisect good b7a0925e47031d51041ce9a357edc02fb67d0b1d  # 06:13    910+      0  Merge tag 'wireless-drivers-next-for-davem-2015-07-31' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
> git bisect good 90eb7fa51ccb9af58c437581af73c4a1d5fd2b9f  # 06:44    910+      0  Merge branch 'bpf_fanout'
> git bisect  bad 4afbc0db720555f1bf0dd9f3e112819041231818  # 06:44      0-     53  net: 6lowpan: convert to using IFF_NO_QUEUE
> git bisect good c1f066d4ee0bde4bb0ff4ac295218b631729e0de  # 07:32    910+      0  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge
> git bisect good c0015bf3a34961342a27b021672049e535ab36a1  # 08:13    910+      0  ieee802154: 6lowpan: fix non-lowpan wpan interfaces
> git bisect  bad 2f52bdcf6ba1bd81597b1505a222430676548b3a  # 08:22    107-     56  net: Updates to netif_index_is_vrf
> git bisect  bad 0aa65cc0c2ca7e3908b1e4ae7946d909a4882249  # 08:34     94-     23  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next
> git bisect  bad 8b89f3a19de05992a70f727072b65f3ea1397075  # 08:51    118-     24  enic: move struct definition from .c to .h file
> git bisect  bad ec120da6f0fe59f175c2a8faa0a7700280c39644  # 09:26    414-     73  ipv6: trivial whitespace fix
> git bisect  bad f4a3e90ba5739cfd761b6befadae9728bd3641ed  # 09:42    172-     22  rhashtable-test: extend to test concurrency
> # first bad commit: [f4a3e90ba5739cfd761b6befadae9728bd3641ed] rhashtable-test: extend to test concurrency
> git bisect good c1f066d4ee0bde4bb0ff4ac295218b631729e0de  # 09:48   1003+      0  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge
> # extra tests with DEBUG_INFO
> git bisect  bad f4a3e90ba5739cfd761b6befadae9728bd3641ed  # 09:57     21-      5  rhashtable-test: extend to test concurrency
> # extra tests on HEAD of linux-devel/devel-spot-201508210128
> git bisect  bad abe5543dfd124681d7c508588c300abb84972558  # 10:40    166-     70  0day head guard for 'devel-spot-201508210128'
> # extra tests on tree/branch jkirsher-next-queue/master
> # extra tests with first bad commit reverted
> # extra tests on tree/branch linus/master
> git bisect good e525293d97b93a04038e7dc15cee3e9075c32dbd  # 12:17   1010+      2  Add hch to .get_maintainer.ignore
> # extra tests on tree/branch linux-next/master
> git bisect  bad 1ef981bcd18de26dc78bc79f092d6f4bb25e0e8f  # 12:28      8-      4  Add linux-next specific files for 20150821
> 
> 
> This script may reproduce the error.
> 
> ----------------------------------------------------------------------------
> #!/bin/bash
> 
> kernel=$1
> initrd=quantal-core-i386.cgz
> 
> wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd
> 
> kvm=(
> 	qemu-system-x86_64
> 	-enable-kvm
> 	-cpu kvm64
> 	-kernel $kernel
> 	-initrd $initrd
> 	-m 300
> 	-smp 2
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
> early console in decompress_kernel
> 
> Decompressing Linux... Parsing ELF... done.
> Booting the kernel.
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 4.2.0-rc6-00979-gf4a3e90 (kbuild@lkp-ib03) (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Sat Aug 22 09:33:38 CST 2015
> [    0.000000] x86/fpu: Legacy x87 FPU detected.
> [    0.000000] x86/fpu: Using 'lazy' FPU context switches.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000012bdffff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000012be0000-0x0000000012bfffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.8 present.
> [    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [    0.000000] Hypervisor detected: KVM
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn = 0x12be0 max_arch_pfn = 0x1000000
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
> [    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC  
> [    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
> [    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> [    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
> [    0.000000] found SMP MP-table at [mem 0x000f0e80-0x000f0e8f] mapped at [c00f0e80]
> [    0.000000]   mpc: f0e90-f0fac
> [    0.000000] initial memory mapped: [mem 0x00000000-0x059fffff]
> [    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x11000000-0x111fffff]
> [    0.000000]  [mem 0x11000000-0x111fffff] page 4k
> [    0.000000] BRK [0x054fe000, 0x054fefff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x10ffffff]
> [    0.000000]  [mem 0x00100000-0x10ffffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x11200000-0x12bdffff]
> [    0.000000]  [mem 0x11200000-0x12bdffff] page 4k
> [    0.000000] BRK [0x054ff000, 0x054fffff] PGTABLE
> [    0.000000] BRK [0x05500000, 0x05500fff] PGTABLE
> [    0.000000] BRK [0x05501000, 0x05501fff] PGTABLE
> [    0.000000] BRK [0x05502000, 0x05502fff] PGTABLE
> [    0.000000] BRK [0x05503000, 0x05503fff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x11393000-0x12bd7fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000000F0C60 000014 (v00 BOCHS )
> [    0.000000] ACPI: RSDT 0x0000000012BE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACP 0x0000000012BE0B37 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
> [    0.000000] ACPI: DSDT 0x0000000012BE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACS 0x0000000012BE0000 000040
> [    0.000000] ACPI: SSDT 0x0000000012BE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: APIC 0x0000000012BE1805 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
> [    0.000000] ACPI: HPET 0x0000000012BE1885 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to         ffffb000 (        fee00000)
> [    0.000000] 0MB HIGHMEM available.
> [    0.000000] 299MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 12be0000
> [    0.000000]   low ram: 0 - 12be0000
> [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> [    0.000000] kvm-clock: cpu 0, msr 0:12bd9001, primary cpu clock
> [    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   Normal   [mem 0x0000000001000000-0x0000000012bdffff]
> [    0.000000]   HighMem  empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x0000000012bdffff]
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000012bdffff]
> [    0.000000] On node 0 totalpages: 76670
> [    0.000000] free_area_init_node: node 0, pgdat c3b91540, node_mem_map d0f45020
> [    0.000000]   DMA zone: 32 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> [    0.000000]   Normal zone: 568 pages used for memmap
> [    0.000000]   Normal zone: 72672 pages, LIFO batch:15
> [    0.000000] Using APIC driver default
> [    0.000000] ACPI: PM-Timer IO Port: 0x608
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to         ffffb000 (        fee00000)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
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
> [    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
> [    0.000000] mapped IOAPIC to ffffa000 (fec00000)
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
> [    0.000000] e820: [mem 0x12c00000-0xfeffbfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
> [    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 15 pages/cpu @d136e000 s38816 r0 d22624 u61440
> [    0.000000] pcpu-alloc: s38816 r0 d22624 u61440 alloc=15*4096
> [    0.000000] pcpu-alloc: [0] 0 [0] 1 
> [    0.000000] KVM setup async PF for cpu 0
> [    0.000000] kvm-stealtime: cpu 0, msr 11371940
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 76070
> [    0.000000] Kernel command line: hung_task_panic=1 earlyprintk=ttyS0,115200 systemd.log_level=err debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kbuild-tests/run-queue/kvm/i386-randconfig-x0-08210826/linux-devel:devel-spot-201508210128:f4a3e90ba5739cfd761b6befadae9728bd3641ed:bisect-linux-9/.vmlinuz-f4a3e90ba5739cfd761b6befadae9728bd3641ed-20150822093355-459-vp branch=linux-devel/devel-spot-201508210128 BOOT_IMAGE=/pkg/linux/i386-randconfig-x0-08210826/gcc-4.9/f4a3e90ba5739cfd761b6befadae9728bd3641ed/vmlinuz-4.2.0-rc6-00979-gf4a3e90 drbd.minor_count=8
> [    0.000000] sysrq: sysrq always enabled.
> [    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
> [    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
> [    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
> [    0.000000] Initializing CPU#0
> [    0.000000] Initializing HighMem for node 0 (00000000:00000000)
> [    0.000000] Memory: 207716K/306680K available (30670K kernel code, 3840K rwdata, 10292K rodata, 1128K init, 24420K bss, 98964K reserved, 0K cma-reserved, 0K highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xffa96000 - 0xfffff000   (5540 kB)
> [    0.000000]     pkmap   : 0xff800000 - 0xffa00000   (2048 kB)
> [    0.000000]     vmalloc : 0xd33e0000 - 0xff7fe000   ( 708 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xd2be0000   ( 299 MB)
> [    0.000000]       .init : 0xc3bd2000 - 0xc3cec000   (1128 kB)
> [    0.000000]       .data : 0xc2df3be1 - 0xc3bd0360   (14193 kB)
> [    0.000000]       .text : 0xc1000000 - 0xc2df3be1   (30670 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
> [    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
> [    0.000000] Running RCU self tests
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=2
> [    0.000000] NR_IRQS:2304 nr_irqs:440 16
> [    0.000000] CPU 0 irqstacks, hard=d080a000 soft=d080c000
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] bootconsole [earlyser0] disabled
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 4.2.0-rc6-00979-gf4a3e90 (kbuild@lkp-ib03) (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Sat Aug 22 09:33:38 CST 2015
> [    0.000000] x86/fpu: Legacy x87 FPU detected.
> [    0.000000] x86/fpu: Using 'lazy' FPU context switches.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000012bdffff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000012be0000-0x0000000012bfffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] SMBIOS 2.8 present.
> [    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [    0.000000] Hypervisor detected: KVM
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn = 0x12be0 max_arch_pfn = 0x1000000
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
> [    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC  
> [    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
> [    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> [    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
> [    0.000000] found SMP MP-table at [mem 0x000f0e80-0x000f0e8f] mapped at [c00f0e80]
> [    0.000000]   mpc: f0e90-f0fac
> [    0.000000] initial memory mapped: [mem 0x00000000-0x059fffff]
> [    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x11000000-0x111fffff]
> [    0.000000]  [mem 0x11000000-0x111fffff] page 4k
> [    0.000000] BRK [0x054fe000, 0x054fefff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x10ffffff]
> [    0.000000]  [mem 0x00100000-0x10ffffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x11200000-0x12bdffff]
> [    0.000000]  [mem 0x11200000-0x12bdffff] page 4k
> [    0.000000] BRK [0x054ff000, 0x054fffff] PGTABLE
> [    0.000000] BRK [0x05500000, 0x05500fff] PGTABLE
> [    0.000000] BRK [0x05501000, 0x05501fff] PGTABLE
> [    0.000000] BRK [0x05502000, 0x05502fff] PGTABLE
> [    0.000000] BRK [0x05503000, 0x05503fff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x11393000-0x12bd7fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000000F0C60 000014 (v00 BOCHS )
> [    0.000000] ACPI: RSDT 0x0000000012BE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACP 0x0000000012BE0B37 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
> [    0.000000] ACPI: DSDT 0x0000000012BE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACS 0x0000000012BE0000 000040
> [    0.000000] ACPI: SSDT 0x0000000012BE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: APIC 0x0000000012BE1805 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
> [    0.000000] ACPI: HPET 0x0000000012BE1885 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to         ffffb000 (        fee00000)
> [    0.000000] 0MB HIGHMEM available.
> [    0.000000] 299MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 12be0000
> [    0.000000]   low ram: 0 - 12be0000
> [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> [    0.000000] kvm-clock: cpu 0, msr 0:12bd9001, primary cpu clock
> [    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   Normal   [mem 0x0000000001000000-0x0000000012bdffff]
> [    0.000000]   HighMem  empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x0000000012bdffff]
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000012bdffff]
> [    0.000000] On node 0 totalpages: 76670
> [    0.000000] free_area_init_node: node 0, pgdat c3b91540, node_mem_map d0f45020
> [    0.000000]   DMA zone: 32 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> [    0.000000]   Normal zone: 568 pages used for memmap
> [    0.000000]   Normal zone: 72672 pages, LIFO batch:15
> [    0.000000] Using APIC driver default
> [    0.000000] ACPI: PM-Timer IO Port: 0x608
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to         ffffb000 (        fee00000)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
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
> [    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
> [    0.000000] mapped IOAPIC to ffffa000 (fec00000)
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
> [    0.000000] e820: [mem 0x12c00000-0xfeffbfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
> [    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 15 pages/cpu @d136e000 s38816 r0 d22624 u61440
> [    0.000000] pcpu-alloc: s38816 r0 d22624 u61440 alloc=15*4096
> [    0.000000] pcpu-alloc: [0] 0 [0] 1 
> [    0.000000] KVM setup async PF for cpu 0
> [    0.000000] kvm-stealtime: cpu 0, msr 11371940
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 76070
> [    0.000000] Kernel command line: hung_task_panic=1 earlyprintk=ttyS0,115200 systemd.log_level=err debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kbuild-tests/run-queue/kvm/i386-randconfig-x0-08210826/linux-devel:devel-spot-201508210128:f4a3e90ba5739cfd761b6befadae9728bd3641ed:bisect-linux-9/.vmlinuz-f4a3e90ba5739cfd761b6befadae9728bd3641ed-20150822093355-459-vp branch=linux-devel/devel-spot-201508210128 BOOT_IMAGE=/pkg/linux/i386-randconfig-x0-08210826/gcc-4.9/f4a3e90ba5739cfd761b6befadae9728bd3641ed/vmlinuz-4.2.0-rc6-00979-gf4a3e90 drbd.minor_count=8
> [    0.000000] sysrq: sysrq always enabled.
> [    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
> [    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
> [    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
> [    0.000000] Initializing CPU#0
> [    0.000000] Initializing HighMem for node 0 (00000000:00000000)
> [    0.000000] Memory: 207716K/306680K available (30670K kernel code, 3840K rwdata, 10292K rodata, 1128K init, 24420K bss, 98964K reserved, 0K cma-reserved, 0K highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xffa96000 - 0xfffff000   (5540 kB)
> [    0.000000]     pkmap   : 0xff800000 - 0xffa00000   (2048 kB)
> [    0.000000]     vmalloc : 0xd33e0000 - 0xff7fe000   ( 708 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xd2be0000   ( 299 MB)
> [    0.000000]       .init : 0xc3bd2000 - 0xc3cec000   (1128 kB)
> [    0.000000]       .data : 0xc2df3be1 - 0xc3bd0360   (14193 kB)
> [    0.000000]       .text : 0xc1000000 - 0xc2df3be1   (30670 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
> [    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
> [    0.000000] Running RCU self tests
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=2
> [    0.000000] NR_IRQS:2304 nr_irqs:440 16
> [    0.000000] CPU 0 irqstacks, hard=d080a000 soft=d080c000
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] bootconsole [earlyser0] disabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
> [    0.000000] ... CHAINHASH_SIZE:          32768
> [    0.000000]  memory used by lock dependency info: 4911 kB
> [    0.000000]  per task-struct memory footprint: 1344 bytes
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
> [    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
> [    0.000000] hpet clockevent registered
> [    0.000000] tsc: Detected 2693.508 MHz processor
> [    0.006666] Calibrating delay loop (skipped) preset value.. 5389.47 BogoMIPS (lpj=8978360)
> [    0.008061] pid_max: default: 32768 minimum: 301
> [    0.010083] ACPI: Core revision 20150619
> [    0.020426] ACPI: All ACPI Tables successfully acquired
> [    0.022383] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
> [    0.023351] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
> [    0.027491] Initializing cgroup subsys devices
> [    0.028804] Initializing cgroup subsys net_cls
> [    0.030027] Initializing cgroup subsys debug
> [    0.031427] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> [    0.032866] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> [    0.037040] debug: unmapping init [mem 0xc3cec000-0xc3cf6fff]
> [    0.047012] Enabling APIC mode:  Flat.  Using 1 I/O APICs
> [    0.048416] enabled ExtINT on CPU#0
> [    0.050745] ENABLING IO-APIC IRQs
> [    0.051692] init IO_APIC IRQs
> [    0.052545]  apic 0 pin 0 not connected
> [    0.053447] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
> [    0.055443] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
> [    0.056666] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
> [    0.056666]  apic 0 pin 16 not connected
> [    0.056666]  apic 0 pin 17 not connected
> [    0.056666]  apic 0 pin 18 not connected
> [    0.056666]  apic 0 pin 19 not connected
> [    0.056666]  apic 0 pin 20 not connected
> [    0.056666]  apic 0 pin 21 not connected
> [    0.056666]  apic 0 pin 22 not connected
> [    0.056666]  apic 0 pin 23 not connected
> [    0.056666] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.056666] Using local APIC timer interrupts.
> [    0.056666] calibrating APIC timer ...
> [    0.059999] ... lapic delta = 6249494
> [    0.059999] ... PM-Timer delta = 357870
> [    0.059999] ... PM-Timer result ok
> [    0.059999] ..... delta 6249494
> [    0.059999] ..... mult: 268413750
> [    0.059999] ..... calibration result: 3333063
> [    0.059999] ..... CPU clock speed is 2693.1461 MHz.
> [    0.059999] ..... host bus clock speed is 1000.0063 MHz.
> [    0.060052] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 06, stepping: 01)
> [    0.061774] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
> [    0.067822] CPU 1 irqstacks, hard=d089a000 soft=d089c000
> [    0.068771] x86: Booting SMP configuration:
> [    0.069535] .... node  #0, CPUs:      #1
> [    0.003333] Initializing CPU#1
> [    0.006666] kvm-clock: cpu 1, msr 0:12bd9021, secondary cpu clock
> [    0.006666] masked ExtINT on CPU#1
> [    0.083588] x86: Booted up 1 node, 2 CPUs
> [    0.083546] KVM setup async PF for cpu 1
> [    0.083546] kvm-stealtime: cpu 1, msr 11380940
> [    0.087986] smpboot: Total of 2 processors activated (10778.95 BogoMIPS)
> [    0.090528] devtmpfs: initialized
> [    0.091293] gcov: version magic: 0x3430392a
> [    0.098196] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
> [    0.100105] xor: measuring software checksum speed
> [    0.133338]    pIII_sse  : 12087.600 MB/sec
> [    0.166678]    prefetch64-sse: 12955.200 MB/sec
> [    0.167268] xor: using function: prefetch64-sse (12955.200 MB/sec)
> [    0.169220] NET: Registered protocol family 16
> [    0.180055] cpuidle: using governor ladder
> [    0.190017] cpuidle: using governor menu
> [    0.201267] ACPI: bus type PCI registered
> [    0.201985] PCI: Using configuration type 1 for base access
> [    0.296715] raid6: mmxx1    gen()   786 MB/s
> [    0.353495] raid6: mmxx2    gen()   609 MB/s
> [    0.410086] raid6: sse1x1   gen()   643 MB/s
> [    0.466701] raid6: sse1x2   gen()   747 MB/s
> [    0.523362] raid6: sse2x1   gen()  1011 MB/s
> [    0.580022] raid6: sse2x1   xor()  1078 MB/s
> [    0.636677] raid6: sse2x2   gen()  1353 MB/s
> [    0.693355] raid6: sse2x2   xor()  1176 MB/s
> [    0.694018] raid6: using algorithm sse2x2 gen() 1353 MB/s
> [    0.694803] raid6: .... xor() 1176 MB/s, rmw enabled
> [    0.695543] raid6: using intx1 recovery algorithm
> [    0.696886] ACPI: Added _OSI(Module Device)
> [    0.697556] ACPI: Added _OSI(Processor Device)
> [    0.698251] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.698956] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.706510] ACPI: Interpreter enabled
> [    0.706685] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150619/hwxface-580)
> [    0.708170] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150619/hwxface-580)
> [    0.710070] ACPI: (supports S0 S3 S4 S5)
> [    0.710701] ACPI: Using IOAPIC for interrupt routing
> [    0.711499] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.727506] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    0.728410] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
> [    0.729430] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    0.730501] PCI host bridge to bus 0000:00
> [    0.731170] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    0.731972] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
> [    0.732914] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
> [    0.733342] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
> [    0.734277] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
> [    0.735213] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
> [    0.736675] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
> [    0.737831] pci_bus 0000:00: root bus resource [mem 0x12c00000-0xfebfffff window]
> [    0.739066] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
> [    0.740824] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
> [    0.742514] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
> [    0.757930] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
> [    0.764619] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
> [    0.765613] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
> [    0.766675] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
> [    0.767659] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
> [    0.769033] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
> [    0.770370] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
> [    0.771511] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
> [    0.773043] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
> [    0.776689] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
> [    0.783355] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
> [    0.810021] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
> [    0.811523] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
> [    0.816679] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
> [    0.823346] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
> [    0.848979] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
> [    0.850477] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
> [    0.855638] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
> [    0.860012] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
> [    0.883808] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
> [    0.888717] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
> [    0.893344] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
> [    0.913818] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
> [    0.920010] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
> [    0.923343] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
> [    0.945797] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
> [    0.950010] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
> [    0.955276] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
> [    0.975668] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
> [    0.980010] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
> [    0.983343] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
> [    1.003772] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
> [    1.008609] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
> [    1.013344] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
> [    1.033768] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
> [    1.038580] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
> [    1.043343] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
> [    1.063756] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
> [    1.066679] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
> [    1.080512] pci_bus 0000:00: on NUMA node 0
> [    1.082088] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
> [    1.083728] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
> [    1.084821] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
> [    1.085877] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
> [    1.086772] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
> [    1.088269] ACPI: Enabled 16 GPEs in block 00 to 0F
> [    1.089842] vgaarb: setting as boot device: PCI:0000:00:02.0
> [    1.089842] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
> [    1.089842] vgaarb: loaded
> [    1.089842] vgaarb: bridge control possible 0000:00:02.0
> [    1.094252] SCSI subsystem initialized
> [    1.094956] libata version 3.00 loaded.
> [    1.094956] ACPI: bus type USB registered
> [    1.094956] usbcore: registered new interface driver usbfs
> [    1.094956] usbcore: registered new interface driver hub
> [    1.096732] usbcore: registered new device driver usb
> [    1.096732] media: Linux media interface: v0.10
> [    1.096732] Linux video capture interface: v2.00
> [    1.097385] pps_core: LinuxPPS API ver. 1 registered
> [    1.098011] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [    1.099144] PTP clock support registered
> [    1.100202] PCI: Using ACPI for IRQ routing
> [    1.100771] PCI: pci_cache_line_size set to 64 bytes
> [    1.101578] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
> [    1.102291] e820: reserve RAM buffer [mem 0x12be0000-0x13ffffff]
> [    1.103987] NET: Registered protocol family 23
> [    1.106677] Bluetooth: Core ver 2.20
> [    1.106677] NET: Registered protocol family 31
> [    1.106677] Bluetooth: HCI device and connection manager initialized
> [    1.106677] Bluetooth: HCI socket layer initialized
> [    1.106681] Bluetooth: L2CAP socket layer initialized
> [    1.107541] nfc: nfc_init: NFC Core ver 0.1
> [    1.108166] NET: Registered protocol family 39
> [    1.110396] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
> [    1.113559] clocksource: Switched to clocksource kvm-clock
> [    1.114719] FS-Cache: Loaded
> [    1.115146] CacheFiles: Loaded
> [    1.115691] pnp: PnP ACPI init
> [    1.116406] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    1.117388] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
> [    1.118277] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
> [    1.119129] pnp 00:03: [dma 2]
> [    1.119656] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
> [    1.120643] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
> [    1.121557] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
> [    1.122915] pnp: PnP ACPI: found 6 devices
> [    1.165231] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
> [    1.166450] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
> [    1.167205] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
> [    1.167926] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
> [    1.168643] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
> [    1.169367] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
> [    1.170110] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff window]
> [    1.170898] pci_bus 0000:00: resource 10 [mem 0x12c00000-0xfebfffff window]
> [    1.171749] NET: Registered protocol family 1
> [    1.172341] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
> [    1.173054] pci 0000:00:01.0: PIIX3: Enabling Passive Release
> [    1.173774] pci 0000:00:01.0: Activating ISA DMA hang workarounds
> [    1.183417] pci 0000:00:02.0: Video device with shadowed ROM
> [    1.184174] PCI: CLS 0 bytes, default 64
> [    1.184981] Trying to unpack rootfs image as initramfs...
> [    2.016645] debug: unmapping init [mem 0xd1393000-0xd2bd7fff]
> [    2.019891] has_svm: not amd
> [    2.020436] kvm: no hardware support
> [    2.022028] apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
> [    2.022926] apm: disabled - APM is not SMP safe.
> [    2.028457] NatSemi SCx200 Driver
> [    2.029165] spin_lock-torture:--- Start of test [debug]: nwriters_stress=4 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
> [    2.031553] spin_lock-torture: Creating torture_shuffle task
> [    2.032622] spin_lock-torture: Creating torture_stutter task
> [    2.032659] spin_lock-torture: torture_shuffle task started
> [    2.034481] spin_lock-torture: Creating lock_torture_writer task
> [    2.034541] spin_lock-torture: torture_stutter task started
> [    2.036331] spin_lock-torture: Creating lock_torture_writer task
> [    2.036358] spin_lock-torture: lock_torture_writer task started
> [    2.038265] spin_lock-torture: Creating lock_torture_writer task
> [    2.038323] spin_lock-torture: lock_torture_writer task started
> [    2.040322] spin_lock-torture: Creating lock_torture_writer task
> [    2.040377] spin_lock-torture: lock_torture_writer task started
> [    2.042231] spin_lock-torture: Creating lock_torture_stats task
> [    2.042294] spin_lock-torture: lock_torture_writer task started
> [    2.044218] spin_lock-torture: lock_torture_stats task started
> [    2.045268] futex hash table entries: 512 (order: 3, 32768 bytes)
> [    2.046232] Initialise system trusted keyring
> [    2.823302] zbud: loaded
> [    2.826762] squashfs: version 4.0 (2009/01/31) Phillip Lougher
> [    2.829166] efs: 1.0a - http://aeschi.ch.eu.org/efs/
> [    2.830549] QNX4 filesystem 0.2.3 registered.
> [    2.831405] qnx6: QNX6 filesystem 1.0.0 registered.
> [    2.832482] fuse init (API version 7.23)
> [    2.834454] NILFS version 2 loaded
> [    2.835048] befs: version: 0.9.3
> [    2.836010] Key type big_key registered
> [    2.846926] NET: Registered protocol family 38
> [    2.847653] Key type asymmetric registered
> [    2.848518] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 248)
> [    2.849681] io scheduler noop registered (default)
> [    2.850486] io scheduler deadline registered
> [    2.851166] test_string_helpers: Running tests...
> [    2.852186] test_hexdump: Running tests...
> [    2.853123] test_firmware: interface ready
> [    2.853821] Running rhashtable test nelem=8, max_size=65536, shrinking=0
> [    2.854752] Test 00:
> [    2.856433]   Adding 50000 keys
> [    3.201595] tsc: Refined TSC clocksource calibration: 2693.505 MHz
> [    3.202561] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x26d346f670a, max_idle_ns: 440795255135 ns
> [    3.218756]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    3.343960]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    3.345262]   Deleting 50000 keys
> [    3.427348]   Duration of test: 570323575 ns
> [    3.428701] Test 01:
> [    3.430429]   Adding 50000 keys
> [    4.264656]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    4.414011]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    4.415280]   Deleting 50000 keys
> [    4.497454]   Duration of test: 1066456384 ns
> [    4.498278] Test 02:
> [    4.499958]   Adding 50000 keys
> [    5.410188]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    5.533074]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    5.534375]   Deleting 50000 keys
> [    5.616102]   Duration of test: 1115566805 ns
> [    5.616934] Test 03:
> [    5.618499]   Adding 50000 keys
> [    6.465568]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    6.588563]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    6.589854]   Deleting 50000 keys
> [    6.670562]   Duration of test: 1051496045 ns
> [    6.672787] Average test time: 950960702
> [    6.673473] Testing concurrent rhashtable access from 10 threads
> [   32.066733] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [rhashtable_thra:103]
> [   32.068432] irq event stamp: 1362768
> [   32.069045] hardirqs last  enabled at (1362767): [<c2df1f47>] restore_all_notrace+0x0/0x18
> [   32.070037] hardirqs last disabled at (1362768): [<c2df29ab>] apic_timer_interrupt+0x2b/0x40
> [   32.070037] softirqs last  enabled at (1362766): [<c11086ff>] __do_softirq+0x2af/0x380
> [   32.070037] softirqs last disabled at (1362761): [<c1072d5b>] do_softirq_own_stack+0x2b/0x40
> [   32.070037] CPU: 0 PID: 103 Comm: rhashtable_thra Not tainted 4.2.0-rc6-00979-gf4a3e90 #1
> [   32.070037] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   32.070037] task: cb1acf80 ti: c0054000 task.ti: c0054000
> [   32.070037] EIP: 0060:[<c1188b82>] EFLAGS: 00000246 CPU: 0
> [   32.070037] EIP is at lock_is_held+0xb2/0xe0
> [   32.070037] EAX: 00000246 EBX: 00000246 ECX: 00000001 EDX: c385ee50
> [   32.070037] ESI: 00000001 EDI: 00000000 EBP: c0055ea8 ESP: c0055ea0
> [   32.070037]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [   32.070037] CR0: 8005003b CR2: ffffffff CR3: 03cfa000 CR4: 000006b0
> [   32.070037] Stack:
> [   32.083360] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [rhashtable_thra:109]
> [   32.083362] irq event stamp: 1377938
> [   32.083372] hardirqs last  enabled at (1377937): [<c2df1f47>] restore_all_notrace+0x0/0x18
> [   32.083376] hardirqs last disabled at (1377938): [<c2df29ab>] apic_timer_interrupt+0x2b/0x40
> [   32.083380] softirqs last  enabled at (1377936): [<c11086ff>] __do_softirq+0x2af/0x380
> [   32.083384] softirqs last disabled at (1377933): [<c1072d5b>] do_softirq_own_stack+0x2b/0x40
> [   32.083388] CPU: 1 PID: 109 Comm: rhashtable_thra Not tainted 4.2.0-rc6-00979-gf4a3e90 #1
> [   32.083389] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   32.083391] task: cb1a9a80 ti: ca914000 task.ti: ca914000
> [   32.083394] EIP: 0060:[<c173ff3e>] EFLAGS: 00000246 CPU: 1
> [   32.083399] EIP is at lockdep_rht_mutex_is_held+0xe/0x50
> [   32.083401] EAX: c46d3880 EBX: cb1f4000 ECX: 00000001 EDX: 00000001
> [   32.083402] ESI: 300003f1 EDI: 00000000 EBP: ca915eec ESP: ca915eb4
> [   32.083403]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [   32.083405] CR0: 8005003b CR2: 00000000 CR3: 03cfa000 CR4: 000006b0
> [   32.083410] Stack:
> [   32.083415]  c17470a3 00000000 d35ec050 d35ec048 000001f8 300003f1 0004c780 000098f0
> [   32.083420]  000698f0 c46d3880 ca915ed4 00000000 d3899974 c0100000 ca915f34 c1748215
> [   32.083424]  d35ec050 00000030 00000006 00000000 d35ec048 00061aa0 0000c354 d3899970
> [   32.083424] Call Trace:
> [   32.083429]  [<c17470a3>] ? thread_lookup_test+0x683/0x7f0
> [   32.083432]  [<c1748215>] threadfunc+0x1005/0x1550
> [   32.083434]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.083436]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.083440]  [<c113cd37>] kthread+0x127/0x170
> [   32.083443]  [<c2df1d81>] ret_from_kernel_thread+0x21/0x30
> [   32.083445]  [<c113cc10>] ? __kthread_unpark+0xd0/0xd0
> [   32.083479] Code: 0d 6b 01 83 05 d8 fb 6c c4 01 83 15 dc fb 6c c4 00 b8 ef ff ff ff 5b 5e 5d c3 8d 76 00 83 05 68 e0 6c c4 01 83 15 6c e0 6c c4 00 <8b> 15 d4 a5 8d c3 85 d2 75 08 b8 01 00 00 00 c3 66 90 55 89 e5
> [   32.083536] Kernel panic - not syncing: softlockup: hung tasks
> [   32.083540] CPU: 1 PID: 109 Comm: rhashtable_thra Tainted: G             L  4.2.0-rc6-00979-gf4a3e90 #1
> [   32.083541] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   32.083547]  00000000 ca915db4 c2dc56f2 00000016 ca915dcc c2dc082b ee6b2800 00000016
> [   32.083553]  ee6b2800 00000000 ca915df0 c1217583 c359d4c6 ca915e78 00000000 00000007
> [   32.083559]  d1381800 d13813a0 c12171d0 ca915e24 c11cf4b3 00000000 7850e875 00000007
> [   32.083559] Call Trace:
> [   32.083563]  [<c2dc56f2>] dump_stack+0xb8/0x108
> [   32.083565]  [<c2dc082b>] panic+0x12b/0x3e6
> [   32.083570]  [<c1217583>] watchdog_timer_fn+0x3b3/0x430
> [   32.083572]  [<c12171d0>] ? watchdog+0x70/0x70
> [   32.083578]  [<c11cf4b3>] __hrtimer_run_queues+0x123/0x2e0
> [   32.083581]  [<c11d07a4>] hrtimer_interrupt+0xc4/0x2c0
> [   32.083584]  [<c1186ef7>] ? trace_hardirqs_off+0x27/0x40
> [   32.083587]  [<c11c7a3a>] ? rcu_irq_enter+0x14a/0x160
> [   32.083590]  [<c10c8117>] local_apic_timer_interrupt+0x37/0x90
> [   32.083593]  [<c10c8d28>] smp_apic_timer_interrupt+0x58/0x90
> [   32.083596]  [<c2df29b2>] apic_timer_interrupt+0x32/0x40
> [   32.083599]  [<c173ff3e>] ? lockdep_rht_mutex_is_held+0xe/0x50
> [   32.083601]  [<c17470a3>] ? thread_lookup_test+0x683/0x7f0
> [   32.083604]  [<c1748215>] threadfunc+0x1005/0x1550
> [   32.083606]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.083608]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.083611]  [<c113cd37>] kthread+0x127/0x170
> [   32.083614]  [<c2df1d81>] ret_from_kernel_thread+0x21/0x30
> [   32.083616]  [<c113cc10>] ? __kthread_unpark+0xd0/0xd0
> [   32.070037]  d0984000 300000bd c0055eb0 c11bef6d c0055eec c1746eb1 00000000 d35ec008
> [   32.070037]  d35ec000 0000005e 300000bd 0000d030 00001a06 00001a06 c46d3880 c0055ed4
> [   32.070037]  00000000 d364fa74 c0100000 c0055f34 c1748215 d35ec008 00000030 00000006
> [   32.070037] Call Trace:
> [   32.070037]  [<c11bef6d>] rcu_read_lock_held+0xdd/0xf0
> [   32.070037]  [<c1746eb1>] thread_lookup_test+0x491/0x7f0
> [   32.070037]  [<c1748215>] threadfunc+0x1005/0x1550
> [   32.070037]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.070037]  [<c1747210>] ? thread_lookup_test+0x7f0/0x7f0
> [   32.070037]  [<c113cd37>] kthread+0x127/0x170
> [   32.070037]  [<c2df1d81>] ret_from_kernel_thread+0x21/0x30
> [   32.070037]  [<c113cc10>] ? __kthread_unpark+0xd0/0xd0
> [   32.070037] Code: 89 f0 e8 d2 fe ff ff 89 c6 83 05 28 2e ec c3 01 83 15 2c 2e ec c3 00 64 a1 28 38 ce c3 c7 80 10 04 00 00 00 00 00 00 89 d8 50 9d <8d> 74 26 00 83 05 30 2e ec c3 01 83 15 34 2e ec c3 00 89 f0 5b
> [   32.086676] Shutting down cpus with NMI
> [   32.086676] Kernel Offset: disabled
> 
> Elapsed time: 40
> qemu-system-x86_64 -enable-kvm -cpu kvm64 -kernel /pkg/linux/i386-randconfig-x0-08210826/gcc-4.9/f4a3e90ba5739cfd761b6befadae9728bd3641ed/vmlinuz-4.2.0-rc6-00979-gf4a3e90 -append 'hung_task_panic=1 earlyprintk=ttyS0,115200 systemd.log_level=err debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kbuild-tests/run-queue/kvm/i386-randconfig-x0-08210826/linux-devel:devel-spot-201508210128:f4a3e90ba5739cfd761b6befadae9728bd3641ed:bisect-linux-9/.vmlinuz-f4a3e90ba5739cfd761b6befadae9728bd3641ed-20150822093355-459-vp branch=linux-devel/devel-spot-201508210128 BOOT_IMAGE=/pkg/linux/i386-randconfig-x0-08210826/gcc-4.9/
 f4a3e90ba5739cfd761b6befadae9728bd3641ed/vmlinuz-4.2.0-rc6-00979-gf4a3e90 drbd.minor_count=8'  -initrd /osimage/quantal/quantal-core-i386.cgz -m 300 -smp 2 -device e1000,netdev=net0 -netdev user,id=net0 -boot order=nc -no-reboot -watchdog i6300esb -rtc base=localtime -drive file=/fs/sdi1/disk0-quantal-vp-30,media=disk,if=virtio -drive file=/fs/sdi1/disk1-quantal-vp-30,media=disk,if=virtio -drive file=/fs/sdi1/disk2-quantal-vp-30,media=disk,if=virtio -drive file=/fs/sdi1/disk3-quantal-vp-30,media=disk,if=virtio -drive file=/fs/sdi1/disk4-quantal-vp-30,media=disk,if=virtio -drive file=/fs/sdi1/disk5-quantal-vp-30,media=disk,if=virtio -drive file=/fs/sdi1/disk6-quantal-vp-30,media=disk,if=virtio -pidfile /dev/shm/kboot/pid-quantal-vp-30 -serial file:/dev/shm/kboot/serial-quantal-vp-30 -daem
 onize -display none -monitor null 

> early console in setup code
> early console in decompress_kernel
> 
> Decompressing Linux... Parsing ELF... done.
> Booting the kernel.
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 4.2.0-rc6-00978-gc1f066d (kbuild@athens) (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Fri Aug 21 23:10:02 CST 2015
> [    0.000000] x86/fpu: Legacy x87 FPU detected.
> [    0.000000] x86/fpu: Using 'lazy' FPU context switches.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
> [    0.000000] SMBIOS 2.8 present.
> [    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [    0.000000] Hypervisor detected: KVM
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn = 0x13fe0 max_arch_pfn = 0x1000000
> [    0.000000] MTRR: Disabled
> [    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
> [    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> [    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
> [    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at [c00f0eb0]
> [    0.000000]   mpc: f0ec0-f0fac
> [    0.000000] initial memory mapped: [mem 0x00000000-0x059fffff]
> [    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x13800000-0x139fffff]
> [    0.000000]  [mem 0x13800000-0x139fffff] page 4k
> [    0.000000] BRK [0x054fd000, 0x054fdfff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x137fffff]
> [    0.000000]  [mem 0x00100000-0x137fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x13a00000-0x13fdffff]
> [    0.000000]  [mem 0x13a00000-0x13fdffff] page 4k
> [    0.000000] BRK [0x054fe000, 0x054fefff] PGTABLE
> [    0.000000] BRK [0x054ff000, 0x054fffff] PGTABLE
> [    0.000000] BRK [0x05500000, 0x05500fff] PGTABLE
> [    0.000000] BRK [0x05501000, 0x05501fff] PGTABLE
> [    0.000000] BRK [0x05502000, 0x05502fff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x13baf000-0x13fd7fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000000F0C90 000014 (v00 BOCHS )
> [    0.000000] ACPI: RSDT 0x0000000013FE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACP 0x0000000013FE0B37 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
> [    0.000000] ACPI: DSDT 0x0000000013FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACS 0x0000000013FE0000 000040
> [    0.000000] ACPI: SSDT 0x0000000013FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: APIC 0x0000000013FE1805 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
> [    0.000000] ACPI: HPET 0x0000000013FE1885 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to         ffffb000 (        fee00000)
> [    0.000000] 0MB HIGHMEM available.
> [    0.000000] 319MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 13fe0000
> [    0.000000]   low ram: 0 - 13fe0000
> [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> [    0.000000] kvm-clock: cpu 0, msr 0:13fdb001, primary cpu clock
> [    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   Normal   [mem 0x0000000001000000-0x0000000013fdffff]
> [    0.000000]   HighMem  empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x0000000013fdffff]
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000013fdffff]
> [    0.000000] On node 0 totalpages: 81790
> [    0.000000] free_area_init_node: node 0, pgdat c3b914c0, node_mem_map d3711020
> [    0.000000]   DMA zone: 32 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> [    0.000000]   Normal zone: 608 pages used for memmap
> [    0.000000]   Normal zone: 77792 pages, LIFO batch:15
> [    0.000000] Using APIC driver default
> [    0.000000] ACPI: PM-Timer IO Port: 0x608
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to         ffffb000 (        fee00000)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
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
> [    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
> [    0.000000] mapped IOAPIC to ffffa000 (fec00000)
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
> [    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
> [    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 15 pages/cpu @d3b8b000 s38816 r0 d22624 u61440
> [    0.000000] pcpu-alloc: s38816 r0 d22624 u61440 alloc=15*4096
> [    0.000000] pcpu-alloc: [0] 0 [0] 1 
> [    0.000000] KVM setup async PF for cpu 0
> [    0.000000] kvm-stealtime: cpu 0, msr 13b8e940
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 81150
> [    0.000000] Kernel command line: root=/dev/ram0 user=lkp job=/lkp/scheduled/vm-kbuild-yocto-i386-54/bisect_boot-1-yocto-minimal-i386.cgz-i386-randconfig-x0-08210826-c1f066d4ee0bde4bb0ff4ac295218b631729e0de-20150822-61926-rm35si-0.yaml ARCH=i386 kconfig=i386-randconfig-x0-08210826 branch=linux-devel/devel-spot-201508210128 commit=c1f066d4ee0bde4bb0ff4ac295218b631729e0de BOOT_IMAGE=/pkg/linux/i386-randconfig-x0-08210826/gcc-4.9/c1f066d4ee0bde4bb0ff4ac295218b631729e0de/vmlinuz-4.2.0-rc6-00978-gc1f066d max_uptime=600 RESULT_ROOT=/result/boot/1/vm-kbuild-yocto-i386/yocto-minimal-i386.cgz/i386-randconfig-x0-08210826/gcc-4.9/c1f066d4ee0bde4bb0ff4ac295218b631729e0de/2 LKP_SERVER=inn earlyprintk=ttyS0,115200 systemd.log_level=err debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_tim
 eout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal rw ip=::::vm-kbuild-yocto-i386-54::dhcp drbd.minor_count=8
> [    0.000000] sysrq: sysrq always enabled.
> [    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
> [    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
> [    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
> [    0.000000] Initializing CPU#0
> [    0.000000] Initializing HighMem for node 0 (00000000:00000000)
> [    0.000000] Memory: 248588K/327160K available (30662K kernel code, 3844K rwdata, 10292K rodata, 1128K init, 24416K bss, 78572K reserved, 0K cma-reserved, 0K highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xffa96000 - 0xfffff000   (5540 kB)
> [    0.000000]     pkmap   : 0xff800000 - 0xffa00000   (2048 kB)
> [    0.000000]     vmalloc : 0xd47e0000 - 0xff7fe000   ( 688 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xd3fe0000   ( 319 MB)
> [    0.000000]       .init : 0xc3bd2000 - 0xc3cec000   (1128 kB)
> [    0.000000]       .data : 0xc2df1ea1 - 0xc3bd02e0   (14201 kB)
> [    0.000000]       .text : 0xc1000000 - 0xc2df1ea1   (30663 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
> [    0.000000] SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
> [    0.000000] Running RCU self tests
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=2
> [    0.000000] NR_IRQS:2304 nr_irqs:440 16
> [    0.000000] CPU 0 irqstacks, hard=d300a000 soft=d300c000
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] bootconsole [earlyser0] disabled
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 4.2.0-rc6-00978-gc1f066d (kbuild@athens) (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Fri Aug 21 23:10:02 CST 2015
> [    0.000000] x86/fpu: Legacy x87 FPU detected.
> [    0.000000] x86/fpu: Using 'lazy' FPU context switches.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> [    0.000000] bootconsole [earlyser0] enabled
> [    0.000000] Notice: NX (Execute Disable) protection missing in CPU!
> [    0.000000] SMBIOS 2.8 present.
> [    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [    0.000000] Hypervisor detected: KVM
> [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn = 0x13fe0 max_arch_pfn = 0x1000000
> [    0.000000] MTRR: Disabled
> [    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
> [    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> [    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
> [    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at [c00f0eb0]
> [    0.000000]   mpc: f0ec0-f0fac
> [    0.000000] initial memory mapped: [mem 0x00000000-0x059fffff]
> [    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x13800000-0x139fffff]
> [    0.000000]  [mem 0x13800000-0x139fffff] page 4k
> [    0.000000] BRK [0x054fd000, 0x054fdfff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0x00100000-0x137fffff]
> [    0.000000]  [mem 0x00100000-0x137fffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x13a00000-0x13fdffff]
> [    0.000000]  [mem 0x13a00000-0x13fdffff] page 4k
> [    0.000000] BRK [0x054fe000, 0x054fefff] PGTABLE
> [    0.000000] BRK [0x054ff000, 0x054fffff] PGTABLE
> [    0.000000] BRK [0x05500000, 0x05500fff] PGTABLE
> [    0.000000] BRK [0x05501000, 0x05501fff] PGTABLE
> [    0.000000] BRK [0x05502000, 0x05502fff] PGTABLE
> [    0.000000] RAMDISK: [mem 0x13baf000-0x13fd7fff]
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x00000000000F0C90 000014 (v00 BOCHS )
> [    0.000000] ACPI: RSDT 0x0000000013FE18BD 000034 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACP 0x0000000013FE0B37 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
> [    0.000000] ACPI: DSDT 0x0000000013FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: FACS 0x0000000013FE0000 000040
> [    0.000000] ACPI: SSDT 0x0000000013FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
> [    0.000000] ACPI: APIC 0x0000000013FE1805 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
> [    0.000000] ACPI: HPET 0x0000000013FE1885 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to         ffffb000 (        fee00000)
> [    0.000000] 0MB HIGHMEM available.
> [    0.000000] 319MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 13fe0000
> [    0.000000]   low ram: 0 - 13fe0000
> [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> [    0.000000] kvm-clock: cpu 0, msr 0:13fdb001, primary cpu clock
> [    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   Normal   [mem 0x0000000001000000-0x0000000013fdffff]
> [    0.000000]   HighMem  empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x0000000013fdffff]
> [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000013fdffff]
> [    0.000000] On node 0 totalpages: 81790
> [    0.000000] free_area_init_node: node 0, pgdat c3b914c0, node_mem_map d3711020
> [    0.000000]   DMA zone: 32 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> [    0.000000]   Normal zone: 608 pages used for memmap
> [    0.000000]   Normal zone: 77792 pages, LIFO batch:15
> [    0.000000] Using APIC driver default
> [    0.000000] ACPI: PM-Timer IO Port: 0x608
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] mapped APIC to         ffffb000 (        fee00000)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
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
> [    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
> [    0.000000] mapped IOAPIC to ffffa000 (fec00000)
> [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
> [    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
> [    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
> [    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 15 pages/cpu @d3b8b000 s38816 r0 d22624 u61440
> [    0.000000] pcpu-alloc: s38816 r0 d22624 u61440 alloc=15*4096
> [    0.000000] pcpu-alloc: [0] 0 [0] 1 
> [    0.000000] KVM setup async PF for cpu 0
> [    0.000000] kvm-stealtime: cpu 0, msr 13b8e940
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 81150
> [    0.000000] Kernel command line: root=/dev/ram0 user=lkp job=/lkp/scheduled/vm-kbuild-yocto-i386-54/bisect_boot-1-yocto-minimal-i386.cgz-i386-randconfig-x0-08210826-c1f066d4ee0bde4bb0ff4ac295218b631729e0de-20150822-61926-rm35si-0.yaml ARCH=i386 kconfig=i386-randconfig-x0-08210826 branch=linux-devel/devel-spot-201508210128 commit=c1f066d4ee0bde4bb0ff4ac295218b631729e0de BOOT_IMAGE=/pkg/linux/i386-randconfig-x0-08210826/gcc-4.9/c1f066d4ee0bde4bb0ff4ac295218b631729e0de/vmlinuz-4.2.0-rc6-00978-gc1f066d max_uptime=600 RESULT_ROOT=/result/boot/1/vm-kbuild-yocto-i386/yocto-minimal-i386.cgz/i386-randconfig-x0-08210826/gcc-4.9/c1f066d4ee0bde4bb0ff4ac295218b631729e0de/2 LKP_SERVER=inn earlyprintk=ttyS0,115200 systemd.log_level=err debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_tim
 eout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal rw ip=::::vm-kbuild-yocto-i386-54::dhcp drbd.minor_count=8
> [    0.000000] sysrq: sysrq always enabled.
> [    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
> [    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
> [    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
> [    0.000000] Initializing CPU#0
> [    0.000000] Initializing HighMem for node 0 (00000000:00000000)
> [    0.000000] Memory: 248588K/327160K available (30662K kernel code, 3844K rwdata, 10292K rodata, 1128K init, 24416K bss, 78572K reserved, 0K cma-reserved, 0K highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xffa96000 - 0xfffff000   (5540 kB)
> [    0.000000]     pkmap   : 0xff800000 - 0xffa00000   (2048 kB)
> [    0.000000]     vmalloc : 0xd47e0000 - 0xff7fe000   ( 688 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xd3fe0000   ( 319 MB)
> [    0.000000]       .init : 0xc3bd2000 - 0xc3cec000   (1128 kB)
> [    0.000000]       .data : 0xc2df1ea1 - 0xc3bd02e0   (14201 kB)
> [    0.000000]       .text : 0xc1000000 - 0xc2df1ea1   (30663 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
> [    0.000000] SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
> [    0.000000] Running RCU self tests
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=2
> [    0.000000] NR_IRQS:2304 nr_irqs:440 16
> [    0.000000] CPU 0 irqstacks, hard=d300a000 soft=d300c000
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] bootconsole [earlyser0] disabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
> [    0.000000] ... CHAINHASH_SIZE:          32768
> [    0.000000]  memory used by lock dependency info: 4911 kB
> [    0.000000]  per task-struct memory footprint: 1344 bytes
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
> [    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
> [    0.000000] hpet clockevent registered
> [    0.000000] tsc: Detected 2693.508 MHz processor
> [    0.006666] Calibrating delay loop (skipped) preset value.. 5389.47 BogoMIPS (lpj=8978360)
> [    0.006666] pid_max: default: 32768 minimum: 301
> [    0.006746] ACPI: Core revision 20150619
> [    0.014956] ACPI: All ACPI Tables successfully acquired
> [    0.016585] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
> [    0.016700] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
> [    0.019228] Initializing cgroup subsys devices
> [    0.019999] Initializing cgroup subsys net_cls
> [    0.019999] Initializing cgroup subsys debug
> [    0.023435] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> [    0.024511] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> [    0.027721] debug: unmapping init [mem 0xc3cec000-0xc3cf6fff]
> [    0.035558] Enabling APIC mode:  Flat.  Using 1 I/O APICs
> [    0.036784] enabled ExtINT on CPU#0
> [    0.038978] ENABLING IO-APIC IRQs
> [    0.040062] init IO_APIC IRQs
> [    0.040826]  apic 0 pin 0 not connected
> [    0.041801] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
> [    0.043453] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
> [    0.045399] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
> [    0.046666] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
> [    0.046666]  apic 0 pin 16 not connected
> [    0.046666]  apic 0 pin 17 not connected
> [    0.046666]  apic 0 pin 18 not connected
> [    0.046666]  apic 0 pin 19 not connected
> [    0.046666]  apic 0 pin 20 not connected
> [    0.046666]  apic 0 pin 21 not connected
> [    0.046666]  apic 0 pin 22 not connected
> [    0.046666]  apic 0 pin 23 not connected
> [    0.046666] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.046666] Using local APIC timer interrupts.
> [    0.046666] calibrating APIC timer ...
> [    0.049999] ... lapic delta = 12084735
> [    0.049999] ... PM-Timer delta = 692139
> [    0.049999] APIC calibration not consistent with PM-Timer: 193ms instead of 100ms
> [    0.049999] APIC delta adjusted to PM-Timer: 6249870 (12084735)
> [    0.049999] TSC delta adjusted to PM-Timer: 269352181 (520818735)
> [    0.049999] ..... delta 6249870
> [    0.049999] ..... mult: 268429899
> [    0.049999] ..... calibration result: 3333264
> [    0.049999] ..... CPU clock speed is 2693.2637 MHz.
> [    0.049999] ..... host bus clock speed is 1000.0264 MHz.
> [    0.050095] smpboot: CPU0: Intel QEMU Virtual CPU version 2.1.2 (fam: 06, model: 06, stepping: 03)
> [    0.052722] Performance Events: Broken PMU hardware detected, using software events only.
> [    0.060016] Failed to access perfctr msr (MSR c2 is 0)
> [    0.068434] CPU 1 irqstacks, hard=d3098000 soft=d309a000
> [    0.070060] x86: Booting SMP configuration:
> [    0.071389] .... node  #0, CPUs:      #1
> [    0.003333] Initializing CPU#1
> [    0.006666] kvm-clock: cpu 1, msr 0:13fdb021, secondary cpu clock
> [    0.006666] masked ExtINT on CPU#1
> [    0.080370] x86: Booted up 1 node, 2 CPUs
> [    0.080307] KVM setup async PF for cpu 1
> [    0.080307] kvm-stealtime: cpu 1, msr 13b9d940
> [    0.084291] smpboot: Total of 2 processors activated (10778.95 BogoMIPS)
> [    0.090027] devtmpfs: initialized
> [    0.092079] gcov: version magic: 0x3430392a
> [    0.109338] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
> [    0.110432] xor: measuring software checksum speed
> [    0.143365]    pIII_sse  :  9300.000 MB/sec
> [    0.176695]    prefetch64-sse:  9373.200 MB/sec
> [    0.177854] xor: using function: prefetch64-sse (9373.200 MB/sec)
> [    0.181359] NET: Registered protocol family 16
> [    0.196804] cpuidle: using governor ladder
> [    0.206725] cpuidle: using governor menu
> [    0.210154] ACPI: bus type PCI registered
> [    0.211529] PCI: Using configuration type 1 for base access
> [    0.346753] raid6: mmxx1    gen()   305 MB/s
> [    0.403380] raid6: mmxx2    gen()   295 MB/s
> [    0.460030] raid6: sse1x1   gen()   234 MB/s
> [    0.516824] raid6: sse1x2   gen()   363 MB/s
> [    0.573402] raid6: sse2x1   gen()   471 MB/s
> [    0.630072] raid6: sse2x1   xor()   571 MB/s
> [    0.686725] raid6: sse2x2   gen()   639 MB/s
> [    0.743380] raid6: sse2x2   xor()   571 MB/s
> [    0.744336] raid6: using algorithm sse2x2 gen() 639 MB/s
> [    0.745412] raid6: .... xor() 571 MB/s, rmw enabled
> [    0.746705] raid6: using intx1 recovery algorithm
> [    0.750889] ACPI: Added _OSI(Module Device)
> [    0.751814] ACPI: Added _OSI(Processor Device)
> [    0.753354] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.754325] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.766383] ACPI: Interpreter enabled
> [    0.766699] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150619/hwxface-580)
> [    0.770665] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150619/hwxface-580)
> [    0.772836] ACPI: (supports S0 S3 S4 S5)
> [    0.773351] ACPI: Using IOAPIC for interrupt routing
> [    0.774480] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.807596] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> [    0.808865] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
> [    0.810136] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
> [    0.812199] PCI host bridge to bus 0000:00
> [    0.813356] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    0.814461] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
> [    0.815746] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
> [    0.816689] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
> [    0.817982] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
> [    0.819251] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
> [    0.820033] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
> [    0.821662] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebfffff window]
> [    0.823501] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
> [    0.826105] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
> [    0.828062] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
> [    0.837479] pci 0000:00:01.1: reg 0x20: [io  0xc080-0xc08f]
> [    0.840481] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
> [    0.841867] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
> [    0.843353] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
> [    0.844771] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
> [    0.846893] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
> [    0.848644] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
> [    0.850050] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
> [    0.853422] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
> [    0.858647] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
> [    0.861746] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
> [    0.873379] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
> [    0.875775] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
> [    0.880035] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
> [    0.884911] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
> [    0.894126] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
> [    0.897223] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
> [    0.900030] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
> [    0.903367] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
> [    0.913796] pci 0000:00:05.0: [8086:25ab] type 00 class 0x088000
> [    0.915856] pci 0000:00:05.0: reg 0x10: [mem 0xfebf2000-0xfebf200f]
> [    0.923499] pci_bus 0000:00: on NUMA node 0
> [    0.928710] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
> [    0.931329] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
> [    0.933738] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
> [    0.935740] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
> [    0.937548] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
> [    0.939999] ACPI: Enabled 16 GPEs in block 00 to 0F
> [    0.943846] vgaarb: setting as boot device: PCI:0000:00:02.0
> [    0.945105] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
> [    0.945105] vgaarb: loaded
> [    0.945105] vgaarb: bridge control possible 0000:00:02.0
> [    0.950495] SCSI subsystem initialized
> [    0.953596] libata version 3.00 loaded.
> [    0.954813] ACPI: bus type USB registered
> [    0.956829] usbcore: registered new interface driver usbfs
> [    0.958083] usbcore: registered new interface driver hub
> [    0.960328] usbcore: registered new device driver usb
> [    0.961713] media: Linux media interface: v0.10
> [    0.962774] Linux video capture interface: v2.00
> [    0.963544] pps_core: LinuxPPS API ver. 1 registered
> [    0.964627] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
> [    0.966783] PTP clock support registered
> [    0.983770] PCI: Using ACPI for IRQ routing
> [    0.984756] PCI: pci_cache_line_size set to 32 bytes
> [    0.986039] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
> [    0.986732] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
> [    0.990412] NET: Registered protocol family 23
> [    0.991572] Bluetooth: Core ver 2.20
> [    1.010154] NET: Registered protocol family 31
> [    1.011130] Bluetooth: HCI device and connection manager initialized
> [    1.013462] Bluetooth: HCI socket layer initialized
> [    1.014560] Bluetooth: L2CAP socket layer initialized
> [    1.016841] nfc: nfc_init: NFC Core ver 0.1
> [    1.017980] NET: Registered protocol family 39
> [    1.021460] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
> [    1.056673] clocksource: Switched to clocksource kvm-clock
> [    1.058589] FS-Cache: Loaded
> [    1.059688] CacheFiles: Loaded
> [    1.060726] pnp: PnP ACPI init
> [    1.062022] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
> [    1.063789] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
> [    1.065491] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
> [    1.067238] pnp 00:03: [dma 2]
> [    1.068262] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
> [    1.070093] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
> [    1.071828] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
> [    1.074233] pnp: PnP ACPI: found 6 devices
> [    1.143072] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
> [    1.145565] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
> [    1.146943] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
> [    1.148174] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
> [    1.149459] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
> [    1.150889] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
> [    1.152277] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff window]
> [    1.153820] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff window]
> [    1.155516] NET: Registered protocol family 1
> [    1.156668] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
> [    1.158116] pci 0000:00:01.0: PIIX3: Enabling Passive Release
> [    1.159507] pci 0000:00:01.0: Activating ISA DMA hang workarounds
> [    1.181040] pci 0000:00:02.0: Video device with shadowed ROM
> [    1.182366] PCI: CLS 0 bytes, default 32
> [    1.183922] Trying to unpack rootfs image as initramfs...
> [    2.416018] debug: unmapping init [mem 0xd3baf000-0xd3fd7fff]
> [    2.424950] has_svm: not amd
> [    2.425917] kvm: no hardware support
> [    2.448787] apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
> [    2.450133] apm: disabled - APM is not SMP safe.
> [    2.462899] NatSemi SCx200 Driver
> [    2.464052] spin_lock-torture:--- Start of test [debug]: nwriters_stress=4 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
> [    2.467477] spin_lock-torture: Creating torture_shuffle task
> [    2.469007] spin_lock-torture: torture_shuffle task started
> [    2.469354] spin_lock-torture: Creating torture_stutter task
> [    2.512207] spin_lock-torture: Creating lock_torture_writer task
> [    2.514126] spin_lock-torture: torture_stutter task started
> [    2.524993] spin_lock-torture: lock_torture_writer task started
> [    2.526413] spin_lock-torture: Creating lock_torture_writer task
> [    2.549857] spin_lock-torture: Creating lock_torture_writer task
> [    2.551227] spin_lock-torture: lock_torture_writer task started
> [    2.551360] spin_lock-torture: Creating lock_torture_writer task
> [    2.551411] spin_lock-torture: lock_torture_writer task started
> [    2.551459] spin_lock-torture: Creating lock_torture_stats task
> [    2.551516] spin_lock-torture: lock_torture_writer task started
> [    2.556742] futex hash table entries: 512 (order: 3, 32768 bytes)
> [    2.556864] Initialise system trusted keyring
> [    2.560200] spin_lock-torture: lock_torture_stats task started
> [    3.450887] tsc: Refined TSC clocksource calibration: 2693.504 MHz
> [    3.452054] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x26d345dbcd4, max_idle_ns: 440795302414 ns
> [    4.790727] zbud: loaded
> [    4.795759] squashfs: version 4.0 (2009/01/31) Phillip Lougher
> [    4.800574] efs: 1.0a - http://aeschi.ch.eu.org/efs/
> [    4.802564] QNX4 filesystem 0.2.3 registered.
> [    4.803913] qnx6: QNX6 filesystem 1.0.0 registered.
> [    4.805473] fuse init (API version 7.23)
> [    4.808439] NILFS version 2 loaded
> [    4.809424] befs: version: 0.9.3
> [    4.811437] Key type big_key registered
> [    4.843914] NET: Registered protocol family 38
> [    4.845181] Key type asymmetric registered
> [    4.846251] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 248)
> [    4.848113] io scheduler noop registered (default)
> [    4.849148] io scheduler deadline registered
> [    4.850077] test_string_helpers: Running tests...
> [    4.865805] test_hexdump: Running tests...
> [    4.867249] test_firmware: interface ready
> [    4.868199] Running rhashtable test nelem=8, max_size=65536, shrinking=0
> [    4.869497] Test 00:
> [    4.871413]   Adding 50000 keys
> [    5.557822]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    5.877799]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    5.879533]   Deleting 50000 keys
> [    6.177154]   Duration of test: 1304937980 ns
> [    6.182756] Test 01:
> [    6.186619]   Adding 50000 keys
> [    6.914500]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    7.304136]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    7.305948]   Deleting 50000 keys
> [    7.577570]   Duration of test: 1390084180 ns
> [    7.578802] Test 02:
> [    7.600843]   Adding 50000 keys
> [    8.336537]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    8.745392]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [    8.747352]   Deleting 50000 keys
> [    9.066895]   Duration of test: 1465327671 ns
> [    9.080002] Test 03:
> [    9.083867]   Adding 50000 keys
> [    9.982778]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [   10.361053]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
> [   10.362817]   Deleting 50000 keys
> [   10.632952]   Duration of test: 1544506049 ns
> [   10.634222] Average test time: 1426213970
> [   10.635653] crc32: CRC_LE_BITS = 64, CRC_BE BITS = 64
> [   10.636786] crc32: self tests passed, processed 225944 bytes in 222142 nsec
> [   10.638348] crc32c: CRC_LE_BITS = 64
> [   10.639173] crc32c: self tests passed, processed 225944 bytes in 102104 nsec
> [   10.709090] crc32_combine: 8373 self tests passed
> [   10.759469] crc32c_combine: 8373 self tests passed
> [   10.760892] xz_dec_test: module loaded
> [   10.761799] xz_dec_test: Create a device node with 'mknod xz_dec_test c 247 0' and write .xz files to it.
> [   10.784057] rbtree testing -> 52478 cycles
> [   12.884377] augmented rbtree testing -> 79009 cycles
> [   16.028107] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> [   16.029459] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
> [   16.031071] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> [   16.033703] ipmi message handler version 39.2
> [   16.034896] IPMI System Interface driver.
> [   16.036077] ipmi_si: Adding default-specified kcs state machine
> [   16.037626] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
> [   16.039896] ipmi_si: Interface detection failed
> [   16.053575] ipmi_si: Adding default-specified smic state machine
> [   16.054923] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
> [   16.057193] ipmi_si: Interface detection failed
> [   16.070161] ipmi_si: Adding default-specified bt state machine
> [   16.071676] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
> [   16.074087] ipmi_si: Interface detection failed
> [   16.087272] ipmi_si: Unable to find any System Interface(s)
> [   16.088476] IPMI SSIF Interface driver
> [   16.089395] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
> [   16.091811] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
> [   16.093587] ACPI: Power Button [PWRF]
> [   16.781877] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
> [   16.783140] virtio-pci 0000:00:04.0: virtio_pci: leaving for legacy driver
> [   16.786337] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [   16.825175] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> [   16.830405] Cyclades driver 2.6
> [   16.847105] MOXA Intellio family driver version 6.0k
> [   16.849349] MOXA Smartio/Industio family driver version 2.0.5
> [   16.850667] Initializing Nozomi driver 2.1d
> [   16.851718] RocketPort device driver module, version 2.09, 12-June-2003
> [   16.853053] No rocketport ports found; unloading driver
> [   16.854194] SyncLink GT
> [   16.874458] SyncLink GT, tty major#239
> [   16.875423] SyncLink GT no devices found
> [   16.876343] SyncLink serial driver $Revision: 4.38 $
> [   16.933662] SyncLink serial driver $Revision: 4.38 $, tty major#238
> [   16.935483] sonypi: Sony Programmable I/O Controller Driver v1.26.
> [   16.936826] toshiba: not a supported Toshiba laptop
> [   16.938334] nsc_gpio initializing
> [   16.939179] telclk_interrupt = 0xf non-mcpbl0010 hw.
> [   16.940404] smapi::smapi_init, ERROR invalid usSmapiID
> [   16.941552] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
> [   16.943659] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
> [   16.958596] mwave: mwavedd::mwave_init: Error: Failed to initialize
> [   16.960196] Linux agpgart interface v0.103
> [   16.961899] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
> [   16.964661] Failed to find cpu0 device node
> [   16.965715] Unable to detect cache hierarchy from DT for CPU 0
> [   16.995261] brd: module loaded
> [   17.017496] loop: module loaded
> [   17.018308] HP CISS Driver (v 3.6.26)
> [   17.034290] nbd: registered device at major 43
> [   17.078809] dummy-irq: no IRQ given.  Use irq=N
> [   17.080159] lkdtm: No crash points registered, enable through debugfs
> [   17.081870] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
> [   17.083895] c2port c2port0: C2 port uc added
> [   17.084856] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
> [   17.088350] usbcore: registered new interface driver dln2
> [   17.089658] usbcore: registered new interface driver pn533
> [   17.105655] Uniform Multi-Platform E-IDE driver
> [   17.108127] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
> [   17.110432] ide-gd driver 1.18
> [   17.111573] Loading iSCSI transport class v2.0-870.
> [   17.126971] fnic: Cisco FCoE HBA Driver, ver 1.6.0.17
> [   17.128237] fnic: Successfully Initialized Trace Buffer
> [   17.130204] fnic: Successfully Initialized FC_CTLR Trace Buffer
> [   17.132902] bnx2fc: QLogic NetXtreme II FCoE Driver bnx2fc v2.4.2 (Dec 11, 2013)
> [   17.148240] Loading Adaptec I2O RAID: Version 2.4 Build 5go
> [   17.149548] Detecting Adaptec I2O RAID controllers...
> [   17.151159] Adaptec aacraid driver 1.2-1[40709]-ms
> [   17.152501] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
> [   17.154218] isci: Intel(R) C600 SAS Controller Driver - version 1.2.0
> [   17.155983] scsi: <fdomain> Detection failed (no card)
> [   17.157368] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.07.00.18-k.
> [   17.163292] iscsi: registered transport (qla4xxx)
> [   17.164580] QLogic iSCSI HBA Driver
> [   17.165498] Brocade BFA FC/FCOE SCSI driver - version: 3.2.23.0
> [   17.166989] csiostor: Chelsio FCoE driver 1.0.0
> [   17.168273] megasas: 06.807.10.00-rc1
> [   17.169246] mpt3sas version 04.100.00.00 loaded
> [   17.170694] GDT-HA: Storage RAID Controller Driver. Version: 3.05
> [   17.172104] 3ware Storage Controller device driver for Linux v1.26.02.003.
> [   17.173581] 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
> [   17.175271] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v3.26.02.000.
> [   17.190241] nsp32: loading...
> [   17.191199] RocketRAID 3xxx/4xxx Controller driver v1.8
> [   17.222450] iscsi: registered transport (be2iscsi)
> [   17.223649] In beiscsi_module_init, tt=c39d3700
> [   17.225021] esas2r: driver will not be loaded because no ATTO esas2r devices were found
> [   17.227114] VMware PVSCSI driver - version 1.0.5.0-k
> [   17.241609] SCSI Media Changer driver v0.25 
> [   17.242859] osd: LOADED open-osd 0.2.1
> [   17.262087] scsi_debug: host protection
> [   17.263094] scsi host0: scsi_debug, version 1.85 [20141022], dev_size_mb=8, opts=0x0
> [   17.266747] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       0184 PQ: 0 ANSI: 6
> [   17.284746] Rounding down aligned max_sectors from 4294967295 to 4294967288
> [   17.287291] SSFDC read-only Flash Translation layer
> [   17.288607] scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
> [   17.289965] slram: not enough parameters.
> [   17.291014] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.00 MiB)
> [   17.292976] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel Networks.
> [   17.294712] pmc551: not detected
> [   17.295559] sd 0:0:0:0: [sda] Write Protect is off
> [   17.307870] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
> [   17.320135] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO and FUA
> [   17.355968] No valid DiskOnChip devices found
> [   17.377028] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)
> [   17.391113] libphy: Fixed MDIO Bus: probed
> [   17.392902] cnic: QLogic cnicDriver v2.5.22 (July 20, 2015)
> [   17.394352] bnx2x: QLogic 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.712.30-0 (2014/02/10)
> [   17.397205] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
> [   17.398631] e100: Copyright(c) 1999-2006 Intel Corporation
> [   17.400117] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
> [   17.403540] sd 0:0:0:0: [sda] Attached SCSI disk
> [   17.418643] e1000: Copyright (c) 1999-2006 Intel Corporation.
> [   18.165409] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 10
> [   18.847617] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
> [   18.849280] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
> [   18.851076] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
> [   18.852440] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
> [   18.854031] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.3.0-k
> [   18.855508] igb: Copyright (c) 2007-2014 Intel Corporation.
> [   18.856958] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.2-k
> [   18.858788] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
> [   18.860289] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.0.1-k
> [   18.875093] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
> [   18.876562] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver - version 2.12.1-k
> [   18.878726] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
> [   18.880189] i40e: Intel(R) Ethernet Connection XL710 Network Driver - version 1.3.6-k
> [   18.882085] i40e: Copyright (c) 2013 - 2014 Intel Corporation.
> [   18.883640] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
> [   18.885161] ixgb: Copyright (c) 1999-2008 Intel Corporation.
> [   18.899744] i40evf: Intel(R) XL710/X710 Virtual Function Network Driver - version 1.3.2
> [   18.901688] Copyright (c) 2013 - 2014 Intel Corporation.
> [   18.903160] jme: JMicron JMC2XX ethernet driver version 1.0.8
> [   18.929212] pch_gbe: EG20T PCH Gigabit Ethernet Driver - version 1.01
> [   18.930840] Solarflare NET driver v4.0
> [   18.933084] usbcore: registered new interface driver kingsun-sir
> [   18.934403] usbcore: registered new interface driver ksdazzle-sir
> [   18.936966] usbcore: registered new interface driver hwa-rc
> [   18.947750] usbcore: registered new interface driver i1480-dfu-usb
> [   18.950477] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [   18.951922] ehci-pci: EHCI PCI platform driver
> [   18.968830] ehci-platform: EHCI generic platform driver
> [   18.970212] uhci_hcd: USB Universal Host Controller Interface driver
> [   18.971776] usbcore: registered new interface driver hwa-hc
> [   18.972993] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
> [   18.989038] usbcore: registered new interface driver wusb-cbaf
> [   18.990346] usbcore: registered new interface driver usblp
> [   18.991544] usbcore: registered new interface driver cdc_wdm
> [   18.992738] usbcore: registered new interface driver usbtmc
> [   18.994012] usbcore: registered new interface driver usb-storage
> [   18.999802] usbcore: registered new interface driver ums-alauda
> [   19.001228] usbcore: registered new interface driver ums-freecom
> [   19.002497] usbcore: registered new interface driver ums-isd200
> [   19.007360] usbcore: registered new interface driver ums-karma
> [   19.008654] usbcore: registered new interface driver ums-onetouch
> [   19.016989] usbcore: registered new interface driver ums-realtek
> [   19.018171] usbcore: registered new interface driver ums-sddr55
> [   19.019293] usbcore: registered new interface driver mdc800
> [   19.020605] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
> [   19.022499] usbcore: registered new interface driver microtekX6
> [   19.023948] usbcore: registered new interface driver adutux
> [   19.056746] usbcore: registered new interface driver appledisplay
> [   19.058112] usbcore: registered new interface driver cypress_cy7c63
> [   19.059450] usbcore: registered new interface driver cytherm
> [   19.066745] usbcore: registered new interface driver iowarrior
> [   19.076799] usbcore: registered new interface driver isight_firmware
> [   19.078339] usbcore: registered new interface driver usblcd
> [   19.079592] usbcore: registered new interface driver usbled
> [   19.080834] usbcore: registered new interface driver trancevibrator
> [   19.082239] usbcore: registered new interface driver uss720
> [   19.083524] uss720: v0.6:USB Parport Cable driver for Cables using the Lucent Technologies USS720 Chip
> [   19.089900] uss720: NOTE: this is a special purpose driver to allow nonstandard
> [   19.106901] uss720: protocols (eg. bitbang) over USS720 usb to parallel cables
> [   19.108554] uss720: If you just want to connect to a printer, use usblp instead
> [   19.110494] usbcore: registered new interface driver yurex
> [   19.111722] usbcore: registered new interface driver sisusb
> [   19.112912] usbcore: registered new interface driver lvs
> [   19.114093] usbip_core: USB/IP Core v1.0.0
> [   19.115433] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
> [   19.117543] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 1
> [   19.123307] hub 1-0:1.0: USB hub found
> [   19.138914] hub 1-0:1.0: 8 ports detected
> [   19.142988] vhci_hcd: USB/IP 'Virtual' Host Controller (VHCI) Driver v1.0.0
> [   19.144619] usbcore: registered new device driver usbip-host
> [   19.145795] usbip_host: USB/IP Host Driver v1.0.0
> [   19.147034] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
> [   19.193781] serio: i8042 KBD port at 0x60,0x64 irq 1
> [   19.195093] serio: i8042 AUX port at 0x60,0x64 irq 12
> [   19.197604] parkbd: no such parport
> [   19.200669] usbcore: registered new interface driver appletouch
> [   19.201093] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
> [   19.203982] usbcore: registered new interface driver bcm5974
> [   19.206614] mk712: device not present
> [   19.207747] usbcore: registered new interface driver sur40
> [   19.209637] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
> [   19.210989] usbcore: registered new interface driver ati_remote2
> [   19.212229] cm109: Keymap for Komunikate KIP1000 phone loaded
> [   19.213587] usbcore: registered new interface driver cm109
> [   19.231610] cm109: CM109 phone driver: 20080805 (C) Alfred E. Heggestad
> [   19.233287] usbcore: registered new interface driver ims_pcu
> [   19.234834] usbcore: registered new interface driver yealink
> [   19.236060] ideapad_slidebar: DMI does not match
> [   19.237343] i2c /dev entries driver
> [   19.239049] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
> [   19.277795] i2c-parport: adapter type unspecified
> [   19.278885] i2c-parport-light: adapter type unspecified
> [   19.280265] usbcore: registered new interface driver i2c-tiny-usb
> [   19.282906] usbcore: registered new interface driver imon
> [   19.284411] usbcore: registered new interface driver mceusb
> [   19.285621] usbcore: registered new interface driver redrat3
> [   19.299842] usbcore: registered new interface driver ttusbir
> [   19.301396] usbcore: registered new interface driver ttusb
> [   19.302628] usbcore: registered new interface driver dvb_usb_vp7045
> [   19.304050] usbcore: registered new interface driver dvb_usb_gp8psk
> [   19.305383] usbcore: registered new interface driver dvb_usb_a800
> [   19.306838] usbcore: registered new interface driver dvb_usb_dibusb_mb
> [   19.308336] usbcore: registered new interface driver dvb_usb_dibusb_mc
> [   19.319338] usbcore: registered new interface driver dvb_usb_digitv
> [   19.327056] usbcore: registered new interface driver dvb_usb_cxusb
> [   19.328413] usbcore: registered new interface driver dvb_usb_dib0700
> [   19.329834] usbcore: registered new interface driver dvb_usb_af9005
> [   19.331332] usbcore: registered new interface driver pctv452e
> [   19.337358] usbcore: registered new interface driver dvb_usb_dtv5100
> [   19.341166] usbcore: registered new interface driver dvb_usb_az6027
> [   19.342452] usbcore: registered new interface driver dvb_usb_af9015
> [   19.343846] usbcore: registered new interface driver dvb_usb_af9035
> [   19.345140] usbcore: registered new interface driver dvb_usb_anysee
> [   19.346456] usbcore: registered new interface driver dvb_usb_au6610
> [   19.362653] usbcore: registered new interface driver dvb_usb_ec168
> [   19.363963] usbcore: registered new interface driver dvb_usb_lmedm04
> [   19.365299] usbcore: registered new interface driver dvb_usb_mxl111sf
> [   19.366632] usbcore: registered new interface driver dvb_usb_dvbsky
> [   19.367991] usbcore: registered new interface driver hackrf
> [   19.369192] usbcore: registered new interface driver em28xx
> [   19.370535] em28xx: Registered (Em28xx dvb Extension) extension
> [   19.371663] em28xx: Registered (Em28xx Input Extension) extension
> [   19.372971] usbcore: registered new interface driver Abilis Systems as10x usb driver
> [   19.374834] smssdio: Siano SMS1xxx SDIO driver
> [   19.375876] smssdio: Copyright Pierre Ossman
> [   19.376951] pps_ldisc: PPS line discipline registered
> [   19.406109] pps_parport: parallel port PPS client
> [   19.407481] Driver for 1-wire Dallas network protocol.
> [   19.422010] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
> [   19.423614] 1-Wire driver for the DS2760 battery monitor chip - (c) 2004-2005, Szabolcs Gyurko
> [   19.737040] applesmc: supported laptop not found!
> [   19.738080] applesmc: driver init failed (ret=-19)!
> [   20.067892] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input3
> [   20.503951] usbcore: registered new interface driver pcwd_usb
> [   20.505126] acquirewdt: WDT driver for Acquire single board computer initialising
> [   20.507155] acquirewdt: I/O address 0x0043 already in use
> [   20.508345] acquirewdt: probe of acquirewdt failed with error -5
> [   20.510198] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
> [   20.511354] alim7101_wdt: ALi M7101 PMU not present - WDT not set
> [   20.512827] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
> [   20.514536] ib700wdt: WDT driver for IB700 single board computer initialising
> [   20.520323] wafer5823wdt: WDT driver for Wafer 5823 single board computer initialising
> [   20.522168] wafer5823wdt: I/O address 0x0443 already in use
> [   20.527042] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
> [   20.528675] i6300esb: cannot register miscdev on minor=130 (err=-16)
> [   20.553672] i6300ESB timer: probe of 0000:00:05.0 failed with error -16
> [   20.555211] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
> [   20.556591] iTCO_vendor_support: vendor-support=0
> [   20.557781] it87_wdt: no device
> [   20.558808] sc1200wdt: build 20020303
> [   20.559812] sc1200wdt: io parameter must be specified
> [   20.561079] pc87413_wdt: Version 1.1 at io 0x2E
> [   20.562177] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
> [   20.571768] nv_tco: NV TCO WatchDog Timer Driver v0.01
> [   20.573466] sbc8360: failed to register misc device
> [   20.579140] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 initialising...
> [   20.582252] smsc37b787_wdt: Unable to register miscdev on minor 130
> [   20.588041] w83877f_wdt: I/O address 0x0443 already in use
> [   20.589215] w83977f_wdt: driver v1.00
> [   20.595530] w83977f_wdt: cannot register miscdev on minor=130 (err=-16)
> [   20.597064] machzwd: MachZ ZF-Logic Watchdog driver initializing
> [   20.598419] machzwd: no ZF-Logic found
> [   20.603973] watchdog: Software Watchdog: cannot register miscdev on minor=130 (err=-16).
> [   20.605925] watchdog: Software Watchdog: a legacy watchdog module is probably present.
> [   20.611889] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=1)
> [   20.614491] Bluetooth: HCI UART driver ver 2.3
> [   20.615626] Bluetooth: HCI UART protocol H4 registered
> [   20.616868] Bluetooth: HCI UART protocol Three-wire (H5) registered
> [   20.618272] Bluetooth: HCI UART protocol Intel registered
> [   20.619653] usbcore: registered new interface driver bcm203x
> [   20.621008] usbcore: registered new interface driver bfusb
> [   20.622173] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
> [   20.623554] lguest: switcher text too large (4384)
> [   20.637760] cpufreq-nforce2: No nForce2 chipset.
> [   20.639046] sdhci: Secure Digital Host Controller Interface driver
> [   20.640532] sdhci: Copyright(c) Pierre Ossman
> [   20.641792] wbsd: Winbond W83L51xD SD/MMC card interface driver
> [   20.643135] wbsd: Copyright(c) Pierre Ossman
> [   20.644586] VUB300 Driver rom wait states = 1C irqpoll timeout = 0400
> [   20.646959] usbcore: registered new interface driver vub300
> [   20.648547] usbcore: registered new interface driver ushc
> [   20.772234] hidraw: raw HID events driver (C) Jiri Kosina
> [   20.787439] usbcore: registered new interface driver usbhid
> [   20.788643] usbhid: USB HID core driver
> [   20.790226] Software Queue-Pair Transport over NTB, version 4
> [   20.791725] NET: Registered protocol family 26
> [   20.792870] NET: Registered protocol family 17
> [   20.794052] bridge: automatic filtering via arp/ip/ip6tables has been deprecated. Update your scripts to load br_netfilter if you need this
