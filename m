From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] of_mdio: use of_property_read_u32_array()
Date: Sat, 05 Aug 2017 00:43:43 +0300
Message-ID: <20170804214354.351406407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:38880 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbdHDVoD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 17:44:03 -0400
Received: by mail-lf0-f43.google.com with SMTP id y15so11812505lfd.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 14:44:02 -0700 (PDT)
Content-Disposition: inline; filename=of_mdio-use-of_property_read_u32_array.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "fixed-link" prop support predated of_property_read_u32_array(), so
basically had to open-code it. Using the modern API saves 24 bytes of the
object code (ARM gcc 4.8.5); the only behavior change would be that the
prop length check is now less strict (however the strict pre-check done
in of_phy_is_fixed_link() is left intact anyway)...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the 'dt/next' branch of Rob Herring's 'linux-git' repo
plus the previously posted patch killing the useless local variable in
of_phy_register_fixed_link().

 drivers/of/of_mdio.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

Index: linux/drivers/of/of_mdio.c
===================================================================
--- linux.orig/drivers/of/of_mdio.c
+++ linux/drivers/of/of_mdio.c
@@ -421,10 +421,10 @@ int of_phy_register_fixed_link(struct de
 {
 	struct fixed_phy_status status = {};
 	struct device_node *fixed_link_node;
-	const __be32 *fixed_link_prop;
+	u32 fixed_link_prop[5];
 	struct phy_device *phy;
 	const char *managed;
-	int link_gpio, len;
+	int link_gpio;
 
 	if (of_property_read_string(np, "managed", &managed) == 0) {
 		if (strcmp(managed, "in-band-status") == 0) {
@@ -459,13 +459,13 @@ int of_phy_register_fixed_link(struct de
 	}
 
 	/* Old binding */
-	fixed_link_prop = of_get_property(np, "fixed-link", &len);
-	if (fixed_link_prop && len == (5 * sizeof(__be32))) {
+	if (of_property_read_u32_array(np, "fixed-link", fixed_link_prop,
+				       ARRAY_SIZE(fixed_link_prop)) == 0) {
 		status.link = 1;
-		status.duplex = be32_to_cpu(fixed_link_prop[1]);
-		status.speed = be32_to_cpu(fixed_link_prop[2]);
-		status.pause = be32_to_cpu(fixed_link_prop[3]);
-		status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
+		status.duplex = fixed_link_prop[1];
+		status.speed  = fixed_link_prop[2];
+		status.pause  = fixed_link_prop[3];
+		status.asym_pause = fixed_link_prop[4];
 		phy = fixed_phy_register(PHY_POLL, &status, -1, np);
 		return PTR_ERR_OR_ZERO(phy);
 	}
