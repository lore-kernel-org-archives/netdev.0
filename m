From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/3] net/mlx5: E-Switch, Handle mode change failures
Date: Sun, 18 Sep 2016 18:20:29 +0300
Message-ID: <1474212029-1052-4-git-send-email-ogerlitz@mellanox.com>
References: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56224 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936481AbcIRPUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:20:41 -0400
In-Reply-To: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

E-switch mode changes involve creating HW tables, potentially allocating
netdevices, etc, and things can fail. Add an attempt to rollback to the
existing mode when changing to the new mode fails. Only if rollback fails,
getting proper SRIOV functionality requires module unload or sriov
disablement/enablement.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c   | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 3dc83a9..7de40e6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -446,7 +446,7 @@ out:
 
 static int esw_offloads_start(struct mlx5_eswitch *esw)
 {
-	int err, num_vfs = esw->dev->priv.sriov.num_vfs;
+	int err, err1, num_vfs = esw->dev->priv.sriov.num_vfs;
 
 	if (esw->mode != SRIOV_LEGACY) {
 		esw_warn(esw->dev, "Can't set offloads mode, SRIOV legacy not enabled\n");
@@ -455,8 +455,12 @@ static int esw_offloads_start(struct mlx5_eswitch *esw)
 
 	mlx5_eswitch_disable_sriov(esw);
 	err = mlx5_eswitch_enable_sriov(esw, num_vfs, SRIOV_OFFLOADS);
-	if (err)
-		esw_warn(esw->dev, "Failed set eswitch to offloads, err %d\n", err);
+	if (err) {
+		esw_warn(esw->dev, "Failed setting eswitch to offloads, err %d\n", err);
+		err1 = mlx5_eswitch_enable_sriov(esw, num_vfs, SRIOV_LEGACY);
+		if (err1)
+			esw_warn(esw->dev, "Failed setting eswitch back to legacy, err %d\n", err);
+	}
 	return err;
 }
 
@@ -508,12 +512,16 @@ create_ft_err:
 
 static int esw_offloads_stop(struct mlx5_eswitch *esw)
 {
-	int err, num_vfs = esw->dev->priv.sriov.num_vfs;
+	int err, err1, num_vfs = esw->dev->priv.sriov.num_vfs;
 
 	mlx5_eswitch_disable_sriov(esw);
 	err = mlx5_eswitch_enable_sriov(esw, num_vfs, SRIOV_LEGACY);
-	if (err)
-		esw_warn(esw->dev, "Failed set eswitch legacy mode. err %d\n", err);
+	if (err) {
+		esw_warn(esw->dev, "Failed setting eswitch to legacy, err %d\n", err);
+		err1 = mlx5_eswitch_enable_sriov(esw, num_vfs, SRIOV_OFFLOADS);
+		if (err1)
+			esw_warn(esw->dev, "Failed setting eswitch back to offloads, err %d\n", err);
+	}
 
 	return err;
 }
-- 
2.3.7
