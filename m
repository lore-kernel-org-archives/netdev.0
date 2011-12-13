From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V2 04/21] mlx4_core: Reduce number of PD bits to
 17
Date: Tue, 13 Dec 2011 16:12:13 +0200
Message-ID: <4EE75D3D.3080700@mellanox.co.il>
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

When SRIOV is enabled on the chip (at FW burning time),
the HCA uses only 17 bits for the PD. The remaining 7 high-order bits
are ignored.

Change the allocator to return only 17 bits for the PD.  The MSB 7
bits will be used to encode the slave number for consistency
checking later on in the resource tracker.

Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    5 ++++-
 drivers/net/ethernet/mellanox/mlx4/pd.c   |   19 ++++++++++++++-----
 include/linux/mlx4/device.h               |    1 +
 3 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 6917761..51cba26 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -420,7 +420,7 @@ struct mlx4_mfunc_master_ctx {
 	struct work_struct	slave_event_work;
 	struct work_struct	slave_flr_event_work;
 	spinlock_t		slave_state_lock;
-	u32			comm_arm_bit_vector[4];
+	__be32			comm_arm_bit_vector[4];
 	struct mlx4_eqe		cmd_eqe;
 	struct mlx4_slave_event_eq slave_eq;
 	struct mutex		gen_eqe_mutex[MLX4_MFUNC_MAX];
@@ -914,4 +914,7 @@ int mlx4_QUERY_IF_STAT_wrapper(struct mlx4_dev *dev, int slave,
 			       struct mlx4_cmd_mailbox *inbox,
 			       struct mlx4_cmd_mailbox *outbox,
 			       struct mlx4_cmd_info *cmd);
+
+#define NOT_MASKED_PD_BITS 17
+
 #endif /* MLX4_H */
diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
index 260ed25..5c9a54d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
@@ -31,6 +31,7 @@
  * SOFTWARE.
  */
 
+#include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/export.h>
 #include <linux/io-mapping.h>
@@ -51,7 +52,8 @@ int mlx4_pd_alloc(struct mlx4_dev *dev, u32 *pdn)
 	*pdn = mlx4_bitmap_alloc(&priv->pd_bitmap);
 	if (*pdn == -1)
 		return -ENOMEM;
-
+	if (mlx4_is_mfunc(dev))
+		*pdn |= (dev->caps.function + 1) << NOT_MASKED_PD_BITS;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_pd_alloc);
@@ -85,7 +87,8 @@ int mlx4_init_pd_table(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
 	return mlx4_bitmap_init(&priv->pd_bitmap, dev->caps.num_pds,
-				(1 << 24) - 1, dev->caps.reserved_pds, 0);
+				(1 << NOT_MASKED_PD_BITS) - 1,
+				 dev->caps.reserved_pds, 0);
 }
 
 void mlx4_cleanup_pd_table(struct mlx4_dev *dev)
@@ -108,13 +111,19 @@ void mlx4_cleanup_xrcd_table(struct mlx4_dev *dev)
 
 int mlx4_uar_alloc(struct mlx4_dev *dev, struct mlx4_uar *uar)
 {
+	int offset;
+
 	uar->index = mlx4_bitmap_alloc(&mlx4_priv(dev)->uar_table.bitmap);
 	if (uar->index == -1)
 		return -ENOMEM;
 
-	uar->pfn = (pci_resource_start(dev->pdev, 2) >> PAGE_SHIFT) + uar->index;
+	if (mlx4_is_slave(dev))
+		offset = uar->index % ((int) pci_resource_len(dev->pdev, 2) /
+				       dev->caps.uar_page_size);
+	else
+		offset = uar->index;
+	uar->pfn = (pci_resource_start(dev->pdev, 2) >> PAGE_SHIFT) + offset;
 	uar->map = NULL;
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_uar_alloc);
@@ -232,7 +241,7 @@ int mlx4_init_uar_table(struct mlx4_dev *dev)
 
 	return mlx4_bitmap_init(&mlx4_priv(dev)->uar_table.bitmap,
 				dev->caps.num_uars, dev->caps.num_uars - 1,
-				max(128, dev->caps.reserved_uars), 0);
+				dev->caps.reserved_uars, 0);
 }
 
 void mlx4_cleanup_uar_table(struct mlx4_dev *dev)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 3333018..e4be34a 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -248,6 +248,7 @@ struct mlx4_caps {
 	u64			trans_code[MLX4_MAX_PORTS + 1];
 	int			local_ca_ack_delay;
 	int			num_uars;
+	u32			uar_page_size;
 	int			bf_reg_size;
 	int			bf_regs_per_page;
 	int			max_sq_sg;
-- 
1.7.7








--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
