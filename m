From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Thu, 15 Sep 2016 03:12:33 +0200
Message-ID: <20160915011233.GC29110@lunn.ch>
References: <1473849542-3298-1-git-send-email-john@phrozen.org>
 <1473849542-3298-4-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473849542-3298-4-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 12:39:02PM +0200, John Crispin wrote:
> This patch contains initial support for the QCA8337 switch. It
> will detect a QCA8337 switch, if present and declared in the DT.
> 
> Each port will be represented through a standalone net_device interface,
> as for other DSA switches. CPU can communicate with any of the ports by
> setting an IP@ on ethN interface. Most of the extra callbacks of the DSA
> subsystem are already supported, such as bridge offloading, stp, fdb.
> 
> Signed-off-by: John Crispin <john@phrozen.org>
> ---
> Changes in V2
> * add proper locking for the FDB table
> * remove udelay when changing the page. neither datasheet nore SDK code
>   requires a sleep
> * add a cond_resched to the busy wait loop
> * use nested locking when accessing the mdio bus
> * remove the phy_to_port() wrappers
> * remove mmd access function and use existing phy helpers
> * fix a copy/paste bug breaking the eee callbacks
> * use default vid 1 when fdb entries are added fro vid 0
> * remove the phy id check and add a switch id check instead
> * add error handling to the mdio read/write functions
> * remove inline usage

Hi John

Thanks for the changes, it looks a lot better.

> +static u16 qca8k_current_page = 0xffff;
> +
> +static struct
> +qca8k_priv *qca8k_to_priv(struct dsa_switch *ds)
> +{
> +	struct qca8k_priv *priv = ds->priv;
> +
> +	return priv;
> +}

https://lkml.org/lkml/2016/8/31/936

In this patch, Vivien removed all the callers to ds_to_priv(). Which
is what this function is. Please just use ds->priv.

> +
> +static void
> +qca8k_fdb_flush(struct qca8k_priv *priv)
> +{
> +	mutex_lock(&priv->fdb_mutex);
> +	qca8k_fdb_access(priv, QCA8K_FDB_FLUSH, -1);
> +	mutex_unlock(&priv->fdb_mutex);
> +}

So this protects the fdb. But should this mutex be more general. Take for example:

> +qca8k_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +	u32 lpi_en = QCA8K_REG_EEE_CTRL_LPI_EN(port);
> +	u32 reg;
> +
> +	reg = qca8k_read(priv, QCA8K_REG_EEE_CTRL);
> +	if (enable)
> +		reg |= lpi_en;
> +	else
> +		reg &= ~lpi_en;
> +	qca8k_write(priv, QCA8K_REG_EEE_CTRL, reg);
> +}
> +

Here you do a read/modify/write. Could this be called on two
interfaces at the same time? I think you might want this protected as
well by a mutex. So maybe rename fdb_mutex to something more generic
and use it in places like this as well?

