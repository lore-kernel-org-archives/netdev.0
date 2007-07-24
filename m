From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 2/2] NET: Fix sch_prio to properly detect the root qdisc on
	multiqueue
Date: Tue, 24 Jul 2007 15:33:57 -0700
Message-ID: <20070724223357.10658.43826.stgit@localhost.localdomain>
References: <20070724223346.10658.80645.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56090 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757369AbXGXWd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 18:33:59 -0400
In-Reply-To: <20070724223346.10658.80645.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the check in prio_tune() to see if sch->parent is TC_H_ROOT instead of
sch->handle to load or reject the qdisc for multiqueue devices.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 net/sched/sch_prio.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2d8c084..06441db 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -239,11 +239,13 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 	/* If we're multiqueue, make sure the number of incoming bands
 	 * matches the number of queues on the device we're associating with.
 	 * If the number of bands requested is zero, then set q->bands to
-	 * dev->egress_subqueue_count.
+	 * dev->egress_subqueue_count.  Also, the root qdisc must be the
+	 * only one that is enabled for multiqueue, since it's the only one
+	 * that interacts with the underlying device.
 	 */
 	q->mq = RTA_GET_FLAG(tb[TCA_PRIO_MQ - 1]);
 	if (q->mq) {
-		if (sch->handle != TC_H_ROOT)
+		if (sch->parent != TC_H_ROOT)
 			return -EINVAL;
 		if (netif_is_multiqueue(sch->dev)) {
 			if (q->bands == 0)
