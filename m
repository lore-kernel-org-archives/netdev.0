From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH 4/4] Marvell phy: add functions to suspend and resume both interfaces: fiber and copper links.
Date: Mon, 18 Jul 2016 11:03:43 +0200
Message-ID: <1468832623-1792-5-git-send-email-charles-antoine.couret@nexvision.fr>
References: <1468832623-1792-1-git-send-email-charles-antoine.couret@nexvision.fr>
Cc: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
To: cacouret.renault@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 10.mo3.mail-out.ovh.net ([87.98.165.232]:57715 "EHLO
	10.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbcGRJXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 05:23:43 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 216DC1020E6D
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 11:04:49 +0200 (CEST)
In-Reply-To: <1468832623-1792-1-git-send-email-charles-antoine.couret@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
---
 drivers/net/phy/marvell.c | 73 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 71 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e05209b..ddb413a 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1224,6 +1224,75 @@ error:
 	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
 	return err;
 }
+
+/* marvell_suspend
+ *
+ * Some Marvell's phys have two modes: fiber and copper.
+ * Both need to be suspended
+ */
+static int marvell_suspend(struct phy_device *phydev)
+{
+	int err;
+
+	/* Suspend the fiber mode first */
+	if (!(phydev->supported & SUPPORTED_FIBRE)) {
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+		if (err < 0)
+			goto error;
+
+		/* With the page set, use the generic suspend */
+		err = genphy_suspend(phydev);
+		if (err < 0)
+			goto error;
+
+		/* Then, the copper link */
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+		if (err < 0)
+			goto error;
+	}
+
+	/* With the page set, use the generic suspend */
+	return genphy_suspend(phydev);
+
+error:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return err;
+}
+
+/* marvell_resume
+ *
+ * Some Marvell's phys have two modes: fiber and copper.
+ * Both need to be resumed
+ */
+static int marvell_resume(struct phy_device *phydev)
+{
+	int err;
+
+	/* Resume the fiber mode first */
+	if (!(phydev->supported & SUPPORTED_FIBRE)) {
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+		if (err < 0)
+			goto error;
+
+		/* With the page set, use the generic resume */
+		err = genphy_resume(phydev);
+		if (err < 0)
+			goto error;
+
+		/* Then, the copper link */
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+		if (err < 0)
+			goto error;
+	}
+
+	/* With the page set, use the generic resume */
+	return genphy_resume(phydev);
+
+error:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return err;
+}
+
 static int marvell_aneg_done(struct phy_device *phydev)
 {
 	int retval = phy_read(phydev, MII_M1011_PHY_STATUS);
@@ -1611,8 +1680,8 @@ static struct phy_driver marvell_drivers[] = {
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.did_interrupt = &m88e1121_did_interrupt,
-		.resume = &genphy_resume,
-		.suspend = &genphy_suspend,
+		.resume = &marvell_resume,
+		.suspend = &marvell_suspend,
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-- 
2.7.4
