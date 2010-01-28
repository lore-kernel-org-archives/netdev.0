From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Thu, 28 Jan 2010 02:20:10 -0500
Message-ID: <1264663210.2793.110.camel@tonnant>
References: <1264657559.2793.103.camel@tonnant>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-KcmM5aEtuxF3V4sWIT8C"
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264657559.2793.103.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-KcmM5aEtuxF3V4sWIT8C
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2010-01-28 at 00:46 -0500, Jon Masters wrote:

> A number of people seem to have reported this crash in various forms,
> but I have yet to see a solution, and can reproduce on 2.6.33-rc5 this
> evening so I know it's still present in the latest upstream kernels too.
> Userspace is Fedora 12, and this happens on both all recent F12 kernels
> (sporadic in 2.6.31 until recently, solidly reproducible on 2.6.32) and
> upstream 2.6.32, and 2.6.33-rc5 also - hard to find a "known good".
> 
> The problem happens when using netfilter with KVM (problem does not
> occur without the firewall loaded, for example) and will occur within a
> few minutes of attempting to start or stop a guest that is connecting to
> the network - the easiest way to reproduce so far is simply to start up
> a bunch of Fedora guests and have them do a "yum update" cycle.
> 
> All of the crashes appear similar to the following (2.6.33-rc5):

