From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sat, 05 Aug 2006 19:17:48 -0400
Message-ID: <1154819868.5517.34.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:51656 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751409AbWHEXRv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 19:17:51 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G9VP3-0004bN-Jm
	for netdev@vger.kernel.org; Sat, 05 Aug 2006 19:17:57 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060805230517.GA25468@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-06-08 at 09:05 +1000, Herbert Xu wrote:
> On Sat, Aug 05, 2006 at 12:56:42PM -0400, jamal wrote:
> >
> > > > The real risk is that the transmit routine will decide it's busy, but
> > > > at the same time an IRQ on another CPU will clean up the whole ring
> > > > and make the queue available again. Then the transmit routine exits and
> > > > says its busy, and the higher level will decide it is permanently stopped.
> 
> This is exactly the scenario where the current code can fail.  It is
> also exactly the one that my patch addresses.
>  

So would the holding of the tx lock at the top layer/qdisc_restart level
not help?

> > I noticed that the e1000 in some cases returns NETDEV_TX_OK even when it
> > has stopped the queue. This results in wasted calls into the qdisc.
> 
> Actually it's OK.  qdisc_restart will return after each NETDEV_TX_OK and
> its caller will check netif_queue_stopped before calling it again.
>  

yes, of course ;->

Actually the stat i captured was not related to this, rather it was the
number of times we entered qdisc_is_running and were unable to get a
packet. I am using the simple pfifo so it cant be the scheduler refusing
to give us a packet. I have a feeling it is just enthusiastic wake up of
the tx softirq. Thoughts on this? I will add checks to be sure. 

> > > If we could avoid NETDEV_TX_BUSY et al. from happening, the idea is
> > > that we could eliminate all of the requeueing logic in the packet
> > > scheduler layer.  It is a pipe dream from many years ago.
> > 
> > Still doable IMO - maybe a motivation for something to experiment with
> > this long weekend. 
> 
> A precondition to eliminating it altogether is to eliminate lockless
> drivers which would be a very good thing :)
> 

They have certainly complicated things. 

cheers,
jamal

