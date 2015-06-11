From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/7] net/mlx5e: Disable client vlan TX acceleration
Date: Thu, 11 Jun 2015 14:47:29 +0300
Message-ID: <1434023253-24362-4-git-send-email-ogerlitz@mellanox.com>
References: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47271 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752864AbbFKLsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 07:48:01 -0400
In-Reply-To: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

We need to resolve a HW configuration issue for enabling HW CVLAN
insertion. Meanwhile, no need to implement the VLAN insertion in
the driver, rather use the generic kernel VLAN insertion method.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |   23 +-------------------
 2 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 95772dc..3cba6a6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1755,7 +1755,6 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 		netdev->vlan_features    |= NETIF_F_LRO;
 
 	netdev->hw_features       = netdev->vlan_features;
-	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_TX;
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 8020986..3cfd2bc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -89,21 +89,6 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 	return MLX5E_MIN_INLINE;
 }
 
-static inline void mlx5e_insert_vlan(void *start, struct sk_buff *skb, u16 ihs)
-{
-	struct vlan_ethhdr *vhdr = (struct vlan_ethhdr *)start;
-	int cpy1_sz = 2 * ETH_ALEN;
-	int cpy2_sz = ihs - cpy1_sz - VLAN_HLEN;
-
-	skb_copy_from_linear_data(skb, vhdr, cpy1_sz);
-	skb_pull_inline(skb, cpy1_sz);
-	vhdr->h_vlan_proto = skb->vlan_proto;
-	vhdr->h_vlan_TCI = cpu_to_be16(skb_vlan_tag_get(skb));
-	skb_copy_from_linear_data(skb, &vhdr->h_vlan_encapsulated_proto,
-				  cpy2_sz);
-	skb_pull_inline(skb, cpy2_sz);
-}
-
 static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 {
 	struct mlx5_wq_cyc       *wq   = &sq->wq;
@@ -149,12 +134,8 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 							ETH_ZLEN);
 	}
 
-	if (skb_vlan_tag_present(skb)) {
-		mlx5e_insert_vlan(eseg->inline_hdr_start, skb, ihs);
-	} else {
-		skb_copy_from_linear_data(skb, eseg->inline_hdr_start, ihs);
-		skb_pull_inline(skb, ihs);
-	}
+	skb_copy_from_linear_data(skb, eseg->inline_hdr_start, ihs);
+	skb_pull_inline(skb, ihs);
 
 	eseg->inline_hdr_sz	= cpu_to_be16(ihs);
 
-- 
1.7.1
