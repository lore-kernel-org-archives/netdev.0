From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/7] net/mlx4_core: Flexible (asymmetric) allocation of EQs and MSI-X vectors for PF/VFs
Date: Thu, 13 Nov 2014 14:45:32 +0200
Message-ID: <1415882733-3084-7-git-send-email-ogerlitz@mellanox.com>
References: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39851 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932683AbaKMMpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:45:42 -0500
In-Reply-To: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Previously, the driver queried the firmware in order to get the number
of supported EQs. Under SRIOV, since this was done before the driver
notified the firmware how many VFs it actually needs, the firmware had
to take into account a worst case scenario and always allocated four EQs
per VF, where one was used for events while the others were used for completions.

Now, when the firmware supports the asymmetric allocation scheme, denoted
by exposing num_sys_eqs > 0 (--> MLX4_DEV_CAP_FLAG2_SYS_EQS), we use the
QUERY_FUNC command to query the firmware before enabling SRIOV. Thus we
can get more EQs and MSI-X vectors per function.

Moreover, when running in the new firmware/driver mode, the limitation
that the number of EQs should be a power of two is lifted.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c            |    3 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c      |    8 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c      |   52 +++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.h      |    2 +
 drivers/net/ethernet/mellanox/mlx4/main.c    |  144 ++++++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/profile.c |   19 +++-
 include/linux/mlx4/device.h                  |    4 +-
 7 files changed, 190 insertions(+), 42 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 8b72cf3..0c33755 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1975,8 +1975,7 @@ static void mlx4_ib_alloc_eqs(struct mlx4_dev *dev, struct mlx4_ib_dev *ibdev)
 	    dev->caps.num_ports > dev->caps.comp_pool)
 		return;
 
-	eq_per_port = rounddown_pow_of_two(dev->caps.comp_pool/
-					dev->caps.num_ports);
+	eq_per_port = dev->caps.comp_pool / dev->caps.num_ports;
 
 	/* Init eq table */
 	added_eqs = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 49290a4..d68b264 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1123,8 +1123,12 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 		goto err_out_free;
 	}
 
-	err = mlx4_bitmap_init(&priv->eq_table.bitmap, dev->caps.num_eqs,
-			       dev->caps.num_eqs - 1, dev->caps.reserved_eqs, 0);
+	err = mlx4_bitmap_init(&priv->eq_table.bitmap,
+			       roundup_pow_of_two(dev->caps.num_eqs),
+			       dev->caps.num_eqs - 1,
+			       dev->caps.reserved_eqs,
+			       roundup_pow_of_two(dev->caps.num_eqs) -
+			       dev->caps.num_eqs);
 	if (err)
 		goto err_out_free;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index b3bbeb9..d2f594f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -142,7 +142,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[13] = "Large cache line (>64B) EQE stride support",
 		[14] = "Ethernet protocol control support",
 		[15] = "Ethernet Backplane autoneg support",
-		[16] = "CONFIG DEV support"
+		[16] = "CONFIG DEV support",
+		[17] = "Asymmetric EQs support"
 	};
 	int i;
 
@@ -200,7 +201,6 @@ int mlx4_QUERY_FUNC(struct mlx4_dev *dev, struct mlx4_func *func, int slave)
 	outbox = mailbox->buf;
 
 	in_modifier = slave;
