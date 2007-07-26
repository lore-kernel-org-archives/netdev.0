From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Thu, 26 Jul 2007 14:38:09 -0700
Message-ID: <1185485889.7922.83.camel@dell>
References: <20070725.233808.41635535.davem@davemloft.net>
 <1551EAE59135BE47B544934E30FC4FC002AAB9F8@nt-irva-0751.brcm.ad.broadcom.com>
 <20070726.001516.48528000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1110 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762426AbXGZUol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 16:44:41 -0400
In-Reply-To: <20070726.001516.48528000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-26 at 00:15 -0700, David Miller wrote:

> The netpoll code has to take that anyways in order to call
> into ->hard_start_xmit() to send out the packet it has
> pending, I'm leveraging that as a synchronization mechanism
> in the drivers because the locking options are limited
> given that netpoll can try to do this in any context whatsoever.
> 
> > There is a measurable difference in oprofile.  When passing small
> > packets, there's a non-trivial difference in throughput.
> 
> Then please help come up with an alternate scheme, because these
> NAPI changes fix real limitations and bugs in the current code
> and unless we fix netpoll too we can't move forward.
> 

I'm not very familiar with netpoll, but I am guessing that we need to
prevent concurrent calls to the TX cleanup code.  For maximum
flexibility, we should let ->poll_controller() handle the locking as the
driver knows what kind of locking is best.

If the driver wants a simple solution, it can do what you did in the
patch:  wrap the tx cleanup code with netif_tx_lock() and
netif_tx_unlock().

If a NAPI driver wants to be more clever, it can do something such as
this in tg3's poll_controller:

if (netif_rx_schedule_prep(dev, &tp->napi)) {
	tg3_tx(tp);
	netif_poll_enable(tp->napi);
}

