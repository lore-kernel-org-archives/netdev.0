From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: next-20131218 - WARNING in qdisc_list_add
Date: Fri, 20 Dec 2013 08:26:04 -0800
Message-ID: <1387556764.19078.441.camel@edumazet-glaptop2.roam.corp.google.com>
References: <7625.1387476879@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7625.1387476879@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-12-19 at 13:14 -0500, Valdis Kletnieks wrote:
> Seen once while booting next-20131218 (different boot than the BUG
> I hit). Command that triggered it would have been one of these 2:
> 
> /usr/sbin/tc qdisc add dev em1 root codel
> /usr/sbin/tc qdisc add dev wlp3s0 root codel
> 
> It's possible that wlp3s0 wasn't there yet due to rfkill switch having
> nuked the wireless.
> 
> 'git blame' points at the message being added in this commit:
> 
> commit e57a784d8cae429f5b697fe55abf420181d9ff09
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Thu Dec 12 15:41:56 2013 -0800
> 
>     pkt_sched: set root qdisc before change() in attach_default_qdiscs()
> 
>     After commit 95dc19299f74 ("pkt_sched: give visibility to mq slave
>     qdiscs") we call disc_list_add() while the device qdisc might be
>     the noop_qdisc one.
> 
>     This shows up as duplicates in "tc qdisc show", as all inactive devices
>     point to noop_qdisc.
> 
>     Fix this by setting dev->qdisc to the new qdisc before calling
>     ops->change() in attach_default_qdiscs()
> 
>     Add a WARN_ON_ONCE() to catch any future similar problem.
> 
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
>  [  153.876539] ------------[ cut here ]------------
>  [  153.878667] WARNING: CPU: 1 PID: 1446 at net/sched/sch_api.c:278 qdisc_list_add+0x79/0xcf()
>  [  153.897042] CPU: 3 PID: 1446 Comm: tc Tainted: G           O 3.13.0-rc4-next-20131218 #129
>  [  153.898877] Hardware name: Dell Inc. Latitude E6530/07Y85M, BIOS A11 03/12/2013
>  [  153.900666]  0000000000000000 ffff880121195950 ffffffff8164c74f 0000000000000000
>  [  153.905666]  ffff880121195988 ffffffff8103875e ffffffff814afe73 ffff88012828f600
>  [  153.910847]  0000000000000001 ffffffff81c8cac0 0000000000000001 ffff880121195998
>  [  153.916012] Call Trace:
>  [  153.917237]  [<ffffffff8164c74f>] dump_stack+0x4f/0xa2
>  [  153.918659]  [<ffffffff8103875e>] warn_slowpath_common+0x7a/0x93
>  [  153.920222]  [<ffffffff814afe73>] ? qdisc_list_add+0x79/0xcf
>  [  153.921896]  [<ffffffff81038816>] warn_slowpath_null+0x15/0x17
>  [  153.923579]  [<ffffffff814afe73>] qdisc_list_add+0x79/0xcf
>  [  153.925134]  [<ffffffff814b1466>] qdisc_create+0x237/0x350
>  [  153.926658]  [<ffffffff814b1a05>] tc_modify_qdisc+0x486/0x4af
>  [  153.928173]  [<ffffffff814a2bb0>] rtnetlink_rcv_msg+0x180/0x193
>  [  153.929753]  [<ffffffff810c7c32>] ? trace_preempt_on+0x12/0x2f
>  [  153.931453]  [<ffffffff814a2a30>] ? rtnl_newlink+0x4ba/0x4ba
>  [  153.933107]  [<ffffffff814b67e4>] netlink_rcv_skb+0x44/0x86
>  [  153.934586]  [<ffffffff8149fbeb>] rtnetlink_rcv+0x1e/0x25
>  [  153.936133]  [<ffffffff814b62ef>] netlink_unicast+0xf1/0x175
>  [  153.937587]  [<ffffffff814b6677>] netlink_sendmsg+0x304/0x34e
>  [  153.939088]  [<ffffffff814794ac>] __sock_sendmsg_nosec+0x25/0x27
>  [  153.940638]  [<ffffffff8147b0c2>] sock_sendmsg+0x52/0x6c
>  [  153.942278]  [<ffffffff811009ce>] ? might_fault+0x9b/0x9f
>  [  153.943980]  [<ffffffff81100985>] ? might_fault+0x52/0x9f
>  [  153.945439]  [<ffffffff81487cec>] ? verify_iovec+0x5e/0xac
>  [  153.946993]  [<ffffffff8147cd41>] ___sys_sendmsg+0x20d/0x29d
>  [  153.948540]  [<ffffffff81073236>] ? arch_local_irq_save+0x9/0xc
>  [  153.950087]  [<ffffffff81072708>] ? up_read+0x22/0x25
>  [  153.951743]  [<ffffffff8165a21b>] ? __do_page_fault+0x56f/0x600
>  [  153.953495]  [<ffffffff810c7bdd>] ? time_hardirqs_on+0x1b/0x2f
>  [  153.955175]  [<ffffffff8113fdee>] ? fcheck_files+0x80/0xe0
>  [  153.956720]  [<ffffffff8114062d>] ? fget_light+0x30/0x90
>  [  153.958195]  [<ffffffff8147d20a>] __sys_sendmsg+0x3d/0x5b
>  [  153.959645]  [<ffffffff8147d235>] SyS_sendmsg+0xd/0x17
>  [  153.961092]  [<ffffffff8165d722>] system_call_fastpath+0x16/0x1b
>  [  153.965229] ---[ end trace ec29ec2eecd5a461 ]---
> 

Thanks for the report !

Could you try the following patch ?

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c31190e29b90..17c03198ebbc 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -273,11 +273,12 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 
 void qdisc_list_add(struct Qdisc *q)
 {
-	struct Qdisc *root = qdisc_dev(q)->qdisc;
+	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
+		struct Qdisc *root = qdisc_dev(q)->qdisc;
 
-	WARN_ON_ONCE(root == &noop_qdisc);
-	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS))
+		WARN_ON_ONCE(root == &noop_qdisc);
 		list_add_tail(&q->list, &root->list);
+	}
 }
 EXPORT_SYMBOL(qdisc_list_add);
 
