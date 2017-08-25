From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: fix a refcount_t issue with noop_qdisc
Date: Thu, 24 Aug 2017 21:12:28 -0700
Message-ID: <1503634348.2499.98.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Reshetova Elena <elena.reshetova@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37795 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbdHYEMb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 00:12:31 -0400
Received: by mail-pg0-f67.google.com with SMTP id a7so2120289pgn.4
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 21:12:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller reported a refcount_t warning [1]

Issue here is that noop_qdisc refcnt was never really considered as
a true refcount, since qdisc_destroy() found TCQ_F_BUILTIN set :

if (qdisc->flags & TCQ_F_BUILTIN ||
    !refcount_dec_and_test(&qdisc->refcnt)))
	return;

Meaning that all atomic_inc() we did on noop_qdisc.refcnt were not
really needed, but harmless until refcount_t came.

To fix this problem, we simply need to not increment noop_qdisc.refcnt,
since we never decrement it.

[1]
refcount_t: increment on 0; use-after-free.
------------[ cut here ]------------
WARNING: CPU: 0 PID: 21754 at lib/refcount.c:152 refcount_inc+0x47/0x50 lib/refcount.c:152
Kernel panic - not syncing: panic_on_warn set ...

CPU: 0 PID: 21754 Comm: syz-executor7 Not tainted 4.13.0-rc6+ #20
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x194/0x257 lib/dump_stack.c:52
 panic+0x1e4/0x417 kernel/panic.c:180
 __warn+0x1c4/0x1d9 kernel/panic.c:541
 report_bug+0x211/0x2d0 lib/bug.c:183
 fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:190
 do_trap_no_signal arch/x86/kernel/traps.c:224 [inline]
 do_trap+0x260/0x390 arch/x86/kernel/traps.c:273
 do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:310
 do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:323
 invalid_op+0x1e/0x30 arch/x86/entry/entry_64.S:846
RIP: 0010:refcount_inc+0x47/0x50 lib/refcount.c:152
RSP: 0018:ffff8801c43477a0 EFLAGS: 00010282
RAX: 000000000000002b RBX: ffffffff86093c14 RCX: 0000000000000000
RDX: 000000000000002b RSI: ffffffff8159314e RDI: ffffed0038868ee8
RBP: ffff8801c43477a8 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff86093ac0
R13: 0000000000000001 R14: ffff8801d0f3bac0 R15: dffffc0000000000
 attach_default_qdiscs net/sched/sch_generic.c:792 [inline]
 dev_activate+0x7d3/0xaa0 net/sched/sch_generic.c:833
 __dev_open+0x227/0x330 net/core/dev.c:1380
 __dev_change_flags+0x695/0x990 net/core/dev.c:6726
 dev_change_flags+0x88/0x140 net/core/dev.c:6792
 dev_ifsioc+0x5a6/0x930 net/core/dev_ioctl.c:256
 dev_ioctl+0x2bc/0xf90 net/core/dev_ioctl.c:554
 sock_do_ioctl+0x94/0xb0 net/socket.c:968
 sock_ioctl+0x2c2/0x440 net/socket.c:1058
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691

Fixes: 7b9364050246 ("net, sched: convert Qdisc.refcnt from atomic_t to refcount_t")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Reshetova, Elena <elena.reshetova@intel.com>
---
 include/net/sch_generic.h |    7 +++++++
 net/sched/sch_api.c       |    6 +++---
 net/sched/sch_generic.c   |    2 +-
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 67f815e5d52517390226bc3531b1ea7b5f1020bc..c1109cdbbfa6afb9aff0d6033aef7b615630ffc1 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -101,6 +101,13 @@ struct Qdisc {
 	spinlock_t		busylock ____cacheline_aligned_in_smp;
 };
 
+static inline void qdisc_refcount_inc(struct Qdisc *qdisc)
+{
+	if (qdisc->flags & TCQ_F_BUILTIN)
+		return;
+	refcount_inc(&qdisc->refcnt);
+}
+
 static inline bool qdisc_is_running(const struct Qdisc *qdisc)
 {
 	return (raw_read_seqcount(&qdisc->running) & 1) ? true : false;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a3fa144b864871088209386fd573bded1886432f..4fb5a3222d0d324167f079f755be14eb028b4a50 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -836,7 +836,7 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 
 			old = dev_graft_qdisc(dev_queue, new);
 			if (new && i > 0)
-				refcount_inc(&new->refcnt);
+				qdisc_refcount_inc(new);
 
 			if (!ingress)
 				qdisc_destroy(old);
@@ -847,7 +847,7 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 			notify_and_destroy(net, skb, n, classid,
 					   dev->qdisc, new);
 			if (new && !new->ops->attach)
-				refcount_inc(&new->refcnt);
+				qdisc_refcount_inc(new);
 			dev->qdisc = new ? : &noop_qdisc;
 
 			if (new && new->ops->attach)
@@ -1256,7 +1256,7 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n,
 				if (q == p ||
 				    (p && check_loop(q, p, 0)))
 					return -ELOOP;
-				refcount_inc(&q->refcnt);
+				qdisc_refcount_inc(q);
 				goto graft;
 			} else {
 				if (!q)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 57ba406f1437323a4ba172d52f14a8b687b86708..4ba6da5fb2546c35ad48fe1f3632df8ca9957b34 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -785,7 +785,7 @@ static void attach_default_qdiscs(struct net_device *dev)
 	    dev->priv_flags & IFF_NO_QUEUE) {
 		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
 		dev->qdisc = txq->qdisc_sleeping;
-		refcount_inc(&dev->qdisc->refcnt);
+		qdisc_refcount_inc(dev->qdisc);
 	} else {
 		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
 		if (qdisc) {
