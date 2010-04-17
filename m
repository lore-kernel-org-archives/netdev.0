From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: [PATCH] KS8851: NULL pointer dereference if list is empty
Date: Fri, 16 Apr 2010 19:48:43 -0500
Message-ID: <k2ocb8016981004161748s1a91f926x3c29b3fbd45ad46c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:51225 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757894Ab0DQAsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 20:48:45 -0400
Received: by gxk9 with SMTP id 9so1843492gxk.8
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 17:48:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix NULL pointer dereference in ks8851_tx_work by checking if dequeued
list is already empty before writing the packet to TX FIFO

 Unable to handle kernel NULL pointer dereference at virtual address 00000050
 PC is at ks8851_tx_work+0xdc/0x1b0
 LR is at wait_for_common+0x148/0x164
 pc : [<c01c0df4>]    lr : [<c025a980>]    psr: 20000013
 Backtrace:
  ks8851_tx_work+0x0/0x1b0
  worker_thread+0x0/0x190
  kthread+0x0/0x90

Signed-off-by: Abraham Arce <x0066660@ti.com>
---
 drivers/net/ks8851.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 13cc1ca..9e9f9b3 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -722,12 +722,14 @@ static void ks8851_tx_work(struct work_struct *work)
 		txb = skb_dequeue(&ks->txq);
 		last = skb_queue_empty(&ks->txq);

-		ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_SDA);
-		ks8851_wrpkt(ks, txb, last);
-		ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);
-		ks8851_wrreg16(ks, KS_TXQCR, TXQCR_METFE);
+		if (txb != NULL) {
+			ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_SDA);
+			ks8851_wrpkt(ks, txb, last);
+			ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);
+			ks8851_wrreg16(ks, KS_TXQCR, TXQCR_METFE);

-		ks8851_done_tx(ks, txb);
+			ks8851_done_tx(ks, txb);
+		}
 	}

 	mutex_unlock(&ks->lock);
-- 
1.5.4.3
