From: Georgi Vlaev <gvlaev@juniper.net>
Subject: Re: [PATCH 09/10] net: phy: Add MDIO driver for Juniper's SAM FPGA
Date: Sat, 8 Oct 2016 09:30:57 -0700
Message-ID: <20161008163056.GA17131@svl-evodev-gvlaev.juniper.net>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
 <1475853518-22264-10-git-send-email-pantelis.antoniou@konsulko.com>
 <20161007211326.GB10197@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
        David Miller <davem@davemloft.net>,
        Lee Jones <lee.jones@linaro.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "Debjit Ghosh" <dghosh@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        Maryam Seraj <mseraj@juniper.net>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161007211326.GB10197@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On 16-10-07 23:13:26, Andrew Lunn wrote:
> On Fri, Oct 07, 2016 at 06:18:37PM +0300, Pantelis Antoniou wrote:
> > From: Georgi Vlaev <gvlaev@juniper.net>
> > 
> > Add driver for the MDIO IP block present in Juniper's
> > SAM FPGA.
> > 
> > This driver supports only Clause 45 of the 802.3 spec.
> > 
> > Note that due to the fact that there are no drivers for
> > Broadcom/Avago retimers on 10/40Ge path that are controlled
> > from the MDIO interface there is a method to have direct
> > access to registers via a debugfs interface.
> 
> This seems to be the wrong solution. Why not write those drivers?
> 
> Controlling stuff from user space is generally frowned up. So i expect
> DaveM will NACK this patch. Please remove all the debugfs stuff.

I'll drop the debugfs and sysfs attributes. This will remove the
access from the user space.

