From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] cnic: Fix crash during bnx2x MTU change.
Date: Mon, 5 Apr 2010 18:44:01 -0700
Message-ID: <1270518241-13750-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1441 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756236Ab0DFBdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 21:33:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cnic_service_bnx2x() irq handler can be called during chip reset from
MTU change.  Need to check that the cnic's device state is up before
handling the irq.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 9781942..4b451a7 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2334,13 +2334,13 @@ static int cnic_service_bnx2x(void *data, void *status_blk)
 	struct cnic_local *cp = dev->cnic_priv;
 	u16 prod = cp->kcq_prod_idx & MAX_KCQ_IDX;
 
-	prefetch(cp->status_blk.bnx2x);
-	prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
+	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags))) {
+		prefetch(cp->status_blk.bnx2x);
+		prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
 
-	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags)))
 		tasklet_schedule(&cp->cnic_irq_task);
-
-	cnic_chk_pkt_rings(cp);
+		cnic_chk_pkt_rings(cp);
+	}
 
 	return 0;
 }
-- 
1.6.4.GIT


