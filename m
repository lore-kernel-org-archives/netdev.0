From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 18/20] ixgbe: combine Rx into into
	ixgbe_configure_rx
Date: Thu, 19 Aug 2010 16:40:06 -0700
Message-ID: <20100819234004.10335.44104.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:58944
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752158Ab0HSXk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:40:28 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The Rx init is currently split over ixgbe_configure, ixgbe_configure_rx,
and ixgbe_up_complete.  Instead of leaving it split over 3 function it is
easier to consolidate them all into ixgbe_configure_rx.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  152 +++++++++++++++++++++++++---------------
 1 files changed, 95 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fd2026e..c88ba13 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2574,6 +2574,8 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 
 	srrctl &= ~IXGBE_SRRCTL_BSIZEHDR_MASK;
 	srrctl &= ~IXGBE_SRRCTL_BSIZEPKT_MASK;
+	if (adapter->num_vfs)
+		srrctl |= IXGBE_SRRCTL_DROP_EN;
 
 	srrctl |= (IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
 		  IXGBE_SRRCTL_BSIZEHDR_MASK;
@@ -2705,13 +2707,72 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(reg_idx), rscctrl);
 }
 
+/**
+ *  ixgbe_set_uta - Set unicast filter table address
+ *  @adapter: board private structure
+ *
+ *  The unicast table address is a register array of 32-bit registers.
+ *  The table is meant to be used in a way similar to how the MTA is used
+ *  however due to certain limitations in the hardware it is necessary to
+ *  set all the hash bits to 1 and use the VMOLR ROPE bit as a promiscuous
+ *  enable bit to allow vlan tag stripping when promiscuous mode is enabled
+ **/
+static void ixgbe_set_uta(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+
+	/* The UTA table only exists on 82599 hardware and newer */
+	if (hw->mac.type < ixgbe_mac_82599EB)
+		return;
+
+	/* we only need to do this if VMDq is enabled */
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		return;
+
+	for (i = 0; i < 128; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_UTA(i), ~0);
+}
+
+#define IXGBE_MAX_RX_DESC_POLL 10
+static void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
+				       struct ixgbe_ring *ring)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int reg_idx = ring->reg_idx;
+	int wait_loop = IXGBE_MAX_RX_DESC_POLL;
+	u32 rxdctl;
+
+	/* RXDCTL.EN will return 0 on 82598 if link is down, so skip it */
+	if (hw->mac.type == ixgbe_mac_82598EB &&
+	    !(IXGBE_READ_REG(hw, IXGBE_LINKS) & IXGBE_LINKS_UP))
+		return;
+
+	do {
+		msleep(1);
+		rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
+	} while (--wait_loop && !(rxdctl & IXGBE_RXDCTL_ENABLE));
+
+	if (!wait_loop) {
+		e_err(drv, "RXDCTL.ENABLE on Rx queue %d not set within "
+		      "the polling period\n", reg_idx);
+	}
+}
+
 static void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 				    struct ixgbe_ring *ring)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 rdba = ring->dma;
+	u32 rxdctl;
 	u16 reg_idx = ring->reg_idx;
 
+	/* disable queue to avoid issues while updating state */
+	rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
+	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx),
+			rxdctl & ~IXGBE_RXDCTL_ENABLE);
+	IXGBE_WRITE_FLUSH(hw);
+
 	IXGBE_WRITE_REG(hw, IXGBE_RDBAL(reg_idx), (rdba & DMA_BIT_MASK(32)));
 	IXGBE_WRITE_REG(hw, IXGBE_RDBAH(reg_idx), (rdba >> 32));
 	IXGBE_WRITE_REG(hw, IXGBE_RDLEN(reg_idx),
@@ -2720,6 +2781,28 @@ static void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_RDT(reg_idx), 0);
 	ring->head = IXGBE_RDH(reg_idx);
 	ring->tail = IXGBE_RDT(reg_idx);
+
+	ixgbe_configure_srrctl(adapter, ring);
+	ixgbe_configure_rscctl(adapter, ring);
+
+	if (hw->mac.type == ixgbe_mac_82598EB) {
+		/*
+		 * enable cache line friendly hardware writes:
+		 * PTHRESH=32 descriptors (half the internal cache),
+		 * this also removes ugly rx_no_buffer_count increment
+		 * HTHRESH=4 descriptors (to minimize latency on fetch)
+		 * WTHRESH=8 burst writeback up to two cache lines
+		 */
+		rxdctl &= ~0x3FFFFF;
+		rxdctl |=  0x080420;
+	}
+
+	/* enable receive descriptor ring */
+	rxdctl |= IXGBE_RXDCTL_ENABLE;
+	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx), rxdctl);
+
+	ixgbe_rx_desc_queue_enable(adapter, ring);
+	ixgbe_alloc_rx_buffers(adapter, ring, IXGBE_DESC_UNUSED(ring));
 }
 
 static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
