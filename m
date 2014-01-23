From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 4/7] qlcnic: Update poll controller code path
Date: Thu, 23 Jan 2014 17:18:31 -0500
Message-ID: <007aef3c1d4ed16bccdb9def80963b186548e6e7.1390491376.git.himanshu.madhani@qlogic.com>
References: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:36273 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755604AbaAWWww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:52:52 -0500
In-Reply-To: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

Add support for MSI/MSI-X mode in poll controller routine.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 34 +++++++++++++++++++-----
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b9c1e37..0cfa8a3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2925,17 +2925,39 @@ static irqreturn_t qlcnic_msix_tx_intr(int irq, void *data)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev)
 {
-	int ring;
-	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_tx_ring *tx_ring;
+	int ring;
+
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
+		return;
+
+	recv_ctx = adapter->recv_ctx;
 
-	disable_irq(adapter->irq);
 	for (ring = 0; ring < adapter->drv_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
-		qlcnic_intr(adapter->irq, sds_ring);
+		qlcnic_disable_sds_intr(adapter, sds_ring);
+		napi_schedule(&sds_ring->napi);
+	}
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		/* Only Multi-Tx queue capable devices need to
+		 * schedule NAPI for TX rings
+		 */
+		if ((qlcnic_83xx_check(adapter) &&
+		     (adapter->flags & QLCNIC_TX_INTR_SHARED)) ||
+		    (qlcnic_82xx_check(adapter) &&
+		     !qlcnic_check_multi_tx(adapter)))
+			return;
+
+		for (ring = 0; ring < adapter->drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			qlcnic_disable_tx_intr(adapter, tx_ring);
+			napi_schedule(&tx_ring->napi);
+		}
 	}
-	enable_irq(adapter->irq);
 }
 #endif
 
-- 
1.8.1.4
