From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/4] net/mlx4: Prepare VLAN macros for 802.1ad Hardware accelerated support
Date: Mon, 27 Jul 2015 14:46:33 +0300
Message-ID: <1437997594-8506-4-git-send-email-amirv@mellanox.com>
References: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56734 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751601AbbG0LrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 07:47:04 -0400
In-Reply-To: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

To add Hardware accelerated support in 802.1ad vlan, replace
Current VLAN macros to CVLAN.
Replace:
MLX4_WQE_CTRL_INS_VLAN
MLX4_CQE_VLAN_PRESENT_MASK
With:
MLX4_WQE_CTRL_INS_CVLAN
MLX4_CQE_CVLAN_PRESENT_MASK

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/infiniband/hw/mlx4/cq.c            | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 2 +-
 include/linux/mlx4/cq.h                    | 2 +-
 include/linux/mlx4/qp.h                    | 2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index 36eb3d0..180a8f7 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -871,7 +871,7 @@ repoll:
 		if (is_eth) {
 			wc->sl  = be16_to_cpu(cqe->sl_vid) >> 13;
 			if (be32_to_cpu(cqe->vlan_my_qpn) &
-					MLX4_CQE_VLAN_PRESENT_MASK) {
+					MLX4_CQE_CVLAN_PRESENT_MASK) {
 				wc->vlan_id = be16_to_cpu(cqe->sl_vid) &
 					MLX4_CQE_VID_MASK;
 			} else {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 12c65e1..10f6c2f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -726,7 +726,7 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
 
 	hw_checksum = csum_unfold((__force __sum16)cqe->checksum);
 
-	if (cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK) &&
+	if (cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_CVLAN_PRESENT_MASK) &&
 	    !(dev_features & NETIF_F_HW_VLAN_CTAG_RX)) {
 		hw_checksum = get_fixed_vlan_csum(hw_checksum, hdr);
 		hdr += sizeof(struct vlan_hdr);
@@ -907,7 +907,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				gro_skb->csum_level = 1;
 
 			if ((cqe->vlan_my_qpn &
-			    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)) &&
+			    cpu_to_be32(MLX4_CQE_CVLAN_PRESENT_MASK)) &&
 			    (dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
 				u16 vid = be16_to_cpu(cqe->sl_vid);
 
@@ -970,7 +970,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					PKT_HASH_TYPE_L3);
 
 		if ((be32_to_cpu(cqe->vlan_my_qpn) &
-		    MLX4_CQE_VLAN_PRESENT_MASK) &&
+		    MLX4_CQE_CVLAN_PRESENT_MASK) &&
 		    (dev->features & NETIF_F_HW_VLAN_CTAG_RX))
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(cqe->sl_vid));
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c10d98f..7c858f6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -958,7 +958,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		ring->bf.offset ^= ring->bf.buf_size;
 	} else {
 		tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
-		tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
+		tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_CVLAN *
 			!!skb_vlan_tag_present(skb);
 		tx_desc->ctrl.fence_size = real_size;
 
diff --git a/include/linux/mlx4/cq.h b/include/linux/mlx4/cq.h
index e7ecc12..899a97b 100644
--- a/include/linux/mlx4/cq.h
+++ b/include/linux/mlx4/cq.h
@@ -88,7 +88,7 @@ struct mlx4_ts_cqe {
 
 enum {
 	MLX4_CQE_L2_TUNNEL_IPOK		= 1 << 31,
-	MLX4_CQE_VLAN_PRESENT_MASK	= 1 << 29,
+	MLX4_CQE_CVLAN_PRESENT_MASK	= 1 << 29,
 	MLX4_CQE_L2_TUNNEL		= 1 << 27,
 	MLX4_CQE_L2_TUNNEL_CSUM		= 1 << 26,
 	MLX4_CQE_L2_TUNNEL_IPV4		= 1 << 25,
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 6fed539..6c61900 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -272,7 +272,7 @@ enum {
 	MLX4_WQE_CTRL_SOLICITED		= 1 << 1,
 	MLX4_WQE_CTRL_IP_CSUM		= 1 << 4,
 	MLX4_WQE_CTRL_TCP_UDP_CSUM	= 1 << 5,
-	MLX4_WQE_CTRL_INS_VLAN		= 1 << 6,
+	MLX4_WQE_CTRL_INS_CVLAN		= 1 << 6,
 	MLX4_WQE_CTRL_STRONG_ORDER	= 1 << 7,
 	MLX4_WQE_CTRL_FORCE_LOOPBACK	= 1 << 0,
 };
-- 
2.4.3.413.ga5fe668
