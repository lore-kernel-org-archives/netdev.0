From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] igb: Move DMA Coalescing init code to separate function.
Date: Fri, 21 Oct 2011 03:32:00 -0700
Message-ID: <1319193121-2729-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30637 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754225Ab1JUKcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 06:32:07 -0400
In-Reply-To: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch moves the DMA Coalescing feature initialization code from
igb_reset to a new function and replaces it with a call to the new
function.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |  124 ++++++++++++++++-------------
 1 files changed, 68 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index f689aa1..b186353 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -204,6 +204,7 @@ static struct pci_error_handlers igb_err_handler = {
 	.resume = igb_io_resume,
 };
 
+static void igb_init_dmac(struct igb_adapter *adapter, u32 pba);
 
 static struct pci_driver igb_driver = {
 	.name     = igb_driver_name,
@@ -1728,63 +1729,8 @@ void igb_reset(struct igb_adapter *adapter)
 
 	if (hw->mac.ops.init_hw(hw))
 		dev_err(&pdev->dev, "Hardware Error\n");
-	if (hw->mac.type > e1000_82580) {
-		if (adapter->flags & IGB_FLAG_DMAC) {
-			u32 reg;
-
-			/*
-			 * DMA Coalescing high water mark needs to be higher
-			 * than * the * Rx threshold.  The Rx threshold is
-			 * currently * pba - 6, so we * should use a high water
-			 * mark of pba * - 4. */
-			hwm = (pba - 4) << 10;
-
-			reg = (((pba-6) << E1000_DMACR_DMACTHR_SHIFT)
-			       & E1000_DMACR_DMACTHR_MASK);
-
-			/* transition to L0x or L1 if available..*/
-			reg |= (E1000_DMACR_DMAC_EN | E1000_DMACR_DMAC_LX_MASK);
-
-			/* watchdog timer= +-1000 usec in 32usec intervals */
-			reg |= (1000 >> 5);
-			wr32(E1000_DMACR, reg);
-
-			/* no lower threshold to disable coalescing(smart fifb)
-			 * -UTRESH=0*/
-			wr32(E1000_DMCRTRH, 0);
-
-			/* set hwm to PBA -  2 * max frame size */
-			wr32(E1000_FCRTC, hwm);
 
-			/*
-			 * This sets the time to wait before requesting tran-
-			 * sition to * low power state to number of usecs needed
-			 * to receive 1 512 * byte frame at gigabit line rate
-			 */
-			reg = rd32(E1000_DMCTLX);
-			reg |= IGB_DMCTLX_DCFLUSH_DIS;
-
-			/* Delay 255 usec before entering Lx state. */
-			reg |= 0xFF;
-			wr32(E1000_DMCTLX, reg);
-
-			/* free space in Tx packet buffer to wake from DMAC */
-			wr32(E1000_DMCTXTH,
-			     (IGB_MIN_TXPBSIZE -
-			     (IGB_TX_BUF_4096 + adapter->max_frame_size))
-			     >> 6);
-
-			/* make low power state decision controlled by DMAC */
-			reg = rd32(E1000_PCIEMISC);
-			reg |= E1000_PCIEMISC_LX_DECISION;
-			wr32(E1000_PCIEMISC, reg);
-		} /* end if IGB_FLAG_DMAC set */
-	}
-	if (hw->mac.type == e1000_82580) {
-		u32 reg = rd32(E1000_PCIEMISC);
-		wr32(E1000_PCIEMISC,
-		                reg & ~E1000_PCIEMISC_LX_DECISION);
-	}
+	igb_init_dmac(adapter, pba);
 	if (!netif_running(adapter->netdev))
 		igb_power_down_link(adapter);
 
@@ -7098,4 +7044,70 @@ static void igb_vmm_control(struct igb_adapter *adapter)
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
