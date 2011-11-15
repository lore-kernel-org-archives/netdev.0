From: Amir Vadai <amirv@dev.mellanox.co.il>
Subject: [PATCH 2/3] net/mlx4_en: adding loopback support
Date: Tue, 15 Nov 2011 11:14:05 +0200
Message-ID: <1321348446-29605-3-git-send-email-amirv@mellanox.com>
References: <1321348446-29605-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Oren Duer <oren@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46441 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab1KOJOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 04:14:36 -0500
Received: by fagn18 with SMTP id n18so145653fag.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 01:14:35 -0800 (PST)
In-Reply-To: <1321348446-29605-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Device must be in promiscious mode or DMAC must be same as the host MAC, or
else packet will be dropped by the HW rx filtering.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    2 ++
 include/linux/mlx4/qp.h                        |    1 +
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 78d776b..55f88a7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1084,7 +1084,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	dev->vlan_features = dev->hw_features;
 
-	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH;
+	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_LOOPBACK;
 	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
 			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 			NETIF_F_HW_VLAN_FILTER;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index d901b42..9b4ca4c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -680,6 +680,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 	tx_desc->ctrl.srcrb_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 						MLX4_WQE_CTRL_SOLICITED);
+	if (dev->features & NETIF_F_LOOPBACK)
+		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_FORCE_LOOPBACK);
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
 							 MLX4_WQE_CTRL_TCP_UDP_CSUM);
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 48cc4cb..804a738 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -183,6 +183,7 @@ struct mlx4_wqe_ctrl_seg {
 	 * [4]   IP checksum
 	 * [3:2] C (generate completion queue entry)
 	 * [1]   SE (solicited event)
+	 * [0]   FL (force loopback)
 	 */
 	__be32			srcrb_flags;
 	/*
-- 
1.7.5.4
