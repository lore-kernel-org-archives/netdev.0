From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: don't overwrite useful bits in advertising
 bitfield
Date: Mon, 20 Aug 2012 16:22:58 +0100
Message-ID: <1345476178.2659.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344953745-13208-1-git-send-email-johangu@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <starvik@axis.com>
To: Johan Gunnarsson <johan.gunnarsson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62946 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757005Ab2HTPXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 11:23:03 -0400
In-Reply-To: <1344953745-13208-1-git-send-email-johangu@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-14 at 16:15 +0200, Johan Gunnarsson wrote:
> There are bits in this bitfield that we want to leave untouched (PAUSE
> and ASYM_PAUSE bits) when changing other bits (speed and duplex bits.)
> Previously, these were always overwritten to zero when running commands
> like "ethtool -s eth0 speed 10 duplex full autoneg off".

This is right in principle, but the implementation isn't quite right.

> Signed-off-by: Johan Gunnarsson <johangu@axis.com>
> ---
>  ethtool.c |   45 +++++++++++++++++++++++++++++++--------------
>  1 file changed, 31 insertions(+), 14 deletions(-)
> 
> diff --git a/ethtool.c b/ethtool.c
> index e573357..efa12c7 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -46,6 +46,18 @@
>  #define MAX_ADDR_LEN	32
>  #endif
>  
> +#define ALL_ADVERTISED_MODES \
> +	(ADVERTISED_10baseT_Half | \
> +	 ADVERTISED_10baseT_Full | \
> +	 ADVERTISED_100baseT_Half | \
> +	 ADVERTISED_100baseT_Full | \
> +	 ADVERTISED_1000baseT_Half | \
> +	 ADVERTISED_1000baseT_Full | \
> +	 ADVERTISED_2500baseX_Full | \
> +	 ADVERTISED_10000baseT_Full | \
> +	 ADVERTISED_20000baseMLD2_Full | \
> +	 ADVERTISED_20000baseKR2_Full)

This is missing the new 40G modes (not a regression, I realise).

[...]
> @@ -2405,19 +2421,20 @@ static int do_sset(struct cmd_context *ctx)
>  			}
>  			if (autoneg_wanted == AUTONEG_ENABLE &&
>  			    advertising_wanted == 0) {
> -				ecmd.advertising = ecmd.supported &
> -					(ADVERTISED_10baseT_Half |
> -					 ADVERTISED_10baseT_Full |
> -					 ADVERTISED_100baseT_Half |
> -					 ADVERTISED_100baseT_Full |
> -					 ADVERTISED_1000baseT_Half |
> -					 ADVERTISED_1000baseT_Full |
> -					 ADVERTISED_2500baseX_Full |
> -					 ADVERTISED_10000baseT_Full |
> -					 ADVERTISED_20000baseMLD2_Full |
> -					 ADVERTISED_20000baseKR2_Full);
> +				/* Auto negotation enabled, but with
> +				 * unspecified speed and duplex: enable all
> +				 * supported speeds and duplexes.
> +				 */
> +				ecmd.advertising = (ecmd.advertising &
> +					~ALL_ADVERTISED_MODES) |
> +					(ALL_ADVERTISED_MODES & ecmd.supported);

Perhaps we should also warn if there's a 'supported' flag we don't
recognise, because we don't know whether it's a link mode and we might
be failing to enable/disable it as requested.

>  			} else if (advertising_wanted > 0) {
> -				ecmd.advertising = advertising_wanted;
> +				/* Enable all requested modes */
> +				ecmd.advertising = (ecmd.advertising &
> +					~ALL_ADVERTISED_MODES) |
> +					(advertising_wanted & ecmd.supported);

I don't think the '& ecmd.supported' here is right.  If an autoneg
device supports some new link mode L that is not in
ALL_ADVERTISED_MODES, but not link mode M which the user requested, then
this can silently fail because the resulting advertising mask will
include L but not M.

We should either use advertising_wanted unmasked and let the driver
validate it, or report an error if it's not present in the supported
mask.  I think we should be consistent with the following case, i.e. let
the driver validate it.

Ben.

> +			} else if (full_advertising_wanted > 0) {
> +				ecmd.advertising = full_advertising_wanted;
>  			}
>  
>  			/* Try to perform the update. */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
