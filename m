From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 05/23 v3] mlx4_core: slave multicast support
Date: Thu, 04 Feb 2010 17:55:03 +0200
Message-ID: <4B6AEDD7.2080203@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:46862 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933079Ab0BDPzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:55:06 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multicast table processing requires multiple related commands.
To keep things simple, low-level multicast handling is done only by the master;
a new virtual command is added to allow slaves to attach/detach QPs to mulitcast
groups at a higher abstraction level.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c   |    8 ++++++++
 drivers/net/mlx4/mcg.c   |   45 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/mlx4/mlx4.h  |    4 ++++
 include/linux/mlx4/cmd.h |    1 +
 4 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 533ce77..5433f3b 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -824,6 +824,14 @@ static struct mlx4_cmd_info {
 
 	/* Native multicast commands are not available for guests */
 	{
+		.opcode = MLX4_CMD_MCAST_ATTACH,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = mlx4_MCAST_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_DIAG_RPRT,
 		.has_inbox = false,
 		.has_outbox = true,
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index 5ccbce9..96f09ed 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -146,6 +146,45 @@ static int find_mgm(struct mlx4_dev *dev,
 	return err;
 }
 
+int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						     struct mlx4_cmd_mailbox *inbox,
+						     struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_qp qp; /* dummy for calling attach/detach */
+
+	qp.qpn = vhcr->in_modifier & 0xffffff;
+	if (vhcr->op_modifier)
+		return mlx4_multicast_attach(dev, &qp, inbox->buf, vhcr->in_modifier >> 31);
+	else
+		return mlx4_multicast_detach(dev, &qp, inbox->buf);
+}
+
+static int mlx4_MCAST(struct mlx4_dev *dev, struct mlx4_qp *qp,
+					    u8 gid[16], u8 attach,
+					    u8 block_loopback)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	int err;
+	int qpn;
+
+	if (!mlx4_is_slave(dev))
+		return -EBADF;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	memcpy(mailbox->buf, gid, 16);
+	qpn = qp->qpn;
+	if (attach && block_loopback)
+		qpn |= (1 << 31);
+
+	err = mlx4_cmd(dev, mailbox->dma, qpn, attach, MLX4_CMD_MCAST_ATTACH,
+						       MLX4_CMD_TIME_CLASS_A);
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback)
 {
@@ -159,6 +198,9 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	int i;
 	int err;
 
+	if (mlx4_is_slave(dev))
+		return mlx4_MCAST(dev, qp, gid, 1, block_mcast_loopback);
+
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
@@ -254,6 +296,9 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16])
 	int i, loc;
 	int err;
 
+	if (mlx4_is_slave(dev))
+		return mlx4_MCAST(dev, qp, gid, 0, 0);
+
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index d62427f..a7dcad6 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -505,4 +505,8 @@ void mlx4_init_vlan_table(struct mlx4_dev *dev, struct mlx4_vlan_table *table);
 int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port);
 int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps);
 
+int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						     struct mlx4_cmd_mailbox *inbox,
+						     struct mlx4_cmd_mailbox *outbox);
+
 #endif /* MLX4_H */
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 5450781..27327f7 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -128,6 +128,7 @@ enum {
 	MLX4_CMD_ALLOC_RES	 = 0xf00,
 	MLX4_CMD_FREE_RES	 = 0xf01,
 	MLX4_CMD_GET_EVENT	 = 0xf03,
+	MLX4_CMD_MCAST_ATTACH	 = 0xf05,
 
 	/* debug commands */
 	MLX4_CMD_QUERY_DEBUG_MSG = 0x2a,
-- 
1.6.1.3


