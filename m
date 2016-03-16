From: Baozeng Ding <sploving1@gmail.com>
Subject: net/bluetooth: use-after-free in hci_event_packet
Date: Wed, 16 Mar 2016 22:44:52 +0800
Message-ID: <56e971a5.a664420a.bd1c5.ffffd7a0@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear all,

I've hit the following use-after-free in hci_event_packet while
fuzzying kernel(4.4, on commit
9638685e32af961943b679fcb72d4ddd458eb18f) using syzkaller. I 
cannot reproduce it with a standalone C program. But it reproduces
easily by replaying the fuzzer log using Go toolchain:

$ go get github.com/google/syzkaller
$ cd $GOPATH/src/github.com/google/syzkaller
$ make executor execprog
$ scp bin/syz-executor bin/syz-execprog (your@testmachine)
$ scp poc_file your@testmachine
on your test machine:
$ ./bin/syz-execprog -executor ./bin/syz-executor -cover=0 -repeat=0
-procs=16 poc_file

The content of  the poc_file is as the following:
mmap(&(0x7f0000000000)=nil, (0xd77000), 0x3, 0x32, 0xffffffffffffffff,
0x0)
r0 = syz_open_dev$vhci(&(0x7f000078a000-0x2)="2f6465762f7668636900",
0x0, 0x2081)
writev(r0, &(0x7f0000d72000+0xce4)=[{&(0x7f0000d6d000)="ff00", 0x2}],
0x1)
write(r0,
&(0x7f0000d77000-0x56)="0422e1e37a57f86c13ecf1267dbc33d62693e36b1518dee20b325c6c99f61c416e7dc6dd0452224180f8197ba570311b02cf04e1875f9a9a70c9393c9d42175b341af060368bafea5e028b50be8afea2f53a9564d00b",
0x56)

After running about a few seconds, we will get the following reports:
(in /var/log/kern.log)

BUG: KASAN: use-after-free in hci_event_packet+0x8d45/0x9f90 at addr
ffff88043ef6e310
Read of size 1 by task kworker/u17:11/9348
=============================================================================
BUG kmalloc-512 (Tainted: G    B          ): kasan: bad access
detected
-----------------------------------------------------------------------------

