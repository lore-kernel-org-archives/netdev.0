From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 5/7] net: ethernet: bgmac: Add platform device support
Date: Wed, 29 Jun 2016 11:51:32 -0700
Message-ID: <577418B4.2010303@gmail.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-6-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467142484-11161-6-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/28/2016 12:34 PM, Jon Mason wrote:
> The bcma portion of the driver has been split off into a bcma specific
> driver.  This has been mirrored for the platform driver.  The last
> references to the bcma core struct have been changed into a generic
> function call.  These function calls are wrappers to either the original
> bcma code or new platform functions that access the same areas via MMIO.
> This necessitated adding function pointers for both platform and bcma to
> hide which backend is being used from the generic bgmac code.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---

[snip]

> +static int bgmac_probe(struct platform_device *pdev)
> +{
> +	struct device_node *np = pdev->dev.of_node;
> +	struct bgmac *bgmac;
> +	struct resource regs;
> +	const u8 *mac_addr;
> +	int rc;
> +
> +	bgmac = kzalloc(sizeof(*bgmac), GFP_KERNEL);

You could utilize devm_kzalloc() here which simplifies the error path.

> +	if (!bgmac)
> +		return -ENOMEM;
> +
> +	platform_set_drvdata(pdev, bgmac);
> +
> +	/* Set the features of the 4707 family */
> +	bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
> +	bgmac->feature_flags |= BGMAC_FEAT_NO_RESET;
> +	bgmac->feature_flags |= BGMAC_FEAT_FORCE_SPEED_2500;
> +	bgmac->feature_flags |= BGMAC_FEAT_CMDCFG_SR_REV4;
> +	bgmac->feature_flags |= BGMAC_FEAT_TX_MASK_SETUP;
> +	bgmac->feature_flags |= BGMAC_FEAT_RX_MASK_SETUP;
> +
> +	bgmac->dev = &pdev->dev;
> +	bgmac->dma_dev = &pdev->dev;
> +
> +	mac_addr = of_get_mac_address(np);
> +	if (mac_addr)
> +		ether_addr_copy(bgmac->mac_addr, mac_addr);
> +	else
> +		dev_warn(&pdev->dev, "MAC address not present in device tree\n");
> +
> +	bgmac->irq = platform_get_irq(pdev, 0);
> +	if (bgmac->irq < 0) {
> +		rc = bgmac->irq;
> +		dev_err(&pdev->dev, "Unable to obtain IRQ\n");
> +		goto err;
> +	}
> +
> +	rc = of_address_to_resource(np, 0, &regs);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "Unable to obtain base resource\n");
> +		goto err;
> +	}

Here you could fetch the resource using a traditional
platform_get_resource(pdev, IORESOURCE_MEM, 0) and...

> +
> +	bgmac->plat.base = ioremap(regs.start, resource_size(&regs));
> +	if (!bgmac->plat.base) {
> +		dev_err(&pdev->dev, "Unable to map base resource\n");
> +		rc = -ENOMEM;
> +		goto err;
> +	}

... here do a devm_ioremap_resource(), which also does a
request_mem_region, so this shows up nicely in /proc/iomem.

> +
> +	rc = of_address_to_resource(np, 1, &regs);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "Unable to obtain idm resource\n");
> +		goto err1;
> +	}
> +
> +	bgmac->plat.idm_base = ioremap(regs.start, resource_size(&regs));
> +	if (!bgmac->plat.base) {
> +		dev_err(&pdev->dev, "Unable to map idm resource\n");
> +		rc = -ENOMEM;
> +		goto err1;
> +	}

Same here.

> +
> +	bgmac->read = platform_bgmac_read;
> +	bgmac->write = platform_bgmac_write;
> +	bgmac->idm_read = platform_bgmac_idm_read;
> +	bgmac->idm_write = platform_bgmac_idm_write;
> +	bgmac->clk_enabled = platform_bgmac_clk_enabled;
> +	bgmac->clk_enable = platform_bgmac_clk_enable;
> +	bgmac->cco_ctl_maskset = platform_bgmac_cco_ctl_maskset;
> +	bgmac->get_bus_clock = platform_bgmac_get_bus_clock;
> +	bgmac->cmn_maskset32 = platform_bgmac_cmn_maskset32;
> +
> +	rc = bgmac_enet_probe(bgmac);
> +	if (rc)
> +		goto err2;
> +
> +	return 0;
> +
> +err2:
> +	iounmap(bgmac->plat.idm_base);
> +err1:
> +	iounmap(bgmac->plat.base);
> +err:
> +	kfree(bgmac);

And with devm_* helpers none of that is needed now.
-- 
Florian
