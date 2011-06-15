From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: Re: [PATCH] ep93xx-eth: convert to phylib
Date: Wed, 15 Jun 2011 22:15:05 +0300
Message-ID: <20110615191505.GA2595@acer>
References: <201106051957.36492.florian@openwrt.org>
 <201106052029.24742.f.fainelli@gmail.com>
 <20110609203059.GZ16318@ibawizard.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Herbert Valerio Riedel <hvr@gnu.org>, davem@davemloft.net,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	Lennert Buytenhek <kernel@wantstofly.org>,
	linux-arm-kernel@lists.infradead.org
To: Petr =?utf-8?Q?=C5=A0tetiar?= <ynezz@true.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42854 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab1FOTRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 15:17:50 -0400
Received: by eyx24 with SMTP id 24so284895eyx.19
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2011 12:17:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110609203059.GZ16318@ibawizard.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2011 at 10:30:59PM +0200, Petr =C5=A0tetiar wrote:
>=20
> just FYI, I wanted to test recent Mika's DMA/ep93xx_eth fixes, so I'v=
e added
> this patch also and it oopsed. If I revert this patch, it seems to wo=
rk so
> far. You can find the whole patchset I've been testing on the GitHub[=
1]. I've
> tested it on ts-7250 and ts-7300, the oops is same. Here's the oops:
>=20
> 	ep93xx-eth version 0.1 loading
> 	ep93xx_eth_mii: probed
> 	ep93xx_eth:ep93xx_mii_probe: no PHY found
> 	ep93xx-eth ep93xx-eth: failed to probe MII bus

I ran into same problem when I tried this patch on my TS-7260. It turne=
d out
that call to mdiobus_register() tries to access PHY registers and the h=
ardware
is not fully initialized yet. On Sim.One there is no such problem and I=
 guess
that the bootloader leaves the hardware in more consistent state or som=
ething.

I was able to boot both TS-7260 and Sim.One with following hack on top =
of
this patch:

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.=
c
index 21cc0ee..06eeb10 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -241,6 +241,13 @@ static int ep93xx_mdiobus_write(struct mii_bus *bu=
s, int phy_id, int reg, u16 da
=20
 static int ep93xx_mdiobus_reset(struct mii_bus *bus)
 {
+	struct ep93xx_priv *ep =3D netdev_priv(bus->priv);
+
+	/*
+	 * Make sure that the PHY clock divisor is valid before trying to
+	 * access any of it's registers.
+	 */
+	wrl(ep, REG_SELFCTL, ((ep->mdc_divisor - 1) << 9));
 	return 0;
 }
=20
@@ -631,10 +638,8 @@ err:
 	return 1;
 }
=20
-static int ep93xx_start_hw(struct net_device *dev)
+static void ep93xx_reset_hw(struct ep93xx_priv *ep)
 {
-	struct ep93xx_priv *ep =3D netdev_priv(dev);
-	unsigned long addr;
 	int i;
=20
 	wrl(ep, REG_SELFCTL, REG_SELFCTL_RESET);
@@ -644,12 +649,15 @@ static int ep93xx_start_hw(struct net_device *dev=
)
 		msleep(1);
 	}
=20
-	if (i =3D=3D 10) {
+	if (i =3D=3D 10)
 		pr_crit("hw failed to reset\n");
-		return 1;
-	}
+}
=20
-	wrl(ep, REG_SELFCTL, ((ep->mdc_divisor - 1) << 9));
+static int ep93xx_start_hw(struct net_device *dev)
+{
+	struct ep93xx_priv *ep =3D netdev_priv(dev);
+	unsigned long addr;
+	int i;
=20
 	/* Does the PHY support preamble suppress?  */
 	if ((ep93xx_mdiobus_read(ep->mii_bus, ep->phy_addr, MII_BMSR) & 0x004=
0) !=3D 0)
@@ -715,18 +723,7 @@ static int ep93xx_start_hw(struct net_device *dev)
=20
 static void ep93xx_stop_hw(struct net_device *dev)
 {
-	struct ep93xx_priv *ep =3D netdev_priv(dev);
-	int i;
-
-	wrl(ep, REG_SELFCTL, REG_SELFCTL_RESET);
-	for (i =3D 0; i < 10; i++) {
-		if ((rdl(ep, REG_SELFCTL) & REG_SELFCTL_RESET) =3D=3D 0)
-			break;
-		msleep(1);
-	}
-
-	if (i =3D=3D 10)
-		pr_crit("hw failed to reset\n");
+	ep93xx_reset_hw(netdev_priv(dev));
 }
=20
 static int ep93xx_open(struct net_device *dev)
@@ -934,6 +931,8 @@ static int ep93xx_eth_probe(struct platform_device =
*pdev)
 	}
 	ep->irq =3D irq;
=20
+	ep93xx_reset_hw(ep);
+
 	ep->mii_bus =3D mdiobus_alloc();
 	if (!ep->mii_bus) {
 		dev_err(&pdev->dev, "Failed to allocate mdiobus\n");

