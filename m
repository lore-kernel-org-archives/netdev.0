From: Kevin Hilman <khilman@baylibre.com>
Subject: Re: [PATCH 2/3] net: stmmac: add a glue driver for the Amlogic Meson 8b / GXBB DWMAC
Date: Fri, 19 Aug 2016 14:40:00 -0700
Message-ID: <7hshu0780f.fsf@baylibre.com>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
        <20160815164100.27766-1-martin.blumenstingl@googlemail.com>
        <20160815164100.27766-3-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-amlogic@lists.infradead.org, carlo@caione.org,
        mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34177 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754947AbcHSVkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 17:40:02 -0400
Received: by mail-pf0-f175.google.com with SMTP id p64so12927386pfb.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 14:40:02 -0700 (PDT)
In-Reply-To: <20160815164100.27766-3-martin.blumenstingl@googlemail.com>
        (Martin Blumenstingl's message of "Mon, 15 Aug 2016 18:40:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Blumenstingl <martin.blumenstingl@googlemail.com> writes:

> The Ethernet controller available in Meson8b and GXBB SoCs is a Synopsys
> DesignWare MAC IP core which is already supported by the stmmac driver.
>
> In addition to the standard stmmac driver some Meson8b / GXBB specific
> registers have to be configured for the PHY clocks. These SoC specific
> registers are called PRG_ETHERNET_ADDR0 and PRG_ETHERNET_ADDR1 in the
> datasheet.
> These registers are not backwards compatible with those on Meson 6b,
> which is why a new glue driver is introduced. This worked for many
> boards because the bootloader programs the PRG_ETHERNET registers
> correctly. Additionally the meson6-dwmac driver only sets bit 1 of
> PRG_ETHERNET_ADDR0 which (according to the datasheet) is only used
> during reset.
>
> Currently all configuration values can be determined automatically,
> based on the configured phy-mode (which is mandatory for the stmmac
> driver). If required the tx-delay and the mux clock (so it supports
> the MPLL2 clock as well) can be made configurable in the future.
>
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>

[...]

> +static int meson8b_init_clk(struct meson8b_dwmac *dwmac)
> +{
> +	struct clk_init_data init;
> +	int i, ret;
> +	struct device *dev = &dwmac->pdev->dev;
> +	char clk_name[32];
> +	const char *clk_div_parents[1];
> +	const char *mux_parent_names[MUX_CLK_NUM_PARENTS];
> +	unsigned int mux_parent_count = 0;
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
> +			/* NOTE: the second clock (MP2) is unused on all known

nit: multi-line comment style  (c.f. Documentation/CodingStyle search
for "multi-line")

> +			 * boards, thus we're making it optional here.
> +			 */
> +			if (i > 0)
> +				continue;

IMO, this is a bit confusing.  I think this should either be coded to
deal with an optional "clkin1" (preferred), or it should be coded to
without a mux and clkin0 is directly the parent of the divider.  The
current way of always bailing out of this loop early is a bit confusing.

> +			ret = PTR_ERR(dwmac->m250_mux_parent[i]);
> +			if (ret != -EPROBE_DEFER)
> +				dev_err(dev, "Missing clock %s\n", name);
> +			dwmac->m250_mux_parent[i] = NULL;
> +			return ret;
> +		}
> +
> +		mux_parent_names[i] =
> +			__clk_get_name(dwmac->m250_mux_parent[i]);
> +		mux_parent_count++;
> +	}
> +
> +	/* create the m250_mux */
> +	snprintf(clk_name, sizeof(clk_name), "%s#m250_sel", dev_name(dev));
> +	init.name = clk_name;
> +	init.ops = &clk_mux_ops;
> +	init.flags = CLK_IS_BASIC;
> +	init.parent_names = mux_parent_names;
> +	init.num_parents = mux_parent_count;
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
> +		return PTR_ERR(dwmac->m250_mux_clk);
> +
> +	/* create the m250_div */
> +	snprintf(clk_name, sizeof(clk_name), "%s#m250_div", dev_name(dev));
> +	init.name = devm_kstrdup(dev, clk_name, GFP_KERNEL);
> +	init.ops = &clk_divider_ops;
> +	init.flags = CLK_IS_BASIC | CLK_SET_RATE_PARENT;

hmm, with CLK_SET_RATE_PARENT that implies that it might switch the mux,
but it's hard-coded above so the mux only ever has one parent, so that
can never happen.

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
> +}
> +
> +static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
> +{
> +	int ret;
> +	unsigned long clk_rate;
> +
> +	switch (dwmac->phy_mode) {
> +	case PHY_INTERFACE_MODE_RGMII:
> +	case PHY_INTERFACE_MODE_RGMII_ID:
> +	case PHY_INTERFACE_MODE_RGMII_RXID:
> +	case PHY_INTERFACE_MODE_RGMII_TXID:
> +		/* Generate a 25MHz clock for the PHY */
> +		clk_rate = 25 * 1000 * 1000;
> +
> +		/* enable RGMII mode */
> +		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_RGMII_MODE,
> +					PRG_ETH0_RGMII_MODE);
> +
> +		/* only relevant for RMII mode -> disable in RGMII mode */
> +		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0,
> +					PRG_ETH0_INVERTED_RMII_CLK, 0);
> +
> +		/* TX clock delay - all known boards use a 1/4 cycle delay */
> +		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TXDLY_MASK,
> +					PRG_ETH0_TXDLY_QUARTER);
> +		break;
> +
> +	case PHY_INTERFACE_MODE_RMII:
> +		/* Use the rate of the mux clock for the internal RMII PHY */
> +		clk_rate = clk_get_rate(dwmac->m250_mux_clk);
> +
> +		/* disable RGMII mode -> enables RMII mode */
> +		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_RGMII_MODE,
> +					0);
> +
> +		/* invert internal clk_rmii_i to generate 25/2.5 tx_rx_clk */
> +		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0,
> +					PRG_ETH0_INVERTED_RMII_CLK,
> +					PRG_ETH0_INVERTED_RMII_CLK);
> +
> +		/* TX clock delay cannot be configured in RMII mode */
> +		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TXDLY_MASK,
> +					0);
> +
> +		break;
> +
> +	default:
> +		dev_err(&dwmac->pdev->dev, "unsupported phy-mode %s\n",
> +			phy_modes(dwmac->phy_mode));
> +		return -EINVAL;
> +	}
> +
> +	ret = clk_prepare_enable(dwmac->m25_div_clk);
> +	if (ret) {
> +		dev_err(&dwmac->pdev->dev, "failed to enable the PHY clock\n");
> +		return ret;
> +	}
> +
> +	ret = clk_set_rate(dwmac->m25_div_clk, clk_rate);
> +	if (ret) {
> +		clk_disable_unprepare(dwmac->m25_div_clk);
> +
> +		dev_err(&dwmac->pdev->dev, "failed to set PHY clock\n");
> +		return ret;
> +	}

In the case of success, the clock is never disabled/unprepared.   You
probably need a .remove function which disables the clock and then calls
stmmac_pltfr_remove.

> +	/* enable TX_CLK and PHY_REF_CLK generator */
> +	meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TX_AND_PHY_REF_CLK,
> +				PRG_ETH0_TX_AND_PHY_REF_CLK);
> +
> +	return 0;
> +}

[...]

Otherwise, this is looking good.

Also, I tested on meson-gxbb-odroidc2 and meson-gxbb-p200 by booting a debian
root filesystem over NFS and all was well.

Tested-by: Kevin Hilman <khilman@baylibre.com>

Kevin