Rebuilt the kernel with all debug options turned on, got some lockdep
warnings (haven't looked further yet). Here's the output (attached full
boot log also):

[  205.843071] 
[  205.843073] =======================================================
[  205.843769] [ INFO: possible circular locking dependency detected ]
[  205.843769] 2.6.33-rc5 #3
[  205.843769] -------------------------------------------------------
[  205.843769] libvirtd/3058 is trying to acquire lock:
[  205.843769]  (s_active){++++.+}, at: [<ffffffff81171a56>]
sysfs_addrm_finish+0x36/0x55
[  205.843769] 
[  205.843769] but task is already holding lock:
[  205.843769]  (rtnl_mutex){+.+.+.}, at: [<ffffffff813cedd9>] rtnl_lock
+0x17/0x19
[  205.843769] 
[  205.843769] which lock already depends on the new lock.
[  205.843769] 
[  205.843769] 
[  205.843769] the existing dependency chain (in reverse order) is:
[  205.843769] 
[  205.843769] -> #4 (rtnl_mutex){+.+.+.}:
[  205.843769]        [<ffffffff8107ea94>] __lock_acquire+0xb84/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff8145504b>] __mutex_lock_common
+0x4b/0x392
[  205.843769]        [<ffffffff81455456>] mutex_lock_nested+0x3e/0x43
[  205.843769]        [<ffffffff813cedd9>] rtnl_lock+0x17/0x19
[  205.843769]        [<ffffffff813d05c0>] linkwatch_event+0xe/0x2c
[  205.843769]        [<ffffffff8106713f>] worker_thread+0x266/0x35f
[  205.843769]        [<ffffffff8106b1d0>] kthread+0x9a/0xa2
[  205.843769]        [<ffffffff8100aaa4>] kernel_thread_helper+0x4/0x10
[  205.843769] 
[  205.843769] -> #3 ((linkwatch_work).work){+.+.+.}:
[  205.843769]        [<ffffffff8107ea94>] __lock_acquire+0xb84/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff81067136>] worker_thread+0x25d/0x35f
[  205.843769]        [<ffffffff8106b1d0>] kthread+0x9a/0xa2
[  205.843769]        [<ffffffff8100aaa4>] kernel_thread_helper+0x4/0x10
[  205.843769] 
[  205.843769] -> #2 (events){+.+.+.}:
[  205.843769]        [<ffffffff8107ea94>] __lock_acquire+0xb84/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff81067a8b>] flush_workqueue+0x63/0xb1
[  205.843769]        [<ffffffff81067aee>] flush_scheduled_work
+0x15/0x17
[  205.843769]        [<ffffffff8138168b>] do_md_stop+0x2c0/0x508
[  205.843769]        [<ffffffff81383b94>] md_ioctl+0x92f/0xf49
[  205.843769]        [<ffffffff8121442d>] __blkdev_driver_ioctl
+0x39/0xa3
[  205.843769]        [<ffffffff81214dc8>] blkdev_ioctl+0x67d/0x6b1
[  205.843769]        [<ffffffff8113ef34>] block_ioctl+0x37/0x3b
[  205.843769]        [<ffffffff81126294>] vfs_ioctl+0x32/0xa6
[  205.843769]        [<ffffffff81126814>] do_vfs_ioctl+0x490/0x4d6
[  205.843769]        [<ffffffff811268b0>] sys_ioctl+0x56/0x79
[  205.843769]        [<ffffffff81009c32>] system_call_fastpath
+0x16/0x1b
[  205.843769] 
[  205.843769] -> #1 (&new->reconfig_mutex){+.+.+.}:
[  205.843769]        [<ffffffff8107ea94>] __lock_acquire+0xb84/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff8145504b>] __mutex_lock_common
+0x4b/0x392
[  205.843769]        [<ffffffff814553d0>]
mutex_lock_interruptible_nested+0x3e/0x43
[  205.843769]        [<ffffffff8137bd62>] mddev_lock+0x17/0x19
[  205.843769]        [<ffffffff8137c039>] md_attr_show+0x32/0x5d
[  205.843769]        [<ffffffff811708dc>] sysfs_read_file+0xbd/0x17f
[  205.843769]        [<ffffffff8111983d>] vfs_read+0xab/0x108
[  205.843769]        [<ffffffff8111995a>] sys_read+0x4a/0x6e
[  205.843769]        [<ffffffff81009c32>] system_call_fastpath
+0x16/0x1b
[  205.843769] 
[  205.843769] -> #0 (s_active){++++.+}:
[  205.843769]        [<ffffffff8107e93e>] __lock_acquire+0xa2e/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff81171463>] sysfs_deactivate+0x9a/0x103
[  205.843769]        [<ffffffff81171a56>] sysfs_addrm_finish+0x36/0x55
[  205.843769]        [<ffffffff81171aab>] remove_dir+0x36/0x3e
[  205.843769]        [<ffffffff81171b60>] sysfs_remove_dir+0x9d/0xbe
[  205.843769]        [<ffffffff812206c1>] kobject_del+0x16/0x37
[  205.843769]        [<ffffffff8122078a>] kobject_release+0xa8/0xf8
[  205.843769]        [<ffffffff8122165d>] kref_put+0x43/0x4d
[  205.843769]        [<ffffffff8122063c>] kobject_put+0x47/0x4b
[  205.843769]        [<ffffffffa02d5ef5>] br_sysfs_delbr+0x21/0x43
[bridge]
[  205.843769]        [<ffffffffa02d20e9>] del_br+0x5a/0x6f [bridge]
[  205.843769]        [<ffffffffa02d24b2>] br_del_bridge+0x59/0x67
[bridge]
[  205.843769]        [<ffffffffa02d3764>] br_ioctl_deviceless_stub
+0x1fb/0x21b [bridge]
[  205.843769]        [<ffffffff813b32c4>] sock_ioctl+0x141/0x20d
[  205.843769]        [<ffffffff81126294>] vfs_ioctl+0x32/0xa6
[  205.843769]        [<ffffffff81126814>] do_vfs_ioctl+0x490/0x4d6
[  205.843769]        [<ffffffff811268b0>] sys_ioctl+0x56/0x79
[  205.843769]        [<ffffffff81009c32>] system_call_fastpath
+0x16/0x1b
[  205.843769] 
[  205.843769] other info that might help us debug this:
[  205.843769] 
[  205.843769] 2 locks held by libvirtd/3058:
[  205.843769]  #0:  (br_ioctl_mutex){+.+.+.}, at: [<ffffffff813b32a9>]
sock_ioctl+0x126/0x20d
[  205.843769]  #1:  (rtnl_mutex){+.+.+.}, at: [<ffffffff813cedd9>]
rtnl_lock+0x17/0x19
[  205.843769] 
[  205.843769] stack backtrace:
[  205.843769] Pid: 3058, comm: libvirtd Not tainted 2.6.33-rc5 #3
[  205.843769] Call Trace:
[  205.843769]  [<ffffffff8107dae0>] print_circular_bug+0xa8/0xb6
[  205.843769]  [<ffffffff8107e93e>] __lock_acquire+0xa2e/0xd3c
[  205.843769]  [<ffffffff81171a56>] ? sysfs_addrm_finish+0x36/0x55
[  205.843769]  [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]  [<ffffffff81171a56>] ? sysfs_addrm_finish+0x36/0x55
[  205.843769]  [<ffffffff81171463>] sysfs_deactivate+0x9a/0x103
[  205.843769]  [<ffffffff81171a56>] ? sysfs_addrm_finish+0x36/0x55
[  205.843769]  [<ffffffff8107c028>] ? trace_hardirqs_off+0xd/0xf
[  206.367937]  [<ffffffff81454e6a>] ? __mutex_unlock_slowpath
+0x120/0x132
[  206.367937]  [<ffffffff81171a56>] sysfs_addrm_finish+0x36/0x55
[  206.367937]  [<ffffffff81171aab>] remove_dir+0x36/0x3e
[  206.367937]  [<ffffffff81171b60>] sysfs_remove_dir+0x9d/0xbe
[  206.367937]  [<ffffffff812206c1>] kobject_del+0x16/0x37
[  206.367937]  [<ffffffff8122078a>] kobject_release+0xa8/0xf8
[  206.367937]  [<ffffffff812206e2>] ? kobject_release+0x0/0xf8
[  206.367937]  [<ffffffff8122165d>] kref_put+0x43/0x4d
[  206.367937]  [<ffffffff8122063c>] kobject_put+0x47/0x4b
[  206.367937]  [<ffffffff8105d218>] ? del_timer_sync+0x0/0xa6
[  206.367937]  [<ffffffffa02d5ef5>] br_sysfs_delbr+0x21/0x43 [bridge]
[  206.367937]  [<ffffffffa02d20e9>] del_br+0x5a/0x6f [bridge]
[  206.367937]  [<ffffffffa02d24b2>] br_del_bridge+0x59/0x67 [bridge]
[  206.367937]  [<ffffffffa02d3764>] br_ioctl_deviceless_stub
+0x1fb/0x21b [bridge]
[  206.367937]  [<ffffffff813b32c4>] sock_ioctl+0x141/0x20d
[  206.367937]  [<ffffffff81126294>] vfs_ioctl+0x32/0xa6
[  206.367937]  [<ffffffff81126814>] do_vfs_ioctl+0x490/0x4d6
[  206.367937]  [<ffffffff811268b0>] sys_ioctl+0x56/0x79
[  206.367937]  [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
[  206.482734] kobject: 'brif' (ffff880213a243b8): calling ktype release
[  206.492872] kobject: (ffff880213a243b8): dynamic_kobj_release
[  206.498841] kobject: 'brif': free name
[  206.527833] kobject: 'virbr0' (ffff8801cf3b0500): kobject_uevent_env
[  206.534360] kobject: 'virbr0' (ffff8801cf3b0500): fill_kobj_path:
path = '/devices/virtual/net/virbr0'
[  206.551468] kobject: 'virbr0' (ffff8801cf3b0500): kobject_cleanup
[  206.557611] kobject: 'virbr0' (ffff8801cf3b0500): calling ktype
release
[  206.564358] kobject: 'virbr0': free name
[  208.575408] kobject: 'tun' (ffffffffa044b510): kobject_add_internal:
parent: 'module', set: 'module'
[  208.595562] kobject: 'holders' (ffff8801d352cf68):
kobject_add_internal: parent: 'tun', set: '<NULL>'
[  208.604990] kobject: 'tun' (ffffffffa044b510): kobject_uevent_env
[  208.611296] kobject: 'tun' (ffffffffa044b510): fill_kobj_path: path =
'/module/tun'
[  208.620119] kobject: 'notes' (ffff8801d352c660):
kobject_add_internal: parent: 'tun', set: '<NULL>'
[  208.630343] tun: Universal TUN/TAP device driver, 1.6
[  208.635421] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[  208.641721] kobject: 'tun' (ffff8801cd319e08): kobject_add_internal:
parent: 'misc', set: 'devices'
[  208.651194] kobject: 'tun' (ffff8801cd319e08): kobject_uevent_env
[  208.657386] kobject: 'tun' (ffff8801cd319e08): fill_kobj_path: path =
'/devices/virtual/misc/tun'
[  208.671916] kobject: 'vnet0' (ffff880207df35e0):
kobject_add_internal: parent: 'net', set: 'devices'
[  208.682667] kobject: 'vnet0' (ffff880207df35e0): kobject_uevent_env
[  208.689435] kobject: 'vnet0' (ffff880207df35e0): fill_kobj_path: path
= '/devices/virtual/net/vnet0'
[  208.712572] device vnet0 entered promiscuous mode
[  208.717571] kobject: 'brport' (ffff8801cd378e88):
kobject_add_internal: parent: 'vnet0', set: '<NULL>'
[  208.728149] kobject: 'brport' (ffff8801cd378e88): kobject_uevent_env
[  208.734561] kobject: 'brport' (ffff8801cd378e88): kobject_uevent_env:
filter function caused the event to drop!
[  208.748356] br0: port 2(vnet0) entering forwarding state
[  209.576245] kobject: 'vnet1' (ffff8801cc9a0500):
kobject_add_internal: parent: 'net', set: 'devices'
[  209.587167] kobject: 'vnet1' (ffff8801cc9a0500): kobject_uevent_env
[  209.593773] kobject: 'vnet1' (ffff8801cc9a0500): fill_kobj_path: path
= '/devices/virtual/net/vnet1'
[  209.614211] device vnet1 entered promiscuous mode
[  209.619898] kobject: 'brport' (ffff8801cee35308):
kobject_add_internal: parent: 'vnet1', set: '<NULL>'
[  209.631310] kobject: 'brport' (ffff8801cee35308): kobject_uevent_env
[  209.638303] kobject: 'brport' (ffff8801cee35308): kobject_uevent_env:
filter function caused the event to drop!
[  209.654971] br0: port 3(vnet1) entering forwarding state
[  210.268995] SELinux: initialized (dev mqueue, type mqueue), uses
transition SIDs
[  210.277526] kobject: 'pid_2' (ffff88020e222128):
kobject_add_internal: parent: 'slab', set: 'slab'
[  210.288037] kobject: 'pid_2' (ffff88020e222128): kobject_uevent_env
[  210.294431] kobject: 'pid_2' (ffff88020e222128): fill_kobj_path: path
= '/kernel/slab/pid_2'
[  210.304019] SELinux: initialized (dev proc, type proc), uses
genfs_contexts
[  210.397532] SELinux: initialized (dev mqueue, type mqueue), uses
transition SIDs
[  210.434435] lo: Disabled Privacy Extensions
[  210.443268] SELinux: initialized (dev proc, type proc), uses
genfs_contexts
[  210.787652] kobject: 'lo' (ffff880207b725a0): kobject_cleanup
[  210.793444] kobject: 'lo' (ffff880207b725a0): calling ktype release
[  210.799783] kobject: 'lo': free name
[  218.966215] vnet0: no IPv6 routers present
[  220.336219] vnet1: no IPv6 routers present
[  238.799662] kobject: 'vnet2' (ffff8801ccba8500):
kobject_add_internal: parent: 'net', set: 'devices'
[  238.811833] kobject: 'vnet2' (ffff8801ccba8500): kobject_uevent_env
[  238.818841] kobject: 'vnet2' (ffff8801ccba8500): fill_kobj_path: path
= '/devices/virtual/net/vnet2'
[  238.841088] device vnet2 entered promiscuous mode
[  238.846209] kobject: 'brport' (ffff8801cf2d92d0):
kobject_add_internal: parent: 'vnet2', set: '<NULL>'
[  238.856592] kobject: 'brport' (ffff8801cf2d92d0): kobject_uevent_env
[  238.863088] kobject: 'brport' (ffff8801cf2d92d0): kobject_uevent_env:
filter function caused the event to drop!
[  238.878798] br0: port 4(vnet2) entering forwarding state
[  249.395339] vnet2: no IPv6 routers present
[  339.729225] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[  339.730086] last sysfs
file: /sys/devices/virtual/block/md0/md/sync_speed
[  339.730086] CPU 7 
[  339.730086] Pid: 3245, comm: qemu-kvm Not tainted 2.6.33-rc5 #3
0F9382/Precision WorkStation 490    
[  339.730086] RIP: 0010:[<ffffffff813e5f3e>]  [<ffffffff813e5f3e>]
nf_ct_remove_expectations+0x49/0x5c
[  339.730086] RSP: 0018:ffff880030603c18  EFLAGS: 00010206
[  339.730086] RAX: ffff8801c2ea530b RBX: 009ab2000008d300 RCX:
ffffffffa02925c1
[  339.730086] RDX: 000000000000006b RSI: ffff880030603be8 RDI:
009ab2000008d378
[  339.730086] RBP: ffff880030603c28 R08: 0000000000000002 R09:
0000000000000000
[  339.730086] R10: 0000000000000003 R11: ffff88019d28a268 R12:
ffffffff829a0400
[  339.730086] R13: ffffffffa02925c1 R14: 0000000000000000 R15:
ffff8801a18e4630
[  339.730086] FS:  00007fb6197ca780(0000) GS:ffff880030600000(0000)
knlGS:0000000000000000
[  339.730086] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  339.730086] CR2: 00007f747a184178 CR3: 00000001badd8000 CR4:
00000000000026e0
[  339.730086] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[  339.730086] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[  339.730086] Process qemu-kvm (pid: 3245, threadinfo ffff8801b9370000,
task ffff8801d53c48a0)
[  339.730086] Stack:
[  339.730086]  ffffffff81b045d0 ffffffff829a0400 ffff880030603c48
ffffffff813e3426
[  339.730086] <0> ffff8801a18e4600 ffff88019d28a250 ffff880030603c68
ffffffff813e10f8
[  339.730086] <0> ffff880030603c68 ffffffff81b045d0 ffff880030603c88
ffffffff813bc080
[  339.730086] Call Trace:
[  339.730086]  <IRQ> 
[  339.730086]  [<ffffffff813e3426>] destroy_conntrack+0x73/0x121
[  339.730086]  [<ffffffff813e10f8>] nf_conntrack_destroy+0x2c/0x33
[  339.730086]  [<ffffffff813bc080>] skb_release_head_state+0x77/0xb9
[  339.730086]  [<ffffffff813bbde2>] __kfree_skb+0x16/0x82
[  339.730086]  [<ffffffff813bbee7>] kfree_skb+0x6a/0x73
[  339.730086]  [<ffffffffa02925c1>] ip6_mc_input+0x214/0x221 [ipv6]
[  339.730086]  [<ffffffffa02925f5>] ip6_rcv_finish+0x27/0x2b [ipv6]
[  339.730086]  [<ffffffffa0292938>] ipv6_rcv+0x33f/0x37f [ipv6]
[  339.730086]  [<ffffffff813c416a>] netif_receive_skb+0x3b0/0x3da
[  339.730086]  [<ffffffffa02d2b6e>] br_handle_frame_finish+0x104/0x13c
[bridge]
[  339.730086]  [<ffffffffa02d2d37>] br_handle_frame+0x191/0x1aa
[bridge]
[  339.730086]  [<ffffffff813c40d6>] netif_receive_skb+0x31c/0x3da
[  339.730086]  [<ffffffff8106e6ee>] ? __run_hrtimer+0xec/0x11b
[  339.730086]  [<ffffffff813c4230>] process_backlog+0x9c/0xd8
[  339.730086]  [<ffffffff813c489b>] net_rx_action+0x7d/0x19c
[  339.730086]  [<ffffffff81055d08>] __do_softirq+0xf8/0x1cd
[  339.730086]  [<ffffffff8100ab9c>] call_softirq+0x1c/0x30
[  339.730086]  <EOI> 
[  339.730086]  [<ffffffff8100c38f>] ? do_softirq+0x4b/0xa3
[  339.730086]  [<ffffffff813c49e0>] netif_rx_ni+0x26/0x2b
[  339.730086]  [<ffffffffa0449d6d>] tun_chr_aio_write+0x3ce/0x429 [tun]
[  339.730086]  [<ffffffffa044999f>] ? tun_chr_aio_write+0x0/0x429 [tun]
[  339.730086]  [<ffffffff81118fd2>] do_sync_readv_writev+0xc1/0x100
[  339.730086]  [<ffffffff811e9ee1>] ? selinux_file_permission+0xa7/0xb3
[  339.730086]  [<ffffffff81118d36>] ? copy_from_user+0x2f/0x31
[  339.730086]  [<ffffffff811e02f5>] ? security_file_permission
+0x16/0x18
[  339.730086]  [<ffffffff81119d1f>] do_readv_writev+0xa7/0x127
[  339.730086]  [<ffffffff8111a1d7>] ? rcu_read_unlock+0x21/0x23
[  339.730086]  [<ffffffff8111a2bd>] ? fget_light+0xe4/0xf2
[  339.730086]  [<ffffffff8111a230>] ? fget_light+0x57/0xf2
[  339.730086]  [<ffffffff81119de2>] vfs_writev+0x43/0x4e
[  339.730086]  [<ffffffff81119ed2>] sys_writev+0x4a/0x93
[  339.730086]  [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
[  339.730086] Code: 38 0f b6 d2 48 01 d0 74 30 48 8b 58 28 eb 13 48 89
df e8 fc f8 ff ff 48 89 df e8 c8 f8 ff ff 4c 89 e3 48 85 db 74 12 48 8d
7b 78 <4c> 8b 23 e8 e2 73 c7 ff 85 c0 74 e8 eb d6 5b 41 5c c9 c3 55 48 
[  339.730086] RIP  [<ffffffff813e5f3e>] nf_ct_remove_expectations
+0x49/0x5c
[  339.730086]  RSP <ffff880030603c18>
[  340.095082] ---[ end trace 7be6d51534d25d87 ]---
[  340.099728] Kernel panic - not syncing: Fatal exception in interrupt
[  340.106123] Pid: 3245, comm: qemu-kvm Tainted: G      D    2.6.33-rc5
#3
[  340.112853] Call Trace:
[  340.112860]  <IRQ>  [<ffffffff81453b1d>] panic+0x7a/0x142
[  340.112886]  [<ffffffff81458011>] oops_end+0xb7/0xc7
[  340.112898]  [<ffffffff8100d421>] die+0x5a/0x63
[  340.112909]  [<ffffffff81457bcc>] do_general_protection+0x12a/0x133
[  340.112922]  [<ffffffff81457100>] ? irq_return+0x0/0x10
[  340.112956]  [<ffffffffa02925c1>] ? ip6_mc_input+0x214/0x221 [ipv6]
[  340.112969]  [<ffffffff81457345>] general_protection+0x25/0x30
[  340.113002]  [<ffffffffa02925c1>] ? ip6_mc_input+0x214/0x221 [ipv6]

Jon.


--=-KcmM5aEtuxF3V4sWIT8C
Content-Disposition: attachment; filename="kvm_crash_20100128.txt"
Content-Type: text/plain; name="kvm_crash_20100128.txt"; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.33-rc5 (jcm@perihelion.bos.jonmasters.org)=
 (gcc version 4.4.2 20091222 (Red Hat 4.4.2-20) (GCC) ) #3 SMP Thu Jan 28 0=
1:46:12 EST 2010
[    0.000000] Command line: ro root=3D/dev/mapper/perihelion-root  LANG=3D=
en_US.UTF-8 SYSFONT=3Dlatarcyrheb-sun16 KEYBOARDTYPE=3Dpc KEYTABLE=3Dus con=
sole=3Dtty0 console=3DttyS0,115200,8N1 panic=3D30
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009ec00 (usable)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000dfe0ac00 (usable)
[    0.000000]  BIOS-e820: 00000000dfe0ac00 - 00000000dfe0cc00 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000dfe0ec00 - 00000000dfe5cc00 (reserved)
[    0.000000]  BIOS-e820: 00000000dfe5cc00 - 00000000dfe5ec00 (ACPI data)
[    0.000000]  BIOS-e820: 00000000dfe5ec00 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fe000000 - 00000000ff000000 (reserved)
[    0.000000]  BIOS-e820: 00000000ffb00000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000000220000000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.3 present.
[    0.000000] No AGP bridge found
[    0.000000] last_pfn =3D 0x220000 max_arch_pfn =3D 0x400000000
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x701060007=
0106
[    0.000000] total RAM covered: 64767M
[    0.000000]  gran_size: 64K 	chunk_size: 64K 	num_reg: 8  	lose cover RA=
M: 61191M
[    0.000000]  gran_size: 64K 	chunk_size: 128K 	num_reg: 8  	lose cover R=
AM: 61191M
[    0.000000]  gran_size: 64K 	chunk_size: 256K 	num_reg: 8  	lose cover R=
AM: 61191M
[    0.000000]  gran_size: 64K 	chunk_size: 512K 	num_reg: 8  	lose cover R=
AM: 61191M
[    0.000000]  gran_size: 64K 	chunk_size: 1M 	num_reg: 8  	lose cover RAM=
: 61191M
[    0.000000]  gran_size: 64K 	chunk_size: 2M 	num_reg: 8  	lose cover RAM=
: 16128M
[    0.000000]  gran_size: 64K 	chunk_size: 4M 	num_reg: 8  	lose cover RAM=
: 16128M
[    0.000000]  gran_size: 64K 	chunk_size: 8M 	num_reg: 8  	lose cover RAM=
: 16128M
[    0.000000]  gran_size: 64K 	chunk_size: 16M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 64K 	chunk_size: 32M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 64K 	chunk_size: 64M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 64K 	chunk_size: 128M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 64K 	chunk_size: 256M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000] *BAD*gran_size: 64K 	chunk_size: 512M 	num_reg: 8  	lose cov=
er RAM: -256M
[    0.000000]  gran_size: 64K 	chunk_size: 1G 	num_reg: 8  	lose cover RAM=
: 0G
[    0.000000]  gran_size: 64K 	chunk_size: 2G 	num_reg: 8  	lose cover RAM=
: 0G
[    0.000000]  gran_size: 128K 	chunk_size: 128K 	num_reg: 8  	lose cover =
RAM: 61191M
[    0.000000]  gran_size: 128K 	chunk_size: 256K 	num_reg: 8  	lose cover =
RAM: 61191M
[    0.000000]  gran_size: 128K 	chunk_size: 512K 	num_reg: 8  	lose cover =
RAM: 61191M
[    0.000000]  gran_size: 128K 	chunk_size: 1M 	num_reg: 8  	lose cover RA=
M: 61191M
[    0.000000]  gran_size: 128K 	chunk_size: 2M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 128K 	chunk_size: 4M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 128K 	chunk_size: 8M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 128K 	chunk_size: 16M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 128K 	chunk_size: 32M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 128K 	chunk_size: 64M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 128K 	chunk_size: 128M 	num_reg: 8  	lose cover =
RAM: 16128M
[    0.000000]  gran_size: 128K 	chunk_size: 256M 	num_reg: 8  	lose cover =
RAM: 16128M
[    0.000000] *BAD*gran_size: 128K 	chunk_size: 512M 	num_reg: 8  	lose co=
ver RAM: -256M
[    0.000000]  gran_size: 128K 	chunk_size: 1G 	num_reg: 8  	lose cover RA=
M: 0G
[    0.000000]  gran_size: 128K 	chunk_size: 2G 	num_reg: 8  	lose cover RA=
M: 0G
[    0.000000]  gran_size: 256K 	chunk_size: 256K 	num_reg: 8  	lose cover =
RAM: 61191M
[    0.000000]  gran_size: 256K 	chunk_size: 512K 	num_reg: 8  	lose cover =
RAM: 61191M
[    0.000000]  gran_size: 256K 	chunk_size: 1M 	num_reg: 8  	lose cover RA=
M: 61191M
[    0.000000]  gran_size: 256K 	chunk_size: 2M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 256K 	chunk_size: 4M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 256K 	chunk_size: 8M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 256K 	chunk_size: 16M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 256K 	chunk_size: 32M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 256K 	chunk_size: 64M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 256K 	chunk_size: 128M 	num_reg: 8  	lose cover =
RAM: 16128M
[    0.000000]  gran_size: 256K 	chunk_size: 256M 	num_reg: 8  	lose cover =
RAM: 16128M
[    0.000000] *BAD*gran_size: 256K 	chunk_size: 512M 	num_reg: 8  	lose co=
ver RAM: -256M
[    0.000000]  gran_size: 256K 	chunk_size: 1G 	num_reg: 8  	lose cover RA=
M: 0G
[    0.000000]  gran_size: 256K 	chunk_size: 2G 	num_reg: 8  	lose cover RA=
M: 0G
[    0.000000]  gran_size: 512K 	chunk_size: 512K 	num_reg: 8  	lose cover =
RAM: 61191M
[    0.000000]  gran_size: 512K 	chunk_size: 1M 	num_reg: 8  	lose cover RA=
M: 61191M
[    0.000000]  gran_size: 512K 	chunk_size: 2M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 512K 	chunk_size: 4M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 512K 	chunk_size: 8M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 512K 	chunk_size: 16M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 512K 	chunk_size: 32M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 512K 	chunk_size: 64M 	num_reg: 8  	lose cover R=
AM: 16128M
[    0.000000]  gran_size: 512K 	chunk_size: 128M 	num_reg: 8  	lose cover =
RAM: 16128M
[    0.000000]  gran_size: 512K 	chunk_size: 256M 	num_reg: 8  	lose cover =
RAM: 16128M
[    0.000000] *BAD*gran_size: 512K 	chunk_size: 512M 	num_reg: 8  	lose co=
ver RAM: -256M
[    0.000000]  gran_size: 512K 	chunk_size: 1G 	num_reg: 8  	lose cover RA=
M: 0G
[    0.000000]  gran_size: 512K 	chunk_size: 2G 	num_reg: 8  	lose cover RA=
M: 0G
[    0.000000]  gran_size: 1M 	chunk_size: 1M 	num_reg: 8  	lose cover RAM:=
 61191M
