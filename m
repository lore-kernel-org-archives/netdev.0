From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 03/10] tg3: Fix a memory leak on 5717+ devices
Date: Sat, 5 Jun 2010 20:24:32 -0700
Message-ID: <1275794679-11085-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4650 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933981Ab0FFDYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 23:24:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rx resources for MSI-X interrupt vector 0 were not being freed
correctly.  This happens because the teardown loop continue's to the
next loop iteration if it detects the tx ring for that vector is not
setup, thus bypassing the rx teardown code.  This patch moves the
call to tg3_rx_prodring_free() earlier in the loop.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 057e8eb..86f8798 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6229,6 +6229,8 @@ static void tg3_free_rings(struct tg3 *tp)
 	for (j = 0; j < tp->irq_cnt; j++) {
 		struct tg3_napi *tnapi = &tp->napi[j];
 
+		tg3_rx_prodring_free(tp, &tp->prodring[j]);
+
 		if (!tnapi->tx_buffers)
 			continue;
 
@@ -6264,8 +6266,6 @@ static void tg3_free_rings(struct tg3 *tp)
 
 			dev_kfree_skb_any(skb);
 		}
-
-		tg3_rx_prodring_free(tp, &tp->prodring[j]);
 	}
 }
 
-- 
1.6.4.4


