From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/6] net/mlx4_core: Enable single ported IB VFs
Date: Thu, 21 May 2015 15:14:10 +0300
Message-ID: <1432210450-23408-7-git-send-email-ogerlitz@mellanox.com>
References: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:56599 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755792AbbEUMPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 08:15:00 -0400
In-Reply-To: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the limitation that disallows configuring single ported VFs
in the presence of IB ports, after addressing the issues that
prevented that to work.

SMI (QP0) requests/responses are still not supported for single
ported IB VFs.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  |   11 +++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c |   12 ------------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 153fb15..7761045 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -3194,6 +3194,12 @@ int mlx4_vf_set_enable_smi_admin(struct mlx4_dev *dev, int slave, int port,
 				 int enabled)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_active_ports actv_ports = mlx4_get_active_ports(
+			&priv->dev, slave);
+	int min_port = find_first_bit(actv_ports.ports,
+				      priv->dev.caps.num_ports) + 1;
+	int max_port = min_port - 1 +
+		bitmap_weight(actv_ports.ports, priv->dev.caps.num_ports);
 
 	if (slave == mlx4_master_func_num(dev))
 		return 0;
@@ -3203,6 +3209,11 @@ int mlx4_vf_set_enable_smi_admin(struct mlx4_dev *dev, int slave, int port,
 	    enabled < 0 || enabled > 1)
 		return -EINVAL;
 
+	if (min_port == max_port && dev->caps.num_ports > 1) {
+		mlx4_info(dev, "SMI access disallowed for single ported VFs\n");
+		return -EPROTONOSUPPORT;
+	}
+
 	priv->mfunc.master.vf_admin[slave].enable_smi[port] = enabled;
 	return 0;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index ced5eca..70d33f6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2988,18 +2988,6 @@ slave_start:
 	/* In master functions, the communication channel must be initialized
 	 * after obtaining its address from fw */
 	if (mlx4_is_master(dev)) {
-		int ib_ports = 0;
-
-		mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
-			ib_ports++;
-
-		if (ib_ports &&
-		    (num_vfs_argc > 1 || probe_vfs_argc > 1)) {
-			mlx4_err(dev,
-				 "Invalid syntax of num_vfs/probe_vfs with IB port - single port VFs syntax is only supported when all ports are configured as ethernet\n");
-			err = -EINVAL;
-			goto err_close;
-		}
 		if (dev->caps.num_ports < 2 &&
 		    num_vfs_argc > 1) {
 			err = -EINVAL;
-- 
1.7.1
