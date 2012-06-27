From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 -next 1/4] tg3: Add common function
 tg3_ape_event_lock()
Date: Tue, 26 Jun 2012 17:53:32 -0700
Message-ID: <1340758415-10746-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4109 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754730Ab2F0Amd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 20:42:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Carlson <mcarlson@broadcom.com>

by refactoring code in tg3_ape_send_event().  The common function will
be used in subsequent patches.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   56 ++++++++++++++++++++---------------
 1 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e47ff8b..7c515db 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -730,44 +730,52 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 	tg3_ape_write32(tp, gnt + 4 * locknum, bit);
 }
 
-static void tg3_ape_send_event(struct tg3 *tp, u32 event)
+static int tg3_ape_event_lock(struct tg3 *tp, u32 timeout_us)
 {
-	int i;
 	u32 apedata;
 
-	/* NCSI does not support APE events */
-	if (tg3_flag(tp, APE_HAS_NCSI))
-		return;
+	while (timeout_us) {
+		if (tg3_ape_lock(tp, TG3_APE_LOCK_MEM))
+			return -EBUSY;
+
+		apedata = tg3_ape_read32(tp, TG3_APE_EVENT_STATUS);
+		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
+			break;
+
+		tg3_ape_unlock(tp, TG3_APE_LOCK_MEM);
+
+		udelay(10);
+		timeout_us -= (timeout_us > 10) ? 10 : timeout_us;
+	}
+
+	return timeout_us ? 0 : -EBUSY;
+}
+
+static int tg3_ape_send_event(struct tg3 *tp, u32 event)
+{
+	int err;
+	u32 apedata;
 
 	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
 	if (apedata != APE_SEG_SIG_MAGIC)
-		return;
+		return -EAGAIN;
 
 	apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
 	if (!(apedata & APE_FW_STATUS_READY))
-		return;
+		return -EAGAIN;
 
 	/* Wait for up to 1 millisecond for APE to service previous event. */
-	for (i = 0; i < 10; i++) {
-		if (tg3_ape_lock(tp, TG3_APE_LOCK_MEM))
-			return;
-
-		apedata = tg3_ape_read32(tp, TG3_APE_EVENT_STATUS);
-
-		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
-			tg3_ape_write32(tp, TG3_APE_EVENT_STATUS,
-					event | APE_EVENT_STATUS_EVENT_PENDING);
+	err = tg3_ape_event_lock(tp, 1000);
+	if (err)
+		return err;
 
-		tg3_ape_unlock(tp, TG3_APE_LOCK_MEM);
+	tg3_ape_write32(tp, TG3_APE_EVENT_STATUS,
+			event | APE_EVENT_STATUS_EVENT_PENDING);
 
-		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
-			break;
+	tg3_ape_unlock(tp, TG3_APE_LOCK_MEM);
+	tg3_ape_write32(tp, TG3_APE_EVENT, APE_EVENT_1);
 
-		udelay(100);
-	}
-
-	if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
-		tg3_ape_write32(tp, TG3_APE_EVENT, APE_EVENT_1);
+	return 0;
 }
 
 static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
-- 
1.7.1
