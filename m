From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] fq_codel: explicitly reset flows in ->reset()
Date: Fri, 31 Jul 2015 17:53:39 -0700
Message-ID: <1438390419-30414-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Alex Gartrell <agartrell@fb.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34877 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbbHAAxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 20:53:48 -0400
Received: by pabkd10 with SMTP id kd10so48727970pab.2
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 17:53:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Alex reported the following crash when using fq_codel
with htb:

  crash> bt
  PID: 630839  TASK: ffff8823c990d280  CPU: 14  COMMAND: "tc"
   [... snip ...]
   #8 [ffff8820ceec17a0] page_fault at ffffffff8160a8c2
      [exception RIP: htb_qlen_notify+24]
      RIP: ffffffffa0841718  RSP: ffff8820ceec1858  RFLAGS: 00010282
      RAX: 0000000000000000  RBX: 0000000000000000  RCX: ffff88241747b400
      RDX: ffff88241747b408  RSI: 0000000000000000  RDI: ffff8811fb27d000
      RBP: ffff8820ceec1868   R8: ffff88120cdeff24   R9: ffff88120cdeff30
      R10: 0000000000000bd4  R11: ffffffffa0840919  R12: ffffffffa0843340
      R13: 0000000000000000  R14: 0000000000000001  R15: ffff8808dae5c2e8
      ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
   #9 [...] qdisc_tree_decrease_qlen at ffffffff81565375
  #10 [...] fq_codel_dequeue at ffffffffa084e0a0 [sch_fq_codel]
  #11 [...] fq_codel_reset at ffffffffa084e2f8 [sch_fq_codel]
  #12 [...] qdisc_destroy at ffffffff81560d2d
  #13 [...] htb_destroy_class at ffffffffa08408f8 [sch_htb]
  #14 [...] htb_put at ffffffffa084095c [sch_htb]
  #15 [...] tc_ctl_tclass at ffffffff815645a3
  #16 [...] rtnetlink_rcv_msg at ffffffff81552cb0
  [... snip ...]

As Jamal pointed out, there is actually no need to call dequeue
to purge the queued skb's in reset, data structures can be just
reset explicitly. Therefore, we reset everything except config's
and stats, so that we would have a fresh start after device flipping.

Fixes: 4b549a2ef4be ("fq_codel: Fair Queue Codel AQM")
Reported-by: Alex Gartrell <agartrell@fb.com>
Cc: Alex Gartrell <agartrell@fb.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
[xiyou.wangcong@gmail.com: added codel_vars_init() and qdisc_qstats_backlog_dec()]
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_fq_codel.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 21ca33c..a9ba030 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -288,10 +288,26 @@ static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 
 static void fq_codel_reset(struct Qdisc *sch)
 {
-	struct sk_buff *skb;
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	int i;
 
-	while ((skb = fq_codel_dequeue(sch)) != NULL)
-		kfree_skb(skb);
+	INIT_LIST_HEAD(&q->new_flows);
+	INIT_LIST_HEAD(&q->old_flows);
+	for (i = 0; i < q->flows_cnt; i++) {
+		struct fq_codel_flow *flow = q->flows + i;
+
+		while (flow->head) {
+			struct sk_buff *skb = dequeue_head(flow);
+
+			qdisc_qstats_backlog_dec(sch, skb);
+			kfree_skb(skb);
+		}
+
+		INIT_LIST_HEAD(&flow->flowchain);
+		codel_vars_init(&flow->cvars);
+	}
+	memset(q->backlogs, 0, q->flows_cnt * sizeof(u32));
+	sch->q.qlen = 0;
 }
 
 static const struct nla_policy fq_codel_policy[TCA_FQ_CODEL_MAX + 1] = {
-- 
1.8.3.1
