From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 4/8] net: mv643xx_eth: Handle Ethernet switches as PHY devices
Date: Wed, 29 Apr 2015 18:57:40 -0700
Message-ID: <1430359064-23454-5-git-send-email-f.fainelli@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33403 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbbD3B6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:06 -0400
Received: by pdbnk13 with SMTP id nk13so45266878pdb.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:58:06 -0700 (PDT)
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing Ethernet switches to be real PHY devices,
adjust the mv643x_eth driver to do two things in case such a PHY device
is detected:

- do not program the PHY polling unit to watch for this PHY since it
  would yield inconsistent results, reading from the pseudo-PHY address,
  not regular MII_BMSR registers

- force the link indication since this is the CPU-facing port of the
  switch which is always up and running

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 1c75829eb166..72ce27562d6f 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2321,7 +2321,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 
 	pscr |= DO_NOT_FORCE_LINK_FAIL;
-	if (mp->phy == NULL)
+	if (mp->phy == NULL || (mp->phy && phy_is_ethswitch(mp->phy)))
 		pscr |= FORCE_LINK_PASS;
 	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 
@@ -3101,7 +3101,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 					 PHY_INTERFACE_MODE_GMII);
 		if (!mp->phy)
 			err = -ENODEV;
-		else
+		else if (!phy_is_ethswitch(mp->phy))
 			phy_addr_set(mp, mp->phy->addr);
 	} else if (pd->phy_addr != MV643XX_ETH_PHY_NONE) {
 		mp->phy = phy_scan(mp, pd->phy_addr);
-- 
2.1.0
