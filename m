From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/6] net/mlx4: Add support to get VF config
Date: Wed, 24 Apr 2013 19:41:14 +0300
Message-ID: <1366821674-17902-7-git-send-email-ogerlitz@mellanox.com>
References: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:44263 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757100Ab3DXQlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 12:41:23 -0400
In-Reply-To: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Support getting VF config.

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c       |   32 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 ++++++
 include/linux/mlx4/cmd.h                       |    2 +
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 993b51d..5c6bfd6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2153,3 +2153,35 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 }
 EXPORT_SYMBOL_GPL(mlx4_set_vf_vlan);
 
+int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_info *ivf)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_vport_state *s_info;
+	int slave;
+
+	if (!mlx4_is_master(dev))
+		return -EPROTONOSUPPORT;
+
+	slave = mlx4_get_slave_indx(dev, vf);
+	if (slave < 0)
+		return -EINVAL;
+
+	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
+	ivf->vf = vf;
+
+	/* need to convert it to a func */
+	ivf->mac[0] = ((s_info->mac >> (5*8)) & 0xff);
+	ivf->mac[1] = ((s_info->mac >> (4*8)) & 0xff);
+	ivf->mac[2] = ((s_info->mac >> (3*8)) & 0xff);
+	ivf->mac[3] = ((s_info->mac >> (2*8)) & 0xff);
+	ivf->mac[4] = ((s_info->mac >> (1*8)) & 0xff);
+	ivf->mac[5] = ((s_info->mac)  & 0xff);
+
+	ivf->vlan	= s_info->default_vlan;
+	ivf->qos	= s_info->default_qos;
+	ivf->tx_rate	= s_info->tx_rate;
+	ivf->spoofchk	= s_info->spoofchk;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx4_get_vf_config);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9db9925..cf77737 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1961,6 +1961,13 @@ static int mlx4_en_set_vf_spoofchk(struct net_device *dev, int vf, bool setting)
 	return mlx4_set_vf_spoofchk(mdev->dev, en_priv->port, vf, setting);
 }
 
+static int mlx4_en_get_vf_config(struct net_device *dev, int vf, struct ifla_vf_info *ivf)
+{
+	struct mlx4_en_priv *en_priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = en_priv->mdev;
+
+	return mlx4_get_vf_config(mdev->dev, en_priv->port, vf, ivf);
+}
 
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
@@ -2001,6 +2008,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_set_vf_mac		= mlx4_en_set_vf_mac,
 	.ndo_set_vf_vlan	= mlx4_en_set_vf_vlan,
 	.ndo_set_vf_spoofchk	= mlx4_en_set_vf_spoofchk,
+	.ndo_get_vf_config	= mlx4_en_get_vf_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= mlx4_en_netpoll,
 #endif
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 95c3223..adf6e06 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -34,6 +34,7 @@
 #define MLX4_CMD_H
 
 #include <linux/dma-mapping.h>
+#include <linux/if_link.h>
 
 enum {
 	/* initialization and general commands */
@@ -235,6 +236,7 @@ u32 mlx4_comm_get_version(void);
 int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac);
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos);
 int mlx4_set_vf_spoofchk(struct mlx4_dev *dev, int port, int vf, bool setting);
+int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_info *ivf);
 
 
 #define MLX4_COMM_GET_IF_REV(cmd_chan_ver) (u8)((cmd_chan_ver) >> 8)
-- 
1.7.1
