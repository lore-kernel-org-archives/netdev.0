From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net: emaclite: adding MDIO and phy lib support
Date: Thu, 4 Feb 2010 11:12:29 -0700
Message-ID: <fa686aa41002041012ibee0975p6f510831f5d67314@mail.gmail.com>
References: <00044664-e9db-419f-88bd-4de21af118b6@VA3EHSMHS001.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f224.google.com ([209.85.217.224]:49516 "EHLO
	mail-gx0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756746Ab0BDSMu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 13:12:50 -0500
Received: by gxk24 with SMTP id 24so3789023gxk.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2010 10:12:49 -0800 (PST)
In-Reply-To: <00044664-e9db-419f-88bd-4de21af118b6@VA3EHSMHS001.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John and Sadanand.  Looks like a good patch, but a few issues to
resolve.  Comments below.

g.

On Wed, Feb 3, 2010 at 5:49 PM, John Linn <john.linn@xilinx.com> wrote:
> These changes add MDIO and phy lib support to the driver as the
> IP core now supports the MDIO bus.
>
> The MDIO bus and phy are added as a child to the emaclite in the devi=
ce
> tree as illustrated below.
>
> mdio {
> =A0 =A0 =A0 =A0#address-cells =3D <1>;
> =A0 =A0 =A0 =A0#size-cells =3D <0>;
> =A0 =A0 =A0 =A0phy0: phy@7 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <7>;

=46or completeness, phy node need a "compatible" property.

> =A0 =A0 =A0 =A0} ;
> }
>
> Signed-off-by: Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
> Signed-off-by: John Linn <john.linn@xilinx.com>
> ---
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/xilinx_emaclite.c | =A0362 +++++++++++++++++++++++++++=
+++++++++-----
> =A02 files changed, 319 insertions(+), 44 deletions(-)
>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 396fd38..2056cd2 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1947,6 +1947,7 @@ config ATL2
> =A0config XILINX_EMACLITE
> =A0 =A0 =A0 =A0tristate "Xilinx 10/100 Ethernet Lite support"
> =A0 =A0 =A0 =A0depends on PPC32 || MICROBLAZE
> + =A0 =A0 =A0 select PHYLIB
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0This driver supports the 10/100 Ethernet Lite from=
 Xilinx.
>

Patch appears to be whitespace damaged.  All tabs have been converted t=
o spaces.

> diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emacl=
ite.c
> index 83a044d..8c7d7ae 100644
> --- a/drivers/net/xilinx_emaclite.c
> +++ b/drivers/net/xilinx_emaclite.c
> @@ -22,11 +22,17 @@
>
> =A0#include <linux/of_device.h>
> =A0#include <linux/of_platform.h>
> +#include <linux/of_mdio.h>
> +#include <linux/phy.h>
>
> =A0#define DRIVER_NAME "xilinx_emaclite"
>
> =A0/* Register offsets for the EmacLite Core */
> =A0#define XEL_TXBUFF_OFFSET =A0 =A0 =A00x0 =A0 =A0 =A0 =A0 =A0 =A0 /=
* Transmit Buffer */
> +#define XEL_MDIOADDR_OFFSET =A0 =A00x07E4 =A0 =A0 =A0 =A0 =A0/* MDIO=
 Address Register */
> +#define XEL_MDIOWR_OFFSET =A0 =A0 =A00x07E8 =A0 =A0 =A0 =A0 =A0/* MD=
IO Write Data Register */
> +#define XEL_MDIORD_OFFSET =A0 =A0 =A00x07EC =A0 =A0 =A0 =A0 =A0/* MD=
IO Read Data Register */
> +#define XEL_MDIOCTRL_OFFSET =A0 =A00x07F0 =A0 =A0 =A0 =A0 =A0/* MDIO=
 Control Register */
