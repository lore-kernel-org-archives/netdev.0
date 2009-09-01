From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 08/18] tg3: Update intmbox and coal_now for msix
Date: Tue, 1 Sep 2009 16:08:58 -0700
Message-ID: <1251867306.5935@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3667 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932132AbZIBEzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes up two spots that need attention now that msix support
has been added.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 58a8986..5389654 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -614,25 +614,33 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 
 static void tg3_disable_ints(struct tg3 *tp)
 {
+	int i;
+
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     (tp->misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT));
-	tw32_mailbox_f(tp->napi[0].int_mbox, 0x00000001);
+	for (i = 0; i < tp->irq_max; i++)
+		tw32_mailbox_f(tp->napi[i].int_mbox, 0x00000001);
 }
 
 static void tg3_enable_ints(struct tg3 *tp)
 {
-	u32 coal_now;
-	struct tg3_napi *tnapi = &tp->napi[0];
+	int i;
+	u32 coal_now = 0;
+
 	tp->irq_sync = 0;
 	wmb();
 
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     (tp->misc_host_ctrl & ~MISC_HOST_CTRL_MASK_PCI_INT));
-	tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
-	if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
+
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
 		tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
+		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
+			tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
 
-	coal_now = tnapi->coal_now;
+		coal_now |= tnapi->coal_now;
+	}
 
 	/* Force an initial interrupt */
 	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
-- 
1.6.3.3


