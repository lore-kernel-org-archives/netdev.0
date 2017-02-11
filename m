From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [RFC 2/2] net: emac: add support for device-tree based PHY discovery and setup
Date: Sat, 11 Feb 2017 23:45:47 +0100
Message-ID: <3718667.nVupg9V25n@debian64>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com> <710c7971cb7dcef54058b61dced03b5d27553380.1486333475.git.chunkeey@googlemail.com> <7143c86d-6a3c-5e55-70cd-7424f28e1d78@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Christian Lamparter <chunkeey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ivan Mikhaylov <ivan-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <7143c86d-6a3c-5e55-70cd-7424f28e1d78-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

I'm sorry for the delay.

On Sunday, February 5, 2017 2:44:54 PM CET Florian Fainelli wrote:
> Le 02/05/17 =E0 14:25, Christian Lamparter a =E9crit :
> > From: Christian Lamparter <chunkeey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >=20
> > This patch adds glue-code that allows the EMAC driver to interface
> > with the existing dt-supported PHYs in drivers/net/phy.
> >=20
> > Because currently, the emac driver maintains a small library of
> > supported phys for in a private phy.c file located in the drivers
> > directory.
> >=20
> > The support is limited to mostly single ethernet transceiver like the:
> > CIS8201, BCM5248, ET1011C, Marvell 88E1111 and 88E1112, AR8035.
> > However, routers like the Netgear WNDR4700 and Cisco Meraki MX60(W)
> > have a 5-port switch (QCA8327N) attached to the MDIO of the EMAC.
> > The switch chip has already a proper phy-driver (qca8k) that uses
> > the generic phy library.
>=20
> Technically, it's a mdio_device in the upstream kernel that registers a
> switch with DSA (and a PHY device in the OpenWrt/LEDE downstream
> kernel). If your goal is to specifically support that device you should
> consider making the EMAC interface with a fixed link PHY to properly
> initialize the EMAC <=3D> CPU port of the switch link, and then declare
> the qca8k device as a child MDIO device (not a PHY), similar to what is
> done in arch/arm/boot/dts/vf610-zii-dev-rev-b.dts for instance.

Ok. I looked what was going on here. As you explained: qca8k is indeed=20
the wrong driver. We do use the ar8216 with swconfig interface.

As for this patch. Currently the apm821xx target in LEDE has two supported
routers, on AP and one NAS.

Both routers: The Netgear WNDR4700 and the Cisco MX60(W) use the AR8327N.

The AP: The Cisco Meraki MR24 has a AR8035 PHY. There's the at803x. driver,
but David Miller was nice enough to merge this patch [0]. This patch added
support for it in in emac's phy.c, however it also limits it to the MR24.

The NAS: Western Digital My Book Live (Uno and Duo) have a Broadcom PHY
BCM54610 (it is detected as a BCM50610 PHY with a better version of this
patch). There's a proper phy driver in the kernel for it too (broadcom.c).
However, emac is limited to its own generic phy driver for this device.

Before I can answer the comments, I would like to deal with=20
the kbuild-test-robot. It discovered the following issues:

|   drivers/built-in.o: In function `emac_mdio_cleanup.isra.2':
|>> core.c:(.text+0x70464): undefined reference to `mdiobus_free'
|>> core.c:(.text+0x70494): undefined reference to `mdiobus_unregister'
|   core.c:(.text+0x704a0): undefined reference to `mdiobus_free'
|   drivers/built-in.o: In function `emac_remove':
|>> core.c:(.text+0x70500): undefined reference to `phy_disconnect'

All these symbols are defined in include/linux/phy.h though.
So, shouldn't there be some stubs for those functions in the
header in case CONFIG_PHYLIB is not defined.
Is this a simple oversight, or is there more to it?
(I can add them if necessary. Or is someone looking for "easy" work?)

