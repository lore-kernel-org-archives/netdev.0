From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 2/4] qed: Use ieee mfw-mask to get ethtype in ieee-dcbx mode.
Date: Mon, 8 Aug 2016 21:57:41 -0400
Message-ID: <1470707863-11712-3-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59014 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752479AbcHIClE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 22:41:04 -0400
In-Reply-To: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtype value is being read incorrectly in ieee-dcbx mode. Use the
correct mfw mask value.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 88 ++++++++++++++++++++----------
 drivers/net/ethernet/qlogic/qed/qed_hsi.h  |  8 +++
 2 files changed, 66 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 6869330..f07f0ac 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -52,16 +52,33 @@ static bool qed_dcbx_app_ethtype(u32 app_info_bitmap)
 		  DCBX_APP_SF_ETHTYPE);
 }
 
+static bool qed_dcbx_ieee_app_ethtype(u32 app_info_bitmap)
+{
+	u8 mfw_val = QED_MFW_GET_FIELD(app_info_bitmap, DCBX_APP_SF_IEEE);
+
+	/* Old MFW */
+	if (mfw_val == DCBX_APP_SF_IEEE_RESERVED)
+		return qed_dcbx_app_ethtype(app_info_bitmap);
+
+	return !!(mfw_val == DCBX_APP_SF_IEEE_ETHTYPE);
+}
+
 static bool qed_dcbx_app_port(u32 app_info_bitmap)
 {
 	return !!(QED_MFW_GET_FIELD(app_info_bitmap, DCBX_APP_SF) ==
 		  DCBX_APP_SF_PORT);
 }
 
-static bool qed_dcbx_default_tlv(u32 app_info_bitmap, u16 proto_id)
+static bool qed_dcbx_default_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 {
-	return !!(qed_dcbx_app_ethtype(app_info_bitmap) &&
-		  proto_id == QED_ETH_TYPE_DEFAULT);
+	bool ethtype;
+
+	if (ieee)
+		ethtype = qed_dcbx_ieee_app_ethtype(app_info_bitmap);
+	else
+		ethtype = qed_dcbx_app_ethtype(app_info_bitmap);
+
+	return !!(ethtype && (proto_id == QED_ETH_TYPE_DEFAULT));
 }
 
 static bool qed_dcbx_iscsi_tlv(u32 app_info_bitmap, u16 proto_id)
@@ -70,16 +87,28 @@ static bool qed_dcbx_iscsi_tlv(u32 app_info_bitmap, u16 proto_id)
 		  proto_id == QED_TCP_PORT_ISCSI);
 }
 
-static bool qed_dcbx_fcoe_tlv(u32 app_info_bitmap, u16 proto_id)
+static bool qed_dcbx_fcoe_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 {
-	return !!(qed_dcbx_app_ethtype(app_info_bitmap) &&
-		  proto_id == QED_ETH_TYPE_FCOE);
+	bool ethtype;
+
+	if (ieee)
+		ethtype = qed_dcbx_ieee_app_ethtype(app_info_bitmap);
+	else
+		ethtype = qed_dcbx_app_ethtype(app_info_bitmap);
+
+	return !!(ethtype && (proto_id == QED_ETH_TYPE_FCOE));
 }
 
-static bool qed_dcbx_roce_tlv(u32 app_info_bitmap, u16 proto_id)
+static bool qed_dcbx_roce_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 {
-	return !!(qed_dcbx_app_ethtype(app_info_bitmap) &&
-		  proto_id == QED_ETH_TYPE_ROCE);
+	bool ethtype;
+
+	if (ieee)
+		ethtype = qed_dcbx_ieee_app_ethtype(app_info_bitmap);
+	else
+		ethtype = qed_dcbx_app_ethtype(app_info_bitmap);
+
+	return !!(ethtype && (proto_id == QED_ETH_TYPE_ROCE));
 }
 
 static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id)
