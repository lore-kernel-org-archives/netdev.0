From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Tue, 21 Feb 2012 09:18:27 +0100
Message-ID: <20120221081827.GF31660@secunet.com>
References: <20120210084424.GM23142@secunet.com>
 <20120210.132557.396788563105190450.davem@davemloft.net>
 <20120221061922.GE31660@secunet.com>
 <20120221.013623.263612018908941497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33932 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752285Ab2BUISj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 03:18:39 -0500
Content-Disposition: inline
In-Reply-To: <20120221.013623.263612018908941497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2012 at 01:36:23AM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> > 
> > Ok, apparently I looked at the wrong place. The only checks at metrics
> > access that might be superfluous are the inet_metrics_new() checks in
> > ipv4_metrics() and ipv6_metrics(). If these are the checks you mean,
> > I'd remove them and resend the patchset.
> 
> I'm saying you shouldn't need a metrics access callback nor the rest
> of your patch at all.

I need the dst->ops->metrics() method because I removed the direct
reference to the inetpeer metrics from the dst_entry. I had to
remove this direct reference to be able to free the old metrics
safely. A dst_entry with a direct reference to old metrics
could leave the rcu protected region and might then try to access
already freed metrics (i.e. if a dst_entry with old metrics is already
attached to a skb when the routing cache is flushed and the skb is queued
for asynchronous processing). With this patchset we access the interpeer
metrics via the inetpeer itself on every metrics access, so we ensure
the metrics are not freed in the meantime.

> 
> Look, when routes change, the routing cache is flushed and the gen ID
> is incremented.
> 
> Every single existing routing cache entry is therefore instantly
> invalid, and will not be used another time.
>

Yes. But the dst_entry that belongs to an old existing routing cache
entry could be already attached to a skb in the moment when the routing
cache is flushed. This could lead to an access of already freed metrics,
as mentioned above.

Maybe I'm a bit slow on the uptake, but I don't see what's superfluous.
Could you please point me to the superfluous code in the patchset?
 
> Therefore every route usage afterwards will go through the routing
> cache entry creation path.  And in this path the inetpeer and it's
> metrics can be validated, out of date metrics freed and replaced with
> new ones, etc.  Whatever might be necessary can all be done here.
> 
> There is no need to every have special handling at metric access time
> on a valid routing cache entry, the fact that it's valid and it's gen
> ID matches up, means there has been no route table changes meanwhile
> and that the inetpeer metrics have been validated since the last route
> table change.
