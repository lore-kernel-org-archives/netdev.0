From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Avoid races in sky2_down
Date: Wed, 22 Jul 2009 09:50:41 +0900
Message-ID: <392fb48f0907211750v101d51cbl531a6ed7199e4855@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f202.google.com ([209.85.210.202]:34212 "EHLO
	mail-yx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbZGVA51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 20:57:27 -0400
Received: by yxe40 with SMTP id 40so944121yxe.33
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 17:57:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset rx chain before trying to drain it.
Shut interrupts off last, incase there's something to report.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index ba768df..3550c5d 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1818,12 +1818,6 @@ static int sky2_down(struct net_device *dev)
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);

-	/* Disable port IRQ */
-	imask = sky2_read32(hw, B0_IMSK);
-	imask &= ~portirq_msk[port];
-	sky2_write32(hw, B0_IMSK, imask);
-	sky2_read32(hw, B0_IMSK);
-
 	/* Force flow control off */
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);

@@ -1863,8 +1857,6 @@ static int sky2_down(struct net_device *dev)

 	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL), RB_RST_SET);

-	sky2_rx_stop(sky2);
-
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);

@@ -1874,6 +1866,14 @@ static int sky2_down(struct net_device *dev)
 	sky2_write32(hw, STAT_ISR_TIMER_CNT, 0);
 	sky2_read8(hw, STAT_ISR_TIMER_CTRL);

+	sky2_rx_stop(sky2);
+
+	/* Disable port IRQ */
+	imask = sky2_read32(hw, B0_IMSK);
+	imask &= ~portirq_msk[port];
+	sky2_write32(hw, B0_IMSK, imask);
+	sky2_read32(hw, B0_IMSK);
+
 	synchronize_irq(hw->pdev->irq);
 	napi_synchronize(&hw->napi);

-- 
1.5.6.5
