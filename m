From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Fix preferred_lft not updating in some cases
Date: Fri, 27 Sep 2013 10:16:04 +0200
Message-ID: <20130927081604.GB28287@order.stressinduktion.org>
References: <1380147175-14874-1-git-send-email-pmarks@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, lorenzo@google.com
To: Paul Marks <pmarks@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54593 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab3I0IQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 04:16:06 -0400
Content-Disposition: inline
In-Reply-To: <1380147175-14874-1-git-send-email-pmarks@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 03:12:55PM -0700, Paul Marks wrote:
> Consider the scenario where an IPv6 router is advertising a fixed
> preferred_lft of 1800 seconds, while the valid_lft begins at 3600
> seconds and counts down in realtime.
> 
> A client should reset its preferred_lft to 1800 every time the RA is
> received, but a bug is causing Linux to ignore the update.
> 
> The core problem is here:
>   if (prefered_lft != ifp->prefered_lft) {
> 
> Note that ifp->prefered_lft is an offset, so it doesn't decrease over
> time.  Thus, the comparison is always (1800 != 1800), which fails to
> trigger an update.
> 
> The most direct solution would be to compute a "stored_prefered_lft",
> and use that value in the comparison.  But I think that trying to filter
> out unnecessary updates here is a premature optimization.  In order for
> the filter to apply, both of these would need to hold:
> 
>   - The advertised valid_lft and preferred_lft are both declining in
>     real time.
>   - No clock skew exists between the router & client.
> 
> So in this patch, I've set "update_lft = 1" unconditionally, which
> allows the surrounding code to be greatly simplified.

I actually find this much harder to follow when verifying against the RFC.

> Signed-off-by: Paul Marks <pmarks@google.com>
> ---
>  net/ipv6/addrconf.c | 52 +++++++++++++++-------------------------------------
>  1 file changed, 15 insertions(+), 37 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index d6ff126..9a5052c 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2193,43 +2193,21 @@ ok:
>  			else
>  				stored_lft = 0;
>  			if (!update_lft && !create && stored_lft) {
> -				if (valid_lft > MIN_VALID_LIFETIME ||
> -				    valid_lft > stored_lft)
> -					update_lft = 1;
> -				else if (stored_lft <= MIN_VALID_LIFETIME) {
> -					/* valid_lft <= stored_lft is always true */
> -					/*
> -					 * RFC 4862 Section 5.5.3e:
> -					 * "Note that the preferred lifetime of
> -					 *  the corresponding address is always
> -					 *  reset to the Preferred Lifetime in
> -					 *  the received Prefix Information
> -					 *  option, regardless of whether the
> -					 *  valid lifetime is also reset or
> -					 *  ignored."
> -					 *
> -					 *  So if the preferred lifetime in
> -					 *  this advertisement is different
> -					 *  than what we have stored, but the
> -					 *  valid lifetime is invalid, just
> -					 *  reset prefered_lft.
> -					 *
> -					 *  We must set the valid lifetime
> -					 *  to the stored lifetime since we'll
> -					 *  be updating the timestamp below,
> -					 *  else we'll set it back to the
> -					 *  minimum.
> -					 */
> -					if (prefered_lft != ifp->prefered_lft) {

Wouldn't the easiest solution be to just drop this if and execute the two
lines below unconditionally?

> -						valid_lft = stored_lft;
> -						update_lft = 1;
> -					}
> -				} else {
> -					valid_lft = MIN_VALID_LIFETIME;
> -					if (valid_lft < prefered_lft)
> -						prefered_lft = valid_lft;
> -					update_lft = 1;
> -				}
> +				const u32 minimum_lft = min(
> +					stored_lft, (u32)MIN_VALID_LIFETIME);
> +				valid_lft = max(valid_lft, minimum_lft);

Quick question: Don't we need a prefered_lft = min(preferred_lft, valid_lft)
here?

> +
> +				/* RFC4862 Section 5.5.3e:
> +				 * "Note that the preferred lifetime of the
> +				 *  corresponding address is always reset to
> +				 *  the Preferred Lifetime in the received
> +				 *  Prefix Information option, regardless of
> +				 *  whether the valid lifetime is also reset or
> +				 *  ignored."
> +				 *
> +				 * So we should always update prefered_lft here.
> +				 */
> +				update_lft = 1;
>  			}
>  
>  			if (update_lft) {

Thanks,

  Hannes
