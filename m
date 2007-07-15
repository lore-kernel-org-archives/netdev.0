From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 1/5] atl1: remove irq_sem
Date: Sun, 15 Jul 2007 11:03:25 -0500
Message-ID: <1184515409355-git-send-email-jacliburn@bellsouth.net>
References: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Cc: jacliburn@bellsouth.net, csnook@redhat.com,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:34716 "EHLO
	imf18aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759175AbXGOQDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 12:03:31 -0400
In-Reply-To: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary irq_sem code.

Signed-off-by: Chris Snook <csnook@redhat.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1.h      |    1 -
 drivers/net/atl1/atl1_main.c |    6 ++----
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index b1c6034..a769e7b 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -236,7 +236,6 @@ struct atl1_adapter {
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t lock;
-	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
 	struct work_struct link_chg_task;
 	struct work_struct pcie_dma_to_rst_task;
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 3bb40dd..ef12dba 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -162,7 +162,6 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	hw->cmb_tx_timer = 1;	/* about 2us */
 	hw->smb_timer = 100000;	/* about 200ms */
 
-	atomic_set(&adapter->irq_sem, 0);
 	spin_lock_init(&adapter->lock);
 	spin_lock_init(&adapter->mb_lock);
 
@@ -268,8 +267,8 @@ err_nomem:
  */
 static void atl1_irq_enable(struct atl1_adapter *adapter)
 {
-	if (likely(!atomic_dec_and_test(&adapter->irq_sem)))
-		iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
+	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
+	ioread32(adapter->hw.hw_addr + REG_IMR);
 }
 
 static void atl1_clear_phy_int(struct atl1_adapter *adapter)
@@ -1195,7 +1194,6 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
  */
 static void atl1_irq_disable(struct atl1_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 	ioread32(adapter->hw.hw_addr + REG_IMR);
 	synchronize_irq(adapter->pdev->irq);
-- 
1.5.2.2

