From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [v2 Patch 3/3] bonding: make bonding support netpoll
Date: Tue, 6 Apr 2010 10:48:24 -0400
Message-ID: <20100406144824.GB10488@gospo.rdu.redhat.com>
References: <20100405091605.4890.31181.sendpatchset@localhost.localdomain> <20100405091628.4890.30541.sendpatchset@localhost.localdomain> <20100405194356.GA10488@gospo.rdu.redhat.com> <4BBA9FDB.4040909@redhat.com> <4BBABAB8.4010401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BBABAB8.4010401@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 06, 2010 at 12:38:16PM +0800, Cong Wang wrote:
> Cong Wang wrote:
>> Before I try to reproduce it, could you please try to replace the  
>> 'read_lock()'
>> in slaves_support_netpoll() with 'read_lock_bh()'? (read_unlock() too)  
>> Try if this helps.
>>
>
> Confirmed. Please use the attached patch instead, for your testing.
>
> Thanks!
>

Moving those locks to bh-locks will not resolve this.  I tried that
yesterday and tried your new patch today without success.  That warning
is a WARN_ON_ONCE so you need to reboot to see that it is still a
problem.  Simply unloading and loading the new module is not an accurate
test.

Also, my system still hangs when removing the bonding module.  I do not
think you intended to fix this with the patch, but wanted it to be clear
to everyone on the list.

You should also configure your kernel with a some of the lock debugging
enabled.  I've been using the following:

CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y

Here is the output when I remove a slave from the bond.  My
xmit_roundrobin patch from earlier (replacing read_lock with
read_trylock) was applied.  It might be helpful for you when debugging
these issues.

------------[ cut here ]------------
WARNING: at kernel/softirq.c:143 local_bh_enable+0x43/0xba()
Hardware name: HP xw4400 Workstation
Modules linked in: netconsole bonding ipt_REJECT bridge stp autofs4 i2c_dev i2c_core hidp rfcomm
l2cap crc16 bluetooth rfki]
Pid: 10, comm: events/1 Not tainted 2.6.34-rc3 #6
Call Trace:
 [<ffffffff81058754>] ? cpu_clock+0x2d/0x41
 [<ffffffff810404d9>] ? local_bh_enable+0x43/0xba
 [<ffffffff8103a350>] warn_slowpath_common+0x77/0x8f
 [<ffffffff812a4659>] ? dev_queue_xmit+0x408/0x467
 [<ffffffff8103a377>] warn_slowpath_null+0xf/0x11
 [<ffffffff810404d9>] local_bh_enable+0x43/0xba
 [<ffffffff812a4659>] dev_queue_xmit+0x408/0x467
 [<ffffffff812a435e>] ? dev_queue_xmit+0x10d/0x467
 [<ffffffffa04a383f>] bond_dev_queue_xmit+0x1cd/0x1f9 [bonding]
 [<ffffffffa04a41ee>] bond_start_xmit+0x139/0x3e9 [bonding]
 [<ffffffff812b0e9a>] queue_process+0xa8/0x160
 [<ffffffff812b0df2>] ? queue_process+0x0/0x160
 [<ffffffff81050bfb>] worker_thread+0x1af/0x2ae
 [<ffffffff81050ba2>] ? worker_thread+0x156/0x2ae
 [<ffffffff81053c34>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff81050a4c>] ? worker_thread+0x0/0x2ae
 [<ffffffff81053901>] kthread+0x7d/0x85
 [<ffffffff81003794>] kernel_thread_helper+0x4/0x10
 [<ffffffff813362bc>] ? restore_args+0x0/0x30
 [<ffffffff81053884>] ? kthread+0x0/0x85
 [<ffffffff81003790>] ? kernel_thread_helper+0x0/0x10
---[ end trace 241f49bf65e0f4f0 ]---

=========================================================
[ INFO: possible irq lock inversion dependency detected ]
2.6.34-rc3 #6
---------------------------------------------------------
events/1/10 just changed the state of lock:
 (&bonding_netdev_xmit_lock_key){+.+...}, at: [<ffffffff812b0e75>] queue_process+0x83/0x160
