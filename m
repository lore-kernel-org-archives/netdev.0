From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sat, 05 Aug 2006 12:56:42 -0400
Message-ID: <1154797002.5081.21.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mchan@broadcom.com,
	herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:37339 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1030204AbWHEQ46
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 12:56:58 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G9PSD-0006fq-Tv
	for netdev@vger.kernel.org; Sat, 05 Aug 2006 12:56:49 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060804.163111.85390037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-08 at 16:31 -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>

>  
> > The real risk is that the transmit routine will decide it's busy, but
> > at the same time an IRQ on another CPU will clean up the whole ring
> > and make the queue available again. Then the transmit routine exits and
> > says its busy, and the higher level will decide it is permanently stopped.
> 

Doesnt this mean we need to hold the txlock longer to avoid the race?
It will also mean we need to have a consistent programming model of the
drivers (as an example: When is it not advisable to prune tx ring on the
tx path? My gut feeling at the moment is i would rather have receive
path do a lot of dirty work so as to prioritize transmit)

> Yes, it's meant to catch unintented races.
> 

This section of the tx path is quiet hairy. Would a patch to make
qdisc_restart more readable be a sensible thing to submit?

> The queueing layer that calls ->hard_start_xmit() technically has no
> need to support NETDEV_TX_BUSY as a return value, since the device
> is able to prevent this.
> 

I noticed that the e1000 in some cases returns NETDEV_TX_OK even when it
has stopped the queue. This results in wasted calls into the qdisc.
It seems the tg3 is doing as well. I put a little counter and the amount
of those useless calls that happen in incredible.
I was going to experiment with infact returning an additional code
NETDEV_TX_BUSY_QUEUED which signals the core to just go away.

> If we could avoid NETDEV_TX_BUSY et al. from happening, the idea is
> that we could eliminate all of the requeueing logic in the packet
> scheduler layer.  It is a pipe dream from many years ago.
> 

Still doable IMO - maybe a motivation for something to experiment with
this long weekend. 


cheers,
jamal

