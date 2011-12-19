From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 2/5] mlx4_core: Changing link sensing logic
Date: Mon, 19 Dec 2011 16:00:34 +0200
Message-ID: <4EEF4382.9090708@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:40655 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752409Ab1LSQMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 11:12:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

New FW can give clues to driver regarding default port type
and whether or not we should default to link sensing on the port.

2 bits are added to QUERY_PORT command:
1. suggested_type: This bit gives a hint whether the default port type should be
   IB or Ethernet.
   The driver will use this hint in case the user didn't specify explicitly the link layer
   type he wants to set.
2. default_sense: If this bit is set, we would sense the port type on start-up
   and default the port to link sensing

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |    2 +
 drivers/net/ethernet/mellanox/mlx4/fw.h   |    2 +
 drivers/net/ethernet/mellanox/mlx4/main.c |   50 +++++++++++++++++++---------
 include/linux/mlx4/device.h               |    2 +
 4 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index f03b54e..abefcc8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -577,6 +577,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 
 			MLX4_GET(field, outbox, QUERY_PORT_SUPPORTED_TYPE_OFFSET);
 			dev_cap->supported_port_types[i] = field & 3;
+			dev_cap->suggested_type[i] = (field >> 3) & 1;
+			dev_cap->default_sense[i] = (field >> 4) & 1;
 			MLX4_GET(field, outbox, QUERY_PORT_MTU_OFFSET);
 			dev_cap->ib_mtu[i]	   = field & 0xf;
 			MLX4_GET(field, outbox, QUERY_PORT_WIDTH_OFFSET);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 3368363..119e0cc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -111,6 +111,8 @@ struct mlx4_dev_cap {
 	u64 max_icm_sz;
 	int max_gso_sz;
 	u8  supported_port_types[MLX4_MAX_PORTS + 1];
+	u8  suggested_type[MLX4_MAX_PORTS + 1];
+	u8  default_sense[MLX4_MAX_PORTS + 1];
 	u8  log_max_macs[MLX4_MAX_PORTS + 1];
 	u8  log_max_vlans[MLX4_MAX_PORTS + 1];
 	u32 max_counters;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 8f73143..e984ded 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -130,10 +130,11 @@ int log_mtts_per_seg = ilog2(MLX4_MTT_ENTRY_PER_SEG);
 module_param_named(log_mtts_per_seg, log_mtts_per_seg, int, 0444);
 MODULE_PARM_DESC(log_mtts_per_seg, "Log2 number of MTT entries per segment (1-7)");
 
-static int port_type_array[2] = {1, 1};
+static int port_type_array[2] = {MLX4_PORT_TYPE_NONE, MLX4_PORT_TYPE_NONE};
 static int arr_argc = 2;
 module_param_array(port_type_array, int, &arr_argc, 0444);
-MODULE_PARM_DESC(port_type_array, "Array of port types: IB by default");
+MODULE_PARM_DESC(port_type_array, "Array of port types: HW_DEFAULT (0) is default "
+				"1 for IB, 2 for Ethernet");
 
 struct mlx4_port_config {
 	struct list_head list;
@@ -225,6 +226,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev->caps.eth_mtu_cap[i]    = dev_cap->eth_mtu[i];
 		dev->caps.def_mac[i]        = dev_cap->def_mac[i];
 		dev->caps.supported_type[i] = dev_cap->supported_port_types[i];
+		dev->caps.suggested_type[i] = dev_cap->suggested_type[i];
+		dev->caps.default_sense[i] = dev_cap->default_sense[i];
 		dev->caps.trans_type[i]	    = dev_cap->trans_type[i];
 		dev->caps.vendor_oui[i]     = dev_cap->vendor_oui[i];
 		dev->caps.wavelength[i]     = dev_cap->wavelength[i];
@@ -302,22 +305,43 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 			 * first of all check if SRIOV is on */
 			} else if (dev->flags & MLX4_FLAG_SRIOV)
 				dev->caps.port_type[i] = MLX4_PORT_TYPE_ETH;
-			/* if IB and ETH are supported and SRIOV is off
-			 * use module parameters */
 			else {
-				if (port_type_array[i-1])
-					dev->caps.port_type[i] =
-						MLX4_PORT_TYPE_IB;
+				/* In non-SRIOV mode, we set the port type
+				 * according to user selection of port type,
+				 * if usere selected none, take the FW hint */
+				if (port_type_array[i-1] == MLX4_PORT_TYPE_NONE)
+					dev->caps.port_type[i] = dev->caps.suggested_type[i] ?
+						MLX4_PORT_TYPE_ETH : MLX4_PORT_TYPE_IB;
 				else
-					dev->caps.port_type[i] =
-						MLX4_PORT_TYPE_ETH;
+					dev->caps.port_type[i] = port_type_array[i-1];
 			}
 		}