but this lock was taken by another, SOFTIRQ-safe lock in the past:
 (&(&dev->tx_global_lock)->rlock){+.-...}

and interrupts could create inverse lock ordering between them.


other info that might help us debug this:
4 locks held by events/1/10:
 #0:  (events){+.+.+.}, at: [<ffffffff81050ba2>] worker_thread+0x156/0x2ae
 #1:  ((&(&npinfo->tx_work)->work)){+.+...}, at: [<ffffffff81050ba2>] worker_thread+0x156/0x2ae
 #2:  (&bonding_netdev_xmit_lock_key){+.+...}, at: [<ffffffff812b0e75>] queue_process+0x83/0x160
 #3:  (&bond->lock){++.+..}, at: [<ffffffffa04a4107>] bond_start_xmit+0x52/0x3e9 [bonding]

the shortest dependencies between 2nd lock and 1st lock:
 -> (&(&dev->tx_global_lock)->rlock){+.-...} ops: 129 {
    HARDIRQ-ON-W at:
                          [<ffffffff810651ef>] __lock_acquire+0x643/0x813
                          [<ffffffff81065487>] lock_acquire+0xc8/0xed
                          [<ffffffff81335742>] _raw_spin_lock+0x31/0x66
                          [<ffffffff812b64bd>] dev_deactivate+0x6f/0x195
                          [<ffffffff812ad7c4>] linkwatch_do_dev+0x9a/0xae
                          [<ffffffff812ada6a>] __linkwatch_run_queue+0x106/0x14a
                          [<ffffffff812adad8>] linkwatch_event+0x2a/0x31
                          [<ffffffff81050bfb>] worker_thread+0x1af/0x2ae
                          [<ffffffff81053901>] kthread+0x7d/0x85
                          [<ffffffff81003794>] kernel_thread_helper+0x4/0x10
    IN-SOFTIRQ-W at:
                          [<ffffffff810651a3>] __lock_acquire+0x5f7/0x813
                          [<ffffffff81065487>] lock_acquire+0xc8/0xed
                          [<ffffffff81335742>] _raw_spin_lock+0x31/0x66
                          [<ffffffff812b6606>] dev_watchdog+0x23/0x1f2
                          [<ffffffff8104701b>] run_timer_softirq+0x1d1/0x285
                          [<ffffffff81040021>] __do_softirq+0xdb/0x1ab
                          [<ffffffff8100388c>] call_softirq+0x1c/0x34
                          [<ffffffff81004f9d>] do_softirq+0x38/0x83
                          [<ffffffff8103ff44>] irq_exit+0x45/0x47
                          [<ffffffff810193bc>] smp_apic_timer_interrupt+0x88/0x98
                          [<ffffffff81003353>] apic_timer_interrupt+0x13/0x20
                          [<ffffffff81001a21>] cpu_idle+0x4d/0x6b
                          [<ffffffff8131da3a>] rest_init+0xbe/0xc2
                          [<ffffffff81a00d4e>] start_kernel+0x38c/0x399
                          [<ffffffff81a002a5>] x86_64_start_reservations+0xb5/0xb9
                          [<ffffffff81a0038f>] x86_64_start_kernel+0xe6/0xed
    INITIAL USE at:
                         [<ffffffff8106525c>] __lock_acquire+0x6b0/0x813
                         [<ffffffff81065487>] lock_acquire+0xc8/0xed
                         [<ffffffff81335742>] _raw_spin_lock+0x31/0x66
                         [<ffffffff812b64bd>] dev_deactivate+0x6f/0x195
                         [<ffffffff812ad7c4>] linkwatch_do_dev+0x9a/0xae
                         [<ffffffff812ada6a>] __linkwatch_run_queue+0x106/0x14a
                         [<ffffffff812adad8>] linkwatch_event+0x2a/0x31
                         [<ffffffff81050bfb>] worker_thread+0x1af/0x2ae
                         [<ffffffff81053901>] kthread+0x7d/0x85
                         [<ffffffff81003794>] kernel_thread_helper+0x4/0x10
  }
  ... key      at: [<ffffffff8282ceb0>] __key.51521+0x0/0x8
  ... acquired at:
   [<ffffffff810649f9>] validate_chain+0xb87/0xd3a
   [<ffffffff81065359>] __lock_acquire+0x7ad/0x813
   [<ffffffff81065487>] lock_acquire+0xc8/0xed
   [<ffffffff81335742>] _raw_spin_lock+0x31/0x66
   [<ffffffff812b64e4>] dev_deactivate+0x96/0x195
   [<ffffffff812a17fc>] __dev_close+0x69/0x86
   [<ffffffff8129f8ed>] __dev_change_flags+0xa8/0x12b
   [<ffffffff812a148c>] dev_change_flags+0x1c/0x51
   [<ffffffff812eee8a>] devinet_ioctl+0x26e/0x5d0
   [<ffffffff812ef978>] inet_ioctl+0x8a/0xa2
   [<ffffffff8128fc28>] sock_do_ioctl+0x26/0x45
   [<ffffffff8128fe5a>] sock_ioctl+0x213/0x226
   [<ffffffff810e5988>] vfs_ioctl+0x2a/0x9d
   [<ffffffff810e5f13>] do_vfs_ioctl+0x491/0x4e2
   [<ffffffff810e5fbb>] sys_ioctl+0x57/0x7a
   [<ffffffff8100296b>] system_call_fastpath+0x16/0x1b

