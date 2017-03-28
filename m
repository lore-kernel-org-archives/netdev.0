From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/3] bnxt_en: Fix NULL pointer dereference in reopen failure path
Date: Tue, 28 Mar 2017 19:47:29 -0400
Message-ID: <1490744851-19985-2-git-send-email-michael.chan@broadcom.com>
References: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:35352 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932088AbdC1XsE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:48:04 -0400
Received: by mail-wr0-f178.google.com with SMTP id u1so49507wra.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:48:03 -0700 (PDT)
In-Reply-To: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sankar Patchineelam <sankar.patchineelam@broadcom.com>

Net device reset can fail when the h/w or f/w is in a bad state.
Subsequent netdevice open fails in bnxt_hwrm_stat_ctx_alloc().
The cleanup invokes bnxt_hwrm_resource_free() which inturn
calls bnxt_disable_int().  In this routine, the code segment

if (ring->fw_ring_id != INVALID_HW_RING_ID)
   BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);

results in NULL pointer dereference as cpr->cp_doorbell is not yet
initialized, and fw_ring_id is zero.

The fix is to initialize cpr fw_ring_id to INVALID_HW_RING_ID before
bnxt_init_chip() is invoked.

Signed-off-by: Sankar Patchineelam <sankar.patchineelam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 32de458..7ee7724 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2455,6 +2455,18 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 	return 0;
 }
 
+static void bnxt_init_cp_rings(struct bnxt *bp)
+{
+	int i;
+
+	for (i = 0; i < bp->cp_nr_rings; i++) {
+		struct bnxt_cp_ring_info *cpr = &bp->bnapi[i]->cp_ring;
+		struct bnxt_ring_struct *ring = &cpr->cp_ring_struct;
+
+		ring->fw_ring_id = INVALID_HW_RING_ID;
+	}
+}
+
 static int bnxt_init_rx_rings(struct bnxt *bp)
 {
 	int i, rc = 0;
@@ -5006,6 +5018,7 @@ static int bnxt_shutdown_nic(struct bnxt *bp, bool irq_re_init)
 
 static int bnxt_init_nic(struct bnxt *bp, bool irq_re_init)
 {
+	bnxt_init_cp_rings(bp);
 	bnxt_init_rx_rings(bp);
 	bnxt_init_tx_rings(bp);
 	bnxt_init_ring_grps(bp, irq_re_init);
-- 
1.8.3.1
