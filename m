From: Arjan van de Ven <arjan@infradead.org>
Subject: PATCH] net: b44.c fix sleeping-with-spinlock-helt during resume
Date: Sat, 31 May 2008 20:11:30 -0700
Message-ID: <20080531201130.0244dc29@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:54742 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbYFADM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 23:12:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [PATCH] net: b44.c fix sleeping-with-spinlock-helt during resume
CC: Michael Buesch <mb@bu3sch.de>

The b44.c driver calls b44_chip_reset() from the resume path,
with the device spinlock held.
Unfortunately, b44_chip_reset() calls ssb_pcicore_dev_irqvecs_enable()
which is a sleeping function (and calls might_sleep), if and only if
the device hasn't been enabled yet.

Not having this hardware, the safest solution seems to be to enable
the irqvec before taking the spinlock...

http://www.kerneloops.org/search.php?search=ssb_pcicore_dev_irqvecs_enable

Reported-by: www.kerneloops.org
Signed-off-by: Arjan van de Ven
---
 drivers/net/b44.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 59dce6a..6028129 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1278,6 +1278,7 @@ static void b44_chip_reset(struct b44 *bp, int reset_kind)
 		bw32(bp, B44_DMARX_CTRL, 0);
 		bp->rx_prod = bp->rx_cons = 0;
 	} else
+		/* this function sleeps! */
 		ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
 
 	ssb_device_enable(bp->sdev, 0);
@@ -1374,7 +1375,7 @@ static int b44_set_mac_addr(struct net_device *dev, void *p)
 }
 
 /* Called at device open time to get the chip ready for
- * packet processing.  Invoked with bp->lock held.
+ * packet processing.  Sometimes invoked with bp->lock held.
  */
 static void __b44_set_rx_mode(struct net_device *);
 static void b44_init_hw(struct b44 *bp, int reset_kind)
@@ -2288,6 +2289,13 @@ static int b44_resume(struct ssb_device *sdev)
 		return rc;
 	}
 
+	/*
+	 * If the device isn't enabled yet, we need to do so before taking
+	 * the spinlock, since the enablinging function sleeps.
+	 */
+	if (!ssb_device_is_enabled(bp->sdev))
+		ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
+
 	spin_lock_irq(&bp->lock);
 
 	b44_init_rings(bp);
-- 
1.5.5.1



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
