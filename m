From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/3] mlx4: Add support for CONFIG_DEV command
Date: Thu, 27 Mar 2014 14:02:03 +0200
Message-ID: <1395921724-2244-3-git-send-email-ogerlitz@mellanox.com>
References: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55707 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751242AbaC0MCS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:02:18 -0400
In-Reply-To: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce the CONFIG_DEV firmware command which we will use to
configure the UDP port assumed by the firmware for the VXLAN offloads.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |    9 ++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c  |   40 ++++++++++++++++++++++++++++++
 include/linux/mlx4/cmd.h                 |    1 +
 include/linux/mlx4/device.h              |    2 +
 4 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 2fd61b6..78099ea 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -955,6 +955,15 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.wrapper = NULL
 	},
 	{
+		.opcode = MLX4_CMD_CONFIG_DEV,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_CMD_EPERM_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_ALLOC_RES,
 		.has_inbox = false,
 		.has_outbox = false,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 6bd33e2..d16a4d1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1779,6 +1779,46 @@ int mlx4_CLOSE_HCA(struct mlx4_dev *dev, int panic)
 			MLX4_CMD_NATIVE);
 }
 
+struct mlx4_config_dev {
+	__be32	update_flags;
+	__be32	rsdv1[3];
+	__be16	vxlan_udp_dport;
+	__be16	rsvd2;
+};
+
+#define MLX4_VXLAN_UDP_DPORT (1 << 0)
+
+static int mlx4_CONFIG_DEV(struct mlx4_dev *dev, struct mlx4_config_dev *config_dev)
+{
+	int err;
+	struct mlx4_cmd_mailbox *mailbox;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	memcpy(mailbox->buf, config_dev, sizeof(*config_dev));
+
+	err = mlx4_cmd(dev, mailbox->dma, 0, 0, MLX4_CMD_CONFIG_DEV,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port)
+{
+	struct mlx4_config_dev config_dev;
+
+	memset(&config_dev, 0, sizeof(config_dev));
+	config_dev.update_flags    = cpu_to_be32(MLX4_VXLAN_UDP_DPORT);
+	config_dev.vxlan_udp_dport = udp_port;
+
+	return mlx4_CONFIG_DEV(dev, &config_dev);
+}
+EXPORT_SYMBOL_GPL(mlx4_config_vxlan_port);
+
+
 int mlx4_SET_ICM_SIZE(struct mlx4_dev *dev, u64 icm_size, u64 *aux_pages)
 {
 	int ret = mlx4_cmd_imm(dev, icm_size, aux_pages, 0, 0,
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 0099856..c845036 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -125,6 +125,7 @@ enum {
 	/* miscellaneous commands */
 	MLX4_CMD_DIAG_RPRT	 = 0x30,
 	MLX4_CMD_NOP		 = 0x31,
+	MLX4_CMD_CONFIG_DEV	 = 0x3a,
 	MLX4_CMD_ACCESS_MEM	 = 0x2e,
 	MLX4_CMD_SET_VEP	 = 0x52,
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 6b39983..d986c97 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1232,4 +1232,6 @@ struct mlx4_slaves_pport mlx4_phys_to_slaves_pport_actv(
 int mlx4_phys_to_slave_port(struct mlx4_dev *dev, int slave, int port);
 
 int mlx4_get_base_gid_ix(struct mlx4_dev *dev, int slave, int port);
+
+int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port);
 #endif /* MLX4_DEVICE_H */
-- 
1.7.1
