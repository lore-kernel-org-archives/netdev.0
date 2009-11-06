From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbe: Fix checking TFCS register for TXOFF
	status when DCB is enabled
Date: Fri, 06 Nov 2009 14:56:00 -0800
Message-ID: <20091106225559.28063.467.stgit@localhost.localdomain>
References: <20091106225526.28063.83720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:53002
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760177AbZKFW4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 17:56:14 -0500
In-Reply-To: <20091106225526.28063.83720.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

When DCB is enabled, the ixgbe_check_tx_hang() should check the corresponding
TC's TXOFF in TFCS based on the TC that the tx ring belongs to. Adds a
function to map from the tx_ring hw reg_idx to the correspodning TC and read
TFCS accordingly.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   52 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 26fc1df..2d0f618 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -226,6 +226,56 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
 	/* tx_buffer_info must be completely set up in the transmit path */
 }
 
+/**
+ * ixgbe_tx_is_paused - check if the tx ring is paused
+ * @adapter: the ixgbe adapter
+ * @tx_ring: the corresponding tx_ring
+ *
+ * If not in DCB mode, checks TFCS.TXOFF, otherwise, find out the
+ * corresponding TC of this tx_ring when checking TFCS.
+ *
+ * Returns : true if paused
+ */
+static inline bool ixgbe_tx_is_paused(struct ixgbe_adapter *adapter,
+                                      struct ixgbe_ring *tx_ring)
+{
+	int tc;
+	u32 txoff = IXGBE_TFCS_TXOFF;
+
+#ifdef CONFIG_IXGBE_DCB
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		int reg_idx = tx_ring->reg_idx;
+		int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+			tc = reg_idx >> 2;
+			txoff = IXGBE_TFCS_TXOFF0;
+		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+			tc = 0;
+			txoff = IXGBE_TFCS_TXOFF;
+			if (dcb_i == 8) {
+				/* TC0, TC1 */
+				tc = reg_idx >> 5;
+				if (tc == 2) /* TC2, TC3 */
+					tc += (reg_idx - 64) >> 4;
+				else if (tc == 3) /* TC4, TC5, TC6, TC7 */
+					tc += 1 + ((reg_idx - 96) >> 3);
+			} else if (dcb_i == 4) {
+				/* TC0, TC1 */
+				tc = reg_idx >> 6;
+				if (tc == 1) {
+					tc += (reg_idx - 64) >> 5;
+					if (tc == 2) /* TC2, TC3 */
+						tc += (reg_idx - 96) >> 4;
+				}
+			}
+		}
+		txoff <<= tc;
+	}
+#endif
+	return IXGBE_READ_REG(&adapter->hw, IXGBE_TFCS) & txoff;
+}
+
 static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
                                        struct ixgbe_ring *tx_ring,
                                        unsigned int eop)
@@ -237,7 +287,7 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 	adapter->detect_tx_hung = false;
 	if (tx_ring->tx_buffer_info[eop].time_stamp &&
 	    time_after(jiffies, tx_ring->tx_buffer_info[eop].time_stamp + HZ) &&
-	    !(IXGBE_READ_REG(&adapter->hw, IXGBE_TFCS) & IXGBE_TFCS_TXOFF)) {
+	    !ixgbe_tx_is_paused(adapter, tx_ring)) {
 		/* detected Tx unit hang */
 		union ixgbe_adv_tx_desc *tx_desc;
 		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);

