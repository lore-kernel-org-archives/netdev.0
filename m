From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge: Eliminate unnecessary forward delay
Date: Tue, 5 Aug 2008 01:32:20 +0800
Message-ID: <20080804173220.GA14093@gondor.apana.org.au>
References: <20080804170439.GA13546@gondor.apana.org.au> <20080804102703.666baedd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47769 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754049AbYHDRc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 13:32:26 -0400
Content-Disposition: inline
In-Reply-To: <20080804102703.666baedd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 10:27:03AM -0700, Stephen Hemminger wrote:
> 
> How about this, it is simpler just to do the state change.

Sure, that should work as well.

> --- a/net/bridge/br_stp.c	2008-08-04 10:20:21.000000000 -0700
> +++ b/net/bridge/br_stp.c	2008-08-04 10:26:04.000000000 -0700
> @@ -368,14 +368,26 @@ static void br_make_blocking(struct net_
>  /* called under bridge lock */
>  static void br_make_forwarding(struct net_bridge_port *p)
>  {
> -	if (p->state == BR_STATE_BLOCKING) {
> -		if (p->br->stp_enabled == BR_KERNEL_STP)
> -			p->state = BR_STATE_LISTENING;
> -		else
> -			p->state = BR_STATE_LEARNING;
> +	struct net_bridge *br = p->br;
>  
> -		br_log_state(p);
> -		mod_timer(&p->forward_delay_timer, jiffies + p->br->forward_delay);	}
> +	if (p->state != BR_STATE_BLOCKING)
> +		return;
> +
> +	if (br->forward_delay == 0) {
> +		p->state = BR_STATE_FORWARDING;
> +		if (br_is_designated_for_some_port(br))
> +			br_topology_change_detection(br);

Provided that you make br_is_designated_for_some_port available
first :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
