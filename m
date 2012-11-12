From: Sasha Levin <sasha.levin@oracle.com>
Subject: net, batman: lockdep circular dependency warning
Date: Mon, 12 Nov 2012 15:37:47 -0500
Message-ID: <50A15E1B.1010001@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with trinity inside a KVM tools (lkvm) guest running latest -next
kernel, I've stumbled on the following:

[ 1002.969392] ======================================================
[ 1002.971639] [ INFO: possible circular locking dependency detected ]
[ 1002.975805] 3.7.0-rc5-next-20121112-sasha-00018-g2f4ce0e #127 Tainted: G        W
[ 1002.983691] -------------------------------------------------------
[ 1002.983691] trinity-child18/8149 is trying to acquire lock:
[ 1002.983691]  (s_active#313){++++.+}, at: [<ffffffff812f9941>] sysfs_addrm_finish+0x31/0x60
[ 1002.983691]
[ 1002.983691] but task is already holding lock:
[ 1002.983691]  (rtnl_mutex){+.+.+.}, at: [<ffffffff834fcc62>] rtnl_lock+0x12/0x20
[ 1002.983691]
[ 1002.983691] which lock already depends on the new lock.
[ 1002.983691]
[ 1002.983691]
[ 1002.983691] the existing dependency chain (in reverse order) is:
[ 1002.983691]
-> #1 (rtnl_mutex){+.+.+.}:
[ 1002.983691]        [<ffffffff81180d0a>] check_prevs_add+0xba/0x1a0
[ 1002.983691]        [<ffffffff81181490>] validate_chain.isra.23+0x6a0/0x7b0
[ 1002.983691]        [<ffffffff81183e3b>] __lock_acquire+0x9db/0xa90
[ 1002.983691]        [<ffffffff8118635a>] lock_acquire+0x1ca/0x270
[ 1002.983691]        [<ffffffff83bf647a>] __mutex_lock_common+0x5a/0x550
[ 1002.983691]        [<ffffffff83bf69af>] mutex_lock_nested+0x3f/0x50
[ 1002.983691]        [<ffffffff834fcc62>] rtnl_lock+0x12/0x20
[ 1002.983691]        [<ffffffff834eeb3c>] netdev_run_todo+0x7c/0x180
[ 1002.983691]        [<ffffffff834fcfa9>] rtnl_unlock+0x9/0x10
[ 1002.983691]        [<ffffffff839d7da1>] batadv_store_mesh_iface+0x121/0x160
[ 1002.983691]        [<ffffffff819d303f>] kobj_attr_store+0xf/0x30
[ 1002.983691]        [<ffffffff812f7d41>] sysfs_write_file+0x101/0x170
[ 1002.983691]        [<ffffffff8127ac58>] vfs_write+0xb8/0x180
[ 1002.983691]        [<ffffffff8127af57>] sys_pwrite64+0x67/0x90
[ 1002.983691]        [<ffffffff83bfafd8>] tracesys+0xe1/0xe6
[ 1002.983691]
-> #0 (s_active#313){++++.+}:
[ 1002.983691]        [<ffffffff81180725>] check_prev_add+0x115/0x640
[ 1002.983691]        [<ffffffff81180d0a>] check_prevs_add+0xba/0x1a0
[ 1002.983691]        [<ffffffff81181490>] validate_chain.isra.23+0x6a0/0x7b0
[ 1002.983691]        [<ffffffff81183e3b>] __lock_acquire+0x9db/0xa90
[ 1002.983691]        [<ffffffff8118635a>] lock_acquire+0x1ca/0x270
[ 1002.983691]        [<ffffffff812f8eaa>] sysfs_deactivate+0x11a/0x190
[ 1002.983691]        [<ffffffff812f9941>] sysfs_addrm_finish+0x31/0x60
[ 1002.983691]        [<ffffffff812f9a0a>] __sysfs_remove_dir+0x9a/0xd0
[ 1002.983691]        [<ffffffff812f9f2f>] sysfs_remove_dir+0x3f/0x50
[ 1002.983691]        [<ffffffff819d3806>] kobject_del+0x16/0x40
[ 1002.983691]        [<ffffffff819d3930>] kobject_cleanup+0x100/0x190
[ 1002.983691]        [<ffffffff819d39cd>] kobject_release+0xd/0x10
[ 1002.983691]        [<ffffffff819d33cc>] kobject_put+0x4c/0x60
[ 1002.983691]        [<ffffffff839d8134>] batadv_sysfs_del_hardif+0x14/0x30
[ 1002.983691]        [<ffffffff839cdacd>] batadv_hardif_remove_interface+0x5d/0x90
[ 1002.983691]        [<ffffffff839cdba1>] batadv_hard_if_event+0xa1/0x2f0
[ 1002.983691]        [<ffffffff8114271e>] notifier_call_chain+0xee/0x130
[ 1002.983691]        [<ffffffff81142d31>] raw_notifier_call_chain+0x11/0x20
[ 1002.983691]        [<ffffffff834e8dc2>] call_netdevice_notifiers+0x52/0x60
[ 1002.983691]        [<ffffffff834ef4cd>] rollback_registered_many+0x14d/0x210
[ 1002.983691]        [<ffffffff834ef5bc>] rollback_registered+0x2c/0x40
[ 1002.983691]        [<ffffffff834ef650>] unregister_netdevice_queue+0x70/0xa0
[ 1002.983691]        [<ffffffff834ef7bb>] unregister_netdev+0x1b/0x30
[ 1002.983691]        [<ffffffff82a51fcc>] usbnet_disconnect+0x8c/0xf0
[ 1002.983691]        [<ffffffff82b0aca7>] usb_unbind_interface+0x67/0x160
[ 1002.983691]        [<ffffffff81e580a1>] __device_release_driver+0x81/0xe0
[ 1002.983691]        [<ffffffff81e581f9>] device_release_driver+0x29/0x40
[ 1002.983691]        [<ffffffff81e56c98>] bus_remove_device+0x138/0x150
[ 1002.983691]        [<ffffffff81e54e8d>] device_del+0x13d/0x1a0
[ 1002.983691]        [<ffffffff82b08459>] usb_disable_device+0xd9/0x270
[ 1002.983691]        [<ffffffff82b08f38>] usb_set_configuration+0x268/0x7b0
[ 1002.983691]        [<ffffffff82b0e5e3>] usb_remove_store+0x43/0x80
[ 1002.983691]        [<ffffffff81e536c3>] dev_attr_store+0x13/0x30
[ 1002.983691]        [<ffffffff812f7d41>] sysfs_write_file+0x101/0x170
[ 1002.983691]        [<ffffffff8127ac58>] vfs_write+0xb8/0x180
[ 1002.983691]        [<ffffffff8127ae10>] sys_write+0x50/0xa0
[ 1002.983691]        [<ffffffff83bfafd8>] tracesys+0xe1/0xe6
[ 1002.983691]
[ 1002.983691] other info that might help us debug this:
[ 1002.983691]
[ 1002.983691]  Possible unsafe locking scenario:
[ 1002.983691]
[ 1002.983691]        CPU0                    CPU1
[ 1002.983691]        ----                    ----
[ 1002.983691]   lock(rtnl_mutex);
[ 1002.983691]                                lock(s_active#313);
[ 1002.983691]                                lock(rtnl_mutex);
[ 1002.983691]   lock(s_active#313);
[ 1002.983691]
[ 1002.983691]  *** DEADLOCK ***
[ 1002.983691]
[ 1002.983691] 4 locks held by trinity-child18/8149:
[ 1002.983691]  #0:  (&buffer->mutex){+.+.+.}, at: [<ffffffff812f7c7f>] sysfs_write_file+0x3f/0x170
[ 1002.983691]  #1:  (&__lockdep_no_validate__){......}, at: [<ffffffff82b0e5c8>] usb_remove_store+0x28/0x80
[ 1002.983691]  #2:  (&__lockdep_no_validate__){......}, at: [<ffffffff81e581f1>] device_release_driver+0x21/0x40
[ 1002.983691]  #3:  (rtnl_mutex){+.+.+.}, at: [<ffffffff834fcc62>] rtnl_lock+0x12/0x20
[ 1002.983691]
[ 1002.983691] stack backtrace:
[ 1002.983691] Pid: 8149, comm: trinity-child18 Tainted: G        W    3.7.0-rc5-next-20121112-sasha-00018-g2f4ce0e #127
[ 1002.983691] Call Trace:
[ 1002.983691]  [<ffffffff83b322b9>] print_circular_bug+0xd3/0xe4
[ 1002.983691]  [<ffffffff81180725>] check_prev_add+0x115/0x640
[ 1002.983691]  [<ffffffff81180d0a>] check_prevs_add+0xba/0x1a0
[ 1002.983691]  [<ffffffff8117e134>] ? graph_unlock+0xa4/0xb0
[ 1002.983691]  [<ffffffff81181490>] validate_chain.isra.23+0x6a0/0x7b0
[ 1002.983691]  [<ffffffff81183e3b>] __lock_acquire+0x9db/0xa90
[ 1002.983691]  [<ffffffff81181ce9>] ? mark_held_locks+0xf9/0x130
[ 1002.983691]  [<ffffffff811844af>] ? lockdep_init_map+0xcf/0x5e0
[ 1002.983691]  [<ffffffff8118635a>] lock_acquire+0x1ca/0x270
[ 1002.983691]  [<ffffffff812f9941>] ? sysfs_addrm_finish+0x31/0x60
[ 1002.983691]  [<ffffffff812f8eaa>] sysfs_deactivate+0x11a/0x190
[ 1002.983691]  [<ffffffff812f9941>] ? sysfs_addrm_finish+0x31/0x60
[ 1002.983691]  [<ffffffff812f9941>] sysfs_addrm_finish+0x31/0x60
[ 1002.983691]  [<ffffffff812f9a0a>] __sysfs_remove_dir+0x9a/0xd0
[ 1002.983691]  [<ffffffff812f9f2f>] sysfs_remove_dir+0x3f/0x50
[ 1002.983691]  [<ffffffff819d3806>] kobject_del+0x16/0x40
[ 1002.983691]  [<ffffffff819d3930>] kobject_cleanup+0x100/0x190
[ 1002.983691]  [<ffffffff819d39cd>] kobject_release+0xd/0x10
[ 1002.983691]  [<ffffffff819d33cc>] kobject_put+0x4c/0x60
[ 1002.983691]  [<ffffffff839d8134>] batadv_sysfs_del_hardif+0x14/0x30
[ 1002.983691]  [<ffffffff839cd040>] ? batadv_primary_if_update_addr+0x280/0x280
[ 1002.983691]  [<ffffffff839cdacd>] batadv_hardif_remove_interface+0x5d/0x90
[ 1002.983691]  [<ffffffff839cdba1>] batadv_hard_if_event+0xa1/0x2f0
[ 1002.983691]  [<ffffffff8114271e>] notifier_call_chain+0xee/0x130
[ 1002.983691]  [<ffffffff81142d31>] raw_notifier_call_chain+0x11/0x20
[ 1002.983691]  [<ffffffff834e8dc2>] call_netdevice_notifiers+0x52/0x60
[ 1002.983691]  [<ffffffff834ef4cd>] rollback_registered_many+0x14d/0x210
[ 1002.983691]  [<ffffffff834ef5bc>] rollback_registered+0x2c/0x40
[ 1002.983691]  [<ffffffff834ef650>] unregister_netdevice_queue+0x70/0xa0
[ 1002.983691]  [<ffffffff834ef7bb>] unregister_netdev+0x1b/0x30
[ 1002.983691]  [<ffffffff82a51fcc>] usbnet_disconnect+0x8c/0xf0
[ 1002.983691]  [<ffffffff82b0aca7>] usb_unbind_interface+0x67/0x160
[ 1002.983691]  [<ffffffff81e580a1>] __device_release_driver+0x81/0xe0
[ 1002.983691]  [<ffffffff81e581f9>] device_release_driver+0x29/0x40
[ 1002.983691]  [<ffffffff81e56c98>] bus_remove_device+0x138/0x150
[ 1002.983691]  [<ffffffff81e54e8d>] device_del+0x13d/0x1a0
[ 1002.983691]  [<ffffffff82b08459>] usb_disable_device+0xd9/0x270
[ 1002.983691]  [<ffffffff82b08f38>] usb_set_configuration+0x268/0x7b0
[ 1002.983691]  [<ffffffff82b0e5c8>] ? usb_remove_store+0x28/0x80
[ 1002.983691]  [<ffffffff82b0e5e3>] usb_remove_store+0x43/0x80
[ 1002.983691]  [<ffffffff81e536c3>] dev_attr_store+0x13/0x30
[ 1002.983691]  [<ffffffff812f7d41>] sysfs_write_file+0x101/0x170
[ 1002.983691]  [<ffffffff8127ac58>] vfs_write+0xb8/0x180
[ 1002.983691]  [<ffffffff8127ae10>] sys_write+0x50/0xa0
[ 1002.983691]  [<ffffffff83bfafd8>] tracesys+0xe1/0xe6


Thanks,
Sasha
