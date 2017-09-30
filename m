From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH v2 2/5] net/sched: Fix accessing invalid dev_queue
Date: Fri, 29 Sep 2017 17:26:54 -0700
Message-ID: <20170930002657.15291-3-vinicius.gomes@intel.com>
References: <20170930002657.15291-1-vinicius.gomes@intel.com>
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36897 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752579AbdI3A12 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:27:28 -0400
In-Reply-To: <20170930002657.15291-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>

In qdisc_alloc() the dev_queue pointer was used without any checks being
performed. If qdisc_create() gets a null dev_queue pointer, it just
passes it along to qdisc_alloc(), leading to a crash. That happens if a
root qdisc implements select_queue() and returns a null dev_queue
pointer for an "invalid handle", for example.

One way to reproduce that is:

1) Setup mqprio
$ tc qdisc replace dev enp3s0 parent root mqprio num_tc 3 \
     	   map 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 queues 1@0 1@1 2@2 hw 0

2) Replace the first inner qdisc
$ tc qdisc replace dev enp3s0 parent 8001:1 pfifo_fast

This will lead to the following crash:

[15274.874506] BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
[15274.875044] IP: qdisc_alloc+0xd/0xf0
[15274.875253] PGD 1a37d067 P4D 1a37d067 PUD 1a0cb067 PMD 0
[15274.875566] Oops: 0000 [#1] SMP
[15274.875813] Modules linked in:
[15274.875993] CPU: 0 PID: 2006 Comm: tc Not tainted 4.14.0-rc1+ #42
[15274.876415] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-20170228_101828-anatol 04/01/2014
[15274.877019] task: ffff88001eb91d00 task.stack: ffffc90000734000
[15274.877359] RIP: 0010:qdisc_alloc+0xd/0xf0
[15274.877606] RSP: 0018:ffffc90000737a88 EFLAGS: 00010286
[15274.877904] RAX: ffffffff81ef0da0 RBX: 0000000000000000 RCX: 0000000000000000
[15274.878331] RDX: ffff88001a046830 RSI: ffffffff81ef0da0 RDI: 0000000000000000
[15274.878757] RBP: 0000000001000001 R08: 000000000000006c R09: ffffc90000737b40
[15274.879165] R10: fffffffffffffc20 R11: 0000000000000000 R12: ffff88001e308000
[15274.879571] R13: 0000000000000088 R14: ffffc90000737b40 R15: 0000000000000000
[15274.879978] FS:  00007f790a90a700(0000) GS:ffff88001fc00000(0000) knlGS:0000000000000000
[15274.880457] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[15274.880784] CR2: 0000000000000058 CR3: 000000001a003004 CR4: 00000000003606f0
[15274.881203] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[15274.881620] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[15274.882026] Call Trace:
[15274.882179]  qdisc_create+0xb0/0x380
[15274.882388]  ? security_capable+0x2e/0x50
[15274.882616]  ? nla_parse+0x32/0x100
[15274.882818]  tc_modify_qdisc+0x47f/0x560
[15274.883046]  rtnetlink_rcv_msg+0x1db/0x200
[15274.883284]  ? __skb_try_recv_datagram+0xd6/0x150
[15274.883555]  ? rtnl_calcit.isra.21+0xe0/0xe0
[15274.883814]  netlink_rcv_skb+0x92/0xf0
[15274.884031]  netlink_unicast+0x12c/0x1d0
[15274.884258]  netlink_sendmsg+0x2ee/0x330
[15274.884486]  sock_sendmsg+0x28/0x40
[15274.884689]  ___sys_sendmsg+0x25d/0x280
[15274.884913]  ? __alloc_pages_nodemask+0x120/0x180
[15274.885185]  ? page_add_new_anon_rmap+0x90/0xb0
[15274.885448]  ? __handle_mm_fault+0x74e/0xc40
[15274.885695]  ? __sys_sendmsg+0x3e/0x70
[15274.885912]  __sys_sendmsg+0x3e/0x70
[15274.886123]  entry_SYSCALL_64_fastpath+0x13/0x94
[15274.886387] RIP: 0033:0x7f7909b1a1b7
[15274.886594] RSP: 002b:00007ffe14315028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
[15274.887042] RAX: ffffffffffffffda RBX: 0000000000661860 RCX: 00007f7909b1a1b7
[15274.887450] RDX: 0000000000000000 RSI: 00007ffe143150a0 RDI: 0000000000000003
[15274.887854] RBP: 00007ffe143150a0 R08: 0000000000000001 R09: 0000000000000000
[15274.888256] R10: 00000000000005f1 R11: 0000000000000246 R12: 00007ffe143150e0
[15274.888660] R13: 000000000066e620 R14: 00007ffe1431d180 R15: 0000000000000000
[15274.889070] Code: a8 01 74 09 48 89 df 5b e9 71 ff ff ff 5b c3 f3 c3 0f 1f 00 66 2e 0f 1f 84 00 00 00 00 00 41 55 41 54 55 53 48 89 fb 44 8b 6e 20 <8b> 57 58 48 89 f5 4c 8b 27 be c0 80 40 01 41 8d bd 40 01 00 00
[15274.890154] RIP: qdisc_alloc+0xd/0xf0 RSP: ffffc90000737a88
[15274.890479] CR2: 0000000000000058
[15274.890677] ---[ end trace 6d0e946c11e46095 ]---

Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
---
 net/sched/sch_generic.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a0a198768aad..de2408f1ccd3 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -603,8 +603,14 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	struct Qdisc *sch;
 	unsigned int size = QDISC_ALIGN(sizeof(*sch)) + ops->priv_size;
 	int err = -ENOBUFS;
-	struct net_device *dev = dev_queue->dev;
+	struct net_device *dev;
+
+	if (!dev_queue) {
+		err = -EINVAL;
+		goto errout;
+	}
 
+	dev = dev_queue->dev;
 	p = kzalloc_node(size, GFP_KERNEL,
 			 netdev_queue_numa_node_read(dev_queue));
 
-- 
2.14.2
