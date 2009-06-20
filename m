From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Avoid races in sky2_down
Date: Sat, 20 Jun 2009 17:02:24 +0900
Message-ID: <392fb48f0906200102k57f7964ah9f74c2cf40ea64b0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:38936 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbZFTICW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 04:02:22 -0400
Received: by bwz9 with SMTP id 9so2154118bwz.37
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2009 01:02:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset rx chain before trying to drain it.
Shut interrupts off last, in case there's something to report.
---
 drivers/net/sky2.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index ca1e9e5..3f67a60 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1825,12 +1825,6 @@ static int sky2_down(struct net_device *dev)
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

@@ -1870,8 +1864,6 @@ static int sky2_down(struct net_device *dev)

 	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL), RB_RST_SET);

-	sky2_rx_stop(sky2);
-
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);

@@ -1881,6 +1873,14 @@ static int sky2_down(struct net_device *dev)
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
