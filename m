From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: spectrum: Add support for flower matches on VLAN ID, PCP
Date: Thu,  9 Mar 2017 09:25:20 +0100
Message-ID: <1489047920-3557-3-git-send-email-jiri@resnulli.us>
References: <1489047920-3557-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36124 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753118AbdCIIZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 03:25:26 -0500
Received: by mail-wm0-f68.google.com with SMTP id v190so9668367wme.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 00:25:25 -0800 (PST)
In-Reply-To: <1489047920-3557-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Introduce MLXSW_AFK_ELEMENT_VID, PCP and declare them in afk_element
infos that contain them.  Use the elements when VLAD ID or priority are
used in the flow.

Also add MLXSW_AFK_ELEMENT_VID, PCP to mlxsw_sp_acl_tcam_pattern_ipv4.
Both items are included in mlxsw_sp_afk_element_info_l2_dmac,
resp. _smac, and both MLXSW_AFK_ELEMENT_SMAC and _DMAC are already in
the pattern.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/core_acl_flex_keys.h   |  6 +++++-
 .../mellanox/mlxsw/spectrum_acl_flex_keys.h        |  6 ++++++
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    |  2 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 24 +++++++++++++++++++++-
 4 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
index e4fcba7..c75e914 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
@@ -54,6 +54,8 @@ enum mlxsw_afk_element {
 	MLXSW_AFK_ELEMENT_DST_IP6_LO,
 	MLXSW_AFK_ELEMENT_DST_L4_PORT,
 	MLXSW_AFK_ELEMENT_SRC_L4_PORT,
+	MLXSW_AFK_ELEMENT_VID,
+	MLXSW_AFK_ELEMENT_PCP,
 	MLXSW_AFK_ELEMENT_MAX,
 };
 
@@ -88,7 +90,7 @@ struct mlxsw_afk_element_info {
 	MLXSW_AFK_ELEMENT_INFO(MLXSW_AFK_ELEMENT_TYPE_BUF,			\
 			       _element, _offset, 0, _size)
 
-/* For the purpose of the driver, define a internal storage scratchpad
+/* For the purpose of the driver, define an internal storage scratchpad
  * that will be used to store key/mask values. For each defined element type
  * define an internal storage geometry.
  */
@@ -98,6 +100,8 @@ static const struct mlxsw_afk_element_info mlxsw_afk_element_infos[] = {
 	MLXSW_AFK_ELEMENT_INFO_BUF(SMAC, 0x0A, 6),
 	MLXSW_AFK_ELEMENT_INFO_U32(ETHERTYPE, 0x00, 0, 16),
 	MLXSW_AFK_ELEMENT_INFO_U32(IP_PROTO, 0x10, 0, 8),
+	MLXSW_AFK_ELEMENT_INFO_U32(VID, 0x10, 8, 12),
+	MLXSW_AFK_ELEMENT_INFO_U32(PCP, 0x10, 20, 3),
 	MLXSW_AFK_ELEMENT_INFO_U32(SRC_IP4, 0x18, 0, 32),
 	MLXSW_AFK_ELEMENT_INFO_U32(DST_IP4, 0x1C, 0, 32),
 	MLXSW_AFK_ELEMENT_INFO_BUF(SRC_IP6_HI, 0x18, 8),
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
index 82b81cf..af7b7ba 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
@@ -39,11 +39,15 @@
 
 static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_l2_dmac[] = {
 	MLXSW_AFK_ELEMENT_INST_BUF(DMAC, 0x00, 6),
+	MLXSW_AFK_ELEMENT_INST_U32(PCP, 0x08, 13, 3),
+	MLXSW_AFK_ELEMENT_INST_U32(VID, 0x08, 0, 12),
 	MLXSW_AFK_ELEMENT_INST_U32(SRC_SYS_PORT, 0x0C, 0, 16),
 };
 
 static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_l2_smac[] = {
 	MLXSW_AFK_ELEMENT_INST_BUF(SMAC, 0x00, 6),
+	MLXSW_AFK_ELEMENT_INST_U32(PCP, 0x08, 13, 3),
+	MLXSW_AFK_ELEMENT_INST_U32(VID, 0x08, 0, 12),
 	MLXSW_AFK_ELEMENT_INST_U32(SRC_SYS_PORT, 0x0C, 0, 16),
 };
 
@@ -65,6 +69,8 @@ static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4_dip[] = {
 };
 
 static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4_ex[] = {
+	MLXSW_AFK_ELEMENT_INST_U32(VID, 0x00, 0, 12),
+	MLXSW_AFK_ELEMENT_INST_U32(PCP, 0x08, 29, 3),
 	MLXSW_AFK_ELEMENT_INST_U32(SRC_L4_PORT, 0x08, 0, 16),
 	MLXSW_AFK_ELEMENT_INST_U32(DST_L4_PORT, 0x0C, 0, 16),
 };
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
index 7382832..6858439 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
@@ -950,6 +950,8 @@ static const enum mlxsw_afk_element mlxsw_sp_acl_tcam_pattern_ipv4[] = {
 	MLXSW_AFK_ELEMENT_DST_IP4,
 	MLXSW_AFK_ELEMENT_DST_L4_PORT,
 	MLXSW_AFK_ELEMENT_SRC_L4_PORT,
+	MLXSW_AFK_ELEMENT_VID,
+	MLXSW_AFK_ELEMENT_PCP,
 };
 
 static const enum mlxsw_afk_element mlxsw_sp_acl_tcam_pattern_ipv6[] = {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index d898407..f2ed0b3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -183,7 +183,8 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 	      BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
-	      BIT(FLOW_DISSECTOR_KEY_PORTS))) {
+	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
+	      BIT(FLOW_DISSECTOR_KEY_VLAN))) {
 		dev_err(mlxsw_sp->bus_info->dev, "Unsupported key\n");
 		return -EOPNOTSUPP;
 	}
@@ -244,6 +245,27 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 					       sizeof(key->src));
 	}
 
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_VLAN)) {
+		struct flow_dissector_key_vlan *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_VLAN,
+						  f->key);
+		struct flow_dissector_key_vlan *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_VLAN,
+						  f->mask);
+		if (mask->vlan_id != 0)
+			mlxsw_sp_acl_rulei_keymask_u32(rulei,
+						       MLXSW_AFK_ELEMENT_VID,
+						       key->vlan_id,
+						       mask->vlan_id);
+		if (mask->vlan_priority != 0)
+			mlxsw_sp_acl_rulei_keymask_u32(rulei,
+						       MLXSW_AFK_ELEMENT_PCP,
+						       key->vlan_priority,
+						       mask->vlan_priority);
+	}
+
 	if (addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS)
 		mlxsw_sp_flower_parse_ipv4(rulei, f);
 
-- 
2.7.4
