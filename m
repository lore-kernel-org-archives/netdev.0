From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/16] mlxsw: switchx2: Add IB port support
Date: Fri, 28 Oct 2016 21:36:00 +0200
Message-ID: <1477683361-8011-15-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33632 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965458AbcJ1TvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:51:19 -0400
Received: by mail-wm0-f66.google.com with SMTP id m83so8790064wmc.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:51:18 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

SwitchX-2 is IB capable device. This patch add a support to change the
port type between Ethernet and Infiniband.

When the port is set to IB, the FW implements the Subnet Management Agent
(SMA) manage the port. All port attributes can be control remotely by
the SM.

Usage:
	$ devlink port show
	pci/0000:03:00.0/1: type eth netdev eth0
	pci/0000:03:00.0/3: type eth netdev eth1
	pci/0000:03:00.0/5: type eth netdev eth2
	pci/0000:03:00.0/6: type eth netdev eth3
	pci/0000:03:00.0/8: type eth netdev eth4

	$ devlink port set pci/0000:03:00.0/1 type ib

	$ devlink port show
	pci/0000:03:00.0/1: type ib

Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/ib.h       |  39 +++++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 229 +++++++++++++++++++++++--
 2 files changed, 249 insertions(+), 19 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/ib.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/ib.h b/drivers/net/ethernet/mellanox/mlxsw/ib.h
new file mode 100644
index 0000000..ce313aa
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/ib.h
@@ -0,0 +1,39 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/ib.h
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Elad Raz <eladr@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+#ifndef _MLXSW_IB_H
+#define _MLXSW_IB_H
+
+#define MLXSW_IB_DEFAULT_MTU 4096
+
+#endif /* _MLXSW_IB_H */
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 3aa0948..5208764 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -3,7 +3,7 @@
  * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
  * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
  * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
- * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
+ * Copyright (c) 2015-2016 Elad Raz <eladr@mellanox.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -53,6 +53,7 @@
 #include "port.h"
 #include "trap.h"
 #include "txheader.h"
+#include "ib.h"
 
 static const char mlxsw_sx_driver_name[] = "mlxsw_switchx2";
 static const char mlxsw_sx_driver_version[] = "1.0";
@@ -218,14 +219,14 @@ static int mlxsw_sx_port_oper_status_get(struct mlxsw_sx_port *mlxsw_sx_port,
 	return 0;
 }
 
-static int mlxsw_sx_port_mtu_set(struct mlxsw_sx_port *mlxsw_sx_port, u16 mtu)
+static int __mlxsw_sx_port_mtu_set(struct mlxsw_sx_port *mlxsw_sx_port,
+				   u16 mtu)
 {
 	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
 	char pmtu_pl[MLXSW_REG_PMTU_LEN];
 	int max_mtu;
 	int err;
 
-	mtu += MLXSW_TXHDR_LEN + ETH_HLEN;
 	mlxsw_reg_pmtu_pack(pmtu_pl, mlxsw_sx_port->local_port, 0);
 	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(pmtu), pmtu_pl);
 	if (err)
@@ -239,6 +240,32 @@ static int mlxsw_sx_port_mtu_set(struct mlxsw_sx_port *mlxsw_sx_port, u16 mtu)
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(pmtu), pmtu_pl);
 }
 
