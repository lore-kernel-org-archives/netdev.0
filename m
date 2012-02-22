From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/4] tg3: Clear RECOVERY_PENDING with
 reset_task_cancel
Date: Wed, 22 Feb 2012 14:35:20 -0800
Message-ID: <1329950121-18577-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3327 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066Ab2BVWgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 17:36:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an error happens in the tx completion thread, tg3_reset_task will be
scheduled and TX_RECOVERY_PENDING will be set.  The TX_RECOVERY_PENDING
flag causes tg3_poll[_msix] to return early before doing much of its
work.  Tg3_reset_task() gets canceled when the configuration of the
device is changing, which always results in a chip reset.  When this
happens, the TX_RECOVERY_PENDING flag may be left set, which would
unnecessarily hinder tg3_poll from doing work.  This patch fixes the
problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9d895c9..1f82514 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6163,6 +6163,7 @@ static inline void tg3_reset_task_cancel(struct tg3 *tp)
 {
 	cancel_work_sync(&tp->reset_task);
 	tg3_flag_clear(tp, RESET_TASK_PENDING);
+	tg3_flag_clear(tp, TX_RECOVERY_PENDING);
 }
 
 static int tg3_poll_msix(struct napi_struct *napi, int budget)
@@ -15937,7 +15938,6 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 
 	/* Want to make sure that the reset task doesn't run */
 	tg3_reset_task_cancel(tp);
-	tg3_flag_clear(tp, TX_RECOVERY_PENDING);
 
 	netif_device_detach(netdev);
 
-- 
1.7.3.4
