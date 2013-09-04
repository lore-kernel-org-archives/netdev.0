From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] solos-pci: Fix BUG() with shared skb
Date: Wed, 04 Sep 2013 14:30:56 -0400 (EDT)
Message-ID: <20130904.143056.1558570610941220565.davem@davemloft.net>
References: <1378223125.4210.11.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon@fire.lp0.eu,
	linux-atm-general@lists.sourceforge.net, nathan@traverse.com.au
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276Ab3IDSa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:30:59 -0400
In-Reply-To: <1378223125.4210.11.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Tue, 03 Sep 2013 16:45:25 +0100

> Simon reported this BUG():
> 
>  kernel BUG at net/core/skbuff.c:1065!
>  Call Trace:
>   [<f9b7c12c>] ? pppoatm_send+0x3f/0x1a0 [pppoatm]
>   [<f8751797>] psend+0xa9/0x14a [solos_pci]
>   [<f9b7c248>] pppoatm_send+0x15b/0x1a0 [pppoatm]
>   [<f8a2f77d>] ppp_push+0x76/0x533 [ppp_generic]
> 
> (Rest of backtrace at http://s85.org/mn0aOxMN ― the skb appears to be
> IPv6, forwarded from another interface over PPPoATM.)
> 
> I wasn't expecting to see shared skbs in the ATM driver's ->send()
> function. Is this the right fix?

skb_realloc_headroom() should do everything you need.

This is what ethernet drivers do to prepend custom headers
when skb_headroom() is not large enough.

For example, see drivers/net/ethernet/sun/niu.c:niu_start_xmit().
There, the driver is attempting to prepend a TX descriptor to the
SKB.

If the SKB is shared, skb_realloc_headroom() will do the clone
for you if necessary.
