From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] NET: Fix sch_prio to detect the root qdisc loading
Date: Sat, 21 Jul 2007 12:14:59 -0700
Message-ID: <20070721191459.2146.48448.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33071 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754711AbXGUTPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 15:15:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sch->parent handle will be NULL for the scheduler that is TC_H_ROOT.
Change this check in prio_tune() so that only the root qdisc can be
multiqueue-enabled.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 net/sched/sch_prio.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2d8c084..271051e 100644
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
+		if (sch->parent != NULL)
 			return -EINVAL;
 		if (netif_is_multiqueue(sch->dev)) {
 			if (q->bands == 0)
