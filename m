From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 5/8] qlcnic: fix pci semaphore checks
Date: Thu, 22 Apr 2010 05:51:39 -0700
Message-ID: <1271940702-17064-6-git-send-email-amit.salecha@qlogic.com>
References: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:16761 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754579Ab0DVMvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:51:44 -0400
In-Reply-To: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver should not go ahead with fw recovery if fails to acquire
semaphore.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3c8a963..bfc5510 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1949,8 +1949,8 @@ static void qlcnic_poll_controller(struct net_device *netdev)
 }
 #endif
 
-static void
-qlcnic_set_drv_state(struct qlcnic_adapter *adapter, int state)
+static int
+qlcnic_set_drv_state(struct qlcnic_adapter *adapter, u8 state)
 {
 	u32  val;
 
@@ -1958,7 +1958,7 @@ qlcnic_set_drv_state(struct qlcnic_adapter *adapter, int state)
 			state != QLCNIC_DEV_NEED_QUISCENT);
 
 	if (qlcnic_api_lock(adapter))
-		return ;
+		return -EIO;
 
 	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
 
@@ -1970,6 +1970,8 @@ qlcnic_set_drv_state(struct qlcnic_adapter *adapter, int state)
 	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
+
+	return 0;
 }
 
 static int
@@ -2195,7 +2197,8 @@ qlcnic_detach_work(struct work_struct *work)
 	if (adapter->temp == QLCNIC_TEMP_PANIC)
 		goto err_ret;
 
-	qlcnic_set_drv_state(adapter, adapter->dev_state);
+	if (qlcnic_set_drv_state(adapter, adapter->dev_state))
+		goto err_ret;
 
 	adapter->fw_wait_cnt = 0;
 
-- 
1.6.0.2

