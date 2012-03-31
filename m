From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Sat, 31 Mar 2012 22:59:09 +0200
Message-ID: <1333227549.2325.4051.camel@edumazet-glaptop>
References: <CA+1xoqfA9FMowOmAXYHtkXB+D6FqgjCRREKPOk_m2c9ZCyaN4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, Oleg Nesterov <oleg@redhat.com>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+1xoqfA9FMowOmAXYHtkXB+D6FqgjCRREKPOk_m2c9ZCyaN4A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-03-31 at 19:51 +0200, Sasha Levin wrote:
> Hi all,
> 
> It appears that a hang may occur when destroying an ipv6 tunnel, which
> I've reproduced several times in a KVM vm.
> 
> The pattern in the stack dump below is consistent with unregistering a
> kobject when holding multiple locks. Unregistering a kobject usually
> leads to an exit back to userspace with call_usermodehelper_exec().

Yes but this userspace call is done asynchronously and we dont have to
wait its done.

> The userspace code may access sysfs files which in turn will require
> locking within the kernel, leading to a deadlock since those locks are
> already held by kernel.


> 
> [ 1561.564172] INFO: task kworker/u:2:3140 blocked for more than 120 seconds.
> [ 1561.566945] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [ 1561.570062] kworker/u:2     D ffff88006ee63000  4504  3140      2 0x00000000
> [ 1561.572968]  ffff88006ed9f7e0 0000000000000082 ffff88006ed9f790
> ffffffff8107d346
> [ 1561.575680]  ffff88006ed9ffd8 00000000001d4580 ffff88006ed9e010
> 00000000001d4580
> [ 1561.578601]  00000000001d4580 00000000001d4580 ffff88006ed9ffd8
> 00000000001d4580
> [ 1561.581697] Call Trace:
> [ 1561.582650]  [<ffffffff8107d346>] ? kvm_clock_read+0x46/0x80
> [ 1561.584543]  [<ffffffff827063d4>] schedule+0x24/0x70
> [ 1561.586231]  [<ffffffff82704025>] schedule_timeout+0x245/0x2c0
> [ 1561.588508]  [<ffffffff81117c9a>] ? mark_held_locks+0x7a/0x120
> [ 1561.590858]  [<ffffffff81119bbd>] ? __lock_release+0x8d/0x1d0
> [ 1561.593162]  [<ffffffff82707e6b>] ? _raw_spin_unlock_irq+0x2b/0x70
> [ 1561.595394]  [<ffffffff810e36d1>] ? get_parent_ip+0x11/0x50
> [ 1561.597403]  [<ffffffff82705919>] wait_for_common+0x119/0x190
> [ 1561.599707]  [<ffffffff810ed1b0>] ? try_to_wake_up+0x2c0/0x2c0
> [ 1561.601758]  [<ffffffff82705a38>] wait_for_completion+0x18/0x20

Something is wrong here, call_usermodehelper_exec ( ... UMH_WAIT_EXEC)
should not block forever. Its not like UMH_WAIT_PROC

Cc Oleg Nesterov <oleg@redhat.com>

> [ 1561.603843]  [<ffffffff810cdcd8>] call_usermodehelper_exec+0x228/0x240
> [ 1561.606059]  [<ffffffff82705844>] ? wait_for_common+0x44/0x190
> [ 1561.608352]  [<ffffffff81878445>] kobject_uevent_env+0x615/0x650
> [ 1561.610908]  [<ffffffff810e36d1>] ? get_parent_ip+0x11/0x50
> [ 1561.613146]  [<ffffffff8187848b>] kobject_uevent+0xb/0x10
> [ 1561.615312]  [<ffffffff81876f5a>] kobject_cleanup+0xca/0x1b0
> [ 1561.617509]  [<ffffffff8187704d>] kobject_release+0xd/0x10
> [ 1561.619334]  [<ffffffff81876d9c>] kobject_put+0x2c/0x60
> [ 1561.621117]  [<ffffffff8226ea80>] net_rx_queue_update_kobjects+0xa0/0xf0
> [ 1561.623421]  [<ffffffff8226ec87>] netdev_unregister_kobject+0x37/0x70
> [ 1561.625979]  [<ffffffff82253e26>] rollback_registered_many+0x186/0x260
> [ 1561.628526]  [<ffffffff82253f14>] unregister_netdevice_many+0x14/0x60
> [ 1561.631064]  [<ffffffff8243922e>] ip6_tnl_destroy_tunnels+0xee/0x160
> [ 1561.633549]  [<ffffffff8243b8f3>] ip6_tnl_exit_net+0xd3/0x1c0
> [ 1561.635843]  [<ffffffff8243b820>] ? ip6_tnl_ioctl+0x550/0x550
> [ 1561.637972]  [<ffffffff81259c86>] ? proc_net_remove+0x16/0x20
> [ 1561.639881]  [<ffffffff8224f119>] ops_exit_list+0x39/0x60
> [ 1561.641666]  [<ffffffff8224f72b>] cleanup_net+0xfb/0x1a0
> [ 1561.643528]  [<ffffffff810ce97d>] process_one_work+0x1cd/0x460
> [ 1561.645828]  [<ffffffff810ce91c>] ? process_one_work+0x16c/0x460
> [ 1561.648180]  [<ffffffff8224f630>] ? net_drop_ns+0x40/0x40
> [ 1561.650285]  [<ffffffff810d1e76>] worker_thread+0x176/0x3b0
> [ 1561.652460]  [<ffffffff810d1d00>] ? manage_workers+0x120/0x120
> [ 1561.654734]  [<ffffffff810d727e>] kthread+0xbe/0xd0
> [ 1561.656656]  [<ffffffff8270a134>] kernel_thread_helper+0x4/0x10
> [ 1561.658881]  [<ffffffff810e3fe0>] ? finish_task_switch+0x80/0x110
> [ 1561.660828]  [<ffffffff82708434>] ? retint_restore_args+0x13/0x13
> [ 1561.662795]  [<ffffffff810d71c0>] ? __init_kthread_worker+0x70/0x70
> [ 1561.664932]  [<ffffffff8270a130>] ? gs_change+0x13/0x13
> [ 1561.667001] 4 locks held by kworker/u:2/3140:
> [ 1561.667599]  #0:  (netns){.+.+.+}, at: [<ffffffff810ce91c>]
> process_one_work+0x16c/0x460
> [ 1561.668758]  #1:  (net_cleanup_work){+.+.+.}, at:
> [<ffffffff810ce91c>] process_one_work+0x16c/0x460
> [ 1561.670002]  #2:  (net_mutex){+.+.+.}, at: [<ffffffff8224f6b0>]
> cleanup_net+0x80/0x1a0
> [ 1561.671700]  #3:  (rtnl_mutex){+.+.+.}, at: [<ffffffff82267f02>]
> rtnl_lock+0x12/0x20
> --
