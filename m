From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 09/14] mlx4_en: Fixing report in Ethtool get_settings
Date: Tue, 24 Aug 2010 16:46:23 +0300
Message-ID: <4C73CD2F.3080500@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50137 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755271Ab0HXNq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The report now based on query from FW, giving the correct tranciever type
and link speed.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_ethtool.c |   27 +++++++++++++++++++++++++--
 drivers/net/mlx4/fw.c         |    9 +++++++++
 drivers/net/mlx4/fw.h         |    4 ++++
 drivers/net/mlx4/main.c       |    4 ++++
 include/linux/mlx4/device.h   |    4 ++++
 5 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 49a7003..13e20c6 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -244,16 +244,39 @@ static void mlx4_en_get_strings(struct net_device *dev,
 
 static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int trans_type;
+
 	cmd->autoneg = AUTONEG_DISABLE;
 	cmd->supported = SUPPORTED_10000baseT_Full;
-	cmd->advertising = ADVERTISED_1000baseT_Full;
+	cmd->advertising = ADVERTISED_10000baseT_Full;
+
+	if (mlx4_en_QUERY_PORT(priv->mdev, priv->port))
+		return -ENOMEM;
+
+	trans_type = priv->port_state.transciver;
 	if (netif_carrier_ok(dev)) {
-		cmd->speed = SPEED_10000;
+		cmd->speed = priv->port_state.link_speed;
 		cmd->duplex = DUPLEX_FULL;
 	} else {
 		cmd->speed = -1;
 		cmd->duplex = -1;
 	}
+
+	if (trans_type > 0 && trans_type <= 0xC) {
+		cmd->port = PORT_FIBRE;
+		cmd->transceiver = XCVR_EXTERNAL;
+		cmd->supported |= SUPPORTED_FIBRE;
+		cmd->advertising |= ADVERTISED_FIBRE;
+	} else if (trans_type == 0x80 || trans_type == 0) {
+		cmd->port = PORT_TP;
+		cmd->transceiver = XCVR_INTERNAL;
+		cmd->supported |= SUPPORTED_TP;
+		cmd->advertising |= ADVERTISED_TP;
+	} else  {
+		cmd->port = -1;
+		cmd->transceiver = -1;
+	}
 	return 0;
 }
 
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index a87bf3c..515c634 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -141,6 +141,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	struct mlx4_cmd_mailbox *mailbox;
 	u32 *outbox;
 	u8 field;
+	u32 field32;
 	u16 size;
 	u16 stat_rate;
 	int err;
@@ -368,6 +369,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_PORT_MAX_MACVLAN_OFFSET		0x0a
 #define QUERY_PORT_MAX_VL_OFFSET		0x0b
 #define QUERY_PORT_MAC_OFFSET			0x10
+#define QUERY_PORT_TRANS_VENDOR_OFFSET		0x18
+#define QUERY_PORT_WAVELENGTH_OFFSET		0x1c
+#define QUERY_PORT_TRANS_CODE_OFFSET		0x20
 
 		for (i = 1; i <= dev_cap->num_ports; ++i) {
 			err = mlx4_cmd_box(dev, 0, mailbox->dma, i, 0, MLX4_CMD_QUERY_PORT,
@@ -391,6 +395,11 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 			dev_cap->log_max_vlans[i] = field >> 4;
 			MLX4_GET(dev_cap->eth_mtu[i], outbox, QUERY_PORT_ETH_MTU_OFFSET);
 			MLX4_GET(dev_cap->def_mac[i], outbox, QUERY_PORT_MAC_OFFSET);
+			MLX4_GET(field32, outbox, QUERY_PORT_TRANS_VENDOR_OFFSET);
+			dev_cap->trans_type[i] = field32 >> 24;
+			dev_cap->vendor_oui[i] = field32 & 0xffffff;
+			MLX4_GET(dev_cap->wavelength[i], outbox, QUERY_PORT_WAVELENGTH_OFFSET);
+			MLX4_GET(dev_cap->trans_code[i], outbox, QUERY_PORT_TRANS_CODE_OFFSET);
 		}
 	}
 
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index 2cc1ba5..443e456 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -73,6 +73,10 @@ struct mlx4_dev_cap {
 	int max_pkeys[MLX4_MAX_PORTS + 1];
 	u64 def_mac[MLX4_MAX_PORTS + 1];
 	u16 eth_mtu[MLX4_MAX_PORTS + 1];
+	int trans_type[MLX4_MAX_PORTS + 1];
+	int vendor_oui[MLX4_MAX_PORTS + 1];
+	u16 wavelength[MLX4_MAX_PORTS + 1];
+	u64 trans_code[MLX4_MAX_PORTS + 1];
 	u16 stat_rate_support;
 	int loopback_support;
 	u32 flags;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 7390cdb..f4791fa 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -184,6 +184,10 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev->caps.eth_mtu_cap[i]    = dev_cap->eth_mtu[i];
 		dev->caps.def_mac[i]        = dev_cap->def_mac[i];
 		dev->caps.supported_type[i] = dev_cap->supported_port_types[i];
+		dev->caps.trans_type[i]	    = dev_cap->trans_type[i];
+		dev->caps.vendor_oui[i]     = dev_cap->vendor_oui[i];
+		dev->caps.wavelength[i]     = dev_cap->wavelength[i];
+		dev->caps.trans_code[i]     = dev_cap->trans_code[i];
 	}
 
 	dev->caps.num_uars	     = dev_cap->uar_size / PAGE_SIZE;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 2cec587..2a36a34 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -186,6 +186,10 @@ struct mlx4_caps {
 	int			eth_mtu_cap[MLX4_MAX_PORTS + 1];
 	int			gid_table_len[MLX4_MAX_PORTS + 1];
 	int			pkey_table_len[MLX4_MAX_PORTS + 1];
+	int			trans_type[MLX4_MAX_PORTS + 1];
+	int			vendor_oui[MLX4_MAX_PORTS + 1];
+	int			wavelength[MLX4_MAX_PORTS + 1];
+	u64			trans_code[MLX4_MAX_PORTS + 1];
 	int			local_ca_ack_delay;
 	int			num_uars;
 	int			bf_reg_size;
-- 
1.6.1.3


