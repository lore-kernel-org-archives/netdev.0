From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 5/9] fs_enet: use the new fixed PHY helpers
Date: Thu, 22 May 2014 09:47:47 -0700
Message-ID: <1400777271-32199-6-git-send-email-f.fainelli@gmail.com>
References: <1400777271-32199-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Li Yang <leoli@freescale.com>,
	Grant Likely <grant.likely@linaro.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Aida Mynzhasova <aida.mynzhasova@skitlab.ru>,
	Richard Cochran <richardcochran@gmail.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	devicetree@vger.kernel.org (open list:OPEN FIRMWARE AND...),
	linux-kernel@vger.kernel.org (open list),
	linuxppc-dev@lists.ozlabs.org (open list:LINUX FOR POWERPC...)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:61167 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbaEVQsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 12:48:23 -0400
In-Reply-To: <1400777271-32199-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_phy_connect_fixed_link() is becoming obsolete, and also required
platform code to register the fixed PHYs at the specified addresses for
those to be usable. Get rid of it and use the new of_phy_is_fixed_link()
plus of_phy_register_fixed_link() helpers to transition over the new
scheme.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
- merge if conditions on the same line as suggested by Sergei
- add comment explaining the device_node pointer assignment

 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index dc80db41d6b3..cfaf17b70f3f 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -792,10 +792,6 @@ static int fs_init_phy(struct net_device *dev)
 	phydev = of_phy_connect(dev, fep->fpi->phy_node, &fs_adjust_link, 0,
 				iface);
 	if (!phydev) {
-		phydev = of_phy_connect_fixed_link(dev, &fs_adjust_link,
-						   iface);
-	}
-	if (!phydev) {
 		dev_err(&dev->dev, "Could not attach to PHY\n");
 		return -ENODEV;
 	}
@@ -1029,9 +1025,16 @@ static int fs_enet_probe(struct platform_device *ofdev)
 	fpi->use_napi = 1;
 	fpi->napi_weight = 17;
 	fpi->phy_node = of_parse_phandle(ofdev->dev.of_node, "phy-handle", 0);
-	if ((!fpi->phy_node) && (!of_get_property(ofdev->dev.of_node, "fixed-link",
-						  NULL)))
-		goto out_free_fpi;
+	if (!fpi->phy_node && of_phy_is_fixed_link(ofdev->dev.of_node)) {
+		err = of_phy_register_fixed_link(ofdev->dev.of_node);
+		if (err)
+			goto out_free_fpi;
+
+		/* In the case of a fixed PHY, the DT node associated
+		 * to the PHY is the Ethernet MAC DT node.
+		 */
+		fpi->phy_node = ofdev->dev.of_node;
+	}
 
 	if (of_device_is_compatible(ofdev->dev.of_node, "fsl,mpc5125-fec")) {
 		phy_connection_type = of_get_property(ofdev->dev.of_node,
-- 
1.9.1