> 
> > +static int mdio_sam_stat_wait(struct mii_bus *bus, u32 wait_mask)
> > +{
> > +	struct mdio_sam_data *data = bus->priv;
> > +	unsigned long timeout;
> > +	u32 stat;
> > +
> > +	timeout = jiffies + msecs_to_jiffies(MDIO_RDY_TMO);
> > +	do {
> > +		stat = ioread32(data->base + MDIO_STATUS);
> > +		if (stat & wait_mask)
> > +			return 0;
> > +
> > +		usleep_range(50, 100);
> > +	} while (time_before(jiffies, timeout));
> > +
> > +	return -EBUSY;
> 
> I've recently had to fix a loop like this in another
> driver. usleep_range(50, 100) can sleep for a lot longer. If it sleeps
> for MDIO_RDY_TMO you exit out with -EBUSY after a single iteration,
> which is not what you want. It is better to make a fixed number of
> iterations rather than a timeout.
> 

OK, I'll change it.

> > +}
> > +
> > +static int mdio_sam_read(struct mii_bus *bus, int phy_id, int regnum)
> > +{
> > +	struct mdio_sam_data *data = bus->priv;
> > +	u32 command, res;
> > +	int ret;
> > +
> > +	/* mdiobus_read holds the bus->mdio_lock mutex */
> > +
> > +	if (!(regnum & MII_ADDR_C45))
> > +		return -ENXIO;
> > +
> > +	ret = mdio_sam_stat_wait(bus, STAT_REG_RDY);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	command = regnum & 0x1fffff; /* regnum = (dev_id << 16) | reg */
> > +	command |= ((phy_id & 0x1f) << 21);
> > +
> > +	iowrite32(command, data->base + MDIO_CMD1);
> > +	ioread32(data->base + MDIO_CMD1);
> 
> 
> > +	iowrite32(CMD2_READ | CMD2_ENABLE, data->base + MDIO_CMD2);
> > +	ioread32(data->base + MDIO_CMD2);
> 
> Why do you need to read the values back? Hardware bug?
> 

We have a lot of these 'SAM' type of FPGAs, that follow the
same spec, but implemented in a different way. Some software
revisions have issues.

> > +	iowrite32(TBL_CMD_REG_GO, data->base + MDIO_TBL_CMD);
> > +	ioread32(data->base + MDIO_TBL_CMD);
> 
> Although not wrong, most drivers use writel().
> 
> > +
> > +	usleep_range(50, 100);
> > +
> > +	ret = mdio_sam_stat_wait(bus, (STAT_REG_DONE | STAT_REG_ERR));
> 
> Do you really need a wait before calling mdio_sam_stat_wait()? Isn't
> that what it is supposed to do, wait...
> 

I'll remove it.

> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	res = ioread32(data->base + MDIO_RESULT);
> > +
> > +	if (res & RES_ERROR || !(res & RES_SUCCESS))
> > +		return -EIO;
> > +
> > +	return (res & 0xffff);
> > +}
> > +
> > +static int mdio_sam_write(struct mii_bus *bus, int phy_id, int regnum, u16 val)
> > +{
> > +	struct mdio_sam_data *data = bus->priv;
> > +	u32 command;
> > +	int ret;
> > +
> > +	/* mdiobus_write holds the bus->mdio_lock mutex */
> > +
> > +	if (!(regnum & MII_ADDR_C45))
> > +		return -ENXIO;
> > +
> > +	ret = mdio_sam_stat_wait(bus, STAT_REG_RDY);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	command = regnum & 0x1fffff; /* regnum = (dev_id << 16) | reg */
> > +	command |= ((phy_id & 0x1f) << 21);
> > +
> > +	iowrite32(command, data->base + MDIO_CMD1);
> > +	ioread32(data->base + MDIO_CMD1);
> > +	iowrite32(CMD2_ENABLE | val, data->base + MDIO_CMD2);
> > +	ioread32(data->base + MDIO_CMD2);
> > +	iowrite32(TBL_CMD_REG_GO, data->base + MDIO_TBL_CMD);
> > +	ioread32(data->base + MDIO_TBL_CMD);
> > +
> > +	usleep_range(50, 100);
> > +
> > +	ret = mdio_sam_stat_wait(bus, (STAT_REG_DONE | STAT_REG_ERR));
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	return 0;
> > +}
> > +
> > +static int mdio_sam_reset(struct mii_bus *bus)
> > +{
> > +	struct mdio_sam_data *data = bus->priv;
> > +
> > +	iowrite32(TBL_CMD_SOFT_RESET, data->base + MDIO_TBL_CMD);
> > +	ioread32(data->base + MDIO_TBL_CMD);
> > +	mdelay(10);
> > +	iowrite32(0, data->base + MDIO_TBL_CMD);
> > +	ioread32(data->base + MDIO_TBL_CMD);
> > +
> > +	/* zero tables */
> > +	memset_io(data->base + MDIO_CMD1, 0, 0x1000);
> > +	memset_io(data->base + MDIO_PRI_CMD1, 0, 0x1000);
> 
> What tables?
> 

For each bus, the MDIO block has 3 tables of 512 entries - 2
"command" and one "result" table. Addresses and data are
written in the "command" table, the returned value for a
read command is written in the "result" table. Once a start
is triggered, the FPGA will flush all entries in those tables,
starting from offset 0. We don't want to have stale entries
in the tables, as they might result in transactions on the bus,
so we have to clear everything at least once. Actually we're
using just a single entry (1/512) from those tables.

> > +
> > +	return 0;
> > +}
> > +
> > +static int mdio_sam_of_register_bus(struct platform_device *pdev,
> > +				    struct device_node *np, void __iomem *base)
> > +{
> > +	struct mii_bus *bus;
> > +	struct mdio_sam_data *data;
> > +	u32 reg;
> > +	int ret;
> > +
> > +	bus = devm_mdiobus_alloc_size(&pdev->dev, sizeof(*data));
> > +	if (!bus)
> > +		return -ENOMEM;
> > +
> > +	/* bus offset */
> > +	ret = of_property_read_u32(np, "reg", &reg);
> > +	if (ret)
> > +		return -ENODEV;
> > +
> > +	data = bus->priv;
> > +	data->base = base + reg;
> > +
> > +	bus->parent = &pdev->dev;
> > +	bus->name = "mdio-sam";
> > +	bus->read = mdio_sam_read;
> > +	bus->write = mdio_sam_write;
> > +	bus->reset = mdio_sam_reset;
> > +	snprintf(bus->id, MII_BUS_ID_SIZE, "mdiosam-%x-%x", pdev->id, reg);
> > +
> > +	ret = of_mdiobus_register(bus, np);
> > +	if (ret < 0)
> > +		return ret;
> > +#ifdef CONFIG_DEBUG_FS
> > +	ret = mdio_sam_debugfs_init(bus);
> > +	if (ret < 0)
> > +		goto err_unregister;
> > +#endif
> > +	ret = device_create_bin_file(&bus->dev, &bin_attr_raw_io);
> > +	if (ret)
> > +		goto err_debugfs;
> > +
> > +	return 0;
> > +
> > +err_debugfs:
> > +#ifdef CONFIG_DEBUG_FS
> > +	mdio_sam_debugfs_remove(bus);
> > +#endif
> > +err_unregister:
> > +	mdiobus_unregister(bus);
> > +
> > +	return ret;
> > +}
> > +
> > +static int mdio_sam_of_unregister_bus(struct device_node *np)
> > +{
> > +	struct mii_bus *bus;
> > +
> > +	bus = of_mdio_find_bus(np);
> > +	if (bus) {
> > +		device_remove_bin_file(&bus->dev, &bin_attr_raw_io);
> > +#ifdef CONFIG_DEBUG_FS
> > +		mdio_sam_debugfs_remove(bus);
> > +#endif
> > +		mdiobus_unregister(bus);
> > +	}
> > +	return 0;
> > +}
> > +
> > +static int mdio_sam_probe(struct platform_device *pdev)
> > +{
> > +	struct device_node *np;
> > +	struct resource *res;
> > +	void __iomem *base;
> > +	int ret;
> > +
> > +	if (!pdev->dev.of_node)
> > +		return -ENODEV;
> > +
> > +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +	base = devm_ioremap_nocache(&pdev->dev, res->start,
> > +				    resource_size(res));
> 
> Why nocache?
> 

I'll change it to devm_ioremap().

> > +	if (IS_ERR(base))
> > +		return PTR_ERR(base);
> > +
> > +	for_each_available_child_of_node(pdev->dev.of_node, np) {
> > +		ret = mdio_sam_of_register_bus(pdev, np, base);
> > +		if (ret)
> > +			goto err;
> > +	}
> 
> This is odd. There does not seem to be any shared resources. So you
> should really have one MDIO bus as one device in the device tree.
> 

Well, there's no shared resource, so probably it can be changed to
a single device/bus. This might require changing the parent MFD as
well.

> 
> 
>        Andrew
> 
> > +
> > +	return 0;
> > +err:
> > +	/* roll back everything */
> > +	for_each_available_child_of_node(pdev->dev.of_node, np)
> > +		mdio_sam_of_unregister_bus(np);
> > +
> > +	return ret;
> > +}
> > +
> > +static int mdio_sam_remove(struct platform_device *pdev)
> > +{
> > +	struct device_node *np;
> > +
> > +	for_each_available_child_of_node(pdev->dev.of_node, np)
> > +		mdio_sam_of_unregister_bus(np);
> > +
> > +	return 0;
> > +}
> > +
> > +static const struct of_device_id mdio_sam_of_match[] = {
> > +	{ .compatible = "jnx,mdio-sam" },
> > +	{  }
> > +};
> > +MODULE_DEVICE_TABLE(of, mdio_sam_of_match);
> > +
> > +static struct platform_driver mdio_sam_driver = {
> > +	.probe = mdio_sam_probe,
> > +	.remove = mdio_sam_remove,
> > +	.driver = {
> > +		.name = "mdio-sam",
> > +		.owner = THIS_MODULE,
> > +		.of_match_table = mdio_sam_of_match,
> > +	},
> > +};
> > +
> > +module_platform_driver(mdio_sam_driver);
> > +
> > +MODULE_ALIAS("platform:mdio-sam");
> > +MODULE_AUTHOR("Georgi Vlaev <gvlaev@juniper.net>");
> > +MODULE_LICENSE("GPL");
> > +MODULE_DESCRIPTION("Juniper Networks SAM MDIO bus driver");
> > -- 
> > 1.9.1
> > 

-- 
joe
