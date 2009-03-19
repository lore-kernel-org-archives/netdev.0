From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 9/9] net/fs_enet: Rework fs_enet driver to use of_mdio
	infrastructure
Date: Wed, 18 Mar 2009 23:07:35 -0600
Message-ID: <fa686aa40903182207r2f62985ar35afcf36b480b7e2@mail.gmail.com>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
	 <20090319050100.11320.64495.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f208.google.com ([209.85.217.208]:36262 "EHLO
	mail-gx0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756838AbZCSFHi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:07:38 -0400
Received: by gxk4 with SMTP id 4so1785790gxk.13
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:07:35 -0700 (PDT)
In-Reply-To: <20090319050100.11320.64495.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC, please don't apply yet.

On Wed, Mar 18, 2009 at 11:01 PM, Grant Likely
<grant.likely@secretlab.ca> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
>
> This patch simplifies the driver by making use of more common code.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
>
> =A0drivers/net/fs_enet/fs_enet-main.c | =A0 66 +++++-----------------=
--------------
> =A0drivers/net/fs_enet/mii-bitbang.c =A0| =A0 29 +---------------
> =A0drivers/net/fs_enet/mii-fec.c =A0 =A0 =A0| =A0 26 +-------------
> =A0include/linux/fs_enet_pd.h =A0 =A0 =A0 =A0 | =A0 =A06 +--
> =A04 files changed, 14 insertions(+), 113 deletions(-)
>
>
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet=
/fs_enet-main.c
> index ce900e5..e039d6a 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -36,6 +36,8 @@
> =A0#include <linux/fs.h>
> =A0#include <linux/platform_device.h>
> =A0#include <linux/phy.h>
> +#include <linux/of.h>
> +#include <linux/of_mdio.h>
> =A0#include <linux/of_platform.h>
> =A0#include <linux/of_gpio.h>
>
> @@ -752,9 +754,10 @@ static int fs_init_phy(struct net_device *dev)
> =A0 =A0 =A0 =A0fep->oldlink =3D 0;
> =A0 =A0 =A0 =A0fep->oldspeed =3D 0;
> =A0 =A0 =A0 =A0fep->oldduplex =3D -1;
> - =A0 =A0 =A0 if(fep->fpi->bus_id)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev =3D phy_connect(dev, fep->fpi->b=
us_id, &fs_adjust_link, 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PHY_INT=
ERFACE_MODE_MII);
> + =A0 =A0 =A0 if(fep->fpi->phy_node)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev =3D of_phy_connect(dev, fep->fpi=
->phy_node,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 &fs_adjust_link, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 PHY_INTERFACE_MODE_MII);
> =A0 =A0 =A0 =A0else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk("No phy bus ID specified in BSP=
 code\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> @@ -962,57 +965,6 @@ static void cleanup_immap(void)
>
> =A0/*****************************************************************=
*********************/
>
> -static int __devinit find_phy(struct device_node *np,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct f=
s_platform_info *fpi)
> -{
> - =A0 =A0 =A0 struct device_node *phynode, *mdionode;
> - =A0 =A0 =A0 int ret =3D 0, len, bus_id;
> - =A0 =A0 =A0 const u32 *data;
> -
> - =A0 =A0 =A0 data =A0=3D of_get_property(np, "fixed-link", NULL);
> - =A0 =A0 =A0 if (data) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(fpi->bus_id, 16, "%x:%02x", 0,=
 *data);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 data =3D of_get_property(np, "phy-handle", &len);
> - =A0 =A0 =A0 if (!data || len !=3D 4)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> -
> - =A0 =A0 =A0 phynode =3D of_find_node_by_phandle(*data);
> - =A0 =A0 =A0 if (!phynode)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> -
> - =A0 =A0 =A0 data =3D of_get_property(phynode, "reg", &len);
> - =A0 =A0 =A0 if (!data || len !=3D 4) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put_phy;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 mdionode =3D of_get_parent(phynode);
> - =A0 =A0 =A0 if (!mdionode) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put_phy;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 bus_id =3D of_get_gpio(mdionode, 0);
> - =A0 =A0 =A0 if (bus_id < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct resource res;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D of_address_to_resource(mdionode=
, 0, &res);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put_mdio;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus_id =3D res.start;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 snprintf(fpi->bus_id, 16, "%x:%02x", bus_id, *data);
> -
> -out_put_mdio:
> - =A0 =A0 =A0 of_node_put(mdionode);
> -out_put_phy:
> - =A0 =A0 =A0 of_node_put(phynode);
> - =A0 =A0 =A0 return ret;
> -}
> -
> =A0#ifdef CONFIG_FS_ENET_HAS_FEC
> =A0#define IS_FEC(match) ((match)->data =3D=3D &fs_fec_ops)
> =A0#else
> @@ -1046,9 +998,9 @@ static int __devinit fs_enet_probe(struct of_dev=
ice *ofdev,
> =A0 =A0 =A0 =A0fpi->rx_copybreak =3D 240;
> =A0 =A0 =A0 =A0fpi->use_napi =3D 1;
> =A0 =A0 =A0 =A0fpi->napi_weight =3D 17;
> -
> - =A0 =A0 =A0 ret =3D find_phy(ofdev->node, fpi);
> - =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 fpi->phy_node =3D of_parse_phandle(ofdev->node, "phy-ha=
ndle", 0);
> + =A0 =A0 =A0 if ((!fpi->phy_node) && (!of_get_property(ofdev->node, =
"fixed-link",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_fpi;
>
> =A0 =A0 =A0 =A0privsize =3D sizeof(*fep) +
> diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/=
mii-bitbang.c
> index 49b6645..93b481b 100644
> --- a/drivers/net/fs_enet/mii-bitbang.c
> +++ b/drivers/net/fs_enet/mii-bitbang.c
> @@ -22,6 +22,7 @@
> =A0#include <linux/mii.h>
> =A0#include <linux/platform_device.h>
> =A0#include <linux/mdio-bitbang.h>
> +#include <linux/of_mdio.h>
> =A0#include <linux/of_platform.h>
>
> =A0#include "fs_enet.h"
> @@ -149,31 +150,12 @@ static int __devinit fs_mii_bitbang_init(struct=
 mii_bus *bus,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static void __devinit add_phy(struct mii_bus *bus, struct device_nod=
e *np)
> -{
> - =A0 =A0 =A0 const u32 *data;
> - =A0 =A0 =A0 int len, id, irq;
> -
> - =A0 =A0 =A0 data =3D of_get_property(np, "reg", &len);
> - =A0 =A0 =A0 if (!data || len !=3D 4)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 id =3D *data;
> - =A0 =A0 =A0 bus->phy_mask &=3D ~(1 << id);
> -
> - =A0 =A0 =A0 irq =3D of_irq_to_resource(np, 0, NULL);
> - =A0 =A0 =A0 if (irq !=3D NO_IRQ)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->irq[id] =3D irq;
> -}
> -
> =A0static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 const struct of_device_id *match)
> =A0{
> - =A0 =A0 =A0 struct device_node *np =3D NULL;
> =A0 =A0 =A0 =A0struct mii_bus *new_bus;
> =A0 =A0 =A0 =A0struct bb_info *bitbang;
> =A0 =A0 =A0 =A0int ret =3D -ENOMEM;
> - =A0 =A0 =A0 int i;
>
> =A0 =A0 =A0 =A0bitbang =3D kzalloc(sizeof(struct bb_info), GFP_KERNEL=
);
> =A0 =A0 =A0 =A0if (!bitbang)
> @@ -196,17 +178,10 @@ static int __devinit fs_enet_mdio_probe(struct =
of_device *ofdev,
> =A0 =A0 =A0 =A0if (!new_bus->irq)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unmap_regs;
>
> - =A0 =A0 =A0 for (i =3D 0; i < PHY_MAX_ADDR; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus->irq[i] =3D -1;
> -
> - =A0 =A0 =A0 while ((np =3D of_get_next_child(ofdev->node, np)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(np->type, "ethernet-phy"))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_phy(new_bus, np);
> -
> =A0 =A0 =A0 =A0new_bus->parent =3D &ofdev->dev;
> =A0 =A0 =A0 =A0dev_set_drvdata(&ofdev->dev, new_bus);
>
> - =A0 =A0 =A0 ret =3D mdiobus_register(new_bus);
> + =A0 =A0 =A0 ret =3D of_mdiobus_register(new_bus, ofdev->node);
> =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_irqs;
>
> diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-=
fec.c
> index 28077cc..bdc3160 100644
> --- a/drivers/net/fs_enet/mii-fec.c
> +++ b/drivers/net/fs_enet/mii-fec.c
> @@ -102,23 +102,6 @@ static int fs_enet_fec_mii_reset(struct mii_bus =
*bus)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static void __devinit add_phy(struct mii_bus *bus, struct device_nod=
e *np)
> -{
> - =A0 =A0 =A0 const u32 *data;
> - =A0 =A0 =A0 int len, id, irq;
> -
> - =A0 =A0 =A0 data =3D of_get_property(np, "reg", &len);
> - =A0 =A0 =A0 if (!data || len !=3D 4)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 id =3D *data;
> - =A0 =A0 =A0 bus->phy_mask &=3D ~(1 << id);
> -
> - =A0 =A0 =A0 irq =3D of_irq_to_resource(np, 0, NULL);
> - =A0 =A0 =A0 if (irq !=3D NO_IRQ)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->irq[id] =3D irq;
> -}
> -
> =A0static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 const struct of_device_id *match)
> =A0{
> @@ -165,17 +148,10 @@ static int __devinit fs_enet_mdio_probe(struct =
of_device *ofdev,
> =A0 =A0 =A0 =A0if (!new_bus->irq)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unmap_regs;
>
> - =A0 =A0 =A0 for (i =3D 0; i < PHY_MAX_ADDR; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus->irq[i] =3D -1;
> -
> - =A0 =A0 =A0 while ((np =3D of_get_next_child(ofdev->node, np)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(np->type, "ethernet-phy"))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_phy(new_bus, np);
> -
> =A0 =A0 =A0 =A0new_bus->parent =3D &ofdev->dev;
> =A0 =A0 =A0 =A0dev_set_drvdata(&ofdev->dev, new_bus);
>
> - =A0 =A0 =A0 ret =3D mdiobus_register(new_bus);
> + =A0 =A0 =A0 ret =3D of_mdiobus_register(new_bus, ofdev->node);
> =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_irqs;
>
> diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
> index 8300cab..51b7934 100644
> --- a/include/linux/fs_enet_pd.h
> +++ b/include/linux/fs_enet_pd.h
> @@ -17,6 +17,7 @@
> =A0#define FS_ENET_PD_H
>
> =A0#include <linux/string.h>
> +#include <linux/of_mdio.h>
> =A0#include <asm/types.h>
>
> =A0#define FS_ENET_NAME =A0 "fs_enet"
> @@ -130,10 +131,7 @@ struct fs_platform_info {
>
> =A0 =A0 =A0 =A0u32 device_flags;
>
> - =A0 =A0 =A0 int phy_addr; =A0 =A0 =A0 =A0 =A0 /* the phy address (-=
1 no phy) */
> - =A0 =A0 =A0 char bus_id[16];
> - =A0 =A0 =A0 int phy_irq; =A0 =A0 =A0 =A0 =A0 =A0/* the phy irq (if =
it exists) =A0*/
> -
> + =A0 =A0 =A0 struct device_node *phy_node;
> =A0 =A0 =A0 =A0const struct fs_mii_bus_info *bus_info;
>
> =A0 =A0 =A0 =A0int rx_ring, tx_ring; =A0 /* number of buffers on rx =A0=
 =A0 */
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
