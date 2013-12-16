From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 7/8] qlcnic: Fix mailbox processing during diagnostic test
Date: Mon, 16 Dec 2013 15:37:02 -0500
Message-ID: <a41cee33ec02c09091a9bdf86d230f0e33b182ca.1387256276.git.himanshu.madhani@qlogic.com>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:17872 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752162Ab3LPVJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:53 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

o Do not enable mailbox polling in case of legacy interrupt.
  Process mailbox AEN/response from the interrupt.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 32 ++++------------------
 1 file changed, 6 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index b1cb0ff..ab66e7f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -447,8 +447,9 @@ irqreturn_t qlcnic_83xx_intr(int irq, void *data)
 
 	qlcnic_83xx_poll_process_aen(adapter);
 
-	if (ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
-		ahw->diag_cnt++;
+	if (ahw->diag_test) {
+		if (ahw->diag_test == QLCNIC_INTERRUPT_TEST)
+			ahw->diag_cnt++;
 		qlcnic_83xx_enable_legacy_msix_mbx_intr(adapter);
 		return IRQ_HANDLED;
 	}
@@ -1345,11 +1346,6 @@ static int qlcnic_83xx_diag_alloc_res(struct net_device *netdev, int test,
 	}
 
 	if (adapter->ahw->diag_test == QLCNIC_LOOPBACK_TEST) {
-		/* disable and free mailbox interrupt */
-		if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
-			qlcnic_83xx_enable_mbx_poll(adapter);
-			qlcnic_83xx_free_mbx_intr(adapter);
-		}
 		adapter->ahw->loopback_state = 0;
 		adapter->ahw->hw_ops->setup_link_event(adapter, 1);
 	}
@@ -1363,33 +1359,20 @@ static void qlcnic_83xx_diag_free_res(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_host_sds_ring *sds_ring;
-	int ring, err;
+	int ring;
 
 	clear_bit(__QLCNIC_DEV_UP, &adapter->state);
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->drv_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
-			qlcnic_83xx_disable_intr(adapter, sds_ring);
-			if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
-				qlcnic_83xx_enable_mbx_poll(adapter);
+			if (adapter->flags & QLCNIC_MSIX_ENABLED)
+				qlcnic_83xx_disable_intr(adapter, sds_ring);
 		}
 	}
 
 	qlcnic_fw_destroy_ctx(adapter);
 	qlcnic_detach(adapter);
 
-	if (adapter->ahw->diag_test == QLCNIC_LOOPBACK_TEST) {
-		if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
-			err = qlcnic_83xx_setup_mbx_intr(adapter);
-			qlcnic_83xx_disable_mbx_poll(adapter);
-			if (err) {
-				dev_err(&adapter->pdev->dev,
-					"%s: failed to setup mbx interrupt\n",
-					__func__);
-				goto out;
-			}
-		}
-	}
 	adapter->ahw->diag_test = 0;
 	adapter->drv_sds_rings = drv_sds_rings;
 
@@ -1399,9 +1382,6 @@ static void qlcnic_83xx_diag_free_res(struct net_device *netdev,
 	if (netif_running(netdev))
 		__qlcnic_up(adapter, netdev);
 
-	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST &&
-	    !(adapter->flags & QLCNIC_MSIX_ENABLED))
-		qlcnic_83xx_disable_mbx_poll(adapter);
 out:
 	netif_device_attach(netdev);
 }
-- 
1.8.1.4