+static int mlxsw_sx_port_mtu_eth_set(struct mlxsw_sx_port *mlxsw_sx_port,
+				     u16 mtu)
+{
+	mtu += MLXSW_TXHDR_LEN + ETH_HLEN;
+	return __mlxsw_sx_port_mtu_set(mlxsw_sx_port, mtu);
+}
+
+static int mlxsw_sx_port_mtu_ib_set(struct mlxsw_sx_port *mlxsw_sx_port,
+				    u16 mtu)
+{
+	return __mlxsw_sx_port_mtu_set(mlxsw_sx_port, mtu);
+}
+
+static int mlxsw_sx_port_ib_port_set(struct mlxsw_sx_port *mlxsw_sx_port,
+				     u8 ib_port)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char plib_pl[MLXSW_REG_PLIB_LEN] = {0};
+	int err;
+
+	mlxsw_reg_plib_local_port_set(plib_pl, mlxsw_sx_port->local_port);
+	mlxsw_reg_plib_ib_port_set(plib_pl, ib_port);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(plib), plib_pl);
+	return err;
+}
+
 static int mlxsw_sx_port_swid_set(struct mlxsw_sx_port *mlxsw_sx_port, u8 swid)
 {
 	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
@@ -348,7 +375,7 @@ static int mlxsw_sx_port_change_mtu(struct net_device *dev, int mtu)
 	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
 	int err;
 
-	err = mlxsw_sx_port_mtu_set(mlxsw_sx_port, mtu);
+	err = mlxsw_sx_port_mtu_eth_set(mlxsw_sx_port, mtu);
 	if (err)
 		return err;
 	dev->mtu = mtu;
@@ -969,6 +996,17 @@ static int mlxsw_sx_port_stp_state_set(struct mlxsw_sx_port *mlxsw_sx_port,
 	return err;
 }
 
+static int mlxsw_sx_port_ib_speed_set(struct mlxsw_sx_port *mlxsw_sx_port,
+				      u16 speed, u16 width)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char ptys_pl[MLXSW_REG_PTYS_LEN];
+
+	mlxsw_reg_ptys_ib_pack(ptys_pl, mlxsw_sx_port->local_port, speed,
+			       width);
+	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
+}
+
 static int
 mlxsw_sx_port_speed_by_width_set(struct mlxsw_sx_port *mlxsw_sx_port, u8 width)
 {
@@ -1063,7 +1101,7 @@ static int __mlxsw_sx_port_eth_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
 		goto err_port_speed_set;
 	}
 
-	err = mlxsw_sx_port_mtu_set(mlxsw_sx_port, ETH_DATA_LEN);
+	err = mlxsw_sx_port_mtu_eth_set(mlxsw_sx_port, ETH_DATA_LEN);
 	if (err) {
 		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set MTU\n",
 			mlxsw_sx_port->local_port);
@@ -1153,15 +1191,118 @@ static void __mlxsw_sx_port_eth_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	free_netdev(mlxsw_sx_port->dev);
 }
 
-static void mlxsw_sx_port_eth_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+static bool mlxsw_sx_port_created(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
-	__mlxsw_sx_port_eth_remove(mlxsw_sx, local_port);
-	mlxsw_core_port_fini(mlxsw_sx->core, local_port);
+	return mlxsw_sx->ports[local_port] != NULL;
 }
 
