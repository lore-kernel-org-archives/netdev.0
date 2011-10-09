From: Alexander Guller <alexg@mellanox.com>
Subject: [PATCH 7/7] mlx4_en: Adding 40gb speed report for ethtool
Date: Sun, 9 Oct 2011 17:29:42 +0200
Message-ID: <4E91BDE6.2000901@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexg@mellanox.com>,
	<yevgenyp@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53838 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751893Ab1JIP3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 11:29:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Query port will now identify a 40G Ethernet speed.

Signed-off-by: Alexander Guller <alexg@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c |   16 +++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_port.h |   11 +++++++++--
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 8824309..9d27555 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -167,11 +167,21 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port)
 	/* This command is always accessed from Ethtool context
 	 * already synchronized, no need in locking */
 	state->link_state = !!(qport_context->link_up & MLX4_EN_LINK_UP_MASK);
-	if ((qport_context->link_speed & MLX4_EN_SPEED_MASK) ==
-	    MLX4_EN_1G_SPEED)
+	switch (qport_context->link_speed & MLX4_EN_SPEED_MASK) {
+	case MLX4_EN_1G_SPEED:
 		state->link_speed = 1000;
-	else
+		break;
+	case MLX4_EN_10G_SPEED_XAUI:
+	case MLX4_EN_10G_SPEED_XFI:
 		state->link_speed = 10000;
+		break;
+	case MLX4_EN_40G_SPEED:
+		state->link_speed = 40000;
+		break;
+	default:
+		state->link_speed = -1;
+		break;
+	}
 	state->transciver = qport_context->transceiver;
 
 out:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.h b/drivers/net/ethernet/mellanox/mlx4/en_port.h
index e3d73e4..19eb244 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.h
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.h
@@ -94,6 +94,14 @@ enum {
 	MLX4_MCAST_ENABLE       = 2,
 };
 
+enum {
+	MLX4_EN_1G_SPEED	= 0x02,
+	MLX4_EN_10G_SPEED_XFI	= 0x01,
+	MLX4_EN_10G_SPEED_XAUI	= 0x00,
+	MLX4_EN_40G_SPEED	= 0x40,
+	MLX4_EN_OTHER_SPEED	= 0x0f,
+};
+
 struct mlx4_en_query_port_context {
 	u8 link_up;
 #define MLX4_EN_LINK_UP_MASK	0x80
@@ -101,8 +109,7 @@ struct mlx4_en_query_port_context {
 	__be16 mtu;
 	u8 reserved2;
 	u8 link_speed;
-#define MLX4_EN_SPEED_MASK	0x3
-#define MLX4_EN_1G_SPEED	0x2
+#define MLX4_EN_SPEED_MASK	0x43
 	u16 reserved3[5];
 	__be64 mac;
 	u8 transceiver;
-- 
1.7.5.4
