From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: systemport: fix tx work done in TX napi poll
Date: Wed, 12 Nov 2014 15:40:43 -0800
Message-ID: <1415835643-13767-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:57545 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbaKLXmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 18:42:22 -0500
Received: by mail-pa0-f49.google.com with SMTP id lj1so13948626pab.36
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 15:42:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit d75b1ade567 ("net: less interrupt masking in NAPI") napi
repoll is done only when work_done == budget. bcm_sysport_tx_poll()
always returns 0 whether or not we completed the poll quantum.

Fix this by returning either 0 when we did complete the TX ring reclaim,
or budget to trigger a repoll.

Fixes: d75b1ade567 ("net: less interrupt masking in NAPI")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 531bb7c57531..3cb241155dac 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -731,9 +731,11 @@ static int bcm_sysport_tx_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		/* re-enable TX interrupt */
 		intrl2_1_mask_clear(ring->priv, BIT(ring->index));
+
+		return 0;
 	}
 
-	return 0;
+	return budget;
 }
 
 static void bcm_sysport_tx_reclaim_all(struct bcm_sysport_priv *priv)
-- 
1.9.1
