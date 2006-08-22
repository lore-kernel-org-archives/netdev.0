From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] Add wireless statics to bcm43xx-d80211
Date: Tue, 22 Aug 2006 16:09:57 +0200
Message-ID: <20060822160957.61a4e9ba@griffin.suse.cz>
References: <44E07AA4.8040309@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:28844 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932262AbWHVOJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 10:09:59 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44E07AA4.8040309@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Aug 2006 08:29:08 -0500, Larry Finger wrote:
> This patch implements wireless statistics for bcm43xx using the d80211 stack.It 
> also sets a framework for the implementation in other drivers that use the 
> d80211 code. The component parts have been circulated on the netdev mailing 
> list, and all suggested changes have been incorporated. The specific changes are 
> as follows:

Please, separate the d80211 part and the bcm43xx-d80211 part into
two patches.

> --- a/include/net/d80211.h
> +++ b/include/net/d80211.h
> @@ -205,6 +205,9 @@ struct ieee80211_rx_status {
>          int channel;
>          int phymode;
>          int ssi;
> +	int maxssi;

Why is maxssi here? Can it really change between received frames?

> [...]
> --- a/net/d80211/ieee80211.c
> +++ b/net/d80211/ieee80211.c
> @@ -3174,6 +3174,9 @@ ieee80211_rx_h_sta_process(struct ieee80
>  	sta->rx_fragments++;
>  	sta->rx_bytes += rx->skb->len;
>  	sta->last_rssi = rx->u.rx.status->ssi;
> +	sta->last_signal = rx->u.rx.status->signal;
> +	sta->last_noise = rx->u.rx.status->noise;
> +	sta->max_rssi = rx->u.rx.status->maxssi;

Again, I see no reason why max_rssi should be in sta structure.

> [...]
> --- a/net/d80211/ieee80211_i.h
> +++ b/net/d80211/ieee80211_i.h
> @@ -337,6 +337,9 @@ struct ieee80211_local {
>  	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
>  	int open_count;
>  	int monitors;
> +	int link_quality;
> +	int noise;
> +	struct iw_statistics wstats;

Why are these three variables in ieee80211_local? They are not used
anywhere.

> [...]
> --- a/net/d80211/ieee80211_ioctl.c
> +++ b/net/d80211/ieee80211_ioctl.c
> @@ -1580,6 +1580,16 @@ static int ieee80211_ioctl_giwrange(stru
>  	range->min_frag = 256;
>  	range->max_frag = 2346;
>  
> +	range->max_qual.qual = 100;
> +	range->max_qual.level = 152;  /* set floor at -104 dBm (152 - 256) */

I would suggest using -110 dBm as a floor (to be compatible with RCPI
definition, see mail from Simon Barber describing it). Or is there any
particular reason for -104 dBm?

> [...]
> --- a/net/d80211/sta_info.h
> +++ b/net/d80211/sta_info.h
> @@ -82,6 +82,9 @@ struct sta_info {
>  	unsigned long rx_dropped; /* number of dropped MPDUs from this STA */
>  
>  	int last_rssi; /* RSSI of last received frame from this STA */
> +	int last_signal; /* signal of last received frame from this STA */
> +	int last_noise; /* noise of last received frame from this STA */

Add these two variables also to sysfs, please.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