INFO: Allocated in __alloc_workqueue_key+0xf7/0xe50 age=2844 cpu=2
pid=9403
[<      none      >] ___slab_alloc+0x4c7/0x500 kernel/mm/slub.c:2440
[<      none      >] __slab_alloc+0x4c/0x90 kernel/mm/slub.c:2469
[<     inline     >] slab_alloc_node kernel/mm/slub.c:2532
[<     inline     >] slab_alloc kernel/mm/slub.c:2574
[<      none      >] __kmalloc+0x28f/0x320 kernel/mm/slub.c:3534
[<     inline     >] kmalloc kernel/include/linux/slab.h:468
[<     inline     >] kzalloc kernel/include/linux/slab.h:607
[<      none      >] __alloc_workqueue_key+0xf7/0xe50 kernel/kernel/workqueue.c:3853
[<      none      >] hci_register_dev+0x21b/0x870 kernel/net/bluetooth/hci_core.c:3053
[<      none      >] vhci_create_device+0x275/0x520 kernel/drivers/bluetooth/hci_vhci.c:135
[<     inline     >] vhci_get_user kernel/drivers/bluetooth/hci_vhci.c:209
[<      none      >] vhci_write+0x2ad/0x430 kernel/drivers/bluetooth/hci_vhci.c:289
[<      none      >] do_iter_readv_writev+0x18b/0x250 kernel/fs/read_write.c:703
[<      none      >] do_readv_writev+0x3b9/0x6e0 kernel/fs/read_write.c:847
[<      none      >] vfs_writev+0x86/0xc0 kernel/fs/read_write.c:886
[<     inline     >] SYSC_writev kernel/fs/read_write.c:919
[<      none      >] SyS_writev+0x111/0x2b0 kernel/fs/read_write.c:911
[<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
kernel/arch/x86/entry/entry_64.S:185
INFO: Freed in rcu_free_wq+0xb6/0x110 age=353 cpu=5 pid=4134
[<      none      >] __slab_free+0x1fc/0x320 kernel/mm/slub.c:2650
[<     inline     >] slab_free kernel/mm/slub.c:2805
[<      none      >] kfree+0x279/0x2a0 kernel/mm/slub.c:3634
[<      none      >] rcu_free_wq+0xb6/0x110 kernel/kernel/workqueue.c:3159
[<     inline     >] __rcu_reclaim kernel/kernel/rcu/rcu.h:118
[<     inline     >] rcu_do_batch kernel/kernel/rcu/tree.c:2704
[<     inline     >] invoke_rcu_callbacks kernel/kernel/rcu/tree.c:2970
[<     inline     >] __rcu_process_callbacks kernel/kernel/rcu/tree.c:2937
[<      none      >] rcu_process_callbacks+0xb08/0x1230 kernel/kernel/rcu/tree.c:2954
[<      none      >] __do_softirq+0x23b/0x8a0 kernel/kernel/softirq.c:273
[<     inline     >] invoke_softirq kernel/kernel/softirq.c:350
[<      none      >] irq_exit+0x15d/0x190 kernel/kernel/softirq.c:391
[<     inline     >] exiting_irq kernel/./arch/x86/include/asm/apic.h:659
[<      none      >] smp_apic_timer_interrupt+0x7b/0xa0 kernel/arch/x86/kernel/apic/apic.c:932
[<      none      >] apic_timer_interrupt+0x8c/0xa0 kernel/arch/x86/entry/entry_64.S:520
[<     inline     >] zero_user_segments kernel/include/linux/highmem.h:202
[<      none      >] ext4_block_write_begin+0xb2e/0xd20 kernel/fs/ext4/inode.c:938
[<      none      >] ext4_da_write_begin+0x3ec/0xa30 kernel/fs/ext4/inode.c:2724
[<      none      >] generic_perform_write+0x297/0x540 kernel/mm/filemap.c:2537
[<      none      >] __generic_file_write_iter+0x351/0x5a0 kernel/mm/filemap.c:2662
[<      none      >] ext4_file_write_iter+0x2e7/0xc80 kernel/fs/ext4/file.c:171
[<     inline     >] new_sync_write kernel/fs/read_write.c:517
[<      none      >] __vfs_write+0x300/0x470 kernel/fs/read_write.c:530
[<      none      >] vfs_write+0x167/0x4a0 kernel/fs/read_write.c:577
[<     inline     >] SYSC_write kernel/fs/read_write.c:624
[<      none      >] SyS_write+0x111/0x220 kernel/fs/read_write.c:616
INFO: Slab 0xffffea0010fbdb00 objects=20 used=19 fp=0xffff88043ef6e310
flags=0x2fffc0000004080
INFO: Object 0xffff88043ef6e310 @offset=8976 fp=0x          (null)

CPU: 1 PID: 9348 Comm: kworker/u17:11 Tainted: G    B           4.4.0+
#5
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
Workqueue: hci4 hci_rx_work
 00000000ffffffff ffff880433b8f6b0 ffffffff8292049d ffff88048a004b40
 ffff88043ef6e310 ffff88043ef6c000 ffff880433b8f6e0 ffffffff816f2054
 ffff88048a004b40 ffffea0010fbdb00 ffff88043ef6e310 ffff88043ef6e318
Call Trace:
 [<     inline     >] __dump_stack kernel/lib/dump_stack.c:15
 [<ffffffff8292049d>] dump_stack+0x6f/0xa2 kernel/lib/dump_stack.c:50
 [<ffffffff816f2054>] print_trailer+0xf4/0x150 kernel/mm/slub.c:654
 [<ffffffff816f875f>] object_err+0x2f/0x40 kernel/mm/slub.c:661
 [<     inline     >] print_address_description kernel/mm/kasan/report.c:138
 [<ffffffff816fb0c5>] kasan_report_error+0x215/0x530 kernel/mm/kasan/report.c:236
 [<     inline     >] kasan_report kernel/mm/kasan/report.c:259
 [<ffffffff816fb41e>] __asan_report_load1_noabort+0x3e/0x40 kernel/mm/kasan/report.c:277
 [<     inline     >] ? hci_inquiry_result_with_rssi_evt kernel/net/bluetooth/hci_event.c:3616
 [<ffffffff854db5f5>] ? hci_event_packet+0x8d45/0x9f90 kernel/net/bluetooth/hci_event.c:5323
 [<     inline     >] hci_inquiry_result_with_rssi_evt kernel/net/bluetooth/hci_event.c:3616
 [<ffffffff854db5f5>] hci_event_packet+0x8d45/0x9f90 kernel/net/bluetooth/hci_event.c:5323
 [<     inline     >] ? spin_lock kernel/include/linux/spinlock.h:302
 [<ffffffff816f3d32>] ? deactivate_slab+0x212/0x710 kernel/mm/slub.c:1949
 [<     inline     >] ? hci_cc_read_local_amp_info kernel/net/bluetooth/hci_event.c:833
 [<ffffffff854d28b0>] ? hci_cmd_complete_evt+0xcfb0/0xcfb0 kernel/net/bluetooth/hci_event.c:2905
 [<     inline     >] ? spin_unlock kernel/include/linux/spinlock.h:347
 [<ffffffff816f3f28>] ? deactivate_slab+0x408/0x710 kernel/mm/slub.c:1995
 [<ffffffff813fdd20>] ? debug_check_no_locks_freed+0x290/0x290 kernel/kernel/locking/lockdep.c:4123
 [<ffffffff813fdd20>] ? debug_check_no_locks_freed+0x290/0x290 kernel/kernel/locking/lockdep.c:4123
 [<     inline     >] ? rcu_read_unlock kernel/include/linux/rcupdate.h:926
 [<ffffffff813f1df7>] ? cpuacct_charge+0x1a7/0x380 kernel/kernel/sched/cpuacct.c:255
 [<     inline     >] ? rcu_lock_release kernel/include/linux/rcupdate.h:495
 [<     inline     >] ? rcu_read_unlock kernel/include/linux/rcupdate.h:930
 [<ffffffff813f1e16>] ? cpuacct_charge+0x1c6/0x380 kernel/kernel/sched/cpuacct.c:255
 [<     inline     >] ? task_cpu kernel/include/linux/sched.h:3111
 [<ffffffff813f1cb0>] ? cpuacct_charge+0x60/0x380 kernel/kernel/sched/cpuacct.c:240
 [<ffffffff8139e056>] ? rcu_read_unlock+0x16/0x70 kernel/include/linux/rcupdate.h:926
 [<ffffffff813fdd20>] ? debug_check_no_locks_freed+0x290/0x290 kernel/kernel/locking/lockdep.c:4123
 [<ffffffff813a0124>] ? __compute_runnable_contrib+0x54/0x70 kernel/kernel/sched/fair.c:2549
 [<     inline     >] ? __update_load_avg kernel/kernel/sched/fair.c:2668
 [<ffffffff813a0653>] ? update_cfs_rq_load_avg+0x513/0x1160 kernel/kernel/sched/fair.c:2795
 [<ffffffff84c34792>] ? skb_dequeue+0x22/0x180 kernel/net/core/skbuff.c:2333
 [<ffffffff813fd7ad>] ? trace_hardirqs_on+0xd/0x10 kernel/kernel/locking/lockdep.c:2619
 [<ffffffff85509956>] ? hci_send_to_monitor+0x296/0x3e0 kernel/net/bluetooth/hci_sock.c:305
 [<ffffffff8549ad12>] hci_rx_work+0x6f2/0xc00 kernel/net/bluetooth/hci_core.c:4157
 [<ffffffff8134acaa>] ? process_one_work+0x6ca/0x1440 kernel/kernel/workqueue.c:2033
 [<ffffffff8134ad74>] process_one_work+0x794/0x1440 kernel/kernel/workqueue.c:2036
 [<ffffffff8134acaa>] ? process_one_work+0x6ca/0x1440 kernel/kernel/workqueue.c:2033
 [<ffffffff8134a5e0>] ? pwq_dec_nr_in_flight+0x2e0/0x2e0 kernel/include/linux/compiler.h:218
 [<ffffffff8134bafb>] worker_thread+0xdb/0xfc0 kernel/kernel/workqueue.c:2170
 [<     inline     >] ? context_switch kernel/kernel/sched/core.c:2807
 [<ffffffff85d794e9>] ? __schedule+0x919/0x1bd0 kernel/kernel/sched/core.c:3283
 [<ffffffff8135e4ff>] kthread+0x23f/0x2d0 kernel/drivers/block/aoe/aoecmd.c:1303
 [<ffffffff8134ba20>] ? process_one_work+0x1440/0x1440 kernel/include/linux/list.h:655
 [<ffffffff8135e2c0>] ? kthread_create_on_node+0x3b0/0x3b0 kernel/kernel/kthread.c:285
 [<ffffffff8135e2c0>] ? kthread_create_on_node+0x3b0/0x3b0 kernel/kernel/kthread.c:285
 [<ffffffff85d8826f>] ret_from_fork+0x3f/0x70 kernel/arch/x86/entry/entry_64.S:468
 [<ffffffff8135e2c0>] ? kthread_create_on_node+0x3b0/0x3b0 kernel/kernel/kthread.c:285

Memory state around the buggy address:
 ffff88043ef6e200: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88043ef6e280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff88043ef6e300: fc fc fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                         ^
 ffff88043ef6e380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88043ef6e400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
============================================================

Best Regards,

Baozeng Ding
