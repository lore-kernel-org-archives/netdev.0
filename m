From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 8/8] net: phy: bcm7xxx: utilize PHY revision in config_init
Date: Fri, 19 Sep 2014 13:07:56 -0700
Message-ID: <1411157276-18260-9-git-send-email-f.fainelli@gmail.com>
References: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36039 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932330AbaISUIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:08:22 -0400
Received: by mail-pa0-f41.google.com with SMTP id ey11so845570pad.0
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 13:08:21 -0700 (PDT)
In-Reply-To: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the GENET and SF2 drivers have been updated to communicate us
what is the revision of the BCM7xxx integrated PHY, utilize that
information in the config_init() callback to call into the appropriate
workaround function based on our revision.

While at it, we also print the revision and patch level to help debug
new chips.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index be3a591aabba..daae69950925 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -196,13 +196,22 @@ static int bcm7xxx_eee_enable(struct phy_device *phydev)
 
 static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 {
-	int ret;
-
-	ret = bcm7445_config_init(phydev);
-	if (ret)
-		return ret;
+	u8 rev = PHY_BRCM_7XXX_REV(phydev->dev_flags);
+	u8 patch = PHY_BRCM_7XXX_PATCH(phydev->dev_flags);
+	int ret = 0;
+
+	dev_info(&phydev->dev, "PHY revision: 0x%02x, patch: %d\n", rev, patch);
+
+	switch (rev) {
+	case 0xa0:
+	case 0xb0:
+		ret = bcm7445_config_init(phydev);
+		break;
+	default:
+		ret = bcm7xxx_28nm_afe_config_init(phydev);
+		break;
+	}
 
-	ret = bcm7xxx_28nm_afe_config_init(phydev);
 	if (ret)
 		return ret;
 
-- 
1.9.1
