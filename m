From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  03/11] ixgbe: fix qv_lock_napi call in ixgbe_napi_disable_all
Date: Tue, 29 Oct 2013 05:02:23 -0700
Message-ID: <1383048151-15002-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Alexander Duyck <alexander.duyck@intel.com>,
	Hyong-Youb Kim <hykim@myri.com>,
	Amir Vadai <amirv@mellanox.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25560 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547Ab3J2MCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:38 -0400
In-Reply-To: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

ixgbe_napi_disable_all calls napi_disable on each queue, however the busy
polling code introduced a local_bh_disable()d context around the napi_disable.
The original author did not realize that napi_disable might sleep, which would
cause a sleep while atomic BUG. In addition, on a single processor system, the
ixgbe_qv_lock_napi loop shouldn't have to mdelay. This patch adds an
ixgbe_qv_disable along with a new IXGBE_QV_STATE_DISABLED bit, which it uses to
indicate to the poll and napi routines that the q_vector has been disabled. Now
the ixgbe_napi_disable_all function will wait until all pending work has been
finished and prevent any future work from being started.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@intel.com>
Cc: Hyong-Youb Kim <hykim@myri.com>
Cc: Amir Vadai <amirv@mellanox.com>
Cc: Dmitry Kravkov <dmitry@broadcom.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 48 ++++++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  6 ++--
 2 files changed, 38 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index dc1588e..f51fd1f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -369,11 +369,13 @@ struct ixgbe_q_vector {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int state;
 #define IXGBE_QV_STATE_IDLE        0
-#define IXGBE_QV_STATE_NAPI	   1    /* NAPI owns this QV */
-#define IXGBE_QV_STATE_POLL	   2    /* poll owns this QV */
-#define IXGBE_QV_LOCKED (IXGBE_QV_STATE_NAPI | IXGBE_QV_STATE_POLL)
-#define IXGBE_QV_STATE_NAPI_YIELD  4    /* NAPI yielded this QV */
-#define IXGBE_QV_STATE_POLL_YIELD  8    /* poll yielded this QV */
+#define IXGBE_QV_STATE_NAPI	   1     /* NAPI owns this QV */
+#define IXGBE_QV_STATE_POLL	   2     /* poll owns this QV */
+#define IXGBE_QV_STATE_DISABLED	   4     /* QV is disabled */
+#define IXGBE_QV_OWNED (IXGBE_QV_STATE_NAPI | IXGBE_QV_STATE_POLL)
+#define IXGBE_QV_LOCKED (IXGBE_QV_OWNED | IXGBE_QV_STATE_DISABLED)
+#define IXGBE_QV_STATE_NAPI_YIELD  8     /* NAPI yielded this QV */
+#define IXGBE_QV_STATE_POLL_YIELD  16    /* poll yielded this QV */
 #define IXGBE_QV_YIELD (IXGBE_QV_STATE_NAPI_YIELD | IXGBE_QV_STATE_POLL_YIELD)
 #define IXGBE_QV_USER_PEND (IXGBE_QV_STATE_POLL | IXGBE_QV_STATE_POLL_YIELD)
 	spinlock_t lock;
@@ -394,7 +396,7 @@ static inline void ixgbe_qv_init_lock(struct ixgbe_q_vector *q_vector)
 static inline bool ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
 {
 	int rc = true;
-	spin_lock(&q_vector->lock);
+	spin_lock_bh(&q_vector->lock);
 	if (q_vector->state & IXGBE_QV_LOCKED) {
 		WARN_ON(q_vector->state & IXGBE_QV_STATE_NAPI);
 		q_vector->state |= IXGBE_QV_STATE_NAPI_YIELD;
@@ -405,7 +407,7 @@ static inline bool ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
 	} else
 		/* we don't care if someone yielded */
 		q_vector->state = IXGBE_QV_STATE_NAPI;
-	spin_unlock(&q_vector->lock);
+	spin_unlock_bh(&q_vector->lock);
 	return rc;
 }
 
@@ -413,14 +415,15 @@ static inline bool ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
 static inline bool ixgbe_qv_unlock_napi(struct ixgbe_q_vector *q_vector)
 {
 	int rc = false;
-	spin_lock(&q_vector->lock);
+	spin_lock_bh(&q_vector->lock);
 	WARN_ON(q_vector->state & (IXGBE_QV_STATE_POLL |
 			       IXGBE_QV_STATE_NAPI_YIELD));
 
 	if (q_vector->state & IXGBE_QV_STATE_POLL_YIELD)
 		rc = true;
-	q_vector->state = IXGBE_QV_STATE_IDLE;
-	spin_unlock(&q_vector->lock);
+	/* will reset state to idle, unless QV is disabled */
+	q_vector->state &= IXGBE_QV_STATE_DISABLED;
+	spin_unlock_bh(&q_vector->lock);
 	return rc;
 }
 
@@ -451,7 +454,8 @@ static inline bool ixgbe_qv_unlock_poll(struct ixgbe_q_vector *q_vector)
 
 	if (q_vector->state & IXGBE_QV_STATE_POLL_YIELD)
 		rc = true;
-	q_vector->state = IXGBE_QV_STATE_IDLE;
+	/* will reset state to idle, unless QV is disabled */
+	q_vector->state &= IXGBE_QV_STATE_DISABLED;
 	spin_unlock_bh(&q_vector->lock);
 	return rc;
 }
@@ -459,9 +463,23 @@ static inline bool ixgbe_qv_unlock_poll(struct ixgbe_q_vector *q_vector)
 /* true if a socket is polling, even if it did not get the lock */
 static inline bool ixgbe_qv_busy_polling(struct ixgbe_q_vector *q_vector)
 {
-	WARN_ON(!(q_vector->state & IXGBE_QV_LOCKED));
+	WARN_ON(!(q_vector->state & IXGBE_QV_OWNED));
 	return q_vector->state & IXGBE_QV_USER_PEND;
 }
+
+/* false if QV is currently owned */
+static inline bool ixgbe_qv_disable(struct ixgbe_q_vector *q_vector)
+{
+	int rc = true;
+	spin_lock_bh(&q_vector->lock);
+	if (q_vector->state & IXGBE_QV_OWNED)
+		rc = false;
+	q_vector->state |= IXGBE_QV_STATE_DISABLED;
+	spin_unlock_bh(&q_vector->lock);
+
+	return rc;
+}
+
 #else /* CONFIG_NET_RX_BUSY_POLL */
 static inline void ixgbe_qv_init_lock(struct ixgbe_q_vector *q_vector)
 {
@@ -491,6 +509,12 @@ static inline bool ixgbe_qv_busy_polling(struct ixgbe_q_vector *q_vector)
 {
 	return false;
 }
+
+static inline bool ixgbe_qv_disable(struct ixgbe_q_vector *q_vector)
+{
+	return true;
+}
+
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
 #ifdef CONFIG_IXGBE_HWMON
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ce3eb60..ee90dfb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3891,15 +3891,13 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx;
 
-	local_bh_disable(); /* for ixgbe_qv_lock_napi() */
 	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++) {
 		napi_disable(&adapter->q_vector[q_idx]->napi);
-		while (!ixgbe_qv_lock_napi(adapter->q_vector[q_idx])) {
+		while (!ixgbe_qv_disable(adapter->q_vector[q_idx])) {
 			pr_info("QV %d locked\n", q_idx);
-			mdelay(1);
+			usleep_range(1000, 20000);
 		}
 	}
-	local_bh_enable();
 }
 
 #ifdef CONFIG_IXGBE_DCB
-- 
1.8.3.1
