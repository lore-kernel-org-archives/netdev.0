From: Paolo Valente <paolo.valente@unimore.it>
Subject: [PATCH] sched: fix virtual-start-time update in QFQ
Date: Sat, 15 Sep 2012 12:41:35 +0200
Message-ID: <20120915104134.GA29862@paolo-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fchecconi@gmail.com, rizzo@iet.unipi.it, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paolo.valente@unimore.it
To: davem@davemloft.net, shemminger@vyatta.com, jhs@mojatatu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the old timestamps of a class, say cl, are stale when the class
becomes active, then QFQ may assign to cl a much higher start time
than the maximum value allowed. This may happen when QFQ assigns to
the start time of cl the finish time of a group whose classes are
characterized by a higher value of the ratio
max_class_pkt/weight_of_the_class with respect to that of
cl. Inserting a class with a too high start time into the bucket list
corrupts the data structure and may eventually lead to crashes.
This patch limits the maximum start time assigned to a class.

Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
---
 net/sched/sch_qfq.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index e4723d3..211a212 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -865,7 +865,10 @@ static void qfq_update_start(struct qfq_sched *q, struct qfq_class *cl)
 		if (mask) {
 			struct qfq_group *next = qfq_ffs(q, mask);
 			if (qfq_gt(roundedF, next->F)) {
-				cl->S = next->F;
+				if (qfq_gt(limit, next->F))
+					cl->S = next->F;
+				else /* preserve timestamp correctness */
+					cl->S = limit;
 				return;
 			}
 		}
-- 
1.7.9.5
