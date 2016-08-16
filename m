From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [PATCH] net: macb: add phy-handle support for the macb
Date: Tue, 16 Aug 2016 07:01:49 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5E27C6@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1471082509-11764-1-git-send-email-appanad@xilinx.com>
 <20160813.115222.443333178659469072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "robh+dt@kernel.org" <robh+dt@kernel.org>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
	"sergio.prado@e-labworks.com" <sergio.prado@e-labworks.com>,
	"gregory.clement@free-electrons.com"
	<gregory.clement@free-electrons.com>,
	"narmstrong@baylibre.com" <narmstrong@baylibre.com>,
	Michal Simek <michals@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0052.outbound.protection.outlook.com ([104.47.37.52]:43184
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751006AbcHPHE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 03:04:29 -0400
In-Reply-To: <20160813.115222.443333178659469072.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David Miller,

	Thanks for the review...

> 
> From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
> Date: Sat, 13 Aug 2016 15:31:49 +0530
> 
> > @@ -445,7 +445,13 @@ static int macb_mii_init(struct macb *bp)
> >  	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
> >
> >  	np = bp->pdev->dev.of_node;
> > -	if (np) {
> > +	np1 = of_get_parent(bp->phy_node);
> > +	if (np1) {
> > +		of_node_put(np1);
> > +		err = of_mdiobus_register(bp->mii_bus, np1);
> > +		if (err)
> > +			goto err_out_unregister_bus;
> > +	} else if (np) {
> 
> I don't know about this, all OF nodes other than the root have a parent node
> which is non-NULL.  This parent node can be anything.
> 
> Just blinding assuming that any parent node of the phy_node is what we are
> looking for, without any other supplementary checks at all, seems to be asking
> for trouble at the very least.

Agree with you my intention is if there is a MDIO bus on the device-tree
The MAC driver should create PHY/MDIO devices using of_mdiobus_register().

How about below code...

-       struct device_node *np;
+       struct device_node *np, *np1;
        int err = -ENXIO, i;
 
        /* Enable management port */
@@ -445,7 +445,14 @@ static int macb_mii_init(struct macb *bp)
        dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
 
        np = bp->pdev->dev.of_node;
-       if (np) {
+       np1 = of_get_child_by_name(np, "mdio");
+       if (np1) {
+               of_node_put(np1);
+               err = of_mdiobus_register(bp->mii_bus, np1);
+               if (err)
+                       goto err_out_unregister_bus;
+       } else if (np) {
                /* try dt phy registration */
                err = of_mdiobus_register(bp->mii_bus, np);

If you are ok with the above code please let me know will post it as v2...

Regards,
Kedar.
