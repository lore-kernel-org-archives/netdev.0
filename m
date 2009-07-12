From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Avoid races in sky2_down
Date: Sun, 12 Jul 2009 14:28:04 +0900
Message-ID: <392fb48f0907112228v52624339x4f6c418ed0ee07a5@mail.gmail.com>
References: <392fb48f0906200102k57f7964ah9f74c2cf40ea64b0@mail.gmail.com>
	 <20090707181807.5b69a926@nehalam>
	 <392fb48f0907072016i14cd650fv3524b345c79e498d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:65231 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbZGLF2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 01:28:06 -0400
Received: by yxe14 with SMTP id 14so2139169yxe.33
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2009 22:28:04 -0700 (PDT)
In-Reply-To: <392fb48f0907072016i14cd650fv3524b345c79e498d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Resending with sign off. (You may have this in your tree already, but
just in case...)
I ran some overnight tests with this patch in, and my machine manages
to stay up all night, where it crashed within minutes before.

Mike

---

Reset rx chain before trying to drain it.
Shut interrupts off last, incase there's something to report.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index daf961a..23a26d6 100644
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
