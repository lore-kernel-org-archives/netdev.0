From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 3 Aug 2006 09:36:21 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32588 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S964850AbWHCQoC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 12:44:02 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Aug 2006, Herbert Xu wrote:
> jamal <hadi@cyberus.ca> wrote:
> > 
> > There is no need for tx_locking if you are already netif stopped
> > (transmit path will never be entered).
> > With this change under high speed forwarding i see anywhere
> > between 2-4Kpps improvement on a 2 CPU environment with twoo e1000s tied
> > to different CPUs forwarding between each other. Actually the
> > performance improvement should be attributed to the use of
> > TX_WAKE_THRESHOLD - more drivers should use that technique.
> > 
> > diff --git a/drivers/net/e1000/e1000_main.c 
> > b/drivers/net/e1000/e1000_main.c
> > index da62db8..559e334 100644
> > --- a/drivers/net/e1000/e1000_main.c
> > +++ b/drivers/net/e1000/e1000_main.c
> > @@ -3517,11 +3517,8 @@ #endif
> >  #define TX_WAKE_THRESHOLD 32
> >  	if (unlikely(cleaned && netif_queue_stopped(netdev) &&
> >  	             netif_carrier_ok(netdev))) {
> > -		spin_lock(&tx_ring->tx_lock);
> > -		if (netif_queue_stopped(netdev) &&
> > -		    (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
> > +		if (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)
> >  			netif_wake_queue(netdev);
> > -		spin_unlock(&tx_ring->tx_lock);
> >  	}
> >  
> >  	if (adapter->detect_tx_hung) {
> 
> Looks good to me.

jamal, thanks for the investigation, but this doesn't look so good to me.

> Even if we get it wrong and wake up something that we shouldn't have,
> the xmit function will simply bail out and stop the queue for us.

I followed the example of tg3 when attempting to optimize this code.  For 
the normal case we remove a lock acquisition.  Jamals case is not normal. 
:-)

we specifically added this lock originally to fix a problem we saw where 
the netif_stop and netif_start would race, and we would end up with a 
queue that was stopped, and no way to restart it because we didn't have 
any more TX packets to clean up (even if we DID get an interrupt from a 
receive)

> Since this is exceedingly unlikely we should drop the locks rather
> than bother about it.

I think that would be nice, but I still think the current driver solution 
is a good stable solution that has made it through several rounds of 
testing here, not to mention is in the tg3.c code.  Unless someone can 
come up with a way to avoid the race between start and stop *inside* the 
start and stop code (which would be ideal) then I think we have to have a 
solution like this in the driver.

Jesse
