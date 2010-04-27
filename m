From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Tue, 27 Apr 2010 17:50:34 +0200
Message-ID: <20100427155034.GA11157@midget.suse.cz>
References: <20100422.004324.67422011.davem@davemloft.net>
 <20100422142506.GA15858@gondor.apana.org.au>
 <20100422154908.GA31568@midget.suse.cz>
 <20100422.185400.71096585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59357 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754224Ab0D0Puh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 11:50:37 -0400
Content-Disposition: inline
In-Reply-To: <20100422.185400.71096585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 06:54:00PM -0700, David Miller wrote:
> From: Jiri Bohac <jbohac@suse.cz>
> Date: Thu, 22 Apr 2010 17:49:08 +0200
> 
> > I still don't see why __ipv6_ifa_notify() needs to call
> > dst_free(). Shouldn't that be dst_release() instead, to drop the
> > reference obtained by dst_hold(&ifp->rt->u.dst)?
> 
> It likely wants to do both.
> 
> Just doing dst_release() doesn't mark the 'dst' object as obsolete,
> and therefore it won't get force garbage collected.

Sure. So If I understand it correctly, there are two problems:

- the reference taken by dst_hold() just above the ip6_del_rt()
  is never dropped if ip6_del_rt() fails; so shouldn't the code
  be like this?:

	dst_hold(&ifp->rt->u.dst);
	if (ip6_del_rt(ifp->rt)) {
		dst_release(&ifp->rt->u.dst);
		dst_free(&ifp->rt->u.dst);
	}

- if ip6_del_rt() fails because it races with something else
  deleting the address, dst_free() will be called twice. This is
  what Herbert is fixing with additional locking. However -- even
  when he fixes that -- how can ip6_del_rt() fail with the
  ifp->rt still needing a dst_free()?
  AFAICS, it can fail by:
  	- __ip6_del_rt() finding that (rt ==
	  net->ipv6.ip6_null_entry); we don't want to call
	  dst_free() on net->ipv6.ip6_null_entry, do we?

	- fib6_del() returning -ENOENT for multiple reasons;
	  but doesn't that mean that something else has removed
	  the route already and called dst_free on it?

  In either case, the dst_free() looks like not being needed. And it only
  does no harm in most cases, because these events are rare and
  it usually finds (obsolete > 2) and does nothing.
  
  I think that what Herbert is doing is only going to enforce that
  the ip6_del_rt() is never going to fail, so the dst_free()
  won't ever be called anyway, right?

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

