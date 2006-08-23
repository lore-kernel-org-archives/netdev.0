From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 01/3] d80211:  add support for SIOCSIWRATE, SIOCSIWTXPOW
 and SIOCSIWPOWER
Date: Wed, 23 Aug 2006 17:19:08 +0200
Message-ID: <20060823171908.63c1077c@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075158.728615077@sipsolutions.net>
	<44EA501E.4010605@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:23952 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964968AbWHWPTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 11:19:12 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
In-Reply-To: <44EA501E.4010605@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 17:30:22 -0700, Mohamed Abbas wrote:
> the attached patch will add support to handle these iw_handle 
> SIOC[S/G]IWRATE, SIOC[S/G]IWTXPOW and SIOC[S/G]IWPOWER.  It also  added 
> some changes in ieee80211_ioctl_giwrange function to report supported 
> channels and rates.  a call to ieee80211_hw_config is needed to infor 
> the low level driver about these changes, I guess we might need to add 
> flag to indicate which parameters was changed so the low level driver 
> does not need to make extra calls.

I'd like adding such flags but haven't figured how to do it easily yet.
Most drivers currently solve that by keeping private copy of the last
config and configure necessary things only.

> [...]
> --- a/net/d80211/ieee80211.c
> +++ b/net/d80211/ieee80211.c
> @@ -1250,6 +1250,10 @@ static int ieee80211_tx(struct net_devic
>  			break;
>  	}
>  
> +	/* only data unicast frame */
> +	if ((tx.u.tx.rate) && !mgmt && !control->no_ack)
> +		local->last_rate = tx.u.tx.rate->rate * 100000;
> +

Are you sure you want to set this even for dropped frames? Also, you
don't filter out management and multicast/broadcast frames with that
condition.

Move this to one of tx handlers (probably ieee80211_tx_h_rate_ctrl or
ieee80211_tx_h_misc) and remove the check for tx.u.tx.rate as it's
useless there.

