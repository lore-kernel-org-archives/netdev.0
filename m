From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 2/4] qed: Add support for query/config dcbx.
Date: Mon, 23 May 2016 05:17:41 -0400
Message-ID: <1463995063-25560-3-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1463995063-25560-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:58688 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753949AbcEWKAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 06:00:52 -0400
In-Reply-To: <1463995063-25560-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Query API reads the dcbx data from the device shared memory and return it
to the caller. The config API configures the user provided dcbx values on
the device, and initiates the dcbx negotiation with the peer.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 534 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h |  21 ++
 include/linux/qed/qed_if.h                 |  90 +++++
 3 files changed, 644 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 2685b353..0292cb9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -251,7 +251,7 @@ qed_dcbx_process_tlv(struct qed_hwfn *p_hwfn,
 		if (p_data->arr[type].update)
 			continue;
 
-		enable = (type == DCBX_PROTOCOL_ETH) ? false : dcbx_enabled;
+		enable = !(type == DCBX_PROTOCOL_ETH);
 		qed_dcbx_update_app_info(p_data, p_hwfn, enable, true,
 					 priority, tc, type);
 	}
@@ -350,6 +350,293 @@ qed_dcbx_copy_mib(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+#ifdef CONFIG_DCB
+static void
+qed_dcbx_get_priority_info(struct qed_hwfn *p_hwfn,
+			   struct qed_dcbx_app_prio *p_prio,
+			   struct qed_dcbx_results *p_results)
+{
+	u8 val;
+
+	p_prio->roce = QED_DCBX_INVALID_PRIORITY;
+	p_prio->roce_v2 = QED_DCBX_INVALID_PRIORITY;
+	p_prio->iscsi = QED_DCBX_INVALID_PRIORITY;
+	p_prio->fcoe = QED_DCBX_INVALID_PRIORITY;
+
+	if (p_results->arr[DCBX_PROTOCOL_ROCE].update &&
+	    p_results->arr[DCBX_PROTOCOL_ROCE].enable)
+		p_prio->roce = p_results->arr[DCBX_PROTOCOL_ROCE].priority;
+
+	if (p_results->arr[DCBX_PROTOCOL_ROCE_V2].update &&
+	    p_results->arr[DCBX_PROTOCOL_ROCE_V2].enable) {
+		val = p_results->arr[DCBX_PROTOCOL_ROCE_V2].priority;
+		p_prio->roce_v2 = val;
+	}
+
+	if (p_results->arr[DCBX_PROTOCOL_ISCSI].update &&
+	    p_results->arr[DCBX_PROTOCOL_ISCSI].enable)
+		p_prio->iscsi = p_results->arr[DCBX_PROTOCOL_ISCSI].priority;
+
+	if (p_results->arr[DCBX_PROTOCOL_FCOE].update &&
+	    p_results->arr[DCBX_PROTOCOL_FCOE].enable)
+		p_prio->fcoe = p_results->arr[DCBX_PROTOCOL_FCOE].priority;
+
+	if (p_results->arr[DCBX_PROTOCOL_ETH].update &&
+	    p_results->arr[DCBX_PROTOCOL_ETH].enable)
+		p_prio->eth = p_results->arr[DCBX_PROTOCOL_ETH].priority;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB,
+		   "Priorities: iscsi %d, roce %d, roce v2 %d, fcoe %d, eth %d\n",
+		   p_prio->iscsi, p_prio->roce, p_prio->roce_v2, p_prio->fcoe,
+		   p_prio->eth);
+}
+
+static void
+qed_dcbx_get_app_data(struct qed_hwfn *p_hwfn,
+		      struct dcbx_app_priority_feature *p_app,
+		      struct dcbx_app_priority_entry *p_tbl,
+		      struct qed_dcbx_params *p_params)
+{
+	struct qed_app_entry *entry;
+	u8 pri_map;
+	int i;
+
+	p_params->app_willing = QED_MFW_GET_FIELD(p_app->flags,
+						  DCBX_APP_WILLING);
+	p_params->app_valid = QED_MFW_GET_FIELD(p_app->flags, DCBX_APP_ENABLED);
+	p_params->app_error = QED_MFW_GET_FIELD(p_app->flags, DCBX_APP_ERROR);
+	p_params->num_app_entries = QED_MFW_GET_FIELD(p_app->flags,
+						      DCBX_APP_NUM_ENTRIES);
+	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
+		entry = &p_params->app_entry[i];
+		entry->ethtype = !(QED_MFW_GET_FIELD(p_tbl[i].entry,
+						     DCBX_APP_SF));
+		pri_map = QED_MFW_GET_FIELD(p_tbl[i].entry, DCBX_APP_PRI_MAP);
+		entry->prio = ffs(pri_map) - 1;
+		entry->proto_id = QED_MFW_GET_FIELD(p_tbl[i].entry,
+						    DCBX_APP_PROTOCOL_ID);
+		qed_dcbx_get_app_protocol_type(p_hwfn, p_tbl[i].entry,
+					       entry->proto_id,
+					       &entry->proto_type);
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB,
+		   "APP params: willing %d, valid %d error = %d\n",
+		   p_params->app_willing, p_params->app_valid,
+		   p_params->app_error);
+}
+
+static void
+qed_dcbx_get_pfc_data(struct qed_hwfn *p_hwfn,
+		      u32 pfc, struct qed_dcbx_params *p_params)
+{
+	u8 pfc_map;
+
+	p_params->pfc.willing = QED_MFW_GET_FIELD(pfc, DCBX_PFC_WILLING);
+	p_params->pfc.max_tc = QED_MFW_GET_FIELD(pfc, DCBX_PFC_CAPS);
+	p_params->pfc.enabled = QED_MFW_GET_FIELD(pfc, DCBX_PFC_ENABLED);
+	pfc_map = QED_MFW_GET_FIELD(pfc, DCBX_PFC_PRI_EN_BITMAP);
+	p_params->pfc.prio[0] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_0);
+	p_params->pfc.prio[1] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_1);
+	p_params->pfc.prio[2] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_2);
+	p_params->pfc.prio[3] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_3);
+	p_params->pfc.prio[4] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_4);
+	p_params->pfc.prio[5] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_5);
+	p_params->pfc.prio[6] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_6);
+	p_params->pfc.prio[7] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_7);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB,
+		   "PFC params: willing %d, pfc_bitmap %d\n",
+		   p_params->pfc.willing, pfc_map);
+}
+
+static void
+qed_dcbx_get_ets_data(struct qed_hwfn *p_hwfn,
+		      struct dcbx_ets_feature *p_ets,
+		      struct qed_dcbx_params *p_params)
+{
+	u32 bw_map[2], tsa_map[2], pri_map;
+	int i;
+
+	p_params->ets_willing = QED_MFW_GET_FIELD(p_ets->flags,
+						  DCBX_ETS_WILLING);
+	p_params->ets_enabled = QED_MFW_GET_FIELD(p_ets->flags,
+						  DCBX_ETS_ENABLED);
+	p_params->ets_cbs = QED_MFW_GET_FIELD(p_ets->flags, DCBX_ETS_CBS);
+	p_params->max_ets_tc = QED_MFW_GET_FIELD(p_ets->flags,
+						 DCBX_ETS_MAX_TCS);
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB,
+		   "ETS params: willing %d, ets_cbs %d pri_tc_tbl_0 %x max_ets_tc %d\n",
+		   p_params->ets_willing,
+		   p_params->ets_cbs,
+		   p_ets->pri_tc_tbl[0], p_params->max_ets_tc);
+
+	/* 8 bit tsa and bw data corresponding to each of the 8 TC's are
+	 * encoded in a type u32 array of size 2.
+	 */
+	bw_map[0] = be32_to_cpu(p_ets->tc_bw_tbl[0]);
+	bw_map[1] = be32_to_cpu(p_ets->tc_bw_tbl[1]);
+	tsa_map[0] = be32_to_cpu(p_ets->tc_tsa_tbl[0]);
+	tsa_map[1] = be32_to_cpu(p_ets->tc_tsa_tbl[1]);
+	pri_map = be32_to_cpu(p_ets->pri_tc_tbl[0]);
+	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++) {
+		p_params->ets_tc_bw_tbl[i] = ((u8 *)bw_map)[i];
+		p_params->ets_tc_tsa_tbl[i] = ((u8 *)tsa_map)[i];
+		p_params->ets_pri_tc_tbl[i] = QED_DCBX_PRIO2TC(pri_map, i);
+		DP_VERBOSE(p_hwfn, QED_MSG_DCB,
+			   "elem %d  bw_tbl %x tsa_tbl %x\n",
+			   i, p_params->ets_tc_bw_tbl[i],
+			   p_params->ets_tc_tsa_tbl[i]);
+	}
+}
+
+static void
+qed_dcbx_get_common_params(struct qed_hwfn *p_hwfn,
+			   struct dcbx_app_priority_feature *p_app,
+			   struct dcbx_app_priority_entry *p_tbl,
+			   struct dcbx_ets_feature *p_ets,
+			   u32 pfc, struct qed_dcbx_params *p_params)
+{
+	qed_dcbx_get_app_data(p_hwfn, p_app, p_tbl, p_params);
+	qed_dcbx_get_ets_data(p_hwfn, p_ets, p_params);
+	qed_dcbx_get_pfc_data(p_hwfn, pfc, p_params);
+}
+
+static void
+qed_dcbx_get_local_params(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt, struct qed_dcbx_get *params)
+{
+	struct dcbx_features *p_feat;
+
+	p_feat = &p_hwfn->p_dcbx_info->local_admin.features;
+	qed_dcbx_get_common_params(p_hwfn, &p_feat->app,
+				   p_feat->app.app_pri_tbl, &p_feat->ets,
+				   p_feat->pfc, &params->local.params);
+	params->local.valid = true;
+}
+
+static void
+qed_dcbx_get_remote_params(struct qed_hwfn *p_hwfn,
+			   struct qed_ptt *p_ptt, struct qed_dcbx_get *params)
+{
+	struct dcbx_features *p_feat;
+
+	p_feat = &p_hwfn->p_dcbx_info->remote.features;
+	qed_dcbx_get_common_params(p_hwfn, &p_feat->app,
+				   p_feat->app.app_pri_tbl, &p_feat->ets,
+				   p_feat->pfc, &params->remote.params);
+	params->remote.valid = true;
+}
+
+static void
+qed_dcbx_get_operational_params(struct qed_hwfn *p_hwfn,
+				struct qed_ptt *p_ptt,
+				struct qed_dcbx_get *params)
+{
+	struct qed_dcbx_operational_params *p_operational;
+	struct qed_dcbx_results *p_results;
+	struct dcbx_features *p_feat;
+	bool enabled, err;
+	u32 flags;
+	bool val;
+
+	flags = p_hwfn->p_dcbx_info->operational.flags;
+
+	/* If DCBx version is non zero, then negotiation
+	 * was successfuly performed
+	 */
+	p_operational = &params->operational;
+	enabled = !!(QED_MFW_GET_FIELD(flags, DCBX_CONFIG_VERSION) !=
+		     DCBX_CONFIG_VERSION_DISABLED);
+	if (!enabled) {
+		p_operational->enabled = enabled;
+		p_operational->valid = false;
+		return;
+	}
+
+	p_feat = &p_hwfn->p_dcbx_info->operational.features;
+	p_results = &p_hwfn->p_dcbx_info->results;
+
+	val = !!(QED_MFW_GET_FIELD(flags, DCBX_CONFIG_VERSION) ==
+		 DCBX_CONFIG_VERSION_IEEE);
+	p_operational->ieee = val;
+	val = !!(QED_MFW_GET_FIELD(flags, DCBX_CONFIG_VERSION) ==
+		 DCBX_CONFIG_VERSION_CEE);
+	p_operational->cee = val;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB, "Version support: ieee %d, cee %d\n",
+		   p_operational->ieee, p_operational->cee);
+
+	qed_dcbx_get_common_params(p_hwfn, &p_feat->app,
+				   p_feat->app.app_pri_tbl, &p_feat->ets,
+				   p_feat->pfc, &params->operational.params);
+	qed_dcbx_get_priority_info(p_hwfn, &p_operational->app_prio, p_results);
+	err = QED_MFW_GET_FIELD(p_feat->app.flags, DCBX_APP_ERROR);
+	p_operational->err = err;
+	p_operational->enabled = enabled;
+	p_operational->valid = true;
+}
+
+static void
+qed_dcbx_get_local_lldp_params(struct qed_hwfn *p_hwfn,
+			       struct qed_ptt *p_ptt,
+			       struct qed_dcbx_get *params)
+{
+	struct lldp_config_params_s *p_local;
+
+	p_local = &p_hwfn->p_dcbx_info->lldp_local[LLDP_NEAREST_BRIDGE];
+
+	memcpy(params->lldp_local.local_chassis_id, p_local->local_chassis_id,
+	       ARRAY_SIZE(p_local->local_chassis_id));
+	memcpy(params->lldp_local.local_port_id, p_local->local_port_id,
+	       ARRAY_SIZE(p_local->local_port_id));
+}
+
+static void
+qed_dcbx_get_remote_lldp_params(struct qed_hwfn *p_hwfn,
+				struct qed_ptt *p_ptt,
+				struct qed_dcbx_get *params)
+{
+	struct lldp_status_params_s *p_remote;
+
+	p_remote = &p_hwfn->p_dcbx_info->lldp_remote[LLDP_NEAREST_BRIDGE];
+
+	memcpy(params->lldp_remote.peer_chassis_id, p_remote->peer_chassis_id,
+	       ARRAY_SIZE(p_remote->peer_chassis_id));
+	memcpy(params->lldp_remote.peer_port_id, p_remote->peer_port_id,
+	       ARRAY_SIZE(p_remote->peer_port_id));
+}
+
+static int
+qed_dcbx_get_params(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+		    struct qed_dcbx_get *p_params,
+		    enum qed_mib_read_type type)
+{
+	switch (type) {
+	case QED_DCBX_REMOTE_MIB:
+		qed_dcbx_get_remote_params(p_hwfn, p_ptt, p_params);
+		break;
+	case QED_DCBX_LOCAL_MIB:
+		qed_dcbx_get_local_params(p_hwfn, p_ptt, p_params);
+		break;
+	case QED_DCBX_OPERATIONAL_MIB:
+		qed_dcbx_get_operational_params(p_hwfn, p_ptt, p_params);
+		break;
+	case QED_DCBX_REMOTE_LLDP_MIB:
+		qed_dcbx_get_remote_lldp_params(p_hwfn, p_ptt, p_params);
+		break;
+	case QED_DCBX_LOCAL_LLDP_MIB:
+		qed_dcbx_get_local_lldp_params(p_hwfn, p_ptt, p_params);
+		break;
+	default:
+		DP_ERR(p_hwfn, "MIB read err, unknown mib type %d\n", type);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+#endif
+
 static int
 qed_dcbx_read_local_lldp_mib(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
@@ -560,3 +847,248 @@ void qed_dcbx_set_pf_update_params(struct qed_dcbx_results *p_src,
 	p_dcb_data = &p_dest->eth_dcb_data;
 	qed_dcbx_update_protocol_data(p_dcb_data, p_src, DCBX_PROTOCOL_ETH);
 }
+
+#ifdef CONFIG_DCB
+static int qed_dcbx_query_params(struct qed_hwfn *p_hwfn,
+				 struct qed_dcbx_get *p_get,
+				 enum qed_mib_read_type type)
+{
+	struct qed_ptt *p_ptt;
+	int rc;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	rc = qed_dcbx_read_mib(p_hwfn, p_ptt, type);
+	if (rc)
+		goto out;
+
+	rc = qed_dcbx_get_params(p_hwfn, p_ptt, p_get, type);
+
+out:
+	qed_ptt_release(p_hwfn, p_ptt);
+	return rc;
+}
+
+static void
+qed_dcbx_set_pfc_data(struct qed_hwfn *p_hwfn,
+		      u32 *pfc, struct qed_dcbx_params *p_params)
+{
+	u8 pfc_map = 0;
+	int i;
+
+	if (p_params->pfc.willing)
+		*pfc |= DCBX_PFC_WILLING_MASK;
+	else
+		*pfc &= ~DCBX_PFC_WILLING_MASK;
+
+	if (p_params->pfc.enabled)
+		*pfc |= DCBX_PFC_ENABLED_MASK;
+	else
+		*pfc &= ~DCBX_PFC_ENABLED_MASK;
+
+	*pfc &= ~DCBX_PFC_CAPS_MASK;
+	*pfc |= (u32)p_params->pfc.max_tc << DCBX_PFC_CAPS_SHIFT;
+
+	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++)
+		if (p_params->pfc.prio[i])
+			pfc_map |= BIT(i);
+
+	*pfc |= (pfc_map << DCBX_PFC_PRI_EN_BITMAP_SHIFT);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB, "pfc = 0x%x\n", *pfc);
+}
+
+static void
+qed_dcbx_set_ets_data(struct qed_hwfn *p_hwfn,
+		      struct dcbx_ets_feature *p_ets,
+		      struct qed_dcbx_params *p_params)
+{
+	u8 *bw_map, *tsa_map;
+	u32 val;
+	int i;
+
+	if (p_params->ets_willing)
+		p_ets->flags |= DCBX_ETS_WILLING_MASK;
+	else
+		p_ets->flags &= ~DCBX_ETS_WILLING_MASK;
+
+	if (p_params->ets_cbs)
+		p_ets->flags |= DCBX_ETS_CBS_MASK;
+	else
+		p_ets->flags &= ~DCBX_ETS_CBS_MASK;
+
+	if (p_params->ets_enabled)
+		p_ets->flags |= DCBX_ETS_ENABLED_MASK;
+	else
+		p_ets->flags &= ~DCBX_ETS_ENABLED_MASK;
+
+	p_ets->flags &= ~DCBX_ETS_MAX_TCS_MASK;
+	p_ets->flags |= (u32)p_params->max_ets_tc << DCBX_ETS_MAX_TCS_SHIFT;
+
+	bw_map = (u8 *)&p_ets->tc_bw_tbl[0];
+	tsa_map = (u8 *)&p_ets->tc_tsa_tbl[0];
+	p_ets->pri_tc_tbl[0] = 0;
+	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++) {
+		bw_map[i] = p_params->ets_tc_bw_tbl[i];
+		tsa_map[i] = p_params->ets_tc_tsa_tbl[i];
+		/* Copy the priority value to the corresponding 4 bits in the
+		 * traffic class table.
+		 */
+		val = (((u32)p_params->ets_pri_tc_tbl[i]) << ((7 - i) * 4));
+		p_ets->pri_tc_tbl[0] |= val;
+	}
+	p_ets->pri_tc_tbl[0] = cpu_to_be32(p_ets->pri_tc_tbl[0]);
+	for (i = 0; i < 2; i++) {
+		p_ets->tc_bw_tbl[i] = cpu_to_be32(p_ets->tc_bw_tbl[i]);
+		p_ets->tc_tsa_tbl[i] = cpu_to_be32(p_ets->tc_tsa_tbl[i]);
+	}
+}
+
+static void
+qed_dcbx_set_app_data(struct qed_hwfn *p_hwfn,
+		      struct dcbx_app_priority_feature *p_app,
+		      struct qed_dcbx_params *p_params)
+{
+	u32 *entry;
+	int i;
+
+	if (p_params->app_willing)
+		p_app->flags |= DCBX_APP_WILLING_MASK;
+	else
+		p_app->flags &= ~DCBX_APP_WILLING_MASK;
+
+	if (p_params->app_valid)
+		p_app->flags |= DCBX_APP_ENABLED_MASK;
+	else
+		p_app->flags &= ~DCBX_APP_ENABLED_MASK;
+
+	p_app->flags &= ~DCBX_APP_NUM_ENTRIES_MASK;
+	p_app->flags |= (u32)p_params->num_app_entries <<
+	    DCBX_APP_NUM_ENTRIES_SHIFT;
+
+	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
+		entry = &p_app->app_pri_tbl[i].entry;
+		*entry &= ~DCBX_APP_SF_MASK;
+		if (p_params->app_entry[i].ethtype)
+			*entry |= ((u32)DCBX_APP_SF_ETHTYPE <<
+				   DCBX_APP_SF_SHIFT);
+		else
+			*entry |= ((u32)DCBX_APP_SF_PORT << DCBX_APP_SF_SHIFT);
+		*entry &= ~DCBX_APP_PROTOCOL_ID_MASK;
+		*entry |= ((u32)p_params->app_entry[i].proto_id <<
+			   DCBX_APP_PROTOCOL_ID_SHIFT);
+		*entry &= ~DCBX_APP_PRI_MAP_MASK;
+		*entry |= ((u32)(p_params->app_entry[i].prio) <<
+			   DCBX_APP_PRI_MAP_SHIFT);
+	}
+}
+
+static void
+qed_dcbx_set_local_params(struct qed_hwfn *p_hwfn,
+			  struct dcbx_local_params *local_admin,
+			  struct qed_dcbx_set *params)
+{
+	local_admin->flags = 0;
+	memcpy(&local_admin->features,
+	       &p_hwfn->p_dcbx_info->operational.features,
+	       sizeof(local_admin->features));
+
+	if (params->enabled)
+		local_admin->config = params->ver_num;
+	else
+		local_admin->config = DCBX_CONFIG_VERSION_DISABLED;
+
+	if (params->override_flags & QED_DCBX_OVERRIDE_PFC_CFG)
+		qed_dcbx_set_pfc_data(p_hwfn, &local_admin->features.pfc,
+				      &params->config.params);
+
+	if (params->override_flags & QED_DCBX_OVERRIDE_ETS_CFG)
+		qed_dcbx_set_ets_data(p_hwfn, &local_admin->features.ets,
+				      &params->config.params);
+
+	if (params->override_flags & QED_DCBX_OVERRIDE_APP_CFG)
+		qed_dcbx_set_app_data(p_hwfn, &local_admin->features.app,
+				      &params->config.params);
+}
+
+static int qed_dcbx_config_params(struct qed_hwfn *p_hwfn,
+				  struct qed_ptt *p_ptt,
+				  struct qed_dcbx_set *params, bool hw_commit)
+{
+	struct dcbx_local_params local_admin;
+	struct qed_dcbx_mib_meta_data data;
+	u32 resp = 0, param = 0;
+	int rc = 0;
+
+	if (!hw_commit) {
+		memcpy(&p_hwfn->p_dcbx_info->set, params,
+		       sizeof(struct qed_dcbx_set));
+		return 0;
+	}
+
+	/* clear set-parmas cache */
+	memset(&p_hwfn->p_dcbx_info->set, 0, sizeof(p_hwfn->p_dcbx_info->set));
+
+	memset(&local_admin, 0, sizeof(local_admin));
+	qed_dcbx_set_local_params(p_hwfn, &local_admin, params);
+
+	data.addr = p_hwfn->mcp_info->port_addr +
+	    offsetof(struct public_port, local_admin_dcbx_mib);
+	data.local_admin = &local_admin;
+	data.size = sizeof(struct dcbx_local_params);
+	qed_memcpy_to(p_hwfn, p_ptt, data.addr, data.local_admin, data.size);
+
+	rc = qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_SET_DCBX,
+			 1 << DRV_MB_PARAM_LLDP_SEND_SHIFT, &resp, &param);
+	if (rc)
+		DP_NOTICE(p_hwfn, "Failed to send DCBX update request\n");
+
+	return rc;
+}
+
+static int qed_dcbx_get_config_params(struct qed_hwfn *p_hwfn,
+				      struct qed_dcbx_set *params)
+{
+	struct qed_dcbx_get *dcbx_info;
+	int rc;
+
+	if (p_hwfn->p_dcbx_info->set.config.valid) {
+		memcpy(params, &p_hwfn->p_dcbx_info->set,
+		       sizeof(struct qed_dcbx_set));
+		return 0;
+	}
+
+	dcbx_info = kmalloc(sizeof(*dcbx_info), GFP_KERNEL);
+	if (!dcbx_info) {
+		DP_ERR(p_hwfn, "Failed to allocate struct qed_dcbx_info\n");
+		return -ENOMEM;
+	}
+
+	rc = qed_dcbx_query_params(p_hwfn, dcbx_info, QED_DCBX_OPERATIONAL_MIB);
+	if (rc) {
+		kfree(dcbx_info);
+		return rc;
+	}
+
+	p_hwfn->p_dcbx_info->set.override_flags = 0;
+	p_hwfn->p_dcbx_info->set.ver_num = DCBX_CONFIG_VERSION_DISABLED;
+	if (dcbx_info->operational.cee)
+		p_hwfn->p_dcbx_info->set.ver_num |= DCBX_CONFIG_VERSION_CEE;
+	if (dcbx_info->operational.ieee)
+		p_hwfn->p_dcbx_info->set.ver_num |= DCBX_CONFIG_VERSION_IEEE;
+
+	p_hwfn->p_dcbx_info->set.enabled = dcbx_info->operational.enabled;
+	memcpy(&p_hwfn->p_dcbx_info->set.config.params,
+	       &dcbx_info->operational.params,
+	       sizeof(struct qed_dcbx_admin_params));
+	p_hwfn->p_dcbx_info->set.config.valid = true;
+
+	memcpy(params, &p_hwfn->p_dcbx_info->set, sizeof(struct qed_dcbx_set));
+
+	kfree(dcbx_info);
+
+	return 0;
+}
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
index e7f834d..1746ad7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
@@ -33,6 +33,24 @@ struct qed_dcbx_app_data {
 	u8 tc;			/* Traffic Class */
 };
 
