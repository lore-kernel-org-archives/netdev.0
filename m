From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 2/2] net: emac: add support for device-tree based PHY
 discovery and setup
Date: Sat, 11 Feb 2017 15:07:04 -0800
Message-ID: <d696cd93-120d-e23f-3cce-5c3b64c7dc31@gmail.com>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com>
 <710c7971cb7dcef54058b61dced03b5d27553380.1486333475.git.chunkeey@googlemail.com>
 <7143c86d-6a3c-5e55-70cd-7424f28e1d78@gmail.com>
 <3718667.nVupg9V25n@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Christian Lamparter <chunkeey@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:34763 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdBKXHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 18:07:07 -0500
In-Reply-To: <3718667.nVupg9V25n@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/11/17 à 14:45, Christian Lamparter a écrit :
> Hello,
> 
> I'm sorry for the delay.
> 
> On Sunday, February 5, 2017 2:44:54 PM CET Florian Fainelli wrote:
>> Le 02/05/17 à 14:25, Christian Lamparter a écrit :
>>> From: Christian Lamparter <chunkeey@gmail.com>
>>>
>>> This patch adds glue-code that allows the EMAC driver to interface
>>> with the existing dt-supported PHYs in drivers/net/phy.
>>>
>>> Because currently, the emac driver maintains a small library of
>>> supported phys for in a private phy.c file located in the drivers
>>> directory.
>>>
>>> The support is limited to mostly single ethernet transceiver like the:
>>> CIS8201, BCM5248, ET1011C, Marvell 88E1111 and 88E1112, AR8035.
>>> However, routers like the Netgear WNDR4700 and Cisco Meraki MX60(W)
>>> have a 5-port switch (QCA8327N) attached to the MDIO of the EMAC.
>>> The switch chip has already a proper phy-driver (qca8k) that uses
>>> the generic phy library.
>>
>> Technically, it's a mdio_device in the upstream kernel that registers a
>> switch with DSA (and a PHY device in the OpenWrt/LEDE downstream
>> kernel). If your goal is to specifically support that device you should
>> consider making the EMAC interface with a fixed link PHY to properly
>> initialize the EMAC <=> CPU port of the switch link, and then declare
>> the qca8k device as a child MDIO device (not a PHY), similar to what is
>> done in arch/arm/boot/dts/vf610-zii-dev-rev-b.dts for instance.
> 
> Ok. I looked what was going on here. As you explained: qca8k is indeed 
> the wrong driver. We do use the ar8216 with swconfig interface.

Can you look into adding support for the 8216 into
drivers/net/dsa/qca8k.c? You don't necessarily need to use QCA tags
(using DSA_PROTO_NONE works too) and this would be a good way to know
what could be missing in that driver, you'd also get per-port network
devices, which could all be driving their built-in PHYs (so ethtool and
friends work as expected).

> 
> As for this patch. Currently the apm821xx target in LEDE has two supported
> routers, on AP and one NAS.
> 
> Both routers: The Netgear WNDR4700 and the Cisco MX60(W) use the AR8327N.
> 
> The AP: The Cisco Meraki MR24 has a AR8035 PHY. There's the at803x. driver,
> but David Miller was nice enough to merge this patch [0]. This patch added
> support for it in in emac's phy.c, however it also limits it to the MR24.
> 
> The NAS: Western Digital My Book Live (Uno and Duo) have a Broadcom PHY
> BCM54610 (it is detected as a BCM50610 PHY with a better version of this
> patch). There's a proper phy driver in the kernel for it too (broadcom.c).
> However, emac is limited to its own generic phy driver for this device.
> 
> Before I can answer the comments, I would like to deal with 
> the kbuild-test-robot. It discovered the following issues:
> 
> |   drivers/built-in.o: In function `emac_mdio_cleanup.isra.2':
> |>> core.c:(.text+0x70464): undefined reference to `mdiobus_free'
> |>> core.c:(.text+0x70494): undefined reference to `mdiobus_unregister'
> |   core.c:(.text+0x704a0): undefined reference to `mdiobus_free'
> |   drivers/built-in.o: In function `emac_remove':
> |>> core.c:(.text+0x70500): undefined reference to `phy_disconnect'
> 
> All these symbols are defined in include/linux/phy.h though.
> So, shouldn't there be some stubs for those functions in the
> header in case CONFIG_PHYLIB is not defined.
> Is this a simple oversight, or is there more to it?
> (I can add them if necessary. Or is someone looking for "easy" work?)

I am not clear how you ran into that build failure, don't you select
PHYLIB? You still need PHYLIB even if you implement a MDIO device driver
for the switch.

