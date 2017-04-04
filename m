From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 12/12] bnxt_en: Cap the msix vector with the max completion rings.
Date: Tue,  4 Apr 2017 18:14:17 -0400
Message-ID: <1491344057-12663-13-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34254 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755173AbdDDWO6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:58 -0400
Received: by mail-wm0-f51.google.com with SMTP id w204so7040977wmd.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:58 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code enables up to the maximum MSIX vectors in the PCIE
config space without considering the max completion rings available.
An MSIX vector is only useful when it has an associated completion
ring, so it is better to cap it.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9d71c19..43b7342 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5183,9 +5183,10 @@ static unsigned int bnxt_get_max_func_irqs(struct bnxt *bp)
 {
 #if defined(CONFIG_BNXT_SRIOV)
 	if (BNXT_VF(bp))
-		return bp->vf.max_irqs;
+		return min_t(unsigned int, bp->vf.max_irqs,
+			     bp->vf.max_cp_rings);
 #endif
-	return bp->pf.max_irqs;
+	return min_t(unsigned int, bp->pf.max_irqs, bp->pf.max_cp_rings);
 }
 
 void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max_irqs)
-- 
1.8.3.1
