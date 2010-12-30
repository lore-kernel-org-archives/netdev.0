From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged
 skbs
Date: Thu, 30 Dec 2010 19:52:14 +0100
Message-ID: <1293735134.21956.1.camel@jlt3.sipsolutions.net>
References: <AANLkTi=XQ2DE==ggJHfokUE1=opDVOFxQNeqwY1xZN_8@mail.gmail.com>
	 <1293708753-17728-1-git-send-email-tomas.winkler@intel.com>
	 <20101230104656.6c5a4b4e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101230104656.6c5a4b4e@nehalam>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-30 at 10:46 -0800, Stephen Hemminger wrote:

> This doesn't look correct. The calculation of the offset doesn't look correct.
> Just following the skb_clone(), the skb_pull value is "offset".
> Also, the other checks return -EINVAL for incorrectly formed packet.
> 
> --- a/net/bridge/br_multicast.c	2010-12-30 10:29:58.579510488 -0800
> +++ b/net/bridge/br_multicast.c	2010-12-30 10:43:27.273386691 -0800
> @@ -1464,6 +1464,9 @@ static int br_multicast_ipv6_rcv(struct
>  	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
>  		return 0;
>  
> +	if (!pskb_may_pull(skb, offset))
> +		return -EINVAL;
> +
>  	/* Okay, we found ICMPv6 header */
>  	skb2 = skb_clone(skb, GFP_ATOMIC);
>  	if (!skb2)

Wouldn't that make more sense after the clone anyway? But if you look at
my email, you'll find that there's potentially, and conditionally, more
stuff that will be read from the skb's header, which hasn't necessarily
been pulled in, so I think this still won't fix all the issues.

Seeing how this only affects some ICMPv6 packets, maybe we should just
use skb_copy() instead?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
