From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 5/9] net: make mpc5200 fec driver use of_mdio
	infrastructure
Date: Wed, 18 Mar 2009 23:06:48 -0600
Message-ID: <fa686aa40903182206s583f0896v32813718da9d82cf@mail.gmail.com>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
	 <20090319050038.11320.71538.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:9449 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328AbZCSFGv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:06:51 -0400
Received: by yx-out-2324.google.com with SMTP id 31so394125yxl.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:06:49 -0700 (PDT)
In-Reply-To: <20090319050038.11320.71538.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC, please don't apply yet.

On Wed, Mar 18, 2009 at 11:00 PM, Grant Likely
<grant.likely@secretlab.ca> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
>
> The patch reworks the MPC5200 Fast Ethernet Controller (FEC) driver t=
o
> use the of_mdio infrastructure for registering PHY devices from data =
out
> openfirmware device tree, and eliminates the assumption that the PHY
> for the FEC is always attached to the FEC's own MDIO bus. =A0With thi=
s
> patch, the FEC can use a PHY attached to any MDIO bus if it is descri=
bed
> in the device tree.
> ---
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 | =A0 =A02
> =A0drivers/net/fec_mpc52xx.c =A0 =A0 | =A0175 +++++++++++------------=
------------------
> =A0drivers/net/fec_mpc52xx_phy.c | =A0 26 +-----
> =A03 files changed, 53 insertions(+), 150 deletions(-)
>
>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index a2f185f..3aa24f6 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1854,7 +1854,7 @@ config FEC_MPC52xx
>
> =A0config FEC_MPC52xx_MDIO
> =A0 =A0 =A0 =A0bool "MPC52xx FEC MDIO bus driver"
> - =A0 =A0 =A0 depends on FEC_MPC52xx
> + =A0 =A0 =A0 depends on FEC_MPC52xx && OF_MDIO
> =A0 =A0 =A0 =A0default y
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0The MPC5200's FEC can connect to the Ethernet eith=
er with
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index 3d55f9a..12ab8ae 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -25,6 +25,7 @@
> =A0#include <linux/hardirq.h>
> =A0#include <linux/delay.h>
> =A0#include <linux/of_device.h>
> +#include <linux/of_mdio.h>
> =A0#include <linux/of_platform.h>
>
> =A0#include <linux/netdevice.h>
> @@ -43,11 +44,9 @@
>
> =A0#define DRIVER_NAME "mpc52xx-fec"
>
> -#define FEC5200_PHYADDR_NONE =A0 (-1)
> -#define FEC5200_PHYADDR_7WIRE =A0(-2)
> -
> =A0/* Private driver data structure */
> =A0struct mpc52xx_fec_priv {
> + =A0 =A0 =A0 struct net_device *ndev;
> =A0 =A0 =A0 =A0int duplex;
> =A0 =A0 =A0 =A0int speed;
> =A0 =A0 =A0 =A0int r_irq;
> @@ -59,10 +58,11 @@ struct mpc52xx_fec_priv {
> =A0 =A0 =A0 =A0int msg_enable;
>
> =A0 =A0 =A0 =A0/* MDIO link details */
> - =A0 =A0 =A0 int phy_addr;
> - =A0 =A0 =A0 unsigned int phy_speed;
> + =A0 =A0 =A0 unsigned int mdio_speed;
> + =A0 =A0 =A0 struct device_node *phy_node;
> =A0 =A0 =A0 =A0struct phy_device *phydev;
> =A0 =A0 =A0 =A0enum phy_state link;
> + =A0 =A0 =A0 int seven_wire_mode;
> =A0};
>
>
> @@ -210,66 +210,6 @@ static void mpc52xx_fec_adjust_link(struct net_d=
evice *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_print_status(phydev);
> =A0}
>
> -static int mpc52xx_fec_init_phy(struct net_device *dev)
> -{
> - =A0 =A0 =A0 struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
> - =A0 =A0 =A0 struct phy_device *phydev;
> - =A0 =A0 =A0 char phy_id[BUS_ID_SIZE];
> -
> - =A0 =A0 =A0 snprintf(phy_id, sizeof(phy_id), "%x:%02x",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned int)dev->base=
_addr, priv->phy_addr);
> -
> - =A0 =A0 =A0 priv->link =3D PHY_DOWN;
> - =A0 =A0 =A0 priv->speed =3D 0;
> - =A0 =A0 =A0 priv->duplex =3D -1;
> -
> - =A0 =A0 =A0 phydev =3D phy_connect(dev, phy_id, &mpc52xx_fec_adjust=
_link, 0, PHY_INTERFACE_MODE_MII);
> - =A0 =A0 =A0 if (IS_ERR(phydev)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "phy_connect failed\=
n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(phydev);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 dev_info(&dev->dev, "attached phy %i to driver %s\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev->addr, phydev->d=
rv->name);
> -
> - =A0 =A0 =A0 priv->phydev =3D phydev;
> -
> - =A0 =A0 =A0 return 0;
> -}
> -
> -static int mpc52xx_fec_phy_start(struct net_device *dev)
> -{
> - =A0 =A0 =A0 struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
> - =A0 =A0 =A0 int err;
> -
> - =A0 =A0 =A0 if (priv->phy_addr < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> -
> - =A0 =A0 =A0 err =3D mpc52xx_fec_init_phy(dev);
> - =A0 =A0 =A0 if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "mpc52xx_fec_init_ph=
y failed\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* reset phy - this also wakes it from PDOWN */
> - =A0 =A0 =A0 phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
> - =A0 =A0 =A0 phy_start(priv->phydev);
> -
> - =A0 =A0 =A0 return 0;
> -}
> -
> -static void mpc52xx_fec_phy_stop(struct net_device *dev)
> -{
> - =A0 =A0 =A0 struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
> -
> - =A0 =A0 =A0 if (!priv->phydev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 phy_disconnect(priv->phydev);
> - =A0 =A0 =A0 /* power down phy */
> - =A0 =A0 =A0 phy_stop(priv->phydev);
> - =A0 =A0 =A0 phy_write(priv->phydev, MII_BMCR, BMCR_PDOWN);
> -}
> -
> =A0static int mpc52xx_fec_phy_mii_ioctl(struct mpc52xx_fec_priv *priv=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mii_ioctl_data *mii_data, int c=
md)
> =A0{
> @@ -279,25 +219,25 @@ static int mpc52xx_fec_phy_mii_ioctl(struct mpc=
52xx_fec_priv *priv,
> =A0 =A0 =A0 =A0return phy_mii_ioctl(priv->phydev, mii_data, cmd);
> =A0}
>
> -static void mpc52xx_fec_phy_hw_init(struct mpc52xx_fec_priv *priv)
> -{
> - =A0 =A0 =A0 struct mpc52xx_fec __iomem *fec =3D priv->fec;
> -
> - =A0 =A0 =A0 if (priv->phydev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 out_be32(&fec->mii_speed, priv->phy_speed);
> -}
> -
> =A0static int mpc52xx_fec_open(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct mpc52xx_fec_priv *priv =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0int err =3D -EBUSY;
>
> + =A0 =A0 =A0 if (priv->phy_node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->phydev =3D of_phy_connect(priv->n=
dev, priv->phy_node,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 mpc52xx_fec_adjust_link, 0, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!priv->phydev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "of_=
phy_connect failed\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_start(priv->phydev);
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0if (request_irq(dev->irq, &mpc52xx_fec_interrupt, IRQF=
_SHARED,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DRIVER_NAME "_ctrl", d=
ev)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&dev->dev, "ctrl interrupt req=
uest failed\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_phy;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (request_irq(priv->r_irq, &mpc52xx_fec_rx_interrupt=
, 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DRIVER_NAME "_rx", dev=
)) {
> @@ -319,10 +259,6 @@ static int mpc52xx_fec_open(struct net_device *d=
ev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto free_irqs;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 err =3D mpc52xx_fec_phy_start(dev);
> - =A0 =A0 =A0 if (err)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_skbs;
> -
> =A0 =A0 =A0 =A0bcom_enable(priv->rx_dmatsk);
> =A0 =A0 =A0 =A0bcom_enable(priv->tx_dmatsk);
>
> @@ -332,16 +268,18 @@ static int mpc52xx_fec_open(struct net_device *=
dev)
>
> =A0 =A0 =A0 =A0return 0;
>
> - free_skbs:
> - =A0 =A0 =A0 mpc52xx_fec_free_rx_buffers(dev, priv->rx_dmatsk);
> -
> =A0free_irqs:
> =A0 =A0 =A0 =A0free_irq(priv->t_irq, dev);
> =A0free_2irqs:
> =A0 =A0 =A0 =A0free_irq(priv->r_irq, dev);
> =A0free_ctrl_irq:
> =A0 =A0 =A0 =A0free_irq(dev->irq, dev);
> - out:
> + free_phy:
> + =A0 =A0 =A0 if (priv->phydev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_stop(priv->phydev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_disconnect(priv->phydev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->phydev =3D NULL;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0return err;
> =A0}
> @@ -360,7 +298,12 @@ static int mpc52xx_fec_close(struct net_device *=
dev)
> =A0 =A0 =A0 =A0free_irq(priv->r_irq, dev);
> =A0 =A0 =A0 =A0free_irq(priv->t_irq, dev);
>
> - =A0 =A0 =A0 mpc52xx_fec_phy_stop(dev);
> + =A0 =A0 =A0 if (priv->phydev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* power down phy */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_stop(priv->phydev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_disconnect(priv->phydev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->phydev =3D NULL;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0return 0;
> =A0}
> @@ -700,7 +643,7 @@ static void mpc52xx_fec_hw_init(struct net_device=
 *dev)
> =A0 =A0 =A0 =A0/* set phy speed.
> =A0 =A0 =A0 =A0 * this can't be done in phy driver, since it needs to=
 be called
> =A0 =A0 =A0 =A0 * before fec stuff (even on resume) */
> - =A0 =A0 =A0 mpc52xx_fec_phy_hw_init(priv);
> + =A0 =A0 =A0 out_be32(&fec->mii_speed, priv->mdio_speed);
> =A0}
>
> =A0/**
> @@ -736,7 +679,7 @@ static void mpc52xx_fec_start(struct net_device *=
dev)
> =A0 =A0 =A0 =A0rcntrl =3D FEC_RX_BUFFER_SIZE << 16; =A0 =A0 =A0/* max=
 frame length */
> =A0 =A0 =A0 =A0rcntrl |=3D FEC_RCNTRL_FCE;
>
> - =A0 =A0 =A0 if (priv->phy_addr !=3D FEC5200_PHYADDR_7WIRE)
> + =A0 =A0 =A0 if (!priv->seven_wire_mode)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcntrl |=3D FEC_RCNTRL_MII_MODE;
>
> =A0 =A0 =A0 =A0if (priv->duplex =3D=3D DUPLEX_FULL)
> @@ -802,8 +745,6 @@ static void mpc52xx_fec_stop(struct net_device *d=
ev)
>
> =A0 =A0 =A0 =A0/* Stop FEC */
> =A0 =A0 =A0 =A0out_be32(&fec->ecntrl, in_be32(&fec->ecntrl) & ~FEC_EC=
NTRL_ETHER_EN);
> -
> - =A0 =A0 =A0 return;
> =A0}
>
> =A0/* reset fec and bestcomm tasks */
> @@ -821,9 +762,11 @@ static void mpc52xx_fec_reset(struct net_device =
*dev)
>
> =A0 =A0 =A0 =A0mpc52xx_fec_hw_init(dev);
>
> - =A0 =A0 =A0 phy_stop(priv->phydev);
> - =A0 =A0 =A0 phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
> - =A0 =A0 =A0 phy_start(priv->phydev);
> + =A0 =A0 =A0 if (priv->phydev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_stop(priv->phydev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_write(priv->phydev, MII_BMCR, BMCR_=
RESET);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_start(priv->phydev);
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0bcom_fec_rx_reset(priv->rx_dmatsk);
> =A0 =A0 =A0 =A0bcom_fec_tx_reset(priv->tx_dmatsk);
> @@ -923,7 +866,6 @@ static const struct net_device_ops mpc52xx_fec_ne=
tdev_ops =3D {
> =A0#endif
> =A0};
>
> -
> =A0static int __devinit
> =A0mpc52xx_fec_probe(struct of_device *op, const struct of_device_id =
*match)
> =A0{
> @@ -931,8 +873,6 @@ mpc52xx_fec_probe(struct of_device *op, const str=
uct of_device_id *match)
> =A0 =A0 =A0 =A0struct net_device *ndev;
> =A0 =A0 =A0 =A0struct mpc52xx_fec_priv *priv =3D NULL;
> =A0 =A0 =A0 =A0struct resource mem;
> - =A0 =A0 =A0 struct device_node *phy_node;
> - =A0 =A0 =A0 const phandle *phy_handle;
> =A0 =A0 =A0 =A0const u32 *prop;
> =A0 =A0 =A0 =A0int prop_size;
>
> @@ -945,6 +885,7 @@ mpc52xx_fec_probe(struct of_device *op, const str=
uct of_device_id *match)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> =A0 =A0 =A0 =A0priv =3D netdev_priv(ndev);
> + =A0 =A0 =A0 priv->ndev =3D ndev;
>
> =A0 =A0 =A0 =A0/* Reserve FEC control zone */
> =A0 =A0 =A0 =A0rv =3D of_address_to_resource(op->node, 0, &mem);
> @@ -968,6 +909,7 @@ mpc52xx_fec_probe(struct of_device *op, const str=
uct of_device_id *match)
> =A0 =A0 =A0 =A0ndev->watchdog_timeo =A0 =A0=3D FEC_WATCHDOG_TIMEOUT;
> =A0 =A0 =A0 =A0ndev->base_addr =A0 =A0 =A0 =A0 =3D mem.start;
> =A0 =A0 =A0 =A0ndev->netdev_ops =3D &mpc52xx_fec_netdev_ops;
> + =A0 =A0 =A0 SET_NETDEV_DEV(ndev, &op->dev);
>
> =A0 =A0 =A0 =A0priv->t_irq =3D priv->r_irq =3D ndev->irq =3D NO_IRQ; =
/* IRQ are free for now */
>
> @@ -1017,14 +959,9 @@ mpc52xx_fec_probe(struct of_device *op, const s=
truct of_device_id *match)
> =A0 =A0 =A0 =A0 */
>
> =A0 =A0 =A0 =A0/* Start with safe defaults for link connection */
> - =A0 =A0 =A0 priv->phy_addr =3D FEC5200_PHYADDR_NONE;
> - =A0 =A0 =A0 priv->speed =3D 100;
> + =A0 =A0 =A0 priv->speed =3D 10;
> =A0 =A0 =A0 =A0priv->duplex =3D DUPLEX_HALF;
> - =A0 =A0 =A0 priv->phy_speed =3D ((mpc52xx_find_ipb_freq(op->node) >=
> 20) / 5) << 1;
> -
> - =A0 =A0 =A0 /* the 7-wire property means don't use MII mode */
> - =A0 =A0 =A0 if (of_find_property(op->node, "fsl,7-wire-mode", NULL)=
)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->phy_addr =3D FEC5200_PHYADDR_7WIR=
E;
> + =A0 =A0 =A0 priv->mdio_speed =3D ((mpc52xx_find_ipb_freq(op->node) =
>> 20) / 5) << 1;
>
> =A0 =A0 =A0 =A0/* The current speed preconfigures the speed of the MI=
I link */
> =A0 =A0 =A0 =A0prop =3D of_get_property(op->node, "current-speed", &p=
rop_size);
> @@ -1033,43 +970,23 @@ mpc52xx_fec_probe(struct of_device *op, const =
struct of_device_id *match)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->duplex =3D prop[1] ? DUPLEX_FULL=
 : DUPLEX_HALF;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* If there is a phy handle, setup link to that phy */
> - =A0 =A0 =A0 phy_handle =3D of_get_property(op->node, "phy-handle", =
&prop_size);
> - =A0 =A0 =A0 if (phy_handle && (prop_size >=3D sizeof(phandle))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_node =3D of_find_node_by_phandle(*p=
hy_handle);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =3D of_get_property(phy_node, "reg=
", &prop_size);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prop && (prop_size >=3D sizeof(u32)=
))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((*prop >=3D 0) && (=
*prop < PHY_MAX_ADDR))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->p=
hy_addr =3D *prop;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(phy_node);
> + =A0 =A0 =A0 /* If there is a phy handle, then get the PHY node */
> + =A0 =A0 =A0 priv->phy_node =3D of_parse_phandle(op->node, "phy-hand=
le", 0);
> +
> + =A0 =A0 =A0 /* the 7-wire property means don't use MII mode */
> + =A0 =A0 =A0 if (of_find_property(op->node, "fsl,7-wire-mode", NULL)=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->seven_wire_mode =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, "using 7-wire PHY =
mode\n");
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Hardware init */
> =A0 =A0 =A0 =A0mpc52xx_fec_hw_init(ndev);
> -
> =A0 =A0 =A0 =A0mpc52xx_fec_reset_stats(ndev);
>
> - =A0 =A0 =A0 SET_NETDEV_DEV(ndev, &op->dev);
> -
> - =A0 =A0 =A0 /* Register the new network device */
> =A0 =A0 =A0 =A0rv =3D register_netdev(ndev);
> =A0 =A0 =A0 =A0if (rv < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto probe_error;
>
> - =A0 =A0 =A0 /* Now report the link setup */
> - =A0 =A0 =A0 switch (priv->phy_addr) {
> - =A0 =A0 =A0 =A0case FEC5200_PHYADDR_NONE:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, "Fixed speed MII l=
ink: %i%cD\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->speed, priv->d=
uplex ? 'F' : 'H');
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0case FEC5200_PHYADDR_7WIRE:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, "using 7-wire PHY =
mode\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, "Using PHY at MDIO=
 address %i\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->phy_addr);
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0/* We're done ! */
> =A0 =A0 =A0 =A0dev_set_drvdata(&op->dev, ndev);
>
> diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_=
phy.c
> index dd9bfa4..fec9f24 100644
> --- a/drivers/net/fec_mpc52xx_phy.c
> +++ b/drivers/net/fec_mpc52xx_phy.c
> @@ -14,12 +14,14 @@
> =A0#include <linux/netdevice.h>
> =A0#include <linux/phy.h>
> =A0#include <linux/of_platform.h>
> +#include <linux/of_mdio.h>
> =A0#include <asm/io.h>
> =A0#include <asm/mpc52xx.h>
> =A0#include "fec_mpc52xx.h"
>
> =A0struct mpc52xx_fec_mdio_priv {
> =A0 =A0 =A0 =A0struct mpc52xx_fec __iomem *regs;
> + =A0 =A0 =A0 int mdio_irqs[PHY_MAX_ADDR];
> =A0};
>
> =A0static int mpc52xx_fec_mdio_transfer(struct mii_bus *bus, int phy_=
id,
> @@ -27,7 +29,7 @@ static int mpc52xx_fec_mdio_transfer(struct mii_bus=
 *bus, int phy_id,
> =A0{
> =A0 =A0 =A0 =A0struct mpc52xx_fec_mdio_priv *priv =3D bus->priv;
> =A0 =A0 =A0 =A0struct mpc52xx_fec __iomem *fec;
> - =A0 =A0 =A0 int tries =3D 100;
> + =A0 =A0 =A0 int tries =3D 3;
>
> =A0 =A0 =A0 =A0value |=3D (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII=
_DATA_PA_MSK;
> =A0 =A0 =A0 =A0value |=3D (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DA=
TA_RA_MSK;
> @@ -38,7 +40,7 @@ static int mpc52xx_fec_mdio_transfer(struct mii_bus=
 *bus, int phy_id,
>
> =A0 =A0 =A0 =A0/* wait for it to finish, this takes about 23 us on li=
te5200b */
> =A0 =A0 =A0 =A0while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --=
tries)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(5);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 msleep(1);
>
> =A0 =A0 =A0 =A0if (!tries)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ETIMEDOUT;
> @@ -64,7 +66,6 @@ static int mpc52xx_fec_mdio_probe(struct of_device =
*of,
> =A0{
> =A0 =A0 =A0 =A0struct device *dev =3D &of->dev;
> =A0 =A0 =A0 =A0struct device_node *np =3D of->node;
> - =A0 =A0 =A0 struct device_node *child =3D NULL;
> =A0 =A0 =A0 =A0struct mii_bus *bus;
> =A0 =A0 =A0 =A0struct mpc52xx_fec_mdio_priv *priv;
> =A0 =A0 =A0 =A0struct resource res =3D {};
> @@ -85,22 +86,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device=
 *of,
> =A0 =A0 =A0 =A0bus->write =3D mpc52xx_fec_mdio_write;
>
> =A0 =A0 =A0 =A0/* setup irqs */
> - =A0 =A0 =A0 bus->irq =3D kmalloc(sizeof(bus->irq[0]) * PHY_MAX_ADDR=
, GFP_KERNEL);
> - =A0 =A0 =A0 if (bus->irq =3D=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOMEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 for (i=3D0; i<PHY_MAX_ADDR; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->irq[i] =3D PHY_POLL;
> -
> - =A0 =A0 =A0 while ((child =3D of_get_next_child(np, child)) !=3D NU=
LL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int irq =3D irq_of_parse_and_map(child,=
 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (irq !=3D NO_IRQ) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const u32 *id =3D of_ge=
t_property(child, "reg", NULL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (id)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->ir=
q[*id] =3D irq;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 bus->irq =3D priv->mdio_irqs;
>
> =A0 =A0 =A0 =A0/* setup registers */
> =A0 =A0 =A0 =A0err =3D of_address_to_resource(np, 0, &res);
> @@ -122,7 +108,7 @@ static int mpc52xx_fec_mdio_probe(struct of_devic=
e *of,
> =A0 =A0 =A0 =A0out_be32(&priv->regs->mii_speed,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((mpc52xx_find_ipb_freq(of->node) >> 2=
0) / 5) << 1);
>
> - =A0 =A0 =A0 err =3D mdiobus_register(bus);
> + =A0 =A0 =A0 err =3D of_mdiobus_register(bus, np);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unmap;
>
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
