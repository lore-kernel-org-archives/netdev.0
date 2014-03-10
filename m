From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 07/14] net: sched: RCU cls_route
Date: Mon, 10 Mar 2014 10:45:16 -0700
Message-ID: <1394473516.3607.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170610.3011.72548.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:53569 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbaCJRpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:45:18 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so7329807pdj.40
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:45:18 -0700 (PDT)
In-Reply-To: <20140310170610.3011.72548.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:06 -0700, John Fastabend wrote:
> RCUify the route classifier. For now however spinlock's are used to
> protect fastmap cache.
> 
> The issue here is the fastmap may be read by one CPU while the
> cache is being updated by another. An array of pointers could be
> one possible solution.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_route.c |  217 ++++++++++++++++++++++++++++---------------------
>  1 file changed, 124 insertions(+), 93 deletions(-)
> 
> diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> index 1ad3068..cd0abba 100644
> --- a/net/sched/cls_route.c
> +++ b/net/sched/cls_route.c
> @@ -29,25 +29,26 @@
>   *    are mutually  exclusive.
>   * 3. "to TAG from ANY" has higher priority, than "to ANY from XXX"
>   */
> -
>  struct route4_fastmap {
> -	struct route4_filter	*filter;
> -	u32			id;
> -	int			iif;
> +	struct route4_filter		*filter;
> +	u32				id;
> +	int				iif;
>  };
>  
>  struct route4_head {
> -	struct route4_fastmap	fastmap[16];
> -	struct route4_bucket	*table[256 + 1];
> +	struct route4_fastmap		fastmap[16];
> +	struct route4_bucket __rcu	*table[256 + 1];
> +	struct rcu_head			rcu;
>  };
>  
>  struct route4_bucket {
>  	/* 16 FROM buckets + 16 IIF buckets + 1 wildcard bucket */
> -	struct route4_filter	*ht[16 + 16 + 1];
> +	struct route4_filter __rcu	*ht[16 + 16 + 1];
> +	struct rcu_head			rcu;
>  };
>  
>  struct route4_filter {
> -	struct route4_filter	*next;
> +	struct route4_filter __rcu	*next;
>  	u32			id;
>  	int			iif;
>  
> @@ -55,6 +56,8 @@ struct route4_filter {
>  	struct tcf_exts		exts;
>  	u32			handle;
>  	struct route4_bucket	*bkt;
> +	struct tcf_proto	*tp;
> +	struct rcu_head		rcu;
>  };
>  
>  #define ROUTE4_FAILURE ((struct route4_filter *)(-1L))
> @@ -64,14 +67,13 @@ static inline int route4_fastmap_hash(u32 id, int iif)
>  	return id & 0xF;
>  }
>  
> +static DEFINE_SPINLOCK(fastmap_lock);
>  static void
> -route4_reset_fastmap(struct Qdisc *q, struct route4_head *head, u32 id)
> +route4_reset_fastmap(struct route4_head *head)
>  {
> -	spinlock_t *root_lock = qdisc_root_sleeping_lock(q);
> -
> -	spin_lock_bh(root_lock);
> +	spin_lock(&fastmap_lock);

Dont you need spin_lock_bh() ?

>  	memset(head->fastmap, 0, sizeof(head->fastmap));
> -	spin_unlock_bh(root_lock);
> +	spin_unlock(&fastmap_lock);
>  }
>  
>  static void
> @@ -80,9 +82,12 @@ route4_set_fastmap(struct route4_head *head, u32 id, int iif,
>  {
>  	int h = route4_fastmap_hash(id, iif);
>  
> +	/* fastmap updates must look atomic to aling id, iff, filter */
> +	spin_lock(&fastmap_lock);

same here

>  	head->fastmap[h].id = id;
>  	head->fastmap[h].iif = iif;
>  	head->fastmap[h].filter = f;
> +	spin_unlock(&fastmap_lock);
>  }
>  
