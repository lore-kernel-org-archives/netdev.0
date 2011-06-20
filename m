From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 2/2] mv643xx_eth: fix race in trasmit path.
Date: Mon, 20 Jun 2011 09:48:07 +0200
Message-ID: <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
References: <cover.1308555865.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, stable@kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41474 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642Ab1FTHsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:48:08 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so759177fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:48:07 -0700 (PDT)
In-Reply-To: <cover.1308555865.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308555865.git.richard.cochran@omicron.at>
References: <cover.1308555865.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the socket buffer is freed in the completion interrupt, it is not
safe to access it after submitting it to the hardware.

Cc: stable@kernel.org
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/mv643xx_eth.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a5d9b1c..1b7d2c1 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -859,7 +859,7 @@ no_csum:
 static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	int queue;
+	int length, queue;
 	struct tx_queue *txq;
 	struct netdev_queue *nq;
 
@@ -881,10 +881,12 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
+	length = skb->len;
+
 	if (!txq_submit_skb(txq, skb)) {
 		int entries_left;
 
-		txq->tx_bytes += skb->len;
+		txq->tx_bytes += length;
 		txq->tx_packets++;
 
 		entries_left = txq->tx_ring_size - txq->tx_desc_count;
-- 
1.7.0.4

