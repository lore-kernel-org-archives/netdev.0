From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net_sched: gred: Fix oops in gred_dump() in WRED mode
Date: Sun, 15 Apr 2012 18:31:45 -0400
Message-ID: <1334529106-5035-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:41333 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752051Ab2DOWb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Apr 2012 18:31:56 -0400
Received: from LLE2K7-HUB02.mitll.ad.local (LLE2K7-HUB02.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id q3FMVtLI013061 for <netdev@vger.kernel.org>; Sun, 15 Apr 2012 18:31:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A parameter set exists for WRED mode, called wred_set, to hold the same
values for qavg and qidlestart across all VQs. The WRED mode values had
been previously held in the VQ for the default DP. After these values
were moved to wred_set, the VQ for the default DP was no longer created
automatically (so that it could be omitted on purpose, to have packets
in the default DP enqueued directly to the device without using RED).

However, gred_dump() was overlooked during that change; in WRED mode it
still reads qavg/qidlestart from the VQ for the default DP, which might
not even exist. As a result, this command sequence will cause an oops:

tc qdisc add dev $DEV handle $HANDLE parent $PARENT gred setup \
    DPs 3 default 2 grio
tc qdisc change dev $DEV handle $HANDLE gred DP 0 prio 8 $RED_OPTIONS
tc qdisc change dev $DEV handle $HANDLE gred DP 1 prio 8 $RED_OPTIONS

This fixes gred_dump() in WRED mode to use the values held in wred_set.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/sched/sch_gred.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 55e3310..ab620bf 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -567,11 +567,8 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 		opt.packets	= q->packetsin;
 		opt.bytesin	= q->bytesin;
 
-		if (gred_wred_mode(table)) {
-			q->vars.qidlestart =
-				table->tab[table->def]->vars.qidlestart;
-			q->vars.qavg = table->tab[table->def]->vars.qavg;
-		}
+		if (gred_wred_mode(table))
+			gred_load_wred_set(table, q);
 
 		opt.qave = red_calc_qavg(&q->parms, &q->vars, q->vars.qavg);
 
-- 
1.7.1
