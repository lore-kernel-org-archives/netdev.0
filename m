From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH] net:phy:dp83640: Move all HW initialization to dp83640_config_init
Date: Thu, 13 Feb 2014 15:26:57 +0100
Message-ID: <1392301617-24354-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:57713 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751908AbaBMO1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 09:27:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_init_hw not does a full PHY reset after the driver probe has
finished, so any hw initialization done in the probe will be lost.
Part of the timestamping functionality of the dp83640 is set up in the
probe and with that lost, enabling timestamping will cause a PHY
lockup, requiring a hard reset / power cycle to recover.

This patch moves all the HW initialization in dp83640_probe to
dp83640_config_init.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 0de863c..5ff221d 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1017,11 +1017,6 @@ static int dp83640_probe(struct phy_device *phyd=
ev)
 	} else
 		list_add_tail(&dp83640->list, &clock->phylist);
=20
-	if (clock->chosen && !list_empty(&clock->phylist))
-		recalibrate(clock);
-	else
-		enable_broadcast(dp83640->phydev, clock->page, 1);
-
 	dp83640_clock_put(clock);
 	return 0;
=20
@@ -1074,6 +1069,14 @@ static void dp83640_remove(struct phy_device *ph=
ydev)
=20
 static int dp83640_config_init(struct phy_device *phydev)
 {
+	struct dp83640_private *dp83640 =3D phydev->priv;
+	struct dp83640_clock *clock =3D dp83640->clock;
+
+	if (clock->chosen && !list_empty(&clock->phylist))
+		recalibrate(clock);
+	else
+		enable_broadcast(phydev, clock->page, 1);
+
 	enable_status_frames(phydev, true);
 	ext_write(0, phydev, PAGE4, PTP_CTL, PTP_ENABLE);
 	return 0;
--=20
1.8.5.3
