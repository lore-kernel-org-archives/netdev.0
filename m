From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 3/4] qed: Add dcbx app support for IEEE Selection Field.
Date: Mon, 8 Aug 2016 21:57:42 -0400
Message-ID: <1470707863-11712-4-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:24063 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752513AbcHIClE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 22:41:04 -0400
In-Reply-To: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MFW now supports the Selection field for IEEE mode. Add driver changes to
use the newer MFW masks to read/write the port-id value.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 124 ++++++++++++++++++++++++-----
 include/linux/qed/qed_if.h                 |   8 ++
 2 files changed, 112 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index f07f0ac..b157a6a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -69,6 +69,17 @@ static bool qed_dcbx_app_port(u32 app_info_bitmap)
 		  DCBX_APP_SF_PORT);
 }
 
+static bool qed_dcbx_ieee_app_port(u32 app_info_bitmap, u8 type)
+{
+	u8 mfw_val = QED_MFW_GET_FIELD(app_info_bitmap, DCBX_APP_SF_IEEE);
+
+	/* Old MFW */
+	if (mfw_val == DCBX_APP_SF_IEEE_RESERVED)
+		return qed_dcbx_app_port(app_info_bitmap);
+
+	return !!(mfw_val == type || mfw_val == DCBX_APP_SF_IEEE_TCP_UDP_PORT);
+}
+
 static bool qed_dcbx_default_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 {
 	bool ethtype;
@@ -81,10 +92,17 @@ static bool qed_dcbx_default_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 	return !!(ethtype && (proto_id == QED_ETH_TYPE_DEFAULT));
 }
 
-static bool qed_dcbx_iscsi_tlv(u32 app_info_bitmap, u16 proto_id)
+static bool qed_dcbx_iscsi_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 {
-	return !!(qed_dcbx_app_port(app_info_bitmap) &&
-		  proto_id == QED_TCP_PORT_ISCSI);
+	bool port;
+
+	if (ieee)
+		port = qed_dcbx_ieee_app_port(app_info_bitmap,
+					      DCBX_APP_SF_IEEE_TCP_PORT);
+	else
+		port = qed_dcbx_app_port(app_info_bitmap);
+
+	return !!(port && (proto_id == QED_TCP_PORT_ISCSI));
 }
 
 static bool qed_dcbx_fcoe_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
@@ -111,10 +129,17 @@ static bool qed_dcbx_roce_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 	return !!(ethtype && (proto_id == QED_ETH_TYPE_ROCE));
 }
 
-static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id)
+static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 {
-	return !!(qed_dcbx_app_port(app_info_bitmap) &&
-		  proto_id == QED_UDP_PORT_TYPE_ROCE_V2);
+	bool port;
+
+	if (ieee)
+		port = qed_dcbx_ieee_app_port(app_info_bitmap,
+					      DCBX_APP_SF_IEEE_UDP_PORT);
+	else
+		port = qed_dcbx_app_port(app_info_bitmap);
+
+	return !!(port && (proto_id == QED_UDP_PORT_TYPE_ROCE_V2));
 }
 
 static void