[    0.000000]  gran_size: 1M 	chunk_size: 2M 	num_reg: 8  	lose cover RAM:=
 16128M
[    0.000000]  gran_size: 1M 	chunk_size: 4M 	num_reg: 8  	lose cover RAM:=
 16128M
[    0.000000]  gran_size: 1M 	chunk_size: 8M 	num_reg: 8  	lose cover RAM:=
 16128M
[    0.000000]  gran_size: 1M 	chunk_size: 16M 	num_reg: 8  	lose cover RAM=
: 16128M
[    0.000000]  gran_size: 1M 	chunk_size: 32M 	num_reg: 8  	lose cover RAM=
: 16128M
[    0.000000]  gran_size: 1M 	chunk_size: 64M 	num_reg: 8  	lose cover RAM=
: 16128M
[    0.000000]  gran_size: 1M 	chunk_size: 128M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000]  gran_size: 1M 	chunk_size: 256M 	num_reg: 8  	lose cover RA=
M: 16128M
[    0.000000] *BAD*gran_size: 1M 	chunk_size: 512M 	num_reg: 8  	lose cove=
r RAM: -256M
[    0.000000]  gran_size: 1M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM:=
 0G
[    0.000000]  gran_size: 1M 	chunk_size: 2G 	num_reg: 8  	lose cover RAM:=
 0G
[    0.000000]  gran_size: 2M 	chunk_size: 2M 	num_reg: 8  	lose cover RAM:=
 61191M
[    0.000000]  gran_size: 2M 	chunk_size: 4M 	num_reg: 8  	lose cover RAM:=
 16129M
[    0.000000]  gran_size: 2M 	chunk_size: 8M 	num_reg: 8  	lose cover RAM:=
 16129M
[    0.000000]  gran_size: 2M 	chunk_size: 16M 	num_reg: 8  	lose cover RAM=
: 16129M
[    0.000000]  gran_size: 2M 	chunk_size: 32M 	num_reg: 8  	lose cover RAM=
: 16129M
[    0.000000]  gran_size: 2M 	chunk_size: 64M 	num_reg: 8  	lose cover RAM=
: 16129M
[    0.000000]  gran_size: 2M 	chunk_size: 128M 	num_reg: 8  	lose cover RA=
M: 16129M
[    0.000000]  gran_size: 2M 	chunk_size: 256M 	num_reg: 8  	lose cover RA=
M: 16129M
[    0.000000] *BAD*gran_size: 2M 	chunk_size: 512M 	num_reg: 8  	lose cove=
r RAM: -255M
[    0.000000]  gran_size: 2M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM:=
 1M
[    0.000000]  gran_size: 2M 	chunk_size: 2G 	num_reg: 8  	lose cover RAM:=
 1M
[    0.000000]  gran_size: 4M 	chunk_size: 4M 	num_reg: 8  	lose cover RAM:=
 61191M
[    0.000000]  gran_size: 4M 	chunk_size: 8M 	num_reg: 8  	lose cover RAM:=
 16131M
[    0.000000]  gran_size: 4M 	chunk_size: 16M 	num_reg: 8  	lose cover RAM=
: 16131M
[    0.000000]  gran_size: 4M 	chunk_size: 32M 	num_reg: 8  	lose cover RAM=
: 16131M
[    0.000000]  gran_size: 4M 	chunk_size: 64M 	num_reg: 8  	lose cover RAM=
: 16131M
[    0.000000]  gran_size: 4M 	chunk_size: 128M 	num_reg: 8  	lose cover RA=
M: 16131M
[    0.000000]  gran_size: 4M 	chunk_size: 256M 	num_reg: 8  	lose cover RA=
M: 16131M
[    0.000000] *BAD*gran_size: 4M 	chunk_size: 512M 	num_reg: 8  	lose cove=
r RAM: -253M
[    0.000000]  gran_size: 4M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM:=
 3M
[    0.000000]  gran_size: 4M 	chunk_size: 2G 	num_reg: 8  	lose cover RAM:=
 3M
[    0.000000]  gran_size: 8M 	chunk_size: 8M 	num_reg: 8  	lose cover RAM:=
 61191M
[    0.000000]  gran_size: 8M 	chunk_size: 16M 	num_reg: 8  	lose cover RAM=
: 16135M
[    0.000000]  gran_size: 8M 	chunk_size: 32M 	num_reg: 8  	lose cover RAM=
: 16135M
[    0.000000]  gran_size: 8M 	chunk_size: 64M 	num_reg: 8  	lose cover RAM=
: 16135M
[    0.000000]  gran_size: 8M 	chunk_size: 128M 	num_reg: 8  	lose cover RA=
M: 16135M
[    0.000000]  gran_size: 8M 	chunk_size: 256M 	num_reg: 8  	lose cover RA=
M: 16135M
[    0.000000] *BAD*gran_size: 8M 	chunk_size: 512M 	num_reg: 8  	lose cove=
r RAM: -249M
[    0.000000]  gran_size: 8M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM:=
 7M
[    0.000000]  gran_size: 8M 	chunk_size: 2G 	num_reg: 8  	lose cover RAM:=
 7M
[    0.000000]  gran_size: 16M 	chunk_size: 16M 	num_reg: 8  	lose cover RA=
M: 57103M
[    0.000000]  gran_size: 16M 	chunk_size: 32M 	num_reg: 8  	lose cover RA=
M: 16143M
[    0.000000]  gran_size: 16M 	chunk_size: 64M 	num_reg: 8  	lose cover RA=
M: 16143M
[    0.000000]  gran_size: 16M 	chunk_size: 128M 	num_reg: 8  	lose cover R=
AM: 16143M
[    0.000000]  gran_size: 16M 	chunk_size: 256M 	num_reg: 8  	lose cover R=
AM: 16143M
[    0.000000] *BAD*gran_size: 16M 	chunk_size: 512M 	num_reg: 8  	lose cov=
er RAM: -241M
[    0.000000]  gran_size: 16M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM=
: 15M
[    0.000000]  gran_size: 16M 	chunk_size: 2G 	num_reg: 8  	lose cover RAM=
: 15M
[    0.000000]  gran_size: 32M 	chunk_size: 32M 	num_reg: 8  	lose cover RA=
M: 48927M
[    0.000000]  gran_size: 32M 	chunk_size: 64M 	num_reg: 8  	lose cover RA=
M: 16159M
[    0.000000]  gran_size: 32M 	chunk_size: 128M 	num_reg: 8  	lose cover R=
AM: 16159M
[    0.000000]  gran_size: 32M 	chunk_size: 256M 	num_reg: 8  	lose cover R=
AM: 16159M
[    0.000000] *BAD*gran_size: 32M 	chunk_size: 512M 	num_reg: 8  	lose cov=
er RAM: -225M
[    0.000000]  gran_size: 32M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM=
: 31M
[    0.000000]  gran_size: 32M 	chunk_size: 2G 	num_reg: 8  	lose cover RAM=
: 31M
[    0.000000]  gran_size: 64M 	chunk_size: 64M 	num_reg: 8  	lose cover RA=
M: 32575M
[    0.000000]  gran_size: 64M 	chunk_size: 128M 	num_reg: 8  	lose cover R=
AM: 16191M
[    0.000000]  gran_size: 64M 	chunk_size: 256M 	num_reg: 8  	lose cover R=
AM: 16191M
[    0.000000] *BAD*gran_size: 64M 	chunk_size: 512M 	num_reg: 8  	lose cov=
er RAM: -193M
[    0.000000]  gran_size: 64M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM=
: 63M
[    0.000000]  gran_size: 64M 	chunk_size: 2G 	num_reg: 8  	lose cover RAM=
: 63M
[    0.000000]  gran_size: 128M 	chunk_size: 128M 	num_reg: 8  	lose cover =
RAM: 16255M
[    0.000000]  gran_size: 128M 	chunk_size: 256M 	num_reg: 8  	lose cover =
RAM: 16255M
[    0.000000] *BAD*gran_size: 128M 	chunk_size: 512M 	num_reg: 8  	lose co=
ver RAM: -129M
[    0.000000]  gran_size: 128M 	chunk_size: 1G 	num_reg: 8  	lose cover RA=
M: 127M
[    0.000000]  gran_size: 128M 	chunk_size: 2G 	num_reg: 8  	lose cover RA=
M: 127M
[    0.000000]  gran_size: 256M 	chunk_size: 256M 	num_reg: 8  	lose cover =
RAM: 8191M
[    0.000000] *BAD*gran_size: 256M 	chunk_size: 512M 	num_reg: 8  	lose co=
ver RAM: -1M
[    0.000000]  gran_size: 256M 	chunk_size: 1G 	num_reg: 8  	lose cover RA=
M: 255M
[    0.000000]  gran_size: 256M 	chunk_size: 2G 	num_reg: 8  	lose cover RA=
M: 255M
[    0.000000]  gran_size: 512M 	chunk_size: 512M 	num_reg: 8  	lose cover =
RAM: 4351M
[    0.000000]  gran_size: 512M 	chunk_size: 1G 	num_reg: 7  	lose cover RA=
M: 767M
[    0.000000]  gran_size: 512M 	chunk_size: 2G 	num_reg: 7  	lose cover RA=
M: 767M
[    0.000000]  gran_size: 1G 	chunk_size: 1G 	num_reg: 8  	lose cover RAM:=
 4351M
[    0.000000]  gran_size: 1G 	chunk_size: 2G 	num_reg: 7  	lose cover RAM:=
 1279M
[    0.000000]  gran_size: 2G 	chunk_size: 2G 	num_reg: 8  	lose cover RAM:=
 3327M
