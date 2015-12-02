From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 21/28] mlxsw: core: Add support for packets received from LAG port
Date: Wed,  2 Dec 2015 21:07:44 +0100
Message-ID: <1449086871-19911-22-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36241 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755988AbbLBUIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:22 -0500
Received: by wmww144 with SMTP id w144so230285250wmw.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:20 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Lower layer (pci) has information if the packet is received via LAG port.
If that is the case, it fills up rx_info accordingly. However upper
layer does not care about lag_id/port_index for received packets so
convert it to local_port before passing it up. For that conversion, lag
mapping array is introduced. Upper layer is responsible for setting up
the mapping according to what is set in HW.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 79 ++++++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/core.h | 14 +++++-
 drivers/net/ethernet/mellanox/mlxsw/pci.c  |  4 +-
 3 files changed, 92 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 1ecb4aa..af8a48b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -105,6 +105,9 @@ struct mlxsw_core {
 		struct debugfs_blob_wrapper vsd_blob;
 		struct debugfs_blob_wrapper psid_blob;
 	} dbg;
+	struct {
+		u8 *mapping; /* lag_id+port_index to local_port mapping */
+	} lag;
 	struct mlxsw_hwmon *hwmon;
 	unsigned long driver_priv[0];
 	/* driver_priv has to be always the last item */
@@ -815,6 +818,17 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 		goto err_alloc_stats;
 	}
 
+	if (mlxsw_driver->profile->used_max_lag &&
+	    mlxsw_driver->profile->used_max_port_per_lag) {
+		alloc_size = sizeof(u8) * mlxsw_driver->profile->max_lag *
+			     mlxsw_driver->profile->max_port_per_lag;
+		mlxsw_core->lag.mapping = kzalloc(alloc_size, GFP_KERNEL);
+		if (!mlxsw_core->lag.mapping) {
+			err = -ENOMEM;
+			goto err_alloc_lag_mapping;
+		}
+	}
+
 	err = mlxsw_bus->init(bus_priv, mlxsw_core, mlxsw_driver->profile);
 	if (err)
 		goto err_bus_init;
@@ -847,6 +861,8 @@ err_hwmon_init:
 err_emad_init:
 	mlxsw_bus->fini(bus_priv);
 err_bus_init:
+	kfree(mlxsw_core->lag.mapping);
+err_alloc_lag_mapping:
 	free_percpu(mlxsw_core->pcpu_stats);
 err_alloc_stats:
 	kfree(mlxsw_core);
@@ -865,6 +881,7 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 	mlxsw_hwmon_fini(mlxsw_core->hwmon);
 	mlxsw_emad_fini(mlxsw_core);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
+	kfree(mlxsw_core->lag.mapping);
 	free_percpu(mlxsw_core->pcpu_stats);
 	kfree(mlxsw_core);
 	mlxsw_core_driver_put(device_kind);
@@ -1196,11 +1213,25 @@ void mlxsw_core_skb_receive(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
 	struct mlxsw_rx_listener_item *rxl_item;
 	const struct mlxsw_rx_listener *rxl;
 	struct mlxsw_core_pcpu_stats *pcpu_stats;
-	u8 local_port = rx_info->sys_port;
+	u8 local_port;
 	bool found = false;
 
-	dev_dbg_ratelimited(mlxsw_core->bus_info->dev, "%s: sys_port = %d, trap_id = 0x%x\n",
-			    __func__, rx_info->sys_port, rx_info->trap_id);
+	if (rx_info->is_lag) {
+		dev_dbg_ratelimited(mlxsw_core->bus_info->dev, "%s: lag_id = %d, lag_port_index = 0x%x\n",
+				    __func__, rx_info->u.lag_id,
+				    rx_info->trap_id);
+		/* Upper layer does not care if the skb came from LAG or not,
+		 * so just get the local_port for the lag port and push it up.
+		 */
+		local_port = mlxsw_core_lag_mapping_get(mlxsw_core,
+							rx_info->u.lag_id,
+							rx_info->lag_port_index);
+	} else {
+		local_port = rx_info->u.sys_port;
+	}
+
+	dev_dbg_ratelimited(mlxsw_core->bus_info->dev, "%s: local_port = %d, trap_id = 0x%x\n",
+			    __func__, local_port, rx_info->trap_id);
 
 	if ((rx_info->trap_id >= MLXSW_TRAP_ID_MAX) ||
 	    (local_port >= MLXSW_PORT_MAX_PORTS))
@@ -1244,6 +1275,48 @@ drop:
 }
 EXPORT_SYMBOL(mlxsw_core_skb_receive);
 
