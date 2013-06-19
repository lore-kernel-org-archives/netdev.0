From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock: adapt SOCK_MIN_RCVBUF and
 SOCK_MIN_SNDBUF
Date: Wed, 19 Jun 2013 02:51:45 -0700
Message-ID: <1371635505.3252.285.camel@edumazet-glaptop>
References: <1371633518-32656-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:57727 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933830Ab3FSJvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 05:51:51 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so3148789eaj.41
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 02:51:49 -0700 (PDT)
In-Reply-To: <1371633518-32656-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 11:18 +0200, Daniel Borkmann wrote:
> The current situation is that SOCK_MIN_RCVBUF is 2048 + sizeof(struct sk_buff))
> while SOCK_MIN_SNDBUF is 2048. Since in both cases, skb->truesize is used for
> sk_{r,w}mem_alloc accounting, we should have both sizes equal and adjusted
> through the macro SKB_TRUESIZE(), which is also used elsewhere to adjust sk
> buffer sizes. The minor adaption in sk_stream_moderate_sndbuf() is to silence
> a warning by using a typed max macro, as similarly done in SOCK_MIN_RCVBUF
> occurences, that would appear otherwise.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/sock.h | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index ac8e181..189ef98 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2045,18 +2045,19 @@ static inline void sk_wake_async(struct sock *sk, int how, int band)
>  		sock_wake_async(sk->sk_socket, how, band);
>  }
>  
> -#define SOCK_MIN_SNDBUF 2048
>  /*
> - * Since sk_rmem_alloc sums skb->truesize, even a small frame might need
> - * sizeof(sk_buff) + MTU + padding, unless net driver perform copybreak
> + * Since sk_{r,w}mem_alloc sums skb->truesize, even a small frame might
> + * need sizeof(sk_buff) + sizeof(skb_shared_info) + MTU + padding, unless
> + * net driver perform copybreak.
>   */
> -#define SOCK_MIN_RCVBUF (2048 + sizeof(struct sk_buff))
> +#define SOCK_MIN_RCVBUF		SKB_TRUESIZE(2048)
> +#define SOCK_MIN_SNDBUF		SKB_TRUESIZE(2048)
> 
>  
>  static inline void sk_stream_moderate_sndbuf(struct sock *sk)
>  {
>  	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK)) {
>  		sk->sk_sndbuf = min(sk->sk_sndbuf, sk->sk_wmem_queued >> 1);
> -		sk->sk_sndbuf = max(sk->sk_sndbuf, SOCK_MIN_SNDBUF);
> +		sk->sk_sndbuf = max_t(u32, sk->sk_sndbuf, SOCK_MIN_SNDBUF);
>  	}
>  }
>  

Funny you send this patch, because I prepared a similar patch
yesterday ;)

My motivation was a bit different, because we hit a (small) regression
here in Google for some applications setting low SO_SNDBUF/SO_RCVBUF
values, because of new TCP needs :

Minimal skb truesize in transmit path is indeed SKB_TRUESIZE(2048) after
commit f07d960df33c5aef ("tcp: avoid frag allocation for small frames")

And tcp sendmsg() tries to limit skb size to half the congestion window,
meaning we try to build two skbs at minimum.

So I believe that we need :

/* TCP works better if we can build two skbs at minimum */
#define SOCK_MIN_SNDBUF		(2 * SKB_TRUESIZE(2048))
