From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next 3/8] bnx2x: add DCB support
Date: Thu, 9 Dec 2010 14:10:28 +0200
Message-ID: <1291896628.8745.9.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, shmulikr@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1371 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755305Ab0LIMVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 07:21:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Adding DCB initialization and handling on 57712 FW/HW

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Shmulik Ravid-Rabinovitz <shmulikr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/Makefile     |    2 +-
 drivers/net/bnx2x/bnx2x.h      |   15 +
 drivers/net/bnx2x/bnx2x_cmn.c  |    2 +
 drivers/net/bnx2x/bnx2x_cmn.h  |    7 +
 drivers/net/bnx2x/bnx2x_dcb.c  | 1491 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_dcb.h  |  193 ++++++
 drivers/net/bnx2x/bnx2x_hsi.h  |  281 ++++++++-
 drivers/net/bnx2x/bnx2x_link.h |   40 ++
 drivers/net/bnx2x/bnx2x_main.c |   24 +-
 9 files changed, 2050 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/bnx2x/bnx2x_dcb.c
 create mode 100644 drivers/net/bnx2x/bnx2x_dcb.h

diff --git a/drivers/net/bnx2x/Makefile b/drivers/net/bnx2x/Makefile
index 084afce..bb83a29 100644
--- a/drivers/net/bnx2x/Makefile
+++ b/drivers/net/bnx2x/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_BNX2X) += bnx2x.o
 
-bnx2x-objs := bnx2x_main.o bnx2x_link.o bnx2x_cmn.o bnx2x_ethtool.o bnx2x_stats.o
+bnx2x-objs := bnx2x_main.o bnx2x_link.o bnx2x_cmn.o bnx2x_ethtool.o bnx2x_stats.o bnx2x_dcb.o
diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 34d84de..26c2315 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -50,6 +50,7 @@
 #include "bnx2x_fw_defs.h"
 #include "bnx2x_hsi.h"
 #include "bnx2x_link.h"
+#include "bnx2x_dcb.h"
 #include "bnx2x_stats.h"
 
 /* error/debug prints */
@@ -820,6 +821,8 @@ struct bnx2x_slowpath {
 
 	u32				wb_comp;
 	u32				wb_data[4];
+	/* pfc configuration for DCBX ramrod */
+	struct flow_control_configuration pfc_config;
 };
 
 #define bnx2x_sp(bp, var)		(&bp->slowpath->var)
