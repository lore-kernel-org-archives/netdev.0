From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: Provide linear backoff mechanism for
 constrained resources at the driver
Date: Wed, 21 May 2014 14:49:28 -0400
Message-ID: <20140521184928.GA16676@hmsreliant.think-freely.org>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
 <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
 <CAHA+R7Ox+6f2Kd9ZyHLez_7rDrQs1vHEZnsoarhYhd9QRVumJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57758 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbaEUStf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 14:49:35 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7Ox+6f2Kd9ZyHLez_7rDrQs1vHEZnsoarhYhd9QRVumJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 11:05:28AM -0700, Cong Wang wrote:
> On Thu, May 8, 2014 at 12:29 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> > What about something like this?  Its not even compile tested, but let me know
> > what you think of the idea.  The reasoning behind it is that transient resources
> > like dma address ranges in the iommu or swiotlb have the following attributes
> >
> > 1) they are quickly allocated and freed
> >
> > 2) Usually handled by simply trying again at some later point in time
> >
> > 3) Likely to fail again if tried again immediately.
> >
> > 4) Not condusive to interlocked signaling mechanisms as the time it takes to
> > find and signal a waiting tx queue that resources are now available may take
> > longer than needed, and may still result in failure, as competing allocators
> > may race in and claim said resources during the signaling period.
> >
> > As such, what if we try something more simple like a linear backoff? In this
> > example we add a TX return code that indicates that the driver is not busy, but
> > unable to transmit due to resource constraints.  This signals the qdisc layer to
> > skip trying to drain this transmit queue for a short period of time, with
> > subsequent simmilar errors causing increased backoff.  Once the condition is
> > cleared, the backoff delay is removed and operation returns to normal.
> 
> Loos like this is a more general issue which should be solved for every
> spinlock:
> 
> http://thread.gmane.org/gmane.linux.kernel/1437186
> 
Good point, though this isn't a locking situation so much as a failed
transmission situation.  The same mechanism applies though, and this seems to be
simmilar to what the ticketed spinlocks do
Neil
