From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash list depth
Date: Fri, 19 Apr 2013 17:06:04 +0200
Message-ID: <20130419150604.GG27889@order.stressinduktion.org>
References: <20130418213637.14296.43143.stgit@dragon> <20130418213732.14296.36026.stgit@dragon> <1366366287.3205.98.camel@edumazet-glaptop> <1366373950.26911.134.camel@localhost> <20130419124528.GF27889@order.stressinduktion.org> <1366381742.26911.166.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52495 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030601Ab3DSPGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 11:06:05 -0400
Content-Disposition: inline
In-Reply-To: <1366381742.26911.166.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 04:29:02PM +0200, Jesper Dangaard Brouer wrote:
> I'm using trafgen (part of netsniff-ng git download from
> https://github.com/borkmann/netsniff-ng).
> 
> Simple DoS test setup read (scroll down):
>  http://thread.gmane.org/gmane.linux.network/257155
> 
> As mentioned last time:
>  http://article.gmane.org/gmane.linux.network/263644
> 
> I have extended the DoS generator. quote:
>  'I have changed the frag DoS generator script to be more
> efficient/deadly.  Before it would only hit one RX queue, now its
> sending packets causing multi-queue RX, due to "better" RX hashing.'
> 
> I have placed the new "multi-queue" trafgen script/input here:
> http://people.netfilter.org/hawk/frag_work/trafgen/frag_packet05_small_frag_multi_queue.txf
> 
> Perhaps you can tell me, if my trafgen traffic is getting hashed badly?

Thanks!

IPv4 traffic does not have this problem, as all the information to identify
the packet are directly used as input to jhash_3words (the problem is, that
IPv6 addresses are xored first and then fed into the jhash). So with this
setup you would flood the hash uniformly distributed.

(Btw. I made a tool to generate fragments with colliding hashes:
https://gist.github.com/hannes/5116331).

> > I agree that we have to do something to mitigate this. I would also
> > drop the sysctl, I do think the kernel should have to take care of that.
> > 
> > Perhaps a way to solve this problem more easily would be to switch back to
> > use a jenkins hash for all inputs of the hash function and not deal with this
> > kind of unfairness regarding the possiblity to fill up one of the buckets.
> > 
> > Perhaps the performance improvements by Jesper (per bucket locking) could make
> > up the more expensive hashing. :)
> 
> Well, I don't know.  But we do need some solution, to the current code.

You do have fancy 10GigE gear? :)
Could you profile a kernel with 279e9f2 ("ipv6: optimize inet6_hash_frag()")
reverted? This would only effect IPv6 traffic, so you would have to write
an IPv6 txf file. If the numbers show that the effect is not too high we could
actually stop worry about per-hash bucket hash utilization in general (still,
a limit per hash chain would be reasonable, but a global element limit should
catch first).

This would give us the possibility to evict fragments from the fragmentation
cache as soon as new fragments come in without caring about which hash bucket
the fragment does actually belong, too. This would solve one of your problems
of the RFC patch.

Btw, where is the txf file format actually documented?

> > 
> > > -void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
> > > +void __inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f,
> > > +		      bool unlink_hash)
> > 
> > This function could be static.
> 
> (Sorry to be dumb) could you explain the benefit of doing so?

The function's namespace will be limited to the current file and won't
be exported for linking by other files. It also does give a good hint
for developers that the function is not used externally.

> > > +static int zero;
> > > +
> > 
> > Could be const.
> 
> Could you also explain the benefit of doing so for a variable?

Precaution that it won't be changed by any statement in the file (does not add
overhead but throws compiler errors if someone accidentally changes the
value out of mistake, compile-time).

Thanks,

  Hannes
