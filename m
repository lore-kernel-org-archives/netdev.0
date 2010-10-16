From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] net/sched: fix missing spinlock init
Date: Sat, 16 Oct 2010 07:22:34 +0200
Message-ID: <1287206554.2799.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47445 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab0JPFWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 01:22:41 -0400
Received: by wwj40 with SMTP id 40so1857945wwj.1
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 22:22:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under network load, doing :

tc qdisc del dev eth0 root

triggers :

[  167.193087] BUG: spinlock bad magic on CPU#3, udpflood/4928
[  167.193139]  lock: c15bc324, .magic: 00000000, .owner:
<none>/-1, .owner_cpu: -1
[  167.193193] Pid: 4928, comm: udpflood Not tainted
2.6.36-rc7-11417-g215340c-dirty #323
[  167.193245] Call Trace:
[  167.193292]  [<c13abaa0>] ? printk+0x18/0x20
[  167.193342]  [<c11afb53>] spin_bug+0xa3/0xf0
[  167.193389]  [<c11afcdd>] do_raw_spin_lock+0x7d/0x160
[  167.193440]  [<c1313d4e>] ? __dev_xmit_skb+0x27e/0x2b0
[  167.193496]  [<c107382b>] ? trace_hardirqs_on+0xb/0x10
[  167.193545]  [<c13ae99a>] _raw_spin_lock+0x3a/0x40
[  167.193593]  [<c1313d4e>] ? __dev_xmit_skb+0x27e/0x2b0
[  167.193641]  [<c1313d4e>] __dev_xmit_skb+0x27e/0x2b0

commit 79640a4ca695 (add additional lock to qdisc to increase
throughput) forgot to initialize  noop_qdisc and noqueue_qdisc busylock 

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_generic.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 3d57681..0abcc49 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -383,6 +383,7 @@ struct Qdisc noop_qdisc = {
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.dev_queue	=	&noop_netdev_queue,
+	.busylock	=	__SPIN_LOCK_UNLOCKED(noop_qdisc.busylock),
 };
 EXPORT_SYMBOL(noop_qdisc);
 
@@ -409,6 +410,7 @@ static struct Qdisc noqueue_qdisc = {
 	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
 	.dev_queue	=	&noqueue_netdev_queue,
+	.busylock	=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.busylock),
 };
 
 


