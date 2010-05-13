From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] sky2: Refactor down/up code out of sky2_restart()
Date: Thu, 13 May 2010 09:12:51 -0700
Message-ID: <20100513161351.257776304@vyatta.com>
References: <20100513161247.833356588@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39378 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757297Ab0EMXaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 19:30:25 -0400
Content-Disposition: inline; filename=sky2-mike4.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Code to bring down all sky2 interfaces and bring it up
again can be reused in sky2_suspend and sky2_resume.

Factor the code to bring the interfaces down into
sky2_all_down and the up code into sky2_all_up.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
Not a regression.

 drivers/net/sky2.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

--- a/drivers/net/sky2.c	2010-05-13 08:57:32.736962641 -0700
+++ b/drivers/net/sky2.c	2010-05-13 08:57:33.337275609 -0700
@@ -3312,15 +3312,11 @@ static int sky2_reattach(struct net_devi
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
@@ -3336,8 +3332,12 @@ static void sky2_restart(struct work_str
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
@@ -3348,6 +3348,7 @@ static void sky2_restart(struct work_str
 
 		sky2_hw_up(sky2);
 		sky2_set_multicast(dev);
+		imask |= portirq_msk[i];
 		netif_wake_queue(dev);
 	}
 
@@ -3356,6 +3357,17 @@ static void sky2_restart(struct work_str
 
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