@@ -164,15 +193,15 @@ qed_dcbx_update_app_info(struct qed_dcbx_results *p_data,
 static bool
 qed_dcbx_get_app_protocol_type(struct qed_hwfn *p_hwfn,
 			       u32 app_prio_bitmap,
-			       u16 id, enum dcbx_protocol_type *type)
+			       u16 id, enum dcbx_protocol_type *type, bool ieee)
 {
-	if (qed_dcbx_fcoe_tlv(app_prio_bitmap, id)) {
+	if (qed_dcbx_fcoe_tlv(app_prio_bitmap, id, ieee)) {
 		*type = DCBX_PROTOCOL_FCOE;
-	} else if (qed_dcbx_roce_tlv(app_prio_bitmap, id)) {
+	} else if (qed_dcbx_roce_tlv(app_prio_bitmap, id, ieee)) {
 		*type = DCBX_PROTOCOL_ROCE;
 	} else if (qed_dcbx_iscsi_tlv(app_prio_bitmap, id)) {
 		*type = DCBX_PROTOCOL_ISCSI;
-	} else if (qed_dcbx_default_tlv(app_prio_bitmap, id)) {
+	} else if (qed_dcbx_default_tlv(app_prio_bitmap, id, ieee)) {
 		*type = DCBX_PROTOCOL_ETH;
 	} else if (qed_dcbx_roce_v2_tlv(app_prio_bitmap, id)) {
 		*type = DCBX_PROTOCOL_ROCE_V2;
@@ -194,17 +223,18 @@ static int
 qed_dcbx_process_tlv(struct qed_hwfn *p_hwfn,
 		     struct qed_dcbx_results *p_data,
 		     struct dcbx_app_priority_entry *p_tbl,
-		     u32 pri_tc_tbl, int count, bool dcbx_enabled)
+		     u32 pri_tc_tbl, int count, u8 dcbx_version)
 {
 	u8 tc, priority_map;
 	enum dcbx_protocol_type type;
+	bool enable, ieee;
 	u16 protocol_id;
 	int priority;
-	bool enable;
 	int i;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_DCB, "Num APP entries = %d\n", count);
 
+	ieee = (dcbx_version == DCBX_CONFIG_VERSION_IEEE);
 	/* Parse APP TLV */
 	for (i = 0; i < count; i++) {
 		protocol_id = QED_MFW_GET_FIELD(p_tbl[i].entry,
@@ -219,7 +249,7 @@ qed_dcbx_process_tlv(struct qed_hwfn *p_hwfn,
 
 		tc = QED_DCBX_PRIO2TC(pri_tc_tbl, priority);
 		if (qed_dcbx_get_app_protocol_type(p_hwfn, p_tbl[i].entry,
-						   protocol_id, &type)) {
+						   protocol_id, &type, ieee)) {
 			/* ETH always have the enable bit reset, as it gets
 			 * vlan information per packet. For other protocols,
 			 * should be set according to the dcbx_enabled
@@ -275,15 +305,12 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 	struct dcbx_ets_feature *p_ets;
 	struct qed_hw_info *p_info;
 	u32 pri_tc_tbl, flags;
-	bool dcbx_enabled;
+	u8 dcbx_version;
 	int num_entries;
 	int rc = 0;
 
-	/* If DCBx version is non zero, then negotiation was
-	 * successfuly performed
-	 */
 	flags = p_hwfn->p_dcbx_info->operational.flags;
-	dcbx_enabled = !!QED_MFW_GET_FIELD(flags, DCBX_CONFIG_VERSION);
+	dcbx_version = QED_MFW_GET_FIELD(flags, DCBX_CONFIG_VERSION);
 
 	p_app = &p_hwfn->p_dcbx_info->operational.features.app;
 	p_tbl = p_app->app_pri_tbl;
@@ -295,13 +322,13 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 	num_entries = QED_MFW_GET_FIELD(p_app->flags, DCBX_APP_NUM_ENTRIES);
 
 	rc = qed_dcbx_process_tlv(p_hwfn, &data, p_tbl, pri_tc_tbl,
-				  num_entries, dcbx_enabled);
+				  num_entries, dcbx_version);
 	if (rc)
 		return rc;
 
 	p_info->num_tc = QED_MFW_GET_FIELD(p_ets->flags, DCBX_ETS_MAX_TCS);
 	data.pf_id = p_hwfn->rel_pf_id;
-	data.dcbx_enabled = dcbx_enabled;
+	data.dcbx_enabled = !!dcbx_version;
 
 	qed_dcbx_dp_protocol(p_hwfn, &data);
 
@@ -400,7 +427,7 @@ static void
 qed_dcbx_get_app_data(struct qed_hwfn *p_hwfn,
 		      struct dcbx_app_priority_feature *p_app,
 		      struct dcbx_app_priority_entry *p_tbl,
-		      struct qed_dcbx_params *p_params)
+		      struct qed_dcbx_params *p_params, bool ieee)
 {
 	struct qed_app_entry *entry;
 	u8 pri_map;
@@ -422,7 +449,7 @@ qed_dcbx_get_app_data(struct qed_hwfn *p_hwfn,
 						    DCBX_APP_PROTOCOL_ID);
 		qed_dcbx_get_app_protocol_type(p_hwfn, p_tbl[i].entry,
 					       entry->proto_id,
-					       &entry->proto_type);
+					       &entry->proto_type, ieee);
 	}
 
 	DP_VERBOSE(p_hwfn, QED_MSG_DCB,
@@ -500,9 +527,9 @@ qed_dcbx_get_common_params(struct qed_hwfn *p_hwfn,
 			   struct dcbx_app_priority_feature *p_app,
 			   struct dcbx_app_priority_entry *p_tbl,
 			   struct dcbx_ets_feature *p_ets,
-			   u32 pfc, struct qed_dcbx_params *p_params)
+			   u32 pfc, struct qed_dcbx_params *p_params, bool ieee)
 {
-	qed_dcbx_get_app_data(p_hwfn, p_app, p_tbl, p_params);
+	qed_dcbx_get_app_data(p_hwfn, p_app, p_tbl, p_params, ieee);
 	qed_dcbx_get_ets_data(p_hwfn, p_ets, p_params);
 	qed_dcbx_get_pfc_data(p_hwfn, pfc, p_params);
 }
@@ -516,7 +543,7 @@ qed_dcbx_get_local_params(struct qed_hwfn *p_hwfn,
 	p_feat = &p_hwfn->p_dcbx_info->local_admin.features;
 	qed_dcbx_get_common_params(p_hwfn, &p_feat->app,
 				   p_feat->app.app_pri_tbl, &p_feat->ets,
-				   p_feat->pfc, &params->local.params);
+				   p_feat->pfc, &params->local.params, false);
 	params->local.valid = true;
 }
 
@@ -529,7 +556,7 @@ qed_dcbx_get_remote_params(struct qed_hwfn *p_hwfn,
 	p_feat = &p_hwfn->p_dcbx_info->remote.features;
 	qed_dcbx_get_common_params(p_hwfn, &p_feat->app,
 				   p_feat->app.app_pri_tbl, &p_feat->ets,
-				   p_feat->pfc, &params->remote.params);
+				   p_feat->pfc, &params->remote.params, false);
 	params->remote.valid = true;
 }
 
