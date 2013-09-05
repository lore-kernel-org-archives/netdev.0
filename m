From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60856] New: Enabling PCI pass-through triggers circular
 locking complaint
Date: Thu, 5 Sep 2013 08:06:12 -0700
Message-ID: <20130905080612.7a2bef58@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:42359 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab3IEPGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 11:06:16 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so1921362pbb.0
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 08:06:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 5 Sep 2013 02:54:21 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60856] New: Enabling PCI pass-through triggers circular locking complaint


https://bugzilla.kernel.org/show_bug.cgi?id=60856

            Bug ID: 60856
           Summary: Enabling PCI pass-through triggers circular locking
                    complaint
           Product: Networking
           Version: 2.5
    Kernel Version: 3.11
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: bvanassche@acm.org
        Regression: Yes

When I enable PCI pass-through for an mlx4 HCA, a circular locking complaint is
reported.

PCI pass-through was enabled with the following script:

#!/bin/bash
vendor_id="15b3" # Mellanox
device_id="1003" # MT27500 Family [ConnectX-3]

modprobe pci_stub &&
echo "$vendor_id $device_id" >/sys/bus/pci/drivers/pci-stub/new_id &&
lspci -n -mm |
while read slot class vendor device rest; do
    slot="0000:${slot}"
    vendor="${vendor#\"}"
    vendor="${vendor%\"}"
    device="${device#\"}"
    device="${device%\"}"
    if [ "$vendor" = "$vendor_id" -a "$device" = "$device_id" ]; then
    echo "$slot" >/sys/bus/pci/devices/$slot/driver/unbind
    echo "$slot" >/sys/bus/pci/drivers/pci-stub/bind
    fi
done

Running the above script triggered the following lockdep complaint:

