From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH resend net-next 2/3] qed: Add dcbnl support.
Date: Wed, 8 Jun 2016 06:22:11 -0400
Message-ID: <1465381332-10064-3-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1465381332-10064-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:64711 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753302AbcFHLGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 07:06:35 -0400
In-Reply-To: <1465381332-10064-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the implementation for both cee/ieee dcbnl callbacks by
using the qed query/config APIs.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 1090 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_l2.c   |    7 +
 include/linux/qed/qed_eth_if.h             |   62 ++
 3 files changed, 1159 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index e782484..d0dc28f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -9,6 +9,7 @@
 #include <linux/types.h>
 #include <asm/byteorder.h>
 #include <linux/bitops.h>
+#include <linux/dcbnl.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
@@ -18,6 +19,9 @@
 #include "qed_dcbx.h"
 #include "qed_hsi.h"
 #include "qed_sp.h"
+#ifdef CONFIG_DCB
+#include <linux/qed/qed_eth_if.h>
+#endif
 
 #define QED_DCBX_MAX_MIB_READ_TRY       (100)
 #define QED_ETH_TYPE_DEFAULT            (0)
@@ -1091,4 +1095,1090 @@ int qed_dcbx_get_config_params(struct qed_hwfn *p_hwfn,
 
 	return 0;
 }
