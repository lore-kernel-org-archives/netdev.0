From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 1/2] IB/ipoib: Add rtnl_link_ops support
Date: Wed, 12 Sep 2012 13:40:11 +0300
Message-ID: <5050668B.1010105@mellanox.com>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com> <1345724119-32110-2-git-send-email-ogerlitz@mellanox.com> <Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Shlomo Pongratz <shlomop@mellanox.com>
To: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:50962 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755891Ab2ILKoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 06:44:20 -0400
In-Reply-To: <Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Or Gerlitz wrote:
>
>> +#define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
>
> This should go into include/linux/if_link.h
>

This comment was easy to fix... HOWEVER, using V3 -- this posting
http://marc.info/?l=linux-netdev&m=134572609226343&w=2 -- of the patch
over latest net-next (commit 280050cc81ccb2e06e4061228ee34c0cc86b1560
"x86 bpf_jit: support MOD operation"), when I just run the following trivial
sequence which loads the module and creates/deletes legacy child

$ modprobe ib_ipoib debug_level=1
$ echo 0x8001 > /sys/class/net/ib0/create_child
$ echo 0x8001 > /sys/class/net/ib0/delete_child
$ modprobe -r ib_ipoib

I get the below lockdep warning, pointing to ipoib_vlan_delete which is
by not means called by the module unload sequence, confusing... any idea?

Or.

======================================================
[ INFO: possible circular locking dependency detected ]
3.6.0-rc3+ #144 Not tainted
-------------------------------------------------------
modprobe/4443 is trying to acquire lock:
  (s_active#155){++++.+}, at: [<ffffffff8114f93f>] 
sysfs_addrm_finish+0x29/0x52

but task is already holding lock:
  (rtnl_mutex){+.+.+.}, at: [<ffffffff812fc103>] rtnl_lock+0x12/0x14

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (rtnl_mutex){+.+.+.}:
        [<ffffffff81072b30>] lock_acquire+0x14f/0x19b
        [<ffffffff81396a43>] mutex_lock_nested+0x64/0x2ce
        [<ffffffff812fc103>] rtnl_lock+0x12/0x14
        [<ffffffff812eecf1>] netdev_run_todo+0xa5/0x27e
        [<ffffffff812fc0dd>] rtnl_unlock+0x9/0xb
        [<ffffffffa0394889>] ipoib_vlan_delete+0x111/0x148 [ib_ipoib]
        [<ffffffffa038d29b>] delete_child+0x44/0x60 [ib_ipoib]
        [<ffffffff81247bd8>] dev_attr_store+0x1b/0x1d
        [<ffffffff8114e223>] sysfs_write_file+0x103/0x13f
        [<ffffffff810f206b>] vfs_write+0xae/0x133
        [<ffffffff810f21a9>] sys_write+0x45/0x6c
        [<ffffffff813a05e2>] system_call_fastpath+0x16/0x1b

-> #0 (s_active#155){++++.+}:
        [<ffffffff81072364>] __lock_acquire+0x10d1/0x174e
        [<ffffffff81072b30>] lock_acquire+0x14f/0x19b
        [<ffffffff8114ef79>] sysfs_deactivate+0x93/0xca
        [<ffffffff8114f93f>] sysfs_addrm_finish+0x29/0x52
        [<ffffffff8114fa36>] sysfs_remove_dir+0x8b/0x9e
        [<ffffffff81199c6d>] kobject_del+0x16/0x37
        [<ffffffff812491ca>] device_del+0x18f/0x19f
        [<ffffffff813000d3>] netdev_unregister_kobject+0x52/0x57
        [<ffffffff812eeacc>] rollback_registered_many+0x238/0x27c
        [<ffffffff812eebe9>] unregister_netdevice_queue+0x7f/0xbf
        [<ffffffff812eec45>] unregister_netdev+0x1c/0x23
        [<ffffffffa038d1eb>] ipoib_remove_one+0xad/0xe7 [ib_ipoib]
        [<ffffffffa01a89ec>] ib_unregister_client+0x3d/0x11c [ib_core]
        [<ffffffffa0398fcf>] ipoib_cleanup_module+0x2f/0x4e [ib_ipoib]
        [<ffffffff8107d81d>] sys_delete_module+0x1ac/0x210
        [<ffffffff813a05e2>] system_call_fastpath+0x16/0x1b

other info that might help us debug this:

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(rtnl_mutex);
                                lock(s_active#155);
                                lock(rtnl_mutex);
   lock(s_active#155);

  *** DEADLOCK ***

2 locks held by modprobe/4443:
  #0:  (device_mutex){+.+.+.}, at: [<ffffffffa01a89d1>] 
ib_unregister_client+0x22/0x11c [ib_core]
  #1:  (rtnl_mutex){+.+.+.}, at: [<ffffffff812fc103>] rtnl_lock+0x12/0x14

stack backtrace:
Pid: 4443, comm: modprobe Not tainted 3.6.0-rc3+ #144
Call Trace:
  [<ffffffff8102dad8>] ? console_unlock+0x329/0x37e
  [<ffffffff81070c15>] print_circular_bug+0x28e/0x29f
  [<ffffffff81072364>] __lock_acquire+0x10d1/0x174e
  [<ffffffff8114f93f>] ? sysfs_addrm_finish+0x29/0x52
  [<ffffffff81072b30>] lock_acquire+0x14f/0x19b
  [<ffffffff8114f93f>] ? sysfs_addrm_finish+0x29/0x52
  [<ffffffff8114ef79>] sysfs_deactivate+0x93/0xca
  [<ffffffff8114f93f>] ? sysfs_addrm_finish+0x29/0x52
  [<ffffffff8114f93f>] sysfs_addrm_finish+0x29/0x52
  [<ffffffff8114fa36>] sysfs_remove_dir+0x8b/0x9e
  [<ffffffff81199c6d>] kobject_del+0x16/0x37
  [<ffffffff812491ca>] device_del+0x18f/0x19f
  [<ffffffff813000d3>] netdev_unregister_kobject+0x52/0x57
  [<ffffffff812eeacc>] rollback_registered_many+0x238/0x27c
  [<ffffffff812eebe9>] unregister_netdevice_queue+0x7f/0xbf
  [<ffffffff812eec45>] unregister_netdev+0x1c/0x23
  [<ffffffffa038d1eb>] ipoib_remove_one+0xad/0xe7 [ib_ipoib]
  [<ffffffffa01a89ec>] ib_unregister_client+0x3d/0x11c [ib_core]
  [<ffffffffa0398fcf>] ipoib_cleanup_module+0x2f/0x4e [ib_ipoib]
  [<ffffffff8107d81d>] sys_delete_module+0x1ac/0x210
  [<ffffffff8106fc4f>] ? trace_hardirqs_on_caller+0x11e/0x155
  [<ffffffff811a2a0e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff813a05e2>] system_call_fastpath+0x16/0x1b
