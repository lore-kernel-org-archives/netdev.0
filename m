From: Dave Jones <davej@codemonkey.org.uk>
Subject: 3.19-rc7 netconsole locking bug.
Date: Wed, 4 Feb 2015 14:39:02 -0500
Message-ID: <20150204193902.GB652@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:33115 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161475AbbBDUhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 15:37:37 -0500
Received: from arcturus.ipv6.aphlor.org ([2a03:9800:10:4a::2] helo=codemonkey.org.uk)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:AES128-GCM-SHA256:128)
	(Exim 4.80.1)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1YJ5mx-0000H3-Pw
	for netdev@vger.kernel.org; Wed, 04 Feb 2015 19:39:04 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I set up netconsole this morning, and noticed when I rebooted the machine
that this happens when it initializes..


netpoll: netconsole: local port 6666
netpoll: netconsole: local IPv4 address 192.168.42.1
netpoll: netconsole: interface 'eth1'
netpoll: netconsole: remote port 6666
netpoll: netconsole: remote IPv4 address 192.168.42.35
netpoll: netconsole: remote ethernet address 80:ee:73:83:57:4c
netpoll: netconsole: device eth1 not up yet, forcing it
IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready

BUG: sleeping function called from invalid context at kernel/irq/manage.c:104
in_atomic(): 1, irqs_disabled(): 1, pid: 157, name: exe
2 locks held by exe/157:
 #0:  (console_lock){+.+.+.}, at: [<ffffffff9510f516>] register_console+0x2a6/0x640
 #1:  (target_list_lock){......}, at: [<ffffffffc017e1c5>] write_msg+0x65/0x1b0 [netconsole]
irq event stamp: 13456
hardirqs last  enabled at (13455): [<ffffffff9510ee3d>] console_unlock+0x57d/0x740
hardirqs last disabled at (13456): [<ffffffff959b242a>] _raw_spin_lock_irqsave+0x3a/0x110
softirqs last  enabled at (10536): [<ffffffff957d7975>] __dev_mc_add+0x95/0xb0
softirqs last disabled at (10522): [<ffffffff957d7913>] __dev_mc_add+0x33/0xb0
CPU: 1 PID: 157 Comm: exe Not tainted 3.19.0-rc7+ #13
 ffffffff95d3d363 0000000049b1ff09 ffff88007707f978 ffffffff959a5efa
 0000000000000000 0000000000000000 ffff88007707f9a8 ffffffff950ca277
 ffff88007707f9a8 ffffffff95d3d363 0000000000000068 0000000000000000
Call Trace:
 [<ffffffff959a5efa>] dump_stack+0x84/0xb9
 [<ffffffff950ca277>] ___might_sleep+0x2d7/0x390
 [<ffffffff950ca3b0>] __might_sleep+0x80/0x100
 [<ffffffff951123f7>] synchronize_irq+0x67/0x120
 [<ffffffff951125a9>] ? __disable_irq_nosync+0x69/0xc0
 [<ffffffff95112634>] disable_irq+0x34/0x50
 [<ffffffff956c93f5>] e1000_netpoll+0x55/0x1d0
 [<ffffffff957fc3f9>] netpoll_poll_dev+0x99/0x300
 [<ffffffff957fc83f>] netpoll_send_skb_on_dev+0x1df/0x470
 [<ffffffff957fcddc>] netpoll_send_udp+0x30c/0x5a0
 [<ffffffffc017e1c5>] ? write_msg+0x65/0x1b0 [netconsole]
 [<ffffffffc017e267>] write_msg+0x107/0x1b0 [netconsole]
 [<ffffffff9510dad9>] call_console_drivers.constprop.10+0x129/0x190
 [<ffffffff9510edf4>] console_unlock+0x534/0x740
 [<ffffffff9510f5c8>] register_console+0x358/0x640
 [<ffffffffc0186000>] ? 0xffffffffc0186000
 [<ffffffffc01862ea>] init_netconsole+0x2ea/0x1000 [netconsole]
 [<ffffffff9500038d>] do_one_initcall+0x13d/0x310
 [<ffffffff95103d4e>] ? trace_hardirqs_on+0x1e/0x30
 [<ffffffff95153895>] load_module+0x22f5/0x28d0
 [<ffffffff9514dcb0>] ? store_uevent+0x90/0x90
 [<ffffffff95153fc9>] SyS_init_module+0x159/0x200
 [<ffffffff959b3912>] system_call_fastpath+0x12/0x17
console [netcon0] enabled
netconsole: network logging started

Despite the positive sounding last two lines, nothing actually gets logged
over the netconsole.

	Dave