======================================================
[ INFO: possible circular locking dependency detected ]
3.11.0-debug+ #1 Not tainted
-------------------------------------------------------
assign-pci-dev-/3065 is trying to acquire lock:
 (s_active#79){++++.+}, at: [<ffffffff811d816b>] sysfs_addrm_finish+0x3b/0x70

but task is already holding lock:
 (rtnl_mutex){+.+.+.}, at: [<ffffffff81384117>] rtnl_lock+0x17/0x20

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (rtnl_mutex){+.+.+.}:
       [<ffffffff810a5eca>] lock_acquire+0x8a/0x120
       [<ffffffff8144c16d>] mutex_lock_nested+0x7d/0x380
       [<ffffffff81384117>] rtnl_lock+0x17/0x20
       [<ffffffffa048fb7e>] ipoib_set_mode+0xde/0xf0 [ib_ipoib]
       [<ffffffffa049686a>] set_mode+0x3a/0x90 [ib_ipoib]
       [<ffffffff812eec88>] dev_attr_store+0x18/0x30
       [<ffffffff811d6654>] sysfs_write_file+0xe4/0x150
       [<ffffffff81167f24>] vfs_write+0xc4/0x1e0
       [<ffffffff811683e5>] SyS_write+0x55/0xa0
       [<ffffffff81459fc2>] system_call_fastpath+0x16/0x1b

-> #0 (s_active#79){++++.+}:
       [<ffffffff810a57a6>] __lock_acquire+0x1d36/0x1e40
       [<ffffffff810a5eca>] lock_acquire+0x8a/0x120
       [<ffffffff811d75b6>] sysfs_deactivate+0x126/0x180
       [<ffffffff811d816b>] sysfs_addrm_finish+0x3b/0x70
       [<ffffffff811d86af>] sysfs_remove_dir+0x9f/0xd0
       [<ffffffff81228666>] kobject_del+0x16/0x40
       [<ffffffff812f037a>] device_del+0x18a/0x1d0
       [<ffffffff8138daf1>] netdev_unregister_kobject+0x71/0x80
       [<ffffffff8137339c>] rollback_registered_many+0x16c/0x220
       [<ffffffff81373661>] rollback_registered+0x31/0x40
       [<ffffffff81373ce8>] unregister_netdevice_queue+0x58/0xa0
       [<ffffffff81373e20>] unregister_netdev+0x20/0x30
       [<ffffffffa048dc01>] ipoib_remove_one+0xb1/0xf0 [ib_ipoib]
       [<ffffffffa035e57e>] ib_unregister_device+0x4e/0x110 [ib_core]
       [<ffffffffa044ebde>] mlx4_ib_remove+0x2e/0x1a0 [mlx4_ib]
       [<ffffffffa037e24b>] mlx4_remove_device+0x7b/0x90 [mlx4_core]
       [<ffffffffa037e5ab>] mlx4_unregister_device+0x4b/0x90 [mlx4_core]
       [<ffffffffa037fca4>] mlx4_remove_one+0x54/0x330 [mlx4_core]
       [<ffffffff812542a6>] pci_device_remove+0x46/0xc0
       [<ffffffff812f39ef>] __device_release_driver+0x7f/0xf0
       [<ffffffff812f3d4e>] device_release_driver+0x2e/0x40
       [<ffffffff812f28e3>] driver_unbind+0xa3/0xc0
       [<ffffffff812f1c24>] drv_attr_store+0x24/0x40
       [<ffffffff811d6654>] sysfs_write_file+0xe4/0x150
       [<ffffffff81167f24>] vfs_write+0xc4/0x1e0
       [<ffffffff811683e5>] SyS_write+0x55/0xa0
       [<ffffffff81459fc2>] system_call_fastpath+0x16/0x1b

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(rtnl_mutex);
                               lock(s_active#79);
                               lock(rtnl_mutex);
  lock(s_active#79);

 *** DEADLOCK ***

8 locks held by assign-pci-dev-/3065:
 #0:  (sb_writers#6){.+.+.+}, at: [<ffffffff81168003>] vfs_write+0x1a3/0x1e0
 #1:  (&buffer->mutex){+.+.+.}, at: [<ffffffff811d65b8>]
sysfs_write_file+0x48/0x150
 #2:  (s_active#185){.+.+.+}, at: [<ffffffff811d663c>]
sysfs_write_file+0xcc/0x150
 #3:  (&__lockdep_no_validate__){......}, at: [<ffffffff812f28db>]
driver_unbind+0x9b/0xc0
 #4:  (&__lockdep_no_validate__){......}, at: [<ffffffff812f3d46>]
device_release_driver+0x26/0x40
 #5:  (intf_mutex){+.+.+.}, at: [<ffffffffa037e583>]
mlx4_unregister_device+0x23/0x90 [mlx4_core]
 #6:  (device_mutex){+.+.+.}, at: [<ffffffffa035e557>]
ib_unregister_device+0x27/0x110 [ib_core]
 #7:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81384117>] rtnl_lock+0x17/0x20

stack backtrace:
CPU: 1 PID: 3065 Comm: assign-pci-dev- Not tainted 3.11.0-debug+ #1
Hardware name: System manufacturer P5Q DELUXE/P5Q DELUXE, BIOS 2301
07/10/2009
 ffffffff81d67910 ffff8801b265d848 ffffffff8144973f 0000000000000007
 ffffffff81d67910 ffff8801b265d898 ffffffff814467da 0000000000000086
 ffff8801b265d928 ffff8801b37f5278 ffff8801b37f52b0 ffff8801b37f5278
Call Trace:
 [<ffffffff8144973f>] dump_stack+0x55/0x76
 [<ffffffff814467da>] print_circular_bug+0x1fb/0x20c
 [<ffffffff810a57a6>] __lock_acquire+0x1d36/0x1e40
 [<ffffffff8107c9e5>] ? sched_clock_local+0x25/0xa0
 [<ffffffff810a5eca>] lock_acquire+0x8a/0x120
 [<ffffffff811d816b>] ? sysfs_addrm_finish+0x3b/0x70
 [<ffffffff811d75b6>] sysfs_deactivate+0x126/0x180
 [<ffffffff811d816b>] ? sysfs_addrm_finish+0x3b/0x70
 [<ffffffff810a6829>] ? mark_held_locks+0xb9/0x140
 [<ffffffff811d816b>] sysfs_addrm_finish+0x3b/0x70
 [<ffffffff811d86af>] sysfs_remove_dir+0x9f/0xd0
 [<ffffffff81228666>] kobject_del+0x16/0x40
 [<ffffffff812f037a>] device_del+0x18a/0x1d0
 [<ffffffff8138daf1>] netdev_unregister_kobject+0x71/0x80
 [<ffffffff8137339c>] rollback_registered_many+0x16c/0x220
 [<ffffffff81384117>] ? rtnl_lock+0x17/0x20
 [<ffffffff81373661>] rollback_registered+0x31/0x40
 [<ffffffff81373ce8>] unregister_netdevice_queue+0x58/0xa0
 [<ffffffff81373e20>] unregister_netdev+0x20/0x30
 [<ffffffffa048dc01>] ipoib_remove_one+0xb1/0xf0 [ib_ipoib]
 [<ffffffffa035e57e>] ib_unregister_device+0x4e/0x110 [ib_core]
 [<ffffffffa044ebde>] mlx4_ib_remove+0x2e/0x1a0 [mlx4_ib]
 [<ffffffffa037e24b>] mlx4_remove_device+0x7b/0x90 [mlx4_core]
 [<ffffffffa037e5ab>] mlx4_unregister_device+0x4b/0x90 [mlx4_core]
 [<ffffffffa037fca4>] mlx4_remove_one+0x54/0x330 [mlx4_core]
 [<ffffffff812542a6>] pci_device_remove+0x46/0xc0
 [<ffffffff812f39ef>] __device_release_driver+0x7f/0xf0
 [<ffffffff812f3d4e>] device_release_driver+0x2e/0x40
 [<ffffffff812f28e3>] driver_unbind+0xa3/0xc0
 [<ffffffff812f1c24>] drv_attr_store+0x24/0x40
 [<ffffffff811d6654>] sysfs_write_file+0xe4/0x150
 [<ffffffff81167f24>] vfs_write+0xc4/0x1e0
 [<ffffffff811683e5>] SyS_write+0x55/0xa0
 [<ffffffff81459fc2>] system_call_fastpath+0x16/0x1b

--
You are receiving this mail because:
You are the assignee for the bug.