@@ -2908,7 +2991,6 @@ static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
 static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct ixgbe_ring *rx_ring;
 	int i;
 	u32 rxctrl;
 
@@ -2919,10 +3001,12 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	ixgbe_setup_psrtype(adapter);
 	ixgbe_setup_rdrxctl(adapter);
 
-	/* Program MRQC for the distribution of queues */
+	/* Program registers for the distribution of queues */
 	ixgbe_setup_mrqc(adapter);
 	ixgbe_configure_virtualization(adapter);
 
+	ixgbe_set_uta(adapter);
+
 	/* set_rx_buffer_len must be called before ring initialization */
 	ixgbe_set_rx_buffer_len(adapter);
 
@@ -2930,13 +3014,16 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	 * Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring
 	 */
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		rx_ring = adapter->rx_ring[i];
-		ixgbe_configure_rx_ring(adapter, rx_ring);
-		ixgbe_configure_srrctl(adapter, rx_ring);
-		ixgbe_configure_rscctl(adapter, rx_ring);
-	}
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		ixgbe_configure_rx_ring(adapter, adapter->rx_ring[i]);
 
+	/* disable drop enable for 82598 parts */
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		rxctrl |= IXGBE_RXCTRL_DMBYPS;
+
+	/* enable all receives */
+	rxctrl |= IXGBE_RXCTRL_RXEN;
+	hw->mac.ops.enable_rx_dma(hw, rxctrl);
 }
 
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
@@ -3306,9 +3393,6 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 
 	ixgbe_configure_tx(adapter);
 	ixgbe_configure_rx(adapter);
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbe_alloc_rx_buffers(adapter, adapter->rx_ring[i],
-		                       (adapter->rx_ring[i]->count - 1));
 }
 
 static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
@@ -3389,28 +3473,6 @@ link_cfg_out:
 	return ret;
 }
 
-#define IXGBE_MAX_RX_DESC_POLL 10
-static inline void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
-	                                      int rxr)
-{
-	int j = adapter->rx_ring[rxr]->reg_idx;
-	int k;
-
-	for (k = 0; k < IXGBE_MAX_RX_DESC_POLL; k++) {
-		if (IXGBE_READ_REG(&adapter->hw,
-		                   IXGBE_RXDCTL(j)) & IXGBE_RXDCTL_ENABLE)
-			break;
-		else
-			msleep(1);
-	}
-	if (k >= IXGBE_MAX_RX_DESC_POLL) {
-		e_err(drv, "RXDCTL.ENABLE on Rx queue %d not set within "
-		      "the polling period\n", rxr);
-	}
-	ixgbe_release_rx_desc(&adapter->hw, adapter->rx_ring[rxr],
-	                      (adapter->rx_ring[rxr]->count - 1));
-}
-
 static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -3462,35 +3524,12 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int i, j = 0;
-	int num_rx_rings = adapter->num_rx_queues;
 	int err;
-	u32 rxdctl;
 	u32 ctrl_ext;
 
 	ixgbe_get_hw_control(adapter);
 	ixgbe_setup_gpie(adapter);
 
-	for (i = 0; i < num_rx_rings; i++) {
-		j = adapter->rx_ring[i]->reg_idx;
-		rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
-		/* enable PTHRESH=32 descriptors (half the internal cache)
-		 * and HTHRESH=0 descriptors (to minimize latency on fetch),
-		 * this also removes a pesky rx_no_buffer_count increment */
-		rxdctl |= 0x0020;
-		rxdctl |= IXGBE_RXDCTL_ENABLE;
-		IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(j), rxdctl);
-		if (hw->mac.type == ixgbe_mac_82599EB)
-			ixgbe_rx_desc_queue_enable(adapter, i);
-	}
-	/* enable all receives */
-	rxdctl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		rxdctl |= (IXGBE_RXCTRL_DMBYPS | IXGBE_RXCTRL_RXEN);
-	else
-		rxdctl |= IXGBE_RXCTRL_RXEN;
-	hw->mac.ops.enable_rx_dma(hw, rxdctl);
-
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
 		ixgbe_configure_msix(adapter);
 	else
@@ -3505,7 +3544,6 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	/* clear any pending interrupts, may auto mask */
 	IXGBE_READ_REG(hw, IXGBE_EICR);
-
 	ixgbe_irq_enable(adapter);
 
 	/*

