From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 19/24] ixgbe: refresh the ixgbe_down function
Date: Mon, 08 Sep 2008 21:48:23 -0700
Message-ID: <20080909044823.18904.68068.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:34578 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141AbYIIEs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:26 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1027474yxm.1
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:25 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

clean up the hardware shutdown sequence to prevent hardware
from continuing to send when resetting or unloading.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   29 +++++++++++++++++++----------
 1 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 700abbb..a9ef7b8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1096,7 +1096,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* If all Rx work done, exit the polling mode */
-	if ((work_done == 0) || !netif_running(netdev)) {
+	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
@@ -2174,32 +2174,41 @@ static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
 void ixgbe_down(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
+	u32 txdctl;
+	int i, j;
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	/* disable receives */
-	rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXCTRL);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXCTRL,
-			rxctrl & ~IXGBE_RXCTRL_RXEN);
+	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
 
 	netif_tx_disable(netdev);
 
-	/* disable transmits in the hardware */
-
-	/* flush both disables */
-	IXGBE_WRITE_FLUSH(&adapter->hw);
+	IXGBE_WRITE_FLUSH(hw);
 	msleep(10);
 
+	netif_tx_stop_all_queues(netdev);
+
 	ixgbe_irq_disable(adapter);
 
 	ixgbe_napi_disable_all(adapter);
+
 	del_timer_sync(&adapter->watchdog_timer);
 	cancel_work_sync(&adapter->watchdog_task);
 
+	/* disable transmits in the hardware now that interrupts are off */
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		j = adapter->tx_ring[i].reg_idx;
+		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j),
+		                (txdctl & ~IXGBE_TXDCTL_ENABLE));
+	}
+
 	netif_carrier_off(netdev);
-	netif_tx_stop_all_queues(netdev);
 
 #if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
@@ -2219,7 +2228,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
 		 * in the CB driver */
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
+			IXGBE_WRITE_REG(hw, IXGBE_DCA_CTRL, 2);
 		ixgbe_setup_dca(adapter);
 	}
 #endif

