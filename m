From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: fix performance regression
Date: Tue, 29 Jul 2014 16:29:30 +0200
Message-ID: <1406644170-4693-1-git-send-email-ivecera@redhat.com>
Cc: rmody@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753406AbaG2O3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 10:29:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent commit "e29aa33 bna: Enable Multi Buffer RX" is causing
a performance regression. It does not properly update 'cmpl' pointer
at the end of the loop in NAPI handler bnad_cq_process(). The result is
only one packet / per NAPI-schedule is processed.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 3a77f9e..556aab7 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -600,9 +600,9 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	prefetch(bnad->netdev);
 
 	cq = ccb->sw_q;
-	cmpl = &cq[ccb->producer_index];
 
 	while (packets < budget) {
+		cmpl = &cq[ccb->producer_index];
 		if (!cmpl->valid)
 			break;
 		/* The 'valid' field is set by the adapter, only after writing
-- 
1.8.5.5