+static int mlxsw_core_lag_mapping_index(struct mlxsw_core *mlxsw_core,
+					u16 lag_id, u8 port_index)
+{
+	return mlxsw_core->driver->profile->max_port_per_lag * lag_id +
+	       port_index;
+}
+
+void mlxsw_core_lag_mapping_set(struct mlxsw_core *mlxsw_core,
+				u16 lag_id, u8 port_index, u8 local_port)
+{
+	int index = mlxsw_core_lag_mapping_index(mlxsw_core,
+						 lag_id, port_index);
+
+	mlxsw_core->lag.mapping[index] = local_port;
+}
+EXPORT_SYMBOL(mlxsw_core_lag_mapping_set);
+
+u8 mlxsw_core_lag_mapping_get(struct mlxsw_core *mlxsw_core,
+			      u16 lag_id, u8 port_index)
+{
+	int index = mlxsw_core_lag_mapping_index(mlxsw_core,
+						 lag_id, port_index);
+
+	return mlxsw_core->lag.mapping[index];
+}
+EXPORT_SYMBOL(mlxsw_core_lag_mapping_get);
+
+void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
+				  u16 lag_id, u8 local_port)
+{
+	int i;
+
+	for (i = 0; i < mlxsw_core->driver->profile->max_port_per_lag; i++) {
+		int index = mlxsw_core_lag_mapping_index(mlxsw_core,
+							 lag_id, i);
+
+		if (mlxsw_core->lag.mapping[index] == local_port)
+			mlxsw_core->lag.mapping[index] = 0;
+	}
+}
+EXPORT_SYMBOL(mlxsw_core_lag_mapping_clear);
+
 int mlxsw_cmd_exec(struct mlxsw_core *mlxsw_core, u16 opcode, u8 opcode_mod,
 		   u32 in_mod, bool out_mbox_direct,
 		   char *in_mbox, size_t in_mbox_size,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 5ac9529..4833fb3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -112,13 +112,25 @@ int mlxsw_reg_write(struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_reg_info *reg, char *payload);
 
 struct mlxsw_rx_info {
-	u16 sys_port;
+	bool is_lag;
+	union {
+		u16 sys_port;
+		u16 lag_id;
+	} u;
+	u8 lag_port_index;
 	int trap_id;
 };
 
 void mlxsw_core_skb_receive(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
 			    struct mlxsw_rx_info *rx_info);
 
+void mlxsw_core_lag_mapping_set(struct mlxsw_core *mlxsw_core,
+				u16 lag_id, u8 port_index, u8 local_port);
+u8 mlxsw_core_lag_mapping_get(struct mlxsw_core *mlxsw_core,
+			      u16 lag_id, u8 port_index);
+void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
+				  u16 lag_id, u8 local_port);
+
 #define MLXSW_CONFIG_PROFILE_SWID_COUNT 8
 
 struct mlxsw_swid_config {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index de69e71..8ca66a0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -690,7 +690,9 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 	if (mlxsw_pci_cqe_lag_get(cqe))
 		goto drop;
 
-	rx_info.sys_port = mlxsw_pci_cqe_system_port_get(cqe);
+	rx_info.is_lag = false;
+	rx_info.u.sys_port = mlxsw_pci_cqe_system_port_get(cqe);
+
 	rx_info.trap_id = mlxsw_pci_cqe_trap_id_get(cqe);
 
 	byte_count = mlxsw_pci_cqe_byte_count_get(cqe);
-- 
1.9.3
