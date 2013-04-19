From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Fri, 19 Apr 2013 16:29:02 +0200
Message-ID: <1366381742.26911.166.camel@localhost>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
	 <20130419124528.GF27889@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030552Ab3DSO3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 10:29:10 -0400
In-Reply-To: <20130419124528.GF27889@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 14:45 +0200, Hannes Frederic Sowa wrote:
> On Fri, Apr 19, 2013 at 02:19:10PM +0200, Jesper Dangaard Brouer wrote:
> > I beg to differ.
> > 
> > First if all, I also though keeping fragments were the right choice, BUT
> > then I realized that we cannot tell god-from-bad frags apart, and an
> > attacker will obviously generate more fragments than the real traffic,
> > thus we end up keeping the attackers fragment for 30 sec. Because the
> > attacker will never "finish/complete" his fragment queues.
> > Thus, the real "help" for a DoS attack is to keep fragments.
> >
> > Second, I have clearly shown, with my performance tests, that frags will
> > complete under DoS.
> 
> How did you simulate the DoS? Did you try to fill up specific buckets or did
> you try to fill up the whole fragment cache?

I'm using trafgen (part of netsniff-ng git download from
https://github.com/borkmann/netsniff-ng).

Simple DoS test setup read (scroll down):
 http://thread.gmane.org/gmane.linux.network/257155

As mentioned last time:
 http://article.gmane.org/gmane.linux.network/263644

I have extended the DoS generator. quote:
 'I have changed the frag DoS generator script to be more
efficient/deadly.  Before it would only hit one RX queue, now its
sending packets causing multi-queue RX, due to "better" RX hashing.'

I have placed the new "multi-queue" trafgen script/input here:
http://people.netfilter.org/hawk/frag_work/trafgen/frag_packet05_small_frag_multi_queue.txf

Perhaps you can tell me, if my trafgen traffic is getting hashed badly?


> > > I am not sure its worth adding extra complexity.
> > 
> > It's not that complex, and we simply need it, else an attacker can DoS
> > us very easily by sending a burst every 30 sec.  We do need this change,
> > else we must revert Hannes patch, and find a complete other approach of
> > removing the LRU list system.
> 
> I agree that we have to do something to mitigate this. I would also
> drop the sysctl, I do think the kernel should have to take care of that.
> 
> Perhaps a way to solve this problem more easily would be to switch back to
> use a jenkins hash for all inputs of the hash function and not deal with this
> kind of unfairness regarding the possiblity to fill up one of the buckets.
> 
> Perhaps the performance improvements by Jesper (per bucket locking) could make
> up the more expensive hashing. :)

Well, I don't know.  But we do need some solution, to the current code.


> Just some minor things I found while looking at the patch:
> 
> > -
> > -/* averaged:
> > - * max_depth = default ipfrag_high_thresh / INETFRAGS_HASHSZ /
> > - *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
> > - *	       struct frag_queue))
> > - */
> > -#define INETFRAGS_MAXDEPTH		128
> > +#define INETFRAGS_MAX_HASH_DEPTH	32
> 
> Perhaps a comment could be added, that this is only a default value for the
> max hash depth.

Yes, I though of calling it INETFRAGS_MAX_HASH_DEPTH_DEFAULT, but it was
getting too long.  But now you and Eric argue against making this
tune-able, so it might be the right "name".

 
> 
> > -void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
> > +void __inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f,
> > +		      bool unlink_hash)
> 
> This function could be static.

(Sorry to be dumb) could you explain the benefit of doing so?


> > -	hlist_for_each_entry(q, &hb->chain, list) {
> > +	hlist_for_each_entry_safe(q, n, &hb->chain, list) {
> 
> Minor, but I think _safe is not needed here.

Yes, the hash unlink happens after we have exited the for_each loop.


> > +static int zero;
> > +
> 
> Could be const.

Could you also explain the benefit of doing so for a variable?


--Jesper
