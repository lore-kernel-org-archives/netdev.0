From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH v2] Marvell phy: add fiber status check for some components
Date: Mon, 4 Apr 2016 15:06:59 +0200
Message-ID: <570266F3.4000400@nexvision.fr>
References: <56FE9B5C.6030509@nexvision.fr> <56FEA2EC.2030303@nexvision.fr>
 <20160401170838.GA21633@lunn.ch> <570229B6.4090805@nexvision.fr>
 <20160404122219.GD21828@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070603070909030103010300"
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 19.mo4.mail-out.ovh.net ([87.98.179.66]:50772 "EHLO
	19.mo4.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbcDDNHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 09:07:04 -0400
Received: from mail699.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo4.mail-out.ovh.net (Postfix) with SMTP id 41324118406B
	for <netdev@vger.kernel.org>; Mon,  4 Apr 2016 15:07:01 +0200 (CEST)
In-Reply-To: <20160404122219.GD21828@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070603070909030103010300
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

Hi,
I took into account previous remark from Andrew to return in MII_M1111_COPPER page in all cases.
I completed the description of patch.

Thanks for all.
Regards,
Charles-Antoine Couret

--------------070603070909030103010300
Content-Type: text/x-patch;
 name="marvell.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="marvell.patch"

>From 564b767163d19355a3b5efaad195e93796570c71 Mon Sep 17 00:00:00 2001
From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Date: Fri, 1 Apr 2016 16:16:35 +0200
Subject: [PATCH] Marvell phy: add fiber status check for some components

Marvell's phy could have two modes: fiber and copper. Currently, the driver
checks only the copper mode registers to get the status link which could be
wrong.

This commit add a handler to check fiber then copper status link.
If the fiber link is activated, the driver would use this information.
Else, it would use the copper status.

This patch is not tested with all Marvell's phy.
The new function is actived only for tested phys.

Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
---
 drivers/net/phy/marvell.c | 43 +++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index ab1d0fc..22552ab 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -890,6 +890,45 @@ static int marvell_read_status(struct phy_device *phydev)
 	return 0;
 }
 
+/* marvell_read_fiber_status
+ *
+ * Some Marvell's phys have two modes: fiber and copper.
+ * Both need status checked.
+ * Description:
+ *   First, check the fiber link and status.
+ *   If the fiber link is down, check the copper link and status which
+ *   will be the default value if both link are down.
+ */
+static int marvell_read_fiber_status(struct phy_device *phydev)
+{
+	int err;
+
+	/* Check the fiber mode first */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+	if (err < 0)
+		goto error;
+
+	err = marvell_read_status(phydev);
+	if (err < 0)
+		goto error;
+
+	if (phydev->link) {
+		phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+		return 0;
+	}
+
+	/* If fiber link is down, check and save copper mode state */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	if (err < 0)
+		goto error;
+
+	return marvell_read_status(phydev);
+
+error:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return err;
+}
+
 static int marvell_aneg_done(struct phy_device *phydev)
 {
 	int retval = phy_read(phydev, MII_M1011_PHY_STATUS);
@@ -1122,7 +1161,7 @@ static struct phy_driver marvell_drivers[] = {
 		.probe = marvell_probe,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
-		.read_status = &marvell_read_status,
+		.read_status = &marvell_read_fiber_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.resume = &genphy_resume,
@@ -1270,7 +1309,7 @@ static struct phy_driver marvell_drivers[] = {
 		.probe = marvell_probe,
 		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
-		.read_status = &marvell_read_status,
+		.read_status = &marvell_read_fiber_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.did_interrupt = &m88e1121_did_interrupt,
-- 
2.5.5


--------------070603070909030103010300--
