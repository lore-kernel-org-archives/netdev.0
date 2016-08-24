From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/7] mlxsw: spectrum: Limit number of FDB records per learning session
Date: Wed, 24 Aug 2016 12:00:23 +0200
Message-ID: <1472032829-6322-2-git-send-email-jiri@resnulli.us>
References: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35024 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932417AbcHXKBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:01:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id i5so1860332wmg.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:00:34 -0700 (PDT)
In-Reply-To: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now a learning session ended whenever the number of queried
records was zero. This turned out to be problematic in situations where
a large number of MACs (48K) had to be processed by the switch driver,
as RTNL mutex is held during the learning session.

Instead, limit the number of FDB records that can be processed in a
session to 64. This means that every time the device is queried for
learning notifications (currently, every 100ms), up to 64 records will
be processed by the switch driver.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  7 +++++++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 22 ++++++++++------------
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 1721098..b83d0a7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -591,6 +591,12 @@ static const struct mlxsw_reg_info mlxsw_reg_sfn = {
  */
 MLXSW_ITEM32(reg, sfn, swid, 0x00, 24, 8);
 
+/* reg_sfn_end
+ * Forces the current session to end.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, sfn, end, 0x04, 20, 1);
+
 /* reg_sfn_num_rec
  * Request: Number of learned notifications and aged-out notification
  * records requested.
@@ -605,6 +611,7 @@ static inline void mlxsw_reg_sfn_pack(char *payload)
 {
 	MLXSW_REG_ZERO(sfn, payload);
 	mlxsw_reg_sfn_swid_set(payload, 0);
+	mlxsw_reg_sfn_end_set(payload, 1);
 	mlxsw_reg_sfn_num_rec_set(payload, MLXSW_REG_SFN_REC_MAX_COUNT);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index d1b59cd..02de240 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1496,20 +1496,18 @@ static void mlxsw_sp_fdb_notify_work(struct work_struct *work)
 	mlxsw_sp = container_of(work, struct mlxsw_sp, fdb_notify.dw.work);
 
 	rtnl_lock();
-	do {
-		mlxsw_reg_sfn_pack(sfn_pl);
-		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(sfn), sfn_pl);
-		if (err) {
-			dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Failed to get FDB notifications\n");
-			break;
-		}
-		num_rec = mlxsw_reg_sfn_num_rec_get(sfn_pl);
-		for (i = 0; i < num_rec; i++)
-			mlxsw_sp_fdb_notify_rec_process(mlxsw_sp, sfn_pl, i);
+	mlxsw_reg_sfn_pack(sfn_pl);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(sfn), sfn_pl);
+	if (err) {
+		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Failed to get FDB notifications\n");
+		goto out;
+	}
+	num_rec = mlxsw_reg_sfn_num_rec_get(sfn_pl);
+	for (i = 0; i < num_rec; i++)
+		mlxsw_sp_fdb_notify_rec_process(mlxsw_sp, sfn_pl, i);
 
-	} while (num_rec);
+out:
 	rtnl_unlock();
-
 	kfree(sfn_pl);
 	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
 }
-- 
2.5.5
