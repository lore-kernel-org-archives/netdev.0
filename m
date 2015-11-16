From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net] qlcnic: Fix mailbox completion handling during spurious interrupt
Date: Mon, 16 Nov 2015 05:58:47 -0500
Message-ID: <1447671527-28905-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46987 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751358AbbKPLiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 06:38:25 -0500
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
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   12 ++++++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    3 ++-
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index d6696cf..371c266 100644
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
index 9f0bdd9..865f21b 100644
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
+		if (atomic_read(&mbx->rsp_status) != rsp_status)
+			qlcnic_83xx_notify_mbx_response(mbx);
+		else
+			adapter->stats.mbx_spurious_intr++;
+	}
 
 out:
 	mask = QLCRDX(adapter->ahw, QLCNIC_DEF_INT_MASK);
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
1.5.6
