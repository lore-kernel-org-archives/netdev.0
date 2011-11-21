From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 7/8] net/mlx4_en: adding loopback support
Date: Mon, 21 Nov 2011 10:43:54 +0200
Message-ID: <4ECA0F4A.30308@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:55694 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756179Ab1KULTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 06:19:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Device must be in promiscious mode or DMAC must be same as the host MAC, or
else packet will be dropped by the HW rx filtering.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    3 +++
 include/linux/mlx4/qp.h                        |    1 +
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 78d776b..55fdbce 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1088,6 +1088,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
 			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 			NETIF_F_HW_VLAN_FILTER;
+	dev->hw_features |= NETIF_F_LOOPBACK;
 
 	mdev->pndev[port] = dev;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 3094f94..f9093b5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -681,6 +681,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 	tx_desc->ctrl.srcrb_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 						MLX4_WQE_CTRL_SOLICITED);
+	if (dev->features & NETIF_F_LOOPBACK)
+		tx_desc->ctrl.srcrb_flags |=
+			cpu_to_be32(MLX4_WQE_CTRL_FORCE_LOOPBACK);
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
 							 MLX4_WQE_CTRL_TCP_UDP_CSUM);
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 6562ff6..bee8fa2 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -210,6 +210,7 @@ struct mlx4_wqe_ctrl_seg {
 	 * [4]   IP checksum
 	 * [3:2] C (generate completion queue entry)
 	 * [1]   SE (solicited event)
+	 * [0]   FL (force loopback)
 	 */
 	__be32			srcrb_flags;
 	/*
-- 
1.7.7
