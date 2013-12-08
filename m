From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 06/12] net/mlx4_en: Implement ndo_get_phys_port_id
Date: Sun,  8 Dec 2013 14:35:46 +0200
Message-ID: <1386506152-10298-7-git-send-email-amirv@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59489 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754686Ab3LHMgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 07:36:14 -0500
In-Reply-To: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Use the port GUID read from the firmware to identify the physical port.
This port identifier is available via ndo_get_phys_port_id for both PF
and VF net-devices.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9270006..44a1cc2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2168,6 +2168,27 @@ static int mlx4_en_set_vf_link_state(struct net_device *dev, int vf, int link_st
 
 	return mlx4_set_vf_link_state(mdev->dev, en_priv->port, vf, link_state);
 }
+
+#define PORT_ID_BYTE_LEN 8
+static int mlx4_en_get_phys_port_id(struct net_device *dev,
+				    struct netdev_phys_port_id *ppid)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_dev *mdev = priv->mdev->dev;
+	int i;
+	u64 phys_port_id = mdev->caps.phys_port_id[priv->port];
+
+	if (!phys_port_id)
+		return -EOPNOTSUPP;
+
+	ppid->id_len = sizeof(phys_port_id);
+	for (i = PORT_ID_BYTE_LEN - 1; i >= 0; --i) {
+		ppid->id[i] =  phys_port_id & 0xff;
+		phys_port_id >>= 8;
+	}
+	return 0;
+}
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2193,6 +2214,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= mlx4_en_low_latency_recv,
 #endif
+	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
 };
 
 static const struct net_device_ops mlx4_netdev_ops_master = {
@@ -2221,6 +2243,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
+	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
 };
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
-- 
1.8.3.4