-static bool mlxsw_sx_port_created(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+static int __mlxsw_sx_port_ib_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
+				     u8 module, u8 width)
 {
-	return mlxsw_sx->ports[local_port] != NULL;
+	struct mlxsw_sx_port *mlxsw_sx_port;
+	int err;
+
+	mlxsw_sx_port = kzalloc(sizeof(*mlxsw_sx_port), GFP_KERNEL);
+	if (!mlxsw_sx_port)
+		return -ENOMEM;
+	mlxsw_sx_port->mlxsw_sx = mlxsw_sx;
+	mlxsw_sx_port->local_port = local_port;
+	mlxsw_sx_port->mapping.module = module;
+
+	err = mlxsw_sx_port_system_port_mapping_set(mlxsw_sx_port);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set system port mapping\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_system_port_mapping_set;
+	}
+
+	/* Adding port to Infiniband swid (1) */
+	err = mlxsw_sx_port_swid_set(mlxsw_sx_port, 1);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set SWID\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_swid_set;
+	}
+
+	/* Expose the IB port number as it's front panel name */
+	err = mlxsw_sx_port_ib_port_set(mlxsw_sx_port, module + 1);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set IB port\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_ib_set;
+	}
+
+	/* Supports all speeds from SDR to FDR (bitmask) and support bus width
+	 * of 1x, 2x and 4x (3 bits bitmask)
+	 */
+	err = mlxsw_sx_port_ib_speed_set(mlxsw_sx_port,
+					 MLXSW_REG_PTYS_IB_SPEED_EDR - 1,
+					 BIT(3) - 1);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set speed\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_speed_set;
+	}
+
+	/* Change to the maximum MTU the device supports, the SMA will take
+	 * care of the active MTU
+	 */
+	err = mlxsw_sx_port_mtu_ib_set(mlxsw_sx_port, MLXSW_IB_DEFAULT_MTU);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set MTU\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_mtu_set;
+	}
+
+	err = mlxsw_sx_port_admin_status_set(mlxsw_sx_port, true);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to change admin state to UP\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_admin_set;
+	}
+
+	mlxsw_core_port_ib_set(mlxsw_sx->core, mlxsw_sx_port->local_port,
+			       mlxsw_sx_port);
+	mlxsw_sx->ports[local_port] = mlxsw_sx_port;
+	return 0;
+
+err_port_admin_set:
+err_port_mtu_set:
+err_port_speed_set:
+err_port_ib_set:
+	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
+err_port_swid_set:
+err_port_system_port_mapping_set:
+	kfree(mlxsw_sx_port);
+	return err;
+}
+
+static void __mlxsw_sx_port_ib_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = mlxsw_sx->ports[local_port];
+
+	mlxsw_core_port_clear(mlxsw_sx->core, local_port, mlxsw_sx);
+	mlxsw_sx->ports[local_port] = NULL;
+	mlxsw_sx_port_admin_status_set(mlxsw_sx_port, false);
+	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
+	kfree(mlxsw_sx_port);
+}
+
+static void __mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+{
+	enum devlink_port_type port_type =
+		mlxsw_core_port_type_get(mlxsw_sx->core, local_port);
+
+	if (port_type == DEVLINK_PORT_TYPE_ETH)
+		__mlxsw_sx_port_eth_remove(mlxsw_sx, local_port);
+	else if (port_type == DEVLINK_PORT_TYPE_IB)
+		__mlxsw_sx_port_ib_remove(mlxsw_sx, local_port);
+}
+
+static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+{
+	__mlxsw_sx_port_remove(mlxsw_sx, local_port);
+	mlxsw_core_port_fini(mlxsw_sx->core, local_port);
 }
 
 static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
@@ -1170,7 +1311,7 @@ static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
 
 	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
 		if (mlxsw_sx_port_created(mlxsw_sx, i))
-			mlxsw_sx_port_eth_remove(mlxsw_sx, i);
+			mlxsw_sx_port_remove(mlxsw_sx, i);
 	kfree(mlxsw_sx->ports);
 }
 
@@ -1203,17 +1344,41 @@ static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 err_port_module_info_get:
 	for (i--; i >= 1; i--)
 		if (mlxsw_sx_port_created(mlxsw_sx, i))
-			mlxsw_sx_port_eth_remove(mlxsw_sx, i);
+			mlxsw_sx_port_remove(mlxsw_sx, i);
 	kfree(mlxsw_sx->ports);
 	return err;
 }
 
