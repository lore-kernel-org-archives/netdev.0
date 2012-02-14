From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 4/7] mlx4: remove unnecessary variables and arguments
Date: Tue, 14 Feb 2012 18:37:46 +0200
Message-ID: <4F3A8DDA.6090402@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:41118 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756448Ab2BNQku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 11:40:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

mlx4_qp_attach/detach_common() don't use hash variable, move it to find_entry()
static find_entry() in mcg.c doesn't use steer argument

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index ca574d8..da63874 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -562,14 +562,14 @@ out_mutex:
  */
 static int find_entry(struct mlx4_dev *dev, u8 port,
 		      u8 *gid, enum mlx4_protocol prot,
-		      enum mlx4_steer_type steer,
 		      struct mlx4_cmd_mailbox *mgm_mailbox,
-		      u16 *hash, int *prev, int *index)
+		      int *prev, int *index)
 {
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mgm *mgm = mgm_mailbox->buf;
 	u8 *mgid;
 	int err;
+	u16 hash;
 	u8 op_mod = (prot == MLX4_PROT_ETH) ?
 		!!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER) : 0;
 
@@ -580,15 +580,15 @@ static int find_entry(struct mlx4_dev *dev, u8 port,
 
 	memcpy(mgid, gid, 16);
 
-	err = mlx4_GID_HASH(dev, mailbox, hash, op_mod);
+	err = mlx4_GID_HASH(dev, mailbox, &hash, op_mod);
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	if (err)
 		return err;
 
 	if (0)
-		mlx4_dbg(dev, "Hash for %pI6 is %04x\n", gid, *hash);
+		mlx4_dbg(dev, "Hash for %pI6 is %04x\n", gid, hash);
 
-	*index = *hash;
+	*index = hash;
 	*prev  = -1;
 
 	do {
@@ -597,7 +597,7 @@ static int find_entry(struct mlx4_dev *dev, u8 port,
 			return err;
 
 		if (!(be32_to_cpu(mgm->members_count) & 0xffffff)) {
-			if (*index != *hash) {
+			if (*index != hash) {
 				mlx4_err(dev, "Found zero MGID in AMGM.\n");
 				err = -EINVAL;
 			}
@@ -624,7 +624,6 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mgm *mgm;
 	u32 members_count;
-	u16 hash;
 	int index, prev;
 	int link = 0;
 	int i;
@@ -638,8 +637,8 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	mgm = mailbox->buf;
 
 	mutex_lock(&priv->mcg_table.mutex);
-	err = find_entry(dev, port, gid, prot, steer,
-			 mailbox, &hash, &prev, &index);
+	err = find_entry(dev, port, gid, prot,
+			 mailbox, &prev, &index);
 	if (err)
 		goto out;
 
@@ -733,7 +732,6 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mgm *mgm;
 	u32 members_count;
-	u16 hash;
 	int prev, index;
 	int i, loc;
 	int err;
@@ -747,8 +745,8 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 
 	mutex_lock(&priv->mcg_table.mutex);
 
-	err = find_entry(dev, port, gid, prot, steer,
-			 mailbox, &hash, &prev, &index);
+	err = find_entry(dev, port, gid, prot,
+			 mailbox, &prev, &index);
 	if (err)
 		goto out;
 
-- 
1.5.4.3
