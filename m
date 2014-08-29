From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] ixgbe: reset interface on link loss with pending Tx work from the VF
Date: Fri, 29 Aug 2014 02:30:17 -0700
Message-ID: <1409304620-23251-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53253 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbaH2Ja3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:29 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

ixgbe initiates a reset of the interface on link loss with pending Tx work
in order to clear the rings.

This patch extends the pending Tx work check to the VF interfaces with the
same purpose.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 54 +++++++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  7 ++++
 2 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2210c6d..bc3eff7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6319,25 +6319,55 @@ static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 	ixgbe_ping_all_vfs(adapter);
 }
 
+static bool ixgbe_ring_tx_pending(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct ixgbe_ring *tx_ring = adapter->tx_ring[i];
+
+		if (tx_ring->next_to_use != tx_ring->next_to_clean)
+			return true;
+	}
+
+	return false;
+}
+
+static bool ixgbe_vf_tx_pending(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
+	u32 q_per_pool = __ALIGN_MASK(1, ~vmdq->mask);
+
+	int i, j;
+
+	if (!adapter->num_vfs)
+		return false;
+
+	for (i = 0; i < adapter->num_vfs; i++) {
+		for (j = 0; j < q_per_pool; j++) {
+			u32 h, t;
+
+			h = IXGBE_READ_REG(hw, IXGBE_PVFTDHN(q_per_pool, i, j));
+			t = IXGBE_READ_REG(hw, IXGBE_PVFTDTN(q_per_pool, i, j));
+
+			if (h != t)
+				return true;
+		}
+	}
+
+	return false;
+}
+
 /**
  * ixgbe_watchdog_flush_tx - flush queues on link down
  * @adapter: pointer to the device adapter structure
  **/
 static void ixgbe_watchdog_flush_tx(struct ixgbe_adapter *adapter)
 {
-	int i;
-	int some_tx_pending = 0;
-
 	if (!netif_carrier_ok(adapter->netdev)) {
-		for (i = 0; i < adapter->num_tx_queues; i++) {
-			struct ixgbe_ring *tx_ring = adapter->tx_ring[i];
-			if (tx_ring->next_to_use != tx_ring->next_to_clean) {
-				some_tx_pending = 1;
-				break;
-			}
-		}
-
-		if (some_tx_pending) {
+		if (ixgbe_ring_tx_pending(adapter) ||
+		    ixgbe_vf_tx_pending(adapter)) {
 			/* We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index e6b07c2..dfd55d8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2194,6 +2194,8 @@ enum {
 #define IXGBE_VFLRE(_i)		((((_i) & 1) ? 0x001C0 : 0x00600))
 #define IXGBE_VFLREC(_i)		(0x00700 + ((_i) * 4))
 /* Translated register #defines */
+#define IXGBE_PVFTDH(P)		(0x06010 + (0x40 * (P)))
+#define IXGBE_PVFTDT(P)		(0x06018 + (0x40 * (P)))
 #define IXGBE_PVFTDWBAL(P)	(0x06038 + (0x40 * (P)))
 #define IXGBE_PVFTDWBAH(P)	(0x0603C + (0x40 * (P)))
 
@@ -2202,6 +2204,11 @@ enum {
 #define IXGBE_PVFTDWBAHn(q_per_pool, vf_number, vf_q_index) \
 		(IXGBE_PVFTDWBAH((q_per_pool)*(vf_number) + (vf_q_index)))
 
+#define IXGBE_PVFTDHN(q_per_pool, vf_number, vf_q_index) \
+		(IXGBE_PVFTDH((q_per_pool)*(vf_number) + (vf_q_index)))
+#define IXGBE_PVFTDTN(q_per_pool, vf_number, vf_q_index) \
+		(IXGBE_PVFTDT((q_per_pool)*(vf_number) + (vf_q_index)))
+
 enum ixgbe_fdir_pballoc_type {
 	IXGBE_FDIR_PBALLOC_NONE = 0,
 	IXGBE_FDIR_PBALLOC_64K  = 1,
-- 
1.9.3