[    0.000000] mtrr_cleanup: can not find optimal value
[    0.000000] please specify mtrr_gran_size/mtrr_chunk_size
[    0.000000] last_pfn =3D 0xdfe0a max_arch_pfn =3D 0x400000000
[    0.000000] found SMP MP-table at [ffff8800000fe710] fe710
[    0.000000] init_memory_mapping: 0000000000000000-00000000dfe0a000
[    0.000000] init_memory_mapping: 0000000100000000-0000000220000000
[    0.000000] RAMDISK: 362df000 - 37fefbaf
[    0.000000] ACPI: RSDP 00000000000febf0 00024 (v02 DELL  )
[    0.000000] ACPI: XSDT 00000000000fce54 000B4 (v01 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: FACP 00000000000fcf7c 000F4 (v03 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: DSDT 00000000fff5e6f4 03BCC (v01   DELL    dt_ex 00001=
000 INTL 20050624)
[    0.000000] ACPI: FACS 00000000dfe0ac00 00040
[    0.000000] ACPI: SSDT 00000000fff623e1 000AC (v01   DELL    st_ex 00001=
000 INTL 20050624)
[    0.000000] ACPI: APIC 00000000000fd070 0009E (v01 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: BOOT 00000000000fd10e 00028 (v01 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: ASF! 00000000000fd136 00067 (v16 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: MCFG 00000000000fd19d 0003E (v01 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: HPET 00000000000fd1db 00038 (v01 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: TCPA 00000000000fd437 00032 (v01 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: SLIC 00000000000fd213 00176 (v01 DELL    B8K     00000=
015 ASL  00000061)
[    0.000000] ACPI: SSDT 00000000dfe0ac40 00175 (v01 DpgPmm  Cpu0Ist 00000=
011 INTL 20050624)
[    0.000000] ACPI: SSDT 00000000dfe0b049 00175 (v01 DpgPmm  Cpu1Ist 00000=
011 INTL 20050624)
[    0.000000] ACPI: SSDT 00000000dfe0b452 00175 (v01 DpgPmm  Cpu2Ist 00000=
011 INTL 20050624)
[    0.000000] ACPI: SSDT 00000000dfe0b85b 00175 (v01 DpgPmm  Cpu3Ist 00000=
011 INTL 20050624)
[    0.000000] ACPI: SSDT 00000000dfe0bc64 00175 (v01 DpgPmm  Cpu4Ist 00000=
011 INTL 20050624)
[    0.000000] ACPI: SSDT 00000000dfe0c06d 00175 (v01 DpgPmm  Cpu5Ist 00000=
011 INTL 20050624)
[    0.000000] ACPI: SSDT 00000000dfe0c476 00175 (v01 DpgPmm  Cpu6Ist 00000=
011 INTL 20050624)
[    0.000000] ACPI: SSDT 00000000dfe0c87f 00175 (v01 DpgPmm  Cpu7Ist 00000=
011 INTL 20050624)
[    0.000000] ACPI: SSDT 00000000dfe0cc88 00244 (v01 DpgPmm    CpuPm 00000=
010 INTL 20050624)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-0000000220000000
[    0.000000] Bootmem setup node 0 0000000000000000-0000000220000000
[    0.000000]   NODE_DATA [0000000000007000 - 000000000001cfff]
[    0.000000]   bootmap [000000000001d000 -  0000000000060fff] pages 44
[    0.000000] (13 early reservations) =3D=3D> bootmem [0000000000 - 022000=
0000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> [000=
0000000 - 0000001000]
[    0.000000]   #1 [0001000000 - 00029a4630]    TEXT DATA BSS =3D=3D> [000=
1000000 - 00029a4630]
[    0.000000]   #2 [00362df000 - 0037fefbaf]          RAMDISK =3D=3D> [003=
62df000 - 0037fefbaf]
[    0.000000]   #3 [00029a5000 - 00029a51e0]              BRK =3D=3D> [000=
29a5000 - 00029a51e0]
[    0.000000]   #4 [00000fe720 - 0000100000]    BIOS reserved =3D=3D> [000=
00fe720 - 0000100000]
[    0.000000]   #5 [00000fe710 - 00000fe720]     MP-table mpf =3D=3D> [000=
00fe710 - 00000fe720]
[    0.000000]   #6 [000009ec00 - 00000f0000]    BIOS reserved =3D=3D> [000=
009ec00 - 00000f0000]
[    0.000000]   #7 [00000f03a4 - 00000fe710]    BIOS reserved =3D=3D> [000=
00f03a4 - 00000fe710]
[    0.000000]   #8 [00000f0000 - 00000f03a4]     MP-table mpc =3D=3D> [000=
00f0000 - 00000f03a4]
[    0.000000]   #9 [0000001000 - 0000003000]       TRAMPOLINE =3D=3D> [000=
0001000 - 0000003000]
[    0.000000]   #10 [0000003000 - 0000007000]      ACPI WAKEUP =3D=3D> [00=
00003000 - 0000007000]
[    0.000000]   #11 [0000100000 - 0000803000]          PGTABLE =3D=3D> [00=
00100000 - 0000803000]
[    0.000000]   #12 [00029a6000 - 00032ab000]          PGTABLE =3D=3D> [00=
029a6000 - 00032ab000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00220000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009e
[    0.000000]     0: 0x00000100 -> 0x000dfe0a
[    0.000000]     0: 0x00100000 -> 0x00220000
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec80000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec80000, GSI 24=
-47
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 8 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: 000000000009e000 - 00000000000=
f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 00000000001=
00000
[    0.000000] PM: Registered nosave memory: 00000000dfe0a000 - 00000000dfe=
0b000
[    0.000000] PM: Registered nosave memory: 00000000dfe0b000 - 00000000dfe=
0c000
[    0.000000] PM: Registered nosave memory: 00000000dfe0c000 - 00000000dfe=
0f000
[    0.000000] PM: Registered nosave memory: 00000000dfe0f000 - 00000000dfe=
5c000
[    0.000000] PM: Registered nosave memory: 00000000dfe5c000 - 00000000dfe=
5d000
[    0.000000] PM: Registered nosave memory: 00000000dfe5d000 - 00000000dfe=
5e000
[    0.000000] PM: Registered nosave memory: 00000000dfe5e000 - 00000000dfe=
5f000
[    0.000000] PM: Registered nosave memory: 00000000dfe5f000 - 00000000f00=
00000
[    0.000000] PM: Registered nosave memory: 00000000f0000000 - 00000000fe0=
00000
[    0.000000] PM: Registered nosave memory: 00000000fe000000 - 00000000ff0=
00000
[    0.000000] PM: Registered nosave memory: 00000000ff000000 - 00000000ffb=
00000
[    0.000000] PM: Registered nosave memory: 00000000ffb00000 - 00000001000=
00000
[    0.000000] Allocating PCI resources starting at f0000000 (gap: f0000000=
:e000000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:8 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 480 pages/cpu @ffff88002f800000 s1933848 r8=
192 d24040 u2097152
[    0.000000] pcpu-alloc: s1933848 r8192 d24040 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 [0] 4 [0] 5 [0] 6 [0] 7=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 2064190
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: ro root=3D/dev/mapper/perihelion-root  =
LANG=3Den_US.UTF-8 SYSFONT=3Dlatarcyrheb-sun16 KEYBOARDTYPE=3Dpc KEYTABLE=
=3Dus console=3Dtty0 console=3DttyS0,115200,8N1 panic=3D30
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 8114888k/8912896k available (4472k kernel code, 5266=
88k absent, 271320k reserved, 6814k data, 3440k init)
[    0.000000] SLUB: Genslabs=3D14, HWalign=3D64, Order=3D0-3, MinObjects=
=3D0, CPUs=3D8, Nodes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU-based detection of stalled CPUs is enabled.
[    0.000000] NR_IRQS:4352 nr_irqs:880
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:             |  ok  |     =
        |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |     =
        |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |     =
        |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |     =
        |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 218 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] allocated 83886080 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] ODEBUG: selftest passed
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2992.805 MHz processor.
[    0.002053] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 5985.61 BogoMIPS (lpj=3D2992805)
[    0.005509] Security Framework initialized
[    0.006024] SELinux:  Initializing.
[    0.015203] Dentry cache hash table entries: 1048576 (order: 11, 8388608=
 bytes)
[    0.026118] Inode-cache hash table entries: 524288 (order: 10, 4194304 b=
ytes)
[    0.030266] Mount-cache hash table entries: 256
[    0.037438] Initializing cgroup subsys ns
[    0.038050] Initializing cgroup subsys cpuacct
[    0.039044] Initializing cgroup subsys memory
[    0.041276] Initializing cgroup subsys devices
[    0.042052] Initializing cgroup subsys freezer
[    0.043025] Initializing cgroup subsys net_cls
[    0.044553] CPU: Physical Processor ID: 0
[    0.045012] CPU: Processor Core ID: 0
[    0.046023] mce: CPU supports 4 MCE banks
[    0.047037] CPU0: Thermal monitoring enabled (TM1)
[    0.048027] using mwait in idle threads.
[    0.049018] Performance Events: no PMU driver, software events only.
[    0.054367] ACPI: Core revision 20091214
[    0.292590] ftrace: converting mcount calls to 0f 1f 44 00 00
[    0.293016] ftrace: allocating 22131 entries in 87 pages
[    0.298438] Setting APIC routing to flat
[    0.300705] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.311890] CPU0: Intel(R) Xeon(TM) CPU 3.00GHz stepping 04
[    0.316420] lockdep: fixing up alternatives.
[    0.318216] Booting Node   0, Processors  #1
[    0.392093] lockdep: fixing up alternatives.
[    0.394122]  #2
[    0.468083] lockdep: fixing up alternatives.
[    0.470072]  #3
[    0.543856] lockdep: fixing up alternatives.
[    0.544201]  #4
[    0.618173] lockdep: fixing up alternatives.
[    0.620197]  #5
[    0.694052] lockdep: fixing up alternatives.
[    0.696045]  #6
[    0.770044] lockdep: fixing up alternatives.
[    0.772099]  #7 Ok.
[    0.845056] Brought up 8 CPUs
[    0.846011] Total of 8 processors activated (47879.47 BogoMIPS).
[    0.861677] regulator: core version 0.5
[    0.862171] Time:  7:06:37  Date: 01/28/10
[    0.864333] NET: Registered protocol family 16
[    0.869379] ACPI FADT declares the system doesn't support PCIe ASPM, so =
disable it
[    0.870057] ACPI: bus type pci registered
[    0.872712] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000=
-0xefffffff] (base 0xe0000000)
[    0.873010] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E82=
0
[    0.881713] PCI: Using configuration type 1 for base access
[    0.930496] bio: create slab <bio-0> at 0
[    1.286144] ACPI: BIOS _OSI(Linux) query ignored
[    1.341229] ACPI: Interpreter enabled
[    1.342012] ACPI: (supports S0 S1 S3 S4 S5)
[    1.346920] ACPI: Using IOAPIC for interrupt routing
[    1.847920] ACPI Warning: Incorrect checksum in table [TCPA] - 00, shoul=
d be 88 (20091214/tbutils-314)
[    1.860643] ACPI: No dock devices found.
[    1.887924] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    1.889958] pci_root PNP0A03:00: ignoring host bridge windows from ACPI;=
 boot with "pci=3Duse_crs" to use them
[    1.941008] pci 0000:01:00.0: disabling ASPM on pre-1.1 PCIe device.  Yo=
u can enable it with 'pcie_aspm=3Dforce'
[    1.942201] pci 0000:00:02.0: PCI bridge to [bus 01-05]
[    1.945199] pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe device.  Yo=
u can enable it with 'pcie_aspm=3Dforce'
[    1.946321] pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe device.  Yo=
u can enable it with 'pcie_aspm=3Dforce'
[    1.947192] pci 0000:01:00.0: PCI bridge to [bus 02-04]
[    1.948271] pci 0000:02:00.0: PCI bridge to [bus 03-03]
[    1.949284] pci 0000:02:01.0: PCI bridge to [bus 04-04]
[    1.951298] pci 0000:01:00.3: PCI bridge to [bus 05-05]
[    1.952308] pci 0000:00:03.0: PCI bridge to [bus 06-06]
[    1.954175] pci 0000:07:00.0: disabling ASPM on pre-1.1 PCIe device.  Yo=
u can enable it with 'pcie_aspm=3Dforce'
[    1.955190] pci 0000:00:04.0: PCI bridge to [bus 07-07]
[    1.956296] pci 0000:00:05.0: PCI bridge to [bus 08-08]
[    1.958035] pci 0000:00:06.0: PCI bridge to [bus 09-09]
[    1.959275] pci 0000:00:07.0: PCI bridge to [bus 0a-0a]
[    1.960509] pci 0000:0b:00.0: disabling ASPM on pre-1.1 PCIe device.  Yo=
u can enable it with 'pcie_aspm=3Dforce'
[    1.962071] pci 0000:00:1c.0: PCI bridge to [bus 0b-0b]
[    1.964059] pci 0000:00:1e.0: PCI bridge to [bus 0c-0c] (subtractive dec=
ode)
[    8.393743] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 =
15)
[    8.404774] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 9 10 11 12 =
15)
[    8.416902] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 9 10 11 12 =
15)
[    8.429127] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 1=
5) *0, disabled.
[    8.441464] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 *9 10 11 12 =
15)
[    8.452487] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 *10 11 12 =
15)
[    8.463498] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 *9 10 11 12 =
15)
[    8.474531] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 *10 11 12 =
15)
[    8.485937] vgaarb: device added: PCI:0000:07:00.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    8.494105] vgaarb: loaded
[    8.501013] SCSI subsystem initialized
[    8.512536] usbcore: registered new interface driver usbfs
[    8.518435] usbcore: registered new interface driver hub
[    8.524304] usbcore: registered new device driver usb
[    8.532269] PCI: Using ACPI for IRQ routing
[    8.541469] NetLabel: Initializing
[    8.545009] NetLabel:  domain hash size =3D 128
[    8.549009] NetLabel:  protocols =3D UNLABELED CIPSOv4
[    8.555181] NetLabel:  unlabeled traffic allowed by default
[    8.562860] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    8.570032] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    8.575347] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    8.587488] Switching to clocksource tsc
[    8.594653] kstop/0 used greatest stack depth: 6392 bytes left
[    9.042274] pnp: PnP ACPI init
[    9.045769] ACPI: bus type pnp registered
[    9.222956] pnp: PnP ACPI: found 10 devices
[    9.227832] ACPI: ACPI bus type pnp unregistered
[    9.233179] system 00:01: [io  0x0800-0x085f] has been reserved
[    9.239315] system 00:01: [io  0x0c00-0x0c7f] has been reserved
[    9.245436] system 00:01: [io  0x0860-0x08ff] has been reserved
[    9.261962] pci 0000:02:00.0: PCI bridge to [bus 03-03]
[    9.267372] pci 0000:02:00.0:   bridge window [io  disabled]
[    9.273227] pci 0000:02:00.0:   bridge window [mem disabled]
[    9.279070] pci 0000:02:00.0:   bridge window [mem pref disabled]
[    9.285356] pci 0000:02:01.0: PCI bridge to [bus 04-04]
[    9.290759] pci 0000:02:01.0:   bridge window [io  disabled]
[    9.296606] pci 0000:02:01.0:   bridge window [mem disabled]
[    9.302451] pci 0000:02:01.0:   bridge window [mem pref disabled]
[    9.308736] pci 0000:01:00.0: PCI bridge to [bus 02-04]
[    9.314141] pci 0000:01:00.0:   bridge window [io  disabled]
[    9.319988] pci 0000:01:00.0:   bridge window [mem disabled]
[    9.325832] pci 0000:01:00.0:   bridge window [mem pref disabled]
[    9.332116] pci 0000:01:00.3: PCI bridge to [bus 05-05]
[    9.337520] pci 0000:01:00.3:   bridge window [io  disabled]
[    9.346329] pci 0000:01:00.3:   bridge window [mem disabled]
[    9.352171] pci 0000:01:00.3:   bridge window [mem pref disabled]
[    9.358457] pci 0000:00:02.0: PCI bridge to [bus 01-05]
[    9.363863] pci 0000:00:02.0:   bridge window [io  disabled]
[    9.369714] pci 0000:00:02.0:   bridge window [mem 0xfcc00000-0xfccfffff=
]
[    9.376687] pci 0000:00:02.0:   bridge window [mem pref disabled]
[    9.382971] pci 0000:00:03.0: PCI bridge to [bus 06-06]
[    9.388373] pci 0000:00:03.0:   bridge window [io  disabled]
[    9.394219] pci 0000:00:03.0:   bridge window [mem 0xfca00000-0xfcafffff=
]
[    9.401205] pci 0000:00:03.0:   bridge window [mem pref disabled]
[    9.407491] pci 0000:00:04.0: PCI bridge to [bus 07-07]
[    9.412898] pci 0000:00:04.0:   bridge window [io  0xd000-0xdfff]
[    9.419178] pci 0000:00:04.0:   bridge window [mem 0xfcd00000-0xfcefffff=
]
[    9.426152] pci 0000:00:04.0:   bridge window [mem 0xf0000000-0xf7ffffff=
 64bit pref]
