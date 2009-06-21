From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/6] mlx4_en: Counting all the dropped packets on the TX side
Date: Sun, 21 Jun 2009 11:15:31 +0300
Message-ID: <4A3DEC23.3050004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:51476 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752211AbZFUHZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 03:25:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reporting the counter's value through 'ethtool -S'

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 5dc7466..c0177c3 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -515,14 +515,12 @@ static int get_real_size(struct sk_buff *skb, struct net_device *dev,
 			else {
 				if (netif_msg_tx_err(priv))
 					en_warn(priv, "Non-linear headers\n");
-				dev_kfree_skb_any(skb);
 				return 0;
 			}
 		}
 		if (unlikely(*lso_header_size > MAX_LSO_HDR_SIZE)) {
 			if (netif_msg_tx_err(priv))
 				en_warn(priv, "LSO header size too big\n");
-			dev_kfree_skb_any(skb);
 			return 0;
 		}
 	} else {
@@ -622,7 +620,7 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	real_size = get_real_size(skb, dev, &lso_header_size);
 	if (unlikely(!real_size))
-		return NETDEV_TX_OK;
+		goto tx_drop;
 
 	/* Allign descriptor to TXBB size */
 	desc_size = ALIGN(real_size, TXBB_SIZE);
@@ -630,8 +628,7 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(nr_txbb > MAX_DESC_TXBBS)) {
 		if (netif_msg_tx_err(priv))
 			en_warn(priv, "Oversized header or SG list\n");
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		goto tx_drop;
 	}
 
 	tx_ind = skb->queue_mapping;
@@ -657,8 +654,7 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(!priv->port_up)) {
 		if (netif_msg_tx_err(priv))
 			en_warn(priv, "xmit: port down!\n");
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		goto tx_drop;
 	}
 
 	/* Track current inflight packets for performance analysis */
@@ -785,5 +781,10 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	mlx4_en_xmit_poll(priv, tx_ind);
 
 	return 0;
+
+tx_drop:
+	dev_kfree_skb_any(skb);
+	priv->stats.tx_dropped++;
+	return NETDEV_TX_OK;
 }
 
-- 
1.6.0

