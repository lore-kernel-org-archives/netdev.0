From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 09/12] bnxt_en: Add PHY loopback to ethtool self-test.
Date: Tue,  4 Apr 2017 18:14:14 -0400
Message-ID: <1491344057-12663-10-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:32889 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755198AbdDDWO6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:58 -0400
Received: by mail-wr0-f174.google.com with SMTP id w43so223841583wrb.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:57 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is necessary to disable autoneg before enabling PHY loopback,
otherwise link won't come up.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 62 ++++++++++++++++++++++-
 1 file changed, 60 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index ecb4417..dde3e21 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -2192,6 +2192,54 @@ static int bnxt_hwrm_mac_loopback(struct bnxt *bp, bool enable)
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
+static int bnxt_disable_an_for_lpbk(struct bnxt *bp,
+				    struct hwrm_port_phy_cfg_input *req)
+{
+	struct bnxt_link_info *link_info = &bp->link_info;
+	u16 fw_advertising = link_info->advertising;
+	u16 fw_speed;
+	int rc;
+
+	if (!link_info->autoneg)
+		return 0;
+
+	fw_speed = PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_1GB;
+	if (netif_carrier_ok(bp->dev))
+		fw_speed = bp->link_info.link_speed;
+	else if (fw_advertising & BNXT_LINK_SPEED_MSK_10GB)
+		fw_speed = PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_10GB;
+	else if (fw_advertising & BNXT_LINK_SPEED_MSK_25GB)
+		fw_speed = PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_25GB;
+	else if (fw_advertising & BNXT_LINK_SPEED_MSK_40GB)
+		fw_speed = PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_40GB;
+	else if (fw_advertising & BNXT_LINK_SPEED_MSK_50GB)
+		fw_speed = PORT_PHY_CFG_REQ_FORCE_LINK_SPEED_50GB;
+
+	req->force_link_speed = cpu_to_le16(fw_speed);
+	req->flags |= cpu_to_le32(PORT_PHY_CFG_REQ_FLAGS_FORCE |
+				  PORT_PHY_CFG_REQ_FLAGS_RESET_PHY);
+	rc = hwrm_send_message(bp, req, sizeof(*req), HWRM_CMD_TIMEOUT);
+	req->flags = 0;
+	req->force_link_speed = cpu_to_le16(0);
+	return rc;
+}
+
+static int bnxt_hwrm_phy_loopback(struct bnxt *bp, bool enable)
+{
+	struct hwrm_port_phy_cfg_input req = {0};
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_PHY_CFG, -1, -1);
+
+	if (enable) {
+		bnxt_disable_an_for_lpbk(bp, &req);
+		req.lpbk = PORT_PHY_CFG_REQ_LPBK_LOCAL;
+	} else {
+		req.lpbk = PORT_PHY_CFG_REQ_LPBK_NONE;
+	}
+	req.enables = cpu_to_le32(PORT_PHY_CFG_REQ_ENABLES_LPBK);
+	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+}
+
 static int bnxt_rx_loopback(struct bnxt *bp, struct bnxt_napi *bnapi,
 			    u32 raw_cons, int pkt_size)
 {
@@ -2318,8 +2366,9 @@ static int bnxt_run_fw_tests(struct bnxt *bp, u8 test_mask, u8 *test_results)
 	return rc;
 }
 
-#define BNXT_DRV_TESTS			1
+#define BNXT_DRV_TESTS			2
 #define BNXT_MACLPBK_TEST_IDX		(bp->num_tests - BNXT_DRV_TESTS)
+#define BNXT_PHYLPBK_TEST_IDX		(BNXT_MACLPBK_TEST_IDX + 1)
 
 static void bnxt_self_test(struct net_device *dev, struct ethtool_test *etest,
 			   u64 *buf)
@@ -2377,8 +2426,15 @@ static void bnxt_self_test(struct net_device *dev, struct ethtool_test *etest,
 		else
 			buf[BNXT_MACLPBK_TEST_IDX] = 0;
 
-		bnxt_half_close_nic(bp);
 		bnxt_hwrm_mac_loopback(bp, false);
+		bnxt_hwrm_phy_loopback(bp, true);
+		msleep(1000);
+		if (bnxt_run_loopback(bp)) {
+			buf[BNXT_PHYLPBK_TEST_IDX] = 1;
+			etest->flags |= ETH_TEST_FL_FAILED;
+		}
+		bnxt_hwrm_phy_loopback(bp, false);
+		bnxt_half_close_nic(bp);
 		bnxt_open_nic(bp, false, true);
 	}
 	for (i = 0; i < bp->num_tests - BNXT_DRV_TESTS; i++) {
@@ -2426,6 +2482,8 @@ void bnxt_ethtool_init(struct bnxt *bp)
 
 		if (i == BNXT_MACLPBK_TEST_IDX) {
 			strcpy(str, "Mac loopback test (offline)");
+		} else if (i == BNXT_PHYLPBK_TEST_IDX) {
+			strcpy(str, "Phy loopback test (offline)");
 		} else {
 			strlcpy(str, fw_str, ETH_GSTRING_LEN);
 			strncat(str, " test", ETH_GSTRING_LEN - strlen(str));
-- 
1.8.3.1
