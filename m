From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net-next 3/3] bnx2x: adding dcbnl support
Date: Tue, 21 Dec 2010 21:33:00 +0200
Message-ID: <1292959980.7142.132.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, lucy.liu@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1248 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752650Ab0LUTdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 14:33:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding dcbnl implementation to bnx2x allowing users to manage the
embedded DCBX engine.

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |   23 ++-
 drivers/net/bnx2x/bnx2x_dcb.c  |  661 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/bnx2x/bnx2x_dcb.h  |    9 +-
 drivers/net/bnx2x/bnx2x_main.c |    8 +-
 4 files changed, 676 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index f14c6ed..77d6c8d 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -22,15 +22,17 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.62.00-2"
-#define DRV_MODULE_RELDATE      "2010/12/13"
+#define DRV_MODULE_VERSION      "1.62.00-3"
+#define DRV_MODULE_RELDATE      "2010/12/21"
 #define BNX2X_BC_VER            0x040200
 
 #define BNX2X_MULTI_QUEUE
 
 #define BNX2X_NEW_NAPI
 
-
+#if defined(CONFIG_DCB)
+#define BCM_DCB
+#endif
 #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
 #define BCM_CNIC 1
 #include "../cnic_if.h"
@@ -1186,7 +1188,20 @@ struct bnx2x {
 	/* LLDP params */
 	struct bnx2x_config_lldp_params		lldp_config_params;
 
-	/* DCBX params */
+	/* DCB support on/off */
+	u16 dcb_state;
+#define BNX2X_DCB_STATE_OFF			0
+#define BNX2X_DCB_STATE_ON			1
+
+	/* DCBX engine mode */
+	int dcbx_enabled;
+#define BNX2X_DCBX_ENABLED_OFF			0
+#define BNX2X_DCBX_ENABLED_ON_NEG_OFF		1
+#define BNX2X_DCBX_ENABLED_ON_NEG_ON		2
+#define BNX2X_DCBX_ENABLED_INVALID		(-1)
+
+	bool dcbx_mode_uset;
+
 	struct bnx2x_config_dcbx_params		dcbx_config_params;
 
 	struct bnx2x_dcbx_port_params		dcbx_port_params;
diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index 0b86480..9249aa1 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -619,13 +619,10 @@ static void bnx2x_dcbx_admin_mib_updated_params(struct bnx2x *bp,
 	for (i = 0; i < sizeof(struct lldp_admin_mib); i += 4, buff++)
 		*buff = REG_RD(bp, (offset + i));
 
-
-	if (BNX2X_DCBX_CONFIG_INV_VALUE != dp->admin_dcbx_enable) {
-		if (dp->admin_dcbx_enable)
-			SET_FLAGS(admin_mib.ver_cfg_flags, DCBX_DCBX_ENABLED);
-		else
-			RESET_FLAGS(admin_mib.ver_cfg_flags, DCBX_DCBX_ENABLED);
-	}
+	if (bp->dcbx_enabled == BNX2X_DCBX_ENABLED_ON_NEG_ON)
+		SET_FLAGS(admin_mib.ver_cfg_flags, DCBX_DCBX_ENABLED);
+	else
+		RESET_FLAGS(admin_mib.ver_cfg_flags, DCBX_DCBX_ENABLED);
 
 	if ((BNX2X_DCBX_OVERWRITE_SETTINGS_ENABLE ==
 				dp->overwrite_settings)) {
@@ -734,12 +731,26 @@ static void bnx2x_dcbx_admin_mib_updated_params(struct bnx2x *bp,
 		REG_WR(bp, (offset + i), *buff);
 }
 
-/* default */
+void bnx2x_dcbx_set_state(struct bnx2x *bp, bool dcb_on, u32 dcbx_enabled)
+{
+	if (CHIP_IS_E2(bp) && !CHIP_MODE_IS_4_PORT(bp)) {
+		bp->dcb_state = dcb_on;
+		bp->dcbx_enabled = dcbx_enabled;
+	} else {
+		bp->dcb_state = false;
+		bp->dcbx_enabled = BNX2X_DCBX_ENABLED_INVALID;
+	}
+	DP(NETIF_MSG_LINK, "DCB state [%s:%s]\n",
+	   dcb_on ? "ON" : "OFF",
+	   dcbx_enabled == BNX2X_DCBX_ENABLED_OFF ? "user-mode" :
+	   dcbx_enabled == BNX2X_DCBX_ENABLED_ON_NEG_OFF ? "on-chip static" :
+	   dcbx_enabled == BNX2X_DCBX_ENABLED_ON_NEG_ON ?
+	   "on-chip with negotiation" : "invalid");
+}
+
 void bnx2x_dcbx_init_params(struct bnx2x *bp)
 {
 	bp->dcbx_config_params.admin_dcbx_version = 0x0; /* 0 - CEE; 1 - IEEE */
-	bp->dcbx_config_params.dcb_enable = 1;
-	bp->dcbx_config_params.admin_dcbx_enable = 1;
 	bp->dcbx_config_params.admin_ets_willing = 1;
 	bp->dcbx_config_params.admin_pfc_willing = 1;
 	bp->dcbx_config_params.overwrite_settings = 1;
@@ -807,23 +818,27 @@ void bnx2x_dcbx_init_params(struct bnx2x *bp)
 void bnx2x_dcbx_init(struct bnx2x *bp)
 {
 	u32 dcbx_lldp_params_offset = SHMEM_LLDP_DCBX_PARAMS_NONE;
+
+	if (bp->dcbx_enabled <= 0)
+		return;
+
 	/* validate:
 	 * chip of good for dcbx version,
 	 * dcb is wanted
 	 * the function is pmf
 	 * shmem2 contains DCBX support fields
 	 */
-	DP(NETIF_MSG_LINK, "dcb_enable %d bp->port.pmf %d\n",
-	   bp->dcbx_config_params.dcb_enable, bp->port.pmf);
+	DP(NETIF_MSG_LINK, "dcb_state %d bp->port.pmf %d\n",
+	   bp->dcb_state, bp->port.pmf);
 
-	if (CHIP_IS_E2(bp) && !CHIP_MODE_IS_4_PORT(bp) &&
-	    bp->dcbx_config_params.dcb_enable &&
-	    bp->port.pmf &&
+	if (bp->dcb_state ==  BNX2X_DCB_STATE_ON && bp->port.pmf &&
 	    SHMEM2_HAS(bp, dcbx_lldp_params_offset)) {
-		dcbx_lldp_params_offset = SHMEM2_RD(bp,
-						    dcbx_lldp_params_offset);
+		dcbx_lldp_params_offset =
+			SHMEM2_RD(bp, dcbx_lldp_params_offset);
+
 		DP(NETIF_MSG_LINK, "dcbx_lldp_params_offset 0x%x\n",
 		   dcbx_lldp_params_offset);
+
 		if (SHMEM_LLDP_DCBX_PARAMS_NONE != dcbx_lldp_params_offset) {
 			bnx2x_dcbx_lldp_updated_params(bp,
 						       dcbx_lldp_params_offset);
@@ -1489,3 +1504,615 @@ static void bnx2x_pfc_fw_struct_e2(struct bnx2x *bp)
 	}
 	bnx2x_dcbx_print_cos_params(bp,	pfc_fw_cfg);
 }
+/* DCB netlink */
+#ifdef BCM_DCB
+#include <linux/dcbnl.h>
+
+#define BNX2X_DCBX_CAPS		(DCB_CAP_DCBX_HW | DCB_CAP_DCBX_VER_CEE | \
+				DCB_CAP_DCBX_STATIC)
+
+static inline bool bnx2x_dcbnl_set_valid(struct bnx2x *bp)
+{
+	/* validate dcbnl call that may change HW state:
+	 * DCB is on and DCBX mode was SUCCESSFULLY set by the user.
+	 */
+	return bp->dcb_state && bp->dcbx_mode_uset;
+}
+
+static u8 bnx2x_dcbnl_get_state(struct net_device *netdev)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "state = %d\n", bp->dcb_state);
+	return bp->dcb_state;
+}
+
+static u8 bnx2x_dcbnl_set_state(struct net_device *netdev, u8 state)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "state = %s\n", state ? "on" : "off");
+
+	bnx2x_dcbx_set_state(bp, (state ? true : false), bp->dcbx_enabled);
+	return 0;
+}
+
+static void bnx2x_dcbnl_get_perm_hw_addr(struct net_device *netdev,
+					 u8 *perm_addr)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "GET-PERM-ADDR\n");
+
+	/* first the HW mac address */
+	memcpy(perm_addr, netdev->dev_addr, netdev->addr_len);
+
+#ifdef BCM_CNIC
+	/* second SAN address */
+	memcpy(perm_addr+netdev->addr_len, bp->fip_mac, netdev->addr_len);
+#endif
+}
+
+static void bnx2x_dcbnl_set_pg_tccfg_tx(struct net_device *netdev, int prio,
+					u8 prio_type, u8 pgid, u8 bw_pct,
+					u8 up_map)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+
+	DP(NETIF_MSG_LINK, "prio[%d] = %d\n", prio, pgid);
+	if (!bnx2x_dcbnl_set_valid(bp) || prio >= DCBX_MAX_NUM_PRI_PG_ENTRIES)
+		return;
+
+	/**
+	 * bw_pct ingnored -	band-width percentage devision between user
+	 *			priorities within the same group is not
+	 *			standard and hence not supported
+	 *
+	 * prio_type igonred -	priority levels within the same group are not
+	 *			standard and hence are not supported. According
+	 *			to the standard pgid 15 is dedicated to strict
+	 *			prioirty traffic (on the port level).
+	 *
+	 * up_map ignored
+	 */
+
+	bp->dcbx_config_params.admin_configuration_ets_pg[prio] = pgid;
+	bp->dcbx_config_params.admin_ets_configuration_tx_enable = 1;
+}
+
+static void bnx2x_dcbnl_set_pg_bwgcfg_tx(struct net_device *netdev,
+					 int pgid, u8 bw_pct)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "pgid[%d] = %d\n", pgid, bw_pct);
+
+	if (!bnx2x_dcbnl_set_valid(bp) || pgid >= DCBX_MAX_NUM_PG_BW_ENTRIES)
+		return;
+
+	bp->dcbx_config_params.admin_configuration_bw_precentage[pgid] = bw_pct;
+	bp->dcbx_config_params.admin_ets_configuration_tx_enable = 1;
+}
+
+static void bnx2x_dcbnl_set_pg_tccfg_rx(struct net_device *netdev, int prio,
+					u8 prio_type, u8 pgid, u8 bw_pct,
+					u8 up_map)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "Nothing to set; No RX support\n");
+}
+
+static void bnx2x_dcbnl_set_pg_bwgcfg_rx(struct net_device *netdev,
+					 int pgid, u8 bw_pct)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "Nothing to set; No RX support\n");
+}
+
+static void bnx2x_dcbnl_get_pg_tccfg_tx(struct net_device *netdev, int prio,
+					u8 *prio_type, u8 *pgid, u8 *bw_pct,
+					u8 *up_map)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "prio = %d\n", prio);
+
+	/**
+	 * bw_pct ingnored -	band-width percentage devision between user
+	 *			priorities within the same group is not
+	 *			standard and hence not supported
+	 *
+	 * prio_type igonred -	priority levels within the same group are not
+	 *			standard and hence are not supported. According
+	 *			to the standard pgid 15 is dedicated to strict
+	 *			prioirty traffic (on the port level).
+	 *
+	 * up_map ignored
+	 */
+	*up_map = *bw_pct = *prio_type = *pgid = 0;
+
+	if (!bp->dcb_state || prio >= DCBX_MAX_NUM_PRI_PG_ENTRIES)
+		return;
+
+	*pgid = DCBX_PRI_PG_GET(bp->dcbx_local_feat.ets.pri_pg_tbl, prio);
+}
+
+static void bnx2x_dcbnl_get_pg_bwgcfg_tx(struct net_device *netdev,
+					 int pgid, u8 *bw_pct)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "pgid = %d\n", pgid);
+
+	*bw_pct = 0;
+
+	if (!bp->dcb_state || pgid >= DCBX_MAX_NUM_PG_BW_ENTRIES)
+		return;
+
+	*bw_pct = DCBX_PG_BW_GET(bp->dcbx_local_feat.ets.pg_bw_tbl, pgid);
+}
+
+static void bnx2x_dcbnl_get_pg_tccfg_rx(struct net_device *netdev, int prio,
+					u8 *prio_type, u8 *pgid, u8 *bw_pct,
+					u8 *up_map)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "Nothing to get; No RX support\n");
+
+	*prio_type = *pgid = *bw_pct = *up_map = 0;
+}
+
+static void bnx2x_dcbnl_get_pg_bwgcfg_rx(struct net_device *netdev,
+					 int pgid, u8 *bw_pct)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "Nothing to get; No RX support\n");
+
+	*bw_pct = 0;
+}
+
+static void bnx2x_dcbnl_set_pfc_cfg(struct net_device *netdev, int prio,
+				    u8 setting)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "prio[%d] = %d\n", prio, setting);
+
+	if (!bnx2x_dcbnl_set_valid(bp) || prio >= MAX_PFC_PRIORITIES)
+		return;
+
+	bp->dcbx_config_params.admin_pfc_bitmap |= ((setting ? 1 : 0) << prio);
+
+	if (setting)
+		bp->dcbx_config_params.admin_pfc_tx_enable = 1;
+}
+
+static void bnx2x_dcbnl_get_pfc_cfg(struct net_device *netdev, int prio,
+				    u8 *setting)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "prio = %d\n", prio);
+
+	*setting = 0;
+
+	if (!bp->dcb_state || prio >= MAX_PFC_PRIORITIES)
+		return;
+
+	*setting = (bp->dcbx_local_feat.pfc.pri_en_bitmap >> prio) & 0x1;
+}
+
+static u8 bnx2x_dcbnl_set_all(struct net_device *netdev)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	int rc = 0;
+
+	DP(NETIF_MSG_LINK, "SET-ALL\n");
+
+	if (!bnx2x_dcbnl_set_valid(bp))
+		return 1;
+
+	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
+		netdev_err(bp->dev, "Handling parity error recovery. "
+				"Try again later\n");
+		return 1;
+	}
+	if (netif_running(bp->dev)) {
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
+	}
+	DP(NETIF_MSG_LINK, "set_dcbx_params done (%d)\n", rc);
+	if (rc)
+		return 1;
+
+	return 0;
+}
+
+static u8 bnx2x_dcbnl_get_cap(struct net_device *netdev, int capid, u8 *cap)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u8 rval = 0;
+
+	if (bp->dcb_state) {
+		switch (capid) {
+		case DCB_CAP_ATTR_PG:
+			*cap = true;
+			break;
+		case DCB_CAP_ATTR_PFC:
+			*cap = true;
+			break;
+		case DCB_CAP_ATTR_UP2TC:
+			*cap = false;
+			break;
+		case DCB_CAP_ATTR_PG_TCS:
+			*cap = 0x80;	/* 8 priorities for PGs */
+			break;
+		case DCB_CAP_ATTR_PFC_TCS:
+			*cap = 0x80;	/* 8 priorities for PFC */
+			break;
+		case DCB_CAP_ATTR_GSP:
+			*cap = true;
+			break;
+		case DCB_CAP_ATTR_BCN:
+			*cap = false;
+			break;
+		case DCB_CAP_ATTR_DCBX:
+			*cap = BNX2X_DCBX_CAPS;
+		default:
+			rval = -EINVAL;
+			break;
+		}
+	} else
+		rval = -EINVAL;
+
+	DP(NETIF_MSG_LINK, "capid %d:%x\n", capid, *cap);
+	return rval;
+}
+
+static u8 bnx2x_dcbnl_get_numtcs(struct net_device *netdev, int tcid, u8 *num)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u8 rval = 0;
+
+	DP(NETIF_MSG_LINK, "tcid %d\n", tcid);
+
+	if (bp->dcb_state) {
+		switch (tcid) {
+		case DCB_NUMTCS_ATTR_PG:
+			*num = E2_NUM_OF_COS;
+			break;
+		case DCB_NUMTCS_ATTR_PFC:
+			*num = E2_NUM_OF_COS;
+			break;
+		default:
+			rval = -EINVAL;
+			break;
+		}
+	} else
+		rval = -EINVAL;
+
+	return rval;
+}
+
+static u8 bnx2x_dcbnl_set_numtcs(struct net_device *netdev, int tcid, u8 num)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "num tcs = %d; Not supported\n", num);
+	return -EINVAL;
+}
+
+static u8  bnx2x_dcbnl_get_pfc_state(struct net_device *netdev)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "state = %d\n", bp->dcbx_local_feat.pfc.enabled);
+
+	if (!bp->dcb_state)
+		return 0;
+
+	return bp->dcbx_local_feat.pfc.enabled;
+}
+
+static void bnx2x_dcbnl_set_pfc_state(struct net_device *netdev, u8 state)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "state = %s\n", state ? "on" : "off");
+
+	if (!bnx2x_dcbnl_set_valid(bp))
+		return;
+
+	bp->dcbx_config_params.admin_pfc_tx_enable =
+	bp->dcbx_config_params.admin_pfc_enable = (state ? 1 : 0);
+}
+
+static bool bnx2x_app_is_equal(struct dcbx_app_priority_entry *app_ent,
+			       u8 idtype, u16 idval)
+{
+	if (!(app_ent->appBitfield & DCBX_APP_ENTRY_VALID))
+		return false;
+
+	switch (idtype) {
+	case DCB_APP_IDTYPE_ETHTYPE:
+		if ((app_ent->appBitfield & DCBX_APP_ENTRY_SF_MASK) !=
+			DCBX_APP_SF_ETH_TYPE)
+			return false;
+		break;
+	case DCB_APP_IDTYPE_PORTNUM:
+		if ((app_ent->appBitfield & DCBX_APP_ENTRY_SF_MASK) !=
+			DCBX_APP_SF_PORT)
+			return false;
+		break;
+	default:
+		return false;
+	}
+	if (app_ent->app_id != idval)
+		return false;
+
+	return true;
+}
+
+static void bnx2x_admin_app_set_ent(
+	struct bnx2x_admin_priority_app_table *app_ent,
+	u8 idtype, u16 idval, u8 up)
+{
+	app_ent->valid = 1;
+
+	switch (idtype) {
+	case DCB_APP_IDTYPE_ETHTYPE:
+		app_ent->traffic_type = TRAFFIC_TYPE_ETH;
+		break;
+	case DCB_APP_IDTYPE_PORTNUM:
+		app_ent->traffic_type = TRAFFIC_TYPE_PORT;
+		break;
+	default:
+		break; /* never gets here */
+	}
+	app_ent->app_id = idval;
+	app_ent->priority = up;
+}
+
+static bool bnx2x_admin_app_is_equal(
+	struct bnx2x_admin_priority_app_table *app_ent,
+	u8 idtype, u16 idval)
+{
+	if (!app_ent->valid)
+		return false;
+
+	switch (idtype) {
+	case DCB_APP_IDTYPE_ETHTYPE:
+		if (app_ent->traffic_type != TRAFFIC_TYPE_ETH)
+			return false;
+		break;
+	case DCB_APP_IDTYPE_PORTNUM:
+		if (app_ent->traffic_type != TRAFFIC_TYPE_PORT)
+			return false;
+		break;
+	default:
+		return false;
+	}
+	if (app_ent->app_id != idval)
+		return false;
+
+	return true;
+}
+
+static int bnx2x_set_admin_app_up(struct bnx2x *bp, u8 idtype, u16 idval, u8 up)
+{
+	int i, ff;
+
+	/* iterate over the app entries looking for idtype and idval */
+	for (i = 0, ff = -1; i < 4; i++) {
+		struct bnx2x_admin_priority_app_table *app_ent =
+			&bp->dcbx_config_params.admin_priority_app_table[i];
+		if (bnx2x_admin_app_is_equal(app_ent, idtype, idval))
+			break;
+
+		if (ff < 0 && !app_ent->valid)
+			ff = i;
+	}
+	if (i < 4)
+		/* if found overwrite up */
+		bp->dcbx_config_params.
+			admin_priority_app_table[i].priority = up;
+	else if (ff >= 0)
+		/* not found use first-free */
+		bnx2x_admin_app_set_ent(
+			&bp->dcbx_config_params.admin_priority_app_table[ff],
+			idtype, idval, up);
+	else
+		/* app table is full */
+		return -EBUSY;
+
+	/* up configured, if not 0 make sure feature is enabled */
+	if (up)
+		bp->dcbx_config_params.admin_application_priority_tx_enable = 1;
+
+	return 0;
+}
+
+static u8 bnx2x_dcbnl_set_app_up(struct net_device *netdev, u8 idtype,
+				 u16 idval, u8 up)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+
+	DP(NETIF_MSG_LINK, "app_type %d, app_id %x, prio bitmap %d\n",
+	   idtype, idval, up);
+
+	if (!bnx2x_dcbnl_set_valid(bp))
+		return -EINVAL;
+
+	/* verify idtype */
+	switch (idtype) {
+	case DCB_APP_IDTYPE_ETHTYPE:
+	case DCB_APP_IDTYPE_PORTNUM:
+		break;
+	default:
+		return -EINVAL;
+	}
+	return bnx2x_set_admin_app_up(bp, idtype, idval, up);
+}
+
+static u8 bnx2x_dcbnl_get_app_up(struct net_device *netdev, u8 idtype,
+				 u16 idval)
+{
+	int i;
+	u8 up = 0;
+
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "app_type %d, app_id 0x%x\n", idtype, idval);
+
+	/* iterate over the app entries looking for idtype and idval */
+	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++)
+		if (bnx2x_app_is_equal(&bp->dcbx_local_feat.app.app_pri_tbl[i],
+				       idtype, idval))
+			break;
+
+	if (i < DCBX_MAX_APP_PROTOCOL)
+		/* if found return up */
+		up = bp->dcbx_local_feat.app.app_pri_tbl[i].pri_bitmap;
+	else
+		DP(NETIF_MSG_LINK, "app not found\n");
+
+	return up;
+}
+
+static u8 bnx2x_dcbnl_get_dcbx(struct net_device *netdev)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u8 state;
+
+	state = DCB_CAP_DCBX_HW | DCB_CAP_DCBX_VER_CEE;
+
+	if (bp->dcbx_enabled == BNX2X_DCBX_ENABLED_ON_NEG_OFF)
+		state |= DCB_CAP_DCBX_STATIC;
+
+	return state;
+}
+
+static u8 bnx2x_dcbnl_set_dcbx(struct net_device *netdev, u8 state)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	DP(NETIF_MSG_LINK, "state = %02x\n", state);
+
+	/* set dcbx mode */
+
+	if ((state & BNX2X_DCBX_CAPS) != state) {
+		BNX2X_ERR("Requested DCBX mode %x is beyond advertised "
+			  "capabilities\n", state);
+		return 1;
+	}
+
+	if (bp->dcb_state != BNX2X_DCB_STATE_ON) {
+		BNX2X_ERR("DCB turned off, DCBX configuration is invalid\n");
+		return 1;
+	}
+
+	if (state & DCB_CAP_DCBX_STATIC)
+		bp->dcbx_enabled = BNX2X_DCBX_ENABLED_ON_NEG_OFF;
+	else
+		bp->dcbx_enabled = BNX2X_DCBX_ENABLED_ON_NEG_ON;
+
+	bp->dcbx_mode_uset = true;
+	return 0;
+}
+
+
+static u8 bnx2x_dcbnl_get_featcfg(struct net_device *netdev, int featid,
+				  u8 *flags)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u8 rval = 0;
+
+	DP(NETIF_MSG_LINK, "featid %d\n", featid);
+
+	if (bp->dcb_state) {
+		*flags = 0;
+		switch (featid) {
+		case DCB_FEATCFG_ATTR_PG:
+			if (bp->dcbx_local_feat.ets.enabled)
+				*flags |= DCB_FEATCFG_ENABLE;
+			if (bp->dcbx_error & DCBX_LOCAL_ETS_ERROR)
+				*flags |= DCB_FEATCFG_ERROR;
+			break;
+		case DCB_FEATCFG_ATTR_PFC:
+			if (bp->dcbx_local_feat.pfc.enabled)
+				*flags |= DCB_FEATCFG_ENABLE;
+			if (bp->dcbx_error & (DCBX_LOCAL_PFC_ERROR |
+			    DCBX_LOCAL_PFC_MISMATCH))
+				*flags |= DCB_FEATCFG_ERROR;
+			break;
+		case DCB_FEATCFG_ATTR_APP:
+			if (bp->dcbx_local_feat.app.enabled)
+				*flags |= DCB_FEATCFG_ENABLE;
+			if (bp->dcbx_error & (DCBX_LOCAL_APP_ERROR |
+			    DCBX_LOCAL_APP_MISMATCH))
+				*flags |= DCB_FEATCFG_ERROR;
+			break;
+		default:
+			rval = -EINVAL;
+			break;
+		}
+	} else
+		rval = -EINVAL;
+
+	return rval;
+}
+
+static u8 bnx2x_dcbnl_set_featcfg(struct net_device *netdev, int featid,
+				  u8 flags)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u8 rval = 0;
+
+	DP(NETIF_MSG_LINK, "featid = %d flags = %02x\n", featid, flags);
+
+	/* ignore the 'advertise' flag */
+	if (bnx2x_dcbnl_set_valid(bp)) {
+		switch (featid) {
+		case DCB_FEATCFG_ATTR_PG:
+			bp->dcbx_config_params.admin_ets_enable =
+				flags & DCB_FEATCFG_ENABLE ? 1 : 0;
+			bp->dcbx_config_params.admin_ets_willing =
+				flags & DCB_FEATCFG_WILLING ? 1 : 0;
+			break;
+		case DCB_FEATCFG_ATTR_PFC:
+			bp->dcbx_config_params.admin_pfc_enable =
+				flags & DCB_FEATCFG_ENABLE ? 1 : 0;
+			bp->dcbx_config_params.admin_pfc_willing =
+				flags & DCB_FEATCFG_WILLING ? 1 : 0;
+			break;
+		case DCB_FEATCFG_ATTR_APP:
+			/* ignore enable, always enabled */
+			bp->dcbx_config_params.admin_app_priority_willing =
+				flags & DCB_FEATCFG_WILLING ? 1 : 0;
+			break;
+		default:
+			rval = -EINVAL;
+			break;
+		}
+	} else
+		rval = -EINVAL;
+
+	return rval;
+}
+
+const struct dcbnl_rtnl_ops bnx2x_dcbnl_ops = {
+	.getstate       = bnx2x_dcbnl_get_state,
+	.setstate       = bnx2x_dcbnl_set_state,
+	.getpermhwaddr  = bnx2x_dcbnl_get_perm_hw_addr,
+	.setpgtccfgtx   = bnx2x_dcbnl_set_pg_tccfg_tx,
+	.setpgbwgcfgtx  = bnx2x_dcbnl_set_pg_bwgcfg_tx,
+	.setpgtccfgrx   = bnx2x_dcbnl_set_pg_tccfg_rx,
+	.setpgbwgcfgrx  = bnx2x_dcbnl_set_pg_bwgcfg_rx,
+	.getpgtccfgtx   = bnx2x_dcbnl_get_pg_tccfg_tx,
+	.getpgbwgcfgtx  = bnx2x_dcbnl_get_pg_bwgcfg_tx,
+	.getpgtccfgrx   = bnx2x_dcbnl_get_pg_tccfg_rx,
+	.getpgbwgcfgrx  = bnx2x_dcbnl_get_pg_bwgcfg_rx,
+	.setpfccfg      = bnx2x_dcbnl_set_pfc_cfg,
+	.getpfccfg      = bnx2x_dcbnl_get_pfc_cfg,
+	.setall         = bnx2x_dcbnl_set_all,
+	.getcap         = bnx2x_dcbnl_get_cap,
+	.getnumtcs      = bnx2x_dcbnl_get_numtcs,
+	.setnumtcs      = bnx2x_dcbnl_set_numtcs,
+	.getpfcstate    = bnx2x_dcbnl_get_pfc_state,
+	.setpfcstate    = bnx2x_dcbnl_set_pfc_state,
+	.getapp         = bnx2x_dcbnl_get_app_up,
+	.setapp         = bnx2x_dcbnl_set_app_up,
+	.getdcbx        = bnx2x_dcbnl_get_dcbx,
+	.setdcbx        = bnx2x_dcbnl_set_dcbx,
+	.getfeatcfg     = bnx2x_dcbnl_get_featcfg,
+	.setfeatcfg     = bnx2x_dcbnl_set_featcfg,
+};
+
+#endif /* BCM_DCB */
diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/bnx2x/bnx2x_dcb.h
index 8dea56b..f650f98 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/bnx2x/bnx2x_dcb.h
@@ -51,7 +51,6 @@ struct bnx2x_dcbx_pfc_params {
 };
 
 struct bnx2x_dcbx_port_params {
-	u32 dcbx_enabled;
 	struct bnx2x_dcbx_pfc_params pfc;
 	struct bnx2x_dcbx_pg_params  ets;
 	struct bnx2x_dcbx_app_params app;
@@ -88,8 +87,6 @@ struct bnx2x_admin_priority_app_table {
  * DCBX protocol configuration parameters.
  ******************************************************************************/
 struct bnx2x_config_dcbx_params {
-	u32 dcb_enable;
-	u32 admin_dcbx_enable;
 	u32 overwrite_settings;
 	u32 admin_dcbx_version;
 	u32 admin_ets_enable;
@@ -182,6 +179,7 @@ struct bnx2x;
 void bnx2x_dcb_init_intmem_pfc(struct bnx2x *bp);
 void bnx2x_dcbx_update(struct work_struct *work);
 void bnx2x_dcbx_init_params(struct bnx2x *bp);
+void bnx2x_dcbx_set_state(struct bnx2x *bp, bool dcb_on, u32 dcbx_enabled);
 
 enum {
 	BNX2X_DCBX_STATE_NEG_RECEIVED = 0x1,
@@ -190,4 +188,9 @@ enum {
 };
 void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state);
 
+/* DCB netlink */
+#ifdef BCM_DCB
+extern const struct dcbnl_rtnl_ops bnx2x_dcbnl_ops;
+#endif /* BCM_DCB */
+
 #endif /* BNX2X_DCB_H */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index bdc3fc2..c49f26c 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -3107,7 +3107,8 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 				bnx2x_pmf_update(bp);
 
 			if (bp->port.pmf &&
-			    (val & DRV_STATUS_DCBX_NEGOTIATION_RESULTS))
+			    (val & DRV_STATUS_DCBX_NEGOTIATION_RESULTS) &&
+				bp->dcbx_enabled > 0)
 				/* start dcbx state machine */
 				bnx2x_dcbx_set_params(bp,
 					BNX2X_DCBX_STATE_NEG_RECEIVED);
@@ -8793,6 +8794,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->timer.data = (unsigned long) bp;
 	bp->timer.function = bnx2x_timer;
 
+	bnx2x_dcbx_set_state(bp, true, BNX2X_DCBX_ENABLED_ON_NEG_ON);
 	bnx2x_dcbx_init_params(bp);
 
 	return rc;
@@ -9144,6 +9146,10 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 	dev->vlan_features |= NETIF_F_TSO6;
 
+#ifdef BCM_DCB
+	dev->dcbnl_ops = &bnx2x_dcbnl_ops;
+#endif
+
 	/* get_port_hwinfo() will set prtad and mmds properly */
 	bp->mdio.prtad = MDIO_PRTAD_NONE;
 	bp->mdio.mmds = 0;
-- 
1.7.1




