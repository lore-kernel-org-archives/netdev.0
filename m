From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/8] tg3: Fix irq alloc error cleanup path
Date: Fri, 4 Nov 2011 12:15:01 -0700
Message-ID: <1320434105-12898-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Ben Li" <benli@broadcom.com>,
	"Akinobu Mita" <akinobu.mita@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3458 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755763Ab1KDTN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 15:13:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug where the irq error cleanup path did not free all
the resources it allocated.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Ben Li <benli@broadcom.com>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3a75179..0413e1e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9677,15 +9677,14 @@ static int tg3_open(struct net_device *dev)
 		struct tg3_napi *tnapi = &tp->napi[i];
 		err = tg3_request_irq(tp, i);
 		if (err) {
-			for (i--; i >= 0; i--)
+			for (i--; i >= 0; i--) {
+				tnapi = &tp->napi[i];
 				free_irq(tnapi->irq_vec, tnapi);
-			break;
+			}
+			goto err_out2;
 		}
 	}
 
-	if (err)
-		goto err_out2;
-
 	tg3_full_lock(tp, 0);
 
 	err = tg3_init_hw(tp, 1);
-- 
1.7.3.4
