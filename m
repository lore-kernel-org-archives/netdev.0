From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [RFC 2/2] net: emac: add support for device-tree based PHY discovery and setup
Date: Tue, 14 Feb 2017 00:38:42 +0100
Message-ID: <2122984.F6mzWerJKz@debian64>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com> <3718667.nVupg9V25n@debian64> <d696cd93-120d-e23f-3cce-5c3b64c7dc31@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Christian Lamparter <chunkeey@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33700 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdBMXk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 18:40:57 -0500
Received: by mail-wr0-f194.google.com with SMTP id i10so26074836wrb.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 15:40:56 -0800 (PST)
In-Reply-To: <d696cd93-120d-e23f-3cce-5c3b64c7dc31@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, February 11, 2017 3:07:04 PM CET Florian Fainelli wrote:
> Le 02/11/17 =E0 14:45, Christian Lamparter a =E9crit :
> > On Sunday, February 5, 2017 2:44:54 PM CET Florian Fainelli wrote:
> >> Le 02/05/17 =E0 14:25, Christian Lamparter a =E9crit :
> >>> From: Christian Lamparter <chunkeey@gmail.com>
> >>>
> >>> This patch adds glue-code that allows the EMAC driver to interface
> >>> with the existing dt-supported PHYs in drivers/net/phy.
> >>>
> >>> Because currently, the emac driver maintains a small library of
> >>> supported phys for in a private phy.c file located in the drivers
> >>> directory.
> >>>
> >>> The support is limited to mostly single ethernet transceiver like the:
> >>> CIS8201, BCM5248, ET1011C, Marvell 88E1111 and 88E1112, AR8035.
> >>> However, routers like the Netgear WNDR4700 and Cisco Meraki MX60(W)
> >>> have a 5-port switch (QCA8327N) attached to the MDIO of the EMAC.
> >>> The switch chip has already a proper phy-driver (qca8k) that uses
> >>> the generic phy library.
> >>
> >> Technically, it's a mdio_device in the upstream kernel that registers a
> >> switch with DSA (and a PHY device in the OpenWrt/LEDE downstream
> >> kernel). If your goal is to specifically support that device you should
> >> consider making the EMAC interface with a fixed link PHY to properly
> >> initialize the EMAC <=3D> CPU port of the switch link, and then declare
> >> the qca8k device as a child MDIO device (not a PHY), similar to what is
> >> done in arch/arm/boot/dts/vf610-zii-dev-rev-b.dts for instance.
> >=20
> > Ok. I looked what was going on here. As you explained: qca8k is indeed=
=20
> > the wrong driver. We do use the ar8216 with swconfig interface.
>=20
> Can you look into adding support for the 8216 into
> drivers/net/dsa/qca8k.c? You don't necessarily need to use QCA tags
> (using DSA_PROTO_NONE works too) and this would be a good way to know
> what could be missing in that driver, you'd also get per-port network
> devices, which could all be driving their built-in PHYs (so ethtool and
> friends work as expected).
Oh, I don't have any devices with an AR8216. Both the Meraki MX60(W) and
the WNDR4700 have the AR8327. I only mentioned AR8216, because that's
the driver module in OpenWRT/LEDE which supports the AR8327 [0], [1].

As for emac and AR8327N: It will come right up, once the QCA8337-only guard=
=20
is removed from qca8k.c [2]. [QCA8K_ID_QCA8337 is 0x13, AR8327N is 0x12]:
|954	if (id !=3D QCA8K_ID_QCA8337)
|955			return -ENODEV;