-> (&bonding_netdev_xmit_lock_key){+.+...} ops: 2 {
   HARDIRQ-ON-W at:
                        [<ffffffff810651ef>] __lock_acquire+0x643/0x813
                        [<ffffffff81065487>] lock_acquire+0xc8/0xed
                        [<ffffffff81335742>] _raw_spin_lock+0x31/0x66
                        [<ffffffff812b64e4>] dev_deactivate+0x96/0x195
                        [<ffffffff812a17fc>] __dev_close+0x69/0x86
                        [<ffffffff8129f8ed>] __dev_change_flags+0xa8/0x12b
                        [<ffffffff812a148c>] dev_change_flags+0x1c/0x51
                        [<ffffffff812eee8a>] devinet_ioctl+0x26e/0x5d0
                        [<ffffffff812ef978>] inet_ioctl+0x8a/0xa2
                        [<ffffffff8128fc28>] sock_do_ioctl+0x26/0x45
                        [<ffffffff8128fe5a>] sock_ioctl+0x213/0x226
                        [<ffffffff810e5988>] vfs_ioctl+0x2a/0x9d
                        [<ffffffff810e5f13>] do_vfs_ioctl+0x491/0x4e2
                        [<ffffffff810e5fbb>] sys_ioctl+0x57/0x7a
                        [<ffffffff8100296b>] system_call_fastpath+0x16/0x1b
   SOFTIRQ-ON-W at:
                        [<ffffffff81062006>] mark_held_locks+0x49/0x69
                        [<ffffffff81062139>] trace_hardirqs_on_caller+0x113/0x13e
                        [<ffffffff81062171>] trace_hardirqs_on+0xd/0xf
                        [<ffffffff81040548>] local_bh_enable+0xb2/0xba
                        [<ffffffff812a4659>] dev_queue_xmit+0x408/0x467
                        [<ffffffffa04a383f>] bond_dev_queue_xmit+0x1cd/0x1f9 [bonding]
                        [<ffffffffa04a41ee>] bond_start_xmit+0x139/0x3e9 [bonding]
                        [<ffffffff812b0e9a>] queue_process+0xa8/0x160
                        [<ffffffff81050bfb>] worker_thread+0x1af/0x2ae
                        [<ffffffff81053901>] kthread+0x7d/0x85
                        [<ffffffff81003794>] kernel_thread_helper+0x4/0x10
   INITIAL USE at:
                       [<ffffffff8106525c>] __lock_acquire+0x6b0/0x813
                       [<ffffffff81065487>] lock_acquire+0xc8/0xed
                       [<ffffffff81335742>] _raw_spin_lock+0x31/0x66
                       [<ffffffff812b64e4>] dev_deactivate+0x96/0x195
                       [<ffffffff812a17fc>] __dev_close+0x69/0x86
                       [<ffffffff8129f8ed>] __dev_change_flags+0xa8/0x12b
                       [<ffffffff812a148c>] dev_change_flags+0x1c/0x51
                       [<ffffffff812eee8a>] devinet_ioctl+0x26e/0x5d0
                       [<ffffffff812ef978>] inet_ioctl+0x8a/0xa2
                       [<ffffffff8128fc28>] sock_do_ioctl+0x26/0x45
                       [<ffffffff8128fe5a>] sock_ioctl+0x213/0x226
                       [<ffffffff810e5988>] vfs_ioctl+0x2a/0x9d
                       [<ffffffff810e5f13>] do_vfs_ioctl+0x491/0x4e2
                       [<ffffffff810e5fbb>] sys_ioctl+0x57/0x7a
                       [<ffffffff8100296b>] system_call_fastpath+0x16/0x1b
 }
 ... key      at: [<ffffffffa04b1968>] bonding_netdev_xmit_lock_key+0x0/0xffffffffffffa78c [bonding]
 ... acquired at:
   [<ffffffff8106386d>] check_usage_backwards+0xb8/0xc7
   [<ffffffff81061d81>] mark_lock+0x311/0x54d
   [<ffffffff81062006>] mark_held_locks+0x49/0x69
   [<ffffffff81062139>] trace_hardirqs_on_caller+0x113/0x13e
   [<ffffffff81062171>] trace_hardirqs_on+0xd/0xf
   [<ffffffff81040548>] local_bh_enable+0xb2/0xba
   [<ffffffff812a4659>] dev_queue_xmit+0x408/0x467
   [<ffffffffa04a383f>] bond_dev_queue_xmit+0x1cd/0x1f9 [bonding]
   [<ffffffffa04a41ee>] bond_start_xmit+0x139/0x3e9 [bonding]
   [<ffffffff812b0e9a>] queue_process+0xa8/0x160
   [<ffffffff81050bfb>] worker_thread+0x1af/0x2ae
   [<ffffffff81053901>] kthread+0x7d/0x85
   [<ffffffff81003794>] kernel_thread_helper+0x4/0x10


