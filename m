From: divy@chelsio.com
Subject: [PATCH 5/7] cxgb3 - Recovery from HW starvation of response queue
	entries.
Date: Sat, 24 Feb 2007 16:44:12 -0800
Message-ID: <20070225004412.20867.8522.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28116 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932903AbXBYAoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 19:44:16 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Improve the traffic recovery after the HW ran out of response queue entries.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    2 ++
 drivers/net/cxgb3/sge.c     |   15 ++++++++++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 5c97a64..01b99b9 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -121,6 +121,8 @@ struct sge_rspq {		/* state for an SGE r
 	unsigned long empty;	/* # of times queue ran out of credits */
 	unsigned long nomem;	/* # of responses deferred due to no mem */
 	unsigned long unhandled_irqs;	/* # of spurious intrs */
+	unsigned long starved;
+	unsigned long restarted;
 };
 
 struct tx_desc;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 822a598..4ff0ab6 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2376,13 +2376,26 @@ static void sge_timer_cb(unsigned long d
 		spin_unlock(&qs->txq[TXQ_OFLD].lock);
 	}
 	lock = (adap->flags & USING_MSIX) ? &qs->rspq.lock :
-	    &adap->sge.qs[0].rspq.lock;
+					    &adap->sge.qs[0].rspq.lock;
 	if (spin_trylock_irq(lock)) {
 		if (!napi_is_scheduled(qs->netdev)) {
+			u32 status = t3_read_reg(adap, A_SG_RSPQ_FL_STATUS);
+
 			if (qs->fl[0].credits < qs->fl[0].size)
 				__refill_fl(adap, &qs->fl[0]);
 			if (qs->fl[1].credits < qs->fl[1].size)
 				__refill_fl(adap, &qs->fl[1]);
+
+			if (status & (1 << qs->rspq.cntxt_id)) {
+				qs->rspq.starved++;
+				if (qs->rspq.credits) {
+					refill_rspq(adap, &qs->rspq, 1);
+					qs->rspq.credits--;
+					qs->rspq.restarted++;
+					t3_write_reg(adap, A_SG_RSPQ_FL_STATUS, 
+						     1 << qs->rspq.cntxt_id);
+				}
+			}
 		}
 		spin_unlock_irq(lock);
 	}
