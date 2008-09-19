From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] multiq: requeue should rewind the current_band
Date: Thu, 18 Sep 2008 17:43:22 -0700
Message-ID: <20080919004322.10002.33219.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:12733 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755623AbYISAnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 20:43:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently dequeueing a packet and requeueing the same packet will cause a
different packet to be pulled on the next dequeue.  This change forces
requeue to rewind the current_band.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/sched/sch_multiq.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 5d9cd68..915f314 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -97,6 +97,7 @@ static int
 multiq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct Qdisc *qdisc;
+	struct multiq_sched_data *q = qdisc_priv(sch);
 	int ret;
 
 	qdisc = multiq_classify(skb, sch, &ret);
@@ -113,6 +114,10 @@ multiq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
+		if (q->curband)
+			q->curband--;
+		else
+			q->curband = q->bands - 1;
 		return NET_XMIT_SUCCESS;
 	}
 	if (net_xmit_drop_count(ret))

