From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/3] net: stmmac: change GMAC control register for SGMII
Date: Mon, 26 Nov 2012 11:31:24 +0100
Message-ID: <50B344FC.4070405@st.com>
References: <004b01cdc959$80af8030$820e8090$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kgene.kim@samsung.com,
	linux-kernel@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <004b01cdc959$80af8030$820e8090$%an@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/23/2012 10:04 AM, Byungho An wrote:
>
> This patch changes GMAC control register (TC(Transmit
> Configuration) and PS(Port Selection) bit for SGMII.
> In case of SGMII, TC bit is '1' and PS bit is 0.

IMO this new support that should be released for net-next and further 
effort is actually needed.

The availability of the PCS registers is given by looking at the HW 
feature register. In fact, these are optional registers.
I don't want to break the compatibility with old chips.

I do not see why we have to use Kconfig macro to select ANE etc
(as you do in your patches).
The driver could directly manage the phy device by itself if possible 
and the stmmac_init_phy should be reworked.

There are several things that need to be implemented. For example:

The ISR (e.g. priv->hw->mac->host_irq_status) should be able to manage 
these new interrupts.
The code has to be able to maintain the user interface.
For example if you want to enable ANE or manage Advertisement caps.

> Signed-off-by: Byungho An <bh74.an@samsung.com>
> ---

[snip]

> +	if (priv->phydev->interface == PHY_INTERFACE_MODE_SGMII) {
> +		value = readl(priv->ioaddr);
> +		/* GMAC_CONTROL_TC : transmit config in RGMII/SGMII */
> +		value |= 0x1000000;
> +		/* GMAC_CONTROL_PS : Port Selection for GMII */
> +		value &= ~(0x8000);
> +		writel(value, priv->ioaddr);
> +	}
> +


This parts of code have to be moved in
drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c

Pls, do not use value |= 0x1000000 but provide the appropriate defines.

>   	/* Request the IRQ lines */
>   	ret = request_irq(dev->irq, stmmac_interrupt,
>   			 IRQF_SHARED, dev->name, dev);
>
