From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 15/23 v3] mlx4_core: Activating ports according to function
 number
Date: Thu, 04 Feb 2010 17:56:22 +0200
Message-ID: <4B6AEE26.40407@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49816 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933222Ab0BDP4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:56:24 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In devices with multiple physical functions, each function activates
only one port, according to the function number.
Even functions activate port 1, odd functions activate port2.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/fw.c       |   13 +++++++++++--
 drivers/net/mlx4/main.c     |   16 +++++++++-------
 drivers/net/mlx4/mlx4.h     |    1 +
 include/linux/mlx4/device.h |    7 ++++---
 4 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 3c6601a..f797a43 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -155,9 +155,13 @@ int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 	/* The Master function is in charge for qp1 of al slaves */
 	caps->sqp_demux = 0;
 
+	/* Ports are activated according to physical function number */
+	mlx4_set_port_mask(dev, caps, slave);
+
 	/* PDs have the same range in every guest; the distinction is in the msbs,
 	 * which contains the guest ID (vf + 1) */
 	caps->pd_base = slave + 1;
+	caps->function = slave;
 
 	/* All other resources are allocated by the master, but we still report
 	 * 'num' and 'reserved' capabilities as follows:
@@ -602,6 +606,7 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 
 #define QUERY_FW_OUT_SIZE             0x100
 #define QUERY_FW_VER_OFFSET            0x00
+#define QUERY_FW_PPF_ID                0x09
 #define QUERY_FW_CMD_IF_REV_OFFSET     0x0a
 #define QUERY_FW_MAX_CMD_OFFSET        0x0f
 #define QUERY_FW_ERR_START_OFFSET      0x30
@@ -634,6 +639,9 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 		((fw_ver & 0xffff0000ull) >> 16) |
 		((fw_ver & 0x0000ffffull) << 16);
 
+	MLX4_GET(lg, outbox, QUERY_FW_PPF_ID);
+	dev->caps.function = lg;
+
 	MLX4_GET(cmd_if_rev, outbox, QUERY_FW_CMD_IF_REV_OFFSET);
 	if (cmd_if_rev < MLX4_COMMAND_INTERFACE_MIN_REV ||
 	    cmd_if_rev > MLX4_COMMAND_INTERFACE_MAX_REV) {
@@ -944,7 +952,8 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 		mlx4_free_cmd_mailbox(dev, mailbox);
 	} else {
 		if (mlx4_is_master(dev))
-			err = mlx4_common_init_port(dev, 0, port);
+			err = mlx4_common_init_port(dev, dev->caps.function,
+						    port);
 		else
 			err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_INIT_PORT,
 				       MLX4_CMD_TIME_CLASS_A);
@@ -984,7 +993,7 @@ int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *v
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port)
 {
 	if (mlx4_is_master(dev))
-		return mlx4_common_close_port(dev, 0, port);
+		return mlx4_common_close_port(dev, dev->caps.function, port);
 	else
 		return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000);
 }
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 9f9292a..41e622e 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -149,14 +149,16 @@ int mlx4_check_port_params(struct mlx4_dev *dev,
 	return 0;
 }
 
-static void mlx4_set_port_mask(struct mlx4_dev *dev)
+void mlx4_set_port_mask(struct mlx4_dev *dev, struct mlx4_caps *caps, int function)
 {
 	int i;
+	int active = (function & 1) + 1;
 
-	dev->caps.port_mask = 0;
-	for (i = 1; i <= dev->caps.num_ports; ++i)
-		if (dev->caps.port_type[i] == MLX4_PORT_TYPE_IB)
-			dev->caps.port_mask |= 1 << (i - 1);
+	for (i = 1; i <= caps->num_ports; ++i) {
+		caps->port_mask[i] = caps->port_type[i];
+		if (dev->caps.pf_num > 1 && i != active)
+			caps->port_mask[i] = 0;
+	}
 }
 
 static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
@@ -272,7 +274,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		}
 	}
 
-	mlx4_set_port_mask(dev);
+	mlx4_set_port_mask(dev, &dev->caps, dev->caps.pf_num);
 
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW] = dev_cap->reserved_qps;
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_ETH_ADDR] =
@@ -385,7 +387,7 @@ int mlx4_change_port_types(struct mlx4_dev *dev,
 				goto out;
 			}
 		}
-		mlx4_set_port_mask(dev);
+		mlx4_set_port_mask(dev, &dev->caps, dev->caps.pf_num);
 		err = mlx4_register_device(dev);
 	}
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 6421932..3417888 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -528,6 +528,7 @@ int mlx4_check_port_params(struct mlx4_dev *dev,
 			   enum mlx4_port_type *port_type);
 int mlx4_change_port_types(struct mlx4_dev *dev,
 			   enum mlx4_port_type *port_types);
+void mlx4_set_port_mask(struct mlx4_dev *dev, struct mlx4_caps *caps, int function);
 
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table);
 void mlx4_init_vlan_table(struct mlx4_dev *dev, struct mlx4_vlan_table *table);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 38de006..563679b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -162,6 +162,7 @@ enum mlx4_qp_region {
 };
 
 enum mlx4_port_type {
+	MLX4_PORT_TYPE_NONE	= 0,
 	MLX4_PORT_TYPE_IB	= 1,
 	MLX4_PORT_TYPE_ETH	= 2,
 	MLX4_PORT_TYPE_AUTO	= 3
@@ -184,6 +185,7 @@ static inline u64 mlx4_fw_ver(u64 major, u64 minor, u64 subminor)
 
 struct mlx4_caps {
 	u64			fw_ver;
+	int			function;
 	int			pf_num;
 	int			num_ports;
 	int			vl_cap[MLX4_MAX_PORTS + 1];
@@ -252,7 +254,7 @@ struct mlx4_caps {
 	enum mlx4_port_type	port_type[MLX4_MAX_PORTS + 1];
 	u8			supported_type[MLX4_MAX_PORTS + 1];
 	u8                      sqp_demux;
-	u32			port_mask;
+	u8			port_mask[MLX4_MAX_PORTS + 1];
 	enum mlx4_port_type	possible_type[MLX4_MAX_PORTS + 1];
 };
 
@@ -412,8 +414,7 @@ struct mlx4_init_port_param {
 
 #define mlx4_foreach_port(port, dev, type)				\
 	for ((port) = 1; (port) <= (dev)->caps.num_ports; (port)++)	\
-		if (((type) == MLX4_PORT_TYPE_IB ? (dev)->caps.port_mask : \
-		     ~(dev)->caps.port_mask) & 1 << ((port) - 1))
+		if ((type) == (dev)->caps.port_mask[port])
 
 static inline int mlx4_is_slave(struct mlx4_dev *dev)
 {
-- 
1.6.1.3


