From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 09/12] net/mlx5e: Add ethtool support for dump module EEPROM
Date: Fri, 22 Apr 2016 22:00:44 +0300
Message-ID: <1461351647-27412-10-git-send-email-saeedm@mellanox.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36888 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751850AbcDVTCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 15:02:03 -0400
In-Reply-To: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add query MCIA, PMLP registers infrastructure and commands.
Add ethtool support for get_module_info() and get_module_eeprom()
callbacks.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   80 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   76 +++++++++++++++++++
 include/linux/mlx5/driver.h                        |    3 +-
 include/linux/mlx5/port.h                          |   15 ++++
 4 files changed, 173 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index a2c444e..0518c86 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1159,6 +1159,84 @@ static int mlx5e_set_phys_id(struct net_device *dev,
 	return mlx5_set_port_beacon(mdev, beacon_duration);
 }
 
+static int mlx5e_get_module_info(struct net_device *netdev,
+				 struct ethtool_modinfo *modinfo)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *dev = priv->mdev;
+	int size_read = 0;
+	u8 data[4];
+
+	size_read = mlx5_query_module_eeprom(dev, 0, 2, data);
+	if (size_read < 2)
+		return -EIO;
+
+	/* data[0] = identifier byte */
+	switch (data[0]) {
+	case MLX5_MODULE_ID_QSFP:
+		modinfo->type       = ETH_MODULE_SFF_8436;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8436_LEN;
+		break;
+	case MLX5_MODULE_ID_QSFP_PLUS:
+	case MLX5_MODULE_ID_QSFP28:
+		/* data[1] = revision id */
+		if (data[0] == MLX5_MODULE_ID_QSFP28 || data[1] >= 0x3) {
+			modinfo->type       = ETH_MODULE_SFF_8636;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8636_LEN;
+		} else {
+			modinfo->type       = ETH_MODULE_SFF_8436;
+			modinfo->eeprom_len = ETH_MODULE_SFF_8436_LEN;
+		}
+		break;
+	case MLX5_MODULE_ID_SFP:
+		modinfo->type       = ETH_MODULE_SFF_8472;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8472_LEN;
+		break;
+	default:
+		netdev_err(priv->netdev, "%s: cable type not recognized:0x%x\n",
+			   __func__, data[0]);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int mlx5e_get_module_eeprom(struct net_device *netdev,
+				   struct ethtool_eeprom *ee,
+				   u8 *data)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int offset = ee->offset;
+	int size_read;
+	int i = 0;
+
+	if (!ee->len)
+		return -EINVAL;
+
+	memset(data, 0, ee->len);
+
+	while (i < ee->len) {
+		size_read = mlx5_query_module_eeprom(mdev, offset, ee->len - i,
+						     data + i);
+
+		if (!size_read)
+			/* Done reading */
+			return 0;
+
+		if (size_read < 0) {
+			netdev_err(priv->netdev, "%s: mlx5_query_eeprom failed:0x%x\n",
+				   __func__, size_read);
+			return 0;
+		}
+
+		i += size_read;
+		offset += size_read;
+	}
+
+	return 0;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -1186,4 +1264,6 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_phys_id       = mlx5e_set_phys_id,
 	.get_wol	   = mlx5e_get_wol,
 	.set_wol	   = mlx5e_set_wol,
+	.get_module_info   = mlx5e_get_module_info,
+	.get_module_eeprom = mlx5e_get_module_eeprom,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 446549f..4cb2a44 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -310,6 +310,82 @@ void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_oper_mtu);
 
