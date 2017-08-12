From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] of_mdio: merge branch tails in of_phy_register_fixed_link()
Date: Sun, 13 Aug 2017 00:03:06 +0300
Message-ID: <20170812210321.520045884@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:32865 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752091AbdHLVD1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 17:03:27 -0400
Received: by mail-lf0-f50.google.com with SMTP id d17so27603656lfe.0
        for <netdev@vger.kernel.org>; Sat, 12 Aug 2017 14:03:26 -0700 (PDT)
Content-Disposition: inline; filename=of_mdio-merge-branch-tails-in-of_phy_register_fixed_link.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks  like gcc isn't always able to figure  out that 3 *if* branches in
of_phy_register_fixed_link() calling fixed_phy_register() at their ends
are similar enough and thus can be merged. The "manual" merge saves 40
bytes of the object code (AArch64 gcc 4.8.5), and still saves 12 bytes
even  if gcc was able to merge the branch tails (ARM gcc 4.8.5)...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next' repo.

 drivers/of/of_mdio.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

Index: net-next/drivers/of/of_mdio.c
===================================================================
--- net-next.orig/drivers/of/of_mdio.c
+++ net-next/drivers/of/of_mdio.c
@@ -422,16 +422,13 @@ int of_phy_register_fixed_link(struct de
 	struct fixed_phy_status status = {};
 	struct device_node *fixed_link_node;
 	u32 fixed_link_prop[5];
-	struct phy_device *phy;
 	const char *managed;
-	int link_gpio;
+	int link_gpio = -1;
 
-	if (of_property_read_string(np, "managed", &managed) == 0) {
-		if (strcmp(managed, "in-band-status") == 0) {
-			/* status is zeroed, namely its .link member */
-			phy = fixed_phy_register(PHY_POLL, &status, -1, np);
-			return PTR_ERR_OR_ZERO(phy);
-		}
+	if (of_property_read_string(np, "managed", &managed) == 0 &&
+	    strcmp(managed, "in-band-status") == 0) {
+		/* status is zeroed, namely its .link member */
+		goto register_phy;
 	}
 
 	/* New binding */
@@ -454,8 +451,7 @@ int of_phy_register_fixed_link(struct de
 		if (link_gpio == -EPROBE_DEFER)
 			return -EPROBE_DEFER;
 
-		phy = fixed_phy_register(PHY_POLL, &status, link_gpio, np);
-		return PTR_ERR_OR_ZERO(phy);
+		goto register_phy;
 	}
 
 	/* Old binding */
@@ -466,11 +462,14 @@ int of_phy_register_fixed_link(struct de
 		status.speed  = fixed_link_prop[2];
 		status.pause  = fixed_link_prop[3];
 		status.asym_pause = fixed_link_prop[4];
-		phy = fixed_phy_register(PHY_POLL, &status, -1, np);
-		return PTR_ERR_OR_ZERO(phy);
+		goto register_phy;
 	}
 
 	return -ENODEV;
+
+register_phy:
+	return PTR_ERR_OR_ZERO(fixed_phy_register(PHY_POLL, &status, link_gpio,
+						  np));
 }
 EXPORT_SYMBOL(of_phy_register_fixed_link);
 
