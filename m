From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/14] bnxt_en: Add function to get vnic capability.
Date: Thu, 29 Dec 2016 12:13:36 -0500
Message-ID: <1483031624-20076-7-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35439 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753320AbcL2ROF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:05 -0500
Received: by mail-pg0-f44.google.com with SMTP id i5so103581404pgh.2
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:05 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new vnic RSS capability will enhance NTUPLE support, to be added
in subsequent patches.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 22 +++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h | 34 +++++++++++++++++++++++++++
 3 files changed, 57 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 0654c3f..9168326 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3665,6 +3665,27 @@ static int bnxt_hwrm_vnic_alloc(struct bnxt *bp, u16 vnic_id,
 	return rc;
 }
 
+static int bnxt_hwrm_vnic_qcaps(struct bnxt *bp)
+{
+	struct hwrm_vnic_qcaps_output *resp = bp->hwrm_cmd_resp_addr;
+	struct hwrm_vnic_qcaps_input req = {0};
+	int rc;
+
+	if (bp->hwrm_spec_code < 0x10600)
+		return 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VNIC_QCAPS, -1, -1);
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (!rc) {
+		if (resp->flags &
+		    cpu_to_le32(VNIC_QCAPS_RESP_FLAGS_RSS_DFLT_CR_CAP))
+			bp->flags |= BNXT_FLAG_NEW_RSS_CAP;
+	}
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
 static int bnxt_hwrm_ring_grp_alloc(struct bnxt *bp)
 {
 	u16 i;
@@ -7070,6 +7091,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 				    VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV6;
 	}
 
+	bnxt_hwrm_vnic_qcaps(bp);
 	if (BNXT_PF(bp) && !BNXT_CHIP_TYPE_NITRO_A0(bp)) {
 		dev->hw_features |= NETIF_F_NTUPLE;
 		if (bnxt_rfs_capable(bp)) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 0eb6401..80bf1ab 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -944,6 +944,7 @@ struct bnxt {
 	#define BNXT_FLAG_PORT_STATS	0x400
 	#define BNXT_FLAG_UDP_RSS_CAP	0x800
 	#define BNXT_FLAG_EEE_CAP	0x1000
+	#define BNXT_FLAG_NEW_RSS_CAP	0x2000
 	#define BNXT_FLAG_ROCEV1_CAP	0x8000
 	#define BNXT_FLAG_ROCEV2_CAP	0x10000
 	#define BNXT_FLAG_ROCE_CAP	(BNXT_FLAG_ROCEV1_CAP |	\
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index 2ddfa51..d0d49ed 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -2797,6 +2797,40 @@ struct hwrm_vnic_cfg_output {
 	u8 valid;
 };
 
+/* hwrm_vnic_qcaps */
+/* Input (24 bytes) */
+struct hwrm_vnic_qcaps_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le32 enables;
+	__le32 unused_0;
+};
+
+/* Output (24 bytes) */
+struct hwrm_vnic_qcaps_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le16 mru;
+	u8 unused_0;
+	u8 unused_1;
+	__le32 flags;
+	#define VNIC_QCAPS_RESP_FLAGS_VLAN_STRIP_CAP		    0x2UL
+	#define VNIC_QCAPS_RESP_FLAGS_BD_STALL_CAP		    0x4UL
+	#define VNIC_QCAPS_RESP_FLAGS_ROCE_DUAL_VNIC_CAP	    0x8UL
+	#define VNIC_QCAPS_RESP_FLAGS_ROCE_ONLY_VNIC_CAP	    0x10UL
+	#define VNIC_QCAPS_RESP_FLAGS_RSS_DFLT_CR_CAP		    0x20UL
+	__le32 unused_2;
+	u8 unused_3;
+	u8 unused_4;
+	u8 unused_5;
+	u8 valid;
+};
+
 /* hwrm_vnic_tpa_cfg */
 /* Input (40 bytes) */
 struct hwrm_vnic_tpa_cfg_input {
-- 
1.8.3.1
