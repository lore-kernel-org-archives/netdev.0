From: "Sachin P. Sant" <sachinp@in.ibm.com>
Subject: [Powerpc / eHEA] Circular dependency with 2.6.29-rc6
Date: Mon, 23 Feb 2009 14:17:12 +0530
Message-ID: <49A26290.60607@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: TKLEIN@de.ibm.com, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Mel Gorman <mel@csn.ul.ie>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
To: linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:56800 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbZBWIrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 03:47:48 -0500
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n1N8lExs015864
	for <netdev@vger.kernel.org>; Mon, 23 Feb 2009 14:17:14 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1N8iR8K4206844
	for <netdev@vger.kernel.org>; Mon, 23 Feb 2009 14:14:27 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n1N8lDoe018867
	for <netdev@vger.kernel.org>; Mon, 23 Feb 2009 19:47:14 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While booting 2.6.29-rc6 on a powerpc box came across this
circular dependency with eHEA driver.

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.29-rc6 #2
-------------------------------------------------------
ip/2174 is trying to acquire lock:
 (&ehea_fw_handles.lock){--..}, at: [<d000000002a13e30>] .ehea_up+0x64/0x6e0
[ehea]

but task is already holding lock:
 (&port->port_lock){--..}, at: [<d000000002a1533c>] .ehea_open+0x3c/0xc4 [ehea]

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&port->port_lock){--..}:
 [<c0000000000a8590>] .__lock_acquire+0x7e0/0x8a8
       [<c0000000000a86ac>] .lock_acquire+0x54/0x80
       [<c0000000005d7564>] .mutex_lock_nested+0x190/0x46c
       [<d000000002a1533c>] .ehea_open+0x3c/0xc4 [ehea]
       [<c000000000537834>] .dev_open+0xf4/0x168
       [<c000000000535780>] .dev_change_flags+0xe4/0x1e8
       [<c000000000597bfc>] .devinet_ioctl+0x2c4/0x750
       [<c0000000005997a8>] .inet_ioctl+0xcc/0x11c
       [<c000000000523400>] .sock_ioctl+0x2f0/0x34c
       [<c0000000001380ec>] .vfs_ioctl+0x5c/0xf0
       [<c000000000138810>] .do_vfs_ioctl+0x690/0x70c
       [<c000000000138900>] .SyS_ioctl+0x74/0xb8
       [<c00000000016fb08>] .dev_ifsioc+0x210/0x4b8
       [<c00000000016ef18>] .compat_sys_ioctl+0x3f4/0x488
       [<c00000000000855c>] syscall_exit+0x0/0x40

-> #1 (rtnl_mutex){--..}:
       [<c0000000000a8590>] .__lock_acquire+0x7e0/0x8a8
       [<c0000000000a86ac>] .lock_acquire+0x54/0x80
       [<c0000000005d7564>] .mutex_lock_nested+0x190/0x46c
       [<c0000000005430a8>] .rtnl_lock+0x20/0x38
       [<c00000000053677c>] .register_netdev+0x1c/0x80
       [<d000000002a12714>] .ehea_setup_single_port+0x2c8/0x3d0 [ehea]
       [<d000000002a19da8>] .ehea_probe_adapter+0x288/0x394 [ehea]
       [<c00000000051f034>] .of_platform_device_probe+0x78/0x86c
       [<c00000000047faec>] .driver_probe_device+0x13c/0x200
       [<c00000000047fc44>] .__driver_attach+0x94/0xd8
       [<c00000000047eab4>] .bus_for_each_dev+0x80/0xd8
       [<c00000000047f850>] .driver_attach+0x28/0x40
       [<c00000000047f23c>] .bus_add_driver+0xd4/0x284
       [<c00000000047ff7c>] .driver_register+0xc4/0x198
       [<c00000000051eeec>] .of_register_driver+0x4c/0x60
       [<c000000000024da4>] .ibmebus_register_driver+0x30/0x4c
       [<d000000002a1a090>] .ehea_module_init+0x1dc/0x234c [ehea]
       [<c000000000009368>] .do_one_initcall+0x90/0x1b0
       [<c0000000000b2f24>] .SyS_init_module+0xc8/0x220
       [<c00000000000855c>] syscall_exit+0x0/0x40

