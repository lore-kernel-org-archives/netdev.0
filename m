From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Fix netpoll interoperability
Date: Tue, 14 Apr 2015 16:35:13 +0300
Message-ID: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bind@enas.net>, <peter@hurleysoftware.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:35365 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932520AbbDNNfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 09:35:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9a2620c877454 ("bnx2x: prevent WARN during driver unload") switched
the napi/busy_lock locking mechanism from spin_lock() into spin_lock_bh(),
breaking inter-operability with netconsole, as netpoll disables interrupts
prior to calling our napi mechanism.

This switches the driver into using atomic assignments instead of the spinlock
mechanisms previously employed.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 116 +++++++-----------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   5 +-
 2 files changed, 34 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 4085c4b..d8b87a7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -525,26 +525,23 @@ enum bnx2x_tpa_mode_t {
 	TPA_MODE_GRO
 };
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+enum bnx2x_fp_state {
+	BNX2X_STATE_FP_IDLE,
+	BNX2X_STATE_FP_NAPI,
+	BNX2X_STATE_FP_POLL,
+	BNX2X_STATE_FP_DISABLE,
+};
+#endif
+
 struct bnx2x_fastpath {
 	struct bnx2x		*bp; /* parent */
 
 	struct napi_struct	napi;
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
-	unsigned int state;
-#define BNX2X_FP_STATE_IDLE		      0
-#define BNX2X_FP_STATE_NAPI		(1 << 0)    /* NAPI owns this FP */
-#define BNX2X_FP_STATE_POLL		(1 << 1)    /* poll owns this FP */
-#define BNX2X_FP_STATE_DISABLED		(1 << 2)
-#define BNX2X_FP_STATE_NAPI_YIELD	(1 << 3)    /* NAPI yielded this FP */
-#define BNX2X_FP_STATE_POLL_YIELD	(1 << 4)    /* poll yielded this FP */
-#define BNX2X_FP_OWNED	(BNX2X_FP_STATE_NAPI | BNX2X_FP_STATE_POLL)
-#define BNX2X_FP_YIELD	(BNX2X_FP_STATE_NAPI_YIELD | BNX2X_FP_STATE_POLL_YIELD)
-#define BNX2X_FP_LOCKED	(BNX2X_FP_OWNED | BNX2X_FP_STATE_DISABLED)
-#define BNX2X_FP_USER_PEND (BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_POLL_YIELD)
-	/* protect state */
-	spinlock_t lock;
-#endif /* CONFIG_NET_RX_BUSY_POLL */
+	atomic_t state;
+#endif
 
 	union host_hc_status_block	status_blk;
 	/* chip independent shortcuts into sb structure */
@@ -621,99 +618,50 @@ struct bnx2x_fastpath {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
 {
-	spin_lock_init(&fp->lock);
-	fp->state = BNX2X_FP_STATE_IDLE;
+	atomic_set(&fp->state, BNX2X_STATE_FP_IDLE);
 }
 
 /* called from the device poll routine to get ownership of a FP */
 static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
 {
-	bool rc = true;
-
-	spin_lock_bh(&fp->lock);
-	if (fp->state & BNX2X_FP_LOCKED) {
-		WARN_ON(fp->state & BNX2X_FP_STATE_NAPI);
-		fp->state |= BNX2X_FP_STATE_NAPI_YIELD;
-		rc = false;
-	} else {
-		/* we don't care if someone yielded */
-		fp->state = BNX2X_FP_STATE_NAPI;
-	}
-	spin_unlock_bh(&fp->lock);
-	return rc;
+	int rc = atomic_cmpxchg(&fp->state, BNX2X_STATE_FP_IDLE,
+				BNX2X_STATE_FP_NAPI);
+	return rc == BNX2X_STATE_FP_IDLE;
 }
 
-/* returns true is someone tried to get the FP while napi had it */
-static inline bool bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
+static inline void bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
 {
-	bool rc = false;
-
-	spin_lock_bh(&fp->lock);
-	WARN_ON(fp->state &
-		(BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_NAPI_YIELD));
-
-	if (fp->state & BNX2X_FP_STATE_POLL_YIELD)
-		rc = true;
-
-	/* state ==> idle, unless currently disabled */
-	fp->state &= BNX2X_FP_STATE_DISABLED;
-	spin_unlock_bh(&fp->lock);
-	return rc;
+	WARN_ON(atomic_read(&fp->state) != BNX2X_STATE_FP_NAPI);
+	atomic_set(&fp->state, BNX2X_STATE_FP_IDLE);
 }
 
 /* called from bnx2x_low_latency_poll() */
 static inline bool bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)
 {
-	bool rc = true;
-
-	spin_lock_bh(&fp->lock);
-	if ((fp->state & BNX2X_FP_LOCKED)) {
-		fp->state |= BNX2X_FP_STATE_POLL_YIELD;
-		rc = false;
-	} else {
-		/* preserve yield marks */
-		fp->state |= BNX2X_FP_STATE_POLL;
-	}
-	spin_unlock_bh(&fp->lock);
-	return rc;
+	int rc = atomic_cmpxchg(&fp->state, BNX2X_STATE_FP_IDLE,
+				BNX2X_STATE_FP_POLL);
+	return rc == BNX2X_STATE_FP_IDLE;
 }
 
-/* returns true if someone tried to get the FP while it was locked */
-static inline bool bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
+static inline void bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
 {
-	bool rc = false;
-
-	spin_lock_bh(&fp->lock);
-	WARN_ON(fp->state & BNX2X_FP_STATE_NAPI);
-
-	if (fp->state & BNX2X_FP_STATE_POLL_YIELD)
-		rc = true;
-
-	/* state ==> idle, unless currently disabled */
-	fp->state &= BNX2X_FP_STATE_DISABLED;
-	spin_unlock_bh(&fp->lock);
-	return rc;
+	WARN_ON(atomic_read(&fp->state) != BNX2X_STATE_FP_POLL);
+	atomic_set(&fp->state, BNX2X_STATE_FP_IDLE);
 }
 
-/* true if a socket is polling, even if it did not get the lock */
+/* true if a socket is polling */
 static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
 {
-	WARN_ON(!(fp->state & BNX2X_FP_OWNED));
-	return fp->state & BNX2X_FP_USER_PEND;
+	return atomic_read(&fp->state) == BNX2X_STATE_FP_POLL;
 }
 
 /* false if fp is currently owned */
 static inline bool bnx2x_fp_ll_disable(struct bnx2x_fastpath *fp)
 {
-	int rc = true;
+	int rc = atomic_cmpxchg(&fp->state, BNX2X_STATE_FP_IDLE,
+				BNX2X_STATE_FP_DISABLE);
+	return rc == BNX2X_STATE_FP_IDLE;
 
-	spin_lock_bh(&fp->lock);
-	if (fp->state & BNX2X_FP_OWNED)
-		rc = false;
-	fp->state |= BNX2X_FP_STATE_DISABLED;
-	spin_unlock_bh(&fp->lock);
-
-	return rc;
 }
 #else
 static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
@@ -725,9 +673,8 @@ static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
 	return true;
 }
 
-static inline bool bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
+static inline void bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
 {
-	return false;
 }
 
 static inline bool bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)
@@ -735,9 +682,8 @@ static inline bool bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)
 	return false;
 }
 
-static inline bool bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
+static inline void bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
 {
-	return false;
 }
 
 static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 0a9faa1..f7c0375 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3191,9 +3191,10 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 			}
 		}
 
+		bnx2x_fp_unlock_napi(fp);
+
 		/* Fall out from the NAPI loop if needed */
-		if (!bnx2x_fp_unlock_napi(fp) &&
-		    !(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 
 			/* No need to update SB for FCoE L2 ring as long as
 			 * it's connected to the default SB and the SB
-- 
1.9.3
