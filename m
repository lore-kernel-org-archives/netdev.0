From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 5/6] bnxt_en: Pass RoCE app priority to firmware.
Date: Tue, 10 Jan 2017 20:12:38 -0500
Message-ID: <1484097159-21575-6-git-send-email-michael.chan@broadcom.com>
References: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34838 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757056AbdAKBNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:13:01 -0500
Received: by mail-pf0-f179.google.com with SMTP id f144so46298801pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 17:13:00 -0800 (PST)
In-Reply-To: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver gets the RoCE app priority set/delete call through DCBNL,
the driver will send the information to the firmware.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c | 106 +++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h |   3 +
 2 files changed, 108 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
index fdf2d8c..619821b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
@@ -241,6 +241,92 @@ static int bnxt_hwrm_queue_pfc_qcfg(struct bnxt *bp, struct ieee_pfc *pfc)
 	return 0;
 }
 
+static int bnxt_hwrm_set_dcbx_app(struct bnxt *bp, struct dcb_app *app,
+				  bool add)
+{
+	struct hwrm_fw_set_structured_data_input set = {0};
+	struct hwrm_fw_get_structured_data_input get = {0};
+	struct hwrm_struct_data_dcbx_app *fw_app;
+	struct hwrm_struct_hdr *data;
+	dma_addr_t mapping;
+	size_t data_len;
+	int rc, n, i;
+
+	if (bp->hwrm_spec_code < 0x10601)
+		return 0;
+
+	n = 8;
+	data_len = sizeof(*data) + sizeof(*fw_app) * n;
+	data = dma_alloc_coherent(&bp->pdev->dev, data_len, &mapping,
+				  GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	memset(data, 0, data_len);
+	bnxt_hwrm_cmd_hdr_init(bp, &get, HWRM_FW_GET_STRUCTURED_DATA, -1, -1);
+	get.dest_data_addr = cpu_to_le64(mapping);
+	get.structure_id = cpu_to_le16(STRUCT_HDR_STRUCT_ID_DCBX_APP);
+	get.subtype = cpu_to_le16(HWRM_STRUCT_DATA_SUBTYPE_HOST_OPERATIONAL);
+	get.count = 0;
+	rc = hwrm_send_message(bp, &get, sizeof(get), HWRM_CMD_TIMEOUT);
+	if (rc)
+		goto set_app_exit;
+
+	fw_app = (struct hwrm_struct_data_dcbx_app *)(data + 1);
+
+	if (data->struct_id != cpu_to_le16(STRUCT_HDR_STRUCT_ID_DCBX_APP)) {
+		rc = -ENODEV;
+		goto set_app_exit;
+	}
+
+	n = data->count;
+	for (i = 0; i < n; i++, fw_app++) {
+		if (fw_app->protocol_id == cpu_to_be16(app->protocol) &&
+		    fw_app->protocol_selector == app->selector &&
+		    fw_app->priority == app->priority) {
+			if (add)
+				goto set_app_exit;
+			else
+				break;
+		}
+	}
+	if (add) {
+		/* append */
+		n++;
+		fw_app->protocol_id = cpu_to_be16(app->protocol);
+		fw_app->protocol_selector = app->selector;
+		fw_app->priority = app->priority;
+		fw_app->valid = 1;
+	} else {
+		size_t len = 0;
+
+		/* not found, nothing to delete */
+		if (n == i)
+			goto set_app_exit;
+
+		len = (n - 1 - i) * sizeof(*fw_app);
+		if (len)
+			memmove(fw_app, fw_app + 1, len);
+		n--;
+		memset(fw_app + n, 0, sizeof(*fw_app));
+	}
+	data->count = n;
+	data->len = cpu_to_le16(sizeof(*fw_app) * n);
+	data->subtype = cpu_to_le16(HWRM_STRUCT_DATA_SUBTYPE_HOST_OPERATIONAL);
+
+	bnxt_hwrm_cmd_hdr_init(bp, &set, HWRM_FW_SET_STRUCTURED_DATA, -1, -1);
+	set.src_data_addr = cpu_to_le64(mapping);
+	set.data_len = cpu_to_le16(sizeof(*data) + sizeof(*fw_app) * n);
+	set.hdr_cnt = 1;
+	rc = hwrm_send_message(bp, &set, sizeof(set), HWRM_CMD_TIMEOUT);
+	if (rc)
+		rc = -EIO;
+
+set_app_exit:
+	dma_free_coherent(&bp->pdev->dev, data_len, data, mapping);
+	return rc;
+}
+
 static int bnxt_ets_validate(struct bnxt *bp, struct ieee_ets *ets, u8 *tc)
 {
 	int total_ets_bw = 0;
@@ -417,6 +503,15 @@ static int bnxt_dcbnl_ieee_setapp(struct net_device *dev, struct dcb_app *app)
 		return -EINVAL;
 
 	rc = dcb_ieee_setapp(dev, app);
+	if (rc)
+		return rc;
+
+	if ((app->selector == IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
+	     app->protocol == ETH_P_ROCE) ||
+	    (app->selector == IEEE_8021QAZ_APP_SEL_DGRAM &&
+	     app->protocol == ROCE_V2_UDP_DPORT))
+		rc = bnxt_hwrm_set_dcbx_app(bp, app, true);
+
 	return rc;
 }
 
@@ -425,10 +520,19 @@ static int bnxt_dcbnl_ieee_delapp(struct net_device *dev, struct dcb_app *app)
 	struct bnxt *bp = netdev_priv(dev);
 	int rc;
 
-	if (!(bp->dcbx_cap & DCB_CAP_DCBX_VER_IEEE))
+	if (!(bp->dcbx_cap & DCB_CAP_DCBX_VER_IEEE) ||
+	    !(bp->dcbx_cap & DCB_CAP_DCBX_HOST))
 		return -EINVAL;
 
 	rc = dcb_ieee_delapp(dev, app);
+	if (rc)
+		return rc;
+	if ((app->selector == IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
+	     app->protocol == ETH_P_ROCE) ||
+	    (app->selector == IEEE_8021QAZ_APP_SEL_DGRAM &&
+	     app->protocol == ROCE_V2_UDP_DPORT))
+		rc = bnxt_hwrm_set_dcbx_app(bp, app, false);
+
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
index 35a0d28..f2630cc 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
@@ -36,6 +36,9 @@ struct bnxt_cos2bw_cfg {
 
 #define HWRM_STRUCT_DATA_SUBTYPE_HOST_OPERATIONAL	0x0300
 
+#define ETH_P_ROCE		0x8915
+#define ROCE_V2_UDP_DPORT	4791
+
 void bnxt_dcb_init(struct bnxt *bp);
 void bnxt_dcb_free(struct bnxt *bp);
 #endif
-- 
1.8.3.1