-		dev->caps.possible_type[i] = dev->caps.port_type[i];
+		/*
+		 * Link sensing is allowed on the port if 3 conditions are true:
+		 * 1. Both protocols are supported on the port.
+		 * 2. Different types are supported on the port
+		 * 3. FW declared that it supports link sensing
+		 */
 		mlx4_priv(dev)->sense.sense_allowed[i] =
 			((dev->caps.supported_type[i] == MLX4_PORT_TYPE_AUTO) &&
+			 (dev->caps.flags & MLX4_DEV_CAP_FLAG_DPDP) &&
 			 (dev->caps.flags & MLX4_DEV_CAP_FLAG_SENSE_SUPPORT));
 
+		/*
+		 * If "default_sense" bit is set, we move the port to "AUTO" mode
+		 * and perform sense_port FW command to try and set the correct
+		 * port type from beginning
+		 */
+		if (mlx4_priv(dev)->sense.sense_allowed && dev->caps.default_sense[i]) {
+			enum mlx4_port_type sensed_port = MLX4_PORT_TYPE_NONE;
+			dev->caps.possible_type[i] = MLX4_PORT_TYPE_AUTO;
+			mlx4_SENSE_PORT(dev, i, &sensed_port);
+			if (sensed_port != MLX4_PORT_TYPE_NONE)
+				dev->caps.port_type[i] = sensed_port;
+		} else {
+			dev->caps.possible_type[i] = dev->caps.port_type[i];
+		}
+
 		if (dev->caps.log_num_macs > dev_cap->log_max_macs[i]) {
 			dev->caps.log_num_macs = dev_cap->log_max_macs[i];
 			mlx4_warn(dev, "Requested number of MACs is too much "
@@ -1329,12 +1353,6 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 
 	if (!mlx4_is_slave(dev)) {
 		for (port = 1; port <= dev->caps.num_ports; port++) {
-			if (!mlx4_is_mfunc(dev)) {
-				enum mlx4_port_type port_type = 0;
-				mlx4_SENSE_PORT(dev, port, &port_type);
-				if (port_type)
-					dev->caps.port_type[port] = port_type;
-			}
 			ib_port_default_caps = 0;
 			err = mlx4_get_port_ib_caps(dev, port,
 						    &ib_port_default_caps);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b06a44b..5c4fe8e 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -303,6 +303,8 @@ struct mlx4_caps {
 	int                     log_num_prios;
 	enum mlx4_port_type	port_type[MLX4_MAX_PORTS + 1];
 	u8			supported_type[MLX4_MAX_PORTS + 1];
+	u8                      suggested_type[MLX4_MAX_PORTS + 1];
+	u8                      default_sense[MLX4_MAX_PORTS + 1];
 	u32			port_mask[MLX4_MAX_PORTS + 1];
 	enum mlx4_port_type	possible_type[MLX4_MAX_PORTS + 1];
 	u32			max_counters;
-- 
1.7.7
