From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 7/9] bnxt_en: Print FEC settings as part of the linkup dmesg.
Date: Sun, 12 Feb 2017 19:18:16 -0500
Message-ID: <1486945098-4086-8-git-send-email-michael.chan@broadcom.com>
References: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:37129 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdBMAS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:18:56 -0500
Received: by mail-it0-f51.google.com with SMTP id x75so22850168itb.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:18:56 -0800 (PST)
In-Reply-To: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print FEC (Forward Error Correction) autoneg and encoding settings during
link up.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 13 ++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  4 ++++
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index afd1190..9f1dfbe 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5437,7 +5437,7 @@ static void bnxt_report_link(struct bnxt *bp)
 	if (bp->link_info.link_up) {
 		const char *duplex;
 		const char *flow_ctrl;
-		u16 speed;
+		u16 speed, fec;
 
 		netif_carrier_on(bp->dev);
 		if (bp->link_info.duplex == BNXT_LINK_DUPLEX_FULL)
@@ -5459,6 +5459,12 @@ static void bnxt_report_link(struct bnxt *bp)
 			netdev_info(bp->dev, "EEE is %s\n",
 				    bp->eee.eee_active ? "active" :
 							 "not active");
+		fec = bp->link_info.fec_cfg;
+		if (!(fec & PORT_PHY_QCFG_RESP_FEC_CFG_FEC_NONE_SUPPORTED))
+			netdev_info(bp->dev, "FEC autoneg %s encodings: %s\n",
+				    (fec & BNXT_FEC_AUTONEG) ? "on" : "off",
+				    (fec & BNXT_FEC_ENC_BASE_R) ? "BaseR" :
+				     (fec & BNXT_FEC_ENC_RS) ? "RS" : "None");
 	} else {
 		netif_carrier_off(bp->dev);
 		netdev_err(bp->dev, "NIC Link is Down\n");
@@ -5583,6 +5589,11 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 			}
 		}
 	}
+
+	link_info->fec_cfg = PORT_PHY_QCFG_RESP_FEC_CFG_FEC_NONE_SUPPORTED;
+	if (bp->hwrm_spec_code >= 0x10504)
+		link_info->fec_cfg = le16_to_cpu(resp->fec_cfg);
+
 	/* TODO: need to add more logic to report VF link */
 	if (chng_link_state) {
 		if (link_info->phy_link_status == BNXT_LINK_LINK)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index eaed700..faf26a2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -867,6 +867,10 @@ struct bnxt_link_info {
 	u16			force_link_speed;
 	u32			preemphasis;
 	u8			module_status;
+	u16			fec_cfg;
+#define BNXT_FEC_AUTONEG	PORT_PHY_QCFG_RESP_FEC_CFG_FEC_AUTONEG_ENABLED
+#define BNXT_FEC_ENC_BASE_R	PORT_PHY_QCFG_RESP_FEC_CFG_FEC_CLAUSE74_ENABLED
+#define BNXT_FEC_ENC_RS		PORT_PHY_QCFG_RESP_FEC_CFG_FEC_CLAUSE91_ENABLED
 
 	/* copy of requested setting from ethtool cmd */
 	u8			autoneg;
-- 
1.8.3.1
