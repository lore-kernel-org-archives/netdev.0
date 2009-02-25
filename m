From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [Powerpc / eHEA] Circular dependency with 2.6.29-rc6
Date: Wed, 25 Feb 2009 16:05:56 +0100
Message-ID: <49A55E54.4080304@de.ibm.com>
References: <49A26290.60607@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>,
	TKLEIN@de.ibm.com, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Mel Gorman <mel@csn.ul.ie>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>
To: "Sachin P. Sant" <sachinp@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:42267 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775AbZBYPGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 10:06:01 -0500
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate6.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n1PF5wu4087660
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 15:05:58 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1PF5w3Z1290322
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 15:05:58 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1PF5ukT032438
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 15:05:58 GMT
In-Reply-To: <49A26290.60607@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we have investigated this problem but didn't understand to root cause of
this problem so far.
The things we observed:
- The warning is only shown when the ehea module is loaded while the
machine is booting.
- If you load the module later (modprobe) no warnings are shown
- Machine never actually hangs

We interpret the warning like this:
- The mutex debug facility detects a dependency between port_lock and
ehea_fw_handles.lock
- ehea_fw_handles.lock is an ehea global lock
- port->port_lock is a lock per network device
- When "open" is called for a registered network device, port->port_lock
is taken first,
  then ehea_fw_handles.lock
- When "open" is left these locks are released in a proper way (inverse
order)
- In addition: ehea_fw_handles.lock is held by the function
"driver_probe_device"
  that registers all available network devices (register_netdev)
- When multiple network devices are registered, it is possible that
"open" is
  called on an already registered network device while further
netdevices are still registered
  in "driver_probe_device". ---> "open" will take port->port_lock, but
won't get ehea_fw_handles.lock
- However, ehea_fw_handles.lock is freed once all netdevices are registered.
- When the second netdevice is registered in "driver_probe_device", it
will also try to get
  the port->port_lock (which in fact is a different one, as there is one
per netdevice).
- Does the mutex debug mechanism distinguish between the different
port->port_lock instances?

So far we don't see a locking problem here. Is it possible that the
mutex debug
mechanism causes a false positive here?

Any help is highly appreciated.

Regards
Jan-Bernd

