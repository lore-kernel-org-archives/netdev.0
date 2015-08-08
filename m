From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Do not override PHY interface if already configured
Date: Sat,  8 Aug 2015 12:58:57 -0700
Message-ID: <1439063937-16316-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35777 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992609AbbHHUBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2015 16:01:12 -0400
Received: by pdrg1 with SMTP id g1so56967820pdr.2
        for <netdev@vger.kernel.org>; Sat, 08 Aug 2015 13:01:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we need to divert reads/writes using the slave MII bus, we may have
already fetched a valid PHY interface property from Device Tree, and that
mode is used by the PHY driver to make configuration decisions.

If we could not fetch the "phy-mode" property, we will assign p->phy_interface
to PHY_INTERFACE_MODE_NA, such that we can actually check for that condition as
to whether or not we should override the interface value.

Fixes: 19334920eaf7 ("net: dsa: Set valid phy interface type")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Hi Guenter,

Could you verify this does not break what you were trying to fix with your change?
I am fairly confident this will not because for "PHYs" built-into the switch port
we will not be able to fetch a "phy-mode" property from DT, so we will use
PHY_INTERFACE_MODE_NA, but here, we will re-assign them to PHY_INTERFACE_MODE_GMII
as before.

Thanks!

 net/dsa/slave.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0917123790ea..35c47ddd04f0 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -756,7 +756,8 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
 		return -ENODEV;
 
 	/* Use already configured phy mode */
-	p->phy_interface = p->phy->interface;
+	if (p->phy_interface == PHY_INTERFACE_MODE_NA)
+		p->phy_interface = p->phy->interface;
 	phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
 			   p->phy_interface);
 
-- 
2.1.0
