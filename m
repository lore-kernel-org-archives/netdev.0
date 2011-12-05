From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] igb: Update DMA Coalescing threshold calculation.
Date: Mon,  5 Dec 2011 00:20:38 -0800
Message-ID: <1323073241-21144-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55396 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188Ab1LEIUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 03:20:47 -0500
In-Reply-To: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

This patch updates the DMA Coalescing feature parameters to account for
larger MTUs. Previously, sufficient space may not have been allocated in
the receive buffer, causing packet drop.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b66b8aa..143cfeb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7061,15 +7061,28 @@ static void igb_init_dmac(struct igb_adapter *adapter, u32 pba)
 			wr32(E1000_DMCTXTH, 0);
 
 			/*
-			 * DMA Coalescing high water mark needs to be higher
-			 * than the RX threshold. set hwm to PBA -  2 * max
-			 * frame size
+			 * DMA Coalescing high water mark needs to be greater
+			 * than the Rx threshold. Set hwm to PBA - max frame
+			 * size in 16B units, capping it at PBA - 6KB.
 			 */
-			hwm = pba - (2 * adapter->max_frame_size);
+			hwm = 64 * pba - adapter->max_frame_size / 16;
+			if (hwm < 64 * (pba - 6))
+				hwm = 64 * (pba - 6);
+			reg = rd32(E1000_FCRTC);
+			reg &= ~E1000_FCRTC_RTH_COAL_MASK;
+			reg |= ((hwm << E1000_FCRTC_RTH_COAL_SHIFT)
+				& E1000_FCRTC_RTH_COAL_MASK);
+			wr32(E1000_FCRTC, reg);
+
+			/*
+			 * Set the DMA Coalescing Rx threshold to PBA - 2 * max
+			 * frame size, capping it at PBA - 10KB.
+			 */
+			dmac_thr = pba - adapter->max_frame_size / 512;
+			if (dmac_thr < pba - 10)
+				dmac_thr = pba - 10;
 			reg = rd32(E1000_DMACR);
 			reg &= ~E1000_DMACR_DMACTHR_MASK;
-			dmac_thr = pba - 4;
-
 			reg |= ((dmac_thr << E1000_DMACR_DMACTHR_SHIFT)
 				& E1000_DMACR_DMACTHR_MASK);
 
@@ -7085,7 +7098,6 @@ static void igb_init_dmac(struct igb_adapter *adapter, u32 pba)
 			 * coalescing(smart fifb)-UTRESH=0
 			 */
 			wr32(E1000_DMCRTRH, 0);
-			wr32(E1000_FCRTC, hwm);
 
 			reg = (IGB_DMCTLX_DCFLUSH_DIS | 0x4);
 
-- 
1.7.6.4
