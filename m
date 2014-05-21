From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RESEND net-next 6/9] gianfar: use the new fixed PHY helpers
Date: Wed, 21 May 2014 14:38:48 -0700
Message-ID: <1400708331-18088-7-git-send-email-f.fainelli@gmail.com>
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
 drivers/net/ethernet/freescale/gianfar.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index e2d42475b006..282674027c92 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -889,6 +889,17 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 
 	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
 
+	/* In the case of a fixed PHY, the DT node associated
+	 * to the PHY is the Ethernet MAC DT node.
+	 */
+	if (of_phy_is_fixed_link(np)) {
+		err = of_phy_register_fixed_link(np);
+		if (err)
+			goto err_grp_init;
+
+		priv->phy_node = np;
+	}
+
 	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
 	priv->tbi_node = of_parse_phandle(np, "tbi-handle", 0);
 
@@ -1660,9 +1671,6 @@ static int init_phy(struct net_device *dev)
 
 	priv->phydev = of_phy_connect(dev, priv->phy_node, &adjust_link, 0,
 				      interface);
-	if (!priv->phydev)
-		priv->phydev = of_phy_connect_fixed_link(dev, &adjust_link,
-							 interface);
 	if (!priv->phydev) {
 		dev_err(&dev->dev, "could not attach to PHY\n");
 		return -ENODEV;
-- 
1.9.1
