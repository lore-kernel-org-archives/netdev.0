From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2 03/13] phylib: rework to prepare for OF registration of
	PHYs
Date: Sat, 28 Mar 2009 10:41:01 -0600
Message-ID: <fa686aa40903280941r2b19f483v3023d8ce0dc45e30@mail.gmail.com>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
	 <20090321222827.20493.18983.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:15216 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbZC1QlE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 12:41:04 -0400
Received: by yx-out-2324.google.com with SMTP id 31so1370880yxl.1
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 09:41:01 -0700 (PDT)
In-Reply-To: <20090321222827.20493.18983.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy, can you please make comment on patch 3, 4 and 5 of this series?
I think they are ready to merge and the driver changes can be applied
any time after the phylib changes.

g.

On Sat, Mar 21, 2009 at 4:28 PM, Grant Likely <grant.likely@secretlab.c=
a> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
>
> This patch makes changes in preparation for supporting open firmware
> device tree descriptions of MDIO busses. =A0Changes include:
> - Cleanup handling of phy_map[] entries; they are already NULLed when
> =A0registering and so don't need to be re-cleared, and it is good pra=
ctice
> =A0to clear them out when unregistering.
> - Split phy_device registration out into a new function so that the
> =A0OF helpers can do two stage registration (separate allocation and
> =A0registration steps).
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> CC: linuxppc-dev@ozlabs.org
> CC: netdev@vger.kernel.org
> CC: Andy Fleming <afleming@freescale.com>
> ---
>
> =A0drivers/net/phy/mdio_bus.c =A0 | =A0 29 +++-----------------------=
-
> =A0drivers/net/phy/phy_device.c | =A0 45 ++++++++++++++++++++++++++++=
++++++++++----
> =A0include/linux/phy.h =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A03 files changed, 45 insertions(+), 30 deletions(-)
>
>
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 811a637..3c39c7b 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -112,7 +112,6 @@ int mdiobus_register(struct mii_bus *bus)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bus->reset(bus);
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->phy_map[i] =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((bus->phy_mask & (1 << i)) =3D=3D =
0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct phy_device *phy=
dev;
>
> @@ -149,6 +148,7 @@ void mdiobus_unregister(struct mii_bus *bus)
> =A0 =A0 =A0 =A0for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (bus->phy_map[i])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0device_unregister(&bus=
->phy_map[i]->dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->phy_map[i] =3D NULL;
> =A0 =A0 =A0 =A0}
> =A0}
> =A0EXPORT_SYMBOL(mdiobus_unregister);
> @@ -187,35 +187,12 @@ struct phy_device *mdiobus_scan(struct mii_bus =
*bus, int addr)
> =A0 =A0 =A0 =A0if (IS_ERR(phydev) || phydev =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return phydev;
>
> - =A0 =A0 =A0 /* There's a PHY at this address
> - =A0 =A0 =A0 =A0* We need to set:
> - =A0 =A0 =A0 =A0* 1) IRQ
> - =A0 =A0 =A0 =A0* 2) bus_id
> - =A0 =A0 =A0 =A0* 3) parent
> - =A0 =A0 =A0 =A0* 4) bus
> - =A0 =A0 =A0 =A0* 5) mii_bus
> - =A0 =A0 =A0 =A0* And, we need to register it */
> -
> - =A0 =A0 =A0 phydev->irq =3D bus->irq !=3D NULL ? bus->irq[addr] : P=
HY_POLL;
> -
> - =A0 =A0 =A0 phydev->dev.parent =3D bus->parent;
> - =A0 =A0 =A0 phydev->dev.bus =3D &mdio_bus_type;
> - =A0 =A0 =A0 dev_set_name(&phydev->dev, PHY_ID_FMT, bus->id, addr);
> -
> - =A0 =A0 =A0 phydev->bus =3D bus;
> -
> - =A0 =A0 =A0 /* Run all of the fixups for this PHY */
> - =A0 =A0 =A0 phy_scan_fixups(phydev);
> -
> - =A0 =A0 =A0 err =3D device_register(&phydev->dev);
> + =A0 =A0 =A0 err =3D phy_device_register(phydev);
> =A0 =A0 =A0 =A0if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "phy %d failed to regis=
ter\n", addr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_device_free(phydev);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 bus->phy_map[addr] =3D phydev;
> -
> =A0 =A0 =A0 =A0return phydev;
> =A0}
> =A0EXPORT_SYMBOL(mdiobus_scan);
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index 0a06e4f..9352ca8 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -39,20 +39,21 @@ MODULE_DESCRIPTION("PHY library");
> =A0MODULE_AUTHOR("Andy Fleming");
> =A0MODULE_LICENSE("GPL");
>
> -static struct phy_driver genphy_driver;
> -extern int mdio_bus_init(void);
> -extern void mdio_bus_exit(void);
> -
> =A0void phy_device_free(struct phy_device *phydev)
> =A0{
> =A0 =A0 =A0 =A0kfree(phydev);
> =A0}
> +EXPORT_SYMBOL(phy_device_free);
>
> =A0static void phy_device_release(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0phy_device_free(to_phy_device(dev));
> =A0}
>
> +static struct phy_driver genphy_driver;
> +extern int mdio_bus_init(void);
> +extern void mdio_bus_exit(void);
> +
> =A0static LIST_HEAD(phy_fixup_list);
> =A0static DEFINE_MUTEX(phy_fixup_lock);
>
> @@ -166,6 +167,10 @@ struct phy_device* phy_device_create(struct mii_=
bus *bus, int addr, int phy_id)
> =A0 =A0 =A0 =A0dev->addr =3D addr;
> =A0 =A0 =A0 =A0dev->phy_id =3D phy_id;
> =A0 =A0 =A0 =A0dev->bus =3D bus;
> + =A0 =A0 =A0 dev->dev.parent =3D bus->parent;
> + =A0 =A0 =A0 dev->dev.bus =3D &mdio_bus_type;
> + =A0 =A0 =A0 dev->irq =3D bus->irq !=3D NULL ? bus->irq[addr] : PHY_=
POLL;
> + =A0 =A0 =A0 dev_set_name(&dev->dev, PHY_ID_FMT, bus->id, addr);
>
> =A0 =A0 =A0 =A0dev->state =3D PHY_DOWN;
>
> @@ -235,6 +240,38 @@ struct phy_device * get_phy_device(struct mii_bu=
s *bus, int addr)
>
> =A0 =A0 =A0 =A0return dev;
> =A0}
> +EXPORT_SYMBOL(get_phy_device);
> +
> +/**
> + * phy_device_register - Register the phy device on the MDIO bus
> + * @phy_device: phy_device structure to be added to the MDIO bus
> + */
> +int phy_device_register(struct phy_device *phydev)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 /* Don't register a phy if one is already registered at=
 this
> + =A0 =A0 =A0 =A0* address */
> + =A0 =A0 =A0 if (phydev->bus->phy_map[phydev->addr])
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 phydev->bus->phy_map[phydev->addr] =3D phydev;
> +
> + =A0 =A0 =A0 /* Run all of the fixups for this PHY */
> + =A0 =A0 =A0 phy_scan_fixups(phydev);
> +
> + =A0 =A0 =A0 err =3D device_register(&phydev->dev);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("phy %d failed to register\n", p=
hydev->addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +
> + out:
> + =A0 =A0 =A0 phydev->bus->phy_map[phydev->addr] =3D NULL;
> + =A0 =A0 =A0 return err;
> +}
> +EXPORT_SYMBOL(phy_device_register);
>
> =A0/**
> =A0* phy_prepare_link - prepares the PHY layer to monitor link status
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index d7e54d9..a47d64f 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -439,6 +439,7 @@ static inline int phy_write(struct phy_device *ph=
ydev, u16 regnum, u16 val)
>
> =A0int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
> =A0struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
> +int phy_device_register(struct phy_device *phy);
> =A0int phy_clear_interrupt(struct phy_device *phydev);
> =A0int phy_config_interrupt(struct phy_device *phydev, u32 interrupts=
);
> =A0struct phy_device * phy_attach(struct net_device *dev,
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
