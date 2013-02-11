From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] tg3: Convert chip type macros to inline functions
Date: Sun, 10 Feb 2013 19:39:27 -0500 (EST)
Message-ID: <20130210.193927.632140014473940921.davem@davemloft.net>
References: <1360194298.12464.35.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hauke@hauke-m.de, mcarlson@broadcom.com,
	mchan@broadcom.com, nsujir@broadcom.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab3BKAjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 19:39:31 -0500
In-Reply-To: <1360194298.12464.35.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 06 Feb 2013 15:44:58 -0800

> To me the negative to these conversions is at
> least for gcc 4.7.2, the overall code size
> increases
> 
> $ size drivers/net/ethernet/broadcom/tg3.o*
>    text	   data	    bss	    dec	    hex	filename
>  203426	  13446	  55744	 272616	  428e8	drivers/net/ethernet/broadcom/tg3.o.new
>  202135	  13446	  55144	 270725	  42185	drivers/net/ethernet/broadcom/tg3.o.old
> 
> I'm not sure why gcc doesn't do the optimization
> and code generation the same way.

Out of curiosity I looked at the assembler difference on sparc
and one thing stood out.

You're changing how the values are evaluated, specifically you
now are forcing the compiler to work with unsigned ID numbers
whereas before it was working with signed values.

So, looking at one example, the ASIC revision test in __tg3_set_mac_addr():

	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 ||
	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
	...
	}


The compiler previously turned the two tests into one:

	asic_id -= 1;
	if (asic_id <= 1) {
	...
	}

But this construct isn't valid for unsigned quantities, so now with
your patch this expands to two tests:

	if (asic_id == 1 ||
	    asic_id == 2) {
	...
	}

The assembler is hard to compare manually, because the inlining
changes how hard registers are allocated, and issues like the above
will change all of the branch and file offsets as well. :-/
