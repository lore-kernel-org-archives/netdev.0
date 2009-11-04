From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 24/25] mlx4: VLAN filter management by master function.
Date: Wed, 04 Nov 2009 17:32:23 +0200
Message-ID: <4AF19E87.2020901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:34816 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755892AbZKDMeh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 07:34:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VLAN filter is a bitmap of 4096 bits.
The mster function sets the VLAN filter as a bitwise OR of the filters
of each one of the slaves.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c     |    2 +-
 drivers/net/mlx4/en_port.c |   35 ---------------------
 drivers/net/mlx4/en_port.h |    5 ---
 drivers/net/mlx4/mlx4.h    |    9 +++++
 drivers/net/mlx4/port.c    |   72 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 82 insertions(+), 41 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 3b0b22a..7eb4394 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -598,7 +598,7 @@ static struct mlx4_cmd_info {
 	{MLX4_CMD_DIAG_RPRT,       0, 1, 0, NULL, NULL}, /* need verifier */
 
 	/* Ethernet specific commands */
-	{MLX4_CMD_SET_VLAN_FLTR,   1, 0, 0, NULL, NULL}, /* need wrapper */
+	{MLX4_CMD_SET_VLAN_FLTR,   1, 0, 0, NULL, mlx4_SET_VLAN_FLTR_wrapper},
 	{MLX4_CMD_SET_MCAST_FLTR,  0, 0, 0, NULL, mlx4_SET_MCAST_FLTR_wrapper},
 	{MLX4_CMD_DUMP_ETH_STATS,  0, 1, 0, NULL, NULL}, /* need wrapper */
 };
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index 6dc07c9..a0e8a97 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -41,41 +41,6 @@
 #include "mlx4_en.h"
 
 
-int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_set_vlan_fltr_mbox *filter;
-	int i;
-	int j;
-	int index = 0;
-	u32 entry;
-	int err = 0;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-
-	filter = mailbox->buf;
-	if (grp) {
-		memset(filter, 0, sizeof *filter);
-		for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
-			entry = 0;
-			for (j = 0; j < 32; j++)
-				if (vlan_group_get_device(grp, index++))
-					entry |= 1 << j;
-			filter->entry[i] = cpu_to_be32(entry);
-		}
-	} else {
-		/* When no vlans are configured we block all vlans */
-		memset(filter, 0, sizeof(*filter));
-	}
-	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_VLAN_FLTR,
-		       MLX4_CMD_TIME_CLASS_B);
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-
-
 int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx)
 {
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index c62abd7..2edb851 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -83,11 +83,6 @@ struct mlx4_set_port_rqp_calc_context {
 	__be32 mcast;
 };
 
-#define VLAN_FLTR_SIZE	128
-struct mlx4_set_vlan_fltr_mbox {
-	__be32 entry[VLAN_FLTR_SIZE];
-};
-
 
 enum {
 	MLX4_MCAST_CONFIG       = 0,
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 7040671..0cb3be1 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -221,6 +221,11 @@ struct mlx4_mcast_entry {
 	u64 addr;
 };
 
+#define VLAN_FLTR_SIZE	128
+struct mlx4_vlan_fltr {
+	__be32 entry[VLAN_FLTR_SIZE];
+};
+
 struct mlx4_slave_state {
 	u8 comm_toggle;
 	u8 last_cmd;
@@ -230,6 +235,7 @@ struct mlx4_slave_state {
 	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
 	struct list_head mcast_filters[MLX4_MAX_PORTS + 1];
+	struct mlx4_vlan_fltr vlan_filter[MLX4_MAX_PORTS + 1];
 	u16 eq_pi;
 	u16 eq_ci;
 	int sqp_start;
@@ -560,5 +566,8 @@ int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
 int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
 				struct mlx4_cmd_mailbox *inbox,
 				struct mlx4_cmd_mailbox *outbox);
+int mlx4_SET_VLAN_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox);
 
 #endif /* MLX4_H */
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 1bc527c..1a790ef 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -32,6 +32,7 @@
 
 #include <linux/errno.h>
 #include <linux/if_ether.h>
+#include <linux/if_vlan.h>
 
 #include <linux/mlx4/cmd.h>
 
@@ -616,3 +617,74 @@ int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
 			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B);
 }
 EXPORT_SYMBOL(mlx4_SET_MCAST_FLTR);
+
+
+int mlx4_SET_VLAN_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+			       struct mlx4_cmd_mailbox *inbox,
+			       struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_vlan_fltr *filter;
+	struct mlx4_slave_state *s_state = &priv->mfunc.master.slave_state[slave];
+	int port = vhcr->in_modifier;
+	int i, j, err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	/* Update slave's Vlan filter */
+	memcpy(s_state->vlan_filter[port].entry, inbox->buf,
+	       sizeof(struct mlx4_vlan_fltr));
+
+	/* We configure the Vlan filter to allow the vlans of
+	 * all slaves */
+	filter = mailbox->buf;
+	memset(filter, 0, sizeof(*filter));
+	for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
+		for (j = 0; j < dev->num_slaves; j++) {
+			s_state = &priv->mfunc.master.slave_state[j];
+			filter->entry[i] |= s_state->vlan_filter[port].entry[i];
+		}
+	}
+	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_VLAN_FLTR,
+		       MLX4_CMD_TIME_CLASS_B);
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_vlan_fltr *filter;
+	int i;
+	int j;
+	int index = 0;
+	u32 entry;
+	int err = 0;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	filter = mailbox->buf;
+	if (grp) {
+		memset(filter, 0, sizeof *filter);
+		for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
+			entry = 0;
+			for (j = 0; j < 32; j++)
+				if (vlan_group_get_device(grp, index++))
+					entry |= 1 << j;
+			filter->entry[i] = cpu_to_be32(entry);
+		}
+	} else {
+		/* When no vlans are configured we block all vlans */
+		memset(filter, 0, sizeof(*filter));
+	}
+	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_VLAN_FLTR,
+		       MLX4_CMD_TIME_CLASS_B);
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_VLAN_FLTR);
-- 
1.6.1.3