@@ -199,11 +224,11 @@ qed_dcbx_get_app_protocol_type(struct qed_hwfn *p_hwfn,
 		*type = DCBX_PROTOCOL_FCOE;
 	} else if (qed_dcbx_roce_tlv(app_prio_bitmap, id, ieee)) {
 		*type = DCBX_PROTOCOL_ROCE;
-	} else if (qed_dcbx_iscsi_tlv(app_prio_bitmap, id)) {
+	} else if (qed_dcbx_iscsi_tlv(app_prio_bitmap, id, ieee)) {
 		*type = DCBX_PROTOCOL_ISCSI;
 	} else if (qed_dcbx_default_tlv(app_prio_bitmap, id, ieee)) {
 		*type = DCBX_PROTOCOL_ETH;
-	} else if (qed_dcbx_roce_v2_tlv(app_prio_bitmap, id)) {
+	} else if (qed_dcbx_roce_v2_tlv(app_prio_bitmap, id, ieee)) {
 		*type = DCBX_PROTOCOL_ROCE_V2;
 	} else {
 		*type = DCBX_MAX_PROTOCOL_TYPE;
@@ -441,8 +466,39 @@ qed_dcbx_get_app_data(struct qed_hwfn *p_hwfn,
 						      DCBX_APP_NUM_ENTRIES);
 	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
 		entry = &p_params->app_entry[i];
-		entry->ethtype = !(QED_MFW_GET_FIELD(p_tbl[i].entry,
-						     DCBX_APP_SF));
+		if (ieee) {
+			u8 sf_ieee;
+			u32 val;
+
+			sf_ieee = QED_MFW_GET_FIELD(p_tbl[i].entry,
+						    DCBX_APP_SF_IEEE);
+			switch (sf_ieee) {
+			case DCBX_APP_SF_IEEE_RESERVED:
+				/* Old MFW */
+				val = QED_MFW_GET_FIELD(p_tbl[i].entry,
+							DCBX_APP_SF);
+				entry->sf_ieee = val ?
+				    QED_DCBX_SF_IEEE_TCP_UDP_PORT :
+				    QED_DCBX_SF_IEEE_ETHTYPE;
+				break;
+			case DCBX_APP_SF_IEEE_ETHTYPE:
+				entry->sf_ieee = QED_DCBX_SF_IEEE_ETHTYPE;
+				break;
+			case DCBX_APP_SF_IEEE_TCP_PORT:
+				entry->sf_ieee = QED_DCBX_SF_IEEE_TCP_PORT;
+				break;
+			case DCBX_APP_SF_IEEE_UDP_PORT:
+				entry->sf_ieee = QED_DCBX_SF_IEEE_UDP_PORT;
+				break;
+			case DCBX_APP_SF_IEEE_TCP_UDP_PORT:
+				entry->sf_ieee = QED_DCBX_SF_IEEE_TCP_UDP_PORT;
+				break;
+			}
+		} else {
+			entry->ethtype = !(QED_MFW_GET_FIELD(p_tbl[i].entry,
+							     DCBX_APP_SF));
+		}
+
 		pri_map = QED_MFW_GET_FIELD(p_tbl[i].entry, DCBX_APP_PRI_MAP);
 		entry->prio = ffs(pri_map) - 1;
 		entry->proto_id = QED_MFW_GET_FIELD(p_tbl[i].entry,
@@ -981,7 +1037,7 @@ qed_dcbx_set_ets_data(struct qed_hwfn *p_hwfn,
 static void
 qed_dcbx_set_app_data(struct qed_hwfn *p_hwfn,
 		      struct dcbx_app_priority_feature *p_app,
-		      struct qed_dcbx_params *p_params)
+		      struct qed_dcbx_params *p_params, bool ieee)
 {
 	u32 *entry;
 	int i;
@@ -1002,12 +1058,36 @@ qed_dcbx_set_app_data(struct qed_hwfn *p_hwfn,
 
 	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
 		entry = &p_app->app_pri_tbl[i].entry;
-		*entry &= ~DCBX_APP_SF_MASK;
-		if (p_params->app_entry[i].ethtype)
-			*entry |= ((u32)DCBX_APP_SF_ETHTYPE <<
-				   DCBX_APP_SF_SHIFT);
-		else
-			*entry |= ((u32)DCBX_APP_SF_PORT << DCBX_APP_SF_SHIFT);
+		if (ieee) {
+			*entry &= ~DCBX_APP_SF_IEEE_MASK;
+			switch (p_params->app_entry[i].sf_ieee) {
+			case QED_DCBX_SF_IEEE_ETHTYPE:
+				*entry |= ((u32)DCBX_APP_SF_IEEE_ETHTYPE <<
+					   DCBX_APP_SF_IEEE_SHIFT);
+				break;
+			case QED_DCBX_SF_IEEE_TCP_PORT:
+				*entry |= ((u32)DCBX_APP_SF_IEEE_TCP_PORT <<
+					   DCBX_APP_SF_IEEE_SHIFT);
+				break;
+			case QED_DCBX_SF_IEEE_UDP_PORT:
+				*entry |= ((u32)DCBX_APP_SF_IEEE_UDP_PORT <<
+					   DCBX_APP_SF_IEEE_SHIFT);
+				break;
+			case QED_DCBX_SF_IEEE_TCP_UDP_PORT:
+				*entry |= ((u32)DCBX_APP_SF_IEEE_TCP_UDP_PORT <<
+					   DCBX_APP_SF_IEEE_SHIFT);
+				break;
+			}
+		} else {
+			*entry &= ~DCBX_APP_SF_MASK;
+			if (p_params->app_entry[i].ethtype)
+				*entry |= ((u32)DCBX_APP_SF_ETHTYPE <<
+					   DCBX_APP_SF_SHIFT);
+			else
+				*entry |= ((u32)DCBX_APP_SF_PORT <<
+					   DCBX_APP_SF_SHIFT);
+		}
+
 		*entry &= ~DCBX_APP_PROTOCOL_ID_MASK;
 		*entry |= ((u32)p_params->app_entry[i].proto_id <<
 			   DCBX_APP_PROTOCOL_ID_SHIFT);
@@ -1022,15 +1102,19 @@ qed_dcbx_set_local_params(struct qed_hwfn *p_hwfn,
 			  struct dcbx_local_params *local_admin,
 			  struct qed_dcbx_set *params)
 {
+	bool ieee = false;
+
 	local_admin->flags = 0;
 	memcpy(&local_admin->features,
 	       &p_hwfn->p_dcbx_info->operational.features,
 	       sizeof(local_admin->features));
 
-	if (params->enabled)
+	if (params->enabled) {
 		local_admin->config = params->ver_num;
-	else
+		ieee = !!(params->ver_num & DCBX_CONFIG_VERSION_IEEE);
+	} else {
 		local_admin->config = DCBX_CONFIG_VERSION_DISABLED;
+	}
 
 	if (params->override_flags & QED_DCBX_OVERRIDE_PFC_CFG)
 		qed_dcbx_set_pfc_data(p_hwfn, &local_admin->features.pfc,
@@ -1042,7 +1126,7 @@ qed_dcbx_set_local_params(struct qed_hwfn *p_hwfn,
 
 	if (params->override_flags & QED_DCBX_OVERRIDE_APP_CFG)
 		qed_dcbx_set_app_data(p_hwfn, &local_admin->features.app,
-				      &params->config.params);
+				      &params->config.params, ieee);
 }
 
 int qed_dcbx_config_params(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index b1e3c57..d6c4177 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -70,8 +70,16 @@ struct qed_dbcx_pfc_params {
 	u8 max_tc;
 };
 
+enum qed_dcbx_sf_ieee_type {
+	QED_DCBX_SF_IEEE_ETHTYPE,
+	QED_DCBX_SF_IEEE_TCP_PORT,
+	QED_DCBX_SF_IEEE_UDP_PORT,
+	QED_DCBX_SF_IEEE_TCP_UDP_PORT
+};
+
 struct qed_app_entry {
 	bool ethtype;
+	enum qed_dcbx_sf_ieee_type sf_ieee;
 	bool enabled;
 	u8 prio;
 	u16 proto_id;
-- 
1.8.3.1
