From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 08/14] bnxt_en: Add ethtool reset method
Date: Thu, 26 Oct 2017 11:51:26 -0400
Message-ID: <1509033092-1887-9-git-send-email-michael.chan@broadcom.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org,
        Vasundhara Volam <vasundhara-v.volam@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:56675 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932438AbdJZPvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:51:54 -0400
Received: by mail-qk0-f196.google.com with SMTP id l194so4814699qke.13
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:51:54 -0700 (PDT)
In-Reply-To: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara-v.volam@broadcom.com>

This is a firmware internal reset after driver is unloaded.

Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 37 ++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h |  2 ++
 2 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index fe93625..fc32df7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1337,7 +1337,6 @@ static int bnxt_firmware_reset(struct net_device *dev,
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FW_RESET, -1, -1);
 
-	/* TODO: Support ASAP ChiMP self-reset (e.g. upon PF driver unload) */
 	/* TODO: Address self-reset of APE/KONG/BONO/TANG or ungraceful reset */
 	/*       (e.g. when firmware isn't already running) */
 	switch (dir_type) {
@@ -1363,6 +1362,10 @@ static int bnxt_firmware_reset(struct net_device *dev,
 	case BNX_DIR_TYPE_BONO_PATCH:
 		req.embedded_proc_type = FW_RESET_REQ_EMBEDDED_PROC_TYPE_ROCE;
 		break;
+	case BNXT_FW_RESET_CHIP:
+		req.embedded_proc_type = FW_RESET_REQ_EMBEDDED_PROC_TYPE_CHIP;
+		req.selfrst_status = FW_RESET_REQ_SELFRST_STATUS_SELFRSTASAP;
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -2485,6 +2488,37 @@ static void bnxt_self_test(struct net_device *dev, struct ethtool_test *etest,
 	}
 }
 
+static int bnxt_reset(struct net_device *dev, u32 *flags)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	int rc = 0;
+
+	if (!BNXT_PF(bp)) {
+		netdev_err(dev, "Reset is not supported from a VF\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (pci_vfs_assigned(bp->pdev)) {
+		netdev_err(dev,
+			   "Reset not allowed when VFs are assigned to VMs\n");
+		return -EBUSY;
+	}
+
+	if (*flags == ETH_RESET_ALL) {
+		/* This feature is not supported in older firmware versions */
+		if (bp->hwrm_spec_code < 0x10803)
+			return -EOPNOTSUPP;
+
+		rc = bnxt_firmware_reset(dev, BNXT_FW_RESET_CHIP);
+		if (!rc)
+			netdev_info(dev, "Reset request successful. Reload driver to complete reset\n");
+	} else {
+		rc = -EINVAL;
+	}
+
+	return rc;
+}
+
 void bnxt_ethtool_init(struct bnxt *bp)
 {
 	struct hwrm_selftest_qlist_output *resp = bp->hwrm_cmd_resp_addr;
@@ -2597,4 +2631,5 @@ void bnxt_ethtool_free(struct bnxt *bp)
 	.nway_reset		= bnxt_nway_reset,
 	.set_phys_id		= bnxt_set_phys_id,
 	.self_test		= bnxt_self_test,
+	.reset			= bnxt_reset,
 };
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
index f1bc90b..ff601b4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
@@ -34,6 +34,8 @@ struct bnxt_led_cfg {
 #define BNXT_LED_DFLT_ENABLES(x)			\
 	cpu_to_le32(BNXT_LED_DFLT_ENA << (BNXT_LED_DFLT_ENA_SHIFT * (x)))
 
+#define BNXT_FW_RESET_CHIP	0xffff
+
 extern const struct ethtool_ops bnxt_ethtool_ops;
 
 u32 _bnxt_fw_to_ethtool_adv_spds(u16, u8);
-- 
1.8.3.1
