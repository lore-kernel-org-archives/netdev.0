From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/3] bnxt_en: Fix tx push race condition.
Date: Mon,  6 Jun 2016 02:37:14 -0400
Message-ID: <1465195036-4107-2-git-send-email-michael.chan@broadcom.com>
References: <1465195036-4107-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33899 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbcFFGh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 02:37:27 -0400
Received: by mail-pa0-f49.google.com with SMTP id bz2so32548660pad.1
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 23:37:26 -0700 (PDT)
In-Reply-To: <1465195036-4107-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the is_push flag in the software BD before the tx data is pushed to
the chip.  It is possible to get the tx interrupt as soon as the tx data
is pushed.  The tx handler will not handle the event properly if the
is_push flag is not set and it will crash.

Signed-off-by: Michael Chan <michael.chan@broadocm.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 72a2eff..4615ed4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -286,7 +286,9 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			cpu_to_le32(DB_KEY_TX_PUSH | DB_LONG_TX_PUSH | prod);
 		txr->tx_prod = prod;
 
+		tx_buf->is_push = 1;
 		netdev_tx_sent_queue(txq, skb->len);
+		wmb();	/* Sync is_push and byte queue before pushing data */
 
 		push_len = (length + sizeof(*tx_push) + 7) / 8;
 		if (push_len > 16) {
@@ -298,7 +300,6 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					 push_len);
 		}
 
-		tx_buf->is_push = 1;
 		goto tx_done;
 	}
 
-- 
1.8.3.1
