From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 8/9] qlcnic: support quisce mode
Date: Thu, 13 May 2010 06:07:49 -0700
Message-ID: <1273756070-7205-9-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:59221 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758756Ab0EMNHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:54 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Device can go to quiescent state, during which drivers
should refrain from using the device.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index ce57229..ce8118c 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2044,8 +2044,11 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 
 	do {
 		msleep(1000);
-	} while ((QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) != QLCNIC_DEV_READY)
-			&& --dev_init_timeo);
+		prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+
+		if (prev_state == QLCNIC_DEV_QUISCENT)
+			continue;
+	} while ((prev_state != QLCNIC_DEV_READY) && --dev_init_timeo);
 
 	if (!dev_init_timeo) {
 		dev_err(&adapter->pdev->dev,
@@ -2076,6 +2079,14 @@ qlcnic_fwinit_work(struct work_struct *work)
 	if (qlcnic_api_lock(adapter))
 		goto err_ret;
 
+	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	if (dev_state ==  QLCNIC_DEV_QUISCENT) {
+		qlcnic_api_unlock(adapter);
+		qlcnic_schedule_work(adapter, qlcnic_fwinit_work,
+						FW_POLL_DELAY * 2);
+		return;
+	}
+
 	if (adapter->fw_wait_cnt++ > adapter->reset_ack_timeo) {
 		dev_err(&adapter->pdev->dev, "Reset:Failed to get ack %d sec\n",
 					adapter->reset_ack_timeo);
@@ -2085,6 +2096,17 @@ qlcnic_fwinit_work(struct work_struct *work)
 	if (!qlcnic_check_drv_state(adapter)) {
 skip_ack_check:
 		dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+
+		if (dev_state == QLCNIC_DEV_NEED_QUISCENT) {
+			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
+						QLCNIC_DEV_QUISCENT);
+			qlcnic_schedule_work(adapter, qlcnic_fwinit_work,
+						FW_POLL_DELAY * 2);
+			QLCDB(adapter, DRV, "Quiscing the driver\n");
+			qlcnic_api_unlock(adapter);
+			return;
+		}
+
 		if (dev_state == QLCNIC_DEV_NEED_RESET) {
 			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
 						QLCNIC_DEV_INITIALIZING);
@@ -2107,6 +2129,8 @@ skip_ack_check:
 	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
 
 	switch (dev_state) {
+	case QLCNIC_DEV_QUISCENT:
+	case QLCNIC_DEV_NEED_QUISCENT:
 	case QLCNIC_DEV_NEED_RESET:
 		qlcnic_schedule_work(adapter,
 			qlcnic_fwinit_work, FW_POLL_DELAY);
-- 
1.6.0.2

