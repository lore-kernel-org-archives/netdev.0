From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH 1/3] fsl_pq_mdio: Fix compiler/sparse warnings (part 1)
Date: Thu, 5 Nov 2009 10:31:20 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950696@zin33exm22.fsl.freescale.net>
References: <20091104225256.GA29537@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Fleming Andy-AFLEMING" <afleming@freescale.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	"David Miller" <davem@davemloft.net>
To: "Anton Vorontsov" <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44185 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbZKEFBV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 00:01:21 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nA551NbI014415
	for <netdev@vger.kernel.org>; Wed, 4 Nov 2009 22:01:24 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nA554UkZ006782
	for <netdev@vger.kernel.org>; Wed, 4 Nov 2009 23:04:31 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091104225256.GA29537@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: Anton Vorontsov [mailto:avorontsov@ru.mvista.com] 
>Sent: Thursday, November 05, 2009 4:23 AM
>To: David Miller
>Cc: Fleming Andy-AFLEMING; Kumar Gopalpet-B05799; 
>netdev@vger.kernel.org; linuxppc-dev@ozlabs.org
>Subject: [PATCH 1/3] fsl_pq_mdio: Fix compiler/sparse warnings (part 1)
>
>commit 1d2397d742b7a2b39b2f09dd9da3b9d1463f55e9 ("fsl_pq_mdio: 
>Add Suport for etsec2.0 devices") introduced the following warnings:
>
>  CHECK   fsl_pq_mdio.c
>fsl_pq_mdio.c:287:22: warning: incorrect type in initializer 
>(different base types)
>fsl_pq_mdio.c:287:22:    expected unknown type 11 const *__mptr
>fsl_pq_mdio.c:287:22:    got unsigned long long [unsigned] 
>[assigned] [usertype] addr
>fsl_pq_mdio.c:287:19: warning: incorrect type in assignment 
>(different base types)
>fsl_pq_mdio.c:287:19:    expected unsigned long long 
>[unsigned] [usertype] ioremap_miimcfg
>fsl_pq_mdio.c:287:19:    got struct fsl_pq_mdio *<noident>
>  CC      fsl_pq_mdio.o
>fsl_pq_mdio.c: In function 'fsl_pq_mdio_probe':
>fsl_pq_mdio.c:287: warning: initialization makes pointer from 
>integer without a cast
>fsl_pq_mdio.c:287: warning: assignment makes integer from 
>pointer without a cast
>
>These warnings are not easy to fix without ugly __force casts. 
>So, instead of introducing the casts, rework the code to 
>substitute an offset from an already mapped area. This makes 
>the code a lot simpler and less duplicated.
>
>Plus, from now on we don't actually map reserved registers on 
>non-etsec2.0 devices, so we have more chances to catch 
>programming errors.
>
>Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
>---
> drivers/net/fsl_pq_mdio.c |   31 ++++++++++++-------------------
> 1 files changed, 12 insertions(+), 19 deletions(-)
>
>diff --git a/drivers/net/fsl_pq_mdio.c 
>b/drivers/net/fsl_pq_mdio.c index 4065b7c..fb8c8d9 100644
>--- a/drivers/net/fsl_pq_mdio.c
>+++ b/drivers/net/fsl_pq_mdio.c
>@@ -262,10 +262,11 @@ static int fsl_pq_mdio_probe(struct 
>of_device *ofdev,
> 	struct device_node *np = ofdev->node;
> 	struct device_node *tbi;
> 	struct fsl_pq_mdio __iomem *regs = NULL;
>+	void __iomem *map;
> 	u32 __iomem *tbipa;
> 	struct mii_bus *new_bus;
> 	int tbiaddr = -1;
>-	u64 addr = 0, size = 0, ioremap_miimcfg = 0;
>+	u64 addr = 0, size = 0;
> 	int err = 0;
> 
> 	new_bus = mdiobus_alloc();
>@@ -279,28 +280,20 @@ static int fsl_pq_mdio_probe(struct 
>of_device *ofdev,
> 	fsl_pq_mdio_bus_name(new_bus->id, np);
> 
> 	/* Set the PHY base address */
>-	if (of_device_is_compatible(np,"fsl,gianfar-mdio") ||
>-		of_device_is_compatible(np, "fsl,gianfar-tbi") ||
>-		of_device_is_compatible(np, "fsl,ucc-mdio") ||
>-		of_device_is_compatible(np,"ucc_geth_phy" )) {
>-		addr = of_translate_address(np, 
>of_get_address(np, 0, &size, NULL));
>-		ioremap_miimcfg =  container_of(addr, struct 
>fsl_pq_mdio, miimcfg);
>-		regs = ioremap(ioremap_miimcfg, size +
>-				offsetof(struct fsl_pq_mdio, miimcfg));
>-	} else if (of_device_is_compatible(np,"fsl,etsec2-mdio") ||
>-			of_device_is_compatible(np, "fsl,etsec2-tbi")) {
>-		addr = of_translate_address(np, 
>of_get_address(np, 0, &size, NULL));
>-		regs = ioremap(addr, size);
>-	} else {
>-		err = -EINVAL;
>-		goto err_free_bus;
>-	}
>-
>-	if (NULL == regs) {
>+	addr = of_translate_address(np, of_get_address(np, 0, 
>&size, NULL));
>+	map = ioremap(addr, size);
>+	if (!map) {
> 		err = -ENOMEM;
> 		goto err_free_bus;
> 	}
> 
>+	if (of_device_is_compatible(np, "fsl,gianfar-mdio") ||
>+			of_device_is_compatible(np, 
>"fsl,gianfar-tbi") ||
>+			of_device_is_compatible(np, "fsl,ucc-mdio") ||
>+			of_device_is_compatible(np, "ucc_geth_phy"))
>+		map -= offsetof(struct fsl_pq_mdio, miimcfg);
>+	regs = map;
>+
> 	new_bus->priv = (void __force *)regs;
> 
> 	new_bus->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
>--

HI Anton, thanks for the changes. I have only one concern, has this code
been tried for ucc_geth ? I remember I had some issues with getting the
ucc_geth mdio also working. I will take in these changes and try at my
end for ucc_geth.


-Thanks
Sandeep 
