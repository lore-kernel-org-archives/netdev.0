From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/9] net/mlx4_core: Set device configuration data to be persistent across reset
Date: Wed, 21 Jan 2015 16:45:50 +0200
Message-ID: <1421851557-12084-3-git-send-email-ogerlitz@mellanox.com>
References: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43066 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752584AbbAUOrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 09:47:03 -0500
In-Reply-To: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

When an HCA enters an internal error state, this is detected by the driver.
The driver then should reset the HCA and restart the software stack.

Keep ports information and some SRIOV configuration in a persistent area
to have it valid across reset.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   45 +++++++++++++++++++++++++++-
 include/linux/mlx4/device.h               |    2 +
 2 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index abcee61..2c5a555 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -3109,18 +3109,34 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	return ret;
 }
 
+static void mlx4_clean_dev(struct mlx4_dev *dev)
+{
+	struct mlx4_dev_persistent *persist = dev->persist;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	memset(priv, 0, sizeof(*priv));
+	priv->dev.persist = persist;
+}
+
 static void mlx4_unload_one(struct pci_dev *pdev)
 {
 	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
 	struct mlx4_dev  *dev  = persist->dev;
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int               pci_dev_data;
-	int p;
+	int p, i;
 	int active_vfs = 0;
 
 	if (priv->removed)
 		return;
 
+	/* saving current ports type for further use */
+	for (i = 0; i < dev->caps.num_ports; i++) {
+		dev->persist->curr_port_type[i] = dev->caps.port_type[i + 1];
+		dev->persist->curr_port_poss_type[i] = dev->caps.
+						       possible_type[i + 1];
+	}
+
 	pci_dev_data = priv->pci_dev_data;
 
 	/* Disabling SR-IOV is not allowed while there are active vf's */
@@ -3191,7 +3207,7 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 	kfree(dev->caps.qp1_proxy);
 	kfree(dev->dev_vfs);
 
-	memset(priv, 0, sizeof(*priv));
+	mlx4_clean_dev(dev);
 	priv->pci_dev_data = pci_dev_data;
 	priv->removed = 1;
 }
@@ -3210,6 +3226,25 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
+static int restore_current_port_types(struct mlx4_dev *dev,
+				      enum mlx4_port_type *types,
+				      enum mlx4_port_type *poss_types)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int err, i;
+
+	mlx4_stop_sense(dev);
+
+	mutex_lock(&priv->port_mutex);
+	for (i = 0; i < dev->caps.num_ports; i++)
+		dev->caps.possible_type[i + 1] = poss_types[i];
+	err = mlx4_change_port_types(dev, types);
+	mlx4_start_sense(dev);
+	mutex_unlock(&priv->port_mutex);
+
+	return err;
+}
+
 int mlx4_restart_one(struct pci_dev *pdev)
 {
 	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
@@ -3230,6 +3265,12 @@ int mlx4_restart_one(struct pci_dev *pdev)
 		return err;
 	}
 
+	err = restore_current_port_types(dev, dev->persist->curr_port_type,
+					 dev->persist->curr_port_poss_type);
+	if (err)
+		mlx4_err(dev, "could not restore original port types (%d)\n",
+			 err);
+
 	return err;
 }
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1069ce6..8c3837a 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -749,6 +749,8 @@ struct mlx4_dev_persistent {
 	struct mlx4_dev	       *dev;
 	int                     nvfs[MLX4_MAX_PORTS + 1];
 	int			num_vfs;
+	enum mlx4_port_type curr_port_type[MLX4_MAX_PORTS + 1];
+	enum mlx4_port_type curr_port_poss_type[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_dev {
-- 
1.7.1
