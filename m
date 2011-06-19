From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 02/11] lib8390: enable transmit and receive time stamping.
Date: Sun, 19 Jun 2011 19:56:55 +0200
Message-ID: <78a221a72eeca02ae74d4cb3bdd8035f751c915c.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58291 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317Ab1FSR5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 13:57:07 -0400
Received: by fxm17 with SMTP id 17so546578fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 10:57:06 -0700 (PDT)
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) time stamping. This file is
included by drivers/net/ax88796.c, which is based on phylib. So, this
patch makes hardware time stamping in the PHY possible.

Compile tested only.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/lib8390.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 17b75e5..70eb207 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -410,7 +410,7 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 
 	spin_unlock(&ei_local->page_lock);
 	enable_irq_lockdep_irqrestore(dev->irq, &flags);
-
+	skb_tx_timestamp(skb);
 	dev_kfree_skb (skb);
 	dev->stats.tx_bytes += send_length;
 
@@ -758,7 +758,8 @@ static void ei_receive(struct net_device *dev)
 				skb_put(skb, pkt_len);	/* Make room */
 				ei_block_input(dev, pkt_len, skb, current_offset + sizeof(rx_frame));
 				skb->protocol=eth_type_trans(skb,dev);
-				netif_rx(skb);
+				if (!skb_defer_rx_timestamp(skb))
+					netif_rx(skb);
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 				if (pkt_stat & ENRSR_PHY)
-- 
1.7.0.4

