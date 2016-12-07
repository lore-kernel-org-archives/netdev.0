From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 5/7] bnxt_en: Reserve RDMA resources by default.
Date: Wed,  7 Dec 2016 00:26:19 -0500
Message-ID: <1481088381-30411-6-git-send-email-michael.chan@broadcom.com>
References: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, selvin.xavier@broadcom.com,
        somnath.kotur@broadcom.com, dledford@redhat.com,
        linux-rdma@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36307 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbcLGF07 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 00:26:59 -0500
Received: by mail-pg0-f43.google.com with SMTP id f188so157223394pgc.3
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 21:26:58 -0800 (PST)
In-Reply-To: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the device supports RDMA, we'll setup network default rings so that
there are enough minimum resources for RDMA, if possible.  However, the
user can still increase network rings to the max if he wants.  The actual
RDMA resources won't be reserved until the RDMA driver registers.

v2: Fix compile warning when BNXT_CONFIG_SRIOV is not set.

Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 58 ++++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  9 +++++
 2 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 52b8ad4..57285bd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4166,6 +4166,11 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 	if (rc)
 		goto hwrm_func_qcaps_exit;
 
+	if (resp->flags & cpu_to_le32(FUNC_QCAPS_RESP_FLAGS_ROCE_V1_SUPPORTED))
+		bp->flags |= BNXT_FLAG_ROCEV1_CAP;
+	if (resp->flags & cpu_to_le32(FUNC_QCAPS_RESP_FLAGS_ROCE_V2_SUPPORTED))
+		bp->flags |= BNXT_FLAG_ROCEV2_CAP;
+
 	bp->tx_push_thresh = 0;
 	if (resp->flags &
 	    cpu_to_le32(FUNC_QCAPS_RESP_FLAGS_PUSH_MODE_SUPPORTED))
@@ -4808,6 +4813,24 @@ static int bnxt_setup_int_mode(struct bnxt *bp)
 	return rc;
 }
 
+unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp)
+{
+#if defined(CONFIG_BNXT_SRIOV)
+	if (BNXT_VF(bp))
+		return bp->vf.max_stat_ctxs;
+#endif
+	return bp->pf.max_stat_ctxs;
+}
+
+unsigned int bnxt_get_max_func_cp_rings(struct bnxt *bp)
+{
+#if defined(CONFIG_BNXT_SRIOV)
+	if (BNXT_VF(bp))
+		return bp->vf.max_cp_rings;
+#endif
+	return bp->pf.max_cp_rings;
+}
+
 static unsigned int bnxt_get_max_func_irqs(struct bnxt *bp)
 {
 #if defined(CONFIG_BNXT_SRIOV)
@@ -6832,6 +6855,39 @@ int bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx, bool shared)
 	return bnxt_trim_rings(bp, max_rx, max_tx, cp, shared);
 }
 
+static int bnxt_get_dflt_rings(struct bnxt *bp, int *max_rx, int *max_tx,
+			       bool shared)
+{
+	int rc;
+
+	rc = bnxt_get_max_rings(bp, max_rx, max_tx, shared);
+	if (rc)
+		return rc;
+
+	if (bp->flags & BNXT_FLAG_ROCE_CAP) {
+		int max_cp, max_stat, max_irq;
+
+		/* Reserve minimum resources for RoCE */
+		max_cp = bnxt_get_max_func_cp_rings(bp);
+		max_stat = bnxt_get_max_func_stat_ctxs(bp);
+		max_irq = bnxt_get_max_func_irqs(bp);
+		if (max_cp <= BNXT_MIN_ROCE_CP_RINGS ||
+		    max_irq <= BNXT_MIN_ROCE_CP_RINGS ||
+		    max_stat <= BNXT_MIN_ROCE_STAT_CTXS)
+			return 0;
+
+		max_cp -= BNXT_MIN_ROCE_CP_RINGS;
+		max_irq -= BNXT_MIN_ROCE_CP_RINGS;
+		max_stat -= BNXT_MIN_ROCE_STAT_CTXS;
+		max_cp = min_t(int, max_cp, max_irq);
+		max_cp = min_t(int, max_cp, max_stat);
+		rc = bnxt_trim_rings(bp, max_rx, max_tx, max_cp, shared);
+		if (rc)
+			rc = 0;
+	}
+	return rc;
+}
+
 static int bnxt_set_dflt_rings(struct bnxt *bp)
 {
 	int dflt_rings, max_rx_rings, max_tx_rings, rc;
@@ -6840,7 +6896,7 @@ static int bnxt_set_dflt_rings(struct bnxt *bp)
 	if (sh)
 		bp->flags |= BNXT_FLAG_SHARED_RINGS;
 	dflt_rings = netif_get_num_default_rss_queues();
-	rc = bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, sh);
+	rc = bnxt_get_dflt_rings(bp, &max_rx_rings, &max_tx_rings, sh);
 	if (rc)
 		return rc;
 	bp->rx_nr_rings = min_t(int, dflt_rings, max_rx_rings);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 43a4b17..d796836 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -387,6 +387,9 @@ struct rx_tpa_end_cmp_ext {
 #define DB_KEY_TX_PUSH						(0x4 << 28)
 #define DB_LONG_TX_PUSH						(0x2 << 24)
 
+#define BNXT_MIN_ROCE_CP_RINGS	2
+#define BNXT_MIN_ROCE_STAT_CTXS	1
+
 #define INVALID_HW_RING_ID	((u16)-1)
 
 /* The hardware supports certain page sizes.  Use the supported page sizes
@@ -953,6 +956,10 @@ struct bnxt {
 	#define BNXT_FLAG_PORT_STATS	0x400
 	#define BNXT_FLAG_UDP_RSS_CAP	0x800
 	#define BNXT_FLAG_EEE_CAP	0x1000
+	#define BNXT_FLAG_ROCEV1_CAP	0x8000
+	#define BNXT_FLAG_ROCEV2_CAP	0x10000
+	#define BNXT_FLAG_ROCE_CAP	(BNXT_FLAG_ROCEV1_CAP |	\
+					 BNXT_FLAG_ROCEV2_CAP)
 	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
@@ -1234,6 +1241,8 @@ static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
 int hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_set_coal(struct bnxt *);
+unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp);
+unsigned int bnxt_get_max_func_cp_rings(struct bnxt *bp);
 void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max);
 void bnxt_tx_disable(struct bnxt *bp);
 void bnxt_tx_enable(struct bnxt *bp);
-- 
1.8.3.1
