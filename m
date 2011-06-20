From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 03/11] emaclite: enable transmit and receive time stamping.
Date: Mon, 20 Jun 2011 09:51:25 +0200
Message-ID: <59f1ec96f041366d5dcb3cf1ccd33eca5e0eee68.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Linn <john.linn@xilinx.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40854 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601Ab1FTHvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:51:36 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so760782fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:51:35 -0700 (PDT)
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) time stamping. Since this
MAC uses phylib, adding the hooks make hardware time stamping in the phy
possible.

Compile tested only.

Cc: John Linn <john.linn@xilinx.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/xilinx_emaclite.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 372572c..8cae4f6 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -647,7 +647,8 @@ static void xemaclite_rx_handler(struct net_device *dev)
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
 
-	netif_rx(skb);		/* Send the packet upstream */
+	if (!skb_defer_rx_timestamp(skb))
+		netif_rx(skb);	/* Send the packet upstream */
 }
 
 /**
@@ -1029,15 +1030,19 @@ static int xemaclite_send(struct sk_buff *orig_skb, struct net_device *dev)
 	spin_lock_irqsave(&lp->reset_lock, flags);
 	if (xemaclite_send_data(lp, (u8 *) new_skb->data, len) != 0) {
 		/* If the Emaclite Tx buffer is busy, stop the Tx queue and
-		 * defer the skb for transmission at a later point when the
+		 * defer the skb for transmission during the ISR, after the
 		 * current transmission is complete */
 		netif_stop_queue(dev);
 		lp->deferred_skb = new_skb;
+		/* Take the time stamp now, since we can't do this in an ISR. */
+		skb_tx_timestamp(new_skb);
 		spin_unlock_irqrestore(&lp->reset_lock, flags);
 		return 0;
 	}
 	spin_unlock_irqrestore(&lp->reset_lock, flags);
 
+	skb_tx_timestamp(new_skb);
+
 	dev->stats.tx_bytes += len;
 	dev_kfree_skb(new_skb);
 
-- 
1.7.0.4

