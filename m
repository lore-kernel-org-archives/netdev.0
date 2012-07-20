From: Sasha Levin <levinsasha928@gmail.com>
Subject: netfilter,rcu: hang in nf_conntrack_net_exit
Date: Fri, 20 Jul 2012 20:43:33 +0200
Message-ID: <5009A6D5.1030907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	coreteam@netfilter.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: pablo@netfilter.org, kaber@trash.net, davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I've stumbled on the following while fuzzing with trinity inside a KVM tools guest, using the latest -next kernel.

[  483.990135] INFO: task kworker/u:0:6 blocked for more than 120 seconds.
[  483.991328] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  483.992500] kworker/u:0     D ffff88000adfa4c8  3160     6      2 0x00000000
[  483.993527]  ffff88000d655a60 0000000000000086 ffff880035bd7640 00000000001d7640
[  483.994667]  ffff88000d655fd8 ffff88000d655fd8 ffff88000d655fd8 ffff88000d655fd8
[  483.995945]  ffff880008448000 ffff88000d65b000 ffff88000d655a50 ffff88000d655c18
[  483.997202] Call Trace:
[  483.997653]  [<ffffffff83788d25>] schedule+0x55/0x60
[  483.998449]  [<ffffffff83786d7a>] schedule_timeout+0x3a/0x370
[  483.999461]  [<ffffffff8115d4a9>] ? mark_held_locks+0xf9/0x130
[  484.000016]  [<ffffffff83789443>] ? wait_for_common+0xf3/0x170
[  484.000016]  [<ffffffff8378a44b>] ? _raw_spin_unlock_irq+0x2b/0x80
[  484.000016]  [<ffffffff8115d758>] ? trace_hardirqs_on_caller+0x118/0x140
[  484.000016]  [<ffffffff8378944b>] wait_for_common+0xfb/0x170
[  484.000016]  [<ffffffff8112fd90>] ? try_to_wake_up+0x290/0x290
[  484.000016]  [<ffffffff811a7960>] ? __call_rcu+0x390/0x390
[  484.000016]  [<ffffffff83789568>] wait_for_completion+0x18/0x20
[  484.000016]  [<ffffffff8111548f>] wait_rcu_gp+0x6f/0xa0
[  484.000016]  [<ffffffff811130f0>] ? perf_trace_rcu_utilization+0xd0/0xd0
[  484.000016]  [<ffffffff83789394>] ? wait_for_common+0x44/0x170
[  484.000016]  [<ffffffff811aa126>] synchronize_rcu+0x86/0x90
[  484.000016]  [<ffffffff83131455>] synchronize_net+0x35/0x40
[  484.000016]  [<ffffffff83194125>] nf_conntrack_cleanup+0x55/0x70
[  484.000016]  [<ffffffff831948a2>] nf_conntrack_net_exit+0x72/0x80
[  484.000016]  [<ffffffff83125285>] ops_exit_list.isra.0+0x35/0x70
[  484.000016]  [<ffffffff83125c70>] cleanup_net+0x100/0x1a0
[  484.000016]  [<ffffffff8110c926>] process_one_work+0x3e6/0x790
[  484.000016]  [<ffffffff8110c7e0>] ? process_one_work+0x2a0/0x790
[  484.000016]  [<ffffffff83125b70>] ? net_drop_ns+0x40/0x40
[  484.000016]  [<ffffffff8110d568>] ? worker_thread+0x48/0x380
[  484.000016]  [<ffffffff8110d719>] worker_thread+0x1f9/0x380
[  484.000016]  [<ffffffff8110d520>] ? manage_workers.isra.8+0x110/0x110
[  484.000016]  [<ffffffff8111823d>] kthread+0xad/0xc0
[  484.000016]  [<ffffffff8378d134>] kernel_thread_helper+0x4/0x10
[  484.000016]  [<ffffffff8378b234>] ? retint_restore_args+0x13/0x13
[  484.000016]  [<ffffffff81118190>] ? insert_kthread_work+0x40/0x40
[  484.000016]  [<ffffffff8378d130>] ? gs_change+0x13/0x13
[  484.000016] 3 locks held by kworker/u:0/6:
[  484.000016]  #0:  (netns){.+.+.+}, at: [<ffffffff8110c7e0>] process_one_work+0x2a0/0x790
[  484.000016]  #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff8110c7e0>] process_one_work+0x2a0/0x790
[  484.000016]  #2:  (net_mutex){+.+.+.}, at: [<ffffffff83125bf0>] cleanup_net+0x80/0x1a0
