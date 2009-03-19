From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] ixgbe: Fixup the watchdog interrupt scheduling
	on 82599
Date: Thu, 19 Mar 2009 04:24:04 -0700
Message-ID: <20090319112404.11957.31387.stgit@lost.foo-projects.org>
References: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:50197
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753766AbZCSLYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:24:25 -0400
In-Reply-To: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The watchdog will schedule an interrupt to help make sure queues are
cleaned in the case when an interrupt is missed, most likely due to very
high load.  On 82599, there are extra interrupt registers to account for
the larger number of MSI-X vectors (64 total for 82599 vs. 18 total for
82598).  These must be taken into account when performing this operation in
the watchdog.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  113 +++++++++++++++++++++++++++++-----------
 1 files changed, 81 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 335119a..0956be7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1434,27 +1434,6 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_irq_disable - Mask off interrupt generation on the NIC
- * @adapter: board private structure
- **/
-static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
-{
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), ~0);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(2), ~0);
-	}
-	IXGBE_WRITE_FLUSH(&adapter->hw);
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		int i;
-		for (i = 0; i < adapter->num_msix_vectors; i++)
-			synchronize_irq(adapter->msix_entries[i].vector);
-	} else {
-		synchronize_irq(adapter->pdev->irq);
-	}
-}
-
-/**
  * ixgbe_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
  **/
@@ -1597,6 +1576,39 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_irq_disable - Mask off interrupt generation on the NIC
+ * @adapter: board private structure
+ **/
+static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
+{
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), ~0);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(2), ~0);
+	}
+	IXGBE_WRITE_FLUSH(&adapter->hw);
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		int i;
+		for (i = 0; i < adapter->num_msix_vectors; i++)
+			synchronize_irq(adapter->msix_entries[i].vector);
+	} else {
+		synchronize_irq(adapter->pdev->irq);
+	}
+}
+
+static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter)
+{
+	u32 mask = IXGBE_EIMS_RTX_QUEUE;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(1), mask << 16);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(2),
+		                (mask << 16 | mask));
+	}
+	/* skip the flush */
+}
+
+/**
  * ixgbe_configure_msi_and_legacy - Initialize PIN (INTA...) and MSI interrupts
  *
  **/
@@ -2624,7 +2636,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 		if (adapter->itr_setting & 1)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			ixgbe_irq_enable(adapter);
+			ixgbe_irq_enable_queues(adapter);
 	}
 	return work_done;
 }
@@ -3806,17 +3818,54 @@ static void ixgbe_watchdog(unsigned long data)
 	/* Do the watchdog outside of interrupt context due to the lovely
 	 * delays that some of the newer hardware requires */
 	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+		u64 eics = 0;
+		int i;
+
+		for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++)
+			eics |= (1 << i);
+
 		/* Cause software interrupt to ensure rx rings are cleaned */
-		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-			u32 eics =
-			 (1 << (adapter->num_msix_vectors - NON_Q_VECTORS)) - 1;
-			IXGBE_WRITE_REG(hw, IXGBE_EICS, eics);
-		} else {
-			/* For legacy and MSI interrupts don't set any bits that
-			 * are enabled for EIAM, because this operation would
-			 * set *both* EIMS and EICS for any bit in EIAM */
-			IXGBE_WRITE_REG(hw, IXGBE_EICS,
-                                    (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
+		switch (hw->mac.type) {
+		case ixgbe_mac_82598EB:
+			if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+				IXGBE_WRITE_REG(hw, IXGBE_EICS, (u32)eics);
+			} else {
+				/*
+				 * for legacy and MSI interrupts don't set any
+				 * bits that are enabled for EIAM, because this
+				 * operation would set *both* EIMS and EICS for
+				 * any bit in EIAM
+				 */
+				IXGBE_WRITE_REG(hw, IXGBE_EICS,
+				     (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
+			}
+			break;
+		case ixgbe_mac_82599EB:
+			if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+				/*
+				 * EICS(0..15) first 0-15 q vectors
+				 * EICS[1] (16..31) q vectors 16-31
+				 * EICS[2] (0..31) q vectors 32-63
+				 */
+				IXGBE_WRITE_REG(hw, IXGBE_EICS,
+				                (u32)(eics & 0xFFFF));
+				IXGBE_WRITE_REG(hw, IXGBE_EICS_EX(1),
+				                (u32)(eics & 0xFFFF0000));
+				IXGBE_WRITE_REG(hw, IXGBE_EICS_EX(2),
+				                (u32)(eics >> 32));
+			} else {
+				/*
+				 * for legacy and MSI interrupts don't set any
+				 * bits that are enabled for EIAM, because this
+				 * operation would set *both* EIMS and EICS for
+				 * any bit in EIAM
+				 */
+				IXGBE_WRITE_REG(hw, IXGBE_EICS,
+				     (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
+			}
+			break;
+		default:
+			break;
 		}
 		/* Reset the timer */
 		mod_timer(&adapter->watchdog_timer,

