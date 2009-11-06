From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 24/25 v2] mlx4: VLAN filter management by master function.
Date: Fri, 06 Nov 2009 05:10:29 +0200
Message-ID: <4AF393A5.70106@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43290 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759231AbZKFAMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 19:12:53 -0500
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
index f3d3a7b..4c472f3 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -939,7 +939,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL,
-		.wrapper = NULL /* need wrapper*/
+		.wrapper = mlx4_SET_VLAN_FLTR_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_SET_MCAST_FLTR,
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
index 1e65749..8ddffaf 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -78,11 +78,6 @@ struct mlx4_set_port_rqp_calc_context {
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
index 2476fb5..ec01ab3 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -225,6 +225,11 @@ struct mlx4_mcast_entry {
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
@@ -234,6 +239,7 @@ struct mlx4_slave_state {
 	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
 	struct list_head mcast_filters[MLX4_MAX_PORTS + 1];
+	struct mlx4_vlan_fltr vlan_filter[MLX4_MAX_PORTS + 1];
 	u16 eq_pi;
 	u16 eq_ci;
 	int sqp_start;
@@ -564,5 +570,8 @@ int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
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
1.5.3.7

From: Liran Liss <liranl@mellanox.co.il>





