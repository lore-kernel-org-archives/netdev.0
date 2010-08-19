From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH net-next-2.6] net: build_ehash_secret() and
	rt_bind_peer() cleanups
Date: Thu, 19 Aug 2010 12:28:05 -0400
Message-ID: <20100819162805.GC24357@Krystal>
References: <1282232815.2549.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts10.bellnexxia.net ([209.226.175.54]:44528 "EHLO
	tomts10-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750817Ab0HSQ2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 12:28:14 -0400
Received: from toip4.srvr.bell.ca ([209.226.175.87])
          by tomts10-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20100819162812.KVMT307.tomts10-srv.bellnexxia.net@toip4.srvr.bell.ca>
          for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 12:28:12 -0400
Content-Disposition: inline
In-Reply-To: <1282232815.2549.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet (eric.dumazet@gmail.com) wrote:
> Now cmpxchg() is available on all arches, we can use it in
> build_ehash_secret() and rt_bind_peer() instead of using spinlocks.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> ---
>  net/ipv4/af_inet.c |    8 +++-----
>  net/ipv4/route.c   |   11 +++--------
>  2 files changed, 6 insertions(+), 13 deletions(-)
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 6a1100c..f581f77 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -227,18 +227,16 @@ EXPORT_SYMBOL(inet_ehash_secret);
>  
>  /*
>   * inet_ehash_secret must be set exactly once
> - * Instead of using a dedicated spinlock, we (ab)use inetsw_lock
>   */
>  void build_ehash_secret(void)
>  {
>  	u32 rnd;
> +
>  	do {
>  		get_random_bytes(&rnd, sizeof(rnd));
>  	} while (rnd == 0);
> -	spin_lock_bh(&inetsw_lock);
> -	if (!inet_ehash_secret)
> -		inet_ehash_secret = rnd;
> -	spin_unlock_bh(&inetsw_lock);
> +
> +	cmpxchg(&inet_ehash_secret, 0, rnd);

I'd be more comfortable if you add a comment saying why you can get away
with not testing the cmpxchg failure case. (it's because the failure is
caused by a concurrent CPU setting the ehash secret to a random value,
which actually does the job for us, so no need to retry).

>  }
>  EXPORT_SYMBOL(build_ehash_secret);
>  
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 3f56b6e..ae3dba7 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1268,18 +1268,13 @@ skip_hashing:
>  
>  void rt_bind_peer(struct rtable *rt, int create)
>  {
> -	static DEFINE_SPINLOCK(rt_peer_lock);
>  	struct inet_peer *peer;
>  
>  	peer = inet_getpeer(rt->rt_dst, create);

Hrm, peer can be NULL on OOM condition.

>  
> -	spin_lock_bh(&rt_peer_lock);
> -	if (rt->peer == NULL) {
> -		rt->peer = peer;
> -		peer = NULL;
> -	}
> -	spin_unlock_bh(&rt_peer_lock);
> -	if (peer)
> +	peer = cmpxchg(&rt->peer, NULL, peer);
> +
> +	if (unlikely(peer))
>  		inet_putpeer(peer);

And you don't want to put the peer returned by cmpxchg, you want to put
the peer you just allocated.

I'd go for:

  if (!peer)
    return;
  if (unlikely(cmpxchg(&rt->peer, NULL, peer) != NULL))
    inet_putpeer(peer);

Thanks,

Mathieu


>  }
>  
> 
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
