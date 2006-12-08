From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 15/22] e1000: simplify msi specific interrupt handler
Date: Fri, 08 Dec 2006 15:03:18 -0800
Message-ID: <20061208230318.30109.63413.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4391 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761262AbWLHWxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:55 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Simplify the msi interrupt handler to avoid issues with delayed ICR reads.
This avoids adapter specific problems at the cost of some performance.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h      |    1 -
 drivers/net/e1000/e1000_main.c |   60 +++++++++++++---------------------------
 2 files changed, 19 insertions(+), 42 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index f091042..8e7acb0 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -257,7 +257,6 @@ struct e1000_adapter {
 	spinlock_t tx_queue_lock;
 #endif
 	atomic_t irq_sem;
-	unsigned int detect_link;
 	unsigned int total_tx_bytes;
 	unsigned int total_tx_packets;
 	unsigned int total_rx_bytes;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 67fc379..cb6b732 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3778,8 +3778,8 @@ e1000_update_stats(struct e1000_adapter 
  * @data: pointer to a network interface device structure
  **/
 
-static
-irqreturn_t e1000_intr_msi(int irq, void *data)
+static irqreturn_t
+e1000_intr_msi(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -3787,49 +3787,27 @@ irqreturn_t e1000_intr_msi(int irq, void
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
+	uint32_t icr = E1000_READ_REG(hw, ICR);
 
-	/* this code avoids the read of ICR but has to get 1000 interrupts
-	 * at every link change event before it will notice the change */
-	if (++adapter->detect_link >= 1000) {
-		uint32_t icr = E1000_READ_REG(hw, ICR);
 #ifdef CONFIG_E1000_NAPI
-		/* read ICR disables interrupts using IAM, so keep up with our
-		 * enable/disable accounting */
-		atomic_inc(&adapter->irq_sem);
+	/* read ICR disables interrupts using IAM, so keep up with our
+	 * enable/disable accounting */
+	atomic_inc(&adapter->irq_sem);
 #endif
-		adapter->detect_link = 0;
-		if ((icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) &&
-		    (icr & E1000_ICR_INT_ASSERTED)) {
-			hw->get_link_status = 1;
-			/* 80003ES2LAN workaround--
-			* For packet buffer work-around on link down event;
-			* disable receives here in the ISR and
-			* reset adapter in watchdog
-			*/
-			if (netif_carrier_ok(netdev) &&
-			    (adapter->hw.mac_type == e1000_80003es2lan)) {
-				/* disable receives */
-				uint32_t rctl = E1000_READ_REG(hw, RCTL);
-				E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
-			}
-			/* guard against interrupt when we're going down */
-			if (!test_bit(__E1000_DOWN, &adapter->flags))
-				mod_timer(&adapter->watchdog_timer,
-				          jiffies + 1);
+	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
+		hw->get_link_status = 1;
+		/* 80003ES2LAN workaround-- For packet buffer work-around on
+		 * link down event; disable receives here in the ISR and reset
+		 * adapter in watchdog */
+		if (netif_carrier_ok(netdev) &&
+		    (adapter->hw.mac_type == e1000_80003es2lan)) {
+			/* disable receives */
+			uint32_t rctl = E1000_READ_REG(hw, RCTL);
+			E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
 		}
-	} else {
-		E1000_WRITE_REG(hw, ICR, (0xffffffff & ~(E1000_ICR_RXSEQ |
-		                                         E1000_ICR_LSC)));
-		/* bummer we have to flush here, but things break otherwise as
-		 * some event appears to be lost or delayed and throughput
-		 * drops.  In almost all tests this flush is un-necessary */
-		E1000_WRITE_FLUSH(hw);
-#ifdef CONFIG_E1000_NAPI
-		/* Interrupt Auto-Mask (IAM)...upon writing ICR, interrupts are
-		 * masked.  No need for the IMC write, but it does mean we
-		 * should account for it ASAP. */
-		atomic_inc(&adapter->irq_sem);
-#endif
+		/* guard against interrupt when we're going down */
+		if (!test_bit(__E1000_DOWN, &adapter->flags))
+			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
 #ifdef CONFIG_E1000_NAPI



---
Auke Kok <auke-jan.h.kok@intel.com>
