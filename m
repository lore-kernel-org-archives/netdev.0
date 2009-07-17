From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 4/4] ucc_geth: Revive fixed link support
Date: Fri, 17 Jul 2009 01:31:47 -0600
Message-ID: <20090717073147.15652.21395.stgit@localhost.localdomain>
References: <20090717065220.15652.93331.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com
To: avorontsov@ru.mvista.com, davem@davemloft.net,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f197.google.com ([209.85.222.197]:52484 "EHLO
	mail-pz0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934169AbZGQHbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 03:31:49 -0400
Received: by mail-pz0-f197.google.com with SMTP id 35so477161pzk.33
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 00:31:49 -0700 (PDT)
In-Reply-To: <20090717065220.15652.93331.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>

Since commit 0b9da337dca972e7a4144e298ec3adb8f244d4a4 ("Rework
ucc_geth driver to use of_mdio infrastructure") the fixed-link
support is broken.

This patch fixes the support by removing !ug_info->phy_node check,
and adds a call to of_phy_connect_fixed_link() if a phy is not attached
to the MAC.

Also, remove an old fixed-link code that we don't use any longer.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/ucc_geth.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)


diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 40c6eba..3b957e6 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1590,13 +1590,13 @@ static int init_phy(struct net_device *dev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	if (!ug_info->phy_node)
-		return 0;
-
 	phydev = of_phy_connect(dev, ug_info->phy_node, &adjust_link, 0,
 				priv->phy_interface);
+	if (!phydev)
+		phydev = of_phy_connect_fixed_link(dev, &adjust_link,
+						   priv->phy_interface);
 	if (!phydev) {
-		printk("%s: Could not attach to PHY\n", dev->name);
+		dev_err(&dev->dev, "Could not attach to PHY\n");
 		return -ENODEV;
 	}
 
@@ -3608,9 +3608,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	struct ucc_geth_private *ugeth = NULL;
 	struct ucc_geth_info *ug_info;
 	struct resource res;
-	struct device_node *phy;
 	int err, ucc_num, max_speed = 0;
-	const u32 *fixed_link;
 	const unsigned int *prop;
 	const char *sprop;
 	const void *mac_addr;
@@ -3708,15 +3706,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
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
@@ -3725,7 +3716,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	prop = of_get_property(np, "phy-connection-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
-		prop = of_get_property(phy, "interface", NULL);
+		prop = of_get_property(ug_info->phy_node, "interface", NULL);
 		if (prop != NULL) {
 			phy_interface = enet_to_phy_interface[*prop];
 			max_speed = enet_to_speed[*prop];

