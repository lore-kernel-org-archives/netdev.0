From: Jason Baron <jasonbaron0@gmail.com>
Subject: Re: [PATCH v2 net-next 1/6] net: fix sk_mem_reclaim_partial()
Date: Mon, 03 Aug 2015 16:53:51 -0400
Message-ID: <55BFD4DF.30703@gmail.com>
References: <1431718770-3815-1-git-send-email-edumazet@google.com> <1431718770-3815-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jason Baron <jbaron@akamai.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35549 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266AbbHCUxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 16:53:54 -0400
Received: by qkbm65 with SMTP id m65so55410422qkb.2
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 13:53:54 -0700 (PDT)
In-Reply-To: <1431718770-3815-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/15/2015 03:39 PM, Eric Dumazet wrote:
> sk_mem_reclaim_partial() goal is to ensure each socket has
> one SK_MEM_QUANTUM forward allocation. This is needed both for
> performance and better handling of memory pressure situations in
> follow up patches.
> 
> SK_MEM_QUANTUM is currently a page, but might be reduced to 4096 bytes
> as some arches have 64KB pages.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/sock.h | 6 +++---
>  net/core/sock.c    | 9 +++++----
>  2 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index d882f4c8e438..4581a60636f8 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1368,7 +1368,7 @@ static inline struct inode *SOCK_INODE(struct socket *socket)
>   * Functions for memory accounting
>   */
>  int __sk_mem_schedule(struct sock *sk, int size, int kind);
> -void __sk_mem_reclaim(struct sock *sk);
> +void __sk_mem_reclaim(struct sock *sk, int amount);
>  
>  #define SK_MEM_QUANTUM ((int)PAGE_SIZE)
>  #define SK_MEM_QUANTUM_SHIFT ilog2(SK_MEM_QUANTUM)
> @@ -1409,7 +1409,7 @@ static inline void sk_mem_reclaim(struct sock *sk)
>  	if (!sk_has_account(sk))
>  		return;
>  	if (sk->sk_forward_alloc >= SK_MEM_QUANTUM)
> -		__sk_mem_reclaim(sk);
> +		__sk_mem_reclaim(sk, sk->sk_forward_alloc);
>  }
>  
>  static inline void sk_mem_reclaim_partial(struct sock *sk)
> @@ -1417,7 +1417,7 @@ static inline void sk_mem_reclaim_partial(struct sock *sk)
>  	if (!sk_has_account(sk))
>  		return;
>  	if (sk->sk_forward_alloc > SK_MEM_QUANTUM)
> -		__sk_mem_reclaim(sk);
> +		__sk_mem_reclaim(sk, sk->sk_forward_alloc - 1);
>  }
>

Hi,

Was just looking at this again - this doesn't ensure the SK_MEM_QUANTUM
minimum as the comment suggests- should it be:

_sk_mem_reclaim(sk, sk->sk_forward_alloc - SK_MEM_QUANTUM);
					   ^^^^^^^^^^^^^^^

Or are you just trying to make sure its not 0?

Thanks,

-Jason
													
