From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 1/5] cxgb3: start qset timers when setup succeeded
Date: Thu, 26 Mar 2009 19:39:09 -0700
Message-ID: <20090327023909.32137.93884.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31274 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973AbZC0CjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 22:39:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Start queue set reclaim timers after the queue sets have been
allocated successfully.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h    |    1 +
 drivers/net/cxgb3/cxgb3_main.c |    3 ++-
 drivers/net/cxgb3/sge.c        |   24 +++++++++++++++++++++---
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 71eaa43..2cf6c92 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -291,6 +291,7 @@ void t3_os_link_fault_handler(struct adapter *adapter, int port_id);
 
 void t3_sge_start(struct adapter *adap);
 void t3_sge_stop(struct adapter *adap);
+void t3_start_sge_timers(struct adapter *adap);
 void t3_stop_sge_timers(struct adapter *adap);
 void t3_free_sge_resources(struct adapter *adap);
 void t3_sge_err_intr_handler(struct adapter *adapter);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
old mode 100644
new mode 100755
index d8be896..8ad5f32
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -602,7 +602,6 @@ static int setup_sge_qsets(struct adapter *adap)
 				&adap->params.sge.qset[qset_idx], ntxq, dev,
 				netdev_get_tx_queue(dev, j));
 			if (err) {
-				t3_stop_sge_timers(adap);
 				t3_free_sge_resources(adap);
 				return err;
 			}
@@ -1046,6 +1045,8 @@ static int cxgb_up(struct adapter *adap)
 		setup_rss(adap);
 		if (!(adap->flags & NAPI_INIT))
 			init_napi(adap);
+
+		t3_start_sge_timers(adap);
 		adap->flags |= FULL_INIT_DONE;
 	}
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
old mode 100644
new mode 100755
index a7555cb..fcd1a4f
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -3044,9 +3044,6 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	t3_write_reg(adapter, A_SG_GTS, V_RSPQ(q->rspq.cntxt_id) |
 		     V_NEWTIMER(q->rspq.holdoff_tmr));
 
-	mod_timer(&q->tx_reclaim_timer, jiffies + TX_RECLAIM_PERIOD);
-	mod_timer(&q->rx_reclaim_timer, jiffies + RX_RECLAIM_PERIOD);
-
 	return 0;
 
 err_unlock:
@@ -3057,6 +3054,27 @@ err:
 }
 
 /**
+ *      t3_start_sge_timers - start SGE timer call backs
+ *      @adap: the adapter
+ *
+ *      Starts each SGE queue set's timer call back
+ */
+void t3_start_sge_timers(struct adapter *adap)
+{
+	int i;
+
+	for (i = 0; i < SGE_QSETS; ++i) {
+		struct sge_qset *q = &adap->sge.qs[i];
+
+	if (q->tx_reclaim_timer.function)
+		mod_timer(&q->tx_reclaim_timer, jiffies + TX_RECLAIM_PERIOD);
+
+	if (q->rx_reclaim_timer.function)
+		mod_timer(&q->rx_reclaim_timer, jiffies + RX_RECLAIM_PERIOD);
+	}
+}
+
+/**
  *	t3_stop_sge_timers - stop SGE timer call backs
  *	@adap: the adapter
  *

