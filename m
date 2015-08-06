From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/7] mlxsw: Make system port to local port mapping explicit
Date: Thu,  6 Aug 2015 16:41:53 +0200
Message-ID: <1438872118-16869-3-git-send-email-jiri@resnulli.us>
References: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35288 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbbHFOmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 10:42:08 -0400
Received: by wibxm9 with SMTP id xm9so25601209wib.0
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 07:42:06 -0700 (PDT)
In-Reply-To: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

System ports are unique identifiers in a multi-ASIC environment that
represent all the available ports in the system. Local ports on the
other hand, are unique only within the local ASIC.

Since system port to local port mapping is not part of the HW-SW
contract and since only single-ASIC configurations are currently
supported, set an explicit 1:1 mapping by configuring the Switch System
Port Record (SSPR) register.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 60 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 18 ++++++++
 2 files changed, 78 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index b5a72f8..096e1c1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -150,6 +150,64 @@ static inline void mlxsw_reg_smid_pack(char *payload, u16 mid)
 	mlxsw_reg_smid_port_mask_set(payload, MLXSW_PORT_CPU_PORT, 1);
 }
 
+/* SSPR - Switch System Port Record Register
+ * -----------------------------------------
+ * Configures the system port to local port mapping.
+ */
+#define MLXSW_REG_SSPR_ID 0x2008
+#define MLXSW_REG_SSPR_LEN 0x8
+
+static const struct mlxsw_reg_info mlxsw_reg_sspr = {
+	.id = MLXSW_REG_SSPR_ID,
+	.len = MLXSW_REG_SSPR_LEN,
+};
+
+/* reg_sspr_m
+ * Master - if set, then the record describes the master system port.
+ * This is needed in case a local port is mapped into several system ports
+ * (for multipathing). That number will be reported as the source system
+ * port when packets are forwarded to the CPU. Only one master port is allowed
+ * per local port.
+ *
+ * Note: Must be set for Spectrum.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sspr, m, 0x00, 31, 1);
+
+/* reg_sspr_local_port
+ * Local port number.
+ *
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sspr, local_port, 0x00, 16, 8);
+
+/* reg_sspr_sub_port
+ * Virtual port within the physical port.
+ * Should be set to 0 when virtual ports are not enabled on the port.
+ *
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sspr, sub_port, 0x00, 8, 8);
+
+/* reg_sspr_system_port
+ * Unique identifier within the stacking domain that represents all the ports
+ * that are available in the system (external ports).
+ *
+ * Currently, only single-ASIC configurations are supported, so we default to
+ * 1:1 mapping between system ports and local ports.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sspr, system_port, 0x04, 0, 16);
+
+static inline void mlxsw_reg_sspr_pack(char *payload, u8 local_port)
+{
+	MLXSW_REG_ZERO(sspr, payload);
+	mlxsw_reg_sspr_m_set(payload, 1);
+	mlxsw_reg_sspr_local_port_set(payload, local_port);
+	mlxsw_reg_sspr_sub_port_set(payload, 0);
+	mlxsw_reg_sspr_system_port_set(payload, local_port);
+}
+
 /* SPMS - Switch Port MSTP/RSTP State Register
  * -------------------------------------------
  * Configures the spanning tree state of a physical port.
@@ -1216,6 +1274,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SPAD";
 	case MLXSW_REG_SMID_ID:
 		return "SMID";
+	case MLXSW_REG_SSPR_ID:
+		return "SSPR";
 	case MLXSW_REG_SPMS_ID:
 		return "SPMS";
 	case MLXSW_REG_SFGC_ID:
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 687f5cb..7eb045e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -245,6 +245,16 @@ static int mlxsw_sx_port_swid_set(struct mlxsw_sx_port *mlxsw_sx_port, u8 swid)
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(pspa), pspa_pl);
 }
 
+static int
+mlxsw_sx_port_system_port_mapping_set(struct mlxsw_sx_port *mlxsw_sx_port)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char sspr_pl[MLXSW_REG_SSPR_LEN];
+
+	mlxsw_reg_sspr_pack(sspr_pl, mlxsw_sx_port->local_port);
+	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sspr), sspr_pl);
+}
+
 static int mlxsw_sx_port_module_check(struct mlxsw_sx_port *mlxsw_sx_port,
 				      bool *p_usable)
 {
@@ -1001,6 +1011,13 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 		goto port_not_usable;
 	}
 
+	err = mlxsw_sx_port_system_port_mapping_set(mlxsw_sx_port);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set system port mapping\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_system_port_mapping_set;
+	}
+
 	err = mlxsw_sx_port_swid_set(mlxsw_sx_port, 0);
 	if (err) {
 		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set SWID\n",
@@ -1061,6 +1078,7 @@ err_port_stp_state_set:
 err_port_mtu_set:
 err_port_speed_set:
 err_port_swid_set:
+err_port_system_port_mapping_set:
 port_not_usable:
 err_port_module_check:
 err_dev_addr_get:
-- 
1.9.3
