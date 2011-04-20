From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/9] tg3: Only allow phy ioctls while
 netif_running
Date: Wed, 20 Apr 2011 10:57:38 -0700
Message-ID: <1303322263-18991-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4279 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755509Ab1DTRsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tg3 was new, phy accesses through ioctl were allowable at any time.
Then, the driver started shutting down the phy when the device was
closed.  Phy accesses would be allowed when the driver first attached to
the device, but then would be forbidden after the device had been up'd
and down'd.  After that, management firmware made it illegal to access
the phy unless the driver "owned" the device.  Now that most firmware
is being moved over to the APE, it is less clear when phy accesses are
safe.

While it is possible to attempt to identify these conditions and code
the driver to navigate through the pitfalls, it could be perplexing to
the admin why phy accesses work in some cases and not others.  This
patch brings some uniformity to the problem by only allowing phy
accesses while the driver has control of the device.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1f233c4..e134e48 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11444,9 +11444,7 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
 			break;			/* We have no PHY */
 
-		if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) ||
-		    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
-		     !netif_running(dev)))
+		if (!netif_running(dev))
 			return -EAGAIN;
 
 		spin_lock_bh(&tp->lock);
@@ -11462,9 +11460,7 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
 			break;			/* We have no PHY */
 
-		if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) ||
-		    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
-		     !netif_running(dev)))
+		if (!netif_running(dev))
 			return -EAGAIN;
 
 		spin_lock_bh(&tp->lock);
-- 
1.7.3.4


