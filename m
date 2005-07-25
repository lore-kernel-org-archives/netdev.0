From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 1/4] PHY Abstraction Layer III (now with more
	splitiness)
Date: Mon, 25 Jul 2005 23:06:46 +0200
Message-ID: <20050725210646.GA17828@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.61.0507251134470.15537@cde-tx32-ldt113.sps.mot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	linuxppc-embedded <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0507251134470.15537@cde-tx32-ldt113.sps.mot.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Andy Fleming <afleming@freescale.com> :
> This patch contains the PHY layer itself, no phy drivers
[...]
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> new file mode 100644
> --- /dev/null
> +++ b/drivers/net/phy/Kconfig
[...]
> +config MARVELL_PHY
> +	bool "Drivers for Marvell PHYs"
> +	depends on PHYLIB
> +	---help---
> +	  Currently has a driver for the 88E1011S
> +	
> +config DAVICOM_PHY
> +	bool "Drivers for Davicom PHYs"
> +	depends on PHYLIB
> +	---help---
> +	  Currently supports dm9161e and dm9131
[snip]

They try to escape...

[...]
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> new file mode 100644
> --- /dev/null
> +++ b/drivers/net/phy/Makefile
> @@ -0,0 +1,9 @@
> +# Makefile for Linux PHY drivers
> +
> +obj-$(CONFIG_PHYLIB) += phy.o phy_device.o mdio_bus.o
> +
> +obj-$(CONFIG_MARVELL_PHY) += marvell.o
> +obj-$(CONFIG_DAVICOM_PHY) += davicom.o
> +obj-$(CONFIG_CICADA_PHY) += cicada.o
> +obj-$(CONFIG_LXT_PHY) += lxt.o
> +obj-$(CONFIG_QSEMI_PHY) += qsemi.o

...and they are not alone. :o)

> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> new file mode 100644
> --- /dev/null
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -0,0 +1,175 @@
[...]
> +int mdiobus_register(struct mii_bus *bus)
> +{
> +	int i;
> +	int err = 0;
> +
> +	spin_lock_init(&bus->mdio_lock);
> +
> +	if (NULL == bus || NULL == bus->name ||
> +			NULL == bus->read ||
> +			NULL == bus->write)

Be spartan:
	if (!bus || !bus->name || !bus->read || !bus->write)

> +		return -EINVAL;
> +
> +	if (bus->reset)
> +		bus->reset(bus);
> +
> +	for (i=0; i < PHY_MAX_ADDR; i++) {

	for (i = 0; ...

> +		struct phy_device *phydev;
> +
> +		phydev = get_phy_device(bus, i);
> +
> +		/* There's a PHY at this address
> +		 * We need to set:
> +		 * 1) IRQ
> +		 * 2) bus_id
> +		 * 3) parent
> +		 * 4) bus
> +		 * 5) mii_bus
> +		 * And, we need to register it */
> +		if (phydev) {
> +			phydev->irq = bus->irq[i];
> +
> +			phydev->dev.parent = bus->dev;
> +
> +			phydev->dev.bus = &mdio_bus_type;
> +
> +			phydev->bus = bus;
> +
> +			sprintf(phydev->dev.bus_id, "phy%d:%d", bus->id, 

Imho you are going a bit too far with empty lines. Not a real issue.

> i);

Something decided to wrap the lines after you did the patch. It appears
several times in the patch (+ extra tabs/spaces at the end of the lines:
there are plenty of nice colorised editors around).

> +
> +			err = device_register(&phydev->dev);
> +
> +			if (err)
> +				printk("phy %d did not register (%d)\n",
> +						i, err);

Missing KERN_SOMETHING in the printk.

> +
> +		/* If get_phy_device returned NULL, it may be
> +		 * because an error occurred.  If so, we return
> +		 * that error */
> +		} else if (errno)
> +			return errno;

I'd rather use ERR_PTR/PTR_ERR/IS_ERR + goto in the first place
(then the previous printk will fit on a single line).

> +
> +		bus->phy_map[i] = phydev;
> +	}
> +
> +	pr_info("%s: probed\n", bus->name);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(mdiobus_register);
> +
> +void mdiobus_unregister(struct mii_bus *bus)
> +{
> +	int i;
> +
> +	for (i=0; i < PHY_MAX_ADDR; i++)

for( i = 0, ... + missing brace.

[...]
> +static int mdio_bus_suspend(struct device * dev, u32 state)
> +{
> +	int ret = 0;
> +
> +	if (dev->driver && dev->driver->suspend) {
> +		ret = dev->driver->suspend(dev, state, SUSPEND_DISABLE);
> +		if (ret == 0)
> +			ret = dev->driver->suspend(dev, state, 
> SUSPEND_SAVE_STATE);
> +		if (ret == 0)
> +			ret = dev->driver->suspend(dev, state, 
> SUSPEND_POWER_DOWN);
> +	}

Copy/paste abuse:
	struct device_driver *drv = dev->driver;

(appears in several functions)

[...]
> +struct bus_type mdio_bus_type = {
> +	.name	= "mdio_bus",
> +	.match	= mdio_bus_match,
> +	.suspend= mdio_bus_suspend,
               ^^

[...]
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> new file mode 100644
> --- /dev/null
> +++ b/drivers/net/phy/phy.c
[...]
> +int phy_read(struct phy_device *phydev, u16 regnum);
> +int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
> +void phy_change(void *data);
> +void phy_timer(unsigned long data);

phy_read and phy_write do not need to be forward-declared.
Not sure if it is possible for phy_{change/timer} as well.

> +
> +/* Convenience function to print out the current phy status
> + */
> +void phy_print_status(struct phy_device *phydev)
> +{
> +	pr_info("%s: Link is %s", phydev->dev.bus_id,
> +			phydev->link ? "Up" : "Down");
> +	if (phydev->link)
> +		printk(" - %d/%s", phydev->speed,

Missing KERN_SOMETHING in the printk.

[...]
> +static inline int phy_aneg_done(struct phy_device *phydev)
> +{
> +	int retval;
> +
> +	retval = phy_read(phydev, MII_BMSR);
> +
> +	if (retval < 0)
> +		return retval;
> +
> +	return retval & BMSR_ANEGCOMPLETE;

Please use a ternary operator.

> +}
> +
> +/* phy_start_aneg
> + *
> + * description: Calls the PHY driver's config_aneg, and then
> + *   sets the PHY state to PHY_AN if auto-negotiation is enabled,
> + *   and to PHY_FORCING if auto-negotiation is disabled. Unless
> + *   the PHY is currently HALTED.
> + */
> +int phy_start_aneg(struct phy_device *phydev)
> +{
> +	int err = 0;

Unneeded initialization.

> +
> +	spin_lock(&phydev->lock);
> +
> +	if (AUTONEG_DISABLE == phydev->autoneg)
> +		phy_sanitize_settings(phydev);
> +
> +	err = phydev->drv->config_aneg(phydev);
> +
> +	if (err < 0)
> +		return err;

The lock should be released. Add a 'goto out_unlock;' ?

> +
> +	if (phydev->state != PHY_HALTED) {
> +		if (AUTONEG_ENABLE == phydev->autoneg) {
> +			phydev->state = PHY_AN;
> +			phydev->link_timeout = PHY_AN_TIMEOUT;
> +		} else {
> +			phydev->state = PHY_FORCING;
> +			phydev->link_timeout = PHY_FORCE_TIMEOUT;
> +		}
> +	}
> +

out_unlock:

> +	spin_unlock(&phydev->lock);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(phy_start_aneg);
> +
> +
[...]
> +/* A mapping of all SUPPORTED settings to speed/duplex */
> +static struct phy_setting settings[] = {
> +	{ .speed = 10000, .duplex = DUPLEX_FULL,
> +		.setting = SUPPORTED_10000baseT_Full,
> +	},
> +	{ .speed = SPEED_1000, .duplex = DUPLEX_FULL,
> +		.setting = SUPPORTED_1000baseT_Full,
> +	},
> +	{ .speed = SPEED_1000, .duplex = DUPLEX_HALF,
> +		.setting = SUPPORTED_1000baseT_Half,
> +	},
> +	{ .speed = SPEED_100, .duplex = DUPLEX_FULL,
> +		.setting = SUPPORTED_100baseT_Full,
> +	},
> +	{ .speed = SPEED_100, .duplex = DUPLEX_HALF,
> +		.setting = SUPPORTED_100baseT_Half,
> +	},
> +	{ .speed = SPEED_10, .duplex = DUPLEX_FULL,
> +		.setting = SUPPORTED_10baseT_Full,
> +	},
> +	{ .speed = SPEED_10, .duplex = DUPLEX_HALF,
> +		.setting = SUPPORTED_10baseT_Half,
> +	},
> +};

Would you veto some macro to initialise this array ?

> +
> +#define MAX_NUM_SETTINGS (sizeof(settings)/sizeof(struct phy_setting))

The kernel provides ARRAY_SIZE

[...]
> +static inline int phy_find_setting(int speed, int duplex)
> +{
> +	int idx = 0;
> +
> +	while (idx < MAX_NUM_SETTINGS &&
> +			(settings[idx].speed != speed ||
> +			settings[idx].duplex != duplex))
> +		idx++;

"for" loop in disguise ?

> +
> +	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;

Ok (dunno if "idx % MAX_NUM_SETTINGS" is more idiomatic or not).

[...]
> +int phy_start_interrupts(struct phy_device *phydev)
> +{
> +	int err = 0;
> +
> +	INIT_WORK(&phydev->phy_queue, phy_change, phydev);
> +
> +	if (request_irq(phydev->irq, phy_interrupt,
> +				SA_SHIRQ,
> +				"phy_interrupt",
> +				phydev) < 0) {

Please, don't do that :o(

	err = request_irq(phydev->irq, phy_interrupt, SA_SHIRQ,
			  "phy_interrupt", phydev);
	if (err < 0)
		...

> +		printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
> +				phydev->bus->name,
> +				phydev->irq);
> +		phydev->irq = PHY_POLL;
> +		return 0;

The description of the function says "Returns 0 on success".

[...]
> +/* Bring down the PHY link, and stop checking the status. */
> +void phy_stop(struct phy_device *phydev)
> +{
> +	spin_lock(&phydev->lock);
> +
> +	if (PHY_HALTED == phydev->state) {
> +		spin_unlock(&phydev->lock);
> +		return;
> +	}

"goto out_unlock;"

> +
> +	if (phydev->irq != PHY_POLL) {
> +		/* Clear any pending interrupts */
> +		phy_clear_interrupt(phydev);
> +
> +		/* Disable PHY Interrupts */
> +		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
> +	}
> +
> +	phydev->state = PHY_HALTED;
> +
> +	spin_unlock(&phydev->lock);
> +}
[...]
> +struct phy_device * get_phy_device(struct mii_bus *bus, uint addr)
> +{

uint ?

> +	int phy_reg;
> +	u32 phy_id;
> +	struct phy_device *dev = NULL;
> +
> +	errno = 0;

A bit ugly.

> +
> +	/* Grab the bits from PHYIR1, and put them
> +	 * in the upper half */
> +	phy_reg = bus->read(bus, addr, MII_PHYSID1);
> +
> +	if (phy_reg < 0) {
> +		errno = phy_reg;
> +		return NULL;

		dev = ERR_PTR(phy_reg);
		goto out;
		...
> +	}
> +
> +	phy_id = (phy_reg & 0xffff) << 16;
> +
> +	/* Grab the bits from PHYIR2, and put them in the lower half */
> +	phy_reg = bus->read(bus, addr, MII_PHYSID2);
> +
> +	if (phy_reg < 0) {
> +		errno = phy_reg;
> +		return NULL;
> +	}
> +
> +	phy_id |= (phy_reg & 0xffff);
> +
> +	/* If the phy_id is all Fs, there is no device there */
> +	if (0xffffffff == phy_id)
> +		return NULL;
> +
> +	/* Otherwise, we allocate the device, and initialize the
> +	 * default values */
> +	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
> +
> +	if (NULL == dev) {
> +		errno = -ENOMEM;
> +		return NULL;
> +	}
> +
> +	memset(dev, 0, sizeof(*dev));

The kernel provides kcalloc.

[...]
> +static int phy_compare_id(struct device *dev, void *data)
> +{
> +	const char *name = data;
> +
> +	if (strcmp(name, dev->bus_id) == 0)
> +		return 1;
> +	return 0;

Ternary operator ?

> +}
> +
> +struct phy_device *phy_attach(struct net_device *dev,
> +		const char *phy_id, u32 flags)
> +{
> +	struct phy_device *phydev = NULL;

Useless initialization.

> +	struct bus_type *bus = &mdio_bus_type;
> +	struct device *d;
> +
> +	/* Search the list of PHY devices on the mdio bus for the
> +	 * PHY with the requested name */
> +	d = bus_find_device(bus, NULL, (void *)phy_id, phy_compare_id);
> +
> +	if (d) {
> +		phydev = to_phy_device(d);
> +	} else {
> +		printk(KERN_ERR "%s not found\n", phy_id);
> +		errno = -ENODEV;
> +		return NULL;
> +	}
> +
> +	/* Assume that if there is no driver, that it doesn't
> +	 * exist, and we should use the genphy driver. */
> +	if (NULL == phydev->dev.driver) {
> +		int err;
> +		down_write(&phydev->dev.bus->subsys.rwsem);
> +		phydev->dev.driver = &genphy_driver.driver;
> +
> +		err = phydev->dev.driver->probe(&phydev->dev);

Would it be possible to s/phydev->dev/d/ ?

--
Ueimor
