From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] solos-pci: Fix BUG() with shared skb
Date: Wed, 04 Sep 2013 17:51:47 -0400 (EDT)
Message-ID: <20130904.175147.516807555661755710.davem@davemloft.net>
References: <1378223125.4210.11.camel@i7.infradead.org>
	<20130904.143056.1558570610941220565.davem@davemloft.net>
	<1378327275.2627.28.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon@fire.lp0.eu,
	linux-atm-general@lists.sourceforge.net, nathan@traverse.com.au
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932400Ab3IDVvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 17:51:51 -0400
In-Reply-To: <1378327275.2627.28.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 04 Sep 2013 21:41:15 +0100

> On Wed, 2013-09-04 at 14:30 -0400, David Miller wrote:
>> skb_realloc_headroom() should do everything you need.
> 
> Great, thanks! Something like this then... ? 
> 
> Do I really need the truesize check? And if so, is there a better way to
> handle the ATM accounting? It just *happens* to be the case that the the
> br2684_pop() and pppoatm_pop() functions don't mind being bypassed in
> this fashion, and we should probably get away with tweaking the core ATM
> accounting directly like this. Doesn't make me happy though...
 ...
> +		nskb = skb_realloc_headroom(skb, sizeof(*header));
> +		if (!nskb) {
> +			solos_pop(vcc, skb);
> +			return -ENOMEM;
> +		}
> +		if (skb->truesize != nskb->truesize)
> +			atm_force_charge(vcc, nskb->truesize - skb->truesize);

My understanding is that truesize will not be changed by calls to
skb_realloc_headroom(), because if it did then every ethernet driver
would be screwed as the skb->truesize adjustment would corrupt socket
memory accounting.

The only thing you need to be mindful is that after the
skb_realloc_headroom() call all skb data pointers change, and
therefore things like packet pointers are now stale and need to be
recalculated.
