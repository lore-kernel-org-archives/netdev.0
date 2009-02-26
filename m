From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: probably bug in drr scheduler, 2.6.29-rc5
Date: Thu, 26 Feb 2009 17:45:28 +0200
Message-ID: <200902261745.28952.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36364 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbZBZQLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 11:11:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, triggered a bug in DRR seems

Script was looking something like this (i know, sometimes it wrong, but i 
didnt notice on which stage it is crashed)

#!/bin/sh
ifconfig ifb0 up

tc qdisc del dev eth0 ingress
tc qdisc add dev eth0 ingress

tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
    match u32 0 0 \
    action mirred egress redirect dev ifb0

echo QDISC

tc qdisc del dev ifb0 root
tc qdisc add dev ifb0 handle 1 root htb

tc class add dev ifb0 classid 1:100 parent 1:0 htb rate 100Kbit ceil 100Kbit
tc qdisc add dev ifb0 parent 1:100 handle 2 drr

tc class add dev ifb0 parent 2:0 classid 2:100 drr help
tc class add dev ifb0 parent 2:0 classid 2:101 quantum 16384
tc class add dev ifb0 parent 2:0 classid 2:102 quantum 16384
tc class add dev ifb0 parent 2:0 classid 2:103 quantum 16384

echo FILTER
tc filter add dev ifb0 protocol ip u32 match u32 0 0 flowid 1:100

Then
#!/bin/sh
ifconfig ifb0 up

tc qdisc del dev eth0 ingress
tc qdisc add dev eth0 ingress

tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
    match u32 0 0 \
    action mirred egress redirect dev ifb0

echo QDISC

tc qdisc del dev ifb0 root
tc qdisc add dev ifb0 handle 1 root htb

tc class add dev ifb0 classid 1:100 parent 1:0 htb rate 100Kbit ceil 100Kbit
tc qdisc add dev ifb0 parent 1:100 handle 2 drr

tc class add dev ifb0 parent 2:0 classid 2:100 drr quantum 16384
tc class add dev ifb0 parent 2:0 classid 2:101 drr quantum 16384
tc class add dev ifb0 parent 2:0 classid 2:102 drr quantum 16384
tc class add dev ifb0 parent 2:0 classid 2:103 drr quantum 16384

echo FILTER
tc filter add dev ifb0 protocol ip u32 match u32 0 0 flowid 1:100






[65298.391392] BUG: unable to handle kernel NULL pointer dereference at (null)
[65298.391397] IP: [<ffffffffa0021700>] drr_change_class+0x39/0x2de [sch_drr]
[65298.391403] PGD 1521ba067 PUD 1520c8067 PMD 0
[65298.391407] Oops: 0000 [#1] SMP
[65298.391409] last sysfs file: /sys/devices/virtual/net/ifb1/address
[65298.391411] CPU 1
[65298.391413] Modules linked in: act_mirred cls_u32 sch_ingress ifb sch_drr 
sch_htb i2c_i801 iTCO_wdt rtl8187 sky2 eeprom_93cx6
[65298.391422] Pid: 13017, comm: tc Not tainted 2.6.29-rc5-home1 #1 P5K-E
[65298.391423] RIP: 0010:[<ffffffffa0021700>]  [<ffffffffa0021700>] 
drr_change_class+0x39/0x2de [sch_drr]
[65298.391428] RSP: 0018:ffff88015216b9a8  EFLAGS: 00010292
[65298.391429] RAX: 0000000000000000 RBX: ffffffffa0021c20 RCX: 
ffff88015216ba38
[65298.391431] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 
ffff88015216b9c8
[65298.391433] RBP: ffff88015216ba08 R08: ffffffffa0021c10 R09: 
0000000000000000
[65298.391435] R10: 0000000000000001 R11: 000000005216bb88 R12: 
0000000000000000
[65298.391437] R13: ffff8801ad83b600 R14: ffff8801ad83b600 R15: 
ffff88015216ba38
[65298.391439] FS:  00007ffe4ebe96f0(0000) GS:ffff8801af802d00(0000) 
knlGS:0000000000000000
[65298.391441] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[65298.391442] CR2: 0000000000000000 CR3: 0000000152104000 CR4: 
00000000000006e0
[65298.391444] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[65298.391446] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[65298.391448] Process tc (pid: 13017, threadinfo ffff88015216a000, task 
ffff88015eae2700)
[65298.391449] Stack:
[65298.391451]  ffff88015216b9b8 ffff88015216ba80 000201005216ba68 
0000000000000000
[65298.391453]  ffff8801af825000 ffff8801af825000 0000000000000000 
ffffffffa0021c20
[65298.391457]  0000000000000000 ffff8801ad83b600 0000000000020100 
0000000000020000
[65298.391460] Call Trace:
[65298.391462]  [<ffffffff8135149d>] tc_ctl_tclass+0x23c/0x296
[65298.391469]  [<ffffffff81349646>] rtnetlink_rcv_msg+0x1d2/0x1f3
[65298.391473]  [<ffffffff81349474>] ? rtnetlink_rcv_msg+0x0/0x1f3
[65298.391475]  [<ffffffff8135895d>] netlink_rcv_skb+0x3e/0x8d
[65298.391478]  [<ffffffff8134946a>] rtnetlink_rcv+0x27/0x31
[65298.391481]  [<ffffffff8135844e>] netlink_unicast+0x203/0x279
[65298.391483]  [<ffffffff81338e39>] ? __alloc_skb+0x66/0x128
[65298.391487]  [<ffffffff8135872b>] netlink_sendmsg+0x267/0x27a
[65298.391489]  [<ffffffff81332071>] sock_sendmsg+0xdf/0xf8
[65298.391492]  [<ffffffff8104a016>] ? autoremove_wake_function+0x0/0x38
[65298.391496]  [<ffffffff810867af>] ? handle_mm_fault+0x32f/0x662
[65298.391500]  [<ffffffff813313d3>] ? move_addr_to_kernel+0x25/0x35
[65298.391504]  [<ffffffff8133a01a>] ? verify_iovec+0x4f/0x91
[65298.391507]  [<ffffffff8133225c>] sys_sendmsg+0x1d2/0x23c
[65298.391509]  [<ffffffff81331878>] ? sockfd_lookup_light+0x1b/0x54
[65298.391512]  [<ffffffff813323a5>] ? sys_sendto+0xdf/0x107
[65298.391514]  [<ffffffff811e7abd>] ? tty_write+0x1fb/0x216
[65298.391518]  [<ffffffff811e9d75>] ? n_tty_write+0x0/0x371
[65298.391521]  [<ffffffff8100c0db>] system_call_fastpath+0x16/0x1b
[65298.391524] Code: 41 55 48 8d 7d c0 41 54 53 48 83 ec 38 89 75 b4 4c 89 45 
a8 be 01 00 00 00 49 8b 00 49 c7 c0 10 1c 02 a0 48 89 45 b8 48 8b 51 10 <0f> 
b7 0a 48 83 c2 04 83 e9 04 e8 bf 76 33 e1 89 c3 85 c0 0f 88
[65298.391548] RIP  [<ffffffffa0021700>] drr_change_class+0x39/0x2de [sch_drr]
[65298.391552]  RSP <ffff88015216b9a8>
[65298.391553] CR2: 0000000000000000
[65298.391555] ---[ end trace 0d4fe5ef4b661d96 ]---
