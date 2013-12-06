From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 2/3] xfrm: clamp down spi range for IPComp when
 allocating spi
Date: Fri, 6 Dec 2013 12:42:48 +0100
Message-ID: <20131206114248.GG31491@secunet.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
 <1385607161-27597-3-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53127 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757569Ab3LFLmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 06:42:51 -0500
Content-Disposition: inline
In-Reply-To: <1385607161-27597-3-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 28, 2013 at 10:52:40AM +0800, Fan Du wrote:
> otherwise xfrm state can not be found properly by peers.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/xfrm/xfrm_state.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 68c2f35..a6716d7 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -1506,6 +1506,19 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
>  	__be32 maxspi = htonl(high);
>  	u32 mark = x->mark.v & x->mark.m;
>  
> +	/* Compression Parameter Index(CPI) is 16bits wide
> +	 * An 32 bits spi value will hash xfrm_state into wrong hash slot.
> +	 * When the upper 16bits of spi values is used as CPI for the peer
> +	 * to look up xfrm state, it would generate XfrmOutNoStates error,
> +	 * as apparently we are looking for the wrong hash slot.
> +	 *
> +	 * So clamp down the spi range into only 16bits valid wide.
> +	 */
> +	if (x->id.proto == IPPROTO_COMP) {
> +		minspi = htonl(0xc00);
> +		maxspi = htonl(0xff00);
> +	}

This does not make sense. The spi is chosen based on minspi only
if minspi is equal to maxspi. This will be never the case for
IPPROTO_COMP with your patch.

Also, the spi range is user defined, we should respect the
users configuration if the range is valid.

Please explain your choices on the minspi and maxspi value.