> > Signed-off-by: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> > ---
> >  drivers/net/ethernet/ibm/emac/core.c | 188 +++++++++++++++++++++++++++=
++++++++
> >  drivers/net/ethernet/ibm/emac/core.h |   4 +
> >  2 files changed, 192 insertions(+)
> >=20
> > diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/etherne=
t/ibm/emac/core.c
> > index 6ead2335a169..ea9234cdb227 100644
> > --- a/drivers/net/ethernet/ibm/emac/core.c
> > +++ b/drivers/net/ethernet/ibm/emac/core.c
> > @@ -42,6 +42,7 @@
> >  #include <linux/of_address.h>
> >  #include <linux/of_irq.h>
> >  #include <linux/of_net.h>
> > +#include <linux/of_mdio.h>
> >  #include <linux/slab.h>
> > =20
> >  #include <asm/processor.h>
> > @@ -2420,6 +2421,179 @@ static int emac_read_uint_prop(struct device_no=
de *np, const char *name,
> >  	return 0;
> >  }
> > =20
> > +static void emac_adjust_link(struct net_device *ndev)
> > +{
> > +	struct emac_instance *dev =3D netdev_priv(ndev);
> > +	struct phy_device *phy =3D dev->phy_dev;
> > +
> > +	mutex_lock(&dev->link_lock);
> > +	dev->phy.autoneg =3D phy->autoneg;
> > +	dev->phy.speed =3D phy->speed;
> > +	dev->phy.duplex =3D phy->duplex;
> > +	dev->phy.pause =3D phy->pause;
> > +	dev->phy.asym_pause =3D phy->asym_pause;
> > +	dev->phy.advertising =3D phy->advertising;
> > +	mutex_unlock(&dev->link_lock);
>=20
> PHYLIB already executes grabbing the phy device's mutex, is this really
> needed here?
Yes, this is a bug. I accidently sent a very old version.
(In fact, the LEDE patch had it already fixed[1].)

> > +}
> > +
> > +static int emac_mii_bus_read(struct mii_bus *bus, int addr, int regnum)
> > +{
> > +	return emac_mdio_read(bus->priv, addr, regnum);
> > +}
> > +
> > +static int emac_mii_bus_write(struct mii_bus *bus, int addr, int regnu=
m,
> > +			      u16 val)
> > +{
> > +	emac_mdio_write(bus->priv, addr, regnum, val);
> > +	return 0;
> > +}
> > +
> > +static int emac_mii_bus_reset(struct mii_bus *bus)
> > +{
> > +	struct emac_instance *dev =3D netdev_priv(bus->priv);
> > +
> > +	emac_mii_reset_phy(&dev->phy);
>=20
> This seems wrong, emac_mii_reset_phy() does a BMCR software reset, which
> PHYLIB is already going to do (phy_init_hw), yet you do this here at the
> MDIO bus level towards a specify PHY, whereas this should be affecting
> the MDIO bus itself (and/or *all* PHY child devices for quirks).
Ah, this is a good point. The emac driver has a emac_reset() function
that does disable and enabled the phy clocks. That said, this is already
done by the emac driver during init too. So if I added it, the bus is
reset twice (since it doesn't hurt - I added it back).

The emac_mii_phy_reset() was added because of the Meraki MX60(W).
This is because Cisco's bootloader disables the switch port=20
(probably to prevent WAN<->LAN leakage during boot)

[bootlog from the MX60(W)]
|Disabling port 0
|Disabling port 1
|Disabling port 2
|Disabling port 3
|ENET Speed is 1000 Mbps - FULL duplex connection (EMAC0)

Without emac_mii_reset_phy(), the mdiobus_scan() function, which
is called by mdiobus_register will fail with -ENODEV.
| /plb/opb/ethernet@ef600c00: failed to attach dt phy (-19).
This is because get_phy_id() will "mostly read mostly Fs" and abort.


With emac_mii_reset_phy() in place, it gets detected:
| switch0: Atheros AR8327 rev. 4 switch registered on emac_mdio

=46urthermore, this is probably not the only device which need it.
Currently, emac's own phy.c code does call emac_mii_reset_phy()=20
as well as part of its probe procedure.
<http://lxr.free-electrons.com/source/drivers/net/ethernet/ibm/emac/phy.c#L=
522>

Ideally, we would like to reset only the ports which are registered in the =
DT.
Do you know if there's a good way to do that? We measured that it takes ~5
seconds to reset all 31 phys.

|[    1.405249] /plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
|[    1.663307] (phy 0 reset)
|...
|[    6.264852] (phy 31 reset)
|[    6.270056] libphy: emac_mdio: probed

> > +	return 0;
> > +}
> > +
> > +static int emac_mdio_probe(struct emac_instance *dev)
> > +{
> > +	struct device_node *mii_np;
> > +	struct mii_bus *bus;
> > +	int res;
> > +
> > +	bus =3D mdiobus_alloc();
> > +	if (!bus)
> > +		return -ENOMEM;
> > +
> > +	mii_np =3D of_get_child_by_name(dev->ofdev->dev.of_node, "mdio");
> > +	if (!mii_np) {
> > +		dev_err(&dev->ndev->dev, "no mdio definition found.");
> > +		return -ENODEV;
> > +	}
> > +
> > +	if (!of_device_is_available(mii_np))
> > +		return 0;
> > +
> > +	bus->priv =3D dev->ndev;
> > +	bus->parent =3D dev->ndev->dev.parent;
> > +	bus->name =3D "emac_mdio";
> > +	bus->read =3D &emac_mii_bus_read;
> > +	bus->write =3D &emac_mii_bus_write;
> > +	bus->reset =3D &emac_mii_bus_reset;
> > +
> > +	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
>=20
> You should pick a more unique name here, if you ever have a second
> instance it would just clash with the previous one.
I looked around what other drivers do. From what I can tell DT drivers
just stick with the of->name.

> > +
> > +	res =3D of_mdiobus_register(bus, mii_np);
> > +	if (res) {
> > +		dev_err(&dev->ndev->dev, "cannot register MDIO bus %s\n",
> > +			bus->name);
> > +		mdiobus_free(bus);
> > +	}
> > +
> > +	dev->mii_bus =3D bus;
> > +	return res;
> > +}
> > +
> > +static void emac_mdio_cleanup(struct emac_instance *dev)
> > +{
> > +	if (dev->mii_bus) {
> > +		if (dev->mii_bus->state =3D=3D MDIOBUS_REGISTERED)
> > +			mdiobus_unregister(dev->mii_bus);
>=20
> If you need to make that kind of check, why not separate how the mdio
> bus structure's lifecycle is managed? This seems to be avoiding to hit
> the BUG_ON() in mdiobus_unregister..
Yes, I converted it all to devres.=20

> > +		mdiobus_free(dev->mii_bus);
> > +		dev->mii_bus =3D NULL;
> > +		kfree(dev->phy.def);
> > +	}
> > +}
> > +
> > +static int stub_setup_aneg(struct mii_phy *phy, u32 advertise)
> > +{
> > +	return 0;
> > +}
> > +
> > +static int stub_setup_forced(struct mii_phy *phy, int speed, int fd)
> > +{
> > +	return 0;
> > +}
> > +
> > +static int stub_poll_link(struct mii_phy *phy)
> > +{
> > +	struct net_device *ndev =3D phy->dev;
> > +	struct emac_instance *dev =3D netdev_priv(ndev);
> > +
> > +	return dev->opened;
> > +}
> > +
> > +static int stub_read_link(struct mii_phy *phy)
> > +{
> > +	struct net_device *ndev =3D phy->dev;
> > +	struct emac_instance *dev =3D netdev_priv(ndev);
> > +
> > +	phy_start(dev->phy_dev);
>=20
> Are you sure the read_link function is supposed to start the PHY state
> machine? Either the name is confusing, or it's not the right thing to do
> here.
This was already fixed too :).
>=20
> > +	return 0;
> > +}
> > +
> > +static const struct mii_phy_ops emac_stub_phy_ops =3D {
> > +	.setup_aneg	=3D stub_setup_aneg,
> > +	.setup_forced	=3D stub_setup_forced,
> > +	.poll_link	=3D stub_poll_link,
> > +	.read_link	=3D stub_read_link,
> > +};
> > +
> > +static int emac_probe_dt_phy(struct emac_instance *dev)
> > +{
> > +	struct device_node *np =3D dev->ofdev->dev.of_node;
> > +	struct device_node *phy_handle;
> > +	struct net_device *ndev =3D dev->ndev;
> > +	int res;
> > +
> > +	phy_handle =3D of_parse_phandle(np, "phy-handle", 0);
> > +
> > +	if (phy_handle) {
> > +		res =3D emac_mdio_probe(dev);
> > +		if (res)
> > +			goto err_cleanup;
> > +
> > +		dev->phy.def =3D kzalloc(sizeof(*dev->phy.def), GFP_KERNEL);
> > +		if (!dev->phy.def) {
> > +			res =3D -ENOMEM;
> > +			goto err_cleanup;
> > +		}
> > +
> > +		dev->phy_dev =3D of_phy_connect(ndev, phy_handle,
> > +					      &emac_adjust_link, 0,
> > +					      PHY_INTERFACE_MODE_RGMII);
>=20
> You should call of_get_phy_mode() since there should be a proper
> "phy-mode" or "phy-connection-type" property describing how it's
> connected to the EMAC.
of_get_phy_mode() is already called by emac.c as part of the=20
emac_init_config() function. I changed it to dev->phy_mode.=20

> > +		if (!dev->phy_dev) {
> > +			res =3D -ENODEV;
> > +			goto err_cleanup;
> > +		}
> > +
> > +		of_node_put(phy_handle);
> > +		dev->phy.def->phy_id =3D dev->phy_dev->drv->phy_id;
> > +		dev->phy.def->phy_id_mask =3D dev->phy_dev->drv->phy_id_mask;
> > +		dev->phy.def->name =3D dev->phy_dev->drv->name;
> > +		dev->phy.def->ops =3D &emac_stub_phy_ops;
> > +		/* Disable any PHY features not supported by the platform */
> > +		dev->phy.def->features =3D  dev->phy_dev->drv->features &
> > +					  ~dev->phy_feat_exc;
> > +		dev->phy.features =3D dev->phy.def->features;
> > +		dev->phy.address =3D dev->phy_dev->mdio.addr;
> > +		dev->phy.mode =3D dev->phy_dev->interface;
> > +		return 0;
> > +	}
> > +
> > +	/* if the device tree didn't specifiy the the phy, then
> > +	 * we simply fallback to the old emac_phy.c probe code
> > +	 * for compatibility reasons.
> > +	 */
> > +	return 1;
> > +
> > + err_cleanup:
> > +	of_node_put(phy_handle);
> > +	kfree(dev->phy.def);
> > +	return res;
> > +}
> > +
> >  static int emac_init_phy(struct emac_instance *dev)
> >  {
> >  	struct device_node *np =3D dev->ofdev->dev.of_node;
> > @@ -2490,6 +2664,13 @@ static int emac_init_phy(struct emac_instance *d=
ev)
> > =20
> >  	emac_configure(dev);
> > =20
> > +	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII)) {
> > +		int res =3D emac_probe_dt_phy(dev);
> > +
> > +		if (res <=3D 0)
> > +			return res;
> > +	}
>=20
> Why is this limited to EMAC_FTR_HAS_RGMII here?
This is because, this code is only tested with RGMII.
SGMII has a separate set of mii_read/write/reset functions and
without a device to test the functionality, I don't really want
to add it.

