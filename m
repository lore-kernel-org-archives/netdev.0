From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/4] bnxt_en: Shutdown link when device is closed.
Date: Mon, 11 Apr 2016 04:11:12 -0400
Message-ID: <1460362274-21771-3-git-send-email-michael.chan@broadcom.com>
References: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:18025 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbcDKILQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:11:16 -0400
In-Reply-To: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let firmware know that the driver is giving up control of the link so that
it can be shutdown if no management firmware is running.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a06dcaa..e874a56 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4790,6 +4790,21 @@ int bnxt_hwrm_set_link_setting(struct bnxt *bp, bool set_pause, bool set_eee)
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
+static int bnxt_hwrm_shutdown_link(struct bnxt *bp)
+{
+	struct hwrm_port_phy_cfg_input req = {0};
+
+	if (BNXT_VF(bp))
+		return 0;
+
+	if (pci_num_vf(bp->pdev))
+		return 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_PHY_CFG, -1, -1);
+	req.flags = cpu_to_le32(PORT_PHY_CFG_REQ_FLAGS_FORCE_LINK_DOWN);
+	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+}
+
 static bool bnxt_eee_config_ok(struct bnxt *bp)
 {
 	struct ethtool_eee *eee = &bp->eee;
@@ -5044,6 +5059,7 @@ static int bnxt_close(struct net_device *dev)
 	struct bnxt *bp = netdev_priv(dev);
 
 	bnxt_close_nic(bp, true, true);
+	bnxt_hwrm_shutdown_link(bp);
 	return 0;
 }
 
-- 
1.8.3.1
