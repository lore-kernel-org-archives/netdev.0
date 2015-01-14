From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net 2/3 v2]tg3: tg3_reset_task() needs to use rtnl_lock to synchronize
Date: Wed, 14 Jan 2015 11:34:17 -0800
Message-ID: <1421264057-23981-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <peter@hurleysoftware.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:37700 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbbANTwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:52:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tg3_reset_task() uses only tp->lock for synchronizing with code
paths like tg3_open() etc. But since tp->lock is released before doing
synchronize_irq(), rtnl_lock should be taken in tg3_reset_task() to
synchronize it with other code paths.

Reported-by: Peter Hurley <peter@hurleysoftware.com>
Tested-by: Peter Hurley <peter@hurleysoftware.com>
Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 2dbd4ae..9247ae1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11103,11 +11103,13 @@ static void tg3_reset_task(struct work_struct *work)
 	struct tg3 *tp = container_of(work, struct tg3, reset_task);
 	int err;
 
+	rtnl_lock();
 	tg3_full_lock(tp, 0);
 
 	if (!netif_running(tp->dev)) {
 		tg3_flag_clear(tp, RESET_TASK_PENDING);
 		tg3_full_unlock(tp);
+		rtnl_unlock();
 		return;
 	}
 
@@ -11140,6 +11142,7 @@ out:
 		tg3_phy_start(tp);
 
 	tg3_flag_clear(tp, RESET_TASK_PENDING);
+	rtnl_unlock();
 }
 
 static int tg3_request_irq(struct tg3 *tp, int irq_num)
-- 
1.7.1
