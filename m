From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: team: Bug when macvlans are defined on top of the slaves
Date: Fri, 22 Aug 2014 12:13:35 +0200
Message-ID: <20140822101335.GA1916@nanopsycho.orion>
References: <20140820160804.GG32293@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, libteam@fedorahosted.org
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:45279 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbaHVKNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 06:13:39 -0400
Received: by mail-we0-f170.google.com with SMTP id w62so10479918wes.15
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 03:13:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140820160804.GG32293@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 20, 2014 at 06:08:04PM CEST, erik.hugne@ericsson.com wrote:
>When macvlans are defined on top of the team port devices, the following oops
>happens immediately when teamd is started.
>
>
>[  108.224148] team0: Mode changed to "activebackup"
>[  108.230450] e1000: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
>[  108.234107] 8021q: adding VLAN 0 to HW filter on device eth1
>[  108.235593] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
>[  108.236397] IP: [<ffffffff815ddb7e>] __mutex_lock_slowpath+0x4e/0x310
>[  108.236397] PGD 3fb2e067 PUD 3fb23067 PMD 0 
>[  108.236397] Oops: 0002 [#1] SMP 
>[  108.236397] Modules linked in: team_mode_activebackup team macvlan
>[  108.236397] CPU: 0 PID: 201 Comm: teamd Not tainted 3.16.0+ #237
>[  108.236397] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>[  108.236397] task: ffff88003f958ed0 ti: ffff88003d15c000 task.ti: ffff88003d15c000
>[  108.236397] RIP: 0010:[<ffffffff815ddb7e>]  [<ffffffff815ddb7e>] __mutex_lock_slowpath+0x4e/0x310
>[  108.236397] RSP: 0018:ffff88003d15f698  EFLAGS: 00010046
>[  108.236397] RAX: 0000000000000100 RBX: 0000000000000010 RCX: 0000000000000001
>[  108.236397] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000010
>[  108.236397] RBP: ffff88003d15f6e8 R08: ffff88003f850900 R09: ffff88003e400008
>[  108.236397] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000010
>[  108.236397] R13: ffff88003f958ed0 R14: 0000000000000018 R15: 0000000000000246
>[  108.236397] FS:  00007ff10a811740(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
>[  108.236397] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>[  108.236397] CR2: 0000000000000018 CR3: 000000003fa96000 CR4: 00000000000006f0
>[  108.236397] Stack:
>[  108.236397]  ffff88003d3d6000 0000000000000081 ffff88003d3d6000 0000000000000001
>[  108.251189]  ffff88003d15f710 0000000000000010 0000000000000010 0000000000000001
>[  108.251189]  ffff88003d15f7d0 0000000000000000 ffff88003d15f700 ffffffff815dde55
>[  108.251189] Call Trace:
>[  108.251189]  [<ffffffff815dde55>] mutex_lock+0x15/0x25
>[  108.251189]  [<ffffffffa000a0df>] team_port_change_check+0x1f/0x60 [team]
>[  108.251189]  [<ffffffffa000afc8>] team_device_event+0xa8/0x150 [team]
>[  108.251189]  [<ffffffff810631ec>] notifier_call_chain+0x4c/0x70
>[  108.251189]  [<ffffffff81063301>] raw_notifier_call_chain+0x11/0x20
>[  108.251189]  [<ffffffff814b5330>] call_netdevice_notifiers_info+0x30/0x60
>[  108.251189]  [<ffffffff814bcdac>] dev_open+0x5c/0x70
>[  108.251189]  [<ffffffffa000a582>] team_add_slave+0x2b2/0x6c0 [team]


I see the problem. team_port_add->team_port_enter sets IFF_TEAM_PORT before
netdev_rx_handler_register is called and therefore team_device_event
thinks that the rx_handler_data pointer is port, but it is macvlan
instead. I'll fix this.

But the thing is, since both macvlan and team are rx_handler users, you
cannot have them both on a single device. If the oops would not appear,
netdev_rx_handler_register would fail anyway. You have to create macvlan on
top of team device instead.

>[  108.251189]  [<ffffffff81564390>] ? inet6_fill_ifla6_attrs+0x360/0x390
>[  108.251189]  [<ffffffff814cb73e>] do_setlink+0x9be/0xa20
>[  108.251189]  [<ffffffff814c99f9>] ? rtnl_fill_ifinfo+0x899/0xb40
>[  108.251189]  [<ffffffff814cbdcf>] rtnl_newlink+0x4ff/0x730
>[  108.251189]  [<ffffffff814cb9d8>] ? rtnl_newlink+0x108/0x730
>[  108.251189]  [<ffffffff814e5e51>] ? netlink_sendskb+0x11/0x40
>[  108.251189]  [<ffffffff814e6033>] ? netlink_unicast+0x1b3/0x250
>[  108.251189]  [<ffffffff814ca8e0>] ? rtnl_getlink+0x130/0x1d0
>[  108.251189]  [<ffffffff814caa70>] rtnetlink_rcv_msg+0x90/0x250
>[  108.251189]  [<ffffffff814ca9e0>] ? rtnetlink_rcv+0x30/0x30
>[  108.251189]  [<ffffffff814e6739>] netlink_rcv_skb+0xa9/0xc0
>[  108.251189]  [<ffffffff814ca9d3>] rtnetlink_rcv+0x23/0x30
>[  108.251189]  [<ffffffff814e5fd8>] netlink_unicast+0x158/0x250
>[  108.251189]  [<ffffffff8128912d>] ? memcpy_fromiovec+0x4d/0x90
>[  108.251189]  [<ffffffff814e6487>] netlink_sendmsg+0x317/0x410
>[  108.251189]  [<ffffffff814a0490>] sock_sendmsg+0xa0/0xc0
>[  108.251189]  [<ffffffff814a1d68>] ? move_addr_to_kernel+0x38/0x80
>[  108.251189]  [<ffffffff814a1d23>] ___sys_sendmsg+0x373/0x380
>[  108.251189]  [<ffffffff8103d034>] ? __do_page_fault+0x284/0x520
>[  108.251189]  [<ffffffff814a2bbd>] __sys_sendmsg+0x3d/0x80
>[  108.251189]  [<ffffffff814a2c0d>] SyS_sendmsg+0xd/0x20
>[  108.251189]  [<ffffffff815dfb52>] system_call_fastpath+0x16/0x1b
>[  108.251189] Code: 35 20 0d 60 00 45 85 f6 75 13 65 8b 04 25 20 b8 00 00 a9 00 ff 1f 00 0f 85 83 02 00 00 9c 41 5f fa b8 00 01 00 00 4d 8d 74 24 08 <f0> 66 41 0f c1 44 24 08 0f b6 d4 38 c2 0f 85 43 02 00 00 44 8b 
>[  108.251189] RIP  [<ffffffff815ddb7e>] __mutex_lock_slowpath+0x4e/0x310
>[  108.251189]  RSP <ffff88003d15f698>
>[  108.251189] CR2: 0000000000000018
>[  108.251189] ---[ end trace 97bf1f31f04db01b ]---
>
>
>Interface config:
> 
>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default 
>    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
>    link/ether 00:0f:ff:10:03:01 brd ff:ff:ff:ff:ff:ff
>3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>    link/ether 00:0f:ff:11:04:01 brd ff:ff:ff:ff:ff:ff
>4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>    link/ether 00:0f:ff:11:05:01 brd ff:ff:ff:ff:ff:ff
>5: macvlan0@eth1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default 
>    link/ether da:ad:a9:57:7a:82 brd ff:ff:ff:ff:ff:ff
>6: macvlan1@eth2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default 
>    link/ether e6:4d:af:76:55:a2 brd ff:ff:ff:ff:ff:ff
>
>
>Teamd config:
>{
>         "device":       "team0",
>         "runner":       {"name": "activebackup"},
>         "link_watch":   {   
>                 "name": "arp_ping",
>                 "interval": 100,
>                 "missed_max": 30, 
>                 "source_host": "192.168.123.101",
>                 "target_host": "192.168.123.1"
>         },  
>         "ports":        {   
>                 "eth1": {
>                         "prio": -10,
>                         "sticky": true
>                 },  
>                 "eth2": {
>                         "prio": 100 
>                 }   
>         }   
>}
>
>teamd version: v1.12
>kernel version: recent net-next (33caee3)
