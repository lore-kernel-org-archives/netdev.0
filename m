From: Sasha Levin <levinsasha928@gmail.com>
Subject: net: Hung task when closing device
Date: Wed, 14 Mar 2012 17:07:35 -0400
Message-ID: <1331759255.3723.8.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>
To: davem <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37630 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756031Ab2CNTHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 15:07:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I've stumbled on the backtrace at the bottom when running the trinity fuzzer in a KVM guest on the latest linux-next build.

It reminds me a lot of https://lkml.org/lkml/2012/1/14/45 where the problem was a held mutex when leaving to userspace to deal with call_usermodehelper_exec().

[  241.448189] INFO: task kworker/u:2:3577 blocked for more than 120 seconds.
[  241.449837] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  241.452037] kworker/u:2     D 0000000000000000  4280  3577      2 0x00000000
[  241.454055]  ffff88002d599810 0000000000000082 5482a487f047e242 ffff88002d599fd8
[  241.456210]  00000000001d4340 ffff88002d598000 00000000001d4340 00000000001d4340
[  241.457907]  00000000001d4340 00000000001d4340 ffff88002d599fd8 00000000001d4340
[  241.459056] Call Trace:
[  241.459424]  [<ffffffff826ee324>] schedule+0x24/0x70
[  241.460130]  [<ffffffff826ec5d5>] schedule_timeout+0x245/0x2c0
[  241.460994]  [<ffffffff8111316e>] ? mark_held_locks+0x6e/0x130
[  241.461890]  [<ffffffff81115bcf>] ? __lock_release+0x8f/0x1d0
[  241.462779]  [<ffffffff826efaab>] ? _raw_spin_unlock_irq+0x2b/0x70
[  241.463585]  [<ffffffff810e42c1>] ? get_parent_ip+0x11/0x50
[  241.464344]  [<ffffffff826eeb10>] wait_for_common+0x120/0x170
[  241.465108]  [<ffffffff810e2bb0>] ? try_to_wake_up+0x250/0x250
[  241.465798]  [<ffffffff826eec08>] wait_for_completion+0x18/0x20
[  241.466533]  [<ffffffff810c9878>] call_usermodehelper_exec+0x228/0x230
[  241.467372]  [<ffffffff826eea34>] ? wait_for_common+0x44/0x170
[  241.468111]  [<ffffffff81875ebb>] kobject_uevent_env+0x61b/0x650
[  241.468957]  [<ffffffff810561a3>] ? sched_clock+0x13/0x20
[  241.469852]  [<ffffffff81875efb>] kobject_uevent+0xb/0x10
[  241.470652]  [<ffffffff81874c0a>] kobject_cleanup+0xca/0x1b0
[  241.471426]  [<ffffffff81874cfd>] kobject_release+0xd/0x10
[  241.472140]  [<ffffffff818746dc>] kobject_put+0x2c/0x60
[  241.472819]  [<ffffffff8223a968>] ? dev_mc_flush+0x38/0x50
[  241.473524]  [<ffffffff8224b06b>] net_rx_queue_update_kobjects+0xab/0xf0
[  241.474426]  [<ffffffff8224b207>] netdev_unregister_kobject+0x37/0x70
[  241.475311]  [<ffffffff82235ba6>] rollback_registered_many+0x186/0x250
[  241.476139]  [<ffffffff82235d74>] unregister_netdevice_many+0x14/0x60
[  241.476935]  [<ffffffff82235e75>] default_device_exit_batch+0xb5/0xe0
[  241.477773]  [<ffffffff82229213>] ops_exit_list.clone.0+0x53/0x60
[  241.478562]  [<ffffffff82229c00>] cleanup_net+0x100/0x1a0
[  241.479244]  [<ffffffff810ca327>] process_one_work+0x1c7/0x460
[  241.479938]  [<ffffffff810ca2c6>] ? process_one_work+0x166/0x460
[  241.480740]  [<ffffffff82229b00>] ? net_drop_ns+0x40/0x40
[  241.481488]  [<ffffffff810cb892>] worker_thread+0x162/0x340
[  241.482216]  [<ffffffff810cb730>] ? manage_workers.clone.13+0x130/0x130
[  241.483040]  [<ffffffff810d25be>] kthread+0xbe/0xd0
[  241.483679]  [<ffffffff826f26b4>] kernel_thread_helper+0x4/0x10
[  241.484473]  [<ffffffff810de328>] ? finish_task_switch+0x78/0x100
[  241.485291]  [<ffffffff826f0834>] ? retint_restore_args+0x13/0x13
[  241.486058]  [<ffffffff810d2500>] ? kthread_flush_work_fn+0x10/0x10
[  241.486844]  [<ffffffff826f26b0>] ? gs_change+0x13/0x13
[  241.487535] 4 locks held by kworker/u:2/3577:
[  241.488131]  #0:  (netns){.+.+.+}, at: [<ffffffff810ca2c6>] process_one_work+0x166/0x460
[  241.489222]  #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff810ca2c6>] process_one_work+0x166/0x460
[  241.490419]  #2:  (net_mutex){+.+.+.}, at: [<ffffffff82229b80>] cleanup_net+0x80/0x1a0
[  241.491460]  #3:  (rtnl_mutex){+.+.+.}, at: [<ffffffff822439d2>] rtnl_lock+0x12/0x20
[  241.492556] Kernel panic - not syncing: hung_task: blocked tasks
[  241.493478] Rebooting in 1 seconds.

-- 

Sasha.
