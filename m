From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 7/9] ucc_geth: use the new fixed PHY helpers
Date: Thu, 22 May 2014 09:47:49 -0700
Message-ID: <1400777271-32199-8-git-send-email-f.fainelli@gmail.com>
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
Received: from mail-ig0-f170.google.com ([209.85.213.170]:46879 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbaEVQs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 12:48:27 -0400
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
No changes in v2

 drivers/net/ethernet/freescale/ucc_geth.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index c8299c31b21f..fab39e295441 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -1728,9 +1728,6 @@ static int init_phy(struct net_device *dev)
 
 	phydev = of_phy_connect(dev, ug_info->phy_node, &adjust_link, 0,
 				priv->phy_interface);
-	if (!phydev)
-		phydev = of_phy_connect_fixed_link(dev, &adjust_link,
-						   priv->phy_interface);
 	if (!phydev) {
 		dev_err(&dev->dev, "Could not attach to PHY\n");
 		return -ENODEV;
@@ -3790,6 +3787,17 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
 
 	ug_info->phy_node = of_parse_phandle(np, "phy-handle", 0);
+	if (!ug_info->phy_node) {
+		/* In the case of a fixed PHY, the DT node associated
+		 * to the PHY is the Ethernet MAC DT node.
+		 */
+		if (of_phy_is_fixed_link(np)) {
+			err = of_phy_register_fixed_link(np);
+			if (err)
+				return err;
+		}
+		ug_info->phy_node = np;
+	}
 
 	/* Find the TBI PHY node.  If it's not there, we don't support SGMII */
 	ug_info->tbi_node = of_parse_phandle(np, "tbi-handle", 0);
-- 
1.9.1
