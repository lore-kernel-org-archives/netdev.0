From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/11] tg3: Restrict phy ioctl access
Date: Tue, 25 Jan 2011 17:58:51 -0800
Message-ID: <1296007137-23146-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1849 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752512Ab1AZB7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If management firmware is present and the device is down, the firmware
will assume control of the phy.  If a phy access were allowed from the
host, it will collide with firmware phy accesses, resulting in
unpredictable behavior.  This patch fixes the problem by disallowing phy
accesses during the problematic condition.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b1274bc..b957b60 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11165,7 +11165,9 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
 			break;			/* We have no PHY */
 
-		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
+		if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) ||
+		    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
+		     !netif_running(dev)))
 			return -EAGAIN;
 
 		spin_lock_bh(&tp->lock);
@@ -11181,7 +11183,9 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
 			break;			/* We have no PHY */
 
-		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
+		if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) ||
+		    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
+		     !netif_running(dev)))
 			return -EAGAIN;
 
 		spin_lock_bh(&tp->lock);
-- 
1.7.2.2