> +static int
> +qca8k_setup(struct dsa_switch *ds)
> +{
> +	struct qca8k_priv *priv = qca8k_to_priv(ds);
> +	int ret, i, phy_mode = -1;
> +
> +	/* Start by setting up the register mapping */
> +	priv->regmap = devm_regmap_init(ds->dev, NULL, priv,
> +					&qca8k_regmap_config);
> +
> +	if (IS_ERR(priv->regmap))
> +		pr_warn("regmap initialization failed");
> +
> +	/* Initialize CPU port pad mode (xMII type, delays...) */
> +	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
> +	if (phy_mode < 0) {
> +		pr_err("Can't find phy-mode for master device\n");
> +		return phy_mode;
> +	}
> +	ret = qca8k_set_pad_ctrl(priv, QCA8K_CPU_PORT, phy_mode);
> +	if (ret < 0)
> +		return ret;

Maybe add a check here that dsa_is_cpu_port(ds, 0) is true?  If you
say the CPU port has to be 0, it should be checked for.

> +	/* Enable CPU Port */
> +	qca8k_reg_set(priv, QCA8K_REG_GLOBAL_FW_CTRL0,
> +		      QCA8K_GLOBAL_FW_CTRL0_CPU_PORT_EN);
> +
> +	/* Enable MIB counters */
> +	qca8k_reg_set(priv, QCA8K_REG_MIB, QCA8K_MIB_CPU_KEEP);
> +	qca8k_write(priv, QCA8K_REG_MODULE_EN, QCA8K_MODULE_EN_MIB);

Will this implicitly clear the MIB counters? They should be set to
zero, otherwise they can survive a reboot of the host.

> +
> +	/* Setup connection between CPU ports & PHYs */

You missed a few "PHY". We tend to call such ports user ports, or
external ports.

> +	for (i = 0; i < DSA_MAX_PORTS; i++) {
> +		/* CPU port gets connected to all PHYs in the switch */
> +		if (dsa_is_cpu_port(ds, i)) {
> +			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(QCA8K_CPU_PORT),
> +				  QCA8K_PORT_LOOKUP_MEMBER,
> +				  ds->enabled_port_mask);
> +		}
> +
> +		/* Invividual PHYs gets connected to CPU port only */
> +		if (ds->enabled_port_mask & BIT(i)) {
> +			int shift = 16 * (i % 2);
> +
> +			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(i),
> +				  QCA8K_PORT_LOOKUP_MEMBER,
> +				  BIT(QCA8K_CPU_PORT));
> +
> +			/* Enable ARP Auto-learning by default */
> +			qca8k_reg_set(priv, QCA8K_PORT_LOOKUP_CTRL(i),
> +				      QCA8K_PORT_LOOKUP_LEARN);
> +
> +			/* For port based vlans to work we need to set the
> +			 * default egress vid
> +			 */
> +			qca8k_rmw(priv, QCA8K_EGRESS_VLAN(i),
> +				  0xffff << shift, 1 << shift);
> +			qca8k_write(priv, QCA8K_REG_PORT_VLAN_CTRL0(i),
> +				    QCA8K_PORT_VLAN_CVID(1) |
> +				    QCA8K_PORT_VLAN_SVID(1));
> +		}
> +	}
> +
> +	/* Flush the FDB table */
> +	qca8k_fdb_flush(priv);
> +
> +	return 0;
> +}
> +
> +static int
> +qca8k_set_addr(struct dsa_switch *ds, u8 *addr)
> +{
> +	/* The subsystem always calls this function so add an empty stub */
> +	return 0;
> +}

The b53/bcm_sf2 driver also has a NOP for set_addr(). Maybe it is time
to make it optional. But that is a separate patchset. This is O.K.

> +static void
> +qca8k_get_strings(struct dsa_switch *ds, int phy, uint8_t *data)

In general, please can you not use int phy, when the prototype is int
port. This is a bad example, since phy/port is not actually used,
but... In fact, it does not happen so often, so maybe you just missed
this one?

> +static int
> +qca8k_fdb_prepare(struct dsa_switch *ds, int port,
> +		  const struct switchdev_obj_port_fdb *fdb,
> +		  struct switchdev_trans *trans)
> +{
> +	/* We do not need to do anything specific here yet */
> +	return 0;
> +}

Does this mean you can store an infinite number of fdb entries?

> +static void
> +qca8k_sw_remove(struct mdio_device *mdiodev)
> +{
> +	struct qca8k_priv *priv = dev_get_drvdata(&mdiodev->dev);
> +
> +	dsa_unregister_switch(priv->ds);
> +}

This has the same problem as the mv88e6xxx driver. You should disable
all the ports when removing the driver. Something on my TODO list...

> +
> +#ifdef CONFIG_PM_SLEEP
> +static int qca8k_suspend(struct device *dev)
> +{
> +	struct platform_device *pdev = to_platform_device(dev);
> +	struct qca8k_priv *priv = platform_get_drvdata(pdev);
> +
> +	return dsa_switch_suspend(priv->ds);
> +}
> +
> +static int qca8k_resume(struct device *dev)
> +{
> +	struct platform_device *pdev = to_platform_device(dev);
> +	struct qca8k_priv *priv = platform_get_drvdata(pdev);
> +
> +	return dsa_switch_resume(priv->ds);
> +}
> +#endif /* CONFIG_PM_SLEEP */

The bcm_sf2 driver disables the port on suspend, and re-enables them
on resume. You should probably do the same.

Thanks

   Andrew
