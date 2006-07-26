From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH Round 4 2/3] Core network changes to support network
	event notification.
Date: Wed, 26 Jul 2006 11:15:43 -0500
Message-ID: <1153930543.8155.22.camel@stevo-desktop>
References: <E1G5HW5-0005xn-00@gondolin.me.apana.org.au>
	 <1153839940.14354.37.camel@stevo-desktop>
	 <20060726033951.GB3203@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rdreier@cisco.com, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:33205 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S1750896AbWGZQPp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 12:15:45 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060726033951.GB3203@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-26 at 13:39 +1000, Herbert Xu wrote:
> On Tue, Jul 25, 2006 at 10:05:40AM -0500, Steve Wise wrote:
> > 
> > But they really are seeing a delete followed by an add.  That's what the
> > kernel is doing.
> 
> Actually that's the other thing I don't really like.  The user-space
> monitor may perceive that a route was actually deleted and replaced
> by a new one even though this isn't what's happening at all.
> 
> In fact the problem here is that you're sending route notifications
> when it's really the dst_entry that's changing.  User-space as it
> stands only get notifications about fib changes which is quite different
> from changes to the transient dst_entry objects which only exist in the
> route cache.
> 
> Is anyone actually going to use the user-space interface of this? If not
> perhaps we should wait until someone really needs it before adding the
> netlink part of the patch.
> 
> We can change the kernel interface at will so if we make a mistake with
> netevent it can be easily corrected.  For user-space though the rules
> are totally different.  I'd really hate to be stuck with an interface
> which turns out to not be the one that people actually want to have.
> 

The user interface is not needed for the rdma users.  They are all in
kernel.  I added this at the request of reviewers of this patch.  I have
no problem at all defering the rtnetlink integration until someone
really needs it.

> > The rdma driver needs to update all established rdma connections that
> > are using the next-hop information of the existing route and make them
> > use the next-hop information of the new route.  In addition, the rdma
> > driver might have a reference to the old dst entry.  So it can release
> > that ref and add a ref to the new dst entry.
> 
> Do you really need the old route for the user-space part of your patch?
> 

Not if we remove the user-space parts. :-)

> > I have to admit I'm a little fuzzy on the routing stuff.  The main
> > netevents I've utilized in the the rdma driver I'm writing is the
> > neighbour update event and the redirect event.  Route add/del was added
> > for completeness of "routing" netevents.   
> 
> So you mean you aren't going to use the route notifications? In that case
> we should probably just drop them and add them when someone actually needs
> it.  At that point they can tell us what semantics they want from it :)
> 

This is fine by me too!  The key events needed for rdma are:

neighbour update events
rtredirect events
pmtu change events

> > Can you expand further or point me to code where the IP stack "flushes
> > its tables" when routes are changed?
> 
> Grep for rt_cache_flush in net/ipv4/fib_hash.c.
> 

thanks.

Dave, what do you think about removing the user-space stuff for the
first round of integration?  IE:  Just add netevents and kernel hooks to
generate them.


Steve.

