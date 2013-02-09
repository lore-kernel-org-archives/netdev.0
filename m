From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 6/8] qlcnic: fix async event handling during diagnostic loopback test
Date: Sat,  9 Feb 2013 14:29:53 -0500
Message-ID: <1360438195-12667-7-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:7544 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932525Ab3BITvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Feb 2013 14:51:25 -0500
In-Reply-To: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o Handle async events during diagnostic loopback test
o Clear loopback mode on failure to receive async events

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 36c1474..51b4340 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1436,13 +1436,15 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 		return status;
 	}
 
-	/* Wait until firmware send IDC Completion AEN */
+	/* Wait for Link and IDC Completion AEN */
 	do {
 		msleep(300);
+		qlcnic_83xx_process_aen(adapter);
 		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
 			dev_err(&adapter->pdev->dev,
 				"FW did not generate IDC completion AEN\n");
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
+			qlcnic_83xx_clear_lb_mode(adapter, mode);
 			return -EIO;
 		}
 	} while (test_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status));
@@ -1474,9 +1476,10 @@ int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 		return status;
 	}
 
-	/* Wait until firmware send IDC Completion AEN */
+	/* Wait for Link and IDC Completion AEN */
 	do {
 		msleep(300);
+		qlcnic_83xx_process_aen(adapter);
 		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
 			dev_err(&adapter->pdev->dev,
 				"Firmware didn't sent IDC completion AEN\n");
-- 
1.7.1
