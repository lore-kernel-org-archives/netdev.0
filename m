From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 17:15:33 +0100
Message-ID: <200611191715.34225.mb@bu3sch.de>
References: <1163802439.3392.47.camel@johannes.berg> <1163895673.15473.11.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Ivo van Doorn <ivdoorn@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:10912
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1756742AbWKSQR0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 11:17:26 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163895673.15473.11.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 19 November 2006 01:21, Johannes Berg wrote:
> If hardware shall do scanning, the hw_scan operation must be set. However,
> if the driver is for multiple cards that may or may not do hardware
> scanning, it'll need a flag.
> 
> Similar issues arise with passive_scan().
> 
> This patch introduces flags to fix these issues.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> ---
> more fallout from my earlier patches... this time it's the scanning ops
> that were still used as flags as well as ops.
> 
> --- wireless-dev.orig/include/net/d80211.h	2006-11-19 01:08:12.439520302 +0100
> +++ wireless-dev/include/net/d80211.h	2006-11-19 01:14:14.859520302 +0100
> @@ -504,6 +504,12 @@ struct ieee80211_wiphy {
>  	/* do hardware fragmentation */
>  #define IEEE80211_HW_FRAG (1<<15)
>  
> +	/* hardware does scanning instead of software */
> +#define IEEE80211_HW_PASSIVE_SCAN (1<<16)
> +
> +	/* hardware does scanning instead of software */
> +#define IEEE80211_HW_SCAN (1<<17)
> +
>  	u32 flags;			/* hardware flags defined above */
>  
>  	/* Set to the size of a needed device specific skb headroom for TX skbs. */
> @@ -627,7 +633,8 @@ struct ieee80211_ops {
>                              struct ieee80211_scan_conf *conf);
>  
>  	/* Ask the hardware to service the scan request, no need to start
> -	 * the scan state machine in stack. */
> +	 * the scan state machine in stack.
> +	 * This callback goes along with the IEEE80211_HW_SCAN flag */
>  	int (*hw_scan)(struct ieee80211_wiphy *wiphy, u8 *ssid,
>  		       size_t len);
>  
> --- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-11-19 01:07:49.509520302 +0100
> +++ wireless-dev/net/d80211/ieee80211_sta.c	2006-11-19 01:18:49.879520302 +0100
> @@ -2552,7 +2552,7 @@ int ieee80211_sta_req_scan(struct net_de
>  
>  	printk(KERN_DEBUG "%s: starting scan\n", dev->name);
>  
> -	if (local->ops->hw_scan) {
> +	if (local->ops->hw_scan && local->wiphy.flags & IEEE80211_HW_SCAN) {

Please wrap this into ()

(Hm, actually, the compiler should complain on this...)

>  		int rc = local->ops->hw_scan(local_to_wiphy(local),
>  					    ssid, ssid_len);
>  		if (!rc) {
> --- wireless-dev.orig/net/d80211/ieee80211_scan.c	2006-11-19 01:18:19.249520302 +0100
> +++ wireless-dev/net/d80211/ieee80211_scan.c	2006-11-19 01:18:22.599520302 +0100
> @@ -114,7 +114,8 @@ static void ieee80211_scan_start(struct 
>  	struct ieee80211_channel *chan = NULL;
>  	int ret;
>  
> -	if (!local->hw->passive_scan) {
> +	if (!local->ops->passive_scan ||
> +	    !(local->wiphy.flags & IEEE80211_HW_PASSIVE_SCAN)) {
>  		printk(KERN_DEBUG "%s: Scan handler called, yet the hardware "
>  		       "does not support passive scanning. Disabled.\n",
>  		       local->mdev->name);
> 
> 
> 

-- 
Greetings Michael.
