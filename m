From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH 2/8] net/mlx4_core: set port QoS attributes
Date: Tue, 13 Mar 2012 19:21:57 +0200
Message-ID: <1331659323-12904-3-git-send-email-amirv@mellanox.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:52893 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758592Ab2CMRWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 13:22:22 -0400
In-Reply-To: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Adding QoS firmware commands:
- mlx4_en_SET_PORT_PRIO2TC - set UP <=> TC
- mlx4_en_SET_PORT_SCHEDULER - set promised BW, max BW and PG number

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.h |    2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h    |   20 ++++++++
 drivers/net/ethernet/mellanox/mlx4/port.c    |   62 ++++++++++++++++++++++++++
 include/linux/mlx4/cmd.h                     |    4 ++
 include/linux/mlx4/device.h                  |    3 +
 5 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.h b/drivers/net/ethernet/mellanox/mlx4/en_port.h
index 6934fd7..745090b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.h
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.h
@@ -39,6 +39,8 @@
 #define SET_PORT_PROMISC_SHIFT	31
 #define SET_PORT_MC_PROMISC_SHIFT	30
 
+#define MLX4_EN_NUM_TC		8
+
 #define VLAN_FLTR_SIZE	128
 struct mlx4_set_vlan_fltr_mbox {
 	__be32 entry[VLAN_FLTR_SIZE];
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 5da51b9..33bf39d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -53,6 +53,26 @@
 #define DRV_VERSION	"1.1"
 #define DRV_RELDATE	"Dec, 2011"
 
+#define MLX4_NUM_UP		8
+#define MLX4_NUM_TC		8
+#define MLX4_RATELIMIT_UNITS 3 /* 100 Mbps */
+#define MLX4_RATELIMIT_DEFAULT 0xffff
+
+struct mlx4_set_port_prio2tc_context {
+	u8 prio2tc[4];
+};
+
+struct mlx4_port_scheduler_tc_cfg_be {
+	__be16 pg;
+	__be16 bw_precentage;
+	__be16 max_bw_units; /* 3-100Mbps, 4-1Gbps, other values - reserved */
+	__be16 max_bw_value;
+};
+
+struct mlx4_set_port_scheduler_context {
+	struct mlx4_port_scheduler_tc_cfg_be tc[MLX4_NUM_TC];
+};
+
 enum {
 	MLX4_HCR_BASE		= 0x80680,
 	MLX4_HCR_SIZE		= 0x0001c,
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 98e7762..762bbda 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -858,6 +858,68 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 }
 EXPORT_SYMBOL(mlx4_SET_PORT_qpn_calc);
 
+int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_prio2tc_context *context;
+	int err;
+	u32 in_mod;
+	int i;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	memset(context, 0, sizeof *context);
+
+	for (i = 0; i < MLX4_NUM_UP; i += 2)
+		context->prio2tc[i >> 1] = prio2tc[i] << 4 | prio2tc[i + 1];
+
+	in_mod = MLX4_SET_PORT_PRIO2TC << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_PRIO2TC);
+
+int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
+		u8 *pg, u16 *ratelimit)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_scheduler_context *context;
+	int err;
+	u32 in_mod;
+	int i;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	memset(context, 0, sizeof *context);
+
+	for (i = 0; i < MLX4_NUM_TC; i++) {
+		struct mlx4_port_scheduler_tc_cfg_be *tc = &context->tc[i];
+		u16 r = ratelimit && ratelimit[i] ? ratelimit[i] :
+			MLX4_RATELIMIT_DEFAULT;
+
+		tc->pg = htons(pg[i]);
+		tc->bw_precentage = htons(tc_tx_bw[i]);
+
+		tc->max_bw_units = htons(MLX4_RATELIMIT_UNITS);
+		tc->max_bw_value = htons(r);
+	}
+
+	in_mod = MLX4_SET_PORT_SCHEDULER << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_SCHEDULER);
+
 int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_vhcr *vhcr,
 				struct mlx4_cmd_mailbox *inbox,
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 9958ff2..1f3860a 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -150,6 +150,10 @@ enum {
 	/* statistics commands */
 	MLX4_CMD_QUERY_IF_STAT	 = 0X54,
 	MLX4_CMD_SET_IF_STAT	 = 0X55,
+
+	/* set port opcode modifiers */
+	MLX4_SET_PORT_PRIO2TC = 0x8,
+	MLX4_SET_PORT_SCHEDULER  = 0x9,
 };
 
 enum {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 44d8144..20c706f 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -626,6 +626,9 @@ int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
 int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc);
+int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc);
+int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
+		u8 *pg, u16 *ratelimit);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
 void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index);
-- 
1.7.8.2
