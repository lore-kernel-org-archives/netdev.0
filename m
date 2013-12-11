From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [PATCH 3/7] net: of_mdio: do not overwrite PHY interrupt configuration
Date: Wed, 11 Dec 2013 13:57:00 +0000
Message-ID: <20131211135700.BDB3FC4061A@trevor.secretlab.ca>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org> < 1386283936-26104-4-git-send-email-florian@openwrt.org>
Cc: davem@davemloft.net, devicetree@vger.kernel.org,
	abrodkin@synopsys.com, rob.herring@calxeda.com,
	mark.rutland@arm.com, sebastian.hesselbarth@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:53408 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab3LKN5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 08:57:06 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so2942056eaj.7
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 05:57:04 -0800 (PST)
In-Reply-To: <1386283936-26104-4-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Dec 2013 14:52:12 -0800, Florian Fainelli <florian@openwrt.org> wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> 
> If irq_of_parse_and_map fails to find an interrupt line for a given PHY,
> we will force the PHY interrupt to be PHY_POLL, completely overriding
> the previous value that the MDIO bus may have set for us (e.g:
> PHY_IGNORE_INTERRUPT). In case of failure, just restore the previous
> value.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/of/of_mdio.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index f93ebca..4923ab2 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -27,7 +27,7 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>  {
>  	struct phy_device *phy;
>  	bool is_c45;
> -	int rc;
> +	int rc, prev_irq;
>  
>  	is_c45 = of_device_is_compatible(child,
>  					 "ethernet-phy-ieee802.3-c45");
> @@ -37,10 +37,11 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>  		return 1;
>  
>  	if (mdio->irq) {
> +		prev_irq= mdio->irq[addr];
>  		mdio->irq[addr] =
>  			irq_of_parse_and_map(child, 0);
>  		if (!mdio->irq[addr])
> -			mdio->irq[addr] = PHY_POLL;
> +			mdio->irq[addr] = prev_irq;
>  	}

Nit, the logic is a little weird the way it is written after the change.
I'd rather see:

	if (mdio->irq) {
		irq = irq_of_parse_and_map(child, 0);
		if (irq)
			mdio->irq[addr] = irq;
	}

Or even more concise:

	if (mdio->irq && irq = irq_of_parse_and_map(child, 0))
		mdio->irq[addr] = irq;

g.

Regardless,

Acked-by: Grant Likely <grant.likely@linaro.org>

g.
