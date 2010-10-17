From: James Hogan <james@albanarts.com>
Subject: [PATCH v2] b44: fix resume, request_irq after hw reset
Date: Sun, 17 Oct 2010 12:48:59 +0100
Message-ID: <201010171249.00485.james@albanarts.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45120 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896Ab0JQLtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Oct 2010 07:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On resume, call request_irq() after resetting the hardware rather than
before. It's a shared interrupt so the handler could be called
immediately if another device on the same irq interrupts (and will be
called immediately if CONFIG_DEBUG_SHIRQ=y), but unless the hardware is
reinitialised with b44_init_hw() the read of the interrupt status
register will hang the system.

Signed-off-by: James Hogan <james@albanarts.com>
---
 drivers/net/b44.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index efeffdf..f950505 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2296,18 +2296,27 @@ static int b44_resume(struct ssb_device *sdev)
 	if (!netif_running(dev))
 		return 0;
 
+	spin_lock_irq(&bp->lock);
+	b44_init_rings(bp);
+	b44_init_hw(bp, B44_FULL_RESET);
+	spin_unlock_irq(&bp->lock);
+
+	/*
+	 * As a shared interrupt, the handler can be called immediately. To be
+	 * able to check the interrupt status the hardware must already be
+	 * powered back on (b44_init_hw).
+	 */
 	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc) {
 		netdev_err(dev, "request_irq failed\n");
+		spin_lock_irq(&bp->lock);
+		b44_halt(bp);
+		b44_free_rings(bp);
+		spin_unlock_irq(&bp->lock);
 		return rc;
 	}
 
-	spin_lock_irq(&bp->lock);
-
-	b44_init_rings(bp);
-	b44_init_hw(bp, B44_FULL_RESET);
 	netif_device_attach(bp->dev);
-	spin_unlock_irq(&bp->lock);
 
 	b44_enable_ints(bp);
 	netif_wake_queue(dev);
-- 
1.7.2.3

