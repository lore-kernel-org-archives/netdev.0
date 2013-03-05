From: Paolo valente <paolo.valente@unimore.it>
Subject: [PATCH BUGFIX 6/6] pkt_sched: remove a useless invocation of qfq_update_eligible
Date: Tue,  5 Mar 2013 19:05:02 +0100
Message-ID: <1362506702-4985-7-git-send-email-paolo.valente@unimore.it>
References: <20130226.173700.882998504986475149.davem@davemloft.net>
 <1362506702-4985-1-git-send-email-paolo.valente@unimore.it>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fchecconi@gmail.com, rizzo@iet.unipi.it,
	Paolo Valente <paolo.valente@unimore.it>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362506702-4985-1-git-send-email-paolo.valente@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QFQ+ can select for service only 'eligible' aggregates, i.e.,
aggregates that would have started to be served also in the emulated
ideal system.  As a consequence, for QFQ+ to be work conserving, at
least one of the active aggregates must be eligible when it is time to
choose the next aggregate to serve.

The set of eligible aggregates is updated through the function
qfq_update_eligible(), which does guarantee that, after its
invocation, at least one of the active aggregates is eligible.
Because of this property, this function is invoked in
qfq_deactivate_agg() to guarantee that at least one of the active
aggregates is still eligible after an aggregate has been deactivated.
In particular, the critical case is when there are other active
aggregates, but the aggregate being deactivated happens to be the only
one eligible.

However, this precaution is not needed for QFQ+ to be work conserving,
because update_eligible() is always invoked also at the beginning of
qfq_choose_next_agg(). This patch removes the additional invocation of
update_eligible() in qfq_deactivate_agg().

Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
Reviewed-by: Fabio Checconi <fchecconi@gmail.com>
---
 net/sched/sch_qfq.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 5d327b3..7cfa1f8 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1385,8 +1385,6 @@ static void qfq_deactivate_agg(struct qfq_sched *q, struct qfq_aggregate *agg)
 			__set_bit(grp->index, &q->bitmaps[s]);
 		}
 	}
-
-	qfq_update_eligible(q);
 }
 
 static void qfq_qlen_notify(struct Qdisc *sch, unsigned long arg)
-- 
1.7.9.5
