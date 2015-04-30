From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 2/8] net: phy: Check fixup lists in get_phy_device()
Date: Wed, 29 Apr 2015 18:57:38 -0700
Message-ID: <1430359064-23454-3-git-send-email-f.fainelli@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34782 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbbD3B6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:03 -0400
Received: by pacyx8 with SMTP id yx8so44621220pac.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:58:02 -0700 (PDT)
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MDIO-connected Ethernet switches will typicall appear as regular
Ethernet PHYs on the MDIO bus, except that they will be accessed using
their unique pseudo-PHY address (16 for Marvell, 30 for Broadcom etc...)
and reading standard MII registers such as MII_PHYSID1 and MII_PHYSID2
from this pseudo-PHY address will not yield expected results.

This is expected because the pseudo-PHY is a special port of the switch
to access internal registers.

PHY drivers will typically intercept these reads by registering a fixup,
checking that the fixup should only apply to the PHY address at the
pseudo-PHY location, and return the expected 32-bits unique OUI of the
switch when reads to that address are performed.

This currently does not work when probed from Device Tree since we
end-up calling get_phy_device() from drivers/of/of_mdio.c, read, e.g: all
F's and decide there is no such PHY there.

A simple fix to that problem is to verify that the fixup list for that
PHY is not empty, if not then we just allow the PHY device creation
since that means a corresponding driver is intending to fixup reads of
the PHY id.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bdfe51fc3a65..8efc4b8ffc59 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -333,8 +333,13 @@ struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45)
 	if (r)
 		return ERR_PTR(r);
 
-	/* If the phy_id is mostly Fs, there is no device there */
-	if ((phy_id & 0x1fffffff) == 0x1fffffff)
+	/* If the phy_id is mostly Fs and we have no fixups registered which
+	 * could alter how phydev->phy_id is going to be read,
+	 * there is no device there */
+	mutex_lock(&phy_fixup_lock);
+	r = ((phy_id & 0x1fffffff) == 0x1fffffff) && list_empty(&phy_fixup_list);
+	mutex_unlock(&phy_fixup_lock);
+	if (r)
 		return NULL;
 
 	return phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
-- 
2.1.0