[    4.250097] libphy: emac_mdio: probed
[    4.253789] mdio_bus 4ef600c00.ethern:10: mdio_device_register
[    4.346679] eth0: EMAC-0 /plb/opb/ethernet@ef600c00, MAC 10:0d:7f:4e:20:=
6e
[...]
[    4.425333] DSA: switch 0 0 parsed
[    4.428751] DSA: tree 0 parsed
[    4.496094] libphy: dsa slave smi: probed
[    4.513056] Generic PHY 4ef600c00.ethern:00: attached PHY driver [Generi=
c PHY] (mii_bus:phy_addr=3D4ef600c00.ethern:00, irq=3D-1)
[    4.524916] Generic PHY dsa-0.0:01: attached PHY driver [Generic PHY] (m=
ii_bus:phy_addr=3Ddsa-0.0:01, irq=3D-1)
[    4.535219] Generic PHY dsa-0.0:02: attached PHY driver [Generic PHY] (m=
ii_bus:phy_addr=3Ddsa-0.0:02, irq=3D-1)
[    4.545504] Generic PHY dsa-0.0:03: attached PHY driver [Generic PHY] (m=
ii_bus:phy_addr=3Ddsa-0.0:03, irq=3D-1)
[    4.555815] Generic PHY dsa-0.0:04: attached PHY driver [Generic PHY] (m=
ii_bus:phy_addr=3Ddsa-0.0:04, irq=3D-1)

# ip link
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP=
 mode DEFAULT group default qlen 1000
    link/ether 10:0d:7f:4e:20:6e brd ff:ff:ff:ff:ff:ff
3: lan4@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue swit=
chid 00000000 state UP mode DEFAULT group default qlen 1000
    link/ether 10:0d:7f:4e:20:6e brd ff:ff:ff:ff:ff:ff
4: lan3@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop switchid 00000000 s=
tate DOWN mode DEFAULT group default qlen 1000
    link/ether 10:0d:7f:4e:20:6e brd ff:ff:ff:ff:ff:ff
5: lan2@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop switchid 00000000 s=
tate DOWN mode DEFAULT group default qlen 1000
    link/ether 10:0d:7f:4e:20:6e brd ff:ff:ff:ff:ff:ff
6: lan1@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop switchid 00000000 s=
tate DOWN mode DEFAULT group default qlen 1000
    link/ether 10:0d:7f:4e:20:6e brd ff:ff:ff:ff:ff:ff
7: wan@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop switchid 00000000 st=
ate DOWN mode DEFAULT group default qlen 1000
    link/ether 10:0d:7f:4e:20:6e brd ff:ff:ff:ff:ff:ff
=20
> > As for this patch. Currently the apm821xx target in LEDE has two suppor=
ted
> > routers, on AP and one NAS.
> >=20
> > Both routers: The Netgear WNDR4700 and the Cisco MX60(W) use the AR8327=
N.
> >=20
> > The AP: The Cisco Meraki MR24 has a AR8035 PHY. There's the at803x. dri=
ver,
> > but David Miller was nice enough to merge this patch [0]. This patch ad=
ded
> > support for it in in emac's phy.c, however it also limits it to the MR2=
4.
> >=20
> > The NAS: Western Digital My Book Live (Uno and Duo) have a Broadcom PHY
> > BCM54610 (it is detected as a BCM50610 PHY with a better version of this
> > patch). There's a proper phy driver in the kernel for it too (broadcom.=
c).
> > However, emac is limited to its own generic phy driver for this device.
> >=20
> > Before I can answer the comments, I would like to deal with=20
> > the kbuild-test-robot. It discovered the following issues:
> >=20
> > |   drivers/built-in.o: In function `emac_mdio_cleanup.isra.2':
> > |>> core.c:(.text+0x70464): undefined reference to `mdiobus_free'
> > |>> core.c:(.text+0x70494): undefined reference to `mdiobus_unregister'
> > |   core.c:(.text+0x704a0): undefined reference to `mdiobus_free'
> > |   drivers/built-in.o: In function `emac_remove':
> > |>> core.c:(.text+0x70500): undefined reference to `phy_disconnect'
> >=20
> > All these symbols are defined in include/linux/phy.h though.
> > So, shouldn't there be some stubs for those functions in the
> > header in case CONFIG_PHYLIB is not defined.
> > Is this a simple oversight, or is there more to it?
> > (I can add them if necessary. Or is someone looking for "easy" work?)
>=20
> I am not clear how you ran into that build failure, don't you select
> PHYLIB? You still need PHYLIB even if you implement a MDIO device driver
> for the switch.
No, I didn't add it, because technically the emac.c has its own private
implementation for just the listed PHYs and they won't need PHYLIB.
However, once you had selected a PHY/DSA driver, PHYLIB was pulled in
automatically. So, I never spotted this because I always had the
broadcom.c PHY driver selected.=20

