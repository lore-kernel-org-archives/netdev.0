From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC net-next 3/4] net/mlx5: Separate between eswitch and MPFS l2 table logic
Date: Thu,  8 Jun 2017 02:42:13 +0300
Message-ID: <20170607234214.24723-4-saeedm@mellanox.com>
References: <20170607234214.24723-1-saeedm@mellanox.com>
Cc: kernel-team@fb.com, Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: netdev@vger.kernel.org, Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35132 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753000AbdFGXt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 19:49:29 -0400
In-Reply-To: <20170607234214.24723-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multi-Physical Function Switch (MPFs) is required for when multi-PF
configuration is enabled to allow passing user configured unicast MAC
addresses to the requesting PF.

Before this patch eswitch.c used to manage the HW MPFS l2 table,
eswitch always enabled vport(0) (NIC PF) vport's contexts update on unicast
mac address list changes, to populate the PF's MPFS L2 table accordingly,
even if SRIOV was not enabled.

In downstream patch we would like to allow compiling the driver without
eswitch functionalities, for that we move MPFS l2 table logic out
of eswitch.c into its own file, and provide Kconfig flag (MLX5_MPFS) to
allow compiling out MPFS for those who don't want Multi-PF support

NIC PF netdevice will now directly update MPFS l2 table via the new MPFS
API. VF netdevice has no access to MPFS L2 table, so e-Switch will remain
responsible of updating its PF MPFS l2 table on behalf of its VFs.

Due to this change we also don't require enabling vport(0) (PF vport)
unicast mac changes events anymore, for when SRIOV is not enabled.
Which means eswitch is now activated only on SRIOV activation, and not
required otherwise.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |   8 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   |  14 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 189 ++++----------------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  55 +-----
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  26 ++-
 drivers/net/ethernet/mellanox/mlx5/core/mpfs.c    | 205 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/mpfs.h    |  98 +++++++++++
 include/linux/mlx5/driver.h                       |   2 +
 9 files changed, 376 insertions(+), 223 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mpfs.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mpfs.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index cf1ef48bfd8d..49559e11af86 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -30,6 +30,14 @@ config MLX5_CORE_EN
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
 
+config MLX5_MPFS
+        bool "Mellanox Technologies MLX5 MPFS support"
+        depends on MLX5_CORE_EN
+	default y
+        ---help---
+	  Mellanox Technologies Ethernet Multi-Physical Function Switch (MPFS)
+          support in ConnectX NIC.
+
 config MLX5_CORE_EN_DCB
 	bool "Data Center Bridging (DCB) Support"
 	default y
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 12556c03eec4..8c493aeec392 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -13,6 +13,8 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
 		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
 
+mlx5_core-$(CONFIG_MLX5_MPFS) += mpfs.o
+
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 7acc4fba7ece..5a782618f1b5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -36,6 +36,7 @@
 #include <linux/tcp.h>
 #include <linux/mlx5/fs.h>
 #include "en.h"
+#include "mpfs.h"
 
 static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 				  struct mlx5e_l2_rule *ai, int type);
