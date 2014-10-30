From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/8] net/mlx4_en: Remove redundant code from RX/GRO path
Date: Thu, 30 Oct 2014 18:06:53 +0200
Message-ID: <1414685216-28907-6-git-send-email-ogerlitz@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39650 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759437AbaJ3QHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:07:06 -0400
In-Reply-To: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the code which goes through napi_gro_frags() on the RX path,
use only napi_gro_receive().

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   54 ----------------------------
 1 files changed, 0 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 9d616a8..2a29a1a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -746,60 +746,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
 			    (cqe->checksum == cpu_to_be16(0xffff))) {
 				ring->csum_ok++;
-				/* This packet is eligible for GRO if it is:
-				 * - DIX Ethernet (type interpretation)
-				 * - TCP/IP (v4)
-				 * - without IP options
-				 * - not an IP fragment
-				 * - no LLS polling in progress
-				 */
-				if (!mlx4_en_cq_busy_polling(cq) &&
-				    (dev->features & NETIF_F_GRO)) {
-					struct sk_buff *gro_skb = napi_get_frags(&cq->napi);
-					if (!gro_skb)
-						goto next;
-
-					nr = mlx4_en_complete_rx_desc(priv,
-						rx_desc, frags, gro_skb,
-						length);
-					if (!nr)
-						goto next;
-
-					skb_shinfo(gro_skb)->nr_frags = nr;
-					gro_skb->len = length;
-					gro_skb->data_len = length;
-					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
-
-					if (l2_tunnel)
-						gro_skb->csum_level = 1;
-					if ((cqe->vlan_my_qpn &
-					    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)) &&
-					    (dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
-						u16 vid = be16_to_cpu(cqe->sl_vid);
-
-						__vlan_hwaccel_put_tag(gro_skb, htons(ETH_P_8021Q), vid);
-					}
-
-					if (dev->features & NETIF_F_RXHASH)
-						skb_set_hash(gro_skb,
-							     be32_to_cpu(cqe->immed_rss_invalid),
-							     PKT_HASH_TYPE_L3);
-
-					skb_record_rx_queue(gro_skb, cq->ring);
-					skb_mark_napi_id(gro_skb, &cq->napi);
-
-					if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
-						timestamp = mlx4_en_get_cqe_ts(cqe);
-						mlx4_en_fill_hwtstamps(mdev,
-								       skb_hwtstamps(gro_skb),
-								       timestamp);
-					}
-
-					napi_gro_frags(&cq->napi);
-					goto next;
-				}
-
-				/* GRO not possible, complete processing here */
 				ip_summed = CHECKSUM_UNNECESSARY;
 			} else {
 				ip_summed = CHECKSUM_NONE;
-- 
1.7.1
