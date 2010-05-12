From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 4/5] sky2: Refactor down/up code out of sky2_restart()
Date: Thu, 13 May 2010 08:29:46 +0900
Message-ID: <4BEB39EA.2060809@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:40587 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab0ELXir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 19:38:47 -0400
Received: by pwi5 with SMTP id 5so332350pwi.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 16:38:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code to bring down all sky2 interfaces and bring it up
again can be reused in sky2_suspend and sky2_resume.

Factor the code to bring the interfaces down into
sky2_all_down and the up code into sky2_all_up.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 04adcee..a8060c8 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3258,15 +3258,11 @@ static int sky2_reattach(struct net_device *dev)
 	return err;
 }
 
-static void sky2_restart(struct work_struct *work)
+static void sky2_all_down(struct sky2_hw *hw)
 {
-	struct sky2_hw *hw = container_of(work, struct sky2_hw, restart_work);
-	u32 imask;
 	int i;
 
-	rtnl_lock();
-
-	imask = sky2_read32(hw, B0_IMSK);
+	sky2_read32(hw, B0_IMSK);
 	sky2_write32(hw, B0_IMSK, 0);
 	synchronize_irq(hw->pdev->irq);
 	napi_disable(&hw->napi);
@@ -3282,8 +3278,12 @@ static void sky2_restart(struct work_struct *work)
 		netif_tx_disable(dev);
 		sky2_hw_down(sky2);
 	}
+}
 
-	sky2_reset(hw);
+static void sky2_all_up(struct sky2_hw *hw)
+{
+	u32 imask = Y2_IS_BASE;
+	int i;
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
@@ -3294,6 +3294,7 @@ static void sky2_restart(struct work_struct *work)
 
 		sky2_hw_up(sky2);
 		sky2_set_multicast(dev);
+		imask |= portirq_msk[i];
 		netif_wake_queue(dev);
 	}
 
@@ -3302,6 +3303,17 @@ static void sky2_restart(struct work_struct *work)
 
 	sky2_read32(hw, B0_Y2_SP_LISR);
 	napi_enable(&hw->napi);
+}
+
+static void sky2_restart(struct work_struct *work)
+{
+	struct sky2_hw *hw = container_of(work, struct sky2_hw, restart_work);
+
+	rtnl_lock();
+
+	sky2_all_down(hw);
+	sky2_reset(hw);
+	sky2_all_up(hw);
 
 	rtnl_unlock();
 }
-- 
1.5.6.5