stack backtrace:
Pid: 10, comm: events/1 Tainted: G        W  2.6.34-rc3 #6
Call Trace:
 [<ffffffff8106189e>] print_irq_inversion_bug+0x121/0x130
 [<ffffffff8106386d>] check_usage_backwards+0xb8/0xc7
 [<ffffffff810637b5>] ? check_usage_backwards+0x0/0xc7
 [<ffffffff81061d81>] mark_lock+0x311/0x54d
 [<ffffffff81062006>] mark_held_locks+0x49/0x69
 [<ffffffff81040548>] ? local_bh_enable+0xb2/0xba
 [<ffffffff81062139>] trace_hardirqs_on_caller+0x113/0x13e
 [<ffffffff812a4659>] ? dev_queue_xmit+0x408/0x467
 [<ffffffff81062171>] trace_hardirqs_on+0xd/0xf
 [<ffffffff81040548>] local_bh_enable+0xb2/0xba
 [<ffffffff812a4659>] dev_queue_xmit+0x408/0x467
 [<ffffffff812a435e>] ? dev_queue_xmit+0x10d/0x467
 [<ffffffffa04a383f>] bond_dev_queue_xmit+0x1cd/0x1f9 [bonding]
 [<ffffffffa04a41ee>] bond_start_xmit+0x139/0x3e9 [bonding]
 [<ffffffff812b0e9a>] queue_process+0xa8/0x160
 [<ffffffff812b0df2>] ? queue_process+0x0/0x160
 [<ffffffff81050bfb>] worker_thread+0x1af/0x2ae
 [<ffffffff81050ba2>] ? worker_thread+0x156/0x2ae
 [<ffffffff81053c34>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff81050a4c>] ? worker_thread+0x0/0x2ae
 [<ffffffff81053901>] kthread+0x7d/0x85
 [<ffffffff81003794>] kernel_thread_helper+0x4/0x10
 [<ffffffff813362bc>] ? restore_args+0x0/0x30
 [<ffffffff81053884>] ? kthread+0x0/0x85
 [<ffffffff81003790>] ? kernel_thread_helper+0x0/0x10
Dead loop on virtual device bond0, fix it urgently!