@@ -574,7 +601,8 @@ qed_dcbx_get_operational_params(struct qed_hwfn *p_hwfn,
 
 	qed_dcbx_get_common_params(p_hwfn, &p_feat->app,
 				   p_feat->app.app_pri_tbl, &p_feat->ets,
-				   p_feat->pfc, &params->operational.params);
+				   p_feat->pfc, &params->operational.params,
+				   p_operational->ieee);
 	qed_dcbx_get_priority_info(p_hwfn, &p_operational->app_prio, p_results);
 	err = QED_MFW_GET_FIELD(p_feat->app.flags, DCBX_APP_ERROR);
 	p_operational->err = err;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 5927840..6f9d3b8 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -6850,6 +6850,14 @@ struct dcbx_app_priority_entry {
 #define DCBX_APP_SF_SHIFT		8
 #define DCBX_APP_SF_ETHTYPE		0
 #define DCBX_APP_SF_PORT		1
+#define DCBX_APP_SF_IEEE_MASK		0x0000f000
+#define DCBX_APP_SF_IEEE_SHIFT		12
+#define DCBX_APP_SF_IEEE_RESERVED	0
+#define DCBX_APP_SF_IEEE_ETHTYPE	1
+#define DCBX_APP_SF_IEEE_TCP_PORT	2
+#define DCBX_APP_SF_IEEE_UDP_PORT	3
+#define DCBX_APP_SF_IEEE_TCP_UDP_PORT	4
+
 #define DCBX_APP_PROTOCOL_ID_MASK	0xffff0000
 #define DCBX_APP_PROTOCOL_ID_SHIFT	16
 };
-- 
1.8.3.1
