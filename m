From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix for iq and droq cnts going negative
Date: Tue, 31 Jan 2017 13:04:42 -0800
Message-ID: <20170131210442.GA5435@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0056.outbound.protection.outlook.com ([104.47.38.56]:60864
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750885AbdAaVFx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 16:05:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satanand Burla <satananda.burla@cavium.com>

Flush the mmio writes before releasing spin locks.
if the maintained counts get too high > 2M force
writeback of the counts to clear them

Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c        | 6 +++++-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c     | 6 +++++-
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h | 1 +
 drivers/net/ethernet/cavium/liquidio/octeon_device.c   | 4 ++++
 4 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index fbe1986..c12cfa4 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2445,7 +2445,11 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 			__func__, iq_no);
 	}
 
-	if ((work_done < budget) && (tx_done)) {
+	/* force enable interrupt if reg cnts are high to avoid wraparound */
+	if ((work_done < budget && tx_done) ||
+	    (iq->pkt_in_done >= MAX_REG_CNT) ||
+	    (droq->pkt_count >= MAX_REG_CNT)) {
+		tx_done = 1;
 		napi_complete_done(napi, work_done);
 		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
 					     POLL_EVENT_ENABLE_INTR, 0);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 78cfa8b..631f1c0f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1630,7 +1630,11 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 			__func__, iq_no);
 	}
 
-	if ((work_done < budget) && (tx_done)) {
+	/* force enable interrupt if reg cnts are high to avoid wraparound */
+	if ((work_done < budget && tx_done) ||
+	    (iq->pkt_in_done >= MAX_REG_CNT) ||
+	    (droq->pkt_count >= MAX_REG_CNT)) {
+		tx_done = 1;
 		napi_complete_done(napi, work_done);
 		octeon_process_droq_poll_cmd(droq->oct_dev, droq->q_no,
 					     POLL_EVENT_ENABLE_INTR, 0);
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index bc0af8a..294c6f3 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -99,6 +99,7 @@ enum octeon_tag_type {
 #define CVM_DRV_APP_END             (CVM_DRV_INVALID_APP - 1)
 
 #define BYTES_PER_DHLEN_UNIT        8
+#define MAX_REG_CNT                 2000000U
 
 static inline u32 incr_index(u32 index, u32 count, u32 max)
 {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index a8df493..9675ffb 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -1361,6 +1361,8 @@ void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq)
 		spin_lock_bh(&droq->lock);
 		writel(droq->pkt_count, droq->pkts_sent_reg);
 		droq->pkt_count = 0;
+		/* this write needs to be flushed before we release the lock */
+		mmiowb();
 		spin_unlock_bh(&droq->lock);
 		oct = droq->oct_dev;
 	}
@@ -1368,6 +1370,8 @@ void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq)
 		spin_lock_bh(&iq->lock);
 		writel(iq->pkt_in_done, iq->inst_cnt_reg);
 		iq->pkt_in_done = 0;
+		/* this write needs to be flushed before we release the lock */
+		mmiowb();
 		spin_unlock_bh(&iq->lock);
 		oct = iq->oct_dev;
 	}
