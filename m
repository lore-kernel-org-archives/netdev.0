From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH v3 4/5] net: stmmac: add a glue driver for the Amlogic
 Meson 8b / GXBB DWMAC
Date: Tue, 30 Aug 2016 12:19:06 -0700
Message-ID: <20160830191906.GD12510@codeaurora.org>
References: <20160820093538.9707-1-martin.blumenstingl@googlemail.com>
 <20160828161637.9941-1-martin.blumenstingl@googlemail.com>
 <20160828161637.9941-5-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-amlogic@lists.infradead.org, khilman@baylibre.com,
        carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, manabian@gmail.com,
        arnd@arndb.de
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58846 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbcH3TTI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 15:19:08 -0400
Content-Disposition: inline
In-Reply-To: <20160828161637.9941-5-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28, Martin Blumenstingl wrote:
> +static int meson8b_init_clk(struct meson8b_dwmac *dwmac)
> +{
> +	struct clk_init_data init;
> +	int i, ret;
> +	struct device *dev = &dwmac->pdev->dev;
> +	char clk_name[32];
> +	const char *clk_div_parents[1];
> +	const char *mux_parent_names[MUX_CLK_NUM_PARENTS];
> +	static struct clk_div_table clk_25m_div_table[] = {
> +		{ .val = 0, .div = 5 },
> +		{ .val = 1, .div = 10 },
> +		{ /* sentinel */ },
> +	};
> +
> +	/* get the mux parents from DT */
> +	for (i = 0; i < MUX_CLK_NUM_PARENTS; i++) {
> +		char name[16];
> +
> +		snprintf(name, sizeof(name), "clkin%d", i);
> +		dwmac->m250_mux_parent[i] = devm_clk_get(dev, name);
> +		if (IS_ERR(dwmac->m250_mux_parent[i])) {
> +			ret = PTR_ERR(dwmac->m250_mux_parent[i]);
> +			if (ret != -EPROBE_DEFER)
> +				dev_err(dev, "Missing clock %s\n", name);
> +			return ret;
> +		}
> +
> +		mux_parent_names[i] =
> +			__clk_get_name(dwmac->m250_mux_parent[i]);
> +	}
> +
> +	/* create the m250_mux */
> +	snprintf(clk_name, sizeof(clk_name), "%s#m250_sel", dev_name(dev));
> +	init.name = clk_name;
> +	init.ops = &clk_mux_ops;
> +	init.flags = CLK_IS_BASIC;

Please don't use this flag unless you need it.

> +	init.parent_names = mux_parent_names;
> +	init.num_parents = MUX_CLK_NUM_PARENTS;
> +
> +	dwmac->m250_mux.reg = dwmac->regs + PRG_ETH0;
> +	dwmac->m250_mux.shift = PRG_ETH0_CLK_M250_SEL_SHIFT;
> +	dwmac->m250_mux.mask = PRG_ETH0_CLK_M250_SEL_MASK;
> +	dwmac->m250_mux.flags = 0;
> +	dwmac->m250_mux.table = NULL;
> +	dwmac->m250_mux.hw.init = &init;
> +
> +	dwmac->m250_mux_clk = devm_clk_register(dev, &dwmac->m250_mux.hw);
> +	if (WARN_ON(PTR_ERR_OR_ZERO(dwmac->m250_mux_clk)))

Why not if(WARN_ON(IS_ERR())? The OR_ZERO part seems confusing.

> +		return PTR_ERR(dwmac->m250_mux_clk);
> +
> +	/* create the m250_div */
> +	snprintf(clk_name, sizeof(clk_name), "%s#m250_div", dev_name(dev));
> +	init.name = devm_kstrdup(dev, clk_name, GFP_KERNEL);
> +	init.ops = &clk_divider_ops;
> +	init.flags = CLK_IS_BASIC | CLK_SET_RATE_PARENT;
> +	clk_div_parents[0] = __clk_get_name(dwmac->m250_mux_clk);
> +	init.parent_names = clk_div_parents;
> +	init.num_parents = ARRAY_SIZE(clk_div_parents);
> +
> +	dwmac->m250_div.reg = dwmac->regs + PRG_ETH0;
> +	dwmac->m250_div.shift = PRG_ETH0_CLK_M250_DIV_SHIFT;
> +	dwmac->m250_div.width = PRG_ETH0_CLK_M250_DIV_WIDTH;
> +	dwmac->m250_div.hw.init = &init;
> +	dwmac->m250_div.flags = CLK_DIVIDER_ONE_BASED | CLK_DIVIDER_ALLOW_ZERO;
> +
> +	dwmac->m250_div_clk = devm_clk_register(dev, &dwmac->m250_div.hw);

We've been trying to move away from devm_clk_register() to
devm_clk_hw_register() so that clk providers aren't also clk
consumers. Obviously in this case this driver is a provider and a
consumer, so this isn't as important. Kevin did something similar
in the mmc driver, so I'll reiterate what I said on that patch.
Perhaps we should make __clk_create_clk() into a real clk
provider API so that we can use devm_clk_hw_register() here and
then generate a clk for this device. That would allow us to have
proper consumer tracking without relying on the clk that is
returned from clk_register() (the intent is to make that clk
instance internal to the framework).

> +	if (WARN_ON(PTR_ERR_OR_ZERO(dwmac->m250_div_clk)))
> +		return PTR_ERR(dwmac->m250_div_clk);
> +
> +	/* create the m25_div */
> +	snprintf(clk_name, sizeof(clk_name), "%s#m25_div", dev_name(dev));
> +	init.name = devm_kstrdup(dev, clk_name, GFP_KERNEL);
> +	init.ops = &clk_divider_ops;
> +	init.flags = CLK_IS_BASIC | CLK_SET_RATE_PARENT;
> +	clk_div_parents[0] = __clk_get_name(dwmac->m250_div_clk);
> +	init.parent_names = clk_div_parents;
> +	init.num_parents = ARRAY_SIZE(clk_div_parents);
> +
> +	dwmac->m25_div.reg = dwmac->regs + PRG_ETH0;
> +	dwmac->m25_div.shift = PRG_ETH0_CLK_M25_DIV_SHIFT;
> +	dwmac->m25_div.width = PRG_ETH0_CLK_M25_DIV_WIDTH;
> +	dwmac->m25_div.table = clk_25m_div_table;
> +	dwmac->m25_div.hw.init = &init;
> +	dwmac->m25_div.flags = CLK_DIVIDER_ALLOW_ZERO;
> +
> +	dwmac->m25_div_clk = devm_clk_register(dev, &dwmac->m25_div.hw);
> +	if (WARN_ON(PTR_ERR_OR_ZERO(dwmac->m25_div_clk)))
> +		return PTR_ERR(dwmac->m25_div_clk);
> +
> +	return 0;

This could be return WARN_ON(PTR_ERR_OR_ZERO(...))

> +
> +static int meson8b_dwmac_probe(struct platform_device *pdev)
> +{
> +	struct plat_stmmacenet_data *plat_dat;
> +	struct stmmac_resources stmmac_res;
> +	struct resource *res;
> +	struct meson8b_dwmac *dwmac;
> +	int ret;
> +
> +	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
> +	if (ret)
> +		return ret;
> +
> +	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
> +	if (IS_ERR(plat_dat))
> +		return PTR_ERR(plat_dat);
> +
> +	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
> +	if (!dwmac)
> +		return -ENOMEM;
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +	if (!res)
> +		return -ENODEV;
> +

You can drop the above two lines and just call
devm_ioremap_resource().

> +	dwmac->regs = devm_ioremap_resource(&pdev->dev, res);

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