+static void mlxsw_sx_pude_eth_event_func(struct mlxsw_sx_port *mlxsw_sx_port,
+					 enum mlxsw_reg_pude_oper_status status)
+{
+	if (status == MLXSW_PORT_OPER_STATUS_UP) {
+		netdev_info(mlxsw_sx_port->dev, "link up\n");
+		netif_carrier_on(mlxsw_sx_port->dev);
+	} else {
+		netdev_info(mlxsw_sx_port->dev, "link down\n");
+		netif_carrier_off(mlxsw_sx_port->dev);
+	}
+}
+
+static void mlxsw_sx_pude_ib_event_func(struct mlxsw_sx_port *mlxsw_sx_port,
+					enum mlxsw_reg_pude_oper_status status)
+{
+	if (status == MLXSW_PORT_OPER_STATUS_UP)
+		pr_info("ib link for port %d - up\n",
+			mlxsw_sx_port->mapping.module + 1);
+	else
+		pr_info("ib link for port %d - down\n",
+			mlxsw_sx_port->mapping.module + 1);
+}
+
 static void mlxsw_sx_pude_event_func(const struct mlxsw_reg_info *reg,
 				     char *pude_pl, void *priv)
 {
 	struct mlxsw_sx *mlxsw_sx = priv;
 	struct mlxsw_sx_port *mlxsw_sx_port;
 	enum mlxsw_reg_pude_oper_status status;
+	enum devlink_port_type port_type;
 	u8 local_port;
 
 	local_port = mlxsw_reg_pude_local_port_get(pude_pl);
@@ -1225,13 +1390,11 @@ static void mlxsw_sx_pude_event_func(const struct mlxsw_reg_info *reg,
 	}
 
 	status = mlxsw_reg_pude_oper_status_get(pude_pl);
-	if (status == MLXSW_PORT_OPER_STATUS_UP) {
-		netdev_info(mlxsw_sx_port->dev, "link up\n");
-		netif_carrier_on(mlxsw_sx_port->dev);
-	} else {
-		netdev_info(mlxsw_sx_port->dev, "link down\n");
-		netif_carrier_off(mlxsw_sx_port->dev);
-	}
+	port_type = mlxsw_core_port_type_get(mlxsw_sx->core, local_port);
+	if (port_type == DEVLINK_PORT_TYPE_ETH)
+		mlxsw_sx_pude_eth_event_func(mlxsw_sx_port, status);
+	else if (port_type == DEVLINK_PORT_TYPE_IB)
+		mlxsw_sx_pude_ib_event_func(mlxsw_sx_port, status);
 }
 
 static struct mlxsw_event_listener mlxsw_sx_pude_event = {
@@ -1305,6 +1468,33 @@ static void mlxsw_sx_rx_listener_func(struct sk_buff *skb, u8 local_port,
 	netif_receive_skb(skb);
 }
 
+static int mlxsw_sx_port_type_set(struct mlxsw_core *mlxsw_core, u8 local_port,
+				  enum devlink_port_type new_type)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_core_driver_priv(mlxsw_core);
+	u8 module, width;
+	int err;
+
+	if (new_type == DEVLINK_PORT_TYPE_AUTO)
+		return -EOPNOTSUPP;
+
+	__mlxsw_sx_port_remove(mlxsw_sx, local_port);
+	err = mlxsw_sx_port_module_info_get(mlxsw_sx, local_port, &module,
+					    &width);
+	if (err)
+		goto err_port_module_info_get;
+
+	if (new_type == DEVLINK_PORT_TYPE_ETH)
+		err = __mlxsw_sx_port_eth_create(mlxsw_sx, local_port, module,
+						 width);
+	else if (new_type == DEVLINK_PORT_TYPE_IB)
+		err = __mlxsw_sx_port_ib_create(mlxsw_sx, local_port, module,
+						width);
+
+err_port_module_info_get:
+	return err;
+}
+
 static const struct mlxsw_rx_listener mlxsw_sx_rx_listener[] = {
 	{
 		.func = mlxsw_sx_rx_listener_func,
@@ -1614,6 +1804,7 @@ static struct mlxsw_driver mlxsw_sx_driver = {
 	.txhdr_construct	= mlxsw_sx_txhdr_construct,
 	.txhdr_len		= MLXSW_TXHDR_LEN,
 	.profile		= &mlxsw_sx_config_profile,
+	.port_type_set		= mlxsw_sx_port_type_set,
 };
 
 static const struct pci_device_id mlxsw_sx_pci_id_table[] = {
-- 
2.5.5
