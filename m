From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 0/2] net: alternate proposal for using macvlans with
 forwarding acceleration
Date: Wed, 2 Oct 2013 09:28:12 -0400
Message-ID: <20131002132812.GB6795@neilslaptop.think-freely.org>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
 <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
 <524BBDC1.6040000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44050 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703Ab3JBN2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 09:28:23 -0400
Content-Disposition: inline
In-Reply-To: <524BBDC1.6040000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 01, 2013 at 11:31:29PM -0700, John Fastabend wrote:
> On 09/25/2013 01:16 PM, Neil Horman wrote:
> >John, et al. -
> >      As promised, heres my (very rough) first pass at an alternate propsal for
> >what you're trying to do with virtual station interfaces here.  Its completely
> >untested, but it builds, and I'll be trying to run it over the next few days
> >(though I'm sure I got part of the hardware manipulation wrong).  I wanted to
> >post it early though so you could get a look at it to see what you did and
> >didn't like about it.  Some notes:
> 
> Sorry for the delay. I like the idea one nice win here is my macvlan
> kvm setup would use the offloads without having to reconfigure.
> 
Thats ok, I've been swamped, so this has gone slower than I had hoped for me.

> >
> >1) As discussed, the major effort here is to tie in macvlans with l2 forwarding
> >acceleration, rather than creating a new vsi link type.  That should make
> >management easier for admins (be it via ovs or some other mechanism).  It
> >basically exposes a bit less to the user, which I think is good.
> >
> 
> The trick here is the offload path may be functionally different from
> the non-offload path. The user needs some visibility into this. For
> example any qdiscs running on the lowerdev will not be visible from the
> accelerated path.
> 
Actually, given your suggestion in your other note (using dev_queue_xmit), I
think this will be handled, in that we will now pass accelerated traffic through
any lowerdev attached qdiscs.

> When a new link type was being used I was able to convince myself that
> it was a property of the link type. But if we reuse macvlan I think we
> need some way to either automatically disable the offload path when this
> occurs or provide the user visibility. Maybe a feature flag and a
> netif_can_hw_offload() routine is needed?
> 
As noted above, I think we can make macvlans work identially with and without
acceleration by reusing the xmit path, and keying off data (what I've done is
attach a pointer to acceleration data in the skb so the common ndo_start_xmit
path in the driver can differentiate accelerated from non-accelerated skbs).
That will allow everything to function the same way.  I do think though that a
feature flag just to provide some visibility to the admin is warranted.

> >2) I've separated out the l2 forwarding acceleration operations from the
> >net_device_operations structure.  I'm not sure I like that yet, but I'm kind on
> >leaning that way.  Since a limited set of hardare supports forwarding
> >acceleration, it makes for a nice easy way to group functionality without
> >polluting the net_device_operations structure.  It also lets us group simmilar
> >functions together nicely (I can see a future l3_accel_ops structure if we can
> >do l3 flows in hardware).  Anywho, its a divergence from what we've been doing
> >so I thought I would call attention to it.
> >
> >3) I've included a l2_accel_xmit method in the accel_ops structure for fast path
> >forwarding, but I'm not sure I like that.  It seems we should be able to use
> >ndo_start_xmit and key off some data to recognize that we should be doing
> >hardware forwarding.  I'm not quite sure how to do that yet though.  Something
> >to think about.
> 
> Without a specific xmit routine though you will be adding operations in
> the common case for a special case. Having a new op fixes this.
> 
Agreed, and thats something to consider.  I'm not sure if separating the special
case to its own operation is a net win however, given the behavioral differences
that arise (the qdisc issue above).  My next version will use a common xmit
path.  We can look it over then for comparison and weight the pros and cons.

> >
> >4) I've borrowed heavily from your vsi work of course just to get this building.
> >I think theres probbaly alot of consolidation that can be done in the code that
> >I added to ixgbe_main.c to make it smaller.  Again, I just wanted to post this
> >so you could speak up if you though this was all crap before I wen't too far
> >down the rabbit hole.
> 
> There was some consolidation needed in my original RFC as well. I can
> help clean some of this stuff up if you want.
> 
That would be greatly appreciated.  Thanks.  Next version should be available
in the next few days.  I'll get it to you asap.

Best
Neil

> .John
> 
> -- 
> John Fastabend         Intel Corporation
> 
