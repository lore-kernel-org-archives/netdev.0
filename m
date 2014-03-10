From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Mon, 10 Mar 2014 01:52:20 +0100
Message-ID: <20140310005220.GD5493@order.stressinduktion.org>
References: <20140306200658.GA32699@unicorn.suse.cz> <20140307.155258.463380957582451300.davem@davemloft.net> <20140308080616.GB5493@order.stressinduktion.org> <20140309.202658.205858191881011540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mkubecek@suse.cz, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52463 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbaCJAwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 20:52:39 -0400
Content-Disposition: inline
In-Reply-To: <20140309.202658.205858191881011540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 09, 2014 at 08:26:58PM -0400, David Miller wrote:
> In fact, thinking about this some more, it's almost silly to allocate
> this temporary array at all.
> 
> A different, potentially much cleaner approach, would be to pass the
> cfg->fc_mx down into the __ip6_ins_rt() code path.

Maybe some people call this a layering violation, but I like the idea! :)

> Then there is _no_ ambiguity.  These are metrics from a netlink
> request and we must write them into the final route which we end
> up with.

Exactly, we can be sure that we don't accidentally always lookup
the inetpeer if we try to reinsert a cloned route where !(rt->rt6i_flags &
(RTF_NONEXTHOP | RTF_GATEWAY)) validates to true and DST_HOST is set.

This addresses the feedback from my other mail because I think if
we insert interface routes (ip r a 2000::/xx dev foo) we don't set
RTF_NONEXTHOP. (Maybe we should change that in rtm_to_fib6_config.)

> This makes it's way down into fib6_add_rt2node(), and right before the
> insertion we make the metrics writable, clear them, and copy in the
> explicit values provided from the netlink message.
> 
> All of these operations can error, and that's fine, the call chain
> can handle errors signalled from here already.
> 
> Michal, Hannes, what do you think?

So we need to change __ip6_ins_rt to take fib6_config as the second
argument instead, still have the info pointer in fc_nlinfo and only have
to wrap the info pointer in ip6_ins_rt into another structure. fib6_add
seems to be straightforward from there.

Sounds good to me!

Thanks,

  Hannes
