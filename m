From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 3/4] gianfar: Revive fixed link support
Date: Fri, 17 Jul 2009 01:31:42 -0600
Message-ID: <20090717073141.15652.13215.stgit@localhost.localdomain>
References: <20090717065220.15652.93331.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com
To: avorontsov@ru.mvista.com, davem@davemloft.net,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:15431 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934159AbZGQHbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 03:31:45 -0400
Received: by wa-out-1112.google.com with SMTP id j5so99972wah.21
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 00:31:44 -0700 (PDT)
In-Reply-To: <20090717065220.15652.93331.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>

Since commit fe192a49118f5b1272317d60c7930ece4e13ae49 ("Rework gianfar
driver to use of_mdio infrastructure") the fixed-link support is
broken, the driver oopses at init_phy():

  Unable to handle kernel paging request for data at address 0x000000e4
  Faulting instruction address: 0xc01cf298
  Oops: Kernel access of bad area, sig: 11 [#1]
  [...]
  NIP [c01cf298] init_phy+0x80/0xdc
  LR [c01cf250] init_phy+0x38/0xdc
  Call Trace:
  [cf81fe80] [c01d1cf8] gfar_enet_open+0x6c/0x19c
  [cf81fea0] [c024494c] dev_open+0xfc/0x134
  [cf81fec0] [c0242edc] dev_change_flags+0x84/0x1ac
  [cf81fee0] [c0399ee0] ic_open_devs+0x168/0x2d8
  [cf81ff20] [c039b2e8] ip_auto_config+0x90/0x2a4
  [cf81ff60] [c0003884] do_one_initcall+0x34/0x1a8

This patch fixes the oops, and removes phy_node checks, and adds a call
to of_phy_connect_fixed_link() if a phy isn't attached..

Also, remove an old fixed-link code that we don't use any longer.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/gianfar.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)


diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4ae1d25..79fcc2c 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -262,15 +262,6 @@ static int gfar_of_init(struct net_device *dev)
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
 
 	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
-	if (!priv->phy_node) {
-		u32 *fixed_link;
-
-		fixed_link = (u32 *)of_get_property(np, "fixed-link", NULL);
-		if (!fixed_link) {
-			err = -ENODEV;
-			goto err_out;
-		}
-	}
 
 	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
 	priv->tbi_node = of_parse_phandle(np, "tbi-handle", 0);
@@ -657,13 +648,14 @@ static int init_phy(struct net_device *dev)
 
 	interface = gfar_get_interface(dev);
 
-	if (priv->phy_node) {
-		priv->phydev = of_phy_connect(dev, priv->phy_node, &adjust_link,
-					      0, interface);
-		if (!priv->phydev) {
-			dev_err(&dev->dev, "error: Could not attach to PHY\n");
-			return -ENODEV;
-		}
+	priv->phydev = of_phy_connect(dev, priv->phy_node, &adjust_link, 0,
+				      interface);
+	if (!priv->phydev)
+		priv->phydev = of_phy_connect_fixed_link(dev, &adjust_link,
+							 interface);
+	if (!priv->phydev) {
+		dev_err(&dev->dev, "could not attach to PHY\n");
+		return -ENODEV;
 	}
 
 	if (interface == PHY_INTERFACE_MODE_SGMII)

