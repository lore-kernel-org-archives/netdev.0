From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH 3/3] net: macb: remove #if defined(CONFIG_ARCH_AT91)
 sections
Date: Thu, 5 Mar 2015 20:44:18 +0100
Message-ID: <20150305194418.GY3989@piout.net>
References: <1425572842-6084-1-git-send-email-boris.brezillon@free-electrons.com>
 <1425572842-6084-4-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Boris Brezillon <boris.brezillon@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1425572842-6084-4-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/03/2015 at 17:27:22 +0100, Boris Brezillon wrote :
> @@ -2388,21 +2392,20 @@ static int macb_probe(struct platform_device *pdev)
>  		bp->phy_interface = err;
>  	}
>  
> +	config = 0;
>  	if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
> -		macb_or_gem_writel(bp, USRIO, GEM_BIT(RGMII));
> -	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII)
> -#if defined(CONFIG_ARCH_AT91)
> -		macb_or_gem_writel(bp, USRIO, (MACB_BIT(RMII) |
> -					       MACB_BIT(CLKEN)));
> -#else
> -		macb_or_gem_writel(bp, USRIO, 0);
> -#endif
> -	else
> -#if defined(CONFIG_ARCH_AT91)
> -		macb_or_gem_writel(bp, USRIO, MACB_BIT(CLKEN));
> -#else
> -		macb_or_gem_writel(bp, USRIO, MACB_BIT(MII));
> -#endif
> +		config = GEM_BIT(RGMII);
> +	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII &&
> +		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> +		config = MACB_BIT(RMII);
> +	else if (bp->phy_interface == PHY_INTERFACE_MODE_MII &&

I'm not sure you should check for PHY_INTERFACE_MODE_MII here as this
may change the previous behaviour.

> +		 !(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> +		config = MACB_BIT(MII);
> +
> +	if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
> +		config |= MACB_BIT(CLKEN);
> +
> +	macb_or_gem_writel(bp, USRIO, config);
>  
>  	err = register_netdev(dev);
>  	if (err) {

-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
