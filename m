From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG net-2.6 vlan/bonding] lockdep splats
Date: Wed, 27 Oct 2010 12:24:30 +0200
Message-ID: <1288175070.2709.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45852 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757574Ab0J0KYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 06:24:35 -0400
Received: by wwe15 with SMTP id 15so600122wwe.1
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 03:24:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On latest net-2.6 kernel I got following splat, not sure its related to
vlan changes...

[   51.402912] tg3 0000:14:04.0: eth2: Link is up at 1000 Mbps, full duplex
[   51.402915] tg3 0000:14:04.0: eth2: Flow control is off for TX and off for RX
[   51.402993] ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
[   52.277993] bonding: bond0: Setting MII monitoring interval to 100.
[   52.278233] bonding: bond0: setting mode to active-backup (1).
[   52.280125] ADDRCONF(NETDEV_UP): bond0: link is not ready
[   52.280127] 8021q: adding VLAN 0 to HW filter on device bond0
[   52.526629] bnx2 0000:07:00.0: irq 42 for MSI/MSI-X
[   52.652352] bnx2 0000:07:00.0: eth1: using MSI
[   52.652542] bonding: bond0: enslaving eth1 as a backup interface with a down link.
[   52.930032] tg3 0000:14:04.0: BAR 0: set to [mem 0xfdff0000-0xfdffffff 64bit] (PCI address [0xfdff0000-0xfdffffff]
[   52.930045] tg3 0000:14:04.0: BAR 2: set to [mem 0xfdfe0000-0xfdfeffff 64bit] (PCI address [0xfdfe0000-0xfdfeffff]
[   52.930134] tg3 0000:14:04.0: irq 43 for MSI/MSI-X
[   52.959296] bonding: bond0: enslaving eth2 as a backup interface with a down link.
[   52.991401] 
[   52.991402] ======================================================
[   52.991511] [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
[   52.991569] 2.6.36-04573-g4b60626-dirty #65
[   52.991622] ------------------------------------------------------
[   52.991696] ip/4842 [HC0[0]:SC0[4]:HE1:SE0] is trying to acquire:
[   52.991758]  (&bond->lock){++++..}, at: [<efe4d300>] bond_set_multicast_list+0x60/0x2c0 [bonding]
[   52.991966] 
[   52.991967] and this task is already holding:
[   52.992008]  (&bonding_netdev_addr_lock_key){+.....}, at: [<c04e5530>] dev_mc_sync+0x50/0xa0
[   52.992008] which would create a new lock dependency:
[   52.992008]  (&bonding_netdev_addr_lock_key){+.....} -> (&bond->lock){++++..}
[   52.992008] 
[   52.992008] but this new dependency connects a SOFTIRQ-irq-safe lock:
[   52.992008]  (&(&mc->mca_lock)->rlock){+.-...}
[   52.992008] ... which became SOFTIRQ-irq-safe at:
[   52.992008]   [<c0272beb>] __lock_acquire+0x96b/0x1960
[   52.992008]   [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]   [<c05f356d>] _raw_spin_lock_bh+0x3d/0x50
[   52.992008]   [<c0584e40>] mld_ifc_timer_expire+0xf0/0x280
[   52.992008]   [<c024cee6>] run_timer_softirq+0x146/0x310
[   52.992008]   [<c024591d>] __do_softirq+0xad/0x1c0
[   52.992008] 
[   52.992008] to a SOFTIRQ-irq-unsafe lock:
[   52.992008]  (&bond->lock){++++..}
[   52.992008] ... which became SOFTIRQ-irq-unsafe at:
[   52.992008] ...  [<c0272c3b>] __lock_acquire+0x9bb/0x1960
[   52.992008]   [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]   [<c05f36b8>] _raw_write_lock+0x38/0x50
[   52.992008]   [<efe4cbe4>] bond_vlan_rx_register+0x24/0x70 [bonding]
[   52.992008]   [<c0598010>] register_vlan_dev+0xc0/0x280
[   52.992008]   [<c0599f3a>] vlan_newlink+0xaa/0xd0
[   52.992008]   [<c04ed4b4>] rtnl_newlink+0x404/0x490
[   52.992008]   [<c04ece35>] rtnetlink_rcv_msg+0x1e5/0x220
[   52.992008]   [<c050424e>] netlink_rcv_skb+0x8e/0xb0
[   52.992008]   [<c04ecbac>] rtnetlink_rcv+0x1c/0x30
[   52.992008]   [<c0503bfb>] netlink_unicast+0x24b/0x290
[   52.992008]   [<c0503e37>] netlink_sendmsg+0x1f7/0x310
[   52.992008]   [<c04cd41c>] sock_sendmsg+0xac/0xe0
[   52.992008]   [<c04ceb80>] sys_sendmsg+0x130/0x230
[   52.992008]   [<c04cf04e>] sys_socketcall+0xde/0x280
[   52.992008]   [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008] 
[   52.992008] other info that might help us debug this:
[   52.992008] 
[   52.992008] 3 locks held by ip/4842:
[   52.992008]  #0:  (rtnl_mutex){+.+.+.}, at: [<c04ecb84>] rtnl_lock+0x14/0x20
[   52.992008]  #1:  (&vlan_netdev_addr_lock_key){+.....}, at: [<c04e1181>] dev_set_rx_mode+0x21/0x40
[   52.992008]  #2:  (&bonding_netdev_addr_lock_key){+.....}, at: [<c04e5530>] dev_mc_sync+0x50/0xa0
[   52.992008] 
[   52.992008] the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
[   52.992008]  -> (&(&mc->mca_lock)->rlock){+.-...} ops: 44 {
[   52.992008]     HARDIRQ-ON-W at:
[   52.992008]                                          [<c0272c0f>] __lock_acquire+0x98f/0x1960
[   52.992008]                                          [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                          [<c05f356d>] _raw_spin_lock_bh+0x3d/0x50
[   52.992008]                                          [<c05856a8>] igmp6_group_added+0x28/0x140
[   52.992008]                                          [<c058618c>] ipv6_dev_mc_inc+0x26c/0x460
[   52.992008]                                          [<c056d754>] ipv6_add_dev+0x204/0x320
[   52.992008]                                          [<c082d80c>] addrconf_init+0x4b/0x153
[   52.992008]                                          [<c082d5ce>] inet6_init+0x17b/0x282
[   52.992008]                                          [<c0201125>] do_one_initcall+0x35/0x170
[   52.992008]                                          [<c08018ea>] kernel_init+0x113/0x1ae
[   52.992008]                                          [<c020323a>] kernel_thread_helper+0x6/0x10
[   52.992008]     IN-SOFTIRQ-W at:
[   52.992008]                                          [<c0272beb>] __lock_acquire+0x96b/0x1960
[   52.992008]                                          [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                          [<c05f356d>] _raw_spin_lock_bh+0x3d/0x50
[   52.992008]                                          [<c0584e40>] mld_ifc_timer_expire+0xf0/0x280
[   52.992008]                                          [<c024cee6>] run_timer_softirq+0x146/0x310
[   52.992008]                                          [<c024591d>] __do_softirq+0xad/0x1c0
[   52.992008]     INITIAL USE at:
[   52.992008]                                         [<c0272534>] __lock_acquire+0x2b4/0x1960
[   52.992008]                                         [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                         [<c05f356d>] _raw_spin_lock_bh+0x3d/0x50
[   52.992008]                                         [<c05856a8>] igmp6_group_added+0x28/0x140
[   52.992008]                                         [<c058618c>] ipv6_dev_mc_inc+0x26c/0x460
[   52.992008]                                         [<c056d754>] ipv6_add_dev+0x204/0x320
[   52.992008]                                         [<c082d80c>] addrconf_init+0x4b/0x153
[   52.992008]                                         [<c082d5ce>] inet6_init+0x17b/0x282
[   52.992008]                                         [<c0201125>] do_one_initcall+0x35/0x170
[   52.992008]                                         [<c08018ea>] kernel_init+0x113/0x1ae
[   52.992008]                                         [<c020323a>] kernel_thread_helper+0x6/0x10
[   52.992008]   }
[   52.992008]   ... key      at: [<c0e5c2d8>] __key.36358+0x0/0x8
[   52.992008]   ... acquired at:
[   52.992008]    [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]    [<c05f356d>] _raw_spin_lock_bh+0x3d/0x50
[   52.992008]    [<c04e5328>] __dev_mc_add+0x28/0x70
[   52.992008]    [<c04e539f>] dev_mc_add+0xf/0x20
[   52.992008]    [<c058572f>] igmp6_group_added+0xaf/0x140
[   52.992008]    [<c058618c>] ipv6_dev_mc_inc+0x26c/0x460
[   52.992008]    [<c056d754>] ipv6_add_dev+0x204/0x320
[   52.992008]    [<c0571274>] addrconf_notify+0x214/0x890
[   52.992008]    [<c02623d8>] notifier_call_chain+0x48/0x60
[   52.992008]    [<c02624cf>] raw_notifier_call_chain+0x1f/0x30
[   52.992008]    [<c04df63c>] call_netdevice_notifiers+0x2c/0x60
[   52.992008]    [<c04dffe7>] register_netdevice+0x3f7/0x4c0
[   52.992008]    [<efe52a27>] bond_create+0x97/0xd0 [bonding]
[   52.992008]    [<efc5593c>] 0xefc5593c
[   52.992008]    [<c0201125>] do_one_initcall+0x35/0x170
[   52.992008]    [<c027d5f4>] sys_init_module+0x124/0x1aa0
[   52.992008]    [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008] 
[   52.992008] -> (&bonding_netdev_addr_lock_key){+.....} ops: 7 {
[   52.992008]    HARDIRQ-ON-W at:
[   52.992008]                                        [<c0272c0f>] __lock_acquire+0x98f/0x1960
[   52.992008]                                        [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                        [<c05f356d>] _raw_spin_lock_bh+0x3d/0x50
[   52.992008]                                        [<c04e5328>] __dev_mc_add+0x28/0x70
[   52.992008]                                        [<c04e539f>] dev_mc_add+0xf/0x20
[   52.992008]                                        [<c058572f>] igmp6_group_added+0xaf/0x140
[   52.992008]                                        [<c058618c>] ipv6_dev_mc_inc+0x26c/0x460
[   52.992008]                                        [<c056d754>] ipv6_add_dev+0x204/0x320
[   52.992008]                                        [<c0571274>] addrconf_notify+0x214/0x890
[   52.992008]                                        [<c02623d8>] notifier_call_chain+0x48/0x60
[   52.992008]                                        [<c02624cf>] raw_notifier_call_chain+0x1f/0x30
[   52.992008]                                        [<c04df63c>] call_netdevice_notifiers+0x2c/0x60
[   52.992008]                                        [<c04dffe7>] register_netdevice+0x3f7/0x4c0
[   52.992008]                                        [<efe52a27>] bond_create+0x97/0xd0 [bonding]
[   52.992008]                                        [<efc5593c>] 0xefc5593c
[   52.992008]                                        [<c0201125>] do_one_initcall+0x35/0x170
[   52.992008]                                        [<c027d5f4>] sys_init_module+0x124/0x1aa0
[   52.992008]                                        [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008]    INITIAL USE at:
[   52.992008]                                       [<c0272534>] __lock_acquire+0x2b4/0x1960
[   52.992008]                                       [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                       [<c05f356d>] _raw_spin_lock_bh+0x3d/0x50
[   52.992008]                                       [<c04e5328>] __dev_mc_add+0x28/0x70
[   52.992008]                                       [<c04e539f>] dev_mc_add+0xf/0x20
[   52.992008]                                       [<c058572f>] igmp6_group_added+0xaf/0x140
[   52.992008]                                       [<c058618c>] ipv6_dev_mc_inc+0x26c/0x460
[   52.992008]                                       [<c056d754>] ipv6_add_dev+0x204/0x320
[   52.992008]                                       [<c0571274>] addrconf_notify+0x214/0x890
[   52.992008]                                       [<c02623d8>] notifier_call_chain+0x48/0x60
[   52.992008]                                       [<c02624cf>] raw_notifier_call_chain+0x1f/0x30
[   52.992008]                                       [<c04df63c>] call_netdevice_notifiers+0x2c/0x60
[   52.992008]                                       [<c04dffe7>] register_netdevice+0x3f7/0x4c0
[   52.992008]                                       [<efe52a27>] bond_create+0x97/0xd0 [bonding]
[   52.992008]                                       [<efc5593c>] 0xefc5593c
[   52.992008]                                       [<c0201125>] do_one_initcall+0x35/0x170
[   52.992008]                                       [<c027d5f4>] sys_init_module+0x124/0x1aa0
[   52.992008]                                       [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008]  }
[   52.992008]  ... key      at: [<efe5fecd>] bonding_netdev_addr_lock_key+0x0/0xffffaa0a [bonding]
[   52.992008]  ... acquired at:
[   52.992008]    [<c0270994>] check_irq_usage+0x54/0xe0
[   52.992008]    [<c02730a7>] __lock_acquire+0xe27/0x1960
[   52.992008]    [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]    [<c05f3958>] _raw_read_lock+0x38/0x50
[   52.992008]    [<efe4d300>] bond_set_multicast_list+0x60/0x2c0 [bonding]
[   52.992008]    [<c04e10f5>] __dev_set_rx_mode+0x35/0xa0
[   52.992008]    [<c04e556f>] dev_mc_sync+0x8f/0xa0
[   52.992008]    [<c0598b84>] vlan_dev_set_rx_mode+0x24/0x40
[   52.992008]    [<c04e10f5>] __dev_set_rx_mode+0x35/0xa0
[   52.992008]    [<c04e1188>] dev_set_rx_mode+0x28/0x40
[   52.992008]    [<c04e1255>] __dev_open+0xb5/0xf0
[   52.992008]    [<c04e14b4>] __dev_change_flags+0x84/0x160
[   52.992008]    [<c04e1633>] dev_change_flags+0x23/0x60
[   52.992008]    [<c04ebfb0>] do_setlink+0x170/0x700
[   52.992008]    [<c04ed425>] rtnl_newlink+0x375/0x490
[   52.992008]    [<c04ece35>] rtnetlink_rcv_msg+0x1e5/0x220
[   52.992008]    [<c050424e>] netlink_rcv_skb+0x8e/0xb0
[   52.992008]    [<c04ecbac>] rtnetlink_rcv+0x1c/0x30
[   52.992008]    [<c0503bfb>] netlink_unicast+0x24b/0x290
[   52.992008]    [<c0503e37>] netlink_sendmsg+0x1f7/0x310
[   52.992008]    [<c04cd41c>] sock_sendmsg+0xac/0xe0
[   52.992008]    [<c04ceb80>] sys_sendmsg+0x130/0x230
[   52.992008]    [<c04cf04e>] sys_socketcall+0xde/0x280
[   52.992008]    [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008] 
[   52.992008] 
[   52.992008] the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
[   52.992008] -> (&bond->lock){++++..} ops: 55 {
[   52.992008]    HARDIRQ-ON-W at:
[   52.992008]                                        [<c0272c0f>] __lock_acquire+0x98f/0x1960
[   52.992008]                                        [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                        [<c05f35bd>] _raw_write_lock_bh+0x3d/0x50
[   52.992008]                                        [<efe4cb0a>] bond_vlan_rx_add_vid+0x9a/0x150 [bonding]
[   52.992008]                                        [<c0597a20>] vlan_device_event+0x90/0x530
[   52.992008]                                        [<c02623d8>] notifier_call_chain+0x48/0x60
[   52.992008]                                        [<c02624cf>] raw_notifier_call_chain+0x1f/0x30
[   52.992008]                                        [<c04df63c>] call_netdevice_notifiers+0x2c/0x60
[   52.992008]                                        [<c04e15c3>] __dev_notify_flags+0x33/0x80
[   52.992008]                                        [<c04e164c>] dev_change_flags+0x3c/0x60
[   52.992008]                                        [<c053e8b1>] devinet_ioctl+0x591/0x6f0
[   52.992008]                                        [<c053fa32>] inet_ioctl+0xa2/0xd0
[   52.992008]                                        [<c04cccb8>] sock_ioctl+0x68/0x270
[   52.992008]                                        [<c02f48be>] do_vfs_ioctl+0x7e/0x5e0
[   52.992008]                                        [<c02f4e87>] sys_ioctl+0x67/0x80
[   52.992008]                                        [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008]    HARDIRQ-ON-R at:
[   52.992008]                                        [<c027279e>] __lock_acquire+0x51e/0x1960
[   52.992008]                                        [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                        [<c05f385d>] _raw_read_lock_bh+0x3d/0x50
[   52.992008]                                        [<efe4cd1f>] bond_get_stats+0x3f/0x1d0 [bonding]
[   52.992008]                                        [<c04dc3b5>] dev_get_stats+0x35/0xb0
[   52.992008]                                        [<c04eb6db>] rtnl_fill_ifinfo+0x32b/0x830
[   52.992008]                                        [<c04ecf6a>] rtmsg_ifinfo+0x6a/0xf0
[   52.992008]                                        [<c04e003c>] register_netdevice+0x44c/0x4c0
[   52.992008]                                        [<efe52a27>] bond_create+0x97/0xd0 [bonding]
[   52.992008]                                        [<efc5593c>] 0xefc5593c
[   52.992008]                                        [<c0201125>] do_one_initcall+0x35/0x170
[   52.992008]                                        [<c027d5f4>] sys_init_module+0x124/0x1aa0
[   52.992008]                                        [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008]    SOFTIRQ-ON-W at:
[   52.992008]                                        [<c0272c3b>] __lock_acquire+0x9bb/0x1960
[   52.992008]                                        [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                        [<c05f36b8>] _raw_write_lock+0x38/0x50
[   52.992008]                                        [<efe4cbe4>] bond_vlan_rx_register+0x24/0x70 [bonding]
[   52.992008]                                        [<c0598010>] register_vlan_dev+0xc0/0x280
[   52.992008]                                        [<c0599f3a>] vlan_newlink+0xaa/0xd0
[   52.992008]                                        [<c04ed4b4>] rtnl_newlink+0x404/0x490
[   52.992008]                                        [<c04ece35>] rtnetlink_rcv_msg+0x1e5/0x220
[   52.992008]                                        [<c050424e>] netlink_rcv_skb+0x8e/0xb0
[   52.992008]                                        [<c04ecbac>] rtnetlink_rcv+0x1c/0x30
[   52.992008]                                        [<c0503bfb>] netlink_unicast+0x24b/0x290
[   52.992008]                                        [<c0503e37>] netlink_sendmsg+0x1f7/0x310
[   52.992008]                                        [<c04cd41c>] sock_sendmsg+0xac/0xe0
[   52.992008]                                        [<c04ceb80>] sys_sendmsg+0x130/0x230
[   52.992008]                                        [<c04cf04e>] sys_socketcall+0xde/0x280
[   52.992008]                                        [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008]    SOFTIRQ-ON-R at:
[   52.992008]                                        [<c0272c3b>] __lock_acquire+0x9bb/0x1960
[   52.992008]                                        [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                        [<c05f3958>] _raw_read_lock+0x38/0x50
[   52.992008]                                        [<efe50664>] bond_mii_monitor+0x24/0x5f0 [bonding]
[   52.992008]                                        [<c0257d9d>] process_one_work+0x15d/0x420
[   52.992008]                                        [<c02586d4>] worker_thread+0x134/0x2d0
[   52.992008]                                        [<c025c564>] kthread+0x74/0x80
[   52.992008]                                        [<c020323a>] kernel_thread_helper+0x6/0x10
[   52.992008]    INITIAL USE at:
[   52.992008]                                       [<c0272534>] __lock_acquire+0x2b4/0x1960
[   52.992008]                                       [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]                                       [<c05f385d>] _raw_read_lock_bh+0x3d/0x50
[   52.992008]                                       [<efe4cd1f>] bond_get_stats+0x3f/0x1d0 [bonding]
[   52.992008]                                       [<c04dc3b5>] dev_get_stats+0x35/0xb0
[   52.992008]                                       [<c04eb6db>] rtnl_fill_ifinfo+0x32b/0x830
[   52.992008]                                       [<c04ecf6a>] rtmsg_ifinfo+0x6a/0xf0
[   52.992008]                                       [<c04e003c>] register_netdevice+0x44c/0x4c0
[   52.992008]                                       [<efe52a27>] bond_create+0x97/0xd0 [bonding]
[   52.992008]                                       [<efc5593c>] 0xefc5593c
[   52.992008]                                       [<c0201125>] do_one_initcall+0x35/0x170
[   52.992008]                                       [<c027d5f4>] sys_init_module+0x124/0x1aa0
[   52.992008]                                       [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008]  }
[   52.992008]  ... key      at: [<efe5fe5c>] __key.38049+0x0/0xffffaa7b [bonding]
[   52.992008]  ... acquired at:
[   52.992008]    [<c0270994>] check_irq_usage+0x54/0xe0
[   52.992008]    [<c02730a7>] __lock_acquire+0xe27/0x1960
[   52.992008]    [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]    [<c05f3958>] _raw_read_lock+0x38/0x50
[   52.992008]    [<efe4d300>] bond_set_multicast_list+0x60/0x2c0 [bonding]
[   52.992008]    [<c04e10f5>] __dev_set_rx_mode+0x35/0xa0
[   52.992008]    [<c04e556f>] dev_mc_sync+0x8f/0xa0
[   52.992008]    [<c0598b84>] vlan_dev_set_rx_mode+0x24/0x40
[   52.992008]    [<c04e10f5>] __dev_set_rx_mode+0x35/0xa0
[   52.992008]    [<c04e1188>] dev_set_rx_mode+0x28/0x40
[   52.992008]    [<c04e1255>] __dev_open+0xb5/0xf0
[   52.992008]    [<c04e14b4>] __dev_change_flags+0x84/0x160
[   52.992008]    [<c04e1633>] dev_change_flags+0x23/0x60
[   52.992008]    [<c04ebfb0>] do_setlink+0x170/0x700
[   52.992008]    [<c04ed425>] rtnl_newlink+0x375/0x490
[   52.992008]    [<c04ece35>] rtnetlink_rcv_msg+0x1e5/0x220
[   52.992008]    [<c050424e>] netlink_rcv_skb+0x8e/0xb0
[   52.992008]    [<c04ecbac>] rtnetlink_rcv+0x1c/0x30
[   52.992008]    [<c0503bfb>] netlink_unicast+0x24b/0x290
[   52.992008]    [<c0503e37>] netlink_sendmsg+0x1f7/0x310
[   52.992008]    [<c04cd41c>] sock_sendmsg+0xac/0xe0
[   52.992008]    [<c04ceb80>] sys_sendmsg+0x130/0x230
[   52.992008]    [<c04cf04e>] sys_socketcall+0xde/0x280
[   52.992008]    [<c0202d10>] sysenter_do_call+0x12/0x36
[   52.992008] 
[   52.992008] 
[   52.992008] stack backtrace:
[   52.992008] Pid: 4842, comm: ip Not tainted 2.6.36-04573-g4b60626-dirty #65
[   52.992008] Call Trace:
[   52.992008]  [<c05f00e8>] ? printk+0x1d/0x25
[   52.992008]  [<c02708b3>] check_usage+0x3d3/0x460
[   52.992008]  [<c027a9a0>] ? __module_text_address+0x10/0x60
[   52.992008]  [<c0270994>] check_irq_usage+0x54/0xe0
[   52.992008]  [<c02730a7>] __lock_acquire+0xe27/0x1960
[   52.992008]  [<c027415e>] lock_acquire+0x7e/0xf0
[   52.992008]  [<efe4d300>] ? bond_set_multicast_list+0x60/0x2c0 [bonding]
[   52.992008]  [<c05f3958>] _raw_read_lock+0x38/0x50
[   52.992008]  [<efe4d300>] ? bond_set_multicast_list+0x60/0x2c0 [bonding]
[   52.992008]  [<efe4d300>] bond_set_multicast_list+0x60/0x2c0 [bonding]
[   52.992008]  [<c04e10f5>] __dev_set_rx_mode+0x35/0xa0
[   52.992008]  [<c04e556f>] dev_mc_sync+0x8f/0xa0
[   52.992008]  [<c0598b84>] vlan_dev_set_rx_mode+0x24/0x40
[   52.992008]  [<c04e10f5>] __dev_set_rx_mode+0x35/0xa0
[   52.992008]  [<c04e1188>] dev_set_rx_mode+0x28/0x40
[   52.992008]  [<c04e1255>] __dev_open+0xb5/0xf0
[   52.992008]  [<c05f39fa>] ? _raw_spin_unlock_bh+0x2a/0x30
[   52.992008]  [<c04e14b4>] __dev_change_flags+0x84/0x160
[   52.992008]  [<c04e1633>] dev_change_flags+0x23/0x60
[   52.992008]  [<c04ebfb0>] do_setlink+0x170/0x700
[   52.992008]  [<c03a6c5f>] ? nla_parse+0x1f/0xa0
[   52.992008]  [<c04ed425>] rtnl_newlink+0x375/0x490
[   52.992008]  [<c04ece35>] rtnetlink_rcv_msg+0x1e5/0x220
[   52.992008]  [<c04ecb84>] ? rtnl_lock+0x14/0x20
[   52.992008]  [<c04ed0b0>] ? rtnl_newlink+0x0/0x490
[   52.992008]  [<c04ecc50>] ? rtnetlink_rcv_msg+0x0/0x220
[   52.992008]  [<c050424e>] netlink_rcv_skb+0x8e/0xb0
[   52.992008]  [<c04ecb90>] ? rtnetlink_rcv+0x0/0x30
[   52.992008]  [<c04ecbac>] rtnetlink_rcv+0x1c/0x30
[   52.992008]  [<c0503bfb>] netlink_unicast+0x24b/0x290
[   52.992008]  [<c0503e37>] netlink_sendmsg+0x1f7/0x310
[   52.992008]  [<c04cd41c>] sock_sendmsg+0xac/0xe0
[   52.992008]  [<c0273c6b>] ? lock_release_non_nested+0x8b/0x300
[   52.992008]  [<c02c6cab>] ? might_fault+0x4b/0xa0
[   52.992008]  [<c02c6cab>] ? might_fault+0x4b/0xa0
[   52.992008]  [<c02c6cf1>] ? might_fault+0x91/0xa0
[   52.992008]  [<c039e074>] ? _copy_from_user+0x44/0x70
[   52.992008]  [<c04d74ba>] ? verify_iovec+0x5a/0xa0
[   52.992008]  [<c04ceb80>] sys_sendmsg+0x130/0x230
[   52.992008]  [<c027266c>] ? __lock_acquire+0x3ec/0x1960
[   52.992008]  [<c02c7e23>] ? do_wp_page+0x2a3/0x7d0
[   52.992008]  [<c02c9500>] ? handle_mm_fault+0x1b0/0x7e0
[   52.992008]  [<c0273c6b>] ? lock_release_non_nested+0x8b/0x300
[   52.992008]  [<c02c6cab>] ? might_fault+0x4b/0xa0
[   52.992008]  [<c02c6cab>] ? might_fault+0x4b/0xa0
[   52.992008]  [<c04cf04e>] sys_socketcall+0xde/0x280
[   52.992008]  [<c0202d43>] ? sysenter_exit+0xf/0x18
[   52.992008]  [<c039d938>] ? trace_hardirqs_on_thunk+0xc/0x10
[   52.992008]  [<c0202d10>] sysenter_do_call+0x12/0x36
[   53.028128] ADDRCONF(NETDEV_UP): vlan.103: link is not ready
[   53.060760] ADDRCONF(NETDEV_UP): vlan.825: link is not ready
[   55.326508] warning: `ntpdate' uses 32-bit capabilities (legacy support in use)
[   55.661812] bnx2 0000:07:00.0: eth1: NIC SerDes Link is Up, 1000 Mbps full duplex
[   55.680088] bonding: bond0: link status definitely up for interface eth1, 1000 Mbps full duplex.
[   55.680171] bonding: bond0: making interface eth1 the new active one.
[   55.680322] bonding: bond0: first active interface up!
[   55.680470] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[   55.680798] ADDRCONF(NETDEV_CHANGE): vlan.103: link becomes ready
[   55.681169] ADDRCONF(NETDEV_CHANGE): vlan.825: link becomes ready
[   56.204977] tg3 0000:14:04.0: eth2: Link is up at 1000 Mbps, full duplex
[   56.205048] tg3 0000:14:04.0: eth2: Flow control is off for TX and off for RX
[   56.280028] bonding: bond0: link status definitely up for interface eth2, 1000 Mbps full duplex.
[   59.545392] bonding: bond0: link status definitely down for interface eth1, disabling it
[   59.545477] bonding: bond0: making interface eth2 the new active one.
[   61.650007] eth0: no IPv6 routers present
[   65.891006] vlan.103: no IPv6 routers present
[   66.339005] vlan.825: no IPv6 routers present
[   66.354005] bond0: no IPv6 routers present


