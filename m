From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: fix RTNL assert fail in DAD
Date: Thu, 20 Mar 2014 07:38:22 +0100
Message-ID: <20140320063822.GL12291@order.stressinduktion.org>
References: <20140318235811.0d8f230a@nehalam.linuxnetplumber.net> <20140319.135319.2039055704156238608.davem@davemloft.net> <20140319224442.GJ12291@order.stressinduktion.org> <20140319.235217.1348886613951521818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47950 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbaCTGiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 02:38:24 -0400
Content-Disposition: inline
In-Reply-To: <20140319.235217.1348886613951521818.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 11:52:17PM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 19 Mar 2014 23:44:42 +0100
> 
> > On Wed, Mar 19, 2014 at 01:53:19PM -0400, David Miller wrote:
> >> Ok, the timer stuff could run from a workqueue just fine.
> > 
> > We have no-timer invocations, too, like addrconf_prefix_rcv. In that case the
> > whole handling of the router advertisment should get deferred into the
> > workqueue.
> 
> Just to be clear, you are saying that this doesn't need to be
> synchronous?  Handling a prefix event seems like something that would
> in fact need to be.

Here is my current analysis and proposals:

Actually, I would say that a safe entry point for starting to push further
prefix event handling into a workqueue would be addrconf_dad_start.

>From there on, we need to make sure that addrconf_join_solict (which
is the first point we actually need RTNL locked) is called before we
do optimistic duplicate address detection processing (this seems to be
the only happens-before invariant we need to preserve here). Stephen already
allocated the work_struct in inet6_ifaddr, so my suggestion would be to
change Stephen's patch to use a delayed workqueue and just replace the
other timer operations to use the new work_struct in inet6_ifaddr
with delayed operations. Entry-point would be addrconf_dad_start which
simply adds the delayed operation with 0 delay and maybe a new flag so
that addrconf_dad_timer (which should be called addrconf_dad_work by then)
does the work which was prior in addrconf_dad_start.

The addrconf_dad_completed handling could be under RTNL, too, so the
original problem would be gone.

addrconf_verify would also need a delayed workqueue (split to
addrconf_verify_rtnl and addrconf_verify is just a invocation
to mod_delay_work(wq, addrconf_verify_work, 0) which calls
addrconf_verify_rtnl with rtnl locked, would be my approach by only
looking at the code).

That leaves us with one unsafe invocation of an rtnl-locked needed invocation
in pndisc_constructor for proxy_ndp handling. Don't know what to do about that
currently but didn't look to closely.

Also, to find problems like this sooner, should we propagate ASSERT_RTNL()
tests up from conditional callees to their callers (e.g. __dev_set_promiscuity
-> __dev_set_rx_mode -> maybe even further up the stack?).

Greetings,

  Hannes