[    9.434205] pci 0000:00:05.0: PCI bridge to [bus 08-08]
[    9.439609] pci 0000:00:05.0:   bridge window [io  disabled]
[    9.445455] pci 0000:00:05.0:   bridge window [mem disabled]
[    9.451300] pci 0000:00:05.0:   bridge window [mem pref disabled]
[    9.457583] pci 0000:00:06.0: PCI bridge to [bus 09-09]
[    9.462987] pci 0000:00:06.0:   bridge window [io  disabled]
[    9.468833] pci 0000:00:06.0:   bridge window [mem disabled]
[    9.474671] pci 0000:00:06.0:   bridge window [mem pref disabled]
[    9.480957] pci 0000:00:07.0: PCI bridge to [bus 0a-0a]
[    9.486360] pci 0000:00:07.0:   bridge window [io  disabled]
[    9.492216] pci 0000:00:07.0:   bridge window [mem disabled]
[    9.498063] pci 0000:00:07.0:   bridge window [mem pref disabled]
[    9.504343] pci 0000:00:1c.0: PCI bridge to [bus 0b-0b]
[    9.509748] pci 0000:00:1c.0:   bridge window [io  disabled]
[    9.515595] pci 0000:00:1c.0:   bridge window [mem 0xfc900000-0xfc9fffff=
]
[    9.522567] pci 0000:00:1c.0:   bridge window [mem pref disabled]
[    9.528852] pci 0000:00:1e.0: PCI bridge to [bus 0c-0c]
[    9.534255] pci 0000:00:1e.0:   bridge window [io  disabled]
[    9.540105] pci 0000:00:1e.0:   bridge window [mem 0xfcb00000-0xfcbfffff=
]
[    9.547078] pci 0000:00:1e.0:   bridge window [mem pref disabled]
[    9.553485] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.560405] pci 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.567320] pci 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.574239] pci 0000:02:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.581178] pci 0000:00:03.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.588088] pci 0000:00:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.595000] pci 0000:00:05.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.601911] pci 0000:00:06.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.608821] pci 0000:00:07.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.615735] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.623157] NET: Registered protocol family 2
[    9.630068] IP route cache hash table entries: 262144 (order: 9, 2097152=
 bytes)
[    9.647427] TCP established hash table entries: 524288 (order: 11, 83886=
08 bytes)
[    9.664138] TCP bind hash table entries: 65536 (order: 10, 4718592 bytes=
)
[    9.682082] TCP: Hash tables configured (established 524288 bind 65536)
[    9.688956] TCP reno registered
[    9.692787] UDP hash table entries: 4096 (order: 7, 655360 bytes)
[    9.700906] UDP-Lite hash table entries: 4096 (order: 7, 655360 bytes)
[    9.710920] NET: Registered protocol family 1
[    9.716565] pci 0000:00:1f.0: rerouting interrupts for [8086:2670]
[    9.724893] Trying to unpack rootfs image as initramfs...
[   11.285752] debug: unmapping init memory ffff8800362df000..ffff880037ff0=
000
[   11.610806] DMA-API: preallocated 32768 debug entries
[   11.616037] DMA-API: debugging enabled by kernel config
[   11.621449] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[   11.628063] Placing 64MB software IO TLB between ffff880020000000 - ffff=
880024000000
[   11.636087] software IO TLB at phys 0x20000000 - 0x24000000
[   11.642339] Simple Boot Flag at 0x7a set to 0x80
[   11.669993] audit: initializing netlink socket (disabled)
[   11.676120] type=3D2000 audit(1264662404.675:1): initialized
[   11.696539] Kprobe smoke test started
[   11.746565] Kprobe smoke test passed successfully
[   11.754077] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   11.866855] VFS: Disk quotas dquot_6.5.2
[   11.872314] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   11.888983] EXT4-fs: Unable to register as ext3 (-16)
[   11.906076] msgmni has been set to 15849
[   11.919711] cryptomgr_test used greatest stack depth: 5688 bytes left
[   11.921516] alg: No test for stdrng (krng)
[   11.923663] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 252)
[   11.923705] io scheduler noop registered
[   11.923711] io scheduler deadline registered
[   11.926688] io scheduler cfq registered (default)
[   11.951620] cryptomgr_test used greatest stack depth: 5624 bytes left
[   11.958399] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   11.965128] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[   11.971929] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[   11.993172] pci-stub: invalid id string ""
[   12.002016] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0=
C0C:00/input/input0
[   12.010735] ACPI: Power Button [VBTN]
[   12.015812] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input1
[   12.023515] ACPI: Power Button [PWRF]
[   12.563182] Non-volatile memory driver v1.3
[   12.567773] Linux agpgart interface v0.103
[   12.573763] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
=FF[   12.825267] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[   13.076290] serial8250: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
[   13.085634] 00:07: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[   13.092801] 00:08: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
[   13.131535] brd: module loaded
[   13.150377] loop: module loaded
[   13.154533] input: Macintosh mouse button emulation as /devices/virtual/=
input/input2
[   13.165887] ahci 0000:00:1f.2: PCI INT C -> GSI 20 (level, low) -> IRQ 2=
0
[   13.174090] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x=
1f impl SATA mode
[   13.182559] ahci 0000:00:1f.2: flags: 64bit ncq pm led slum part=20
[   13.190424] scsi0 : ahci
[   13.198266] scsi1 : ahci
[   13.202644] scsi2 : ahci
[   13.207193] scsi3 : ahci
[   13.211581] scsi4 : ahci
[   13.216115] scsi5 : ahci
[   13.220145] ata1: SATA max UDMA/133 irq_stat 0x00400040, connection stat=
us changed irq 20
[   13.228615] ata2: SATA max UDMA/133 irq_stat 0x00400040, connection stat=
us changed irq 20
[   13.237088] ata3: SATA max UDMA/133 abar m1024@0xff970000 port 0xff97020=
0 irq 20
[   13.244770] ata4: SATA max UDMA/133 abar m1024@0xff970000 port 0xff97028=
0 irq 20
[   13.252462] ata5: SATA max UDMA/133 abar m1024@0xff970000 port 0xff97030=
0 irq 20
[   13.260154] ata6: DUMMY
[   13.263731] ata_piix 0000:00:1f.1: PCI INT A -> GSI 16 (level, low) -> I=
RQ 16
[   13.272408] scsi6 : ata_piix
[   13.277027] scsi7 : ata_piix
[   13.281239] ata7: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq=
 14
[   13.288385] ata8: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq=
 15
[   13.297171] Fixed MDIO Bus: probed
[   13.301947] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   13.308964] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 21 (level, low) -> I=
RQ 21
[   13.316507] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[   13.324380] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus =
number 1
[   13.332534] ehci_hcd 0000:00:1d.7: debug port 1
[   13.341393] ehci_hcd 0000:00:1d.7: irq 21, io mem 0xff980800
[   13.356122] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[   13.363188] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[   13.370160] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   13.377671] usb usb1: Product: EHCI Host Controller
[   13.382728] usb usb1: Manufacturer: Linux 2.6.33-rc5 ehci_hcd
[   13.388654] usb usb1: SerialNumber: 0000:00:1d.7
[   13.396151] hub 1-0:1.0: USB hub found
[   13.400331] hub 1-0:1.0: 8 ports detected
[   13.407070] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   13.413798] uhci_hcd: USB Universal Host Controller Interface driver
[   13.421709] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 21 (level, low) -> I=
RQ 21
[   13.429129] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   13.435586] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus =
number 2
[   13.443502] uhci_hcd 0000:00:1d.0: irq 21, io base 0x0000ff80
[   13.450422] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[   13.457394] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   13.464903] usb usb2: Product: UHCI Host Controller
[   13.469966] usb usb2: Manufacturer: Linux 2.6.33-rc5 uhci_hcd
[   13.470941] ata7.00: ATAPI: SONY CD-RW/DVD-ROM CRX310EE, SDK3, max UDMA/=
33
[   13.482914] usb usb2: SerialNumber: 0000:00:1d.0
[   13.489741] hub 2-0:1.0: USB hub found
[   13.493996] hub 2-0:1.0: 2 ports detected
[   13.499831] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 22 (level, low) -> I=
RQ 22
[   13.502410] ata7.00: configured for UDMA/33
[   13.512265] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   13.518936] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus =
number 3
[   13.527047] uhci_hcd 0000:00:1d.1: irq 22, io base 0x0000ff60
[   13.534100] usb usb3: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[   13.541113] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   13.548630] usb usb3: Product: UHCI Host Controller
[   13.553693] usb usb3: Manufacturer: Linux 2.6.33-rc5 uhci_hcd
[   13.559616] usb usb3: SerialNumber: 0000:00:1d.1
[   13.566500] hub 3-0:1.0: USB hub found
[   13.570640] hub 3-0:1.0: 2 ports detected
[   13.576432] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> I=
RQ 18
[   13.583822] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   13.587108] ata3: SATA link down (SStatus 0 SControl 300)
[   13.587161] ata5: SATA link down (SStatus 4 SControl 300)
[   13.587207] ata4: SATA link down (SStatus 0 SControl 300)
[   13.609902] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus =
number 4
[   13.617975] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000ff40
[   13.624905] usb usb4: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[   13.631868] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   13.639379] usb usb4: Product: UHCI Host Controller
[   13.644440] usb usb4: Manufacturer: Linux 2.6.33-rc5 uhci_hcd
[   13.650363] usb usb4: SerialNumber: 0000:00:1d.2
[   13.657693] hub 4-0:1.0: USB hub found
[   13.661870] hub 4-0:1.0: 2 ports detected
[   13.667605] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 23 (level, low) -> I=
RQ 23
[   13.675008] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[   13.681761] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus =
number 5
[   13.689800] uhci_hcd 0000:00:1d.3: irq 23, io base 0x0000ff20
[   13.696746] usb usb5: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[   13.703712] usb usb5: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   13.711294] usb usb5: Product: UHCI Host Controller
[   13.716353] usb usb5: Manufacturer: Linux 2.6.33-rc5 uhci_hcd
[   13.722278] usb usb5: SerialNumber: 0000:00:1d.3
[   13.722611] usb 1-1: new high speed USB device using ehci_hcd and addres=
s 2
[   13.736258] hub 5-0:1.0: USB hub found
[   13.740419] hub 5-0:1.0: 2 ports detected
[   13.747415] PNP: No PS/2 controller found. Probing ports directly.
[   13.757468] serio: i8042 KBD port at 0x60,0x64 irq 1
[   13.762739] serio: i8042 AUX port at 0x60,0x64 irq 12
[   13.769699] mice: PS/2 mouse device common for all mice
[   13.778128] rtc_cmos 00:05: RTC can wake from S4
[   13.784109] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
[   13.790491] rtc0: alarms up to one day, 242 bytes nvram, hpet irqs
[   13.802928] device-mapper: uevent: version 1.0.3
[   13.810967] device-mapper: ioctl: 4.16.0-ioctl (2009-11-05) initialised:=
 dm-devel@redhat.com
