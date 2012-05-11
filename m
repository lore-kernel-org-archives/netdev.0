From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_htb: report backlog information in htb classes
Date: Sat, 12 May 2012 00:31:34 +0200
Message-ID: <1336775494.31653.297.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53124 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761095Ab2EKWbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:31:38 -0400
Received: by weyu7 with SMTP id u7so678153wey.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 15:31:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

htb classes at level 0 can copy their qdisc child backlog to provide to
"tc -s class" users more relevant information. (packet counter is
correct but byte counter (backlog) is 0)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_htb.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 9d75b77..0f4d534 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1073,9 +1073,10 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	spin_lock_bh(root_lock);
 	tcm->tcm_parent = cl->parent ? cl->parent->common.classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->common.classid;
-	if (!cl->level && cl->un.leaf.q)
+	if (!cl->level && cl->un.leaf.q) {
 		tcm->tcm_info = cl->un.leaf.q->handle;
-
+		sch->qstats.backlog = cl->un.leaf.q->qstats.backlog;
+	}
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
