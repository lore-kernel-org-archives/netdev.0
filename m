From: Daniele Orlandi <daniele@orlandi.com>
Subject: Possible race/deadlock in netdev_unregister
Date: Fri, 28 Jan 2005 23:13:29 +0100
Message-ID: <200501282313.30517.daniele@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello,

First of all, please excuse me if this happens to be a bug in my code :)
Unfortunately I'm still a newbie with netdev and his interactions with 
netlink, hotplug, etc... please help me understand what's happening and who 
is wrong.

The scenario is this:

- A device driver module (written by me) has two netdevices registered.
- Another module (written by me, too) provides sockets implementation for the 
protocol spoken by the device.
- An application has one socket bound to one netdevice
- I rmmod the device driver module
- The exit function in the module calls netdev_unregister
- The event dispatcher notifies the socket layer that a device is going down
- The socket is marked errored but the application keeps it open for a while
- The application ends, the socket is destroyed, the remaining reference to 
netdevice is released but netdev_unregister keeps sleeping forever with this 
backtrace:

Jan 28 19:02:58 bastard kernel: Call Trace:
Jan 28 19:02:58 bastard kernel:  [<c03053ee>] __down+0x6e/0xd0
Jan 28 19:02:58 bastard kernel:  [<c0119c70>] default_wake_function+0x0/0x10
Jan 28 19:02:58 bastard kernel:  [<c02a8f46>] netlink_dump+0x66/0x180
Jan 28 19:02:58 bastard kernel:  [<c0119cb5>] __wake_up_common+0x35/0x60
Jan 28 19:02:58 bastard kernel:  [<c0305554>] __down_failed+0x8/0xc
Jan 28 19:02:58 bastard kernel:  [<c0297108>] .text.lock.dev+0x91/0xb9
Jan 28 19:02:58 bastard kernel:  [<c029b660>] rtnetlink_dump_ifinfo+0x0/0x70
Jan 28 19:02:58 bastard kernel:  [<c029bc18>] rtnetlink_rcv+0x1d8/0x3f0
Jan 28 19:02:58 bastard kernel:  [<c029ba40>] rtnetlink_rcv+0x0/0x3f0
Jan 28 19:02:58 bastard kernel:  [<c02a8df8>] netlink_data_ready+0x28/0x50
Jan 28 19:02:58 bastard kernel:  [<c0296b81>] netdev_wait_allrefs+0xf1/0x100
Jan 28 19:02:58 bastard kernel:  [<c01d0410>] kobject_release+0x0/0x10
Jan 28 19:02:58 bastard kernel:  [<c0296c8c>] netdev_run_todo+0xfc/0x1c0
Jan 28 19:02:58 bastard kernel:  [<c029b660>] rtnetlink_dump_ifinfo+0x0/0x70
Jan 28 19:02:58 bastard kernel:  [<c029bc18>] rtnetlink_rcv+0x1d8/0x3f0
Jan 28 19:02:58 bastard kernel:  [<c011cabf>] printk+0xf/0x20
Jan 28 19:02:58 bastard kernel:  [<c012ab00>] wakeme_after_rcu+0x0/0x10
Jan 28 19:02:58 bastard kernel:  [<c029ba40>] rtnetlink_rcv+0x0/0x3f0
Jan 28 19:02:58 bastard kernel:  [<c02a8df8>] netlink_data_ready+0x28/0x50
Jan 28 19:02:58 bastard kernel:  [<c029aea1>] rtnl_unlock+0x31/0x40
Jan 28 19:02:58 bastard kernel:  [<e12f115e>] fake_module_exit+0x2e/0x7e 
[fake_isdn]
Jan 28 19:02:58 bastard kernel:  [<c012eaaa>] sys_delete_module+0x15a/0x170
Jan 28 19:02:58 bastard kernel:  [<c014653e>] unmap_vma_list+0xe/0x20
Jan 28 19:02:58 bastard kernel:  [<c0146838>] do_munmap+0xd8/0x120
Jan 28 19:02:58 bastard kernel:  [<c01468bc>] sys_munmap+0x3c/0x60
Jan 28 19:02:58 bastard kernel:  [<c0105c69>] sysenter_past_esp+0x52/0x79

Note that disabling hotplug avoids the problem.

Bye,

-- 
  Daniele Orlandi
