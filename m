From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v2 4/5] qlcnic: Enable mailbox interface in poll mode when interrupts are not available
Date: Wed, 31 Jul 2013 17:11:01 -0400
Message-ID: <b2f92592650aa440d8df5dc70e348b2317805258.1375314056.git.himanshu.madhani@qlogic.com>
References: <cover.1375314056.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60520 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757007Ab3GaWCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 18:02:32 -0400
In-Reply-To: <cover.1375314056.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 1bdc754..29c3778 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -945,6 +945,7 @@ void qlcnic_83xx_enable_mbx_poll(struct qlcnic_adapter *adapter)
 		return;
 
 	INIT_DELAYED_WORK(&adapter->mbx_poll_work, qlcnic_83xx_mbx_poll_work);
+	queue_delayed_work(adapter->qlcnic_wq, &adapter->mbx_poll_work, 0);
 }
 
 void qlcnic_83xx_disable_mbx_poll(struct qlcnic_adapter *adapter)
@@ -1331,8 +1332,10 @@ static int qlcnic_83xx_diag_alloc_res(struct net_device *netdev, int test,
 
 	if (adapter->ahw->diag_test == QLCNIC_LOOPBACK_TEST) {
 		/* disable and free mailbox interrupt */
-		if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
+		if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
+			qlcnic_83xx_enable_mbx_poll(adapter);
 			qlcnic_83xx_free_mbx_intr(adapter);
+		}
 		adapter->ahw->loopback_state = 0;
 		adapter->ahw->hw_ops->setup_link_event(adapter, 1);
 	}
@@ -1353,6 +1356,8 @@ static void qlcnic_83xx_diag_free_res(struct net_device *netdev,
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
 			qlcnic_83xx_disable_intr(adapter, sds_ring);
+			if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
+				qlcnic_83xx_enable_mbx_poll(adapter);
 		}
 	}
 
@@ -1362,6 +1367,7 @@ static void qlcnic_83xx_diag_free_res(struct net_device *netdev,
 	if (adapter->ahw->diag_test == QLCNIC_LOOPBACK_TEST) {
 		if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
 			err = qlcnic_83xx_setup_mbx_intr(adapter);
+			qlcnic_83xx_disable_mbx_poll(adapter);
 			if (err) {
 				dev_err(&adapter->pdev->dev,
 					"%s: failed to setup mbx interrupt\n",
@@ -1378,6 +1384,10 @@ static void qlcnic_83xx_diag_free_res(struct net_device *netdev,
 
 	if (netif_running(netdev))
 		__qlcnic_up(adapter, netdev);
+
+	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST &&
+	    !(adapter->flags & QLCNIC_MSIX_ENABLED))
+		qlcnic_83xx_disable_mbx_poll(adapter);
 out:
 	netif_device_attach(netdev);
 }
@@ -1662,8 +1672,6 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 	/* Poll for link up event before running traffic */
 	do {
 		msleep(QLC_83XX_LB_MSLEEP_COUNT);
-		if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
-			qlcnic_83xx_process_aen(adapter);
 
 		if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
 			netdev_info(netdev,
@@ -1740,8 +1748,6 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 	/* Wait for Link and IDC Completion AEN */
 	do {
 		msleep(QLC_83XX_LB_MSLEEP_COUNT);
-		if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
-			qlcnic_83xx_process_aen(adapter);
 
 		if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
 			netdev_info(netdev,
@@ -1789,8 +1795,6 @@ int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 	/* Wait for Link and IDC Completion AEN */
 	do {
 		msleep(QLC_83XX_LB_MSLEEP_COUNT);
-		if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
-			qlcnic_83xx_process_aen(adapter);
 
 		if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
 			netdev_info(netdev,
-- 
1.8.1.4
