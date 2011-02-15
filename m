From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-2.6/stable] tg3: Restrict phy ioctl access
Date: Tue, 15 Feb 2011 14:51:10 -0800
Message-ID: <1297810270-4690-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1524 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756458Ab1BOWvb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 17:51:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If management firmware is present and the device is down, the firmware
will assume control of the phy.  If a phy access were allowed from the
host, it will collide with firmware phy accesses, resulting in
unpredictable behavior.  This patch fixes the problem by disallowing phy
accesses during the problematic condition.

Upstream commit ID f746a3136a61ae535c5d0b49a9418fa21edc61b5

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 93b32d3..06c0e503 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11158,7 +11158,9 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
 			break;			/* We have no PHY */
 
-		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
+		if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) ||
+		    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
+		     !netif_running(dev)))
 			return -EAGAIN;
 
 		spin_lock_bh(&tp->lock);
@@ -11174,7 +11176,9 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
 			break;			/* We have no PHY */
 
-		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
+		if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) ||
+		    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
+		     !netif_running(dev)))
 			return -EAGAIN;
 
 		spin_lock_bh(&tp->lock);
-- 
1.7.3.4


