From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash
 table
Date: Wed, 13 Mar 2013 06:29:28 +0100
Message-ID: <1363152568.13690.35.camel@edumazet-glaptop>
References: <20130307214211.GP7941@order.stressinduktion.org>
	 <20130308055718.GA28531@order.stressinduktion.org>
	 <20130308130433.GB28531@order.stressinduktion.org>
	 <1362754386.15793.226.camel@edumazet-glaptop>
	 <20130308150831.GD28531@order.stressinduktion.org>
	 <1362756219.15793.240.camel@edumazet-glaptop>
	 <20130313012715.GE14801@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, brouer@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:44216 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab3CMF3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 01:29:32 -0400
Received: by mail-ea0-f172.google.com with SMTP id d10so217174eaj.3
        for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 22:29:30 -0700 (PDT)
In-Reply-To: <20130313012715.GE14801@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-13 at 02:27 +0100, Hannes Frederic Sowa wrote:

> 
> [PATCH net-next RFC] inet: add max_depth to limit list length in inet_frags hash
> 
> This does implement trivial drop for fragments where the hash queue
> is above some limit.
> 
> I calculate the limit as follow:
> 
> I averaged the folowing formula
> 
> max_depth = max_threshold / INETFRAGS_HASHSZ / rounded up (SKB_TRUELEN(0)
>             sizeof(struct ipq or struct frag_queue))
> 
> to
> 
> max_threshold >> 15
> 
> So we start with a maximum list length of 128. I think we could halve
> this value to 64, but because I have no real performance data I left it
> at this higher value for now.
> 
> This patch does only protect IPv6 (and not netfilter ipv6 defragmentation)
> and will switch off limit checking if max_depth is zero. I'll rewrite
> the check if we agree that this simple solution is the way to go (simple
> drop) and will clamp the minimum value to 1 as soon as I also migrated
> ipv4 and netfilter to the new sysctl handler.
> 
> When testing this patch:
> 
> Disable netfilter defragmenation for ipv6 on your machine if you test
> this patch, otherwise you won't see the improvment. Machine now runs
> smoothly under fragmentation dos.
> 
> Ok if I target this patch for net next time because the hashing changes
> are in there already?
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/inet_frag.h  | 13 +++++++++++++
>  net/ipv4/inet_fragment.c | 25 ++++++++++++++++++++++++-
>  net/ipv6/reassembly.c    |  6 +++++-
>  3 files changed, 42 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index 76c3fe5..9ba6ada 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -17,6 +17,7 @@ struct netns_frags {
>  	int			timeout;
>  	int			high_thresh;
>  	int			low_thresh;
> +	int			max_depth;
>  };
>  
>  struct inet_frag_queue {
> @@ -43,6 +44,11 @@ struct inet_frag_queue {
>  
>  #define INETFRAGS_HASHSZ		64
>  
> +/* max_depth = max_threshold / INETFRAGS_HASHSZ / rounded up (SKB_TRUELEN(0) +
> + *	       sizeof(struct ipq or struct frag_queue))
> + */
> +#define INETFRAGS_MAXDEPTH_SHIFT	15
> +

This looks like a bit complex to me, as we cant change INETFRAGS_HASHSZ
from userland.

I would just a use a predefined max depth of 128, or even less.
If we have 128 items in a hash chain, then something is really wrong
with our choices.

> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index 245ae07..92f1fdd 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -277,6 +277,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
>  	__releases(&f->lock)
>  {
>  	struct inet_frag_queue *q;
> +	int depth = 0;
>  
>  	hlist_for_each_entry(q, &f->hash[hash], list) {
>  		if (q->net == nf && f->match(q, key)) {
> @@ -284,9 +285,31 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
>  			read_unlock(&f->lock);
>  			return q;
>  		}
> +		depth++;
>  	}
>  	read_unlock(&f->lock);
>  
> -	return inet_frag_create(nf, f, key);
> +	if (!nf->max_depth || depth <= nf->max_depth)
> +		return inet_frag_create(nf, f, key);
> +	else
> +		return NULL;
>  }

I would issue a one one time warning in syslog when depth exceeds the
limit.

Thanks !
