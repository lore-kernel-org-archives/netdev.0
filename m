From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: prevent WARN during driver unload
Date: Tue, 7 Jan 2014 12:07:41 +0200
Message-ID: <1389089261-25714-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:61722 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbaAGKIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 05:08:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Starting with commit 80c33dd "net: add might_sleep() call to napi_disable"
bnx2x fails the might_sleep tests causing a stack trace to appear whenever
the driver is unloaded, as local_bh_disable() is being called before 
napi_disable().

This changes the locking schematics related to CONFIG_NET_RX_BUSY_POLL,
preventing the need for calling local_bh_disable() and thus eliminating
the issue.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Hi Dave,

Please apply this to `net'.

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 44 +++++++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 12 +++----
 2 files changed, 38 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a1f66e2..46eeace 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -520,10 +520,12 @@ struct bnx2x_fastpath {
 #define BNX2X_FP_STATE_IDLE		      0
 #define BNX2X_FP_STATE_NAPI		(1 << 0)    /* NAPI owns this FP */
 #define BNX2X_FP_STATE_POLL		(1 << 1)    /* poll owns this FP */
-#define BNX2X_FP_STATE_NAPI_YIELD	(1 << 2)    /* NAPI yielded this FP */
-#define BNX2X_FP_STATE_POLL_YIELD	(1 << 3)    /* poll yielded this FP */
+#define BNX2X_FP_STATE_DISABLED		(1 << 2)
+#define BNX2X_FP_STATE_NAPI_YIELD	(1 << 3)    /* NAPI yielded this FP */
+#define BNX2X_FP_STATE_POLL_YIELD	(1 << 4)    /* poll yielded this FP */
+#define BNX2X_FP_OWNED	(BNX2X_FP_STATE_NAPI | BNX2X_FP_STATE_POLL)
 #define BNX2X_FP_YIELD	(BNX2X_FP_STATE_NAPI_YIELD | BNX2X_FP_STATE_POLL_YIELD)
-#define BNX2X_FP_LOCKED	(BNX2X_FP_STATE_NAPI | BNX2X_FP_STATE_POLL)
+#define BNX2X_FP_LOCKED	(BNX2X_FP_OWNED | BNX2X_FP_STATE_DISABLED)
 #define BNX2X_FP_USER_PEND (BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_POLL_YIELD)
 	/* protect state */
 	spinlock_t lock;
@@ -613,7 +615,7 @@ static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
 {
 	bool rc = true;
 
-	spin_lock(&fp->lock);
+	spin_lock_bh(&fp->lock);
 	if (fp->state & BNX2X_FP_LOCKED) {
 		WARN_ON(fp->state & BNX2X_FP_STATE_NAPI);
 		fp->state |= BNX2X_FP_STATE_NAPI_YIELD;
@@ -622,7 +624,7 @@ static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
 		/* we don't care if someone yielded */
 		fp->state = BNX2X_FP_STATE_NAPI;
 	}
-	spin_unlock(&fp->lock);
+	spin_unlock_bh(&fp->lock);
 	return rc;
 }
 
@@ -631,14 +633,16 @@ static inline bool bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
 {
 	bool rc = false;
 
-	spin_lock(&fp->lock);
+	spin_lock_bh(&fp->lock);
 	WARN_ON(fp->state &
 		(BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_NAPI_YIELD));
 
 	if (fp->state & BNX2X_FP_STATE_POLL_YIELD)
 		rc = true;
-	fp->state = BNX2X_FP_STATE_IDLE;
-	spin_unlock(&fp->lock);
+
+	/* state ==> idle, unless currently disabled */
+	fp->state &= BNX2X_FP_STATE_DISABLED;
+	spin_unlock_bh(&fp->lock);
 	return rc;
 }
 
@@ -669,7 +673,9 @@ static inline bool bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
 
 	if (fp->state & BNX2X_FP_STATE_POLL_YIELD)
 		rc = true;
-	fp->state = BNX2X_FP_STATE_IDLE;
+
+	/* state ==> idle, unless currently disabled */
+	fp->state &= BNX2X_FP_STATE_DISABLED;
 	spin_unlock_bh(&fp->lock);
 	return rc;
 }
@@ -677,9 +683,23 @@ static inline bool bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
 /* true if a socket is polling, even if it did not get the lock */
 static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
 {
-	WARN_ON(!(fp->state & BNX2X_FP_LOCKED));
+	WARN_ON(!(fp->state & BNX2X_FP_OWNED));
 	return fp->state & BNX2X_FP_USER_PEND;
 }
+
+/* false if fp is currently owned */
+static inline bool bnx2x_fp_ll_disable(struct bnx2x_fastpath *fp)
+{
+	int rc = true;
+
+	spin_lock_bh(&fp->lock);
+	if (fp->state & BNX2X_FP_OWNED)
+		rc = false;
+	fp->state |= BNX2X_FP_STATE_DISABLED;
+	spin_unlock_bh(&fp->lock);
+
+	return rc;
+}
 #else
 static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
 {
@@ -709,6 +729,10 @@ static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
 {
 	return false;
 }
+static inline bool bnx2x_fp_ll_disable(struct bnx2x_fastpath *fp)
+{
+	return true;
+}
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
 /* Use 2500 as a mini-jumbo MTU for FCoE */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ec96130..c6745d7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1790,26 +1790,22 @@ static void bnx2x_napi_disable_cnic(struct bnx2x *bp)
 {
 	int i;
 
-	local_bh_disable();
 	for_each_rx_queue_cnic(bp, i) {
 		napi_disable(&bnx2x_fp(bp, i, napi));
-		while (!bnx2x_fp_lock_napi(&bp->fp[i]))
-			mdelay(1);
+		while (!bnx2x_fp_ll_disable(&bp->fp[i]))
+			usleep_range(1000, 2000);
 	}
-	local_bh_enable();
 }
 
 static void bnx2x_napi_disable(struct bnx2x *bp)
 {
 	int i;
 
-	local_bh_disable();
 	for_each_eth_queue(bp, i) {
 		napi_disable(&bnx2x_fp(bp, i, napi));
-		while (!bnx2x_fp_lock_napi(&bp->fp[i]))
-			mdelay(1);
+		while (!bnx2x_fp_ll_disable(&bp->fp[i]))
+			usleep_range(1000, 2000);
 	}
-	local_bh_enable();
 }
 
 void bnx2x_netif_start(struct bnx2x *bp)
-- 
1.8.1.227.g44fe835
