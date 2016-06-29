From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 3/7] net: ethernet: bgmac: move BCMA MDIO Phy code into a
 separate file
Date: Wed, 29 Jun 2016 11:35:28 -0700
Message-ID: <577414F0.3060609@gmail.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-4-git-send-email-jon.mason@broadcom.com>
 <20160629141324.GA24194@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, davem@davemloft.net, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160629141324.GA24194@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/29/2016 07:13 AM, Andrew Lunn wrote:
> Hi Jon
> 
> I know you are just refactoring code, but at some point it would be
> good to take a closer look at this MDIO bus driver.
> 
> The MDIO bus driver should be generic, allowing access to all 32
> addresses on the bus, if that makes sense. You could for example have
> a B53 switch hanging off the MDIO bus.... The basic read/write
> functions seem to allow this.

That's the case on MIPS-based SoCs actually.

> 
>> +/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyinit */
>> +static void bcma_mdio_phy_init(struct bcma_mdio *bcma_mdio)
>> +{
>> +	struct bcma_chipinfo *ci = &bcma_mdio->core->bus->chipinfo;
>> +	u8 i;
>> +
>> +	if (ci->id == BCMA_CHIP_ID_BCM5356) {
>> +		for (i = 0; i < 5; i++) {
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x008b);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x15, 0x0100);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x12, 0x2aaa);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
> 
> It would be good to document what these writes are doing. Also, could
> they be moved into the phy driver? Does the PHY implement an ID in
> registers 2 and 3 that can be used to determine these are needed?
> 
> Also, why is it iterating over 5 PHYs? Is this actually a switch with
> 5 ports?

Yes, this is applying workarounds to the integrated PHYs, the plan is to
move that to a proper PHY driver so we can get rid of that.

> 
>> +		}
>> +	}
>> +	if ((ci->id == BCMA_CHIP_ID_BCM5357 && ci->pkg != 10) ||
>> +	    (ci->id == BCMA_CHIP_ID_BCM4749 && ci->pkg != 10) ||
>> +	    (ci->id == BCMA_CHIP_ID_BCM53572 && ci->pkg != 9)) {
>> +		struct bcma_drv_cc *cc = &bcma_mdio->core->bus->drv_cc;
>> +
>> +		bcma_chipco_chipctl_maskset(cc, 2, ~0xc0000000, 0);
>> +		bcma_chipco_chipctl_maskset(cc, 4, ~0x80000000, 0);
>> +		for (i = 0; i < 5; i++) {
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x5284);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x0010);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000f);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x5296);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x1073);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x9073);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x16, 0x52b6);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x17, 0x9273);
>> +			bcma_mdio_phy_write(bcma_mdio, i, 0x1f, 0x000b);
> 
> Same comment here.
> 
>> +/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyreset */
>> +static int bcma_mdio_phy_reset(struct mii_bus *bus)
>> +{
>> +	struct bcma_mdio *bcma_mdio = bus->priv;
>> +	u8 phyaddr = bcma_mdio->phyaddr;
>> +
>> +	if (bcma_mdio->phyaddr == BGMAC_PHY_NOREGS)
>> +		return 0;
>> +
>> +	bcma_mdio_phy_write(bcma_mdio, phyaddr, MII_BMCR, BMCR_RESET);
>> +	udelay(100);
>> +	if (bcma_mdio_phy_read(bcma_mdio, phyaddr, MII_BMCR) & BMCR_RESET)
>> +		dev_err(&bcma_mdio->core->dev, "PHY reset failed\n");
>> +	bcma_mdio_phy_init(bcma_mdio);
> 
> This appears to be resetting one PHY. What about the others? Why not
> put this in the PHY driver?

Probably should be there, keep in mind this driver was mostly reverse
engineered, from an internal code base which usually did not plan on
utilizing existing APIs.

> 
>> +struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 phyaddr)
>> +{
>> +	struct bcma_mdio *bcma_mdio;
>> +	struct mii_bus *mii_bus;
>> +	int err;
>> +
>> +	bcma_mdio = kzalloc(sizeof(*bcma_mdio), GFP_KERNEL);
>> +	if (!bcma_mdio)
>> +		return ERR_PTR(-ENOMEM);
>> +
>> +	mii_bus = mdiobus_alloc();
>> +	if (!mii_bus) {
>> +		err = -ENOMEM;
>> +		goto err;
>> +	}
>> +
>> +	mii_bus->name = "bcma_mdio mii bus";
>> +	sprintf(mii_bus->id, "%s-%d-%d", "bcma_mdio", core->bus->num,
>> +		core->core_unit);
>> +	mii_bus->priv = bcma_mdio;
>> +	mii_bus->read = bcma_mdio_mii_read;
>> +	mii_bus->write = bcma_mdio_mii_write;
>> +	mii_bus->reset = bcma_mdio_phy_reset;
>> +	mii_bus->parent = &core->dev;
>> +	mii_bus->phy_mask = ~(1 << phyaddr);
> 
> Is there a need to limit this to just the one PHY?

Usually this is only relevant for an external PHY, and Jon is just
moving code around without making functional changes to existing BCMA
code, so all of that can be changed at a later time.

> 
>> +
>> +	bcma_mdio->core = core;
>> +	bcma_mdio->phyaddr = phyaddr;
>> +
>> +	err = mdiobus_register(mii_bus);
> 
> Something which appears to be missing from the later patch which adds
> device tree support. If you have a device node pointer, you should use
> of_mdiobus_register() and document in the binding that PHYs should be
> listed in the usual way.

This is just moving the code around for now.

I don't think of_mdiobus_register() is going to be used at all, because
on the ARM-based BCM5301X SoCs that use Device Tree, we have yet to see
a platform which requires this MDIO bus driver, all PHYs are internal,
and hanging off the switch register access block.

On MIPS-based BCM53xx/47xx, we need this driver to drive the external
switches, but those are not Device Tree aware, nor is there a need to
make that happen.

And, to re-iterate all of your points are valid, but this is premature
-- 
Florian
