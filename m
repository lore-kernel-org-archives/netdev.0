From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 03/12] qlcnic: Update IRQ name for 8200 and 8300 Series adapter.
Date: Fri, 24 May 2013 03:04:27 -0400
Message-ID: <1369379076-4718-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:19746
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759561Ab3EXH3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:29:51 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Updated IRQ name for 8200 and 8300 Series adapter as per
  format used by other multiqueue drivers.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    5 +---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   23 +++++++++++++-------
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 9b91d6a..9f5683f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -482,7 +482,6 @@ int qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *adapter)
 {
 	irq_handler_t handler;
 	u32 val;
-	char name[32];
 	int err = 0;
 	unsigned long flags = 0;
 
@@ -493,9 +492,7 @@ int qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *adapter)
 	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
 		handler = qlcnic_83xx_handle_aen;
 		val = adapter->msix_entries[adapter->ahw->num_msix - 1].vector;
-		snprintf(name, (IFNAMSIZ + 4),
-			 "%s[%s]", "qlcnic", "aen");
-		err = request_irq(val, handler, flags, name, adapter);
+		err = request_irq(val, handler, flags, "qlcnic-MB", adapter);
 		if (err) {
 			dev_err(&adapter->pdev->dev,
 				"failed to register MBX interrupt\n");
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 5d42ec1..4099cf2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1431,16 +1431,23 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 			for (ring = 0; ring < num_sds_rings; ring++) {
 				sds_ring = &recv_ctx->sds_rings[ring];
 				if (qlcnic_82xx_check(adapter) &&
-				    (ring == (num_sds_rings - 1)))
+				    (ring == (num_sds_rings - 1))) {
+					if (!(adapter->flags &
+					      QLCNIC_MSIX_ENABLED))
+						snprintf(sds_ring->name,
+							 sizeof(sds_ring->name),
+							 "qlcnic");
+					else
+						snprintf(sds_ring->name,
+							 sizeof(sds_ring->name),
+							 "%s-tx-0-rx-%d",
+							 netdev->name, ring);
+				} else {
 					snprintf(sds_ring->name,
 						 sizeof(sds_ring->name),
-						 "qlcnic-%s[Tx0+Rx%d]",
-						 netdev->name, ring);
-				else
-					snprintf(sds_ring->name,
-						 sizeof(sds_ring->name),
-						 "qlcnic-%s[Rx%d]",
+						 "%s-rx-%d",
 						 netdev->name, ring);
+				}
 				err = request_irq(sds_ring->irq, handler, flags,
 						  sds_ring->name, sds_ring);
 				if (err)
@@ -1455,7 +1462,7 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 			     ring++) {
 				tx_ring = &adapter->tx_ring[ring];
 				snprintf(tx_ring->name, sizeof(tx_ring->name),
-					 "qlcnic-%s[Tx%d]", netdev->name, ring);
+					 "%s-tx-%d", netdev->name, ring);
 				err = request_irq(tx_ring->irq, handler, flags,
 						  tx_ring->name, tx_ring);
 				if (err)
-- 
1.5.6
