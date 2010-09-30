From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: fix link issues and panic with shared
	interrupts for 82598
Date: Thu, 30 Sep 2010 00:35:23 -0700
Message-ID: <20100930073251.12750.67720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:47610
	"EHLO qmta06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752802Ab0I3Hfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 03:35:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Fix possible panic/hang with shared Legacy interrupts by not enabling
interrupts when interface is down.

Also fixes an intermittent link by enabling LSC upon exit from ixgbe_intr()

This patch adds flags to ixgbe_irq_enable() to allow for some flexibility
when enabling interrupts.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   36 ++++++++++++++++++++++++++----------
 1 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c35185c..c35e13c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2233,7 +2233,8 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
  * ixgbe_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
  **/
-static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
+static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
+				    bool flush)
 {
 	u32 mask;
 
@@ -2254,8 +2255,10 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 		mask |= IXGBE_EIMS_FLOW_DIR;
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
-	ixgbe_irq_enable_queues(adapter, ~0);
-	IXGBE_WRITE_FLUSH(&adapter->hw);
+	if (queues)
+		ixgbe_irq_enable_queues(adapter, ~0);
+	if (flush)
+		IXGBE_WRITE_FLUSH(&adapter->hw);
 
 	if (adapter->num_vfs > 32) {
 		u32 eitrsel = (1 << (adapter->num_vfs - 32)) - 1;
@@ -2277,7 +2280,7 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	u32 eicr;
 
 	/*
-	 * Workaround for silicon errata.  Mask the interrupts
+	 * Workaround for silicon errata on 82598.  Mask the interrupts
 	 * before the read of EICR.
 	 */
 	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_IRQ_CLEAR_MASK);
@@ -2286,10 +2289,15 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	 * therefore no explict interrupt disable is necessary */
 	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
 	if (!eicr) {
-		/* shared interrupt alert!
+		/*
+		 * shared interrupt alert!
 		 * make sure interrupts are enabled because the read will
-		 * have disabled interrupts due to EIAM */
-		ixgbe_irq_enable(adapter);
+		 * have disabled interrupts due to EIAM
+		 * finish the workaround of silicon errata on 82598.  Unmask
+		 * the interrupt that we masked before the EICR read.
+		 */
+		if (!test_bit(__IXGBE_DOWN, &adapter->state))
+			ixgbe_irq_enable(adapter, true, true);
 		return IRQ_NONE;	/* Not our interrupt */
 	}
 
@@ -2313,6 +2321,14 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 		__napi_schedule(&(q_vector->napi));
 	}
 
+	/*
+	 * re-enable link(maybe) and non-queue interrupts, no flush.
+	 * ixgbe_poll will re-enable the queue interrupts
+	 */
+
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_enable(adapter, false, false);
+
 	return IRQ_HANDLED;
 }
 
@@ -3048,7 +3064,7 @@ static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_enable(adapter);
+		ixgbe_irq_enable(adapter, true, true);
 
 	/* remove VID from filter table */
 	hw->mac.ops.set_vfta(&adapter->hw, vid, pool_ndx, false);
@@ -3145,7 +3161,7 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	ixgbe_vlan_rx_add_vid(netdev, 0);
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_enable(adapter);
+		ixgbe_irq_enable(adapter, true, true);
 }
 
 static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
@@ -3546,7 +3562,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	/* clear any pending interrupts, may auto mask */
 	IXGBE_READ_REG(hw, IXGBE_EICR);
-	ixgbe_irq_enable(adapter);
+	ixgbe_irq_enable(adapter, true, true);
 
 	/*
 	 * If this adapter has a fan, check to see if we had a failure