@@ -363,17 +364,28 @@ static void mlx5e_del_vlan_rules(struct mlx5e_priv *priv)
 static void mlx5e_execute_l2_action(struct mlx5e_priv *priv,
 				    struct mlx5e_l2_hash_node *hn)
 {
-	switch (hn->action) {
+	u8 action = hn->action;
+	int l2_err = 0;
+
+	switch (action) {
 	case MLX5E_ACTION_ADD:
 		mlx5e_add_l2_flow_rule(priv, &hn->ai, MLX5E_FULLMATCH);
+		/* mlx5_mpfs_add_mac will skip mc addresses */
+		l2_err = mlx5_mpfs_add_mac(priv->mdev, hn->ai.addr);
 		hn->action = MLX5E_ACTION_NONE;
 		break;
 
 	case MLX5E_ACTION_DEL:
+		/* mlx5_mpfs_del_mac will skip mc addresses */
+		l2_err = mlx5_mpfs_del_mac(priv->mdev, hn->ai.addr);
 		mlx5e_del_l2_flow_rule(priv, &hn->ai);
 		mlx5e_del_l2_from_hash(hn);
 		break;
 	}
+
+	if (l2_err)
+		netdev_warn(priv->netdev, "L2 table, failed to %s mac %pM, err(%d)\n",
+			    action == MLX5E_ACTION_ADD ? "add" : "del", hn->ai.addr, l2_err);
 }
 
 static void mlx5e_sync_netdev_addr(struct mlx5e_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 81dfcd90b1f5..33e3b9a2f966 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -46,13 +46,6 @@ enum {
 	MLX5_ACTION_DEL  = 2,
 };
 
-/* E-Switch UC L2 table hash node */
-struct esw_uc_addr {
-	struct l2addr_node node;
-	u32                table_index;
-	u32                vport;
-};
-
 /* Vport UC/MC hash node */
 struct vport_addr {
 	struct l2addr_node     node;
@@ -154,81 +147,6 @@ static int modify_esw_vport_cvlan(struct mlx5_core_dev *dev, u32 vport,
 	return modify_esw_vport_context_cmd(dev, vport, in, sizeof(in));
 }
 
-/* HW L2 Table (MPFS) management */
-static int set_l2_table_entry_cmd(struct mlx5_core_dev *dev, u32 index,
-				  u8 *mac, u8 vlan_valid, u16 vlan)
-{
-	u32 in[MLX5_ST_SZ_DW(set_l2_table_entry_in)]   = {0};
-	u32 out[MLX5_ST_SZ_DW(set_l2_table_entry_out)] = {0};
-	u8 *in_mac_addr;
-
-	MLX5_SET(set_l2_table_entry_in, in, opcode,
-		 MLX5_CMD_OP_SET_L2_TABLE_ENTRY);
-	MLX5_SET(set_l2_table_entry_in, in, table_index, index);
-	MLX5_SET(set_l2_table_entry_in, in, vlan_valid, vlan_valid);
-	MLX5_SET(set_l2_table_entry_in, in, vlan, vlan);
-
-	in_mac_addr = MLX5_ADDR_OF(set_l2_table_entry_in, in, mac_address);
-	ether_addr_copy(&in_mac_addr[2], mac);
-
-	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
-}
-
-static int del_l2_table_entry_cmd(struct mlx5_core_dev *dev, u32 index)
-{
-	u32 in[MLX5_ST_SZ_DW(delete_l2_table_entry_in)]   = {0};
-	u32 out[MLX5_ST_SZ_DW(delete_l2_table_entry_out)] = {0};
-
-	MLX5_SET(delete_l2_table_entry_in, in, opcode,
-		 MLX5_CMD_OP_DELETE_L2_TABLE_ENTRY);
-	MLX5_SET(delete_l2_table_entry_in, in, table_index, index);
-	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
-}
-
-static int alloc_l2_table_index(struct mlx5_l2_table *l2_table, u32 *ix)
-{
-	int err = 0;
-
-	*ix = find_first_zero_bit(l2_table->bitmap, l2_table->size);
-	if (*ix >= l2_table->size)
-		err = -ENOSPC;
-	else
-		__set_bit(*ix, l2_table->bitmap);
-
-	return err;
-}
-
-static void free_l2_table_index(struct mlx5_l2_table *l2_table, u32 ix)
-{
-	__clear_bit(ix, l2_table->bitmap);
-}
-
-static int set_l2_table_entry(struct mlx5_core_dev *dev, u8 *mac,
-			      u8 vlan_valid, u16 vlan,
-			      u32 *index)
-{
-	struct mlx5_l2_table *l2_table = &dev->priv.eswitch->l2_table;
-	int err;
-
-	err = alloc_l2_table_index(l2_table, index);
-	if (err)
-		return err;
-
-	err = set_l2_table_entry_cmd(dev, *index, mac, vlan_valid, vlan);
-	if (err)
-		free_l2_table_index(l2_table, *index);
-
-	return err;
-}
-
-static void del_l2_table_entry(struct mlx5_core_dev *dev, u32 index)
-{
-	struct mlx5_l2_table *l2_table = &dev->priv.eswitch->l2_table;
-
-	del_l2_table_entry_cmd(dev, index);
-	free_l2_table_index(l2_table, index);
-}
-
 /* E-Switch FDB */
 static struct mlx5_flow_handle *
 __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
@@ -455,65 +373,58 @@ typedef int (*vport_addr_action)(struct mlx5_eswitch *esw,
 
 static int esw_add_uc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
 {
-	struct hlist_head *hash = esw->l2_table.l2_hash;
-	struct esw_uc_addr *esw_uc;
 	u8 *mac = vaddr->node.addr;
 	u32 vport = vaddr->vport;
 	int err;
 
-	esw_uc = l2addr_hash_find(hash, mac, struct esw_uc_addr);
-	if (esw_uc) {
+	/* Skip l2_table_add for PFs,
+	 * it is already done by the PF netdev in mlx5e_execute_l2_action
+	 */
+	if (!vport)
+		goto fdb_add;
+
+	err = mlx5_mpfs_add_mac(esw->dev, mac);
+	if (err) {
 		esw_warn(esw->dev,
-			 "Failed to set L2 mac(%pM) for vport(%d), mac is already in use by vport(%d)\n",
-			 mac, vport, esw_uc->vport);
-		return -EEXIST;
+			 "Failed to add L2 table mac(%pM) for vport(%d), err(%d)\n",
+			 mac, vport, err);
+		return err;
 	}
 
-	esw_uc = l2addr_hash_add(hash, mac, struct esw_uc_addr, GFP_KERNEL);
-	if (!esw_uc)
-		return -ENOMEM;
-	esw_uc->vport = vport;
-
-	err = set_l2_table_entry(esw->dev, mac, 0, 0, &esw_uc->table_index);
-	if (err)
-		goto abort;
-
+fdb_add:
 	/* SRIOV is enabled: Forward UC MAC to vport */
 	if (esw->fdb_table.fdb && esw->mode == SRIOV_LEGACY)
 		vaddr->flow_rule = esw_fdb_set_vport_rule(esw, mac, vport);
 
-	esw_debug(esw->dev, "\tADDED UC MAC: vport[%d] %pM index:%d fr(%p)\n",
-		  vport, mac, esw_uc->table_index, vaddr->flow_rule);
-	return err;
-abort:
-	l2addr_hash_del(esw_uc);
+	esw_debug(esw->dev, "\tADDED UC MAC: vport[%d] %pM fr(%p)\n",
+		  vport, mac, vaddr->flow_rule);
+
 	return err;
 }
 
 static int esw_del_uc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
 {
-	struct hlist_head *hash = esw->l2_table.l2_hash;
-	struct esw_uc_addr *esw_uc;
 	u8 *mac = vaddr->node.addr;
 	u32 vport = vaddr->vport;
+	int err = 0;
 
-	esw_uc = l2addr_hash_find(hash, mac, struct esw_uc_addr);
-	if (!esw_uc || esw_uc->vport != vport) {
-		esw_debug(esw->dev,
-			  "MAC(%pM) doesn't belong to vport (%d)\n",
-			  mac, vport);
-		return -EINVAL;
-	}
-	esw_debug(esw->dev, "\tDELETE UC MAC: vport[%d] %pM index:%d fr(%p)\n",
-		  vport, mac, esw_uc->table_index, vaddr->flow_rule);
+	/* Skip l2_table_del for PFs,
+	 * it is already done by the PF netdev in mlx5e_execute_l2_action
+	 */
+	if (!vport)
+		goto fdb_del;
 
-	del_l2_table_entry(esw->dev, esw_uc->table_index);
+	err = mlx5_mpfs_del_mac(esw->dev, mac);
+	if (err)
+		esw_warn(esw->dev,
+			 "Failed to del L2 table mac(%pM) for vport(%d), err(%d)\n",
+			 mac, vport, err);
 
+fdb_del:
 	if (vaddr->flow_rule)
 		mlx5_del_flow_rules(vaddr->flow_rule);
 	vaddr->flow_rule = NULL;
 
-	l2addr_hash_del(esw_uc);
 	return 0;
 }
 
@@ -1635,7 +1546,6 @@ int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode)
 
 	esw_info(esw->dev, "E-Switch enable SRIOV: nvfs(%d) mode (%d)\n", nvfs, mode);
 	esw->mode = mode;
-	esw_disable_vport(esw, 0);
 
 	if (mode == SRIOV_LEGACY)
 		err = esw_create_legacy_fdb_table(esw, nvfs + 1);
@@ -1648,7 +1558,11 @@ int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode)
 	if (err)
 		esw_warn(esw->dev, "Failed to create eswitch TSAR");
 
-	enabled_events = (mode == SRIOV_LEGACY) ? SRIOV_VPORT_EVENTS : UC_ADDR_CHANGE;
+	/* Don't enable vport events when in SRIOV_OFFLOADS mode, since:
+	 * 1. L2 table (MPFS) is programmed by PF/VF representors netdevs set_rx_mode
+	 * 2. FDB/Eswitch is programmed by user space tools
+	 */
+	enabled_events = (mode == SRIOV_LEGACY) ? SRIOV_VPORT_EVENTS : 0;
 	for (i = 0; i <= nvfs; i++)
 		esw_enable_vport(esw, i, enabled_events);
 
@@ -1657,7 +1571,6 @@ int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode)
 	return 0;
 
 abort:
-	esw_enable_vport(esw, 0, UC_ADDR_CHANGE);
 	esw->mode = SRIOV_NONE;
 	return err;
 }
