From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 6/9] net/gianfar: Rework gianfar driver to use OF PHY/MDIO
	helper functions
Date: Wed, 18 Mar 2009 23:07:01 -0600
Message-ID: <fa686aa40903182207w227bba9fie796b5c073078abf@mail.gmail.com>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
	 <20090319050043.11320.96160.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:33845 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbZCSFHD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:07:03 -0400
Received: by yw-out-2324.google.com with SMTP id 5so392906ywb.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:07:01 -0700 (PDT)
In-Reply-To: <20090319050043.11320.96160.stgit@localhost.localdomain>
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
> =A0drivers/net/gianfar.c =A0 =A0 | =A0 94 ++++++++++++++-------------=
------------------
> =A0drivers/net/gianfar.h =A0 =A0 | =A0 =A03 +
> =A0drivers/net/gianfar_mii.c | =A0 52 +------------------------
> =A03 files changed, 34 insertions(+), 115 deletions(-)
>
>
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 9831b3f..0521267 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -75,6 +75,7 @@
> =A0#include <linux/if_vlan.h>
> =A0#include <linux/spinlock.h>
> =A0#include <linux/mm.h>
> +#include <linux/of_mdio.h>
> =A0#include <linux/of_platform.h>
> =A0#include <linux/ip.h>
> =A0#include <linux/tcp.h>
> @@ -155,17 +156,13 @@ static inline int gfar_uses_fcb(struct gfar_pri=
vate *priv)
>
> =A0static int gfar_of_init(struct net_device *dev)
> =A0{
> - =A0 =A0 =A0 struct device_node *phy, *mdio;
> - =A0 =A0 =A0 const unsigned int *id;
> =A0 =A0 =A0 =A0const char *model;
> =A0 =A0 =A0 =A0const char *ctype;
> =A0 =A0 =A0 =A0const void *mac_addr;
> - =A0 =A0 =A0 const phandle *ph;
> =A0 =A0 =A0 =A0u64 addr, size;
> =A0 =A0 =A0 =A0int err =3D 0;
> =A0 =A0 =A0 =A0struct gfar_private *priv =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0struct device_node *np =3D priv->node;
> - =A0 =A0 =A0 char bus_name[MII_BUS_ID_SIZE];
>
> =A0 =A0 =A0 =A0if (!np || !of_device_is_available(np))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
> @@ -228,8 +225,8 @@ static int gfar_of_init(struct net_device *dev)
> =A0 =A0 =A0 =A0if (of_get_property(np, "fsl,magic-packet", NULL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->device_flags |=3D FSL_GIANFAR_DE=
V_HAS_MAGIC_PACKET;
>
> - =A0 =A0 =A0 ph =3D of_get_property(np, "phy-handle", NULL);
> - =A0 =A0 =A0 if (ph =3D=3D NULL) {
> + =A0 =A0 =A0 priv->phy_node =3D of_parse_phandle(np, "phy-device", 0=
);
> + =A0 =A0 =A0 if (!priv->phy_node) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 *fixed_link;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fixed_link =3D (u32 *)of_get_property(=
np, "fixed-link", NULL);
> @@ -237,57 +234,10 @@ static int gfar_of_init(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENODEV;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(priv->phy_bus_id, sizeof(priv-=
>phy_bus_id),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PHY_ID_=
=46MT, "0", fixed_link[0]);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy =3D of_find_node_by_phandle(*ph);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (phy =3D=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENODEV;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio =3D of_get_parent(phy);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D of_get_property(phy, "reg", NULL=
);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(phy);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(mdio);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfar_mdio_bus_name(bus_name, mdio);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(priv->phy_bus_id, sizeof(priv-=
>phy_bus_id), "%s:%02x",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus_nam=
e, *id);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Find the TBI PHY. =A0If it's not there, we don't su=
pport SGMII */
> - =A0 =A0 =A0 ph =3D of_get_property(np, "tbi-handle", NULL);
> - =A0 =A0 =A0 if (ph) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device_node *tbi =3D of_find_nod=
e_by_phandle(*ph);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct of_device *ofdev;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mii_bus *bus;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!tbi)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio =3D of_get_parent(tbi);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mdio)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ofdev =3D of_find_device_by_node(mdio);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(mdio);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D of_get_property(tbi, "reg", NULL=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!id)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(tbi);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus =3D dev_get_drvdata(&ofdev->dev);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->tbiphy =3D bus->phy_map[*id];
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 priv->tbi_node =3D of_parse_phandle(np, "tbi-handle", 0=
);
>
> =A0 =A0 =A0 =A0return 0;
>
> @@ -661,7 +611,6 @@ static int init_phy(struct net_device *dev)
> =A0 =A0 =A0 =A0uint gigabit_support =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->device_flags & FSL_GIANFAR_DEV_H=
AS_GIGABIT ?
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SUPPORTED_1000baseT_Full : 0;
> - =A0 =A0 =A0 struct phy_device *phydev;
> =A0 =A0 =A0 =A0phy_interface_t interface;
>
> =A0 =A0 =A0 =A0priv->oldlink =3D 0;
> @@ -670,23 +619,38 @@ static int init_phy(struct net_device *dev)
>
> =A0 =A0 =A0 =A0interface =3D gfar_get_interface(dev);
>
> - =A0 =A0 =A0 phydev =3D phy_connect(dev, priv->phy_bus_id, &adjust_l=
ink, 0, interface);
> + =A0 =A0 =A0 if (priv->phy_node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->phydev =3D of_phy_connect(dev, pr=
iv->phy_node, &adjust_link,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 0, interface);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!priv->phydev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "err=
or: Could not attach to PHY\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (priv->tbi_node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->tbiphy =3D of_phy_connect(dev, pr=
iv->tbi_node, &adjust_link,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 0, interface);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!priv->tbiphy) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "err=
or: Could not attach to TBI\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_tbiphy;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0if (interface =3D=3D PHY_INTERFACE_MODE_SGMII)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfar_configure_serdes(dev);
>
> - =A0 =A0 =A0 if (IS_ERR(phydev)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s: Could not attach t=
o PHY\n", dev->name);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(phydev);
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0/* Remove any features not supported by the controller=
 */
> - =A0 =A0 =A0 phydev->supported &=3D (GFAR_SUPPORTED | gigabit_suppor=
t);
> - =A0 =A0 =A0 phydev->advertising =3D phydev->supported;
> -
> - =A0 =A0 =A0 priv->phydev =3D phydev;
> + =A0 =A0 =A0 priv->phydev->supported &=3D (GFAR_SUPPORTED | gigabit_=
support);
> + =A0 =A0 =A0 priv->phydev->advertising =3D priv->phydev->supported;
>
> =A0 =A0 =A0 =A0return 0;
> +
> + err_tbiphy:
> + =A0 =A0 =A0 if (priv->phy_node)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_disconnect(priv->phydev);
> + =A0 =A0 =A0 priv->phydev =3D NULL;
> + =A0 =A0 =A0 return -ENODEV;
> =A0}
>
> =A0/*
> diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
> index eaa8689..d3d56a9 100644
> --- a/drivers/net/gianfar.h
> +++ b/drivers/net/gianfar.h
> @@ -775,7 +775,8 @@ struct gfar_private {
> =A0 =A0 =A0 =A0spinlock_t bflock;
>
> =A0 =A0 =A0 =A0phy_interface_t interface;
> - =A0 =A0 =A0 char =A0 =A0phy_bus_id[BUS_ID_SIZE];
> + =A0 =A0 =A0 struct device_node *phy_node;
> + =A0 =A0 =A0 struct device_node *tbi_node;
> =A0 =A0 =A0 =A0u32 device_flags;
> =A0 =A0 =A0 =A0unsigned char rx_csum_enable:1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0extended_hash:1,
> diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
> index f49a426..c6d77bd 100644
> --- a/drivers/net/gianfar_mii.c
> +++ b/drivers/net/gianfar_mii.c
> @@ -35,6 +35,7 @@
> =A0#include <linux/mii.h>
> =A0#include <linux/phy.h>
> =A0#include <linux/of.h>
> +#include <linux/of_mdio.h>
> =A0#include <linux/of_platform.h>
>
> =A0#include <asm/io.h>
> @@ -152,45 +153,6 @@ static int gfar_mdio_reset(struct mii_bus *bus)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -/* Allocate an array which provides irq #s for each PHY on the given=
 bus */
> -static int *create_irq_map(struct device_node *np)
> -{
> - =A0 =A0 =A0 int *irqs;
> - =A0 =A0 =A0 int i;
> - =A0 =A0 =A0 struct device_node *child =3D NULL;
> -
> - =A0 =A0 =A0 irqs =3D kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL)=
;
> -
> - =A0 =A0 =A0 if (!irqs)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> -
> - =A0 =A0 =A0 for (i =3D 0; i < PHY_MAX_ADDR; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 irqs[i] =3D PHY_POLL;
> -
> - =A0 =A0 =A0 while ((child =3D of_get_next_child(np, child)) !=3D NU=
LL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int irq =3D irq_of_parse_and_map(child,=
 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 const u32 *id;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (irq =3D=3D NO_IRQ)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D of_get_property(child, "reg", NU=
LL);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!id)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (*id < PHY_MAX_ADDR && *id >=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 irqs[*id] =3D irq;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING "%s=
: "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "%d is not a valid PHY address\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 np->full_name, *id);
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 return irqs;
> -}
> -
> -
> =A0void gfar_mdio_bus_name(char *name, struct device_node *np)
> =A0{
> =A0 =A0 =A0 =A0const u32 *reg;
> @@ -253,7 +215,7 @@ static int gfar_mdio_probe(struct of_device *ofde=
v,
>
> =A0 =A0 =A0 =A0new_bus->priv =3D (void __force *)regs;
>
> - =A0 =A0 =A0 new_bus->irq =3D create_irq_map(np);
> + =A0 =A0 =A0 new_bus->irq =3D kcalloc(PHY_MAX_ADDR, sizeof(int), GFP=
_KERNEL);
>
> =A0 =A0 =A0 =A0if (new_bus->irq =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> @@ -301,15 +263,7 @@ static int gfar_mdio_probe(struct of_device *ofd=
ev,
>
> =A0 =A0 =A0 =A0gfar_write(&enet_regs->tbipa, tbiaddr);
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* The TBIPHY-only buses will find PHYs at every addr=
ess,
> - =A0 =A0 =A0 =A0* so we mask them all but the TBI
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (!of_device_is_compatible(np, "fsl,gianfar-mdio"))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus->phy_mask =3D ~(1 << tbiaddr);
> -
> - =A0 =A0 =A0 err =3D mdiobus_register(new_bus);
> -
> + =A0 =A0 =A0 err =3D of_mdiobus_register(new_bus, np);
> =A0 =A0 =A0 =A0if (err !=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk (KERN_ERR "%s: Cannot register =
as MDIO bus\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_bu=
s->name);
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
