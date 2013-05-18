From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/4] tg3: Add tg3_eee_pull_config() function
Date: Sat, 18 May 2013 02:05:38 +0100
Message-ID: <1368839138.3469.67.camel@deadeye.wl.decadent.org.uk>
References: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
	 <1368803990-10098-3-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7154 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab3ERBFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:05:43 -0400
In-Reply-To: <1368803990-10098-3-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 08:19 -0700, Nithin Nayak Sujir wrote:
> Add tg3_eee_pull_config() to pull the settings from the hardware and
> populate the eee structure.
> 
> If Link Flap Avoidance is enabled, we pull the eee settings from the hw
> so as not to cause a phy reset on eee config mismatch later. This
> requires moving down tg3_setup_eee() below the tg3_pull_config() to not
> trample existing settings.
> 
> Reviewed-by: Ben Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 62 +++++++++++++++++++++++++++++++------
>  1 file changed, 53 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 91efe64..75b38c4 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -2320,6 +2320,52 @@ static void tg3_phy_apply_otp(struct tg3 *tp)
>  	tg3_phy_toggle_auxctl_smdsp(tp, false);
>  }
>  
> +static void tg3_eee_pull_config(struct tg3 *tp, struct ethtool_eee *eee)
> +{
> +	u32 val;
> +	struct ethtool_eee *dest = &tp->eee;
> +
> +	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP))
> +		return;
> +
> +	if (eee)
> +		dest = eee;
> +
> +	if (tg3_phy_cl45_read(tp, MDIO_MMD_AN, TG3_CL45_D7_EEERES_STAT, &val))
> +		return;
> +
> +	/* Pull eee_active and lp_advertised. */
> +	if (val == TG3_CL45_D7_EEERES_STAT_LP_1000T ||
> +	    val == TG3_CL45_D7_EEERES_STAT_LP_100TX) {
> +		dest->eee_active = 1;
> +	} else
> +		dest->eee_active = 0;
> +
> +	if (val == TG3_CL45_D7_EEERES_STAT_LP_1000T)
> +		dest->lp_advertised = ADVERTISED_1000baseT_Full;
> +	else
> +		dest->lp_advertised = ADVERTISED_100baseT_Full;
[...]

This is wrong; you're looking at the autoneg result, not the link
partner advertising mask (7.61, MDIO_AN_EEE_LPABLE).  The link partner
might be advertising multiple modes and you should report them all
(including modes the local PHY doesn't support).  This possibly belongs
in a generic function in the mdio module.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