-	mlx4_dbg(dev, "%s for VF %d\n", __func__, in_modifier);
 
 	err = mlx4_cmd_box(dev, 0, mailbox->dma, in_modifier, 0,
 			   MLX4_CMD_QUERY_FUNC,
@@ -243,6 +243,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	u8	field, port;
 	u32	size, proxy_qp, qkey;
 	int	err = 0;
+	struct mlx4_func func;
 
 #define QUERY_FUNC_CAP_FLAGS_OFFSET		0x0
 #define QUERY_FUNC_CAP_NUM_PORTS_OFFSET		0x1
@@ -287,6 +288,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_VF_ENABLE_QP0		0x08
 
 #define QUERY_FUNC_CAP_FLAGS0_FORCE_PHY_WQE_GID 0x80
+#define QUERY_FUNC_CAP_SUPPORTS_NON_POWER_OF_2_NUM_EQS (1 << 31)
 
 	if (vhcr->op_modifier == 1) {
 		struct mlx4_active_ports actv_ports =
@@ -365,11 +367,24 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		size = dev->caps.num_cqs;
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_CQ_QUOTA_OFFSET_DEP);
 
-		size = dev->caps.num_eqs;
-		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MAX_EQ_OFFSET);
-
-		size = dev->caps.reserved_eqs;
-		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_RESERVED_EQ_OFFSET);
+		if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS) ||
+		    mlx4_QUERY_FUNC(dev, &func, slave)) {
+			size = vhcr->in_modifier &
+				QUERY_FUNC_CAP_SUPPORTS_NON_POWER_OF_2_NUM_EQS ?
+				dev->caps.num_eqs :
+				rounddown_pow_of_two(dev->caps.num_eqs);
+			MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MAX_EQ_OFFSET);
+			size = dev->caps.reserved_eqs;
+			MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_RESERVED_EQ_OFFSET);
+		} else {
+			size = vhcr->in_modifier &
+				QUERY_FUNC_CAP_SUPPORTS_NON_POWER_OF_2_NUM_EQS ?
+				func.max_eq :
+				rounddown_pow_of_two(func.max_eq);
+			MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MAX_EQ_OFFSET);
+			size = func.rsvd_eqs;
+			MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_RESERVED_EQ_OFFSET);
+		}
 
 		size = priv->mfunc.master.res_tracker.res_alloc[RES_MPT].quota[slave];
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MPT_QUOTA_OFFSET);
@@ -399,14 +414,17 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 	u8			field, op_modifier;
 	u32			size, qkey;
 	int			err = 0, quotas = 0;
+	u32                     in_modifier;
 
 	op_modifier = !!gen_or_port; /* 0 = general, 1 = logical port */
+	in_modifier = op_modifier ? gen_or_port :
+		QUERY_FUNC_CAP_SUPPORTS_NON_POWER_OF_2_NUM_EQS;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 
-	err = mlx4_cmd_box(dev, 0, mailbox->dma, gen_or_port, op_modifier,
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, in_modifier, op_modifier,
 			   MLX4_CMD_QUERY_FUNC_CAP,
 			   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 	if (err)
@@ -578,6 +596,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAX_MRW_SZ_OFFSET		0x21
 #define QUERY_DEV_CAP_RSVD_MRW_OFFSET		0x22
 #define QUERY_DEV_CAP_MAX_MTT_SEG_OFFSET	0x23
+#define QUERY_DEV_CAP_NUM_SYS_EQ_OFFSET		0x26
 #define QUERY_DEV_CAP_MAX_AV_OFFSET		0x27
 #define QUERY_DEV_CAP_MAX_REQ_QP_OFFSET		0x29
 #define QUERY_DEV_CAP_MAX_RES_QP_OFFSET		0x2b
@@ -678,6 +697,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->reserved_mrws = 1 << (field & 0xf);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_MTT_SEG_OFFSET);
 	dev_cap->max_mtt_seg = 1 << (field & 0x3f);
+	MLX4_GET(size, outbox, QUERY_DEV_CAP_NUM_SYS_EQ_OFFSET);
+	dev_cap->num_sys_eqs = size & 0xfff;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_REQ_QP_OFFSET);
 	dev_cap->max_requester_per_qp = 1 << (field & 0x3f);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_RES_QP_OFFSET);
@@ -905,8 +926,11 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	 * we can't use any EQs whose doorbell falls on that page,
 	 * even if the EQ itself isn't reserved.
 	 */
-	dev_cap->reserved_eqs = max(dev_cap->reserved_uars * 4,
-				    dev_cap->reserved_eqs);
+	if (dev_cap->num_sys_eqs == 0)
+		dev_cap->reserved_eqs = max(dev_cap->reserved_uars * 4,
+					    dev_cap->reserved_eqs);
+	else
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_SYS_EQS;
 
 	mlx4_dbg(dev, "Max ICM size %lld MB\n",
 		 (unsigned long long) dev_cap->max_icm_sz >> 20);
