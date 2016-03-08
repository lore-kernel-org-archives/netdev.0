From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net v2 2/2] qlcnic: Fix mailbox completion handling during spurious interrupt
Date: Tue, 8 Mar 2016 02:39:58 -0500
Message-ID: <1457422798-17981-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1457422798-17981-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43983 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753530AbcCHIU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 03:20:28 -0500
In-Reply-To: <1457422798-17981-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o While the driver is in the middle of a MB completion processing
and it receives a spurious MB interrupt, it is mistaken as a good MB
completion interrupt leading to premature completion of the next MB
request. Fix the driver to guard against this by checking the current
state of MB processing and ignore the spurious interrupt.
Also added a stats counter to record this condition.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h         |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 15 +++++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c |  3 ++-
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index d18667b..55007f1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -566,6 +566,7 @@ struct qlcnic_adapter_stats {
 	u64  tx_dma_map_error;
 	u64  spurious_intr;
 	u64  mac_filter_limit_overrun;
+	u64  mbx_spurious_intr;
 };
 
 /*
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index e3d1bb7..f9640d5ce 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2338,9 +2338,9 @@ static void qlcnic_83xx_handle_link_aen(struct qlcnic_adapter *adapter,
 
 static irqreturn_t qlcnic_83xx_handle_aen(int irq, void *data)
 {
+	u32 mask, resp, event, rsp_status = QLC_83XX_MBX_RESPONSE_ARRIVED;
 	struct qlcnic_adapter *adapter = data;
 	struct qlcnic_mailbox *mbx;
-	u32 mask, resp, event;
 	unsigned long flags;
 
 	mbx = adapter->ahw->mailbox;
@@ -2350,10 +2350,14 @@ static irqreturn_t qlcnic_83xx_handle_aen(int irq, void *data)
 		goto out;
 
 	event = readl(QLCNIC_MBX_FW(adapter->ahw, 0));
-	if (event &  QLCNIC_MBX_ASYNC_EVENT)
+	if (event &  QLCNIC_MBX_ASYNC_EVENT) {
 		__qlcnic_83xx_process_aen(adapter);
-	else
-		qlcnic_83xx_notify_mbx_response(mbx);
+	} else {
+		if (mbx->rsp_status != rsp_status)
+			qlcnic_83xx_notify_mbx_response(mbx);
+		else
+			adapter->stats.mbx_spurious_intr++;
+	}
 
 out:
 	mask = QLCRDX(adapter->ahw, QLCNIC_DEF_INT_MASK);
@@ -4053,6 +4057,7 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 	struct list_head *head = &mbx->cmd_q;
 	struct qlcnic_hardware_context *ahw;
 	struct qlcnic_cmd_args *cmd = NULL;
+	unsigned long flags;
 
 	ahw = adapter->ahw;
 
@@ -4062,7 +4067,9 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 			return;
 		}
 
+		spin_lock_irqsave(&mbx->aen_lock, flags);
 		mbx->rsp_status = QLC_83XX_MBX_RESPONSE_WAIT;
+		spin_unlock_irqrestore(&mbx->aen_lock, flags);
 
 		spin_lock(&mbx->queue_lock);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 494e810..0a2318c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -59,7 +59,8 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 	 QLC_OFF(stats.mac_filter_limit_overrun)},
 	{"spurious intr", QLC_SIZEOF(stats.spurious_intr),
 	 QLC_OFF(stats.spurious_intr)},
-
+	{"mbx spurious intr", QLC_SIZEOF(stats.mbx_spurious_intr),
+	 QLC_OFF(stats.mbx_spurious_intr)},
 };
 
 static const char qlcnic_device_gstrings_stats[][ETH_GSTRING_LEN] = {
-- 
1.8.3.1
