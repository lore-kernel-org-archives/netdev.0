From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 05/13] ethtool,net/mlx4_en: Add 100M, 20G, 56G speeds ethtool reporting support
Date: Mon, 27 Oct 2014 11:37:39 +0200
Message-ID: <1414402667-8841-6-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34953 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752258AbaJ0Jia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:30 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Added 100M, 20G and 56G ethtool speed reporting support.
Update mlx4_en_test_speed self test with the new speeds.

Defined new link speeds in include/uapi/linux/ethtool.h:
+#define SPEED_20000	20000
+#define SPEED_40000	40000
+#define SPEED_56000	56000

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c     | 15 ++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_port.h     |  9 ++++++---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c | 12 ++++++++----
 include/uapi/linux/ethtool.h                     | 14 +++++++++++++-
 4 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 0a0261d..afd3036 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -91,15 +91,24 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port)
 	 * already synchronized, no need in locking */
 	state->link_state = !!(qport_context->link_up & MLX4_EN_LINK_UP_MASK);
 	switch (qport_context->link_speed & MLX4_EN_SPEED_MASK) {
+	case MLX4_EN_100M_SPEED:
+		state->link_speed = SPEED_100;
+		break;
 	case MLX4_EN_1G_SPEED:
-		state->link_speed = 1000;
+		state->link_speed = SPEED_1000;
 		break;
 	case MLX4_EN_10G_SPEED_XAUI:
 	case MLX4_EN_10G_SPEED_XFI:
-		state->link_speed = 10000;
+		state->link_speed = SPEED_10000;
+		break;
+	case MLX4_EN_20G_SPEED:
+		state->link_speed = SPEED_20000;
 		break;
 	case MLX4_EN_40G_SPEED:
-		state->link_speed = 40000;
+		state->link_speed = SPEED_40000;
+		break;
+	case MLX4_EN_56G_SPEED:
+		state->link_speed = SPEED_56000;
 		break;
 	default:
 		state->link_speed = -1;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.h b/drivers/net/ethernet/mellanox/mlx4/en_port.h
index 745090b..a5fc93b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.h
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.h
@@ -54,10 +54,13 @@ enum {
 };
 
 enum {
-	MLX4_EN_1G_SPEED	= 0x02,
-	MLX4_EN_10G_SPEED_XFI	= 0x01,
+	MLX4_EN_100M_SPEED	= 0x04,
 	MLX4_EN_10G_SPEED_XAUI	= 0x00,
+	MLX4_EN_10G_SPEED_XFI	= 0x01,
+	MLX4_EN_1G_SPEED	= 0x02,
+	MLX4_EN_20G_SPEED	= 0x08,
 	MLX4_EN_40G_SPEED	= 0x40,
+	MLX4_EN_56G_SPEED	= 0x20,
 	MLX4_EN_OTHER_SPEED	= 0x0f,
 };
 
@@ -68,7 +71,7 @@ struct mlx4_en_query_port_context {
 	__be16 mtu;
 	u8 reserved2;
 	u8 link_speed;
-#define MLX4_EN_SPEED_MASK	0x43
+#define MLX4_EN_SPEED_MASK	0x6f
 	u16 reserved3[5];
 	__be64 mac;
 	u8 transceiver;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 49d5afc..2d8ee66 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -129,11 +129,15 @@ static int mlx4_en_test_speed(struct mlx4_en_priv *priv)
 	if (mlx4_en_QUERY_PORT(priv->mdev, priv->port))
 		return -ENOMEM;
 
-	/* The device supports 1G, 10G and 40G speeds */
-	if (priv->port_state.link_speed != 1000 &&
-	    priv->port_state.link_speed != 10000 &&
-	    priv->port_state.link_speed != 40000)
+	/* The device supports 100M, 1G, 10G, 20G, 40G and 56G speed */
+	if (priv->port_state.link_speed != SPEED_100 &&
+	    priv->port_state.link_speed != SPEED_1000 &&
+	    priv->port_state.link_speed != SPEED_10000 &&
+	    priv->port_state.link_speed != SPEED_20000 &&
+	    priv->port_state.link_speed != SPEED_40000 &&
+	    priv->port_state.link_speed != SPEED_56000)
 		return priv->port_state.link_speed;
+
 	return 0;
 }
 
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index b6acd78..eb2095b 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1213,6 +1213,10 @@ enum ethtool_sfeatures_retval_bits {
 #define SUPPORTED_40000baseCR4_Full	(1 << 24)
 #define SUPPORTED_40000baseSR4_Full	(1 << 25)
 #define SUPPORTED_40000baseLR4_Full	(1 << 26)
+#define SUPPORTED_56000baseKR4_Full	(1 << 27)
+#define SUPPORTED_56000baseCR4_Full	(1 << 28)
+#define SUPPORTED_56000baseSR4_Full	(1 << 29)
+#define SUPPORTED_56000baseLR4_Full	(1 << 30)
 
 #define ADVERTISED_10baseT_Half		(1 << 0)
 #define ADVERTISED_10baseT_Full		(1 << 1)
@@ -1241,6 +1245,10 @@ enum ethtool_sfeatures_retval_bits {
 #define ADVERTISED_40000baseCR4_Full	(1 << 24)
 #define ADVERTISED_40000baseSR4_Full	(1 << 25)
 #define ADVERTISED_40000baseLR4_Full	(1 << 26)
+#define ADVERTISED_56000baseKR4_Full	(1 << 27)
+#define ADVERTISED_56000baseCR4_Full	(1 << 28)
+#define ADVERTISED_56000baseSR4_Full	(1 << 29)
+#define ADVERTISED_56000baseLR4_Full	(1 << 30)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
@@ -1248,12 +1256,16 @@ enum ethtool_sfeatures_retval_bits {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
+/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|10|20|40|56]GbE. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
 #define SPEED_2500		2500
 #define SPEED_10000		10000
+#define SPEED_20000		20000
+#define SPEED_40000		40000
+#define SPEED_56000		56000
+
 #define SPEED_UNKNOWN		-1
 
 /* Duplex, half or full. */
-- 
1.8.3.4
