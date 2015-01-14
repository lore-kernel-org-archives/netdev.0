From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net 1/3 v2]tg3: tg3_timer() should grab tp->lock before checking for tp->irq_sync
Date: Wed, 14 Jan 2015 11:33:49 -0800
Message-ID: <1421264029-23939-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <peter@hurleysoftware.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:30353 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbANTv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:51:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to avoid the race between tg3_timer() and the execution paths
which does not invoke tg3_timer_stop() and releases tp->lock before
calling synchronize_irq()

Reported-by: Peter Hurley <peter@hurleysoftware.com>
Tested-by: Peter Hurley <peter@hurleysoftware.com>
Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 553dcd8..2dbd4ae 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10903,11 +10903,13 @@ static void tg3_timer(unsigned long __opaque)
 {
 	struct tg3 *tp = (struct tg3 *) __opaque;
 
-	if (tp->irq_sync || tg3_flag(tp, RESET_TASK_PENDING))
-		goto restart_timer;
-
 	spin_lock(&tp->lock);
 
+	if (tp->irq_sync || tg3_flag(tp, RESET_TASK_PENDING)) {
+		spin_unlock(&tp->lock);
+		goto restart_timer;
+	}
+
 	if (tg3_asic_rev(tp) == ASIC_REV_5717 ||
 	    tg3_flag(tp, 57765_CLASS))
 		tg3_chk_missed_msi(tp);
-- 
1.7.1
