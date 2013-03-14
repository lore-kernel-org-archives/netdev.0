From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH v2 net-next 06/22] cxgb4: Enable doorbell drop recovery only for T4 adapter
Date: Thu, 14 Mar 2013 20:38:52 +0530
Message-ID: <1363273748-25330-7-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com, vipul@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25450 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757725Ab3CNPPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:15:23 -0400
In-Reply-To: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Rastapur <santosh@chelsio.com>

Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   87 ++++++++++++++++++----
 1 files changed, 71 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ce1451c..177d0c1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3227,10 +3227,18 @@ EXPORT_SYMBOL(cxgb4_port_chan);
 unsigned int cxgb4_dbfifo_count(const struct net_device *dev, int lpfifo)
 {
 	struct adapter *adap = netdev2adap(dev);
-	u32 v;
+	u32 v1, v2, lp_count, hp_count;
 
-	v = t4_read_reg(adap, A_SGE_DBFIFO_STATUS);
-	return lpfifo ? G_LP_COUNT(v) : G_HP_COUNT(v);
+	v1 = t4_read_reg(adap, A_SGE_DBFIFO_STATUS);
+	v2 = t4_read_reg(adap, SGE_DBFIFO_STATUS2);
+	if (is_t4(adap->chip)) {
+		lp_count = G_LP_COUNT(v1);
+		hp_count = G_HP_COUNT(v1);
+	} else {
+		lp_count = G_LP_COUNT_T5(v1);
+		hp_count = G_HP_COUNT_T5(v2);
+	}
+	return lpfifo ? lp_count : hp_count;
 }
 EXPORT_SYMBOL(cxgb4_dbfifo_count);
 
@@ -3368,14 +3376,23 @@ static struct notifier_block cxgb4_netevent_nb = {
 
 static void drain_db_fifo(struct adapter *adap, int usecs)
 {
-	u32 v;
+	u32 v1, v2, lp_count, hp_count;
 
 	do {
+		v1 = t4_read_reg(adap, A_SGE_DBFIFO_STATUS);
+		v2 = t4_read_reg(adap, SGE_DBFIFO_STATUS2);
+		if (is_t4(adap->chip)) {
+			lp_count = G_LP_COUNT(v1);
+			hp_count = G_HP_COUNT(v1);
+		} else {
+			lp_count = G_LP_COUNT_T5(v1);
+			hp_count = G_HP_COUNT_T5(v2);
+		}
+
+		if (lp_count == 0 && hp_count == 0)
+			break;
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout(usecs_to_jiffies(usecs));
-		v = t4_read_reg(adap, A_SGE_DBFIFO_STATUS);
-		if (G_LP_COUNT(v) == 0 && G_HP_COUNT(v) == 0)
-			break;
 	} while (1);
 }
 
@@ -3484,24 +3501,62 @@ static void process_db_drop(struct work_struct *work)
 
 	adap = container_of(work, struct adapter, db_drop_task);
 
+	if (is_t4(adap->chip)) {
+		disable_dbs(adap);
+		notify_rdma_uld(adap, CXGB4_CONTROL_DB_DROP);
+		drain_db_fifo(adap, 1);
+		recover_all_queues(adap);
+		enable_dbs(adap);
+	} else {
+		u32 dropped_db = t4_read_reg(adap, 0x010ac);
+		u16 qid = (dropped_db >> 15) & 0x1ffff;
+		u16 pidx_inc = dropped_db & 0x1fff;
+		unsigned int s_qpp;
+		unsigned short udb_density;
+		unsigned long qpshift;
+		int page;
+		u32 udb;
+
+		dev_warn(adap->pdev_dev,
+			 "Dropped DB 0x%x qid %d bar2 %d coalesce %d pidx %d\n",
+			 dropped_db, qid,
+			 (dropped_db >> 14) & 1,
+			 (dropped_db >> 13) & 1,
+			 pidx_inc);
+
+		drain_db_fifo(adap, 1);
+
+		s_qpp = QUEUESPERPAGEPF1 * adap->fn;
+		udb_density = 1 << QUEUESPERPAGEPF0_GET(t4_read_reg(adap,
+				SGE_EGRESS_QUEUES_PER_PAGE_PF) >> s_qpp);
+		qpshift = PAGE_SHIFT - ilog2(udb_density);
+		udb = qid << qpshift;
+		udb &= PAGE_MASK;
+		page = udb / PAGE_SIZE;
+		udb += (qid - (page * udb_density)) * 128;
+
+		writel(PIDX(pidx_inc),  adap->bar2 + udb + 8);
+
+		/* Re-enable BAR2 WC */
+		t4_set_reg_field(adap, 0x10b0, 1<<15, 1<<15);
+	}
+
 	t4_set_reg_field(adap, A_SGE_DOORBELL_CONTROL, F_DROPPED_DB, 0);
-	disable_dbs(adap);
-	notify_rdma_uld(adap, CXGB4_CONTROL_DB_DROP);
-	drain_db_fifo(adap, 1);
-	recover_all_queues(adap);
-	enable_dbs(adap);
 }
 
 void t4_db_full(struct adapter *adap)
 {
-	t4_set_reg_field(adap, SGE_INT_ENABLE3,
-			 DBFIFO_HP_INT | DBFIFO_LP_INT, 0);
-	queue_work(workq, &adap->db_full_task);
+	if (is_t4(adap->chip)) {
+		t4_set_reg_field(adap, SGE_INT_ENABLE3,
+				 DBFIFO_HP_INT | DBFIFO_LP_INT, 0);
+		queue_work(workq, &adap->db_full_task);
+	}
 }
 
 void t4_db_dropped(struct adapter *adap)
 {
-	queue_work(workq, &adap->db_drop_task);
+	if (is_t4(adap->chip))
+		queue_work(workq, &adap->db_drop_task);
 }
 
 static void uld_attach(struct adapter *adap, unsigned int uld)
-- 
1.7.1
