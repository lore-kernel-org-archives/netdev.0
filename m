From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/3] cxgb3: add support for the Aquantia
 10G-BT phy
Date: Sat, 30 May 2009 04:39:04 +0100
Message-ID: <1243654744.3818.18.camel@deadeye>
References: <20090529225236.27382.32365.stgit@speedy5>
	 <20090529225249.27382.37135.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44637 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753212AbZE3Djw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 23:39:52 -0400
In-Reply-To: <20090529225249.27382.37135.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-29 at 15:52 -0700, Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Add support for the Aquantia AQ1002 10G-BaseT phy.

It's in production, then?

[...]
> +enum {
> +	/* MDIO_DEV_PMA_PMD registers */
> +	AQ_LINK_STAT	= 0xe800,
> +	AQ_IMASK_PMA	= 0xf000,
> +
> +	/* MDIO_DEV_XGXS registers */
> +	AQ_XAUI_RX_CFG	= 0xc400,
> +	AQ_XAUI_TX_CFG	= 0xe400,
> +
> +	/* MDIO_DEV_ANEG registers */
> +	AQ_100M_CTRL	= 0x0010,

= MDIO_AN_ADVERTISE

> +	AQ_10G_CTRL	= 0x0020,

= MDIO_AN_10GBT_CTRL

> +	AQ_1G_CTRL	= 0xc400,
> +	AQ_ANEG_STAT	= 0xc800,
> +
> +	/* MDIO_DEV_VEND1 registers */
> +	AQ_FW_VERSION	= 0x0020,
> +	AQ_IFLAG_GLOBAL	= 0xfc00,
> +	AQ_IMASK_GLOBAL	= 0xff00,
> +};
> +
> +#define AQBIT(x)	(1 << (x))

Seems a bit pointless.

> +#define IMASK_PMA	AQBIT(0x2)
> +#define IMASK_GLOBAL	AQBIT(0xf)
> +#define ADV_1G_FULL	AQBIT(0xf)
> +#define ADV_1G_HALF	AQBIT(0xe)
> +#define ADV_10G_FULL	AQBIT(0xc)

= MDIO_AN_10GBT_CTRL_ADV10G

[...]
> +static int aq100x_advertise(struct cphy *phy, unsigned int advertise_map)
> +{
> +	unsigned int adv;
> +	int err;
> +
> +	/* 10G advertisement */
> +	adv = 0;
> +	if (advertise_map & ADVERTISED_10000baseT_Full)
> +		adv |= ADV_10G_FULL;
> +	err = t3_mdio_change_bits(phy, MDIO_MMD_AN, AQ_10G_CTRL,
> +				  ADV_10G_FULL, adv);
> +	if (err)
> +		return err;
> +
> +	/* 1G advertisement */
> +	adv = 0;
> +	if (advertise_map & ADVERTISED_1000baseT_Full)
> +		adv |= ADV_1G_FULL;
> +	if (advertise_map & ADVERTISED_1000baseT_Half)
> +		adv |= ADV_1G_HALF;
> +	err = t3_mdio_change_bits(phy, MDIO_MMD_AN, AQ_1G_CTRL,
> +				  ADV_1G_FULL | ADV_1G_HALF, adv);
> +	if (err)
> +		return err;
> +
> +	/* 100M, pause advertisement */
> +	adv = 0;
> +	if (advertise_map & ADVERTISED_100baseT_Half)
> +		adv |= ADVERTISE_100HALF;
> +	if (advertise_map & ADVERTISED_100baseT_Full)
> +		adv |= ADVERTISE_100FULL;
> +	if (advertise_map & ADVERTISED_Pause)
> +		adv |= ADVERTISE_PAUSE_CAP;
> +	if (advertise_map & ADVERTISED_Asym_Pause)
> +		adv |= ADVERTISE_PAUSE_ASYM;

None of these flags are reported as "supported".

[...]
> +int t3_aq100x_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
> +		       const struct mdio_ops *mdio_ops)
> +{
> +	unsigned int v, v2, gpio, wait;
> +	int err;
> +
> +	cphy_init(phy, adapter, phy_addr, &aq100x_ops, mdio_ops,
> +		  SUPPORTED_1000baseT_Full | SUPPORTED_10000baseT_Full |
> +		  SUPPORTED_Autoneg | SUPPORTED_AUI, "1000/10GBASE-T");
[...]

AUI?!

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
