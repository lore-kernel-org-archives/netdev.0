From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Wed, 30 Aug 2006 10:19:19 -0700
Message-ID: <20060830171919.GC18041@instant802.com>
References: <44F355EE.3090607@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-51.dex002.intermedia.net ([64.78.21.150]:39598 "EHLO
	DHOST002-51.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751177AbWH3RT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 13:19:26 -0400
To: mabbas <mabbas@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <44F355EE.3090607@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2006 at 01:45:34PM -0700, mabbas wrote:

> This patch modify d80211 to add SIOCSIWRATE and SIOCGIWRATE
> commands. this patch almost does the same thing as in 
> PRISM2_HOSTAPD_SET_RATE_SETS.

I don't think I would like to get this applied since this seems to be
changing the design on how the per-STA TX rate limiting is done in a
way that does not match the original design and no justification has
been given for that change so far. Some comments below.


> --- a/net/d80211/ieee80211_i.h
> @@ -280,6 +280,9 @@ #define IEEE80211_AUTH_ALG_LEAP BIT(2)
>     struct sk_buff *probe_resp; /* ProbeResp template for IBSS */
>     u32 supp_rates_bits;
>  
> +	u32 last_rate; /* last tx data rate value. management and multi cast frame
> +			* wont be used. */

Is this information valuable enough to collect with all the extra code
in ieee80211_tx_h_rate_ctrl()? The last rate can be fetched from the STA
entry. It won't be the exact same value as this one here, but then
again, I don't really see much point in reporting the last used TX rate
since it can be changing a lot. Some sort of average over the last N
frames could be more useful information to collect, if that level of
detail is needed.


> --- a/net/d80211/ieee80211_ioctl.c
> +++ b/net/d80211/ieee80211_ioctl.c
> @@ -2138,6 +2138,103 @@ static int ieee80211_ioctl_giwretry(stru
>  	return 0;
>  }
>  
> +static int ieee80211_ioctl_siwrate(struct net_device *dev,
> +                                struct iw_request_info *info,
> +                                union iwreq_data *wrqu, char *extra)
> +{
> +	struct ieee80211_local *local = dev->ieee80211_ptr;
> +	int i, j;
> +	u32 target_rate = wrqu->bitrate.value /100000;
> +	u32 fixed;
> +	int *old_supp = local->supp_rates[local->conf.phymode];
> +	int *supp = NULL;
> +
> +	/* value = -1, fixed = 0 means auto only, so we should use
> +	 * all rates offered by AP
> +	 * value = X, fixed = 1 means only rate X
> +	* value = X, fixed = 0 means all rates lower equal X */

Please keep in mind that this function can also be called in AP mode.

> +	fixed = wrqu->bitrate.fixed;
> +	supp = (int *) kmalloc((local->num_curr_rates + 1) *
> +					sizeof(int), GFP_KERNEL);
> +	if (!supp)
> +		return 0;

return -ENOMEM

> +	j = 0;
> +	for (i=0; i< local->num_curr_rates; i++) {
> +		struct ieee80211_rate *rate = &local->curr_rates[i];
> +
> +		if (target_rate == rate->rate) {
> +			supp[j++] = rate->rate;
> +			break;
> +		} else if (!fixed)
> +			supp[j++] = rate->rate;
> +	}

This can allow number of invalid configurations; especially so, since
there is no synchronization with basic reate sets here. In addition, I
would not really want to change the supported/basic rate sets this way.
If there is desire to limit what rates the TX rate control algorithm is
using, this should be done by modifying per-STA entry data
(sta->supp_rates), not the per-radio rate table.

> +	/* number of supported rate equal to all current supported rate
> +	 * this equal like supp_rates = NULL so save process time and set
> +	* supp to NULL
> +	*/
> +	if ((j >= local->num_curr_rates) || (j == 0)) {
> +		kfree(supp);
> +		supp = NULL;

Shouldn't these return an error and not replace the current rate
configuration?

> +	if (old_supp)
> +		kfree(old_supp);

No need for 'if (old_supp)' before calling kfree(old_supp).

-- 
Jouni Malinen                                            PGP id EFC895FA
