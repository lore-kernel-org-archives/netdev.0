From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH v2 net-next 4/4] udp: add batching to udp_rmem_release()
Date: Thu, 08 Dec 2016 19:24:51 +0100
Message-ID: <1481221491.6120.11.camel@redhat.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
         <1481218739-27089-5-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34960 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751540AbcLHSYy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 13:24:54 -0500
In-Reply-To: <1481218739-27089-5-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 09:38 -0800, Eric Dumazet wrote:
> If udp_recvmsg() constantly releases sk_rmem_alloc
> for every read packet, it gives opportunity for
> producers to immediately grab spinlocks and desperatly
> try adding another packet, causing false sharing.
> 
> We can add a simple heuristic to give the signal
> by batches of ~25 % of the queue capacity.
> 
> This patch considerably increases performance under
> flood by about 50 %, since the thread draining the queue
> is no longer slowed by false sharing.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/udp.h |  3 +++
>  net/ipv4/udp.c      | 11 +++++++++++
>  2 files changed, 14 insertions(+)
> 
> diff --git a/include/linux/udp.h b/include/linux/udp.h
> index d1fd8cd39478..c0f530809d1f 100644
> --- a/include/linux/udp.h
> +++ b/include/linux/udp.h
> @@ -79,6 +79,9 @@ struct udp_sock {
>  	int			(*gro_complete)(struct sock *sk,
>  						struct sk_buff *skb,
>  						int nhoff);
> +
> +	/* This field is dirtied by udp_recvmsg() */
> +	int		forward_deficit;
>  };
>  
>  static inline struct udp_sock *udp_sk(const struct sock *sk)
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 880cd3d84abf..f0096d088104 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1177,8 +1177,19 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
>  /* fully reclaim rmem/fwd memory allocated for skb */
>  static void udp_rmem_release(struct sock *sk, int size, int partial)
>  {
> +	struct udp_sock *up = udp_sk(sk);
>  	int amt;
>  
> +	if (likely(partial)) {
> +		up->forward_deficit += size;
> +		size = up->forward_deficit;
> +		if (size < (sk->sk_rcvbuf >> 2))
> +			return;
> +	} else {
> +		size += up->forward_deficit;
> +	}
> +	up->forward_deficit = 0;
> +
>  	atomic_sub(size, &sk->sk_rmem_alloc);
>  	sk->sk_forward_alloc += size;
>  	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);

Nice one! This sounds like a relevant improvement! 

I'm wondering if it may cause regressions with small value of
sk_rcvbuf ?!? e.g. with:

netperf -t UDP_STREAM  -H 127.0.0.1 -- -s 1280 -S 1280 -m 1024 -M 1024

I'm sorry, I fear I will not unable to do any test before next week.

Cheers,

Paolo