+static int mlx5_query_module_num(struct mlx5_core_dev *dev, int *module_num)
+{
+	u32 out[MLX5_ST_SZ_DW(pmlp_reg)];
+	u32 in[MLX5_ST_SZ_DW(pmlp_reg)];
+	int module_mapping;
+	int err;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(pmlp_reg, in, local_port, 1);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out, sizeof(out),
+				   MLX5_REG_PMLP, 0, 0);
+	if (err)
+		return err;
+
+	module_mapping = MLX5_GET(pmlp_reg, out, lane0_module_mapping);
+	*module_num = module_mapping & MLX5_EEPROM_IDENTIFIER_BYTE_MASK;
+
+	return 0;
+}
+
+int mlx5_query_module_eeprom(struct mlx5_core_dev *dev,
+			     u16 offset, u16 size, u8 *data)
+{
+	u32 out[MLX5_ST_SZ_DW(mcia_reg)];
+	u32 in[MLX5_ST_SZ_DW(mcia_reg)];
+	int module_num;
+	u16 i2c_addr;
+	int status;
+	int err;
+	void *ptr = MLX5_ADDR_OF(mcia_reg, out, dword_0);
+
+	err = mlx5_query_module_num(dev, &module_num);
+	if (err)
+		return err;
+
+	memset(in, 0, sizeof(in));
+	size = min_t(int, size, MLX5_EEPROM_MAX_BYTES);
+
+	if (offset < MLX5_EEPROM_PAGE_LENGTH &&
+	    offset + size > MLX5_EEPROM_PAGE_LENGTH)
+		/* Cross pages read, read until offset 256 in low page */
+		size -= offset + size - MLX5_EEPROM_PAGE_LENGTH;
+
+	i2c_addr = MLX5_I2C_ADDR_LOW;
+	if (offset >= MLX5_EEPROM_PAGE_LENGTH) {
+		i2c_addr = MLX5_I2C_ADDR_HIGH;
+		offset -= MLX5_EEPROM_PAGE_LENGTH;
+	}
+
+	MLX5_SET(mcia_reg, in, l, 0);
+	MLX5_SET(mcia_reg, in, module, module_num);
+	MLX5_SET(mcia_reg, in, i2c_device_address, i2c_addr);
+	MLX5_SET(mcia_reg, in, page_number, 0);
+	MLX5_SET(mcia_reg, in, device_address, offset);
+	MLX5_SET(mcia_reg, in, size, size);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_MCIA, 0, 0);
+	if (err)
+		return err;
+
+	status = MLX5_GET(mcia_reg, out, status);
+	if (status) {
+		mlx5_core_err(dev, "query_mcia_reg failed: status: 0x%x\n",
+			      status);
+		return -EIO;
+	}
+
+	memcpy(data, ptr, size);
+
+	return size;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_module_eeprom);
+
 static int mlx5_query_port_pvlc(struct mlx5_core_dev *dev, u32 *pvlc,
 				int pvlc_size,  u8 local_port)
 {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 2e8758d..1a17067 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -113,9 +113,10 @@ enum {
 	MLX5_REG_PELC		 = 0x500e,
 	MLX5_REG_PVLC		 = 0x500f,
 	MLX5_REG_PCMR		 = 0x5041,
-	MLX5_REG_PMLP		 = 0, /* TBD */
+	MLX5_REG_PMLP		 = 0x5002,
 	MLX5_REG_NODE_DESC	 = 0x6001,
 	MLX5_REG_HOST_ENDIANNESS = 0x7004,
+	MLX5_REG_MCIA		 = 0x9014,
 	MLX5_REG_MLCR		 = 0x902b,
 };
 
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index a364ab1..7391eb8 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -40,6 +40,19 @@ enum mlx5_beacon_duration {
 	MLX5_BEACON_DURATION_INF = 0xffff,
 };
 
+enum mlx5_module_id {
+	MLX5_MODULE_ID_SFP              = 0x3,
+	MLX5_MODULE_ID_QSFP             = 0xC,
+	MLX5_MODULE_ID_QSFP_PLUS        = 0xD,
+	MLX5_MODULE_ID_QSFP28           = 0x11,
+};
+
+#define MLX5_EEPROM_MAX_BYTES			32
+#define MLX5_EEPROM_IDENTIFIER_BYTE_MASK	0x000000ff
+#define MLX5_I2C_ADDR_LOW		0x50
+#define MLX5_I2C_ADDR_HIGH		0x51
+#define MLX5_EEPROM_PAGE_LENGTH		256
+
 int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps);
 int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
 			 int ptys_size, int proto_mask, u8 local_port);
@@ -93,5 +106,7 @@ int mlx5_query_port_wol(struct mlx5_core_dev *mdev, u8 *wol_mode);
 int mlx5_set_port_fcs(struct mlx5_core_dev *mdev, u8 enable);
 void mlx5_query_port_fcs(struct mlx5_core_dev *mdev, bool *supported,
 			 bool *enabled);
+int mlx5_query_module_eeprom(struct mlx5_core_dev *dev,
+			     u16 offset, u16 size, u8 *data);
 
 #endif /* __MLX5_PORT_H__ */
-- 
1.7.1
