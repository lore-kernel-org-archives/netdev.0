From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] of_mdio: fix phy interrupt passing
Date: Tue, 18 Feb 2014 23:29:14 +0300
Message-ID: <5303C29A.6080200@cogentembedded.com>
References: <1392725818-558-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>, grant.likely@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392725818-558-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/18/2014 03:16 PM, Ben Dooks wrote:

> The of_mdiobus_register_phy() is not setting phy->irq thus causing
> some drivers to incorrectly assume that the PHY does not have an
> IRQ associated with it. Not only do some drivers report no IRQ
> they do not install an interrupt handler for the PHY.

> Simplify the code setting irq and set the phy->irq at the same
> time so that we cover the following issues, which should cover
> all the cases the code will find:

> - Set phy->irq if node has irq property and mdio->irq is NULL
> - Set phy->irq if node has no irq and mdio->irq is not NULL
> - Leave phy->irq as PHY_POLL default if none of the above

> This fixes the issue:
>   net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI

> to the correct:
>   net eth0: attached PHY 1 (IRQ 416) to driver Micrel KSZ8041RNLI

> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

[...]

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 875b7b6..46d95fc 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
[...]
> @@ -54,12 +54,14 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>   	if (!phy || IS_ERR(phy))
>   		return 1;
>
> -	if (mdio->irq) {
> -		prev_irq = mdio->irq[addr];
> -		mdio->irq[addr] =
> -			irq_of_parse_and_map(child, 0);
> -		if (!mdio->irq[addr])
> -			mdio->irq[addr] = prev_irq;
> +	rc = irq_of_parse_and_map(child, 0);
> +	if (rc > 0) {
> +		phy->irq = rc;
> +		if (mdio->irq)
> +			mdio->irq[addr] = rc;
> +	} else {
> +		if (mdio->irq)
> +			phy->irq = mdio->irq[addr];

    I have now looked thru the of_mdio.c code and the code it calls.
    This case seems to be cared about by phy_device_create() called earlier 
via get_phy_device() call just above this hunk; in any case the value will be 
PHY_POLL. I don't think this branch is needed at all.

WBR, Sergei