-> #0 (&ehea_fw_handles.lock){--..}:
       [<c0000000000a8590>] .__lock_acquire+0x7e0/0x8a8
       [<c0000000000a86ac>] .lock_acquire+0x54/0x80
       [<c0000000005d7564>] .mutex_lock_nested+0x190/0x46c
       [<d000000002a13e30>] .ehea_up+0x64/0x6e0 [ehea]
       [<d000000002a15364>] .ehea_open+0x64/0xc4 [ehea]
       [<c000000000537834>] .dev_open+0xf4/0x168
       [<c000000000535780>] .dev_change_flags+0xe4/0x1e8
       [<c000000000597bfc>] .devinet_ioctl+0x2c4/0x750
       [<c0000000005997a8>] .inet_ioctl+0xcc/0x11c
       [<c000000000523400>] .sock_ioctl+0x2f0/0x34c
       [<c0000000001380ec>] .vfs_ioctl+0x5c/0xf0
       [<c000000000138810>] .do_vfs_ioctl+0x690/0x70c
       [<c000000000138900>] .SyS_ioctl+0x74/0xb8
       [<c00000000016fb08>] .dev_ifsioc+0x210/0x4b8
       [<c00000000016ef18>] .compat_sys_ioctl+0x3f4/0x488
       [<c00000000000855c>] syscall_exit+0x0/0x40

other info that might help us debug this:

2 locks held by ip/2174:
 #0:  (rtnl_mutex){--..}, at: [<c0000000005430a8>] .rtnl_lock+0x20/0x38
 #1:  (&port->port_lock){--..}, at: [<d000000002a1533c>] .ehea_open+0x3c/0xc4
[ehea]

stack backtrace:
Call Trace:
[c00000004246b070] [c00000000001154c] .show_stack+0x70/0x184 (unreliable)
[c00000004246b120] [c0000000000a6ee4] .print_circular_bug_tail+0xd8/0xfc
[c00000004246b1f0] [c0000000000a76ec] .validate_chain+0x7e4/0xea8
[c00000004246b2b0] [c0000000000a8590] .__lock_acquire+0x7e0/0x8a8
[c00000004246b3a0] [c0000000000a86ac] .lock_acquire+0x54/0x80
[c00000004246b430] [c0000000005d7564] .mutex_lock_nested+0x190/0x46c
[c00000004246b510] [d000000002a13e30] .ehea_up+0x64/0x6e0 [ehea]
[c00000004246b610] [d000000002a15364] .ehea_open+0x64/0xc4 [ehea]
[c00000004246b6b0] [c000000000537834] .dev_open+0xf4/0x168
[c00000004246b740] [c000000000535780] .dev_change_flags+0xe4/0x1e8
[c00000004246b7f0] [c000000000597bfc] .devinet_ioctl+0x2c4/0x750
[c00000004246b8f0] [c0000000005997a8] .inet_ioctl+0xcc/0x11c
[c00000004246b960] [c000000000523400] .sock_ioctl+0x2f0/0x34c
[c00000004246ba00] [c0000000001380ec] .vfs_ioctl+0x5c/0xf0
[c00000004246baa0] [c000000000138810] .do_vfs_ioctl+0x690/0x70c
[c00000004246bb80] [c000000000138900] .SyS_ioctl+0x74/0xb8
[c00000004246bc30] [c00000000016fb08] .dev_ifsioc+0x210/0x4b8
[c00000004246bd40] [c00000000016ef18] .compat_sys_ioctl+0x3f4/0x488
[c00000004246be30] [c00000000000855c] syscall_exit+0x0/0x40
ehea: eth2: Physical port up

Thanks
-Sachin

-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------

