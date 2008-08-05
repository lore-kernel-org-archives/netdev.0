From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] catch up device stats when multicast > total frames
Date: Tue, 5 Aug 2008 09:16:11 -0400
Message-ID: <20080805131610.GC22123@hmsreliant.think-freely.org>
References: <20080805115018.GB22123@hmsreliant.think-freely.org> <20080805121527.GZ10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2700 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758878AbYHENQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 09:16:46 -0400
Content-Disposition: inline
In-Reply-To: <20080805121527.GZ10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 01:15:29PM +0100, Ben Hutchings wrote:
> Neil Horman wrote:
> > Hey-
> > 	REcently observed a problem wherein, if a BMC or other IPMI device is
> > attached to a NIC, multicast frames can be consumed by the aformentioned device
> > without ever being seen by the driver.  Since multicast frames are counted in
> > the hardware and the total frame counter is counted in the driver napi routine,
> 
> I'd be surprised if the hardware does not also maintain a total frame
> counter.  If not, you can possibly calculate the total as good + bad
> packets, or unicast + multicast + broadcast + bad, or something like that.
> 

It does, however,  for whatever reason the drriver relies on a software
computed total packets counter rather than the hardware based on (possibly for
the same reason, in that it counts frames the driver never actually sees).  I
asked John R. in the origional bug report why e1000 might do this, and while
neither of us were sure, that seemed to be the consensus.

> [...]
> > --- a/drivers/net/e1000/e1000_main.c
> > +++ b/drivers/net/e1000/e1000_main.c
> > @@ -3761,6 +3761,8 @@ e1000_update_stats(struct e1000_adapter *adapter)
> >  	/* Fill out the OS statistics structure */
> >  	adapter->net_stats.multicast = adapter->stats.mprc;
> >  	adapter->net_stats.collisions = adapter->stats.colc;
> > +	if (adapter->net_stats.rx_packets < adapter->net_stats.multicast)
> > +		adapter->net_stats.rx_packets = adapter->net_stats.multicast;
> >  
> >  	/* Rx Errors */
> >  
> [...]
> 
> This is a botch - it means the numbers can't be so obviously wrong, but
> doesn't make them correct.
> 
I agree, but as it stands currently the numbers are obviously wrong, and I don't
see a way to make them undenyably correct.  We could use the hardware counter
instead, but then we would be counting frames that various IPMI endpoints might
consume, so that wouldn't be quite right.  We could fix up the sofware counter
based on the hardware counter, but that doesn't seem right either.  We could
inspect the packet in the driver, and do a software multicast frame counter, but
that would be a big performance hit.  So there is no great fix to this problem.
This at least makes the stats sane, doesn't impact performance, and doesn't
affect stats for which IPMI reception isn't an issue.

John, you stopped commenting in the origional bug report, do you have any
further thoughts on this as a fix to the issue at hand?

Neil


-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
