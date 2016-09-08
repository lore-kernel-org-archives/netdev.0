From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 9/9] net/mlx4_en: Fix panic on xmit while port is down
Date: Thu,  8 Sep 2016 11:52:01 +0300
Message-ID: <1473324721-5206-10-git-send-email-tariqt@mellanox.com>
References: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Moshe Shemesh <moshe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55673 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S938470AbcIHIxN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 04:53:13 -0400
In-Reply-To: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

When port is down, tx drop counter update is not needed.
Updating the counter in this case can cause a kernel
panic as when the port is down, ring can be NULL.

Fixes: 63a664b7e92b ("net/mlx4_en: fix tx_dropped bug")
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 9df87ca0515a..e2509bba3e7c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -818,7 +818,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	real_size = get_real_size(skb, shinfo, dev, &lso_header_size,
 				  &inline_ok, &fragptr);
 	if (unlikely(!real_size))
-		goto tx_drop;
+		goto tx_drop_count;
 
 	/* Align descriptor to TXBB size */
 	desc_size = ALIGN(real_size, TXBB_SIZE);
@@ -826,7 +826,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(nr_txbb > MAX_DESC_TXBBS)) {
 		if (netif_msg_tx_err(priv))
 			en_warn(priv, "Oversized header or SG list\n");
-		goto tx_drop;
+		goto tx_drop_count;
 	}
 
 	bf_ok = ring->bf_enabled;
@@ -1071,9 +1071,10 @@ tx_drop_unmap:
 			       PCI_DMA_TODEVICE);
 	}
 
+tx_drop_count:
+	ring->tx_dropped++;
 tx_drop:
 	dev_kfree_skb_any(skb);
-	ring->tx_dropped++;
 	return NETDEV_TX_OK;
 }
 
@@ -1106,7 +1107,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
 		goto tx_drop;
 
 	if (mlx4_en_is_tx_ring_full(ring))
-		goto tx_drop;
+		goto tx_drop_count;
 
 	/* fetch ring->cons far ahead before needing it to avoid stall */
 	ring_cons = READ_ONCE(ring->cons);
@@ -1176,7 +1177,8 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
 
 	return NETDEV_TX_OK;
 
-tx_drop:
+tx_drop_count:
 	ring->tx_dropped++;
+tx_drop:
 	return NETDEV_TX_BUSY;
 }
-- 
1.8.3.1
