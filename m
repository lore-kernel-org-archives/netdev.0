From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BUG][PATCH] Fix race condition about network device name
 allocation
Date: Fri, 11 May 2007 08:50:20 -0700
Message-ID: <20070511085020.7acf792c@freepuppy>
References: <1178862045.3979.33.camel@kane-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52026 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757558AbXEKPuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 11:50:25 -0400
In-Reply-To: <1178862045.3979.33.camel@kane-linux>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 May 2007 14:40:45 +0900
Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> wrote:

> Hi,
> 
> I encountered the following error when I was hot-plugging network card
> using pci hotplug driver.
> 
> kobject_add failed for eth8 with -EEXIST, don't try to register things with the same name in the same directory.
> 
> Call Trace:
>  [<a000000100013940>] show_stack+0x40/0xa0
>                                 sp=e0000000652cfbf0 bsp=e0000000652c9450
>  [<a0000001000139d0>] dump_stack+0x30/0x60
>                                 sp=e0000000652cfdc0 bsp=e0000000652c9438
>  [<a0000001003b5af0>] kobject_shadow_add+0x3b0/0x440
>                                 sp=e0000000652cfdc0 bsp=e0000000652c93f0
>  [<a0000001003b5bb0>] kobject_add+0x30/0x60
>                                 sp=e0000000652cfdc0 bsp=e0000000652c93d0
>  [<a000000100488240>] device_add+0x160/0xf40
>                                 sp=e0000000652cfdc0 bsp=e0000000652c9358
>  [<a00000010061af00>] netdev_register_sysfs+0xc0/0xe0
>                                 sp=e0000000652cfdc0 bsp=e0000000652c9328
>  [<a0000001006006c0>] register_netdevice+0x600/0x7e0
>                                 sp=e0000000652cfdc0 bsp=e0000000652c92e8
>  [<a000000100600910>] register_netdev+0x70/0xc0
>                                 sp=e0000000652cfdd0 bsp=e0000000652c92c0
>  [<a00000020018dd70>] e1000_probe+0x1710/0x1a00 [e1000]
>                                 sp=e0000000652cfdd0 bsp=e0000000652c9258
>  [<a0000001003d56c0>] pci_device_probe+0xc0/0x120
>                                 sp=e0000000652cfde0 bsp=e0000000652c9218
>  [<a00000010048dc60>] really_probe+0x1c0/0x300
>                                 sp=e0000000652cfde0 bsp=e0000000652c91c8
>  [<a00000010048df40>] driver_probe_device+0x1a0/0x1c0
>                                 sp=e0000000652cfde0 bsp=e0000000652c9198
>  [<a00000010048df90>] __device_attach+0x30/0x60
>                                 sp=e0000000652cfde0 bsp=e0000000652c9170
>  [<a00000010048c080>] bus_for_each_drv+0x80/0x120
>                                 sp=e0000000652cfde0 bsp=e0000000652c9138
>  [<a00000010048e0c0>] device_attach+0xa0/0x100
>                                 sp=e0000000652cfe00 bsp=e0000000652c9110
>  [<a00000010048bec0>] bus_attach_device+0x60/0xe0
>                                 sp=e0000000652cfe00 bsp=e0000000652c90e0
>  [<a000000100488a30>] device_add+0x950/0xf40
>                                 sp=e0000000652cfe00 bsp=e0000000652c9068
>  [<a0000001003ca360>] pci_bus_add_device+0x20/0x100
>                                 sp=e0000000652cfe00 bsp=e0000000652c9040
>  [<a0000001003ca490>] pci_bus_add_devices+0x50/0x320
>                                 sp=e0000000652cfe00 bsp=e0000000652c9010
>  [<a000000200081520>] shpchp_configure_device+0x460/0x4a0 [shpchp]
>                                 sp=e0000000652cfe00 bsp=e0000000652c8fc0
>  [<a00000020007e7c0>] board_added+0x720/0x8c0 [shpchp]
>                                 sp=e0000000652cfe00 bsp=e0000000652c8f80
>  [<a00000020007f280>] shpchp_enable_slot+0x920/0xa40 [shpchp]
>                                 sp=e0000000652cfe10 bsp=e0000000652c8f30
>  [<a000000200080a40>] shpchp_sysfs_enable_slot+0x120/0x220 [shpchp]
>                                 sp=e0000000652cfe20 bsp=e0000000652c8ef8
>  [<a00000020007d270>] enable_slot+0x90/0xc0 [shpchp]
>                                 sp=e0000000652cfe20 bsp=e0000000652c8ed0
>  [<a00000020002a760>] power_write_file+0x1e0/0x2a0 [pci_hotplug]
>                                 sp=e0000000652cfe20 bsp=e0000000652c8ea0
>  [<a000000200028100>] hotplug_slot_attr_store+0x60/0xa0 [pci_hotplug]
>                                 sp=e0000000652cfe20 bsp=e0000000652c8e68
>  [<a0000001001cf010>] sysfs_write_file+0x270/0x300
>                                 sp=e0000000652cfe20 bsp=e0000000652c8e18
>  [<a0000001001395b0>] vfs_write+0x1b0/0x300
>                                 sp=e0000000652cfe20 bsp=e0000000652c8dc0
>  [<a00000010013a1b0>] sys_write+0x70/0xe0
>                                 sp=e0000000652cfe20 bsp=e0000000652c8d48
>  [<a00000010000bc20>] ia64_ret_from_syscall+0x0/0x20
>                                 sp=e0000000652cfe30 bsp=e0000000652c8d48
>  [<a000000000010620>] __kernel_syscall_via_break+0x0/0x20
>                                 sp=e0000000652d0000 bsp=e0000000652c8d48
> 
> This error is caused by the race condition between dev_alloc_name()
> and unregistering net device. The dev_alloc_name() function checks
> dev_base list to find a suitable id. The net device is removed from
> the dev_base list when net device is unregistered. Those are done with
> rtnl lock held, so there is no problem. However, removing sysfs entry
> is delayed until netdev_run_todo() which is outside rtnl lock. Because
> of this, dev_alloc_name() can create a device name which is duplicated
> with the existing sysfs entry.
> 
> The following patch fixes this by changing dev_alloc_name() function
> to check not only dev_base list but also todo list and snapshot list
> to find a suitable id. If some devices exists on the todo list or
> snapshot list, sysfs entries corresponding to them are not deleted
> yet.
> 
> Thanks,
> Kenji Kaneshige
> 
> ---
> Fix the race condition between dev_alloc_name() and net device
> unregistration.
> 
> dev_alloc_name checks `dev_base' list to find a suitable ID. On the
> other hand, net devices are removed from that list on net device
> unregistration. Both of them are done with holding rtnl lock. However,
> removing sysfs entry is delayed until netdev_run_todo(), which doesn't
> acquire rtnl lock. Therefore, on dev_alloc_name(), device name could
> conflict with the device, which is unregistered, but its sysfs entry
> still exist.
> 
> To fix this bug, change dev_alloc_name to check not only `dev_base'
> list but also todo list and snapshot list.
> 
> Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

There should be a better way to fix this by getting rid of the kobjects 
on deletion rather than the overhead another lock and list scans....

