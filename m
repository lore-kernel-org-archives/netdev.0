From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next 6/8] liquidio: moved liquidio_napi_poll to
 lio_core.c
Date: Mon, 14 Aug 2017 12:01:50 -0700
Message-ID: <20170814190150.GA1297@felix-thinkpad.cavium.com>
References: <20170814190034.GA1219@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0050.outbound.protection.outlook.com ([104.47.33.50]:49504
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752274AbdHNTB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 15:01:56 -0400
Content-Disposition: inline
In-Reply-To: <20170814190034.GA1219@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Moving common liquidio_napi_poll to lio_core.c

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 61 +++++++++++++++++++++-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 52 ------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 54 -------------------
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  2 +-
 4 files changed, 61 insertions(+), 108 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 8cba927..2030c25 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -366,7 +366,7 @@ void cleanup_rx_oom_poll_fn(struct net_device *netdev)
 }
 
 /* Runs in interrupt context. */
-void lio_update_txq_status(struct octeon_device *oct, int iq_num)
+static void lio_update_txq_status(struct octeon_device *oct, int iq_num)
 {
 	struct octeon_instr_queue *iq = oct->instr_queue[iq_num];
 	struct net_device *netdev;
@@ -620,3 +620,62 @@ void liquidio_napi_drv_callback(void *arg)
 		smp_call_function_single_async(droq->cpu_id, csd);
 	}
 }
