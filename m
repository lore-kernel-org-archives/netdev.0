From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 1/7] bnxt_en: Add bnxt_set_max_func_irqs().
Date: Wed,  7 Dec 2016 00:26:15 -0500
Message-ID: <1481088381-30411-2-git-send-email-michael.chan@broadcom.com>
References: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, selvin.xavier@broadcom.com,
        somnath.kotur@broadcom.com, dledford@redhat.com,
        linux-rdma@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34342 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752273AbcLGF0y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 00:26:54 -0500
Received: by mail-pf0-f173.google.com with SMTP id c4so75002224pfb.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 21:26:54 -0800 (PST)
In-Reply-To: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By refactoring existing code into this new function.  The new function
will be used in subsequent patches.

v2: Fixed compile warning when CONFIG_BNXT_SRIOV is not set.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 17 +++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e84613a..269e757 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4743,6 +4743,16 @@ static int bnxt_trim_rings(struct bnxt *bp, int *rx, int *tx, int max,
 	return 0;
 }
 
+void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max_irqs)
+{
+#if defined(CONFIG_BNXT_SRIOV)
+	if (BNXT_VF(bp))
+		bp->vf.max_irqs = max_irqs;
+	else
+#endif
+		bp->pf.max_irqs = max_irqs;
+}
+
 static int bnxt_setup_msix(struct bnxt *bp)
 {
 	struct msix_entry *msix_ent;
@@ -6949,12 +6959,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
-	if (BNXT_PF(bp))
-		bp->pf.max_irqs = max_irqs;
-#if defined(CONFIG_BNXT_SRIOV)
-	else
-		bp->vf.max_irqs = max_irqs;
-#endif
+	bnxt_set_max_func_irqs(bp, max_irqs);
 	bnxt_set_dflt_rings(bp);
 
 	/* Default RSS hash cfg. */
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index b4abc1b..8327d0d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1235,6 +1235,7 @@ static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
 int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_set_coal(struct bnxt *);
 int bnxt_hwrm_func_qcaps(struct bnxt *);
+void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max);
 void bnxt_tx_disable(struct bnxt *bp);
 void bnxt_tx_enable(struct bnxt *bp);
 int bnxt_hwrm_set_pause(struct bnxt *);
-- 
1.8.3.1
