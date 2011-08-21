From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] ixgbe: Update TXDCTL configuration to correctly handle WTHRESH
Date: Sun, 21 Aug 2011 00:29:21 -0700
Message-ID: <1313911761-11709-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55753 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317Ab1HUH3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Aug 2011 03:29:30 -0400
In-Reply-To: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change updated the TXDCTL configuration.  The main goal is to be much
more explicit about the configuration and avoid a possible fake TX hang
when the interrupt throttle rate is set to 0.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   35 +++++++++++++------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 35f9912..8cf8670 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2359,13 +2359,11 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 tdba = ring->dma;
 	int wait_loop = 10;
-	u32 txdctl;
+	u32 txdctl = IXGBE_TXDCTL_ENABLE;
 	u8 reg_idx = ring->reg_idx;
 
 	/* disable queue to avoid issues while updating state */
-	txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(reg_idx));
-	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx),
-			txdctl & ~IXGBE_TXDCTL_ENABLE);
+	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), 0);
 	IXGBE_WRITE_FLUSH(hw);
 
 	IXGBE_WRITE_REG(hw, IXGBE_TDBAL(reg_idx),
@@ -2377,18 +2375,22 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_TDT(reg_idx), 0);
 	ring->tail = hw->hw_addr + IXGBE_TDT(reg_idx);
 
-	/* configure fetching thresholds */
-	if (adapter->rx_itr_setting == 0) {
-		/* cannot set wthresh when itr==0 */
-		txdctl &= ~0x007F0000;
-	} else {
-		/* enable WTHRESH=8 descriptors, to encourage burst writeback */
-		txdctl |= (8 << 16);
-	}
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		/* PThresh workaround for Tx hang with DFP enabled. */
-		txdctl |= 32;
-	}
+	/*
+	 * set WTHRESH to encourage burst writeback, it should not be set
+	 * higher than 1 when ITR is 0 as it could cause false TX hangs
+	 *
+	 * In order to avoid issues WTHRESH + PTHRESH should always be equal
+	 * to or less than the number of on chip descriptors, which is
+	 * currently 40.
+	 */
+	if (!adapter->tx_itr_setting || !adapter->rx_itr_setting)
+		txdctl |= (1 << 16);	/* WTHRESH = 1 */
+	else
+		txdctl |= (8 << 16);	/* WTHRESH = 8 */
+
+	/* PTHRESH=32 is needed to avoid a Tx hang with DFP enabled. */
+	txdctl |= (1 << 8) |	/* HTHRESH = 1 */
+		   32;		/* PTHRESH = 32 */
 
 	/* reinitialize flowdirector state */
 	if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) &&
@@ -2403,7 +2405,6 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	clear_bit(__IXGBE_HANG_CHECK_ARMED, &ring->state);
 
 	/* enable queue */
-	txdctl |= IXGBE_TXDCTL_ENABLE;
 	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), txdctl);
 
 	/* TXDCTL.EN will return 0 on 82598 if link is down, so skip it */
-- 
1.7.6

