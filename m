From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 02/21] mlxsw: reg: Update RATR to support IP-in-IP tunnels
Date: Sat,  2 Sep 2017 23:49:10 +0200
Message-ID: <20170902214929.2890-3-jiri@resnulli.us>
References: <20170902214929.2890-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:37536 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752761AbdIBVth (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 17:49:37 -0400
Received: by mail-wr0-f194.google.com with SMTP id y15so1122992wrc.4
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 14:49:36 -0700 (PDT)
In-Reply-To: <20170902214929.2890-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

So far, adjacencies have always been of type Ethernet (with value of 0),
and thus there was no need to explicitly support RATR type. However to
support IP-in-IP adjacencies, this type and a suite of IP-in-IP-specific
attributes need to be added.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 66 +++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 8736f8492..6a7757f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4362,6 +4362,38 @@ MLXSW_ITEM32(reg, ratr, v, 0x00, 24, 1);
  */
 MLXSW_ITEM32(reg, ratr, a, 0x00, 16, 1);
 
+enum mlxsw_reg_ratr_type {
+	/* Ethernet */
+	MLXSW_REG_RATR_TYPE_ETHERNET,
+	/* IPoIB Unicast without GRH.
+	 * Reserved for Spectrum.
+	 */
+	MLXSW_REG_RATR_TYPE_IPOIB_UC,
+	/* IPoIB Unicast with GRH. Supported only in table 0 (Ethernet unicast
+	 * adjacency).
+	 * Reserved for Spectrum.
+	 */
+	MLXSW_REG_RATR_TYPE_IPOIB_UC_W_GRH,
+	/* IPoIB Multicast.
+	 * Reserved for Spectrum.
+	 */
+	MLXSW_REG_RATR_TYPE_IPOIB_MC,
+	/* MPLS.
+	 * Reserved for SwitchX/-2.
+	 */
+	MLXSW_REG_RATR_TYPE_MPLS,
+	/* IPinIP Encap.
+	 * Reserved for SwitchX/-2.
+	 */
+	MLXSW_REG_RATR_TYPE_IPIP,
+};
+
+/* reg_ratr_type
+ * Adjacency entry type.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, type, 0x04, 28, 4);
+
 /* reg_ratr_adjacency_index_low
  * Bits 15:0 of index into the adjacency table.
  * For SwitchX and SwitchX-2, the adjacency table is linear and
@@ -4416,6 +4448,34 @@ MLXSW_ITEM32(reg, ratr, trap_id, 0x0C, 0, 8);
  */
 MLXSW_ITEM_BUF(reg, ratr, eth_destination_mac, 0x12, 6);
 
+enum mlxsw_reg_ratr_ipip_type {
+	/* IPv4, address set by mlxsw_reg_ratr_ipip_ipv4_udip. */
+	MLXSW_REG_RATR_IPIP_TYPE_IPV4,
+	/* IPv6, address set by mlxsw_reg_ratr_ipip_ipv6_ptr. */
+	MLXSW_REG_RATR_IPIP_TYPE_IPV6,
+};
+
+/* reg_ratr_ipip_type
+ * Underlay destination ip type.
+ * Note: the type field must match the protocol of the router interface.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, ipip_type, 0x10, 16, 4);
+
+/* reg_ratr_ipip_ipv4_udip
+ * Underlay ipv4 dip.
+ * Reserved when ipip_type is IPv6.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, ipip_ipv4_udip, 0x18, 0, 32);
+
+/* reg_ratr_ipip_ipv6_ptr
+ * Pointer to IPv6 underlay destination ip address.
+ * For Spectrum: Pointer to KVD linear space.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, ipip_ipv6_ptr, 0x1C, 0, 24);
+
 static inline void
 mlxsw_reg_ratr_pack(char *payload,
 		    enum mlxsw_reg_ratr_op op, bool valid,
@@ -4435,6 +4495,12 @@ static inline void mlxsw_reg_ratr_eth_entry_pack(char *payload,
 	mlxsw_reg_ratr_eth_destination_mac_memcpy_to(payload, dest_mac);
 }
 
+static inline void mlxsw_reg_ratr_ipip4_entry_pack(char *payload, u32 ipv4_udip)
+{
+	mlxsw_reg_ratr_ipip_type_set(payload, MLXSW_REG_RATR_IPIP_TYPE_IPV4);
+	mlxsw_reg_ratr_ipip_ipv4_udip_set(payload, ipv4_udip);
+}
+
 /* RICNT - Router Interface Counter Register
  * -----------------------------------------
  * The RICNT register retrieves per port performance counters
-- 
2.9.3
