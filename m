From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash list depth
Date: Tue, 23 Apr 2013 22:54:23 +0200
Message-ID: <20130423205423.GA17055@order.stressinduktion.org>
References: <1366366287.3205.98.camel@edumazet-glaptop> <1366373950.26911.134.camel@localhost> <20130419124528.GF27889@order.stressinduktion.org> <1366381742.26911.166.camel@localhost> <20130419194424.GI27889@order.stressinduktion.org> <1366621834.26911.271.camel@localhost> <20130422145431.GA26838@order.stressinduktion.org> <1366652952.26911.334.camel@localhost> <20130423002022.GA28991@order.stressinduktion.org> <1366726763.26911.417.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59409 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647Ab3DWUyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 16:54:25 -0400
Content-Disposition: inline
In-Reply-To: <1366726763.26911.417.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 04:19:23PM +0200, Jesper Dangaard Brouer wrote:
> Yes, traffic patterns do affect the results, BUT you have to be really
> careful profiling this:
> 
> Notice, that inet_frag_find() also indirectly takes the LRU lock, and
> the perf tool will blame inet_frag_find().  This is very subtle and
> happens with a traffic pattern that want to create new frag queues (e.g.
> not found in the hash list).
> The problem is that inet_frag_find() calls inet_frag_create() (if q is
> not found) which calls inet_frag_intern() which calls
> inet_frag_lru_add() taking the LRU lock.  All of these functions gets
> inlined by the compiler, thus inet_frag_find() gets the blame.
> 
> 
> To avoid pissing people off:

Ah, come on. I don't think you do that. ;)

> Yes, having a long list in the hash bucket is obviously also contributes
> significantly.  Yes, we still should increase the hash bucket size.  I'm
> just pointing out be careful about what you actually profile ;-)
> 
> 
> Please see below, profiling of current next-next, with "noinline" added
> to inet_frag_intern, inet_frag_alloc and inet_frag_create.  Run under
> test 20G3F+MQ. I hope you can see my point with the LRU list lock,
> please let me know if I have missed something.

I have no objections. My ipv6 test case simply does not get the memory
usage of the fragment cache over the thresholds, so I have no contention
there, just dropping because of the 128 list length limit.

As soon as I would fill up the fragment cache the contention will be on the
lru lock as you showed here.

Greetings,

  Hannes
