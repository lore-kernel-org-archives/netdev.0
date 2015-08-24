From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] mlxsw: expose EMAD transactions statistics via debugfs
Date: Mon, 24 Aug 2015 16:45:46 +0200
Message-ID: <1440427547-8539-3-git-send-email-jiri@resnulli.us>
References: <1440427547-8539-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37407 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594AbbHXOpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 10:45:53 -0400
Received: by widdq5 with SMTP id dq5so74452752wid.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 07:45:52 -0700 (PDT)
In-Reply-To: <1440427547-8539-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 51 ++++++++++++++++++++++++++++--
 1 file changed, 48 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 0415ff6..6ee3f45 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -98,6 +98,12 @@ struct mlxsw_core {
 		bool trans_active;
 		struct mutex lock; /* One EMAD transaction at a time. */
 		bool use_emad;
+		struct {
+			u64 trans;
+			u32 fails;
+			u32 retries;
+			u32 timeouts;
+		} stats;
 	} emad;
 	struct mlxsw_core_pcpu_stats __percpu *pcpu_stats;
 	struct dentry *dbg_dir;
@@ -390,6 +396,7 @@ static int __mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
 		dev_warn(mlxsw_core->bus_info->dev, "EMAD timed-out (tid=%llx)\n",
 			 mlxsw_core->emad.tid);
 		mlxsw_core->emad.trans_active = false;
+		mlxsw_core->emad.stats.timeouts++;
 		return -EIO;
 	}
 
@@ -463,8 +470,10 @@ retry:
 		if (!err || err != -EAGAIN)
 			goto out;
 	}
-	if (n_retry++ < MLXSW_EMAD_MAX_RETRY)
+	if (n_retry++ < MLXSW_EMAD_MAX_RETRY) {
+		mlxsw_core->emad.stats.retries++;
 		goto retry;
+	}
 
 out:
 	dev_kfree_skb(skb);
@@ -671,6 +680,35 @@ static const struct file_operations mlxsw_core_rx_stats_dbg_ops = {
 	.llseek = seq_lseek
 };
 
+static int mlxsw_core_emad_stats_dbg_read(struct seq_file *file, void *data)
+{
+	struct mlxsw_core *mlxsw_core = file->private;
+
+	if (mutex_lock_interruptible(&mlxsw_core->emad.lock))
+		return -EINTR;
+	seq_printf(file, "transactions: %llu\n", mlxsw_core->emad.stats.trans);
+	seq_printf(file, "fails: %u\n", mlxsw_core->emad.stats.fails);
+	seq_printf(file, "retries: %u\n", mlxsw_core->emad.stats.retries);
+	seq_printf(file, "timeouts: %u\n", mlxsw_core->emad.stats.timeouts);
+	mutex_unlock(&mlxsw_core->emad.lock);
+	return 0;
+}
+
+static int mlxsw_core_emad_stats_dbg_open(struct inode *inode, struct file *f)
+{
+	struct mlxsw_core *mlxsw_core = inode->i_private;
+
+	return single_open(f, mlxsw_core_emad_stats_dbg_read, mlxsw_core);
+}
+
+static const struct file_operations mlxsw_core_emad_stats_dbg_ops = {
+	.owner = THIS_MODULE,
+	.open = mlxsw_core_emad_stats_dbg_open,
+	.release = single_release,
+	.read = seq_read,
+	.llseek = seq_lseek
+};
+
 static void mlxsw_core_buf_dump_dbg(struct mlxsw_core *mlxsw_core,
 				    const char *buf, size_t size)
 {
@@ -768,6 +806,8 @@ static int mlxsw_core_debugfs_init(struct mlxsw_core *mlxsw_core)
 	mlxsw_core->dbg.psid_blob.size = sizeof(bus_info->psid);
 	debugfs_create_blob("psid", S_IRUGO, mlxsw_core->dbg_dir,
 			    &mlxsw_core->dbg.psid_blob);
+	debugfs_create_file("emad_stats", S_IRUGO, mlxsw_core->dbg_dir,
+			    mlxsw_core, &mlxsw_core_emad_stats_dbg_ops);
 	return 0;
 }
 
@@ -1107,8 +1147,10 @@ retry:
 	err = mlxsw_cmd_access_reg(mlxsw_core, in_mbox, out_mbox);
 	if (!err) {
 		err = mlxsw_emad_process_status(mlxsw_core, out_mbox);
-		if (err == -EAGAIN && n_retry++ < MLXSW_EMAD_MAX_RETRY)
+		if (err == -EAGAIN && n_retry++ < MLXSW_EMAD_MAX_RETRY) {
+			mlxsw_core->emad.stats.retries++;
 			goto retry;
+		}
 	}
 
 	if (!err)
@@ -1137,6 +1179,7 @@ static int mlxsw_core_reg_access(struct mlxsw_core *mlxsw_core,
 		return -EINTR;
 	}
 
+	mlxsw_core->emad.stats.trans++;
 	cur_tid = mlxsw_core->emad.tid;
 	dev_dbg(mlxsw_core->bus_info->dev, "Reg access (tid=%llx,reg_id=%x(%s),type=%s)\n",
 		cur_tid, reg->id, mlxsw_reg_id_str(reg->id),
@@ -1153,10 +1196,12 @@ static int mlxsw_core_reg_access(struct mlxsw_core *mlxsw_core,
 		err = mlxsw_core_reg_access_emad(mlxsw_core, reg,
 						 payload, type);
 
-	if (err)
+	if (err) {
 		dev_err(mlxsw_core->bus_info->dev, "Reg access failed (tid=%llx,reg_id=%x(%s),type=%s)\n",
 			cur_tid, reg->id, mlxsw_reg_id_str(reg->id),
 			mlxsw_core_reg_access_type_str(type));
+		mlxsw_core->emad.stats.fails++;
+	}
 
 	mutex_unlock(&mlxsw_core->emad.lock);
 	return err;
-- 
1.9.3
