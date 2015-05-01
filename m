From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: sched: run ingress qdisc without locks
Date: Thu, 30 Apr 2015 20:14:07 -0700
Message-ID: <1430450047-5671-1-git-send-email-ast@plumgrid.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36216 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbbEADOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 23:14:15 -0400
Received: by pabsx10 with SMTP id sx10so78850621pab.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 20:14:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC classifiers/actions were converted to RCU by John in the series:
http://thread.gmane.org/gmane.linux.network/329739/focus=329739
and many follow on patches.
This is the last patch from that series that finally drops
ingress spin_lock.

Single cpu ingress+u32 performance goes from 22.9 Mpps to 24.5 Mpps.

In two cpu case when both cores are receiving traffic on the same
device and go into the same ingress+u32 the performance jumps
from 4.5 + 4.5 Mpps to 23.5 + 23.5 Mpps

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
All the credit goes to John. I merely tested and benchmarked.

 net/core/dev.c          |    2 --
 net/sched/sch_ingress.c |    5 +++--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 97a15ae8d07a..862875ec8f2f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3538,10 +3538,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 
 	q = rcu_dereference(rxq->qdisc);
 	if (q != &noop_qdisc) {
-		spin_lock(qdisc_lock(q));
 		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
 			result = qdisc_enqueue_root(skb, q);
-		spin_unlock(qdisc_lock(q));
 	}
 
 	return result;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 4cdbfb85686a..a89cc3278bfb 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -65,11 +65,11 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	result = tc_classify(skb, fl, &res);
 
-	qdisc_bstats_update(sch, skb);
+	qdisc_bstats_update_cpu(sch, skb);
 	switch (result) {
 	case TC_ACT_SHOT:
 		result = TC_ACT_SHOT;
-		qdisc_qstats_drop(sch);
+		qdisc_qstats_drop_cpu(sch);
 		break;
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
@@ -91,6 +91,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	net_inc_ingress_queue();
+	sch->flags |= TCQ_F_CPUSTATS;
 
 	return 0;
 }
-- 
1.7.9.5