> > +
> >  	if (dev->phy_address !=3D 0xffffffff)
> >  		phy_map =3D ~(1 << dev->phy_address);
> > =20
> > @@ -2938,6 +3119,8 @@ static int emac_probe(struct platform_device *ofd=
ev)
> >  	/* I have a bad feeling about this ... */
> > =20
> >   err_detach_tah:
> > +	emac_mdio_cleanup(dev);
> > +
> >  	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
> >  		tah_detach(dev->tah_dev, dev->tah_port);
> >   err_detach_rgmii:
> > @@ -2988,6 +3171,11 @@ static int emac_remove(struct platform_device *o=
fdev)
> >  	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII))
> >  		zmii_detach(dev->zmii_dev, dev->zmii_port);
> > =20
> > +	if (dev->phy_dev)
> > +		phy_disconnect(dev->phy_dev);
> > +
> > +	emac_mdio_cleanup(dev);
> > +
> >  	busy_phy_map &=3D ~(1 << dev->phy.address);
> >  	DBG(dev, "busy_phy_map now %#x" NL, busy_phy_map);
> > =20
> > diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/etherne=
t/ibm/emac/core.h
> > index 93ae11494810..0710a6685489 100644
> > --- a/drivers/net/ethernet/ibm/emac/core.h
> > +++ b/drivers/net/ethernet/ibm/emac/core.h
> > @@ -199,6 +199,10 @@ struct emac_instance {
> >  	struct emac_instance		*mdio_instance;
> >  	struct mutex			mdio_lock;
> > =20
> > +	/* Device-tree based phy configuration */
> > +	struct mii_bus			*mii_bus;
> > +	struct phy_device		*phy_dev;
> > +
> >  	/* ZMII infos if any */
> >  	u32				zmii_ph;
> >  	u32				zmii_port;
> >=20
>

[0] <https://patchwork.ozlabs.org/patch/617930/>
[1] <https://git.lede-project.org/?p=3Dsource.git;a=3Dblob;f=3Dtarget/linux=
/apm821xx/patches-4.4/702-powerpc_ibm_phy_add_dt_parser.patch;h=3Dc84e761ed=
02efe881a20adc0d275e4e4e74589a3;hb=3D6c6167621f3aba358742d68aeaed8dd360254a=
d6>
[2] <https://git.lede-project.org/?p=3Dsource.git;a=3Dblob;f=3Dtarget/linux=
/apm821xx/patches-4.9/702-powerpc_ibm_phy_add_dt_parser.patch;h=3Dc84e761ed=
02efe881a20adc0d275e4e4e74589a3;hb=3D6c6167621f3aba358742d68aeaed8dd360254a=
d6>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
