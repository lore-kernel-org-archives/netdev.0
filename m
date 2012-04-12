From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 08/10] mac80211: Support on-channel scan option.
Date: Thu, 12 Apr 2012 05:45:56 +0200
Message-ID: <1334202356.3788.7.camel@jlt3.sipsolutions.net>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
	 <1334166738-28243-9-git-send-email-greearb@candelatech.com>
	 (sfid-20120411_195349_401873_95D8A0F4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:52096 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757218Ab2DLDqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 23:46:31 -0400
In-Reply-To: <1334166738-28243-9-git-send-email-greearb@candelatech.com> (sfid-20120411_195349_401873_95D8A0F4)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-11 at 10:52 -0700, greearb@candelatech.com wrote:

>  static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
>  				  struct cfg80211_scan_request *req)
> @@ -438,10 +461,43 @@ static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
>  	local->scan_req = req;
>  	local->scan_sdata = sdata;
>  
> -	if (local->ops->hw_scan)
> +	if (local->ops->hw_scan) {
>  		__set_bit(SCAN_HW_SCANNING, &local->scanning);
> -	else
> -		__set_bit(SCAN_SW_SCANNING, &local->scanning);
> +	} else {
> +		/* If we are scanning only on the current channel, then
> +		 * we do not need to stop normal activities
> +		 */
> +		if ((req->n_channels == 1) &&
> +		    (req->channels[0]->center_freq ==
> +		     local->hw.conf.channel->center_freq)) {

how about "else if {", then the indentation isn't so deep and you can
have much nicer code in the entire block :)

> +			unsigned long next_delay;

please add a blank line after variable declarations.

> +		}
> +		else {

please read the coding style documentation

> @@ -672,6 +704,12 @@ void ieee80211_scan_work(struct work_struct *work)
>  
>  	sdata = local->scan_sdata;
>  
> +	/* When scanning on-channel, the first-callback means completeed. */

typo "completed"

> +	if (test_bit(SCAN_ONCHANNEL_SCANNING, &local->scanning)) {
> +		aborted = test_and_clear_bit(SCAN_ABORTED, &local->scanning);
> +		goto out_complete;
> +	}

how does the onchannel bit get cleared?

Shouldn't you be calling pre/post scan hooks?


I'm a bit divided over this. On the one hand, it seems like a mildly
useful optimisation, on the other though it adds a bunch of complexity
for multi-channel we've been thinking about... Not that we want to
support multi-channel with SW scan anyway, but still.

johannes
