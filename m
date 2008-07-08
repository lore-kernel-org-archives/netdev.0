From: David Miller <davem@davemloft.net>
Subject: Re: NAPI and ->poll()
Date: Tue, 08 Jul 2008 14:24:50 -0700 (PDT)
Message-ID: <20080708.142450.171642381.davem@davemloft.net>
References: <m3vdzgfqv8.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54692
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751183AbYGHVYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 17:24:50 -0400
In-Reply-To: <m3vdzgfqv8.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Tue, 08 Jul 2008 15:27:23 +0200

> Just noticed a weird fragment in my code and want to be sure:
> The NAPI poll() method should _always_ return a number of sk_buffs
> processed, even if it calls netif_rx_complete() and then maybe
> netif_rx_reschedule()?

Yes, and the value you return lets the core layer know whether
you called netif_rx_complete() or not.

You may only do a netif_rx_complete() if you return a value
less than the given budget.  This is a pretty strict requirement,
and it's described in the following comment from net/core/dev.c:

		/* Drivers must not modify the NAPI state if they
		 * consume the entire weight.  In such cases this code
		 * still "owns" the NAPI instance and therefore can
		 * move the instance around on the list at-will.
		 */
		if (unlikely(work == weight)) {
			if (unlikely(napi_disable_pending(n)))
				__napi_complete(n);
			else
				list_move_tail(&n->poll_list, list);
		}

So, as you can see, if you consume the entire budget, your
caller assumes that it still owns the NAPI context and it is
still scheduled.  Otherwise, if less than the budget is consumed,
you must netif_rx_complete().

You must make these decisions regardless of whether your hardware
says there is more work left.  It must be strictly performed
based upon the work quota consumed.

One common mistake is to consume exactly the quota, and do
a netif_rx_complete() because no more RX packets are
present in the hardware.  This is wrong, you must simply
return the work consumed, and let the mid-layer call you
one more time.
