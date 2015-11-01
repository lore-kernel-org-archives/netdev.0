From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 8/8] net/mlx5e: Fix LSO vlan insertion
Date: Sun,  1 Nov 2015 19:35:22 +0200
Message-ID: <1446399322-14046-9-git-send-email-ogerlitz@mellanox.com>
References: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56274 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752745AbbKARfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2015 12:35:51 -0500
In-Reply-To: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Consider vlan insertion impact on headers copy size also for LSO
packets.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 5105288..cd8f85a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -116,7 +116,7 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 	 * headers and occur before the data gather.
 	 * Therefore these headers must be copied into the WQE
 	 */
-#define MLX5E_MIN_INLINE (ETH_HLEN + 2/*vlan tag*/)
+#define MLX5E_MIN_INLINE ETH_HLEN
 
 	if (bf && (skb_headlen(skb) <= sq->max_inline))
 		return skb_headlen(skb);
@@ -128,7 +128,7 @@ static inline void mlx5e_insert_vlan(void *start, struct sk_buff *skb, u16 ihs)
 {
 	struct vlan_ethhdr *vhdr = (struct vlan_ethhdr *)start;
 	int cpy1_sz = 2 * ETH_ALEN;
-	int cpy2_sz = ihs - cpy1_sz - VLAN_HLEN;
+	int cpy2_sz = ihs - cpy1_sz;
 
 	skb_copy_from_linear_data(skb, vhdr, cpy1_sz);
 	skb_pull_inline(skb, cpy1_sz);
@@ -192,6 +192,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	if (skb_vlan_tag_present(skb)) {
 		mlx5e_insert_vlan(eseg->inline_hdr_start, skb, ihs);
+		ihs += VLAN_HLEN;
 	} else {
 		skb_copy_from_linear_data(skb, eseg->inline_hdr_start, ihs);
 		skb_pull_inline(skb, ihs);
-- 
2.3.7
