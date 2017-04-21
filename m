From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 4/5] qed: Support dcbnl IEEE selector field.
Date: Thu, 20 Apr 2017 22:31:19 -0700
Message-ID: <20170421053120.12980-5-sudarsana.kalluru@cavium.com>
References: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0074.outbound.protection.outlook.com ([104.47.33.74]:2801
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1035630AbdDUFcL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 01:32:11 -0400
In-Reply-To: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c    | 53 ++++++++++++++++++++++-----
 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c |  5 +++
 2 files changed, 49 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 507b79d..d79831d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -2181,15 +2181,46 @@ static int qed_dcbnl_ieee_setets(struct qed_dev *cdev, struct ieee_ets *ets)
 	return qed_dcbnl_get_ieee_pfc(cdev, pfc, true);
 }
 
+static int qed_get_sf_ieee_value(u8 selector, u8 *sf_ieee)
+{
+	switch (selector) {
+	case IEEE_8021QAZ_APP_SEL_ETHERTYPE:
+		*sf_ieee = QED_DCBX_SF_IEEE_ETHTYPE;
+		break;
+	case IEEE_8021QAZ_APP_SEL_STREAM:
+		*sf_ieee = QED_DCBX_SF_IEEE_TCP_PORT;
+		break;
+	case IEEE_8021QAZ_APP_SEL_DGRAM:
+		*sf_ieee = QED_DCBX_SF_IEEE_UDP_PORT;
+		break;
+	case IEEE_8021QAZ_APP_SEL_ANY:
+		*sf_ieee = QED_DCBX_SF_IEEE_TCP_UDP_PORT;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int qed_dcbnl_ieee_getapp(struct qed_dev *cdev, struct dcb_app *app)
 {
 	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
 	struct qed_dcbx_get *dcbx_info;
 	struct qed_app_entry *entry;
-	bool ethtype;
 	u8 prio = 0;
+	u8 sf_ieee;
 	int i;
 
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "selector = %d protocol = %d\n",
+		   app->selector, app->protocol);
+
+	if (qed_get_sf_ieee_value(app->selector, &sf_ieee)) {
+		DP_INFO(cdev, "Invalid selector field value %d\n",
+			app->selector);
+		return -EINVAL;
+	}
+
 	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
 	if (!dcbx_info)
 		return -EINVAL;
@@ -2200,11 +2231,9 @@ static int qed_dcbnl_ieee_getapp(struct qed_dev *cdev, struct dcb_app *app)
 		return -EINVAL;
 	}
 
-	/* ieee defines the selector field value for ethertype to be 1 */
-	ethtype = !!((app->selector - 1) == DCB_APP_IDTYPE_ETHTYPE);
 	for (i = 0; i < QED_DCBX_MAX_APP_PROTOCOL; i++) {
 		entry = &dcbx_info->operational.params.app_entry[i];
-		if ((entry->ethtype == ethtype) &&
+		if ((entry->sf_ieee == sf_ieee) &&
 		    (entry->proto_id == app->protocol)) {
 			prio = entry->prio;
 			break;
@@ -2232,14 +2261,22 @@ static int qed_dcbnl_ieee_setapp(struct qed_dev *cdev, struct dcb_app *app)
 	struct qed_dcbx_set dcbx_set;
 	struct qed_app_entry *entry;
 	struct qed_ptt *ptt;
-	bool ethtype;
+	u8 sf_ieee;
 	int rc, i;
 
+	DP_VERBOSE(hwfn, QED_MSG_DCB, "selector = %d protocol = %d pri = %d\n",
+		   app->selector, app->protocol, app->priority);
 	if (app->priority < 0 || app->priority >= QED_MAX_PFC_PRIORITIES) {
 		DP_INFO(hwfn, "Invalid priority %d\n", app->priority);
 		return -EINVAL;
 	}
 
+	if (qed_get_sf_ieee_value(app->selector, &sf_ieee)) {
+		DP_INFO(cdev, "Invalid selector field value %d\n",
+			app->selector);
+		return -EINVAL;
+	}
+
 	dcbx_info = qed_dcbnl_get_dcbx(hwfn, QED_DCBX_OPERATIONAL_MIB);
 	if (!dcbx_info)
 		return -EINVAL;
@@ -2257,11 +2294,9 @@ static int qed_dcbnl_ieee_setapp(struct qed_dev *cdev, struct dcb_app *app)
 	if (rc)
 		return -EINVAL;
 
-	/* ieee defines the selector field value for ethertype to be 1 */
-	ethtype = !!((app->selector - 1) == DCB_APP_IDTYPE_ETHTYPE);
 	for (i = 0; i < QED_DCBX_MAX_APP_PROTOCOL; i++) {
 		entry = &dcbx_set.config.params.app_entry[i];
-		if ((entry->ethtype == ethtype) &&
+		if ((entry->sf_ieee == sf_ieee) &&
 		    (entry->proto_id == app->protocol))
 			break;
 		/* First empty slot */
@@ -2277,7 +2312,7 @@ static int qed_dcbnl_ieee_setapp(struct qed_dev *cdev, struct dcb_app *app)
 	}
 
 	dcbx_set.override_flags |= QED_DCBX_OVERRIDE_APP_CFG;
-	dcbx_set.config.params.app_entry[i].ethtype = ethtype;
+	dcbx_set.config.params.app_entry[i].sf_ieee = sf_ieee;
 	dcbx_set.config.params.app_entry[i].proto_id = app->protocol;
 	dcbx_set.config.params.app_entry[i].prio = BIT(app->priority);
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
index 03e8c02..a9e7379 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
@@ -281,6 +281,11 @@ static int qede_dcbnl_ieee_setapp(struct net_device *netdev,
 				  struct dcb_app *app)
 {
 	struct qede_dev *edev = netdev_priv(netdev);
+	int err;
+
+	err = dcb_ieee_setapp(netdev, app);
+	if (err)
+		return err;
 
 	return edev->ops->dcb->ieee_setapp(edev->cdev, app);
 }
-- 
1.8.3.1
