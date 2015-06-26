From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] net: phy: bcm7xxx: workaround MDIO management controller initial read
Date: Fri, 26 Jun 2015 10:38:32 -0700
Message-ID: <1435340314-10229-3-git-send-email-f.fainelli@gmail.com>
References: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33726 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbbFZRkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:40:12 -0400
Received: by padev16 with SMTP id ev16so72046566pad.0
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:40:11 -0700 (PDT)
In-Reply-To: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The initial MDIO read or write towards the BCM7xxx integrated PHY may
fail, workaround this by inserting a dummy MII_BMSR read to force the
MDIO management controller to see at least one valid transaction and get
out of stuck state out of reset.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 4dea85bfc545..6b701b3ded74 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -246,6 +246,13 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	pr_info_once("%s: %s PHY revision: 0x%02x, patch: %d\n",
 		     dev_name(&phydev->dev), phydev->drv->name, rev, patch);
 
+	/* Dummy read to a register to workaround an issue upon reset where the
+	 * internal inverter may not allow the first MDIO transaction to pass
+	 * the MDIO management controller and make us return 0xffff for such
+	 * reads.
+	 */
+	phy_read(phydev, MII_BMSR);
+
 	switch (rev) {
 	case 0xb0:
 		ret = bcm7xxx_28nm_b0_afe_config_init(phydev);
-- 
2.1.0
