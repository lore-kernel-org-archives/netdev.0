From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] e1000e: Do not read ICR in Other interrupt
Date: Mon, 14 Dec 2015 21:38:42 -0800
Message-ID: <1450157924-58901-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59686 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbbLOFiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 00:38:50 -0500
In-Reply-To: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

Removes the ICR read in the other interrupt handler, uses EIAC to
autoclear the Other bit from ICR and IMS. This allows us to avoid
interference with Rx and Tx interrupts in the Other interrupt handler.

The information read from ICR is not needed. IMS is configured such that
the only interrupt cause that can trigger the Other interrupt is Link
Status Change.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 26cf183..56bc422 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1905,24 +1905,15 @@ static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 icr = er32(ICR);
 
-	if (icr & adapter->eiac_mask)
-		ew32(ICS, (icr & adapter->eiac_mask));
+	hw->mac.get_link_status = true;
 
-	if (icr & E1000_ICR_OTHER) {
-		if (!(icr & E1000_ICR_LSC))
-			goto no_link_interrupt;
-		hw->mac.get_link_status = true;
-		/* guard against interrupt when we're going down */
-		if (!test_bit(__E1000_DOWN, &adapter->state))
-			mod_timer(&adapter->watchdog_timer, jiffies + 1);
+	/* guard against interrupt when we're going down */
+	if (!test_bit(__E1000_DOWN, &adapter->state)) {
+		mod_timer(&adapter->watchdog_timer, jiffies + 1);
+		ew32(IMS, E1000_IMS_OTHER);
 	}
 
-no_link_interrupt:
-	if (!test_bit(__E1000_DOWN, &adapter->state))
-		ew32(IMS, E1000_IMS_LSC | E1000_IMS_OTHER);
-
 	return IRQ_HANDLED;
 }
 
@@ -2021,6 +2012,7 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
 		       hw->hw_addr + E1000_EITR_82574(vector));
 	else
 		writel(1, hw->hw_addr + E1000_EITR_82574(vector));
+	adapter->eiac_mask |= E1000_IMS_OTHER;
 
 	/* Cause Tx interrupts on every write back */
 	ivar |= (1 << 31);
@@ -2249,7 +2241,7 @@ static void e1000_irq_enable(struct e1000_adapter *adapter)
 
 	if (adapter->msix_entries) {
 		ew32(EIAC_82574, adapter->eiac_mask & E1000_EIAC_MASK_82574);
-		ew32(IMS, adapter->eiac_mask | E1000_IMS_OTHER | E1000_IMS_LSC);
+		ew32(IMS, adapter->eiac_mask | E1000_IMS_LSC);
 	} else if ((hw->mac.type == e1000_pch_lpt) ||
 		   (hw->mac.type == e1000_pch_spt)) {
 		ew32(IMS, IMS_ENABLE_MASK | E1000_IMS_ECCER);
-- 
2.5.0
