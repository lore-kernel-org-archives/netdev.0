From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] net: ethernet: ibm-emac: Add 5482 PHY init for OpenBlocks
 600
Date: Fri, 01 Sep 2017 14:44:49 +1000
Message-ID: <1504241089.4974.67.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55387 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750996AbdIAEox (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 00:44:53 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v814inR0009452
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 23:44:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vendor patches initialize those registers to get the
PHY working properly.

Sadly I don't have that PHY spec and whatever Broadcom PHY
code we already have don't seem to document these two shadow
registers (unless I miscalculated the address) so I'm keeping
this as "vendor magic for that board". The vendor has long
abandoned that product, but I find it handy to test ppc405
kernels and so would like to keep it alive upstream :-)

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Note: Ideally, the whole driver should switch over to the
generic PHY layer. However this is a much bigger undertaking
which requires access to a bunch of HW to test, and for which
I have neither the time nor the HW available these days.

(Some of the HW could prove hard to find ...)
---
 drivers/net/ethernet/ibm/emac/phy.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/ibm/emac/phy.c b/drivers/net/ethernet/ibm/emac/phy.c
index 35865d05fccd..daa10de542fb 100644
--- a/drivers/net/ethernet/ibm/emac/phy.c
+++ b/drivers/net/ethernet/ibm/emac/phy.c
@@ -24,6 +24,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/delay.h>
+#include <linux/of.h>
 
 #include "emac.h"
 #include "phy.h"
@@ -363,6 +364,34 @@ static struct mii_phy_def bcm5248_phy_def = {
 	.ops		= &generic_phy_ops
 };
 
+static int bcm5482_init(struct mii_phy *phy)
+{
+	if (!of_machine_is_compatible("plathome,obs600"))
+		return 0;
+
+	/* Magic inits from vendor original patches */
+	phy_write(phy, 0x1c, 0xa410);
+	phy_write(phy, 0x1c, 0x8804);
+
+	return 0;
+}
+
+static const struct mii_phy_ops bcm5482_phy_ops = {
+	.init		= bcm5482_init,
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link
+};
+
+static struct mii_phy_def bcm5482_phy_def = {
+
+	.phy_id		= 0x0143bcb0,
+	.phy_id_mask	= 0x0ffffff0,
+	.name		= "BCM5482 Gigabit Ethernet",
+	.ops		= &bcm5482_phy_ops
+};
+
 static int m88e1111_init(struct mii_phy *phy)
 {
 	pr_debug("%s: Marvell 88E1111 Ethernet\n", __func__);
@@ -499,6 +528,7 @@ static struct mii_phy_def *mii_phy_table[] = {
 	&et1011c_phy_def,
 	&cis8201_phy_def,
 	&bcm5248_phy_def,
+	&bcm5482_phy_def,
 	&m88e1111_phy_def,
 	&m88e1112_phy_def,
 	&ar8035_phy_def,
-- 
2.13.5
