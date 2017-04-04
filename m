From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 10/12] bnxt_en: Add interrupt test to ethtool -t selftest.
Date: Tue,  4 Apr 2017 18:14:15 -0400
Message-ID: <1491344057-12663-11-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:34955 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755207AbdDDWPA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:15:00 -0400
Received: by mail-wr0-f176.google.com with SMTP id k6so220426277wre.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:59 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 32 ++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index dde3e21..848ecf2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -2178,6 +2178,29 @@ static int bnxt_set_phys_id(struct net_device *dev,
 	return rc;
 }
 
+static int bnxt_hwrm_selftest_irq(struct bnxt *bp, u16 cmpl_ring)
+{
+	struct hwrm_selftest_irq_input req = {0};
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_SELFTEST_IRQ, cmpl_ring, -1);
+	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+}
+
+static int bnxt_test_irq(struct bnxt *bp)
+{
+	int i;
+
+	for (i = 0; i < bp->cp_nr_rings; i++) {
+		u16 cmpl_ring = bp->grp_info[i].cp_fw_ring_id;
+		int rc;
+
+		rc = bnxt_hwrm_selftest_irq(bp, cmpl_ring);
+		if (rc)
+			return rc;
+	}
+	return 0;
+}
+
 static int bnxt_hwrm_mac_loopback(struct bnxt *bp, bool enable)
 {
 	struct hwrm_port_mac_cfg_input req = {0};
@@ -2366,9 +2389,10 @@ static int bnxt_run_fw_tests(struct bnxt *bp, u8 test_mask, u8 *test_results)
 	return rc;
 }
 
-#define BNXT_DRV_TESTS			2
+#define BNXT_DRV_TESTS			3
 #define BNXT_MACLPBK_TEST_IDX		(bp->num_tests - BNXT_DRV_TESTS)
 #define BNXT_PHYLPBK_TEST_IDX		(BNXT_MACLPBK_TEST_IDX + 1)
+#define BNXT_IRQ_TEST_IDX		(BNXT_MACLPBK_TEST_IDX + 2)
 
 static void bnxt_self_test(struct net_device *dev, struct ethtool_test *etest,
 			   u64 *buf)
@@ -2437,6 +2461,10 @@ static void bnxt_self_test(struct net_device *dev, struct ethtool_test *etest,
 		bnxt_half_close_nic(bp);
 		bnxt_open_nic(bp, false, true);
 	}
+	if (bnxt_test_irq(bp)) {
+		buf[BNXT_IRQ_TEST_IDX] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
 	for (i = 0; i < bp->num_tests - BNXT_DRV_TESTS; i++) {
 		u8 bit_val = 1 << i;
 
@@ -2484,6 +2512,8 @@ void bnxt_ethtool_init(struct bnxt *bp)
 			strcpy(str, "Mac loopback test (offline)");
 		} else if (i == BNXT_PHYLPBK_TEST_IDX) {
 			strcpy(str, "Phy loopback test (offline)");
+		} else if (i == BNXT_IRQ_TEST_IDX) {
+			strcpy(str, "Interrupt_test (offline)");
 		} else {
 			strlcpy(str, fw_str, ETH_GSTRING_LEN);
 			strncat(str, " test", ETH_GSTRING_LEN - strlen(str));
-- 
1.8.3.1
