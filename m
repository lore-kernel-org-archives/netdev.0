From: Amerigo Wang <amwang@redhat.com>
Subject: [v3 Patch 2/2] mlx4: add dynamic LRO disable support
Date: Fri, 18 Jun 2010 06:55:38 -0400
Message-ID: <20100618105945.6496.67648.sendpatchset@localhost.localdomain>
References: <20100618105935.6496.4725.sendpatchset@localhost.localdomain>
Cc: nhorman@redhat.com, sgruszka@redhat.com, herbert.xu@redhat.com,
	Amerigo Wang <amwang@redhat.com>, bhutchings@solarflare.com,
	Ramkrishna.Vepa@exar.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758462Ab0FRKzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jun 2010 06:55:44 -0400
In-Reply-To: <20100618105935.6496.4725.sendpatchset@localhost.localdomain>
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
Cc: Ben Hutchings <bhutchings@solarflare.com>

---

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index d5afd03..d68b796 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -387,6 +387,41 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
 	param->tx_pending = mdev->profile.prof[priv->port].tx_ring_size;
 }
 
+static int mlx4_ethtool_op_set_flags(struct net_device *dev, u32 data)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int rc = 0;
+	int changed = 0;
+
+	if (data & (ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH))
+		return -EOPNOTSUPP;
+
+	if (data & ETH_FLAG_LRO) {
+		if (!(dev->features & NETIF_F_LRO))
+			changed = 1;
+	} else if (dev->features & NETIF_F_LRO) {
+		changed = 1;
+		mdev->profile.num_lro = 0;
+	}
+
+	if (changed) {
+		if (netif_running(dev)) {
+			mutex_lock(&mdev->state_lock);
+			mlx4_en_stop_port(dev);
+		}
+		dev->features ^= NETIF_F_LRO;
+		if (netif_running(dev)) {
+			rc = mlx4_en_start_port(dev);
+			if (rc)
+				en_err(priv, "Failed to restart port\n");
+			mutex_unlock(&mdev->state_lock);
+		}
+	}
+
+	return rc;
+}
+
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
 	.get_settings = mlx4_en_get_settings,
@@ -415,7 +450,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_ringparam = mlx4_en_get_ringparam,
 	.set_ringparam = mlx4_en_set_ringparam,
 	.get_flags = ethtool_op_get_flags,
-	.set_flags = ethtool_op_set_flags,
+	.set_flags = mlx4_ethtool_op_set_flags,
 };
 
 
