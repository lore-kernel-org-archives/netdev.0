From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/15] mlxsw: pci: Limit number of entries being sent in single MAP_FA cmd
Date: Thu, 15 Oct 2015 17:43:20 +0200
Message-ID: <1444923809-20785-7-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:32935 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbbJOPnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:40 -0400
Received: by lbbpp2 with SMTP id pp2so44842443lbb.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:38 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Firmware accepts only limited number of mapping entries for MAP_FA
command. In order to prevent overflow, introduce a limit and in case the
number of entries is bigger, call MAP_FA multiple times.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h |  2 ++
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 26 ++++++++++++++++++--------
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index 770db17..27e48b4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -464,6 +464,8 @@ MLXSW_ITEM32(cmd_mbox, query_aq_cap, max_sg_rq, 0x10, 0, 8);
  * passed in this command must be pinned.
  */
 
+#define MLXSW_CMD_MAP_FA_VPM_ENTRIES_MAX 32
+
 static inline int mlxsw_cmd_map_fa(struct mlxsw_core *mlxsw_core,
 				   char *in_mbox, u32 vpm_entries_count)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 870d443..87afa5f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -171,8 +171,8 @@ struct mlxsw_pci {
 	struct msix_entry msix_entry;
 	struct mlxsw_core *core;
 	struct {
-		u16 num_pages;
 		struct mlxsw_pci_mem_item *items;
+		unsigned int count;
 	} fw_area;
 	struct {
 		struct mlxsw_pci_mem_item out_mbox;
@@ -1272,6 +1272,7 @@ static int mlxsw_pci_fw_area_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 				  u16 num_pages)
 {
 	struct mlxsw_pci_mem_item *mem_item;
+	int nent = 0;
 	int i;
 	int err;
 
@@ -1279,7 +1280,7 @@ static int mlxsw_pci_fw_area_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 					   GFP_KERNEL);
 	if (!mlxsw_pci->fw_area.items)
 		return -ENOMEM;
-	mlxsw_pci->fw_area.num_pages = num_pages;
+	mlxsw_pci->fw_area.count = num_pages;
 
 	mlxsw_cmd_mbox_zero(mbox);
 	for (i = 0; i < num_pages; i++) {
@@ -1293,13 +1294,22 @@ static int mlxsw_pci_fw_area_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 			err = -ENOMEM;
 			goto err_alloc;
 		}
-		mlxsw_cmd_mbox_map_fa_pa_set(mbox, i, mem_item->mapaddr);
-		mlxsw_cmd_mbox_map_fa_log2size_set(mbox, i, 0); /* 1 page */
+		mlxsw_cmd_mbox_map_fa_pa_set(mbox, nent, mem_item->mapaddr);
+		mlxsw_cmd_mbox_map_fa_log2size_set(mbox, nent, 0); /* 1 page */
+		if (++nent == MLXSW_CMD_MAP_FA_VPM_ENTRIES_MAX) {
+			err = mlxsw_cmd_map_fa(mlxsw_pci->core, mbox, nent);
+			if (err)
+				goto err_cmd_map_fa;
+			nent = 0;
+			mlxsw_cmd_mbox_zero(mbox);
+		}
 	}
 
-	err = mlxsw_cmd_map_fa(mlxsw_pci->core, mbox, num_pages);
-	if (err)
-		goto err_cmd_map_fa;
+	if (nent) {
+		err = mlxsw_cmd_map_fa(mlxsw_pci->core, mbox, nent);
+		if (err)
+			goto err_cmd_map_fa;
+	}
 
 	return 0;
 
@@ -1322,7 +1332,7 @@ static void mlxsw_pci_fw_area_fini(struct mlxsw_pci *mlxsw_pci)
 
 	mlxsw_cmd_unmap_fa(mlxsw_pci->core);
 
-	for (i = 0; i < mlxsw_pci->fw_area.num_pages; i++) {
+	for (i = 0; i < mlxsw_pci->fw_area.count; i++) {
 		mem_item = &mlxsw_pci->fw_area.items[i];
 
 		pci_free_consistent(mlxsw_pci->pdev, mem_item->size,
-- 
1.9.3
