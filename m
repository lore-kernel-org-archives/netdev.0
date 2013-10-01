From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  3/9] ixgbevf: add wait for Rx queue disable
Date: Tue,  1 Oct 2013 04:33:50 -0700
Message-ID: <1380627236-3190-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46701 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622Ab3JALeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:34:00 -0400
In-Reply-To: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

New function was added to wait for Rx queues to be disabled before
disabling NAPI. This function also allows us to  modify
ixgbevf_rx_desc_queue_enable() to better match ixgbe.  I also cleaned up
some msleep calls to usleep_range while I was in this code anyway.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 61 ++++++++++++++++-------
 1 file changed, 44 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b9a78a2..e3493b0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1302,27 +1302,51 @@ static void ixgbevf_configure(struct ixgbevf_adapter *adapter)
 	}
 }
 
-#define IXGBE_MAX_RX_DESC_POLL 10
-static inline void ixgbevf_rx_desc_queue_enable(struct ixgbevf_adapter *adapter,
-						int rxr)
+#define IXGBEVF_MAX_RX_DESC_POLL 10
+static void ixgbevf_rx_desc_queue_enable(struct ixgbevf_adapter *adapter,
+					 int rxr)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	int wait_loop = IXGBEVF_MAX_RX_DESC_POLL;
+	u32 rxdctl;
 	int j = adapter->rx_ring[rxr].reg_idx;
-	int k;
 
-	for (k = 0; k < IXGBE_MAX_RX_DESC_POLL; k++) {
-		if (IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(j)) & IXGBE_RXDCTL_ENABLE)
-			break;
-		else
-			msleep(1);
-	}
-	if (k >= IXGBE_MAX_RX_DESC_POLL) {
-		hw_dbg(hw, "RXDCTL.ENABLE on Rx queue %d "
-		       "not set within the polling period\n", rxr);
-	}
+	do {
+		usleep_range(1000, 2000);
+		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(j));
+	} while (--wait_loop && !(rxdctl & IXGBE_RXDCTL_ENABLE));
+
+	if (!wait_loop)
+		hw_dbg(hw, "RXDCTL.ENABLE queue %d not set while polling\n",
+		       rxr);
+
+	ixgbevf_release_rx_desc(&adapter->hw, &adapter->rx_ring[rxr],
+				(adapter->rx_ring[rxr].count - 1));
+}
 
-	ixgbevf_release_rx_desc(hw, &adapter->rx_ring[rxr],
-				adapter->rx_ring[rxr].count - 1);
+static void ixgbevf_disable_rx_queue(struct ixgbevf_adapter *adapter,
+				     struct ixgbevf_ring *ring)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int wait_loop = IXGBEVF_MAX_RX_DESC_POLL;
+	u32 rxdctl;
+	u8 reg_idx = ring->reg_idx;
+
+	rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(reg_idx));
+	rxdctl &= ~IXGBE_RXDCTL_ENABLE;
+
+	/* write value back with RXDCTL.ENABLE bit cleared */
+	IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(reg_idx), rxdctl);
+
+	/* the hardware may take up to 100us to really disable the rx queue */
+	do {
+		udelay(10);
+		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(reg_idx));
+	} while (--wait_loop && (rxdctl & IXGBE_RXDCTL_ENABLE));
+
+	if (!wait_loop)
+		hw_dbg(hw, "RXDCTL.ENABLE queue %d not cleared while polling\n",
+		       reg_idx);
 }
 
 static void ixgbevf_save_reset_stats(struct ixgbevf_adapter *adapter)
@@ -1654,7 +1678,10 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBEVF_DOWN, &adapter->state);
-	/* disable receives */
+
+	/* disable all enabled rx queues */
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		ixgbevf_disable_rx_queue(adapter, &adapter->rx_ring[i]);
 
 	netif_tx_disable(netdev);
 
-- 
1.8.3.1
