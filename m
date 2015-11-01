From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/8] net/mlx5e: Re-eanble client vlan TX acceleration
Date: Sun,  1 Nov 2015 19:35:21 +0200
Message-ID: <1446399322-14046-8-git-send-email-ogerlitz@mellanox.com>
References: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56286 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752596AbbKARgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2015 12:36:04 -0500
In-Reply-To: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

This reverts commit cd58c714acb9 "net/mlx5e: Disable client vlan TX acceleration".

Bring back client vlan insertion offload, the original
performance issue was found and fixed in the next patch.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 23 +++++++++++++++++++++--
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b284bfc..b87f5f2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2005,6 +2005,7 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 		netdev->vlan_features    |= NETIF_F_LRO;
 
 	netdev->hw_features       = netdev->vlan_features;
+	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_TX;
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index b73672f..5105288 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -124,6 +124,21 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 	return MLX5E_MIN_INLINE;
 }
 
+static inline void mlx5e_insert_vlan(void *start, struct sk_buff *skb, u16 ihs)
+{
+	struct vlan_ethhdr *vhdr = (struct vlan_ethhdr *)start;
+	int cpy1_sz = 2 * ETH_ALEN;
+	int cpy2_sz = ihs - cpy1_sz - VLAN_HLEN;
+
+	skb_copy_from_linear_data(skb, vhdr, cpy1_sz);
+	skb_pull_inline(skb, cpy1_sz);
+	vhdr->h_vlan_proto = skb->vlan_proto;
+	vhdr->h_vlan_TCI = cpu_to_be16(skb_vlan_tag_get(skb));
+	skb_copy_from_linear_data(skb, &vhdr->h_vlan_encapsulated_proto,
+				  cpy2_sz);
+	skb_pull_inline(skb, cpy2_sz);
+}
+
 static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 {
 	struct mlx5_wq_cyc       *wq   = &sq->wq;
@@ -175,8 +190,12 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 							ETH_ZLEN);
 	}
 
-	skb_copy_from_linear_data(skb, eseg->inline_hdr_start, ihs);
-	skb_pull_inline(skb, ihs);
+	if (skb_vlan_tag_present(skb)) {
+		mlx5e_insert_vlan(eseg->inline_hdr_start, skb, ihs);
+	} else {
+		skb_copy_from_linear_data(skb, eseg->inline_hdr_start, ihs);
+		skb_pull_inline(skb, ihs);
+	}
 
 	eseg->inline_hdr_sz = cpu_to_be16(ihs);
 
-- 
2.3.7
