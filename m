From: "Chris Snook" <csnook@redhat.com>
Subject: [PATCH 3/3] remove =?UTF-8?Q?irq=5Fsem=20from=20ixgb?=
Date: Mon, 19 Feb 2007 20:12:52 -0500
Message-ID: <20070220.EUt.93968700@egw.corp.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:44208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965874AbXBTBNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 20:13:08 -0500
In-Reply-To: <20070220.Bq5.44322700@egw.corp.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Remove irq_sem from ixgb.  Currently untested, but similar to tested patches
on atl1 and e1000.

Signed-off-by: Chris Snook <csnook@redhat.com>
--
diff -urp linux-2.6.20-git14.orig/drivers/net/ixgb/ixgb.h
linux-2.6.20-git14/drivers/net/ixgb/ixgb.h
--- linux-2.6.20-git14.orig/drivers/net/ixgb/ixgb.h	2007-02-19
14:32:16.000000000 -0500
+++ linux-2.6.20-git14/drivers/net/ixgb/ixgb.h	2007-02-19 15:04:50.000000000
-0500
@@ -161,7 +161,6 @@ struct ixgb_adapter {
 	uint16_t link_speed;
 	uint16_t link_duplex;
 	spinlock_t tx_lock;
-	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;

 	struct timer_list blink_timer;
diff -urp linux-2.6.20-git14.orig/drivers/net/ixgb/ixgb_main.c
linux-2.6.20-git14/drivers/net/ixgb/ixgb_main.c
--- linux-2.6.20-git14.orig/drivers/net/ixgb/ixgb_main.c	2007-02-19
14:32:16.000000000 -0500
+++ linux-2.6.20-git14/drivers/net/ixgb/ixgb_main.c	2007-02-19
15:06:52.000000000 -0500
@@ -201,7 +201,6 @@ module_exit(ixgb_exit_module);
 static void
 ixgb_irq_disable(struct ixgb_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 	IXGB_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
@@ -215,12 +214,10 @@ ixgb_irq_disable(struct ixgb_adapter *ad
 static void
 ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
-	if(atomic_dec_and_test(&adapter->irq_sem)) {
-		IXGB_WRITE_REG(&adapter->hw, IMS,
-			       IXGB_INT_RXT0 | IXGB_INT_RXDMT0 | IXGB_INT_TXDW |
-			       IXGB_INT_LSC);
-		IXGB_WRITE_FLUSH(&adapter->hw);
-	}
+	IXGB_WRITE_REG(&adapter->hw, IMS,
+		       IXGB_INT_RXT0 | IXGB_INT_RXDMT0 | IXGB_INT_TXDW |
+		       IXGB_INT_LSC);
+	IXGB_WRITE_FLUSH(&adapter->hw);
 }

 int
@@ -584,7 +581,6 @@ ixgb_sw_init(struct ixgb_adapter *adapte
 	/* enable flow control to be programmed */
 	hw->fc.send_xon = 1;

-	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->tx_lock);

 	return 0;
@@ -1755,7 +1751,6 @@ ixgb_intr(int irq, void *data)
 		  of the posted write is intentionally left out.
 		*/

-		atomic_inc(&adapter->irq_sem);
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 		__netif_rx_schedule(netdev);
 	}

