From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_en: Don't attempt to TX offload the outer UDP checksum for VXLAN
Date: Thu, 30 Oct 2014 15:59:27 +0200
Message-ID: <1414677568-28409-2-git-send-email-ogerlitz@mellanox.com>
References: <1414677568-28409-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40204 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758423AbaJ3N7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 09:59:33 -0400
In-Reply-To: <1414677568-28409-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For VXLAN/NVGRE encapsulation, the current HW doesn't support offloading
both the outer UDP TX checksum and the inner TCP/UDP TX checksum. 

The driver doesn't advertize SKB_GSO_UDP_TUNNEL_CSUM, however we are wrongly
telling the HW to offload the outer UDP checksum for encapsulated packets,
fix that.

Fixes: 837052d0ccc5 ('net/mlx4_en: Add netdev support for TCP/IP
		     offloads of vxlan tunneling')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 34c1378..454d9fe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -836,8 +836,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * whether LSO is used */
 	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
-		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
-							 MLX4_WQE_CTRL_TCP_UDP_CSUM);
+		if (!skb->encapsulation)
+			tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
+								 MLX4_WQE_CTRL_TCP_UDP_CSUM);
+		else
+			tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM);
 		ring->tx_csum++;
 	}
 
-- 
1.7.1
