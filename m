From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 1/2] bnx2x: add support for ndo_ll_poll
Date: Wed, 19 Jun 2013 01:36:04 +0300
Message-ID: <1371594965-12546-2-git-send-email-dmitry@broadcom.com>
References: <1371594965-12546-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2054 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932479Ab3FRWgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 18:36:21 -0400
In-Reply-To: <1371594965-12546-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds ndo_ll_poll method and locking for FPs between LL and the napi.

When receiving a packet we use skb_mark_ll to record the napi it came from.
Add each napi to the napi_hash right after netif_napi_add().

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 125 +++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  67 ++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |  23 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   4 +
 4 files changed, 208 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index f76597e..edda716 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -485,6 +485,21 @@ struct bnx2x_fastpath {
 	struct bnx2x		*bp; /* parent */
 
 	struct napi_struct	napi;
+
+#ifdef CONFIG_NET_LL_RX_POLL
+	unsigned int state;
+#define BNX2X_FP_STATE_IDLE		      0
+#define BNX2X_FP_STATE_NAPI		(1 << 0)    /* NAPI owns this FP */
+#define BNX2X_FP_STATE_POLL		(1 << 1)    /* poll owns this FP */
+#define BNX2X_FP_STATE_NAPI_YIELD	(1 << 2)    /* NAPI yielded this FP */
+#define BNX2X_FP_STATE_POLL_YIELD	(1 << 3)    /* poll yielded this FP */
+#define BNX2X_FP_YIELD	(BNX2X_FP_STATE_NAPI_YIELD | BNX2X_FP_STATE_POLL_YIELD)
+#define BNX2X_FP_LOCKED	(BNX2X_FP_STATE_NAPI | BNX2X_FP_STATE_POLL)
+#define BNX2X_FP_USER_PEND (BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_POLL_YIELD)
+	/* protect state */
+	spinlock_t lock;
+#endif /* CONFIG_NET_LL_RX_POLL */
+
 	union host_hc_status_block	status_blk;
 	/* chip independent shortcuts into sb structure */
 	__le16			*sb_index_values;
@@ -557,6 +572,116 @@ struct bnx2x_fastpath {
 #define bnx2x_fp_stats(bp, fp)	(&((bp)->fp_stats[(fp)->index]))
 #define bnx2x_fp_qstats(bp, fp)	(&((bp)->fp_stats[(fp)->index].eth_q_stats))
 
+#ifdef CONFIG_NET_LL_RX_POLL
+static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
+{
+	spin_lock_init(&fp->lock);
+	fp->state = BNX2X_FP_STATE_IDLE;
+}
+
+/* called from the device poll routine to get ownership of a FP */
+static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
+{
+	bool rc = true;
+
+	spin_lock(&fp->lock);
+	if (fp->state & BNX2X_FP_LOCKED) {
+		WARN_ON(fp->state & BNX2X_FP_STATE_NAPI);
+		fp->state |= BNX2X_FP_STATE_NAPI_YIELD;
+		rc = false;
+	} else {
+		/* we don't care if someone yielded */
+		fp->state = BNX2X_FP_STATE_NAPI;
+	}
+	spin_unlock(&fp->lock);
+	return rc;
+}
+
+/* returns true is someone tried to get the FP while napi had it */
+static inline bool bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
+{
+	bool rc = false;
+
+	spin_lock(&fp->lock);
+	WARN_ON(fp->state &
+		(BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_NAPI_YIELD));
+
+	if (fp->state & BNX2X_FP_STATE_POLL_YIELD)
+		rc = true;
+	fp->state = BNX2X_FP_STATE_IDLE;
+	spin_unlock(&fp->lock);
+	return rc;
+}
+
+/* called from bnx2x_low_latency_poll() */
+static inline bool bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)
+{
+	bool rc = true;
+
+	spin_lock_bh(&fp->lock);
+	if ((fp->state & BNX2X_FP_LOCKED)) {
+		fp->state |= BNX2X_FP_STATE_POLL_YIELD;
+		rc = false;
+	} else {
+		/* preserve yield marks */
+		fp->state |= BNX2X_FP_STATE_POLL;
+	}
+	spin_unlock_bh(&fp->lock);
+	return rc;
+}
+
+/* returns true if someone tried to get the FP while it was locked */
+static inline bool bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
+{
+	bool rc = false;
+
+	spin_lock_bh(&fp->lock);
+	WARN_ON(fp->state & BNX2X_FP_STATE_NAPI);
+
+	if (fp->state & BNX2X_FP_STATE_POLL_YIELD)
+		rc = true;
+	fp->state = BNX2X_FP_STATE_IDLE;
+	spin_unlock_bh(&fp->lock);
+	return rc;
+}
+
+/* true if a socket is polling, even if it did not get the lock */
+static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
+{
+	WARN_ON(!(fp->state & BNX2X_FP_LOCKED));
+	return fp->state & BNX2X_FP_USER_PEND;
+}
+#else
+static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
+{
+}
+
+static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
+{
+	return true;
+}
+
+static inline bool bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
+{
+	return false;
+}
+
+static inline bool bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)
+{
+	return false;
+}
+
+static inline bool bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
+{
+	return false;
+}
+
+static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
+{
+	return false;
+}
+#endif /* CONFIG_NET_LL_RX_POLL */
+
 /* Use 2500 as a mini-jumbo MTU for FCoE */
 #define BNX2X_FCOE_MINI_JUMBO_MTU	2500
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4e42bdd..20eefa6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -24,6 +24,7 @@
 #include <net/tcp.h>
 #include <net/ipv6.h>
 #include <net/ip6_checksum.h>
