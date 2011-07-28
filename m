From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 2/2] bna: HW Interface Init Update
Date: Thu, 28 Jul 2011 14:49:27 -0700
Message-ID: <1311889767-9848-2-git-send-email-rmody@brocade.com>
References: <1311889767-9848-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:52700 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754956Ab1G1Vts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 17:49:48 -0400
In-Reply-To: <1311889767-9848-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Split the hw interface into common and asic specific to support new asic
   in the future.
 - Fix bfa_ioc_ct_isr_mode_set() to also include the case that we are already
   in the desired msix mode.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc_ct.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc_ct.c b/drivers/net/bna/bfa_ioc_ct.c
index c43f942..29b5fd0 100644
--- a/drivers/net/bna/bfa_ioc_ct.c
+++ b/drivers/net/bna/bfa_ioc_ct.c
@@ -50,26 +50,32 @@ static enum bfa_status bfa_ioc_ct_pll_init(void __iomem *rb, bool fcmode);
 
 static struct bfa_ioc_hwif nw_hwif_ct;
 
+static void
+bfa_ioc_set_ctx_hwif(struct bfa_ioc *ioc, struct bfa_ioc_hwif *hwif)
+{
+	hwif->ioc_firmware_lock = bfa_ioc_ct_firmware_lock;
+	hwif->ioc_firmware_unlock = bfa_ioc_ct_firmware_unlock;
+	hwif->ioc_notify_fail = bfa_ioc_ct_notify_fail;
+	hwif->ioc_ownership_reset = bfa_ioc_ct_ownership_reset;
+	hwif->ioc_sync_start = bfa_ioc_ct_sync_start;
+	hwif->ioc_sync_join = bfa_ioc_ct_sync_join;
+	hwif->ioc_sync_leave = bfa_ioc_ct_sync_leave;
+	hwif->ioc_sync_ack = bfa_ioc_ct_sync_ack;
+	hwif->ioc_sync_complete = bfa_ioc_ct_sync_complete;
+}
+
 /**
  * Called from bfa_ioc_attach() to map asic specific calls.
  */
 void
 bfa_nw_ioc_set_ct_hwif(struct bfa_ioc *ioc)
 {
+	bfa_ioc_set_ctx_hwif(ioc, &nw_hwif_ct);
+
 	nw_hwif_ct.ioc_pll_init = bfa_ioc_ct_pll_init;
-	nw_hwif_ct.ioc_firmware_lock = bfa_ioc_ct_firmware_lock;
-	nw_hwif_ct.ioc_firmware_unlock = bfa_ioc_ct_firmware_unlock;
 	nw_hwif_ct.ioc_reg_init = bfa_ioc_ct_reg_init;
 	nw_hwif_ct.ioc_map_port = bfa_ioc_ct_map_port;
 	nw_hwif_ct.ioc_isr_mode_set = bfa_ioc_ct_isr_mode_set;
-	nw_hwif_ct.ioc_notify_fail = bfa_ioc_ct_notify_fail;
-	nw_hwif_ct.ioc_ownership_reset = bfa_ioc_ct_ownership_reset;
-	nw_hwif_ct.ioc_sync_start = bfa_ioc_ct_sync_start;
-	nw_hwif_ct.ioc_sync_join = bfa_ioc_ct_sync_join;
-	nw_hwif_ct.ioc_sync_leave = bfa_ioc_ct_sync_leave;
-	nw_hwif_ct.ioc_sync_ack = bfa_ioc_ct_sync_ack;
-	nw_hwif_ct.ioc_sync_complete = bfa_ioc_ct_sync_complete;
-
 	ioc->ioc_hwif = &nw_hwif_ct;
 }
 
@@ -297,7 +303,7 @@ bfa_ioc_ct_isr_mode_set(struct bfa_ioc *ioc, bool msix)
 	/**
 	 * If already in desired mode, do not change anything
 	 */
-	if (!msix && mode)
+	if ((!msix && mode) || (msix && !mode))
 		return;
 
 	if (msix)
-- 
1.7.1

