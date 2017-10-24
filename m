From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 7/7] mlxsw: core: Add support for reload
Date: Tue, 24 Oct 2017 11:22:45 +0200
Message-ID: <20171024092245.1386-8-jiri@resnulli.us>
References: <20171024092245.1386-1-jiri@resnulli.us>
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:54780 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751778AbdJXJWy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:22:54 -0400
Received: by mail-wm0-f66.google.com with SMTP id r68so14866582wmr.3
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:22:54 -0700 (PDT)
In-Reply-To: <20171024092245.1386-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for hot reload. First, all the driver/core resources are
released but the PCI and devlink instances, then reset is performed
through the PCI interface. Finally the driver performs initialization.

In case of reload failure the driver is left in a partially initialized
state. Special care is taken during the driver removal in order to
properly handle this state.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 58 +++++++++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlxsw/core.h |  4 +--
 drivers/net/ethernet/mellanox/mlxsw/i2c.c  |  4 +--
 drivers/net/ethernet/mellanox/mlxsw/pci.c  |  4 +--
 4 files changed, 51 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index ab93437..2fcde3c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -113,6 +113,7 @@ struct mlxsw_core {
 	struct mlxsw_thermal *thermal;
 	struct mlxsw_core_port *ports;
 	unsigned int max_ports;
+	bool reload_fail;
 	unsigned long driver_priv[0];
 	/* driver_priv has to be always the last item */
 };
@@ -962,7 +963,24 @@ mlxsw_devlink_sb_occ_tc_port_bind_get(struct devlink_port *devlink_port,
 						     pool_type, p_cur, p_max);
 }
 
