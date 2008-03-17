From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 8/8] ixgb: remove irq_sem
Date: Mon, 17 Mar 2008 09:30:16 -0700
Message-ID: <20080317163016.4861.22127.stgit@localhost.localdomain>
References: <20080317162939.4861.91040.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63764 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594AbYCQQay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 12:30:54 -0400
In-Reply-To: <20080317162939.4861.91040.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

ixgb can remove irq_sem by auditing all the call sites to make sure
that each of them makes sure the adapter is in the correct state
before re-enabling interrupts.  after doing this to all of our other
drivers it is becoming easier.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h      |    1 -
 drivers/net/ixgb/ixgb_main.c |   18 ++++++------------
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index a95ab55..f2fff90 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -158,7 +158,6 @@ struct ixgb_adapter {
 	uint16_t link_speed;
 	uint16_t link_duplex;
 	spinlock_t tx_lock;
-	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
 
 	struct timer_list blink_timer;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index d9688bb..9c9bf31 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -197,7 +197,6 @@ module_exit(ixgb_exit_module);
 static void
 ixgb_irq_disable(struct ixgb_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 	IXGB_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
@@ -211,14 +210,12 @@ ixgb_irq_disable(struct ixgb_adapter *adapter)
 static void
 ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
-	if(atomic_dec_and_test(&adapter->irq_sem)) {
-		u32 val = IXGB_INT_RXT0 | IXGB_INT_RXDMT0 |
-			  IXGB_INT_TXDW | IXGB_INT_LSC;
-		if (adapter->hw.subsystem_vendor_id == SUN_SUBVENDOR_ID)
-			val |= IXGB_INT_GPI0;
-		IXGB_WRITE_REG(&adapter->hw, IMS, val);
-		IXGB_WRITE_FLUSH(&adapter->hw);
-	}
+	u32 val = IXGB_INT_RXT0 | IXGB_INT_RXDMT0 |
+		  IXGB_INT_TXDW | IXGB_INT_LSC;
+	if (adapter->hw.subsystem_vendor_id == SUN_SUBVENDOR_ID)
+		val |= IXGB_INT_GPI0;
+	IXGB_WRITE_REG(&adapter->hw, IMS, val);
+	IXGB_WRITE_FLUSH(&adapter->hw);
 }
 
 int
@@ -305,7 +302,6 @@ ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog)
 
 #ifdef CONFIG_IXGB_NAPI
 	napi_disable(&adapter->napi);
-	atomic_set(&adapter->irq_sem, 0);
 #endif
 	/* waiting for NAPI to complete can re-enable interrupts */
 	ixgb_irq_disable(adapter);
@@ -594,7 +590,6 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	/* enable flow control to be programmed */
 	hw->fc.send_xon = 1;
 
-	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->tx_lock);
 
 	set_bit(__IXGB_DOWN, &adapter->flags);
@@ -1774,7 +1769,6 @@ ixgb_intr(int irq, void *data)
 		  of the posted write is intentionally left out.
 		*/
 
-		atomic_inc(&adapter->irq_sem);
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 		__netif_rx_schedule(netdev, &adapter->napi);
 	}

