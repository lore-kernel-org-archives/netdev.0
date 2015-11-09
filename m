From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH v3 2/4] e1000e: Do not read icr in Other interrupt
Date: Mon,  9 Nov 2015 15:50:19 -0800
Message-ID: <1447113021-1611-3-git-send-email-bpoirier@suse.com>
References: <1447113021-1611-1-git-send-email-bpoirier@suse.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Frank Steiner <steiner-reg@bio.ifi.lmu.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447113021-1611-1-git-send-email-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

removes the icr read in the other interrupt handler, uses eiac to
autoclear the Other bit from icr and ims. This allows us to avoid
interference with rx and tx interrupts in the Other interrupt handler.

The information read from icr is not needed. IMS is configured such that
the only interrupt cause that can trigger the Other interrupt is Link
Status Change.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

---
I noticed a 8-16% improvement in netperf rr tests after applying this
patch. This is a little surprising since this patch touches the handling
of Other interrupts, which do not occur during such a test. Some
profiling was not very insightful but the improvement seems related to
writing Other to EIAC.
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a228167..a73e323 100644
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
 
@@ -2019,6 +2010,7 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
 		       hw->hw_addr + E1000_EITR_82574(vector));
 	else
 		writel(1, hw->hw_addr + E1000_EITR_82574(vector));
+	adapter->eiac_mask |= E1000_IMS_OTHER;
 
 	/* Cause Tx interrupts on every write back */
 	ivar |= (1 << 31);
@@ -2247,7 +2239,7 @@ static void e1000_irq_enable(struct e1000_adapter *adapter)
 
 	if (adapter->msix_entries) {
 		ew32(EIAC_82574, adapter->eiac_mask & E1000_EIAC_MASK_82574);
-		ew32(IMS, adapter->eiac_mask | E1000_IMS_OTHER | E1000_IMS_LSC);
+		ew32(IMS, adapter->eiac_mask | E1000_IMS_LSC);
 	} else if ((hw->mac.type == e1000_pch_lpt) ||
 		   (hw->mac.type == e1000_pch_spt)) {
 		ew32(IMS, IMS_ENABLE_MASK | E1000_IMS_ECCER);
-- 
2.6.2
