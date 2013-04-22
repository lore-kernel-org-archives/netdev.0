From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Mon, 22 Apr 2013 11:10:34 +0200
Message-ID: <1366621834.26911.271.camel@localhost>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
	 <20130419124528.GF27889@order.stressinduktion.org>
	 <1366381742.26911.166.camel@localhost>
	 <20130419194424.GI27889@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753838Ab3DVJKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 05:10:40 -0400
In-Reply-To: <20130419194424.GI27889@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 21:44 +0200, Hannes Frederic Sowa wrote:
> On Fri, Apr 19, 2013 at 04:29:02PM +0200, Jesper Dangaard Brouer wrote:
> > Well, I don't know.  But we do need some solution, to the current code.
> 
> In <http://article.gmane.org/gmane.linux.network/261361> I said that we could
> actually have a list lengt of about 370. At this time this number was stable,
> perhaps you could verify?
> 
> I tried to flood the cache with very minimal packets so this was actually
> the hint that I should have resized the hash back then. With the current
> fragmentation cache design we could reach optimal behaviour as soon
> as the memory limits kicks in and lru eviction starts before we limit the
> fragments queues in the hash chains. The only way to achieve this is to
> increase the hash table slots and lower the maximum length limit. I would
> propose a limit of about 25-32 and as Eric said, a hash size of 1024. We could
> test if we are limited of accepting new fragments by memory limit (which would
> be fine because lru eviction kicks in) or by chain length (we could recheck
> the numbers then).
> 
> So the chain limit would only kick in if someone tries to exploit the fragment
> cache by using the method I demonstrated before (which was the reason I
> introduced this limit).

(To avoid pissing people off) I acknowledge that we should change the
hash size, as its ridiculously small with 64 entries.

But your mem limit assumption and hash depth limit assumptions are
broken, because the mem limit is per netns (network namespace).
Thus, starting more netns instances will break these assumptions.

The dangerous part of your change (commit 5a3da1fe) is that you keep the
existing frag queues (and don't allow new frag queues to be created).
The attackers fragments will never finish (timeout 30 sec), while valid
fragments will complete and "exit" the queue, thus the end result is
hash bucket is filled with attackers invalid/incomplete fragments.


Besides, after we have implemented per hash bucket locking (in my change
commit 19952cc4 "net: frag queue per hash bucket locking").
Then, I don't think it is a big problem that a single hash bucket is
being "attacked".

IMHO we should just revert the change (commit 5a3da1fe), and increase
the hash size and fix the hashing for IPv6.


And then I'll find another method for fixing the global LRU list
scalability problem (than the "direct-hash-cleaning" method).


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
