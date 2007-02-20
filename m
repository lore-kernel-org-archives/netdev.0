From: "Chris Snook" <csnook@redhat.com>
Subject: [PATCH 1/3] remove =?UTF-8?Q?irq=5Fsem=20from=20atl=31?=
Date: Mon, 19 Feb 2007 20:03:32 -0500
Message-ID: <20070220.4mi.25231800@egw.corp.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:42161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965861AbXBTBD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 20:03:57 -0500
In-Reply-To: <20070220.Bq5.44322700@egw.corp.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Remove unnecessary irq_sem code from atl1 driver.  Tested with no problems.

Signed-off-by: Chris Snook <csnook@redhat.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
--
diff -urp linux-2.6.20-git14.orig/drivers/net/atl1/atl1.h
linux-2.6.20-git14/drivers/net/atl1/atl1.h
--- linux-2.6.20-git14.orig/drivers/net/atl1/atl1.h	2007-02-19
14:32:15.000000000 -0500
+++ linux-2.6.20-git14/drivers/net/atl1/atl1.h	2007-02-19 15:10:07.000000000
-0500
@@ -236,7 +236,6 @@ struct atl1_adapter {
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t lock;
-	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
 	struct work_struct link_chg_task;
 	struct work_struct pcie_dma_to_rst_task;
diff -urp linux-2.6.20-git14.orig/drivers/net/atl1/atl1_main.c
linux-2.6.20-git14/drivers/net/atl1/atl1_main.c
--- linux-2.6.20-git14.orig/drivers/net/atl1/atl1_main.c	2007-02-19
14:32:15.000000000 -0500
+++ linux-2.6.20-git14/drivers/net/atl1/atl1_main.c	2007-02-19
15:10:44.000000000 -0500
@@ -163,7 +163,6 @@ static int __devinit atl1_sw_init(struct
 	hw->cmb_tx_timer = 1;	/* about 2us */
 	hw->smb_timer = 100000;	/* about 200ms */

-	atomic_set(&adapter->irq_sem, 0);
 	spin_lock_init(&adapter->lock);
 	spin_lock_init(&adapter->mb_lock);

@@ -272,8 +271,7 @@ err_nomem:
  */
 static void atl1_irq_enable(struct atl1_adapter *adapter)
 {
-	if (likely(!atomic_dec_and_test(&adapter->irq_sem)))
-		iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
+	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
 }

 static void atl1_clear_phy_int(struct atl1_adapter *adapter)
@@ -1205,7 +1203,6 @@ static u32 atl1_configure(struct atl1_ad
  */
 static void atl1_irq_disable(struct atl1_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 	ioread32(adapter->hw.hw_addr + REG_IMR);
 	synchronize_irq(adapter->pdev->irq);

