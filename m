From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 1/3] net: fix race bug in fragmentation create code
Date: Fri, 19 Apr 2013 03:00:06 +0200
Message-ID: <20130419010006.GE27889@order.stressinduktion.org>
References: <20130418213637.14296.43143.stgit@dragon> <20130418213715.14296.43912.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51443 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967716Ab3DSBAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 21:00:07 -0400
Content-Disposition: inline
In-Reply-To: <20130418213715.14296.43912.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 11:37:27PM +0200, Jesper Dangaard Brouer wrote:
> During creation of a new inet_frag_queue, the lru_list pointer is
> updated after releasing the hash bucket lock, which can lead to a
> race condition (and panic), if the inet_frag_queue is deleted
> (very quickly) before the lru_list is valid.
> 
> This race condition is should not be able to occur with current
> LRU based evictor.  For the planned direct hash based
> evictor/clean strategy, this race condition is more likely to
> occur.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> 
>  net/ipv4/inet_fragment.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index e97d66a..beec05b 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -283,9 +283,9 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
>  
>  	atomic_inc(&qp->refcnt);
>  	hlist_add_head(&qp->list, &hb->chain);
> +	inet_frag_lru_add(nf, qp);
>  	spin_unlock(&hb->chain_lock);
>  	read_unlock(&f->lock);
> -	inet_frag_lru_add(nf, qp);
>  	return qp;
>  }

If I checked correctly, the current code does not have the race
condition? I think this change is ok but maybe we can defer it until
the direct hash cleanup patches land?

Thanks,

  Hannes
