From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] igb: Split igb_update_dca into separate Tx and Rx functions
Date: Fri, 19 Oct 2012 04:45:14 -0700
Message-ID: <1350647114-6768-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36113 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758645Ab2JSLpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 07:45:44 -0400
In-Reply-To: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that igb_update_dca is broken into two halves, one
for Rx and one for Tx.  The advantage to this is primarily readability.

In addition I am enabling relaxed ordering for reads from hardware since
this is supported on all of the igb parts.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h |  3 ++
 drivers/net/ethernet/intel/igb/igb_main.c    | 80 +++++++++++++++++-----------
 2 files changed, 52 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index e85c453..44b76b3 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -172,10 +172,13 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DCA_RXCTRL_DESC_DCA_EN (1 << 5) /* DCA Rx Desc enable */
 #define E1000_DCA_RXCTRL_HEAD_DCA_EN (1 << 6) /* DCA Rx Desc header enable */
 #define E1000_DCA_RXCTRL_DATA_DCA_EN (1 << 7) /* DCA Rx Desc payload enable */
+#define E1000_DCA_RXCTRL_DESC_RRO_EN (1 << 9) /* DCA Rx rd Desc Relax Order */
 
 #define E1000_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
 #define E1000_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
+#define E1000_DCA_TXCTRL_DESC_RRO_EN (1 << 9) /* Tx rd Desc Relax Order */
 #define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
+#define E1000_DCA_TXCTRL_DATA_RRO_EN (1 << 13) /* Tx rd data Relax Order */
 
 /* Additional DCA related definitions, note change in position of CPUID */
 #define E1000_DCA_TXCTRL_CPUID_MASK_82576 0xFF000000 /* Tx CPUID Mask */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e7b1027..87abb57 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4851,45 +4851,63 @@ static irqreturn_t igb_msix_ring(int irq, void *data)
 }
 
 #ifdef CONFIG_IGB_DCA
+static void igb_update_tx_dca(struct igb_adapter *adapter,
+			      struct igb_ring *tx_ring,
+			      int cpu)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 txctrl = dca3_get_tag(tx_ring->dev, cpu);
+
+	if (hw->mac.type != e1000_82575)
+		txctrl <<= E1000_DCA_TXCTRL_CPUID_SHIFT;
+
+	/*
+	 * We can enable relaxed ordering for reads, but not writes when
+	 * DCA is enabled.  This is due to a known issue in some chipsets
+	 * which will cause the DCA tag to be cleared.
+	 */
+	txctrl |= E1000_DCA_TXCTRL_DESC_RRO_EN |
+		  E1000_DCA_TXCTRL_DATA_RRO_EN |
+		  E1000_DCA_TXCTRL_DESC_DCA_EN;
+
+	wr32(E1000_DCA_TXCTRL(tx_ring->reg_idx), txctrl);
+}
+
+static void igb_update_rx_dca(struct igb_adapter *adapter,
+			      struct igb_ring *rx_ring,
+			      int cpu)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 rxctrl = dca3_get_tag(&adapter->pdev->dev, cpu);
+
+	if (hw->mac.type != e1000_82575)
+		rxctrl <<= E1000_DCA_RXCTRL_CPUID_SHIFT;
+
+	/*
+	 * We can enable relaxed ordering for reads, but not writes when
+	 * DCA is enabled.  This is due to a known issue in some chipsets
+	 * which will cause the DCA tag to be cleared.
+	 */
+	rxctrl |= E1000_DCA_RXCTRL_DESC_RRO_EN |
+		  E1000_DCA_RXCTRL_DESC_DCA_EN;
+
+	wr32(E1000_DCA_RXCTRL(rx_ring->reg_idx), rxctrl);
+}
+
 static void igb_update_dca(struct igb_q_vector *q_vector)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
-	struct e1000_hw *hw = &adapter->hw;
 	int cpu = get_cpu();
 
 	if (q_vector->cpu == cpu)
 		goto out_no_update;
 
-	if (q_vector->tx.ring) {
-		int q = q_vector->tx.ring->reg_idx;
-		u32 dca_txctrl = rd32(E1000_DCA_TXCTRL(q));
-		if (hw->mac.type == e1000_82575) {
-			dca_txctrl &= ~E1000_DCA_TXCTRL_CPUID_MASK;
-			dca_txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
-		} else {
-			dca_txctrl &= ~E1000_DCA_TXCTRL_CPUID_MASK_82576;
-			dca_txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu) <<
-			              E1000_DCA_TXCTRL_CPUID_SHIFT;
-		}
-		dca_txctrl |= E1000_DCA_TXCTRL_DESC_DCA_EN;
-		wr32(E1000_DCA_TXCTRL(q), dca_txctrl);
-	}
-	if (q_vector->rx.ring) {
-		int q = q_vector->rx.ring->reg_idx;
-		u32 dca_rxctrl = rd32(E1000_DCA_RXCTRL(q));
-		if (hw->mac.type == e1000_82575) {
-			dca_rxctrl &= ~E1000_DCA_RXCTRL_CPUID_MASK;
-			dca_rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
-		} else {
-			dca_rxctrl &= ~E1000_DCA_RXCTRL_CPUID_MASK_82576;
-			dca_rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu) <<
-			              E1000_DCA_RXCTRL_CPUID_SHIFT;
-		}
-		dca_rxctrl |= E1000_DCA_RXCTRL_DESC_DCA_EN;
-		dca_rxctrl |= E1000_DCA_RXCTRL_HEAD_DCA_EN;
-		dca_rxctrl |= E1000_DCA_RXCTRL_DATA_DCA_EN;
-		wr32(E1000_DCA_RXCTRL(q), dca_rxctrl);
-	}
+	if (q_vector->tx.ring)
+		igb_update_tx_dca(adapter, q_vector->tx.ring, cpu);
+
+	if (q_vector->rx.ring)
+		igb_update_rx_dca(adapter, q_vector->rx.ring, cpu);
+
 	q_vector->cpu = cpu;
 out_no_update:
 	put_cpu();
-- 
1.7.11.7
