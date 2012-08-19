From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: IPv4 BUG: held lock freed!
Date: Sun, 19 Aug 2012 11:39:37 +0800
Message-ID: <20120819033937.GA18110@localhost>
References: <20120818021918.GA6499@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: networking <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8046 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392Ab2HSDkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2012 23:40:17 -0400
Content-Disposition: inline
In-Reply-To: <20120818021918.GA6499@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Sorry I forgot to mention that the test kernels run inside a slow QEMU
(not the hardware accelerated KVM!) virtual machine.

If no obvious clue, I'll continue to bisect..perhaps taking one month
of machine time, which still seems affordable to me.

Thanks,
Fengguang

On Sat, Aug 18, 2012 at 10:19:18AM +0800, Fengguang Wu wrote:
> Hi David,
> 
> The bug should be introduced somewhere between 3.5 and 3.6-rc1.
> 
> [ 2866.131281] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.131726] 
> [ 2866.132188] =========================
> [ 2866.132281] [ BUG: held lock freed! ]
> [ 2866.132281] 3.6.0-rc1+ #622 Not tainted
> [ 2866.132281] -------------------------
> [ 2866.132281] kworker/0:1/652 is freeing memory ffff880019ec0000-ffff880019ec0a1f, with a lock still held there!
> [ 2866.132281]  (sk_lock-AF_INET-RPC){+.+...}, at: [<ffffffff81903619>] tcp_sendmsg+0x29/0xcc6
> [ 2866.132281] 4 locks held by kworker/0:1/652:
> [ 2866.132281]  #0:  (rpciod){.+.+.+}, at: [<ffffffff81083567>] process_one_work+0x1de/0x47f
> [ 2866.132281]  #1:  ((&task->u.tk_work)){+.+.+.}, at: [<ffffffff81083567>] process_one_work+0x1de/0x47f
> [ 2866.132281]  #2:  (sk_lock-AF_INET-RPC){+.+...}, at: [<ffffffff81903619>] tcp_sendmsg+0x29/0xcc6
> [ 2866.132281]  #3:  (&icsk->icsk_retransmit_timer){+.-...}, at: [<ffffffff81078017>] run_timer_softirq+0x1ad/0x35f
> [ 2866.132281] 
> [ 2866.132281] stack backtrace:
> [ 2866.132281] Pid: 652, comm: kworker/0:1 Not tainted 3.6.0-rc1+ #622
> [ 2866.132281] Call Trace:
> [ 2866.132281]  <IRQ>  [<ffffffff810bc527>] debug_check_no_locks_freed+0x112/0x159
> [ 2866.132281]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.132281]  [<ffffffff811549fa>] kmem_cache_free+0x6b/0x13a
> [ 2866.132281]  [<ffffffff818a0839>] __sk_free+0xfd/0x114
> [ 2866.132281]  [<ffffffff818a08c0>] sk_free+0x1c/0x1e
> [ 2866.132281]  [<ffffffff81911e1c>] tcp_write_timer+0x51/0x56
> [ 2866.132281]  [<ffffffff81078082>] run_timer_softirq+0x218/0x35f
> [ 2866.132281]  [<ffffffff81078017>] ? run_timer_softirq+0x1ad/0x35f
> [ 2866.132281]  [<ffffffff810f5831>] ? rb_commit+0x58/0x85
> [ 2866.132281]  [<ffffffff81911dcb>] ? tcp_write_timer_handler+0x148/0x148
> [ 2866.132281]  [<ffffffff81070bd6>] __do_softirq+0xcb/0x1f9
> [ 2866.132281]  [<ffffffff81a0a00c>] ? _raw_spin_unlock+0x29/0x2e
> [ 2866.132281]  [<ffffffff81a1227c>] call_softirq+0x1c/0x30
> [ 2866.132281]  [<ffffffff81039f38>] do_softirq+0x4a/0xa6
> [ 2866.132281]  [<ffffffff81070f2b>] irq_exit+0x51/0xad
> [ 2866.132281]  [<ffffffff81a129cd>] do_IRQ+0x9d/0xb4
> [ 2866.132281]  [<ffffffff81a0a3ef>] common_interrupt+0x6f/0x6f
> [ 2866.132281]  <EOI>  [<ffffffff8109d006>] ? sched_clock_cpu+0x58/0xd1
> [ 2866.132281]  [<ffffffff81a0a172>] ? _raw_spin_unlock_irqrestore+0x4c/0x56
> [ 2866.132281]  [<ffffffff81078692>] mod_timer+0x178/0x1a9
> [ 2866.132281]  [<ffffffff818a00aa>] sk_reset_timer+0x19/0x26
> [ 2866.132281]  [<ffffffff8190b2cc>] tcp_rearm_rto+0x99/0xa4
> [ 2866.132281]  [<ffffffff8190dfba>] tcp_event_new_data_sent+0x6e/0x70
> [ 2866.132281]  [<ffffffff8190f7ea>] tcp_write_xmit+0x7de/0x8e4
> [ 2866.132281]  [<ffffffff818a565d>] ? __alloc_skb+0xa0/0x1a1
> [ 2866.132281]  [<ffffffff8190f952>] __tcp_push_pending_frames+0x2e/0x8a
> [ 2866.132281]  [<ffffffff81904122>] tcp_sendmsg+0xb32/0xcc6
> [ 2866.132281]  [<ffffffff819229c2>] inet_sendmsg+0xaa/0xd5
> [ 2866.132281]  [<ffffffff81922918>] ? inet_autobind+0x5f/0x5f
> [ 2866.132281]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
> [ 2866.132281]  [<ffffffff8189adab>] sock_sendmsg+0xa3/0xc4
> [ 2866.132281]  [<ffffffff810f5de6>] ? rb_reserve_next_event+0x26f/0x2d5
> [ 2866.132281]  [<ffffffff8103e6a9>] ? native_sched_clock+0x29/0x6f
> [ 2866.132281]  [<ffffffff8103e6f8>] ? sched_clock+0x9/0xd
> [ 2866.132281]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
> [ 2866.132281]  [<ffffffff8189ae03>] kernel_sendmsg+0x37/0x43
> [ 2866.132281]  [<ffffffff8199ce49>] xs_send_kvec+0x77/0x80
> [ 2866.132281]  [<ffffffff8199cec1>] xs_sendpages+0x6f/0x1a0
> [ 2866.132281]  [<ffffffff8107826d>] ? try_to_del_timer_sync+0x55/0x61
> [ 2866.132281]  [<ffffffff8199d0d2>] xs_tcp_send_request+0x55/0xf1
> [ 2866.132281]  [<ffffffff8199bb90>] xprt_transmit+0x89/0x1db
> [ 2866.132281]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.132281]  [<ffffffff81999d92>] call_transmit+0x1c5/0x20e
> [ 2866.132281]  [<ffffffff819a0d55>] __rpc_execute+0x6f/0x225
> [ 2866.132281]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.132281]  [<ffffffff819a0f33>] rpc_async_schedule+0x28/0x34
> [ 2866.132281]  [<ffffffff810835d6>] process_one_work+0x24d/0x47f
> [ 2866.132281]  [<ffffffff81083567>] ? process_one_work+0x1de/0x47f
> [ 2866.132281]  [<ffffffff819a0f0b>] ? __rpc_execute+0x225/0x225
> [ 2866.132281]  [<ffffffff81083a6d>] worker_thread+0x236/0x317
> [ 2866.132281]  [<ffffffff81083837>] ? process_scheduled_works+0x2f/0x2f
> [ 2866.132281]  [<ffffffff8108b7b8>] kthread+0x9a/0xa2
> [ 2866.132281]  [<ffffffff81a12184>] kernel_thread_helper+0x4/0x10
> [ 2866.132281]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.132281]  [<ffffffff8108b71e>] ? __init_kthread_worker+0x5a/0x5a
> [ 2866.132281]  [<ffffffff81a12180>] ? gs_change+0x13/0x13
> [ 2866.308506] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.309689] =============================================================================
> [ 2866.310254] BUG TCP (Not tainted): Object already free
> [ 2866.310254] -----------------------------------------------------------------------------
> [ 2866.310254] 
> 
> This happens only in one of my test boxes and is rather hard to
> reproduce. I find that it could only happen once out of 100 boots,
> each boot test takes 1.5 hour. It's basically an NFSROOT system that
> runs a bunch of IO and MM tests.
> 
> I've been running auto+manual bisects for one week and it has failed
> several times.  Here is the log for last try. It reports 0bb4087 as
> the first bad commit, however the bug still shows up when reverting
> 0bb4087 on top of 3.6-rc2. So the 'good' commits in the below log may
> not really be good. The 'bad' commits, however, are bad for sure.
> 
> wfg@bee ~/linux% git bisect log
> # bad: [0d7614f09c1ebdbaa1599a5aba7593f147bf96ee] Linux 3.6-rc1
> # good: [28a33cbc24e4256c143dce96c7d93bf423229f92] Linux 3.5
> git bisect start 'v3.6-rc1' 'v3.5' '--'
> # bad: [614a6d4341b3760ca98a1c2c09141b71db5d1e90] Merge branch 'for-3.6' of git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup
> git bisect bad 614a6d4341b3760ca98a1c2c09141b71db5d1e90
> # bad: [320f5ea0cedc08ef65d67e056bcb9d181386ef2c] genetlink: define lockdep_genl_is_held() when CONFIG_LOCKDEP
> git bisect bad 320f5ea0cedc08ef65d67e056bcb9d181386ef2c
> # skip: [dbfa600148a25903976910863c75dae185f8d187] cxgb3: set maximal number of default RSS queues
> git bisect skip dbfa600148a25903976910863c75dae185f8d187
> # bad: [b6dfd939fdc249fcf8cd7b8006f76239b33eb581] ixgbe: add support for new 82599 device
> git bisect bad b6dfd939fdc249fcf8cd7b8006f76239b33eb581
> # bad: [39cb681b3bb4da17e74d48e553d1bb9a1b759aa5] ixgbe: Fix handling of FDIR_HASH flag
> git bisect bad 39cb681b3bb4da17e74d48e553d1bb9a1b759aa5
> # bad: [9297127b9cdd8d30c829ef5fd28b7cc0323a7bcd] ixgbe: Change how we check for pre-existing and assigned VFs
> git bisect bad 9297127b9cdd8d30c829ef5fd28b7cc0323a7bcd
> # bad: [99d744875d01d57d832b8dbfc36d9a1990d503b8] ixgbe: Drop probe_vf and merge functionality into ixgbe_enable_sriov
> git bisect bad 99d744875d01d57d832b8dbfc36d9a1990d503b8
> # bad: [186e868786f97c8026f0a81400b451ace306b3a4] forcedeth: spin_unlock_irq in interrupt handler fix
> git bisect bad 186e868786f97c8026f0a81400b451ace306b3a4
> # good: [3e4b9459fb0e149c6b74c9e89399a8fc39a92b44] Merge tag 'md-3.5-fixes' of git://neil.brown.name/md
> git bisect good 3e4b9459fb0e149c6b74c9e89399a8fc39a92b44
> # good: [e8c7b335faca2cbce715da3b0e1663d75d422f5b] wlcore: increase command completion timeout
> git bisect good e8c7b335faca2cbce715da3b0e1663d75d422f5b
> # good: [1d248b1cf4e09dbec8cef5f7fbeda5874248bd09] net: Pass neighbours and dest address into NETEVENT_REDIRECT events.
> git bisect good 1d248b1cf4e09dbec8cef5f7fbeda5874248bd09
> # good: [73dea3983a9d2e413e1c065ed4e132a7d4127929] be2net: Add description about various RSS hash types
> git bisect good 73dea3983a9d2e413e1c065ed4e132a7d4127929
> # good: [8b0d2f9ed3d8e92feada7c5d70fa85be46e6f948] net: e100: ucode is optional in some cases
> git bisect good 8b0d2f9ed3d8e92feada7c5d70fa85be46e6f948
> # good: [36eb22e97a2b621fb707eead58ef915ab0f46e9e] libertas: firmware.c: remove duplicated include
> git bisect good 36eb22e97a2b621fb707eead58ef915ab0f46e9e
> # good: [5815d5e7aae3cc9c5e85af83094d4d6498c3f4fc] tcp: use hash_32() in tcp_metrics
> git bisect good 5815d5e7aae3cc9c5e85af83094d4d6498c3f4fc
> # good: [e4bce0f288bafd8505ba5ce9c5284a4478f1b725] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> git bisect good e4bce0f288bafd8505ba5ce9c5284a4478f1b725
> # good: [a1b5d0dd28e9cb4fe42ad2df4ebbe5cce96866d7] openvswitch: Check gso_type for correct sk_buff in queue_gso_packets().
> git bisect good a1b5d0dd28e9cb4fe42ad2df4ebbe5cce96866d7
> # bad: [0bb4087] ipv4: Fix neigh lookup keying over loopback/point-to-point devices.
> git bisect bad 0bb4087
> # good: [b09e786bd1dd66418b69348cb110f3a64764626a] tun: fix a crash bug and a memory leak
> git bisect good b09e786bd1dd66418b69348cb110f3a64764626a
> # good: [fa0afcd10951afad2022dda09777d2bf70cdab3d] atl1c: fix issue of io access mode for AR8152 v2.1
> git bisect good fa0afcd10951afad2022dda09777d2bf70cdab3d
> 
> Thanks,
> Fengguang

> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.6.0-rc1+ (kbuild@bee) (gcc version 4.7.1 (Debian 4.7.1-5) ) #622 SMP Mon Aug 6 16:48:16 CST 2012
> [    0.000000] Command line: trinity=3m hung_task_panic=1 branch=vfs/for-linus log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-08-06-16-49-45-vfs:for-linus:98d11ea-50640bc-x86_64-nfsroot-1-ant noapic nolapic acpi=off BOOT_IMAGE=kernel-tests/kernels/x86_64-nfsroot/50640bc/vmlinuz-3.6.0-rc1+
> [    0.000000] KERNEL supported cpus:
> [    0.000000]   Intel GenuineIntel
> [    0.000000]   Centaur CentaurHauls
> [    0.000000] CPU: vendor_id 'AuthenticAMD' unknown, using generic init.
> [    0.000000] CPU: Your system may be unstable.
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
> [    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffdfff] usable
> [    0.000000] BIOS-e820: [mem 0x000000001fffe000-0x000000001fffffff] reserved
> [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> [    0.000000] debug: ignoring loglevel setting.
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] DMI 2.4 present.
> [    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
> [    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
> [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> [    0.000000] e820: last_pfn = 0x1fffe max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: write-back
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF uncachable
> [    0.000000]   C0000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
> [    0.000000]   1 disabled
> [    0.000000]   2 disabled
> [    0.000000]   3 disabled
> [    0.000000]   4 disabled
> [    0.000000]   5 disabled
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
> [    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
> [    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> [    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
> [    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at [ffff8800000fdac0]
> [    0.000000]   mpc: fdad0-fdbec
> [    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
> [    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x1fffdfff]
> [    0.000000]  [mem 0x00000000-0x1fffdfff] page 4k
> [    0.000000] kernel direct mapping tables up to 0x1fffdfff @ [mem 0x1fefc000-0x1fffdfff]
> [    0.000000] log_buf_len: 8388608
> [    0.000000] early log buf free: 258924(98%)
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffdfff]
> [    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffdfff]
> [    0.000000]   NODE_DATA [mem 0x1f6f7000-0x1f6fbfff]
> [    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e600000-ffff88001edfffff] on node 0
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
> [    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
> [    0.000000]   Normal   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00010000-0x00092fff]
> [    0.000000]   node   0: [mem 0x00100000-0x1fffdfff]
> [    0.000000] On node 0 totalpages: 130945
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 6 pages reserved
> [    0.000000]   DMA zone: 3901 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 1984 pages used for memmap
> [    0.000000]   DMA32 zone: 124990 pages, LIFO batch:31
> [    0.000000] Intel MultiProcessor Specification v1.4
> [    0.000000]   mpc: fdad0-fdbec
> [    0.000000] MPTABLE: OEM ID: BOCHSCPU
> [    0.000000] MPTABLE: Product ID: 0.1         
> [    0.000000] MPTABLE: APIC at: 0xFEE00000
> [    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
> [    0.000000] Processor #0 (Bootup-CPU)
> [    0.000000] Processor #1
> [    0.000000] Bus #0 is PCI   
> [    0.000000] Bus #1 is ISA   
> [    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
> [    0.000000] Int: type 0, pol 1, trig 0, bus 00, IRQ 04, APIC ID 2, APIC INT 09
> [    0.000000] Int: type 0, pol 1, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC INT 0b
> [    0.000000] Int: type 0, pol 1, trig 0, bus 00, IRQ 10, APIC ID 2, APIC INT 0b
> [    0.000000] Int: type 0, pol 1, trig 0, bus 00, IRQ 14, APIC ID 2, APIC INT 0a
> [    0.000000] Int: type 0, pol 1, trig 0, bus 00, IRQ 18, APIC ID 2, APIC INT 0a
> [    0.000000] Int: type 0, pol 1, trig 0, bus 00, IRQ 1c, APIC ID 2, APIC INT 0b
> [    0.000000] Int: type 0, pol 1, trig 0, bus 00, IRQ 20, APIC ID 2, APIC INT 0b
> [    0.000000] Int: type 0, pol 1, trig 0, bus 00, IRQ 24, APIC ID 2, APIC INT 0a
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 00, APIC ID 2, APIC INT 02
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 01, APIC ID 2, APIC INT 01
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 03, APIC ID 2, APIC INT 03
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 04, APIC ID 2, APIC INT 04
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 05, APIC ID 2, APIC INT 05
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 06, APIC ID 2, APIC INT 06
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 07, APIC ID 2, APIC INT 07
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 08, APIC ID 2, APIC INT 08
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 0c, APIC ID 2, APIC INT 0c
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 0d, APIC ID 2, APIC INT 0d
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 0e, APIC ID 2, APIC INT 0e
> [    0.000000] Int: type 0, pol 0, trig 0, bus 01, IRQ 0f, APIC ID 2, APIC INT 0f
> [    0.000000] Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC LINT 00
> [    0.000000] Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, APIC LINT 01
> [    0.000000] Processors: 2
> [    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
> [    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
> [    0.000000] nr_irqs_gsi: 40
> [    0.000000] PM: Registered nosave memory: 0000000000093000 - 0000000000094000
> [    0.000000] PM: Registered nosave memory: 0000000000094000 - 00000000000a0000
> [    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
> [    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
> [    0.000000] e820: [mem 0x20000000-0xfffbffff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:2 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 476 pages/cpu @ffff88001f200000 s1919168 r8192 d22336 u2097152
> [    0.000000] pcpu-alloc: s1919168 r8192 d22336 u2097152 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 0 [0] 1 
> [    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 128891
> [    0.000000] Policy zone: DMA32
> [    0.000000] Kernel command line: trinity=3m hung_task_panic=1 branch=vfs/for-linus log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10 load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal ip=::::kvm::dhcp nfsroot=10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=600,nolock,rsize=524288,wsize=524288 rw link=vmlinuz-2012-08-06-16-49-45-vfs:for-linus:98d11ea-50640bc-x86_64-nfsroot-1-ant noapic nolapic acpi=off BOOT_IMAGE=kernel-tests/kernels/x86_64-nfsroot/50640bc/vmlinuz-3.6.0-rc1+
> [    0.000000] sysrq: sysrq always enabled.
> [    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
> [    0.000000] __ex_table already sorted, skipping sort
> [    0.000000] Memory: 470856k/524280k available (10329k kernel code, 500k absent, 52924k reserved, 6295k data, 2836k init)
> [    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 
> [    0.000000] 
> [    0.000000] NR_IRQS:4352 nr_irqs:512 16
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
> [    0.000000] ... CHAINHASH_SIZE:          16384
> [    0.000000]  memory used by lock dependency info: 6367 kB
> [    0.000000]  per task-struct memory footprint: 2688 bytes
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
> [    0.000000] -------------------------------------------------------
> [    0.000000] Good, all 218 testcases passed! |
> [    0.000000] ---------------------------------
> [    0.000000] ODEBUG: 0 of 0 active objects replaced
> [    0.000000] tsc: Fast TSC calibration using PIT
> [    0.000000] tsc: Detected 3191.974 MHz processor
> [    0.000000] tsc: Marking TSC unstable due to TSCs unsynchronized
> [    0.018997] Calibrating delay loop (skipped), value calculated using timer frequency.. 6383.94 BogoMIPS (lpj=3191974)
> [    0.022480] pid_max: default: 32768 minimum: 301
> [    0.128524] Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.148643] Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
> [    0.163441] Mount-cache hash table entries: 256
> [    0.442254] Initializing cgroup subsys debug
> [    0.444320] Initializing cgroup subsys cpuacct
> [    0.446176] Initializing cgroup subsys devices
> [    0.448414] Initializing cgroup subsys freezer
> [    0.450417] Initializing cgroup subsys blkio
> [    0.475405] mce: CPU supports 10 MCE banks
> [    0.477224] mce: unknown CPU type - not enabling MCE support
> [    0.480368] numa_add_cpu cpu 0 node 0: mask now 0
> [    0.482429] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> [    0.482429] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
> [    0.482429] tlb_flushall_shift is 0xffffffff
> [    0.568607] ftrace: allocating 39749 entries in 156 pages
> [    0.972226] smpboot: SMP disabled
> [    0.974250] Performance Events: 
> [    1.062516] Brought up 1 CPUs
> [    1.064198] smpboot: Total of 1 processors activated (6383.94 BogoMIPS)
> [    1.082214] CPU0 attaching NULL sched-domain.
> [    1.176176] devtmpfs: initialized
> [    1.467376] xor: automatically using best checksumming function:
> [    1.481078]    generic_sse:   288.000 MB/sec
> [    1.485501] atomic64 test passed for x86-64 platform with CX8 and with SSE
> [    1.543631] kworker/u:0 (13) used greatest stack depth: 5240 bytes left
> [    1.565276] RTC time:  8:50:30, date: 08/06/12
> [    1.609993] NET: Registered protocol family 16
> [    2.221087] dca service started, version 1.12.1
> [    2.334978] PCI: Using configuration type 1 for base access
> [   23.383027] bio: create slab <bio-0> at 0
> [   23.426876] kworker/u:0 (517) used greatest stack depth: 4840 bytes left
> [   23.484174] raid6: sse2x1      42 MB/s
> [   23.502293] raid6: sse2x2      50 MB/s
> [   23.519817] raid6: sse2x4      42 MB/s
> [   23.521735] raid6: using algorithm sse2x2 (50 MB/s)
> [   23.523968] raid6: using intx1 recovery algorithm
> [   23.563007] ACPI: Interpreter disabled.
> [   23.703075] vgaarb: loaded
> [   23.933671] SCSI subsystem initialized
> [   24.058631] libata version 3.00 loaded.
> [   24.268817] usbcore: registered new interface driver usbfs
> [   24.314677] usbcore: registered new interface driver hub
> [   24.361809] usbcore: registered new device driver usb
> [   24.713900] Advanced Linux Sound Architecture Driver Version 1.0.25.
> [   24.715753] PCI: Probing PCI hardware
> [   24.720064] PCI: root bus 00: using default resources
> [   24.721732] PCI: Probing PCI hardware (bus 00)
> [   24.778698] PCI host bridge to bus 0000:00
> [   24.785232] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
> [   24.786938] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
> [   24.793760] pci_bus 0000:00: No busn resource found for root bus, will use [bus 00-ff]
> [   24.797746] pci_bus 0000:00: busn_res: [bus 00-ff] is inserted under domain [bus 00-ff]
> [   24.807671] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
> [   24.825505] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
> [   24.836521] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
> [   24.853539] pci 0000:00:01.1: reg 20: [io  0xc1c0-0xc1cf]
> [   24.867607] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
> [   24.875691] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
> [   24.877598] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
> [   24.882496] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
> [   24.886677] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
> [   24.891722] pci 0000:00:02.0: reg 14: [mem 0xfebf0000-0xfebf0fff]
> [   24.913812] pci 0000:00:02.0: reg 30: [mem 0xfebe0000-0xfebeffff pref]
> [   24.920546] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
> [   24.923656] pci 0000:00:03.0: reg 10: [mem 0xfeba0000-0xfebbffff]
> [   24.928633] pci 0000:00:03.0: reg 14: [io  0xc000-0xc03f]
> [   24.949631] pci 0000:00:03.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
> [   24.956534] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
> [   24.960683] pci 0000:00:04.0: reg 10: [io  0xc040-0xc07f]
> [   24.965639] pci 0000:00:04.0: reg 14: [mem 0xfebf1000-0xfebf1fff]
> [   24.996877] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
> [   25.000630] pci 0000:00:05.0: reg 10: [io  0xc080-0xc0bf]
> [   25.005633] pci 0000:00:05.0: reg 14: [mem 0xfebf2000-0xfebf2fff]
> [   25.033821] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
> [   25.038701] pci 0000:00:06.0: reg 10: [io  0xc0c0-0xc0ff]
> [   25.043661] pci 0000:00:06.0: reg 14: [mem 0xfebf3000-0xfebf3fff]
> [   25.070477] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
> [   25.074556] pci 0000:00:07.0: reg 10: [io  0xc100-0xc13f]
> [   25.079651] pci 0000:00:07.0: reg 14: [mem 0xfebf4000-0xfebf4fff]
> [   25.108472] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
> [   25.112547] pci 0000:00:08.0: reg 10: [io  0xc140-0xc17f]
> [   25.117608] pci 0000:00:08.0: reg 14: [mem 0xfebf5000-0xfebf5fff]
> [   25.146460] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
> [   25.150687] pci 0000:00:09.0: reg 10: [io  0xc180-0xc1bf]
> [   25.155540] pci 0000:00:09.0: reg 14: [mem 0xfebf6000-0xfebf6fff]
> [   25.182462] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
> [   25.185594] pci 0000:00:0a.0: reg 10: [mem 0xfebf7000-0xfebf700f]
> [   25.210718] pci_bus 0000:00: busn_res: [bus 00-ff] end is updated to 00
> [   25.484125] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
> [   25.976771] pci 0000:00:01.0: PIIX/ICH IRQ router [8086:7000]
> [   26.004630] PCI: pci_cache_line_size set to 64 bytes
> [   26.034653] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
> [   26.037611] e820: reserve RAM buffer [mem 0x1fffe000-0x1fffffff]
> [   43.128743] pnp: PnP ACPI: disabled
> [   48.026994] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
> [   48.028934] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
> [   48.043419] NET: Registered protocol family 2
> [   48.110116] TCP established hash table entries: 16384 (order: 6, 262144 bytes)
> [   48.144952] TCP bind hash table entries: 16384 (order: 8, 1310720 bytes)
> [   48.207877] TCP: Hash tables configured (established 16384 bind 16384)
> [   48.210941] TCP: reno registered
> [   48.214917] UDP hash table entries: 256 (order: 3, 49152 bytes)
> [   48.220898] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
> [   48.256922] NET: Registered protocol family 1
> [   48.310913] RPC: Registered named UNIX socket transport module.
> [   48.311938] RPC: Registered udp transport module.
> [   48.313890] RPC: Registered tcp transport module.
> [   48.314835] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [   48.317466] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
> [   48.318477] pci 0000:00:01.0: PIIX3: Enabling Passive Release
> [   48.320905] pci 0000:00:01.0: Activating ISA DMA hang workarounds
> [   48.324166] pci 0000:00:02.0: Boot video device
> [   48.331010] PCI: CLS 0 bytes, default 64
> [   59.987586] DMA-API: preallocated 32768 debug entries
> [   59.988100] DMA-API: debugging enabled by kernel config
> [   60.005678] kvm: no hardware support
> [   60.040532] platform rtc_cmos: registered platform RTC device (no PNP device found)
> [   60.048449] Machine check injector initialized
> [   60.323336] microcode: no support for this CPU vendor
> [   61.123075] Initializing RT-Tester: OK
> [   61.139276] audit: initializing netlink socket (disabled)
> [   61.150031] type=2000 audit(1344243088.145:1): initialized
> [   62.110030] Kprobe smoke test started
> [   62.446496] Kprobe smoke test passed successfully
> [   62.455825] rcu-torture:--- Start of test: nreaders=2 nfakewriters=4 stat_interval=0 verbose=0 test_no_idle_hz=0 shuffle_interval=3 stutter=5 irqreader=1 fqs_duration=0 fqs_holdoff=0 fqs_stutter=3 test_boost=1/0 test_boost_interval=7 test_boost_duration=4 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
> [   62.799716] HugeTLB registered 2 MB page size, pre-allocated 0 pages
> [   76.002884] NFS: Registering the id_resolver key type
> [   76.016777] Key type id_resolver registered
> [   76.018968] Key type id_legacy registered
> [   76.023243] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> [   76.861165] fuse init (API version 7.19)
> [   77.120711] JFS: nTxBlock = 3678, nTxLock = 29428
> [   77.454568] SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
> [   79.058568] NILFS version 2 loaded
> [   79.653304] Btrfs loaded
> [   79.659334] msgmni has been set to 919
> [   79.954554] async_tx: api initialized (async)
> [   80.037358] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
> [   80.040104] io scheduler noop registered
> [   80.041096] io scheduler deadline registered
> [   80.157085] io scheduler cfq registered (default)
> [   80.158055] start plist test
> [   80.197240] end plist test
> [   80.370781] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> [   80.510024] ioatdma: Intel(R) QuickData Technology Driver 4.00
> [   80.654457] PCI: setting IRQ 11 as level-triggered
> [   80.656385] virtio-pci 0000:00:04.0: found PCI INT A -> IRQ 11
> [   80.679254] virtio-pci 0000:00:04.0: setting latency timer to 64
> [   80.749325] PCI: setting IRQ 10 as level-triggered
> [   80.750912] virtio-pci 0000:00:05.0: found PCI INT A -> IRQ 10
> [   80.768138] virtio-pci 0000:00:05.0: setting latency timer to 64
> [   80.806203] virtio-pci 0000:00:06.0: found PCI INT A -> IRQ 10
> [   80.826034] virtio-pci 0000:00:06.0: setting latency timer to 64
> [   80.867976] virtio-pci 0000:00:07.0: setting latency timer to 64
> [   80.913207] virtio-pci 0000:00:08.0: setting latency timer to 64
> [   80.954375] virtio-pci 0000:00:09.0: setting latency timer to 64
> [  113.178389] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [  113.253424] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> [  113.650125] Initializing Nozomi driver 2.1d
> [  113.968566] Non-volatile memory driver v1.3
> [  114.034006] Linux agpgart interface v0.103
> [  114.169105] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
> [  114.170094] Hangcheck: Using getrawmonotonic().
> [  114.211011] [drm] Initialized drm 1.1.0 20060810
> [  114.717872] Floppy drive(s): fd0 is 1.44M
> [  114.813831] FDC 0 is a S82078B
> [  117.132863] brd: module loaded
> [  118.395698] loop: module loaded
> [  118.779226]  vda: unknown partition table
> [  119.039407]  vdb: unknown partition table
> [  119.252481]  vdc: unknown partition table
> [  119.486374]  vdd: unknown partition table
> [  119.731008]  vde: unknown partition table
> [  119.967304]  vdf: unknown partition table
> [  120.099076] lkdtm: No crash points registered, enable through debugfs
> [  120.134057] Uniform Multi-Platform E-IDE driver
> [  120.223171] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
> [  120.245045] piix 0000:00:01.1: not 100% native mode: will probe irqs later
> [  120.249072] pci 0000:00:01.1: setting latency timer to 64
> [  120.251169]     ide0: BM-DMA at 0xc1c0-0xc1c7
> [  120.259219]     ide1: BM-DMA at 0xc1c8-0xc1cf
> [  120.263254] Probing IDE interface ide0...
> [  120.846066] Probing IDE interface ide1...
> [  121.524107] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
> [  122.250848] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
> [  122.262821] hdc: MWDMA2 mode selected
> [  122.290828] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> [  122.306774] ide1 at 0x170-0x177,0x376 on irq 15
> [  122.612624] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
> [  122.614797] ide-gd driver 1.18
> [  123.150704] Loading iSCSI transport class v2.0-870.
> [  124.212663] Loading Adaptec I2O RAID: Version 2.4 Build 5go
> [  124.214444] Detecting Adaptec I2O RAID controllers...
> [  124.381586] Adaptec aacraid driver 1.2-0[29800]-ms
> [  124.587385] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
> [  125.208413] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.04.00.03-k.
> [  125.526241] iscsi: registered transport (qla4xxx)
> [  125.603482] QLogic iSCSI HBA Driver
> [  125.709449] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
> [  125.819340] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
> [  125.906400] megasas: 00.00.06.15-rc1 Mon. Mar. 19 17:00:00 PDT 2012
> [  126.005306] mpt2sas version 13.100.00.00 loaded
> [  126.192305] GDT-HA: Storage RAID Controller Driver. Version: 3.05
> [  129.608591] tun: Universal TUN/TAP device driver, 1.6
> [  129.610531] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> [  129.898904] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.12 (June 29, 2012)
> [  129.958959] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
> [  129.960554] e1000: Copyright (c) 1999-2006 Intel Corporation.
> [  129.975805] e1000 0000:00:03.0: found PCI INT A -> IRQ 11
> [  130.000679] e1000 0000:00:03.0: setting latency timer to 64
> [  130.753122] e1000 0000:00:03.0: eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
> [  130.760528] e1000 0000:00:03.0: eth0: Intel(R) PRO/1000 Network Connection
> [  130.805928] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
> [  130.807360] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
> [  130.858556] igb: Intel(R) Gigabit Ethernet Network Driver - version 4.0.1-k
> [  130.863392] igb: Copyright (c) 2007-2012 Intel Corporation.
> [  130.913756] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.1-k
> [  130.915333] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
> [  130.949092] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.9.15-k
> [  130.950421] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> [  131.092393] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
> [  131.094383] ixgb: Copyright (c) 1999-2008 Intel Corporation.
> [  131.220657] jme: JMicron JMC2XX ethernet driver version 1.0.8
> [  131.298874] sky2: driver version 1.30
> [  131.490726] usbcore: registered new interface driver catc
> [  131.520678] usbcore: registered new interface driver kaweth
> [  131.521253] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
> [  131.561310] usbcore: registered new interface driver pegasus
> [  131.590610] usbcore: registered new interface driver rtl8150
> [  131.630533] usbcore: registered new interface driver asix
> [  131.655985] usbcore: registered new interface driver cdc_ether
> [  131.737972] usbcore: registered new interface driver cdc_eem
> [  131.806247] usbcore: registered new interface driver dm9601
> [  131.849787] usbcore: registered new interface driver smsc75xx
> [  131.891227] usbcore: registered new interface driver smsc95xx
> [  131.923322] usbcore: registered new interface driver gl620a
> [  131.950512] usbcore: registered new interface driver net1080
> [  131.987620] usbcore: registered new interface driver plusb
> [  132.016183] usbcore: registered new interface driver rndis_host
> [  132.052528] usbcore: registered new interface driver cdc_subset
> [  132.082274] usbcore: registered new interface driver zaurus
> [  132.111239] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
> [  132.143237] usbcore: registered new interface driver int51x1
> [  132.177332] usbcore: registered new interface driver cdc_ncm
> [  132.180175] Fusion MPT base driver 3.04.20
> [  132.181074] Copyright (c) 1999-2008 LSI Corporation
> [  132.189568] Fusion MPT SPI Host driver 3.04.20
> [  132.224477] Fusion MPT FC Host driver 3.04.20
> [  132.259530] Fusion MPT SAS Host driver 3.04.20
> [  132.297526] Fusion MPT misc device (ioctl) driver 3.04.20
> [  132.344462] mptctl: Registered with Fusion MPT base driver
> [  132.345084] mptctl: /dev/mptctl @ (major,minor=10,220)
> [  132.375416] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [  132.376243] ehci_hcd: block sizes: qh 104 qtd 96 itd 192 sitd 96
> [  132.418477] uhci_hcd: USB Universal Host Controller Interface driver
> [  132.517162] Initializing USB Mass Storage driver...
> [  132.550360] usbcore: registered new interface driver usb-storage
> [  132.551057] USB Mass Storage support registered.
> [  132.599105] usbcore: registered new interface driver libusual
> [  132.626606] usbcore: registered new interface driver ums-alauda
> [  132.654285] usbcore: registered new interface driver ums-cypress
> [  132.685301] usbcore: registered new interface driver ums-datafab
> [  132.717281] usbcore: registered new interface driver ums-freecom
> [  132.747103] usbcore: registered new interface driver ums-isd200
> [  132.771815] usbcore: registered new interface driver ums-jumpshot
> [  132.795421] usbcore: registered new interface driver ums-karma
> [  132.826092] usbcore: registered new interface driver ums-onetouch
> [  132.856278] usbcore: registered new interface driver ums-sddr09
> [  132.891405] usbcore: registered new interface driver ums-sddr55
> [  132.927327] usbcore: registered new interface driver ums-usbat
> [  133.001286] usbcore: registered new interface driver usbserial
> [  133.051991] usbcore: registered new interface driver usbserial_generic
> [  133.091049] USB Serial support registered for generic
> [  133.093329] usbserial: USB Serial Driver core
> [  133.128003] usbcore: registered new interface driver belkin_sa
> [  133.159984] USB Serial support registered for Belkin / Peracom / GoHubs USB Serial Adapter
> [  133.191185] usbcore: registered new interface driver mct_u232
> [  133.220235] USB Serial support registered for MCT U232
> [  133.266313] usbcore: registered new interface driver usbtest
> [  133.374235] i8042: PNP: No PS/2 controller found. Probing ports directly.
> [  133.442186] serio: i8042 KBD port at 0x60,0x64 irq 1
> [  133.447001] serio: i8042 AUX port at 0x60,0x64 irq 12
> [  133.643217] mousedev: PS/2 mouse device common for all mice
> [  133.936638] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
> [  134.300067] rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
> [  134.327050] rtc0: alarms up to one day, 114 bytes nvram
> [  134.808027] rtc-test rtc-test.0: rtc core: registered test as rtc1
> [  135.088463] rtc-test rtc-test.1: rtc core: registered test as rtc2
> [  135.166815] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
> [  135.288741] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input1
> [  135.336425] i6300esb: initialized (0xffffc9000059a000). heartbeat=30 sec (nowayout=0)
> [  135.381889] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
> [  135.433928] iTCO_vendor_support: vendor-support=0
> [  135.463921] watchdog: Software Watchdog: cannot register miscdev on minor=130 (err=-16).
> [  135.465832] watchdog: Software Watchdog: a legacy watchdog module is probably present.
> [  135.553918] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
> [  135.556694] md: linear personality registered for level -1
> [  135.558736] md: raid0 personality registered for level 0
> [  135.559606] md: raid1 personality registered for level 1
> [  135.561732] md: raid10 personality registered for level 10
> [  135.563607] md: raid6 personality registered for level 6
> [  135.565773] md: raid5 personality registered for level 5
> [  135.566591] md: raid4 personality registered for level 4
> [  135.568609] md: multipath personality registered for level -4
> [  135.570836] md: faulty personality registered for level -5
> [  135.864755] device-mapper: uevent: version 1.0.3
> [  136.034738] device-mapper: ioctl: 4.23.0-ioctl (2012-07-25) initialised: dm-devel@redhat.com
> [  136.296766] device-mapper: multipath: version 1.5.0 loaded
> [  136.302672] device-mapper: multipath round-robin: version 1.0.0 loaded
> [  136.306752] device-mapper: multipath queue-length: version 0.1.0 loaded
> [  136.309647] device-mapper: multipath service-time: version 0.2.0 loaded
> [  136.620525] device-mapper: dm-log-userspace: version 1.1.0 loaded
> [  136.625742] cpuidle: using governor ladder
> [  136.627680] cpuidle: using governor menu
> [  136.724704] usbcore: registered new interface driver usbhid
> [  136.726432] usbhid: USB HID core driver
> [  136.819877] dell_wmi: No known WMI GUID found
> [  136.821552] acer_wmi: Acer Laptop ACPI-WMI Extras
> [  136.823800] acer_wmi: No or unsupported WMI interface, unable to load
> [  137.023784] oprofile: using timer interrupt.
> [  137.085627] netem: version 1.3
> [  137.087436] Netfilter messages via NETLINK v0.30.
> [  137.101011] nf_conntrack version 0.5.0 (3678 buckets, 14712 max)
> [  137.259510] ctnetlink v0.93: registering with nfnetlink.
> [  137.273369] NF_TPROXY: Transparent proxy support initialized, version 4.1.0
> [  137.275363] NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
> [  137.345774] xt_time: kernel timezone is -0000
> [  137.396734] ip_tables: (C) 2000-2006 Netfilter Core Team
> [  137.454579] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
> [  137.492762] arp_tables: (C) 2002 David S. Miller
> [  137.522934] TCP: bic registered
> [  137.523361] TCP: cubic registered
> [  137.524323] TCP: westwood registered
> [  137.525313] TCP: highspeed registered
> [  137.527318] TCP: hybla registered
> [  137.528338] TCP: htcp registered
> [  137.529329] TCP: vegas registered
> [  137.531394] TCP: veno registered
> [  137.532332] TCP: scalable registered
> [  137.534330] TCP: lp registered
> [  137.535380] TCP: yeah registered
> [  137.536304] TCP: illinois registered
> [  137.537304] Initializing XFRM netlink socket
> [  137.914444] NET: Registered protocol family 10
> [  138.154335] sit: IPv6 over IPv4 tunneling driver
> [  138.331786] NET: Registered protocol family 17
> [  138.337328] NET: Registered protocol family 15
> [  138.412371] Bridge firewalling registered
> [  138.418218] Ebtables v2.0 registered
> [  138.479302] Key type dns_resolver registered
> [  138.497350] 
> [  138.497350] printing PIC contents
> [  138.499169] ... PIC  IMR: 22b8
> [  138.499944] ... PIC  IRR: 0011
> [  138.500118] ... PIC  ISR: 0000
> [  138.502172] ... PIC ELCR: 0c00
> [  138.761161] PM: Hibernation image not present or could not be loaded.
> [  138.776451] registered taskstats version 1
> [  138.867207]   Magic number: 8:97:826
> [  138.874362] tty ptyt6: hash matches
> [  138.922292] console [netcon0] enabled
> [  138.924249] netconsole: network logging started
> [  138.928475] rtc_cmos rtc_cmos: setting system clock to 2012-08-06 08:52:49 UTC (1344243169)
> [  139.298118] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> [  141.304080] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
> [  141.317168] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [  141.419998] Sending DHCP requests ., OK
> [  141.519255] IP-Config: Got DHCP answer from 10.0.2.2, my address is 10.0.2.15
> [  141.758807] IP-Config: Complete:
> [  141.760657]      device=eth0, addr=10.0.2.15, mask=255.255.255.0, gw=10.0.2.2
> [  141.761641]      host=kvm, domain=, nis-domain=(none)
> [  141.763722]      bootserver=10.0.2.2, rootserver=10.239.97.14, rootpath=
> [  141.765969] ALSA device list:
> [  141.767711]   No soundcards found.
> [  141.834014] md: Waiting for all devices to be available before autodetect
> [  141.834628] md: If you don't use raid, use raid=noautodetect
> [  142.132967] md: Autodetecting RAID arrays.
> [  142.134615] md: Scanned 0 and added 0 devices.
> [  142.135566] md: autorun ...
> [  142.137649] md: ... autorun DONE.
> [  142.961110] VFS: Mounted root (nfs filesystem) on device 0:14.
> [  143.008676] devtmpfs: mounted
> [  143.016941] debug: unmapping init [mem 0xffffffff8203e000-0xffffffff82302fff]
> [  160.800554] modprobe (1805) used greatest stack depth: 3000 bytes left
> [  176.057577] S01glibc.sh (1810) used greatest stack depth: 2832 bytes left
> [  243.305012] udevd[1889]: starting version 175
> [  762.537076] S07hdparm (2047) used greatest stack depth: 2488 bytes left
> [ 1484.591307] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> [ 1484.680006] NFSD: starting 90-second grace period
> Kernel tests: Boot OK!
> [ 1613.550703] Adding 307196k swap on /dev/vda.  Priority:-1 extents:1 across:307196k 
> [ 1659.138772] [sched_delayed] sched: RT throttling activated
> [ 2866.131281] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.131726] 
> [ 2866.132188] =========================
> [ 2866.132281] [ BUG: held lock freed! ]
> [ 2866.132281] 3.6.0-rc1+ #622 Not tainted
> [ 2866.132281] -------------------------
> [ 2866.132281] kworker/0:1/652 is freeing memory ffff880019ec0000-ffff880019ec0a1f, with a lock still held there!
> [ 2866.132281]  (sk_lock-AF_INET-RPC){+.+...}, at: [<ffffffff81903619>] tcp_sendmsg+0x29/0xcc6
> [ 2866.132281] 4 locks held by kworker/0:1/652:
> [ 2866.132281]  #0:  (rpciod){.+.+.+}, at: [<ffffffff81083567>] process_one_work+0x1de/0x47f
> [ 2866.132281]  #1:  ((&task->u.tk_work)){+.+.+.}, at: [<ffffffff81083567>] process_one_work+0x1de/0x47f
> [ 2866.132281]  #2:  (sk_lock-AF_INET-RPC){+.+...}, at: [<ffffffff81903619>] tcp_sendmsg+0x29/0xcc6
> [ 2866.132281]  #3:  (&icsk->icsk_retransmit_timer){+.-...}, at: [<ffffffff81078017>] run_timer_softirq+0x1ad/0x35f
> [ 2866.132281] 
> [ 2866.132281] stack backtrace:
> [ 2866.132281] Pid: 652, comm: kworker/0:1 Not tainted 3.6.0-rc1+ #622
> [ 2866.132281] Call Trace:
> [ 2866.132281]  <IRQ>  [<ffffffff810bc527>] debug_check_no_locks_freed+0x112/0x159
> [ 2866.132281]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.132281]  [<ffffffff811549fa>] kmem_cache_free+0x6b/0x13a
> [ 2866.132281]  [<ffffffff818a0839>] __sk_free+0xfd/0x114
> [ 2866.132281]  [<ffffffff818a08c0>] sk_free+0x1c/0x1e
> [ 2866.132281]  [<ffffffff81911e1c>] tcp_write_timer+0x51/0x56
> [ 2866.132281]  [<ffffffff81078082>] run_timer_softirq+0x218/0x35f
> [ 2866.132281]  [<ffffffff81078017>] ? run_timer_softirq+0x1ad/0x35f
> [ 2866.132281]  [<ffffffff810f5831>] ? rb_commit+0x58/0x85
> [ 2866.132281]  [<ffffffff81911dcb>] ? tcp_write_timer_handler+0x148/0x148
> [ 2866.132281]  [<ffffffff81070bd6>] __do_softirq+0xcb/0x1f9
> [ 2866.132281]  [<ffffffff81a0a00c>] ? _raw_spin_unlock+0x29/0x2e
> [ 2866.132281]  [<ffffffff81a1227c>] call_softirq+0x1c/0x30
> [ 2866.132281]  [<ffffffff81039f38>] do_softirq+0x4a/0xa6
> [ 2866.132281]  [<ffffffff81070f2b>] irq_exit+0x51/0xad
> [ 2866.132281]  [<ffffffff81a129cd>] do_IRQ+0x9d/0xb4
> [ 2866.132281]  [<ffffffff81a0a3ef>] common_interrupt+0x6f/0x6f
> [ 2866.132281]  <EOI>  [<ffffffff8109d006>] ? sched_clock_cpu+0x58/0xd1
> [ 2866.132281]  [<ffffffff81a0a172>] ? _raw_spin_unlock_irqrestore+0x4c/0x56
> [ 2866.132281]  [<ffffffff81078692>] mod_timer+0x178/0x1a9
> [ 2866.132281]  [<ffffffff818a00aa>] sk_reset_timer+0x19/0x26
> [ 2866.132281]  [<ffffffff8190b2cc>] tcp_rearm_rto+0x99/0xa4
> [ 2866.132281]  [<ffffffff8190dfba>] tcp_event_new_data_sent+0x6e/0x70
> [ 2866.132281]  [<ffffffff8190f7ea>] tcp_write_xmit+0x7de/0x8e4
> [ 2866.132281]  [<ffffffff818a565d>] ? __alloc_skb+0xa0/0x1a1
> [ 2866.132281]  [<ffffffff8190f952>] __tcp_push_pending_frames+0x2e/0x8a
> [ 2866.132281]  [<ffffffff81904122>] tcp_sendmsg+0xb32/0xcc6
> [ 2866.132281]  [<ffffffff819229c2>] inet_sendmsg+0xaa/0xd5
> [ 2866.132281]  [<ffffffff81922918>] ? inet_autobind+0x5f/0x5f
> [ 2866.132281]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
> [ 2866.132281]  [<ffffffff8189adab>] sock_sendmsg+0xa3/0xc4
> [ 2866.132281]  [<ffffffff810f5de6>] ? rb_reserve_next_event+0x26f/0x2d5
> [ 2866.132281]  [<ffffffff8103e6a9>] ? native_sched_clock+0x29/0x6f
> [ 2866.132281]  [<ffffffff8103e6f8>] ? sched_clock+0x9/0xd
> [ 2866.132281]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
> [ 2866.132281]  [<ffffffff8189ae03>] kernel_sendmsg+0x37/0x43
> [ 2866.132281]  [<ffffffff8199ce49>] xs_send_kvec+0x77/0x80
> [ 2866.132281]  [<ffffffff8199cec1>] xs_sendpages+0x6f/0x1a0
> [ 2866.132281]  [<ffffffff8107826d>] ? try_to_del_timer_sync+0x55/0x61
> [ 2866.132281]  [<ffffffff8199d0d2>] xs_tcp_send_request+0x55/0xf1
> [ 2866.132281]  [<ffffffff8199bb90>] xprt_transmit+0x89/0x1db
> [ 2866.132281]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.132281]  [<ffffffff81999d92>] call_transmit+0x1c5/0x20e
> [ 2866.132281]  [<ffffffff819a0d55>] __rpc_execute+0x6f/0x225
> [ 2866.132281]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.132281]  [<ffffffff819a0f33>] rpc_async_schedule+0x28/0x34
> [ 2866.132281]  [<ffffffff810835d6>] process_one_work+0x24d/0x47f
> [ 2866.132281]  [<ffffffff81083567>] ? process_one_work+0x1de/0x47f
> [ 2866.132281]  [<ffffffff819a0f0b>] ? __rpc_execute+0x225/0x225
> [ 2866.132281]  [<ffffffff81083a6d>] worker_thread+0x236/0x317
> [ 2866.132281]  [<ffffffff81083837>] ? process_scheduled_works+0x2f/0x2f
> [ 2866.132281]  [<ffffffff8108b7b8>] kthread+0x9a/0xa2
> [ 2866.132281]  [<ffffffff81a12184>] kernel_thread_helper+0x4/0x10
> [ 2866.132281]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.132281]  [<ffffffff8108b71e>] ? __init_kthread_worker+0x5a/0x5a
> [ 2866.132281]  [<ffffffff81a12180>] ? gs_change+0x13/0x13
> [ 2866.308506] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.309689] =============================================================================
> [ 2866.310254] BUG TCP (Not tainted): Object already free
> [ 2866.310254] -----------------------------------------------------------------------------
> [ 2866.310254] 
> [ 2866.310254] INFO: Allocated in sk_prot_alloc.isra.35+0x30/0xd2 age=2724046 cpu=0 pid=652
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] INFO: Freed in __sk_free+0xfd/0x114 age=176 cpu=0 pid=652
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] 
> [ 2866.310254] INFO: Slab 0xffffea000067b000 objects=11 used=9 fp=0xffff880019ec0000 flags=0x100000000004081
> [ 2866.310254] INFO: Object 0xffff880019ec0000 @offset=0 fp=0xffff880019ec5c00
> [ 2866.310254] 
> [ 2866.310254] Object ffff880019ec0000: 0a ef 61 0e 0a 00 02 0f bb 7c 0f b9 02 00 01 00  ..a......|......
> [ 2866.310254] Object ffff880019ec0010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0020: 98 7c eb 19 00 88 ff ff 00 e0 ff 81 ff ff ff ff  .|..............
> [ 2866.310254] Object ffff880019ec0030: 77 79 00 00 00 00 00 00 b0 eb 0f 00 00 c9 ff ff  wy..............
> [ 2866.310254] Object ffff880019ec0040: ff ff ff ff 01 00 00 00 dc dc 00 00 ad 4e ad de  .............N..
> [ 2866.310254] Object ffff880019ec0050: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0060: 60 e8 e2 82 ff ff ff ff 50 d3 51 82 ff ff ff ff  `.......P.Q.....
> [ 2866.310254] Object ffff880019ec0070: b0 e6 51 82 ff ff ff ff f1 0c ea 81 ff ff ff ff  ..Q.............
> [ 2866.310254] Object ffff880019ec0080: 00 00 00 00 00 00 00 00 e6 1d 91 81 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0090: 01 00 00 00 00 00 00 00 02 02 00 00 ad 4e ad de  .............N..
> [ 2866.310254] Object ffff880019ec00a0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec00b0: 80 e8 e2 82 ff ff ff ff 00 fc 51 82 ff ff ff ff  ..........Q.....
> [ 2866.310254] Object ffff880019ec00c0: 00 00 00 00 00 00 00 00 81 8f dc 81 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec00d0: 00 00 00 00 00 00 00 00 57 42 09 81 ff ff ff ff  ........WB......
> [ 2866.310254] Object ffff880019ec00e0: e0 00 ec 19 00 88 ff ff e0 00 ec 19 00 88 ff ff  ................
> [ 2866.310254] Object ffff880019ec00f0: 70 e8 e2 82 ff ff ff ff 40 d5 51 82 ff ff ff ff  p.......@.Q.....
> [ 2866.310254] Object ffff880019ec0100: 00 00 00 00 00 00 00 00 03 0d ea 81 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0120: 20 01 ec 19 00 88 ff ff 20 01 ec 19 00 88 ff ff   ....... .......
> [ 2866.310254] Object ffff880019ec0130: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.310254] Object ffff880019ec0140: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0150: c0 3e e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .>..............
> [ 2866.310254] Object ffff880019ec0160: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0190: 00 00 00 00 00 00 00 00 00 07 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec01a0: 00 00 00 00 68 7d 0b 00 00 00 00 00 00 00 00 00  ....h}..........
> [ 2866.310254] Object ffff880019ec01b0: 90 63 e9 19 00 88 ff ff 00 00 00 00 00 00 00 00  .c..............
> [ 2866.310254] Object ffff880019ec01c0: 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec01d0: 40 5d e9 19 00 88 ff ff 00 40 e9 19 00 88 ff ff  @].......@......
> [ 2866.310254] Object ffff880019ec01e0: 01 01 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.310254] Object ffff880019ec01f0: ff ff ff ff ff ff ff ff 28 40 e2 82 ff ff ff ff  ........(@......
> [ 2866.310254] Object ffff880019ec0200: 20 d9 51 82 ff ff ff ff 00 00 00 00 00 00 00 00   .Q.............
> [ 2866.310254] Object ffff880019ec0210: af 28 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  .(..............
> [ 2866.310254] Object ffff880019ec0220: 69 31 92 81 ff ff ff ff 00 00 00 00 00 00 00 00  i1..............
> [ 2866.310254] Object ffff880019ec0230: a8 57 00 00 00 00 00 00 80 e0 eb 19 00 88 ff ff  .W..............
> [ 2866.310254] Object ffff880019ec0240: 80 e0 eb 19 00 88 ff ff 01 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0250: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.310254] Object ffff880019ec0260: ff ff ff ff ff ff ff ff c0 3e e2 82 ff ff ff ff  .........>......
> [ 2866.310254] Object ffff880019ec0270: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0280: c5 1b da 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0290: 00 00 00 00 00 00 00 00 80 06 01 00 00 09 00 00  ................
> [ 2866.310254] Object ffff880019ec02a0: 20 00 00 00 00 00 00 00 89 4b 1b 40 00 00 00 00   ........K.@....
> [ 2866.310254] Object ffff880019ec02b0: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 01 00  ................
> [ 2866.310254] Object ffff880019ec02c0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec02d0: d0 02 ec 19 00 88 ff ff d0 02 ec 19 00 88 ff ff  ................
> [ 2866.310254] Object ffff880019ec02e0: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.310254] Object ffff880019ec02f0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0300: c0 3e e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .>..............
> [ 2866.310254] Object ffff880019ec0310: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0320: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0330: 00 e0 ff 81 ff ff ff ff 00 00 10 00 ed 1e af de  ................
> [ 2866.310254] Object ffff880019ec0340: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0350: f0 3e e2 82 ff ff ff ff 10 db 51 82 ff ff ff ff  .>........Q.....
> [ 2866.310254] Object ffff880019ec0360: 00 00 00 00 00 00 00 00 8c 30 e9 81 ff ff ff ff  .........0......
> [ 2866.310254] Object ffff880019ec0370: 00 00 00 00 00 00 00 00 71 d9 99 81 ff ff ff ff  ........q.......
> [ 2866.310254] Object ffff880019ec0380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0390: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec03a0: 00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff 7f  ................
> [ 2866.310254] Object ffff880019ec03b0: ff ff ff ff ff ff ff 7f 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec03c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec03d0: 00 00 00 00 00 00 00 00 00 72 38 82 ff ff ff ff  .........r8.....
> [ 2866.310254] Object ffff880019ec03e0: 98 11 91 81 ff ff ff ff 00 00 ec 19 00 88 ff ff  ................
> [ 2866.310254] Object ffff880019ec03f0: ff ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0410: 90 72 e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .r..............
> [ 2866.310254] Object ffff880019ec0420: 00 00 00 00 00 00 00 00 a1 28 e9 81 ff ff ff ff  .........(......
> [ 2866.310254] Object ffff880019ec0430: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0440: 00 36 65 c4 ff ff ff ff 80 31 c2 1d 00 88 ff ff  .6e......1......
> [ 2866.310254] Object ffff880019ec0450: 90 a2 e9 19 00 88 ff ff 40 0b 66 00 00 ea ff ff  ........@.f.....
> [ 2866.310254] Object ffff880019ec0460: 80 e0 eb 19 00 88 ff ff 03 00 00 00 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0470: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0480: 00 00 00 00 00 00 00 00 d3 d7 99 81 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0490: 4f d9 99 81 ff ff ff ff 47 d7 99 81 ff ff ff ff  O.......G.......
> [ 2866.310254] Object ffff880019ec04a0: cc d6 99 81 ff ff ff ff 18 28 91 81 ff ff ff ff  .........(......
> [ 2866.310254] Object ffff880019ec04b0: 80 36 92 81 ff ff ff ff 00 00 00 00 00 00 00 00  .6..............
> [ 2866.310254] Object ffff880019ec04c0: 08 01 8d 03 0a 00 02 0f ff ff 00 00 03 8d 32 0f  ..............2.
> [ 2866.310254] Object ffff880019ec04d0: 00 00 00 00 00 00 00 00 00 00 01 01 52 00 00 00  ............R...
> [ 2866.310254] Object ffff880019ec04e0: 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00  ................
> [ 2866.310254] Object ffff880019ec04f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0500: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0510: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0520: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0530: 03 00 00 00 01 00 00 00 00 00 00 00 00 00 06 02  ................
> [ 2866.310254] Object ffff880019ec0540: 00 00 00 00 0a 00 02 0f 0a ef 61 0e 08 01 03 8d  ..........a.....
> [ 2866.310254] Object ffff880019ec0550: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0560: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0570: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0590: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec05a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec05b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec05c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec05d0: 00 00 00 00 00 00 00 00 80 7c eb 19 00 88 ff ff  .........|......
> [ 2866.310254] Object ffff880019ec05e0: de 28 27 00 01 00 00 00 00 00 00 00 00 00 00 00  .('.............
> [ 2866.310254] Object ffff880019ec05f0: 00 02 20 00 00 00 ad de de 28 27 00 01 00 00 00  .. ......('.....
> [ 2866.310254] Object ffff880019ec0600: 00 72 38 82 ff ff ff ff cb 1d 91 81 ff ff ff ff  .r8.............
> [ 2866.310254] Object ffff880019ec0610: 00 00 ec 19 00 88 ff ff ff ff ff ff ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0620: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0630: 00 00 00 00 00 00 00 00 80 72 e2 82 ff ff ff ff  .........r......
> [ 2866.310254] Object ffff880019ec0640: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0650: fc 92 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0660: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0670: 00 02 20 00 00 00 ad de 5d 0f 27 00 01 00 00 00  .. .....].'.....
> [ 2866.310254] Object ffff880019ec0680: 00 72 38 82 ff ff ff ff 9f 16 91 81 ff ff ff ff  .r8.............
> [ 2866.310254] Object ffff880019ec0690: 00 00 ec 19 00 88 ff ff ff ff ff ff ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec06a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec06b0: 00 00 00 00 00 00 00 00 88 72 e2 82 ff ff ff ff  .........r......
> [ 2866.310254] Object ffff880019ec06c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec06d0: 19 93 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec06e0: 00 00 00 00 00 00 00 00 ae 02 00 00 dc 05 00 00  ................
> [ 2866.310254] Object ffff880019ec06f0: c0 9d 03 82 ff ff ff ff 10 10 bb 81 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0700: a9 e3 90 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0710: 00 0a 00 00 3c 00 00 00 5d 0f 27 00 01 00 00 00  ....<...].'.....
> [ 2866.310254] Object ffff880019ec0720: 3f 23 27 00 00 00 b4 05 00 00 00 00 dc 05 00 00  ?#'.............
> [ 2866.310254] Object ffff880019ec0730: 28 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00  (...............
> [ 2866.310254] Object ffff880019ec0740: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0750: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0760: 00 00 00 00 1f 00 00 00 97 99 fd ff 89 48 a9 2c  .............H.,
> [ 2866.310254] Object ffff880019ec0770: 97 99 fd ff 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0780: 14 00 03 00 50 10 22 38 3e 98 e2 02 3e 98 e2 02  ....P."8>...>...
> [ 2866.310254] Object ffff880019ec0790: 3e 98 e2 02 a5 78 b0 2c a5 78 b0 2c a5 78 b0 2c  >....x.,.x.,.x.,
> [ 2866.310254] Object ffff880019ec07a0: 1d 2a 27 00 53 2a 27 00 a8 07 ec 19 00 88 ff ff  .*'.S*'.........
> [ 2866.310254] Object ffff880019ec07b0: a8 07 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec07c0: c0 07 ec 19 00 88 ff ff c0 07 ec 19 00 88 ff ff  ................
> [ 2866.310254] Object ffff880019ec07d0: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.310254] Object ffff880019ec07e0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec07f0: 78 73 e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  xs..............
> [ 2866.310254] Object ffff880019ec0800: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.310254] Object ffff880019ec0810: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0820: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0830: 00 00 00 00 00 00 00 00 3e 98 e2 02 38 22 00 00  ........>...8"..
> [ 2866.310254] Object ffff880019ec0840: 38 22 00 00 b4 05 00 00 c8 91 05 00 c8 91 05 00  8"..............
> [ 2866.310254] Object ffff880019ec0850: 00 00 00 00 b4 05 00 01 00 01 00 00 78 03 00 00  ............x...
> [ 2866.310254] Object ffff880019ec0860: 3f 02 00 00 c8 00 00 00 3f 02 00 00 a5 78 b0 2c  ?.......?....x.,
> [ 2866.310254] Object ffff880019ec0870: 00 00 00 00 00 00 00 00 00 00 00 03 a5 78 b0 2c  .............x.,
> [ 2866.310254] Object ffff880019ec0880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0890: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec08a0: 00 00 b4 05 00 00 00 00 ff ff ff 7f 0a 00 00 00  ................
> [ 2866.310254] Object ffff880019ec08b0: 00 00 00 00 ff ff ff ff 00 00 00 00 1f 2a 27 00  .............*'.
> [ 2866.310254] Object ffff880019ec08c0: 00 00 00 00 00 00 00 00 00 00 00 00 c8 91 05 00  ................
> [ 2866.310254] Object ffff880019ec08d0: 1d 79 b0 2c 1d 79 b0 2c 00 00 00 00 00 00 00 00  .y.,.y.,........
> [ 2866.310254] Object ffff880019ec08e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec08f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0900: 00 00 00 00 00 00 00 00 08 09 ec 19 00 88 ff ff  ................
> [ 2866.310254] Object ffff880019ec0910: 08 09 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0920: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.310254] Object ffff880019ec0930: ff ff ff ff ff ff ff ff 78 73 e2 82 ff ff ff ff  ........xs......
> [ 2866.310254] Object ffff880019ec0940: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0950: c5 1b da 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0960: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0970: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0980: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec0990: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec09a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec09b0: 00 c0 eb 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec09c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec09d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Object ffff880019ec09e0: 00 00 00 00 00 00 00 00 00 00 00 00 e0 0c 00 00  ................
> [ 2866.310254] Object ffff880019ec09f0: 4e f7 e3 02 07 df 26 00 c8 91 05 00 0e 8b e2 02  N.....&.........
> [ 2866.310254] Object ffff880019ec0a00: 41 22 27 00 00 00 00 00 00 00 00 00 00 00 00 00  A"'.............
> [ 2866.310254] Object ffff880019ec0a10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.310254] Redzone ffff880019ec0a20: bb bb bb bb bb bb bb bb                          ........
> [ 2866.310254] Padding ffff880019ec0b60: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [ 2866.310254] Padding ffff880019ec0b70: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [ 2866.310254] Pid: 652, comm: kworker/0:1 Not tainted 3.6.0-rc1+ #622
> [ 2866.310254] Call Trace:
> [ 2866.310254]  <IRQ>  [<ffffffff811517b4>] ? print_section+0x3d/0x3f
> [ 2866.310254]  [<ffffffff811528f7>] print_trailer+0x12b/0x134
> [ 2866.310254]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.310254]  [<ffffffff81152938>] object_err+0x38/0x41
> [ 2866.310254]  [<ffffffff819fb4cd>] free_debug_processing+0x14d/0x264
> [ 2866.310254]  [<ffffffff8106b56e>] ? vprintk_emit+0x479/0x4a5
> [ 2866.310254]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.310254]  [<ffffffff819fb61e>] __slab_free+0x3a/0x383
> [ 2866.310254]  [<ffffffff810b791a>] ? trace_hardirqs_off_caller+0x1f/0xa0
> [ 2866.310254]  [<ffffffff819f825e>] ? printk+0x4d/0x4f
> [ 2866.310254]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.310254]  [<ffffffff81154a86>] kmem_cache_free+0xf7/0x13a
> [ 2866.310254]  [<ffffffff818a0839>] __sk_free+0xfd/0x114
> [ 2866.310254]  [<ffffffff818a089f>] sock_wfree+0x4f/0x54
> [ 2866.310254]  [<ffffffff8190dab9>] tcp_wfree+0xca/0xd2
> [ 2866.310254]  [<ffffffff818a4a8c>] skb_release_head_state+0x7f/0xd3
> [ 2866.310254]  [<ffffffff818a4897>] __kfree_skb+0x13/0x7e
> [ 2866.310254]  [<ffffffff818a4968>] consume_skb+0x40/0x6c
> [ 2866.310254]  [<ffffffff818ae25b>] dev_kfree_skb_any+0x36/0x38
> [ 2866.310254]  [<ffffffff816dc0e0>] e1000_unmap_and_free_tx_resource.isra.24+0xd5/0xed
> [ 2866.310254]  [<ffffffff816dc1ae>] e1000_clean+0xb6/0x6c6
> [ 2866.310254]  [<ffffffff818ae4f4>] net_rx_action+0xb5/0x1f3
> [ 2866.310254]  [<ffffffff81070bd6>] __do_softirq+0xcb/0x1f9
> [ 2866.310254]  [<ffffffff81a1227c>] call_softirq+0x1c/0x30
> [ 2866.310254]  <EOI>  [<ffffffff81039f38>] do_softirq+0x4a/0xa6
> [ 2866.310254]  [<ffffffff818faaaa>] ? ip_finish_output+0x413/0x501
> [ 2866.310254]  [<ffffffff81070939>] local_bh_enable+0xb2/0xe6
> [ 2866.310254]  [<ffffffff818faaaa>] ip_finish_output+0x413/0x501
> [ 2866.310254]  [<ffffffff818fa967>] ? ip_finish_output+0x2d0/0x501
> [ 2866.310254]  [<ffffffff818fbf0d>] ip_output+0x8a/0xdf
> [ 2866.310254]  [<ffffffff818fb688>] ip_local_out+0x59/0x72
> [ 2866.310254]  [<ffffffff818fb9db>] ip_queue_xmit+0x33a/0x3c3
> [ 2866.310254]  [<ffffffff818fb6a1>] ? ip_local_out+0x72/0x72
> [ 2866.310254]  [<ffffffff8190ef0d>] tcp_transmit_skb+0x745/0x7aa
> [ 2866.310254]  [<ffffffff8190f7db>] tcp_write_xmit+0x7cf/0x8e4
> [ 2866.310254]  [<ffffffff818a565d>] ? __alloc_skb+0xa0/0x1a1
> [ 2866.310254]  [<ffffffff8190f952>] __tcp_push_pending_frames+0x2e/0x8a
> [ 2866.310254]  [<ffffffff81904122>] tcp_sendmsg+0xb32/0xcc6
> [ 2866.310254]  [<ffffffff81153b92>] ? deactivate_slab+0x39b/0x3e6
> [ 2866.310254]  [<ffffffff819229c2>] inet_sendmsg+0xaa/0xd5
> [ 2866.310254]  [<ffffffff81922918>] ? inet_autobind+0x5f/0x5f
> [ 2866.310254]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
> [ 2866.310254]  [<ffffffff8189adab>] sock_sendmsg+0xa3/0xc4
> [ 2866.310254]  [<ffffffff81153b92>] ? deactivate_slab+0x39b/0x3e6
> [ 2866.310254]  [<ffffffff8103e6a9>] ? native_sched_clock+0x29/0x6f
> [ 2866.310254]  [<ffffffff8103e6f8>] ? sched_clock+0x9/0xd
> [ 2866.310254]  [<ffffffff810ee7f1>] ? trace_clock_local+0x9/0xb
> [ 2866.310254]  [<ffffffff8189ae03>] kernel_sendmsg+0x37/0x43
> [ 2866.310254]  [<ffffffff8199ce49>] xs_send_kvec+0x77/0x80
> [ 2866.310254]  [<ffffffff8199cec1>] xs_sendpages+0x6f/0x1a0
> [ 2866.310254]  [<ffffffff8107826d>] ? try_to_del_timer_sync+0x55/0x61
> [ 2866.310254]  [<ffffffff810782f7>] ? del_timer_sync+0x7e/0xc9
> [ 2866.310254]  [<ffffffff8199d0d2>] xs_tcp_send_request+0x55/0xf1
> [ 2866.310254]  [<ffffffff8199bb90>] xprt_transmit+0x89/0x1db
> [ 2866.310254]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.310254]  [<ffffffff81999d92>] call_transmit+0x1c5/0x20e
> [ 2866.310254]  [<ffffffff819a0d55>] __rpc_execute+0x6f/0x225
> [ 2866.310254]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.310254]  [<ffffffff819a0f33>] rpc_async_schedule+0x28/0x34
> [ 2866.310254]  [<ffffffff810835d6>] process_one_work+0x24d/0x47f
> [ 2866.310254]  [<ffffffff81083567>] ? process_one_work+0x1de/0x47f
> [ 2866.310254]  [<ffffffff819a0f0b>] ? __rpc_execute+0x225/0x225
> [ 2866.310254]  [<ffffffff81083a6d>] worker_thread+0x236/0x317
> [ 2866.310254]  [<ffffffff81083837>] ? process_scheduled_works+0x2f/0x2f
> [ 2866.310254]  [<ffffffff8108b7b8>] kthread+0x9a/0xa2
> [ 2866.310254]  [<ffffffff81a12184>] kernel_thread_helper+0x4/0x10
> [ 2866.310254]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.310254]  [<ffffffff8108b71e>] ? __init_kthread_worker+0x5a/0x5a
> [ 2866.310254]  [<ffffffff81a12180>] ? gs_change+0x13/0x13
> [ 2866.310254] FIX TCP: Object at 0xffff880019ec0000 not freed
> [ 2866.399835] IPv4: Attempt to release TCP socket in state 2 ffff880019ec0000
> [ 2866.401467] =============================================================================
> [ 2866.402240] BUG TCP (Not tainted): Object already free
> [ 2866.402240] -----------------------------------------------------------------------------
> [ 2866.402240] 
> [ 2866.402240] INFO: Allocated in sk_prot_alloc.isra.35+0x30/0xd2 age=2724138 cpu=0 pid=652
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] INFO: Freed in __sk_free+0xfd/0x114 age=268 cpu=0 pid=652
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] 
> [ 2866.402240] INFO: Slab 0xffffea000067b000 objects=11 used=9 fp=0xffff880019ec0000 flags=0x100000000004081
> [ 2866.402240] INFO: Object 0xffff880019ec0000 @offset=0 fp=0xffff880019ec5c00
> [ 2866.402240] 
> [ 2866.402240] Object ffff880019ec0000: 0a ef 61 0e 0a 00 02 0f bb 7c 0f b9 02 00 02 00  ..a......|......
> [ 2866.402240] Object ffff880019ec0010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0020: 98 7c eb 19 00 88 ff ff 00 e0 ff 81 ff ff ff ff  .|..............
> [ 2866.402240] Object ffff880019ec0030: 77 79 00 00 00 00 00 00 b0 eb 0f 00 00 c9 ff ff  wy..............
> [ 2866.402240] Object ffff880019ec0040: ff ff ff ff 01 00 00 00 e2 e2 00 00 ad 4e ad de  .............N..
> [ 2866.402240] Object ffff880019ec0050: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0060: 60 e8 e2 82 ff ff ff ff 50 d3 51 82 ff ff ff ff  `.......P.Q.....
> [ 2866.402240] Object ffff880019ec0070: b0 e6 51 82 ff ff ff ff f1 0c ea 81 ff ff ff ff  ..Q.............
> [ 2866.402240] Object ffff880019ec0080: 00 00 00 00 00 00 00 00 e6 1d 91 81 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0090: 01 00 00 00 00 00 00 00 02 02 00 00 ad 4e ad de  .............N..
> [ 2866.402240] Object ffff880019ec00a0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec00b0: 80 e8 e2 82 ff ff ff ff 00 fc 51 82 ff ff ff ff  ..........Q.....
> [ 2866.402240] Object ffff880019ec00c0: 00 00 00 00 00 00 00 00 81 8f dc 81 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec00d0: 00 00 00 00 00 00 00 00 57 42 09 81 ff ff ff ff  ........WB......
> [ 2866.402240] Object ffff880019ec00e0: e0 00 ec 19 00 88 ff ff e0 00 ec 19 00 88 ff ff  ................
> [ 2866.402240] Object ffff880019ec00f0: 70 e8 e2 82 ff ff ff ff 40 d5 51 82 ff ff ff ff  p.......@.Q.....
> [ 2866.402240] Object ffff880019ec0100: 00 00 00 00 00 00 00 00 03 0d ea 81 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0120: 20 01 ec 19 00 88 ff ff 20 01 ec 19 00 88 ff ff   ....... .......
> [ 2866.402240] Object ffff880019ec0130: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.402240] Object ffff880019ec0140: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0150: c0 3e e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .>..............
> [ 2866.402240] Object ffff880019ec0160: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0190: 00 00 00 00 00 00 00 00 00 fb ff ff 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec01a0: 00 00 00 00 68 7d 0b 00 00 00 00 00 00 00 00 00  ....h}..........
> [ 2866.402240] Object ffff880019ec01b0: 90 63 e9 19 00 88 ff ff 00 00 00 00 00 00 00 00  .c..............
> [ 2866.402240] Object ffff880019ec01c0: 00 00 00 00 00 00 00 00 00 43 00 00 00 00 00 00  .........C......
> [ 2866.402240] Object ffff880019ec01d0: 40 5d e9 19 00 88 ff ff 00 40 e9 19 00 88 ff ff  @].......@......
> [ 2866.402240] Object ffff880019ec01e0: 01 01 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.402240] Object ffff880019ec01f0: ff ff ff ff ff ff ff ff 28 40 e2 82 ff ff ff ff  ........(@......
> [ 2866.402240] Object ffff880019ec0200: 20 d9 51 82 ff ff ff ff 00 00 00 00 00 00 00 00   .Q.............
> [ 2866.402240] Object ffff880019ec0210: af 28 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  .(..............
> [ 2866.402240] Object ffff880019ec0220: 69 31 92 81 ff ff ff ff 00 00 00 00 00 00 00 00  i1..............
> [ 2866.402240] Object ffff880019ec0230: a8 57 00 00 00 00 00 00 80 e0 eb 19 00 88 ff ff  .W..............
> [ 2866.402240] Object ffff880019ec0240: 80 e0 eb 19 00 88 ff ff 01 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0250: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.402240] Object ffff880019ec0260: ff ff ff ff ff ff ff ff c0 3e e2 82 ff ff ff ff  .........>......
> [ 2866.402240] Object ffff880019ec0270: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0280: c5 1b da 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0290: 00 00 00 00 00 00 00 00 80 06 01 00 00 05 00 00  ................
> [ 2866.402240] Object ffff880019ec02a0: 20 00 00 00 00 00 00 00 89 4b 1b 40 00 00 00 00   ........K.@....
> [ 2866.402240] Object ffff880019ec02b0: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 01 00  ................
> [ 2866.402240] Object ffff880019ec02c0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec02d0: d0 02 ec 19 00 88 ff ff d0 02 ec 19 00 88 ff ff  ................
> [ 2866.402240] Object ffff880019ec02e0: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.402240] Object ffff880019ec02f0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0300: c0 3e e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .>..............
> [ 2866.402240] Object ffff880019ec0310: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0320: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0330: 00 e0 ff 81 ff ff ff ff 00 00 10 00 ed 1e af de  ................
> [ 2866.402240] Object ffff880019ec0340: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0350: f0 3e e2 82 ff ff ff ff 10 db 51 82 ff ff ff ff  .>........Q.....
> [ 2866.402240] Object ffff880019ec0360: 00 00 00 00 00 00 00 00 8c 30 e9 81 ff ff ff ff  .........0......
> [ 2866.402240] Object ffff880019ec0370: 00 00 00 00 00 00 00 00 71 d9 99 81 ff ff ff ff  ........q.......
> [ 2866.402240] Object ffff880019ec0380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0390: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec03a0: 00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff 7f  ................
> [ 2866.402240] Object ffff880019ec03b0: ff ff ff ff ff ff ff 7f 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec03c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec03d0: 00 00 00 00 00 00 00 00 00 72 38 82 ff ff ff ff  .........r8.....
> [ 2866.402240] Object ffff880019ec03e0: 98 11 91 81 ff ff ff ff 00 00 ec 19 00 88 ff ff  ................
> [ 2866.402240] Object ffff880019ec03f0: ff ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0410: 90 72 e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .r..............
> [ 2866.402240] Object ffff880019ec0420: 00 00 00 00 00 00 00 00 a1 28 e9 81 ff ff ff ff  .........(......
> [ 2866.402240] Object ffff880019ec0430: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0440: 00 36 65 c4 ff ff ff ff 80 31 c2 1d 00 88 ff ff  .6e......1......
> [ 2866.402240] Object ffff880019ec0450: 90 a2 e9 19 00 88 ff ff 40 0b 66 00 00 ea ff ff  ........@.f.....
> [ 2866.402240] Object ffff880019ec0460: 00 00 00 00 00 00 00 00 03 00 00 00 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0470: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0480: 00 00 00 00 00 00 00 00 d3 d7 99 81 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0490: 4f d9 99 81 ff ff ff ff 47 d7 99 81 ff ff ff ff  O.......G.......
> [ 2866.402240] Object ffff880019ec04a0: cc d6 99 81 ff ff ff ff 18 28 91 81 ff ff ff ff  .........(......
> [ 2866.402240] Object ffff880019ec04b0: 80 36 92 81 ff ff ff ff 00 00 00 00 00 00 00 00  .6..............
> [ 2866.402240] Object ffff880019ec04c0: 08 01 8d 03 0a 00 02 0f ff ff 00 00 03 8d fd b1  ................
> [ 2866.402240] Object ffff880019ec04d0: 00 00 00 00 00 00 00 00 00 00 01 01 52 00 00 00  ............R...
> [ 2866.402240] Object ffff880019ec04e0: 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00  ................
> [ 2866.402240] Object ffff880019ec04f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0500: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0510: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0520: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0530: 03 00 00 00 01 00 00 00 00 00 00 00 00 00 06 02  ................
> [ 2866.402240] Object ffff880019ec0540: 00 00 00 00 0a 00 02 0f 0a ef 61 0e 08 01 03 8d  ..........a.....
> [ 2866.402240] Object ffff880019ec0550: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0560: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0570: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0590: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec05a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec05b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec05c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec05d0: 00 00 00 00 00 00 00 00 80 7c eb 19 00 88 ff ff  .........|......
> [ 2866.402240] Object ffff880019ec05e0: 0e 2d 27 00 01 00 00 00 00 00 00 00 00 00 00 00  .-'.............
> [ 2866.402240] Object ffff880019ec05f0: 00 02 20 00 00 00 ad de 10 2d 27 00 01 00 00 00  .. ......-'.....
> [ 2866.402240] Object ffff880019ec0600: 00 72 38 82 ff ff ff ff cb 1d 91 81 ff ff ff ff  .r8.............
> [ 2866.402240] Object ffff880019ec0610: 00 00 ec 19 00 88 ff ff ff ff ff ff ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0620: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0630: 00 00 00 00 00 00 00 00 80 72 e2 82 ff ff ff ff  .........r......
> [ 2866.402240] Object ffff880019ec0640: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0650: fc 92 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0660: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0670: 00 02 20 00 00 00 ad de 5d 0f 27 00 01 00 00 00  .. .....].'.....
> [ 2866.402240] Object ffff880019ec0680: 00 72 38 82 ff ff ff ff 9f 16 91 81 ff ff ff ff  .r8.............
> [ 2866.402240] Object ffff880019ec0690: 00 00 ec 19 00 88 ff ff ff ff ff ff ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec06a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec06b0: 00 00 00 00 00 00 00 00 88 72 e2 82 ff ff ff ff  .........r......
> [ 2866.402240] Object ffff880019ec06c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec06d0: 19 93 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec06e0: 00 00 00 00 00 00 00 00 e8 03 00 00 dc 05 00 00  ................
> [ 2866.402240] Object ffff880019ec06f0: c0 9d 03 82 ff ff ff ff 10 10 bb 81 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0700: a9 e3 90 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0710: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0720: 00 00 00 00 00 00 0c 02 00 00 00 00 40 02 00 00  ............@...
> [ 2866.402240] Object ffff880019ec0730: 34 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00  4...............
> [ 2866.402240] Object ffff880019ec0740: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0750: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0760: 00 00 00 00 1f 00 00 00 97 99 fd ff 89 48 a9 2c  .............H.,
> [ 2866.402240] Object ffff880019ec0770: 97 99 fd ff 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0780: 20 00 03 00 50 10 22 38 00 00 00 00 00 00 00 00   ...P."8........
> [ 2866.402240] Object ffff880019ec0790: 00 00 00 00 57 9b b0 2c 57 9b b0 2c 57 9b b0 2c  ....W..,W..,W..,
> [ 2866.402240] Object ffff880019ec07a0: 1d 2a 27 00 53 2a 27 00 a8 07 ec 19 00 88 ff ff  .*'.S*'.........
> [ 2866.402240] Object ffff880019ec07b0: a8 07 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec07c0: c0 07 ec 19 00 88 ff ff c0 07 ec 19 00 88 ff ff  ................
> [ 2866.402240] Object ffff880019ec07d0: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.402240] Object ffff880019ec07e0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec07f0: 78 73 e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  xs..............
> [ 2866.402240] Object ffff880019ec0800: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.402240] Object ffff880019ec0810: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0820: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0830: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0840: 00 00 00 00 0c 02 00 00 c0 ff 3f 00 08 39 00 00  ..........?..9..
> [ 2866.402240] Object ffff880019ec0850: 00 00 00 00 b4 05 00 01 00 01 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0860: 3f 02 00 00 c8 00 00 00 3f 02 00 00 a5 78 b0 2c  ?.......?....x.,
> [ 2866.402240] Object ffff880019ec0870: 01 00 00 00 00 00 00 00 00 00 00 03 57 9b b0 2c  ............W..,
> [ 2866.402240] Object ffff880019ec0880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0890: 00 00 00 00 00 00 00 00 00 00 00 00 00 60 00 00  .............`..
> [ 2866.402240] Object ffff880019ec08a0: 00 00 18 02 00 00 00 00 ff ff ff 7f 02 00 00 00  ................
> [ 2866.402240] Object ffff880019ec08b0: 00 00 00 00 ff ff ff ff 01 00 00 00 1f 2a 27 00  .............*'.
> [ 2866.402240] Object ffff880019ec08c0: 00 00 00 00 00 00 00 00 00 00 00 00 08 39 00 00  .............9..
> [ 2866.402240] Object ffff880019ec08d0: 58 9b b0 2c 1d 79 b0 2c 00 00 00 00 00 00 00 00  X..,.y.,........
> [ 2866.402240] Object ffff880019ec08e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec08f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0900: 00 00 00 00 00 00 00 00 08 09 ec 19 00 88 ff ff  ................
> [ 2866.402240] Object ffff880019ec0910: 08 09 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0920: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.402240] Object ffff880019ec0930: ff ff ff ff ff ff ff ff 78 73 e2 82 ff ff ff ff  ........xs......
> [ 2866.402240] Object ffff880019ec0940: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0950: c5 1b da 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0960: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0970: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0980: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec0990: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec09a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec09b0: 00 c0 eb 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec09c0: 00 00 00 00 00 00 00 00 00 00 00 00 ae 2a 27 00  .............*'.
> [ 2866.402240] Object ffff880019ec09d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Object ffff880019ec09e0: 00 00 00 00 00 00 00 00 00 00 00 00 e0 0c 00 00  ................
> [ 2866.402240] Object ffff880019ec09f0: 4e f7 e3 02 07 df 26 00 c8 91 05 00 0e 8b e2 02  N.....&.........
> [ 2866.402240] Object ffff880019ec0a00: 41 22 27 00 00 00 00 00 00 00 00 00 00 00 00 00  A"'.............
> [ 2866.402240] Object ffff880019ec0a10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.402240] Redzone ffff880019ec0a20: bb bb bb bb bb bb bb bb                          ........
> [ 2866.402240] Padding ffff880019ec0b60: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [ 2866.402240] Padding ffff880019ec0b70: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [ 2866.402240] Pid: 652, comm: kworker/0:1 Not tainted 3.6.0-rc1+ #622
> [ 2866.402240] Call Trace:
> [ 2866.402240]  <IRQ>  [<ffffffff811517b4>] ? print_section+0x3d/0x3f
> [ 2866.402240]  [<ffffffff811528f7>] print_trailer+0x12b/0x134
> [ 2866.402240]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.402240]  [<ffffffff81152938>] object_err+0x38/0x41
> [ 2866.402240]  [<ffffffff819fb4cd>] free_debug_processing+0x14d/0x264
> [ 2866.402240]  [<ffffffff8106b56e>] ? vprintk_emit+0x479/0x4a5
> [ 2866.402240]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.402240]  [<ffffffff819fb61e>] __slab_free+0x3a/0x383
> [ 2866.402240]  [<ffffffff8143b242>] ? check_unmap+0x5fb/0x6d5
> [ 2866.402240]  [<ffffffff819f825e>] ? printk+0x4d/0x4f
> [ 2866.402240]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.402240]  [<ffffffff81154a86>] kmem_cache_free+0xf7/0x13a
> [ 2866.402240]  [<ffffffff818a0839>] __sk_free+0xfd/0x114
> [ 2866.402240]  [<ffffffff818a089f>] sock_wfree+0x4f/0x54
> [ 2866.402240]  [<ffffffff8190dab9>] tcp_wfree+0xca/0xd2
> [ 2866.402240]  [<ffffffff818a4a8c>] skb_release_head_state+0x7f/0xd3
> [ 2866.402240]  [<ffffffff818a4897>] __kfree_skb+0x13/0x7e
> [ 2866.402240]  [<ffffffff818a4968>] consume_skb+0x40/0x6c
> [ 2866.402240]  [<ffffffff818ae25b>] dev_kfree_skb_any+0x36/0x38
> [ 2866.402240]  [<ffffffff816dc0e0>] e1000_unmap_and_free_tx_resource.isra.24+0xd5/0xed
> [ 2866.402240]  [<ffffffff816dc1ae>] e1000_clean+0xb6/0x6c6
> [ 2866.402240]  [<ffffffff818ae4f4>] net_rx_action+0xb5/0x1f3
> [ 2866.402240]  [<ffffffff81070bd6>] __do_softirq+0xcb/0x1f9
> [ 2866.402240]  [<ffffffff81a1227c>] call_softirq+0x1c/0x30
> [ 2866.402240]  <EOI>  [<ffffffff81039f38>] do_softirq+0x4a/0xa6
> [ 2866.402240]  [<ffffffff818faaaa>] ? ip_finish_output+0x413/0x501
> [ 2866.402240]  [<ffffffff81070939>] local_bh_enable+0xb2/0xe6
> [ 2866.402240]  [<ffffffff818faaaa>] ip_finish_output+0x413/0x501
> [ 2866.402240]  [<ffffffff818fa967>] ? ip_finish_output+0x2d0/0x501
> [ 2866.402240]  [<ffffffff818fbf0d>] ip_output+0x8a/0xdf
> [ 2866.402240]  [<ffffffff818fb688>] ip_local_out+0x59/0x72
> [ 2866.402240]  [<ffffffff818fb9db>] ip_queue_xmit+0x33a/0x3c3
> [ 2866.402240]  [<ffffffff818fb6a1>] ? ip_local_out+0x72/0x72
> [ 2866.402240]  [<ffffffff8190ef0d>] tcp_transmit_skb+0x745/0x7aa
> [ 2866.402240]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.402240]  [<ffffffff81910ca2>] tcp_connect+0x3d6/0x461
> [ 2866.402240]  [<ffffffff81913329>] tcp_v4_connect+0x3c6/0x430
> [ 2866.402240]  [<ffffffff81922d91>] __inet_stream_connect+0x88/0x283
> [ 2866.402240]  [<ffffffff8189e992>] ? lock_sock_nested+0x75/0x80
> [ 2866.402240]  [<ffffffff810bc413>] ? trace_hardirqs_on+0xd/0xf
> [ 2866.402240]  [<ffffffff8107094d>] ? local_bh_enable+0xc6/0xe6
> [ 2866.402240]  [<ffffffff8189e992>] ? lock_sock_nested+0x75/0x80
> [ 2866.402240]  [<ffffffff81922fb3>] ? inet_stream_connect+0x27/0x50
> [ 2866.402240]  [<ffffffff81922fc4>] inet_stream_connect+0x38/0x50
> [ 2866.402240]  [<ffffffff8189a4eb>] kernel_connect+0x10/0x12
> [ 2866.402240]  [<ffffffff8199ee20>] xs_tcp_setup_socket+0x20c/0x2d5
> [ 2866.402240]  [<ffffffff810835d6>] process_one_work+0x24d/0x47f
> [ 2866.402240]  [<ffffffff81083567>] ? process_one_work+0x1de/0x47f
> [ 2866.402240]  [<ffffffff8199ec14>] ? xs_udp_setup_socket+0x169/0x169
> [ 2866.402240]  [<ffffffff81083a6d>] worker_thread+0x236/0x317
> [ 2866.402240]  [<ffffffff81083837>] ? process_scheduled_works+0x2f/0x2f
> [ 2866.402240]  [<ffffffff8108b7b8>] kthread+0x9a/0xa2
> [ 2866.402240]  [<ffffffff81a12184>] kernel_thread_helper+0x4/0x10
> [ 2866.402240]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.402240]  [<ffffffff8108b71e>] ? __init_kthread_worker+0x5a/0x5a
> [ 2866.402240]  [<ffffffff81a12180>] ? gs_change+0x13/0x13
> [ 2866.402240] FIX TCP: Object at 0xffff880019ec0000 not freed
> [ 2866.423538] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.424432] =============================================================================
> [ 2866.425237] BUG TCP (Not tainted): Object already free
> [ 2866.425237] -----------------------------------------------------------------------------
> [ 2866.425237] 
> [ 2866.425237] INFO: Allocated in sk_prot_alloc.isra.35+0x30/0xd2 age=2724161 cpu=0 pid=652
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] INFO: Freed in __sk_free+0xfd/0x114 age=291 cpu=0 pid=652
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] 
> [ 2866.425237] INFO: Slab 0xffffea000067b000 objects=11 used=9 fp=0xffff880019ec0000 flags=0x100000000004081
> [ 2866.425237] INFO: Object 0xffff880019ec0000 @offset=0 fp=0xffff880019ec5c00
> [ 2866.425237] 
> [ 2866.425237] Object ffff880019ec0000: 0a ef 61 0e 0a 00 02 0f bb 7c 0f b9 02 00 01 00  ..a......|......
> [ 2866.425237] Object ffff880019ec0010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0020: 98 7c eb 19 00 88 ff ff 00 e0 ff 81 ff ff ff ff  .|..............
> [ 2866.425237] Object ffff880019ec0030: 77 79 00 00 00 00 00 00 b0 eb 0f 00 00 c9 ff ff  wy..............
> [ 2866.425237] Object ffff880019ec0040: ff ff ff ff 02 00 00 00 e4 e4 00 00 ad 4e ad de  .............N..
> [ 2866.425237] Object ffff880019ec0050: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0060: 60 e8 e2 82 ff ff ff ff 50 d3 51 82 ff ff ff ff  `.......P.Q.....
> [ 2866.425237] Object ffff880019ec0070: b0 e6 51 82 ff ff ff ff f1 0c ea 81 ff ff ff ff  ..Q.............
> [ 2866.425237] Object ffff880019ec0080: 00 00 00 00 00 00 00 00 e6 1d 91 81 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0090: 01 00 00 00 00 00 00 00 02 02 00 00 ad 4e ad de  .............N..
> [ 2866.425237] Object ffff880019ec00a0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec00b0: 80 e8 e2 82 ff ff ff ff 00 fc 51 82 ff ff ff ff  ..........Q.....
> [ 2866.425237] Object ffff880019ec00c0: 00 00 00 00 00 00 00 00 81 8f dc 81 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec00d0: 00 00 00 00 00 00 00 00 57 42 09 81 ff ff ff ff  ........WB......
> [ 2866.425237] Object ffff880019ec00e0: e0 00 ec 19 00 88 ff ff e0 00 ec 19 00 88 ff ff  ................
> [ 2866.425237] Object ffff880019ec00f0: 70 e8 e2 82 ff ff ff ff 40 d5 51 82 ff ff ff ff  p.......@.Q.....
> [ 2866.425237] Object ffff880019ec0100: 00 00 00 00 00 00 00 00 03 0d ea 81 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0120: 20 01 ec 19 00 88 ff ff 20 01 ec 19 00 88 ff ff   ....... .......
> [ 2866.425237] Object ffff880019ec0130: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.425237] Object ffff880019ec0140: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0150: c0 3e e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .>..............
> [ 2866.425237] Object ffff880019ec0160: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0180: 00 00 00 00 c0 02 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0190: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec01a0: 00 00 00 00 68 7d 0b 00 00 00 00 00 00 00 00 00  ....h}..........
> [ 2866.425237] Object ffff880019ec01b0: 90 63 e9 19 00 88 ff ff 00 00 00 00 00 00 00 00  .c..............
> [ 2866.425237] Object ffff880019ec01c0: 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec01d0: 40 5d e9 19 00 88 ff ff 00 40 e9 19 00 88 ff ff  @].......@......
> [ 2866.425237] Object ffff880019ec01e0: 01 01 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.425237] Object ffff880019ec01f0: ff ff ff ff ff ff ff ff 28 40 e2 82 ff ff ff ff  ........(@......
> [ 2866.425237] Object ffff880019ec0200: 20 d9 51 82 ff ff ff ff 00 00 00 00 00 00 00 00   .Q.............
> [ 2866.425237] Object ffff880019ec0210: af 28 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  .(..............
> [ 2866.425237] Object ffff880019ec0220: 69 31 92 81 ff ff ff ff 00 00 00 00 00 00 00 00  i1..............
> [ 2866.425237] Object ffff880019ec0230: a8 57 00 00 00 00 00 00 38 02 ec 19 00 88 ff ff  .W......8.......
> [ 2866.425237] Object ffff880019ec0240: 38 02 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  8...............
> [ 2866.425237] Object ffff880019ec0250: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.425237] Object ffff880019ec0260: ff ff ff ff ff ff ff ff c0 3e e2 82 ff ff ff ff  .........>......
> [ 2866.425237] Object ffff880019ec0270: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0280: c5 1b da 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0290: 00 00 00 00 00 00 00 00 80 06 01 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec02a0: 20 00 00 00 00 00 00 00 89 4b 1b 40 00 00 00 00   ........K.@....
> [ 2866.425237] Object ffff880019ec02b0: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 01 00  ................
> [ 2866.425237] Object ffff880019ec02c0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec02d0: d0 02 ec 19 00 88 ff ff d0 02 ec 19 00 88 ff ff  ................
> [ 2866.425237] Object ffff880019ec02e0: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.425237] Object ffff880019ec02f0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0300: c0 3e e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .>..............
> [ 2866.425237] Object ffff880019ec0310: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0320: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0330: 00 e0 ff 81 ff ff ff ff 00 00 10 00 ed 1e af de  ................
> [ 2866.425237] Object ffff880019ec0340: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0350: f0 3e e2 82 ff ff ff ff 10 db 51 82 ff ff ff ff  .>........Q.....
> [ 2866.425237] Object ffff880019ec0360: 00 00 00 00 00 00 00 00 8c 30 e9 81 ff ff ff ff  .........0......
> [ 2866.425237] Object ffff880019ec0370: 00 00 00 00 00 00 00 00 71 d9 99 81 ff ff ff ff  ........q.......
> [ 2866.425237] Object ffff880019ec0380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0390: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec03a0: 00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff 7f  ................
> [ 2866.425237] Object ffff880019ec03b0: ff ff ff ff ff ff ff 7f 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec03c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec03d0: 00 00 00 00 00 00 00 00 00 72 38 82 ff ff ff ff  .........r8.....
> [ 2866.425237] Object ffff880019ec03e0: 98 11 91 81 ff ff ff ff 00 00 ec 19 00 88 ff ff  ................
> [ 2866.425237] Object ffff880019ec03f0: ff ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0410: 90 72 e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .r..............
> [ 2866.425237] Object ffff880019ec0420: 00 00 00 00 00 00 00 00 a1 28 e9 81 ff ff ff ff  .........(......
> [ 2866.425237] Object ffff880019ec0430: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0440: 00 36 65 c4 ff ff ff ff 80 31 c2 1d 00 88 ff ff  .6e......1......
> [ 2866.425237] Object ffff880019ec0450: 90 a2 e9 19 00 88 ff ff 40 0b 66 00 00 ea ff ff  ........@.f.....
> [ 2866.425237] Object ffff880019ec0460: 00 00 00 00 00 00 00 00 03 00 00 00 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0470: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0480: 00 00 00 00 00 00 00 00 d3 d7 99 81 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0490: 4f d9 99 81 ff ff ff ff 47 d7 99 81 ff ff ff ff  O.......G.......
> [ 2866.425237] Object ffff880019ec04a0: cc d6 99 81 ff ff ff ff 18 28 91 81 ff ff ff ff  .........(......
> [ 2866.425237] Object ffff880019ec04b0: 80 36 92 81 ff ff ff ff 00 00 00 00 00 00 00 00  .6..............
> [ 2866.425237] Object ffff880019ec04c0: 08 01 8d 03 0a 00 02 0f ff ff 00 00 03 8d fe b1  ................
> [ 2866.425237] Object ffff880019ec04d0: 00 00 00 00 00 00 00 00 00 00 01 01 52 00 00 00  ............R...
> [ 2866.425237] Object ffff880019ec04e0: 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00  ................
> [ 2866.425237] Object ffff880019ec04f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0500: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0510: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0520: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0530: 03 00 00 00 01 00 00 00 00 00 00 00 00 00 06 02  ................
> [ 2866.425237] Object ffff880019ec0540: 00 00 00 00 0a 00 02 0f 0a ef 61 0e 08 01 03 8d  ..........a.....
> [ 2866.425237] Object ffff880019ec0550: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0560: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0570: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0590: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec05a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec05b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec05c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec05d0: 00 00 00 00 00 00 00 00 80 7c eb 19 00 88 ff ff  .........|......
> [ 2866.425237] Object ffff880019ec05e0: a6 2e 27 00 01 00 00 00 48 85 38 82 ff ff ff ff  ..'.....H.8.....
> [ 2866.425237] Object ffff880019ec05f0: 20 fd 3c 1f 00 88 ff ff a8 2e 27 00 01 00 00 00   .<.......'.....
> [ 2866.425237] Object ffff880019ec0600: 00 72 38 82 ff ff ff ff cb 1d 91 81 ff ff ff ff  .r8.............
> [ 2866.425237] Object ffff880019ec0610: 00 00 ec 19 00 88 ff ff ff ff ff ff ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0620: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0630: 00 00 00 00 00 00 00 00 80 72 e2 82 ff ff ff ff  .........r......
> [ 2866.425237] Object ffff880019ec0640: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0650: fc 92 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0660: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0670: 00 02 20 00 00 00 ad de 5d 0f 27 00 01 00 00 00  .. .....].'.....
> [ 2866.425237] Object ffff880019ec0680: 00 72 38 82 ff ff ff ff 9f 16 91 81 ff ff ff ff  .r8.............
> [ 2866.425237] Object ffff880019ec0690: 00 00 ec 19 00 88 ff ff ff ff ff ff ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec06a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec06b0: 00 00 00 00 00 00 00 00 88 72 e2 82 ff ff ff ff  .........r......
> [ 2866.425237] Object ffff880019ec06c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec06d0: 19 93 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec06e0: 00 00 00 00 00 00 00 00 f5 00 00 00 dc 05 00 00  ................
> [ 2866.425237] Object ffff880019ec06f0: c0 9d 03 82 ff ff ff ff 10 10 bb 81 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0700: a9 e3 90 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0710: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0720: 00 00 00 00 00 00 18 02 00 00 00 00 dc 05 00 00  ................
> [ 2866.425237] Object ffff880019ec0730: 28 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00  (...............
> [ 2866.425237] Object ffff880019ec0740: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0750: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0760: 00 00 00 00 20 00 00 00 c4 2a 27 00 58 9b b0 2c  .... ....*'.X..,
> [ 2866.425237] Object ffff880019ec0770: c4 2a 27 00 00 00 00 00 00 00 00 00 00 00 00 00  .*'.............
> [ 2866.425237] Object ffff880019ec0780: 14 00 03 00 50 10 20 00 02 c2 26 17 02 c2 26 17  ....P. ...&...&.
> [ 2866.425237] Object ffff880019ec0790: 02 c2 26 17 58 9b b0 2c 58 9b b0 2c 57 9b b0 2c  ..&.X..,X..,W..,
> [ 2866.425237] Object ffff880019ec07a0: c0 2a 27 00 c4 2a 27 00 a8 07 ec 19 00 88 ff ff  .*'..*'.........
> [ 2866.425237] Object ffff880019ec07b0: a8 07 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec07c0: c0 07 ec 19 00 88 ff ff c0 07 ec 19 00 88 ff ff  ................
> [ 2866.425237] Object ffff880019ec07d0: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.425237] Object ffff880019ec07e0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec07f0: 78 73 e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  xs..............
> [ 2866.425237] Object ffff880019ec0800: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.425237] Object ffff880019ec0810: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0820: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0830: 00 00 00 00 00 00 00 00 01 c2 26 17 00 20 00 00  ..........&.. ..
> [ 2866.425237] Object ffff880019ec0840: 00 20 00 00 b4 05 00 00 ff ff 00 00 08 39 00 00  . ...........9..
> [ 2866.425237] Object ffff880019ec0850: 00 00 00 00 b4 05 00 01 00 01 00 00 6f 01 00 00  ............o...
> [ 2866.425237] Object ffff880019ec0860: b6 00 00 00 c8 00 00 00 c8 00 00 00 58 9b b0 2c  ............X..,
> [ 2866.425237] Object ffff880019ec0870: 00 00 00 00 00 00 00 00 00 00 00 03 58 9b b0 2c  ............X..,
> [ 2866.425237] Object ffff880019ec0880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0890: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec08a0: 00 00 b4 05 00 00 00 00 ff ff ff 7f 0a 00 00 00  ................
> [ 2866.425237] Object ffff880019ec08b0: 00 00 00 00 ff ff ff ff 01 00 00 00 c5 2a 27 00  .............*'.
> [ 2866.425237] Object ffff880019ec08c0: 00 00 00 00 00 00 00 00 00 00 00 00 08 39 00 00  .............9..
> [ 2866.425237] Object ffff880019ec08d0: 58 9b b0 2c 58 9b b0 2c 00 00 00 00 00 00 00 00  X..,X..,........
> [ 2866.425237] Object ffff880019ec08e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec08f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0900: 00 00 00 00 00 00 00 00 08 09 ec 19 00 88 ff ff  ................
> [ 2866.425237] Object ffff880019ec0910: 08 09 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0920: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.425237] Object ffff880019ec0930: ff ff ff ff ff ff ff ff 78 73 e2 82 ff ff ff ff  ........xs......
> [ 2866.425237] Object ffff880019ec0940: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0950: c5 1b da 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0960: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0970: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0980: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec0990: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec09a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec09b0: 00 c0 eb 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec09c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec09d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Object ffff880019ec09e0: 00 00 00 00 00 00 00 00 00 00 00 00 e0 0c 00 00  ................
> [ 2866.425237] Object ffff880019ec09f0: 4e f7 e3 02 07 df 26 00 08 39 00 00 0e 8b e2 02  N.....&..9......
> [ 2866.425237] Object ffff880019ec0a00: 41 22 27 00 00 00 00 00 00 00 00 00 00 00 00 00  A"'.............
> [ 2866.425237] Object ffff880019ec0a10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.425237] Redzone ffff880019ec0a20: bb bb bb bb bb bb bb bb                          ........
> [ 2866.425237] Padding ffff880019ec0b60: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [ 2866.425237] Padding ffff880019ec0b70: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [ 2866.425237] Pid: 652, comm: kworker/0:1 Not tainted 3.6.0-rc1+ #622
> [ 2866.425237] Call Trace:
> [ 2866.425237]  <IRQ>  [<ffffffff811517b4>] ? print_section+0x3d/0x3f
> [ 2866.425237]  [<ffffffff811528f7>] print_trailer+0x12b/0x134
> [ 2866.425237]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.425237]  [<ffffffff81152938>] object_err+0x38/0x41
> [ 2866.425237]  [<ffffffff819fb4cd>] free_debug_processing+0x14d/0x264
> [ 2866.425237]  [<ffffffff8106b56e>] ? vprintk_emit+0x479/0x4a5
> [ 2866.425237]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.425237]  [<ffffffff819fb61e>] __slab_free+0x3a/0x383
> [ 2866.425237]  [<ffffffff8143b242>] ? check_unmap+0x5fb/0x6d5
> [ 2866.425237]  [<ffffffff819f825e>] ? printk+0x4d/0x4f
> [ 2866.425237]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.425237]  [<ffffffff81154a86>] kmem_cache_free+0xf7/0x13a
> [ 2866.425237]  [<ffffffff818a0839>] __sk_free+0xfd/0x114
> [ 2866.425237]  [<ffffffff818a089f>] sock_wfree+0x4f/0x54
> [ 2866.425237]  [<ffffffff8190dab9>] tcp_wfree+0xca/0xd2
> [ 2866.425237]  [<ffffffff818a4a8c>] skb_release_head_state+0x7f/0xd3
> [ 2866.425237]  [<ffffffff818a4897>] __kfree_skb+0x13/0x7e
> [ 2866.425237]  [<ffffffff818a4968>] consume_skb+0x40/0x6c
> [ 2866.425237]  [<ffffffff818ae25b>] dev_kfree_skb_any+0x36/0x38
> [ 2866.425237]  [<ffffffff816dc0e0>] e1000_unmap_and_free_tx_resource.isra.24+0xd5/0xed
> [ 2866.425237]  [<ffffffff816dc1ae>] e1000_clean+0xb6/0x6c6
> [ 2866.425237]  [<ffffffff810b79a8>] ? trace_hardirqs_off+0xd/0xf
> [ 2866.425237]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.425237]  [<ffffffff810bc413>] ? trace_hardirqs_on+0xd/0xf
> [ 2866.425237]  [<ffffffff818ae4f4>] net_rx_action+0xb5/0x1f3
> [ 2866.425237]  [<ffffffff81070bd6>] __do_softirq+0xcb/0x1f9
> [ 2866.425237]  [<ffffffff81a1227c>] call_softirq+0x1c/0x30
> [ 2866.425237]  <EOI>  [<ffffffff81039f38>] do_softirq+0x4a/0xa6
> [ 2866.425237]  [<ffffffff81a089ce>] ? __cond_resched_softirq+0x3a/0x4b
> [ 2866.425237]  [<ffffffff81070939>] local_bh_enable+0xb2/0xe6
> [ 2866.425237]  [<ffffffff81a089ce>] __cond_resched_softirq+0x3a/0x4b
> [ 2866.425237]  [<ffffffff818a0274>] release_sock+0x112/0x1c4
> [ 2866.425237]  [<ffffffff81922fd0>] inet_stream_connect+0x44/0x50
> [ 2866.425237]  [<ffffffff8189a4eb>] kernel_connect+0x10/0x12
> [ 2866.425237]  [<ffffffff8199ee20>] xs_tcp_setup_socket+0x20c/0x2d5
> [ 2866.425237]  [<ffffffff810835d6>] process_one_work+0x24d/0x47f
> [ 2866.425237]  [<ffffffff81083567>] ? process_one_work+0x1de/0x47f
> [ 2866.425237]  [<ffffffff8199ec14>] ? xs_udp_setup_socket+0x169/0x169
> [ 2866.425237]  [<ffffffff81083a6d>] worker_thread+0x236/0x317
> [ 2866.425237]  [<ffffffff81083837>] ? process_scheduled_works+0x2f/0x2f
> [ 2866.425237]  [<ffffffff8108b7b8>] kthread+0x9a/0xa2
> [ 2866.425237]  [<ffffffff81a12184>] kernel_thread_helper+0x4/0x10
> [ 2866.425237]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.425237]  [<ffffffff8108b71e>] ? __init_kthread_worker+0x5a/0x5a
> [ 2866.425237]  [<ffffffff81a12180>] ? gs_change+0x13/0x13
> [ 2866.425237] FIX TCP: Object at 0xffff880019ec0000 not freed
> [ 2866.569667] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.573538] =============================================================================
> [ 2866.574214] BUG TCP (Not tainted): Object already free
> [ 2866.574214] -----------------------------------------------------------------------------
> [ 2866.574214] 
> [ 2866.574214] INFO: Allocated in sk_prot_alloc.isra.35+0x30/0xd2 age=2724310 cpu=0 pid=652
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] INFO: Freed in __sk_free+0xfd/0x114 age=440 cpu=0 pid=652
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] 
> [ 2866.574214] INFO: Slab 0xffffea000067b000 objects=11 used=9 fp=0xffff880019ec0000 flags=0x100000000004081
> [ 2866.574214] INFO: Object 0xffff880019ec0000 @offset=0 fp=0xffff880019ec5c00
> [ 2866.574214] 
> [ 2866.574214] Object ffff880019ec0000: 0a ef 61 0e 0a 00 02 0f bb 7c 0f b9 02 00 01 00  ..a......|......
> [ 2866.574214] Object ffff880019ec0010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0020: 98 7c eb 19 00 88 ff ff 00 e0 ff 81 ff ff ff ff  .|..............
> [ 2866.574214] Object ffff880019ec0030: 77 79 00 00 00 00 00 00 b0 eb 0f 00 00 c9 ff ff  wy..............
> [ 2866.574214] Object ffff880019ec0040: ff ff ff ff 02 00 00 00 e6 e6 00 00 ad 4e ad de  .............N..
> [ 2866.574214] Object ffff880019ec0050: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0060: 60 e8 e2 82 ff ff ff ff 50 d3 51 82 ff ff ff ff  `.......P.Q.....
> [ 2866.574214] Object ffff880019ec0070: b0 e6 51 82 ff ff ff ff f1 0c ea 81 ff ff ff ff  ..Q.............
> [ 2866.574214] Object ffff880019ec0080: 00 00 00 00 00 00 00 00 e6 1d 91 81 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0090: 01 00 00 00 00 00 00 00 02 02 00 00 ad 4e ad de  .............N..
> [ 2866.574214] Object ffff880019ec00a0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec00b0: 80 e8 e2 82 ff ff ff ff 00 fc 51 82 ff ff ff ff  ..........Q.....
> [ 2866.574214] Object ffff880019ec00c0: 00 00 00 00 00 00 00 00 81 8f dc 81 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec00d0: 00 00 00 00 00 00 00 00 57 42 09 81 ff ff ff ff  ........WB......
> [ 2866.574214] Object ffff880019ec00e0: e0 00 ec 19 00 88 ff ff e0 00 ec 19 00 88 ff ff  ................
> [ 2866.574214] Object ffff880019ec00f0: 70 e8 e2 82 ff ff ff ff 40 d5 51 82 ff ff ff ff  p.......@.Q.....
> [ 2866.574214] Object ffff880019ec0100: 00 00 00 00 00 00 00 00 03 0d ea 81 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0120: 20 01 ec 19 00 88 ff ff 20 01 ec 19 00 88 ff ff   ....... .......
> [ 2866.574214] Object ffff880019ec0130: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.574214] Object ffff880019ec0140: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0150: c0 3e e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .>..............
> [ 2866.574214] Object ffff880019ec0160: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0190: 00 00 00 00 00 00 00 00 00 07 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec01a0: 00 00 00 00 68 7d 0b 00 00 00 00 00 00 00 00 00  ....h}..........
> [ 2866.574214] Object ffff880019ec01b0: 90 63 e9 19 00 88 ff ff 00 00 00 00 00 00 00 00  .c..............
> [ 2866.574214] Object ffff880019ec01c0: 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec01d0: 40 5d e9 19 00 88 ff ff 00 40 e9 19 00 88 ff ff  @].......@......
> [ 2866.574214] Object ffff880019ec01e0: 01 01 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.574214] Object ffff880019ec01f0: ff ff ff ff ff ff ff ff 28 40 e2 82 ff ff ff ff  ........(@......
> [ 2866.574214] Object ffff880019ec0200: 20 d9 51 82 ff ff ff ff 00 00 00 00 00 00 00 00   .Q.............
> [ 2866.574214] Object ffff880019ec0210: af 28 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  .(..............
> [ 2866.574214] Object ffff880019ec0220: 69 31 92 81 ff ff ff ff 00 00 00 00 00 00 00 00  i1..............
> [ 2866.574214] Object ffff880019ec0230: a8 57 00 00 00 00 00 00 80 e0 eb 19 00 88 ff ff  .W..............
> [ 2866.574214] Object ffff880019ec0240: 80 e0 eb 19 00 88 ff ff 01 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0250: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.574214] Object ffff880019ec0260: ff ff ff ff ff ff ff ff c0 3e e2 82 ff ff ff ff  .........>......
> [ 2866.574214] Object ffff880019ec0270: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0280: c5 1b da 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0290: 00 00 00 00 00 00 00 00 80 06 01 00 00 09 00 00  ................
> [ 2866.574214] Object ffff880019ec02a0: 20 00 00 00 00 00 00 00 89 4b 1b 40 00 00 00 00   ........K.@....
> [ 2866.574214] Object ffff880019ec02b0: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 01 00  ................
> [ 2866.574214] Object ffff880019ec02c0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec02d0: d0 02 ec 19 00 88 ff ff d0 02 ec 19 00 88 ff ff  ................
> [ 2866.574214] Object ffff880019ec02e0: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.574214] Object ffff880019ec02f0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0300: c0 3e e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .>..............
> [ 2866.574214] Object ffff880019ec0310: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0320: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0330: 00 e0 ff 81 ff ff ff ff 00 00 10 00 ed 1e af de  ................
> [ 2866.574214] Object ffff880019ec0340: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0350: f0 3e e2 82 ff ff ff ff 10 db 51 82 ff ff ff ff  .>........Q.....
> [ 2866.574214] Object ffff880019ec0360: 00 00 00 00 00 00 00 00 8c 30 e9 81 ff ff ff ff  .........0......
> [ 2866.574214] Object ffff880019ec0370: 00 00 00 00 00 00 00 00 71 d9 99 81 ff ff ff ff  ........q.......
> [ 2866.574214] Object ffff880019ec0380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0390: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec03a0: 00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff 7f  ................
> [ 2866.574214] Object ffff880019ec03b0: ff ff ff ff ff ff ff 7f 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec03c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec03d0: 00 00 00 00 00 00 00 00 00 72 38 82 ff ff ff ff  .........r8.....
> [ 2866.574214] Object ffff880019ec03e0: 98 11 91 81 ff ff ff ff 00 00 ec 19 00 88 ff ff  ................
> [ 2866.574214] Object ffff880019ec03f0: ff ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0410: 90 72 e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  .r..............
> [ 2866.574214] Object ffff880019ec0420: 00 00 00 00 00 00 00 00 a1 28 e9 81 ff ff ff ff  .........(......
> [ 2866.574214] Object ffff880019ec0430: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0440: 00 36 65 c4 ff ff ff ff 80 31 c2 1d 00 88 ff ff  .6e......1......
> [ 2866.574214] Object ffff880019ec0450: 90 a2 e9 19 00 88 ff ff 40 0b 66 00 00 ea ff ff  ........@.f.....
> [ 2866.574214] Object ffff880019ec0460: 80 e0 eb 19 00 88 ff ff 03 00 00 00 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0470: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0480: 00 00 00 00 00 00 00 00 d3 d7 99 81 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0490: 4f d9 99 81 ff ff ff ff 47 d7 99 81 ff ff ff ff  O.......G.......
> [ 2866.574214] Object ffff880019ec04a0: cc d6 99 81 ff ff ff ff 18 28 91 81 ff ff ff ff  .........(......
> [ 2866.574214] Object ffff880019ec04b0: 80 36 92 81 ff ff ff ff 00 00 00 00 00 00 00 00  .6..............
> [ 2866.574214] Object ffff880019ec04c0: 08 01 8d 03 0a 00 02 0f ff ff 00 00 03 8d ff b1  ................
> [ 2866.574214] Object ffff880019ec04d0: 00 00 00 00 00 00 00 00 00 00 01 01 52 00 00 00  ............R...
> [ 2866.574214] Object ffff880019ec04e0: 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00  ................
> [ 2866.574214] Object ffff880019ec04f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0500: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0510: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0520: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0530: 03 00 00 00 01 00 00 00 00 00 00 00 00 00 06 02  ................
> [ 2866.574214] Object ffff880019ec0540: 00 00 00 00 0a 00 02 0f 0a ef 61 0e 08 01 03 8d  ..........a.....
> [ 2866.574214] Object ffff880019ec0550: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0560: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0570: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0590: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec05a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec05b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec05c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec05d0: 00 00 00 00 00 00 00 00 80 7c eb 19 00 88 ff ff  .........|......
> [ 2866.574214] Object ffff880019ec05e0: a6 2e 27 00 01 00 00 00 48 85 38 82 ff ff ff ff  ..'.....H.8.....
> [ 2866.574214] Object ffff880019ec05f0: 20 fd 3c 1f 00 88 ff ff a8 2e 27 00 01 00 00 00   .<.......'.....
> [ 2866.574214] Object ffff880019ec0600: 00 72 38 82 ff ff ff ff cb 1d 91 81 ff ff ff ff  .r8.............
> [ 2866.574214] Object ffff880019ec0610: 00 00 ec 19 00 88 ff ff ff ff ff ff ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0620: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0630: 00 00 00 00 00 00 00 00 80 72 e2 82 ff ff ff ff  .........r......
> [ 2866.574214] Object ffff880019ec0640: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0650: fc 92 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0660: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0670: 00 02 20 00 00 00 ad de 5d 0f 27 00 01 00 00 00  .. .....].'.....
> [ 2866.574214] Object ffff880019ec0680: 00 72 38 82 ff ff ff ff 9f 16 91 81 ff ff ff ff  .r8.............
> [ 2866.574214] Object ffff880019ec0690: 00 00 ec 19 00 88 ff ff ff ff ff ff ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec06a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec06b0: 00 00 00 00 00 00 00 00 88 72 e2 82 ff ff ff ff  .........r......
> [ 2866.574214] Object ffff880019ec06c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec06d0: 19 93 e9 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec06e0: 00 00 00 00 00 00 00 00 f5 00 00 00 dc 05 00 00  ................
> [ 2866.574214] Object ffff880019ec06f0: c0 9d 03 82 ff ff ff ff 10 10 bb 81 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0700: a9 e3 90 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0710: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0720: 00 00 00 00 00 00 18 02 00 00 00 00 dc 05 00 00  ................
> [ 2866.574214] Object ffff880019ec0730: 28 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00  (...............
> [ 2866.574214] Object ffff880019ec0740: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0750: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0760: 00 00 00 00 20 00 00 00 c4 2a 27 00 58 9b b0 2c  .... ....*'.X..,
> [ 2866.574214] Object ffff880019ec0770: c4 2a 27 00 00 00 00 00 00 00 00 00 00 00 00 00  .*'.............
> [ 2866.574214] Object ffff880019ec0780: 14 00 02 00 50 10 20 00 02 c2 26 17 02 c2 26 17  ....P. ...&...&.
> [ 2866.574214] Object ffff880019ec0790: 02 c2 26 17 58 9b b0 2c 58 9b b0 2c 57 9b b0 2c  ..&.X..,X..,W..,
> [ 2866.574214] Object ffff880019ec07a0: c0 2a 27 00 4e 2b 27 00 a8 07 ec 19 00 88 ff ff  .*'.N+'.........
> [ 2866.574214] Object ffff880019ec07b0: a8 07 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec07c0: c0 07 ec 19 00 88 ff ff c0 07 ec 19 00 88 ff ff  ................
> [ 2866.574214] Object ffff880019ec07d0: 00 00 00 00 00 00 00 00 00 00 00 00 ad 4e ad de  .............N..
> [ 2866.574214] Object ffff880019ec07e0: ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec07f0: 78 73 e2 82 ff ff ff ff 00 00 00 00 00 00 00 00  xs..............
> [ 2866.574214] Object ffff880019ec0800: 00 00 00 00 00 00 00 00 c5 1b da 81 ff ff ff ff  ................
> [ 2866.574214] Object ffff880019ec0810: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0820: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0830: 00 00 00 00 00 00 00 00 01 c2 26 17 00 20 00 00  ..........&.. ..
> [ 2866.574214] Object ffff880019ec0840: 00 20 00 00 b4 05 00 00 ff ff 00 00 08 39 00 00  . ...........9..
> [ 2866.574214] Object ffff880019ec0850: 00 00 00 00 b4 05 00 01 00 01 00 00 6f 01 00 00  ............o...
> [ 2866.574214] Object ffff880019ec0860: b6 00 00 00 c8 00 00 00 c8 00 00 00 58 9b b0 2c  ............X..,
> [ 2866.574214] Object ffff880019ec0870: 00 00 00 00 00 00 00 00 00 00 00 03 58 9b b0 2c  ............X..,
> [ 2866.574214] Object ffff880019ec0880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0890: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec08a0: 00 00 b4 05 00 00 00 00 ff ff ff 7f 0a 00 00 00  ................
> [ 2866.574214] Object ffff880019ec08b0: 00 00 00 00 ff ff ff ff 01 00 00 00 c5 2a 27 00  .............*'.
> [ 2866.574214] Object ffff880019ec08c0: 00 00 00 00 00 00 00 00 00 00 00 00 08 39 00 00  .............9..
> [ 2866.574214] Object ffff880019ec08d0: d0 9b b0 2c d0 9b b0 2c 00 00 00 00 00 00 00 00  ...,...,........
> [ 2866.574214] Object ffff880019ec08e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec08f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0900: 00 00 00 00 00 00 00 00 08 09 ec 19 00 88 ff ff  ................
> [ 2866.574214] Object ffff880019ec0910: 08 09 ec 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0920: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
> [ 2866.574214] Object ffff880019ec0930: ff ff ff ff ff ff ff ff 78 73 e2 82 ff ff ff ff  ........xs......
> [ 2866.574214] Object ffff880019ec0940: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0950: c5 1b da 81 ff ff ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0960: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0970: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0980: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec0990: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec09a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec09b0: 00 c0 eb 19 00 88 ff ff 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec09c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec09d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Object ffff880019ec09e0: 00 00 00 00 00 00 00 00 00 00 00 00 e0 0c 00 00  ................
> [ 2866.574214] Object ffff880019ec09f0: 4e f7 e3 02 07 df 26 00 08 39 00 00 0e 8b e2 02  N.....&..9......
> [ 2866.574214] Object ffff880019ec0a00: 41 22 27 00 00 00 00 00 00 00 00 00 00 00 00 00  A"'.............
> [ 2866.574214] Object ffff880019ec0a10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [ 2866.574214] Redzone ffff880019ec0a20: bb bb bb bb bb bb bb bb                          ........
> [ 2866.574214] Padding ffff880019ec0b60: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [ 2866.574214] Padding ffff880019ec0b70: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [ 2866.574214] Pid: 652, comm: kworker/0:1 Not tainted 3.6.0-rc1+ #622
> [ 2866.574214] Call Trace:
> [ 2866.574214]  <IRQ>  [<ffffffff811517b4>] ? print_section+0x3d/0x3f
> [ 2866.574214]  [<ffffffff811528f7>] print_trailer+0x12b/0x134
> [ 2866.574214]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.574214]  [<ffffffff81152938>] object_err+0x38/0x41
> [ 2866.574214]  [<ffffffff819fb4cd>] free_debug_processing+0x14d/0x264
> [ 2866.574214]  [<ffffffff8106b56e>] ? vprintk_emit+0x479/0x4a5
> [ 2866.574214]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.574214]  [<ffffffff819fb61e>] __slab_free+0x3a/0x383
> [ 2866.574214]  [<ffffffff8143b242>] ? check_unmap+0x5fb/0x6d5
> [ 2866.574214]  [<ffffffff819f825e>] ? printk+0x4d/0x4f
> [ 2866.574214]  [<ffffffff818a0839>] ? __sk_free+0xfd/0x114
> [ 2866.574214]  [<ffffffff81154a86>] kmem_cache_free+0xf7/0x13a
> [ 2866.574214]  [<ffffffff818a0839>] __sk_free+0xfd/0x114
> [ 2866.574214]  [<ffffffff818a089f>] sock_wfree+0x4f/0x54
> [ 2866.574214]  [<ffffffff8190dab9>] tcp_wfree+0xca/0xd2
> [ 2866.574214]  [<ffffffff818a4a8c>] skb_release_head_state+0x7f/0xd3
> [ 2866.574214]  [<ffffffff818a4897>] __kfree_skb+0x13/0x7e
> [ 2866.574214]  [<ffffffff818a4968>] consume_skb+0x40/0x6c
> [ 2866.574214]  [<ffffffff818ae25b>] dev_kfree_skb_any+0x36/0x38
> [ 2866.574214]  [<ffffffff816dc0e0>] e1000_unmap_and_free_tx_resource.isra.24+0xd5/0xed
> [ 2866.574214]  [<ffffffff816dc1ae>] e1000_clean+0xb6/0x6c6
> [ 2866.574214]  [<ffffffff810b79a8>] ? trace_hardirqs_off+0xd/0xf
> [ 2866.574214]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.574214]  [<ffffffff818ae4f4>] net_rx_action+0xb5/0x1f3
> [ 2866.574214]  [<ffffffff81070bd6>] __do_softirq+0xcb/0x1f9
> [ 2866.574214]  [<ffffffff81a1227c>] call_softirq+0x1c/0x30
> [ 2866.574214]  <EOI>  [<ffffffff81039f38>] do_softirq+0x4a/0xa6
> [ 2866.574214]  [<ffffffff818faaaa>] ? ip_finish_output+0x413/0x501
> [ 2866.574214]  [<ffffffff81070939>] local_bh_enable+0xb2/0xe6
> [ 2866.574214]  [<ffffffff818faaaa>] ip_finish_output+0x413/0x501
> [ 2866.574214]  [<ffffffff818fa967>] ? ip_finish_output+0x2d0/0x501
> [ 2866.574214]  [<ffffffff818fbf0d>] ip_output+0x8a/0xdf
> [ 2866.574214]  [<ffffffff818fb688>] ip_local_out+0x59/0x72
> [ 2866.574214]  [<ffffffff818fb9db>] ip_queue_xmit+0x33a/0x3c3
> [ 2866.574214]  [<ffffffff818fb6a1>] ? ip_local_out+0x72/0x72
> [ 2866.574214]  [<ffffffff8190ef0d>] tcp_transmit_skb+0x745/0x7aa
> [ 2866.574214]  [<ffffffff8190f7db>] tcp_write_xmit+0x7cf/0x8e4
> [ 2866.574214]  [<ffffffff818a565d>] ? __alloc_skb+0xa0/0x1a1
> [ 2866.574214]  [<ffffffff8190f952>] __tcp_push_pending_frames+0x2e/0x8a
> [ 2866.574214]  [<ffffffff81904122>] tcp_sendmsg+0xb32/0xcc6
> [ 2866.574214]  [<ffffffff819229c2>] inet_sendmsg+0xaa/0xd5
> [ 2866.574214]  [<ffffffff81922918>] ? inet_autobind+0x5f/0x5f
> [ 2866.574214]  [<ffffffff81922918>] ? inet_autobind+0x5f/0x5f
> [ 2866.574214]  [<ffffffff8189adab>] sock_sendmsg+0xa3/0xc4
> [ 2866.574214]  [<ffffffff810f6524>] ? ring_buffer_lock_reserve+0xc2/0x126
> [ 2866.574214]  [<ffffffff810bc29b>] ? trace_hardirqs_on_caller+0x16/0x181
> [ 2866.574214]  [<ffffffff8103e6a9>] ? native_sched_clock+0x29/0x6f
> [ 2866.574214]  [<ffffffff8189ae03>] kernel_sendmsg+0x37/0x43
> [ 2866.574214]  [<ffffffff8199ce49>] xs_send_kvec+0x77/0x80
> [ 2866.574214]  [<ffffffff81267e6e>] ? nfs3_xdr_enc_write3args+0x6c/0x6c
> [ 2866.574214]  [<ffffffff8199cec1>] xs_sendpages+0x6f/0x1a0
> [ 2866.574214]  [<ffffffff819a9ab9>] ? xdr_encode_opaque+0x18/0x1a
> [ 2866.574214]  [<ffffffff81267cf9>] ? encode_nfs_fh3+0x31/0x36
> [ 2866.574214]  [<ffffffff8199d0d2>] xs_tcp_send_request+0x55/0xf1
> [ 2866.574214]  [<ffffffff8199bb90>] xprt_transmit+0x89/0x1db
> [ 2866.574214]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.574214]  [<ffffffff81999d92>] call_transmit+0x1c5/0x20e
> [ 2866.574214]  [<ffffffff819a0d55>] __rpc_execute+0x6f/0x225
> [ 2866.574214]  [<ffffffff81999bcd>] ? call_connect+0x3c/0x3c
> [ 2866.574214]  [<ffffffff819a0f33>] rpc_async_schedule+0x28/0x34
> [ 2866.574214]  [<ffffffff810835d6>] process_one_work+0x24d/0x47f
> [ 2866.574214]  [<ffffffff81083567>] ? process_one_work+0x1de/0x47f
> [ 2866.574214]  [<ffffffff819a0f0b>] ? __rpc_execute+0x225/0x225
> [ 2866.574214]  [<ffffffff81083a6d>] worker_thread+0x236/0x317
> [ 2866.574214]  [<ffffffff81083837>] ? process_scheduled_works+0x2f/0x2f
> [ 2866.574214]  [<ffffffff8108b7b8>] kthread+0x9a/0xa2
> [ 2866.574214]  [<ffffffff81a12184>] kernel_thread_helper+0x4/0x10
> [ 2866.574214]  [<ffffffff81a0a4b0>] ? retint_restore_args+0x13/0x13
> [ 2866.574214]  [<ffffffff8108b71e>] ? __init_kthread_worker+0x5a/0x5a
> [ 2866.574214]  [<ffffffff81a12180>] ? gs_change+0x13/0x13
> [ 2866.574214] FIX TCP: Object at 0xffff880019ec0000 not freed
> [ 2866.729190] IPv4: Attempt to release TCP socket in state 1 ffff880019ec0000
> [ 2866.730415] =============================================================================
> [ 2866.731190] BUG TCP (Not tainted): Object already free
> [ 2866.731190] -----------------------------------------------------------------------------
> [ 2866.731190] 
> [ 2866.731190] INFO: Allocated in sk_prot_alloc.isra.35+0x30/0xd2 age=2724467 cpu=0 pid=652
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] INFO: Freed in __sk_free+0xfd/0x114 age=597 cpu=0 pid=652
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] 
> [ 2866.731190] INFO: Slab 0xffffea000067b000 objects=11 used=9 fp=0xffff880019ec0000 flags=0x100000000004081
> [ 2866.731190] INFO: Object 0xffff880019ec0000 @offset=0 fp=0xffff880019ec5c00
> [ 2866.731190] 
> [ 2866.731190] Object ffff880019ec0000: 0a ef 61 0e 0a 00 02 0f bb 7c 0f b9 02 00 01 00  ..a......|......
> [ 2866.731190] Object ffff880019ec0010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

> #
> # Automatically generated file; DO NOT EDIT.
> # Linux/x86_64 3.6.0-rc1 Kernel Configuration
> #
> CONFIG_64BIT=y
> # CONFIG_X86_32 is not set
> CONFIG_X86_64=y
> CONFIG_X86=y
> CONFIG_INSTRUCTION_DECODER=y
> CONFIG_OUTPUT_FORMAT="elf64-x86-64"
> CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
> CONFIG_LOCKDEP_SUPPORT=y
> CONFIG_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_LATENCYTOP_SUPPORT=y
> CONFIG_MMU=y
> CONFIG_NEED_DMA_MAP_STATE=y
> CONFIG_NEED_SG_DMA_LENGTH=y
> CONFIG_GENERIC_ISA_DMA=y
> CONFIG_GENERIC_BUG=y
> CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
> CONFIG_GENERIC_HWEIGHT=y
> CONFIG_ARCH_MAY_HAVE_PC_FDC=y
> # CONFIG_RWSEM_GENERIC_SPINLOCK is not set
> CONFIG_RWSEM_XCHGADD_ALGORITHM=y
> CONFIG_GENERIC_CALIBRATE_DELAY=y
> CONFIG_ARCH_HAS_CPU_RELAX=y
> CONFIG_ARCH_HAS_DEFAULT_IDLE=y
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
> CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
> CONFIG_HAVE_SETUP_PER_CPU_AREA=y
> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
> CONFIG_ARCH_HIBERNATION_POSSIBLE=y
> CONFIG_ARCH_SUSPEND_POSSIBLE=y
> CONFIG_ZONE_DMA32=y
> CONFIG_AUDIT_ARCH=y
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
> CONFIG_X86_64_SMP=y
> CONFIG_X86_HT=y
> CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
> CONFIG_ARCH_CPU_PROBE_RELEASE=y
> CONFIG_ARCH_SUPPORTS_UPROBES=y
> CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
> CONFIG_HAVE_IRQ_WORK=y
> CONFIG_IRQ_WORK=y
> CONFIG_BUILDTIME_EXTABLE_SORT=y
> 
> #
> # General setup
> #
> CONFIG_EXPERIMENTAL=y
> CONFIG_INIT_ENV_ARG_LIMIT=32
> CONFIG_CROSS_COMPILE=""
> CONFIG_LOCALVERSION=""
> # CONFIG_LOCALVERSION_AUTO is not set
> CONFIG_HAVE_KERNEL_GZIP=y
> CONFIG_HAVE_KERNEL_BZIP2=y
> CONFIG_HAVE_KERNEL_LZMA=y
> CONFIG_HAVE_KERNEL_XZ=y
> CONFIG_HAVE_KERNEL_LZO=y
> CONFIG_KERNEL_GZIP=y
> # CONFIG_KERNEL_BZIP2 is not set
> # CONFIG_KERNEL_LZMA is not set
> # CONFIG_KERNEL_XZ is not set
> # CONFIG_KERNEL_LZO is not set
> CONFIG_DEFAULT_HOSTNAME="(none)"
> CONFIG_SWAP=y
> CONFIG_SYSVIPC=y
> CONFIG_SYSVIPC_SYSCTL=y
> CONFIG_POSIX_MQUEUE=y
> CONFIG_POSIX_MQUEUE_SYSCTL=y
> CONFIG_BSD_PROCESS_ACCT=y
> CONFIG_BSD_PROCESS_ACCT_V3=y
> # CONFIG_FHANDLE is not set
> CONFIG_TASKSTATS=y
> CONFIG_TASK_DELAY_ACCT=y
> CONFIG_TASK_XACCT=y
> CONFIG_TASK_IO_ACCOUNTING=y
> CONFIG_AUDIT=y
> CONFIG_AUDITSYSCALL=y
> CONFIG_AUDIT_WATCH=y
> CONFIG_AUDIT_TREE=y
> # CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
> CONFIG_HAVE_GENERIC_HARDIRQS=y
> 
> #
> # IRQ subsystem
> #
> CONFIG_GENERIC_HARDIRQS=y
> CONFIG_GENERIC_IRQ_PROBE=y
> CONFIG_GENERIC_IRQ_SHOW=y
> CONFIG_GENERIC_PENDING_IRQ=y
> CONFIG_IRQ_DOMAIN=y
> # CONFIG_IRQ_DOMAIN_DEBUG is not set
> CONFIG_IRQ_FORCED_THREADING=y
> CONFIG_SPARSE_IRQ=y
> CONFIG_CLOCKSOURCE_WATCHDOG=y
> CONFIG_ARCH_CLOCKSOURCE_DATA=y
> CONFIG_GENERIC_TIME_VSYSCALL=y
> CONFIG_GENERIC_CLOCKEVENTS=y
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
> CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
> CONFIG_GENERIC_CMOS_UPDATE=y
> 
> #
> # Timers subsystem
> #
> CONFIG_TICK_ONESHOT=y
> CONFIG_NO_HZ=y
> CONFIG_HIGH_RES_TIMERS=y
> 
> #
> # RCU Subsystem
> #
> CONFIG_TREE_RCU=y
> # CONFIG_PREEMPT_RCU is not set
> CONFIG_RCU_FANOUT=64
> CONFIG_RCU_FANOUT_LEAF=16
> # CONFIG_RCU_FANOUT_EXACT is not set
> # CONFIG_RCU_FAST_NO_HZ is not set
> CONFIG_TREE_RCU_TRACE=y
> CONFIG_IKCONFIG=y
> CONFIG_IKCONFIG_PROC=y
> CONFIG_LOG_BUF_SHIFT=18
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
> CONFIG_CGROUPS=y
> CONFIG_CGROUP_DEBUG=y
> CONFIG_CGROUP_FREEZER=y
> CONFIG_CGROUP_DEVICE=y
> CONFIG_CPUSETS=y
> CONFIG_PROC_PID_CPUSET=y
> CONFIG_CGROUP_CPUACCT=y
> CONFIG_RESOURCE_COUNTERS=y
> # CONFIG_MEMCG is not set
> # CONFIG_CGROUP_HUGETLB is not set
> # CONFIG_CGROUP_PERF is not set
> CONFIG_CGROUP_SCHED=y
> CONFIG_FAIR_GROUP_SCHED=y
> # CONFIG_CFS_BANDWIDTH is not set
> # CONFIG_RT_GROUP_SCHED is not set
> CONFIG_BLK_CGROUP=y
> CONFIG_DEBUG_BLK_CGROUP=y
> # CONFIG_CHECKPOINT_RESTORE is not set
> # CONFIG_NAMESPACES is not set
> # CONFIG_SCHED_AUTOGROUP is not set
> # CONFIG_SYSFS_DEPRECATED is not set
> CONFIG_RELAY=y
> CONFIG_BLK_DEV_INITRD=y
> CONFIG_INITRAMFS_SOURCE=""
> CONFIG_RD_GZIP=y
> # CONFIG_RD_BZIP2 is not set
> # CONFIG_RD_LZMA is not set
> # CONFIG_RD_XZ is not set
> # CONFIG_RD_LZO is not set
> CONFIG_CC_OPTIMIZE_FOR_SIZE=y
> CONFIG_SYSCTL=y
> CONFIG_ANON_INODES=y
> CONFIG_EXPERT=y
> CONFIG_UID16=y
> CONFIG_SYSCTL_SYSCALL=y
> CONFIG_KALLSYMS=y
> CONFIG_KALLSYMS_ALL=y
> CONFIG_HOTPLUG=y
> CONFIG_PRINTK=y
> CONFIG_BUG=y
> CONFIG_ELF_CORE=y
> CONFIG_PCSPKR_PLATFORM=y
> CONFIG_HAVE_PCSPKR_PLATFORM=y
> CONFIG_BASE_FULL=y
> CONFIG_FUTEX=y
> CONFIG_EPOLL=y
> CONFIG_SIGNALFD=y
> CONFIG_TIMERFD=y
> CONFIG_EVENTFD=y
> CONFIG_SHMEM=y
> CONFIG_AIO=y
> CONFIG_EMBEDDED=y
> CONFIG_HAVE_PERF_EVENTS=y
> 
> #
> # Kernel Performance Events And Counters
> #
> CONFIG_PERF_EVENTS=y
> # CONFIG_DEBUG_PERF_USE_VMALLOC is not set
> CONFIG_VM_EVENT_COUNTERS=y
> CONFIG_PCI_QUIRKS=y
> CONFIG_SLUB_DEBUG=y
> CONFIG_COMPAT_BRK=y
> # CONFIG_SLAB is not set
> CONFIG_SLUB=y
> # CONFIG_SLOB is not set
> CONFIG_PROFILING=y
> CONFIG_TRACEPOINTS=y
> CONFIG_OPROFILE=y
> # CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
> CONFIG_HAVE_OPROFILE=y
> CONFIG_OPROFILE_NMI_TIMER=y
> CONFIG_KPROBES=y
> # CONFIG_JUMP_LABEL is not set
> CONFIG_OPTPROBES=y
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
> CONFIG_KRETPROBES=y
> CONFIG_USER_RETURN_NOTIFIER=y
> CONFIG_HAVE_IOREMAP_PROT=y
> CONFIG_HAVE_KPROBES=y
> CONFIG_HAVE_KRETPROBES=y
> CONFIG_HAVE_OPTPROBES=y
> CONFIG_HAVE_ARCH_TRACEHOOK=y
> CONFIG_HAVE_DMA_ATTRS=y
> CONFIG_USE_GENERIC_SMP_HELPERS=y
> CONFIG_GENERIC_SMP_IDLE_THREAD=y
> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
> CONFIG_HAVE_DMA_API_DEBUG=y
> CONFIG_HAVE_HW_BREAKPOINT=y
> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
> CONFIG_HAVE_USER_RETURN_NOTIFIER=y
> CONFIG_HAVE_PERF_EVENTS_NMI=y
> CONFIG_HAVE_ARCH_JUMP_LABEL=y
> CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
> CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
> CONFIG_HAVE_CMPXCHG_LOCAL=y
> CONFIG_HAVE_CMPXCHG_DOUBLE=y
> CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
> CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
> CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
> CONFIG_SECCOMP_FILTER=y
> 
> #
> # GCOV-based kernel profiling
> #
> # CONFIG_GCOV_KERNEL is not set
> # CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
> CONFIG_SLABINFO=y
> CONFIG_RT_MUTEXES=y
> CONFIG_BASE_SMALL=0
> CONFIG_MODULES=y
> # CONFIG_MODULE_FORCE_LOAD is not set
> CONFIG_MODULE_UNLOAD=y
> CONFIG_MODULE_FORCE_UNLOAD=y
> # CONFIG_MODVERSIONS is not set
> # CONFIG_MODULE_SRCVERSION_ALL is not set
> CONFIG_STOP_MACHINE=y
> CONFIG_BLOCK=y
> CONFIG_BLK_DEV_BSG=y
> CONFIG_BLK_DEV_BSGLIB=y
> CONFIG_BLK_DEV_INTEGRITY=y
> # CONFIG_BLK_DEV_THROTTLING is not set
> 
> #
> # Partition Types
> #
> # CONFIG_PARTITION_ADVANCED is not set
> CONFIG_MSDOS_PARTITION=y
> CONFIG_BLOCK_COMPAT=y
> 
> #
> # IO Schedulers
> #
> CONFIG_IOSCHED_NOOP=y
> CONFIG_IOSCHED_DEADLINE=y
> CONFIG_IOSCHED_CFQ=y
> CONFIG_CFQ_GROUP_IOSCHED=y
> # CONFIG_DEFAULT_DEADLINE is not set
> CONFIG_DEFAULT_CFQ=y
> # CONFIG_DEFAULT_NOOP is not set
> CONFIG_DEFAULT_IOSCHED="cfq"
> CONFIG_PREEMPT_NOTIFIERS=y
> # CONFIG_INLINE_SPIN_TRYLOCK is not set
> # CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
> # CONFIG_INLINE_SPIN_LOCK is not set
> # CONFIG_INLINE_SPIN_LOCK_BH is not set
> # CONFIG_INLINE_SPIN_LOCK_IRQ is not set
> # CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
> CONFIG_UNINLINE_SPIN_UNLOCK=y
> # CONFIG_INLINE_SPIN_UNLOCK_BH is not set
> # CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
> # CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
> # CONFIG_INLINE_READ_TRYLOCK is not set
> # CONFIG_INLINE_READ_LOCK is not set
> # CONFIG_INLINE_READ_LOCK_BH is not set
> # CONFIG_INLINE_READ_LOCK_IRQ is not set
> # CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
> # CONFIG_INLINE_READ_UNLOCK is not set
> # CONFIG_INLINE_READ_UNLOCK_BH is not set
> # CONFIG_INLINE_READ_UNLOCK_IRQ is not set
> # CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
> # CONFIG_INLINE_WRITE_TRYLOCK is not set
> # CONFIG_INLINE_WRITE_LOCK is not set
> # CONFIG_INLINE_WRITE_LOCK_BH is not set
> # CONFIG_INLINE_WRITE_LOCK_IRQ is not set
> # CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
> # CONFIG_INLINE_WRITE_UNLOCK is not set
> # CONFIG_INLINE_WRITE_UNLOCK_BH is not set
> # CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
> # CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
> # CONFIG_MUTEX_SPIN_ON_OWNER is not set
> CONFIG_FREEZER=y
> 
> #
> # Processor type and features
> #
> CONFIG_ZONE_DMA=y
> CONFIG_SMP=y
> CONFIG_X86_MPPARSE=y
> CONFIG_X86_EXTENDED_PLATFORM=y
> # CONFIG_X86_VSMP is not set
> CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
> CONFIG_SCHED_OMIT_FRAME_POINTER=y
> CONFIG_PARAVIRT_GUEST=y
> # CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
> # CONFIG_XEN is not set
> # CONFIG_XEN_PRIVILEGED_GUEST is not set
> CONFIG_KVM_CLOCK=y
> CONFIG_KVM_GUEST=y
> CONFIG_PARAVIRT=y
> # CONFIG_PARAVIRT_SPINLOCKS is not set
> CONFIG_PARAVIRT_CLOCK=y
> # CONFIG_PARAVIRT_DEBUG is not set
> CONFIG_NO_BOOTMEM=y
> CONFIG_MEMTEST=y
> # CONFIG_MK8 is not set
> # CONFIG_MPSC is not set
> CONFIG_MCORE2=y
> # CONFIG_MATOM is not set
> # CONFIG_GENERIC_CPU is not set
> CONFIG_X86_INTERNODE_CACHE_SHIFT=6
> CONFIG_X86_CMPXCHG=y
> CONFIG_X86_L1_CACHE_SHIFT=6
> CONFIG_X86_XADD=y
> CONFIG_X86_WP_WORKS_OK=y
> CONFIG_X86_INTEL_USERCOPY=y
> CONFIG_X86_USE_PPRO_CHECKSUM=y
> CONFIG_X86_P6_NOP=y
> CONFIG_X86_TSC=y
> CONFIG_X86_CMPXCHG64=y
> CONFIG_X86_CMOV=y
> CONFIG_X86_MINIMUM_CPU_FAMILY=64
> CONFIG_X86_DEBUGCTLMSR=y
> CONFIG_PROCESSOR_SELECT=y
> CONFIG_CPU_SUP_INTEL=y
> # CONFIG_CPU_SUP_AMD is not set
> CONFIG_CPU_SUP_CENTAUR=y
> CONFIG_HPET_TIMER=y
> CONFIG_HPET_EMULATE_RTC=y
> CONFIG_DMI=y
> # CONFIG_CALGARY_IOMMU is not set
> CONFIG_SWIOTLB=y
> CONFIG_IOMMU_HELPER=y
> # CONFIG_MAXSMP is not set
> CONFIG_NR_CPUS=64
> CONFIG_SCHED_SMT=y
> CONFIG_SCHED_MC=y
> # CONFIG_IRQ_TIME_ACCOUNTING is not set
> # CONFIG_PREEMPT_NONE is not set
> CONFIG_PREEMPT_VOLUNTARY=y
> # CONFIG_PREEMPT is not set
> CONFIG_X86_LOCAL_APIC=y
> CONFIG_X86_IO_APIC=y
> # CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
> CONFIG_X86_MCE=y
> CONFIG_X86_MCE_INTEL=y
> # CONFIG_X86_MCE_AMD is not set
> CONFIG_X86_MCE_THRESHOLD=y
> CONFIG_X86_MCE_INJECT=y
> CONFIG_X86_THERMAL_VECTOR=y
> # CONFIG_I8K is not set
> CONFIG_MICROCODE=y
> CONFIG_MICROCODE_INTEL=y
> # CONFIG_MICROCODE_AMD is not set
> CONFIG_MICROCODE_OLD_INTERFACE=y
> CONFIG_X86_MSR=y
> CONFIG_X86_CPUID=y
> CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
> CONFIG_ARCH_DMA_ADDR_T_64BIT=y
> CONFIG_DIRECT_GBPAGES=y
> CONFIG_NUMA=y
> CONFIG_AMD_NUMA=y
> CONFIG_X86_64_ACPI_NUMA=y
> CONFIG_NODES_SPAN_OTHER_NODES=y
> CONFIG_NUMA_EMU=y
> CONFIG_NODES_SHIFT=6
> CONFIG_ARCH_SPARSEMEM_ENABLE=y
> CONFIG_ARCH_SPARSEMEM_DEFAULT=y
> CONFIG_ARCH_SELECT_MEMORY_MODEL=y
> CONFIG_ARCH_MEMORY_PROBE=y
> CONFIG_ARCH_PROC_KCORE_TEXT=y
> CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
> CONFIG_SELECT_MEMORY_MODEL=y
> CONFIG_SPARSEMEM_MANUAL=y
> CONFIG_SPARSEMEM=y
> CONFIG_NEED_MULTIPLE_NODES=y
> CONFIG_HAVE_MEMORY_PRESENT=y
> CONFIG_SPARSEMEM_EXTREME=y
> CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
> CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
> CONFIG_SPARSEMEM_VMEMMAP=y
> CONFIG_HAVE_MEMBLOCK=y
> CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
> CONFIG_ARCH_DISCARD_MEMBLOCK=y
> CONFIG_MEMORY_ISOLATION=y
> CONFIG_MEMORY_HOTPLUG=y
> CONFIG_MEMORY_HOTPLUG_SPARSE=y
> CONFIG_MEMORY_HOTREMOVE=y
> CONFIG_PAGEFLAGS_EXTENDED=y
> CONFIG_SPLIT_PTLOCK_CPUS=999999
> # CONFIG_COMPACTION is not set
> CONFIG_MIGRATION=y
> CONFIG_PHYS_ADDR_T_64BIT=y
> CONFIG_ZONE_DMA_FLAG=1
> CONFIG_BOUNCE=y
> CONFIG_VIRT_TO_BUS=y
> CONFIG_MMU_NOTIFIER=y
> CONFIG_KSM=y
> CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
> CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
> CONFIG_MEMORY_FAILURE=y
> CONFIG_HWPOISON_INJECT=y
> # CONFIG_TRANSPARENT_HUGEPAGE is not set
> CONFIG_CROSS_MEMORY_ATTACH=y
> # CONFIG_CLEANCACHE is not set
> # CONFIG_FRONTSWAP is not set
> CONFIG_X86_CHECK_BIOS_CORRUPTION=y
> CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
> CONFIG_X86_RESERVE_LOW=64
> CONFIG_MTRR=y
> # CONFIG_MTRR_SANITIZER is not set
> CONFIG_X86_PAT=y
> CONFIG_ARCH_USES_PG_UNCACHED=y
> CONFIG_ARCH_RANDOM=y
> CONFIG_EFI=y
> # CONFIG_EFI_STUB is not set
> CONFIG_SECCOMP=y
> # CONFIG_CC_STACKPROTECTOR is not set
> # CONFIG_HZ_100 is not set
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_300 is not set
> CONFIG_HZ_1000=y
> CONFIG_HZ=1000
> CONFIG_SCHED_HRTICK=y
> CONFIG_KEXEC=y
> CONFIG_CRASH_DUMP=y
> # CONFIG_KEXEC_JUMP is not set
> CONFIG_PHYSICAL_START=0x1000000
> CONFIG_RELOCATABLE=y
> CONFIG_PHYSICAL_ALIGN=0x1000000
> CONFIG_HOTPLUG_CPU=y
> CONFIG_COMPAT_VDSO=y
> # CONFIG_CMDLINE_BOOL is not set
> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
> CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
> CONFIG_USE_PERCPU_NUMA_NODE_ID=y
> 
> #
> # Power management and ACPI options
> #
> CONFIG_ARCH_HIBERNATION_HEADER=y
> CONFIG_SUSPEND=y
> CONFIG_SUSPEND_FREEZER=y
> CONFIG_HIBERNATE_CALLBACKS=y
> CONFIG_HIBERNATION=y
> CONFIG_PM_STD_PARTITION=""
> CONFIG_PM_SLEEP=y
> CONFIG_PM_SLEEP_SMP=y
> # CONFIG_PM_AUTOSLEEP is not set
> # CONFIG_PM_WAKELOCKS is not set
> CONFIG_PM_RUNTIME=y
> CONFIG_PM=y
> CONFIG_PM_DEBUG=y
> CONFIG_PM_ADVANCED_DEBUG=y
> CONFIG_PM_TEST_SUSPEND=y
> CONFIG_PM_SLEEP_DEBUG=y
> CONFIG_PM_TRACE=y
> CONFIG_PM_TRACE_RTC=y
> CONFIG_ACPI=y
> CONFIG_ACPI_SLEEP=y
> CONFIG_ACPI_PROCFS=y
> CONFIG_ACPI_PROCFS_POWER=y
> # CONFIG_ACPI_EC_DEBUGFS is not set
> CONFIG_ACPI_PROC_EVENT=y
> CONFIG_ACPI_AC=y
> CONFIG_ACPI_BATTERY=y
> CONFIG_ACPI_BUTTON=y
> CONFIG_ACPI_VIDEO=y
> CONFIG_ACPI_FAN=y
> CONFIG_ACPI_DOCK=y
> CONFIG_ACPI_PROCESSOR=y
> CONFIG_ACPI_HOTPLUG_CPU=y
> # CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
> CONFIG_ACPI_THERMAL=y
> CONFIG_ACPI_NUMA=y
> CONFIG_ACPI_CUSTOM_DSDT_FILE=""
> # CONFIG_ACPI_CUSTOM_DSDT is not set
> CONFIG_ACPI_BLACKLIST_YEAR=0
> CONFIG_ACPI_DEBUG=y
> CONFIG_ACPI_DEBUG_FUNC_TRACE=y
> CONFIG_ACPI_PCI_SLOT=y
> CONFIG_X86_PM_TIMER=y
> CONFIG_ACPI_CONTAINER=y
> # CONFIG_ACPI_HOTPLUG_MEMORY is not set
> CONFIG_ACPI_SBS=y
> # CONFIG_ACPI_HED is not set
> # CONFIG_ACPI_CUSTOM_METHOD is not set
> # CONFIG_ACPI_BGRT is not set
> # CONFIG_ACPI_APEI is not set
> # CONFIG_SFI is not set
> 
> #
> # CPU Frequency scaling
> #
> CONFIG_CPU_FREQ=y
> CONFIG_CPU_FREQ_TABLE=y
> CONFIG_CPU_FREQ_STAT=y
> CONFIG_CPU_FREQ_STAT_DETAILS=y
> # CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
> CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
> # CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
> CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
> CONFIG_CPU_FREQ_GOV_POWERSAVE=y
> CONFIG_CPU_FREQ_GOV_USERSPACE=y
> CONFIG_CPU_FREQ_GOV_ONDEMAND=y
> CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
> 
> #
> # x86 CPU frequency scaling drivers
> #
> # CONFIG_X86_PCC_CPUFREQ is not set
> CONFIG_X86_ACPI_CPUFREQ=y
> # CONFIG_X86_POWERNOW_K8 is not set
> CONFIG_X86_SPEEDSTEP_CENTRINO=y
> # CONFIG_X86_P4_CLOCKMOD is not set
> 
> #
> # shared options
> #
> # CONFIG_X86_SPEEDSTEP_LIB is not set
> CONFIG_CPU_IDLE=y
> CONFIG_CPU_IDLE_GOV_LADDER=y
> CONFIG_CPU_IDLE_GOV_MENU=y
> # CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
> # CONFIG_INTEL_IDLE is not set
> 
> #
> # Memory power savings
> #
> CONFIG_I7300_IDLE_IOAT_CHANNEL=y
> CONFIG_I7300_IDLE=y
> 
> #
> # Bus options (PCI etc.)
> #
> CONFIG_PCI=y
> CONFIG_PCI_DIRECT=y
> CONFIG_PCI_MMCONFIG=y
> CONFIG_PCI_DOMAINS=y
> # CONFIG_PCI_CNB20LE_QUIRK is not set
> CONFIG_PCIEPORTBUS=y
> # CONFIG_HOTPLUG_PCI_PCIE is not set
> CONFIG_PCIEAER=y
> # CONFIG_PCIE_ECRC is not set
> # CONFIG_PCIEAER_INJECT is not set
> # CONFIG_PCIEASPM is not set
> CONFIG_PCIE_PME=y
> CONFIG_ARCH_SUPPORTS_MSI=y
> CONFIG_PCI_MSI=y
> # CONFIG_PCI_DEBUG is not set
> # CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
> # CONFIG_PCI_STUB is not set
> CONFIG_HT_IRQ=y
> # CONFIG_PCI_IOV is not set
> # CONFIG_PCI_PRI is not set
> # CONFIG_PCI_PASID is not set
> CONFIG_PCI_IOAPIC=y
> CONFIG_PCI_LABEL=y
> CONFIG_ISA_DMA_API=y
> # CONFIG_PCCARD is not set
> CONFIG_HOTPLUG_PCI=y
> # CONFIG_HOTPLUG_PCI_FAKE is not set
> # CONFIG_HOTPLUG_PCI_ACPI is not set
> # CONFIG_HOTPLUG_PCI_CPCI is not set
> # CONFIG_HOTPLUG_PCI_SHPC is not set
> # CONFIG_RAPIDIO is not set
> 
> #
> # Executable file formats / Emulations
> #
> CONFIG_BINFMT_ELF=y
> CONFIG_COMPAT_BINFMT_ELF=y
> CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
> # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
> # CONFIG_HAVE_AOUT is not set
> # CONFIG_BINFMT_MISC is not set
> CONFIG_IA32_EMULATION=y
> # CONFIG_IA32_AOUT is not set
> # CONFIG_X86_X32 is not set
> CONFIG_COMPAT=y
> CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
> CONFIG_SYSVIPC_COMPAT=y
> CONFIG_KEYS_COMPAT=y
> CONFIG_HAVE_TEXT_POKE_SMP=y
> CONFIG_X86_DEV_DMA_OPS=y
> CONFIG_NET=y
> 
> #
> # Networking options
> #
> CONFIG_PACKET=y
> CONFIG_UNIX=y
> # CONFIG_UNIX_DIAG is not set
> CONFIG_XFRM=y
> CONFIG_XFRM_ALGO=y
> CONFIG_XFRM_USER=y
> # CONFIG_XFRM_SUB_POLICY is not set
> # CONFIG_XFRM_MIGRATE is not set
> # CONFIG_XFRM_STATISTICS is not set
> CONFIG_XFRM_IPCOMP=y
> CONFIG_NET_KEY=y
> # CONFIG_NET_KEY_MIGRATE is not set
> CONFIG_INET=y
> # CONFIG_IP_MULTICAST is not set
> # CONFIG_IP_ADVANCED_ROUTER is not set
> CONFIG_IP_ROUTE_CLASSID=y
> CONFIG_IP_PNP=y
> CONFIG_IP_PNP_DHCP=y
> # CONFIG_IP_PNP_BOOTP is not set
> # CONFIG_IP_PNP_RARP is not set
> # CONFIG_NET_IPIP is not set
> # CONFIG_NET_IPGRE_DEMUX is not set
> # CONFIG_ARPD is not set
> # CONFIG_SYN_COOKIES is not set
> CONFIG_INET_AH=y
> CONFIG_INET_ESP=y
> CONFIG_INET_IPCOMP=y
> CONFIG_INET_XFRM_TUNNEL=y
> CONFIG_INET_TUNNEL=y
> # CONFIG_INET_XFRM_MODE_TRANSPORT is not set
> # CONFIG_INET_XFRM_MODE_TUNNEL is not set
> # CONFIG_INET_XFRM_MODE_BEET is not set
> CONFIG_INET_LRO=y
> CONFIG_INET_DIAG=y
> CONFIG_INET_TCP_DIAG=y
> # CONFIG_INET_UDP_DIAG is not set
> CONFIG_TCP_CONG_ADVANCED=y
> CONFIG_TCP_CONG_BIC=y
> CONFIG_TCP_CONG_CUBIC=y
> CONFIG_TCP_CONG_WESTWOOD=y
> CONFIG_TCP_CONG_HTCP=y
> CONFIG_TCP_CONG_HSTCP=y
> CONFIG_TCP_CONG_HYBLA=y
> CONFIG_TCP_CONG_VEGAS=y
> CONFIG_TCP_CONG_SCALABLE=y
> CONFIG_TCP_CONG_LP=y
> CONFIG_TCP_CONG_VENO=y
> CONFIG_TCP_CONG_YEAH=y
> CONFIG_TCP_CONG_ILLINOIS=y
> # CONFIG_DEFAULT_BIC is not set
> CONFIG_DEFAULT_CUBIC=y
> # CONFIG_DEFAULT_HTCP is not set
> # CONFIG_DEFAULT_HYBLA is not set
> # CONFIG_DEFAULT_VEGAS is not set
> # CONFIG_DEFAULT_VENO is not set
> # CONFIG_DEFAULT_WESTWOOD is not set
> # CONFIG_DEFAULT_RENO is not set
> CONFIG_DEFAULT_TCP_CONG="cubic"
> # CONFIG_TCP_MD5SIG is not set
> CONFIG_IPV6=y
> # CONFIG_IPV6_PRIVACY is not set
> # CONFIG_IPV6_ROUTER_PREF is not set
> # CONFIG_IPV6_OPTIMISTIC_DAD is not set
> # CONFIG_INET6_AH is not set
> # CONFIG_INET6_ESP is not set
> # CONFIG_INET6_IPCOMP is not set
> # CONFIG_IPV6_MIP6 is not set
> # CONFIG_INET6_XFRM_TUNNEL is not set
> # CONFIG_INET6_TUNNEL is not set
> CONFIG_INET6_XFRM_MODE_TRANSPORT=y
> CONFIG_INET6_XFRM_MODE_TUNNEL=y
> CONFIG_INET6_XFRM_MODE_BEET=y
> # CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
> CONFIG_IPV6_SIT=y
> # CONFIG_IPV6_SIT_6RD is not set
> CONFIG_IPV6_NDISC_NODETYPE=y
> # CONFIG_IPV6_TUNNEL is not set
> # CONFIG_IPV6_MULTIPLE_TABLES is not set
> # CONFIG_IPV6_MROUTE is not set
> # CONFIG_NETWORK_SECMARK is not set
> # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
> CONFIG_NETFILTER=y
> # CONFIG_NETFILTER_DEBUG is not set
> CONFIG_NETFILTER_ADVANCED=y
> CONFIG_BRIDGE_NETFILTER=y
> 
> #
> # Core Netfilter Configuration
> #
> CONFIG_NETFILTER_NETLINK=y
> # CONFIG_NETFILTER_NETLINK_ACCT is not set
> CONFIG_NETFILTER_NETLINK_QUEUE=y
> CONFIG_NETFILTER_NETLINK_LOG=y
> CONFIG_NF_CONNTRACK=y
> CONFIG_NF_CONNTRACK_MARK=y
> CONFIG_NF_CONNTRACK_ZONES=y
> CONFIG_NF_CONNTRACK_PROCFS=y
> CONFIG_NF_CONNTRACK_EVENTS=y
> # CONFIG_NF_CONNTRACK_TIMEOUT is not set
> # CONFIG_NF_CONNTRACK_TIMESTAMP is not set
> CONFIG_NF_CT_PROTO_DCCP=y
> CONFIG_NF_CT_PROTO_GRE=y
> CONFIG_NF_CT_PROTO_SCTP=y
> CONFIG_NF_CT_PROTO_UDPLITE=y
> CONFIG_NF_CONNTRACK_AMANDA=y
> CONFIG_NF_CONNTRACK_FTP=y
> CONFIG_NF_CONNTRACK_H323=y
> CONFIG_NF_CONNTRACK_IRC=y
> CONFIG_NF_CONNTRACK_BROADCAST=y
> CONFIG_NF_CONNTRACK_NETBIOS_NS=y
> # CONFIG_NF_CONNTRACK_SNMP is not set
> CONFIG_NF_CONNTRACK_PPTP=y
> CONFIG_NF_CONNTRACK_SANE=y
> CONFIG_NF_CONNTRACK_SIP=y
> CONFIG_NF_CONNTRACK_TFTP=y
> CONFIG_NF_CT_NETLINK=y
> # CONFIG_NF_CT_NETLINK_TIMEOUT is not set
> # CONFIG_NETFILTER_NETLINK_QUEUE_CT is not set
> CONFIG_NETFILTER_TPROXY=y
> CONFIG_NETFILTER_XTABLES=y
> 
> #
> # Xtables combined modules
> #
> CONFIG_NETFILTER_XT_MARK=y
> CONFIG_NETFILTER_XT_CONNMARK=y
> 
> #
> # Xtables targets
> #
> # CONFIG_NETFILTER_XT_TARGET_AUDIT is not set
> # CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set
> CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
> CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
> CONFIG_NETFILTER_XT_TARGET_CT=y
> CONFIG_NETFILTER_XT_TARGET_DSCP=y
> CONFIG_NETFILTER_XT_TARGET_HL=y
> # CONFIG_NETFILTER_XT_TARGET_HMARK is not set
> # CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
> CONFIG_NETFILTER_XT_TARGET_LED=y
> # CONFIG_NETFILTER_XT_TARGET_LOG is not set
> CONFIG_NETFILTER_XT_TARGET_MARK=y
> CONFIG_NETFILTER_XT_TARGET_NFLOG=y
> CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
> CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
> CONFIG_NETFILTER_XT_TARGET_RATEEST=y
> CONFIG_NETFILTER_XT_TARGET_TEE=y
> CONFIG_NETFILTER_XT_TARGET_TPROXY=y
> CONFIG_NETFILTER_XT_TARGET_TRACE=y
> CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
> CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y
> 
> #
> # Xtables matches
> #
> # CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
> CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
> CONFIG_NETFILTER_XT_MATCH_COMMENT=y
> CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
> CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
> CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
> CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
> # CONFIG_NETFILTER_XT_MATCH_CPU is not set
> CONFIG_NETFILTER_XT_MATCH_DCCP=y
> # CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
> CONFIG_NETFILTER_XT_MATCH_DSCP=y
> CONFIG_NETFILTER_XT_MATCH_ECN=y
> CONFIG_NETFILTER_XT_MATCH_ESP=y
> CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
> CONFIG_NETFILTER_XT_MATCH_HELPER=y
> CONFIG_NETFILTER_XT_MATCH_HL=y
> CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
> CONFIG_NETFILTER_XT_MATCH_LENGTH=y
> CONFIG_NETFILTER_XT_MATCH_LIMIT=y
> CONFIG_NETFILTER_XT_MATCH_MAC=y
> CONFIG_NETFILTER_XT_MATCH_MARK=y
> CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
> # CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
> CONFIG_NETFILTER_XT_MATCH_OSF=y
> CONFIG_NETFILTER_XT_MATCH_OWNER=y
> CONFIG_NETFILTER_XT_MATCH_POLICY=y
> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
> CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
> CONFIG_NETFILTER_XT_MATCH_QUOTA=y
> CONFIG_NETFILTER_XT_MATCH_RATEEST=y
> CONFIG_NETFILTER_XT_MATCH_REALM=y
> CONFIG_NETFILTER_XT_MATCH_RECENT=y
> CONFIG_NETFILTER_XT_MATCH_SCTP=y
> CONFIG_NETFILTER_XT_MATCH_SOCKET=y
> CONFIG_NETFILTER_XT_MATCH_STATE=y
> CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
> CONFIG_NETFILTER_XT_MATCH_STRING=y
> CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
> CONFIG_NETFILTER_XT_MATCH_TIME=y
> CONFIG_NETFILTER_XT_MATCH_U32=y
> # CONFIG_IP_SET is not set
> # CONFIG_IP_VS is not set
> 
> #
> # IP: Netfilter Configuration
> #
> CONFIG_NF_DEFRAG_IPV4=y
> CONFIG_NF_CONNTRACK_IPV4=y
> CONFIG_NF_CONNTRACK_PROC_COMPAT=y
> # CONFIG_IP_NF_QUEUE is not set
> CONFIG_IP_NF_IPTABLES=y
> CONFIG_IP_NF_MATCH_AH=y
> CONFIG_IP_NF_MATCH_ECN=y
> # CONFIG_IP_NF_MATCH_RPFILTER is not set
> CONFIG_IP_NF_MATCH_TTL=y
> CONFIG_IP_NF_FILTER=y
> CONFIG_IP_NF_TARGET_REJECT=y
> CONFIG_IP_NF_TARGET_ULOG=y
> CONFIG_NF_NAT=y
> CONFIG_NF_NAT_NEEDED=y
> CONFIG_IP_NF_TARGET_MASQUERADE=y
> CONFIG_IP_NF_TARGET_NETMAP=y
> CONFIG_IP_NF_TARGET_REDIRECT=y
> CONFIG_NF_NAT_PROTO_DCCP=y
> CONFIG_NF_NAT_PROTO_GRE=y
> CONFIG_NF_NAT_PROTO_UDPLITE=y
> CONFIG_NF_NAT_PROTO_SCTP=y
> CONFIG_NF_NAT_FTP=y
> CONFIG_NF_NAT_IRC=y
> CONFIG_NF_NAT_TFTP=y
> CONFIG_NF_NAT_AMANDA=y
> CONFIG_NF_NAT_PPTP=y
> CONFIG_NF_NAT_H323=y
> CONFIG_NF_NAT_SIP=y
> CONFIG_IP_NF_MANGLE=y
> CONFIG_IP_NF_TARGET_CLUSTERIP=y
> CONFIG_IP_NF_TARGET_ECN=y
> CONFIG_IP_NF_TARGET_TTL=y
> CONFIG_IP_NF_RAW=y
> CONFIG_IP_NF_ARPTABLES=y
> CONFIG_IP_NF_ARPFILTER=y
> CONFIG_IP_NF_ARP_MANGLE=y
> 
> #
> # IPv6: Netfilter Configuration
> #
> # CONFIG_NF_DEFRAG_IPV6 is not set
> # CONFIG_NF_CONNTRACK_IPV6 is not set
> # CONFIG_IP6_NF_IPTABLES is not set
> CONFIG_BRIDGE_NF_EBTABLES=y
> CONFIG_BRIDGE_EBT_BROUTE=y
> CONFIG_BRIDGE_EBT_T_FILTER=y
> CONFIG_BRIDGE_EBT_T_NAT=y
> CONFIG_BRIDGE_EBT_802_3=y
> CONFIG_BRIDGE_EBT_AMONG=y
> CONFIG_BRIDGE_EBT_ARP=y
> CONFIG_BRIDGE_EBT_IP=y
> # CONFIG_BRIDGE_EBT_IP6 is not set
> CONFIG_BRIDGE_EBT_LIMIT=y
> CONFIG_BRIDGE_EBT_MARK=y
> CONFIG_BRIDGE_EBT_PKTTYPE=y
> CONFIG_BRIDGE_EBT_STP=y
> CONFIG_BRIDGE_EBT_VLAN=y
> CONFIG_BRIDGE_EBT_ARPREPLY=y
> CONFIG_BRIDGE_EBT_DNAT=y
> CONFIG_BRIDGE_EBT_MARK_T=y
> CONFIG_BRIDGE_EBT_REDIRECT=y
> CONFIG_BRIDGE_EBT_SNAT=y
> CONFIG_BRIDGE_EBT_LOG=y
> CONFIG_BRIDGE_EBT_ULOG=y
> CONFIG_BRIDGE_EBT_NFLOG=y
> # CONFIG_IP_DCCP is not set
> # CONFIG_IP_SCTP is not set
> # CONFIG_RDS is not set
> # CONFIG_TIPC is not set
> # CONFIG_ATM is not set
> # CONFIG_L2TP is not set
> CONFIG_STP=y
> CONFIG_BRIDGE=y
> CONFIG_BRIDGE_IGMP_SNOOPING=y
> # CONFIG_NET_DSA is not set
> # CONFIG_VLAN_8021Q is not set
> # CONFIG_DECNET is not set
> CONFIG_LLC=y
> # CONFIG_LLC2 is not set
> # CONFIG_IPX is not set
> # CONFIG_ATALK is not set
> # CONFIG_X25 is not set
> # CONFIG_LAPB is not set
> # CONFIG_WAN_ROUTER is not set
> # CONFIG_PHONET is not set
> # CONFIG_IEEE802154 is not set
> CONFIG_NET_SCHED=y
> 
> #
> # Queueing/Scheduling
> #
> # CONFIG_NET_SCH_CBQ is not set
> # CONFIG_NET_SCH_HTB is not set
> # CONFIG_NET_SCH_HFSC is not set
> # CONFIG_NET_SCH_PRIO is not set
> # CONFIG_NET_SCH_MULTIQ is not set
> # CONFIG_NET_SCH_RED is not set
> # CONFIG_NET_SCH_SFB is not set
> # CONFIG_NET_SCH_SFQ is not set
> # CONFIG_NET_SCH_TEQL is not set
> # CONFIG_NET_SCH_TBF is not set
> # CONFIG_NET_SCH_GRED is not set
> # CONFIG_NET_SCH_DSMARK is not set
> CONFIG_NET_SCH_NETEM=y
> # CONFIG_NET_SCH_DRR is not set
> # CONFIG_NET_SCH_MQPRIO is not set
> # CONFIG_NET_SCH_CHOKE is not set
> # CONFIG_NET_SCH_QFQ is not set
> # CONFIG_NET_SCH_CODEL is not set
> # CONFIG_NET_SCH_FQ_CODEL is not set
> # CONFIG_NET_SCH_PLUG is not set
> 
> #
> # Classification
> #
> # CONFIG_NET_CLS_BASIC is not set
> # CONFIG_NET_CLS_TCINDEX is not set
> # CONFIG_NET_CLS_ROUTE4 is not set
> # CONFIG_NET_CLS_FW is not set
> # CONFIG_NET_CLS_U32 is not set
> # CONFIG_NET_CLS_RSVP is not set
> # CONFIG_NET_CLS_RSVP6 is not set
> # CONFIG_NET_CLS_FLOW is not set
> # CONFIG_NET_CLS_CGROUP is not set
> # CONFIG_NET_EMATCH is not set
> # CONFIG_NET_CLS_ACT is not set
> CONFIG_NET_SCH_FIFO=y
> # CONFIG_DCB is not set
> CONFIG_DNS_RESOLVER=y
> # CONFIG_BATMAN_ADV is not set
> # CONFIG_OPENVSWITCH is not set
> CONFIG_RPS=y
> CONFIG_RFS_ACCEL=y
> CONFIG_XPS=y
> # CONFIG_NETPRIO_CGROUP is not set
> CONFIG_BQL=y
> # CONFIG_BPF_JIT is not set
> 
> #
> # Network testing
> #
> # CONFIG_NET_PKTGEN is not set
> # CONFIG_NET_TCPPROBE is not set
> # CONFIG_NET_DROP_MONITOR is not set
> # CONFIG_HAMRADIO is not set
> # CONFIG_CAN is not set
> # CONFIG_IRDA is not set
> # CONFIG_BT is not set
> # CONFIG_AF_RXRPC is not set
> # CONFIG_WIRELESS is not set
> # CONFIG_WIMAX is not set
> # CONFIG_RFKILL is not set
> # CONFIG_NET_9P is not set
> # CONFIG_CAIF is not set
> # CONFIG_CEPH_LIB is not set
> # CONFIG_NFC is not set
> CONFIG_HAVE_BPF_JIT=y
> 
> #
> # Device Drivers
> #
> 
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
> CONFIG_DEVTMPFS=y
> CONFIG_DEVTMPFS_MOUNT=y
> # CONFIG_STANDALONE is not set
> # CONFIG_PREVENT_FIRMWARE_BUILD is not set
> CONFIG_FW_LOADER=y
> CONFIG_FIRMWARE_IN_KERNEL=y
> CONFIG_EXTRA_FIRMWARE=""
> # CONFIG_DEBUG_DRIVER is not set
> # CONFIG_DEBUG_DEVRES is not set
> # CONFIG_SYS_HYPERVISOR is not set
> # CONFIG_GENERIC_CPU_DEVICES is not set
> CONFIG_DMA_SHARED_BUFFER=y
> CONFIG_CONNECTOR=y
> CONFIG_PROC_EVENTS=y
> # CONFIG_MTD is not set
> # CONFIG_PARPORT is not set
> CONFIG_PNP=y
> CONFIG_PNP_DEBUG_MESSAGES=y
> 
> #
> # Protocols
> #
> CONFIG_PNPACPI=y
> CONFIG_BLK_DEV=y
> CONFIG_BLK_DEV_FD=y
> # CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
> # CONFIG_BLK_CPQ_DA is not set
> # CONFIG_BLK_CPQ_CISS_DA is not set
> # CONFIG_BLK_DEV_DAC960 is not set
> # CONFIG_BLK_DEV_UMEM is not set
> # CONFIG_BLK_DEV_COW_COMMON is not set
> CONFIG_BLK_DEV_LOOP=y
> CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
> CONFIG_BLK_DEV_CRYPTOLOOP=y
> # CONFIG_BLK_DEV_DRBD is not set
> # CONFIG_BLK_DEV_NBD is not set
> # CONFIG_BLK_DEV_NVME is not set
> # CONFIG_BLK_DEV_SX8 is not set
> # CONFIG_BLK_DEV_UB is not set
> CONFIG_BLK_DEV_RAM=y
> CONFIG_BLK_DEV_RAM_COUNT=16
> CONFIG_BLK_DEV_RAM_SIZE=65536
> # CONFIG_BLK_DEV_XIP is not set
> CONFIG_CDROM_PKTCDVD=y
> CONFIG_CDROM_PKTCDVD_BUFFERS=128
> # CONFIG_CDROM_PKTCDVD_WCACHE is not set
> # CONFIG_ATA_OVER_ETH is not set
> CONFIG_VIRTIO_BLK=y
> # CONFIG_BLK_DEV_HD is not set
> # CONFIG_BLK_DEV_RBD is not set
> 
> #
> # Misc devices
> #
> # CONFIG_SENSORS_LIS3LV02D is not set
> # CONFIG_AD525X_DPOT is not set
> # CONFIG_IBM_ASM is not set
> # CONFIG_PHANTOM is not set
> # CONFIG_INTEL_MID_PTI is not set
> # CONFIG_SGI_IOC4 is not set
> # CONFIG_TIFM_CORE is not set
> # CONFIG_ICS932S401 is not set
> # CONFIG_ENCLOSURE_SERVICES is not set
> # CONFIG_HP_ILO is not set
> # CONFIG_APDS9802ALS is not set
> # CONFIG_ISL29003 is not set
> # CONFIG_ISL29020 is not set
> # CONFIG_SENSORS_TSL2550 is not set
> # CONFIG_SENSORS_BH1780 is not set
> # CONFIG_SENSORS_BH1770 is not set
> # CONFIG_SENSORS_APDS990X is not set
> # CONFIG_HMC6352 is not set
> # CONFIG_DS1682 is not set
> # CONFIG_VMWARE_BALLOON is not set
> # CONFIG_BMP085_I2C is not set
> # CONFIG_PCH_PHUB is not set
> # CONFIG_USB_SWITCH_FSA9480 is not set
> # CONFIG_C2PORT is not set
> 
> #
> # EEPROM support
> #
> # CONFIG_EEPROM_AT24 is not set
> # CONFIG_EEPROM_LEGACY is not set
> # CONFIG_EEPROM_MAX6875 is not set
> # CONFIG_EEPROM_93CX6 is not set
> # CONFIG_CB710_CORE is not set
> 
> #
> # Texas Instruments shared transport line discipline
> #
> # CONFIG_SENSORS_LIS3_I2C is not set
> 
> #
> # Altera FPGA firmware download module
> #
> # CONFIG_ALTERA_STAPL is not set
> # CONFIG_INTEL_MEI is not set
> CONFIG_HAVE_IDE=y
> CONFIG_IDE=y
> 
> #
> # Please see Documentation/ide/ide.txt for help/info on IDE drives
> #
> CONFIG_IDE_XFER_MODE=y
> # CONFIG_BLK_DEV_IDE_SATA is not set
> CONFIG_IDE_GD=y
> CONFIG_IDE_GD_ATA=y
> # CONFIG_IDE_GD_ATAPI is not set
> # CONFIG_BLK_DEV_IDECD is not set
> # CONFIG_BLK_DEV_IDETAPE is not set
> # CONFIG_BLK_DEV_IDEACPI is not set
> # CONFIG_IDE_TASK_IOCTL is not set
> CONFIG_IDE_PROC_FS=y
> 
> #
> # IDE chipset support/bugfixes
> #
> CONFIG_IDE_GENERIC=y
> # CONFIG_BLK_DEV_PLATFORM is not set
> # CONFIG_BLK_DEV_CMD640 is not set
> # CONFIG_BLK_DEV_IDEPNP is not set
> CONFIG_BLK_DEV_IDEDMA_SFF=y
> 
> #
> # PCI IDE chipsets support
> #
> CONFIG_BLK_DEV_IDEPCI=y
> CONFIG_IDEPCI_PCIBUS_ORDER=y
> # CONFIG_BLK_DEV_GENERIC is not set
> # CONFIG_BLK_DEV_OPTI621 is not set
> # CONFIG_BLK_DEV_RZ1000 is not set
> CONFIG_BLK_DEV_IDEDMA_PCI=y
> # CONFIG_BLK_DEV_AEC62XX is not set
> # CONFIG_BLK_DEV_ALI15X3 is not set
> # CONFIG_BLK_DEV_AMD74XX is not set
> # CONFIG_BLK_DEV_ATIIXP is not set
> # CONFIG_BLK_DEV_CMD64X is not set
> # CONFIG_BLK_DEV_TRIFLEX is not set
> # CONFIG_BLK_DEV_CS5520 is not set
> # CONFIG_BLK_DEV_CS5530 is not set
> # CONFIG_BLK_DEV_HPT366 is not set
> # CONFIG_BLK_DEV_JMICRON is not set
> # CONFIG_BLK_DEV_SC1200 is not set
> CONFIG_BLK_DEV_PIIX=y
> # CONFIG_BLK_DEV_IT8172 is not set
> # CONFIG_BLK_DEV_IT8213 is not set
> # CONFIG_BLK_DEV_IT821X is not set
> # CONFIG_BLK_DEV_NS87415 is not set
> # CONFIG_BLK_DEV_PDC202XX_OLD is not set
> # CONFIG_BLK_DEV_PDC202XX_NEW is not set
> # CONFIG_BLK_DEV_SVWKS is not set
> # CONFIG_BLK_DEV_SIIMAGE is not set
> # CONFIG_BLK_DEV_SIS5513 is not set
> # CONFIG_BLK_DEV_SLC90E66 is not set
> # CONFIG_BLK_DEV_TRM290 is not set
> # CONFIG_BLK_DEV_VIA82CXXX is not set
> # CONFIG_BLK_DEV_TC86C001 is not set
> CONFIG_BLK_DEV_IDEDMA=y
> 
> #
> # SCSI device support
> #
> CONFIG_SCSI_MOD=y
> CONFIG_RAID_ATTRS=y
> CONFIG_SCSI=y
> CONFIG_SCSI_DMA=y
> # CONFIG_SCSI_TGT is not set
> CONFIG_SCSI_NETLINK=y
> CONFIG_SCSI_PROC_FS=y
> 
> #
> # SCSI support type (disk, tape, CD-ROM)
> #
> CONFIG_BLK_DEV_SD=y
> # CONFIG_CHR_DEV_ST is not set
> # CONFIG_CHR_DEV_OSST is not set
> # CONFIG_BLK_DEV_SR is not set
> # CONFIG_CHR_DEV_SG is not set
> # CONFIG_CHR_DEV_SCH is not set
> # CONFIG_SCSI_MULTI_LUN is not set
> CONFIG_SCSI_CONSTANTS=y
> # CONFIG_SCSI_LOGGING is not set
> CONFIG_SCSI_SCAN_ASYNC=y
> 
> #
> # SCSI Transports
> #
> CONFIG_SCSI_SPI_ATTRS=y
> CONFIG_SCSI_FC_ATTRS=y
> CONFIG_SCSI_ISCSI_ATTRS=y
> CONFIG_SCSI_SAS_ATTRS=y
> CONFIG_SCSI_SAS_LIBSAS=y
> CONFIG_SCSI_SAS_ATA=y
> CONFIG_SCSI_SAS_HOST_SMP=y
> # CONFIG_SCSI_SRP_ATTRS is not set
> CONFIG_SCSI_LOWLEVEL=y
> # CONFIG_ISCSI_TCP is not set
> CONFIG_ISCSI_BOOT_SYSFS=y
> # CONFIG_SCSI_CXGB3_ISCSI is not set
> # CONFIG_SCSI_CXGB4_ISCSI is not set
> # CONFIG_SCSI_BNX2_ISCSI is not set
> # CONFIG_SCSI_BNX2X_FCOE is not set
> # CONFIG_BE2ISCSI is not set
> # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
> # CONFIG_SCSI_HPSA is not set
> # CONFIG_SCSI_3W_9XXX is not set
> # CONFIG_SCSI_3W_SAS is not set
> # CONFIG_SCSI_ACARD is not set
> CONFIG_SCSI_AACRAID=y
> CONFIG_SCSI_AIC7XXX=y
> CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
> CONFIG_AIC7XXX_RESET_DELAY_MS=5000
> # CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
> CONFIG_AIC7XXX_DEBUG_ENABLE=y
> CONFIG_AIC7XXX_DEBUG_MASK=0
> CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
> CONFIG_SCSI_AIC7XXX_OLD=y
> CONFIG_SCSI_AIC79XX=y
> CONFIG_AIC79XX_CMDS_PER_DEVICE=32
> CONFIG_AIC79XX_RESET_DELAY_MS=5000
> # CONFIG_AIC79XX_BUILD_FIRMWARE is not set
> CONFIG_AIC79XX_DEBUG_ENABLE=y
> CONFIG_AIC79XX_DEBUG_MASK=0
> CONFIG_AIC79XX_REG_PRETTY_PRINT=y
> CONFIG_SCSI_AIC94XX=y
> CONFIG_AIC94XX_DEBUG=y
> CONFIG_SCSI_MVSAS=y
> CONFIG_SCSI_MVSAS_DEBUG=y
> # CONFIG_SCSI_MVSAS_TASKLET is not set
> # CONFIG_SCSI_MVUMI is not set
> CONFIG_SCSI_DPT_I2O=y
> CONFIG_SCSI_ADVANSYS=y
> # CONFIG_SCSI_ARCMSR is not set
> CONFIG_MEGARAID_NEWGEN=y
> CONFIG_MEGARAID_MM=y
> CONFIG_MEGARAID_MAILBOX=y
> CONFIG_MEGARAID_LEGACY=y
> CONFIG_MEGARAID_SAS=y
> CONFIG_SCSI_MPT2SAS=y
> CONFIG_SCSI_MPT2SAS_MAX_SGE=128
> # CONFIG_SCSI_MPT2SAS_LOGGING is not set
> # CONFIG_SCSI_UFSHCD is not set
> # CONFIG_SCSI_HPTIOP is not set
> # CONFIG_SCSI_BUSLOGIC is not set
> # CONFIG_VMWARE_PVSCSI is not set
> # CONFIG_LIBFC is not set
> # CONFIG_LIBFCOE is not set
> # CONFIG_FCOE is not set
> # CONFIG_FCOE_FNIC is not set
> # CONFIG_SCSI_DMX3191D is not set
> # CONFIG_SCSI_EATA is not set
> # CONFIG_SCSI_FUTURE_DOMAIN is not set
> CONFIG_SCSI_GDTH=y
> # CONFIG_SCSI_ISCI is not set
> # CONFIG_SCSI_IPS is not set
> # CONFIG_SCSI_INITIO is not set
> # CONFIG_SCSI_INIA100 is not set
> # CONFIG_SCSI_STEX is not set
> # CONFIG_SCSI_SYM53C8XX_2 is not set
> # CONFIG_SCSI_IPR is not set
> CONFIG_SCSI_QLOGIC_1280=y
> CONFIG_SCSI_QLA_FC=y
> CONFIG_SCSI_QLA_ISCSI=y
> # CONFIG_SCSI_LPFC is not set
> # CONFIG_SCSI_DC395x is not set
> # CONFIG_SCSI_DC390T is not set
> # CONFIG_SCSI_DEBUG is not set
> # CONFIG_SCSI_PMCRAID is not set
> # CONFIG_SCSI_PM8001 is not set
> # CONFIG_SCSI_SRP is not set
> # CONFIG_SCSI_BFA_FC is not set
> # CONFIG_SCSI_VIRTIO is not set
> # CONFIG_SCSI_DH is not set
> # CONFIG_SCSI_OSD_INITIATOR is not set
> CONFIG_ATA=y
> # CONFIG_ATA_NONSTANDARD is not set
> CONFIG_ATA_VERBOSE_ERROR=y
> CONFIG_ATA_ACPI=y
> CONFIG_SATA_PMP=y
> 
> #
> # Controllers with non-SFF native interface
> #
> CONFIG_SATA_AHCI=y
> # CONFIG_SATA_AHCI_PLATFORM is not set
> # CONFIG_SATA_INIC162X is not set
> # CONFIG_SATA_ACARD_AHCI is not set
> # CONFIG_SATA_SIL24 is not set
> CONFIG_ATA_SFF=y
> 
> #
> # SFF controllers with custom DMA interface
> #
> # CONFIG_PDC_ADMA is not set
> # CONFIG_SATA_QSTOR is not set
> # CONFIG_SATA_SX4 is not set
> CONFIG_ATA_BMDMA=y
> 
> #
> # SATA SFF controllers with BMDMA
> #
> CONFIG_ATA_PIIX=y
> # CONFIG_SATA_MV is not set
> # CONFIG_SATA_NV is not set
> # CONFIG_SATA_PROMISE is not set
> # CONFIG_SATA_SIL is not set
> # CONFIG_SATA_SIS is not set
> # CONFIG_SATA_SVW is not set
> # CONFIG_SATA_ULI is not set
> # CONFIG_SATA_VIA is not set
> # CONFIG_SATA_VITESSE is not set
> 
> #
> # PATA SFF controllers with BMDMA
> #
> # CONFIG_PATA_ALI is not set
> # CONFIG_PATA_AMD is not set
> # CONFIG_PATA_ARASAN_CF is not set
> # CONFIG_PATA_ARTOP is not set
> # CONFIG_PATA_ATIIXP is not set
> # CONFIG_PATA_ATP867X is not set
> # CONFIG_PATA_CMD64X is not set
> # CONFIG_PATA_CS5520 is not set
> # CONFIG_PATA_CS5530 is not set
> # CONFIG_PATA_CS5536 is not set
> # CONFIG_PATA_CYPRESS is not set
> # CONFIG_PATA_EFAR is not set
> # CONFIG_PATA_HPT366 is not set
> # CONFIG_PATA_HPT37X is not set
> # CONFIG_PATA_HPT3X2N is not set
> # CONFIG_PATA_HPT3X3 is not set
> # CONFIG_PATA_IT8213 is not set
> # CONFIG_PATA_IT821X is not set
> # CONFIG_PATA_JMICRON is not set
> # CONFIG_PATA_MARVELL is not set
> # CONFIG_PATA_NETCELL is not set
> # CONFIG_PATA_NINJA32 is not set
> # CONFIG_PATA_NS87415 is not set
> # CONFIG_PATA_OLDPIIX is not set
> # CONFIG_PATA_OPTIDMA is not set
> # CONFIG_PATA_PDC2027X is not set
> # CONFIG_PATA_PDC_OLD is not set
> # CONFIG_PATA_RADISYS is not set
> # CONFIG_PATA_RDC is not set
> # CONFIG_PATA_SC1200 is not set
> # CONFIG_PATA_SCH is not set
> # CONFIG_PATA_SERVERWORKS is not set
> # CONFIG_PATA_SIL680 is not set
> # CONFIG_PATA_SIS is not set
> # CONFIG_PATA_TOSHIBA is not set
> # CONFIG_PATA_TRIFLEX is not set
> # CONFIG_PATA_VIA is not set
> # CONFIG_PATA_WINBOND is not set
> 
> #
> # PIO-only SFF controllers
> #
> # CONFIG_PATA_CMD640_PCI is not set
> # CONFIG_PATA_MPIIX is not set
> # CONFIG_PATA_NS87410 is not set
> # CONFIG_PATA_OPTI is not set
> CONFIG_PATA_PLATFORM=y
> # CONFIG_PATA_RZ1000 is not set
> 
> #
> # Generic fallback / legacy drivers
> #
> # CONFIG_PATA_ACPI is not set
> CONFIG_ATA_GENERIC=y
> # CONFIG_PATA_LEGACY is not set
> CONFIG_MD=y
> CONFIG_BLK_DEV_MD=y
> CONFIG_MD_AUTODETECT=y
> CONFIG_MD_LINEAR=y
> CONFIG_MD_RAID0=y
> CONFIG_MD_RAID1=y
> CONFIG_MD_RAID10=y
> CONFIG_MD_RAID456=y
> CONFIG_MULTICORE_RAID456=y
> CONFIG_MD_MULTIPATH=y
> CONFIG_MD_FAULTY=y
> CONFIG_BLK_DEV_DM=y
> CONFIG_DM_DEBUG=y
> CONFIG_DM_CRYPT=y
> CONFIG_DM_SNAPSHOT=y
> # CONFIG_DM_THIN_PROVISIONING is not set
> CONFIG_DM_MIRROR=y
> # CONFIG_DM_RAID is not set
> CONFIG_DM_LOG_USERSPACE=y
> CONFIG_DM_ZERO=y
> CONFIG_DM_MULTIPATH=y
> CONFIG_DM_MULTIPATH_QL=y
> CONFIG_DM_MULTIPATH_ST=y
> CONFIG_DM_DELAY=y
> CONFIG_DM_UEVENT=y
> # CONFIG_DM_FLAKEY is not set
> # CONFIG_DM_VERITY is not set
> # CONFIG_TARGET_CORE is not set
> CONFIG_FUSION=y
> CONFIG_FUSION_SPI=y
> CONFIG_FUSION_FC=y
> CONFIG_FUSION_SAS=y
> CONFIG_FUSION_MAX_SGE=128
> CONFIG_FUSION_CTL=y
> CONFIG_FUSION_LOGGING=y
> 
> #
> # IEEE 1394 (FireWire) support
> #
> # CONFIG_FIREWIRE is not set
> # CONFIG_FIREWIRE_NOSY is not set
> # CONFIG_I2O is not set
> # CONFIG_MACINTOSH_DRIVERS is not set
> CONFIG_NETDEVICES=y
> CONFIG_NET_CORE=y
> # CONFIG_BONDING is not set
> CONFIG_DUMMY=y
> # CONFIG_EQUALIZER is not set
> # CONFIG_NET_FC is not set
> CONFIG_MII=y
> # CONFIG_NET_TEAM is not set
> # CONFIG_MACVLAN is not set
> CONFIG_NETCONSOLE=y
> CONFIG_NETCONSOLE_DYNAMIC=y
> CONFIG_NETPOLL=y
> # CONFIG_NETPOLL_TRAP is not set
> CONFIG_NET_POLL_CONTROLLER=y
> CONFIG_TUN=y
> # CONFIG_VETH is not set
> CONFIG_VIRTIO_NET=y
> # CONFIG_ARCNET is not set
> 
> #
> # CAIF transport drivers
> #
> CONFIG_ETHERNET=y
> CONFIG_MDIO=y
> CONFIG_NET_VENDOR_3COM=y
> # CONFIG_VORTEX is not set
> # CONFIG_TYPHOON is not set
> CONFIG_NET_VENDOR_ADAPTEC=y
> # CONFIG_ADAPTEC_STARFIRE is not set
> CONFIG_NET_VENDOR_ALTEON=y
> # CONFIG_ACENIC is not set
> CONFIG_NET_VENDOR_AMD=y
> # CONFIG_AMD8111_ETH is not set
> # CONFIG_PCNET32 is not set
> CONFIG_NET_VENDOR_ATHEROS=y
> # CONFIG_ATL2 is not set
> CONFIG_ATL1=y
> CONFIG_ATL1E=y
> CONFIG_ATL1C=y
> CONFIG_NET_VENDOR_BROADCOM=y
> # CONFIG_B44 is not set
> CONFIG_BNX2=y
> CONFIG_CNIC=y
> CONFIG_TIGON3=y
> # CONFIG_BNX2X is not set
> CONFIG_NET_VENDOR_BROCADE=y
> # CONFIG_BNA is not set
> # CONFIG_NET_CALXEDA_XGMAC is not set
> CONFIG_NET_VENDOR_CHELSIO=y
> # CONFIG_CHELSIO_T1 is not set
> # CONFIG_CHELSIO_T3 is not set
> # CONFIG_CHELSIO_T4 is not set
> # CONFIG_CHELSIO_T4VF is not set
> CONFIG_NET_VENDOR_CISCO=y
> # CONFIG_ENIC is not set
> # CONFIG_DNET is not set
> CONFIG_NET_VENDOR_DEC=y
> # CONFIG_NET_TULIP is not set
> CONFIG_NET_VENDOR_DLINK=y
> # CONFIG_DL2K is not set
> # CONFIG_SUNDANCE is not set
> CONFIG_NET_VENDOR_EMULEX=y
> # CONFIG_BE2NET is not set
> CONFIG_NET_VENDOR_EXAR=y
> # CONFIG_S2IO is not set
> # CONFIG_VXGE is not set
> CONFIG_NET_VENDOR_HP=y
> # CONFIG_HP100 is not set
> CONFIG_NET_VENDOR_INTEL=y
> # CONFIG_E100 is not set
> CONFIG_E1000=y
> CONFIG_E1000E=y
> CONFIG_IGB=y
> CONFIG_IGB_DCA=y
> # CONFIG_IGB_PTP is not set
> CONFIG_IGBVF=y
> CONFIG_IXGB=y
> CONFIG_IXGBE=y
> CONFIG_IXGBE_HWMON=y
> CONFIG_IXGBE_DCA=y
> # CONFIG_IXGBE_PTP is not set
> # CONFIG_IXGBEVF is not set
> CONFIG_NET_VENDOR_I825XX=y
> # CONFIG_ZNET is not set
> CONFIG_IP1000=y
> CONFIG_JME=y
> CONFIG_NET_VENDOR_MARVELL=y
> CONFIG_SKGE=y
> # CONFIG_SKGE_DEBUG is not set
> # CONFIG_SKGE_GENESIS is not set
> CONFIG_SKY2=y
> # CONFIG_SKY2_DEBUG is not set
> CONFIG_NET_VENDOR_MELLANOX=y
> # CONFIG_MLX4_EN is not set
> # CONFIG_MLX4_CORE is not set
> CONFIG_NET_VENDOR_MICREL=y
> # CONFIG_KS8842 is not set
> # CONFIG_KS8851_MLL is not set
> # CONFIG_KSZ884X_PCI is not set
> CONFIG_NET_VENDOR_MYRI=y
> # CONFIG_MYRI10GE is not set
> # CONFIG_FEALNX is not set
> CONFIG_NET_VENDOR_NATSEMI=y
> # CONFIG_NATSEMI is not set
> # CONFIG_NS83820 is not set
> CONFIG_NET_VENDOR_8390=y
> # CONFIG_NE2K_PCI is not set
> CONFIG_NET_VENDOR_NVIDIA=y
> # CONFIG_FORCEDETH is not set
> CONFIG_NET_VENDOR_OKI=y
> # CONFIG_PCH_GBE is not set
> # CONFIG_ETHOC is not set
> CONFIG_NET_PACKET_ENGINE=y
> # CONFIG_HAMACHI is not set
> # CONFIG_YELLOWFIN is not set
> CONFIG_NET_VENDOR_QLOGIC=y
> # CONFIG_QLA3XXX is not set
> # CONFIG_QLCNIC is not set
> # CONFIG_QLGE is not set
> # CONFIG_NETXEN_NIC is not set
> CONFIG_NET_VENDOR_REALTEK=y
> # CONFIG_8139CP is not set
> # CONFIG_8139TOO is not set
> CONFIG_R8169=y
> CONFIG_NET_VENDOR_RDC=y
> # CONFIG_R6040 is not set
> CONFIG_NET_VENDOR_SEEQ=y
> # CONFIG_SEEQ8005 is not set
> CONFIG_NET_VENDOR_SILAN=y
> # CONFIG_SC92031 is not set
> CONFIG_NET_VENDOR_SIS=y
> # CONFIG_SIS900 is not set
> CONFIG_SIS190=y
> # CONFIG_SFC is not set
> CONFIG_NET_VENDOR_SMSC=y
> # CONFIG_EPIC100 is not set
> # CONFIG_SMSC9420 is not set
> CONFIG_NET_VENDOR_STMICRO=y
> # CONFIG_STMMAC_ETH is not set
> CONFIG_NET_VENDOR_SUN=y
> # CONFIG_HAPPYMEAL is not set
> # CONFIG_SUNGEM is not set
> # CONFIG_CASSINI is not set
> # CONFIG_NIU is not set
> CONFIG_NET_VENDOR_TEHUTI=y
> # CONFIG_TEHUTI is not set
> CONFIG_NET_VENDOR_TI=y
> # CONFIG_TLAN is not set
> CONFIG_NET_VENDOR_VIA=y
> # CONFIG_VIA_RHINE is not set
> CONFIG_VIA_VELOCITY=y
> CONFIG_NET_VENDOR_WIZNET=y
> # CONFIG_WIZNET_W5100 is not set
> # CONFIG_WIZNET_W5300 is not set
> # CONFIG_FDDI is not set
> # CONFIG_HIPPI is not set
> # CONFIG_NET_SB1000 is not set
> CONFIG_PHYLIB=y
> 
> #
> # MII PHY device drivers
> #
> # CONFIG_AMD_PHY is not set
> CONFIG_MARVELL_PHY=y
> CONFIG_DAVICOM_PHY=y
> CONFIG_QSEMI_PHY=y
> CONFIG_LXT_PHY=y
> CONFIG_CICADA_PHY=y
> CONFIG_VITESSE_PHY=y
> CONFIG_SMSC_PHY=y
> CONFIG_BROADCOM_PHY=y
> # CONFIG_BCM87XX_PHY is not set
> CONFIG_ICPLUS_PHY=y
> # CONFIG_REALTEK_PHY is not set
> # CONFIG_NATIONAL_PHY is not set
> # CONFIG_STE10XP is not set
> # CONFIG_LSI_ET1011C_PHY is not set
> # CONFIG_MICREL_PHY is not set
> # CONFIG_FIXED_PHY is not set
> # CONFIG_MDIO_BITBANG is not set
> # CONFIG_PPP is not set
> # CONFIG_SLIP is not set
> 
> #
> # USB Network Adapters
> #
> CONFIG_USB_CATC=y
> CONFIG_USB_KAWETH=y
> CONFIG_USB_PEGASUS=y
> CONFIG_USB_RTL8150=y
> CONFIG_USB_USBNET=y
> CONFIG_USB_NET_AX8817X=y
> CONFIG_USB_NET_CDCETHER=y
> CONFIG_USB_NET_CDC_EEM=y
> CONFIG_USB_NET_CDC_NCM=y
> CONFIG_USB_NET_DM9601=y
> CONFIG_USB_NET_SMSC75XX=y
> CONFIG_USB_NET_SMSC95XX=y
> CONFIG_USB_NET_GL620A=y
> CONFIG_USB_NET_NET1080=y
> CONFIG_USB_NET_PLUSB=y
> CONFIG_USB_NET_MCS7830=y
> CONFIG_USB_NET_RNDIS_HOST=y
> CONFIG_USB_NET_CDC_SUBSET=y
> CONFIG_USB_ALI_M5632=y
> CONFIG_USB_AN2720=y
> CONFIG_USB_BELKIN=y
> CONFIG_USB_ARMLINUX=y
> CONFIG_USB_EPSON2888=y
> CONFIG_USB_KC2190=y
> CONFIG_USB_NET_ZAURUS=y
> # CONFIG_USB_NET_CX82310_ETH is not set
> # CONFIG_USB_NET_KALMIA is not set
> # CONFIG_USB_NET_QMI_WWAN is not set
> CONFIG_USB_NET_INT51X1=y
> # CONFIG_USB_IPHETH is not set
> # CONFIG_USB_SIERRA_NET is not set
> # CONFIG_USB_VL600 is not set
> # CONFIG_WLAN is not set
> 
> #
> # Enable WiMAX (Networking options) to see the WiMAX drivers
> #
> # CONFIG_WAN is not set
> # CONFIG_VMXNET3 is not set
> # CONFIG_ISDN is not set
> 
> #
> # Input device support
> #
> CONFIG_INPUT=y
> # CONFIG_INPUT_FF_MEMLESS is not set
> CONFIG_INPUT_POLLDEV=y
> CONFIG_INPUT_SPARSEKMAP=y
> # CONFIG_INPUT_MATRIXKMAP is not set
> 
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=y
> CONFIG_INPUT_MOUSEDEV_PSAUX=y
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
> # CONFIG_INPUT_JOYDEV is not set
> CONFIG_INPUT_EVDEV=y
> # CONFIG_INPUT_EVBUG is not set
> 
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=y
> # CONFIG_KEYBOARD_ADP5588 is not set
> # CONFIG_KEYBOARD_ADP5589 is not set
> CONFIG_KEYBOARD_ATKBD=y
> # CONFIG_KEYBOARD_QT1070 is not set
> # CONFIG_KEYBOARD_QT2160 is not set
> # CONFIG_KEYBOARD_LKKBD is not set
> # CONFIG_KEYBOARD_TCA6416 is not set
> # CONFIG_KEYBOARD_TCA8418 is not set
> # CONFIG_KEYBOARD_LM8323 is not set
> # CONFIG_KEYBOARD_LM8333 is not set
> # CONFIG_KEYBOARD_MAX7359 is not set
> # CONFIG_KEYBOARD_MCS is not set
> # CONFIG_KEYBOARD_MPR121 is not set
> CONFIG_KEYBOARD_NEWTON=y
> # CONFIG_KEYBOARD_OPENCORES is not set
> # CONFIG_KEYBOARD_STOWAWAY is not set
> # CONFIG_KEYBOARD_SUNKBD is not set
> # CONFIG_KEYBOARD_OMAP4 is not set
> CONFIG_KEYBOARD_XTKBD=y
> CONFIG_INPUT_MOUSE=y
> CONFIG_MOUSE_PS2=y
> CONFIG_MOUSE_PS2_ALPS=y
> CONFIG_MOUSE_PS2_LOGIPS2PP=y
> CONFIG_MOUSE_PS2_SYNAPTICS=y
> CONFIG_MOUSE_PS2_LIFEBOOK=y
> CONFIG_MOUSE_PS2_TRACKPOINT=y
> # CONFIG_MOUSE_PS2_ELANTECH is not set
> # CONFIG_MOUSE_PS2_SENTELIC is not set
> # CONFIG_MOUSE_PS2_TOUCHKIT is not set
> # CONFIG_MOUSE_SERIAL is not set
> # CONFIG_MOUSE_APPLETOUCH is not set
> # CONFIG_MOUSE_BCM5974 is not set
> # CONFIG_MOUSE_VSXXXAA is not set
> # CONFIG_MOUSE_SYNAPTICS_I2C is not set
> # CONFIG_MOUSE_SYNAPTICS_USB is not set
> # CONFIG_INPUT_JOYSTICK is not set
> # CONFIG_INPUT_TABLET is not set
> # CONFIG_INPUT_TOUCHSCREEN is not set
> CONFIG_INPUT_MISC=y
> # CONFIG_INPUT_AD714X is not set
> # CONFIG_INPUT_BMA150 is not set
> # CONFIG_INPUT_PCSPKR is not set
> # CONFIG_INPUT_MMA8450 is not set
> # CONFIG_INPUT_MPU3050 is not set
> # CONFIG_INPUT_APANEL is not set
> # CONFIG_INPUT_ATLAS_BTNS is not set
> # CONFIG_INPUT_ATI_REMOTE2 is not set
> # CONFIG_INPUT_KEYSPAN_REMOTE is not set
> # CONFIG_INPUT_KXTJ9 is not set
> # CONFIG_INPUT_POWERMATE is not set
> # CONFIG_INPUT_YEALINK is not set
> # CONFIG_INPUT_CM109 is not set
> CONFIG_INPUT_UINPUT=y
> # CONFIG_INPUT_PCF8574 is not set
> # CONFIG_INPUT_ADXL34X is not set
> # CONFIG_INPUT_CMA3000 is not set
> 
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=y
> CONFIG_SERIO_I8042=y
> # CONFIG_SERIO_SERPORT is not set
> # CONFIG_SERIO_CT82C710 is not set
> # CONFIG_SERIO_PCIPS2 is not set
> CONFIG_SERIO_LIBPS2=y
> # CONFIG_SERIO_RAW is not set
> # CONFIG_SERIO_ALTERA_PS2 is not set
> # CONFIG_SERIO_PS2MULT is not set
> # CONFIG_GAMEPORT is not set
> 
> #
> # Character devices
> #
> CONFIG_VT=y
> CONFIG_CONSOLE_TRANSLATIONS=y
> CONFIG_VT_CONSOLE=y
> CONFIG_VT_CONSOLE_SLEEP=y
> CONFIG_HW_CONSOLE=y
> CONFIG_VT_HW_CONSOLE_BINDING=y
> CONFIG_UNIX98_PTYS=y
> # CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
> CONFIG_LEGACY_PTYS=y
> CONFIG_LEGACY_PTY_COUNT=256
> # CONFIG_SERIAL_NONSTANDARD is not set
> CONFIG_NOZOMI=y
> # CONFIG_N_GSM is not set
> # CONFIG_TRACE_SINK is not set
> CONFIG_DEVKMEM=y
> 
> #
> # Serial drivers
> #
> CONFIG_SERIAL_8250=y
> CONFIG_SERIAL_8250_CONSOLE=y
> CONFIG_FIX_EARLYCON_MEM=y
> CONFIG_SERIAL_8250_PCI=y
> CONFIG_SERIAL_8250_PNP=y
> CONFIG_SERIAL_8250_NR_UARTS=16
> CONFIG_SERIAL_8250_RUNTIME_UARTS=4
> CONFIG_SERIAL_8250_EXTENDED=y
> CONFIG_SERIAL_8250_MANY_PORTS=y
> CONFIG_SERIAL_8250_SHARE_IRQ=y
> # CONFIG_SERIAL_8250_DETECT_IRQ is not set
> CONFIG_SERIAL_8250_RSA=y
> 
> #
> # Non-8250 serial port support
> #
> # CONFIG_SERIAL_MFD_HSU is not set
> CONFIG_SERIAL_CORE=y
> CONFIG_SERIAL_CORE_CONSOLE=y
> # CONFIG_SERIAL_JSM is not set
> # CONFIG_SERIAL_TIMBERDALE is not set
> # CONFIG_SERIAL_ALTERA_JTAGUART is not set
> # CONFIG_SERIAL_ALTERA_UART is not set
> # CONFIG_SERIAL_PCH_UART is not set
> # CONFIG_SERIAL_XILINX_PS_UART is not set
> # CONFIG_TTY_PRINTK is not set
> CONFIG_HVC_DRIVER=y
> CONFIG_VIRTIO_CONSOLE=y
> # CONFIG_IPMI_HANDLER is not set
> CONFIG_HW_RANDOM=y
> # CONFIG_HW_RANDOM_TIMERIOMEM is not set
> CONFIG_HW_RANDOM_INTEL=y
> # CONFIG_HW_RANDOM_AMD is not set
> CONFIG_HW_RANDOM_VIA=y
> CONFIG_HW_RANDOM_VIRTIO=y
> CONFIG_NVRAM=y
> # CONFIG_R3964 is not set
> # CONFIG_APPLICOM is not set
> # CONFIG_MWAVE is not set
> # CONFIG_RAW_DRIVER is not set
> CONFIG_HPET=y
> CONFIG_HPET_MMAP=y
> CONFIG_HANGCHECK_TIMER=y
> # CONFIG_TCG_TPM is not set
> # CONFIG_TELCLOCK is not set
> CONFIG_DEVPORT=y
> CONFIG_I2C=y
> CONFIG_I2C_BOARDINFO=y
> CONFIG_I2C_COMPAT=y
> # CONFIG_I2C_CHARDEV is not set
> # CONFIG_I2C_MUX is not set
> CONFIG_I2C_HELPER_AUTO=y
> CONFIG_I2C_ALGOBIT=y
> 
> #
> # I2C Hardware Bus support
> #
> 
> #
> # PC SMBus host controller drivers
> #
> # CONFIG_I2C_ALI1535 is not set
> # CONFIG_I2C_ALI1563 is not set
> # CONFIG_I2C_ALI15X3 is not set
> # CONFIG_I2C_AMD756 is not set
> # CONFIG_I2C_AMD8111 is not set
> # CONFIG_I2C_I801 is not set
> # CONFIG_I2C_ISCH is not set
> # CONFIG_I2C_PIIX4 is not set
> # CONFIG_I2C_NFORCE2 is not set
> # CONFIG_I2C_SIS5595 is not set
> # CONFIG_I2C_SIS630 is not set
> # CONFIG_I2C_SIS96X is not set
> # CONFIG_I2C_VIA is not set
> # CONFIG_I2C_VIAPRO is not set
> 
> #
> # ACPI drivers
> #
> # CONFIG_I2C_SCMI is not set
> 
> #
> # I2C system bus drivers (mostly embedded / system-on-chip)
> #
> # CONFIG_I2C_DESIGNWARE_PCI is not set
> # CONFIG_I2C_EG20T is not set
> # CONFIG_I2C_INTEL_MID is not set
> # CONFIG_I2C_OCORES is not set
> # CONFIG_I2C_PCA_PLATFORM is not set
> # CONFIG_I2C_PXA_PCI is not set
> # CONFIG_I2C_SIMTEC is not set
> # CONFIG_I2C_XILINX is not set
> 
> #
> # External I2C/SMBus adapter drivers
> #
> # CONFIG_I2C_DIOLAN_U2C is not set
> # CONFIG_I2C_PARPORT_LIGHT is not set
> # CONFIG_I2C_TAOS_EVM is not set
> # CONFIG_I2C_TINY_USB is not set
> 
> #
> # Other I2C/SMBus bus drivers
> #
> # CONFIG_I2C_STUB is not set
> # CONFIG_I2C_DEBUG_CORE is not set
> # CONFIG_I2C_DEBUG_ALGO is not set
> # CONFIG_I2C_DEBUG_BUS is not set
> # CONFIG_SPI is not set
> # CONFIG_HSI is not set
> 
> #
> # PPS support
> #
> # CONFIG_PPS is not set
> 
> #
> # PPS generators support
> #
> 
> #
> # PTP clock support
> #
> 
> #
> # Enable Device Drivers -> PPS to see the PTP clock options.
> #
> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
> # CONFIG_GPIOLIB is not set
> # CONFIG_W1 is not set
> CONFIG_POWER_SUPPLY=y
> # CONFIG_POWER_SUPPLY_DEBUG is not set
> # CONFIG_PDA_POWER is not set
> # CONFIG_TEST_POWER is not set
> # CONFIG_BATTERY_DS2780 is not set
> # CONFIG_BATTERY_DS2781 is not set
> # CONFIG_BATTERY_DS2782 is not set
> # CONFIG_BATTERY_SBS is not set
> # CONFIG_BATTERY_BQ27x00 is not set
> # CONFIG_BATTERY_MAX17040 is not set
> # CONFIG_BATTERY_MAX17042 is not set
> # CONFIG_CHARGER_MAX8903 is not set
> # CONFIG_CHARGER_LP8727 is not set
> # CONFIG_CHARGER_SMB347 is not set
> # CONFIG_POWER_AVS is not set
> CONFIG_HWMON=y
> # CONFIG_HWMON_VID is not set
> # CONFIG_HWMON_DEBUG_CHIP is not set
> 
> #
> # Native drivers
> #
> # CONFIG_SENSORS_ABITUGURU is not set
> # CONFIG_SENSORS_ABITUGURU3 is not set
> # CONFIG_SENSORS_AD7414 is not set
> # CONFIG_SENSORS_AD7418 is not set
> # CONFIG_SENSORS_ADM1021 is not set
> # CONFIG_SENSORS_ADM1025 is not set
> # CONFIG_SENSORS_ADM1026 is not set
> # CONFIG_SENSORS_ADM1029 is not set
> # CONFIG_SENSORS_ADM1031 is not set
> # CONFIG_SENSORS_ADM9240 is not set
> # CONFIG_SENSORS_ADT7411 is not set
> # CONFIG_SENSORS_ADT7462 is not set
> # CONFIG_SENSORS_ADT7470 is not set
> # CONFIG_SENSORS_ADT7475 is not set
> # CONFIG_SENSORS_ASC7621 is not set
> # CONFIG_SENSORS_K8TEMP is not set
> # CONFIG_SENSORS_K10TEMP is not set
> # CONFIG_SENSORS_FAM15H_POWER is not set
> # CONFIG_SENSORS_ASB100 is not set
> # CONFIG_SENSORS_ATXP1 is not set
> # CONFIG_SENSORS_DS620 is not set
> # CONFIG_SENSORS_DS1621 is not set
> # CONFIG_SENSORS_I5K_AMB is not set
> # CONFIG_SENSORS_F71805F is not set
> # CONFIG_SENSORS_F71882FG is not set
> # CONFIG_SENSORS_F75375S is not set
> # CONFIG_SENSORS_FSCHMD is not set
> # CONFIG_SENSORS_G760A is not set
> # CONFIG_SENSORS_GL518SM is not set
> # CONFIG_SENSORS_GL520SM is not set
> # CONFIG_SENSORS_HIH6130 is not set
> # CONFIG_SENSORS_CORETEMP is not set
> # CONFIG_SENSORS_IT87 is not set
> # CONFIG_SENSORS_JC42 is not set
> # CONFIG_SENSORS_LINEAGE is not set
> # CONFIG_SENSORS_LM63 is not set
> # CONFIG_SENSORS_LM73 is not set
> # CONFIG_SENSORS_LM75 is not set
> # CONFIG_SENSORS_LM77 is not set
> # CONFIG_SENSORS_LM78 is not set
> # CONFIG_SENSORS_LM80 is not set
> # CONFIG_SENSORS_LM83 is not set
> # CONFIG_SENSORS_LM85 is not set
> # CONFIG_SENSORS_LM87 is not set
> # CONFIG_SENSORS_LM90 is not set
> # CONFIG_SENSORS_LM92 is not set
> # CONFIG_SENSORS_LM93 is not set
> # CONFIG_SENSORS_LTC4151 is not set
> # CONFIG_SENSORS_LTC4215 is not set
> # CONFIG_SENSORS_LTC4245 is not set
> # CONFIG_SENSORS_LTC4261 is not set
> # CONFIG_SENSORS_LM95241 is not set
> # CONFIG_SENSORS_LM95245 is not set
> # CONFIG_SENSORS_MAX16065 is not set
> # CONFIG_SENSORS_MAX1619 is not set
> # CONFIG_SENSORS_MAX1668 is not set
> # CONFIG_SENSORS_MAX6639 is not set
> # CONFIG_SENSORS_MAX6642 is not set
> # CONFIG_SENSORS_MAX6650 is not set
> # CONFIG_SENSORS_MCP3021 is not set
> # CONFIG_SENSORS_NTC_THERMISTOR is not set
> # CONFIG_SENSORS_PC87360 is not set
> # CONFIG_SENSORS_PC87427 is not set
> # CONFIG_SENSORS_PCF8591 is not set
> # CONFIG_PMBUS is not set
> # CONFIG_SENSORS_SHT21 is not set
> # CONFIG_SENSORS_SIS5595 is not set
> # CONFIG_SENSORS_SMM665 is not set
> # CONFIG_SENSORS_DME1737 is not set
> # CONFIG_SENSORS_EMC1403 is not set
> # CONFIG_SENSORS_EMC2103 is not set
> # CONFIG_SENSORS_EMC6W201 is not set
> # CONFIG_SENSORS_SMSC47M1 is not set
> # CONFIG_SENSORS_SMSC47M192 is not set
> # CONFIG_SENSORS_SMSC47B397 is not set
> # CONFIG_SENSORS_SCH56XX_COMMON is not set
> # CONFIG_SENSORS_SCH5627 is not set
> # CONFIG_SENSORS_SCH5636 is not set
> # CONFIG_SENSORS_ADS1015 is not set
> # CONFIG_SENSORS_ADS7828 is not set
> # CONFIG_SENSORS_AMC6821 is not set
> # CONFIG_SENSORS_INA2XX is not set
> # CONFIG_SENSORS_THMC50 is not set
> # CONFIG_SENSORS_TMP102 is not set
> # CONFIG_SENSORS_TMP401 is not set
> # CONFIG_SENSORS_TMP421 is not set
> # CONFIG_SENSORS_VIA_CPUTEMP is not set
> # CONFIG_SENSORS_VIA686A is not set
> # CONFIG_SENSORS_VT1211 is not set
> # CONFIG_SENSORS_VT8231 is not set
> # CONFIG_SENSORS_W83781D is not set
> # CONFIG_SENSORS_W83791D is not set
> # CONFIG_SENSORS_W83792D is not set
> # CONFIG_SENSORS_W83793 is not set
> # CONFIG_SENSORS_W83795 is not set
> # CONFIG_SENSORS_W83L785TS is not set
> # CONFIG_SENSORS_W83L786NG is not set
> # CONFIG_SENSORS_W83627HF is not set
> # CONFIG_SENSORS_W83627EHF is not set
> # CONFIG_SENSORS_APPLESMC is not set
> 
> #
> # ACPI drivers
> #
> # CONFIG_SENSORS_ACPI_POWER is not set
> # CONFIG_SENSORS_ATK0110 is not set
> CONFIG_THERMAL=y
> CONFIG_THERMAL_HWMON=y
> CONFIG_WATCHDOG=y
> CONFIG_WATCHDOG_CORE=y
> # CONFIG_WATCHDOG_NOWAYOUT is not set
> 
> #
> # Watchdog Device Drivers
> #
> CONFIG_SOFT_WATCHDOG=y
> # CONFIG_ACQUIRE_WDT is not set
> # CONFIG_ADVANTECH_WDT is not set
> # CONFIG_ALIM1535_WDT is not set
> # CONFIG_ALIM7101_WDT is not set
> # CONFIG_F71808E_WDT is not set
> # CONFIG_SP5100_TCO is not set
> # CONFIG_SC520_WDT is not set
> # CONFIG_SBC_FITPC2_WATCHDOG is not set
> # CONFIG_EUROTECH_WDT is not set
> # CONFIG_IB700_WDT is not set
> # CONFIG_IBMASR is not set
> # CONFIG_WAFER_WDT is not set
> CONFIG_I6300ESB_WDT=y
> # CONFIG_IE6XX_WDT is not set
> CONFIG_ITCO_WDT=y
> CONFIG_ITCO_VENDOR_SUPPORT=y
> # CONFIG_IT8712F_WDT is not set
> # CONFIG_IT87_WDT is not set
> # CONFIG_HP_WATCHDOG is not set
> # CONFIG_SC1200_WDT is not set
> # CONFIG_PC87413_WDT is not set
> # CONFIG_NV_TCO is not set
> # CONFIG_60XX_WDT is not set
> # CONFIG_SBC8360_WDT is not set
> # CONFIG_CPU5_WDT is not set
> # CONFIG_SMSC_SCH311X_WDT is not set
> # CONFIG_SMSC37B787_WDT is not set
> # CONFIG_VIA_WDT is not set
> # CONFIG_W83627HF_WDT is not set
> # CONFIG_W83697HF_WDT is not set
> # CONFIG_W83697UG_WDT is not set
> # CONFIG_W83877F_WDT is not set
> # CONFIG_W83977F_WDT is not set
> # CONFIG_MACHZ_WDT is not set
> # CONFIG_SBC_EPX_C3_WATCHDOG is not set
> 
> #
> # PCI-based Watchdog Cards
> #
> # CONFIG_PCIPCWATCHDOG is not set
> # CONFIG_WDTPCI is not set
> 
> #
> # USB-based Watchdog Cards
> #
> # CONFIG_USBPCWATCHDOG is not set
> CONFIG_SSB_POSSIBLE=y
> 
> #
> # Sonics Silicon Backplane
> #
> CONFIG_SSB=y
> CONFIG_SSB_SPROM=y
> CONFIG_SSB_PCIHOST_POSSIBLE=y
> CONFIG_SSB_PCIHOST=y
> # CONFIG_SSB_B43_PCI_BRIDGE is not set
> # CONFIG_SSB_SILENT is not set
> # CONFIG_SSB_DEBUG is not set
> CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
> CONFIG_SSB_DRIVER_PCICORE=y
> CONFIG_BCMA_POSSIBLE=y
> 
> #
> # Broadcom specific AMBA
> #
> # CONFIG_BCMA is not set
> 
> #
> # Multifunction device drivers
> #
> CONFIG_MFD_CORE=y
> # CONFIG_MFD_88PM860X is not set
> # CONFIG_MFD_88PM800 is not set
> # CONFIG_MFD_88PM805 is not set
> # CONFIG_MFD_SM501 is not set
> # CONFIG_HTC_PASIC3 is not set
> # CONFIG_MFD_LM3533 is not set
> # CONFIG_TPS6105X is not set
> # CONFIG_TPS6507X is not set
> # CONFIG_MFD_TPS65217 is not set
> # CONFIG_TWL4030_CORE is not set
> # CONFIG_TWL6040_CORE is not set
> # CONFIG_MFD_STMPE is not set
> # CONFIG_MFD_TC3589X is not set
> # CONFIG_MFD_TMIO is not set
> # CONFIG_PMIC_DA903X is not set
> # CONFIG_MFD_DA9052_I2C is not set
> # CONFIG_PMIC_ADP5520 is not set
> # CONFIG_MFD_MAX77686 is not set
> # CONFIG_MFD_MAX77693 is not set
> # CONFIG_MFD_MAX8925 is not set
> # CONFIG_MFD_MAX8997 is not set
> # CONFIG_MFD_MAX8998 is not set
> # CONFIG_MFD_SEC_CORE is not set
> # CONFIG_MFD_ARIZONA_I2C is not set
> # CONFIG_MFD_WM8400 is not set
> # CONFIG_MFD_WM831X_I2C is not set
> # CONFIG_MFD_WM8350_I2C is not set
> # CONFIG_MFD_WM8994 is not set
> # CONFIG_MFD_PCF50633 is not set
> # CONFIG_MFD_MC13XXX_I2C is not set
> # CONFIG_ABX500_CORE is not set
> # CONFIG_MFD_CS5535 is not set
> # CONFIG_LPC_SCH is not set
> CONFIG_LPC_ICH=y
> # CONFIG_MFD_RDC321X is not set
> # CONFIG_MFD_JANZ_CMODIO is not set
> # CONFIG_MFD_VX855 is not set
> # CONFIG_MFD_WL1273_CORE is not set
> # CONFIG_MFD_TPS65090 is not set
> # CONFIG_MFD_RC5T583 is not set
> # CONFIG_MFD_PALMAS is not set
> # CONFIG_REGULATOR is not set
> # CONFIG_MEDIA_SUPPORT is not set
> 
> #
> # Graphics support
> #
> CONFIG_AGP=y
> CONFIG_AGP_INTEL=y
> # CONFIG_AGP_SIS is not set
> # CONFIG_AGP_VIA is not set
> CONFIG_VGA_ARB=y
> CONFIG_VGA_ARB_MAX_GPUS=16
> # CONFIG_VGA_SWITCHEROO is not set
> CONFIG_DRM=y
> CONFIG_DRM_KMS_HELPER=y
> # CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
> # CONFIG_DRM_TDFX is not set
> # CONFIG_DRM_R128 is not set
> # CONFIG_DRM_RADEON is not set
> # CONFIG_DRM_NOUVEAU is not set
> 
> #
> # I2C encoder or helper chips
> #
> # CONFIG_DRM_I2C_CH7006 is not set
> # CONFIG_DRM_I2C_SIL164 is not set
> # CONFIG_DRM_I810 is not set
> CONFIG_DRM_I915=y
> CONFIG_DRM_I915_KMS=y
> # CONFIG_DRM_MGA is not set
> # CONFIG_DRM_SIS is not set
> # CONFIG_DRM_VIA is not set
> # CONFIG_DRM_SAVAGE is not set
> # CONFIG_DRM_VMWGFX is not set
> # CONFIG_DRM_GMA500 is not set
> # CONFIG_DRM_UDL is not set
> # CONFIG_DRM_AST is not set
> # CONFIG_DRM_MGAG200 is not set
> # CONFIG_DRM_CIRRUS_QEMU is not set
> # CONFIG_STUB_POULSBO is not set
> # CONFIG_VGASTATE is not set
> CONFIG_VIDEO_OUTPUT_CONTROL=y
> CONFIG_FB=y
> # CONFIG_FIRMWARE_EDID is not set
> # CONFIG_FB_DDC is not set
> # CONFIG_FB_BOOT_VESA_SUPPORT is not set
> CONFIG_FB_CFB_FILLRECT=y
> CONFIG_FB_CFB_COPYAREA=y
> CONFIG_FB_CFB_IMAGEBLIT=y
> # CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
> # CONFIG_FB_SYS_FILLRECT is not set
> # CONFIG_FB_SYS_COPYAREA is not set
> # CONFIG_FB_SYS_IMAGEBLIT is not set
> # CONFIG_FB_FOREIGN_ENDIAN is not set
> # CONFIG_FB_SYS_FOPS is not set
> # CONFIG_FB_WMT_GE_ROPS is not set
> # CONFIG_FB_SVGALIB is not set
> # CONFIG_FB_MACMODES is not set
> # CONFIG_FB_BACKLIGHT is not set
> CONFIG_FB_MODE_HELPERS=y
> # CONFIG_FB_TILEBLITTING is not set
> 
> #
> # Frame buffer hardware drivers
> #
> # CONFIG_FB_CIRRUS is not set
> # CONFIG_FB_PM2 is not set
> # CONFIG_FB_CYBER2000 is not set
> # CONFIG_FB_ARC is not set
> # CONFIG_FB_ASILIANT is not set
> # CONFIG_FB_IMSTT is not set
> # CONFIG_FB_VGA16 is not set
> # CONFIG_FB_UVESA is not set
> # CONFIG_FB_VESA is not set
> # CONFIG_FB_EFI is not set
> # CONFIG_FB_N411 is not set
> # CONFIG_FB_HGA is not set
> # CONFIG_FB_S1D13XXX is not set
> # CONFIG_FB_NVIDIA is not set
> # CONFIG_FB_RIVA is not set
> # CONFIG_FB_I740 is not set
> # CONFIG_FB_LE80578 is not set
> # CONFIG_FB_MATROX is not set
> # CONFIG_FB_RADEON is not set
> # CONFIG_FB_ATY128 is not set
> # CONFIG_FB_ATY is not set
> # CONFIG_FB_S3 is not set
> # CONFIG_FB_SAVAGE is not set
> # CONFIG_FB_SIS is not set
> # CONFIG_FB_VIA is not set
> # CONFIG_FB_NEOMAGIC is not set
> # CONFIG_FB_KYRO is not set
> # CONFIG_FB_3DFX is not set
> # CONFIG_FB_VOODOO1 is not set
> # CONFIG_FB_VT8623 is not set
> # CONFIG_FB_TRIDENT is not set
> # CONFIG_FB_ARK is not set
> # CONFIG_FB_PM3 is not set
> # CONFIG_FB_CARMINE is not set
> # CONFIG_FB_GEODE is not set
> # CONFIG_FB_TMIO is not set
> # CONFIG_FB_SMSCUFX is not set
> # CONFIG_FB_UDL is not set
> # CONFIG_FB_VIRTUAL is not set
> # CONFIG_FB_METRONOME is not set
> # CONFIG_FB_MB862XX is not set
> # CONFIG_FB_BROADSHEET is not set
> # CONFIG_FB_AUO_K190X is not set
> # CONFIG_EXYNOS_VIDEO is not set
> CONFIG_BACKLIGHT_LCD_SUPPORT=y
> CONFIG_LCD_CLASS_DEVICE=y
> # CONFIG_LCD_PLATFORM is not set
> CONFIG_BACKLIGHT_CLASS_DEVICE=y
> CONFIG_BACKLIGHT_GENERIC=y
> # CONFIG_BACKLIGHT_PROGEAR is not set
> # CONFIG_BACKLIGHT_APPLE is not set
> # CONFIG_BACKLIGHT_SAHARA is not set
> # CONFIG_BACKLIGHT_ADP8860 is not set
> # CONFIG_BACKLIGHT_ADP8870 is not set
> # CONFIG_BACKLIGHT_LP855X is not set
> 
> #
> # Console display driver support
> #
> CONFIG_VGA_CONSOLE=y
> CONFIG_VGACON_SOFT_SCROLLBACK=y
> CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=1024
> CONFIG_DUMMY_CONSOLE=y
> CONFIG_FRAMEBUFFER_CONSOLE=y
> CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
> # CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
> # CONFIG_FONTS is not set
> CONFIG_FONT_8x8=y
> CONFIG_FONT_8x16=y
> # CONFIG_LOGO is not set
> CONFIG_SOUND=y
> # CONFIG_SOUND_OSS_CORE is not set
> CONFIG_SND=y
> CONFIG_SND_TIMER=y
> CONFIG_SND_PCM=y
> CONFIG_SND_HWDEP=y
> CONFIG_SND_JACK=y
> CONFIG_SND_SEQUENCER=y
> CONFIG_SND_SEQ_DUMMY=y
> # CONFIG_SND_MIXER_OSS is not set
> # CONFIG_SND_PCM_OSS is not set
> # CONFIG_SND_SEQUENCER_OSS is not set
> CONFIG_SND_HRTIMER=y
> CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
> CONFIG_SND_DYNAMIC_MINORS=y
> # CONFIG_SND_SUPPORT_OLD_API is not set
> CONFIG_SND_VERBOSE_PROCFS=y
> CONFIG_SND_VERBOSE_PRINTK=y
> CONFIG_SND_DEBUG=y
> CONFIG_SND_DEBUG_VERBOSE=y
> CONFIG_SND_PCM_XRUN_DEBUG=y
> CONFIG_SND_VMASTER=y
> CONFIG_SND_KCTL_JACK=y
> CONFIG_SND_DMA_SGBUF=y
> # CONFIG_SND_RAWMIDI_SEQ is not set
> # CONFIG_SND_OPL3_LIB_SEQ is not set
> # CONFIG_SND_OPL4_LIB_SEQ is not set
> # CONFIG_SND_SBAWE_SEQ is not set
> # CONFIG_SND_EMU10K1_SEQ is not set
> CONFIG_SND_DRIVERS=y
> CONFIG_SND_PCSP=m
> # CONFIG_SND_DUMMY is not set
> # CONFIG_SND_ALOOP is not set
> # CONFIG_SND_VIRMIDI is not set
> # CONFIG_SND_MTPAV is not set
> # CONFIG_SND_SERIAL_U16550 is not set
> # CONFIG_SND_MPU401 is not set
> CONFIG_SND_PCI=y
> # CONFIG_SND_AD1889 is not set
> # CONFIG_SND_ALS300 is not set
> # CONFIG_SND_ALS4000 is not set
> # CONFIG_SND_ALI5451 is not set
> # CONFIG_SND_ASIHPI is not set
> # CONFIG_SND_ATIIXP is not set
> # CONFIG_SND_ATIIXP_MODEM is not set
> # CONFIG_SND_AU8810 is not set
> # CONFIG_SND_AU8820 is not set
> # CONFIG_SND_AU8830 is not set
> # CONFIG_SND_AW2 is not set
> # CONFIG_SND_AZT3328 is not set
> # CONFIG_SND_BT87X is not set
> # CONFIG_SND_CA0106 is not set
> # CONFIG_SND_CMIPCI is not set
> # CONFIG_SND_OXYGEN is not set
> # CONFIG_SND_CS4281 is not set
> # CONFIG_SND_CS46XX is not set
> # CONFIG_SND_CS5530 is not set
> # CONFIG_SND_CS5535AUDIO is not set
> # CONFIG_SND_CTXFI is not set
> # CONFIG_SND_DARLA20 is not set
> # CONFIG_SND_GINA20 is not set
> # CONFIG_SND_LAYLA20 is not set
> # CONFIG_SND_DARLA24 is not set
> # CONFIG_SND_GINA24 is not set
> # CONFIG_SND_LAYLA24 is not set
> # CONFIG_SND_MONA is not set
> # CONFIG_SND_MIA is not set
> # CONFIG_SND_ECHO3G is not set
> # CONFIG_SND_INDIGO is not set
> # CONFIG_SND_INDIGOIO is not set
> # CONFIG_SND_INDIGODJ is not set
> # CONFIG_SND_INDIGOIOX is not set
> # CONFIG_SND_INDIGODJX is not set
> # CONFIG_SND_EMU10K1 is not set
> # CONFIG_SND_EMU10K1X is not set
> # CONFIG_SND_ENS1370 is not set
> # CONFIG_SND_ENS1371 is not set
> # CONFIG_SND_ES1938 is not set
> # CONFIG_SND_ES1968 is not set
> # CONFIG_SND_FM801 is not set
> CONFIG_SND_HDA_INTEL=y
> CONFIG_SND_HDA_PREALLOC_SIZE=64
> CONFIG_SND_HDA_HWDEP=y
> CONFIG_SND_HDA_RECONFIG=y
> CONFIG_SND_HDA_INPUT_BEEP=y
> CONFIG_SND_HDA_INPUT_BEEP_MODE=1
> CONFIG_SND_HDA_INPUT_JACK=y
> CONFIG_SND_HDA_PATCH_LOADER=y
> CONFIG_SND_HDA_CODEC_REALTEK=y
> CONFIG_SND_HDA_CODEC_ANALOG=y
> CONFIG_SND_HDA_CODEC_SIGMATEL=y
> CONFIG_SND_HDA_CODEC_VIA=y
> CONFIG_SND_HDA_CODEC_HDMI=y
> CONFIG_SND_HDA_CODEC_CIRRUS=y
> CONFIG_SND_HDA_CODEC_CONEXANT=y
> CONFIG_SND_HDA_CODEC_CA0110=y
> CONFIG_SND_HDA_CODEC_CA0132=y
> CONFIG_SND_HDA_CODEC_CMEDIA=y
> CONFIG_SND_HDA_CODEC_SI3054=y
> CONFIG_SND_HDA_GENERIC=y
> CONFIG_SND_HDA_POWER_SAVE=y
> CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
> # CONFIG_SND_HDSP is not set
> # CONFIG_SND_HDSPM is not set
> # CONFIG_SND_ICE1712 is not set
> # CONFIG_SND_ICE1724 is not set
> # CONFIG_SND_INTEL8X0 is not set
> # CONFIG_SND_INTEL8X0M is not set
> # CONFIG_SND_KORG1212 is not set
> # CONFIG_SND_LOLA is not set
> # CONFIG_SND_LX6464ES is not set
> # CONFIG_SND_MAESTRO3 is not set
> # CONFIG_SND_MIXART is not set
> # CONFIG_SND_NM256 is not set
> # CONFIG_SND_PCXHR is not set
> # CONFIG_SND_RIPTIDE is not set
> # CONFIG_SND_RME32 is not set
> # CONFIG_SND_RME96 is not set
> # CONFIG_SND_RME9652 is not set
> # CONFIG_SND_SONICVIBES is not set
> # CONFIG_SND_TRIDENT is not set
> # CONFIG_SND_VIA82XX is not set
> # CONFIG_SND_VIA82XX_MODEM is not set
> # CONFIG_SND_VIRTUOSO is not set
> # CONFIG_SND_VX222 is not set
> # CONFIG_SND_YMFPCI is not set
> # CONFIG_SND_USB is not set
> # CONFIG_SND_SOC is not set
> # CONFIG_SOUND_PRIME is not set
> 
> #
> # HID support
> #
> CONFIG_HID=y
> # CONFIG_HID_BATTERY_STRENGTH is not set
> # CONFIG_HIDRAW is not set
> # CONFIG_UHID is not set
> CONFIG_HID_GENERIC=y
> 
> #
> # Special HID drivers
> #
> # CONFIG_HID_A4TECH is not set
> # CONFIG_HID_ACRUX is not set
> # CONFIG_HID_APPLE is not set
> # CONFIG_HID_AUREAL is not set
> # CONFIG_HID_BELKIN is not set
> # CONFIG_HID_CHERRY is not set
> # CONFIG_HID_CHICONY is not set
> # CONFIG_HID_PRODIKEYS is not set
> # CONFIG_HID_CYPRESS is not set
> # CONFIG_HID_DRAGONRISE is not set
> # CONFIG_HID_EMS_FF is not set
> # CONFIG_HID_EZKEY is not set
> # CONFIG_HID_HOLTEK is not set
> # CONFIG_HID_KEYTOUCH is not set
> # CONFIG_HID_KYE is not set
> # CONFIG_HID_UCLOGIC is not set
> # CONFIG_HID_WALTOP is not set
> # CONFIG_HID_GYRATION is not set
> # CONFIG_HID_TWINHAN is not set
> # CONFIG_HID_KENSINGTON is not set
> # CONFIG_HID_LCPOWER is not set
> # CONFIG_HID_LENOVO_TPKBD is not set
> # CONFIG_HID_LOGITECH is not set
> # CONFIG_HID_MICROSOFT is not set
> # CONFIG_HID_MONTEREY is not set
> # CONFIG_HID_MULTITOUCH is not set
> # CONFIG_HID_NTRIG is not set
> # CONFIG_HID_ORTEK is not set
> # CONFIG_HID_PANTHERLORD is not set
> # CONFIG_HID_PETALYNX is not set
> # CONFIG_HID_PICOLCD is not set
> # CONFIG_HID_PRIMAX is not set
> # CONFIG_HID_ROCCAT is not set
> # CONFIG_HID_SAITEK is not set
> # CONFIG_HID_SAMSUNG is not set
> # CONFIG_HID_SONY is not set
> # CONFIG_HID_SPEEDLINK is not set
> # CONFIG_HID_SUNPLUS is not set
> # CONFIG_HID_GREENASIA is not set
> # CONFIG_HID_SMARTJOYPLUS is not set
> # CONFIG_HID_TIVO is not set
> # CONFIG_HID_TOPSEED is not set
> # CONFIG_HID_THRUSTMASTER is not set
> # CONFIG_HID_ZEROPLUS is not set
> # CONFIG_HID_ZYDACRON is not set
> 
> #
> # USB HID support
> #
> CONFIG_USB_HID=y
> # CONFIG_HID_PID is not set
> CONFIG_USB_HIDDEV=y
> CONFIG_USB_ARCH_HAS_OHCI=y
> CONFIG_USB_ARCH_HAS_EHCI=y
> CONFIG_USB_ARCH_HAS_XHCI=y
> CONFIG_USB_SUPPORT=y
> CONFIG_USB_COMMON=y
> CONFIG_USB_ARCH_HAS_HCD=y
> CONFIG_USB=y
> CONFIG_USB_DEBUG=y
> CONFIG_USB_ANNOUNCE_NEW_DEVICES=y
> 
> #
> # Miscellaneous USB options
> #
> CONFIG_USB_DYNAMIC_MINORS=y
> # CONFIG_USB_SUSPEND is not set
> # CONFIG_USB_OTG_WHITELIST is not set
> # CONFIG_USB_OTG_BLACKLIST_HUB is not set
> # CONFIG_USB_MON is not set
> # CONFIG_USB_WUSB_CBAF is not set
> 
> #
> # USB Host Controller Drivers
> #
> # CONFIG_USB_C67X00_HCD is not set
> # CONFIG_USB_XHCI_HCD is not set
> CONFIG_USB_EHCI_HCD=y
> CONFIG_USB_EHCI_ROOT_HUB_TT=y
> # CONFIG_USB_EHCI_TT_NEWSCHED is not set
> # CONFIG_USB_OXU210HP_HCD is not set
> # CONFIG_USB_ISP116X_HCD is not set
> # CONFIG_USB_ISP1760_HCD is not set
> # CONFIG_USB_ISP1362_HCD is not set
> # CONFIG_USB_OHCI_HCD is not set
> # CONFIG_USB_EHCI_HCD_PLATFORM is not set
> CONFIG_USB_UHCI_HCD=y
> # CONFIG_USB_SL811_HCD is not set
> # CONFIG_USB_R8A66597_HCD is not set
> # CONFIG_USB_HCD_SSB is not set
> # CONFIG_USB_CHIPIDEA is not set
> 
> #
> # USB Device Class drivers
> #
> # CONFIG_USB_ACM is not set
> # CONFIG_USB_PRINTER is not set
> # CONFIG_USB_WDM is not set
> # CONFIG_USB_TMC is not set
> 
> #
> # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
> #
> 
> #
> # also be needed; see USB_STORAGE Help for more info
> #
> CONFIG_USB_STORAGE=y
> # CONFIG_USB_STORAGE_DEBUG is not set
> # CONFIG_USB_STORAGE_REALTEK is not set
> CONFIG_USB_STORAGE_DATAFAB=y
> CONFIG_USB_STORAGE_FREECOM=y
> CONFIG_USB_STORAGE_ISD200=y
> CONFIG_USB_STORAGE_USBAT=y
> CONFIG_USB_STORAGE_SDDR09=y
> CONFIG_USB_STORAGE_SDDR55=y
> CONFIG_USB_STORAGE_JUMPSHOT=y
> CONFIG_USB_STORAGE_ALAUDA=y
> CONFIG_USB_STORAGE_ONETOUCH=y
> CONFIG_USB_STORAGE_KARMA=y
> CONFIG_USB_STORAGE_CYPRESS_ATACB=y
> # CONFIG_USB_STORAGE_ENE_UB6250 is not set
> # CONFIG_USB_UAS is not set
> CONFIG_USB_LIBUSUAL=y
> 
> #
> # USB Imaging devices
> #
> # CONFIG_USB_MDC800 is not set
> # CONFIG_USB_MICROTEK is not set
> 
> #
> # USB port drivers
> #
> CONFIG_USB_SERIAL=y
> CONFIG_USB_SERIAL_CONSOLE=y
> # CONFIG_USB_EZUSB is not set
> CONFIG_USB_SERIAL_GENERIC=y
> # CONFIG_USB_SERIAL_AIRCABLE is not set
> # CONFIG_USB_SERIAL_ARK3116 is not set
> CONFIG_USB_SERIAL_BELKIN=y
> # CONFIG_USB_SERIAL_CH341 is not set
> # CONFIG_USB_SERIAL_WHITEHEAT is not set
> # CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
> # CONFIG_USB_SERIAL_CP210X is not set
> # CONFIG_USB_SERIAL_CYPRESS_M8 is not set
> # CONFIG_USB_SERIAL_EMPEG is not set
> # CONFIG_USB_SERIAL_FTDI_SIO is not set
> # CONFIG_USB_SERIAL_FUNSOFT is not set
> # CONFIG_USB_SERIAL_VISOR is not set
> # CONFIG_USB_SERIAL_IPAQ is not set
> # CONFIG_USB_SERIAL_IR is not set
> # CONFIG_USB_SERIAL_EDGEPORT is not set
> # CONFIG_USB_SERIAL_EDGEPORT_TI is not set
> # CONFIG_USB_SERIAL_F81232 is not set
> # CONFIG_USB_SERIAL_GARMIN is not set
> # CONFIG_USB_SERIAL_IPW is not set
> # CONFIG_USB_SERIAL_IUU is not set
> # CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
> # CONFIG_USB_SERIAL_KEYSPAN is not set
> # CONFIG_USB_SERIAL_KLSI is not set
> # CONFIG_USB_SERIAL_KOBIL_SCT is not set
> CONFIG_USB_SERIAL_MCT_U232=y
> # CONFIG_USB_SERIAL_METRO is not set
> # CONFIG_USB_SERIAL_MOS7720 is not set
> # CONFIG_USB_SERIAL_MOS7840 is not set
> # CONFIG_USB_SERIAL_MOTOROLA is not set
> # CONFIG_USB_SERIAL_NAVMAN is not set
> # CONFIG_USB_SERIAL_PL2303 is not set
> # CONFIG_USB_SERIAL_OTI6858 is not set
> # CONFIG_USB_SERIAL_QCAUX is not set
> # CONFIG_USB_SERIAL_QUALCOMM is not set
> # CONFIG_USB_SERIAL_SPCP8X5 is not set
> # CONFIG_USB_SERIAL_HP4X is not set
> # CONFIG_USB_SERIAL_SAFE is not set
> # CONFIG_USB_SERIAL_SIEMENS_MPI is not set
> # CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
> # CONFIG_USB_SERIAL_SYMBOL is not set
> # CONFIG_USB_SERIAL_TI is not set
> # CONFIG_USB_SERIAL_CYBERJACK is not set
> # CONFIG_USB_SERIAL_XIRCOM is not set
> # CONFIG_USB_SERIAL_OPTION is not set
> # CONFIG_USB_SERIAL_OMNINET is not set
> # CONFIG_USB_SERIAL_OPTICON is not set
> # CONFIG_USB_SERIAL_VIVOPAY_SERIAL is not set
> # CONFIG_USB_SERIAL_ZIO is not set
> # CONFIG_USB_SERIAL_SSU100 is not set
> # CONFIG_USB_SERIAL_QT2 is not set
> # CONFIG_USB_SERIAL_DEBUG is not set
> 
> #
> # USB Miscellaneous drivers
> #
> # CONFIG_USB_EMI62 is not set
> # CONFIG_USB_EMI26 is not set
> # CONFIG_USB_ADUTUX is not set
> # CONFIG_USB_SEVSEG is not set
> # CONFIG_USB_RIO500 is not set
> # CONFIG_USB_LEGOTOWER is not set
> # CONFIG_USB_LCD is not set
> # CONFIG_USB_LED is not set
> # CONFIG_USB_CYPRESS_CY7C63 is not set
> # CONFIG_USB_CYTHERM is not set
> # CONFIG_USB_IDMOUSE is not set
> # CONFIG_USB_FTDI_ELAN is not set
> # CONFIG_USB_APPLEDISPLAY is not set
> # CONFIG_USB_SISUSBVGA is not set
> # CONFIG_USB_LD is not set
> # CONFIG_USB_TRANCEVIBRATOR is not set
> # CONFIG_USB_IOWARRIOR is not set
> CONFIG_USB_TEST=y
> # CONFIG_USB_ISIGHTFW is not set
> # CONFIG_USB_YUREX is not set
> 
> #
> # USB Physical Layer drivers
> #
> # CONFIG_USB_ISP1301 is not set
> # CONFIG_USB_GADGET is not set
> 
> #
> # OTG and related infrastructure
> #
> # CONFIG_NOP_USB_XCEIV is not set
> # CONFIG_UWB is not set
> # CONFIG_MMC is not set
> # CONFIG_MEMSTICK is not set
> CONFIG_NEW_LEDS=y
> CONFIG_LEDS_CLASS=y
> 
> #
> # LED drivers
> #
> # CONFIG_LEDS_LM3530 is not set
> # CONFIG_LEDS_PCA9532 is not set
> # CONFIG_LEDS_LP3944 is not set
> # CONFIG_LEDS_LP5521 is not set
> # CONFIG_LEDS_LP5523 is not set
> # CONFIG_LEDS_CLEVO_MAIL is not set
> # CONFIG_LEDS_PCA955X is not set
> # CONFIG_LEDS_PCA9633 is not set
> # CONFIG_LEDS_BD2802 is not set
> # CONFIG_LEDS_INTEL_SS4200 is not set
> # CONFIG_LEDS_DELL_NETBOOKS is not set
> # CONFIG_LEDS_TCA6507 is not set
> # CONFIG_LEDS_LM3556 is not set
> # CONFIG_LEDS_OT200 is not set
> # CONFIG_LEDS_BLINKM is not set
> CONFIG_LEDS_TRIGGERS=y
> 
> #
> # LED Triggers
> #
> # CONFIG_LEDS_TRIGGER_TIMER is not set
> # CONFIG_LEDS_TRIGGER_ONESHOT is not set
> # CONFIG_LEDS_TRIGGER_IDE_DISK is not set
> # CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
> # CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
> # CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set
> 
> #
> # iptables trigger is under Netfilter config (LED target)
> #
> # CONFIG_LEDS_TRIGGER_TRANSIENT is not set
> # CONFIG_ACCESSIBILITY is not set
> # CONFIG_INFINIBAND is not set
> # CONFIG_EDAC is not set
> CONFIG_RTC_LIB=y
> CONFIG_RTC_CLASS=y
> CONFIG_RTC_HCTOSYS=y
> CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
> # CONFIG_RTC_DEBUG is not set
> 
> #
> # RTC interfaces
> #
> CONFIG_RTC_INTF_SYSFS=y
> CONFIG_RTC_INTF_PROC=y
> CONFIG_RTC_INTF_DEV=y
> # CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
> CONFIG_RTC_DRV_TEST=y
> 
> #
> # I2C RTC drivers
> #
> # CONFIG_RTC_DRV_DS1307 is not set
> # CONFIG_RTC_DRV_DS1374 is not set
> # CONFIG_RTC_DRV_DS1672 is not set
> # CONFIG_RTC_DRV_DS3232 is not set
> # CONFIG_RTC_DRV_MAX6900 is not set
> # CONFIG_RTC_DRV_RS5C372 is not set
> # CONFIG_RTC_DRV_ISL1208 is not set
> # CONFIG_RTC_DRV_ISL12022 is not set
> # CONFIG_RTC_DRV_X1205 is not set
> # CONFIG_RTC_DRV_PCF8563 is not set
> # CONFIG_RTC_DRV_PCF8583 is not set
> # CONFIG_RTC_DRV_M41T80 is not set
> # CONFIG_RTC_DRV_BQ32K is not set
> # CONFIG_RTC_DRV_S35390A is not set
> # CONFIG_RTC_DRV_FM3130 is not set
> # CONFIG_RTC_DRV_RX8581 is not set
> # CONFIG_RTC_DRV_RX8025 is not set
> # CONFIG_RTC_DRV_EM3027 is not set
> # CONFIG_RTC_DRV_RV3029C2 is not set
> 
> #
> # SPI RTC drivers
> #
> 
> #
> # Platform RTC drivers
> #
> CONFIG_RTC_DRV_CMOS=y
> # CONFIG_RTC_DRV_DS1286 is not set
> # CONFIG_RTC_DRV_DS1511 is not set
> # CONFIG_RTC_DRV_DS1553 is not set
> # CONFIG_RTC_DRV_DS1742 is not set
> # CONFIG_RTC_DRV_STK17TA8 is not set
> # CONFIG_RTC_DRV_M48T86 is not set
> # CONFIG_RTC_DRV_M48T35 is not set
> # CONFIG_RTC_DRV_M48T59 is not set
> # CONFIG_RTC_DRV_MSM6242 is not set
> # CONFIG_RTC_DRV_BQ4802 is not set
> # CONFIG_RTC_DRV_RP5C01 is not set
> # CONFIG_RTC_DRV_V3020 is not set
> 
> #
> # on-CPU RTC drivers
> #
> CONFIG_DMADEVICES=y
> # CONFIG_DMADEVICES_DEBUG is not set
> 
> #
> # DMA Devices
> #
> # CONFIG_INTEL_MID_DMAC is not set
> CONFIG_INTEL_IOATDMA=y
> # CONFIG_TIMB_DMA is not set
> # CONFIG_PCH_DMA is not set
> CONFIG_DMA_ENGINE=y
> 
> #
> # DMA Clients
> #
> # CONFIG_NET_DMA is not set
> # CONFIG_ASYNC_TX_DMA is not set
> # CONFIG_DMATEST is not set
> CONFIG_DCA=y
> # CONFIG_AUXDISPLAY is not set
> CONFIG_UIO=y
> # CONFIG_UIO_CIF is not set
> # CONFIG_UIO_PDRV is not set
> # CONFIG_UIO_PDRV_GENIRQ is not set
> # CONFIG_UIO_AEC is not set
> # CONFIG_UIO_SERCOS3 is not set
> # CONFIG_UIO_PCI_GENERIC is not set
> # CONFIG_UIO_NETX is not set
> CONFIG_VIRTIO=y
> CONFIG_VIRTIO_RING=y
> 
> #
> # Virtio drivers
> #
> CONFIG_VIRTIO_PCI=y
> CONFIG_VIRTIO_BALLOON=y
> # CONFIG_VIRTIO_MMIO is not set
> 
> #
> # Microsoft Hyper-V guest support
> #
> # CONFIG_HYPERV is not set
> # CONFIG_STAGING is not set
> CONFIG_X86_PLATFORM_DEVICES=y
> CONFIG_ACER_WMI=y
> # CONFIG_ACERHDF is not set
> # CONFIG_ASUS_LAPTOP is not set
> CONFIG_DELL_WMI=y
> # CONFIG_DELL_WMI_AIO is not set
> # CONFIG_FUJITSU_LAPTOP is not set
> # CONFIG_FUJITSU_TABLET is not set
> # CONFIG_HP_ACCEL is not set
> CONFIG_HP_WMI=y
> # CONFIG_PANASONIC_LAPTOP is not set
> CONFIG_THINKPAD_ACPI=y
> CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
> # CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
> # CONFIG_THINKPAD_ACPI_DEBUG is not set
> # CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
> CONFIG_THINKPAD_ACPI_VIDEO=y
> CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
> # CONFIG_SENSORS_HDAPS is not set
> # CONFIG_INTEL_MENLOW is not set
> CONFIG_EEEPC_LAPTOP=y
> # CONFIG_ASUS_WMI is not set
> CONFIG_ACPI_WMI=y
> # CONFIG_MSI_WMI is not set
> # CONFIG_TOPSTAR_LAPTOP is not set
> # CONFIG_ACPI_TOSHIBA is not set
> # CONFIG_TOSHIBA_BT_RFKILL is not set
> # CONFIG_ACPI_CMPC is not set
> # CONFIG_INTEL_IPS is not set
> # CONFIG_IBM_RTL is not set
> # CONFIG_XO15_EBOOK is not set
> # CONFIG_SAMSUNG_LAPTOP is not set
> # CONFIG_MXM_WMI is not set
> # CONFIG_SAMSUNG_Q10 is not set
> # CONFIG_APPLE_GMUX is not set
> 
> #
> # Hardware Spinlock drivers
> #
> CONFIG_CLKEVT_I8253=y
> CONFIG_I8253_LOCK=y
> CONFIG_CLKBLD_I8253=y
> CONFIG_IOMMU_SUPPORT=y
> # CONFIG_AMD_IOMMU is not set
> # CONFIG_INTEL_IOMMU is not set
> # CONFIG_IRQ_REMAP is not set
> 
> #
> # Remoteproc drivers (EXPERIMENTAL)
> #
> 
> #
> # Rpmsg drivers (EXPERIMENTAL)
> #
> # CONFIG_VIRT_DRIVERS is not set
> # CONFIG_PM_DEVFREQ is not set
> # CONFIG_EXTCON is not set
> # CONFIG_MEMORY is not set
> # CONFIG_IIO is not set
> # CONFIG_VME_BUS is not set
> # CONFIG_PWM is not set
> 
> #
> # Firmware Drivers
> #
> # CONFIG_EDD is not set
> CONFIG_FIRMWARE_MEMMAP=y
> # CONFIG_EFI_VARS is not set
> # CONFIG_DELL_RBU is not set
> # CONFIG_DCDBAS is not set
> CONFIG_DMIID=y
> # CONFIG_DMI_SYSFS is not set
> # CONFIG_ISCSI_IBFT_FIND is not set
> # CONFIG_GOOGLE_FIRMWARE is not set
> 
> #
> # File systems
> #
> CONFIG_DCACHE_WORD_ACCESS=y
> # CONFIG_EXT2_FS is not set
> CONFIG_EXT3_FS=y
> # CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
> CONFIG_EXT3_FS_XATTR=y
> CONFIG_EXT3_FS_POSIX_ACL=y
> CONFIG_EXT3_FS_SECURITY=y
> CONFIG_EXT4_FS=y
> CONFIG_EXT4_USE_FOR_EXT23=y
> CONFIG_EXT4_FS_XATTR=y
> # CONFIG_EXT4_FS_POSIX_ACL is not set
> # CONFIG_EXT4_FS_SECURITY is not set
> # CONFIG_EXT4_DEBUG is not set
> CONFIG_JBD=y
> # CONFIG_JBD_DEBUG is not set
> CONFIG_JBD2=y
> # CONFIG_JBD2_DEBUG is not set
> CONFIG_FS_MBCACHE=y
> CONFIG_REISERFS_FS=y
> # CONFIG_REISERFS_CHECK is not set
> CONFIG_REISERFS_PROC_INFO=y
> # CONFIG_REISERFS_FS_XATTR is not set
> CONFIG_JFS_FS=y
> # CONFIG_JFS_POSIX_ACL is not set
> # CONFIG_JFS_SECURITY is not set
> # CONFIG_JFS_DEBUG is not set
> # CONFIG_JFS_STATISTICS is not set
> CONFIG_XFS_FS=y
> # CONFIG_XFS_QUOTA is not set
> CONFIG_XFS_POSIX_ACL=y
> # CONFIG_XFS_RT is not set
> # CONFIG_XFS_DEBUG is not set
> # CONFIG_GFS2_FS is not set
> # CONFIG_OCFS2_FS is not set
> CONFIG_BTRFS_FS=y
> # CONFIG_BTRFS_FS_POSIX_ACL is not set
> # CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
> CONFIG_NILFS2_FS=y
> CONFIG_FS_POSIX_ACL=y
> CONFIG_EXPORTFS=y
> CONFIG_FILE_LOCKING=y
> CONFIG_FSNOTIFY=y
> CONFIG_DNOTIFY=y
> CONFIG_INOTIFY_USER=y
> # CONFIG_FANOTIFY is not set
> # CONFIG_QUOTA is not set
> # CONFIG_QUOTACTL is not set
> # CONFIG_AUTOFS4_FS is not set
> CONFIG_FUSE_FS=y
> # CONFIG_CUSE is not set
> 
> #
> # Caches
> #
> # CONFIG_FSCACHE is not set
> 
> #
> # CD-ROM/DVD Filesystems
> #
> CONFIG_ISO9660_FS=y
> # CONFIG_JOLIET is not set
> # CONFIG_ZISOFS is not set
> # CONFIG_UDF_FS is not set
> 
> #
> # DOS/FAT/NT Filesystems
> #
> CONFIG_FAT_FS=y
> # CONFIG_MSDOS_FS is not set
> CONFIG_VFAT_FS=y
> CONFIG_FAT_DEFAULT_CODEPAGE=437
> CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
> # CONFIG_NTFS_FS is not set
> 
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=y
> CONFIG_PROC_KCORE=y
> CONFIG_PROC_VMCORE=y
> CONFIG_PROC_SYSCTL=y
> CONFIG_PROC_PAGE_MONITOR=y
> CONFIG_SYSFS=y
> CONFIG_TMPFS=y
> # CONFIG_TMPFS_POSIX_ACL is not set
> # CONFIG_TMPFS_XATTR is not set
> CONFIG_HUGETLBFS=y
> CONFIG_HUGETLB_PAGE=y
> CONFIG_CONFIGFS_FS=y
> CONFIG_MISC_FILESYSTEMS=y
> # CONFIG_ADFS_FS is not set
> # CONFIG_AFFS_FS is not set
> # CONFIG_ECRYPT_FS is not set
> # CONFIG_HFS_FS is not set
> # CONFIG_HFSPLUS_FS is not set
> # CONFIG_BEFS_FS is not set
> # CONFIG_BFS_FS is not set
> # CONFIG_EFS_FS is not set
> # CONFIG_LOGFS is not set
> CONFIG_CRAMFS=y
> # CONFIG_SQUASHFS is not set
> # CONFIG_VXFS_FS is not set
> # CONFIG_MINIX_FS is not set
> # CONFIG_OMFS_FS is not set
> # CONFIG_HPFS_FS is not set
> # CONFIG_QNX4FS_FS is not set
> # CONFIG_QNX6FS_FS is not set
> # CONFIG_ROMFS_FS is not set
> # CONFIG_PSTORE is not set
> # CONFIG_SYSV_FS is not set
> # CONFIG_UFS_FS is not set
> CONFIG_NETWORK_FILESYSTEMS=y
> CONFIG_NFS_FS=y
> CONFIG_NFS_V2=y
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=y
> # CONFIG_NFS_SWAP is not set
> # CONFIG_NFS_V4_1 is not set
> CONFIG_ROOT_NFS=y
> # CONFIG_NFS_USE_LEGACY_DNS is not set
> CONFIG_NFS_USE_KERNEL_DNS=y
> CONFIG_NFSD=y
> CONFIG_NFSD_V3=y
> # CONFIG_NFSD_V3_ACL is not set
> CONFIG_NFSD_V4=y
> # CONFIG_NFSD_FAULT_INJECTION is not set
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_ACL_SUPPORT=y
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=y
> CONFIG_SUNRPC_GSS=y
> # CONFIG_SUNRPC_DEBUG is not set
> # CONFIG_CEPH_FS is not set
> CONFIG_CIFS=y
> CONFIG_CIFS_STATS=y
> CONFIG_CIFS_STATS2=y
> # CONFIG_CIFS_WEAK_PW_HASH is not set
> # CONFIG_CIFS_UPCALL is not set
> CONFIG_CIFS_XATTR=y
> CONFIG_CIFS_POSIX=y
> CONFIG_CIFS_DEBUG2=y
> # CONFIG_CIFS_DFS_UPCALL is not set
> # CONFIG_CIFS_ACL is not set
> # CONFIG_NCP_FS is not set
> # CONFIG_CODA_FS is not set
> # CONFIG_AFS_FS is not set
> CONFIG_NLS=y
> CONFIG_NLS_DEFAULT="iso8859-1"
> CONFIG_NLS_CODEPAGE_437=y
> # CONFIG_NLS_CODEPAGE_737 is not set
> # CONFIG_NLS_CODEPAGE_775 is not set
> # CONFIG_NLS_CODEPAGE_850 is not set
> # CONFIG_NLS_CODEPAGE_852 is not set
> # CONFIG_NLS_CODEPAGE_855 is not set
> # CONFIG_NLS_CODEPAGE_857 is not set
> # CONFIG_NLS_CODEPAGE_860 is not set
> # CONFIG_NLS_CODEPAGE_861 is not set
> # CONFIG_NLS_CODEPAGE_862 is not set
> # CONFIG_NLS_CODEPAGE_863 is not set
> # CONFIG_NLS_CODEPAGE_864 is not set
> # CONFIG_NLS_CODEPAGE_865 is not set
> # CONFIG_NLS_CODEPAGE_866 is not set
> # CONFIG_NLS_CODEPAGE_869 is not set
> CONFIG_NLS_CODEPAGE_936=y
> # CONFIG_NLS_CODEPAGE_950 is not set
> # CONFIG_NLS_CODEPAGE_932 is not set
> # CONFIG_NLS_CODEPAGE_949 is not set
> # CONFIG_NLS_CODEPAGE_874 is not set
> # CONFIG_NLS_ISO8859_8 is not set
> # CONFIG_NLS_CODEPAGE_1250 is not set
> # CONFIG_NLS_CODEPAGE_1251 is not set
> # CONFIG_NLS_ASCII is not set
> CONFIG_NLS_ISO8859_1=y
> # CONFIG_NLS_ISO8859_2 is not set
> # CONFIG_NLS_ISO8859_3 is not set
> # CONFIG_NLS_ISO8859_4 is not set
> # CONFIG_NLS_ISO8859_5 is not set
> # CONFIG_NLS_ISO8859_6 is not set
> # CONFIG_NLS_ISO8859_7 is not set
> # CONFIG_NLS_ISO8859_9 is not set
> # CONFIG_NLS_ISO8859_13 is not set
> # CONFIG_NLS_ISO8859_14 is not set
> # CONFIG_NLS_ISO8859_15 is not set
> # CONFIG_NLS_KOI8_R is not set
> # CONFIG_NLS_KOI8_U is not set
> # CONFIG_NLS_MAC_ROMAN is not set
> # CONFIG_NLS_MAC_CELTIC is not set
> # CONFIG_NLS_MAC_CENTEURO is not set
> # CONFIG_NLS_MAC_CROATIAN is not set
> # CONFIG_NLS_MAC_CYRILLIC is not set
> # CONFIG_NLS_MAC_GAELIC is not set
> # CONFIG_NLS_MAC_GREEK is not set
> # CONFIG_NLS_MAC_ICELAND is not set
> # CONFIG_NLS_MAC_INUIT is not set
> # CONFIG_NLS_MAC_ROMANIAN is not set
> # CONFIG_NLS_MAC_TURKISH is not set
> CONFIG_NLS_UTF8=y
> # CONFIG_DLM is not set
> 
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=y
> CONFIG_PRINTK_TIME=y
> CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
> CONFIG_ENABLE_WARN_DEPRECATED=y
> CONFIG_ENABLE_MUST_CHECK=y
> CONFIG_FRAME_WARN=2048
> CONFIG_MAGIC_SYSRQ=y
> # CONFIG_STRIP_ASM_SYMS is not set
> # CONFIG_READABLE_ASM is not set
> # CONFIG_UNUSED_SYMBOLS is not set
> CONFIG_DEBUG_FS=y
> # CONFIG_HEADERS_CHECK is not set
> # CONFIG_DEBUG_SECTION_MISMATCH is not set
> CONFIG_DEBUG_KERNEL=y
> CONFIG_DEBUG_SHIRQ=y
> # CONFIG_LOCKUP_DETECTOR is not set
> # CONFIG_HARDLOCKUP_DETECTOR is not set
> # CONFIG_PANIC_ON_OOPS is not set
> CONFIG_PANIC_ON_OOPS_VALUE=0
> CONFIG_DETECT_HUNG_TASK=y
> CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
> CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
> CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
> CONFIG_SCHED_DEBUG=y
> CONFIG_SCHEDSTATS=y
> CONFIG_TIMER_STATS=y
> CONFIG_DEBUG_OBJECTS=y
> # CONFIG_DEBUG_OBJECTS_SELFTEST is not set
> # CONFIG_DEBUG_OBJECTS_FREE is not set
> # CONFIG_DEBUG_OBJECTS_TIMERS is not set
> # CONFIG_DEBUG_OBJECTS_WORK is not set
> # CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
> # CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
> CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
> CONFIG_SLUB_DEBUG_ON=y
> CONFIG_SLUB_STATS=y
> # CONFIG_DEBUG_KMEMLEAK is not set
> CONFIG_DEBUG_RT_MUTEXES=y
> CONFIG_DEBUG_PI_LIST=y
> CONFIG_RT_MUTEX_TESTER=y
> CONFIG_DEBUG_SPINLOCK=y
> CONFIG_DEBUG_MUTEXES=y
> CONFIG_DEBUG_LOCK_ALLOC=y
> CONFIG_PROVE_LOCKING=y
> # CONFIG_PROVE_RCU is not set
> # CONFIG_SPARSE_RCU_POINTER is not set
> CONFIG_LOCKDEP=y
> CONFIG_LOCK_STAT=y
> # CONFIG_DEBUG_LOCKDEP is not set
> CONFIG_TRACE_IRQFLAGS=y
> # CONFIG_DEBUG_ATOMIC_SLEEP is not set
> CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
> CONFIG_STACKTRACE=y
> CONFIG_DEBUG_STACK_USAGE=y
> # CONFIG_DEBUG_KOBJECT is not set
> CONFIG_DEBUG_BUGVERBOSE=y
> # CONFIG_DEBUG_INFO is not set
> CONFIG_DEBUG_VM=y
> CONFIG_DEBUG_VIRTUAL=y
> CONFIG_DEBUG_WRITECOUNT=y
> CONFIG_DEBUG_MEMORY_INIT=y
> CONFIG_DEBUG_LIST=y
> # CONFIG_TEST_LIST_SORT is not set
> CONFIG_DEBUG_SG=y
> CONFIG_DEBUG_NOTIFIERS=y
> CONFIG_DEBUG_CREDENTIALS=y
> CONFIG_ARCH_WANT_FRAME_POINTERS=y
> CONFIG_FRAME_POINTER=y
> CONFIG_BOOT_PRINTK_DELAY=y
> CONFIG_RCU_TORTURE_TEST=y
> # CONFIG_RCU_TORTURE_TEST_RUNNABLE is not set
> CONFIG_RCU_CPU_STALL_TIMEOUT=60
> # CONFIG_RCU_CPU_STALL_INFO is not set
> CONFIG_RCU_TRACE=y
> CONFIG_KPROBES_SANITY_TEST=y
> # CONFIG_BACKTRACE_SELF_TEST is not set
> CONFIG_DEBUG_BLOCK_EXT_DEVT=y
> CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
> CONFIG_DEBUG_PER_CPU_MAPS=y
> CONFIG_LKDTM=y
> # CONFIG_NOTIFIER_ERROR_INJECTION is not set
> CONFIG_FAULT_INJECTION=y
> # CONFIG_FAILSLAB is not set
> CONFIG_FAIL_PAGE_ALLOC=y
> CONFIG_FAIL_MAKE_REQUEST=y
> # CONFIG_FAIL_IO_TIMEOUT is not set
> CONFIG_FAULT_INJECTION_DEBUG_FS=y
> CONFIG_LATENCYTOP=y
> CONFIG_DEBUG_PAGEALLOC=y
> CONFIG_WANT_PAGE_DEBUG_FLAGS=y
> CONFIG_PAGE_GUARD=y
> CONFIG_USER_STACKTRACE_SUPPORT=y
> CONFIG_NOP_TRACER=y
> CONFIG_HAVE_FUNCTION_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
> CONFIG_HAVE_DYNAMIC_FTRACE=y
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
> CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
> CONFIG_HAVE_C_RECORDMCOUNT=y
> CONFIG_TRACER_MAX_TRACE=y
> CONFIG_RING_BUFFER=y
> CONFIG_EVENT_TRACING=y
> CONFIG_EVENT_POWER_TRACING_DEPRECATED=y
> CONFIG_CONTEXT_SWITCH_TRACER=y
> CONFIG_RING_BUFFER_ALLOW_SWAP=y
> CONFIG_TRACING=y
> CONFIG_GENERIC_TRACER=y
> CONFIG_TRACING_SUPPORT=y
> CONFIG_FTRACE=y
> CONFIG_FUNCTION_TRACER=y
> CONFIG_FUNCTION_GRAPH_TRACER=y
> CONFIG_IRQSOFF_TRACER=y
> CONFIG_SCHED_TRACER=y
> CONFIG_FTRACE_SYSCALLS=y
> CONFIG_BRANCH_PROFILE_NONE=y
> # CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
> # CONFIG_PROFILE_ALL_BRANCHES is not set
> # CONFIG_STACK_TRACER is not set
> CONFIG_BLK_DEV_IO_TRACE=y
> CONFIG_KPROBE_EVENT=y
> # CONFIG_UPROBE_EVENT is not set
> CONFIG_PROBE_EVENTS=y
> CONFIG_DYNAMIC_FTRACE=y
> CONFIG_FUNCTION_PROFILER=y
> CONFIG_FTRACE_MCOUNT_RECORD=y
> # CONFIG_FTRACE_STARTUP_TEST is not set
> CONFIG_MMIOTRACE=y
> CONFIG_MMIOTRACE_TEST=m
> # CONFIG_RING_BUFFER_BENCHMARK is not set
> # CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
> # CONFIG_DYNAMIC_DEBUG is not set
> CONFIG_DMA_API_DEBUG=y
> CONFIG_ATOMIC64_SELFTEST=y
> # CONFIG_ASYNC_RAID6_TEST is not set
> # CONFIG_SAMPLES is not set
> CONFIG_HAVE_ARCH_KGDB=y
> # CONFIG_KGDB is not set
> CONFIG_HAVE_ARCH_KMEMCHECK=y
> # CONFIG_TEST_KSTRTOX is not set
> # CONFIG_STRICT_DEVMEM is not set
> CONFIG_X86_VERBOSE_BOOTUP=y
> CONFIG_EARLY_PRINTK=y
> # CONFIG_EARLY_PRINTK_DBGP is not set
> CONFIG_DEBUG_STACKOVERFLOW=y
> CONFIG_X86_PTDUMP=y
> # CONFIG_DEBUG_RODATA is not set
> # CONFIG_DEBUG_SET_MODULE_RONX is not set
> CONFIG_DEBUG_NX_TEST=m
> # CONFIG_DEBUG_TLBFLUSH is not set
> # CONFIG_IOMMU_STRESS is not set
> CONFIG_HAVE_MMIOTRACE_SUPPORT=y
> # CONFIG_X86_DECODER_SELFTEST is not set
> CONFIG_IO_DELAY_TYPE_0X80=0
> CONFIG_IO_DELAY_TYPE_0XED=1
> CONFIG_IO_DELAY_TYPE_UDELAY=2
> CONFIG_IO_DELAY_TYPE_NONE=3
> CONFIG_IO_DELAY_0X80=y
> # CONFIG_IO_DELAY_0XED is not set
> # CONFIG_IO_DELAY_UDELAY is not set
> # CONFIG_IO_DELAY_NONE is not set
> CONFIG_DEFAULT_IO_DELAY_TYPE=0
> # CONFIG_DEBUG_BOOT_PARAMS is not set
> # CONFIG_CPA_DEBUG is not set
> # CONFIG_OPTIMIZE_INLINING is not set
> # CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
> # CONFIG_DEBUG_NMI_SELFTEST is not set
> 
> #
> # Security options
> #
> CONFIG_KEYS=y
> # CONFIG_ENCRYPTED_KEYS is not set
> # CONFIG_KEYS_DEBUG_PROC_KEYS is not set
> # CONFIG_SECURITY_DMESG_RESTRICT is not set
> # CONFIG_SECURITY is not set
> # CONFIG_SECURITYFS is not set
> CONFIG_DEFAULT_SECURITY_DAC=y
> CONFIG_DEFAULT_SECURITY=""
> CONFIG_XOR_BLOCKS=y
> CONFIG_ASYNC_CORE=y
> CONFIG_ASYNC_MEMCPY=y
> CONFIG_ASYNC_XOR=y
> CONFIG_ASYNC_PQ=y
> CONFIG_ASYNC_RAID6_RECOV=y
> CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
> CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
> CONFIG_CRYPTO=y
> 
> #
> # Crypto core or helper
> #
> CONFIG_CRYPTO_ALGAPI=y
> CONFIG_CRYPTO_ALGAPI2=y
> CONFIG_CRYPTO_AEAD=y
> CONFIG_CRYPTO_AEAD2=y
> CONFIG_CRYPTO_BLKCIPHER=y
> CONFIG_CRYPTO_BLKCIPHER2=y
> CONFIG_CRYPTO_HASH=y
> CONFIG_CRYPTO_HASH2=y
> CONFIG_CRYPTO_RNG2=y
> CONFIG_CRYPTO_PCOMP2=y
> CONFIG_CRYPTO_MANAGER=y
> CONFIG_CRYPTO_MANAGER2=y
> # CONFIG_CRYPTO_USER is not set
> CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
> CONFIG_CRYPTO_GF128MUL=y
> CONFIG_CRYPTO_NULL=y
> # CONFIG_CRYPTO_PCRYPT is not set
> CONFIG_CRYPTO_WORKQUEUE=y
> # CONFIG_CRYPTO_CRYPTD is not set
> CONFIG_CRYPTO_AUTHENC=y
> # CONFIG_CRYPTO_TEST is not set
> 
> #
> # Authenticated Encryption with Associated Data
> #
> # CONFIG_CRYPTO_CCM is not set
> # CONFIG_CRYPTO_GCM is not set
> # CONFIG_CRYPTO_SEQIV is not set
> 
> #
> # Block modes
> #
> CONFIG_CRYPTO_CBC=y
> # CONFIG_CRYPTO_CTR is not set
> # CONFIG_CRYPTO_CTS is not set
> CONFIG_CRYPTO_ECB=y
> # CONFIG_CRYPTO_LRW is not set
> # CONFIG_CRYPTO_PCBC is not set
> CONFIG_CRYPTO_XTS=y
> 
> #
> # Hash modes
> #
> CONFIG_CRYPTO_HMAC=y
> # CONFIG_CRYPTO_XCBC is not set
> # CONFIG_CRYPTO_VMAC is not set
> 
> #
> # Digest
> #
> CONFIG_CRYPTO_CRC32C=y
> # CONFIG_CRYPTO_CRC32C_INTEL is not set
> # CONFIG_CRYPTO_GHASH is not set
> CONFIG_CRYPTO_MD4=y
> CONFIG_CRYPTO_MD5=y
> # CONFIG_CRYPTO_MICHAEL_MIC is not set
> # CONFIG_CRYPTO_RMD128 is not set
> # CONFIG_CRYPTO_RMD160 is not set
> # CONFIG_CRYPTO_RMD256 is not set
> # CONFIG_CRYPTO_RMD320 is not set
> CONFIG_CRYPTO_SHA1=y
> # CONFIG_CRYPTO_SHA1_SSSE3 is not set
> CONFIG_CRYPTO_SHA256=y
> CONFIG_CRYPTO_SHA512=y
> # CONFIG_CRYPTO_TGR192 is not set
> # CONFIG_CRYPTO_WP512 is not set
> # CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set
> 
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=y
> # CONFIG_CRYPTO_AES_X86_64 is not set
> # CONFIG_CRYPTO_AES_NI_INTEL is not set
> # CONFIG_CRYPTO_ANUBIS is not set
> CONFIG_CRYPTO_ARC4=y
> # CONFIG_CRYPTO_BLOWFISH is not set
> # CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
> # CONFIG_CRYPTO_CAMELLIA is not set
> # CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
> # CONFIG_CRYPTO_CAST5 is not set
> # CONFIG_CRYPTO_CAST6 is not set
> CONFIG_CRYPTO_DES=y
> # CONFIG_CRYPTO_FCRYPT is not set
> # CONFIG_CRYPTO_KHAZAD is not set
> # CONFIG_CRYPTO_SALSA20 is not set
> # CONFIG_CRYPTO_SALSA20_X86_64 is not set
> # CONFIG_CRYPTO_SEED is not set
> # CONFIG_CRYPTO_SERPENT is not set
> # CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
> # CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
> # CONFIG_CRYPTO_TEA is not set
> # CONFIG_CRYPTO_TWOFISH is not set
> # CONFIG_CRYPTO_TWOFISH_X86_64 is not set
> # CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
> # CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set
> 
> #
> # Compression
> #
> CONFIG_CRYPTO_DEFLATE=y
> # CONFIG_CRYPTO_ZLIB is not set
> # CONFIG_CRYPTO_LZO is not set
> 
> #
> # Random Number Generation
> #
> # CONFIG_CRYPTO_ANSI_CPRNG is not set
> # CONFIG_CRYPTO_USER_API_HASH is not set
> # CONFIG_CRYPTO_USER_API_SKCIPHER is not set
> CONFIG_CRYPTO_HW=y
> # CONFIG_CRYPTO_DEV_PADLOCK is not set
> CONFIG_HAVE_KVM=y
> CONFIG_HAVE_KVM_IRQCHIP=y
> CONFIG_HAVE_KVM_EVENTFD=y
> CONFIG_KVM_APIC_ARCHITECTURE=y
> CONFIG_KVM_MMIO=y
> CONFIG_KVM_ASYNC_PF=y
> CONFIG_HAVE_KVM_MSI=y
> CONFIG_VIRTUALIZATION=y
> CONFIG_KVM=y
> CONFIG_KVM_INTEL=y
> # CONFIG_KVM_AMD is not set
> # CONFIG_KVM_MMU_AUDIT is not set
> CONFIG_VHOST_NET=y
> CONFIG_BINARY_PRINTF=y
> 
> #
> # Library routines
> #
> CONFIG_RAID6_PQ=y
> CONFIG_BITREVERSE=y
> CONFIG_GENERIC_STRNCPY_FROM_USER=y
> CONFIG_GENERIC_STRNLEN_USER=y
> CONFIG_GENERIC_FIND_FIRST_BIT=y
> CONFIG_GENERIC_PCI_IOMAP=y
> CONFIG_GENERIC_IOMAP=y
> CONFIG_GENERIC_IO=y
> CONFIG_CRC_CCITT=y
> CONFIG_CRC16=y
> CONFIG_CRC_T10DIF=y
> # CONFIG_CRC_ITU_T is not set
> CONFIG_CRC32=y
> # CONFIG_CRC32_SELFTEST is not set
> CONFIG_CRC32_SLICEBY8=y
> # CONFIG_CRC32_SLICEBY4 is not set
> # CONFIG_CRC32_SARWATE is not set
> # CONFIG_CRC32_BIT is not set
> # CONFIG_CRC7 is not set
> CONFIG_LIBCRC32C=y
> # CONFIG_CRC8 is not set
> CONFIG_ZLIB_INFLATE=y
> CONFIG_ZLIB_DEFLATE=y
> CONFIG_LZO_COMPRESS=y
> CONFIG_LZO_DECOMPRESS=y
> # CONFIG_XZ_DEC is not set
> # CONFIG_XZ_DEC_BCJ is not set
> CONFIG_DECOMPRESS_GZIP=y
> CONFIG_TEXTSEARCH=y
> CONFIG_TEXTSEARCH_KMP=y
> CONFIG_TEXTSEARCH_BM=y
> CONFIG_TEXTSEARCH_FSM=y
> CONFIG_HAS_IOMEM=y
> CONFIG_HAS_IOPORT=y
> CONFIG_HAS_DMA=y
> # CONFIG_CPUMASK_OFFSTACK is not set
> CONFIG_CPU_RMAP=y
> CONFIG_DQL=y
> CONFIG_NLATTR=y
> CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
> # CONFIG_AVERAGE is not set
> # CONFIG_CORDIC is not set
> # CONFIG_DDR is not set
