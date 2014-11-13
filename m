From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/7] net/mlx4_core: Add QUERY_FUNC firmware command
Date: Thu, 13 Nov 2014 14:45:31 +0200
Message-ID: <1415882733-3084-6-git-send-email-ogerlitz@mellanox.com>
References: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46593 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932840AbaKMMpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:45:44 -0500
In-Reply-To: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

QUERY_FUNC firmware command could be used in order to query the
number of EQs, reserved EQs, etc for a specific function.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |   56 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.h |   11 ++++++
 2 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index f1a6718..b3bbeb9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -177,6 +177,62 @@ int mlx4_MOD_STAT_CFG(struct mlx4_dev *dev, struct mlx4_mod_stat_cfg *cfg)
 	return err;
 }
 
+int mlx4_QUERY_FUNC(struct mlx4_dev *dev, struct mlx4_func *func, int slave)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	u32 *outbox;
+	u8 in_modifier;
+	u8 field;
+	u16 field16;
+	int err;
+
+#define QUERY_FUNC_BUS_OFFSET			0x00
+#define QUERY_FUNC_DEVICE_OFFSET		0x01
+#define QUERY_FUNC_FUNCTION_OFFSET		0x01
+#define QUERY_FUNC_PHYSICAL_FUNCTION_OFFSET	0x03
+#define QUERY_FUNC_RSVD_EQS_OFFSET		0x04
+#define QUERY_FUNC_MAX_EQ_OFFSET		0x06
+#define QUERY_FUNC_RSVD_UARS_OFFSET		0x0b
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	outbox = mailbox->buf;
+
+	in_modifier = slave;
+	mlx4_dbg(dev, "%s for VF %d\n", __func__, in_modifier);
+
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, in_modifier, 0,
+			   MLX4_CMD_QUERY_FUNC,
+			   MLX4_CMD_TIME_CLASS_A,
+			   MLX4_CMD_NATIVE);
+	if (err)
+		goto out;
+
+	MLX4_GET(field, outbox, QUERY_FUNC_BUS_OFFSET);
+	func->bus = field & 0xf;
+	MLX4_GET(field, outbox, QUERY_FUNC_DEVICE_OFFSET);
+	func->device = field & 0xf1;
+	MLX4_GET(field, outbox, QUERY_FUNC_FUNCTION_OFFSET);
+	func->function = field & 0x7;
+	MLX4_GET(field, outbox, QUERY_FUNC_PHYSICAL_FUNCTION_OFFSET);
+	func->physical_function = field & 0xf;
+	MLX4_GET(field16, outbox, QUERY_FUNC_RSVD_EQS_OFFSET);
+	func->rsvd_eqs = field16 & 0xffff;
+	MLX4_GET(field16, outbox, QUERY_FUNC_MAX_EQ_OFFSET);
+	func->max_eq = field16 & 0xffff;
+	MLX4_GET(field, outbox, QUERY_FUNC_RSVD_UARS_OFFSET);
+	func->rsvd_uars = field & 0x0f;
+
+	mlx4_dbg(dev, "Bus: %d, Device: %d, Function: %d, Physical function: %d, Max EQs: %d, Reserved EQs: %d, Reserved UARs: %d\n",
+		 func->bus, func->device, func->function, func->physical_function,
+		 func->max_eq, func->rsvd_eqs, func->rsvd_uars);
+
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
 int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_vhcr *vhcr,
 				struct mlx4_cmd_mailbox *inbox,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 694557e..48c11b5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -145,6 +145,16 @@ struct mlx4_func_cap {
 	u64	phys_port_id;
 };
 
+struct mlx4_func {
+	int	bus;
+	int	device;
+	int	function;
+	int	physical_function;
+	int	rsvd_eqs;
+	int	max_eq;
+	int	rsvd_uars;
+};
+
 struct mlx4_adapter {
 	char board_id[MLX4_BOARD_ID_LEN];
 	u8   inta_pin;
@@ -211,6 +221,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_cmd_mailbox *inbox,
 				struct mlx4_cmd_mailbox *outbox,
 				struct mlx4_cmd_info *cmd);
+int mlx4_QUERY_FUNC(struct mlx4_dev *dev, struct mlx4_func *func, int slave);
 int mlx4_MAP_FA(struct mlx4_dev *dev, struct mlx4_icm *icm);
 int mlx4_UNMAP_FA(struct mlx4_dev *dev);
 int mlx4_RUN_FW(struct mlx4_dev *dev);
-- 
1.7.1
