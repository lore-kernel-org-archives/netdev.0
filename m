From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V2 18/21] mlx4_core: adjust catas operation for SRIOV
 mode
Date: Tue, 13 Dec 2011 16:17:16 +0200
Message-ID: <4EE75E6C.6090900@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>

When running in SRIOV mode, driver should not automatically start/stop
the mlx4_core upon sensing an HCA internal error -- doing this disables/enables
sriov, which will cause the hypervisor to hang if there are running VMs with
attached VFs.

In addition, on VMs the catas process should not run at all, since the HCA
error buffer is not available to VMs in the BARs.

Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/catas.c |    7 ++++++-
 drivers/net/ethernet/mellanox/mlx4/intf.c  |    6 ++++--
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index 45aea9c..915e947 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -48,7 +48,8 @@ static struct work_struct catas_work;
 static int internal_err_reset = 1;
 module_param(internal_err_reset, int, 0644);
 MODULE_PARM_DESC(internal_err_reset,
-		 "Reset device on internal errors if non-zero (default 1)");
+		 "Reset device on internal errors if non-zero"
+		 " (default 1, in SRIOV mode default is 0)");
 
 static void dump_err_buf(struct mlx4_dev *dev)
 {
@@ -116,6 +117,10 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	phys_addr_t addr;
 
+	/*If we are in SRIOV the default of the module param must be 0*/
+	if (mlx4_is_mfunc(dev))
+		internal_err_reset = 0;
+
 	INIT_LIST_HEAD(&priv->catas_err.list);
 	init_timer(&priv->catas_err.timer);
 	priv->catas_err.map = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index ca6feb5..b4e9f6f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -142,7 +142,8 @@ int mlx4_register_device(struct mlx4_dev *dev)
 		mlx4_add_device(intf, priv);
 
 	mutex_unlock(&intf_mutex);
-	mlx4_start_catas_poll(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_start_catas_poll(dev);
 
 	return 0;
 }
@@ -152,7 +153,8 @@ void mlx4_unregister_device(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_interface *intf;
 
-	mlx4_stop_catas_poll(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_stop_catas_poll(dev);
 	mutex_lock(&intf_mutex);
 
 	list_for_each_entry(intf, &intf_list, list)
-- 
1.7.7







--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