+
+/**
+ * \brief Entry point for NAPI polling
+ * @param napi NAPI structure
+ * @param budget maximum number of items to process
+ */
+int liquidio_napi_poll(struct napi_struct *napi, int budget)
+{
+	struct octeon_instr_queue *iq;
+	struct octeon_device *oct;
+	struct octeon_droq *droq;
+	int tx_done = 0, iq_no;
+	int work_done;
+
+	droq = container_of(napi, struct octeon_droq, napi);
+	oct = droq->oct_dev;
+	iq_no = droq->q_no;
+
+	/* Handle Droq descriptors */
+	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
+						 POLL_EVENT_PROCESS_PKTS,
+						 budget);
+
+	/* Flush the instruction queue */
+	iq = oct->instr_queue[iq_no];
+	if (iq) {
+		/* TODO: move this check to inside octeon_flush_iq,
+		 * once check_db_timeout is removed
+		 */
+		if (atomic_read(&iq->instr_pending))
+			/* Process iq buffers with in the budget limits */
+			tx_done = octeon_flush_iq(oct, iq, budget);
+		else
+			tx_done = 1;
+		/* Update iq read-index rather than waiting for next interrupt.
+		 * Return back if tx_done is false.
+		 */
+		/* sub-queue status update */
+		lio_update_txq_status(oct, iq_no);
+	} else {
+		dev_err(&oct->pci_dev->dev, "%s:  iq (%d) num invalid\n",
+			__func__, iq_no);
+	}
+
+#define MAX_REG_CNT  2000000U
+	/* force enable interrupt if reg cnts are high to avoid wraparound */
+	if (((work_done < budget) && (tx_done)) ||
+	    (iq->pkt_in_done >= MAX_REG_CNT) ||
+	    (droq->pkt_count >= MAX_REG_CNT)) {
+		tx_done = 1;
+		napi_complete_done(napi, work_done);
+
+		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
+					     POLL_EVENT_ENABLE_INTR, 0);
+		return 0;
+	}
+
+	return (!tx_done) ? (budget) : (work_done);
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 4241949..b00d199 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2229,58 +2229,6 @@ static void if_cfg_callback(struct octeon_device *oct,
 }
 
 /**
- * \brief Entry point for NAPI polling
- * @param napi NAPI structure
- * @param budget maximum number of items to process
- */
-static int liquidio_napi_poll(struct napi_struct *napi, int budget)
-{
-	struct octeon_droq *droq;
-	int work_done;
-	int tx_done = 0, iq_no;
-	struct octeon_instr_queue *iq;
-	struct octeon_device *oct;
-
-	droq = container_of(napi, struct octeon_droq, napi);
-	oct = droq->oct_dev;
-	iq_no = droq->q_no;
-	/* Handle Droq descriptors */
-	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
-						 POLL_EVENT_PROCESS_PKTS,
-						 budget);
-
-	/* Flush the instruction queue */
-	iq = oct->instr_queue[iq_no];
-	if (iq) {
-		if (atomic_read(&iq->instr_pending))
-			/* Process iq buffers with in the budget limits */
-			tx_done = octeon_flush_iq(oct, iq, budget);
-		else
-			tx_done = 1;
-		/* Update iq read-index rather than waiting for next interrupt.
-		 * Return back if tx_done is false.
-		 */
-		lio_update_txq_status(oct, iq_no);
-	} else {
-		dev_err(&oct->pci_dev->dev, "%s:  iq (%d) num invalid\n",
-			__func__, iq_no);
-	}
-
-	/* force enable interrupt if reg cnts are high to avoid wraparound */
-	if ((work_done < budget && tx_done) ||
-	    (iq && iq->pkt_in_done >= MAX_REG_CNT) ||
-	    (droq->pkt_count >= MAX_REG_CNT)) {
-		tx_done = 1;
-		napi_complete_done(napi, work_done);
-		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
-					     POLL_EVENT_ENABLE_INTR, 0);
-		return 0;
-	}
-
-	return (!tx_done) ? (budget) : (work_done);
-}
-
-/**
  * \brief Setup input and output queues
  * @param octeon_dev octeon device
  * @param ifidx  Interface Index
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 2663bd6..0bd0c30 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1377,60 +1377,6 @@ static void if_cfg_callback(struct octeon_device *oct,
 }
 
 /**
- * \brief Entry point for NAPI polling
- * @param napi NAPI structure
- * @param budget maximum number of items to process
- */
-static int liquidio_napi_poll(struct napi_struct *napi, int budget)
-{
-	struct octeon_instr_queue *iq;
-	struct octeon_device *oct;
-	struct octeon_droq *droq;
-	int tx_done = 0, iq_no;
-	int work_done;
-
-	droq = container_of(napi, struct octeon_droq, napi);
-	oct = droq->oct_dev;
-	iq_no = droq->q_no;
-
-	/* Handle Droq descriptors */
-	work_done = octeon_process_droq_poll_cmd(oct, droq->q_no,
-						 POLL_EVENT_PROCESS_PKTS,
-						 budget);
-
-	/* Flush the instruction queue */
-	iq = oct->instr_queue[iq_no];
-	if (iq) {
-		if (atomic_read(&iq->instr_pending))
-			/* Process iq buffers with in the budget limits */
-			tx_done = octeon_flush_iq(oct, iq, budget);
-		else
-			tx_done = 1;
-
-		/* Update iq read-index rather than waiting for next interrupt.
-		 * Return back if tx_done is false.
-		 */
-		lio_update_txq_status(oct, iq_no);
-	} else {
-		dev_err(&oct->pci_dev->dev, "%s: iq (%d) num invalid\n",
-			__func__, iq_no);
-	}
-
-	/* force enable interrupt if reg cnts are high to avoid wraparound */
-	if ((work_done < budget && tx_done) ||
-	    (iq && iq->pkt_in_done >= MAX_REG_CNT) ||
-	    (droq->pkt_count >= MAX_REG_CNT)) {
-		tx_done = 1;
-		napi_complete_done(napi, work_done);
-		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
-					     POLL_EVENT_ENABLE_INTR, 0);
-		return 0;
-	}
-
-	return (!tx_done) ? (budget) : (work_done);
-}
-
-/**
  * \brief Setup input and output queues
  * @param octeon_dev octeon device
  * @param ifidx Interface index
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 076fdfc..b6597ef 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -474,7 +474,6 @@ static inline int wait_for_pending_requests(struct octeon_device *oct)
 	return 0;
 }
 
-void lio_update_txq_status(struct octeon_device *oct, int iq_num);
 int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
 		      int desc_size, void *app_ctx);
 void
@@ -485,4 +484,5 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 		     void *param,
 		     void *arg);
 void liquidio_napi_drv_callback(void *arg);
+int liquidio_napi_poll(struct napi_struct *napi, int budget);
 #endif
-- 
2.9.0
