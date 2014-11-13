From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCH 2/2] net/smsc911x: Fix delays in the PHY enable/disable routines
Date: Thu, 13 Nov 2014 05:26:20 +0400
Message-ID: <1415841980-14250-2-git-send-email-al.kochet@gmail.com>
References: <1415841980-14250-1-git-send-email-al.kochet@gmail.com>
Cc: steve.glendinning@shawell.net,
	Alexander Kochetkov <al.kochet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:65220 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbaKMB0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 20:26:46 -0500
Received: by mail-lb0-f173.google.com with SMTP id n15so10496769lbi.18
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 17:26:44 -0800 (PST)
In-Reply-To: <1415841980-14250-1-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increased delay in the smsc911x_phy_disable_energy_detect (from 1ms to 2ms).
Dropped delays in the smsc911x_phy_enable_energy_detect (100ms and 1ms).

The patch affect SMSC LAN generation 4 chips with integrated PHY (LAN9221).

I saw problems with soft reset due to wrong udelay timings.
After I fixed udelay, I measured the time needed to bring integrated PHY
from power-down to operational mode (the time beetween clearing EDPWRDOWN
bit and soft reset complete event). I got 1ms (measured using ktime_get).
The value is equal to the current value (1ms) used in the
smsc911x_phy_disable_energy_detect. It is near the upper bound and in order
to avoid rare soft reset faults it is doubled (2ms).

I don't know official timing for bringing up integrated PHY as specs doesn't
clarify this (or may be I didn't found).

It looks safe to drop delays before and after setting EDPWRDOWN bit
(enable PHY power-down mode). I didn't saw any regressions with the patch.

The patch was reviewed by Steve Glendinning and Microchip Team.

Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
Acked-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/ethernet/smsc/smsc911x.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index c657184..b2b3170 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1366,8 +1366,8 @@ static int smsc911x_phy_disable_energy_detect(struct smsc911x_data *pdata)
 			SMSC_WARN(pdata, drv, "Failed writing PHY control reg");
 			return rc;
 		}
-
-		mdelay(1);
+		/* Allow PHY to wakeup */
+		mdelay(2);
 	}
 
 	return 0;
@@ -1389,7 +1389,6 @@ static int smsc911x_phy_enable_energy_detect(struct smsc911x_data *pdata)
 
 	/* Only enable if energy detect mode is already disabled */
 	if (!(rc & MII_LAN83C185_EDPWRDOWN)) {
-		mdelay(100);
 		/* Enable energy detect mode for this SMSC Transceivers */
 		rc = phy_write(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS,
 			       rc | MII_LAN83C185_EDPWRDOWN);
@@ -1398,8 +1397,6 @@ static int smsc911x_phy_enable_energy_detect(struct smsc911x_data *pdata)
 			SMSC_WARN(pdata, drv, "Failed writing PHY control reg");
 			return rc;
 		}
-
-		mdelay(1);
 	}
 	return 0;
 }
-- 
1.7.9.5
