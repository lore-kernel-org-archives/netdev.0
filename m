From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] improved statistics for bcm43xx-softmac
Date: Thu, 29 Jun 2006 16:56:50 -0400
Message-ID: <1151614610.15090.30.camel@localhost.localdomain>
References: <44A3524C.40704@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50652 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932542AbWF2U4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 16:56:45 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44A3524C.40704@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 23:08 -0500, Larry Finger wrote:
> This patch improves the statistics returned from bcm43xx_get_wireless_stats. The signal level comes
> from smoothing the rssi value returned by the firmware. The quality value is a hack derived from the
> smoothed rssi value and an assumed rssi_max of -25. If anyone has a better value, please let me
> know. The noise value is still the one calculated from the clean-room formula. On my system, this is
> roughly -65 dBm, which seems too high. I would appreciate getting any ideas on what other 
> interface/driver combinations get for the noise value.

Tentative NAK, this looks somewhat wrong...  are you _really_ getting
quality values as RSSI, or as dBm?

RSSI is usually a positive integer from 0 to some larger number.  It's
an arbitrary value and the maximum will be specific to the
chipset/radio/firmware.

dBm is usually bounded by (noise floor, 0), where noise floor is a
negative number around -100.

To me, it looks like you're trying to use dBm rather than RSSI here.  In
that case, you have to set range->max_qual.level to 0, because the upper
bound of dBm is indeed 0.  If you are using negative values _anywhere_
in your code for quality, you're almost certainly using dBm, not RSSI,
or something is very wrong.

Print out the value of 'average' from handle_irq_noise() both when close
and far away from the AP.  It looks to me like the final calculations
there come out in dBm given the fact that (a) average is negative, and
(b) that average is in the range of acceptable dBm numbers.  So:

1. set your stats->max_qual.level = 0
2. set bcm->stats.link_quality = average
3. Do link quality calculation on signal and noise; you can't just be
linear here though, since a noise floor of -100 with a signal of -90 is
in reality better than 10% signal; it's actually pretty OK.  Each -1 dBm
step near the noise floor counts for more % than a -1 dBm increase near
the best signal level.  You have to weight the bottom of the scale WRT
percentage to get values that make sense.

ipw2200 for example reports -53 dBm near the AP, with noise floor of -83
dBm in a fairly spectrum-crowded area.  That translates into what
ipw2200 reports as a 75% signal, which seems a bit off, but gives you an
idea.  You'll never get near 0 dBm, since there's already 10s of dBm
loss when the signal has to cross any air at all.

Dan

> Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>
> 
> ==========================================================
> 
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> index af97755..c80fdcd 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -1581,17 +1581,8 @@ static void handle_irq_noise(struct bcm4
> 		else
> 			average -= 48;
> 
> -/* FIXME: This is wrong, but people want fancy stats. well... */
> -bcm->stats.noise = average;
> -		if (average > -65)
> -			bcm->stats.link_quality = 0;
> -		else if (average > -75)
> -			bcm->stats.link_quality = 1;
> -		else if (average > -85)
> -			bcm->stats.link_quality = 2;
> -		else
> -			bcm->stats.link_quality = 3;
> -//		dprintk(KERN_INFO PFX "Link Quality: %u (avg was %d)\n", bcm->stats.link_quality, average);
> +/* FIXME: This matches the formula from the clean-room, but yields a value that is probably too
> large. */
> +		bcm->stats.noise = average;
>   drop_calculation:
> 		bcm->noisecalc.calculation_running = 0;
> 		return;
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> index 5c36e29..8224da1 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> @@ -47,6 +47,8 @@ #include "bcm43xx_phy.h"
>   #define BCM43xx_WX_VERSION	18
> 
>   #define MAX_WX_STRING		80
> +/* FIXME: the next line is a guess as to what the maximum value of rssi might be */
> +#define RSSI_MAX		-25
> 
> 
>   static int bcm43xx_wx_get_name(struct net_device *net_dev,
> @@ -227,15 +229,15 @@ static int bcm43xx_wx_get_rangeparams(st
> 
> 	range->max_qual.qual = 100;
> 	/* TODO: Real max RSSI */
> -	range->max_qual.level = 3;
> -	range->max_qual.noise = 100;
> -	range->max_qual.updated = 7;
> -
> -	range->avg_qual.qual = 70;
> -	range->avg_qual.level = 2;
> -	range->avg_qual.noise = 40;
> -	range->avg_qual.updated = 7;
> -
> +	range->max_qual.level = -100;
> +	range->max_qual.noise = -100;
> +	range->max_qual.updated = IW_QUAL_ALL_UPDATED;
> +
> +	range->avg_qual.qual = 50;
> +	range->avg_qual.level = -40;
> +	range->avg_qual.noise = -65;
> +	range->avg_qual.updated = IW_QUAL_ALL_UPDATED;
> +
> 	range->min_rts = BCM43xx_MIN_RTS_THRESHOLD;
> 	range->max_rts = BCM43xx_MAX_RTS_THRESHOLD;
> 	range->min_frag = MIN_FRAG_THRESHOLD;
> @@ -827,6 +829,8 @@ static struct iw_statistics *bcm43xx_get
> 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
> 	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
> 	struct iw_statistics *wstats;
> +	struct ieee80211_network *network = NULL;
> +	static int tmp_level = 0;
> 
> 	wstats = &bcm->stats.wstats;
> 	if (!mac->associated) {
> @@ -849,11 +853,19 @@ static struct iw_statistics *bcm43xx_get
> 		return wstats;
> 	}
> 	/* fill in the real statistics when iface associated */
> -	wstats->qual.qual = 100;     // TODO: get the real signal quality
> -	wstats->qual.level = 3 - bcm->stats.link_quality;
> +	list_for_each_entry(network, &mac->ieee->network_list, list) {
> +		if (!memcmp(mac->associnfo.bssid, network->bssid, ETH_ALEN)) {
> +			if (!tmp_level)		/* get initial value */
> +				tmp_level = network->stats.rssi;
> +			else			/* smooth results */
> +				tmp_level = (7 * tmp_level + network->stats.rssi)/8;
> +			break;
> +		}
> +	}
> +	wstats->qual.level = tmp_level;
> +	wstats->qual.qual = 100 + tmp_level - RSSI_MAX; // TODO: get the real signal quality
> 	wstats->qual.noise = bcm->stats.noise;
> -	wstats->qual.updated = IW_QUAL_QUAL_UPDATED | IW_QUAL_LEVEL_UPDATED |
> -		IW_QUAL_NOISE_UPDATED;
> +	wstats->qual.updated = IW_QUAL_ALL_UPDATED;
> 	wstats->discard.code = bcm->ieee->ieee_stats.rx_discards_undecryptable;
> 	wstats->discard.retries = bcm->ieee->ieee_stats.tx_retry_limit_exceeded;
> 	wstats->discard.nwid = bcm->ieee->ieee_stats.tx_discards_wrong_sa;
> 
> ==================
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

