From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] ixgbe: Fix issues with SR-IOV loopback when flow control is disabled
Date: Sat, 17 Mar 2012 02:07:34 -0700
Message-ID: <1331975254-19443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4909 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168Ab2CQJHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 05:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch allows us to avoid a Tx hang when SR-IOV is enabled.  This hang
can be triggered by sending small packets at a rate that was triggering Rx
missed errors from the adapter while the internal Tx switch and at least
one VF are enabled.

This was all due to the fact that under heavy stress the Rx FIFO never
drained below the flow control high water mark.  This resulted in the Tx
FIFO being head of line blocked due to the fact that it relies on the flow
control high water mark to determine when it is acceptable for the Tx to
place a packet in the Rx FIFO.

The resolution for this is to set the FCRTH value to the RXPBSIZE - 32 so
that even if the ring is almost completely full we can still place Tx
packets on the Rx ring and drop incoming Rx traffic if we do not have
sufficient space available in the Rx FIFO.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 383b941..7d81bee 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -2011,13 +2011,20 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, mflcn_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, fccfg_reg);
 
-	fcrth = hw->fc.high_water[packetbuf_num] << 10;
 	fcrtl = hw->fc.low_water << 10;
 
 	if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
+		fcrth = hw->fc.high_water[packetbuf_num] << 10;
 		fcrth |= IXGBE_FCRTH_FCEN;
 		if (hw->fc.send_xon)
 			fcrtl |= IXGBE_FCRTL_XONE;
+	} else {
+		/*
+		 * If Tx flow control is disabled, set our high water mark
+		 * to Rx FIFO size minus 32 in order prevent Tx switch
+		 * loopback from stalling on DMA.
+		 */
+		fcrth = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num)) - 32;
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num), fcrth);
-- 
1.7.7.6