Sachin P. Sant wrote:
> While booting 2.6.29-rc6 on a powerpc box came across this
> circular dependency with eHEA driver.
>
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.29-rc6 #2
> -------------------------------------------------------
> ip/2174 is trying to acquire lock:
> (&ehea_fw_handles.lock){--..}, at: [<d000000002a13e30>]
> .ehea_up+0x64/0x6e0
> [ehea]
>
> but task is already holding lock:
> (&port->port_lock){--..}, at: [<d000000002a1533c>]
> .ehea_open+0x3c/0xc4 [ehea]
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #2 (&port->port_lock){--..}:
> [<c0000000000a8590>] .__lock_acquire+0x7e0/0x8a8
>       [<c0000000000a86ac>] .lock_acquire+0x54/0x80
>       [<c0000000005d7564>] .mutex_lock_nested+0x190/0x46c
>       [<d000000002a1533c>] .ehea_open+0x3c/0xc4 [ehea]
>       [<c000000000537834>] .dev_open+0xf4/0x168
>       [<c000000000535780>] .dev_change_flags+0xe4/0x1e8
>       [<c000000000597bfc>] .devinet_ioctl+0x2c4/0x750
>       [<c0000000005997a8>] .inet_ioctl+0xcc/0x11c
>       [<c000000000523400>] .sock_ioctl+0x2f0/0x34c
>       [<c0000000001380ec>] .vfs_ioctl+0x5c/0xf0
>       [<c000000000138810>] .do_vfs_ioctl+0x690/0x70c
>       [<c000000000138900>] .SyS_ioctl+0x74/0xb8
>       [<c00000000016fb08>] .dev_ifsioc+0x210/0x4b8
>       [<c00000000016ef18>] .compat_sys_ioctl+0x3f4/0x488
>       [<c00000000000855c>] syscall_exit+0x0/0x40
>
> -> #1 (rtnl_mutex){--..}:
>       [<c0000000000a8590>] .__lock_acquire+0x7e0/0x8a8
>       [<c0000000000a86ac>] .lock_acquire+0x54/0x80
>       [<c0000000005d7564>] .mutex_lock_nested+0x190/0x46c
>       [<c0000000005430a8>] .rtnl_lock+0x20/0x38
>       [<c00000000053677c>] .register_netdev+0x1c/0x80
>       [<d000000002a12714>] .ehea_setup_single_port+0x2c8/0x3d0 [ehea]
>       [<d000000002a19da8>] .ehea_probe_adapter+0x288/0x394 [ehea]
>       [<c00000000051f034>] .of_platform_device_probe+0x78/0x86c
>       [<c00000000047faec>] .driver_probe_device+0x13c/0x200
>       [<c00000000047fc44>] .__driver_attach+0x94/0xd8
>       [<c00000000047eab4>] .bus_for_each_dev+0x80/0xd8
>       [<c00000000047f850>] .driver_attach+0x28/0x40
>       [<c00000000047f23c>] .bus_add_driver+0xd4/0x284
>       [<c00000000047ff7c>] .driver_register+0xc4/0x198
>       [<c00000000051eeec>] .of_register_driver+0x4c/0x60
>       [<c000000000024da4>] .ibmebus_register_driver+0x30/0x4c
>       [<d000000002a1a090>] .ehea_module_init+0x1dc/0x234c [ehea]
>       [<c000000000009368>] .do_one_initcall+0x90/0x1b0
>       [<c0000000000b2f24>] .SyS_init_module+0xc8/0x220
>       [<c00000000000855c>] syscall_exit+0x0/0x40
>
> -> #0 (&ehea_fw_handles.lock){--..}:
>       [<c0000000000a8590>] .__lock_acquire+0x7e0/0x8a8
>       [<c0000000000a86ac>] .lock_acquire+0x54/0x80
>       [<c0000000005d7564>] .mutex_lock_nested+0x190/0x46c
>       [<d000000002a13e30>] .ehea_up+0x64/0x6e0 [ehea]
>       [<d000000002a15364>] .ehea_open+0x64/0xc4 [ehea]
>       [<c000000000537834>] .dev_open+0xf4/0x168
>       [<c000000000535780>] .dev_change_flags+0xe4/0x1e8
>       [<c000000000597bfc>] .devinet_ioctl+0x2c4/0x750
>       [<c0000000005997a8>] .inet_ioctl+0xcc/0x11c
>       [<c000000000523400>] .sock_ioctl+0x2f0/0x34c
>       [<c0000000001380ec>] .vfs_ioctl+0x5c/0xf0
>       [<c000000000138810>] .do_vfs_ioctl+0x690/0x70c
>       [<c000000000138900>] .SyS_ioctl+0x74/0xb8
>       [<c00000000016fb08>] .dev_ifsioc+0x210/0x4b8
>       [<c00000000016ef18>] .compat_sys_ioctl+0x3f4/0x488
>       [<c00000000000855c>] syscall_exit+0x0/0x40
>
> other info that might help us debug this:
>
> 2 locks held by ip/2174:
> #0:  (rtnl_mutex){--..}, at: [<c0000000005430a8>] .rtnl_lock+0x20/0x38
> #1:  (&port->port_lock){--..}, at: [<d000000002a1533c>]
> .ehea_open+0x3c/0xc4
> [ehea]
>
> stack backtrace:
> Call Trace:
> [c00000004246b070] [c00000000001154c] .show_stack+0x70/0x184 (unreliable)
> [c00000004246b120] [c0000000000a6ee4] .print_circular_bug_tail+0xd8/0xfc
> [c00000004246b1f0] [c0000000000a76ec] .validate_chain+0x7e4/0xea8
> [c00000004246b2b0] [c0000000000a8590] .__lock_acquire+0x7e0/0x8a8
> [c00000004246b3a0] [c0000000000a86ac] .lock_acquire+0x54/0x80
> [c00000004246b430] [c0000000005d7564] .mutex_lock_nested+0x190/0x46c
> [c00000004246b510] [d000000002a13e30] .ehea_up+0x64/0x6e0 [ehea]
> [c00000004246b610] [d000000002a15364] .ehea_open+0x64/0xc4 [ehea]
> [c00000004246b6b0] [c000000000537834] .dev_open+0xf4/0x168
> [c00000004246b740] [c000000000535780] .dev_change_flags+0xe4/0x1e8
> [c00000004246b7f0] [c000000000597bfc] .devinet_ioctl+0x2c4/0x750
> [c00000004246b8f0] [c0000000005997a8] .inet_ioctl+0xcc/0x11c
> [c00000004246b960] [c000000000523400] .sock_ioctl+0x2f0/0x34c
> [c00000004246ba00] [c0000000001380ec] .vfs_ioctl+0x5c/0xf0
> [c00000004246baa0] [c000000000138810] .do_vfs_ioctl+0x690/0x70c
> [c00000004246bb80] [c000000000138900] .SyS_ioctl+0x74/0xb8
> [c00000004246bc30] [c00000000016fb08] .dev_ifsioc+0x210/0x4b8
> [c00000004246bd40] [c00000000016ef18] .compat_sys_ioctl+0x3f4/0x488
> [c00000004246be30] [c00000000000855c] syscall_exit+0x0/0x40
> ehea: eth2: Physical port up
>
> Thanks
> -Sachin
>