+static int mlxsw_devlink_core_bus_device_reload(struct devlink *devlink)
+{
+	struct mlxsw_core *mlxsw_core = devlink_priv(devlink);
+	const struct mlxsw_bus *mlxsw_bus = mlxsw_core->bus;
+	int err;
+
+	mlxsw_core_bus_device_unregister(mlxsw_core, true);
+	mlxsw_bus->reset(mlxsw_core->bus_priv);
+	err = mlxsw_core_bus_device_register(mlxsw_core->bus_info,
+					     mlxsw_core->bus,
+					     mlxsw_core->bus_priv, true);
+	if (err)
+		mlxsw_core->reload_fail = true;
+	return err;
+}
+
 static const struct devlink_ops mlxsw_devlink_ops = {
+	.reload				= mlxsw_devlink_core_bus_device_reload,
 	.port_type_set			= mlxsw_devlink_port_type_set,
 	.port_split			= mlxsw_devlink_port_split,
 	.port_unsplit			= mlxsw_devlink_port_unsplit,
@@ -980,7 +998,7 @@ static const struct devlink_ops mlxsw_devlink_ops = {
 
 int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 				   const struct mlxsw_bus *mlxsw_bus,
-				   void *bus_priv)
+				   void *bus_priv, bool reload)
 {
 	const char *device_kind = mlxsw_bus_info->device_kind;
 	struct mlxsw_core *mlxsw_core;
@@ -992,11 +1010,14 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	mlxsw_driver = mlxsw_core_driver_get(device_kind);
 	if (!mlxsw_driver)
 		return -EINVAL;
-	alloc_size = sizeof(*mlxsw_core) + mlxsw_driver->priv_size;
-	devlink = devlink_alloc(&mlxsw_devlink_ops, alloc_size);
-	if (!devlink) {
-		err = -ENOMEM;
-		goto err_devlink_alloc;
+
+	if (!reload) {
+		alloc_size = sizeof(*mlxsw_core) + mlxsw_driver->priv_size;
+		devlink = devlink_alloc(&mlxsw_devlink_ops, alloc_size);
+		if (!devlink) {
+			err = -ENOMEM;
+			goto err_devlink_alloc;
+		}
 	}
 
 	mlxsw_core = devlink_priv(devlink);
@@ -1012,7 +1033,7 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_bus_init;
 
-	if (mlxsw_driver->resources_register) {
+	if (mlxsw_driver->resources_register && !reload) {
 		err = mlxsw_driver->resources_register(mlxsw_core);
 		if (err)
 			goto err_register_resources;
@@ -1038,9 +1059,11 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_emad_init;
 
-	err = devlink_register(devlink, mlxsw_bus_info->dev);
-	if (err)
-		goto err_devlink_register;
+	if (!reload) {
+		err = devlink_register(devlink, mlxsw_bus_info->dev);
+		if (err)
+			goto err_devlink_register;
+	}
 
 	err = mlxsw_hwmon_init(mlxsw_core, mlxsw_bus_info, &mlxsw_core->hwmon);
 	if (err)
@@ -1082,20 +1105,29 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 }
 EXPORT_SYMBOL(mlxsw_core_bus_device_register);
 
-void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
+void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core,
+				      bool reload)
 {
 	const char *device_kind = mlxsw_core->bus_info->device_kind;
 	struct devlink *devlink = priv_to_devlink(mlxsw_core);
 
+	if (mlxsw_core->reload_fail)
+		goto out;
+
 	if (mlxsw_core->driver->fini)
 		mlxsw_core->driver->fini(mlxsw_core);
 	mlxsw_thermal_fini(mlxsw_core->thermal);
-	devlink_unregister(devlink);
+	if (!reload)
+		devlink_unregister(devlink);
 	mlxsw_emad_fini(mlxsw_core);
 	kfree(mlxsw_core->lag.mapping);
 	mlxsw_ports_fini(mlxsw_core);
-	devlink_resources_clear(devlink);
+	if (!reload)
+		devlink_resources_clear(devlink);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
+	if (reload)
+		return;
+out:
 	devlink_free(devlink);
 	mlxsw_core_driver_put(device_kind);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index e44061d..1a62da5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -66,8 +66,8 @@ void mlxsw_core_driver_unregister(struct mlxsw_driver *mlxsw_driver);
 
 int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 				   const struct mlxsw_bus *mlxsw_bus,
-				   void *bus_priv);
-void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core);
+				   void *bus_priv, bool reload);
+void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core, bool reload);
 
 struct mlxsw_tx_info {
 	u8 local_port;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/i2c.c b/drivers/net/ethernet/mellanox/mlxsw/i2c.c
index 12c3a44..d7a5562 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/i2c.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/i2c.c
@@ -539,7 +539,7 @@ static int mlxsw_i2c_probe(struct i2c_client *client,
 	mlxsw_i2c->dev = &client->dev;
 
 	err = mlxsw_core_bus_device_register(&mlxsw_i2c->bus_info,
-					     &mlxsw_i2c_bus, mlxsw_i2c);
+					     &mlxsw_i2c_bus, mlxsw_i2c, false);
 	if (err) {
 		dev_err(&client->dev, "Fail to register core bus\n");
 		return err;
@@ -557,7 +557,7 @@ static int mlxsw_i2c_remove(struct i2c_client *client)
 {
 	struct mlxsw_i2c *mlxsw_i2c = i2c_get_clientdata(client);
 
-	mlxsw_core_bus_device_unregister(mlxsw_i2c->core);
+	mlxsw_core_bus_device_unregister(mlxsw_i2c->core, false);
 	mutex_destroy(&mlxsw_i2c->cmd.lock);
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index da08f08..b69508d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1737,7 +1737,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	mlxsw_pci->id = id;
 
 	err = mlxsw_core_bus_device_register(&mlxsw_pci->bus_info,
-					     &mlxsw_pci_bus, mlxsw_pci);
+					     &mlxsw_pci_bus, mlxsw_pci, false);
 	if (err) {
 		dev_err(&pdev->dev, "cannot register bus device\n");
 		goto err_bus_device_register;
@@ -1765,7 +1765,7 @@ static void mlxsw_pci_remove(struct pci_dev *pdev)
 {
 	struct mlxsw_pci *mlxsw_pci = pci_get_drvdata(pdev);
 
-	mlxsw_core_bus_device_unregister(mlxsw_pci->core);
+	mlxsw_core_bus_device_unregister(mlxsw_pci->core, false);
 	mlxsw_pci_free_irq_vectors(mlxsw_pci);
 	iounmap(mlxsw_pci->hw_addr);
 	pci_release_regions(mlxsw_pci->pdev);
-- 
2.9.5
