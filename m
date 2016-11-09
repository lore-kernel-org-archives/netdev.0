From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/6] net: mdio-mux: Add MDIO mux driver for NSP SoC
Date: Wed, 9 Nov 2016 15:45:15 +0100
Message-ID: <20161109144515.GF15386@lunn.ch>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
 <1478683994-12008-4-git-send-email-yendapally.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Kishon Vijay Abraham I <kishon@ti.com>,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478683994-12008-4-git-send-email-yendapally.reddy@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +#define NSP_MDIO_EXT_BUS_START_ADDR		16
> +#define NSP_MDIO_EXT_SELECT_BIT			BIT(9)
> +
> +static int mdio_mux_nsp_switch_fn(int current_child, int desired_child,
> +				  void *priv)
> +{
> +	struct nsp_mdiomux_desc *md = priv;
> +	u32 data, bus_id;
> +
> +	/* select internal or external bus */
> +	data = readl(md->mgmt_ctrl);
> +	if (desired_child == NSP_MDIO_EXT_BUS_START_ADDR)
> +		data |= NSP_MDIO_EXT_SELECT_BIT;
> +	else
> +		data &= ~NSP_MDIO_EXT_SELECT_BIT;
> +	writel(data, md->mgmt_ctrl);
> +
> +	/* select bus number */
> +	if (md->bus_ctrl) {
> +		bus_id = desired_child & (NSP_MDIO_EXT_BUS_START_ADDR - 1);
> +		writel(bus_id, md->bus_ctrl);
> +	}
> +
> +	return 0;

So address 16 is external. What happens which you try to access
address 16 internally? Does the chip raise an abort? Reads just give
0xffff?

I'm wondering if it would be better to implement this as two nested
muxes. One mux doing internal/external, and the other doing the bus.
If you do that, you can use the existing mdio-mux-mmioreg.c and don't
need any new code at all.

     Andrew
