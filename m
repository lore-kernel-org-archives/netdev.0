From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [Fwd: [PATCH 1/2] CS89X0: Add cleanup for dma after fail]
Date: Fri, 30 May 2008 11:18:55 +0800
Message-ID: <483F721F.1090204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64015 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752451AbYE3DVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 23:21:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff, will you pick up this one?
I also cc Andrew, because his name is in the code.

From: Wang Chen <wangchen@cn.fujitsu.com>

After request_dma() succeeding, any error path should do free_dma().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/cs89x0.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 348371f..fba87ab 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1394,7 +1394,11 @@ net_open(struct net_device *dev)
 #endif
         if (!result) {
                 printk(KERN_ERR "%s: EEPROM is configured for unavailable media\n", dev->name);
-        release_irq:
+release_dma:
+#if ALLOW_DMA
+		free_dma(dev->dma);
+#endif
+release_irq:
 #if ALLOW_DMA
 		release_dma_buff(lp);
 #endif
@@ -1442,12 +1446,12 @@ net_open(struct net_device *dev)
 			if ((result = detect_bnc(dev)) != DETECTED_NONE)
 				break;
 		printk(KERN_ERR "%s: no media detected\n", dev->name);
-                goto release_irq;
+		goto release_dma;
 	}
 	switch(result) {
 	case DETECTED_NONE:
 		printk(KERN_ERR "%s: no network cable attached to configured media\n", dev->name);
-                goto release_irq;
+		goto release_dma;
 	case DETECTED_RJ45H:
 		printk(KERN_INFO "%s: using half-duplex 10Base-T (RJ-45)\n", dev->name);
 		break;
-- 
1.5.4.rc3