+
+static struct qed_dcbx_get *qed_dcbnl_get_dcbx(struct qed_hwfn *hwfn,
+					       enum qed_mib_read_type type)
+{
+	struct qed_dcbx_get *dcbx_info;
+
+	dcbx_info = kmalloc(sizeof(*dcbx_info), GFP_KERNEL);
+	if (!dcbx_info) {
+		DP_ERR(hwfn->cdev, "Failed to allocate memory for dcbx_info\n");
+		return NULL;
+	}
+
+	if (qed_dcbx_query_params(hwfn, dcbx_info, type)) {
+		kfree(dcbx_info);
+		return NULL;
+	}
+
+	if ((type == QED_DCBX_OPERATIONAL_MIB) &&
+	    !dcbx_info->operational.enabled) {
+		DP_INFO(hwfn, "DCBX is not enabled/operational\n");
+		kfree(dcbx_info);
+		return NULL;
+	}
+
+	return dcbx_info;
+}
+
+static u8 qed_dcbnl_getstate(struct qed_dev *cdev)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	bool enabled;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return 0;
+
+	enabled = dcbx_info->operational.enabled;
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "DCB state = %d\n", enabled);
+	kfree(dcbx_info);
+
+	return enabled;
+}
+
+static u8 qed_dcbnl_setstate(struct qed_dev *cdev, u8 state)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "DCB state = %d\n", state);
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return 1;
+
+	dcbx_set.enabled = !!state;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return 1;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return rc ? 1 : 0;
+}
+
+static void qed_dcbnl_getpgtccfgtx(struct qed_dev *cdev, int tc, u8 *prio_type,
+				   u8 *pgid, u8 *bw_pct, u8 *up_map)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "tc = %d\n", tc);
+	*prio_type = *pgid = *bw_pct = *up_map = 0;
+	if (tc < 0 || tc >= QED_MAX_PFC_PRIORITIES) {
+		DP_INFO(hwfn, "Invalid tc %d\n", tc);
+		return;
+	}
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return;
+
+	*pgid = dcbx_info->operational.params.ets_pri_tc_tbl[tc];
+	kfree(dcbx_info);
+}
+
+static void qed_dcbnl_getpgbwgcfgtx(struct qed_dev *cdev, int pgid, u8 *bw_pct)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+
+	*bw_pct = 0;
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "pgid = %d\n", pgid);
+	if (pgid < 0 || pgid >= QED_MAX_PFC_PRIORITIES) {
+		DP_INFO(hwfn, "Invalid pgid %d\n", pgid);
+		return;
+	}
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return;
+
+	*bw_pct = dcbx_info->operational.params.ets_tc_bw_tbl[pgid];
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "bw_pct = %d\n", *bw_pct);
+	kfree(dcbx_info);
+}
+
+static void qed_dcbnl_getpgtccfgrx(struct qed_dev *cdev, int tc, u8 *prio,
+				   u8 *bwg_id, u8 *bw_pct, u8 *up_map)
+{
+	DP_INFO(QED_LEADING_HWFN(cdev), "Rx ETS is not supported\n");
+	*prio = *bwg_id = *bw_pct = *up_map = 0;
+}
+
+static void qed_dcbnl_getpgbwgcfgrx(struct qed_dev *cdev,
+				    int bwg_id, u8 *bw_pct)
+{
+	DP_INFO(QED_LEADING_HWFN(cdev), "Rx ETS is not supported\n");
+	*bw_pct = 0;
+}
+
+static void qed_dcbnl_getpfccfg(struct qed_dev *cdev,
+				int priority, u8 *setting)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "priority = %d\n", priority);
+	if (priority < 0 || priority >= QED_MAX_PFC_PRIORITIES) {
+		DP_INFO(hwfn, "Invalid priority %d\n", priority);
+		return;
+	}
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return;
+
+	*setting = dcbx_info->operational.params.pfc.prio[priority];
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "setting = %d\n", *setting);
+	kfree(dcbx_info);
+}
+
+static void qed_dcbnl_setpfccfg(struct qed_dev *cdev, int priority, u8 setting)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "priority = %d setting = %d\n",
+		   priority, setting);
+	if (priority < 0 || priority >= QED_MAX_PFC_PRIORITIES) {
+		DP_INFO(hwfn, "Invalid priority %d\n", priority);
+		return;
+	}
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return;
+
+	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_PFC_CFG;
+	dcbx_set.config.params.pfc.prio[priority] = !!setting;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+}
+
+static u8 qed_dcbnl_getcap(struct qed_dev *cdev, int capid, u8 *cap)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	int rc = 0;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "capid = %d\n", capid);
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return 1;
+
+	switch (capid) {
+	case DCB_CAP_ATTR_PG:
+	case DCB_CAP_ATTR_PFC:
+	case DCB_CAP_ATTR_UP2TC:
+	case DCB_CAP_ATTR_GSP:
+		*cap = true;
+		break;
+	case DCB_CAP_ATTR_PG_TCS:
+	case DCB_CAP_ATTR_PFC_TCS:
+		*cap = 0x80;
+		break;
+	case DCB_CAP_ATTR_DCBX:
+		*cap = (DCB_CAP_DCBX_LLD_MANAGED | DCB_CAP_DCBX_VER_CEE |
+			DCB_CAP_DCBX_VER_IEEE);
+		break;
+	default:
+		*cap = false;
+		rc = 1;
+	}
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "id = %d caps = %d\n", capid, *cap);
+	kfree(dcbx_info);
+
+	return rc;
+}
+
+static int qed_dcbnl_getnumtcs(struct qed_dev *cdev, int tcid, u8 *num)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	int rc = 0;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "tcid = %d\n", tcid);
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	switch (tcid) {
+	case DCB_NUMTCS_ATTR_PG:
+		*num = dcbx_info->operational.params.max_ets_tc;
+		break;
+	case DCB_NUMTCS_ATTR_PFC:
+		*num = dcbx_info->operational.params.pfc.max_tc;
+		break;
+	default:
+		rc = -EINVAL;
+	}
+
+	kfree(dcbx_info);
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "numtcs = %d\n", *num);
+
+	return rc;
+}
+
+static u8 qed_dcbnl_getpfcstate(struct qed_dev *cdev)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	bool enabled;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return 0;
+
+	enabled = dcbx_info->operational.params.pfc.enabled;
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "pfc state = %d\n", enabled);
+	kfree(dcbx_info);
+
+	return enabled;
+}
+
+static u8 qed_dcbnl_getdcbx(struct qed_dev *cdev)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	u8 mode = 0;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return 0;
+
+	if (dcbx_info->operational.enabled)
+		mode |= DCB_CAP_DCBX_LLD_MANAGED;
+	if (dcbx_info->operational.ieee)
+		mode |= DCB_CAP_DCBX_VER_IEEE;
+	if (dcbx_info->operational.cee)
+		mode |= DCB_CAP_DCBX_VER_CEE;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "dcb mode = %d\n", mode);
+	kfree(dcbx_info);
+
+	return mode;
+}
+
+static void qed_dcbnl_setpgtccfgtx(struct qed_dev *cdev,
+				   int tc,
+				   u8 pri_type, u8 pgid, u8 bw_pct, u8 up_map)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB,
+		   "tc = %d pri_type = %d pgid = %d bw_pct = %d up_map = %d\n",
+		   tc, pri_type, pgid, bw_pct, up_map);
+
+	if (tc < 0 || tc >= QED_MAX_PFC_PRIORITIES) {
+		DP_INFO(hwfn, "Invalid tc %d\n", tc);
+		return;
+	}
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return;
+
+	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_ETS_CFG;
+	dcbx_set.config.params.ets_pri_tc_tbl[tc] = pgid;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+}
+
+static void qed_dcbnl_setpgtccfgrx(struct qed_dev *cdev, int prio,
+				   u8 pri_type, u8 pgid, u8 bw_pct, u8 up_map)
+{
+	DP_INFO(QED_LEADING_HWFN(cdev), "Rx ETS is not supported\n");
+}
+
+static void qed_dcbnl_setpgbwgcfgtx(struct qed_dev *cdev, int pgid, u8 bw_pct)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "pgid = %d bw_pct = %d\n", pgid, bw_pct);
+	if (pgid < 0 || pgid >= QED_MAX_PFC_PRIORITIES) {
+		DP_INFO(hwfn, "Invalid pgid %d\n", pgid);
+		return;
+	}
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return;
+
+	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_ETS_CFG;
+	dcbx_set.config.params.ets_tc_bw_tbl[pgid] = bw_pct;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+}
+
+static void qed_dcbnl_setpgbwgcfgrx(struct qed_dev *cdev, int pgid, u8 bw_pct)
+{
+	DP_INFO(QED_LEADING_HWFN(cdev), "Rx ETS is not supported\n");
+}
+
+static u8 qed_dcbnl_setall(struct qed_dev *cdev)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return 1;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return 1;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 1);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return rc;
+}
+
+static int qed_dcbnl_setnumtcs(struct qed_dev *cdev, int tcid, u8 num)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "tcid = %d num = %d\n", tcid, num);
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return 1;
+
+	switch (tcid) {
+	case DCB_NUMTCS_ATTR_PG:
+		dcbx_set.override_flags |= QED_DCBX_OVERRIDE_ETS_CFG;
+		dcbx_set.config.params.max_ets_tc = num;
+		break;
+	case DCB_NUMTCS_ATTR_PFC:
+		dcbx_set.override_flags |= QED_DCBX_OVERRIDE_PFC_CFG;
+		dcbx_set.config.params.pfc.max_tc = num;
+		break;
+	default:
+		DP_INFO(hwfn, "Invalid tcid %d\n", tcid);
+		return -EINVAL;
+	}
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return -EINVAL;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return 0;
+}
+
+static void qed_dcbnl_setpfcstate(struct qed_dev *cdev, u8 state)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "new state = %d\n", state);
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return;
+
+	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_PFC_CFG;
+	dcbx_set.config.params.pfc.enabled = !!state;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+}
+
+static int qed_dcbnl_getapp(struct qed_dev *cdev, u8 idtype, u16 idval)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	struct qed_app_entry *entry;
+	bool ethtype;
+	u8 prio = 0;
+	int i;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	ethtype = !!(idtype == DCB_APP_IDTYPE_ETHTYPE);
+	for (i = 0; i < QED_DCBX_MAX_APP_PROTOCOL; i++) {
+		entry = &dcbx_info->operational.params.app_entry[i];
+		if ((entry->ethtype == ethtype) && (entry->proto_id == idval)) {
+			prio = entry->prio;
+			break;
+		}
+	}
+
+	if (i == QED_DCBX_MAX_APP_PROTOCOL) {
+		DP_ERR(cdev, "App entry (%d, %d) not found\n", idtype, idval);
+		kfree(dcbx_info);
+		return -EINVAL;
+	}
+
+	kfree(dcbx_info);
+
+	return prio;
+}
+
+static int qed_dcbnl_setapp(struct qed_dev *cdev,
+			    u8 idtype, u16 idval, u8 pri_map)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_app_entry *entry;
+	struct qed_ptt *ptt;
+	bool ethtype;
+	int rc, i;
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return -EINVAL;
+
+	ethtype = !!(idtype == DCB_APP_IDTYPE_ETHTYPE);
+	for (i = 0; i < QED_DCBX_MAX_APP_PROTOCOL; i++) {
+		entry = &dcbx_set.config.params.app_entry[i];
+		if ((entry->ethtype == ethtype) && (entry->proto_id == idval))
+			break;
+		/* First empty slot */
+		if (!entry->proto_id)
+			break;
+	}
+
+	if (i == QED_DCBX_MAX_APP_PROTOCOL) {
+		DP_ERR(cdev, "App table is full\n");
+		return -EBUSY;
+	}
+
+	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_APP_CFG;
+	dcbx_set.config.params.app_entry[i].ethtype = ethtype;
+	dcbx_set.config.params.app_entry[i].proto_id = idval;
+	dcbx_set.config.params.app_entry[i].prio = pri_map;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return -EBUSY;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return rc;
+}
+
+static u8 qed_dcbnl_setdcbx(struct qed_dev *cdev, u8 mode)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "new mode = %x\n", mode);
+
+	if (!(mode & DCB_CAP_DCBX_VER_IEEE) && !(mode & DCB_CAP_DCBX_VER_CEE)) {
+		DP_INFO(hwfn, "Allowed mode is cee, ieee or both\n");
+		return 1;
+	}
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return 1;
+
+	dcbx_set.ver_num = 0;
+	if (mode & DCB_CAP_DCBX_VER_CEE) {
+		dcbx_set.ver_num |= DCBX_CONFIG_VERSION_CEE;
+		dcbx_set.enabled = true;
+	}
+
+	if (mode & DCB_CAP_DCBX_VER_IEEE) {
+		dcbx_set.ver_num |= DCBX_CONFIG_VERSION_IEEE;
+		dcbx_set.enabled = true;
+	}
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return 1;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return 0;
+}
+
+static u8 qed_dcbnl_getfeatcfg(struct qed_dev *cdev, int featid, u8 *flags)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "Feature id  = %d\n", featid);
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return 1;
+
+	*flags = 0;
+	switch (featid) {
+	case DCB_FEATCFG_ATTR_PG:
+		if (dcbx_info->operational.params.ets_enabled)
+			*flags = DCB_FEATCFG_ENABLE;
+		else
+			*flags = DCB_FEATCFG_ERROR;
+		break;
+	case DCB_FEATCFG_ATTR_PFC:
+		if (dcbx_info->operational.params.pfc.enabled)
+			*flags = DCB_FEATCFG_ENABLE;
+		else
+			*flags = DCB_FEATCFG_ERROR;
+		break;
+	case DCB_FEATCFG_ATTR_APP:
+		if (dcbx_info->operational.params.app_valid)
+			*flags = DCB_FEATCFG_ENABLE;
+		else
+			*flags = DCB_FEATCFG_ERROR;
+		break;
+	default:
+		DP_INFO(hwfn, "Invalid feature-ID %d\n", featid);
+		kfree(dcbx_info);
+		return 1;
+	}
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "flags = %d\n", *flags);
+	kfree(dcbx_info);
+
+	return 0;
+}
+
+static u8 qed_dcbnl_setfeatcfg(struct qed_dev *cdev, int featid, u8 flags)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_set dcbx_set;
+	bool enabled, willing;
+	struct qed_ptt *ptt;
+	int rc;
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "featid = %d flags = %d\n",
+		   featid, flags);
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return 1;
+
+	enabled = !!(flags & DCB_FEATCFG_ENABLE);
+	willing = !!(flags & DCB_FEATCFG_WILLING);
+	switch (featid) {
+	case DCB_FEATCFG_ATTR_PG:
+		dcbx_set.override_flags |= QED_DCBX_OVERRIDE_ETS_CFG;
+		dcbx_set.config.params.ets_enabled = enabled;
+		dcbx_set.config.params.ets_willing = willing;
+		break;
+	case DCB_FEATCFG_ATTR_PFC:
+		dcbx_set.override_flags |= QED_DCBX_OVERRIDE_PFC_CFG;
+		dcbx_set.config.params.pfc.enabled = enabled;
+		dcbx_set.config.params.pfc.willing = willing;
+		break;
+	case DCB_FEATCFG_ATTR_APP:
+		dcbx_set.override_flags |= QED_DCBX_OVERRIDE_APP_CFG;
+		dcbx_set.config.params.app_willing = willing;
+		break;
+	default:
+		DP_INFO(hwfn, "Invalid feature-ID %d\n", featid);
+		return 1;
+	}
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return 1;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return 0;
+}
+
+static int qed_dcbnl_peer_getappinfo(struct qed_dev *cdev,
+				     struct dcb_peer_app_info *info,
+				     u16 *app_count)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_REMOTE_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	info->willing = dcbx_info->remote.params.app_willing;
+	info->error = dcbx_info->remote.params.app_error;
+	*app_count = dcbx_info->remote.params.num_app_entries;
+	kfree(dcbx_info);
+
+	return 0;
+}
+
+static int qed_dcbnl_peer_getapptable(struct qed_dev *cdev,
+				      struct dcb_app *table)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	int i;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_REMOTE_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	for (i = 0; i < dcbx_info->remote.params.num_app_entries; i++) {
+		if (dcbx_info->remote.params.app_entry[i].ethtype)
+			table[i].selector = DCB_APP_IDTYPE_ETHTYPE;
+		else
+			table[i].selector = DCB_APP_IDTYPE_PORTNUM;
+		table[i].priority = dcbx_info->remote.params.app_entry[i].prio;
+		table[i].protocol =
+		    dcbx_info->remote.params.app_entry[i].proto_id;
+	}
+
+	kfree(dcbx_info);
+
+	return 0;
+}
+
+static int qed_dcbnl_cee_peer_getpfc(struct qed_dev *cdev, struct cee_pfc *pfc)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	int i;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_REMOTE_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++)
+		if (dcbx_info->remote.params.pfc.prio[i])
+			pfc->pfc_en |= BIT(i);
+
+	pfc->tcs_supported = dcbx_info->remote.params.pfc.max_tc;
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "pfc state = %d tcs_supported = %d\n",
+		   pfc->pfc_en, pfc->tcs_supported);
+	kfree(dcbx_info);
+
+	return 0;
+}
+
+static int qed_dcbnl_cee_peer_getpg(struct qed_dev *cdev, struct cee_pg *pg)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	int i;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_REMOTE_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	pg->willing = dcbx_info->remote.params.ets_willing;
+	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++) {
+		pg->pg_bw[i] = dcbx_info->remote.params.ets_tc_bw_tbl[i];
+		pg->prio_pg[i] = dcbx_info->remote.params.ets_pri_tc_tbl[i];
+	}
+
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "willing = %d", pg->willing);
+	kfree(dcbx_info);
+
+	return 0;
+}
+
+static int qed_dcbnl_get_ieee_pfc(struct qed_dev *cdev,
+				  struct ieee_pfc *pfc, bool remote)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_params *params;
+	struct qed_dcbx_get *dcbx_info;
+	int rc, i;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	if (!dcbx_info->operational.ieee) {
+		DP_INFO(hwfn, "DCBX is not enabled/operational in IEEE mode\n");
+		return -EINVAL;
+	}
+
+	if (remote) {
+		memset(dcbx_info, 0, sizeof(*dcbx_info));
+		rc = qed_dcbx_query_params(hwfn, dcbx_info,
+					   QED_DCBX_REMOTE_MIB);
+		if (rc) {
+			kfree(dcbx_info);
+			return -EINVAL;
+		}
+
+		params = &dcbx_info->remote.params;
+	} else {
+		params = &dcbx_info->operational.params;
+	}
+
+	pfc->pfc_cap = params->pfc.max_tc;
+	pfc->pfc_en = 0;
+	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++)
+		if (params->pfc.prio[i])
+			pfc->pfc_en |= BIT(i);
+
+	kfree(dcbx_info);
+
+	return 0;
+}
+
+static int qed_dcbnl_ieee_getpfc(struct qed_dev *cdev, struct ieee_pfc *pfc)
+{
+	return qed_dcbnl_get_ieee_pfc(cdev, pfc, false);
+}
+
+static int qed_dcbnl_ieee_setpfc(struct qed_dev *cdev, struct ieee_pfc *pfc)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc, i;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	if (!dcbx_info->operational.ieee) {
+		DP_INFO(hwfn, "DCBX is not enabled/operational in IEEE mode\n");
+		kfree(dcbx_info);
+		return -EINVAL;
+	}
+
+	kfree(dcbx_info);
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return -EINVAL;
+
+	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_PFC_CFG;
+	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++)
+		dcbx_set.config.params.pfc.prio[i] = !!(pfc->pfc_en & BIT(i));
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return -EINVAL;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return rc;
+}
+
+static int qed_dcbnl_get_ieee_ets(struct qed_dev *cdev,
+				  struct ieee_ets *ets, bool remote)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	struct qed_dcbx_params *params;
+	int rc;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	if (!dcbx_info->operational.ieee) {
+		DP_INFO(hwfn, "DCBX is not enabled/operational in IEEE mode\n");
+		kfree(dcbx_info);
+		return -EINVAL;
+	}
+
+	if (remote) {
+		memset(dcbx_info, 0, sizeof(*dcbx_info));
+		rc = qed_dcbx_query_params(hwfn, dcbx_info,
+					   QED_DCBX_REMOTE_MIB);
+		if (rc) {
+			kfree(dcbx_info);
+			return -EINVAL;
+		}
+
+		params = &dcbx_info->remote.params;
+	} else {
+		params = &dcbx_info->operational.params;
+	}
+
+	ets->ets_cap = params->max_ets_tc;
+	ets->willing = params->ets_willing;
+	ets->cbs = params->ets_cbs;
+	memcpy(ets->tc_tx_bw, params->ets_tc_bw_tbl, sizeof(ets->tc_tx_bw));
+	memcpy(ets->tc_tsa, params->ets_tc_tsa_tbl, sizeof(ets->tc_tsa));
+	memcpy(ets->prio_tc, params->ets_pri_tc_tbl, sizeof(ets->prio_tc));
+	kfree(dcbx_info);
+
+	return 0;
+}
+
+static int qed_dcbnl_ieee_getets(struct qed_dev *cdev, struct ieee_ets *ets)
+{
+	return qed_dcbnl_get_ieee_ets(cdev, ets, false);
+}
+
+static int qed_dcbnl_ieee_setets(struct qed_dev *cdev, struct ieee_ets *ets)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	struct qed_dcbx_set dcbx_set;
+	struct qed_ptt *ptt;
+	int rc;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	if (!dcbx_info->operational.ieee) {
+		DP_INFO(hwfn, "DCBX is not enabled/operational in IEEE mode\n");
+		kfree(dcbx_info);
+		return -EINVAL;
+	}
+
+	kfree(dcbx_info);
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return -EINVAL;
+
+	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_ETS_CFG;
+	dcbx_set.config.params.max_ets_tc = ets->ets_cap;
+	dcbx_set.config.params.ets_willing = ets->willing;
+	dcbx_set.config.params.ets_cbs = ets->cbs;
+	memcpy(dcbx_set.config.params.ets_tc_bw_tbl, ets->tc_tx_bw,
+	       sizeof(ets->tc_tx_bw));
+	memcpy(dcbx_set.config.params.ets_tc_tsa_tbl, ets->tc_tsa,
+	       sizeof(ets->tc_tsa));
+	memcpy(dcbx_set.config.params.ets_pri_tc_tbl, ets->prio_tc,
+	       sizeof(ets->prio_tc));
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return -EINVAL;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return rc;
+}
+
+int qed_dcbnl_ieee_peer_getets(struct qed_dev *cdev, struct ieee_ets *ets)
+{
+	return qed_dcbnl_get_ieee_ets(cdev, ets, true);
+}
+
+int qed_dcbnl_ieee_peer_getpfc(struct qed_dev *cdev, struct ieee_pfc *pfc)
+{
+	return qed_dcbnl_get_ieee_pfc(cdev, pfc, true);
+}
+
+int qed_dcbnl_ieee_getapp(struct qed_dev *cdev, struct dcb_app *app)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	struct qed_app_entry *entry;
+	bool ethtype;
+	u8 prio = 0;
+	int i;
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	if (!dcbx_info->operational.ieee) {
+		DP_INFO(hwfn, "DCBX is not enabled/operational in IEEE mode\n");
+		kfree(dcbx_info);
+		return -EINVAL;
+	}
+
+	/* ieee defines the selector field value for ethertype to be 1 */
+	ethtype = !!((app->selector - 1) == DCB_APP_IDTYPE_ETHTYPE);
+	for (i = 0; i < QED_DCBX_MAX_APP_PROTOCOL; i++) {
+		entry = &dcbx_info->operational.params.app_entry[i];
+		if ((entry->ethtype == ethtype) &&
+		    (entry->proto_id == app->protocol)) {
+			prio = entry->prio;
+			break;
+		}
+	}
+
+	if (i == QED_DCBX_MAX_APP_PROTOCOL) {
+		DP_ERR(cdev, "App entry (%d, %d) not found\n", app->selector,
+		       app->protocol);
+		kfree(dcbx_info);
+		return -EINVAL;
+	}
+
+	app->priority = ffs(prio) - 1;
+
+	kfree(dcbx_info);
+
+	return 0;
+}
+
+int qed_dcbnl_ieee_setapp(struct qed_dev *cdev, struct dcb_app *app)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dcbx_get *dcbx_info;
+	struct qed_dcbx_set dcbx_set;
+	struct qed_app_entry *entry;
+	struct qed_ptt *ptt;
+	bool ethtype;
+	int rc, i;
+
+	if (app->priority < 0 || app->priority >= QED_MAX_PFC_PRIORITIES) {
+		DP_INFO(hwfn, "Invalid priority %d\n", app->priority);
+		return -EINVAL;
+	}
+
+	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
+	if (!dcbx_info)
+		return -EINVAL;
+
+	if (!dcbx_info->operational.ieee) {
+		DP_INFO(hwfn, "DCBX is not enabled/operational in IEEE mode\n");
+		kfree(dcbx_info);
+		return -EINVAL;
+	}
+
+	kfree(dcbx_info);
+
+	memset(&dcbx_set, 0, sizeof(dcbx_set));
+	rc = qed_dcbx_get_config_params(hwfn, &dcbx_set);
+	if (rc)
+		return -EINVAL;
+
+	/* ieee defines the selector field value for ethertype to be 1 */
+	ethtype = !!((app->selector - 1) == DCB_APP_IDTYPE_ETHTYPE);
+	for (i = 0; i < QED_DCBX_MAX_APP_PROTOCOL; i++) {
+		entry = &dcbx_set.config.params.app_entry[i];
+		if ((entry->ethtype == ethtype) &&
+		    (entry->proto_id == app->protocol))
+			break;
+		/* First empty slot */
+		if (!entry->proto_id)
+			break;
+	}
+
+	if (i == QED_DCBX_MAX_APP_PROTOCOL) {
+		DP_ERR(cdev, "App table is full\n");
+		return -EBUSY;
+	}
+
+	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_APP_CFG;
+	dcbx_set.config.params.app_entry[i].ethtype = ethtype;
+	dcbx_set.config.params.app_entry[i].proto_id = app->protocol;
+	dcbx_set.config.params.app_entry[i].prio = BIT(app->priority);
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return -EBUSY;
+
+	rc = qed_dcbx_config_params(hwfn, ptt, &dcbx_set, 0);
+
+	qed_ptt_release(hwfn, ptt);
+
+	return rc;
+}
+
+const struct qed_eth_dcbnl_ops qed_dcbnl_ops_pass = {
+	.getstate = qed_dcbnl_getstate,
+	.setstate = qed_dcbnl_setstate,
+	.getpgtccfgtx = qed_dcbnl_getpgtccfgtx,
+	.getpgbwgcfgtx = qed_dcbnl_getpgbwgcfgtx,
+	.getpgtccfgrx = qed_dcbnl_getpgtccfgrx,
+	.getpgbwgcfgrx = qed_dcbnl_getpgbwgcfgrx,
+	.getpfccfg = qed_dcbnl_getpfccfg,
+	.setpfccfg = qed_dcbnl_setpfccfg,
+	.getcap = qed_dcbnl_getcap,
+	.getnumtcs = qed_dcbnl_getnumtcs,
+	.getpfcstate = qed_dcbnl_getpfcstate,
+	.getdcbx = qed_dcbnl_getdcbx,
+	.setpgtccfgtx = qed_dcbnl_setpgtccfgtx,
+	.setpgtccfgrx = qed_dcbnl_setpgtccfgrx,
+	.setpgbwgcfgtx = qed_dcbnl_setpgbwgcfgtx,
+	.setpgbwgcfgrx = qed_dcbnl_setpgbwgcfgrx,
+	.setall = qed_dcbnl_setall,
+	.setnumtcs = qed_dcbnl_setnumtcs,
+	.setpfcstate = qed_dcbnl_setpfcstate,
+	.setapp = qed_dcbnl_setapp,
+	.setdcbx = qed_dcbnl_setdcbx,
+	.setfeatcfg = qed_dcbnl_setfeatcfg,
+	.getfeatcfg = qed_dcbnl_getfeatcfg,
+	.getapp = qed_dcbnl_getapp,
+	.peer_getappinfo = qed_dcbnl_peer_getappinfo,
+	.peer_getapptable = qed_dcbnl_peer_getapptable,
+	.cee_peer_getpfc = qed_dcbnl_cee_peer_getpfc,
+	.cee_peer_getpg = qed_dcbnl_cee_peer_getpg,
+	.ieee_getpfc = qed_dcbnl_ieee_getpfc,
+	.ieee_setpfc = qed_dcbnl_ieee_setpfc,
+	.ieee_getets = qed_dcbnl_ieee_getets,
+	.ieee_setets = qed_dcbnl_ieee_setets,
+	.ieee_peer_getpfc = qed_dcbnl_ieee_peer_getpfc,
+	.ieee_peer_getets = qed_dcbnl_ieee_peer_getets,
+	.ieee_getapp = qed_dcbnl_ieee_getapp,
+	.ieee_setapp = qed_dcbnl_ieee_setapp,
+};
+
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 2ee496e..d121a8b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -2166,11 +2166,18 @@ static int qed_fp_cqe_completion(struct qed_dev *dev,
 extern const struct qed_iov_hv_ops qed_iov_ops_pass;
 #endif
 
+#ifdef CONFIG_DCB
+extern const struct qed_eth_dcbnl_ops qed_dcbnl_ops_pass;
+#endif
+
 static const struct qed_eth_ops qed_eth_ops_pass = {
 	.common = &qed_common_ops_pass,
 #ifdef CONFIG_QED_SRIOV
 	.iov = &qed_iov_ops_pass,
 #endif
+#ifdef CONFIG_DCB
+	.dcb = &qed_dcbnl_ops_pass,
+#endif
 	.fill_dev_info = &qed_fill_eth_dev_info,
 	.register_ops = &qed_register_eth_ops,
 	.check_mac = &qed_check_mac,
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index f8ff711..71d523b 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -128,11 +128,73 @@ struct qed_eth_cb_ops {
 	void (*force_mac) (void *dev, u8 *mac);
 };
 
+#ifdef CONFIG_DCB
+/* Prototype declaration of qed_eth_dcbnl_ops should match with the declaration
+ * of dcbnl_rtnl_ops structure.
+ */
+struct qed_eth_dcbnl_ops {
+	/* IEEE 802.1Qaz std */
+	int (*ieee_getpfc)(struct qed_dev *cdev, struct ieee_pfc *pfc);
+	int (*ieee_setpfc)(struct qed_dev *cdev, struct ieee_pfc *pfc);
+	int (*ieee_getets)(struct qed_dev *cdev, struct ieee_ets *ets);
+	int (*ieee_setets)(struct qed_dev *cdev, struct ieee_ets *ets);
+	int (*ieee_peer_getets)(struct qed_dev *cdev, struct ieee_ets *ets);
+	int (*ieee_peer_getpfc)(struct qed_dev *cdev, struct ieee_pfc *pfc);
+	int (*ieee_getapp)(struct qed_dev *cdev, struct dcb_app *app);
+	int (*ieee_setapp)(struct qed_dev *cdev, struct dcb_app *app);
+
+	/* CEE std */
+	u8 (*getstate)(struct qed_dev *cdev);
+	u8 (*setstate)(struct qed_dev *cdev, u8 state);
+	void (*getpgtccfgtx)(struct qed_dev *cdev, int prio, u8 *prio_type,
+			     u8 *pgid, u8 *bw_pct, u8 *up_map);
+	void (*getpgbwgcfgtx)(struct qed_dev *cdev, int pgid, u8 *bw_pct);
+	void (*getpgtccfgrx)(struct qed_dev *cdev, int prio, u8 *prio_type,
+			     u8 *pgid, u8 *bw_pct, u8 *up_map);
+	void (*getpgbwgcfgrx)(struct qed_dev *cdev, int pgid, u8 *bw_pct);
+	void (*getpfccfg)(struct qed_dev *cdev, int prio, u8 *setting);
+	void (*setpfccfg)(struct qed_dev *cdev, int prio, u8 setting);
+	u8 (*getcap)(struct qed_dev *cdev, int capid, u8 *cap);
+	int (*getnumtcs)(struct qed_dev *cdev, int tcid, u8 *num);
+	u8 (*getpfcstate)(struct qed_dev *cdev);
+	int (*getapp)(struct qed_dev *cdev, u8 idtype, u16 id);
+	u8 (*getfeatcfg)(struct qed_dev *cdev, int featid, u8 *flags);
+
+	/* DCBX configuration */
+	u8 (*getdcbx)(struct qed_dev *cdev);
+	void (*setpgtccfgtx)(struct qed_dev *cdev, int prio,
+			     u8 pri_type, u8 pgid, u8 bw_pct, u8 up_map);
+	void (*setpgtccfgrx)(struct qed_dev *cdev, int prio,
+			     u8 pri_type, u8 pgid, u8 bw_pct, u8 up_map);
+	void (*setpgbwgcfgtx)(struct qed_dev *cdev, int pgid, u8 bw_pct);
+	void (*setpgbwgcfgrx)(struct qed_dev *cdev, int pgid, u8 bw_pct);
+	u8 (*setall)(struct qed_dev *cdev);
+	int (*setnumtcs)(struct qed_dev *cdev, int tcid, u8 num);
+	void (*setpfcstate)(struct qed_dev *cdev, u8 state);
+	int (*setapp)(struct qed_dev *cdev, u8 idtype, u16 idval, u8 up);
+	u8 (*setdcbx)(struct qed_dev *cdev, u8 state);
+	u8 (*setfeatcfg)(struct qed_dev *cdev, int featid, u8 flags);
+
+	/* Peer apps */
+	int (*peer_getappinfo)(struct qed_dev *cdev,
+			       struct dcb_peer_app_info *info,
+			       u16 *app_count);
+	int (*peer_getapptable)(struct qed_dev *cdev, struct dcb_app *table);
+
+	/* CEE peer */
+	int (*cee_peer_getpfc)(struct qed_dev *cdev, struct cee_pfc *pfc);
+	int (*cee_peer_getpg)(struct qed_dev *cdev, struct cee_pg *pg);
+};
+#endif
+
 struct qed_eth_ops {
 	const struct qed_common_ops *common;
 #ifdef CONFIG_QED_SRIOV
 	const struct qed_iov_hv_ops *iov;
 #endif
+#ifdef CONFIG_DCB
+	const struct qed_eth_dcbnl_ops *dcb;
+#endif
 
 	int (*fill_dev_info)(struct qed_dev *cdev,
 			     struct qed_dev_eth_info *info);
-- 
1.8.3.1
