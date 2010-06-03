From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Wed, 2 Jun 2010 23:39:09 -0400
Message-ID: <20100603034312.5305.61000.sendpatchset@localhost.localdomain>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>
Cc: herbert.xu@redhat.com, nhorman@redhat.com, sgruszka@redhat.com,
	Amerigo Wang <amwang@redhat.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933779Ab0FCDjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 23:39:12 -0400
In-Reply-To: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds dynamic LRO diable support for mlx4 net driver.
It also fixes a bug of mlx4, which checks NETIF_F_LRO flag in rx
path without rtnl lock.

I don't have mlx4 card, so only did compiling test. Anyone who wants
to test this is more than welcome.

This is based on Neil's initial work too.

Signed-off-by: WANG Cong <amwang@redhat.com>
Signed-off-by: Neil Horman <nhorman@redhat.com>
Acked-by: Neil Horman <nhorman@redhat.com>
Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>


---
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index d5afd03..46cd049 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -387,6 +387,39 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
 	param->tx_pending = mdev->profile.prof[priv->port].tx_ring_size;
 }
 
+static int mlx4_ethtool_op_set_flags(struct net_device *dev, u32 data)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int rc = 0;
+	int changed = 0;
+	static int old_num_lro;
+
+	if (data & ETH_FLAG_LRO) {
+		if (!(dev->features & NETIF_F_LRO)) {
+			dev->features |= NETIF_F_LRO;
+			changed = 1;
+			mdev->profile.num_lro = old_num_lro;
+		}
+	} else if (dev->features & NETIF_F_LRO) {
+		dev->features &= ~NETIF_F_LRO;
+		changed = 1;
+		old_num_lro = mdev->profile.num_lro;
+		mdev->profile.num_lro = 0;
+	}
+
+	if (changed && netif_running(dev)) {
+		mutex_lock(&mdev->state_lock);
+		mlx4_en_stop_port(dev);
+		rc = mlx4_en_start_port(dev);
+		if (rc)
+			en_err(priv, "Failed to restart port\n");
+		mutex_unlock(&mdev->state_lock);
+	}
+
+	return rc;
+}
+
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
 	.get_settings = mlx4_en_get_settings,
@@ -415,7 +448,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_ringparam = mlx4_en_get_ringparam,
 	.set_ringparam = mlx4_en_set_ringparam,
 	.get_flags = ethtool_op_get_flags,
-	.set_flags = ethtool_op_set_flags,
+	.set_flags = mlx4_ethtool_op_set_flags,
 };
 
 
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 8e2fcb7..10f50ef 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -609,7 +609,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				 * - without IP options
 				 * - not an IP fragment */
 				if (mlx4_en_can_lro(cqe->status) &&
-				    dev->features & NETIF_F_LRO) {
+				    priv->mdev->profile.num_lro) {
 
 					nr = mlx4_en_complete_rx_desc(
 						priv, rx_desc,
