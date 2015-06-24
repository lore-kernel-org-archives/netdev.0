From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/4] net/mlx4_en: Fix wrong csum complete report when rxvlan offload is disabled
Date: Wed, 24 Jun 2015 18:22:02 +0300
Message-ID: <1435159323-10028-4-git-send-email-ogerlitz@mellanox.com>
References: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56561 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752620AbbFXPWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 11:22:32 -0400
In-Reply-To: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

The check_csum() function relied on hwtstamp_rx_filter to know if rxvlan
offload is disabled. This is wrong since rxvlan offload can be switched
on/off regardless of hwtstamp_rx_filter.

Also moved check_csum to query CQE information to identify VLAN packets
and removed the check of IP packets, since it has been validated before.

Fixes: f8c6455bb04b ('net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE')
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 35f726c..580dd59 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -718,7 +718,7 @@ static int get_fixed_ipv6_csum(__wsum hw_checksum, struct sk_buff *skb,
 }
 #endif
 static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
-		      int hwtstamp_rx_filter)
+		      netdev_features_t dev_features)
 {
 	__wsum hw_checksum = 0;
 
@@ -726,14 +726,8 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
 
 	hw_checksum = csum_unfold((__force __sum16)cqe->checksum);
 
-	if (((struct ethhdr *)va)->h_proto == htons(ETH_P_8021Q) &&
-	    hwtstamp_rx_filter != HWTSTAMP_FILTER_NONE) {
-		/* next protocol non IPv4 or IPv6 */
-		if (((struct vlan_hdr *)hdr)->h_vlan_encapsulated_proto
-		    != htons(ETH_P_IP) &&
-		    ((struct vlan_hdr *)hdr)->h_vlan_encapsulated_proto
-		    != htons(ETH_P_IPV6))
-			return -1;
+	if (be32_to_cpu(cqe->vlan_my_qpn) & MLX4_CQE_VLAN_PRESENT_MASK &&
+	    !(dev_features & NETIF_F_HW_VLAN_CTAG_RX)) {
 		hw_checksum = get_fixed_vlan_csum(hw_checksum, hdr);
 		hdr += sizeof(struct vlan_hdr);
 	}
@@ -896,7 +890,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 			if (ip_summed == CHECKSUM_COMPLETE) {
 				void *va = skb_frag_address(skb_shinfo(gro_skb)->frags);
-				if (check_csum(cqe, gro_skb, va, ring->hwtstamp_rx_filter)) {
+				if (check_csum(cqe, gro_skb, va,
+					       dev->features)) {
 					ip_summed = CHECKSUM_NONE;
 					ring->csum_none++;
 					ring->csum_complete--;
@@ -951,7 +946,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		}
 
 		if (ip_summed == CHECKSUM_COMPLETE) {
-			if (check_csum(cqe, skb, skb->data, ring->hwtstamp_rx_filter)) {
+			if (check_csum(cqe, skb, skb->data, dev->features)) {
 				ip_summed = CHECKSUM_NONE;
 				ring->csum_complete--;
 				ring->csum_none++;
-- 
2.3.7
