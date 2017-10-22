From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Sat, 21 Oct 2017 19:01:45 -0700
Message-ID: <FD695891-F3B8-4388-8887-A9DC997828B4@gmail.com>
References: <1508327643-3579-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508327643-3579-1-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On October 18, 2017 4:54:03 AM PDT, Geert Uytterhoeven <geert+renesas@glide=
r=2Ebe> wrote:
>If an Ethernet PHY is initialized before the interrupt controller it is
>connected to, a message like the following is printed:
>
>    irq: no irq domain found for /interrupt-controller@e61c0000 !
>
>However, the actual error is ignored, leading to a non-functional
>(POLL)
>PHY interrupt later:
>
>Micrel KSZ8041RNLI ee700000=2Eethernet-ffffffff:01: attached PHY driver
>[Micrel KSZ8041RNLI] (mii_bus:phy_addr=3Dee700000=2Eethernet-ffffffff:01,
>irq=3DPOLL)
>
>Depending on whether the PHY driver will fall back to polling, Ethernet
>may or may not work=2E
>
>To fix this:
>  1=2E Switch of_mdiobus_register_phy() from irq_of_parse_and_map() to
>     of_irq_get()=2E
>     Unlike the former, the latter returns -EPROBE_DEFER if the
>    interrupt controller is not yet available, so this condition can be
>     detected=2E
>     Other errors are handled the same as before, i=2Ee=2E use the passed
>     mdio->irq[addr] as interrupt=2E
>  2=2E Propagate and handle errors from of_mdiobus_register_phy() and
>     of_mdiobus_register_device()=2E
>
>Signed-off-by: Geert Uytterhoeven <geert+renesas@glider=2Ebe>

Reviewed-by : Florian Fainelli <f=2Efainelli@gmail=2Ecom>

I still can't make sure this is not a problem for multiple PHYs hanging of=
f the same bus, but like anything else, we'll deal with problems later if t=
hey arise=2E

>---
>Seen on e=2Eg=2E r8a7791/koelsch when using the new CPG/MSSR clock driver=
,
>which will hit upstream in v4=2E15=2E  I assume it always happened on RZ/=
G1
>in mainline=2E
>
>The actual patch is unchanged since v1, sent on May 18=2E  Obviously I
>still cannot test it on a system with multiple PHYs, just like v1=2E
>
>How can we proceed?
>
>Note that if you are worried about the MDIO subsystem not handling
>(partial) teardown and reprobe correctly in the presence of multiple
>PHYs, that can already be triggered since commit a5597008dbc23087
>("phy:
>fixed_phy: Add gpio to determine link up/down=2E"), which handles
>EPROBE_DEFER for GPIOs=2E
>
>Thanks!
>
>v2:
> - Update for non-functional interrupts being printed as "POLL" instead
>    of "-1" since commit 5e369aefdce4818c ("net: stmmac: Delete dead
>    code for MDIO registration")=2E
>---
> drivers/of/of_mdio=2Ec | 39 +++++++++++++++++++++++++++------------
> 1 file changed, 27 insertions(+), 12 deletions(-)
>
>diff --git a/drivers/of/of_mdio=2Ec b/drivers/of/of_mdio=2Ec
>index d94dd8b77abd5140=2E=2E98258583abb0b405 100644
>--- a/drivers/of/of_mdio=2Ec
>+++ b/drivers/of/of_mdio=2Ec
>@@ -44,7 +44,7 @@ static int of_get_phy_id(struct device_node *device,
>u32 *phy_id)
> 	return -EINVAL;
> }
>=20
>-static void of_mdiobus_register_phy(struct mii_bus *mdio,
>+static int of_mdiobus_register_phy(struct mii_bus *mdio,
> 				    struct device_node *child, u32 addr)
> {
> 	struct phy_device *phy;
>@@ -60,9 +60,13 @@ static void of_mdiobus_register_phy(struct mii_bus
>*mdio,
> 	else
> 		phy =3D get_phy_device(mdio, addr, is_c45);
> 	if (IS_ERR(phy))
>-		return;
>+		return PTR_ERR(phy);
>=20
>-	rc =3D irq_of_parse_and_map(child, 0);
>+	rc =3D of_irq_get(child, 0);
>+	if (rc =3D=3D -EPROBE_DEFER) {
>+		phy_device_free(phy);
>+		return rc;
>+	}
> 	if (rc > 0) {
> 		phy->irq =3D rc;
> 		mdio->irq[addr] =3D rc;
>@@ -84,22 +88,23 @@ static void of_mdiobus_register_phy(struct mii_bus
>*mdio,
> 	if (rc) {
> 		phy_device_free(phy);
> 		of_node_put(child);
>-		return;
>+		return rc;
> 	}
>=20
> 	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
> 		child->name, addr);
>+	return 0;
> }
>=20
>-static void of_mdiobus_register_device(struct mii_bus *mdio,
>-				       struct device_node *child, u32 addr)
>+static int of_mdiobus_register_device(struct mii_bus *mdio,
>+				      struct device_node *child, u32 addr)
> {
> 	struct mdio_device *mdiodev;
> 	int rc;
>=20
> 	mdiodev =3D mdio_device_create(mdio, addr);
> 	if (IS_ERR(mdiodev))
>-		return;
>+		return PTR_ERR(mdiodev);
>=20
> 	/* Associate the OF node with the device structure so it
> 	 * can be looked up later=2E
>@@ -112,11 +117,12 @@ static void of_mdiobus_register_device(struct
>mii_bus *mdio,
> 	if (rc) {
> 		mdio_device_free(mdiodev);
> 		of_node_put(child);
>-		return;
>+		return rc;
> 	}
>=20
> 	dev_dbg(&mdio->dev, "registered mdio device %s at address %i\n",
> 		child->name, addr);
>+	return 0;
> }
>=20
> /* The following is a list of PHY compatible strings which appear in
>@@ -219,9 +225,11 @@ int of_mdiobus_register(struct mii_bus *mdio,
>struct device_node *np)
> 		}
>=20
> 		if (of_mdiobus_child_is_phy(child))
>-			of_mdiobus_register_phy(mdio, child, addr);
>+			rc =3D of_mdiobus_register_phy(mdio, child, addr);
> 		else
>-			of_mdiobus_register_device(mdio, child, addr);
>+			rc =3D of_mdiobus_register_device(mdio, child, addr);
>+		if (rc)
>+			goto unregister;
> 	}
>=20
> 	if (!scanphys)
>@@ -242,12 +250,19 @@ int of_mdiobus_register(struct mii_bus *mdio,
>struct device_node *np)
> 			dev_info(&mdio->dev, "scan phy %s at address %i\n",
> 				 child->name, addr);
>=20
>-			if (of_mdiobus_child_is_phy(child))
>-				of_mdiobus_register_phy(mdio, child, addr);
>+			if (of_mdiobus_child_is_phy(child)) {
>+				rc =3D of_mdiobus_register_phy(mdio, child, addr);
>+				if (rc)
>+					goto unregister;
>+			}
> 		}
> 	}
>=20
> 	return 0;
>+
>+unregister:
>+	mdiobus_unregister(mdio);
>+	return rc;
> }
> EXPORT_SYMBOL(of_mdiobus_register);
>=20


--=20
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
