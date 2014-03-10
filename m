From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Sun, 09 Mar 2014 20:26:58 -0400 (EDT)
Message-ID: <20140309.202658.205858191881011540.davem@davemloft.net>
References: <20140306200658.GA32699@unicorn.suse.cz>
	<20140307.155258.463380957582451300.davem@davemloft.net>
	<20140308080616.GB5493@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbaCJA1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 20:27:04 -0400
In-Reply-To: <20140308080616.GB5493@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 8 Mar 2014 09:06:16 +0100

> I think we always should have the metrics (if we have them) in inet_peer
> in case the dst is a DST_HOST. We cannot do that directly in ip6_route_add
> because we would also publish the metrics in case we don't actually
> install the route because of an error.  So this is a no-go, we need to
> stage them first.

Absolutely, we cannot make the metrics visible until the final commit
of the route insert.

This worked transparently before we placed metrics into the inetpeer
cache, because the metrics lives in the dst itself.

I also agree with Michal's observarion of another unintended
behavioral change by this conversion.  Specifically the handling of
metric changes of existing routes.  The original code replaced all of
the metrics completely with defaults overlayed with whatever was
provided in the route change request, whereas the current inetpeer
code only updates metrics explicitly provided.

This is part of why we need to remove that DST_HOST check currently
guarding the kzalloc()'d metrics in ip6_route_add().

> So moving the metrics from staging area into inet_peer metrics in
> rt2node seems like the best solution to me so far. I am fine with the
> current approach.

I agree.

> In case fc_mx is set we now always kzalloc a non-inet-peer region to
> store the metrics for staging. I would find it a bit easier to switch
> away from dst_metric_set and use array notation to make it more clear we
> don't operate on inet_peer metrics below the install_route: mark in
> ip6_route_add. This shouldn't alter the behaviour but just make it clear we
> don't operate on inet_peer metric storage.

In fact, thinking about this some more, it's almost silly to allocate
this temporary array at all.

A different, potentially much cleaner approach, would be to pass the
cfg->fc_mx down into the __ip6_ins_rt() code path.

Then there is _no_ ambiguity.  These are metrics from a netlink
request and we must write them into the final route which we end
up with.

This makes it's way down into fib6_add_rt2node(), and right before the
insertion we make the metrics writable, clear them, and copy in the
explicit values provided from the netlink message.

All of these operations can error, and that's fine, the call chain
can handle errors signalled from here already.

Michal, Hannes, what do you think?
