From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/4] ucc_geth: Revive fixed link support
Date: Sat, 27 Jun 2009 02:29:50 +0400
Message-ID: <20090626222950.GC32487@oksana.dev.rtsoft.ru>
References: <20090626222900.GA14594@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Li Yang <leoli@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:11819 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755350AbZFZW3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 18:29:47 -0400
Content-Disposition: inline
In-Reply-To: <20090626222900.GA14594@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0b9da337dca972e7a4144e298ec3adb8f244d4a4 ("Rework
ucc_geth driver to use of_mdio infrastructure") the fixed-link
support is broken.

This patch fixes the support by removing !ug_info->phy_node check,
today the of_phy_connect() will try to find a fixed PHY if the
phy_node appears to be NULL.

Also, remove an old fixed-link code that we don't use any longer.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   18 +++---------------
 1 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 40c6eba..2dc83b1 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1590,9 +1590,6 @@ static int init_phy(struct net_device *dev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	if (!ug_info->phy_node)
-		return 0;
-
 	phydev = of_phy_connect(dev, ug_info->phy_node, &adjust_link, 0,
 				priv->phy_interface);
 	if (!phydev) {
@@ -3608,9 +3605,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	struct ucc_geth_private *ugeth = NULL;
 	struct ucc_geth_info *ug_info;
 	struct resource res;
-	struct device_node *phy;
 	int err, ucc_num, max_speed = 0;
-	const u32 *fixed_link;
 	const unsigned int *prop;
 	const char *sprop;
 	const void *mac_addr;
@@ -3708,15 +3703,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ug_info->uf_info.regs = res.start;
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
-	fixed_link = of_get_property(np, "fixed-link", NULL);
-	if (fixed_link) {
-		phy = NULL;
-	} else {
-		phy = of_parse_phandle(np, "phy-handle", 0);
-		if (phy == NULL)
-			return -ENODEV;
-	}
-	ug_info->phy_node = phy;
+
+	ug_info->phy_node = of_parse_phandle(np, "phy-handle", 0);
 
 	/* Find the TBI PHY node.  If it's not there, we don't support SGMII */
 	ug_info->tbi_node = of_parse_phandle(np, "tbi-handle", 0);
@@ -3725,7 +3713,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	prop = of_get_property(np, "phy-connection-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
-		prop = of_get_property(phy, "interface", NULL);
+		prop = of_get_property(ug_info->phy_node, "interface", NULL);
 		if (prop != NULL) {
 			phy_interface = enet_to_phy_interface[*prop];
 			max_speed = enet_to_speed[*prop];
-- 
1.6.3.1

