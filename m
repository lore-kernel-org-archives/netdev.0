From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 3/9] phylib: add *_direct() variants of phy_connect and
	phy_attach functions
Date: Wed, 18 Mar 2009 23:05:58 -0600
Message-ID: <fa686aa40903182205o34e6e32cq4441db2bd369f14@mail.gmail.com>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
	 <20090319050026.11320.23198.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:36238 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbZCSFGB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:06:01 -0400
Received: by yw-out-2324.google.com with SMTP id 5so392674ywb.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:05:58 -0700 (PDT)
In-Reply-To: <20090319050026.11320.23198.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC, please don't apply yet.

On Wed, Mar 18, 2009 at 11:00 PM, Grant Likely
<grant.likely@secretlab.ca> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
>
> Add phy_connect_direct() and phy_attach_direct() functions so that
> drivers can use a pointer to the phy_device instead of trying to dete=
rmine
> the phy's bus_id string.
>
> This patch is useful for OF device tree descriptions of phy devices w=
here
> the driver doesn't need or know what the bus_id value in order to get=
 a
> phy_device pointer.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
>
> =A0drivers/net/phy/phy_device.c | =A0118 ++++++++++++++++++++++++++++=
++------------
> =A0include/linux/phy.h =A0 =A0 =A0 =A0 =A0| =A0 =A05 ++
> =A02 files changed, 90 insertions(+), 33 deletions(-)
>
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index 793332f..238d21e 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -290,6 +290,33 @@ void phy_prepare_link(struct phy_device *phydev,
> =A0}
>
> =A0/**
> + * phy_connect_direct - connect an ethernet device to a specific phy=
_device
> + * @dev: the network device to connect
> + * @phydev: the pointer to the phy device
> + * @handler: callback function for state change notifications
> + * @flags: PHY device's dev_flags
> + * @interface: PHY device's interface
> + */
> +int phy_connect_direct(struct net_device *dev, struct phy_device *ph=
ydev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*handler)(struct n=
et_device *), u32 flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_interface_t interfac=
e)
> +{
> + =A0 =A0 =A0 int rc;
> +
> + =A0 =A0 =A0 rc =3D phy_attach_direct(dev, phydev, flags, interface)=
;
> + =A0 =A0 =A0 if (rc)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return rc;
> +
> + =A0 =A0 =A0 phy_prepare_link(phydev, handler);
> + =A0 =A0 =A0 phy_start_machine(phydev, NULL);
> + =A0 =A0 =A0 if (phydev->irq > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_start_interrupts(phydev);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +EXPORT_SYMBOL(phy_connect_direct);
> +
> +/**
> =A0* phy_connect - connect an ethernet device to a PHY device
> =A0* @dev: the network device to connect
> =A0* @bus_id: the id string of the PHY device to connect
> @@ -310,18 +337,21 @@ struct phy_device * phy_connect(struct net_devi=
ce *dev, const char *bus_id,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_interface_t interface)
> =A0{
> =A0 =A0 =A0 =A0struct phy_device *phydev;
> + =A0 =A0 =A0 struct device *d;
> + =A0 =A0 =A0 int rc;
>
> - =A0 =A0 =A0 phydev =3D phy_attach(dev, bus_id, flags, interface);
> -
> - =A0 =A0 =A0 if (IS_ERR(phydev))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return phydev;
> -
> - =A0 =A0 =A0 phy_prepare_link(phydev, handler);
> -
> - =A0 =A0 =A0 phy_start_machine(phydev, NULL);
> + =A0 =A0 =A0 /* Search the list of PHY devices on the mdio bus for t=
he
> + =A0 =A0 =A0 =A0* PHY with the requested name */
> + =A0 =A0 =A0 d =3D bus_find_device_by_name(&mdio_bus_type, NULL, bus=
_id);
> + =A0 =A0 =A0 if (!d) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("PHY %s not found\n", bus_id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 phydev =3D to_phy_device(d);
>
> - =A0 =A0 =A0 if (phydev->irq > 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_start_interrupts(phydev);
> + =A0 =A0 =A0 rc =3D phy_attach_direct(dev, phydev, flags, interface)=
;
> + =A0 =A0 =A0 if (rc)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(rc);
>
> =A0 =A0 =A0 =A0return phydev;
> =A0}
> @@ -345,9 +375,9 @@ void phy_disconnect(struct phy_device *phydev)
> =A0EXPORT_SYMBOL(phy_disconnect);
>
> =A0/**
> - * phy_attach - attach a network device to a particular PHY device
> + * phy_attach_direct - attach a network device to a given PHY device=
 pointer
> =A0* @dev: network device to attach
> - * @bus_id: PHY device to attach
> + * @phydev: Pointer to phy_device to attach
> =A0* @flags: PHY device's dev_flags
> =A0* @interface: PHY device's interface
> =A0*
> @@ -358,22 +388,10 @@ EXPORT_SYMBOL(phy_disconnect);
> =A0* =A0 =A0 the attaching device, and given a callback for link stat=
us
> =A0* =A0 =A0 change. =A0The phy_device is returned to the attaching d=
river.
> =A0*/
> -struct phy_device *phy_attach(struct net_device *dev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *bus_id, u32 flags, phy_inte=
rface_t interface)
> +int phy_attach_direct(struct net_device *dev, struct phy_device *phy=
dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 flags, phy_interface_t =
interface)
> =A0{
> - =A0 =A0 =A0 struct bus_type *bus =3D &mdio_bus_type;
> - =A0 =A0 =A0 struct phy_device *phydev;
> - =A0 =A0 =A0 struct device *d;
> -
> - =A0 =A0 =A0 /* Search the list of PHY devices on the mdio bus for t=
he
> - =A0 =A0 =A0 =A0* PHY with the requested name */
> - =A0 =A0 =A0 d =3D bus_find_device_by_name(bus, NULL, bus_id);
> - =A0 =A0 =A0 if (d) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev =3D to_phy_device(d);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s not found\n", bus_i=
d);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 struct device *d =3D &phydev->dev;
>
> =A0 =A0 =A0 =A0/* Assume that if there is no driver, that it doesn't
> =A0 =A0 =A0 =A0 * exist, and we should use the genphy driver. */
> @@ -386,13 +404,12 @@ struct phy_device *phy_attach(struct net_device=
 *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D device_bind_dr=
iver(d);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (phydev->attached_dev) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s: %s already attache=
d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->na=
me, bus_id);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EBUSY);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "PHY already attache=
d\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0phydev->attached_dev =3D dev;
> @@ -410,13 +427,48 @@ struct phy_device *phy_attach(struct net_device=
 *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D phy_scan_fixups(phydev);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D phydev->drv->config_init(phyde=
v);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +EXPORT_SYMBOL(phy_attach_direct);
> +
> +/**
> + * phy_attach - attach a network device to a particular PHY device
> + * @dev: network device to attach
> + * @bus_id: Bus ID of PHY device to attach
> + * @flags: PHY device's dev_flags
> + * @interface: PHY device's interface
> + *
> + * Description: Same as phy_attach_direct() except that a PHY bus_id
> + * =A0 =A0 string is passed instead of a pointer to a struct phy_dev=
ice.
> + */
> +struct phy_device *phy_attach(struct net_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *bus_id, u32 flags, phy_inte=
rface_t interface)
> +{
> + =A0 =A0 =A0 struct bus_type *bus =3D &mdio_bus_type;
> + =A0 =A0 =A0 struct phy_device *phydev;
> + =A0 =A0 =A0 struct device *d;
> + =A0 =A0 =A0 int rc;
> +
> + =A0 =A0 =A0 /* Search the list of PHY devices on the mdio bus for t=
he
> + =A0 =A0 =A0 =A0* PHY with the requested name */
> + =A0 =A0 =A0 d =3D bus_find_device_by_name(bus, NULL, bus_id);
> + =A0 =A0 =A0 if (!d) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("PHY %s not found\n", bus_id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 phydev =3D to_phy_device(d);
> +
> + =A0 =A0 =A0 rc =3D phy_attach_direct(dev, phydev, flags, interface)=
;
> + =A0 =A0 =A0 if (rc)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(rc);
>
> =A0 =A0 =A0 =A0return phydev;
> =A0}
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index a47d64f..97405f2 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -442,8 +442,13 @@ struct phy_device* get_phy_device(struct mii_bus=
 *bus, int addr);
> =A0int phy_device_register(struct phy_device *phy);
> =A0int phy_clear_interrupt(struct phy_device *phydev);
> =A0int phy_config_interrupt(struct phy_device *phydev, u32 interrupts=
);
> +int phy_attach_direct(struct net_device *dev, struct phy_device *phy=
dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 flags, phy_interface_t interface);
> =A0struct phy_device * phy_attach(struct net_device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char *bus_id, u32 flags, phy_int=
erface_t interface);
> +int phy_connect_direct(struct net_device *dev, struct phy_device *ph=
ydev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void (*handler)(struct net_device *), u=
32 flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_interface_t interface);
> =A0struct phy_device * phy_connect(struct net_device *dev, const char=
 *bus_id,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*handler)(struct net_device *), =
u32 flags,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_interface_t interface);
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
