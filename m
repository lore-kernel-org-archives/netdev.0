From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 23/32] net: dsa: bcm_sf2: make it a real platform
 driver
Date: Thu, 3 Mar 2016 10:33:03 -0800
Message-ID: <56D8835F.4040607@gmail.com>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <1456677700-23027-24-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35685 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbcCCSee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 13:34:34 -0500
Received: by mail-pa0-f68.google.com with SMTP id fl4so1687304pad.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 10:34:29 -0800 (PST)
In-Reply-To: <1456677700-23027-24-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/02/16 08:41, Andrew Lunn wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> 
> The Broadcom Starfighter 2 switch driver should be a proper platform
> driver, now that the DSA code has been updated to allow that, register
> a switch device, feed it with the proper configuration data coming
> from Device Tree and register our switch device with DSA.
> 
> The bulk of the changes consist in moving what bcm_sf2_sw_setup() did
> into the component slave bind function.
> 
> This change does not however prevent the old DSA binding from working.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
[snip]

> +	/* All the interesting properties are at the parent device_node
> +	 * level
> +	 */
> +	dn = ds->pd->of_node->parent;

This is no longer true with the binding you are proposing, but see more
below.

> +	bcm_sf2_identify_ports(priv, ds->pd->of_node);
> +
> +	priv->irq0 = irq_of_parse_and_map(dn, 0);
> +	priv->irq1 = irq_of_parse_and_map(dn, 1);
> +
> +	base = &priv->core;
> +	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
> +		*base = of_iomap(dn, i);
> +		if (!base) {
> +			pr_err("unable to find register: %s\n", reg_names[i]);
> +			ret = -ENOMEM;
> +			goto out_unmap;
> +		}
> +		base++;
> +	}
> +
> +	ret = bcm_sf2_sw_rst(priv);
> +	if (ret) {
> +		pr_err("unable to software reset switch: %d\n", ret);
> +		goto out_unmap;
> +	}
> +
> +	/* Disable all interrupts and request them */
> +	bcm_sf2_intr_disable(priv);
> +
> +	ret = request_irq(priv->irq0, bcm_sf2_switch_0_isr, 0,
> +			  "switch_0", priv);
> +	if (ret < 0) {
> +		pr_err("failed to request switch_0 IRQ\n");
> +		goto out_unmap;
> +	}
> +
> +	ret = request_irq(priv->irq1, bcm_sf2_switch_1_isr, 0,
> +			  "switch_1", priv);
> +	if (ret < 0) {
> +		pr_err("failed to request switch_1 IRQ\n");
> +		goto out_free_irq0;
> +	}
> +
> +	/* Reset the MIB counters */
> +	reg = core_readl(priv, CORE_GMNCFGCFG);
> +	reg |= RST_MIB_CNT;
> +	core_writel(priv, reg, CORE_GMNCFGCFG);
> +	reg &= ~RST_MIB_CNT;
> +	core_writel(priv, reg, CORE_GMNCFGCFG);
> +
> +	/* Get the maximum number of ports for this switch */
> +	priv->hw_params.num_ports = core_readl(priv, CORE_IMP0_PRT_ID) + 1;
> +	if (priv->hw_params.num_ports > DSA_MAX_PORTS)
> +		priv->hw_params.num_ports = DSA_MAX_PORTS;
> +
> +	/* Assume a single GPHY setup if we can't read that property */
> +	if (of_property_read_u32(dn, "brcm,num-gphy",
> +				 &priv->hw_params.num_gphy))
> +		priv->hw_params.num_gphy = 1;
> +
> +	/* Include the pseudo-PHY address and the broadcast PHY address to
> +	 * divert reads towards our workaround. This is only required for
> +	 * 7445D0, since 7445E0 disconnects the internal switch pseudo-PHY such
> +	 * that we can use the regular SWITCH_MDIO master controller instead.
> +	 *
> +	 * By default, DSA initializes ds->phys_mii_mask to ds->phys_port_mask
> +	 * to have a 1:1 mapping between Port address and PHY address in order
> +	 * to utilize the slave_mii_bus instance to read from Port PHYs. This is
> +	 * not what we want here, so we initialize phys_mii_mask 0 to always
> +	 * utilize the "master" MDIO bus backed by the "mdio-unimac" driver.
> +	 */
> +	if (of_machine_is_compatible("brcm,bcm7445d0"))
> +		ds->phys_mii_mask |= ((1 << BRCM_PSEUDO_PHY_ADDR) | (1 << 0));
> +	else
> +		ds->phys_mii_mask = 0;
> +
> +	rev = reg_readl(priv, REG_SWITCH_REVISION);
> +	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
> +					SWITCH_TOP_REV_MASK;
> +	priv->hw_params.core_rev = (rev & SF2_REV_MASK);
> +
> +	rev = reg_readl(priv, REG_PHY_REVISION);
> +	priv->hw_params.gphy_rev = rev & PHY_REVISION_MASK;
> +
> +	pr_info("Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
> +		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
> +		priv->hw_params.core_rev >> 8, priv->hw_params.core_rev & 0xff,
> +		priv->core, priv->irq0, priv->irq1);
> +
> +	platform_set_drvdata(pdev, ds);
> +
> +	return dsa_switch_register(dst, ds, dn, "Starfighter 2");
> +
> +out_free_irq0:
> +	free_irq(priv->irq0, priv);
> +out_unmap:
> +	base = &priv->core;
> +	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
> +		if (*base)
> +			iounmap(*base);
> +		base++;
> +	}
> +	return ret;
> +}
> +
> +static void bcm_sf2_sw_unbind(struct device *dev,
> +			      struct device *master, void *data)
> +{
> +	struct dsa_switch *ds = dev_get_drvdata(dev);
> +	struct bcm_sf2_priv *priv = ds_to_priv(ds);
> +
> +	/* Disable all ports and interrupts */
> +	priv->wol_ports_mask = 0;
> +	bcm_sf2_sw_suspend(ds);
> +	dsa_switch_unregister(ds);
> +}
> +
> +static const struct component_ops bcm_sf2_component_ops = {
> +	.bind = bcm_sf2_sw_bind,
> +	.unbind = bcm_sf2_sw_unbind,
> +};
> +
> +static int bcm_sf2_sw_remove(struct platform_device *pdev)
> +{
> +	component_del(&pdev->dev, &bcm_sf2_component_ops);
>  
>  	return 0;
>  }
> -module_init(bcm_sf2_init);
>  
> -static void __exit bcm_sf2_exit(void)
> +static int bcm_sf2_sw_probe(struct platform_device *pdev)
>  {
> -	unregister_switch_driver(&bcm_sf2_switch_driver);
> +	return component_add(&pdev->dev, &bcm_sf2_component_ops);
>  }
> -module_exit(bcm_sf2_exit);
> +
> +static const struct of_device_id bcm_sf2_of_match[] = {
> +	{ .compatible = "brcm,brcm-sf2" },

As I mentioned before, this is a no go for the SF2 platforms out there
which are using the old DSA binding (incorrectly maybe, but using it)
and whose bootloader cannot be changed, but I still have a fundamental
problem with how this is approached here, my initial attempts at making
the SF2 driver a real platform driver was to take the
brcm,bcm7445-switch-v4.0 compatible string as match here, and call
dsa_of_probe() to get the old binding to populate the dsa_platform_data
structure on our behalf, and not require the "dsa" platform device to be
there at all, just some piece of code to be resident in the kernel that
exposes dsa_switch_register().

So, not really the same direction we are taking here, and as I will
reply shortly in the cover letter, the need for the special "dsa"
platform device is only an artifact now, and to catch older setups, it
does not need to exist.
-- 
Florian