> =A0#define XEL_GIER_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x07F8 =A0 =
=A0 =A0 =A0 =A0/* GIE Register */
> =A0#define XEL_TSR_OFFSET =A0 =A0 =A0 =A0 0x07FC =A0 =A0 =A0 =A0 =A0/=
* Tx status */
> =A0#define XEL_TPLR_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x07F4 =A0 =
=A0 =A0 =A0 =A0/* Tx packet length */
> @@ -37,6 +43,22 @@
>
> =A0#define XEL_BUFFER_OFFSET =A0 =A0 =A00x0800 =A0 =A0 =A0 =A0 =A0/* =
Next Tx/Rx buffer's offset */
>
> +/* MDIO Address Register Bit Masks */
> +#define XEL_MDIOADDR_REGADR_MASK =A00x0000001F =A0 /* Register Addre=
ss */
> +#define XEL_MDIOADDR_PHYADR_MASK =A00x000003E0 =A0 /* PHY Address */
> +#define XEL_MDIOADDR_PHYADR_SHIFT 5
> +#define XEL_MDIOADDR_OP_MASK =A0 =A0 0x00000400 =A0 =A0/* RD/WR Oper=
ation */
> +
> +/* MDIO Write Data Register Bit Masks */
> +#define XEL_MDIOWR_WRDATA_MASK =A0 0x0000FFFF =A0 =A0/* Data to be W=
ritten */
> +
> +/* MDIO Read Data Register Bit Masks */
> +#define XEL_MDIORD_RDDATA_MASK =A0 0x0000FFFF =A0 =A0/* Data to be R=
ead */
> +
> +/* MDIO Control Register Bit Masks */
> +#define XEL_MDIOCTRL_MDIOSTS_MASK 0x00000001 =A0 /* MDIO Status Mask=
 */
