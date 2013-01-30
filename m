From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 01/11] net/mlx4_core: Directly expose fields of HW flow steering rule control segment
Date: Wed, 30 Jan 2013 12:34:17 +0200
Message-ID: <1359542067-10760-2-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:32921 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754209Ab3A3Ket (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:49 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Some of the fields for struct mlx4_net_trans_rule_hw_ctrl were packed into u32
and accessed through bit field operations. Expose and access them directly as
u8.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    7 +++++--
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    2 +-
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 1ee4db3..d7c0704 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -664,7 +664,7 @@ static void trans_rule_ctrl_to_hw(struct mlx4_net_trans_rule *ctrl,
 	dw |= ctrl->priority << 16;
 
 	hw->ctrl = cpu_to_be32(dw);
-	hw->vf_vep_port = cpu_to_be32(ctrl->port);
+	hw->port = ctrl->port;
 	hw->qpn = cpu_to_be32(ctrl->qpn);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 116c5c2..3263848 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -696,9 +696,12 @@ struct mlx4_steer {
 
 struct mlx4_net_trans_rule_hw_ctrl {
 	__be32 ctrl;
-	__be32 vf_vep_port;
+	u8 rsvd1;
+	u8 funcid;
+	u8 vep;
+	u8 port;
 	__be32 qpn;
-	__be32 reserved;
+	__be32 rsvd2;
 };
 
 struct mlx4_net_trans_rule_hw_ib {
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 561ed2a..5997adc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3018,7 +3018,7 @@ static int add_eth_header(struct mlx4_dev *dev, int slave,
 	__be64 mac_msk = cpu_to_be64(MLX4_MAC_MASK << 16);
 
 	ctrl = (struct mlx4_net_trans_rule_hw_ctrl *)inbox->buf;
-	port = be32_to_cpu(ctrl->vf_vep_port) & 0xff;
+	port = ctrl->port;
 	eth_header = (struct mlx4_net_trans_rule_hw_eth *)(ctrl + 1);
 
 	/* Clear a space in the inbox for eth header */
-- 
1.7.8.2
