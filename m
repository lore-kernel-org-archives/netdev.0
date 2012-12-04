From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/5 net-next v2] tg3: Fix inconsistent locking for
 tg3_netif_start().
Date: Mon, 3 Dec 2012 21:36:56 -0800
Message-ID: <1354599420-3589-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com,
	richardcochran@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3680 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab2LDFVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 00:21:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>

Every caller holds tp->lock when calling tg3_netif_start() except
tg3_io_resume().  Fix it so that it is all consistent.  The subsequent
PTP patches add tg3_ptp_resume() to tg3_netif_start() and the tp->lock
is required.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 5cc976d..41a2dbd 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6525,6 +6525,7 @@ static inline void tg3_netif_stop(struct tg3 *tp)
 	netif_tx_disable(tp->dev);
 }
 
+/* tp->lock must be held */
 static inline void tg3_netif_start(struct tg3 *tp)
 {
 	/* NOTE: unconditional netif_tx_wake_all_queues is only
@@ -16598,8 +16599,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
 	tg3_full_lock(tp, 0);
 	tg3_flag_set(tp, INIT_COMPLETE);
 	err = tg3_restart_hw(tp, 1);
-	tg3_full_unlock(tp);
 	if (err) {
+		tg3_full_unlock(tp);
 		netdev_err(netdev, "Cannot restart hardware after reset.\n");
 		goto done;
 	}
@@ -16610,6 +16611,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
 
 	tg3_netif_start(tp);
 
+	tg3_full_unlock(tp);
+
 	tg3_phy_start(tp);
 
 done:
-- 
1.7.1
