From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net v2 2/3] qed: Fix overriding of supported autoneg value.
Date: Thu, 4 May 2017 08:15:04 -0700
Message-ID: <20170504151505.4407-3-sudarsana.kalluru@cavium.com>
References: <20170504151505.4407-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0063.outbound.protection.outlook.com ([104.47.32.63]:32425
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754989AbdEDPPi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 11:15:38 -0400
In-Reply-To: <20170504151505.4407-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver currently uses advertised-autoneg value to populate the
supported-autoneg field. When advertised field is updated, user gets
the same value for supported field. Supported-autoneg value need to be
populated from the link capabilities value returned by the MFW.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c  | 3 +++
 drivers/net/ethernet/qlogic/qed/qed_main.c | 6 +++++-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h  | 1 +
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 5c6874a..bb70522 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2536,6 +2536,9 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		DP_NOTICE(p_hwfn, "Unknown Speed in 0x%08x\n", link_temp);
 	}
 
+	p_hwfn->mcp_info->link_capabilities.default_speed_autoneg =
+		link->speed.autoneg;
+
 	link_temp &= NVM_CFG1_PORT_DRV_FLOW_CONTROL_MASK;
 	link_temp >>= NVM_CFG1_PORT_DRV_FLOW_CONTROL_OFFSET;
 	link->pause.autoneg = !!(link_temp &
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index a5eef1a..b7ad36b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1372,7 +1372,7 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 
 	/* TODO - at the moment assume supported and advertised speed equal */
 	if_link->supported_caps = QED_LM_FIBRE_BIT;
-	if (params.speed.autoneg)
+	if (link_caps.default_speed_autoneg)
 		if_link->supported_caps |= QED_LM_Autoneg_BIT;
 	if (params.pause.autoneg ||
 	    (params.pause.forced_rx && params.pause.forced_tx))
@@ -1382,6 +1382,10 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 		if_link->supported_caps |= QED_LM_Pause_BIT;
 
 	if_link->advertised_caps = if_link->supported_caps;
+	if (params.speed.autoneg)
+		if_link->advertised_caps |= QED_LM_Autoneg_BIT;
+	else
+		if_link->advertised_caps &= ~QED_LM_Autoneg_BIT;
 	if (params.speed.advertised_speeds &
 	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G)
 		if_link->advertised_caps |= QED_LM_1000baseT_Half_BIT |
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 5ae35d6..2b09b85 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -61,6 +61,7 @@ struct qed_mcp_link_params {
 
 struct qed_mcp_link_capabilities {
 	u32 speed_capabilities;
+	bool default_speed_autoneg;
 };
 
 struct qed_mcp_link_state {
-- 
1.8.3.1
