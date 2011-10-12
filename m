From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/12] igb: Fix features that are currently 82580 only and should also be i350
Date: Tue, 11 Oct 2011 20:38:22 -0700
Message-ID: <1318390708-12232-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34679 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab1JLDio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 23:38:44 -0400
In-Reply-To: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change allows support for per packet timesync and global device reset
on the i350 adapter.  These features were supported on both 82580 and i350
however it looks like several checks where not updated and as such the i350
support was not enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 29ec64f..ff4a335 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -563,7 +563,7 @@ static cycle_t igb_read_clock(const struct cyclecounter *tc)
 	 * the lowest register is SYSTIMR instead of SYSTIML.  However we never
 	 * adjusted TIMINCA so SYSTIMR will just read as all 0s so ignore it.
 	 */
-	if (hw->mac.type == e1000_82580) {
+	if (hw->mac.type >= e1000_82580) {
 		stamp = rd32(E1000_SYSTIMR) >> 8;
 		shift = IGB_82580_TSYNC_SHIFT;
 	}
@@ -1320,7 +1320,7 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (adapter->msix_entries) {
-		u32 ims = E1000_IMS_LSC | E1000_IMS_DOUTSYNC;
+		u32 ims = E1000_IMS_LSC | E1000_IMS_DOUTSYNC | E1000_IMS_DRSTA;
 		u32 regval = rd32(E1000_EIAC);
 		wr32(E1000_EIAC, regval | adapter->eims_enable_mask);
 		regval = rd32(E1000_EIAM);
@@ -1330,9 +1330,6 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 			wr32(E1000_MBVFIMR, 0xFF);
 			ims |= E1000_IMS_VMMB;
 		}
-		if (adapter->hw.mac.type == e1000_82580)
-			ims |= E1000_IMS_DRSTA;
-
 		wr32(E1000_IMS, ims);
 	} else {
 		wr32(E1000_IMS, IMS_ENABLE_MASK |
@@ -3042,7 +3039,7 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	srrctl |= (PAGE_SIZE / 2) >> E1000_SRRCTL_BSIZEPKT_SHIFT;
 #endif
 	srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
-	if (hw->mac.type == e1000_82580)
+	if (hw->mac.type >= e1000_82580)
 		srrctl |= E1000_SRRCTL_TIMESTAMP;
 	/* Only set Drop Enable if we are supporting multiple queues */
 	if (adapter->vfs_allocated_count || adapter->num_rx_queues > 1)
@@ -4393,7 +4390,7 @@ static void igb_tx_timeout(struct net_device *netdev)
 	/* Do the reset outside of interrupt context */
 	adapter->tx_timeout_count++;
 
-	if (hw->mac.type == e1000_82580)
+	if (hw->mac.type >= e1000_82580)
 		hw->dev_spec._82575.global_device_reset = true;
 
 	schedule_work(&adapter->reset_task);
@@ -5511,7 +5508,7 @@ static void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
 	 * The 82580 starts with 1ns at bit 0 in RX/TXSTMPL, shift this up to
 	 * 24 to match clock shift we setup earlier.
 	 */
-	if (adapter->hw.mac.type == e1000_82580)
+	if (adapter->hw.mac.type >= e1000_82580)
 		regval <<= IGB_82580_TSYNC_SHIFT;
 
 	ns = timecounter_cyc2time(&adapter->clock, regval);
@@ -6206,7 +6203,7 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev,
 	 * timestamped, so enable timestamping in all packets as
 	 * long as one rx filter was configured.
 	 */
-	if ((hw->mac.type == e1000_82580) && tsync_rx_ctl) {
+	if ((hw->mac.type >= e1000_82580) && tsync_rx_ctl) {
 		tsync_rx_ctl = E1000_TSYNCRXCTL_ENABLED;
 		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_ALL;
 	}
-- 
1.7.6.4
