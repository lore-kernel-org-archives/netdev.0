From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/6] pkt_sched: sch_htb: Consider used jiffies in
	htb_do_events()
Date: Tue, 9 Dec 2008 10:21:03 +0000
Message-ID: <20081209102103.GA14862@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:44025 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbYLIKVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 05:21:11 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1033647ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 02:21:09 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next event time should consider jiffies used for recounting. Otherwise
qdisc_watchdog_schedule() triggers hrtimer immediately with the event
in the past, and may cause very high ksoftirqd cpu usage (if highres
is on).

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f89fd71..d6eb4a7 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -685,8 +685,8 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level)
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
 	}
-	/* too much load - let's continue on next jiffie */
-	return q->now + PSCHED_TICKS_PER_SEC / HZ;
+	/* too much load - let's continue on next jiffie (including above) */
+	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
-- 
1.5.6.5