> [...]
> --- a/net/d80211/ieee80211_ioctl.c
> +++ b/net/d80211/ieee80211_ioctl.c
> @@ -1537,6 +1537,19 @@ static int ieee80211_ioctl_giwname(struc
>  				   char *name, char *extra)
>  {
>  	struct ieee80211_local *local = dev->ieee80211_ptr;
> +	struct ieee80211_sub_if_data *sdata;
> +
> +	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
> +        if (!local->conf.radio_enabled) {
> +        	strcpy(name, "radio off");
> +                return 0;
> +	} else if (sdata->type == IEEE80211_IF_TYPE_STA) {
> +        	if (!(sdata->u.sta.associated) ||
> +                     (sdata->u.sta.probereq_poll)) {
> +			strcpy(name, "unassociated");
> +			return 0;
> +		}
> +        }

I'm sorry, but I must NACK this hunk. Please find a better way to report
radio and association status.

>  
>  	switch (local->conf.phymode) {
>  	case MODE_IEEE80211A:
> [...]
> @@ -1580,6 +1596,42 @@ static int ieee80211_ioctl_giwrange(stru
>  	range->min_frag = 256;
>  	range->max_frag = 2346;
>  
> +	j = 0;
> +        for (i = 0; i < local->num_curr_rates ; i++) {
> +                struct ieee80211_rate *rate = &local->curr_rates[i];
> +
> +                if (rate->flags & IEEE80211_RATE_SUPPORTED) {
> +			range->bitrate[j] = rate->rate * 100000;
> +			j++;

Isn't a check for array overflow necessary here?

> +		}
> +	}
> +	range->num_bitrates = j;
> +
> +	c = 0;
> +        for (i = 0; i < local->hw->num_modes; i++) {
> +                struct ieee80211_hw_modes *mode = &local->hw->modes[i];
> +		if (skip_bg &&
> +                    ((mode->mode == MODE_IEEE80211G) ||
> +                    (mode->mode == MODE_IEEE80211B)))
> +			continue;
> +
> +		for (j = 0; 
> +		     j < mode->num_channels && c < IW_MAX_FREQUENCIES; j++) {
> +			struct ieee80211_channel *chan = &mode->channels[j];
> +
> +                        range->freq[c].i = chan->chan;
> +                        range->freq[c].m = chan->freq * 100000;
> +                        range->freq[c].e = 1;
> +			c++;
> +		}
> +		if ((mode->mode == MODE_IEEE80211G) || 
> +		    (mode->mode == MODE_IEEE80211B))
> +			skip_bg = 1;

This possibly won't report all supported frequencies if b and g ones differ.

> +
> +	}
> +        range->num_channels = c;
> +        range->num_frequency = c;
> +
>  	return 0;
>  }
>  
> @@ -2138,6 +2190,169 @@ static int ieee80211_ioctl_giwretry(stru
>  }
>  
>  
> +static int ieee80211_ioctl_siwrate(struct net_device *dev,
> +                           struct iw_request_info *info,
> +                           union iwreq_data *wrqu, char *extra)
> +{
> +        struct ieee80211_local *local = dev->ieee80211_ptr;
> +        int i, j;
> +        u32 target_rate = wrqu->bitrate.value /100000;
> +        u32 fixed;
> +	int *old_supp = local->supp_rates[local->conf.phymode];
> +	int *supp = NULL;
> +
> +        /* value = -1, fixed = 0 means auto only, so we should use
> +         * all rates offered by AP
> +         * value = X, fixed = 1 means only rate X
> +         * value = X, fixed = 0 means all rates lower equal X */
> +        if (target_rate == -1) {
> +                fixed = 0;
> +                goto apply;
> +        }
> +
> +        fixed = wrqu->bitrate.fixed;
> +	supp = (int *) kmalloc((local->num_curr_rates + 1) * 
> +					sizeof(int), GFP_KERNEL);
> +	if (!supp)
> +		return 0;
> +
> +	j = 0;
> +	for (i=0; i< local->num_curr_rates; i++) {

Use correct spacing, please.

> +		struct ieee80211_rate *rate = &local->curr_rates[i];
> +
> +		if (target_rate == rate->rate) {
> +			supp[j++] = rate->rate;
> +			break;
> +		} else if (!fixed)
> +			supp[j++] = rate->rate;

Please add a note to d80211.h that drivers are required to sort rates
ascending by their rate.

> +	}
> +
> +	supp[j] = -1;
> +
> +        if ((j >= local->num_curr_rates) || (j == 0)) {
> +                kfree(supp);
> +                supp = NULL;
> +        }

If target_rate is the highest possible rate, j will be equal to
local->num_curr_rates and you will end up with
local->supp_rates[phymode] set to NULL.

> +
> +     apply:
> +	if (!old_supp && !supp)
> +		return 0;
> +
> +        local->supp_rates[local->conf.phymode] = supp;
> +	if (old_supp)
> +        	kfree(old_supp);
> +
> +	
> +	ieee80211_prepare_rates(dev);
> +	ieee80211_hw_config(dev);

ieee80211_hw_config can return an error.

> +        return 0;
> +}

I'm not sure how this will work when intersection between supported
rates of already associated station and new supported rates is empty.
Also, management and multicast/broadcast frames need to be send at
certain rates. I'm not sure what happens when none of those rates is
enabled. But that's a more general problem, nothing to address in your
patch.

> +
> +static int ieee80211_ioctl_giwrate(struct net_device *dev,
> +                           struct iw_request_info *info,
> +                           union iwreq_data *wrqu, char *extra)
> +{
> +	struct ieee80211_local *local = dev->ieee80211_ptr;
> +        u32 max_rate = 0;
> +	int i;
> +
> +        for (i = local->num_curr_rates - 1; i >= 0 ; i--) {
> +                struct ieee80211_rate *rate = &local->curr_rates[i];
> +
> +		if (rate->flags & IEEE80211_RATE_SUPPORTED) {	
> +			max_rate = rate->rate * 100000;
> +			break;
> +		}
> +	}
> +
> +        if (max_rate >= local->last_rate)
> +                wrqu->bitrate.value = local->last_rate;
> +        else
> +                wrqu->bitrate.value = max_rate;
> +        return 0;
> +}

I'm not sure if this implementation is correct. The concept of last_rate
is totally wrong at least.

> +
> +static int ieee80211_ioctl_giwtxpow(struct net_device *dev,
> +                            struct iw_request_info *info,
> +                            union iwreq_data *wrqu, char *extra)
> +{
> +	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
> +
> +	wrqu->txpower.flags = IW_TXPOW_DBM;
> +        wrqu->txpower.fixed = 1;
> +        wrqu->txpower.disabled = (conf->radio_enabled) ? 0 : 1;
> +	wrqu->txpower.value = conf->power_level;
> +        return 0;
> +}
> +
> +
> +static int ieee80211_ioctl_siwtxpow(struct net_device *dev,
> +                            struct iw_request_info *info,
> +                            union iwreq_data *wrqu, char *extra)
> +{
> +	int rc = 0;
> +	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
> +
> +	/* we need to add flag in ieee80211_conf to mark the changed fields.
> +	*/

Remove this comment, please.

> +        if (wrqu->txpower.flags != IW_TXPOW_DBM) 
> +                rc = -EINVAL;
> +	else
> +		conf->power_level = wrqu->txpower.value;
> +        
> +
> +	ieee80211_ioctl_set_radio_enabled(dev, !wrqu->txpower.disabled);

if (!rc)
	rc = ieee80211_ioctl_set_radio_enabled(...)

> +        return rc;
> +}
> +
> +static int ieee80211_ioctl_siwpower(struct net_device *dev,
> +                            struct iw_request_info *info,
> +                            union iwreq_data *wrqu, char *extra)
> +{
> +	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
> +
> +        /* We might need to add new callback function instead of
> +           calling ieee80211_hw_config
> +	*/
> +	if (wrqu->power.disabled) {
> +		conf->power_management_enable = 0;
> +		ieee80211_hw_config(dev);
> +		return 0;
> +        }
> +
> +        if (wrqu->power.flags & IW_POWER_TYPE) 
> +                return -EOPNOTSUPP;

-EOPNOTSUPP doesn't sound right, the operation is supported, just
parameters are not. Don't know what is the best error, though. -EINVAL?

> +
> +        switch (wrqu->power.flags & IW_POWER_MODE) {
> +        case IW_POWER_ON:       /* If not specified */
> +        case IW_POWER_MODE:     /* If set all mask */
> +        case IW_POWER_ALL_R:    /* If explicitely state all */
> +                break;
> +        default:                /* Otherwise we don't support it */
> +                return -EOPNOTSUPP;

Again, not -EOPNOTSUPP.

> +        }
> +
> +	conf->power_management_enable = 1;
> +	ieee80211_hw_config(dev);

Error handling.

> +
> +        return 0;
> +}

I'd prefer more complete solution for power management, but okay, let's
change it later.

> [...]

Please, correct indentation through the whole patch (spaces to tabs).

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
