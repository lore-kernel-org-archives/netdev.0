From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 2/6] net/mlx4_core: Fix number of EQs used in ICM initialisation
Date: Wed, 30 May 2012 22:21:51 +0300
Message-ID: <1338405711-16282-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Marcel Apfelbaum <marcela@dev.mellanox.co.il>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:36405 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750931Ab2E3TV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 15:21:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Apfelbaum <marcela@dev.mellanox.co.il>

In SRIOV mode, the number of EQs used when computing the total ICM size
was incorrect.

To fix this, we do the following:
1. We add a new structure to mlx4_dev, mlx4_phys_caps, to contain physical HCA
   capabilities.  The PPF uses the phys capabilities when it computes things
   like ICM size.

   The dev_caps structure will then contain the paravirtualized values, making
   bookkeeping much easier in SRIOV mode. We add a structure rather than a
   single parameter because there will be other fields in the phys_caps.

   The first field we add to the mlx4_phys_caps structure is num_phys_eqs.

2. In INIT_HCA, when running in SRIOV mode, the "log_num_eqs" parameter
   passed to the FW is the number of EQs per VF/PF; each function (PF or VF)
   has this number of EQs available.

   However, the total number of EQs which must be allowed for in the ICM is
   (1 << log_num_eqs) * (#VFs + #PFs).  Rather than compute this quantity,
   we allocate ICM space for 1024 EQs (which is the device maximum
   number of EQs, and which is the value we place in the mlx4_phys_caps structure).

   For INIT_HCA, however, we use the per-function number of EQs as described
   above.

Signed-off-by: Marcel Apfelbaum <marcela@dev.mellanox.co.il>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c    |   17 +++++------------
 drivers/net/ethernet/mellanox/mlx4/profile.c |    9 ++++++---
 include/linux/mlx4/device.h                  |    6 ++++++
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2e024a6..2fe9fe5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -142,12 +142,6 @@ struct mlx4_port_config {
 	struct pci_dev *pdev;
 };
 
-static inline int mlx4_master_get_num_eqs(struct mlx4_dev *dev)
-{
-	return dev->caps.reserved_eqs +
-		MLX4_MFUNC_EQ_NUM * (dev->num_slaves + 1);
-}
-
 int mlx4_check_port_params(struct mlx4_dev *dev,
 			   enum mlx4_port_type *port_type)
 {
@@ -217,6 +211,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	}
 
 	dev->caps.num_ports	     = dev_cap->num_ports;
+	dev->phys_caps.num_phys_eqs  = MLX4_MAX_EQ_NUM;
 	for (i = 1; i <= dev->caps.num_ports; ++i) {
 		dev->caps.vl_cap[i]	    = dev_cap->max_vl[i];
 		dev->caps.ib_mtu_cap[i]	    = dev_cap->ib_mtu[i];
@@ -810,9 +805,8 @@ static int mlx4_init_cmpt_table(struct mlx4_dev *dev, u64 cmpt_base,
 	if (err)
 		goto err_srq;
 
-	num_eqs = (mlx4_is_master(dev)) ?
-		roundup_pow_of_two(mlx4_master_get_num_eqs(dev)) :
-		dev->caps.num_eqs;
+	num_eqs = (mlx4_is_master(dev)) ? dev->phys_caps.num_phys_eqs :
+		  dev->caps.num_eqs;
 	err = mlx4_init_icm_table(dev, &priv->eq_table.cmpt_table,
 				  cmpt_base +
 				  ((u64) (MLX4_CMPT_TYPE_EQ *
@@ -874,9 +868,8 @@ static int mlx4_init_icm(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap,
 	}
 
 
-	num_eqs = (mlx4_is_master(dev)) ?
-		roundup_pow_of_two(mlx4_master_get_num_eqs(dev)) :
-		dev->caps.num_eqs;
+	num_eqs = (mlx4_is_master(dev)) ? dev->phys_caps.num_phys_eqs :
+		   dev->caps.num_eqs;
 	err = mlx4_init_icm_table(dev, &priv->eq_table.table,
 				  init_hca->eqc_base, dev_cap->eqc_entry_sz,
 				  num_eqs, num_eqs, 0, 0);
diff --git a/drivers/net/ethernet/mellanox/mlx4/profile.c b/drivers/net/ethernet/mellanox/mlx4/profile.c
index 06e5ade..b83bc92 100644
--- a/drivers/net/ethernet/mellanox/mlx4/profile.c
+++ b/drivers/net/ethernet/mellanox/mlx4/profile.c
@@ -126,7 +126,9 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	profile[MLX4_RES_AUXC].num    = request->num_qp;
 	profile[MLX4_RES_SRQ].num     = request->num_srq;
 	profile[MLX4_RES_CQ].num      = request->num_cq;
-	profile[MLX4_RES_EQ].num      = min_t(unsigned, dev_cap->max_eqs, MAX_MSIX);
+	profile[MLX4_RES_EQ].num      = mlx4_is_mfunc(dev) ?
+					dev->phys_caps.num_phys_eqs :
+					min_t(unsigned, dev_cap->max_eqs, MAX_MSIX);
 	profile[MLX4_RES_DMPT].num    = request->num_mpt;
 	profile[MLX4_RES_CMPT].num    = MLX4_NUM_CMPTS;
 	profile[MLX4_RES_MTT].num     = request->num_mtt * (1 << log_mtts_per_seg);
@@ -215,9 +217,10 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 			init_hca->log_num_cqs = profile[i].log_num;
 			break;
 		case MLX4_RES_EQ:
-			dev->caps.num_eqs     = profile[i].num;
+			dev->caps.num_eqs     = roundup_pow_of_two(min_t(unsigned, dev_cap->max_eqs,
+									 MAX_MSIX));
 			init_hca->eqc_base    = profile[i].start;
-			init_hca->log_num_eqs = profile[i].log_num;
+			init_hca->log_num_eqs = ilog2(dev->caps.num_eqs);
 			break;
 		case MLX4_RES_DMPT:
 			dev->caps.num_mpts	= profile[i].num;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 6e27fa9..6a8f002 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -64,6 +64,7 @@ enum {
 	MLX4_MAX_NUM_PF		= 16,
 	MLX4_MAX_NUM_VF		= 64,
 	MLX4_MFUNC_MAX		= 80,
+	MLX4_MAX_EQ_NUM		= 1024,
 	MLX4_MFUNC_EQ_NUM	= 4,
 	MLX4_MFUNC_MAX_EQES     = 8,
 	MLX4_MFUNC_EQE_MASK     = (MLX4_MFUNC_MAX_EQES - 1)
@@ -239,6 +240,10 @@ static inline u64 mlx4_fw_ver(u64 major, u64 minor, u64 subminor)
 	return (major << 32) | (minor << 16) | subminor;
 }
 
+struct mlx4_phys_caps {
+	u32			num_phys_eqs;
+};
+
 struct mlx4_caps {
 	u64			fw_ver;
 	u32			function;
@@ -499,6 +504,7 @@ struct mlx4_dev {
 	unsigned long		flags;
 	unsigned long		num_slaves;
 	struct mlx4_caps	caps;
+	struct mlx4_phys_caps	phys_caps;
 	struct radix_tree_root	qp_table_tree;
 	u8			rev_id;
 	char			board_id[MLX4_BOARD_ID_LEN];
-- 
1.7.1
