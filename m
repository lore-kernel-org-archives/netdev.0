From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next  03/18] liquidio support for new device cn23xx
Date: Wed, 3 Aug 2016 11:55:34 -0700
Message-ID: <1470250549-10993-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0059.outbound.protection.outlook.com ([104.47.33.59]:13184
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758270AbcHCUbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 16:31:09 -0400
In-Reply-To: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for adding common lio_enable_irq
function for iq and oq.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  1 +
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  2 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 17 +++++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  2 ++
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 33 +++++++++++++---------
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  2 ++
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  2 ++
 .../net/ethernet/cavium/liquidio/request_manager.c |  3 ++
 8 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 06f4094..8798246 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -192,6 +192,7 @@ static void octeon_droq_bh(unsigned long pdev)
 			continue;
 		reschedule |= octeon_droq_process_packets(oct, oct->droq[q_no],
 							  MAX_PACKET_BUDGET);
+		lio_enable_irq(oct->droq[q_no], NULL);
 	}
 
 	if (reschedule)
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 0a5bc1f..9f328ff 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -848,7 +848,7 @@ struct oct_mdio_cmd {
 /* intrmod: max. packets to trigger interrupt */
 #define LIO_INTRMOD_RXMAXCNT_TRIGGER	384
 /* intrmod: min. packets to trigger interrupt */
-#define LIO_INTRMOD_RXMINCNT_TRIGGER	1
+#define LIO_INTRMOD_RXMINCNT_TRIGGER	0
 /* intrmod: max. time to trigger interrupt */
 #define LIO_INTRMOD_RXMAXTMR_TRIGGER	128
 /* 66xx:intrmod: min. time to trigger interrupt
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index cff845c..541137a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -1122,3 +1122,20 @@ int lio_get_device_id(void *dev)
 			return octeon_dev->octeon_id;
 	return -1;
 }
+
+void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq)
+{
+	/* the whole thing needs to be atomic, ideally */
+	if (droq) {
+		spin_lock_bh(&droq->lock);
+		writel(droq->pkt_count, droq->pkts_sent_reg);
+		droq->pkt_count = 0;
+		spin_unlock_bh(&droq->lock);
+	}
+	if (iq) {
+		spin_lock_bh(&iq->lock);
+		writel(iq->pkt_in_done, iq->inst_cnt_reg);
+		iq->pkt_in_done = 0;
+		spin_unlock_bh(&iq->lock);
+	}
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 01edfb4..fcda21e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -661,6 +661,8 @@ void *oct_get_config_info(struct octeon_device *oct, u16 card_type);
  */
 struct octeon_config *octeon_get_conf(struct octeon_device *oct);
 
+void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq);
+
 /* LiquidIO driver pivate flags */
 enum {
 	OCT_PRIV_FLAG_TX_BYTES = 0, /* Tx interrupts by pending byte count */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index e0afe4c..5dfc23d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -92,22 +92,25 @@ static inline void *octeon_get_dispatch_arg(struct octeon_device *octeon_dev,
 	return fn_arg;
 }
 
-/** Check for packets on Droq. This function should be called with
- * lock held.
+/** Check for packets on Droq. This function should be called with lock held.
  *  @param  droq - Droq on which count is checked.
  *  @return Returns packet count.
  */
 u32 octeon_droq_check_hw_for_pkts(struct octeon_droq *droq)
 {
 	u32 pkt_count = 0;
+	u32 last_count;
 
 	pkt_count = readl(droq->pkts_sent_reg);
-	if (pkt_count) {
-		atomic_add(pkt_count, &droq->pkts_pending);
-		writel(pkt_count, droq->pkts_sent_reg);
-	}
 
-	return pkt_count;
+	last_count = pkt_count - droq->pkt_count;
+	droq->pkt_count = pkt_count;
+
+	/* we shall write to cnts  at napi irq enable or end of droq tasklet */
+	if (last_count)
+		atomic_add(last_count, &droq->pkts_pending);
+
+	return last_count;
 }
 
 static void octeon_droq_compute_max_packet_bufs(struct octeon_droq *droq)
@@ -735,16 +738,20 @@ octeon_droq_process_packets(struct octeon_device *oct,
 	u32 pkt_count = 0, pkts_processed = 0;
 	struct list_head *tmp, *tmp2;
 
+	/* Grab the droq lock */
+	spin_lock(&droq->lock);
+
+	octeon_droq_check_hw_for_pkts(droq);
 	pkt_count = atomic_read(&droq->pkts_pending);
-	if (!pkt_count)
+
+	if (!pkt_count) {
+		spin_unlock(&droq->lock);
 		return 0;
+	}
 
 	if (pkt_count > budget)
 		pkt_count = budget;
 
-	/* Grab the droq lock */
-	spin_lock(&droq->lock);
-
 	pkts_processed = octeon_droq_fast_process_packets(oct, droq, pkt_count);
 
 	atomic_sub(pkts_processed, &droq->pkts_pending);
@@ -789,6 +796,8 @@ octeon_droq_process_poll_pkts(struct octeon_device *oct,
 	spin_lock(&droq->lock);
 
 	while (total_pkts_processed < budget) {
+		octeon_droq_check_hw_for_pkts(droq);
+
 		pkts_available =
 			CVM_MIN((budget - total_pkts_processed),
 				(u32)(atomic_read(&droq->pkts_pending)));
@@ -803,8 +812,6 @@ octeon_droq_process_poll_pkts(struct octeon_device *oct,
 		atomic_sub(pkts_processed, &droq->pkts_pending);
 
 		total_pkts_processed += pkts_processed;
-
-		octeon_droq_check_hw_for_pkts(droq);
 	}
 
 	spin_unlock(&droq->lock);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 5a6fb91..5be002d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -261,6 +261,8 @@ struct octeon_droq {
 
 	u32 q_no;
 
+	u32 pkt_count;
+
 	struct octeon_droq_ops ops;
 
 	struct octeon_device *oct_dev;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index ff4b1d6..e4d426b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -88,6 +88,8 @@ struct octeon_instr_queue {
 	/** A spinlock to protect while posting on the ring.  */
 	spinlock_t post_lock;
 
+	u32 pkt_in_done;
+
 	/** A spinlock to protect access to the input ring.*/
 	spinlock_t iq_flush_running_lock;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index d32492f1..3ee5d02 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -499,6 +499,7 @@ static void __check_db_timeout(struct octeon_device *oct, u64 iq_no)
 
 	if (!oct)
 		return;
+
 	iq = oct->instr_queue[iq_no];
 	if (!iq)
 		return;
@@ -514,6 +515,8 @@ static void __check_db_timeout(struct octeon_device *oct, u64 iq_no)
 
 	/* Flush the instruction queue */
 	octeon_flush_iq(oct, iq, 1, 0);
+
+	lio_enable_irq(NULL, iq);
 }
 
 /* Called by the Poll thread at regular intervals to check the instruction
-- 
1.8.3.1
