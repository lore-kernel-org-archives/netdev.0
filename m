From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] ixgbe: Interrupt management update for 82599
Date: Tue, 28 Apr 2009 01:42:54 -0700
Message-ID: <20090428084254.32710.36207.stgit@localhost.localdomain>
References: <20090428084236.32710.14750.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:45846 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066AbZD1InM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:43:12 -0400
In-Reply-To: <20090428084236.32710.14750.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson, Shannon <shannon.nelson@intel.com>

Update the interrupt management to correctly handle greater
than 16 queue vectors.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   90 ++++++++++++++++++++++------------------
 1 files changed, 50 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 599808b..60c3a21 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -326,8 +326,18 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	}
 
 	/* re-arm the interrupt */
-	if (count >= tx_ring->work_limit)
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->v_idx);
+	if (count >= tx_ring->work_limit) {
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
+					tx_ring->v_idx);
+		else if (tx_ring->v_idx & 0xFFFFFFFF)
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(0),
+					tx_ring->v_idx);
+		else
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(1),
+					(tx_ring->v_idx >> 32));
+	}
+
 
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
@@ -1173,7 +1183,13 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
+	else if (rx_ring->v_idx & 0xFFFFFFFF)
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(0), rx_ring->v_idx);
+	else
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1),
+				(rx_ring->v_idx >> 32));
 	napi_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -1187,6 +1203,23 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
+					   u64 qmask)
+{
+	u32 mask;
+
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
+	} else {
+		mask = (qmask & 0xFFFFFFFF);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(0), mask);
+		mask = (qmask >> 32);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(1), mask);
+	}
+	/* skip the flush */
+}
+
 /**
  * ixgbe_clean_rxonly - msix (aka one shot) rx clean routine
  * @napi: napi struct with our devices info in it
@@ -1219,7 +1252,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 		if (adapter->itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rx_ring->v_idx);
+			ixgbe_irq_enable_queues(adapter, rx_ring->v_idx);
 	}
 
 	return work_done;
@@ -1241,7 +1274,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	struct ixgbe_ring *rx_ring = NULL;
 	int work_done = 0, i;
 	long r_idx;
-	u16 enable_mask = 0;
+	u64 enable_mask = 0;
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
 	 * the budget to go below 1 because we'll exit polling */
@@ -1268,7 +1301,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 		if (adapter->itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, enable_mask);
+			ixgbe_irq_enable_queues(adapter, enable_mask);
 		return 0;
 	}
 
@@ -1488,7 +1521,8 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 {
 	u32 mask;
-	mask = IXGBE_EIMS_ENABLE_MASK;
+
+	mask = (IXGBE_EIMS_ENABLE_MASK & ~IXGBE_EIMS_RTX_QUEUE);
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		mask |= IXGBE_EIMS_GPI_SDP1;
 	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
@@ -1498,14 +1532,7 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 	}
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		/* enable the rest of the queue vectors */
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(1),
-		                (IXGBE_EIMS_RTX_QUEUE << 16));
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(2),
-		                ((IXGBE_EIMS_RTX_QUEUE << 16) |
-		                  IXGBE_EIMS_RTX_QUEUE));
-	}
+	ixgbe_irq_enable_queues(adapter, ~0);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 }
 
@@ -1629,10 +1656,12 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
  **/
 static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 {
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
+	} else {
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFF0000);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(0), ~0);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), ~0);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(2), ~0);
 	}
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
@@ -1644,18 +1673,6 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 	}
 }
 
-static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter)
-{
-	u32 mask = IXGBE_EIMS_RTX_QUEUE;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(1), mask << 16);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(2),
-		                (mask << 16 | mask));
-	}
-	/* skip the flush */
-}
-
 /**
  * ixgbe_configure_msi_and_legacy - Initialize PIN (INTA...) and MSI interrupts
  *
@@ -2721,7 +2738,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 		if (adapter->itr_setting & 1)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			ixgbe_irq_enable_queues(adapter);
+			ixgbe_irq_enable_queues(adapter, IXGBE_EIMS_RTX_QUEUE);
 	}
 	return work_done;
 }
@@ -4012,16 +4029,9 @@ static void ixgbe_watchdog(unsigned long data)
 			break;
 		case ixgbe_mac_82599EB:
 			if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-				/*
-				 * EICS(0..15) first 0-15 q vectors
-				 * EICS[1] (16..31) q vectors 16-31
-				 * EICS[2] (0..31) q vectors 32-63
-				 */
-				IXGBE_WRITE_REG(hw, IXGBE_EICS,
-				                (u32)(eics & 0xFFFF));
+				IXGBE_WRITE_REG(hw, IXGBE_EICS_EX(0),
+				                (u32)(eics & 0xFFFFFFFF));
 				IXGBE_WRITE_REG(hw, IXGBE_EICS_EX(1),
-				                (u32)(eics & 0xFFFF0000));
-				IXGBE_WRITE_REG(hw, IXGBE_EICS_EX(2),
 				                (u32)(eics >> 32));
 			} else {
 				/*

