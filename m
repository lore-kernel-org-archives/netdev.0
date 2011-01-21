From: Jongman Heo <jongman.heo@gmail.com>
Subject: [vmxnet3] possible irq lock inversion dependency detected
Date: Fri, 21 Jan 2011 09:44:46 +0000 (UTC)
Message-ID: <loom.20110121T104147-622@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:47392 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955Ab1AUJuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 04:50:06 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PgDd5-00075E-Mt
	for netdev@vger.kernel.org; Fri, 21 Jan 2011 10:50:04 +0100
Received: from 210.94.41.89 ([210.94.41.89])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 21 Jan 2011 10:50:03 +0100
Received: from jongman.heo by 210.94.41.89 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 21 Jan 2011 10:50:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm using Fedora 14 on VMWare.

With latest Linus git tree(2b1caf6ed7b888), following warnings are printed.

Is this a known issue? I don't know whether this is a regression or not.
This is my first time using vmxnet3 driver.

===============================================================
[   17.593243] NET: Registered protocol family 10
[   17.640420] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   18.418134] auditd (733): /proc/733/oom_adj is deprecated, please 
use /proc/733/oom_score_adj instead.
[   24.074627] eth0: intr type 3, mode 0, 5 vectors allocated
[   24.075450] eth0: NIC Link is Up 10000 Mbps
[   24.081505] 
[   24.081507] =========================================================
[   24.081693] [ INFO: possible irq lock inversion dependency detected ]
[   24.081797] 2.6.38-rc1+ #85
[   24.081914] ---------------------------------------------------------
[   24.082061] dbus-daemon/847 just changed the state of lock:
[   24.082200]  (&(&mc->mca_lock)->rlock){+.-...}, at: [<f85a034e>] 
mld_ifc_timer_expire+0x12a/0x1f2 [ipv6]
[   24.082488] but this lock took another, SOFTIRQ-unsafe lock in the past:
[   24.082690]  (&(&adapter->cmd_lock)->rlock){+.+...}
[   24.082769] 
[   24.082770] and interrupts could create inverse lock ordering between them.
[   24.082772] 
[   24.083196] 
[   24.083197] other info that might help us debug this:
[   24.083415] 3 locks held by dbus-daemon/847:
[   24.083538]  #0:  (&mm->mmap_sem){++++++}, at: [<c07d49ea>] 
do_page_fault+0x140/0x33b
[   24.083799]  #1:  (&idev->mc_ifc_timer){+.-...}, at: [<c04459c7>] 
run_timer_softirq+0x11c/0x268
[   24.084081]  #2:  (&ndev->lock){++.-..}, at: [<f85a023f>] 
mld_ifc_timer_expire+0x1b/0x1f2 [ipv6]
[   24.084364] 
[   24.084365] the shortest dependencies between 2nd lock and 1st lock:
[   24.084659]   -> (&(&adapter->cmd_lock)->rlock){+.+...} ops: 28 {
[   24.084826]      HARDIRQ-ON-W at:
[   24.084987]                                            [<c0461e11>] 
__lock_acquire+0x2d9/0xbf2
[   24.085302]                                            [<c0462b5f>] 
lock_acquire+0xb7/0xd7
[   24.085507]                                            [<c07d1835>] 
_raw_spin_lock+0x33/0x40
[   24.085708]                                            [<f855e2bf>] 
vmxnet3_alloc_intr_resources+0x18/0x1c1 [vmxnet3]
[   24.085964]                                            [<f8562b23>] 
vmxnet3_probe_device+0x503/0x712 [vmxnet3]
[   24.086180]                                            [<c05f645a>] 
local_pci_probe+0x2f/0x5a
[   24.086382]                                            [<c05f68ed>] 
pci_device_probe+0x48/0x6b
[   24.086582]                                            [<c067f87a>] 
driver_probe_device+0x115/0x1ec
[   24.086788]                                            [<c067f990>] 
__driver_attach+0x3f/0x5b
[   24.087014]                                            [<c067eb28>] 
bus_for_each_dev+0x3d/0x60
[   24.087214]                                            [<c067f50e>] 
driver_attach+0x19/0x1b
[   24.087411]                                            [<c067f1a4>] 
bus_add_driver+0xbd/0x215
[   24.087611]                                            [<c067fb61>] 
driver_register+0x7f/0xde
[   24.087811]                                            [<c05f6adb>] 
__pci_register_driver+0x4c/0xa9
[   24.088046]                                            [<f8568036>] 
0xf8568036
[   24.088238]                                            [<c0401268>] 
do_one_initcall+0x87/0x143
[   24.088439]                                            [<c046b0a6>] 
sys_init_module+0x130d/0x14aa
[   24.088643]                                            [<c040319f>] 
sysenter_do_call+0x12/0x38
[   24.088844]      SOFTIRQ-ON-W at:
[   24.115469]                                            [<c0461e30>] 
__lock_acquire+0x2f8/0xbf2
[   24.115483]                                            [<c0462b5f>] 
lock_acquire+0xb7/0xd7
[   24.115486]                                            [<c07d1835>] 
_raw_spin_lock+0x33/0x40
[   24.115493]                                            [<f855e2bf>] 
vmxnet3_alloc_intr_resources+0x18/0x1c1 [vmxnet3]
[   24.115508]                                            [<f8562b23>] 
vmxnet3_probe_device+0x503/0x712 [vmxnet3]
[   24.115513]                                            [<c05f645a>] 
local_pci_probe+0x2f/0x5a
[   24.115519]                                            [<c05f68ed>] 
pci_device_probe+0x48/0x6b
[   24.115523]                                            [<c067f87a>] 
driver_probe_device+0x115/0x1ec
[   24.115529]                                            [<c067f990>] 
__driver_attach+0x3f/0x5b
[   24.115532]                                            [<c067eb28>] 
bus_for_each_dev+0x3d/0x60
[   24.115535]                                            [<c067f50e>] 
driver_attach+0x19/0x1b
[   24.115539]                                            [<c067f1a4>] 
bus_add_driver+0xbd/0x215
[   24.115542]                                            [<c067fb61>] 
driver_register+0x7f/0xde
[   24.115545]                                            [<c05f6adb>] 
__pci_register_driver+0x4c/0xa9
[   24.115555]                                            [<f8568036>] 
0xf8568036
[   24.115562]                                            [<c0401268>] 
do_one_initcall+0x87/0x143
[   24.115567]                                            [<c046b0a6>] 
sys_init_module+0x130d/0x14aa
[   24.115590]                                            [<c040319f>] 
sysenter_do_call+0x12/0x38
[   24.115596]      INITIAL USE at:
[   24.115598]                                           [<c0461e85>] 
__lock_acquire+0x34d/0xbf2
[   24.115602]                                           [<c0462b5f>] 
lock_acquire+0xb7/0xd7
[   24.115606]                                           [<c07d1835>] 
_raw_spin_lock+0x33/0x40
[   24.115609]                                           [<f855e2bf>] 
vmxnet3_alloc_intr_resources+0x18/0x1c1 [vmxnet3]
[   24.115614]                                           [<f8562b23>] 
vmxnet3_probe_device+0x503/0x712 [vmxnet3]
[   24.115619]                                           [<c05f645a>] 
local_pci_probe+0x2f/0x5a
[   24.115622]                                           [<c05f68ed>] 
pci_device_probe+0x48/0x6b
[   24.115626]                                           [<c067f87a>] 
driver_probe_device+0x115/0x1ec
[   24.115629]                                           [<c067f990>] 
__driver_attach+0x3f/0x5b
[   24.115633]                                           [<c067eb28>] 
bus_for_each_dev+0x3d/0x60
[   24.115636]                                           [<c067f50e>] 
driver_attach+0x19/0x1b
[   24.115639]                                           [<c067f1a4>] 
bus_add_driver+0xbd/0x215
[   24.115642]                                           [<c067fb61>] 
driver_register+0x7f/0xde
[   24.115645]                                           [<c05f6adb>] 
__pci_register_driver+0x4c/0xa9
[   24.115648]                                           [<f8568036>] 
0xf8568036
[   24.115652]                                           [<c0401268>] 
do_one_initcall+0x87/0x143
[   24.115655]                                           [<c046b0a6>] 
sys_init_module+0x130d/0x14aa
[   24.115659]                                           [<c040319f>] 
sysenter_do_call+0x12/0x38
[   24.115662]    }
[   24.115663]    ... key      at: [<f8564580>] __key.40447+0x0/0xffffe7b2 
[vmxnet3]
[   24.115668]    ... acquired at:
[   24.115670]    [<c0462b5f>] lock_acquire+0xb7/0xd7
[   24.115673]    [<c07d1920>] _raw_spin_lock_irqsave+0x40/0x50
[   24.115676]    [<f855f494>] vmxnet3_set_mc+0x11a/0x165 [vmxnet3]
[   24.115684]    [<c0751f4d>] __dev_set_rx_mode+0x76/0x7a
[   24.115689]    [<c0751f6c>] dev_set_rx_mode+0x1b/0x26
[   24.115692]    [<c0752014>] __dev_open+0x9d/0xaf
[   24.115694]    [<c07521e6>] __dev_change_flags+0x98/0x10d
[   24.115697]    [<c07522c1>] dev_change_flags+0x13/0x3f
[   24.115699]    [<c075ae71>] do_setlink+0x245/0x56b
[   24.115703]    [<c075b6a6>] rtnl_setlink+0xaa/0xc6
[   24.115706]    [<c075b90f>] rtnetlink_rcv_msg+0x1a0/0x1af
[   24.115709]    [<c07694fd>] netlink_rcv_skb+0x32/0x73
[   24.115712]    [<c075b3bc>] rtnetlink_rcv+0x1b/0x22
[   24.115714]    [<c0769098>] netlink_unicast+0xc4/0x120
[   24.115716]    [<c076934e>] netlink_sendmsg+0x25a/0x271
[   24.115719]    [<c074135e>] __sock_sendmsg+0x54/0x5b
[   24.115723]    [<c07419dd>] sock_sendmsg+0x95/0xac
[   24.115726]    [<c0742fbc>] sys_sendmsg+0x181/0x1e8
[   24.115729]    [<c074348c>] sys_socketcall+0x22c/0x287
[   24.115732]    [<c040319f>] sysenter_do_call+0x12/0x38
[   24.115735] 
[   24.115736]  -> (_xmit_ETHER){+.....} ops: 6 {
[   24.115741]     HARDIRQ-ON-W at:
[   24.115742]                                          [<c0461e11>] 
__lock_acquire+0x2d9/0xbf2
[   24.115746]                                          [<c0462b5f>] 
lock_acquire+0xb7/0xd7
[   24.115750]                                          [<c07d1a20>] 
_raw_spin_lock_bh+0x38/0x45
[   24.115753]                                          [<c07553cd>] 
__dev_mc_add+0x23/0x61
[   24.115761]                                          [<c0755424>] 
dev_mc_add+0xa/0xc
[   24.115764]                                          [<f85a0bb9>] 
igmp6_group_added+0x56/0x139 [ipv6]
[   24.115784]                                          [<f85a114f>] 
ipv6_dev_mc_inc+0x1fb/0x20c [ipv6]
[   24.115799]                                          [<f858d0f9>] 
ipv6_add_dev+0x26d/0x28b [ipv6]
[   24.115834]                                          [<f8590007>] 
addrconf_notify+0x57/0x52c [ipv6]
[   24.115848]                                          [<c074ec2a>] 
register_netdevice_notifier+0x54/0x14e
[   24.115852]                                          [<f866b324>] 0xf866b324
[   24.115856]                                          [<f866b18a>] 0xf866b18a
[   24.115859]                                          [<c0401268>] 
do_one_initcall+0x87/0x143
[   24.115862]                                          [<c046b0a6>] 
sys_init_module+0x130d/0x14aa
[   24.115867]                                          [<c040319f>] 
sysenter_do_call+0x12/0x38
[   24.115870]     INITIAL USE at:
[   24.115872]                                         [<c0461e85>] 
__lock_acquire+0x34d/0xbf2
[   24.115876]                                         [<c0462b5f>] 
lock_acquire+0xb7/0xd7
[   24.115880]                                         [<c07d1a20>] 
_raw_spin_lock_bh+0x38/0x45
[   24.115884]                                         [<c07553cd>] 
__dev_mc_add+0x23/0x61
[   24.115887]                                         [<c0755424>] 
dev_mc_add+0xa/0xc
[   24.115891]                                         [<f85a0bb9>] 
igmp6_group_added+0x56/0x139 [ipv6]
[   24.115911]                                         [<f85a114f>] 
ipv6_dev_mc_inc+0x1fb/0x20c [ipv6]
[   24.115926]                                         [<f858d0f9>] 
ipv6_add_dev+0x26d/0x28b [ipv6]
[   24.115939]                                         [<f8590007>] 
addrconf_notify+0x57/0x52c [ipv6]
[   24.115951]                                         [<c074ec2a>] 
register_netdevice_notifier+0x54/0x14e
[   24.115954]                                         [<f866b324>] 0xf866b324
[   24.115957]                                         [<f866b18a>] 0xf866b18a
[   24.115960]                                         [<c0401268>] 
do_one_initcall+0x87/0x143
[   24.115963]                                         [<c046b0a6>] 
sys_init_module+0x130d/0x14aa
[   24.115966]                                         [<c040319f>] 
sysenter_do_call+0x12/0x38
[   24.115970]   }
[   24.115971]   ... key      at: [<c10308b8>] netdev_addr_lock_key+0x8/0x1d0
[   24.115985]   ... acquired at:
[   24.115986]    [<c0462b5f>] lock_acquire+0xb7/0xd7
[   24.115990]    [<c07d1a20>] _raw_spin_lock_bh+0x38/0x45
[   24.115992]    [<c07553cd>] __dev_mc_add+0x23/0x61
[   24.115995]    [<c0755424>] dev_mc_add+0xa/0xc
[   24.115997]    [<f85a0bb9>] igmp6_group_added+0x56/0x139 [ipv6]
[   24.116013]    [<f85a114f>] ipv6_dev_mc_inc+0x1fb/0x20c [ipv6]
[   24.116027]    [<f858d0f9>] ipv6_add_dev+0x26d/0x28b [ipv6]
[   24.116039]    [<f8590007>] addrconf_notify+0x57/0x52c [ipv6]
[   24.116051]    [<c074ec2a>] register_netdevice_notifier+0x54/0x14e
[   24.116054]    [<f866b324>] 0xf866b324
[   24.116056]    [<f866b18a>] 0xf866b18a
[   24.116058]    [<c0401268>] do_one_initcall+0x87/0x143
[   24.116061]    [<c046b0a6>] sys_init_module+0x130d/0x14aa
[   24.116064]    [<c040319f>] sysenter_do_call+0x12/0x38
[   24.116067] 
[   24.116068] -> (&(&mc->mca_lock)->rlock){+.-...} ops: 6 {
[   24.116071]    HARDIRQ-ON-W at:
[   24.116073]                                        [<c0461e11>] 
__lock_acquire+0x2d9/0xbf2
[   24.116077]                                        [<c0462b5f>] 
lock_acquire+0xb7/0xd7
[   24.116080]                                        [<c07d1a20>] 
_raw_spin_lock_bh+0x38/0x45
[   24.116083]                                        [<f85a0b8b>] 
igmp6_group_added+0x28/0x139 [ipv6]
[   24.116102]                                        [<f85a114f>] 
ipv6_dev_mc_inc+0x1fb/0x20c [ipv6]
[   24.116118]                                        [<f858d0f9>] 
ipv6_add_dev+0x26d/0x28b [ipv6]
[   24.116130]                                        [<f866b2f0>] 0xf866b2f0
[   24.116133]                                        [<f866b18a>] 0xf866b18a
[   24.116136]                                        [<c0401268>] 
do_one_initcall+0x87/0x143
[   24.116139]                                        [<c046b0a6>] 
sys_init_module+0x130d/0x14aa
[   24.116143]                                        [<c040319f>] 
sysenter_do_call+0x12/0x38
[   24.116146]    IN-SOFTIRQ-W at:
[   24.116148]                                        [<c0461dbc>] 
__lock_acquire+0x284/0xbf2
[   24.116151]                                        [<c0462b5f>] 
lock_acquire+0xb7/0xd7
[   24.116154]                                        [<c07d1a20>] 
_raw_spin_lock_bh+0x38/0x45
[   24.116158]                                        [<f85a034e>] 
mld_ifc_timer_expire+0x12a/0x1f2 [ipv6]
[   24.116173]                                        [<c0445a4a>] 
run_timer_softirq+0x19f/0x268
[   24.116180]                                        [<c043fd5b>] 
__do_softirq+0xa9/0x16a
[   24.116183]    INITIAL USE at:
[   24.116185]                                       [<c0461e85>] 
__lock_acquire+0x34d/0xbf2
[   24.116188]                                       [<c0462b5f>] 
lock_acquire+0xb7/0xd7
[   24.116191]                                       [<c07d1a20>] 
_raw_spin_lock_bh+0x38/0x45
[   24.116195]                                       [<f85a0b8b>] 
igmp6_group_added+0x28/0x139 [ipv6]
[   24.116210]                                       [<f85a114f>] 
ipv6_dev_mc_inc+0x1fb/0x20c [ipv6]
[   24.116226]                                       [<f858d0f9>] 
ipv6_add_dev+0x26d/0x28b [ipv6]
[   24.116238]                                       [<f866b2f0>] 0xf866b2f0
[   24.116241]                                       [<f866b18a>] 0xf866b18a
[   24.116244]                                       [<c0401268>] 
do_one_initcall+0x87/0x143
[   24.116247]                                       [<c046b0a6>] 
sys_init_module+0x130d/0x14aa
[   24.116251]                                       [<c040319f>] 
sysenter_do_call+0x12/0x38
[   24.116254]  }
[   24.116255]  ... key      at: [<f85b382c>] __key.38329+0x0/0xffff9cd8 [ipv6]
[   24.116266]  ... acquired at:
[   24.116268]    [<c046135b>] check_usage_forwards+0x6f/0x77
[   24.116271]    [<c0461a70>] mark_lock+0xf3/0x1bb
[   24.116273]    [<c0461dbc>] __lock_acquire+0x284/0xbf2
[   24.116276]    [<c0462b5f>] lock_acquire+0xb7/0xd7
[   24.116279]    [<c07d1a20>] _raw_spin_lock_bh+0x38/0x45
[   24.116282]    [<f85a034e>] mld_ifc_timer_expire+0x12a/0x1f2 [ipv6]
[   24.116296]    [<c0445a4a>] run_timer_softirq+0x19f/0x268
[   24.116299]    [<c043fd5b>] __do_softirq+0xa9/0x16a
[   24.116302] 
[   24.116303] 
[   24.116303] stack backtrace:
[   24.116307] Pid: 847, comm: dbus-daemon Not tainted 2.6.38-rc1+ #85
[   24.116309] Call Trace:
[   24.116314]  [<c04612e2>] ? print_irq_inversion_bug+0xfc/0x106
[   24.116317]  [<c046135b>] ? check_usage_forwards+0x6f/0x77
[   24.116320]  [<c0461a70>] ? mark_lock+0xf3/0x1bb
[   24.116323]  [<c04612ec>] ? check_usage_forwards+0x0/0x77
[   24.116327]  [<c0461dbc>] ? __lock_acquire+0x284/0xbf2
[   24.116330]  [<c04607f5>] ? save_trace+0x37/0x93
[   24.116333]  [<c046267c>] ? __lock_acquire+0xb44/0xbf2
[   24.116348]  [<f85a034e>] ? mld_ifc_timer_expire+0x12a/0x1f2 [ipv6]
[   24.116352]  [<c0462b5f>] ? lock_acquire+0xb7/0xd7
[   24.116366]  [<f85a034e>] ? mld_ifc_timer_expire+0x12a/0x1f2 [ipv6]
[   24.116370]  [<c07d1a20>] ? _raw_spin_lock_bh+0x38/0x45
[   24.116385]  [<f85a034e>] ? mld_ifc_timer_expire+0x12a/0x1f2 [ipv6]
[   24.116400]  [<f85a034e>] ? mld_ifc_timer_expire+0x12a/0x1f2 [ipv6]
[   24.116403]  [<c04459c7>] ? run_timer_softirq+0x11c/0x268
[   24.116410]  [<c0445a4a>] ? run_timer_softirq+0x19f/0x268
[   24.116413]  [<c04459c7>] ? run_timer_softirq+0x11c/0x268
[   24.116428]  [<f85a0224>] ? mld_ifc_timer_expire+0x0/0x1f2 [ipv6]
[   24.116432]  [<c043fd5b>] ? __do_softirq+0xa9/0x16a
[   24.116434]  [<c043fcb2>] ? __do_softirq+0x0/0x16a
[   24.116436]  <IRQ>  [<c043fead>] ? irq_exit+0x38/0x6c
[   24.116443]  [<c0419e71>] ? smp_apic_timer_interrupt+0x66/0x73
[   24.116447]  [<c05e6cc0>] ? trace_hardirqs_off_thunk+0xc/0x10
[   24.116451]  [<c07d2522>] ? apic_timer_interrupt+0x36/0x3c
[   24.116456]  [<c04bb9d7>] ? copy_user_highpage.clone.44+0x21/0x34
[   24.116459]  [<c04bc87a>] ? do_wp_page+0x397/0x514
[   24.116462]  [<c07d183c>] ? _raw_spin_lock+0x3a/0x40
[   24.116465]  [<c04be2a8>] ? handle_pte_fault+0x67f/0x6ea
[   24.116468]  [<c04be3bf>] ? handle_mm_fault+0xac/0xb8
[   24.116472]  [<c07d4bcd>] ? do_page_fault+0x323/0x33b
[   24.116475]  [<c0462b77>] ? lock_acquire+0xcf/0xd7
[   24.116478]  [<c07d205d>] ? restore_all_notrace+0x0/0x18
[   24.116481]  [<c04601a3>] ? trace_hardirqs_off_caller+0x2e/0x86
[   24.116484]  [<c07d48aa>] ? do_page_fault+0x0/0x33b
[   24.116487]  [<c07d27a4>] ? error_code+0x6c/0x74
[   24.550299] RPC: Registered udp transport module.
[   24.550405] RPC: Registered tcp transport module.
[   24.550498] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   28.499064] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   28.725260] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery 
directory
[   28.783996] NFSD: starting 90-second grace period
[   33.488381] Bridge firewalling registered
[   34.443551] ------------[ cut here ]------------
[   34.443561] WARNING: at net/core/dev.c:1351 dev_disable_lro+0x54/0x57()
[   34.443563] Hardware name: VMware Virtual Platform
[   34.443565] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat bridge stp 
llc nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc xt_physdev 
nf_conntrack_tftp nf_conntrack_netbios_ns ip6t_REJECT nf_conntrack_ipv6 
nf_defrag_ipv6 ip6table_filter ip6_tables ipv6 vmhgfs uinput snd_ens1371 
gameport snd_rawmidi snd_ac97_codec ac97_bus snd_seq snd_seq_device snd_pcm 
snd_timer microcode vmxnet3 vmci snd soundcore snd_page_alloc i2c_piix4 mptspi 
mptscsih mptbase scsi_transport_spi [last unloaded: scsi_wait_scan]
[   34.443605] Pid: 1358, comm: libvirtd Not tainted 2.6.38-rc1+ #85
[   34.443607] Call Trace:
[   34.443615]  [<c043a801>] ? warn_slowpath_common+0x77/0x8c
[   34.443618]  [<c074d8cb>] ? dev_disable_lro+0x54/0x57
[   34.443620]  [<c074d8cb>] ? dev_disable_lro+0x54/0x57
[   34.443623]  [<c043a833>] ? warn_slowpath_null+0x1d/0x1f
[   34.443626]  [<c074d8cb>] ? dev_disable_lro+0x54/0x57
[   34.443630]  [<c079a574>] ? devinet_sysctl_forward+0xd5/0x139
[   34.443633]  [<c079a49f>] ? devinet_sysctl_forward+0x0/0x139
[   34.443638]  [<c051e889>] ? proc_sys_call_handler.clone.0+0x6a/0x89
[   34.443641]  [<c051e8a8>] ? proc_sys_write+0x0/0x22
[   34.443643]  [<c051e8c5>] ? proc_sys_write+0x1d/0x22
[   34.443649]  [<c04da9d8>] ? vfs_write+0x86/0xde
[   34.443651]  [<c04dba58>] ? fget_light+0x5f/0x66
[   34.443654]  [<c04daba6>] ? sys_write+0x3d/0x5e
[   34.443659]  [<c040319f>] ? sysenter_do_call+0x12/0x38
[   34.443662] ---[ end trace 06a697a570356b0c ]---