+#include <net/ll_poll.h>
 #include <linux/prefetch.h>
 #include "bnx2x_cmn.h"
 #include "bnx2x_init.h"
@@ -999,8 +1000,13 @@ reuse_rx:
 		    PARSING_FLAGS_VLAN)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       le16_to_cpu(cqe_fp->vlan_tag));
-		napi_gro_receive(&fp->napi, skb);
 
+		skb_mark_ll(skb, &fp->napi);
+
+		if (bnx2x_fp_ll_polling(fp))
+			netif_receive_skb(skb);
+		else
+			napi_gro_receive(&fp->napi, skb);
 next_rx:
 		rx_buf->data = NULL;
 
@@ -1755,32 +1761,46 @@ static void bnx2x_napi_enable_cnic(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_rx_queue_cnic(bp, i)
+	for_each_rx_queue_cnic(bp, i) {
+		bnx2x_fp_init_lock(&bp->fp[i]);
 		napi_enable(&bnx2x_fp(bp, i, napi));
+	}
 }
 
 static void bnx2x_napi_enable(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_eth_queue(bp, i)
+	for_each_eth_queue(bp, i) {
+		bnx2x_fp_init_lock(&bp->fp[i]);
 		napi_enable(&bnx2x_fp(bp, i, napi));
+	}
 }
 
 static void bnx2x_napi_disable_cnic(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_rx_queue_cnic(bp, i)
+	local_bh_disable();
+	for_each_rx_queue_cnic(bp, i) {
 		napi_disable(&bnx2x_fp(bp, i, napi));
+		while (!bnx2x_fp_lock_napi(&bp->fp[i]))
+			mdelay(1);
+	}
+	local_bh_enable();
 }
 
 static void bnx2x_napi_disable(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_eth_queue(bp, i)
+	local_bh_disable();
+	for_each_eth_queue(bp, i) {
 		napi_disable(&bnx2x_fp(bp, i, napi));
+		while (!bnx2x_fp_lock_napi(&bp->fp[i]))
+			mdelay(1);
+	}
+	local_bh_enable();
 }
 
 void bnx2x_netif_start(struct bnx2x *bp)
@@ -3039,6 +3059,8 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 			return 0;
 		}
 #endif
+		if (!bnx2x_fp_lock_napi(fp))
+			return work_done;
 
 		for_each_cos_in_tx_queue(fp, cos)
 			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
@@ -3048,12 +3070,15 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 			work_done += bnx2x_rx_int(fp, budget - work_done);
 
 			/* must not complete if we consumed full budget */
