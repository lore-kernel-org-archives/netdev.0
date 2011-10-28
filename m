From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 1/5] qlcnic: skip IDC ack check in fw reset path.
Date: Fri, 28 Oct 2011 15:57:11 -0700
Message-ID: <1319842636-14936-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:56269
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933739Ab1J1XJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 19:09:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

In fw reset path, we should consider any change in device state as an
ack from the other driver. When that happens, we don't have to wait for
an explicit ack.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 106503f..2edffce 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2840,8 +2840,15 @@ qlcnic_fwinit_work(struct work_struct *work)
 		goto wait_npar;
 	}
 
+	if (dev_state == QLCNIC_DEV_INITIALIZING ||
+	    dev_state == QLCNIC_DEV_READY) {
+		dev_info(&adapter->pdev->dev, "Detected state change from "
+				"DEV_NEED_RESET, skipping ack check\n");
+		goto skip_ack_check;
+	}
+
 	if (adapter->fw_wait_cnt++ > adapter->reset_ack_timeo) {
-		dev_err(&adapter->pdev->dev, "Reset:Failed to get ack %d sec\n",
+		dev_info(&adapter->pdev->dev, "Reset:Failed to get ack %d sec\n",
 					adapter->reset_ack_timeo);
 		goto skip_ack_check;
 	}
-- 
1.7.4.1