> 
>>> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
>>> ---
>>>  drivers/net/ethernet/ibm/emac/core.c | 188 +++++++++++++++++++++++++++++++++++
>>>  drivers/net/ethernet/ibm/emac/core.h |   4 +
>>>  2 files changed, 192 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
>>> index 6ead2335a169..ea9234cdb227 100644
>>> --- a/drivers/net/ethernet/ibm/emac/core.c
>>> +++ b/drivers/net/ethernet/ibm/emac/core.c
>>> @@ -42,6 +42,7 @@
>>>  #include <linux/of_address.h>
>>>  #include <linux/of_irq.h>
>>>  #include <linux/of_net.h>
>>> +#include <linux/of_mdio.h>
>>>  #include <linux/slab.h>
>>>  
>>>  #include <asm/processor.h>
>>> @@ -2420,6 +2421,179 @@ static int emac_read_uint_prop(struct device_node *np, const char *name,
>>>  	return 0;
>>>  }
>>>  
>>> +static void emac_adjust_link(struct net_device *ndev)
>>> +{
>>> +	struct emac_instance *dev = netdev_priv(ndev);
>>> +	struct phy_device *phy = dev->phy_dev;
>>> +
>>> +	mutex_lock(&dev->link_lock);
>>> +	dev->phy.autoneg = phy->autoneg;
>>> +	dev->phy.speed = phy->speed;
>>> +	dev->phy.duplex = phy->duplex;
>>> +	dev->phy.pause = phy->pause;
>>> +	dev->phy.asym_pause = phy->asym_pause;
>>> +	dev->phy.advertising = phy->advertising;
>>> +	mutex_unlock(&dev->link_lock);
>>
>> PHYLIB already executes grabbing the phy device's mutex, is this really
>> needed here?
> Yes, this is a bug. I accidently sent a very old version.
> (In fact, the LEDE patch had it already fixed[1].)
> 
>>> +}
>>> +
>>> +static int emac_mii_bus_read(struct mii_bus *bus, int addr, int regnum)
>>> +{
>>> +	return emac_mdio_read(bus->priv, addr, regnum);
>>> +}
>>> +
>>> +static int emac_mii_bus_write(struct mii_bus *bus, int addr, int regnum,
>>> +			      u16 val)
>>> +{
>>> +	emac_mdio_write(bus->priv, addr, regnum, val);
>>> +	return 0;
>>> +}
>>> +
>>> +static int emac_mii_bus_reset(struct mii_bus *bus)
>>> +{
>>> +	struct emac_instance *dev = netdev_priv(bus->priv);
>>> +
>>> +	emac_mii_reset_phy(&dev->phy);
>>
>> This seems wrong, emac_mii_reset_phy() does a BMCR software reset, which
>> PHYLIB is already going to do (phy_init_hw), yet you do this here at the
>> MDIO bus level towards a specify PHY, whereas this should be affecting
>> the MDIO bus itself (and/or *all* PHY child devices for quirks).
> Ah, this is a good point. The emac driver has a emac_reset() function
> that does disable and enabled the phy clocks. That said, this is already
> done by the emac driver during init too. So if I added it, the bus is
> reset twice (since it doesn't hurt - I added it back).
> 
> The emac_mii_phy_reset() was added because of the Meraki MX60(W).
> This is because Cisco's bootloader disables the switch port 
> (probably to prevent WAN<->LAN leakage during boot)
> 
> [bootlog from the MX60(W)]
> |Disabling port 0
> |Disabling port 1
> |Disabling port 2
> |Disabling port 3
> |ENET Speed is 1000 Mbps - FULL duplex connection (EMAC0)
> 
> Without emac_mii_reset_phy(), the mdiobus_scan() function, which
> is called by mdiobus_register will fail with -ENODEV.
> | /plb/opb/ethernet@ef600c00: failed to attach dt phy (-19).
> This is because get_phy_id() will "mostly read mostly Fs" and abort.

Is the PHY just powered down by chance (BMCR_PWRDN set?) and resetting
it implicitly clears the power down that seems to be what is going on.

Keep in mind that MDIO address 16 is the switch's pseudo PHY address
here, so if you are telling PHYLIB to probe for that address and you
don't get the expected MII_PHYSID1/2 value in return, that usually means
that there was a PHY fixup registered to intercept these reads and make
us return the switch's unique identifier. Reading from the switch's
pseudo PHY at address 16 registers 2/3 (MII_PHYSID1/2) is not guaranteed
to return the switch's unique identifer.

With a MDIO device driver this won't happen because you will be probed
by address, and you can read any switch register you want to and from
there move on with the initialization.

> 
> 
> With emac_mii_reset_phy() in place, it gets detected:
> | switch0: Atheros AR8327 rev. 4 switch registered on emac_mdio
> 
> Furthermore, this is probably not the only device which need it.
> Currently, emac's own phy.c code does call emac_mii_reset_phy() 
> as well as part of its probe procedure.
> <http://lxr.free-electrons.com/source/drivers/net/ethernet/ibm/emac/phy.c#L522>
> 
> Ideally, we would like to reset only the ports which are registered in the DT.

Which you would get for free if you did extend qca8k to support the
8216, because qca8k does implicitly tell the DSA layer to register a
dsa_slave_mii_bus which will probe and attach to per-port built-in PHYs
and that happens only for the ports enabled on your specific board.

> Do you know if there's a good way to do that? We measured that it takes ~5
> seconds to reset all 31 phys.

AFAICT there is no good way (without becoming too complex) to reset a
vector of PHYs and then just come back every 50ms or to see which ones
are reset or not.

NB: on some top of the rack switches, MDIO address 0 acts as a broadcast
address and you can use that feature to write to many, that still poses
the question of the read though which needs to be done for all PHYs to
know if the reset has completed.

> 
> |[    1.405249] /plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
> |[    1.663307] (phy 0 reset)
> |...
> |[    6.264852] (phy 31 reset)
> |[    6.270056] libphy: emac_mdio: probed
> 
>>> +	return 0;
>>> +}
>>> +
>>> +static int emac_mdio_probe(struct emac_instance *dev)
>>> +{
>>> +	struct device_node *mii_np;
>>> +	struct mii_bus *bus;
>>> +	int res;
>>> +
>>> +	bus = mdiobus_alloc();
>>> +	if (!bus)
>>> +		return -ENOMEM;
>>> +
>>> +	mii_np = of_get_child_by_name(dev->ofdev->dev.of_node, "mdio");
>>> +	if (!mii_np) {
>>> +		dev_err(&dev->ndev->dev, "no mdio definition found.");
>>> +		return -ENODEV;
>>> +	}
>>> +
>>> +	if (!of_device_is_available(mii_np))
>>> +		return 0;
>>> +
>>> +	bus->priv = dev->ndev;
>>> +	bus->parent = dev->ndev->dev.parent;
>>> +	bus->name = "emac_mdio";
>>> +	bus->read = &emac_mii_bus_read;
>>> +	bus->write = &emac_mii_bus_write;
>>> +	bus->reset = &emac_mii_bus_reset;
>>> +
>>> +	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
>>
>> You should pick a more unique name here, if you ever have a second
>> instance it would just clash with the previous one.
> I looked around what other drivers do. From what I can tell DT drivers
> just stick with the of->name.

My comment still stands, if you have two instances of this bus in a
system, the second will clash with the first one. You can just use
np->full_name or just use a driver private static index + bus->name to
create an unique enough name.

>>> +		dev->phy_dev = of_phy_connect(ndev, phy_handle,
>>> +					      &emac_adjust_link, 0,
>>> +					      PHY_INTERFACE_MODE_RGMII);
>>
>> You should call of_get_phy_mode() since there should be a proper
>> "phy-mode" or "phy-connection-type" property describing how it's
>> connected to the EMAC.
> of_get_phy_mode() is already called by emac.c as part of the 
> emac_init_config() function. I changed it to dev->phy_mode. 

Great thanks!

> 
>>> +		if (!dev->phy_dev) {
>>> +			res = -ENODEV;
>>> +			goto err_cleanup;
>>> +		}
>>> +
>>> +		of_node_put(phy_handle);
>>> +		dev->phy.def->phy_id = dev->phy_dev->drv->phy_id;
>>> +		dev->phy.def->phy_id_mask = dev->phy_dev->drv->phy_id_mask;
>>> +		dev->phy.def->name = dev->phy_dev->drv->name;
>>> +		dev->phy.def->ops = &emac_stub_phy_ops;
>>> +		/* Disable any PHY features not supported by the platform */
>>> +		dev->phy.def->features =  dev->phy_dev->drv->features &
>>> +					  ~dev->phy_feat_exc;
>>> +		dev->phy.features = dev->phy.def->features;
>>> +		dev->phy.address = dev->phy_dev->mdio.addr;
>>> +		dev->phy.mode = dev->phy_dev->interface;
>>> +		return 0;
>>> +	}
>>> +
>>> +	/* if the device tree didn't specifiy the the phy, then
>>> +	 * we simply fallback to the old emac_phy.c probe code
>>> +	 * for compatibility reasons.
>>> +	 */
>>> +	return 1;
>>> +
>>> + err_cleanup:
>>> +	of_node_put(phy_handle);
>>> +	kfree(dev->phy.def);
>>> +	return res;
>>> +}
>>> +
>>>  static int emac_init_phy(struct emac_instance *dev)
>>>  {
>>>  	struct device_node *np = dev->ofdev->dev.of_node;
>>> @@ -2490,6 +2664,13 @@ static int emac_init_phy(struct emac_instance *dev)
>>>  
>>>  	emac_configure(dev);
>>>  
>>> +	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII)) {
>>> +		int res = emac_probe_dt_phy(dev);
>>> +
>>> +		if (res <= 0)
>>> +			return res;
>>> +	}
>>
>> Why is this limited to EMAC_FTR_HAS_RGMII here?
> This is because, this code is only tested with RGMII.
> SGMII has a separate set of mii_read/write/reset functions and
> without a device to test the functionality, I don't really want
> to add it.

OK fair enough and that makes sense.
-- 
Florian
