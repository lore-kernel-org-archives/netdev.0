From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/10] tg3: Fix tx mailbox initialization
Date: Wed, 20 Jan 2010 18:58:08 -0800
Message-ID: <1264042691-28284-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1736 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260Ab0AUC61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a device supports MSI-X interrupts, the driver assumes TSS will be
available.  This is not true for the 57765.  This patch changes the code
so that only the default tx mailbox is initialized if TSS is not
available.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 72d1e18..dffa51a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7440,10 +7440,13 @@ static void tg3_rings_reset(struct tg3 *tp)
 		for (i = 1; i < TG3_IRQ_MAX_VECS; i++) {
 			tp->napi[i].tx_prod = 0;
 			tp->napi[i].tx_cons = 0;
-			tw32_mailbox(tp->napi[i].prodmbox, 0);
+			if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
+				tw32_mailbox(tp->napi[i].prodmbox, 0);
 			tw32_rx_mbox(tp->napi[i].consmbox, 0);
 			tw32_mailbox_f(tp->napi[i].int_mbox, 1);
 		}
+		if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS))
+			tw32_mailbox(tp->napi[0].prodmbox, 0);
 	} else {
 		tp->napi[0].tx_prod = 0;
 		tp->napi[0].tx_cons = 0;
-- 
1.6.4.4


