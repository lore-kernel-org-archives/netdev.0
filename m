From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 06/20] ixgbe: move Tx ring configuration into a
	separate function
Date: Thu, 19 Aug 2010 16:35:12 -0700
Message-ID: <20100819233509.10335.23922.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:46226 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751598Ab0HSXfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:35:39 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch moves the Tx ring configuration into a separate function.  In
addition the function drops the setting of the head writeback RO bit since
head writeback is no longer used within ixgbe.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   69 +++++++++++++++++-----------------------
 1 files changed, 29 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c4e4207..37d1f64 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2424,6 +2424,32 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	e_info(hw, "Legacy interrupt IVAR setup done\n");
 }
 
+/**
+ * ixgbe_configure_tx_ring - Configure 8259x Tx ring after Reset
+ * @adapter: board private structure
+ * @ring: structure containing ring specific data
+ *
+ * Configure the Tx descriptor ring after a reset.
+ **/
+ static void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
+				     struct ixgbe_ring *ring)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u64 tdba = ring->dma;
+	u16 reg_idx = ring->reg_idx;
+
+	IXGBE_WRITE_REG(hw, IXGBE_TDBAL(reg_idx),
+	                (tdba & DMA_BIT_MASK(32)));
+	IXGBE_WRITE_REG(hw, IXGBE_TDBAH(reg_idx), (tdba >> 32));
+	IXGBE_WRITE_REG(hw, IXGBE_TDLEN(reg_idx),
+			ring->count * sizeof(union ixgbe_adv_tx_desc));
+	IXGBE_WRITE_REG(hw, IXGBE_TDH(reg_idx), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_TDT(reg_idx), 0);
+	ring->head = IXGBE_TDH(reg_idx);
+	ring->tail = IXGBE_TDT(reg_idx);
+
+}
+
 static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -2471,48 +2497,11 @@ static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 {
-	u64 tdba;
-	struct ixgbe_hw *hw = &adapter->hw;
-	u32 i, j, tdlen, txctrl;
+	u32 i;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct ixgbe_ring *ring = adapter->tx_ring[i];
-		j = ring->reg_idx;
-		tdba = ring->dma;
-		tdlen = ring->count * sizeof(union ixgbe_adv_tx_desc);
-		IXGBE_WRITE_REG(hw, IXGBE_TDBAL(j),
-		                (tdba & DMA_BIT_MASK(32)));
-		IXGBE_WRITE_REG(hw, IXGBE_TDBAH(j), (tdba >> 32));
-		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(j), tdlen);
-		IXGBE_WRITE_REG(hw, IXGBE_TDH(j), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_TDT(j), 0);
-		adapter->tx_ring[i]->head = IXGBE_TDH(j);
-		adapter->tx_ring[i]->tail = IXGBE_TDT(j);
-		/*
-		 * Disable Tx Head Writeback RO bit, since this hoses
-		 * bookkeeping if things aren't delivered in order.
-		 */
-		switch (hw->mac.type) {
-		case ixgbe_mac_82598EB:
-			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(j));
-			break;
-		case ixgbe_mac_82599EB:
-		default:
-			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(j));
-			break;
-		}
-		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
-		switch (hw->mac.type) {
-		case ixgbe_mac_82598EB:
-			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(j), txctrl);
-			break;
-		case ixgbe_mac_82599EB:
-		default:
-			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(j), txctrl);
-			break;
-		}
-	}
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		ixgbe_configure_tx_ring(adapter, adapter->tx_ring[i]);
 
 	ixgbe_setup_mtqc(adapter);
 }

