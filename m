From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 10/13] net/mlx4_core: Add helper to query counters
Date: Wed, 10 Jun 2015 17:59:35 +0300
Message-ID: <1433948378-17570-11-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38142 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751318AbbFJPCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:02:33 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

This is an infrastructure step for querying VF and PF counters.

This code was in the IB driver, move it to the mlx4 core driver
so it will be accessible for more use cases.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/mad.c         |   32 ++++------------
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   57 ++++++++++++++++++++++++++++++
 include/linux/mlx4/cmd.h                 |    3 ++
 include/linux/mlx4/device.h              |    8 ++++
 4 files changed, 76 insertions(+), 24 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index bc698b1..bc09b4e 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -64,14 +64,6 @@ enum {
 #define GUID_TBL_BLK_NUM_ENTRIES 8
 #define GUID_TBL_BLK_SIZE (GUID_TBL_ENTRY_SIZE * GUID_TBL_BLK_NUM_ENTRIES)
 
-/* Counters should be saturate once they reach their maximum value */
-#define ASSIGN_32BIT_COUNTER(counter, value) do {\
-	if ((value) > U32_MAX)			 \
-		counter = cpu_to_be32(U32_MAX); \
-	else					 \
-		counter = cpu_to_be32(value);	 \
-} while (0)
-
 struct mlx4_mad_rcv_buf {
 	struct ib_grh grh;
 	u8 payload[256];
@@ -828,31 +820,25 @@ static int iboe_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
 			struct ib_wc *in_wc, struct ib_grh *in_grh,
 			struct ib_mad *in_mad, struct ib_mad *out_mad)
 {
-	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_counter counter_stats;
 	struct mlx4_ib_dev *dev = to_mdev(ibdev);
 	int err;
-	u32 inmod = dev->counters[port_num - 1].index & 0xffff;
-	u8 mode;
 
 	if (in_mad->mad_hdr.mgmt_class != IB_MGMT_CLASS_PERF_MGMT)
 		return -EINVAL;
 
-	mailbox = mlx4_alloc_cmd_mailbox(dev->dev);
-	if (IS_ERR(mailbox))
-		return IB_MAD_RESULT_FAILURE;
-
-	err = mlx4_cmd_box(dev->dev, 0, mailbox->dma, inmod, 0,
-			   MLX4_CMD_QUERY_IF_STAT, MLX4_CMD_TIME_CLASS_C,
-			   MLX4_CMD_WRAPPED);
+	memset(&counter_stats, 0, sizeof(counter_stats));
+	err = mlx4_get_counter_stats(dev->dev,
+				     dev->counters[port_num - 1].index,
+				     &counter_stats, 0);
 	if (err)
 		err = IB_MAD_RESULT_FAILURE;
 	else {
 		memset(out_mad->data, 0, sizeof out_mad->data);
-		mode = ((struct mlx4_counter *)mailbox->buf)->counter_mode;
-		switch (mode & 0xf) {
+		switch (counter_stats.counter_mode & 0xf) {
 		case 0:
-			edit_counter(mailbox->buf,
-						(void *)(out_mad->data + 40));
+			edit_counter(&counter_stats,
+				     (void *)(out_mad->data + 40));
 			err = IB_MAD_RESULT_SUCCESS | IB_MAD_RESULT_REPLY;
 			break;
 		default:
@@ -860,8 +846,6 @@ static int iboe_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
 		}
 	}
 
-	mlx4_free_cmd_mailbox(dev->dev, mailbox);
-
 	return err;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 91d8344..4495bbd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -49,6 +49,7 @@
 #include "mlx4.h"
 #include "fw.h"
 #include "fw_qos.h"
+#include "mlx4_stats.h"
 
 #define CMD_POLL_TOKEN 0xffff
 #define INBOX_MASK	0xffffffffffffff00ULL
@@ -3166,6 +3167,62 @@ int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_stat
 }
 EXPORT_SYMBOL_GPL(mlx4_set_vf_link_state);
 
+int mlx4_get_counter_stats(struct mlx4_dev *dev, int counter_index,
+			   struct mlx4_counter *counter_stats, int reset)
+{
+	struct mlx4_cmd_mailbox *mailbox = NULL;
+	struct mlx4_counter *tmp_counter;
+	int err;
+	u32 if_stat_in_mod;
+
+	if (!counter_stats)
+		return -EINVAL;
+
+	if (counter_index == MLX4_SINK_COUNTER_INDEX(dev))
+		return 0;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	memset(mailbox->buf, 0, sizeof(struct mlx4_counter));
+	if_stat_in_mod = counter_index;
+	if (reset)
+		if_stat_in_mod |= MLX4_QUERY_IF_STAT_RESET;
+	err = mlx4_cmd_box(dev, 0, mailbox->dma,
+			   if_stat_in_mod, 0,
+			   MLX4_CMD_QUERY_IF_STAT,
+			   MLX4_CMD_TIME_CLASS_C,
+			   MLX4_CMD_NATIVE);
+	if (err) {
+		mlx4_dbg(dev, "%s: failed to read statistics for counter index %d\n",
+			 __func__, counter_index);
+		goto if_stat_out;
+	}
+	tmp_counter = (struct mlx4_counter *)mailbox->buf;
+	counter_stats->counter_mode = tmp_counter->counter_mode;
+	if (counter_stats->counter_mode == 0) {
+		counter_stats->rx_frames =
+			cpu_to_be64(be64_to_cpu(counter_stats->rx_frames) +
+				    be64_to_cpu(tmp_counter->rx_frames));
+		counter_stats->tx_frames =
+			cpu_to_be64(be64_to_cpu(counter_stats->tx_frames) +
+				    be64_to_cpu(tmp_counter->tx_frames));
+		counter_stats->rx_bytes =
+			cpu_to_be64(be64_to_cpu(counter_stats->rx_bytes) +
+				    be64_to_cpu(tmp_counter->rx_bytes));
+		counter_stats->tx_bytes =
+			cpu_to_be64(be64_to_cpu(counter_stats->tx_bytes) +
+				    be64_to_cpu(tmp_counter->tx_bytes));
+	}
+
+if_stat_out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_get_counter_stats);
+
 int mlx4_vf_smi_enabled(struct mlx4_dev *dev, int slave, int port)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index f62e7cf..5dffc86 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -35,6 +35,7 @@
 
 #include <linux/dma-mapping.h>
 #include <linux/if_link.h>
+#include <linux/mlx4/device.h>
 
 enum {
 	/* initialization and general commands */
@@ -300,6 +301,8 @@ static inline int mlx4_cmd_imm(struct mlx4_dev *dev, u64 in_param, u64 *out_para
 struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev);
 void mlx4_free_cmd_mailbox(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox);
 
+int mlx4_get_counter_stats(struct mlx4_dev *dev, int counter_index,
+			   struct mlx4_counter *counter_stats, int reset);
 u32 mlx4_comm_get_version(void);
 int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac);
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 4820080..efe80c7 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -771,6 +771,14 @@ union mlx4_ext_av {
 	struct mlx4_eth_av	eth;
 };
 
+/* Counters should be saturate once they reach their maximum value */
+#define ASSIGN_32BIT_COUNTER(counter, value) do {	\
+	if ((value) > U32_MAX)				\
+		counter = cpu_to_be32(U32_MAX);		\
+	else						\
+		counter = cpu_to_be32(value);		\
+} while (0)
+
 struct mlx4_counter {
 	u8	reserved1[3];
 	u8	counter_mode;
-- 
1.7.1
