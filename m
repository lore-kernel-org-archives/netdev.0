From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] igb: move DMA Coalescing feature code into separate function.
Date: Tue, 11 Oct 2011 20:38:26 -0700
Message-ID: <1318390708-12232-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Sowles <jacob.r.sowles@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34679 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148Ab1JLDip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 23:38:45 -0400
In-Reply-To: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Sowles <jacob.r.sowles@intel.com>

DMA Coalescing code needs to be executed during reset, if enabled.  Moved
code to separate function and added a call to it in igb_reset.

Signed-off-by: Jacob Sowles <jacob.r.sowles@intel.com>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   66 +++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 7c6e526..6fdf2e0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6907,4 +6907,70 @@ static void igb_vmm_control(struct igb_adapter *adapter)
 	}
 }
 
+static void igb_init_dmac(struct igb_adapter *adapter, u32 pba)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 dmac_thr;
+	u16 hwm;
+
+	if (hw->mac.type > e1000_82580) {
+		if (adapter->flags & IGB_FLAG_DMAC) {
+			u32 reg;
+
+			/* force threshold to 0. */
+			wr32(E1000_DMCTXTH, 0);
+
+			/*
+			 * DMA Coalescing high water mark needs to be higher
+			 * than the RX threshold. set hwm to PBA -  2 * max
+			 * frame size
+			 */
+			hwm = pba - (2 * adapter->max_frame_size);
+			reg = rd32(E1000_DMACR);
+			reg &= ~E1000_DMACR_DMACTHR_MASK;
+			dmac_thr = pba - 4;
+
+			reg |= ((dmac_thr << E1000_DMACR_DMACTHR_SHIFT)
+				& E1000_DMACR_DMACTHR_MASK);
+
+			/* transition to L0x or L1 if available..*/
+			reg |= (E1000_DMACR_DMAC_EN | E1000_DMACR_DMAC_LX_MASK);
+
+			/* watchdog timer= +-1000 usec in 32usec intervals */
+			reg |= (1000 >> 5);
+			wr32(E1000_DMACR, reg);
+
+			/*
+			 * no lower threshold to disable
+			 * coalescing(smart fifb)-UTRESH=0
+			 */
+			wr32(E1000_DMCRTRH, 0);
+			wr32(E1000_FCRTC, hwm);
+
+			reg = (IGB_DMCTLX_DCFLUSH_DIS | 0x4);
+
+			wr32(E1000_DMCTLX, reg);
+
+			/*
+			 * free space in tx packet buffer to wake from
+			 * DMA coal
+			 */
+			wr32(E1000_DMCTXTH, (IGB_MIN_TXPBSIZE -
+			     (IGB_TX_BUF_4096 + adapter->max_frame_size)) >> 6);
+
+			/*
+			 * make low power state decision controlled
+			 * by DMA coal
+			 */
+			reg = rd32(E1000_PCIEMISC);
+			reg &= ~E1000_PCIEMISC_LX_DECISION;
+			wr32(E1000_PCIEMISC, reg);
+		} /* endif adapter->dmac is not disabled */
+	} else if (hw->mac.type == e1000_82580) {
+		u32 reg = rd32(E1000_PCIEMISC);
+		wr32(E1000_PCIEMISC, reg & ~E1000_PCIEMISC_LX_DECISION);
+		wr32(E1000_DMACR, 0);
+	}
+}
+
 /* igb_main.c */
-- 
1.7.6.4
