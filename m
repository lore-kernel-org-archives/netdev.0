From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv4 4/5] net: mvneta: add support for fixed links
Date: Fri, 16 May 2014 16:14:06 +0200
Message-ID: <1400249647-4643-5-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Florian Fainelli <florian@openwrt.org>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:41078 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754323AbaEPOOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 10:14:16 -0400
In-Reply-To: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following the introduction of of_phy_register_fixed_link(), this patch
introduces fixed link support in the mvneta driver, for Marvell Armada
370/XP SOCs.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 14786c8..f232e3b 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2797,9 +2797,22 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	phy_node = of_parse_phandle(dn, "phy", 0);
 	if (!phy_node) {
-		dev_err(&pdev->dev, "no associated PHY\n");
-		err = -ENODEV;
-		goto err_free_irq;
+		if (!of_phy_is_fixed_link(dn)) {
+			dev_err(&pdev->dev, "no PHY specified\n");
+			err = -ENODEV;
+			goto err_free_irq;
+		}
+
+		err = of_phy_register_fixed_link(dn);
+		if (err < 0) {
+			dev_err(&pdev->dev, "cannot register fixed PHY\n");
+			goto err_free_irq;
+		}
+
+		/* In the case of a fixed PHY, the DT node associated
+		 * to the PHY is the Ethernet MAC DT node.
+		 */
+		phy_node = dn;
 	}
 
 	phy_mode = of_get_phy_mode(dn);
-- 
1.9.3
