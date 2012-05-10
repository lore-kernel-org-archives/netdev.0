From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference at __ip_route_output_key
Date: Thu, 10 May 2012 16:49:46 -0400 (EDT)
Message-ID: <20120510.164946.154691168913135822.davem@davemloft.net>
References: <4F90282C.5020104@sonymobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgen.pronenko@sonymobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052Ab2EJUtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 16:49:50 -0400
In-Reply-To: <4F90282C.5020104@sonymobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgen Pronenko <yevgen.pronenko@sonymobile.com>
Date: Thu, 19 Apr 2012 16:58:52 +0200

> As you can see, there is a NULL in res.fi->fib_nh.nh_dev. One more
> thing which looks suspicious for me is that res.fi->fib_dead is 1
> here. And the crash happened just after shutting down a WLAN interface
> (the last string in the kernel log was "wlan: disconnected").
> 
> Having that, is it possible there is a race between network resources
> deallocation and a route lookup procedure?

Indeed this area is a mess.

Nothing actually gates on fi->fib_dead except for an assertion in
free_fib_info().

Therefore, fi->fib_dead is essentially useless, and doesn't block
usage of fib_info objects that we are about to liberate via RCU.

My initial impression is that we need to shift the cleanup code into
the RCU handler (free_fib_info_rcu), and add some checks on
fi->fib_dead to the fib_info lookup paths.

I suspect we might have lost the fi->fib_dead tests unintentionally
when we converted the fib_info lookup paths to be refcount-less and
use RCU.  Oddly enough, the code does check for things like
(fi->fib_flags & RTNH_F_DEAD).

Anyways, I'll do some data-mining to figure out what happened here
and then use that information to cons up a fix.

Thanks for the report.
