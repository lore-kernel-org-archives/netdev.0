From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 19/29] ixgbe: refresh the ixgbe_down function
Date: Thu, 11 Sep 2008 20:00:16 -0700
Message-ID: <20080912030003.6234.84277.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:45474 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755403AbYILDAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:00:19 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392897waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:00:18 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
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
index df093ec..cafb915 100644
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

