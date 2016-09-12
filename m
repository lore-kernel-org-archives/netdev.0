From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] mlxsw: spectrum: Report link partner's advertised speeds
Date: Mon, 12 Sep 2016 13:26:24 +0200
Message-ID: <1473679587-9112-3-git-send-email-jiri@resnulli.us>
References: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34925 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755984AbcILL0d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 07:26:33 -0400
Received: by mail-wm0-f68.google.com with SMTP id a6so13151606wmc.2
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 04:26:32 -0700 (PDT)
In-Reply-To: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

If autonegotiation was performed successfully, then we should report the
link partner's advertised speeds instead of the operational speed of the
port.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 19 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  9 ++++++++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index b83d0a7..43ce27f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2138,6 +2138,18 @@ MLXSW_ITEM32(reg, ptys, local_port, 0x00, 16, 8);
  */
 MLXSW_ITEM32(reg, ptys, proto_mask, 0x00, 0, 3);
 
+enum {
+	MLXSW_REG_PTYS_AN_STATUS_NA,
+	MLXSW_REG_PTYS_AN_STATUS_OK,
+	MLXSW_REG_PTYS_AN_STATUS_FAIL,
+};
+
+/* reg_ptys_an_status
+ * Autonegotiation status.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ptys, an_status, 0x04, 28, 4);
+
 #define MLXSW_REG_PTYS_ETH_SPEED_SGMII			BIT(0)
 #define MLXSW_REG_PTYS_ETH_SPEED_1000BASE_KX		BIT(1)
 #define MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CX4		BIT(2)
@@ -2184,6 +2196,13 @@ MLXSW_ITEM32(reg, ptys, eth_proto_admin, 0x18, 0, 32);
  */
 MLXSW_ITEM32(reg, ptys, eth_proto_oper, 0x24, 0, 32);
 
+/* reg_ptys_eth_proto_lp_advertise
+ * The protocols that were advertised by the link partner during
+ * autonegotiation.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ptys, eth_proto_lp_advertise, 0x30, 0, 32);
+
 static inline void mlxsw_reg_ptys_pack(char *payload, u8 local_port,
 				       u32 proto_admin)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 9de2383..e035a9d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1799,6 +1799,8 @@ static int mlxsw_sp_port_get_settings(struct net_device *dev,
 	u32 eth_proto_cap;
 	u32 eth_proto_admin;
 	u32 eth_proto_oper;
+	u8 autoneg_status;
+	u32 eth_proto_lp;
 	int err;
 
 	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
@@ -1809,6 +1811,8 @@ static int mlxsw_sp_port_get_settings(struct net_device *dev,
 	}
 	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap,
 			      &eth_proto_admin, &eth_proto_oper);
+	eth_proto_lp = mlxsw_reg_ptys_eth_proto_lp_advertise_get(ptys_pl);
+	autoneg_status = mlxsw_reg_ptys_an_status_get(ptys_pl);
 
 	cmd->supported = mlxsw_sp_from_ptys_supported_port(eth_proto_cap) |
 			 mlxsw_sp_from_ptys_supported_link(eth_proto_cap) |
@@ -1825,7 +1829,10 @@ static int mlxsw_sp_port_get_settings(struct net_device *dev,
 
 	eth_proto_oper = eth_proto_oper ? eth_proto_oper : eth_proto_cap;
 	cmd->port = mlxsw_sp_port_connector_port(eth_proto_oper);
-	cmd->lp_advertising = mlxsw_sp_from_ptys_advert_link(eth_proto_oper);
+
+	if (autoneg_status == MLXSW_REG_PTYS_AN_STATUS_OK && eth_proto_lp)
+		cmd->lp_advertising =
+			mlxsw_sp_from_ptys_advert_link(eth_proto_lp);
 
 	cmd->transceiver = XCVR_INTERNAL;
 	return 0;
-- 
2.5.5
