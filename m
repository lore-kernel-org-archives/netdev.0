From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/4] bnxt_en: Initialize CP doorbell value before ring allocation
Date: Mon, 28 Mar 2016 19:46:04 -0400
Message-ID: <1459208767-4225-2-git-send-email-michael.chan@broadcom.com>
References: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:26215 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbcC1Xzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 19:55:42 -0400
In-Reply-To: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>

The existing code does the following:
    allocate completion ring
    initialize completion ring doorbell
    disable interrupts on this completion ring by writing to the doorbell

We can have a race where firmware sends an asynchronous event to the host
after completion ring allocation and before doorbell is initialized.
When this happens driver can crash while ringing the doorbell using
uninitialized value as part of handling the IRQ/napi request.

Signed-off-by: Prashant Sreedharan <prashant.sreedharan@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index aabbd51..c92053c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3391,11 +3391,11 @@ static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
 		struct bnxt_ring_struct *ring = &cpr->cp_ring_struct;
 
+		cpr->cp_doorbell = bp->bar1 + i * 0x80;
 		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_CMPL, i,
 					      INVALID_STATS_CTX_ID);
 		if (rc)
 			goto err_out;
-		cpr->cp_doorbell = bp->bar1 + i * 0x80;
 		BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
 		bp->grp_info[i].cp_fw_ring_id = ring->fw_ring_id;
 	}
-- 
1.8.3.1
