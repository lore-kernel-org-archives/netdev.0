From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Thu, 16 Dec 2010 13:21:22 -0800 (PST)
Message-ID: <20101216.132122.70179958.davem@davemloft.net>
References: <20101215.132113.189700977.davem@davemloft.net>
	<1292529359.2655.2.camel@edumazet-laptop>
	<20101216.115900.183061857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36024
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756903Ab0LPVUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 16:20:53 -0500
In-Reply-To: <20101216.115900.183061857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 16 Dec 2010 11:59:00 -0800 (PST)

> Hmm... perhaps we need to force-COW or revert to the default zero
> metrics for any routing cache entries with reference counts?
> 
> Or maybe that's not even needed.
> 
> Because nobody should try to touch metrics without first doing a
> dst->check(), especially after the RCU grace period, so it should be
> OK no?

Ok I did some audits and there are some problems in this area.

First of all I have to at least defer the kmalloc()'d metrics free
until the RCU callback.

Second of all things like tcp_update_metrics() use __sk_dst_get()
instead of __sk_dst_check().

I have an idea to use another pointer state bit to indicate that the
metrics are "dead".  This would block all COW operations and writes.
Metric reads for obsolete dst's would be redirected to the read-only
all-zeros default array.

In this way we won't need to do anything different in places like
tcp_update_metrics().

I'll post a new patch once I sort all of this out.

Thanks for catching this!