[   13.824820] cpuidle: using governor ladder
[   13.829100] cpuidle: using governor menu
[   13.839299] usb 1-1: New USB device found, idVendor=3D03f0, idProduct=3D=
5611
[   13.843346] usbcore: registered new interface driver hiddev
[   13.843767] usbcore: registered new interface driver usbhid
[   13.843770] usbhid: USB HID core driver
[   13.843824] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   13.846719] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Pl=
ease use
[   13.846722] nf_conntrack.acct=3D1 kernel parameter, acct=3D1 nf_conntrac=
k module option or
[   13.846724] sysctl net.netfilter.nf_conntrack_acct=3D1 to enable it.
[   13.850876] ip_tables: (C) 2000-2006 Netfilter Core Team
[   13.851069] TCP cubic registered
[   13.851077] NET: Registered protocol family 17
[   13.853467] registered taskstats version 1
[   13.854964] kmemleak: Kernel memory leak detector initialized
[   13.854973] kmemleak: Automatic memory scanning thread started
[   13.856059] No TPM chip found, activating TPM-bypass!
[   13.862227]   Magic number: 10:876:117
[   13.928661] rtc_cmos 00:05: setting system clock to 2010-01-28 07:06:51 =
UTC (1264662411)
[   13.928681] usb 1-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D3
[   13.928686] usb 1-1: Product: Photosmart C3100 series
[   13.928688] usb 1-1: Manufacturer: HP
[   13.928691] usb 1-1: SerialNumber: CN6B6C51NZ04KV
[   13.959768] Initalizing network drop monitor service
[   13.987119] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[   13.993600] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[   14.027546] ata2.00: ATA-8: ST31500341AS, CC1H, max UDMA/133
[   14.028831] ata1.00: ATA-8: ST31500341AS, CC1H, max UDMA/133
[   14.028838] ata1.00: 2930277168 sectors, multi 0: LBA48 NCQ (depth 31/32=
)
[   14.038153] usb 1-4: new high speed USB device using ehci_hcd and addres=
s 3
[   14.053239] ata2.00: 2930277168 sectors, multi 0: LBA48 NCQ (depth 31/32=
)
[   14.070802] ata1.00: configured for UDMA/133
[   14.088394] scsi 0:0:0:0: Direct-Access     ATA      ST31500341AS     CC=
1H PQ: 0 ANSI: 5
[   14.101262] sd 0:0:0:0: [sda] 2930277168 512-byte logical blocks: (1.50 =
TB/1.36 TiB)
[   14.102016] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   14.114834] ata2.00: configured for UDMA/133
[   14.116193] sd 0:0:0:0: [sda] Write Protect is off
[   14.116759] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[   14.120723]  sda: sda1 sda2
[   14.141206] sd 0:0:0:0: [sda] Attached SCSI disk
[   14.148771] scsi 1:0:0:0: Direct-Access     ATA      ST31500341AS     CC=
1H PQ: 0 ANSI: 5
[   14.158456] usb 1-4: New USB device found, idVendor=3D058f, idProduct=3D=
6254
[   14.160551] sd 1:0:0:0: [sdb] 2930277168 512-byte logical blocks: (1.50 =
TB/1.36 TiB)
[   14.161344] sd 1:0:0:0: Attached scsi generic sg1 type 0
[   14.162744] sd 1:0:0:0: [sdb] Write Protect is off
[   14.163688] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[   14.165644] scsi 6:0:0:0: CD-ROM            SONY     CDRWDVD CRX310EE SD=
K3 PQ: 0 ANSI: 5
[   14.169153]  sdb:
[   14.203599]  sdb1
[   14.203706] usb 1-4: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[   14.206918] hub 1-4:1.0: USB hub found
[   14.207338] hub 1-4:1.0: 4 ports detected
[   14.221317]  sdb2
[   14.225373] sr0: scsi3-mmc drive: 0x/48x writer cd/rw xa/form2 cdda tray
[   14.231036] sd 1:0:0:0: [sdb] Attached SCSI disk
[   14.237103] Uniform CD-ROM driver Revision: 3.20
[   14.246417] sr 6:0:0:0: Attached scsi generic sg2 type 5
[   14.252771] debug: unmapping init memory ffffffff81b07000..ffffffff81e63=
000
[   14.260243] Write protecting the kernel read-only data: 10240k
[   14.266627] debug: unmapping init memory ffff880001463000..ffff880001600=
000
[   14.273923] debug: unmapping init memory ffff880001827000..ffff880001a00=
000
[   14.298106] mknod used greatest stack depth: 5392 bytes left
[   14.318984] mount used greatest stack depth: 4976 bytes left
[   14.339171] mount used greatest stack depth: 4752 bytes left
[   14.375257] usb 1-6: new high speed USB device using ehci_hcd and addres=
s 5
[   14.490494] dracut: dracut-002-13.4.git8f397a9b.fc12
dracut: dracut-002-13.4.git8f397a9b.fc12
[   14.507933] usb 1-6: New USB device found, idVendor=3D05ac, idProduct=3D=
1006
[   14.514828] usb 1-6: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D3
[   14.522157] usb 1-6: Product: Keyboard Hub
[   14.526461] usb 1-6: Manufacturer: Apple, Inc.
[   14.531114] usb 1-6: SerialNumber: 000000000000
[   14.539311] hub 1-6:1.0: USB hub found
[   14.543842] hub 1-6:1.0: 3 ports detected
[   14.587982] udev: starting version 145
[   14.758178] usb 4-1: new low speed USB device using uhci_hcd and address=
 2
[   14.931185] usb 4-1: New USB device found, idVendor=3D046d, idProduct=3D=
c03d
[   14.938081] usb 4-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D0
[   14.945393] usb 4-1: Product: USB-PS/2 Optical Mouse
[   14.950534] usb 4-1: Manufacturer: Logitech
[   14.981265] input: Logitech USB-PS/2 Optical Mouse as /devices/pci0000:0=
0/0000:00:1d.2/usb4/4-1/4-1:1.0/input/input3
[   14.996766] generic-usb 0003:046D:C03D.0001: input,hidraw0: USB HID v1.1=
0 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:1d.2-1/input0
[   15.093753] usb 1-4.1: new low speed USB device using ehci_hcd and addre=
ss 6
[   15.159458] async/0 used greatest stack depth: 4272 bytes left
[   15.166985] [drm] Initialized drm 1.1.0 20060810
[   15.211644] usb 1-4.1: New USB device found, idVendor=3D0764, idProduct=
=3D0501
[   15.218741] usb 1-4.1: New USB device strings: Mfr=3D3, Product=3D1, Ser=
ialNumber=3D0
[   15.226363] usb 1-4.1: Product: UPS AE550
[   15.230540] async/8 used greatest stack depth: 4008 bytes left
[   15.230558] usb 1-4.1: Manufacturer: CPS
[   15.253310] async/6 used greatest stack depth: 3992 bytes left
[   15.293139] generic-usb 0003:0764:0501.0002: hiddev96,hidraw1: USB HID v=
1.10 Device [CPS UPS AE550] on usb-0000:00:1d.7-4.1/input0
[   15.384441] usb 1-4.2: new full speed USB device using ehci_hcd and addr=
ess 7
[   15.426966] [drm] radeon defaulting to kernel modesetting.
[   15.432631] [drm] radeon kernel modesetting enabled.
[   15.438132] radeon 0000:07:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ=
 16
[   15.455185] [drm] radeon: Initializing kernel modesetting.
[   15.464889] [drm] register mmio base: 0xFCDE0000
[   15.469683] [drm] register mmio size: 65536
[   15.474363] [drm] GPU reset succeed (RBBM_STATUS=3D0x00000140)
[   15.480579] [drm] Generation 2 PCI interface, using max accessible memor=
y
[   15.482525] usb 1-4.2: New USB device found, idVendor=3D058f, idProduct=
=3D9254
[   15.482531] usb 1-4.2: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D0
[   15.482535] usb 1-4.2: Product: Generic USB Hub
[   15.482538] usb 1-4.2: Manufacturer: ALCOR
[   15.485162] hub 1-4.2:1.0: USB hub found
[   15.485662] hub 1-4.2:1.0: 4 ports detected
[   15.519525] [drm] radeon: VRAM 128M
[   15.523193] [drm] radeon: VRAM from 0x00000000 to 0x07FFFFFF
[   15.529033] [drm] radeon: GTT 512M
[   15.532615] [drm] radeon: GTT from 0x20000000 to 0x3FFFFFFF
[   15.539048] [drm] radeon: using MSI.
[   15.543214] [drm] radeon: irq initialized.
[   15.547639] mtrr: type mismatch for f0000000,8000000 old: write-back new=
: write-combining
[   15.556119] [drm] Detected VRAM RAM=3D128M, BAR=3D128M
[   15.561082] [drm] RAM width 64bits DDR
[   15.566448] [TTM] Zone  kernel: Available graphics memory: 4057444 kiB.
[   15.573237] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[   15.580707] [drm] radeon: 128M of VRAM memory ready
[   15.585778] [drm] radeon: 512M of GTT memory ready.
[   15.591485] [drm] GART: num cpu pages 131072, num gpu pages 131072
[   15.598655] usb 1-4.3: new full speed USB device using ehci_hcd and addr=
ess 8
[   15.600136] [drm] radeon: 1 quad pipes, 1 Z pipes initialized.
[   15.600321] [drm] PCIE GART of 512M enabled (table at 0x00040000).
[   15.601018] [drm] radeon: cp idle (0x10000C03)
[   15.601722] [drm] Loading R300 Microcode
[   15.602420] platform radeon_cp.0: firmware: requesting radeon/R300_cp.bi=
n
[   15.642662] [drm] radeon: ring at 0x0000000020000000
[   15.651308] [drm] ring test succeeded in 0 usecs
[   15.661198] [drm] radeon: ib pool ready.
[   15.670020] [drm] ib test succeeded in 0 usecs
[   15.675885] [drm] DFP table revision: 4
[   15.681840] [drm] Default TV standard: NTSC
[   15.686240] [drm] 27.000000000 MHz TV ref clk
[   15.690899] [drm] Default TV standard: NTSC
[   15.695324] [drm] 27.000000000 MHz TV ref clk
[   15.700752] [drm] Radeon Display Connectors
[   15.705192] [drm] Connector 0:
[   15.708513] [drm]   DVI-I
[   15.711305] [drm]   HPD1
[   15.714008] [drm]   DDC: 0x60 0x60 0x60 0x60 0x60 0x60 0x60 0x60
[   15.720222] [drm]   Encoders:
[   15.723434] [drm]     CRT1: INTERNAL_DAC1
[   15.723494] usb 1-4.3: New USB device found, idVendor=3D046d, idProduct=
=3D092e
[   15.723499] usb 1-4.3: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D0
[   15.723503] usb 1-4.3: Product: Camera
[   15.723505] usb 1-4.3: Manufacturer:        =20
[   15.750650] [drm]     DFP1: INTERNAL_TMDS1
[   15.754921] [drm] Connector 1:
[   15.758159] [drm]   S-video
[   15.761133] [drm]   Encoders:
[   15.764280] [drm]     TV1: INTERNAL_DAC2
[   15.802275] usb 1-4.4: new full speed USB device using ehci_hcd and addr=
ess 9
[   15.897670] usb 1-4.4: New USB device found, idVendor=3D093a, idProduct=
=3D2620
[   15.904734] usb 1-4.4: New USB device strings: Mfr=3D0, Product=3D0, Ser=
ialNumber=3D0
[   15.981543] usb 1-6.2: new low speed USB device using ehci_hcd and addre=
ss 10
[   16.071956] usb 1-6.2: New USB device found, idVendor=3D05ac, idProduct=
=3D0220
[   16.079035] usb 1-6.2: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D0
[   16.086626] usb 1-6.2: Product: Apple Keyboard
[   16.091240] usb 1-6.2: Manufacturer: Apple, Inc
[   16.104842] [drm] fb mappable at 0xF00C0000
[   16.109231] [drm] vram apper at 0xF0000000
[   16.111548] input: Apple, Inc Apple Keyboard as /devices/pci0000:00/0000=
:00:1d.7/usb1/1-6/1-6.2/1-6.2:1.0/input/input4
[   16.114658] apple 0003:05AC:0220.0003: input,hidraw2: USB HID v1.11 Keyb=
oard [Apple, Inc Apple Keyboard] on usb-0000:00:1d.7-6.2/input0
[   16.137041] [drm] size 9437184
[   16.140288] [drm] fb depth is 24
[   16.142457] input: Apple, Inc Apple Keyboard as /devices/pci0000:00/0000=
:00:1d.7/usb1/1-6/1-6.2/1-6.2:1.1/input/input5
[   16.144642] apple 0003:05AC:0220.0004: input,hidraw3: USB HID v1.11 Devi=
ce [Apple, Inc Apple Keyboard] on usb-0000:00:1d.7-6.2/input1
[   16.166912] [drm]    pitch is 8192
[   16.237970] Console: switching to colour frame buffer device 256x72
[   16.254545] fb0: radeondrmfb frame buffer device
[   16.259218] registered panic notifier
[   16.262982] [drm] Initialized radeon 2.0.0 20080528 for 0000:07:00.0 on =
minor 0
[   16.304799] modprobe used greatest stack depth: 3520 bytes left
[   16.408800] dracut: Starting plymouth daemon
dracut: Starting plymouth daemon
[   16.960209] Initializing USB Mass Storage driver...
[   16.967166] scsi8 : usb-storage 1-1:1.3
[   16.978028] usbcore: registered new interface driver usb-storage
[   16.985498] USB Mass Storage support registered.
G[   17.548517] dracut: Autoassembling MD Raid
dracut: Autoassembling MD Raid
[   17.759858] md: md0 stopped.
[   17.773474] md: bind<sdb2>
[   17.778203] md: bind<sda2>
[   17.802409] md: raid1 personality registered for level 1
[   17.824901] raid1: md0 is not clean -- starting background reconstructio=
n
[   17.832467] raid1: raid set md0 active with 2 out of 2 mirrors
[   17.840349] md0: detected capacity change from 0 to 1499225456640
[   17.847917] dracut: mdadm: /dev/md0 has been started with 2 drives.
[   17.849228] md: resync of RAID array md0
[   17.849241] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[   17.849250] md: using maximum available idle IO bandwidth (but not more =
than 200000 KB/sec) for resync.
[   17.849270] md: using 128k window, over a total of 1464087360 blocks.
[   17.849285] md: resuming resync of md0 from checkpoint.
[   17.860798]  md0:dracut: mdadm: /dev/md0 has been started with 2 drives.
 unknown partition table
