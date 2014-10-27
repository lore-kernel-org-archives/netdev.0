From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 02/13] ethtool,net/mlx4_en: Cable info, get_module_info/eeprom ethtool support
Date: Mon, 27 Oct 2014 11:37:36 +0200
Message-ID: <1414402667-8841-3-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:32862 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752270AbaJ0Jia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:30 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Added support for get_module_info/get_module_eeprom ethtool support for cable info reading.

Added new cable types enum in include/uapi/linux/ethtool.h for ethtool use.
+#define ETH_MODULE_SFF_8636            0x3
+#define ETH_MODULE_SFF_8636_LEN        256
+#define ETH_MODULE_SFF_8436            0x4
+#define ETH_MODULE_SFF_8436_LEN        256

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 83 +++++++++++++++++++++++++
 include/uapi/linux/ethtool.h                    |  4 ++
 2 files changed, 87 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index ae83da9..279f423 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -35,6 +35,7 @@
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/mlx4/driver.h>
+#include <linux/mlx4/device.h>
 #include <linux/in.h>
 #include <net/ip.h>
 
@@ -1309,6 +1310,86 @@ static int mlx4_en_set_tunable(struct net_device *dev,
 	return ret;
 }
 
+static int mlx4_en_get_module_info(struct net_device *dev,
+				   struct ethtool_modinfo *modinfo)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int ret;
+	u8 data[4];
+
+	/* Read first 2 bytes to get Module & REV ID */
+	ret = mlx4_get_module_info(mdev->dev, priv->port,
+				   0/*offset*/, 2/*size*/, data);
+	if (ret < 2)
+		return -EIO;
+
+	switch (data[0] /* identifier */) {
+	case MLX4_MODULE_ID_QSFP:
+		modinfo->type = ETH_MODULE_SFF_8436;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8436_LEN;
+		break;
+	case MLX4_MODULE_ID_QSFP_PLUS:
+		if (data[1] >= 0x3) { /* revision id */
+			modinfo->type = ETH_MODULE_SFF_8636;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8636_LEN;
+		} else {
+			modinfo->type = ETH_MODULE_SFF_8436;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8436_LEN;
+		}
+		break;
+	case MLX4_MODULE_ID_QSFP28:
+		modinfo->type = ETH_MODULE_SFF_8636;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8636_LEN;
+		break;
+	case MLX4_MODULE_ID_SFP:
+		modinfo->type = ETH_MODULE_SFF_8472;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8472_LEN;
+		break;
+	default:
+		return -ENOSYS;
+	}
+
+	return 0;
+}
+
+static int mlx4_en_get_module_eeprom(struct net_device *dev,
+				     struct ethtool_eeprom *ee,
+				     u8 *data)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int offset = ee->offset;
+	int i = 0, ret;
+
+	if (ee->len == 0)
+		return -EINVAL;
+
+	memset(data, 0, ee->len);
+
+	while (i < ee->len) {
+		en_dbg(DRV, priv,
+		       "mlx4_get_module_info i(%d) offset(%d) len(%d)\n",
+		       i, offset, ee->len - i);
+
+		ret = mlx4_get_module_info(mdev->dev, priv->port,
+					   offset, ee->len - i, data + i);
+
+		if (!ret) /* Done reading */
+			return 0;
+
+		if (ret < 0) {
+			en_err(priv,
+			       "mlx4_get_module_info i(%d) offset(%d) bytes_to_read(%d) - FAILED (0x%x)\n",
+			       i, offset, ee->len - i, ret);
+			return 0;
+		}
+
+		i += ret;
+		offset += ret;
+	}
+	return 0;
+}
 
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
@@ -1341,6 +1422,8 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_priv_flags = mlx4_en_get_priv_flags,
 	.get_tunable		= mlx4_en_get_tunable,
 	.set_tunable		= mlx4_en_set_tunable,
+	.get_module_info = mlx4_en_get_module_info,
+	.get_module_eeprom = mlx4_en_get_module_eeprom
 };
 
 
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 99b4305..b6acd78 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1343,6 +1343,10 @@ enum ethtool_sfeatures_retval_bits {
 #define ETH_MODULE_SFF_8079_LEN		256
 #define ETH_MODULE_SFF_8472		0x2
 #define ETH_MODULE_SFF_8472_LEN		512
+#define ETH_MODULE_SFF_8636		0x3
+#define ETH_MODULE_SFF_8636_LEN		256
+#define ETH_MODULE_SFF_8436		0x4
+#define ETH_MODULE_SFF_8436_LEN		256
 
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
-- 
1.8.3.4
