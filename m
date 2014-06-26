From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 3/3] net: systemport: fix TX NAPI work done return value
Date: Thu, 26 Jun 2014 10:06:46 -0700
Message-ID: <1403802406-10992-4-git-send-email-f.fainelli@gmail.com>
References: <1403802406-10992-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:39989 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757594AbaFZRH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 13:07:28 -0400
Received: by mail-pd0-f179.google.com with SMTP id w10so3293252pde.10
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 10:07:28 -0700 (PDT)
In-Reply-To: <1403802406-10992-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although we do not limit the number of packets the TX completion
function bcm_sysport_tx_reclaim() is allowed to reclaim, we were still
using its return value as-is. This means that we could hit the WARN() in
net/core/dev.c where work_done >= budget.

Make sure we do exit the NAPI context when the TX ring is empty, and
pretend there was no work to do.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
New patch in v2

 drivers/net/ethernet/broadcom/bcmsysport.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index d31f7d239064..5776e503e4c5 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -654,13 +654,13 @@ static int bcm_sysport_tx_poll(struct napi_struct *napi, int budget)
 
 	work_done = bcm_sysport_tx_reclaim(ring->priv, ring);
 
-	if (work_done < budget) {
+	if (work_done == 0) {
 		napi_complete(napi);
 		/* re-enable TX interrupt */
 		intrl2_1_mask_clear(ring->priv, BIT(ring->index));
 	}
 
-	return work_done;
+	return 0;
 }
 
 static void bcm_sysport_tx_reclaim_all(struct bcm_sysport_priv *priv)
-- 
1.9.1
