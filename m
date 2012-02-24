From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Fri, 24 Feb 2012 10:08:38 +0100
Message-ID: <20120224090837.GA15404@secunet.com>
References: <20120221061922.GE31660@secunet.com>
 <20120221.013623.263612018908941497.davem@davemloft.net>
 <20120221081827.GF31660@secunet.com>
 <20120221.142455.1647947327897905941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47171 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756408Ab2BXJJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 04:09:13 -0500
Content-Disposition: inline
In-Reply-To: <20120221.142455.1647947327897905941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2012 at 02:24:55PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Tue, 21 Feb 2012 09:18:27 +0100
> 
> > I need the dst->ops->metrics() method because I removed the direct
> > reference to the inetpeer metrics from the dst_entry. I had to
> > remove this direct reference to be able to free the old metrics
> > safely. A dst_entry with a direct reference to old metrics
> > could leave the rcu protected region and might then try to access
> > already freed metrics (i.e. if a dst_entry with old metrics is already
> > attached to a skb when the routing cache is flushed and the skb is queued
> > for asynchronous processing). With this patchset we access the interpeer
> > metrics via the inetpeer itself on every metrics access, so we ensure
> > the metrics are not freed in the meantime.
> 
> Then a callback still seems like extreme overkill just to ensure the
> RCU safety of metric pointer accesses.

Ok, so it is the approach that is problematic. I had real hard times
to find something that I can remove from the patchset without adding
a bug :-)

> 
> It seems much simpler to me to just kill the inetpeer when we find out
> we actually do need to change the metrics, instead of trying to change
> the metric memory from underneath it. 

Well, the inetpeer was intended to keep the long-living route independent
informations about the peer. With this approach I tried to keep these
long-living informations about the peer. If we don't want to keep these
informations, it is indeed better to remove the whole inetpeer.

> Just make a new inetpeer and let
> the old one with the old outdated metrics simply die off as the stray
> references disappear.
> 
> Remove the old inetpeer from the tree (so it cannot be found in a
> lookup), and then any dangling old, invalid, routing cache entries
> referring to it will hold a reference count.  And once that final
> reference drops, we'll know we can safely free the inetpeer up. 

Actually the whole tree is invalid in such cases. So instead of
replacing each single entry of the tree, we could just replace
the old tree with a fresh initialized inet_peer_base. The old
tree could be removed later with a delayed work queue.

When rt_cache_invalidate() is invoked, all we have to do is to
replace the root node with a peer_fake_node and to add the old root
node to a garbage collecting list. The old tree will be destroyed
with a work queue later.

We would not even need a genid and we could also get rid of the
redirect_genid handling.