@@ -1692,32 +1605,10 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 		esw_offloads_cleanup(esw, nvports);
 
 	esw->mode = SRIOV_NONE;
-	/* VPORT 0 (PF) must be enabled back with non-sriov configuration */
-	esw_enable_vport(esw, 0, UC_ADDR_CHANGE);
-}
-
-void mlx5_eswitch_attach(struct mlx5_eswitch *esw)
-{
-	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
-		return;
-
-	esw_enable_vport(esw, 0, UC_ADDR_CHANGE);
-	/* VF Vports will be enabled when SRIOV is enabled */
-}
-
-void mlx5_eswitch_detach(struct mlx5_eswitch *esw)
-{
-	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
-		return;
-
-	esw_disable_vport(esw, 0);
 }
 
 int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 {
-	int l2_table_size = 1 << MLX5_CAP_GEN(dev, log_max_l2_table);
 	int total_vports = MLX5_TOTAL_VPORTS(dev);
 	struct mlx5_eswitch *esw;
 	int vport_num;
@@ -1728,8 +1619,8 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 		return 0;
 
 	esw_info(dev,
-		 "Total vports %d, l2 table size(%d), per vport: max uc(%d) max mc(%d)\n",
-		 total_vports, l2_table_size,
+		 "Total vports %d, per vport: max uc(%d) max mc(%d)\n",
+		 total_vports,
 		 MLX5_MAX_UC_PER_VPORT(dev),
 		 MLX5_MAX_MC_PER_VPORT(dev));
 
@@ -1739,14 +1630,6 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 
 	esw->dev = dev;
 
-	esw->l2_table.bitmap = kcalloc(BITS_TO_LONGS(l2_table_size),
-				   sizeof(uintptr_t), GFP_KERNEL);
-	if (!esw->l2_table.bitmap) {
-		err = -ENOMEM;
-		goto abort;
-	}
-	esw->l2_table.size = l2_table_size;
-
 	esw->work_queue = create_singlethread_workqueue("mlx5_esw_wq");
 	if (!esw->work_queue) {
 		err = -ENOMEM;
@@ -1796,7 +1679,6 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 abort:
 	if (esw->work_queue)
 		destroy_workqueue(esw->work_queue);
-	kfree(esw->l2_table.bitmap);
 	kfree(esw->vports);
 	kfree(esw->offloads.vport_reps);
 	kfree(esw);
@@ -1813,7 +1695,6 @@ void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw)
 
 	esw->dev->priv.eswitch = NULL;
 	destroy_workqueue(esw->work_queue);
-	kfree(esw->l2_table.bitmap);
 	kfree(esw->offloads.vport_reps);
 	kfree(esw->vports);
 	kfree(esw);
@@ -1838,7 +1719,7 @@ void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe)
 
 /* Vport Administration */
 #define ESW_ALLOWED(esw) \