> +#define XEL_MDIOCTRL_MDIOEN_MASK =A00x00000008 =A0 /* MDIO Enable */
> +
> =A0/* Global Interrupt Enable Register (GIER) Bit Masks */
> =A0#define XEL_GIER_GIE_MASK =A0 =A0 =A00x80000000 =A0 =A0 =A0/* Glob=
al Enable */
>
> @@ -87,6 +109,12 @@
> =A0* @reset_lock: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lock used for synchr=
onization
> =A0* @deferred_skb: =A0 =A0 =A0holds an skb (for transmission at a la=
ter time) when the
> =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Tx buffer is not free
> + * @phy_dev: =A0 =A0 =A0 =A0 =A0 pointer to the PHY device
> + * @phy_node: =A0 =A0 =A0 =A0 =A0pointer to the PHY device node
> + * @mii_bus: =A0 =A0 =A0 =A0 =A0 pointer to the MII bus
> + * @mdio_irqs: =A0 =A0 =A0 =A0 IRQs table for MDIO bus
> + * @last_link: =A0 =A0 =A0 =A0 last link status
> + * @has_mdio: =A0 =A0 =A0 =A0 =A0indicates whether MDIO is included =
in the HW
> =A0*/
> =A0struct net_local {
>
> @@ -100,6 +128,15 @@ struct net_local {
>
> =A0 =A0 =A0 =A0spinlock_t reset_lock;
> =A0 =A0 =A0 =A0struct sk_buff *deferred_skb;
> +
> + =A0 =A0 =A0 struct phy_device *phy_dev;
> + =A0 =A0 =A0 struct device_node *phy_node;
> +
> + =A0 =A0 =A0 struct mii_bus *mii_bus;
> + =A0 =A0 =A0 int mdio_irqs[PHY_MAX_ADDR];
> +
> + =A0 =A0 =A0 int last_link;
> + =A0 =A0 =A0 bool has_mdio;
> =A0};
>
>
> @@ -431,7 +468,7 @@ static u16 xemaclite_recv_data(struct net_local *=
drvdata, u8 *data)
> =A0}
>
> =A0/**
> - * xemaclite_set_mac_address - Set the MAC address for this device
> + * xemaclite_update_address - Update the MAC address in the device
> =A0* @drvdata: =A0 Pointer to the Emaclite device private data
> =A0* @address_ptr:Pointer to the MAC address (MAC address is a 48-bit=
 value)
> =A0*
> @@ -441,8 +478,8 @@ static u16 xemaclite_recv_data(struct net_local *=
drvdata, u8 *data)
> =A0* The MAC address can be programmed using any of the two transmit
> =A0* buffers (if configured).
> =A0*/
> -static void xemaclite_set_mac_address(struct net_local *drvdata,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 u8 *address_ptr)
> +static void xemaclite_update_address(struct net_local *drvdata,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0u8 *address_ptr)
> =A0{
> =A0 =A0 =A0 =A0void __iomem *addr;
> =A0 =A0 =A0 =A0u32 reg_data;
> @@ -465,6 +502,30 @@ static void xemaclite_set_mac_address(struct net=
_local *drvdata,
> =A0}
>
> =A0/**
> + * xemaclite_set_mac_address - Set the MAC address for this device
> + * @dev: =A0 =A0 =A0 Pointer to the network device instance
> + * @addr: =A0 =A0 =A0Void pointer to the sockaddr structure
> + *
> + * This function copies the HW address from the sockaddr strucutre t=
o the
> + * net_device structure and updates the address in HW.
> + *
> + * Return: =A0 =A0 Error if the net device is busy or 0 if the addr =
is set
> + * =A0 =A0 =A0 =A0 =A0 =A0 successfully
> + */
> +static int xemaclite_set_mac_address(struct net_device *dev, void *a=
ddress)
> +{
> + =A0 =A0 =A0 struct net_local *lp =3D (struct net_local *) netdev_pr=
iv(dev);
> + =A0 =A0 =A0 struct sockaddr *addr =3D address;
> +
> + =A0 =A0 =A0 if (netif_running(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> +
> + =A0 =A0 =A0 memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
> + =A0 =A0 =A0 xemaclite_update_address(lp, dev->dev_addr);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/**
> =A0* xemaclite_tx_timeout - Callback for Tx Timeout
> =A0* @dev: =A0 =A0 =A0 Pointer to the network device
> =A0*
> @@ -641,12 +702,195 @@ static irqreturn_t xemaclite_interrupt(int irq=
, void *dev_id)
> =A0 =A0 =A0 =A0return IRQ_HANDLED;
> =A0}
>
> +/**********************/
> +/* MDIO Bus functions */
> +/**********************/
> +/**
> + * xemaclite_mdio_read - Read from a given MII management register
> + * @bus: =A0 =A0 =A0 the mii_bus struct
> + * @phy_id: =A0 =A0the phy address
> + * @reg: =A0 =A0 =A0 register number to read from
> + *
> + * This function waits till the device is ready to accept a new MDIO
> + * request and then writes the phy address to the MDIO Address regis=
ter
> + * and reads data from MDIO Read Data register, when its available.
> + *
> + * Return: =A0 =A0 Value read from the MII management register
> + */
> +static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int =
reg)
> +{
> + =A0 =A0 =A0 struct net_local *lp =3D bus->priv;
> + =A0 =A0 =A0 u32 ctrl_reg;
> + =A0 =A0 =A0 u32 rc;
> +
> + =A0 =A0 =A0 /* Wait till the device is ready */
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctrl_reg =3D in_be32(lp->base_addr + XE=
L_MDIOCTRL_OFFSET);
> + =A0 =A0 =A0 } while (ctrl_reg & XEL_MDIOCTRL_MDIOSTS_MASK);

This is a busywait loop that just burns cycles while waiting for the
MDIO bus to become non-busy, and further down...

> +
> + =A0 =A0 =A0 /* Write the PHY address, register number and set the O=
P bit in the
> + =A0 =A0 =A0 =A0* MDIO Address register. Set the Status bit in the M=
DIO Control
> + =A0 =A0 =A0 =A0* register to start a MDIO read transaction.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XEL_MDIOADDR_OP_MASK |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((phy_id << XEL_MDIOADDR_PHYADR_SHIF=
T) | reg));
> + =A0 =A0 =A0 out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK=
);
> +
> + =A0 =A0 =A0 /* Wait for the device to complete the transaction and =
read the value
> + =A0 =A0 =A0 =A0* from MDIO Read Data register.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctrl_reg =3D in_be32(lp->base_addr + XE=
L_MDIOCTRL_OFFSET);
> + =A0 =A0 =A0 } while (ctrl_reg & XEL_MDIOCTRL_MDIOSTS_MASK);

=2E.. I see the same thing waiting for the issued transaction to
complete.  Busywaiting on slow events, like MDIO transfers, wastes a
lot of cycles that could be used for running other threads.

At the very least, the wait loop should msleep() so that other threads
get scheduled.  Even better is if a completion is used and the MDIO
irq can be used to wake up the thread.

Another problem with this busywait is that is has no failure path if
the MDIO bus hangs up.  The thread could get stuck spinning on this
loop forever with no way to kill it.

> + =A0 =A0 =A0 rc =3D in_be32(lp->base_addr + XEL_MDIORD_OFFSET);
> +
> + =A0 =A0 =A0 dev_dbg(&lp->ndev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "xemaclite_mdio_read(phy_id=3D%i, reg=3D=
%x) =3D=3D %x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_id, reg, rc);
> +
> + =A0 =A0 =A0 return rc;
> +}
> +
> +/**
> + * xemaclite_mdio_write - Write to a given MII management register
> + * @bus: =A0 =A0 =A0 the mii_bus struct
> + * @phy_id: =A0 =A0the phy address
> + * @reg: =A0 =A0 =A0 register number to write to
> + * @val: =A0 =A0 =A0 value to write to the register number specified=
 by reg
> + *
> + * This fucntion waits till the device is ready to accept a new MDIO
> + * request and then writes the val to the MDIO Write Data register.
> + */
> +static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int=
 reg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 val=
)
> +{
> + =A0 =A0 =A0 struct net_local *lp =3D bus->priv;
> + =A0 =A0 =A0 u32 ctrl_reg;
> +
> + =A0 =A0 =A0 dev_dbg(&lp->ndev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "xemaclite_mdio_write(phy_id=3D%i, reg=3D=
%x, val=3D%x)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_id, reg, val);
> +
> + =A0 =A0 =A0 /* Wait till the device is ready */
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctrl_reg =3D in_be32(lp->base_addr + XE=
L_MDIOCTRL_OFFSET);
> + =A0 =A0 =A0 } while (ctrl_reg & XEL_MDIOCTRL_MDIOSTS_MASK);

Ditto here.  In fact, this is a common pattern used 4 times in this
patch.  Probably a candidate to break out into a subroutine.

> +
> + =A0 =A0 =A0 /* Write the PHY address, register number and clear the=
 OP bit in the
> + =A0 =A0 =A0 =A0* MDIO Address register and then write the value int=
o the MDIO Write
> + =A0 =A0 =A0 =A0* Data register. Finally, set the Status bit in the =
MDIO Control
> + =A0 =A0 =A0 =A0* register to start a MDIO write transaction.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0~XEL_MDIOADDR_OP_MASK &
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((phy_id << XEL_MDIOADDR_PHYADR_SHIF=
T) | reg));
> + =A0 =A0 =A0 out_be32(lp->base_addr + XEL_MDIOWR_OFFSET, val);
> + =A0 =A0 =A0 out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK=
);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/**
> + * xemaclite_mdio_reset - Reset the mdio bus.
> + * @bus: =A0 =A0 =A0 Pointer to the MII bus
> + *
> + * This function is required(?) as per Documentation/networking/phy.=
txt.
> + * There is no reset in this device; this function always returns 0.
> + */
> +static int xemaclite_mdio_reset(struct mii_bus *bus)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/**
> + * xemaclite_mdio_setup - Register mii_bus for the Emaclite device
> + * @lp: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Pointer to the Emaclite devic=
e private data
> + * @ofdev: =A0 =A0 Pointer to OF device structure
> + *
> + * This function enables MDIO bus in the Emaclite device and registe=
rs a
> + * mii_bus.
> + *
> + * Return: =A0 =A0 0 upon success or a negative error upon failure
> + */
> +static int xemaclite_mdio_setup(struct net_local *lp, struct device =
*dev)
> +{
> + =A0 =A0 =A0 struct mii_bus *bus;
> + =A0 =A0 =A0 int rc;
> + =A0 =A0 =A0 struct resource res;
> + =A0 =A0 =A0 struct device_node *np =3D of_get_parent(lp->phy_node);
> +
> + =A0 =A0 =A0 /* Don't register the MDIO bus if the phy_node or its p=
arent node
> + =A0 =A0 =A0 =A0* can't be found.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!np)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> +
> + =A0 =A0 =A0 /* Enable the MDIO bus by asserting the enable bit in M=
DIO Control
> + =A0 =A0 =A0 =A0* register.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XEL_MDIOCTRL_MDIOEN_MASK);
> +
> + =A0 =A0 =A0 bus =3D mdiobus_alloc();
> + =A0 =A0 =A0 if (!bus)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 of_address_to_resource(np, 0, &res);
> + =A0 =A0 =A0 snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long long)res.start);
> + =A0 =A0 =A0 bus->priv =3D lp;
> + =A0 =A0 =A0 bus->name =3D "Xilinx Emaclite MDIO";
> + =A0 =A0 =A0 bus->read =3D xemaclite_mdio_read;
> + =A0 =A0 =A0 bus->write =3D xemaclite_mdio_write;
> + =A0 =A0 =A0 bus->reset =3D xemaclite_mdio_reset;
> + =A0 =A0 =A0 bus->parent =3D dev;
> + =A0 =A0 =A0 bus->irq =3D lp->mdio_irqs; /* preallocated IRQ table *=
/
> +
> + =A0 =A0 =A0 lp->mii_bus =3D bus;
> +
> + =A0 =A0 =A0 rc =3D of_mdiobus_register(bus, np);
> + =A0 =A0 =A0 if (rc)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_register;
> +
> + =A0 =A0 =A0 return 0;
> +
> +err_register:
> + =A0 =A0 =A0 mdiobus_free(bus);
> + =A0 =A0 =A0 return rc;
> +}
> +
> +/**
> + * xemaclite_adjust_link - Link state callback for the Emaclite devi=
ce
> + * @ndev: pointer to net_device struct
> + *
> + * There's nothing in the Emaclite device to be configured when the =
link
> + * state changes. We just print the status.
> + */
> +void xemaclite_adjust_link(struct net_device *ndev)
> +{
> + =A0 =A0 =A0 struct net_local *lp =3D netdev_priv(ndev);
> + =A0 =A0 =A0 struct phy_device *phy =3D lp->phy_dev;
> + =A0 =A0 =A0 int link_state;
> +
> + =A0 =A0 =A0 /* hash together the state values to decide if somethin=
g has changed */
> + =A0 =A0 =A0 link_state =3D phy->speed | (phy->duplex << 1) | phy->l=
ink;
> +
> + =A0 =A0 =A0 if (lp->last_link !=3D link_state) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->last_link =3D link_state;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_print_status(phy);
> + =A0 =A0 =A0 }
> +}
> +
> =A0/**
> =A0* xemaclite_open - Open the network device
> =A0* @dev: =A0 =A0 =A0 Pointer to the network device
> =A0*
> =A0* This function sets the MAC address, requests an IRQ and enables =
interrupts
> =A0* for the Emaclite device and starts the Tx queue.
> + * It also connects to the phy device, if MDIO is included in Emacli=
te device.
> =A0*/
> =A0static int xemaclite_open(struct net_device *dev)
> =A0{
> @@ -656,14 +900,50 @@ static int xemaclite_open(struct net_device *de=
v)
> =A0 =A0 =A0 =A0/* Just to be safe, stop the device first */
> =A0 =A0 =A0 =A0xemaclite_disable_interrupts(lp);
>
> + =A0 =A0 =A0 if (lp->phy_node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 bmcr;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev =3D of_phy_connect(lp->ndev=
, lp->phy_node,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0xemaclite_adjust_link, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_MII);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lp->phy_dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&lp->ndev->dev,=
 "of_phy_connect() failed\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* EmacLite doesn't support giga-bit sp=
eeds */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev->supported &=3D (PHY_BASIC_=
=46EATURES);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev->advertising =3D lp->phy_de=
v->supported;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Don't advertise 1000BASE-T Full/Half=
 duplex speeds */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xemaclite_mdio_write(lp->mii_bus, lp->p=
hy_dev->addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0MII_CTRL1000, 0x00);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Advertise only 10 and 100mbps full/h=
alf duplex speeds */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xemaclite_mdio_write(lp->mii_bus, lp->p=
hy_dev->addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0MII_ADVERTISE, ADVERTISE_ALL);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Restart auto negotiation */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bmcr =3D xemaclite_mdio_read(lp->mii_bu=
s,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0lp->phy_dev->addr, MII_BMCR);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bmcr |=3D (BMCR_ANENABLE | BMCR_ANRESTA=
RT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xemaclite_mdio_write(lp->mii_bus, lp->p=
hy_dev->addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0MII_BMCR, bmcr);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_start(lp->phy_dev);
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* Set the MAC address each time opened */
> - =A0 =A0 =A0 xemaclite_set_mac_address(lp, dev->dev_addr);
> + =A0 =A0 =A0 xemaclite_update_address(lp, dev->dev_addr);
>
> =A0 =A0 =A0 =A0/* Grab the IRQ */
> =A0 =A0 =A0 =A0retval =3D request_irq(dev->irq, xemaclite_interrupt, =
0, dev->name, dev);
> =A0 =A0 =A0 =A0if (retval) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&lp->ndev->dev, "Could not all=
ocate interrupt %d\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->irq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lp->phy_dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_disconnect(lp->phy_=
dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev =3D NULL;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return retval;
> =A0 =A0 =A0 =A0}
>
> @@ -682,6 +962,7 @@ static int xemaclite_open(struct net_device *dev)
> =A0*
> =A0* This function stops the Tx queue, disables interrupts and frees =
the IRQ for
> =A0* the Emaclite device.
> + * It also disconnects the phy device associated with the Emaclite d=
evice.
> =A0*/
> =A0static int xemaclite_close(struct net_device *dev)
> =A0{
> @@ -691,6 +972,10 @@ static int xemaclite_close(struct net_device *de=
v)
> =A0 =A0 =A0 =A0xemaclite_disable_interrupts(lp);
> =A0 =A0 =A0 =A0free_irq(dev->irq, dev);
>
> + =A0 =A0 =A0 if (lp->phy_dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_disconnect(lp->phy_dev);
> + =A0 =A0 =A0 lp->phy_dev =3D NULL;
> +
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -754,42 +1039,6 @@ static int xemaclite_send(struct sk_buff *orig_=
skb, struct net_device *dev)
> =A0}
>
> =A0/**
> - * xemaclite_ioctl - Perform IO Control operations on the network de=
vice
> - * @dev: =A0 =A0 =A0 Pointer to the network device
> - * @rq: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Pointer to the interface requ=
est structure
> - * @cmd: =A0 =A0 =A0 IOCTL command
> - *
> - * The only IOCTL operation supported by this function is setting th=
e MAC
> - * address. An error is reported if any other operations are request=
ed.
> - *
> - * Return: =A0 =A0 0 to indicate success, or a negative error for fa=
ilure.
> - */
> -static int xemaclite_ioctl(struct net_device *dev, struct ifreq *rq,=
 int cmd)
> -{
> - =A0 =A0 =A0 struct net_local *lp =3D (struct net_local *) netdev_pr=
iv(dev);
> - =A0 =A0 =A0 struct hw_addr_data *hw_addr =3D (struct hw_addr_data *=
) &rq->ifr_hwaddr;
> -
> - =A0 =A0 =A0 switch (cmd) {
> - =A0 =A0 =A0 case SIOCETHTOOL:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EIO;
> -
> - =A0 =A0 =A0 case SIOCSIFHWADDR:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&lp->ndev->dev, "SIOCSIFHWADDR\=
n");
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Copy MAC address in from user space =
*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 copy_from_user((void __force *) dev->de=
v_addr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(void __=
user __force *) hw_addr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IFHWADDR=
LEN);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 xemaclite_set_mac_address(lp, dev->dev_=
addr);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 return 0;
> -}
> -
> -/**
> =A0* xemaclite_remove_ndev - Free the network device
> =A0* @ndev: =A0 =A0 =A0Pointer to the network device to be freed
> =A0*
> @@ -840,6 +1089,8 @@ static struct net_device_ops xemaclite_netdev_op=
s;
> =A0* This function probes for the Emaclite device in the device tree.
> =A0* It initializes the driver data structure and the hardware, sets =
the MAC
> =A0* address and registers the network device.
> + * It also registers a mii_bus for the Emaclite device, if MDIO is i=
ncluded
> + * in the device.
> =A0*
> =A0* Return: =A0 =A0 0, if the driver is bound to the Emaclite device=
, or
> =A0* =A0 =A0 =A0 =A0 =A0 =A0 a negative error if there is failure.
> @@ -853,7 +1104,6 @@ static int __devinit xemaclite_of_probe(struct o=
f_device *ofdev,
> =A0 =A0 =A0 =A0struct net_local *lp =3D NULL;
> =A0 =A0 =A0 =A0struct device *dev =3D &ofdev->dev;
> =A0 =A0 =A0 =A0const void *mac_address;
> -

Unrelated whitespace change.

> =A0 =A0 =A0 =A0int rc =3D 0;
>
> =A0 =A0 =A0 =A0dev_info(dev, "Device Tree Probing\n");
> @@ -880,6 +1130,7 @@ static int __devinit xemaclite_of_probe(struct o=
f_device *ofdev,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0dev_set_drvdata(dev, ndev);
> + =A0 =A0 =A0 SET_NETDEV_DEV(ndev, &ofdev->dev);
>
> =A0 =A0 =A0 =A0ndev->irq =3D r_irq.start;
> =A0 =A0 =A0 =A0ndev->mem_start =3D r_mem.start;
> @@ -923,7 +1174,16 @@ static int __devinit xemaclite_of_probe(struct =
of_device *ofdev,
> =A0 =A0 =A0 =A0out_be32(lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_O=
=46FSET, 0);
>
> =A0 =A0 =A0 =A0/* Set the MAC address in the EmacLite device */
> - =A0 =A0 =A0 xemaclite_set_mac_address(lp, ndev->dev_addr);
> + =A0 =A0 =A0 xemaclite_update_address(lp, ndev->dev_addr);
> +
> + =A0 =A0 =A0 /* Check if MDIO is included in the HW */
> + =A0 =A0 =A0 lp->has_mdio =3D get_bool(ofdev, "xlnx,include-mdio");
> + =A0 =A0 =A0 if (lp->has_mdio) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_node =3D of_parse_phandle(ofdev=
->node, "phy-handle", 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D xemaclite_mdio_setup(lp, &ofdev-=
>dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rc)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(&ofdev->dev, "=
error registering MDIO bus\n");
> + =A0 =A0 =A0 }

What if the phy is attached to a different MDIO bus (which is
completely possible)?  The fetching of phy_node should be performed
regardless of whether or not xlnx,include-mdio is set.

>
> =A0 =A0 =A0 =A0dev_info(dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "MAC address is now %2x:%2x:%2x:%2x:%=
2x:%2x\n",
> @@ -972,12 +1232,25 @@ static int __devexit xemaclite_of_remove(struc=
t of_device *of_dev)
> =A0 =A0 =A0 =A0struct device *dev =3D &of_dev->dev;
> =A0 =A0 =A0 =A0struct net_device *ndev =3D dev_get_drvdata(dev);
>
> + =A0 =A0 =A0 struct net_local *lp =3D (struct net_local *) netdev_pr=
iv(ndev);
> +
> + =A0 =A0 =A0 /* Un-register the mii_bus, if configured */
> + =A0 =A0 =A0 if (lp->has_mdio) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdiobus_unregister(lp->mii_bus);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(lp->mii_bus->irq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdiobus_free(lp->mii_bus);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->mii_bus =3D NULL;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0unregister_netdev(ndev);
>
> + =A0 =A0 =A0 if (lp->phy_node)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(lp->phy_node);
> + =A0 =A0 =A0 lp->phy_node =3D NULL;
> +
> =A0 =A0 =A0 =A0release_mem_region(ndev->mem_start, ndev->mem_end-ndev=
->mem_start + 1);
>
> =A0 =A0 =A0 =A0xemaclite_remove_ndev(ndev);
> -
> =A0 =A0 =A0 =A0dev_set_drvdata(dev, NULL);
>
> =A0 =A0 =A0 =A0return 0;
> @@ -987,7 +1260,7 @@ static struct net_device_ops xemaclite_netdev_op=
s =3D {
> =A0 =A0 =A0 =A0.ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D xemaclite_op=
en,
> =A0 =A0 =A0 =A0.ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D xemaclite_cl=
ose,
> =A0 =A0 =A0 =A0.ndo_start_xmit =A0 =A0 =A0 =A0 =3D xemaclite_send,
> - =A0 =A0 =A0 .ndo_do_ioctl =A0 =A0 =A0 =A0 =A0 =3D xemaclite_ioctl,
> + =A0 =A0 =A0 .ndo_set_mac_address =A0 =A0=3D xemaclite_set_mac_addre=
ss,
> =A0 =A0 =A0 =A0.ndo_tx_timeout =A0 =A0 =A0 =A0 =3D xemaclite_tx_timeo=
ut,
> =A0 =A0 =A0 =A0.ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D xemaclite_get_st=
ats,
> =A0};
> @@ -999,6 +1272,7 @@ static struct of_device_id xemaclite_of_match[] =
__devinitdata =3D {
> =A0 =A0 =A0 =A0{ .compatible =3D "xlnx,xps-ethernetlite-1.00.a", },
> =A0 =A0 =A0 =A0{ .compatible =3D "xlnx,xps-ethernetlite-2.00.a", },
> =A0 =A0 =A0 =A0{ .compatible =3D "xlnx,xps-ethernetlite-2.01.a", },
> + =A0 =A0 =A0 { .compatible =3D "xlnx,xps-ethernetlite-3.00.a", },
> =A0 =A0 =A0 =A0{ /* end of list */ },
> =A0};
> =A0MODULE_DEVICE_TABLE(of, xemaclite_of_match);
> --
> 1.6.2.1
>
>
>
> This email and any attachments are intended for the sole use of the n=
amed recipient(s) and contain(s) confidential information that may be p=
roprietary, privileged or copyrighted under applicable law. If you are =
not the intended recipient, do not read, copy, or forward this email me=
ssage or any attachments. Delete this email message and any attachments=
 immediately.
>
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