> >>> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
> >>> ---
> >>>  drivers/net/ethernet/ibm/emac/core.c | 188 +++++++++++++++++++++++++=
++++++++++
> >>>  drivers/net/ethernet/ibm/emac/core.h |   4 +
> >>>  2 files changed, 192 insertions(+)
> >>>
> >>> diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ether=
net/ibm/emac/core.c
> >>> index 6ead2335a169..ea9234cdb227 100644
> >>> --- a/drivers/net/ethernet/ibm/emac/core.c
> >>> +++ b/drivers/net/ethernet/ibm/emac/core.c
> >>> @@ -2420,6 +2421,179 @@ static int emac_read_uint_prop(struct device_=
node *np, const char *name,
> >>> [...]=20
> >>> +static int emac_mii_bus_reset(struct mii_bus *bus)
> >>> +{
> >>> +	struct emac_instance *dev =3D netdev_priv(bus->priv);
> >>> +
> >>> +	emac_mii_reset_phy(&dev->phy);
> >>
> >> This seems wrong, emac_mii_reset_phy() does a BMCR software reset, whi=
ch
> >> PHYLIB is already going to do (phy_init_hw), yet you do this here at t=
he
> >> MDIO bus level towards a specify PHY, whereas this should be affecting
> >> the MDIO bus itself (and/or *all* PHY child devices for quirks).
> > Ah, this is a good point. The emac driver has a emac_reset() function
> > that does disable and enabled the phy clocks. That said, this is already
> > done by the emac driver during init too. So if I added it, the bus is
> > reset twice (since it doesn't hurt - I added it back).
> >=20
> > The emac_mii_phy_reset() was added because of the Meraki MX60(W).
> > This is because Cisco's bootloader disables the switch port=20
> > (probably to prevent WAN<->LAN leakage during boot)
> >=20
> > [bootlog from the MX60(W)]
> > |Disabling port 0
> > |Disabling port 1
> > |Disabling port 2
> > |Disabling port 3
> > |ENET Speed is 1000 Mbps - FULL duplex connection (EMAC0)
> >=20
> > Without emac_mii_reset_phy(), the mdiobus_scan() function, which
> > is called by mdiobus_register will fail with -ENODEV.
> > | /plb/opb/ethernet@ef600c00: failed to attach dt phy (-19).
> > This is because get_phy_id() will "mostly read mostly Fs" and abort.
>=20
> Is the PHY just powered down by chance (BMCR_PWRDN set?) and resetting
> it implicitly clears the power down that seems to be what is going on.

Yes, the PHY is just in the BMCR_PDOWN state. I can do the same
on the WNDR4700, by messing with u-boot:

| =3D> mii write 0 0 0x0800
| =3D> mii dump
| 0.     (ffff)                 -- PHY control register --
|  (8000:8000) 0.15    =3D     1    reset
|  (4000:4000) 0.14    =3D     1    loopback
|  (2040:2040) 0. 6,13 =3D   b11    speed selection =3D ??? Mbps
|  (1000:1000) 0.12    =3D     1    A/N enable
|  (0800:0800) 0.11    =3D     1    power-down
|  (0400:0400) 0.10    =3D     1    isolate
|  (0200:0200) 0. 9    =3D     1    restart A/N
|  (0100:0100) 0. 8    =3D     1    duplex =3D full
|  (0080:0080) 0. 7    =3D     1    collision test enable
|  (003f:003f) 0. 5- 0 =3D    63    (reserved)

On the Meraki, the port disabled by the bootloader.=20
The reset is still needed.

> Keep in mind that MDIO address 16 is the switch's pseudo PHY address
> here, so if you are telling PHYLIB to probe for that address and you
> don't get the expected MII_PHYSID1/2 value in return, that usually means
> that there was a PHY fixup registered to intercept these reads and make
> us return the switch's unique identifier. Reading from the switch's
> pseudo PHY at address 16 registers 2/3 (MII_PHYSID1/2) is not guaranteed
> to return the switch's unique identifer.
>=20
> With a MDIO device driver this won't happen because you will be probed
> by address, and you can read any switch register you want to and from
> there move on with the initialization.
>=20
> >=20
> >=20
> > With emac_mii_reset_phy() in place, it gets detected:
> > | switch0: Atheros AR8327 rev. 4 switch registered on emac_mdio
> >=20
> > Furthermore, this is probably not the only device which need it.
> > Currently, emac's own phy.c code does call emac_mii_reset_phy()=20
> > as well as part of its probe procedure.
> > <http://lxr.free-electrons.com/source/drivers/net/ethernet/ibm/emac/phy=
=2Ec#L522>
> >=20
> > Ideally, we would like to reset only the ports which are registered in =
the DT.
>=20
> Which you would get for free if you did extend qca8k to support the
> 8327, because qca8k does implicitly tell the DSA layer to register a
> dsa_slave_mii_bus which will probe and attach to per-port built-in PHYs
> and that happens only for the ports enabled on your specific board.
No, the Meraki and the modified WNDR4700 still refuse to work. Just >one<
of the phys at address 0-4 need to be powered down to get the following
error:
[    4.425618] DSA: switch 0 0 parsed
[    4.429034] DSA: tree 0 parsed
[    4.435416] qca8k: probe of 4ef600c00.ethern:10 failed with error -5

I'll report back, what exactly is causing the error in this case.
> > Do you know if there's a good way to do that? We measured that it takes=
 ~5
> > seconds to reset all 31 phys.
>=20
> AFAICT there is no good way (without becoming too complex) to reset a
> vector of PHYs and then just come back every 50ms or to see which ones
> are reset or not.
>=20
> NB: on some top of the rack switches, MDIO address 0 acts as a broadcast
> address and you can use that feature to write to many, that still poses
> the question of the read though which needs to be done for all PHYs to
> know if the reset has completed.
That's good to know. On the AR8327, each of the five phys just map to one
of the four lan or wan ports.

> >>> +	return 0;
> >>> +}
> >>> +
> >>> +static int emac_mdio_probe(struct emac_instance *dev)
> >>> +{
> >>> +	struct device_node *mii_np;
> >>> +	struct mii_bus *bus;
> >>> +	int res;
> >>> +
> >>> +	bus =3D mdiobus_alloc();
> >>> +	if (!bus)
> >>> +		return -ENOMEM;
> >>> +
> >>> +	mii_np =3D of_get_child_by_name(dev->ofdev->dev.of_node, "mdio");
> >>> +	if (!mii_np) {
> >>> +		dev_err(&dev->ndev->dev, "no mdio definition found.");
> >>> +		return -ENODEV;
> >>> +	}
> >>> +
> >>> +	if (!of_device_is_available(mii_np))
> >>> +		return 0;
> >>> +
> >>> +	bus->priv =3D dev->ndev;
> >>> +	bus->parent =3D dev->ndev->dev.parent;
> >>> +	bus->name =3D "emac_mdio";
> >>> +	bus->read =3D &emac_mii_bus_read;
> >>> +	bus->write =3D &emac_mii_bus_write;
> >>> +	bus->reset =3D &emac_mii_bus_reset;
> >>> +
> >>> +	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
> >>
> >> You should pick a more unique name here, if you ever have a second
> >> instance it would just clash with the previous one.
> > I looked around what other drivers do. From what I can tell DT drivers
> > just stick with the of->name.
>=20
> My comment still stands, if you have two instances of this bus in a
> system, the second will clash with the first one. You can just use
> np->full_name or just use a driver private static index + bus->name to
> create an unique enough name.
Oh, I forgot to say that I changed it. It uses the dt node name, just
like everybody else.=20
=20
Regards,
Christian

[0] <https://git.lede-project.org/?p=3Dsource.git;a=3Dblob;f=3Dtarget/linux=
/generic/files/drivers/net/phy/ar8327.c;h=3D9b40cd7e4259e1ca8202a607a2d4701=
d3e903707;hb=3Dd5221d5a419c14456bccba9f6825567839082fb0>
[1] <https://git.lede-project.org/?p=3Dsource.git;a=3Dblob;f=3Dtarget/linux=
/generic/files/drivers/net/phy/ar8216.c;h=3Df3c953b808ee924493a4de9204bba2f=
b7906b0bf;hb=3Dd5221d5a419c14456bccba9f6825567839082fb0>
[2] <http://lxr.free-electrons.com/source/drivers/net/dsa/qca8k.c#L954>
