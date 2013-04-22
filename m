From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 2/5] net/mlx4_core: Read HCA frequency and map internal clock
Date: Mon, 22 Apr 2013 14:56:04 +0300
Message-ID: <1366631767-16493-3-git-send-email-amirv@mellanox.com>
References: <1366631767-16493-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:58909 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752099Ab3DVMQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 08:16:37 -0400
In-Reply-To: <1366631767-16493-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Read HCA frequency, read PCI clock bar and offset, map internal clock to
PCI bar.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |   11 ++++++
 drivers/net/ethernet/mellanox/mlx4/fw.h   |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c |   57 +++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    6 +++-
 include/linux/mlx4/device.h               |    1 +
 5 files changed, 75 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 8f394be..c16a59e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1013,6 +1013,9 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 #define QUERY_FW_COMM_BASE_OFFSET      0x40
 #define QUERY_FW_COMM_BAR_OFFSET       0x48
 
+#define QUERY_FW_CLOCK_OFFSET	       0x50
+#define QUERY_FW_CLOCK_BAR	       0x58
+
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
@@ -1087,6 +1090,12 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 		 fw->comm_bar, fw->comm_base);
 	mlx4_dbg(dev, "FW size %d KB\n", fw->fw_pages >> 2);
 
+	MLX4_GET(fw->clock_offset, outbox, QUERY_FW_CLOCK_OFFSET);
+	MLX4_GET(fw->clock_bar,    outbox, QUERY_FW_CLOCK_BAR);
+	fw->clock_bar = (fw->clock_bar >> 6) * 2;
+	mlx4_dbg(dev, "Internal clock bar:%d offset:0x%llx\n",
+		 fw->clock_bar, fw->clock_offset);
+
 	/*
 	 * Round up number of system pages needed in case
 	 * MLX4_ICM_PAGE_SIZE < PAGE_SIZE.
@@ -1374,6 +1383,7 @@ int mlx4_QUERY_HCA(struct mlx4_dev *dev,
 	u8 byte_field;
 
 #define QUERY_HCA_GLOBAL_CAPS_OFFSET	0x04
+#define QUERY_HCA_CORE_CLOCK_OFFSET	0x0c
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -1388,6 +1398,7 @@ int mlx4_QUERY_HCA(struct mlx4_dev *dev,
 		goto out;
 
 	MLX4_GET(param->global_caps, outbox, QUERY_HCA_GLOBAL_CAPS_OFFSET);
+	MLX4_GET(param->hca_core_clock, outbox, QUERY_HCA_CORE_CLOCK_OFFSET);
 
 	/* QPC/EEC/CQC/EQC/RDMARC attributes */
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 151c2bb..3332463 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -162,6 +162,7 @@ struct mlx4_init_hca_param {
 	u64 global_caps;
 	u16 log_mc_entry_sz;
 	u16 log_mc_hash_sz;
+	u16 hca_core_clock;
 	u8  log_num_qps;
 	u8  log_num_srqs;
 	u8  log_num_cqs;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 16abde2..e81840f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -513,6 +513,8 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 
 	mlx4_log_num_mgm_entry_size = hca_param.log_mc_entry_sz;
 
+	dev->caps.hca_core_clock = hca_param.hca_core_clock;
+
 	memset(&dev_cap, 0, sizeof(dev_cap));
 	dev->caps.max_qp_dest_rdma = 1 << hca_param.log_rd_per_qp;
 	err = mlx4_dev_cap(dev, &dev_cap);
@@ -1226,8 +1228,31 @@ static void unmap_bf_area(struct mlx4_dev *dev)
 		io_mapping_free(mlx4_priv(dev)->bf_mapping);
 }
 
+static int map_internal_clock(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	priv->clock_mapping =
+		ioremap(pci_resource_start(dev->pdev, priv->fw.clock_bar) +
+			priv->fw.clock_offset, MLX4_CLOCK_SIZE);
+
+	if (!priv->clock_mapping)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void unmap_internal_clock(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	if (priv->clock_mapping)
+		iounmap(priv->clock_mapping);
+}
+
 static void mlx4_close_hca(struct mlx4_dev *dev)
 {
+	unmap_internal_clock(dev);
 	unmap_bf_area(dev);
 	if (mlx4_is_slave(dev))
 		mlx4_slave_exit(dev);
@@ -1445,6 +1470,37 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 			mlx4_err(dev, "INIT_HCA command failed, aborting.\n");
 			goto err_free_icm;
 		}
+		/*
+		 * If TS is supported by FW
+		 * read HCA frequency by QUERY_HCA command
+		 */
+		if (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS) {
+			memset(&init_hca, 0, sizeof(init_hca));
+			err = mlx4_QUERY_HCA(dev, &init_hca);
+			if (err) {
+				mlx4_err(dev, "QUERY_HCA command failed, disable timestamp.\n");
+				dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_TS;
+			} else {
+				dev->caps.hca_core_clock =
+					init_hca.hca_core_clock;
+			}
+
+			/* In case we got HCA frequency 0 - disable timestamping
+			 * to avoid dividing by zero
+			 */
+			if (!dev->caps.hca_core_clock) {
+				dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_TS;
+				mlx4_err(dev,
+					 "HCA frequency is 0. Timestamping is not supported.");
+			} else if (map_internal_clock(dev)) {
+				/*
+				 * Map internal clock,
+				 * in case of failure disable timestamping
+				 */
+				dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_TS;
+				mlx4_err(dev, "Failed to map internal clock. Timestamping is not supported.\n");
+			}
+		}
 	} else {
 		err = mlx4_init_slave(dev);
 		if (err) {
@@ -1478,6 +1534,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 	return 0;
 
 unmap_bf:
+	unmap_internal_clock(dev);
 	unmap_bf_area(dev);
 
 err_close:
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 252f4ba..0567f01 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -87,7 +87,8 @@ enum {
 	MLX4_HCR_SIZE		= 0x0001c,
 	MLX4_CLR_INT_SIZE	= 0x00008,
 	MLX4_SLAVE_COMM_BASE	= 0x0,
-	MLX4_COMM_PAGESIZE	= 0x1000
+	MLX4_COMM_PAGESIZE	= 0x1000,
+	MLX4_CLOCK_SIZE		= 0x00008
 };
 
 enum {
@@ -403,6 +404,7 @@ struct mlx4_fw {
 	u64			clr_int_base;
 	u64			catas_offset;
 	u64			comm_base;
+	u64			clock_offset;
 	struct mlx4_icm	       *fw_icm;
 	struct mlx4_icm	       *aux_icm;
 	u32			catas_size;
@@ -410,6 +412,7 @@ struct mlx4_fw {
 	u8			clr_int_bar;
 	u8			catas_bar;
 	u8			comm_bar;
+	u8			clock_bar;
 };
 
 struct mlx4_comm {
@@ -826,6 +829,7 @@ struct mlx4_priv {
 	struct list_head	bf_list;
 	struct mutex		bf_mutex;
 	struct io_mapping	*bf_mapping;
+	void __iomem            *clock_mapping;
 	int			reserved_mtts;
 	int			fs_hash_mode;
 	u8 virt2phys_pkey[MLX4_MFUNC_MAX][MLX4_MAX_PORTS][MLX4_MAX_PORT_PKEYS];
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 86ae260..e088290 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -445,6 +445,7 @@ struct mlx4_caps {
 	u8			eqe_factor;
 	u32			userspace_caps; /* userspace must be aware of these */
 	u32			function_caps;  /* VFs must be aware of these */
+	u16			hca_core_clock;
 };
 
 struct mlx4_buf_list {
-- 
1.7.8.2
