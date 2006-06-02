From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix handling of authentication failure
Date: Thu, 01 Jun 2006 21:43:01 -0500
Message-ID: <447FA5B5.8020707@lwfinger.net>
References: <20060601143722.D0B2C89CF47@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:63700 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751152AbWFBCnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 22:43:06 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060601143722.D0B2C89CF47@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> My router blew up earlier, but exhibited some interesting behaviour during
> its dying moments. It was broadcasting beacons but wouldn't respond to
> any authentication requests.
>
> I noticed that softmac wasn't playing nice with this, as I couldn't make it try
> to connect to other networks after it had timed out authenticating to my ill
> router.
>
> To resolve this, I modified the softmac event/notify API to pass the event
> code to the callback, so that callbacks being notified from
> IEEE80211SOFTMAC_EVENT_ANY masks can make some judgement. In this case, the
> ieee80211softmac_assoc callback needs to make a decision based upon whether
> the association passed or failed.
>
> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> Acked-by: Johannes Berg <johannes@sipsolutions.net>
--snip--

> Index: linux/net/ieee80211/softmac/ieee80211softmac_assoc.c
> ===================================================================
> --- linux.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
> +++ linux/net/ieee80211/softmac/ieee80211softmac_assoc.c
> @@ -164,12 +164,28 @@ network_matches_request(struct ieee80211
>  }
>  
>  static void
> -ieee80211softmac_assoc_notify(struct net_device *dev, void *context)
> +ieee80211softmac_assoc_notify_scan(struct net_device *dev, int event_type, void *context)
>  {
>  	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
>  	ieee80211softmac_assoc_work((void*)mac);
>  }
>  
> +static void
> +ieee80211softmac_assoc_notify_auth(struct net_device *dev, int event_type, void *context)
> +{
> +	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
> +
> +	switch (event_type) {
> +	case IEEE80211SOFTMAC_EVENT_AUTHENTICATED:
> +		ieee80211softmac_assoc_work((void*)mac);
> +		break;
> +	case IEEE80211SOFTMAC_EVENT_AUTH_FAILED:
> +	case IEEE80211SOFTMAC_EVENT_AUTH_TIMEOUT:
> +		ieee80211softmac_disassoc(mac);
>   
This statement fails to compile on my system using Linus' tree, because 
ieee80211softmac_disassoc needs a second argument - the reason. It seems 
as if WLAN_REASON_PREV_AUTH_NOT_VALID would be appropriate.

Larry