@@ -916,8 +940,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		 dev_cap->max_srqs, dev_cap->reserved_srqs, dev_cap->srq_entry_sz);
 	mlx4_dbg(dev, "Max CQs: %d, reserved CQs: %d, entry size: %d\n",
 		 dev_cap->max_cqs, dev_cap->reserved_cqs, dev_cap->cqc_entry_sz);
-	mlx4_dbg(dev, "Max EQs: %d, reserved EQs: %d, entry size: %d\n",
-		 dev_cap->max_eqs, dev_cap->reserved_eqs, dev_cap->eqc_entry_sz);
+	mlx4_dbg(dev, "Num sys EQs: %d, max EQs: %d, reserved EQs: %d, entry size: %d\n",
+		 dev_cap->num_sys_eqs, dev_cap->max_eqs, dev_cap->reserved_eqs,
+		 dev_cap->eqc_entry_sz);
 	mlx4_dbg(dev, "reserved MPTs: %d, reserved MTTs: %d\n",
 		 dev_cap->reserved_mrws, dev_cap->reserved_mtts);
 	mlx4_dbg(dev, "Max PDs: %d, reserved PDs: %d, reserved UARs: %d\n",
@@ -1463,6 +1488,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 #define	 INIT_HCA_AUXC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x50)
 #define	 INIT_HCA_EQC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x60)
 #define	 INIT_HCA_LOG_EQ_OFFSET		 (INIT_HCA_QPC_OFFSET + 0x67)
+#define	INIT_HCA_NUM_SYS_EQS_OFFSET	(INIT_HCA_QPC_OFFSET + 0x6a)
 #define	 INIT_HCA_RDMARC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x70)
 #define	 INIT_HCA_LOG_RD_OFFSET		 (INIT_HCA_QPC_OFFSET + 0x77)
 #define INIT_HCA_MCAST_OFFSET		 0x0c0
@@ -1566,6 +1592,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	MLX4_PUT(inbox, param->auxc_base,     INIT_HCA_AUXC_BASE_OFFSET);
 	MLX4_PUT(inbox, param->eqc_base,      INIT_HCA_EQC_BASE_OFFSET);
 	MLX4_PUT(inbox, param->log_num_eqs,   INIT_HCA_LOG_EQ_OFFSET);
+	MLX4_PUT(inbox, param->num_sys_eqs,   INIT_HCA_NUM_SYS_EQS_OFFSET);
 	MLX4_PUT(inbox, param->rdmarc_base,   INIT_HCA_RDMARC_BASE_OFFSET);
 	MLX4_PUT(inbox, param->log_rd_per_qp, INIT_HCA_LOG_RD_OFFSET);
 
@@ -1676,6 +1703,7 @@ int mlx4_QUERY_HCA(struct mlx4_dev *dev,
 	MLX4_GET(param->auxc_base,     outbox, INIT_HCA_AUXC_BASE_OFFSET);
 	MLX4_GET(param->eqc_base,      outbox, INIT_HCA_EQC_BASE_OFFSET);
 	MLX4_GET(param->log_num_eqs,   outbox, INIT_HCA_LOG_EQ_OFFSET);
+	MLX4_GET(param->num_sys_eqs,   outbox, INIT_HCA_NUM_SYS_EQS_OFFSET);
 	MLX4_GET(param->rdmarc_base,   outbox, INIT_HCA_RDMARC_BASE_OFFSET);
 	MLX4_GET(param->log_rd_per_qp, outbox, INIT_HCA_LOG_RD_OFFSET);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 48c11b5..475215e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -56,6 +56,7 @@ struct mlx4_dev_cap {
 	int max_mpts;
 	int reserved_eqs;
 	int max_eqs;
+	int num_sys_eqs;
 	int reserved_mtts;
 	int max_mrw_sz;
 	int reserved_mrws;
@@ -180,6 +181,7 @@ struct mlx4_init_hca_param {
 	u8  log_num_srqs;
 	u8  log_num_cqs;
 	u8  log_num_eqs;
+	u16 num_sys_eqs;
 	u8  log_rd_per_qp;
 	u8  log_mc_table_sz;
 	u8  log_mpt_sz;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 43047b2..ebb2790 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -197,6 +197,29 @@ static void mlx4_set_port_mask(struct mlx4_dev *dev)
 		dev->caps.port_mask[i] = dev->caps.port_type[i];
 }
 
+enum {
+	MLX4_QUERY_FUNC_NUM_SYS_EQS = 1 << 0,
+};
+
+static int mlx4_query_func(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
+{
+	int err = 0;
+	struct mlx4_func func;
+
+	if (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS) {
+		err = mlx4_QUERY_FUNC(dev, &func, 0);
+		if (err) {
+			mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting.\n");
+			return err;
+		}
+		dev_cap->max_eqs = func.max_eq;
+		dev_cap->reserved_eqs = func.rsvd_eqs;
+		dev_cap->reserved_uars = func.rsvd_uars;
+		err |= MLX4_QUERY_FUNC_NUM_SYS_EQS;
+	}
+	return err;
+}
+
 static void mlx4_enable_cqe_eqe_stride(struct mlx4_dev *dev)
 {
 	struct mlx4_caps *dev_cap = &dev->caps;
@@ -261,7 +284,10 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	}
 
 	dev->caps.num_ports	     = dev_cap->num_ports;
-	dev->phys_caps.num_phys_eqs  = MLX4_MAX_EQ_NUM;
+	dev->caps.num_sys_eqs = dev_cap->num_sys_eqs;
+	dev->phys_caps.num_phys_eqs = dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS ?
+				      dev->caps.num_sys_eqs :
+				      MLX4_MAX_EQ_NUM;
 	for (i = 1; i <= dev->caps.num_ports; ++i) {
 		dev->caps.vl_cap[i]	    = dev_cap->max_vl[i];
 		dev->caps.ib_mtu_cap[i]	    = dev_cap->ib_mtu[i];
@@ -1130,8 +1156,7 @@ static int mlx4_init_cmpt_table(struct mlx4_dev *dev, u64 cmpt_base,
 	if (err)
 		goto err_srq;
 
-	num_eqs = (mlx4_is_master(dev)) ? dev->phys_caps.num_phys_eqs :
-		  dev->caps.num_eqs;
+	num_eqs = dev->phys_caps.num_phys_eqs;
 	err = mlx4_init_icm_table(dev, &priv->eq_table.cmpt_table,
 				  cmpt_base +
 				  ((u64) (MLX4_CMPT_TYPE_EQ *
@@ -1193,8 +1218,7 @@ static int mlx4_init_icm(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap,
 	}
 
 
-	num_eqs = (mlx4_is_master(dev)) ? dev->phys_caps.num_phys_eqs :
-		   dev->caps.num_eqs;
+	num_eqs = dev->phys_caps.num_phys_eqs;
 	err = mlx4_init_icm_table(dev, &priv->eq_table.table,
 				  init_hca->eqc_base, dev_cap->eqc_entry_sz,
 				  num_eqs, num_eqs, 0, 0);
@@ -1719,6 +1743,19 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 			mlx4_err(dev, "INIT_HCA command failed, aborting\n");
 			goto err_free_icm;
 		}
+
+		if (dev_cap.flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS) {
+			err = mlx4_query_func(dev, &dev_cap);
+			if (err < 0) {
+				mlx4_err(dev, "QUERY_FUNC command failed, aborting.\n");
+				goto err_stop_fw;
+			} else if (err & MLX4_QUERY_FUNC_NUM_SYS_EQS) {
+				dev->caps.num_eqs = dev_cap.max_eqs;
+				dev->caps.reserved_eqs = dev_cap.reserved_eqs;
+				dev->caps.reserved_uars = dev_cap.reserved_uars;
+			}
+		}
+
 		/*
 		 * If TS is supported by FW
 		 * read HCA frequency by QUERY_HCA command
@@ -2085,12 +2122,11 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct msix_entry *entries;
-	int nreq = min_t(int, dev->caps.num_ports *
-			 min_t(int, num_online_cpus() + 1,
-			       MAX_MSIX_P_PORT) + MSIX_LEGACY_SZ, MAX_MSIX);
 	int i;
 
 	if (msi_x) {
+		int nreq = dev->caps.num_ports * num_online_cpus() + MSIX_LEGACY_SZ;
+
 		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
 			     nreq);
 
@@ -2345,6 +2381,7 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 	int err;
 	int port;
 	int i;
+	struct mlx4_dev_cap *dev_cap = NULL;
 	int existing_vfs = 0;
 
 	dev = &priv->dev;
@@ -2381,15 +2418,6 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 			}
 		}
 
-		if (total_vfs) {
-			existing_vfs = pci_num_vf(pdev);
-			dev->flags = MLX4_FLAG_MASTER;
-			dev->flags = mlx4_enable_sriov(dev, pdev, total_vfs,
-						       existing_vfs);
-			if (!SRIOV_VALID_STATE(dev->flags))
-				goto err_sriov;
-		}
-
 		atomic_set(&priv->opreq_count, 0);
 		INIT_WORK(&priv->opreq_task, mlx4_opreq_action);
 
@@ -2403,6 +2431,12 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 			mlx4_err(dev, "Failed to reset HCA, aborting\n");
 			goto err_sriov;
 		}
+
+		if (total_vfs) {
+			existing_vfs = pci_num_vf(pdev);
+			dev->flags = MLX4_FLAG_MASTER;
+			dev->num_vfs = total_vfs;
+		}
 	}
 
 slave_start:
@@ -2416,9 +2450,10 @@ slave_start:
 	 * before posting commands. Also, init num_slaves before calling
 	 * mlx4_init_hca */
 	if (mlx4_is_mfunc(dev)) {
-		if (mlx4_is_master(dev))
+		if (mlx4_is_master(dev)) {
 			dev->num_slaves = MLX4_MAX_NUM_SLAVES;
-		else {
+
+		} else {
 			dev->num_slaves = 0;
 			err = mlx4_multi_func_init(dev);
 			if (err) {
@@ -2434,6 +2469,52 @@ slave_start:
 		goto err_mfunc;
 	}
 
+	if (mlx4_is_master(dev)) {
+		if (!dev_cap) {
+			dev_cap = kzalloc(sizeof(*dev_cap), GFP_KERNEL);
+
+			if (!dev_cap) {
+				err = -ENOMEM;
+				goto err_fw;
+			}
+
+			err = mlx4_QUERY_DEV_CAP(dev, dev_cap);
+			if (err) {
+				mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting.\n");
+				goto err_fw;
+			}
+
+			if (!(dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS)) {
+				u64 dev_flags = mlx4_enable_sriov(dev, pdev, total_vfs,
+								  existing_vfs);
+
+				mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
+				dev->flags = dev_flags;
+				if (!SRIOV_VALID_STATE(dev->flags)) {
+					mlx4_err(dev, "Invalid SRIOV state\n");
+					goto err_sriov;
+				}
+				err = mlx4_reset(dev);
+				if (err) {
+					mlx4_err(dev, "Failed to reset HCA, aborting.\n");
+					goto err_sriov;
+				}
+				goto slave_start;
+			}
+		} else {
+			/* Legacy mode FW requires SRIOV to be enabled before
+			 * doing QUERY_DEV_CAP, since max_eq's value is different if
+			 * SRIOV is enabled.
+			 */
+			memset(dev_cap, 0, sizeof(*dev_cap));
+			err = mlx4_QUERY_DEV_CAP(dev, dev_cap);
+			if (err) {
+				mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting.\n");
+				goto err_fw;
+			}
+		}
+	}
+
 	err = mlx4_init_hca(dev);
 	if (err) {
 		if (err == -EACCES) {
@@ -2457,6 +2538,30 @@ slave_start:
 			goto err_fw;
 	}
 
+	if (mlx4_is_master(dev) && (dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS)) {
+		u64 dev_flags = mlx4_enable_sriov(dev, pdev, total_vfs, existing_vfs);
+
+		if ((dev->flags ^ dev_flags) & (MLX4_FLAG_MASTER | MLX4_FLAG_SLAVE)) {
+			mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_VHCR);
+			dev->flags = dev_flags;
+			err = mlx4_cmd_init(dev);
+			if (err) {
+				/* Only VHCR is cleaned up, so could still
+				 * send FW commands
+				 */
+				mlx4_err(dev, "Failed to init VHCR command interface, aborting\n");
+				goto err_close;
+			}
+		} else {
+			dev->flags = dev_flags;
+		}
+
+		if (!SRIOV_VALID_STATE(dev->flags)) {
+			mlx4_err(dev, "Invalid SRIOV state\n");
+			goto err_close;
+		}
+	}
+
 	/* check if the device is functioning at its maximum possible speed.
 	 * No return code for this call, just warn the user in case of PCI
 	 * express device capabilities are under-satisfied by the bus.
@@ -2631,6 +2736,7 @@ err_sriov:
 	if (!mlx4_is_slave(dev))
 		mlx4_free_ownership(dev);
 
+	kfree(dev_cap);
 	return err;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/profile.c b/drivers/net/ethernet/mellanox/mlx4/profile.c
index 14089d9..2bf437a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/profile.c
+++ b/drivers/net/ethernet/mellanox/mlx4/profile.c
@@ -126,8 +126,7 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	profile[MLX4_RES_AUXC].num    = request->num_qp;
 	profile[MLX4_RES_SRQ].num     = request->num_srq;
 	profile[MLX4_RES_CQ].num      = request->num_cq;
-	profile[MLX4_RES_EQ].num      = mlx4_is_mfunc(dev) ?
-					dev->phys_caps.num_phys_eqs :
+	profile[MLX4_RES_EQ].num = mlx4_is_mfunc(dev) ? dev->phys_caps.num_phys_eqs :
 					min_t(unsigned, dev_cap->max_eqs, MAX_MSIX);
 	profile[MLX4_RES_DMPT].num    = request->num_mpt;
 	profile[MLX4_RES_CMPT].num    = MLX4_NUM_CMPTS;
@@ -216,10 +215,18 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 			init_hca->log_num_cqs = profile[i].log_num;
 			break;
 		case MLX4_RES_EQ:
-			dev->caps.num_eqs     = roundup_pow_of_two(min_t(unsigned, dev_cap->max_eqs,
-									 MAX_MSIX));
-			init_hca->eqc_base    = profile[i].start;
-			init_hca->log_num_eqs = ilog2(dev->caps.num_eqs);
+			if (dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS) {
+				init_hca->log_num_eqs = 0x1f;
+				init_hca->eqc_base    = profile[i].start;
+				init_hca->num_sys_eqs = dev_cap->num_sys_eqs;
+			} else {
+				dev->caps.num_eqs     = roundup_pow_of_two(
+								min_t(unsigned,
+								      dev_cap->max_eqs,
+								      MAX_MSIX));
+				init_hca->eqc_base    = profile[i].start;
+				init_hca->log_num_eqs = ilog2(dev->caps.num_eqs);
+			}
 			break;
 		case MLX4_RES_DMPT:
 			dev->caps.num_mpts	= profile[i].num;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 3d9bff0..1c560eb 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -189,7 +189,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_EQE_STRIDE		= 1LL <<  13,
 	MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL        = 1LL <<  14,
 	MLX4_DEV_CAP_FLAG2_ETH_BACKPL_AN_REP	= 1LL <<  15,
-	MLX4_DEV_CAP_FLAG2_CONFIG_DEV		= 1LL <<  16
+	MLX4_DEV_CAP_FLAG2_CONFIG_DEV		= 1LL <<  16,
+	MLX4_DEV_CAP_FLAG2_SYS_EQS		= 1LL <<  17
 };
 
 enum {
@@ -443,6 +444,7 @@ struct mlx4_caps {
 	int			num_cqs;
 	int			max_cqes;
 	int			reserved_cqs;
+	int			num_sys_eqs;
 	int			num_eqs;
 	int			reserved_eqs;
 	int			num_comp_vectors;
-- 
1.7.1