-	(esw && MLX5_CAP_GEN(esw->dev, vport_group_manager) && mlx5_core_is_pf(esw->dev))
+	(esw && MLX5_VPORT_MANAGER(esw->dev))
 #define LEGAL_VPORT(esw, vport) (vport >= 0 && vport < esw->total_vports)
 
 int mlx5_eswitch_set_vport_mac(struct mlx5_eswitch *esw,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index b746f62c8c79..a0203c7f6cf6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -37,6 +37,7 @@
 #include <linux/if_link.h>
 #include <net/devlink.h>
 #include <linux/mlx5/device.h>
+#include "mpfs.h"
 
 #define MLX5_MAX_UC_PER_VPORT(dev) \
 	(1 << MLX5_CAP_GEN(dev, log_max_current_uc_list))
@@ -44,9 +45,6 @@
 #define MLX5_MAX_MC_PER_VPORT(dev) \
 	(1 << MLX5_CAP_GEN(dev, log_max_current_mc_list))
 
-#define MLX5_L2_ADDR_HASH_SIZE (BIT(BITS_PER_BYTE))
-#define MLX5_L2_ADDR_HASH(addr) (addr[5])
-
 #define FDB_UPLINK_VPORT 0xffff
 
 #define MLX5_MIN_BW_SHARE 1
@@ -54,48 +52,6 @@
 #define MLX5_RATE_TO_BW_SHARE(rate, divider, limit) \
 	min_t(u32, max_t(u32, (rate) / (divider), MLX5_MIN_BW_SHARE), limit)
 
-/* L2 -mac address based- hash helpers */
-struct l2addr_node {
-	struct hlist_node hlist;
-	u8                addr[ETH_ALEN];
-};
-
-#define for_each_l2hash_node(hn, tmp, hash, i) \
-	for (i = 0; i < MLX5_L2_ADDR_HASH_SIZE; i++) \
-		hlist_for_each_entry_safe(hn, tmp, &hash[i], hlist)
-
-#define l2addr_hash_find(hash, mac, type) ({                \
-	int ix = MLX5_L2_ADDR_HASH(mac);                    \
-	bool found = false;                                 \
-	type *ptr = NULL;                                   \
-							    \
-	hlist_for_each_entry(ptr, &hash[ix], node.hlist)    \
-		if (ether_addr_equal(ptr->node.addr, mac)) {\
-			found = true;                       \
-			break;                              \
-		}                                           \
-	if (!found)                                         \
-		ptr = NULL;                                 \
-	ptr;                                                \
-})
-
-#define l2addr_hash_add(hash, mac, type, gfp) ({            \
-	int ix = MLX5_L2_ADDR_HASH(mac);                    \
-	type *ptr = NULL;                                   \
-							    \
-	ptr = kzalloc(sizeof(type), gfp);                   \
-	if (ptr) {                                          \
-		ether_addr_copy(ptr->node.addr, mac);       \
-		hlist_add_head(&ptr->node.hlist, &hash[ix]);\
-	}                                                   \
-	ptr;                                                \
-})
-
-#define l2addr_hash_del(ptr) ({                             \
-	hlist_del(&ptr->node.hlist);                        \
-	kfree(ptr);                                         \
-})
-
 struct vport_ingress {
 	struct mlx5_flow_table *acl;
 	struct mlx5_flow_group *allow_untagged_spoofchk_grp;
@@ -150,12 +106,6 @@ struct mlx5_vport {
 	u16                     enabled_events;
 };
 
-struct mlx5_l2_table {
-	struct hlist_head l2_hash[MLX5_L2_ADDR_HASH_SIZE];
-	u32                  size;
-	unsigned long        *bitmap;
-};
-
 struct mlx5_eswitch_fdb {
 	void *fdb;
 	union {
@@ -221,7 +171,6 @@ struct esw_mc_addr { /* SRIOV only */
 
 struct mlx5_eswitch {
 	struct mlx5_core_dev    *dev;
-	struct mlx5_l2_table    l2_table;
 	struct mlx5_eswitch_fdb fdb_table;
 	struct hlist_head       mc_table[MLX5_L2_ADDR_HASH_SIZE];
 	struct workqueue_struct *work_queue;
@@ -249,8 +198,6 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports);
 /* E-Switch API */
 int mlx5_eswitch_init(struct mlx5_core_dev *dev);
 void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw);
-void mlx5_eswitch_attach(struct mlx5_eswitch *esw);
-void mlx5_eswitch_detach(struct mlx5_eswitch *esw);
 void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe);
 int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode);
 void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 361cd112bb5b..70db4257930e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -53,6 +53,7 @@
 #include <net/devlink.h>
 #include "mlx5_core.h"
 #include "fs_core.h"
+#include "mpfs.h"
 #ifdef CONFIG_MLX5_CORE_EN
 #include "eswitch.h"
 #endif
@@ -941,11 +942,17 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 		goto err_tables_cleanup;
 	}
 
