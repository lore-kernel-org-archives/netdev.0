From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] htb: call qdisc_root with rcu read lock held
Date: Tue, 14 Jun 2016 06:16:27 +0200
Message-ID: <1465877787-7974-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42265 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750805AbcFNEQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 00:16:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

saw a debug splat:
net/include/net/sch_generic.h:287 suspicious rcu_dereference_check() usage!
other info that might help us debug this:
rcu_scheduler_active = 1, debug_locks = 0
 2 locks held by kworker/2:1/710:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8106ca1d>]
  #1:  ((&q->work)){+.+...}, at: [<ffffffff8106ca1d>] process_one_work+0x14d/0x690
Workqueue: events htb_work_func
Call Trace:
 [<ffffffff812dc763>] dump_stack+0x85/0xc2
 [<ffffffff8109fee7>] lockdep_rcu_suspicious+0xe7/0x120
 [<ffffffff814ced47>] htb_work_func+0x67/0x70

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/sched/sch_htb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d4b4218..62f9d81 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1007,7 +1007,9 @@ static void htb_work_func(struct work_struct *work)
 	struct htb_sched *q = container_of(work, struct htb_sched, work);
 	struct Qdisc *sch = q->watchdog.qdisc;
 
+	rcu_read_lock();
 	__netif_schedule(qdisc_root(sch));
+	rcu_read_unlock();
 }
 
 static int htb_init(struct Qdisc *sch, struct nlattr *opt)
-- 
2.7.3
