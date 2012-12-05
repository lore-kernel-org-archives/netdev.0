From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Wed, 05 Dec 2012 10:24:22 +0100
Message-ID: <1354699462.20888.207.camel@localhost>
References: <1354319937.20109.285.camel@edumazet-glaptop>
	 <20121204133007.20215.52566.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab2LEJ05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 04:26:57 -0500
In-Reply-To: <20121204133007.20215.52566.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First of all, this patch contains a small bug (see below), which
resulted in me not testing the correct patch...

Second, this patch does NOT behave as I expected and claimed.  Thus, my
conclusions, in my previous respond might be wrong!

The previous evictor patch of letting new fragments enter, worked
amazingly well.  But I suspect, this might also be related to a
bug/problem in the evictor loop (which were being hidden by that patch).

My new *theory* is that the evictor loop, will be looping too much, if
it finds a fragment which is INET_FRAG_COMPLETE ... in that case, we
don't advance the LRU list, and thus will pickup the exact same
inet_frag_queue again in the loop... to get out of the loop we need
another CPU or packet to change the LRU list for us... I'll test that
theory... (its could also be CPUs fighting over the same LRU head
element that cause this) ... more to come...


On Tue, 2012-12-04 at 14:30 +0100, Jesper Dangaard Brouer wrote:
> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index 4750d2b..d8bf59b 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -178,6 +178,16 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
>  
>  		q = list_first_entry(&nf->lru_list,
>  				struct inet_frag_queue, lru_list);
> +
> +		/* When head of LRU is very new/warm, then the head is
> +		 * most likely the one with most fragments and the
> +		 * tail with least, thus drop tail
> +		 */
> +		if (!force && q->creation_ts == (u32) jiffies) {
> +			q = list_entry(&nf->lru_list.prev,

Remove the "&" in &nf->lru_list.prev

> +				struct inet_frag_queue, lru_list);
> +		}
> +
>  		atomic_inc(&q->refcnt);
>  		read_unlock(&f->lock);
