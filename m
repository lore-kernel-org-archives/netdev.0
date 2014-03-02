From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 8/9] net/mlx4_en: Use union for BlueFlame WQE
Date: Sun,  2 Mar 2014 10:25:04 +0200
Message-ID: <1393748705-1685-9-git-send-email-amirv@mellanox.com>
References: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52984 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751660AbaCBIZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2014 03:25:30 -0500
In-Reply-To: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When BlueFlame is turned on, control segment of the TX WQE is changed,
and the second line of it is used for QPN.
Changed code to use a union in the mlx4_wqe_ctrl_seg instead of casting.
This makes the code clearer and solves the static checker warning:

drivers/net/ethernet/mellanox/mlx4/en_tx.c:839 mlx4_en_xmit()
	warn: potential memory corrupting cast 4 vs 2 bytes

CC: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |  3 ++-
 include/linux/mlx4/qp.h                    | 11 ++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 56e8fbc..69c2fce 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -876,7 +876,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_tx_timestamp(skb);
 
 	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tx_tag_present(skb)) {
-		*(__be32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
+		tx_desc->ctrl.bf_qpn |= cpu_to_be32(ring->doorbell_qpn);
+
 		op_own |= htonl((bf_index & 0xffff) << 8);
 		/* Ensure new descirptor hits memory
 		* before setting ownership of this descriptor to HW */
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 59f8ba8..b66e761 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -270,9 +270,14 @@ enum {
 
 struct mlx4_wqe_ctrl_seg {
 	__be32			owner_opcode;
-	__be16			vlan_tag;
-	u8			ins_vlan;
-	u8			fence_size;
+	union {
+		struct {
+			__be16			vlan_tag;
+			u8			ins_vlan;
+			u8			fence_size;
+		};
+		__be32			bf_qpn;
+	};
 	/*
 	 * High 24 bits are SRC remote buffer; low 8 bits are flags:
 	 * [7]   SO (strong ordering)
-- 
1.8.3.4
