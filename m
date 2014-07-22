From: Borislav Petkov <bp@alien8.de>
Subject: 3.16-rc6+: r8169 fresh new irq lock inversion
Date: Tue, 22 Jul 2014 10:18:40 +0200
Message-ID: <20140722081840.GA6462@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:59885 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752795AbaGVISo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 04:18:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I got this new lockdep splat after booting rc6 + tip/master this
morning. I haven't seen it before so it must be new in rc6 which should
be easy to pinpoint... or maybe there's already a fix queued somewhere. :)


[   10.033876] NET: Registered protocol family 10
[   11.510454] r8169 0000:02:00.0 eth0: link down
[   11.510566] r8169 0000:02:00.0 eth0: link down
[   11.522573] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   13.024024] r8169 0000:02:00.0 eth0: link up
[   13.031636] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   14.024289] 
[   14.028860] =========================================================
[   14.038419] [ INFO: possible irq lock inversion dependency detected ]
[   14.047992] 3.16.0-rc6+ #1 Not tainted
[   14.054806] ---------------------------------------------------------
[   14.064269] swapper/2/0 just changed the state of lock:
[   14.072523]  (&tb->tb6_lock){++--..}, at: [<ffffffffa02bba87>] ip6_ins_rt+0x47/0x80 [ipv6]
[   14.083983] but this lock took another, SOFTIRQ-READ-unsafe lock in the past:
[   14.094142]  (nl_table_lock){.+.?..}
[   14.094142] 
[   14.094142] and interrupts could create inverse lock ordering between them.
[   14.094142] 
[   14.115623] 
[   14.115623] other info that might help us debug this:
[   14.128001]  Possible interrupt unsafe locking scenario:
[   14.128001] 
[   14.140632]        CPU0                    CPU1
[   14.148080]        ----                    ----
[   14.155494]   lock(nl_table_lock);
[   14.161756]                                local_irq_disable();
[   14.170487]                                lock(&tb->tb6_lock);
[   14.179272]                                lock(nl_table_lock);
[   14.188002]   <Interrupt>
[   14.193397]     lock(&tb->tb6_lock);
[   14.199835] 
[   14.199835]  *** DEADLOCK ***
[   14.199835] 
[   14.214025] 1 lock held by swapper/2/0:
[   14.220632]  #0:  (rcu_read_lock){......}, at: [<ffffffff81551e15>] __netif_receive_skb_core+0x65/0xc00
[   14.232984] 
[   14.232984] the shortest dependencies between 2nd lock and 1st lock:
[   14.246511]  -> (nl_table_lock){.+.?..} ops: 4153 {
[   14.254361]     HARDIRQ-ON-R at:
[   14.260442]                       [<ffffffff81099b2c>] __lock_acquire+0x39c/0x2230
[   14.270889]                       [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   14.280886]                       [<ffffffff8161f7d4>] _raw_read_lock+0x44/0x80
[   14.291002]                       [<ffffffff81582422>] netlink_broadcast_filtered+0x42/0x360
[   14.302244]                       [<ffffffff8158275d>] netlink_broadcast+0x1d/0x20
[   14.312580]                       [<ffffffff815851ad>] nlmsg_notify+0xbd/0xd0
[   14.322462]                       [<ffffffff8156626c>] rtmsg_ifinfo+0xdc/0x100
[   14.332448]                       [<ffffffff81558145>] register_netdevice+0x495/0x570
[   14.343009]                       [<ffffffff8155823f>] register_netdev+0x1f/0x30
[   14.353107]                       [<ffffffff81bc4e5a>] loopback_net_init+0x3b/0x7f
[   14.363390]                       [<ffffffff81549f9f>] ops_init.constprop.8+0xaf/0x180
[   14.374001]                       [<ffffffff8154a0dc>] register_pernet_operations.isra.5+0x6c/0xb0
[   14.385668]                       [<ffffffff8154a187>] register_pernet_device+0x27/0x70
[   14.396421]                       [<ffffffff81bd060e>] net_dev_init+0x18c/0x1e8
[   14.406439]                       [<ffffffff810002f0>] do_one_initcall+0xa0/0x1f0
[   14.416660]                       [<ffffffff81b90f5f>] kernel_init_freeable+0x114/0x19c
[   14.427385]                       [<ffffffff816143ae>] kernel_init+0xe/0xe0
[   14.437061]                       [<ffffffff8162052c>] ret_from_fork+0x7c/0xb0
[   14.446978]     IN-SOFTIRQ-R at:
[   14.452894]                       [<ffffffff8109a0b9>] __lock_acquire+0x929/0x2230
[   14.463166]                       [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   14.473085]                       [<ffffffff8161f7d4>] _raw_read_lock+0x44/0x80
[   14.483106]                       [<ffffffff81582422>] netlink_broadcast_filtered+0x42/0x360
[   14.494290]                       [<ffffffff8158275d>] netlink_broadcast+0x1d/0x20
[   14.504553]                       [<ffffffff815851ad>] nlmsg_notify+0xbd/0xd0
[   14.514385]                       [<ffffffff8156491b>] rtnl_notify+0x3b/0x40
[   14.524087]                       [<ffffffff8155d827>] __neigh_notify+0xb7/0xe0
[   14.534057]                       [<ffffffff81563044>] neigh_update+0x444/0x950
[   14.544043]                       [<ffffffff815caa1d>] arp_process+0x30d/0x820
[   14.553910]                       [<ffffffff815cb04b>] arp_rcv+0x10b/0x140
[   14.563412]                       [<ffffffff81551ffc>] __netif_receive_skb_core+0x24c/0xc00
[   14.574412]                       [<ffffffff815529cb>] __netif_receive_skb+0x1b/0x70
[   14.584771]                       [<ffffffff81552a4d>] netif_receive_skb_internal+0x2d/0x1e0
[   14.595832]                       [<ffffffff815538e0>] napi_gro_receive+0x90/0x1b0
[   14.606029]                       [<ffffffffa00036cb>] rtl8169_poll+0x30b/0x640 [r8169]
[   14.616675]                       [<ffffffff81554742>] net_rx_action+0x132/0x310
[   14.626757]                       [<ffffffff8105418d>] __do_softirq+0xed/0x4d0
[   14.636621]                       [<ffffffff810546fe>] irq_exit+0x8e/0xb0
[   14.646038]                       [<ffffffff81622fe1>] do_IRQ+0x71/0x110
[   14.655368]                       [<ffffffff8162122f>] ret_from_intr+0x0/0x13
[   14.665093]                       [<ffffffff814b8b97>] cpuidle_enter+0x17/0x20
[   14.674883]                       [<ffffffff8108ffe7>] cpu_startup_entry+0x287/0x7c0
[   14.685180]                       [<ffffffff81035850>] start_secondary+0x210/0x250
[   14.695290]     SOFTIRQ-ON-R at:
[   14.701042]                       [<ffffffff8109a115>] __lock_acquire+0x985/0x2230
[   14.711157]                       [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   14.720920]                       [<ffffffff8161f7d4>] _raw_read_lock+0x44/0x80
[   14.730742]                       [<ffffffff81582422>] netlink_broadcast_filtered+0x42/0x360
[   14.741691]                       [<ffffffff8158275d>] netlink_broadcast+0x1d/0x20
[   14.751731]                       [<ffffffff815851ad>] nlmsg_notify+0xbd/0xd0
[   14.761310]                       [<ffffffff8156626c>] rtmsg_ifinfo+0xdc/0x100
[   14.770969]                       [<ffffffff81558145>] register_netdevice+0x495/0x570
[   14.781224]                       [<ffffffff8155823f>] register_netdev+0x1f/0x30
[   14.791022]                       [<ffffffff81bc4e5a>] loopback_net_init+0x3b/0x7f
[   14.801016]                       [<ffffffff81549f9f>] ops_init.constprop.8+0xaf/0x180
[   14.811359]                       [<ffffffff8154a0dc>] register_pernet_operations.isra.5+0x6c/0xb0
[   14.822731]                       [<ffffffff8154a187>] register_pernet_device+0x27/0x70
[   14.833162]                       [<ffffffff81bd060e>] net_dev_init+0x18c/0x1e8
[   14.842907]                       [<ffffffff810002f0>] do_one_initcall+0xa0/0x1f0
[   14.852842]                       [<ffffffff81b90f5f>] kernel_init_freeable+0x114/0x19c
[   14.863305]                       [<ffffffff816143ae>] kernel_init+0xe/0xe0
[   14.872712]                       [<ffffffff8162052c>] ret_from_fork+0x7c/0xb0
[   14.882387]     INITIAL USE at:
[   14.887992]                      [<ffffffff81099bd3>] __lock_acquire+0x443/0x2230
[   14.898013]                      [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   14.907664]                      [<ffffffff8161fc87>] _raw_write_lock_irq+0x47/0x80
[   14.917850]                      [<ffffffff81583b0a>] netlink_table_grab+0x1a/0x110
[   14.928054]                      [<ffffffff81bd1944>] netlink_proto_init+0x161/0x1e0
[   14.938379]                      [<ffffffff810002f0>] do_one_initcall+0xa0/0x1f0
[   14.948354]                      [<ffffffff81b90f5f>] kernel_init_freeable+0x114/0x19c
[   14.958803]                      [<ffffffff816143ae>] kernel_init+0xe/0xe0
[   14.968157]                      [<ffffffff8162052c>] ret_from_fork+0x7c/0xb0
[   14.977763]   }
[   14.981921]   ... key      at: [<ffffffff81991198>] nl_table_lock+0x18/0x80
[   14.991364]   ... acquired at:
[   14.996836]    [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   15.004876]    [<ffffffff8161f7d4>] _raw_read_lock+0x44/0x80
[   15.012999]    [<ffffffff81582422>] netlink_broadcast_filtered+0x42/0x360
[   15.022260]    [<ffffffff8158275d>] netlink_broadcast+0x1d/0x20
[   15.030645]    [<ffffffff815851ad>] nlmsg_notify+0xbd/0xd0
[   15.038596]    [<ffffffff8156491b>] rtnl_notify+0x3b/0x40
[   15.046462]    [<ffffffffa02be934>] inet6_rt_notify+0xe4/0x160 [ipv6]
[   15.055393]    [<ffffffffa02bffc7>] fib6_add+0x577/0xaa0 [ipv6]
[   15.063802]    [<ffffffffa02bba9c>] ip6_ins_rt+0x5c/0x80 [ipv6]
[   15.072240]    [<ffffffffa02b40c5>] __ipv6_ifa_notify+0x335/0x340 [ipv6]
[   15.081439]    [<ffffffffa02b414c>] ipv6_ifa_notify+0x7c/0x130 [ipv6]
[   15.090369]    [<ffffffffa02b59c4>] add_addr+0x64/0x90 [ipv6]
[   15.098608]    [<ffffffffa02b7669>] addrconf_notify+0x589/0xb50 [ipv6]
[   15.107642]    [<ffffffff81074305>] notifier_call_chain+0x55/0x110
[   15.116311]    [<ffffffff810743e6>] raw_notifier_call_chain+0x16/0x20
[   15.125242]    [<ffffffff8154d280>] call_netdevice_notifiers_info+0x40/0x70
[   15.134709]    [<ffffffff81557140>] __dev_notify_flags+0x40/0xc0
[   15.143224]    [<ffffffff8155794a>] dev_change_flags+0x5a/0x70
[   15.151548]    [<ffffffff81567991>] do_setlink+0x3f1/0xb50
[   15.159492]    [<ffffffff815687ed>] rtnl_newlink+0x5bd/0x770
[   15.167634]    [<ffffffff815672f8>] rtnetlink_rcv_msg+0x98/0x250
[   15.176105]    [<ffffffff81585801>] netlink_rcv_skb+0xa1/0xc0
[   15.184309]    [<ffffffff8156724a>] rtnetlink_rcv+0x2a/0x40
[   15.192345]    [<ffffffff81585056>] netlink_unicast+0x146/0x1e0
[   15.200730]    [<ffffffff81585508>] netlink_sendmsg+0x348/0x440
[   15.209107]    [<ffffffff81534693>] sock_sendmsg+0x73/0x90
[   15.217051]    [<ffffffff81535548>] ___sys_sendmsg+0x408/0x420
[   15.225348]    [<ffffffff81538589>] __sys_sendmsg+0x49/0x80
[   15.233387]    [<ffffffff815385d2>] SyS_sendmsg+0x12/0x20
[   15.241250]    [<ffffffff816205d6>] system_call_fastpath+0x1a/0x1f
[   15.249896] 
[   15.253820] -> (&tb->tb6_lock){++--..} ops: 6 {
[   15.260915]    HARDIRQ-ON-W at:
[   15.266511]                     [<ffffffff8109a0e2>] __lock_acquire+0x952/0x2230
[   15.276411]                     [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   15.285947]                     [<ffffffff8161fd05>] _raw_write_lock_bh+0x45/0x80
[   15.295926]                     [<ffffffffa02bba87>] ip6_ins_rt+0x47/0x80 [ipv6]
[   15.305827]                     [<ffffffffa02b40c5>] __ipv6_ifa_notify+0x335/0x340 [ipv6]
[   15.316524]                     [<ffffffffa02b414c>] ipv6_ifa_notify+0x7c/0x130 [ipv6]
[   15.326970]                     [<ffffffffa02b59c4>] add_addr+0x64/0x90 [ipv6]
[   15.336733]                     [<ffffffffa02b7669>] addrconf_notify+0x589/0xb50 [ipv6]
[   15.347273]                     [<ffffffff81074305>] notifier_call_chain+0x55/0x110
[   15.357459]                     [<ffffffff810743e6>] raw_notifier_call_chain+0x16/0x20
[   15.367897]                     [<ffffffff8154d280>] call_netdevice_notifiers_info+0x40/0x70
[   15.378847]                     [<ffffffff81557140>] __dev_notify_flags+0x40/0xc0
[   15.388841]                     [<ffffffff8155794a>] dev_change_flags+0x5a/0x70
[   15.398660]                     [<ffffffff81567991>] do_setlink+0x3f1/0xb50
[   15.408178]                     [<ffffffff815687ed>] rtnl_newlink+0x5bd/0x770
[   15.417817]                     [<ffffffff815672f8>] rtnetlink_rcv_msg+0x98/0x250
[   15.427813]                     [<ffffffff81585801>] netlink_rcv_skb+0xa1/0xc0
[   15.437549]                     [<ffffffff8156724a>] rtnetlink_rcv+0x2a/0x40
[   15.447120]                     [<ffffffff81585056>] netlink_unicast+0x146/0x1e0
[   15.457036]                     [<ffffffff81585508>] netlink_sendmsg+0x348/0x440
[   15.466990]                     [<ffffffff81534693>] sock_sendmsg+0x73/0x90
[   15.476458]                     [<ffffffff81535548>] ___sys_sendmsg+0x408/0x420
[   15.486263]                     [<ffffffff81538589>] __sys_sendmsg+0x49/0x80
[   15.495808]                     [<ffffffff815385d2>] SyS_sendmsg+0x12/0x20
[   15.505172]                     [<ffffffff816205d6>] system_call_fastpath+0x1a/0x1f
[   15.515334]    HARDIRQ-ON-R at:
[   15.520963]                     [<ffffffff81099b2c>] __lock_acquire+0x39c/0x2230
[   15.530908]                     [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   15.540485]                     [<ffffffff8161f978>] _raw_read_lock_bh+0x48/0x80
[   15.550405]                     [<ffffffffa02bbb27>] ip6_pol_route.isra.41+0x67/0x3f0 [ipv6]
[   15.561371]                     [<ffffffffa02bbf0a>] ip6_pol_route_output+0x2a/0x30 [ipv6]
[   15.572165]                     [<ffffffffa02bfa0a>] fib6_rule_lookup+0x1a/0x20 [ipv6]
[   15.582601]                     [<ffffffffa02b9e94>] ip6_route_output+0x74/0xc0 [ipv6]
[   15.593031]                     [<ffffffffa02a83cf>] ip6_dst_lookup_tail+0xcf/0xf0 [ipv6]
[   15.603736]                     [<ffffffffa02a8445>] ip6_dst_lookup_flow+0x35/0x90 [ipv6]
[   15.614415]                     [<ffffffffa02de809>] ip6_datagram_connect+0x169/0x4b0 [ipv6]
[   15.625375]                     [<ffffffff815d3b45>] inet_dgram_connect+0x45/0xa0
[   15.635360]                     [<ffffffff81537dea>] SyS_connect+0x8a/0xe0
[   15.644741]                     [<ffffffff816205d6>] system_call_fastpath+0x1a/0x1f
[   15.654912]    IN-SOFTIRQ-W at:
[   15.660543]                     [<ffffffff8109a0b9>] __lock_acquire+0x929/0x2230
[   15.670451]                     [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   15.680030]                     [<ffffffff8161fd05>] _raw_write_lock_bh+0x45/0x80
[   15.690035]                     [<ffffffffa02bba87>] ip6_ins_rt+0x47/0x80 [ipv6]
[   15.699953]                     [<ffffffffa02bbda4>] ip6_pol_route.isra.41+0x2e4/0x3f0 [ipv6]
[   15.711016]                     [<ffffffffa02bbedb>] ip6_pol_route_input+0x2b/0x30 [ipv6]
[   15.721730]                     [<ffffffffa02bfa0a>] fib6_rule_lookup+0x1a/0x20 [ipv6]
[   15.732185]                     [<ffffffffa02bba2c>] ip6_route_input_lookup.isra.39.constprop.46+0x4c/0x60 [ipv6]
[   15.745012]                     [<ffffffffa02bbfab>] ip6_route_input+0x9b/0xc0 [ipv6]
[   15.755416]                     [<ffffffffa02ac740>] ip6_rcv_finish+0x170/0x2a0 [ipv6]
[   15.765897]                     [<ffffffffa02ad565>] ipv6_rcv+0x4f5/0x8b0 [ipv6]
[   15.775849]                     [<ffffffff81551ffc>] __netif_receive_skb_core+0x24c/0xc00
[   15.786590]                     [<ffffffff815529cb>] __netif_receive_skb+0x1b/0x70
[   15.796706]                     [<ffffffff81552a4d>] netif_receive_skb_internal+0x2d/0x1e0
[   15.807525]                     [<ffffffff815538e0>] napi_gro_receive+0x90/0x1b0
[   15.817469]                     [<ffffffffa00036cb>] rtl8169_poll+0x30b/0x640 [r8169]
[   15.827855]                     [<ffffffff81554742>] net_rx_action+0x132/0x310
[   15.837644]                     [<ffffffff8105418d>] __do_softirq+0xed/0x4d0
[   15.847232]                     [<ffffffff810546fe>] irq_exit+0x8e/0xb0
[   15.856370]                     [<ffffffff81622fe1>] do_IRQ+0x71/0x110
[   15.865431]                     [<ffffffff8162122f>] ret_from_intr+0x0/0x13
[   15.874924]                     [<ffffffff814b8b97>] cpuidle_enter+0x17/0x20
[   15.884503]                     [<ffffffff8108ffe7>] cpu_startup_entry+0x287/0x7c0
[   15.894604]                     [<ffffffff81035850>] start_secondary+0x210/0x250
[   15.904530]    IN-SOFTIRQ-R at:
[   15.910206]                     [<ffffffff8109a0b9>] __lock_acquire+0x929/0x2230
[   15.920174]                     [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   15.929832]                     [<ffffffff8161f978>] _raw_read_lock_bh+0x48/0x80
[   15.939810]                     [<ffffffffa02bbb27>] ip6_pol_route.isra.41+0x67/0x3f0 [ipv6]
[   15.950856]                     [<ffffffffa02bbedb>] ip6_pol_route_input+0x2b/0x30 [ipv6]
[   15.961631]                     [<ffffffffa02bfa0a>] fib6_rule_lookup+0x1a/0x20 [ipv6]
[   15.972154]                     [<ffffffffa02bba2c>] ip6_route_input_lookup.isra.39.constprop.46+0x4c/0x60 [ipv6]
[   15.985043]                     [<ffffffffa02bbfab>] ip6_route_input+0x9b/0xc0 [ipv6]
[   15.995508]                     [<ffffffffa02ac740>] ip6_rcv_finish+0x170/0x2a0 [ipv6]
[   16.006075]                     [<ffffffffa02ad565>] ipv6_rcv+0x4f5/0x8b0 [ipv6]
[   16.016080]                     [<ffffffff81551ffc>] __netif_receive_skb_core+0x24c/0xc00
[   16.026872]                     [<ffffffff815529cb>] __netif_receive_skb+0x1b/0x70
[   16.037043]                     [<ffffffff81552a4d>] netif_receive_skb_internal+0x2d/0x1e0
[   16.047911]                     [<ffffffff815538e0>] napi_gro_receive+0x90/0x1b0
[   16.057925]                     [<ffffffffa00036cb>] rtl8169_poll+0x30b/0x640 [r8169]
[   16.068355]                     [<ffffffff81554742>] net_rx_action+0x132/0x310
[   16.078177]                     [<ffffffff8105418d>] __do_softirq+0xed/0x4d0
[   16.087844]                     [<ffffffff810546fe>] irq_exit+0x8e/0xb0
[   16.097033]                     [<ffffffff81622fe1>] do_IRQ+0x71/0x110
[   16.106146]                     [<ffffffff8162122f>] ret_from_intr+0x0/0x13
[   16.115667]                     [<ffffffff814b8b97>] cpuidle_enter+0x17/0x20
[   16.125271]                     [<ffffffff8108ffe7>] cpu_startup_entry+0x287/0x7c0
[   16.135406]                     [<ffffffff81035850>] start_secondary+0x210/0x250
[   16.145395]    INITIAL USE at:
[   16.151015]                    [<ffffffff81099bd3>] __lock_acquire+0x443/0x2230
[   16.160924]                    [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   16.170531]                    [<ffffffff8161fd05>] _raw_write_lock_bh+0x45/0x80
[   16.180534]                    [<ffffffffa02bba87>] ip6_ins_rt+0x47/0x80 [ipv6]
[   16.190463]                    [<ffffffffa02b40c5>] __ipv6_ifa_notify+0x335/0x340 [ipv6]
[   16.201185]                    [<ffffffffa02b414c>] ipv6_ifa_notify+0x7c/0x130 [ipv6]
[   16.211657]                    [<ffffffffa02b59c4>] add_addr+0x64/0x90 [ipv6]
[   16.221428]                    [<ffffffffa02b7669>] addrconf_notify+0x589/0xb50 [ipv6]
[   16.231995]                    [<ffffffff81074305>] notifier_call_chain+0x55/0x110
[   16.242216]                    [<ffffffff810743e6>] raw_notifier_call_chain+0x16/0x20
[   16.252697]                    [<ffffffff8154d280>] call_netdevice_notifiers_info+0x40/0x70
[   16.263699]                    [<ffffffff81557140>] __dev_notify_flags+0x40/0xc0
[   16.273747]                    [<ffffffff8155794a>] dev_change_flags+0x5a/0x70
[   16.283596]                    [<ffffffff81567991>] do_setlink+0x3f1/0xb50
[   16.293090]                    [<ffffffff815687ed>] rtnl_newlink+0x5bd/0x770
[   16.302738]                    [<ffffffff815672f8>] rtnetlink_rcv_msg+0x98/0x250
[   16.312743]                    [<ffffffff81585801>] netlink_rcv_skb+0xa1/0xc0
[   16.322487]                    [<ffffffff8156724a>] rtnetlink_rcv+0x2a/0x40
[   16.332057]                    [<ffffffff81585056>] netlink_unicast+0x146/0x1e0
[   16.341976]                    [<ffffffff81585508>] netlink_sendmsg+0x348/0x440
[   16.351886]                    [<ffffffff81534693>] sock_sendmsg+0x73/0x90
[   16.361396]                    [<ffffffff81535548>] ___sys_sendmsg+0x408/0x420
[   16.371219]                    [<ffffffff81538589>] __sys_sendmsg+0x49/0x80
[   16.380773]                    [<ffffffff815385d2>] SyS_sendmsg+0x12/0x20
[   16.390147]                    [<ffffffff816205d6>] system_call_fastpath+0x1a/0x1f
[   16.400306]  }
[   16.404472]  ... key      at: [<ffffffffa02f55a8>] __key.43500+0x0/0xffffffffffff2221 [ipv6]
[   16.415507]  ... acquired at:
[   16.420999]    [<ffffffff810960eb>] check_usage_forwards+0x15b/0x160
[   16.429956]    [<ffffffff81096f74>] mark_lock+0x444/0x760
[   16.437959]    [<ffffffff8109a0b9>] __lock_acquire+0x929/0x2230
[   16.446473]    [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   16.454641]    [<ffffffff8161fd05>] _raw_write_lock_bh+0x45/0x80
[   16.463225]    [<ffffffffa02bba87>] ip6_ins_rt+0x47/0x80 [ipv6]
[   16.471723]    [<ffffffffa02bbda4>] ip6_pol_route.isra.41+0x2e4/0x3f0 [ipv6]
[   16.481368]    [<ffffffffa02bbedb>] ip6_pol_route_input+0x2b/0x30 [ipv6]
[   16.490675]    [<ffffffffa02bfa0a>] fib6_rule_lookup+0x1a/0x20 [ipv6]
[   16.499711]    [<ffffffffa02bba2c>] ip6_route_input_lookup.isra.39.constprop.46+0x4c/0x60 [ipv6]
[   16.511119]    [<ffffffffa02bbfab>] ip6_route_input+0x9b/0xc0 [ipv6]
[   16.520092]    [<ffffffffa02ac740>] ip6_rcv_finish+0x170/0x2a0 [ipv6]
[   16.529134]    [<ffffffffa02ad565>] ipv6_rcv+0x4f5/0x8b0 [ipv6]
[   16.537666]    [<ffffffff81551ffc>] __netif_receive_skb_core+0x24c/0xc00
[   16.546961]    [<ffffffff815529cb>] __netif_receive_skb+0x1b/0x70
[   16.555692]    [<ffffffff81552a4d>] netif_receive_skb_internal+0x2d/0x1e0
[   16.565082]    [<ffffffff815538e0>] napi_gro_receive+0x90/0x1b0
[   16.573613]    [<ffffffffa00036cb>] rtl8169_poll+0x30b/0x640 [r8169]
[   16.582589]    [<ffffffff81554742>] net_rx_action+0x132/0x310
[   16.590965]    [<ffffffff8105418d>] __do_softirq+0xed/0x4d0
[   16.599165]    [<ffffffff810546fe>] irq_exit+0x8e/0xb0
[   16.606911]    [<ffffffff81622fe1>] do_IRQ+0x71/0x110
[   16.614550]    [<ffffffff8162122f>] ret_from_intr+0x0/0x13
[   16.622598]    [<ffffffff814b8b97>] cpuidle_enter+0x17/0x20
[   16.630731]    [<ffffffff8108ffe7>] cpu_startup_entry+0x287/0x7c0
[   16.639410]    [<ffffffff81035850>] start_secondary+0x210/0x250
[   16.647919] 
[   16.651927] 
[   16.651927] stack backtrace:
[   16.661241] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 3.16.0-rc6+ #1
[   16.670118] Hardware name: To be filled by O.E.M. To be filled by O.E.M./M5A97 EVO R2.0, BIOS 1503 01/16/2013
[   16.682584]  ffffffff82830c40 ffff88042da03910 ffffffff8161810e ffffffff82830c40
[   16.692638]  ffff88042da03950 ffffffff8161752f ffffffff8183b499 ffff88042b9e8760
[   16.702704]  ffff88042b9e8000 ffffffff8183b499 0000000000000000 ffffffff82830c40
[   16.712777] Call Trace:
[   16.717802]  <IRQ>  [<ffffffff8161810e>] dump_stack+0x4e/0x7a
[   16.726192]  [<ffffffff8161752f>] print_irq_inversion_bug.part.31+0x1b8/0x1c4
[   16.735953]  [<ffffffff810960eb>] check_usage_forwards+0x15b/0x160
[   16.744763]  [<ffffffff81096f74>] mark_lock+0x444/0x760
[   16.752609]  [<ffffffff81095f90>] ? print_shortest_lock_dependencies+0x1d0/0x1d0
[   16.762658]  [<ffffffff8109a0b9>] __lock_acquire+0x929/0x2230
[   16.771050]  [<ffffffff81095f90>] ? print_shortest_lock_dependencies+0x1d0/0x1d0
[   16.781134]  [<ffffffff8109485e>] ? find_usage_backwards+0x4e/0x90
[   16.789996]  [<ffffffff8109c1c9>] lock_acquire+0xb9/0x200
[   16.798112]  [<ffffffffa02bba87>] ? ip6_ins_rt+0x47/0x80 [ipv6]
[   16.806712]  [<ffffffff8161fd05>] _raw_write_lock_bh+0x45/0x80
[   16.815218]  [<ffffffffa02bba87>] ? ip6_ins_rt+0x47/0x80 [ipv6]
[   16.823794]  [<ffffffffa02bba87>] ip6_ins_rt+0x47/0x80 [ipv6]
[   16.832197]  [<ffffffffa02bbda4>] ip6_pol_route.isra.41+0x2e4/0x3f0 [ipv6]
[   16.841744]  [<ffffffffa02bbedb>] ip6_pol_route_input+0x2b/0x30 [ipv6]
[   16.850959]  [<ffffffffa02bfa0a>] fib6_rule_lookup+0x1a/0x20 [ipv6]
[   16.859888]  [<ffffffffa02bba2c>] ip6_route_input_lookup.isra.39.constprop.46+0x4c/0x60 [ipv6]
[   16.871192]  [<ffffffffa02bbfab>] ip6_route_input+0x9b/0xc0 [ipv6]
[   16.880052]  [<ffffffffa02ac740>] ip6_rcv_finish+0x170/0x2a0 [ipv6]
[   16.889016]  [<ffffffffa02ad565>] ipv6_rcv+0x4f5/0x8b0 [ipv6]
[   16.897427]  [<ffffffffa02ad098>] ? ipv6_rcv+0x28/0x8b0 [ipv6]
[   16.905917]  [<ffffffff81551ffc>] __netif_receive_skb_core+0x24c/0xc00
[   16.915098]  [<ffffffff81551e15>] ? __netif_receive_skb_core+0x65/0xc00
[   16.924421]  [<ffffffff815529cb>] __netif_receive_skb+0x1b/0x70
[   16.933003]  [<ffffffff81552a4d>] netif_receive_skb_internal+0x2d/0x1e0
[   16.942280]  [<ffffffff815538e0>] napi_gro_receive+0x90/0x1b0
[   16.950703]  [<ffffffffa00036cb>] rtl8169_poll+0x30b/0x640 [r8169]
[   16.959561]  [<ffffffff81554742>] net_rx_action+0x132/0x310
[   16.967818]  [<ffffffff812f6d83>] ? __this_cpu_preempt_check+0x13/0x20
[   16.977041]  [<ffffffff8105418d>] __do_softirq+0xed/0x4d0
[   16.985139]  [<ffffffff810546fe>] irq_exit+0x8e/0xb0
[   16.992803]  [<ffffffff81622fe1>] do_IRQ+0x71/0x110
[   17.000378]  [<ffffffff8162122f>] common_interrupt+0x6f/0x6f
[   17.008764]  <EOI>  [<ffffffff814b8a5f>] ? cpuidle_enter_state+0x5f/0xd0
[   17.018246]  [<ffffffff814b8a5b>] ? cpuidle_enter_state+0x5b/0xd0
[   17.027079]  [<ffffffff814b8b97>] cpuidle_enter+0x17/0x20
[   17.035257]  [<ffffffff8108ffe7>] cpu_startup_entry+0x287/0x7c0
[   17.043910]  [<ffffffff81035850>] start_secondary+0x210/0x250
[   28.960885] ip_tables: (C) 2000-2006 Netfilter Core Team
[   28.974767] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
