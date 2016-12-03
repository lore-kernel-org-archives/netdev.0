From: Simon Horman <horms@verge.net.au>
Subject: Possible regression due to "net/sched: cls_flower: Add offload
 support using egress Hardware device"
Date: Sat, 3 Dec 2016 14:17:58 +0100
Message-ID: <20161203131758.GA4695@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56016 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbcLCNSE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 08:18:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hadar,

in net-next I am observing what appears to be an regression in net-next due to:
7091d8c7055d ("net/sched: cls_flower: Add offload support using egress Hardware device")

The problem occurs when adding a flower filter (without offload to a virtio
device).

# ethtool -d eth0
ethtool -i eth0
driver: virtio_net
...

# tc qdisc add dev eth0 ingress
# tc filter add dev eth0 protocol ip parent ffff: flower indev eth0
[  104.302779] BUG: unable to handle kernel NULL pointer dereference at 00000000000000d5
[  104.303388] IP: [<ffffffff812c966d>] fl_dump+0x18d/0x7b0
[  104.304140] PGD 1f825067 [  104.304535] PUD 1f81a067 
PMD 0 [  104.305080] 
[  104.305351] Oops: 0000 [#1] SMP
[  104.305850] Modules linked in:
[  104.306358] CPU: 0 PID: 164 Comm: tc Not tainted 4.9.0-rc6-01485-g7091d8c7055d #1217
[  104.307603] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  104.309781] task: ffff8800167dac40 task.stack: ffffc9000017c000
[  104.310950] RIP: 0010:[<ffffffff812c966d>]  [<ffffffff812c966d>] fl_dump+0x18d/0x7b0
[  104.311924] RSP: 0018:ffffc9000017fa40  EFLAGS: 00010246
[  104.311924] RAX: ffff88001f830a00 RBX: ffff88001b320900 RCX: 0000000000000000
[  104.311924] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000ffff0000
[  104.311924] RBP: ffff8800167dec00 R08: 0000000000000000 R09: ffff88001f800034
[  104.311924] R10: 00000000c6024032 R11: 0000000000000000 R12: ffff88001f800030
[  104.311924] R13: ffff880016412e00 R14: ffff8800166fb200 R15: ffffc9000017fa50
[  104.311924] FS:  00007fe24e0e6700(0000) GS:ffff88001b600000(0000) knlGS:0000000000000000
[  104.311924] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  104.311924] CR2: 00000000000000d5 CR3: 000000001645a000 CR4: 00000000000006b0
[  104.311924] Stack:
[  104.311924]  0000000000000286 0000000000000000 0000000000000000 0000000000000000
[  104.311924]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  104.311924]  ffff88001b320900 ffff88001f800000 ffff88001f800000 ffff880016412e00
[  104.311924] Call Trace:
[  104.311924]  [<ffffffff812c452e>] ? tcf_fill_node.constprop.12+0x12e/0x180
[  104.311924]  [<ffffffff812c45f6>] ? tfilter_notify.constprop.11+0x76/0x100
[  104.311924]  [<ffffffff812c4ac9>] ? tc_ctl_tfilter+0x449/0x6c0
[  104.311924]  [<ffffffff812b17d3>] ? rtnetlink_rcv_msg+0x83/0x200
[  104.311924]  [<ffffffff812b1750>] ? rtnl_newlink+0x810/0x810
[  104.311924]  [<ffffffff812ce834>] ? netlink_rcv_skb+0x94/0xb0
[  104.311924]  [<ffffffff812ae4e4>] ? rtnetlink_rcv+0x24/0x30
[  104.311924]  [<ffffffff812ce1b5>] ? netlink_unicast+0x145/0x1d0
[  104.311924]  [<ffffffff812ce659>] ? netlink_sendmsg+0x369/0x390
[  104.311924]  [<ffffffff811119a3>] ? rw_copy_check_uvector+0x53/0x110
[  104.311924]  [<ffffffff81282830>] ? sock_sendmsg+0x10/0x20
[  104.311924]  [<ffffffff81282e97>] ? ___sys_sendmsg+0x1f7/0x200
[  104.311924]  [<ffffffff81282fb9>] ? ___sys_recvmsg+0x119/0x140
[  104.311924]  [<ffffffff810e3c70>] ? trace_raw_output_mm_lru_activate+0x60/0x60
[  104.311924]  [<ffffffff81105606>] ? page_add_new_anon_rmap+0x46/0x80
[  104.311924]  [<ffffffff810fd902>] ? handle_mm_fault+0xae2/0xb00
[  104.311924]  [<ffffffff81283da1>] ? __sys_sendmsg+0x41/0x70
[  104.311924]  [<ffffffff813b7560>] ? entry_SYSCALL_64_fastpath+0x13/0x94
[  104.311924] Code: 85 5b ff ff ff e9 1a ff ff ff 4c 8d 7c 24 10 31 c0 b9 06 00 00 00 4c 8b 85 60 01 00 00 4c 89 ff f3 48 ab 49 8b 45 28 41 8b 7d 20 <41> f6 80 d5 00 00 00 80 48 8b 40 18 48 8b 40 08 0f 84 f0 fe ff 
[  104.311924] RIP  [<ffffffff812c966d>] fl_dump+0x18d/0x7b0
[  104.311924]  RSP <ffffc9000017fa40>
[  104.311924] CR2: 00000000000000d5
[  104.347974] ---[ end trace 9d9dacd54834303d ]---
