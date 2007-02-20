From: "Chris Snook" <csnook@redhat.com>
Subject: [PATCH 2/3] remove =?UTF-8?Q?irq=5Fsem=20from=20e=31=30=30=30?=
Date: Mon, 19 Feb 2007 20:10:18 -0500
Message-ID: <20070220.pBx.84771300@egw.corp.redhat.com>
References: <20070220.Bq5.44322700@egw.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, jacliburn@bellsouth.net, csnook@redhat.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43638 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965888AbXBTBKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 20:10:34 -0500
In-Reply-To: <20070220.Bq5.44322700@egw.corp.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Remove unnecessary irq_sem accounting from e1000.  Tested with no problems.

Signed-off-by: Chris Snook <csnook@redhat.com>
--
diff -urp linux-2.6.20-git14.orig/drivers/net/e1000/e1000.h
linux-2.6.20-git14/drivers/net/e1000/e1000.h
--- linux-2.6.20-git14.orig/drivers/net/e1000/e1000.h	2007-02-19
14:32:15.000000000 -0500
+++ linux-2.6.20-git14/drivers/net/e1000/e1000.h	2007-02-19 15:07:37.000000000
-0500
@@ -252,7 +252,6 @@ struct e1000_adapter {
 #ifdef CONFIG_E1000_NAPI
 	spinlock_t tx_queue_lock;
 #endif
-	atomic_t irq_sem;
 	unsigned int total_tx_bytes;
 	unsigned int total_tx_packets;
 	unsigned int total_rx_bytes;
diff -urp linux-2.6.20-git14.orig/drivers/net/e1000/e1000_main.c
linux-2.6.20-git14/drivers/net/e1000/e1000_main.c
--- linux-2.6.20-git14.orig/drivers/net/e1000/e1000_main.c	2007-02-19
14:32:15.000000000 -0500
+++ linux-2.6.20-git14/drivers/net/e1000/e1000_main.c	2007-02-19
15:09:28.000000000 -0500
@@ -349,7 +349,6 @@ static void e1000_free_irq(struct e1000_
 static void
 e1000_irq_disable(struct e1000_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
 	E1000_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
@@ -363,10 +362,8 @@ e1000_irq_disable(struct e1000_adapter *
 static void
 e1000_irq_enable(struct e1000_adapter *adapter)
 {
-	if (likely(atomic_dec_and_test(&adapter->irq_sem))) {
-		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
-		E1000_WRITE_FLUSH(&adapter->hw);
-	}
+	E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
+	E1000_WRITE_FLUSH(&adapter->hw);
 }

 static void
@@ -1336,7 +1333,6 @@ e1000_sw_init(struct e1000_adapter *adap
 	spin_lock_init(&adapter->tx_queue_lock);
 #endif

-	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);

 	set_bit(__E1000_DOWN, &adapter->flags);
@@ -3758,11 +3754,6 @@ e1000_intr_msi(int irq, void *data)
 #endif
 	uint32_t icr = E1000_READ_REG(hw, ICR);

-#ifdef CONFIG_E1000_NAPI
-	/* read ICR disables interrupts using IAM, so keep up with our
-	 * enable/disable accounting */
-	atomic_inc(&adapter->irq_sem);
-#endif
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->get_link_status = 1;
 		/* 80003ES2LAN workaround-- For packet buffer work-around on
@@ -3832,13 +3823,6 @@ e1000_intr(int irq, void *data)
 	if (unlikely(hw->mac_type >= e1000_82571 &&
 	             !(icr & E1000_ICR_INT_ASSERTED)))
 		return IRQ_NONE;
-
-	/* Interrupt Auto-Mask...upon reading ICR,
-	 * interrupts are masked.  No need for the
-	 * IMC write, but it does mean we should
-	 * account for it ASAP. */
-	if (likely(hw->mac_type >= e1000_82571))
-		atomic_inc(&adapter->irq_sem);
 #endif

 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
@@ -3862,7 +3846,6 @@ e1000_intr(int irq, void *data)
 #ifdef CONFIG_E1000_NAPI
 	if (unlikely(hw->mac_type < e1000_82571)) {
 		/* disable interrupts, without the synchronize_irq bit */
-		atomic_inc(&adapter->irq_sem);
 		E1000_WRITE_REG(hw, IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
@@ -3888,7 +3871,6 @@ e1000_intr(int irq, void *data)
 	 * de-assertion state.
 	 */
 	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2) {
-		atomic_inc(&adapter->irq_sem);
 		E1000_WRITE_REG(hw, IMC, ~0);
 	}

