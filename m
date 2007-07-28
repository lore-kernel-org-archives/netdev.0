From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Sat, 28 Jul 2007 08:21:58 -0700
Message-ID: <ada6444y2nd.fsf@cisco.com>
References: <20070723.210748.63127793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:47976 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbXG1PWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2007 11:22:00 -0400
In-Reply-To: <20070723.210748.63127793.davem@davemloft.net> (David Miller's message of "Mon, 23 Jul 2007 21:07:48 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been on vacation so I missed most of this thread.  I'm just
catching up now...

 > Ok I converted everything with Rusty's suggestion to move napi_struct
 > out of net_device, this was mostly mechanical but some devices took
 > some unanticipated amount of work.

Actually you missed drivers/infiniband/ulp/ipoib, which has used NAPI
since 2.6.22.  I can take a stab at the conversion soon if you want...

 > Another area of consternation are drivers that were using
 > netif_rx_reschedule(), as that interface was removed because it
 > doesn't fit well with the caller managing the dev->quota et al.  I
 > left race conditions in the drivers that were using that interface,
 > but they should still basically work nonetheless.

...but this is a problem for IPoIB.  The underlying IB stuff only
allows us to register what is essentially a one-shot edge-triggered
interrupt.  So there is a race between calling netif_rx_complete() and
calling ib_req_notify_cq() (which enables the interrupt), since the
interrupt might never happen if a packet arrives between the two calls.

In the current driver we are OK because ib_req_notify_cq() can return
a hint if an event was missed, but to use this hint we need a way to
restart the NAPI poll without getting into trouble if the interrupt
handler calls netif_rx_schedule() too.

Thanks,
  Roland
