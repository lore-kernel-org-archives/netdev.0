From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: simplify detection of first operational link-local address on interface
Date: Thu, 16 Jan 2014 21:27:33 +0100
Message-ID: <20140116202733.GD17529@order.stressinduktion.org>
References: <20140116135323.GA7961@minipsycho.orion> <20140116191304.GC17529@order.stressinduktion.org> <52D83DE3.40806@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	fbl@redhat.com
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43652 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaAPU1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 15:27:34 -0500
Content-Disposition: inline
In-Reply-To: <52D83DE3.40806@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 03:15:31PM -0500, Brian Haley wrote:
> On 01/16/2014 02:13 PM, Hannes Frederic Sowa wrote:
> > In commit 1ec047eb4751e3 ("ipv6: introduce per-interface counter for
> > dad-completed ipv6 addresses") I build the detection of the first
> > operational link-local address much to complex. Additionally this code
> > now has a race condition.
> > 
> > Replace it with a much simpler variant, which just scans the address
> > list when duplicate address detection completes, to check if this is
> > the first valid link local address and send RS and MLD reports then.
> > 
> > Fixes: 1ec047eb4751e3 ("ipv6: introduce per-interface counter for dad-completed ipv6 addresses")
> > Reported-by: Jiri Pirko <jiri@resnulli.us>
> > Cc: Flavio Leitner <fbl@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> 
> > +/* ifp->idev must be at least read locked */
> > +static bool ipv6_lonely_lladdr(struct inet6_ifaddr *ifp)
> > +{
> > +	struct inet6_ifaddr *ifpiter;
> > +	struct inet6_dev *idev = ifp->idev;
> > +
> > +	list_for_each_entry(ifpiter, &idev->addr_list, if_list) {
> > +		if (ifp != ifpiter && ifpiter->scope == IFA_LINK &&
> > +		    (ifpiter->flags & (IFA_F_PERMANENT|IFA_F_TENTATIVE|
> > +				       IFA_F_OPTIMISTIC|IFA_F_DADFAILED)) ==
> > +		    IFA_F_PERMANENT)
> > +			return false;
> > +	}
> > +	return true;
> > +}
> 
> Just a nit, but the idev->addr_list is sorted by scope, so you could use
> list_for_each_entry_reverse(), and break out once the scope is > IFA_LINK to
> reduce the number of compares.

Very good idea, but I would leave this patch for net as-is. I'll send
one for net-next which does this optimization for the other functions
at the weekend (we can do the same optimization to ipv6_get_lladdr etc.).

Thanks,

  Hannes
