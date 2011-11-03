From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] tg3: fix error handling in tg3_open
Date: Thu,  3 Nov 2011 19:36:43 +0900
Message-ID: <1320316603-8355-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:50928 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670Ab1KCKgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 06:36:19 -0400
Received: by ywf7 with SMTP id 7so1168941ywf.19
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2011 03:36:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If one of the request_irq calls fails in tg3_open, all interrupts
allocated with request_irq should be freed before returning error.

But it accidentally attempts to free the same invalid IRQ repeatedly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 161cbbb..13c4054 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9674,8 +9674,10 @@ static int tg3_open(struct net_device *dev)
 		struct tg3_napi *tnapi = &tp->napi[i];
 		err = tg3_request_irq(tp, i);
 		if (err) {
-			for (i--; i >= 0; i--)
+			for (i--; i >= 0; i--) {
+				tnapi = &tp->napi[i];
 				free_irq(tnapi->irq_vec, tnapi);
+			}
 			break;
 		}
 	}
-- 
1.7.4.4
