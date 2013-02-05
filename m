From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] cfg80211: Fix memory leak
Date: Tue, 05 Feb 2013 11:06:06 +0100
Message-ID: <1360058766.8376.3.camel@jlt4.sipsolutions.net>
References: <1360013624-4973-1-git-send-email-Larry.Finger@lwfinger.net>
	 (sfid-20130204_223416_570378_EE2CC644)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>, mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1360013624-4973-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> (sfid-20130204_223416_570378_EE2CC644)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-02-04 at 15:33 -0600, Larry Finger wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> 
> When a driver requests a specific regulatory domain after cfg80211 already
> has one, a struct ieee80211_regdomain is leaked.

Thanks Larry!

> Johannes,
> 
> I added a From: for you as the content of this patch is yours.

I changed it back, it's really your patch, I only suggested a bit of the
code :-)

> --- a/net/wireless/reg.c
> +++ b/net/wireless/reg.c
> @@ -2189,10 +2189,14 @@ static int __set_regdom(const struct ieee80211_regdomain *rd)
>  		 * However if a driver requested this specific regulatory
>  		 * domain we keep it for its private use
>  		 */
> -		if (lr->initiator == NL80211_REGDOM_SET_BY_DRIVER)
> +		if (lr->initiator == NL80211_REGDOM_SET_BY_DRIVER) {
> +			const struct ieee80211_regdomain *tmp =
> +						get_wiphy_regdom(request_wiphy);
>  			rcu_assign_pointer(request_wiphy->regd, rd);
> -		else
> +			rcu_free_regdom(tmp);

Luis, when you get back can you please audit the other places? I'm not
convinced that there aren't more places that need to free the regdom,
but I don't really want to dig into the code right now.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
