From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sis900: Allocate rx replacement buffer before rx operation
Date: Thu, 26 Apr 2007 19:30:14 -0400
Message-ID: <20070426233014.GB3600@localhost.localdomain>
References: <20070420135458.GB16191@hmsreliant.homelinux.net> <462E33A8.5060107@garzik.org> <20070426174736.GC6000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, venza@brownhat.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4887 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753897AbXD0AQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 20:16:54 -0400
Content-Disposition: inline
In-Reply-To: <20070426174736.GC6000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 01:47:36PM -0400, Neil Horman wrote:
> On Tue, Apr 24, 2007 at 12:43:20PM -0400, Jeff Garzik wrote:
> > Neil Horman wrote:
> > >Hey there-
> > >	The sis900 driver appears to have a bug in which the receive routine
> > >passes the skbuff holding the received frame to the network stack before
> > >refilling the buffer in the rx ring.  If a new skbuff cannot be allocated, 
> > >the
> > >driver simply leaves a hole in the rx ring, which causes the driver to stop
> > >receiving frames and become non-recoverable without an rmmod/insmod 
> > >according to
> > >reporters.  This patch reverses that order, attempting to allocate a 
> > >replacement
> > >buffer first, and receiving the new frame only if one can be allocated.  
> > >If no
> > >skbuff can be allocated, the current skbuf in the rx ring is recycled, 
> > >dropping
> > >the current frame, but keeping the NIC operational.
> > >
> > >Thanks & Regards
> > >Neil
> > 
> 
> 
> 
> Just found a hole in my last patch.  It was reported to me that shortly after we
> integrated this patch.  The report was of an oops that took place inside of
> netif_rx when using the sis900 driver.  Looking at my origional patch I noted
> that there was a spot between the new skb_alloc and the refill_rx_ring label
> where skb got reassigned to the pointer currently held in the rx_ring for the
> purposes of receiveing the frame.  The result of this is however that the buffer
> that gets passed to netif_rx (if it is called), then gets placed right back into
> the rx_ring.  So if you receive frames fast enough the skb being processed by
> the network stack can get corrupted.  The reporter is testing out the fix I've
> written for this below (I'm not near my hardware at the moment to test myself),
> but I wanted to post it for review ASAP.  I'll post test results when I hear
> them, but I think this is a pretty straightforward fix.  It just uses a separate
> pointer to do the rx operation, so that we don't improperly reassign the pointer
> that we use to refill the rx ring.
> 
> Thanks & Regards
> Neil
> 
Test results are back and appear successful.
Neil

