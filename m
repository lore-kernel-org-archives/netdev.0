From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 6/7] bnxt_en: Implement xmit_more.
Date: Mon, 29 May 2017 19:06:09 -0400
Message-ID: <1496099170-701-7-git-send-email-michael.chan@broadcom.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:34877 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdE2XHC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 19:07:02 -0400
Received: by mail-qt0-f182.google.com with SMTP id v27so58546934qtg.2
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 16:07:02 -0700 (PDT)
In-Reply-To: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not write the TX doorbell if skb->xmit_more is set unless the TX
queue is full.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index d7c1295..2c6af31 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -463,13 +463,17 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	prod = NEXT_TX(prod);
 	txr->tx_prod = prod;
 
-	bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | prod);
+	if (!skb->xmit_more)
+		bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | prod);
 
 tx_done:
 
 	mmiowb();
 
 	if (unlikely(bnxt_tx_avail(bp, txr) <= MAX_SKB_FRAGS + 1)) {
+		if (skb->xmit_more && !tx_buf->is_push)
+			bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | prod);
+
 		netif_tx_stop_queue(txq);
 
 		/* netif_tx_stop_queue() must be done before checking
-- 
1.8.3.1
