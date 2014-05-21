From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RESEND net-next 3/9] net: bcmgenet: use the new fixed PHY helpers
Date: Wed, 21 May 2014 14:38:45 -0700
Message-ID: <1400708331-18088-4-git-send-email-f.fainelli@gmail.com>
References: <1400708331-18088-1-git-send-email-f.fainelli@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400708331-18088-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_phy_connect_fixed_link() is becoming obsolete, and also required
platform code to register the fixed PHYs at the specified addresses for
those to be usable. Get rid of it and use the new of_phy_is_fixed_link()
plus of_phy_register_fixed_link() helpers to transition over the new
scheme.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 4608673beaff..add8d8596084 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -298,6 +298,7 @@ int bcmgenet_mii_config(struct net_device *dev)
 static int bcmgenet_mii_probe(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
+	struct device_node *dn = priv->pdev->dev.of_node;
 	struct phy_device *phydev;
 	unsigned int phy_flags;
 	int ret;
@@ -307,15 +308,19 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 		return 0;
 	}
 
-	if (priv->phy_dn)
-		phydev = of_phy_connect(dev, priv->phy_dn,
-					bcmgenet_mii_setup, 0,
-					priv->phy_interface);
-	else
-		phydev = of_phy_connect_fixed_link(dev,
-					bcmgenet_mii_setup,
-					priv->phy_interface);
+	/* In the case of a fixed PHY, the DT node associated
+	 * to the PHY is the Ethernet MAC DT node.
+	 */
+	if (of_phy_is_fixed_link(dn)) {
+		ret = of_phy_register_fixed_link(dn);
+		if (ret)
+			return ret;
+
+		priv->phy_dn = dn;
+	}
 
+	phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup, 0,
+				priv->phy_interface);
 	if (!phydev) {
 		pr_err("could not attach to PHY\n");
 		return -ENODEV;
-- 
1.9.1
