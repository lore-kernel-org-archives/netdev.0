From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash list depth
Date: Fri, 19 Apr 2013 14:45:28 +0200
Message-ID: <20130419124528.GF27889@order.stressinduktion.org>
References: <20130418213637.14296.43143.stgit@dragon> <20130418213732.14296.36026.stgit@dragon> <1366366287.3205.98.camel@edumazet-glaptop> <1366373950.26911.134.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52255 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968316Ab3DSMp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:45:29 -0400
Content-Disposition: inline
In-Reply-To: <1366373950.26911.134.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 02:19:10PM +0200, Jesper Dangaard Brouer wrote:
> I beg to differ.
> 
> First if all, I also though keeping fragments were the right choice, BUT
> then I realized that we cannot tell god-from-bad frags apart, and an
> attacker will obviously generate more fragments than the real traffic,
> thus we end up keeping the attackers fragment for 30 sec. Because the
> attacker will never "finish/complete" his fragment queues.
> Thus, the real "help" for a DoS attack is to keep fragments.
>
> Second, I have clearly shown, with my performance tests, that frags will
> complete under DoS.

How did you simulate the DoS? Did you try to fill up specific buckets or did
you try to fill up the whole fragment cache?

> > I am not sure its worth adding extra complexity.
> 
> It's not that complex, and we simply need it, else an attacker can DoS
> us very easily by sending a burst every 30 sec.  We do need this change,
> else we must revert Hannes patch, and find a complete other approach of
> removing the LRU list system.

I agree that we have to do something to mitigate this. I would also
drop the sysctl, I do think the kernel should have to take care of that.

Perhaps a way to solve this problem more easily would be to switch back to
use a jenkins hash for all inputs of the hash function and not deal with this
kind of unfairness regarding the possiblity to fill up one of the buckets.

Perhaps the performance improvements by Jesper (per bucket locking) could make
up the more expensive hashing. :)

Just some minor things I found while looking at the patch:

> -
> -/* averaged:
> - * max_depth = default ipfrag_high_thresh / INETFRAGS_HASHSZ /
> - *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
> - *	       struct frag_queue))
> - */
> -#define INETFRAGS_MAXDEPTH		128
> +#define INETFRAGS_MAX_HASH_DEPTH	32

Perhaps a comment could be added, that this is only a default value for the
max hash depth.
 
 
> -void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
> +void __inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f,
> +		      bool unlink_hash)

This function could be static.

> -	hlist_for_each_entry(q, &hb->chain, list) {
> +	hlist_for_each_entry_safe(q, n, &hb->chain, list) {

Minor, but I think _safe is not needed here.

> +static int zero;
> +

Could be const.

Thanks,

  Hannes