[   18.534223] dracut: Scanning devices md0  for LVM volume groups=20
dracut: Scanning devices md0  for LVM volume groups=20
[   18.654993] dracut: Reading all physical volumes. This may take a while.=
..
[   18.662436] dracut: Found volume group "perihelion" using metadata type =
lvm2
dracut: Reading all physical volumes. This may take a while...
dracut: Found volume group "perihelion" using metadata type lvm2
[   19.048719] dracut: 3 logical volume(s) in volume group "perihelion" now=
 active
dracut: 3 logical volume(s) in volume group "perihelion" now active
[   19.863939] EXT4-fs (dm-0): mounted filesystem with ordered data mode
[   19.954458] dracut: Mounted root filesystem /dev/mapper/perihelion-root
dracut: Mounted root filesystem /dev/mapper/perihelion-root
[   20.201613] dracut: Loading SELinux policy
dracut: Loading SELinux policy
[   21.997409] scsi 8:0:0:0: Direct-Access     HP       Photosmart C3180 1.=
00 PQ: 0 ANSI: 2
[   22.026999] sd 8:0:0:0: Attached scsi generic sg3 type 0
[   22.038248] sd 8:0:0:0: [sdc] Attached SCSI removable disk
[   33.681227] type=3D1403 audit(1264662431.317:2): policy loaded auid=3D42=
94967295 ses=3D4294967295
[   33.700862] load_policy used greatest stack depth: 3072 bytes left
[   34.194006] dracut: Switching root
dracut: Switching root
		Welcome to Fedora=20
		Press 'I' to enter interactive startup.
Starting udev: G[  OK  ]
Setting hostname perihelion.bos.jonmasters.org:  [  OK  ]
Setting up Logical Volume Management:   3 logical volume(s) in volume group=
 "perihelion" now active
[  OK  ]
Checking filesystems
Checking all file systems.
[/sbin/fsck.ext4 (1) -- /] fsck.ext4 -a /dev/mapper/perihelion-root=20
/dev/mapper/perihelion-root: clean, 828101/22405120 files, 36863454/8960000=
0 blocks
[/sbin/fsck.ext4 (1) -- /boot] fsck.ext4 -a /dev/sda1=20
[/sbin/fsck.ext4 (2) -- /boot1] fsck.ext4 -a /dev/sdb1=20
/dev/sdb1: clean, 11/65536 files, 12635/262144 blocks
/dev/sda1: clean, 54/65536 files, 58714/262144 blocks
[/sbin/fsck.ext4 (1) -- /data] fsck.ext4 -a /dev/mapper/perihelion-data=20
/dev/mapper/perihelion-data: clean, 1558379/65536000 files, 96448353/262144=
000 blocks
[  OK  ]
Remounting root filesystem in read-write mode:  [  OK  ]
Mounting local filesystems:  [  OK  ]
Enabling local filesystem quotas:  [  OK  ]
Enabling /etc/fstab swaps:  [  OK  ]
Entering non-interactive startup
Applying Intel CPU microcode update: FATAL: Module microcode not found.
ERROR: Module microcode does not exist in /proc/modules
Calling the system activity data collector (sadc):=20
Starting monitoring for VG perihelion:   3 logical volume(s) in volume grou=
p "perihelion" monitored
[  OK  ]
Bringing up loopback interface:  [  OK  ]
Bringing up interface eth0:  [  OK  ]
Bringing up interface br0:  [  OK  ]
Starting auditd: [  OK  ]
Starting portreserve: [  OK  ]
Starting system logger: [  OK  ]
Enabling ondemand cpu frequency scaling: [  OK  ]
Starting irqbalance: [  OK  ]
Starting rpcbind: [  OK  ]
Starting NFS statd: [  OK  ]
Starting mdmonitor: [  OK  ]
Starting RPC idmapd: [  OK  ]
Starting system message bus: [  OK  ]
Starting Avahi daemon... [  OK  ]
Starting cups: [  OK  ]
Mounting other filesystems:  [  OK  ]
Starting acpi daemon: [  OK  ]
Starting HAL daemon: [  OK  ]
Starting PC/SC smart card daemon (pcscd): [  OK  ]
Loading autofs4: [  OK  ]
Starting automount: [  OK  ]
Starting NFS services:  exportfs: Warning: /mnt/remote does not exist
[  OK  ]
Starting NFS quotas: [  OK  ]
Starting NFS daemon: [  OK  ]
Starting NFS mountd: [  OK  ]
Starting snort: [FAILED]
Enabling Bluetooth devices:
Starting sshd: [  OK  ]
Starting ntpd: [  OK  ]
Starting vsftpd for vsftpd: [  OK  ]
Starting exim: [  OK  ]
Starting abrt daemon: [  OK  ]
Starting ksm: /etc/rc5.d/S84ksm: line 44: /sys/kernel/mm/ksm/max_kernel_pag=
es: No such file or directory
[  OK  ]
Starting console mouse services: [  OK  ]
Starting ksmtuned: [  OK  ]
Starting crond: [  OK  ][  OK  ]
Starting atd: [  OK  ][  OK  ]
Registering binary handler for Windows applications: [  OK  ]
Starting smartd: [  OK  ]

Fedora release 12 (Constantine)
Kernel 2.6.33-rc5 on an x86_64 (/dev/ttyS0)

