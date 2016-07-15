From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH 4/4 v4] Marvell phy: add functions to suspend and resume both,
 interfaces: fiber and copper links.
Date: Fri, 15 Jul 2016 12:13:10 +0200
Message-ID: <1d7ec528-7d58-d35c-b585-69657fe8d517@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 14.mo3.mail-out.ovh.net ([188.165.43.98]:59563 "EHLO
	14.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbcGOQIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 12:08:49 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 93A1B1030687
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:13:10 +0200 (CEST)
Received: from [192.168.1.29] (LFbn-1-1866-70.w90-73.abo.wanadoo.fr [90.73.165.70])
	(Authenticated sender: charles-antoine.couret@nexvision.fr)
	by player734.ha.ovh.net (Postfix) with ESMTPSA id 84255280073
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:13:10 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From 95a2a268629ee2778f0ad65a273d70bcf912c4b0 Mon Sep 17 00:00:00 2001
From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Date: Fri, 15 Jul 2016 11:58:09 +0200
Subject: [PATCH 4/4] Marvell phy: add functions to suspend and resume both
 interfaces: fiber and copper links.

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
