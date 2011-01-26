From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Wed, 26 Jan 2011 15:31:11 -0800 (PST)
Message-ID: <20110126.153111.246553586.davem@davemloft.net>
References: <1292529359.2655.2.camel@edumazet-laptop>
	<20101216.115900.183061857.davem@davemloft.net>
	<20110126.152538.260074157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42393
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753988Ab1AZXah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 18:30:37 -0500
In-Reply-To: <20110126.152538.260074157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 26 Jan 2011 15:25:38 -0800 (PST)

> Finally, once this change is stabilized we can be a lot smarter about
> what we do at the time an entry is created.  For example, when a route
> is looked up for a TCP socket, we essentially know we are going to COW
> the route %99.99999 of the time.  So we can pass a hint into TCP's
> route lookups in the flow flags field telling it to pre-COW the route.
> 
> TCP pre-COW'ing of metrics will thus save several atomics.

I forgot to mention one other idea I had.

To get rid of the atomics in the non-TCP cases, we note that pretty much
all routes installed have no special metrics attached, the fib_info
metrics are equal to dst_default_metrics.

This means if we check for this case, we can point the dst->_metrics
at dst_default_metrics and then we don't need to do any atomics at
all.  Just one straight assignment at creation and then absolutely no
work at all during destroy.

We could even consider allocating fib_info->metrics externally, and point
it directly at dst_default_metrics when possible.  This is going to save
an enormous amount of memory as well as get rid of the atomics.

So Eric, I really hope I can sell you on this :-)