perihelion.bos.jonmasters.org login: [  205.843071]=20
[  205.843073] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  205.843769] [ INFO: possible circular locking dependency detected ]
[  205.843769] 2.6.33-rc5 #3
[  205.843769] -------------------------------------------------------
[  205.843769] libvirtd/3058 is trying to acquire lock:
[  205.843769]  (s_active){++++.+}, at: [<ffffffff81171a56>] sysfs_addrm_fi=
nish+0x36/0x55
[  205.843769]=20
[  205.843769] but task is already holding lock:
[  205.843769]  (rtnl_mutex){+.+.+.}, at: [<ffffffff813cedd9>] rtnl_lock+0x=
17/0x19
[  205.843769]=20
[  205.843769] which lock already depends on the new lock.
[  205.843769]=20
[  205.843769]=20
[  205.843769] the existing dependency chain (in reverse order) is:
[  205.843769]=20
[  205.843769] -> #4 (rtnl_mutex){+.+.+.}:
[  205.843769]        [<ffffffff8107ea94>] __lock_acquire+0xb84/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff8145504b>] __mutex_lock_common+0x4b/0x392
[  205.843769]        [<ffffffff81455456>] mutex_lock_nested+0x3e/0x43
[  205.843769]        [<ffffffff813cedd9>] rtnl_lock+0x17/0x19
[  205.843769]        [<ffffffff813d05c0>] linkwatch_event+0xe/0x2c
[  205.843769]        [<ffffffff8106713f>] worker_thread+0x266/0x35f
[  205.843769]        [<ffffffff8106b1d0>] kthread+0x9a/0xa2
[  205.843769]        [<ffffffff8100aaa4>] kernel_thread_helper+0x4/0x10
[  205.843769]=20
[  205.843769] -> #3 ((linkwatch_work).work){+.+.+.}:
[  205.843769]        [<ffffffff8107ea94>] __lock_acquire+0xb84/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff81067136>] worker_thread+0x25d/0x35f
[  205.843769]        [<ffffffff8106b1d0>] kthread+0x9a/0xa2
[  205.843769]        [<ffffffff8100aaa4>] kernel_thread_helper+0x4/0x10
[  205.843769]=20
[  205.843769] -> #2 (events){+.+.+.}:
[  205.843769]        [<ffffffff8107ea94>] __lock_acquire+0xb84/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff81067a8b>] flush_workqueue+0x63/0xb1
[  205.843769]        [<ffffffff81067aee>] flush_scheduled_work+0x15/0x17
[  205.843769]        [<ffffffff8138168b>] do_md_stop+0x2c0/0x508
[  205.843769]        [<ffffffff81383b94>] md_ioctl+0x92f/0xf49
[  205.843769]        [<ffffffff8121442d>] __blkdev_driver_ioctl+0x39/0xa3
[  205.843769]        [<ffffffff81214dc8>] blkdev_ioctl+0x67d/0x6b1
[  205.843769]        [<ffffffff8113ef34>] block_ioctl+0x37/0x3b
[  205.843769]        [<ffffffff81126294>] vfs_ioctl+0x32/0xa6
[  205.843769]        [<ffffffff81126814>] do_vfs_ioctl+0x490/0x4d6
[  205.843769]        [<ffffffff811268b0>] sys_ioctl+0x56/0x79
[  205.843769]        [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
[  205.843769]=20
[  205.843769] -> #1 (&new->reconfig_mutex){+.+.+.}:
[  205.843769]        [<ffffffff8107ea94>] __lock_acquire+0xb84/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff8145504b>] __mutex_lock_common+0x4b/0x392
[  205.843769]        [<ffffffff814553d0>] mutex_lock_interruptible_nested+=
0x3e/0x43
[  205.843769]        [<ffffffff8137bd62>] mddev_lock+0x17/0x19
[  205.843769]        [<ffffffff8137c039>] md_attr_show+0x32/0x5d
[  205.843769]        [<ffffffff811708dc>] sysfs_read_file+0xbd/0x17f
[  205.843769]        [<ffffffff8111983d>] vfs_read+0xab/0x108
[  205.843769]        [<ffffffff8111995a>] sys_read+0x4a/0x6e
[  205.843769]        [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
[  205.843769]=20
[  205.843769] -> #0 (s_active){++++.+}:
[  205.843769]        [<ffffffff8107e93e>] __lock_acquire+0xa2e/0xd3c
[  205.843769]        [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]        [<ffffffff81171463>] sysfs_deactivate+0x9a/0x103
[  205.843769]        [<ffffffff81171a56>] sysfs_addrm_finish+0x36/0x55
[  205.843769]        [<ffffffff81171aab>] remove_dir+0x36/0x3e
[  205.843769]        [<ffffffff81171b60>] sysfs_remove_dir+0x9d/0xbe
[  205.843769]        [<ffffffff812206c1>] kobject_del+0x16/0x37
[  205.843769]        [<ffffffff8122078a>] kobject_release+0xa8/0xf8
[  205.843769]        [<ffffffff8122165d>] kref_put+0x43/0x4d
[  205.843769]        [<ffffffff8122063c>] kobject_put+0x47/0x4b
[  205.843769]        [<ffffffffa02d5ef5>] br_sysfs_delbr+0x21/0x43 [bridge=
]
[  205.843769]        [<ffffffffa02d20e9>] del_br+0x5a/0x6f [bridge]
[  205.843769]        [<ffffffffa02d24b2>] br_del_bridge+0x59/0x67 [bridge]
[  205.843769]        [<ffffffffa02d3764>] br_ioctl_deviceless_stub+0x1fb/0=
x21b [bridge]
[  205.843769]        [<ffffffff813b32c4>] sock_ioctl+0x141/0x20d
[  205.843769]        [<ffffffff81126294>] vfs_ioctl+0x32/0xa6
[  205.843769]        [<ffffffff81126814>] do_vfs_ioctl+0x490/0x4d6
[  205.843769]        [<ffffffff811268b0>] sys_ioctl+0x56/0x79
[  205.843769]        [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
[  205.843769]=20
[  205.843769] other info that might help us debug this:
[  205.843769]=20
[  205.843769] 2 locks held by libvirtd/3058:
[  205.843769]  #0:  (br_ioctl_mutex){+.+.+.}, at: [<ffffffff813b32a9>] soc=
k_ioctl+0x126/0x20d
[  205.843769]  #1:  (rtnl_mutex){+.+.+.}, at: [<ffffffff813cedd9>] rtnl_lo=
ck+0x17/0x19
[  205.843769]=20
[  205.843769] stack backtrace:
[  205.843769] Pid: 3058, comm: libvirtd Not tainted 2.6.33-rc5 #3
[  205.843769] Call Trace:
[  205.843769]  [<ffffffff8107dae0>] print_circular_bug+0xa8/0xb6
[  205.843769]  [<ffffffff8107e93e>] __lock_acquire+0xa2e/0xd3c
[  205.843769]  [<ffffffff81171a56>] ? sysfs_addrm_finish+0x36/0x55
[  205.843769]  [<ffffffff8107ed19>] lock_acquire+0xcd/0xf1
[  205.843769]  [<ffffffff81171a56>] ? sysfs_addrm_finish+0x36/0x55
[  205.843769]  [<ffffffff81171463>] sysfs_deactivate+0x9a/0x103
[  205.843769]  [<ffffffff81171a56>] ? sysfs_addrm_finish+0x36/0x55
[  205.843769]  [<ffffffff8107c028>] ? trace_hardirqs_off+0xd/0xf
[  206.367937]  [<ffffffff81454e6a>] ? __mutex_unlock_slowpath+0x120/0x132
[  206.367937]  [<ffffffff81171a56>] sysfs_addrm_finish+0x36/0x55
[  206.367937]  [<ffffffff81171aab>] remove_dir+0x36/0x3e
[  206.367937]  [<ffffffff81171b60>] sysfs_remove_dir+0x9d/0xbe
[  206.367937]  [<ffffffff812206c1>] kobject_del+0x16/0x37
[  206.367937]  [<ffffffff8122078a>] kobject_release+0xa8/0xf8
[  206.367937]  [<ffffffff812206e2>] ? kobject_release+0x0/0xf8
[  206.367937]  [<ffffffff8122165d>] kref_put+0x43/0x4d
[  206.367937]  [<ffffffff8122063c>] kobject_put+0x47/0x4b
[  206.367937]  [<ffffffff8105d218>] ? del_timer_sync+0x0/0xa6
[  206.367937]  [<ffffffffa02d5ef5>] br_sysfs_delbr+0x21/0x43 [bridge]
[  206.367937]  [<ffffffffa02d20e9>] del_br+0x5a/0x6f [bridge]
[  206.367937]  [<ffffffffa02d24b2>] br_del_bridge+0x59/0x67 [bridge]
[  206.367937]  [<ffffffffa02d3764>] br_ioctl_deviceless_stub+0x1fb/0x21b [=
bridge]
[  206.367937]  [<ffffffff813b32c4>] sock_ioctl+0x141/0x20d
[  206.367937]  [<ffffffff81126294>] vfs_ioctl+0x32/0xa6
[  206.367937]  [<ffffffff81126814>] do_vfs_ioctl+0x490/0x4d6
[  206.367937]  [<ffffffff811268b0>] sys_ioctl+0x56/0x79
[  206.367937]  [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
[  206.482734] kobject: 'brif' (ffff880213a243b8): calling ktype release
[  206.492872] kobject: (ffff880213a243b8): dynamic_kobj_release
[  206.498841] kobject: 'brif': free name
[  206.527833] kobject: 'virbr0' (ffff8801cf3b0500): kobject_uevent_env
[  206.534360] kobject: 'virbr0' (ffff8801cf3b0500): fill_kobj_path: path =
=3D '/devices/virtual/net/virbr0'
[  206.551468] kobject: 'virbr0' (ffff8801cf3b0500): kobject_cleanup
[  206.557611] kobject: 'virbr0' (ffff8801cf3b0500): calling ktype release
[  206.564358] kobject: 'virbr0': free name
[  208.575408] kobject: 'tun' (ffffffffa044b510): kobject_add_internal: par=
ent: 'module', set: 'module'
[  208.595562] kobject: 'holders' (ffff8801d352cf68): kobject_add_internal:=
 parent: 'tun', set: '<NULL>'
[  208.604990] kobject: 'tun' (ffffffffa044b510): kobject_uevent_env
[  208.611296] kobject: 'tun' (ffffffffa044b510): fill_kobj_path: path =3D =
'/module/tun'
[  208.620119] kobject: 'notes' (ffff8801d352c660): kobject_add_internal: p=
arent: 'tun', set: '<NULL>'
[  208.630343] tun: Universal TUN/TAP device driver, 1.6
[  208.635421] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[  208.641721] kobject: 'tun' (ffff8801cd319e08): kobject_add_internal: par=
ent: 'misc', set: 'devices'
[  208.651194] kobject: 'tun' (ffff8801cd319e08): kobject_uevent_env
[  208.657386] kobject: 'tun' (ffff8801cd319e08): fill_kobj_path: path =3D =
'/devices/virtual/misc/tun'
[  208.671916] kobject: 'vnet0' (ffff880207df35e0): kobject_add_internal: p=
arent: 'net', set: 'devices'
[  208.682667] kobject: 'vnet0' (ffff880207df35e0): kobject_uevent_env
[  208.689435] kobject: 'vnet0' (ffff880207df35e0): fill_kobj_path: path =
=3D '/devices/virtual/net/vnet0'
[  208.712572] device vnet0 entered promiscuous mode
[  208.717571] kobject: 'brport' (ffff8801cd378e88): kobject_add_internal: =
parent: 'vnet0', set: '<NULL>'
[  208.728149] kobject: 'brport' (ffff8801cd378e88): kobject_uevent_env
[  208.734561] kobject: 'brport' (ffff8801cd378e88): kobject_uevent_env: fi=
lter function caused the event to drop!
[  208.748356] br0: port 2(vnet0) entering forwarding state
[  209.576245] kobject: 'vnet1' (ffff8801cc9a0500): kobject_add_internal: p=
arent: 'net', set: 'devices'
[  209.587167] kobject: 'vnet1' (ffff8801cc9a0500): kobject_uevent_env
[  209.593773] kobject: 'vnet1' (ffff8801cc9a0500): fill_kobj_path: path =
=3D '/devices/virtual/net/vnet1'
[  209.614211] device vnet1 entered promiscuous mode
[  209.619898] kobject: 'brport' (ffff8801cee35308): kobject_add_internal: =
parent: 'vnet1', set: '<NULL>'
[  209.631310] kobject: 'brport' (ffff8801cee35308): kobject_uevent_env
[  209.638303] kobject: 'brport' (ffff8801cee35308): kobject_uevent_env: fi=
lter function caused the event to drop!
[  209.654971] br0: port 3(vnet1) entering forwarding state
[  210.268995] SELinux: initialized (dev mqueue, type mqueue), uses transit=
ion SIDs
[  210.277526] kobject: 'pid_2' (ffff88020e222128): kobject_add_internal: p=
arent: 'slab', set: 'slab'
[  210.288037] kobject: 'pid_2' (ffff88020e222128): kobject_uevent_env
[  210.294431] kobject: 'pid_2' (ffff88020e222128): fill_kobj_path: path =
=3D '/kernel/slab/pid_2'
[  210.304019] SELinux: initialized (dev proc, type proc), uses genfs_conte=
xts
[  210.397532] SELinux: initialized (dev mqueue, type mqueue), uses transit=
ion SIDs
[  210.434435] lo: Disabled Privacy Extensions
[  210.443268] SELinux: initialized (dev proc, type proc), uses genfs_conte=
xts
[  210.787652] kobject: 'lo' (ffff880207b725a0): kobject_cleanup
[  210.793444] kobject: 'lo' (ffff880207b725a0): calling ktype release
[  210.799783] kobject: 'lo': free name
[  218.966215] vnet0: no IPv6 routers present
[  220.336219] vnet1: no IPv6 routers present
[  238.799662] kobject: 'vnet2' (ffff8801ccba8500): kobject_add_internal: p=
arent: 'net', set: 'devices'
[  238.811833] kobject: 'vnet2' (ffff8801ccba8500): kobject_uevent_env
[  238.818841] kobject: 'vnet2' (ffff8801ccba8500): fill_kobj_path: path =
=3D '/devices/virtual/net/vnet2'
[  238.841088] device vnet2 entered promiscuous mode
[  238.846209] kobject: 'brport' (ffff8801cf2d92d0): kobject_add_internal: =
parent: 'vnet2', set: '<NULL>'
[  238.856592] kobject: 'brport' (ffff8801cf2d92d0): kobject_uevent_env
[  238.863088] kobject: 'brport' (ffff8801cf2d92d0): kobject_uevent_env: fi=
lter function caused the event to drop!
[  238.878798] br0: port 4(vnet2) entering forwarding state
[  249.395339] vnet2: no IPv6 routers present
[  339.729225] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[  339.730086] last sysfs file: /sys/devices/virtual/block/md0/md/sync_spee=
d
[  339.730086] CPU 7=20
[  339.730086] Pid: 3245, comm: qemu-kvm Not tainted 2.6.33-rc5 #3 0F9382/P=
recision WorkStation 490   =20
[  339.730086] RIP: 0010:[<ffffffff813e5f3e>]  [<ffffffff813e5f3e>] nf_ct_r=
emove_expectations+0x49/0x5c
[  339.730086] RSP: 0018:ffff880030603c18  EFLAGS: 00010206
[  339.730086] RAX: ffff8801c2ea530b RBX: 009ab2000008d300 RCX: ffffffffa02=
925c1
[  339.730086] RDX: 000000000000006b RSI: ffff880030603be8 RDI: 009ab200000=
8d378
[  339.730086] RBP: ffff880030603c28 R08: 0000000000000002 R09: 00000000000=
00000
[  339.730086] R10: 0000000000000003 R11: ffff88019d28a268 R12: ffffffff829=
a0400
[  339.730086] R13: ffffffffa02925c1 R14: 0000000000000000 R15: ffff8801a18=
e4630
[  339.730086] FS:  00007fb6197ca780(0000) GS:ffff880030600000(0000) knlGS:=
0000000000000000
[  339.730086] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  339.730086] CR2: 00007f747a184178 CR3: 00000001badd8000 CR4: 00000000000=
026e0
[  339.730086] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[  339.730086] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[  339.730086] Process qemu-kvm (pid: 3245, threadinfo ffff8801b9370000, ta=
sk ffff8801d53c48a0)
[  339.730086] Stack:
[  339.730086]  ffffffff81b045d0 ffffffff829a0400 ffff880030603c48 ffffffff=
813e3426
[  339.730086] <0> ffff8801a18e4600 ffff88019d28a250 ffff880030603c68 fffff=
fff813e10f8
[  339.730086] <0> ffff880030603c68 ffffffff81b045d0 ffff880030603c88 fffff=
fff813bc080
[  339.730086] Call Trace:
[  339.730086]  <IRQ>=20
[  339.730086]  [<ffffffff813e3426>] destroy_conntrack+0x73/0x121
[  339.730086]  [<ffffffff813e10f8>] nf_conntrack_destroy+0x2c/0x33
[  339.730086]  [<ffffffff813bc080>] skb_release_head_state+0x77/0xb9
[  339.730086]  [<ffffffff813bbde2>] __kfree_skb+0x16/0x82
[  339.730086]  [<ffffffff813bbee7>] kfree_skb+0x6a/0x73
[  339.730086]  [<ffffffffa02925c1>] ip6_mc_input+0x214/0x221 [ipv6]
[  339.730086]  [<ffffffffa02925f5>] ip6_rcv_finish+0x27/0x2b [ipv6]
[  339.730086]  [<ffffffffa0292938>] ipv6_rcv+0x33f/0x37f [ipv6]
[  339.730086]  [<ffffffff813c416a>] netif_receive_skb+0x3b0/0x3da
[  339.730086]  [<ffffffffa02d2b6e>] br_handle_frame_finish+0x104/0x13c [br=
idge]
[  339.730086]  [<ffffffffa02d2d37>] br_handle_frame+0x191/0x1aa [bridge]
[  339.730086]  [<ffffffff813c40d6>] netif_receive_skb+0x31c/0x3da
[  339.730086]  [<ffffffff8106e6ee>] ? __run_hrtimer+0xec/0x11b
[  339.730086]  [<ffffffff813c4230>] process_backlog+0x9c/0xd8
[  339.730086]  [<ffffffff813c489b>] net_rx_action+0x7d/0x19c
[  339.730086]  [<ffffffff81055d08>] __do_softirq+0xf8/0x1cd
[  339.730086]  [<ffffffff8100ab9c>] call_softirq+0x1c/0x30
[  339.730086]  <EOI>=20
[  339.730086]  [<ffffffff8100c38f>] ? do_softirq+0x4b/0xa3
[  339.730086]  [<ffffffff813c49e0>] netif_rx_ni+0x26/0x2b
[  339.730086]  [<ffffffffa0449d6d>] tun_chr_aio_write+0x3ce/0x429 [tun]
[  339.730086]  [<ffffffffa044999f>] ? tun_chr_aio_write+0x0/0x429 [tun]
[  339.730086]  [<ffffffff81118fd2>] do_sync_readv_writev+0xc1/0x100
[  339.730086]  [<ffffffff811e9ee1>] ? selinux_file_permission+0xa7/0xb3
[  339.730086]  [<ffffffff81118d36>] ? copy_from_user+0x2f/0x31
[  339.730086]  [<ffffffff811e02f5>] ? security_file_permission+0x16/0x18
[  339.730086]  [<ffffffff81119d1f>] do_readv_writev+0xa7/0x127
[  339.730086]  [<ffffffff8111a1d7>] ? rcu_read_unlock+0x21/0x23
[  339.730086]  [<ffffffff8111a2bd>] ? fget_light+0xe4/0xf2
[  339.730086]  [<ffffffff8111a230>] ? fget_light+0x57/0xf2
[  339.730086]  [<ffffffff81119de2>] vfs_writev+0x43/0x4e
[  339.730086]  [<ffffffff81119ed2>] sys_writev+0x4a/0x93
[  339.730086]  [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
[  339.730086] Code: 38 0f b6 d2 48 01 d0 74 30 48 8b 58 28 eb 13 48 89 df =
e8 fc f8 ff ff 48 89 df e8 c8 f8 ff ff 4c 89 e3 48 85 db 74 12 48 8d 7b 78 =
<4c> 8b 23 e8 e2 73 c7 ff 85 c0 74 e8 eb d6 5b 41 5c c9 c3 55 48=20
[  339.730086] RIP  [<ffffffff813e5f3e>] nf_ct_remove_expectations+0x49/0x5=
c
[  339.730086]  RSP <ffff880030603c18>
[  340.095082] ---[ end trace 7be6d51534d25d87 ]---
[  340.099728] Kernel panic - not syncing: Fatal exception in interrupt
[  340.106123] Pid: 3245, comm: qemu-kvm Tainted: G      D    2.6.33-rc5 #3
[  340.112853] Call Trace:
[  340.112860]  <IRQ>  [<ffffffff81453b1d>] panic+0x7a/0x142
[  340.112886]  [<ffffffff81458011>] oops_end+0xb7/0xc7
[  340.112898]  [<ffffffff8100d421>] die+0x5a/0x63
[  340.112909]  [<ffffffff81457bcc>] do_general_protection+0x12a/0x133
[  340.112922]  [<ffffffff81457100>] ? irq_return+0x0/0x10
[  340.112956]  [<ffffffffa02925c1>] ? ip6_mc_input+0x214/0x221 [ipv6]
[  340.112969]  [<ffffffff81457345>] general_protection+0x25/0x30
[  340.113002]  [<ffffffffa02925c1>] ? ip6_mc_input+0x214/0x221 [ipv6]
--=-KcmM5aEtuxF3V4sWIT8C--

