From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/7] qlcnic: clear device reset state after fw recovery
Date: Mon,  1 Feb 2010 06:30:40 -0800
Message-ID: <1265034644-19461-4-git-send-email-amit.salecha@qlogic.com>
References: <1265034644-19461-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:9783 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754606Ab0BAOaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 09:30:46 -0500
In-Reply-To: <1265034644-19461-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o After firmware recovery, clear device reset state transition register.
  Otherwise firmware reload can occur unnecessary.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 05275f2..9a98285 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1866,6 +1866,23 @@ qlcnic_set_drv_state(struct qlcnic_adapter *adapter, int state)
 	qlcnic_api_unlock(adapter);
 }
 
+static int
+qlcnic_clr_drv_state(struct qlcnic_adapter *adapter)
+{
+	u32  val;
+
+	if (qlcnic_api_lock(adapter))
+		return -EBUSY;
+
+	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val &= ~((u32)0x3 << (adapter->portnum * 4));
+	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+
+	qlcnic_api_unlock(adapter);
+
+	return 0;
+}
+
 static void
 qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter)
 {
@@ -2119,7 +2136,10 @@ qlcnic_attach_work(struct work_struct *work)
 done:
 	adapter->fw_fail_cnt = 0;
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
+
+	if (!qlcnic_clr_drv_state(adapter))
+		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
+							FW_POLL_DELAY);
 }
 
 static int
-- 
1.6.0.2

