From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Tue, 21 Feb 2012 14:24:55 -0500 (EST)
Message-ID: <20120221.142455.1647947327897905941.davem@davemloft.net>
References: <20120221061922.GE31660@secunet.com>
	<20120221.013623.263612018908941497.davem@davemloft.net>
	<20120221081827.GF31660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334Ab2BUTZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 14:25:11 -0500
In-Reply-To: <20120221081827.GF31660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 21 Feb 2012 09:18:27 +0100

> I need the dst->ops->metrics() method because I removed the direct
> reference to the inetpeer metrics from the dst_entry. I had to
> remove this direct reference to be able to free the old metrics
> safely. A dst_entry with a direct reference to old metrics
> could leave the rcu protected region and might then try to access
> already freed metrics (i.e. if a dst_entry with old metrics is already
> attached to a skb when the routing cache is flushed and the skb is queued
> for asynchronous processing). With this patchset we access the interpeer
> metrics via the inetpeer itself on every metrics access, so we ensure
> the metrics are not freed in the meantime.

Then a callback still seems like extreme overkill just to ensure the
RCU safety of metric pointer accesses.

It seems much simpler to me to just kill the inetpeer when we find out
we actually do need to change the metrics, instead of trying to change
the metric memory from underneath it.  Just make a new inetpeer and let
the old one with the old outdated metrics simply die off as the stray
references disappear.

Remove the old inetpeer from the tree (so it cannot be found in a
lookup), and then any dangling old, invalid, routing cache entries
referring to it will hold a reference count.  And once that final
reference drops, we'll know we can safely free the inetpeer up.  So
we'll use stale metrics for a while from these old invalid routing
cache entries, but that's perfectly fine.

The whole thing is about not doing something non-trivial in the fast
path, which is what your patch does.  Your approach causes us to incur
a cost every single metric access just because we "might" access stale
metrics from a old invalid routing cache entry.  This is not the
common case at all.
