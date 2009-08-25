From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 12/26] et131x: clean up constant rx/tx registry fields
Date: Tue, 25 Aug 2009 15:59:28 +0100
Message-ID: <20090825145925.16176.90147.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47787 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755331AbZHYPEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:04:50 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_jagcore.c |    4 ++--
 drivers/staging/et131x/et1310_rx.c      |    6 +++---
 drivers/staging/et131x/et1310_tx.c      |   11 ++++++-----
 drivers/staging/et131x/et131x_adapter.h |    6 ------
 drivers/staging/et131x/et131x_config.c  |   27 ---------------------------
 drivers/staging/et131x/et131x_defs.h    |    8 ++++++++
 6 files changed, 19 insertions(+), 43 deletions(-)


diff --git a/drivers/staging/et131x/et1310_jagcore.c b/drivers/staging/et131x/et1310_jagcore.c
index 4032589..5c847ad 100644
--- a/drivers/staging/et131x/et1310_jagcore.c
+++ b/drivers/staging/et131x/et1310_jagcore.c
@@ -113,9 +113,9 @@ void ConfigGlobalRegs(struct et131x_adapter *etdev)
 			 * 50/50:
 			 */
 			writel(0, &pGbl->rxq_start_addr.value);
-			writel(etdev->RegistryRxMemEnd,
+			writel(PARM_RX_MEM_END_DEF,
 			       &pGbl->rxq_end_addr.value);
-			writel(etdev->RegistryRxMemEnd + 1,
+			writel(PARM_RX_MEM_END_DEF + 1,
 			       &pGbl->txq_start_addr.value);
 			writel(INTERNAL_MEM_SIZE - 1,
 			       &pGbl->txq_end_addr.value);
diff --git a/drivers/staging/et131x/et1310_rx.c b/drivers/staging/et131x/et1310_rx.c
index c60e05e..53efa08 100644
--- a/drivers/staging/et131x/et1310_rx.c
+++ b/drivers/staging/et131x/et1310_rx.c
@@ -792,14 +792,14 @@ void ConfigRxDmaRegs(struct et131x_adapter *etdev)
 	 * For version B silicon, this value gets updated once autoneg is
 	 *complete.
 	 */
-	writel(etdev->RegistryRxNumBuffers, &pRxDma->num_pkt_done.value);
+	writel(PARM_RX_NUM_BUFS_DEF, &pRxDma->num_pkt_done.value);
 
 	/* The "time_done" is not working correctly to coalesce interrupts
 	 * after a given time period, but rather is giving us an interrupt
 	 * regardless of whether we have received packets.
 	 * This value gets updated once autoneg is complete.
 	 */
-	writel(etdev->RegistryRxTimeInterval, &pRxDma->max_pkt_time.value);
+	writel(PARM_RX_TIME_INT_DEF, &pRxDma->max_pkt_time.value);
 
 	spin_unlock_irqrestore(&etdev->RcvLock, flags);
 
@@ -1272,7 +1272,7 @@ void et131x_handle_recv_interrupt(struct et131x_adapter *etdev)
 
 	if ((PacketArrayCount == NUM_PACKETS_HANDLED) || TempUnfinishedRec) {
 		etdev->RxRing.UnfinishedReceives = true;
-		writel(etdev->RegistryTxTimeInterval * NANO_IN_A_MICRO,
+		writel(PARM_TX_TIME_INT_DEF * NANO_IN_A_MICRO,
 		       &etdev->regs->global.watchdog_timer);
 	} else {
 		/* Watchdog timer will disable itself if appropriate. */
diff --git a/drivers/staging/et131x/et1310_tx.c b/drivers/staging/et131x/et1310_tx.c
index 8e8486a..8472c1b 100644
--- a/drivers/staging/et131x/et1310_tx.c
+++ b/drivers/staging/et131x/et1310_tx.c
@@ -94,6 +94,7 @@
 
 #include "et1310_tx.h"
 
+
 /* Data for debugging facilities */
 #ifdef CONFIG_ET131X_DEBUG
 extern dbg_info_t *et131x_dbginfo;
@@ -711,7 +712,7 @@ static int nic_send_packet(struct et131x_adapter *etdev, PMP_TCB pMpTcb)
 
 	if (etdev->uiLinkSpeed == TRUEPHY_SPEED_1000MBPS) {
 		if (++etdev->TxRing.TxPacketsSinceLastinterrupt ==
-		    etdev->RegistryTxNumBuffers) {
+		    PARM_TX_NUM_BUFS_DEF) {
 			CurDesc[FragmentNumber - 1].word3.value = 0x5;
 			etdev->TxRing.TxPacketsSinceLastinterrupt = 0;
 		} else {
@@ -794,7 +795,7 @@ static int nic_send_packet(struct et131x_adapter *etdev, PMP_TCB pMpTcb)
 	 * timer to wake us up if this packet isn't followed by N more.
 	 */
 	if (etdev->uiLinkSpeed == TRUEPHY_SPEED_1000MBPS) {
-		writel(etdev->RegistryTxTimeInterval * NANO_IN_A_MICRO,
+		writel(PARM_TX_TIME_INT_DEF * NANO_IN_A_MICRO,
 		       &etdev->regs->global.watchdog_timer);
 	}
 
@@ -1064,7 +1065,7 @@ static int nic_send_packet(struct et131x_adapter *etdev, PMP_TCB pMpTcb)
 				    TRUEPHY_SPEED_1000MBPS) {
 					if (++etdev->TxRing.
 					    TxPacketsSinceLastinterrupt >=
-					    etdev->RegistryTxNumBuffers) {
+					    PARM_TX_NUM_BUFS_DEF) {
 						CurDesc.word3.value = 0x5;
 						etdev->TxRing.
 						    TxPacketsSinceLastinterrupt
@@ -1132,7 +1133,7 @@ static int nic_send_packet(struct et131x_adapter *etdev, PMP_TCB pMpTcb)
 
 		if (etdev->uiLinkSpeed == TRUEPHY_SPEED_1000MBPS) {
 			if (++etdev->TxRing.TxPacketsSinceLastinterrupt >=
-			    etdev->RegistryTxNumBuffers) {
+			    PARM_TX_NUM_BUFS_DEF) {
 				CurDesc.word3.value = 0x5;
 				etdev->TxRing.TxPacketsSinceLastinterrupt =
 				    0;
@@ -1212,7 +1213,7 @@ static int nic_send_packet(struct et131x_adapter *etdev, PMP_TCB pMpTcb)
 	 * timer to wake us up if this packet isn't followed by N more.
 	 */
 	if (etdev->uiLinkSpeed == TRUEPHY_SPEED_1000MBPS) {
-		writel(etdev->RegistryTxTimeInterval * NANO_IN_A_MICRO,
+		writel(PARM_TX_TIME_INT_DEF * NANO_IN_A_MICRO,
 		       &etdev->regs->global.watchdog_timer);
 	}
 
diff --git a/drivers/staging/et131x/et131x_adapter.h b/drivers/staging/et131x/et131x_adapter.h
index a7402a3..bbbada0 100644
--- a/drivers/staging/et131x/et131x_adapter.h
+++ b/drivers/staging/et131x/et131x_adapter.h
@@ -260,12 +260,6 @@ struct et131x_adapter {
 	u32 RegistryVlanTag;	/* 802.1q Vlan TAG */
 	u32 RegistryJumboPacket;	/* Max supported ethernet packet size */
 
-	u32 RegistryTxNumBuffers;
-	u32 RegistryTxTimeInterval;
-
-	u32 RegistryRxNumBuffers;
-	u32 RegistryRxTimeInterval;
-
 	/* Validation helpers */
 	u8 RegistryNMIDisable;
 	u8 RegistryPhyLoopbk;	/* Enable Phy loopback */
diff --git a/drivers/staging/et131x/et131x_config.c b/drivers/staging/et131x/et131x_config.c
index f8273d1..a31f82a 100644
--- a/drivers/staging/et131x/et131x_config.c
+++ b/drivers/staging/et131x/et131x_config.c
@@ -129,26 +129,6 @@ extern dbg_info_t *et131x_dbginfo;
 #define PARM_PHY_COMA_MIN       0
 #define PARM_PHY_COMA_MAX       1
 
-#define PARM_RX_NUM_BUFS_DEF    4
-#define PARM_RX_NUM_BUFS_MIN    1
-#define PARM_RX_NUM_BUFS_MAX    64
-
-#define PARM_RX_TIME_INT_DEF    10
-#define PARM_RX_TIME_INT_MIN    2
-#define PARM_RX_TIME_INT_MAX    320
-
-#define PARM_TX_NUM_BUFS_DEF    4
-#define PARM_TX_NUM_BUFS_MIN    1
-#define PARM_TX_NUM_BUFS_MAX    40
-
-#define PARM_TX_TIME_INT_DEF    40
-#define PARM_TX_TIME_INT_MIN    1
-#define PARM_TX_TIME_INT_MAX    140
-
-#define PARM_RX_MEM_END_DEF     0x2bc
-#define PARM_RX_MEM_END_MIN     0
-#define PARM_RX_MEM_END_MAX     0x3ff
-
 #define PARM_MAC_STAT_DEF       1
 #define PARM_MAC_STAT_MIN       0
 #define PARM_MAC_STAT_MAX       1
@@ -166,8 +146,6 @@ extern dbg_info_t *et131x_dbginfo;
 #define PARM_NMI_DISABLE_MAX    2
 
 #define PARM_DMA_CACHE_DEF      0
-#define PARM_DMA_CACHE_MIN      0
-#define PARM_DMA_CACHE_MAX      15
 
 #define PARM_PHY_LOOPBK_DEF     0
 #define PARM_PHY_LOOPBK_MIN     0
@@ -249,11 +227,6 @@ void et131x_config_parse(struct et131x_adapter *etdev)
 	etdev->RegistryFlowControl = PARM_FLOW_CTL_DEF;
 	etdev->RegistryJumboPacket = PARM_JUMBO_PKT_DEF;
 	etdev->RegistryPhyComa = PARM_PHY_COMA_DEF;
-	etdev->RegistryRxNumBuffers = PARM_RX_NUM_BUFS_DEF;
-	etdev->RegistryRxTimeInterval = PARM_RX_TIME_INT_DEF;
-	etdev->RegistryTxNumBuffers = PARM_TX_NUM_BUFS_DEF;
-	etdev->RegistryTxTimeInterval = PARM_TX_TIME_INT_DEF;
-	etdev->RegistryRxMemEnd = PARM_RX_MEM_END_DEF;
 	etdev->RegistryMACStat = PARM_MAC_STAT_DEF;
 
 	if (et131x_nmi_disable != PARM_NMI_DISABLE_DEF)
diff --git a/drivers/staging/et131x/et131x_defs.h b/drivers/staging/et131x/et131x_defs.h
index 9d609e5..5665c6a 100644
--- a/drivers/staging/et131x/et131x_defs.h
+++ b/drivers/staging/et131x/et131x_defs.h
@@ -125,4 +125,12 @@
 /* Define order of magnitude converter */
 #define NANO_IN_A_MICRO	1000
 
+#define PARM_RX_NUM_BUFS_DEF    4
+#define PARM_RX_TIME_INT_DEF    10
+#define PARM_RX_MEM_END_DEF     0x2bc
+#define PARM_TX_TIME_INT_DEF    40
+#define PARM_TX_NUM_BUFS_DEF    4
+#define PARM_DMA_CACHE_DEF      0
+
+
 #endif /* __ET131X_DEFS_H__ */

