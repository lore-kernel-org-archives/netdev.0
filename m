From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [PATCH] of_mdio: fix phy interrupt passing
Date: Tue, 18 Feb 2014 09:30:24 +0000
Message-ID: <20140218093024.D0E94C403C8@trevor.secretlab.ca>
References: <1392654580-3706-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: linux-kernel@lists.codethink.co.uk, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:41255 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472AbaBRJa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 04:30:29 -0500
Received: by mail-we0-f180.google.com with SMTP id u57so11346232wes.39
        for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 01:30:28 -0800 (PST)
In-Reply-To: <1392654580-3706-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Feb 2014 16:29:40 +0000, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
> The of_mdiobus_register_phy() is not setting phy->irq this causing
> some drivers to incorrectly assume that the PHY does not have an
> IRQ associated with it or install an interrupt handler for the
> PHY.
> 
> Simplify the code setting irq and set the phy->irq at the same
> time so that the case if mdio->irq is not NULL is easier to read.
> 
> This fixes the issue:
>  net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI
> 
> to the correct:
>  net eth0: attached PHY 1 (IRQ 416) to driver Micrel KSZ8041RNLI
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> ---
>  drivers/of/of_mdio.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 875b7b6..7b3e7b0 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -44,7 +44,7 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>  {
>  	struct phy_device *phy;
>  	bool is_c45;
> -	int rc, prev_irq;
> +	int rc;
>  	u32 max_speed = 0;
>  
>  	is_c45 = of_device_is_compatible(child,
> @@ -55,11 +55,11 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>  		return 1;
>  
>  	if (mdio->irq) {
> -		prev_irq = mdio->irq[addr];
> -		mdio->irq[addr] =
> -			irq_of_parse_and_map(child, 0);
> -		if (!mdio->irq[addr])
> -			mdio->irq[addr] = prev_irq;

I cannot for the life for me remeber why the code was structured that
way. Your change is better.

> +		rc = irq_of_parse_and_map(child, 0);
> +		if (rc > 0) {
> +			mdio->irq[addr] = rc;
> +			phy->irq = rc;
> +		}
>  	}

The outer if is merely protecting against no irq array being allocated
for the bus. Would not the following be better:

	rc = irq_of_parse_and_map(child, 0);
	if (rc > 0) {
		phy->irq = rc;
		if (mdio->irq)
			mdio->irq[addr] = rc;
	}

g.
