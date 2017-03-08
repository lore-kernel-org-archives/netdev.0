From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 12/13] mlx4: make validate_loopback() more generic
Date: Wed,  8 Mar 2017 08:17:17 -0800
Message-ID: <20170308161718.2867-13-edumazet@google.com>
References: <20170308161718.2867-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33106 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753058AbdCHQRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:17:51 -0500
Received: by mail-pg0-f46.google.com with SMTP id 25so14905300pgy.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:17:51 -0800 (PST)
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Testing a boolean in fast path is not worth duplicating
the code allocating packets, when GRO is on or off.

If this proves to be a problem, we might later use a jump label.

Next patch will remove this duplicated code and ease code review.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       | 23 ++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |  6 ------
 2 files changed, 10 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b5aa3f986508f0a5a89a40e18f8db99767068fef..33b28278c8270197c5a8f35521fd2af5e1e6b1be 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -584,20 +584,17 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	return skb;
 }
 
-static void validate_loopback(struct mlx4_en_priv *priv, struct sk_buff *skb)
+static void validate_loopback(struct mlx4_en_priv *priv, void *va)
 {
+	const unsigned char *data = va + ETH_HLEN;
 	int i;
-	int offset = ETH_HLEN;
 
-	for (i = 0; i < MLX4_LOOPBACK_TEST_PAYLOAD; i++, offset++) {
-		if (*(skb->data + offset) != (unsigned char) (i & 0xff))
-			goto out_loopback;
+	for (i = 0; i < MLX4_LOOPBACK_TEST_PAYLOAD; i++) {
+		if (data[i] != (unsigned char)i)
+			return;
 	}
 	/* Loopback found */
 	priv->loopback_ok = 1;
-
-out_loopback:
-	dev_kfree_skb_any(skb);
 }
 
 static bool mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
@@ -785,6 +782,11 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			}
 		}
 
+		if (unlikely(priv->validate_loopback)) {
+			validate_loopback(priv, va);
+			goto next;
+		}
+
 		/*
 		 * Packet is OK - process it.
 		 */
@@ -948,11 +950,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			goto next;
 		}
 
-		if (unlikely(priv->validate_loopback)) {
-			validate_loopback(priv, skb);
-			goto next;
-		}
-
 		if (ip_summed == CHECKSUM_COMPLETE) {
 			if (check_csum(cqe, skb, va, dev->features)) {
 				ip_summed = CHECKSUM_NONE;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 95290e1fc9fe7600b2e3bcca334f3fad7d733c09..17112faafbccc5f7a75ee82a287be7952859ae9e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -81,14 +81,11 @@ static int mlx4_en_test_loopback(struct mlx4_en_priv *priv)
 {
 	u32 loopback_ok = 0;
 	int i;
-	bool gro_enabled;
 
         priv->loopback_ok = 0;
 	priv->validate_loopback = 1;
-	gro_enabled = priv->dev->features & NETIF_F_GRO;
 
 	mlx4_en_update_loopback_state(priv->dev, priv->dev->features);
-	priv->dev->features &= ~NETIF_F_GRO;
 
 	/* xmit */
 	if (mlx4_en_test_loopback_xmit(priv)) {
@@ -111,9 +108,6 @@ static int mlx4_en_test_loopback(struct mlx4_en_priv *priv)
 
 	priv->validate_loopback = 0;
 
-	if (gro_enabled)
-		priv->dev->features |= NETIF_F_GRO;
-
 	mlx4_en_update_loopback_state(priv->dev, priv->dev->features);
 	return !loopback_ok;
 }
-- 
2.12.0.246.ga2ecc84866-goog
