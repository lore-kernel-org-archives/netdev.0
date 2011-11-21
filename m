From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 8/8] net/mlx4_en: bug fix for the case of vlan id 0 and UP
 0
Date: Mon, 21 Nov 2011 10:43:58 +0200
Message-ID: <4ECA0F4E.9090304@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:48911 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756102Ab1KULTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 06:19:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

When using vlan 0 and UP 0, vlan header wasn't placed.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index f9093b5..70743a1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -566,7 +566,8 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 		inl->byte_count = cpu_to_be32(1 << 31 | (skb->len - spc));
 	}
 	tx_desc->ctrl.vlan_tag = cpu_to_be16(*vlan_tag);
-	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN * !!(*vlan_tag);
+	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
+		(!!vlan_tx_tag_present(skb));
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 }
 
@@ -677,7 +678,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Prepare ctrl segement apart opcode+ownership, which depends on
 	 * whether LSO is used */
 	tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
-	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN * !!vlan_tag;
+	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
+		!!vlan_tx_tag_present(skb);
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 	tx_desc->ctrl.srcrb_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 						MLX4_WQE_CTRL_SOLICITED);
-- 
1.7.7