+	err = mlx5_mpfs_init(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init l2 table %d\n", err);
+		goto err_rl_cleanup;
+	}
+
 #ifdef CONFIG_MLX5_CORE_EN
 	err = mlx5_eswitch_init(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to init eswitch %d\n", err);
-		goto err_rl_cleanup;
+		goto err_mpfs_cleanup;
 	}
 #endif
 
@@ -960,11 +967,11 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 err_eswitch_cleanup:
 #ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
-
-err_rl_cleanup:
+err_mpfs_cleanup:
 #endif
+	mlx5_mpfs_cleanup(dev);
+err_rl_cleanup:
 	mlx5_cleanup_rl_table(dev);
-
 err_tables_cleanup:
 	mlx5_cleanup_mkey_table(dev);
 	mlx5_cleanup_srq_table(dev);
@@ -984,6 +991,7 @@ static void mlx5_cleanup_once(struct mlx5_core_dev *dev)
 #ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
 #endif
+	mlx5_mpfs_cleanup(dev);
 	mlx5_cleanup_rl_table(dev);
 	mlx5_cleanup_mkey_table(dev);
 	mlx5_cleanup_srq_table(dev);
@@ -1137,10 +1145,6 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		goto err_fs;
 	}
 
-#ifdef CONFIG_MLX5_CORE_EN
-	mlx5_eswitch_attach(dev->priv.eswitch);
-#endif
-
 	err = mlx5_sriov_attach(dev);
 	if (err) {
 		dev_err(&pdev->dev, "sriov init failed %d\n", err);
@@ -1174,9 +1178,6 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_sriov_detach(dev);
 
 err_sriov:
-#ifdef CONFIG_MLX5_CORE_EN
-	mlx5_eswitch_detach(dev->priv.eswitch);
-#endif
 	mlx5_cleanup_fs(dev);
 
 err_fs:
@@ -1248,9 +1249,6 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		mlx5_detach_device(dev);
 
 	mlx5_sriov_detach(dev);
-#ifdef CONFIG_MLX5_CORE_EN
-	mlx5_eswitch_detach(dev->priv.eswitch);
-#endif
 	mlx5_cleanup_fs(dev);
 	mlx5_irq_clear_affinity_hints(dev);
 	free_comp_eqs(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mpfs.c b/drivers/net/ethernet/mellanox/mlx5/core/mpfs.c
new file mode 100644
index 000000000000..af5e49f3482f
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mpfs.c
@@ -0,0 +1,205 @@
+/*
+ * Copyright (c) 2017, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/mlx5_ifc.h>
+#include "mlx5_core.h"
+#include "mpfs.h"
+
+/* HW L2 Table (MPFS) management */
+static int set_l2table_entry_cmd(struct mlx5_core_dev *dev, u32 index, u8 *mac)
+{
+	u32 in[MLX5_ST_SZ_DW(set_l2_table_entry_in)]   = {0};
+	u32 out[MLX5_ST_SZ_DW(set_l2_table_entry_out)] = {0};
+	u8 *in_mac_addr;
+
+	MLX5_SET(set_l2_table_entry_in, in, opcode, MLX5_CMD_OP_SET_L2_TABLE_ENTRY);
+	MLX5_SET(set_l2_table_entry_in, in, table_index, index);
+
+	in_mac_addr = MLX5_ADDR_OF(set_l2_table_entry_in, in, mac_address);
+	ether_addr_copy(&in_mac_addr[2], mac);
+
+	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
+
+static int del_l2table_entry_cmd(struct mlx5_core_dev *dev, u32 index)
+{
+	u32 in[MLX5_ST_SZ_DW(delete_l2_table_entry_in)]   = {0};
+	u32 out[MLX5_ST_SZ_DW(delete_l2_table_entry_out)] = {0};
+
+	MLX5_SET(delete_l2_table_entry_in, in, opcode, MLX5_CMD_OP_DELETE_L2_TABLE_ENTRY);
+	MLX5_SET(delete_l2_table_entry_in, in, table_index, index);
+	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
+
+/* UC L2 table hash node */
+struct l2table_node {
+	struct l2addr_node node;
+	u32                index; /* index in HW l2 table */
+};
+
+struct mlx5_mpfs {
+	struct hlist_head    hash[MLX5_L2_ADDR_HASH_SIZE];
+	struct mutex         lock; /* Synchronize l2 table access */
+	u32                  size;
+	unsigned long        *bitmap;
+};
+
+static int alloc_l2table_index(struct mlx5_mpfs *l2table, u32 *ix)
+{
+	int err = 0;
+
+	*ix = find_first_zero_bit(l2table->bitmap, l2table->size);
+	if (*ix >= l2table->size)
+		err = -ENOSPC;
+	else
+		__set_bit(*ix, l2table->bitmap);
+
+	return err;
+}
+
+static void free_l2table_index(struct mlx5_mpfs *l2table, u32 ix)
+{
+	__clear_bit(ix, l2table->bitmap);
+}
+
+int mlx5_mpfs_init(struct mlx5_core_dev *dev)
+{
+	int l2table_size = 1 << MLX5_CAP_GEN(dev, log_max_l2_table);
+	struct mlx5_mpfs *mpfs;
+
+	if (!MLX5_VPORT_MANAGER(dev))
+		return 0;
+
+	mpfs = kzalloc(sizeof(*mpfs), GFP_KERNEL);
+	if (!mpfs)
+		return -ENOMEM;
+
+	mutex_init(&mpfs->lock);
+	mpfs->size   = l2table_size;
+	mpfs->bitmap = kcalloc(BITS_TO_LONGS(l2table_size),
+			       sizeof(uintptr_t), GFP_KERNEL);
+	if (!mpfs->bitmap) {
+		kfree(mpfs);
+		return -ENOMEM;
+	}
+
+	dev->priv.mpfs = mpfs;
+	return 0;
+}
+
+void mlx5_mpfs_cleanup(struct mlx5_core_dev *dev)
+{
+	struct mlx5_mpfs *mpfs = dev->priv.mpfs;
+
+	if (!MLX5_VPORT_MANAGER(dev))
+		return;
+
+	WARN_ON(!hlist_empty(mpfs->hash));
+	kfree(mpfs->bitmap);
+	kfree(mpfs);
+}
+
+int mlx5_mpfs_add_mac(struct mlx5_core_dev *dev, u8 *mac)
+{
+	struct mlx5_mpfs *mpfs = dev->priv.mpfs;
+	struct l2table_node *l2addr;
+	u32 index;
+	int err;
+
+	if (!MLX5_VPORT_MANAGER(dev))
+		return 0;
+
+	if (is_multicast_ether_addr(mac))
+		return 0;
+
+	mutex_lock(&mpfs->lock);
+
+	l2addr = l2addr_hash_find(mpfs->hash, mac, struct l2table_node);
+	if (l2addr) {
+		err = -EEXIST;
+		goto abort;
+	}
+
+	err = alloc_l2table_index(mpfs, &index);
+	if (err)
+		goto abort;
+
+	l2addr = l2addr_hash_add(mpfs->hash, mac, struct l2table_node, GFP_KERNEL);
+	if (!l2addr) {
+		free_l2table_index(mpfs, index);
+		err = -ENOMEM;
+		goto abort;
+	}
+
+	l2addr->index = index;
+	err = set_l2table_entry_cmd(dev, index, mac);
+	if (err) {
+		l2addr_hash_del(l2addr);
+		free_l2table_index(mpfs, index);
+	}
+
+abort:
+	mutex_unlock(&mpfs->lock);
+	return err;
+}
+
+int mlx5_mpfs_del_mac(struct mlx5_core_dev *dev, u8 *mac)
+{
+	struct mlx5_mpfs *mpfs = dev->priv.mpfs;
+	struct l2table_node *l2addr;
+	u32 index;
+	int err;
+
+	if (!MLX5_VPORT_MANAGER(dev))
+		return 0;
+
+	if (is_multicast_ether_addr(mac))
+		return 0;
+
+	mutex_lock(&mpfs->lock);
+
+	l2addr = l2addr_hash_find(mpfs->hash, mac, struct l2table_node);
+	if (!l2addr) {
+		err = -ENOENT;
+		goto unlock;
+	}
+
+	index = l2addr->index;
+	del_l2table_entry_cmd(dev, index);
+	l2addr_hash_del(l2addr);
+	free_l2table_index(mpfs, index);
+unlock:
+	mutex_unlock(&mpfs->lock);
+	return err;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mpfs.h b/drivers/net/ethernet/mellanox/mlx5/core/mpfs.h
new file mode 100644
index 000000000000..1db560f689a6
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mpfs.h
@@ -0,0 +1,98 @@
+/*
+ * Copyright (c) 2017, Mellanox Technologies, Ltd.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __MLX5_MPFS_H__
+#define __MLX5_MPFS_H__
+
+#include <linux/if_ether.h>
+#include <linux/mlx5/device.h>
+
+#define MLX5_VPORT_MANAGER(mdev) \
+	(MLX5_CAP_GEN(mdev, vport_group_manager) && mlx5_core_is_pf(mdev))
+
+/* L2 -mac address based- hash helpers */
+#define MLX5_L2_ADDR_HASH_SIZE (BIT(BITS_PER_BYTE))
+#define MLX5_L2_ADDR_HASH(addr) (addr[5])
+
+struct l2addr_node {
+	struct hlist_node hlist;
+	u8                addr[ETH_ALEN];
+};
+
+#define for_each_l2hash_node(hn, tmp, hash, i) \
+	for (i = 0; i < MLX5_L2_ADDR_HASH_SIZE; i++) \
+		hlist_for_each_entry_safe(hn, tmp, &(hash)[i], hlist)
+
+#define l2addr_hash_find(hash, mac, type) ({                \
+	int ix = MLX5_L2_ADDR_HASH(mac);                    \
+	bool found = false;                                 \
+	type *ptr = NULL;                                   \
+							    \
+	hlist_for_each_entry(ptr, &(hash)[ix], node.hlist)  \
+		if (ether_addr_equal(ptr->node.addr, mac)) {\
+			found = true;                       \
+			break;                              \
+		}                                           \
+	if (!found)                                         \
+		ptr = NULL;                                 \
+	ptr;                                                \
+})
+
+#define l2addr_hash_add(hash, mac, type, gfp) ({            \
+	int ix = MLX5_L2_ADDR_HASH(mac);                    \
+	type *ptr = NULL;                                   \
+							    \
+	ptr = kzalloc(sizeof(type), gfp);                   \
+	if (ptr) {                                          \
+		ether_addr_copy(ptr->node.addr, mac);       \
+		hlist_add_head(&ptr->node.hlist, &(hash)[ix]);\
+	}                                                   \
+	ptr;                                                \
+})
+
+#define l2addr_hash_del(ptr) ({                             \
+	hlist_del(&(ptr)->node.hlist);                      \
+	kfree(ptr);                                         \
+})
+
+#ifdef CONFIG_MLX5_MPFS
+int  mlx5_mpfs_init(struct mlx5_core_dev *dev);
+void mlx5_mpfs_cleanup(struct mlx5_core_dev *dev);
+int  mlx5_mpfs_add_mac(struct mlx5_core_dev *dev, u8 *mac);
+int  mlx5_mpfs_del_mac(struct mlx5_core_dev *dev, u8 *mac);
+#else /* #ifndef CONFIG_MLX5_MPFS */
+static inline int  mlx5_mpfs_init(struct mlx5_core_dev *dev) { return 0; }
+static inline void mlx5_mpfs_cleanup(struct mlx5_core_dev *dev) {}
+static inline int  mlx5_mpfs_add_mac(struct mlx5_core_dev *dev, u8 *mac) { return 0; }
+static inline int  mlx5_mpfs_del_mac(struct mlx5_core_dev *dev, u8 *mac) { return 0; }
+#endif
+#endif
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 6ea2f5734e37..382f688b7231 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -545,6 +545,7 @@ struct mlx5_fc_stats {
 	unsigned long sampling_interval; /* jiffies */
 };
 
+struct mlx5_mpfs;
 struct mlx5_eswitch;
 struct mlx5_lag;
 struct mlx5_pagefault;
@@ -642,6 +643,7 @@ struct mlx5_priv {
 	spinlock_t              ctx_lock;
 
 	struct mlx5_flow_steering *steering;
+	struct mlx5_mpfs        *mpfs;
 	struct mlx5_eswitch     *eswitch;
 	struct mlx5_core_sriov	sriov;
 	struct mlx5_lag		*lag;
-- 
2.11.0
