From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net v2] enic: fix issues in enic_poll
Date: Wed,  1 Jul 2015 14:21:57 +0530
Message-ID: <1435740717-12325-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:57523 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058AbbGAIwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2015 04:52:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In enic_poll, we clean tx and rx queues, when low latency busy socket polling
is happening, enic_poll will only clean tx queue. After cleaning tx, it should
return total budget for re-poll.

There is a small window between vnic_intr_unmask() and enic_poll_unlock_napi().
In this window if an irq occurs and napi is scheduled on different cpu, it tries
to acquire enic_poll_lock_napi() and fails. Unlock napi_poll before unmasking
the interrupt.

v2:
Do not change tx wonk done behaviour. Consider only rx work done for completing
napi.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index da2004e..918a8e4 100644
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
@@ -1191,6 +1191,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 			0 /* don't reset intr timer */);
 
 	err = vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
+	enic_poll_unlock_napi(&enic->rq[cq_rq], napi);
 
 	/* Buffer allocation failed. Stay in polling
 	 * mode so we can try to fill the ring again.
@@ -1208,7 +1209,6 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[intr]);
 	}
-	enic_poll_unlock_napi(&enic->rq[cq_rq], napi);
 
 	return rq_work_done;
 }
-- 
2.4.4
