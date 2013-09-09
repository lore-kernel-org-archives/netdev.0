From: Michal Kubecek <mkubecek@suse.cz>
Subject: RFC: crash in fib6_clean_all() while loading ipv6 module
Date: Mon, 9 Sep 2013 12:05:15 +0200
Message-ID: <20130909100515.GA16056@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38386 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871Ab3IIKFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 06:05:17 -0400
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 048D2A41E0
	for <netdev@vger.kernel.org>; Mon,  9 Sep 2013 12:05:16 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Two of our customers encountered a crash in fib6_clean_all() when
booting their system:

[   12.408421] BUG: unable to handle kernel NULL pointer dereference at        (null)
[   12.408424] IP: [<ffffffffa02566b4>] fib6_clean_all+0x34/0xd0 [ipv6_lib]
[   12.408434] PGD c3590f067 PUD c29073067 PMD 0 
[   12.408436] Oops: 0000 [#1] SMP 
[   12.408439] CPU 1 
[   12.408440] Modules linked in: processor(+) ipv6(+) thermal_sys ipv6_lib
ahci(+) ixgbe(+) ehci_hcd libahci hwmon igb(+) libata usbcore i2c_i801 dca
iTCO_wdt pcspkr scsi_mod e1000e i2c_core usb_common iTCO_vendor_support
rtc_cmos container ptp pps_core button mdio
[   12.408449] Supported: Yes
[   12.408449] 
[   12.408451] Pid: 211, comm: modprobe Not tainted 3.0.76-0.11-default #1 ...
[   12.408453] RIP: 0010:[<ffffffffa02566b4>]  [<ffffffffa02566b4>] fib6_clean_all+0x34/0xd0 [ipv6_lib]
[   12.408460] RSP: 0018:ffff880c1e983b98  EFLAGS: 00010246
[   12.408462] RAX: 0000000000000000 RBX: ffffffffffffffff RCX: 0000000000000000
[   12.408463] RDX: 0000000000000000 RSI: ffffffffa0254f90 RDI: ffffffff81a72280
[   12.408464] RBP: ffffffff81a72280 R08: 0000000000000000 R09: 000000003520aec8
[   12.408466] R10: 000000005f000c28 R11: 000000003520aec8 R12: 0000000000000000
[   12.408467] R13: ffffffff81a72280 R14: 0000000000000000 R15: ffffffffa0254f90
[   12.408469] FS:  00007fb2039f1700(0000) GS:ffff880c7f040000(0000) knlGS:0000000000000000
[   12.408470] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   12.408471] CR2: 0000000000000000 CR3: 0000000c2904e000 CR4: 00000000001407e0
[   12.408473] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   12.408474] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   12.408476] Process modprobe (pid: 211, threadinfo ffff880c1e982000, task ffff880c3242c540)
[   12.408477] Stack:
[   12.408478]  0000000000000000 0000000000000000 0000000000000000 ffffffff8146544e
[   12.408480]  000000000006a9d0 0000000000000000 000000003520aec8 000000005f000c28
[   12.408483]  000000003520aec8 0000000000000000 0000000000000000 0000000000000000
[   12.408485] Call Trace:
[   12.408507]  [<ffffffffa02567a3>] fib6_run_gc+0x53/0xf0 [ipv6_lib]
[   12.408524]  [<ffffffffa025c5c6>] ndisc_netdev_event+0x186/0x190 [ipv6_lib]
[   12.408541]  [<ffffffff81460437>] notifier_call_chain+0x37/0x70
[   12.408547]  [<ffffffff813a6e52>] dev_addr_add+0x52/0x90
[   12.408556]  [<ffffffffa032e3e9>] ixgbe_probe+0x8c9/0xd10 [ixgbe]
[   12.408565]  [<ffffffff8127d5d4>] local_pci_probe+0x54/0xe0
[   12.408570]  [<ffffffff8127d740>] __pci_device_probe+0xe0/0xf0
[   12.408573]  [<ffffffff8127e953>] pci_device_probe+0x33/0x60
[   12.408578]  [<ffffffff8132ddda>] really_probe+0x7a/0x260
[   12.408581]  [<ffffffff8132e023>] driver_probe_device+0x63/0xc0
[   12.408585]  [<ffffffff8132e113>] __driver_attach+0x93/0xa0
[   12.408588]  [<ffffffff8132d468>] bus_for_each_dev+0x88/0xb0
[   12.408591]  [<ffffffff8132cbb5>] bus_add_driver+0x155/0x2a0
[   12.408595]  [<ffffffff8132e769>] driver_register+0x79/0x170
[   12.408599]  [<ffffffff8127ebe8>] __pci_register_driver+0x58/0xe0
[   12.408604]  [<ffffffff810001cb>] do_one_initcall+0x3b/0x180
[   12.408610]  [<ffffffff810a02df>] sys_init_module+0xcf/0x240
[   12.408615]  [<ffffffff81464592>] system_call_fastpath+0x16/0x1b

The crash is caused by fib6_clean_all() dereferencing a null pointer in
init_net.ipv6.fib_table_hash because ndisc_netdev_event() handler which
calls fib6_run_gc() is registered by ndisc_init() but the relevant data
structures aren't initialized until ip6_route_init() is called. If a
device intialization falls into this window, it emits NETDEV_CHANGEADDR,
leading to a crash.

This could be prevented by setting a flag when ip6_route_init() is
complete and not calling fib6_run_gc() from ndisc_netdev_event() until
the flag is set. However, I don't like the idea of adding a test which
will be useful only in a short window while loading ipv6 module.

The only other actions ndisc_netdev_event() does are flushing the neigh
table (which should be empty at the moment) and calling
ndisc_send_unsol_na() (which should do nothing as there is no IPv6
address assigned yet). Thus I believe taking the netdev event handler
registration call out of ndisc_init() into a separate function, say
ndisc_late_init(), which would be called after ip6_route_init() should
be a safe and efficient way to avoid the race condition.

Before I submit the patch, I wanted to ask if someone can see a problem
with this solution (or a better solution).

                                                         Michal Kubecek
