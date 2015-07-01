From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net] enic: fix issues in enic_poll
Date: Wed,  1 Jul 2015 11:23:54 +0530
Message-ID: <1435730034-18284-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:51677 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768AbbGAFyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2015 01:54:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In enic_poll, we clean tx and rx queues, when low latency busy socket polling
is happening, enic_poll will only clean tx queue. After cleaning tx, it should
return total budget for re-poll.

Current code checks only rx work done to complete napi. It completely ignores
tx work done. If we have only tx packets to clean and no rq work, we always
napi complete instead of re-poll. Change this behavior to re-poll until
tx work_done + rx work_done is not 0.

There is a small window between vnic_intr_unmask() and enic_poll_unlock_napi().
In this window if an irq occurs and napi is scheduled on different cpu, it tries
to acquire enic_poll_lock_napi() and fails. Unlock napi_poll before unmasking
the interrupt.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index da2004e..6d7ce79 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1170,7 +1170,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 						 wq_work_done,
 						 0 /* dont unmask intr */,
 						 0 /* dont reset intr timer */);
-		return rq_work_done;
+		return budget;
 	}
 
 	if (budget > 0)
@@ -1191,26 +1191,27 @@ static int enic_poll(struct napi_struct *napi, int budget)
 			0 /* don't reset intr timer */);
 
 	err = vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
+	enic_poll_unlock_napi(&enic->rq[cq_rq], napi);
 
 	/* Buffer allocation failed. Stay in polling
 	 * mode so we can try to fill the ring again.
 	 */
 
 	if (err)
-		rq_work_done = rq_work_to_do;
+		return budget;
 
-	if (rq_work_done < rq_work_to_do) {
+	if (!work_done) {
 
-		/* Some work done, but not enough to stay in polling,
-		 * exit polling
+		/* No work to do, exit polling
 		 */
 
 		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[intr]);
+
+		return work_done;
 	}
-	enic_poll_unlock_napi(&enic->rq[cq_rq], napi);
 
-	return rq_work_done;
+	return budget;
 }
 
 static void enic_set_int_moderation(struct enic *enic, struct vnic_rq *rq)
-- 
2.4.5
