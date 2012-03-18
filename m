From: Sasha Levin <levinsasha928@gmail.com>
Subject: netfilter: Hung task
Date: Sun, 18 Mar 2012 12:55:13 +0200
Message-ID: <CA+1xoqfCTXxXsbfUjttuOVutyD_FzYS8PoOoAOOtB72P8SwdVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Jones <davej@redhat.com>, netfilter-devel@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: pablo@netfilter.org, kaber@trash.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I got the following spew after fuzzing using trinity on a KVM tools
guest, using the latest linux-next.

It reminds me a lot of https://lkml.org/lkml/2012/3/14/375 and
https://lkml.org/lkml/2012/1/14/45 .

[ 6841.034447] INFO: task kworker/u:2:12563 blocked for more than 120 seconds.
[ 6841.035431] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 6841.036477] kworker/u:2     D 0000000000000000  4088 12563      2 0x00000000
[ 6841.037463]  ffff88002f8918b0 0000000000000082 0000000000000002
ffff88002f891fd8
[ 6841.038978]  00000000001d45c0 ffff88002f890000 00000000001d45c0
00000000001d45c0
[ 6841.039966]  00000000001d45c0 00000000001d45c0 ffff88002f891fd8
00000000001d45c0
[ 6841.041002] Call Trace:
[ 6841.041658]  [<ffffffff82708744>] schedule+0x24/0x70
[ 6841.042204]  [<ffffffff827069f5>] schedule_timeout+0x245/0x2c0
[ 6841.042731]  [<ffffffff8270ac34>] ? retint_restore_args+0x13/0x13
[ 6841.043334]  [<ffffffff810e7b51>] ? get_parent_ip+0x11/0x50
[ 6841.043963]  [<ffffffff82708f30>] wait_for_common+0x120/0x170
[ 6841.044468]  [<ffffffff810e6440>] ? try_to_wake_up+0x250/0x250
[ 6841.045162]  [<ffffffff82709028>] wait_for_completion+0x18/0x20
[ 6841.045858]  [<ffffffff810cd0f8>] call_usermodehelper_exec+0x228/0x230
[ 6841.046536]  [<ffffffff82708e54>] ? wait_for_common+0x44/0x170
[ 6841.047072]  [<ffffffff8187b1ab>] kobject_uevent_env+0x61b/0x650
[ 6841.047915]  [<ffffffff8187b1eb>] kobject_uevent+0xb/0x10
[ 6841.048757]  [<ffffffff811ca745>] kmem_cache_destroy+0x185/0x1f0
[ 6841.049565]  [<ffffffff822b3559>] nf_conntrack_cleanup_net+0xd9/0x100
[ 6841.050275]  [<ffffffff822b35c2>] nf_conntrack_cleanup+0x22/0x60
[ 6841.051154]  [<ffffffff822b3d05>] nf_conntrack_net_exit+0x45/0x60
[ 6841.052061]  [<ffffffff82235458>] ops_exit_list.clone.0+0x38/0x60
[ 6841.052582]  [<ffffffff82235e60>] cleanup_net+0x100/0x1a0
[ 6841.053126]  [<ffffffff810cdba7>] process_one_work+0x1c7/0x460
[ 6841.053560]  [<ffffffff810cdb46>] ? process_one_work+0x166/0x460
[ 6841.054065]  [<ffffffff82235d60>] ? net_drop_ns+0x40/0x40
[ 6841.054649]  [<ffffffff810cf112>] worker_thread+0x162/0x340
[ 6841.055201]  [<ffffffff810cefb0>] ? manage_workers.clone.13+0x130/0x130
[ 6841.055691]  [<ffffffff810d5e3e>] kthread+0xbe/0xd0
[ 6841.056166]  [<ffffffff8270cab4>] kernel_thread_helper+0x4/0x10
[ 6841.056627]  [<ffffffff810e1bb8>] ? finish_task_switch+0x78/0x100
[ 6841.057120]  [<ffffffff8270ac34>] ? retint_restore_args+0x13/0x13
[ 6841.057611]  [<ffffffff810d5d80>] ? kthread_flush_work_fn+0x10/0x10
[ 6841.058426]  [<ffffffff8270cab0>] ? gs_change+0x13/0x13
[ 6841.059006] 3 locks held by kworker/u:2/12563:
[ 6841.059387]  #0:  (netns){.+.+.+}, at: [<ffffffff810cdb46>]
process_one_work+0x166/0x460
[ 6841.060153]  #1:  (net_cleanup_work){+.+.+.}, at:
[<ffffffff810cdb46>] process_one_work+0x166/0x460
[ 6841.061304]  #2:  (net_mutex){+.+.+.}, at: [<ffffffff82235de0>]
cleanup_net+0x80/0x1a0
[ 6841.062069] sending NMI to all CPUs:
[ 6841.062354] NMI backtrace for cpu 0
[ 6841.062647] CPU 0
[ 6841.062813] Pid: 1167, comm: khungtaskd Tainted: G        W
3.3.0-rc7-next-20120316-sasha-00003-g06bb741 #54
[ 6841.063055] RIP: 0010:[<ffffffff81075f90>]  [<ffffffff81075f90>]
flat_send_IPI_all+0xd0/0x120
[ 6841.063055] RSP: 0018:ffff88003b945dc0  EFLAGS: 00010006
[ 6841.063055] RAX: 0000000000000000 RBX: 0000000000000282 RCX: 0000000000000000
[ 6841.063055] RDX: ffff88003b948000 RSI: 0000000000000000 RDI: 0000000000000300
[ 6841.063055] RBP: ffff88003b945de0 R08: 0000000000000001 R09: 0000000000000000
[ 6841.063055] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000c00
[ 6841.063055] R13: 0000000001000000 R14: 000000000000037b R15: ffff88003b945e38
[ 6841.063055] FS:  0000000000000000(0000) GS:ffff88003fc00000(0000)
knlGS:0000000000000000
[ 6841.063055] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 6841.063055] CR2: 000000000115b668 CR3: 000000000321d000 CR4: 00000000000406f0
[ 6841.063055] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 6841.063055] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 6841.063055] Process khungtaskd (pid: 1167, threadinfo
ffff88003b944000, task ffff88003b948000)
[ 6841.063055] Stack:
[ 6841.063055]  0000000000000000 0000000000002710 ffff880033fc8000
00000000003fff7c
[ 6841.063055]  ffff88003b945e00 ffffffff81072aea ffff880033fc8000
ffff880033fc8000
[ 6841.063055]  ffff88003b945e70 ffffffff8114f28e ffffffff8114efb8
000000003fffffff
[ 6841.063055] Call Trace:
[ 6841.063055]  [<ffffffff81072aea>] arch_trigger_all_cpu_backtrace+0x6a/0xb0
[ 6841.063055]  [<ffffffff8114f28e>]
check_hung_uninterruptible_tasks+0x31e/0x470
[ 6841.063055]  [<ffffffff8114efb8>] ?
check_hung_uninterruptible_tasks+0x48/0x470
[ 6841.063055]  [<ffffffff8114f3e0>] ?
check_hung_uninterruptible_tasks+0x470/0x470
[ 6841.063055]  [<ffffffff8114f42f>] watchdog+0x4f/0x60
[ 6841.063055]  [<ffffffff810d5e3e>] kthread+0xbe/0xd0
[ 6841.063055]  [<ffffffff8270cab4>] kernel_thread_helper+0x4/0x10
[ 6841.063055]  [<ffffffff810e1bb8>] ? finish_task_switch+0x78/0x100
[ 6841.063055]  [<ffffffff8270ac34>] ? retint_restore_args+0x13/0x13
[ 6841.063055]  [<ffffffff810d5d80>] ? kthread_flush_work_fn+0x10/0x10
[ 6841.063055]  [<ffffffff8270cab0>] ? gs_change+0x13/0x13
[ 6841.063055] Code: c1 e5 18 48 8b 05 a9 16 6c 02 44 8b 60 3c ff 90
50 01 00 00 44 89 2c 25 10 a3 5f ff 41 81 cc 00 04 00 00 44 89 24 25
00 a3 5f ff <f6> c7 02 74 24 e8 56 0c 0a 00 48 83 3d a6 f1 1b 02 00 74
33 48
[ 6841.063055] Call Trace:
[ 6841.063055]  [<ffffffff81072aea>] arch_trigger_all_cpu_backtrace+0x6a/0xb0
[ 6841.063055]  [<ffffffff8114f28e>]
check_hung_uninterruptible_tasks+0x31e/0x470
[ 6841.063055]  [<ffffffff8114efb8>] ?
check_hung_uninterruptible_tasks+0x48/0x470
[ 6841.063055]  [<ffffffff8114f3e0>] ?
check_hung_uninterruptible_tasks+0x470/0x470
[ 6841.063055]  [<ffffffff8114f42f>] watchdog+0x4f/0x60
[ 6841.063055]  [<ffffffff810d5e3e>] kthread+0xbe/0xd0
[ 6841.063055]  [<ffffffff8270cab4>] kernel_thread_helper+0x4/0x10
[ 6841.063055]  [<ffffffff810e1bb8>] ? finish_task_switch+0x78/0x100
[ 6841.063055]  [<ffffffff8270ac34>] ? retint_restore_args+0x13/0x13
[ 6841.063055]  [<ffffffff810d5d80>] ? kthread_flush_work_fn+0x10/0x10
[ 6841.063055]  [<ffffffff8270cab0>] ? gs_change+0x13/0x13
[ 6841.089248] Kernel panic - not syncing: hung_task: blocked tasks
[ 6841.090009] Rebooting in 1 seconds..
