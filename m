From: Steven Rostedt <rostedt@goodmis.org>
Subject: [STABLE REQUEST] add: e1000: fix lockdep splat in shutdown handler
Date: Thu, 11 Oct 2012 18:09:45 -0400
Message-ID: <1349993385.24256.79.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	stable <stable@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben, David,

I posted before a lockdep splat that showed a possible deadlock that was
later fixed by Jesse. I'm now hitting this deadlock on my box while
testing the 3.2-rt kernel.


Please stand by while rebooting the system...
<5>sd 0:0:0:0: [sda] Synchronizing SCSI cache
<3>INFO: task kworker/0:2:633 blocked for more than 120 seconds.
<3>"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
<6>kworker/0:2     D<c> 0000000000000000 <c>    0   633      2 0x00000000
<c> ffff880074bcbc40<c> 0000000000000046<c> 0000000000000000<c> ffffffff81c11020<c>
<c> 0000000000000000<c> ffff880074bcbfd8<c> 0000000000010440<c> ffff880074bcbfd8<c>
<c> 0000000000010440<c> ffff880075a04540<c> ffff8800713c6650<c> 00000001713c6650<c>
Call Trace:
 [<ffffffff8175ff0e>] schedule+0x75/0x92
 [<ffffffff81760adc>] __rt_mutex_slowlock+0x96/0xde
 [<ffffffff81760c11>] rt_mutex_slowlock+0xed/0x153
 [<ffffffff8106ba4f>] rt_mutex_fastlock.constprop.15+0x35/0x37
 [<ffffffff81760c8c>] rt_mutex_lock+0x15/0x17
 [<ffffffff81761234>] _mutex_lock+0xe/0x10
 [<ffffffff814d7e7b>] e1000_watchdog+0x54/0x4a2
 [<ffffffff814d7e27>] ? e1000_update_stats+0x92c/0x92c
 [<ffffffff810548fc>] process_one_work+0x181/0x2c8
 [<ffffffff81055ae2>] worker_thread+0xe3/0x16c
 [<ffffffff810559ff>] ? manage_workers.isra.24+0x180/0x180
 [<ffffffff81059491>] kthread+0x84/0x8c
 [<ffffffff8102e32a>] ? finish_task_switch+0x57/0x9a
 [<ffffffff817691b4>] kernel_thread_helper+0x4/0x10
 [<ffffffff817617ce>] ? retint_restore_args+0xe/0xe
 [<ffffffff8105940d>] ? rcu_read_unlock_sched_notrace+0x25/0x25
 [<ffffffff817691b0>] ? gs_change+0xb/0xb
<3>INFO: task reboot:1646 blocked for more than 120 seconds.
<3>"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
<6>reboot          D<c> 0000000000000000 <c>    0  1646      1 0x00000000
<c> ffff880073eb3a88<c> 0000000000000086<c> 0000000000000000<c> ffff8800774d2380<c>
<c> 0000000000000000<c> ffff880073eb3fd8<c> 0000000000010440<c> ffff880073eb3fd8<c>
<c> 0000000000010440<c> ffff880071ab4100<c> 0000000000000001<c> 0000000100000001<c>
Call Trace:
 [<ffffffff8175ff0e>] schedule+0x75/0x92
 [<ffffffff8176021b>] schedule_timeout+0x34/0xd9
 [<ffffffff8103250c>] ? get_parent_ip+0xf/0x40
 [<ffffffff81764133>] ? sub_preempt_count+0x94/0xa8
 [<ffffffff8103647e>] ? migrate_enable+0x153/0x165
 [<ffffffff8175fd7f>] wait_for_common+0xa2/0x106
 [<ffffffff810361fd>] ? try_to_wake_up+0x2ba/0x2ba
 [<ffffffff8175fe97>] wait_for_completion+0x1d/0x1f
 [<ffffffff81053e22>] wait_on_cpu_work+0xc9/0xd9
 [<ffffffff81053586>] ? rcu_read_unlock_sched_notrace+0x25/0x25
 [<ffffffff81053e75>] wait_on_work+0x43/0x6b
 [<ffffffff81054ccb>] __cancel_work_timer+0xc7/0x10c
 [<ffffffff81054d22>] cancel_delayed_work_sync+0x12/0x14
 [<ffffffff814d489f>] e1000_down_and_stop+0x39/0x55
 [<ffffffff814d6de2>] e1000_down+0x123/0x183
 [<ffffffff814d873d>] __e1000_shutdown+0x81/0x1f9
 [<ffffffff814d88cf>] e1000_shutdown+0x1a/0x43
 [<ffffffff812a1fa9>] pci_device_shutdown+0x29/0x3d
 [<ffffffff81484387>] device_shutdown+0xc6/0x10b
 [<ffffffff8105071e>] kernel_restart_prepare+0x31/0x38
 [<ffffffff81050739>] kernel_restart+0x14/0x51
 [<ffffffff810508dd>] sys_reboot+0x155/0x1ae
 [<ffffffff8103647e>] ? migrate_enable+0x153/0x165
 [<ffffffff8111cef4>] ? vfsmount_lock_local_unlock+0x2e/0x33
 [<ffffffff8111dfa5>] ? mntput_no_expire+0x2c/0xd5
 [<ffffffff8111e074>] ? mntput+0x26/0x28
 [<ffffffff81106abf>] ? fput+0x1b3/0x1c2
 [<ffffffff810a73a8>] ? trace_hardirqs_on_caller+0xe/0x22
 [<ffffffff8128ef66>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8176706b>] system_call_fastpath+0x16/0x1b


Can you add this to the 3.2 stable tree.

commit 3a3847e007aae732d64d8fd1374126393e9879a3
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Wed Jan 4 20:23:33 2012 +0000

    e1000: fix lockdep splat in shutdown handler


Thanks!

-- Steve