+#ifdef CONFIG_DCB
+#define QED_DCBX_VERSION_DISABLED       0
+#define QED_DCBX_VERSION_IEEE           1
+#define QED_DCBX_VERSION_CEE            2
+
+struct qed_dcbx_set {
+#define QED_DCBX_OVERRIDE_STATE	        BIT(0)
+#define QED_DCBX_OVERRIDE_PFC_CFG       BIT(1)
+#define QED_DCBX_OVERRIDE_ETS_CFG       BIT(2)
+#define QED_DCBX_OVERRIDE_APP_CFG       BIT(3)
+#define QED_DCBX_OVERRIDE_DSCP_CFG      BIT(4)
+	u32 override_flags;
+	bool enabled;
+	struct qed_dcbx_admin_params config;
+	u32 ver_num;
+};
+#endif
+
 struct qed_dcbx_results {
 	bool dcbx_enabled;
 	u8 pf_id;
@@ -55,6 +73,9 @@ struct qed_dcbx_info {
 	struct qed_dcbx_results results;
 	struct dcbx_mib operational;
 	struct dcbx_mib remote;
+#ifdef CONFIG_DCB
+	struct qed_dcbx_set set;
+#endif
 	u8 dcbx_cap;
 };
 
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 4c29439..75818c5 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -34,6 +34,96 @@ enum dcbx_protocol_type {
 	DCBX_MAX_PROTOCOL_TYPE
 };
 
+#ifdef CONFIG_DCB
+#define QED_LLDP_CHASSIS_ID_STAT_LEN 4
+#define QED_LLDP_PORT_ID_STAT_LEN 4
+#define QED_DCBX_MAX_APP_PROTOCOL 32
+#define QED_MAX_PFC_PRIORITIES 8
+#define QED_DCBX_DSCP_SIZE 64
+
+struct qed_dcbx_lldp_remote {
+	u32 peer_chassis_id[QED_LLDP_CHASSIS_ID_STAT_LEN];
+	u32 peer_port_id[QED_LLDP_PORT_ID_STAT_LEN];
+	bool enable_rx;
+	bool enable_tx;
+	u32 tx_interval;
+	u32 max_credit;
+};
+
+struct qed_dcbx_lldp_local {
+	u32 local_chassis_id[QED_LLDP_CHASSIS_ID_STAT_LEN];
+	u32 local_port_id[QED_LLDP_PORT_ID_STAT_LEN];
+};
+
+struct qed_dcbx_app_prio {
+	u8 roce;
+	u8 roce_v2;
+	u8 fcoe;
+	u8 iscsi;
+	u8 eth;
+};
+
+struct qed_dbcx_pfc_params {
+	bool willing;
+	bool enabled;
+	u8 prio[QED_MAX_PFC_PRIORITIES];
+	u8 max_tc;
+};
+
+struct qed_app_entry {
+	bool ethtype;
+	bool enabled;
+	u8 prio;
+	u16 proto_id;
+	enum dcbx_protocol_type proto_type;
+};
+
+struct qed_dcbx_params {
+	struct qed_app_entry app_entry[QED_DCBX_MAX_APP_PROTOCOL];
+	u16 num_app_entries;
+	bool app_willing;
+	bool app_valid;
+	bool app_error;
+	bool ets_willing;
+	bool ets_enabled;
+	bool ets_cbs;
+	bool valid;
+	u8 ets_pri_tc_tbl[QED_MAX_PFC_PRIORITIES];
+	u8 ets_tc_bw_tbl[QED_MAX_PFC_PRIORITIES];
+	u8 ets_tc_tsa_tbl[QED_MAX_PFC_PRIORITIES];
+	struct qed_dbcx_pfc_params pfc;
+	u8 max_ets_tc;
+};
+
+struct qed_dcbx_admin_params {
+	struct qed_dcbx_params params;
+	bool valid;
+};
+
+struct qed_dcbx_remote_params {
+	struct qed_dcbx_params params;
+	bool valid;
+};
+
+struct qed_dcbx_operational_params {
+	struct qed_dcbx_app_prio app_prio;
+	struct qed_dcbx_params params;
+	bool valid;
+	bool enabled;
+	bool ieee;
+	bool cee;
+	u32 err;
+};
+
+struct qed_dcbx_get {
+	struct qed_dcbx_operational_params operational;
+	struct qed_dcbx_lldp_remote lldp_remote;
+	struct qed_dcbx_lldp_local lldp_local;
+	struct qed_dcbx_remote_params remote;
+	struct qed_dcbx_admin_params local;
+};
+#endif
+
 enum qed_led_mode {
 	QED_LED_MODE_OFF,
 	QED_LED_MODE_ON,
-- 
1.8.3.1
