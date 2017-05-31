From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next] bnxt_en: Fix xmit_more with BQL.
Date: Tue, 30 May 2017 20:03:00 -0400
Message-ID: <1496188980-13392-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34876 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdEaADL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:03:11 -0400
Received: by mail-qk0-f174.google.com with SMTP id 19so333674qke.2
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:03:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to write the doorbell if BQL has stopped the queue and
skb->xmit_more is set.  Otherwise it is possible for the tx queue to
rot and cause tx timeout.

Fixes: 4d172f21cefe ("bnxt_en: Implement xmit_more.")
Suggested-by: Yuval Mintz <yuval.mintz@cavium.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 954758f..c1cd72a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -463,7 +463,7 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	prod = NEXT_TX(prod);
 	txr->tx_prod = prod;
 
-	if (!skb->xmit_more)
+	if (!skb->xmit_more || netif_xmit_stopped(txq))
 		bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | prod);
 
 tx_done:
-- 
1.8.3.1