@@ -1180,6 +1183,18 @@ struct bnx2x {
 
 	char			fw_ver[32];
 	const struct firmware	*firmware;
+	/* LLDP params */
+	struct bnx2x_config_lldp_params		lldp_config_params;
+
+	/* DCBX params */
+	struct bnx2x_config_dcbx_params		dcbx_config_params;
+
+	struct bnx2x_dcbx_port_params		dcbx_port_params;
+	int					dcb_version;
+
+	/* DCBX Negotation results */
+	struct dcbx_features			dcbx_local_feat;
+	u32					dcbx_error;
 };
 
 /**
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 862b29e..3330869 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1373,6 +1373,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 	}
 
+	bnx2x_dcbx_init(bp);
+
 	bp->state = BNX2X_STATE_OPENING_WAIT4_PORT;
 
 	rc = bnx2x_func_start(bp);
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 258f0c0..03eb4d6 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -324,6 +324,13 @@ int bnx2x_func_start(struct bnx2x *bp);
 void bnx2x_ilt_set_info(struct bnx2x *bp);
 
 /**
+ * Inintialize dcbx protocol
+ *
+ * @param bp
+ */
+void bnx2x_dcbx_init(struct bnx2x *bp);
+
+/**
  * Set power state to the requested value. Currently only D0 and
  * D3hot are supported.
  *
diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
new file mode 100644
index 0000000..0b86480
--- /dev/null
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -0,0 +1,1491 @@
+/* bnx2x_dcb.c: Broadcom Everest network driver.
+ *
+ * Copyright 2009-2010 Broadcom Corporation
+ *
+ * Unless you and Broadcom execute a separate written software license
+ * agreement governing use of this software, this software is licensed to you
+ * under the terms of the GNU General Public License version 2, available
+ * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL").
+ *
+ * Notwithstanding the above, under no circumstances may you combine this
+ * software in any way with any other Broadcom software provided under a
+ * license other than the GPL, without Broadcom's express prior written
+ * consent.
+ *
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Dmitry Kravkov
+ *
+ */
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+
+#include "bnx2x.h"
+#include "bnx2x_cmn.h"
+#include "bnx2x_dcb.h"
+
+
+/* forward declarations of dcbx related functions */
+static void bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp);
+static void bnx2x_pfc_set_pfc(struct bnx2x *bp);
+static void bnx2x_dcbx_update_ets_params(struct bnx2x *bp);
+static void bnx2x_dcbx_resume_hw_tx(struct bnx2x *bp);
+static void bnx2x_dcbx_get_ets_pri_pg_tbl(struct bnx2x *bp,
+					  u32 *set_configuration_ets_pg,
+					  u32 *pri_pg_tbl);
+static void bnx2x_dcbx_get_num_pg_traf_type(struct bnx2x *bp,
+					    u32 *pg_pri_orginal_spread,
+					    struct pg_help_data *help_data);
+static void bnx2x_dcbx_fill_cos_params(struct bnx2x *bp,
+				       struct pg_help_data *help_data,
+				       struct dcbx_ets_feature *ets,
+				       u32 *pg_pri_orginal_spread);
+static void bnx2x_dcbx_separate_pauseable_from_non(struct bnx2x *bp,
+				struct cos_help_data *cos_data,
+				u32 *pg_pri_orginal_spread,
+				struct dcbx_ets_feature *ets);
+static void bnx2x_pfc_fw_struct_e2(struct bnx2x *bp);
+
+
+static void bnx2x_pfc_set(struct bnx2x *bp)
+{
+	struct bnx2x_nig_brb_pfc_port_params pfc_params = {0};
+	u32 pri_bit, val = 0;
+	u8 pri;
+
+	/* Tx COS configuration */
+	if (bp->dcbx_port_params.ets.cos_params[0].pauseable)
+		pfc_params.rx_cos0_priority_mask =
+			bp->dcbx_port_params.ets.cos_params[0].pri_bitmask;
+	if (bp->dcbx_port_params.ets.cos_params[1].pauseable)
+		pfc_params.rx_cos1_priority_mask =
+			bp->dcbx_port_params.ets.cos_params[1].pri_bitmask;
+
+
+	/**
+	 * Rx COS configuration
+	 * Changing PFC RX configuration .
+	 * In RX COS0 will always be configured to lossy and COS1 to lossless
+	 */
+	for (pri = 0 ; pri < MAX_PFC_PRIORITIES ; pri++) {
+		pri_bit = 1 << pri;
+
+		if (pri_bit & DCBX_PFC_PRI_PAUSE_MASK(bp))
+			val |= 1 << (pri * 4);
+	}
+
+	pfc_params.pkt_priority_to_cos = val;
+
+	/* RX COS0 */
+	pfc_params.llfc_low_priority_classes = 0;
+	/* RX COS1 */
+	pfc_params.llfc_high_priority_classes = DCBX_PFC_PRI_PAUSE_MASK(bp);
+
+	/* BRB configuration */
+	pfc_params.cos0_pauseable = false;
+	pfc_params.cos1_pauseable = true;
+
+	bnx2x_acquire_phy_lock(bp);
+	bp->link_params.feature_config_flags |= FEATURE_CONFIG_PFC_ENABLED;
+	bnx2x_update_pfc(&bp->link_params, &bp->link_vars, &pfc_params);
+	bnx2x_release_phy_lock(bp);
+}
+
+static void bnx2x_pfc_clear(struct bnx2x *bp)
+{
+	struct bnx2x_nig_brb_pfc_port_params nig_params = {0};
+	nig_params.pause_enable = 1;
+#ifdef BNX2X_SAFC
+	if (bp->flags & SAFC_TX_FLAG) {
+		u32 high = 0, low = 0;
+		int i;
+
+		for (i = 0; i < BNX2X_MAX_PRIORITY; i++) {
+			if (bp->pri_map[i] == 1)
+				high |= (1 << i);
+			if (bp->pri_map[i] == 0)
+				low |= (1 << i);
+		}
+
+		nig_params.llfc_low_priority_classes = high;
+		nig_params.llfc_low_priority_classes = low;
+
+		nig_params.pause_enable = 0;
+		nig_params.llfc_enable = 1;
+		nig_params.llfc_out_en = 1;
+	}
+#endif /* BNX2X_SAFC */
+	bnx2x_acquire_phy_lock(bp);
+	bp->link_params.feature_config_flags &= ~FEATURE_CONFIG_PFC_ENABLED;
+	bnx2x_update_pfc(&bp->link_params, &bp->link_vars, &nig_params);
+	bnx2x_release_phy_lock(bp);
+}
+
+static void  bnx2x_dump_dcbx_drv_param(struct bnx2x *bp,
+				       struct dcbx_features *features,
+				       u32 error)
+{
+	u8 i = 0;
+	DP(NETIF_MSG_LINK, "local_mib.error %x\n", error);
+
+	/* PG */
+	DP(NETIF_MSG_LINK,
+	   "local_mib.features.ets.enabled %x\n", features->ets.enabled);
+	for (i = 0; i < DCBX_MAX_NUM_PG_BW_ENTRIES; i++)
+		DP(NETIF_MSG_LINK,
+		   "local_mib.features.ets.pg_bw_tbl[%d] %d\n", i,
+		   DCBX_PG_BW_GET(features->ets.pg_bw_tbl, i));
+	for (i = 0; i < DCBX_MAX_NUM_PRI_PG_ENTRIES; i++)
+		DP(NETIF_MSG_LINK,
+		   "local_mib.features.ets.pri_pg_tbl[%d] %d\n", i,
+		   DCBX_PRI_PG_GET(features->ets.pri_pg_tbl, i));
+
+	/* pfc */
+	DP(NETIF_MSG_LINK, "dcbx_features.pfc.pri_en_bitmap %x\n",
+					features->pfc.pri_en_bitmap);
+	DP(NETIF_MSG_LINK, "dcbx_features.pfc.pfc_caps %x\n",
+					features->pfc.pfc_caps);
+	DP(NETIF_MSG_LINK, "dcbx_features.pfc.enabled %x\n",
+					features->pfc.enabled);
+
+	DP(NETIF_MSG_LINK, "dcbx_features.app.default_pri %x\n",
+					features->app.default_pri);
+	DP(NETIF_MSG_LINK, "dcbx_features.app.tc_supported %x\n",
+					features->app.tc_supported);
+	DP(NETIF_MSG_LINK, "dcbx_features.app.enabled %x\n",
+					features->app.enabled);
+	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
+		DP(NETIF_MSG_LINK,
+		   "dcbx_features.app.app_pri_tbl[%x].app_id %x\n",
+		   i, features->app.app_pri_tbl[i].app_id);
+		DP(NETIF_MSG_LINK,
+		   "dcbx_features.app.app_pri_tbl[%x].pri_bitmap %x\n",
+		   i, features->app.app_pri_tbl[i].pri_bitmap);
+		DP(NETIF_MSG_LINK,
+		   "dcbx_features.app.app_pri_tbl[%x].appBitfield %x\n",
+		   i, features->app.app_pri_tbl[i].appBitfield);
+	}
+}
+
+static void bnx2x_dcbx_get_ap_priority(struct bnx2x *bp,
+				       u8 pri_bitmap,
+				       u8 llfc_traf_type)
+{
+	u32 pri = MAX_PFC_PRIORITIES;
+	u32 index = MAX_PFC_PRIORITIES - 1;
+	u32 pri_mask;
+	u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
+
+	/* Choose the highest priority */
+	while ((MAX_PFC_PRIORITIES == pri) && (0 != index)) {
+		pri_mask = 1 << index;
+		if (GET_FLAGS(pri_bitmap, pri_mask))
+			pri = index ;
+		index--;
+	}
+
+	if (pri < MAX_PFC_PRIORITIES)
+		ttp[llfc_traf_type] = max_t(u32, ttp[llfc_traf_type], pri);
+}
+
+static void bnx2x_dcbx_get_ap_feature(struct bnx2x *bp,
+				   struct dcbx_app_priority_feature *app,
+				   u32 error) {
+	u8 index;
+	u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
+
+	if (GET_FLAGS(error, DCBX_LOCAL_APP_ERROR))
+		DP(NETIF_MSG_LINK, "DCBX_LOCAL_APP_ERROR\n");
+
+	if (app->enabled && !GET_FLAGS(error, DCBX_LOCAL_APP_ERROR)) {
+
+		bp->dcbx_port_params.app.enabled = true;
+
+		for (index = 0 ; index < LLFC_DRIVER_TRAFFIC_TYPE_MAX; index++)
+			ttp[index] = 0;
+
+		if (app->default_pri < MAX_PFC_PRIORITIES)
+			ttp[LLFC_TRAFFIC_TYPE_NW] = app->default_pri;
+
+		for (index = 0 ; index < DCBX_MAX_APP_PROTOCOL; index++) {
+			struct dcbx_app_priority_entry *entry =
+							app->app_pri_tbl;
+
+			if (GET_FLAGS(entry[index].appBitfield,
+				     DCBX_APP_SF_ETH_TYPE) &&
+			   ETH_TYPE_FCOE == entry[index].app_id)
+				bnx2x_dcbx_get_ap_priority(bp,
+						entry[index].pri_bitmap,
+						LLFC_TRAFFIC_TYPE_FCOE);
+
+			if (GET_FLAGS(entry[index].appBitfield,
+				     DCBX_APP_SF_PORT) &&
+			   TCP_PORT_ISCSI == entry[index].app_id)
+				bnx2x_dcbx_get_ap_priority(bp,
+						entry[index].pri_bitmap,
+						LLFC_TRAFFIC_TYPE_ISCSI);
+		}
+	} else {
+		DP(NETIF_MSG_LINK, "DCBX_LOCAL_APP_DISABLED\n");
+		bp->dcbx_port_params.app.enabled = false;
+		for (index = 0 ; index < LLFC_DRIVER_TRAFFIC_TYPE_MAX; index++)
+			ttp[index] = INVALID_TRAFFIC_TYPE_PRIORITY;
+	}
+}
+
+static void bnx2x_dcbx_get_ets_feature(struct bnx2x *bp,
+				       struct dcbx_ets_feature *ets,
+				       u32 error) {
+	int i = 0;
+	u32 pg_pri_orginal_spread[DCBX_MAX_NUM_PG_BW_ENTRIES] = {0};
+	struct pg_help_data pg_help_data;
+	struct bnx2x_dcbx_cos_params *cos_params =
+			bp->dcbx_port_params.ets.cos_params;
+
+	memset(&pg_help_data, 0, sizeof(struct pg_help_data));
+
+
+	if (GET_FLAGS(error, DCBX_LOCAL_ETS_ERROR))
+		DP(NETIF_MSG_LINK, "DCBX_LOCAL_ETS_ERROR\n");
+
+
+	/* Clean up old settings of ets on COS */
+	for (i = 0; i < E2_NUM_OF_COS ; i++) {
+
+		cos_params[i].pauseable = false;
+		cos_params[i].strict = BNX2X_DCBX_COS_NOT_STRICT;
+		cos_params[i].bw_tbl = DCBX_INVALID_COS_BW;
+		cos_params[i].pri_bitmask = DCBX_PFC_PRI_GET_NON_PAUSE(bp, 0);
+	}
+
+	if (bp->dcbx_port_params.app.enabled &&
+	   !GET_FLAGS(error, DCBX_LOCAL_ETS_ERROR) &&
+	   ets->enabled) {
+		DP(NETIF_MSG_LINK, "DCBX_LOCAL_ETS_ENABLE\n");
+		bp->dcbx_port_params.ets.enabled = true;
+
+		bnx2x_dcbx_get_ets_pri_pg_tbl(bp,
+					      pg_pri_orginal_spread,
+					      ets->pri_pg_tbl);
+
+		bnx2x_dcbx_get_num_pg_traf_type(bp,
+						pg_pri_orginal_spread,
+						&pg_help_data);
+
+		bnx2x_dcbx_fill_cos_params(bp, &pg_help_data,
+					   ets, pg_pri_orginal_spread);
+
+	} else {
+		DP(NETIF_MSG_LINK, "DCBX_LOCAL_ETS_DISABLED\n");
+		bp->dcbx_port_params.ets.enabled = false;
+		ets->pri_pg_tbl[0] = 0;
+
+		for (i = 0; i < DCBX_MAX_NUM_PRI_PG_ENTRIES ; i++)
+			DCBX_PG_BW_SET(ets->pg_bw_tbl, i, 1);
+	}
+}
+
+static void  bnx2x_dcbx_get_pfc_feature(struct bnx2x *bp,
+					struct dcbx_pfc_feature *pfc, u32 error)
+{
+
+	if (GET_FLAGS(error, DCBX_LOCAL_PFC_ERROR))
+		DP(NETIF_MSG_LINK, "DCBX_LOCAL_PFC_ERROR\n");
+
+	if (bp->dcbx_port_params.app.enabled &&
+	   !GET_FLAGS(error, DCBX_LOCAL_PFC_ERROR) &&
+	   pfc->enabled) {
+		bp->dcbx_port_params.pfc.enabled = true;
+		bp->dcbx_port_params.pfc.priority_non_pauseable_mask =
+			~(pfc->pri_en_bitmap);
+	} else {
+		DP(NETIF_MSG_LINK, "DCBX_LOCAL_PFC_DISABLED\n");
+		bp->dcbx_port_params.pfc.enabled = false;
+		bp->dcbx_port_params.pfc.priority_non_pauseable_mask = 0;
+	}
+}
+
+static void bnx2x_get_dcbx_drv_param(struct bnx2x *bp,
+				     struct dcbx_features *features,
+				     u32 error)
+{
+	bnx2x_dcbx_get_ap_feature(bp, &features->app, error);
+
+	bnx2x_dcbx_get_pfc_feature(bp, &features->pfc, error);
+
+	bnx2x_dcbx_get_ets_feature(bp, &features->ets, error);
+}
+
+#define DCBX_LOCAL_MIB_MAX_TRY_READ		(100)
+static int bnx2x_dcbx_read_mib(struct bnx2x *bp,
+			       u32 *base_mib_addr,
+			       u32 offset,
+			       int read_mib_type)
+{
+	int max_try_read = 0, i;
+	u32 *buff, mib_size, prefix_seq_num, suffix_seq_num;
+	struct lldp_remote_mib *remote_mib ;
+	struct lldp_local_mib  *local_mib;
+
+
+	switch (read_mib_type) {
+	case DCBX_READ_LOCAL_MIB:
+		mib_size = sizeof(struct lldp_local_mib);
+		break;
+	case DCBX_READ_REMOTE_MIB:
+		mib_size = sizeof(struct lldp_remote_mib);
+		break;
+	default:
+		return 1; /*error*/
+	}
+
+	offset += BP_PORT(bp) * mib_size;
+
+	do {
+		buff = base_mib_addr;
+		for (i = 0; i < mib_size; i += 4, buff++)
+			*buff = REG_RD(bp, offset + i);
+
+		max_try_read++;
+
+		switch (read_mib_type) {
+		case DCBX_READ_LOCAL_MIB:
+			local_mib = (struct lldp_local_mib *) base_mib_addr;
+			prefix_seq_num = local_mib->prefix_seq_num;
+			suffix_seq_num = local_mib->suffix_seq_num;
+			break;
+		case DCBX_READ_REMOTE_MIB:
+			remote_mib = (struct lldp_remote_mib *) base_mib_addr;
+			prefix_seq_num = remote_mib->prefix_seq_num;
+			suffix_seq_num = remote_mib->suffix_seq_num;
+			break;
+		default:
+			return 1; /*error*/
+		}
+	} while ((prefix_seq_num != suffix_seq_num) &&
+	       (max_try_read < DCBX_LOCAL_MIB_MAX_TRY_READ));
+
+	if (max_try_read >= DCBX_LOCAL_MIB_MAX_TRY_READ) {
+		BNX2X_ERR("MIB could not be read\n");
+		return 1;
+	}
+
+	return 0;
+}
+
+static void bnx2x_pfc_set_pfc(struct bnx2x *bp)
+{
+	if (CHIP_IS_E2(bp)) {
+		if (BP_PORT(bp)) {
+			BNX2X_ERR("4 port mode is not supported");
+			return;
+		}
+
+		if (bp->dcbx_port_params.pfc.enabled)
+
+			/* 1. Fills up common PFC structures if required.*/
+			/* 2. Configure NIG, MAC and BRB via the elink:
+			 *    elink must first check if BMAC is not in reset
+			 *    and only then configures the BMAC
+			 *    Or, configure EMAC.
+			 */
+			bnx2x_pfc_set(bp);
+
+		else
+			bnx2x_pfc_clear(bp);
+	}
+}
+
+static void bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp)
+{
+	DP(NETIF_MSG_LINK, "sending STOP TRAFFIC\n");
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_STOP_TRAFFIC,
+		      0 /* connectionless */,
+		      0 /* dataHi is zero */,
+		      0 /* dataLo is zero */,
+		      1 /* common */);
+}
+
+static void bnx2x_dcbx_resume_hw_tx(struct bnx2x *bp)
+{
+	bnx2x_pfc_fw_struct_e2(bp);
+	DP(NETIF_MSG_LINK, "sending START TRAFFIC\n");
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_START_TRAFFIC,
+		      0, /* connectionless */
+		      U64_HI(bnx2x_sp_mapping(bp, pfc_config)),
+		      U64_LO(bnx2x_sp_mapping(bp, pfc_config)),
+		      1  /* commmon */);
+}
+
+static void bnx2x_dcbx_update_ets_params(struct bnx2x *bp)
+{
+	struct bnx2x_dcbx_pg_params *ets = &(bp->dcbx_port_params.ets);
+	u8	status = 0;
+
+	bnx2x_ets_disabled(&bp->link_params);
+
+	if (!ets->enabled)
+		return;
+
+	if ((ets->num_of_cos == 0) || (ets->num_of_cos > E2_NUM_OF_COS)) {
+		BNX2X_ERR("illegal num of cos= %x", ets->num_of_cos);
+		return;
+	}
+
+	/* valid COS entries */
+	if (ets->num_of_cos == 1)   /* no ETS */
+		return;
+
+	/* sanity */
+	if (((BNX2X_DCBX_COS_NOT_STRICT == ets->cos_params[0].strict) &&
+	     (DCBX_INVALID_COS_BW == ets->cos_params[0].bw_tbl)) ||
+	    ((BNX2X_DCBX_COS_NOT_STRICT == ets->cos_params[1].strict) &&
+	     (DCBX_INVALID_COS_BW == ets->cos_params[1].bw_tbl))) {
+		BNX2X_ERR("all COS should have at least bw_limit or strict"
+			    "ets->cos_params[0].strict= %x"
+			    "ets->cos_params[0].bw_tbl= %x"
+			    "ets->cos_params[1].strict= %x"
+			    "ets->cos_params[1].bw_tbl= %x",
+			  ets->cos_params[0].strict,
+			  ets->cos_params[0].bw_tbl,
+			  ets->cos_params[1].strict,
+			  ets->cos_params[1].bw_tbl);
+		return;
+	}
+	/* If we join a group and there is bw_tbl and strict then bw rules */
+	if ((DCBX_INVALID_COS_BW != ets->cos_params[0].bw_tbl) &&
+	    (DCBX_INVALID_COS_BW != ets->cos_params[1].bw_tbl)) {
+		u32 bw_tbl_0 = ets->cos_params[0].bw_tbl;
+		u32 bw_tbl_1 = ets->cos_params[1].bw_tbl;
+		/* Do not allow 0-100 configuration
+		 * since PBF does not support it
+		 * force 1-99 instead
+		 */
+		if (bw_tbl_0 == 0) {
+			bw_tbl_0 = 1;
+			bw_tbl_1 = 99;
+		} else if (bw_tbl_1 == 0) {
+			bw_tbl_1 = 1;
+			bw_tbl_0 = 99;
+		}
+
+		bnx2x_ets_bw_limit(&bp->link_params, bw_tbl_0, bw_tbl_1);
+	} else {
+		if (ets->cos_params[0].strict == BNX2X_DCBX_COS_HIGH_STRICT)
+			status = bnx2x_ets_strict(&bp->link_params, 0);
+		else if (ets->cos_params[1].strict
+						== BNX2X_DCBX_COS_HIGH_STRICT)
+			status = bnx2x_ets_strict(&bp->link_params, 1);
+
+		if (status)
+			BNX2X_ERR("update_ets_params failed\n");
+	}
+}
+
+static int bnx2x_dcbx_read_shmem_neg_results(struct bnx2x *bp)
+{
+	struct lldp_local_mib local_mib = {0};
+	u32 dcbx_neg_res_offset = SHMEM2_RD(bp, dcbx_neg_res_offset);
+	int rc;
+
+	DP(NETIF_MSG_LINK, "dcbx_neg_res_offset 0x%x\n", dcbx_neg_res_offset);
+
+	if (SHMEM_DCBX_NEG_RES_NONE == dcbx_neg_res_offset) {
+		BNX2X_ERR("FW doesn't support dcbx_neg_res_offset\n");
+		return -EINVAL;
+	}
+	rc = bnx2x_dcbx_read_mib(bp, (u32 *)&local_mib, dcbx_neg_res_offset,
+				 DCBX_READ_LOCAL_MIB);
+
+	if (rc) {
+		BNX2X_ERR("Faild to read local mib from FW\n");
+		return rc;
+	}
+
+	/* save features and error */
+	bp->dcbx_local_feat = local_mib.features;
+	bp->dcbx_error = local_mib.error;
+	return 0;
+}
+
+void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
+{
+	switch (state) {
+	case BNX2X_DCBX_STATE_NEG_RECEIVED:
+		{
+			DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_NEG_RECEIVED\n");
+
+			/* Read neg results if dcbx is in the FW */
+			if (bnx2x_dcbx_read_shmem_neg_results(bp))
+				return;
+
+			bnx2x_dump_dcbx_drv_param(bp, &bp->dcbx_local_feat,
+						  bp->dcbx_error);
+
+			bnx2x_get_dcbx_drv_param(bp, &bp->dcbx_local_feat,
+						 bp->dcbx_error);
+
+			if (bp->state != BNX2X_STATE_OPENING_WAIT4_LOAD) {
+				bnx2x_dcbx_stop_hw_tx(bp);
+				return;
+			}
+			/* fall through */
+		}
+	case BNX2X_DCBX_STATE_TX_PAUSED:
+		DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_TX_PAUSED\n");
+		bnx2x_pfc_set_pfc(bp);
+
+		bnx2x_dcbx_update_ets_params(bp);
+		if (bp->state != BNX2X_STATE_OPENING_WAIT4_LOAD) {
+			bnx2x_dcbx_resume_hw_tx(bp);
+			return;
+		}
+		/* fall through */
+	case BNX2X_DCBX_STATE_TX_RELEASED:
+		DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_TX_RELEASED\n");
+		if (bp->state != BNX2X_STATE_OPENING_WAIT4_LOAD)
+			bnx2x_fw_command(bp, DRV_MSG_CODE_DCBX_PMF_DRV_OK, 0);
+
+		return;
+	default:
+		BNX2X_ERR("Unknown DCBX_STATE\n");
+	}
+}
+
+
+#define LLDP_STATS_OFFSET(bp)		(BP_PORT(bp)*\
+					sizeof(struct lldp_dcbx_stat))
+
+/* calculate struct offset in array according to chip information */
+#define LLDP_PARAMS_OFFSET(bp)		(BP_PORT(bp)*sizeof(struct lldp_params))
+
+#define LLDP_ADMIN_MIB_OFFSET(bp)	(PORT_MAX*sizeof(struct lldp_params) + \
+				      BP_PORT(bp)*sizeof(struct lldp_admin_mib))
+
+static void bnx2x_dcbx_lldp_updated_params(struct bnx2x *bp,
+					   u32 dcbx_lldp_params_offset)
+{
+	struct lldp_params lldp_params = {0};
+	u32 i = 0, *buff = NULL;
+	u32 offset = dcbx_lldp_params_offset + LLDP_PARAMS_OFFSET(bp);
+
+	DP(NETIF_MSG_LINK, "lldp_offset 0x%x\n", offset);
+
+	if ((bp->lldp_config_params.overwrite_settings ==
+				BNX2X_DCBX_OVERWRITE_SETTINGS_ENABLE)) {
+		/* Read the data first */
+		buff = (u32 *)&lldp_params;
+		for (i = 0; i < sizeof(struct lldp_params); i += 4,  buff++)
+			*buff = REG_RD(bp, (offset + i));
+
+		lldp_params.msg_tx_hold =
+			(u8)bp->lldp_config_params.msg_tx_hold;
+		lldp_params.msg_fast_tx_interval =
+			(u8)bp->lldp_config_params.msg_fast_tx;
+		lldp_params.tx_crd_max =
+			(u8)bp->lldp_config_params.tx_credit_max;
+		lldp_params.msg_tx_interval =
+			(u8)bp->lldp_config_params.msg_tx_interval;
+		lldp_params.tx_fast =
+			(u8)bp->lldp_config_params.tx_fast;
+
+		/* Write the data.*/
+		buff = (u32 *)&lldp_params;
+		for (i = 0; i < sizeof(struct lldp_params); i += 4, buff++)
+			REG_WR(bp, (offset + i) , *buff);
+
+
+	} else if (BNX2X_DCBX_OVERWRITE_SETTINGS_ENABLE ==
+				bp->lldp_config_params.overwrite_settings)
+		bp->lldp_config_params.overwrite_settings =
+				BNX2X_DCBX_OVERWRITE_SETTINGS_INVALID;
+}
+
+static void bnx2x_dcbx_admin_mib_updated_params(struct bnx2x *bp,
+				u32 dcbx_lldp_params_offset)
+{
+	struct lldp_admin_mib admin_mib;
+	u32 i, other_traf_type = PREDEFINED_APP_IDX_MAX, traf_type = 0;
+	u32 *buff;
+	u32 offset = dcbx_lldp_params_offset + LLDP_ADMIN_MIB_OFFSET(bp);
+
+	/*shortcuts*/
+	struct dcbx_features *af = &admin_mib.features;
+	struct bnx2x_config_dcbx_params *dp = &bp->dcbx_config_params;
+
+	memset(&admin_mib, 0, sizeof(struct lldp_admin_mib));
+	buff = (u32 *)&admin_mib;
+	/* Read the data first */
+	for (i = 0; i < sizeof(struct lldp_admin_mib); i += 4, buff++)
+		*buff = REG_RD(bp, (offset + i));
+
+
+	if (BNX2X_DCBX_CONFIG_INV_VALUE != dp->admin_dcbx_enable) {
+		if (dp->admin_dcbx_enable)
+			SET_FLAGS(admin_mib.ver_cfg_flags, DCBX_DCBX_ENABLED);
+		else
+			RESET_FLAGS(admin_mib.ver_cfg_flags, DCBX_DCBX_ENABLED);
+	}
+
+	if ((BNX2X_DCBX_OVERWRITE_SETTINGS_ENABLE ==
+				dp->overwrite_settings)) {
+		RESET_FLAGS(admin_mib.ver_cfg_flags, DCBX_CEE_VERSION_MASK);
+		admin_mib.ver_cfg_flags |=
+			(dp->admin_dcbx_version << DCBX_CEE_VERSION_SHIFT) &
+			 DCBX_CEE_VERSION_MASK;
+
+		af->ets.enabled = (u8)dp->admin_ets_enable;
+
+		af->pfc.enabled = (u8)dp->admin_pfc_enable;
+
+		/* FOR IEEE dp->admin_tc_supported_tx_enable */
+		if (dp->admin_ets_configuration_tx_enable)
+			SET_FLAGS(admin_mib.ver_cfg_flags,
+				  DCBX_ETS_CONFIG_TX_ENABLED);
+		else
+			RESET_FLAGS(admin_mib.ver_cfg_flags,
+				    DCBX_ETS_CONFIG_TX_ENABLED);
+		/* For IEEE admin_ets_recommendation_tx_enable */
+		if (dp->admin_pfc_tx_enable)
+			SET_FLAGS(admin_mib.ver_cfg_flags,
+				  DCBX_PFC_CONFIG_TX_ENABLED);
+		else
+			RESET_FLAGS(admin_mib.ver_cfg_flags,
+				  DCBX_PFC_CONFIG_TX_ENABLED);
+
+		if (dp->admin_application_priority_tx_enable)
+			SET_FLAGS(admin_mib.ver_cfg_flags,
+				  DCBX_APP_CONFIG_TX_ENABLED);
+		else
+			RESET_FLAGS(admin_mib.ver_cfg_flags,
+				  DCBX_APP_CONFIG_TX_ENABLED);
+
+		if (dp->admin_ets_willing)
+			SET_FLAGS(admin_mib.ver_cfg_flags, DCBX_ETS_WILLING);
+		else
+			RESET_FLAGS(admin_mib.ver_cfg_flags, DCBX_ETS_WILLING);
+		/* For IEEE admin_ets_reco_valid */
+		if (dp->admin_pfc_willing)
+			SET_FLAGS(admin_mib.ver_cfg_flags, DCBX_PFC_WILLING);
+		else
+			RESET_FLAGS(admin_mib.ver_cfg_flags, DCBX_PFC_WILLING);
+
+		if (dp->admin_app_priority_willing)
+			SET_FLAGS(admin_mib.ver_cfg_flags, DCBX_APP_WILLING);
+		else
+			RESET_FLAGS(admin_mib.ver_cfg_flags, DCBX_APP_WILLING);
+
+		for (i = 0 ; i < DCBX_MAX_NUM_PG_BW_ENTRIES; i++) {
+			DCBX_PG_BW_SET(af->ets.pg_bw_tbl, i,
+				(u8)dp->admin_configuration_bw_precentage[i]);
+
+			DP(NETIF_MSG_LINK, "pg_bw_tbl[%d] = %02x\n",
+			   i, DCBX_PG_BW_GET(af->ets.pg_bw_tbl, i));
+		}
+
+		for (i = 0; i < DCBX_MAX_NUM_PRI_PG_ENTRIES; i++) {
+			DCBX_PRI_PG_SET(af->ets.pri_pg_tbl, i,
+					(u8)dp->admin_configuration_ets_pg[i]);
+
+			DP(NETIF_MSG_LINK, "pri_pg_tbl[%d] = %02x\n",
+			   i, DCBX_PRI_PG_GET(af->ets.pri_pg_tbl, i));
+		}
+
+		/*For IEEE admin_recommendation_bw_precentage
+		 *For IEEE admin_recommendation_ets_pg */
+		af->pfc.pri_en_bitmap = (u8)dp->admin_pfc_bitmap;
+		for (i = 0; i < 4; i++) {
+			if (dp->admin_priority_app_table[i].valid) {
+				struct bnx2x_admin_priority_app_table *table =
+					dp->admin_priority_app_table;
+				if ((ETH_TYPE_FCOE == table[i].app_id) &&
+				   (TRAFFIC_TYPE_ETH == table[i].traffic_type))
+					traf_type = FCOE_APP_IDX;
+				else if ((TCP_PORT_ISCSI == table[i].app_id) &&
+				   (TRAFFIC_TYPE_PORT == table[i].traffic_type))
+					traf_type = ISCSI_APP_IDX;
+				else
+					traf_type = other_traf_type++;
+
+				af->app.app_pri_tbl[traf_type].app_id =
+					table[i].app_id;
+
+				af->app.app_pri_tbl[traf_type].pri_bitmap =
+					(u8)(1 << table[i].priority);
+
+				af->app.app_pri_tbl[traf_type].appBitfield =
+				    (DCBX_APP_ENTRY_VALID);
+
+				af->app.app_pri_tbl[traf_type].appBitfield |=
+				   (TRAFFIC_TYPE_ETH == table[i].traffic_type) ?
+					DCBX_APP_SF_ETH_TYPE : DCBX_APP_SF_PORT;
+			}
+		}
+
+		af->app.default_pri = (u8)dp->admin_default_priority;
+
+	} else if (BNX2X_DCBX_OVERWRITE_SETTINGS_ENABLE ==
+						dp->overwrite_settings)
+		dp->overwrite_settings = BNX2X_DCBX_OVERWRITE_SETTINGS_INVALID;
+
+	/* Write the data. */
+	buff = (u32 *)&admin_mib;
+	for (i = 0; i < sizeof(struct lldp_admin_mib); i += 4, buff++)
+		REG_WR(bp, (offset + i), *buff);
+}
+
+/* default */
+void bnx2x_dcbx_init_params(struct bnx2x *bp)
+{
+	bp->dcbx_config_params.admin_dcbx_version = 0x0; /* 0 - CEE; 1 - IEEE */
+	bp->dcbx_config_params.dcb_enable = 1;
+	bp->dcbx_config_params.admin_dcbx_enable = 1;
+	bp->dcbx_config_params.admin_ets_willing = 1;
+	bp->dcbx_config_params.admin_pfc_willing = 1;
+	bp->dcbx_config_params.overwrite_settings = 1;
+	bp->dcbx_config_params.admin_ets_enable = 1;
+	bp->dcbx_config_params.admin_pfc_enable = 1;
+	bp->dcbx_config_params.admin_tc_supported_tx_enable = 1;
+	bp->dcbx_config_params.admin_ets_configuration_tx_enable = 1;
+	bp->dcbx_config_params.admin_pfc_tx_enable = 1;
+	bp->dcbx_config_params.admin_application_priority_tx_enable = 1;
+	bp->dcbx_config_params.admin_ets_reco_valid = 1;
+	bp->dcbx_config_params.admin_app_priority_willing = 1;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[0] = 00;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[1] = 50;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[2] = 50;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[3] = 0;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[4] = 0;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[5] = 0;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[6] = 0;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[7] = 0;
+	bp->dcbx_config_params.admin_configuration_ets_pg[0] = 1;
+	bp->dcbx_config_params.admin_configuration_ets_pg[1] = 0;
+	bp->dcbx_config_params.admin_configuration_ets_pg[2] = 0;
+	bp->dcbx_config_params.admin_configuration_ets_pg[3] = 2;
+	bp->dcbx_config_params.admin_configuration_ets_pg[4] = 0;
+	bp->dcbx_config_params.admin_configuration_ets_pg[5] = 0;
+	bp->dcbx_config_params.admin_configuration_ets_pg[6] = 0;
+	bp->dcbx_config_params.admin_configuration_ets_pg[7] = 0;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[0] = 0;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[1] = 1;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[2] = 2;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[3] = 0;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[4] = 7;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[5] = 5;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[6] = 6;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[7] = 7;
+	bp->dcbx_config_params.admin_recommendation_ets_pg[0] = 0;
+	bp->dcbx_config_params.admin_recommendation_ets_pg[1] = 1;
+	bp->dcbx_config_params.admin_recommendation_ets_pg[2] = 2;
+	bp->dcbx_config_params.admin_recommendation_ets_pg[3] = 3;
+	bp->dcbx_config_params.admin_recommendation_ets_pg[4] = 4;
+	bp->dcbx_config_params.admin_recommendation_ets_pg[5] = 5;
+	bp->dcbx_config_params.admin_recommendation_ets_pg[6] = 6;
+	bp->dcbx_config_params.admin_recommendation_ets_pg[7] = 7;
+	bp->dcbx_config_params.admin_pfc_bitmap = 0x8; /* FCoE(3) enable */
+	bp->dcbx_config_params.admin_priority_app_table[0].valid = 1;
+	bp->dcbx_config_params.admin_priority_app_table[1].valid = 1;
+	bp->dcbx_config_params.admin_priority_app_table[2].valid = 0;
+	bp->dcbx_config_params.admin_priority_app_table[3].valid = 0;
+	bp->dcbx_config_params.admin_priority_app_table[0].priority = 3;
+	bp->dcbx_config_params.admin_priority_app_table[1].priority = 0;
+	bp->dcbx_config_params.admin_priority_app_table[2].priority = 0;
+	bp->dcbx_config_params.admin_priority_app_table[3].priority = 0;
+	bp->dcbx_config_params.admin_priority_app_table[0].traffic_type = 0;
+	bp->dcbx_config_params.admin_priority_app_table[1].traffic_type = 1;
+	bp->dcbx_config_params.admin_priority_app_table[2].traffic_type = 0;
+	bp->dcbx_config_params.admin_priority_app_table[3].traffic_type = 0;
+	bp->dcbx_config_params.admin_priority_app_table[0].app_id = 0x8906;
+	bp->dcbx_config_params.admin_priority_app_table[1].app_id = 3260;
+	bp->dcbx_config_params.admin_priority_app_table[2].app_id = 0;
+	bp->dcbx_config_params.admin_priority_app_table[3].app_id = 0;
+	bp->dcbx_config_params.admin_default_priority =
+		bp->dcbx_config_params.admin_priority_app_table[1].priority;
+}
+
+void bnx2x_dcbx_init(struct bnx2x *bp)
+{
+	u32 dcbx_lldp_params_offset = SHMEM_LLDP_DCBX_PARAMS_NONE;
+	/* validate:
+	 * chip of good for dcbx version,
+	 * dcb is wanted
+	 * the function is pmf
+	 * shmem2 contains DCBX support fields
+	 */
+	DP(NETIF_MSG_LINK, "dcb_enable %d bp->port.pmf %d\n",
+	   bp->dcbx_config_params.dcb_enable, bp->port.pmf);
+
+	if (CHIP_IS_E2(bp) && !CHIP_MODE_IS_4_PORT(bp) &&
+	    bp->dcbx_config_params.dcb_enable &&
+	    bp->port.pmf &&
+	    SHMEM2_HAS(bp, dcbx_lldp_params_offset)) {
+		dcbx_lldp_params_offset = SHMEM2_RD(bp,
+						    dcbx_lldp_params_offset);
+		DP(NETIF_MSG_LINK, "dcbx_lldp_params_offset 0x%x\n",
+		   dcbx_lldp_params_offset);
+		if (SHMEM_LLDP_DCBX_PARAMS_NONE != dcbx_lldp_params_offset) {
+			bnx2x_dcbx_lldp_updated_params(bp,
+						       dcbx_lldp_params_offset);
+
+			bnx2x_dcbx_admin_mib_updated_params(bp,
+				dcbx_lldp_params_offset);
+
+			/* set default configuration BC has */
+			bnx2x_dcbx_set_params(bp,
+					      BNX2X_DCBX_STATE_NEG_RECEIVED);
+
+			bnx2x_fw_command(bp,
+					 DRV_MSG_CODE_DCBX_ADMIN_PMF_MSG, 0);
+		}
+	}
+}
+
+void bnx2x_dcb_init_intmem_pfc(struct bnx2x *bp)
+{
+	struct priority_cos pricos[MAX_PFC_TRAFFIC_TYPES];
+	u32 i = 0, addr;
+	memset(pricos, 0, sizeof(pricos));
+	/* Default initialization */
+	for (i = 0; i < MAX_PFC_TRAFFIC_TYPES; i++)
+		pricos[i].priority = LLFC_TRAFFIC_TYPE_TO_PRIORITY_UNMAPPED;
+
+	/* Store per port struct to internal memory */
+	addr = BAR_XSTRORM_INTMEM +
+			XSTORM_CMNG_PER_PORT_VARS_OFFSET(BP_PORT(bp)) +
+			offsetof(struct cmng_struct_per_port,
+				 traffic_type_to_priority_cos);
+	__storm_memset_struct(bp, addr, sizeof(pricos), (u32 *)pricos);
+
+
+	/* LLFC disabled.*/
+	REG_WR8(bp , BAR_XSTRORM_INTMEM +
+		    XSTORM_CMNG_PER_PORT_VARS_OFFSET(BP_PORT(bp)) +
+		    offsetof(struct cmng_struct_per_port, llfc_mode),
+			LLFC_MODE_NONE);
+
+	/* DCBX disabled.*/
+	REG_WR8(bp , BAR_XSTRORM_INTMEM +
+		    XSTORM_CMNG_PER_PORT_VARS_OFFSET(BP_PORT(bp)) +
+		    offsetof(struct cmng_struct_per_port, dcb_enabled),
+			DCB_DISABLED);
+}
+
+static void
+bnx2x_dcbx_print_cos_params(struct bnx2x *bp,
+			    struct flow_control_configuration *pfc_fw_cfg)
+{
+	u8 pri = 0;
+	u8 cos = 0;
+
+	DP(NETIF_MSG_LINK,
+	   "pfc_fw_cfg->dcb_version %x\n", pfc_fw_cfg->dcb_version);
+	DP(NETIF_MSG_LINK,
+	   "pdev->params.dcbx_port_params.pfc."
+	   "priority_non_pauseable_mask %x\n",
+	   bp->dcbx_port_params.pfc.priority_non_pauseable_mask);
+
+	for (cos = 0 ; cos < bp->dcbx_port_params.ets.num_of_cos ; cos++) {
+		DP(NETIF_MSG_LINK, "pdev->params.dcbx_port_params.ets."
+		   "cos_params[%d].pri_bitmask %x\n", cos,
+		   bp->dcbx_port_params.ets.cos_params[cos].pri_bitmask);
+
+		DP(NETIF_MSG_LINK, "pdev->params.dcbx_port_params.ets."
+		   "cos_params[%d].bw_tbl %x\n", cos,
+		   bp->dcbx_port_params.ets.cos_params[cos].bw_tbl);
+
+		DP(NETIF_MSG_LINK, "pdev->params.dcbx_port_params.ets."
+		   "cos_params[%d].strict %x\n", cos,
+		   bp->dcbx_port_params.ets.cos_params[cos].strict);
+
+		DP(NETIF_MSG_LINK, "pdev->params.dcbx_port_params.ets."
+		   "cos_params[%d].pauseable %x\n", cos,
+		   bp->dcbx_port_params.ets.cos_params[cos].pauseable);
+	}
+
+	for (pri = 0; pri < LLFC_DRIVER_TRAFFIC_TYPE_MAX; pri++) {
+		DP(NETIF_MSG_LINK,
+		   "pfc_fw_cfg->traffic_type_to_priority_cos[%d]."
+		   "priority %x\n", pri,
+		   pfc_fw_cfg->traffic_type_to_priority_cos[pri].priority);
+
+		DP(NETIF_MSG_LINK,
+		   "pfc_fw_cfg->traffic_type_to_priority_cos[%d].cos %x\n",
+		   pri, pfc_fw_cfg->traffic_type_to_priority_cos[pri].cos);
+	}
+}
+
+/* fills help_data according to pg_info */
+static void bnx2x_dcbx_get_num_pg_traf_type(struct bnx2x *bp,
+					    u32 *pg_pri_orginal_spread,
+					    struct pg_help_data *help_data)
+{
+	bool pg_found  = false;
+	u32 i, traf_type, add_traf_type, add_pg;
+	u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
+	struct pg_entry_help_data *data = help_data->data; /*shotcut*/
+
+	/* Set to invalid */
+	for (i = 0; i < LLFC_DRIVER_TRAFFIC_TYPE_MAX; i++)
+		data[i].pg = DCBX_ILLEGAL_PG;
+
+	for (add_traf_type = 0;
+	     add_traf_type < LLFC_DRIVER_TRAFFIC_TYPE_MAX; add_traf_type++) {
+		pg_found = false;
+		if (ttp[add_traf_type] < MAX_PFC_PRIORITIES) {
+			add_pg = (u8)pg_pri_orginal_spread[ttp[add_traf_type]];
+			for (traf_type = 0;
+			     traf_type < LLFC_DRIVER_TRAFFIC_TYPE_MAX;
+			     traf_type++) {
+				if (data[traf_type].pg == add_pg) {
+					if (!(data[traf_type].pg_priority &
+					     (1 << ttp[add_traf_type])))
+						data[traf_type].
+							num_of_dif_pri++;
+					data[traf_type].pg_priority |=
+						(1 << ttp[add_traf_type]);
+					pg_found = true;
+					break;
+				}
+			}
+			if (false == pg_found) {
+				data[help_data->num_of_pg].pg = add_pg;
+				data[help_data->num_of_pg].pg_priority =
+						(1 << ttp[add_traf_type]);
+				data[help_data->num_of_pg].num_of_dif_pri = 1;
+				help_data->num_of_pg++;
+			}
+		}
+		DP(NETIF_MSG_LINK,
+		   "add_traf_type %d pg_found %s num_of_pg %d\n",
+		   add_traf_type, (false == pg_found) ? "NO" : "YES",
+		   help_data->num_of_pg);
+	}
+}
+
+
+/*******************************************************************************
+ * Description: single priority group
+ *
+ * Return:
+ ******************************************************************************/
+static void bnx2x_dcbx_ets_disabled_entry_data(struct bnx2x *bp,
+					       struct cos_help_data *cos_data,
+					       u32 pri_join_mask)
+{
+	/* Only one priority than only one COS */
+	cos_data->data[0].pausable =
+		IS_DCBX_PFC_PRI_ONLY_PAUSE(bp, pri_join_mask);
+	cos_data->data[0].pri_join_mask = pri_join_mask;
+	cos_data->data[0].cos_bw = 100;
+	cos_data->num_of_cos = 1;
+}
+
+/*******************************************************************************
+ * Description: updating the cos bw
+ *
+ * Return:
+ ******************************************************************************/
+static inline void bnx2x_dcbx_add_to_cos_bw(struct bnx2x *bp,
+					    struct cos_entry_help_data *data,
+					    u8 pg_bw)
+{
+	if (data->cos_bw == DCBX_INVALID_COS_BW)
+		data->cos_bw = pg_bw;
+	else
+		data->cos_bw += pg_bw;
+}
+
+/*******************************************************************************
+ * Description: single priority group
+ *
+ * Return:
+ ******************************************************************************/
+static void bnx2x_dcbx_separate_pauseable_from_non(struct bnx2x *bp,
+			struct cos_help_data *cos_data,
+			u32 *pg_pri_orginal_spread,
+			struct dcbx_ets_feature *ets)
+{
+	u32	pri_tested	= 0;
+	u8	i		= 0;
+	u8	entry		= 0;
+	u8	pg_entry	= 0;
+	u8	num_of_pri	= LLFC_DRIVER_TRAFFIC_TYPE_MAX;
+
+	cos_data->data[0].pausable = true;
+	cos_data->data[1].pausable = false;
+	cos_data->data[0].pri_join_mask = cos_data->data[1].pri_join_mask = 0;
+
+	for (i = 0 ; i < num_of_pri ; i++) {
+		pri_tested = 1 << bp->dcbx_port_params.
+					app.traffic_type_priority[i];
+
+		if (pri_tested & DCBX_PFC_PRI_NON_PAUSE_MASK(bp)) {
+			cos_data->data[1].pri_join_mask |= pri_tested;
+			entry = 1;
+		} else {
+			cos_data->data[0].pri_join_mask |= pri_tested;
+			entry = 0;
+		}
+		pg_entry = (u8)pg_pri_orginal_spread[bp->dcbx_port_params.
+						app.traffic_type_priority[i]];
+		/* There can be only one strict pg */
+		if (pg_entry < DCBX_MAX_NUM_PG_BW_ENTRIES)
+			bnx2x_dcbx_add_to_cos_bw(bp, &cos_data->data[entry],
+				DCBX_PG_BW_GET(ets->pg_bw_tbl, pg_entry));
+		else
+			/* If we join a group and one is strict
+			 * than the bw rulls */
+			cos_data->data[entry].strict =
+						BNX2X_DCBX_COS_HIGH_STRICT;
+	}
+	if ((0 == cos_data->data[0].pri_join_mask) &&
+	    (0 == cos_data->data[1].pri_join_mask))
+		BNX2X_ERR("dcbx error: Both groups must have priorities\n");
+}
+
+
+#ifndef POWER_OF_2
+#define POWER_OF_2(x)	((0 != x) && (0 == (x & (x-1))))
+#endif
+
+static void bxn2x_dcbx_single_pg_to_cos_params(struct bnx2x *bp,
+					      struct pg_help_data *pg_help_data,
+					      struct cos_help_data *cos_data,
+					      u32 pri_join_mask,
+					      u8 num_of_dif_pri)
+{
+	u8 i = 0;
+	u32 pri_tested = 0;
+	u32 pri_mask_without_pri = 0;
+	u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
+	/*debug*/
+	if (num_of_dif_pri == 1) {
+		bnx2x_dcbx_ets_disabled_entry_data(bp, cos_data, pri_join_mask);
+		return;
+	}
+	/* single priority group */
+	if (pg_help_data->data[0].pg < DCBX_MAX_NUM_PG_BW_ENTRIES) {
+		/* If there are both pauseable and non-pauseable priorities,
+		 * the pauseable priorities go to the first queue and
+		 * the non-pauseable priorities go to the second queue.
+		 */
+		if (IS_DCBX_PFC_PRI_MIX_PAUSE(bp, pri_join_mask)) {
+			/* Pauseable */
+			cos_data->data[0].pausable = true;
+			/* Non pauseable.*/
+			cos_data->data[1].pausable = false;
+
+			if (2 == num_of_dif_pri) {
+				cos_data->data[0].cos_bw = 50;
+				cos_data->data[1].cos_bw = 50;
+			}
+
+			if (3 == num_of_dif_pri) {
+				if (POWER_OF_2(DCBX_PFC_PRI_GET_PAUSE(bp,
+							pri_join_mask))) {
+					cos_data->data[0].cos_bw = 33;
+					cos_data->data[1].cos_bw = 67;
+				} else {
+					cos_data->data[0].cos_bw = 67;
+					cos_data->data[1].cos_bw = 33;
+				}
+			}
+
+		} else if (IS_DCBX_PFC_PRI_ONLY_PAUSE(bp, pri_join_mask)) {
+			/* If there are only pauseable priorities,
+			 * then one/two priorities go to the first queue
+			 * and one priority goes to the second queue.
+			 */
+			if (2 == num_of_dif_pri) {
+				cos_data->data[0].cos_bw = 50;
+				cos_data->data[1].cos_bw = 50;
+			} else {
+				cos_data->data[0].cos_bw = 67;
+				cos_data->data[1].cos_bw = 33;
+			}
+			cos_data->data[1].pausable = true;
+			cos_data->data[0].pausable = true;
+			/* All priorities except FCOE */
+			cos_data->data[0].pri_join_mask = (pri_join_mask &
+				((u8)~(1 << ttp[LLFC_TRAFFIC_TYPE_FCOE])));
+			/* Only FCOE priority.*/
+			cos_data->data[1].pri_join_mask =
+				(1 << ttp[LLFC_TRAFFIC_TYPE_FCOE]);
+		} else
+			/* If there are only non-pauseable priorities,
+			 * they will all go to the same queue.
+			 */
+			bnx2x_dcbx_ets_disabled_entry_data(bp,
+						cos_data, pri_join_mask);
+	} else {
+		/* priority group which is not BW limited (PG#15):*/
+		if (IS_DCBX_PFC_PRI_MIX_PAUSE(bp, pri_join_mask)) {
+			/* If there are both pauseable and non-pauseable
+			 * priorities, the pauseable priorities go to the first
+			 * queue and the non-pauseable priorities
+			 * go to the second queue.
+			 */
+			if (DCBX_PFC_PRI_GET_PAUSE(bp, pri_join_mask) >
+			    DCBX_PFC_PRI_GET_NON_PAUSE(bp, pri_join_mask)) {
+				cos_data->data[0].strict =
+					BNX2X_DCBX_COS_HIGH_STRICT;
+				cos_data->data[1].strict =
+					BNX2X_DCBX_COS_LOW_STRICT;
+			} else {
+				cos_data->data[0].strict =
+					BNX2X_DCBX_COS_LOW_STRICT;
+				cos_data->data[1].strict =
+					BNX2X_DCBX_COS_HIGH_STRICT;
+			}
+			/* Pauseable */
+			cos_data->data[0].pausable = true;
+			/* Non pause-able.*/
+			cos_data->data[1].pausable = false;
+		} else {
+			/* If there are only pauseable priorities or
+			 * only non-pauseable,* the lower priorities go
+			 * to the first queue and the higherpriorities go
+			 * to the second queue.
+			 */
+			cos_data->data[0].pausable =
+				cos_data->data[1].pausable =
+				IS_DCBX_PFC_PRI_ONLY_PAUSE(bp, pri_join_mask);
+
+			for (i = 0 ; i < LLFC_DRIVER_TRAFFIC_TYPE_MAX; i++) {
+				pri_tested = 1 << bp->dcbx_port_params.
+					app.traffic_type_priority[i];
+				/* Remove priority tested */
+				pri_mask_without_pri =
+					(pri_join_mask & ((u8)(~pri_tested)));
+				if (pri_mask_without_pri < pri_tested)
+					break;
+			}
+
+			if (i == LLFC_DRIVER_TRAFFIC_TYPE_MAX)
+				BNX2X_ERR("Invalid value for pri_join_mask -"
+					  " could not find a priority\n");
+
+			cos_data->data[0].pri_join_mask = pri_mask_without_pri;
+			cos_data->data[1].pri_join_mask = pri_tested;
+			/* Both queues are strict priority,
+			 * and that with the highest priority
+			 * gets the highest strict priority in the arbiter.
+			 */
+			cos_data->data[0].strict = BNX2X_DCBX_COS_LOW_STRICT;
+			cos_data->data[1].strict = BNX2X_DCBX_COS_HIGH_STRICT;
+		}
+	}
+}
+
+static void bnx2x_dcbx_two_pg_to_cos_params(
+			    struct bnx2x		*bp,
+			    struct  pg_help_data	*pg_help_data,
+			    struct dcbx_ets_feature	*ets,
+			    struct cos_help_data	*cos_data,
+			    u32			*pg_pri_orginal_spread,
+			    u32				pri_join_mask,
+			    u8				num_of_dif_pri)
+{
+	u8 i = 0;
+	u8 pg[E2_NUM_OF_COS] = {0};
+
+	/* If there are both pauseable and non-pauseable priorities,
+	 * the pauseable priorities go to the first queue and
+	 * the non-pauseable priorities go to the second queue.
+	 */
+	if (IS_DCBX_PFC_PRI_MIX_PAUSE(bp, pri_join_mask)) {
+		if (IS_DCBX_PFC_PRI_MIX_PAUSE(bp,
+					 pg_help_data->data[0].pg_priority) ||
+		    IS_DCBX_PFC_PRI_MIX_PAUSE(bp,
+					 pg_help_data->data[1].pg_priority)) {
+			/* If one PG contains both pauseable and
+			 * non-pauseable priorities then ETS is disabled.
+			 */
+			bnx2x_dcbx_separate_pauseable_from_non(bp, cos_data,
+					pg_pri_orginal_spread, ets);
+			bp->dcbx_port_params.ets.enabled = false;
+			return;
+		}
+
+		/* Pauseable */
+		cos_data->data[0].pausable = true;
+		/* Non pauseable. */
+		cos_data->data[1].pausable = false;
+		if (IS_DCBX_PFC_PRI_ONLY_PAUSE(bp,
+				pg_help_data->data[0].pg_priority)) {
+			/* 0 is pauseable */
+			cos_data->data[0].pri_join_mask =
+				pg_help_data->data[0].pg_priority;
+			pg[0] = pg_help_data->data[0].pg;
+			cos_data->data[1].pri_join_mask =
+				pg_help_data->data[1].pg_priority;
+			pg[1] = pg_help_data->data[1].pg;
+		} else {/* 1 is pauseable */
+			cos_data->data[0].pri_join_mask =
+				pg_help_data->data[1].pg_priority;
+			pg[0] = pg_help_data->data[1].pg;
+			cos_data->data[1].pri_join_mask =
+				pg_help_data->data[0].pg_priority;
+			pg[1] = pg_help_data->data[0].pg;
+		}
+	} else {
+		/* If there are only pauseable priorities or
+		 * only non-pauseable, each PG goes to a queue.
+		 */
+		cos_data->data[0].pausable = cos_data->data[1].pausable =
+			IS_DCBX_PFC_PRI_ONLY_PAUSE(bp, pri_join_mask);
+		cos_data->data[0].pri_join_mask =
+			pg_help_data->data[0].pg_priority;
+		pg[0] = pg_help_data->data[0].pg;
+		cos_data->data[1].pri_join_mask =
+			pg_help_data->data[1].pg_priority;
+		pg[1] = pg_help_data->data[1].pg;
+	}
+
+	/* There can be only one strict pg */
+	for (i = 0 ; i < E2_NUM_OF_COS; i++) {
+		if (pg[i] < DCBX_MAX_NUM_PG_BW_ENTRIES)
+			cos_data->data[i].cos_bw =
+				DCBX_PG_BW_GET(ets->pg_bw_tbl, pg[i]);
+		else
+			cos_data->data[i].strict = BNX2X_DCBX_COS_HIGH_STRICT;
+	}
+}
+
+/*******************************************************************************
+ * Description: Still
+ *
+ * Return:
+ ******************************************************************************/
+static void bnx2x_dcbx_three_pg_to_cos_params(
+			      struct bnx2x		*bp,
+			      struct pg_help_data	*pg_help_data,
+			      struct dcbx_ets_feature	*ets,
+			      struct cos_help_data	*cos_data,
+			      u32			*pg_pri_orginal_spread,
+			      u32			pri_join_mask,
+			      u8			num_of_dif_pri)
+{
+	u8 i = 0;
+	u32 pri_tested = 0;
+	u8 entry = 0;
+	u8 pg_entry = 0;
+	bool b_found_strict = false;
+	u8 num_of_pri = LLFC_DRIVER_TRAFFIC_TYPE_MAX;
+
+	cos_data->data[0].pri_join_mask = cos_data->data[1].pri_join_mask = 0;
+	/* If there are both pauseable and non-pauseable priorities,
+	 * the pauseable priorities go to the first queue and the
+	 * non-pauseable priorities go to the second queue.
+	 */
+	if (IS_DCBX_PFC_PRI_MIX_PAUSE(bp, pri_join_mask))
+		bnx2x_dcbx_separate_pauseable_from_non(bp,
+				cos_data, pg_pri_orginal_spread, ets);
+	else {
+		/* If two BW-limited PG-s were combined to one queue,
+		 * the BW is their sum.
+		 *
+		 * If there are only pauseable priorities or only non-pauseable,
+		 * and there are both BW-limited and non-BW-limited PG-s,
+		 * the BW-limited PG/s go to one queue and the non-BW-limited
+		 * PG/s go to the second queue.
+		 *
+		 * If there are only pauseable priorities or only non-pauseable
+		 * and all are BW limited, then	two priorities go to the first
+		 * queue and one priority goes to the second queue.
+		 *
+		 * We will join this two cases:
+		 * if one is BW limited it will go to the secoend queue
+		 * otherwise the last priority will get it
+		 */
+
+		cos_data->data[0].pausable = cos_data->data[1].pausable =
+			IS_DCBX_PFC_PRI_ONLY_PAUSE(bp, pri_join_mask);
+
+		for (i = 0 ; i < num_of_pri; i++) {
+			pri_tested = 1 << bp->dcbx_port_params.
+				app.traffic_type_priority[i];
+			pg_entry = (u8)pg_pri_orginal_spread[bp->
+				dcbx_port_params.app.traffic_type_priority[i]];
+
+			if (pg_entry < DCBX_MAX_NUM_PG_BW_ENTRIES) {
+				entry = 0;
+
+				if (i == (num_of_pri-1) &&
+				    false == b_found_strict)
+					/* last entry will be handled separately
+					 * If no priority is strict than last
+					 * enty goes to last queue.*/
+					entry = 1;
+				cos_data->data[entry].pri_join_mask |=
+								pri_tested;
+				bnx2x_dcbx_add_to_cos_bw(bp,
+					&cos_data->data[entry],
+					DCBX_PG_BW_GET(ets->pg_bw_tbl,
+						       pg_entry));
+			} else {
+				b_found_strict = true;
+				cos_data->data[1].pri_join_mask |= pri_tested;
+				/* If we join a group and one is strict
+				 * than the bw rulls */
+				cos_data->data[1].strict =
+					BNX2X_DCBX_COS_HIGH_STRICT;
+			}
+		}
+	}
+}
+
+
+static void bnx2x_dcbx_fill_cos_params(struct bnx2x *bp,
+				       struct pg_help_data *help_data,
+				       struct dcbx_ets_feature *ets,
+				       u32 *pg_pri_orginal_spread)
+{
+	struct cos_help_data         cos_data ;
+	u8                    i                           = 0;
+	u32                   pri_join_mask               = 0;
+	u8                    num_of_dif_pri              = 0;
+
+	memset(&cos_data, 0, sizeof(cos_data));
+	/* Validate the pg value */
+	for (i = 0; i < help_data->num_of_pg ; i++) {
+		if (DCBX_STRICT_PRIORITY != help_data->data[i].pg &&
+		    DCBX_MAX_NUM_PG_BW_ENTRIES <= help_data->data[i].pg)
+			BNX2X_ERR("Invalid pg[%d] data %x\n", i,
+				  help_data->data[i].pg);
+		pri_join_mask   |=  help_data->data[i].pg_priority;
+		num_of_dif_pri  += help_data->data[i].num_of_dif_pri;
+	}
+
+	/* default settings */
+	cos_data.num_of_cos = 2;
+	for (i = 0; i < E2_NUM_OF_COS ; i++) {
+		cos_data.data[i].pri_join_mask    = pri_join_mask;
+		cos_data.data[i].pausable         = false;
+		cos_data.data[i].strict           = BNX2X_DCBX_COS_NOT_STRICT;
+		cos_data.data[i].cos_bw           = DCBX_INVALID_COS_BW;
+	}
+
+	switch (help_data->num_of_pg) {
+	case 1:
+
+		bxn2x_dcbx_single_pg_to_cos_params(
+					       bp,
+					       help_data,
+					       &cos_data,
+					       pri_join_mask,
+					       num_of_dif_pri);
+		break;
+	case 2:
+		bnx2x_dcbx_two_pg_to_cos_params(
+					    bp,
+					    help_data,
+					    ets,
+					    &cos_data,
+					    pg_pri_orginal_spread,
+					    pri_join_mask,
+					    num_of_dif_pri);
+		break;
+
+	case 3:
+		bnx2x_dcbx_three_pg_to_cos_params(
+					      bp,
+					      help_data,
+					      ets,
+					      &cos_data,
+					      pg_pri_orginal_spread,
+					      pri_join_mask,
+					      num_of_dif_pri);
+
+		break;
+	default:
+		BNX2X_ERR("Wrong pg_help_data.num_of_pg\n");
+		bnx2x_dcbx_ets_disabled_entry_data(bp,
+						   &cos_data, pri_join_mask);
+	}
+
+	for (i = 0; i < cos_data.num_of_cos ; i++) {
+		struct bnx2x_dcbx_cos_params *params =
+			&bp->dcbx_port_params.ets.cos_params[i];
+
+		params->pauseable = cos_data.data[i].pausable;
+		params->strict = cos_data.data[i].strict;
+		params->bw_tbl = cos_data.data[i].cos_bw;
+		if (params->pauseable) {
+			params->pri_bitmask =
+			DCBX_PFC_PRI_GET_PAUSE(bp,
+					cos_data.data[i].pri_join_mask);
+			DP(NETIF_MSG_LINK, "COS %d PAUSABLE prijoinmask 0x%x\n",
+				  i, cos_data.data[i].pri_join_mask);
+		} else {
+			params->pri_bitmask =
+			DCBX_PFC_PRI_GET_NON_PAUSE(bp,
+					cos_data.data[i].pri_join_mask);
+			DP(NETIF_MSG_LINK, "COS %d NONPAUSABLE prijoinmask "
+					  "0x%x\n",
+				  i, cos_data.data[i].pri_join_mask);
+		}
+	}
+
+	bp->dcbx_port_params.ets.num_of_cos = cos_data.num_of_cos ;
+}
+
+static void bnx2x_dcbx_get_ets_pri_pg_tbl(struct bnx2x *bp,
+				u32 *set_configuration_ets_pg,
+				u32 *pri_pg_tbl)
+{
+	int i;
+
+	for (i = 0; i < DCBX_MAX_NUM_PRI_PG_ENTRIES; i++) {
+		set_configuration_ets_pg[i] = DCBX_PRI_PG_GET(pri_pg_tbl, i);
+
+		DP(NETIF_MSG_LINK, "set_configuration_ets_pg[%d] = 0x%x\n",
+		   i, set_configuration_ets_pg[i]);
+	}
+}
+
+/*******************************************************************************
+ * Description: Fill pfc_config struct that will be sent in DCBX start ramrod
+ *
+ * Return:
+ ******************************************************************************/
+static void bnx2x_pfc_fw_struct_e2(struct bnx2x *bp)
+{
+	struct flow_control_configuration   *pfc_fw_cfg = 0;
+	u16 pri_bit = 0;
+	u8 cos = 0, pri = 0;
+	struct priority_cos *tt2cos;
+	u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
+
+	pfc_fw_cfg = (struct flow_control_configuration *)
+					bnx2x_sp(bp, pfc_config);
+	memset(pfc_fw_cfg, 0, sizeof(struct flow_control_configuration));
+
+	/*shortcut*/
+	tt2cos = pfc_fw_cfg->traffic_type_to_priority_cos;
+
+	/* Fw version should be incremented each update */
+	pfc_fw_cfg->dcb_version = ++bp->dcb_version;
+	pfc_fw_cfg->dcb_enabled = DCB_ENABLED;
+
+	/* Default initialization */
+	for (pri = 0; pri < MAX_PFC_TRAFFIC_TYPES ; pri++) {
+		tt2cos[pri].priority = LLFC_TRAFFIC_TYPE_TO_PRIORITY_UNMAPPED;
+		tt2cos[pri].cos = 0;
+	}
+
+	/* Fill priority parameters */
+	for (pri = 0; pri < LLFC_DRIVER_TRAFFIC_TYPE_MAX; pri++) {
+		tt2cos[pri].priority = ttp[pri];
+		pri_bit = 1 << tt2cos[pri].priority;
+
+		/* Fill COS parameters based on COS calculated to
+		 * make it more generally for future use */
+		for (cos = 0; cos < bp->dcbx_port_params.ets.num_of_cos; cos++)
+			if (bp->dcbx_port_params.ets.cos_params[cos].
+						pri_bitmask & pri_bit)
+					tt2cos[pri].cos = cos;
+	}
+	bnx2x_dcbx_print_cos_params(bp,	pfc_fw_cfg);
+}
diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/bnx2x/bnx2x_dcb.h
new file mode 100644
index 0000000..8dea56b
--- /dev/null
+++ b/drivers/net/bnx2x/bnx2x_dcb.h
@@ -0,0 +1,193 @@
+/* bnx2x_dcb.h: Broadcom Everest network driver.
+ *
+ * Copyright 2009-2010 Broadcom Corporation
+ *
+ * Unless you and Broadcom execute a separate written software license
+ * agreement governing use of this software, this software is licensed to you
+ * under the terms of the GNU General Public License version 2, available
+ * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL").
+ *
+ * Notwithstanding the above, under no circumstances may you combine this
+ * software in any way with any other Broadcom software provided under a
+ * license other than the GPL, without Broadcom's express prior written
+ * consent.
+ *
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Dmitry Kravkov
+ *
+ */
+#ifndef BNX2X_DCB_H
+#define BNX2X_DCB_H
+
+#include "bnx2x_hsi.h"
+
+#define LLFC_DRIVER_TRAFFIC_TYPE_MAX 3 /* NW, iSCSI, FCoE */
+struct bnx2x_dcbx_app_params {
+	u32 enabled;
+	u32 traffic_type_priority[LLFC_DRIVER_TRAFFIC_TYPE_MAX];
+};
+
+#define E2_NUM_OF_COS			2
+#define BNX2X_DCBX_COS_NOT_STRICT	0
+#define BNX2X_DCBX_COS_LOW_STRICT	1
+#define BNX2X_DCBX_COS_HIGH_STRICT	2
+
+struct bnx2x_dcbx_cos_params {
+	u32	bw_tbl;
+	u32	pri_bitmask;
+	u8	strict;
+	u8	pauseable;
+};
+
+struct bnx2x_dcbx_pg_params {
+	u32 enabled;
+	u8 num_of_cos; /* valid COS entries */
+	struct bnx2x_dcbx_cos_params	cos_params[E2_NUM_OF_COS];
+};
+
+struct bnx2x_dcbx_pfc_params {
+	u32 enabled;
+	u32 priority_non_pauseable_mask;
+};
+
+struct bnx2x_dcbx_port_params {
+	u32 dcbx_enabled;
+	struct bnx2x_dcbx_pfc_params pfc;
+	struct bnx2x_dcbx_pg_params  ets;
+	struct bnx2x_dcbx_app_params app;
+};
+
+#define BNX2X_DCBX_CONFIG_INV_VALUE			(0xFFFFFFFF)
+#define BNX2X_DCBX_OVERWRITE_SETTINGS_DISABLE		0
+#define BNX2X_DCBX_OVERWRITE_SETTINGS_ENABLE		1
+#define BNX2X_DCBX_OVERWRITE_SETTINGS_INVALID	(BNX2X_DCBX_CONFIG_INV_VALUE)
+
+/*******************************************************************************
+ * LLDP protocol configuration parameters.
+ ******************************************************************************/
+struct bnx2x_config_lldp_params {
+	u32 overwrite_settings;
+	u32 msg_tx_hold;
+	u32 msg_fast_tx;
+	u32 tx_credit_max;
+	u32 msg_tx_interval;
+	u32 tx_fast;
+};
+
+struct bnx2x_admin_priority_app_table {
+		u32 valid;
+		u32 priority;
+#define INVALID_TRAFFIC_TYPE_PRIORITY	(0xFFFFFFFF)
+		u32 traffic_type;
+#define TRAFFIC_TYPE_ETH		0
+#define TRAFFIC_TYPE_PORT		1
+		u32 app_id;
+};
+
+/*******************************************************************************
+ * DCBX protocol configuration parameters.
+ ******************************************************************************/
+struct bnx2x_config_dcbx_params {
+	u32 dcb_enable;
+	u32 admin_dcbx_enable;
+	u32 overwrite_settings;
+	u32 admin_dcbx_version;
+	u32 admin_ets_enable;
+	u32 admin_pfc_enable;
+	u32 admin_tc_supported_tx_enable;
+	u32 admin_ets_configuration_tx_enable;
+	u32 admin_ets_recommendation_tx_enable;
+	u32 admin_pfc_tx_enable;
+	u32 admin_application_priority_tx_enable;
+	u32 admin_ets_willing;
+	u32 admin_ets_reco_valid;
+	u32 admin_pfc_willing;
+	u32 admin_app_priority_willing;
+	u32 admin_configuration_bw_precentage[8];
+	u32 admin_configuration_ets_pg[8];
+	u32 admin_recommendation_bw_precentage[8];
+	u32 admin_recommendation_ets_pg[8];
+	u32 admin_pfc_bitmap;
+	struct bnx2x_admin_priority_app_table admin_priority_app_table[4];
+	u32 admin_default_priority;
+};
+
+#define GET_FLAGS(flags, bits)		((flags) & (bits))
+#define SET_FLAGS(flags, bits)		((flags) |= (bits))
+#define RESET_FLAGS(flags, bits)	((flags) &= ~(bits))
+
+enum {
+	DCBX_READ_LOCAL_MIB,
+	DCBX_READ_REMOTE_MIB
+};
+
+#define ETH_TYPE_FCOE		(0x8906)
+#define TCP_PORT_ISCSI		(0xCBC)
+
+#define PFC_VALUE_FRAME_SIZE				(512)
+#define PFC_QUANTA_IN_NANOSEC_FROM_SPEED_MEGA(mega_speed)  \
+				((1000 * PFC_VALUE_FRAME_SIZE)/(mega_speed))
+
+#define PFC_BRB1_REG_HIGH_LLFC_LOW_THRESHOLD			130
+#define PFC_BRB1_REG_HIGH_LLFC_HIGH_THRESHOLD			170
+
+
+
+struct cos_entry_help_data {
+	u32			pri_join_mask;
+	u32			cos_bw;
+	u8			strict;
+	bool			pausable;
+};
+
+struct cos_help_data {
+	struct cos_entry_help_data	data[E2_NUM_OF_COS];
+	u8				num_of_cos;
+};
+
+#define DCBX_ILLEGAL_PG				(0xFF)
+#define DCBX_PFC_PRI_MASK			(0xFF)
+#define DCBX_STRICT_PRIORITY			(15)
+#define DCBX_INVALID_COS_BW			(0xFFFFFFFF)
+#define DCBX_PFC_PRI_NON_PAUSE_MASK(bp)		\
+			((bp)->dcbx_port_params.pfc.priority_non_pauseable_mask)
+#define DCBX_PFC_PRI_PAUSE_MASK(bp)		\
+					((u8)~DCBX_PFC_PRI_NON_PAUSE_MASK(bp))
+#define DCBX_PFC_PRI_GET_PAUSE(bp, pg_pri)	\
+				((pg_pri) & (DCBX_PFC_PRI_PAUSE_MASK(bp)))
+#define DCBX_PFC_PRI_GET_NON_PAUSE(bp, pg_pri)	\
+			(DCBX_PFC_PRI_NON_PAUSE_MASK(bp) & (pg_pri))
+#define IS_DCBX_PFC_PRI_ONLY_PAUSE(bp, pg_pri)	\
+			(pg_pri == DCBX_PFC_PRI_GET_PAUSE((bp), (pg_pri)))
+#define IS_DCBX_PFC_PRI_ONLY_NON_PAUSE(bp, pg_pri)\
+			((pg_pri) == DCBX_PFC_PRI_GET_NON_PAUSE((bp), (pg_pri)))
+#define IS_DCBX_PFC_PRI_MIX_PAUSE(bp, pg_pri)	\
+			(!(IS_DCBX_PFC_PRI_ONLY_NON_PAUSE((bp), (pg_pri)) || \
+			 IS_DCBX_PFC_PRI_ONLY_PAUSE((bp), (pg_pri))))
+
+
+struct pg_entry_help_data {
+	u8	num_of_dif_pri;
+	u8	pg;
+	u32	pg_priority;
+};
+
+struct pg_help_data {
+	struct pg_entry_help_data	data[LLFC_DRIVER_TRAFFIC_TYPE_MAX];
+	u8				num_of_pg;
+};
+
+/* forward DCB/PFC related declarations */
+struct bnx2x;
+void bnx2x_dcb_init_intmem_pfc(struct bnx2x *bp);
+void bnx2x_dcbx_update(struct work_struct *work);
+void bnx2x_dcbx_init_params(struct bnx2x *bp);
+
+enum {
+	BNX2X_DCBX_STATE_NEG_RECEIVED = 0x1,
+	BNX2X_DCBX_STATE_TX_PAUSED = 0x2,
+	BNX2X_DCBX_STATE_TX_RELEASED = 0x4
+};
+void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state);
+
+#endif /* BNX2X_DCB_H */
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 6555c47..ed90ec8 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -684,7 +684,7 @@ struct shm_dev_info {						    /* size */
 #define E1VN_MAX			1
 #define E1HVN_MAX			4
 
-
+#define E2_VF_MAX			64
 /* This value (in milliseconds) determines the frequency of the driver
  * issuing the PULSE message code.  The firmware monitors this periodic
  * pulse to determine when to switch to an OS-absent mode. */
@@ -820,6 +820,8 @@ struct drv_func_mb {
 #define DRV_MSG_CODE_VRFY_SPECIFIC_PHY_OPT_MDL	    0xa1000000
 #define REQ_BC_VER_4_VRFY_SPECIFIC_PHY_OPT_MDL	    0x00050234
 
+#define DRV_MSG_CODE_DCBX_ADMIN_PMF_MSG			0xb0000000
+#define DRV_MSG_CODE_DCBX_PMF_DRV_OK			0xb2000000
 #define DRV_MSG_CODE_SET_MF_BW				0xe0000000
 #define REQ_BC_VER_4_SET_MF_BW				0x00060202
 #define DRV_MSG_CODE_SET_MF_BW_ACK			0xe1000000
@@ -905,6 +907,8 @@ struct drv_func_mb {
 #define DRV_STATUS_DCC_RESERVED1			0x00000800
 #define DRV_STATUS_DCC_SET_PROTOCOL			0x00001000
 #define DRV_STATUS_DCC_SET_PRIORITY			0x00002000
+#define DRV_STATUS_DCBX_EVENT_MASK			0x000f0000
+#define DRV_STATUS_DCBX_NEGOTIATION_RESULTS		0x00010000
 
 	u32 virt_mac_upper;
 #define VIRT_MAC_SIGN_MASK				0xffff0000
@@ -1089,6 +1093,251 @@ struct fw_flr_mb {
 	struct	fw_flr_ack ack;
 };
 
+/**** SUPPORT FOR SHMEM ARRRAYS ***
+ * The SHMEM HSI is aligned on 32 bit boundaries which makes it difficult to
+ * define arrays with storage types smaller then unsigned dwords.
+ * The macros below add generic support for SHMEM arrays with numeric elements
+ * that can span 2,4,8 or 16 bits. The array underlying type is a 32 bit dword
+ * array with individual bit-filed elements accessed using shifts and masks.
+ *
+ */
+
+/* eb is the bitwidth of a single element */
+#define SHMEM_ARRAY_MASK(eb)		((1<<(eb))-1)
+#define SHMEM_ARRAY_ENTRY(i, eb)	((i)/(32/(eb)))
+
+/* the bit-position macro allows the used to flip the order of the arrays
+ * elements on a per byte or word boundary.
+ *
+ * example: an array with 8 entries each 4 bit wide. This array will fit into
+ * a single dword. The diagrmas below show the array order of the nibbles.
+ *
+ * SHMEM_ARRAY_BITPOS(i, 4, 4) defines the stadard ordering:
+ *
+ *		|		|		|		|
+ *   0	|   1	|   2	|   3	|   4	|   5	|   6	|   7	|
+ *		|		|		|		|
+ *
+ * SHMEM_ARRAY_BITPOS(i, 4, 8) defines a flip ordering per byte:
+ *
+ *		|		|		|		|
+ *   1	|   0	|   3	|   2	|   5	|   4	|   7	|   6	|
+ *		|		|		|		|
+ *
+ * SHMEM_ARRAY_BITPOS(i, 4, 16) defines a flip ordering per word:
+ *
+ *		|		|		|		|
+ *   3	|   2	|   1	|   0	|   7	|   6	|   5	|   4	|
+ *		|		|		|		|
+ */
+#define SHMEM_ARRAY_BITPOS(i, eb, fb)	\
+	((((32/(fb)) - 1 - ((i)/((fb)/(eb))) % (32/(fb))) * (fb)) + \
+	(((i)%((fb)/(eb))) * (eb)))
+
+#define SHMEM_ARRAY_GET(a, i, eb, fb)					   \
+	((a[SHMEM_ARRAY_ENTRY(i, eb)] >> SHMEM_ARRAY_BITPOS(i, eb, fb)) &  \
+	SHMEM_ARRAY_MASK(eb))
+
+#define SHMEM_ARRAY_SET(a, i, eb, fb, val)				   \
+do {									   \
+	a[SHMEM_ARRAY_ENTRY(i, eb)] &= ~(SHMEM_ARRAY_MASK(eb) <<	   \
+	SHMEM_ARRAY_BITPOS(i, eb, fb));				   \
+	a[SHMEM_ARRAY_ENTRY(i, eb)] |= (((val) & SHMEM_ARRAY_MASK(eb)) <<  \
+	SHMEM_ARRAY_BITPOS(i, eb, fb));				   \
+} while (0)
+
+
+/****START OF DCBX STRUCTURES DECLARATIONS****/
+#define DCBX_MAX_NUM_PRI_PG_ENTRIES	8
+#define DCBX_PRI_PG_BITWIDTH		4
+#define DCBX_PRI_PG_FBITS		8
+#define DCBX_PRI_PG_GET(a, i)		\
+	SHMEM_ARRAY_GET(a, i, DCBX_PRI_PG_BITWIDTH, DCBX_PRI_PG_FBITS)
+#define DCBX_PRI_PG_SET(a, i, val)	\
+	SHMEM_ARRAY_SET(a, i, DCBX_PRI_PG_BITWIDTH, DCBX_PRI_PG_FBITS, val)
+#define DCBX_MAX_NUM_PG_BW_ENTRIES	8
+#define DCBX_BW_PG_BITWIDTH		8
+#define DCBX_PG_BW_GET(a, i)		\
+	SHMEM_ARRAY_GET(a, i, DCBX_BW_PG_BITWIDTH, DCBX_BW_PG_BITWIDTH)
+#define DCBX_PG_BW_SET(a, i, val)	\
+	SHMEM_ARRAY_SET(a, i, DCBX_BW_PG_BITWIDTH, DCBX_BW_PG_BITWIDTH, val)
+#define DCBX_STRICT_PRI_PG		15
+#define DCBX_MAX_APP_PROTOCOL		16
+#define FCOE_APP_IDX			0
+#define ISCSI_APP_IDX			1
+#define PREDEFINED_APP_IDX_MAX		2
+
+struct dcbx_ets_feature {
+	u32 enabled;
+	u32  pg_bw_tbl[2];
+	u32  pri_pg_tbl[1];
+};
+
+struct dcbx_pfc_feature {
+#ifdef __BIG_ENDIAN
+	u8 pri_en_bitmap;
+#define DCBX_PFC_PRI_0 0x01
+#define DCBX_PFC_PRI_1 0x02
+#define DCBX_PFC_PRI_2 0x04
+#define DCBX_PFC_PRI_3 0x08
+#define DCBX_PFC_PRI_4 0x10
+#define DCBX_PFC_PRI_5 0x20
+#define DCBX_PFC_PRI_6 0x40
+#define DCBX_PFC_PRI_7 0x80
+	u8 pfc_caps;
+	u8 reserved;
+	u8 enabled;
+#elif defined(__LITTLE_ENDIAN)
+	u8 enabled;
+	u8 reserved;
+	u8 pfc_caps;
+	u8 pri_en_bitmap;
+#define DCBX_PFC_PRI_0 0x01
+#define DCBX_PFC_PRI_1 0x02
+#define DCBX_PFC_PRI_2 0x04
+#define DCBX_PFC_PRI_3 0x08
+#define DCBX_PFC_PRI_4 0x10
+#define DCBX_PFC_PRI_5 0x20
+#define DCBX_PFC_PRI_6 0x40
+#define DCBX_PFC_PRI_7 0x80
+#endif
+};
+
+struct dcbx_app_priority_entry {
+#ifdef __BIG_ENDIAN
+	u16	app_id;
+	u8	pri_bitmap;
+	u8	appBitfield;
+#define DCBX_APP_ENTRY_VALID	     0x01
+#define DCBX_APP_ENTRY_SF_MASK	     0x30
+#define DCBX_APP_ENTRY_SF_SHIFT	     4
+#define DCBX_APP_SF_ETH_TYPE	     0x10
+#define DCBX_APP_SF_PORT	     0x20
+#elif defined(__LITTLE_ENDIAN)
+	u8 appBitfield;
+#define DCBX_APP_ENTRY_VALID	     0x01
+#define DCBX_APP_ENTRY_SF_MASK	     0x30
+#define DCBX_APP_ENTRY_SF_SHIFT	     4
+#define DCBX_APP_SF_ETH_TYPE	     0x10
+#define DCBX_APP_SF_PORT	     0x20
+	u8	pri_bitmap;
+	u16	app_id;
+#endif
+};
+
+struct dcbx_app_priority_feature {
+#ifdef __BIG_ENDIAN
+	u8 reserved;
+	u8 default_pri;
+	u8 tc_supported;
+	u8 enabled;
+#elif defined(__LITTLE_ENDIAN)
+	u8 enabled;
+	u8 tc_supported;
+	u8 default_pri;
+	u8 reserved;
+#endif
+	struct dcbx_app_priority_entry  app_pri_tbl[DCBX_MAX_APP_PROTOCOL];
+};
+
+struct dcbx_features {
+	struct dcbx_ets_feature ets;
+	struct dcbx_pfc_feature pfc;
+	struct dcbx_app_priority_feature app;
+};
+
+struct lldp_params {
+#ifdef __BIG_ENDIAN
+	u8	msg_fast_tx_interval;
+	u8	msg_tx_hold;
+	u8	msg_tx_interval;
+	u8	admin_status;
+#define LLDP_TX_ONLY  0x01
+#define LLDP_RX_ONLY  0x02
+#define LLDP_TX_RX    0x03
+#define LLDP_DISABLED 0x04
+	u8	reserved1;
+	u8	tx_fast;
+	u8	tx_crd_max;
+	u8	tx_crd;
+#elif defined(__LITTLE_ENDIAN)
+	u8	admin_status;
+#define LLDP_TX_ONLY  0x01
+#define LLDP_RX_ONLY  0x02
+#define LLDP_TX_RX    0x03
+#define LLDP_DISABLED 0x04
+	u8	msg_tx_interval;
+	u8	msg_tx_hold;
+	u8	msg_fast_tx_interval;
+	u8	tx_crd;
+	u8	tx_crd_max;
+	u8	tx_fast;
+	u8	reserved1;
+#endif
+#define REM_CHASSIS_ID_STAT_LEN	4
+#define REM_PORT_ID_STAT_LEN 4
+	u32 peer_chassis_id[REM_CHASSIS_ID_STAT_LEN];
+	u32 peer_port_id[REM_PORT_ID_STAT_LEN];
+};
+
+struct lldp_dcbx_stat {
+#define LOCAL_CHASSIS_ID_STAT_LEN 2
+#define LOCAL_PORT_ID_STAT_LEN 2
+	u32 local_chassis_id[LOCAL_CHASSIS_ID_STAT_LEN];
+	u32 local_port_id[LOCAL_PORT_ID_STAT_LEN];
+	u32 num_tx_dcbx_pkts;
+	u32 num_rx_dcbx_pkts;
+};
+
+struct lldp_admin_mib {
+	u32	ver_cfg_flags;
+#define DCBX_ETS_CONFIG_TX_ENABLED	0x00000001
+#define DCBX_PFC_CONFIG_TX_ENABLED	0x00000002
+#define DCBX_APP_CONFIG_TX_ENABLED	0x00000004
+#define DCBX_ETS_RECO_TX_ENABLED	0x00000008
+#define DCBX_ETS_RECO_VALID		0x00000010
+#define DCBX_ETS_WILLING		0x00000020
+#define DCBX_PFC_WILLING		0x00000040
+#define DCBX_APP_WILLING		0x00000080
+#define DCBX_VERSION_CEE		0x00000100
+#define DCBX_VERSION_IEEE		0x00000200
+#define DCBX_DCBX_ENABLED		0x00000400
+#define DCBX_CEE_VERSION_MASK		0x0000f000
+#define DCBX_CEE_VERSION_SHIFT		12
+#define DCBX_CEE_MAX_VERSION_MASK	0x000f0000
+#define DCBX_CEE_MAX_VERSION_SHIFT	16
+	struct dcbx_features	features;
+};
+
+struct lldp_remote_mib {
+	u32 prefix_seq_num;
+	u32 flags;
+#define DCBX_ETS_TLV_RX	    0x00000001
+#define DCBX_PFC_TLV_RX	    0x00000002
+#define DCBX_APP_TLV_RX	    0x00000004
+#define DCBX_ETS_RX_ERROR   0x00000010
+#define DCBX_PFC_RX_ERROR   0x00000020
+#define DCBX_APP_RX_ERROR   0x00000040
+#define DCBX_ETS_REM_WILLING	0x00000100
+#define DCBX_PFC_REM_WILLING	0x00000200
+#define DCBX_APP_REM_WILLING	0x00000400
+#define DCBX_REMOTE_ETS_RECO_VALID  0x00001000
+	struct dcbx_features features;
+	u32 suffix_seq_num;
+};
+
+struct lldp_local_mib {
+	u32 prefix_seq_num;
+	u32 error;
+#define DCBX_LOCAL_ETS_ERROR	 0x00000001
+#define DCBX_LOCAL_PFC_ERROR	 0x00000002
+#define DCBX_LOCAL_APP_ERROR	 0x00000004
+#define DCBX_LOCAL_PFC_MISMATCH	 0x00000010
+#define DCBX_LOCAL_APP_MISMATCH	 0x00000020
+	struct dcbx_features   features;
+	u32 suffix_seq_num;
+};
+/***END OF DCBX STRUCTURES DECLARATIONS***/
 
 struct shmem2_region {
 
@@ -1112,7 +1361,12 @@ struct shmem2_region {
 #define SHMEM_MF_CFG_ADDR_NONE			    0x00000000
 
 	struct fw_flr_mb flr_mb;
-	u32	reserved[3];
+	u32	dcbx_lldp_params_offset;
+#define SHMEM_LLDP_DCBX_PARAMS_NONE		    0x00000000
+	u32	dcbx_neg_res_offset;
+#define SHMEM_DCBX_NEG_RES_NONE			    0x00000000
+	u32	dcbx_remote_mib_offset;
+#define SHMEM_DCBX_REMOTE_MIB_NONE		    0x00000000
 	/*
 	 * The other shmemX_base_addr holds the other path's shmem address
 	 * required for example in case of common phy init, or for path1 to know
@@ -1121,6 +1375,10 @@ struct shmem2_region {
 	 */
 	u32 other_shmem_base_addr;
 	u32 other_shmem2_base_addr;
+	u32	reserved1[E2_VF_MAX / 32];
+	u32	reserved2[E2_FUNC_MAX][E2_VF_MAX / 32];
+	u32	dcbx_lldp_dcbx_stat_offset;
+#define SHMEM_LLDP_DCBX_STAT_NONE		   0x00000000
 };
 
 
@@ -3023,6 +3281,25 @@ struct fairness_vars_per_vn {
 
 
 /*
+ * The data for flow control configuration
+ */
+struct flow_control_configuration {
+	struct priority_cos
+		traffic_type_to_priority_cos[MAX_PFC_TRAFFIC_TYPES];
+#if defined(__BIG_ENDIAN)
+	u16 reserved1;
+	u8 dcb_version;
+	u8 dcb_enabled;
+#elif defined(__LITTLE_ENDIAN)
+	u8 dcb_enabled;
+	u8 dcb_version;
+	u16 reserved1;
+#endif
+	u32 reserved2;
+};
+
+
+/*
  * FW version stored in the Xstorm RAM
  */
 struct fw_version {
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 171abf8..149f842 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -216,6 +216,7 @@ struct link_params {
 
 	u32 feature_config_flags;
 #define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED (1<<0)
+#define FEATURE_CONFIG_PFC_ENABLED		(1<<1)
 #define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY	(1<<2)
 #define FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY	(1<<3)
 	/* Will be populated during common init */
@@ -332,4 +333,43 @@ u8 bnx2x_phy_probe(struct link_params *params);
 u8 bnx2x_fan_failure_det_req(struct bnx2x *bp, u32 shmem_base,
 			     u32 shmem2_base, u8 port);
 
+/* PFC port configuration params */
+struct bnx2x_nig_brb_pfc_port_params {
+	/* NIG */
+	u32 pause_enable;
+	u32 llfc_out_en;
+	u32 llfc_enable;
+	u32 pkt_priority_to_cos;
+	u32 rx_cos0_priority_mask;
+	u32 rx_cos1_priority_mask;
+	u32 llfc_high_priority_classes;
+	u32 llfc_low_priority_classes;
+	/* BRB */
+	u32 cos0_pauseable;
+	u32 cos1_pauseable;
+};
+
+/**
+ * Used to update the PFC attributes in EMAC, BMAC, NIG and BRB
+ * when link is already up
+ */
+void bnx2x_update_pfc(struct link_params *params,
+		      struct link_vars *vars,
+		      struct bnx2x_nig_brb_pfc_port_params *pfc_params);
+
+
+/* Used to configure the ETS to disable */
+void bnx2x_ets_disabled(struct link_params *params);
+
+/* Used to configure the ETS to BW limited */
+void bnx2x_ets_bw_limit(const struct link_params *params, const u32 cos0_bw,
+						const u32 cos1_bw);
+
+/* Used to configure the ETS to strict */
+u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos);
+
+/* Read pfc statistic*/
+void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
+						 u32 pfc_frames_sent[2],
+						 u32 pfc_frames_received[2]);
 #endif /* BNX2X_LINK_H */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index c4dfb42..b472fb2 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -55,6 +55,7 @@
 #include "bnx2x_init.h"
 #include "bnx2x_init_ops.h"
 #include "bnx2x_cmn.h"
+#include "bnx2x_dcb.h"
 
 #include <linux/firmware.h>
 #include "bnx2x_fw_file_hdr.h"
@@ -3105,6 +3106,11 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 			if ((bp->port.pmf == 0) && (val & DRV_STATUS_PMF))
 				bnx2x_pmf_update(bp);
 
+			if (bp->port.pmf &&
+			    (val & DRV_STATUS_DCBX_NEGOTIATION_RESULTS))
+				/* start dcbx state machine */
+				bnx2x_dcbx_set_params(bp,
+					BNX2X_DCBX_STATE_NEG_RECEIVED);
 		} else if (attn & BNX2X_MC_ASSERT_BITS) {
 
 			BNX2X_ERR("MC assert!\n");
@@ -3724,6 +3730,15 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 						BNX2X_FP_STATE_CLOSED;
 
 			goto next_spqe;
+
+		case EVENT_RING_OPCODE_STOP_TRAFFIC:
+			DP(NETIF_MSG_IFUP, "got STOP TRAFFIC\n");
+			bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_TX_PAUSED);
+			goto next_spqe;
+		case EVENT_RING_OPCODE_START_TRAFFIC:
+			DP(NETIF_MSG_IFUP, "got START TRAFFIC\n");
+			bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_TX_RELEASED);
+			goto next_spqe;
 		}
 
 		switch (opcode | bp->state) {
@@ -4363,6 +4378,7 @@ static void bnx2x_init_internal_common(struct bnx2x *bp)
 static void bnx2x_init_internal_port(struct bnx2x *bp)
 {
 	/* port */
+	bnx2x_dcb_init_intmem_pfc(bp);
 }
 
 static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)
@@ -5488,8 +5504,10 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	 *  - SF mode: bits 3-7 are masked. only bits 0-2 are in use
 	 *  - MF mode: bit 3 is masked. bits 0-2 are in use as in SF
 	 *             bits 4-7 are used for "per vn group attention" */
-	REG_WR(bp, MISC_REG_AEU_MASK_ATTN_FUNC_0 + port*4,
-	       (IS_MF(bp) ? 0xF7 : 0x7));
+	val = IS_MF(bp) ? 0xF7 : 0x7;
+	/* Enable DCBX attention for all but E1 */
+	val |= CHIP_IS_E1(bp) ? 0 : 0x10;
+	REG_WR(bp, MISC_REG_AEU_MASK_ATTN_FUNC_0 + port*4, val);
 
 	bnx2x_init_block(bp, PXPCS_BLOCK, init_stage);
 	bnx2x_init_block(bp, EMAC0_BLOCK, init_stage);
@@ -8775,6 +8793,8 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->timer.data = (unsigned long) bp;
 	bp->timer.function = bnx2x_timer;
 
+	bnx2x_dcbx_init_params(bp);
+
 	return rc;
 }
 
-- 
1.7.1




