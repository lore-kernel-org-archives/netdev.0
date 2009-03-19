From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 7/9] net/ucc_geth: Rework ucc_geth driver to use OF
	PHY/MDIO helper functions
Date: Wed, 18 Mar 2009 23:07:14 -0600
Message-ID: <fa686aa40903182207x6d6f0c2cl9b37c681479e64e6@mail.gmail.com>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
	 <20090319050049.11320.98769.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:9449 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529AbZCSFHQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:07:16 -0400
Received: by yx-out-2324.google.com with SMTP id 31so394125yxl.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:07:14 -0700 (PDT)
In-Reply-To: <20090319050049.11320.98769.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC, please don't apply yet.

On Wed, Mar 18, 2009 at 11:00 PM, Grant Likely
<grant.likely@secretlab.ca> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
>
> This patch simplifies the driver by making use of more common code.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
>
> =A0drivers/net/ucc_geth.c =A0 =A0 | =A0 27 ++++++--------------------=
-
> =A0drivers/net/ucc_geth_mii.c | =A0 17 +++--------------
> =A02 files changed, 9 insertions(+), 35 deletions(-)
>
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index e879868..45bb627 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -28,6 +28,7 @@
> =A0#include <linux/mii.h>
> =A0#include <linux/phy.h>
> =A0#include <linux/workqueue.h>
> +#include <linux/of_mdio.h>
> =A0#include <linux/of_platform.h>
>
> =A0#include <asm/uaccess.h>
> @@ -1537,35 +1538,19 @@ static int init_phy(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct ucc_geth_private *priv =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0struct device_node *np =3D priv->node;
> - =A0 =A0 =A0 struct device_node *phy, *mdio;
> - =A0 =A0 =A0 const phandle *ph;
> - =A0 =A0 =A0 char bus_name[MII_BUS_ID_SIZE];
> - =A0 =A0 =A0 const unsigned int *id;
> + =A0 =A0 =A0 struct device_node *phy;
> =A0 =A0 =A0 =A0struct phy_device *phydev;
> - =A0 =A0 =A0 char phy_id[BUS_ID_SIZE];
>
> =A0 =A0 =A0 =A0priv->oldlink =3D 0;
> =A0 =A0 =A0 =A0priv->oldspeed =3D 0;
> =A0 =A0 =A0 =A0priv->oldduplex =3D -1;
>
> - =A0 =A0 =A0 ph =3D of_get_property(np, "phy-handle", NULL);
> - =A0 =A0 =A0 phy =3D of_find_node_by_phandle(*ph);
> - =A0 =A0 =A0 mdio =3D of_get_parent(phy);
> -
> - =A0 =A0 =A0 id =3D of_get_property(phy, "reg", NULL);
> -
> + =A0 =A0 =A0 phy =3D of_parse_phandle(np, "phy-handle", 0);
> + =A0 =A0 =A0 phydev =3D of_phy_connect(dev, phy, &adjust_link, 0, pr=
iv->phy_interface);
> =A0 =A0 =A0 =A0of_node_put(phy);
> - =A0 =A0 =A0 of_node_put(mdio);
> -
> - =A0 =A0 =A0 uec_mdio_bus_name(bus_name, mdio);
> - =A0 =A0 =A0 snprintf(phy_id, sizeof(phy_id), "%s:%02x",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bus_=
name, *id);
> -
> - =A0 =A0 =A0 phydev =3D phy_connect(dev, phy_id, &adjust_link, 0, pr=
iv->phy_interface);
> -
> - =A0 =A0 =A0 if (IS_ERR(phydev)) {
> + =A0 =A0 =A0 if (!phydev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk("%s: Could not attach to PHY\n"=
, dev->name);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(phydev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0phydev->supported &=3D (ADVERTISED_10baseT_Half |
> diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
> index 0ada4ed..9f2492f 100644
> --- a/drivers/net/ucc_geth_mii.c
> +++ b/drivers/net/ucc_geth_mii.c
> @@ -36,6 +36,7 @@
> =A0#include <linux/mii.h>
> =A0#include <linux/phy.h>
> =A0#include <linux/fsl_devices.h>
> +#include <linux/of_mdio.h>
> =A0#include <linux/of_platform.h>
>
> =A0#include <asm/io.h>
> @@ -135,11 +136,10 @@ static int uec_mdio_probe(struct of_device *ofd=
ev, const struct of_device_id *ma
> =A0{
> =A0 =A0 =A0 =A0struct device *device =3D &ofdev->dev;
> =A0 =A0 =A0 =A0struct device_node *np =3D ofdev->node, *tempnp =3D NU=
LL;
> - =A0 =A0 =A0 struct device_node *child =3D NULL;
> =A0 =A0 =A0 =A0struct ucc_mii_mng __iomem *regs;
> =A0 =A0 =A0 =A0struct mii_bus *new_bus;
> =A0 =A0 =A0 =A0struct resource res;
> - =A0 =A0 =A0 int k, err =3D 0;
> + =A0 =A0 =A0 int err =3D 0;
>
> =A0 =A0 =A0 =A0new_bus =3D mdiobus_alloc();
> =A0 =A0 =A0 =A0if (NULL =3D=3D new_bus)
> @@ -165,17 +165,6 @@ static int uec_mdio_probe(struct of_device *ofde=
v, const struct of_device_id *ma
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto reg_map_fail;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 for (k =3D 0; k < 32; k++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus->irq[k] =3D PHY_POLL;
> -
> - =A0 =A0 =A0 while ((child =3D of_get_next_child(np, child)) !=3D NU=
LL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int irq =3D irq_of_parse_and_map(child,=
 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (irq !=3D NO_IRQ) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const u32 *id =3D of_ge=
t_property(child, "reg", NULL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus->irq[*id] =3D i=
rq;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0/* Set the base address */
> =A0 =A0 =A0 =A0regs =3D ioremap(res.start, sizeof(struct ucc_mii_mng)=
);
>
> @@ -220,7 +209,7 @@ static int uec_mdio_probe(struct of_device *ofdev=
, const struct of_device_id *ma
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 err =3D mdiobus_register(new_bus);
> + =A0 =A0 =A0 err =3D of_mdiobus_register(new_bus, np);
> =A0 =A0 =A0 =A0if (0 !=3D err) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "%s: Cannot register a=
s MDIO bus\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus->name);
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
