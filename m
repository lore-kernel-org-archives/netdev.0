From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 5/7] qlcnic: Rename the IRQ description.
Date: Wed, 24 Apr 2013 18:42:43 -0400
Message-ID: <1366843365-2787-6-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:45498 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932204Ab3DXXHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:07:12 -0400
In-Reply-To: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Here's what modified vectors will look like
in the /proc/interrupts

        MSIx             	INTx
-----------------------------------------
83xx    qlcnic[MB]
	qlcnic-ethX[Rx0]
	qlcnic-ethX[Rx1]
	..
	qlcnic-ethX[RxN]
	qlcnic-ethx[Tx0]        qlcnic[MB+Tx0+Rx0]

82xx    qlcnic-ethX[Rx0]
	qlcnic-ethX[Rx1]
	..
	qlcnic-ethX[Tx0+RxN]    qlcnic-ethX[Tx0+Rx0]

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   23 +++++++++++++++------
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 767c683..b2206db 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -519,13 +519,13 @@ struct qlcnic_host_sds_ring {
 	int irq;
 
 	dma_addr_t phys_addr;
-	char name[IFNAMSIZ+4];
+	char name[IFNAMSIZ + 12];
 } ____cacheline_internodealigned_in_smp;
 
 struct qlcnic_host_tx_ring {
 	int irq;
 	void __iomem *crb_intr_mask;
-	char name[IFNAMSIZ+4];
+	char name[IFNAMSIZ + 12];
 	u16 ctx_id;
 	u32 producer;
 	u32 sw_consumer;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 4e0bcb1..1310b7b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1287,7 +1287,7 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	irq_handler_t handler;
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_host_tx_ring *tx_ring;
-	int err, ring;
+	int err, ring, num_sds_rings;
 
 	unsigned long flags = 0;
 	struct net_device *netdev = adapter->netdev;
@@ -1318,10 +1318,20 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 		if (qlcnic_82xx_check(adapter) ||
 		    (qlcnic_83xx_check(adapter) &&
 		     (adapter->flags & QLCNIC_MSIX_ENABLED))) {
-			for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			num_sds_rings = adapter->max_sds_rings;
+			for (ring = 0; ring < num_sds_rings; ring++) {
 				sds_ring = &recv_ctx->sds_rings[ring];
-				snprintf(sds_ring->name, sizeof(int) + IFNAMSIZ,
-					 "%s[%d]", netdev->name, ring);
+				if (qlcnic_82xx_check(adapter) &&
+				    (ring == (num_sds_rings - 1)))
+					snprintf(sds_ring->name,
+						 sizeof(sds_ring->name),
+						 "qlcnic-%s[Tx0+Rx%d]",
+						 netdev->name, ring);
+				else
+					snprintf(sds_ring->name,
+						 sizeof(sds_ring->name),
+						 "qlcnic-%s[Rx%d]",
+						 netdev->name, ring);
 				err = request_irq(sds_ring->irq, handler, flags,
 						  sds_ring->name, sds_ring);
 				if (err)
@@ -1335,9 +1345,8 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 			for (ring = 0; ring < adapter->max_drv_tx_rings;
 			     ring++) {
 				tx_ring = &adapter->tx_ring[ring];
-				snprintf(tx_ring->name, sizeof(int) + IFNAMSIZ,
-					 "%s[%d]", netdev->name,
-					 adapter->max_sds_rings + ring);
+				snprintf(tx_ring->name, sizeof(tx_ring->name),
+					 "qlcnic-%s[Tx%d]", netdev->name, ring);
 				err = request_irq(tx_ring->irq, handler, flags,
 						  tx_ring->name, tx_ring);
 				if (err)
-- 
1.7.6.rc1.1.g2c162b
