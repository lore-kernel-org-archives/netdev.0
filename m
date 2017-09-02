From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/21] mlxsw: reg: Update RITR to support loopback device
Date: Sat,  2 Sep 2017 17:21:06 +0200
Message-ID: <20170902152126.17286-2-jiri@resnulli.us>
References: <20170902152126.17286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33320 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752712AbdIBPVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 11:21:32 -0400
Received: by mail-wm0-f68.google.com with SMTP id 187so2416528wmn.0
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 08:21:32 -0700 (PDT)
In-Reply-To: <20170902152126.17286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Update the register so that loopback RIFs can be created and loopback
properties specified.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 88 +++++++++++++++++++++++++++++++
 1 file changed, 88 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 11e290c..8736f8492 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3998,6 +3998,8 @@ enum mlxsw_reg_ritr_if_type {
 	MLXSW_REG_RITR_FID_IF,
 	/* Sub-port interface. */
 	MLXSW_REG_RITR_SP_IF,
+	/* Loopback Interface. */
+	MLXSW_REG_RITR_LOOPBACK_IF,
 };
 
 /* reg_ritr_type
@@ -4129,6 +4131,67 @@ MLXSW_ITEM32(reg, ritr, sp_if_system_port, 0x08, 0, 16);
  */
 MLXSW_ITEM32(reg, ritr, sp_if_vid, 0x18, 0, 12);
 
+/* Loopback Interface */
+
+enum mlxsw_reg_ritr_loopback_protocol {
+	/* IPinIP IPv4 underlay Unicast */
+	MLXSW_REG_RITR_LOOPBACK_PROTOCOL_IPIP_IPV4,
+	/* IPinIP IPv6 underlay Unicast */
+	MLXSW_REG_RITR_LOOPBACK_PROTOCOL_IPIP_IPV6,
+};
+
+/* reg_ritr_loopback_protocol
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, loopback_protocol, 0x08, 28, 4);
+
+enum mlxsw_reg_ritr_loopback_ipip_type {
+	/* Tunnel is IPinIP. */
+	MLXSW_REG_RITR_LOOPBACK_IPIP_TYPE_IP_IN_IP,
+	/* Tunnel is GRE, no key. */
+	MLXSW_REG_RITR_LOOPBACK_IPIP_TYPE_IP_IN_GRE_IN_IP,
+	/* Tunnel is GRE, with a key. */
+	MLXSW_REG_RITR_LOOPBACK_IPIP_TYPE_IP_IN_GRE_KEY_IN_IP,
+};
+
+/* reg_ritr_loopback_ipip_type
+ * Encapsulation type.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, loopback_ipip_type, 0x10, 24, 4);
+
+enum mlxsw_reg_ritr_loopback_ipip_options {
+	/* The key is defined by gre_key. */
+	MLXSW_REG_RITR_LOOPBACK_IPIP_OPTIONS_GRE_KEY_PRESET,
+};
+
+/* reg_ritr_loopback_ipip_options
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, loopback_ipip_options, 0x10, 20, 4);
+
+/* reg_ritr_loopback_ipip_uvr
+ * Underlay Virtual Router ID.
+ * Range is 0..cap_max_virtual_routers-1.
+ * Reserved for Spectrum-2.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, loopback_ipip_uvr, 0x10, 0, 16);
+
+/* reg_ritr_loopback_ipip_usip*
+ * Encapsulation Underlay source IP.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, ritr, loopback_ipip_usip6, 0x18, 16);
+MLXSW_ITEM32(reg, ritr, loopback_ipip_usip4, 0x24, 0, 32);
+
+/* reg_ritr_loopback_ipip_gre_key
+ * GRE Key.
+ * Reserved when ipip_type is not IP_IN_GRE_KEY_IN_IP.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, loopback_ipip_gre_key, 0x28, 0, 32);
+
 /* Shared between ingress/egress */
 enum mlxsw_reg_ritr_counter_set_type {
 	/* No Count. */
@@ -4219,6 +4282,31 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 	mlxsw_reg_ritr_if_mac_memcpy_to(payload, mac);
 }
 
+static inline void
+mlxsw_reg_ritr_loopback_ipip_common_pack(char *payload,
+			    enum mlxsw_reg_ritr_loopback_ipip_type ipip_type,
+			    enum mlxsw_reg_ritr_loopback_ipip_options options,
+			    u16 uvr_id, u32 gre_key)
+{
+	mlxsw_reg_ritr_loopback_ipip_type_set(payload, ipip_type);
+	mlxsw_reg_ritr_loopback_ipip_options_set(payload, options);
+	mlxsw_reg_ritr_loopback_ipip_uvr_set(payload, uvr_id);
+	mlxsw_reg_ritr_loopback_ipip_gre_key_set(payload, gre_key);
+}
+
+static inline void
+mlxsw_reg_ritr_loopback_ipip4_pack(char *payload,
+			    enum mlxsw_reg_ritr_loopback_ipip_type ipip_type,
+			    enum mlxsw_reg_ritr_loopback_ipip_options options,
+			    u16 uvr_id, u32 usip, u32 gre_key)
+{
+	mlxsw_reg_ritr_loopback_protocol_set(payload,
+				    MLXSW_REG_RITR_LOOPBACK_PROTOCOL_IPIP_IPV4);
+	mlxsw_reg_ritr_loopback_ipip_common_pack(payload, ipip_type, options,
+						 uvr_id, gre_key);
+	mlxsw_reg_ritr_loopback_ipip_usip4_set(payload, usip);
+}
+
 /* RATR - Router Adjacency Table Register
  * --------------------------------------
  * The RATR register is used to configure the Router Adjacency (next-hop)
-- 
2.9.3
