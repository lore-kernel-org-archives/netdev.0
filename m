From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] net: bcmgenet: add support for new GENET
 PHY revision scheme
Date: Wed, 03 Dec 2014 14:23:40 +0300
Message-ID: <547EF2BC.60504@cogentembedded.com>
References: <1417562882-2511-1-git-send-email-f.fainelli@gmail.com> <1417562882-2511-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:63384 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbaLCLXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 06:23:43 -0500
Received: by mail-lb0-f179.google.com with SMTP id z11so11979543lbi.38
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 03:23:41 -0800 (PST)
In-Reply-To: <1417562882-2511-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/3/2014 2:28 AM, Florian Fainelli wrote:

> Starting with GPHY revision G0, the GENET register layout has changed to
> use the same numbering scheme as the Starfighter 2 switch. This means
> that GPHY major revision is in bits 15:12, minor in bits 11:8 and patch
> level is in bits 7:4.

> Introduce a small heuristic which checks for the old scheme first, tests
> for the new scheme and finally attempts to catch reserved values and
> aborts.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/genet/bcmgenet.c | 24 +++++++++++++++++++++++-
>   1 file changed, 23 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index f2fadb053d52..23e283174c4e 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
[...]
> @@ -2551,8 +2552,29 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
>   	 * to pass this information to the PHY driver. The PHY driver expects
>   	 * to find the PHY major revision in bits 15:8 while the GENET register
>   	 * stores that information in bits 7:0, account for that.
> +	 *
> +	 * On newer chips, starting with PHY revision G0, a new scheme is
> +	 * deployed similar to the Starfighter 2 switch with GPHY major
> +	 * revision in bits 15:8 and patch level in bits 7:0. Major revision 0
> +	 * is reserved as well as special value 0x01ff, we have a small
> +	 * heuristic to check for the new GPHY revision and re-arrange things
> +	 * so the GPHY driver is happy.
>   	 */
> -	priv->gphy_rev = (reg & 0xffff) << 8;
> +	gphy_rev = (reg & 0xffff);

    Parens not needed anymore.

> +
> +	/* This the good old scheme, just GPHY major, no minor nor patch */

    Missing "is" after "This"?

> +	if ((gphy_rev & 0xf0) != 0)
> +		priv->gphy_rev = gphy_rev << 8;
> +
> +	/* This is the new scheme, GPHY major rolls over with 0x10 = rev G0 */
> +	else if ((gphy_rev & 0xff00) != 0)
> +		priv->gphy_rev = gphy_rev;
> +
> +	/* This is reserved so should require special treatment */
> +	else if (gphy_rev == 0 || gphy_rev == 0x01ff) {
> +		pr_warn("Invalid GPHY revision detected: 0x%04x\n", gphy_rev);
> +		return;
> +	}

    Hm, {} are needed on all *if* branches.

[...]

WBR, Sergei
