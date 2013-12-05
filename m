From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/7] net: of_mdio: do not overwrite PHY interrupt configuration
Date: Thu, 5 Dec 2013 14:52:12 -0800
Message-ID: <1386283936-26104-4-git-send-email-florian@openwrt.org>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <abrodkin@synopsys.com>,
	<rob.herring@calxeda.com>, <mark.rutland@arm.com>,
	<sebastian.hesselbarth@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:8568 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab3LEXCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:02:04 -0500
In-Reply-To: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

If irq_of_parse_and_map fails to find an interrupt line for a given PHY,
we will force the PHY interrupt to be PHY_POLL, completely overriding
the previous value that the MDIO bus may have set for us (e.g:
PHY_IGNORE_INTERRUPT). In case of failure, just restore the previous
value.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/of/of_mdio.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index f93ebca..4923ab2 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -27,7 +27,7 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 {
 	struct phy_device *phy;
 	bool is_c45;
-	int rc;
+	int rc, prev_irq;
 
 	is_c45 = of_device_is_compatible(child,
 					 "ethernet-phy-ieee802.3-c45");
@@ -37,10 +37,11 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 		return 1;
 
 	if (mdio->irq) {
+		prev_irq= mdio->irq[addr];
 		mdio->irq[addr] =
 			irq_of_parse_and_map(child, 0);
 		if (!mdio->irq[addr])
-			mdio->irq[addr] = PHY_POLL;
+			mdio->irq[addr] = prev_irq;
 	}
 
 	/* Associate the OF node with the device structure so it
-- 
1.8.3.2
