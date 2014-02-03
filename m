From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH] net:phy:dp83640: Initialize PTP clocks at device init.
Date: Mon,  3 Feb 2014 15:36:58 +0100
Message-ID: <1391438218-21994-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:60808 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752465AbaBCOzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 09:55:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The trigger and events functionality can be useful even if packet
timestamping is not used, but the required PTP clock is only enabled
when packet timestamping is started. This patch moves the clock enable
to when the interface is configured.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 80c5fc8..14616e4 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1064,6 +1064,13 @@ static void dp83640_remove(struct phy_device *ph=
ydev)
 	kfree(dp83640);
 }
=20
+static int dp83640_config_init(struct phy_device *phydev)
+{
+	enable_status_frames(phydev, true);
+	ext_write(0, phydev, PAGE4, PTP_CTL, PTP_ENABLE);
+	return 0;
+}
+
 static int dp83640_ack_interrupt(struct phy_device *phydev)
 {
 	int err =3D phy_read(phydev, MII_DP83640_MISR);
@@ -1201,11 +1208,6 @@ static int dp83640_hwtstamp(struct phy_device *p=
hydev, struct ifreq *ifr)
=20
 	mutex_lock(&dp83640->clock->extreg_lock);
=20
-	if (dp83640->hwts_tx_en || dp83640->hwts_rx_en) {
-		enable_status_frames(phydev, true);
-		ext_write(0, phydev, PAGE4, PTP_CTL, PTP_ENABLE);
-	}
-
 	ext_write(0, phydev, PAGE5, PTP_TXCFG0, txcfg0);
 	ext_write(0, phydev, PAGE5, PTP_RXCFG0, rxcfg0);
=20
@@ -1337,6 +1339,7 @@ static struct phy_driver dp83640_driver =3D {
 	.flags		=3D PHY_HAS_INTERRUPT,
 	.probe		=3D dp83640_probe,
 	.remove		=3D dp83640_remove,
+	.config_init	=3D dp83640_config_init,
 	.config_aneg	=3D genphy_config_aneg,
 	.read_status	=3D genphy_read_status,
 	.ack_interrupt  =3D dp83640_ack_interrupt,
--=20
1.8.5.3
