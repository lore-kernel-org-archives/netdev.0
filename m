From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 01/18] tg3: inline tg3_cond_int()
Date: Tue, 1 Sep 2009 15:47:49 -0700
Message-ID: <1251867298.5914@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3486 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754543AbZIBEzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch inlines the code of tg3_cond_int() into the function's only
callsite.  This prep work makes the following patch cleaner.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9d5c178..65ff286 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -618,18 +618,9 @@ static void tg3_disable_ints(struct tg3 *tp)
 	tw32_mailbox_f(tp->napi[0].int_mbox, 0x00000001);
 }
 
-static inline void tg3_cond_int(struct tg3 *tp)
-{
-	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
-	    (tp->napi[0].hw_status->status & SD_STATUS_UPDATED))
-		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
-	else
-		tw32(HOSTCC_MODE, tp->coalesce_mode |
-		     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
-}
-
 static void tg3_enable_ints(struct tg3 *tp)
 {
+	u32 coal_now;
 	struct tg3_napi *tnapi = &tp->napi[0];
 	tp->irq_sync = 0;
 	wmb();
@@ -639,7 +630,16 @@ static void tg3_enable_ints(struct tg3 *tp)
 	tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
 	if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
 		tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
-	tg3_cond_int(tp);
+
+	coal_now = HOSTCC_MODE_NOW;
+
+	/* Force an initial interrupt */
+	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
+	    (tp->napi[0].hw_status->status & SD_STATUS_UPDATED))
+		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
+	else
+		tw32(HOSTCC_MODE, tp->coalesce_mode |
+		     HOSTCC_MODE_ENABLE | coal_now);
 }
 
 static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
-- 
1.6.3.3


