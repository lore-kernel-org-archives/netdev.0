From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 4/6] net/mlx4_core: Fixes for VF / Guest startup flow
Date: Wed, 30 May 2012 22:14:53 +0300
Message-ID: <1338405295-15427-5-git-send-email-yevgenyp@mellanox.com>
References: <1338405295-15427-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:41216 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751122Ab2E3TPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 15:15:03 -0400
In-Reply-To: <1338405295-15427-1-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

- pass the following parameters:
  - firmware version (added QUERY_FW paravirtualization for that)

  - disable Blueflame on slaves. KVM disables write combining on guests,
    and we get better performance without BF in this case. (This requires
    QUERY_DEV_CAP paravirtualization, also in this commit)

  - max qp rdma as destination

- get rid of a chunk of "if (0)" dead code

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  |    4 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c   |   46 +++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c |   17 +++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |   10 ++++++
 4 files changed, 63 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 1bcead1..842c8ce 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -617,7 +617,7 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.out_is_imm = false,
 		.encode_slave_id = false,
 		.verify = NULL,
-		.wrapper = NULL
+		.wrapper = mlx4_QUERY_FW_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_QUERY_HCA,
@@ -635,7 +635,7 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.out_is_imm = false,
 		.encode_slave_id = false,
 		.verify = NULL,
-		.wrapper = NULL
+		.wrapper = mlx4_QUERY_DEV_CAP_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_QUERY_FUNC_CAP,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 68f5cd6..7f2a4a6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -669,6 +669,28 @@ out:
 	return err;
 }
 
+int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
+			       struct mlx4_vhcr *vhcr,
+			       struct mlx4_cmd_mailbox *inbox,
+			       struct mlx4_cmd_mailbox *outbox,
+			       struct mlx4_cmd_info *cmd)
+{
+	int	err = 0;
+	u8	field;
+
+	err = mlx4_cmd_box(dev, 0, outbox->dma, 0, 0, MLX4_CMD_QUERY_DEV_CAP,
+			   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
+	if (err)
+		return err;
+
+	/* For guests, report Blueflame disabled */
+	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_BF_OFFSET);
+	field &= 0x7f;
+	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_BF_OFFSET);
+
+	return 0;
+}
+
 int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			    struct mlx4_vhcr *vhcr,
 			    struct mlx4_cmd_mailbox *inbox,
@@ -860,6 +882,9 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 		((fw_ver & 0xffff0000ull) >> 16) |
 		((fw_ver & 0x0000ffffull) << 16);
 
+	if (mlx4_is_slave(dev))
+		goto out;
+
 	MLX4_GET(lg, outbox, QUERY_FW_PPF_ID);
 	dev->caps.function = lg;
 
@@ -927,6 +952,27 @@ out:
 	return err;
 }
 
+int mlx4_QUERY_FW_wrapper(struct mlx4_dev *dev, int slave,
+			  struct mlx4_vhcr *vhcr,
+			  struct mlx4_cmd_mailbox *inbox,
+			  struct mlx4_cmd_mailbox *outbox,
+			  struct mlx4_cmd_info *cmd)
+{
+	u8 *outbuf;
+	int err;
+
+	outbuf = outbox->buf;
+	err = mlx4_cmd_box(dev, 0, outbox->dma, 0, 0, MLX4_CMD_QUERY_FW,
+			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
+	if (err)
+		return err;
+
+	/* for slaves, zero out everything except FW version */
+	outbuf[0] = outbuf[1] = 0;
+	memset(&outbuf[8], 0, QUERY_FW_OUT_SIZE - 8);
+	return 0;
+}
+
 static void get_board_id(void *vsd, char *board_id)
 {
 	int i;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2fe9fe5..7f71be0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -430,12 +430,17 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	mlx4_log_num_mgm_entry_size = hca_param.log_mc_entry_sz;
 
 	memset(&dev_cap, 0, sizeof(dev_cap));
+	dev->caps.max_qp_dest_rdma = 1 << hca_param.log_rd_per_qp;
 	err = mlx4_dev_cap(dev, &dev_cap);
 	if (err) {
 		mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting.\n");
 		return err;
 	}
 
+	err = mlx4_QUERY_FW(dev);
+	if (err)
+		mlx4_err(dev, "QUERY_FW command failed: could not get FW version.\n");
+
 	page_size = ~dev->caps.page_size_cap + 1;
 	mlx4_warn(dev, "HCA minimum page size:%d\n", page_size);
 	if (page_size > PAGE_SIZE) {
@@ -499,18 +504,6 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		return -ENODEV;
 	}
 
-#if 0
-	mlx4_warn(dev, "sqp_demux:%d\n", dev->caps.sqp_demux);
-	mlx4_warn(dev, "num_uars:%d reserved_uars:%d uar region:0x%x bar2:0x%llx\n",
-		  dev->caps.num_uars, dev->caps.reserved_uars,
-		  dev->caps.uar_page_size * dev->caps.num_uars,
-		  pci_resource_len(dev->pdev, 2));
-	mlx4_warn(dev, "num_eqs:%d reserved_eqs:%d\n", dev->caps.num_eqs,
-		  dev->caps.reserved_eqs);
-	mlx4_warn(dev, "num_pds:%d reserved_pds:%d slave_pd_shift:%d pd_base:%d\n",
-		  dev->caps.num_pds, dev->caps.reserved_pds,
-		  dev->caps.slave_pd_shift, dev->caps.pd_base);
-#endif
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 86b6e5a..e5d2022 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1039,6 +1039,11 @@ int mlx4_init_resource_tracker(struct mlx4_dev *dev);
 void mlx4_free_resource_tracker(struct mlx4_dev *dev,
 				enum mlx4_res_tracker_free_type type);
 
+int mlx4_QUERY_FW_wrapper(struct mlx4_dev *dev, int slave,
+			  struct mlx4_vhcr *vhcr,
+			  struct mlx4_cmd_mailbox *inbox,
+			  struct mlx4_cmd_mailbox *outbox,
+			  struct mlx4_cmd_info *cmd);
 int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			  struct mlx4_vhcr *vhcr,
 			  struct mlx4_cmd_mailbox *inbox,
@@ -1054,6 +1059,11 @@ int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			    struct mlx4_cmd_mailbox *inbox,
 			    struct mlx4_cmd_mailbox *outbox,
 			    struct mlx4_cmd_info *cmd);
+int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
+			       struct mlx4_vhcr *vhcr,
+			       struct mlx4_cmd_mailbox *inbox,
+			       struct mlx4_cmd_mailbox *outbox,
+			       struct mlx4_cmd_info *cmd);
 int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			    struct mlx4_vhcr *vhcr,
 			    struct mlx4_cmd_mailbox *inbox,
-- 
1.7.1