-			if (work_done >= budget)
+			if (work_done >= budget) {
+				bnx2x_fp_unlock_napi(fp);
 				break;
+			}
 		}
 
 		/* Fall out from the NAPI loop if needed */
-		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+		if (!bnx2x_fp_unlock_napi(fp) &&
+		    !(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 
 			/* No need to update SB for FCoE L2 ring as long as
 			 * it's connected to the default SB and the SB
@@ -3095,6 +3120,34 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+#ifdef CONFIG_NET_LL_RX_POLL
+/* must be called with local_bh_disable()d */
+int bnx2x_low_latency_recv(struct napi_struct *napi)
+{
+	struct bnx2x_fastpath *fp = container_of(napi, struct bnx2x_fastpath,
+						 napi);
+	struct bnx2x *bp = fp->bp;
+	int found = 0;
+
+	if ((bp->state == BNX2X_STATE_CLOSED) ||
+	    (bp->state == BNX2X_STATE_ERROR) ||
+	    (bp->flags & (TPA_ENABLE_FLAG | GRO_ENABLE_FLAG)))
+		return LL_FLUSH_FAILED;
+
+	if (!bnx2x_fp_lock_poll(fp))
+		return LL_FLUSH_BUSY;
+
+	if (bnx2x_has_rx_work(fp)) {
+		bnx2x_update_fpsb_idx(fp);
+		found = bnx2x_rx_int(fp, 4);
+	}
+
+	bnx2x_fp_unlock_poll(fp);
+
+	return found;
+}
+#endif
+
 /* we split the first BD into headers and data BDs
  * to ease the pain of our fellow microcode engineers
  * we use one mapping for both BDs
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 650bb52..a1a5cdc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -605,6 +605,13 @@ int bnx2x_enable_msi(struct bnx2x *bp);
 int bnx2x_poll(struct napi_struct *napi, int budget);
 
 /**
+ * bnx2x_low_latency_recv - LL callback
+ *
+ * @napi:	napi structure
+ */
+int bnx2x_low_latency_recv(struct napi_struct *napi);
+
+/**
  * bnx2x_alloc_mem_bp - allocate memories outsize main driver structure
  *
  * @bp:		driver handle
@@ -846,9 +853,11 @@ static inline void bnx2x_add_all_napi_cnic(struct bnx2x *bp)
 	int i;
 
 	/* Add NAPI objects */
-	for_each_rx_queue_cnic(bp, i)
+	for_each_rx_queue_cnic(bp, i) {
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, NAPI_POLL_WEIGHT);
+		napi_hash_add(&bnx2x_fp(bp, i, napi));
+	}
 }
 
 static inline void bnx2x_add_all_napi(struct bnx2x *bp)
@@ -856,25 +865,31 @@ static inline void bnx2x_add_all_napi(struct bnx2x *bp)
 	int i;
 
 	/* Add NAPI objects */
-	for_each_eth_queue(bp, i)
+	for_each_eth_queue(bp, i) {
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, NAPI_POLL_WEIGHT);
+		napi_hash_add(&bnx2x_fp(bp, i, napi));
+	}
 }
 
 static inline void bnx2x_del_all_napi_cnic(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_rx_queue_cnic(bp, i)
+	for_each_rx_queue_cnic(bp, i) {
+		napi_hash_del(&bnx2x_fp(bp, i, napi));
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
+	}
 }
 
 static inline void bnx2x_del_all_napi(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_eth_queue(bp, i)
+	for_each_eth_queue(bp, i) {
+		napi_hash_del(&bnx2x_fp(bp, i, napi));
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
+	}
 }
 
 int bnx2x_set_int_mode(struct bnx2x *bp);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 658b9fd..e2e8705 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12013,6 +12013,10 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 #ifdef NETDEV_FCOE_WWNN
 	.ndo_fcoe_get_wwn	= bnx2x_fcoe_get_wwn,
 #endif
+
+#ifdef CONFIG_NET_LL_RX_POLL
+	.ndo_ll_poll		= bnx2x_low_latency_recv,
+#endif
 };
 
 static int bnx2x_set_coherency_mask(struct bnx2x *bp)
-- 
1.8.1.4
