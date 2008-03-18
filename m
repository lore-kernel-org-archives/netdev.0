From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] Add Fixed PHY support for ucc_geth
Date: Tue, 18 Mar 2008 10:46:55 +0100
Message-ID: <1205833615-15833-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Netdev <netdev@vger.kernel.org>, Li Yang <LeoLi@freescale.com>,
	"Linuxppc-Embedded@Ozlabs.Org" <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:11167 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752304AbYCRJq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 05:46:57 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new Fixed PHY method, fixed-link property, isn't
impl. for ucc_geth which makes fixed PHYs non functional.
Add support for the new method to restore the Fixed PHY
functionality.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

This is a regression as fixed PHYs works in 2.6.23 and I am
using it.

 drivers/net/ucc_geth.c |   53 +++++++++++++++++++++++++++--------------------
 1 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index ecc5712..18c8b39 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3836,6 +3836,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	struct device_node *phy;
 	int err, ucc_num, max_speed = 0;
 	const phandle *ph;
+	const u32 *fixed_link;
 	const unsigned int *prop;
 	const char *sprop;
 	const void *mac_addr;
@@ -3926,18 +3927,38 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ug_info->uf_info.regs = res.start;
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
+	fixed_link = of_get_property(np, "fixed-link", NULL);
+	if (fixed_link) {
+		ug_info->mdio_bus = 0;
+		ug_info->phy_address = fixed_link[0];
+		phy = NULL;
+	} else {
+		ph = of_get_property(np, "phy-handle", NULL);
+		phy = of_find_node_by_phandle(*ph);
 
-	ph = of_get_property(np, "phy-handle", NULL);
-	phy = of_find_node_by_phandle(*ph);
+		if (phy == NULL)
+			return -ENODEV;
 
-	if (phy == NULL)
-		return -ENODEV;
+		/* set the PHY address */
+		prop = of_get_property(phy, "reg", NULL);
+		if (prop == NULL)
+			return -1;
+		ug_info->phy_address = *prop;
+
+		/* Set the bus id */
+		mdio = of_get_parent(phy);
+
+		if (mdio == NULL)
+			return -1;
 
-	/* set the PHY address */
-	prop = of_get_property(phy, "reg", NULL);
-	if (prop == NULL)
-		return -1;
-	ug_info->phy_address = *prop;
+		err = of_address_to_resource(mdio, 0, &res);
+		of_node_put(mdio);
+
+		if (err)
+			return -1;
+
+		ug_info->mdio_bus = res.start;
+	}
 
 	/* get the phy interface type, or default to MII */
 	prop = of_get_property(np, "phy-connection-type", NULL);
@@ -3982,20 +4003,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;
 	}
 
-	/* Set the bus id */
-	mdio = of_get_parent(phy);
-
-	if (mdio == NULL)
-		return -1;
-
-	err = of_address_to_resource(mdio, 0, &res);
-	of_node_put(mdio);
-
-	if (err)
-		return -1;
-
-	ug_info->mdio_bus = res.start;
-
 	if (netif_msg_probe(&debug))
 		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
 			ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
-- 
1.5.4.3

