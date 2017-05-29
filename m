From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/7] bnxt_en: Add a callback to inform RDMA driver during PCI shutdown.
Date: Mon, 29 May 2017 19:06:06 -0400
Message-ID: <1496099170-701-4-git-send-email-michael.chan@broadcom.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33719 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdE2XGn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 19:06:43 -0400
Received: by mail-qk0-f175.google.com with SMTP id y201so56898140qka.0
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 16:06:42 -0700 (PDT)
In-Reply-To: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bnxt_en gets a PCI shutdown call, we need to have a new callback
to inform the RDMA driver to do proper shutdown and removal.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c | 19 +++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h |  2 ++
 3 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index dc10a9a..63d23b6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7837,6 +7837,7 @@ static void bnxt_shutdown(struct pci_dev *pdev)
 		dev_close(dev);
 
 	if (system_state == SYSTEM_POWER_OFF) {
+		bnxt_ulp_shutdown(bp);
 		bnxt_clear_int_mode(bp);
 		pci_wake_from_d3(pdev, bp->wol);
 		pci_set_power_state(pdev, PCI_D3hot);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
index 8b7464b..77da75a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
@@ -266,6 +266,25 @@ void bnxt_ulp_sriov_cfg(struct bnxt *bp, int num_vfs)
 	}
 }
 
+void bnxt_ulp_shutdown(struct bnxt *bp)
+{
+	struct bnxt_en_dev *edev = bp->edev;
+	struct bnxt_ulp_ops *ops;
+	int i;
+
+	if (!edev)
+		return;
+
+	for (i = 0; i < BNXT_MAX_ULP; i++) {
+		struct bnxt_ulp *ulp = &edev->ulp_tbl[i];
+
+		ops = rtnl_dereference(ulp->ulp_ops);
+		if (!ops || !ops->ulp_shutdown)
+			continue;
+		ops->ulp_shutdown(ulp->handle);
+	}
+}
+
 void bnxt_ulp_async_events(struct bnxt *bp, struct hwrm_async_event_cmpl *cmpl)
 {
 	u16 event_id = le16_to_cpu(cmpl->event_id);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h
index 74f816e..d247106 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h
@@ -26,6 +26,7 @@ struct bnxt_ulp_ops {
 	void (*ulp_stop)(void *);
 	void (*ulp_start)(void *);
 	void (*ulp_sriov_config)(void *, int);
+	void (*ulp_shutdown)(void *);
 };
 
 struct bnxt_msix_entry {
@@ -87,6 +88,7 @@ static inline bool bnxt_ulp_registered(struct bnxt_en_dev *edev, int ulp_id)
 void bnxt_ulp_stop(struct bnxt *bp);
 void bnxt_ulp_start(struct bnxt *bp);
 void bnxt_ulp_sriov_cfg(struct bnxt *bp, int num_vfs);
+void bnxt_ulp_shutdown(struct bnxt *bp);
 void bnxt_ulp_async_events(struct bnxt *bp, struct hwrm_async_event_cmpl *cmpl);
 struct bnxt_en_dev *bnxt_ulp_probe(struct net_device *dev);
 
-- 
1.8.3.1
