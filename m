From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mdio-sun4i: oops in error handling in probe
Date: Mon, 21 Mar 2016 12:02:31 +0300
Message-ID: <20160321090231.GA31670@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25349 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbcCUJCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 05:02:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We could end up dereferencing an error pointer when we call
regulator_disable().

Fixes: 4bdcb1dd9feb ('net: Add MDIO bus driver for the Allwinner EMAC')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/phy/mdio-sun4i.c b/drivers/net/phy/mdio-sun4i.c
index f70522c..1352965 100644
--- a/drivers/net/phy/mdio-sun4i.c
+++ b/drivers/net/phy/mdio-sun4i.c
@@ -122,6 +122,7 @@ static int sun4i_mdio_probe(struct platform_device *pdev)
 			return -EPROBE_DEFER;
 
 		dev_info(&pdev->dev, "no regulator found\n");
+		data->regulator = NULL;
 	} else {
 		ret = regulator_enable(data->regulator);
 		if (ret)
@@ -137,7 +138,8 @@ static int sun4i_mdio_probe(struct platform_device *pdev)
 	return 0;
 
 err_out_disable_regulator:
-	regulator_disable(data->regulator);
+	if (data->regulator)
+		regulator_disable(data->regulator);
 err_out_free_mdiobus:
 	mdiobus_free(bus);
 	return ret;
